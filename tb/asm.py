#!/usr/bin/env python3
"""
Simple two-pass RISC-V RV32I assembler for test generation.
Supports labels, comments, and core RV32I instructions.
"""
import sys, re

def parse_reg(reg_str):
    reg_str = reg_str.strip().lower()
    if reg_str.startswith('x'):
        return int(reg_str[1:])
    reg_map = {
        'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
        't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
        'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15, 'a6': 16, 'a7': 17,
        's2': 18, 's3': 19, 's4': 20, 's5': 21, 's6': 22, 's7': 23, 's8': 24, 's9': 25,
        's10': 26, 's11': 27, 't3': 28, 't4': 29, 't5': 30, 't6': 31
    }
    if reg_str in reg_map:
        return reg_map[reg_str]
    raise ValueError(f"Unknown register: {reg_str}")

def parse_imm(imm_str, labels=None, pc=0):
    imm_str = imm_str.strip()
    if labels and imm_str in labels:
        target = labels[imm_str]
        return target - pc
    return int(imm_str, 0)

def assemble(code):
    lines = code.strip().split('\n')
    instructions = []
    labels = {}
    
    # Pass 1: Gather labels
    pc = 0
    clean_lines = []
    for line in lines:
        line = re.sub(r'#.*|//.*', '', line).strip()
        if not line:
            continue
        if ':' in line:
            parts = line.split(':', 1)
            lbl = parts[0].strip()
            labels[lbl] = pc
            line = parts[1].strip()
            if not line:
                continue
        clean_lines.append((pc, line))
        pc += 4

    # Pass 2: Assemble instructions
    machine_code = []
    for pc, line in clean_lines:
        tokens = [t.strip() for t in re.split(r'[\s,()]+', line) if t.strip()]
        op = tokens[0].lower()

        if op == 'nop':
            machine_code.append(0x00000013)
        elif op == 'addi':
            rd = parse_reg(tokens[1])
            rs1 = parse_reg(tokens[2])
            imm = parse_imm(tokens[3], labels, pc) & 0xFFF
            val = (imm << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x13
            machine_code.append(val)
        elif op in ['add', 'sub', 'and', 'or', 'xor', 'slt', 'sll', 'srl', 'sra']:
            rd = parse_reg(tokens[1])
            rs1 = parse_reg(tokens[2])
            rs2 = parse_reg(tokens[3])
            f3_map = {'add':0, 'sub':0, 'sll':1, 'slt':2, 'xor':4, 'srl':5, 'sra':5, 'or':6, 'and':7}
            f7 = 0x20 if op in ['sub', 'sra'] else 0x00
            val = (f7 << 25) | (rs2 << 20) | (rs1 << 15) | (f3_map[op] << 12) | (rd << 7) | 0x33
            machine_code.append(val)
        elif op == 'lw':
            rd = parse_reg(tokens[1])
            imm = parse_imm(tokens[2], labels, pc) & 0xFFF
            rs1 = parse_reg(tokens[3])
            val = (imm << 20) | (rs1 << 15) | (2 << 12) | (rd << 7) | 0x03
            machine_code.append(val)
        elif op == 'sw':
            rs2 = parse_reg(tokens[1])
            imm = parse_imm(tokens[2], labels, pc) & 0xFFF
            rs1 = parse_reg(tokens[3])
            imm_11_5 = (imm >> 5) & 0x7F
            imm_4_0 = imm & 0x1F
            val = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (2 << 12) | (imm_4_0 << 7) | 0x23
            machine_code.append(val)
        elif op in ['beq', 'bne']:
            rs1 = parse_reg(tokens[1])
            rs2 = parse_reg(tokens[2])
            imm = parse_imm(tokens[3], labels, pc)
            imm_12 = (imm >> 12) & 1
            imm_11 = (imm >> 11) & 1
            imm_10_5 = (imm >> 5) & 0x3F
            imm_4_1 = (imm >> 1) & 0xF
            f3 = 0 if op == 'beq' else 1
            val = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | 0x63
            machine_code.append(val)
        elif op == 'lui':
            rd = parse_reg(tokens[1])
            imm = parse_imm(tokens[2], labels, pc) & 0xFFFFF
            val = (imm << 12) | (rd << 7) | 0x37
            machine_code.append(val)
        else:
            raise ValueError(f"Unsupported instruction: {op}")

    # Pad with NOPs up to at least 16 instructions
    while len(machine_code) < 16:
        machine_code.append(0x00000013)
        
    return machine_code

if __name__ == '__main__':
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            code = f.read()
        hex_lines = [f"{val:08x}" for val in assemble(code)]
        if len(sys.argv) > 2:
            with open(sys.argv[2], 'w') as out:
                out.write('\n'.join(hex_lines) + '\n')
        else:
            print('\n'.join(hex_lines))
