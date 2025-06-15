module MedianFinder_6num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  ,  
    output 	[3:0] 	median  
);
	
	wire [3:0] min1, max1, min2, max2, min3, max3, min4, max4, min5, max5, min6, max6, min7, max7, min8, max8, min9, max9, min10, max10, min11, max11;

	Comparator2 comp1(.A(num1), .B(num2), .min(min1), .max(max1));	// divide 6 inputs into two group: min & max
	Comparator2 comp2(.A(num3), .B(num4), .min(min2), .max(max2));	// min: min1, 2, 3
	Comparator2 comp3(.A(num5), .B(num6), .min(min3), .max(max3));	// max: max1, 2, 3

	Comparator2 comp4(.A(min1), .B(min2), .min(min4), .max(max4));
	Comparator2 comp5(.A(min3), .B(min4), .min(min5), .max(max5));	// min5 is minimum value of 6 inputs

	Comparator2 comp6(.A(max1), .B(max2), .min(min6), .max(max6));
	Comparator2 comp7(.A(max3), .B(max6), .min(min7), .max(max7));	// max7 is maximum value of 6 inputs

	// remain value: min: max4, 5  ,  max: min6, 7
	Comparator2 comp8(.A(max4), .B(max5), .min(min8), .max(max8));
	Comparator2 comp9(.A(min6), .B(min7), .min(min9), .max(max9));

	Comparator2 comp10(.A(max8), .B(max9), .min(min10), .max(max10));	// max10 is maximum value of remain values
	Comparator2 comp11(.A(min8), .B(min9), .min(min11), .max(max11));	// min11 is minimum value of remain values

	assign median = (max11 + min10)/2;

endmodule
