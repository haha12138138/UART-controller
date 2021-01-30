`timescale 1ns / 1ps

module UART_protocal_cfg (
	 input glb_rstn
	,input glb_clk
	,input [4:0] usr_data_addr
	,input [7:0] usr_data_cfgdata
	,input 		 usr_ctrl_wnr
	,input PROT_CFG_ctrl_tx_rst
	,input PROT_CFG_ctrl_rx_rst
	,input PROT_CFG_ctrl_tx_r_en
	,input PROT_CFG_ctrl_rx_w_en
	,input [1:0]PROT_CFG_ctrl_Txsel
	,output [7:0]CFG_SEL_data_tx_data 
	,output [7:0]CFG_USR_data_rx_data
	,output Tx_FIFO_full
	,output Tx_FIFO_empty
	,output Rx_FIFO_full
	,output Rx_FIFO_empty
	,output parity_cfg
	,output stop_cfg
	,output CFG_PROT_ctrl_Txen
	,output CFG_PROT_ctrl_rxen
);

reg Tx_en;				//0
reg Rx_en;				//1	
assign CFG_PROT_ctrl_Txen=Tx_en;
assign CFG_PROT_ctrl_rxen=Rx_en;
reg [7:0] slave_addr;	//2
reg [7:0] stop_frame;
reg [7:0] self_addr;
reg [7:0] baud_cmpval;	//5
//6 Tx FIFO 
//7 Rx FIFO
reg parity_cfg_reg;//8 parity cfg
reg stop_cfg_reg;//9 stop cfg
assign parity_cfg=parity_cfg_reg;
assign stop_cfg = stop_cfg_reg;
reg TX_FIFO_w_en;
reg RX_FIFO_r_en;
reg [9:0] decoder_ctrl_addr;

always @ (*)
begin
	decoder_ctrl_addr=(1<<(usr_data_addr));
end // always

always @(*)
begin
	TX_FIFO_w_en=usr_ctrl_wnr&decoder_ctrl_addr[6];
	RX_FIFO_r_en=(!usr_ctrl_wnr)&decoder_ctrl_addr[7];
end
Sync_FIFO TX_FIFO(glb_rstn,glb_clk
				 ,usr_data_cfgdata,1'b0,1'b0,3'b0
				 ,PROT_CFG_ctrl_tx_r_en,TX_FIFO_w_en,CFG_SEL_data_tx_data
				 ,Tx_FIFO_full,Tx_FIFO_empty);
Sync_FIFO RX_FIFO(glb_rstn,glb_clk
				 ,usr_data_cfgdata,1'b0,1'b0,3'b0
				 ,RX_FIFO_r_en,PROT_CFG_ctrl_rx_w_en,CFG_USR_data_rx_data
				 ,Rx_FIFO_full,Rx_FIFO_empty);
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
	begin
		slave_addr<=0;
		stop_frame<=0;
		self_addr<=0;
		baud_cmpval<=0;
	end
	else if(usr_ctrl_wnr) 
	begin
		casex(decoder_ctrl_addr[5:2])
		4'bxxx1:
		begin
		slave_addr<=usr_data_cfgdata;
		end
		4'bxx1x:
		begin
		self_addr<=usr_data_cfgdata;
		end
		4'bx1xx:
		begin
		stop_frame<=usr_data_cfgdata;
		end
		4'b1xxx:
		begin
		baud_cmpval<=usr_data_cfgdata;
		end
		endcase
	end
end 
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
	begin
		stop_cfg_reg<=0;
	end
	else 
	begin
		if (decoder_ctrl_addr[9]&usr_ctrl_wnr)
 		begin
 			stop_cfg_reg<=usr_data_cfgdata[0];
 		end
	end
end
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
	begin
		parity_cfg_reg<=0;
	end
	else 
	begin
		if (decoder_ctrl_addr[8]&usr_ctrl_wnr)
 		begin
 			parity_cfg_reg<=usr_data_cfgdata[0];
 		end
	end
end 
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
	begin
		Tx_en<=0;
	end
	else 
	begin
		if(PROT_CFG_ctrl_tx_rst)
		begin
			Tx_en<=0;
		end
		else if (decoder_ctrl_addr[0]&usr_ctrl_wnr)
 		begin
 			Tx_en<=1;
 		end
	end
end 

always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
	begin
		Rx_en<=0;
	end
	else 
	begin
		if(PROT_CFG_ctrl_rx_rst)
		begin
			Rx_en<=0;
		end
		else if (decoder_ctrl_addr[1]&usr_ctrl_wnr)
 		begin
 			Rx_en<=1;
 		end
	end
end 
endmodule     	