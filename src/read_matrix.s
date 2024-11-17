.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:
    
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s3, a1         # save and copy rows
    mv s4, a2         # save and copy cols

    li a1, 0

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file

    # read rows n columns
    mv a0, s0
    addi a1, sp, 28  # a1 is a buffer

    li a2, 8         # look at 2 numbers

    jal fread

    li t0, 8
    bne a0, t0, fread_error

    lw t1, 28(sp)    # opening to save num rows
    lw t2, 32(sp)    # opening to save num cols

    sw t1, 0(s3)     # saves num rows
    sw t2, 0(s4)     # saves num cols

     #mul s1, t1, t2   # s1 is number of elements
    # FIXME: Replace 'mul' with your own implementation
    
   # Prologue - caller_saved 
    addi sp, sp, -20      # create an area in stack
    sw a0, 0(sp)         # s
    sw a1, 4(sp)          # 
    sw t4, 8(sp)          # 
    sw t5, 12(sp)          # 
    sw t6, 16(sp)          # 
    
    addi a0,t1,0
    addi a1,t2,0
    jal mul
    addi s1,a0,0
    # Epilogue - caller_reload
    lw a0, 0(sp)          # 
    lw a1, 4(sp)          # 
    lw t4, 8(sp)          # 
    lw t5, 12(sp)          # 
    lw t6, 16(sp)          # 
    
    addi sp, sp, 20       # release the area in stack
    #
    #
    slli t3, s1, 2
    sw t3, 24(sp)    # size in bytes

    lw a0, 24(sp)    # a0 = size in bytes

    jal malloc

    beq a0, x0, malloc_error

    # set up file, buffer and bytes to read
    mv s2, a0        # matrix
    mv a0, s0
    mv a1, s2
    lw a2, 24(sp)

    jal fread

    lw t3, 24(sp)
    bne a0, t3, fread_error

    mv a0, s0

    jal fclose

    li t0, -1

    beq a0, t0, fclose_error

    mv a0, s2

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40

    jr ra

malloc_error:
    li a0, 26
    j error_exit

fopen_error:
    li a0, 27
    j error_exit

fread_error:
    li a0, 29
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
    addi sp, sp, 40
    j exit

#mul(a0,a1,t4,t5,t6)
mul:
	
    # Prologue
    #
    li t6, 0   #t6=value_mul 
    li t5, 0   #t5=sign_mul 
    xor t5,a0,a1  #tell  if same sign or diff sign(same=0)(diff=1)
    srli t5,t5,31 #take the sign bit 
    #abs(rs2)
    mv t4,a0 #save a0
    mv a0,a1
    #caller_saved_pro
    addi sp,sp,-4
    sw ra,0(sp)
    #
    jal abs 
    mv a1,a0 #a1=abs(rs2)
    #abs(rs1)
    mv a0,t4
    jal abs  #a0=abs(rs1)
    #caller_saved_epi
    lw ra,0(sp)
    addi sp,sp,4
    #
    li t4,0    #i(t4)=0
	beq t5,x0,same_loop_start #if the value_mul is postive
oppo_loop_start:
    #mul_value(t6)=0
    bge t4,a1,oppo_loop_end
    add t6,t6,a0  #t6+=a0
    addi t4,t4,1  #i++
    j oppo_loop_start
oppo_loop_end:
	sub a0,x0,t6 #a0=-t6
    # epilogue
	jr ra	
same_loop_start:
    #mul_value(t6)=0
    bge t4,a1,same_loop_end
    add t6,t6,a0  #t6+=a0
    addi t4,t4,1  #i++
    j same_loop_start
same_loop_end:
	addi a0,t6,0 
    # epilogue
	jr ra	

#abs()
#Args:
	#a0 (int )value
abs:
    bge a0, zero, positive_done
    sub a0,x0,a0  #t1=-t0
    jr ra
positive_done:
    jr ra