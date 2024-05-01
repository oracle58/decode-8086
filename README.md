# computer-enhance

# Exericise I: Decoding the 8086

INDEX    | 7 6 5 4 3 2  |  1 0  | 7 6  |  5 4 3 | 2 1 0 |
-------- |--------------|-------|------|--------|-------|
INSTR    |   opcode     |  d w  |  mod |  reg   |  r/m  |
EXMPL    | 1 0 0 0 1 0  |  1 0  | 1 1  |        |       |


- `opcode`: e.g. Mov=100010
- `mod`(rm switch): alternates between `r` (register) and `m`(memory) in the last byte. 
mod = 11 -> reg to reg
- `d` (destination): d = 0 -> reg=source, d=1 -> reg=destination
- `w` (wide): w=0 -> 8 bits, w=1 -> 16 bits
- `reg`: encoded register, e.g. `AX`
- `r/m`: encoded register or memory address. `r` is selected if mod=11 