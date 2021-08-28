.psx
.open "exe\SLPM_862.64",0x8000F800

;.org 0x8001c7f8
;	addiu v0, r0, 0xFF64

; This tries to pad out the blocks it loads to be divisible by 16. Why?
.org 0x80023e5c
	nop

.close