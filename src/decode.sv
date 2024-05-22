`include "sc.svh"

module decode (
input logic         [width-1:0]instruction,wb_out,
input logic         [width_alu:0]address_wr,
input logic         clk,reset,reg_wr,
output logic        [width-1:0]rdata1,rdata2,imm_out
);

reg_file RF(.address_rd1(instruction[19:15]),.address_rd2(instruction[24:20]),.address_wr(address_wr),.data_in(wb_out),.clk(clk), .wr_en(reg_wr),.reset(reset),.rs1(rdata1),.rs2(rdata2));
	
imm_gen I_GEN(.instruction(instruction),.imm_out(imm_out));



endmodule


//Register File

module reg_file(

input reg clk,
input bit reset ,wr_en,
input logic [width-1:0]data_in,
input logic [4:0]address_rd1,address_rd2,address_wr,
output  logic [width-1 :0]rs1,rs2
 );
 integer i;
 
reg [width-1:0]reg_file[width-1 :0];
initial begin 
 reg_file[0] = 'h0;
end
always_comb begin 
 rs1 <= reg_file[address_rd1];
 rs2 <= reg_file[address_rd2];
   
end

always_ff @(posedge clk or negedge reset )begin

    if (!reset)begin
    for(i = 1; i < width ; i++)begin
        reg_file[i] <= 'h0;
   end
   end
   
   
   else begin
   
    if (wr_en && (address_wr != 0))begin
        
            reg_file[address_wr] <=  data_in;
            
     end 
   
   
   end           
end
endmodule



//Immediate Generation

module imm_gen(
input logic [width-1:0]instruction,
output logic [width-1:0]imm_out
    );
 logic [6:0]opcode;
 logic [2:0]func3;
 
 assign opcode = instruction[6:0];
 assign func3 = instruction[14:12];
 
 always_comb begin
    case(opcode)
        R_TYPE : begin imm_out = 'h0; end
    
        I_TYPE : begin
            case(func3)
                3'b001: imm_out = {23'b0,instruction[24:20]};
				3'b101: imm_out = {23'b0,instruction[24:20]};
				default: imm_out = {{20{instruction[31]}},instruction[31:20]};
				endcase
				end  
	
		LOAD  :   begin imm_out = {{20{instruction[31]}},instruction[31:20]}; end	
		
		S_TYPE: begin imm_out = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; end	
		
		B_TYPE: begin imm_out = {{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0}; end
        
        LUI   :    begin imm_out = {instruction[31:12],12'b0}; end
		
		AUIPC :  begin imm_out = {instruction[31:12],12'b0}; end
		
		JAL:    begin imm_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; end
		
		JALR:   begin imm_out = {{20{instruction[31]}},instruction[31:20]}; end	

        CSR:    begin imm_out = {{20{instruction[31]}},instruction[31:20]}; end
                        
        default : imm_out = 'h0;
   
   
   endcase
   end   
        
endmodule
