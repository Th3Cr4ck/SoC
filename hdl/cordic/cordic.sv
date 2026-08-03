module cordic #(
    parameter DATA_WIDTH = 13,
    parameter QF = 10
) (
    input                          clk,
    input                          rstn,
    input                          rot_vec, // 1 rot, 0 vect
    input                          start,
    input  signed [DATA_WIDTH-1:0] x_i,
    input  signed [DATA_WIDTH-1:0] y_i,
    input  signed [DATA_WIDTH-1:0] z_i,
    output signed [DATA_WIDTH-1:0] x_o,
    output signed [DATA_WIDTH-1:0] y_o,
    output signed [DATA_WIDTH-1:0] z_o,
    output                         busy,
    output                         done
);

  localparam QI = DATA_WIDTH - QF;
  localparam signed [DATA_WIDTH-1:0] N = 12;

  localparam signed [DATA_WIDTH-1:0] DEF_0 = {DATA_WIDTH{1'b0}};

  // Q 3.10
  localparam signed [DATA_WIDTH-1:0] PI = 3217;
  localparam signed [DATA_WIDTH-1:0] PI_M = -3217;
  localparam signed [DATA_WIDTH-1:0] PI_H = 1608;
  localparam signed [DATA_WIDTH-1:0] PI_HM = -1608;

  // Angulos LUT
  reg [DATA_WIDTH-1:0] atan_table[N];
  initial begin  // Q3.10
    atan_table[0]  = 804;
    atan_table[1]  = 475;
    atan_table[2]  = 251;
    atan_table[3]  = 127;
    atan_table[4]  = 64;
    atan_table[5]  = 32;
    atan_table[6]  = 16;
    atan_table[7]  = 8;
    atan_table[8]  = 4;
    atan_table[9]  = 2;
    atan_table[10] = 1;
    atan_table[11] = 0;
  end

  // Cables
  wire signed [DATA_WIDTH-1:0] x_curr;
  wire signed [DATA_WIDTH-1:0] y_curr;
  wire signed [DATA_WIDTH-1:0] z_curr;
  wire signed [DATA_WIDTH-1:0] x_nxt;
  wire signed [DATA_WIDTH-1:0] y_nxt;
  wire signed [DATA_WIDTH-1:0] z_nxt;
  wire signed [DATA_WIDTH-1:0] rot_ini;
  wire signed [DATA_WIDTH-1:0] rot_ini_v;
  wire signed [DATA_WIDTH-1:0] rot_ini_abs;
  wire        [           3:0] i;
  wire        [           3:0] i_nxt;
  wire                         sigma;

  // Senales de control
  wire        [           1:0] sel_x_curr;
  wire        [           1:0] sel_y_curr;
  wire        [           1:0] sel_rot_ini;
  wire        [           1:0] sel_x_o;
  wire        [           1:0] sel_y_o;
  wire                         sel_z_o;
  wire                         sel_z_curr;
  wire                         x_curr_en;
  wire                         y_curr_en;
  wire                         z_curr_en;
  wire                         rot_ini_en;
  wire                         x_o_en;
  wire                         y_o_en;
  wire                         z_o_en;
  wire                         i_en;
  wire                         z_curr_clr;
  wire                         rot_ini_clr;
  wire                         i_clr;

  // Comparaciones
  wire                         x_pos;
  wire                         y_pos;
  wire                         full_i;
  wire                         z_half_pi;
  wire                         z_half_lpi;
  wire                         rot_half_pi;
  wire                         rot_half_lpi;
  wire                         rot_gt0;

  assign x_pos = x_i < 0;
  assign y_pos = y_i >= 0;
  assign full_i = i_nxt >= N;
  assign z_half_pi = z_i >= PI_H;
  assign z_half_lpi = z_i <= PI_HM;
  assign rot_half_pi = rot_ini == PI_H;
  assign rot_half_lpi = rot_ini == PI_HM;
  assign rot_gt0 = rot_ini && ~rot_vec;

  assign sigma = (z_curr >= 0 && rot_vec) || (y_curr < 0 && ~rot_vec);

  // FSM
  fsm_reg FSM (.*);

  // ROT_INI
  mux_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (2)
  ) MUX_ROT_INI (
      .clk(clk),
      .rstn(rstn),
      .enh(rot_ini_en),
      .clrh(rot_ini_clr),
      .sel_i(sel_rot_ini),
      .data_i({PI, PI_M, PI_H, PI_HM}),
      .data_o_v(rot_ini_v),
      .data_o(rot_ini)
  );

  assign rot_ini_abs = rot_ini_clr ? {DATA_WIDTH{1'b0}} : rot_ini_v;

  // X_CURR
  mux_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (2)
  ) MUX_X_CURR (
      .clk(clk),
      .rstn(rstn),
      .enh(x_curr_en),
      .clrh(1'b0),
      .sel_i(sel_x_curr),
      .data_i({DEF_0, x_i, -x_i, x_nxt}),
      .data_o_v(),
      .data_o(x_curr)
  );

  // Y_CURR
  mux_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (2)
  ) MUX_Y_CURR (
      .clk(clk),
      .rstn(rstn),
      .enh(y_curr_en),
      .clrh(1'b0),
      .sel_i(sel_y_curr),
      .data_i({DEF_0, y_i, -y_i, y_nxt}),
      .data_o_v(),
      .data_o(y_curr)
  );

  // Z_CURR
  mux_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (1)
  ) MUX_Z_CURR (
      .clk(clk),
      .rstn(rstn),
      .enh(z_curr_en),
      .clrh(z_curr_clr),
      .sel_i(sel_z_curr),
      .data_i({(z_i - rot_ini_abs), z_nxt}),
      .data_o_v(),
      .data_o(z_curr)
  );

  // I
  add_reg #(
      .DATA_WIDTH(4)  // ceil(log_2(N))
  ) ADD_REG_I (
      .clk(clk),
      .rstn(rstn),
      .enh(i_en),
      .clrh(i_clr),
      .a(i),
      .b({{3{1'b0}}, 1'b1}),  // 1
      .out_comb(i_nxt),
      .out(i)
  );

  // X_NXT
  add_sub #(
      .DATA_WIDTH(DATA_WIDTH)
  ) ADD_SUB_X_NXT (
      .a  (x_curr),
      .b  (y_curr >>> i),
      .sel(~sigma),
      .out(x_nxt)
  );

  // Y_NXT
  add_sub #(
      .DATA_WIDTH(DATA_WIDTH)
  ) ADD_SUB_Y_NXT (
      .a  (y_curr),
      .b  (x_curr >>> i),
      .sel(sigma),
      .out(y_nxt)
  );

  // Z_NXT
  add_sub #(
      .DATA_WIDTH(DATA_WIDTH)
  ) ADD_SUB_Z_NXT (
      .a  (z_curr),
      .b  (atan_table[i]),
      .sel(~sigma),
      .out(z_nxt)
  );

  // X_O
  mux_mult_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .QF(QF),
      .SEL_WIDTH(2)
  ) MUX_MULT_X_O (
      .clk(clk),
      .rstn(rstn),
      .enh(x_o_en),
      .clrh(1'b0),
      .sel_i(sel_x_o),
      .data_i({DEF_0, x_curr, y_curr, -y_curr}),
      .data_o(x_o)
  );

  // Y_O
  mux_mult_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (2)
  ) MUX_MULT_Y_O (
      .clk(clk),
      .rstn(rstn),
      .enh(y_o_en),
      .clrh(1'b0),
      .sel_i(sel_y_o),
      .data_i({DEF_0, y_curr, x_curr, -x_curr}),
      .data_o(y_o)
  );

  // Z_O
  mux_reg #(
      .DATA_WIDTH(DATA_WIDTH),
      .SEL_WIDTH (1)
  ) MUX_Z_O (
      .clk(clk),
      .rstn(rstn),
      .enh(z_o_en),
      .clrh(1'b0),
      .sel_i(sel_z_o),
      .data_i({(z_curr + rot_ini), z_curr}),
      .data_o_v(),
      .data_o(z_o)
  );
endmodule
