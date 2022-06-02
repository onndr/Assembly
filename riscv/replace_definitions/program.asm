#-------------------------------------------------------------------------------
#author: Andrii Gamalii
#date : 2022.05.26
#description : Replace symbols from file with their definitions, removing those definitions from output file
#-------------------------------------------------------------------------------		
		.eqv	EXIT_SYS, 10
		.eqv	OPEN_SYS, 1024
		.eqv	READ_SYS, 63
		.eqv	WRITE_SYS, 64
		.eqv	BUF_SIZE, 512
		.eqv	BIG_BUF_SIZE, 8192
		.eqv	READ_FLAG, 0
		.eqv	WRITE_FLAG, 1
	.data
error_op:	.asciz	"Error: failed to open a file."
error_rd:	.asciz	"Error: failed to read from a file"
error_wr:	.asciz	"Error: failed to write to a file"
inputf:		.asciz	"wejscie.txt"
outputf:	.asciz	"wyjscie.txt"
buf_in:		.space	BUF_SIZE
buf_line:	.space	BIG_BUF_SIZE
buf_text:	.space	BIG_BUF_SIZE
buf_defs:	.space	BIG_BUF_SIZE
buf_word: 	.space	BIG_BUF_SIZE
buf_out:	.space	BUF_SIZE
	.text
main:
#use of registers:
#a0 - for value of current ascii symbol
#a1 - is_eof flag
#a3 - is 100% text line
#a4 - holds dile descriptor for getc procedure
#a5 - next char pointer in getc procedure
#a6 - chars left in getc buffor
#a7 - loading values for system calls

#t0 - pointer to buf_line
#t1 - is line with definition flag
#t2 - for different temp ascii values
#t3 - is definition started
#t4 - pointer to buf_text
#t5 - pointer to buf_defs
#t6 - used when writing a line, holds t5 if t1 else t4
#open input file:
  	la	a0, inputf		#path to the input file
  	li   	a1, READ_FLAG		#set flag to read-only
  	li   	a7, OPEN_SYS		#set system command number
  	ecall
  	bltz 	a0, error_open		#check if returned value is correct
#save file descriptor for using getc
	mv	a4, a0			# move file descriptor to a4
#prepare pointers and eof flag
	la	t4, buf_text		# buffer with text
	la	t5, buf_defs		# buffer with definitions
	li	a1, 0			# is_eof = false
loop_divide_new_line:
	la	t0, buf_line
	li	t1, 0
	li	a3, 0
	li	t3, 0
loop_divide:
	jal	getc
	li	t2, ' '			
	beq	a0, t2, case_space
	li	t2, ':'	
	beq	a0, t2, case_colon
	li	t2, '\n'
	beq	a0, t2, case_eol	#case end of line
	li	t2, 127
	bgtu	a0, t2, case_eol		#case end of file
	beqz	a0, case_eol		#case end of file
put_char:
	bnez	t1, is_def_started
put_char_line_buf:
	sb	a0, (t0)
	addi	t0, t0, 1
	j 	loop_divide
is_def_started:
	li	t2, ' '
	beq	a0, t2, loop_divide
	li	t3, 1
	j	put_char_line_buf
case_space:
	beqz	t1, set_text_line_flag
	beqz	t3, loop_divide
	j	put_char_line_buf
set_text_line_flag:
	li	a3, 1
	j	put_char_line_buf
case_colon:
	bnez	a3, put_char_line_buf
	li	t1, 1
	j	put_char_line_buf
put_line_to_defs:
	mv	t6, t5
go_put_line:
	la	t0, buf_line
put_line:
	lbu	a0, (t0)
	li	t2, 255			# -1 in U2 (returned by getc when EOF)
	beq	a0, t2, eof_eol
	sb	a0, (t6)
	addi	t0, t0, 1
	addi	t6, t6, 1
	beqz	a0, eof_eol
	li	t2, '\n'
	bne	a0, t2, put_line
put_line_end:
	bnez	t1, remove_spaces_from_end_def
	mv	t4, t6
	j	loop_divide_new_line
eof_eol:
	sb	zero, (t6)
	addi	t6, t6, 1
	beqz	t1, eof
remove_spaces_from_end_def:
	lbu	a0, (t6)
	li	t2, 32
	addi	t6, t6, -1
	bleu	a0, t2,	remove_spaces_from_end_def
put_semicolon_def:
	addi	t6, t6, 2
	li	t2, ';'
	sb	t2, (t6)
	addi	t6, t6, 1
	mv	t5, t6
	j	loop_divide_new_line
case_eol:
	sb	a0, (t0)
case_eol_dont_store_last_byte:
	bnez	t1, put_line_to_defs
	la	t0, buf_line
	mv	t6, t4
	j	put_line
eof:
#open file to write
	la	a0, outputf		#path to the input file
  	li   	a1, WRITE_FLAG		#set flag to read-only
  	li   	a7, OPEN_SYS		#set system command number
  	ecall
  	bltz 	a0, error_open		#check if returned value is correct
	mv	a4, a0
#use of registers:
#t0 - pointer to buf_text
#t1 - pointer to buf_defs
#t2 - for different ascii values
#t5 - pointer to buf_word

