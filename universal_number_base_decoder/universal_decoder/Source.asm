.686
.model flat

extern	_ExitProcess@4	:PROC
extern	__read			:PROC
extern	__write			:PROC

public	_main

.data
	in_base		db	20
	out_base	db	10
	decoder		db	'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	dzielnik dd 10
	znaki db 12 dup (?)
	w0 dd 0
	w1 dd 0
	w2 dd 0
.code

_main PROC
	mov ecx,-1  ; ecx:edx:eax
	mov edx,-1
	mov eax,-1
	call _wyswietl_EAX
	push 0
	call _ExitProcess@4


	push	0
	call	_ExitProcess@4

_main ENDP

_suma PROC
	push ebp			; prolog
	mov ebp,esp  

	mov eax,[ebp+8]
	add eax,[ebp+12]
	
	pop ebp
	ret
_suma ENDP

_wyswietl_EAX PROC
	push ebp
	mov ebp,esp
	sub esp,36  ; rezerwacja zmiennej dynamicznej
	pushad
	;mov eax,[ebp+8]
	mov	w2,ecx
	mov w1,edx	; a2 == w2
	mov w0,eax

	mov edi,esp
	;lea edi,[ebp-12]
		
	mov esi, 34 ; indeks w tablicy 'znaki' 
	mov ebx, 10 ; dzielnik równy 10
konwersja: 
	mov edx, 0; zerowanie starszej czêœci dzielnej 

	mov	eax, w2
	div ebx
	mov	w2, eax


	mov eax,w1
	div ebx ; dzielenie przez 10, reszta w EDX, 
			; iloraz w EAX 

	mov  w1,eax
	mov eax,w0
	div ebx
	mov w0,eax
	add dl, 30H ; zamiana reszty z dzielenia na kod ASCII 
	mov [edi][esi], dl; zapisanie cyfry w kodzie ASCII
	dec esi ; zmniejszenie indeksu 
	;cmp eax, 0 ; sprawdzenie czy iloraz = 0 
	or eax,w1
	jne konwersja ; skok, gdy iloraz niezerowy
; wype³nienie pozosta³ych bajtów spacjami i wpisanie 
; znaków nowego wiersza 
wypeln: 
	or esi, esi		; cmp esi,0
	jz wyswietl ; skok, gdy ESI = 0 
	mov byte PTR [edi][esi], 20H ; kod spacji 
	dec esi ; zmniejszenie indeksu 
	jmp wypeln 

wyswietl: 
	mov byte PTR [edi+0], 0AH ; kod nowego wiersza 
	mov byte PTR [edi][35], 0AH ; kod nowego wiersza
; wyœwietlenie cyfr na ekranie 
	push dword PTR 36 ; liczba wyœwietlanych znaków 
	;push dword PTR OFFSET znaki ; adres wyœw. obszaru 
	push edi
	push dword PTR 1; numer urz¹dzenia (ekran ma numer 1) 
	call __write ; wyœwietlenie liczby na ekranie 
	add esp, 12 ; usuniêcie parametrów ze stosu

	
	popad
	add esp,24	; usuniêcie zmiennej dynamicznej
	pop ebp
	ret
_wyswietl_EAX ENDP






_read_to_EAX PROC
	push	edi
	push	ebx
	push	esi

	sub		esp, 12
	mov		edi, esp

	push	10
	push	edi
	push	0
	call	__read
	add		esp, 12

	mov		eax, 0
	mov		al, in_base
	;movzx	eax, BYTE PTR in_base
	movzx	esi, al
	mov		eax, 0

	main_lp:
		mov		ebx, 0
		mov		bl, [edi]
		inc		edi
		cmp		bl, 0ah
		je		_end
		cmp		bl, '0'
		jb		main_lp
		cmp		bl, '9'
		ja		abup_case
		sub		bl, '0'
		mul		esi
		add		eax, ebx
		jmp		main_lp

		abup_case:
		cmp		bl, 'A'
		jb		main_lp
		cmp		bl, 'Z'
		ja		ablow_case
		sub		bl, 'A'
		add		bl, 10
		mul		esi
		add		eax, ebx
		jmp		main_lp

		ablow_case:
		cmp		bl, 'a'
		jb		main_lp
		cmp		bl, 'z'
		ja		main_lp
		sub		bl, 'a'
		add		bl, 10
		mul		esi
		add		eax, ebx
		jmp		main_lp

	_end:
		add		esp, 12
		pop		esi
		pop		ebx
		pop		edi
		ret

_read_to_EAX ENDP

_read_to_EAXDX_64 PROC
	push	ebx
	push	edi
	push	ecx
	push	esi

	sub		esp, 20
	mov		edi, esp
	
	push	20
	push	edi
	push	0
	call	__read
	add		esp, 12

	mov		eax, 0
	mov		edx, 0
	
	main_lp:
		mov		cl, [edi]
		inc		edi
		cmp		cl, 0ah
		je		_end
		sub		cl, 30h
		movzx	ecx, cl

		mov		esi, eax
		mov		ebx, edx

		;times 8
		shl		eax,1
		rcl		edx,1
		
		shl		eax,1
		rcl		edx,1

		shl		eax,1
		rcl		edx,1

		;times 2
		shl		esi, 1
		rcl		ebx, 1

		;add times 2, times 8 = times 10
		add		eax, esi
		adc		edx, ebx

		add		eax, ecx
		adc		edx, 0
		
		jmp	main_lp


	_end:
		add		esp, 20


	pop		esi
	pop		ecx
	pop		edi
	pop		ebx
	
	ret
