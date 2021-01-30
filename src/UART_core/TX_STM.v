`timescale 1ns / 1ps

module TX_STM (
	 input rst_n
	,input clk
	// from cfg registers
	,input Cfg_ctrl_stopbit
	,input[1:0] Cfg_ctrl_paritybit
	,input Cfg_ctrl_Tx_en
	//from FIFO
	,input [7:0] FIFO_data_payload
	,input FIFO_ctrl_empty
	// to FIFO
	,output reg STM_ctrl_FIFO_r_en
	// from baud cnter
	,input Baud_ctrl_sample_en
	// to baud cnter
	,output reg STM_ctrl_baud_cnt_en
	,output reg STM_ctrl_baud_cnt_rstn
	//to tx_shift_register
	,output reg [7:0] STM_data_payload
	,output reg STM_ctrl_shift_send_en
	,output reg STM_ctrl_shift_ld_en
	//to parity generator
	,output reg [1:0] STM_ctrl_Parity_cfg
	,output reg STM_ctrl_Parity_en
	//to Tx data generator
	,output reg [1:0] STM_ctrl_outputsel
);
parameter Finished = 4'd14;
parameter LD_Tx_Reg = 4'd0;
parameter Send_start = 4'd1;
parameter Send_1 = 4'd2;
parameter Send_2 = 4'd3;
parameter Send_3 = 4'd4;
parameter Send_4 = 4'd5;
parameter Send_5 = 4'd6;
parameter Send_6 = 4'd7;
parameter Send_7 = 4'd8;
parameter Send_8 = 4'd9;
parameter Send_P = 4'd10;
parameter Send_Stop_2 = 4'd11;
parameter Send_Stop_1 = 4'd12;

reg [3:0] state;
reg [3:0] next_state;
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n) 
		state <= Finished;
	else 
	begin
		state<=next_state;
	end
end 
always @ (*)
begin
	case (state) 
	    4'd0    :   begin next_state = Send_start; end
	    4'd1    :   begin next_state = (Baud_ctrl_sample_en)?Send_1:Send_start; end
	    4'd2    :   begin next_state = (Baud_ctrl_sample_en)?Send_2:Send_1; end
	    4'd3    :   begin next_state = (Baud_ctrl_sample_en)?Send_3:Send_2; end
	    4'd4    :   begin next_state = (Baud_ctrl_sample_en)?Send_4:Send_3; end
	    4'd5    :   begin next_state = (Baud_ctrl_sample_en)?Send_5:Send_4; end
	    4'd6    :   begin next_state = (Baud_ctrl_sample_en)?Send_6:Send_5; end
	    4'd7    :   begin next_state = (Baud_ctrl_sample_en)?Send_7:Send_6; end
	    4'd8    :   begin next_state = (Baud_ctrl_sample_en)?Send_8:Send_7; end
	    4'd9    :   begin next_state = (Baud_ctrl_sample_en)?Send_P:Send_8; end
	    4'd10    :  begin next_state =(Baud_ctrl_sample_en)?(Cfg_ctrl_stopbit)?Send_Stop_2:Send_Stop_1:Send_P; end
	    4'd11    :  begin next_state =(Baud_ctrl_sample_en)?Send_Stop_1:Send_Stop_2; end
	    4'd12    :  begin next_state =(Baud_ctrl_sample_en)?(FIFO_ctrl_empty)?Finished:LD_Tx_Reg:Send_Stop_1; end
	    Finished:	begin next_state=(Cfg_ctrl_Tx_en&!FIFO_ctrl_empty)?LD_Tx_Reg:Finished; end
	    default :   begin next_state = LD_Tx_Reg; end
	endcase
end // always

always @ (*)
begin
	STM_data_payload=(STM_ctrl_FIFO_r_en)?FIFO_data_payload:0;
end // always

always @ (*)
begin
	case(state)
	LD_Tx_Reg:
	begin
		STM_ctrl_Parity_cfg=Cfg_ctrl_paritybit;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=Cfg_ctrl_Tx_en;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
		STM_ctrl_outputsel=0;
		STM_ctrl_shift_ld_en=1;
		STM_ctrl_baud_cnt_rstn=0;
	end
	Send_start:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
		STM_ctrl_outputsel=1;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=1;
	end
	Send_1,Send_2,Send_3,Send_4,Send_5,Send_6,Send_7:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=1;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=1;
		STM_ctrl_baud_cnt_en=1;
		STM_ctrl_outputsel=2;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=1;
	end
	Send_8:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=1;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
		STM_ctrl_outputsel=2;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=1;
	end
	Send_P:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
		STM_ctrl_outputsel=3;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=1;
	end
	Send_Stop_2,Send_Stop_1:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=1;
		STM_ctrl_outputsel=0;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=1;
	end
	Finished:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
		STM_ctrl_outputsel=0;
		STM_ctrl_shift_ld_en=0;
		STM_ctrl_baud_cnt_rstn=0;// rst baud cnt and deactivate it until
								 // send start state
	end
	default:
	begin
		STM_ctrl_Parity_cfg=0;
		STM_ctrl_Parity_en=0;
		STM_ctrl_FIFO_r_en=0;
		STM_ctrl_shift_send_en=0;
		STM_ctrl_baud_cnt_en=0;
		STM_ctrl_outputsel=0;
		STM_ctrl_shift_ld_en=0;
	end
	endcase
end // always

endmodule     	