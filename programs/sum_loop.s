# ==============================================================================
# Program B: Iterative Loop Summation (Sum 1 to 5 = 15)
# Owner: Member 5 (Balanagu Srikar)
# Project: Single-Cycle RV32I Processor
#
# Algorithm:
#   sum = 0;
#   for (i = 1; i < 6; i++) {
#       sum += i;
#   }
#   mem[4] = sum;  // Word address 1 = 15
#
# Tests:
#   - Backward branching with negative immediate (fe311ce3 -> offset -8)
#   - Register accumulation across loop iterations
#   - Offset memory store (sw x1, 4(x0))
#   - Loop termination condition when i reaches 6
#
# Expected final state:
#   - x1 = 15 (0x0F)
#   - x2 = 6  (loop index after 5 iterations)
#   - x3 = 6  (loop bound)
#   - Data Memory word 1 (byte addr 4) = 15
#   - Total instructions executed: 19
# ==============================================================================

.text
.globl _start

_start:
    # 0x00: Initialization
    addi x1, x0, 0        # x1 = sum = 0        (0x00000093)
    addi x2, x0, 1        # x2 = i = 1          (0x00100113)
    addi x3, x0, 6        # x3 = bound = 6      (0x00600193)

loop:
    # 0x0C: Loop body
    add  x1, x1, x2       # sum = sum + i       (0x002080b3)
    addi x2, x2, 1        # i = i + 1           (0x00110113)

    # 0x14: Backward branch (jump back -8 bytes to 0x0C while i != 6)
    bne  x2, x3, loop     # if i != 6 goto loop (0xfe311ce3)

done:
    # 0x18: Store result into data memory word 1 (byte offset 4)
    sw   x1, 4(x0)        # mem[1] = sum = 15   (0x00102223)

halt:
    # 0x1C: Halt CPU
    beq  x0, x0, halt     # infinite loop       (0x00000063)
