/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */


module pico_mini_soc (
    input  clk,
    input  rst,
    input  ena,
    output ser_tx,
    input  ser_rx,

    input irq_5,

    output led1,
    output led2,
    output led3,
    output led4,
    output led5,

    output ledr_n,
    output ledg_n,

    output o_pwm,
    inout [15:0] io_gpio

);

  localparam NUM_PERI = 4;
  localparam PWM_PERI = 0;
  localparam GPIO_PERI = 1;
  localparam CORDIC_PERI = 2;
  localparam CONV_PERI = 3;

  localparam PWM_BASE_ADDR = 32'h8000_1000;
  localparam GPIO_BASE_ADDR = 32'h8000_2000;
  localparam CORDIC_BASE_ADDR = 32'h8000_3000;
  localparam CONV_BASE_ADDR = 32'h8000_4000;

  wire clk_12Mhz;
  reg [1:0] cont;

  always @(posedge clk or negedge rst) begin
    if (!rst) cont = 0;
    else cont <= cont + 1'b1;
  end
  assign clk_12Mhz = clk;


  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt;

  always @(posedge clk_12Mhz or negedge rst) begin
    if (!rst) reset_cnt = 0;
    else if (ena) reset_cnt <= reset_cnt + !resetn;
  end

  // wire [7:0] leds;
  // assign led1   = leds[1];
  // assign led2   = leds[2];
  // assign led3   = leds[3];
  // assign led4   = leds[4];
  // assign led5   = leds[5];
  //
  // assign ledr_n = !leds[6];
  // assign ledg_n = !leds[7];

  // reg [31:0] gpio;
  // assign leds = gpio;

  // always @(posedge clk_12Mhz) begin
  //   if (!resetn) begin
  //     gpio <= 0;
  //   end else begin
  //     // iomem_ready <= 0;
  //     if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h81) begin
  //       // iomem_ready <= 1;
  //       if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
  //       if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
  //       if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
  //       if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
  //     end
  //   end
  // end

  // CPU connections
  wire        iomem_valid;
  reg         iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  wire [31:0] iomem_rdata;
  wire        iomem_wen;
  wire        irq_6;
  wire        irq_7;

  // AIP connections
  wire        aip_sel     [NUM_PERI];  //CPU Addr + valid condition
  wire        aip_enable  [NUM_PERI];  //enAIP
  wire [31:0] aip_dataOut [NUM_PERI];  //dataOutAIP
  wire [31:0] aip_dataIn  [NUM_PERI];  //dataInAIP
  wire [ 4:0] aip_config  [NUM_PERI];  //configAIP
  reg         aip_read    [NUM_PERI];  //readAIP
  reg         aip_write   [NUM_PERI];  //writeAIP
  wire        aip_start   [NUM_PERI];  //startAIP
  wire        aip_int     [NUM_PERI];  //intAIP--------INT
  wire        core_int    [NUM_PERI];  //intAIP----------INT TO CPU

  always @(posedge clk or negedge rst)
    if (~rst) iomem_ready <= 1'b0;
    else if (iomem_valid && ~iomem_ready) iomem_ready <= 1'b1;
    else iomem_ready <= 1'b0;

  // Auxiliar wires
  wire        cpu_ready[NUM_PERI];
  wire [31:0] cpu_rdata[NUM_PERI];

  assign iomem_rdata = 
    aip_sel[PWM_PERI] ? cpu_rdata[PWM_PERI] : 
    aip_sel[GPIO_PERI] ? cpu_rdata[GPIO_PERI] : 
    aip_sel[CORDIC_PERI] ? cpu_rdata[CORDIC_PERI]: 
    aip_sel[CONV_PERI] ? cpu_rdata[CONV_PERI]: 
    32'd0;

  assign iomem_wen = iomem_wstrb > 4'b0;

  // Periph selector based on address
  assign aip_sel[PWM_PERI] = iomem_valid && (iomem_addr[31:12] == 20'h8000_1);
  assign aip_sel[GPIO_PERI] = iomem_valid && (iomem_addr[31:12] == 20'h8000_2);
  assign aip_sel[CORDIC_PERI] = iomem_valid && (iomem_addr[31:12] == 20'h8000_3);
  assign aip_sel[CONV_PERI] = iomem_valid && (iomem_addr[31:12] == 20'h8000_4);

  assign aip_enable[PWM_PERI] = 1'b1;
  assign aip_enable[GPIO_PERI] = 1'b1;
  assign aip_enable[CORDIC_PERI] = 1'b1;
  assign aip_enable[CONV_PERI] = 1'b1;

  pico_mini soc (
      .clk   (clk_12Mhz),
      .resetn(resetn),

      .ser_tx(ser_tx),
      .ser_rx(ser_rx),

      .irq_5(irq_5),
      .irq_6(irq_6),
      .irq_7(irq_7),

      .iomem_valid(iomem_valid),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr (iomem_addr),
      .iomem_wdata(iomem_wdata),
      .iomem_rdata(iomem_rdata)
  );


  /*******************************************/
  /****************** PWM ********************/
  /*******************************************/
  native_aip u_nat_pwm (
      .i_clk(clk_12Mhz),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(iomem_wen),
      .o_cpu_mem_rdata(cpu_rdata[PWM_PERI]),
      .o_cpu_mem_ready(),
      .o_cpu_irq(),  // Disconnected
      // AIP
      .i_aip_sel(aip_sel[PWM_PERI]),  // CPU Addr + valid condition
      .i_aip_enable(aip_enable[PWM_PERI]),
      .i_aip_dataOut(aip_dataOut[PWM_PERI]),
      .o_aip_dataIn(aip_dataIn[PWM_PERI]),
      .o_aip_config(aip_config[PWM_PERI]),
      .o_aip_read(aip_read[PWM_PERI]),
      .o_aip_write(aip_write[PWM_PERI]),
      .o_aip_start(aip_start[PWM_PERI]),
      .i_aip_int(aip_int[PWM_PERI]),
      .o_core_int(core_int[PWM_PERI])
  );

  ID00005010_pwm u_pwm (
      .i_clk(clk),  // 50 MHz clock
      .i_rst(resetn),
      .i_enAIP(aip_enable[PWM_PERI]),
      .i_dataInAIP(aip_dataIn[PWM_PERI]),
      .i_configAIP(aip_config[PWM_PERI]),
      .i_writeAIP(aip_write[PWM_PERI]),
      .i_readAIP(aip_read[PWM_PERI]),
      .i_startAIP(aip_start[PWM_PERI]),
      .o_dataOutAIP(aip_dataOut[PWM_PERI]),
      .o_intAIP(aip_int[PWM_PERI]),
      .o_pwm(o_pwm)
  );

  /*******************************************/
  /****************** GPIO *******************/
  /*******************************************/
  native_aip u_nat_gpio (
      .i_clk(clk_12Mhz),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(iomem_wen),
      .o_cpu_mem_rdata(cpu_rdata[GPIO_PERI]),
      .o_cpu_mem_ready(),
      .o_cpu_irq(),  // Disconnected
      // AIP
      .i_aip_sel(aip_sel[GPIO_PERI]),
      .i_aip_enable(aip_enable[GPIO_PERI]),
      .i_aip_dataOut(aip_dataOut[GPIO_PERI]),
      .o_aip_dataIn(aip_dataIn[GPIO_PERI]),
      .o_aip_config(aip_config[GPIO_PERI]),
      .o_aip_read(aip_read[GPIO_PERI]),
      .o_aip_write(aip_write[GPIO_PERI]),
      .o_aip_start(aip_start[GPIO_PERI]),
      .i_aip_int(aip_int[GPIO_PERI]),
      .o_core_int(core_int[GPIO_PERI])
  );

  ID00005020_gpio #(
      .PORT_WIDTH  (16),
      .DATA_WIDTH  (32),
      .CONFIG_WIDTH(5)
  ) u_gpio (
      .i_clk(clk),
      .i_rst(resetn),
      .i_enAIP(aip_enable[GPIO_PERI]),
      .i_dataInAIP(aip_dataIn[GPIO_PERI]),
      .i_configAIP(aip_config[GPIO_PERI]),
      .i_writeAIP(aip_write[GPIO_PERI]),
      .i_readAIP(aip_read[GPIO_PERI]),
      .i_startAIP(aip_start[GPIO_PERI]),
      .o_dataOutAIP(aip_dataOut[GPIO_PERI]),
      .o_intAIP(aip_int[GPIO_PERI]),
      .io_port(io_gpio)
  );

  /*******************************************/
  /****************** CORDIC *****************/
  /*******************************************/
  native_aip u_nat_cordic (
      .i_clk(clk_12Mhz),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(iomem_wen),
      .o_cpu_mem_rdata(cpu_rdata[CORDIC_PERI]),
      .o_cpu_mem_ready(),
      .o_cpu_irq(),
      // AIP
      .i_aip_sel(aip_sel[CORDIC_PERI]),
      .i_aip_enable(aip_enable[CORDIC_PERI]),
      .i_aip_dataOut(aip_dataOut[CORDIC_PERI]),
      .o_aip_dataIn(aip_dataIn[CORDIC_PERI]),
      .o_aip_config(aip_config[CORDIC_PERI]),
      .o_aip_read(aip_read[CORDIC_PERI]),
      .o_aip_write(aip_write[CORDIC_PERI]),
      .o_aip_start(aip_start[CORDIC_PERI]),
      .i_aip_int(aip_int[CORDIC_PERI]),
      .o_core_int(core_int[CORDIC_PERI])
  );

  ID00005030_cordic #(
      .DATA_WIDTH  (32),
      .CONFIG_WIDTH(5)
  ) u_cordic (
      .i_clk(clk),
      .i_rst(resetn),
      .i_enAIP(aip_enable[CORDIC_PERI]),
      .i_dataInAIP(aip_dataIn[CORDIC_PERI]),
      .i_configAIP(aip_config[CORDIC_PERI]),
      .i_writeAIP(aip_write[CORDIC_PERI]),
      .i_readAIP(aip_read[CORDIC_PERI]),
      .i_startAIP(aip_start[CORDIC_PERI]),
      .o_dataOutAIP(aip_dataOut[CORDIC_PERI]),
      .o_intAIP(aip_int[CORDIC_PERI])
  );

  /*******************************************/
  /****************** CONV *******************/
  /*******************************************/
  native_aip u_nat_conv (
      .i_clk(clk_12Mhz),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(iomem_wen),
      .o_cpu_mem_rdata(cpu_rdata[CONV_PERI]),
      .o_cpu_mem_ready(),
      .o_cpu_irq(irq_7),
      // AIP
      .i_aip_sel(aip_sel[CONV_PERI]),
      .i_aip_enable(aip_enable[CONV_PERI]),
      .i_aip_dataOut(aip_dataOut[CONV_PERI]),
      .o_aip_dataIn(aip_dataIn[CONV_PERI]),
      .o_aip_config(aip_config[CONV_PERI]),
      .o_aip_read(aip_read[CONV_PERI]),
      .o_aip_write(aip_write[CONV_PERI]),
      .o_aip_start(aip_start[CONV_PERI]),
      .i_aip_int(aip_int[CONV_PERI]),
      .o_core_int(core_int[CONV_PERI])
  );

  ID00005040_conv u_conv (
      .clk(clk),
      .rst_a(resetn),
      .en_s(aip_enable[CORDIC_PERI]),
      .data_in(aip_dataIn[CORDIC_PERI]),
      .conf_dbus(aip_config[CORDIC_PERI]),
      .write(aip_write[CORDIC_PERI]),
      .read(aip_read[CORDIC_PERI]),
      .start(aip_start[CORDIC_PERI]),
      .data_out(aip_dataOut[CORDIC_PERI]),
      .int_req(aip_int[CORDIC_PERI])
  );
endmodule
