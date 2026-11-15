`timescale 1ns/1ps
// Owner: Member 1. Program Counter.
// Interface is FIXED: do not rename or resize ports.
module pc (
    input             clk,
    input             reset,
    input      [31:0] pc_next,
    output reg [31:0] pc
);
    // TODO: on every rising clock edge:
    //   if reset is 1 -> pc becomes 0
    //   otherwise     -> pc becomes pc_next
    // Hint: this is a clocked block, so use non-blocking assignment.
endmodule
