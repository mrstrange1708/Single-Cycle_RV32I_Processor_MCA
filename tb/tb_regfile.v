`timescale 1ns/1ps
// Owner: Member 3. Self-checking register file testbench.
module tb_regfile;
    reg         clk = 0;
    reg         we;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;
    integer errors = 0;

    regfile dut (.clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd), .rd1(rd1), .rd2(rd2));

    always #5 clk = ~clk;   // 10 ns clock period

    // Sets up one write, lets one rising clock edge happen, then turns we off
    task write_reg(input [4:0] r, input [31:0] value, input enable);
        begin
            @(negedge clk);
            we = enable; rd = r; wd = value;
            @(negedge clk);
            we = 0;
        end
    endtask

    // Reads two registers at the same time (no clock needed) and checks both
    task check_read(input [4:0] a, input [4:0] b, input [31:0] exp1, input [31:0] exp2);
        begin
            rs1 = a; rs2 = b; #1;
            if (rd1 !== exp1 || rd2 !== exp2) begin
                $display("FAIL rs1=x%0d rs2=x%0d got rd1=%0d rd2=%0d expected rd1=%0d rd2=%0d",
                         a, b, rd1, rd2, exp1, exp2);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("regfile.vcd"); $dumpvars(0, tb_regfile);
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;

        write_reg(5'd5, 32'd25, 1'b1);              // write 25 to x5
        check_read(5'd5, 5'd0, 32'd25, 32'd0);      // ... and read it back

        write_reg(5'd0, 32'd99, 1'b1);              // try to write 99 to x0
        check_read(5'd0, 5'd0, 32'd0, 32'd0);       // x0 must still read 0 on both ports

        write_reg(5'd6, 32'd7, 1'b1);               // x6 = 7
        check_read(5'd5, 5'd6, 32'd25, 32'd7);      // two reads at once give two different registers

        write_reg(5'd5, 32'd123, 1'b0);             // we = 0: this write must be ignored
        check_read(5'd5, 5'd6, 32'd25, 32'd7);

        write_reg(5'd31, 32'hFFFFFFF8, 1'b1);       // -8 in the last register
        check_read(5'd31, 5'd5, 32'hFFFFFFF8, 32'd25);

        if (errors == 0) $display("REGFILE: ALL TESTS PASSED");
        $finish;
    end
endmodule
