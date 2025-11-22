// Code your design here
// Code your testbench here
// or browse Examples

//NOTES
//moore for input controller
//mealey for output controller
//2 cycle latency

`timescale 1ns/1ns
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
    if(reset) begin // reset
      net_do <= 0;
    end
    else begin
      // latch d_in if processor wants to write and (status is currently 0 or the data is going to be read out by the network router)
      if (out_buff_en) begin
        net_do <= d_in;
      end     
    end 
  end
          
  
  // for out_status
  always@(posedge clk) begin
    if(reset) begin
      out_status <= 0;
    end
    else begin
      // status 1 if processor wants to write and either I have empty buffer or the buffer is going to be read out by the router
      if (out_buff_en) begin
        out_status <= 1;
      end
      // status is 0 if buffer is going to be read out and nothing is going to be written in
      else if (net_so && (~out_buff_en)) begin
        out_status <= 0;
      end
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
    if(reset) begin
      input_channel_buf_out <= 0;
    end
    else begin
      if(net_si) begin
        input_channel_buf_out <= net_di;
      end
    end
  end
  
  always @(posedge clk) begin
    if(reset) begin
      in_status <= 0;
    end
    else begin
      if (net_si) begin
        in_status <= 1;
      end
      else if ((nicEn && (~nicWrEn)) && (addr == 2'b00)) begin
        in_status <= 0;
      end
    end
  end
  
endmodule


module Buffer(   
  input clk, reset,
  input [63:0] data_in,          // Input data to the buffer
  input valid_in,                // Input valid signal indicating data is ready at `data_in`
  input ready_in,                // Ready signal from the next module
  input allowed,                 // Control signal indicating if data transfer is allowed
  output reg [63:0] data_out,    // Buffered data output
  output reg valid_out,          // Output valid signal (should be a register)
  output valid_out2,             // Auxiliary valid signal, indicating data is ready and accepted
  output ready_out               // Ready signal indicating buffer can accept new data
);

  // Enable signal for data transfer
  wire en;
  
  // `ready_out` follows standard handshaking: high if buffer is empty or ready to accept data
  assign ready_out = (~valid_out | ready_in);
  
  // Enable signal `en` is controlled by `ready_out` and is used with `allowed` inside the clocked block
  assign en = ready_out;
  
  // `valid_out2` is high only when `valid_out` and `ready_in` are both asserted
  assign valid_out2 = valid_out && ready_in;
  
  // Clock-driven behavior for buffering data and handling `valid_out`
  always @(posedge clk) begin
    if (reset) begin
      data_out <= 0;
      valid_out <= 0;
    end  
    else begin
      if (en && allowed) begin        // On enable and allowed, update buffer with input data
        data_out  <= data_in;
        valid_out <= valid_in;
      end
      else if (ready_in == 0) begin   // If not ready, retain current buffer values
        valid_out <= valid_out;
        data_out <= data_out;
      end
      else begin                      // Clear buffer and valid flag if ready and not allowed
        valid_out <= 0;
        data_out <= 0;
      end  
    end    
  end
endmodule

module Router_Logic(//Note: check the negative value logic
  input signed [3:0] X_hop, Y_hop,
  input valid_in_router,
  output reg CB_to_NOB_valid, CB_to_SOB_valid, CB_to_WOB_valid, CB_to_EOB_valid, CB_to_PEOB_valid
);

	always@(*)
	begin
		CB_to_NOB_valid=0;
		CB_to_SOB_valid=0;
		CB_to_WOB_valid=0;
		CB_to_EOB_valid=0;
		CB_to_PEOB_valid=0;
		
		if(valid_in_router)
		begin
		  // Tejas: why couldn't be if, else if? And, what about the routers on the corners or edges. Packet will fall off the cliff?
			if(X_hop>0)               CB_to_EOB_valid =1; 
			if(X_hop<0)               CB_to_WOB_valid =1; 
			if( X_hop==0 && Y_hop>0)  CB_to_NOB_valid =1; 
			if( X_hop==0 && Y_hop<0)  CB_to_SOB_valid =1; 
			if( X_hop==0 && Y_hop==0) CB_to_PEOB_valid =1; 
		end   
	end
endmodule

module input_controller( 
  input clk, reset,
  input polarity,
  input IB_si,                           // Input valid signal
  input [63:0] IB_di,                    // Input data
  output IB_ri,                          // Ready signal to input buffer

  // Output data and control signals to Output Buffers (OBs)
  output [63:0] IC_data_out,
  input OB0_to_IB_ready, OB1_to_IB_ready, OB2_to_IB_ready, OB3_to_IB_ready,
  output IB_to_NOB_valid, IB_to_SOB_valid, IB_to_WOB_valid, IB_to_EOB_valid, IB_to_PEOB_valid,
  output IB_to_NOB_valid_int, IB_to_SOB_valid_int, IB_to_WOB_valid_int, IB_to_EOB_valid_int, IB_to_PEOB_valid_int
);

  // Internal data wires and control signals
  wire [63:0] IB_data_out;
  wire IB_ready_in, IB_ready_out;
  reg signed [3:0] X_hop, Y_hop;
  reg signed [3:0] X_hop_new, Y_hop_new;

  wire IB_valid_in, IB_valid_out, IB_valid_out2;
  wire IB_di_VC, IB_data_out_VC;
  wire allowed_ext, allowed_int;
  wire router_valid_in;

  // Valid signal assigned from input buffer signal `IB_si`
  assign IB_valid_in = IB_si;

  // Ready signal assigned based on all OB ready signals
  assign IB_ready_in = OB0_to_IB_ready && OB1_to_IB_ready && OB2_to_IB_ready && OB3_to_IB_ready;

  // Virtual Channel (VC) bit check for external allowance
  assign IB_di_VC = IB_di[63];
  assign allowed_ext = IB_di_VC ^ polarity; // Allow external only if VC bit and polarity differ

  // Instantiate Buffer to hold incoming data
  Buffer i_buf (
    .clk(clk), .reset(reset), .data_in(IB_di), .valid_in(IB_valid_in),
    .ready_in(IB_ready_in), .allowed(allowed_ext),
    .data_out(IB_data_out), .valid_out(IB_valid_out),
    .valid_out2(IB_valid_out2), .ready_out(IB_ready_out)
  );

  // Internal allowance check based on VC bit and polarity
  assign IB_data_out_VC = IB_data_out[63];
  assign allowed_int = IB_data_out_VC ~^ polarity;

  // Ready signal output
  assign IB_ri = IB_ready_out && allowed_ext;

  // Router Logic determines direction based on X and Y hops
  assign router_valid_in = IB_valid_out;
  Router_Logic RL(
    .X_hop(X_hop), .Y_hop(Y_hop), .valid_in_router(router_valid_in),
    .CB_to_NOB_valid(IB_to_NOB_valid_int), .CB_to_SOB_valid(IB_to_SOB_valid_int),
    .CB_to_WOB_valid(IB_to_WOB_valid_int), .CB_to_EOB_valid(IB_to_EOB_valid_int),
    .CB_to_PEOB_valid(IB_to_PEOB_valid_int)
  );

  assign IB_to_NOB_valid = IB_to_NOB_valid_int && allowed_int;
  assign IB_to_SOB_valid = IB_to_SOB_valid_int && allowed_int;
  assign IB_to_WOB_valid = IB_to_WOB_valid_int && allowed_int;
  assign IB_to_EOB_valid = IB_to_EOB_valid_int && allowed_int;
  assign IB_to_PEOB_valid = IB_to_PEOB_valid_int && allowed_int;

  // Output data assignment with updated hops
  assign IC_data_out = {IB_data_out[63:56], X_hop_new, Y_hop_new, IB_data_out[47:0]};

  // Hop count update logic
  always @(*) begin  
    X_hop =  IB_data_out[55:52]; 
    Y_hop =  IB_data_out[51:48]; 
    X_hop_new = X_hop;
    Y_hop_new = Y_hop;

    if (X_hop > 0)         X_hop_new = X_hop - 1;
    if (X_hop < 0)         X_hop_new = X_hop + 1;
    if (X_hop == 0 && Y_hop > 0) Y_hop_new = Y_hop - 1;
    if (X_hop == 0 && Y_hop < 0) Y_hop_new = Y_hop + 1;
  end      
endmodule

module Arbiter( // ROUND ROBIN ARBITER  
  input clk, reset,
  input req_in0, req_in1, req_in2, req_in3,   // Request signals from input buffers
  input [63:0] data_in0, data_in1, data_in2, data_in3, // Data inputs from input buffers
  output reg [3:0] grant_out,                 // Output grant indicating selected input
  output reg [63:0] arb_data_out              // Data output from granted input
);

  reg [3:0] grant_2, grant; // Stores previous grant and current grant
  wire [3:0] combined_req;
  
  // Combine request signals into a single wire
  assign combined_req = {req_in3, req_in2, req_in1, req_in0};

  // Update `grant_2` based on current grants and reset conditions
  always @(posedge clk) begin
    if (reset) begin
      grant_2 <= 0;
    end
    else if (|combined_req) begin
      grant_2 <= grant;
    end      
  end

  // Determine next grant based on `grant_2` (previous grant)
  always @(*) begin
    grant = 0;
    if (grant_2 == 4'b1000) begin
      casex(combined_req)
        4'b1000: grant = 4'b1000;
        4'bX1XX: grant = 4'b0100;
        4'bX01X: grant = 4'b0010;
        4'bX001: grant = 4'b0001;
      endcase
    end
    else if (grant_2 == 4'b0100) begin
      casex(combined_req)
        4'b1X00: grant = 4'b1000;
        4'b0100: grant = 4'b0100;
        4'bXX1X: grant = 4'b0010;
        4'bXX01: grant = 4'b0001;
      endcase
    end
    else if (grant_2 == 4'b0010) begin
      casex(combined_req)
        4'b1XX0: grant = 4'b1000;
        4'b01X0: grant = 4'b0100;
        4'b0010: grant = 4'b0010;
        4'bXXX1: grant = 4'b0001;
      endcase
    end
    else if (grant_2 == 4'b0001 || grant_2 == 4'b0000) begin
      casex(combined_req)
        4'b1XXX: grant = 4'b1000;
        4'b01XX: grant = 4'b0100;
        4'b001X: grant = 4'b0010;
        4'b0001: grant = 4'b0001;
      endcase
    end

    // Select output data based on granted request
    case (grant & combined_req)
      4'b1000: arb_data_out = data_in3;
      4'b0100: arb_data_out = data_in2;
      4'b0010: arb_data_out = data_in1;
      4'b0001: arb_data_out = data_in0;
      default: arb_data_out = 0; // Default if no request is active
    endcase

    // Assign grant output based on active request
    grant_out = grant & combined_req;
  end
endmodule

module output_controller (
  input clk, reset,
  input polarity,
  output OB_so,                      // Output valid signal
  output [63:0] OB_do,               // Data output from output buffer
  input OB_ro,                       // Ready signal from output buffer
  input IB0_to_OB_valid, IB1_to_OB_valid, IB2_to_OB_valid, IB3_to_OB_valid, // Valid inputs from input buffers
    input IB0_to_OB_valid_int, IB1_to_OB_valid_int, IB2_to_OB_valid_int, IB3_to_OB_valid_int, // Valid inputs from input buffers

  input [63:0] IB0_data_out, IB1_data_out, IB2_data_out, IB3_data_out,       // Data inputs from input buffers
  output OB_to_IB0_ready, OB_to_IB1_ready, OB_to_IB2_ready, OB_to_IB3_ready  // Ready outputs to input buffers
);

  wire OB_ready_out2;
  wire OB_valid_in, OB_valid_out_unused, OB_valid_out;
  wire OB_ready_out;
  wire [63:0] OB_data_in;
  wire [3:0] grant_out;
  wire [63:0] arb_data_out;
  wire OB_do_VC, allowed_ext2, OB_ready_in;
  wire allowed_int_oc;

  // Instantiate Arbiter to select input data based on requests
  Arbiter A1 (
    .clk(clk), .reset(reset),
    .req_in0(IB0_to_OB_valid), .req_in1(IB1_to_OB_valid), 
    .req_in2(IB2_to_OB_valid), .req_in3(IB3_to_OB_valid),
    .data_in0(IB0_data_out), .data_in1(IB1_data_out),
    .data_in2(IB2_data_out), .data_in3(IB3_data_out),
    .grant_out(grant_out), .arb_data_out(arb_data_out)
  );

  // Allow internal operation if VC bit and polarity are equal
  assign allowed_int_oc = OB_data_in[63] ~^ polarity;

  // Instantiate output buffer
  Buffer out_buf (
    .clk(clk), .reset(reset),
    .data_in(OB_data_in), .valid_in(OB_valid_in),
    .ready_in(OB_ready_in), .allowed(allowed_int_oc),
    .data_out(OB_do), .valid_out(OB_valid_out_unused),
    .valid_out2(OB_valid_out), .ready_out(OB_ready_out)
  );

  // Assign arbiter output to buffer input
  assign OB_data_in = arb_data_out;

  // Set `OB_valid_in` high if any request is active
  assign OB_valid_in = |grant_out;

  // Set output valid signal based on buffer output
  assign OB_so = OB_valid_out;

  // Check VC bit for external allowance
  assign OB_do_VC = OB_do[63];
  assign allowed_ext2 = OB_do_VC ^ polarity; // Allow if VC bit and polarity differ

  // Set buffer ready signal based on `OB_ro` and external allowance
  assign OB_ready_in = OB_ro && allowed_ext2;

  // Internal ready signal with allowance check
  assign OB_ready_out2 = OB_ready_out && allowed_int_oc;

  // Generate ready signals for each input buffer based on arbiter grant and `OB_ready_out2`
   assign OB_to_IB0_ready = ((OB_ready_out2 & grant_out[0]) | (~IB0_to_OB_valid_int));
  assign OB_to_IB1_ready = ((OB_ready_out2 & grant_out[1]) | (~IB1_to_OB_valid_int));
  assign OB_to_IB2_ready = ((OB_ready_out2 & grant_out[2]) | (~IB2_to_OB_valid_int));
  assign OB_to_IB3_ready = ((OB_ready_out2 & grant_out[3]) | (~IB3_to_OB_valid_int));
  
endmodule

module Node(
	input clk, reset, polarity,

	input NIB_si, SIB_si, WIB_si, EIB_si, PEIB_si,
	input [63:0] NIB_di, SIB_di, WIB_di, EIB_di, PEIB_di,
	output NIB_ri, SIB_ri, WIB_ri, EIB_ri, PEIB_ri,

	output NOB_so, SOB_so, WOB_so, EOB_so, PEOB_so,
	output [63:0] NOB_do, SOB_do, WOB_do, EOB_do, PEOB_do,
	input  NOB_ro, SOB_ro, WOB_ro, EOB_ro, PEOB_ro,
	output polarity_to_NIC // Tejas: polarity
); // Tejas:

	assign polarity_to_NIC = polarity; // Tejas: polarity
	wire [63:0] NIB_data_out, SIB_data_out, WIB_data_out, EIB_data_out, PEIB_data_out;

	wire SOB_to_NIB_ready, WOB_to_NIB_ready, EOB_to_NIB_ready, PEOB_to_NIB_ready,
		 NIB_to_NOB_valid, NIB_to_SOB_valid, NIB_to_WOB_valid, NIB_to_EOB_valid, NIB_to_PEOB_valid;

	wire  NIB_to_NOB_valid_int, NIB_to_SOB_valid_int, NIB_to_WOB_valid_int, NIB_to_EOB_valid_int, NIB_to_PEOB_valid_int;


	wire NOB_to_SIB_ready, WOB_to_SIB_ready, EOB_to_SIB_ready, PEOB_to_SIB_ready, 
		 SIB_to_NOB_valid, SIB_to_SOB_valid, SIB_to_WOB_valid, SIB_to_EOB_valid, SIB_to_PEOB_valid;

	 wire SIB_to_NOB_valid_int, SIB_to_SOB_valid_int, SIB_to_WOB_valid_int, SIB_to_EOB_valid_int, SIB_to_PEOB_valid_int;


	wire  NOB_to_WIB_ready, SOB_to_WIB_ready, EOB_to_WIB_ready, PEOB_to_WIB_ready, 
		  WIB_to_NOB_valid, WIB_to_SOB_valid, WIB_to_WOB_valid, WIB_to_EOB_valid, WIB_to_PEOB_valid ;

	  wire    WIB_to_NOB_valid_int, WIB_to_SOB_valid_int, WIB_to_WOB_valid_int, WIB_to_EOB_valid_int, WIB_to_PEOB_valid_int ;
		

	wire  NOB_to_EIB_ready, SOB_to_EIB_ready, WOB_to_EIB_ready, PEOB_to_EIB_ready, 
		  EIB_to_NOB_valid, EIB_to_SOB_valid, EIB_to_WOB_valid, EIB_to_EOB_valid, EIB_to_PEOB_valid ;

	  wire    EIB_to_NOB_valid_int, EIB_to_SOB_valid_int, EIB_to_WOB_valid_int, EIB_to_EOB_valid_int, EIB_to_PEOB_valid_int ;


	wire  NOB_to_PEIB_ready, SOB_to_PEIB_ready, WOB_to_PEIB_ready, EOB_to_PEIB_ready, 
		  PEIB_to_NOB_valid, PEIB_to_SOB_valid, PEIB_to_WOB_valid, PEIB_to_EOB_valid, PEIB_to_PEOB_valid; 

	wire   PEIB_to_NOB_valid_int, PEIB_to_SOB_valid_int, PEIB_to_WOB_valid_int, PEIB_to_EOB_valid_int, PEIB_to_PEOB_valid_int; 



	input_controller North_IC (clk, reset, polarity, NIB_si, NIB_di, NIB_ri,
	 NIB_data_out, SOB_to_NIB_ready, WOB_to_NIB_ready, EOB_to_NIB_ready, PEOB_to_NIB_ready, 
	 NIB_to_NOB_valid,NIB_to_SOB_valid, NIB_to_WOB_valid, NIB_to_EOB_valid, NIB_to_PEOB_valid,
	 NIB_to_NOB_valid_int, NIB_to_SOB_valid_int, NIB_to_WOB_valid_int, NIB_to_EOB_valid_int, NIB_to_PEOB_valid_int); 

	input_controller South_IC (clk, reset, polarity, SIB_si, SIB_di, SIB_ri,
	 SIB_data_out, NOB_to_SIB_ready, WOB_to_SIB_ready, EOB_to_SIB_ready, PEOB_to_SIB_ready, 
	 SIB_to_NOB_valid, SIB_to_SOB_valid,SIB_to_WOB_valid, SIB_to_EOB_valid, SIB_to_PEOB_valid,
	 SIB_to_NOB_valid_int, SIB_to_SOB_valid_int, SIB_to_WOB_valid_int, SIB_to_EOB_valid_int, SIB_to_PEOB_valid_int); 

	input_controller West_IC (clk, reset, polarity, WIB_si, WIB_di, WIB_ri,
	 WIB_data_out, NOB_to_WIB_ready, SOB_to_WIB_ready, EOB_to_WIB_ready, PEOB_to_WIB_ready, 
	 WIB_to_NOB_valid, WIB_to_SOB_valid, WIB_to_WOB_valid, WIB_to_EOB_valid, WIB_to_PEOB_valid,
	 WIB_to_NOB_valid_int, WIB_to_SOB_valid_int, WIB_to_WOB_valid_int, WIB_to_EOB_valid_int, WIB_to_PEOB_valid_int); 

	input_controller East_IC (clk, reset, polarity, EIB_si, EIB_di, EIB_ri,
	 EIB_data_out, NOB_to_EIB_ready, SOB_to_EIB_ready, WOB_to_EIB_ready, PEOB_to_EIB_ready, 
	 EIB_to_NOB_valid, EIB_to_SOB_valid, EIB_to_WOB_valid, EIB_to_EOB_valid, EIB_to_PEOB_valid,
	 EIB_to_NOB_valid_int, EIB_to_SOB_valid_int, EIB_to_WOB_valid_int, EIB_to_EOB_valid_int, EIB_to_PEOB_valid_int); 

	 input_controller PE_IC (clk, reset, polarity, PEIB_si, PEIB_di, PEIB_ri,
	 PEIB_data_out, NOB_to_PEIB_ready, SOB_to_PEIB_ready, WOB_to_PEIB_ready, EOB_to_PEIB_ready, 
	 PEIB_to_NOB_valid, PEIB_to_SOB_valid, PEIB_to_WOB_valid, PEIB_to_EOB_valid,PEIB_to_PEOB_valid,
	 PEIB_to_NOB_valid_int, PEIB_to_SOB_valid_int, PEIB_to_WOB_valid_int, PEIB_to_EOB_valid_int, PEIB_to_PEOB_valid_int); 


	 output_controller North_OC (   clk,  reset, polarity,  NOB_so, NOB_do,   NOB_ro,  
	   SIB_to_NOB_valid,  WIB_to_NOB_valid, EIB_to_NOB_valid ,  PEIB_to_NOB_valid, 
	   SIB_to_NOB_valid_int,  WIB_to_NOB_valid_int, EIB_to_NOB_valid_int ,  PEIB_to_NOB_valid_int, 
	   SIB_data_out,  WIB_data_out,  EIB_data_out,  PEIB_data_out, 
	   NOB_to_SIB_ready,  NOB_to_WIB_ready,  NOB_to_EIB_ready,  NOB_to_PEIB_ready);

	 output_controller South_OC (   clk,  reset,  polarity,  SOB_so, SOB_do,   SOB_ro, 
	   NIB_to_SOB_valid,  WIB_to_SOB_valid, EIB_to_SOB_valid ,  PEIB_to_SOB_valid, 
		  NIB_to_SOB_valid_int,  WIB_to_SOB_valid_int, EIB_to_SOB_valid_int ,  PEIB_to_SOB_valid_int, 
	   NIB_data_out,  WIB_data_out,  EIB_data_out,  PEIB_data_out, 
	   SOB_to_NIB_ready,  SOB_to_WIB_ready,  SOB_to_EIB_ready,  SOB_to_PEIB_ready);

	 output_controller West_OC (   clk,  reset,  polarity, WOB_so, WOB_do,  WOB_ro,  
	   NIB_to_WOB_valid, SIB_to_WOB_valid,  EIB_to_WOB_valid ,  PEIB_to_WOB_valid, 
	   NIB_to_WOB_valid_int, SIB_to_WOB_valid_int,  EIB_to_WOB_valid_int ,  PEIB_to_WOB_valid_int, 
	   NIB_data_out, SIB_data_out,  EIB_data_out,  PEIB_data_out, 
	   WOB_to_NIB_ready, WOB_to_SIB_ready, WOB_to_EIB_ready,  WOB_to_PEIB_ready);

	 output_controller East_OC (   clk,  reset, polarity,  EOB_so, EOB_do,   EOB_ro,  
	   NIB_to_EOB_valid, SIB_to_EOB_valid,  WIB_to_EOB_valid,  PEIB_to_EOB_valid, 
		  NIB_to_EOB_valid_int, SIB_to_EOB_valid_int,  WIB_to_EOB_valid_int,  PEIB_to_EOB_valid_int, 
	   NIB_data_out,  SIB_data_out,  WIB_data_out,    PEIB_data_out, 
	   EOB_to_NIB_ready, EOB_to_SIB_ready,  EOB_to_WIB_ready,  EOB_to_PEIB_ready);

	 output_controller PE_OC (   clk,  reset,  polarity, PEOB_so, PEOB_do,   PEOB_ro,  
	   NIB_to_PEOB_valid, SIB_to_PEOB_valid,  WIB_to_PEOB_valid, EIB_to_PEOB_valid ,  
		   NIB_to_PEOB_valid_int, SIB_to_PEOB_valid_int,  WIB_to_PEOB_valid_int, EIB_to_PEOB_valid_int ,  
	   NIB_data_out, SIB_data_out, WIB_data_out,  EIB_data_out,   
	   PEOB_to_NIB_ready, PEOB_to_SIB_ready,  PEOB_to_WIB_ready,  PEOB_to_EIB_ready );
endmodule 

module Mesh_with_NIC(
	input clk, reset,polarity,



	// PE_NIC for 00 Tejas:
	input nicEn_00, nicWrEn_00,
	input [1:0] addr_00, 
	input [63:0] d_in_00, 
	output  [63:0] d_out_00,

	// PE_NIC for 01
	input nicEn_01, nicWrEn_01,
	input [1:0] addr_01, 
	input [63:0] d_in_01, 
	output  [63:0] d_out_01,

	// PE_NIC for 02
	input nicEn_02, nicWrEn_02,
	input [1:0] addr_02, 
	input [63:0] d_in_02, 
	output  [63:0] d_out_02,

	// PE_NIC for 03
	input nicEn_03, nicWrEn_03,
	input [1:0] addr_03, 
	input [63:0] d_in_03, 
	output  [63:0] d_out_03,

	// PE_NIC for 10
	input nicEn_10, nicWrEn_10,
	input [1:0] addr_10, 
	input [63:0] d_in_10, 
	output  [63:0] d_out_10,

	// PE_NIC for 11
	input nicEn_11, nicWrEn_11,
	input [1:0] addr_11, 
	input [63:0] d_in_11, 
	output  [63:0] d_out_11,

	// PE_NIC for 12
	input nicEn_12, nicWrEn_12,
	input [1:0] addr_12, 
	input [63:0] d_in_12, 
	output  [63:0] d_out_12,

	// PE_NIC for 13
	input nicEn_13, nicWrEn_13,
	input [1:0] addr_13, 
	input [63:0] d_in_13, 
	output  [63:0] d_out_13,

	// PE_NIC for 20
	input nicEn_20, nicWrEn_20,
	input [1:0] addr_20, 
	input [63:0] d_in_20, 
	output  [63:0] d_out_20,

	// PE_NIC for 21
	input nicEn_21, nicWrEn_21,
	input [1:0] addr_21, 
	input [63:0] d_in_21, 
	output  [63:0] d_out_21,

	// PE_NIC for 22
	input nicEn_22, nicWrEn_22,
	input [1:0] addr_22, 
	input [63:0] d_in_22, 
	output  [63:0] d_out_22,

	// PE_NIC for 23
	input nicEn_23, nicWrEn_23,
	input [1:0] addr_23, 
	input [63:0] d_in_23, 
	output  [63:0] d_out_23,

	// PE_NIC for 30
	input nicEn_30, nicWrEn_30,
	input [1:0] addr_30, 
	input [63:0] d_in_30, 
	output  [63:0] d_out_30,

	// PE_NIC for 31
	input nicEn_31, nicWrEn_31,
	input [1:0] addr_31, 
	input [63:0] d_in_31, 
	output  [63:0] d_out_31,

	// PE_NIC for 32
	input nicEn_32, nicWrEn_32,
	input [1:0] addr_32, 
	input [63:0] d_in_32, 
	output  [63:0] d_out_32,

	// PE_NIC for 33
	input nicEn_33, nicWrEn_33,
	input [1:0] addr_33, 
	input [63:0] d_in_33, 
	output  [63:0] d_out_33
);

	// Inputs for PEIB_si from 00 to 33
	wire  PEIB_si_00, PEIB_si_01, PEIB_si_02, PEIB_si_03;
	wire  PEIB_si_10, PEIB_si_11, PEIB_si_12, PEIB_si_13;
	wire  PEIB_si_20, PEIB_si_21, PEIB_si_22, PEIB_si_23;
	wire  PEIB_si_30, PEIB_si_31, PEIB_si_32, PEIB_si_33;

	// Inputs for PEIB_di from 00 to 33
	wire [63:0] PEIB_di_00, PEIB_di_01, PEIB_di_02, PEIB_di_03;
	wire [63:0] PEIB_di_10, PEIB_di_11, PEIB_di_12, PEIB_di_13;
	wire [63:0] PEIB_di_20, PEIB_di_21, PEIB_di_22, PEIB_di_23;
	wire [63:0] PEIB_di_30, PEIB_di_31, PEIB_di_32, PEIB_di_33;

	// Outputs for PEIB_ri from 00 to 33
	wire PEIB_ri_00, PEIB_ri_01, PEIB_ri_02, PEIB_ri_03;
	wire PEIB_ri_10, PEIB_ri_11, PEIB_ri_12, PEIB_ri_13;
	wire PEIB_ri_20, PEIB_ri_21, PEIB_ri_22, PEIB_ri_23;
	wire PEIB_ri_30, PEIB_ri_31, PEIB_ri_32, PEIB_ri_33;

	// Outputs for PEOB_so from 00 to 33
	wire PEOB_so_00, PEOB_so_01, PEOB_so_02, PEOB_so_03;
	wire PEOB_so_10, PEOB_so_11, PEOB_so_12, PEOB_so_13;
	wire PEOB_so_20, PEOB_so_21, PEOB_so_22, PEOB_so_23;
	wire PEOB_so_30, PEOB_so_31, PEOB_so_32, PEOB_so_33;

	// Outputs for PEOB_do from 00 to 33
	wire [63:0] PEOB_do_00, PEOB_do_01, PEOB_do_02, PEOB_do_03;
	wire [63:0] PEOB_do_10, PEOB_do_11, PEOB_do_12, PEOB_do_13;
	wire [63:0] PEOB_do_20, PEOB_do_21, PEOB_do_22, PEOB_do_23;
	wire [63:0] PEOB_do_30, PEOB_do_31, PEOB_do_32, PEOB_do_33;

	// Inputs for PEOB_ro from 00 to 33
	wire PEOB_ro_00, PEOB_ro_01, PEOB_ro_02, PEOB_ro_03;
	wire PEOB_ro_10, PEOB_ro_11, PEOB_ro_12, PEOB_ro_13;
	wire PEOB_ro_20, PEOB_ro_21, PEOB_ro_22, PEOB_ro_23;
	wire PEOB_ro_30, PEOB_ro_31, PEOB_ro_32, PEOB_ro_33;


	// Input ready signals from neighboring nodes
	wire NIB_si_00, NIB_si_01, NIB_si_02, NIB_si_03; // North input ready signals
	wire SIB_si_00, SIB_si_01, SIB_si_02, SIB_si_03; // South input ready signals
	wire WIB_si_00, WIB_si_01, WIB_si_02, WIB_si_03; // West input ready signals
	wire EIB_si_00, EIB_si_01, EIB_si_02, EIB_si_03; // East input ready signals

	// Input data signals (64-bit)
	wire [63:0] NIB_di_00, NIB_di_01, NIB_di_02, NIB_di_03; // Data from North
	wire [63:0] SIB_di_00, SIB_di_01, SIB_di_02, SIB_di_03; // Data from South
	wire [63:0] WIB_di_00, WIB_di_01, WIB_di_02, WIB_di_03; // Data from West
	wire [63:0] EIB_di_00, EIB_di_01, EIB_di_02, EIB_di_03; // Data from East

	// Output ready signals to neighboring nodes
	wire NOB_ro_00, NOB_ro_01, NOB_ro_02, NOB_ro_03; // North output ready signals
	wire SOB_ro_00, SOB_ro_01, SOB_ro_02, SOB_ro_03; // South output ready signals
	wire WOB_ro_00, WOB_ro_01, WOB_ro_02, WOB_ro_03; // West output ready signals
	wire EOB_ro_00, EOB_ro_01, EOB_ro_02, EOB_ro_03; // East output ready signals

	// Output ready signals from nodes
	wire NIB_ri_00, NIB_ri_01, NIB_ri_02, NIB_ri_03; // North input ready signals
	wire SIB_ri_00, SIB_ri_01, SIB_ri_02, SIB_ri_03; // South input ready signals
	wire WIB_ri_00, WIB_ri_01, WIB_ri_02, WIB_ri_03; // West input ready signals
	wire EIB_ri_00, EIB_ri_01, EIB_ri_02, EIB_ri_03; // East input ready signals

	// Output data signals (64-bit)
	wire [63:0] NOB_do_00, NOB_do_01, NOB_do_02, NOB_do_03; // Data to North
	wire [63:0] SOB_do_00, SOB_do_01, SOB_do_02, SOB_do_03; // Data to South
	wire [63:0] WOB_do_00, WOB_do_01, WOB_do_02, WOB_do_03; // Data to West
	wire [63:0] EOB_do_00, EOB_do_01, EOB_do_02, EOB_do_03; // Data to East

	// Output valid signals from nodes (added XOB_so signals)
	wire NOB_so_00, NOB_so_01, NOB_so_02, NOB_so_03; // North output valid signals
	wire SOB_so_00, SOB_so_01, SOB_so_02, SOB_so_03; // South output valid signals
	wire WOB_so_00, WOB_so_01, WOB_so_02, WOB_so_03; // West output valid signals
	wire EOB_so_00, EOB_so_01, EOB_so_02, EOB_so_03; // East output valid signals

	// Repeat for all rows (01, 02, 03) and all nodes
	// Input ready signals from neighboring nodes
	wire NIB_si_10, NIB_si_11, NIB_si_12, NIB_si_13; // North input ready signals
	wire SIB_si_10, SIB_si_11, SIB_si_12, SIB_si_13; // South input ready signals
	wire WIB_si_10, WIB_si_11, WIB_si_12, WIB_si_13; // West input ready signals
	wire EIB_si_10, EIB_si_11, EIB_si_12, EIB_si_13; // East input ready signals

	// Input data signals (64-bit)
	wire [63:0] NIB_di_10, NIB_di_11, NIB_di_12, NIB_di_13; // Data from North
	wire [63:0] SIB_di_10, SIB_di_11, SIB_di_12, SIB_di_13; // Data from South
	wire [63:0] WIB_di_10, WIB_di_11, WIB_di_12, WIB_di_13; // Data from West
	wire [63:0] EIB_di_10, EIB_di_11, EIB_di_12, EIB_di_13; // Data from East

	// Output ready signals to neighboring nodes
	wire NOB_ro_10, NOB_ro_11, NOB_ro_12, NOB_ro_13; // North output ready signals
	wire SOB_ro_10, SOB_ro_11, SOB_ro_12, SOB_ro_13; // South output ready signals
	wire WOB_ro_10, WOB_ro_11, WOB_ro_12, WOB_ro_13; // West output ready signals
	wire EOB_ro_10, EOB_ro_11, EOB_ro_12, EOB_ro_13; // East output ready signals

	// Output ready signals from nodes
	wire NIB_ri_10, NIB_ri_11, NIB_ri_12, NIB_ri_13; // North input ready signals
	wire SIB_ri_10, SIB_ri_11, SIB_ri_12, SIB_ri_13; // South input ready signals
	wire WIB_ri_10, WIB_ri_11, WIB_ri_12, WIB_ri_13; // West input ready signals
	wire EIB_ri_10, EIB_ri_11, EIB_ri_12, EIB_ri_13; // East input ready signals

	// Output data signals (64-bit)
	wire [63:0] NOB_do_10, NOB_do_11, NOB_do_12, NOB_do_13; // Data to North
	wire [63:0] SOB_do_10, SOB_do_11, SOB_do_12, SOB_do_13; // Data to South
	wire [63:0] WOB_do_10, WOB_do_11, WOB_do_12, WOB_do_13; // Data to West
	wire [63:0] EOB_do_10, EOB_do_11, EOB_do_12, EOB_do_13; // Data to East

	// Output valid signals from nodes (added XOB_so signals)
	wire NOB_so_10, NOB_so_11, NOB_so_12, NOB_so_13; // North output valid signals
	wire SOB_so_10, SOB_so_11, SOB_so_12, SOB_so_13; // South output valid signals
	wire WOB_so_10, WOB_so_11, WOB_so_12, WOB_so_13; // West output valid signals
	wire EOB_so_10, EOB_so_11, EOB_so_12, EOB_so_13; // East output valid signals

	// Repeat for nodes 20 to 33
	// Input ready signals from neighboring nodes
	wire NIB_si_20, NIB_si_21, NIB_si_22, NIB_si_23; // North input ready signals
	wire SIB_si_20, SIB_si_21, SIB_si_22, SIB_si_23; // South input ready signals
	wire WIB_si_20, WIB_si_21, WIB_si_22, WIB_si_23; // West input ready signals
	wire EIB_si_20, EIB_si_21, EIB_si_22, EIB_si_23; // East input ready signals

	// Input data signals (64-bit)
	wire [63:0] NIB_di_20, NIB_di_21, NIB_di_22, NIB_di_23; // Data from North
	wire [63:0] SIB_di_20, SIB_di_21, SIB_di_22, SIB_di_23; // Data from South
	wire [63:0] WIB_di_20, WIB_di_21, WIB_di_22, WIB_di_23; // Data from West
	wire [63:0] EIB_di_20, EIB_di_21, EIB_di_22, EIB_di_23; // Data from East

	// Output ready signals to neighboring nodes
	wire NOB_ro_20, NOB_ro_21, NOB_ro_22, NOB_ro_23; // North output ready signals
	wire SOB_ro_20, SOB_ro_21, SOB_ro_22, SOB_ro_23; // South output ready signals
	wire WOB_ro_20, WOB_ro_21, WOB_ro_22, WOB_ro_23; // West output ready signals
	wire EOB_ro_20, EOB_ro_21, EOB_ro_22, EOB_ro_23; // East output ready signals

	// Output ready signals from nodes
	wire NIB_ri_20, NIB_ri_21, NIB_ri_22, NIB_ri_23; // North input ready signals
	wire SIB_ri_20, SIB_ri_21, SIB_ri_22, SIB_ri_23; // South input ready signals
	wire WIB_ri_20, WIB_ri_21, WIB_ri_22, WIB_ri_23; // West input ready signals
	wire EIB_ri_20, EIB_ri_21, EIB_ri_22, EIB_ri_23; // East input ready signals

	// Output data signals (64-bit)
	wire [63:0] NOB_do_20, NOB_do_21, NOB_do_22, NOB_do_23; // Data to North
	wire [63:0] SOB_do_20, SOB_do_21, SOB_do_22, SOB_do_23; // Data to South
	wire [63:0] WOB_do_20, WOB_do_21, WOB_do_22, WOB_do_23; // Data to West
	wire [63:0] EOB_do_20, EOB_do_21, EOB_do_22, EOB_do_23; // Data to East

	// Output valid signals from nodes (added XOB_so signals)
	wire NOB_so_20, NOB_so_21, NOB_so_22, NOB_so_23; // North output valid signals
	wire SOB_so_20, SOB_so_21, SOB_so_22, SOB_so_23; // South output valid signals
	wire WOB_so_20, WOB_so_21, WOB_so_22, WOB_so_23; // West output valid signals
	wire EOB_so_20, EOB_so_21, EOB_so_22, EOB_so_23; // East output valid signals

	// Input ready signals from neighboring nodes
	wire NIB_si_30, NIB_si_31, NIB_si_32, NIB_si_33; // North input ready signals
	wire SIB_si_30, SIB_si_31, SIB_si_32, SIB_si_33; // South input ready signals
	wire WIB_si_30, WIB_si_31, WIB_si_32, WIB_si_33; // West input ready signals
	wire EIB_si_30, EIB_si_31, EIB_si_32, EIB_si_33; // East input ready signals

	// Input data signals (64-bit)
	wire [63:0] NIB_di_30, NIB_di_31, NIB_di_32, NIB_di_33; // Data from North
	wire [63:0] SIB_di_30, SIB_di_31, SIB_di_32, SIB_di_33; // Data from South
	wire [63:0] WIB_di_30, WIB_di_31, WIB_di_32, WIB_di_33; // Data from West
	wire [63:0] EIB_di_30, EIB_di_31, EIB_di_32, EIB_di_33; // Data from East

	// Output ready signals to neighboring nodes
	wire NOB_ro_30, NOB_ro_31, NOB_ro_32, NOB_ro_33; // North output ready signals
	wire SOB_ro_30, SOB_ro_31, SOB_ro_32, SOB_ro_33; // South output ready signals
	wire WOB_ro_30, WOB_ro_31, WOB_ro_32, WOB_ro_33; // West output ready signals
	wire EOB_ro_30, EOB_ro_31, EOB_ro_32, EOB_ro_33; // East output ready signals

	// Output ready signals from nodes
	wire NIB_ri_30, NIB_ri_31, NIB_ri_32, NIB_ri_33; // North input ready signals
	wire SIB_ri_30, SIB_ri_31, SIB_ri_32, SIB_ri_33; // South input ready signals
	wire WIB_ri_30, WIB_ri_31, WIB_ri_32, WIB_ri_33; // West input ready signals
	wire EIB_ri_30, EIB_ri_31, EIB_ri_32, EIB_ri_33; // East input ready signals

	// Output data signals (64-bit)
	wire [63:0] NOB_do_30, NOB_do_31, NOB_do_32, NOB_do_33; // Data to North
	wire [63:0] SOB_do_30, SOB_do_31, SOB_do_32, SOB_do_33; // Data to South
	wire [63:0] WOB_do_30, WOB_do_31, WOB_do_32, WOB_do_33; // Data to West
	wire [63:0] EOB_do_30, EOB_do_31, EOB_do_32, EOB_do_33; // Data to East

	// Output valid signals from nodes (added XOB_so signals)
	wire NOB_so_30, NOB_so_31, NOB_so_32, NOB_so_33; // North output valid signals
	wire SOB_so_30, SOB_so_31, SOB_so_32, SOB_so_33; // South output valid signals
	wire WOB_so_30, WOB_so_31, WOB_so_32, WOB_so_33; // West output valid signals
	wire EOB_so_30, EOB_so_31, EOB_so_32, EOB_so_33; // East output valid signals

	// polarity from node to NIC 
	// Tejas: polarity
	wire polarity_from_N00, polarity_from_N01, polarity_from_N02, polarity_from_N03;
	wire polarity_from_N10, polarity_from_N11, polarity_from_N12, polarity_from_N13;
	wire polarity_from_N20, polarity_from_N21, polarity_from_N22, polarity_from_N23;
	wire polarity_from_N30, polarity_from_N31, polarity_from_N32, polarity_from_N33;

	  


	  // Instantiate nodes in 4x4 grid
	  
	  // Row 0
	// Tejas: Node change


	// Tejas: polarity at each NIC
	NIC NIC00(.clk(clk), .reset(reset), .nicEn(nicEn_00), .nicWrEn(nicWrEn_00), .addr(addr_00), .d_in(d_in_00), .d_out(d_out_00), .net_so(PEIB_si_00), .net_ro(PEIB_ri_00), .net_do(PEIB_di_00), .net_polarity(polarity_from_N00), .net_si(PEOB_so_00), .net_ri(PEOB_ro_00), .net_di(PEOB_do_00)); 
	Node N00 (clk, reset, polarity, NIB_si_00, SIB_si_00, WIB_si_00, EIB_si_00, PEIB_si_00, 
					 NIB_di_00, SIB_di_00, WIB_di_00, EIB_di_00, PEIB_di_00,
					 NIB_ri_00, SIB_ri_00, WIB_ri_00, EIB_ri_00, PEIB_ri_00,
					 NOB_so_00, SOB_so_00, WOB_so_00, EOB_so_00, PEOB_so_00,
					 NOB_do_00, SOB_do_00, WOB_do_00, EOB_do_00, PEOB_do_00,
					 NOB_ro_00, SOB_ro_00, WOB_ro_00, EOB_ro_00, PEOB_ro_00, polarity_from_N00);

	NIC NIC01(.clk(clk), .reset(reset), .nicEn(nicEn_01), .nicWrEn(nicWrEn_01), .addr(addr_01), .d_in(d_in_01), .d_out(d_out_01), .net_so(PEIB_si_01), .net_ro(PEIB_ri_01), .net_do(PEIB_di_01), .net_polarity(polarity_from_N01), .net_si(PEOB_so_01), .net_ri(PEOB_ro_01), .net_di(PEOB_do_01)); 
	Node N01 (clk, reset, polarity, NIB_si_01, SIB_si_01, WIB_si_01, EIB_si_01, PEIB_si_01,
					 NIB_di_01, SIB_di_01, WIB_di_01, EIB_di_01, PEIB_di_01,
					 NIB_ri_01, SIB_ri_01, WIB_ri_01, EIB_ri_01, PEIB_ri_01,
					 NOB_so_01, SOB_so_01, WOB_so_01, EOB_so_01, PEOB_so_01,
					 NOB_do_01, SOB_do_01, WOB_do_01, EOB_do_01, PEOB_do_01,
					 NOB_ro_01, SOB_ro_01, WOB_ro_01, EOB_ro_01, PEOB_ro_01, polarity_from_N01);

	NIC NIC02(.clk(clk), .reset(reset), .nicEn(nicEn_02), .nicWrEn(nicWrEn_02), .addr(addr_02), .d_in(d_in_02), .d_out(d_out_02), .net_so(PEIB_si_02), .net_ro(PEIB_ri_02), .net_do(PEIB_di_02), .net_polarity(polarity_from_N02), .net_si(PEOB_so_02), .net_ri(PEOB_ro_02), .net_di(PEOB_do_02)); 
	Node N02 (clk, reset, polarity, NIB_si_02, SIB_si_02, WIB_si_02, EIB_si_02, PEIB_si_02,
					 NIB_di_02, SIB_di_02, WIB_di_02, EIB_di_02, PEIB_di_02,
					 NIB_ri_02, SIB_ri_02, WIB_ri_02, EIB_ri_02, PEIB_ri_02,
					 NOB_so_02, SOB_so_02, WOB_so_02, EOB_so_02, PEOB_so_02,
					 NOB_do_02, SOB_do_02, WOB_do_02, EOB_do_02, PEOB_do_02,
					 NOB_ro_02, SOB_ro_02, WOB_ro_02, EOB_ro_02, PEOB_ro_02, polarity_from_N02);

	NIC NIC03(.clk(clk), .reset(reset), .nicEn(nicEn_03), .nicWrEn(nicWrEn_03), .addr(addr_03), .d_in(d_in_03), .d_out(d_out_03), .net_so(PEIB_si_03), .net_ro(PEIB_ri_03), .net_do(PEIB_di_03), .net_polarity(polarity_from_N03), .net_si(PEOB_so_03), .net_ri(PEOB_ro_03), .net_di(PEOB_do_03)); 
	Node N03 (clk, reset, polarity, NIB_si_03, SIB_si_03, WIB_si_03, EIB_si_03, PEIB_si_03,
					 NIB_di_03, SIB_di_03, WIB_di_03, EIB_di_03, PEIB_di_03,
					 NIB_ri_03, SIB_ri_03, WIB_ri_03, EIB_ri_03, PEIB_ri_03,
					 NOB_so_03, SOB_so_03, WOB_so_03, EOB_so_03, PEOB_so_03,
					 NOB_do_03, SOB_do_03, WOB_do_03, EOB_do_03, PEOB_do_03,
					 NOB_ro_03, SOB_ro_03, WOB_ro_03, EOB_ro_03, PEOB_ro_03, polarity_from_N03);

	// Row 1
	NIC NIC10(.clk(clk), .reset(reset), .nicEn(nicEn_10), .nicWrEn(nicWrEn_10), .addr(addr_10), .d_in(d_in_10), .d_out(d_out_10), .net_so(PEIB_si_10), .net_ro(PEIB_ri_10), .net_do(PEIB_di_10), .net_polarity(polarity_from_N10), .net_si(PEOB_so_10), .net_ri(PEOB_ro_10), .net_di(PEOB_do_10)); 
	Node N10 (clk, reset, polarity, NIB_si_10, SIB_si_10, WIB_si_10, EIB_si_10, PEIB_si_10,
					 NIB_di_10, SIB_di_10, WIB_di_10, EIB_di_10, PEIB_di_10,
					 NIB_ri_10, SIB_ri_10, WIB_ri_10, EIB_ri_10, PEIB_ri_10,
					 NOB_so_10, SOB_so_10, WOB_so_10, EOB_so_10, PEOB_so_10,
					 NOB_do_10, SOB_do_10, WOB_do_10, EOB_do_10, PEOB_do_10,
					 NOB_ro_10, SOB_ro_10, WOB_ro_10, EOB_ro_10, PEOB_ro_10, polarity_from_N10);

	NIC NIC11(.clk(clk), .reset(reset), .nicEn(nicEn_11), .nicWrEn(nicWrEn_11), .addr(addr_11), .d_in(d_in_11), .d_out(d_out_11), .net_so(PEIB_si_11), .net_ro(PEIB_ri_11), .net_do(PEIB_di_11), .net_polarity(polarity_from_N11), .net_si(PEOB_so_11), .net_ri(PEOB_ro_11), .net_di(PEOB_do_11)); 
	Node N11 (clk, reset, polarity, NIB_si_11, SIB_si_11, WIB_si_11, EIB_si_11, PEIB_si_11,
					 NIB_di_11, SIB_di_11, WIB_di_11, EIB_di_11, PEIB_di_11,
					 NIB_ri_11, SIB_ri_11, WIB_ri_11, EIB_ri_11, PEIB_ri_11,
					 NOB_so_11, SOB_so_11, WOB_so_11, EOB_so_11, PEOB_so_11,
					 NOB_do_11, SOB_do_11, WOB_do_11, EOB_do_11, PEOB_do_11,
					 NOB_ro_11, SOB_ro_11, WOB_ro_11, EOB_ro_11, PEOB_ro_11, polarity_from_N11);

	NIC NIC12(.clk(clk), .reset(reset), .nicEn(nicEn_12), .nicWrEn(nicWrEn_12), .addr(addr_12), .d_in(d_in_12), .d_out(d_out_12), .net_so(PEIB_si_12), .net_ro(PEIB_ri_12), .net_do(PEIB_di_12), .net_polarity(polarity_from_N12), .net_si(PEOB_so_12), .net_ri(PEOB_ro_12), .net_di(PEOB_do_12)); 
	Node N12 (clk, reset, polarity, NIB_si_12, SIB_si_12, WIB_si_12, EIB_si_12, PEIB_si_12,
					 NIB_di_12, SIB_di_12, WIB_di_12, EIB_di_12, PEIB_di_12,
					 NIB_ri_12, SIB_ri_12, WIB_ri_12, EIB_ri_12, PEIB_ri_12,
					 NOB_so_12, SOB_so_12, WOB_so_12, EOB_so_12, PEOB_so_12,
					 NOB_do_12, SOB_do_12, WOB_do_12, EOB_do_12, PEOB_do_12,
					 NOB_ro_12, SOB_ro_12, WOB_ro_12, EOB_ro_12, PEOB_ro_12, polarity_from_N12);

	NIC NIC13(.clk(clk), .reset(reset), .nicEn(nicEn_13), .nicWrEn(nicWrEn_13), .addr(addr_13), .d_in(d_in_13), .d_out(d_out_13), .net_so(PEIB_si_13), .net_ro(PEIB_ri_13), .net_do(PEIB_di_13), .net_polarity(polarity_from_N13), .net_si(PEOB_so_13), .net_ri(PEOB_ro_13), .net_di(PEOB_do_13)); 
	Node N13 (clk, reset, polarity, NIB_si_13, SIB_si_13, WIB_si_13, EIB_si_13, PEIB_si_13,
					 NIB_di_13, SIB_di_13, WIB_di_13, EIB_di_13, PEIB_di_13,
					 NIB_ri_13, SIB_ri_13, WIB_ri_13, EIB_ri_13, PEIB_ri_13,
					 NOB_so_13, SOB_so_13, WOB_so_13, EOB_so_13, PEOB_so_13,
					 NOB_do_13, SOB_do_13, WOB_do_13, EOB_do_13, PEOB_do_13,
					 NOB_ro_13, SOB_ro_13, WOB_ro_13, EOB_ro_13, PEOB_ro_13, polarity_from_N13);

	// Row 2
	NIC NIC20(.clk(clk), .reset(reset), .nicEn(nicEn_20), .nicWrEn(nicWrEn_20), .addr(addr_20), .d_in(d_in_20), .d_out(d_out_20), .net_so(PEIB_si_20), .net_ro(PEIB_ri_20), .net_do(PEIB_di_20), .net_polarity(polarity_from_N20), .net_si(PEOB_so_20), .net_ri(PEOB_ro_20), .net_di(PEOB_do_20)); 
	Node N20 (clk, reset, polarity, NIB_si_20, SIB_si_20, WIB_si_20, EIB_si_20, PEIB_si_20,
					 NIB_di_20, SIB_di_20, WIB_di_20, EIB_di_20, PEIB_di_20,
					 NIB_ri_20, SIB_ri_20, WIB_ri_20, EIB_ri_20, PEIB_ri_20,
					 NOB_so_20, SOB_so_20, WOB_so_20, EOB_so_20, PEOB_so_20,
					 NOB_do_20, SOB_do_20, WOB_do_20, EOB_do_20, PEOB_do_20,
					 NOB_ro_20, SOB_ro_20, WOB_ro_20, EOB_ro_20, PEOB_ro_20, polarity_from_N20);

	NIC NIC21(.clk(clk), .reset(reset), .nicEn(nicEn_21), .nicWrEn(nicWrEn_21), .addr(addr_21), .d_in(d_in_21), .d_out(d_out_21), .net_so(PEIB_si_21), .net_ro(PEIB_ri_21), .net_do(PEIB_di_21), .net_polarity(polarity_from_N21), .net_si(PEOB_so_21), .net_ri(PEOB_ro_21), .net_di(PEOB_do_21)); 
	Node N21 (clk, reset, polarity, NIB_si_21, SIB_si_21, WIB_si_21, EIB_si_21, PEIB_si_21,
					 NIB_di_21, SIB_di_21, WIB_di_21, EIB_di_21, PEIB_di_21,
					 NIB_ri_21, SIB_ri_21, WIB_ri_21, EIB_ri_21, PEIB_ri_21,
					 NOB_so_21, SOB_so_21, WOB_so_21, EOB_so_21, PEOB_so_21,
					 NOB_do_21, SOB_do_21, WOB_do_21, EOB_do_21, PEOB_do_21,
					 NOB_ro_21, SOB_ro_21, WOB_ro_21, EOB_ro_21, PEOB_ro_21, polarity_from_N21);

	NIC NIC22(.clk(clk), .reset(reset), .nicEn(nicEn_22), .nicWrEn(nicWrEn_22), .addr(addr_22), .d_in(d_in_22), .d_out(d_out_22), .net_so(PEIB_si_22), .net_ro(PEIB_ri_22), .net_do(PEIB_di_22), .net_polarity(polarity_from_N22), .net_si(PEOB_so_22), .net_ri(PEOB_ro_22), .net_di(PEOB_do_22)); 
	Node N22 (clk, reset, polarity, NIB_si_22, SIB_si_22, WIB_si_22, EIB_si_22, PEIB_si_22,
					 NIB_di_22, SIB_di_22, WIB_di_22, EIB_di_22, PEIB_di_22,
					 NIB_ri_22, SIB_ri_22, WIB_ri_22, EIB_ri_22, PEIB_ri_22,
					 NOB_so_22, SOB_so_22, WOB_so_22, EOB_so_22, PEOB_so_22,
					 NOB_do_22, SOB_do_22, WOB_do_22, EOB_do_22, PEOB_do_22,
					 NOB_ro_22, SOB_ro_22, WOB_ro_22, EOB_ro_22, PEOB_ro_22, polarity_from_N22);

	NIC NIC23(.clk(clk), .reset(reset), .nicEn(nicEn_23), .nicWrEn(nicWrEn_23), .addr(addr_23), .d_in(d_in_23), .d_out(d_out_23), .net_so(PEIB_si_23), .net_ro(PEIB_ri_23), .net_do(PEIB_di_23), .net_polarity(polarity_from_N23), .net_si(PEOB_so_23), .net_ri(PEOB_ro_23), .net_di(PEOB_do_23)); 
	Node N23 (clk, reset, polarity, NIB_si_23, SIB_si_23, WIB_si_23, EIB_si_23, PEIB_si_23,
					 NIB_di_23, SIB_di_23, WIB_di_23, EIB_di_23, PEIB_di_23,
					 NIB_ri_23, SIB_ri_23, WIB_ri_23, EIB_ri_23, PEIB_ri_23,
					 NOB_so_23, SOB_so_23, WOB_so_23, EOB_so_23, PEOB_so_23,
					 NOB_do_23, SOB_do_23, WOB_do_23, EOB_do_23, PEOB_do_23,
					 NOB_ro_23, SOB_ro_23, WOB_ro_23, EOB_ro_23, PEOB_ro_23, polarity_from_N23);

	// Row 3
	NIC NIC30(.clk(clk), .reset(reset), .nicEn(nicEn_30), .nicWrEn(nicWrEn_30), .addr(addr_30), .d_in(d_in_30), .d_out(d_out_30), .net_so(PEIB_si_30), .net_ro(PEIB_ri_30), .net_do(PEIB_di_30), .net_polarity(polarity_from_N30), .net_si(PEOB_so_30), .net_ri(PEOB_ro_30), .net_di(PEOB_do_30)); 
	Node N30 (clk, reset, polarity, NIB_si_30, SIB_si_30, WIB_si_30, EIB_si_30, PEIB_si_30,
					 NIB_di_30, SIB_di_30, WIB_di_30, EIB_di_30, PEIB_di_30,
					 NIB_ri_30, SIB_ri_30, WIB_ri_30, EIB_ri_30, PEIB_ri_30,
					 NOB_so_30, SOB_so_30, WOB_so_30, EOB_so_30, PEOB_so_30,
					 NOB_do_30, SOB_do_30, WOB_do_30, EOB_do_30, PEOB_do_30,
					 NOB_ro_30, SOB_ro_30, WOB_ro_30, EOB_ro_30, PEOB_ro_30, polarity_from_N30);

	NIC NIC31(.clk(clk), .reset(reset), .nicEn(nicEn_31), .nicWrEn(nicWrEn_31), .addr(addr_31), .d_in(d_in_31), .d_out(d_out_31), .net_so(PEIB_si_31), .net_ro(PEIB_ri_31), .net_do(PEIB_di_31), .net_polarity(polarity_from_N31), .net_si(PEOB_so_31), .net_ri(PEOB_ro_31), .net_di(PEOB_do_31)); 
	Node N31 (clk, reset, polarity, NIB_si_31, SIB_si_31, WIB_si_31, EIB_si_31, PEIB_si_31,
					 NIB_di_31, SIB_di_31, WIB_di_31, EIB_di_31, PEIB_di_31,
					 NIB_ri_31, SIB_ri_31, WIB_ri_31, EIB_ri_31, PEIB_ri_31,
					 NOB_so_31, SOB_so_31, WOB_so_31, EOB_so_31, PEOB_so_31,
					 NOB_do_31, SOB_do_31, WOB_do_31, EOB_do_31, PEOB_do_31,
					 NOB_ro_31, SOB_ro_31, WOB_ro_31, EOB_ro_31, PEOB_ro_31, polarity_from_N31);

	NIC NIC32(.clk(clk), .reset(reset), .nicEn(nicEn_32), .nicWrEn(nicWrEn_32), .addr(addr_32), .d_in(d_in_32), .d_out(d_out_32), .net_so(PEIB_si_32), .net_ro(PEIB_ri_32), .net_do(PEIB_di_32), .net_polarity(polarity_from_N32), .net_si(PEOB_so_32), .net_ri(PEOB_ro_32), .net_di(PEOB_do_32)); 
	Node N32 (clk, reset, polarity, NIB_si_32, SIB_si_32, WIB_si_32, EIB_si_32, PEIB_si_32,
					 NIB_di_32, SIB_di_32, WIB_di_32, EIB_di_32, PEIB_di_32,
					 NIB_ri_32, SIB_ri_32, WIB_ri_32, EIB_ri_32, PEIB_ri_32,
					 NOB_so_32, SOB_so_32, WOB_so_32, EOB_so_32, PEOB_so_32,
					 NOB_do_32, SOB_do_32, WOB_do_32, EOB_do_32, PEOB_do_32,
					 NOB_ro_32, SOB_ro_32, WOB_ro_32, EOB_ro_32, PEOB_ro_32, polarity_from_N32);

	NIC NIC33(.clk(clk), .reset(reset), .nicEn(nicEn_33), .nicWrEn(nicWrEn_33), .addr(addr_33), .d_in(d_in_33), .d_out(d_out_33), .net_so(PEIB_si_33), .net_ro(PEIB_ri_33), .net_do(PEIB_di_33), .net_polarity(polarity_from_N33), .net_si(PEOB_so_33), .net_ri(PEOB_ro_33), .net_di(PEOB_do_33)); 
	Node N33 (clk, reset, polarity, NIB_si_33, SIB_si_33, WIB_si_33, EIB_si_33, PEIB_si_33,
					 NIB_di_33, SIB_di_33, WIB_di_33, EIB_di_33, PEIB_di_33,
					 NIB_ri_33, SIB_ri_33, WIB_ri_33, EIB_ri_33, PEIB_ri_33,
					 NOB_so_33, SOB_so_33, WOB_so_33, EOB_so_33, PEOB_so_33,
					 NOB_do_33, SOB_do_33, WOB_do_33, EOB_do_33, PEOB_do_33,
					 NOB_ro_33, SOB_ro_33, WOB_ro_33, EOB_ro_33, PEOB_ro_33, polarity_from_N33);
	//corner nodes
	// Node (00)
	assign NIB_si_00 = SOB_so_01;  
	assign NIB_di_00 = SOB_do_01;  
	assign NOB_ro_00 = SIB_ri_01;  // Ready output connection

	assign SIB_si_00 = 0;  
	assign SIB_di_00 = 0;  
	assign SOB_ro_00 = 0;  

	assign WIB_si_00 = 0;  
	assign WIB_di_00 = 0;  
	assign WOB_ro_00 = 0;  

	assign EIB_si_00 = WOB_so_10;  
	assign EIB_di_00 = WOB_do_10;  
	assign EOB_ro_00 = WIB_ri_10;  



	// Node (30) //lower right corner
	assign NIB_si_30 = SOB_so_31;  
	assign NIB_di_30 = SOB_do_31;  
	assign NOB_ro_30 = SIB_ri_31;  // Ready output connection

	assign SIB_si_30 = 0;  
	assign SIB_di_30 = 0;  
	assign SOB_ro_30 = 0;  

	assign WIB_si_30 = EOB_so_20;  
	assign WIB_di_30 = EOB_do_20;  
	assign WOB_ro_30 = EIB_ri_20;  

	assign EIB_si_30 = 0;  
	assign EIB_di_30 = 0;  
	assign EOB_ro_30 = 0; 

	// Node (03) upper left corner
	assign NIB_si_03 = 0;  
	assign NIB_di_03= 0;  
	assign NOB_ro_03 = 0;    // Ready output connection

	assign SIB_si_03 = NOB_so_02;  
	assign SIB_di_03 = NOB_do_02;  
	assign SOB_ro_03 = NIB_ri_02; 

	assign WIB_si_03 = 0;  
	assign WIB_di_03 = 0;  
	assign WOB_ro_03 = 0;   

	assign EIB_si_03 = WOB_so_13;  
	assign EIB_di_03 = WOB_do_13;  
	assign EOB_ro_03 = WIB_ri_13;  

	// Node (33) upper right
	assign NIB_si_33 = 0;  
	assign NIB_di_33 = 0;  
	assign NOB_ro_33 = 0;    // Ready output connection

	assign SIB_si_33 = NOB_so_32;  
	assign SIB_di_33 = NOB_do_32;  
	assign SOB_ro_33 = NIB_ri_32; 

	assign WIB_si_33 = EOB_so_23;  
	assign WIB_di_33 = EOB_do_23;  
	assign WOB_ro_33 = EIB_ri_23;   

	assign EIB_si_33 = 0;  
	assign EIB_di_33 = 0;  
	assign EOB_ro_33 = 0;  

	//centre nodes
	// Node (11)
	assign NIB_si_11 = SOB_so_12;  
	assign NIB_di_11 = SOB_do_12;  
	assign NOB_ro_11 = SIB_ri_12;  

	assign SIB_si_11 = NOB_so_10;  
	assign SIB_di_11 = NOB_do_10;  
	assign SOB_ro_11 = NIB_ri_10; 

	assign WIB_si_11 = EOB_so_01;  
	assign WIB_di_11 = EOB_do_01;  
	assign WOB_ro_11 = EIB_ri_01; 

	assign EIB_si_11 = WOB_so_21;  
	assign EIB_di_11 = WOB_do_21;  
	assign EOB_ro_11 = WIB_ri_21; 

	// Node (12)
	assign NIB_si_12 = SOB_so_13;  
	assign NIB_di_12 = SOB_do_13;  
	assign NOB_ro_12 = SIB_ri_13;  

	assign SIB_si_12 = NOB_so_11;  
	assign SIB_di_12 = NOB_do_11;  
	assign SOB_ro_12 = NIB_ri_11; 

	assign WIB_si_12 = EOB_so_02;  
	assign WIB_di_12 = EOB_do_02;  
	assign WOB_ro_12 = EIB_ri_02; 

	assign EIB_si_12 = WOB_so_22;  
	assign EIB_di_12 = WOB_do_22;  
	assign EOB_ro_12 = WIB_ri_22; 

	// Node (21)
	assign NIB_si_21 = SOB_so_22;  
	assign NIB_di_21 = SOB_do_22;  
	assign NOB_ro_21 = SIB_ri_22;  

	assign SIB_si_21 = NOB_so_20;  
	assign SIB_di_21 = NOB_do_20;  
	assign SOB_ro_21 = NIB_ri_20; 

	assign WIB_si_21 = EOB_so_11;  
	assign WIB_di_21 = EOB_do_11;  
	assign WOB_ro_21 = EIB_ri_11; 

	assign EIB_si_21 = WOB_so_31;  
	assign EIB_di_21 = WOB_do_31;  
	assign EOB_ro_21 = WIB_ri_31; 

	// Node (22)
	assign NIB_si_22 = SOB_so_23;  
	assign NIB_di_22 = SOB_do_23;  
	assign NOB_ro_22 = SIB_ri_23;  

	assign SIB_si_22 = NOB_so_21;  
	assign SIB_di_22 = NOB_do_21;  
	assign SOB_ro_22 = NIB_ri_21;  

	assign WIB_si_22 = EOB_so_12;  
	assign WIB_di_22 = EOB_do_12;  
	assign WOB_ro_22 = EIB_ri_12; 

	assign EIB_si_22 = WOB_so_32;  
	assign EIB_di_22 = WOB_do_32;  
	assign EOB_ro_22 = WIB_ri_32; 


	//lower nodes
	// Node (10)
	assign NIB_si_10 = SOB_so_11;  
	assign NIB_di_10 = SOB_do_11;  
	assign NOB_ro_10 = SIB_ri_11;  

	assign SIB_si_10 = 0;  
	assign SIB_di_10 = 0;  
	assign SOB_ro_10 = 0; 

	assign WIB_si_10 = EOB_so_00;  
	assign WIB_di_10 = EOB_do_00;  
	assign WOB_ro_10 = EIB_ri_00; 

	assign EIB_si_10 = WOB_so_20;  
	assign EIB_di_10 = WOB_do_20;  
	assign EOB_ro_10 = WIB_ri_20; 

	// Node (20)
	assign NIB_si_20 = SOB_so_21;  
	assign NIB_di_20 = SOB_do_21;  
	assign NOB_ro_20 = SIB_ri_21;  

	assign SIB_si_20 = 0;  
	assign SIB_di_20 = 0;  
	assign SOB_ro_20 = 0; 

	assign WIB_si_20 = EOB_so_10;  
	assign WIB_di_20 = EOB_do_10;  
	assign WOB_ro_20 = EIB_ri_10; 

	assign EIB_si_20 = WOB_so_30;  
	assign EIB_di_20 = WOB_do_30;  
	assign EOB_ro_20 = WIB_ri_30; 

	//left side nodes

	//Node (01)
	assign NIB_si_01 = SOB_so_02;  
	assign NIB_di_01 = SOB_do_02;  
	assign NOB_ro_01 = SIB_ri_02;  

	assign SIB_si_01 = NOB_so_00;  
	assign SIB_di_01 = NOB_do_00;  
	assign SOB_ro_01 = NIB_ri_00; 

	assign WIB_si_01 = 0;  
	assign WIB_di_01 = 0;  
	assign WOB_ro_01 = 0; 

	assign EIB_si_01 = WOB_so_11;  
	assign EIB_di_01 = WOB_do_11;  
	assign EOB_ro_01 = WIB_ri_11; 

	//Node (02)
	assign NIB_si_02 = SOB_so_03;  
	assign NIB_di_02 = SOB_do_03;  
	assign NOB_ro_02 = SIB_ri_03;  

	assign SIB_si_02 = NOB_so_01;  
	assign SIB_di_02 = NOB_do_01;  
	assign SOB_ro_02 = NIB_ri_01; 

	assign WIB_si_02 = 0;  
	assign WIB_di_02 = 0;  
	assign WOB_ro_02 = 0; 

	assign EIB_si_02 = WOB_so_12;  
	assign EIB_di_02 = WOB_do_12;  
	assign EOB_ro_02 = WIB_ri_12; 

	//Right side nodes 31, 32
	// Node (31)
	assign NIB_si_31 = SOB_so_32;  
	assign NIB_di_31 = SOB_do_32;  
	assign NOB_ro_31 = SIB_ri_32;  

	assign SIB_si_31 = NOB_so_30;  
	assign SIB_di_31 = NOB_do_30;  
	assign SOB_ro_31 = NIB_ri_30; 

	assign WIB_si_31 = EOB_so_21;  
	assign WIB_di_31 = EOB_do_21;  
	assign WOB_ro_31 = EIB_ri_21; 

	assign EIB_si_31 = 0;  
	assign EIB_di_31 = 0;  
	assign EOB_ro_31 = 0; 

	// Node (32)
	assign NIB_si_32 = SOB_so_33;  
	assign NIB_di_32 = SOB_do_33;  
	assign NOB_ro_32 = SIB_ri_33;  

	assign SIB_si_32 = NOB_so_31;  
	assign SIB_di_32 = NOB_do_31;  
	assign SOB_ro_32 = NIB_ri_31; 

	assign WIB_si_32 = EOB_so_22;  
	assign WIB_di_32 = EOB_do_22;  
	assign WOB_ro_32 = EIB_ri_22; 

	assign EIB_si_32 = 0;  
	assign EIB_di_32 = 0;  
	assign EOB_ro_32 = 0; 
	 

	//Upper nodes : 13, 23

	//Node 13
	assign NIB_si_13 = 0;  
	assign NIB_di_13 = 0;  
	assign NOB_ro_13 = 0;  

	assign SIB_si_13 = NOB_so_12;  
	assign SIB_di_13 = NOB_do_12;  
	assign SOB_ro_13 = NIB_ri_12; 

	assign WIB_si_13 = EOB_so_03;  
	assign WIB_di_13 = EOB_do_03;  
	assign WOB_ro_13 = EIB_ri_03; 

	assign EIB_si_13 = WOB_so_23;  
	assign EIB_di_13 = WOB_do_23;  
	assign EOB_ro_13 = WIB_ri_23; 


	//Node 23
	assign NIB_si_23 = 0;  
	assign NIB_di_23 = 0;  
	assign NOB_ro_23 = 0;  

	assign SIB_si_23 = NOB_so_22;  
	assign SIB_di_23 = NOB_do_22;  
	assign SOB_ro_23 = NIB_ri_22; 

	assign WIB_si_23 = EOB_so_13;  
	assign WIB_di_23 = EOB_do_13;  
	assign WOB_ro_23 = EIB_ri_13; 

	assign EIB_si_23 = WOB_so_33;  
	assign EIB_di_23 = WOB_do_33;  
	assign EOB_ro_23 = WIB_ri_33; 

endmodule //hello 
