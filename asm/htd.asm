DATA SEGMENT
	PROMPT DB 'Input the 16 bits hexadecimal digit:',13,10,'$'
	RETURN DB 	13,10,'$'
	TOO_MANY_BITS DB 'At most 16 bits can be input!',13,10,'$'
	WRONG DB 'Wrong Input!','13','10','$'
	HEX DB 5			;String to store the hexadecimal number
		DB ?
		DB 5 DUP(0)
DATA ENDS

STACK SEGMENT

STACK ENDS

CODE SEGMENT
	ASSUME DS:DATA, CS:CODE
HTD:
	MOV AX, DATA
	MOV DS, AX
	
	LEA DX, PROMPT  ;Tell us to input the hexadecimal number
	MOV AH, 09H
	INT 21H
	
	LEA DX, HEX
	MOV AH, 0AH
	INT 21H
	LEA DX, RETURN
	MOV AH, 09H
	INT 21H
	
	CMP HEX[1], 4   	;If the bits number is smaller than 4, the input is valid
	JNA BITS_VALID
	
	LEA DX, TOO_MANY_BITS
	MOV AH, 09H
	INT 21H
	JMP HTD
	
BITS_VALID:
	LEA DI, HEX
	MOV CX, 0
	MOV CL, HEX[1]
	CALL CHANGE		;Call CHANGE function to get the value from the string
	CMP BX, 16
	JE  HTD
	PUSH AX
	
	MOV CX, 5		;Loop 5 times to output the number string
	MOV BX, 10		;Divide 10 to get a decimal number remainder
	MOV DX, 0
	
TO_ASCII:			;Change the value to string, which represent a decimal number
	DIV BX
	PUSH DX
	MOV DX, 0
	LOOP TO_ASCII

	MOV CX, 5
ASCII:
	POP BX
	ADD BX, '0'

PRINT:
	MOV DX, BX
	MOV AH, 02H
    INT 21H
	LOOP ASCII
	
EXIT:

	MOV AH, 4CH
	INT 21H
	
	
TONUM PROC NEAR
	CMP BL, '0'
	JB  WRONG_INPUT
	CMP BL, '9'
	JA  UPPER_HEX
	SUB BL, '0'
	RET
	
UPPER_HEX:
	CMP BL,'A'
	JB  WRONG_INPUT
	CMP BL,'F'
	JA  LOWER_HEX
	SUB BL, 'A'
	ADD BL, 10
	RET
	
	
LOWER_HEX:
	CMP BL,'a'
	JB  WRONG_INPUT
	CMP BL,'f'
	JA  WRONG_INPUT
	SUB BL,'a'
	ADD BL, 10
	RET
	
WRONG_INPUT:
	LEA DX, WRONG
	MOV AH, 09H
	INT 21H
	MOV BX, 16
	RET
TONUM ENDP

CHANGE PROC NEAR

	ADD DI, 2
	MOV AX, 0
	CAL:
    MOV BX, 16
	MUL BX
	MOV BL, [DI]
	INC DI
	CALL TONUM
	CMP  BX, 16
	JNE   NEXT
	RET
	NEXT:
	ADD AX, BX
	LOOP CAL

	RET
CHANGE ENDP
	
CODE ENDS

END HTD
