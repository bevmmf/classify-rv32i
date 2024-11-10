.globl relu
.globl print_array

.data
input_array: 
array:.word  -2, 0, 3, -1, 5 # array_test
size:.word 5
.text
main:
    la a0,array #send the array[0] address to a0 
    lw a1,size #send size to a1
    
    jal relu
    
    jal print_array
    # end
    li a0, 10      # system call：quit
    ecall
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
	
    li t0, 1             
    blt a1, t0, error     
    li t1, 0 #i=0             
	
    
loop_start:
    # TODO: Add your own implementation
	bge t1,a1,loop_done
	# get the elements in array(t1 for array index)
    slli t2,t1,2 #t1=4*i (shift for constant mutiplication)
    add t2,a0,t2 #t2=array pointer+4*i(address+4*i)=address_temp
    lw t3,0(t2) #load magnitude from address
    #
    blt t3,x0,set_zero #if the element less than 0
    addi t1,t1,1 #i++
    j loop_start

set_zero:
	sw x0,0(t2) #set 0 t0 address_temp
    addi t0,t0,1 #i++
    j loop_start
    
loop_done:
	jr ra
    
error:
    li a0,17
    li a1,36   
    ecall
    j exit     
exit:
	li a0 10  #quit
    ecall
#subfunction
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