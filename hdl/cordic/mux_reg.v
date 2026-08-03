/*
* Mux with output registered
*/

module mux_reg #(
  parameter DATA_WIDTH = 32,
  parameter SEL_WIDTH = 1
) (
    input clk,
    input rstn,
    input enh,
    input clrh,
    input [SEL_WIDTH-1:0] sel_i,
    input [((2**SEL_WIDTH)*DATA_WIDTH)-1 : 0] data_i,
    output [DATA_WIDTH-1:0] data_o_v,
    output reg [DATA_WIDTH-1:0] data_o
);

  localparam NUM_INPUTS = 2 ** SEL_WIDTH;

  genvar i;

  wire [DATA_WIDTH-1:0] input_wire[0:NUM_INPUTS-1];

  assign data_o_v = input_wire[sel_i];

  always@(posedge clk or negedge rstn) begin
    if (~rstn)
      data_o <= {DATA_WIDTH{1'b0}};
    else if (clrh)
      data_o <= {DATA_WIDTH{1'b0}};
    else if (enh)
      data_o <= data_o_v;
  end

  //conections to input wire
  generate
    for (i = 0; i < NUM_INPUTS; i = i + 1) begin : g_assignements
      assign input_wire[i] = data_i[(i*DATA_WIDTH)+:DATA_WIDTH];
    end
  endgenerate

endmodule

// module mux_reg #(
//     parameter DATA_WIDTH = 32,
//     parameter SEL_WIDTH  = 1
// ) (
//     input clk,
//     input rstn,
//     input enh,
//     input clrh,
//     input [SEL_WIDTH-1:0] sel_i,
//     input [((2**SEL_WIDTH)*DATA_WIDTH)-1 : 0] data_i,
//     output [DATA_WIDTH-1:0] data_o_v,
//     output [DATA_WIDTH-1:0] data_o
// );
//
//   wire [DATA_WIDTH-1:0] mux_out;
//   assign mux_out = data_o_v;
//
//   muxNto1 #(
//       .DATA_WIDTH(DATA_WIDTH),
//       .SEL_WIDTH (SEL_WIDTH)
//   ) MUX (
//       .sel_i (sel_i),
//       .data_i(data_i),
//       .data_o(data_o_v)
//   );
//
//
//   register #(
//       .DATA_WIDTH(DATA_WIDTH)
//   ) REG (
//       .clk   (clk),
//       .rstn  (rstn),
//       .clrh  (clrh),
//       .enh   (enh),
//       .data_i(mux_out),
//       .data_o(data_o)
//   );
//
// endmodule
