# ==============================================================================
# Program A: Full ISA Verification Test (All 10 Instructions)
# Owner: Member 5 (Balanagu Srikar)
# Project: Single-Cycle RV32I Processor
#
# Instructions exercised:
#   1. ADDI (I-type)  - Initialize x1 = 5, x2 = 3
#   2. ADD  (R-type)  - x3 = x1 + x2 = 8
#   3. SUB  (R-type)  - x4 = x1 - x2 = 2
#   4. AND  (R-type)  - x5 = x1 & x2 = 1
#   5. OR   (R-type)  - x6 = x1 | x2 = 7
#   6. XOR  (R-type)  - x7 = x1 ^ x2 = 6
#   7. SW   (S-type)  - Store x3 (8) to memory address 0
#   8. LW   (I-type)  - Load word from address 0 into x8 (8)
#   9. BEQ  (B-type)  - Branch if x3 == x8 (taken -> skip next ADDI)
#  10. BNE  (B-type)  - Branch if x1 != x2 (taken -> skip next ADDI)
#
# Verification points:
#   - x1 = 5, x2 = 3, x3 = 8, x4 = 2, x5 = 1, x6 = 7, x7 = 6, x8 = 8
#   - x9 remains 0 (skipped by BEQ)
#   - x10 remains 0 (skipped by BNE)
#   - x11 = 42 (reached after BNE jump)
#   - Data Memory word 0 = 8
# ==============================================================================

.text
.globl _start

_start:
    # 0x00: Initialize registers with ADDI
    addi x1, x0, 5        # x1 = 0 + 5 = 5 (0x00500093)
    addi x2, x0, 3        # x2 = 0 + 3 = 3 (0x00300113)

    # 0x08: Test R-type ALU arithmetic and logic
    add  x3, x1, x2       # x3 = 5 + 3 = 8 (0x002081b3)
    sub  x4, x1, x2       # x4 = 5 - 3 = 2 (0x40208233)
    and  x5, x1, x2       # x5 = 5 & 3 = 1 (0x0020f2b3)
    or   x6, x1, x2       # x6 = 5 | 3 = 7 (0x0020e333)
    xor  x7, x1, x2       # x7 = 5 ^ 3 = 6 (0x0020c3b3)

    # 0x1C: Test Data Memory Store and Load
    sw   x3, 0(x0)        # mem[0] = x3 = 8 (0x00302023)
    lw   x8, 0(x0)        # x8 = mem[0] = 8 (0x00002403)

    # 0x24: Test Branch If Equal (BEQ) - should be TAKEN (x3 == x8 == 8)
    beq  x3, x8, target1  # Jump forward +8 bytes to target1 (0x00818463)
    addi x9, x0, 1        # Skipped if branch works -> x9 stays 0 (0x00100493)

target1:
    # 0x2C: Test Branch If Not Equal (BNE) - should be TAKEN (x1 != x2, 5 != 3)
    bne  x1, x2, target2  # Jump forward +8 bytes to target2 (0x00209463)
    addi x10, x0, 1       # Skipped if branch works -> x10 stays 0 (0x00100513)

target2:
    # 0x34: Reached after successful branches
    addi x11, x0, 42      # x11 = 42 (0x02a00593)

halt:
    # 0x38: Infinite loop to halt processor
    beq  x0, x0, halt     # Jump to self (0x00000063)
