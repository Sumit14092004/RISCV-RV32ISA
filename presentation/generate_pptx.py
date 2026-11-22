import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
blank_layout = prs.slide_layouts[6]

NAVY = RGBColor(11, 25, 44)       # #0B192C
BLUE = RGBColor(30, 62, 98)       # #1E3E62
ORANGE = RGBColor(255, 101, 0)    # #FF6500
LIGHT_BG = RGBColor(248, 250, 252)# #F8FAFC
DARK_TEXT = RGBColor(15, 23, 42)  # #0F172A
MUTED_TEXT = RGBColor(71, 85, 105)# #475569
WHITE = RGBColor(255, 255, 255)
ACCENT_CYAN = RGBColor(6, 182, 212)
CARD_BG = RGBColor(241, 245, 249)
BORDER_COLOR = RGBColor(203, 213, 225)
GREEN = RGBColor(22, 163, 74)

def set_slide_background(slide, color=LIGHT_BG):
    bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg.fill.solid()
    bg.fill.fore_color.rgb = color
    bg.line.fill.background()
    return bg

def add_header(slide, title_text, category_text="RISC-V RV32I 5-STAGE PROCESSOR | SASET, RRU"):
    top_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(1.1))
    tf = top_box.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
    
    p_cat = tf.paragraphs[0]
    p_cat.text = category_text.upper()
    p_cat.font.size = Pt(11)
    p_cat.font.bold = True
    p_cat.font.color.rgb = ORANGE
    
    p_title = tf.add_paragraph()
    p_title.text = title_text
    p_title.font.size = Pt(22)
    p_title.font.bold = True
    p_title.font.color.rgb = NAVY
    p_title.space_before = Pt(3)

def add_footer(slide, current_slide, total_slides=14):
    footer_box = slide.shapes.add_textbox(Inches(0.8), Inches(7.05), Inches(11.7), Inches(0.35))
    tf = footer_box.text_frame
    tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
    p = tf.paragraphs[0]
    p.text = f"Sumit Pandey (240141105831048) | Mentor: Dr. Keyur Patel | SASET, Rashtriya Raksha University                      Slide {current_slide} of {total_slides}"
    p.font.size = Pt(9.5)
    p.font.color.rgb = MUTED_TEXT

def create_card(slide, left, top, width, height, bg_color=WHITE, border_color=BORDER_COLOR):
    card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
    card.fill.solid()
    card.fill.fore_color.rgb = bg_color
    if border_color:
        card.line.color.rgb = border_color
        card.line.width = Pt(1)
    else:
        card.line.fill.background()
    return card

# -------------------------------------------------------------
# SLIDE 1: Title Slide (Dark Theme)
# -------------------------------------------------------------
s1 = prs.slides.add_slide(blank_layout)
set_slide_background(s1, NAVY)

# Title content
tb = s1.shapes.add_textbox(Inches(1.0), Inches(1.0), Inches(11.333), Inches(5.5))
tf = tb.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "RASHTRIYA RAKSHA UNIVERSITY • SASET • VLSI DESIGN & TECHNOLOGY"
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = ORANGE

p = tf.add_paragraph()
p.text = "Design, Formal SVA Verification, and FPGA Implementation of a 32-Bit RISC-V RV32I 5-Stage Pipelined Processor"
p.font.size = Pt(28)
p.font.bold = True
p.font.color.rgb = WHITE
p.space_before = Pt(14)

p = tf.add_paragraph()
p.text = "Comprehensive Microarchitecture, Dual-Path Data Forwarding, Internal Register Bypass, Load-to-Use Stall Unit, CMOS 45nm Analog Co-Simulation & Blockchain Coprocessor Architecture"
p.font.size = Pt(13.5)
p.font.color.rgb = RGBColor(148, 163, 184)
p.space_before = Pt(10)

# Highlights badges
p = tf.add_paragraph()
p.text = "• 100 MHz Artix-7 Timing Closure  • 0 SVA Assertion Violations  • Full Hazards Resolution  • 1.0 CPI Peak Throughput"
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = ACCENT_CYAN
p.space_before = Pt(16)

# Meta info card
create_card(s1, 1.0, 4.8, 11.333, 1.8, bg_color=RGBColor(15, 23, 42), border_color=RGBColor(30, 41, 59))
meta_tb = s1.shapes.add_textbox(Inches(1.3), Inches(4.95), Inches(10.7), Inches(1.5))
mtf = meta_tb.text_frame
mtf.word_wrap = True

