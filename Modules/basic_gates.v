/* ----------------------------------------- *
 * Title       : Fundamental Logic Gates     *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : basic_gates.v               *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 30/06/2021                  *
 * ----------------------------------------- *
 * Description : "Wrapper" for Fundamental   *
 *                logic gates                *
 * ----------------------------------------- */

module inv(
  input in,
  output out);
  
  assign out = ~in;
endmodule

module and_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = A_i & B_i;
endmodule

module nand_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = ~(A_i & B_i);
endmodule

module or_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = A_i | B_i;
endmodule

module nor_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = ~(A_i | B_i);
endmodule

module xor_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = A_i ^ B_i;
endmodule

module xnor_gate(
  input A_i,
  input B_i,
  output O_o);
  
  assign O_o = ~(A_i ^ B_i);
endmodule
