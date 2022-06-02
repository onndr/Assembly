#-------------------------------------------------------------------------------
#author       : Andrii Gamalii
#description  : RISC-V - Read, modify and display the input string
#-------------------------------------------------------------------------------


	.data
#bottom:	.ascii "a"
#top: 	.ascii "z"
#symbol:	.ascii "*"
input:	.space 80
prompt:	.asciz "\nInput string       > "
msg1:	.asciz "\nConversion results > "
msg2:   .asciz "\nReturn value	> "

	.text
# ============================================================================
main:
#display the input prompt
    li a7, 4		#system call for print_string
    la a0, prompt	#address of string
    ecall

#read the input string
    li a7, 8		#system call for read_string
    la a0, input	#address of buffer
    li a1, 80    	#max length
    ecall

#modify your string here
#...

    li a7, 4
    la a0 msg1
    ecall

#display the length prompt
    li a7, 4		#system call for print_string
    la a0, msg2		#address of string
    ecall
#get length of string
    la a0, input
    jal	strlen
#print length
    li a7, 1		#system call for print_int
    ecall

#display the results prompt
    mv a1, a0		#save length of string

    li a7, 4		#system call for print_string
    la a0, msg1		#address of string
    ecall
#reverse string
    la a0, input
    jal	reverse
#print the results
    li a7, 4		#system call for print_string
    la a0, input		#address of string
    ecall


exit:
    li 	a7,10	#Terminate the program
    ecall
# ============================================================================
strlen:
# arguments:
#    a0 - address
# return value:
#    a0 - length of the string

#addi sp, sp, -4
#sw ra, 0 (sp)

# count = 0; -> t1
# string - wskazanie na bie��cy znak �a�cucha -> t2
# while (*string != "\0") {
# string ++;
# count ++;
# }
    li t1, 0
    mv t2, a0
loop:
    lbu t3, (t2)
    beqz t3, loop_exit
    addi t1, t1, 1
    addi t2, t2, 1
    j loop

loop_exit:
    addi t1, t1, -1
    mv a0, t1


#lw ra,0 (sp)
#addi sp, sp, 4
    jr ra

replace:
    li t1, 0
    mv t2, a0
    li t4, 'z'
    li t5, 'a'
    li t6, '*'
    addi a0, a0, -1

replace_loop:
    addi a0, a0, 1
    lbu t3, (a0)
    beqz t3, end_replace_loop
    bgt	t3, t4, replace_loop
    blt t3, t5, replace_loop
    sb	t6, (a0)
    addi t1, t1, 1
    j	replace_loop

end_replace_loop:
    mv	a0, t1
    jr	ra


reverse:
#iterating from the end of string
#a0 - first byte of string, a1 - length of string
    #srli t2, a1, 1	#counter
    li t2, 0
    add	t0, a0, t2	#from left
    add t1, a0, a1	#end of string

reverse_loop:
    lb	t3, (t0)
    lb	t4, (t1)
    sb	t3, (t1)
    sb	t4, (t0)
    addi t0, t0, 1
    addi t1, t1, -1
    addi t2, t2, 2
    ble t2, a1, reverse_loop

end_reverse_loop:
    jr	ra


# ============================================================================
#end of file
