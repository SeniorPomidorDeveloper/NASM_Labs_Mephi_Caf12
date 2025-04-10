bits 64

section .data
    ENVP db 'LAB3_FILENAME', 0   ; Имя искомой переменной
    ENVP_len equ $-ENVP

    buffer_len equ 256

    spaces db ' ', 9
    space db ' '
    end db 10

section .bss
    buffer resb 256
 
section .text
    global _start

    extern open_file
    extern read_file
    extern write_file
    extern close_file
    extern print

    extern STDOUT

    extern O_RDONLY

    extern get_envp
    extern get_value_envp

    extern strlen
    extern find_char
    extern find_nchar

_start:
    mov rdi, ENVP
    mov rsi, rsp
    call get_envp

    test rsi, rsi
    jz error_envp_nfound

    call get_value_envp

    mov rdi, rsi
    mov rsi, O_RDONLY
    mov rdx, 111q
    call open_file

    mov rdi, rax        ; Дескриптор
    mov rsi, buffer     ; Начало буфера
    mov rdx, buffer_len ; Длина буфера
    find_space:
        call read_file
        cmp rax, 0
        jl error_read_file 

        mov r9, rsi        ; Конец буфера
        add r9, rax
        dec r9

        call close_file
        mov rbx, rsi

        del_spaces:
            mov rcx, rbx
            mov rax, spaces
            mov r8, 2
            call find_nchar

            cmp byte[rbx], 10
            je write_end
            
            cmp r9, rbx
            jbe ok

            mov rsi, rbx

        find_first_space:
            mov rcx, rsi
            mov rax, spaces

            call find_char

            mov r10, rbx
            sub r10, rsi ; Длина первого слова

        mov rdi, STDOUT
        mov rdx, r10
        call write_file
        cmp rax, 0
        jle error_write_file

        cmp byte[rbx], 10
        je write_end

        cmp r9, rbx
        jbe ok

        find_other_spaces:
            cmp byte[rbx], 10
            je write_end
            
            mov rcx, rbx
            mov rax, spaces
            call find_nchar

            cmp r9, rbx
            jb write_end 

            cmp byte[rbx], 10
            je write_end

            mov rcx, rbx
            mov rax, spaces
            call find_char

            cmp r9, rbx
            jb ok

            mov r11, rbx ; Длина текущего
            sub r11, rcx
            cmp r11, r10
            jne find_other_spaces

            mov r13, rcx
            
            mov rdx, 1
            mov rsi, space
            call write_file
            cmp rax, 0
            jle error_write_file

            mov rdx, r10
            mov rsi, r13
            call write_file
            cmp rax, 0
            jle error_write_file

            jmp find_other_spaces

write_end:
    mov rdx, 1
    mov rsi, end
    call write_file
    cmp rax, 0
    jle error_write_file
    inc rbx
    cmp r9, rbx
    jb ok
    jmp del_spaces

ok:
    mov rdi, 0
    jmp exit

error_envp_nfound:
    mov rdi, 1
    jmp exit

error_open_file:
    mov rdi, 2
    jmp exit

error_read_file:
    mov rdi, 3
    jmp exit

error_write_file:
    mov rdi, 4
    jmp exit

error_buffer:
    mov rdi, 5
    jmp exit

error_first_word_nfound:
    mov rdi, 6
    jmp exit

exit:
    mov rax, 60
    syscall