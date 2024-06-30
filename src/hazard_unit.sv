`include "sc.svh"


module hazard_unit (
input logic      branch_taken,
input logic      [width-1:0]instruction_he,       //instruction in execute stage   
input logic      [width_alu:0]rs1_e,rs2_e,      //rs1 and rs2 are source registers that are currently inexecute stage
input logic      [width_alu:0]rd_m,rd_w,        //rd_m and rd_w are the destination register of instructions that are currently in memory and write back stage
input logic      reg_wr_hm,reg_wr_hw,             // register write signals of the corresponding instructions to know whether they are to be written or not
input logic      [width_alu:0]rs1_d,rs2_d,     //rs1 and rs2 are source registers that are currently decode stage
input logic      [width_alu:0]rd_e,             //rd_e  is the destination register of instruction that is currently in execute stage(LOAD)

output logic     [1:0]forward_a,forward_b, 
output logic     stall_f,stall_d,flush_e,flush_d
);
logic lwstall;
assign lwstall = (instruction_he[6:0]== LOAD)&&((rs1_d ==  rd_e)| (rs2_d ==  rd_e));
////////////////////////////////RS1//////////////////////////////////////////////////////    
always_comb begin 
if (((rs1_e == rd_m) & reg_wr_hm) & (rs1_e != 0))begin   //forward from memory stage
     forward_a = 2'b10;
end
else if (((rs1_e == rd_w) & reg_wr_hw) & (rs1_e != 0)) begin   //forward from write back stage 
   forward_a = 2'b01; 
end
else begin
     forward_a = 2'b00;
end
end
///////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////RS2//////////////////////////////////////////////////////    
always_comb begin
if (((rs2_e == rd_m) & reg_wr_hm) & (rs2_e != 0))begin   //forward from memory stage
     forward_b = 2'b10;
end
else if (((rs2_e == rd_w) & reg_wr_hw) & (rs2_e != 0)) begin   //forward from write back stage 
    forward_b = 2'b01; 
end
else begin
     forward_b = 2'b00;
end
end
///////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////LOAD//////////////////////////////////////////////////////////////
always_comb begin 
    if (lwstall)begin
        stall_f = 1'b1;
        stall_d = 1'b1;
        flush_e = 1'b1;
    end   
    else begin
     if (branch_taken)begin    
        flush_e = 1'b1;
    end
    else begin
        stall_f = 1'b0;
        stall_d = 1'b0;
        flush_e = 1'b0;
    end
end
end
////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////BRANCH///////////////////////////////////////////////////////////////
always_comb begin 
    if (branch_taken) begin
        flush_d = 1'b1;
      
    end
    else begin
        flush_d = 1'b0;

        
    end
    
end


endmodule