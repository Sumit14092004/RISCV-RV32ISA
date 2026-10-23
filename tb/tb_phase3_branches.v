// Testbench — Phase 3: Control Hazard & Branch Stress Test
`timescale 1ns/1ps

module tb_phase3_branches;

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
        $display("=== Phase 3: Control Hazard & Branch Stress Test Starting ===");

        // Wait enough cycles for loop to execute (5 iterations * ~4 cycles + initial code)
        repeat (60) @(posedge clk);

        $display("=== Phase 3 Results Check ===");
        
        // 3A: BEQ taken and pipeline flush verification
        if (dut.u_regfile.registers[3] === 32'd0 && dut.u_regfile.registers[4] === 32'd42)
            $display("✓ Test 3A PASS: BEQ Taken & Flush (x3 = %0d [expected 0], x4 = %0d [expected 42])",
                     dut.u_regfile.registers[3], dut.u_regfile.registers[4]);
        else begin
            $display("✗ Test 3A FAIL: BEQ Taken & Flush (x3 = %0d [expected 0], x4 = %0d [expected 42])",
                     dut.u_regfile.registers[3], dut.u_regfile.registers[4]);
            errors = errors + 1;
        end

        // 3B: BEQ not-taken fall-through
        if (dut.u_regfile.registers[7] === 32'd77 && dut.u_regfile.registers[8] === 32'd88)
            $display("✓ Test 3B PASS: BEQ Not Taken Fallthrough (x7 = %0d [expected 77], x8 = %0d [expected 88])",
                     dut.u_regfile.registers[7], dut.u_regfile.registers[8]);
        else begin
            $display("✗ Test 3B FAIL: BEQ Not Taken Fallthrough (x7 = %0d [expected 77], x8 = %0d [expected 88])",
                     dut.u_regfile.registers[7], dut.u_regfile.registers[8]);
            errors = errors + 1;
        end

        // 3C: BNE taken
        if (dut.u_regfile.registers[9] === 32'd0 && dut.u_regfile.registers[10] === 32'd100)
            $display("✓ Test 3C PASS: BNE Taken & Flush (x9 = %0d [expected 0], x10 = %0d [expected 100])",
                     dut.u_regfile.registers[9], dut.u_regfile.registers[10]);
        else begin
            $display("✗ Test 3C FAIL: BNE Taken & Flush (x9 = %0d [expected 0], x10 = %0d [expected 100])",
                     dut.u_regfile.registers[9], dut.u_regfile.registers[10]);
            errors = errors + 1;
        end

        // 3D: Backward Branch Loop
        if (dut.u_regfile.registers[11] === 32'd50 && dut.u_regfile.registers[12] === 32'd0)
            $display("✓ Test 3D PASS: Loop Execution (x11 = %0d [expected 50], x12 = %0d [expected 0])",
                     dut.u_regfile.registers[11], dut.u_regfile.registers[12]);
        else begin
            $display("✗ Test 3D FAIL: Loop Execution (x11 = %0d [expected 50], x12 = %0d [expected 0])",
                     dut.u_regfile.registers[11], dut.u_regfile.registers[12]);
            errors = errors + 1;
        end

        $display("");
        if (errors == 0)
            $display("🎉 ALL PHASE 3 TESTS PASSED PERFECTLY!");
        else
            $display("❌ PHASE 3 FAILED WITH %0d ERRORS", errors);

        $finish;
    end

endmodule
