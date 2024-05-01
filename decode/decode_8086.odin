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


run :: proc() {
    path := "decode/listing_0037_single_register_mov"
    data := read_bytes(path)

    low_bits := data[0]
    high_bits := data[1]
    
    opcode := (low_bits & OPCODE_MASK) >> OPCODE_OFFSET
    d := (low_bits & D_MASK) >> D_OFFSET
    w := (low_bits & W_MASK) 
    mod := (high_bits & MOD_MASK) >> MOD_OFFSET
    reg := (high_bits & REG_MASK) >> REG_OFFSET
    rm := (high_bits & RM_MASK)

    print(low_bits, high_bits, opcode, d, w, mod, reg, rm)
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

print :: proc(low_bits: u8, high_bits: u8, opcode: u8, d: u8, w: u8, mod: u8, reg: u8, rm: u8) {
    fmt.printfln("INSTRUCTION: %b%b", low_bits, high_bits)
    fmt.printfln("OPCODE     : %b", opcode)
    fmt.printfln("D          : %b", d)
    fmt.printfln("W          : %b", w)
    fmt.printfln("MOD        : %b", mod)
    fmt.printfln("REG        : %03b", reg)
    fmt.printfln("R/M        : %03b", rm)
}


