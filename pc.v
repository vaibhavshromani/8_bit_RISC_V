`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    output reg [3:0] pc
);

always @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 4'd0;
    else if (pc < 4'd15)
        pc <= pc + 1'b1;
    else
        pc <= 4'd15;
end

endmodule