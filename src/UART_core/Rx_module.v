`timescale 1ns / 1ps

module UART_Rx_module (
	  input glb_rstn 
	, input glb_clk 
	, input Cfg_ctrl_stopbit 
	, input[1:0] Cfg_ctrl_paritybit 
	, input Cfg_ctrl_Rx_en 
	, input usr_data_rcvbit 
	, input FIFO_ctrl_full
	, output [7:0] UART_Rx_data_payload 
	, output UART_ctrl_FIFO_w_en
);
wire Sample_en;
wire [7:0] shift_data_rcvdata;
wire Rx_shift_en_o;
wire Rx_cnt_en;
wire Parity_i;
wire [1:0] Parity_ld_cfg_o;
wire Parity_calc_en;
wire cnt_ld_en;
wire baud_ctrl_prescalerout;
wire Edge_ctrl_fallingedge;
RX_STM STM(glb_rstn,glb_clk
			,Cfg_ctrl_stopbit,Cfg_ctrl_paritybit,Cfg_ctrl_Rx_en,
			UART_Rx_data_payload,UART_ctrl_FIFO_w_en,FIFO_ctrl_full,
			Sample_en&baud_ctrl_prescalerout,
			Rx_cnt_en,
			cnt_ld_en,
			shift_data_rcvdata,
			Rx_shift_en_o,
			Parity_i^usr_data_rcvbit,
			Parity_ld_cfg_o,
			Parity_calc_en,
			Edge_ctrl_fallingedge,
			usr_data_rcvbit);
wire cnt_full;
baud_cnter #(8,2,1) Rx_cnter(glb_rstn,glb_clk
					,8'b10
					,cnt_ld_en,Rx_cnt_en
					,Sample_en,baud_ctrl_prescalerout);
Edge_detector Edge(glb_rstn,glb_clk
					  ,1'b1
					  ,usr_data_rcvbit
					  ,Edge_ctrl_fallingedge);
//count_cmp #(0,3,2,1,0) Rx_cnt (glb_rstn,baud_clk,Rx_cnt_en,cnt_ld_en,cnt_full,Sample_en);
Parity_generator Parity_gen(glb_clk,
							usr_data_rcvbit,
							Parity_ld_cfg_o,Parity_calc_en&Sample_en&baud_ctrl_prescalerout,
							Parity_i);
Shift_Register Rx_reg(glb_rstn,glb_clk,1'b0,Rx_shift_en_o&Sample_en&baud_ctrl_prescalerout,usr_data_rcvbit,8'b0,shift_data_rcvdata,);

endmodule     	