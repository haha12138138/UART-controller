`timescale 1ns / 1ps

module Edge_detector (
	 input glb_rstn
	,input glb_clk
	,input sample
	,input usr_data
	,output reg falling
 
);
reg detector;
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
		 detector<=0 ;
	else 
	begin
		detector<=(sample)?usr_data:detector;
	end
end 
always @ (*)
begin
	falling=detector&~usr_data;
end // always

endmodule     	