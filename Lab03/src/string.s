bits 64

section .text
    global strlen
    global find_char
    global find_nchar
    global strcmp
    global strncmp

; Параметры:
;   rdi - указатель на начало строки
;   al  - символ окончания строки
; Возвращает:
;   rax - длина строки
strlen:
    push rsi
    call find_char
    mov rax, rsi
    sub rax, rdi
    pop rsi
    ret

; Параметры:
;   rcx - указатель на начало строки
;   rax - символы которые мы ищем
;   r8 - их кол-во
; Возвращает:
;   rbx - указатель на найденный символ (если не найден то -1)
find_char:
    push rsi
    push rdx
    mov rbx, rcx
    find_loop:
        mov dl, byte[rbx] 
        inc rbx
        cmp dl, 10
        je done
        cmp dl, 0
        je done
        mov rsi, 0
        cmp_loop_char:
            cmp dl, byte[rax + rsi]
            je done
            inc rsi
            cmp rsi, r8
            jne cmp_loop_char
        jmp find_loop
done:
    dec rbx
    pop rdx
    pop rsi
    ret

; Параметры:
;   rcx - указатель на начало строки
;   rax - символы которые не нужны
;   r8 - их кол-во
; Возвращает:
;   rbx - указатель на найденный символ (если не найден то -1)
find_nchar:
    push rsi
    push rdx
    mov rbx, rcx
    find_loop_nchar:
        mov dl, byte[rbx] 
        inc rbx
        cmp dl, 10
        je done_nchar
        cmp dl, 0
        je done_nchar
        mov rsi, 0
        cmp_loop_nchar:
            cmp dl, byte[rax + rsi]
            je find_loop_nchar
            inc rsi
            cmp rsi, r8
            jne cmp_loop_nchar
done_nchar:
    dec rbx
    pop rdx
    pop rsi
    ret

; Параметры:
;   rdi - указатель на начало строки №1
;   rsi - указатель на начало строки №2
; Возвращает:
;   rax - результат сравнения
; Примечание: обе строки должны заканчиваться детерминирующим нулём.
strcmp:
    push rdx
    push rcx
    mov dl, 1
    mov rax, 0

    srcmp_loop:
        cmp dl, 0
        and dl, cl
        cmp dl, 0
        je equal
        mov dl, byte[rdi + rax - 1]
        mov cl, byte[rsi + rax - 1]
        cmp dl, cl
        je srcmp_loop

nequal:
    mov rax, 0
    pop rcx
    pop rdx
    ret

equal:
    inc rax
    pop rcx
    pop rdx
    ret

; Параметры:
;   rdi - указатель на начало строки №1
;   rsi - указатель на начало строки №2
;   rax - кол-во сравниваемых символов
; Возвращает:
;   rax - результат сравнения
strncmp:
    push rdx

    srcnmp_loop:
        cmp rax, 0
        je equal
        dec rax
        mov dl, byte[rdi + rax]
        cmp dl, byte[rsi + rax]
        je srcmp_loop

strncmp_nequal:
    mov rax, 0
    pop rdx
    ret
    
strncmp_equal:
    inc rax
    pop rdx
    ret
