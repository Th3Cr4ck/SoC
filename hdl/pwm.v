module pwm #(
    parameter DATA_WIDTH = 16
) (
    input                   clk,
    input                   rst_n,
    input  [DATA_WIDTH-1:0] i_prescaler,
    input  [DATA_WIDTH-1:0] i_period,
    input  [DATA_WIDTH-1:0] i_duty,
    input                   i_polarity,   // 0 active_low, 1 active_high 
    output wire             o_pwm
);

  wire w_tick;
  reg [DATA_WIDTH-1:0] r_count_pwm = 0;

  prescaler #(.WIDTH(DATA_WIDTH)) u_prescaler (
      .clk(clk),
      .rst_n(rst_n),
      .i_prescaler_val(i_prescaler),
      .o_tick(w_tick)
  );

  assign o_pwm = (r_count_pwm < i_duty) ? i_polarity : ~i_polarity;

  always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      r_count_pwm <= 0;
    end 

    else if (w_tick) begin
      if (r_count_pwm == (i_period-1)) r_count_pwm <= 0;
      else r_count_pwm <= r_count_pwm + 1;
    end

  end

endmodule
