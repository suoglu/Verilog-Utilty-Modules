/* ----------------------------------------- *
 * Title       : Led Matrix Utility          *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : led_matix.v                 *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 30/01/2021                  *
 * ----------------------------------------- *
 * Description : Modules related to led      *
 *               matrices, such as driver,   *
 *               encoder                     *
 * ----------------------------------------- */

 //Static & Single array
module ledMatrixCntr_SS(clk,rst,en,data,rows,colms,an);
  input clk;
  input rst;
  input en;
  input [7:0] data;
  output [7:0] rows;
  output [7:0] colms;
  input an;

  wire [63:0] array;

  decoder8x8 dec(data,array);
  ledMatrixDriver8x8 lMrxDriver(clk,rst,en,array,rows,colms,an);
endmodule

/*
 +  array indices goes as: high to illuminate
 +  0,  1,  2,  3,  4,  5,  6,  7
 +  8,  9, 10, 11, 12, 13, 14, 15
 + 16, 17,  . . .
 + 24,  .
 +  .     .
 +  .        .
 +  . 
 */
module ledMatrixDriver8x8(clk,rst,en,array,rows,colms,an);
  input clk;
  input rst;
  input en;
  input [63:0] array;
  output [7:0] rows;
  output reg [7:0] colms;
  input an;

  reg [2:0] state;

  assign rows[0] = array[{3'd0, state}] ^ an;
  assign rows[1] = array[{3'd0, state}+6'd8] ^ an;
  assign rows[2] = array[{3'd0, state}+6'd16] ^ an;
  assign rows[3] = array[{3'd0, state}+6'd24] ^ an;
  assign rows[4] = array[{3'd0, state}+6'd32] ^ an;
  assign rows[5] = array[{3'd0, state}+6'd40] ^ an;
  assign rows[6] = array[{3'd0, state}+6'd48] ^ an;
  assign rows[7] = array[{3'd0, state}+6'd56] ^ an;
  
  //Current colmn
  always@(posedge clk)
    begin
      if(rst)
        state <= 3'd0;
      else
        state <= state + {2'd0, en};
    end
  //Colms selection
  always@*
    begin
      if(~en)
        colms = {8{~an}};
      else
        case(state)
          3'd7:
            begin 
              colms = {an,{7{~an}}};
            end
          3'd6:
            begin 
              colms = {~an,an,{6{~an}}};
            end
          3'd5:
            begin 
              colms = {{2{~an}},an,{5{~an}}};
            end
          3'd4:
            begin 
              colms = {{3{~an}},an,{4{~an}}};
            end
          3'd3:
            begin 
              colms = {{4{~an}},an,{3{~an}}};
            end
          3'd2:
            begin 
              colms = {{5{~an}},an,{2{~an}}};
            end
          3'd1:
            begin 
              colms = {{6{~an}},an,{1{~an}}};
            end
          3'd0:
            begin 
              colms = {{7{~an}},an};
            end
        endcase
        
    end
endmodule

module decoder8x8(data,array);
  input [7:0] data;
  output reg [63:0] array;

  always@*
    begin
      case(data)
        8'd0:   array = 64'h0018242424241800; //0
        8'd1:   array = 64'h0038101010181000; //1
        8'd2:   array = 64'h003c081020241800; //2
        8'd3:   array = 64'h0038101010181000; //3
        8'd4:   array = 64'h00207c2428302000; //4
        8'd5:   array = 64'h001c202018043c00; //5
        8'd6:   array = 64'h001824241c043800; //6
        8'd7:   array = 64'h0008080810203c00; //7
        8'd8:   array = 64'h1824241824241800; //8
        8'd9:   array = 64'h0018203824241800; //9
        8'd10:  array = 64'h0024243c24241800; //A
        8'd11:  array = 64'h1c24241c24241c00; //B
        8'd12:  array = 64'h0018240404241800; //C
        8'd13:  array = 64'h001c242424241c00; //D
        8'd14:  array = 64'h3c04043c04043c00; //E
        8'd15:  array = 64'h0404043c04043c00; //F
        8'd16:  array = 64'h3844443404443800; //G
        8'd17:  array = 64'h0024243c24240000; //H
        8'd18:  array = 64'h0038101010380000; //I
        8'd19:  array = 64'h0008141010103800; //J
        8'd20:  array = 64'h0014140c14140000; //K
        8'd21:  array = 64'h003c040404040000; //L
        8'd22:  array = 64'h004444546c440000; //M
        8'd23:  array = 64'h004464544c440000; //N
        8'd24:  array = 64'h0038444444380000; //O
        8'd25:  array = 64'h0004041c24241c00; //P
        8'd26:  array = 64'h6038444444380000; //Q
        8'd27:  array = 64'h00140c1c24241c00; //R
        8'd28:  array = 64'h1824201804241800; //S
        8'd29:  array = 64'h00101010107c0000; //T
        8'd30:  array = 64'h0030484848480000; //U
        8'd31:  array = 64'h0010284444440000; //V
        8'd32:  array = 64'h0028545454540000; //W
        8'd33:  array = 64'h0044281028440000; //X
        8'd34:  array = 64'h0010101028440000; //Y
        8'd35:  array = 64'h007c0810207c0000; //Z
        8'd36:  array = 64'h5824382018000000; //a
        8'd37:  array = 64'h001c24241c040404; //b
        8'd38:  array = 64'h0018040418000000; //c
        8'd39:  array = 64'h0038242438202020; //d
        8'd40:  array = 64'h0018043c24180000; //e
        8'd41:  array = 64'h0808081c08281000; //f
        8'd42:  array = 64'h1820382424180000; //g
        8'd43:  array = 64'h0014140c04040000; //h
        8'd44:  array = 64'h0004040400040000; //i
        8'd45:  array = 64'h0814101000100000; //j
        8'd46:  array = 64'h00140c1404040000; //k
        8'd47:  array = 64'h1008080808080400; //l
        8'd48:  array = 64'h0054542800000000; //m
        8'd49:  array = 64'h0014140c00000000; //n
        8'd50:  array = 64'h0018242418000000; //o
        8'd51:  array = 64'h04040c140c000000; //p
        8'd52:  array = 64'h1010181418000000; //q
        8'd53:  array = 64'h000404140c000000; //r
        8'd54:  array = 64'h0c10080418000000; //s
        8'd55:  array = 64'h00080404040e0400; //t
        8'd56:  array = 64'h0008141400000000; //u
        8'd57:  array = 64'h0008140000000000; //v
        8'd58:  array = 64'h0028540000000000; //w
        8'd59:  array = 64'h0014081400000000; //x
        8'd60:  array = 64'h0810181414000000; //y
        8'd61:  array = 64'h003c08103c000000; //z
        8'd62:  array = 64'h0002000000000000; //punc:.
        8'd63:  array = 64'h0302000000000000; //punc:,
        8'd64:  array = 64'h040004040810120c; //punc:?
        8'd65:  array = 64'h0400040404040400; //punc:!
        8'd66:  array = 64'h0002000200000000; //punc::
        8'd67:  array = 64'h0302000200000000; //punc:;
        8'd68:  array = 64'h0202040408080000; //punc:/
        8'd69:  array = 64'h0808040402020000; //punc:\
        8'd70:  array = 64'h0404040404040000; //op:|
        8'd71:  array = 64'h2619290a040a0400; //op:&
        8'd72:  array = 64'h0402020202040000; // (
        8'd73:  array = 64'h0204040404020000; // )
        8'd74:  array = 64'h0602020202060000; // [
        8'd75:  array = 64'h0604040404060000; // ]
        8'd76:  array = 64'h00040e0400000000; //op:+
        8'd77:  array = 64'h00000e0000000000; //op:-
        8'd78:  array = 64'h120c3f0c12000000; //op:*
        8'd79:  array = 64'h0012040812000000; //op:%
        8'd80:  array = 64'h00000a0400000000; //op:^
        8'd81:  array = 64'h0030484848480048; //Ü
        8'd82:  array = 64'h0038444444380028; //Ö
        8'd83:  array = 64'h0038101010380010; //İ
        8'd84:  array = 64'h3844443404783048; //Ğ
        8'd85:  array = 64'h24243c2424180024; //Ä
        8'd86:  array = 64'h0008141400140000; //ü
        8'd87:  array = 64'h0018242418002400; //ö
        8'd88:  array = 64'h0004040400000000; //ı
        8'd89:  array = 64'h1820382424181824; //ğ
        8'd90:  array = 64'h5824382018002400; //ä
        8'd91:  array = 64'h000a140000000000; //op:~
        8'd92:  array = 64'h143e143e14000000; //op:#
        8'd93:  array = 64'h020e0a060a060000; //ß
        8'd94:  array = 64'h0000000000004040; //punc:' begin
        8'd95:  array = 64'h0000000000000202; //punc:' end
        8'd96:  array = 64'h000000000e040806; //power: ²
        8'd97:  array = 64'h0000000608060806; //power: ³
        8'd98:  array = 64'h0402040000000000; //punc: <
        8'd99:  array = 64'h0204020000000000; //punc: >
        8'd100: array = 64'h1018240404241800; //Ç
        8'd101: array = 64'h1018242018042418; //Ş
        8'd102: array = 64'h0818040418000000; //ç
        8'd103: array = 64'h080c100804180000; //ş
        8'd104: array = 64'h00003c4200240000; //Smiley: :)
        8'd105: array = 64'h00007e0000240000; //Smiley: :|
        8'd106: array = 64'h00423c0000240000; //Smiley: :(
        8'd107: array = 64'h000e000e00000000; //punc:=
        8'd108: array = 64'h1c00081c08000000; //punc:+-
        8'd109: array = 64'h002a000000000000; //punc: ...
        8'd110: array = 64'h0000285428000000; //symbol: inf
        8'd111: array = 64'h000808082a1c0800; //Arrow: up
        8'd112: array = 64'h0010207e20100000; //Arrow: right
        8'd113: array = 64'h00081c2a08080800; //Arrow: down
        8'd114: array = 64'h0008047e04080000; //Arrow: left
        8'd115: array = 64'h003c421a3a221c00; //@
        //8'd: array = 64'h;
        default: array = 64'h0;
      endcase
    end
endmodule