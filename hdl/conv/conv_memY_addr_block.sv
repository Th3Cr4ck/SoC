module memY_addr_block
#(
	parameter DATA_WIDTH = 8
)(
	input  logic clk, 
	input  logic rstn, 
	input  logic memY_addr_en_i, 
	input  logic memY_addr_clr_i,
	input  logic selY_i,
	input  logic [DATA_WIDTH-1:0] i_reg_i,
	input  logic [DATA_WIDTH-1:0] j_reg_i,
	input  logic [DATA_WIDTH-1:0] k_reg_i,
	output logic [DATA_WIDTH-1:0] memY_addr_o
);

	logic [DATA_WIDTH-1:0] sub_result;
	logic [DATA_WIDTH-1:0] mux_result;

	// ----------- SUBTRACTOR ----------//
	subtractor
	#(
		.DATA_WIDTH		(DATA_WIDTH)
	)
	conv_memY_sub
	(
		.A_i			(i_reg_i),
		.B_i			(j_reg_i),
		.A_sub_B_o	(sub_result)
	);


	// ---------- MUX2TO1 ------------ //
   muxNto1 
   #(
      .DATA_WIDTH   (DATA_WIDTH),
      .SEL_WIDTH    ($clog2(2))
   )
	conv_memY_mux2to1
   (
      .sel_i    (selY_i),
      .data_i   ({
						k_reg_i,		// sel == 1
						sub_result	// sel == 0
					   }),
      .data_o   (mux_result)
   );


	// ---------- REGISTER ------------ //
      register 
      #(
         .DATA_WIDTH (DATA_WIDTH)
      )
		conv_memY_register
      (
         .clk     (clk),
         .rstn    (rstn),
         .clrh    (memY_addr_clr_i),   
         .enh     (memY_addr_en_i),
         .data_i  (mux_result),
         .data_o  (memY_addr_o)
      );


endmodule 
