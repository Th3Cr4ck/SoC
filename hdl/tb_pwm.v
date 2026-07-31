module tb_pwm;

  localparam DATA_WIDTH = 8;

  reg                   clk;
  reg                   rst_n;
  reg                   r_en;
  reg                   r_output_en;
  reg  [DATA_WIDTH-1:0] r_prescaler;
  reg  [DATA_WIDTH-1:0] r_period;
  reg  [DATA_WIDTH-1:0] r_duty;
  reg                   r_polarity;  // 0 active_low, 1 active_high 
  wire                  w_pwm;


  pwm #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_pwm (
      .clk(clk),
      .rst_n(rst_n),
      .i_en(r_en),
      .i_output_en(r_output_en),
      .i_prescaler(r_prescaler),
      .i_period(r_period),
      .i_duty(r_duty),
      .i_polarity(r_polarity),
      .o_pwm(w_pwm)
  );

  // Clock
  always #5 clk = ~clk;

  // Test
  initial begin
    $dumpfile("pwm.vcd");
    $dumpvars(0);
    clk = 0;
    rst_n = 1;
    r_en = 1;
    r_output_en = 1;
    r_prescaler = 4;
    r_period = 8;
    r_duty = 6;
    r_polarity = 1;

    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    repeat ((r_prescaler * r_period + 10) * 2) begin
      @(posedge clk);
    end
    
    r_prescaler = 2;
    r_period = 10;
    r_duty = 2;
    r_polarity = 0;

    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    repeat ((r_prescaler * r_period + 10) * 2) begin
      @(posedge clk);
    end

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    r_output_en = 0;
    @(posedge clk);

    repeat ((r_prescaler * r_period + 10) * 2) begin
      @(posedge clk);
    end

    r_output_en = 1;
    r_en = 0;
    @(posedge clk);

    repeat ((r_prescaler * r_period + 10) * 2) begin
      @(posedge clk);
    end

    $finish;
  end

endmodule
