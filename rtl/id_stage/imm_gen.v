// Immediate Generator
// Extracts and sign-extends immediates from instruction
// Handles I, S, B, U, J type encodings

module imm_gen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)

            7'b0010011,         // I-type ALU (ADDI, ANDI, ORI...)
            7'b0000011,         // I-type Load (LW)
            7'b1100111: begin   // JALR
                // bits [31:20] sign extended
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            7'b0100011: begin   // S-type (SW)
                // bits [31:25] and [11:7]
                imm_out = {{20{instruction[31]}},
                            instruction[31:25],
                            instruction[11:7]};
            end

            7'b1100011: begin   // B-type (BEQ, BNE)
                // bits scattered: [31],[7],[30:25],[11:8], LSB always 0
                imm_out = {{20{instruction[31]}},
                            instruction[7],
                            instruction[30:25],
                            instruction[11:8],
                            1'b0};
            end

            7'b0110111,         // U-type LUI
            7'b0010111: begin   // U-type AUIPC
                // bits [31:12], lower 12 bits are 0
                imm_out = {instruction[31:12], 12'b0};
            end

            7'b1101111: begin   // J-type (JAL)
                // bits scattered: [31],[19:12],[20],[30:21], LSB always 0
                imm_out = {{12{instruction[31]}},
                            instruction[19:12],
                            instruction[20],
                            instruction[30:21],
                            1'b0};
            end

            default: imm_out = 32'h00000000;

        endcase
    end

endmodule