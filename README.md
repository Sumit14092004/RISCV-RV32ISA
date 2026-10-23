# RISC-V RV32I 5-Stage Pipelined Processor

[![RISC-V](https://img.shields.io/badge/ISA-RISC--V%20RV32I-blue.svg)](https://riscv.org/)
[![HDL](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-brightgreen.svg)](#)
[![Simulation](https://img.shields.io/badge/Simulators-Vivado%20xsim%20%7C%20Icarus%20Verilog-orange.svg)](#)
[![Verification](https://img.shields.io/badge/Test%20Status-ALL%20TESTS%20PASSED-success.svg)](#)
[![Synthesis](https://img.shields.io/badge/FPGA-Xilinx%20Artix--7%20(XC7A35T)-purple.svg)](#)

A complete, fully verified 5-stage pipelined processor core implementing the 32-bit RISC-V (RV32I) Base Integer Instruction Set with full hardware hazard handling, forwarding unit, branch resolution, and SystemVerilog assertions.

**Author:** Sumit Pandey | RRU ECE | 2026

---

## Architecture Overview

![RISC-V 5-Stage Pipeline Architecture Schematic](docs/riscv_5stage_pipeline_schematic.svg)

> **Interactive Viewer:** Open [`docs/schematic_viewer.html`](docs/schematic_viewer.html) in any browser for full-screen pan and zoom.  
> **Transistor-Level SPICE Models:** See [`docs/riscv_6t_sram_cell.asc`](docs/riscv_6t_sram_cell.asc) (6T SRAM memory bit-cell for LTspice) and [`docs/riscv_alu_full_adder.cir`](docs/riscv_alu_full_adder.cir) (1-bit CMOS ALU adder slice).

The core follows the classic 5-stage RISC-V pipelined datapath:
1. **IF (Instruction Fetch):** Program Counter (`pc.v`) and Instruction Memory (`instruction_memory.v`).
2. **ID (Instruction Decode):** Control Unit (`control_unit.v`), Register File (`register_file.v`) with write-through bypass, and Immediate Generator (`imm_gen.v`).
3. **EX (Execute):** ALU (`alu.v`), ALU Control (`alu_control.v`), Forwarding Unit (`forwarding_unit.v`), and Branch Unit (`branch_unit.v`).
4. **MEM (Memory Access):** Data Memory (`data_memory.v`) with synchronous writes and combinational reads.
5. **WB (Write Back):** Write-Back Multiplexer (`wb_mux.v`) selecting between ALU results and loaded memory data.

```
       +----+        +----+        +----+        +----+        +----+
       | IF | =====> | ID | =====> | EX | =====> | MEM| =====> | WB |
       +----+        +----+        +----+        +----+        +----+
         |             |             ^             ^             |
         |             |             |             |             |
         |             |             +--- FWD A ---+-------------+
         |             |             +--- FWD B ---+-------------+
         |             +------------- RegFile WB Bypass <--------+
         +<-------------------------- Branch Flush --------------+
```

---

## 17 RTL Modules Breakdown

| # | Module | Stage | Description |
|---|---|---|---|
| 1 | `pc.v` | IF | Program Counter with synchronous stall freeze |
| 2 | `instruction_memory.v` | IF | 1KB (256 x 32-bit words) combinational read memory |
| 3 | `if_id_reg.v` | IF→ID | Pipeline register supporting stall and synchronous flush |
| 4 | `register_file.v` | ID | 32 x 32-bit register file with internal WB-to-ID bypass; x0 = 0 |
| 5 | `control_unit.v` | ID | Main instruction decoder for 7 RISC-V opcode classes |
| 6 | `imm_gen.v` | ID | Sign-extended immediate generator (I, S, B, U, J types) |
| 7 | `id_ex_reg.v` | ID→EX | Latches operands, registers, and execution control signals |
| 8 | `alu_control.v` | EX | Second-level decode with opcode gating (`alu_src`) for `ADDI` vs `SUB` |
| 9 | `alu.v` | EX | 10 arithmetic & logic operations with zero flag |
| 10 | `forwarding_unit.v` | EX | Hardware forwarding unit (EX-to-EX and MEM-to-EX paths) |
| 11 | `branch_unit.v` | EX | Evaluates branch conditions (`BEQ`, `BNE`, etc.) and generates flush |
| 12 | `ex_mem_reg.v` | EX→MEM | Carries ALU results and memory control to MEM stage |
| 13 | `data_memory.v` | MEM | 1KB (256 x 32-bit words) synchronous write, combinational read |
| 14 | `mem_wb_reg.v` | MEM→WB | Passes memory load data and ALU results to WB stage |
| 15 | `wb_mux.v` | WB | Selects memory data (`LW`) or ALU result for register writeback |
| 16 | `hazard_unit.v` | Global | Detects load-use hazards; stalls PC & IF/ID, flushes ID/EX |
| 17 | `riscv_pipeline.v` | Top | Top-level integration of all 16 submodules |

---

## Hazard Handling & Pipeline Control

### 1. RAW Data Hazards (Arithmetic Forwarding)
- **EX-to-EX Path (`forward = 2'b10`):** Forwards result from EX/MEM register to EX ALU inputs (distance = 1).
- **MEM-to-EX Path (`forward = 2'b01`):** Forwards result from MEM/WB register to EX ALU inputs (distance = 2).
- **WB-to-ID Path (Internal Bypass):** When an instruction in WB writes to a register that the instruction in ID is reading (distance = 3), `register_file.v` combinatorially bypasses the write data directly to the read output:
  ```verilog
  assign read_data1 = (rs1 == 5'b00000) ? 32'h00000000 :
                      (reg_write && (rd == rs1)) ? write_data : registers[rs1];
  ```

### 2. Load-Use Data Hazard (Hardware Stall)
When an instruction in EX is a Load (`LW`) and its destination matches `rs1` or `rs2` of the instruction in ID:
- PC is frozen (`stall = 1`).
- IF/ID register is frozen (`stall = 1`).
- ID/EX register receives a bubble (`id_ex_flush = 1`).
- On the subsequent cycle, the loaded data is forwarded from the WB stage into EX.

### 3. Control Hazards (Branch Penalty & Flush)
- Branches are resolved in the **EX stage**.
- When taken (`pc_src = 1`), `flush` clears both `if_id_reg` and `id_ex_reg` to NOP bubbles.
- Branch penalty = **2 clock cycles**.

---

## Verification Suite

The processor is verified through 5 rigorous testing phases:

### Phase 1: Baseline Integration & Sanity Check
- **Program:** [`tb/program.hex`](tb/program.hex)
- **Features Tested:** Register writes, basic arithmetic, memory store (`SW`), memory load (`LW`), forwarding, and WB hazard bypass.
- **Outcome:** `✓ ALL TESTS PASSED` (Verified in both Icarus Verilog and Vivado XSim).

### Phase 2: Directed Data Hazard & Forwarding Stress Test
- **Testbench:** [`tb/tb_phase2_hazards.v`](tb/tb_phase2_hazards.v)
- **Features Tested:** EX-EX forwarding, MEM-EX forwarding, WB-ID bypass, back-to-back dependency chains, load-use stall verification, store data forwarding.
- **Outcome:** `🎉 ALL PHASE 2 TESTS PASSED PERFECTLY!`.

### Phase 3: Control Hazard & Branch Stress Test
- **Testbench:** [`tb/tb_phase3_branches.v`](tb/tb_phase3_branches.v)
- **Features Tested:** `BEQ` taken (with flush verification), `BEQ` not taken (fallthrough), `BNE` taken, backward branch loop execution across multiple iterations.
- **Outcome:** `🎉 ALL PHASE 3 TESTS PASSED PERFECTLY!`.

### Phase 4: Complex Algorithm — Fibonacci Sequence Generator
- **Testbench:** [`tb/tb_phase4_fibonacci.v`](tb/tb_phase4_fibonacci.v)
- **Algorithm:** Computes the first 10 Fibonacci numbers ($0, 1, 1, 2, 3, 5, 8, 13, 21, 34$) in an iterative loop, dynamically writes them to `mem[0..9]`, and loads them back into registers `x10..x19`.
- **Outcome:** `🎉 ALL PHASE 4 FIBONACCI TESTS PASSED PERFECTLY!`.

### Phase 5: Complex Algorithm — Array Sorting (Bubble Sort)
- **Testbench:** [`tb/tb_phase5_sort.v`](tb/tb_phase5_sort.v)
- **Algorithm:** Sorts an array `[25, 10, 7, 2]` in memory into `[2, 7, 10, 25]` using conditional swapping, loads, stores, and branches.
- **Outcome:** `🎉 ALL SORTING TESTS PASSED PERFECTLY!`.

### Formal Verification: SystemVerilog Assertions (SVA)
- **Testbench:** [`tb/tb_riscv_pipeline_sva.sv`](tb/tb_riscv_pipeline_sva.sv)
- Continuously verifies pipeline properties on every clock edge:
  - `x0` is unconditionally constant zero (`assert (registers[0] == 0)`).
  - PC and IF/ID instruction remain frozen during stalls.
  - Flush correctly clears execution control signals to NOP.
  - Load-use hazards unconditionally trigger stall and flush.
  - EX-EX forwarding takes strict priority over MEM-EX forwarding.
- **Outcome:** `=== SVA Verification Completed with 0 Violations! ===`.

---

## Quick Start & Simulation Guide

### Option 1: Ultra-Fast Local Simulation (macOS / Linux)
Requires `iverilog` (v12) and `vvp`:
```bash
# Compile and run baseline testbench
iverilog -g2012 -o sim.out tb/tb_riscv_pipeline.v rtl/*.v rtl/*/*.v && vvp sim.out

# Run SVA Assertions
iverilog -g2012 -o sim_sva.out tb/tb_riscv_pipeline_sva.sv rtl/*.v rtl/*/*.v && vvp sim_sva.out

# Run Fibonacci sequence test
cp tb/program_fibonacci.hex program.hex
iverilog -g2012 -o sim_fib.out tb/tb_phase4_fibonacci.v rtl/*.v rtl/*/*.v && vvp sim_fib.out
```

### Option 2: Vivado Simulator (xsim) via Docker Container
```bash
# Start Docker environment
cd ../scripts && ./start_container.sh

# Inside Vivado xsim directory:
cd /home/user/riscv_pipeline/riscv_pipeline.sim/sim_1/behav/xsim
./compile.sh
./elaborate.sh
./simulate.sh
```

---

## FPGA Synthesis Results

- **Target FPGA:** Xilinx Artix-7 `xc7a35tcpg236-1` (Basys 3 / Cmod A7)
- **Synthesis Tool:** AMD Xilinx Vivado 2022.2
- **Checkpoint Generated:** `riscv_pipeline.dcp`
- **Errors:** **0 Errors, 0 Critical Warnings**

---

## Repository Structure

```
riscv_pipeline/
├── rtl/
│   ├── if_stage/          # PC, Instruction Memory
│   ├── id_stage/          # Register File, Control Unit, Imm Gen
│   ├── ex_stage/          # ALU, ALU Control, Forwarding Unit, Branch Unit
│   ├── mem_stage/         # Data Memory
│   ├── wb_stage/          # Writeback Mux
│   ├── pipeline_regs/     # IF/ID, ID/EX, EX/MEM, MEM/WB Registers
│   ├── hazard_unit.v      # Hazard Detection & Stall Generator
│   └── riscv_pipeline.v   # Top-level integration
├── tb/
│   ├── asm.py             # Custom RISC-V RV32I two-pass assembler
│   ├── program.hex        # Baseline sum program
│   ├── program_phase2.hex # Forwarding stress program
│   ├── program_phase3.hex # Branch control program
│   ├── program_fibonacci.hex # Fibonacci sequence program
│   ├── program_sort.hex   # Array bubble sort program
│   ├── tb_riscv_pipeline.v      # Baseline testbench
│   ├── tb_phase2_hazards.v      # Hazard testbench
│   ├── tb_phase3_branches.v     # Branch testbench
│   ├── tb_phase4_fibonacci.v    # Fibonacci testbench
│   ├── tb_phase5_sort.v         # Bubble sort testbench
│   └── tb_riscv_pipeline_sva.sv # Formal SVA assertions testbench
├── docs/                  # Technical project reports & demo scripts
└── riscv_pipeline.xpr     # Vivado 2022.2 Project File
```

---

## License

Academic and educational use. RRU ECE 2026.
