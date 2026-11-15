`timescale 1ns/1ps
// Owner: Member 5 (Balanagu Srikar). Full-processor testbench for Program A.
module tb_cpu;
    reg clk = 0;
    reg reset = 1;
    integer errors = 0;

    // Instantiate Device Under Test (DUT)
    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    // Architectural probe wires for waveform visualization and GTKWave inspection
    wire [31:0] pc_cur     = dut.pc_cur;
    wire [31:0] instr      = dut.instr;
    wire        reg_write  = dut.reg_write;
    wire        alu_src    = dut.alu_src;
    wire        mem_write  = dut.mem_write;
    wire        result_src = dut.result_src;
    wire        branch     = dut.branch;
    wire        pc_src     = dut.pc_src;
    wire [2:0]  alu_ctrl   = dut.alu_ctrl;
    wire [31:0] rd1        = dut.rd1;
    wire [31:0] rd2        = dut.rd2;
    wire [31:0] imm        = dut.imm;
    wire [31:0] alu_result = dut.alu_result;
    wire        zero       = dut.zero;
    wire [31:0] mem_rdata  = dut.mem_rdata;
    wire [31:0] result     = dut.result;

    // Register probe wires
    wire [31:0] x1  = dut.u_rf.regs[1];
    wire [31:0] x2  = dut.u_rf.regs[2];
    wire [31:0] x3  = dut.u_rf.regs[3];
    wire [31:0] x4  = dut.u_rf.regs[4];
    wire [31:0] x5  = dut.u_rf.regs[5];
    wire [31:0] x6  = dut.u_rf.regs[6];
    wire [31:0] x7  = dut.u_rf.regs[7];
    wire [31:0] x8  = dut.u_rf.regs[8];
    wire [31:0] x9  = dut.u_rf.regs[9];
    wire [31:0] x10 = dut.u_rf.regs[10];
    wire [31:0] x11 = dut.u_rf.regs[11];
    wire [31:0] dmem0 = dut.u_dm.mem[0];

    // 100 MHz clock generation (10 ns period, 50% duty cycle)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);

        $display("==================================================");
        $display("   RV32I Single-Cycle Processor: Program A Test   ");
        $display("==================================================");

        // Reset sequence: hold reset high past the first clock edge
        #12 reset = 0;

        // Allow processor to execute all 15 instructions and enter halt loop
        #300;

        $display("\nChecking Architectural State:");
        $display("--------------------------------------------------");
        $display("  Register x1  (addi 5)      : got = %0d, expected = 5", dut.u_rf.regs[1]);
        $display("  Register x2  (addi 3)      : got = %0d, expected = 3", dut.u_rf.regs[2]);
        $display("  Register x3  (add x1, x2)  : got = %0d, expected = 8", dut.u_rf.regs[3]);
        $display("  Register x4  (sub x1, x2)  : got = %0d, expected = 2", dut.u_rf.regs[4]);
        $display("  Register x5  (and x1, x2)  : got = %0d, expected = 1", dut.u_rf.regs[5]);
        $display("  Register x6  (or x1, x2)   : got = %0d, expected = 7", dut.u_rf.regs[6]);
        $display("  Register x7  (xor x1, x2)  : got = %0d, expected = 6", dut.u_rf.regs[7]);
        $display("  Data Mem[0]  (sw x3, 0)    : got = %0d, expected = 8", dut.u_dm.mem[0]);
        $display("  Register x8  (lw 0(x0))    : got = %0d, expected = 8", dut.u_rf.regs[8]);
        $display("  Register x9  (beq skip)    : got = %0d, expected = 0", dut.u_rf.regs[9]);
        $display("  Register x10 (bne skip)    : got = %0d, expected = 0", dut.u_rf.regs[10]);
        $display("  Register x11 (addi 42)     : got = %0d, expected = 42", dut.u_rf.regs[11]);
        $display("--------------------------------------------------");

        if (dut.u_rf.regs[1]  !== 32'd5)  begin $display("FAIL: x1 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[2]  !== 32'd3)  begin $display("FAIL: x2 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[3]  !== 32'd8)  begin $display("FAIL: x3 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[4]  !== 32'd2)  begin $display("FAIL: x4 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[5]  !== 32'd1)  begin $display("FAIL: x5 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[6]  !== 32'd7)  begin $display("FAIL: x6 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[7]  !== 32'd6)  begin $display("FAIL: x7 mismatch");  errors = errors + 1; end
        if (dut.u_dm.mem[0]   !== 32'd8)  begin $display("FAIL: mem[0] mismatch"); errors = errors + 1; end
        if (dut.u_rf.regs[8]  !== 32'd8)  begin $display("FAIL: x8 mismatch");  errors = errors + 1; end
        if (dut.u_rf.regs[9]  !== 32'd0)  begin $display("FAIL: x9 mismatch (BEQ failed to branch)"); errors = errors + 1; end
        if (dut.u_rf.regs[10] !== 32'd0)  begin $display("FAIL: x10 mismatch (BNE failed to branch)"); errors = errors + 1; end
        if (dut.u_rf.regs[11] !== 32'd42) begin $display("FAIL: x11 mismatch"); errors = errors + 1; end

        if (errors == 0) begin
            $display("\n>>> CPU: PROGRAM A PASSED <<<");
            $display("All 10 instructions verified with expected architectural outputs.\n");
        end else begin
            $display("\n>>> CPU: PROGRAM A FAILED with %0d errors <<<\n", errors);
            $finish(1);
        end

        $finish;
    end
endmodule
