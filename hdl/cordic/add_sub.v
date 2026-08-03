/*
 * Addition or subtraction specified by input sel
 * sel = 1 => a + b
 * sel = 0 => a - b
 * */

module add_sub #(
    parameter DATA_WIDTH = 32
) (
    input  signed [DATA_WIDTH-1 : 0] a,
    input  signed [DATA_WIDTH-1 : 0] b,
    input                            sel,
    output signed [DATA_WIDTH-1 : 0] out
);

  assign out = sel ? a + b : a - b;

endmodule
