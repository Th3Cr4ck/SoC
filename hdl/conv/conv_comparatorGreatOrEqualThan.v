module comparatorGreatOrEqualThan
#(
   parameter DATA_WIDTH = 32
)(
	input [DATA_WIDTH-1:0]  A_i,
	input [DATA_WIDTH-1:0]  B_i, 
	output                  A_great_or_equal_than_B_o
);

assign A_great_or_equal_than_B_o = ( $signed(A_i) >= $signed(B_i) ) ? 1'b1 :  1'b0;

endmodule
