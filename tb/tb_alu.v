`timescale 1ns/1ps
// Owner: Member 2. Self-checking ALU unit testbench.
module tb_alu;
    reg  [31:0] a, b;
    reg  [2:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    alu dut (.a(a), .b(b), .alu_ctrl(alu_ctrl), .result(result), .zero(zero));

    // TODO: apply independently calculated vectors and check result and zero.
    // TODO: dump alu.vcd and finish with a nonzero exit status on failure.
endmodule
