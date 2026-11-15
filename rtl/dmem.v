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
    integer i;

    // Zero-initialize memory for simulation
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
    end

    // Synchronous write on rising clock edge when write enable (we) is asserted
    always @(posedge clk) begin
        if (we)
            mem[addr[7:2]] <= wd;
    end

    // Asynchronous / combinational read: data is available instantly
    assign rd = mem[addr[7:2]];

endmodule
