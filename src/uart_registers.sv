`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2024 10:00:13 PM
// Design Name: 
// Module Name: uart_registers
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
module uart_registers(
input logic         clk,reset,uart_sel,we,re,data_transmitted,
input logic         [width-1:0]address,data_in,
output logic        [width-1:0]read_out,uart_baud_rate,
output logic        [7:0]uart_data,
output logic        load_signal,tx_signal
    );

uart_registers_e  uart_registers;



logic [width-1:0]uart_data_reg,uart_baud_reg,uart_ctrl_reg;



always_comb begin 
    if(data_transmitted)begin               //checks if the transmission is done then set full bit of data register to '0'.
        uart_data_reg[31] = 0;
    end

    
end



always_ff @( posedge clk or negedge reset ) begin 
    if (!reset) begin
        uart_baud_reg <= 'h0;
        uart_ctrl_reg <= 'h0;
        uart_data_reg <= 'h0;
    end
    else begin
        if(uart_sel && we)begin
            case (address)
              UART_DATA_REG  : begin
               if (uart_data_reg[31] ==  0) begin
                
                    uart_data_reg[7:0] <= data_in[7:0];
                    uart_data_reg[30:8] <= 0;
                    uart_data_reg[31] <= 1;       
               end
              end 
                UART_BAUD_REG : uart_baud_reg <= data_in;
    
                UART_CTRL_REG : uart_ctrl_reg <= data_in;
                
                default:begin
                    uart_baud_reg <= 115200;
                    uart_data_reg <= 8'b11111111;
                    uart_ctrl_reg <= 0;
                end 


            endcase
        end

    end
    
end


always_comb begin
    if (re && uart_sel)begin
        case (address)
           UART_DATA_REG :begin
                if (uart_data_reg[31] == 1'b1) begin    //checks whether the transmission of data is going on
                    read_out[30:0] = 'h0;
                    read_out[31] = 1;
                end 
                else begin
                    read_out = uart_data_reg;
                end                           
           end 
           UART_BAUD_REG :  read_out = uart_baud_reg;

           UART_CTRL_REG : read_out = uart_ctrl_reg;
            
            default:      read_out = uart_data_reg;

        endcase
        
    end
    
end

assign uart_data = uart_data_reg[7:0];
assign uart_baud_rate = uart_baud_reg;
assign tx_signal = uart_ctrl_reg[0];
assign load_signal = uart_data_reg[31];
/*
////////////////////////////////////////////////////Load Signal//////////////////////////////////////
always_ff @( posedge clk or negedge reset) begin 
    if (!reset)begin

        load_signal <= 1'b0;
    
    end
    else begin
        if ((uart_data_reg[31]== 1'b1) && (uart_ctrl_reg[0] == 1'b0)) begin
            load_signal <= 1'b1;

        end
        else begin
            load_signal <= 1'b0;
        end
    end



end
*/

endmodule
