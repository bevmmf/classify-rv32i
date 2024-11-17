

.data
n1:.word 2
n2:.word 4
.text
main:
	lw a0,n1 
   	lw a1,n2  
    jal mul
    mv t2,a0
    li a0 1
    mv a1,t2
    ecall
    li a0 10
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

#abs()
#Args:
	#a0 (int )value
abs:
    bge a0, zero, positive_done
    sub a0,x0,a0  #t1=-t0
    jr ra
positive_done:
    jr ra