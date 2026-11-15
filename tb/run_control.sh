#!/bin/sh
# Run from any directory; all generated files stay in the ignored sim/ folder.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
command -v iverilog >/dev/null 2>&1 || { echo 'Install Icarus Verilog (iverilog and vvp) first.' >&2; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo 'vvp is missing from PATH.' >&2; exit 1; }
mkdir -p "$repo_dir/sim"
cd "$repo_dir/sim"
iverilog -g2005 -Wall -s tb_control -o control_sim ../tb/tb_control.v ../rtl/control.v
vvp control_sim > control_test.log 2>&1 || { cat control_test.log; exit 1; }
cat control_test.log
