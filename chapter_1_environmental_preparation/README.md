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

## 编译

```bash
# 64位CPU
nasm -f elf64 first.asm -o first.o
gcc -m64 first.o -o first
```

## 运行

```bash
./first ; echo $?
```

```echo $?```是指上个命令的退出状态，或函数的返回值。如果去掉它，执行first程序将无任何显示。
