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
	CALL	VBLANK_PERIOD_WORK		; 8 scanline * 224 = 1952 t-states (minus some for alignment timing)
	CALL	TOP_BORDER_RENDER		; timining-critical flipping of top border colours
	CALL 	STACK_RENDER
	JP		SP_MAIN

INITIAL_SETUP:
	; black border
	LD 		A, 0					
	OUT		($FE), A		

	RET								; INITIAL_SETUP

FRAME_COUNT:
	DEFB 	0

; 8 scanline * 224 = 1,752 t-states (minus some for alignment, push/pop, calls, etc...)
; we use it to flicker a window's colour based on pre-calculated stuff 
VBLANK_PERIOD_WORK:					
	PUSH AF							
	PUSH BC							
	PUSH DE							
	PUSH HL							

	NOP
	NOP

	LD		B, 118
VBLANK_LOOP:						
	DJNZ	VBLANK_LOOP				
									
	; fiddling...
	;.1 LD	A, 7					
	;.3 NOP	

	POP HL							
	POP DE							
	POP BC							
	POP AF							

	RET								; VBLANK_PERIOD_WORK

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
   