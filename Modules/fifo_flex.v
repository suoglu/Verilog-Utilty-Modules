/* ----------------------------------------- *
 * Title       : FIFO Buffer Flexible Size   *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : fifo_flex.v                 *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 02/09/2021                  *
 * Licence     : CERN-OHL-W                  *
 * ----------------------------------------- *
 * Description : A generic FIFO buffer with  *
 *               flexible buffer size        *
 * ----------------------------------------- */

module fifo_fl#(
  parameter DATA_WIDTH = 32, //Size of each data entry
  parameter FIFO_LENGTH = 16, //Number of entries
  parameter COUNTER_SIZE = $clog2(FIFO_LENGTH+1) //Shoud be able to fit FIFO_LENGTH, best to leave as it is
  )(
  input clk,
  input rst,
  //Flags
  output fifo_empty,
  output fifo_full,
  output reg [COUNTER_SIZE-1:0] awaiting_count, //Number of entires waiting in the buffer
  //Data in
  input [DATA_WIDTH-1:0] data_i,
  input push, //Add data_i to buffer, level sensitive
  //Data out
  output [DATA_WIDTH-1:0] data_o,
  input drop //Entry at data_o is read, should be set after data_o is read, level sensitive
  );
  reg [DATA_WIDTH-1:0] buffer[FIFO_LENGTH-1:0];
  reg [DATA_WIDTH-1:0] buffer_next[FIFO_LENGTH-1:0];
  integer i;

  //fifo flags
  assign fifo_empty = (awaiting_count == 0);
  assign fifo_full = (awaiting_count == FIFO_LENGTH);

  assign data_o = buffer[0];

  always@* begin //determine shifted buffer
    for (i = 0; i < (FIFO_LENGTH-1); i=i+1) begin
        buffer_next[i] = buffer[i+1];
      end
    buffer_next[FIFO_LENGTH-1] = (fifo_full & push) ? data_i : {DATA_WIDTH{1'b0}};
  end

  always@(posedge clk) begin //keep track of number of valid enties
    if(rst) begin
      awaiting_count <= {COUNTER_SIZE{1'b0}};
    end else begin
      if(push & ((~drop & ~fifo_full) | fifo_empty)) begin
        awaiting_count <= awaiting_count + {{COUNTER_SIZE-1{1'b0}},1'b1};
      end else if (drop & ~push & ~fifo_empty) begin
        awaiting_count <= awaiting_count - {{COUNTER_SIZE-1{1'b0}},1'b1};
      end
    end
  end

  always@(posedge clk) begin //Handle push drop
    if(rst) begin
      for (i = 0; i < FIFO_LENGTH; i=i+1) begin
        buffer[i] <= {DATA_WIDTH{1'b0}};
      end
    end else begin
      if(drop) begin
        for (i = 0; i < FIFO_LENGTH; i=i+1) begin
          buffer[i] <= (push & ((i+1) == awaiting_count)) ? data_i : buffer_next[i];
        end
      end else if(push & ~fifo_full) begin
        buffer[awaiting_count] <= data_i;
      end
    end
  end
endmodule

module fifo_fe#(
  parameter DATA_WIDTH = 32, //Size of each data entry
  parameter FIFO_LENGTH = 16, //Number of entries
  parameter COUNTER_SIZE = $clog2(FIFO_LENGTH+1) //Shoud be able to fit FIFO_LENGTH, best to leave as it is
  )(
  input clk,
  input rst,
  //Flags
  output fifo_empty,
  output fifo_full,
  output reg [COUNTER_SIZE-1:0] awaiting_count, //Number of entires waiting in the buffer
  //Data in
  input [DATA_WIDTH-1:0] data_i,
  input push, //Add data_i to buffer, edge sensitive
  //Data out
  output [DATA_WIDTH-1:0] data_o,
  input drop //Entry at data_o is read, should be set after data_o is read, edge sensitive
  );
  reg push_d, drop_d;
  wire push_posedge, drop_posedge;
  reg [DATA_WIDTH-1:0] buffer[FIFO_LENGTH-1:0];
  reg [DATA_WIDTH-1:0] buffer_next[FIFO_LENGTH-1:0];
  integer i;

  //fifo flags
  assign fifo_empty = (awaiting_count == 0);
  assign fifo_full = (awaiting_count == FIFO_LENGTH);

  assign data_o = buffer[0];

  //Edge detection
  always@(posedge clk) begin
    push_d <= push;
    drop_d <= drop;
  end
  assign drop_posedge = ~drop_d & drop;
  assign push_posedge = ~push_d & push;

  always@* begin //determine shifted buffer
    for (i = 0; i < (FIFO_LENGTH-1); i=i+1) begin
        buffer_next[i] = buffer[i+1];
      end
    buffer_next[FIFO_LENGTH-1] = (fifo_full & push_posedge) ? data_i : {DATA_WIDTH{1'b0}};
  end

  always@(posedge clk) begin //keep track of number of valid enties
    if(rst) begin
      awaiting_count <= {COUNTER_SIZE{1'b0}};
    end else begin
      if(push_posedge & ((~drop_posedge & ~fifo_full) | fifo_empty)) begin
        awaiting_count <= awaiting_count + {{COUNTER_SIZE-1{1'b0}},1'b1};
      end else if (drop_posedge & ~push_posedge & ~fifo_empty) begin
        awaiting_count <= awaiting_count - {{COUNTER_SIZE-1{1'b0}},1'b1};
      end
    end
  end

  always@(posedge clk) begin //Handle push drop
    if(rst) begin
      for (i = 0; i < FIFO_LENGTH; i=i+1) begin
        buffer[i] <= {DATA_WIDTH{1'b0}};
      end
    end else begin
      if(drop_posedge) begin
        for (i = 0; i < FIFO_LENGTH; i=i+1) begin
          buffer[i] <= (push_posedge & ((i+1) == awaiting_count)) ? data_i : buffer_next[i];
        end
      end else if(push_posedge & ~fifo_full) begin
        buffer[awaiting_count] <= data_i;
      end
    end
  end
endmodule
