module tx_controller (
input logic            clk ,reset,tx_start,load,data_transmitted,
output logic           tx_enable,load_en,tx_sel
);

logic   [1:0]c_state,n_state;
parameter  S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;

always_ff @( posedge clk or negedge reset ) begin 
    if (!reset)begin
        c_state <= S0;
    end
    else begin
        c_state <= n_state;
    end

end
always_comb begin
    case (c_state)  
        S0  : begin if (load) n_state =  S1;
                    else  n_state = S0; end
        S1  : begin if (tx_start) n_state = S2;
                    else   n_state = S1;end
        S2  : begin if (data_transmitted) n_state = S0;
                    else     n_state =  S2;end           
        default :     n_state = S0;
    endcase           
end

always_comb begin 
    case (c_state)
       S0 : begin
            load_en = 1'b0;
            tx_enable = 1'b0;
            tx_sel = 1'b0;
       end 
       S1  : begin
                load_en = 1'b1;
                tx_enable = 1'b0;
                tx_sel = 1'b0;
                 
       end
       S2  : begin
                load_en = 1'b0;
                tx_enable = 1'b1;
                tx_sel = 1'b1;
                 
       end
        default: begin
                load_en = 1'b0;
                tx_enable = 1'b0;
                tx_sel = 1'b0;
        end
    endcase
    
end


    
endmodule