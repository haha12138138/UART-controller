`timescale 1ns / 1ps

module Tx_outputsel (
	 input [1:0]STM_ctrl_outputsel
	 ,input Shift_data_bit
	 ,input Parity_data
	,output reg outputsel_data_bit
);
parameter Parity =3 ;
parameter STOP =0 ;
parameter DATA =2;
parameter START =1 ;
always @ (*)
begin
	case(STM_ctrl_outputsel)
	STOP:
	begin
		outputsel_data_bit=1;
	end
	START:
	begin
		outputsel_data_bit=0;
	end
	DATA:
	begin
		outputsel_data_bit=Shift_data_bit;
	end
	Parity:
	begin
		outputsel_data_bit=Parity_data;
	end
	endcase
end // always

endmodule