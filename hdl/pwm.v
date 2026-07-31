module pwm #(
    parameter DATA_WIDTH = 16
) (
    input                   clk,
    input                   rst_n,
    input                   i_en,        // Periph enable
    input                   i_output_en, // PWM enable
    input  [DATA_WIDTH-1:0] i_prescaler,
    input  [DATA_WIDTH-1:0] i_period,
    input  [DATA_WIDTH-1:0] i_duty,
    input                   i_polarity,  // 0 active_low, 1 active_high 
    output                  o_pwm
);

  wire w_tick;
  reg [DATA_WIDTH-1:0] r_count_pwm = 0;
  wire w_rst_prescaler;

  // If rst_n or perip disabled, reset prescaler
  assign w_rst_prescaler_n = rst_n & i_en;

  prescaler #(
      .WIDTH(DATA_WIDTH)
  ) u_prescaler (
      .clk(clk),
      .rst_n(w_rst_prescaler_n),
      .en(i_en),
      .i_prescaler_val(i_prescaler),
      .o_tick(w_tick)
  );

  
  assign o_pwm = (~i_output_en | ~i_en) ? 1'b0 : // Disabled output
    (r_count_pwm < i_duty) ? i_polarity : ~i_polarity; // Assign polarity bit

  always @(posedge clk or negedge rst_n) begin

    if (~rst_n | ~i_en) begin
      r_count_pwm <= 0;
    end else if (w_tick) begin
      if (r_count_pwm == (i_period - 1)) r_count_pwm <= 0;
      else r_count_pwm <= r_count_pwm + 1;
    end

  end

endmodule
