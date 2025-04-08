bits 64

section .text
    global strlen
    global find_char
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
;   rdi - указатель на начало строки
;   al  - символ который мы ищем
; Возвращает:
;   rsi - указатель на найденный символ (если не найден то -1)
find_char:
    push rdx
    mov rsi, rdi

    find_loop:
        mov dl, byte[rsi] 
        inc rsi
        cmp dl, 10
        je nfound
        cmp dl, al
        jne find_loop
found:
    dec rsi
    pop rdx
    ret

nfound:
    mov rsi, -1
    pop rdx
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
