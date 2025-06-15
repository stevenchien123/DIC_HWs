`timescale 1ns/10ps

module SRAM #(
	parameter Width = 16,
	parameter Row   = 4096
)(
	input				     		clk		, 
	input 							SRAM_ceb,  
	input 		 [$clog2(Row)-1:0]	SRAM_A 	, 
	input 		 [Width-1:0] 		SRAM_D 	,
	input 					 		SRAM_web,
	output logic [Width-1:0] 		SRAM_Q  
);

logic [Width-1:0] SRAM_M [0:Row-1];
integer i;

initial begin
	for (i=0; i<Row; i=i+1) SRAM_M[i] = 0;
end

always @(negedge clk) begin
	if (SRAM_ceb) begin
		if(~SRAM_web)
			SRAM_M[SRAM_A] <= SRAM_D;
		else 
			SRAM_Q <= SRAM_M[SRAM_A];
	end
end
	
endmodule