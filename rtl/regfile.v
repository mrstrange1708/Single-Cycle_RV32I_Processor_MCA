`timescale 1ns/1ps
// Owner: Member 3. Register file: 32 registers x 32 bits.
// Two reads (any time, no clock), one write (on the rising clock edge).
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
    integer i;

    // Start every register at 0 (simulation only)
    initial for (i = 0; i < 32; i = i + 1) regs[i] = 32'b0;

    // Write on the rising clock edge; register 0 is never written
    always @(posedge clk) begin
        if (we && rd != 5'd0) regs[rd] <= wd;
    end

    // Reads are combinational; register 0 always reads 0
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
endmodule
