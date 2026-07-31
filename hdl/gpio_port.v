module gpio_port #(
    parameter PORT_WIDTH = 16
) (
    input  [PORT_WIDTH-1:0] i_mode,  // 0 input, 1 output
    input  [PORT_WIDTH-1:0] i_port_out,
    output [PORT_WIDTH-1:0] o_port_in,
    inout  [PORT_WIDTH-1:0] io_port
);

  assign o_port_in = io_port;

  genvar i;
  generate
    for (i = 0; i < PORT_WIDTH; i = i + 1) begin : g_port
      assign io_port[i] = i_mode[i] ? i_port_out[i] : 1'bZ;
    end
  endgenerate

endmodule
