.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # save arguments
    mv s1, a1        # s1 = matrix pointer
    mv s2, a2        # s2 = number of rows
    mv s3, a3        # s3 = number of columns

    li a1, 1

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)    # number of rows
    sw s3, 28(sp)    # number of columns

    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error
    
    # mul s4, s2, s3   # s4 = total elements
       # Prologue - caller_saved 
    addi sp, sp, -20       # create an area in stack
    sw ra, 16(sp)		  # save ra
    sw a0, 12(sp)         # save a0
    sw a1, 8(sp)          # save a1
    sw t0, 4(sp)          # save t0
    sw t1, 0(sp)          # save t1
    addi a0,s3,0          #input1_mul 
    addi a1,s2,0		  #input2_mul
    jal mul
    addi s4,a0,0          #t6=mul_value
        # Epilogue - caller_reload
    lw t1, 0(sp)          # reload t1
    lw t0, 4(sp)          # reload t0
    lw a1, 8(sp)          # reload a1
    lw a0, 12(sp)          # reload a0
    lw ra, 16(sp)          # reload ra 
    addi sp, sp, 20        # release the area in stack
    #
    # FIXME: Replace 'mul' with your own implementation

    # write matrix data to file
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    bne a0, s4, fwrite_error

    mv a0, s0

    jal fclose

    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra

fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
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