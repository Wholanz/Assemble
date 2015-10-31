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
        MOV AL, 200
        OUT DX, AL
        MOV DX, 0DE21H
        MOV AL, 200
        OUT DX, AL
       

COPY:


	MOV DX, 0DE03H
        MOV AL, 10000000B
	OUT DX, AL
	
	MOV DX, 0DE01H
        MOV AX, 0EEEEH
	OUT DX, AL
	
	MOV DX, 0DE00H
	MOV AL, 0F9H
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
        
CHECK: 
        CMP CX, 30000
        JMP CHECK

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

ANODE_CHANGE PROC NEAR

        JMP BEGIN

        ANODE DW 0EEEEH
	
	MONTH_UNITS DB 1
	MONTH_TENS DB 0
        DAY_UNITS DB 1
        DAY_TENS DB 0

        TIME_COUNT DW 0

        SEG_CHART DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,
                     80H,98H

	SET_FLAG DB 0
	

	MTENS_SET DB "Month tens set!",13,10,'$'
	MUNITS_SET DB "Month units set!",13,10,'$'
	DTENS_SET DB "Day tens set!",13,10,'$'
	DUNITS_SET DB "Day units set!",13,10,'$'
	

BEGIN:


        PUSH AX
	PUSH CX
	PUSH BX
	PUSH DX
	
	CMP SET_FLAG, 0
	JNE CONTINUE
	

	MOV DX, 0DE03H
        MOV AL, 10010001B
	OUT DX, AL

	MOV SET_FLAG, 1
	
	MOV DX, OFFSET MTENS_SET
	MOV AH, 09H
	INT 21H
	CALL DATE_SET
	MOV MONTH_TENS, AL
	
	MOV DX, OFFSET MUNITS_SET
	MOV AH, 09H
	INT 21H
	CALL DATE_SET
	MOV MONTH_UNITS, AL
	
	MOV DX, OFFSET DTENS_SET
	MOV AH, 09H
	INT 21H
	CALL DATE_SET
	MOV DAY_TENS, AL


	MOV DX, OFFSET DUNITS_SET
	MOV AH, 09H
	INT 21H
	CALL DATE_SET
	MOV DAY_UNITS, AL

	MOV DX, 0DE03H
        MOV AL, 10000000B
	OUT DX, AL

CONTINUE:
        MOV AX, TIME_COUNT
        CMP AX, 2500
        JB DISPLAY

        MOV AX, 0
        MOV TIME_COUNT, AX

        MOV AL, DAY_UNITS
        MOV AH, DAY_TENS
        MOV BL, MONTH_UNITS
        MOV BH, MONTH_TENS

        CALL DATE_CHANGE

        MOV DAY_UNITS, AL
        MOV DAY_TENS, AH
        MOV MONTH_UNITS, BL
        MOV MONTH_TENS, BH


DISPLAY:

        MOV AX, TIME_COUNT
        ADD AX, 1
        MOV TIME_COUNT, AX


        MOV AX, ANODE
        ROL AX, 1
	MOV DX, 0DE01H
	OUT DX, AL
	

        MOV ANODE, AX
        NOT AL

        TEST AL, 1
        JZ  SECOND
        MOV AL, DAY_UNITS
        JMP SEG_OUT
SECOND:
        TEST AL, 2
        JZ   THIRD
        MOV AL, DAY_TENS
        JMP SEG_OUT
THIRD:
        TEST AL, 4
        JZ   FORTH
        MOV AL, MONTH_UNITS
        JMP SEG_OUT
FORTH:
        MOV AL, MONTH_TENS 

SEG_OUT:
        
        MOV DX, 0DE00H
        MOV BX, OFFSET SEG_CHART
        XLAT
        OUT DX, AL


	POP DX
	POP BX
        POP CX
        POP AX
       
        RET

ANODE_CHANGE ENDP

DATE_CHANGE PROC NEAR

       JMP DATE_CALC
       DAY DB 0  
       MONTH DB 0  

       TENS_DAY DB 1
       UNITS_DAY DB 2
       TENS_MONTH DB 1
       UNITS_MONTH DB 2

DATE_CALC:

        MOV DAY, AL
        MOV AL, AH
        MOV DL, 10
        MUL DL
        MOV AH, DAY
        ADD AL, AH
        MOV DAY, AL

        MOV MONTH, BL
        MOV AL, BH
        MOV DL, 10
        MUL DL
        MOV BH, MONTH
        ADD AL, BH
        MOV MONTH, AL

        MOV AL, DAY
        MOV BL, MONTH


        CMP AL, 28
        JNE MONTH_SMALL_TEST
        CMP BL, 2
        JE NEXT_MONTH
        ADD AL, 1
        MOV DAY, AL
        JMP DATE_SPLIT

