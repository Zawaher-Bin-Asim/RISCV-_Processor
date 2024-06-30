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
input  logic clk,reset,enable_f,enable_pc,
input  logic [width-1:0]clk_rate,
output logic [width-1:0]alu_out,fetch_instruction,
output logic uart_out,
output logic transmission_interrupt,receiving_interrupt
  );
  logic [width_alu-1:0]alu_op;
  logic reg_wr,reg_wr_e,reg_wr_m,rs1_sel,rs2_sel,rd_en,wr_en,csr_reg_wr,csr_reg_rd,is_mret;
  logic [1:0]wb_sel;
  logic [7:0]timer;
  logic [width-1:0]timer_interrupt_occured,uart_interrupt_dummy,uart_interrupt ;
  logic [width-1:0]interuppt;
  logic interrupt_start ;

  assign interuppt = timer_interrupt_occured | uart_interrupt;

datapath DP(.alu_op(alu_op),.clk(clk),.clk_rate(clk_rate), .reset(reset),.enable_f(enable_f),.enable_pc(enable_pc),.interuppt(interuppt),
            .reg_wr(reg_wr),.reg_wr_e(reg_wr_e),.reg_wr_m(reg_wr_m),.rs1_sel(rs1_sel),.rs2_sel(rs2_sel),.wb_sel(wb_sel),.wr_en(wr_en),.rd_en(rd_en),
            .csr_reg_wr(csr_reg_wr),.csr_reg_rd(csr_reg_rd),.is_mret(is_mret),
             .alu_out(alu_out),.fetch_instruction(fetch_instruction),.uart_out(uart_out),.transmission_interrupt(transmission_interrupt),.receiving_interrupt(receiving_interrupt)
             );
	
	
controller CT(.clk(clk),.reset(reset), .instruction(fetch_instruction), .alu_op(alu_op),.reg_wr(reg_wr),.reg_wr_e(reg_wr_e),.reg_wr_m(reg_wr_m),.rs1_sel(rs1_sel),.rs2_sel(rs2_sel),.wb_sel(wb_sel),.wr_en(wr_en),.rd_en(rd_en),
              .csr_reg_wr(csr_reg_wr),.csr_reg_rd(csr_reg_rd),.is_mret(is_mret) );

/////////////////////////////////////////////////EXTERNAL INTERRUPT (UART)///////////////////////////////////////////////////////////////
always_comb begin 
  if (transmission_interrupt || receiving_interrupt) begin
    uart_interrupt_dummy = 32'h0001_0800;
  
  end
  else begin

    uart_interrupt_dummy = 32'h0000_0000;


  end
end
//because the uart interrupt depends on the the transmission and received signal that are running on the baud_rate clk 
//so the  interrrupt  signal remains high for very long time so in order to turn on the interrupt signal for only one cycle and remain off afterwards 
// so that the csr registers's value don't change that depends on the interrupt signal because if the interrupt signal remains high for long time  the value of registers change  in each ccycle especially mepc register trhat we don't want  
always_ff @(posedge clk or negedge reset )begin
  if (!reset)begin
    uart_interrupt <= 32'h0000_0000;
    interrupt_start <= 1'b0;    
  end
  else if (!interrupt_start && uart_interrupt_dummy == 32'h0001_0800)begin
    uart_interrupt <= 32'h0001_0800;
    interrupt_start <= 1'b1;  // this signal makes sure that interrupt signal turns on for only one cycle
  end
  else begin
    uart_interrupt <= 32'h0000_0000;
  end
end 




///////////////////////////////////////////////////////////////Timer Interuppt/////////////////////////////////////////////////////////	
always_ff @(posedge clk or negedge reset)  begin
		if (!reset) begin
			timer <= 8'b0000_0000;
		end
		else begin
		if (timer == 8'b0011_1111) begin
			timer_interrupt_occured <= 32'h0000_0080;
      timer <= 8'b0000_0000;
		end
		else begin
			timer <= timer + 1;
      timer_interrupt_occured <= 32'h0000_0000;

		end
    end 
	end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
