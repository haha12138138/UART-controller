`timescale 1ns / 1ps

module UART_Tx_module (
	 input glb_rstn 
	,input glb_clk 
	,input Cfg_ctrl_stopbit 
	,input[1:0] Cfg_ctrl_paritybit 
	,input Cfg_ctrl_Tx_en 
	,input [7:0] FIFO_data_payload 
	,input FIFO_ctrl_empty
	,output outputsel_data_bit
	,output STM_ctrl_FIFO_r_en
);
wire baud_ctrl_sample_en;
wire [7:0] STM_data_payload;//to shift reg
wire STM_ctrl_shift_send_en;
wire STM_ctrl_baud_cnt_en;
wire Parity_data;
wire [1:0] STM_ctrl_Parity_cfg;
wire STM_ctrl_Parity_en;
wire Shift_data_bit;
wire baud_ctrl_prescaler;
wire STM_ctrl_shift_ld_en;
wire [1:0] STM_ctrl_outputsel;
TX_STM STM2(glb_rstn,glb_clk
	       ,Cfg_ctrl_stopbit,Cfg_ctrl_paritybit,Cfg_ctrl_Tx_en
	       ,FIFO_data_payload,FIFO_ctrl_empty,STM_ctrl_FIFO_r_en
	       ,baud_ctrl_sample_en&baud_ctrl_prescaler,STM_ctrl_baud_cnt_en,STM_ctrl_baud_cnt_rstn
	       ,STM_data_payload,STM_ctrl_shift_send_en,STM_ctrl_shift_ld_en
	       ,STM_ctrl_Parity_cfg,STM_ctrl_Parity_en
	       ,STM_ctrl_outputsel);
wire cnt_full;
wire [7:0] Tx_Parallel_out;
baud_cnter cnt1(glb_rstn,glb_clk
			    ,8'b10
			    ,STM_ctrl_baud_cnt_rstn,STM_ctrl_baud_cnt_en
			    ,baud_ctrl_sample_en,baud_ctrl_prescaler);

Shift_Register Rx_reg(glb_rstn,glb_clk,
					STM_ctrl_shift_ld_en,STM_ctrl_shift_send_en&baud_ctrl_sample_en&baud_ctrl_prescaler,
					1'b0,STM_data_payload,
					Tx_Parallel_out,Shift_data_bit);
Parity_generator Parity_gen(glb_clk
						   ,Shift_data_bit
						   ,STM_ctrl_Parity_cfg,STM_ctrl_Parity_en&baud_ctrl_sample_en&baud_ctrl_prescaler
						   ,Parity_data
						   );
Tx_outputsel sel(STM_ctrl_outputsel,Shift_data_bit,Parity_data,outputsel_data_bit);


endmodule     	