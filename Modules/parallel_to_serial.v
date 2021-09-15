/* ----------------------------------------------- *
 * Title       : Parallel to Serial Converter      *
 * Project     : Verilog Utility Modules           *
 * ----------------------------------------------- *
 * File        : parallel_to_serial.v              *
 * Author      : Yigit Suoglu                      *
 * Last Edit   : 16/05/2021                        *
 * ----------------------------------------------- *
 * Description : Simple converter to convert       *
 *               paralel data to a serial stream   *
 * ----------------------------------------------- */

module parallel_to_serial#(
  parameter DATA_SIZE = 8,
  parameter MSB_FIRST = 1 //1 for MSB first, 0 for LSB first
)(
  input clk,
  input rst,
  input start,
  input [DATA_SIZE-1:0] paralel_i,
  output serial_o,
  output busy //on going conversion
);
  localparam COUNTER_SIZE = $clog2(DATA_SIZE-1);
  reg [COUNTER_SIZE-1:0] counter;
  wire counter_done;
  reg [DATA_SIZE-1:0] data_buffer;
  reg working;

  reg start_d;
  wire start_posedge;

  assign busy = working;


  //State
  always@(posedge clk) begin
    if(rst) begin
      working <= 1'b0;
    end else begin
      case(working)
        1'b0: working <= start_posedge;
        1'b1: working <= ~counter_done;
      endcase
    end
  end

  //Determine output
  assign serial_o = data_buffer[(DATA_SIZE-1)*MSB_FIRST];
  always@(posedge clk) begin
    if(start_posedge) begin
      data_buffer <= paralel_i;
    end else begin
      data_buffer <= (working) ? ((MSB_FIRST) ? (data_buffer << 1) : (data_buffer >> 1)) : data_buffer;
    end
  end


  //Counters
  assign counter_done = (counter == DATA_SIZE);
  always@(posedge clk) begin
    if(~working) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end


  //Sensitive to posedge
  assign start_posedge = ~start_d & start;
  always@(posedge clk) begin
    start_d <= start;
  end
endmodule