// Yigit Suoglu ~ 17720
//This module contains adders of the diffent type

//Simple 1 bit full adder
module FA(A, B, Cin, S, Cout);
  input A, B, Cin;
  output S, Cout;
  wire ha_sum; //Partial Sum without carry

  assign ha_sum = A ^ B;
  assign S =  ha_sum ^ Cin; //Sum
  assign Cout = (A & B) | (ha_sum & Cin); //Carry out
endmodule // full Adder

//Simple 1 bit half adder
module HA(A, B, S, Cout);
  input A, B;
  output S, Cout;

  assign S = A ^ B;
  assign Cout = A & B;
endmodule // half Adder

//4 bit ripple carry adder
// A, B and S are 4 bits and Cin and Cout are 1 bit
module RCA4(A, B, Cin, S, Cout);
  input [3:0] A, B;
  input Cin; //carry from previous stage
  output [3:0] S;
  output Cout;

  wire [2:0] Cmid; //Used to make carry connections between CLAs

  FA faddr1(A[0], B[0], Cin, S[0], Cmid[0]);
  FA faddr2(A[1], B[1], Cmid[0], S[1], Cmid[1]);
  FA faddr3(A[2], B[2], Cmid[1], S[2], Cmid[2]);
  FA faddr4(A[3], B[3], Cmid[2], S[3], Cout);

endmodule //4 bit ripple carry adder

//16 bit ripple carry adder
// A, B and S are 16 bits and Cin and Cout are 1 bit
module RCA16(A, B, Cin, S, Cout);
  input [15:0] A, B;
  input Cin; //carry from previous stage
  output [15:0] S;
  output Cout;

  wire [2:0] Cmid; //Used to make carry connections between CLAs

  RCA4 rcaddr1(A[3:0], B[3:0], Cin, S[3:0], Cmid[0]);
  RCA4 rcaddr2(A[7:4], B[7:4], Cmid[0], S[7:4], Cmid[1]);
  RCA4 rcaddr3(A[11:8], B[11:8], Cmid[1], S[11:8], Cmid[2]);
  RCA4 rcaddr4(A[15:12], B[15:12], Cmid[2], S[15:12], Cout);

endmodule //16 bit ripple carry adder

//4 bit carry lookahead adder
// A, B and S are 4 bits and Cin and Cout are 1 bit
module CLA4(A, B, Cin, S, Cout);
  input [3:0] A, B;
  input Cin; //carry from previous stage
  output [3:0] S;
  output Cout;

  wire [3:0] P, G; //carry propagate and generate signals
  wire [4:0] C; //internal carries

  assign P = A ^ B;
  assign G = A & B;
  assign C[0] = Cin;
  assign C[1] = G[0] | (P[0] & C[0]);
  assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
  assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
  assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);
  assign S = P ^ C[3:0];
  assign Cout = C[4];
endmodule //4 bit carry lookahead adder

//16 bit hybrid adder (CLA & Ripple)
// A, B and S are 16 bits and Cin and Cout are 1 bit
module hybridCLA16(A, B, Cin, S, Cout);
  input [15:0] A, B;
  input Cin;
  output [15:0] S;
  output Cout;

  wire [2:0] Cmid; //Used to make carry connections between CLAs

  CLA4 claddr1(A[3:0], B[3:0], Cin, S[3:0], Cmid[0]);
  CLA4 claddr2(A[7:4], B[7:4], Cmid[0], S[7:4], Cmid[1]);
  CLA4 claddr3(A[11:8], B[11:8], Cmid[1], S[11:8], Cmid[2]);
  CLA4 claddr4(A[15:12], B[15:12], Cmid[2], S[15:12], Cout);

endmodule //16 bit hybrid adder with 4 bit carry lookahead adders

