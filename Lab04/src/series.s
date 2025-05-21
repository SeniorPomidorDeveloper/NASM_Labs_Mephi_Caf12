section .data
    one dd 1.0             ; Константа 2.0 для float
    neg_one dd -1.0

    ; filename db "numbers.txt", 0     ; Имя файла
    mode db "w", 0                   ; Режим открытия - запись

    format db "%d %.6f", 10, 0

section .text
    global calculate

    extern fopen
    extern fprintf
    extern fclose
 
    extern scanf

; Функция calculate
; Вход: xmm0 = x, xmm1 = число, xmm2 = точность, rdi = указатеь на имя файла
; Выход: xmm0 = результат (float), eax = ошибка
calculate:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    movss dword[rbp-4], xmm0    ; x
    movss dword[rbp-8], xmm1    ; число
    movss xmm8, xmm2
    mulss xmm8, dword[neg_one]
    movss dword[rbp-12], xmm8   ; обратная точность
    movss dword[rbp-16], xmm2   ; точность

    ; Открываем файл
    mov rsi, mode
    call fopen
    
    ; Проверяем, успешно ли открылся файл
    test rax, rax
    jz error_opening
    
    ; Сохраняем указатель на файл
    mov dword[rbp-28], eax

    movss xmm3, dword[one]

    movss dword[rbp-20], xmm3   ; прошлый член
    movss dword[rbp-24], xmm3   ; сумма

    mov rdi, rax                    ; Файловый дескриптор
    mov rsi, format                 ; Формат
    mov edx, 0                      ; Первый аргумент - номер
    cvtss2sd xmm0, dword[rbp-20]    ; Второй аргумент - дробное число
    mov eax, 1                      ; Один аргумент с плавающей точкой
    call fprintf

    mov dword[rbp-32], 0    ; Номер члена (n)
    
ser_loop:
    movss xmm4, dword[rbp-24]   ; Сумма
    movss xmm3, dword[rbp-20]   ; Прочшлый член
    movss xmm0, xmm4            ; Сумма
    movss xmm1, dword[rbp-8]    ; число
    subss xmm0, xmm1            ; Сумма - число
    movss xmm8, dword[rbp-12]   ; -точность
    comiss xmm8, xmm0
    ja start                    ; -Точность > Сумма - число
    comiss xmm0, dword[rbp-16] 
    jbe end                     ; Точность >= Сумма - число

start:  
    mov eax, dword[rbp-32]      ; n
    add eax, 1                  ; n + 1
    mul eax                     ; (n + 1)^2
    cdq
    add eax, eax                ; 2(n + 1)^2
    cvtsi2ss xmm5, eax
    mulss xmm5, dword[rbp-4]    ; 2(n + 1)^2 * x
    mulss xmm5, dword[rbp-4]    ; 2(n + 1)^2 * x^2

    mov eax, dword[rbp-32]      ; n
    add eax, 2                  ; n + 2
    mov ebx, eax                ; n + 2
    mov eax, dword[rbp-32]      ; n
    add eax, eax                ; 2n
    add eax, 3                  ; 2n + 3
    mul ebx                     ; (n + 2)(2n + 3)
    cvtsi2ss xmm6, eax
    divss xmm5, xmm6            ; 2(n + 1)^2 * x^2
                                ; ----------------
                                ;  (n + 2)(2n + 3)

    mulss xmm3, xmm5            ; 2(n + 1)^2 * x^2
                                ; ---------------- * prev = new
                                ;  (n + 2)(2n + 3)

    addss xmm4, xmm3            ; sum + new

    movss dword[rbp-20], xmm3   ; Прошлый член
    movss dword[rbp-24], xmm4   ; sum

    inc dword[rbp-32]   ; n++

    mov eax, dword[rbp-28]
    mov rdi, rax                    ; Файловый дескриптор
    mov rsi, format                 ; Формат
    mov edx, dword[rbp-32]          ; Первый аргумент - номер
    cvtss2sd xmm0, dword[rbp-24]    ; Второй аргумент - дробное число
    mov eax, 1                      ; Один аргумент с плавающей точкой
    call fprintf

    jmp ser_loop

end:
    mov eax, dword[rbp-28]
    mov rdi, rax
    call fclose

    movss xmm0, dword[rbp-24]
    leave
    ret

overflow_error:
    mov eax, dword[rbp-28]
    mov rdi, rax
    call fclose
    ; Очищаем стек и возвращаем специальное значение
    mov rax, -1 ; Индикатор переполнения
    leave
    ret

error_opening:
    mov eax, -2
    leave
    ret