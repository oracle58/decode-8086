package main

import "core:fmt"
import "decode"

main :: proc() {
    exercise1 := "./samples/listing_0037_single_register_mov"
    exercise1_bonus := "./samples/listing_0038_many_register_mov"
    exercise2 := "./samples/listing_0039_more_movs"

    data := decode.read_instructions(exercise1_bonus)
    //instructions := decode.format_instructions(data)
    //fmt.printfln(instructions)
}
