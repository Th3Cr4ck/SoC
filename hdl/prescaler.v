/*
* Prescaler (Frequency division)
*/

module prescaler #(
    parameter WIDTH = 16
) (
    input clk,
    input rst_n,
    input [WIDTH-1:0] i_prescaler_val,
    output reg o_tick
);

  reg [WIDTH-1:0] r_count;

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      r_count <= 0;
      o_tick <= 0;
    end

    else begin
      if (r_count == (i_prescaler_val - 1)) begin
        o_tick <= 1'b1;
        r_count <= 0;
      end else begin
        o_tick <= 1'b0;
        r_count <= r_count + 1;
      end
    end

endmodule
