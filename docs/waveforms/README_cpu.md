# Member 5 CPU Waveform Evidence

Owner: **Member 5 (Balanagu Srikar)** — Memory & Verification  
Artifacts: `docs/waveforms/cpu.png`, `docs/waveforms/cpu.gtkw`, `sim/cpu.vcd`

---

## Overview

The file `docs/waveforms/cpu.png` illustrates the complete execution trace of **Program A** (`test_all.hex`), demonstrating the cycle-by-cycle behavior of all 10 RV32I instructions in the processor datapath.

To open the live interactive trace in GTKWave:
```sh
./tb/run_cpu.sh
gtkwave sim/cpu.vcd docs/waveforms/cpu.gtkw
```

---

## Cycle-by-Cycle Execution Trace

| Cycle | Time (ns) | PC (Hex) | Instruction | Control Signals (`RegW`, `ALUSrc`, `MemW`, `ResSrc`, `Branch`, `PCSrc`) | ALU Operation | Key Register / Memory State Change |
|---|---|---|---|---|---|---|
| **0** | 0–12 | `0x00000000` | — | Reset Active (`reset = 1`) | — | `pc` held at 0; all registers cleared |
| **1** | 12–20 | `0x00000000` | `addi x1, x0, 5` | `1, 1, 0, 0, 0, 0` | `0 + 5 = 5` | `x1 <= 5` at clock edge (20 ns) |
| **2** | 20–30 | `0x00000004` | `addi x2, x0, 3` | `1, 1, 0, 0, 0, 0` | `0 + 3 = 3` | `x2 <= 3` at clock edge (30 ns) |
| **3** | 30–40 | `0x00000008` | `add x3, x1, x2` | `1, 0, 0, 0, 0, 0` | `5 + 3 = 8` | `x3 <= 8` at clock edge (40 ns) |
| **4** | 40–50 | `0x0000000C` | `sub x4, x1, x2` | `1, 0, 0, 0, 0, 0` | `5 - 3 = 2` | `x4 <= 2` at clock edge (50 ns) |
| **5** | 50–60 | `0x00000010` | `and x5, x1, x2` | `1, 0, 0, 0, 0, 0` | `5 & 3 = 1` | `x5 <= 1` at clock edge (60 ns) |
| **6** | 60–70 | `0x00000014` | `or x6, x1, x2`  | `1, 0, 0, 0, 0, 0` | `5 \| 3 = 7` | `x6 <= 7` at clock edge (70 ns) |
| **7** | 70–80 | `0x00000018` | `xor x7, x1, x2` | `1, 0, 0, 0, 0, 0` | `5 ^ 3 = 6` | `x7 <= 6` at clock edge (80 ns) |
| **8** | 80–90 | `0x0000001C` | `sw x3, 0(x0)`   | `0, 1, 1, 0, 0, 0` | `0 + 0 = 0` (addr) | `dmem[0] <= 8` written synchronously |
| **9** | 90–100 | `0x00000020` | `lw x8, 0(x0)`   | `1, 1, 0, 1, 0, 0` | `0 + 0 = 0` (addr) | `dmem[0]` read combinational; `x8 <= 8` |
| **10** | 100–110 | `0x00000024` | `beq x3, x8, +8` | `0, 0, 0, 0, 1, 1` | `8 - 8 = 0` (`zero=1`) | **Taken**: `pc_next = 0x24 + 8 = 0x2C` |
| **—** | — | `0x00000028` | `addi x9, x0, 1` | — | — | **SKIPPED**: `x9` remains `0` |
| **11** | 110–120 | `0x0000002C` | `bne x1, x2, +8` | `0, 0, 0, 0, 1, 1` | `5 - 3 = 2` (`zero=0`) | **Taken**: `pc_next = 0x2C + 8 = 0x34` |
| **—** | — | `0x00000030` | `addi x10, x0, 1`| — | — | **SKIPPED**: `x10` remains `0` |
| **12** | 120–130 | `0x00000034` | `addi x11, x0, 42`| `1, 1, 0, 0, 0, 0`| `0 + 42 = 42` | `x11 <= 42` at clock edge (130 ns) |
| **13+**| 130+ | `0x00000038` | `beq x0, x0, 0`  | `0, 0, 0, 0, 1, 1` | `0 - 0 = 0` (`zero=1`) | **Halt loop**: PC remains at `0x38` |

---

## Critical Architectural Verification Highlights

1. **Memory Load-Store Round Trip**:
   - In Cycle 8 (`sw`), `alu_result = 0` selects data memory word 0, `mem_write = 1` writes `x3 = 8` into memory.
   - In Cycle 9 (`lw`), `result_src = 1` multiplexes memory read data (`mem_rdata = 8`) to the writeback bus, successfully loading `8` into `x8`.
2. **Branch Decision Verification**:
   - `beq` compares `x3` (8) and `x8` (8). The ALU calculates $8 - 8 = 0$, asserting `zero = 1`. Since `instr[12] == 0`, `pc_src = branch & zero = 1`, jumping to `0x2C` and skipping `x9`.
   - `bne` compares `x1` (5) and `x2` (3). The ALU calculates $5 - 3 = 2 \neq 0$, so `zero = 0`. Since `instr[12] == 1`, `pc_src = branch & ~zero = 1`, jumping to `0x34` and skipping `x10`.
   - The probe signals verify `x9 == 0` and `x10 == 0`, confirming both branch skips occurred properly.
