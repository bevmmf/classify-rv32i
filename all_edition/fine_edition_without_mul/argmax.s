.globl argmax
.data
#input
array_test:.word   
size:.word 0 
.text
main:
    la a0,array_test #send the array_base_address to a0 
    lw a1,size #send size value to a1
    
    jal argmax
    
    #print an int
    addi a1,a0,0 #a1=output(argmax)
    li a0,1     
    addi a1,a1,0 
    ecall 
    # end
    li a0, 10      # system call：quit
    ecall
    
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Prologue - save reg_s
    addi sp, sp, -4       # create an area in stack
    sw ra, 0(sp)          # save ra
    #
    li t6, 1
    blt a1, t6, handle_error #check if a empty array
    
    addi t0,a0,0    #t0=array_base_address
    addi t3,a1,0    #t3=array_size
    li t1, 0       #i = 0    
    li t5, 0       #t5 = index_max =0(init)
    li t2, 0       #t2 = max_value
loop_start:
    # TODO: Add your own implementation
    bge t1,t3,loop_done
    #get the elements in array(i(t1) for array index)
    slli t6,t1,2 #t1=4*i (shift for constant mutiplication)
    add t6,t0,t6 #t3=array pointer+4*i(address+4*i)=address_temp
    lw t4,0(t6) #load magnitude from address
    blt t2,t4,replace_max #if the element greater than max(t2)
    addi t1,t1,1 #i++
    j loop_start
replace_max:
    addi t2,t4,0 #reg_max(t2)=current element
    addi t5,t1,0 #put index i of the max to t5(index_max)  
    addi t1,t1,1 #i++
    j loop_start
loop_done:
    addi a0,t5,0  #output t5(index_max)
    # Epilogue - reload reg_s and return
    lw ra, 0(sp)          # reload ra
    addi sp, sp, 4        # release the area in stack
    
    jr ra
handle_error:
    
    li a0,17
    li a1,36
    ecall
    j exit

exit:
    ebreak
    li a0 10  #quit
    ecall
