section .data
    one dd 1.0                ; 32-бита для float
    zero dd 0.0
    eps_zero dd 0.00000000000000001

    prompt_msg db "Введите x (|x| <= 1): ", 0
    accuracy_msg db "Введите точность: ", 0
    result_fmt db "%.6f = %.6f", 10, 0
    num_s db "Число: %.6f", 10, 0
    
    scan_fmt db "%f", 0        ; %f для float вместо %lf

    error_fmt db "Ошибка: |x| должно быть <= 1", 10, 0
    overflow_msg db "Ошибка: произошло переполнение", 10, 0
    
section .bss
    x resd 1        ; float (4 байта) вместо resq
    accuracy resd 1 ; float (4 байта) вместо resq

section .text
    global main

    extern printf
    extern scanf
    extern asinf              ; asinf вместо asin для float

    extern calculate

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    cmp rdi, 1         ; Если argc <= 1, то аргументов нет
    jbe .exit
    mov r15, qword[rsi + 8]
    
    ; Выводим приглашение
    mov rdi, prompt_msg
    xor eax, eax
    call printf
    
    ; Считываем x
    mov rdi, scan_fmt
    mov rsi, x
    xor eax, eax
    call scanf

    ; Проверяем |x| <= 1
    movss xmm0, dword[x]
    mulss xmm0, xmm0         ; x^2 используя float
    comiss xmm0, dword[one]        ; Сравнение для float
    ja error_input

    ; Выводим приглашение
    mov rdi, accuracy_msg
    xor eax, eax
    call printf

    mov rdi, scan_fmt
    mov rsi, accuracy
    xor eax, eax
    call scanf

    movss xmm0, dword[x]
    call left
    movss dword[rbp-4], xmm0

    mov rdi, r15
    movss xmm0, dword[x]
    movss xmm1, dword[rbp-4]
    movss xmm2, dword[accuracy]
    call calculate
    cmp eax, -1
    je print_overflow
    
    ; Для вывода через printf нужно преобразовать float в double
    cvtss2sd xmm1, xmm0      ; Результат
    cvtss2sd xmm0, dword[rbp-4]
    
    ; Выводим результат
    mov rdi, result_fmt
    mov eax, 2  ; Три аргумента с плавающей точкой
    call printf

.exit:    
    ; Выход
    xor eax, eax
    leave
    ret

left:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    movss xmm2, xmm0

    ; Проверяем |x| = 0
    mulss xmm0, xmm0
    comiss xmm0, dword[eps_zero]
    jbe left_zero_result
    
    ; Вычисляем arcsin(x)
    movss xmm0, xmm2
    movss dword[rbp-4], xmm2
    call asinf               ; Используем asinf вместо asin

    ucomiss xmm5, xmm5
    jp invalid_input


    movss xmm2, dword[rbp-4]
    movss xmm1, xmm0
    
    ; Вычисляем (arcsin(x)/x)²
    divss xmm0, xmm2         ; Деление для float
    mulss xmm0, xmm0         ; Возведение в квадрат для float
    leave
    ret

left_zero_result:
    movss xmm0, dword[one]
    leave
    ret

invalid_input:
    mov rdi, error_fmt
    xor eax, eax
    call printf
    mov eax, 1
    leave
    ret

error_input:
    mov rdi, error_fmt
    xor eax, eax
    call printf
    mov eax, 1
    leave
    ret

print_overflow:
    mov rdi, overflow_msg
    xor eax, eax
    call printf
    mov eax, 1
    leave
    ret