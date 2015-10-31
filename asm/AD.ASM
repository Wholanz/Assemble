DATA SEGMENT 'DATA'
	PROMPT1 DB 'INPUT THE INTERRUPT SIGNAL',13,10,'$'
        NUMBER DB 8 DUP(?),13,10,'$'
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

        MOV DX, 0DE23H
        MOV AL, 00010110B
        OUT DX, AL
        MOV AL, 01010110B
        OUT DX, AL
        
	
        MOV DX, 0DE20H
        MOV AL, 250
        OUT DX, AL
        MOV DX, 0DE21H
        MOV AL, 13
        OUT DX, AL
       

        MOV AH, 00H
        MOV AL, 2
        INT 10H

        MOV AH,06H
        MOV AL,00H
        MOV BH,07H
        MOV CH,00H
        MOV CL,00H
        MOV DH,24
        MOV DL,79
        INT 10H


	;MOV SRC, 10
	;DIV SRC
	
COPY:


	MOV DX, 0DE03H
        MOV AL, 10000110B
	OUT DX, AL
	
	
	MOV AL, 00000000B
	OUT DX, AL
	NOP
	NOP
        NOP

	OR  AL, 00000101B
	OUT DX, AL
        
        
	MOV DX, 0DCCCH		
	IN AL, DX	
	MOV irqmark, AL		
	OR  AL, 5BH
	OUT DX, AL			



	MOV AH, 35H
	MOV AL, 0AH
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

                   
        MOV DX, 0DE80H
        OUT DX, AL
       
        MOV CX, 0
        ;MOV BX, CX
CHECK: 
        CMP CX, 200


        JB CHECK

RECOVER:

       
        MOV AL, 17H
	MOV DX, 0DCCCH
	OUT DX, AL

        MOV AL, intmark1
        OR AL, 00000100B
        OUT 21H, AL              
	MOV AL, intmark2	
        OR AL, 000000010B
	OUT 0A1H, AL		

	
	MOV AX, csreg			
	MOV DS, AX
	MOV DX, ipreg	
	MOV AH, 25H
	MOV AL, 71H
	INT 21H						

EXIT: 
	
	MOV AH, 4CH
	INT 21H

PRINT PROC NEAR

        PUSH AX
	PUSH CX
	PUSH BX
	PUSH DX

        MOV DL, AL
        MOV BL, 10
        MOV AH, 0
        DIV BL

        MOV AH,0
        MOV DH, AL
  
       
        MOV BX, 80
        MOV AX, CX
        DIV BL
        MOV DL, AH
        MOV BL, 0
        MOV BH, AL
       

        MOV AH,02H
        INT 10H       
        ;MOV BH,00H     ;PAGE
        ;MOV DH,AL      ;ROW
        ;MOV DL,CL      ;COL
        ;INT 10H
        
        MOV AH, 05H
        MOV AL, BH
        INT 10H

        MOV AH,02H
        MOV DL,'*'      ;ASCII
        INT 21H



       ; MOV DL, AL
       ; MOV AH, 02H
       ; INT 21H

        
	POP DX
	POP BX
        POP CX
        POP AX
       
        RET

PRINT ENDP

INTERRUPT:
	JMP NEXT
	PROMPT2 DB 'THIS IS SXL_100 INTERRUPT',13,10,'$'
NEXT:

        NOP
        NOP
        NOP
        CLI

	PUSH BX
	PUSH CX
	PUSH DX


       ; MOV DX, 0DE01H
       ; MOV AX, 0
       ; IN  AL, DX

        MOV DX, 0DE80H
        MOV AX, 0
        IN AL, DX
        ;mov al,'*'
	PUSH AX

        CALL PRINT

        MOV AL, 00100000B
	OUT 20H, AL			
	OUT 0A0H, AL			
	

	MOV DX, 0DCCDH
	IN AL, DX
	OR AL, 0CH
	OUT DX, AL		


        MOV DX, 0DE80H
        OUT DX, AL 
	
	POP AX

	POP DX
	POP CX
	POP BX	
	

	ADD CX, 1
	STI
	IRET
	
MAIN ENDP



CODE ENDS

END MAIN
