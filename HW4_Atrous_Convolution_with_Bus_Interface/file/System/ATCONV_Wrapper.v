`timescale 1ns/10ps
`include "./include/define.v"

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

endmodule
