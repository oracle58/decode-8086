package main

import "core:fmt"
import "decode"

main :: proc() {
    single_path := "./decode/listing_0037_single_register_mov"
    many_path := "./decode/listing_0038_many_register_mov"

    data := decode.read_instructions(many_path)
    instructions := decode.format_instructions(data)
    fmt.printfln(instructions)
}
