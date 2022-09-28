module cv32e40p_insert_discontinuity #(
	parameter MAX_BB_LEN
) (
	input clk,
	input rst_n,
	input [31:0] instr_i,
	output [31:0] instr_o
);
localparam MAX_BB_LEN_WIDTH = $clog2(MAX_BB_LEN+1);	
reg[MAX_BB_LEN_WIDTH-1 :0] reg_counter = MAX_BB_LEN-2;

logic           is_disc_instr = '0;


assign instr_o = (reg_counter == '0 && instr_i != '0) ? 32'h000006f : instr_i;

always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		reg_counter <= MAX_BB_LEN-2;
	end else begin
        if (instr_i != '0) begin
            if (reg_counter == '0) begin
                reg_counter <= MAX_BB_LEN;
            end else if (is_disc_instr) begin
                reg_counter <= MAX_BB_LEN;
            end else begin
                reg_counter <= reg_counter - 1;
            end
        end
	end
end

always_comb begin
unique case (instr_i[1:0])
  // C1
  2'b01: begin
    unique case (instr_i[15:13])
      3'b001, 3'b101, 3'b110, 3'b111: begin
        // 001: c.jal -> jal x1, imm
        // 101: c.j   -> jal x0, imm
        // 110: c.beqz -> beq rs1', x0, imm
        // 111: c.bnez -> bne rs1', x0, imm
        is_disc_instr = '1;
      end
    default:  is_disc_instr = '0;
    endcase
  end

  // C2
  2'b10: begin
    unique case (instr_i[15:13])
      3'b100: begin
        if (instr_i[12] == 1'b0 && instr_i[6:2] == 5'b0) begin
          // c.jr -> jalr x0, rd/rs1, 0
          // instr_o = {12'b0, instr_i[11:7], 3'b0, 5'b0, OPCODE_JALR};
          is_disc_instr = '1;
        end else if (instr_i[6:2] == 5'b0 && instr_i[11:7] != 5'b0) begin
          // c.jalr -> jalr x1, rs1, 0
          // instr_o = {12'b0, instr_i[11:7], 3'b000, 5'b00001, OPCODE_JALR};
          is_disc_instr = '1;
        end
      end
    default: is_disc_instr = '0;
    endcase
  end

  // 32 bit (or more) instruction
  default: begin
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
endcase
end

endmodule



