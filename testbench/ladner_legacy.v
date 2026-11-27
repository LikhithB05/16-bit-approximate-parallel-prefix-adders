module testbench;

    // Inputs
    reg [15:0] A_tb;
    reg [15:0] B_tb;
    reg        Cin_tb;

    // Outputs
    wire [15:0] Sum_tb;
    wire        Cout_tb;

    // Instantiate the Device Under Test (DUT)
    perfectladner dut (
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
  
          // === EXTREME CORNER CASES ===
        A_tb = 16'h0000; B_tb = 16'h0000; Cin_tb = 0; #10;  // 1
        A_tb = 16'h0000; B_tb = 16'h0000; Cin_tb = 1; #10;  // 2
        A_tb = 16'hFFFF; B_tb = 16'h0000; Cin_tb = 0; #10;  // 3
        A_tb = 16'hFFFF; B_tb = 16'h0000; Cin_tb = 1; #10;  // 4
        A_tb = 16'h0000; B_tb = 16'hFFFF; Cin_tb = 0; #10;  // 5
        A_tb = 16'h0000; B_tb = 16'hFFFF; Cin_tb = 1; #10;  // 6
        A_tb = 16'hFFFF; B_tb = 16'hFFFF; Cin_tb = 0; #10;  // 7
        A_tb = 16'hFFFF; B_tb = 16'hFFFF; Cin_tb = 1; #10;  // 8
        
        // === POWER OF TWO BOUNDARIES ===
        A_tb = 16'h0001; B_tb = 16'h0001; Cin_tb = 0; #10;  // 9
        A_tb = 16'h8000; B_tb = 16'h8000; Cin_tb = 0; #10;  // 10
        A_tb = 16'h4000; B_tb = 16'h4000; Cin_tb = 0; #10;  // 11
        A_tb = 16'h2000; B_tb = 16'h2000; Cin_tb = 0; #10;  // 12
        A_tb = 16'h1000; B_tb = 16'h1000; Cin_tb = 0; #10;  // 13
        
        // === COMPLEMENTARY PATTERNS ===
        A_tb = 16'hAAAA; B_tb = 16'h5555; Cin_tb = 0; #10;  // 14
        A_tb = 16'hAAAA; B_tb = 16'h5555; Cin_tb = 1; #10;  // 15
        A_tb = 16'h3333; B_tb = 16'hCCCC; Cin_tb = 0; #10;  // 16
        A_tb = 16'h0F0F; B_tb = 16'hF0F0; Cin_tb = 0; #10;  // 17
        A_tb = 16'h00FF; B_tb = 16'hFF00; Cin_tb = 0; #10;  // 18
        A_tb = 16'h00FF; B_tb = 16'hFF00; Cin_tb = 1; #10;  // 19
        
        // === LADNER-FISCHER PREFIX TREE SPECIFIC ===
        // Level 1 Operators
        A_tb = 16'h0003; B_tb = 16'h0003; Cin_tb = 0; #10;  // 20
        A_tb = 16'h0006; B_tb = 16'h0006; Cin_tb = 0; #10;  // 21
        A_tb = 16'h000C; B_tb = 16'h000C; Cin_tb = 0; #10;  // 22
        A_tb = 16'h0018; B_tb = 16'h0018; Cin_tb = 0; #10;  // 23
        
        // Level 2 Operators
        A_tb = 16'h000F; B_tb = 16'h0001; Cin_tb = 0; #10;  // 24
        A_tb = 16'h000F; B_tb = 16'h0001; Cin_tb = 1; #10;  // 25
        A_tb = 16'h00F0; B_tb = 16'h0010; Cin_tb = 0; #10;  // 26
        A_tb = 16'h00F0; B_tb = 16'h0010; Cin_tb = 1; #10;  // 27
        
        // Level 3 Operators
        A_tb = 16'h00FF; B_tb = 16'h0001; Cin_tb = 0; #10;  // 28
        A_tb = 16'h00FF; B_tb = 16'h0001; Cin_tb = 1; #10;  // 29
        A_tb = 16'h0FFF; B_tb = 16'h0001; Cin_tb = 0; #10;  // 30
        A_tb = 16'h0FFF; B_tb = 16'h0001; Cin_tb = 1; #10;  // 31
        
        // Level 4 Operator
        A_tb = 16'hFFFF; B_tb = 16'h0001; Cin_tb = 0; #10;  // 32
        A_tb = 16'hFFFF; B_tb = 16'h0001; Cin_tb = 1; #10;  // 33
        A_tb = 16'h7FFF; B_tb = 16'h0001; Cin_tb = 0; #10;  // 34
        A_tb = 16'h7FFF; B_tb = 16'h0001; Cin_tb = 1; #10;  // 35
        
        // === MULTIPLE CARRY CHAINS ===
        A_tb = 16'h0F0F; B_tb = 16'h0F0F; Cin_tb = 0; #10;  // 36
        A_tb = 16'hF0F0; B_tb = 16'hF0F0; Cin_tb = 0; #10;  // 37
        A_tb = 16'h3333; B_tb = 16'h3333; Cin_tb = 0; #10;  // 38
        A_tb = 16'h5555; B_tb = 16'h5555; Cin_tb = 0; #10;  // 39
        
        // === PROGRESSIVE CARRY TESTS ===
        A_tb = 16'h0001; B_tb = 16'h0002; Cin_tb = 0; #10;  // 40
        A_tb = 16'h0007; B_tb = 16'h0008; Cin_tb = 0; #10;  // 41
        A_tb = 16'h000F; B_tb = 16'h0010; Cin_tb = 0; #10;  // 42
        A_tb = 16'h007F; B_tb = 16'h0080; Cin_tb = 0; #10;  // 43
        A_tb = 16'h00FF; B_tb = 16'h0100; Cin_tb = 0; #10;  // 44
        A_tb = 16'h0FFF; B_tb = 16'h1000; Cin_tb = 0; #10;  // 45
        
        // === CARRY-IN PROPAGATION TESTS ===
        A_tb = 16'h00FF; B_tb = 16'h0000; Cin_tb = 1; #10;  // 46
        A_tb = 16'h0000; B_tb = 16'h00FF; Cin_tb = 1; #10;  // 47
        A_tb = 16'h0FFF; B_tb = 16'h0000; Cin_tb = 1; #10;  // 48
        A_tb = 16'h7FFF; B_tb = 16'h0000; Cin_tb = 1; #10;  // 49
        A_tb = 16'hFFFF; B_tb = 16'h0000; Cin_tb = 1; #10;  // 50
        
        A_tb = 16'h5555; B_tb = 16'h5555; Cin_tb = 1; #10;  // 51
        A_tb = 16'hAAAA; B_tb = 16'hAAAA; Cin_tb = 1; #10;  // 52
        A_tb = 16'h0F0F; B_tb = 16'h0F0F; Cin_tb = 1; #10;  // 53
        A_tb = 16'hF0F0; B_tb = 16'hF0F0; Cin_tb = 1; #10;  // 54
        
        // === ALPHANUMERIC & REAL-WORLD PATTERNS ===
        A_tb = 16'h1234; B_tb = 16'h5678; Cin_tb = 0; #10;  // 55
        A_tb = 16'h1234; B_tb = 16'h5678; Cin_tb = 1; #10;  // 56
        A_tb = 16'hABCD; B_tb = 16'h1234; Cin_tb = 0; #10;  // 57
        A_tb = 16'hABCD; B_tb = 16'h1234; Cin_tb = 1; #10;  // 58
        A_tb = 16'hBABE; B_tb = 16'hDEAD; Cin_tb = 0; #10;  // 59
        A_tb = 16'hBABE; B_tb = 16'hDEAD; Cin_tb = 1; #10;  // 60
        A_tb = 16'hCAFE; B_tb = 16'hBABE; Cin_tb = 0; #10;  // 61
        A_tb = 16'hCAFE; B_tb = 16'hBABE; Cin_tb = 1; #10;  // 62
        A_tb = 16'hFADE; B_tb = 16'hDEAF; Cin_tb = 0; #10;  // 63
        A_tb = 16'hFADE; B_tb = 16'hDEAF; Cin_tb = 1; #10;  // 64
        
        A_tb = 16'hDEAD; B_tb = 16'hBEEF; Cin_tb = 0; #10;  // 65
        A_tb = 16'hFACE; B_tb = 16'hB00C; Cin_tb = 0; #10;  // 66
        A_tb = 16'hC0DE; B_tb = 16'hD00D; Cin_tb = 0; #10;  // 67
        A_tb = 16'hFEED; B_tb = 16'hCAFE; Cin_tb = 0; #10;  // 68
        
        // === SEQUENTIAL PATTERNS ===
        A_tb = 16'h1111; B_tb = 16'h2222; Cin_tb = 0; #10;  // 69
        A_tb = 16'h3333; B_tb = 16'h4444; Cin_tb = 0; #10;  // 70
        A_tb = 16'h5555; B_tb = 16'h6666; Cin_tb = 0; #10;  // 71
        A_tb = 16'h7777; B_tb = 16'h8888; Cin_tb = 0; #10;  // 72
        A_tb = 16'h9999; B_tb = 16'hAAAA; Cin_tb = 0; #10;  // 73
        A_tb = 16'hBBBB; B_tb = 16'hCCCC; Cin_tb = 0; #10;  // 74
        
        // === FINAL STRESS TESTS ===
        A_tb = 16'h7FFE; B_tb = 16'h0001; Cin_tb = 0; #10;  // 75
        A_tb = 16'h7FFE; B_tb = 16'h0001; Cin_tb = 1; #10;  // 76
        A_tb = 16'h7FFF; B_tb = 16'h7FFF; Cin_tb = 0; #10;  // 77
        A_tb = 16'h7FFF; B_tb = 16'h7FFF; Cin_tb = 1; #10;  // 78
        A_tb = 16'hFFFE; B_tb = 16'h0001; Cin_tb = 0; #10;  // 79
        A_tb = 16'hFFFE; B_tb = 16'h0001; Cin_tb = 1; #10;  // 80

        $finish;
    end


endmodule