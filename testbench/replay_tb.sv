// Post-project testbench. Stream fixed-width unsigned operand triples.
module replay_tb;
    reg [15:0] A, B;
    reg Cin;
    wire [15:0] Sum;
    wire Cout;
    integer input_file, status;
    reg [4095:0] vectors;

    __DUT__ dut (.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));

    initial begin
        if (!$value$plusargs("vectors=%s", vectors)) $fatal(1, "Pass +vectors=file");
        input_file = $fopen(vectors, "r");
        if (!input_file) $fatal(1, "Could not open vector file");
        while (!$feof(input_file)) begin
            status = $fscanf(input_file, "%h %h %b\n", A, B, Cin);
            if (status == 3) begin
                #1;
                $display("%05h", {Cout, Sum});
            end else if (!$feof(input_file)) begin
                $fatal(1, "Malformed input");
            end
        end
        $fclose(input_file);
    end
endmodule
