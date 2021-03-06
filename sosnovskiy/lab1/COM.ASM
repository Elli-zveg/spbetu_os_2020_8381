TESTPC SEGMENT
	ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
	ORG 100H

START: JMP BEGIN

pc db 'PC', 0dh, 0ah, '$'
pc_xt db 'PC/XT', 0dh, 0ah, '$'
at_ db	'AT', 0dh, 0ah, '$'
ps2_30 db 'PS2 model 30', 0dh, 0ah, '$'
ps2_5060 db 'PS2 model 50/60', 0dh, 0ah, '$'
ps2_80 db 'PS2 model 80', 0dh, 0ah, '$'
pcjr db 'PCjr', 0dh, 0ah, '$'
pc_convertible db 'PC Convertible', 0dh, 0ah, '$'

pc_type db	'��� PC: ','$'
msdos_version db '����� MS DOS:  . ', 0dh, 0ah, '$'
oem_number	db '����� ���:     ', 0dh, 0ah, '$'
serial_number db	'��਩�� �����:     ', 0dh, 0ah, '$'

;��楤���
	
;��ॢ�� ����� �.��.
tetr_to_hex	proc near
	and	al, 0fh
	cmp al, 09
	jbe	next
	add	al, 07
	next: add al, 30h
	ret
tetr_to_hex	endp

byte_to_hex	proc near
	push cx
	mov	al, ah
	call tetr_to_hex
	xchg al, ah
	mov	cl, 4
	shr	al, cl
	call tetr_to_hex 
	pop	cx 			
	ret
byte_to_hex	endp

word_to_hex	proc near
	push bx
	mov	bh, ah
	call byte_to_hex
	mov [di], ah
	dec	di
	mov [di], al
	dec	di
	mov	al, bh
	xor	ah, ah
	call byte_to_hex
	mov	[di], ah
	dec	di
	mov	[di], al
	pop	bx
	ret
word_to_hex	endp

byte_to_dec	proc near
	push cx
	push dx
	push ax
	xor	ah, ah
	xor	dx, dx
	mov	cx, 10
loop_bd: 
	div	cx
	or dl, 30h
	mov	[si], dl
	dec	si
	xor	dx, dx
	cmp	ax, 10
	jae	loop_bd
	cmp	ax, 00h
	jbe	end_l
	or al, 30h
	mov	[si], al
end_l:	
	pop	ax
	pop	dx
	pop	cx
	ret
byte_to_dec	endp

;�뢮� ��ப
print proc near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
print endp

print_a_pc_type:
	call print
	jmp GET_OS

print_pc:
	mov dx, offset pc
	jmp print_a_pc_type
	
print_pc_xt:
	mov dx, offset pc_xt
	jmp print_a_pc_type
	
print_at:
	mov dx, offset at_
	jmp print_a_pc_type
	
print_ps2_30:
	mov dx, offset ps2_30
	jmp print_a_pc_type

print_ps2_5060:
	mov dx, offset ps2_5060
	jmp print_a_pc_type
	
print_ps2_80:
	mov dx, offset ps2_80
	jmp print_a_pc_type
	
print_pcjr:
	mov dx, offset pcjr
	jmp print_a_pc_type
	
print_pc_convertible:
	mov dx, offset pc_convertible
	jmp print_a_pc_type

;�᭮��� ��楤���
BEGIN:
GET_PC:
	push dx
	push ax
	
	mov dx, offset pc_type
	call print ; �뢮�: "��� PC: "
	
	mov ax, 0F000h ;㪠�뢠�� ES �� ���
	mov es, ax
	mov al, es:[0FFFEh]
	
	;����砥� � al ���祭�� ���� ⨯� IBM PC
	mov ax, 0F000h 
	mov es, ax
	mov al, es:[0FFFEh]
	
	;FF => PC
	cmp al, 0FFh
	je print_pc
	
	;FE, FB => PC/XT
	cmp al, 0FEh
	je print_pc_xt
	cmp al, 0FBh
	je print_pc_xt
	
	;FC => AT
	cmp al, 0FCh
	je print_at
	
	;FA => ps2_30
	cmp al, 0FAh
	je print_ps2_30
	
	;FC => ps2_5060
	cmp al, 0FCh
	je print_ps2_5060
	
	;F8 => ps2_80
	cmp al, 0F8h
	je print_ps2_80
	
	;FD => PCjr
	cmp al, 0FDh
	je print_pcjr
	
	;F9 => PC convertible
	cmp al, 0F9h
	je print_pcjr


GET_OS:
;��室�� ��ࠬ����:
;al - �᭮���� �����, ah - ����䨪���, bh - OEM, bl:cx - 24 ��⮢� �਩�� ����� ���짮��⥫�
	mov ah, 30h
	int 21h 
	
	lea si, msdos_version
	add si, 15	
	;�����뢠�� �᭮���� ���ᨡ
	call byte_to_dec 	
	add	si, 3
	;������ ����� ����䨪�樨 � al
	mov al, ah
	;����� ����� ����䨪�樨
	call byte_to_dec
	mov dx, offset msdos_version
	call print

GET_OEM:
	mov al, bh
	lea si, oem_number
	add si, 11
	call byte_to_dec
	mov dx, offset oem_number
	call print

GET_SERIAL_NUMBER:
	mov	al, bl
	lea si, serial_number
	add si, 16
	call byte_to_hex
	mov [si], ax
	add	si, 6
	mov	di, si
	mov ax, cx
	call word_to_hex
	mov dx, offset serial_number
	call print


	pop di
	pop si
	pop dx
	pop	ax	
	mov ah, 4ch
	int	21h
	ret 

TESTPC ends
end START