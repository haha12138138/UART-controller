`timescale 1ns / 1ps

module Send_protocal_STM (
	 input glb_rstn
	,input glb_clk
	,input FIFO_ctrl_empty
	,input Cfg_ctrl_protocal_en
	,input Cfg_ctrl_Tx_en
	,input UART_core_ctrl_FIFO_r_en
	,output reg PROT_STM_ctrl_empty
	,output reg PROT_STM_ctrl_FIFO_r_en
	,output reg [1:0] PROT_STM_data_senddata
);
parameter No_protocal_idle = 0;
parameter No_protocal_send = 5;
parameter With_protocal_idle = 1;
parameter Send_Address = 2;
parameter Send_Payload = 3;
parameter Send_Endframe = 4;

parameter Send_FIFO_sel = 0;
parameter Send_Address_sel = 1;
parameter Send_Payload_sel = 2;
parameter Send_Endframe_sel = 3;

reg [2:0] Protocal_STM;
reg [2:0] next_state;
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n) 
		 Protocal_STM<=No_protocal  ;
	else 
	begin
		Protocal_STM<=next_state;
	end
end 

always @ (*)
begin
	case(Protocal_STM)
	No_protocal:
	begin
		next_state=(Cfg_ctrl_protocal_en)?With_protocal_idle:No_protocal;
	end
	With_protocal_idle:
	begin
		next_state=(Cfg_ctrl_protocal_en)?(Cfg_ctrl_Tx_en&!FIFO_ctrl_empty)?Send_Address:With_protocal_idle:No_protocal;
	end
	Send_Address:
	begin
		next_state=(UART_core_ctrl_FIFO_r_en)?Send_Payload:Send_Address;
	end
	Send_Payload:
	begin
		next_state=(FIFO_ctrl_empty)?Send_Endframe:Send_Payload;
	end
	Send_Endframe:
	begin
		next_state=(UART_core_ctrl_FIFO_r_en)?With_protocal_idle:Send_Endframe;
	end
	endcase
end // always

always @ (*)
begin
	case(Protocal_STM)
	No_protocal:
	begin
		PROT_STM_ctrl_empty=FIFO_ctrl_empty;
		PROT_STM_ctrl_FIFO_r_en=UART_core_ctrl_FIFO_r_en;
		PROT_STM_data_senddata=Send_Payload_sel;
	end
	With_protocal_idle:
	begin
		PROT_STM_ctrl_empty=FIFO_ctrl_empty;
		PROT_STM_ctrl_FIFO_r_en=0;
		PROT_STM_data_senddata=Send_Payload_sel;
	end
	Send_Address:
	begin
		PROT_STM_ctrl_empty=FIFO_ctrl_empty;
		PROT_STM_ctrl_FIFO_r_en=0;
		PROT_STM_data_senddata=Send_Address_sel;
	end
	Send_Payload:
	begin
		PROT_STM_ctrl_empty=0;
		PROT_STM_ctrl_FIFO_r_en=UART_core_ctrl_FIFO_r_en;
		PROT_STM_data_senddata=Send_Payload_sel;
	end
	Send_Endframe:
	begin
		PROT_STM_ctrl_empty=0;
		PROT_STM_ctrl_FIFO_r_en=0;
		PROT_STM_data_senddata=Send_Endframe_sel;
	end
	endcase
end // always

endmodule     	