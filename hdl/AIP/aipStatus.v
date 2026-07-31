
/*
-------------------------------------------------------------------------------------------------
|                                   STATUS/INTERRUPTION FLAGS                                   |
-------------------------------------------------------------------------------------------------
|     7     |     6     |     5     |     4     |     3     |     2     |     1     |     0     |
-------------------------------------------------------------------------------------------------
|     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |   Done    |
-------------------------------------------------------------------------------------------------
|     15    |     14    |     13    |     12    |     11    |     10    |     9     |     8     |
-------------------------------------------------------------------------------------------------
|     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |   Busy    |
-------------------------------------------------------------------------------------------------
UD = User Define
*/

module aipStatus
(
    clk,
    rst,
    enSet,
    dataIn,
    intIP,
    statusIP,
    dataStatus,
    intReq
);

    localparam REGWIDTH = 'd32;
    localparam STATUSFLAGS = 'd8;
    localparam INTFLAGS = 'd8;

    input clk;
    input rst;
    input enSet;
    input [REGWIDTH-1:0] dataIn;
    input [INTFLAGS-1:0] intIP;
    input [STATUSFLAGS-1:0] statusIP;
    output [REGWIDTH-1:0] dataStatus;
    output intReq;

    reg [STATUSFLAGS-1:0] regStatus;
    reg [INTFLAGS-1:0] regInt;
    wire [INTFLAGS-1:0] wireInt;
    reg [INTFLAGS-1:0] regMaskInt;
    wire [INTFLAGS-1:0] wireMaskInt;

    assign dataStatus = {8'h00, regMaskInt,regStatus, regInt};
    assign intReq = ~|(regInt & regMaskInt);
    assign wireInt = dataIn[7:0];
    assign wireMaskInt = dataIn[23:16];

    genvar i;
    generate
        for (i=0; i<STATUSFLAGS; i=i+1) begin : buff
            always @ (posedge clk or negedge rst) begin
                if(!rst)
                    regStatus[i] <= 1'b0;
                else begin
                    regStatus[i] <= statusIP[i];
                end
            end
            always @ (posedge clk or negedge rst) begin
                if(!rst)
                    regInt[i] <= 1'b0;
                else begin
                    if (wireInt[i] & enSet)
                        regInt[i] <= 1'b0;
                    else if (intIP[i])
                        regInt[i] <= 1'b1;
                    else
                        regInt[i] <= regInt[i];
                end
            end
        end
    endgenerate

    always @(posedge clk or negedge rst) begin
        if(!rst)
            regMaskInt <= {INTFLAGS{1'b0}};
        else if(enSet)
            regMaskInt <= wireMaskInt;
    end

endmodule
