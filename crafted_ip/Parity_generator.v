`timescale 1ns / 1ps

module Parity_generator (
	input clk
	,input data_in
	,input [1:0] Parity_ld_cfg
	,input Parity_calc_en
	,output reg Parity_o
);
wire Parity_ld_en;
wire Parity_cfg;
reg Parity;
assign Parity_ld_en = Parity_ld_cfg[0];
assign Parity_cfg = Parity_ld_cfg[1];
always @(negedge Parity_ld_en or posedge clk)
begin
	if(Parity_ld_en) 
		 Parity<= Parity_cfg;// 0 Even 1 Odd
	else 
	begin
		Parity<=(Parity_calc_en)?Parity^data_in:Parity;
	end
end 
always @ (*)
begin
	Parity_o=Parity;
end // always

endmodule     	