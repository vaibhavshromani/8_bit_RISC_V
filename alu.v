// ============================================================
// alu.v -- 8-bit ALU used inside the RISC processor datapath
// Reuses the same combinational-logic principles as the ALU
// minor project, trimmed to the 4 ops the ISA needs.
// ============================================================
`timescale 1ns/1ps

module alu (
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] alu_op,     // 00=ADD, 01=SUB, 10=AND, 11=OR
    output [7:0] result,
    output       carry_out,
    output       zero
);
    reg [8:0] temp; // 9 bits to catch carry-out

    always @(*) begin
        case (alu_op)
            2'b00: temp = a + b;            // ADD
            2'b01: temp = a - b;            // SUB
            2'b10: temp = {1'b0, a & b};    // AND
            2'b11: temp = {1'b0, a | b};    // OR
            default: temp = 9'b0;
        endcase
    end

    assign result    = temp[7:0];
    assign carry_out = temp[8];
    assign zero      = (temp[7:0] == 8'b0);

endmodule