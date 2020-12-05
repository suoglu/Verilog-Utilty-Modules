/* ----------------------------------------- *
 * Title       : Clock Dividers              *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : clk_div.v                   *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 23/11/2020                  *
 * ----------------------------------------- *
 * Description : Collection clock dividers   *
 * ----------------------------------------- */

/* ------------------------------- *
 +  Naming convention for modules: +
 + (d)clk_divN(_M)                 +
 +  d: dynamic                     +
 +  N: Max divison rate 2^N        +
 + _M: step size (if M > 1)        +
 * ------------------------------- */

//Static (Fixed) dividers, can be daisy chained for variable output rates
module clk_div1(clk_i, rst, clk_o); //fi = 2fo
  input clk_i, rst;
  output reg clk_o;

  always@(posedge clk_i or posedge rst)
    begin
      if(rst)
        begin
          clk_o <= 0;
        end
      else
        begin
          clk_o <= ~clk_o;
        end
    end
endmodule

module clk_div2(clk_i, rst, clk_o); //fi = 4fo
  input clk_i, rst;
  output clk_o;
  wire clk_mid;

  clk_div1 clkdivider0(clk_i, rst, clk_mid);
  clk_div1 clkdivider1(clk_mid, rst, clk_o);
endmodule

module clk_div4(clk_i, rst, clk_o); //fi = 16fo
  input clk_i, rst;
  output clk_o;
  wire clk_mid;

  clk_div2 clkdivider0(clk_i, rst, clk_mid);
  clk_div2 clkdivider1(clk_mid, rst, clk_o);
endmodule

module clk_div6(clk_i, rst, clk_o); //fi = 64fo
  input clk_i, rst;
  output clk_o;
  wire clk_mid;

  clk_div1 clkdivider0(clk_i, rst, clk_mid);
  clk_div2 clkdivider1(clk_mid, rst, clk_o);
endmodule

//Dynamic dividers, rate can be controlled 
//Higher rate_cntrl lower freq
module dclk_div2(clk_i, rst, rate_cntrl, clk_o);
  input clk_i, rst;
  input rate_cntrl;
  output clk_o;
  wire [1:0] clk_array;

  assign clk_o = (rate_cntrl) ? clk_array[1] : clk_array[0];
  
  clk_div1 clkdivider0(clk_i, rst, clk_array[0]);
  clk_div1 clkdivider1(clk_array[0], rst, clk_array[1]);
endmodule//dclk_div

module dclk_div2_2(clk_i, rst, rate_cntrl, clk_o);
  input clk_i, rst;
  input rate_cntrl;
  output clk_o;
  wire [1:0] clk_array;

  assign clk_o = (rate_cntrl) ? clk_array[1] : clk_array[0];
  
  clk_div2 clkdivider0(clk_i, rst, clk_array[0]);
  clk_div2 clkdivider1(clk_array[0], rst, clk_array[1]);
endmodule//dclk_div2_2

module dclk_div4(clk_i, rst, rate_cntrl, clk_o);
  input clk_i, rst;
  input [1:0] rate_cntrl;
  output clk_o;
  wire [3:0] clk_array;

  assign clk_o = clk_array[rate_cntrl];

  clk_div1 clkdivider0(clk_i, rst, clk_array[0]);
  clk_div1 clkdivider1(clk_array[0], rst, clk_array[1]);
  clk_div1 clkdivider2(clk_array[1], rst, clk_array[2]);
  clk_div1 clkdivider3(clk_array[2], rst, clk_array[3]);
endmodule//dclk_div4

module dclk_div8(clk_i, rst, rate_cntrl, clk_o);
  input clk_i, rst;
  input [2:0] rate_cntrl;
  output clk_o;
  wire [7:0] clk_array;

  assign clk_o = clk_array[rate_cntrl];

  clk_div1 clkdivider0(clk_i, rst, clk_array[0]);
  clk_div1 clkdivider1(clk_array[0], rst, clk_array[1]);
  clk_div1 clkdivider2(clk_array[1], rst, clk_array[2]);
  clk_div1 clkdivider3(clk_array[2], rst, clk_array[3]);
  clk_div1 clkdivider4(clk_array[3], rst, clk_array[4]);
  clk_div1 clkdivider5(clk_array[4], rst, clk_array[5]);
  clk_div1 clkdivider6(clk_array[5], rst, clk_array[6]);
  clk_div1 clkdivider7(clk_array[6], rst, clk_array[7]);
endmodule//dclk_div8

module dclk_div8_2(clk_i, rst, rate_cntrl, clk_o);
  input clk_i, rst;
  input [2:0] rate_cntrl;
  output clk_o;
  wire [7:0] clk_array;

  assign clk_o = clk_array[rate_cntrl];

  clk_div2 clkdivider0(clk_i, rst, clk_array[0]);
  clk_div2 clkdivider1(clk_array[0], rst, clk_array[1]);
  clk_div2 clkdivider2(clk_array[1], rst, clk_array[2]);
  clk_div2 clkdivider3(clk_array[2], rst, clk_array[3]);
  clk_div2 clkdivider4(clk_array[3], rst, clk_array[4]);
  clk_div2 clkdivider5(clk_array[4], rst, clk_array[5]);
  clk_div2 clkdivider6(clk_array[5], rst, clk_array[6]);
  clk_div2 clkdivider7(clk_array[6], rst, clk_array[7]);
endmodule//dclk_div8_2
