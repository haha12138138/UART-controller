`timescale 1ns / 1ps

module baud_cnter
#( parameter PRESCALER_WID = 8
  ,parameter DIVIDER_WID = 2
  ,parameter DIVIDER_CMPVAL =2 
  )
  (
	 input glb_rstn
	,input glb_clk
	,input [PRESCALER_WID-1:0] Cfg_data_cmpval
	,input STM_ctrl_rstn
	,input STM_ctrl_cnt_en
	,output reg baud_ctrl_sample_en
	,output reg baud_ctrl_prescalerout
);
reg [PRESCALER_WID-1:0] prescaler;
reg [DIVIDER_WID-1:0] divider;
always @ (*)
begin
	baud_ctrl_prescalerout=prescaler==Cfg_data_cmpval;
end // always

always @ (*)
begin
	baud_ctrl_sample_en=divider==DIVIDER_CMPVAL;
end // always

always @ (posedge glb_clk or negedge glb_rstn)
begin
	if(~glb_rstn|~STM_ctrl_rstn)
	begin
		prescaler<=0;
	end
	else if(STM_ctrl_cnt_en)
	begin
		prescaler<=(baud_ctrl_prescalerout)?0:prescaler+1;
	end
end

always @ (posedge glb_clk or negedge glb_rstn)
begin
	if(~glb_rstn|~STM_ctrl_rstn)
	begin
		divider<=0;
	end
	else if(baud_ctrl_prescalerout)
	begin
		divider<=divider+1;
	end
end



endmodule     	