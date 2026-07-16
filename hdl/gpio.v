module gpio #(
    parameter PORT_WIDTH = 16
) (
    input clk,
    input rstn,
    inout [PORT_WIDTH-1:0] io_port
    // AIP
);

  reg  [PORT_WIDTH-1:0]   r_mode;   // Pin mode
  reg  [PORT_WIDTH-1:0]   r_odr;    // Output Data Register
  wire [PORT_WIDTH-1:0]   w_idr;    // Input Data Register
  reg  [PORT_WIDTH*2-1:0] r_bsrr;   // Bit Set Reset Register (Upper 16 bit reg -> Reset, Lower -> Set)

  // Arithmetic logic for BSRR -> ODR
  wire [PORT_WIDTH-1:0] w_br;     // Aux Bit Reset wire
  wire [PORT_WIDTH-1:0] w_bs;     // Aux Bit Set wire
  wire [PORT_WIDTH-1:0] w_bsrr_odr;

  assign w_br = r_bsrr[2*PORT_WIDTH-1:PORT_WIDTH];
  assign w_bs = r_bsrr[PORT_WIDTH-1:0];
  assign w_bsrr_odr = w_bs | (~w_br & r_odr);

  // Port instantiation
  gpio_port #(.PORT_WIDTH(PORT_WIDTH)) u_gpio_port  (
    .i_mode(r_mode),
    .i_port_out(r_odr),
    .o_port_in(w_idr),
    .io_port(io_port)
  );

  always @(posedge clk or negedge rstn) begin

    if (!rstn) begin
      r_mode <= {PORT_WIDTH{1'b0}};
      r_odr <= {PORT_WIDTH{1'b0}};
      r_bsrr <= {PORT_WIDTH{1'b0}};
    end

    else begin

      // r_mode write
      r_mode <= data;

      // r_odr write
      r_odr <= data;

      // w_idr read;
      r_data <= w_idr;

      // r_bsrr write;
      r_odr <= w_bsrr_odr;

    end

  end

endmodule

