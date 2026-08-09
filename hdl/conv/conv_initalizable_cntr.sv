module initializable_cntr
#(
	parameter DATA_WIDTH = 8
)(
	input clk,
	input rstn,
	input sel_in,
	input en_in,
	input	clr_in,
	input  logic [DATA_WIDTH-1:0] initial_value_in,
	output logic [DATA_WIDTH-1:0] c_out,
	output logic [DATA_WIDTH-1:0] c_nxt_out
);

	logic [DATA_WIDTH-1:0] adder_result;
	logic [DATA_WIDTH-1:0] mux_result;

	assign c_nxt_out = clr_in ? 0 : mux_result;

	// ---------- ADDER ------------ //
   adder
   #(
      .DATA_WIDTH    (DATA_WIDTH)
   )
   conv_cntr_adder
   (
       .re_A      ('d1),
       .re_B      (c_out),
       .re_out    (adder_result)
   );
	

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
						// {{DATA_WIDTH-1{1'b0}}, 1'b1}, // sel == 1
						initial_value_in,	// sel == 1
						adder_result		// sel == 0
					   }),
      .data_o   (mux_result)
   );


	// ---------- REGISTER ------------ //
      register 
      #(
         .DATA_WIDTH (DATA_WIDTH)
      )
		conv_cntr_register
      (
         .clk     (clk),
         .rstn    (rstn),
         .clrh    (clr_in),   
         .enh     (en_in),
         .data_i  (c_nxt_out),
         .data_o  (c_out)
      );

endmodule
