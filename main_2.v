`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// College: 		San Jose State University
// Team Members:	Bhautik Patel, Ankita Moholkar, Jaimil Patel 		
// 
// Create Date:   19:06:30 04/15/2020 
// Design Name: 	MIPS ISA INSTRUCTIONS
// Module Name:   main_2 
// 
// Revision:		version 2 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////
/* op source1 source2 dest shift_function - 6bit 5bit 5bit 5bit 11bit

dot_product: 

	addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000 

loop: 

	beq $r7 $r0 done ;         // 000010 00111 00000 00000 00000000000 (done)
										// 	2      7     0     0       0 
	lw $r2 0($r3) ;  				// 000011 00010 00011 00000 00000000000
										//   3       2     3     0       0
	lw $r4 0($r5) ;  				// 000011 00100 00101 00000 00000000000
										//  3        4     5       0          0
	mul $r2 $r2 $r4 ;          // 000100 00010 00100 00010 00000000000
										// 4        2     4     2         0
	addu $r1 $r1 $r2 ;         // 000001 00001 00010 00001 00000000000
										// 1        1     2     1        0
	addiu $r3 $r3 #4           // 000101 00011 00011 00000 00000000100
										// 5       3      3     0         4
	addiu $r5 $r5 #4           // 000101 00101 00101 00000 00000000100
										// 5        5     5     0         4       
	addiu $r7 $r7 #-1 			// 000101 00111 00111 00000 00000000001
										//  5      7       7    0        1

j loop                  		// 000111 00000 00000 00000 00000000111 (loop)

done: 

jr $r31

*/

module main_2(	input clock, input reset );

parameter s0 = 8'd0;
parameter s1 = 8'd1;
parameter s2 = 8'd2;
parameter s3 = 8'd3;
parameter s4 = 8'd4;
parameter s5 = 8'd5;
parameter s6 = 8'd6;
parameter s7 = 8'd7;
parameter s8 = 8'd8;
parameter s9 = 8'd9;
parameter s10 = 8'd10;
parameter s11 = 8'd11;
parameter s12 = 8'd12;
parameter s13 = 8'd13;
parameter s14 = 8'd14;
parameter s15 = 8'd15;
parameter s16 = 8'd16;
parameter s17 = 8'd17;
parameter s18 = 8'd18;
parameter s19 = 8'd19;

reg [7:0] state, nstate;
reg [31:0] reg_instruction;

reg [5:0]	op;
reg [4:0]	rd, rdtemp;
reg [31:0]	a, b, atemp;
reg [31:0]	alu_out;
reg [15:0]	immi;

reg [13:0] sign_e;

reg flag_beq;

///////////////////////////////////////////////////// data memory
reg [31:0] data [31:0];
initial begin
	data[0] = 32'b000000_00000_00000_00000_00000000001;
	data[1] = 32'b000000_00000_00000_00000_00000000001;
	data[2] = 32'b000000_00000_00000_00000_00000000001;
	data[3] = 32'b000000_00000_00000_00000_00000000001;
	data[4] = 32'b000000_00000_00000_00000_00000000001;
	data[5] = 32'b000000_00000_00000_00000_00000000001;
	data[6] = 32'b000000_00000_00000_00000_00000000001;
	data[7] = 32'b000000_00000_00000_00000_00000000001;
	data[8] = 32'b000000_00000_00000_00000_00000000001;
	data[9] = 32'b000000_00000_00000_00000_00000000001;
	data[10]= 32'b000000_00000_00000_00000_00000000001;
	data[11] = 32'b000000_00000_00000_00000_00000000001;
	data[12] = 32'b000000_00000_00000_00000_00000000001;
	data[13] = 32'b000000_00000_00000_00000_00000000001;
	data[14] = 32'b000000_00000_00000_00000_00000000001;
	data[15] = 32'b000000_00000_00000_00000_00000000001;
	data[16] = 32'b000000_00000_00000_00000_00000000001;
	data[17] = 32'b000000_00000_00000_00000_00000000001;
	data[18] = 32'b000000_00000_00000_00000_00000000001;
	data[19] = 32'b000000_00000_00000_00000_00000000001;
	data[20] = 32'b000000_00000_00000_00000_00000000001;
	data[21] = 32'b000000_00000_00000_00000_00000000001;
	data[22] = 32'b000000_00000_00000_00000_00000000001;
	data[23] = 32'b000000_00000_00000_00000_00000000001;
	data[24] = 32'b000000_00000_00000_00000_00000000001;
	data[25] = 32'b000000_00000_00000_00000_00000000001;
	data[26] = 32'b000000_00000_00000_00000_00000000001;
	data[27] = 32'b000000_00000_00000_00000_00000000001;
	data[28] = 32'b000000_00000_00000_00000_00000000001;
	data[29] = 32'b000000_00000_00000_00000_00000000001;
	data[30] = 32'b000000_00000_00000_00000_00000000001;
	data[31] = 32'b000000_00000_00000_00000_00000000001;

end



///////////////////////////////////////////////////// given instructions
reg [31:0] memory [31:0];
initial begin
	memory[0] = 32'b000001_00000_00000_00001_00000000000;
	memory[1] = 32'b000010_00111_00000_00000_00000000000;
	memory[2] = 32'b000011_00010_00011_00000_00000000000;
	memory[3] = 32'b000011_00100_00101_00000_00000000000;
	memory[4] = 32'b000100_00010_00100_00010_00000000000;
	memory[5] = 32'b000001_00001_00010_00001_00000000000;
	memory[6] = 32'b000101_00011_00011_00000_00000000100;
	memory[7] = 32'b000101_00101_00101_00000_00000000100;
	memory[8] = 32'b000101_00111_00111_00000_00000000001;
	memory[9] = 32'b000111_00000_00000_00000_00000000111;
	memory[10]= 32'b000000_00000_00000_00000_00000000000;
	memory[11] = 32'b000000_00000_00000_00000_00000000000;
	memory[12] = 32'b000000_00000_00000_00000_00000000000;
	memory[13] = 32'b000000_00000_00000_00000_00000000000;
	memory[14] = 32'b000000_00000_00000_00000_00000000000;
	memory[15] = 32'b000000_00000_00000_00000_00000000000;
	memory[16] = 32'b000000_00000_00000_00000_00000000000;
	memory[17] = 32'b000000_00000_00000_00000_00000000000;
	memory[18] = 32'b000000_00000_00000_00000_00000000000;
	memory[19] = 32'b000000_00000_00000_00000_00000000000;
	memory[20] = 32'b000000_00000_00000_00000_00000000000;
	memory[21] = 32'b000000_00000_00000_00000_00000000000;
	memory[22] = 32'b000000_00000_00000_00000_00000000000;
	memory[23] = 32'b000000_00000_00000_00000_00000000000;
	memory[24] = 32'b000000_00000_00000_00000_00000000000;
	memory[25] = 32'b000000_00000_00000_00000_00000000000;
	memory[26] = 32'b000000_00000_00000_00000_00000000000;
	memory[27] = 32'b000000_00000_00000_00000_00000000000;
	memory[28] = 32'b000000_00000_00000_00000_00000000000;
	memory[29] = 32'b000000_00000_00000_00000_00000000000;
	memory[30] = 32'b000000_00000_00000_00000_00000000000;
	memory[31] = 32'b000000_00000_00000_00000_00000000000;
	
end

//////////////////////////////////////////////////////// MIPS reg
// MIPS registers that stores values.

reg [31:0] register [31:0];

initial begin
	register[0]= 32'b000000_00000_00000_00000_00000000000;
	register[1] = 32'b000000_00000_00000_00000_00000000000;
	register[2] = 32'b000000_00000_00000_00000_00000000000;
	register[3] = 32'b000000_00000_00000_00000_00000000000;
	register[4] = 32'b000000_00000_00000_00000_00000000000;
	register[5] = 32'b000000_00000_00000_00000_00000000000;
	register[6] = 32'b000000_00000_00000_00000_00000000000;
	register[7] = 32'b000000_00000_00000_00000_00000000010;
	register[8] = 32'b000000_00000_00000_00000_00000000000;
	register[9] = 32'b000000_00000_00000_00000_00000000000;
	register[10]= 32'b000000_00000_00000_00000_00000000000;
	register[11] = 32'b000000_00000_00000_00000_00000000000;
	register[12] = 32'b000000_00000_00000_00000_00000000000;
	register[13] = 32'b000000_00000_00000_00000_00000000000;
	register[14] = 32'b000000_00000_00000_00000_00000000000;
	register[15] = 32'b000000_00000_00000_00000_00000000000;
	register[16] = 32'b000000_00000_00000_00000_00000000000;
	register[17] = 32'b000000_00000_00000_00000_00000000000;
	register[18] = 32'b000000_00000_00000_00000_00000000000;
	register[19] = 32'b000000_00000_00000_00000_00000000000;
	register[20] = 32'b000000_00000_00000_00000_00000000000;
	register[21] = 32'b000000_00000_00000_00000_00000000000;
	register[22] = 32'b000000_00000_00000_00000_00000000000;
	register[23] = 32'b000000_00000_00000_00000_00000000000;
	register[24] = 32'b000000_00000_00000_00000_00000000000;
	register[25] = 32'b000000_00000_00000_00000_00000000000;
	register[26] = 32'b000000_00000_00000_00000_00000000000;
	register[27] = 32'b000000_00000_00000_00000_00000000000;
	register[28] = 32'b000000_00000_00000_00000_00000000000;
	register[29] = 32'b000000_00000_00000_00000_00000000000;
	register[30] = 32'b000000_00000_00000_00000_00000000000;
	register[31] = 32'b000000_00000_00000_00000_00000000000;
end


always @ (posedge clock or posedge reset)
begin
	if(reset)
	begin
		state <= s0;
		flag_beq <= 1'b0;
		register[0] <= 32'd0;
	end
	else
	begin

		state <= nstate;
	end
end


always @ (state)
begin

	case(state)
		s0:
		begin
			//fetch addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000
			reg_instruction = memory[0];
			nstate = s1;
			//$display();
		end
		
		s1:
		begin
			if(flag_beq == 1'b0)
			begin
				//Decode addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000
				op = reg_instruction[31:26];
				a = register[reg_instruction[25:21]];
				b = register[reg_instruction[20:16]];
				rd = reg_instruction[15:11];
			end
			else
			begin
				//do nothing
			end
			//fetch beq $r7 $r0 done ;   // 000010 00111 00000 00000 00000000110 (done)
			reg_instruction = memory[1];
			
			nstate = s2;
		end
		
		s2:
		begin
			if(flag_beq == 1'b0)
			begin
				//execute addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000
				alu_out = b + a;
				rdtemp = rd;
			end
			else
			begin
				//do nothing
			end
			
			//Decode beq $r7 $r0 done ;   // 000010 00111 00000 00000 00000000110 (done)
			op = reg_instruction[31:26];
			a = register[reg_instruction[25:21]];
			b = register[reg_instruction[20:16]];
			rd = reg_instruction[15:11];
		
			//stall
			
			nstate = s3;
		end
	
		s3:
		begin
			if(flag_beq == 1'b0)
			begin
				//memory state addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000
				register[rdtemp] = alu_out;
				$display("addu $r1 $r0 $r0:	r1 = %b, %d",register[rdtemp],register[rdtemp]);
				//$display("%d",rdtemp);
			end
			else
			begin
				//do nothing 
			end

			//execute beq $r7 $r0 done ;   // 000010 00111 00000 00000 00000000110 (done)
			if(a == b)
			begin
				//jump to done label
				nstate = s18;
				//set some flag to 1
			end
			
			else
			begin
				//fetch lw $r2 0($r3) ;  			// // 000011 00010 00011 00000 00000000000
				reg_instruction = memory[2];
				
				nstate = s4;
			end
		end
			
		s4:
		begin
			//writeback addu $r1 $r0 $r0 ;	// 000001 00000 00000 00001 00000000000
			
			//memory beq $r7 $r0 done ;   	// 000010 00111 00000 00000 00000000110 (done)
			//$display("HERE: %b",reg_instruction);
			//decode lw $r2 0($r3) ;  			// 000011 00010 00011 00000 00000000000
			op = reg_instruction[31:26];
			a = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0];
			
			//fetch lw $r4 0($r5) ;  		// 000011 00100 00101 00000 00000000000
			reg_instruction = memory[3];
			
				
			nstate = s5;
			
		end
		
		s5:
		begin
			//writeback
			
			//execute lw $r2 0($r3) ;  			// 000011 00010 00011 00000 00000000000
			alu_out = b + {immi[15] ? 14'b11_1111_1111_1111 : 14'b0000_0000_0000_0000, immi};
			atemp   = a;
			
			//decode lw $r4 0($r5) ;  		// 000011 00100 00101 00000 00000000000
			op = reg_instruction[31:26];
			a = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0];
			
			nstate = s6;
			
		end
		
		s6:
		begin
			//memory lw $r2 0($r3) ;  			// 000011 00010 00011 00000 00000000000
			//$display("%d", alu_out);
			register[atemp] = data[alu_out];
			$display("lw $r2 0($r3):		r2 = %b, %d",register[atemp],register[atemp]);
			//$display("%d",atemp);
			
			//execute lw $r4 0($r5) ;  		// 000011 00100 00101 00000 00000000000
			alu_out = b + {immi[15] ? 14'b11_1111_1111_1111 : 14'b0000_0000_0000_0000, immi};
			atemp   = a;
			
			nstate = s7;
			
		end
		
		s7:
		begin
			//writeback lw $r2 0($r3) ;  			// 000011 00010 00011 00000 00000000000
			
			//memory lw $r4 0($r5) ;  		// 000011 00100 00101 00000 00000000000
			//$display("%d", alu_out);
			register[atemp] = data[alu_out];
			$display("lw $r4 0($r5):		r4 = %b, %d",register[atemp],register[atemp]);
			//$display("%d",atemp);
			
			nstate = s8;
			
		end
		
		s8:
		begin
			//writeback lw $r4 0($r5) ;  		// 000011 00101 00100 00000 00000000000
			
			//fetch mul $r2 $r2 $r4 ;    // 000100 00010 00100 00010 00000000000
			reg_instruction = memory[4];
			
			nstate = s9;
		end
		
		s9:
		begin
			//decode mul $r2 $r2 $r4 ;    // 000100 00010 00100 00010 00000000000
			op = reg_instruction[31:26];
			a = register[reg_instruction[25:21]];
			b = register[reg_instruction[20:16]];
			rd = reg_instruction[15:11];
			
			nstate = s10;
		end
		
		s10:
		begin
			//execute mul $r2 $r2 $r4 ;    // 000100 00010 00100 00010 00000000000
			alu_out = a * b;
			rdtemp = rd;
			
			nstate = s11;
		end
		
		s11:
		begin
			//memory mul $r2 $r2 $r4 ;    // 000100 00010 00100 00010 00000000000
			register[rdtemp] = alu_out;
			$display("mul $r2 $r2 $r4: 	r2 = %b, %d",register[rdtemp],register[rdtemp]);
			//$display("%d",rdtemp);
			
			//fetch addu $r1 $r1 $r2 ;   // 000001 00001 00010 00001 00000000000
			reg_instruction = memory[5];
			
			nstate = s12;
		end
		
		s12:
		begin
			//writeback mul $r2 $r2 $r4 ;    // 000100 00010 00100 00010 00000000000
			
			//decode addu $r1 $r1 $r2 ;   // 000001 00001 00010 00001 00000000000
			op = reg_instruction[31:26];
			a = register[reg_instruction[25:21]];
			b = register[reg_instruction[20:16]];
			rd = reg_instruction[15:11];
			
			//fetch 	addiu $r3 $r3 #4 		// 000101 00011 00011 00000 00000000100
			reg_instruction = memory[6];

			nstate = s13;
		end
		
		s13:
		begin
			//execute addu $r1 $r1 $r2 ;   // 000001 00001 00010 00001 00000000000
			alu_out = a + b;
			rdtemp = rd;
			
			//decode addiu $r3 $r3 #4 		// 000101 00011 00011 00000 00000000100
			op = reg_instruction[31:26];
			rd = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0];
			
			//fetch addiu $r5 $r5 #4 		// 000101 00101 00101 00000 00000000100
			reg_instruction = memory[7];
			
			nstate = s14;
		end
		
		s14:
		begin
			//memory addu $r1 $r1 $r2 ;   // 000001 00001 00010 00001 00000000000
			register[rdtemp] = alu_out;
			$display("addu $r1 $r1 $r2:	r1 = %b, %d",register[rdtemp],register[rdtemp]);
			//$display("%d",rdtemp);
			
			//execute addiu $r3 $r3 #4 		// 000101 00011 00011 00000 00000000100
			alu_out = b + {immi[15] ? 14'b11_1111_1111_1111 : 14'b0000_0000_0000_0000, immi};
			rdtemp = rd;
			
			//decode addiu $r5 $r5 #4 		// 000101 00101 00101 00000 00000000100
			op = reg_instruction[31:26];
			rd = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0];
			
			//fetch 	addiu $r7 $r7 #-1 	// 000101 00111 00111 00000 10000000001 (1 means negative)
			reg_instruction = memory[8];

			nstate = s15;
		end
		
		s15:
		begin
			//writeback addu $r1 $r1 $r2 ;   // 000001 00001 00010 00001 00000000000
			
			//memory addiu $r3 $r3 #4 		// 000101 00011 00011 00000 00000000100
			register[rdtemp] = alu_out;
			$display("addiu $r3 $r3 #4:	r3 = %b, %d",register[rdtemp],register[rdtemp]);
			//$display("%d",rdtemp);
			
			//execute addiu $r5 $r5 #4 		// 000101 00101 00101 00000 00000000100
			alu_out = b + {immi[15] ? 14'b11_1111_1111_1111 : 14'b0000_0000_0000_0000, immi};
			rdtemp = rd;
			
			//decode addiu $r7 $r7 #-1 	// 000101 00111 00111 00000 10000000001 (1 means negative)
			op = reg_instruction[31:26];
			rd = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0]; //value should be one because we are subtracting (hardcoded)
			
			//fetch j loop                  // 000111 00000 00000 00000 00000000111 (loop)
			reg_instruction = memory[9];
			
			nstate = s16;
		end
		
		s16:
		begin
			//writeback addiu $r3 $r3 #4 		// 000101 00011 00011 00000 00000000100
			
			//memory addiu $r5 $r5 #4 		// 000101 00101 00101 00000 00000000100
			register[rdtemp] = alu_out;
			$display("addiu $r5 $r5 #4:	r5 = %b, %d",register[rdtemp],register[rdtemp]);
			//$display("%d",rdtemp);
			
			//execute addiu $r7 $r7 #-1 	// 000101 00111 00111 00000 10000000001 (1 means negative)
			sign_e = immi[15] ? 14'b11_1111_1111_1111 : 14'b0000_0000_0000_0000;
			alu_out = b - {sign_e , immi};
			rdtemp = rd;
			
			//decode j loop                  // 000111 00000 00000 00000 00000000111 (loop)
			op = reg_instruction[31:26];
			rd = reg_instruction[25:21];
			b = register[reg_instruction[20:16]];
			immi = reg_instruction[15:0];
			
			nstate = s17;
		end
		
		s17:
		begin
			//writeback addiu $r5 $r5 #4 		// 000101 00101 00101 00000 00000000100
			
			//memory addiu $r7 $r7 #-1 	// 000101 00111 00111 00000 10000000001 (1 means negative)
			register[rdtemp] = alu_out;
			$display("addiu $r7 $r7 #-1:	r7 = %b, %d",register[rdtemp],register[rdtemp]);
			//$display("%d",rdtemp);
			
			//execute j loop                  // 000111 00000 00000 00000 00000000111 (loop)
			flag_beq = 1'b1;
			op = 32'd0;
			a = 32'd0;
			b = 32'd0;
			rd = 32'd0;
			alu_out = 32'd0;;
			rdtemp = 32'd0;
			$display("       -------------------------------------              ");
			
			nstate = s1;
		end
		
		s18:
		begin
			$display("Execution Finished. Done Label");
/*			$display("Register: ");
			$display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",register[0] 
																		,register[1] 
																		,register[2] 
																		,register[3] 
																		,register[4] 
																		,register[5] 
																		,register[6] 
																		,register[7] 
																		,register[8] 
																		,register[9] 
																		,register[10]
																		,register[11]
																		,register[12]
																		,register[13]
																		,register[14]
																		,register[15]
																		,register[16]);
			$display("      ");
			$display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",register[17]
																	,register[18]
																	,register[19]
																	,register[20]
																	,register[21]
																	,register[22]
																	,register[23]
																	,register[24]
																	,register[25]
																	,register[26]
																	,register[27]
																	,register[28]
																	,register[29]
																	,register[30]
																	,register[31]);
*/			
			nstate = s19;
		end
		
		s19:
		begin
			nstate =s19;
			$display("   ");
			$display("Result= %b , or %d  ", register[1], register[1]);
			//jr $31
		end
		
		//default:
	endcase
	
end


endmodule
