package main
import "core:fmt"
import "decode"

INSTRUCTION_SIZE :: 16

path := "./decode/listing_0037_single_register_mov"

main :: proc() {

    opcode, d, w, mod, reg, rm := decode.parse_instruction(path)
    opcode_str := decode.opcode(opcode)
    source := decode.reg(reg, w)
    dest := decode.reg(rm, w)
    fmt.printfln("bits %d \n", INSTRUCTION_SIZE)
    fmt.printfln("%s %s, %s", opcode_str, dest, source)
}
