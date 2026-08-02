module ID00005020_gpio #(
    parameter PORT_WIDTH = 16,
    parameter DATA_WIDTH = 32,
    parameter CONFIG_WIDTH = 5
) (
    input                     i_clk,
    input                     i_rst,
    inout  [  PORT_WIDTH-1:0] io_port,
    // AIP
    input  [  DATA_WIDTH-1:0] i_dataInAIP,
    input  [CONFIG_WIDTH-1:0] i_configAIP,
    input                     i_writeAIP,
    input                     i_readAIP,
    input                     i_enAIP,
    input                     i_startAIP,
    output [  DATA_WIDTH-1:0] o_dataOutAIP,
    output                    o_intAIP
);

  localparam MEM_ADDR_MAX_WIDTH = 16;
  localparam MEM_ADDR_WIDTH = 1;

  // Wires AIP <-> GPIO
  wire [  DATA_WIDTH*2-1:0] w_dataConfig;
  wire                      w_dataConfigRegWritten;
  wire [MEM_ADDR_WIDTH-1:0] w_wrAddrMemOut;
  wire [    DATA_WIDTH-1:0] w_dataMemOut;
  wire                      w_wrEnMemOut;
  wire                      w_start;

  // Data from Config Register
  wire                      w_opMode;
  wire [    PORT_WIDTH-1:0] w_ioMode;  // Pin mode
  wire [    DATA_WIDTH-1:0] w_dataReg; // Manipulate data for ODR (ODR or BSSR)

  assign w_dataReg = w_dataConfig[31:0];
  assign w_ioMode  = w_dataConfig[47:32];
  assign w_opMode  = w_dataConfig[48];

  // Auxiliars
  wire [PORT_WIDTH-1:0] w_odr_host;  // Output Data Register by Host
  wire [PORT_WIDTH-1:0] w_br;        // Bit Reset wire
  wire [PORT_WIDTH-1:0] w_bs;        // Bit Set wire

  assign w_odr_host = w_dataReg[15:0];
  assign w_bs = w_dataReg[15:0];
  assign w_br = w_dataReg[31:16];

  // GPIO registers
  reg  [  PORT_WIDTH-1:0] r_odr;  // Output Data Register of GPIO
  wire [  PORT_WIDTH-1:0] w_idr;  // Input Data Register

  // Arithmetic logic for BSRR -> ODR
  wire [  PORT_WIDTH-1:0] w_odr_bsrr;  // Output Data Register by BSRR

  assign w_odr_bsrr = w_bs | (~w_br & r_odr);

  // Core
  gpio_port #(
      .PORT_WIDTH(PORT_WIDTH)
  ) u_gpio_port (
      .i_mode(w_ioMode),
      .i_port_out(r_odr),
      .o_port_in(w_idr),
      .io_port(io_port)
  );

  // AIP
  ID00005020_aip u_aip (
      .clk(i_clk),
      .rst(i_rst),
      .en (i_enAIP),

      //--- AIP ---//
      .dataInAIP(i_dataInAIP),
      .dataOutAIP(o_dataOutAIP),
      .configAIP(i_configAIP),
      .readAIP(i_readAIP),
      .writeAIP(i_writeAIP),
      .startAIP(i_startAIP),
      .intAIP(o_intAIP),

      //--- IP-core ---//
      .wrDataMemOut_0({r_odr, w_idr}),
      .wrAddrMemOut_0({MEM_ADDR_MAX_WIDTH{1'b0}}),
      .wrEnMemOut_0({1'b1}),
      .rdDataConfigReg(w_dataConfig),
      .statusIPcore_Busy(1'b0),
      .intIPCore_Done(1'b0),
      .startIPcore(w_start),
      .dataConfigRegWritten(w_dataConfigRegWritten)
  );

  always @(posedge i_clk or negedge i_rst) begin

    if (!i_rst) begin
      r_odr <= {PORT_WIDTH{1'b0}};
    end

    else if (w_dataConfigRegWritten)
      if (w_opMode) 
        r_odr <= w_odr_bsrr;
      else 
        r_odr <= w_odr_host;

    else 
      r_odr <= r_odr;

  end

endmodule

