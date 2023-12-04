#!/bin/sh

iverilog -o tb.vvp KF6845_Line_Address_tb.sv ../HDL/KF6845_Line_Address.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd

