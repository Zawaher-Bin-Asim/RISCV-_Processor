`include "sc.svh"
`include "pip.svh"


module datapath(
    input logic [width_alu-1:0]alu_op,
	input logic clk, reset, reg_wr,csr_reg_wr,csr_reg_rd,is_mret,reg_wr_e,reg_wr_m,rs1_sel,rs2_sel,rd_en,wr_en,enable_f,enable_pc,
	input logic [1:0]wb_sel,
	input logic  [width-1:0]clk_rate,interuppt,
	output logic [width-1:0]alu_out,
	output logic [width-1:0]fetch_instruction,
	output logic uart_out,
	output logic uart_stop //shows that data have been received by the uart
	);
	
	logic data_transmitted;   //completion of transmission signal for uart
	logic branch_taken;
	logic [width_alu:0]address_wr;
	logic [width-1:0]instruction;

	logic [width-1:0]pc_out,pc_plus;
	logic [width-1:0]rdata1,rdata2,imm_out,mem_out,wb_out;
	logic [width-1:0]forward_a_mux,forward_b_mux;
	
	logic  [width-1:0]mem_phase_out; //output of memory phase
	
	
	
	pip_dp_fetch                pip_dp_fetch;
	pip_dp_decode               pip_dp_decode;
	pip_dp_execute              pip_dp_execute;
	pip_dp_memory               pip_dp_memory;
	LSU_OUTPUTS					lsu_out;
	UART_REGFILE                uart_reg;

    assign fetch_instruction = pip_dp_fetch.instruction_f;
	
	/////////////////////////////Hazarad///////////////////////////////
	logic 		[width-1:0]instruction_he;
	logic       [width_alu:0]rs1_e,rs2_e,rs1_d,rs2_d,rd_hm,rd_w,rd_e,rd_m;
	logic        reg_wr_hm,reg_wr_hw;             // register write signals of the corresponding instructions to know whether they are to be written or not
	logic 		[1:0]forward_a,forward_b;
	logic 		stall_f,stall_d,flush_e,flush_d;
	



	/////////////////////////////////CSR/////////////////////////////////////////////////////
	logic [width-1:0]csr_excep_pc,csr_rd_data;
	logic excep_taken;
	////////////////////////////////////////////////////////////////////////////////////////
	assign  pc_plus = pc_out + 4;
	
     
	 fetch Fetch(
		.clk(clk),.reset(reset),.enable_pc(enable_pc),.stall_f(stall_f),
		.branch_taken(branch_taken),
		.excep_taken(excep_taken),
		.pc_plus(pc_plus),
		.alu_out(alu_out),
		.csr_excep(csr_excep_pc),
		.instruction(instruction),.pc_out(pc_out)
		);
     
	 //Fetch Register   for Pipelining////////////////////////////////////////////////

	 always @(posedge clk or negedge reset)begin
		if (!reset)begin
			pip_dp_fetch.pc_out_f <= 'h0;

		end
		else if (flush_d || !reset)begin

			pip_dp_fetch.instruction_f <= 'h13;

		end

		else begin
			if (enable_f && !stall_d) begin
				pip_dp_fetch.pc_out_f <= pc_out;
				pip_dp_fetch.instruction_f <= instruction;
				
			end
		end

	 end
	 ////////////////////////////////////////////////////////////////////////////////

	 decode Decode(
					.instruction(pip_dp_fetch.instruction_f),
					.address_wr(pip_dp_memory.instruction_m[11:7]),
					.wb_out(wb_out),
					.clk(clk),.reset(reset),.reg_wr(reg_wr),
					.rdata1(rdata1),.rdata2(rdata2),
					.imm_out(imm_out)
					);
					
	 //Decode  Register   for Pipelining////////////////////////////////////////////////

	 always @(posedge clk or negedge reset)begin
		if (!reset || flush_e)begin
			pip_dp_decode.rdata1_d <= 'h0;
			pip_dp_decode.rdata2_d <= 'h0;
			pip_dp_decode.imm_out_d <= 'h0;
			pip_dp_decode.pc_out_d <= 'h0;
			pip_dp_decode.instruction_d <= 'h13;
		end
		else begin
			pip_dp_decode.instruction_d <= pip_dp_fetch.instruction_f;
			pip_dp_decode.rdata1_d <= rdata1;
			pip_dp_decode.rdata2_d <= rdata2;
			pip_dp_decode.imm_out_d <= imm_out;
			pip_dp_decode.pc_out_d <= pip_dp_fetch.pc_out_f;
			

			end

	 end
	 ////////////////////////////////////////////////////////////////////////////////

	////////////////////////HAZARD UNIT//////////////////////////////////////////////
	hazard_unit HAZARD_UNIT(
				.instruction_he(pip_dp_decode.instruction_d),       										//instruction in execute stage   
				.rs1_e(pip_dp_decode.instruction_d[19:15]),.rs2_e(pip_dp_decode.instruction_d[24:20]),      						 //rs1 and rs2 are source registers that are currently inexecute stage
				.rd_m(pip_dp_execute.instruction_e[11:7]),.rd_w(pip_dp_memory.instruction_m[11:7]),        //rd_m and rd_w are the destination register of instructions that are currently in memory and write back stage
				.reg_wr_hm(reg_wr_e),.reg_wr_hw(reg_wr_m),             										// register write signals of the corresponding instructions to know whether they are to be written or not
				.rs1_d(pip_dp_fetch.instruction_f[19:15]),.rs2_d(pip_dp_fetch.instruction_f[24:20]),     														//rs1 and rs2 are source registers that are currently decode stage
				.rd_e(pip_dp_decode.instruction_d[11:7]),             										//rd_e  is the destination register of instruction that is currently in execute stage(LOAD)
				.branch_taken(branch_taken),			
				.forward_a(forward_a),.forward_b(forward_b), 
				.stall_f(stall_f),.stall_d(stall_d),.flush_e(flush_e),.flush_d(flush_d)
			);



	////////////FORWARDING MUXES////////////////////////////////////////////////////
	
	 forwarding_mux  FORWARDING_MUX_A(
  			.mem(pip_dp_execute.alu_out_e),.wb(wb_out),.in(pip_dp_decode.rdata1_d),.sel(forward_a),.out(forward_a_mux)
	);

	forwarding_mux  FORWARDING_MUX_B(
  			.mem(pip_dp_execute.alu_out_e),.wb(wb_out),.in(pip_dp_decode.rdata2_d),.sel(forward_b),.out(forward_b_mux)
	);

	
		
	////////////////////////////////////////////////////////////////////////////////

	 execute Execute(
						.instruction(pip_dp_decode.instruction_d),		
						.rdata1(forward_a_mux),
						.rdata2(forward_b_mux),
						.pc_out(pip_dp_decode.pc_out_d),
						.imm_out(pip_dp_decode.imm_out_d),
						.rs1_sel(rs1_sel),.rs2_sel(rs2_sel),
						.alu_op(alu_op),.alu_out(alu_out),.branch_taken(branch_taken)
						);
					
