module subtractor
#(
	parameter DATA_WIDTH = 8
)(
	input  logic [DATA_WIDTH-1:0] A_i,
	input  logic [DATA_WIDTH-1:0] B_i,
	output logic [DATA_WIDTH-1:0] A_sub_B_o
);

assign A_sub_B_o = A_i - B_i;

endmodule
