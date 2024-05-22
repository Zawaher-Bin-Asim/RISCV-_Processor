module uart (
    input logic     clk,reset,tx_start,load,
    input logic     [7:0]in,
    input logic     [31:0]tx_baud_divisor,clk_rate,
    output logic    out,data_transmitted,
    output logic    [7:0]data_out,
    output logic    stop 
);

//Tx
logic  tx_enable,load_en,tx_sel;
logic tx_baud_clk,rx_baud_clk;
//Rx
logic get_value,data_received,start_bit;
logic bit_clr,get_output,take_value,incre_counter;



baud_rate Baud_CLK(
.clk(clk),.reset(reset),
.tx_baud_divisor(tx_baud_divisor),.clk_rate(clk_rate),
.tx_baud_clk(tx_baud_clk),
.rx_baud_clk(rx_baud_clk)
    );

tx_controller TX_CONTROLLER(
          .clk(tx_baud_clk) ,.reset(reset),.tx_start(tx_start),.load(load),.data_transmitted(data_transmitted),   //inputs
           .tx_enable(tx_enable),.load_en(load_en),.tx_sel(tx_sel)       //outputs
);


tx_datapath TX_DATAPATH(
        .clk(tx_baud_clk),.reset(reset),.load_en(load_en),.tx_enable(tx_enable),.tx_sel(tx_sel), //input
        .in(in),   //input
        .out(out),.data_transmitted(data_transmitted)//output

);


rx_controller RX_CONTROLLER(
                        .clk(rx_baud_clk),.reset(reset),
                        .get_value(get_value),.data_received(data_received),.start_bit(start_bit),.stop(stop),
                        .bit_clr(bit_clr),.get_output(get_output),.take_value(take_value),.incre_counter(incre_counter)
);

rx_datapath RX_DATAPATH(
                    .clk(rx_baud_clk),.reset(reset),
                    .in(out),
                    .bit_clr(bit_clr),.get_output(get_output),.take_value(take_value),.incre_counter(incre_counter),
                    .data_out(data_out),
                    .stop(stop),.start_bit(start_bit),.data_received(data_received),.get_value(get_value)

);

    
endmodule