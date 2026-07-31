// Host <-> AIP

module ID00005010_pwm (
    input         i_clk,
    input         i_rst,
    input         i_en, // AIP enable
    input  [31:0] i_dataIn,
    input  [ 4:0] i_config,
    input         i_write,
    input         i_read,
    input         i_start, // Periph enable
    output [31:0] o_dataOut,
    output        o_int,
    output        o_pwm
);

  localparam DATA_WIDTH = 32;
  localparam CONF_WIDTH = 5;
  localparam DATA_CONF_WIDTH = 16;

  wire [DATA_WIDTH*2-1:0] w_dataConfig;
  wire w_start;

  ID00005010_aip u_aip (
      .clk(i_clk),
      .rst(i_rst),
      .en (i_en),

      //--- AIP ---//
      .dataInAIP(i_dataIn),
      .dataOutAIP(o_dataOut),
      .configAIP(i_config),
      .readAIP(i_read),
      .writeAIP(i_write),
      .startAIP(i_start),
      .intAIP(o_int),

      //--- IP-core ---//
      .rdDataConfigReg(w_dataConfig),
      .statusIPcore_Busy(1'b0),
      .intIPCore_Done(1'b0),
      .startIPcore(w_start)
  );

  pwm #(
      .DATA_WIDTH(DATA_CONF_WIDTH)
  ) u_pwmCore (
      .clk(i_clk),
      .rst_n(i_rst),
      .i_en(w_start),
      .i_output_en(w_dataConfig[49]),
      .i_prescaler(w_dataConfig[15:0]),
      .i_period(w_dataConfig[31:16]),
      .i_duty(w_dataConfig[47:32]),
      .i_polarity(w_dataConfig[48]),  // 0 active_low, 1 active_high 
      .o_pwm(o_pwm)
  );

  assign w_dataConfig[DATA_WIDTH*2-1:50] = 0;

endmodule
