// ID/EX Pipeline Register
// Latches all ID stage outputs for use in EX stage
// Supports flush and reset (stall not needed here)

module id_ex_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // Data inputs from ID stage
    input  wire [31:0] pc_in,
    input  wire [31:0] read_data1_in,
    input  wire [31:0] read_data2_in,
    input  wire [31:0] imm_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,

    // Control signal inputs
    input  wire        reg_write_in,
    input  wire        alu_src_in,
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire        mem_to_reg_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input  wire [1:0]  alu_op_in,
    input  wire [2:0]  funct3_in,
    input  wire [6:0]  funct7_in,

    // Data outputs to EX stage
    output reg  [31:0] pc_out,
    output reg  [31:0] read_data1_out,
    output reg  [31:0] read_data2_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out,

    // Control signal outputs
    output reg         reg_write_out,
    output reg         alu_src_out,
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg         mem_to_reg_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg  [1:0]  alu_op_out,
    output reg  [2:0]  funct3_out,
    output reg  [6:0]  funct7_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // flush all data and control signals to 0
            pc_out          <= 32'h0;
            read_data1_out  <= 32'h0;
            read_data2_out  <= 32'h0;
            imm_out         <= 32'h0;
            rs1_out         <= 5'h0;
            rs2_out         <= 5'h0;
            rd_out          <= 5'h0;
            reg_write_out   <= 0;
            alu_src_out     <= 0;
            mem_write_out   <= 0;
            mem_read_out    <= 0;
            mem_to_reg_out  <= 0;
            branch_out      <= 0;
            jump_out        <= 0;
            alu_op_out      <= 2'b00;
            funct3_out      <= 3'h0;
            funct7_out      <= 7'h0;
        end
        else begin
            pc_out          <= pc_in;
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            imm_out         <= imm_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;
            reg_write_out   <= reg_write_in;
            alu_src_out     <= alu_src_in;
            mem_write_out   <= mem_write_in;
            mem_read_out    <= mem_read_in;
            mem_to_reg_out  <= mem_to_reg_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            alu_op_out      <= alu_op_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;
        end
    end

endmodule