`timescale 1ns / 1ps

module count_cmp
#(
  parameter RSTVAL=23,
  parameter MAXVAL=23,
  parameter LEN =5,
  parameter CMPVAL =22,
  parameter mode =0 // upcount
) (
	 input rst_n
	,input clk
	,input cnt_en
	,input ld_en
	,output cnt_full
	,output cmp_matched
);
wire [LEN-1:0] cnt_val;
generate
	if(mode == 0)
	begin
		up_cnt_w_init #(RSTVAL,MAXVAL,LEN)
		cnt(rst_n,clk,cnt_en,ld_en,cnt_val,cnt_full);
	end
endgenerate
assign cmp_matched =(cnt_val==CMPVAL) ;
endmodule     	