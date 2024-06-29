.686
.model flat

extern _diff				:PROC
public _progowanie_sredniej_kroczacej

.code
_progowanie_sredniej_kroczacej	PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 8				;zmienna do przechowania aktualnej sredniej oraz poprzedniej
	push	ebx
	push	edi
	push	esi

	mov		ecx, [ebp + 12]		;k - ilosc elementow w tablicy
	mov		esi, [ebp + 8]		;tablica
	mov		ebx, [ebp + 16]		;m - ile elementow dla sredniej

	;mov		eax, 0				;ilosc aktualnie zsumowanych elementow	(zawsze mniejsze od m)
	mov		edx, 0				;aktualny obieg liczenia sredniej


	mov		eax, 4
	mul		ebx
	mov		ebx, eax



	finit

	fldz
	fst		dword PTR [ebp - 4]
	fstp	dword PTR [ebp - 8]
	lea		edi, [esi + ecx*4]
	main_lp:
		add		esi, ebx
		cmp		esi, edi
		ja		end_2
		sub		esi, ebx
		xor		eax, eax
		calc_sum:
			fld		dword PTR [esi + eax*4]
			fld		dword PTR [ebp - 4]
			faddp
			fstp	dword PTR [ebp - 4]
			inc		eax
			cmp		eax, [ebp + 16]
			jne		calc_sum
		
		fld		dword PTR [ebp - 4]
		fild	dword PTR [ebp + 16]
		fdivp
		fld		dword PTR [ebp - 8]
		fxch	
		fst		dword PTR [ebp - 8]; zapisanie nowej sredniej w pamiec
		fsubp   
		fabs
		fld		dword PTR _diff
		fcomi	st(0), st(1)
		ja		_end
		fstp	st(0)
		fstp	st(0)
		add		esi, 4
		fldz
		fstp	dword PTR [ebp - 4]
		jmp		main_lp

		

	_end:
		fstp	st(0)
		fstp	st(0)
		fld	dword PTR [ebp - 4]

	end_2:
		fld dword PTR [ebp - 8]
	pop		esi
	pop		edi
	pop		ebx
	add		esp, 8
	pop		ebp
	ret
_progowanie_sredniej_kroczacej	ENDP
END