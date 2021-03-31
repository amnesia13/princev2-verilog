//-- $Id: tb.v,v 1.1 2021/01/04 09:36:26 brunom Exp $

`timescale 1ns/10ps

module tb();

`include "tb_features.v" 

parameter TICK = 100;

//-- to IP
reg ARESETN;  //-- asynchronous, active at low level
reg ACLK;
reg [DATA_SIZE-1:0] S_AXIS_TDATA;

//-- from IP
wire [DATA_SIZE-1:0] M_AXIS_TDATA;

wire CLK_MASK;

initial begin
  $dumpfile ("tb.vcd");
  $dumpvars;
end

initial begin
ARESETN = 1;
#(TICK * 10);
ARESETN = 0;
#(TICK * 10);
ARESETN = 1;
#(TICK * 300);
$finish;
end

assign #(TICK/2) CLK_MASK = ~ARESETN;

always @(*)
 ACLK <= #(TICK/2) ~ACLK & CLK_MASK;

axi_stream_wrapper i_axi_stream_wrapper (
	//-- inputs
	.ACLK(ACLK),
	.ARESETN(ARESETN),
	.S_AXIS_TDATA(S_AXIS_TDATA),
	.S_AXIS_TLAST(S_AXIS_TLAST),
	.M_AXIS_TREADY(M_AXIS_TREADY),
	.S_AXIS_TVALID(S_AXIS_TVALID),
	//-- outputs
	.M_AXIS_TVALID(M_AXIS_TVALID),
	.M_AXIS_TLAST(M_AXIS_TLAST),
	.M_AXIS_TDATA(M_AXIS_TDATA),
	.S_AXIS_TREADY(S_AXIS_TREADY)
	);

endmodule
