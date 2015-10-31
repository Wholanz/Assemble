DATA SEGMENT

  PROMPT1 DB 'Input the first 16 bits hexadecimal number',13,10,'$'  ;PROMPT  
  PROMPT2 DB 'Input the second 16 bits hexadecimal number',13,10,'$'
  OVERFLOW DB 'Overflow!',13,10,'$'  
  WRONG DB 'Wrong Input!',13,10,'$'
  RETURN DB 13,10,'$'
  DATA1 DB 10        ;The string of the first number
	  DB 0
	  DB 10 DUP (0)
  DATA2 DB 10        ;The string of the second number
	  DB 0
	  DB 10 DUP (0)
	  
DATA ENDS

STACK SEGMENT
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA,ES:DATA
ADDER:
	MOV AX, DATA
	MOV DS, AX
	
NUM1_IN:
	LEA DX, PROMPT1  ;Tell us to input the first number
	MOV AH, 09H
	INT 21H
	LEA DX, DATA1
	

	MOV AH,0AH
	INT 21H
	LEA DX, RETURN
	MOV AH,09H
	INT 21H
	CMP BYTE PTR DATA1[1], 4  ;Check if the number is too large
	JA OVERFLOW1              ;If number is too large, ourput overflow
	LEA DI, DATA1             ;Set DI as a parameter passed to function, here is DATA1, the address
	MOV CX, 0
	MOV CL, DATA1[1]          ;Set CL as a parameter passed to function, here is DATA[1], the bits number
	CALL CHANGE               ;Call the subprogram CHANGE
	CMP BX, 16				  ;If the return value BX is 16, the input number is not valid
	JE  NUM1_IN				  ;Input another valid number
	PUSH AX					  ;The valid change number is returned and saved in AX,push it to the stack
	JMP NUM2_IN				
	
	OVERFLOW1:
	LEA DX, OVERFLOW
	MOV AH, 09H
	INT 21H	
	JMP NUM1_IN

	
NUM2_IN:
	LEA DX, PROMPT2          ;Tell us to input the second number,similar to the first number
	MOV AH, 09H
	INT 21H
	LEA DX, DATA2
	MOV AH,0AH
	INT 21H
	LEA DX, RETURN
	MOV AH,09H
	INT 21H
	CMP BYTE PTR DATA2[1], 4
	JA OVERFLOW2
	LEA DI, DATA2
	MOV CX, 0
	MOV CL, DATA2[1]
	CALL CHANGE
	CMP BX, 16
	JE  NUM2_IN
	PUSH AX
	JMP ADD_NUM
	
	OVERFLOW2:
	LEA DX, OVERFLOW
	MOV AH, 09H
	INT 21H	
	JMP NUM2_IN

ADD_NUM:
		
	POP BX              ;Pop the two numbers and add
	POP AX
	ADD AX,BX

	JNC PRINT_OUT   	;Check if overflow
	
	LEA DX, OVERFLOW
	MOV AH, 09H
	INT 21H
	JMP EXIT
	
PRINT_OUT:
	
	PUSH AX
	
	MOV CX, 4
	MOV BX, 16
	MOV DX, 0
	
TO_ASCII:
	DIV BX          ;Divide 16 to get the remainder and change it to a ASCII number
	PUSH DX
	MOV DX, 0
	LOOP TO_ASCII

	MOV CX, 4
ASCII:
	POP BX
	CMP BX, 9
	JA  MORE_THAN_TEN
	ADD BX, '0'
	JMP PRINT
MORE_THAN_TEN:
	SUB BX, 10
	ADD BX, 'A'
PRINT:
	MOV DX, 0
	MOV DX, BX
	MOV AH, 02H
    INT 21H
	LOOP ASCII
	
EXIT:

	MOV AH, 4CH
	INT 21H

TONUM PROC NEAR          ;This subprogram is used to change a ASCII number to a hexadecimal number
	CMP BL, '0'			 ;Check if the input is a number 
	JB  WRONG_INPUT
	CMP BL, '9'
	JA  UPPER_HEX
	SUB BL, '0'			;Change it to a hexadecimal number
	RET
	
UPPER_HEX:				;or upper-case letter A-F 
	CMP BL,'A'
	JB  WRONG_INPUT
	CMP BL,'F'
	JA  LOWER_HEX
	SUB BL, 'A'			;Change it to a hexadecimal number
	ADD BL, 10
	RET
	
	
LOWER_HEX:				;or lower-case letter a-f 
	CMP BL,'a'
	JB  WRONG_INPUT
	CMP BL,'f'
	JA  WRONG_INPUT
	SUB BL,'a'			;Change it to a hexadecimal number
	ADD BL, 10
	RET
	
WRONG_INPUT:
	LEA DX, WRONG
	MOV AH, 09H
	INT 21H
	MOV BX, 16			;Else the input is invalid, save 16 in BX to return a error message
	RET
TONUM ENDP 
	
CHANGE PROC NEAR		;This subprogram is used to Change a string into a hexadecimal number

	ADD DI, 2			;Move the index to the first letter
	MOV AX, 0
	CAL:
    MOV BX, 16   		;total multiply by 16 to make the bits move forward
	MUL BX
	MOV BL, [DI]		;Get the letter and pass it to the function TONUM
	INC DI
	CALL TONUM			;Call function TONUM
	CMP  BX, 16
	JNE   NEXT
	RET
	NEXT:
	ADD AX, BX			;Add the new number to the total
	LOOP CAL

	RET
CHANGE ENDP 
	
CODE ENDS

END ADDER