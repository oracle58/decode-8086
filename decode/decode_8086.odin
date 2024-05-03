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

REG_8 :: enum {
    AL = 0b000,
    CL = 0b001,
    DL = 0b010,
    BL = 0b011,
    AH = 0b100,
    CH = 0b101,
    DH = 0b110,
    BH = 0b111
}

REG_16 :: enum {
    AX = 0b000, //decimal = 0
    CX = 0b001, //decimal = 1
    DX = 0b010, //decimal = 2
    BX = 0b011, // 3
    SP = 0b100,
    BP = 0b101, //...
    SI = 0b110,
    DI = 0b111, //7
}

MOD :: enum {
    DISP_NO = 0b00,
    DISP_LO = 0b01,
    DISP_HI = 0b10,
    REG = 0b11
}

reg_to_string :: proc(reg_code: u8, w: bool) -> string {
    reg_names: [16]string = {"al", "cl", "dl", "bl", "ah", "ch", "dh", "bh",
                             "ax", "cx", "dx", "bx", "sp", "bp", "si", "di"}
    if w { 
        return reg_names[reg_code + 8]
    } else {
        return reg_names[reg_code]
    }
}

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

parse_instructions :: proc(data: []u8) -> string {
    decoded_str := "Bits 16\n\n"
    data_len := len(data)

    //TODO: need to iterate by instruction size
    for i:=0; i < data_len-1; i+=2 {
        opcode_byte := data[i]
        modrm_byte := data[i + 1]

        w := (opcode_byte & W_MASK) != 0
        d := (opcode_byte & D_MASK) != 0
        mod := (modrm_byte & MOD_MASK) >> MOD_OFFSET
        reg := (modrm_byte & REG_MASK) >> REG_OFFSET
        rm := (modrm_byte & RM_MASK)

          
        displacement_size := 0
        mnemonic := "mov"
        formatted_instruction: string
        dest: string
        src: string

        switch mod {
        case u8(MOD.REG):
            if (d) {
                dest  = reg_to_string(reg, w)
                src = reg_to_string(rm, w)
            } else {
                dest = reg_to_string(rm, w)
                src  = reg_to_string(reg, w)
            }
            formatted_instruction = fmt.aprintf("%s %s, %s \n", mnemonic, dest, src )
        }
        decoded_str = strings.concatenate({decoded_str, formatted_instruction})
    }
    return decoded_str
}