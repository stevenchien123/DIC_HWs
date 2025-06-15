`include "Comparator2.v"
`include "MedianFinder_3num.v"
`include "MedianFinder_5num.v"

module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] C0_min;
wire [3:0] C0_max;
wire [3:0] C1_min;
wire [3:0] C1_max;
wire [3:0] C2_min;
wire [3:0] C2_max;
wire [3:0] C3_min;
wire [3:0] C3_max;
wire [3:0] C4_min;
wire [3:0] C4_max;
wire [3:0] C5_min;
wire [3:0] C5_max;
wire [3:0] C6_min;
wire [3:0] C6_max;


Comparator2 C0(
	.A(num1),
	.B(num2),
	.min(C0_min),
	.max(C0_max)
);

Comparator2 C1(
	.A(num3),
	.B(num4),
	.min(C1_min),
	.max(C1_max)
);

Comparator2 C2(
	.A(num5),
	.B(num6),
	.min(C2_min),
	.max(C2_max)
);

Comparator2 C3(
	.A(C0_min),
	.B(C1_min),
	.min(C3_min),
	.max(C3_max)
);

Comparator2 C4(
	.A(C0_max),
	.B(C1_max),
	.min(C4_min),
	.max(C4_max)
);

Comparator2 C5(
	.A(C3_min),
	.B(C2_min),
	.min(C5_min),
	.max(C5_max)
);

Comparator2 C6(
	.A(C4_max),
	.B(C2_max),
	.min(C6_min),
	.max(C6_max)
);

MedianFinder_5num M5(
	.num1(C5_max),
	.num2(C3_max),
	.num3(C4_min),
	.num4(C6_min),
	.num5(num7),
	.median(median)
);


endmodule
