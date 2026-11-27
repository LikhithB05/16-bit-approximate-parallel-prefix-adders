//======================================================================
// MODULE 1: Group Propagate/Generate Operator (Unchanged)
//======================================================================
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
// MODULE 2: The 16-bit Kogge-Stone Adder (Fig. 4 - Explicit Wires)
// This implements the uniform, minimum-depth Kogge-Stone structure.
//======================================================================
module kogge_stone_fig4 (
    input  [15:0] A,
    input  [15:0] B,
    input  Cin,
    output [15:0] Sum,
    output Cout
);

    //============================================================
    // Step 1: Initial Propagate and Generate (Unchanged)
    //============================================================
    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B; // Also used for final sum (P_i ^ C_i)

    //============================================================
    // Step 2: Kogge-Stone Prefix Tree (Fig. 4)
    //============================================================

    // Wires for each level of the prefix tree (Black dots)
    // G_Lk[i] and P_Lk[i] are the intermediate prefix groups [i: i - 2^k + 1]
    wire [15:0] G_L1, P_L1; // Level 1 (Distance 1)
    wire [15:0] G_L2, P_L2; // Level 2 (Distance 2)
    wire [15:0] G_L3, P_L3; // Level 3 (Distance 4)
    wire [15:0] G_L4, P_L4; // Level 4 (Distance 8)

    // Wires for the final prefix [i:0] (C_i+1 carries)
    wire [15:0] G_final, P_final;
    
    // Bits 0 are always the initial P/G
    assign G_L1[0] = G[0]; assign P_L1[0] = P[0];
    assign G_L2[0] = G[0]; assign P_L2[0] = P[0];
    assign G_L3[0] = G[0]; assign P_L3[0] = P[0];
    assign G_L4[0] = G[0]; assign P_L4[0] = P[0];


    // --- LEVEL 1 (Distance 1: combines (i) with (i-1)) ---
    gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1], P_L1[1]);
    gp_operator L1_2 (G[1], P[1], G[2], P[2], G_L1[2], P_L1[2]);
    gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3], P_L1[3]);
    gp_operator L1_4 (G[3], P[3], G[4], P[4], G_L1[4], P_L1[4]);
    gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);
    gp_operator L1_6 (G[5], P[5], G[6], P[6], G_L1[6], P_L1[6]);
    gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);
    gp_operator L1_8 (G[7], P[7], G[8], P[8], G_L1[8], P_L1[8]);
    gp_operator L1_9 (G[8], P[8], G[9], P[9], G_L1[9], P_L1[9]);
    gp_operator L1_10(G[9], P[9], G[10], P[10], G_L1[10], P_L1[10]);
    gp_operator L1_11(G[10], P[10], G[11], P[11], G_L1[11], P_L1[11]);
    gp_operator L1_12(G[11], P[11], G[12], P[12], G_L1[12], P_L1[12]);
    gp_operator L1_13(G[12], P[12], G[13], P[13], G_L1[13], P_L1[13]);
    gp_operator L1_14(G[13], P[13], G[14], P[14], G_L1[14], P_L1[14]);
    gp_operator L1_15(G[14], P[14], G[15], P[15], G_L1[15], P_L1[15]);


    // --- LEVEL 2 (Distance 2: combines (i:i-1) with (i-2:i-3)) ---
    // Bits 0 and 1 are passed from L1
    assign G_L2[1] = G_L1[1]; assign P_L2[1] = P_L1[1]; 
    
    // Start at i=2 (combines [2:1] with [0:0]) - technically uses G[0] P[0]
    gp_operator L2_2 (G_L1[0], P_L1[0], G_L1[2], P_L1[2], G_L2[2], P_L2[2]); 
    gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]);
    gp_operator L2_4 (G_L1[2], P_L1[2], G_L1[4], P_L1[4], G_L2[4], P_L2[4]);
    gp_operator L2_5 (G_L1[3], P_L1[3], G_L1[5], P_L1[5], G_L2[5], P_L2[5]);
    gp_operator L2_6 (G_L1[4], P_L1[4], G_L1[6], P_L1[6], G_L2[6], P_L2[6]);
    gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]);
    gp_operator L2_8 (G_L1[6], P_L1[6], G_L1[8], P_L1[8], G_L2[8], P_L2[8]);
    gp_operator L2_9 (G_L1[7], P_L1[7], G_L1[9], P_L1[9], G_L2[9], P_L2[9]);
    gp_operator L2_10(G_L1[8], P_L1[8], G_L1[10], P_L1[10], G_L2[10], P_L2[10]);
    gp_operator L2_11(G_L1[9], P_L1[9], G_L1[11], P_L1[11], G_L2[11], P_L2[11]);
    gp_operator L2_12(G_L1[10], P_L1[10], G_L1[12], P_L1[12], G_L2[12], P_L2[12]);
    gp_operator L2_13(G_L1[11], P_L1[11], G_L1[13], P_L1[13], G_L2[13], P_L2[13]);
    gp_operator L2_14(G_L1[12], P_L1[12], G_L1[14], P_L1[14], G_L2[14], P_L2[14]);
    gp_operator L2_15(G_L1[13], P_L1[13], G_L1[15], P_L1[15], G_L2[15], P_L2[15]);


    // --- LEVEL 3 (Distance 4: combines (i:i-3) with (i-4:i-7)) ---
    // Bits 0 to 3 are passed from L2
    assign G_L3[1] = G_L1[1]; assign P_L3[1] = P_L1[1]; 
    assign G_L3[2] = G_L2[2]; assign P_L3[2] = P_L2[2];
    assign G_L3[3] = G_L2[3]; assign P_L3[3] = P_L2[3];

    // Start at i=4 (combines [4:3] with [0:0]) - technically uses G_L2[0] P_L2[0]
    gp_operator L3_4 (G_L2[0], P_L2[0], G_L2[4], P_L2[4], G_L3[4], P_L3[4]); 
    gp_operator L3_5 (G_L2[1], P_L2[1], G_L2[5], P_L2[5], G_L3[5], P_L3[5]);
    gp_operator L3_6 (G_L2[2], P_L2[2], G_L2[6], P_L2[6], G_L3[6], P_L3[6]);
    gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]);
    gp_operator L3_8 (G_L2[4], P_L2[4], G_L2[8], P_L2[8], G_L3[8], P_L3[8]);
    gp_operator L3_9 (G_L2[5], P_L2[5], G_L2[9], P_L2[9], G_L3[9], P_L3[9]);
    gp_operator L3_10(G_L2[6], P_L2[6], G_L2[10], P_L2[10], G_L3[10], P_L3[10]);
    gp_operator L3_11(G_L2[7], P_L2[7], G_L2[11], P_L2[11], G_L3[11], P_L3[11]);
    gp_operator L3_12(G_L2[8], P_L2[8], G_L2[12], P_L2[12], G_L3[12], P_L3[12]);
    gp_operator L3_13(G_L2[9], P_L2[9], G_L2[13], P_L2[13], G_L3[13], P_L3[13]);
    gp_operator L3_14(G_L2[10], P_L2[10], G_L2[14], P_L2[14], G_L3[14], P_L3[14]);
    gp_operator L3_15(G_L2[11], P_L2[11], G_L2[15], P_L2[15], G_L3[15], P_L3[15]);


    // --- LEVEL 4 (Distance 8: combines (i:i-7) with (i-8:i-15)) ---
    // Bits 0 to 7 are passed from L3
    assign G_L4[1] = G_L1[1]; assign P_L4[1] = P_L1[1]; 
    assign G_L4[2] = G_L2[2]; assign P_L4[2] = P_L2[2];
    assign G_L4[3] = G_L2[3]; assign P_L4[3] = P_L2[3];
    assign G_L4[4] = G_L3[4]; assign P_L4[4] = P_L3[4];
    assign G_L4[5] = G_L3[5]; assign P_L4[5] = P_L3[5];
    assign G_L4[6] = G_L3[6]; assign P_L4[6] = P_L3[6];
    assign G_L4[7] = G_L3[7]; assign P_L4[7] = P_L3[7];

    // Start at i=8
    gp_operator L4_8 (G_L3[0], P_L3[0], G_L3[8], P_L3[8], G_L4[8], P_L4[8]); 
    gp_operator L4_9 (G_L3[1], P_L3[1], G_L3[9], P_L3[9], G_L4[9], P_L4[9]);
    gp_operator L4_10(G_L3[2], P_L3[2], G_L3[10], P_L3[10], G_L4[10], P_L4[10]);
    gp_operator L4_11(G_L3[3], P_L3[3], G_L3[11], P_L3[11], G_L4[11], P_L4[11]);
    gp_operator L4_12(G_L3[4], P_L3[4], G_L3[12], P_L3[12], G_L4[12], P_L4[12]);
    gp_operator L4_13(G_L3[5], P_L3[5], G_L3[13], P_L3[13], G_L4[13], P_L4[13]);
    gp_operator L4_14(G_L3[6], P_L3[6], G_L3[14], P_L3[14], G_L4[14], P_L4[14]);
    gp_operator L4_15(G_L3[7], P_L3[7], G_L3[15], P_L3[15], G_L4[15], P_L4[15]);

    
    // --- FINAL PREFIXES (G_final[i] is G(i:0) and P_final[i] is P(i:0)) ---
    // In Kogge-Stone, G_final[i] is simply the output of the highest level calculated for bit i.
    assign G_final[0] = G_L1[0]; assign P_final[0] = P_L1[0]; 
    assign G_final[1] = G_L1[1]; assign P_final[1] = P_L1[1];
    assign G_final[2] = G_L2[2]; assign P_final[2] = P_L2[2];
    assign G_final[3] = G_L2[3]; assign P_final[3] = P_L2[3];
    assign G_final[4] = G_L3[4]; assign P_final[4] = P_L3[4];
    assign G_final[5] = G_L3[5]; assign P_final[5] = P_L3[5];
    assign G_final[6] = G_L3[6]; assign P_final[6] = P_L3[6];
    assign G_final[7] = G_L3[7]; assign P_final[7] = P_L3[7];
    assign G_final[8] = G_L4[8]; assign P_final[8] = P_L4[8];
    assign G_final[9] = G_L4[9]; assign P_final[9] = P_L4[9];
    assign G_final[10] = G_L4[10]; assign P_final[10] = P_L4[10];
    assign G_final[11] = G_L4[11]; assign P_final[11] = P_L4[11];
    assign G_final[12] = G_L4[12]; assign P_final[12] = P_L4[12];
    assign G_final[13] = G_L4[13]; assign P_final[13] = P_L4[13];
    assign G_final[14] = G_L4[14]; assign P_final[14] = P_L4[14];
    assign G_final[15] = G_L4[15]; assign P_final[15] = P_L4[15];


//============================================================
    // Step 3: Carry generation (Using generate loop)
    //============================================================
    wire [16:0] C;
    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_gen
            // C[i+1] (carry-out of bit i) = G_prefix[i] | (P_prefix[i] & C[0])
            assign C[i + 1] = G_final[i] | (P_final[i] & C[0]);
        end
    endgenerate

    //============================================================
    // Step 4: Final Sum and Carry Out (Unchanged)
    //============================================================
    // Sum_i = P_i XOR C_i
    assign Sum  = P ^ C[15:0];
    
    // Cout is the final carry-out of the 16-bit block
    assign Cout = C[16];

endmodule