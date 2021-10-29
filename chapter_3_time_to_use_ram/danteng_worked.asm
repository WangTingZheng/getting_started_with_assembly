global main

main:
	mov ebx, 1
	mov ecx, 2
	
	add ebx, ecx
	
	mov [ram], ebx
	mov eax, [ram]
	
	ret

section .data
ram dw 0