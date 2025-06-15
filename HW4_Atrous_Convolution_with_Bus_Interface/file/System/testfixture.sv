`timescale 1ns/10ps
`include "top.v"
`include "./include/define.v"
`include "./mem/ROM.sv"
`include "./mem/SRAM.sv"
`define CYCLE       50   
`define END_CYCLE   1000000000  // Simulation end cycle
`define tb1   // Modify to test different patterns

`ifdef tb1
    `define IMG_DATA             "./dat/tb1/img.dat"
    `define LAYER0_GOLDEN        "./dat/tb1/layer0_golden.dat"
    `define LAYER1_GOLDEN        "./dat/tb1/layer1_golden.dat"
`endif

`ifdef tb2
    `define IMG_DATA             "./dat/tb2/img.dat"
    `define LAYER0_GOLDEN        "./dat/tb2/layer0_golden.dat"
    `define LAYER1_GOLDEN        "./dat/tb2/layer1_golden.dat"
`endif

`ifdef tb3
    `define IMG_DATA             "./dat/tb3/img.dat"
    `define LAYER0_GOLDEN        "./dat/tb3/layer0_golden.dat"
    `define LAYER1_GOLDEN        "./dat/tb3/layer1_golden.dat"
`endif

module testfixture;

reg [15:0] imgData       [0:4095];
reg [15:0] layer0_golden [0:4095];
reg [15:0] layer1_golden [0:1023];

reg clk=0, rst=0;
reg [30:0] cycle=0;
wire done;

wire [`BUS_ADDR_BITS-1:0] SRAM_A_L0;
wire [`BUS_DATA_BITS-1:0] SRAM_D_L0; 
wire [`BUS_DATA_BITS-1:0] SRAM_Q_L0; 
wire SRAM_ceb_L0;
wire SRAM_web_L0;

wire [`BUS_ADDR_BITS-1:0] SRAM_A_L1;
wire [`BUS_DATA_BITS-1:0] SRAM_D_L1; 
wire [`BUS_DATA_BITS-1:0] SRAM_Q_L1; 
wire SRAM_ceb_L1;
wire SRAM_web_L1;

wire [`BUS_ADDR_BITS-1:0] ROM_A_IMG;
wire [`BUS_DATA_BITS-1:0] ROM_Q_IMG;
wire ROM_rd_IMG;

top u_top(
    .clk            (clk        ), 
    .rst            (rst        ),
    .done           (done       ),
    .SRAM_A_L0      (SRAM_A_L0  ),
    .SRAM_D_L0      (SRAM_D_L0  ),
    .SRAM_Q_L0      (SRAM_Q_L0  ),
    .SRAM_ceb_L0    (SRAM_ceb_L0),
    .SRAM_web_L0    (SRAM_web_L0),
    .SRAM_A_L1      (SRAM_A_L1  ),
    .SRAM_D_L1      (SRAM_D_L1  ),
    .SRAM_Q_L1      (SRAM_Q_L1  ),
    .SRAM_ceb_L1    (SRAM_ceb_L1),
    .SRAM_web_L1    (SRAM_web_L1),
    .ROM_A_IMG      (ROM_A_IMG  ),
    .ROM_rd_IMG     (ROM_rd_IMG ),
    .ROM_Q_IMG      (ROM_Q_IMG  )
);

ROM #(`BUS_DATA_BITS, 4096) i_ROM(
	.clk		(clk            ),
	.ROM_rd		(ROM_rd_IMG		), 
	.ROM_addr	(ROM_A_IMG	    ), 
	.ROM_data	(ROM_Q_IMG	    )
);

SRAM #(`BUS_DATA_BITS, 4096) i_SRAM_L0(
	.clk		(clk            ),
	.SRAM_D		(SRAM_D_L0		), 
	.SRAM_A		(SRAM_A_L0	    ), 
	.SRAM_ceb	(SRAM_ceb_L0    ),
	.SRAM_web	(SRAM_web_L0    ),
	.SRAM_Q		(SRAM_Q_L0		)
);

