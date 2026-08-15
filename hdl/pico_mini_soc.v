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
    input clk,
    input rst,
    input ena,

    output ser_tx,
    input  ser_rx,

    input irq_5,

    input sw0,
    input sw1,
    input sw2,
    input sw3,
    input sw4,
    input sw5,
    input sw6,
    input sw7,

    output led0,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6,
    output led7,
    output ledr_n,
    output ledg_n,

    output o_pwm,
    inout [15:0] io_gpio

);

  localparam NUM_PERI = 3;
  localparam PWM_PERI = 0;
  localparam GPIO_PERI = 1;
  localparam CORDIC_PERI = 2;

  localparam PWM_BASE_ADDR = 32'h8000_1000;
  localparam GPIO_BASE_ADDR = 32'h8000_2000;
  localparam CORDIC_BASE_ADDR = 32'h8000_3000;


  // resetn counter
  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt;
  always @(posedge clk or negedge rst) begin
    if (!rst) reset_cnt = 0;
    else if (ena) reset_cnt <= reset_cnt + !resetn;
  end

  // leds
  wire [7:0] leds;
  assign led0   = leds[0];
  assign led1   = leds[1];
  assign led2   = leds[2];
  assign led3   = leds[3];
  assign led4   = leds[4];
  assign led5   = leds[5];
  assign led6   = leds[6];
  assign led7   = leds[7];

  assign led0 = io_gpio[0];
  assign led1 = io_gpio[1];


  // CPU connections
  wire        iomem_valid;
  wire        iomem_ready;
  wire [ 3:0] iomem_wstrb;
  wire [31:0] iomem_addr;
  wire [31:0] iomem_wdata;
  wire [31:0] iomem_rdata;
  // wire        iomem_wen;
  wire        irq_6;
  wire        irq_7;

  // AIP connections
  wire        aip_sel     [NUM_PERI];  //CPU Addr + valid condition
  wire        aip_enable  [NUM_PERI];  //enAIP
  wire [31:0] aip_dataOut [NUM_PERI];  //dataOutAIP
  wire [31:0] aip_dataIn  [NUM_PERI];  //dataInAIP
  wire [ 4:0] aip_config  [NUM_PERI];  //configAIP
  wire        aip_read    [NUM_PERI];  //readAIP
  wire        aip_write   [NUM_PERI];  //writeAIP
  wire        aip_start   [NUM_PERI];  //startAIP
  wire        aip_int     [NUM_PERI];  //intAIP--------INT
  wire        core_int    [NUM_PERI];  //intAIP----------INT TO CPU

  // Auxiliar wires
  wire        cpu_ready   [NUM_PERI];
  wire [31:0] cpu_rdata   [NUM_PERI];
  wire        cpu_wen     [NUM_PERI];

  assign iomem_rdata = 
    aip_sel[PWM_PERI] ? cpu_rdata[PWM_PERI] : 
    aip_sel[GPIO_PERI] ? cpu_rdata[GPIO_PERI] : 
    aip_sel[CORDIC_PERI] ? cpu_rdata[CORDIC_PERI]: 
    32'd0;

  assign iomem_ready = 
    (aip_sel[PWM_PERI] && cpu_ready[PWM_PERI]) ||
    (aip_sel[GPIO_PERI] && cpu_ready[GPIO_PERI]) ||
    (aip_sel[CORDIC_PERI] && cpu_ready[CORDIC_PERI]);

  assign cpu_wen[PWM_PERI] = iomem_valid && !cpu_ready[PWM_PERI] && (aip_sel[PWM_PERI] ? |(iomem_wstrb) : 1'b0);
  assign cpu_wen[GPIO_PERI] = iomem_valid && !cpu_ready[GPIO_PERI] && (aip_sel[GPIO_PERI] ? |(iomem_wstrb) : 1'b0);
  assign cpu_wen[CORDIC_PERI] = iomem_valid && !cpu_ready[CORDIC_PERI] && (aip_sel[CORDIC_PERI] ? |(iomem_wstrb) : 1'b0);

  // Periph selector based on address
  assign aip_sel[PWM_PERI] = (iomem_addr[31:12] == 20'h8000_1);
  assign aip_sel[GPIO_PERI] = (iomem_addr[31:12] == 20'h8000_2);
  assign aip_sel[CORDIC_PERI] = (iomem_addr[31:12] == 20'h8000_3);

  assign aip_enable[PWM_PERI] = 1'b1;
  assign aip_enable[GPIO_PERI] = 1'b1;
  assign aip_enable[CORDIC_PERI] = 1'b1;

  pico_mini soc (
      .clk   (clk),
      .resetn(resetn),

      .ser_tx(ser_tx),
      .ser_rx(ser_rx),

      .irq_5(1'b0),
      .irq_6(1'b0),
      .irq_7(1'b0),

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
      .i_clk(clk),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(cpu_wen[PWM_PERI]),
      .o_cpu_mem_rdata(cpu_rdata[PWM_PERI]),
      .o_cpu_mem_ready(cpu_ready[PWM_PERI]),
      .o_cpu_irq(),  // Disconnected
      // AIP
      .i_aip_sel(aip_sel[PWM_PERI]),
      .i_aip_enable(aip_enable[PWM_PERI]),
      .i_aip_dataOut(aip_dataOut[PWM_PERI]),
      .o_aip_dataIn(aip_dataIn[PWM_PERI]),
      .o_aip_config(aip_config[PWM_PERI]),
      .o_aip_read(aip_read[PWM_PERI]),
      .o_aip_write(aip_write[PWM_PERI]),
      .o_aip_start(aip_start[PWM_PERI]),
      .i_aip_int(aip_int[PWM_PERI]),
      .o_core_int()
  );

  ID00005010_pwm u_pwm (
      .i_clk(clk),
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
      .i_clk(clk),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(cpu_wen[GPIO_PERI]),
      .o_cpu_mem_rdata(cpu_rdata[GPIO_PERI]),
      .o_cpu_mem_ready(cpu_ready[GPIO_PERI]),
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
      .o_core_int()
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
      .i_clk(clk),
      .i_rst(resetn),
      // CPU
      .i_cpu_mem_valid(iomem_valid),
      .i_cpu_mem_addr(iomem_addr),
      .i_cpu_mem_wdata(iomem_wdata),
      .i_cpu_mem_wen(cpu_wen[CORDIC_PERI]),
      .o_cpu_mem_rdata(cpu_rdata[CORDIC_PERI]),
      .o_cpu_mem_ready(cpu_ready[CORDIC_PERI]),
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
      .o_core_int()
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

endmodule
