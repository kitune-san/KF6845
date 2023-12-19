#!/bin/sh

iverilog -o tb.vvp KF6845_Light_Pen_tb.sv ../HDL/KF6845_Light_Pen.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