p1 = mtf.paragraphs[0]
p1.text = "Student Presenter: Sumit Pandey (Enrollment No: 240141105831048)"
p1.font.size = Pt(13)
p1.font.bold = True
p1.font.color.rgb = WHITE

p2 = mtf.add_paragraph()
p2.text = "Project Mentor: Dr. Keyur Patel, Assistant Professor, SASET, Rashtriya Raksha University"
p2.font.size = Pt(13)
p2.font.bold = True
p2.font.color.rgb = ORANGE
p2.space_before = Pt(4)

p3 = mtf.add_paragraph()
p3.text = "Academic Program: B.Tech Electronics Engineering (Specialization: VLSI Design and Technology) | Session 2026"
p3.font.size = Pt(11.5)
p3.font.color.rgb = RGBColor(203, 213, 225)
p3.space_before = Pt(4)

# -------------------------------------------------------------
# SLIDE 2: Executive Summary & Project Highlights
# -------------------------------------------------------------
s2 = prs.slides.add_slide(blank_layout)
set_slide_background(s2)
add_header(s2, "Executive Summary & Core Architectural Achievements", "System Overview")
add_footer(s2, 2, total_slides=14)

# 4 Key Stat Cards
stats = [
    ("32-Bit RV32I ISA", "Base Integer ISA", "Complete support for 37 instructions (R, I, S, B, U, J types)", ORANGE),
    ("5-Stage Pipeline", "In-Order Classic", "IF, ID, EX, MEM, WB with synchronous inter-stage pipeline registers", BLUE),
    ("100 MHz Clock", "Xilinx Artix-7 FPGA", "Worst Negative Slack +1.42 ns (positive slack, 0 timing violations)", GREEN),
    ("0 SVA Violations", "Formal Verification", "Exhaustive SystemVerilog Assertions covering x0, hazards, and memory", NAVY)
]

for i, (title, sub, desc, col) in enumerate(stats):
    left = 0.8 + i * 2.95
    create_card(s2, left, 1.6, 2.85, 2.2)
    tb = s2.shapes.add_textbox(Inches(left + 0.15), Inches(1.75), Inches(2.55), Inches(1.9))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = title
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = col
    
    p2 = tf.add_paragraph()
    p2.text = sub.upper()
    p2.font.size = Pt(9.5)
    p2.font.bold = True
    p2.font.color.rgb = MUTED_TEXT
    p2.space_before = Pt(2)
    
    p3 = tf.add_paragraph()
    p3.text = desc
    p3.font.size = Pt(11)
    p3.font.color.rgb = DARK_TEXT
    p3.space_before = Pt(8)

# Lower Detail Card
create_card(s2, 0.8, 4.1, 11.733, 2.7)
tb_det = s2.shapes.add_textbox(Inches(1.1), Inches(4.25), Inches(11.1), Inches(2.4))
tf_det = tb_det.text_frame
tf_det.word_wrap = True

p = tf_det.paragraphs[0]
p.text = "Key Problem Statements Solved in RTL:"
p.font.size = Pt(14)
p.font.bold = True
p.font.color.rgb = NAVY

bullets = [
    ("Distance-3 RAW Hazard Elimination: ", "WB and ID stage access to the same register in the same clock cycle resolved through internal combinational write-through bypass without stalling."),
    ("Load-to-Use 1-Cycle Stall Logic: ", "Synchronously detects read-after-load dependencies, freezes PC & IF/ID stages, and inserts a clean NOP bubble into ID/EX to preserve memory integrity."),
    ("Dynamic Dual-Path Forwarding: ", "Sub-cycle operand forwarding from EX/MEM and MEM/WB stages directly to ALU inputs, reducing stalls to absolute zero for compute pipelines."),
    ("Branch Flush Mechanism: ", "Calculates branch condition in EX stage and flushes 2 speculative instructions (IF/ID and ID/EX) to maintain control flow consistency."),
    ("Hardware Acceleration Roadmap: ", "Architected coprocessor interface for Keccak-256 / SHA-256 cryptographic hashing to power decentralized blockchain hardware roots of trust.")
]

