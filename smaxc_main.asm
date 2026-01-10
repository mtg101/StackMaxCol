	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION	; for VSCODE and debugging
	DEVICE ZXSPECTRUM48 			; needed for SNA export
	ORG 	$8000					; the uncontended 32KiB
	
	INCLUDE "smaxc_defs.asm"
	INCLUDE "smaxc_top_border.asm"
	INCLUDE "smaxc_stack_render.asm"
	
START:
	CALL	INITIALISE_INTERRUPT	; IM2 with ROM trick
	CALL 	INITIAL_SETUP

SP_MAIN:
	HALT							; wait for vblank
	JP		VBLANK_PERIOD_WORK		; 8 scanline * 224 = 1,952 t-states (minus some for alignment timing)
VBLANK_PERIOD_WORK_OVER:
	JP		TOP_BORDER_RENDER		; timining-critical flipping of top border colours
TOP_BORDER_RENDER_OVER:
	JP 		STACK_RENDER
STACK_RENDER_OVER:
	JP		SP_MAIN

INITIAL_SETUP:
	; black border
	LD 		A, 0					
	OUT		($FE), A		

	RET								; INITIAL_SETUP

FRAME_COUNT:
	DEFB 	0

; 8 scanline * 224 = 1,752 t-states (minus some for alignment, etc)
; we use it to flicker a window's colour based on pre-calculated stuff 

VBLANK_PERIOD_WORK:					; 10 T (JP in)

; preserve SP
	LD 			(STACK_POINTER_BACKUP), SP	; 20 T

; pre-pop buffer
	Stack_Row_Pixel	0	,	192				; 233 T (18 col)
					; 262 T for 20col	


; pre-pop registers
		; start of source row
		LD 			SP, SCREEN_BASE_1									; 10 T
																			; = 10 T

		; pop from source to registers
		POP 		AF 													; 10 T
		POP 		BC 													; 10 T
		POP 		DE 													; 10 T
		POP 		HL													; 10 T
																			; = 40 T

		; extra IX/IY
;		POP 		IX 													; 14 T
		POP			IY 													; 14 T 
																			; = 28 T

		; flip to shadow registers
		EXX 															; 4 T
		EX AF															; 4 T
																			; = 8 T

		; pop from source to shadow registers
		POP 		AF 													; 10 T
		POP 		BC 													; 10 T
		POP 		DE 													; 10 T
		POP 		HL													; 10 T
																			; = 40 T

																				; = 126 T

; pre-pop SP   (after we steop being in a called routine!)
		; end of target row
;		LD 			SP, SCREEN_END_tar_num								; 10 T

	LD 			SP, (STACK_POINTER_BACKUP)	; 20 T
												; = 273 T  (18 col)
					; = 302 T (20 col)



; filler
	PUSH AF							; 11 T
	PUSH BC							; 11 T							
	PUSH DE							; 11 T
	PUSH HL							; 11 T
										; = 44 T

	NOP								; 4 T
	NOP								; 4 T
										; = 8 T

	LD		B, 86					; 7 T
										; = 7 T
VBLANK_LOOP:						
	DJNZ	VBLANK_LOOP			; 13 T per loop
								; +8 T last time

								; 86 * 13 = 1,248 T

									; last loop
										; 8 T 
									
	POP HL							; 10 T
	POP DE							; 10 T
	POP BC							; 10 T
	POP AF							; 10 T
										; = 40T

	; fiddling
	.3 NOP								; 4 T


	JP	VBLANK_PERIOD_WORK_OVER		; 10 T (ret)

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






; set up IM2 - so we don't wate time scanning keyboard and so on
; use ROM trick for interrupt table
; from http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum/interrupts 
INITIALISE_INTERRUPT:   			
	di                              ; Disable interrupts
	ld		hl, INTERRUPT
	ld		ix, $FFF0				; This code is to be written at 0xFF
	ld		(ix + $04), $C3         ; Opcode for JP
	ld		(ix + $05), l           ; Store the address of the interrupt routine in
	ld		(ix + $06), h
	ld		(ix + $0F), $18         ; Opcode for JR; this will do JR to FFF4h
	ld		a, $39                  ; Interrupt table at page 0x3900 (ROM)
	ld		i, a                    ; Set the interrupt register to that page
	im		2                       ; Set the interrupt mode
	ei                              ; Enable interrupts
	ret								; INITIALISE_INTERRUPT
 
INTERRUPT:              
	EI                               ; Enable interrupts
	RET                              ; INTERRUPT

; screen
	ORG			$4000
	INCBIN 		"futari.scr"

; Deployment: Snapshot
	SAVESNA 	"smaxc.sna", START
   