bits	64

section	.data
width:
	db 6
height:
	db 5
matrix:
	dd 1, 4, 1, 1, 8, 9,
	dd 2, 5, 2, 5, 6, 1,
	dd 3, 6, 7, 3, 4, 5,
	dd 0, 0, 0, 0, 5, 7,
	dd 17, 2, 3, 9, 10, 1
; dd 2147483647, 6, -4,
section .bss
sum_matrix:
	resd 6 
indexes:
	resb 6

section	.text
global	_start
_start:
	movzx r8d, byte[width]
	mov r9b, byte[height]

	mov ebx, 0

	init_indexes:
		mov byte[indexes + ebx], bl
		inc bl
		cmp ebx, r8d
		jne init_indexes

	mov ecx, 0
begin_sum:
	mov ebx, ecx
	mov edi, 0
	mov dl, 0
	
	sum:
		add edi, dword[matrix + ebx * 4]
		jo sum_overflow
		add ebx, r8d
		inc dl
		cmp dl, r9b
		jne sum

end_sum: 
	mov dword[sum_matrix + ecx * 4], edi
	inc ecx
	cmp ecx, r8d
	jne begin_sum

	mov eax, r8d
begin_sort:
	mov edi, 100
	mov ebp, 124
	mul edi
	cdq
	div ebp

	cmp eax, 0
	je end

	mov ebx, 0
	mov ecx, ebx
	add ecx, eax

	sort:
		mov edi, dword[sum_matrix + ebx * 4]
		mov esi, dword[sum_matrix + ecx * 4]
		%ifdef WANE
			cmp esi, edi
		%else
			cmp edi, esi
		%endif
		jle sort_step
		mov dword[sum_matrix + ebx * 4], esi
		mov dword[sum_matrix + ecx * 4], edi
		mov dl, byte[indexes + ebx]
		mov r10b, byte[indexes + ecx]
		mov byte[indexes + ebx], r10b
		mov byte[indexes + ecx], dl

	sort_step:
		inc ebx
		inc ecx
		cmp ecx, r8d
		jne sort
end_sort:
	cmp eax, 0
	jne begin_sort

end:
	mov	eax, 60
	mov edi, 0
	syscall	

sum_overflow:
	mov	eax, 60
	mov	edi, 1
	syscall
