#!/bin/sh

iverilog -o tb.vvp KF6845_Horizontal_tb.sv ../HDL/KF6845_Horizontal.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

