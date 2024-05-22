`include "sc.svh"
module lsu_unit (
input logic         [width-1:0]instruction,data,dbus_address,
output logic        we,re,uart_sel,dmem_sel,
output logic        [width-1:0]input_data,reg_address
);
    
logic   [6:0]opcode;

assign opcode  = instruction[6:0];

assign dmem_sel = (LOAD  | S_TYPE) && (dbus_address[31:28] == 4'h0);
assign uart_sel = (LOAD  | S_TYPE) && (dbus_address[31:28] == 4'h8);

always_comb begin
    case (opcode)
       LOAD : begin
        we = 0;
        re = 1;
        reg_address = dbus_address;
        input_data = data;
       end 
       S_TYPE : begin
        we = 1;
        re = 0;
        reg_address = dbus_address;
        input_data = data;
       end 
        default:    begin
            we = 0;
            re = 1;
            reg_address = dbus_address;
            input_data = data;
        end
    endcase    
end



endmodule