`timescale 1ns/1ps
// Owner: Member 3. Immediate generator.
// Rebuilds the sign-extended 32-bit constant hidden inside I, S and B instructions.
// Interface is FIXED: do not rename or resize ports.
module immgen (
    input      [31:0] instr,
    input      [1:0]  imm_sel,     // 00 = I-type, 01 = S-type, 10 = B-type
    output reg [31:0] imm
);
    // instr[31] is the sign bit in every format; copying it into the upper
    // bits keeps negative constants negative (e.g. a backward branch of -8).
    always @(*) begin
        case (imm_sel)
            2'b00:   imm = {{20{instr[31]}}, instr[31:20]};                                     // I-type: ADDI, LW
            2'b01:   imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};                        // S-type: SW
            2'b10:   imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type: BEQ, BNE (bit 0 is always 0)
            default: imm = 32'b0;
        endcase
    end
endmodule
