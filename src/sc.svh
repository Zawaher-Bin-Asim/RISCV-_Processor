`ifndef sc
`define sc

parameter address = 12;
parameter width = 32;
parameter  width_alu = 4; 
parameter  depth  = 512;

typedef enum logic [6:0]{
      R_TYPE = 7'b0110011, //51
      I_TYPE = 7'b0010011,  //19
      S_TYPE = 7'b0100011, //
      B_TYPE = 7'b1100011,
       LOAD  = 7'b0000011,
	    LUI  = 7'b0110111,
	   AUIPC = 7'b0010111,  	    
         JAL = 7'b1101111,
	    JALR = 7'b1100111,
        CSR  = 7'b1110011    
  
      
  }type_opcode_e ;

   
typedef enum logic [3:0] {
    ADD  = 4'b0000, // Addition
    SUB  = 4'b0001, // Subtraction
    SRA  = 4'b0010, // Arithmetic Right Shift
    SRL  = 4'b0011, // Logical Right Shift
    SLL  = 4'b0100, // Logical Left Shift
    AND  = 4'b0101, // Bitwise AND
    OR   = 4'b0110, // Bitwise OR
    XOR  = 4'b0111, // Bitwise XOR
    SLT  = 4'b1000, // Set Less Than
    SLTU = 4'b1001, // Set Less Than Unsigned
    UPPER = 4'b1010

} alu_op_e;



typedef enum logic [2:0] {
    LB  = 3'b000,
    LH  = 3'b001,
	LW  = 3'b010,
	LBU = 3'b100,
	LHU = 3'b101
} load_op_e;


typedef enum logic [2:0] {
    SB  = 3'b000,
    SH  = 3'b001,
    SW  = 3'b010
} store_op_e;


typedef enum logic [2:0] {
    BEQ  = 3'b000,
	BNE  = 3'b001,
	BLT  = 3'b100,
	BGE  = 3'b101,
	BLTU = 3'b110,
	BGEU = 3'b111
} branch_op_e;



typedef enum logic [31:0] {
    UART_TX_DATA_REG = 32'h8000_0000,
    UART_BAUD_REG = 32'h8000_0004,
    UART_CTRL_REG = 32'h8000_0008

} uart_registers_e;




`endif