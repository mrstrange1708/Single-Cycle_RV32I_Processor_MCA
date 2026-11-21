# Vivado batch synthesis + implementation (Member 1).
# Run from the syn/ folder:  vivado -mode batch -source run_vivado.tcl
# Part: Artix-7 xc7a35t (the chip on Basys 3 / Arty A7 boards).
file copy -force ../programs/test_all.hex program.hex
read_verilog [glob ../rtl/*.v]
read_xdc cpu.xdc
synth_design -top cpu -part xc7a35tcpg236-1
opt_design
place_design
route_design
report_utilization    -file utilization.rpt
report_timing_summary -file timing_summary.rpt
report_timing -max_paths 1 -path_type full -file critical_path.rpt
puts "Done. Open utilization.rpt, timing_summary.rpt and critical_path.rpt"