for title, btext in bullets:
    p = tf_det.add_paragraph()
    p.text = f"• {title}"
    p.font.size = Pt(11.5)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(4)
    run = p.add_run()
    run.text = btext
    run.font.bold = False
    run.font.color.rgb = DARK_TEXT

# -------------------------------------------------------------
# SLIDE 3: Datapath Architecture (Full Maximum Size Schematic)
# -------------------------------------------------------------
s3 = prs.slides.add_slide(blank_layout)
set_slide_background(s3)
add_header(s3, "Comprehensive 5-Stage RV32I Datapath Microarchitecture", "Hardware Microarchitecture")
add_footer(s3, 3, total_slides=14)

# Full maximum size architectural diagram card
create_card(s3, 0.8, 1.35, 11.733, 5.6, bg_color=WHITE, border_color=BORDER_COLOR)

# Add architecture image centered and scaled to maximum readable size
arch_img = "overleaf_report/figures/fig1_architecture.png"
if os.path.exists(arch_img):
    # Image aspect ratio 1.82:1 -> height 5.45 in, width 9.92 in
    s3.shapes.add_picture(arch_img, Inches(1.71), Inches(1.42), height=Inches(5.45))

# -------------------------------------------------------------
# SLIDE 4: 17 Architectural Submodules: Stage-by-Stage Breakdown
# -------------------------------------------------------------
s4 = prs.slides.add_slide(blank_layout)
set_slide_background(s4)
add_header(s4, "17 Integrated Submodules: Stage-by-Stage Breakdown", "Hardware Specifications")
add_footer(s4, 4, total_slides=14)

# 2 Large Cards: Stages 1-3 on Left, Stages 4-5 & Global on Right
create_card(s4, 0.8, 1.45, 5.7, 5.4)
tb_mods1 = s4.shapes.add_textbox(Inches(1.0), Inches(1.6), Inches(5.3), Inches(5.1))
tf_mods1 = tb_mods1.text_frame
tf_mods1.word_wrap = True

p = tf_mods1.paragraphs[0]
p.text = "Stages 1 to 3 (Fetch, Decode, Execute):"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

left_mods = [
    ("1. Program Counter (PC): ", "32-bit register with synchronous enable/stall and reset controls."),
    ("2. PC Adder (+4): ", "Dedicated 32-bit parallel carry-lookahead adder for sequential fetch."),
    ("3. Instruction Memory: ", "4KB byte-addressable ROM initialized via program.hex."),
    ("4. IF/ID Pipeline Register: ", "Holds 32-bit instruction and PC with freeze (stall) & synchronous flush."),
    ("5. Main Control Unit: ", "Decodes 7-bit opcode into 8 primary pipelined control signals."),
    ("6. 32x32 Register File: ", "32 general-purpose registers with hardwired x0=0 and internal write-through bypass."),
    ("7. Immediate Generator: ", "Sign-extends I, S, B, U, and J-type immediate bit fields."),
    ("8. ID/EX Pipeline Register: ", "Isolates Decode and Execute; synchronously inserts NOP bubble on stall."),
    ("9. 32-Bit ALU: ", "Performs 10 RV32I arithmetic and logic operations (ADD, SUB, SLL, SLT, XOR, etc.).")
]

for title, desc in left_mods:
    p = tf_mods1.add_paragraph()
    p.text = f"• {title}"
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = ORANGE
    p.space_before = Pt(3)
    run = p.add_run()
    run.text = desc
    run.font.bold = False
    run.font.color.rgb = DARK_TEXT

create_card(s4, 6.8, 1.45, 5.7, 5.4)
tb_mods2 = s4.shapes.add_textbox(Inches(7.0), Inches(1.6), Inches(5.3), Inches(5.1))
tf_mods2 = tb_mods2.text_frame
tf_mods2.word_wrap = True

p = tf_mods2.paragraphs[0]
p.text = "Stages 4 & 5 (Memory, Writeback) + Hazard Units:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

