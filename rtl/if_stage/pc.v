// Program Counter
// Holds address of current instruction
// Updates every clock cycle unless stalled

module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;
        else if (!stall)
            pc <= pc_next;
    end

endmodule