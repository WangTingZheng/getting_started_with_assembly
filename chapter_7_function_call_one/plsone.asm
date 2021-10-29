global main

eax_plus_1s:
    add eax, 1
    ret
eax_plus_2s:
	add eax, 2
	ret

main:
    mov eax, 0
    call eax_plus_1s
    call eax_plus_2s
    ret