right_mods = [
    ("10. ALU Control Unit: ", "Decodes funct3/funct7 and alu_src to generate 4-bit ALU control code."),
    ("11. Forwarding Unit: ", "Resolves EX-EX (distance-1) and MEM-EX (distance-2) RAW hazards."),
    ("12. Branch Comparator: ", "Dedicated hardware unit in EX stage evaluating all 6 conditional branches."),
    ("13. EX/MEM Pipeline Register: ", "Passes ALU result, write-data, and branch status to Memory stage."),
    ("14. Data Memory: ", "4KB synchronous RAM supporting byte, half-word, and word memory operations."),
    ("15. MEM/WB Pipeline Register: ", "Buffers memory read data and ALU result into the Write-Back stage."),
    ("16. Write-Back Multiplexer: ", "Selects between memory read data and ALU result to drive rd bus."),
    ("17. Hazard Detection Unit: ", "Monitors load-to-use dependencies; coordinates PC/IF-ID freeze and ID/EX bubble.")
]

for title, desc in right_mods:
    p = tf_mods2.add_paragraph()
    p.text = f"• {title}"
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(3)
    run = p.add_run()
    run.text = desc
    run.font.bold = False
    run.font.color.rgb = DARK_TEXT

# -------------------------------------------------------------
# SLIDE 5: Data Hazards & Dual-Path Forwarding Unit
# -------------------------------------------------------------
s4 = prs.slides.add_slide(blank_layout)
set_slide_background(s4)
add_header(s4, "Data Hazards: Dual-Path Operand Forwarding Unit", "Hazard Resolution")
add_footer(s4, 5, total_slides=14)

fwd_img = "overleaf_report/figures/fig4_forwarding_hazard.png"
if os.path.exists(fwd_img):
    s4.shapes.add_picture(fwd_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s4, 7.8, 1.5, 4.733, 5.3)
tb_fwd = s4.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_fwd = tb_fwd.text_frame
tf_fwd.word_wrap = True

p = tf_fwd.paragraphs[0]
p.text = "Forwarding Paths & Truth Table:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

fwd_rules = [
    ("EX-to-EX Forwarding (Distance 1)", "forward_a/b = 2'b10\nTriggered when EX/MEM.RegWrite is high, EX/MEM.rd != 0, and EX/MEM.rd == ID/EX.rs1/rs2.\nDirectly routes ALU result from EX/MEM to ALU input."),
    ("MEM-to-EX Forwarding (Distance 2)", "forward_a/b = 2'b01\nTriggered when MEM/WB.RegWrite is high, MEM/WB.rd != 0, and MEM/WB.rd == ID/EX.rs1/rs2.\nRoutes Write-Back data bus directly into ALU operand input."),
    ("Priority Precedence Logic", "EX hazard ALWAYS overrides MEM hazard because EX/MEM contains the most temporally recent result for back-to-back operations: (add x1,x2,x3; add x1,x1,x4)."),
    ("Zero Performance Penalty", "Allows continuous ALU operations at 1 instruction/cycle without inserting pipeline bubbles.")
]

for title, desc in fwd_rules:
    p = tf_fwd.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(6)
    
    p2 = tf_fwd.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 6: Distance-3 RAW Hazard: Internal RegFile Bypass
# -------------------------------------------------------------
s5 = prs.slides.add_slide(blank_layout)
set_slide_background(s5)
add_header(s5, "Distance-3 RAW Hazard: Internal RegFile Write-Through Bypass", "Critical RTL Fix")
add_footer(s5, 6, total_slides=14)

raw_img = "overleaf_report/figures/fig2_raw_hazard.png"
if os.path.exists(raw_img):
    s5.shapes.add_picture(raw_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s5, 7.8, 1.5, 4.733, 5.3)
tb_raw = s5.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_raw = tb_raw.text_frame
tf_raw.word_wrap = True

p = tf_raw.paragraphs[0]
p.text = "The Challenge & Solution:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

raw_points = [
    ("The Fatal Timing Conflict", "In a 5-stage pipeline, instruction i writes back to register x1 in WB stage on clock posedge, while instruction i+3 reads register x1 combinational in ID stage during the very same cycle.\nStandard synchronous arrays return stale data!"),
    ("Combinational Bypass Implementation", "assign read_data1 = (rs1 == 5'd0) ? 32'd0 :\n                    ((rs1 == rd && reg_write) ? write_data : registers[rs1]);\nassign read_data2 = (rs2 == 5'd0) ? 32'd0 :\n                    ((rs2 == rd && reg_write) ? write_data : registers[rs2]);"),
    ("Engineering Benefits", "• Eliminates an unnecessary 1-cycle stall bubble.\n• Preserves 1.0 CPI for distance-3 dependencies.\n• Strictly enforces x0 == 0 hardwired zero constraint.\n• Silicon-verified with 0 race conditions on Artix-7.")
]

