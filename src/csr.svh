`ifndef csr
`define csr

//parameter width = 32 ;
parameter addr_width = 12;

typedef enum logic [11:0] {
    mstatus = 12'h300,
    mie     = 12'h304,
    mtvec   = 12'h305,
    mepc    = 12'h341,
    mcause  = 12'h342,
    mip     = 12'h344

} csr_registers;

typedef enum logic [2:0] {
    CSRRW  = 3'b001,
    CSRRS  = 3'b010,
    CSRRC  = 3'b011,
    CSRRWI = 3'b101,
    CSRRSI = 3'b110,
    CSRRCI = 3'b111
} csr_op_e;


`endif 