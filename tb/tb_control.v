`timescale 1ns/1ps
// Owner: Member 4. Self-checking control unit testbench.
// Feeds real 32-bit instructions (as cpu.v does: opcode = instr[6:0],
// funct3 = instr[14:12], funct7_5 = instr[30]) and compares every output
// against docs/control_table.md. Don't-cares (x in the table) are driven 0.
module tb_control;
    reg  [31:0] instr;
    wire        reg_write, alu_src, mem_write, result_src, branch;
    wire [1:0]  imm_sel;
    wire [2:0]  alu_ctrl;
    integer errors = 0;
    integer tests  = 0;

    control dut (.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]),
                 .reg_write(reg_write), .alu_src(alu_src), .mem_write(mem_write),
                 .result_src(result_src), .branch(branch), .imm_sel(imm_sel), .alu_ctrl(alu_ctrl));

    // Expected outputs packed in table order:
    // {reg_write, alu_src, mem_write, result_src, branch, imm_sel[1:0], alu_ctrl[2:0]}
    task check(input [8*12-1:0] name, input [31:0] word, input [9:0] expected);
        begin
            instr = word;
            #10;
            tests = tests + 1;
            if ({reg_write, alu_src, mem_write, result_src, branch, imm_sel, alu_ctrl} !== expected) begin
                $display("FAIL %0s instr=%h got  rw=%b src=%b mw=%b rs=%b br=%b imm=%b alu=%b",
                         name, word, reg_write, alu_src, mem_write, result_src, branch, imm_sel, alu_ctrl);
                $display("     %0s            want rw=%b src=%b mw=%b rs=%b br=%b imm=%b alu=%b",
                         name, expected[9], expected[8], expected[7], expected[6], expected[5],
                         expected[4:3], expected[2:0]);
                errors = errors + 1;
            end else begin
                $display("PASS %-12s instr=%h rw=%b src=%b mw=%b rs=%b br=%b imm=%b alu=%b",
                         name, word, reg_write, alu_src, mem_write, result_src, branch, imm_sel, alu_ctrl);
            end
        end
    endtask

    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0, tb_control);

        //            name           instruction    rw src mw rs br  imm   alu
        // ---- R-type: reg_write only, ALU op from funct3/funct7 ----
        check("ADD",          32'h002081b3, {5'b10000, 2'b00, 3'b000}); // add  x3, x1, x2
        check("SUB",          32'h402081b3, {5'b10000, 2'b00, 3'b001}); // sub  x3, x1, x2
        check("AND",          32'h0020f1b3, {5'b10000, 2'b00, 3'b010}); // and  x3, x1, x2
        check("OR",           32'h0020e1b3, {5'b10000, 2'b00, 3'b011}); // or   x3, x1, x2
        check("XOR",          32'h0020c1b3, {5'b10000, 2'b00, 3'b100}); // xor  x3, x1, x2
        // ---- I-type ----
        check("ADDI",         32'h00500093, {5'b11000, 2'b00, 3'b000}); // addi x1, x0, 5
        check("LW",           32'h00002403, {5'b11010, 2'b00, 3'b000}); // lw   x8, 0(x0)
        // ---- S-type ----
        check("SW",           32'h00302023, {5'b01100, 2'b01, 3'b000}); // sw   x3, 0(x0)
        // ---- B-type: compare with sub ----
        check("BEQ",          32'h00818463, {5'b00001, 2'b10, 3'b001}); // beq  x3, x8, +8
        check("BNE",          32'h00819463, {5'b00001, 2'b10, 3'b001}); // bne  x3, x8, +8

        // ---- Edge cases ----
        // Negative immediates set bit 30; ADDI must stay "add", not become SUB.
        check("ADDI -8",      32'hff800093, {5'b11000, 2'b00, 3'b000}); // addi x1, x0, -8
        check("LW -4",        32'hffc02403, {5'b11010, 2'b00, 3'b000}); // lw   x8, -4(x0)
        check("SW -4",        32'hfe302e23, {5'b01100, 2'b01, 3'b000}); // sw   x3, -4(x0)
        check("BNE -8",       32'hfe819ce3, {5'b00001, 2'b10, 3'b001}); // bne  x3, x8, -8
        // Unknown opcode (LUI) and all-zero word: nothing written, no branch.
        check("LUI (none)",   32'h000010b7, {5'b00000, 2'b00, 3'b000});
        check("all zeros",    32'h00000000, {5'b00000, 2'b00, 3'b000});
        // Back to a real instruction after an unknown one: outputs must update.
        check("SUB again",    32'h402081b3, {5'b10000, 2'b00, 3'b001});

        if (errors != 0) $fatal(1, "CONTROL: %0d failures in %0d tests", errors, tests);
        $display("CONTROL: ALL TESTS PASSED (%0d instructions, all 7 outputs checked)", tests);
        $finish;
    end
endmodule