MONTH_SMALL_TEST:
        CMP AL, 30
        JNE MONTH_BIG_TEST

        CMP BL, 2
        JE NEXT_MONTH
        CMP BL, 4
        JE NEXT_MONTH
        CMP BL, 6
        JE NEXT_MONTH
        CMP BL, 9
        JE NEXT_MONTH
        CMP BL, 11
        JE NEXT_MONTH

        ADD AL, 1
        MOV DAY, AL
        JMP DATE_SPLIT

MONTH_BIG_TEST:
        CMP AL, 31
        JE NEXT_MONTH

        ADD AL, 1
        MOV DAY, AL
        JMP DATE_SPLIT


NEXT_MONTH:
        MOV AL, 1
        MOV DAY, AL

        CMP BL, 12
        JNB NEXT_YEAR
        ADD BL, 1
        MOV MONTH,BL

        JMP DATE_SPLIT



NEXT_YEAR:
        MOV BL,1
        MOV MONTH, BL
        JMP DATE_SPLIT


DATE_SPLIT:

        MOV AL, DAY
        MOV BL, MONTH
        

        MOV AH, 0
        MOV DL, 10
        DIV DL
        MOV UNITS_DAY, AH
        MOV TENS_DAY, AL

        MOV AH, 0
        MOV AL, BL
        MOV DL, 10
        DIV DL
        MOV UNITS_MONTH, AH
        MOV TENS_MONTH, AL

        MOV AL, UNITS_DAY
        MOV AH, TENS_DAY
        MOV BL, UNITS_MONTH
        MOV BH, TENS_MONTH


        RET

DATE_CHANGE ENDP


DATE_SET PROC NEAR
	
	JMP INPUT
	
	WRONG  DB 'ERROR OCCURS!',13,10,'$'
	
        SCAN_BYTE DB 0,4,8,0CH,1,5,9,0DH,2,6,0AH,0EH,3,7,0BH,0FH


INPUT:
       	MOV CX, 0FFFFH
DELAY1:	
	PUSH CX
	MOV CX, 0AAAH
DELAY2:
	LOOP DELAY2
	POP CX
	LOOP DELAY1 
	
	CALL SCAN

	MOV AL, 0
	MOV DX, 1
	MOV CX, 4
	
CHECK1:	
	TEST BL, DL
	JNZ  ADD1
	SHL  DL, 1
	LOOP CHECK1
	
	MOV DX, OFFSET WRONG
	MOV AH, 09H
	INT 21H
        JMP INPUT
ADD1:
	MOV DX, 4
	SUB DL, CL
	MOV AL, DL
	MOV CL, 2
	SHL AL, CL
	
	MOV CX, 4
	MOV DX, 16
	
CHECK2:
	TEST BL, DL
	JNZ  ADD2
	SHL  DX, 1
	LOOP CHECK2
	
	MOV DX, OFFSET WRONG
	MOV AH, 09H
	INT 21H
        JMP INPUT

ADD2:
	MOV DL, 4
	SUB DL, CL
	ADD AL, DL

	MOV BX, OFFSET SCAN_BYTE
	XLAT 

	RET	

DATE_SET ENDP



SCAN PROC NEAR
	
	MOV DX, 0DE02H
        MOV AL, 11101110B
	OUT DX, AL
        
PRESS:
        PUSH AX
	
	MOV  AH, 0BH
	INT 21H
        CMP AL, 0FFH 
	JE  TERM

        MOV DX, 0DE02H
        IN  AL, DX
        MOV BL, AL   

        OR  AL, 11110000B
        NOT AL
	CMP AL, 0
        JA  RETURN
	POP AX
	ROL AL, 1
        OUT DX, AL
	JMP PRESS
        
	
RETURN:
       
	AND AL, 00001111B
	MOV BL, 0
	MOV BL, AL
	POP AX
        NOT AL
	AND AL, 11110000B
	OR  BL, AL
	RET
TERM:

        POP AX
	MOV BL, 0
	RET
	
SCAN ENDP



INTERRUPT:
	JMP NEXT
	PROMPT2 DB 'THIS IS SXL_100 INTERRUPT',13,10,'$'
NEXT:

        
        CLI

	PUSH BX
	PUSH CX
	PUSH DX

        PUSH AX

        CALL ANODE_CHANGE
        

        MOV AL, 00100000B
	OUT 20H, AL			
	OUT 0A0H, AL			
	

	MOV DX, 0DCCDH
	IN AL, DX
	OR AL, 0CH
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