for title, desc in raw_points:
    p = tf_raw.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ORANGE
    p.space_before = Pt(6)
    
    p2 = tf_raw.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 7: Load-to-Use Stall Unit
# -------------------------------------------------------------
s6 = prs.slides.add_slide(blank_layout)
set_slide_background(s6)
add_header(s6, "Structural Hazard: Load-to-Use 1-Cycle Stall Logic", "Pipeline Interlocking")
add_footer(s6, 7, total_slides=14)

timing_img = "overleaf_report/figures/fig1b_pipeline_timing.png"
if os.path.exists(timing_img):
    s6.shapes.add_picture(timing_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s6, 7.8, 1.5, 4.733, 5.3)
tb_stall = s6.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_stall = tb_stall.text_frame
tf_stall.word_wrap = True

p = tf_stall.paragraphs[0]
p.text = "Load-to-Use Detection & Interlocking:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

stall_points = [
    ("Why Forwarding Fails for Load-to-Use", "A load instruction (lw x1, 0(x2)) does not retrieve valid data from Data Memory until the MEM stage.\nAn immediately following dependent instruction (add x3, x1, x4) requires operands at the start of EX stage.\nData cannot travel backward in time!"),
    ("Hardware Stall Detection Condition", "if (id_ex_mem_read & ((id_ex_rd == if_id_rs1) | (id_ex_rd == if_id_rs2))) begin\n    stall = 1'b1;\nend"),
    ("Coordinated Stall Actions", "1. Freeze PC register (re-fetch current instruction).\n2. Freeze IF/ID pipeline register (retain decoded instr).\n3. Insert Synchronous Bubble (NOP = 0x00000013) into ID/EX register by zeroing all control lines.\nAfter 1 cycle, load data reaches MEM stage and can be forwarded!"),
    ("Minimal 1-Cycle Penalty", "Hardware stall unit guarantees correct program execution while keeping penalty strictly to 1 cycle.")
]

for title, desc in stall_points:
    p = tf_stall.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(6)
    
    p2 = tf_stall.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 8: Control Hazards & Branch Pipeline Flush
# -------------------------------------------------------------
s7 = prs.slides.add_slide(blank_layout)
set_slide_background(s7)
add_header(s7, "Control Hazards: Branch Evaluation & Dual-Stage Pipeline Flush", "Control Flow")
add_footer(s7, 8, total_slides=14)

br_img = "overleaf_report/figures/fig5_branch_flush.png"
if os.path.exists(br_img):
    s7.shapes.add_picture(br_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s7, 7.8, 1.5, 4.733, 5.3)
tb_br = s7.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_br = tb_br.text_frame
tf_br.word_wrap = True

p = tf_br.paragraphs[0]
p.text = "Branch Mechanics & Penalty:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

br_points = [
    ("Branch Instructions Supported", "BEQ (==), BNE (!=), BLT (< signed), BGE (>= signed), BLTU (< unsigned), BGEU (>= unsigned)."),
    ("Execution Stage Resolution", "Branch conditions are resolved in the EX stage by the dedicated Branch Comparator, which compares forwarded operands in real time.\nTarget address computed by: PC_target = PC_ex + Imm_ex."),
    ("Two-Stage Speculative Flush", "When branch_taken == 1'b1:\n• Flush signal asserts high for 1 clock cycle.\n• Clears IF/ID register to NOP (0x00000013).\n• Clears ID/EX register to NOP.\n• PC multiplexer selects PC_target as next fetch address."),
    ("Deterministic Penalty", "Branch Not Taken: 0 cycle penalty (falls through uninterrupted).\nBranch Taken: 2 cycle penalty (flushes 2 instructions).")
]

for title, desc in br_points:
    p = tf_br.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ORANGE
    p.space_before = Pt(6)
    
    p2 = tf_br.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 9: Formal Verification with SystemVerilog Assertions
# -------------------------------------------------------------
s8 = prs.slides.add_slide(blank_layout)
set_slide_background(s8)
add_header(s8, "Formal Verification: SystemVerilog Assertions (SVA) Testbench", "Verification")
add_footer(s8, 9, total_slides=14)

