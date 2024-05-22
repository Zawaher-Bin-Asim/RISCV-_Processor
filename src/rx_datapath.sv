module rx_datapath (
    input logic     clk,reset,
    input logic     in,
    input logic     bit_clr,get_output,take_value,incre_counter,
    output logic    [7:0]data_out,
    output logic    stop,start_bit,data_received,get_value

);


sipo SIPO(
                    .clk(clk),.reset(reset),
                    .take_value(take_value),.get_output(get_output),
                    .data_in(in),
                    .start_bit(start_bit),.stop(stop),
                    .data_out(data_out)

);

bit_counter Bit_Counter(
                   .clk(clk),.reset(reset),.bit_clr(bit_clr),  
                   .incre_counter(incre_counter),
                   .data_received(data_received)
    );


sample_counter SAMLE_COUNTER(
        .clk(clk),.reset(reset),
        .start(start_bit),
        .get_value(get_value)
);



endmodule

module  sipo(
    input logic      clk,reset,
    input logic      take_value,get_output,
    input logic      data_in,
    output logic     start_bit,stop,
    output logic     [7:0]data_out

);
logic [9:0]temp,q;  

assign start_bit = (data_in == 1'b0) ;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        temp <= 'h0;
        q <= 'h0;
        data_out <= 'h0;
        stop <= 1'b0;
    end
    else begin
        if (take_value) begin
            temp <= {data_in, temp[9:1]};
            q <= temp;
        end
        else if (get_output) begin
            data_out <= q[9:2];
            stop <= 1'b1;
        end
        else begin
            stop <= 1'b0;
        end
    end
end

endmodule


module bit_counter (
    input logic     clk,reset,bit_clr,  
    input logic     incre_counter,
    output logic    data_received
    );
localparam  max_bits = 10;

logic [3:0]counter;


 always_ff @(posedge clk or negedge reset)begin
    if(!reset | bit_clr)begin
        counter <= 'h0;
    end
    else begin
        if (counter == max_bits-1) begin
            data_received <= 1'b1;
        end
        else begin
            data_received <= 1'b0;
            if (incre_counter) begin
                counter <= counter + 1;

            end
            else begin
                counter <= counter;
            end
        end
    end
 end   
    
endmodule


module sample_counter(
    input logic clk, reset,
    input logic start,
    output logic get_value
);

    logic [2:0] counter;
    logic started;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 3'b000;
            started <= 1'b0;
            get_value <= 1'b0;
        end
        else begin
            if (!started && start) begin // First positive edge of start
                counter <= 3'b000;
                started <= 1'b1;
            end
            else if (!started) begin
                get_value <= 1'b0; // Remain low until started
            end
            else if (counter == 3'b100) begin
                counter <= counter + 1;
                get_value <= 1'b1;
            end
            else if (counter == 3'b111) begin
                counter <= 3'b000;
                get_value <= 1'b0;
            end
            else begin
                counter <= counter + 1;
                get_value <= 1'b0;
            end
        end
    end
endmodule

