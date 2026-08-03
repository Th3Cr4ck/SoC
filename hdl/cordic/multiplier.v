module multiplier #(
    parameter DATA_WIDTH = 8
) (
    input wire signed [DATA_WIDTH-1:0] A_i,
    input wire signed [DATA_WIDTH-1:0] B_i,
    output wire signed [(DATA_WIDTH*2)-1:0] A_times_B_o
);

  assign A_times_B_o = A_i * B_i;

endmodule
