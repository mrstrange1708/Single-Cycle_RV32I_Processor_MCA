#!/bin/sh
# Run from any directory; all generated files stay in the ignored sim/ folder.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
command -v iverilog >/dev/null 2>&1 || { echo 'Install Icarus Verilog (iverilog and vvp) first.' >&2; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo 'vvp is missing from PATH.' >&2; exit 1; }
cd "$repo_dir/sim"
iverilog -g2005 -Wall -s tb_alu -o alu_sim ../tb/tb_alu.v ../rtl/alu.v
vvp alu_sim > alu_test.log 2>&1 || { cat alu_test.log; exit 1; }
cat alu_test.log
