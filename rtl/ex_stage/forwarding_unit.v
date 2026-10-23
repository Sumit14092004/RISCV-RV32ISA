// Forwarding Unit
// Detects data hazards and selects correct ALU inputs
// Purely combinational — no clock needed
// Implements EX-EX and MEM-EX forwarding paths

module forwarding_unit (
    // Current instruction in EX stage
    input  wire [4:0] ex_rs1,           // source register 1 address
    input  wire [4:0] ex_rs2,           // source register 2 address

    // Instruction currently in MEM stage
    input  wire [4:0] mem_rd,           // destination register address
    input  wire       mem_reg_write,    // 1 if MEM instruction writes a register

    // Instruction currently in WB stage
    input  wire [4:0] wb_rd,            // destination register address
    input  wire       wb_reg_write,     // 1 if WB instruction writes a register

    // Output — MUX select signals for ALU inputs
    output reg  [1:0] forward_a,        // controls MUX A (rs1 path)
    output reg  [1:0] forward_b         // controls MUX B (rs2 path)
);

    always @(*) begin
        // Default — no forwarding, use register file value
        forward_a = 2'b00;
        forward_b = 2'b00;

        // ── ForwardA — rs1 ──────────────────────────────────

        // EX-EX: MEM stage result → EX stage rs1
        // MEM instruction is writing to the same reg EX needs
        if (mem_reg_write &&
            mem_rd != 5'b00000 &&
            mem_rd == ex_rs1)
            forward_a = 2'b10;

        // MEM-EX: WB stage result → EX stage rs1
        // Only if EX-EX didn't already fire (EX-EX is more recent → higher priority)
        else if (wb_reg_write &&
                 wb_rd != 5'b00000 &&
                 wb_rd == ex_rs1)
            forward_a = 2'b01;

        // ── ForwardB — rs2 ──────────────────────────────────

        // EX-EX: MEM stage result → EX stage rs2
        if (mem_reg_write &&
            mem_rd != 5'b00000 &&
            mem_rd == ex_rs2)
            forward_b = 2'b10;

        // MEM-EX: WB stage result → EX stage rs2
        else if (wb_reg_write &&
                 wb_rd != 5'b00000 &&
                 wb_rd == ex_rs2)
            forward_b = 2'b01;
    end

endmodule