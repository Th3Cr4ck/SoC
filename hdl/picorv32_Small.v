/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */


module picorv32_Small (
    input clk,
    input resetn,

    output        iomem_valid,
    input         iomem_ready,
    output [ 3:0] iomem_wstrb,
    output [31:0] iomem_addr,
    output [31:0] iomem_wdata,
    input  [31:0] iomem_rdata,

    input irq_5,
    input irq_6,
    input irq_7,

    output ser_tx,
    input  ser_rx
);

  parameter [0:0] ENABLE_COUNTERS = 1;
  parameter [0:0] ENABLE_COUNTERS64 = 1;
  parameter [0:0] ENABLE_REGS_16_31 = 1;
  parameter [0:0] ENABLE_REGS_DUALPORT = 1;
  parameter [0:0] TWO_STAGE_SHIFT = 1;
  parameter [0:0] BARREL_SHIFTER = 1;
  parameter [0:0] TWO_CYCLE_COMPARE = 0;
  parameter [0:0] TWO_CYCLE_ALU = 0;
  parameter [0:0] COMPRESSED_ISA = 1;
  parameter [0:0] CATCH_MISALIGN = 1;
  parameter [0:0] CATCH_ILLINSN = 1;
  parameter [0:0] ENABLE_PCPI = 0;
  parameter [0:0] ENABLE_MUL = 1;
  parameter [0:0] ENABLE_FAST_MUL = 1;
  parameter [0:0] ENABLE_DIV = 0;
  parameter [0:0] ENABLE_IRQ = 1;
  parameter [0:0] ENABLE_IRQ_QREGS = 1;
  parameter [0:0] ENABLE_IRQ_TIMER = 1;
  parameter [0:0] ENABLE_TRACE = 1;
  parameter [0:0] REGS_INIT_ZERO = 0;
  parameter [31:0] MASKED_IRQ = 32'h0000_0000;
  parameter [31:0] LATCHED_IRQ = 32'hffff_ffff;


  parameter [0:0] ENABLE_COMPRESSED = 0;


  localparam LOWLIMIT_ROM = 32'h0000_0000;
  localparam HIGHLIMIT_ROM = 32'h1FFF_FFFF;
  localparam LOWLIMIT_RAM = 32'h2000_0000;
  localparam HIGHLIMIT_RAM = 32'h3FFF_FFFF;

  //parameter integer MEM_WORDS = 256;
  parameter integer MEM_WORDS_ROM = 8192;
  parameter integer MEM_WORDS_RAM = 2048;
  parameter [31:0] STACKADDR = LOWLIMIT_RAM + (4 * MEM_WORDS_RAM);
  parameter [31:0] PROGADDR_RESET = LOWLIMIT_ROM;
  parameter [31:0] PROGADDR_IRQ = LOWLIMIT_ROM + 32'h0000_0010;


  reg [31:0] irq;
  wire irq_stall = 0;
  wire irq_uart = 0;

  always @* begin
    irq = 0;
    irq[3] = irq_stall;
    irq[4] = irq_uart;
    irq[5] = irq_5;
    irq[6] = irq_6;
    irq[7] = irq_7;
  end

  wire mem_valid; // Solicitud de lectura o escritura, activa en 1
  wire mem_instr; // Tipo de instruccion de memoria: 1 fetch instruction, 0 load/store data
  wire mem_ready; // Indica transaccion finalizada, activa en 1
  wire [31:0] mem_addr;
  wire [31:0] mem_wdata; 
  wire [ 3:0] mem_wstrb; // Byte enable de escritura. 0000 indica lectura
  wire [31:0] mem_rdata, mem_rdata_mem, mem_rdata_ipcore;

  reg rom_ready;
  wire [31:0] rom_mem_rdata;

  reg ram_ready;
  wire [31:0] ram_rdata;

  wire sel_mem;

  assign iomem_valid = mem_valid && (mem_addr[31:24] >= 8'h80);
  assign iomem_wstrb = mem_wstrb;
  assign iomem_addr  = mem_addr;
  assign iomem_wdata = mem_wdata;

  localparam UARTSIMPLE_BASE_ADDR = 32'h50002000;

  wire simpleuart_reg_div_sel = mem_valid && (mem_addr == UARTSIMPLE_BASE_ADDR);
  wire [31:0] simpleuart_reg_div_do;

  wire simpleuart_reg_dat_sel = mem_valid && (mem_addr == (UARTSIMPLE_BASE_ADDR + 32'h0000_0004));
  wire [31:0] simpleuart_reg_dat_do;
  wire simpleuart_reg_dat_wait;

  assign mem_ready = (iomem_valid && iomem_ready) || rom_ready || ram_ready ||
			simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);

  assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata
  : rom_ready ? rom_mem_rdata
  : ram_ready ? ram_rdata
  : simpleuart_reg_div_sel ? simpleuart_reg_div_do
  : simpleuart_reg_dat_sel ? simpleuart_reg_dat_do
  : 32'h 0000_0000;

  always @(posedge clk) begin
    ram_ready <= mem_valid && !mem_ready && (mem_addr >= LOWLIMIT_RAM && mem_addr < HIGHLIMIT_RAM);
    rom_ready <= mem_valid && !mem_ready && (mem_addr >= LOWLIMIT_ROM && mem_addr < HIGHLIMIT_ROM);
  end

  picorv32 #(
      .ENABLE_COUNTERS     (ENABLE_COUNTERS),
      .ENABLE_COUNTERS64   (ENABLE_COUNTERS64),
      .ENABLE_REGS_16_31   (ENABLE_REGS_16_31),
      .ENABLE_REGS_DUALPORT(ENABLE_REGS_DUALPORT),
      .TWO_STAGE_SHIFT     (TWO_STAGE_SHIFT),
      .BARREL_SHIFTER      (BARREL_SHIFTER),
      .TWO_CYCLE_COMPARE   (TWO_CYCLE_COMPARE),
      .TWO_CYCLE_ALU       (TWO_CYCLE_ALU),
      .COMPRESSED_ISA      (COMPRESSED_ISA),
      .CATCH_MISALIGN      (CATCH_MISALIGN),
      .CATCH_ILLINSN       (CATCH_ILLINSN),
      .ENABLE_PCPI         (ENABLE_PCPI),
      .ENABLE_MUL          (ENABLE_MUL),
      .ENABLE_FAST_MUL     (ENABLE_FAST_MUL),
      .ENABLE_DIV          (ENABLE_DIV),
      .ENABLE_IRQ          (ENABLE_IRQ),
      .ENABLE_IRQ_QREGS    (ENABLE_IRQ_QREGS),
      .ENABLE_IRQ_TIMER    (ENABLE_IRQ_TIMER),
      .ENABLE_TRACE        (ENABLE_TRACE),
      .REGS_INIT_ZERO      (REGS_INIT_ZERO),
      .MASKED_IRQ          (MASKED_IRQ),
      .LATCHED_IRQ         (LATCHED_IRQ),
      .PROGADDR_RESET      (PROGADDR_RESET),
      .PROGADDR_IRQ        (PROGADDR_IRQ),
      .STACKADDR           (STACKADDR)
  ) cpu (
      .clk      (clk),
      .resetn   (resetn),
      .mem_valid(mem_valid),
      .mem_instr(mem_instr),
      .mem_ready(mem_ready),
      .mem_addr (mem_addr),
      .mem_wdata(mem_wdata),
      .mem_wstrb(mem_wstrb),
      .mem_rdata(mem_rdata),
      .irq      (irq)
  );

  picosoc_mem #(
      .WORDS(MEM_WORDS_RAM)
  ) memory (
      .clk(clk),
      .wen((mem_valid && !mem_ready && (mem_addr >= LOWLIMIT_RAM && mem_addr < HIGHLIMIT_RAM)) 
            ? mem_wstrb : 4'b0),
      .addr(mem_addr[31:2]),
      .wdata(mem_wdata),
      .rdata(ram_rdata)
  );

  picosoc_mem_rom #(
      .WORDS(MEM_WORDS_ROM)
  ) memoryROM (
      .clk  (clk),
      .addr (mem_addr[31:2]),  // Direccionamiento alineado a 4 bytes, ignora los primeros dos bits
      .rdata(rom_mem_rdata)
  );

  simpleuart simpleuart (
      .clk   (clk),
      .resetn(resetn),

      .ser_tx(ser_tx),
      .ser_rx(ser_rx),

      .reg_div_we(simpleuart_reg_div_sel ? mem_wstrb : 4'b0000),
      .reg_div_di(mem_wdata),
      .reg_div_do(simpleuart_reg_div_do),

      .reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b0),
      .reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
      .reg_dat_di  (mem_wdata),
      .reg_dat_do  (simpleuart_reg_dat_do),
      .reg_dat_wait(simpleuart_reg_dat_wait)
  );
 
