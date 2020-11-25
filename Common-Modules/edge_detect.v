/*
 * Two super simple modules to detect edges
 * Suoglu, Nov 2020
 */

module det_pos_edge(clk, in, pedge);
  input clk, in;
  output pedge;

  reg [1:0] in_del;

  assign pedge = in_del[0] & (~in_del[1]);

  always@(posedge clk)
    begin
      in_del <= {in_del[0], in};
    end
endmodule//pos_edge

module det_neg_edge(clk, in, nedge);
  input clk, in;
  output nedge;

  reg [1:0] in_del;
  
  assign nedge = in_del[1] & (~in_del[0]);
  
  always@(posedge clk)
    begin
      in_del <= {in_del[0], in};
    end
 endmodule//neg_edge