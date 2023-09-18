.set noreorder
.set noat
.globl __start
.section text

__start:
.text


    # $a0 - start address of A
    # $a1 - start address of B
    # $a2 - start address of C
    # $s0 - arrary length
    # $s1 - loop counter
    # $s2 - 0x11111111


    ori     $s0, $zero, 0x1         # s0 = 0x100000
    sll     $s0, $s0, 0x14
    ori     $s1, $zero, 0x0         # s1 = 0x0
    lui     $s2, 0x1111
    addiu   $s2, $s2, 0x1111        # s2 = 0x11111111

    lui     $a0, 0x8040             # a0 = 0x80400000
    lui     $a1, 0x8050             # a1 = 0x80500000
    lui     $a2, 0x8060             # a2 = 0x80600000

loop:
    # loop body

    lw      $t0, 0($a0)             # load a[i]    
    lw      $t1, 0($a1)             # load b[i]

# caculate mod
mod:
    xor     $t3, $t0, $t1           # a ^ b
    beq     $t3, $zero, aeb         # a = b
    ori     $zero, $zero, 0x0       # nop

    
    ori     $t4, $t0, 0x0
    ori     $t5, $t1, 0x0

compare_loop:
    and     $t6, $t4, $t5           # a & b

    beq     $t6, $zero, stage2
    ori     $zero, $zero, 0x0       # nop

stage1:
    xor     $t4, $t4, $t6
    xor     $t5, $t5, $t6

    beq     $t4, $zero, alb
    ori     $zero, $zero, 0x0       # nop

    beq     $t5, $zero, agb
    ori     $zero, $zero, 0x0       # nop

stage2:
    srl     $t4, $t4, 0x1
    srl     $t5, $t5, 0x1

    beq     $t4, $zero, alb
    ori     $zero, $zero, 0x0       # nop

    beq     $t5, $zero, agb
    ori     $zero, $zero, 0x0       # nop

    j       stage2
    ori     $zero, $zero, 0x0       # nop


aeb:
# a = b
    ori     $t2, $zero, 0x0
    j       store
    ori     $zero, $zero, 0x0       # nop

alb:
# a < b
    ori     $t2, $t0, 0x0
    j       store
    ori     $zero, $zero, 0x0       # nop

agb:
# a > b     a mod b = (a-b) mod b
#    div     $t0, $t0, $t1
#    j       mod
#    ori     $zero, $zero, 0x0       # nop

    xor     $t7, $t1, $s2
    addiu   $t7, $t7, 0x1
    addu    $t0, $t0, $t7

    j       mod
    ori     $zero, $zero, 0x0       # nop


store:
    sw      $t2, 0($a2)             # store c[i]

    addiu   $a0, $a0, 0x4
    addiu   $a1, $a1, 0x4
    addiu   $a2, $a2, 0x4
    addiu   $s1, $s1, 0x4           # s1 += 4
    bne     $s1, $s0, loop
    ori     $zero, $zero, 0x0       # nop


end:
    jr      $ra
    ori     $zero, $zero, 0         # nop