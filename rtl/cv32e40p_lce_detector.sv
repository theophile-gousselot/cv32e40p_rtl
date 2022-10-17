module cv32e40p_lce_detector #(
	parameter WWDL
) (
	input clk,
	input rst_n,
	input [31:0] pc_i,
	output alarm_o
);
localparam WWDL_WITDH = $clog2(WWDL+1);	

reg[WWDL_WITDH-1 :0] reg_counter = WWDL;
reg[31 :0] reg_last_pc = pc_i;

assign alarm_o = reg_counter=='0 ? '1 : '0;

always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		reg_counter <= WWDL;
	end else begin
		if (pc_i == reg_last_pc + 4 ) begin
            if (reg_counter!='0) begin
                reg_counter <= reg_counter - 1;
            end
		end else begin
			if (pc_i != reg_last_pc) begin
			    reg_counter <= WWDL;
			end
		end
	end
	reg_last_pc <= pc_i;
end
endmodule

