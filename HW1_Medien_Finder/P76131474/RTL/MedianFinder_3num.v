`include "Comparator2.v"

module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] C0_min;
wire [3:0] C0_max;
wire [3:0] C1_min;


Comparator2 C0(
    .A(num1),
    .B(num2),
    .min(C0_min),
    .max(C0_max)
);

Comparator2 C1(
    .A(C0_max),
    .B(num3),
    .min(C1_min),
    .max()
);

Comparator2 C2(
    .A(C0_min),
    .B(C1_min),
    .min(),
    .max(median)
);

endmodule
