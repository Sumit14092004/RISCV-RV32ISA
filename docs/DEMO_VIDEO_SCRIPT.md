# RISC-V RV32I 5-Stage Pipelined Processor: Demo Video Walkthrough Script
**Author:** Sumit Pandey | RRU ECE | 2026  
**Target Duration:** 5 to 7 Minutes  
**Recommended Recording Tools:** OBS Studio / Loom / QuickTime Screen Recording  

---

## Recording Checklist Before Starting
- [ ] VS Code open with `riscv_pipeline/` folder visible in sidebar
- [ ] Terminal open at `/Volumes/SSD/vivado-on-silicon-mac-main/riscv_pipeline`
- [ ] Vivado VNC or xsim terminal ready
- [ ] Microphone tested and clear

---

## Segment 1: Introduction & Project Scope (0:00 – 1:00)

### What to Show on Screen:
Show the project `README.md` or the title slide showing:
*"RISC-V RV32I 5-Stage Pipelined Processor — Sumit Pandey, RRU ECE 2026"*

### Spoken Script:
> "Hello everyone, my name is Sumit Pandey from the Electronics and Communication Engineering department at Rashtriya Raksha University.
> 
> Today, I am excited to demonstrate my implementation of a 32-bit RISC-V RV32I 5-stage pipelined processor in Verilog.
> 
> The processor implements the standard five pipeline stages: Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write-Back. 
> 
> In this video, I will walk you through the architecture, explain how we resolve data and control hazards through hardware forwarding, stalls, and flushes, demonstrate our cycle-accurate verification suite across multiple algorithms including Fibonacci and Bubble Sort, and show the synthesis results on a Xilinx Artix-7 FPGA."

---

## Segment 2: RTL Architecture & 17 Modules Walkthrough (1:00 – 2:30)

### What to Show on Screen:
In VS Code, expand the `rtl/` directory tree, showing:
- `rtl/if_stage/`
- `rtl/id_stage/`
- `rtl/ex_stage/`
- `rtl/mem_stage/`
- `rtl/wb_stage/`
- `rtl/pipeline_regs/`
- `rtl/hazard_unit.v`
- `rtl/riscv_pipeline.v`

Open `riscv_pipeline.v` and scroll through the clean top-level instantiations.

### Spoken Script:
> "Let's first take a look at the RTL structure in VS Code. The core consists of 17 modular Verilog units organized cleanly by stage:
> 
> 1. In the **IF stage**, we have our Program Counter `pc.v` and a 1-Kilobyte Instruction Memory `instruction_memory.v`.
> 2. Between stages, we have pipeline registers: `if_id_reg.v`, `id_ex_reg.v`, `ex_mem_reg.v`, and `mem_wb_reg.v`.
> 3. In the **ID stage**, we have our Control Unit `control_unit.v`, our Immediate Generator `imm_gen.v` supporting all five RISC-V formats, and our 32-word Register File `register_file.v` where register x0 is strictly hardwired to zero.
> 4. In the **EX stage**, we have a 10-operation Arithmetic Logic Unit `alu.v`, our ALU Control unit `alu_control.v`, our Forwarding Unit `forwarding_unit.v`, and our Branch Unit `branch_unit.v`.
> 5. In the **MEM stage**, we have our 1-Kilobyte synchronous Data Memory `data_memory.v`.
> 6. And in the **WB stage**, we have our Write-Back Multiplexer `wb_mux.v` selecting whether memory load data or ALU results get written back to the register file.
> 
> All of these are connected together in our top-level module, `riscv_pipeline.v`."

---

## Segment 3: Deep Dive into Hazard Handling (2:30 – 4:00)

### What to Show on Screen:
Open `rtl/ex_stage/forwarding_unit.v`, then `rtl/id_stage/register_file.v`, then `rtl/hazard_unit.v`.

### Spoken Script:
> "Now let's examine the most critical part of pipelining: **Hazard Resolution**.
> 
> For **RAW Data Hazards**, our `forwarding_unit.v` checks for dependencies combinationally:
> - If an instruction in the EX stage depends on the immediately preceding instruction in the MEM stage, we activate the **EX-to-EX forwarding path** (`forward = 2'b10`).
> - If it depends on an instruction in the WB stage, we activate the **MEM-to-EX forwarding path** (`forward = 2'b01`).
> - Notice that EX-to-EX takes priority over MEM-to-EX because the MEM stage instruction is newer in program order.
> 
> Next, look at `register_file.v`. Here we implemented an **internal write-through bypass**:
> When an instruction in WB writes to a register at the clock edge, an instruction in ID reading that same register simultaneously gets the new value bypassed combinationally. This completely eliminates distance-3 RAW hazards.
> 
> For **Load-Use Hazards**, where an instruction immediately uses data from a Load Word (`LW`), data cannot be forwarded backwards in time. Our `hazard_unit.v` detects this condition, freezing the PC and IF/ID registers for one clock cycle and inserting a NOP bubble into `id_ex_reg`. In the next cycle, the loaded data is forwarded directly from the WB stage into the ALU.
> 
> Finally, for **Control Hazards**, branches are resolved in the EX stage by `branch_unit.v`. If taken, the pipeline penalty is exactly 2 cycles, and a flush signal synchronously clears `if_id_reg` and `id_ex_reg`."

