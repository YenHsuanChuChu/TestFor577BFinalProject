/*

4-stage pipeline design


*/


`timescale 1ns/10ps
`include "./include/DW_sqrt.v"
`include "./include/DW_div.v"


//==============================================================
//  Module: Register File 
//==============================================================

module RegisterFile (
  input clk, input reset, input wrEn, 
  input [0:4] wrAddr, input [0:63] wrData, 
  input [0:4] rdAddr1, output reg [0:63] rdData1,
  input [0:4] rdAddr2, output reg [0:63] rdData2,
  input [0:2] PPP
);
  reg [0:63] regFile [0:31];
  
  always @(*) begin
        rdData1 = (rdAddr1 == 5'b00000) ? 64'h0000_0000_0000_0000 : regFile[rdAddr1];
        rdData2 = (rdAddr2 == 5'b00000) ? 64'h0000_0000_0000_0000 : regFile[rdAddr2];
  end

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      
      for (i = 0; i < 32; i = i + 1) begin
        regFile[i] <= 64'h0000_0000_0000_0000;
      end
    end 
    else if (wrEn == 1 && wrAddr != 5'b00000 && PPP < 5) begin
        if (PPP == 0) begin
            regFile[wrAddr] <= wrData;
        end
        else if (PPP == 1) begin
            regFile[wrAddr] <= {wrData[0:31], regFile[wrAddr][32:63]};
        end
        else if (PPP == 2) begin
            regFile[wrAddr] <= {regFile[wrAddr][0:31], wrData[32:63]};
        end
        else if (PPP == 3) begin
            regFile[wrAddr] <= {wrData[0:7], regFile[wrAddr][8:15], wrData[16:23], regFile[wrAddr][24:31], wrData[32:39], regFile[wrAddr][40:47], wrData[48:55], regFile[wrAddr][56:63]};
        end
        else if (PPP == 4) begin
            regFile[wrAddr] <= {regFile[wrAddr][0:7], wrData[8:15], regFile[wrAddr][16:23], wrData[24:31], regFile[wrAddr][32:39], wrData[40:47], regFile[wrAddr][48:55], wrData[56:63]};
        end
    end
  end


endmodule

//==============================================================
//  HDU
//==============================================================
module HDU(
    input [0:4] Dest_EX_Stage, Dest_WB_Stage, SR1_ID_Stage, SR2_ID_Stage,
    input Write_Intent_EX, Write_Intent_WB, read_Intent,
    input [0:2] PPP_EX, PPP_WB,
    output Haz_from_EX_to_SR1_B0, Haz_from_EX_to_SR1_B1, Haz_from_EX_to_SR1_B2, Haz_from_EX_to_SR1_B3, Haz_from_EX_to_SR1_B4, Haz_from_EX_to_SR1_B5, Haz_from_EX_to_SR1_B6, Haz_from_EX_to_SR1_B7, 
    output Haz_from_EX_to_SR2_B0, Haz_from_EX_to_SR2_B1, Haz_from_EX_to_SR2_B2, Haz_from_EX_to_SR2_B3, Haz_from_EX_to_SR2_B4, Haz_from_EX_to_SR2_B5, Haz_from_EX_to_SR2_B6, Haz_from_EX_to_SR2_B7,  
    output Haz_from_WB_to_SR1_B0, Haz_from_WB_to_SR1_B1, Haz_from_WB_to_SR1_B2, Haz_from_WB_to_SR1_B3, Haz_from_WB_to_SR1_B4, Haz_from_WB_to_SR1_B5, Haz_from_WB_to_SR1_B6, Haz_from_WB_to_SR1_B7, 
    output Haz_from_WB_to_SR2_B0, Haz_from_WB_to_SR2_B1, Haz_from_WB_to_SR2_B2, Haz_from_WB_to_SR2_B3, Haz_from_WB_to_SR2_B4, Haz_from_WB_to_SR2_B5, Haz_from_WB_to_SR2_B6, Haz_from_WB_to_SR2_B7
);
  assign Haz_from_EX_to_SR1_B0 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 3);
  assign Haz_from_EX_to_SR1_B1 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 4);
  assign Haz_from_EX_to_SR1_B2 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 3);
  assign Haz_from_EX_to_SR1_B3 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 4);
  assign Haz_from_EX_to_SR1_B4 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 3);
  assign Haz_from_EX_to_SR1_B5 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 4);
  assign Haz_from_EX_to_SR1_B6 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 3);
  assign Haz_from_EX_to_SR1_B7 = (Dest_EX_Stage == SR1_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 4);

  assign Haz_from_EX_to_SR2_B0 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 3);
  assign Haz_from_EX_to_SR2_B1 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 4);
  assign Haz_from_EX_to_SR2_B2 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 3);
  assign Haz_from_EX_to_SR2_B3 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 1 || PPP_EX == 4);
  assign Haz_from_EX_to_SR2_B4 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 3);
  assign Haz_from_EX_to_SR2_B5 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 4);
  assign Haz_from_EX_to_SR2_B6 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 3);
  assign Haz_from_EX_to_SR2_B7 = (Dest_EX_Stage == SR2_ID_Stage) && Write_Intent_EX && read_Intent && (PPP_EX == 0 || PPP_EX == 2 || PPP_EX == 4);

  assign Haz_from_WB_to_SR1_B0 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 3);
  assign Haz_from_WB_to_SR1_B1 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 4);
  assign Haz_from_WB_to_SR1_B2 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 3);
  assign Haz_from_WB_to_SR1_B3 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 4);
  assign Haz_from_WB_to_SR1_B4 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 3);
  assign Haz_from_WB_to_SR1_B5 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 4);
  assign Haz_from_WB_to_SR1_B6 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 3);
  assign Haz_from_WB_to_SR1_B7 = (Dest_WB_Stage == SR1_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 4);


  assign Haz_from_WB_to_SR2_B0 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 3);
  assign Haz_from_WB_to_SR2_B1 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 4);
  assign Haz_from_WB_to_SR2_B2 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 3);
  assign Haz_from_WB_to_SR2_B3 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 1 || PPP_WB == 4);
  assign Haz_from_WB_to_SR2_B4 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 3);
  assign Haz_from_WB_to_SR2_B5 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 4);
  assign Haz_from_WB_to_SR2_B6 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 3);
  assign Haz_from_WB_to_SR2_B7 = (Dest_WB_Stage == SR2_ID_Stage) && Write_Intent_WB && read_Intent && (PPP_WB == 0 || PPP_WB == 2 || PPP_WB == 4);


endmodule


//===========================================================
// ALU 
//===========================================================
module ALU (
  input  [0:63] dataA_ALU_in,
  input  [0:63] dataB_ALU_in,
  input  [0:5]  function_code,
  input  [0:1]  ww,
  output reg [0:63] data_ALU_out
);

  integer array8[0:7];   // per-lane shift amounts

  // ---------- Divider outputs ----------
  wire [0:63] div8_quotient,  remain8;
  wire [0:63] div16_quotient, remain16;
  wire [0:63] div32_quotient, remain32;
  wire [0:63] div64_quotient, remain64;

  // ---------- Sqrt outputs ----------
  wire [0:63] sqrt8_output;
  wire [0:31] sqrt16_out, sqrt32_out, sqrt64_out;

  // ---------- opcode names (readability) ----------
  localparam [5:0]
    OP_VAND  = 6'b000001,
    OP_VOR   = 6'b000010,
    OP_VXOR  = 6'b000011,
    OP_VNOT  = 6'b000100,
    OP_VMOV  = 6'b000101,
    OP_VADD  = 6'b000110,
    OP_VSUB  = 6'b000111,
    OP_VMULE = 6'b001000,  // even unsigned
    OP_VMULO = 6'b001001,  // odd  unsigned
    OP_VSLL  = 6'b001010,
    OP_VSRL  = 6'b001011,
    OP_VSRA  = 6'b001100,
    OP_VRTTH = 6'b001101,
    OP_VDIV  = 6'b001110,
    OP_VMOD  = 6'b001111,
    OP_VSQEU = 6'b010000,
    OP_VSQOU = 6'b010001,
    OP_VSQRT = 6'b010010;

  // ---------- width decode helper ----------
  function integer width_from_ww;
    input [0:1] ww_local; // note: [0:1] ordering follows your style
    begin
      case (ww_local)
        2'b00: width_from_ww = 8;
        2'b01: width_from_ww = 16;
        2'b10: width_from_ww = 32;
        default: width_from_ww = 64; // 2'b11
      endcase
    end
  endfunction

  // ---------- DesignWare DIV instantiations ----------
  // 8-bit lanes
  DW_div div8_0(.a(dataA_ALU_in[0:7]),   .b(dataB_ALU_in[0:7]),   .quotient(div8_quotient[0:7]),   .remainder(remain8[0:7]),   .divide_by_0());
  DW_div div8_1(.a(dataA_ALU_in[8:15]),  .b(dataB_ALU_in[8:15]),  .quotient(div8_quotient[8:15]),  .remainder(remain8[8:15]),  .divide_by_0());
  DW_div div8_2(.a(dataA_ALU_in[16:23]), .b(dataB_ALU_in[16:23]), .quotient(div8_quotient[16:23]), .remainder(remain8[16:23]), .divide_by_0());
  DW_div div8_3(.a(dataA_ALU_in[24:31]), .b(dataB_ALU_in[24:31]), .quotient(div8_quotient[24:31]), .remainder(remain8[24:31]), .divide_by_0());
  DW_div div8_4(.a(dataA_ALU_in[32:39]), .b(dataB_ALU_in[32:39]), .quotient(div8_quotient[32:39]), .remainder(remain8[32:39]), .divide_by_0());
  DW_div div8_5(.a(dataA_ALU_in[40:47]), .b(dataB_ALU_in[40:47]), .quotient(div8_quotient[40:47]), .remainder(remain8[40:47]), .divide_by_0());
  DW_div div8_6(.a(dataA_ALU_in[48:55]), .b(dataB_ALU_in[48:55]), .quotient(div8_quotient[48:55]), .remainder(remain8[48:55]), .divide_by_0());
  DW_div div8_7(.a(dataA_ALU_in[56:63]), .b(dataB_ALU_in[56:63]), .quotient(div8_quotient[56:63]), .remainder(remain8[56:63]), .divide_by_0());

  // 16-bit lanes
  DW_div #(.a_width(16), .b_width(16)) div16_0(.a(dataA_ALU_in[0:15]),  .b(dataB_ALU_in[0:15]),  .quotient(div16_quotient[0:15]),  .remainder(remain16[0:15]),  .divide_by_0());
  DW_div #(.a_width(16), .b_width(16)) div16_1(.a(dataA_ALU_in[16:31]), .b(dataB_ALU_in[16:31]), .quotient(div16_quotient[16:31]), .remainder(remain16[16:31]), .divide_by_0());
  DW_div #(.a_width(16), .b_width(16)) div16_2(.a(dataA_ALU_in[32:47]), .b(dataB_ALU_in[32:47]), .quotient(div16_quotient[32:47]), .remainder(remain16[32:47]), .divide_by_0());
  DW_div #(.a_width(16), .b_width(16)) div16_3(.a(dataA_ALU_in[48:63]), .b(dataB_ALU_in[48:63]), .quotient(div16_quotient[48:63]), .remainder(remain16[48:63]), .divide_by_0());

  // 32-bit lanes
  DW_div #(.a_width(32), .b_width(32)) div32_0(.a(dataA_ALU_in[0:31]),  .b(dataB_ALU_in[0:31]),  .quotient(div32_quotient[0:31]),  .remainder(remain32[0:31]),  .divide_by_0());
  DW_div #(.a_width(32), .b_width(32)) div32_1(.a(dataA_ALU_in[32:63]), .b(dataB_ALU_in[32:63]), .quotient(div32_quotient[32:63]), .remainder(remain32[32:63]), .divide_by_0());

  // 64-bit
  DW_div #(.a_width(64), .b_width(64)) div64_0(.a(dataA_ALU_in[0:63]), .b(dataB_ALU_in[0:63]), .quotient(div64_quotient[0:63]), .remainder(remain64[0:63]), .divide_by_0());

  // ---------- DesignWare SQRT instantiations ----------
  // 8-bit lanes (roots are 4b; you packed each into the high nibble of each byte slice)
  DW_sqrt sqrt8_0(.a(dataA_ALU_in[0:7]),   .root(sqrt8_output[4:7]));
  DW_sqrt sqrt8_1(.a(dataA_ALU_in[8:15]),  .root(sqrt8_output[12:15]));
  DW_sqrt sqrt8_2(.a(dataA_ALU_in[16:23]), .root(sqrt8_output[20:23]));
  DW_sqrt sqrt8_3(.a(dataA_ALU_in[24:31]), .root(sqrt8_output[28:31]));
  DW_sqrt sqrt8_4(.a(dataA_ALU_in[32:39]), .root(sqrt8_output[36:39]));
  DW_sqrt sqrt8_5(.a(dataA_ALU_in[40:47]), .root(sqrt8_output[44:47]));
  DW_sqrt sqrt8_6(.a(dataA_ALU_in[48:55]), .root(sqrt8_output[52:55]));
  DW_sqrt sqrt8_7(.a(dataA_ALU_in[56:63]), .root(sqrt8_output[60:63]));

  // 16/32/64-bit lanes
  DW_sqrt #(.width(16)) sqrt16_0(.a(dataA_ALU_in[0:15]),   .root(sqrt16_out[0:7]));
  DW_sqrt #(.width(16)) sqrt16_1(.a(dataA_ALU_in[16:31]),  .root(sqrt16_out[8:15]));
  DW_sqrt #(.width(16)) sqrt16_2(.a(dataA_ALU_in[32:47]),  .root(sqrt16_out[16:23]));
  DW_sqrt #(.width(16)) sqrt16_3(.a(dataA_ALU_in[48:63]),  .root(sqrt16_out[24:31]));
  DW_sqrt #(.width(32)) sqrt32_0(.a(dataA_ALU_in[0:31]),   .root(sqrt32_out[0:15]));
  DW_sqrt #(.width(32)) sqrt32_1(.a(dataA_ALU_in[32:63]),  .root(sqrt32_out[16:31]));
  DW_sqrt #(.width(64)) sqrt64_0(.a(dataA_ALU_in[0:63]),   .root(sqrt64_out[0:31]));

  // ---------- main comb logic ----------
  integer w;
  always @* begin
    w = width_from_ww(ww);
    data_ALU_out = 64'h0;  // default/NOP

    case (function_code)

      // bitwise
      OP_VAND:  data_ALU_out = dataA_ALU_in & dataB_ALU_in;
      OP_VOR:   data_ALU_out = dataA_ALU_in | dataB_ALU_in;
      OP_VXOR:  data_ALU_out = dataA_ALU_in ^ dataB_ALU_in;
      OP_VNOT:  data_ALU_out = ~dataA_ALU_in;
      OP_VMOV:  data_ALU_out =  dataA_ALU_in;

      // VADD
      OP_VADD: begin
        case (w)
          8:  begin
                data_ALU_out[ 0: 7] = dataA_ALU_in[ 0: 7] + dataB_ALU_in[ 0: 7];
                data_ALU_out[ 8:15] = dataA_ALU_in[ 8:15] + dataB_ALU_in[ 8:15];
                data_ALU_out[16:23] = dataA_ALU_in[16:23] + dataB_ALU_in[16:23];
                data_ALU_out[24:31] = dataA_ALU_in[24:31] + dataB_ALU_in[24:31];
                data_ALU_out[32:39] = dataA_ALU_in[32:39] + dataB_ALU_in[32:39];
                data_ALU_out[40:47] = dataA_ALU_in[40:47] + dataB_ALU_in[40:47];
                data_ALU_out[48:55] = dataA_ALU_in[48:55] + dataB_ALU_in[48:55];
                data_ALU_out[56:63] = dataA_ALU_in[56:63] + dataB_ALU_in[56:63];
              end
          16: begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0:15] + dataB_ALU_in[ 0:15];
                data_ALU_out[16:31] = dataA_ALU_in[16:31] + dataB_ALU_in[16:31];
                data_ALU_out[32:47] = dataA_ALU_in[32:47] + dataB_ALU_in[32:47];
                data_ALU_out[48:63] = dataA_ALU_in[48:63] + dataB_ALU_in[48:63];
              end
          32: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:31] + dataB_ALU_in[ 0:31];
                data_ALU_out[32:63] = dataA_ALU_in[32:63] + dataB_ALU_in[32:63];
              end
          default: data_ALU_out = dataA_ALU_in + dataB_ALU_in; // 64
        endcase
      end

      // VSUB
      OP_VSUB: begin
        case (w)
          8:  begin
                data_ALU_out[ 0: 7] = dataA_ALU_in[ 0: 7] - dataB_ALU_in[ 0: 7];
                data_ALU_out[ 8:15] = dataA_ALU_in[ 8:15] - dataB_ALU_in[ 8:15];
                data_ALU_out[16:23] = dataA_ALU_in[16:23] - dataB_ALU_in[16:23];
                data_ALU_out[24:31] = dataA_ALU_in[24:31] - dataB_ALU_in[24:31];
                data_ALU_out[32:39] = dataA_ALU_in[32:39] - dataB_ALU_in[32:39];
                data_ALU_out[40:47] = dataA_ALU_in[40:47] - dataB_ALU_in[40:47];
                data_ALU_out[48:55] = dataA_ALU_in[48:55] - dataB_ALU_in[48:55];
                data_ALU_out[56:63] = dataA_ALU_in[56:63] - dataB_ALU_in[56:63];
              end
          16: begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0:15] - dataB_ALU_in[ 0:15];
                data_ALU_out[16:31] = dataA_ALU_in[16:31] - dataB_ALU_in[16:31];
                data_ALU_out[32:47] = dataA_ALU_in[32:47] - dataB_ALU_in[32:47];
                data_ALU_out[48:63] = dataA_ALU_in[48:63] - dataB_ALU_in[48:63];
              end
          32: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:31] - dataB_ALU_in[ 0:31];
                data_ALU_out[32:63] = dataA_ALU_in[32:63] - dataB_ALU_in[32:63];
              end
          default: data_ALU_out = dataA_ALU_in - dataB_ALU_in; // 64
        endcase
      end

      // VMULEU (even lanes)
      OP_VMULE: begin
        case (w)
          8:  begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0: 7] * dataB_ALU_in[ 0: 7];
                data_ALU_out[16:31] = dataA_ALU_in[16:23] * dataB_ALU_in[16:23];
                data_ALU_out[32:47] = dataA_ALU_in[32:39] * dataB_ALU_in[32:39];
                data_ALU_out[48:63] = dataA_ALU_in[48:55] * dataB_ALU_in[48:55];
              end
          16: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:15] * dataB_ALU_in[ 0:15];
                data_ALU_out[32:63] = dataA_ALU_in[32:47] * dataB_ALU_in[32:47];
              end
          32: data_ALU_out = dataA_ALU_in[0:31] * dataB_ALU_in[0:31];
          default: data_ALU_out = 64'h0; // 64 (NOP per your original)
        endcase
      end

      // VMULOU (odd lanes)
      OP_VMULO: begin
        case (w)
          8:  begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 8:15] * dataB_ALU_in[ 8:15];
                data_ALU_out[16:31] = dataA_ALU_in[24:31] * dataB_ALU_in[24:31];
                data_ALU_out[32:47] = dataA_ALU_in[40:47] * dataB_ALU_in[40:47];
                data_ALU_out[48:63] = dataA_ALU_in[56:63] * dataB_ALU_in[56:63];
              end
          16: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[16:31] * dataB_ALU_in[16:31];
                data_ALU_out[32:63] = dataA_ALU_in[48:63] * dataB_ALU_in[48:63];
              end
          32: data_ALU_out = dataA_ALU_in[32:63] * dataB_ALU_in[32:63];
          default: data_ALU_out = 64'h0; // 64 (NOP per your original)
        endcase
      end

      // VSLL
      OP_VSLL: begin
        case (w)
          8:  begin
                array8[0] = dataB_ALU_in[ 5: 7];
                array8[1] = dataB_ALU_in[13:15];
                array8[2] = dataB_ALU_in[21:23];
                array8[3] = dataB_ALU_in[29:31];
                array8[4] = dataB_ALU_in[37:39];
                array8[5] = dataB_ALU_in[45:47];
                array8[6] = dataB_ALU_in[53:55];
                array8[7] = dataB_ALU_in[61:63];
                data_ALU_out[ 0: 7] = dataA_ALU_in[ 0: 7] << array8[0];
                data_ALU_out[ 8:15] = dataA_ALU_in[ 8:15] << array8[1];
                data_ALU_out[16:23] = dataA_ALU_in[16:23] << array8[2];
                data_ALU_out[24:31] = dataA_ALU_in[24:31] << array8[3];
                data_ALU_out[32:39] = dataA_ALU_in[32:39] << array8[4];
                data_ALU_out[40:47] = dataA_ALU_in[40:47] << array8[5];
                data_ALU_out[48:55] = dataA_ALU_in[48:55] << array8[6];
                data_ALU_out[56:63] = dataA_ALU_in[56:63] << array8[7];
              end
          16: begin
                array8[0] = dataB_ALU_in[12:15];
                array8[1] = dataB_ALU_in[28:31];
                array8[2] = dataB_ALU_in[44:47];
                array8[3] = dataB_ALU_in[60:63];
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0:15] << array8[0];
                data_ALU_out[16:31] = dataA_ALU_in[16:31] << array8[1];
                data_ALU_out[32:47] = dataA_ALU_in[32:47] << array8[2];
                data_ALU_out[48:63] = dataA_ALU_in[48:63] << array8[3];
              end
          32: begin
                array8[0] = dataB_ALU_in[27:31];
                array8[1] = dataB_ALU_in[59:63];
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:31] << array8[0];
                data_ALU_out[32:63] = dataA_ALU_in[32:63] << array8[1];
              end
          default: begin
                array8[0] = dataB_ALU_in[58:63];
                data_ALU_out[0:63] = dataA_ALU_in[0:63] << array8[0];
              end
        endcase
      end

      // VSRL
      OP_VSRL: begin
        case (w)
          8:  begin
                array8[0] = dataB_ALU_in[ 5: 7];
                array8[1] = dataB_ALU_in[13:15];
                array8[2] = dataB_ALU_in[21:23];
                array8[3] = dataB_ALU_in[29:31];
                array8[4] = dataB_ALU_in[37:39];
                array8[5] = dataB_ALU_in[45:47];
                array8[6] = dataB_ALU_in[53:55];
                array8[7] = dataB_ALU_in[61:63];
                data_ALU_out[ 0: 7] = dataA_ALU_in[ 0: 7] >> array8[0];
                data_ALU_out[ 8:15] = dataA_ALU_in[ 8:15] >> array8[1];
                data_ALU_out[16:23] = dataA_ALU_in[16:23] >> array8[2];
                data_ALU_out[24:31] = dataA_ALU_in[24:31] >> array8[3];
                data_ALU_out[32:39] = dataA_ALU_in[32:39] >> array8[4];
                data_ALU_out[40:47] = dataA_ALU_in[40:47] >> array8[5];
                data_ALU_out[48:55] = dataA_ALU_in[48:55] >> array8[6];
                data_ALU_out[56:63] = dataA_ALU_in[56:63] >> array8[7];
              end
          16: begin
                array8[0] = dataB_ALU_in[12:15];
                array8[1] = dataB_ALU_in[28:31];
                array8[2] = dataB_ALU_in[44:47];
                array8[3] = dataB_ALU_in[60:63];
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0:15] >> array8[0];
                data_ALU_out[16:31] = dataA_ALU_in[16:31] >> array8[1];
                data_ALU_out[32:47] = dataA_ALU_in[32:47] >> array8[2];
                data_ALU_out[48:63] = dataA_ALU_in[48:63] >> array8[3];
              end
          32: begin
                array8[0] = dataB_ALU_in[27:31];
                array8[1] = dataB_ALU_in[59:63];
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:31] >> array8[0];
                data_ALU_out[32:63] = dataA_ALU_in[32:63] >> array8[1];
              end
          default: begin
                array8[0] = dataB_ALU_in[58:63];
                data_ALU_out[0:63] = dataA_ALU_in[0:63] >> array8[0];
              end
        endcase
      end

      // VSRA
      OP_VSRA: begin
        case (w)
          8:  begin
                array8[0] = dataB_ALU_in[ 5: 7];
                array8[1] = dataB_ALU_in[13:15];
                array8[2] = dataB_ALU_in[21:23];
                array8[3] = dataB_ALU_in[29:31];
                array8[4] = dataB_ALU_in[37:39];
                array8[5] = dataB_ALU_in[45:47];
                array8[6] = dataB_ALU_in[53:55];
                array8[7] = dataB_ALU_in[61:63];
                data_ALU_out[ 0: 7] = $signed(dataA_ALU_in[ 0: 7]) >>> array8[0];
                data_ALU_out[ 8:15] = $signed(dataA_ALU_in[ 8:15]) >>> array8[1];
                data_ALU_out[16:23] = $signed(dataA_ALU_in[16:23]) >>> array8[2];
                data_ALU_out[24:31] = $signed(dataA_ALU_in[24:31]) >>> array8[3];
                data_ALU_out[32:39] = $signed(dataA_ALU_in[32:39]) >>> array8[4];
                data_ALU_out[40:47] = $signed(dataA_ALU_in[40:47]) >>> array8[5];
                data_ALU_out[48:55] = $signed(dataA_ALU_in[48:55]) >>> array8[6];
                data_ALU_out[56:63] = $signed(dataA_ALU_in[56:63]) >>> array8[7];
              end
          16: begin
                array8[0] = dataB_ALU_in[12:15];
                array8[1] = dataB_ALU_in[28:31];
                array8[2] = dataB_ALU_in[44:47];
                array8[3] = dataB_ALU_in[60:63];
                data_ALU_out[ 0:15] = $signed(dataA_ALU_in[ 0:15]) >>> array8[0];
                data_ALU_out[16:31] = $signed(dataA_ALU_in[16:31]) >>> array8[1];
                data_ALU_out[32:47] = $signed(dataA_ALU_in[32:47]) >>> array8[2];
                data_ALU_out[48:63] = $signed(dataA_ALU_in[48:63]) >>> array8[3];
              end
          32: begin
                array8[0] = dataB_ALU_in[27:31];
                array8[1] = dataB_ALU_in[59:63];
                data_ALU_out[ 0:31] = $signed(dataA_ALU_in[ 0:31]) >>> array8[0];
                data_ALU_out[32:63] = $signed(dataA_ALU_in[32:63]) >>> array8[1];
              end
          default: begin
                array8[0] = dataB_ALU_in[58:63];
                data_ALU_out[0:63] = $signed(dataA_ALU_in[0:63]) >>> array8[0];
              end
        endcase
      end

      // VRTTH (rotate by half-element)
      OP_VRTTH: begin
        case (w)
          8:  begin
                data_ALU_out[ 0: 7] = {dataA_ALU_in[ 4: 7], dataA_ALU_in[ 0: 3]};
                data_ALU_out[ 8:15] = {dataA_ALU_in[12:15], dataA_ALU_in[ 8:11]};
                data_ALU_out[16:23] = {dataA_ALU_in[20:23], dataA_ALU_in[16:19]};
                data_ALU_out[24:31] = {dataA_ALU_in[28:31], dataA_ALU_in[24:27]};
                data_ALU_out[32:39] = {dataA_ALU_in[36:39], dataA_ALU_in[32:35]};
                data_ALU_out[40:47] = {dataA_ALU_in[44:47], dataA_ALU_in[40:43]};
                data_ALU_out[48:55] = {dataA_ALU_in[52:55], dataA_ALU_in[48:51]};
                data_ALU_out[56:63] = {dataA_ALU_in[60:63], dataA_ALU_in[56:59]};
              end
          16: begin
                data_ALU_out[ 0:15] = {dataA_ALU_in[ 8:15], dataA_ALU_in[ 0: 7]};
                data_ALU_out[16:31] = {dataA_ALU_in[24:31], dataA_ALU_in[16:23]};
                data_ALU_out[32:47] = {dataA_ALU_in[40:47], dataA_ALU_in[32:39]};
                data_ALU_out[48:63] = {dataA_ALU_in[56:63], dataA_ALU_in[48:55]};
              end
          32: begin
                data_ALU_out[ 0:31] = {dataA_ALU_in[16:31], dataA_ALU_in[ 0:15]};
                data_ALU_out[32:63] = {dataA_ALU_in[48:63], dataA_ALU_in[32:47]};
              end
          default:
                data_ALU_out[0:63] = {dataA_ALU_in[32:63], dataA_ALU_in[0:31]}; // 64
        endcase
      end

      // VDIV / VMOD
      OP_VDIV: data_ALU_out = (w==8 ) ? div8_quotient  :
                               (w==16) ? div16_quotient :
                               (w==32) ? div32_quotient : div64_quotient;

      OP_VMOD: data_ALU_out = (w==8 ) ? remain8  :
                               (w==16) ? remain16 :
                               (w==32) ? remain32 : remain64;

      // VSQEU / VSQOU
      OP_VSQEU: begin
        case (w)
          8:  begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 0: 7] * dataA_ALU_in[ 0: 7];
                data_ALU_out[16:31] = dataA_ALU_in[16:23] * dataA_ALU_in[16:23];
                data_ALU_out[32:47] = dataA_ALU_in[32:39] * dataA_ALU_in[32:39];
                data_ALU_out[48:63] = dataA_ALU_in[48:55] * dataA_ALU_in[48:55];
              end
          16: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[ 0:15] * dataA_ALU_in[ 0:15];
                data_ALU_out[32:63] = dataA_ALU_in[32:47] * dataA_ALU_in[32:47];
              end
          32: data_ALU_out = dataA_ALU_in[0:31] * dataA_ALU_in[0:31];
          default: data_ALU_out = 64'h0; // 64 (NOP per your original)
        endcase
      end

      OP_VSQOU: begin
        case (w)
          8:  begin
                data_ALU_out[ 0:15] = dataA_ALU_in[ 8:15] * dataA_ALU_in[ 8:15];
                data_ALU_out[16:31] = dataA_ALU_in[24:31] * dataA_ALU_in[24:31];
                data_ALU_out[32:47] = dataA_ALU_in[40:47] * dataA_ALU_in[40:47];
                data_ALU_out[48:63] = dataA_ALU_in[56:63] * dataA_ALU_in[56:63];
              end
          16: begin
                data_ALU_out[ 0:31] = dataA_ALU_in[16:31] * dataA_ALU_in[16:31];
                data_ALU_out[32:63] = dataA_ALU_in[48:63] * dataA_ALU_in[48:63];
              end
          32: data_ALU_out = dataA_ALU_in[32:63] * dataA_ALU_in[32:63];
          default: data_ALU_out = 64'h0; // 64 (NOP per your original)
        endcase
      end

      // VSQRT
      OP_VSQRT: begin
        case (w)
          8:  begin
                data_ALU_out[ 0: 7] = {4'b0000, sqrt8_output[ 4: 7]};
                data_ALU_out[ 8:15] = {4'b0000, sqrt8_output[12:15]};
                data_ALU_out[16:23] = {4'b0000, sqrt8_output[20:23]};
                data_ALU_out[24:31] = {4'b0000, sqrt8_output[28:31]};
                data_ALU_out[32:39] = {4'b0000, sqrt8_output[36:39]};
                data_ALU_out[40:47] = {4'b0000, sqrt8_output[44:47]};
                data_ALU_out[48:55] = {4'b0000, sqrt8_output[52:55]};
                data_ALU_out[56:63] = {4'b0000, sqrt8_output[60:63]};
              end
          16: begin
                data_ALU_out[ 0:15] = {8'h00, sqrt16_out[ 0: 7]};
                data_ALU_out[16:31] = {8'h00, sqrt16_out[ 8:15]};
                data_ALU_out[32:47] = {8'h00, sqrt16_out[16:23]};
                data_ALU_out[48:63] = {8'h00, sqrt16_out[24:31]};
              end
          32: begin
                data_ALU_out[ 0:31] = {16'h0000, sqrt32_out[ 0:15]};
                data_ALU_out[32:63] = {16'h0000, sqrt32_out[16:31]};
              end
          default: data_ALU_out = {32'h0000_0000, sqrt64_out[0:31]}; // 64
        endcase
      end

      default: begin
        data_ALU_out = 64'h0; // NOP/undefined
      end
    endcase
  end

endmodule


//==============================================================
//  Module: pipeline_4stages
//==============================================================
//
//    IF  →  ID  →  EX/MEM  →  WB
//
//==============================================================

module pipeline_stages (
    input  clk,                      // System clock
    input  reset,                    // Synchronous reset (active high)
    input  en,                       // Pipeline enable: 1 = advance, 0 = stall

    //===============================
    // IF/ID stage boundary register
    //===============================
    input  [0:31]  input_stage1_IF_ID,     // Input data from IF stage
    output reg [0:31] output_stage1_IF_ID, // Latched output to ID stage

    //===============================
    // ID/EXMEM stage boundary register
    //===============================
    input  [0:159] input_stage2_ID_EXMEM,      // Input data from ID stage
    output reg [0:159] output_stage2_ID_EXMEM, // Latched output to EX/MEM stage

    //===============================
    // EXMEM/WB stage boundary register
    //===============================
    input  [0:72]  input_stage3_EXMEM_WB,      // Input data from EX/MEM stage
    output reg [0:72] output_stage3_EXMEM_WB   // Latched output to WB stage
);

    //----------------------------------------------------------
    // Sequential Logic: update pipeline registers each cycle
    //----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            // On reset: clear all pipeline stages (insert NOPs)
            output_stage1_IF_ID     <= 0;
            output_stage2_ID_EXMEM  <= 0;
            output_stage3_EXMEM_WB  <= 0;

        end else if (en) begin
            // On normal operation: capture new stage data
            output_stage1_IF_ID     <= input_stage1_IF_ID;
            output_stage2_ID_EXMEM  <= input_stage2_ID_EXMEM;
            output_stage3_EXMEM_WB  <= input_stage3_EXMEM_WB;

            // If 'en' is 0, this block does not execute,
            // so the previous values are retained (stall)
        end
    end

endmodule



//==============================================================
//  Module: counter
//==============================================================
//  Usage in CPU Pipeline:
//  - Typically used to introduce a multi-cycle stall for 
//    operations such as load/store (memory access).
//  - While `count` is nonzero, the pipeline can be stalled.
//==============================================================

module counter(
    input  wire       clk,            // System clock
    input  wire       reset,          // Asynchronous reset (active high)
    input  wire       start,          // Start signal to begin counting
    input  wire [0:2] number_cycles,  // Number of cycles to count (3-bit)
    output reg  [0:2] count           // Current count output
);


    reg counting;                     // Flag: 1 when counter is active
    reg [0:2] cycle_counter;          // Tracks how many cycles have elapsed


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all state variables
            count         <= 0;
            counting      <= 0;
            cycle_counter <= 0;

        end else begin

            if (start && !counting) begin
                counting      <= 1;   // Enter counting mode
                cycle_counter <= 0;   // Reset internal cycle counter
                count         <= 1;   // Initialize output to 1

            end else if (counting) begin
                if (cycle_counter < number_cycles) begin
                    // Increment internal and output counters
                    cycle_counter <= cycle_counter + 1;
                    count         <= count + 1;
                end else begin
                    counting      <= 0;   // Stop counting
                    count         <= 0;   // Reset count output to zero
                end
            end
        end
    end

endmodule




module TOP(
    input clk, reset,
    input [0:31] Instr_from_imem,
    output reg [0:31] PC,
    output memEn_to_dmem, memWrEn_to_dmem,
    output [0:31] memAddr_to_dmem,
    output [0:63] data_to_dmem,
    input [0:63] data_from_dmem,

    output [0:1] addr_nic,
    output [0:63] din_to_nic,
    input [0:63] dout_from_nic,
    output nicEn,
    output nicWrEn
);

  // === IF stage wires ===
  wire [0:31] instr_ifid_in;         
  wire [0:31] ifid_q;                

  // === ID stage decode  ===
  wire [0:4] rsA, rsB, rdW;          
  wire [0:4] rf_addr1, rf_addr2;     
  wire        is_rdtype;             
  wire        is_branch;             
  wire        br_taken;              
  wire [0:63] rf_data1, rf_data2;    

  wire [0:31] instr_to_idex;         

  // Per-byte forwarded/selected sources
  wire [0:7] src1_B0, src1_B1, src1_B2, src1_B3, src1_B4, src1_B5, src1_B6, src1_B7; 
  wire [0:7] src2_B0, src2_B1, src2_B2, src2_B3, src2_B4, src2_B5, src2_B6, src2_B7; 
  wire [0:63] src1_merged, src2_merged;                                              

  // === Pipeline regs ===
  wire [0:159] stage2_ID_EXMEM_out;           
  wire [0:72]  stage3_EXMEM_WB_out;           

  // === Forwarding ===
  wire [0:63] fwd_ex, fwd_wb;       

  // === EX/MEM signals ===
  wire        ALU_en;
  wire [0:63] ALU_data_out;
  wire [0:63] data_to_stage3;
  wire        stall;

  // === WB controls ===
  wire        wb_regwen;            
  wire [0:4]  wb_waddr;             
  wire [0:2]  wb_ppp;               

  pipeline_stages pipe(
    .clk(clk), .reset(reset), .en(~stall),
    .input_stage1_IF_ID({instr_ifid_in}),                    .output_stage1_IF_ID(ifid_q),
    .input_stage2_ID_EXMEM({instr_to_idex, src1_merged, src2_merged}), .output_stage2_ID_EXMEM(stage2_ID_EXMEM_out),
    .input_stage3_EXMEM_WB({(stage2_ID_EXMEM_out[0:5] == 6'b100000 || stage2_ID_EXMEM_out[0:5] == 6'b101010),
                             stage2_ID_EXMEM_out[6:10],
                             stage2_ID_EXMEM_out[21:23],
                             data_to_stage3}),
    .output_stage3_EXMEM_WB(stage3_EXMEM_WB_out) // [6:10]: WrAddr, [21:23]: PPP, RegWrEn from opcode
  );

  // =========================
  // IF Stage
  // =========================
  always @(posedge clk) begin
    if (reset) begin
      PC <= 0; // PC 0 on reset
    end else if (~stall) begin
      PC <= br_taken ? {16'b0, ifid_q[16:31]} : PC + 4;
    end
  end

  // Basic instruction checks
  wire bad_func_code, invalid_alu_instr, r0_writing, bad_opcode;
  assign bad_func_code     = Instr_from_imem[0:5] == 6'b101010 && (Instr_from_imem[26:31] > 18 || Instr_from_imem[26:31] == 0);
  assign invalid_alu_instr = Instr_from_imem[0:5] == 6'b101010 &&
                             (Instr_from_imem[26:31] == 8 || Instr_from_imem[26:31] == 9 || Instr_from_imem[26:31] == 16 || Instr_from_imem[26:31] == 17) &&
                             Instr_from_imem[24:25] == 2'b11;
  assign r0_writing        = (Instr_from_imem[0:5] == 6'b101010 || Instr_from_imem[0:5] == 6'b100000) && Instr_from_imem[6:10] == 0;
  
  assign bad_opcode        = Instr_from_imem[0:5] != 6'b101010 &&
                             Instr_from_imem[0:5] != 6'b100000 &&
                             Instr_from_imem[0:5] != 6'b100001 &&
                             Instr_from_imem[0:5] != 6'b100010 &&
                             Instr_from_imem[0:5] != 6'b100011;

  // Flush to NOP when needed
  assign instr_ifid_in = (br_taken || bad_func_code || invalid_alu_instr || r0_writing || bad_opcode)
                         ? {6'b111100, Instr_from_imem[6:31]}
                         : Instr_from_imem;

  // =========================
  // ID Stage
  // =========================
  assign rsA = ifid_q[11:15];
  assign rsB = ifid_q[16:20];
  assign rdW = ifid_q[6:10];

  assign is_branch = (ifid_q[0:5] == 6'b100010 || ifid_q[0:5] == 6'b100011);
  assign is_rdtype = ~ifid_q[2];

  assign rf_addr1 = (is_rdtype) ? rdW : rsA;
  assign rf_addr2 = rsB;

  RegisterFile RF(
    .clk(clk), .reset(reset),
    .wrEn(wb_regwen), .wrAddr(wb_waddr), .wrData(stage3_EXMEM_WB_out[9:72]),
    .rdAddr1(rf_addr1), .rdData1(rf_data1),
    .rdAddr2(rf_addr2), .rdData2(rf_data2),
    .PPP(wb_ppp)
  );

  assign br_taken = (is_branch) &&
                    ((src1_merged == 0 && ifid_q[5] == 0) || (src1_merged != 0 && ifid_q[5] == 1));

  // =========================
  // Hazard Detection Unit
  // =========================
  wire Haz_from_EX_to_SR1_B0, Haz_from_EX_to_SR1_B1, Haz_from_EX_to_SR1_B2, Haz_from_EX_to_SR1_B3, Haz_from_EX_to_SR1_B4, Haz_from_EX_to_SR1_B5, Haz_from_EX_to_SR1_B6, Haz_from_EX_to_SR1_B7;
  wire Haz_from_EX_to_SR2_B0, Haz_from_EX_to_SR2_B1, Haz_from_EX_to_SR2_B2, Haz_from_EX_to_SR2_B3, Haz_from_EX_to_SR2_B4, Haz_from_EX_to_SR2_B5, Haz_from_EX_to_SR2_B6, Haz_from_EX_to_SR2_B7;
  wire Haz_from_WB_to_SR1_B0, Haz_from_WB_to_SR1_B1, Haz_from_WB_to_SR1_B2, Haz_from_WB_to_SR1_B3, Haz_from_WB_to_SR1_B4, Haz_from_WB_to_SR1_B5, Haz_from_WB_to_SR1_B6, Haz_from_WB_to_SR1_B7;
  wire Haz_from_WB_to_SR2_B0, Haz_from_WB_to_SR2_B1, Haz_from_WB_to_SR2_B2, Haz_from_WB_to_SR2_B3, Haz_from_WB_to_SR2_B4, Haz_from_WB_to_SR2_B5, Haz_from_WB_to_SR2_B6, Haz_from_WB_to_SR2_B7;

  HDU HDU_1(
    .Dest_EX_Stage(stage2_ID_EXMEM_out[6:10]),
    .Dest_WB_Stage(stage3_EXMEM_WB_out[1:5]),
    .SR1_ID_Stage(rf_addr1),
    .SR2_ID_Stage(rf_addr2),
    .Write_Intent_EX(stage2_ID_EXMEM_out[0:5] == 6'b101010 || stage2_ID_EXMEM_out[0:5] == 6'b100000),
    .Write_Intent_WB(stage3_EXMEM_WB_out[0]),
    .read_Intent(~(ifid_q[0:5] == 6'b100000 || ifid_q[0:5] == 6'b111100)),
    .PPP_EX(stage2_ID_EXMEM_out[21:23]),
    .PPP_WB(wb_ppp),
    .Haz_from_EX_to_SR1_B0(Haz_from_EX_to_SR1_B0), .Haz_from_EX_to_SR1_B1(Haz_from_EX_to_SR1_B1), .Haz_from_EX_to_SR1_B2(Haz_from_EX_to_SR1_B2), .Haz_from_EX_to_SR1_B3(Haz_from_EX_to_SR1_B3),
    .Haz_from_EX_to_SR1_B4(Haz_from_EX_to_SR1_B4), .Haz_from_EX_to_SR1_B5(Haz_from_EX_to_SR1_B5), .Haz_from_EX_to_SR1_B6(Haz_from_EX_to_SR1_B6), .Haz_from_EX_to_SR1_B7(Haz_from_EX_to_SR1_B7),
    .Haz_from_EX_to_SR2_B0(Haz_from_EX_to_SR2_B0), .Haz_from_EX_to_SR2_B1(Haz_from_EX_to_SR2_B1), .Haz_from_EX_to_SR2_B2(Haz_from_EX_to_SR2_B2), .Haz_from_EX_to_SR2_B3(Haz_from_EX_to_SR2_B3),
    .Haz_from_EX_to_SR2_B4(Haz_from_EX_to_SR2_B4), .Haz_from_EX_to_SR2_B5(Haz_from_EX_to_SR2_B5), .Haz_from_EX_to_SR2_B6(Haz_from_EX_to_SR2_B6), .Haz_from_EX_to_SR2_B7(Haz_from_EX_to_SR2_B7),
    .Haz_from_WB_to_SR1_B0(Haz_from_WB_to_SR1_B0), .Haz_from_WB_to_SR1_B1(Haz_from_WB_to_SR1_B1), .Haz_from_WB_to_SR1_B2(Haz_from_WB_to_SR1_B2), .Haz_from_WB_to_SR1_B3(Haz_from_WB_to_SR1_B3),
    .Haz_from_WB_to_SR1_B4(Haz_from_WB_to_SR1_B4), .Haz_from_WB_to_SR1_B5(Haz_from_WB_to_SR1_B5), .Haz_from_WB_to_SR1_B6(Haz_from_WB_to_SR1_B6), .Haz_from_WB_to_SR1_B7(Haz_from_WB_to_SR1_B7),
    .Haz_from_WB_to_SR2_B0(Haz_from_WB_to_SR2_B0), .Haz_from_WB_to_SR2_B1(Haz_from_WB_to_SR2_B1), .Haz_from_WB_to_SR2_B2(Haz_from_WB_to_SR2_B2), .Haz_from_WB_to_SR2_B3(Haz_from_WB_to_SR2_B3),
    .Haz_from_WB_to_SR2_B4(Haz_from_WB_to_SR2_B4), .Haz_from_WB_to_SR2_B5(Haz_from_WB_to_SR2_B5), .Haz_from_WB_to_SR2_B6(Haz_from_WB_to_SR2_B6), .Haz_from_WB_to_SR2_B7(Haz_from_WB_to_SR2_B7)
  );

  // Byte-lane mapping:
  // B0 0:7, B1 8:15, B2 16:23, B3 24:31, B4 32:39, B5 40:47, B6 48:55, B7 56:63

  assign fwd_ex = data_to_stage3;
  assign fwd_wb = stage3_EXMEM_WB_out[9:72];

  assign instr_to_idex = ifid_q[0:31];

  // Source 1 muxing (per byte)
  assign src1_B0 = Haz_from_EX_to_SR1_B0 ? fwd_ex[0:7]   : (Haz_from_WB_to_SR1_B0 ? fwd_wb[0:7]   : rf_data1[0:7]);
  assign src1_B1 = Haz_from_EX_to_SR1_B1 ? fwd_ex[8:15]  : (Haz_from_WB_to_SR1_B1 ? fwd_wb[8:15]  : rf_data1[8:15]);
  assign src1_B2 = Haz_from_EX_to_SR1_B2 ? fwd_ex[16:23] : (Haz_from_WB_to_SR1_B2 ? fwd_wb[16:23] : rf_data1[16:23]);
  assign src1_B3 = Haz_from_EX_to_SR1_B3 ? fwd_ex[24:31] : (Haz_from_WB_to_SR1_B3 ? fwd_wb[24:31] : rf_data1[24:31]);
  assign src1_B4 = Haz_from_EX_to_SR1_B4 ? fwd_ex[32:39] : (Haz_from_WB_to_SR1_B4 ? fwd_wb[32:39] : rf_data1[32:39]);
  assign src1_B5 = Haz_from_EX_to_SR1_B5 ? fwd_ex[40:47] : (Haz_from_WB_to_SR1_B5 ? fwd_wb[40:47] : rf_data1[40:47]);
  assign src1_B6 = Haz_from_EX_to_SR1_B6 ? fwd_ex[48:55] : (Haz_from_WB_to_SR1_B6 ? fwd_wb[48:55] : rf_data1[48:55]);
  assign src1_B7 = Haz_from_EX_to_SR1_B7 ? fwd_ex[56:63] : (Haz_from_WB_to_SR1_B7 ? fwd_wb[56:63] : rf_data1[56:63]);
  assign src1_merged = {src1_B0, src1_B1, src1_B2, src1_B3, src1_B4, src1_B5, src1_B6, src1_B7};

  // Source 2 muxing (per byte)
  assign src2_B0 = Haz_from_EX_to_SR2_B0 ? fwd_ex[0:7]   : (Haz_from_WB_to_SR2_B0 ? fwd_wb[0:7]   : rf_data2[0:7]);
  assign src2_B1 = Haz_from_EX_to_SR2_B1 ? fwd_ex[8:15]  : (Haz_from_WB_to_SR2_B1 ? fwd_wb[8:15]  : rf_data2[8:15]);
  assign src2_B2 = Haz_from_EX_to_SR2_B2 ? fwd_ex[16:23] : (Haz_from_WB_to_SR2_B2 ? fwd_wb[16:23] : rf_data2[16:23]);
  assign src2_B3 = Haz_from_EX_to_SR2_B3 ? fwd_ex[24:31] : (Haz_from_WB_to_SR2_B3 ? fwd_wb[24:31] : rf_data2[24:31]);
  assign src2_B4 = Haz_from_EX_to_SR2_B4 ? fwd_ex[32:39] : (Haz_from_WB_to_SR2_B4 ? fwd_wb[32:39] : rf_data2[32:39]);
  assign src2_B5 = Haz_from_EX_to_SR2_B5 ? fwd_ex[40:47] : (Haz_from_WB_to_SR2_B5 ? fwd_wb[40:47] : rf_data2[40:47]);
  assign src2_B6 = Haz_from_EX_to_SR2_B6 ? fwd_ex[48:55] : (Haz_from_WB_to_SR2_B6 ? fwd_wb[48:55] : rf_data2[48:55]);
  assign src2_B7 = Haz_from_EX_to_SR2_B7 ? fwd_ex[56:63] : (Haz_from_WB_to_SR2_B7 ? fwd_wb[56:63] : rf_data2[56:63]);
  assign src2_merged = {src2_B0, src2_B1, src2_B2, src2_B3, src2_B4, src2_B5, src2_B6, src2_B7};

  // =========================
  // EX Stage
  // =========================
  wire [0:2] count_out;
  counter cntr(.clk(~clk), .reset(reset), .start(memEn_to_dmem), .number_cycles(3'b000), .count(count_out));
  assign stall = count_out != 0;

  assign addr_nic  = stage2_ID_EXMEM_out[30:31];
  assign din_to_nic = stage2_ID_EXMEM_out[32:95];
  assign nicEn    = (stage2_ID_EXMEM_out[16:17] == 2'b11) && (stage2_ID_EXMEM_out[0:5] == 6'b100000 || stage2_ID_EXMEM_out[0:5] == 6'b100001);
  assign nicWrEn  =  stage2_ID_EXMEM_out[0:5] == 6'b100001 && stage2_ID_EXMEM_out[16:17] == 2'b11;

  assign ALU_en = (stage2_ID_EXMEM_out[0:5] == 6'b101010) && stage2_ID_EXMEM_out[26:31] <= 18;

  ALU ALU_DUT1(
    .function_code(stage2_ID_EXMEM_out[26:31]),
    .dataA_ALU_in(stage2_ID_EXMEM_out[32:95]),
    .dataB_ALU_in(stage2_ID_EXMEM_out[96:159]),
    .data_ALU_out(ALU_data_out),
    .ww(stage2_ID_EXMEM_out[24:25])
  );

  assign memEn_to_dmem  = (stage2_ID_EXMEM_out[0:5] == 6'b100000 || stage2_ID_EXMEM_out[0:5] == 6'b100001) && (stage2_ID_EXMEM_out[16:17] != 2'b11);
  assign memWrEn_to_dmem = stage2_ID_EXMEM_out[0:5] == 6'b100001 && stage2_ID_EXMEM_out[16:17] != 2'b11;
  assign memAddr_to_dmem = {16'b0, stage2_ID_EXMEM_out[16:31]};
  assign data_to_dmem    = stage2_ID_EXMEM_out[32:95];

  wire [0:63] nic_or_dmem_dout;
  assign nic_or_dmem_dout = stage2_ID_EXMEM_out[16:17] == 2'b11 ? dout_from_nic : data_from_dmem;
  assign data_to_stage3   = stage2_ID_EXMEM_out[0:5] == 6'b100000 ? nic_or_dmem_dout : ALU_data_out;

  // =========================
  // WB Stage
  // =========================
  assign wb_regwen = stage3_EXMEM_WB_out[0] && ~stall;
  assign wb_waddr  = stage3_EXMEM_WB_out[1:5];
  assign wb_ppp    = stage3_EXMEM_WB_out[6:8];

endmodule
