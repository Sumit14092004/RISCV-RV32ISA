// Testbench — RISC-V RV32I Pipelined Processor
// Runs a sum program and verifies register and memory results
// Author: Sumit Pandey | RRU ECE | 2026

`timescale 1ns/1ps

module tb_riscv_pipeline;

    // ── Clock and Reset ──────────────────────────────
    reg clk;
    reg reset;

    // ── DUT instantiation ────────────────────────────
    riscv_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // ── Clock generation — 10ns period (100 MHz) ────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Reset sequence ───────────────────────────────
    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        $display("=== Reset released — simulation starting ===");
    end

    // ── Waveform dump ────────────────────────────────
    initial begin
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, tb_riscv_pipeline);
    end

    // ── Main test sequence ───────────────────────────
    integer i;
    initial begin
        // Wait for reset
        @(negedge reset);

        // Wait enough cycles for all instructions to complete
        // 12 instructions + 5 pipeline stages + stall margin = 25 cycles
        repeat (30) @(posedge clk);

        $display("=== Simulation Complete — Checking Results ===");
        $display("");

        // ── Check register file values ──
        $display("--- Register File ---");
        $display("x1  = %0d (expected 1)",  dut.u_regfile.registers[1]);
        $display("x2  = %0d (expected 2)",  dut.u_regfile.registers[2]);
        $display("x3  = %0d (expected 3)",  dut.u_regfile.registers[3]);
        $display("x4  = %0d (expected 6)",  dut.u_regfile.registers[4]);
        $display("x5  = %0d (expected 15)", dut.u_regfile.registers[5]);
        $display("x6  = %0d (expected 5)",  dut.u_regfile.registers[6]);
        $display("x7  = %0d (expected 15)", dut.u_regfile.registers[7]);
        $display("");

        // ── Check data memory ──
        $display("--- Data Memory ---");
        $display("mem[0] = %0d (expected 15)", dut.u_dmem.mem[0]);
        $display("");

        // ── Pass/Fail ──
        if (dut.u_regfile.registers[5] == 32'd15 &&
            dut.u_regfile.registers[7] == 32'd15 &&
            dut.u_dmem.mem[0]          == 32'd15)
        begin
            $display("✓ ALL TESTS PASSED — Processor working correctly!");
        end
        else begin
            $display("✗ TEST FAILED — Check waveforms for errors");
        end

        $display("");
        $display("=== End of Simulation ===");
        $finish;
    end

    // ── Cycle monitor — prints PC every cycle ────────
    always @(posedge clk) begin
        if (!reset)
            $display("Cycle %0t | PC = 0x%08h | Instr = 0x%08h",
                     $time,
                     dut.u_pc.pc,
                     dut.u_imem.instruction);
    end

endmodule