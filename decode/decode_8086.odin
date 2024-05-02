package decode

import "core:fmt"
import "core:os"
import "core:strings"

OPCODE_MASK   :: 0b11111100
D_MASK        :: 0b00000010
W_MASK        :: 0b00000001
MOD_MASK      :: 0b11000000
REG_MASK      :: 0b00111000
RM_MASK       :: 0b00000111

OPCODE_OFFSET :: 2
D_OFFSET      :: 1
MOD_OFFSET    :: 6
REG_OFFSET    :: 3
RM_OFFSET     :: 0

AX :: 0b110 //NOTE: Accumulator is a special case as it has 16-bit displacement when used with mod=00

MOD :: enum {
    DISP_NO = 0b00,
    DISP_LO = 0b01,
    DISP_HI = 0b10,
    REG = 0b11
}

reg_to_string :: proc(reg_code: u8, w: bool) -> string {
    base_reg_names: [16]string = {"al", "cl", "dl", "bl", "ah", "ch", "dh", "bh",
                                  "ax", "cx", "dx", "bx", "sp", "bp", "si", "di"}
    if w {
        if reg_code >= 0b110 {  //SP, BP, SI, DI don
            return base_reg_names[reg_code] 
        } else {
            return base_reg_names[reg_code + 8] // Offset to reach AX, CX, DX, BX
        } 
    } else {
        // For byte operations, use the name directly including `h` and `l`
        return base_reg_names[reg_code]
    }
}

// Function to read binary instructions from a file
read_instructions :: proc(path: string) -> []u8 {
    f, open_err := os.open(path, os.O_RDONLY, 0)
    defer os.close(f)
    if open_err != os.ERROR_NONE {
        fmt.println("Error opening file: ", open_err)
        return nil
    }
    file_info, _ := os.fstat(f)
    buffer := make([]u8, file_info.size)
    bytes, read_err := os.read(f, buffer)
    if read_err != os.ERROR_NONE {
        fmt.println("Error reading file: ", read_err)
        return nil
    }
    return buffer[:bytes]
}

parse_instruction :: proc(data: []u8, index: int, data_length: int) -> (string, int) {
    if index + 1 >= data_length {
        return "End of data reached unexpectedly.", index  // Prevent reading beyond the array
    }

    opcode_byte := data[index]
    modrm_byte := data[index + 1]

    w := (opcode_byte & W_MASK) != 0
    mod := (modrm_byte & MOD_MASK) >> MOD_OFFSET
    reg := (modrm_byte & REG_MASK) >> REG_OFFSET
    rm := (modrm_byte & RM_MASK)

    instruction_size := 2  // Base size for opcode and ModR/M byte
    displacement_size := 0
    immediate_value := ""
    addressing := ""

    switch mod {
    case u8(MOD.DISP_NO):
        if rm == AX {
            if index + 3 >= data_length { return "Not enough data for displacement.", index }
            displacement_size = 2  // Direct addressing with 16-bit displacement
            addressing = fmt.aprintf("[%d]", read_word(data, index + 2))
            instruction_size += displacement_size
        } else {
            addressing = fmt.aprintf("[%s]", reg_to_string(rm, true)) 
        }
    case u8(MOD.DISP_LO):
        if index + 2 >= data_length { return "Not enough data for low displacement.", index }
        displacement_size = 1  // 8-bit displacement
        addressing = fmt.aprintf("[%s + %d]", reg_to_string(rm, true), data[index + 2])
        instruction_size += displacement_size
    case u8(MOD.DISP_HI):
        if index + 3 >= data_length { return "Not enough data for high displacement.", index }
        displacement_size = 2  // 16-bit displacement
        addressing = fmt.aprintf("[%s + %d]", reg_to_string(rm, true), read_word(data, index + 2))
        instruction_size += displacement_size
    case u8(MOD.REG):
        addressing = reg_to_string(rm, w) 
    }

    if w && mod != u8(MOD.REG) {
        if index + instruction_size + 1 >= data_length {
            return "Not enough data for immediate value.", index
        }
        immediate_value = fmt.aprintf(", %d", read_word(data, index + instruction_size))
        instruction_size += 2
    } else if !w && mod != u8(MOD.REG) {
        if index + instruction_size >= data_length {
            return "Not enough data for immediate byte value.", index
        }
        immediate_value = fmt.aprintf(", %d", data[index + instruction_size])
        instruction_size += 1
    }

    formatted_instruction := fmt.aprintf("mov %s, %s%s", addressing, reg_to_string(reg, w), immediate_value)
    return formatted_instruction, instruction_size
}

format_instructions :: proc(data: []u8) -> string {
    result := "Bits 16\n\n"
    i := 0
    for i < len(data) {
        instruction, size := parse_instruction(data, i, len(data))
        result = strings.concatenate({result, fmt.aprintf("%s\n", instruction)})
        i += size
    }
    return result
}

read_word :: proc(data: []u8, index: int) -> u16 {
    return u16(data[index]) | (u16(data[index + 1]) << 8)
}
