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

OPCODE :: enum {
    MOV = 0b100010
}

REG_LH :: enum{
    AL = 0b000,  
    CL = 0b001,  
    DL = 0b010,  
    BL = 0b011,  
    AH = 0b100,  
    CH = 0b101,  
    DH = 0b110,  
    BH = 0b111  
}

REG_X :: enum {
    AX = 0b000,  
    CX = 0b001,  
    DX = 0b010,  
    BX = 0b011,  
    SP = 0b100,  
    BP = 0b101,  
    SI = 0b110,  
    DI = 0b111   
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

parse_instruction :: proc (data: []u8, index: int) -> (u8, u8, u8, u8, u8, u8){
    opcode_byte := data[index]
    modrm_byte := data[index+1]

    opcode := (opcode_byte & OPCODE_MASK) >> OPCODE_OFFSET
    d := (opcode_byte & D_MASK) >> D_OFFSET
    w := (opcode_byte & W_MASK) 
    mod := (modrm_byte & MOD_MASK) >> MOD_OFFSET
    reg := (modrm_byte & REG_MASK) >> REG_OFFSET
    rm := (modrm_byte & RM_MASK)

    return opcode, d, w, mod, reg, rm
}

opcode_to_string :: proc(opcode_byte: u8) -> string {
    switch opcode_byte {
        case u8(OPCODE.MOV):
            return "mov"
        case: 
            panic("unrecognized opcode")
    }
}

reg_to_string :: proc(reg_byte: u8, w: u8) -> string {
    if w == 1 {
        switch reg_byte {
            case u8(REG_X.AX): return "ax"
            case u8(REG_X.CX): return "cx"
            case u8(REG_X.DX): return "dx"
            case u8(REG_X.BX): return "bx"
            case u8(REG_X.SP): return "sp"
            case u8(REG_X.BP): return "bp"
            case u8(REG_X.SI): return "si"
            case u8(REG_X.DI): return "di"
            case: 
                panic("unrecognized registry encoding")
        }
    } else {
        switch reg_byte {
            case u8(REG_LH.AL): return "al"
            case u8(REG_LH.CL): return "cl"
            case u8(REG_LH.DL): return "dl"
            case u8(REG_LH.BL): return "bl"
            case u8(REG_LH.AH): return "ah"
            case u8(REG_LH.CH): return "ch"
            case u8(REG_LH.DH): return "dh"
            case u8(REG_LH.BH): return "bh"
            case: 
                panic("unrecognized registry encoding")
        }
    }
}

format_instructions :: proc(data: []u8) -> string {
    result := strings.Builder{}
    defer strings.builder_destroy(&result)

    str := "bits 16\n\n"

    for i := 0; i < len(data) - 1; i += 2 {
        opcode, d, w, mod, reg, rm := parse_instruction(data, i)
        opcode_str := opcode_to_string(opcode)
        source := reg_to_string(reg, w)
        dest := reg_to_string(rm, w)
        line := fmt.aprintf("%s %s, %s\n", opcode_str, dest, source)
        str = strings.concatenate({str, line})
    }
    return str
}
