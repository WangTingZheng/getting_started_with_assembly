# 打通C和汇编语言

原文请看[汇编语言入门四：打通C和汇编语言 - 不吃油条的文章 - 知乎](https://zhuanlan.zhihu.com/p/23779935) ，本文主要写的是将C语言程序反汇编成汇编代码，然后和同功能的汇编代码比较，最后获得一些启示，用到自己的汇编代码中改进它。

- test01.c: 一个实现2 + 3的c语言程序
- test02.asm: 用汇编实现的 2 + 3的程序
- advanced.asm: 根据test01.c反汇编得到的代码里的思路改进的一个汇编程序，也是实现2 + 3的功能
- advanced_fix.asm: advanced.asm的改进版，前者不能运行，因为存储数据到内存的时候没有告诉编译器要多大空间

## 编译运行

```bash
$ gcc -m64 test01.c -o test01
$ ./test01; echo $?
5

$ nasm -f elf64 test02.asm -o test02.o
$ gcc -m64 test02.o -o test02 -no-pie
$ ./test02; echo $?
5

$ nasm -f elf64 advanced.asm -o advanced.o
advanced.asm:4: error: operation size not specified
advanced.asm:5: error: operation size not specified

$ nasm -f elf64 advanced_fix.asm -o advanced_fix.o
$ gcc -m64 advanced_fix.o -o advanced_fix -no-pie
$ ./advanced_fix; echo $?
5
```

## 扩展

汇编语言的执行流程：

```assembly
mov eax, 2
mov [x], eax
mov eax, 3
mov [y], eax
mov eax, [x]
mov ebx, [y]
add eax, ebx
mov [z], eax
mov eax, [z]
ret
```

C语言程序的汇编执行流程：

```assembly
mov [x],0x2
mov [y],0x3
mov edx,[x]
mov eax,[y]
add eax,edx
mov [z],eax
mov eax,[z]
ret
```

具体的图形化过程，请查阅本目录中的`c and assembly process.pdf`

## 扩展

修改后可运行的程序中，添加了dword：

```assembly
mov dword [x], 0x2
```

dword的作用相当于申请一段4个字节的空间，当然[x]是这段空间的起始地址？如果不加的话，编译器就不知道应该在内存中开辟多少大小的空间。