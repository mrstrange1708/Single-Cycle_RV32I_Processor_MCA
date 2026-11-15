`timescale 1ns/1ps
// Owner: Member 5 (Balanagu Srikar). Data memory.
// Interface is FIXED: do not rename or resize ports.
module dmem (
    input         clk,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd
);
    reg [31:0] mem [0:63];  // 64 words = 256 bytes

    // TODO 1: start all words at 0
    // TODO 2: on the rising clock edge, if we is 1, store wd at word addr / 4
    // TODO 3: rd always shows the word at addr / 4 (no clock)
endmodule
