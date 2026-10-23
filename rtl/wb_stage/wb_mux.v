// Write Back MUX
// Selects the correct value to write back to the register file
// mem_to_reg = 0 → ALU result (arithmetic)
// mem_to_reg = 1 → Memory read data (LW)

module wb_mux (
    input  wire        mem_to_reg,      // select signal from control
    input  wire [31:0] alu_result,      // from EX stage via MEM/WB
    input  wire [31:0] read_data,       // from data memory via MEM/WB
    output wire [31:0] write_data       // final value → register file
);

    assign write_data = mem_to_reg ? read_data : alu_result;

endmodule