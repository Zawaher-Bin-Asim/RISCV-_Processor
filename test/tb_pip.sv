`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2024 02:32:10 AM
// Design Name: 
// Module Name: sc_tb
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


module pip_tb();
    reg  clk, reset;
    logic enable_f,enable_pc;
    logic [31:0] alu_out;
	logic [31:0]fetch_instruction;
	logic [31:0]clk_rate;
	logic uart_out;
	logic transmission_interrupt,receiving_interrupt;
	
	pipline PIP(.clk(clk),.clk_rate(clk_rate),.reset(reset),.enable_f(enable_f),.enable_pc(enable_pc),.alu_out(alu_out),
	            .fetch_instruction(fetch_instruction),.uart_out(uart_out),.receiving_interrupt(receiving_interrupt),.transmission_interrupt(transmission_interrupt));
	initial begin
		clk = 1;
		forever #5 clk = ~clk;
	end
	
	initial begin
		reset = 0;clk_rate = 32'd16000000;
		@(posedge clk);
		reset = 1;enable_f = 1;enable_pc = 1;
	    repeat(12) @(posedge clk);
		
		$stop;
	end
endmodule
