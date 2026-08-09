module cntrK
#(
	parameter DATA_WIDTH = 8
)(
	input clk,
	input rstn,
	input sel_in,
	input en_in,
	input  logic [DATA_WIDTH-1:0] sizeY_in,
	output logic [DATA_WIDTH-1:0] k_out,
	output logic [DATA_WIDTH-1:0] k_nxt_out
);

	logic [DATA_WIDTH-1:0] mux_result;
	logic [DATA_WIDTH-1:0] sub_result;
	
	assign k_nxt_out = sub_result;

	// ---------- MUX2TO1 ------------ //
   muxNto1 
   #(
      .DATA_WIDTH   (DATA_WIDTH),
      .SEL_WIDTH    ($clog2(2))
   )
	conv_cntr_mux2to1
   (
      .sel_i    (sel_in),
      .data_i   ({
						k_out,		// sel == 1
						sizeY_in		// sel == 0
					   }),
      .data_o   (mux_result)
   );

	
	// ---------- SUBTRACTOR ------------ //
	subtractor
	#(
		.DATA_WIDTH (DATA_WIDTH)
	)
	conv_cntrK_sub
	(
		.A_i			(mux_result),
		.B_i			('d1),
		.A_sub_B_o	(sub_result)
	);


	// ---------- SUBTRACTOR ------------ //
	register 
   #(
		.DATA_WIDTH (DATA_WIDTH)
   )
	conv_cntrK_reg
   (
		.clk     (clk),
	   .rstn    (rstn),
      .clrh    (0),   
      .enh     (en_in),
      .data_i  (sub_result),
      .data_o  (k_out)
    );

endmodule
