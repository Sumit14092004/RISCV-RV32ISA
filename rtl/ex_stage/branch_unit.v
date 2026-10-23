// Branch Unit
// Determines if branch is taken and computes target address
// Handles BEQ, BNE, BLT, BGE, BLTU, BGEU and JAL

module branch_unit (
    input  wire        branch,          // control signal — is this a branch?
    input  wire        jump,            // control signal — is this JAL?
    input  wire        zero,            // from ALU — rs1 == rs2 if 1
    input  wire [2:0]  funct3,          // branch type selector
    input  wire [31:0] pc,              // PC of branch instruction
    input  wire [31:0] imm,             // sign-extended immediate
    input  wire [31:0] alu_result,      // ALU result (for signed/unsigned compare)
    output wire [31:0] branch_target,   // computed target address = PC + imm
    output reg         pc_src,          // 1 = branch/jump taken
    output wire        flush            // 1 = flush pipeline
);

    // Branch target is always PC + immediate
    assign branch_target = pc + imm;

    // Flush whenever branch or jump is taken
    assign flush = pc_src;

    always @(*) begin
        pc_src = 0;   // default — not taken

        if (jump) begin
            // JAL always taken
            pc_src = 1;
        end
        else if (branch) begin
            case (funct3)
                3'b000: pc_src = zero;          // BEQ — taken if rs1 == rs2
                3'b001: pc_src = ~zero;         // BNE — taken if rs1 != rs2
                3'b100: pc_src = alu_result[31];// BLT — taken if negative (signed)
                3'b101: pc_src = ~alu_result[31]// BGE — taken if positive (signed)
                                 | zero;
                3'b110: pc_src = alu_result[31];// BLTU — borrow bit for unsigned
                3'b111: pc_src = ~alu_result[31]// BGEU — unsigned >=
                                 | zero;
                default: pc_src = 0;
            endcase
        end
    end

endmodule