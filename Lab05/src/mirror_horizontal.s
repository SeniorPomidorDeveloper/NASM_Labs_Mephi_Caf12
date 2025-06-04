; void mirror_horizontal(uint8_t* image, int width, int height, int channels)
; rdi = image, rsi = width, rdx = height, rcx = channels

global mirror_horizontal_asm

section .text

mirror_horizontal_asm:
    ; Prologue: save rbp and callee-saved registers
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Move function parameters to registers:
    ; width is in rsi, height is in rdx, channels is in rcx
    mov r8, rsi      ; r8d = width
    mov r9d, edx      ; r9d = height
    mov r10d, ecx     ; r10d = channels

    xor r11d, r11d    ; r11d = y = 0 (row counter)

outer_loop:
    cmp r11d, r9d
    jge end_function

    ; Compute row pointer = image + y * width * channels
    mov rax, r11
    imul rax, r8      ; rax = y * width
    imul rax, r10     ; rax = y * width * channels
    mov r12, rdi
    add r12, rax       ; r12 = row pointer

    xor r13d, r13d     ; r13d = x = 0
    mov eax, r8d
    shr eax, 1         ; half of width (integer division)
    mov r14d, eax      ; r14d = (width / 2)

inner_loop:
    cmp r13d, r14d
    jge next_row

    ; Calculate left pixel pointer: left = row + (x * channels)
    mov rax, r13
    imul rax, r10     ; rax = x * channels
    mov rbx, r12
    add rbx, rax       ; rbx = left pointer

    ; Calculate right pixel pointer: right = row + ((width - 1 - x) * channels)
    mov rax, r8       ; rax = width
    dec rax            ; rax = width - 1
    sub rax, r13      ; rax = width - 1 - x
    imul rax, r10     ; rax = (width - 1 - x) * channels
    mov rcx, r12
    add rcx, rax       ; rcx = right pointer

    xor r15d, r15d     ; r15d = channel index, c = 0

channel_loop:
    cmp r15d, r10d
    jge finish_pixel

    ; Swap the pixel bytes in each channel:
    mov al, [rbx + r15]  ; left pixel byte in channel c
    mov dl, [rcx + r15]  ; right pixel byte in channel c
    mov [rbx + r15], dl
    mov [rcx + r15], al

    inc r15d
    jmp channel_loop

finish_pixel:
    inc r13d
    jmp inner_loop

next_row:
    inc r11d
    jmp outer_loop

end_function:
    ; Epilogue: restore callee-saved registers and rbp, then return
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret