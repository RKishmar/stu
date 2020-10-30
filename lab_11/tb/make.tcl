vlib work

quit -sim

vlog -sv ../rtl/lab_11_if.sv
vlog -sv ../rtl/lab_11.sv
vlog -sv ../rtl/lab_11_top.sv
vlog -sv lab_11_tb.sv
vlog -work work -refresh

vsim -novopt lab_11_tb 

add wave -hex -r lab_11_tb/*

run -all



