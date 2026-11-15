# Member 5 Demo Script, Video Assembly Guide & Interview Preparation

Owner: **Member 5 (Balanagu Srikar)** — Memory & Verification  
Role in Video: Segment 5 (3:40 – 4:40, 60 seconds)  
Role in Submission: Final Video Assembly & Verification Lead

---

## 1. 60-Second Video Script (Timestamp: 3:40 – 4:40)

> **Recording Setup:** Landscape 1080p, webcam bubble in the corner. Speak clearly with natural pauses (~130 words). Rehearse twice with a stopwatch to keep under 58 seconds.

### Spoken Narration & Screen Actions

| Time | Screen Display | Spoken Narration |
|---|---|---|
| **3:40 – 3:55** | **Screen:** Show `rtl/imem.v` and `rtl/dmem.v` side by side in the editor. | *"Hi, I'm Balanagu Srikar, Member 5. I built the instruction memory, data memory, our test programs, and the full-processor testbench. We use a modified Harvard architecture with separate instruction and data memories so that an instruction like Load Word can fetch its instruction and access memory data in the exact same clock cycle."* |
| **3:55 – 4:12** | **Screen:** Open `programs/README_programs.md` or `test_all.s` showing Program A. | *"Our primary test suite, Program A, systematically exercises all ten RV32I instructions. It initializes operands with ADDI, runs ALU arithmetic and logic, performs a store followed by a load from data memory, and verifies both equal and not-equal conditional branches."* |
| **4:12 – 4:28** | **Screen:** Switch to GTKWave showing `cpu.vcd` (or `docs/waveforms/cpu.png`). | *"In the waveform, you can see the single-cycle execution trace. PC increments by four, the ALU computes operands, memory data is written and loaded back, and here the branch skips ahead by eight bytes, leaving registers x9 and x10 at zero as expected."* |
| **4:28 – 4:40** | **Screen:** Switch to terminal, execute `./tb/run_cpu.sh`, showing `CPU: PROGRAM A PASSED` and `CPU: PROGRAM B (LOOP) PASSED`. | *"Our automated testbench verifies every register and memory word, confirming Program A and an iterative loop Program B both pass. In Phase Two, we'll synthesize the processor in Vivado and evaluate its maximum clock frequency. Thank you."* |

---

## 2. Team Video Assembly Checklist (Owned by Member 5)

Member 5 is responsible for collecting the 5 individual clips and assembling the final team video:

1. **Collect Clips from All Members:**
   - [ ] Clip 1: Member 1 (0:00–0:55) — Lead, datapath, PC, top-level integration
   - [ ] Clip 2: Member 2 (0:55–1:50) — ALU unit and testbench
   - [ ] Clip 3: Member 3 (1:50–2:45) — Register file and immediate generator
   - [ ] Clip 4: Member 4 (2:45–3:40) — Control unit and truth table
   - [ ] Clip 5: Member 5 (3:40–4:40) — Memories, test programs, full CPU verification
2. **Editing & Formatting (in CapCut / Clipchamp / Premiere / iMovie):**
   - Resolution: 1080p (1920x1080), 30 fps or 60 fps.
   - Lower Thirds: Add a text caption overlay displaying Member Name, Role, and MCA Roll/ID during the first 5 seconds of each member's segment.
   - Total Duration Check: **Must be strictly under 5:00 minutes** (Target: 4 min 40 s). Truncate any clip running over its allotted window.
3. **Upload & Submission:**
   - Upload to YouTube as **Unlisted** (or Google Drive with access set to "Anyone with the link can view").
   - Test the video link in an incognito/private browser window to ensure no login is required.
   - Provide the final link to Member 1 for inclusion in the `README.md` and Phase I submission portal before the deadline.

---

## 3. Evaluator Interview (Viva) Preparation for Member 5

Evaluators will test each member's deep understanding of their module and the whole processor datapath.

### Core Assigned Questions from Playbook

#### Question 4: Why separate instruction and data memories (Harvard architecture)?
> **Answer:** In a single-cycle processor, every instruction completes in exactly one clock cycle. A `LW` (Load Word) instruction must fetch its 32-bit instruction code from memory during the Fetch phase, and simultaneously read the 32-bit data operand from memory during the Memory phase. A single unified memory (von Neumann) with a single read port cannot perform two independent reads to different addresses in the same clock cycle without stalling or requiring multiple cycles. By separating instruction memory and data memory into distinct blocks with independent address decoders, single-cycle execution is achieved without memory contention.

