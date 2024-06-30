`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2024 03:42:16 PM
// Design Name: 
// Module Name: controller
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

`include "sc.svh"
module controller(
    input logic clk,reset,
    input logic [width-1:0] instruction,
    output logic [width_alu-1:0] alu_op,
    output logic reg_wr,reg_wr_e,reg_wr_m ,wr_en,rd_en,rs1_sel,rs2_sel,csr_reg_wr,csr_reg_rd,is_mret,
    output logic [1:0]wb_sel
);

    type_opcode_e operationcode;
    alu_op_e  operation;
    logic [6:0] func7;
    logic [2:0] func3;
    logic [6:0]opcode;

    ////Combinational Part//////////////////////////////////////////////////////////////////////
    logic rd_en_d,wr_en_d,reg_wr_d,rs1_sel_d,rs2_sel_d,csr_rd,csr_wr,csr_is_mret ;
    logic [1:0]wb_sel_d;
    logic [width_alu-1:0]alu_op_d;
    ////////////////////////////////////////////////////////////////////////

    //Decode Register//////////////////////////////////////////////////////////
    logic rd_en_d_reg,wr_en_d_reg,reg_wr_d_reg,rs1_sel_d_reg,rs2_sel_d_reg,csr_reg_rd_d,csr_reg_wr_d,is_mret_d; 
    logic [1:0]wb_sel_d_reg;  
    logic [width_alu-1:0]alu_op_d_reg;                  
    /////////////////////////////////////////////////////////////////////

    //Execute Register/////////////////////////////////////////////////////////
    logic rd_en_e,wr_en_e,csr_reg_rd_e,csr_reg_wr_e,is_mret_e;
    logic [1:0]wb_sel_e;
    //////////////////////////////////////////////////////////////////////////

    //Memory Register/////////////////////////////////////////////////////////
    logic [1:0]wb_sel_m;
    //////////////////////////////////////////////////////////////////////////



    always_comb begin
        // Extract opcode and funct fields from instruction
        opcode = instruction[6:0];
        func7 = instruction[31:25];
        func3 = instruction[14:12];

        // Decode ALU operation based on opcode and funct fields
        case (opcode)
            R_TYPE: begin
                        rd_en_d = 1'b0;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b01;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b0;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        case (func7)
                            7'b000_0000: begin
                                case(func3)
                                    3'b000: alu_op_d = ADD;
                                    3'b001: alu_op_d = SLL;
                                    3'b010: alu_op_d = SLT;
                                    3'b011: alu_op_d = SLTU;
                                    3'b100: alu_op_d = XOR;
                                    3'b101: alu_op_d = SRL;
                                    3'b110: alu_op_d = OR;
                                    3'b111: alu_op_d = AND;
                                    default : alu_op_d = ADD;
                                endcase
                            end
                            7'b010_0000: begin
                                case(func3)
                                    3'b000: alu_op_d = SUB;
                                    3'b101: alu_op_d = SRA;
                                    default : alu_op_d = ADD;
                                endcase
                            end
                        endcase
                        
                end
                        
                
            I_TYPE: begin
                        rd_en_d = 1'b0;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b01;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                            case (func3)
                                    3'b000: alu_op_d = ADD;
                                    3'b010: alu_op_d = SLT;
                                    3'b011: alu_op_d = SLTU;
                                    3'b100: alu_op_d = XOR;
                                    3'b110: alu_op_d = OR;
                                    3'b111: alu_op_d = AND;
                                    3'b001: begin
                                            if (func7 == 7'b0000000) begin alu_op_d = SLL; end 
                                            end
                                    3'b101: begin if (func7 == 7'b0000000) begin alu_op_d = SRL; end
                                            else if (func7 == 7'b0100000) begin alu_op_d = SRA; end
                                            end
                                    default : alu_op_d = ADD;        
                            endcase
                    end
                
            LOAD: begin
                        rd_en_d = 1'b1;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b00;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;                           
                    end
                        
                        
                   
            S_TYPE: begin
			            rd_en_d = 1'b0;
                        wr_en_d = 1'b1;
                        wb_sel_d = 2'b01;
                        reg_wr_d = 1'b0;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;
                    end
                        
                        
               
            B_TYPE: begin
			            rd_en_d  = 1'b0;
                        wr_en_d  = 1'b0;
                        wb_sel_d = 2'b01;
                        reg_wr_d = 1'b0;
                        rs1_sel_d = 1'b1;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;	
                        end
                        
               
            
            LUI: begin
			            rd_en_d  = 1'b0;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b01;
                        reg_wr_d =  1'b1;
                        rs1_sel_d = 1'b1;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = UPPER;			
                        end
                        
			
		    AUIPC: begin
			           rd_en_d  = 1'b0;
                        wr_en_d  = 1'b0;
                        wb_sel_d = 2'b01;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b1;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;        
                        end
                                    
                
            
            JAL : begin
			            rd_en_d  = 1'b0;
                        wr_en_d  = 1'b0;
                        wb_sel_d = 2'b10;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b1;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;              
                        end
                                    
                
            JALR : begin
			            rd_en_d  = 1'b0;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b10;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b1;
                        csr_rd = 1'b0;
                        csr_wr = 1'b0;
                        csr_is_mret = 1'b0;
                        alu_op_d = ADD;          
                        end

            CSR   : begin
                        rd_en_d = 1'b0;
                        wr_en_d = 1'b0;
                        wb_sel_d = 2'b11;
                        reg_wr_d = 1'b1;
                        rs1_sel_d = 1'b0;
                        rs2_sel_d = 1'b1;
                        alu_op_d = ADD;
                       
                        case (func3)
                        3'b001    : begin            ////CSRW 
                            csr_rd = 1'b1;
                            csr_wr = 1'b1;
                            csr_is_mret = 1'b0;
                        end

                        3'b000    : begin            ////CSRW 
                            csr_rd = 1'b0;
                            csr_wr = 1'b0;
                            csr_is_mret = 1'b1;
                        end
                        default : begin
                            csr_rd = 1'b0;
                            csr_wr = 1'b0;
                            csr_is_mret = 1'b0;
                            end
                        
                        endcase         
                                    
            end

            default :begin
            rd_en_d  = 1'b0;
			wr_en_d  = 1'b0;
			wb_sel_d = 2'b01;
			reg_wr_d = 1'b1;
			rs1_sel_d  = 1'b0;
			rs2_sel_d  = 1'b0;
            csr_rd = 1'b0;
            csr_wr = 1'b0;
            csr_is_mret = 1'b0;
			alu_op_d = ADD; 
			end   
        endcase
    end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//PIPELINED Registers    (They are given names in a sense  that those registers comes after that stage )
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    always @(posedge clk or negedge reset)begin       //DECODE REGISTER

            if (!reset)begin
                rd_en_d_reg  <= 1'b0;
                wr_en_d_reg  <= 1'b0;
                wb_sel_d_reg <= 2'b01;
                reg_wr_d_reg <= 1'b1;
                rs1_sel_d_reg <= 1'b0;
                rs2_sel_d_reg <= 1'b0;
                csr_reg_rd_d <= 1'b0;
                csr_reg_wr_d <= 1'b0;
                is_mret_d    <= 1'b0;
                alu_op_d_reg <= ADD; 
             end   
            else begin
                rd_en_d_reg <= rd_en_d;
                wr_en_d_reg <= wr_en_d ;
                wb_sel_d_reg <= wb_sel_d;
                reg_wr_d_reg <= reg_wr_d;
                rs1_sel_d_reg <= rs1_sel_d;
                rs2_sel_d_reg <= rs2_sel_d;
                csr_reg_rd_d <= csr_rd;
                csr_reg_wr_d <= csr_wr;
                is_mret_d    <= csr_is_mret;
                alu_op_d_reg <= alu_op_d;
            end
                
                
        end
        
        always @(posedge clk or negedge reset) begin       //EXECUTE REGISTER
            if(!reset)begin 
                rd_en_e  <= 1'b0;
                wr_en_e  <= 1'b0;
                wb_sel_e <= 2'b01;
                reg_wr_e <= 1'b1;
                csr_reg_rd_e <= 1'b0;
                csr_reg_wr_e <= 1'b0;
                is_mret_e    <= 1'b0;

            end 
            else begin
                rd_en_e  <= rd_en_d_reg;
                wr_en_e  <= wr_en_d_reg;
                wb_sel_e <= wb_sel_d_reg;
                reg_wr_e <= reg_wr_d_reg;
                csr_reg_rd_e <= csr_reg_rd_d;
                csr_reg_wr_e <= csr_reg_wr_d;
                is_mret_e    <= is_mret_d;

            end

        end


        always @(posedge clk or negedge reset) begin      //MEMORY REGISTER
            if (!reset) begin
                wb_sel_m <= 2'b01;
                reg_wr_m <= 1'b1;

            end
            else begin
                wb_sel_m <= wb_sel_e;
                reg_wr_m <= reg_wr_e;

            end                    
        end  

////////////ASSIGNING TO OUTPUT///////////////////////////////////////////////////////////////

    assign    rd_en = rd_en_e;
    assign    wr_en = wr_en_e;
    assign    wb_sel = wb_sel_m;
    assign    reg_wr = reg_wr_m;
    assign    rs1_sel = rs1_sel_d_reg;
    assign    rs2_sel = rs2_sel_d_reg;
    assign    alu_op = alu_op_d_reg;
    assign    csr_reg_wr = csr_reg_wr_e;
    assign    csr_reg_rd = csr_reg_wr_e;
    assign    is_mret    = is_mret_e;
/////////////////////////////////////////////////////////////////////////////////////////////




endmodule

