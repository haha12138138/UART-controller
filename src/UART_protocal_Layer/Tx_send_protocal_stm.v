`timescale 1ns / 1ps

module UART_Protocal_Tx_stm (
	 input glb_rstn
	,input glb_clk
	,input CFG_PROT_ctrl_Txen
	,input CFG_PROT_ctrl_empty
	,input USR_PROT_ctrl_cts
	,input CORE_CFG_r_en
	,output reg PROT_CORE_ctrl_Txen
	,output reg PROT_CORE_ctrl_empty
	,output reg[1:0] PROT_CFG_ctrl_Txsel 
	,output reg PROT_CFG_ctrl_tx_r_en
	,output reg PROT_CFG_ctrl_tx_rst
);
reg[1:0] state;
reg[1:0] next_state;
parameter INIT = 0;
parameter SEND_SLAVE_ADDR = 1;
parameter SEND_DATA = 2;
parameter SEND_STOP_FRAME = 3;
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
		state<=INIT;
	else 
	begin
		state<=next_state;
	end
end 
always @ (*)
begin
	case(state)
	INIT:
	begin
		next_state=(CFG_PROT_ctrl_Txen)?SEND_SLAVE_ADDR:INIT;
	end
	SEND_SLAVE_ADDR:
	begin
		next_state=SEND_DATA;
	end
	SEND_DATA:
	begin
		next_state=(CFG_PROT_ctrl_empty)?SEND_STOP_FRAME:SEND_DATA;
	end
	SEND_STOP_FRAME:
	begin
		next_state=(CORE_CFG_r_en)?INIT:SEND_STOP_FRAME;
	end
	endcase
end // always

always @ (*)
begin
	PROT_CORE_ctrl_empty=CFG_PROT_ctrl_empty;
	case(state)
	INIT:
	begin
		PROT_CORE_ctrl_Txen=CFG_PROT_ctrl_Txen;
		PROT_CFG_ctrl_Txsel=0;
		PROT_CFG_ctrl_tx_r_en=0;
		PROT_CFG_ctrl_tx_rst=0;
	end
	SEND_SLAVE_ADDR:
	begin
		PROT_CORE_ctrl_Txen=1;
		PROT_CFG_ctrl_Txsel=0;
		PROT_CFG_ctrl_tx_r_en=0;
		PROT_CFG_ctrl_tx_rst=0;
	end
	SEND_DATA:
	begin
		PROT_CORE_ctrl_Txen=1;
		PROT_CFG_ctrl_Txsel=1;
		PROT_CFG_ctrl_tx_r_en=CORE_CFG_r_en&!CFG_PROT_ctrl_empty;
		PROT_CFG_ctrl_tx_rst=0;
	end
	SEND_STOP_FRAME:
	begin
		PROT_CORE_ctrl_Txen=1;
		PROT_CFG_ctrl_Txsel=2;
		PROT_CFG_ctrl_tx_r_en=0;
		PROT_CFG_ctrl_tx_rst=CORE_CFG_r_en;
	end
	endcase
end // always

endmodule     	