.686
.model flat

extern	__write				:PROC
extern	_GetSystemTime@4	:PROC

public	_get_curr_minutes


.code

_get_curr_minutes PROC
	push	ebp
	mov		ebp, esp
	push	edi


	sub		esp, 12
	mov		edi, esp
	
	push	edi
	call	_GetSystemTime@4


	mov		ax, [edi][10]
	movzx	eax, ax
	
	add		esp, 12
	pop		edi
	pop		ebp
	ret
_get_curr_minutes ENDP


END