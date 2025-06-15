`timescale 1ns/10ps
`include "ATCONV_Wrapper.v"
`include "BUS.v"
`include "./mem/ROM_Wrapper.v"
`include "./mem/SRAM_Wrapper.v"
`include "./include/define.v"

module top(
    input       				 clk      	,
    input       				 rst      	,
    output      				 done	  	,
	output 	[`BUS_ADDR_BITS-1:0] SRAM_A_L0	,
	output	[`BUS_DATA_BITS-1:0] SRAM_D_L0	,
	input	[`BUS_DATA_BITS-1:0] SRAM_Q_L0	,
	output 						 SRAM_ceb_L0,
	output 						 SRAM_web_L0,
	output 	[`BUS_ADDR_BITS-1:0] SRAM_A_L1	,
	output	[`BUS_DATA_BITS-1:0] SRAM_D_L1	,
	input	[`BUS_DATA_BITS-1:0] SRAM_Q_L1	,
	output 						 SRAM_ceb_L1,
	output 						 SRAM_web_L1,
	output 	[`BUS_ADDR_BITS-1:0] ROM_A_IMG	,
	output 						 ROM_rd_IMG	,
	input 	[`BUS_DATA_BITS-1:0] ROM_Q_IMG
);

wire [`BUS_ADDR_BITS-1:0] ADDR_M0  ; 
wire [`BUS_DATA_BITS-1:0] RDATA_M0 ;
wire [`BUS_DATA_BITS-1:0] WDATA_M0 ;
wire [`BUS_ID_BITS  -1:0] ID_M0	   ;
wire [`BUS_LEN_BITS -1:0] BLEN_M0  ;
wire 					  RLAST_M0 ;
wire 					  RVALID_M0;
wire 					  RREADY_M0;
wire 					  WLAST_M0 ;
wire 					  WVALID_M0;
wire 					  WREADY_M0;

wire [`BUS_ADDR_BITS-1:0] ADDR_S0  ; 
wire [`BUS_DATA_BITS-1:0] RDATA_S0 ;
wire [`BUS_LEN_BITS -1:0] BLEN_S0  ;
wire 					  RLAST_S0 ;
wire 					  RVALID_S0;
wire 					  RREADY_S0;

wire [`BUS_ADDR_BITS-1:0] ADDR_S1  ; 
wire [`BUS_DATA_BITS-1:0] RDATA_S1 ;
wire [`BUS_DATA_BITS-1:0] WDATA_S1 ;
wire [`BUS_LEN_BITS -1:0] BLEN_S1  ;
wire 				      RLAST_S1 ;
wire 				      RVALID_S1;
wire 				      RREADY_S1;
wire 				      WLAST_S1 ;
wire 				      WVALID_S1;
wire 				      WREADY_S1;

wire [`BUS_ADDR_BITS-1:0] ADDR_S2  ; 
wire [`BUS_DATA_BITS-1:0] RDATA_S2 ;
wire [`BUS_DATA_BITS-1:0] WDATA_S2 ;
wire [`BUS_LEN_BITS -1:0] BLEN_S2  ;
wire 					  RLAST_S2 ;
wire 					  RVALID_S2;
wire 					  RREADY_S2;
wire 					  WLAST_S2 ;
wire 					  WVALID_S2;
wire 					  WREADY_S2;

// Master ATCONV
ATCONV_Wrapper Master_0(
	.bus_clk	(clk	    ), 
	.bus_rst	(rst	    ), 
	.RDATA_M    (RDATA_M0   ),  
    .RLAST_M    (RLAST_M0   ),  
    .WREADY_M   (WREADY_M0  ), 
    .RREADY_M   (RREADY_M0  ), 
    .ID_M       (ID_M0      ),	  
    .ADDR_M     (ADDR_M0    ),	  
    .WDATA_M    (WDATA_M0   ),  
    .BLEN_M     (BLEN_M0    ),   
    .WLAST_M    (WLAST_M0   ),  
    .WVALID_M   (WVALID_M0  ), 
    .RVALID_M   (RVALID_M0  ), 
	.done		(done       )
);

