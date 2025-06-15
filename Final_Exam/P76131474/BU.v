module BU(
	input signed [31:0] a,
	input signed [31:0] b,
	input signed [31:0] c,
	input signed [31:0] d,
	input signed [31:0] W_real,
	input signed [31:0] W_imag,
	
	output signed [31:0] result0_real,
	output signed [31:0] result0_imag,
	output signed [31:0] result1_real,
	output signed [31:0] result1_imag
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

wire [63:0] temp1_real;
wire [63:0] temp1_imag;

assign result0_real = a + c;
assign result0_imag = b + d;

assign temp1_real = ((a-c)*W_real+(d-b)*W_imag);
assign temp1_imag = ((a-c)*W_imag+(b-d)*W_real);
assign result1_real = temp1_real[47:16];
assign result1_imag = temp1_imag[47:16];

endmodule