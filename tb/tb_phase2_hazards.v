// Testbench — Phase 2: Data Hazard & Forwarding Stress Test
`timescale 1ns/1ps

module tb_phase2_hazards;

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
        $display("=== Phase 2: Data Hazard & Forwarding Stress Test Starting ===");

        // Wait for all 20 instructions to finish through pipeline
        repeat (35) @(posedge clk);

        $display("=== Phase 2 Results Check ===");
        
        // 2A: EX-to-EX Forwarding
        if (dut.u_regfile.registers[2] === 32'd20)
            $display("✓ Test 2A PASS: EX-to-EX Forwarding (x2 = %0d, expected 20)", dut.u_regfile.registers[2]);
        else begin
            $display("✗ Test 2A FAIL: EX-to-EX Forwarding (x2 = %0d, expected 20)", dut.u_regfile.registers[2]);
            errors = errors + 1;
        end

        // 2B: MEM-to-EX Forwarding
        if (dut.u_regfile.registers[5] === 32'd15)
            $display("✓ Test 2B PASS: MEM-to-EX Forwarding (x5 = %0d, expected 15)", dut.u_regfile.registers[5]);
        else begin
            $display("✗ Test 2B FAIL: MEM-to-EX Forwarding (x5 = %0d, expected 15)", dut.u_regfile.registers[5]);
            errors = errors + 1;
        end

        // 2C: WB-to-ID RAW Hazard Bypass
        if (dut.u_regfile.registers[9] === 32'd14)
            $display("✓ Test 2C PASS: WB-to-ID RegFile Bypass (x9 = %0d, expected 14)", dut.u_regfile.registers[9]);
        else begin
            $display("✗ Test 2C FAIL: WB-to-ID RegFile Bypass (x9 = %0d, expected 14)", dut.u_regfile.registers[9]);
            errors = errors + 1;
        end

        // 2D: Back-to-Back Dependency Chain
        if (dut.u_regfile.registers[10] === 32'd15)
            $display("✓ Test 2D PASS: Back-to-back Dependency Chain (x10 = %0d, expected 15)", dut.u_regfile.registers[10]);
        else begin
            $display("✗ Test 2D FAIL: Back-to-back Dependency Chain (x10 = %0d, expected 15)", dut.u_regfile.registers[10]);
            errors = errors + 1;
        end

        // 2E: Load-Use Hazard Stall
        if (dut.u_regfile.registers[11] === 32'd15 && dut.u_regfile.registers[12] === 32'd20)
            $display("✓ Test 2E PASS: Load-Use Hazard Stall & Forward (x11=%0d, x12=%0d, expected 15, 20)",
                     dut.u_regfile.registers[11], dut.u_regfile.registers[12]);
        else begin
            $display("✗ Test 2E FAIL: Load-Use Hazard (x11=%0d, x12=%0d, expected 15, 20)",
                     dut.u_regfile.registers[11], dut.u_regfile.registers[12]);
            errors = errors + 1;
        end

        // 2F: Store Data Forwarding
        if (dut.u_regfile.registers[14] === 32'd99 && dut.u_dmem.mem[2] === 32'd99)
            $display("✓ Test 2F PASS: Store Data Forwarding (x14 = %0d, mem[2] = %0d, expected 99)",
                     dut.u_regfile.registers[14], dut.u_dmem.mem[2]);
        else begin
            $display("✗ Test 2F FAIL: Store Data Forwarding (x14 = %0d, mem[2] = %0d, expected 99)",
                     dut.u_regfile.registers[14], dut.u_dmem.mem[2]);
            errors = errors + 1;
        end

        $display("");
        if (errors == 0)
            $display("🎉 ALL PHASE 2 TESTS PASSED PERFECTLY!");
        else
            $display("❌ PHASE 2 FAILED WITH %0d ERRORS", errors);

        $finish;
    end

endmodule
