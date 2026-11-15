# Member 2 Phase II performance worksheet

**Status: calculation tooling prepared; measured CPU performance is pending.**
The checkout has no complete CPU testbench/programs or Vivado timing results.
ALU simulation delays are stimulus spacing, not synthesized propagation delay
or CPU clock measurements.

## Required evidence

1. Member 5 supplies one CSV row per executed instruction, with `pc,mnemonic`
   columns. Count executed loop iterations, not static assembly lines. Stop
   before the terminal self-loop used as a halt marker, and exclude reset.
2. Member 1 supplies Vivado's target period and WNS for the synthesized design,
   including the target device and timing-report evidence. For the playbook's
   stated timing model, `period_ns = target_period_ns - WNS_ns` and
   `Fmax_MHz = 1000 / period_ns`. Check that the timing constraints/report
   justify the number; do not infer it from the testbench clock.
3. Keep the traces and synthesis report referenced by the final performance
   subsection so the numbers can be reproduced.

For this single-cycle design, CPI is 1 by design. Thus `cycles = executed
instructions` and `execution_time_us = cycles / Fmax_MHz`.

Run from the repository root, replacing the example frequency with the
measured result and using the actual instruction trace:

```sh
python3 report/calculate_performance.py --trace sim/program_b_trace.csv --single-fmax-mhz 50
```

The calculator also uses the guide's **estimated** multi-cycle costs:
R-type/ADDI/SW = 4 cycles, branches = 3, LW = 5. An optional
`--multi-fmax-mhz` supplies a separately stated assumed baseline clock.
Compare execution times at their respective frequencies; fewer cycles alone
do not establish higher speed.

## Playbook example, not a current measurement

```sh
python3 report/calculate_performance.py --guide-example --single-fmax-mhz 50 --multi-fmax-mhz 200
```

The guide's Program B mix is 8 ADDI + 5 ADD + 5 BNE + 1 SW:
19 single-cycle cycles versus 71 estimated multi-cycle cycles (CPI ≈ 3.737).
At the illustrative 50 MHz and 200 MHz clocks, the corresponding times
are 0.380 us and 0.355 us. The single-cycle design is therefore slower in
this example. Equal execution time requires the multi-cycle frequency to
be about 3.737 times the single-cycle frequency.

The guide lists Program A as 12 instructions and Program B as 19; confirm
both from the eventual simulation. No such CPU results have been verified
in this checkout. Fill the final report table only after collecting them:

| Metric | Program A | Program B | Evidence |
|---|---|---|---|
| Executed instructions | Pending | Pending | Retired-instruction trace |
| CPI | 1 by design | 1 by design | Single-cycle architecture |
| Clock cycles | Pending | Pending | Trace, excluding reset/halt |
| Fmax | Pending | Pending | Member 1's Vivado timing report |
| Execution time | Pending | Pending | Cycles / measured Fmax |
| Multi-cycle comparison | Estimate pending inputs | Estimate pending inputs | Explicit cycle/frequency assumptions |
