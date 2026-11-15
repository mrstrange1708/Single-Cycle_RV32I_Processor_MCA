#!/bin/sh
# Owner: Member 5 (Balanagu Srikar) - Memory & Verification
# Run from any directory; all generated files stay in the ignored sim/ folder.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

command -v iverilog >/dev/null 2>&1 || { echo 'Install Icarus Verilog (iverilog and vvp) first.' >&2; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo 'vvp is missing from PATH.' >&2; exit 1; }

cd "$repo_dir/sim"

echo "=================================================="
echo " Running Program A (Full ISA Coverage Test)...     "
echo "=================================================="
cp "$repo_dir/programs/test_all.hex" program.hex
iverilog -g2005 -Wall -s tb_cpu -o cpu_sim ../tb/tb_cpu.v ../rtl/*.v
vvp cpu_sim > cpu_test_a.log 2>&1 || { cat cpu_test_a.log; exit 1; }
cat cpu_test_a.log

echo "=================================================="
echo " Running Program B (Summation Loop Test)...       "
echo "=================================================="
cp "$repo_dir/programs/sum_loop.hex" program.hex
iverilog -g2005 -Wall -s tb_cpu_loop -o cpu_loop_sim ../tb/tb_cpu_loop.v ../rtl/*.v
vvp cpu_loop_sim > cpu_test_b.log 2>&1 || { cat cpu_test_b.log; exit 1; }
cat cpu_test_b.log

# Restore default program.hex to test_all.hex
cp "$repo_dir/programs/test_all.hex" program.hex

if python3 -c "import PIL" >/dev/null 2>&1; then
    python3 "$repo_dir/tb/generate_waveform_png.py"
fi

echo "All CPU tests passed successfully!"
