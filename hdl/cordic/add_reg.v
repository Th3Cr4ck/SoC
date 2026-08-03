/*
 * Addition or subtraction specified by input sel
 * sel = 1 => a + b
 * sel = 0 => a - b

 // TEMPLATE
  add_reg #(
      .DATA_WIDTH()
  ) INSTANCE_NAME (
      .clk(),
      .rstn(),
      .enh(),
      .clrh(),
      .a(),
      .b(),
      .out()
  );
 * */

module add_reg #(
    parameter DATA_WIDTH = 32
) (
    input                                clk,
    input                                rstn,
    input                                enh,
    input                                clrh,
    input  signed     [DATA_WIDTH-1 : 0] a,
    input  signed     [DATA_WIDTH-1 : 0] b,
    output signed     [DATA_WIDTH-1 : 0] out_comb,
    output reg signed [DATA_WIDTH-1 : 0] out
);

  assign out_comb = a + b;

  always @(posedge clk, negedge rstn) begin
    if (~rstn) out <= {DATA_WIDTH{1'b0}};
    else if (enh) out <= out_comb;
    else if (clrh) out <= {DATA_WIDTH{1'b0}};
  end

endmodule
