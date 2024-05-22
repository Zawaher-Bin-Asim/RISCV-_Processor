module rx_controller (
    input logic         clk,reset,
    input logic         get_value,data_received,start_bit,stop,
    output logic        bit_clr,get_output,take_value,incre_counter
);
logic   [1:0]c_state,n_state;
parameter  S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

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
        S0  : begin if (start_bit) n_state =  S1;
                    else  n_state = S0; end
        S1  : begin if (get_value) n_state = S2;
                    else   n_state = S1;end
        S2  : begin if (data_received) n_state = S3;
                    else     n_state =  S1;end
        S3  : begin if (stop) n_state = S0;
                    else     n_state =  S3;end
                             
        default :     n_state = S0;
    endcase           
end
    
always_comb begin 
    case (c_state)
       S0 : begin
            bit_clr       = 1'b1;
            get_output    = 1'b0;
            take_value    = 1'b0;
            incre_counter = 1'b0;
       end 
       S1  : begin

            bit_clr       = 1'b0;
            get_output    = 1'b0;
            take_value    = 1'b0;
            incre_counter = 1'b0;                 
       
       end
       S2  : begin

            bit_clr       = 1'b0;
            get_output    = 1'b0;
            take_value    = 1'b1;
            incre_counter = 1'b1;

       end
       S3  : begin

            bit_clr       = 1'b1;
            get_output    = 1'b1;
            take_value    = 1'b0;
            incre_counter = 1'b0;

       end


        default: begin
            bit_clr       = 1'b1;
            get_output    = 1'b0;
            take_value    = 1'b0;
            incre_counter = 1'b0;

        end
    endcase
    
end


endmodule