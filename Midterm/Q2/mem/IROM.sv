`timescale 1ns/10ps

module IROM #(
	parameter Width = 8 ,
	parameter Row   = 64
)(
	input 							IROM_rd	 ,
	input  		 [$clog2(Row)-1:0]	IROM_addr, 
	input 							clk		 , 
	input 							rst		 ,
	output logic [Width-1:0] 	    IROM_data
);

string data_path = "./dat";
logic [Width-1:0] sti_M [0:Row-1];
integer i;

initial begin
	$value$plusargs("data_path=%s", data_path);
	@ (negedge rst) $readmemb ({data_path, "/image1.dat"} , sti_M);
end

always@(negedge clk) 
	if (IROM_rd) IROM_data <= sti_M[IROM_addr];
	
endmodule