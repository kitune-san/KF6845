#!/bin/sh

iverilog -o tb.vvp KF6845_Cursor_tb.sv ../HDL/KF6845_Cursor.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

