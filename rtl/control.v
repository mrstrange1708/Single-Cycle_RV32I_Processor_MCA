`timescale 1ns/1ps
// Owner: Member 4. Control unit = main decoder + ALU decoder.
module control (
    input      [6:0] opcode,
    input      [2:0] funct3,
    input            funct7_5,
    output reg       reg_write,
    output reg       alu_src,
    output reg       mem_write,
    output reg       result_src,
    output reg       branch,
    output reg [1:0] imm_sel,
    output reg [2:0] alu_ctrl
);
    reg [1:0] alu_op;   // internal: main decoder -> ALU decoder
    // TODO 1 (main decoder): set all outputs to 0 first, then case on opcode:
    //   0110011 R-type | 0010011 ADDI | 0000011 LW | 0100011 SW | 1100011 BEQ/BNE
    //   Fill each row from the control truth table in docs/control_table.md.
    // TODO 2 (ALU decoder): case on alu_op:
    //   00 -> add | 01 -> sub | 11 -> add (ADDI)
    //   10 -> look at funct3 (and funct7_5 for ADD vs SUB)
    //   alu_ctrl codes: 000 add, 001 sub, 010 and, 011 or, 100 xor
endmodule
