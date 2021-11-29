.psx
.open "exe\SLPM_862.64",0x8000F800


;.org 0x8005ba44
;	.db 0x19

; No clearing out my space for code!
.org 0x8004356c
	nop

; This tries to pad out the blocks it loads to be divisible by 16. Why?
.org 0x80023e5c
	nop

; Setup current width of the letter
.org 0x8001de9c
	jal getLetterWidth
	
.org 0x8001e620
	j storeLetterWidth
	
.org 0x8001c748
	j setStartPrint
	
.org 0x8001c908
	j onIncreaseY
	nop
	
.org 0x8001c7e0
	j calculateXPosition
	nop

; This loads the max allowed #s.  We cannot change where it loads from as it's used for the text box too... go figure
.org 0x8001c89c
	;LW      00000016 (t0), 0014 (801fff50 (sp)) [801fff64]
	addiu t0, r0, 0x4E
	
; This adds to the value to store our flags for showing letters.  We increase it by 2 to offset it by quiet a bit more.
; See 0x8001e610 for the position it stores the flag at which this will affect
.org 0x8001d634
	;ADDIU   0000000a (v1), 0000000a (v1), 0001 (1),
	addiu v1, v1, 0x06

;  Part of the calculation to store the flags for showing letters.  But it increases ita HELLUVA lot for some reason for the start.
.org 0x8001e600
	;SLL     0000008f (v1), 0000008f (v1), 01 (1),
	nop
	
.org 0x8001c77c
	;SLL     00000010 (t4), 00000082 (v1), 01 (1),
	addu t4, r0, v1
	
.org 0x8001c768
	j multiplyByY
	nop
	
.org 0x8001c784
	addiu t3, t3, 0xFF90
	

.org 0x80063640
; TODO: Cleanup but im lazy...
getLetterWidth:
	la t2, letter_widths
	la t0, nex_width
	addiu t1, a0, 0xFFE0
	addu t2, t2, t1
	lb t1, 1(v1)
	lb t2, 0(t2)
	addiu t1, t1, 0xFFF6 ;-0x0A
	sb r0, 2(t0) ; new_line flag
	bne t1, r0, not_newline
	sb t2, 0(t0)
	addiu t1, t1, 0x01
	sb t1, 2(t0) ; new line flag
not_newline:
	j 0x8001e518	
	nop
	
	
storeLetterWidth:
	la v0, nex_width
	lb v0, 0(v0)
	nop
	jr ra
	sb v0, 0(v1)
	
	
calculateXPosition:
	; 8001c7e0 : SLL     00000000 (v0), 00000003 (a1), 01 (1),
	; 8001c7e4 : ADDU    00000006 (v0), 00000006 (v0), 00000003 (a1),
	; 8001c7e8 : SLL     00000009 (v0), 00000009 (v0), 02 (2),
	; 8001c7ec : SB      0000008c (s3), 000c (800f5774 (v1)) [800f5780]
	; 8001c7f0 : LUI     00000003 (a1), 8006 (32774),
	; 8001c7f4 : LW      80060000 (a1), 5824 (80060000 (a1)) [80065824]
	; 8001c7f8 : ADDIU   00000024 (v0), 00000024 (v0), ff64 (65380),

	sw t1, 0x0018(sp) ; just store off t1 temporarily although this IS where it will go eventually
	la t1, variables
	lb v0, 3(t1)
	nop
	beq v0, r0, not_start_printing
	lw v0, 0(t1) ;	current width

	sll v0, a1, 1
	addu v0, v0, a1
	sll v0, v0, 2
	sb r0, 3(t1)
		
not_start_printing:
	nop
	addu a2, a2, v0 ; next width
	sw a2, 0(t1)
	lw t1, 0x0018(sp) ; reset t1 back to normal

	sb s3, 0x000C(v1)
	lui a1, 0x8006
	lw a1, 0x5824(a1)
	addiu a2, r0, 1 ; reset a2 back to 1 as it should be
	j 0x8001c7fc
	addiu v0, v0, 0xFF64
	
setStartPrint:
	la t5, variables
	sb t6, 3(t5)	; we'll use t6 as thats always added with 1 so it should not 0
	j 0x8001c750
	addiu t5, v1, 0xFFFE
	

onIncreaseY:
	la v0, variables
	addiu s4, s4, 0x01
	sb s4, 3(v0) ; we don't care what it is as long as not zero
	j 0x8001c910
	slt v0, s4, t5
	
