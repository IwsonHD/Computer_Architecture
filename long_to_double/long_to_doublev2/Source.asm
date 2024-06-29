.686
.model flat

public _main
extern _ExitProcess@4 :PROC

.data
	input dd -31.44
	output dq ?
.code

_main PROC
	mov		esi, OFFSET input
	xor		eax, eax	;mlodsza czesc double
	xor		edx, edx	;starsza czesci double
	mov		ebx, [esi]  ;ebx = org float

	;odizolowanie wykladnika do ecx

	mov		ecx, ebx
	and		ecx, 7f800000h
	;repolaryzacja do wykladnika double
	shr		ecx, 23
	sub		ecx, 127
	add		ecx, 1023
	shl		ecx, 20
	push	ecx
	;odizolowanie mantysy do ecx
	mov		ecx, ebx
	and		ecx, 007fffffh

	mov		edx, ecx
	shr		edx, 3
	mov		eax, ecx
	shl		eax, 29

	pop		ecx
	add		edx, ecx
	bt		ebx, 31
	jnc		_end
	bts		edx, 31

	_end:
	mov		edi, OFFSET output
	mov		[edi], eax
	mov		[edi + 4], edx
	fld		input
	fld		qword PTR output
	push	0
	call	_ExitProcess@4
_main ENDP
END