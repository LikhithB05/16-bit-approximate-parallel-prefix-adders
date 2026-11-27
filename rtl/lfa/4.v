module approx_gp_operator (
    input  wire g_in1, p_in1,
    input  wire g_in2, p_in2,
    output wire g_out, p_out
);

    assign g_out = g_in2;


    assign p_out = p_in2;

endmodule



module gp_operator (
    input  wire g_in1, p_in1,
    input  wire g_in2, p_in2,
    output wire g_out, p_out
);

    assign g_out = g_in2 | (p_in2 & g_in1);

    assign p_out = p_in2 & p_in1;
endmodule






module ladner_fig8 (
    input  [15:0] A,
    input  [15:0] B,
    input  Cin,
    output [15:0] Sum,
    output Cout
);




    wire [15:0] G, P;
    assign G = A & B;
    assign P = A ^ B;






    wire [15:0] G_L1, P_L1;
    wire [15:0] G_L2, P_L2;
    wire [15:0] G_L3, P_L3;
    wire [15:0] G_L4, P_L4;


    wire [15:0] G_final, P_final;


    wire G_6_4, P_6_4;
    wire G_10_8, P_10_8;
    wire G_12_8, P_12_8;
    wire G_13_8, P_13_8;
    wire G_14_8, P_14_8;






    approx_gp_operator L1_1 (G[0], P[0], G[1], P[1], G_L1[1_], P_L1[1]);
    approx_gp_operator L1_3 (G[2], P[2], G[3], P[3], G_L1[3_], P_L1[3]);
    gp_operator L1_5 (G[4], P[4], G[5], P[5], G_L1[5], P_L1[5]);
    gp_operator L1_7 (G[6], P[6], G[7], P[7], G_L1[7], P_L1[7]);
    gp_operator L1_9 (G[8], P[8], G[9], P[9], G_L1[9], P_L1[9]);
    gp_operator L1_11(G[10], P[10], G[11], P[11], G_L1[11], P_L1[11]);
    gp_operator L1_13(G[12], P[12], G[13], P[13], G_L1[13], P_L1[13]);
    gp_operator L1_15(G[14], P[14], G[15], P[15], G_L1[15], P_L1[15]);


    approx_gp_operator L2_3 (G_L1[1], P_L1[1], G_L1[3], P_L1[3], G_L2[3], P_L2[3]);
    gp_operator L2_7 (G_L1[5], P_L1[5], G_L1[7], P_L1[7], G_L2[7], P_L2[7]);
    gp_operator L2_11(G_L1[9], P_L1[9], G_L1[11], P_L1[11], G_L2[11], P_L2[11]);
    gp_operator L2_15(G_L1[13], P_L1[13], G_L1[15], P_L1[15], G_L2[15], P_L2[15]);


    gp_operator L3_7 (G_L2[3], P_L2[3], G_L2[7], P_L2[7], G_L3[7], P_L3[7]);
    gp_operator L3_15(G_L2[11], P_L2[11], G_L2[15], P_L2[15], G_L3[15], P_L3[15]);


    gp_operator L4_15(G_L3[7], P_L3[7], G_L3[15], P_L3[15], G_L4[15], P_L4[15]);






    assign G_final[0]  = G[0];    assign P_final[0]  = P[0];
    assign G_final[1]  = G_L1[1]; assign P_final[1]  = P_L1[1];
    assign G_final[3]  = G_L2[3]; assign P_final[3]  = P_L2[3];
    assign G_final[7]  = G_L3[7]; assign P_final[7]  = P_L3[7];
    assign G_final[15] = G_L4[15]; assign P_final[15] = P_L4[15];




    approx_gp_operator D_2 (G_final[1], P_final[1], G[2], P[2], G_final[2], P_final[2]);


    gp_operator D_4 (G_final[3], P_final[3], G[4], P[4], G_final[4], P_final[4]);
    gp_operator D_5 (G_final[3], P_final[3], G_L1[5], P_L1[5], G_final[5], P_final[5]);


    gp_operator D_6_temp (G_L1[5], P_L1[5], G[6], P[6], G_6_4, P_6_4);
    gp_operator D_6 (G_final[3], P_final[3], G_6_4, P_6_4, G_final[6], P_final[6]);


    gp_operator D_8 (G_final[7], P_final[7], G[8], P[8], G_final[8], P_final[8]);
    gp_operator D_9 (G_final[7], P_final[7], G_L1[9], P_L1[9], G_final[9], P_final[9]);


    gp_operator D_10_temp(G_L1[9], P_L1[9], G[10], P[10], G_10_8, P_10_8);
    gp_operator D_10 (G_final[7], P_final[7], G_10_8, P_10_8, G_final[10], P_final[10]);

    gp_operator D_11(G_final[7], P_final[7], G_L2[11], P_L2[11], G_final[11], P_final[11]);


    gp_operator D_12_temp(G_L2[11], P_L2[11], G[12], P[12], G_12_8, P_12_8);
    gp_operator D_12 (G_final[7], P_final[7], G_12_8, P_12_8, G_final[12], P_final[12]);


    gp_operator D_13_temp(G_L2[11], P_L2[11], G_L1[13], P_L1[13], G_13_8, P_13_8);
    gp_operator D_13 (G_final[7], P_final[7], G_13_8, P_13_8, G_final[13], P_final[13]);


    gp_operator D_14_temp(G_13_8, P_13_8, G[14], P[14], G_14_8, P_14_8);
    gp_operator D_14 (G_final[7], P_final[7], G_14_8, P_14_8, G_final[14], P_final[14]);





    wire [16:0] C;
    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_gen


            assign C[i + 1] = G_final[i] | (P_final[i] & C[0]);
        end
    endgenerate





    assign Sum  = P ^ C[15:0];


    assign Cout = C[16];

endmodule