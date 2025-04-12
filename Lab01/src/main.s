bits	64
;	res=(a*b*c-c*d*e)/(a/b+c/d)

section	.data
res:
	dq	0 ; 64б
a:
	dd	0 ; 32б
b:
	dw	40 ; 16б
c:
	dd	0 ; 32б
d:
	dw	40 ; 16б
e:
	dd	30 ; 32б

section	.text
global	_start

_start:
	; Запись b
	movzx ebx, word[b]
	test ebx, ebx
	jz err ; Если b == 0, то завершаем программу с ошибкой

	; Запись d
	movzx edi, word[d]
	test edi, edi
	jz err ; Если d == 0, то завершаем программу с ошибкой

	; Запись a
	mov esi, dword[a]

	; Запись c
	mov ecx , dword[c]

	; esi = a
	; eax = a
	mov eax, esi

	; eax = a
	; ebx = b
	; eax = a / b
	div ebx

	; eax = a / b
	; ebp = a / b
	mov ebp, eax

	; ecx = c
	; eax = c
	mov eax, ecx

	; eax = c
	; edi = d
	; eax = c / d
	xor edx, edx
	div edi

	; ebp = a / c
	; eax = c / d
	; ebp = a / c + c / d
	add ebp, eax
	jo err ; Выполняем проверку на переполнение
	test ebp, ebp
	jz err ; Выполняем проверку на ноль

	mov eax, esi
	; eax = a
	; ebx = b
	; eax:adx = a * b
	; rax = eax:edx 
	mul ebx
	sal rdx, 32
	or rax, rdx

	; rbx = a * b
	mov rbx, rax

	; Запись e
	mov eax, dword[e]

	; eax = e
	; edi = d
	; eax:edx = e * d
	; rax = eax:edx
	mul edi
	sal rdx, 32
	or rax, rdx

	; rbx = a * b
	; rax = e * d
	; rbx = a * b - e * b
	sub rbx, rax
	js err ; Если разность отрицательна
	
	; rax = a * b - e * b
	mov rax, rbx

	; rcx = c
	; rax:rdx = a * b * c - c * d * e
	mov ecx, ecx
	mul rcx

	; rbp = a / c + c / d
	; rax = (a * b * c - c * d * e)
	; rax = (a * b * c - c * d * e) / (a / c + c / d) 
	mov ebp, ebp
	div rbp

	mov qword[res], rax

	mov	eax, 60
	mov	edi, 0
	syscall	

err:
	mov	eax, 60
	mov	edi, 1
	syscall
