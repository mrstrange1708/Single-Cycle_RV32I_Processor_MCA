`timescale 1ns/1ps
// Owner: Member 2. Combinational 32-bit ALU.
// Interface and operation codes are shared with cpu.v and control.v.
module alu (
    input      [31:0] a,
    input      [31:0] b,
    input      [2:0]  alu_ctrl,
    output reg [31:0] result,
    output           zero
);
    // TODO: ADD, SUB, AND, OR, XOR; unused control codes return zero.
    // TODO: assert zero exactly when result is zero.
endmodule
