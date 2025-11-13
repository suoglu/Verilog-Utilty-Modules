/* ----------------------------------------- *
 * Title       : FIFO Buffer                 *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : fifo.v                      *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 13/11/2025                  *
 * Licence     : CERN-OHL-W                  *
 * ----------------------------------------- *
 * Description : A generic FIFO circular     *
 *               buffer                      *
 * ----------------------------------------- */

//Level sensetive push/drop
module fifo_cl#(
  parameter DATA_WIDTH = 32, //Size of each data entry
  parameter FIFO_DEPTH = 64 //Max number of buffer entries
  )(
  input clk,
  input rst,
  //Flags
  output fifo_empty,
  output fifo_full,
  output reg [$clog2(FIFO_DEPTH):0] awaiting_count, //Number of entires waiting in the buffer
  //Data in
  input [DATA_WIDTH-1:0] data_i,
  input push, //Add data_i to buffer, level sensitive
  //Data out
  output [DATA_WIDTH-1:0] data_o,
  input drop //Entry at data_o is read, should be set after data_o is read, level sensitive
  );
  localparam FIFO_LENGTH_SIZE = $clog2(FIFO_DEPTH);
  reg [DATA_WIDTH-1:0] buffer[FIFO_DEPTH-1:0];

  //Pointers for circular buffer
  reg  [FIFO_LENGTH_SIZE-1:0]  read_ptr;
  wire [FIFO_LENGTH_SIZE-1:0] write_ptr = read_ptr + awaiting_count[FIFO_LENGTH_SIZE-1:0];

  always@(posedge clk) begin
    if(rst) begin
      read_ptr <= 0;
    end else begin
      read_ptr <= (~fifo_empty & drop) ? read_ptr + 1 : read_ptr;
    end
  end

  always@(posedge clk) begin
    if(rst) begin
      awaiting_count <= 0;
    end else begin
      if(~fifo_full & ~drop & push) begin
        awaiting_count <= awaiting_count + 1;
      end else if(~fifo_empty & drop & ~push) begin
        awaiting_count <= awaiting_count - 1;
      end
    end
  end


  //fifo flags
  assign fifo_empty = (awaiting_count == 0);
  assign fifo_full  =  awaiting_count[FIFO_LENGTH_SIZE];
  

  //Handle data pins
  assign data_o = buffer[read_ptr];
  always@(posedge clk) begin
    if(~fifo_full & push) begin
      buffer[write_ptr] <= data_i;
    end
  end
endmodule

//edge sensetive push/drop
module fifo_ce#(  
  parameter DATA_WIDTH = 32, //Size of each data entry
  parameter FIFO_DEPTH = 64 //Max number of buffer entries
  )(
  input clk,
  input rst,
  //Flags
  output fifo_empty,
  output fifo_full,
  output reg [$clog2(FIFO_DEPTH):0] awaiting_count, //Number of entires waiting in the buffer
  //Data in
  input [DATA_WIDTH-1:0] data_i,
  input push, //Add data_i to buffer, edge sensitive
  //Data out
  output [DATA_WIDTH-1:0] data_o,
  input drop //Entry at data_o is read, should be set after data_o is read, edge sensitive
  );
  reg push_d, drop_d;
  always@(posedge clk) begin
    push_d <= push;
    drop_d <= drop;
  end
  wire push_posedge = ~push_d & push;
  wire drop_posedge = ~drop_d & drop;

  fifo_cl #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH))
      fifo(.clk(clk), .rst(rst),
           .fifo_empty(fifo_empty), .fifo_full(fifo_full), .awaiting_count(awaiting_count),
           .data_i(data_i), .push(push_posedge),
           .data_o(data_o), .drop(drop_posedge));
endmodule
