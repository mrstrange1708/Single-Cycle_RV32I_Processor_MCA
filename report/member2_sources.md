# Sources reviewed for the Member 2 draft

These two primary sources were read before preparing the literature review.
Read the linked sections yourself before the interview and adjust the draft
to reflect your own understanding.

1. **RISC-V International, Unprivileged ISA manual, release 20260120, RV32I v2.1.**
   [Official chapter](https://docs.riscv.org/reference/isa/v20260120/unpriv/rv32.html).
   Sections reviewed: Programmers' Model; Base Instruction Formats;
   Integer Register-Register Instructions; Conditional Branches; Load and Store Instructions.
   The chapter establishes 32-bit registers, x0, fixed register fields, load/store
   behavior, low-32-bit arithmetic results, and ADD/SUB/AND/OR/XOR/BEQ/BNE semantics.
   These are the specifications used for the ALU and its expected results.

2. **K. Asanović and D. A. Patterson, “Instruction Sets Should Be Free:
   The Case For RISC-V,” UCB/EECS-2014-146, August 6, 2014.**
   [Berkeley record and original paper](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2014/EECS-2014-146.html).
   Printed pages 1–2 distinguish an ISA from an implementation and discuss an
   open, small base ISA with optional extensions for research and education.
   The paper supports the motivation for choosing RISC-V; it does not specify
   this project's control codes or establish this CPU's performance.

## How the team can merge these files

- Put `\input{member2_literature_review}` inside Literature Review and
  `\input{member2_module_design}` inside Proposed Solution / Module Design.
- Add the row from `member2_contribution.tex` to the existing contribution table.
- Member 5 can merge the two bibliography entries into the team's `.bib` file
  and use `IEEEtran` bibliography style. Both citation keys already appear in
  the literature-review text. Do not create a second References section.
- Member 3 supplies the review of datapaths and existing cores; Member 1
  assembles and renders the final IEEE report. These fragments are Member 2's
  contribution, not a complete team report or final PDF.

The draft describes a ten-instruction teaching subset, not complete RV32I
conformance, and makes no unmeasured timing or CPU test claims.
