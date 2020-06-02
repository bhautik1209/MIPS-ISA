`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// College: 		San Jose State University
// Team Members:	Bhautik Patel, Ankita Moholkar, Jaimil Patel 		
// 
// Create Date:   19:06:30 04/15/2020 
// Design Name: 	MIPS ISA INSTRUCTIONS
// Module Name:   Testbench 
// 
// Revision:		version 2 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module testbench_main_2;

	reg clock;
	reg reset;


	main_2 uut (.clock(clock), .reset(reset));

	always #5 clock = ~clock;
	
	initial begin
		clock = 0;
		reset = 1;

		#100;
		reset = 0;
		#1000;
		$finish;
		
	end
      
endmodule

