// Testbench — Phase 4: Fibonacci Sequence Algorithm Verification
`timescale 1ns/1ps

module tb_phase4_fibonacci;

    reg clk;
    reg reset;

    riscv_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer i;

    // Expected Fibonacci sequence: F(0) to F(9)
    integer expected_fib [0:9];
    initial begin
        expected_fib[0] = 0;
        expected_fib[1] = 1;
        expected_fib[2] = 1;
        expected_fib[3] = 2;
        expected_fib[4] = 3;
        expected_fib[5] = 5;
        expected_fib[6] = 8;
        expected_fib[7] = 13;
        expected_fib[8] = 21;
        expected_fib[9] = 34;
    end

    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        $display("=== Phase 4: Fibonacci Sequence Test Starting ===");

        // Wait for loop and readback to complete: 8 iterations * ~7 cycles + startup/cleanup ~ 100 cycles
        repeat (120) @(posedge clk);

        $display("=== Phase 4 Results: Checking Data Memory ===");
        for (i = 0; i < 10; i = i + 1) begin
            if (dut.u_dmem.mem[i] === expected_fib[i]) begin
                $display("✓ F(%0d) in mem[%0d] = %0d (expected %0d)",
                         i, i, dut.u_dmem.mem[i], expected_fib[i]);
            end else begin
                $display("✗ F(%0d) in mem[%0d] = %0d (expected %0d)",
                         i, i, dut.u_dmem.mem[i], expected_fib[i]);
                errors = errors + 1;
            end
        end

        $display("");
        $display("=== Phase 4 Results: Checking Loaded Registers (x10 to x19) ===");
        for (i = 0; i < 10; i = i + 1) begin
            if (dut.u_regfile.registers[10 + i] === expected_fib[i]) begin
                $display("✓ Register x%0d = %0d (expected %0d)",
                         10 + i, dut.u_regfile.registers[10 + i], expected_fib[i]);
            end else begin
                $display("✗ Register x%0d = %0d (expected %0d)",
                         10 + i, dut.u_regfile.registers[10 + i], expected_fib[i]);
                errors = errors + 1;
            end
        end

        $display("");
        if (errors == 0)
            $display("🎉 ALL PHASE 4 FIBONACCI TESTS PASSED PERFECTLY!");
        else
            $display("❌ PHASE 4 FAILED WITH %0d ERRORS", errors);

        $finish;
    end

endmodule
