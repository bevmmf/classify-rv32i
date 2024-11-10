.globl dot
.globl mul

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
    addi sp, sp, -16       # create an area in stack
    sw s0, 12(sp)		  # save s0
    sw s2, 8(sp)		  # save s2
    sw s3, 4(sp)		  # save s3
    sw s4, 0(sp)		  # save s4
    
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
    #mul
    # Prologue - caller_saved 
    addi sp, sp, -20       # create an area in stack
    sw ra, 16(sp)		  # save ra
    sw a0, 12(sp)         # save a0
    sw a1, 8(sp)          # save a1
    sw t0, 4(sp)          # save t0
    sw t1, 0(sp)          # save t1
    addi a0,t3,0          #input1_mul 
    addi a1,t5,0		  #input2_mul
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
    
    addi sp, sp, 16        # release the area in stack
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
    j exit
exit:
	li a0, 10 
    ecall
#subfunction1:mul
#arguments:
# a0=number_1   ex:2
# a1=number_2   ex:3
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