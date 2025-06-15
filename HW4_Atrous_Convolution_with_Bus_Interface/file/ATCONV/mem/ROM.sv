`timescale 1ns/10ps

module ROM #(
	parameter Width = 16 ,
	parameter Row   = 4096
)(
	input 							clk		 , 
	input 							rst		 ,
	input 							ROM_rd	 ,
	input  		 [$clog2(Row)-1:0]	ROM_addr , 
	output logic [Width-1:0] 	    ROM_data
);

logic [Width-1:0] sti_M [0:Row-1];
integer i;

always@(negedge clk) 
	if (ROM_rd) ROM_data <= sti_M[ROM_addr];
	
endmodule