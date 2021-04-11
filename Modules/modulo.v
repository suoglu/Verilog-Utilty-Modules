/* ----------------------------------------- *
 * Title       : Modulo                      *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : modulo.v                    *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 11/04/2021                  *
 * ----------------------------------------- *
 * Description : Modules for modulo opration *
 * ----------------------------------------- */

//<divident> mod <divisor>
module modulo_sec#(
  parameter SIZE = 16,
  parameter CALCULATION_OUT = 1'b0/*1'b0 or 1'b1*/)(
  input clk,
  input rst,
  input [(SIZE-1):0] divident,
  input [(SIZE-1):0] divisor,
  input start,
  output done,
  output [(SIZE-1):0] remainder);

  reg calculating; //State reg
  wire negativeRes;
  reg [(SIZE-1):0] stepVal, divisor_reg;
  wire [(SIZE-1):0] stepRes;

  assign done = ~calculating;
  assign remainder = (done) ? stepVal : {SIZE{CALCULATION_OUT}};
  assign {negativeRes, stepRes} = {1'b0, stepVal} - {1'b0, divisor_reg};

  //Handle calculation result
  always@(posedge clk)
    begin
      if(start & done)
        begin
          stepVal <= divident;
        end
      else
        begin
          stepVal <= (~negativeRes & calculating) ? stepRes : stepVal;
        end
    end

  //Store divisor value during calculation
  always@(posedge clk)
    begin
      divisor_reg <= (done) ? divisor : divisor_reg;
    end

  //State transactions
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          calculating <= 1'b0;
        end
      else
        begin
          case(calculating)
            1'b0:
              begin
                calculating <= start;
              end
            1'b1:
              begin
                calculating <= ~negativeRes;
              end
          endcase
        end
    end
endmodule