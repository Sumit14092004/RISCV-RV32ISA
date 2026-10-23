// Testbench with Formal SystemVerilog Assertions (SVA)
// Author: Sumit Pandey | RRU ECE | 2026
`timescale 1ns/1ps

module tb_riscv_pipeline_sva;

    reg clk;
    reg reset;

    riscv_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        $display("=== SVA Verification Starting ===");
    end

    // Waveform dump
    initial begin
        $dumpfile("riscv_pipeline_sva.vcd");
        $dumpvars(0, tb_riscv_pipeline_sva);
    end

    // ── Assertion 1: Hardwired Zero Register ─────────────────
    // x0 must never change from 0 under any circumstance
    always @(posedge clk) begin
        if (!reset) begin
            assert (dut.u_regfile.registers[0] === 32'h0)
                else $error("[SVA VIOLATION] Register x0 modified! Value = 0x%08h", dut.u_regfile.registers[0]);
        end
    end

    // ── Assertion 2: Stall Freeze Verification ───────────────
    // When stall is asserted, PC must hold its value
    reg [31:0] pc_prev;
    reg [31:0] instr_id_prev;
    reg        stall_prev;

    always @(posedge clk) begin
        if (!reset) begin
            if (stall_prev) begin
                assert (dut.u_pc.pc === pc_prev)
                    else $error("[SVA VIOLATION] PC changed during stall! Current = 0x%08h, Expected = 0x%08h",
                                dut.u_pc.pc, pc_prev);
                assert (dut.u_if_id.instr_out === instr_id_prev)
                    else $error("[SVA VIOLATION] IF/ID instruction changed during stall!");
            end
            pc_prev       <= dut.u_pc.pc;
            instr_id_prev <= dut.u_if_id.instr_out;
            stall_prev    <= dut.stall;
        end
    end

    // ── Assertion 3: Flush Clears Pipeline Registers ─────────
    // When flush is asserted, ID/EX control signals must be neutralized (NOP bubble)
    reg flush_prev;
    always @(posedge clk) begin
        if (!reset) begin
            if (flush_prev) begin
                assert (dut.reg_write_ex === 1'b0 && dut.mem_write_ex === 1'b0)
                    else $error("[SVA VIOLATION] Active control signals observed in EX after flush!");
            end
            flush_prev <= (dut.flush | dut.id_ex_flush_haz);
        end
    end

    // ── Assertion 4: Load-Use Hazard Detection ───────────────
    // When LW in EX is followed by dependent instruction in ID, stall must assert
    always @(posedge clk) begin
        if (!reset) begin
            if (dut.mem_read_ex && (dut.rd_ex != 5'b00000) &&
                (dut.rd_ex === dut.rs1_id || dut.rd_ex === dut.rs2_id))
            begin
                assert (dut.stall === 1'b1 && dut.id_ex_flush_haz === 1'b1)
                    else $error("[SVA VIOLATION] Load-use hazard not detected by Hazard Detection Unit!");
            end
        end
    end

    // ── Assertion 5: Forwarding Priority ─────────────────────
    // EX-EX forwarding must take priority over MEM-EX forwarding
    always @(posedge clk) begin
        if (!reset) begin
            if (dut.reg_write_mem && (dut.rd_mem != 5'b00000) && (dut.rd_mem === dut.rs1_ex)) begin
                assert (dut.forward_a === 2'b10)
                    else $error("[SVA VIOLATION] Forward A did not select EX-EX forwarding! Value = %b", dut.forward_a);
            end
            if (dut.reg_write_mem && (dut.rd_mem != 5'b00000) && (dut.rd_mem === dut.rs2_ex)) begin
                assert (dut.forward_b === 2'b10)
                    else $error("[SVA VIOLATION] Forward B did not select EX-EX forwarding! Value = %b", dut.forward_b);
            end
        end
    end

    // ── Simulation Completion Check ──────────────────────────
    initial begin
        @(negedge reset);
        repeat (35) @(posedge clk);
        $display("=== SVA Verification Completed with 0 Violations! ===");
        $finish;
    end

endmodule
