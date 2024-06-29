.686
.model flat

public	_read_uni_64
public	_write_uni_64

extern	__write			:PROC
extern	__read			:PROC
extern	_ExitProcess@4	:PROC
.data

decoder		db '0123456789ABCDEFGHIJKLMNOP'

.code

;_main	PROC
;	
;	push	10
;	call	_read_uni_64
;	add		esp, 4
;
;	push	0
;	call	_ExitProcess@4
;_main	ENDP

;int read_uni_64(int in_base)
_read_uni_64	PROC		;funkcja wczyta i zapisze na eax:edx liczbe w wybranym systemie 
	push	ebp	
	mov		ebp, esp
	push	esi
	push	edi
	push	ebx

	sub		esp, 68
	mov		ebx, esp		;lokazlizacja wczytanej liczby

	push	68
	push	ebx
	push	0
	call	__read
	add		esp, 12

	xor		eax, eax
	xor		edx, edx
	xor		ecx, ecx

	main_lp:
		mov		cl, [ebx]
		cmp		cl, 0ah
		je		_end

		mov		esi, eax
		mov		edi, edx
		mov		cl, [ebp + 8]	;podstawa systemu pobrana z argumentu
		dec		cl

		mul_times_base:
			add		eax, esi
			adc		edx, edi
			dec		cl
			jnz		mul_times_base
		
ignore:	mov		cl, [ebx]
		inc		ebx

		cmp		cl, '0'
		jb		ignore
		cmp		cl, 'a'
		jae		letter_case
		sub		cl, '0'
		jmp		_add

	letter_case:
		sub		cl, 'a'
		add		cl, 10

	_add:
		add		eax, ecx
		adc		edx, 0

		jmp		main_lp
	
	_end:
	add		esp, 68
	pop		esi
	pop		edi
	pop		ebx
	pop		ebp
	ret
_read_uni_64	ENDP

;void write(unsinged long long int num, int out_base)
_write_uni_64	PROC
	push	ebp
	mov		ebp, esp	
	push	edi
	push	ebx
	push	esi


	mov		eax, [ebp + 8]	;mlodsza czesc liczby
	mov		edx, [ebp + 12]	;starsza czesc liczby
	mov		cx,  [ebp + 16]	;podstawa systemowa
	movzx	ecx, cx

	sub		esp, 68
	mov		edi, esp

	push	edi


	mov		BYTE PTR [edi], 0ah
	add		edi, 65
	mov		BYTE PTR [edi], 0ah
	dec		edi

	mov		esi, eax		;przechowanie mlodszej czesci (eax)
	mov		ebx, edx		;przechowanie starszej czesci (edx)

	main_lp:
		xor		edx, edx
		mov		eax, ebx
		div		ecx
		mov		ebx, eax

		mov		eax, esi
		div		ecx
		mov		esi, eax
		mov		[edi], decoder[dl]
		dec		edi
		or		esi, ebx
		jnz		main_lp	

	fill_zeros:
		mov		BYTE PTR [edi], '0'
		dec		edi
		cmp		edi, [esp]
		jnz		fill_zeros

	pop		edi
	push	66
	push	edi
	push	1
	call	__read

	add		esp, 68 + 12

	pop		esi
	pop		ebx
	pop		edi
	pop		ebp
	ret
_write_uni_64	ENDP

END