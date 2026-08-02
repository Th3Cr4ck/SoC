/*
 * Author:         Abisai
 * Create Date:    10:59:05 03/23/2017 
 * Module Name:    simple_dual_port_ram_single_clk 
 * Description: 
 * - Dual port RAM
 * - With WR enable
 * - Sync in/out data ports
 * - Single clock
 * Revision: 
 * Revision 0.01 - File Created
 * Additional Comments: 
 *
 */

module simple_dual_port_ram_single_clk
#(
    parameter DATA_WIDTH    =   12,     // Datawidth of data
    parameter ADDR_WIDTH    =   6       // Address bits
)   
(
    input                           Write_clock__i, 
    input                           Write_enable_i,
    input       [(ADDR_WIDTH-1):0]  Write_addres_i,
    input       [(ADDR_WIDTH-1):0]  Read_address_i, 
    input       [(DATA_WIDTH-1):0]  data_input___i,
    output  reg [(DATA_WIDTH-1):0]  data_output__o
);

    reg [(DATA_WIDTH-1):0] RAM_Structure [2**ADDR_WIDTH-1:0];
    
    always @(posedge Write_clock__i) begin
        if (Write_enable_i) begin
            RAM_Structure[Write_addres_i] = data_input___i;
        end
        
        data_output__o <= RAM_Structure[Read_address_i];
    end
    
endmodule
