.686
.model flat

extern	_ExitProcess@4		:PROC
extern  _MessageBoxW@16		:PROC

public	_main

.data
	bufor	db	50H, 6FH, 0C5H, 82H, 0C4H, 85H, 63H, 7AH, 65H, 6EH, 69H, 61H, 20H
		;	db	0f0h,5fh,90h,88h   ; utf-8
			db	0F0H, 9FH, 9AH, 82H   ; parowoz
			db	20H, 20H, 6BH, 6FH, 6CH, 65H, 6AH, 6FH, 77H, 6FH, 20H
			db	0E2H, 80H, 93H ; polpauza
			db	20H, 61H, 75H, 74H, 6FH, 62H, 75H, 73H, 6FH, 77H, 65H, 20H, 20H
			db	0F0H,  9FH,  9AH,  8CH, 0h; autobus 

	final	db	80 dup (?)
	_title	dw	'U', 't', 'f','-','8'

.code
_main PROC
	mov		esi, 0
	mov		edi, 0
	mov		ecx, (OFFSET final) - (OFFSET bufor)
		
	main_lp:
		mov		edx, 0
		mov		dl, bufor[esi]
		add		esi, 1
		cmp		dl, 7fh
		ja		multy_bait_utf
		mov		WORD PTR final[edi], dx
		add		edi, 2 ;o 2 bo utf_16
		
		dec		ecx
		jz		_end
		jmp		main_lp


	multy_bait_utf:
		cmp		dl, 0E0h 
		jb		two_bait_case
		cmp		dl, 0F0h
		jb		three_bait_case
		jmp		four_bait_case

	two_bait_case:
	;dx = 10xx xxxx 110x xxxx bcs LE
		mov		dh, bufor[esi]
		add		esi, 1
		xchg	dh, dl	;dx = 110x xxxx 10xx xxxx
		shl		dh, 3
		shr     dh, 3;dh = 000x xxxx
		shl		dl, 2 ;dl = xxxx xx00
		shr		dx, 2 ;dx = 0000 0xxx xxxx xxxx
		mov		WORD PTR final[edi], dx 

		add		edi, 2
		
		
		sub		ecx, 2
		jz		_end
		jmp		main_lp


	three_bait_case:
	;1110 xxxx 10xx xxxx 10xx xxxx
	movzx	eax, dl
	shl		eax, 16
	mov		ax, WORD PTR bufor[esi]
	add		esi, 2
	xchg	al, ah
	shl		al, 2
	shl		ax, 2
	shr		eax, 4

	mov		WORD PTR final[edi], ax
	
	add		edi, 2
	sub		ecx, 3
	jz		_end
	jmp		main_lp
	
	four_bait_case:
	
	movzx	eax, dl
	and		al, 00000111b
	shl		eax, 16
	mov		ax,WORD PTR bufor[esi] 

	add		esi, 2
	xchg	al, ah	; 0000 0000 0000 0xxx 10xx xxxx 10xx xxxx
	shl		al, 2
	shl		ax, 2
	shl		eax, 6
	mov		al, bufor[esi] ;0000 0000 0xxx xxxx xxxx xxxx 10xx xxxx
	add		esi, 1
	shl		al, 2
	shr		eax, 2	;unicode  0000 0000 000x xxxx xxxx xxxx xxxx xxxx 
	sub		eax, 10000h ;0000 0000 0000 xxxx xxxx xxxx xxxx xxxx 
	shl		eax, 6
	shr		ax, 6
	or		eax, 11011000000000001101110000000000b
	mov		DWORD PTR final[edi], eax
	add		edi, 4
	
	sub		ecx, 4
	jz		_end
	jmp		main_lp







	_end:
		push	DWORD PTR 0
		push	DWORD PTR OFFSET _title
		push	DWORD PTR OFFSET final
		push	DWORD PTR 0
		call	_MessageBoxW@16
		
		push	DWORD PTR 0
		call	_ExitProcess@4

_main ENDP
END

