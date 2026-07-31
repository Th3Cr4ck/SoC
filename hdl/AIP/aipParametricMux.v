
module aipParametricMux
#(
    parameter DATAWIDTH = 32,
    parameter SELBITS = 2
)
(
    data_in,
    sel,
    data_out
);

    input [((2**SELBITS)*DATAWIDTH)-1:0] data_in;
    input [SELBITS-1:0] sel;
    output [DATAWIDTH-1:0] data_out;

    wire [DATAWIDTH-1:0] data_mux [0:((2**SELBITS)-1)];

    genvar index;
    generate
        for (index = 0; index < (2**SELBITS); index = index + 1) begin : MUX
            assign data_mux[index][DATAWIDTH-1:0] = data_in[(DATAWIDTH*index)+(DATAWIDTH-1):DATAWIDTH*index];
        end
    endgenerate

    assign data_out = data_mux[sel];

endmodule
