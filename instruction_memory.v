`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:40:55
// Design Name: 
// Module Name: instruction_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// instr_memory.v -- Instruction ROM
// 16 locations x 16-bit instruction word, word-addressed by PC.
//
// Instruction formats (16 bits total):
//   R-type : [opcode 3][reg_a(rd) 3][reg_b(rs1) 3][reg_c(rs2) 3][unused 4]
//   I-type : [opcode 3][reg_a 3][reg_b(base) 3][imm 7]
//
// reg_a meaning depends on opcode:
//   ADD/SUB/AND/OR/LOAD -> destination register (rd)
//   STORE               -> source register holding the data to store
//
// Opcodes:
//   000 ADD   001 SUB   010 AND   011 OR   100 LOAD   101 STORE
// ============================================================
module instruction_memory (
    input  [3:0]  pc,
    output [15:0] instr
);
    reg [15:0] mem [0:15];
    integer k;

    initial begin
        for (k = 0; k < 16; k = k + 1)
            mem[k] = 16'b0;

        // Sample program (matches the project guide's test sequence):
        //   LOAD  R1, 0x10
        //   LOAD  R2, 0x11
        //   ADD   R3, R1, R2
        //   STORE R3, 0x12
        //   AND   R4, R1, R2

        // LOAD R1, 0x10  -> rd=R1, base=R0, imm=16
        mem[0] = {3'b100, 3'b001, 3'b000, 7'd16};

        // LOAD R2, 0x11  -> rd=R2, base=R0, imm=17
        mem[1] = {3'b100, 3'b010, 3'b000, 7'd17};

        // ADD R3, R1, R2
        mem[2] = {3'b000, 3'b011, 3'b001, 3'b010, 4'b0000};

        // STORE R3, 0x12 -> data-src=R3, base=R0, imm=18
        mem[3] = {3'b101, 3'b011, 3'b000, 7'd18};

        // AND R4, R1, R2
        mem[4] = {3'b010, 3'b100, 3'b001, 3'b010, 4'b0000};

        // mem[5] and beyond stay 0 (decodes as ADD R0,R0,R0 -> harmless NOP)
    end

    assign instr = mem[pc];

endmodule
