.text
vbsme:  	li		$v0, 0					# 0 Set v0 = 0
			li		$v1, 0					# 4 Set v1 = 0
			lui		$s7, 0x7fff				# 8	Set SAD to Largest Possible
			ori		$s7, $s7, 0xffff		# 12
			lw		$s0,  0($a0)			# 16 Frame Rows
			lw		$s1,  4($a0)			# 20 Frame Cols
			lw		$s2,  8($a0)			# 24 Window Rows
			lw		$s3, 12($a0)			# 28 Window Cols
			addi	$a1, $0, 16				# 32
			mul		$a2, $s0, $s1,			# 36
			sll		$a2, $a2, 2				# 40
			add		$a2, $a1, $a2			# 44
			sll		$s6, $s1, 2				# 48 Frame Row Jump
			mul		$a3, $s2, $s3			# 52 End of Window
			sll		$a3, $a3, 2				# 56
			add		$a3, $a3, $a2			# 60 
			addi	$a3, $a3, -4			# 64
			sub		$a0, $s1, $s3			# 68 Next Frame-Window Row Offset
			addi	$a0, $a0, 1				# 72
			sll		$a0, $a0, 2				# 76
			sub		$s4, $s1, $s3			# 80 Max Frame Columns
			sub		$s5, $s0, $s2			# 84 Max Frame Rows
			addi	$t9, $0, 0				# 88 Current Row
			addi	$t8, $0, 0				# 92 Current Column	
			addi	$t0, $a1, 0				# 96 Current Frame Cell
			sll		$t6, $s2, 2				# 100 Current Frame-Window Row End
			add		$t6, $t6, $t0			# 104
			addi	$t6, $t6, -4			# 108
			addi	$s0, $a1,  0			# 112 Current Frame-Window Start
SADLoop:	li		$t5, 0					# 116 Reset Window SAD
			addi	$t1, $a2, 0				# 120 Reset Window Address
			addi	$t2, $s3, -1			# 124 Set Frame-Window Row End
			sll		$t2, $t2, 2				# 128
			add		$t6, $t0, $t2			# 132 
WindowLoop:	lw		$t2, 0($t0)				# 136 Current Frame Cell Value
			lw		$t3, 0($t1)				# 140 Current Window Cell Value
			sub		$t4, $t2, $t3			# 144 Cell SAD Value
			bgez	$t4, gteZero			# 148 if Cell SAD < 0 perform abs()
			nor		$t4, $t4, $0			# 152
			addi	$t4, $t4, 1				# 156
gteZero:	add		$t5, $t5, $t4			# 160 Add Cell SAD to Window SAD
			beq		$t1, $a3, CheckSAD		# 164 GoTo CheckSAD if at the end of the Window
			beq		$t0, $t6, NextFWRow		# 168 GoTo NextWinRow if at the end of the Frame Window Row
			addi	$t0, $t0, 4				# 172 Move to Next Frame Element
			addi	$t1, $t1, 4				# 176 Move to Next Window Element
			j		WindowLoop				# 180
NextFWRow:	add		$t0, $t0, $a0			# 184 Move Frame-Window
			addi	$t1, $t1, 4				# 188 Move to Next Window Element
			add		$t6, $t6, $s6			# 192 Move Frame-Window Row End
			j		WindowLoop				# 196
CheckSAD:	slt		$t2, $s7, $t5			# 200 Chcek if Current Window SAD < Min SAD, Update
			bne		$t2, $0, CheckExit		# 204
			addi	$s7, $t5, 0				# 208 Set New Min SAD
			addi	$v0, $t9, 0				# 212 Set New Min SAD Row
			addi	$v1, $t8, 0				# 216 Set New Min SAD Col
CheckExit:	bne		$t8, $s4, Move			# 220 Check if at Last (Possible) Column
			bne		$t9, $s5, Move			# 224 Check if at Last (Possible) Row
			#jr		$ra						# 228
			j		end	
Move:		beq		$t8, $s4, MoveNextR		# 232 Check if at Last (Possible) Column
MoveRight:	addi	$t8, $t8, 1				# 236 Move Next Column Index
			addi	$s0, $s0, 4				# 240 Move Frame-Window Start
			addi	$t0, $s0, 0				# 240
			j 		SADLoop					# 244
MoveNextR:  addi	$t9, $t9, 1				# 248 Move Row +1
			addi	$t8, $0,  0				# 252 Move Col 0
			sll		$t2, $s3, 2				# 256 Move Frame-Window To Begining of Next Row
			add		$s0, $s0, $t2			# 260
			addi	$t0, $s0, 0				# 264
			j		SADLoop					# 268 
end:		j		endLoop					# 272
endLoop:	j		end						# 276