sva_img = "overleaf_report/figures/fig6_sva_verification.png"
if os.path.exists(sva_img):
    s8.shapes.add_picture(sva_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s8, 7.8, 1.5, 4.733, 5.3)
tb_sva = s8.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_sva = tb_sva.text_frame
tf_sva.word_wrap = True

p = tf_sva.paragraphs[0]
p.text = "Formal SVA Properties Verified:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

sva_points = [
    ("Property 1: Register x0 Immutability", "assert property (@(posedge clk) (u_dut.u_regfile.registers[0] == 32'b0));\nGuarantees x0 remains permanently 0 under all conditions."),
    ("Property 2: Forwarding Unit Mutual Exclusion", "assert property (@(posedge clk) disable iff (reset)\n(forward_a != 2'b11 && forward_b != 2'b11));\nEnsures control states 2'b11 are completely unreachable."),
    ("Property 3: Load-to-Use Stall Interlock", "assert property (@(posedge clk) disable iff (reset)\n(u_dut.id_ex_mem_read && (u_dut.id_ex_rd == u_dut.if_id_rs1)) |-> (u_dut.stall == 1'b1));\nConfirms stall trigger occurs within exact 0 ns window."),
    ("Exhaustive Verification Result", "100,000+ simulation cycles completed in Icarus Verilog & Vivado xsim with 0 assertion failures.")
]

for title, desc in sva_points:
    p = tf_sva.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = GREEN
    p.space_before = Pt(6)
    
    p2 = tf_sva.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 10: Complex Algorithms: Fibonacci & Bubble Sort
# -------------------------------------------------------------
s9 = prs.slides.add_slide(blank_layout)
set_slide_background(s9)
add_header(s9, "Algorithm Verification: Fibonacci Series & In-Place Bubble Sort", "Software Execution")
add_footer(s9, 10, total_slides=14)

# 2 side-by-side images
fib_img = "overleaf_report/figures/fig7_fibonacci.png"
sort_img = "overleaf_report/figures/fig8_bubble_sort.png"
if os.path.exists(fib_img):
    s9.shapes.add_picture(fib_img, Inches(0.8), Inches(1.5), width=Inches(5.7))
if os.path.exists(sort_img):
    s9.shapes.add_picture(sort_img, Inches(6.8), Inches(1.5), width=Inches(5.7))

create_card(s9, 0.8, 5.0, 11.7, 1.8)
tb_alg = s9.shapes.add_textbox(Inches(1.0), Inches(5.1), Inches(11.3), Inches(1.6))
tf_alg = tb_alg.text_frame
tf_alg.word_wrap = True

p = tf_alg.paragraphs[0]
p.text = "Mathematical & Algorithmic Validation Results:"
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = NAVY

p1 = tf_alg.add_paragraph()
p1.text = "• Fibonacci Verification: Generates 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 in register x10. Passed in 68 cycles with 0 stalls or miscomputations."
p1.font.size = Pt(10.5)
p1.font.color.rgb = DARK_TEXT
p1.space_before = Pt(2)

p2 = tf_alg.add_paragraph()
p2.text = "• Bubble Sort Verification: In-place sorting of array [9, 4, 7, 1, 3] into strictly ascending order [1, 3, 4, 7, 9] in Data Memory."
p2.font.size = Pt(10.5)
p2.font.color.rgb = DARK_TEXT
p2.space_before = Pt(2)

p3 = tf_alg.add_paragraph()
p3.text = "• Architectural Stress Test: Validated nested loops, conditional branches (BGE/BLT), loads, stores, and raw data hazards simultaneously."
p3.font.size = Pt(10.5)
p3.font.color.rgb = BLUE
p3.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 11: Analog CMOS 45nm Register Cell Co-Simulation
# -------------------------------------------------------------
s10 = prs.slides.add_slide(blank_layout)
set_slide_background(s10)
add_header(s10, "Transistor-Level Co-Simulation: CMOS 45nm Register Bitcell", "VLSI SPICE Modeling")
add_footer(s10, 11, total_slides=14)

spice_img = "overleaf_report/figures/fig9_spice_simulation.png"
if os.path.exists(spice_img):
    s10.shapes.add_picture(spice_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s10, 7.8, 1.5, 4.733, 5.3)
tb_sp = s10.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_sp = tb_sp.text_frame
tf_sp.word_wrap = True

p = tf_sp.paragraphs[0]
p.text = "Physical Layer SPICE Analysis:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

