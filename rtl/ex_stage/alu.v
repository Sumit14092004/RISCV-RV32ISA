// ALU — Arithmetic Logic Unit
// Performs all arithmetic and logic operations
// Zero flag used for branch decisions

module alu (
    input  wire [31:0] a,           // operand A (rs1 or forwarded)
    input  wire [31:0] b,           // operand B (rs2, immediate, or forwarded)
    input  wire [3:0]  alu_ctrl,    // operation from ALU control
    output reg  [31:0] result,      // computation result
    output wire        zero         // 1 if result is zero
);

    // Zero flag — combinational
    assign zero = (result == 32'h00000000);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;                    // ADD
            4'b0001: result = a - b;                    // SUB
            4'b0010: result = a & b;                    // AND
            4'b0011: result = a | b;                    // OR
            4'b0100: result = a ^ b;                    // XOR
            4'b0101: result = ($signed(a) < $signed(b)) // SLT
                               ? 32'h1 : 32'h0;
            4'b0110: result = a << b[4:0];              // SLL
            4'b0111: result = a >> b[4:0];              // SRL
            4'b1000: result = $signed(a) >>> b[4:0];    // SRA
            4'b1001: result = b;                        // LUI (pass B through)
            default: result = 32'h00000000;
        endcase
    end

endmodule