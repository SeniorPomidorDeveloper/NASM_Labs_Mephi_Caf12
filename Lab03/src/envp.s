bits 64

section .text
    global get_envp
    global get_value_envp

; Параметры:
;   rdi - указатель на имя переменной (строка с нулём на конце)
;   rsi - указатель на стек
; Возвращает:
;   rsi - указтель на переменную (если не найдена то 0)
get_envp:
    push rcx
    push rax
    push rdx
    push rbx
    mov rcx, [rsi]         ; argc
    lea rsi, [rsi + rcx * 8 + 16] ; envp

search_loop:
    mov rcx, [rsi]         ; Текущая переменная
    test rcx, rcx
    jz exit

    ; Сравнение начала строки с "PATH="
    mov rdx, 0
    check_char:
        mov al, byte[rdi + rdx]
        mov bl, byte[rcx + rdx] 
        cmp al, 0             
        je exit
        inc rdx
        cmp al, bl
        je check_char

next_var:
    add rsi, 8
    jmp search_loop

exit:
    mov rsi, rcx
    pop rbx
    pop rdx
    pop rax
    pop rcx
    ret

; Параметры:
;   rsi - указатель на имя переменную
; Возвращает:
;   rsi - указатель на строку содержащую значение переменной
get_value_envp:

    get_value_envp_loop:
        inc rsi
        cmp byte[rsi - 1], '='
        jne get_value_envp_loop
    ret