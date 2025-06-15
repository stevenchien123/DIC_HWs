`include "./Butterfly_Unit.v"

module  FFT(
    input           clk      , 
    input           rst      , 
    input  [15:0]   fir_d    , 
    input           fir_valid,
    output          fft_valid, 
    output          done     ,
    output reg [15:0]   fft_d1   , 
    output reg [15:0]   fft_d2   ,
    output reg [15:0]   fft_d3   , 
    output reg [15:0]   fft_d4   , 
    output reg [15:0]   fft_d5   , 
    output reg [15:0]   fft_d6   , 
    output reg [15:0]   fft_d7   , 
    output reg [15:0]   fft_d8   ,
    output reg [15:0]   fft_d9   , 
    output reg [15:0]   fft_d10  , 
    output reg [15:0]   fft_d11  , 
    output reg [15:0]   fft_d12  , 
    output reg [15:0]   fft_d13  , 
    output reg [15:0]   fft_d14  , 
    output reg [15:0]   fft_d15  , 
    output reg [15:0]   fft_d0
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

// parameter
  // coefficient
    parameter signed W_0_real = 12'b010000000000;
    parameter signed W_0_imag = 12'b000000000000;
    parameter signed W_1_real = 12'b001110110010;
    parameter signed W_1_imag = 12'b111001111000;
    parameter signed W_2_real = 12'b001011010100;
    parameter signed W_2_imag = 12'b110100101011;
    parameter signed W_3_real = 12'b000110000111;
    parameter signed W_3_imag = 12'b110001001101;
    parameter signed W_4_real = 12'b000000000000;
    parameter signed W_4_imag = 12'b110000000000;
    parameter signed W_5_real = 12'b111001111000;
    parameter signed W_5_imag = 12'b110001001101;
    parameter signed W_6_real = 12'b110100101011;
    parameter signed W_6_imag = 12'b110100101011;
    parameter signed W_7_real = 12'b110001001101;
    parameter signed W_7_imag = 12'b111001111000;

  // state
    parameter IDLE        = 0;
    parameter READ_DATA   = 1;
    parameter BUTTERFLY_1 = 2;
    parameter BUTTERFLY_2 = 3;
    parameter BUTTERFLY_3 = 4;
    parameter BUTTERFLY_4 = 5;
    parameter OUTPUT_DATA = 6;
    parameter DONE        = 7;

// wire & port
    reg [ 2:0] cur_state;
    reg [ 2:0] nxt_state;

    reg [ 3:0] counter;                                // For READ_DATA  : count from 0~15, store values into temp_butterfly array
    reg [ 1:0] counter_butterfly;                      // For BUTTERFLY_*: count from 0~2, 0: first part of multiple, 1: second part of multiple, 2: add together
    reg        counter_output_data;                    // For OUTPUT_DATA: count from 0~2, 2 cycles for output fft values

    reg signed [17:0] fir_in [15:0];                   // Store input data from fir_d
    
    reg signed [17:0] temp_butterfly_real [15:0];      // Store each butterfly stage of real value
    reg signed [17:0] temp_butterfly_imag [15:0];      // Store each butterfly stage of imagine value

    reg signed [35:0] wire_temp_butterfly_real [5:0];
    reg signed [35:0] wire_temp_butterfly_imag [5:0];


// FSM
  // nxt_state logic
    always @(*) begin
        case (cur_state)
            // IDLE: begin
            //     nxt_state = READ_DATA;
            // end

            READ_DATA: begin
                if(counter == 5'd15)
                    nxt_state = BUTTERFLY_1;
                else
                    nxt_state = READ_DATA;
            end

            BUTTERFLY_1: begin
                if(counter_butterfly == 2'd2)
                    nxt_state = BUTTERFLY_2;
                else
                    nxt_state = BUTTERFLY_1;
            end

            BUTTERFLY_2: begin
                if(counter_butterfly == 2'd2)
                    nxt_state = BUTTERFLY_3;
                else
                    nxt_state = BUTTERFLY_2;
            end

            BUTTERFLY_3: begin
                if(counter_butterfly == 2'd2)
                    nxt_state = BUTTERFLY_4;
                else
                    nxt_state = BUTTERFLY_3;
            end

            BUTTERFLY_4: begin
                if(counter_butterfly == 2'd2)
                    nxt_state = OUTPUT_DATA;
                else
                    nxt_state = BUTTERFLY_4;
            end

            OUTPUT_DATA: begin
                if(fir_valid == 1'b0 && counter_output_data == 1'b1)
                    nxt_state = DONE;
                else if(counter_output_data < 1'b1)     // OUTPUT_DATA not finish yet
                    nxt_state = OUTPUT_DATA;
                else                                    // input data have not completly output yet
                    nxt_state = READ_DATA;
            end

            DONE: begin
                nxt_state = DONE;
            end

            default: begin
                nxt_state = READ_DATA;
            end 
        endcase
    end

  // state register
    always @(posedge clk or posedge rst) begin
        if(rst)
            cur_state <= READ_DATA;
        else
            cur_state <= nxt_state;
    end

// fir_in
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0; i<16; i=i+1)
                fir_in[i] <= 18'd0;
        end
        else
            fir_in[counter] <= {$signed(fir_d), 2'd0};
    end

// counter
    reg fir_valid_reg;
    always @(posedge clk or posedge rst) begin
        if(rst)
            fir_valid_reg <= 1'd0;
        else 
            fir_valid_reg <= fir_valid;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            counter <= 4'd0;
        else if(fir_valid || (fir_valid_reg == 1'b1 && fir_valid == 1'b0))
            counter <= counter + 4'd1;
    end

// counter_butterfly
    always @(posedge clk or posedge rst) begin
        if(rst)
            counter_butterfly <= 2'd0;
        else if(cur_state == BUTTERFLY_1 || cur_state == BUTTERFLY_2 || cur_state == BUTTERFLY_3 || cur_state == BUTTERFLY_4) begin
            if(counter_butterfly == 2'd2)
                counter_butterfly <= 2'd0;
            else
                counter_butterfly <= counter_butterfly + 2'd1; 
        end
        else 
            counter_butterfly <= 2'd0;
    end

// counter_output_data
    always @(posedge clk or posedge rst) begin
        if(rst)
            counter_output_data <= 1'b0;
        else if(cur_state == OUTPUT_DATA)
            counter_output_data <= counter_output_data + 1'b1;
        else
            counter_output_data <= 1'b0;
    end

// wire_temp_butterfly_real & imag
    wire [29:0] fft_add_real_0;
    wire [29:0] fft_add_imag_0;
    wire [29:0] fft_mul_real_0;
    wire [29:0] fft_mul_imag_0;
    reg [17:0] a_0;
    reg [17:0] b_0;
    reg [17:0] c_0;
    reg [17:0] d_0;
    reg [11:0] W_real_0;
    reg [11:0] W_imag_0;

    wire [29:0] fft_add_real_1;
    wire [29:0] fft_add_imag_1;
    wire [29:0] fft_mul_real_1;
    wire [29:0] fft_mul_imag_1;
    reg [17:0] a_1;
    reg [17:0] b_1;
    reg [17:0] c_1;
    reg [17:0] d_1;
    reg [11:0] W_real_1;
    reg [11:0] W_imag_1;

    wire [29:0] fft_add_real_2;
    wire [29:0] fft_add_imag_2;
    wire [29:0] fft_mul_real_2;
    wire [29:0] fft_mul_imag_2;
    reg [17:0] a_2;
    reg [17:0] b_2;
    reg [17:0] c_2;
    reg [17:0] d_2;
    reg [11:0] W_real_2;
    reg [11:0] W_imag_2;

    Butterfly_Unit B0 (
        .fft_add_real(fft_add_real_0), 
        .fft_add_imag(fft_add_imag_0), 
        .fft_mul_real(fft_mul_real_0), 
        .fft_mul_imag(fft_mul_imag_0), 
        .a(a_0), 
        .b(b_0), 
        .c(c_0), 
        .d(d_0), 
        .W_real(W_real_0), 
        .W_imag(W_imag_0)
    );

    Butterfly_Unit B1 (
        .fft_add_real(fft_add_real_1), 
        .fft_add_imag(fft_add_imag_1), 
        .fft_mul_real(fft_mul_real_1), 
        .fft_mul_imag(fft_mul_imag_1), 
        .a(a_1), 
        .b(b_1), 
        .c(c_1), 
        .d(d_1), 
        .W_real(W_real_1), 
        .W_imag(W_imag_1)
    );

    Butterfly_Unit B2 (
        .fft_add_real(fft_add_real_2), 
        .fft_add_imag(fft_add_imag_2), 
        .fft_mul_real(fft_mul_real_2), 
        .fft_mul_imag(fft_mul_imag_2), 
        .a(a_2), 
        .b(b_2), 
        .c(c_2), 
        .d(d_2), 
        .W_real(W_real_2), 
        .W_imag(W_imag_2)
    );

    integer j;
    always @(*) begin
        for(i=0; i<6; i=i+1) begin
                    wire_temp_butterfly_real[i] = 0;
                    wire_temp_butterfly_imag[i] = 0;
        end

        a_0 = 0;
        b_0 = 0;
        c_0 = 0;
        d_0 = 0;
        W_real_0 = 0;
        W_imag_0 = 0;

        a_1 = 0;
        b_1 = 0;
        c_1 = 0;
        d_1 = 0;
        W_real_1 = 0;
        W_imag_1 = 0;

        a_2 = 0;
        b_2 = 0;
        c_2 = 0;
        d_2 = 0;
        W_real_2 = 0;
        W_imag_2 = 0;

        case(cur_state)
            BUTTERFLY_1: begin
                if(counter_butterfly == 2'd0) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = fir_in[0];
                    b_0 = 32'd0;
                    c_0 = fir_in[8];
                    d_0 = 32'd0;
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;

                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = fir_in[1];
                    b_1 = 32'd0;
                    c_1 = fir_in[9];
                    d_1 = 32'd0;
                    W_real_1 = W_1_real;
                    W_imag_1 = W_1_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = fir_in[2];
                    b_2 = 32'd0;
                    c_2 = fir_in[10];
                    d_2 = 32'd0;
                    W_real_2 = W_2_real;
                    W_imag_2 = W_2_imag;
                end
                else if(counter_butterfly == 2'd1) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = fir_in[3];
                    b_0 = 32'd0;
                    c_0 = fir_in[11];
                    d_0 = 32'd0;
                    W_real_0 = W_3_real;
                    W_imag_0 = W_3_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = fir_in[4];
                    b_1 = 32'd0;
                    c_1 = fir_in[12];
                    d_1 = 32'd0;
                    W_real_1 = W_4_real;
                    W_imag_1 = W_4_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = fir_in[5];
                    b_2 = 32'd0;
                    c_2 = fir_in[13];
                    d_2 = 32'd0;
                    W_real_2 = W_5_real;
                    W_imag_2 = W_5_imag;
                end
                else begin
                    wire_temp_butterfly_real[2] = fft_add_real_0;
                    wire_temp_butterfly_imag[2] = fft_add_imag_0;
                    wire_temp_butterfly_real[4] = fft_mul_real_0;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_0;
                    a_0 = fir_in[6];
                    b_0 = 32'd0;
                    c_0 = fir_in[14];
                    d_0 = 32'd0;
                    W_real_0 = W_6_real;
                    W_imag_0 = W_6_imag;

                    wire_temp_butterfly_real[3] = fft_add_real_1;
                    wire_temp_butterfly_imag[3] = fft_add_imag_1;
                    wire_temp_butterfly_real[5] = fft_mul_real_1;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_1;
                    a_1 = fir_in[7];
                    b_1 = 32'd0;
                    c_1 = fir_in[15];
                    d_1 = 32'd0;
                    W_real_1 = W_7_real;
                    W_imag_1 = W_7_imag;
                end
            end

            BUTTERFLY_2: begin
                if(counter_butterfly == 2'd0) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[0];
                    c_0 = temp_butterfly_real[4];
                    b_0 = temp_butterfly_imag[0];
                    d_0 = temp_butterfly_imag[4];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[1];
                    c_1 = temp_butterfly_real[5];
                    b_1 = temp_butterfly_imag[1];
                    d_1 = temp_butterfly_imag[5];
                    W_real_1 = W_2_real;
                    W_imag_1 = W_2_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[2];
                    c_2 = temp_butterfly_real[6];
                    b_2 = temp_butterfly_imag[2];
                    d_2 = temp_butterfly_imag[6];
                    W_real_2 = W_4_real;
                    W_imag_2 = W_4_imag;
                end
                else if(counter_butterfly == 2'd1) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[3];
                    c_0 = temp_butterfly_real[7];
                    b_0 = temp_butterfly_imag[3];
                    d_0 = temp_butterfly_imag[7];
                    W_real_0 = W_6_real;
                    W_imag_0 = W_6_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[8];
                    c_1 = temp_butterfly_real[12];
                    b_1 = temp_butterfly_imag[8];
                    d_1 = temp_butterfly_imag[12];
                    W_real_1 = W_0_real;
                    W_imag_1 = W_0_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[9];
                    c_2 = temp_butterfly_real[13];
                    b_2 = temp_butterfly_imag[9];
                    d_2 = temp_butterfly_imag[13];
                    W_real_2 = W_2_real;
                    W_imag_2 = W_2_imag;
                end
                else begin
                    wire_temp_butterfly_real[2] = fft_add_real_0;
                    wire_temp_butterfly_imag[2] = fft_add_imag_0;
                    wire_temp_butterfly_real[4] = fft_mul_real_0;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[10];
                    c_0 = temp_butterfly_real[14];
                    b_0 = temp_butterfly_imag[10];
                    d_0 = temp_butterfly_imag[14];
                    W_real_0 = W_4_real;
                    W_imag_0 = W_4_imag;

                    wire_temp_butterfly_real[3] = fft_add_real_1;
                    wire_temp_butterfly_imag[3] = fft_add_imag_1;
                    wire_temp_butterfly_real[5] = fft_mul_real_1;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[11];
                    c_1 = temp_butterfly_real[15];
                    b_1 = temp_butterfly_imag[11];
                    d_1 = temp_butterfly_imag[15];
                    W_real_1 = W_6_real;
                    W_imag_1 = W_6_imag;
                end
                
            end

            BUTTERFLY_3: begin
                if(counter_butterfly == 2'd0) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[0];
                    c_0 = temp_butterfly_real[2];
                    b_0 = temp_butterfly_imag[0];
                    d_0 = temp_butterfly_imag[2];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[1];
                    c_1 = temp_butterfly_real[3];
                    b_1 = temp_butterfly_imag[1];
                    d_1 = temp_butterfly_imag[3];
                    W_real_1 = W_4_real;
                    W_imag_1 = W_4_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[4];
                    c_2 = temp_butterfly_real[6];
                    b_2 = temp_butterfly_imag[4];
                    d_2 = temp_butterfly_imag[6];
                    W_real_2 = W_0_real;
                    W_imag_2 = W_0_imag;
                end
                else if(counter_butterfly == 2'd1) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[5];
                    c_0 = temp_butterfly_real[7];
                    b_0 = temp_butterfly_imag[5];
                    d_0 = temp_butterfly_imag[7];
                    W_real_0 = W_4_real;
                    W_imag_0 = W_4_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[8];
                    c_1 = temp_butterfly_real[10];
                    b_1 = temp_butterfly_imag[8];
                    d_1 = temp_butterfly_imag[10];
                    W_real_1 = W_0_real;
                    W_imag_1 = W_0_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[9];
                    c_2 = temp_butterfly_real[11];
                    b_2 = temp_butterfly_imag[9];
                    d_2 = temp_butterfly_imag[11];
                    W_real_2 = W_4_real;
                    W_imag_2 = W_4_imag;
                end
                else begin
                    wire_temp_butterfly_real[2] = fft_add_real_0;
                    wire_temp_butterfly_imag[2] = fft_add_imag_0;
                    wire_temp_butterfly_real[4] = fft_mul_real_0;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[12];
                    c_0 = temp_butterfly_real[14];
                    b_0 = temp_butterfly_imag[12];
                    d_0 = temp_butterfly_imag[14];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[3] = fft_add_real_1;
                    wire_temp_butterfly_imag[3] = fft_add_imag_1;
                    wire_temp_butterfly_real[5] = fft_mul_real_1;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[13];
                    c_1 = temp_butterfly_real[15];
                    b_1 = temp_butterfly_imag[13];
                    d_1 = temp_butterfly_imag[15];
                    W_real_1 = W_4_real;
                    W_imag_1 = W_4_imag;
                end
                
            end

            BUTTERFLY_4: begin
                if(counter_butterfly == 2'd0) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[0];
                    c_0 = temp_butterfly_real[1];
                    b_0 = temp_butterfly_imag[0];
                    d_0 = temp_butterfly_imag[1];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[2];
                    c_1 = temp_butterfly_real[3];
                    b_1 = temp_butterfly_imag[2];
                    d_1 = temp_butterfly_imag[3];
                    W_real_1 = W_0_real;
                    W_imag_1 = W_0_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[4];
                    c_2 = temp_butterfly_real[5];
                    b_2 = temp_butterfly_imag[4];
                    d_2 = temp_butterfly_imag[5];
                    W_real_2 = W_0_real;
                    W_imag_2 = W_0_imag;
                end
                else if(counter_butterfly == 2'd1) begin
                    wire_temp_butterfly_real[0] = fft_add_real_0;
                    wire_temp_butterfly_imag[0] = fft_add_imag_0;
                    wire_temp_butterfly_real[3] = fft_mul_real_0;
                    wire_temp_butterfly_imag[3] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[6];
                    c_0 = temp_butterfly_real[7];
                    b_0 = temp_butterfly_imag[6];
                    d_0 = temp_butterfly_imag[7];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[1] = fft_add_real_1;
                    wire_temp_butterfly_imag[1] = fft_add_imag_1;
                    wire_temp_butterfly_real[4] = fft_mul_real_1;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[8];
                    c_1 = temp_butterfly_real[9];
                    b_1 = temp_butterfly_imag[8];
                    d_1 = temp_butterfly_imag[9];
                    W_real_1 = W_0_real;
                    W_imag_1 = W_0_imag;

                    wire_temp_butterfly_real[2] = fft_add_real_2;
                    wire_temp_butterfly_imag[2] = fft_add_imag_2;
                    wire_temp_butterfly_real[5] = fft_mul_real_2;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_2;
                    a_2 = temp_butterfly_real[10];
                    c_2 = temp_butterfly_real[11];
                    b_2 = temp_butterfly_imag[10];
                    d_2 = temp_butterfly_imag[11];
                    W_real_2 = W_0_real;
                    W_imag_2 = W_0_imag;
                end
                else begin
                    wire_temp_butterfly_real[2] = fft_add_real_0;
                    wire_temp_butterfly_imag[2] = fft_add_imag_0;
                    wire_temp_butterfly_real[4] = fft_mul_real_0;
                    wire_temp_butterfly_imag[4] = fft_mul_imag_0;
                    a_0 = temp_butterfly_real[12];
                    c_0 = temp_butterfly_real[13];
                    b_0 = temp_butterfly_imag[12];
                    d_0 = temp_butterfly_imag[13];
                    W_real_0 = W_0_real;
                    W_imag_0 = W_0_imag;

                    wire_temp_butterfly_real[3] = fft_add_real_1;
                    wire_temp_butterfly_imag[3] = fft_add_imag_1;
                    wire_temp_butterfly_real[5] = fft_mul_real_1;
                    wire_temp_butterfly_imag[5] = fft_mul_imag_1;
                    a_1 = temp_butterfly_real[14];
                    c_1 = temp_butterfly_real[15];
                    b_1 = temp_butterfly_imag[14];
                    d_1 = temp_butterfly_imag[15];
                    W_real_1 = W_0_real;
                    W_imag_1 = W_0_imag;
                end
            end
        endcase
    end

// temp_butterfly_real & imag
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(j=0; j<6; j=j+1) begin
                temp_butterfly_real[j] <= 16'd0;
                temp_butterfly_imag[j] <= 16'd0;
            end
        end
        else begin
            case(cur_state)
                BUTTERFLY_1: begin
                    if(counter_butterfly == 2'd0) begin
                        // real part
                        temp_butterfly_real[ 0] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 1] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 2] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 8] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[ 9] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[10] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 0] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 1] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 2] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 8] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[ 9] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[10] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else if(counter_butterfly == 2'd1) begin
                        // real part
                        temp_butterfly_real[ 3] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 4] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 5] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[11] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[12] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[13] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 3] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 4] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 5] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[11] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[12] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[13] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else begin
                        // real part
                        temp_butterfly_real[ 6] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 7] <= wire_temp_butterfly_real[ 3];
                        temp_butterfly_real[14] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[15] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 6] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 7] <= wire_temp_butterfly_imag[ 3];
                        temp_butterfly_imag[14] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[15] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                end

                BUTTERFLY_2: begin
                    if(counter_butterfly == 2'd0) begin
                        // real part
                        temp_butterfly_real[ 0] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 1] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 2] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 4] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[ 5] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[ 6] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 0] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 1] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 2] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 4] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[ 5] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[ 6] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else if(counter_butterfly == 2'd1) begin
                        // real part
                        temp_butterfly_real[ 3] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 8] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 9] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 7] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[12] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[13] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 3] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 8] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 9] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 7] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[12] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[13] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else begin
                        // real part
                        temp_butterfly_real[10] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[11] <= wire_temp_butterfly_real[ 3];
                        temp_butterfly_real[14] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[15] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[10] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[11] <= wire_temp_butterfly_imag[ 3];
                        temp_butterfly_imag[14] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[15] <= wire_temp_butterfly_imag[ 5][10+:18]; 
                    end
                end

                BUTTERFLY_3: begin
                    if(counter_butterfly == 2'd0) begin
                        // real part
                        temp_butterfly_real[ 0] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 1] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 4] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 2] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[ 3] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[ 6] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 0] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 1] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 4] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 2] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[ 3] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[ 6] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else if(counter_butterfly == 2'd1) begin
                        // real part
                        temp_butterfly_real[ 5] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 8] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 9] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 7] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[10] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[11] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 5] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 8] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 9] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 7] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[10] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[11] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else begin
                        // real part
                        temp_butterfly_real[12] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[13] <= wire_temp_butterfly_real[ 3];
                        temp_butterfly_real[14] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[15] <= wire_temp_butterfly_real[ 5][10+:18];
                        
                        // imag part
                        temp_butterfly_imag[12] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[13] <= wire_temp_butterfly_imag[ 3];                        
                        temp_butterfly_imag[14] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[15] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                end

                BUTTERFLY_4: begin
                    if(counter_butterfly == 2'd0) begin
                        // real part
                        temp_butterfly_real[ 0] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 2] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[ 4] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 1] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[ 3] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[ 5] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 0] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 2] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[ 4] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 1] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[ 3] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[ 5] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else if(counter_butterfly == 2'd1) begin
                        // real part
                        temp_butterfly_real[ 6] <= wire_temp_butterfly_real[ 0];
                        temp_butterfly_real[ 8] <= wire_temp_butterfly_real[ 1];
                        temp_butterfly_real[10] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[ 7] <= wire_temp_butterfly_real[ 3][10+:18];
                        temp_butterfly_real[ 9] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[11] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[ 6] <= wire_temp_butterfly_imag[ 0];
                        temp_butterfly_imag[ 8] <= wire_temp_butterfly_imag[ 1];
                        temp_butterfly_imag[10] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[ 7] <= wire_temp_butterfly_imag[ 3][10+:18];
                        temp_butterfly_imag[ 9] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[11] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                    else begin
                        // real part
                        temp_butterfly_real[12] <= wire_temp_butterfly_real[ 2];
                        temp_butterfly_real[14] <= wire_temp_butterfly_real[ 3];
                        temp_butterfly_real[13] <= wire_temp_butterfly_real[ 4][10+:18];
                        temp_butterfly_real[15] <= wire_temp_butterfly_real[ 5][10+:18];

                        // imag part
                        temp_butterfly_imag[12] <= wire_temp_butterfly_imag[ 2];
                        temp_butterfly_imag[14] <= wire_temp_butterfly_imag[ 3];
                        temp_butterfly_imag[13] <= wire_temp_butterfly_imag[ 4][10+:18];
                        temp_butterfly_imag[15] <= wire_temp_butterfly_imag[ 5][10+:18];
                    end
                end
            endcase
        end
    end

// fft_d0 ~ fft_d15
    always @(*) begin
        if(cur_state == OUTPUT_DATA) begin
            if(counter_output_data == 1'b0) begin
                fft_d0  = temp_butterfly_real[ 0][2+:16];
                fft_d1  = temp_butterfly_real[ 8][2+:16];
                fft_d2  = temp_butterfly_real[ 4][2+:16];
                fft_d3  = temp_butterfly_real[12][2+:16];
                fft_d4  = temp_butterfly_real[ 2][2+:16];
                fft_d5  = temp_butterfly_real[10][2+:16];
                fft_d6  = temp_butterfly_real[ 6][2+:16];
                fft_d7  = temp_butterfly_real[14][2+:16];
                fft_d8  = temp_butterfly_real[ 1][2+:16];
                fft_d9  = temp_butterfly_real[ 9][2+:16];
                fft_d10 = temp_butterfly_real[ 5][2+:16];
                fft_d11 = temp_butterfly_real[13][2+:16];
                fft_d12 = temp_butterfly_real[ 3][2+:16];
                fft_d13 = temp_butterfly_real[11][2+:16];
                fft_d14 = temp_butterfly_real[ 7][2+:16];
                fft_d15 = temp_butterfly_real[15][2+:16];
            end
            else begin
                fft_d0  = temp_butterfly_imag[ 0][2+:16];
                fft_d1  = temp_butterfly_imag[ 8][2+:16];
                fft_d2  = temp_butterfly_imag[ 4][2+:16];
                fft_d3  = temp_butterfly_imag[12][2+:16];
                fft_d4  = temp_butterfly_imag[ 2][2+:16];
                fft_d5  = temp_butterfly_imag[10][2+:16];
                fft_d6  = temp_butterfly_imag[ 6][2+:16];
                fft_d7  = temp_butterfly_imag[14][2+:16];
                fft_d8  = temp_butterfly_imag[ 1][2+:16];
                fft_d9  = temp_butterfly_imag[ 9][2+:16];
                fft_d10 = temp_butterfly_imag[ 5][2+:16];
                fft_d11 = temp_butterfly_imag[13][2+:16];
                fft_d12 = temp_butterfly_imag[ 3][2+:16];
                fft_d13 = temp_butterfly_imag[11][2+:16];
                fft_d14 = temp_butterfly_imag[ 7][2+:16];
                fft_d15 = temp_butterfly_imag[15][2+:16];
            end
        end
        else begin
            fft_d0  = 16'd0;
            fft_d1  = 16'd0; 
            fft_d2  = 16'd0; 
            fft_d3  = 16'd0; 
            fft_d4  = 16'd0; 
            fft_d5  = 16'd0; 
            fft_d6  = 16'd0; 
            fft_d7  = 16'd0; 
            fft_d8  = 16'd0; 
            fft_d9  = 16'd0; 
            fft_d10 = 16'd0;
            fft_d11 = 16'd0;
            fft_d12 = 16'd0;
            fft_d13 = 16'd0;
            fft_d14 = 16'd0;
            fft_d15 = 16'd0;
        end
    end

// fft_valid
    assign fft_valid = (cur_state == OUTPUT_DATA)? 1'b1 : 1'b0;

// done
    assign done = (cur_state == DONE)? 1'b1 : 1'b0;

endmodule