//Execute  Register   for Pipelining////////////////////////////////////////////////

	 always @(posedge clk or negedge reset)begin
		if (!reset)begin
			pip_dp_execute.instruction_e <= 'h0;
			pip_dp_execute.rdata2_e <= 'h0;
			pip_dp_execute.alu_out_e <= 'h0;
			pip_dp_execute.pc_out_e <= 'h0;
			pip_dp_execute.forward_a_mux_e <= 'h0;
			pip_dp_execute.imm_out_e <= 'h0;

		end
		else begin
			pip_dp_execute.instruction_e <= pip_dp_decode.instruction_d;
			pip_dp_execute.rdata2_e <= forward_b_mux;  //data to memory is now change to the output of forward_b mux
			pip_dp_execute.alu_out_e <= alu_out;
			pip_dp_execute.pc_out_e <= pip_dp_decode.pc_out_d;
			pip_dp_execute.forward_a_mux_e <= forward_a_mux;
			pip_dp_execute.imm_out_e <= pip_dp_decode.imm_out_d;

			end

	 end
	 ////////////////////////////////////////////////////////////////////////////////


	lsu_unit LSU(
                   .instruction(pip_dp_execute.instruction_e),.data(pip_dp_execute.rdata2_e),.dbus_address(pip_dp_execute.alu_out_e),
			       .we(lsu_out.we),.re(lsu_out.re),.uart_sel(lsu_out.uart_sel),.dmem_sel(lsu_out.dmem_sel),
        		   .input_data(lsu_out.input_data),.reg_address(lsu_out.reg_address)
);

	 memory Memory(
					.addr(lsu_out.reg_address),
					.data_in(lsu_out.input_data),
					.clk(clk) ,.rd_en(lsu_out.re),.wr_en(lsu_out.we),
					.func3(pip_dp_execute.instruction_e[14:12]),.mem_out(mem_out)
				);

	uart_registers UART_REGFILE(
         .clk(clk),.reset(reset),.uart_sel(lsu_out.uart_sel),.we(lsu_out.we),.re(lsu_out.re),.data_transmitted(data_transmitted),
         .address(lsu_out.reg_address),.data_in(lsu_out.input_data),
		.read_out(uart_reg.read_out),.uart_baud_rate(uart_reg.uart_baud_rate),
		.uart_data(uart_reg.uart_data),
		.load_signal(uart_reg.load_signal),.tx_signal(uart_reg.tx_signal)
    );
