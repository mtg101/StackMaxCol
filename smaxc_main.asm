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
	PUSH 	AF
	LD 		A, 1					
	OUT		($FE), A		
	POP 	AF

	; vblank work...

; 8 scanline * 224 = 1,752 t-states (minus some for alignment, etc)
; we use it to flicker a window's colour based on pre-calculated stuff 

; last few rows...
	Stack_Row_Pixel	147	,	146
	Stack_Row_Pixel	148	,	147
	Stack_Row_Pixel	149	,	148
	Stack_Row_Pixel	150	,	149
	Stack_Row_Pixel	151	,	150
	Stack_Row_Pixel	152	,	151
	Stack_Row_Pixel	153	,	152
	Stack_Row_Pixel	154	,	153
	Stack_Row_Pixel	155	,	154
	Stack_Row_Pixel	156	,	155
	Stack_Row_Pixel	157	,	156
	Stack_Row_Pixel	158	,	157
	Stack_Row_Pixel	159	,	158
	Stack_Row_Pixel	160	,	159
	Stack_Row_Pixel	161	,	160
	Stack_Row_Pixel	162	,	161
	Stack_Row_Pixel	163	,	162
	Stack_Row_Pixel	164	,	163
	Stack_Row_Pixel	165	,	164
	Stack_Row_Pixel	166	,	165
	Stack_Row_Pixel	167	,	166
	Stack_Row_Pixel	168	,	167
	Stack_Row_Pixel	169	,	168
	Stack_Row_Pixel	170	,	169
	Stack_Row_Pixel	171	,	170
	Stack_Row_Pixel	172	,	171
	Stack_Row_Pixel	173	,	172
	Stack_Row_Pixel	174	,	173
	Stack_Row_Pixel	175	,	174
	Stack_Row_Pixel	176	,	175
	Stack_Row_Pixel	177	,	176
	Stack_Row_Pixel	178	,	177
	Stack_Row_Pixel	179	,	178
	Stack_Row_Pixel	180	,	179
	Stack_Row_Pixel	181	,	180
	Stack_Row_Pixel	182	,	181
	Stack_Row_Pixel	183	,	182
	Stack_Row_Pixel	184	,	183
	Stack_Row_Pixel	185	,	184
	Stack_Row_Pixel	186	,	185
	Stack_Row_Pixel	187	,	186
	Stack_Row_Pixel	188	,	187
	Stack_Row_Pixel	189	,	188
	Stack_Row_Pixel	190	,	189
	Stack_Row_Pixel	191	,	190
	Stack_Row_Pixel	192	,	191

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



; filler
	LD 		B, 21
FILLER:
	DJNZ	FILLER

	; fiddling
	.4 NOP								; 4 T


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
	EI                               ; Enable interrupts
	RET                              ; INTERRUPT

; screen
	ORG			$4000
	INCBIN 		"futari.scr"

; Deployment: Snapshot
	SAVESNA 	"smaxc.sna", START
   