`timescale 1ns/1ps
// Owner: Member 4. Control unit = main decoder + ALU decoder.
module control (
    input      [6:0] opcode,
    input      [2:0] funct3,
    input            funct7_5,
    output reg       reg_write,
    output reg       alu_src,
    output reg       mem_write,
    output reg       result_src,
    output reg       branch,
    output reg [1:0] imm_sel,
    output reg [2:0] alu_ctrl
);
    reg [1:0] alu_op;   // internal: main decoder -> ALU decoder
    localparam OP_R    = 7'b0110011;   // ADD, SUB, AND, OR, XOR
    localparam OP_ADDI = 7'b0010011;
    localparam OP_LW   = 7'b0000011;
    localparam OP_SW   = 7'b0100011;
    localparam OP_B    = 7'b1100011;   // BEQ, BNE

    // Main decoder: opcode -> datapath control signals.
    // Every output gets a default first, so no signal is ever left undefined
    // (and no latch is inferred). Each case only overrides what it needs.
    always @(*) begin
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        result_src = 1'b0;
        branch     = 1'b0;
        imm_sel    = 2'b00;
        alu_op     = 2'b00;
        case (opcode)
            OP_R:    begin reg_write = 1'b1;                                     alu_op = 2'b10; end
            OP_ADDI: begin reg_write = 1'b1; alu_src = 1'b1; imm_sel = 2'b00;   alu_op = 2'b11; end
            OP_LW:   begin reg_write = 1'b1; alu_src = 1'b1; result_src = 1'b1; imm_sel = 2'b00; end
            OP_SW:   begin alu_src = 1'b1; mem_write = 1'b1; imm_sel = 2'b01; end
            OP_B:    begin branch = 1'b1; imm_sel = 2'b10;                       alu_op = 2'b01; end
            default: ;   // unknown opcode: everything stays 0, nothing is written
        endcase
    end

    // TODO 2 (ALU decoder): case on alu_op:
    //   00 -> add | 01 -> sub | 11 -> add (ADDI)
    //   10 -> look at funct3 (and funct7_5 for ADD vs SUB)
    //   alu_ctrl codes: 000 add, 001 sub, 010 and, 011 or, 100 xor
endmodule
