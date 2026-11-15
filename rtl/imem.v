`timescale 1ns/1ps
// Owner: Member 5 (Balanagu Srikar). Instruction memory (read-only).
// Interface is FIXED: do not rename or resize ports.
module imem (
    input  [31:0] addr,     // byte address from the PC
    output [31:0] instr
);
    reg [31:0] mem [0:63];  // 64 words = 64 instructions (256 bytes)

    // TODO 1: load "program.hex" into mem at the start of simulation
    // TODO 2: instr = the word at addr / 4 (drop the lowest 2 bits)
endmodule
