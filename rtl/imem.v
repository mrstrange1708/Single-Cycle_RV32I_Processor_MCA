`timescale 1ns/1ps
// Owner: Member 5 (Balanagu Srikar). Instruction memory (read-only).
// Interface is FIXED: do not rename or resize ports.
module imem (
    input  [31:0] addr,     // byte address from the PC
    output [31:0] instr
);
    reg [31:0] mem [0:63];  // 64 words = 64 instructions (256 bytes)

    // Load hex machine code into instruction memory at start of simulation
    initial begin
        $readmemh("program.hex", mem);
    end

    // Instruction memory is addressed by byte address from PC.
    // In RV32I, instructions are 32-bit (4 bytes) and word-aligned.
    // Dividing byte address by 4 gives the word index: addr[7:2].
    assign instr = mem[addr[7:2]];

endmodule
