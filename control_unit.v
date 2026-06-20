`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 09:40:55
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input [2:0] opcode,
    output reg_write,
    output mem_write,
    output mem_read,
    output alu_src,
    output mem_to_reg,
    output [1:0] alu_op
    );
    localparam ADD    = 3'b000;
    localparam SUB    = 3'b001;
    localparam AND_OP = 3'b010;
    localparam OR_OP  = 3'b011;
    localparam LOAD   = 3'b100;
    localparam STORE  = 3'b101;
 
    reg rw, mw, mr, asrc, mtr;
    reg [1:0] aop;
 
    always @(*) begin
        // safe defaults (also covers unused/NOP opcodes)
        rw = 1'b0; mw = 1'b0; mr = 1'b0; asrc = 1'b0; mtr = 1'b0; aop = 2'b00;
 
        case (opcode)
            ADD:    begin rw = 1'b1; aop = 2'b00; end
            SUB:    begin rw = 1'b1; aop = 2'b01; end
            AND_OP: begin rw = 1'b1; aop = 2'b10; end
            OR_OP:  begin rw = 1'b1; aop = 2'b11; end
            LOAD:   begin rw = 1'b1; mr = 1'b1; asrc = 1'b1; mtr = 1'b1; aop = 2'b00; end
            STORE:  begin mw = 1'b1; asrc = 1'b1; aop = 2'b00; end
            default: ; // NOP - everything stays at safe defaults
        endcase
    end
 
    assign reg_write  = rw;
    assign mem_write  = mw;
    assign mem_read   = mr;
    assign alu_src    = asrc;
    assign mem_to_reg = mtr;
    assign alu_op     = aop;
endmodule
