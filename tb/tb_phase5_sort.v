// Testbench — Phase 5: Array Sorting Algorithm Verification
`timescale 1ns/1ps

module tb_phase5_sort;

    reg clk;
    reg reset;

    riscv_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        $display("=== Sorting Algorithm Test Starting ===");

        // Wait for 49 instructions + stall/branch margins ~ 100 cycles
        repeat (120) @(posedge clk);

        $display("=== Sorting Algorithm Results Check ===");
        
        // Check sorted elements in data memory: [2, 7, 10, 25]
        if (dut.u_dmem.mem[0] === 32'd2 &&
            dut.u_dmem.mem[1] === 32'd7 &&
            dut.u_dmem.mem[2] === 32'd10 &&
            dut.u_dmem.mem[3] === 32'd25)
        begin
            $display("✓ Memory array correctly sorted: mem[0..3] = [%0d, %0d, %0d, %0d]",
                     dut.u_dmem.mem[0], dut.u_dmem.mem[1], dut.u_dmem.mem[2], dut.u_dmem.mem[3]);
        end else begin
            $display("✗ Memory array sorting FAILED: mem[0..3] = [%0d, %0d, %0d, %0d] (expected [2, 7, 10, 25])",
                     dut.u_dmem.mem[0], dut.u_dmem.mem[1], dut.u_dmem.mem[2], dut.u_dmem.mem[3]);
            errors = errors + 1;
        end

        // Check loaded registers: x10=2, x11=7, x12=10, x13=25
        if (dut.u_regfile.registers[10] === 32'd2 &&
            dut.u_regfile.registers[11] === 32'd7 &&
            dut.u_regfile.registers[12] === 32'd10 &&
            dut.u_regfile.registers[13] === 32'd25)
        begin
            $display("✓ Registers loaded correctly: x10=%0d, x11=%0d, x12=%0d, x13=%0d",
                     dut.u_regfile.registers[10], dut.u_regfile.registers[11],
                     dut.u_regfile.registers[12], dut.u_regfile.registers[13]);
        end else begin
            $display("✗ Register values mismatch: x10=%0d, x11=%0d, x12=%0d, x13=%0d",
                     dut.u_regfile.registers[10], dut.u_regfile.registers[11],
                     dut.u_regfile.registers[12], dut.u_regfile.registers[13]);
            errors = errors + 1;
        end

        $display("");
        if (errors == 0)
            $display("🎉 ALL SORTING TESTS PASSED PERFECTLY!");
        else
            $display("❌ SORTING TEST FAILED WITH %0d ERRORS", errors);

        $finish;
    end

endmodule
