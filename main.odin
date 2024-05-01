package main
import "core:fmt"

main :: proc() {
    // x initially with some value, let's say binary 0000 0100 (4 in decimal)
    x := 4;
    fmt.printf("Initial x: %08b\n", x);

    // Setting the second bit (0-indexed)
    x |= 1 << 2;
    fmt.printf("After setting 2nd bit: %08b\n", x);

    // Clearing the second bit
    x &= (1 << 2);
    fmt.printf("After clearing 2nd bit: %08b\n", x);

    // Toggling the second bit
    x = 1 << 2;
    fmt.printf("After toggling 2nd bit: %08b\n", x);
}
