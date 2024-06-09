//Copyright (C)2014-2024 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.03 
//Created Time: 2024-06-08 16:58:03
create_clock -name osc_in -period 20 -waveform {0 10} [get_ports {clk_in}]
