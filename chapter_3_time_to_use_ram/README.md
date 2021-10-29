# 是时候上内存了

看本文档前，请看原文：[汇编语言入门三：是时候上内存了](https://zhuanlan.zhihu.com/p/23722940)，本章主要讲的是如何从内存中存取数据

## 程序清单

- danteng.asm: 全文第一个程序，尝试使用内存存取值，但是执行不起来
- danteng_worked.asm: 上一个程序的改进版，使之可以正常运行
- danteng_try.asm: 自由发挥的程序，借助内存的辅助完成两个变量的相加
- dangteng_try_short.asm: 实现同样的功能，但是是上一个程序的精简版
- test.asm: 用于gdb调试演示，只是简单地把两个寄存器的值相加

## 编译运行

danteng.asm是一个运行不了的程序，作者首先使用它来做反面教材，其编译指令和之前的一样：

```bash
nasm -f elf64 danteng.asm -o danteng.o
gcc -m64 danteng.o -o danteng
```

可以正常运行的danteng_worked.asm/danteng_try.asm的编译会出现

`/usr/bin/ld: danteng_worked.o: relocation R_X86_64_32S against .data' can not be used when making a PIE object; recompile with -fPIE collect2: error: ld returned 1 exit status`

的错误，[gcc linking error for assembly program - Stack Overflow](https://stackoverflow.com/questions/49828667/gcc-linking-error-for-assembly-program)给出了修正的方法，编译指令如下：

```bash
$ nasm -f elf64 danteng_worked.asm -o danteng_worked.o
$ gcc -m64 danteng_worked.o -o danteng_worked -no-pie
$ ./danteng_worked; echo $?


$ nasm -f elf64 danteng_try.asm -o danteng_try.o
$ gcc -m64 danteng_try.o -o danteng_try -no-pie
$ ./danteng_try; echo $?

$ nasm -f elf64 danteng_try_short.asm -o danteng_try_short.o
$ gcc -m64 danteng_try_short.o -o danteng_try_short -no-pie
$ ./danteng_try_short; echo $?
```

最后一个用于gdb调试的test.asm编译和之前的一样

```bash
$ nasm -f elf64 test.asm -o test.o
$ gcc -m64 test.o -o test
$ ./test; echo $?
```

## 补充

首先，进入gdb调试test.asm的时候，最好先run一遍再打断点，否则会出现：

```bash
Warning:
Cannot insert breakpoint 1.
Cannot access memory at address 0x1135
```

然后那个`set disassembly-flavor intel`命令不是说可以把反汇编的代码修正为intel的格式吗？去掉它与不去掉的区别如下：

```assembly
;不使用set disassembly-flavor intel
0x0000000008001130 <+0>:     mov    $0x1,%eax
0x0000000008001135 <+5>:     mov    $0x2,%ebx
0x000000000800113a <+10>:    add    %ebx,%eax
0x000000000800113c <+12>:    retq
0x000000000800113d <+13>:    nopl   (%rax)

;使用set disassembly-flavor intel
0x0000000000001130 <+0>:     mov    eax,0x1
0x0000000000001135 <+5>:     mov    ebx,0x2
0x000000000000113a <+10>:    add    eax,ebx
0x000000000000113c <+12>:    ret
0x000000000000113d <+13>:    nop    DWORD PTR [rax]
```

看起来格式更加清晰了

