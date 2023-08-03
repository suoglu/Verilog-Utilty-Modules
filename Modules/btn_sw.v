/* ------------------------------------------ *
 * Title       : Button-Switch Converters     *
 * Project     : Verilog Utility Modules      *
 * ------------------------------------------ *
 * File        : btn_sw.v                     *
 * Author      : Yigit Suoglu                 *
 * Last Edit   : 30/01/2021                   *
 * Licence     : CERN-OHL-W                   *
 * ------------------------------------------ *
 * Description : Allows the use of switches   *
 *               as buttons, and buttons as   *
 *               switches.                    *
 * ------------------------------------------ */

module BTNtoSW#(parameter RESETVAL = 1'b0, parameter NEGEDGESENS = 1'b0)(clk, rst, btn, sw);
  input clk, rst, btn;
  output reg sw;

  wire btn_cntr;

  assign btn_cntr = (NEGEDGESENS) ? ~btn : btn;

  always@(posedge btn_cntr or posedge rst)
    begin
      if(rst)
        begin
          sw <= RESETVAL;
        end
      else
        begin
          sw <= ~sw;
        end
    end
endmodule

module SWtoBTN(clk, sw, btn);
  input clk, sw;
  output btn;
  reg sw_d, sw_dd;

  assign btn = sw_dd ^ sw_d;

  always@(posedge clk)
    begin
      sw_d <= sw;
      sw_dd <= sw_d;
    end
endmodule
