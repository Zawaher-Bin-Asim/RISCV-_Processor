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
input logic         clk,reset,uart_sel,we,rx_wr,re,data_transmitted,
input logic         [width-1:0]address,data_in,
input logic         [7:0]rx_in,
output logic        [width-1:0]read_out,uart_baud_rate,
output logic        [7:0]uart_data,
output logic        load_signal,tx_signal,
output logic        [1:0]stop_bit,
output logic        transmission_interrupt,receiving_interrupt
    );

uart_registers_e  uart_registers;



logic [width-1:0]uart_tx_data_reg,uart_rx_data_reg,uart_baud_reg,uart_ctrl_reg,uart_interrupt_en_reg,uart_interrupt_pen_reg;



always_comb begin 
    if(data_transmitted)begin               //checks if the transmission is done then set full bit of data register to '0'.
        uart_tx_data_reg[31] = 0;
    end

    
end

////////////////////////////////////////////////////////////REG WRITE/////////////////////////////////////////////////////////////////

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset) begin
        uart_baud_reg         <= 'h0;
        uart_ctrl_reg         <= 'h0;
        uart_tx_data_reg      <= 'h0;
        uart_interrupt_en_reg <= 'h0;
    end
    else begin
        if(uart_sel && we)begin
            case (address)
                UART_TX_DATA_REG  : begin
                if (uart_tx_data_reg[31] ==  0) begin
                    
                        uart_tx_data_reg[7:0]  <= data_in[7:0];
                        uart_tx_data_reg[30:8] <= 0;
                        uart_tx_data_reg[31]   <= 1;       
                end
                end
                UART_INTERRUPT_EN_REG  : begin
                    
                        uart_interrupt_en_reg[1:0]  <= data_in[1:0];
                        uart_interrupt_en_reg[31:2] <= 0;       
                end
 
                UART_BAUD_REG : uart_baud_reg <= data_in;
    
                UART_CTRL_REG : uart_ctrl_reg <= data_in;
                
                default:begin
                    uart_baud_reg         <= 115200;
                    uart_tx_data_reg      <= 8'b11111111;
                    uart_ctrl_reg         <= 'h0;
                    uart_interrupt_en_reg <= 'h0;
                end 


            endcase
        end

    end
    
end

/////////////////////////////////////////////////////INTERRUPT PENNDING REG WRITE///////////////////////////////////////////

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        uart_interrupt_pen_reg <= 'h0;
    end else begin
        if (rx_wr) begin
            uart_interrupt_pen_reg[0] <= 1'b0;
            uart_interrupt_pen_reg[1] <= 1'b1;  // bit 1 for the receiving completion
        end else if (data_transmitted) begin
            uart_interrupt_pen_reg[0] <= 1'b1;  // bit 0 for the transmission completion
            uart_interrupt_pen_reg[1] <= 1'b0;
        end else begin
            uart_interrupt_pen_reg[0] <= 1'b0;
            uart_interrupt_pen_reg[1] <= 1'b0;
        end
    end
end


///////////////////////////////////////////////////////////RX DATA REGISTER///////////////////////////////////////////////

always_ff @(posedge clk or negedge reset)begin
    if (!reset )begin
        uart_rx_data_reg[30:0] <= 'h0;
        uart_rx_data_reg[31] <= 1'b1; 
    end
    else if (rx_wr) begin
        uart_rx_data_reg[7:0]  <= rx_in[7:0];
        uart_rx_data_reg[30:8] <= 0;
        uart_rx_data_reg[31]   <= 0;        
    end
    else begin
        uart_rx_data_reg[7:0]  <= 'h0;
        uart_rx_data_reg[30:8] <= 'h0;
        uart_rx_data_reg[31]   <= 1'b1;
        
    end
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


always_comb begin
    if (re && uart_sel)begin
        case (address)
           UART_TX_DATA_REG :begin
                if (uart_tx_data_reg[31] == 1'b1) begin    //checks whether the transmission of data is going on
                    read_out[30:0] = 'h0;
                    read_out[31]   = 1;
                end 
                else begin
                    read_out = uart_tx_data_reg;
                end                           
           end
           UART_RX_DATA_REG :begin
                if (uart_rx_data_reg[31] == 1'b1) begin    //checks whether the receiving of data is going on
                    read_out[30:0] = 'h0;
                    read_out[31]   = 1;
                end 
                else begin
                    read_out = uart_tx_data_reg;
                end                           
           end
           UART_INTERRUPT_EN_REG  : begin
                    
                    read_out[1:0]  <= uart_interrupt_en_reg[1:0];
                    read_out[31:2] <= 0;       
            end
           UART_INTERRUPT_PEN_REG  : begin            
                    read_out[1:0]  <= uart_interrupt_pen_reg[1:0];
                    read_out[31:2] <= 0; 
            end 
           UART_BAUD_REG :  read_out = uart_baud_reg;

           UART_CTRL_REG : read_out = uart_ctrl_reg;
            
            default:      read_out = uart_tx_data_reg;

        endcase
        
    end
    
end


assign uart_data = uart_tx_data_reg[7:0];
assign uart_baud_rate = uart_baud_reg;
assign tx_signal = uart_ctrl_reg[0]; //bit 0 of control register checks  the tx_start signal 
assign load_signal = uart_tx_data_reg[31];
assign transmission_interrupt = uart_interrupt_en_reg[0] && uart_interrupt_pen_reg[0];
assign receiving_interrupt = uart_interrupt_en_reg[1] && uart_interrupt_pen_reg[1];

////////////////////////////////////////////////Stop bits Calculation/////////////////////////////

//bit 1 of control register tells the no of stop bits
// "0" in "bit 1" means "one stop bit"
// "1" in "bit 1" means "2 stop bit"

always_comb begin
    if (uart_ctrl_reg[1] == 1)begin
        stop_bit = 2'b10;
    end
    else begin
        stop_bit = 2'b01;
    end
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
