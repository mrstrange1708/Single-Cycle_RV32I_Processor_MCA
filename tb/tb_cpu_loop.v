`timescale 1ns/1ps
// Owner: Member 5 (Balanagu Srikar). Full-processor testbench for Program B (Loop Summation).
module tb_cpu_loop;
    reg clk = 0;
    reg reset = 1;
    integer errors = 0;
    integer cycles = 0;

    // Instantiate DUT
    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    // 100 MHz clock generation
    always #5 clk = ~clk;

    // Cycle counter
    always @(posedge clk) begin
        if (!reset) cycles <= cycles + 1;
    end

    initial begin
        $dumpfile("cpu_loop.vcd");
        $dumpvars(0, tb_cpu_loop);

        $display("==================================================");
        $display("  RV32I Single-Cycle Processor: Program B Test    ");
        $display("  Sum of 1 to 5 (Iterative Loop & Backward Branch)");
        $display("==================================================");

        // Reset sequence
        #12 reset = 0;

        // Run until loop completes and enters halt loop (19 instructions + margin)
        #350;

        $display("\nChecking Architectural State:");
        $display("--------------------------------------------------");
        $display("  Register x1 (Sum result) : got = %0d, expected = 15", dut.u_rf.regs[1]);
        $display("  Register x2 (Loop index) : got = %0d, expected = 6", dut.u_rf.regs[2]);
        $display("  Register x3 (Loop bound) : got = %0d, expected = 6", dut.u_rf.regs[3]);
        $display("  Data Mem[1] (Stored sum) : got = %0d, expected = 15", dut.u_dm.mem[1]);
        $display("  Cycles elapsed           : %0d", cycles);
        $display("--------------------------------------------------");

        if (dut.u_rf.regs[1] !== 32'd15) begin $display("FAIL: x1 sum mismatch"); errors = errors + 1; end
        if (dut.u_rf.regs[2] !== 32'd6)  begin $display("FAIL: x2 index mismatch"); errors = errors + 1; end
        if (dut.u_rf.regs[3] !== 32'd6)  begin $display("FAIL: x3 bound mismatch"); errors = errors + 1; end
        if (dut.u_dm.mem[1]  !== 32'd15) begin $display("FAIL: mem[1] mismatch"); errors = errors + 1; end

        if (errors == 0) begin
            $display("\n>>> CPU: PROGRAM B (LOOP) PASSED <<<");
            $display("Iterative loop computed 1+2+3+4+5 = 15 successfully.\n");
        end else begin
            $display("\n>>> CPU: PROGRAM B FAILED with %0d errors <<<\n", errors);
            $finish(1);
        end

        $finish;
    end
endmodule
