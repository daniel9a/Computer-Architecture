	addi	$1, $0, 1	# $1 = 1
	ori	$2, $1, 2	# $2 = 3
	andi	$3, $2, -2	# $3 = 2
	add	$4, $1, $2	# $4 = 1 + 3 = 4
	sub	$5, $4, $3	# $5 = 4 - 2 = 2
	and	$6, $1, $2	# $6 = 1
	sw	$2, 100($4)	# memory[100 + 4] = 3
	lw	$7, 100($4)	# $7 = memory[100 + 4] = 3
	slt	$8, $1, $7	# $8 = 1 < 3 = 1
	or	$9, $4, $2	# $9 = 7
	nor	$10, $1, $3	# $10 = -4
	jal	begin	# $31 = 48
	addi	$27, $0, 1	# should not execute
begin:	addi	$11, $0, 1	# $11 = 1
	sll	$12, $4, 8	# $12 = 1024
	srl	$13, $31, 2	# $13 = 12
	addi $31, $31, 36	# $31 = 84
middle:	beq	$11, $0, end	# not taken first time, taken second time
	sub	$11, $11, $1	# $11 = 1 - 1 = 0
	j	middle
	addi	$28, $0, 1	# should not execute
end:	jr	$31	# infinite loop
	addi	$29, $0, 1	# should not execute
	addi	$30, $0, 1	# should not execute