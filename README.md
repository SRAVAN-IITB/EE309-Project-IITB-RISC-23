# EE309 Course Project: IITB-RISC-23
This repository contains the implementation of the IITB-RISC-23, a 16-bit computer system developed as part of the **Microprocessors (EE309)** course at **IIT Bombay** (2024). The processor is described in **VHDL** and designed for FPGA implementation, optimized for performance with hazard mitigation techniques.

## Team

- [Sravan K Suresh](https://github.com/SRAVAN-IITB)  
- [Chinmay Moorjani](https://github.com/krimsonscorpio-manga)  
- [Nimay Upen Shah](https://github.com/nimayshah123)  
- [K Ashvanth](https://github.com/k-ashvanth)

[View Design Document](IITB_RISC_23_Report.pdf)

## Introduction

The IITB-RISC-23 architecture is a **16-bit, 8-register computer system** with a **6-stage pipeline**:  
1. Instruction Fetch (IF)  
2. Instruction Decode (ID)  
3. Register Read (RR)  
4. Execute (EX)  
5. Memory Access (MEM)  
6. Write Back (WB)  

It supports an **8-register file (R0 to R7)**, with register R0 reserved as the Program Counter (PC). The instruction set consists of **14 instructions** in three formats: **R-type, I-type, and J-type**. The design includes a condition code register with two flags:  
- **Carry flag (C)**  
- **Zero flag (Z)**  

## Key Features

- **Hazard Mitigation**: The processor implements **forwarding mechanisms** (R A Forwarding, R B Forwarding) to handle data hazards and optimize CPI towards 1.  
- **Branch Prediction & Stalling**: Wrong branch predictions and load dependencies are managed using control signals and stalling logic. For certain instructions like Load Multiple (LM) and Store Multiple (SM), an **8-cycle stall** is introduced to sequentially access all registers (R0 to R7).  
- **Valid Bit Resetting Logic**: Instructions can be disabled using **RF-Write** and **MemoryWrite** control signals.  
- **Synchronous Counter**: A **3-bit synchronous up counter** is used for multi-register operations (LM, SM), synchronized with the CPU clock.  

## Design Overview

The CPU design includes the following components:

- **Instruction Memory**: Stores machine instructions.
- **Data Memory**: Holds program data.
- **3 ALUs**: Two 2-input ALUs and one 3-input ALU for various arithmetic and logical operations.
- **5 Pipeline Registers**: Transfer data and control signals across pipeline stages.
- **26 MUXes**: Various multiplexers (2x1, 4x1, 8x1) for data selection.
- **Register File**: 8 registers of 16 bits each.
- **3-bit Synchronous Counter**: For multi-register operations.
- **D-Flip Flops**: Two D-FFs to store carry and zero flags.
- **Control Signal Generator**: Manages control signals for the pipeline stages.

## Component List

### Arithmetic Unit
- **`alu.vhdl`**: Supports ADD, SUB, MUL, AND, ORA, and IMP operations. Utilizes carry (C) and zero (Z) flags.

### Multiplexers
- **`Mux1_2_1.vhdl`**: 2-to-1 multiplexer.  
- **`Mux1_4_1.vhdl`**: 4-to-1 multiplexer.  
- **`Mux1_8_1.vhdl`**: 8-to-1 multiplexer.  

### Registers
- **`Register16BIT.vhdl`**: 16-bit register with synchronous write and asynchronous read.  
- **`Register_file.vhdl`**: A set of eight 16-bit registers.  

### Memory Unit
- **`Memory.vhdl`**: A memory array of 512 8-bit vectors for instruction and data storage.

### Main CPU Unit
- **`CPU.vhdl`**: Top-level CPU code implementing the complete design.
