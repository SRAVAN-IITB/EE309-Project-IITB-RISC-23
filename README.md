# EE224 Course Project: IITB-CPU
A 16-bit multi-cycle CPU described in VHDL and to be implemented on an FPGA.

This project is part of the course Digital Systems (EE224), at IIT Bombay (2023)

### Team
* [Sravan K Suresh](https://github.com/SRAVAN-IITB)
* [Chinmay Moorjani](https://github.com/krimsonscorpio-manga)
* [Anshu Arora](https://github.com/AroraAnshu26)
* [Sachi Deshmukh](https://github.com/Sachi-Deshmukh)

[Design Document](/Design_IITB_CPU.pdf)

## Component List

### ARITHEMATIC UNIT
1. `alu.vhdl`: Capable of performing ADD, SUB, MUL, AND, ORA and IMP and uses registers(C,Z flags)

### MULTIPLEXERS
#### 1-bit Devices
1. `Mux1_2_1.vhdl`: 2-to-1 MUX
2. `Mux1_4_1.vhdl`: 4-to-1 MUX
3. `Mux1_8_1.vhdl`: 8-to-1 MUX

### DEMULTIPLEXERS
#### 1-bit Devices
1. `Mux1_8_1.vhdl`: 8-to-1 MUX


### REGISTERS
1. `Register16BIT.vhdl`: 16-bit register with synchronous write and asynchonous read
2. `Register_file.vhdl`: Set of 8 16-bit registers

### MEMORY UNIT
1. `Memory.vhdl`: Array of 512 8-bit vectors

### DUT
`DUT_ALU.vhdl`: Top-Level entity for `ALU.vhdl`
`DUT_Reg16BIT.vhdl`: Top-Level entity for `Reg16BIT.vhdl`

### MAIN CPU UNIT
`CPU.vhdl`: Main code