#a0 - current char
#a2 - pointer to buf_out for putc procedure
#a3 - counter of free bytes left in putc buffer
#a4 - file descriptor for putc
	la	a2, buf_out
	li	a3, BUF_SIZE
	la	t0, buf_text
	la	t1, buf_defs
	la	t5, buf_word
	li	t3, 0			#flag word started
	li	a5, 0			#eof flag
before_take_word:
	la	t5, buf_word	 	#load buf_word pointer
take_word:
	bnez	a5, putc_and_exit
	lbu	a0, (t0)
	addi	t0, t0, 1
	beqz	a0, eo_buf_text		#found NULL
	
	li	t2, ' '
	bleu	a0, t2, write_out	#write any sign that is not 'visible' or is whitespace
	
	sb	a0, (t5)
	addi	t5, t5, 1
	li	t3, 1
	bgtu	a0, t2, take_word	#jump to take_word if char was less not ' '
eo_buf_text:
	li	a5, 1
	beqz	t3, write_out
word_ended:
	sb	zero, (t5)
	la	t1, buf_defs
#find_word_in_buf_def
before_compare_word_and_symbol:
	la	t5, buf_word
compare_word_and_symbol:
	lbu 	t6, (t5)
	addi	t5, t5, 1
	lbu	a0, (t1)
	addi	t1, t1, 1	
	beqz	a0, write_word
	beq	a0, t6, compare_word_and_symbol		#loop if chars from word and symbol are equal
	bnez	t6, go_next_def
	li	t2, ':'
	bne	a0, t2, go_next_def
before_write_def:
	la	t5, buf_word
write_def:
	lbu	a0, (t1)
	addi	t1, t1, 1
	li	t2, ';'	
	beq	a0, t2, end_def_write
	sb	a0, (t5)
	addi	t5, t5, 1
#if definition not ended(c != ';', then buf_word still doesn't contain definition, need to loop)
	beqz	a0, end_def_write
	j	write_def
go_next_def:
	lbu	a0, (t1)
	addi	t1, t1, 1
	beqz	a0, write_word
	li	t2, ';'
	beq	a0, t2, before_compare_word_and_symbol
	j	go_next_def
end_def_write:
	sb	zero, (t5)
write_word:
	addi	t0, t0, -1
	li	t3, 0
	la	t5, buf_word
write_word_loop:
	lbu	a0, (t5)
	addi	t5, t5, 1
	beqz	a0, before_take_word
	jal	putc
	j	write_word_loop
write_out:
	bgtz	t3, word_ended		#if word was ended, then dont write now
	jal	putc
	j	take_word
#get char from file (buffered)
#	a7 - system calls codes
#	a6 - symbols left counter
#	a5 - symbol pointer
#	a4 - file descriptor
#	a0 - return char
getc:
	beqz	a6, read		# if counter = 0, then no chars left to read from buffer, read file
	lbu	a0, (a5)		# else there are chars, load char from pointer
	addi	a5, a5, 1		# increment pointer
	addi	a6, a6, -1		# decrement counter
	jr	ra			# return
getc_zero:
	li	a0, -1			# end of file flag
	jr	ra			# return 
# system read from file to buf_in
read:
	mv	a0, a4
  	la	a1, buf_in		# address of buffer to write to
  	li	a2, BUF_SIZE		# max length to read from file
  	li   	a7, READ_SYS		# set system command number
  	ecall
  	bltz 	a0, error_read		# check if returned value is correct
  	mv	a6, a0			# set counter to length of read string
  	beqz	a0, getc_zero		# if was 0, then file ended, goto getc_zero 
  	la	a5, buf_in		# load start of buf_in
  	j	getc			# return to getc
#put char to file (buffered)
#	a7 - system calls codes
#	a4 - file descriptor
#	a3 - bytes left counter
#	a2 - pointer
#	a1 - system call parametre
#	a0 - char to write
putc:
	beqz	a3, write
	sb	a0, (a2)
	addi	a2, a2, 1
	addi	a3, a3, -1
	beqz	a0, write
	jr	ra
#system write from buf_out to file
write:
	mv	t6, a0			# save char to write
	mv	a0, a4			# move file descriptor
	la	a1, buf_out		# load buffer from which to write
	li	a2, BUF_SIZE		# load max size of buffer
	sub	a2, a2, a3		# substract size of empty bytes
	li	a7, WRITE_SYS		# load system command to write
	ecall				# call system
	bne	a2, a0, error_write	# error if length of written not equal to number of chars to be written
	beqz	t6, exit		# exit if last written char was 0
	la	a2, buf_out		# return to the start of buf_out
	li	a3, BUF_SIZE		# available bytes = size of buffer
	mv	a0, t6			# return saved char
	j	putc			# return to putc
error_open:
	li   	a7, 4
	la	a0, error_op
	ecall
	j	exit
error_read:
	li   	a7, 4
  	la   	a0, error_rd
  	ecall
  	j	exit
error_write:
	li   	a7, 4
  	la   	a0, error_wr
  	ecall
putc_and_exit:
	mv	a0, zero
	jal	putc
exit:
    	li	a7, EXIT_SYS
    	ecall
