`timescale 1ns / 1ps

module RX_STM (
	 input glb_rstn
	,input glb_clk
	// from cfg registers
	,input Cfg_ctrl_stopbit
	,input[1:0] Cfg_ctrl_paritybit
	,input Cfg_ctrl_Rx_en
	// to FIFO
	,output reg [7:0] STM_data_payload
	,output reg STM_ctrl_FIFO_w_en
	,input FIFO_ctrl_full
	// from baud cnter
	,input Baud_ctrl_sample_en
	// to baud cnter
	,output reg STM_ctrl_baud_cnt_en
	,output reg STM_ctrl_baud_cnt_rstn
	//from Rx_shift_register
	,input [7:0] Shift_data_payload
	//to Rx_shift_register
	,output reg STM_ctrl_shift_send_en
	//from parity generator
	,input Parity_data_checksum
	//to parity generator
	,output reg [1:0] STM_ctrl_Parity_cfg
	,output reg STM_ctrl_Parity_en
	// from Rx_filter
	,input usr_ctrl_fallingedge
	,input usr_data_rcvbit
);
parameter Finished_a_frame = 4'd14;
parameter Wait_for_transfer = 4'd15;
parameter Init = 4'd0;
parameter Read_start = 4'd1;
parameter Read_1 = 4'd2;
parameter Read_2 = 4'd3;
parameter Read_3 = 4'd4;
parameter Read_4 = 4'd5;
parameter Read_5 = 4'd6;
parameter Read_6 = 4'd7;
parameter Read_7 = 4'd8;
parameter Read_8 = 4'd9;
parameter Read_P = 4'd10;
parameter Read_Stop_2 = 4'd11;
parameter Read_Stop_1 = 4'd12;
parameter Fault = 4'd13;
reg [3:0] state;
reg [3:0] next_state;
always @(negedge glb_rstn or posedge glb_clk)
begin
	if(!glb_rstn) 
		state <= 0;
	else 
	begin
		state<=next_state;
	end
end 
always @ (*)
begin
	STM_ctrl_baud_cnt_rstn=!(state==Finished_a_frame);
end // always

always @ (*)
begin
	case (state) 
	    4'd0    :   begin next_state = (usr_ctrl_fallingedge&Cfg_ctrl_Rx_en)?Read_start:Init; end
	    4'd1    :   begin next_state = (Baud_ctrl_sample_en)?Read_1:Read_start; end
	    4'd2    :   begin next_state = (Baud_ctrl_sample_en)?Read_2:Read_1; end
	    4'd3    :   begin next_state = (Baud_ctrl_sample_en)?Read_3:Read_2; end
	    4'd4    :   begin next_state = (Baud_ctrl_sample_en)?Read_4:Read_3; end
	    4'd5    :   begin next_state = (Baud_ctrl_sample_en)?Read_5:Read_4; end
	    4'd6    :   begin next_state = (Baud_ctrl_sample_en)?Read_6:Read_5; end
	    4'd7    :   begin next_state = (Baud_ctrl_sample_en)?Read_7:Read_6; end
	    4'd8    :   begin next_state = (Baud_ctrl_sample_en)?Read_8:Read_7; end
	    4'd9    :   begin next_state = (Baud_ctrl_sample_en)?Read_P:Read_8; end
	    4'd10   :   begin next_state =(Baud_ctrl_sample_en)?(Parity_data_checksum)?Fault:(Cfg_ctrl_stopbit)?Read_Stop_2:Read_Stop_1:Read_P; end
	    4'd11   :   begin next_state =(Baud_ctrl_sample_en)?(usr_data_rcvbit)?Read_Stop_1:Fault:Read_Stop_2; end
	    4'd12   :   begin next_state =(Baud_ctrl_sample_en)?(usr_data_rcvbit)?Finished_a_frame:Fault:Read_Stop_1; end
	    Fault   :   begin next_state =Init; end
	    Finished_a_frame:begin next_state= (FIFO_ctrl_full)?Wait_for_transfer:Init; end
	    Wait_for_transfer :   begin next_state = (!FIFO_ctrl_full)?Init:Wait_for_transfer; end
	endcase
end // always

always @ (*)
begin
	STM_data_payload=(STM_ctrl_FIFO_w_en)?Shift_data_payload:0;
end // always

always @ (*)
begin
	case(state)
	Init:
	begin
		STM_ctrl_Parity_cfg=Cfg_ctrl_paritybit;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
	end
	Read_start:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
	end
	Read_1,Read_2,Read_3,Read_4,Read_5,Read_6,Read_7,Read_8:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=1;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=1;
		STM_ctrl_baud_cnt_en=1;
	end
	Read_P:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
	end
	Read_Stop_2,Read_Stop_1:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
	end
	Finished_a_frame:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=1;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
	end
	Fault:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
	end
	Wait_for_transfer:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_w_en=1;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
	end
	endcase
end // always

endmodule     	