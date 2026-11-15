# Single-Cycle RV32I Processor (Verilog)

MCA course project, Project 1. A single-cycle RISC-V processor that executes
ADD, SUB, AND, OR, XOR, ADDI, LW, SW, BEQ and BNE.

## Team

| Member   | Name                                  | Part                                                   |
|----------|---------------------------------------|--------------------------------------------------------|
| Member 1 | Shaik Junaid                          | PC, top-level integration, datapath diagram, README    |
| Member 2 | Siraparapu Shiva Sankar Mani Kanta    | ALU + ALU testbench                                    |
| Member 3 | Nakkina Lakshmi Praneeth              | Register file, immediate generator + testbench         |
| Member 4 | Rishik Chowdary Karuturi              | Control unit, control truth table + testbench          |
| Member 5 | Balanagu Sesha Srikar                 | Instruction/data memory, test programs, CPU testbenches|

## Demo video

<paste YouTube / Drive link>

## Report

[report/report.pdf](report/report.pdf)

## Architecture

![Datapath](docs/datapath.png)

## Repository layout

```
rtl/        hardware modules   (pc.v cpu.v alu.v regfile.v immgen.v control.v imem.v dmem.v)
tb/         testbenches        (tb_alu.v tb_regfile.v tb_control.v tb_cpu.v tb_cpu_loop.v)
            + run scripts      (run_alu.sh run_control.sh run_cpu.sh)
programs/   test programs      (test_all.s/.hex = Program A, sum_loop.s/.hex = Program B)
sim/        run simulations here (outputs are not committed)
docs/       datapath.png, control_table.md, waveforms/ screenshots per module
report/     main.tex + section fragments, references (.bib), report.pdf
```

## Test programs

| Program | File | What it checks | Expected |
|---------|------|----------------|----------|
| A | `programs/test_all.hex` | Every one of the 10 instructions once, both branches taken | x3=8 x4=2 x5=1 x6=7 x7=6 x8=8 x9=0 x10=0 x11=42, mem[0]=8 |
| B | `programs/sum_loop.hex` | Backward BNE loop summing 1..5, SW with offset | x1=15 x2=6, mem[1]=15 after 19 instructions |

## Interface contract

Every module keeps these exact port names and widths. `cpu.v` connects to them.

| Module  | Inputs                                         | Outputs                                                                        |
|---------|------------------------------------------------|--------------------------------------------------------------------------------|
| pc      | clk, reset, pc_next[31:0]                      | pc[31:0]                                                                       |
| alu     | a[31:0], b[31:0], alu_ctrl[2:0]                | result[31:0], zero                                                             |
| regfile | clk, we, rs1[4:0], rs2[4:0], rd[4:0], wd[31:0] | rd1[31:0], rd2[31:0]                                                           |
| immgen  | instr[31:0], imm_sel[1:0]                      | imm[31:0]                                                                      |
| control | opcode[6:0], funct3[2:0], funct7_5             | reg_write, alu_src, mem_write, result_src, branch, imm_sel[1:0], alu_ctrl[2:0] |
| imem    | addr[31:0]                                     | instr[31:0]                                                                    |
| dmem    | clk, we, addr[31:0], wd[31:0]                  | rd[31:0]                                                                       |

Shared codes: `alu_ctrl` 000 add · 001 sub · 010 and · 011 or · 100 xor.
`imm_sel` 00 I-type · 01 S-type · 10 B-type.

## How to run

Needs Icarus Verilog (`iverilog`, `vvp`) and optionally GTKWave.

Full CPU, both programs (prints `CPU: PROGRAM A PASSED` and `CPU: PROGRAM B (LOOP) PASSED`):

```
./tb/run_cpu.sh
gtkwave sim/cpu.vcd docs/waveforms/cpu.gtkw
```

Unit tests:

```
./tb/run_alu.sh          # ALU: ALL TESTS PASSED (542 vectors)
./tb/run_control.sh      # CONTROL: ALL TESTS PASSED (17 instructions)
cd sim && iverilog -o regfile_sim ../tb/tb_regfile.v ../rtl/regfile.v && vvp regfile_sim   # REGFILE: ALL TESTS PASSED
```

Manual run of one program:

```
cd sim
cp ../programs/test_all.hex program.hex
iverilog -o cpu_sim ../tb/tb_cpu.v ../rtl/*.v
vvp cpu_sim
gtkwave cpu.vcd
```

A warning like "Not enough words in the file for $readmemh" is normal: the program is shorter than the 64-word memory.

## Git workflow

```
git pull --rebase        # get teammates' work first
git add rtl/<your_file>  # only YOUR files
git commit -m "ALU: add ADD and SUB operations"
git push
```

## Status

- [x] All 8 modules implemented with the fixed interface
- [x] Unit testbenches passing (ALU, register file, control)
- [x] Program A passes on the full CPU
- [x] Program B (loop) passes on the full CPU
- [x] Datapath diagram, control table and waveform screenshots in docs/
- [x] Report PDF (report/report.pdf, built from report/main.tex)
- [ ] Demo video link
- [ ] Synthesis results (Phase II)
