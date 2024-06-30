

`include "sc.svh"

module memory(
input logic [width-1:0]addr,data_in,
input logic clk ,rd_en,wr_en,
input logic [2:0]func3,
output logic [width-1:0]mem_out
);

load_op_e load;
logic [width-1:0]memory[depth-1:0];
logic [15:0] hw_data;
logic [7:0] b_data;

initial begin
         $readmemh("/home/zawaher-bin-asim/RISCV_UART/riscv_uart.srcs/sources_1/new/memory.mem",memory);
    end
	
	always_comb begin
		if (rd_en == 1'b1) begin
			case (func3)
				LB: begin
					b_data = memory[addr >> 2][7:0]; // Extract byte (lower 8 bits)
					mem_out = {{24{b_data[7]}},b_data};
				end
				LBU: begin
					b_data = memory[addr >> 2][7:0]; // Extract byte (lower 8 bits)
					mem_out = {24'b0,b_data};
				end
				LH: begin
					hw_data = memory[addr >> 2][15:0]; // Extract half-word (lower 16 bits)
					mem_out = {{16{hw_data[15]}},hw_data};
				end
				LHU: begin
					hw_data = memory[addr >> 2][15:0]; // Extract half-word (lower 16 bits)
					mem_out = {16'b0,hw_data};
				end
				LW: begin
					mem_out = memory[addr >> 2]; // Address shifted by 2 bits to convert byte address to word address
				end
			default: mem_out = 32'b0;
				
			endcase
		end
	end


    always_ff @(negedge clk) begin
		if (wr_en == 1'b1) begin
			case (func3)
				SW: begin
					memory[addr >> 2] <=   data_in;


				end
				SH: begin
					memory[addr >> 2] <=   data_in[15:0];
				end
				SB: begin
					memory[addr >> 2] <=   data_in[7:0];
				end	
			default : 		memory[addr >> 2] <=   'h0;
			endcase		
			$writememh("/home/zawaher-bin-asim/RISCV_UART/riscv_uart.srcs/sources_1/new/memory.mem",memory);
		end
	
	end



endmodule
