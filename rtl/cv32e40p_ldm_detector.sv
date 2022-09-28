module cv32e40p_ldm_detector #(
	parameter MAX_BB_LEN,
	parameter MAX_INSTR_EXE_CYCLES
) (
	input clk,
	input rst_n,
	input [31:0] instr_rdata_id_i,
	input decrement_i,
	output alarm_o
);
localparam MAX_BB_LEN_WITDH = $clog2(MAX_BB_LEN+1);	
localparam MAX_INSTR_EXE_CYCLES_WITDH = $clog2(MAX_INSTR_EXE_CYCLES+1);	

reg[MAX_BB_LEN_WITDH-1 :0] reg_counter = MAX_BB_LEN;
reg[MAX_INSTR_EXE_CYCLES_WITDH-1 :0] reg_decrement_unset = MAX_INSTR_EXE_CYCLES;

assign alarm_o = (reg_counter=='0 | reg_decrement_unset=='0) ? '1 : '0;

always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		reg_counter <= MAX_BB_LEN;
	end else begin
		if (instr_rdata_id_i==32'h0000006f) begin
			reg_counter <= MAX_BB_LEN;
		end else begin
			if (decrement_i) begin
				if (reg_counter!='0) begin
					reg_counter <= reg_counter - 1;
				end
			end
		end
	end
end

always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		reg_decrement_unset <= MAX_INSTR_EXE_CYCLES;
	end else begin
        if (decrement_i=='0) begin
            reg_decrement_unset <= reg_decrement_unset - 1;
		end else begin
            reg_decrement_unset <= MAX_INSTR_EXE_CYCLES;
		end
	end
end
endmodule
