`timescale 1ns/1ps
// Owner: Member 1. Program Counter: holds the address of the current instruction.
// Interface is FIXED: do not rename or resize ports.
module pc (
    input             clk,
    input             reset,
    input      [31:0] pc_next,
    output reg [31:0] pc
);
    // Sequential block: pc only changes on the rising clock edge.
    // reset has priority so the CPU always starts at address 0.
    always @(posedge clk) begin
        if (reset) pc <= 32'b0;
        else       pc <= pc_next;
    end
endmodule
