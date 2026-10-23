// Register File
// 32 x 32-bit registers (x0 to x31)
// Synchronous write, combinational read
// x0 is hardwired to zero
module register_file (
    input  wire        clk,
    input  wire        reg_write,       // write enable from WB stage
    input  wire [4:0]  rs1,             // source register 1 address
    input  wire [4:0]  rs2,             // source register 2 address
    input  wire [4:0]  rd,              // destination register address
    input  wire [31:0] write_data,      // data to write into rd
    output wire [31:0] read_data1,      // value of rs1
    output wire [31:0] read_data2       // value of rs2
);

    reg [31:0] registers [0:31];        // 32 registers x 32 bits

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'h00000000; // initialize all to 0
    end

    // Synchronous write — on rising clock edge
    always @(posedge clk) begin
        if (reg_write && rd != 5'b00000)  // never write to x0
            registers[rd] <= write_data;
    end

    // Combinational read with internal write-through bypass (resolves WB-to-ID RAW hazard)
    assign read_data1 = (rs1 == 5'b00000) ? 32'h00000000 :
                        (reg_write && (rd == rs1)) ? write_data :
                        registers[rs1];
    assign read_data2 = (rs2 == 5'b00000) ? 32'h00000000 :
                        (reg_write && (rd == rs2)) ? write_data :
                        registers[rs2];

endmodule