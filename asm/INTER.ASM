DATA SEGMENT 'DATA'
	PROMPT1 DB 'INPUT THE INTERRUPT SIGNAL',13,10,'$'
	
	csreg   DW ?
	ipreg   DW ?
	intmark1 DB ?
	intmark2 DB ?
	irqmark  DB ?
DATA ENDS

STACK SEGMENT STACK

STACK ENDS

CODE SEGMENT 'CODE'
	ASSUME CS:CODE, SS:STACK, DS:DATA, ES:DATA

MAIN PROC FAR

	MOV AX, DATA
	MOV DS, AX
	MOV ES, AX

COPY:


	MOV DX, 0DCCCH		
	IN AL, DX	
	MOV irqmark, AL		
	OR  AL, 5BH
	OUT DX, AL			

	MOV AH, 35H
	MOV AL, 71H
	INT 21H				
	MOV AX, ES
	MOV csreg, AX
	MOV ipreg, BX      
	
	MOV AX, CS			
	MOV DS, AX
	MOV DX, OFFSET INTERRUPT	
	MOV AH, 25H
	MOV AL, 71H
	INT 21H						
	
	IN AL, 21H	
	MOV intmark1, AL
	AND AL, 11111011B
	OUT 21H, AL			
	IN AL, 0A1H			
	MOV intmark2, AL
	AND AL, 11111101B
	OUT 0A1H, AL		

        
	MOV CX, 0
CHECK: 
	CMP CX, 10
        JB CHECK

RECOVER:
	MOV AL, intmark1
        OR AL, 00000100B
        OUT 21H, AL              
	MOV AL, intmark2	
        OR AL, 000000010B
	OUT 0A1H, AL		

        ;MOV AL, irqmark
         MOV AL, 17H
	MOV DX, 0DCCCH
	OUT DX, AL			
	
	MOV AX, csreg			
	MOV DS, AX
	MOV DX, ipreg	
	MOV AH, 25H
	MOV AL, 71H
	INT 21H						

EXIT: 
	
	MOV AH, 4CH
	INT 21H

INTERRUPT:
	JMP NEXT
	PROMPT2 DB 'THIS IS SXL_100 INTERRUPT',13,10,'$'
NEXT:	
	
        
	MOV DX,OFFSET PROMPT2
	MOV AH, 09H
	INT 21H

        CLI

	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
			
        MOV AL, 00100000B
	OUT 20H, AL			
	OUT 0A0H, AL			
	

	MOV DX, 0DCCDH
	IN AL, DX
	OR AL, 0CH
	OUT DX, AL			
	
	POP DX
	POP CX
	POP BX
	POP AX	
	
	ADD CX, 1
	STI
	IRET

	MOV AH, 4CH
	INT 21H
	
MAIN ENDP



CODE ENDS

END MAIN
