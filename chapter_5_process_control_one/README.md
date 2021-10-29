# 流程控制一
原文请看：[汇编语言入门五：流程控制（一）](https://zhuanlan.zhihu.com/p/23845369)，本章主要讲的是if...else语句的汇编实现，其本质上就是汇编里的跳转语句

- grade.c: 一个有完整if...else语句的C语言文件，其主要作用是根据成绩判别等级，在本篇文章中作者用它来分析流程控制。
- goto.c：我自己编写的，用来分析goto语句的程序，原作者没有写
- register_void.c：我自己编写的，用来分析register关键字的作用的程序，但是这个程序中，被register标识的变量在汇编代码中没有
- register_int.c：上一个程序的改进，返回被register标识的变量了，汇编中就有它了

## 编译

```bash
$ gcc -m64 grade.c -o grade 
$ ./grade ; echo $?
2
```

## Q&A

### Q: 如何将含有if语句的C语言程序改写为汇编？

A: 原文里要将C语言的if语句改写成汇编，但是作者是直接给出了结果，难免有些跳跃，其实可以把if语句先改写成goto语句，源程序如下：

```c
int main() {
    int x = 1;
    if ( x > 100 ) {
        x = x - 20;
    }
    x = x + 1;
    return x;
}
```

实际上，作者也说了，`x = x + 1`是肯定要执行的，`x = x - 20`可执行可不执行，由于对于C语言来说，每一条语句都会按顺序逐条执行，所以有两种可能的执行情况：

```c
x = x - 20;
x = x + 1;

//x = x - 20;
x = x + 1;
```

一种是两者都执行，一种是只执行第二条，两者可以统一成第一种，但是要保留直接跳到第二天语句的入口

```c
x = x - 20;
xiao_deng_yu_100:
x = x + 1;
```

当满足x>100的时候，正常执行，不满足的时候，goto到xiao_deng_yu_100越过x = x - 20，也就是：

```c
int main() {    
    int x = 1;    
    if(x <= 100){
        goto xiao_deng_yu_100;
    }
    x = x - 20;
xiao_deng_yu_100:
    x = x + 1;    
    return x;
}
```

换成汇编就是：

```assembly
global main

main:
	mov eax, 1
	cmp eax, 100
	jle xiao_deng_yu_100
	sub eax, 20
xiao_deng_yu_100:
    add eax, 1
    ret
```

所以，将含有if的C语言改写成汇编的形式的要诀就是，将if里的语句和之后的代码放在一起，然后在其后面加上一个标签，当if不成立的时候goto到这个位置，更加复杂的程序也是一样的道理：

```C
int main() {
    int x = 10;
    if ( x > 100 ) {
        x = x - 20;
    }
    if( x <= 10 ) {
        x = x + 10;
    }
    x = x + 1;
    return 0;
}

int main() {
    int x = 10;
    if(x <= 100)
    {
        goto lower_or_equal_100;
    }
    
    x = x - 20;
lower_or_equal_100:
    if(x > 10)
    {
        goto greater_10;
    }
    x = x + 10;
greater_10:
    x = x + 1;
    return 0;
}
```

改编成的汇编代码为：

```assembly
global main

main:
	mov eax, 10
	
	cmp eax, 100
	jle lower_or_equal_100
	sub eax, 20
	
low_or_equal_100:
	cmp eax, 10
	jg greater_10
	add eax, 10
greater_10:
	add eax, 1
	ret
```

### Q: if...else语句的C语言程序的汇编实现是什么样的？

***A:*** 作者提供了一个更复杂的，带有else的C语言程序：

```c
int main() {
    register int grade = 80;
    register int level;
    if ( grade >= 85 ){
        level = 1;
    } else if ( grade >= 70 ) {
        level = 2;
    } else if ( grade >= 60 ) {
        level = 3;
    } else {
        level = 4;
    }
    return level;
}
```

其汇编代码如下，当然删除了一些多余的push、pop等语句，其中jle这类跳转语句后面的地址0x1143后面还特意标注了<main+26>，根据它来匹配左侧地址末尾的<+26>可以快速地定位到跳转的地方，它其实是程序的行号，之所以没有从0开始而是从9开始，那是因为我删除了一些语句。

```assembly
0x0000000000001132 <+9>:     mov    ebx,0x50
0x0000000000001137 <+14>:    cmp    ebx,0x54
0x000000000000113a <+17>:    jle    0x1143 <main+26>
0x000000000000113c <+19>:    mov    ebx,0x1
0x0000000000001141 <+24>:    jmp    0x1160 <main+55>
0x0000000000001143 <+26>:    cmp    ebx,0x45
0x0000000000001146 <+29>:    jle    0x114f <main+38>
0x0000000000001148 <+31>:    mov    ebx,0x2
0x000000000000114d <+36>:    jmp    0x1160 <main+55>
0x000000000000114f <+38>:    cmp    ebx,0x3b
0x0000000000001152 <+41>:    jle    0x115b <main+50>
0x0000000000001154 <+43>:    mov    ebx,0x3
0x0000000000001159 <+48>:    jmp    0x1160 <main+55>
0x000000000000115b <+50>:    mov    ebx,0x4
0x0000000000001160 <+55>:    mov    eax,ebx
0x0000000000001164 <+59>:    ret
```

翻译成更好看的形式的汇编如下：

```assembly
global main

main:
	mov ebx, 0x50 ; 赋成绩为初值80
	cmp ebx, 0x54 ; 把分数和85比较
	jle low_or_equal_85 ; 如果分数小于等于85，就继续判断
	mov ebx, 0x1 ; 如果分数大于85，那就设为第一等级
	jmp return_level ;直接返回等级，退出函数
	
low_or_equal_85: ;继续判断等级
	cmp ebx, 0x45 ; 将分数和70比较
	jle low_or_equal_70 ; 如果分数小于等于70，那么需要继续判断等级
	mov ebx, 0x02 ; 如果分数大于70，那么就处于第二等级，设等级为2
	jmp return_level ; 直接返回等级，退出函数
	
low_or_equal_70: ;继续判断等级
	cmp ebx,0x3b ;将分数和60比较
	jle set_level_4: ;如果分数小于等于60，就跳到设置等级为4的地方
	mov ebx, 0x3 ; 如果分数大于60，就设置为等级3
	jmp return_level ; 直接返回等级，退出函数
	
set_level_4: ; 设置等级为4
	mov ebx, 0x4
	
return_level: ;将等级赋值给eax
	mov eax, ebx
	ret ; 返回eax保存的等级数据
```

### Q: goto背后的实现原理是什么样的？

***A:*** 我自己写了一个带有goto语句的C语言程序：

```c
int main()
{
	register int a = 1;
	if(a > 1)
	{
		goto next;
	}
	a = a + 2;
next:
	a = a - 1;
	return a;
}
```

将其编译成汇编形式，如下：

```assembly
0x0000000000001129 <+0>:     endbr64
0x000000000000112d <+4>:     push   rbp
0x000000000000112e <+5>:     mov    rbp,rsp
0x0000000000001131 <+8>:     push   rbx
0x0000000000001132 <+9>:     mov    ebx,0x1
0x0000000000001137 <+14>:    cmp    ebx,0x1
0x000000000000113a <+17>:    jg     0x1141 <main+24>
0x000000000000113c <+19>:    add    ebx,0x2
0x000000000000113f <+22>:    jmp    0x1142 <main+25>
0x0000000000001141 <+24>:    nop
0x0000000000001142 <+25>:    sub    ebx,0x1
0x0000000000001145 <+28>:    mov    eax,ebx
0x0000000000001147 <+30>:    pop    rbx
0x0000000000001148 <+31>:    pop    rbp
0x0000000000001149 <+32>:    ret
```

去掉一些无关紧要的指令：

```assembly
0x0000000000001132 <+9>:     mov    ebx,0x1
0x0000000000001137 <+14>:    cmp    ebx,0x1
0x000000000000113a <+17>:    jg     0x1141 <main+24>
0x000000000000113c <+19>:    add    ebx,0x2
0x000000000000113f <+22>:    jmp    0x1142 <main+25>
0x0000000000001142 <+25>:    sub    ebx,0x1
0x0000000000001145 <+28>:    mov    eax,ebx
0x0000000000001149 <+32>:    ret
```

不管具体逻辑是什么样的吧，可以看到，if..else语句和goto语句编译完的汇编代码都差不多，goto有害论已经成为了业界共识，所以使用if...else这种流程控制语句来代替goto，完全是可行而且有必要的。

### Q: 加不加register有什么区别？

***A:*** 我编写了一个程序，定义了两个变量，一个变量被register关键字修饰，一个变量没有被register关键字修饰

```c
void main()
{
	register int a = 1;
	int b = 2;
}
```

编译成汇编代码如下：

```assembly
0x0000000000001129 <+0>:     endbr64
0x000000000000112d <+4>:     push   rbp
0x000000000000112e <+5>:     mov    rbp,rsp
0x0000000000001131 <+8>:     mov    DWORD PTR [rbp-0x4],0x2
0x0000000000001138 <+15>:    nop
0x0000000000001139 <+16>:    pop    rbp
0x000000000000113a <+17>:    ret
```

去掉非核心语句：

```assembly
0x0000000000001131 <+8>:     mov    DWORD PTR [rbp-0x4],0x2
0x000000000000113a <+17>:    ret
```

b 被保存在rbp寄存器中，a则是消失不见了。我们重新改写一下程序，使程序最终返回a的值：

```c
int  main()
{
	register int a = 1;
	int b = 2;
	
	a = a + 1;
	b = b + 1;
	
	return a;
}
```

编译成汇编：

```assembly
0x0000000000001129 <+0>:     endbr64
0x000000000000112d <+4>:     push   rbp
0x000000000000112e <+5>:     mov    rbp,rsp
0x0000000000001131 <+8>:     push   rbx
0x0000000000001132 <+9>:     mov    ebx,0x1
0x0000000000001137 <+14>:    mov    DWORD PTR [rbp-0xc],0x2
0x000000000000113e <+21>:    add    ebx,0x1
0x0000000000001141 <+24>:    add    DWORD PTR [rbp-0xc],0x1
0x0000000000001145 <+28>:    mov    eax,ebx
0x0000000000001147 <+30>:    pop    rbx
0x0000000000001148 <+31>:    pop    rbp
0x0000000000001149 <+32>:    ret
```

去掉非核心语句：

```assembly
0x0000000000001132 <+9>:     mov    ebx,0x1
0x0000000000001137 <+14>:    mov    DWORD PTR [rbp-0xc],0x2
0x000000000000113e <+21>:    add    ebx,0x1
0x0000000000001141 <+24>:    add    DWORD PTR [rbp-0xc],0x1
0x0000000000001145 <+28>:    mov    eax,ebx
0x0000000000001149 <+32>:    ret
```

我们发现被register标识的变量a，被直接赋值进了ebx寄存器，而没有被标识的变量b，则以一种奇奇怪怪的方式被赋值到了寄存器rbp。那它们俩有啥区别呢？经过查阅，在一篇文章叫[x86-64 下函数调用及栈帧原理](https://zhuanlan.zhihu.com/p/27339191)，我们可以依稀看出，ebx应该是一个普通的寄存器，而rbp似乎和栈有关，是否意味着，被register标识的变量会被直接保存在寄存器中，而未被标识的变量会被保存在函数栈中呢？
