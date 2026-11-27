// Post-project adapter for the archived monitor-only testbench.
module perfectladner(
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);
    ladner dut (.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));
endmodule
