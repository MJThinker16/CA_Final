.text
.globl matrix_chain_multiplication

matrix_chain_multiplication:

    // Your implementation here


    addi sp sp -8
    sw ra 0(sp)
    sw s0 4(sp)

    #Load
    addi s0 a0 0 #An array storing the addresses of all matrice
    addi s1 a1 0 #An array storing the row size of each matrix.
    addi s2 a2 0 #An array storing the column size of each matr
    addi s3 a3 0 #An integer representing the number of matrice n
    # let row add col final 
DP:
    # Matrix m
    mul t0 s3 s3 #t0 = n*n
    slli t0 t0 2 #t0 = n*n*4
    
    addi a0 t0 0
    call malloc
    addi s4 a0 0 #s4 m_ptr
    
    #Matrix s
    addi a0 t0 0
    call malloc
    addi s5 a0 0 #s5 s_ptr

    addi t0 zero 0 #t0 = i_idx
    addi t1 s3 1 #t1 = n+1
    slli s6 s3 2 #s6 = n*4
ini_M:
    # initialize m[i,i] = 0 for(i = 0;i<n) m[i*n + i] = 0 

    mul t3 t0 t1  #t3  = i_idx*(n+1)
    add t3 t3 s4  #t3 = m[i*n + i]
    sw zero 0(t3) #m[i*n + i] = 0 

    addi t0 t0 4 #i_idx++ 
    bne s6 t0 ini_M #if i<n

    
    addi a2 zero 8 #a2 = l_idx = 2_idx(ini)
For_length:
    # for l in range 3~n  i: 0~n-l+1 k:i~j-1 m[i,j] = min(m[i,k]+ m[k+1,j] + rowi colk colj ), s[i,j] = k
    addi t0 a2 -4 #t0 = l-1_idx 
    
    addi s7 zero 0 #s7 = i_idx = 0(ini)
For_starti:
    add s8 s7 t0 #s8 = j_idx = i_idx + l_idx - 1
    
    mul t1 s7 s3 #t1 = s7*s3 = i_idx*n
    add t2 t1 s8 #t2 =  i*n + j
    add s9 t2 s4 #s9 = &m[i*n + j]    
    li t4 0x7FFFFFFF     
    sw t4 0(s9) #m[i*n + j] = 0x777777F  

    addi s10 s7 0 #s10 = k_idx = i_idx(ini)
    addi t3 s7 -4 #t3 = i-1_idx       
For_cutk:
    # (m[i][k]) + (m[k+1][j]) + row[i] col[k] col[j]
    add t4 t1 s10
    add t4 s4 t4   # t4 = &(m[i*n + k])
    addi t5 s10 4   # t5 = k+1_idx
    mul t5 t5 s3   # t5 = k+1_idx*n 
    add t5 t5 s8   # t5 = k+1_idx*n  + j_idx
    add t5 s4 t5   # t5 = &(m[k+1][j])
    lw t4 0(t4)    # t4 = (m[i*n + k])
    lw a0 0(t5)    # a0 = (m[k+1][j])
    
    add t5 s1 s7   # t5 = &row[i] 
    add t6 s2 s10  # t6 = &col[k]
    lw t5 0(t5)    # t5 = row[i]
    lw t6 0(t6)    # t6 = col[k]
    add s11 s2 s8  # s11 = &col[j]
    mul t5 t5 t6   # t5 = row[i] col[k]
    lw t6 0(s11)   # t6 = col[j]

    add t4 t4 a0   # t4 = (m[i][k]) + (m[k+1][j]) -- avoid stall
    
    mul t5 t5 t6   # t5 = row[i] col[k] col[j]
    add t4 t4 t5   # t4 = (m[i][k]) + (m[k+1][j]) + row[i] col[k] col[j]

    lw s11 0(s9)   # s11 = m[i*n + j]
    add t5 s5 t2   # t5 = &s[i*n + j]

    bgt t4 s11 End_cutk  #if (m[i][k]) + (m[k+1][j]) + row[i] col[k] col[j] >= m[i*n + j] branch  -- avoid stall

    sw t4 0(s9) # m[i*n + j]  = q
    srli t6 s10 2 #t6 = k
    sw t6 0(t5)  # s[i*n + j] = k
End_cutk:
    addi s10 s10 4 #k_idx++ 
    bne s10 s8 For_cutk #if k<=j-1

End_starti:
    addi s7 s7 4 #i_idx++
    sub t4 s6 t0 #n-(l-1)
    bne t4 s7 For_starti #if i<n-l+1

End_length:
    addi a2 a2 4 #l++ 
    bge s6 a2 For_length #if i<n

    

    # Return to main program after completion (Remember to store the return address at the beginning)
    lw s0 4(sp)
    lw ra 0(sp)
    addi sp sp 8
    jr ra

