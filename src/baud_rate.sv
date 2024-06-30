`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2024 06:46:36 PM
// Design Name: 
// Module Name: baud_rate
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


module baud_rate(
input logic clk,reset,
input logic [31:0]clk_rate,    
input logic [31:0]tx_baud_divisor,
//input logic [31:0]rx_baud_divisor,    
output logic tx_baud_clk,
output logic rx_baud_clk
    );

 
// Counter register
 logic [31:0]tx_counter;
 logic  [31:0]rx_counter;
 logic  [31:0]rx_baud_divisor;      
 logic tx_eq , rx_eq ;
 logic tx_toggle , rx_toggle;

assign rx_baud_divisor = tx_baud_divisor/8;




////////////////////////////TRANSMITTER////////////////////////////////////////////////////
always_ff @( posedge clk or negedge reset) begin 
    if (!reset  || (tx_baud_divisor == 1'b0))begin
        tx_counter <= 'h0;
    end
    else 
        
        if (tx_counter == tx_baud_divisor-1)begin
            tx_counter <= 0;
        end
        else begin
            tx_counter <= tx_counter + 1;
        end
    
end
assign  tx_eq  = (tx_counter == tx_baud_divisor-1); //checking the condition and storing its value in the eq variable

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset)begin
        tx_baud_clk <= 1'b0;
        tx_toggle  <= 1'b1;
    end
    else begin 
        if(tx_eq)begin    //if eq the first toggle then assign toggle to baud_clk
            tx_toggle <= ~tx_toggle;
            tx_baud_clk  <= tx_toggle;
        end

end

end


////////////////////////////RECEIVER////////////////////////////////////////////////////
always_ff @( posedge clk or negedge reset) begin 
    if (!reset || (rx_baud_divisor == 1'b0))begin
        rx_counter <= 'h0;
    end
    else 
        
        if (rx_counter == rx_baud_divisor-1)begin
            rx_counter <= 0;
        end
        else begin
            rx_counter <= rx_counter + 1;
        end
    
end
assign  rx_eq  = (rx_counter == rx_baud_divisor-1); //checking the condition and storing its value in the eq variable

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset)begin
        rx_baud_clk <= 1'b0;
        rx_toggle  <= 1'b1;
    end
    else begin 
        if(rx_eq)begin    //if eq the first toggle then assign toggle to baud_clk
            rx_toggle <= ~rx_toggle;
            rx_baud_clk  <= rx_toggle;
        end

end

end


   
endmodule

