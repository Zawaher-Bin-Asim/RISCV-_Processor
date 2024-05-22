module tx_datapath (
input logic         clk,reset,load_en,tx_enable,tx_sel,
input logic         [7:0]in,
output logic        out,data_transmitted


);
logic piso_out;
logic idol = 1'b1;



piso PISO(
          .clk(clk),.reset(reset),
          .tx_enable(tx_enable),.load_en(load_en),
          .in(in),         .out(piso_out)
);    

tx_counter TX_COUNTER(
            .clk(clk),.reset(reset),
            .tx_enable(tx_enable),
            .data_transmitted(data_transmitted)
);

tx_mux TX_MUX(
             .a(idol),.b(piso_out),
             .sel(tx_sel),
             .out(out)  
);



    
endmodule

/////////////////////////Parallel In Serial OUt Shift Register/////////////////////////////////////////////////////////////////
module piso(
input logic            clk,reset,
input logic            tx_enable,load_en,
input logic            [7:0]in,  
output logic           out
);
logic [9:0]q;

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset)begin
        q <= 10'b1111111111;
    end    
    else begin  
        if (load_en)begin
            q[0]    <= 1'b0;
            q[8:1]  <= in;
            q[9]    <= 1'b1;
        end    
        else begin
            if (tx_enable) begin
                out <= q[0];
                q  <=   q>>1;  
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
    output logic    data_transmitted
);
localparam  max_count = 4'd10 ;
reg [3:0]counter;

always_ff @(posedge clk or negedge reset)begin
    if (!reset) begin
       counter <= 'h0;
       data_transmitted <= 1'b0;
    end
    else begin
        if(tx_enable)begin
            if (counter == max_count-1)begin
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