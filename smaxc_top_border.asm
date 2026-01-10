; timining-critical flipping of top border colours
; 224 t-states per row
TOP_BORDER_RENDER:		
	; can't trash registers...
	PUSH 	AF 
	PUSH 	BC
	PUSH	HL

	; border
	; LD 		A, 2					
	; OUT		($FE), A		


	LD		C, $FE
	LD 		HL, TOP_BORDER_BUFFER

	LD 		B, 8
TOP_BORDER_RENDER_LOOP:	
	;11 cols
	LD 		A, B

	OUTI	
	OUTI	
	OUTI	
	OUTI	

	OUTI	
	OUTI	
	OUTI	
	OUTI	

	OUTI	
	OUTI	
	OUTI	

	; hblank & timing desu...
	.5 NOP
	LD  	B, A
	LD 		A, (HL)

	DJNZ    TOP_BORDER_RENDER_LOOP

	; can't trash reg
	POP 	HL
	POP 	BC 
	POP 	AF 

	JP 		STACK_RENDER

TOP_BORDER_BUFFER:
	DEFS 	11, 0
	DEFS 	11, 1
	DEFS 	11, 2
	DEFS 	11, 3
	DEFS 	11, 4
	DEFS 	11, 5
	DEFS 	11, 6
	DEFS 	11, 7

