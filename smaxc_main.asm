	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION	; for VSCODE and debugging
	DEVICE ZXSPECTRUM48 			; needed for SNA export
	ORG 	$8000					; the uncontended 32KiB
	
	INCLUDE "smaxc_defs.asm"
	INCLUDE "smaxc_top_border.asm"
	INCLUDE "smaxc_stack_render.asm"
	
START:
	; black border
	LD 		A, 0					
	OUT		($FE), A		

	; IM2 with ROM trick
	DI                              ; Disable interrupts
	LD		hl, INTERRUPT
	LD		ix, $FFF0				; This code is to be written at 0xFF
	LD		(ix + $04), $C3         ; Opcode for JP
	LD		(ix + $05), l           ; Store the address of the interrupt routine in
	LD		(ix + $06), h
	LD		(ix + $0F), $18         ; Opcode for JR; this will do JR to FFF4h
	LD		a, $39                  ; Interrupt table at page 0x3900 (ROM)
	LD		i, a                    ; Set the interrupt register to that page
	IM		2                       ; Set the interrupt mode
	EI                              ; Enable interrupts

SP_MAIN:
	HALT							; wait for vblank

	; border
	LD 		SP, PRIVATE_STACK
	PUSH 	AF
	LD 		A, 1					
	OUT		($FE), A		
	POP 	AF

	; vblank work...

	LD		B, 255
FILL_0:
	DJNZ	FILL_0
FILL_1:
	DJNZ	FILL_1
FILL_2:
	DJNZ	FILL_2
	LD 		B, 179
FILL_3:
	DJNZ	FILL_3


	; fiddling
	.10 NOP								; 4 T





; 8 scanline * 224 = 1,752 t-states (minus some for alignment, etc)
; we use it to flicker a window's colour based on pre-calculated stuff 




; ; pre-pop buffer
; 	Stack_Row_Pixel	0	,	192				; 233 T (18 col)
; 					; 262 T for 20col	


; ; pre-pop registers
; 		; start of source row
; 		LD 			SP, SCREEN_BASE_1									; 10 T
; 																			; = 10 T

; 		; pop from source to registers
; 		POP 		AF 													; 10 T
; 		POP 		BC 													; 10 T
; 		POP 		DE 													; 10 T
; 		POP 		HL													; 10 T
; 																			; = 40 T

; 		; extra IX/IY
; ;		POP 		IX 													; 14 T
; 		POP			IY 													; 14 T 
; 																			; = 28 T

; 		; flip to shadow registers
; 		EXX 															; 4 T
; 		EX AF															; 4 T
; 																			; = 8 T

; 		; pop from source to shadow registers
; 		POP 		AF 													; 10 T
; 		POP 		BC 													; 10 T
; 		POP 		DE 													; 10 T
; 		POP 		HL													; 10 T
; 																			; = 40 T

; 																				; = 126 T

; ; pre-pop SP
; 		; end of target row
; 		LD 			SP, SCREEN_END_0								; 10 T




	JP		TOP_BORDER_RENDER		
;	JP		STACK_RENDER

	; buffer: 273 T
	; reg: -
	; sp: -
	; before loop: 69 T
	; loop: 1,248 T
	; after: 69 T
	; = 1,659 T


; original VBLANK_PERIOD_WORK
; VBLANK_PERIOD_WORK:					; 17 T (call)
; 	PUSH AF							; 11 T
; 	PUSH BC							; 11 T							
; 	PUSH DE							; 11 T
; 	PUSH HL							; 11 T
; 										; = 44 T

; 	NOP								; 4 T
; 	NOP								; 4 T
; 										; = 8 T

; 	LD		B, 118					; 7 T
; 										; = 7 T
; VBLANK_LOOP:						
; 	DJNZ	VBLANK_LOOP			; 13 T per loop
; 								; +8 T last time

; 								; 117 * 13 = 1,521 T
; 									; + 8 = 1,529 T
									
; 	POP HL							; 10 T
; 	POP DE							; 10 T
; 	POP BC							; 10 T
; 	POP AF							; 10 T
; 										; = 40T

; 	RET	; VBLANK_PERIOD_WORK		; 10 T (ret)

; 	; before loop: 76 T
; 	; loop: 1,529 T
; 	; after: 50 T
; 	; = 1,655 T





 
INTERRUPT:              
	EI                              ; Enable interrupts
	RET                             ; INTERRUPT

; private stack - top borded does 3 16 bit registers... 16 is plenty!
	DEFS		16					
PRIVATE_STACK:						; stacks are upside down rmember... label after memory alloc

; screen
	ORG			$4000
	INCBIN 		"futari.scr"

; Deployment: Snapshot
	SAVESNA 	"smaxc.sna", START
   