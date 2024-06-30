`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 01:40:03 AM
// Design Name: 
// Module Name: csr_reg_file
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
`include "csr.svh"

module csr_reg_file(
    input logic         clk,reset,
    input logic         [width-1:0]pc,wdata,
    input logic         [2:0]func3,
    input logic         [addr_width-1:0]address,
    input logic         reg_wr,reg_rd,is_mret,
    input logic         [width-1:0]excep,
    output logic        excep_taken,
    output logic        [width-1:0]excep_pc,rd_data

    );
csr_registers      csr_registers;
csr_op_e            csr_op;

logic   interrupt_occured;
logic   [width-1:0]csr_mip_reg, csr_mie_reg, csr_mcause_reg, csr_mepc_reg, csr_mstatus_reg, csr_mtvec_reg;
logic   csr_mcause_wr_flag,csr_mstatus_wr_flag,csr_mip_wr_flag,csr_mie_wr_flag,csr_mepc_wr_flag,csr_mtvec_wr_flag;
logic   [width-1:0] vector_in, non_vector_in, vector_out;

assign interrupt_occured = (((csr_mip_reg[7] && csr_mie_reg[7]) || (csr_mip_reg[11] && csr_mie_reg[11]) || (csr_mip_reg[11] && csr_mip_reg[16] && csr_mie_reg[11] && csr_mie_reg[16]) ) && csr_mstatus_reg[3]);  //checking the interuppt
assign excep_taken = (is_mret | interrupt_occured);  //setting the exception taken flag
assign vector_in = (csr_mcause_reg<<2)+{csr_mtvec_reg[31:2],2'b00};
assign non_vector_in = {csr_mtvec_reg[31:2],2'b00};

mux MUX_VECTOR (.a(non_vector_in),.b(vector_in),.sel(csr_mtvec_reg[0]),.out(vector_out));

mux MUX_IS_MRET (.a(vector_out),.b(csr_mepc_reg),.sel(is_mret),.out(excep_pc));


//////////////////////////////////////////////////REG_READ/////////////////////////////////////////////
//the bits that are zero are not to be written and guves zero on read 

always_comb begin 
    rd_data = 'h0;
    if (reg_rd) begin

        case (address)

            mstatus : begin
                            rd_data[2:0] = 'h0;
                            rd_data[3] = csr_mstatus_reg[3];
                            rd_data[6:4] = 'h0;
                            rd_data[7] = csr_mstatus_reg[7];
                            rd_data[10:8] = 'h0;
                            rd_data[12:11] = csr_mstatus_reg[12:11];
                            rd_data[31:13] = 'h0;
            end    
            mie     : begin     
                            rd_data[6:0] = 6'h0;
                            rd_data[7] = csr_mie_reg[7];
                            rd_data[10:8] = 3'h0;
                            rd_data[11] = csr_mie_reg[11];
                            rd_data[15:12] = 4'h0;
                            rd_data[31:16] = csr_mie_reg[31:16];
                            
            end

            mtvec   : rd_data = csr_mtvec_reg;
            mepc    : rd_data = csr_mepc_reg;
            mcause  : rd_data = csr_mcause_reg;
            mip     : begin     
                            rd_data[6:0] = 6'h0;
                            rd_data[7] = csr_mip_reg[7];
                            rd_data[10:8] = 3'h0;
                            rd_data[11] = csr_mip_reg[11];
                            rd_data[15:12] = 4'h0;
                            rd_data[31:16] = csr_mip_reg[31:16];
            end
           
            default  : rd_data = 'h0;
        endcase
    end
    
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////REG_WRITE////////////////////////////////////////////////////////////
always_comb begin
    csr_mcause_wr_flag = 1'b0;
    csr_mstatus_wr_flag = 1'b0;
    csr_mie_wr_flag = 1'b0;
    csr_mip_wr_flag = 1'b0;
    csr_mtvec_wr_flag = 1'b0;
    csr_mepc_wr_flag = 1'b0;
    
    if (reg_wr) begin

        case (address)
          mstatus  : csr_mstatus_wr_flag = 1'b1;
          mcause   : csr_mcause_wr_flag = 1'b1;
          mie      : csr_mie_wr_flag = 1'b1;
          mip      : csr_mip_wr_flag = 1'b1;
          mtvec    : csr_mtvec_wr_flag = 1'b1;
          mepc     : csr_mepc_wr_flag = 1'b1;        

        endcase
        
    end

    end
//////////////Updating the Registers//////////////////////////////////////////////////////////////////////////////////////

//the bits written here are write only else other bits are read only .

//MCAUSES
always_ff @( posedge clk or negedge reset) begin 
    if (!reset) begin
        csr_mcause_reg  <= 'h0;
        end
    else begin 
           // Timer Interrupt Pending
			if (excep[7] == 1'b1) begin
				csr_mcause_reg <= {1'b1,27'h0,4'b0111};
			end
		// External Interrupt Pending
			if (excep[11] == 1'b1) begin
				csr_mcause_reg <= {1'b1,27'h0,4'b1011};
			end
        // Uart Interrupt Pending
			if (excep[16] == 1'b1) begin
				csr_mcause_reg <= {1'b1,23'h0,8'b10000};
			end
		end
	end


//MSTATUS
always_ff @(posedge clk or negedge reset ) begin 
    if (!reset) begin
        csr_mstatus_reg  <= 'h0;
        end
    else if (csr_mstatus_wr_flag) begin
        if(func3 == CSRRC || func3 == CSRRCI)begin
            csr_mstatus_reg[3] <=  ~wdata[3];        
            csr_mstatus_reg[7] <=  ~wdata[7];
            csr_mstatus_reg[12:11] <=  ~wdata[12:11];
        end
        else begin
            csr_mstatus_reg[3] <=  wdata[3];        
            csr_mstatus_reg[7] <=  wdata[7];
            csr_mstatus_reg[12:11] <=  wdata[12:11];
        end
    end
end

//MIE
always_ff @(posedge clk or negedge reset ) begin 
    if (!reset) begin
        csr_mie_reg  <= 'h0;
        end
    else if (csr_mie_wr_flag) begin
        if(func3 == CSRRC || func3 == CSRRCI)begin
                csr_mie_reg[7] <= ~wdata[7]; //Timer Interrupt
                csr_mie_reg[11] <= ~wdata[11]; // External Interrupt
                csr_mie_reg[16] <= ~wdata[16]; //Uart Interrupt
        end
        else begin
            csr_mie_reg[7] <= wdata[7];
            csr_mie_reg[11] <= wdata[11];
            csr_mie_reg[16] <= wdata[16];
        end
    end
end

//MTVEC
always_ff @(posedge clk or negedge reset ) begin 
    if (!reset) begin
        csr_mtvec_reg  <= 'h0;
        end
    else if (csr_mtvec_wr_flag) begin
        if(func3 == CSRRC || func3 == CSRRCI)begin
            csr_mtvec_reg  <= ~wdata;
        end
        else begin
            csr_mtvec_reg  <= wdata;
        end   
    end
end



// Update the mip (Machine Interrupt Pending) CSR
always_ff @(posedge clk or negedge reset ) begin 
    if (!reset) begin
        csr_mip_reg  <= 'h0;
        end
    else begin
    
    // Timer Interrupt Pending
			if (excep[7] == 1'b1) begin
				csr_mip_reg[7] <= 1'b1;
			end
			else begin
				csr_mip_reg[7] <= 1'b0;
			end
		// External Interrupt Pending
			if (excep[11] == 1'b1) begin
				csr_mip_reg[11] <= 1'b1;
			end
			else begin
				csr_mip_reg[11] <= 1'b0;
			end
        // Uart Interrupt (we will  high  both(11 & 16) bits of mip register
           // External Interrupt Pending
			if (excep[16] == 1'b1) begin
				csr_mip_reg[11] <= 1'b1;
                csr_mip_reg[16] <= 1'b1;
			end
			else begin
                csr_mip_reg[11] <= 1'b0;
                csr_mip_reg[16] <= 1'b0;
			end 
end

end

//MEPC
always_ff @(posedge clk or negedge reset ) begin 
    if (!reset) begin
        csr_mepc_reg  <= 'h0;
        end
    else begin 
        
        if (interrupt_occured) begin
            csr_mepc_reg <=  pc;
        end 
        end   

end



endmodule


module mux
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

