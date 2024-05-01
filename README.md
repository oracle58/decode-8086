# computer-enhance

# Exericise I: Decoding the 8086

INDEX    | 7 6 5 4 3 2  |  1 0  | 7 6   |  543   |  210  |
-------- |--------------|-------|-------|--------|-------|
INSTR    |   opcode     |  d w  | mod   |  reg   |  r/m  |
EXMPL    | 1 0 0 0 1 0  |  0 1  | 1 1   |  011   |  001  |
ASM      |     `MOV`    |   *   |  **   |  `BX`  |  `CX` |

**\*** Depending on the order of operands in `mov`, `d` will be set to 0 or 1 indicating the direction of the data to be copied, e.g from CX to BX or vice versa. It sets whether `reg` or `r/m` is to be considered the destination.
e.g. `mov cx, bx`:  `cx` = dest -> d=0 because CX sits in the r/m field.

**\*\*** Alternator for `r/m`. depending on mod the last 3 bits can hold an encoded reference to a register or memory addr

- `opcode`: e.g. Mov=100010
- `mod`(rm switch): alternates between `r` (register) and `m`(memory) in the last byte. 
mod = 11 -> reg to reg
- `d` (destination): 
    - d=0 -> `reg`=source and `r/m`=dest
    - d=1 -> `reg`=dest and `r/m`=source
- `w` (wide): w=0 -> 8 bits, w=1 -> 16 bits
- `reg`: encoded register, e.g. `BX`
- `r/m`: encoded register or memory address. `r` is selected if mod=11 

## Creating binaries
1. `nasm listing_0037_single_register_mov.asm`
2. `nasm listing_0038_many_register_mov.asm`
## Assembly on Win
1. `nasm -f win64 listing_0037_single_register_mov.asm -o sr_mov.o`
2. `ld -e sr_mov.o /fo srmov.exe`