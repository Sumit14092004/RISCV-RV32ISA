// MEM/WB Pipeline Register
// Last pipeline register — carries data and control to WB stage
// Simplest register — most control signals already consumed

module mem_wb_reg (
    input  wire        clk,
    input  wire        reset,

    // Data inputs from MEM stage
    input  wire [31:0] alu_result_in,   // arithmetic result
    input  wire [31:0] read_data_in,    // data read from memory (LW)
    input  wire [4:0]  rd_in,           // destination register address

    // Control inputs
    input  wire        mem_to_reg_in,   // 1 = write memory data, 0 = write ALU result
    input  wire        reg_write_in,    // 1 = write to register file

    // Data outputs to WB stage
    output reg  [31:0] alu_result_out,
    output reg  [31:0] read_data_out,
    output reg  [4:0]  rd_out,

    // Control outputs
    output reg         mem_to_reg_out,
    output reg         reg_write_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'h0;
            read_data_out  <= 32'h0;
            rd_out         <= 5'h0;
            mem_to_reg_out <= 0;
            reg_write_out  <= 0;
        end
        else begin
            alu_result_out <= alu_result_in;
            read_data_out  <= read_data_in;
            rd_out         <= rd_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
        end
    end

endmodule