module mux_mult_reg #(
    parameter DATA_WIDTH = 32,
    parameter QF = 10,
    parameter SEL_WIDTH  = 1
) (
    input clk,
    input rstn,
    input enh,
    input clrh,
    input [SEL_WIDTH-1:0] sel_i,
    input [((2**SEL_WIDTH)*DATA_WIDTH)-1 : 0] data_i,
    output signed [DATA_WIDTH-1:0] data_o
);

  localparam signed [DATA_WIDTH-1:0] K = 622;  // Q3.10

  wire signed [DATA_WIDTH-1:0] mux_out;

  muxNto1 #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (SEL_WIDTH)
  ) MUX (
      .sel_i (sel_i),
      .data_i(data_i),
      .data_o(mux_out)
  );


  wire signed [(DATA_WIDTH*2)-1:0] mult_out_full;
  multiplier #(
      .DATA_WIDTH(DATA_WIDTH)
  ) MULT (
      .A_i(K),
      .B_i(mux_out),
      .A_times_B_o(mult_out_full)
  );

  wire signed [(DATA_WIDTH*2)-1:0] mult_out_full_shifted;
  wire signed [DATA_WIDTH-1:0] mult_out;
  assign mult_out_full_shifted = mult_out_full >>> QF;
  assign mult_out = mult_out_full_shifted[DATA_WIDTH-1:0];

  register #(
      .DATA_WIDTH(DATA_WIDTH)
  ) REG (
      .clk   (clk),
      .rstn  (rstn),
      .clrh  (clrh),
      .enh   (enh),
      .data_i(mult_out),
      .data_o(data_o)
  );
endmodule
