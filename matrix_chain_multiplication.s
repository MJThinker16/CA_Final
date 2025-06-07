.globl matrix_chain_multiplication
matrix_chain_multiplication:
    mv s6, ra
    mv s1, a0           # saved data in s1
    mv s7, a1
    mv s8, a2
    mv s9, a3
    addi s9, s9, -1
    li s3, 0
    lw s2, 0(s1)
loop_N:
    bge s3, s9, end_loop_N
    mv s5, s2
    li a0, 5300
    call malloc
    mv s2, a0        # s2 = base pointer for m[i][j]
    li t0, 0

loop_i:
    lw t1, 0(s7)          # t1 = rowA
    bge t0, t1, end_i     # if i >= rowA, break
    li t1, 0              # j = 0 (t1)

loop_j:
    slli s10, s3, 2       # s10 is the offset for number of matrices
    add s4, s10, s8       # s4 stores colA
    lw t2, 4(s4)

    bge t1, t2, end_j     # if j >= colB, break

    # index = i * colB + j
    mul t2, t0, t2
    add t2, t2, t1
    slli t2, t2, 2        # t2 = byte offset in result
    add t3, s2, t2
    sw zero, 0(t3)        # result[i * colB + j] = 0

    li t4, 0              # k = 0 (t4)
loop_k:
    lw t2, 0(s4)
    bge t4, t2, end_k     # if k >= colA, break

    # A[i * colA + k]
    mul t5, t0, t2
    add t5, t5, t4
    slli t5, t5, 2
    add t5, s5, t5
    lw t5, 0(t5)

    # B[k * colB + j]
    lw t2, 4(s4)
    mul t6, t4, t2
    add t6, t6, t1
    slli t6, t6, 2
    add t2, s1, s10
    lw t2, 4(t2)
    add t6, t2, t6
    lw t6, 0(t6)

    mul t5, t5, t6        # A[...] * B[...]

    lw t6, 0(t3)          # old result[i][j]
    add t6, t6, t5
    sw t6, 0(t3)          # store back

    addi t4, t4, 1
    j loop_k
end_k:
    addi t1, t1, 1
    j loop_j
end_j:
    addi t0, t0, 1
    j loop_i
end_i:
    addi s3, s3, 1
    j loop_N
end_loop_N:
    mv a0, s2
    mv ra, s6
    jr ra

