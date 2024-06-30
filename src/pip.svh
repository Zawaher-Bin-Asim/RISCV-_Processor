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
   logic        load_signal,tx_signal,uart_stop;
   logic        [1:0]stop_bit;

} UART_REGFILE;

`endif 
