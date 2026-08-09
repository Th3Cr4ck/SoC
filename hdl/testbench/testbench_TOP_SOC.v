`timescale 1 ns / 1 ps

module testbench_TOP_SOC;
  //----------------------------------------------------------
  //.......MANDATORY TB PARAMETERS............................
  //----------------------------------------------------------
  localparam CYCLE = 'd20,  // Define the clock work cycle in ns (user)
  DATAWIDTH = 'd32,  // BITWIDTH
  MAX_SIZE_MEM = 'd256,  // MAX MEMORY SIZE AMONG ALL AIP MEMORIES (Defined by the user)

  //------------------------------------------------------------
  //..................PARAMETERS DEFINED BY THE USER............
  //------------------------------------------------------------
  SIZE_MEM0 = 'd8192;  //Size of the memories of the IP PICORV32

  reg clk, rst, en_s;
  wire        rst_a;
  reg         iStartIPcore;
  reg  [31:0] count_cycle = 0;
  reg         irq;
  reg         pwm;

  // Simula el dispositivo externo conectado al GPIO
  reg [15:0] ext_data;
  reg [15:0] ext_enable;

  // Bus bidireccional
  tri [15:0] io_port;

  // El dispositivo externo solo conduce cuando ext_enable = 1
  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : g_port
      assign io_port[k] = ext_enable[k] ? ext_data[k] : 1'bZ;
    end
  endgenerate

  always #(CYCLE / 2) clk = !clk;

  localparam ser_half_period = 53;
  event ser_sample;

  initial begin
    $dumpfile("Testbench_soc.vcd");
    $dumpvars(0, testbench_TOP_SOC);
    /*       for (integer idx = 0; idx < 1024; idx++) begin
            $dumpvars(1, testbench_TOP_SOC.uut.soc.picorv32_AIP.memory.mem[idx]);
        end
*/
    repeat (10) begin
      repeat (10000) @(posedge clk);
      $display("+100000 cycles");
    end
    $dumpall;
    $finish;
  end

  integer                             i;
  reg     [            DATAWIDTH-1:0] tb_data;
  reg     [            DATAWIDTH-1:0] dataSet        [SIZE_MEM0-1:0];
  reg     [(DATAWIDTH*SIZE_MEM0)-1:0] dataSet_packed;

  integer                             cycle_cnt = 0;

  always @(posedge clk) count_cycle <= rst ? count_cycle + 1 : 0;

  always @* begin

    irq = &count_cycle[17-1:0];
  end

  always @(posedge clk) begin
    cycle_cnt <= cycle_cnt + 1;
  end


  assign rst_a = ((cycle_cnt > 50) || (cycle_cnt < 5)) ? 1'b1 : 1'b0;

  wire led1, led2, led3, led4, led5;
  wire ledr_n, ledg_n;

  wire [6:0] leds = {!ledg_n, !ledr_n, led5, led4, led3, led2, led1};


  wire ser_rx;
  wire ser_tx;

  reg uart_rx_in;
  wire uart_tx_out;

  reg [SIZE_MEM0/2:0] firmware_file;
  reg [31:0] mem[0:SIZE_MEM0-1];

  initial begin
    if (!$value$plusargs("firmware=%s", firmware_file)) begin
      firmware_file = "firmware/main_fw.txt";
      $display("Firmware charged!");
    end
    $readmemh(firmware_file, mem);
  end

  always @(leds) begin
    #1 $display("%b", leds);
  end

  pico_mini_soc uut (
      .clk   (clk),
      .rst   (rst_a),
      .ena   (en_s),
      .led1  (led1),
      .led2  (led2),
      .led3  (led3),
      .led4  (led4),
      .led5  (led5),
      .ledr_n(ledr_n),
      .ledg_n(ledg_n),
      .ser_rx(ser_rx),
      .ser_tx(ser_tx),
      .irq_5 (1'b0),
      .o_pwm (pwm),
      .io_gpio(io_port)
  );

  wire clk_12Mhz;
  reg [1:0] cont;
  wire locked;

  always @(posedge clk) begin
    if (!rst_a) cont = 0;
    else cont <= cont + 1'b1;
  end
  assign clk_12Mhz = clk;  //(cont== 2'b11)? 1'b1: 1'b0;

  reg [7:0] buffer;

  always begin
    @(negedge ser_tx);

    repeat (ser_half_period) @(posedge clk_12Mhz);
    ->ser_sample;  // start bit

    repeat (8) begin
      repeat (ser_half_period) @(posedge clk_12Mhz);
      repeat (ser_half_period) @(posedge clk_12Mhz);
      buffer = {ser_tx, buffer[7:1]};
      ->ser_sample;  // data bit
    end

    repeat (ser_half_period) @(posedge clk_12Mhz);
    repeat (ser_half_period) @(posedge clk_12Mhz);
    ->ser_sample;  // stop bit

    if (buffer < 32 || buffer >= 127) $display("Serial data: %d", buffer);
    else $display("Serial data: '%c'", buffer);
  end



  initial begin
    clk        = 1'b1;
    en_s       = 1'b1;

    i          = 'd0;
    rst        = 1'b0;  // reset is active
    uart_rx_in = 1'b0;
    #(CYCLE) rst = 1'b1;  // at time #n release reset

    ext_enable = 16'h00FF;
    ext_data = 16'h1234;

    // #(900000 * CYCLE);
    // $display($time, " << finishing Simulation >>");
  end



endmodule
