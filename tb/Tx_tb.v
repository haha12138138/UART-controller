`timescale 1ns / 1ps
module Tx_tb;
/*
reg glb_rstn;
reg glb_clk;
reg Stop_cfg_i;
reg[1:0] Parity_cfg_i;
reg Tx_en;
wire Sample_en;
wire [7:0] Tx_data_o;//to shift reg
wire FIFO_r_en;
reg [7:0] Tx_data_i;
wire Tx_shift_en_o;
wire Tx_cnt_en;
wire Parity;
wire [1:0] Parity_ld_cfg_o;
wire Parity_calc_en;
wire Tx_reg_bit;
wire Tx_bit_out;
wire Tx_LD_en;
wire [1:0] Tx_outsel;
TX_STM STM2(glb_rstn,glb_clk
	       ,Stop_cfg_i,Parity_cfg_i,Tx_en
	       ,Tx_data_i,FIFO_r_en
	       ,Sample_en,Tx_cnt_en
	       ,Tx_data_o,Tx_shift_en_o,Tx_LD_en
	       ,Parity_ld_cfg_o,Parity_calc_en
	       ,Tx_outsel);
wire cnt_full;
wire [7:0] Tx_Parallel_out;
count_cmp #(0,3,2,3,0)
		 Rx_cnt (glb_rstn,glb_clk,Tx_cnt_en,cnt_full,Sample_en);
Shift_Register Rx_reg(glb_rstn,glb_clk,
					Tx_LD_en,Tx_shift_en_o,
					1'b0,Tx_data_o,
					Tx_Parallel_out,Tx_reg_bit);
Parity_generator Parity_gen(glb_clk,Tx_reg_bit,Parity_ld_cfg_o,Parity_calc_en,Parity);
Tx_outsel sel(Tx_outsel,Tx_reg_bit,Parity,Tx_bit_out);*/
reg glb_rstn,glb_clk,Stop_cfg_i,Tx_en;
reg [1:0] Parity;
reg [7:0] Tx_data_i;
reg FIFO_ctrl_empty;
wire outputsel_data_bit;
wire STM_ctrl_FIFO_r_en;
UART_Tx_module Tx(glb_rstn,glb_clk
				 ,Stop_cfg_i,Parity,Tx_en,Tx_data_i,
				 FIFO_ctrl_empty,outputsel_data_bit
				 ,STM_ctrl_FIFO_r_en);

initial begin
	Stop_cfg_i =1 ;
	Parity=2'b01;
	Tx_en=0;
	#5 Tx_en=1;
end // initial

initial begin
	#0 glb_rstn = 0;
	#5 glb_rstn =1;
end // initial

initial begin
	#0 glb_clk=0;
	forever begin
	    #10 glb_clk = ~glb_clk;
	end // forever 
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