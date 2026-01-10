

	MACRO 		Stack_Row_Pixel	   src_num, tar_num							; total 262 T for 20
																			; 233 T for 18
		; start of sourse row
		LD 			SP, SCREEN_BASE_src_num								; 10 T
																			; = 10 T

		; pop from source to registers
		POP 		AF 													; 10 T
		POP 		BC 													; 10 T
		POP 		DE 													; 10 T
		POP 		HL													; 10 T
																			; = 40 T

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

		; end of target row
		LD 			SP, SCREEN_END_tar_num								; 10 T
																			; = 10 T

		; push from shadow registers to screen
		PUSH 		HL 													; 11 T
		PUSH 		DE 													; 11 T
		PUSH 		BC 													; 11 T
		PUSH 		AF 													; 11 T
																			; = 44 T

		; flip back to regular registers
		EXX 															; 4 T
		EX AF															; 4 T
																			; = 8 T

		; push from registers to screen
		PUSH 		HL 													; 11 T
		PUSH 		DE 													; 11 T
		PUSH 		BC 													; 11 T
		PUSH 		AF 													; 11 T
																			; = 44 T
	ENDM 







	MACRO 		Stack_Row_Pixel_Right	   src_num, tar_num				; total 262 T for 20
																			; 233 T for 18
		; start of sourse row
		LD 			SP, SCREEN_BASE_RIGHT_src_num						; 10 T
																			; = 10 T

		; pop from source to registers
		POP 		AF 													; 10 T
;		POP 		BC 													; 10 T
;		POP 		DE 													; 10 T
;		POP 		HL													; 10 T
																			; = 40 T
		; flip to shadow registers
;		EXX 															; 4 T
;		EX AF															; 4 T
																			; = 8 T

		; pop from source to shadow registers
;		POP 		AF 													; 10 T
;		POP 		BC 													; 10 T
;		POP 		DE 													; 10 T
;		POP 		HL													; 10 T
																			; = 40 T

		; end of target row
		LD 			SP, SCREEN_END_RIGHT_tar_num						; 10 T
																			; = 10 T

		; push from shadow registers to screen
;		PUSH 		HL 													; 11 T
;		PUSH 		DE 													; 11 T
;		PUSH 		BC 													; 11 T
;		PUSH 		AF 													; 11 T
																			; = 44 T

		; flip back to regular registers
;		EXX 															; 4 T
;		EX AF															; 4 T
																			; = 8 T

		; push from registers to screen
;		PUSH 		HL 													; 11 T
;		PUSH 		DE 													; 11 T
;		PUSH 		BC 													; 11 T
		PUSH 		AF 													; 11 T
																			; = 44 T
	ENDM 


