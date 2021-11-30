.psx
.open "exe\SLPM_862.64",0x8000F800

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
	
	
; --------------------------- CLEAN UP FLAGS FOR DISPLAYING TEXT -------------
; For cleaning up our flags
.org 0x8001cf6c
	;SLL     00000075 (a0), 00000075 (a0), 01 (1),
	nop

; Gets how many bytes to clean up yet its a unique instruction so...
.org 0x8001cf50
	;LH      60000000 (a2), 0004 (8010a1d4 (s1)) [8010a1d8]
	addiu a2, r0, 0xC5 ; Add a bit more than our actual length so i can cheat and don't need to fix the calculation...
					   ; This could bite us in the ass.. so maybe todo? fix it properly
					   
; ----------------------------------------------------------------------------

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