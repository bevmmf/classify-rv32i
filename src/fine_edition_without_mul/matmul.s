.globl matmul


.data
input_array: 
matrix1:.word 1, 2, 3, 4, 5 ,6 # matrix1_test
matrix2:.word 2, 4, 6, 8, 10 ,12 # matrix2_test
matrix1_row_number:.word 2
matrix1_column_number:.word 3
matrix2_row_number:.word 3
matrix2_column_number:.word 2
matrix3:
.text
main:
    #prepare the input of function
    la a0,matrix1 #send the array1[0](M0) address to a0 
    lw a1,matrix1_row_number #to a2
    lw a2,matrix1_column_number #to a3
    
    la a3,matrix2 #send the array2[0](M1) address to a1 
    lw a4,matrix2_row_number #to a4
    lw a5,matrix2_column_number #to a5
    
    la a6,matrix3  # D
    #save static data
    add s0,a0,x0
    add s1,a1,x0
    add s2,a2,x0
    add s3,a3,x0
    add s4,a4,x0
    add s5,a5,x0
    add s6,a6,x0
    #
    jal matmul
    #print an matrix 
    add a0,s6,x0 #a0=matrix3_base_address
    
    #mul t6,s1,s5 
    # Prologue - caller_saved 
    addi sp, sp, -20       # create an area in stack
    sw ra, 16(sp)		  # save ra
    sw a0, 12(sp)         # save a0
    sw a1, 8(sp)          # save a1
    sw t0, 4(sp)          # save t0
    sw t1, 0(sp)          # save t1
    addi a0,s5,0          #input1_mul 
    addi a1,s1,0		  #input2_mul
    jal mul
    addi t6,a0,0          #t6=mul_value
    # Epilogue - caller_reload
    lw t1, 0(sp)          # reload t1
    lw t0, 4(sp)          # reload t0
    lw a1, 8(sp)          # reload a1
    lw a0, 12(sp)          # reload a0
    lw ra, 16(sp)          # reload ra 
    addi sp, sp, 20        # release the area in stack
    #
    #
    
    add a1,x0,t6 #a1=matrix_size=matrix1_row_number*matrix2_column_number
    jal print_array
  
    # end
    li a0, 10      # system call�Gquit
    ecall
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 ? M1
# Where:
#   - M0 is a (rows0 ? cols0) matrix
#   - M1 is a (rows1 ? cols1) matrix
#   - D is a (rows0 ? cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count(n)
#     a2: Column count(m)
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count(k)
#     a5: Column count(L)
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
#main function
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    #a1=1_row  a2=1_column  a4=2_row  a5=2_column
    li s0, 0 # outer loop counter(i)
    li s1, 0 # inner loop counter(j)
    mv s2, a6 # incrementing result matrix pointer#(matrix3_base address) to s2 
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop#(matrix1_base address) to s3
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop# (matrix2_base address) to s4
    
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    

    blt s0, a1, inner_loop_start  # i<1_row
    j outer_loop_end
outer_loop_end:
	#no output
    # Epilogue - reload reg_s and return
    lw ra, 0(sp)           # reload 
    lw s0, 4(sp)           # reload 
    lw s1, 8(sp)           # reload 
    lw s2, 12(sp)          # reload 
    lw s3, 16(sp)          # reload 
    lw s4, 20(sp)          # reload 
    lw s5, 24(sp)          # reload 
    lw s6, 28(sp)          # reload 
    
    addi sp, sp, 32        # release the area in stack
    #
    ret

inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    #[
    #1_row_base_address(m1[i_row][])=1_base_address+[4(bytes)*i]*m
    slli t0,s0,2 #i*4
    
    mul t2,t0,a2 #m*(4i) #a2 not sure still 1_col
   
    #
    
    add t2,s3,t2 #1_address_m1[i_row](1_pointer)=1_base_address+[4(bytes)*i]*m=t0
     
    #
    #2_column_address(m2[][j_column])=2_base_address+[4(bytes)*j]
    slli t1,s1,2 #j*4
    add t1,s4,t1 #2_address_m2[j_column](2_pointer)=2_base_address+[4(bytes)*j]=t3
    #]    
    #
    mv a0, t2 # setting pointer for matrix A into the correct argument value
    mv a1, t1 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A (a2=1_col)
    li a3, 1 # stride for matrix A 
    mv a4, a5 # stride for matrix B (a5=2_col)
    
    jal dot
    
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    # store the value in matrix3(D[i][j])
    
    mul t6,s0,a5  #t1=i*L
    
    #
    
    add t6,t6,s1  #t1=j+i*L
    slli t6,t6,2  #t1=4*(j+i*L)=D_offset
    add t2,s2,t6  #t2=D_pointer=D_base address+offset
    sw t0, 0(t2)   # store dot_value to M_result pointer

    
    addi s1, s1, 1  #j++
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation
	li s1, 0   #initialize j=0
    addi s0,s0,1 #i++
    j outer_loop_start


error:
    li a0, 17 
    li a1, 38
    ecall
    j exit
exit:
	li a0 10
    ecall
# subfunction 1:dot (use: a0~a4 t0~t6)
dot: 
	# Prologue - callee_saved
    addi sp, sp, -20       # create an area in stack
       
    sw ra, 16(sp)
    sw s0, 12(sp)		  # save s0
    sw s2, 8(sp)		  # save s2
    sw s3, 4(sp)		  # save s3
    sw s4, 0(sp)		  # save s4
    
    #
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate
    #save a2�Ba3�Ba4
	addi s2,a2,0
    addi s3,a3,0
    addi s4,a4,0
    
    addi t0,x0, 0     #i=0 (index for array1)
    addi t1,x0, 0     #j=0 (index for array2)
	addi s0,x0, 0     #dot_value
loop_start:
    bge t0, s2, loop_end
    # TODO: Add your own implementation
	  # get the elements in array1�Barray2
    #load array1[i] value
    slli t2,t0,2 #t2=4*i (shift for constant mutiplication)
    add t2,a0,t2 #t2=array1 pointer+4*i(address+4*i)
    lw t3,0(t2) #t3=load array1[i] value from address
    #load array2[j] value
    slli t4,t1,2 #t4=4*j
    add t4,a1,t4 #t4=array2 pointer+4*j(address+4*j)
    lw t5,0(t4) #t5=load array2[j] value from address
    mul t6,t3,t5
    #mul fixed
    
    #
    add s0,s0,t6 #s0(dot product value)+=t6
    add t0,t0,s3 #i++ stride1
    add t1,t1,s4 #j++ stride2
    j loop_start
loop_end:
    addi a0, s0 ,0 #a0(output)=t0
    # Epilogue - callee_reload
 	lw s4, 0(sp)          # reload s0
    lw s3, 4(sp)          # reload s0
    lw s2, 8(sp)          # reload s0
    lw s0, 12(sp)          # reload s0
    lw ra, 16(sp)          # reload s0
    

    addi sp, sp, 20        # release the area in stack
    #
    jr ra
	
error_terminate:
    blt a2, t0, set_error_36
    li a0, 17
    li a1, 37
    ecall
    
    j exit

set_error_36:
    li a0, 17
    li a1, 36
    ecall
    j exit_dot
exit_dot:
	li a0, 10 
    ecall



# subfunction 2:print_array (use t0~t2�Bt5~t6�Ba0~a1)
print_array:
    mv t6,a0 #array pointer in t6
    mv t5,a1 #size in t5
    addi t0,x0,0 #i=0
    loop_print:
        bge t0,t5,done_print
        li a0,1  #print integer
        
        # get the elements in array(t1 for array index)
        slli t1,t0,2 #t1=4*i (shift for constant mutiplication)
        add t1,t6,t1 #t2=array pointer+4*i(address+4*i)
        lw t2,0(t1) #load magnitude from address
        mv a1,t2 #prepare to output integer
        ecall
        
        #\n
        li a0, 11         # system call 11：print char
        li a1, 32         # ASCII 32 =' '
        ecall             #
        
        addi t0,t0,1 #i++
        j loop_print
     
     done_print:
         ret  
  
# subfunction 3:mul (use:t0�Bt1�Ba0�Ba1)
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