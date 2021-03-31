#!/bin/bash

# tb=prince_axis_tb
tb=tb_prince_top

gtkwave --dump=${tb}.vcd -a ${tb}.sav
