global main

main:
    mov dword [x], 0x2
    mov dword [y], 0x3
    mov eax, [x]
    mov ebx, [y]
    add eax, ebx
    mov [z], eax
    mov eax, [z]
    ret

section .data
x       dw      0
y       dw      0
z       dw      0