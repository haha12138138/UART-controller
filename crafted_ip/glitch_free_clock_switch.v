`timescale 1ns / 1ps

module glitch_free_clk_switch (
	 input rst_n
	,input clka
	,input clkb
	,input sel
	,output reg clko 
);
reg [1:0] clka_buff;
reg [1:0] clkb_buff;

always @(negedge rst_n or posedge clka)
begin
	if(!rst_n) 
	begin
		clka_buff<=2'b11;
	end
	else 
	begin
		clka_buff<={clka_buff[0],((!sel)&(!clkb_buff[1]))};
	end
end 
always @(negedge rst_n or posedge clkb)
begin
	if(!rst_n) 
	begin
		clkb_buff<=2'b00;
	end
	else 
	begin
		clkb_buff<={clkb_buff[0],(sel)&(!clka_buff[1])};
	end
end 
always @ (*)
begin
	case({clka_buff[1],clkb_buff[1]})
	0,3:
	begin
		clko=1;
	end
	1:
	begin
		clko=clka;
	end
	2:
	begin
		clko=clkb;
	end
	endcase
end // always

endmodule     	