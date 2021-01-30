`timescale 1ns / 1ps
module Sync_FIFO
#(parameter DEPTH=8,
  parameter WIDTH=8
  )
(
	 input rst_n
	,input clk
	,input [WIDTH-1:0] FIFO_w_data
	,input low_watermark_en
	,input low_watermark_ld_en
	,input [log2(DEPTH)-1:0] low_watermark_i
	,input FIFO_r_en
	,input FIFO_w_en
	,output reg [WIDTH-1:0] FIFO_r_data
	,output reg full
	,output reg empty
);

function integer log2;
  input integer value;
  begin
    value = value-1;
    for (log2=0; value>0; log2=log2+1)
      value = value>>1;
  end
endfunction

reg [WIDTH-1:0] ram[DEPTH-1:0];
reg[log2(DEPTH):0] FIFO_r_addr;
reg[log2(DEPTH):0] FIFO_w_addr;
reg [log2(DEPTH)-1:0] low_watermark;
integer i;
always @(posedge clk)
begin
	if(FIFO_w_en&!full)
	begin
		ram[FIFO_w_addr[log2(DEPTH)-1:0]]<=FIFO_w_data;
	end
end 
always @ (*)
begin
	FIFO_r_data=(FIFO_r_en&!empty)?ram[FIFO_r_addr[log2(DEPTH)-1:0]]:FIFO_r_data;
end // always

always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		low_watermark<=0;
	end
	else 
	begin
		low_watermark<=(low_watermark_ld_en)?FIFO_r_addr+low_watermark_i:low_watermark;
	end
end // always
reg rest_address_equal;
reg guard_bit_equal;
always @ (*)
begin
	rest_address_equal=(FIFO_w_addr[log2(DEPTH)-1:0]==FIFO_r_addr[log2(DEPTH)-1:0]);
	guard_bit_equal=FIFO_w_addr[log2(DEPTH)]^FIFO_r_addr[log2(DEPTH)];
	full=(guard_bit_equal)&(rest_address_equal);
	empty=((low_watermark==FIFO_r_addr[log2(DEPTH)-1:0])&low_watermark_en)|((~guard_bit_equal)&rest_address_equal);
end // always

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		FIFO_w_addr<=0;
	end
	else
	begin
		FIFO_w_addr<=(FIFO_w_en&(!full))?FIFO_w_addr+1:FIFO_w_addr;
	end
end
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		FIFO_r_addr<=0;
	end
	else
	begin
		FIFO_r_addr<=(FIFO_r_en&(!empty))?FIFO_r_addr+1:FIFO_r_addr;
	end
end
endmodule     	