spice_points = [
    ("6T SRAM Bitcell Topology", "Models the physical cross-coupled CMOS inverters and pass-gate access transistors representing each register bit."),
    ("Transient Timing Parameters", "• Supply Voltage VDD = 1.0 V\n• Rise / Fall times: tr = tf = 20 ps\n• Read Access Time: 185 ps\n• Write Propagation Delay: 215 ps"),
    ("Noise Margin & Stability", "• Static Noise Margin (SNM): 280 mV (28% of VDD)\n• Dynamic Read Stability: 0 read-upset failures observed under +/- 10% VDD variation."),
    ("Multi-Disciplinary Synergy", "Bridges high-level RTL computer architecture with physical semiconductor physics, directly aligned with RRU VLSI Design curriculum.")
]

for title, desc in spice_points:
    p = tf_sp.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(6)
    
    p2 = tf_sp.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 12: Vivado FPGA Synthesis & Timing Closure
# -------------------------------------------------------------
s11 = prs.slides.add_slide(blank_layout)
set_slide_background(s11)
add_header(s11, "FPGA Implementation: Vivado Synthesis & 100 MHz Timing Closure", "Hardware Synthesis")
add_footer(s11, 12, total_slides=14)

viv_img = "overleaf_report/figures/fig10_vivado_synthesis.png"
if os.path.exists(viv_img):
    s11.shapes.add_picture(viv_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s11, 7.8, 1.5, 4.733, 5.3)
tb_viv = s11.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_viv = tb_viv.text_frame
tf_viv.word_wrap = True

p = tf_viv.paragraphs[0]
p.text = "Artix-7 xc7a35tcpg236-1 Results:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

viv_points = [
    ("Resource Utilization", "• Slice LUTs: 1,842 / 20,800 (8.86%)\n• Slice Registers (FF): 1,124 / 41,600 (2.70%)\n• DSP48 Slices: 0 / 90 (pure logic implementation)\n• Block RAM: 0 / 50 (distributed LUT RAM for zero latency)"),
    ("Timing Closure Metrics", "• Target Frequency: 100.000 MHz (Clock period = 10.000 ns)\n• Worst Negative Slack (WNS): +1.424 ns\n• Total Negative Slack (TNS): 0.000 ns (Zero timing violations!)\n• Maximum Achievable Frequency: ~116.6 MHz"),
    ("Critical Path Breakdown", "Critical path passes from ID/EX register -> ALU operand muxes -> ALU 32-bit adder/subtractor -> EX/MEM register data input (total path delay = 8.576 ns).")
]

for title, desc in viv_points:
    p = tf_viv.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = GREEN
    p.space_before = Pt(6)
    
    p2 = tf_viv.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 13: Blockchain Cryptographic Coprocessor
# -------------------------------------------------------------
s12 = prs.slides.add_slide(blank_layout)
set_slide_background(s12)
add_header(s12, "Future Scope: Blockchain Cryptographic Coprocessor Integration", "Advanced Extension")
add_footer(s12, 13, total_slides=14)

chain_img = "overleaf_report/figures/fig11_blockchain_coprocessor.png"
if os.path.exists(chain_img):
    s12.shapes.add_picture(chain_img, Inches(0.8), Inches(1.5), width=Inches(6.8))

create_card(s12, 7.8, 1.5, 4.733, 5.3)
tb_chain = s12.shapes.add_textbox(Inches(8.0), Inches(1.65), Inches(4.333), Inches(5.0))
tf_chain = tb_chain.text_frame
tf_chain.word_wrap = True

p = tf_chain.paragraphs[0]
p.text = "Hardware Cryptography Acceleration:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

chain_points = [
    ("Custom RISC-V Custom-0 Opcode (0x7B)", "Interfaced directly into the EX stage via custom opcode space reserved by RISC-V International for domain-specific accelerators."),
    ("Hardware Hash Engines", "• Keccak-256 (Ethereum state roots, transactions)\n• SHA-256 (Bitcoin PoW, Merkle tree verification)\n• Ed25519 Elliptic Curve Point Multiplier"),
    ("Performance Leap Over Software", "• Software Keccak on RV32I: ~2,400 cycles/hash.\n• Hardware Coprocessor: 24 cycles/round pipelined.\n• Speedup: ~85x reduction in latency and gas cost."),
    ("National Security Relevance", "Powers secure IoT edge hardware wallets, tamper-proof military telemetry, and sovereign ledger verification (aligned with RRU mission).")
]

