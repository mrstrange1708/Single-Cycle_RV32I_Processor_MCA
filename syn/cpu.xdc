# Timing constraint (Member 1): ask Vivado to meet a 10 ns (100 MHz) clock.
# Vivado then reports WNS (worst negative slack): how much faster or slower
# the real critical path is than 10 ns.
create_clock -name clk -period 10.000 [get_ports clk]
