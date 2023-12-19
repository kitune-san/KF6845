#!/bin/sh

iverilog -o tb.vvp KF6845_Vertical_tb.sv ../HDL/KF6845_Vertical.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

