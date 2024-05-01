package tests

import "core:testing"
import "../decode"
import "core:fmt"

path := "./decode/listing_0037_single_register_mov"

@(test)
parse_instructions_from_binary :: proc (t: ^testing.T) {
    expected_opcode:u8 = 0b100010
    expected_d:u8 = 0b0
    expected_w:u8 = 0b1
    expected_mod:u8 = 0b11
    expected_reg:u8 = 0b011
    expected_rm:u8 = 0b001

    opcode, d, w, mod, reg, rm := decode.parse_instruction(path)

    testing.expect(t, expected_opcode == opcode)
    testing.expect(t, expected_d == d)
    testing.expect(t, expected_w == w)
    testing.expect(t, expected_mod == mod)
    testing.expect(t, expected_reg == reg)
    testing.expect(t, expected_rm == rm)
}

@(test)
decoding :: proc(t: ^testing.T) {
    expected_opcode_str := "mov"
    expected_reg_str := "bx"
    expected_rm_str := "cx"
    
    opcode, d, w, mod, reg, rm := decode.parse_instruction(path)
    opcode_str := decode.opcode(opcode)
    reg_str := decode.reg(reg)
    rm_str := decode.reg(rm)

    testing.expect(t, expected_opcode_str == opcode_str)
    testing.expect(t, expected_reg_str == reg_str)
    testing.expect(t, expected_rm_str == rm_str)
}
