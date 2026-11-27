module gp_operator (
    input  wire g_in1, p_in1,
    input  wire g_in2, p_in2,
    output wire g_out, p_out
);
    assign g_out = g_in2 | (p_in2 & g_in1);
    assign p_out = p_in2 & p_in1;
endmodule


module ladner_fig8_m1 (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,
    output wire [15:0] Sum,
    output wire        Cout
);

    // ---------------------------------------------------
    // Bit-level Generate and Propagate
    // ---------------------------------------------------
    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B;

    // ===================================================
    // LOWER 8 BITS: LADNER-FISCHER PREFIX TREE
    // ===================================================
    wire [7:0] G_L1, P_L1;
    wire [7:0] G_L2, P_L2;
    wire [7:0] G_L3, P_L3;

    // Level 1
    gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1], P_L1[1]);
    gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3], P_L1[3]);
    gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);
    gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);

    // Level 2
    gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]);
    gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]);

    // Level 3
    gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]);

    // ===================================================
    // FINAL BIT-WISE PREFIX RESULTS (FIXED)
    // ===================================================
    wire [7:0] G_final, P_final;
    wire G_6_tmp, P_6_tmp;

    assign G_final[0] = G[0];
    assign P_final[0] = P[0];

    assign G_final[1] = G_L1[1];
    assign P_final[1] = P_L1[1];

    gp_operator D_2 (
        G_final[1], P_final[1],
        G[2], P[2],
        G_final[2], P_final[2]
    );

    assign G_final[3] = G_L2[3];
    assign P_final[3] = P_L2[3];

    gp_operator D_4 (
        G_final[3], P_final[3],
        G[4], P[4],
        G_final[4], P_final[4]
    );

    gp_operator D_5 (
        G_final[3], P_final[3],
        G_L1[5], P_L1[5],
        G_final[5], P_final[5]
    );

    gp_operator D_6_temp (
        G_L1[5], P_L1[5],
        G[6], P[6],
        G_6_tmp, P_6_tmp
    );

    gp_operator D_6 (
        G_final[3], P_final[3],
        G_6_tmp, P_6_tmp,
        G_final[6], P_final[6]
    );

    assign G_final[7] = G_L3[7];
    assign P_final[7] = P_L3[7];

    // ===================================================
    // APPROXIMATION: CARRY SPECULATION AT BIT 8
    // ===================================================
    wire C8_pred;
    assign C8_pred = G_final[7];   // SAME approximation logic ✅

    // ===================================================
    // UPPER 8 BITS: DUAL-PATH MSB COMPUTATION (UNCHANGED)
    // ===================================================
    wire [16:8] C0, C1;

    assign C0[8] = 1'b0;
    assign C1[8] = 1'b1;

    genvar i;
    generate
        for (i = 8; i < 16; i = i + 1) begin
            assign C0[i+1] = G[i] | (P[i] & C0[i]);
            assign C1[i+1] = G[i] | (P[i] & C1[i]);
        end
    endgenerate

    // ===================================================
    // FINAL SUM AND CARRY GENERATION
    // ===================================================
    wire [8:0] C_lsb;
    assign C_lsb[0] = Cin;

    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign C_lsb[i+1] = G_final[i] | (P_final[i] & Cin);
            assign Sum[i]     = P[i] ^ C_lsb[i];
        end
    endgenerate

    assign Sum[15:8] = (C8_pred) ? (P[15:8] ^ C1[15:8])
                                 : (P[15:8] ^ C0[15:8]);

    assign Cout = (C8_pred) ? C1[16] : C0[16];

endmodule