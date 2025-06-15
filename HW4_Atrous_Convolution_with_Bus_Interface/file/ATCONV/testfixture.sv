`timescale 1ns/10ps
`define CYCLE       50  
`define END_CYCLE   10000000  // Simulation end cycle
`include "./mem/ROM.sv"
`include "./mem/SRAM.sv"
`define tb1  // Modify to test different pattern

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

// image interface
wire ROM_rd;
wire [11:0] iaddr;
wire [15:0] idata;

wire done;

reg [30:0] cycle=0;
// Layer‑0 wires
wire layer0_ceb, layer0_web;
wire [11:0] layer0_A;
wire [15:0] layer0_D;
wire [15:0] layer0_Q;

// Layer‑1 wires
wire layer1_ceb, layer1_web;
wire [11:0] layer1_A;
wire [15:0] layer1_D;
wire [15:0] layer1_Q;

ATCONV u_ATCONV (
    .clk        (clk),
    .rst        (rst),
    .ROM_rd     (ROM_rd),
    .iaddr      (iaddr),
    .idata      (idata),

    .layer0_ceb   (layer0_ceb), .layer0_web(layer0_web), .layer0_A(layer0_A), .layer0_D(layer0_D), .layer0_Q(layer0_Q),
    .layer1_ceb   (layer1_ceb), .layer1_web(layer1_web), .layer1_A(layer1_A), .layer1_D(layer1_D), .layer1_Q(layer1_Q),

    .done      (done)
);

ROM #(16, 4096) IMG_ROM (
    .clk        (clk    ),
    .rst        (rst    ),
    .ROM_rd     (ROM_rd ),
    .ROM_addr   (iaddr  ),
    .ROM_data   (idata  )
);

SRAM #(16, 4096) L0_SRAM (
    .clk      (clk),
    .SRAM_ceb (layer0_ceb),
    .SRAM_web (layer0_web),
    .SRAM_A   (layer0_A),
    .SRAM_D   (layer0_D),
    .SRAM_Q   (layer0_Q)
);

SRAM #(16, 1024) L1_SRAM (
    .clk      (clk),
    .SRAM_ceb (layer1_ceb),
    .SRAM_web (layer1_web),
    .SRAM_A   (layer1_A), // only 0~1023 used
    .SRAM_D   (layer1_D),
    .SRAM_Q   (layer1_Q)
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
    rst = 1'b0;  
end

initial begin
    $readmemb(`IMG_DATA,       imgData);
    $readmemb(`LAYER0_GOLDEN,  layer0_golden);
    $readmemb(`LAYER1_GOLDEN,  layer1_golden);
end

integer r;
initial begin
    for(r=0; r<4096; r=r+1) begin
        IMG_ROM.sti_M[r] = imgData[r];
    end
end

always @(posedge clk)
     begin
         cycle <= cycle + 31'd1;
     end

integer i, j, m, k, err0, err1;
initial begin
    wait(done);

    // ---------------- Layer‑0 ----------------
    err0 = 0;
    for (k=0;k<4096;k=k+1) begin
        if (L0_SRAM.SRAM_M[k] !== layer0_golden[k])
            begin
                err0 = err0 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 0 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", L0_SRAM.SRAM_M[k], layer0_golden[k]);
                    end
                end
            end
        else
        if (L0_SRAM.SRAM_M[k] == 16'dx)
            begin
                err0 = err0 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 0 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", L0_SRAM.SRAM_M[k], layer0_golden[k]);
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

    // ---------------- Layer‑1 ----------------
    err1 = 0;
    for (k=0;k<1024;k=k+1) begin
        if (L1_SRAM.SRAM_M[k] !== layer1_golden[k])
            begin
                err1 = err1 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 1 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", L1_SRAM.SRAM_M[k], layer1_golden[k]);
                    end
                end
            end
        else
        if (L1_SRAM.SRAM_M[k] == 16'dx)
            begin
                err1 = err1 + 1;
                begin
                    if(k < 128)
                    begin
                        $display("WRONG! Layer 1 output , Pixel %d is wrong!", k);
                        $display("               The output data is %h, but the expected data is %h ", L1_SRAM.SRAM_M[k], layer1_golden[k]);
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
        $write("%h ", L1_SRAM.SRAM_M[m]);
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
