package decode

import "core:fmt"
import "core:os"
import "core:strings"

BITS_PER_BYTE :: 8
LINES         :: 2

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

OPCODE :: enum {
    MOV = 0b100010
}

REG :: enum {
    BX = 0b011,
    CX = 0b001
}

read_bytes :: proc(path: string) -> []u8 {
    f, open_err := os.open(path, os.O_RDONLY, 0)
    defer os.close(f)
    if open_err != os.ERROR_NONE {
        fmt.println("Error opening file: ", open_err)
        return nil
    }
    buffer := make([]u8, LINES) 
    bytes, read_err := os.read(f, buffer)
    if read_err != os.ERROR_NONE {
        fmt.println("Error reading file: ", read_err)
        return nil
    }
    return buffer[:bytes] 
}

parse_instruction :: proc (path: string) -> (u8, u8, u8, u8, u8, u8){
    data := read_bytes(path)

    opcode_byte := data[0]
    modrm_byte := data[1]

    opcode := (opcode_byte & OPCODE_MASK) >> OPCODE_OFFSET
    d := (opcode_byte & D_MASK) >> D_OFFSET
    w := (opcode_byte & W_MASK) 
    mod := (modrm_byte & MOD_MASK) >> MOD_OFFSET
    reg := (modrm_byte & REG_MASK) >> REG_OFFSET
    rm := (modrm_byte & RM_MASK)

    return opcode, d, w, mod, reg, rm
}

opcode :: proc(opcode_byte: u8) -> string {
    switch opcode_byte {
        case u8(OPCODE.MOV):
            return "mov"
        case: 
            return ""    
    }
}

reg :: proc(reg_byte: u8) -> string {
    switch reg_byte {
        case u8(REG.BX):
            return "bx"
        case u8(REG.CX):
            return "cx"
        case: 
            return ""    
    }
}



