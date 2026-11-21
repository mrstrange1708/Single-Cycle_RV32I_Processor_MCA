# Synthesis and Timing (Member 1)

Simulation shows the logic is correct. Synthesis shows it is real hardware: it
turns the Verilog into FPGA parts and counts them. Place and route then finds
the slowest path, which sets the fastest clock the CPU can run at (Fmax).

## Tool flow

Yosys (synthesis) + nextpnr (place, route, timing), targeting a Lattice ECP5
LFE5U-25F in the CABGA381 package. The team uses macOS, and Vivado runs only on
Windows and Linux, so we use this open-source flow instead.

Tools: OSS CAD Suite 2026-11-21 (Yosys 0.71+77, nextpnr-0.11.1-121-g15b77f5f).

## 1. ECP5 resources (Yosys `stat`)

| Primitive       | Count | What it is |
|-----------------|------:|------------|
| LUT4            | 542   | 4-input lookup tables: control, ALU, immediate generator, muxes, instruction ROM |
| PFUMX / L6MUX21 | 90 / 34 | Muxes that join LUT4s into 5- and 6-input functions |
| CCU2C           | 63    | Carry-chain cells (2 bits each): ALU, PC+4, PC+imm |
| TRELLIS_FF      | 50    | Flip-flops: PC and instruction-fetch register |
| TRELLIS_DPR16X4 | 48    | Distributed RAM (16 words x 4 bits each): register file and data memory |
| DP16KD          | 0     | Block RAM: not used |

## 2. ECP5 utilisation after place and route (nextpnr)

| Resource     | Used | Available | Use |
|--------------|-----:|----------:|----:|
| TRELLIS_COMB | 972  | 24288     | 4%  |
| TRELLIS_FF   | 50   | 24288     | 0%  |
| TRELLIS_RAMW | 48   | 3036      | 1%  |
| TRELLIS_IO   | 67   | 197       | 34% |
| DCCA (clock) | 1    | 56        | 1%  |

## 3. Timing

| Item | Value |
|------|-------|
| Target clock | 50 MHz (`--freq 50`) |
| Fmax (after routing) | **64.18 MHz** (PASS at 50 MHz) |
| Clock period = 1000 / Fmax | **15.58 ns** |

Critical path (clk posedge -> posedge), total **15.58 ns** (5.61 ns logic, 9.98 ns routing):

| Start point | Through | End point |
|-------------|---------|-----------|
| Instruction-fetch flip-flop (`u_ig.instr_TRELLIS_FF_Q_2`) | register file read (`u_rf`) -> ALU carry chain (`alu.v:15`) -> data memory read (`u_dm`) -> next-PC logic -> instruction ROM | Instruction-fetch flip-flop (`u_ig.instr_TRELLIS_FF_Q_8`) |

This is one full instruction: fetch, register read, ALU, memory and next PC,
all in one cycle.

## 4. Cross-check: Yosys for Xilinx 7-series

Same RTL synthesised for a second FPGA family (`syn/synth_yosys.ys`). "Design
hierarchy" totals for the whole CPU:

| Primitive | Count |
|-----------|------:|
| LUT2 / LUT3 / LUT4 / LUT5 / LUT6 | 101 / 73 / 52 / 57 / 91 (total 374) |
| CARRY4    | 34  |
| FDRE      | 32  |
| RAM32M    | 12  |
| RAM64X1S  | 32  |
| MUXF7     | 1   |
| INV       | 7   |
| IBUF / OBUF / BUFG | 2 / 65 / 1 |
| Total cells | 560 |

Estimated logic cells (from `synth_xilinx`): 273.

## Memories

The register file and data memory read asynchronously (data comes out in the
same cycle), so they map to distributed (LUT) RAM: `TRELLIS_DPR16X4` on ECP5,
`RAM32M` / `RAM64X1S` on Xilinx. Block RAM reads one clock late, which would
break single-cycle execution. The instruction memory is read-only with fixed
contents, so Yosys builds it from LUTs. It also moves the PC's address
flip-flops to the ROM output (the 18 extra flip-flops above 32); the behaviour
is the same.

## How to reproduce

From the repo root, with OSS CAD Suite on the PATH (`source <oss-cad-suite>/environment`):

```
cd syn
cp ../programs/test_all.hex program.hex
yosys -s synth_ecp5.ys | tee yosys_ecp5.log
nextpnr-ecp5 --25k --package CABGA381 --json cpu_ecp5.json --freq 50 --report nextpnr_report.json 2>&1 | tee nextpnr.log
yosys -s synth_yosys.ys | tee yosys.log
```

Fmax is the last "Max frequency for clock" line in `nextpnr.log`; the critical
path is the "Critical path report for clock" block above it.
