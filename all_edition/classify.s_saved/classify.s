.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prolouge
    addi sp, sp, -48
    
    sw ra, 0(sp)
    
    sw s0, 4(sp) # m0 matrix
    sw s1, 8(sp) # m1 matrix
    sw s2, 12(sp) # input matrix
    
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
     
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
    # Read pretrained m1
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 8(a1) # set argument 1 for the read_matrix function  
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Read input matrix
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 12(a1) # set argument 1 for the read_matrix function  
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -48
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
          # Prologue - caller_saved 
    # addi sp, sp, -20       # create an area in stack
    sw ra, 28(sp)		  # save ra
    sw a0, 32(sp)         # save a0
    sw a1, 36(sp)          # save a1
    sw t0, 40(sp)          # save t0
    sw t1, 44(sp)          # save t1
    addi a0,t0,0          #input1_mul 
    addi a1,t1,0		  #input2_mul
    jal mul
    addi t2,a0,0          #t6=mul_value
        # Epilogue - caller_reload
    lw t1, 44(sp)          # reload t1
    lw t0, 40(sp)          # reload t0
    lw a1, 36(sp)          # reload a1
    lw a0, 32(sp)          # reload a0
    lw ra, 28(sp)          # reload ra 
    #addi sp, sp, 20        # release the area in stack
    addi a0,t2,0
    #
    #
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 48
    
    # Compute h = relu(h)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9 # move h to the first argument
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a1, t0, t1 # length of h array and set it as second argument
   
         # Prologue - caller_saved 
    # addi sp, sp, -20       # create an area in stack
    sw ra, 8(sp)		  # save ra
    sw a0, 12(sp)         # save a0
    sw a1, 16(sp)          # save a1
    sw t0, 20(sp)          # save t0
    sw t1, 24(sp)          # save t1
    addi a0,t0,0          #input1_mul 
    addi a1,t1,0		  #input2_mul
    
    jal mul
    addi t2,a0,0          #t6=mul_value
        # Epilogue - caller_reload
    lw t1, 24(sp)          # reload t1
    lw t0, 20(sp)          # reload t0
    lw a1, 16(sp)          # reload a1
    lw a0, 12(sp)          # reload a0
    lw ra, 8(sp)          # reload ra 
    #addi sp, sp, 20        # release the area in stack
    #
    addi a1,t2,0 
    # FIXME: Replace 'mul' with your own implementation
    
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    
    addi sp, sp, 28
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -48
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s6)
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
      # Prologue - caller_saved 
    #addi sp, sp, -20       # create an area in stack
    sw ra, 28(sp)		  # save ra
    sw a0, 32(sp)         # save a0
    sw a1, 36(sp)          # save a1
    sw t0, 40(sp)          # save t0
    sw t1, 44(sp)          # save t1
    addi a0,t0,0          #input1_mul 
    addi a1,t1,0		  #input2_mul
    jal mul
    addi t2,a0,0          #t6=mul_value
        # Epilogue - caller_reload
    lw t1, 44(sp)          # reload t1
    lw t0, 40(sp)          # reload t0
    lw a1, 36(sp)          # reload a1
    lw a0, 32(sp)          # reload a0
    lw ra, 28(sp)          # reload ra 
    #addi sp, sp, 20        # release the area in stack
     addi a0,t2,0
    #
    #
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0 # move o to s10
    
    mv a6, a0 # o
    
    mv a0, s1 # move m1 array to first arg
    lw a1, 0(s5) # move m1 rows to second arg
    lw a2, 0(s6) # move m1 cols to third arg
    
    mv a3, s9 # move h array to fourth arg
    lw a4, 0(s3) # move h rows to fifth arg
    lw a5, 0(s8) # move h cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 48
    
    # Write output matrix o
    addi sp, sp, -16
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -32
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10 # load o array into first arg
    lw t0, 0(s3)
    lw t1, 0(s6)
    #mul a1, t0, t1 # load length of array into second arg
         # Prologue - caller_saved 
    #addi sp, sp, -20       # create an area in stack
    sw ra, 12(sp)		  # save ra
    sw a0, 16(sp)         # save a0
    sw a1, 20(sp)          # save a1
    sw t0, 24(sp)          # save t0
    sw t1, 28(sp)          # save t1
    addi a0,t0,0          #input1_mul 
    addi a1,t1,0		  #input2_mul
    jal mul
    addi t2,a0,0          #t6=mul_value
        # Epilogue - caller_reload
    lw t1, 28(sp)          # reload t1
    lw t0, 24(sp)          # reload t0
    lw a1, 20(sp)          # reload a1
    lw a0, 16(sp)          # reload a0
    lw ra, 12(sp)          # reload ra 
    #addi sp, sp, 20        # release the area in stack
    addi a1,t2,0
    #
    # FIXME: Replace 'mul' with your own implementation
    
    jal argmax
    
    mv t0, a0 # move return value of argmax into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp 32
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4
    
    # Epilouge
epilouge:
    addi sp, sp, -4
    sw a0, 0(sp)
    
    mv a0, s0
    jal free
    
    mv a0, s1
    jal free
    
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s4
    jal free
    
    mv a0, s5
    jal free
    
    mv a0, s6
    jal free
    
    mv a0, s7
    jal free
    
    mv a0, s8
    jal free
    
    mv a0, s9
    jal free
    
    mv a0, s10
    jal free
    
    lw a0, 0(sp)
    addi sp, sp, 4

    lw ra, 0(sp)
    
    lw s0, 4(sp) # m0 matrix
    lw s1, 8(sp) # m1 matrix
    lw s2, 12(sp) # input matrix
    
    lw s3, 16(sp) 
    lw s4, 20(sp)
    
    lw s5, 24(sp)
    lw s6, 28(sp)
    
    lw s7, 32(sp)
    lw s8, 36(sp)
    
    lw s9, 40(sp) # h
    lw s10, 44(sp) # o
    
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit
#
mul:
	addi t0,x0,0 #i(t0)=0
    addi t1,x0,0 #mul_value(t1)=0
loop_mul:
    bge t0,a1,done_loop_mul
    add t1,t1,a0  #t1+=a0
    addi t0,t0,1  #i++
    j loop_mul
done_loop_mul:
	addi a0,t1,0 
	jr ra


#