// Bridge
BUS u_BUS(
	.bus_clk    (clk        ),
	.bus_rst    (rst        ),
	.ID_M0      (ID_M0      ),
	.ADDR_M0    (ADDR_M0    ),
	.WDATA_M0   (WDATA_M0   ),
	.BLEN_M0    (BLEN_M0    ),
	.WLAST_M0   (WLAST_M0   ),
	.WVALID_M0  (WVALID_M0  ),
	.RVALID_M0  (RVALID_M0  ),
	.RDATA_M0   (RDATA_M0   ),
	.RLAST_M0   (RLAST_M0   ),
	.WREADY_M0  (WREADY_M0  ),
	.RREADY_M0  (RREADY_M0  ),
	.ADDR_S0    (ADDR_S0    ),
	.BLEN_S0    (BLEN_S0    ),
	.RVALID_S0  (RVALID_S0  ),
	.RDATA_S0   (RDATA_S0   ),
	.RLAST_S0   (RLAST_S0   ),
	.RREADY_S0  (RREADY_S0  ),
	.ADDR_S1    (ADDR_S1    ),
	.WDATA_S1   (WDATA_S1   ),
	.BLEN_S1    (BLEN_S1    ),
	.WLAST_S1   (WLAST_S1   ),
	.WVALID_S1  (WVALID_S1  ),
	.RVALID_S1  (RVALID_S1  ),
	.RDATA_S1   (RDATA_S1   ),
	.RLAST_S1   (RLAST_S1   ),
	.WREADY_S1  (WREADY_S1  ),
	.RREADY_S1  (RREADY_S1  ),
	.ADDR_S2    (ADDR_S2    ),
	.WDATA_S2   (WDATA_S2   ),
	.BLEN_S2    (BLEN_S2    ),
	.WLAST_S2   (WLAST_S2   ),
	.WVALID_S2  (WVALID_S2  ),
	.RVALID_S2  (RVALID_S2  ),
	.RDATA_S2   (RDATA_S2   ),
	.RLAST_S2   (RLAST_S2   ),
	.WREADY_S2  (WREADY_S2  ),
	.RREADY_S2  (RREADY_S2  )
);

// Slave Image ROM
ROM_Wrapper Slave_0(
	.bus_clk	(clk	 	), 
	.bus_rst	(rst		), 
	.ADDR_S		(ADDR_S0	),  
	.BLEN_S		(BLEN_S0	),  
	.RVALID_S	(RVALID_S0	),
	.RDATA_S	(RDATA_S0	), 
	.RLAST_S	(RLAST_S0	), 
	.RREADY_S	(RREADY_S0	),
	.ROM_rd		(ROM_rd_IMG	), 
	.ROM_A		(ROM_A_IMG	),  
	.ROM_Q		(ROM_Q_IMG	) 
);

// Slave Layer0 SRAM
SRAM_Wrapper Slave_1(
    .bus_clk	(clk		),
    .bus_rst    (rst        ),     
    .ADDR_S     (ADDR_S1    ),     
    .WDATA_S    (WDATA_S1   ),    
    .BLEN_S     (BLEN_S1    ),     
    .WLAST_S    (WLAST_S1   ),    
    .WVALID_S   (WVALID_S1  ),   
    .RVALID_S   (RVALID_S1  ),   
    .RDATA_S    (RDATA_S1   ),    
    .RLAST_S    (RLAST_S1   ),    
    .WREADY_S   (WREADY_S1  ),   
    .RREADY_S   (RREADY_S1  ),
	.SRAM_D		(SRAM_D_L0  ), 
	.SRAM_A		(SRAM_A_L0	), 
	.SRAM_ceb	(SRAM_ceb_L0),
	.SRAM_web	(SRAM_web_L0),
	.SRAM_Q		(SRAM_Q_L0	)  
);

// Slave Layer1 SRAM
SRAM_Wrapper Slave_2(
	.bus_clk	(clk		),
    .bus_rst    (rst        ),    
    .ADDR_S     (ADDR_S2    ),     
    .WDATA_S    (WDATA_S2   ),    
    .BLEN_S     (BLEN_S2    ),     
    .WLAST_S    (WLAST_S2   ),    
    .WVALID_S   (WVALID_S2  ),   
    .RVALID_S   (RVALID_S2  ),   
    .RDATA_S    (RDATA_S2   ),    
    .RLAST_S    (RLAST_S2   ),    
    .WREADY_S   (WREADY_S2  ),   
    .RREADY_S   (RREADY_S2  ),
	.SRAM_D		(SRAM_D_L1  ), 
	.SRAM_A		(SRAM_A_L1	), 
	.SRAM_ceb	(SRAM_ceb_L1),
	.SRAM_web	(SRAM_web_L1),
	.SRAM_Q		(SRAM_Q_L1	)   
);

endmodule