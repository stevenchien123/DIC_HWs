module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,
    input       [ 7:0]  Y,
    output              Done,
    output      [16:0]  area
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

// State
    parameter IDLE            = 0;
    parameter READ            = 1;     // read 20 points inputs

                                       // sort each point by x
    parameter SORT1           = 2;     // update index_i & index_j & counter
    parameter SORT2           = 3;     // do swap

    parameter LOWER_HULL_CAL  = 4;     // calculate convex hull using andrew's monotone chain algorithm
    parameter UPPER_HULL_CAL  = 5;
    parameter CAL_AREA        = 6;
    parameter DONE            = 7;

// wire & reg
    reg         [ 3:0] cur_state, nxt_state;
    reg         [ 4:0] counter, counter_sort, index_i, index_j, point_num, t;
    reg         [ 7:0] point_X [19:0], point_Y [19:0], convex_hull [19:0];
    reg                do_swap;
    reg  signed [40:0] area_temp;
    wire signed [30:0] cross_product;
    


// FSM
  // nxt_state logic
    always @(*) begin
        case(cur_state)
            READ: begin
                if(counter == 19) nxt_state = SORT1;
                else              nxt_state = READ;
            end

            SORT1:
                nxt_state = SORT2;

            SORT2: begin
                if(!do_swap || index_j == 1) begin
                    if(counter_sort == 19) nxt_state = LOWER_HULL_CAL;
                    else nxt_state = SORT1;
                end
                else nxt_state = SORT2;
            end

            LOWER_HULL_CAL: begin
                if(counter == 20) nxt_state = UPPER_HULL_CAL;
                else nxt_state = LOWER_HULL_CAL;
            end

            UPPER_HULL_CAL: begin
                if(counter == 0 && (!(point_num >= t && cross_product <= 0))) nxt_state = CAL_AREA;
                else nxt_state = UPPER_HULL_CAL;
            end

            CAL_AREA: begin
                if(index_i == point_num-1) nxt_state = DONE;
                else nxt_state = CAL_AREA;
            end

            DONE:
                nxt_state = READ;

            default:
                nxt_state = READ;
        endcase
    end

  // state register
    always @(posedge clk or posedge reset) begin
        if(reset)
            cur_state <= READ;
        else
            cur_state <= nxt_state;
    end

// counter & t
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            t <= 0;
        end
        else if(cur_state == SORT1 || cur_state == DONE)begin
            counter <= 0;
            t <= 0;
        end
        else if(cur_state == READ) counter <= counter + 1;
        else if(cur_state == LOWER_HULL_CAL) begin
            if(counter == 20) begin
                counter <= 18;
                t <= point_num + 1;
            end
            else if(!(point_num >= 2 && cross_product <= 0))
                counter <= counter + 1;
        end
        else if(cur_state == UPPER_HULL_CAL) begin
            if(!(point_num >= t && cross_product <= 0))
                counter <= counter - 1;
        end
    end

// counter_sort
    always @(posedge clk or posedge reset) begin
        if(reset) counter_sort <= 0;
        else if(cur_state == SORT1) counter_sort <= counter_sort + 1;
        else if(cur_state == DONE) counter_sort <= 0;
    end

// point_X & point_Y
    integer i;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            for(i=0; i<20; i=i+1) begin
                point_X[i] <= 0;
                point_Y[i] <= 0;
            end
        end
        else if(cur_state == READ || nxt_state == READ) begin
            point_X[counter] <= X;
            point_Y[counter] <= Y;
        end
        else if(cur_state == SORT2) begin
            if(do_swap) begin
                point_X[index_i] <= point_X[index_j];
                point_X[index_j] <= point_X[index_i];
                point_Y[index_i] <= point_Y[index_j];
                point_Y[index_j] <= point_Y[index_i];
            end
        end
        else if(cur_state == DONE) begin
            for(i=0; i<20; i=i+1) begin
                point_X[i] <= 0;
                point_Y[i] <= 0;
            end
        end
    end

