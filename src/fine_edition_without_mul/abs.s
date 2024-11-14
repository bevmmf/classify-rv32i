.globl abs

.data
number_test:.word -5
.text
.globl main
main:
    la a0,number_test  
    jal abs
    add s0,a0,x0
    li a0, 1      # system call：print integer
    lw a1,0(s0)
    ecall
    # end
    li a0, 10           
    ecall
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue
    # Load number from memory
    
    lw t0 0(a0)
    ebreak
    bge t0, zero, done
    # TODO: Add your own implementation
    sub t1,x0,t0  #t1=-t0
    sw t1,0(a0)  #store t0 to a0
    jr ra
done:
    # Epilogue
    jr ra
