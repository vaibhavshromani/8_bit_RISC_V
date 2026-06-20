`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:40:55
// Design Name: 
// Module Name: register_file
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
// ============================================================
// register_file.v -- 8 x 8-bit general purpose registers
// R0 is hardwired to 0 (common RISC convention).
// Two combinational read ports, one synchronous write port.
// ============================================================
module register_file (
    input        clk,
    input        reg_write,
    input  [2:0] rs1,      // read address 1
    input  [2:0] rs2,      // read address 2
    input  [2:0] waddr,    // write address
    input  [7:0] wdata,    // write data
    output [7:0] rdata1,
    output [7:0] rdata2
);
    reg [7:0] regs [0:7];
    integer i;

    initial begin
        for (i = 0; i < 8; i = i + 1)
            regs[i] = 8'b0;
    end

    // R0 always reads as 0, even if something tries to write it
    assign rdata1 = (rs1 == 3'b000) ? 8'b0 : regs[rs1];
    assign rdata2 = (rs2 == 3'b000) ? 8'b0 : regs[rs2];

    always @(posedge clk) begin
        if (reg_write && waddr != 3'b000)
            regs[waddr] <= wdata;
    end

endmodule