_read_to_EAXDX_64 ENDP

_write_EAX	PROC
	pusha

	mov		esi, 10
	movzx	ebx, out_base

	mov		edi, esp ;end of the string
	sub		esp, 12
	mov		ebp, esp ;start of the string

	mov		[esp], BYTE PTR	0ah
	mov		[edi - 1], BYTE PTR 0ah
	dec		edi

	main_lp:
		mov		edx, 0
		div		ebx 
		mov		cl, decoder[edx]
		mov		[edi], cl
		dec		edi
		cmp		edi, ebp
		je		show
		jmp		main_lp

	show:
		mov		ecx, 11
		inc		ebp
		extract_zero:
			mov		al, [ebp]
			cmp		al, '0'
			jne		end_extr
			inc		ebp
			dec		ecx
			dec		ecx
			jmp		extract_zero

		end_extr:
			;inc		ecx ;in for write to consider 0ah
			push	ecx
			push	ebp
			push	1
			call	__write
			add		esp, 12

	add		esp, 12
	popa
	ret

_write_EAX	ENDP






read_value_to_EAX_hex	PROC
push	ebx
push	ecx
push	edx
push	esi
push	edi
push	ebp

sub		esp, 12
mov		esi, esp

push	dword PTR 10
push	esi
push	dword PTR 0
call	__read

add		esp, 12

mov		eax, 0

start_transl:
	mov		dl, [esi]
	inc		esi
	cmp		dl, 10
	je		ready
	cmp		dl, '0'
	jb		start_transl
	cmp		dl, '9'
	ja		continue_chck1
	sub		dl, '0'

_add:
	shl		eax, 4
	or		al, dl
	jmp		start_transl


continue_chck1:
	cmp		dl, 'A'
	jb		start_transl
	cmp		dl, 'F'
	ja		continue_chck2
	sub		dl, 'A' - 10
	jmp		_add

continue_chck2:
	cmp		dl, 'a'
	jb		start_transl
	cmp		dl, 'f'
	ja		start_transl
	sub		dl, 'a' - 10
	jmp		_add

ready:
	add		esp, 12
	
	pop		ebp
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	ret


read_value_to_EAX_hex	ENDP

print_EAX_hex	PROC
	pusha
	;dynamiczna rezerwacja pamieci na stosie
	sub		esp, 12
	mov		edi, esp
	
	;inicjalizacja petli
	mov		ecx, 8
	mov		esi, 1
	main_lp_hex:
		
		rol		eax, 4
		mov		ebx, eax
		and		ebx, 0fh
		mov		dl,	decoder[ebx]
		mov		[edi][esi], dl
		inc		esi
		loop	main_lp_hex
	
	mov		esi,	1
	rep_for_space:
		mov		dl, [edi][esi]
		cmp		dl, '0'
		jne	    done
		mov		byte PTR [edi][esi], ' '
		inc		esi
		loop	rep_for_space

	done:
		mov		byte PTR [edi][0], 0ah
		mov     byte PTR [edi][11], 0ah

		push	9
		push	edi
		push	1
		call	__write

		add		esp, 24

	popa
	ret
print_EAX_hex	ENDP

zad_ciag PROC
	pusha
	
	call	_read_to_EAX
	mov		ebx, eax ;p w ebx (pierwszy element ciagu)
	call	_read_to_EAX
	mov		ecx, eax ;n w ecx (ilosc elementow ciagu do wyswietlenia)
	mov		esi, 0	 ;flaga czy odjac (1) czy dodac (0)

	mov		edx, 0

	main_lp:
		mov		eax, ebx
		or		esi, 0
		jz		add_case
		
		sub_case:
		mov		esi, 0
		sub		eax, edx

		continue:
		call	_write_EAX		
		inc		edx
		dec		ecx
		jz		_end
		jmp		main_lp
		
		add_case:
		mov		esi, 1
		add		eax, edx
		jmp	continue


	_end:
		popa
		ret
zad_ciag ENDP

zad_podziel_float PROC
	pusha
		sub	esp, 4
		mov	ebp, esp

		mov	[ebp], BYTE PTR '.'

		call	_read_to_EAX
		mov		ebx, eax
		call	_read_to_EAX
		mov		ecx, eax
		
		mov		eax, ebx

		div		ecx
		call	_write_EAX
		
		push	eax
		push	edx
		push	ecx

		push	1
		push	ebp
		push	1
		call	__write
		add		esp, 12
		
		pop		ecx
		pop		edx
		pop		eax
		add		esp, 4

		mov		eax, edx
		mov		esi, 1000
		mul		esi

		div		ecx
		call	_write_EAX



	popa
	ret
zad_podziel_float ENDP


END
