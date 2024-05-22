`ifndef pip
`define pip
`include "sc.svh"


typedef struct {
     logic [width-1:0]pc_out_f;
     logic [width-1:0]instruction_f;
    
    
} pip_dp_fetch;


typedef struct {
     logic [width-1:0]instruction_d;
     logic [width-1:0]rdata1_d;
     logic [width-1:0]rdata2_d;
     logic [width-1:0]imm_out_d;
     logic [width-1:0]pc_out_d;

    
    
} pip_dp_decode;

typedef struct {
     logic [width-1:0]instruction_e;
     logic [width-1:0]alu_out_e;
     logic [width-1:0]rdata2_e;
     logic [width-1:0]pc_out_e;
     logic [width-1:0]imm_out_e;
     logic [width-1:0]forward_a_mux_e;
     
	 
    
} pip_dp_execute;

typedef struct {
    logic [width-1:0]mem_out_m;
    logic [width-1:0]pc_plus_m;
	logic [width-1:0]instruction_m;
	logic [width-1:0]alu_out_m;
     logic [width-1:0]csr_rd_data_m;
    
    
} pip_dp_memory;

typedef struct  {
     logic         we,re,uart_sel,dmem_sel;
     logic        [width-1:0]input_data,reg_address;

} LSU_OUTPUTS;


typedef struct packed {
   logic        [width-1:0]read_out,uart_baud_rate;
   logic        [7:0]uart_data,rx_data_out;
   logic        load_signal,tx_signal;
   
} UART_REGFILE;

/*typedef struct {

 logic      [width-1:0]instruction_e;       //instruction in execute stage   
 logic      [width_alu:0]rs1_e,rs2_e;      //rs1 and rs2 are source registers that are currently inexecute stage
 logic      [width_alu:0]rd_m,rd_w;        //rd_m and rd_w are the destination register of instructions that are currently in memory and write back stage
 logic      reg_wr_m,reg_wr_w;             // register write signals of the corresponding instructions to know whether they are to be written or not
 logic      [width_alu:0]rs1_d,rs2_d;     //rs1 and rs2 are source registers that are currently decode stage
 logic      [width_alu:0]rd_e;             //rd_e  is the destination register of instruction that is currently in execute stage(LOAD)

 logic     [width_alu-3:0]forward_a,forward_b ;
 logic     stall_f,stall_d,flush_e;
    
} pip_hazard;

*/

`endif 
