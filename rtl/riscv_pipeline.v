// RISC-V RV32I 5-Stage Pipelined Processor
// Top-level module — connects all pipeline stages
// Author: Sumit Pandey | RRU ECE | 2026

module riscv_pipeline (
    input wire clk,
    input wire reset
);

// ──────────────────────────────────────────────
// WIRE DECLARATIONS — grouped by pipeline stage
// ──────────────────────────────────────────────

// IF stage wires
wire [31:0] pc_current;         // current PC value
wire [31:0] pc_next;            // next PC (PC+4 or branch target)
wire [31:0] pc_plus4;           // PC + 4
wire [31:0] instr_if;           // fetched instruction

// IF/ID pipeline register outputs
wire [31:0] pc_id;              // PC in ID stage
wire [31:0] instr_id;           // instruction in ID stage

// ID stage wires
wire [31:0] read_data1_id;      // rs1 value from register file
wire [31:0] read_data2_id;      // rs2 value from register file
wire [31:0] imm_id;             // sign-extended immediate
wire [6:0]  opcode_id;          // instruction opcode
wire [4:0]  rs1_id, rs2_id;     // source register addresses
wire [4:0]  rd_id;              // destination register address
wire [2:0]  funct3_id;          // funct3 field
wire [6:0]  funct7_id;          // funct7 field

// Control signals from control unit
wire        reg_write_id;
wire        alu_src_id;
wire        mem_write_id;
wire        mem_read_id;
wire        mem_to_reg_id;
wire        branch_id;
wire        jump_id;
wire [1:0]  alu_op_id;

// ID/EX pipeline register outputs
wire [31:0] pc_ex;
wire [31:0] read_data1_ex;
wire [31:0] read_data2_ex;
wire [31:0] imm_ex;
wire [4:0]  rs1_ex, rs2_ex;
wire [4:0]  rd_ex;
wire [2:0]  funct3_ex;
wire [6:0]  funct7_ex;
wire        reg_write_ex;
wire        alu_src_ex;
wire        mem_write_ex;
wire        mem_read_ex;
wire        mem_to_reg_ex;
wire        branch_ex;
wire        jump_ex;
wire [1:0]  alu_op_ex;

// EX stage wires
wire [3:0]  alu_ctrl;           // ALU operation code
wire [31:0] alu_input_a;        // ALU operand A (after forwarding MUX)
wire [31:0] alu_input_b;        // ALU operand B (after forwarding MUX)
wire [31:0] alu_input_b_pre;    // before alu_src MUX
wire [31:0] alu_result_ex;      // ALU result
wire        zero_ex;            // ALU zero flag
wire [31:0] branch_target;      // PC + imm
wire        pc_src;             // branch/jump taken
wire        flush;              // pipeline flush signal
wire [1:0]  forward_a;          // forwarding MUX A select
wire [1:0]  forward_b;          // forwarding MUX B select

// EX/MEM pipeline register outputs
wire [31:0] alu_result_mem;
wire [31:0] write_data_mem;
wire [4:0]  rd_mem;
wire        zero_mem;
wire        mem_read_mem;
wire        mem_write_mem;
wire        mem_to_reg_mem;
wire        reg_write_mem;

// MEM stage wires
wire [31:0] read_data_mem;      // data read from data memory

// MEM/WB pipeline register outputs
wire [31:0] alu_result_wb;
wire [31:0] read_data_wb;
wire [4:0]  rd_wb;
wire        mem_to_reg_wb;
wire        reg_write_wb;

// WB stage wires
wire [31:0] write_data_wb;      // final value written to register file

// Hazard unit wires
wire        stall;              // freeze PC and IF/ID
wire        id_ex_flush_haz;    // bubble from hazard unit

// ──────────────────────────────────────────────
// INSTRUCTION FIELD EXTRACTION
// ──────────────────────────────────────────────
assign opcode_id = instr_id[6:0];
assign rd_id     = instr_id[11:7];
assign funct3_id = instr_id[14:12];
assign rs1_id    = instr_id[19:15];
assign rs2_id    = instr_id[24:20];
assign funct7_id = instr_id[31:25];

