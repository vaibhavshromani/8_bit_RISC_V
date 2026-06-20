`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 12:07:19
// Design Name: 
// Module Name: risc_top_pipelined
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
// risc_top_pipelined.v -- 2-stage pipelined RISC processor
//
// Stage 1 (IF/ID): Fetch instruction, decode it, read registers
// Stage 2 (EX/MEM/WB): ALU execute, memory access, write back
//
// A pipeline register sits between the two stages. Because two
// instructions are in flight at once, an instruction decoding in
// Stage 1 can need a register that the instruction ahead of it
// (currently finishing Stage 2 in the SAME cycle) is about to
// write. This ISA has no branches, so instead of stalling we
// forward the write-back value directly into Stage 1's reads.
// ============================================================
module risc_top_pipelined (
    input clk,
    input rst
);
    // ======================================================
    // STAGE 1: FETCH + DECODE
    // ======================================================
    wire [3:0]  pc;
    wire [15:0] instr;

    pc PC (
        .clk(clk), .rst(rst), .pc(pc)
    );

    instruction_memory IMEM (
        .pc(pc), .instr(instr)
    );

    wire [2:0] opcode = instr[15:13];
    wire [2:0] reg_a  = instr[12:10]; // rd (R-type/LOAD) or data-src reg (STORE)
    wire [2:0] reg_b  = instr[9:7];   // rs1 (R-type) or base addr reg (LOAD/STORE)
    wire [2:0] reg_c  = instr[6:4];   // rs2 (R-type only)
    wire [6:0] imm7   = instr[6:0];   // immediate (I-type only)

    wire is_store      = (opcode == 3'b101);
    wire [2:0] rs2_addr = is_store ? reg_a : reg_c;

    wire reg_write_d, mem_write_d, mem_read_d, alu_src_d, mem_to_reg_d;
    wire [1:0] alu_op_d;

    control_unit CU (
        .opcode(opcode),
        .reg_write(reg_write_d), .mem_write(mem_write_d), .mem_read(mem_read_d),
        .alu_src(alu_src_d), .mem_to_reg(mem_to_reg_d), .alu_op(alu_op_d)
    );

    // ---- write-back signals, driven by Stage 2 further below ----
    wire        wb_reg_write;
    wire [2:0]  wb_waddr;
    wire [7:0]  wb_wdata;

    wire [7:0] rf_rdata1, rf_rdata2;

    register_file RF (
        .clk(clk),
        .reg_write(wb_reg_write),   // the actual write happens in WB (Stage 2)
        .rs1(reg_b),
        .rs2(rs2_addr),
        .waddr(wb_waddr),
        .wdata(wb_wdata),
        .rdata1(rf_rdata1),
        .rdata2(rf_rdata2)
    );

    // ---- Forwarding: bypass register file with this cycle's WB value
    // if Stage 2 (the instruction one ahead) is about to write the
    // exact register Stage 1 is trying to read right now.
    wire fwd1 = (wb_reg_write && wb_waddr == reg_b && reg_b != 3'b000);
    wire fwd2 = (wb_reg_write && wb_waddr == rs2_addr && rs2_addr != 3'b000);

    wire [7:0] rdata1_fwd = fwd1 ? wb_wdata : rf_rdata1;
    wire [7:0] rdata2_fwd = fwd2 ? wb_wdata : rf_rdata2;

    wire [7:0] alu_b_d = alu_src_d ? {1'b0, imm7} : rdata2_fwd;

    // ======================================================
    // PIPELINE REGISTER: Stage 1 -> Stage 2
    // ======================================================
    reg        p_reg_write, p_mem_write, p_mem_to_reg;
    reg [1:0]  p_alu_op;
    reg [2:0]  p_waddr;
    reg [7:0]  p_alu_a, p_alu_b, p_mem_wdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // bubble: nothing valid is in Stage 2 right after reset
            p_reg_write  <= 1'b0;
            p_mem_write  <= 1'b0;
            p_mem_to_reg <= 1'b0;
            p_alu_op     <= 2'b00;
            p_waddr      <= 3'b000;
            p_alu_a      <= 8'b0;
            p_alu_b      <= 8'b0;
            p_mem_wdata  <= 8'b0;
        end else begin
            p_reg_write  <= reg_write_d;
            p_mem_write  <= mem_write_d;
            p_mem_to_reg <= mem_to_reg_d;
            p_alu_op     <= alu_op_d;
            p_waddr      <= reg_a;
            p_alu_a      <= rdata1_fwd;
            p_alu_b      <= alu_b_d;
            p_mem_wdata  <= rdata2_fwd;
        end
    end

    // ======================================================
    // STAGE 2: EXECUTE + MEMORY ACCESS + WRITE BACK
    // ======================================================
    wire [7:0] alu_result;
    wire alu_carry, alu_zero;

    alu ALU0 (
        .a(p_alu_a), .b(p_alu_b), .alu_op(p_alu_op),
        .result(alu_result), .carry_out(alu_carry), .zero(alu_zero)
    );

    wire [7:0] mem_rdata;

    data_memory DMEM (
        .clk(clk),
        .mem_write(p_mem_write),
        .addr(alu_result[4:0]),
        .wdata(p_mem_wdata),
        .rdata(mem_rdata)
    );

    assign wb_reg_write = p_reg_write;
    assign wb_waddr     = p_waddr;
    assign wb_wdata      = p_mem_to_reg ? mem_rdata : alu_result;

endmodule
