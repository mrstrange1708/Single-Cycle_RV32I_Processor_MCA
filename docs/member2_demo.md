# Member 2 demo and interview preparation

## 55-second segment: team video 0:55–1:50

Replace `[your name]` with your own name when recording. The captioned support
clip can accompany your narration; the final team video needs all five names
and must remain within five minutes.

| Relative time | Show | Explain |
|---|---|---|
| 0–12 s | `rtl/alu.v`, ports and operation cases | Two 32-bit operands, 3-bit selector, five operations |
| 12–27 s | `always @(*)` and `assign zero` | Combinational logic, no clock, equality by subtraction |
| 27–40 s | `./tb/run_alu.sh` output | Negative subtraction and 542 passing vectors |
| 40–55 s | `docs/waveforms/alu.png` | Results change with inputs; equal-input SUB asserts zero |

Suggested narration:

> I'm [your name], Member 2, and I built the arithmetic logic unit and its
> self-checking testbench. The ALU takes two 32-bit operands and a three-bit
> control code. It performs addition, subtraction, AND, OR, and XOR.
> It is purely combinational, so it has no clock. The zero flag is high
> whenever the result is zero. Subtracting equal operands lets the processor
> decide BEQ and BNE branches. Here the testbench checks all operations,
> including three minus five, which appears as hexadecimal FFFFFFFE.
> All 542 vectors pass, checking both the result and zero flag. The waveform
> shows the five operations and equal-input subtraction. Unused control
> codes also return zero, and every case assigns a result to avoid a latch.

Record at approximately 145–150 words per minute and rehearse against the
55-second slot. Describe the full CPU as working only after its tests pass.

## Assigned interview questions

- **Q3: CPI is one, so why can it be slow?** Every instruction shares a clock
  period long enough for the slowest path, typically LW in this datapath.
- **Q8: How do BEQ/BNE share the ALU?** SUB computes `rs1-rs2`; zero indicates
  equality. `cpu.v` branches on zero for BEQ and on its inverse for BNE.
- **Q12: What is combinational versus sequential?** ALU, control, immediate
  generation, and muxes are combinational. PC updates and register/memory
  writes are sequential. The ALU has no stored state.
- **Q13: How do your tests prove correctness?** The unit testbench applies
  independently expected vectors, checks result and zero with case inequality,
  and exits with an error on failure. This establishes ALU behavior; full
  CPU correctness needs Member 5's program tests and CPU waveforms.
- **Q16: RISC-V versus MIPS?** The conventional 32-bit forms use a load/store
  organization and 32 integer registers. RISC-V is an open ISA, keeps register
  fields in fixed positions, and has no architectural branch delay slot.

Also understand why `3-5` is `0xFFFFFFFE`, why the default case prevents a
latch, and why `zero` is an internal wire rather than a RISC-V status register.
