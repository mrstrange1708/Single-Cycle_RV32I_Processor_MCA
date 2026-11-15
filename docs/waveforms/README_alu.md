# Member 2 ALU waveform evidence

`alu.png` is a capture of the native GTKWave window displaying the generated
`sim/alu.vcd`. `alu.gtkw` and `alu.rc` preserve the signal selection, radix,
marker, and zoom without committing local absolute paths.

Recreate the trace and open the view from the repository root:

```sh
./tb/run_alu.sh
gtkwave sim/alu.vcd docs/waveforms/alu.gtkw docs/waveforms/alu.rc
```

The trace's timescale is 1 ps; the examples below are expressed in ns.
The first seven vectors are the playbook's required examples:

| Time interval | Operation | a | b | Result (hex) | zero |
|---|---|---|---|---|---|
| 0–10 ns | ADD | 5 | 3 | 00000008 | 0 |
| 10–20 ns | SUB | 5 | 3 | 00000002 | 0 |
| 20–30 ns | SUB | 3 | 5 | fffffffe | 0 |
| 30–40 ns | AND | 5 | 3 | 00000001 | 0 |
| 40–50 ns | OR | 5 | 3 | 00000007 | 0 |
| 50–60 ns | XOR | 5 | 3 | 00000006 | 0 |
| 60–70 ns | SUB | 7 | 7 | 00000000 | 1 |

The marker at 65 ns selects the equal-input subtraction. Bus results use
hexadecimal; `alu_ctrl` uses binary. The testbench goes on to complete all
542 vectors with zero failures. A 10 ns vector interval is testbench stimulus
spacing, not a measured hardware clock period or ALU propagation delay.
