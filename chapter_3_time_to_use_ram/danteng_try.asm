global main

main:
	;将内存中的number_1的数据放入ebx寄存器中
	mov ebx, [number_1] 
	;将内存中的number_2的数据放入ecx寄存器中
	mov ecx, [number_2]
	
	;将ecx寄存器的值加到ebx寄存器中，实际上是完成number_1 + number_2 的操作
	add ebx, ecx
	
	;将结果赋值给内存中的result变量
	mov [result], ebx
	
	;将结果赋值给另外一个eax变量
	mov eax, [result]
	
	;实际上完成的是 result = number_1 + number_2
	
	ret

section .data
number_1 dw 10
number_2 dw 20
result   dw 0