//32 bit hybrid adder (CLA & Ripple)
//A, B and S are 32 bits and Cin and Cout are 1 bit
module hybridCLA32(A, B, Cin, S, Cout);
  input [31:0] A, B;
  input Cin;
  output [31:0] S;
  output Cout;

  wire Cmid; //Used to make carry connections between CLAs

  hybridCLA16 haddr1(A[15:0], B[15:0], Cin, S[15:0], Cmid);
  hybridCLA16 haddr2(A[31:16], B[31:16], Cmid, S[31:16], Cout);

endmodule //32 bit hybrid adder with 4 bit carry lookahead adders

//Simple 1 bit carry select Adder
module CSA(A, B, Cin, S, Cout);
  input A, B, Cin;
  output S, Cout;

  wire ha_sum; //Partial Sum without carry

  assign ha_sum = A ^ B;
  assign S = (Cin) ? (~ha_sum) : ha_sum;
  assign Cout = (Cin) ? (A | B) : (A & B);
endmodule //carry select Adder

//Simple 1 bit full Adder with Cin 1
module FA_1(A, B, S, Cout);
  input A, B;
  output S, Cout;

  assign S = ~(A ^ B);
  assign Cout = (A | B);
endmodule //to be used in bigger carry select Adder

//Simple 1 bit full Adder with Cin 0
module FA_0(A, B, S, Cout);
  input A, B;
  output S, Cout;

  assign S = (A ^ B);
  assign Cout = (A & B);
endmodule //to be used in bigger carry select Adder

//4 bit carry select Adder with Full adders for each bit
module CSA4_RCA(A, B, Cin, S, Cout);
  input [3:0] A, B;
  input Cin; //carry from previous stage
  output [3:0] S;
  output Cout;

  wire [2:0] C [1:0];
  wire [3:0] preSum [1:0];
  wire [1:0] preCarry;

  //modules for Cin = 0
  FA_0 fstadder0(A[0], B[0], preSum[0][0],C[0][0]);
  FA fulla01(A[1], B[1], C[0][0], preSum[0][1], C[0][1]);
  FA fulla02(A[2], B[2], C[0][1], preSum[0][2], C[0][2]);
  FA fulla03(A[3], B[3], C[0][2], preSum[0][3], preCarry[0]);

  //modules for Cin = 1
  FA_1 fstadder1(A[0], B[0], preSum[1][0],C[1][0]);
  FA fulla11(A[1], B[1], C[1][0], preSum[1][1], C[1][1]);
  FA fulla12(A[2], B[2], C[1][1], preSum[1][2], C[1][2]);
  FA fulla13(A[3], B[3], C[1][2], preSum[1][3], preCarry[1]);

  assign S = preSum[Cin];
  assign Cout = preCarry[Cin];
endmodule // 4 bit carry select Adder

//16 bit Linear Carry Select Adder with 4 bit carry select Adders
module LCSA16(A, B, Cin, S, Cout);
  input [15:0] A, B;
  input Cin; //carry from previous stage
  output [15:0] S;
  output Cout;

  wire [2:0] C;

  CSA4_RCA csa0(A[3:0], B[3:0], Cin, S[3:0], C[0]);
  CSA4_RCA csa1(A[7:4], B[7:4], C[0], S[7:4], C[1]);
  CSA4_RCA csa2(A[11:8], B[11:8], C[1], S[11:8], C[2]);
  CSA4_RCA csa3(A[15:12], B[15:12], C[2], S[15:12], Cout);
endmodule // 16 bit Linear Carry Select Adder

//32 bit Linear Carry Select Adder with 4 bit carry select Adders
module LCSA32(A, B, Cin, S, Cout);
  input [31:0] A, B;
  input Cin; //carry from previous stage
  output [31:0] S;
  output Cout;

  wire C;

  LCSA16 lcsa0(A[15:0], B[15:0], Cin, S[15:0], C);
  LCSA16 lcsa1(A[31:16], B[31:16], C, S[31:16], Cout);
endmodule // 16 bit Linear Carry Select Adder
