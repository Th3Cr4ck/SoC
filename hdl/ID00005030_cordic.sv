module ID00005030_cordic #(
    parameter DATA_WIDTH   = 32,
    parameter CONFIG_WIDTH = 5
) (
    input                     i_clk,
    input                     i_rst,
    // AIP
    input  [  DATA_WIDTH-1:0] i_dataInAIP,
    input  [CONFIG_WIDTH-1:0] i_configAIP,
    input                     i_writeAIP,
    input                     i_readAIP,
    input                     i_enAIP,
    input                     i_startAIP,
    output [  DATA_WIDTH-1:0] o_dataOutAIP,
    output                    o_intAIP
);

  localparam MEM_ADDR_MAX_WIDTH = 16;
  localparam MEM_ADDR_WIDTH = 2;
  localparam CORDIC_DATA_WIDTH = 13;
  localparam CORDIC_QF = 10;

  // Connections AIP <-> CORDIC
  wire [     DATA_WIDTH*2-1:0] w_dataConfig;
  reg  [   MEM_ADDR_WIDTH-1:0] r_addrMemOut;
  reg  [       DATA_WIDTH-1:0] r_dataMemOut;
  reg                          r_enMemOut;
  wire                         w_start;
  wire                         w_busy_core;
  wire                         w_done_core;

  // Data from Config Register
  wire [CORDIC_DATA_WIDTH-1:0] w_xIn;  // X in value
  wire [CORDIC_DATA_WIDTH-1:0] w_yIn;  // Y in value
  wire [CORDIC_DATA_WIDTH-1:0] w_zIn;  // Z in value
  wire                         w_opMode;  // Rotation or Vectoring Mode

  assign w_xIn    = w_dataConfig[15:0];
  assign w_yIn    = w_dataConfig[31:16];
  assign w_zIn    = w_dataConfig[47:32];
  assign w_opMode = w_dataConfig[48];

  // CORDIC results
  wire [CORDIC_DATA_WIDTH*3-1:0] w_results;  //[Z Y X]
  wire [  CORDIC_DATA_WIDTH-1:0] w_xOut;  // X out value
  wire [  CORDIC_DATA_WIDTH-1:0] w_yOut;  // Y out value
  wire [  CORDIC_DATA_WIDTH-1:0] w_zOut;  // Z out value
  assign w_results = {w_zOut, w_yOut, w_xOut};

  // Aux
  reg r_busy;
  reg r_done;
  reg [1:0] r_count;

  // Core
  cordic #(
      .DATA_WIDTH(CORDIC_DATA_WIDTH),
      .QF(CORDIC_QF)
  ) u_cordic (
      .clk(i_clk),
      .rstn(i_rst),
      .rot_vec(w_opMode),
      .start(w_start),
      .x_i(w_xIn),
      .y_i(w_yIn),
      .z_i(w_zIn),
      .x_o(w_xOut),
      .y_o(w_yOut),
      .z_o(w_zOut),
      .busy(w_busy_core),
      .done(w_done_core)
  );

  // AIP
  ID00005030_aip u_aip (
      .clk(i_clk),
      .rst(i_rst),
      .en (i_enAIP),

      //--- AIP ---//
      .dataInAIP(i_dataInAIP),
      .dataOutAIP(o_dataOutAIP),
      .configAIP(i_configAIP),
      .readAIP(i_readAIP),
      .writeAIP(i_writeAIP),
      .startAIP(i_startAIP),
      .intAIP(o_intAIP),

      //--- IP-core ---//
      .wrDataMemOut_0(r_dataMemOut),
      .wrAddrMemOut_0({{(MEM_ADDR_MAX_WIDTH - MEM_ADDR_WIDTH) {1'b0}}, r_addrMemOut}),
      .wrEnMemOut_0(r_enMemOut),
      .rdDataConfigReg(w_dataConfig),
      .statusIPcore_Busy(r_busy),
      .intIPCore_Done(r_done),
      .startIPcore(w_start)
  );

  // FSM
  typedef enum logic [2:0] {
    S1_IDLE,
    S2_BUSY,
    S3_WR_MEM,
    S4_DONE,
    XX = 'x
  } state_t;  //For FSM states

  //typedef definitions
  state_t state;
  state_t next;

  //(1)State register
  always_ff @(posedge i_clk or negedge i_rst)
    if (!i_rst) state <= S1_IDLE;
    else state <= next;

  //(2)Combinational next state logic
  always_comb begin
    next = XX;
    unique case (state)
      S1_IDLE:
      if (w_start) next = S2_BUSY;
      else next = S1_IDLE;

      S2_BUSY:
      if (w_done_core) next = S3_WR_MEM;
      else next = S2_BUSY;

      S3_WR_MEM:
      if (r_addrMemOut == 2'd2) next = S4_DONE;
      else next = S3_WR_MEM;

      S4_DONE: next = S1_IDLE;
    endcase
  end

  //(3)Registered output logic
  always_ff @(posedge i_clk or negedge i_rst) begin
    if (~i_rst) begin
      r_busy <= 1'b0;
      r_done <= 1'b0;
      r_enMemOut <= 1'b0;
      r_addrMemOut <= {MEM_ADDR_WIDTH{1'b0}};
      r_count <= 2'b0;

    end else begin
      // default values
      r_busy <= 1'b1;
      r_done <= 1'b0;
      r_enMemOut <= 1'b0;
      r_dataMemOut <= {DATA_WIDTH{1'b0}};
      r_addrMemOut <= {MEM_ADDR_WIDTH{1'b0}};
      r_count <= 2'b0;

      unique case (next)
        S1_IDLE: begin
          r_busy <= 1'b0;
        end

        S2_BUSY: begin
        end

        S3_WR_MEM: begin
          r_enMemOut <= 1'b1;
          r_dataMemOut <= {
            {(DATA_WIDTH - CORDIC_DATA_WIDTH) {1'b0}}
            , w_results[CORDIC_DATA_WIDTH*(r_count+1)-1-:CORDIC_DATA_WIDTH]
          };
          r_addrMemOut <= state == S3_WR_MEM ? r_addrMemOut + 1 : r_addrMemOut;
          r_count <= r_count + 1;
        end

        S4_DONE: begin
          r_busy <= 1'b0;
          r_done <= 1'b1;
        end

      endcase

    end  // else
  end  // always_ff

endmodule

