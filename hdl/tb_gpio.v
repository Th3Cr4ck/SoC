`timescale 1ns/1ps

module tb_gpio;

    localparam PORT_WIDTH = 16;

    reg  [PORT_WIDTH-1:0] i_mode;
    reg  [PORT_WIDTH-1:0] i_data_out;

    // Simula el dispositivo externo conectado al GPIO
    reg  [PORT_WIDTH-1:0] ext_data;
    reg                   ext_enable;

    // Bus bidireccional
    tri [PORT_WIDTH-1:0] io_port;

    // El dispositivo externo solo conduce cuando ext_enable = 1
    assign io_port = ext_enable ? ext_data : {PORT_WIDTH{1'bz}};

    // DUT
    gpio dut (
        .i_mode(i_mode),
        .i_data_out(i_data_out),
        .io_port(io_port)
    );

    initial begin

        //----------------------------------------------------------
        // Caso 1: GPIO como salida
        //----------------------------------------------------------
        $display("Caso 1: GPIO como salida");

        ext_enable = 0;
        i_mode     = 16'hFFFF;
        i_data_out = 16'hA55A;

        #10;

        $display("io_port = %h (esperado A55A)", io_port);

        //----------------------------------------------------------
        // Caso 2: GPIO como entrada
        //----------------------------------------------------------
        $display("Caso 2: GPIO como entrada");

        i_mode     = 16'h0000;
        ext_enable = 1;
        ext_data   = 16'h1234;

        #10;

        $display("io_port = %h (esperado 1234)", io_port);

        //----------------------------------------------------------
        // Caso 3: Cambiar el valor externo
        //----------------------------------------------------------
        ext_data = 16'hF0F0;

        #10;

        $display("io_port = %h (esperado F0F0)", io_port);

        //----------------------------------------------------------
        // Caso 4: Volver a salida
        //----------------------------------------------------------
        ext_enable = 0;
        i_mode     = 16'hFFFF;
        i_data_out = 16'h0F0F;

        #10;

        $display("io_port = %h (esperado 0F0F)", io_port);

        $finish;

    end

endmodule
