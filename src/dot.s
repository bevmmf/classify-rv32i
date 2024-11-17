.globl dot


.data
array1:.word 1,2,3,4,5,6,7,8,9 # array1_test
array2:.word 1,2,3,4,5,6,7,8,9  # array2_test
size:.word 3 
stride1:.word 1
stride2:.word 2
.text
main:
    #prepare the input of function
    la a0,array1 #send the array1[0] address to a0 
    la a1,array2 #send the array2[0] address to a1 
    lw a2,size #send size1 to a2
    lw a3,stride1 #send stride1 to a3
    lw a4,stride2 #send stride2 to a4
        
    
    jal dot
    #print a number
    mv a1,a0
    li a0,1
    mv a1,a1 
    ecall 
    # end
    li a0, 10      # system call：quit
    ecall

# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   stride1(Skip distance in first array)
#   a4 (int):   stride2(Skip distance in second array)
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
#main function
dot:
	# Prologue - callee_saved
    addi sp, sp, -20       # create an area in stack
    sw ra, 0(sp)
    sw s0, 4(sp)		  # save s0
    sw s2, 8(sp)		  # save s2
    sw s3, 12(sp)		  # save s3
    sw s4, 16(sp)		  # save s4
    
    #
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate
    #save a2、a3、a4
	addi s2,a2,0
    addi s3,a3,0
    addi s4,a4,0
    
    addi t0,x0, 0     #i=0 (index for array1)
    addi t1,x0, 0     #j=0 (index for array2)
	addi s0,x0, 0     #dot_value
loop_start:
    bge t0, s2, loop_end
    # TODO: Add your own implementation
	  # get the elements in array1、array2
    #load array1[i] value
    slli t2,t0,2 #t2=4*i (shift for constant mutiplication)
    add t2,a0,t2 #t2=array1 pointer+4*i(address+4*i)
    lw t3,0(t2) #t3=load array1[i] value from address
    #load array2[j] value
    slli t4,t1,2 #t4=4*j
    add t4,a1,t4 #t4=array2 pointer+4*j(address+4*j)
    lw t5,0(t4) #t5=load array2[j] value from address
    #mul t6,t3,t5
    #mul fixed
      # Prologue - caller_saved 
    addi sp, sp, -20       # create an area in stack
    sw t4, 16(sp)		  # save ra
    sw a0, 12(sp)         # save a0
    sw a1, 8(sp)          # save a1
    sw t5, 4(sp)          # save t0
    addi a0,t3,0
    addi a1,t5,0
    jal mul
    addi t6,a0,0
    # Epilogue - caller_reload
    lw t5, 4(sp)          # reload t0
    lw a1, 8(sp)          # reload a1
    lw a0, 12(sp)          # reload a0
    lw t4, 16(sp)          # reload ra 
    addi sp, sp, 20        # release the area in stack
    #
    #
    add s0,s0,t6 #s0(dot product value)+=t6
    add t0,t0,s3 #i++ stride1
    add t1,t1,s4 #j++ stride2
    j loop_start
loop_end:
    addi a0, s0 ,0 #a0(output)=t0
    # Epilogue - callee_reload
 	lw s4, 16(sp)          # reload s0
    lw s3, 12(sp)          # reload s0
    lw s2, 8(sp)          # reload s0
    lw s0, 4(sp)          # reload s0
    lw ra, 0(sp)

    addi sp, sp, 20        # release the area in stack
    #
    jr ra
	
error_terminate:
    blt a2, t0, set_error_36
    li a0, 17
    li a1, 37
    ecall
    
    j exit_dot

set_error_36:
    li a0, 17
    li a1, 36
    ecall
    j exit_dot
exit_dot:
	li a0, 10 
    ecall


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

#abs
#Args:
	#a0 (int )value
abs:
    bge a0, zero, positive_done
    sub a0,x0,a0  #t1=-t0
    jr ra
positive_done:
    jr ra
