// Data Memory
// Stores program data — variables, arrays, stack
// Synchronous write (SW), combinational read (LW)
// Only accessed in MEM stage

module data_memory (
    input  wire        clk,
    input  wire        mem_write,       // 1 = SW instruction
    input  wire        mem_read,        // 1 = LW instruction
    input  wire [31:0] address,         // from ALU result (base + offset)
    input  wire [31:0] write_data,      // rs2 value — data to store
    output reg  [31:0] read_data        // data read from memory (for LW)
);

    reg [31:0] mem [0:255];             // 256 x 32-bit words = 1KB data space

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000000;      // initialize all to 0
    end

    // Synchronous write — on rising clock edge
    always @(posedge clk) begin
        if (mem_write)
            mem[address[9:2]] <= write_data;
    end

    // Combinational read — immediate output
    always @(*) begin
        if (mem_read)
            read_data = mem[address[9:2]];
        else
            read_data = 32'h00000000;
    end

endmodule