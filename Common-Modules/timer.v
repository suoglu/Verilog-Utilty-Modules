/*
 * Timer module with adjustable width
 * Suoglu, Nov 2020
 */
/*
 * Some values for 100 MHz clock:
 *  1 sec: at least 27bit 100_000_000
 *  1 min: at least 33bit 6_000_000_000
 * 1 hour: at least 39bit 360_000_000_000
 */

 module timer_p#(parameter WIDTH = 8)(clk, start, en, done, remaining, init_val);
  input clk, start, en;
  input [(WIDTH-1):0] init_val;
  output done;
  output reg [(WIDTH-1):0] remaining;

  assign done = ~(|remaining);

  always@(posedge clk)
    begin
      if(start)
        begin
          remaining <= init_val;
        end
      else
        begin
          remaining <= (done) ? remaining : remaining + {WIDTH{en}};
        end 
    end
 endmodule//timer_p