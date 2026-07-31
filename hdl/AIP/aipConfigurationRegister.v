
module aipConfigurationRegister
(
  reset,
  writeClock,
  writeEnable,
  writeAddress,
  dataInput,
  dataOutput
);
  parameter DATAWIDTH = 32;
  parameter REGISTERS = 4; // MAX 4

  localparam ADDRWIDTH = 3;

  input reset;
  input writeClock;
  input writeEnable;
  input [(ADDRWIDTH-1):0] writeAddress;
  input [(DATAWIDTH-1):0] dataInput;
  output wire [(((REGISTERS+1)*DATAWIDTH)-1):0] dataOutput;

  reg [(DATAWIDTH-1):0] regConfig [0:REGISTERS];
  reg [(DATAWIDTH-1):0] regConfigStreaming;

  assign dataOutput[(DATAWIDTH*REGISTERS) +: DATAWIDTH] = regConfigStreaming;

  genvar i;
  generate
  for (i=0; i<REGISTERS; i=i+1) begin: OUTPUTCONF
      assign dataOutput[(DATAWIDTH*i) +: DATAWIDTH] = regConfig[i];
  end
  endgenerate

  always @(posedge writeClock or negedge reset) begin
      if(!reset) begin : RESETREGCONF
          integer j;
          for (j=0; j<REGISTERS; j=j+1) begin
            regConfig[j] <= 'd0;
          end
          regConfigStreaming <= 'd0;
      end
      else begin
          if (writeEnable) begin
            if ('d4==writeAddress) begin
              regConfigStreaming <= dataInput;
            end
            else begin
              regConfig[writeAddress] <= dataInput;
            end
          end
      end
  end

endmodule
