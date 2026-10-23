// Control Unit
// Decodes opcode and generates all control signals
// Only looks at bits [6:0] of the instruction

module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_write,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg  [1:0] alu_op
);

    always @(*) begin
        // default all signals to 0 (safe state)
        reg_write  = 0;
        alu_src    = 0;
        mem_write  = 0;
        mem_read   = 0;
        mem_to_reg = 0;
        branch     = 0;
        jump       = 0;
        alu_op     = 2'b00;

        case (opcode)
            7'b0110011: begin   // R-type (ADD, SUB, AND, OR, SLT)
                reg_write  = 1;
                alu_src    = 0; // use rs2
                alu_op     = 2'b10;
            end

            7'b0010011: begin   // I-type (ADDI, SLTI, ANDI, ORI)
                reg_write  = 1;
                alu_src    = 1; // use immediate
                alu_op     = 2'b10;
            end

            7'b0000011: begin   // Load (LW)
                reg_write  = 1;
                alu_src    = 1; // base + offset
                mem_read   = 1;
                mem_to_reg = 1;
                alu_op     = 2'b00; // ADD for address
            end

            7'b0100011: begin   // Store (SW)
                alu_src    = 1; // base + offset
                mem_write  = 1;
                alu_op     = 2'b00; // ADD for address
            end

            7'b1100011: begin   // Branch (BEQ, BNE)
                branch     = 1;
                alu_src    = 0; // compare rs1 and rs2
                alu_op     = 2'b01;
            end

            7'b1101111: begin   // JAL
                reg_write  = 1;
                jump       = 1;
                alu_op     = 2'b00;
            end

            7'b0110111: begin   // LUI
                reg_write  = 1;
                alu_src    = 1;
                alu_op     = 2'b11;
            end

            default: begin      // unknown opcode — all signals 0
                reg_write  = 0;
                alu_op     = 2'b00;
            end
        endcase
    end

endmodule