`timescale 1ns/1ps
// Owner: Member 2. Self-checking ALU unit testbench.
module tb_alu;
    reg  [31:0] a, b;
    reg  [2:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    alu dut (.a(a), .b(b), .alu_ctrl(alu_ctrl), .result(result), .zero(zero));

    integer errors = 0;
    integer tests = 0;
    integer op, x, y, i;
    integer coverage [0:7];
    reg [31:0] expected;

    // Each vector checks the data result AND the zero flag. Case inequality
    // also rejects unknown (X/Z) outputs instead of treating them as a pass.
    task check;
        input [2:0] operation;
        input [31:0] lhs, rhs, answer;
        begin
            alu_ctrl = operation;
            a = lhs;
            b = rhs;
            #10;
            tests = tests + 1;
            coverage[operation] = coverage[operation] + 1;
            if (result !== answer || zero !== (answer == 32'b0)) begin
                $display("FAIL test=%0d op=%b a=%h b=%h result=%h expected=%h zero=%b expected_zero=%b",
                         tests, operation, lhs, rhs, result, answer,
                         zero, (answer == 32'b0));
                errors = errors + 1;
            end else if (tests <= 7) begin
                $display("PASS op=%b a=%h b=%h result=%h zero=%b",
                         operation, lhs, rhs, result, zero);
            end
        end
    endtask

    initial begin
        for (i = 0; i < 8; i = i + 1) coverage[i] = 0;
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);

        // Playbook examples: 5=101 and 3=011, so AND=001, OR=111,
        // XOR=110. 3-5=-2 is 0xFFFFFFFE in two's complement.
        check(3'b000, 32'd5, 32'd3, 32'd8);
        check(3'b001, 32'd5, 32'd3, 32'd2);
        check(3'b001, 32'd3, 32'd5, 32'hfffffffe);
        check(3'b010, 32'd5, 32'd3, 32'd1);
        check(3'b011, 32'd5, 32'd3, 32'd7);
        check(3'b100, 32'd5, 32'd3, 32'd6);
        check(3'b001, 32'd7, 32'd7, 32'd0);

        // Arithmetic boundaries: wraparound is normal RV32I behavior;
        // the ALU has no overflow exception or saturation output.
        check(3'b000, 32'd0, 32'd0, 32'd0);
        check(3'b000, 32'hffffffff, 32'd1, 32'd0);
        check(3'b000, 32'h7fffffff, 32'd1, 32'h80000000);
        check(3'b000, 32'h80000000, 32'h80000000, 32'd0);
        check(3'b000, 32'hfffffffe, 32'd3, 32'd1);
        check(3'b001, 32'd0, 32'd1, 32'hffffffff);
        check(3'b001, 32'h80000000, 32'd1, 32'h7fffffff);
        check(3'b001, 32'hffffffff, 32'hffffffff, 32'd0);
        check(3'b001, 32'd0, 32'hffffffff, 32'd1);

        // Exercise every bit, including the sign bit, and transitions
        // from zero to nonzero results for all the bitwise operations.
        check(3'b010, 32'hffffffff, 32'h80000001, 32'h80000001);
        check(3'b010, 32'haaaaaaaa, 32'h55555555, 32'd0);
        check(3'b010, 32'hffffffff, 32'hffffffff, 32'hffffffff);
        check(3'b011, 32'd0, 32'd0, 32'd0);
        check(3'b011, 32'haaaaaaaa, 32'h55555555, 32'hffffffff);
        check(3'b011, 32'h80000000, 32'd1, 32'h80000001);
        check(3'b100, 32'hffffffff, 32'hffffffff, 32'd0);
        check(3'b100, 32'haaaaaaaa, 32'h55555555, 32'hffffffff);
        check(3'b100, 32'h80000000, 32'd1, 32'h80000001);

        // Unused codes must overwrite a previous nonzero result.
        check(3'b101, 32'hffffffff, 32'd3, 32'd0);
        check(3'b000, 32'd1, 32'd2, 32'd3);
        check(3'b110, 32'd5, 32'd3, 32'd0);
        check(3'b100, 32'd5, 32'd3, 32'd6);
        check(3'b111, 32'hffffffff, 32'hffffffff, 32'd0);

        // Exhaustively check 0..7 operand pairs for every control code.
        // Logical expected values are built one bit at a time from truth
        // conditions, independently of the DUT's vector operators.
        for (op = 0; op < 8; op = op + 1) begin
            for (x = 0; x < 8; x = x + 1) begin
                for (y = 0; y < 8; y = y + 1) begin
                    expected = 32'b0;
                    if (op == 0) expected = x + y;
                    if (op == 1) expected = x - y;
                    for (i = 0; i < 3; i = i + 1) begin
                        if (op == 2) expected[i] = (x[i] == 1 && y[i] == 1);
                        if (op == 3) expected[i] = (x[i] == 1 || y[i] == 1);
                        if (op == 4) expected[i] = (x[i] != y[i]);
                    end
                    check(op[2:0], x, y, expected);
                end
            end
        end

        for (op = 0; op < 8; op = op + 1) begin
            if (coverage[op] == 0) begin
                $display("FAIL control code %b was never tested", op[2:0]);
                errors = errors + 1;
            end
        end
        if (errors != 0) $fatal(1, "ALU: %0d failures in %0d tests", errors, tests);
        $display("ALU: ALL TESTS PASSED (%0d vectors; result and zero checked for each)", tests);
        $finish;
    end
endmodule
