module Brkung_tb;

    // Inputs
    reg [15:0] A_tb;
    reg [15:0] B_tb;
    reg        Cin_tb;

    // Outputs
    wire [15:0] Sum_tb;
    wire        Cout_tb;

    // Instantiate the Device Under Test (DUT)
    Brkung dut (
        .A(A_tb),
        .B(B_tb),
        .Cin(Cin_tb),
        .Sum(Sum_tb),
        .Cout(Cout_tb)
    );

    // Test cases
    initial begin
        // Use $monitor to print results whenever an input changes
        $monitor("Time=%0t | A = %h | B = %h | Cin = %b | Sum = %h | Cout = %b",
                 $time, A_tb, B_tb, Cin_tb, Sum_tb, Cout_tb);

        // Test 1: Simple
        A_tb = 16'h0001; B_tb = 16'h0000; Cin_tb = 0; #10;
        // Expected: Sum = 1, Cout = 0

        // Test 2: Ripple all the way
        A_tb = 16'hFFFF; B_tb = 16'h0000; Cin_tb = 1; #10;
        // Expected: Sum = 0, Cout = 1

        // Test 3: Generate and ripple
        A_tb = 16'hFFFF; B_tb = 16'h0001; Cin_tb = 0; #10;
        // Expected: Sum = 0, Cout = 1

        // Test 4: General case
        A_tb = 16'h1234; B_tb = 16'hABCD; Cin_tb = 0; #10;
        // Expected: 1234 + ABCD = BE01. Sum = BE01, Cout = 0

        // Test 5: General case with Cin
        A_tb = 16'h1234; B_tb = 16'hABCD; Cin_tb = 1; #10;
        // Expected: 1234 + ABCD + 1 = BE02. Sum = BE02, Cout = 0

        // Test 6: Big carry
        A_tb = 16'hF000; B_tb = 16'h2000; Cin_tb = 0; #10;
        // Expected: F000 + 2000 = 11000. Sum = 1000, Cout = 1
         A_tb = 16'hBABE; B_tb = 16'hDEAD; Cin_tb = 0; #10;
         A_tb = 16'hBABE; B_tb = 16'hDEAD; Cin_tb = 1; #10;
         A_tb = 16'hFFFF; B_tb = 16'hFFFF; Cin_tb = 0; #10;
         A_tb = 16'hFFFF; B_tb = 16'hFFFF; Cin_tb = 1; #10;

         A_tb = 16'hFADE; B_tb = 16'hDEAF; Cin_tb = 0; #10;
         A_tb = 16'hFADE; B_tb = 16'hDEAF; Cin_tb = 1; #10;
          $finish; // End simulation
    end

endmodule