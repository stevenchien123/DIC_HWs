`timescale 1ns/10ps
`define CYCLE         10.0
`define MAX_CYCLE     10000
`define PATTERN_DIR   "./dat"
`define TOTAL_PAT     10
`define DATA_COUNT    20  // 每個 pattern 的 (x, y) 筆數

module testfixture;

    reg clk, reset;
    reg [7:0] x, y;
    wire [16:0] area;
    wire done;
    integer i, j, err, total_err;
    reg [16:0] expected_area;
    reg [7:0] x_values [`DATA_COUNT-1:0];
    reg [7:0] y_values [`DATA_COUNT-1:0];
    reg [31:0] out_mem [0:`DATA_COUNT*2]; // N pairs + 1 area = 2N+1 entries
    integer cycle_cnt;
    string pattern_file;

    MCH mch (
        .clk(clk),
        .X(x),
        .Y(y),
        .reset(reset),
        .Done(done),
        .area(area)
    );

    // Clock generation
    always #(`CYCLE/2) clk = ~clk;

    initial begin
        cycle_cnt = 0;
        clk = 0;
        err = 0;
        total_err = 0;
        reset = 1;
        #(`CYCLE) reset = 0;
        for (j = 0; j < `TOTAL_PAT; j = j + 1) begin
            pattern_file = $sformatf("%s/golden%0d.dat", `PATTERN_DIR, j);
            $display("\n================ Running pattern %0d ================\n", j);
            $readmemh(pattern_file, out_mem);

            // Parse x, y
            for (i = 0; i < `DATA_COUNT; i = i + 1) begin
                x_values[i] = out_mem[i * 2];
                y_values[i] = out_mem[i * 2 + 1];
            end
            expected_area = out_mem[`DATA_COUNT * 2][16:0];

           

            for (i = 0; i < `DATA_COUNT; i = i + 1) begin
                @(negedge clk);
                x = x_values[i];
                y = y_values[i];
            end

            wait (done);
            @(negedge clk);

            if (area !== expected_area) begin
                $display("[FAIL] Pattern %0d: Expected area = %h, but got = %h", j, expected_area, area);
                err = err + 1;
            end else begin
                $display("[PASS] Pattern %0d: area = %h", j, area);
            end

            #(`CYCLE);
        end

        $display("\n====================== RESULT ======================\n");
        total_err = err;
        if (total_err == 0)begin
            $display("All %0d patterns passed!\n", `TOTAL_PAT);
            $display("Cycle: %0d \n", cycle_cnt);
        end
        else
            $display("%0d / %0d patterns failed.\n", total_err, `TOTAL_PAT);

        $finish;
    end

    initial begin
        #(`CYCLE * `MAX_CYCLE);
        $display("[TIMEOUT] Simulation time limit exceeded.");
        $stop;
        $finish;
    end
    always@(posedge clk) cycle_cnt = cycle_cnt + 1;


endmodule
