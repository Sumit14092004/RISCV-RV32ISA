// ALU Control
// Second level decode — determines exact ALU operation
// Uses alu_op from Control Unit + funct3/funct7 from instruction

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire       alu_src,   // 1 for I-type, 0 for R-type (when alu_op == 2'b10)
    output reg  [3:0] alu_ctrl
);

    always @(*) begin
        case (alu_op)

            2'b00: alu_ctrl = 4'b0000;  // ADD (for LW, SW, address calc)

            2'b01: alu_ctrl = 4'b0001;  // SUB (for branch comparison)

            2'b11: alu_ctrl = 4'b1001;  // LUI (pass immediate through)

            2'b10: begin                 // R-type or I-type — check funct3/funct7
                case (funct3)
                    3'b000: begin
                        // SUB only for R-type (alu_src == 0) with funct7[5] == 1.
                        // For I-type (alu_src == 1), funct7[5] is imm[10] and always ADD.
                        if (!alu_src && funct7[5] == 1'b1)
                            alu_ctrl = 4'b0001; // SUB
                        else
                            alu_ctrl = 4'b0000; // ADD / ADDI
                    end
                    3'b111: alu_ctrl = 4'b0010; // AND / ANDI
                    3'b110: alu_ctrl = 4'b0011; // OR  / ORI
                    3'b100: alu_ctrl = 4'b0100; // XOR / XORI
                    3'b010: alu_ctrl = 4'b0101; // SLT / SLTI
                    3'b001: alu_ctrl = 4'b0110; // SLL / SLLI
                    3'b101: begin
                        if (funct7[5] == 1'b1)
                            alu_ctrl = 4'b1000; // SRA / SRAI
                        else
                            alu_ctrl = 4'b0111; // SRL / SRLI
                    end
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            default: alu_ctrl = 4'b0000;

      endcase
      end
      endmodule