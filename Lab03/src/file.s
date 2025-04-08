bits 64

section .data
    global STDIN
    global STDOUT

    global O_RDONLY
    global O_WRONLY
    global O_RDWR
    global O_CREAT
    global O_TRUNC

    ; Константы для системных вызовов
    SYS_FOPEN  equ 2    ; Номер syscall для fopen()
    SYS_FREAD  equ 0    ; Номер syscall для fread()
    SYS_FWRITE equ 1   ; Номер syscall для fwrite()
    SYS_FCLOSE equ 3   ; Номер syscall для fclose()

    STDIN  equ 0        ; Файловый дескриптор stdin
    STDOUT equ 1       ; Файловый дескриптор stdout

    O_RDONLY equ 0     ; Режим только для чтения
    O_WRONLY equ 1     ; Только запись
    O_RDWR   equ 2     ; Чтение и запись
    O_CREAT  equ 0x40  ; Создать файл, если не существует
    O_TRUNC  equ 0x200 ; Очистить файл при открытии

section .text
    global print
    global open_file
    global read_file
    global write_file
    global close_file

    extern strlen

; Параметры:
;   rsi - указатель на строку с детерменирующим нулём.
; Возвращает:
;   rax - кол-во записанных байт (если 0 - дошли до конца файла; если <0 - ошибка записи; если >0 - запись файла прошло успешно)
print:
    push rdx
    push rdi
    push rax

    mov rdi, rsi
    mov al, 0
    call strlen

    mov rdx, rax
    mov rdi, STDOUT
    call write_file

    pop rax
    pop rdi
    pop rdx
    ret

; Параметры:
;   rdi - указатель на имя файла (строка с нулём на конце)
;   rsi - флаги доступа (O_RDONLY, O_WRONLY и т.д.)
;   rdx - права доступа (если используется O_CREAT)
; Возвращает:
;   rax - файловый дескриптор (положительное число) или код ошибки (отрицательное)
open_file:
    mov rax, SYS_FOPEN  ; Номер syscall для fopen()
    syscall             ; Вызов ядра
    ret                 ; Возврат из функции (результат в rax)

; Параметры:
;   rdi - файловый дескриптор
;   rsi - буфер для данных
;   rdx - размер буфера
; Возвращает:
;   rax - кол-во прочитанных байт (если 0 - дошли до конца файла; если <0 - ошибка чтения; если >0 - чтение файла прошло успешно)
read_file:
    mov rax, SYS_FREAD  ; syscall fread()
    syscall
    ret

; Параметры:
;   rdx - кол-во записываемых байт
;   rdi - файловый дескриптор
;   rsi - указатель на записываемые данные
; Возвращает:
;   rax - rax - кол-во записанных байт (если 0 - дошли до конца файла; если <0 - ошибка записи; если >0 - запись файла прошло успешно)
write_file:
    mov rax, SYS_FWRITE ; syscall fwrite()
    syscall
    ret

; Параметры:
;   rdi - файловый дескриптор
close_file:
    mov rax, SYS_FCLOSE ; syscall fclose()
    syscall
    ret