multiplyByY:
	addu t3, t8, s4 ; the value of this gets set to v0 and then used to calculate the line position on screen... yay.... this is used for 0x8001c784
	sll t3, t3, 0x04
	
	addiu v0, r0, 0x06
	mult v0, s4
	mflo v0
	addu v0, t8, v0
	j 0x8001c770
	sll v1, v0, 1
	
; addiu t2, r0, 0x0C
; ;sb r0, 1(t1)
; sb t2, 0(t1)

; sb t2,  2(t1) ; We don't care what # it is as long as it isn't 0




; ;.org 0x8001c7f8
; ;	addiu v0, r0, 0xFF64

; .org 0x8001e59c
	; j start_draw_letter
	; nop

; ; ; This loads the idx to use to offset the position of the buffer
; ; ; 8001e550 : LB      0000002e (a0), 02d0 (80065540 (gp)) [80065810]
; ; .org 0x8001e550
	; ; j increaseLetterBuffer

; ; ; .org 0x8001e55c
	; ; ; addu v1, a0, v1
; ; .org 0x8001e55c
	; ; addu v1, a0, r0
	
; .org 0x8001e590
	; addu a1, r0, v0
	
; ; Thie block increase the x coord of the letter
; .org 0x8001d020
	; j increaseXCoord
	
; ; Increase the allowed width by 2 more pixels to make it so i have a bit more wiggle room
; ;.org 0x8001d030
; ;	addiu v1, a0, 0x23

; ;.org 0x8001d028
; ;	addiu v0, a3, 0x03

; .org 0x8001d028
	; addu v0, a1, t2
	
; .org 0x8001d03c
	; addu v0, a1, t1
	
; ; -------------------------------
; ; Below is when we hit a newline character (0x0A).  We need to set it to "overflow" so it'll increas the x position (why it has to happen who knows...)
; .org 0x8001d628
	; j newline
	
; ; Increase the amount of letters weve seen
; .org 0x8001deac
	; addu v0, v0, t4 ; t4 holds our overflow...
	
; .org 0x8001d5bc
	; jal resetOnEnd
; ;------------------------------------



; ; a3 = text buffer position
; ; t9 = cur width location
; ; t3 = overflow buffer position
; ; t0 = font letter pixel position


; .org 0x80063640
; start_draw_letter:
	; la t9, variables
	; la t3, ovr_buffer
	; lb v0, 0(t9) ; cur width
	; addiu v1, r0, 0x0B
	; slt v1, v1, v0
	; sb v1, 2(t9)
	
	
