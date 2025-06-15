`include "Comparator2.v"
`include "MedianFinder_3num.v"

module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] C0_min;
wire [3:0] C0_max;
wire [3:0] C1_min;
wire [3:0] C1_max;
wire [3:0] C2_max;
wire [3:0] C3_min;


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
	.A(C0_min),
	.B(C1_min),
	.min(),
	.max(C2_max)
);

Comparator2 C3(
	.A(C0_max),
	.B(C1_max),
	.min(C3_min),
	.max()
);

MedianFinder_3num M3(
	.num1(C2_max),
	.num2(C3_min),
	.num3(num5),
	.median(median)
);


endmodule
