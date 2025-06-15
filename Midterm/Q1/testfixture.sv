module testfixture;

    reg [3:0] A, B, C, num1, num2, num3, num4, num5, num6;
    wire [3:0] min_C2, max_C2, median6;
    integer file_c2, file_mf6, error_c2, error_mf6;
    integer i, scan_result;
    reg [3:0] expected_median, expected_min_C2, expected_max_C2;

    Comparator2 C2(
        .A      (A)     ,
        .B      (B)     ,
        .min    (min_C2),
        .max    (max_C2)
    );

    MedianFinder_6num MF6(
        .num1   (num1)   , 
        .num2   (num2)   , 
        .num3   (num3)   , 
        .num4   (num4)   , 
        .num5   (num5)   , 
        .num6   (num6)   ,
        .median (median6)
    );

    initial begin
        error_c2 = 0;
        error_mf6 = 0;

        file_c2 = $fopen("./golden_c2.dat", "r");
        file_mf6 = $fopen("./golden_mf6.dat", "r");

        if (file_c2 == 0 || file_mf6 == 0) begin
            $display("Error: Failed to open one or more golden data files.");
            $finish;
        end

        for (i = 0; i < 100; i = i + 1) begin
            scan_result = $fscanf(file_c2, "%d %d %d %d\n", A, B, expected_min_C2, expected_max_C2);
            #10;
            if (min_C2 == expected_min_C2 && max_C2 == expected_max_C2) begin
                // $display("Test3 %0d Passed! Median: %0d (Expected: %0d)", i, median3, expected_median);
            end 
            else begin
                if(min_C2 != expected_min_C2 && max_C2 != expected_max_C2) begin
                    $display("Stage1: %0d Failed! Min: %0d  (Expected: %0d) Max: %0d (Expected: %0d)", i, min_C2, expected_min_C2, max_C2, expected_max_C2);
                end
                else if(min_C2 != expected_min_C2 && max_C2 == expected_max_C2) begin
                    $display("Stage1: %0d Failed! Min: %0d (Expected: %0d) Max: Pass", i, min_C2, expected_min_C2);
                end
                else if(min_C2 == expected_min_C2 && max_C2 != expected_max_C2) begin
                    $display("Stage1: %0d Failed! Min: Pass                Max: %0d (Expected: %0d)", i, max_C2, expected_max_C2);
                end
                
                error_c2 = error_c2 + 1;
            end
        end
        for (i = 0; i < 1000; i = i + 1) begin
            scan_result = $fscanf(file_mf6, "%d %d %d %d %d %d %d\n", num1, num2, num3, num4, num5, num6, expected_median);
            #10;
            if (median6 == expected_median) begin
                // $display("Test7 %0d Passed! Median: %0d (Expected: %0d)", i, median7, expected_median);
            end 
            else begin
                $display("Stage2: %0d Failed! Median: %0d (Expected: %0d)", i, median6, expected_median);
                error_mf6 = error_mf6 + 1;
            end
        end
    
        $fclose(file_c2);
        $fclose(file_mf6);

        if(error_c2 != 0) begin
            $display("-------------------   There are %4d errors in Comparator2 !   -------------------\n", error_c2);
        end
        else begin
            $display("-------------              Stage1: Comparator2 Pass !                -------------\n");
        end
        if(error_mf6 != 0) begin
            $display("-------------------There are %4d errors in MedianFinder_6num !-------------------\n", error_mf6);
        end
        else begin
            $display("-------------              Stage2: MedianFinder_6num Pass !          -------------\n");
        end

        if(error_c2==0&error_mf6==0)begin
            $display("                   //////////////////////////               ");
            $display("                   /                        /       |\__|\  ");
            $display("                   /  Congratulations !!    /      / O.O  | ");
            $display("                   /                        /    /_____   | ");
            $display("                   /  Simulation PASS !!    /   /^ ^ ^ \\  |");
            $display("                   /                        /  |^ ^ ^ ^ |w| ");
            $display("                   //////////////////////////   \\m___m__|_|");
            $display("\n");
        end
        else begin
            $display("                   //////////////////////////               ");
            $display("                   /                        /       |\__|\  ");
            $display("                   /  OOPS !!               /      / X.X  | ");
            $display("                   /                        /    /_____   | ");
            $display("                   /  Simulation Failed !!  /   /^ ^ ^ \\  |");
            $display("                   /                        /  |^ ^ ^ ^ |w| ");
            $display("                   //////////////////////////   \\m___m__|_|");
            $display("\n");
        end
        $finish;
    end
endmodule
