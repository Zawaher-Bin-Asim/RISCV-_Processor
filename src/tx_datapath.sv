module tx_datapath (
input logic         clk,reset,load_en,tx_enable,tx_sel,
input logic         [7:0]in,
input logic         [1:0]stop_bit,
output logic        out,data_transmitted
);
logic piso_out;
logic idol = 1'b1;

piso PISO(
    .clk(clk), .reset(reset),
    .tx_enable(tx_enable), .load_en(load_en),
    .in(in), .stop_bit(stop_bit), .out(piso_out)
);    

tx_counter TX_COUNTER(
    .clk(clk), .reset(reset),
    .tx_enable(tx_enable), .stop_bit(stop_bit),
    .data_transmitted(data_transmitted)
);

tx_mux TX_MUX(
    .a(idol), .b(piso_out),
    .sel(tx_sel),
    .out(out)
);

endmodule



/////////////////////////Parallel In Serial OUt Shift Register/////////////////////////////////////////////////////////////////
module piso(
input logic            clk,reset,
input logic            tx_enable,load_en,
input logic            [7:0]in,  
input logic            [1:0]stop_bit,
output logic           out
);
logic [10:0]q;

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset)begin
        q <= 11'b11111111111;
    end    
    else begin  
        if (load_en)begin
            q[0]    <= 1'b0; // Start bit
            q[8:1]  <= in;   // Data bits
            q[9]    <= 1'b1; // First stop bit
            q[10]   <= 1'b1; // Second stop bit if needed
        end    
        else begin
            if (tx_enable) begin
                out <= q[0];
                q  <= q >> 1;  
            end
            else 
                out <= 1'b1;
        end
    end
end
    
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////For counting the tramnsmitted bits///////////////////////////////////////////////////
module tx_counter (
    input logic     clk,reset,
    input logic     tx_enable,
    input logic     [1:0]stop_bit,
    output logic    data_transmitted
);
reg [3:0] counter; // Adjusted width to accommodate up to 11 bits

always_ff @(posedge clk or negedge reset)begin
    if (!reset) begin
       counter <= 'h0;
       data_transmitted <= 1'b0;
    end
    else begin
        if(tx_enable)begin
            if (counter == (9 + stop_bit)) begin // Adjust max count based on stop bits
                data_transmitted <= 1'b1;
                counter <= 'h0;
            end
            else begin
                data_transmitted <= 1'b0;
                counter <= counter + 1;
            end
        end   
    end
end
    
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////TX_MUX///////////////////////////////////////////////////////////////////////////
module tx_mux (
    input logic         a,b,
    input logic         sel,
    output logic        out  
);
always_comb begin 
    case (sel)
        1'b0 : out = a;
        1'b1 : out = b;
        default: out = 1'b1;
    endcase
end

endmodule