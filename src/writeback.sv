`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 02:01:51 AM
// Design Name: 
// Module Name: wb_mux
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


module writeback(
input logic [width-1:0]a,b,c,d,
input logic [1:0]sel,
output logic [width-1:0]out
);

always_comb
    case(sel)
        2'b00:out = a;
        2'b01:out = b;
        2'b10:out = c;
        2'b11:out = d;
    default : out = 'h0;
    endcase
endmodule
