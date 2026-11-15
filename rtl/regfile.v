`timescale 1ns/1ps
// Owner: Member 3. Register file: 32 registers x 32 bits.
// Interface is FIXED: do not rename or resize ports.
module regfile (
    input         clk,
    input         we,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);
    reg [31:0] regs [0:31];   // the 32 registers

    // TODO 1: start every register at 0 (simulation only)
    // TODO 2: on the rising clock edge, if we is 1, write wd into regs[rd]
    //         ... but NEVER write register 0
    // TODO 3: rd1 / rd2 read regs[rs1] / regs[rs2] at any time (no clock)
    //         ... and always give 0 when the register number is 0
endmodule
