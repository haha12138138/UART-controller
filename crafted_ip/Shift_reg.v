`timescale 1ns / 1ps
module Shift_Register
#(parameter DEPTH =8
)
(
	 input rst_n
	,input clk
	,input Ld_en
	,input Shift_en
	,input Serial_in
	,input [DEPTH-1:0] Parallel_in
	,output reg [DEPTH-1:0] Parallel_out
	,output reg Serial_out 
);
reg [DEPTH-1:0] shift_reg;

always @ (posedge clk)
begin
	if(Ld_en)
	begin
		shift_reg<=Parallel_in;
	end
	else if(Shift_en)
	begin
		shift_reg<={shift_reg[DEPTH-2:0],Serial_in};
	end
end
always @ (*)
begin
	Parallel_out=shift_reg;
	Serial_out=shift_reg[DEPTH-1];
end // always

endmodule     	