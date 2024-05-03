package decode

import "core:fmt"
import "core:os"
import "core:strings"

//NOTE: remove constants as these patterns differ from case to case
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

OPCODES :: enum {
    REG_RM = 0b100010,
    IMMEDIATE_RM = 0b110011,
    IMMEDIATE_REG = 0b1011,
}


MOD :: enum {
    DISP_NO = 0b00,
    DISP_LO = 0b01,
    DISP_HI = 0b10,
    REG = 0b11
}

parse_reg :: proc(reg_code: u8, w: bool) -> string {
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

iterator_limit: int = 26

parse_instructions :: proc(data: []u8) -> string {
    mod_00: [8]string= {"[bx + si]", "[bx + di]", "[bp + si]", "[bp + di]", "si", "di", "", "bx"}
    decoded_str := "Bits 16\n\n"
    data_len := len(data)
    fmt.printfln("%b", data)

    //TODO: need to iterate by instruction size
    for i:=0; i < iterator_limit; {
        opcode_byte := data[i]
        
        mnemonic := "mov"
        formatted_instruction: string
        dest: string
        src: string
        
        w: bool
        d: bool
        reg: u8 
        rm: u8 
        size:int = 2

        if (opcode_byte >> 2 == u8(OPCODES.REG_RM)) {  
            
            data_byte := data[i + 1]  

            w = (opcode_byte & 0b00000001) != 0
            d = (opcode_byte & 0b00000010) != 0

            reg = (data_byte & REG_MASK) >> REG_OFFSET
            rm = (data_byte & RM_MASK)
            mod := (data_byte & MOD_MASK) >> MOD_OFFSET
            if (d) {
                dest  = parse_reg(reg, w)
                if (mod == 0b11) {
                    src = parse_reg(rm, w)
                } else if (mod == 0b00)
                {
                    reg_code := data_byte & 0b00000111
                    src =fmt.aprintf("%s", mod_00[reg_code])
                }
            } else {
                dest = parse_reg(rm, w)
                if (mod == 0b11) {
                    src = parse_reg(reg, w)
                }
            }
        }
        else if (opcode_byte >> 4 == u8(OPCODES.IMMEDIATE_REG)) { 

            w = (opcode_byte & 0b00001000) != 0
            reg = (opcode_byte & 0b00000111) 
            dest = parse_reg(reg, w)
            if w {
                size = 3
                low_byte := data[i + 1]  
                high_byte := data[i + 2] 
                value := concat_bits(low_byte, high_byte)
                src = fmt.aprintf("%d", parse_sign_u16(value)) 
            } else {
                data_byte := data[i + 1]  
                src = fmt.aprintf("%d", parse_sign_u8(data_byte)) 
            } 
        }
        formatted_instruction = fmt.aprintf("%s %s, %s \n", mnemonic, dest, src)
        decoded_str = strings.concatenate({decoded_str, formatted_instruction})
        i+=size
    }
    return decoded_str
}

parse_sign_u8 :: proc(value: u8) -> int {
    if value & 0x80 != 0 {  // Check if the MSB (bit 8) is set
        return int(i8(value))  
    } else {
        return int(value)
    }
}

parse_sign_u16 :: proc(value: u16) -> int {
    if value & 0x8000 != 0 {  // Check if the MSB (bit 16) is set
        return int(i16(value))  
    } else {
        return int(value)
    }
}

concat_bits :: proc(low_byte: u8, high_byte: u8, ) -> u16 {
    return u16(low_byte) | u16(high_byte) << 8
}