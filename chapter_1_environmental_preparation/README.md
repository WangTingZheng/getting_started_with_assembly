# 汇编语言入门一：环境准备

详细信息请看原作者知乎[原文](https://zhuanlan.zhihu.com/p/23618489)。本章主要讲了汇编语言的一些工具的安装

- first.asm: 一个简单的演示用的汇编语言

## 安装环境

使用各种Linux发行版，我使用的是Windows11下的WSL，x86, 64位CPU，执行：

```bash
sudo apt-get install gcc nasm vim gcc-multilib -y
```

检测是否安装成功：

```bash
$ which nasm
/usr/bin/nasm
$ which gcc
/usr/bin/gcc
```

## 编译运行

```bash
# 64位CPU
$ nasm -f elf64 first.asm -o first.o
$ gcc -m64 first.o -o first
$ ./first ; echo $?
1
```

## Q&A

### Q: echo $?是啥意思？

***A:*** ```echo $?```是指上个命令的退出状态，或函数的返回值。如果去掉它，执行first程序将无任何显示。

### Q: 为什么程序运行的结果是1？

***A:*** 而ret返回的是寄存器eax的值，eax被值1了，所以返回的结果应该是1
