# 环境有了先过把瘾

原文请看知乎文章：[汇编语言入门二：环境有了先过把瘾](https://zhuanlan.zhihu.com/p/23639191)，这篇文章的主要目的是为了让大家对汇编的几个基础的指令有一个认识，知道汇编大概是怎么工作的。

## 程序清单

- nmb.asm: 实现1 + 2的运算
- nmb2.asm: 实现 1 + 2 + 3 + 4 + 5的运算
- nmb3.asm:  实现 1 + 2 + 3 + 4的运算

## 编译

64位CPU

```bash
 nasm -f elf64 nmb.asm -o nmb.o
 gcc -m64 nmb.o -o nmb
 
 nasm -f elf64 nmb2.asm -o nmb2.o
 gcc -m64 nmb2.o -o nmb2
 
 nasm -f elf64 nmb3.asm -o nmb3.o
 gcc -m64 nmb3.o -o nmb3
```

## 运行

```bash
./nmb;echo$?
./nmb2;echo$?
./nmb3:echo$?
```

话说作者取的文件名够粗鄙的...
