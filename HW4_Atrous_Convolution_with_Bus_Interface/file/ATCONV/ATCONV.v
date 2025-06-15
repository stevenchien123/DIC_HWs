`timescale 1ns/10ps

module  ATCONV(
        input		clk       ,
        input		rst       ,
        output          ROM_rd    ,
        output [11:0]	iaddr     ,
        input  [15:0]	idata     ,
        output          layer0_ceb,
        output          layer0_web,   
        output [11:0]   layer0_A  ,
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

endmodule
