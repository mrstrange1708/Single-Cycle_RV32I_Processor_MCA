# Member 2 completion check

Checked against the Member 2 card, shared interface, report assignments,
video segment, and Phase II table in the supplied RV32I Team Playbook.
Only Member 2's RTL, tests, and supporting documents were changed.

## Implemented and verified

- [x] `rtl/alu.v`: unchanged port names/widths; two 32-bit operands and
  3-bit control, 32-bit result, one-bit zero; no clock or reset.
- [x] Shared operation codes: 000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR.
- [x] All other control codes assign zero; complete combinational assignment
  avoids a latch. Arithmetic wraps to the low 32 bits.
- [x] Zero is high exactly when the result is zero, including equal-input SUB.
- [x] `tb/tb_alu.v`: all seven guide examples plus boundary/transition cases;
  542 total vectors, checking both outputs on every vector.
- [x] Unit simulation prints `ALU: ALL TESTS PASSED` with zero failures.
- [x] Failure handling verified: a temporary broken zero flag is rejected
  with exit code 1 and never prints the success message.
- [x] `sim/alu.vcd` generated. Waveform and other simulation outputs are ignored
  by Git as required by the repository's existing `.gitignore`.
- [x] Native GTKWave capture saved to `docs/waveforms/alu.png`, with a portable
  saved view and interpretation in `docs/waveforms/README_alu.md`.
- [x] Literature Review part 1 drafted from two primary sources, with both
  references cited; ALU module-design text and contribution row prepared.
- [x] 55-second demo narration/shot plan and assigned interview questions
  prepared in `docs/member2_demo.md`.
- [x] Phase II performance calculator checked against the guide's estimate,
  a small instruction trace, and invalid input cases. No measured performance
  is claimed without CPU/synthesis evidence.

## Submission and team-dependent items

- [ ] Demo recording (deferred by the user): record your own name/voice for
  the 0:55–1:50 segment and give it to
  Member 5 for the final team video. The script is ready; a personal recording
  has not been created or represented as complete.
- [ ] Merge these fragments into the shared IEEE report with Members 1/3/5.
  `report/member2_review.pdf` is a standalone review preview, not the final
  team submission PDF.
- [ ] Full CPU integration and Program A verification: this checkout still
  lacks `imem`, `dmem`, `regfile`, `immgen`, and `control`, plus CPU programs
  and testbench. The existing CPU connects the ALU using the agreed ports.
- [ ] Actual Phase II CPI/cycle-count/time table: collect the executed
  instruction traces and Member 1's Vivado Fmax before filling measured values.
- [x] GitHub publication and attribution: Member 2's staged commits were
  pushed to `origin/main`, and the remote history was verified. GitHub links
  their authors to `Smanikanta21`; confirm this is the account to use for
  Member 2's course contribution record.

The guide requests four or more staged commits. Your latest instruction
confirms that sequence: skeletons, ADD/SUB, bitwise operations and zero,
passing testbench, written materials, and final evidence. The pre-existing
Member 1 history is preserved. GitHub publication is complete.

## Reproduce the checks

```sh
./tb/run_alu.sh
python3 report/calculate_performance.py --guide-example --single-fmax-mhz 50 --multi-fmax-mhz 200
```

Expected results: 542 ALU vectors pass; the explicitly illustrative Program B
calculation gives 19 versus 71 cycles and 0.380 versus 0.355 us at 50 versus
200 MHz. Those example frequencies and instruction counts are not measured
results from this checkout.

To rebuild the IEEE-format contribution preview, run `tectonic member2_review.tex`
from `report/`. The source fragments and `.bib` file can also be merged directly
in Overleaf; they need no changes to other members' sections.
