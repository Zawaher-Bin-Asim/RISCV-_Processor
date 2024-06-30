`include "sc.svh"

module execute(
    input logic         [width-1:0]rdata1,rdata2,pc_out,imm_out,instruction,
    input logic         rs1_sel,rs2_sel ,
    input logic         [width_alu-1:0]alu_op,   
    output logic        [width-1:0]alu_out,
    output logic        branch_taken
);

logic [width-1:0]muxrs1_out,muxrs2_out;

reg_mux21 MUX_RS1 (.a(rdata1),.b(pc_out),.sel(rs1_sel),.out(muxrs1_out));
	
reg_mux21 MUX_RS2 (.a(rdata2),.b(imm_out),.sel(rs2_sel),.out(muxrs2_out));
	 
alu alu(.operand_a(muxrs1_out),.operand_b(muxrs2_out),.alu_op(alu_op),.result(alu_out));

branch_comp BR_COM(.rdata1(rdata1),.rdata2(rdata2),.instruction(instruction), .branch_taken(branch_taken));



endmodule



module alu (
input logic [width-1:0]operand_a,operand_b,
input logic [width_alu-1:0]alu_op,
output logic [width-1:0]result 
 );
 
 alu_op_e operation; 

always_comb begin
    case (alu_op)
        ADD: result = operand_a + operand_b;
        SUB: result = operand_a - operand_b;
        SRA: result = operand_a >> operand_b;
        SRL: result = operand_a >>> operand_b;
        SLL: result = operand_a << operand_b;
        AND: result = operand_a & operand_b;
        OR: result = operand_a | operand_b;
        XOR: result = operand_a ^ operand_b;
        SLT: result = (operand_a < operand_b) ? 1 : 0;
        SLTU: result = (operand_a < operand_b) ? 1 : 0; // Assuming unsigned comparison
        UPPER : result = operand_b;
        default: result = 0; // Default operation
    endcase
end

endmodule

    


module reg_mux21 
(
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




module branch_comp(
input logic [width-1:0]rdata1,rdata2,instruction,
output logic branch_taken 
    );
   
 logic [6:0]opcode;
 logic [2:0]func3;  
 logic cmp_not_zero, cmp_overflow;
 logic [31:0] cmp_neg;
 logic [32:0] cmp_output; 
 
 assign opcode = instruction[6:0];
 assign func3 = instruction[14:12];
    
 
 assign cmp_output = {rdata1}-{rdata2};
 assign cmp_not_zero = |cmp_output[31:0];
 assign cmp_neg = cmp_output[31];
 assign cmp_overflow = (cmp_neg & ~rdata1[31] & rdata2[31])|(~cmp_neg & rdata1[31] & ~rdata2[31]);   
    
 always_comb begin
        case(opcode)
            B_TYPE:begin
                case(func3)
                    BEQ : branch_taken = ~(cmp_not_zero);
                    BNE : branch_taken = cmp_not_zero;
                    BLT : branch_taken = (cmp_neg ^ cmp_overflow);
                    BLTU: branch_taken = cmp_output[32];
                    BGE : branch_taken = ~(cmp_neg ^ cmp_overflow);
                    BGEU: branch_taken = ~cmp_output[32];
                default : branch_taken = 1'h0;
                endcase 
            end
            
            JAL:begin branch_taken = 1'h1; end
           
            JALR:begin branch_taken = 1'h1; end
            
        default: branch_taken = 1'h0;            
        endcase
        end            
endmodule