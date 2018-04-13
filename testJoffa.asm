; http://zxsnippets.wikia.com/wiki/Clearing_screen
; http://www.breakintoprogram.co.uk/computers/zx-spectrum/interrupts

screenMem  equ 4000h
attributeMem equ 5800h

	org 40000
start

;-----------------------------------------------------------------------------
main
	call setUpTheScreen
	call setUpTheInterrupt
loop
	halt

	ld a,3			; change to magenta border
	out (0feh),a

	call waitForLowerPartOfScreen	; wait for a central/lower part of the screen where 40h was inserted as attrib
;	call waitForLowerPartOfScreen1	; wait for a central/lower part of the screen where 40h was inserted as attrib

	ld a,5 			; change to cyan border
	out (0feh),a

	jr loop                    ; Loop around forever


;-----------------------------------------------------------------------------
; Set the screen to black everywhere, then insert a line of bright black on black 
; (for Joffa-like syncronization) and another line of black on yellow (to see where it is!!)

setUpTheScreen

; clear the screen attributes, white ink on black paper (stupid and slow ldir stuff)
	ld hl,attributeMem
	ld de,attributeMem+1 
	ld a,7			; 0 0 000 111 white ink on black paper
	ld (hl),a
	ld bc,20h * 24 - 1
	ldir

; prepare attribute setting
	ld hl,attributeMem
	ld bc,20h*10
	add hl,bc		; point to the 11th line	

; now set the bright black on black line, for "in" instruction to read (Joffa)
	ld a,40h		; black ink on black paper with brightness: 0 1 000 000
	ld b,20h		; fill the whole line with 40h
fillLineWith40h
	ld (hl),a
	inc hl
	djnz fillLineWith40h

; now set a stripe of black ink on yellow paper
	ld a,30h		; black ink on yellow paper: 0 0 110 000
	ld b,20h		; fill the whole line with 30h
fillLineWith30h
	ld (hl),a
	inc hl
	djnz fillLineWith30h

; insert some pixel values at 40h
	if 0
	ld hl,4000h + 0800h	; now insert some 40h as pixel byte values
	ld a,40h
	ld b,20h
fillPixelLineWith04h
	ld (hl),a
	inc hl
	djnz fillPixelLineWith04h
	endif
	ret

;-----------------------------------------------------------------------------
setUpTheInterrupt
	di			; Make sure no interrupts are called!
	ld hl,interrupt          ; Address of the interrupt routine
	ld ix,0fff0h                ; Where to stick this code
	ld (ix+04h),0c3h            ; Z80 opcode for JP
	ld (ix+05h),l              ; Where to JP to (in HL)
	ld (IX+06h),h
	ld (IX+0Fh),18h            ; Z80 Opcode for JR
	ld a,39h                   ; High byte address of vector table
	ld i,a                     ; Set I register to this
	im 2                       ; Set Interrupt Mode 2
	ei                         ; Enable interrupts again
	ret

;----------------------------------------------------------------------------
waitForLowerPartOfScreen
	ld a,40h
	ld e,a     ; or ld e,40h
waitForLowerPartOfScreenLoop:
	in a,(0ffh)
	cp e
	jr nz,waitForLowerPartOfScreenLoop
	ret

;----------------------------------------------------------------------------
waitForLowerPartOfScreen1
	ld bc,40ffh
	ld e,b      ; or ld e,40h
waitForLowerPartOfScreenLoop1
	in a,(c)
	cp e
	jr nz,waitForLowerPartOfScreenLoop1
	ret
;-----------------------------------------------------------------------------
; just a stub, does nothing
interrupt:
	di                         ; Disable interrupts
	push af                    ; Preserve all registers
	push bc
	push de
	push hl
	exx
	ex af,af'
	push af
	push bc
	push de
	push hl
	push ix
	push iy
;	call interruptStuff
	pop iy 		; restore all registers
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ex af,af'
	exx
	pop hl
	pop de
	pop bc
	pop af
	ei
	reti

;-----------------------------------------------------------------------------
; Just tests, not active
interruptStuff 
	xor a
	ld b,a
	out (254),a
a0	djnz a0
a01	djnz a01

	inc a
	out (254),a
;a1	djnz a1
	inc a
	out (254),a
;a2	djnz a2
	inc a
	out (254),a
;a3	djnz a3
	inc a
	out (254),a
;a4	djnz a4
	inc a
	out (254),a
;a5	djnz a5
	inc a
	out (254),a
;a6	djnz a6
	inc a
	out (254),a
	ret


