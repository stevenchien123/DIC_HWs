module  FFT (
	input clk,
	input rst,
	input [15:0] fir_d, 
	input fir_valid, 
	output fftr_valid, 
	output ffti_valid, 
	output done,
	output [15:0] fft_d0, 
 	output [15:0] fft_d1, 
	output [15:0] fft_d2,
	output [15:0] fft_d3,
	output [15:0] fft_d4,
	output [15:0] fft_d5,
	output [15:0] fft_d6,
	output [15:0] fft_d7,
	output [15:0] fft_d8,
 	output [15:0] fft_d9,
	output [15:0] fft_d10,
	output [15:0] fft_d11,
	output [15:0] fft_d12,
	output [15:0] fft_d13,
	output [15:0] fft_d14,
	output [15:0] fft_d15
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

// imag part
parameter signed [31:0] W0_IMAG   = 32'h00000000 ;    //16.16
parameter signed [31:0] W1_IMAG   = 32'hFFFFCE0F ;     
parameter signed [31:0] W2_IMAG   = 32'hFFFF9E09 ;     
parameter signed [31:0] W3_IMAG   = 32'hFFFF71C6 ;     
parameter signed [31:0] W4_IMAG   = 32'hFFFF4AFC ;     
parameter signed [31:0] W5_IMAG   = 32'hFFFF2B25 ;     
parameter signed [31:0] W6_IMAG   = 32'hFFFF137D ;     
parameter signed [31:0] W7_IMAG   = 32'hFFFF04EB ;   
parameter signed [31:0] W8_IMAG   = 32'hFFFF0000 ;     
parameter signed [31:0] W9_IMAG   = 32'hFFFF04EB ;     
parameter signed [31:0] W10_IMAG  = 32'hFFFF137D ;     
parameter signed [31:0] W11_IMAG  = 32'hFFFF2B25 ;     
parameter signed [31:0] W12_IMAG  = 32'hFFFF4AFC ;     
parameter signed [31:0] W13_IMAG  = 32'hFFFF71C6 ;     
parameter signed [31:0] W14_IMAG  = 32'hFFFF9E09 ;  
parameter signed [31:0] W15_IMAG  = 32'hFFFFCE0F ; 

// real part
parameter signed [31:0] W0_REAL   = 32'h00010000 ;    //16.16
parameter signed [31:0] W1_REAL   = 32'h0000FB15 ;
parameter signed [31:0] W2_REAL   = 32'h0000EC83 ;   
parameter signed [31:0] W3_REAL   = 32'h0000D4DB ;
parameter signed [31:0] W4_REAL   = 32'h0000B504 ;    
parameter signed [31:0] W5_REAL   = 32'h00008E3A ;
parameter signed [31:0] W6_REAL   = 32'h000061F7 ;    
parameter signed [31:0] W7_REAL   = 32'h000031F1 ;
parameter signed [31:0] W8_REAL   = 32'h00000000 ;   
parameter signed [31:0] W9_REAL   = 32'hFFFFCE0F ;
parameter signed [31:0] W10_REAL  = 32'hFFFF9E09 ;    
parameter signed [31:0] W11_REAL  = 32'hFFFF71C6 ;
parameter signed [31:0] W12_REAL  = 32'hFFFF4AFC ;     
parameter signed [31:0] W13_REAL  = 32'hFFFF2B25 ;
parameter signed [31:0] W14_REAL  = 32'hFFFF137D ;  
parameter signed [31:0] W15_REAL  = 32'hFFFF04EB ;

reg [2:0]st,nxt;

parameter IDLE=0,READ=1,CAL=2,DONE=3;
integer i;

reg signed [31:0]fir_data[0:31]; // 16.16
reg [4:0]counter;
assign fftr_valid = (st==CAL&&(counter==4||counter==5));
assign ffti_valid = (st==CAL&&(counter==6||counter==7));
assign done=(st==DONE);

// stage 1
wire signed [31:0]s1_real[0:31]; 
wire signed [31:0]s1_imag[0:31];
reg signed [31:0]s1_real_reg[0:31]; 
reg signed [31:0]s1_imag_reg[0:31];

BU S1_0(
	.a(fir_data[0]),
	.b(32'd0),
	.c(fir_data[16]),
	.d(32'd0),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s1_real[0]),
	.result0_imag(s1_imag[0]),
	.result1_real(s1_real[16]),
	.result1_imag(s1_imag[16])
);

BU S1_1(
	.a(fir_data[1]),
	.b(32'd0),
	.c(fir_data[17]),
	.d(32'd0),
	.W_real(W1_REAL),
	.W_imag(W1_IMAG),
	.result0_real(s1_real[1]),
	.result0_imag(s1_imag[1]),
	.result1_real(s1_real[17]),
	.result1_imag(s1_imag[17])
);

BU S1_2(
	.a(fir_data[2]),
	.b(32'd0),
	.c(fir_data[18]),
	.d(32'd0),
	.W_real(W2_REAL),
	.W_imag(W2_IMAG),
	.result0_real(s1_real[2]),
	.result0_imag(s1_imag[2]),
	.result1_real(s1_real[18]),
	.result1_imag(s1_imag[18])
);

BU S1_3(
	.a(fir_data[3]),
	.b(32'd0),
	.c(fir_data[19]),
	.d(32'd0),
	.W_real(W3_REAL),
	.W_imag(W3_IMAG),
	.result0_real(s1_real[3]),
	.result0_imag(s1_imag[3]),
	.result1_real(s1_real[19]),
	.result1_imag(s1_imag[19])
);

BU S1_4(
	.a(fir_data[4]),
	.b(32'd0),
	.c(fir_data[20]),
	.d(32'd0),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s1_real[4]),
	.result0_imag(s1_imag[4]),
	.result1_real(s1_real[20]),
	.result1_imag(s1_imag[20])
);

BU S1_5(
	.a(fir_data[5]),
	.b(32'd0),
	.c(fir_data[21]),
	.d(32'd0),
	.W_real(W5_REAL),
	.W_imag(W5_IMAG),
	.result0_real(s1_real[5]),
	.result0_imag(s1_imag[5]),
	.result1_real(s1_real[21]),
	.result1_imag(s1_imag[21])
);

BU S1_6(
	.a(fir_data[6]),
	.b(32'd0),
	.c(fir_data[22]),
	.d(32'd0),
	.W_real(W6_REAL),
	.W_imag(W6_IMAG),
	.result0_real(s1_real[6]),
	.result0_imag(s1_imag[6]),
	.result1_real(s1_real[22]),
	.result1_imag(s1_imag[22])
);

BU S1_7(
	.a(fir_data[7]),
	.b(32'd0),
	.c(fir_data[23]),
	.d(32'd0),
	.W_real(W7_REAL),
	.W_imag(W7_IMAG),
	.result0_real(s1_real[7]),
	.result0_imag(s1_imag[7]),
	.result1_real(s1_real[23]),
	.result1_imag(s1_imag[23])
);

BU S1_8(
	.a(fir_data[8]),
	.b(32'd0),
	.c(fir_data[24]),
	.d(32'd0),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s1_real[8]),
	.result0_imag(s1_imag[8]),
	.result1_real(s1_real[24]),
	.result1_imag(s1_imag[24])
);

BU S1_9(
	.a(fir_data[9]),
	.b(32'd0),
	.c(fir_data[25]),
	.d(32'd0),
	.W_real(W9_REAL),
	.W_imag(W9_IMAG),
	.result0_real(s1_real[9]),
	.result0_imag(s1_imag[9]),
	.result1_real(s1_real[25]),
	.result1_imag(s1_imag[25])
);

BU S1_10(
	.a(fir_data[10]),
	.b(32'd0),
	.c(fir_data[26]),
	.d(32'd0),
	.W_real(W10_REAL),
	.W_imag(W10_IMAG),
	.result0_real(s1_real[10]),
	.result0_imag(s1_imag[10]),
	.result1_real(s1_real[26]),
	.result1_imag(s1_imag[26])
);

BU S1_11(
	.a(fir_data[11]),
	.b(32'd0),
	.c(fir_data[27]),
	.d(32'd0),
	.W_real(W11_REAL),
	.W_imag(W11_IMAG),
	.result0_real(s1_real[11]),
	.result0_imag(s1_imag[11]),
	.result1_real(s1_real[27]),
	.result1_imag(s1_imag[27])
);

BU S1_12(
	.a(fir_data[12]),
	.b(32'd0),
	.c(fir_data[28]),
	.d(32'd0),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s1_real[12]),
	.result0_imag(s1_imag[12]),
	.result1_real(s1_real[28]),
	.result1_imag(s1_imag[28])
);

BU S1_13(
	.a(fir_data[13]),
	.b(32'd0),
	.c(fir_data[29]),
	.d(32'd0),
	.W_real(W13_REAL),
	.W_imag(W13_IMAG),
	.result0_real(s1_real[13]),
	.result0_imag(s1_imag[13]),
	.result1_real(s1_real[29]),
	.result1_imag(s1_imag[29])
);

BU S1_14(
	.a(fir_data[14]),
	.b(32'd0),
	.c(fir_data[30]),
	.d(32'd0),
	.W_real(W14_REAL),
	.W_imag(W14_IMAG),
	.result0_real(s1_real[14]),
	.result0_imag(s1_imag[14]),
	.result1_real(s1_real[30]),
	.result1_imag(s1_imag[30])
);

BU S1_15(
	.a(fir_data[15]),
	.b(32'd0),
	.c(fir_data[31]),
	.d(32'd0),
	.W_real(W15_REAL),
	.W_imag(W15_IMAG),
	.result0_real(s1_real[15]),
	.result0_imag(s1_imag[15]),
	.result1_real(s1_real[31]),
	.result1_imag(s1_imag[31])
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			s1_real_reg[i]<=0;
			s1_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<32;i=i+1)begin
			s1_real_reg[i]<=s1_real[i];
			s1_imag_reg[i]<=s1_imag[i];
		end
	end
end

// stage 2
wire signed [31:0]s2_real[0:31]; 
wire signed [31:0]s2_imag[0:31];
reg signed [31:0]s2_real_reg[0:31]; 
reg signed [31:0]s2_imag_reg[0:31];

BU S2_0(
	.a(s1_real_reg[0]),
	.b(s1_imag_reg[0]),
	.c(s1_real_reg[8]),
	.d(s1_imag_reg[8]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s2_real[0]),
	.result0_imag(s2_imag[0]),
	.result1_real(s2_real[8]),
	.result1_imag(s2_imag[8])
);

BU S2_1(
	.a(s1_real_reg[1]),
	.b(s1_imag_reg[1]),
	.c(s1_real_reg[9]),
	.d(s1_imag_reg[9]),
	.W_real(W2_REAL),
	.W_imag(W2_IMAG),
	.result0_real(s2_real[1]),
	.result0_imag(s2_imag[1]),
	.result1_real(s2_real[9]),
	.result1_imag(s2_imag[9])
);
BU S2_2(
	.a(s1_real_reg[2]),
	.b(s1_imag_reg[2]),
	.c(s1_real_reg[10]),
	.d(s1_imag_reg[10]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s2_real[2]),
	.result0_imag(s2_imag[2]),
	.result1_real(s2_real[10]),
	.result1_imag(s2_imag[10])
);
BU S2_3(
	.a(s1_real_reg[3]),
	.b(s1_imag_reg[3]),
	.c(s1_real_reg[11]),
	.d(s1_imag_reg[11]),
	.W_real(W6_REAL),
	.W_imag(W6_IMAG),
	.result0_real(s2_real[3]),
	.result0_imag(s2_imag[3]),
	.result1_real(s2_real[11]),
	.result1_imag(s2_imag[11])
);
BU S2_4(
	.a(s1_real_reg[4]),
	.b(s1_imag_reg[4]),
	.c(s1_real_reg[12]),
	.d(s1_imag_reg[12]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s2_real[4]),
	.result0_imag(s2_imag[4]),
	.result1_real(s2_real[12]),
	.result1_imag(s2_imag[12])
);
BU S2_5(
	.a(s1_real_reg[5]),
	.b(s1_imag_reg[5]),
	.c(s1_real_reg[13]),
	.d(s1_imag_reg[13]),
	.W_real(W10_REAL),
	.W_imag(W10_IMAG),
	.result0_real(s2_real[5]),
	.result0_imag(s2_imag[5]),
	.result1_real(s2_real[13]),
	.result1_imag(s2_imag[13])
);
BU S2_6(
	.a(s1_real_reg[6]),
	.b(s1_imag_reg[6]),
	.c(s1_real_reg[14]),
	.d(s1_imag_reg[14]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s2_real[6]),
	.result0_imag(s2_imag[6]),
	.result1_real(s2_real[14]),
	.result1_imag(s2_imag[14])
);
BU S2_7(
	.a(s1_real_reg[7]),
	.b(s1_imag_reg[7]),
	.c(s1_real_reg[15]),
	.d(s1_imag_reg[15]),
	.W_real(W14_REAL),
	.W_imag(W14_IMAG),
	.result0_real(s2_real[7]),
	.result0_imag(s2_imag[7]),
	.result1_real(s2_real[15]),
	.result1_imag(s2_imag[15])
);
BU S2_8(
	.a(s1_real_reg[16]),
	.b(s1_imag_reg[16]),
	.c(s1_real_reg[24]),
	.d(s1_imag_reg[24]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s2_real[16]),
	.result0_imag(s2_imag[16]),
	.result1_real(s2_real[24]),
	.result1_imag(s2_imag[24])
);
BU S2_9(
	.a(s1_real_reg[17]),
	.b(s1_imag_reg[17]),
	.c(s1_real_reg[25]),
	.d(s1_imag_reg[25]),
	.W_real(W2_REAL),
	.W_imag(W2_IMAG),
	.result0_real(s2_real[17]),
	.result0_imag(s2_imag[17]),
	.result1_real(s2_real[25]),
	.result1_imag(s2_imag[25])
);
BU S2_10(
	.a(s1_real_reg[18]),
	.b(s1_imag_reg[18]),
	.c(s1_real_reg[26]),
	.d(s1_imag_reg[26]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s2_real[18]),
	.result0_imag(s2_imag[18]),
	.result1_real(s2_real[26]),
	.result1_imag(s2_imag[26])
);
BU S2_11(
	.a(s1_real_reg[19]),
	.b(s1_imag_reg[19]),
	.c(s1_real_reg[27]),
	.d(s1_imag_reg[27]),
	.W_real(W6_REAL),
	.W_imag(W6_IMAG),
	.result0_real(s2_real[19]),
	.result0_imag(s2_imag[19]),
	.result1_real(s2_real[27]),
	.result1_imag(s2_imag[27])
);
BU S2_12(
	.a(s1_real_reg[20]),
	.b(s1_imag_reg[20]),
	.c(s1_real_reg[28]),
	.d(s1_imag_reg[28]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s2_real[20]),
	.result0_imag(s2_imag[20]),
	.result1_real(s2_real[28]),
	.result1_imag(s2_imag[28])
);
BU S2_13(
	.a(s1_real_reg[21]),
	.b(s1_imag_reg[21]),
	.c(s1_real_reg[29]),
	.d(s1_imag_reg[29]),
	.W_real(W10_REAL),
	.W_imag(W10_IMAG),
	.result0_real(s2_real[21]),
	.result0_imag(s2_imag[21]),
	.result1_real(s2_real[29]),
	.result1_imag(s2_imag[29])
);
BU S2_14(
	.a(s1_real_reg[22]),
	.b(s1_imag_reg[22]),
	.c(s1_real_reg[30]),
	.d(s1_imag_reg[30]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s2_real[22]),
	.result0_imag(s2_imag[22]),
	.result1_real(s2_real[30]),
	.result1_imag(s2_imag[30])
);
BU S2_15(
	.a(s1_real_reg[23]),
	.b(s1_imag_reg[23]),
	.c(s1_real_reg[31]),
	.d(s1_imag_reg[31]),
	.W_real(W14_REAL),
	.W_imag(W14_IMAG),
	.result0_real(s2_real[23]),
	.result0_imag(s2_imag[23]),
	.result1_real(s2_real[31]),
	.result1_imag(s2_imag[31])
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			s2_real_reg[i]<=0;
			s2_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<32;i=i+1)begin
			s2_real_reg[i]<=s2_real[i];
			s2_imag_reg[i]<=s2_imag[i];
		end
	end
end

// stage 3
wire signed [31:0]s3_real[0:31]; 
wire signed [31:0]s3_imag[0:31];
reg signed [31:0]s3_real_reg[0:31]; 
reg signed [31:0]s3_imag_reg[0:31];

BU S3_0(
	.a(s2_real_reg[0]),
	.b(s2_imag_reg[0]),
	.c(s2_real_reg[4]),
	.d(s2_imag_reg[4]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s3_real[0]),
	.result0_imag(s3_imag[0]),
	.result1_real(s3_real[4]),
	.result1_imag(s3_imag[4])
);

BU S3_1(
	.a(s2_real_reg[1]),
	.b(s2_imag_reg[1]),
	.c(s2_real_reg[5]),
	.d(s2_imag_reg[5]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s3_real[1]),
	.result0_imag(s3_imag[1]),
	.result1_real(s3_real[5]),
	.result1_imag(s3_imag[5])
);

BU S3_2(
	.a(s2_real_reg[2]),
	.b(s2_imag_reg[2]),
	.c(s2_real_reg[6]),
	.d(s2_imag_reg[6]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s3_real[2]),
	.result0_imag(s3_imag[2]),
	.result1_real(s3_real[6]),
	.result1_imag(s3_imag[6])
);

BU S3_3(
	.a(s2_real_reg[3]),
	.b(s2_imag_reg[3]),
	.c(s2_real_reg[7]),
	.d(s2_imag_reg[7]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s3_real[3]),
	.result0_imag(s3_imag[3]),
	.result1_real(s3_real[7]),
	.result1_imag(s3_imag[7])
);

BU S3_4(
	.a(s2_real_reg[8]),
	.b(s2_imag_reg[8]),
	.c(s2_real_reg[12]),
	.d(s2_imag_reg[12]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s3_real[8]),
	.result0_imag(s3_imag[8]),
	.result1_real(s3_real[12]),
	.result1_imag(s3_imag[12])
);

BU S3_5(
	.a(s2_real_reg[9]),
	.b(s2_imag_reg[9]),
	.c(s2_real_reg[13]),
	.d(s2_imag_reg[13]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s3_real[9]),
	.result0_imag(s3_imag[9]),
	.result1_real(s3_real[13]),
	.result1_imag(s3_imag[13])
);

BU S3_6(
	.a(s2_real_reg[10]),
	.b(s2_imag_reg[10]),
	.c(s2_real_reg[14]),
	.d(s2_imag_reg[14]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s3_real[10]),
	.result0_imag(s3_imag[10]),
	.result1_real(s3_real[14]),
	.result1_imag(s3_imag[14])
);

BU S3_7(
	.a(s2_real_reg[11]),
	.b(s2_imag_reg[11]),
	.c(s2_real_reg[15]),
	.d(s2_imag_reg[15]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s3_real[11]),
	.result0_imag(s3_imag[11]),
	.result1_real(s3_real[15]),
	.result1_imag(s3_imag[15])
);

BU S3_8(
	.a(s2_real_reg[16]),
	.b(s2_imag_reg[16]),
	.c(s2_real_reg[20]),
	.d(s2_imag_reg[20]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s3_real[16]),
	.result0_imag(s3_imag[16]),
	.result1_real(s3_real[20]),
	.result1_imag(s3_imag[20])
);

BU S3_9(
	.a(s2_real_reg[17]),
	.b(s2_imag_reg[17]),
	.c(s2_real_reg[21]),
	.d(s2_imag_reg[21]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s3_real[17]),
	.result0_imag(s3_imag[17]),
	.result1_real(s3_real[21]),
	.result1_imag(s3_imag[21])
);

BU S3_10(
	.a(s2_real_reg[18]),
	.b(s2_imag_reg[18]),
	.c(s2_real_reg[22]),
	.d(s2_imag_reg[22]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s3_real[18]),
	.result0_imag(s3_imag[18]),
	.result1_real(s3_real[22]),
	.result1_imag(s3_imag[22])
);

BU S3_11(
	.a(s2_real_reg[19]),
	.b(s2_imag_reg[19]),
	.c(s2_real_reg[23]),
	.d(s2_imag_reg[23]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s3_real[19]),
	.result0_imag(s3_imag[19]),
	.result1_real(s3_real[23]),
	.result1_imag(s3_imag[23])
);

BU S3_12(
	.a(s2_real_reg[24]),
	.b(s2_imag_reg[24]),
	.c(s2_real_reg[28]),
	.d(s2_imag_reg[28]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s3_real[24]),
	.result0_imag(s3_imag[24]),
	.result1_real(s3_real[28]),
	.result1_imag(s3_imag[28])
);

BU S3_13(
	.a(s2_real_reg[25]),
	.b(s2_imag_reg[25]),
	.c(s2_real_reg[29]),
	.d(s2_imag_reg[29]),
	.W_real(W4_REAL),
	.W_imag(W4_IMAG),
	.result0_real(s3_real[25]),
	.result0_imag(s3_imag[25]),
	.result1_real(s3_real[29]),
	.result1_imag(s3_imag[29])
);

BU S3_14(
	.a(s2_real_reg[26]),
	.b(s2_imag_reg[26]),
	.c(s2_real_reg[30]),
	.d(s2_imag_reg[30]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s3_real[26]),
	.result0_imag(s3_imag[26]),
	.result1_real(s3_real[30]),
	.result1_imag(s3_imag[30])
);

BU S3_15(
	.a(s2_real_reg[27]),
	.b(s2_imag_reg[27]),
	.c(s2_real_reg[31]),
	.d(s2_imag_reg[31]),
	.W_real(W12_REAL),
	.W_imag(W12_IMAG),
	.result0_real(s3_real[27]),
	.result0_imag(s3_imag[27]),
	.result1_real(s3_real[31]),
	.result1_imag(s3_imag[31])
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			s3_real_reg[i]<=0;
			s3_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<32;i=i+1)begin
			s3_real_reg[i]<=s3_real[i];
			s3_imag_reg[i]<=s3_imag[i];
		end
	end
end

// stage 4
wire signed [31:0]s4_real[0:31]; 
wire signed [31:0]s4_imag[0:31];
reg signed [31:0]s4_real_reg[0:31]; 
reg signed [31:0]s4_imag_reg[0:31];

BU S4_0(
	.a(s3_real_reg[0]),
	.b(s3_imag_reg[0]),
	.c(s3_real_reg[2]),
	.d(s3_imag_reg[2]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[0]),
	.result0_imag(s4_imag[0]),
	.result1_real(s4_real[2]),
	.result1_imag(s4_imag[2])
);

BU S4_1(
	.a(s3_real_reg[1]),
	.b(s3_imag_reg[1]),
	.c(s3_real_reg[3]),
	.d(s3_imag_reg[3]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[1]),
	.result0_imag(s4_imag[1]),
	.result1_real(s4_real[3]),
	.result1_imag(s4_imag[3])
);

BU S4_2(
	.a(s3_real_reg[4]),
	.b(s3_imag_reg[4]),
	.c(s3_real_reg[6]),
	.d(s3_imag_reg[6]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[4]),
	.result0_imag(s4_imag[4]),
	.result1_real(s4_real[6]),
	.result1_imag(s4_imag[6])
);

BU S4_3(
	.a(s3_real_reg[5]),
	.b(s3_imag_reg[5]),
	.c(s3_real_reg[7]),
	.d(s3_imag_reg[7]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[5]),
	.result0_imag(s4_imag[5]),
	.result1_real(s4_real[7]),
	.result1_imag(s4_imag[7])
);

BU S4_4(
	.a(s3_real_reg[8]),
	.b(s3_imag_reg[8]),
	.c(s3_real_reg[10]),
	.d(s3_imag_reg[10]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[8]),
	.result0_imag(s4_imag[8]),
	.result1_real(s4_real[10]),
	.result1_imag(s4_imag[10])
);

BU S4_5(
	.a(s3_real_reg[9]),
	.b(s3_imag_reg[9]),
	.c(s3_real_reg[11]),
	.d(s3_imag_reg[11]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[9]),
	.result0_imag(s4_imag[9]),
	.result1_real(s4_real[11]),
	.result1_imag(s4_imag[11])
);

BU S4_6(
	.a(s3_real_reg[12]),
	.b(s3_imag_reg[12]),
	.c(s3_real_reg[14]),
	.d(s3_imag_reg[14]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[12]),
	.result0_imag(s4_imag[12]),
	.result1_real(s4_real[14]),
	.result1_imag(s4_imag[14])
);

BU S4_7(
	.a(s3_real_reg[13]),
	.b(s3_imag_reg[13]),
	.c(s3_real_reg[15]),
	.d(s3_imag_reg[15]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[13]),
	.result0_imag(s4_imag[13]),
	.result1_real(s4_real[15]),
	.result1_imag(s4_imag[15])
);

BU S4_8(
	.a(s3_real_reg[16]),
	.b(s3_imag_reg[16]),
	.c(s3_real_reg[18]),
	.d(s3_imag_reg[18]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[16]),
	.result0_imag(s4_imag[16]),
	.result1_real(s4_real[18]),
	.result1_imag(s4_imag[18])
);

BU S4_9(
	.a(s3_real_reg[17]),
	.b(s3_imag_reg[17]),
	.c(s3_real_reg[19]),
	.d(s3_imag_reg[19]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[17]),
	.result0_imag(s4_imag[17]),
	.result1_real(s4_real[19]),
	.result1_imag(s4_imag[19])
);

BU S4_10(
	.a(s3_real_reg[20]),
	.b(s3_imag_reg[20]),
	.c(s3_real_reg[22]),
	.d(s3_imag_reg[22]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[20]),
	.result0_imag(s4_imag[20]),
	.result1_real(s4_real[22]),
	.result1_imag(s4_imag[22])
);

BU S4_11(
	.a(s3_real_reg[21]),
	.b(s3_imag_reg[21]),
	.c(s3_real_reg[23]),
	.d(s3_imag_reg[23]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[21]),
	.result0_imag(s4_imag[21]),
	.result1_real(s4_real[23]),
	.result1_imag(s4_imag[23])
);

BU S4_12(
	.a(s3_real_reg[24]),
	.b(s3_imag_reg[24]),
	.c(s3_real_reg[26]),
	.d(s3_imag_reg[26]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[24]),
	.result0_imag(s4_imag[24]),
	.result1_real(s4_real[26]),
	.result1_imag(s4_imag[26])
);

BU S4_13(
	.a(s3_real_reg[25]),
	.b(s3_imag_reg[25]),
	.c(s3_real_reg[27]),
	.d(s3_imag_reg[27]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[25]),
	.result0_imag(s4_imag[25]),
	.result1_real(s4_real[27]),
	.result1_imag(s4_imag[27])
);

BU S4_14(
	.a(s3_real_reg[28]),
	.b(s3_imag_reg[28]),
	.c(s3_real_reg[30]),
	.d(s3_imag_reg[30]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s4_real[28]),
	.result0_imag(s4_imag[28]),
	.result1_real(s4_real[30]),
	.result1_imag(s4_imag[30])
);

BU S4_15(
	.a(s3_real_reg[29]),
	.b(s3_imag_reg[29]),
	.c(s3_real_reg[31]),
	.d(s3_imag_reg[31]),
	.W_real(W8_REAL),
	.W_imag(W8_IMAG),
	.result0_real(s4_real[29]),
	.result0_imag(s4_imag[29]),
	.result1_real(s4_real[31]),
	.result1_imag(s4_imag[31])
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			s4_real_reg[i]<=0;
			s4_imag_reg[i]<=0;
		end
	end
	else if(st==CAL)begin
		for(i=0;i<32;i=i+1)begin
			s4_real_reg[i]<=s4_real[i];
			s4_imag_reg[i]<=s4_imag[i];
		end
	end
end

// stage 5
wire signed [31:0]s5_real[0:31]; 
wire signed [31:0]s5_imag[0:31];
reg signed [31:0]s5_real_reg[0:31]; 
reg signed [31:0]s5_imag_reg[0:31];

BU S5_0(
	.a(s4_real_reg[0]),
	.b(s4_imag_reg[0]),
	.c(s4_real_reg[1]),
	.d(s4_imag_reg[1]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[0]),
	.result0_imag(s5_imag[0]),
	.result1_real(s5_real[1]),
	.result1_imag(s5_imag[1])
);

BU S5_1(
	.a(s4_real_reg[2]),
	.b(s4_imag_reg[2]),
	.c(s4_real_reg[3]),
	.d(s4_imag_reg[3]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[2]),
	.result0_imag(s5_imag[2]),
	.result1_real(s5_real[3]),
	.result1_imag(s5_imag[3])
);

BU S5_2(
	.a(s4_real_reg[4]),
	.b(s4_imag_reg[4]),
	.c(s4_real_reg[5]),
	.d(s4_imag_reg[5]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[4]),
	.result0_imag(s5_imag[4]),
	.result1_real(s5_real[5]),
	.result1_imag(s5_imag[5])
);

BU S5_3(
	.a(s4_real_reg[6]),
	.b(s4_imag_reg[6]),
	.c(s4_real_reg[7]),
	.d(s4_imag_reg[7]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[6]),
	.result0_imag(s5_imag[6]),
	.result1_real(s5_real[7]),
	.result1_imag(s5_imag[7])
);

BU S5_4(
	.a(s4_real_reg[8]),
	.b(s4_imag_reg[8]),
	.c(s4_real_reg[9]),
	.d(s4_imag_reg[9]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[8]),
	.result0_imag(s5_imag[8]),
	.result1_real(s5_real[9]),
	.result1_imag(s5_imag[9])
);

BU S5_5(
	.a(s4_real_reg[10]),
	.b(s4_imag_reg[10]),
	.c(s4_real_reg[11]),
	.d(s4_imag_reg[11]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[10]),
	.result0_imag(s5_imag[10]),
	.result1_real(s5_real[11]),
	.result1_imag(s5_imag[11])
);

BU S5_6(
	.a(s4_real_reg[12]),
	.b(s4_imag_reg[12]),
	.c(s4_real_reg[13]),
	.d(s4_imag_reg[13]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[12]),
	.result0_imag(s5_imag[12]),
	.result1_real(s5_real[13]),
	.result1_imag(s5_imag[13])
);

BU S5_7(
	.a(s4_real_reg[14]),
	.b(s4_imag_reg[14]),
	.c(s4_real_reg[15]),
	.d(s4_imag_reg[15]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[14]),
	.result0_imag(s5_imag[14]),
	.result1_real(s5_real[15]),
	.result1_imag(s5_imag[15])
);

BU S5_8(
	.a(s4_real_reg[16]),
	.b(s4_imag_reg[16]),
	.c(s4_real_reg[17]),
	.d(s4_imag_reg[17]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[16]),
	.result0_imag(s5_imag[16]),
	.result1_real(s5_real[17]),
	.result1_imag(s5_imag[17])
);

BU S5_9(
	.a(s4_real_reg[18]),
	.b(s4_imag_reg[18]),
	.c(s4_real_reg[19]),
	.d(s4_imag_reg[19]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[18]),
	.result0_imag(s5_imag[18]),
	.result1_real(s5_real[19]),
	.result1_imag(s5_imag[19])
);

BU S5_10(
	.a(s4_real_reg[20]),
	.b(s4_imag_reg[20]),
	.c(s4_real_reg[21]),
	.d(s4_imag_reg[21]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[20]),
	.result0_imag(s5_imag[20]),
	.result1_real(s5_real[21]),
	.result1_imag(s5_imag[21])
);

BU S5_11(
	.a(s4_real_reg[22]),
	.b(s4_imag_reg[22]),
	.c(s4_real_reg[23]),
	.d(s4_imag_reg[23]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[22]),
	.result0_imag(s5_imag[22]),
	.result1_real(s5_real[23]),
	.result1_imag(s5_imag[23])
);

BU S5_12(
	.a(s4_real_reg[24]),
	.b(s4_imag_reg[24]),
	.c(s4_real_reg[25]),
	.d(s4_imag_reg[25]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[24]),
	.result0_imag(s5_imag[24]),
	.result1_real(s5_real[25]),
	.result1_imag(s5_imag[25])
);

BU S5_13(
	.a(s4_real_reg[26]),
	.b(s4_imag_reg[26]),
	.c(s4_real_reg[27]),
	.d(s4_imag_reg[27]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[26]),
	.result0_imag(s5_imag[26]),
	.result1_real(s5_real[27]),
	.result1_imag(s5_imag[27])
);

BU S5_14(
	.a(s4_real_reg[28]),
	.b(s4_imag_reg[28]),
	.c(s4_real_reg[29]),
	.d(s4_imag_reg[29]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[28]),
	.result0_imag(s5_imag[28]),
	.result1_real(s5_real[29]),
	.result1_imag(s5_imag[29])
);

BU S5_15(
	.a(s4_real_reg[30]),
	.b(s4_imag_reg[30]),
	.c(s4_real_reg[31]),
	.d(s4_imag_reg[31]),
	.W_real(W0_REAL),
	.W_imag(W0_IMAG),
	.result0_real(s5_real[30]),
	.result0_imag(s5_imag[30]),
	.result1_real(s5_real[31]),
	.result1_imag(s5_imag[31])
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)begin
			s5_real_reg[i]<=0;
			s5_imag_reg[i]<=0;
		end
	end
	else if(st==CAL && (counter == 4))begin
		for(i=0;i<32;i=i+1)begin
			s5_real_reg[i]<=s5_real[i];
			s5_imag_reg[i]<=s5_imag[i];
		end
	end
end

assign fft_d0=(counter==4)?s5_real[0][24:8] : (counter==5)? s5_real_reg[16][24:8]   : (counter == 6)? s5_imag_reg[0][24:8]  :s5_imag_reg[16][24:8];
assign fft_d1=(counter==4)?s5_real[1][24:8] : (counter==5)? s5_real_reg[17][24:8]   : (counter == 6)? s5_imag_reg[1][24:8]  :s5_imag_reg[17][24:8];
assign fft_d2=(counter==4)?s5_real[2][24:8] : (counter==5)? s5_real_reg[18][24:8]   : (counter == 6)? s5_imag_reg[2][24:8]  :s5_imag_reg[18][24:8];
assign fft_d3=(counter==4)?s5_real[3][24:8] : (counter==5)? s5_real_reg[19][24:8]   : (counter == 6)? s5_imag_reg[3][24:8]  :s5_imag_reg[19][24:8];
assign fft_d4=(counter==4)?s5_real[4][24:8] : (counter==5)? s5_real_reg[20][24:8]   : (counter == 6)? s5_imag_reg[4][24:8]  :s5_imag_reg[20][24:8];
assign fft_d5=(counter==4)?s5_real[5][24:8] : (counter==5)? s5_real_reg[21][24:8]   : (counter == 6)? s5_imag_reg[5][24:8]  :s5_imag_reg[21][24:8];
assign fft_d6=(counter==4)?s5_real[6][24:8] : (counter==5)? s5_real_reg[22][24:8]   : (counter == 6)? s5_imag_reg[6][24:8]  :s5_imag_reg[22][24:8];
assign fft_d7=(counter==4)?s5_real[7][24:8] : (counter==5)? s5_real_reg[23][24:8]   : (counter == 6)? s5_imag_reg[7][24:8]  :s5_imag_reg[23][24:8];
assign fft_d8=(counter==4)?s5_real[8][24:8] : (counter==5)? s5_real_reg[24][24:8]   : (counter == 6)? s5_imag_reg[8][24:8]  :s5_imag_reg[24][24:8];
assign fft_d9=(counter==4)?s5_real[9][24:8] : (counter==5)? s5_real_reg[25][24:8]   : (counter == 6)? s5_imag_reg[9][24:8]  :s5_imag_reg[25][24:8];
assign fft_d10=(counter==4)?s5_real[10][24:8] : (counter==5)? s5_real_reg[26][24:8] : (counter == 6)? s5_imag_reg[10][24:8] :s5_imag_reg[26][24:8];
assign fft_d11=(counter==4)?s5_real[11][24:8] : (counter==5)? s5_real_reg[27][24:8] : (counter == 6)? s5_imag_reg[11][24:8] :s5_imag_reg[27][24:8];
assign fft_d12=(counter==4)?s5_real[12][24:8] : (counter==5)? s5_real_reg[28][24:8] : (counter == 6)? s5_imag_reg[12][24:8] :s5_imag_reg[28][24:8];
assign fft_d13=(counter==4)?s5_real[13][24:8] : (counter==5)? s5_real_reg[29][24:8] : (counter == 6)? s5_imag_reg[13][24:8] :s5_imag_reg[29][24:8];
assign fft_d14=(counter==4)?s5_real[14][24:8] : (counter==5)? s5_real_reg[30][24:8] : (counter == 6)? s5_imag_reg[14][24:8] :s5_imag_reg[30][24:8];
assign fft_d15=(counter==4)?s5_real[15][24:8] : (counter==5)? s5_real_reg[31][24:8] : (counter == 6)? s5_imag_reg[15][24:8] :s5_imag_reg[31][24:8];


always@(posedge clk or posedge rst)begin
	if(rst)	
		counter<=0;
	else if(nxt==READ||nxt==CAL)
		counter<=counter+1;
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)
			fir_data[i]<=0;
	end		
	else if(nxt==READ||st==READ)begin
		fir_data[counter]<={{8{fir_d[15]}},fir_d,{8{1'b0}}};
	end	
	else if(st==CAL)begin
		fir_data[counter]<={{8{fir_d[15]}},fir_d,{8{1'b0}}};
	end	
end

always@(*)begin
	case(st)
		IDLE : nxt=(fir_valid)?READ:IDLE;
		READ : nxt=(&counter)?CAL:READ;  // counter == 31
		CAL : nxt=(counter==7&&!fir_valid)?DONE:CAL;
		DONE : nxt=DONE;
		default : nxt=IDLE;
	endcase
end

always@(posedge clk or posedge rst)begin
	if(rst)
		st<=IDLE;
	else
		st<=nxt;
end

endmodule