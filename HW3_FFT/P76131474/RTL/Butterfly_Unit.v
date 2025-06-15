module Butterfly_Unit (
    output [29:0] fft_add_real, 
    output [29:0] fft_add_imag, 
    output [29:0] fft_mul_real, 
    output [29:0] fft_mul_imag, 

    input  [17:0] a, 
    input  [17:0] b, 
    input  [17:0] c, 
    input  [17:0] d, 
    input  [11:0] W_real, 
    input  [11:0] W_imag
);

// always @(*) begin
//     fft_add_real = a + c;
//     fft_add_imag = b + d;

//     fft_mul_real = (($signed({(a - c)})) * W_real) + (($signed({(d - b)})) * W_imag);
//     fft_mul_imag = (($signed({(a - c)})) * W_imag) + (($signed({(b - d)})) * W_real);
// end

assign fft_add_real = a + c;
assign fft_add_imag = b + d;

assign fft_mul_real = (($signed(a - c)) * $signed(W_real)) + (($signed(d - b)) * $signed(W_imag));
assign fft_mul_imag = (($signed(a - c)) * $signed(W_imag)) + (($signed(b - d)) * $signed(W_real));

endmodule