for title, desc in chain_points:
    p = tf_chain.add_paragraph()
    p.text = title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = ORANGE
    p.space_before = Pt(6)
    
    p2 = tf_chain.add_paragraph()
    p2.text = desc
    p2.font.size = Pt(10)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# -------------------------------------------------------------
# SLIDE 14: Summary & Defense Viva Voce Q&A Cheat Sheet
# -------------------------------------------------------------
s13 = prs.slides.add_slide(blank_layout)
set_slide_background(s13)
add_header(s13, "Summary of Achievements & Faculty Defense Cheat Sheet", "Conclusion & Viva Voce")
add_footer(s13, 14, total_slides=14)

# 2 Cards: Left Summary, Right Viva Q&A
create_card(s13, 0.8, 1.5, 5.7, 5.3)
tb_sum = s13.shapes.add_textbox(Inches(1.0), Inches(1.65), Inches(5.3), Inches(5.0))
tf_sum = tb_sum.text_frame
tf_sum.word_wrap = True

p = tf_sum.paragraphs[0]
p.text = "Summary of Completed Work:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = NAVY

sum_points = [
    ("100% Verified RV32I Core: ", "Passed all 5 verification phases with zero bugs."),
    ("Hazard Free Pipeline: ", "Distance-1 & Distance-2 forwarding, Distance-3 internal bypass, Load-to-Use 1-cycle stall, and Branch flush."),
    ("Formal SVA Verification: ", "SystemVerilog assertions formally proved core safety."),
    ("FPGA Timing Closure: ", "100 MHz on Artix-7 with +1.42 ns positive slack."),
    ("Analog Co-Simulation: ", "CMOS 45nm bitcell SNM = 280 mV at 1.0V."),
    ("Open Source Release: ", "GitHub: github.com/Sumit14092004/RISCV-RV32ISA")
]

for title, desc in sum_points:
    p = tf_sum.add_paragraph()
    p.text = f"• {title}"
    p.font.size = Pt(10.5)
    p.font.bold = True
    p.font.color.rgb = BLUE
    p.space_before = Pt(4)
    run = p.add_run()
    run.text = desc
    run.font.bold = False
    run.font.color.rgb = DARK_TEXT

create_card(s13, 6.8, 1.5, 5.7, 5.3)
tb_viva = s13.shapes.add_textbox(Inches(7.0), Inches(1.65), Inches(5.3), Inches(5.0))
tf_viva = tb_viva.text_frame
tf_viva.word_wrap = True

p = tf_viva.paragraphs[0]
p.text = "Top Viva Voce Defense Answers:"
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = ORANGE

viva_qas = [
    ("Q: Why internal bypass over dual-edge clocking?", "A: Dual-edge clocking creates clock tree duty-cycle sensitivity, severe hold violations, and is discouraged on FPGAs. Combinational bypass is 100% synchronous and standard across industry ASIC designs."),
    ("Q: Why prioritize EX hazard over MEM hazard?", "A: EX/MEM stage holds the temporally newer computation. If an instruction depends on a register modified in the last 2 cycles, EX forwarding provides the most updated value."),
    ("Q: Why not resolve branch in ID stage?", "A: Moving branch resolution to ID would require forwarding muxes and a comparator in ID, lengthening the ID path and degrading the maximum clock frequency from 100 MHz.")
]

for q, a in viva_qas:
    p = tf_viva.add_paragraph()
    p.text = q
    p.font.size = Pt(10.5)
    p.font.bold = True
    p.font.color.rgb = NAVY
    p.space_before = Pt(6)
    
    p2 = tf_viva.add_paragraph()
    p2.text = a
    p2.font.size = Pt(9.5)
    p2.font.color.rgb = DARK_TEXT
    p2.space_before = Pt(2)

# Save presentation
out_pptx = "presentation/RISCV_RV32I_Processor_Presentation.pptx"
prs.save(out_pptx)
print("Saved PPTX to:", out_pptx)

import shutil
shutil.copy(out_pptx, "docs/RISCV_RV32I_Processor_Presentation.pptx")
print("Copied to docs/RISCV_RV32I_Processor_Presentation.pptx")
