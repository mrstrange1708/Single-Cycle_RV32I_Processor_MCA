`timescale 1ns/1ps
// Owner: Member 1. Top level: connects every block into the datapath.
module cpu (
    input clk,
    input reset
);
    // All the wires that run between blocks (names match the datapath diagram)
    wire [31:0] pc_cur, pc_next, pc_plus4, pc_branch;
    wire [31:0] instr, rd1, rd2, imm, alu_b, alu_result, mem_rdata, result;
    wire        reg_write, alu_src, mem_write, result_src, branch, zero, pc_src;
    wire [1:0]  imm_sel;
    wire [2:0]  alu_ctrl;

    // ---- Next-PC logic ----
    // TODO: pc_plus4  = current PC + 4
    // TODO: pc_branch = current PC + imm
    // TODO: pc_src    = 1 when this is a branch AND the condition holds
    //        (BEQ: zero is 1.  BNE: zero is 0.  instr[12] tells them apart)
    // TODO: pc_next   = pc_branch if pc_src else pc_plus4

    // ---- Blocks ----
    pc u_pc (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc_cur));   // done as an example
    // TODO: imem    u_im  -> addr from pc_cur, gives instr
    // TODO: control u_cu  -> opcode = instr[6:0], funct3 = instr[14:12], funct7_5 = instr[30]
    // TODO: regfile u_rf  -> rs1 = instr[19:15], rs2 = instr[24:20], rd = instr[11:7], wd = result
    // TODO: immgen  u_ig  -> from instr and imm_sel
    // TODO: alu_b mux     -> imm when alu_src is 1, otherwise rd2
    // TODO: alu     u_alu -> a = rd1, b = alu_b
    // TODO: dmem    u_dm  -> addr = alu_result, write data = rd2, we = mem_write
    // TODO: result mux    -> mem_rdata when result_src is 1, otherwise alu_result
endmodule
