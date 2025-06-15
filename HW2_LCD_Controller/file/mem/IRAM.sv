`timescale 1ns/10ps

module IRAM #(
	parameter Width = 8 ,
	parameter Row   = 64
)(
	input 							IRAM_ceb,  
	input 		 [$clog2(Row)-1:0]	IRAM_A 	, 
	input				     		clk		, 
	input 		 [Width-1:0] 		IRAM_D 	,
	input 					 		IRAM_web,
	output logic [Width-1:0] 		IRAM_Q
);

logic [7:0] IRAM_M [0:63];
integer i;

initial begin
	for (i=0; i<=63; i=i+1) IRAM_M[i] = 0;
end

always@(negedge clk) begin
	if (IRAM_ceb) begin
		if(~IRAM_web)
			IRAM_M[IRAM_A] <= IRAM_D;
		else 
			IRAM_Q <= IRAM_M[IRAM_A];
	end
end
	
endmodule