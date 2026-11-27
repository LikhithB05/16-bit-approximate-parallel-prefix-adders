module gp_operator (
    input  wire g_in1, p_in1,  // "Bottom" input (e.g., [j-1:0])
    input  wire g_in2, p_in2,  // "Top" input (e.g., [i:j])
    output wire g_out, p_out   // Combined output [i:0]
);
    // Group Generate: g_out = g2 OR (p2 AND g1)
    assign g_out = g_in2 | (p_in2 & g_in1);
    // Group Propagate: p_out = p2 AND p1
    assign p_out = p_in2 & p_in1;
endmodule


//======================================================================
// MODULE 2: The 16-bit Brent Kung Adder
// This is the main adder, hard-wired to your Fig. 7 diagram.
//======================================================================
module Brkung (
    input  [15:0] A,
    input  [15:0] B,
    input  Cin,
    output [15:0] Sum,
    output Cout
);

    //============================================================
    // Step 1: Initial Propagate and Generate
    //============================================================
    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B; // Also used for final sum (P_i ^ C_i)

    //============================================================
    // Step 2:  Prefix Tree
    // This is the direct translation of your Fig. 7
    //============================================================

    // Wires for each level of the "up-sweep" (black dots)
    wire [15:0] G_L1, P_L1; // Level 1 (K=1)
    wire [15:0] G_L2, P_L2; // Level 2 (K=2)
    wire [15:0] G_L3, P_L3; // Level 3 (K=3)
    wire [15:0] G_L4, P_L4; // Level 4 (K=4)

    // Wires for the final prefix [i:0]
    // These will be the inputs to Step 3
    wire [15:0] G_final, P_final;

    // --- UP-SWEEP (Black Dots, K=1 to K=4) ---
    // Level 1 (K=1): Combine (i) and (i-1)
    gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1], P_L1[1]);
    gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3], P_L1[3]);
    gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);
    gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);
    gp_operator L1_9 (G[8], P[8], G[9], P[9], G_L1[9], P_L1[9]);
    gp_operator L1_11(G[10], P[10], G[11], P[11], G_L1[11], P_L1[11]);
    gp_operator L1_13(G[12], P[12], G[13], P[13], G_L1[13], P_L1[13]);
    gp_operator L1_15(G[14], P[14], G[15], P[15], G_L1[15], P_L1[15]);

    // Level 2 (K=2): Combine (i:i-1) and (i-2:i-3)
    gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]);
    gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]);
    gp_operator L2_11(G_L1[9], P_L1[9], G_L1[11], P_L1[11], G_L2[11], P_L2[11]);
    gp_operator L2_15(G_L1[13], P_L1[13], G_L1[15], P_L1[15], G_L2[15], P_L2[15]);

    // Level 3 (K=3): Combine (i:i-3) and (i-4:i-7)
    gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]);
    gp_operator L3_15(G_L2[11], P_L2[11], G_L2[15], P_L2[15], G_L3[15], P_L3[15]);

    // Level 4 (K=4): Combine (i:i-7) and (i-8:i-15)
    gp_operator L4_15(G_L3[7], P_L3[7], G_L3[15], P_L3[15], G_L4[15], P_L4[15]);


    // --- DOWN-SWEEP (Grey Dots) ---
    // G_final[i] = P(i:0)
    // Some are directly from the up-sweep, others are new.

    // These bits are the "endpoints" of the up-sweep
    assign G_final[0]  = G[0];     assign P_final[0]  = P[0];
    assign G_final[1]  = G_L1[1];  assign P_final[1]  = P_L1[1];
    assign G_final[3]  = G_L2[3];  assign P_final[3]  = P_L2[3];
    assign G_final[7]  = G_L3[7];  assign P_final[7]  = P_L3[7];
    assign G_final[15] = G_L4[15]; assign P_final[15] = P_L4[15];

    // These are the "grey dots" that fill in the gaps
    // G_final[i] = G(group i) + G_final[j] (from a previous level)
    
    // Grey dots combining with G_final[1]
    gp_operator D_2 (G_final[1], P_final[1], G[2], P[2], G_final[2], P_final[2]);
    
    // Grey dots combining with G_final[3]
    gp_operator D_4 (G_final[3], P_final[3], G[4], P[4], G_final[4], P_final[4]);
    gp_operator D_5 (G_final[3], P_final[3], G_L1[5], P_L1[5], G_final[5], P_final[5]);
    gp_operator D_6 (G_final[5], P_final[5], G[6], P[6], G_final[6], P_final[6]); // G_final[6] = G(6) + G_final[5]

    // Grey dots combining with G_final[7]
    gp_operator D_8 (G_final[7], P_final[7], G[8], P[8], G_final[8], P_final[8]);
    gp_operator D_9 (G_final[7], P_final[7], G_L1[9], P_L1[9], G_final[9], P_final[9]);
    gp_operator D_10(G_final[9], P_final[9], G[10], P[10], G_final[10], P_final[10]);
    gp_operator D_11(G_final[7], P_final[7], G_L2[11], P_L2[11], G_final[11], P_final[11]);
    gp_operator D_12(G_final[11], P_final[11], G[12], P[12], G_final[12], P_final[12]);
    gp_operator D_13(G_final[11], P_final[11], G_L1[13], P_L1[13], G_final[13], P_final[13]);
    gp_operator D_14(G_final[13], P_final[13], G[14], P[14], G_final[14], P_final[14]);


    //============================================================
    // Step 3: Carry generation (This is your corrected PARALLEL logic)
    //============================================================
    wire [16:0] C;
    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_gen
            // C[i+1] (carry-out of bit i) depends on the *entire* group [i:0]
            // and the *single* initial Cin (C[0]). This is parallel.
            assign C[i + 1] = G_final[i] | (P_final[i] & C[0]);
        end
    endgenerate

    //============================================================
    // Step 4: Final Sum and Carry Out
    //============================================================
    // Sum_i = P_i XOR C_i
    assign Sum  = P ^ C[15:0];
    
    // Cout is the final carry-out of the 16-bit block
    assign Cout = C[16];

endmodule
