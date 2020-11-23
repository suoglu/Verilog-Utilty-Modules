/*
 * This file contains a collection of counters
 * Suoglu, Nov 2020
 */
 // Counters are simulated with Icarus Verilog
 /*
  + General working principles:
  + Count up to limit (if limit is 0 count indefinitly)
  + Only count up when enabled and not done
  + Keep start high for one cycle to start counting (counters should be disabled)
  */

module counter_p#(parameter COUNTER_WIDTH = 8)(clk, start, en, done, count, limit);
  input clk, en, start; 
  input [(COUNTER_WIDTH-1):0] limit;
  output done;
  output reg [(COUNTER_WIDTH-1):0] count;

  assign done = (limit == count) & (|limit); //when limit is 0, keep counting
   
  always@(posedge clk)
    begin
      if(start)
        begin
          count <= {{(COUNTER_WIDTH-1){1'b0}}, en};
        end
      else
        begin
          count <= count + {{(COUNTER_WIDTH-1){1'b0}},(en & (~done))};
        end
    end 
endmodule//counter parameterised 

module counter8bit(clk, start, en, done, count, limit);
  input clk, en, start; 
  input [7:0] limit;
  output done;
  output reg [7:0] count;

  assign done = (limit == count) & (|limit); //when limit is 0, keep counting
   
  always@(posedge clk)
    begin
      if(start)
        begin
          count <= {7'b0, en};
        end
      else
        begin
          count <= count + {7'b0,(en & (~done))};
        end
    end 
endmodule//counter8bit

module counter16bit(clk, start, en, done, count, limit);
  input clk, en, start; 
  input [15:0] limit;
  output done;
  output reg [15:0] count;

  assign done = (limit == count) & (|limit); //when limit is 0, keep counting
   
  always@(posedge clk)
    begin
      if(start)
        begin
          count <= {15'b0, en};
        end
      else
        begin
          count <= count + {15'b0,(en & (~done))};
        end
    end 
endmodule//counter16bit

module counter32bit(clk, start, en, done, count, limit);
  input clk, en, start; 
  input [31:0] limit;
  output done;
  output reg [31:0] count;

  assign done = (limit == count) & (|limit); //when limit is 0, keep counting
   
  always@(posedge clk)
    begin
      if(start)
        begin
          count <= {31'b0, en};
        end
      else
        begin
          count <= count + {31'b0,(en & (~done))};
        end
    end 
endmodule//counter32bit

module counter64bit(clk, start, en, done, count, limit);
  input clk, en, start; 
  input [63:0] limit;
  output done;
  output reg [63:0] count;

  assign done = (limit == count) & (|limit); //when limit is 0, keep counting
   
  always@(posedge clk)
    begin
      if(start)
        begin
          count <= {63'b0, en};
        end
      else
        begin
          count <= count + {63'b0,(en & (~done))};
        end
    end 
endmodule//counter64bit
