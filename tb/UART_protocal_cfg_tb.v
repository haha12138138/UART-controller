`timescale 1ns / 1ps
module UART_protocal_cfg_tb;

reg glb_rstn;
reg glb_clk;
reg [4:0] usr_data_addr;
reg [7:0] usr_data_cfgdata;
reg 	  usr_ctrl_wnr;
wire PROT_CFG_ctrl_tx_rst;
wire PROT_CFG_ctrl_rx_rst;
wire PROT_CFG_ctrl_tx_r_en;
reg PROT_CFG_ctrl_rx_w_en;
wire [7:0]CFG_SEL_data_tx_data; 
wire [7:0]CFG_USR_data_rx_data;
wire Tx_FIFO_full;
wire Tx_FIFO_empty;
wire Rx_FIFO_full;
wire Rx_FIFO_empty;
wire parity_cfg;
wire stop_cfg;
wire[1:0]PROT_CFG_ctrl_Txsel ;
reg USR_PROT_ctrl_cts;
reg CORE_CFG_r_en;
wire PROT_CORE_ctrl_Txen;
wire PROT_CORE_ctrl_empty;
wire CFG_PROT_ctrl_Rxen;
UART_protocal_cfg cfg_regfile(glb_rstn,glb_clk
							  ,usr_data_addr,usr_data_cfgdata,usr_ctrl_wnr
							  ,PROT_CFG_ctrl_tx_rst,PROT_CFG_ctrl_rx_rst,PROT_CFG_ctrl_tx_r_en,PROT_CFG_ctrl_rx_w_en
							  ,PROT_CFG_ctrl_Txsel
							  ,CFG_SEL_data_tx_data,CFG_USR_data_rx_data
							  ,Tx_FIFO_full,Tx_FIFO_empty,Rx_FIFO_full,Rx_FIFO_empty
							  ,parity_cfg,stop_cfg,CFG_PROT_ctrl_Txen,CFG_PROT_ctrl_Rxen);


UART_Protocal_Tx_stm Tx_stm(glb_rstn,glb_clk
							,CFG_PROT_ctrl_Txen,Tx_FIFO_empty
							,USR_PROT_ctrl_cts
							,CORE_CFG_r_en
							,PROT_CORE_ctrl_Txen,PROT_CORE_ctrl_empty
							,PROT_CFG_ctrl_Txsel,PROT_CFG_ctrl_tx_r_en,PROT_CFG_ctrl_tx_rst);

/*glb initalization*/
initial begin
	# 0 glb_rstn=0 ;
	#15 glb_rstn=1;
end // initial
initial begin
	#0 glb_clk=0;
	forever begin
	    #10 glb_clk=~glb_clk ;
	end // forever 
end // initial
/*usr behavior*/
integer i;
always @ (posedge glb_clk or negedge glb_rstn)
	begin
		if(~glb_rstn)
		begin
			i<=0;
		end
		else
		begin
			i<=i+1;
		end
	end	
always @ (*)
begin
	case(i)
	0:
	begin
		usr_data_addr=0;
		usr_data_cfgdata=0;
		usr_ctrl_wnr=0;
	end
	1:/*write slave addr*/
	begin
		usr_data_addr=2;
		usr_data_cfgdata=8'b10011;
		usr_ctrl_wnr=1;
	end
	2:/*write self addr*/
	begin
		usr_data_addr=3;
		usr_data_cfgdata=8'b10010;
		usr_ctrl_wnr=1;
	end
	3:/*write stop frame*/
	begin
		usr_data_addr=4;
		usr_data_cfgdata=8'b1001111;
		usr_ctrl_wnr=1;
	end
	4:/*write baudcmpval*/
	begin
		usr_data_addr=5;
		usr_data_cfgdata=8'b1001000;
		usr_ctrl_wnr=1;
	end
	5,6,7,8,9,10,11,12,13:
	begin
		usr_data_addr=6;
		usr_data_cfgdata=i[7:0];
		usr_ctrl_wnr=1;
	end
	14:/*enable Tx*/
	begin
		usr_data_addr=0;
		usr_data_cfgdata=1;
		usr_ctrl_wnr=1;
	end
	15:
	begin
		usr_data_addr=1;
		usr_data_cfgdata=1;
		usr_ctrl_wnr=0;
	end
	300:
	begin
		$stop;
	end
	endcase
end // always
always @ (posedge glb_clk or negedge glb_rstn)
	begin
		if(~glb_rstn)
		begin
			CORE_CFG_r_en=0;
		end
		else if(i%10==0 && i!=0)
		begin
			CORE_CFG_r_en=1;
		end
		else
		begin
			CORE_CFG_r_en=0;
		end
			
	end	

endmodule