//////////////////////////////////////MUX FOR SELECTING THE MEMORY PHASE OUTPUT BETWEEN UART AND MEMORY///////////////////////////////////
	always_comb begin
		case (lsu_out.dmem_sel)
			1'b1	: mem_phase_out = mem_out;
			1'b0    : mem_phase_out = uart_reg.read_out;
			default: mem_phase_out = mem_out;
		endcase		
		
	end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	uart UART(
    		.clk(clk),.reset(reset),.tx_start(uart_reg.tx_signal),.load(uart_reg.load_signal),
    		.in(uart_reg.uart_data),
    		.tx_baud_divisor(uart_reg.uart_baud_rate),.clk_rate(clk_rate),
    		.out(uart_out),.data_transmitted(data_transmitted),.data_out(uart_reg.rx_data_out),.stop(uart_stop)
);


////////////////////////////////////////////////////CSR////////////////////////////////////////////////////////////////////////////////////////////////

	csr_reg_file CSR_REG_FILE(
	                     .clk(clk),.reset(reset),
    			         .pc(pip_dp_execute.pc_out_e),.wdata(pip_dp_execute.forward_a_mux_e),
    			         .address(pip_dp_execute.imm_out_e[11:0]),
						 .func3(pip_dp_execute.instruction_e[14:12]),
    			         .reg_wr(csr_reg_wr),.reg_rd(csr_reg_rd),
						 .is_mret(is_mret),
    			         .excep(interuppt),
						 .excep_taken(excep_taken),
    			        .excep_pc(csr_excep_pc),.rd_data(csr_rd_data)
	);


	//Memory  Register   for Pipelining////////////////////////////////////////////////
	 always @(posedge clk or negedge reset)begin
		if (!reset)begin
			pip_dp_memory.instruction_m <= 'h0;
			pip_dp_memory.mem_out_m <= 'h0;
			pip_dp_memory.alu_out_m <= 'h0;
			pip_dp_memory.pc_plus_m <= 'h0;
			pip_dp_memory.csr_rd_data_m <= 'h0;

		end
		else begin
			
			pip_dp_memory.instruction_m <= pip_dp_execute.instruction_e;
			pip_dp_memory.mem_out_m <= mem_phase_out;
			pip_dp_memory.alu_out_m <= pip_dp_execute.alu_out_e;
			pip_dp_memory.pc_plus_m <= pip_dp_execute.pc_out_e + 4;
			pip_dp_memory.csr_rd_data_m <= csr_rd_data;

			end

	 end
	 ////////////////////////////////////////////////////////////////////////////////


	
	 writeback WriteBack(.a(pip_dp_memory.mem_out_m),.b(pip_dp_memory.alu_out_m),.c(pip_dp_memory.pc_plus_m),.d(pip_dp_memory.csr_rd_data_m),.sel(wb_sel),.out(wb_out));
	



		
	endmodule

