#!/bin/bash 

tb="tb_prince_top"
# tb="tb"
# tb="prince_axis_tb"

iverilog \
	-I ${PWD} \
	-I ${PWD}/../sim \
	-f list_of_files.txt \
	-N uverilog.cmd \
	-Wtimescale \
	-s ${tb} \
	-o ${tb}

vvp ${tb}

exit