SRAM #(`BUS_DATA_BITS, 1024) i_SRAM_L1(
	.clk		(clk            ),
	.SRAM_D		(SRAM_D_L1		), 
	.SRAM_A		(SRAM_A_L1	    ), 
	.SRAM_ceb	(SRAM_ceb_L1    ),
	.SRAM_web	(SRAM_web_L1    ),
	.SRAM_Q		(SRAM_Q_L1		)
);

always #(`CYCLE/2) clk = ~clk;

initial 
begin
    $display("-----------------------------------------------------\n");
    $display("START!!! Simulation Start .....\n");
    $display("-----------------------------------------------------\n");
    @(negedge clk);
    #1;
    rst = 1'b1;
    #(`CYCLE*3);
    #1;
    rst = 1'b0;  // release rst
end

initial begin
    $readmemb(`IMG_DATA,       imgData);
    $readmemb(`LAYER0_GOLDEN,  layer0_golden);
    $readmemb(`LAYER1_GOLDEN,  layer1_golden);
end

integer r;
initial begin
    for(r=0; r<4096; r=r+1) begin
        i_ROM.sti_M[r] = imgData[r];
    end
end

always @(posedge clk) begin
    cycle <= cycle + 31'd1;
end

integer i, j, m, k, err0, err1;
initial begin
    wait(done);

    // ---------------- Layer‑0 ----------------
    err0 = 0;
    for (k=0;k<4096;k=k+1) begin
        if (i_SRAM_L0.SRAM_M[k] !== layer0_golden[k])
            begin
                err0 = err0 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 0 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", i_SRAM_L0.SRAM_M[k], layer0_golden[k]);
                    end
                end
            end
        else
        if (i_SRAM_L0.SRAM_M[k] == 16'dx)
            begin
                err0 = err0 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 0 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", i_SRAM_L0.SRAM_M[k], layer0_golden[k]);
                    end
                end
            end
        else
        ;
    end
    if (err0 == 0)
        $display("Layer 0 output is correct !");
    else
        $display("Layer 0 output be found %d error !", err0);

    // // ---------------- Layer‑1 ----------------
    err1 = 0;
    for (k=0;k<1024;k=k+1) begin
        if (i_SRAM_L1.SRAM_M[k] !== layer1_golden[k])
            begin
                err1 = err1 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 1 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", i_SRAM_L1.SRAM_M[k], layer1_golden[k]);
                    end
                end
            end
        else
        if (i_SRAM_L1.SRAM_M[k] == 16'dx)
            begin
                err1 = err1 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 1 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", i_SRAM_L1.SRAM_M[k], layer1_golden[k]);
                    end
                end
            end
        else
        ;
    end
        if (err1 == 0)
        $display("Layer 1 output is correct !");
    else
        $display("Layer 1 output be found %d error !", err1);

    $display("===============================================================================================================================================================\n");
    for (i = 0; i < 32; i++) begin
      for (j = 0; j < 32; j++) begin
        m = i * 32 + j;
        $write("%h ", i_SRAM_L1.SRAM_M[m]);
      end
      $write("\n");
    end
	$display("\n===============================================================================================================================================================");

    $display(" ");
    $display("-----------------------------------------------------\n");
    $display("--------------------- S U M M A R Y -----------------\n");

    if (err0==0) 
        $display("Congratulations! Layer 0 data have been generated successfully! The result is PASS!!\n"); 
    else 
        $display("FAIL!!!  There are %d errors! in Layer 0 \n", err0);
    if (err1==0) 
        $display("Congratulations! Layer 1 data have been generated successfully! The result is PASS!!\n");
    else 
        $display("FAIL!!!  There are %d errors! in Layer 1 \n", err1);

    $display("terminate at %d cycle",cycle);
    $display("-----------------------------------------------------\n");
    #(`CYCLE/2);
    $finish;
end

initial begin
    #`END_CYCLE;
    $display("\nSimulation TIMEOUT!\n");
    $finish;
end

endmodule
