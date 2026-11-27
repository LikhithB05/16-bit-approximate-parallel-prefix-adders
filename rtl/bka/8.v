// MODULE 1: The "Black Cell" (Exact Operator)
// This is your original, exact operator. It is still needed for
// the upper 8 bits and the "boundary" cells.
module gp_operator (
    input  wire g_in1, p_in1,  // "Bottom" input
    input  wire g_in2, p_in2,  // "Top" input
    output wire g_out, p_out   // Combined output
);
    // Group Generate: g_out = g2 OR (p2 AND g1)
    assign g_out = g_in2 | (p_in2 & g_in1);
    // Group Propagate: p_out = p2 AND p1
    assign p_out = p_in2 & p_in1;
endmodule

//======================================================================
// --- NEW MODULE ---
// MODULE 1.5: The APPROXIMATE Operator
// This just passes the "top" input (in2) straight through,
// ignoring the "bottom" input (in1), as per your image.
//======================================================================
module approx_gp_operator (
    input  wire g_in1, p_in1,  // "Bottom" input (IGNORED)
    input  wire g_in2, p_in2,  // "Top" input
    output wire g_out, p_out   // Pass-through output
);
    // Approximation: g_out = g_in2
    assign g_out = g_in2;
    
    // Approximation: p_out = p_in2
    assign p_out = p_in2;
    
endmodule

//======================================================================
// MODULE 2: The 16-bit 8-bit LSB Approximate Ladner-Fischer Adder
//======================================================================
module BKapprox8 ( // Renamed module
    input  [15:0] A,
    input  [15:0] B,
    input  Cin,
    output [15:0] Sum,
    output Cout
);

    //============================================================
    // Step 1: Initial Propagate and Generate (SAME)
    //============================================================
    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B; 

    //============================================================
    // Step 2: Ladner-Fischer Prefix Tree (MODIFIED)
    //============================================================

    // Wires for each level (SAME)
    wire [15:0] G_L1, P_L1; // Level 1 (K=1)
    wire [15:0] G_L2, P_L2; // Level 2 (K=2)
    wire [15:0] G_L3, P_L3; // Level 3 (K=3)
    wire [15:0] G_L4, P_L4; // Level 4 (K=4)

    // Wires for the final prefix [i:0] (SAME)
    wire [15:0] G_final, P_final;

    // --- UP-SWEEP (Black Dots, K=1 to K=4) ---
    // Level 1 (K=1): Combine (i) and (i-1)
    
    // APPROXIMATE for bits 0-7
    approx_gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1], P_L1[1]);     // CHANGED
    approx_gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3], P_L1[3]);     // CHANGED
    approx_gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);     // CHANGED
    approx_gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);     // CHANGED
    
    // EXACT for bits 8-15 (Same as before)
    gp_operator L1_9 (G[8], P[8], G[9], P[9], G_L1[9], P_L1[9]);
    gp_operator L1_11(G[10], P[10], G[11], P[11], G_L1[11], P_L1[11]);
    gp_operator L1_13(G[12], P[12], G[13], P[13], G_L1[13], P_L1[13]);
    gp_operator L1_15(G[14], P[14], G[15], P[15], G_L1[15], P_L1[15]);

    // Level 2 (K=2): Combine (i:i-1) and (i-2:i-3)
    
    // APPROXIMATE for bits 0-7
    approx_gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]); // CHANGED
    approx_gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]); // CHANGED
    
    // EXACT for bits 8-15 (Same as before)
    gp_operator L2_11(G_L1[9], P_L1[9], G_L1[11], P_L1[11], G_L2[11], P_L2[11]);
    gp_operator L2_15(G_L1[13], P_L1[13], G_L1[15], P_L1[15], G_L2[15], P_L2[15]);

    // Level 3 (K=3): Combine (i:i-3) and (i-4:i-7)
    
    // APPROXIMATE for bits 0-7
    approx_gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]); // CHANGED
    
    // EXACT for bits 8-15 (Same as before)
    gp_operator L3_15(G_L2[11], P_L2[11], G_L2[15], P_L2[15], G_L3[15], P_L3[15]);

    // Level 4 (K=4): Combine (i:i-7) and (i-8:i-15)
    // This is a "boundary" cell. It MUST be EXACT to combine
    // the (approx) L3_7 and the (exact) L3_15.
    gp_operator L4_15(G_L3[7], P_L3[7], G_L3[15], P_L3[15], G_L4[15], P_L4[15]); // SAME


    // --- DOWN-SWEEP (Grey Dots) ---
    // (Same logic as before for assigning endpoints)
    assign G_final[0]  = G[0];    assign P_final[0]  = P[0];
    assign G_final[1]  = G_L1[1]; assign P_final[1]  = P_L1[1];
    assign G_final[3]  = G_L2[3]; assign P_final[3]  = P_L2[3];
    assign G_final[7]  = G_L3[7]; assign P_final[7]  = P_L3[7];
    assign G_final[15] = G_L4[15];assign P_final[15] = P_L4[15];

    // These are the "grey dots" that fill in the gaps
    
    // Grey dots for bits 0-7 (APPROXIMATE)
    approx_gp_operator D_2 (G_final[1], P_final[1], G[2], P[2], G_final[2], P_final[2]); // CHANGED
    approx_gp_operator D_4 (G_final[3], P_final[3], G[4], P[4], G_final[4], P_final[4]); // CHANGED
    approx_gp_operator D_5 (G_final[3], P_final[3], G_L1[5], P_L1[5], G_final[5], P_final[5]); // CHANGED
    approx_gp_operator D_6 (G_final[5], P_final[5], G[6], P[6], G_final[6], P_final[6]); // CHANGED

    // Grey dots for bits 8-15 (EXACT)
    // These MUST be EXACT. They are "boundary" cells that
    // take the approx G_final[7] and combine it with exact bits.
    gp_operator D_8 (G_final[7], P_final[7], G[8], P[8], G_final[8], P_final[8]);     // SAME
    gp_operator D_9 (G_final[7], P_final[7], G_L1[9], P_L1[9], G_final[9], P_final[9]); // SAME
    gp_operator D_10(G_final[9], P_final[9], G[10], P[10], G_final[10], P_final[10]);   // SAME
    gp_operator D_11(G_final[7], P_final[7], G_L2[11], P_L2[11], G_final[11], P_final[11]); // SAME
    gp_operator D_12(G_final[11], P_final[11], G[12], P[12], G_final[12], P_final[12]); // SAME
    gp_operator D_13(G_final[11], P_final[11], G_L1[13], P_L1[13], G_final[13], P_final[13]); // SAME
    gp_operator D_14(G_final[13], P_final[13], G[14], P[14], G_final[14], P_final[14]); // SAME

    //============================================================
    // Step 3: Carry generation (SAME)
    //================================H============================
    wire [16:0] C;
    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_gen
            assign C[i + 1] = G_final[i] | (P_final[i] & C[0]);
        end
    endgenerate

    //============================================================
    // Step 4: Final Sum and Carry Out (SAME)
    //============================================================
    assign Sum  = P ^ C[15:0];
    assign Cout = C[16];

endmodule