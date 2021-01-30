`timescale 1ns / 1ps
module UART_tb;
reg rst_n;
reg clk;
reg Stop_cfg_i; 
reg[1:0] Parity_cfg_i; 
reg Tx_en; 
reg [7:0] Tx_data_i; 
reg Rx_en; 

wire [7:0] Rx_data_o; 
wire Tx_bit_out;
wire Tx_baud_clk,Rx_baud_clk;
UART_Tx_module Tx(rst_n,clk,Tx_baud_clk
				  ,Stop_cfg_i,Parity_cfg_i,Tx_en,Tx_data_i,Tx_bit_out);
UART_Rx_module Rx(rst_n,clk,Rx_baud_clk
				  ,Stop_cfg_i,Parity_cfg_i,Rx_en,Tx_bit_out,Rx_data_o);

count_cmp Tx_baud_counter(rst_n,clk,1'b1,1'b0,,Tx_baud_clk);
count_cmp Rx_baud_counter(rst_n,clk,1'b1,1'b0,,Rx_baud_clk);
initial begin
	Stop_cfg_i =1 ;
	Parity_cfg_i=2'b01;
	Tx_en=0;
	Rx_en=1;
	#5 Tx_en=1;
end // initial
initial begin
	#0 rst_n = 0;
	#5 rst_n =1;
end // initial

initial begin
	#0 clk=0;
	forever begin
	    #10 clk = ~clk;
	end // forever 
end // initial

integer i;
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		Tx_data_i=8'b11011010;
		i=0;
	end
	else
	begin
		i=i+1;
		if (i==14*4)
		begin
			$stop;
		end
	end
end
endmodule