// index_i & index_j
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            index_i <= 0;
            index_j <= 1;
        end
        else if(cur_state == SORT1) begin
            index_i <= counter_sort;
            index_j <= counter_sort + 1;
        end
        else if(cur_state == SORT2) begin
            if(do_swap) begin
                index_i <= index_i - 1;
                index_j <= index_j - 1;
            end
        end
        else if(cur_state == CAL_AREA)
            index_i <= index_i + 1;
        else begin
            index_i <= 0;
            index_j <= 0;
        end
    end

// convex_hull & point_num
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            point_num <= 0;
            for(i=0; i<20; i=i+1) 
                convex_hull[i] <= 0; 
        end
        else if(cur_state == LOWER_HULL_CAL) begin
            if(counter < 20)begin
                if(point_num >= 2 && cross_product <= 0)
                    point_num <= point_num - 1;
                else begin  // ADD
                    point_num <= point_num + 1;
                    convex_hull[point_num] <= counter;
                end
            end
        end
        else if(cur_state == UPPER_HULL_CAL) begin
            if(point_num >= t && cross_product <= 0)
                point_num <= point_num - 1;
            else begin  // ADD
                point_num <= point_num + 1;
                convex_hull[point_num] <= counter;
            end
        end
        else if(cur_state == DONE) begin
            point_num <= 0;
            for(i=0; i<20; i=i+1) 
                convex_hull[i] <= 0;
        end
    end

// area_temp
    wire signed [20:0] xi, xi_1, yi, yi_1;
    assign xi =  {1'b0, point_X[convex_hull[index_i]]};
    assign xi_1 = (index_i == point_num-1)? {1'b0, point_X[convex_hull[0]]} : {1'b0, point_X[convex_hull[index_i+1]]};
    assign yi = {1'b0, point_Y[convex_hull[index_i]]};
    assign yi_1 = (index_i == point_num-1)? {1'b0, point_Y[convex_hull[0]]} : {1'b0, point_Y[convex_hull[index_i+1]]};

    always @(posedge clk or posedge reset) begin
        if(reset) area_temp <= 0;
        else if(cur_state == CAL_AREA) begin
            area_temp <= area_temp + ((xi*yi_1)-(xi_1*yi));
        end
        else
            area_temp <= 0;
    end

// do_swap
    always @(*) begin
        if(point_X[index_j] < point_X[index_i]) do_swap = 1;
        else if(point_X[index_j] == point_X[index_i]) begin
            if(point_Y[index_j] < point_Y[index_i]) do_swap = 1;
            else do_swap = 0;
        end
        else do_swap = 0;
    end

// cross_product, (x1-x0)*(y2-y0) - (x2-x0)*(y1-y0)
// (x0, y0)=(point_X[convex_hull[point_num-2]], point_Y[convex_hull[point_num-2]])
// (x1, y1)=(point_X[convex_hull[point_num-1]], point_Y[convex_hull[point_num-1]])
// (x2, y2)=(point_X[convex_hull[counter]], point_Y[convex_hull[counter]])
    wire signed [ 9:0] Ax, Bx, Ay, By;
    wire signed [25:0] AxBy, BxAy;

    assign Ax = (point_X[convex_hull[point_num-1]])-(point_X[convex_hull[point_num-2]]);
    assign Ay = (point_Y[convex_hull[point_num-1]])-(point_Y[convex_hull[point_num-2]]);
    assign Bx = (point_X[counter])-(point_X[convex_hull[point_num-2]]);
    assign By = (point_Y[counter])-(point_Y[convex_hull[point_num-2]]);

    assign AxBy = Ax * By;
    assign BxAy = Bx * Ay;

    assign cross_product =  AxBy - BxAy;

// area
    assign area = area_temp;

// Done
    assign Done = (cur_state == DONE);

endmodule