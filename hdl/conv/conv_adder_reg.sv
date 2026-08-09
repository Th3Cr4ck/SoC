module adder_reg
#(
	parameter DATA_WIDTH = 8
)(
	input  logic clk,
	input  logic rstn,
	input  logic en_in,
	input  logic clr_in,
	input  logic [DATA_WIDTH-1:0] A_in,
	input  logic [DATA_WIDTH-1:0] B_in,
	output logic [DATA_WIDTH-1:0] A_plus_B_o
);

	logic [DATA_WIDTH-1:0] add_result;

   adder
   #(
      .DATA_WIDTH    (DATA_WIDTH)
   )
	A_plus_B
   (
       .re_A      (A_in),
       .re_B      (B_in),
       .re_out    (add_result)
   );
		
	register 
	#(
		.DATA_WIDTH (DATA_WIDTH)
	)
	A_plus_B_register	
	(
		.clk     (clk),
		.rstn    (rstn),
		.clrh    (clr_in),   
		.enh     (en_in),
		.data_i  (add_result),
		.data_o  (A_plus_B_o)
		);

endmodule 
