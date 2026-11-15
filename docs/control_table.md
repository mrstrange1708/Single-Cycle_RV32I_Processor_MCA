# Control unit truth table (Member 4)

`rtl/control.v` implements this table line by line. `tb/tb_control.v` checks
every row for all 10 instructions.

## Instruction encodings

| Instr | Type | opcode  | funct3 | funct7_5 (instr[30]) | Meaning                       |
|-------|------|---------|--------|----------------------|-------------------------------|
| ADD   | R    | 0110011 | 000    | 0                    | rd = rs1 + rs2                |
| SUB   | R    | 0110011 | 000    | 1                    | rd = rs1 - rs2                |
| AND   | R    | 0110011 | 111    | 0                    | rd = rs1 & rs2                |
| OR    | R    | 0110011 | 110    | 0                    | rd = rs1 \| rs2               |
| XOR   | R    | 0110011 | 100    | 0                    | rd = rs1 ^ rs2                |
| ADDI  | I    | 0010011 | 000    | — (part of imm)      | rd = rs1 + imm                |
| LW    | I    | 0000011 | 010    | — (part of imm)      | rd = Mem[rs1 + imm]           |
| SW    | S    | 0100011 | 010    | — (part of imm)      | Mem[rs1 + imm] = rs2          |
| BEQ   | B    | 1100011 | 000    | — (part of imm)      | if rs1 == rs2: PC = PC + imm  |
| BNE   | B    | 1100011 | 001    | — (part of imm)      | if rs1 != rs2: PC = PC + imm  |

## Main decoder (opcode → control signals)

| Instr   | reg_write | alu_src | mem_write | result_src | branch | imm_sel | alu_op          |
|---------|-----------|---------|-----------|------------|--------|---------|-----------------|
| R-type  | 1         | 0       | 0         | 0          | 0      | xx      | 10 (use funct)  |
| ADDI    | 1         | 1       | 0         | 0          | 0      | 00 (I)  | 11 (add)        |
| LW      | 1         | 1       | 0         | 1          | 0      | 00 (I)  | 00 (add)        |
| SW      | 0         | 1       | 1         | x          | 0      | 01 (S)  | 00 (add)        |
| BEQ/BNE | 0         | 0       | 0         | x          | 1      | 10 (B)  | 01 (sub)        |
| other   | 0         | 0       | 0         | 0          | 0      | 00      | 00              |

In the RTL every `x` (don't care) is driven as 0, so no output is ever
undefined. Unknown opcodes produce all zeros: nothing is written.

## ALU decoder (alu_op, funct3, funct7_5 → alu_ctrl)

| alu_op | funct3 | funct7_5 | alu_ctrl | Operation | Used by     |
|--------|--------|----------|----------|-----------|-------------|
| 00     | —      | —        | 000      | add       | LW, SW      |
| 01     | —      | —        | 001      | sub       | BEQ, BNE    |
| 11     | —      | —        | 000      | add       | ADDI        |
| 10     | 000    | 0        | 000      | add       | ADD         |
| 10     | 000    | 1        | 001      | sub       | SUB         |
| 10     | 111    | —        | 010      | and       | AND         |
| 10     | 110    | —        | 011      | or        | OR          |
| 10     | 100    | —        | 100      | xor       | XOR         |

ADDI has its own `alu_op` (11) so the ALU decoder never looks at funct7_5
for it: in an I-type instruction bit 30 is part of the immediate, so a
negative immediate such as `addi x1, x0, -8` would otherwise decode as SUB.

## What each signal means

| Signal     | When 1                                                      |
|------------|-------------------------------------------------------------|
| reg_write  | write the result into register rd at the clock edge         |
| alu_src    | ALU's second input is the immediate (not rs2)               |
| mem_write  | store rs2 into data memory                                  |
| result_src | write back memory data (LW) instead of the ALU result       |
| branch     | this is a branch; take it if the condition holds            |

Branch decision (in `cpu.v`): the ALU computes rs1 - rs2, so equal registers
give zero = 1. `PCSrc = branch & (funct3[0] ? ~zero : zero)`; BEQ and BNE
differ only in funct3 bit 0 (instr[12]).
