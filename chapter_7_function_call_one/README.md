# 函数调用一

原文请看：[汇编语言入门七：函数调用（一）](https://zhuanlan.zhihu.com/p/24129384)，主要讲的是函数调用中，程序运行位置的保存

- plsone.c：一个简单的，带有call函数调用的汇编程序，用来做演示

## 编译调试

编译运行，最后的结果是1，那是因为函数执行的过程中调用了eax_plus_1s函数，将eax加上了1，所以最终eax为1

```bash
$ nasm -f elf64 plsone.asm -o plsone.o
$ gcc -m64 plsone.o -o plsone -no-pie
$ ./plsone; echo $?
```

调试的过程中，由于作者的机器是32位的，而我使用的是64位的，所以需要更换一下寄存器，其它的跟随作者的步骤即可，寄存器的对应关系如下，信息来自[寄存器1 - Minazuki Sora](https://www.minazuki.cn/post/blog_os/blog_os-1btagnqm2aabq/blog_os-1btago8uhn9is/)：

```assembly
ebp->rbp ; 作者的文章中没出现过
esp->rsp ; 保存rip的栈的栈顶指针
eip->rip ; 指向程序运行的位置
```

## Q&A

### Q:为什么作者的栈顶指针每一次减少的4而我们的是8？

A: 每保存一次rip，栈的方向就减少8，而不是4，这应该也和64位系统有关系。然后大概说一下作者所演示的函数调用的过程：

![stack_before.png](https://i.loli.net/2021/10/28/913zbmasifOYvA8.png)

