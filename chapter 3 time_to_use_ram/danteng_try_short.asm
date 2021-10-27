global main

main:
	; 将内存中的number_1的值拷贝到eax寄存器中
    mov eax, [number_1]
    
    ; 将内存中的number_2的值拷贝到ebx寄存器中
    mov ebx, [number_2]
    
    ; 将eax上的值加上ebx
    add eax, ebx
    
    ret

section .data
number_1      dw        10
number_2      dw        20