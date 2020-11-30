#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "350 MHz" -name clk_i [get_ports clk_i]

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


