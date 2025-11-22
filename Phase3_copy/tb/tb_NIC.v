`timescale 1ns/1ns

module tb_NIC;

  // Declare variables for the NIC inputs and outputs
  reg [63:0] d_in;
  reg nicEn, nicWrEn, clk, reset;
  wire [63:0] net_do;
  reg net_ro;
  wire net_so;
  reg net_polarity;
  
  wire [63:0] d_out;
  reg [1:0] addr;
  reg [63:0] net_di;
  reg net_si;
  wire net_ri;

  NIC uut (
    .d_in(d_in),
    .nicEn(nicEn),
    .nicWrEn(nicWrEn),
    .clk(clk),
    .reset(reset),
    .net_do(net_do),
    .net_ro(net_ro),
    .net_so(net_so),
    .net_polarity(net_polarity),
    .d_out(d_out),
    .addr(addr),
    .net_di(net_di),
    .net_si(net_si),
    .net_ri(net_ri)
  );
  
  initial begin
    clk = 0;
  end
  
  always begin
    #1 clk = ~clk;
  end
  
  initial begin
    $dumpfile("dump.vcd");
	$dumpvars();
    reset = 1;
    nicEn = 0;
    nicWrEn = 0;
    d_in = 64'h0;
    addr = 2'b00;
    net_ro = 0;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'h0;
    #4; // reset for 2 cycles

    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1204; //vc is 0
    addr = 2'b10;
    net_ro = 0;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write and output_buffer is empty (out_status = 0) so, net_do should latch in d_in. net_so is 0 coz although the net_ro is high, polarity check with vc fails.
    
    
    $display("Test 1 - net_do: %h, net_so: %b", net_do, net_so);
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1205; //vc is 0
    addr = 2'b10;
    net_ro = 1;
    net_si = 0;
    net_polarity = 0;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do shouldn't latch in d_in, net_so 0 coz net_ro 1 but polarity and vc don match
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1206; //vc is 0
    addr = 2'b10;
    net_ro = 1;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do should latch in d_in, net_so 1 coz net_ro 1 and polarity and vc match
    
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1207; //vc is 0
    addr = 2'b10;
    net_ro = 1;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do should latch in d_in, net_so 1 coz net_ro 1 and polarity and vc match
    
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1208; //vc is 0
    addr = 2'b10;
    net_ro = 1;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do should latch in d_in, net_so 1 coz net_ro 1 and polarity and vc match
    
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1209; //vc is 0
    addr = 2'b00;
    net_ro = 1;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do shouldn't latch in d_in. addr is not 10. net_so 0 coz net_ro 1 and polarity and vc match
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 1;
    d_in = 1209; //vc is 0
    addr = 2'b10;
    net_ro = 0;
    net_si = 0;
    net_polarity = 1;
    net_di = 64'd1312;
    #2; // processor wants to write, outstatus is not 0. net_do should latch in d_in. net_so 0 coz net_ro 1 and polarity and vc match
    
    
    
    //input chan buff
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 0;
    d_in = 1209; //vc is 0
    addr = 2'b00;
    net_ro = 1;
    net_si = 1; // in_status is empty, so net_ri should be 1
    net_polarity = 1;
    net_di = 64'd1312;
    #2; 
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 0;
    d_in = 1210; //vc is 0
    addr = 2'b01;
    net_ro = 0;
    net_si = 1; // in_status is empty, so net_ri should be 1
    net_polarity = 1;
    net_di = 64'd1313;
    #2; 
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 0;
    d_in = 1210; //vc is 0
    addr = 2'b11;
    net_ro = 0;
    net_si = 1; // in_status is empty, so net_ri should be 1
    net_polarity = 1;
    net_di = 64'd1313;
    #2; 
    
    
    reset = 0;
    nicEn = 1;
    nicWrEn = 0;
    d_in = 1210; //vc is 0
    addr = 2'b00;
    net_ro = 0;
    net_si = 1; // in_status is empty, so net_ri should be 1
    net_polarity = 1;
    net_di = 64'd1313;
    #2; 
    
    
    
    
    


    $finish;
  end

endmodule
