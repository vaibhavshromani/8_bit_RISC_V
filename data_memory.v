`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:40:55
// Design Name: 
// Module Name: data_memory
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
// 
//////////////////////////////////////////////////////////////////////////////////
 // ============================================================
// data_memory.v -- 32 x 8-bit data RAM
// Combinational read, synchronous write (typical single-cycle style)
// Preloaded with sample data at 0x10 and 0x11 so LOAD has something
// real to fetch, per the project guide's sample test vectors.
// ============================================================
module data_memory (
    input        clk,
    input        mem_write,
    input  [4:0] addr,
    input  [7:0] wdata,
    output [7:0] rdata
);
    reg [7:0] mem [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            mem[i] = 8'b0;
        mem[16] = 8'd5;    // address 0x10
        mem[17] = 8'd10;   // address 0x11
    end

    assign rdata = mem[addr];

    always @(posedge clk) begin
        if (mem_write)
            mem[addr] <= wdata;
    end

endmodule