`timescale 1ns / 1ps
module Rx_tb;
/*
reg glb_rstn;
reg glb_clk;
reg Stop_cfg_i;
reg[1:0] Parity_cfg_i;
reg Rx_en;
wire Sample_en;
wire [7:0] Rx_data_o;
wire FIFO_w_en;
wire [7:0] Rx_data_i;
wire Rx_shift_en_o;
wire Rx_cnt_en;
wire Parity_i;
wire [1:0] Parity_ld_cfg_o;
wire Parity_calc_en;
reg Rx_bit;

RX_STM STM(glb_rstn glb_clk Stop_cfg_i Parity_cfg_i Rx_en,
			Rx_data_o FIFO_w_en,
			Sample_en,
			Rx_cnt_en,
			Rx_data_i,
			Rx_shift_en_o,
			Parity_i,
			Parity_ld_cfg_o,
			Parity_calc_en,
			Rx_bit);
wire cnt_full;
count_cmp #(0 3 2 1 0) Rx_cnt (glb_rstn glb_clk Rx_cnt_en cnt_full Sample_en);
Parity_generator Parity_gen(glb_clk Rx_bit Parity_ld_cfg_o Parity_calc_en Parity_i);
Shift_Register Rx_reg(glb_rstn glb_clk 1'b0 Rx_shift_en_o Rx_bit 8'b0 Rx_data_i,);
initial begin
	Stop_cfg_i =1 ;
	Parity_cfg_i=2'b01;
	Rx_en=1;
end // initial
*/
reg glb_rstn;
reg glb_clk; 
reg Cfg_ctrl_stopbit; 
reg[1:0] Cfg_ctrl_paritybit; 
reg Cfg_ctrl_Rx_en; 

reg FIFO_ctrl_full;
wire [7:0] UART_Rx_data_payload; 
wire UART_ctrl_FIFO_w_en;
reg Stop_cfg_i,Tx_en;
reg [1:0] Parity;
reg [7:0] Tx_data_i;
reg FIFO_ctrl_empty;
wire outputsel_data_bit;
wire STM_ctrl_FIFO_r_en;
UART_Rx_module Rx(
	glb_rstn 
	,glb_clk 
	,Cfg_ctrl_stopbit 
	,Cfg_ctrl_paritybit 
	,Cfg_ctrl_Rx_en 
	,outputsel_data_bit 
	,FIFO_ctrl_full
	,UART_Rx_data_payload 
	,UART_ctrl_FIFO_w_en
);
UART_Tx_module Tx(glb_rstn,glb_clk
				 ,Stop_cfg_i,Parity,Tx_en,Tx_data_i,
				 FIFO_ctrl_empty,outputsel_data_bit
				 ,STM_ctrl_FIFO_r_en);
initial begin
	#0 glb_rstn = 0;
	Cfg_ctrl_stopbit=1;
	Cfg_ctrl_paritybit=2'b01;
	Cfg_ctrl_Rx_en=1;
	FIFO_ctrl_full=0;
	#5 glb_rstn =1;
end // initial

initial begin
	#0 glb_clk=0;
	forever begin
	    #10 glb_clk = ~glb_clk;
	end // forever 
end // initial



initial begin
	Stop_cfg_i =1 ;
	Parity=2'b01;
	Tx_en=0;
	#50 Tx_en=1;
end // initial

integer i;
always @ (posedge glb_clk or negedge glb_rstn)
begin
	if(~glb_rstn)
	begin
		Tx_data_i=8'b11011110;
		i=0;
		FIFO_ctrl_empty=0;

	end
	else
	begin
		if (STM_ctrl_FIFO_r_en==1)
		begin
			Tx_data_i<=Tx_data_i+1;
			i<=i+1;
		end
		
		if(i==4)
		begin
			FIFO_ctrl_empty=1;

			#1000 $stop;
		end

	end
end

endmodule