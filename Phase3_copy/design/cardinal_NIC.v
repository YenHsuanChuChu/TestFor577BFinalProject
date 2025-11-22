module NIC(input [63:0] d_in, input nicEn, input nicWrEn, input clk, input reset, output reg [63:0] net_do, input net_ro, output net_so, input net_polarity, output reg  [63:0] d_out, input [1:0] addr, input [63:0] net_di, input net_si, output net_ri);
  
  // Output channel buffer --> 
  // outputs: net_do, net_so, out_status, d_out
  // inputs: d_in, net_polarity, nicEness, nicWrEn, clk, reset
  // misc: out_status
  
  reg out_status;
  wire out_buff_en;
  wire polarity_vc_match;
  
  assign out_buff_en = ( (nicEn && nicWrEn) && ( (out_status == 0) || net_so) && (addr == 2'b10) );
  assign polarity_vc_match = (net_do[63] != net_polarity);
  assign net_so = (out_status && net_ro) && (polarity_vc_match);
  
  
  // for net_do
  always@(posedge clk) begin
    if(reset) net_do <= 0;
    // latch d_in if processor wants to write and (status is currently 0 or the data is going to be read out by the network router)
	else if (out_buff_en) net_do <= d_in;
	else net_do <= net_do;
  end
          
  
  // for out_status
  always@(posedge clk) begin
    if(reset) begin
		out_status <= 0;
    end
    else begin
		// status 1 if processor wants to write and either I have empty buffer or the buffer is going to be read out by the router
		if (out_buff_en) out_status <= 1;
		// status is 0 if buffer is going to be read out and nothing is going to be written in
		else if (net_so && (~out_buff_en)) out_status <= 0;
		else out_status <= out_status;
    end
  end   
  
  reg [63:0] input_channel_buf_out;
  reg in_status;
  
  always@(*) begin
    case (addr)
      2'b00: begin
        d_out = input_channel_buf_out;
      end
      2'b01: begin
        d_out = {63'b0, in_status};
      end
      2'b11: begin
        d_out = {63'b0, out_status};
      end
      default: begin
        d_out = {4'b0,1'b1,59'b0};
      end
    endcase
  end
  
  // input channel buffer --> 
  // outputs: d_out
  // inputs: net_si, net_di, nicEn, nicWrEn, clk, reset
  // misc: in_status
  
  assign net_ri = ~in_status;
  
  always@(posedge clk) begin
    if(reset) input_channel_buf_out <= 0;
    else if(net_si) input_channel_buf_out <= net_di;
	else input_channel_buf_out <= input_channel_buf_out;
  end
  
  always @(posedge clk) begin
    if(reset) in_status <= 0;
    else begin
      if (net_si) in_status <= 1;
      else if ((nicEn && (~nicWrEn)) && (addr == 2'b00)) in_status <= 0;
    end
  end
  
endmodule