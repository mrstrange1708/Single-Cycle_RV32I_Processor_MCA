# Synthesis and Timing (Member 1)

Simulation shows the logic is correct. Synthesis shows it is real hardware: it
turns the Verilog into FPGA parts and counts them. Timing analysis then finds
the slowest path, which sets the fastest clock the CPU can run at (Fmax).

Target: Xilinx 7-series, Artix-7 `xc7a35tcpg236-1` (the chip on Basys 3 / Arty A7).

## 1. Yosys (open source): resource counts

Run from `syn/`:

```
cp ../programs/test_all.hex program.hex
yosys -s synth_yosys.ys | tee yosys.log
```

Tool: Yosys 0.70. Numbers below are the final "design hierarchy" block of the log
(whole CPU, all submodules included).

| Primitive | Count | What it is in our CPU |
|-----------|------:|------------------------|
| FDRE      | 32    | Flip-flops: the 32-bit PC register |
| RAM32M    | 12    | Register file (32 x 32, two read ports) as LUT-RAM |
| RAM64X1S  | 32    | Data memory (64 words x 32 bits) as LUT-RAM |
| LUT2      | 101   | |
| LUT3      | 73    | |
| LUT4      | 52    | |
| LUT5      | 57    | |
| LUT6      | 91    | |
| LUT total | 374   | Control, ALU, immediate generator, muxes, instruction ROM |
| MUXF7     | 1     | Wide multiplexer that combines two LUTs |
| CARRY4    | 34    | Fast adder chains: ALU, PC+4, PC+imm |
| IBUF / OBUF | 2 / 65 | Input pins (clk, reset) / output pins (the three debug ports) |
| BUFG      | 1     | Global clock buffer |

Estimated number of logic cells (from `synth_xilinx`): 273.

The register file and data memory read asynchronously (data comes out in the
same cycle), so they map to LUT-RAM, not block RAM. Block RAM reads one clock
late, which would break single-cycle execution.

Yosys gives no clock frequency. Fmax comes from Vivado below.

## 2. Vivado: utilization and Fmax

Run from `syn/`:

```
vivado -mode batch -source run_vivado.tcl
```

Clock constraint: 10 ns (100 MHz), set in `syn/cpu.xdc`.

### Utilization (from `utilization.rpt`)

| Resource        | Used | Available |
|-----------------|-----:|----------:|
| Slice LUTs      |      |           |
| Slice Registers |      |           |
| LUT as Memory   |      |           |

### Timing (from `timing_summary.rpt`)

| Item | Value |
|------|-------|
| Target period | 10.000 ns |
| WNS | |
| Critical path delay = 10 - WNS | |
| Fmax = 1 / (10 - WNS) | |

Example: WNS = +2.0 ns, so the path is 8.0 ns and Fmax = 125 MHz. If WNS is
negative the path is longer than 10 ns; the same formula still works.

### Critical path (from `critical_path.rpt`)

| Start point | End point |
|-------------|-----------|
| | |

Expected: the LW path, PC -> instruction memory -> register file -> ALU ->
data memory -> write-back mux -> register file.
