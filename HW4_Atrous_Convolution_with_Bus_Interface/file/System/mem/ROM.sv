`timescale 1ns/10ps

module ROM #(
	parameter Width = 16 ,
	parameter Row   = 4096
)(
	input 							clk		 , 
	input 							ROM_rd	 ,
	input  		 [$clog2(Row)-1:0]	ROM_addr , 
	output reg	 [Width-1:0] 	    ROM_data
);

// string data_path = "./dat";
reg [Width-1:0] sti_M [0:Row-1];
integer i;

// initial begin
// 	$value$plusargs("data_path=%s", data_path);
// 	@ (negedge rst) $readmemb ({data_path, "/image1.dat"} , sti_M);
// end

always@(negedge clk) 
	if (ROM_rd) ROM_data <= sti_M[ROM_addr];
	
endmodule