/* ----------------------------------------------- *
 * Title       : Pseudo-Random Number Generators   *
 * Project     : Verilog Utility Modules           *
 * ----------------------------------------------- *
 * File        : pseudoRandNumGen.v                *
 * Author      : Yigit Suoglu                      *
 * Last Edit   : 10/04/2021                        *
 * ----------------------------------------------- *
 * Description : Set of modules to generate        *
 *               Pseudo-Random numbers             *
 * ----------------------------------------------- */

//Random Number Generator
/* 
 * Rules on parameters:
 * - SIZE > (DEPTH + 7)
 * - DEPTH > 0
 */
module randGen#(
parameter SIZE = 32, //Size of the output number
parameter DEPTH = 3) //Increases randomness and leght of the pattern
(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [(SIZE-1):0] seed;
  output reg [(SIZE-1):0] number;
  wire [(SIZE-1):0] lfsr[(DEPTH-1):0];

  integer i;
  genvar g, g_a;

  generate
    for (g = 0; g < DEPTH; g = g + 1) 
      begin
        lfsrg #(SIZE-g) lfsr(clk, rst, pause, newStart, seed[(SIZE-g-1):0], lfsr[g][(SIZE-g-1):0]);
      end
  endgenerate

   generate
    for (g_a = 1; g_a < DEPTH; g_a = g_a + 1) 
      begin
        assign lfsr[g_a][(SIZE-1):SIZE-g_a] = 0;
      end
  endgenerate

  always@* //Sum lfsr outputs
    begin
      number = 0;
      for (i = 0; i < DEPTH ; i = i + 1) 
        begin
          number = number + lfsr[i];
        end
    end
endmodule

//Parameterized Fibonacci Linear Shift Register, minimum size 6 bits
module lfsrf#(parameter SIZE = 8 //Minimum value 6
)(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [(SIZE-1):0] seed;
  output [(SIZE-1):0] number;
  reg [(SIZE-1):0] lfsr;
  wire [(SIZE-1):0] lfsr_next;
  wire newBit;

  assign number = lfsr;

  //Determine next values
  assign newBit = lfsr[SIZE-6] ^ lfsr[SIZE-4] ^ lfsr[SIZE-3] ^ lfsr[SIZE-1];
  assign lfsr_next = {lfsr[(SIZE-2):0], newBit};

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule

//Parameterized Galois Linear Shift Register, minimum size 7 bits
module lfsrg#(parameter SIZE = 8 //Minimum value 7
)(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [(SIZE-1):0] seed;
  output [(SIZE-1):0] number;
  reg [(SIZE-1):0] lfsr;
  reg [(SIZE-1):0] lfsr_next;

  assign number = lfsr;

  //Determine next values
  always@*
    begin
      lfsr_next[(SIZE-1):(SIZE-2)] = {lfsr[0], lfsr[SIZE-1]};
      lfsr_next[SIZE-3]   = lfsr[0] ^ lfsr[SIZE-2];
      lfsr_next[SIZE-4]   = lfsr[0] ^ lfsr[SIZE-3];
      lfsr_next[SIZE-5]   = lfsr[SIZE-4];
      lfsr_next[SIZE-6]   = lfsr[0] ^ lfsr[SIZE-5];
      lfsr_next[SIZE-7:0] = lfsr[(SIZE-6):1];
    end

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule

//8 bit Fibonacci Linear Shift Register
module lfsr8f(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [7:0] seed;
  output [7:0] number;
  reg [7:0] lfsr;
  wire [7:0] lfsr_next;
  wire newBit;

  assign number = lfsr;

  //Determine next values
  assign newBit = lfsr[2] ^ lfsr[4] ^ lfsr[5] ^ lfsr[7];
  assign lfsr_next = {lfsr[6:0], newBit};

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule

//16 bit Fibonacci Linear Shift Register
module lfsr16f(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [15:0] seed;
  output [15:0] number;
  reg [15:0] lfsr;
  wire [15:0] lfsr_next;
  wire newBit;

  assign number = lfsr;

  //Determine next values
  assign newBit = lfsr[10] ^ lfsr[12] ^ lfsr[13] ^ lfsr[15];
  assign lfsr_next = {lfsr[14:0], newBit};

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule

//8 bit Galois Linear Shift Register
module lfsr8g(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [7:0] seed;
  output [7:0] number;
  reg [7:0] lfsr;
  reg [7:0] lfsr_next;

  assign number = lfsr;

  //Determine next values
  always@*
    begin
      lfsr_next[7:6] = {lfsr[0], lfsr[7]};
      lfsr_next[5]   = lfsr[0] ^ lfsr[6];
      lfsr_next[4]   = lfsr[0] ^ lfsr[5];
      lfsr_next[3]   = lfsr[4];
      lfsr_next[2]   = lfsr[0] ^ lfsr[3];
      lfsr_next[1:0] = lfsr[2:1];
    end

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule

//16 bit Galois Linear Shift Register
module lfsr16g(clk, rst, pause, newStart, seed, number); 
  input clk;
  input rst; //async reset, updates seed
  input pause; //pause number generation
  input newStart; //sync reset, updates seed
  input [15:0] seed;
  output [15:0] number;
  reg [15:0] lfsr;
  reg [15:0] lfsr_next;

  assign number = lfsr;

  //Determine next values
  always@*
    begin
      lfsr_next[15:14] = {lfsr[0], lfsr[15]};
      lfsr_next[13]   = lfsr[0] ^ lfsr[14];
      lfsr_next[12]   = lfsr[0] ^ lfsr[13];
      lfsr_next[11]   = lfsr[12];
      lfsr_next[10]   = lfsr[0] ^ lfsr[11];
      lfsr_next[9:0] = lfsr[10:1];
    end

  always @(posedge clk or posedge rst)
	  begin
	    if(rst)
	      lfsr <= seed;
	    else
	      lfsr <= (newStart) ? seed : ((~pause) ? lfsr_next : lfsr);
	  end
endmodule