#### Question 13: What is a testbench, and how do you know the CPU works?
> **Answer:** A testbench is a non-synthesizable Verilog module that acts as a virtual lab bench. It instantiates the processor DUT (Device Under Test), generates the master system clock, drives the reset sequence, and monitors architectural state.  
> We know our CPU works because our testbenches are **self-checking**:
> 1. In `tb_cpu.v` (Program A), the testbench checks all destination registers (`x1` through `x8`, `x11`) and memory word `0` against golden mathematical values, ensuring `x9` and `x10` remain 0 to confirm branches were taken.
> 2. In `tb_cpu_loop.v` (Program B), the testbench executes an iterative summation loop ($1+2+3+4+5=15$), verifying that the backward branch loops 5 times and terminates when $i=6$.
> 3. GTKWave waveforms visually prove that control signals (`RegWrite`, `ALUSrc`, `MemWrite`, `ResultSrc`, `Branch`, `PCSrc`) match the architecture specification cycle-by-cycle.

#### Question 14: What is synthesis, and what does it tell you?
> **Answer:** Synthesis is the process where a software tool (such as Xilinx Vivado or Yosys) translates high-level Verilog RTL into real hardware primitive gates, lookup tables (LUTs), multiplexers, and flip-flops tailored for a target FPGA (e.g., Artix-7) or ASIC standard cell library.  
> It provides two critical engineering metrics:
> 1. **Resource Utilization:** Exactly how many hardware resources (Slice LUTs, Slice Registers/FFs, IO buffers, Block RAMs) the processor consumes.
> 2. **Timing Analysis ($F_{max}$):** The length of the critical path (propagation delay through the slowest path, which is `LW`), determining the maximum safe clock frequency.

---

## 4. Hardware Walkthrough: Tracing Two Key Instructions

Be ready to point to the datapath diagram or waveform and walk through these step-by-step:

### Walkthrough 1: Load Word (`lw x8, 0(x0)`)
1. **Fetch:** PC outputs byte address `0x20`. Instruction memory asynchronously outputs `0x00002403`. Concurrently, the PC adder calculates `PC + 4 = 0x24`.
2. **Decode:** Control unit inspects `opcode = 7'b0000011` (LW) and asserts `reg_write = 1`, `alu_src = 1`, `result_src = 1` (select memory), `mem_write = 0`, `branch = 0`, `imm_sel = 00` (I-type). Register file reads `rs1 = x0` (outputs `0`). ImmGen sign-extends `0` to 32 bits.
3. **Execute:** ALUSrc mux selects immediate (`0`). ALU adds $0 + 0 = 0$, producing the memory effective address.
4. **Memory:** Data memory receives `addr = 0` and combinational read retrieves `mem[0] = 8` onto `mem_rdata`.
5. **Writeback:** ResultSrc mux selects `mem_rdata` instead of ALU result. On the next rising clock edge, `result = 8` is written into destination register `x8` because `reg_write = 1`.

### Walkthrough 2: Branch If Equal (`beq x3, x8, +8`)
1. **Fetch:** PC outputs `0x24`. Instruction memory outputs `0x00818463`.
2. **Decode:** Control unit inspects `opcode = 7'b1100011` (Branch) and asserts `branch = 1`, `reg_write = 0`, `mem_write = 0`, `alu_src = 0` (select register `rs2`), `imm_sel = 10` (B-type). Register file reads `rs1 = x3` (8) and `rs2 = x8` (8). ImmGen constructs sign-extended branch offset $+8$.
3. **Execute:** ALU subtracts `rs1 - rs2` ($8 - 8 = 0$). Since the result is 0, the ALU asserts the `zero` flag (`zero = 1`). In parallel, the branch adder calculates target address: `PC + imm = 0x24 + 8 = 0x2C`.
4. **Branch Logic:** Next-PC logic evaluates `pc_src = branch & (BEQ ? zero : ~zero) = 1 & 1 = 1`.
5. **Update PC:** The Next-PC mux selects `pc_branch` (`0x2C`) instead of `pc_plus4` (`0x28`). On the next rising clock edge, PC updates directly to `0x2C`, safely skipping instruction `0x28` (`addi x9, x0, 1`).
