.psx
.open "exe\SLPM_862.64",0x8000F800

TextDrawFlagsArea: equ 0x800F1000

; No clearing out my space for code!
.org 0x8004356c
	nop

; This tries to pad out the blocks it loads to be divisible by 16. Why?
.org 0x80023e5c
	nop

; --------------------------- Text Flag Area Code ---------------------------
; Clear text flag area
.org 0x8001cf40
	la s3, TextDrawFlagsArea

.org 0x8001cf58
	;SLL     0000000d (a0), 0000000b (v0), 01 (1),
	sll a0, v0, 3

; Write text flags area
.org 0x8001e5e8
	la v0, TextDrawFlagsArea

.org 0x8001e5f0
	;SLL     00000040 (v1), 0000000c (s0), 01 (1),
	sll v1, s0, 3

; Load text flags area
.org 0x8001c6ac
	la t9, TextDrawFlagsArea
	
.org 0x8001c76c
	;SLL     00000003 (v1), 0000000c (v0), 01 (1),
	sll v1, v0, 3
; ---------------------------------------------------------------------------

;----------- TODO: Not hardcode these values ---------------------------------
; ; This loads the max allowed #s.  We cannot change where it loads from as it's used for the text box too... go figure
.org 0x8001c89c
	;LW      00000016 (t0), 0014 (801fff50 (sp)) [801fff64]
	addiu t0, r0, 0x48
	
.org 0x8001cf50
	addiu a2, r0, 0x48
; ---------------------------------------------------------------------------


; Dialogue
.org 0x8001de9c
	jal getLetterWidth
	
; Items
.org 0x8001e6b4
	jal getLetterWidth

; Names
.org 0x8001d568
	jal getLetterWidth
	
.org 0x8001e620
	j storeLetterWidth
	
.org 0x8001c908
	j onIncreaseY
	nop
	
.org 0x8001c7e0
	j calculateXPosition
	nop

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
	sll v0, v0, 4
	or v0, v0, a0
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
	srl a1, a2, 4 ; a2 contains letter width + color so shift off the color
	addu a1, a1, v0 ; next width
	sw a1, 0(t1)
	lw t1, 0x0018(sp) ; reset t1 back to normal

	sb s3, 0x000C(v1)
	lui a1, 0x8006
	lw a1, 0x5824(a1)
	andi a2, a2, 0x0F ; and off the letter width so we only have our color left
	j 0x8001c7fc
	addiu v0, v0, 0xFF64

onIncreaseY:
	la v0, variables
	addiu s4, s4, 0x01
	sb s4, 3(v0) ; we don't care what it is as long as not zero
	j 0x8001c910
	slt v0, s4, t5


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
	.db 0x0C ;
	.db 0x04 ;!
	.db 0x05 ;"
	.db 0x04 ; 
	.db 0x0C ;
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
	.db 0x0C ;
	.db 0x0C ;
	.db 0x06 ;=
	.db 0x0C ;
	.db 0x08 ;?
	.db 0x0C ;
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
	.db 0x0C ;
	.db 0x0C ;
	.db 0x0C ;
	.db 0x0C ;
	.db 0x0C ;
	.db 0x0C ;
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