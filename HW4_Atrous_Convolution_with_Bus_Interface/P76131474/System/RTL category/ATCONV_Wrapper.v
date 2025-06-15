`timescale 1ns/10ps
`include "./include/define.v"
`include "../ATCONV/ATCONV.v"

module ATCONV_Wrapper(
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    input         [`BUS_DATA_BITS-1:0]  RDATA_M  ,
    input 	      					 	RLAST_M  ,
    input 	      					 	WREADY_M ,
    input 	      					 	RREADY_M ,
    output        [`BUS_ID_BITS  -1:0]  ID_M	 ,
    output        [`BUS_ADDR_BITS-1:0]  ADDR_M	 ,
    output        [`BUS_DATA_BITS-1:0]  WDATA_M  ,
    output        [`BUS_LEN_BITS -1:0]  BLEN_M   ,
    output 						 	    WLAST_M  ,
    output   						    WVALID_M ,
    output   						    RVALID_M ,
    output                              done   
);

    /////////////////////////////////
	// Please write your code here //
	/////////////////////////////////

// wire & reg
    wire                      ROM_rd;
    wire [`BUS_ADDR_BITS-1:0] iaddr;

    wire                      layer0_ceb;
    wire                      layer0_web;
    wire [`BUS_ADDR_BITS:0]   layer0_A;
    wire [`BUS_DATA_BITS:0]   layer0_D;

    wire                      layer1_ceb;
    wire                      layer1_web;
    wire [`BUS_ADDR_BITS:0]   layer1_A;
    wire [`BUS_DATA_BITS:0]   layer1_D;

    wire [`BUS_DATA_BITS:0]   RDATA_M_READY;

// AVCONV instantiation
    ATCONV ATCONV_inst (
        .clk(bus_clk),        
        .rst(bus_rst),        
        .ROM_rd(ROM_rd),     
        .iaddr(iaddr),      
        .idata(RDATA_M),      
        .layer0_ceb(layer0_ceb), 
        .layer0_web(layer0_web), 
        .layer0_A(layer0_A),   
        .layer0_D(layer0_D),   
        .layer0_Q(RDATA_M),   
        .layer1_ceb(layer1_ceb), 
        .layer1_web(layer1_web), 
        .layer1_A(layer1_A),   
        .layer1_D(layer1_D),   
        .layer1_Q(RDATA_M),   
        .done(done)
    );

// ID_M
    assign ID_M = (ROM_rd == 1'b1)? 2'd0 : ((layer0_ceb)? 2'd1 : 2'd2);

// ADDR_M
    assign ADDR_M = (ROM_rd == 1'b1)? iaddr : ((layer0_ceb)? layer0_A : layer1_A);

// WDATA_M
    assign WDATA_M = (layer0_ceb)? layer0_D : layer1_D;

// BLEN_M, Get 1 data per clock, so BLEN_M = 1
    assign BLEN_M = `BUS_LEN_BITS'd1;

// WLAST_M
    assign WLAST_M = 1'b1;

// WVALID_M
    assign WVALID_M = ((layer0_ceb == 1'b1 && layer0_web == 1'b0) || (layer1_ceb == 1'b1 && layer1_web == 1'b0))? 1'b1 : 1'b0;

// RVALID_M
    assign RVALID_M = (ROM_rd == 1'b1 || (layer0_ceb == 1'b1 && layer0_web == 1'b1) || (layer1_ceb == 1'b1 && layer1_web == 1'b1));


endmodule