---

## Segment 4: Live Verification & Testing (4:00 – 6:00)

### What to Show on Screen:
Switch to the terminal. Run the live simulation commands.

#### Step 4A: Baseline Sum Program
Run:
```bash
iverilog -g2012 -o sim.out tb/tb_riscv_pipeline.v rtl/*.v rtl/*/*.v && vvp sim.out
```
Point to the terminal output:
`✓ ALL TESTS PASSED — Processor working correctly!`

### Spoken Script:
> "Now let's see the processor in action.
> 
> First, we run our baseline integration test. It executes additions, forwarding, stores to memory, and loads back from memory.
> As you can see on screen:
> Registers x1 through x7 and mem[0] match all expected values, and we get `ALL TESTS PASSED`."

#### Step 4B: SystemVerilog Assertions (SVA)
Run:
```bash
iverilog -g2012 -o sim_sva.out tb/tb_riscv_pipeline_sva.sv rtl/*.v rtl/*/*.v && vvp sim_sva.out
```
Point to output:
`=== SVA Verification Completed with 0 Violations! ===`

### Spoken Script:
> "To formally verify the pipeline, we wrote a suite of SystemVerilog Assertions in `tb_riscv_pipeline_sva.sv`.
> These assertions continuously verify at every single clock cycle that:
> 1. Register x0 is never modified from 0,
> 2. The Program Counter and IF/ID instruction remain strictly frozen during stalls,
> 3. Control signals are neutralized after flushes, and
> 4. EX-EX forwarding takes strict priority.
> As you can see, our SVA suite completed with **zero violations**."

#### Step 4C: Fibonacci Algorithm & Bubble Sort
Run:
```bash
cp tb/program_fibonacci.hex program.hex
iverilog -g2012 -o sim_fib.out tb/tb_phase4_fibonacci.v rtl/*.v rtl/*/*.v && vvp sim_fib.out
```
Point to the 10 Fibonacci numbers computed dynamically: `0, 1, 1, 2, 3, 5, 8, 13, 21, 34`.

Then run Bubble Sort:
```bash
cp tb/program_sort.hex program.hex
iverilog -g2012 -o sim_sort.out tb/tb_phase5_sort.v rtl/*.v rtl/*/*.v && vvp sim_sort.out
```
Point to output:
`✓ Memory array correctly sorted: mem[0..3] = [2, 7, 10, 25]`

### Spoken Script:
> "Next, we stress-test the pipeline with two real-world algorithms:
> First, an iterative **Fibonacci sequence generator**. It runs a loop in hardware, calculates the first 10 Fibonacci numbers, writes them into data memory, and loads them back into registers. All 10 numbers match the mathematical series perfectly.
> 
> Second, an in-memory **Bubble Sort algorithm**. We initialize an unsorted array of [25, 10, 7, 2] in memory. The processor runs comparison passes with `SLT` and `BEQ`, conditionally swaps values, and produces the sorted array [2, 7, 10, 25] with 100% accuracy."

---

## Segment 5: Vivado Simulation, Synthesis & Wrap-up (6:00 – 7:00)

### What to Show on Screen:
Show the Vivado xsim log or Vivado GUI:
`riscv_pipeline.runs/synth_1/riscv_pipeline.dcp`

### Spoken Script:
> "Finally, we synthesized the entire design in AMD Xilinx Vivado 2022.2 targeting a Xilinx Artix-7 FPGA (xc7a35t).
> Synthesis completed with **0 errors and 0 critical warnings**, generating our implementation checkpoint `riscv_pipeline.dcp`.
> 
> In summary, we have built a complete, hazard-free RISC-V RV32I pipelined processor with forwarding, stalls, flushes, formal SVA properties, and complex algorithm execution.
> 
> All source code, testbenches, and reports are available in the repository. Thank you for watching!"

---

## Recording Tips
- Speak at a steady, confident pace.
- Use mouse highlighting when pointing out specific lines in code or terminal outputs.
- Keep terminal text clean and legible (font size 14-16 pt).
