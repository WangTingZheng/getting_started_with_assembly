# 函数调用二

原文请看[汇编语言入门八：函数调用（二）](https://zhuanlan.zhihu.com/p/24265088)，主要讲的是函数调用中，变量的保存，紧接着上一章，上一章讲的是程序运行位置的保存

- fibo1.c: 不使用全局变量，传入函数形参计算5的斐波那契数列
- fibo2.c: 使用传入全局变量计算5的斐波那契数列计算
- fibo.asm: fibo2.c的汇编版本
- fibo_fix.asm: 使用堆栈修复的fibo.asm的版本

## 编译运行

```bash
$ gcc -o fibo1 fibo1.c
$ ./fibo1; echo $?
5

$ gcc -o fibo2 fibo2.c
$ ./fibo2; echo $?
4

$ nasm -f elf64 fibo.asm -o fibo.o
$ gcc -m64 fibo.o -o fibo -no-pie
$ ./fibo; echo $?
4

$ nasm -f elf64 fibo_fix.asm -o fibo_fix.o
$ gcc -m64 fibo_fix.o -o fibo_fix -no-pie
$ ./fibo_fix; echo $?
5
```

我们可以看到，使用局部变量的fibo1.c和使用全局变量的fibo2.c、fibo.asm结果是不一样的，这是为什么呢？我们可以来分析一下，首先，肯定是使用局部变量的fibo1.c所计算出来的结果是正确的，因为：

```
fibo(1) = fibo(2) = 1
fibo(3) = fibo(3 - 1) + fibo(3 - 2)
        = fibo(2) + fibo(1)
        = 1 + 1 = 2
        
fibo(4) = fibo(4 - 1) + fibo(4 - 2)
        = fibo(3) + fibo(2)
        = 2 + 1 = 3

fibo(5) = fibo(5 - 1) + fibo(5 - 2)
	    = fibo(4) + fibo(3)
	    = 3 + 2 = 5
```

## 使用全局变量导致的问题

那4是怎么回事呢？我们来看一下程序，先看C语言版本的程序：

```c
int ebx, ecx, edx, eax;

int fibo() {
    if(eax == 1) {
        eax = 1;
        return 1;
    }
    if(eax == 2) {
         eax = 1;
         return 1;
    }
    
    edx = eax;
    
    eax = edx - 1;
    /* 递归进入一个人新的的函数中时，由于使用的是全局变量
    * 所以edx的值被改变成了传入的形参eax
    * 而传入的eax是传入前程序中的eax - 1
    * 所以当子程序fibo被调用完成之后，edx实际上被错误地修改了
    */
    eax = fibo(eax); 
    ebx = eax;
    
    // 错误地edx使eax的值也发生了错误
    eax = edx - 2;
    eax = fibo(eax);
    ecx = eax;
    
    eax = ebx + ecx;
}

int main()
{
	eax = 5;
	fibo();
	
	return eax;
}
```

 可以看到，使用全局变量时，递归调用自身的时候就会引起变量的错误，所以，必须有一个机制，使函数所使用的变量，只能在函数内部起到作用，这种机制就是作用域。这样的话，外层的函数作用域内的变量，就需要和调用的递归函数作用域的变量区分开来，当递归调用的时候，外层的函数自己的变量就需要提前保存在一个地方，等递归完成之后，再取出来，继续执行，这个地方，就是栈，所以，栈不仅仅像上一节所说的，需要存储rip，程序运行的位置，也需要存储本函数作用域下的局部变量的值。

## 使用堆栈解决全局变量带来的问题

作者举了一个例子，这个例子将计算1+2+3...+eax的值，但是这里用到了ebx寄存器，如果此函数的外面，或者其它函数同样使用到了ebx的值，那么和上面的C语言的例子一样，它可能读取到一个被sum_one_to_n函数修改过的ebx的值。

```assembly
sum_one_to_n:
    mov ebx, 0

_go_on:
    cmp eax, 0
    je _get_out:
    add ebx, eax
    sub eax, 1
    jmp _go_on

_get_out:
    mov eax, ebx
    ret
```

为了解决这个问题，作者使用入栈出栈指令，将ebx的原来的值先保存在栈中，等用好了再恢复ebx的值：

```assembly
sum_one_to_n:
    push ebx ; 用之前保存ebx的值到堆栈
    mov ebx, 0

_go_on:
    cmp eax, 0
    je _get_out:
    add ebx, eax
    sub eax, 1
    jmp _go_on

_get_out:
    mov eax, ebx
    pop ebx ; 程序执行完成后，再将原来保存的ebx值取出，放回ebx
    ret
```

这样就可以避免这个问题。

接下来我们来修改一下使用全局寄存器的fibo.asm，由于作者使用的是32位的CPU，我们使用的是64位CPU，所以里面用到的寄存器是32位的，机器使用push或者pop的时候无法进行操作，需要换成64位的寄存器，所以需要替换，解决方案来自[stackoverflow](https://stackoverflow.com/a/59587754/12815044)：

```assembly
eax->rax
ebx->rbx
ecx->rcx
edx->rdx
```

替换后加上push/pop指令保存寄存器的值

```assembly
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
```

编译运行后，结果就正常了，程序正确了
