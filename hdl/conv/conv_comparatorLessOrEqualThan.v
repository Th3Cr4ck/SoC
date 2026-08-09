module comparatorLessOrEqualThan
#(
   parameter DATA_WIDTH = 13
)(
	input [DATA_WIDTH-1:0]  A_i,
	input [DATA_WIDTH-1:0]  B_i, 
	output                  A_less_than_B_o
);

assign A_less_than_B_o = ( A_i <= B_i ) ? 1'b1 :  1'b0;

endmodule
