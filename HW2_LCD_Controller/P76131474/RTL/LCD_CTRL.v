module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output 		  IROM_rd  , 
	output  [5:0] IROM_A   ,
	output 		  IRAM_ceb ,
	output 		  IRAM_web ,
	output  [7:0] IRAM_D   ,
	output  [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,
	output 		  busy	   ,
	output 		  done
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////


// parameter
  // states
	parameter READ_DATA = 2'd0;		// read data from IROM
	parameter READ_CMD  = 2'd1;		// read cmd
	parameter OPERATION = 2'd2;		// do cmd process
	parameter DONE      = 2'd3;

  // cmd
	parameter WRITE = 3'd0;
	parameter SU    = 3'd1;		// shift up
	parameter SD    = 3'd2;		// shift down
	parameter SL    = 3'd3;		// shift left
	parameter SR    = 3'd4;		// shift right
	parameter MAX   = 3'd5;
	parameter MIN   = 3'd6;
	parameter AVG   = 3'd7;		// average

// wire & reg
	reg [ 1:0] cur_state;		// for FSM
	reg [ 1:0] nxt_state;

	reg [ 7:0] data [63:0];		// for READ_DATA, store all data from IROM
	reg [ 5:0] counter;			// for READ_DATA, count from 0 ~ 63
								// for OPERATION MAX/MIN/AVG, 0~15: get max/min/avg value, 16: assign value to data array

	reg [ 3:0] cmd_store;		// for READ_CMD, store cmd for OPERATION

	reg [ 2:0] x;				// for OPERATION, range from +2 ~ +6
	reg [ 2:0] y;
	reg [ 2:0] x_op;			// for cmd == MAX/MIN/AVG, change x_op, y_op index to get max/min/avg value
	reg [ 2:0] y_op;
	reg [ 7:0] max;				// if cmd == MAX, get max value
	reg [ 7:0] min;				// if cmd == MIN, get min value
	reg [12:0] total;			// if cmd == AVG, sum all value, then assign total/16 to data array
								// 12-bit: each data is 8 bits, sum 16 datas, 4-bit, so 8 + 4 = 12

// FSM
  // nxt_state logic
	always @(*) begin
		case(cur_state) 
			READ_DATA: begin
				if(counter == 6'd63)
					nxt_state = READ_CMD;
				else
					nxt_state = READ_DATA;
			end

			READ_CMD: begin
				nxt_state = OPERATION;
			end

			OPERATION: begin
				case(cmd_store)
					WRITE: begin
						if(counter == 6'd63)
							nxt_state = DONE;
						else
							nxt_state = OPERATION;
					end

					SU: 
						nxt_state = READ_CMD;

					SD: 
						nxt_state = READ_CMD;

					SL: 
						nxt_state = READ_CMD;

					SR: 
						nxt_state = READ_CMD;

					MAX: begin
						if(counter == 6'd16)
							nxt_state = READ_CMD;
						else
							nxt_state = OPERATION;
					end

					MIN: begin
						if(counter == 6'd16)
							nxt_state = READ_CMD;
						else
							nxt_state = OPERATION;
					end

					AVG: begin
						if(counter == 6'd16)
							nxt_state = READ_CMD;
						else
							nxt_state = OPERATION;
					end
				endcase
			end

			DONE:
				nxt_state = DONE;
		endcase
	end

  // state register
	always @(posedge clk or posedge rst) begin
		if(rst)
			cur_state <= READ_DATA;
		else
			cur_state <= nxt_state;
	end

// counter
	always @(posedge clk or posedge rst) begin
		if(rst)
			counter <= 6'd0;
		else if(cur_state == READ_DATA || cur_state == OPERATION)
			counter <= counter + 6'd1;
		else
			counter <= 6'd0;
	end

// IROM_A & IROM_rd
	assign IROM_A = counter;
	assign IROM_rd = (cur_state == READ_DATA)? 1'd1 : 1'd0;

// data
	integer i;
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			for(i=0; i<63; i=i+1) begin
				data[i] <= 8'd0;
			end
		end
		else if(cur_state == READ_DATA)
			data[counter] <= IROM_Q;
		else if(cur_state == OPERATION) begin
			case(cmd_store)
				MAX: begin
					if(counter == 6'd16) begin
						// first row
						data[{y-3'd2, x-3'd2}] <= max;
						data[{y-3'd2, x-3'd1}] <= max;
						data[{y-3'd2, x     }] <= max;
						data[{y-3'd2, x+3'd1}] <= max;
						
						// second row
						data[{y-3'd1, x-3'd2}] <= max;
						data[{y-3'd1, x-3'd1}] <= max;
						data[{y-3'd1, x     }] <= max;
						data[{y-3'd1, x+3'd1}] <= max;

						// third row
						data[{y, x-3'd2}] <= max;
						data[{y, x-3'd1}] <= max;
						data[{y, x     }] <= max;
						data[{y, x+3'd1}] <= max;

						// forth row
						data[{y+3'd1, x-3'd2}] <= max;
						data[{y+3'd1, x-3'd1}] <= max;
						data[{y+3'd1, x     }] <= max;
						data[{y+3'd1, x+3'd1}] <= max;
					end
				end

				MIN: begin
					if(counter == 6'd16) begin
						// first row
						data[{y-3'd2, x-3'd2}] <= min;
						data[{y-3'd2, x-3'd1}] <= min;
						data[{y-3'd2, x     }] <= min;
						data[{y-3'd2, x+3'd1}] <= min;
						
						// second row
						data[{y-3'd1, x-3'd2}] <= min;
						data[{y-3'd1, x-3'd1}] <= min;
						data[{y-3'd1, x     }] <= min;
						data[{y-3'd1, x+3'd1}] <= min;

						// third row
						data[{y, x-3'd2}] <= min;
						data[{y, x-3'd1}] <= min;
						data[{y, x     }] <= min;
						data[{y, x+3'd1}] <= min;

						// forth row
						data[{y+3'd1, x-3'd2}] <= min;
						data[{y+3'd1, x-3'd1}] <= min;
						data[{y+3'd1, x     }] <= min;
						data[{y+3'd1, x+3'd1}] <= min;
					end
				end

				AVG: begin
					if(counter == 6'd16) begin
						// first row
						data[{y-3'd2, x-3'd2}] <= (total >> 4);
						data[{y-3'd2, x-3'd1}] <= (total >> 4);
						data[{y-3'd2, x     }] <= (total >> 4);
						data[{y-3'd2, x+3'd1}] <= (total >> 4);
						
						// second row
						data[{y-3'd1, x-3'd2}] <= (total >> 4);
						data[{y-3'd1, x-3'd1}] <= (total >> 4);
						data[{y-3'd1, x     }] <= (total >> 4);
						data[{y-3'd1, x+3'd1}] <= (total >> 4);

						// third row
						data[{y, x-3'd2}] <= (total >> 4);
						data[{y, x-3'd1}] <= (total >> 4);
						data[{y, x     }] <= (total >> 4);
						data[{y, x+3'd1}] <= (total >> 4);

						// forth row
						data[{y+3'd1, x-3'd2}] <= (total >> 4);
						data[{y+3'd1, x-3'd1}] <= (total >> 4);
						data[{y+3'd1, x     }] <= (total >> 4);
						data[{y+3'd1, x+3'd1}] <= (total >> 4);
					end
				end
			endcase
		end	
	end

// x & y
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			x <= 3'd4;
			y <= 3'd4;
		end
		else if(cur_state == OPERATION) begin
			case (cmd_store)
				SU: begin
					x <= x;

					if(y == 3'd2)
						y <= y;
					else
						y <= y - 3'd1;
				end 

				SD: begin
					x <= x;

					if(y == 3'd6)
						y <= y;
					else
						y <= y + 3'd1;
				end 

				SL: begin
					if(x == 3'd2)
						x <= x;
					else
						x <= x - 3'd1;

					y <= y;
				end 

				SR: begin
					if(x == 3'd6)
						x <= x;
					else
						x <= x + 3'd1;

					y <= y;
				end
			endcase
		end
	end

// x_op & y_op
	always @(posedge clk or posedge rst) begin
		if(rst) begin			// initialize to upper left index
			x_op <= x - 3'd2;
			y_op <= y - 3'd2;
		end
		else if(cur_state == OPERATION) begin
			if(cmd_store == MAX || cmd_store == MIN || cmd_store == AVG) begin
				if(counter <= 6'd15) begin
					if(x_op == x + 3'd1) begin
						x_op <= x - 3'd2;
						y_op <= y_op + 3'd1;
					end
					else
						x_op <= x_op + 3'd1;
				end
			end
		end
		else begin
			x_op <= x - 3'd2;
			y_op <= y - 3'd2;
		end
	end

// max & min & total
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			max   <= 8'd0;
			min   <= 8'b11111111;
			total <= 13'd0;
		end
		else if(cur_state == OPERATION) begin
			case(cmd_store)
				MAX:
					max <= (max < data[{y_op, x_op}])? data[{y_op, x_op}] : max;
				MIN:
					min <= (min > data[{y_op, x_op}])? data[{y_op, x_op}] : min;
				AVG:
					total <= total + data[{y_op, x_op}];
			endcase
		end	
		else begin
			max   <= 8'd0;
			min   <= 8'b11111111;
			total <= 13'd0;
		end
	end

// cmd_store
	always @(posedge clk or posedge rst) begin
		if(rst)
			cmd_store <= 4'd8;
		else if(cur_state == READ_CMD)
			cmd_store <= cmd;
		else
			cmd_store <= cmd_store;
	end

// busy
	assign busy = (cur_state == READ_CMD)? 1'd0 : 1'd1;

// IRAM_D & IRAM_A & IRAM_ceb & IRAM_web
	assign IRAM_D   = data[counter];
	assign IRAM_A   = counter;
	assign IRAM_ceb = (cur_state == OPERATION && cmd_store == WRITE)? 1'd1 : 1'd0;
	assign IRAM_web = (cur_state == OPERATION && cmd_store == WRITE)? 1'd0 : 1'd1;

// done
	assign done = (cur_state == DONE)? 1'd1 : 1'd0;

endmodule