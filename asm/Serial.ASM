data segment
	pciport3 EQU 0DE00H ;pci address3 
	pcCom EQU 3F8H ;pc com
	pciCom EQU 0DE10H
	pcSendHit DB "pc send:$"
	pciReceiveHit DB "pci receive:$"
	pciSendHit DB "pci send:$"
	pcReceiveHit DB "pc receive:$"
	exitHit DB "exit? (q)$"
data ends

code segment
	assume cs:code, ds:data
START:
	mov ax,data
	mov ds,ax ;将数据段的段地址赋给ds

	mov al,80H
	mov dx,pcCom+3
	out dx,al
	mov ax,960
	mov dx,pcCom
	out dx,al
	mov al,ah
	mov dx,pcCom+1
	out dx,al
	mov al,00001011B
	mov dx,pcCom+3
	out dx,al
	mov al,00000111B
	mov dx,pcCom+2
	out dx,al

	mov al,80H
	mov dx,pciCom+3
	out dx,al
	mov ax,960
	mov dx,pciCom
	out dx,al
	mov al,ah
	mov dx,pciCom+1
	out dx,al
	mov al,00001011B
	mov dx,pciCom+3
	out dx,al
	mov al,00000111B
	mov dx,pciCom+2
	out dx,al
        ;mov dx,pciCom
        ;in  al,dx
MAIN:
	call NEWLINE
	call PCSEND
	call PCIRECEIVE
	call NEWLINE
	call PCISEND
	call PCRECEIVE
	call NEWLINE
	mov dx,offset exitHit
	mov ah,09H
	int 21H
	mov ah,01H
	int 21H
	cmp al,'q'
	jne MAIN
EXIT:
	mov ah,4ch
	int 21H 	;调用int 21的4ch中断结束程序
PCSEND PROC NEAR
	mov dx,offset pcSendHit
	mov ah,09H
	int 21H
	mov ah,01H
	int 21H
	mov ah,al
PCSENDLOOP:
	mov dx,pcCom+5
	in  al,dx
	test al,20H
	jz PCSENDLOOP
	mov al,ah
	mov dx,pcCom
	out dx,al
	mov ah,02H
	mov dl,20H
	int 21H
	ret
PCSEND ENDP

PCRECEIVE PROC NEAR
	mov dx,offset pcReceiveHit
	mov ah,09H
	int 21H
PCRECEIVELOOP:
	mov dx,pcCom+5
	in  al,dx
	test al,1
	jz PCRECEIVELOOP
	mov ah,al
	mov dx,pcCom
	in  al,dx
	test ah,0EH
	jz  PCRECEIVENEXT
	mov al,'?'
PCRECEIVENEXT:
	mov ah,02H
	mov dl,al
	int 21H
	ret
PCRECEIVE ENDP

PCISEND PROC NEAR
	mov dx,offset pciSendHit
	mov ah,09H
	int 21H
	mov ah,01H
	int 21H
	mov ah,al
PCISENDLOOP:
	mov dx,pciCom+5
	in  al,dx
	test al,20H
	jz PCISENDLOOP
	mov al,ah
	mov dx,pciCom
	out dx,al
	mov ah,02H
	mov dl,20H
	int 21H
	ret
PCISEND ENDP

PCIRECEIVE PROC NEAR
	mov dx,offset pciReceiveHit
	mov ah,09H
	int 21H
PCIRECEIVELOOP:
	mov dx,pciCom+5
	in  al,dx
	test al,1
	jz PCIRECEIVELOOP
	mov ah,al
	mov dx,pciCom
	in  al,dx
	test ah,0EH
	jz  PCIRECEIVENEXT
	mov al,'?'
PCIRECEIVENEXT:
	mov ah,02H
	mov dl,al
	int 21H
	ret
PCIRECEIVE ENDP

NEWLINE PROC NEAR
	mov ah,02H
	mov dl,0aH
	int 21H
	mov dl,0dH
	int 21H
	ret
NEWLINE endp
code ends
end start
