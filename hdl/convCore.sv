module ID00005040_convCore
#(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH  = 5
	
)(
	input clk,
	input rstn,
	input start,
	// MEMX 
	input  logic [DATA_WIDTH-1:0]	dataX,
	output logic [ADDR_WIDTH-1:0] memX_addr,
	// MEMY
	input  logic [DATA_WIDTH-1:0] dataY,
	output logic [ADDR_WIDTH-1:0]	memY_addr,
	// MEMZ
	output logic [(DATA_WIDTH*2)-1:0] dataZ,
	output logic [ADDR_WIDTH:0]       memZ_addr,
	output logic							 writeZ,
		
	input  logic [DATA_WIDTH-1:0]	config_in,

	output logic busy_out,
	output logic done_out
);

	//sizeX and sizeY from configReg
	logic [ADDR_WIDTH-1:0] sizeX;
	logic [ADDR_WIDTH-1:0] sizeY;
	assign sizeX = config_in[4:0];
	assign sizeY = config_in[9:5];
	
	// Registers i, j, k 
	logic [DATA_WIDTH-1:0] i_reg;
	logic [DATA_WIDTH-1:0] i_nxt;
	logic [DATA_WIDTH-1:0] j_reg;
	logic [DATA_WIDTH-1:0] j_nxt;
	logic [ADDR_WIDTH-1:0] k_reg;
	logic [ADDR_WIDTH-1:0] k_nxt;

	// Wire for comp_j_valid blocks
	logic comp_j_i;
	logic comp_k_0;

	// FSM DATA
	logic comp_i_sizeY;
	logic comp_i_sizeX;
	logic comp_j_sizeX;
	logic comp_j_valid1;
	logic comp_j_valid2;
	logic selI_ff;
	logic selJ_ff;
	logic selK_ff;
	logic selY_ff;
	logic i_en_ff;
	logic j_en_ff;
	logic k_en_ff;
	logic i_clr_ff;
	logic j_clr_ff;
	logic memX_addr_en_ff;
	logic memY_addr_en_ff;
	logic memZ_addr_en_ff;
	logic memX_addr_clr_ff;
	logic memY_addr_clr_ff;
	logic memZ_addr_clr_ff;
	logic dataZ_en_ff;
	logic dataZ_clr_ff;

	// ------------ FSM -------------- //
	conv_fsm_reg FSM
	(
		.clk					(clk),
		.rstn					(rstn),
		.start_in			(start),
		.comp_i_sizeY_in	(comp_i_sizeY),
		.comp_i_sizeX_in	(comp_i_sizeX),
		.comp_j_valid1_in	(comp_j_valid1),
		.comp_j_valid2_in (comp_j_valid2),
		.selI_o				(selI_ff),
		.selJ_o				(selJ_ff),
		.selK_o				(selK_ff),
		.selY_o				(selY_ff),
		.i_en_o				(i_en_ff),
		.j_en_o				(j_en_ff),
		.k_en_o				(k_en_ff),
		.i_clr_o				(i_clr_ff),
		.j_clr_o				(j_clr_ff),
		.memX_addr_en_o	(memX_addr_en_ff),
		.memY_addr_en_o	(memY_addr_en_ff),
		.memZ_addr_en_o	(memZ_addr_en_ff),
		.memX_addr_clr_o	(memX_addr_clr_ff),
		.memY_addr_clr_o	(memY_addr_clr_ff),
		.memZ_addr_clr_o	(memZ_addr_clr_ff),
		.dataZ_en_o			(dataZ_en_ff),
		.dataZ_clr_o		(dataZ_clr_ff),
		.busy_o				(busy_out),
		.done_o				(done_out),
		.writeZ_o			(writeZ)
		);


	// ------------ I_COUNTER -------------- //
	initializable_cntr 	
	#(
		.DATA_WIDTH		(DATA_WIDTH)	
	)
	iBlock
	(
		.clk					(clk),
		.rstn					(rstn),
		.sel_in				(selI_ff),
		.en_in				(i_en_ff),
		.clr_in				(i_clr_ff),
		.initial_value_in ('d1),
		.c_out				(i_reg),
		.c_nxt_out			(i_nxt)
	);


	// ------------ J_COUNTER -------------- //
	initializable_cntr 	
	#(
		.DATA_WIDTH		(DATA_WIDTH)	
	)
	jBlock
	(
		.clk					(clk),
		.rstn					(rstn),
		.sel_in				(selJ_ff),
		.en_in				(j_en_ff),
		.clr_in				(j_clr_ff),
		.initial_value_in (i_reg),
		.c_out				(j_reg),
		.c_nxt_out			(j_nxt)
	);


	// ------------ K_COUNTER -------------- //
	cntrK
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	kBlock
	(
		.clk				(clk),
		.rstn				(rstn),
		.sel_in			(selK_ff),
		.en_in			(k_en_ff),
		.sizeY_in		(sizeY),
		.k_nxt_out		(k_nxt),
		.k_out			(k_reg)
	);


	// ------------ MEMX_ADDR -------------- //
	register
	#(
		.DATA_WIDTH		(DATA_WIDTH)
	)
	memX_addr_block_reg
	(
		.clk     (clk),
		.rstn    (rstn),
		.clrh    (memX_addr_clr_ff),   
		.enh     (memX_addr_en_ff),
		.data_i  (j_reg),
		.data_o  (memX_addr)
	);


	// ------------ MEMY_ADDR -------------- //
	memY_addr_block 
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	memY_addr_block_reg 
	(
		.clk					(clk),
		.rstn					(rstn),
		.memY_addr_en_i	(memY_addr_en_ff),
		.memY_addr_clr_i	(memY_addr_clr_ff),
		.selY_i				(selY_ff),
		.i_reg_i				(i_reg),
		.j_reg_i				(j_reg),
		.k_reg_i				(k_reg),
		.memY_addr_o		(memY_addr) 
	);


	// ------------ MEMZ_ADDR -------------- //
	adder_reg
	#(
		.DATA_WIDTH		(ADDR_WIDTH+1)
	)
	memZ_addr_block_reg
	(
		.clk			(clk),
		.rstn			(rstn),
		.en_in		(memZ_addr_en_ff),
		.clr_in		(memZ_addr_clr_ff),
		.A_in			(1),
		.B_in			(memZ_addr),
		.A_plus_B_o	(memZ_addr)
	);


	// ------------ DATAZ -------------- //
	dataZ_block
	#(
		.DATA_WIDTH		(DATA_WIDTH)
	)
	dataZ_block_reg
	(
		.clk		(clk),
		.rstn		(rstn),
		.en_i		(dataZ_en_ff),
		.clr_i	(dataZ_clr_ff),
		.dataX_i	(dataX),
		.dataY_i	(dataY),
		.dataZ_o	(dataZ)
	);


	// ---------- COMPARATOR I_SIZEY ----------- //
	comparatorLessThan
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	comparator_I_sizeY
	(
		.A_i					(i_nxt),
		.B_i					(sizeY),
		.A_less_than_B_o	(comp_i_sizeY)
	);


	// ---------- COMPARATOR I_SIZEX ----------- //
	comparatorLessThan
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	comparator_I_sizeX
	(
		.A_i					(i_nxt),
		.B_i					(sizeX),
		.A_less_than_B_o	(comp_i_sizeX)
	);

	
	// ---------- COMPARATOR J_VALID_1 ----------- //
	comparatorLessThan
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	comparator_J_sizeX
	(
		.A_i					(j_nxt),
		.B_i					(sizeX),
		.A_less_than_B_o	(comp_j_sizeX)
	);

	comparatorLessOrEqualThan
	#(
		.DATA_WIDTH		(ADDR_WIDTH)
	)
	comparator_J_I
	(
		.A_i					(j_nxt),
		.B_i					(i_reg),
		.A_less_than_B_o	(comp_j_i)
	);
	assign comp_j_valid1 = comp_j_sizeX & comp_j_i;
	
	
	// ---------- COMPARATOR J_VALID_2 ----------- //
	comparatorGreatOrEqualThan
	#(
		.DATA_WIDTH(ADDR_WIDTH)
	)
	comparator_K_0
	(
		.A_i			(k_nxt),
		.B_i			(0),
		.A_great_or_equal_than_B_o	(comp_k_0)
	);
	assign comp_j_valid2 = comp_j_sizeX & comp_k_0;


endmodule
