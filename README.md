# elficpu2
This is simple 8-bit CPU written in VHDL.

# Features
- 8-bit CPU
- Up to 65536 bytes of instruction memory
- Up to 65536 bytes of data memory
- Up to 65536 I/O ports
- Two general purpose registers R0 and R1
- One 32-bit counter register CNT
- One 16-bit STACK register

# Reset behaviour
All registers are set to 0.

# Instructions
- nop. No operation :)
- R0 = const. Load register R0 with a 8-bit constant data. Opcode: 1h X.
- R1 = const. Load register R1 with a 8-bit constant data. Opcode: 2h X.
- halt. Halts CPU. Opcode: FFh.
- portaddr = R0. Write register R0 to port. Opcode: 3h, XX, YY.
- portaddr = R1. Write register R1 to port. Opcode: 3h, XX, YY.
- CNT = const. Load register CNT with a 32-bit constant value. Opcode: 5h, AA, BB, CC, DD
- --CNT. Decrement CNT register. Opcode: 6h.
- jumpnz(addr). Jump on CNT register is not zero. Opcode: 7h, A, B, C, D.
- jump(addr). Jump to address. Opcode: 7h, A, B, C, D.
