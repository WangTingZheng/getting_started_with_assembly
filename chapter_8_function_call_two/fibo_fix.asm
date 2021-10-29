global main

fibo:
    cmp rax, 1
    je _get_out
    cmp rax, 2
    je _get_out
    
    ; 保存所有非rax寄存器的值到栈里
    push rbx
    push rcx
    push rdx
    
    mov rdx, rax
    sub rax, 1
    
    ; 每次递归进入函数之后也会保存寄存器的值到栈
    call fibo
    ; 函数结束跳出前，会恢复寄存器的值
    ; 所以程序运行到这里，实际上和刚进入函数前寄存器的值是一样的
    mov rbx, rax
    
    mov rax, rdx
    sub rax, 2
    call fibo
    mov rcx, rax
    
    mov rax, rbx
    add rax, rcx
    
    ; 由于栈是先入后出的
    ; 所以从下往上出栈保存
    pop rdx;
    pop rcx;
    pop rbx;
    
    ret
    
_get_out:
    mov rax, 1
    ret
    
main:
	mov rax, 5
	call fibo
	ret