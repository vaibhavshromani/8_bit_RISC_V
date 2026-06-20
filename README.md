# 8-Bit RISC Processor with 2-Stage Pipeline (Verilog HDL)

## Overview

This project implements an **8-bit RISC Processor** in **Verilog HDL** using a custom Instruction Set Architecture (ISA).

The processor was designed, simulated, and synthesized using **Xilinx Vivado**.

The design includes:

* Program Counter (PC)
* Instruction Memory
* Control Unit
* Register File
* Arithmetic Logic Unit (ALU)
* Data Memory
* Write-Back Logic
* 2-Stage Pipeline Architecture
* Data Forwarding Unit

The processor executes arithmetic, logical, memory load, and memory store instructions while demonstrating basic pipelining concepts used in modern CPUs.

---

# Processor Specifications

| Parameter          | Value               |
| ------------------ | ------------------- |
| Architecture       | Custom RISC         |
| Data Width         | 8-bit               |
| Instruction Width  | 16-bit              |
| Registers          | 8 Registers (R0-R7) |
| Register Width     | 8-bit               |
| Instruction Memory | 16 × 16-bit         |
| Data Memory        | 32 × 8-bit          |
| Pipeline           | 2-Stage             |
| Clocking           | Single Clock        |
| HDL                | Verilog             |
| Tool Used          | Xilinx Vivado       |
---
# Architecture
<img width="1354" height="475" alt="Screenshot 2026-06-20 132737" src="https://github.com/user-attachments/assets/feafc497-2682-49fc-8527-0d03b37f1c04" />
---
# Instruction Set Architecture (ISA)
## Instruction Format
### R-Type
| 15:13  | 12:10 | 9:7 | 6:4 | 3:0    |
| ------ | ----- | --- | --- | ------ |
| Opcode | Rd    | Rs1 | Rs2 | Unused |
Example:
```
ADD R3, R1, R2
```
---
### I-Type

| 15:13  | 12:10   | 9:7 | 6:0       |
| ------ | ------- | --- | --------- |
| Opcode | Rd/Rsrc | Rs  | Immediate |

Examples:

```
LOAD R1, 0x10
STORE R3, 0x12
```
---
# Opcode Table
| Instruction | Opcode |
| ----------- | ------ |
| ADD         | 000    |
| SUB         | 001    |
| AND         | 010    |
| OR          | 011    |
| LOAD        | 100    |
| STORE       | 101    |
---
# Register File
* 8 General Purpose Registers
* R0 permanently tied to zero
* Two Read Ports
* One Write Port
* Synchronous Write
* Combinational Read
---
# Pipeline Architecture
A basic **2-stage pipeline** is implemented.
## Stage 1
Instruction Fetch (IF)
* Program Counter Update
* Instruction Fetch from Instruction Memory
## Stage 2
Instruction Decode + Execute + Memory + Write Back
* Control Signal Generation
* Register Read
* ALU Operation
* Memory Access
* Register Write Back
---
# Forwarding Unit
To avoid data hazards:
```
LOAD R1, 0x10
LOAD R2, 0x11
ADD R3, R1, R2
```
The processor includes simple forwarding logic that forwards results from the Write-Back stage directly to ALU inputs when required.
Benefits:
* Eliminates unnecessary stalls
* Improves performance
* Demonstrates basic pipeline hazard handling
---
# Sample Test Program
```
LOAD  R1, 0x10
LOAD  R2, 0x11
ADD   R3, R1, R2
STORE R3, 0x12
AND   R4, R1, R2
```
---
# Expected Results
| Register | Value |
| -------- | ----- |
| R1       | 5     |
| R2       | 10    |
| R3       | 15    |
| R4       | 0     |

Memory:

```
Mem[0x12] = 15
```

---

# Simulation Results

The design was verified through behavioral simulation.

Observed:

* Correct Program Counter progression
  <img width="1363" height="713" alt="program counter" src="https://github.com/user-attachments/assets/a5078b01-dbdd-46c4-843c-42ce576ea8d6" />

* Correct instruction decoding
 <img width="1364" height="695" alt="instruction_fetch" src="https://github.com/user-attachments/assets/fbeccaa8-fdac-49ce-8cde-22f0aa56b3e3" />

* Successful ALU operations
  <img width="1365" height="695" alt="alu signals" src="https://github.com/user-attachments/assets/9ece97d0-bb23-41ee-9c03-2c3f64c6d32e" />

* Successful memory read/write
 <img width="1365" height="658" alt="data memory signal" src="https://github.com/user-attachments/assets/f55d72a6-063f-490a-8bae-d58a13d0bb1b" />

* Proper pipeline execution
* <img width="1364" height="695" alt="instruction_fetch" src="https://github.com/user-attachments/assets/d4963514-4d19-4ce8-8b7f-56a13fe50922" />

* Correct forwarding behavior
* <img width="1359" height="698" alt="overall_risc_signal" src="https://github.com/user-attachments/assets/62484a65-e9a5-42a4-a119-8d6c289fdd48" />

* Expected register values obtained
  <img width="1355" height="690" alt="register file signal" src="https://github.com/user-attachments/assets/9ef44c23-4b04-45fd-9349-b263a6ffa3ed" />


Final Verification:
<img width="1225" height="394" alt="test passed" src="https://github.com/user-attachments/assets/9d713714-c23b-4df0-b06c-1d8453a94874" />

---

# Control Signal Truth Table

| Instruction | RegWrite | MemWrite | MemRead | ALUSrc | MemToReg | ALUOp |
| ----------- | -------- | -------- | ------- | ------ | -------- | ----- |
| ADD         | 1        | 0        | 0       | 0      | 0        | 00    |
| SUB         | 1        | 0        | 0       | 0      | 0        | 01    |
| AND         | 1        | 0        | 0       | 0      | 0        | 10    |
| OR          | 1        | 0        | 0       | 0      | 0        | 11    |
| LOAD        | 1        | 0        | 1       | 1      | 1        | 00    |
| STORE       | 0        | 1        | 0       | 1      | 0        | 00    |

---

# Project Structure

```
RISC_V_PROCESSOR/
│
├── alu.v
├── control_unit.v
├── data_memory.v
├── instruction_memory.v
├── register_file.v
├── pc.v
├── risc_top_pipelined.v
│
├── risc_tb_pipelined.v
│
├── ISA_Document.md
├── control_truth_table.md
├── README.md
└──DEVICE
└── simulations/
    ├── alu.png
    ├── control unit.png
    ├── data memory signal.png
    ├── instruction fetch.png
    ├── overall_risc_signal.png
    ├── register file signal.png
    ├── test passed.png
    └── synthesis_report.png
```
---
# Results
The processor successfully:
* Executes arithmetic instructions
* Executes logical instructions
* Supports memory access operations
* Implements a working 2-stage pipeline
* Resolves data hazards using forwarding
* Produces correct simulation outputs
--
# Future Enhancements
* 5-Stage Pipeline
* Branch Instructions
* Jump Instructions
* Hazard Detection Unit
* Cache Memory
* RISC-V Compatible ISA
* 32-bit Architecture
* FPGA Implementation on Artix UltraScale+
---
# Author
vaibhav shromani
