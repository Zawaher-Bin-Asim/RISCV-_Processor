`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2024 10:55:29 AM
// Design Name: 
// Module Name: singlecycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include"sc.svh"

module pipline(
input logic clk,reset,enable_f,enable_pc,
input logic [width-1:0]clk_rate,
output logic [width-1:0]alu_out,fetch_instruction,
output logic uart_out,
output logic uart_stop
  );
  logic [width_alu-1:0]alu_op;
  logic reg_wr,reg_wr_e,reg_wr_m,rs1_sel,rs2_sel,rd_en,wr_en,csr_reg_wr,csr_reg_rd,is_mret;
  logic [1:0]wb_sel;
  logic [7:0]timer;
  logic [width-1:0]timer_interrupt_occured,external_interrupt;
  logic [width-1:0]interuppt;


  assign interuppt = timer_interrupt_occured | external_interrupt;

datapath DP(.alu_op(alu_op),.clk(clk),.clk_rate(clk_rate), .reset(reset),.enable_f(enable_f),.enable_pc(enable_pc),.interuppt(interuppt),
            .reg_wr(reg_wr),.reg_wr_e(reg_wr_e),.reg_wr_m(reg_wr_m),.rs1_sel(rs1_sel),.rs2_sel(rs2_sel),.wb_sel(wb_sel),.wr_en(wr_en),.rd_en(rd_en),
            .csr_reg_wr(csr_reg_wr),.csr_reg_rd(csr_reg_rd),.is_mret(is_mret),
             .alu_out(alu_out),.fetch_instruction(fetch_instruction),.uart_out(uart_out),.uart_stop(uart_stop)
             );
	
	
controller CT(.clk(clk),.reset(reset), .instruction(fetch_instruction), .alu_op(alu_op),.reg_wr(reg_wr),.reg_wr_e(reg_wr_e),.reg_wr_m(reg_wr_m),.rs1_sel(rs1_sel),.rs2_sel(rs2_sel),.wb_sel(wb_sel),.wr_en(wr_en),.rd_en(rd_en),
              .csr_reg_wr(csr_reg_wr),.csr_reg_rd(csr_reg_rd),.is_mret(is_mret) );

/////////////////////////////////////////////////EXTERNAL INTERRUPT (UART)///////////////////////////////////////////////////////////////
always_comb begin 
  if (uart_stop == 1'b1) begin
    external_interrupt = 32'h0000_0800;
  
  end
  else begin

    external_interrupt = 32'h0000_0000;


  end
end

///////////////////////////////////////////////////////////////Timer Interuppt/////////////////////////////////////////////////////////	
always_ff @(posedge clk or negedge reset)  begin
		if (!reset) begin
			timer <= 8'b0000_0000;
		end
		else begin
		if (timer == 8'b1111_1111) begin
			timer_interrupt_occured <= 32'h0000_0000;
		end
		else begin
			timer <= timer + 1;
      timer_interrupt_occured <= 32'h0000_0000;

		end
    end 
	end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
