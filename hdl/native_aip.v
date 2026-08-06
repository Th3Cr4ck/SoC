// Connection PicoRV32 <-> AIP

module native_aip (
    input i_clk,
    input i_rst,

    input        i_cpu_mem_valid,  //CPU valid
    input [31:0] i_cpu_mem_addr,   //CPU Addr
    input [31:0] i_cpu_mem_wdata,  //CPU wdata
    input        i_cpu_mem_wen,    //CPU wen condition

    output reg [31:0] o_cpu_mem_rdata,  //Read for CPU
    output reg        o_cpu_mem_ready,  //ready to CPU
    output            o_cpu_irq,        //To produce Irq to CPU?

    // aip interface
    input             i_aip_sel,      //CPU Addr + valid condition
    input             i_aip_enable,   //enAIP
    input      [31:0] i_aip_dataOut,  //dataOutAIP
    output     [31:0] o_aip_dataIn,   //dataInAIP
    output     [ 4:0] o_aip_config,   //configAIP
    output reg        o_aip_read,     //readAIP
    output reg        o_aip_write,    //writeAIP
    output            o_aip_start,    //startAIP
    input             i_aip_int,      //intAIP--------INT

    output o_core_int  //intAIP----------INT TO CPU
);
  wire [31:0] reg0_aipDataOut;  // aipDataOut
  reg  [31:0] reg4_aipDataIn;  // aipDataIn
  reg  [31:0] reg8_aipConfig;  // aipConfig
  reg  [31:0] reg12_start;
  reg         start_w;
  wire        busCtrl_askWrite;
  wire        busCtrl_askRead;
  wire        busCtrl_doWrite;
  wire        busCtrl_doRead;

  assign o_aip_dataIn = reg4_aipDataIn;   //dataInAIP
  assign o_aip_config = reg8_aipConfig;   //configAIP
  assign o_aip_start = start_w;           //startAIP
  assign o_core_int = i_aip_int;          //intAIP---INT

  assign reg0_aipDataOut = i_aip_dataOut; //dataOutAIP

  // Read
  always @(*) begin
    o_cpu_mem_rdata = 32'h0;

    case (i_cpu_mem_addr[7:0])
      8'h0c: begin  //
      end
      8'h08: begin
      end
      8'h04: begin
      end
      8'h00: begin
        o_cpu_mem_rdata = reg0_aipDataOut;
      end
      default: begin
      end
    endcase
  end

  assign busCtrl_askWrite = ((i_aip_sel && i_aip_enable) && (i_cpu_mem_wen));
  assign busCtrl_askRead = ((i_aip_sel && i_aip_enable) && (!((i_cpu_mem_wen))));
  assign busCtrl_doWrite = (((i_aip_sel && i_aip_enable)) && (i_cpu_mem_wen));
  assign busCtrl_doRead = (((i_aip_sel && i_aip_enable && i_cpu_mem_valid && o_cpu_mem_ready) ) && (! ((i_cpu_mem_wen))) && (!o_aip_write));

  // Write
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      reg4_aipDataIn <= 32'h0;
      reg8_aipConfig <= 32'h0;
      reg12_start <= 32'h0;
      o_cpu_mem_ready <= 1'b0;
    end else begin
      o_cpu_mem_ready <= i_aip_sel;

      case (i_cpu_mem_addr[7:0])
        8'h0c: begin
          if (busCtrl_doWrite) begin
            reg12_start <= i_cpu_mem_wdata[31:0];
          end
        end
        8'h08: begin
          if (busCtrl_doWrite) begin
            reg8_aipConfig <= i_cpu_mem_wdata[31:0];
          end
        end
        8'h04: begin
          if (busCtrl_doWrite) begin
            reg4_aipDataIn <= i_cpu_mem_wdata[31:0];
          end
        end
        8'h00: begin
        end
        default: begin
        end
      endcase
    end
  end

  // Buffer
  // Write and read should be filtered out
  // when no write_data, write_conf or read_data are issued
  always @(*) begin
    o_aip_read <= busCtrl_doRead && (i_cpu_mem_addr[7:0] == 8'h00);
    // start
    if (busCtrl_doWrite && (i_cpu_mem_addr[7:0] == 8'h0c)) start_w <= i_cpu_mem_wdata[0];
    else start_w <= 1'b0;
  end

  always @(posedge i_clk) begin
    o_aip_write <= busCtrl_doWrite && (i_cpu_mem_addr[7:0] == 8'h04);
  end
endmodule
