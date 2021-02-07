`timescale 1ns / 1ps

module UART_core (
	 input glb_rstn
	,input glb_clk
	,input Cfg_ctrl_stopbit
	,input[1:0]Cfg_ctrl_paritybit
	,input Cfg_ctrl_Rx_en
	,input Cfg_ctrl_Tx_en
	,input FIFO_ctrl_full
	,input FIFO_ctrl_empty
	,output [7:0]UART_Rx_data_payload
	,output UART_ctrl_FIFO_w_en
	,input [7:0]UART_Tx_data_payload
	,output UART_ctrl_FIFO_r_en
	,input UART_RX_data_bit
	,output UART_Tx_data_bit
);
UART_Rx_module Rx(
	glb_rstn 
	,glb_clk 
	,Cfg_ctrl_stopbit 
	,Cfg_ctrl_paritybit 
	,Cfg_ctrl_Rx_en 
	,UART_RX_data_bit 
	,FIFO_ctrl_full
	,UART_Rx_data_payload 
	,UART_ctrl_FIFO_w_en
);
UART_Tx_module Tx(
	glb_rstn
	,glb_clk
	,Cfg_ctrl_stopbit
	,Cfg_ctrl_paritybit
	,Cfg_ctrl_Tx_en
	,UART_Tx_data_payload
	,FIFO_ctrl_empty
	,UART_Tx_data_bit
	,UART_ctrl_FIFO_r_en
);
endmodule     	