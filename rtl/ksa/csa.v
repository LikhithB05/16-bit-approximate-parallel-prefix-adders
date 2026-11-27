`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 20:03:34
// Design Name: 
// Module Name: ksa_csa
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
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



module ksa_csa (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,
    output wire [15:0] Sum,
    output wire        Cout
);

    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B;

    // =====================================================
    // LOWER 8 BITS - EXACT KOGGE-STONE PREFIX
    // =====================================================

    wire [7:0] G_L1, P_L1;
    wire [7:0] G_L2, P_L2;
    wire [7:0] G_L3, P_L3;

    // -------- LEVEL 1 --------
    assign G_L1[0] = G[0];  assign P_L1[0] = P[0];

    gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1], P_L1[1]);
    gp_operator L1_2 (G[1], P[1], G[2], P[2], G_L1[2], P_L1[2]);
    gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3], P_L1[3]);
    gp_operator L1_4 (G[3], P[3], G[4], P[4], G_L1[4], P_L1[4]);
    gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);
    gp_operator L1_6 (G[5], P[5], G[6], P[6], G_L1[6], P_L1[6]);
    gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);

    // -------- LEVEL 2 --------
    assign G_L2[0] = G_L1[0]; assign P_L2[0] = P_L1[0];
    assign G_L2[1] = G_L1[1]; assign P_L2[1] = P_L1[1];

    gp_operator L2_2 (G_L1[0], P_L1[0], G_L1[2], P_L1[2], G_L2[2], P_L2[2]);
    gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]);
    gp_operator L2_4 (G_L1[2], P_L1[2], G_L1[4], P_L1[4], G_L2[4], P_L2[4]);
    gp_operator L2_5 (G_L1[3], P_L1[3], G_L1[5], P_L1[5], G_L2[5], P_L2[5]);
    gp_operator L2_6 (G_L1[4], P_L1[4], G_L1[6], P_L1[6], G_L2[6], P_L2[6]);
    gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]);

    // -------- LEVEL 3 --------
    assign G_L3[0] = G_L2[0]; assign P_L3[0] = P_L2[0];
    assign G_L3[1] = G_L2[1]; assign P_L3[1] = P_L2[1];
    assign G_L3[2] = G_L2[2]; assign P_L3[2] = P_L2[2];
    assign G_L3[3] = G_L2[3]; assign P_L3[3] = P_L2[3];

    gp_operator L3_4 (G_L2[0], P_L2[0], G_L2[4], P_L2[4], G_L3[4], P_L3[4]);
    gp_operator L3_5 (G_L2[1], P_L2[1], G_L2[5], P_L2[5], G_L3[5], P_L3[5]);
    gp_operator L3_6 (G_L2[2], P_L2[2], G_L2[6], P_L2[6], G_L3[6], P_L3[6]);
    gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]);

    // =====================================================
    // FINAL PREFIX MAPPING (YOU WERE RIGHT - REQUIRED)
    // =====================================================

    wire [7:0] G_final, P_final;

    assign G_final[0] = G_L1[0]; assign P_final[0] = P_L1[0];
    assign G_final[1] = G_L1[1]; assign P_final[1] = P_L1[1];
    assign G_final[2] = G_L2[2]; assign P_final[2] = P_L2[2];
    assign G_final[3] = G_L2[3]; assign P_final[3] = P_L2[3];
    assign G_final[4] = G_L3[4]; assign P_final[4] = P_L3[4];
    assign G_final[5] = G_L3[5]; assign P_final[5] = P_L3[5];
    assign G_final[6] = G_L3[6]; assign P_final[6] = P_L3[6];
    assign G_final[7] = G_L3[7]; assign P_final[7] = P_L3[7];

    // =====================================================
    // SAME SPECULATION AS LFA
    // =====================================================

    wire C8_pred;
    assign C8_pred = G_final[7];

    // =====================================================
    // UPPER 8-BIT DUAL PATH (LOOP ALLOWED)
    // =====================================================

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

    // =====================================================
    // LOWER 8-BIT CARRY (LOOP SAME AS LFA CSA)
    // =====================================================

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