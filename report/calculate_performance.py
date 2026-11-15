#!/usr/bin/env python3
"""Member 2: calculate performance from a retired-instruction trace and Fmax.

Trace CSV: pc,mnemonic, with one row per executed instruction. A trace must
exclude reset/idle cycles and the terminal self-loop used as a halt marker.
The --guide-example switch uses the playbook's unverified Program B mix.
"""
import argparse
import csv
import json
import math
from collections import Counter
from pathlib import Path

# Explicit textbook estimate; no multi-cycle processor is implemented here.
ESTIMATED_CYCLES = {
    "ADD": 4, "SUB": 4, "AND": 4, "OR": 4, "XOR": 4,
    "ADDI": 4, "LW": 5, "SW": 4, "BEQ": 3, "BNE": 3,
}


def positive_mhz(value):
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise argparse.ArgumentTypeError("frequency must be finite and greater than zero")
    return number


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    inputs = parser.add_mutually_exclusive_group(required=True)
    inputs.add_argument("--trace", type=Path)
    inputs.add_argument("--guide-example", action="store_true")
    parser.add_argument("--single-fmax-mhz", type=positive_mhz, required=True)
    parser.add_argument("--multi-fmax-mhz", type=positive_mhz,
                        help="assumed multi-cycle clock; clearly label it as an estimate")
    args = parser.parse_args()
    if args.guide_example:
        counts = Counter({"ADDI": 8, "ADD": 5, "BNE": 5, "SW": 1})
        evidence = "Unverified playbook Program B mix; frequencies are illustrative inputs"
    else:
        counts = Counter()
        try:
            with args.trace.open(newline="") as stream:
                reader = csv.DictReader(stream)
                if not reader.fieldnames or "mnemonic" not in reader.fieldnames:
                    parser.error("trace requires a mnemonic column")
                for row_number, row in enumerate(reader, 2):
                    mnemonic = (row.get("mnemonic") or "").strip().upper()
                    if mnemonic not in ESTIMATED_CYCLES:
                        parser.error(f"unsupported mnemonic at CSV row {row_number}: {mnemonic!r}")
                    counts[mnemonic] += 1
        except OSError as error:
            parser.error(str(error))
        evidence = str(args.trace)
    instructions = sum(counts.values())
    if instructions == 0:
        parser.error("trace contains no executed instructions")
    baseline_cycles = sum(counts[name] * ESTIMATED_CYCLES[name] for name in counts)
    single_time_us = instructions / args.single_fmax_mhz
    results = {
        "instruction_source": evidence,
        "instruction_mix": dict(sorted(counts.items())),
        "instructions_executed": instructions,
        "single_cycle_cpi_by_design": 1,
        "single_cycle_cycles_excluding_reset_and_halt": instructions,
        "single_fmax_mhz_input": args.single_fmax_mhz,
        "single_execution_time_us": single_time_us,
        "estimated_multicycle_cycles": baseline_cycles,
        "estimated_multicycle_cpi": baseline_cycles / instructions,
        "equal_time_multi_to_single_frequency_ratio": baseline_cycles / instructions,
    }
    if args.multi_fmax_mhz is not None:
        baseline_time_us = baseline_cycles / args.multi_fmax_mhz
        results.update({
            "assumed_multi_fmax_mhz": args.multi_fmax_mhz,
            "estimated_multicycle_execution_time_us": baseline_time_us,
            "single_speedup_over_estimated_multi": baseline_time_us / single_time_us,
        })
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
