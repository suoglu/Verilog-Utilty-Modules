/* ----------------------------------------- *
 * Title       : Keypad decoder              *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : keypad.v                    *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 08/01/2021                  *
 * Licence     : CERN-OHL-W                  *
 * ----------------------------------------- *
 * Description : Decode keypads, Rows should *
 *               be connected to Vcc with    *
 *               pull-up resistors           *
 * ----------------------------------------- */

 /* keypad4x4a mapping
  + #  0 1 2 3
  + 0  1 2 3 A : A=10
  + 1  4 5 6 B : B=11
  + 2  7 8 9 C : C=12
  + 3  * 0 # D : *= 14, #=15, D=13
  */
module keypad4x4a(
  input clk,
  input rst,
  input [3:0] row,
  output reg [3:0] col,
  output reg [15:0] buttons);
  reg [15:0] button_reg;
  reg [1:0] state;
  wire newCycle;

  assign newCycle = ~|state;

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state <= 2'd0;
        end
      else
        begin
          state <= state + 2'd1;
        end
    end
  

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          button_reg <= 16'd0;
        end
      else
        begin
          case(state)
            2'b00:
              begin
                button_reg[1] <= ~row[0];
                button_reg[4] <= ~row[1];
                button_reg[7] <= ~row[2];
                button_reg[14] <= ~row[3];
              end
            2'b01:
              begin
                button_reg[2] <= ~row[0];
                button_reg[5] <= ~row[1];
                button_reg[8] <= ~row[2];
                button_reg[0] <= ~row[3];
              end
            2'b10:
              begin
                button_reg[3] <= ~row[0];
                button_reg[6] <= ~row[1];
                button_reg[9] <= ~row[2];
                button_reg[15] <= ~row[3];
              end
            2'b11:
              begin
                button_reg[10] <= ~row[0];
                button_reg[11] <= ~row[1];
                button_reg[12] <= ~row[2];
                button_reg[13] <= ~row[3];
              end
          endcase
        end
    end
  

  always@(posedge newCycle or posedge rst)
    begin
      if(rst)
        begin
          buttons <= 16'd0;
        end
      else
        begin
          buttons <= button_reg;
        end
    end
  
  always@*
    begin
      case(state)
        2'b00:
          begin
            col = 4'b1110;
          end
        2'b01:
          begin
            col = 4'b1101;
          end
        2'b10:
          begin
            col = 4'b1011;
          end
        2'b11:
          begin
            col = 4'b0111;
          end
      endcase  
    end
endmodule//keypad4x4

/* keypad4x3a mapping
 + #  0 1 2
 + 0  1 2 3 : 
 + 1  4 5 6 : 
 + 2  7 8 9 :
 + 3  * 0 # : *= 10, #=11
 */
module keypad4x3a(
  input clk,
  input rst,
  input [3:0] row,
  output reg [2:0] col,
  output reg [11:0] buttons);
  reg [11:0] button_reg;
  reg [1:0] state;
  wire newCycle;

  assign newCycle = ~|state;

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state <= 2'd0;
        end
      else
        begin
          state <= state + {(~state[0] & state[1]), 1'b1};
        end
    end
  

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          button_reg <= 12'd0;
        end
      else
        begin
          case(state)
            2'b00:
              begin
                button_reg[1]  <= ~row[0];
                button_reg[4]  <= ~row[1];
                button_reg[7]  <= ~row[2];
                button_reg[10] <= ~row[3];
              end
            2'b01:
              begin
                button_reg[2]  <= ~row[0];
                button_reg[5]  <= ~row[1];
                button_reg[8]  <= ~row[2];
                button_reg[0]  <= ~row[3];
              end
            2'b10:
              begin
                button_reg[3]  <= ~row[0];
                button_reg[6]  <= ~row[1];
                button_reg[9]  <= ~row[2];
                button_reg[11] <= ~row[3];
              end
          endcase
        end
    end
  

  always@(posedge newCycle or posedge rst)
    begin
      if(rst)
        begin
          buttons <= 12'd0;
        end
      else
        begin
          buttons <= button_reg;
        end
    end
  
  always@*
    begin
      case(state)
        2'b00:
          begin
            col = 3'b110;
          end
        2'b01:
          begin
            col = 3'b101;
          end
        2'b10:
          begin
            col = 3'b011;
          end
        default:
          begin
            col = 3'b111;
          end
      endcase  
    end
endmodule//keypad4x3