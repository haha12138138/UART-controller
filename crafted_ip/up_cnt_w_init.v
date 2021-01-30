`timescale 1ns / 1ps

module up_cnt_w_init
#(
  parameter RSTVAL=0,
  parameter MAXVAL=0,
  parameter LEN =5 
 )
(
	 input rst_n
	,input clk
	,input cnt_en
	,input ld_en
	,output reg [LEN-1:0] cnt_val
	,output reg cnt_full
);
reg [LEN-1:0] cnt;
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n |ld_en) 
		 cnt<=RSTVAL ;
	else if(cnt_full & cnt_en)
	begin
		cnt<=0;
	end
	else if(cnt_en)
	begin
		cnt<=cnt+1;
	end
	else
	begin
		cnt<=cnt;
	end
end 
always @ (*)
begin
	cnt_val=cnt;
end // always
always @ (*)
begin
	cnt_full=cnt==MAXVAL;
end // always


endmodule     	