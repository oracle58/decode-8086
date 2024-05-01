package tests

import "core:testing"
import "../decode"
import "core:fmt"

@(test)
parse_instructions_from_binary :: proc (t: ^testing.T) {
    path := "./decode/listing_0037_single_register_mov"
    data := decode.read_instructions(path)

    expected_opcode:u8 = 0b100010
    expected_d:u8 = 0b0
    expected_w:u8 = 0b1
    expected_mod:u8 = 0b11
    expected_reg:u8 = 0b011
    expected_rm:u8 = 0b001

    opcode, d, w, mod, reg, rm := decode.parse_instruction(data, 0)

    testing.expect_value(t, opcode, expected_opcode)
    testing.expect_value(t, d, expected_d)
    testing.expect_value(t, w, expected_w)
    testing.expect_value(t, mod, expected_mod)
    testing.expect_value(t, reg, expected_reg)
    testing.expect_value(t, rm, expected_rm)
}

@(test)
decoding :: proc(t: ^testing.T) {
    path := "./decode/listing_0037_single_register_mov"
    data := decode.read_instructions(path)

    expected_opcode_str := "mov"
    expected_reg_str := "bx"
    expected_rm_str := "cx"
    
    opcode, d, w, mod, reg, rm := decode.parse_instruction(data, 0)
    opcode_str := decode.opcode_to_string(opcode)
    reg_str := decode.reg_to_string(reg, w)
    rm_str := decode.reg_to_string(rm, w)

    testing.expect_value(t, opcode_str, expected_opcode_str)
    testing.expect_value(t, reg_str, expected_reg_str)
    testing.expect_value(t, rm_str, expected_rm_str)
}

@(test)
disassemble_single :: proc(t: ^testing.T) {
    path := "./decode/listing_0037_single_register_mov"
    data := decode.read_instructions(path)

    expected_asm := "bits 16\n\nmov cx, bx\n"
    result_asm := decode.format_instructions(data)
    testing.expect_value(t, result_asm, expected_asm)
}

@(test)
disassemble_many :: proc(t: ^testing.T) {
    many_path := "./decode/listing_0038_many_register_mov"
    data := decode.read_instructions(many_path)

    expected_asm := "bits 16\n\n" +
                    "mov cx, bx\n" +
                    "mov ch, ah\n" +
                    "mov dx, bx\n" +
                    "mov si, bx\n" +
                    "mov bx, di\n" +
                    "mov al, cl\n" +
                    "mov ch, ch\n" +
                    "mov bx, ax\n" +
                    "mov bx, si\n" +
                    "mov sp, di\n" +
                    "mov bp, ax\n"
    
    result_asm := decode.format_instructions(data)
    testing.expect_value(t, result_asm, expected_asm)
}