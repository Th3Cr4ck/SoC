`timescale 1ns / 1ns
`define EOF 32'hFFFF_FFFF
`define NULL 0

module tb_ID00005010 #(
    // parameter id00001001_DATA_WIDTH_OUTPUT_P = 12,
    parameter CLK_PERIOD = 2
);

  //----------------------------------------------------------
  //.......MANDATORY TB PARAMETERS............................
  //----------------------------------------------------------
  localparam CYCLE = 'd20,  // Define the clock work cycle in ns (user)
  DATAWIDTH = 'd32,  // AIP BITWIDTH
  MAX_SIZE_MEM = 'd8,  // MAX MEMORY SIZE AMONG ALL AIP MEMORIES (Defined by the user)
  //------------------------------------------------------------
  //..................CONFIG VALUES.............................
  //------------------------------------------------------------           
  STATUS = 5'd30,  //Mandatory config
  IP_ID = 5'd31,  //Mandatory config
  // id00005010_CConfReg = 5'd0,  // output data register
  id00001001_MDATAIN0 = 5'd0,  // output data register
  id00001001_ADATAIN0 = 5'd1, id00001001_MMEMOUT0 = 5'd2,  // input data register
  id00001001_AMEMOUT0 = 5'd3, id00001001_MMEMOUT1 = 5'd4,  // interruptions
  id00001001_AMEMOUT1 = 5'd5, id00001001_CCONFREG = 5'd0, id00001001_ACONFREG = 5'd1,
  //------------------------------------------------------------
  //..................PARAMETERS DEFINED BY THE USER............
  //------------------------------------------------------------
  id00001001_SIZE_MEM0 = 'd8,  //Size of the memories of the IP DDS
  INT_BIT_DONE = 'd0;  //Bit corresponding to the Int Done flag.

  //AIP Interface signals
  reg                  readAIP;
  reg                  writeAIP;
  reg                  startAIP;
  reg  [          4:0] configAIP;
  reg  [DATAWIDTH-1:0] dataInAIP;

  wire                 intAIP;
  wire [DATAWIDTH-1:0] dataOutAIP;

  reg clk, rst_a, en_s;
  reg iStartIPcore;

  //Auxiliar variables
  integer i;
  reg [DATAWIDTH-1:0] id00001001_tb_data;

  reg [DATAWIDTH-1:0] id00001001_dataSet[id00001001_SIZE_MEM0-1:0];
  reg [(DATAWIDTH*id00001001_SIZE_MEM0)-1:0] id00001001_dataSet_packed;

  reg [DATAWIDTH-1:0] id00001001_result[id00001001_SIZE_MEM0-1:0];
  reg [(DATAWIDTH*id00001001_SIZE_MEM0)-1:0] id00001001_result_packed;

  wire w_pwm;

  initial begin
    $dumpfile("Test_id00005010.vcd");
    $dumpvars(0, tb_ID00005010);
    $dumpall;
  end


  initial begin
    clk          = 1'b1;
    en_s         = 1'b1;
    readAIP      = 1'b0;
    writeAIP     = 1'b0;
    startAIP     = 1'b0;
    configAIP    = 5'd0;
    dataInAIP    = 32'd0;
    iStartIPcore = 1'b1;
    rst_a        = 1'b0;  // reset is active
    #3 rst_a = 1'b1;  // at time #n release reset
    #37

    // READ IP_ID
    getID(
        id00001001_tb_data);
    $display("%7T Read ID %h", $time, id00001001_tb_data);

    // READ STATUS
    getStatus(id00001001_tb_data);
    $display("%7T Read STATUS %h", $time, id00001001_tb_data);

    //(INTERRUPTIONS) 
    //FOR ENABLING INTERRUPTIONS
    // enableINT(INT_BIT_DONE);

    // $display("%7T writing to id00001001_MDATAIN0 Register", $time);
    // writeMem(id00001001_MDATAIN0, 32'h0000_beaf, 1, 0);  // 

    $display("%7T writing to CONFREG Register", $time);
    writeConfReg(id00001001_CCONFREG, 64'h0003_0002_000A_0002, 2, 0);  // 
    // writeConfReg(id00001001_CCONFREG, 32'h55555555, 1, 0);  // 

    $display("%7T sending START", $time);
    start();
    #50

    // READ STATUS
    // getStatus(
    //     id00001001_tb_data);
    // $display("%7T Read STATUS %h", $time, id00001001_tb_data);

    //CLEAR INT DONE FLAG
    // clearINT(INT_BIT_DONE);

    // READ STATUS
    // getStatus(id00001001_tb_data);
    // $display("%7T Read STATUS %h", $time, id00001001_tb_data);
    //

    #10000;

    // Change config
    $display("%7T writing to CONFREG Register", $time);
    writeConfReg(id00001001_CCONFREG, 64'h0003_0006_0008_0004, 2, 0);  // 

    #10000;

    $display($time, " << finishing Simulation >>");
    $finish;
  end

  //Clock source procedural block
  always #(CYCLE / 2) clk = !clk;



  ID00005010_pwm u_pwmModule (
      .i_clk       (clk),         // Clock
      .i_rst       (rst_a),       // reset low active
      .i_enAIP     (1'b1),
      .i_dataInAIP (dataInAIP),
      .i_configAIP (configAIP),
      .i_writeAIP  (writeAIP),
      .i_readAIP   (readAIP),
      .i_startAIP  (startAIP),
      .o_dataOutAIP(dataOutAIP),
      .o_intAIP    (intAIP),
      .o_pwm       (w_pwm)
  );



  //*******************************************************************
  //*********************TASKS DEFINITION******************************
  //*******************************************************************

  task getID;
    output [DATAWIDTH-1:0] read_ID;

    begin
      single_read(IP_ID, read_ID);
    end
  endtask

  task getStatus;
    output [DATAWIDTH-1:0] read_status;

    begin
      single_read(STATUS, read_status);
    end
  endtask

  task writeMem;
    input [4:0] config_value;
    input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
    input [DATAWIDTH-1:0] length;
    input [DATAWIDTH-1:0] offset;

    begin
      //SET POINTER
      single_write(config_value + 1, offset);

      //WRITE MEMORY
      configAIP = config_value;
      #(CYCLE)
      for (i = 0; i < length; i = i + 1) begin
        dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
        writeAIP  = 1'b1;
        #(CYCLE);
      end
      writeAIP = 1'b0;
      #(CYCLE);
    end
  endtask

  task writeConfReg;
    input [4:0] config_value;
    input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
    input [DATAWIDTH-1:0] length;
    input [DATAWIDTH-1:0] offset;

    begin
      //SET POINTER
      single_write(config_value + 1, offset);

      //WRITE MEMORY
      configAIP = config_value;
      #(CYCLE)
      for (i = 0; i < length; i = i + 1) begin
        dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
        writeAIP  = 1'b1;
        #(CYCLE);
      end
      writeAIP = 1'b0;
      #(CYCLE);
    end
  endtask



  task readMem;
    input [4:0] config_value;
    output [(DATAWIDTH*MAX_SIZE_MEM)-1:0] read_data;
    input [DATAWIDTH-1:0] length;
    input [DATAWIDTH-1:0] offset;

    begin
      //SET POINTER
      single_write(config_value + 1, offset);

      configAIP = config_value;
      #(CYCLE)
      for (i = 0; i < length; i = i + 1) begin
        readAIP = 1'b1;
        #(CYCLE);
        read_data[(i*DATAWIDTH)+:DATAWIDTH] = dataOutAIP;
      end
      readAIP = 1'b0;
      #(CYCLE);
    end
  endtask

  task enableINT;
    input [3:0] idxInt;

    reg [DATAWIDTH-1:0] read_status;
    reg [7:0] mask;

    begin

      getStatus(read_status);

      mask = read_status[23:16];  //previous stored mask
      mask[idxInt] = 1'b1;  //enabling INT bit

      single_write(STATUS, {8'd0, mask, 16'd0});  //write status reg
    end
  endtask

  task disableINT;
    input [3:0] idxInt;

    reg [DATAWIDTH-1:0] read_status;
    reg [7:0] mask;
    begin

      getStatus(read_status);

      mask = read_status[23:16];  //previous stored mask
      mask[idxInt] = 1'b0;  //disabling INT bit

      single_write(STATUS, {8'd0, mask, 16'd0});  //write status reg
    end
  endtask

  task clearINT;
    input [3:0] idxInt;

    reg [DATAWIDTH-1:0] read_status;
    reg [7:0] clear_value;
    reg [7:0] mask;

    begin

      getStatus(read_status);

      mask = read_status[23:16];  //previous stored mask
      clear_value = 7'd1 << idxInt;

      single_write(STATUS, {8'd0, mask, 8'd0, clear_value});  //write status reg
    end
  endtask

  task start;
    begin
      startAIP = 1'b1;
      #(CYCLE);
      startAIP = 1'b0;
      #(CYCLE);
    end
  endtask

  task single_write;
    input [4:0] config_value;
    input [DATAWIDTH-1:0] write_data;
    begin
      configAIP = config_value;
      dataInAIP = write_data;
      #(CYCLE) writeAIP = 1'b1;
      #(CYCLE) writeAIP = 1'b0;
      #(CYCLE);
    end
  endtask

  task single_read;
    input [4:0] config_value;
    output [DATAWIDTH-1:0] read_data;
    begin
      configAIP = config_value;
      #(CYCLE);
      readAIP = 1'b1;
      #(CYCLE);
      read_data = dataOutAIP;
      readAIP   = 1'b0;
      #(CYCLE);
    end
  endtask
endmodule
