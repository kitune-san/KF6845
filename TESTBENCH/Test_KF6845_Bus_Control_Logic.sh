#!/bin/sh

iverilog -o tb.vvp KF6845_Bus_Control_Logic_tb.sv ../HDL/KF6845_Bus_Control_Logic.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

