/******************************************************************
* Description
*
* SystemVerilog FSM template with registered outputs
*
* Reset: Async active low
*
******************************************************************/

module fsm_reg (
    input logic clk,
    input logic rstn,
    input logic start,
    input logic rot_vec,
    input logic x_pos,
    input logic y_pos,
    input logic z_half_pi,
    input logic z_half_lpi,
    input logic rot_half_pi,
    input logic rot_half_lpi,
    input logic full_i,
    input logic rot_gt0,

    output logic busy,
    output logic done,
    output logic [1:0] sel_x_curr,
    output logic [1:0] sel_y_curr,
    output logic [1:0] sel_rot_ini,
    output logic [1:0] sel_x_o,
    output logic [1:0] sel_y_o,
    output logic sel_z_o,
    output logic sel_z_curr,
    output logic x_curr_en,
    output logic y_curr_en,
    output logic z_curr_en,
    output logic rot_ini_en,
    output logic x_o_en,
    output logic y_o_en,
    output logic z_o_en,
    output logic i_en,
    output logic z_curr_clr,
    output logic rot_ini_clr,
    output logic i_clr
);

  typedef enum logic [2:0] {
    S1_IDLE,
    S2_PRE_ROT,
    S3_ROT,
    S4_OUT,
    S5_DONE,
    XX = 'x
  } state_t;  //For FSM states

  //typedef definitions
  state_t state;
  state_t next;

  //(1)State register
  always_ff @(posedge clk or negedge rstn)
    if (!rstn) state <= S1_IDLE;
    else state <= next;

  //(2)Combinational next state logic
  always_comb begin
    next = XX;
    unique case (state)

      S1_IDLE:
      if (start) next = S2_PRE_ROT;
      else next = S1_IDLE;

      S2_PRE_ROT: next = S3_ROT;

      S3_ROT:
      if (full_i) next = S4_OUT;
      else next = S3_ROT;

      S4_OUT: next = S5_DONE;

      S5_DONE: next = S1_IDLE;

    endcase
  end

  //(3)Registered output logic
  always_ff @(posedge clk or negedge rstn) begin
  // always_comb begin
    if (!rstn) begin
      busy    <= 0;
      done    <= 0;
      sel_x_curr <= 0;
      sel_y_curr <= 0;
      sel_rot_ini <= 0;
      sel_x_o <= 0;
      sel_y_o <= 0;
      sel_z_o <= 0;
      sel_z_curr <= 0;
      x_curr_en <= 0;
      y_curr_en <= 0;
      z_curr_en <= 0;
      rot_ini_en <= 0;
      x_o_en <= 0;
      y_o_en <= 0;
      z_o_en <= 0;
      i_en <= 0;
      z_curr_clr <= 0;
      rot_ini_clr <= 0;
      i_clr <= 0;
    end else begin
      // Default values
      busy    <= 1;
      done    <= 0;
      sel_x_curr <= 0;
      sel_y_curr <= 0;
      sel_rot_ini <= 0;
      sel_x_o <= 0;
      sel_y_o <= 0;
      sel_z_o <= 0;
      sel_z_curr <= 0;
      x_curr_en <= 0;
      y_curr_en <= 0;
      z_curr_en <= 0;
      rot_ini_en <= 0;
      x_o_en <= 0;
      y_o_en <= 0;
      z_o_en <= 0;
      i_en <= 0;
      z_curr_clr <= 0;
      rot_ini_clr <= 0;
      i_clr <= 0;

      unique case (next)

        S1_IDLE: begin
          busy <= 1'b0;
        end

        S2_PRE_ROT: begin

          sel_x_curr <= (~rot_vec && x_pos) ? 2'd1 : 2'd2;
          sel_y_curr <= (~rot_vec && x_pos) ? 2'd1 : 2'd2;
          sel_z_curr <= 1'b1;  // z_i - rot_ini_v

          //sel_rot_ini
          if (rot_vec && z_half_pi) sel_rot_ini <= 2'd1;  // pi/2
          else if (rot_vec && z_half_lpi) sel_rot_ini <= 2'd0;  // -pi/2
          else if (~rot_vec && y_pos) sel_rot_ini <= 2'd3;  // pi
          else sel_rot_ini <= 2'd2;  // -pi

          x_curr_en <= 1'b1;
          y_curr_en <= 1'b1;
          z_curr_en <= 1'b1;
          rot_ini_en <= 1'b1;

          z_curr_clr <= ~rot_vec;
          rot_ini_clr <= ((rot_vec && ~z_half_pi && ~z_half_lpi) || ~rot_vec && ~x_pos) ? 1'b1 : 1'b0;
          i_clr <= 1'b1;

        end

        S3_ROT: begin

          x_curr_en <= ~full_i;
          y_curr_en <= ~full_i;
          z_curr_en <= ~full_i;
          i_en <= ~full_i;

          sel_z_curr <= 1'b0;  // z_nxt

        end

        S4_OUT: begin

          if (rot_vec && rot_half_pi) begin
            sel_x_o <= 2'd0;  // -y_curr
            sel_y_o <= 2'd1;  // x_curr
          end else if (rot_vec && rot_half_lpi) begin
            sel_x_o <= 2'd1;  // y_curr
            sel_y_o <= 2'd0;  // -x_curr
          end else begin
            sel_x_o <= 2'd2;  // x_curr
            sel_y_o <= 2'd2;  // y_curr
          end

          sel_z_o <= (rot_gt0 && ~rot_vec);

          x_o_en <= 1'b1;
          y_o_en <= 1'b1;
          z_o_en <= 1'b1;

        end

        S5_DONE: begin
          done <= 1'b1;
          busy <= 1'b0;
        end

      endcase
    end
  end
endmodule
