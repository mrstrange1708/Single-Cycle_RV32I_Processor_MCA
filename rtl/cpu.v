`timescale 1ns/1ps
// Owner: Member 1. Top level: connects every block into the datapath.
// Phase II: three debug outputs added so synthesis has something observable
// to keep. Testbenches connect ports by name, so they need no change.
module cpu (
    input         clk,
    input         reset,
    output [31:0] dbg_pc,          // current PC
    output [31:0] dbg_result,      // value being written back
    output        dbg_reg_write    // 1 when a register is written this cycle
);
    // All the wires that run between blocks (names match the datapath diagram)
    wire [31:0] pc_cur, pc_next, pc_plus4, pc_branch;
    wire [31:0] instr, rd1, rd2, imm, alu_b, alu_result, mem_rdata, result;
    wire        reg_write, alu_src, mem_write, result_src, branch, zero, pc_src;
    wire [1:0]  imm_sel;
    wire [2:0]  alu_ctrl;

    // ---- Next-PC logic ----
    // Two separate adders: the ALU is busy comparing rs1 - rs2 during a branch,
    // so the branch target needs its own adder.
    assign pc_plus4  = pc_cur + 32'd4;
    assign pc_branch = pc_cur + imm;
    // instr[12] is funct3[0]: 0 = BEQ (branch when zero), 1 = BNE (branch when not zero)
    assign pc_src    = branch & (instr[12] ? ~zero : zero);
    assign pc_next   = pc_src ? pc_branch : pc_plus4;

    // ---- Blocks (all ports connected by name, never by position) ----
    // Fetch
    pc      u_pc  (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc_cur));
    imem    u_im  (.addr(pc_cur), .instr(instr));

    // Decode: control signals + register reads + immediate
    control u_cu  (.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]),
                   .reg_write(reg_write), .alu_src(alu_src), .mem_write(mem_write),
                   .result_src(result_src), .branch(branch), .imm_sel(imm_sel), .alu_ctrl(alu_ctrl));
    regfile u_rf  (.clk(clk), .we(reg_write), .rs1(instr[19:15]), .rs2(instr[24:20]),
                   .rd(instr[11:7]), .wd(result), .rd1(rd1), .rd2(rd2));
    immgen  u_ig  (.instr(instr), .imm_sel(imm_sel), .imm(imm));

    // Execute: ALUSrc mux picks rs2 (R-type, branches) or the immediate (ADDI, LW, SW)
    assign alu_b = alu_src ? imm : rd2;
    alu     u_alu (.a(rd1), .b(alu_b), .alu_ctrl(alu_ctrl), .result(alu_result), .zero(zero));

    // Memory: address from the ALU, store data from rs2
    dmem    u_dm  (.clk(clk), .we(mem_write), .addr(alu_result), .wd(rd2), .rd(mem_rdata));

    // Write back: ResultSrc mux picks memory data (LW) or the ALU result
    assign result = result_src ? mem_rdata : alu_result;

    // ---- Debug outputs ----
    // Synthesis deletes any logic whose value never reaches an output pin.
    // Without these, synthesis would optimise the whole CPU away.
    assign dbg_pc        = pc_cur;
    assign dbg_result    = result;
    assign dbg_reg_write = reg_write;
endmodule
