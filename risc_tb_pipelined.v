`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 11:54:11
// Design Name: 
// Module Name: risc_tb_pipelined
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
// risc_tb_pipelined.v -- Testbench for the 2-stage pipeline version
// Same sample program as the single-cycle design, used to prove
// the pipeline + forwarding produces IDENTICAL results.
// ============================================================
`timescale 1ns/1ps

module risc_tb_pipelined;
    reg clk;
    reg rst;

    risc_top_pipelined UUT (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #12 rst = 0;

        // 5 instructions + 1 cycle pipeline fill + margin
        #100;

        $display("");
        $display("==================================================");
        $display("FINAL REGISTER FILE CONTENTS (pipelined)");
        $display("==================================================");
        $display("R1 = %0d  (expected 5)",  UUT.RF.regs[1]);
        $display("R2 = %0d  (expected 10)", UUT.RF.regs[2]);
        $display("R3 = %0d  (expected 15, R1+R2 -- needed forwarding!)", UUT.RF.regs[3]);
        $display("R4 = %0d  (expected 0,  R1 AND R2)", UUT.RF.regs[4]);

        $display("");
        $display("Mem[0x12] = %0d  (expected 15, STORE -- also needed forwarding!)",
                   UUT.DMEM.mem[18]);

        $display("");
        if (UUT.RF.regs[1]===5 && UUT.RF.regs[2]===10 && UUT.RF.regs[3]===15 &&
            UUT.RF.regs[4]===0 && UUT.DMEM.mem[18]===15)
            $display(">>> PIPELINED TEST PASSED: forwarding resolved both hazards correctly");
        else
            $display(">>> PIPELINED TEST FAILED: check forwarding logic");

        $finish;
    end

    initial begin
          $monitor("t=%0t | pc=%0d",
          $time, UUT.pc); 
    end

    initial begin
        $dumpfile("risc_pipelined_waveform.vcd");
        $dumpvars(0, risc_tb_pipelined);
    end

endmodule
