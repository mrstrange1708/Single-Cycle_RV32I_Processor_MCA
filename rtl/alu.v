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
    // Arithmetic wraps to 32 bits, including two's-complement subtraction.
    always @(*) begin
        case (alu_ctrl)
            3'b000: result = a + b;
            3'b001: result = a - b;
            // TODO: add the three bitwise operations.
            default: result = 32'b0;
        endcase
    end
    // TODO: assert zero exactly when result is zero.
endmodule
