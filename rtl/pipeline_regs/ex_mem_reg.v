// EX/MEM Pipeline Register
// Latches EX stage outputs for MEM and WB stages
// No stall or flush needed — hazards resolved before this point

module ex_mem_reg (
    input  wire        clk,
    input  wire        reset,

    // Data inputs from EX stage
    input  wire [31:0] alu_result_in,   // ALU computation result
    input  wire [31:0] write_data_in,   // rs2 value — for SW instruction
    input  wire [4:0]  rd_in,           // destination register address
    input  wire        zero_in,         // ALU zero flag

    // Control signals from EX stage
    input  wire        mem_read_in,     // 1 = LW instruction
    input  wire        mem_write_in,    // 1 = SW instruction
    input  wire        mem_to_reg_in,   // 1 = write memory data to reg (LW)
    input  wire        reg_write_in,    // 1 = write result to register file

    // Data outputs to MEM stage
    output reg  [31:0] alu_result_out,
    output reg  [31:0] write_data_out,
    output reg  [4:0]  rd_out,
    output reg         zero_out,

    // Control signal outputs
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'h0;
            write_data_out <= 32'h0;
            rd_out         <= 5'h0;
            zero_out       <= 0;
            mem_read_out   <= 0;
            mem_write_out  <= 0;
            mem_to_reg_out <= 0;
            reg_write_out  <= 0;
        end
        else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out         <= rd_in;
            zero_out       <= zero_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
        end
    end

endmodule