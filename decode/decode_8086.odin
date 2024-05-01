package decode

import "core:fmt"
import "core:os"
import "core:strings"

BITS_PER_BYTE :: 8

run :: proc() {
    path := "decode/listing_0037_single_register_mov"
    data := read_bytes(path)
    bit_str := convert_to_bit_str(data)
    fmt.printfln("%s", bit_str)
}

read_bytes :: proc(path: string) -> []u8 {
    f, open_err := os.open(path, os.O_RDONLY, 0)
    defer os.close(f)
    if open_err != os.ERROR_NONE {
        fmt.println("Error opening file: ", open_err)
        return nil
    }
    buffer := make([]u8, 256) // Adjust buffer size as needed
    bytes, read_err := os.read(f, buffer)
    if read_err != os.ERROR_NONE {
        fmt.println("Error reading file: ", read_err)
        return nil
    }
    return buffer[:bytes] // Trim the buffer to the actual bytes read
}

convert_to_bit_str :: proc(values: []u8) -> string {
    str := ""
    defer delete(str);

    for value in values {
        for i := BITS_PER_BYTE - 1; i >= 0; i -= 1 { 
            if (value & (1 << u8(i))) != 0 {
                str = strings.concatenate({str, "1"})
            } else {
                str = strings.concatenate({str, "0"})
            }
        }
    }
    return string(str)
}
