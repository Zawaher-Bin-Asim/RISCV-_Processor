`include "sc.svh"
module fetch (

    input logic                 clk,reset,enable_pc,stall_f,
    input logic                 [width-1:0]alu_out,pc_plus,csr_excep,
    input logic                 branch_taken,excep_taken,
    output logic                [width-1:0]instruction,pc_out

    );
logic [width-1:0]pc_in,csr_mux_out;


pc_mux21 PC_MUX(.a(pc_plus),.b(alu_out),.sel(branch_taken),.out(pc_in));

csr_mux21 CSR_MUX(.a(pc_in),.b(csr_excep),.sel(excep_taken),.out(csr_mux_out));
        
pc PC(.clk(clk), .reset(reset),.enable_pc(enable_pc),.stall_f(stall_f),.pc_in(csr_mux_out),.pc_out(pc_out));
	
instr_mem IM(.addr(pc_out), .instruction(instruction));    

endmodule


//PC_MUX
 module pc_mux21(
input logic [width -1 :0]a,b,
input logic sel,
output logic [width-1:0]out
);
always @(a,b,sel)begin
  case(sel)
    1'b0 :  out = a ;
    1'b1 :  out = b ;
    default : out = 'h0;
    endcase      

end
endmodule

//CSR MUX
module csr_mux21(
input logic [width -1 :0]a,b,
input logic sel,
output logic [width-1:0]out
);
always @(a,b,sel)begin
  case(sel)
    1'b0 :  out = a ;
    1'b1 :  out = b ;
    default : out = 'h0;
    endcase      

end
endmodule 


//Pc Register
module pc(
    input logic clk,reset,enable_pc,stall_f,
    input logic  [width -1:0]pc_in,
    output logic [width -1:0]pc_out
  
    );
  
 always_ff  @(posedge clk or negedge reset )begin
    if(!reset)begin 
 
        pc_out  <= 'h0;  
   end   
   else begin
        if (!stall_f && enable_pc) begin   
            pc_out <= pc_in;
        end
    end    
 end          
endmodule    

//Instruction_Memory

module instr_mem(
input logic [width-1:0]addr,
output logic [width-1 : 0]instruction
);

logic [width-1:0]inst_mem[depth-1:0];

initial begin
    $readmemh("/home/zawaher-bin-asim/Computer Architecture/CSR/csr.srcs/sources_1/new/main.txt",inst_mem);
   
 end
 
 assign instruction = inst_mem[addr[address-1:2]];
 
    

endmodule