endmodule


module picosoc_mem_rom #(
    parameter integer WORDS = 256
) (
    input clk,
    input [($clog2(WORDS)-1):0] addr,
    output reg [31:0] rdata
);
  reg [31:0] mem[0:WORDS-1];

  initial begin
    $readmemh("firmware/main_fw.txt", mem);
  end

  always @(posedge clk) begin
    rdata <= mem[addr];
  end
endmodule

module picosoc_mem #(
    parameter integer WORDS = 256
) (
    input                        clk,
    input  [                3:0] wen,
    input  [($clog2(WORDS)-1):0] addr,
    input  [               31:0] wdata,
    output [               31:0] rdata
);
  reg [7:0] mem0[0:WORDS-1];
  reg [7:0] mem1[0:WORDS-1];
  reg [7:0] mem2[0:WORDS-1];
  reg [7:0] mem3[0:WORDS-1];

  reg [(32-1):0] addr_reg0;
  reg [(32-1):0] addr_reg1;
  reg [(32-1):0] addr_reg2;
  reg [(32-1):0] addr_reg3;

  always @(posedge clk) begin
    addr_reg0 <= addr;
    if (wen[0]) mem0[addr] <= wdata[7:0];
  end

  always @(posedge clk) begin
    addr_reg1 <= addr;
    if (wen[1]) mem1[addr] <= wdata[15:8];
  end

  always @(posedge clk) begin
    addr_reg2 <= addr;
    if (wen[2]) mem2[addr] <= wdata[23:16];
  end

  always @(posedge clk) begin
    addr_reg3 <= addr;
    if (wen[3]) mem3[addr] <= wdata[31:24];
  end

  assign rdata = {mem3[addr_reg3], mem2[addr_reg2], mem1[addr_reg1], mem0[addr_reg0]};

  function integer CeilLog2;
    input integer data;
    integer i, result;
    begin
      result = 1;
      for (i = 0; 2 ** i < data; i = i + 1) result = i + 1;
      CeilLog2 = result;
    end
  endfunction

endmodule

