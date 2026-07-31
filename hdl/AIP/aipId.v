
module aipId
#(
    parameter SIZE_REG = 'd32,
    parameter ID = 32'h00001001
)
(
    clk,
    data_IP_ID
);

    input wire clk;
    output reg [SIZE_REG-1:0] data_IP_ID;

    always @(posedge clk)
        data_IP_ID <= ID;

endmodule
