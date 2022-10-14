module cv32e40p_insert_security_markers #(
	parameter MAX_BB_LEN
) (
	input clk,
	input rst_n,
	input [31:0] instr_i,
	output [31:0] instr_o
);
localparam MAX_BB_LEN_WIDTH = $clog2(MAX_BB_LEN+1);	
reg[MAX_BB_LEN_WIDTH-1 :0] reg_counter = MAX_BB_LEN-2;

logic is_disc_instr = '0;

// If counter is at 1 or 2 when there is a BRANCH, the
    // security marker added in 1 or 2 instructions will be drop by the pipeline
    // in case of BRANCH taken. Without initialize the lce_detector counter.
logic is_disc_instr_and_counter_near_zero;
assign is_disc_instr_and_counter_near_zero = ((reg_counter == 1 || reg_counter == 2) && is_disc_instr) ? 1 : 0;

assign instr_o = ((reg_counter == '0 && instr_i != '0)|| is_disc_instr_and_counter_near_zero ) ? 32'h000006f : instr_i;

// COUNTER
always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		reg_counter <= MAX_BB_LEN-2;
	end else begin
        if (instr_i != '0) begin
            if (reg_counter == '0) begin
                reg_counter <= MAX_BB_LEN;
            end else begin
                reg_counter <= reg_counter - 1;
            end
        end
	end
end

// IS A DISCONTINUITY INSTRUCTION ?
always_comb begin                                                                  
    unique case (instr_i[6:2])                                                     
      // Branch                                                                    
      5'b11000: begin                                                              
        is_disc_instr = '1;                                                        
      end                                                                          
                                                                                   
      // JAL                                                                       
      5'b11011: begin                                                              
        is_disc_instr = '1;                                                        
      end                                                                          
                                                                                   
      // JALR                                                                      
      5'b11001: begin                                                              
        if (instr_i[14:12] == 3'b000) begin                                        
          is_disc_instr = '1;                                                      
        end                                                                        
      end
      default: is_disc_instr = '0;                                                 
    endcase   
end

endmodule



