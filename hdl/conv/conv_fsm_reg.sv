/******************************************************************
* Description
*
* SystemVerilog FSM template with registered outputs
*
* Reset: Async active low
*
* Author:
* email :	
* Date  :	
******************************************************************/

module conv_fsm_reg (
   input  logic        clk,
   input  logic        rstn,
   input  logic        start_in,
	input  logic        comp_i_sizeY_in, 
	input  logic        comp_i_sizeX_in, 
	input  logic        comp_j_valid1_in, 
	input  logic        comp_j_valid2_in, 
	output logic		  selI_o,
	output logic		  selJ_o,
	output logic		  selK_o,
	output logic		  selY_o,
	output logic		  i_en_o,
	output logic		  j_en_o,
	output logic		  k_en_o,
	output logic		  i_clr_o,
	output logic		  j_clr_o,
	output logic		  memY_addr_en_o,
	output logic		  memX_addr_en_o,
	output logic		  memZ_addr_en_o,
	output logic		  memY_addr_clr_o,
	output logic		  memX_addr_clr_o,
	output logic		  memZ_addr_clr_o,
	output logic		  dataZ_en_o,
	output logic		  dataZ_clr_o,
	output logic		  busy_o,
	output logic		  done_o,
	output logic		  writeZ_o
);

typedef enum logic [4:0] {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, XX='x} state_t; //For FSM states

 //typedef definitions
 state_t state;
 state_t next;

 //(1)State register
 always_ff@(posedge clk or negedge rstn)
     if(!rstn) state <= S1;                                            
     else      state <= next;

 //(2)Combinational next state logic
 always_comb begin
     next = XX;
     unique case(state)
         S1:  if (start_in)			next = S2;
              else						next = S1;                        
         S2:  if (comp_i_sizeY_in)	next = S3;
				  else						next = S9;
			S3:  if (comp_j_valid1_in)	next = S4;
				  else						next = S7;
			S4:								next = S5;
			S5:								next = S6;
			S6:  if (comp_j_valid1_in)	next = S4;
				  else						next = S7;
			S7:								next = S8;
			S8:  if (comp_i_sizeY_in)	next = S3;
				  else						next = S9;
			S9:  if (comp_i_sizeX_in)	next = S10;
				  else						next = S16;
			S10: if (comp_j_valid2_in)	next = S11;
				  else						next = S14;
			S11:								next = S12;
			S12:								next = S13;
			S13: if (comp_j_valid2_in)	next = S11;
				  else						next = S14;
			S14:								next = S15;
			S15: if (comp_i_sizeX_in)	next = S10;
				  else						next = S16;
			S16:								next = S17;
			S17:								next = S1;
     endcase
 end

 //(3)Registered output logic (Moore outputs)
 always_ff @(posedge clk or negedge rstn) begin
     if(!rstn) begin
		  busy_o				<= 0;
		  done_o				<= 0;
		  writeZ_o			<= 0;
		  selI_o				<= 0;
		  selJ_o				<= 0;
		  selK_o				<= 0;
		  selY_o				<= 0;
		  i_en_o				<= 0;
		  j_en_o				<= 0;
		  k_en_o				<= 0;
		  i_clr_o			<= 0;
		  j_clr_o			<= 0;
		  memY_addr_en_o	<= 0;
		  memX_addr_en_o	<= 0;
		  memZ_addr_en_o	<= 0;
		  memY_addr_clr_o	<= 0;
		  memX_addr_clr_o	<= 0;
		  memZ_addr_clr_o	<= 0;
		  dataZ_en_o		<= 0;
		  dataZ_clr_o		<= 0;
     end
     else begin
		  // Default values
		  busy_o				<= 1;
		  done_o				<= 0;
		  writeZ_o			<= 0;
		  selI_o				<= 0;
		  selJ_o				<= 0;
		  selK_o				<= 0;
		  selY_o				<= 0;
		  i_en_o				<= 0;
		  j_en_o				<= 0;
		  k_en_o				<= 0;
		  i_clr_o			<= 0;
		  j_clr_o			<= 0;
		  memX_addr_en_o	<= 0;
		  memY_addr_en_o	<= 0;
		  memZ_addr_en_o	<= 0;
		  memX_addr_clr_o	<= 0;
		  memY_addr_clr_o	<= 0;
		  memZ_addr_clr_o	<= 0;
		  dataZ_en_o		<= 0;
		  dataZ_clr_o		<= 0;

             unique case(next)
                 S1:  busy_o <= 0;
					  S2: begin
					      memX_addr_clr_o <= 1;
					      memY_addr_clr_o <= 1;
					      memZ_addr_clr_o <= 1;
							i_clr_o			 <= 1;
					  end 
					  S3: begin
							dataZ_clr_o		<= 1;
							j_clr_o			<= 1;
					  end
					  S4: begin
							memX_addr_en_o	<= 1;
							memY_addr_en_o	<= 1;
					  end
					  S5: ;//empty
					  S6: begin
							dataZ_en_o		<= 1;
							j_en_o			<= 1;
					  end
					  S7: begin
							writeZ_o			<= 1;
					  end
					  S8: begin
							memZ_addr_en_o <= 1;
							i_en_o			<= 1;
					  end
					  S9: begin
							i_en_o			<= 1;
							selI_o			<= 1;
					  end
					  S10: begin
							dataZ_clr_o		<= 1;
							k_en_o			<= 1;
							j_en_o			<= 1;
							selJ_o			<= 1;
					  end
					  S11: begin
							memX_addr_en_o	<= 1;
							memY_addr_en_o	<= 1;
							selY_o			<= 1;
					  end
					  S12: ;//empty
					  S13: begin
							dataZ_en_o		<= 1;
							j_en_o			<= 1;
							k_en_o			<= 1;
							selK_o			<= 1;
					  end
					  S14: begin
							writeZ_o			<= 1;
					  end
					  S15: begin
							memZ_addr_en_o	<= 1;
							i_en_o			<= 1;
					  end
					  S16: begin
							busy_o			<= 0;
							done_o			<= 1;
					  end
					  S17: begin
							busy_o			<= 0;
					  end
             endcase
     end
 end
endmodule
