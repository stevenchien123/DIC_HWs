`timescale 1ns/10ps

module  ATCONV(
        input		clk       ,
        input		rst       ,
        output          ROM_rd    ,
        output reg [11:0]	iaddr     ,
        input  [15:0]	idata     ,
        output          layer0_ceb,
        output          layer0_web,   
        output reg [11:0]   layer0_A  ,
        output [15:0]   layer0_D  ,
        input  [15:0]   layer0_Q  ,
        output          layer1_ceb,
        output          layer1_web,
        output [11:0]   layer1_A  ,
        output [15:0]   layer1_D  ,
        input  [15:0]   layer1_Q  ,
        output          done        
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

// parameter
    parameter READ_DATA_0  = 3'd0;     // Read data from IMAGE_MEM
    parameter CONV         = 3'd1;     // Atrous convolution
    parameter WRITE_DATA_0 = 3'd2;     // Write data into LAYER_0_MEM
    parameter MAX_POOLING  = 3'd3;     // Max pooling process
    parameter WRITE_DATA_1 = 3'd4;     // Write data into LAYER_1_MEM
    parameter DONE         = 3'd5;     // Finish all process


// wire & reg
    reg         [ 2:0] cur_state, nxt_state;

    wire signed [15:0] bias;
    reg  signed [15:0] kernal;

    reg         [ 5:0] x, y;
    reg         [ 4:0] x_1, y_1;
    reg         [ 3:0] counter;       // count from 0 ~ 8, convolution do 9 times multiple-add
    wire signed [15:0] idata_temp;
    wire signed [31:0] mul_temp;
    reg  signed [19:0] conv_value_temp;    // 16-bit * 16-bit = 32-bit, 9 * 32-bit = 36-bit
    wire signed [15:0] conv_value;         // Extract 12-bit integer & 4-bit fraction from conv_value_temp
    wire signed [15:0] conv_value_relu;

    wire signed [15:0] layer0_Q_temp;
    reg  signed [15:0] max_value;
    wire signed [15:0] round_up_value;
    wire signed [15:0] round_down_value;
    wire signed [15:0] round_value;

// FSM
    always @(*) begin
        case(cur_state)
            READ_DATA_0: begin
                nxt_state = CONV;
            end

            CONV: begin
                if(counter == 4'd8)
                    nxt_state = WRITE_DATA_0;
                else
                    nxt_state = CONV;
            end

            WRITE_DATA_0: begin
                if(x == 6'd63 && y == 6'd63)
                    nxt_state = MAX_POOLING;
                else
                    nxt_state = READ_DATA_0;
            end

            MAX_POOLING: begin
                if(counter == 4'd4)
                    nxt_state = WRITE_DATA_1;
                else
                    nxt_state = MAX_POOLING;
            end

            WRITE_DATA_1: begin
                if(x == 6'd62 && y == 6'd62)
                    nxt_state = DONE;
                else
                    nxt_state = MAX_POOLING;
            end

            DONE: begin
                nxt_state = DONE;
            end

            default: begin
                nxt_state = READ_DATA_0;
            end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            cur_state <= READ_DATA_0;
        else
            cur_state <= nxt_state;
    end

// bias & kernal
    assign bias = 16'hFFF4;

    always @(*) begin
        case(counter)
            4'd0: kernal = 16'hFFFF;
            4'd1: kernal = 16'hFFFE;
            4'd2: kernal = 16'hFFFF;
            4'd3: kernal = 16'hFFFC;
            4'd4: kernal = 16'h0010;
            4'd5: kernal = 16'hFFFC;
            4'd6: kernal = 16'hFFFF;
            4'd7: kernal = 16'hFFFE;
            4'd8: kernal = 16'hFFFF;
            default: kernal = 16'd0;
        endcase
    end

// x & y
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            x <= 6'd0;
            y <= 6'd0;
        end
        else if(cur_state == WRITE_DATA_0) begin
            x <= x + 6'd1;

            if(x == 6'd63) 
                y <= y + 6'd1;
        end
        else if(cur_state == WRITE_DATA_1) begin
            x <= x + 6'd2;

            if(x == 6'd62) 
                y <= y + 6'd2;
        end
    end

// x_1 & y_1
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            x_1 <= 5'd0;
            y_1 <= 5'd0;
        end
        else if(cur_state == WRITE_DATA_1) begin
            x_1 <= x_1 + 5'd1;

            if(x_1 == 5'd31) 
                y_1 <= y_1 + 5'd1;
        end
    end

// counter
    always @(posedge clk or posedge rst) begin
        if(rst)
            counter <= 4'd0;
        else if(cur_state == CONV || cur_state == MAX_POOLING)
            counter <= counter + 4'd1;
        else
            counter <= 4'd0;
    end

// iaddr
    wire signed [7:0] x_before;
    wire signed [7:0] y_before;
    wire signed [7:0] x_after;
    wire signed [7:0] y_after;
    wire signed [5:0] x_after_1;
    wire signed [5:0] y_after_1;

    assign x_before = x-2;
    assign y_before = y-2;
    assign x_after  = x+2;
    assign y_after  = y+2;
    assign x_after_1  = x+1;
    assign y_after_1  = y+1;
    

    always @(*) begin
        iaddr = 12'd0;

        case(counter)
            4'd0: begin
                if(x_before < 0 && y_before < 0)
                    iaddr = 12'd0;
                else if(x_before < 0)
                    iaddr = {y_before[5:0], 6'd0};
                else if(y_before < 0)
                    iaddr = {6'd0, x_before[5:0]};
                else
                    iaddr = {y_before[5:0], x_before[5:0]};
            end

            4'd1: begin
                if(y_before < 0)
                    iaddr = {6'd0, x};
                else
                    iaddr = {y_before[5:0], x};
            end

            4'd2: begin
                if(x_after > 63 && y_before < 0)
                    iaddr = 12'd63;
                else if(x_after > 63)
                    iaddr = {y_before[5:0], 6'd63};
                else if(y_before < 0)
                    iaddr = {6'd0, x_after[5:0]};
                else
                    iaddr = {y_before[5:0], x_after[5:0]};
            end

            4'd3: begin
                if(x_before < 0)
                    iaddr = {y, 6'd0};
                else
                    iaddr = {y, x_before[5:0]};
            end

            4'd4: begin
                iaddr = {y, x};
            end

            4'd5: begin
                if(x_after > 63)
                    iaddr = {y, 6'd63};
                else
                    iaddr = {y, x_after[5:0]};
            end

            4'd6: begin
                if(x_before < 0 && y_after > 63)
                    iaddr = {6'd63, 6'd0};
                else if(x_before < 0)
                    iaddr = {y_after[5:0], 6'd0};
                else if(y_after > 63)
                    iaddr = {6'd63, x_before[5:0]};
                else
                    iaddr = {y_after[5:0], x_before[5:0]};
            end

            4'd7: begin
                if(y_after > 63)
                    iaddr = {6'd63, x};
                else
                    iaddr = {y_after[5:0], x};
            end

            4'd8: begin
                if(x_after > 63 && y_after > 63)
                    iaddr = {6'd63, 6'd63};
                else if(x_after > 63)
                    iaddr = {y_after[5:0], 6'd63};
                else if(y_after > 63)
                    iaddr = {6'd63, x_after[5:0]};
                else
                    iaddr = {y_after[5:0], x_after[5:0]};
            end
        endcase
    end

// idata_temp
    assign idata_temp = idata;

// mul_temp
    assign mul_temp = idata_temp * kernal;

// conv_value_temp
    always @(posedge clk or posedge rst) begin
        if(rst)
            conv_value_temp <= 36'd0;
        else if(cur_state == CONV) begin
            if(counter < 4'd8)
                conv_value_temp <= conv_value_temp + mul_temp;
            else if(counter == 4'd8)
                conv_value_temp <= conv_value_temp + mul_temp + $signed({bias, 4'd0});
        end
        else if(cur_state == WRITE_DATA_0)
            conv_value_temp <= 36'd0;
    end

// conv_value
    assign conv_value = conv_value_temp[19:4];

// conv_value_relu
   assign conv_value_relu = (conv_value > 0)? conv_value : 16'd0;

// layer0_Q_temp
    assign layer0_Q_temp = layer0_Q;

// max_value
    always @(posedge clk or posedge rst) begin
        if(rst)
            max_value <= 16'd0;
        else if(cur_state == MAX_POOLING) begin
            if(counter == 4'd0)
                max_value <= layer0_Q_temp;
            else
                max_value <= (max_value > layer0_Q_temp)? max_value : layer0_Q_temp;
        end
    end

// round_up_value
    assign round_up_value = {max_value[15:4]+12'd1, 4'd0};

// round_value
    assign round_value = (max_value[3] == 1'b1 || max_value[2] == 1'b1 || max_value[1] == 1'b1 || max_value[0] == 1'b1)? round_up_value : max_value;

// ROM_rd
    assign ROM_rd = (cur_state == READ_DATA_0 || cur_state == CONV)? 1'b1 : 1'b0;

// layer0_ceb & layer1_ceb
    assign layer0_ceb = (cur_state == WRITE_DATA_0 || cur_state == MAX_POOLING)? 1'b1 : 1'b0;
    assign layer1_ceb = (cur_state == WRITE_DATA_1)? 1'b1 : 1'b0;

// layer0_web & layer1_web
    assign layer0_web = (cur_state == MAX_POOLING)? 1'b1 : 1'b0;
    assign layer1_web = 1'b0;

// layer0_A & layer1_A
    always @(*) begin
        layer0_A = 12'd0;

        case(cur_state)
            WRITE_DATA_0:
                layer0_A = {y, x};

            MAX_POOLING: begin
                case(counter)
                    4'd0: layer0_A = {y, x};
                    4'd1: layer0_A = {y, x_after_1};
                    4'd2: layer0_A = {y_after_1, x};
                    4'd3: layer0_A = {y_after_1, x_after_1};
                endcase
            end
        endcase
    end

    assign layer1_A = {y_1, x_1};

// layer0_D & layer1_D
    assign layer0_D = conv_value_relu;
    assign layer1_D = round_value;

// done
    assign done = (cur_state == DONE)? 1'b1 : 1'b0;

endmodule
