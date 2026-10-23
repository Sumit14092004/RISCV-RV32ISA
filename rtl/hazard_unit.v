// Hazard Detection Unit
// Detects load-use hazards and generates stall signals
// Forwarding handles all other data hazards
// Only one case needs stalling: LW followed immediately by dependent instruction

module hazard_unit (
    // Instruction currently in EX stage
    input  wire       id_ex_mem_read,   // 1 if EX instruction is LW
    input  wire [4:0] id_ex_rd,         // destination register of EX instruction

    // Instruction currently in ID stage
    input  wire [4:0] if_id_rs1,        // source register 1
    input  wire [4:0] if_id_rs2,        // source register 2

    // Outputs
    output reg        stall,            // 1 = freeze PC and IF/ID register
    output reg        id_ex_flush       // 1 = insert NOP bubble into ID/EX
);

    always @(*) begin
        // Default — no hazard
        stall        = 0;
        id_ex_flush  = 0;

        // Load-use hazard detected when:
        // 1. EX stage instruction is a LW (mem_read = 1)
        // 2. LW destination matches rs1 OR rs2 of ID stage instruction
        // 3. LW destination is not x0 (writing to x0 is meaningless)
        if (id_ex_mem_read &&
            id_ex_rd != 5'b00000 &&
            (id_ex_rd == if_id_rs1 ||
             id_ex_rd == if_id_rs2))
        begin
            stall       = 1;   // freeze PC and IF/ID
            id_ex_flush = 1;   // insert bubble into ID/EX
        end
    end

endmodule