; draw_letter:
	; lbu        a0, 0x0(t0) ; Load 1bpp font pixel here
	; addiu      t0, t0, 0x1
	; addiu      a2, a2, 0x1
	; andi       v1, a0, 0xc0
	; sll        v1, v1, 0x6
	; andi       v0, a0, 0x30
	; sll        v0, v0, 0x4
	; or         v1, v1, v0
	; andi       v0, a0, 0xc
	; sll        v0, v0, 0x2
	; or         v1, v1, v0
	; andi       a0, a0, 0x3
	; or         v1, v1, a0
	; sh		   v1, 4(t9)
	; ;addu      t2, r0, v1
	
	; ; Width = 8
	; lbu        a0, 0x0(t0) ; Load 1bpp font pixel here
	; addiu      t0, t0, 0x1
	; addiu      a2, a2, 0x1
	; andi       v1, a0, 0xc0
	; sll        v1, v1, 0x6
	; andi       v0, a0, 0x30
	; sll        v0, v0, 0x4
	; or         v1, v1, v0
	; andi       v0, a0, 0xc
	; sll        v0, v0, 0x2
	; or         v1, v1, v0
	; andi       a0, a0, 0x3
	; or         v1, v1, a0
	; sh		   v1, 6(t9)
	; ;addu      t3, r0, v1
	
	; ; Width = 12
	; lbu        a0, 0x0(t0) ; Load 1bpp font pixel here
	; addiu      t0, t0, 0x1
	; addiu      a2, a2, 0x1
	; andi       v1, a0, 0xc0
	; sll        v1, v1, 0x6
	; andi       v0, a0, 0x30
	; sll        v0, v0, 0x4
	; or         v1, v1, v0
	; andi       v0, a0, 0xc
	; sllv       v0, v0, v1
	; or         v1, v1, v0
	; andi       a0, a0, 0x3
	; or         v1, v1, a0
	; sh		   v1, 8(t9)
	
	; ;sh		   t2, 0(a3)
	; ;sh	       t3, 2(a3)
	; ;sh         t4, 4(a3)
	
	; ; Combine letters... clean up later....
	; ;sll t3, t3, 0x10
	; ;or v0, t3, t2
	; ;addu v1, r0, t4
	; ;sw v0, 0(a3)
	; ;sh v1, 4(a3)
	; lw 		v0, 4(t9)
	; lh 		v1, 8(t9)
		
	; do_vwf:
	
		; ;lbu t6, 0x02(t9) ; Load if we overflowed, 1 we did, 0 we didn't
		; lbu t2, 0x00(t9) ; Load current width
		; addiu t6, r0, 0x0B
		; slt t6, t6, t2
		; beqz t6, start_vwf 
		; ;sb t6, 0x02(t9)
		; nop
		; addiu t2, t2, -0x0C
		; clear_overflow:	
			; lw a0, 0x00(t3) ; overflow
			; sw r0, 0x00(t3)
			; sw a0, 0x00(a3)
			
			; lh a0, 0x04(t3)
			; sh r0, 0x04(t3)
			; sh a0, 0x04(a3)

	; start_vwf:
		; addu t8, r0, t2   ; cur width

		; load_letter:
			; lw t4, 0x00(t3) ; overflow
			; beqz t8, store_letter ; obviously we dont need to shift if the cur width is 0
			; lhu t5, 0x04(t3)		
			
			; shift_letter:
				; addi t8, t8, 0xffff ; decrease width by 1
				
				; xor t6, t6
				; sll t5, t5, 4   ; (overflow2 << 4
				; srl t6, t4, 28  ; (overflow1 >> 28)
				; or t5, t6, t5   ; overflow2 =| (overflow1 >> 28)
				
				; xor t6, t6
				; sll t4, t4, 4   ; (overflow1 << 4)
				; srl t6, v1, 12  ; (char2pixels2 >> 28)
				; or t4, t6, t4   ; overflow1 =| (char2pixels2 >> 28);
				
				; xor t6, t6
				; sll v1, v1, 4   ; (char2pixels2 << 4)
				; andi v1, v1, 0x0000FFFF
				; srl t6, v0, 28  ; (char2pixels1 >> 28);
				; or v1, t6, v1   ;  char2pixels2 =| (char2pixels1 >> 28);
				
				; bgtz t8, shift_letter
				
				; sll v0, v0, 4   ;(char2pixels1 << 4);
				
			; store_letter:
				; ; Grab letters written already
				; lw t7, 0x00(a3)
				; lhu t1, 0x04(a3)
				; ; Add on our shifted current letteri 
				; or t7, t7, v0
				; or t1, t1, v1
				; ; Store updated buffer
				; sw t7, 0x00(a3)
				; sh t1, 0x04(a3)
				
				; ; Store anything written to the overflow buffer
				; sw t4, 0x00(t3) ; overflow
				; sh t5, 0x04(t3)
				
	; end_vwf:
		; ;sh         v1, 0x0(a3) ; Store 4bpp font pixel here
		; slti       v0, a2, 0x30
		; addiu	   t3, t3, 0x06	; Increase overflow buffer store position
		; bne        v0, r0, draw_letter
		; addiu      a3, a3,0x6   ; Increase pixel buffer store position
		
		; lb t4, 1(t9)
		; nop
		; ;addiu t4, r0, 0x0C ; default next widths to C
		; ;sb t4, 1(t9)
		; ;addiu t2, t2, 0x08
		; addu t2, t2, t4
		; ;addiu t4, r0, 0x0B
		; ;slt t4, t4, t2
		
		; sb t2, 0(t9) ; store width
		; lb t4, 2(t9) ; load if we overflowed or not (1 means we didn't)	
		
		
		; j 0x8001e5e0
		; addu      a0, r0, t1

; increaseLetterBuffer:
	; la v1, ovr_flow
	; lb v1, 0(v1)
	; j 0x8001e558
	; lb a0, 0x02d0(gp)

; ;8001d020 : LBU     00000010 (a1), 0002 (800f5720 (s1)) [800f5722]
; ;8001d024 : LBU     1f801074 (v1), 0000 (80065540 (s0)) [80065540]
; ;8001d028 : ADDIU   80065540 (v0), 00000020 (a1), 0006 (6),
; ;8001d02c : SRL     0000000d (a0), 00000080 (v1), 02 (2),
; ;8001d030 : ADDIU   00000080 (v1), 00000020 (a0), 0020 (32),
; ;8001d034 : SLT     00000026 (v0), 00000026 (v0), 00000040 (v1),
; ;8001d038 : BNE     00000001 (v0), 00000000 (r0), 8001d054,
; ;8001d03c : ADDIU   00000001 (v0), 00000020 (a1), 0003 (3),
; increaseXCoord:
	; la t1, cur_width
	; lb t2, 3(t1) ; get if newline will occur
	; sb r0, 3(t1) ; we dont care if it gets reset everytime
	; lb t1,  0(t1)
	; bne t2, r0, increaseX
	; lb a1, 0x02(s1)
	; slti t1, t1, 0x0C
	; xor t2, t2
	; bne t1, r0, noIncreaseX
	; xor t1, t1
; increaseX:
	; addiu t1, r0, 0x03
	; addiu t2, r0, 0x06
; noIncreaseX:
	; j 0x8001d028
	; nop
	
; newline:
	; la t1, cur_width
	; lb v0, 0xA1D4(v0)
	; addiu t2, r0, 0x0C
	; ;sb r0, 1(t1)
	; sb t2, 0(t1)
	; j 0x8001d630
	; sb t2,  2(t1) ; We don't care what # it is as long as it isn't 0
	
; getLetterWidth:
	; la t2, letter_widths
	; la t0, nex_width
	; addiu t1, a0, 0xFFE0
	; addu t2, t2, t1
	; lb t1, 1(v1)
	; lb t2, 0(t2)
	; addiu t1, t1, 0xFFF6 ;-0x0A
	; sb r0, 2(t0) ; new_line flag
	; bne t1, r0, not_newline
	; sb t2, 0(t0)
	; addiu t1, t1, 0x01
	; sb t1, 2(t0) ; new line flag
; not_newline:
	; j 0x8001e518	
	; nop
	
; resetOnEnd:
	; la t1, cur_width
	; addiu t2, r0, 0x0C
	; sb t2, 0(t1)
	; j 0x800234cc
	; sb t2,  2(t1) ; We don't care what # it is as long as it isn't 0

variables:
cur_width:
	.dw 0x18
nex_width:
	.db 0x08
sta_print:
	.db 1
new_line:
	.db 0
tmp_buffer:
	.dw 0
	.dw 0
ovr_buffer:
	.db 0

.org 0x80063B00
letter_widths:
	.db 0x00 ;
	.db 0x04 ;!
	.db 0x05 ;"
	.db 0x04 ; 
	.db 0x00 ;
	.db 0x0A ;
	.db 0x09 ;&
	.db 0x03 ;'
	.db 0x06 ;(
	.db 0x06 ;)
	.db 0x0D ;*
	.db 0x06 ;+
	.db 0x05 ;,
	.db 0x06 ;-
	.db 0x04 ;.
	.db 0x06 ;/
	.db 0x08 ;0
	.db 0x05 ;1
	.db 0x08 ;2
	.db 0x08 ;3
	.db 0x09 ;4
	.db 0x08 ;5
	.db 0x08 ;6
	.db 0x08 ;7
	.db 0x08 ;8
	.db 0x08 ;9
	.db 0x04 ;:
	.db 0x00 ;
	.db 0x00 ;
	.db 0x06 ;=
	.db 0x00 ;
	.db 0x08 ;?
	.db 0x00 ;
	.db 0x08 ;A
	.db 0x08 ;B
	.db 0x08 ;C
	.db 0x08 ;D
	.db 0x07 ;E
	.db 0x07 ;F
	.db 0x08 ;G
	.db 0x08 ;H
	.db 0x07 ;I
	.db 0x08 ;J
	.db 0x09 ;K
	.db 0x07 ;L
	.db 0x0A ;M
	.db 0x09 ;N
	.db 0x08 ;O
	.db 0x08 ;P
	.db 0x08 ;Q
	.db 0x08 ;R
	.db 0x07 ;S
	.db 0x08 ;T
	.db 0x08 ;U
	.db 0x08 ;V
	.db 0x0C ;W
	.db 0x08 ;X
	.db 0x08 ;Y
	.db 0x08 ;Z
	.db 0x00 ;
	.db 0x00 ;
	.db 0x00 ;
	.db 0x00 ;
	.db 0x00 ;
	.db 0x00 ;
	.db 0x08 ;a
	.db 0x08 ;b
	.db 0x07 ;c
	.db 0x08 ;d
	.db 0x08 ;e
	.db 0x07 ;f
	.db 0x08 ;g
	.db 0x08 ;h
	.db 0x04 ;i
	.db 0x07 ;j
	.db 0x08 ;k
	.db 0x04 ;l
	.db 0x0C ;m
	.db 0x08 ;n
	.db 0x08 ;o
	.db 0x08 ;p
	.db 0x08 ;q
	.db 0x07 ;r
	.db 0x07 ;s
	.db 0x06 ;t
	.db 0x08 ;u
	.db 0x08 ;v
	.db 0x0C ;w
	.db 0x08 ;x
	.db 0x08 ;y
	.db 0x08 ;z

.close