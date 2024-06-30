`include "sc.svh"

module forwarding_mux (
  input logic  [width-1:0]mem,wb,in,
  input logic [1:0]sel,
  output logic [width-1:0] out
);

always_comb begin 
    case (sel)
		2'b10	: out = mem;
		2'b01	: out = wb;
		2'b00	: out = in;
			default: out = 'h0;
		endcase
		
	end
    
    
endmodule