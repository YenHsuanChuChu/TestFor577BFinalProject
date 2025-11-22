`timescale 1ns/10ps

`include "./design/cmp16.v"
`include "./design/Mesh_with_NIC.v"

module cardinal_cmp(
    input clk, polarity, reset,

    input [0:31]node0_inst_in,
    input [0:63]node0_d_in,
    output [0:31] node0_pc_out,
    output [0:63] node0_d_out,
    output [0:31] node0_addr_out,
    output node0_memWrEn,
    output node0_memEn,


    input [0:31]node1_inst_in,
    input [0:63]node1_d_in,
    output [0:31] node1_pc_out,
    output [0:63] node1_d_out,
    output [0:31] node1_addr_out,
    output node1_memWrEn,
    output node1_memEn,


    input [0:31]node2_inst_in,
    input [0:63]node2_d_in,
    output [0:31] node2_pc_out,
    output [0:63] node2_d_out,
    output [0:31] node2_addr_out,
    output node2_memWrEn,
    output node2_memEn,
    

    input [0:31]node3_inst_in,
    input [0:63]node3_d_in,
    output [0:31] node3_pc_out,
    output [0:63] node3_d_out,
    output [0:31] node3_addr_out,
    output node3_memWrEn,
    output node3_memEn,


    input [0:31]node4_inst_in,
    input [0:63]node4_d_in,
    output [0:31] node4_pc_out,
    output [0:63] node4_d_out,
    output [0:31] node4_addr_out,
    output node4_memWrEn,
    output node4_memEn,


    input [0:31]node5_inst_in,
    input [0:63]node5_d_in,
    output [0:31] node5_pc_out,
    output [0:63] node5_d_out,
    output [0:31] node5_addr_out,
    output node5_memWrEn,
    output node5_memEn,


    input [0:31]node6_inst_in,
    input [0:63]node6_d_in,
    output [0:31] node6_pc_out,
    output [0:63] node6_d_out,
    output [0:31] node6_addr_out,
    output node6_memWrEn,
    output node6_memEn,


    input [0:31]node7_inst_in,
    input [0:63]node7_d_in,
    output [0:31] node7_pc_out,
    output [0:63] node7_d_out,
    output [0:31] node7_addr_out,
    output node7_memWrEn,
    output node7_memEn,


    input [0:31]node8_inst_in,
    input [0:63]node8_d_in,
    output [0:31] node8_pc_out,
    output [0:63] node8_d_out,
    output [0:31] node8_addr_out,
    output node8_memWrEn,
    output node8_memEn,


    input [0:31]node9_inst_in,
    input [0:63]node9_d_in,
    output [0:31] node9_pc_out,
    output [0:63] node9_d_out,
    output [0:31] node9_addr_out,
    output node9_memWrEn,
    output node9_memEn,


    input [0:31]node10_inst_in,
    input [0:63]node10_d_in,
    output [0:31] node10_pc_out,
    output [0:63] node10_d_out,
    output [0:31] node10_addr_out,
    output node10_memWrEn,
    output node10_memEn,


    input [0:31]node11_inst_in,
    input [0:63]node11_d_in,
    output [0:31] node11_pc_out,
    output [0:63] node11_d_out,
    output [0:31] node11_addr_out,
    output node11_memWrEn,
    output node11_memEn,
    

    input [0:31]node12_inst_in,
    input [0:63]node12_d_in,
    output [0:31] node12_pc_out,
    output [0:63] node12_d_out,
    output [0:31] node12_addr_out,
    output node12_memWrEn,
    output node12_memEn,


    input [0:31]node13_inst_in,
    input [0:63]node13_d_in,
    output [0:31] node13_pc_out,
    output [0:63] node13_d_out,
    output [0:31] node13_addr_out,
    output node13_memWrEn,
    output node13_memEn,
    

    input [0:31]node14_inst_in,
    input [0:63]node14_d_in,
    output [0:31] node14_pc_out,
    output [0:63] node14_d_out,
    output [0:31] node14_addr_out,
    output node14_memWrEn,
    output node14_memEn,
    

    input [0:31]node15_inst_in,
    input [0:63]node15_d_in,
    output [0:31] node15_pc_out,
    output [0:63] node15_d_out,
    output [0:31] node15_addr_out,
    output node15_memWrEn,
    output node15_memEn
);

    wire [0:1] node0_addr_nic;
    wire [0:63] node0_din_nic;
    wire [0:63] node0_dout_nic;
    wire node0_nicEn;
    wire node0_nicWrEn;

    wire [0:1] node1_addr_nic;
    wire [0:63] node1_din_nic;
    wire [0:63] node1_dout_nic;
    wire node1_nicEn;
    wire node1_nicWrEn;

    wire [0:1] node2_addr_nic;
    wire [0:63] node2_din_nic;
    wire [0:63] node2_dout_nic;
    wire node2_nicEn;
    wire node2_nicWrEn;

    wire [0:1] node3_addr_nic;
    wire [0:63] node3_din_nic;
    wire [0:63] node3_dout_nic;
    wire node3_nicEn;
    wire node3_nicWrEn;

    wire [0:1] node4_addr_nic;
    wire [0:63] node4_din_nic;
    wire [0:63] node4_dout_nic;
    wire node4_nicEn;
    wire node4_nicWrEn;

    wire [0:1] node5_addr_nic;
    wire [0:63] node5_din_nic;
    wire [0:63] node5_dout_nic;
    wire node5_nicEn;
    wire node5_nicWrEn;

    wire [0:1] node6_addr_nic;
    wire [0:63] node6_din_nic;
    wire [0:63] node6_dout_nic;
    wire node6_nicEn;
    wire node6_nicWrEn;

    wire [0:1] node7_addr_nic;
    wire [0:63] node7_din_nic;
    wire [0:63] node7_dout_nic;
    wire node7_nicEn;
    wire node7_nicWrEn;

    wire [0:1] node8_addr_nic;
    wire [0:63] node8_din_nic;
    wire [0:63] node8_dout_nic;
    wire node8_nicEn;
    wire node8_nicWrEn;

    wire [0:1] node9_addr_nic;
    wire [0:63] node9_din_nic;
    wire [0:63] node9_dout_nic;
    wire node9_nicEn;
    wire node9_nicWrEn;

    wire [0:1] node10_addr_nic;
    wire [0:63] node10_din_nic;
    wire [0:63] node10_dout_nic;
    wire node10_nicEn;
    wire node10_nicWrEn;

    wire [0:1] node11_addr_nic;
    wire [0:63] node11_din_nic;
    wire [0:63] node11_dout_nic;
    wire node11_nicEn;
    wire node11_nicWrEn;

    wire [0:1] node12_addr_nic;
    wire [0:63] node12_din_nic;
    wire [0:63] node12_dout_nic;
    wire node12_nicEn;
    wire node12_nicWrEn;

    wire [0:1] node13_addr_nic;
    wire [0:63] node13_din_nic;
    wire [0:63] node13_dout_nic;
    wire node13_nicEn;
    wire node13_nicWrEn;

    wire [0:1] node14_addr_nic;
    wire [0:63] node14_din_nic;
    wire [0:63] node14_dout_nic;
    wire node14_nicEn;
    wire node14_nicWrEn;

    wire [0:1] node15_addr_nic;
    wire [0:63] node15_din_nic;
    wire [0:63] node15_dout_nic;
    wire node15_nicEn;
    wire node15_nicWrEn;

	cmp16 cmp16_dut(
		.clk(clk), 
		.reset(reset),

		.node0_inst_in(node0_inst_in),
		.node0_d_in(node0_d_in),
		.node0_pc_out(node0_pc_out),
		.node0_d_out(node0_d_out),
		.node0_addr_out(node0_addr_out),
		.node0_memWrEn(node0_memWrEn),
		.node0_memEn(node0_memEn),
		.node0_addr_nic(node0_addr_nic),
		.node0_din_nic(node0_din_nic),
		.node0_dout_nic(node0_dout_nic),
		.node0_nicEn(node0_nicEn),
		.node0_nicWrEn(node0_nicWrEn),

		.node1_inst_in(node1_inst_in),
		.node1_d_in(node1_d_in),
		.node1_pc_out(node1_pc_out),
		.node1_d_out(node1_d_out),
		.node1_addr_out(node1_addr_out),
		.node1_memWrEn(node1_memWrEn),
		.node1_memEn(node1_memEn),
		.node1_addr_nic(node1_addr_nic),
		.node1_din_nic(node1_din_nic),
		.node1_dout_nic(node1_dout_nic),
		.node1_nicEn(node1_nicEn),
		.node1_nicWrEn(node1_nicWrEn),

		.node2_inst_in(node2_inst_in),
		.node2_d_in(node2_d_in),
		.node2_pc_out(node2_pc_out),
		.node2_d_out(node2_d_out),
		.node2_addr_out(node2_addr_out),
		.node2_memWrEn(node2_memWrEn),
		.node2_memEn(node2_memEn),
		.node2_addr_nic(node2_addr_nic),
		.node2_din_nic(node2_din_nic),
		.node2_dout_nic(node2_dout_nic),
		.node2_nicEn(node2_nicEn),
		.node2_nicWrEn(node2_nicWrEn),

		.node3_inst_in(node3_inst_in),
		.node3_d_in(node3_d_in),
		.node3_pc_out(node3_pc_out),
		.node3_d_out(node3_d_out),
		.node3_addr_out(node3_addr_out),
		.node3_memWrEn(node3_memWrEn),
		.node3_memEn(node3_memEn),
		.node3_addr_nic(node3_addr_nic),
		.node3_din_nic(node3_din_nic),
		.node3_dout_nic(node3_dout_nic),
		.node3_nicEn(node3_nicEn),
		.node3_nicWrEn(node3_nicWrEn),

		.node4_inst_in(node4_inst_in),
		.node4_d_in(node4_d_in),
		.node4_pc_out(node4_pc_out),
		.node4_d_out(node4_d_out),
		.node4_addr_out(node4_addr_out),
		.node4_memWrEn(node4_memWrEn),
		.node4_memEn(node4_memEn),
		.node4_addr_nic(node4_addr_nic),
		.node4_din_nic(node4_din_nic),
		.node4_dout_nic(node4_dout_nic),
		.node4_nicEn(node4_nicEn),
		.node4_nicWrEn(node4_nicWrEn),

		.node5_inst_in(node5_inst_in),
		.node5_d_in(node5_d_in),
		.node5_pc_out(node5_pc_out),
		.node5_d_out(node5_d_out),
		.node5_addr_out(node5_addr_out),
		.node5_memWrEn(node5_memWrEn),
		.node5_memEn(node5_memEn),
		.node5_addr_nic(node5_addr_nic),
		.node5_din_nic(node5_din_nic),
		.node5_dout_nic(node5_dout_nic),
		.node5_nicEn(node5_nicEn),
		.node5_nicWrEn(node5_nicWrEn),

		.node6_inst_in(node6_inst_in),
		.node6_d_in(node6_d_in),
		.node6_pc_out(node6_pc_out),
		.node6_d_out(node6_d_out),
		.node6_addr_out(node6_addr_out),
		.node6_memWrEn(node6_memWrEn),
		.node6_memEn(node6_memEn),
		.node6_addr_nic(node6_addr_nic),
		.node6_din_nic(node6_din_nic),
		.node6_dout_nic(node6_dout_nic),
		.node6_nicEn(node6_nicEn),
		.node6_nicWrEn(node6_nicWrEn),

		.node7_inst_in(node7_inst_in),
		.node7_d_in(node7_d_in),
		.node7_pc_out(node7_pc_out),
		.node7_d_out(node7_d_out),
		.node7_addr_out(node7_addr_out),
		.node7_memWrEn(node7_memWrEn),
		.node7_memEn(node7_memEn),
		.node7_addr_nic(node7_addr_nic),
		.node7_din_nic(node7_din_nic),
		.node7_dout_nic(node7_dout_nic),
		.node7_nicEn(node7_nicEn),
		.node7_nicWrEn(node7_nicWrEn),

		.node8_inst_in(node8_inst_in),
		.node8_d_in(node8_d_in),
		.node8_pc_out(node8_pc_out),
		.node8_d_out(node8_d_out),
		.node8_addr_out(node8_addr_out),
		.node8_memWrEn(node8_memWrEn),
		.node8_memEn(node8_memEn),
		.node8_addr_nic(node8_addr_nic),
		.node8_din_nic(node8_din_nic),
		.node8_dout_nic(node8_dout_nic),
		.node8_nicEn(node8_nicEn),
		.node8_nicWrEn(node8_nicWrEn),

		.node9_inst_in(node9_inst_in),
		.node9_d_in(node9_d_in),
		.node9_pc_out(node9_pc_out),
		.node9_d_out(node9_d_out),
		.node9_addr_out(node9_addr_out),
		.node9_memWrEn(node9_memWrEn),
		.node9_memEn(node9_memEn),
		.node9_addr_nic(node9_addr_nic),
		.node9_din_nic(node9_din_nic),
		.node9_dout_nic(node9_dout_nic),
		.node9_nicEn(node9_nicEn),
		.node9_nicWrEn(node9_nicWrEn),

		.node10_inst_in(node10_inst_in),
		.node10_d_in(node10_d_in),
		.node10_pc_out(node10_pc_out),
		.node10_d_out(node10_d_out),
		.node10_addr_out(node10_addr_out),
		.node10_memWrEn(node10_memWrEn),
		.node10_memEn(node10_memEn),
		.node10_addr_nic(node10_addr_nic),
		.node10_din_nic(node10_din_nic),
		.node10_dout_nic(node10_dout_nic),
		.node10_nicEn(node10_nicEn),
		.node10_nicWrEn(node10_nicWrEn),

		.node11_inst_in(node11_inst_in),
		.node11_d_in(node11_d_in),
		.node11_pc_out(node11_pc_out),
		.node11_d_out(node11_d_out),
		.node11_addr_out(node11_addr_out),
		.node11_memWrEn(node11_memWrEn),
		.node11_memEn(node11_memEn),
		.node11_addr_nic(node11_addr_nic),
		.node11_din_nic(node11_din_nic),
		.node11_dout_nic(node11_dout_nic),
		.node11_nicEn(node11_nicEn),
		.node11_nicWrEn(node11_nicWrEn),

		.node12_inst_in(node12_inst_in),
		.node12_d_in(node12_d_in),
		.node12_pc_out(node12_pc_out),
		.node12_d_out(node12_d_out),
		.node12_addr_out(node12_addr_out),
		.node12_memWrEn(node12_memWrEn),
		.node12_memEn(node12_memEn),
		.node12_addr_nic(node12_addr_nic),
		.node12_din_nic(node12_din_nic),
		.node12_dout_nic(node12_dout_nic),
		.node12_nicEn(node12_nicEn),
		.node12_nicWrEn(node12_nicWrEn),

		.node13_inst_in(node13_inst_in),
		.node13_d_in(node13_d_in),
		.node13_pc_out(node13_pc_out),
		.node13_d_out(node13_d_out),
		.node13_addr_out(node13_addr_out),
		.node13_memWrEn(node13_memWrEn),
		.node13_memEn(node13_memEn),
		.node13_addr_nic(node13_addr_nic),
		.node13_din_nic(node13_din_nic),
		.node13_dout_nic(node13_dout_nic),
		.node13_nicEn(node13_nicEn),
		.node13_nicWrEn(node13_nicWrEn),

		.node14_inst_in(node14_inst_in),
		.node14_d_in(node14_d_in),
		.node14_pc_out(node14_pc_out),
		.node14_d_out(node14_d_out),
		.node14_addr_out(node14_addr_out),
		.node14_memWrEn(node14_memWrEn),
		.node14_memEn(node14_memEn),
		.node14_addr_nic(node14_addr_nic),
		.node14_din_nic(node14_din_nic),
		.node14_dout_nic(node14_dout_nic),
		.node14_nicEn(node14_nicEn),
		.node14_nicWrEn(node14_nicWrEn),

		.node15_inst_in(node15_inst_in),
		.node15_d_in(node15_d_in),
		.node15_pc_out(node15_pc_out),
		.node15_d_out(node15_d_out),
		.node15_addr_out(node15_addr_out),
		.node15_memWrEn(node15_memWrEn),
		.node15_memEn(node15_memEn),
		.node15_addr_nic(node15_addr_nic),
		.node15_din_nic(node15_din_nic),
		.node15_dout_nic(node15_dout_nic),
		.node15_nicEn(node15_nicEn),
		.node15_nicWrEn(node15_nicWrEn)
	);


    Mesh_with_NIC mesh16(
		.clk(clk), .reset(reset), .polarity(polarity),

		.nicEn_00(node0_nicEn),
		.nicWrEn_00(node0_nicWrEn),
		.addr_00(node0_addr_nic),
		.d_in_00(node0_din_nic),
		.d_out_00(node0_dout_nic),

		.nicEn_01(node4_nicEn),
		.nicWrEn_01(node4_nicWrEn),
		.addr_01(node4_addr_nic),
		.d_in_01(node4_din_nic),
		.d_out_01(node4_dout_nic),

		.nicEn_02(node8_nicEn),
		.nicWrEn_02(node8_nicWrEn),
		.addr_02(node8_addr_nic),
		.d_in_02(node8_din_nic),
		.d_out_02(node8_dout_nic),

		.nicEn_03(node12_nicEn),
		.nicWrEn_03(node12_nicWrEn),
		.addr_03(node12_addr_nic),
		.d_in_03(node12_din_nic),
		.d_out_03(node12_dout_nic),

		.nicEn_10(node1_nicEn),
		.nicWrEn_10(node1_nicWrEn),
		.addr_10(node1_addr_nic),
		.d_in_10(node1_din_nic),
		.d_out_10(node1_dout_nic),

		.nicEn_11(node5_nicEn),
		.nicWrEn_11(node5_nicWrEn),
		.addr_11(node5_addr_nic),
		.d_in_11(node5_din_nic),
		.d_out_11(node5_dout_nic),

		.nicEn_12(node9_nicEn),
		.nicWrEn_12(node9_nicWrEn),
		.addr_12(node9_addr_nic),
		.d_in_12(node9_din_nic),
		.d_out_12(node9_dout_nic),

		.nicEn_13(node13_nicEn),
		.nicWrEn_13(node13_nicWrEn),
		.addr_13(node13_addr_nic),
		.d_in_13(node13_din_nic),
		.d_out_13(node13_dout_nic),

		.nicEn_20(node2_nicEn),
		.nicWrEn_20(node2_nicWrEn),
		.addr_20(node2_addr_nic),
		.d_in_20(node2_din_nic),
		.d_out_20(node2_dout_nic),

		.nicEn_21(node6_nicEn),
		.nicWrEn_21(node6_nicWrEn),
		.addr_21(node6_addr_nic),
		.d_in_21(node6_din_nic),
		.d_out_21(node6_dout_nic),

		.nicEn_22(node10_nicEn),
		.nicWrEn_22(node10_nicWrEn),
		.addr_22(node10_addr_nic),
		.d_in_22(node10_din_nic),
		.d_out_22(node10_dout_nic),

		.nicEn_23(node14_nicEn),
		.nicWrEn_23(node14_nicWrEn),
		.addr_23(node14_addr_nic),
		.d_in_23(node14_din_nic),
		.d_out_23(node14_dout_nic),

		.nicEn_30(node3_nicEn),
		.nicWrEn_30(node3_nicWrEn),
		.addr_30(node3_addr_nic),
		.d_in_30(node3_din_nic),
		.d_out_30(node3_dout_nic),

		.nicEn_31(node7_nicEn),
		.nicWrEn_31(node7_nicWrEn),
		.addr_31(node7_addr_nic),
		.d_in_31(node7_din_nic),
		.d_out_31(node7_dout_nic),

		.nicEn_32(node11_nicEn),
		.nicWrEn_32(node11_nicWrEn),
		.addr_32(node11_addr_nic),
		.d_in_32(node11_din_nic),
		.d_out_32(node11_dout_nic),

		.nicEn_33(node15_nicEn),
		.nicWrEn_33(node15_nicWrEn),
		.addr_33(node15_addr_nic),
		.d_in_33(node15_din_nic),
		.d_out_33(node15_dout_nic)
	);

endmodule
