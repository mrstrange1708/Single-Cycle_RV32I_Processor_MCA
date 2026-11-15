`timescale 1ns/1ps
// Owner: Member 3. Immediate generator.
// Interface is FIXED: do not rename or resize ports.
module immgen (
    input      [31:0] instr,
    input      [1:0]  imm_sel,     // 00 = I-type, 01 = S-type, 10 = B-type
    output reg [31:0] imm
);
    // TODO: in a combinational block, rebuild the 32-bit sign-extended constant.
    //   I-type: 12 bits at instr[31:20]
    //   S-type: instr[31:25] then instr[11:7]
    //   B-type: instr[31], instr[7], instr[30:25], instr[11:8], then a 0 at the end
    //   Sign-extend: fill the upper bits with copies of instr[31]
endmodule
