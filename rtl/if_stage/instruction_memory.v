// Instruction Memory
// Read-only memory holding the program
// Combinational read — output available same cycle as address

module instruction_memory (
    input  wire [31:0] addr,
    output wire [31:0] instruction
);

    reg [31:0] mem [0:255];   // 256 x 32-bit words = 1KB of program space

    // Preload program from a file during simulation
    initial begin
        $readmemh("program.hex", mem);
    end

    // Word-aligned read — drop bottom 2 bits
    assign instruction = mem[addr[9:2]];

endmodule