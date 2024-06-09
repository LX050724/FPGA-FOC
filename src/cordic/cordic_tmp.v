//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.03
//Part Number: GW5A-LV25MG121NES
//Device: GW5A-25
//Device Version: A
//Created Time: Sat Jun  8 15:55:02 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	CORDIC_Top your_instance_name(
		.clk(clk), //input clk
		.rst(rst), //input rst
		.x_i(x_i), //input [16:0] x_i
		.y_i(y_i), //input [16:0] y_i
		.theta_i(theta_i), //input [16:0] theta_i
		.x_o(x_o), //output [16:0] x_o
		.y_o(y_o), //output [16:0] y_o
		.theta_o(theta_o) //output [16:0] theta_o
	);

//--------Copy end-------------------
