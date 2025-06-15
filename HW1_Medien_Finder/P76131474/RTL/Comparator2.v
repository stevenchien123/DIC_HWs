module Comparator2 (
    input   [3:0]   A  ,  
    input   [3:0]   B  ,  
    output  [3:0]   min,  
    output  [3:0]   max  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

assign min = (A < B)? A : B;
assign max = (A < B)? B : A;

endmodule
