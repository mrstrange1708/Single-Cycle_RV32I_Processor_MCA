# RISC-V Test Programs

Owner: **Member 5 (Balanagu Srikar)** — Memory & Verification  
Repository: Single-Cycle RV32I Processor

This directory contains the assembly source (`.s`) and machine code (`.hex`) for processor verification.

---

## Program A: Full ISA Verification (`test_all.s`, `test_all.hex`)

Exercises all 10 supported RV32I instructions in a linear and conditional flow to ensure full architectural coverage.

### Instruction Map & Verification Points

| Addr | Hex | Assembly | Instruction Type | Expected Architectural State | Verification Goal |
|---|---|---|---|---|---|
| `0x00` | `00500093` | `addi x1, x0, 5` | I-type | `x1 = 5` | ADDI immediate sign extension & addition |
| `0x04` | `00300113` | `addi x2, x0, 3` | I-type | `x2 = 3` | Register write to `x2` |
| `0x08` | `002081b3` | `add x3, x1, x2` | R-type | `x3 = 8` | ALU ADD with register sources |
| `0x0C` | `40208233` | `sub x4, x1, x2` | R-type | `x4 = 2` | ALU SUB (`funct7[5] = 1`) |
| `0x10` | `0020f2b3` | `and x5, x1, x2` | R-type | `x5 = 1` | ALU AND (`5 & 3 = 1`) |
| `0x14` | `0020e333` | `or x6, x1, x2` | R-type | `x6 = 7` | ALU OR (`5 \| 3 = 7`) |
| `0x18` | `0020c3b3` | `xor x7, x1, x2` | R-type | `x7 = 6` | ALU XOR (`5 ^ 3 = 6`) |
| `0x1C` | `00302023` | `sw x3, 0(x0)` | S-type | `dmem[0] = 8` | Data memory store with zero offset |
| `0x20` | `00002403` | `lw x8, 0(x0)` | I-type | `x8 = 8` | Data memory load; writeback into `x8` |
| `0x24` | `00818463` | `beq x3, x8, +8` | B-type | Taken (`PC += 8`) | Branch if equal (`x3 == x8 == 8`), skips `0x28` |
| `0x28` | `00100493` | `addi x9, x0, 1` | I-type | **Skipped** (`x9 = 0`) | Verifies `beq` branch taken |
| `0x2C` | `00209463` | `bne x1, x2, +8` | B-type | Taken (`PC += 8`) | Branch if not equal (`x1 != x2`, `5 != 3`), skips `0x30` |
| `0x30` | `00100513` | `addi x10, x0, 1` | I-type | **Skipped** (`x10 = 0`) | Verifies `bne` branch taken |
| `0x34` | `02a00593` | `addi x11, x0, 42` | I-type | `x11 = 42` (`0x2A`) | Verifies execution resumes at branch target |
| `0x38` | `00000063` | `beq x0, x0, 0` | B-type | Infinite loop | Traps CPU to halt state |

---

## Program B: Iterative Loop Summation (`sum_loop.s`, `sum_loop.hex`)

Computes the sum of integers from 1 to 5 ($1 + 2 + 3 + 4 + 5 = 15$). This program verifies backward branching with a negative 12-bit immediate, repeated register file read-write iterations, loop boundary checking, and memory storage.

### Trace & Verification Points

| Addr | Hex | Assembly | Note |
|---|---|---|---|
| `0x00` | `00000093` | `addi x1, x0, 0` | Initialize `sum = 0` |
| `0x04` | `00100113` | `addi x2, x0, 1` | Initialize loop counter `i = 1` |
| `0x08` | `00600193` | `addi x3, x0, 6` | Loop bound `bound = 6` |
| `0x0C` | `002080b3` | `add x1, x1, x2` | `sum += i` (Iterations: 1, 3, 6, 10, 15) |
| `0x10` | `00110113` | `addi x2, x2, 1` | `i++` (Iterations: 2, 3, 4, 5, 6) |
| `0x14` | `fe311ce3` | `bne x2, x3, -8` | Backward branch to `0x0C` while `i != 6` |
| `0x18` | `00102223` | `sw x1, 4(x0)` | Store final sum (15) at data memory word 1 (`addr = 4`) |
| `0x1C` | `00000063` | `beq x0, x0, 0` | Halt |

### Execution Metrics
- **Total instructions executed:** 19
- **Expected register values at completion:**
  - `x1 = 15` (`0x0000000F`)
  - `x2 = 6`  (`0x00000006`)
  - `x3 = 6`  (`0x00000006`)
- **Expected data memory values:**
  - `dmem[1]` (word address 1 / byte address 4) = `15` (`0x0000000F`)