// ──────────────────────────────────────────────
// PC+4 ADDER
// ──────────────────────────────────────────────
assign pc_plus4 = pc_current + 32'd4;

// Next PC MUX — branch target or PC+4
assign pc_next = pc_src ? branch_target : pc_plus4;

// ──────────────────────────────────────────────
// FORWARDING MUX A — ALU input A (rs1)
// ──────────────────────────────────────────────
assign alu_input_a = (forward_a == 2'b10) ? alu_result_mem  :
                     (forward_a == 2'b01) ? write_data_wb   :
                                            read_data1_ex;

// ──────────────────────────────────────────────
// FORWARDING MUX B — ALU input B (rs2 before alu_src)
// ──────────────────────────────────────────────
assign alu_input_b_pre = (forward_b == 2'b10) ? alu_result_mem :
                         (forward_b == 2'b01) ? write_data_wb  :
                                                read_data2_ex;

// ALU SRC MUX — select between rs2 and immediate
assign alu_input_b = alu_src_ex ? imm_ex : alu_input_b_pre;

// ──────────────────────────────────────────────
// MODULE INSTANTIATIONS
// ──────────────────────────────────────────────

// 1. Program Counter
pc u_pc (
    .clk     (clk),
    .reset   (reset),
    .stall   (stall),
    .pc_next (pc_next),
    .pc      (pc_current)
);

// 2. Instruction Memory
instruction_memory u_imem (
    .addr        (pc_current),
    .instruction (instr_if)
);

// 3. IF/ID Pipeline Register
if_id_reg u_if_id (
    .clk      (clk),
    .reset    (reset),
    .stall    (stall),
    .flush    (flush),
    .pc_in    (pc_current),
    .instr_in (instr_if),
    .pc_out   (pc_id),
    .instr_out(instr_id)
);

// 4. Register File
register_file u_regfile (
    .clk        (clk),
    .reg_write  (reg_write_wb),
    .rs1        (rs1_id),
    .rs2        (rs2_id),
    .rd         (rd_wb),
    .write_data (write_data_wb),
    .read_data1 (read_data1_id),
    .read_data2 (read_data2_id)
);

// 5. Control Unit
control_unit u_ctrl (
    .opcode     (opcode_id),
    .reg_write  (reg_write_id),
    .alu_src    (alu_src_id),
    .mem_write  (mem_write_id),
    .mem_read   (mem_read_id),
    .mem_to_reg (mem_to_reg_id),
    .branch     (branch_id),
    .jump       (jump_id),
    .alu_op     (alu_op_id)
);

// 6. Immediate Generator
imm_gen u_immgen (
    .instruction (instr_id),
    .imm_out     (imm_id)
);

// 7. ID/EX Pipeline Register
id_ex_reg u_id_ex (
    .clk            (clk),
    .reset          (reset),
    .flush          (flush | id_ex_flush_haz),
    .pc_in          (pc_id),
    .read_data1_in  (read_data1_id),
    .read_data2_in  (read_data2_id),
    .imm_in         (imm_id),
    .rs1_in         (rs1_id),
    .rs2_in         (rs2_id),
    .rd_in          (rd_id),
    .reg_write_in   (reg_write_id),
    .alu_src_in     (alu_src_id),
    .mem_write_in   (mem_write_id),
    .mem_read_in    (mem_read_id),
    .mem_to_reg_in  (mem_to_reg_id),
    .branch_in      (branch_id),
    .jump_in        (jump_id),
    .alu_op_in      (alu_op_id),
    .funct3_in      (funct3_id),
    .funct7_in      (funct7_id),
    .pc_out         (pc_ex),
    .read_data1_out (read_data1_ex),
    .read_data2_out (read_data2_ex),
    .imm_out        (imm_ex),
    .rs1_out        (rs1_ex),
    .rs2_out        (rs2_ex),
    .rd_out         (rd_ex),
    .reg_write_out  (reg_write_ex),
    .alu_src_out    (alu_src_ex),
    .mem_write_out  (mem_write_ex),
    .mem_read_out   (mem_read_ex),
    .mem_to_reg_out (mem_to_reg_ex),
    .branch_out     (branch_ex),
    .jump_out       (jump_ex),
    .alu_op_out     (alu_op_ex),
    .funct3_out     (funct3_ex),
    .funct7_out     (funct7_ex)
);

// 8. ALU Control
alu_control u_aluctrl (
    .alu_op   (alu_op_ex),
    .funct3   (funct3_ex),
    .funct7   (funct7_ex),
    .alu_src  (alu_src_ex),
    .alu_ctrl (alu_ctrl)
);

// 9. ALU
alu u_alu (
    .a        (alu_input_a),
    .b        (alu_input_b),
    .alu_ctrl (alu_ctrl),
    .result   (alu_result_ex),
    .zero     (zero_ex)
);

// 10. Forwarding Unit
forwarding_unit u_fwd (
    .ex_rs1        (rs1_ex),
    .ex_rs2        (rs2_ex),
    .mem_rd        (rd_mem),
    .mem_reg_write (reg_write_mem),
    .wb_rd         (rd_wb),
    .wb_reg_write  (reg_write_wb),
    .forward_a     (forward_a),
    .forward_b     (forward_b)
);

// 11. Branch Unit
branch_unit u_branch (
    .branch        (branch_ex),
    .jump          (jump_ex),
    .zero          (zero_ex),
    .funct3        (funct3_ex),
    .pc            (pc_ex),
    .imm           (imm_ex),
    .alu_result    (alu_result_ex),
    .branch_target (branch_target),
    .pc_src        (pc_src),
    .flush         (flush)
);

// 12. EX/MEM Pipeline Register
ex_mem_reg u_ex_mem (
    .clk            (clk),
    .reset          (reset),
    .alu_result_in  (alu_result_ex),
    .write_data_in  (alu_input_b_pre),
    .rd_in          (rd_ex),
    .zero_in        (zero_ex),
    .mem_read_in    (mem_read_ex),
    .mem_write_in   (mem_write_ex),
    .mem_to_reg_in  (mem_to_reg_ex),
    .reg_write_in   (reg_write_ex),
    .alu_result_out (alu_result_mem),
    .write_data_out (write_data_mem),
    .rd_out         (rd_mem),
    .zero_out       (zero_mem),
    .mem_read_out   (mem_read_mem),
    .mem_write_out  (mem_write_mem),
    .mem_to_reg_out (mem_to_reg_mem),
    .reg_write_out  (reg_write_mem)
);

// 13. Data Memory
data_memory u_dmem (
    .clk        (clk),
    .mem_write  (mem_write_mem),
    .mem_read   (mem_read_mem),
    .address    (alu_result_mem),
    .write_data (write_data_mem),
    .read_data  (read_data_mem)
);

// 14. MEM/WB Pipeline Register
mem_wb_reg u_mem_wb (
    .clk            (clk),
    .reset          (reset),
    .alu_result_in  (alu_result_mem),
    .read_data_in   (read_data_mem),
    .rd_in          (rd_mem),
    .mem_to_reg_in  (mem_to_reg_mem),
    .reg_write_in   (reg_write_mem),
    .alu_result_out (alu_result_wb),
    .read_data_out  (read_data_wb),
    .rd_out         (rd_wb),
    .mem_to_reg_out (mem_to_reg_wb),
    .reg_write_out  (reg_write_wb)
);

// 15. WB MUX
wb_mux u_wbmux (
    .mem_to_reg (mem_to_reg_wb),
    .alu_result (alu_result_wb),
    .read_data  (read_data_wb),
    .write_data (write_data_wb)
);

// 16. Hazard Detection Unit
hazard_unit u_hazard (
    .id_ex_mem_read (mem_read_ex),
    .id_ex_rd       (rd_ex),
    .if_id_rs1      (rs1_id),
    .if_id_rs2      (rs2_id),
    .stall          (stall),
    .id_ex_flush    (id_ex_flush_haz)
);

endmodule