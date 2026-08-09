module dataZ_block
#(
	parameter DATA_WIDTH = 8
)(
	input  logic							 clk, 
	input  logic							 rstn, 
	input  logic							 en_i, 
	input  logic							 clr_i,
	input  logic [DATA_WIDTH-1:0]		 dataX_i,
	input  logic [DATA_WIDTH-1:0]		 dataY_i,
	output logic [(DATA_WIDTH*2)-1:0] dataZ_o
);

	logic [(DATA_WIDTH*2)-1:0] multiplier_result;
	logic [(DATA_WIDTH*2)-1:0] adder_result;
	
	
	// ---------- MULTIPLIER ------------ //
	multiplier
   #(
      .DATA_WIDTH    (DATA_WIDTH)
   )
	conv_dataZ_multiplier
	(
		.A_i				(dataX_i),
		.B_i				(dataY_i),
		.A_times_B_o	(multiplier_result)
	);
	

	// ---------- ADDER ------------ //
   adder
   #(
      .DATA_WIDTH    (DATA_WIDTH*2)
   )
   conv_dataZ_adder
   (
       .re_A      (multiplier_result),
       .re_B      (dataZ_o),
       .re_out    (adder_result)
   );


	// ---------- REGISTER ------------ //
	register 
	#(
		.DATA_WIDTH (DATA_WIDTH*2)
	)
	conv_dataZ_register	
	(
		.clk     (clk),
		.rstn    (rstn),
		.clrh    (clr_i),   
		.enh     (en_i),
		.data_i  (adder_result),
		.data_o  (dataZ_o)
	);

endmodule 
