---
title: Linux系统编程
tags:
  - linux
  - 计算机
abbrlink: '72802800'
date: 2022-10-10 11:40:02
---

## 1 常用工具

### 1.1 gcc

*工作流程概述：*

1. 预处理：**头文件**展开、**宏**替换、去除**注释**

   `gcc -E xxx.c -o xxx.i`

   > `xxx.i`仍然是一个**c文件**
   >
   > 预处理工作本质是由**cpp工具**完成的，gcc命令会调用这个工具

2. 编译：将c文件编译成**汇编文件**

     `gcc -S xxx.i -o xxx.s`

   > 这一步时间往往是**最长**的
   >
   > 编译工作由**gcc工具**完成

3. 汇编：将汇编文件转换成**二进制文件**

   `gcc -c xxx.s -o xxx.o`

   > 汇编工作本质是由**as工具**完成的，gcc命令会调用这个工具

4. 链接：将**函数库**中相应的代码组合到目标文件中

    `gcc xxx.o -o xxx`

   > 将所有相关的`.o`文件打包成一个**可执行文件**，并将`main`函数作为**启动函数**
   >
   > 链接工作本质是由**ld工具**完成的，gcc命令会调用这个工具

   > 可以直接调用链接的命令，这样会自动调用之前的三步：`gcc xxx.c -o xxx`

---

*常用参数：*

- `-I 目录`：指定**头文件**所在目录

  > 头文件一般放在`include`目录下；如果是在**同级目录**就不用参数指定了

- `-L 目录`：指定**库文件**所在目录

  > 库文件一般放在`lib`目录下

- `-l 库名`：指定**库文件**的名字

- `-D 宏名`：指定一个宏

  > 经典使用场景是控制log的输出

- `-O1`、`-O2`、`-O3`：生成汇编之前**优化**代码，`-O`后面数字越大，优化等级越大

- `-Wall`：输出**警告**信息

- `-g`：添加调试信息，之后可以用gdb工具调试

---

*静态库：*

- 命名规则：`lib + 库的名字 + .a`

  > `.a`文件一般放在`lib`目录下

- 制作步骤

  1. 生成`.o`文件：`gcc 所有需要的.c文件 -c -I 头文件所在目录`

  2. 将生成的`.o`文件打包：`ar rcs lib库的名字.a 所有需要的.o文件`

     > 使用`ar`打包工具

- 发布和使用静态库

  - 发布静态库
  - 提供头文件，在源程序中引入
  - 在编译时指定静态库，生成可执行程序：
    - `gcc 源程序.c lib库的名字.a -I 头文件所在目录 -o xxx`
    - `gcc 源程序.c -I 头文件所在目录 -L 静态库所在目录 -l 库的名字 -o xxx`
  - 运行可执行程序

- 查看组成静态库的`.o`文件：`nm lib库名.a`

  - 打包的最小单元是`.o`文件，并不会直接把整个库打包

- 静态库的优点和缺点

  - 优点
    - 发布程序时，不需要再**提供对应库**
    - 加载静态库的**速度**快
  - 缺点
    - 增加了应用程序的**大小**
    - 库发生**更新**后必须**重新编译**程序

---

*共享库/动态库：*

- 命名规则：`lib + 库名 + .so`

- 制作步骤

  1. 生成与位置无关的`.o`文件：`gcc -fPIC -c 所有需要的.c文件`

     > 生成静态库的时候，是与位置有关的`.o`
     >
     > - 与位置有关的`.o`，直接“静态地”存放在**`.text`代码段**
     > - 与位置无关的`.o`，在程序运行时才会动态加载到**虚拟地址空间的共享库**中

  2. 将`.o`文件打包成共享库：`gcc -shared lib库名.so -o 所有需要的.o文件`

- 发布和使用共享库

  - 发布静态库

  - 提供头文件，在源程序中引入

  - 在编译时指定动态库，生成可执行程序：

    - `gcc 源程序.c lib库名.so -I 头文件所在目录 -o xxx`
    - `gcc 源程序.c -I 头文件所在目录 -L 共享库所在目录 -l 库的名字 -o xxx`

  - 运行可执行程序

    > 解决自定义动态库无法加载的问题：
    >
    > ---
    >
    > `ldd 可执行程序`可以查看程序**依赖的所有共享库**
    >
    > 一般来说，程序都会依赖一个库，叫做动态链接器：`/lib64/ld-linux-x86-64.so.2`
    >
    > - 动态链接器可以**加载程序依赖的其他动态库**
    >
    > - 动态链接器的查找规则：根据某些**环境变量**查找
    >
    >   > 系统提供的动态库一般都放在`/lib`下（但不要把自己制作的库放进去
    >   >
    >   > **环境变量`LD_LIBRARY_PATH`**也在动态链接器的查找范围内，且是优先被查找的
    >
    > 所以如果要使用自定义动态库，可以执行`export LD_LIBRARY_PATH = xxx`，让动态链接器能找到自定义动态库，这样可以临时生效，用于**测试**
    >
    > > 如果不只要临时生效，可以把`export`语句写入`~/.bachrc`文件中再重启终端，但这种做法比较少见
    >
    > 还可以使用**配置文件**的方式：
    >
    > 1. 以管理员权限修改`/etc/ld.so.conf`，将自定义动态库路径写入新行
    >
    > 2. 使配置文件生效：`ldconfig -v`
    >
    >    > `-v`代表打印提示信息，也可以不加

- 动态库的优点和缺点

  - 优点

    - 不会把动态库打包到应用程序中，**体积小**

    - 库发生**更新**后可以不需要**重新编译**程序

      > 前提是**接口**没有发生太大变化

  - 缺点

    - 发布程序时，还需要再**提供对应库**
    - 加载动态库的**速度**相对较慢



### 1.2 gdb

*概述：*

- GDB（GNU Debugger）是GCC的调试工具

---

*常用指令：*

> 编译时需要加`-g`选项，通过`gdb 可执行程序`可以开启gdb调试

- 工作目录

  - `pwd`：查看当前工作目录
  - `cd`：切换工作目录

- 运行时参数

  - `set args 参数1 参数2 ...`：指定运行时参数
  - `show args`：查看设置好的运行时参数

- 查看源代码

  > l：list，列出10行

  - `l 要查看的文件名:行号`：显示指定文件某行前后的代码
  - `l 要查看的文件名:函数名`：显示指定文件某函数定义前后的代码
  - `l`：从上一次列出的代码后继续列出代码，或是从程序入口开始列出代码
  - `set listsize count`：设置一次显示的代码行数
  - `show listsize`：查看一次显示的代码行数

- 设置断点

  > b：break

  - `b 行号`：（在当前所在文件中）设置一个断点

  - `b 行号 if 逻辑表达式`：当逻辑表达式成立时断点才有效

    > 注意，如果是设置循环的条件停止，要把断点设置在`{}`代码块里

  - `d 断点编号范围`：删除断点。如果不加断点编号范围，则删除所有断点

    > d：delete
    >
    > `范围`可以直接写一个数字，也可以写类似`3-7`这种

  - `disable 断点编号范围`：让指定断点暂时失效

  - `enable 断点编号范围`：让指定断点重新生效

- 运行程序

  - `start`：开始运行程序，等待调试（只执行一步）

  - `r`：运行程序，直到断点或运行结束

    > r：run

  - `n`：单步执行

    > n：next

  - `c`：继续运行程序，直到断点或运行结束

    > c：continue

  - `s`：进入当前行中的函数内部

    > s：step

  - `u`：跳出循环

    > u：until
    >
    > 相当于程序中的`break`关键字

  - `finish`：跳出之前进入的函数

    > 要求之后不能有断点出现，否则无法跳出

- 打印信息

  - `p 表达式`：打印表达式的值
  - `ptype 表达式`：打印表达式的类型
  - `display 表达式`：追踪打印表达式的值，每运行一次都会打印
  - `undisplay 被追踪的表达式编号范围`：取消追踪的表达式

- 设置值

  - `set var 变量名=变量值 `：设置变量的值

- 查看信息

  > i：info

  - `i b`：查看断点信息
  - `i display`：查看被追踪的表达式信息



### 1.3 makefile

*一个规则：*

- makefile文件命名规则：

  - `makefile`
  - `Makefile`

- 运行makefile：

  - `make`：生成终极目标
  - `make xxx`：生成`xxx`目标，运行对应规则的命令

- 规则三要素：目标、依赖、命令

  ```makefile
  # 如下方式定义一条“规则”
  目标: 依赖的所有文件
  	gcc命令
  ```

  - 注意命令前必须有一个`tab`缩进
  - 默认从当前目录中寻找依赖文件，否则就要指定路径

  ```makefile
  app: main.o add.o sub.o mul.o
      gcc main.o add.o sub.o mul.o -o app
  
  main.o: main.c
      gcc -c main.c
  
  add.o: add.c
      gcc -c add.c
  
  mul.o: mul.c
      gcc -c mul.c
  
  sub.o: sub.c
      gcc -c sub.c
  ```

  - 如果有多条规则，默认**第1条规则**的目标为**终极目标**，后面的规则都是为此服务的

    > 终极目标可以向下查找依赖项的生成，然后从下向上执行

  - 如上所示分开生成`.o`文件，则执行`make`时**只会编译修改过的文件**

    > 终极目标是`app`，其他的可以不变；
    >
    > 当**依赖的更新时间**晚于**目标的更新时间**时，会再次执行**命令**

- `clean`规则与伪目标

  ```makefile
  .PHONY: clean
  clean:
      rm $(obj) $(target) -f
  ```

  - `make clean`即可运行命令
  - 解决目录下有名为`clean`的文件的问题：声明伪目标`.PHONY`

---

*三个变量：*

- `变量名=变量值`

  `$(变量名)`

  - 可以在makefile中以`变量名=变量值`和格式定义变量
  - 然后用`$(变量名)`引用

  `%`

  - 向下寻找依赖时，会自动匹配下方规则中的`%`，替换成要寻找的依赖，生成一条规则

    > 替换时会自动将`.后缀`去掉

- `$<`：规则中的**第一个依赖**

  `$^`：规则中的**所有依赖**

- `$@`：规则中的**目标**

> `$< $^ $@`是makefile中的自动变量，只能在规则的**命令**中使用

```makefile
obj = main.o add.o sub.o mul.o
target = app 

${target}: ${obj} 
    gcc ${obj} -o ${target}

%.o: %.c 
    gcc -c $< -o $@
```

- makefile维护的变量

  > 通常为**大写**。用户自定义变量通常为小写

  - `CC`：默认值`cc`，也就是`gcc`
  - `CPPFLAGS`：预处理时需要的选项，如`-I`
  - `CFLAGS`：编译的时候使用的参数，如`-Wall -D -g -c`
  - `LDFLAGS`：链接时使用的选项，如`-L -l`

---

*两个函数：*

- `wildcard`：

  `src = $(wildcard 某目录下用*匹配的文件)`

- `patsubst`：

  `obj = $(patsubst 某目录下用%匹配的文件, 保留%后要替换成的样子, $(src))`

```makefile
target = app 
src = $(wildcard ./*.c)
obj = $(patsubst ./%.c, ./%.o, $(src))

${target}: ${obj} 
    gcc ${obj} -o ${target}

%.o: %.c 
    gcc -c $< -o $@

.PHONY: clean
clean:
    rm $(obj) $(target) -f
```

---



## 2 内存与文件系统

### 2.1 内存管理

*虚拟地址空间：*

-   <u>大小</u>：对于32bit操作系统，有$2^{32}=4G$的可用虚拟地址空间，从0开始

    >   为进程按需分配物理内存，不会直接分配4G

-   <u>内核区</u>：3G~4G

    >   不允许用户直接操作

    -   PCB：

        -   文件描述符表：一个大小为1024的数组，数组**索引**就是**文件描述符**，数组元素代表文件

            0：`STDIN_FILENO`

            1：`STDOUT_FILENO`

            2：`STDERR_FILENO`

            >   标准输入、标准输出、标准错误默认是打开状态

            3~1023：每打开一个新文件，会占用**空闲文件描述符**中最小的那个

        -   ...（PCB中的其他内容）

    -   ...（内核区的其他内容）

-   <u>用户区</u>：0~3G

    >   允许用户访问并操作；
    >
    >   接下来的**从低地址向高地址**介绍

    -   受保护的地址（header）：0~4K

        >   `#define NULL (void*)0`指向的就是这里

    -   ELF段：ELF是Linux下**可执行文件格式**

        >   `file a.out`命令可以查看`a.out`的文件格式

        -   .text段：只读的**代码段**，二进制机器指令

            >   代码段也可以包括一些**静态库**

        -   .rodata段：只读的数据段、符号段等

        -   .data段：已初始化的**全局变量**，可读写

        -   .bss段：未初始化的**全局变量**，可读写

    -   堆空间：从低地址向高地址增长，`malloc`相关函数分配的地址空间

    -   共享库：加载程序执行时引用的**动态链接库**（C标准库等）

        >   由于加载到共享库的位置不定，所以动态库中应当时位置无关代码（相对地址）

    -   栈空间：从高地址向低地址增长，主要存放**函数栈帧**，包括调用信息、局部变量等

    -   命令行参数：`argv[]`

    -   环境变量（env）

-   <u>虚拟地址空间的优点</u>

    -   有利于编译器和操作系统利用**离散的物理地址空间**，为进程提供虚拟的**连续地址空间**
    -   有利于进程之间**地址空间的隔离**
    -   有利于在逻辑上**扩展物理内存**

---

*MMU的基本工作原理*：

-   Memory Management Unit，内存管理单元，位于CPU内部

-   主要功能

    -   虚拟内存和物理内存的映射，按**页（4k大小）**分配物理地址空间

        -   不同进程的**内核区**映射到**相同的内核物理内存**

            >   当然，不同进程的PCB不同，只是位于同一块内核物理内存中

        -   不同进程的用户区映射到不同的物理内存

    -   管理**内存访问权限**（用户级、内核级）

### 2.3 IO





## 3 进程与线程

### 3.1 进程相关数据结构

*进程控制块PCB：*

- Linux内核的进程控制块是`task_struct`结构体

  > `/usr/src/linux-headers-3.16.0-30/include/linux/sched.h`文件中可以查看`struct task_struct`结构体定义

- `task_struct`结构体重要成员
    -   进程**描述**信息：
        -   进程标识符（**PID**）：系统中每个进程都有**唯一**的id，用`pid_t`表示其**类型**，本质是非负整数

            >   Unix系统的第一个进程**init进程的pid为1**

        -   用户id和组id

    -   进程**控制和管理**信息：
        -   进程当前**状态**
        -   **信号**相关的信息
        -   **会话**（Session）和**进程组**

    -   **资源分配**清单：
        -   描述**虚拟地址空间**的信息

        -   进程可以使用的**资源上限**（Resource Limit）

            >   `ulimit -a`命令可以查看一些资源上限

    -   **处理机**相关信息：

        -   进程**切换**时需要保存和恢复的**寄存器**
        -   描述**控制终端**的信息
        -   当前**工作目录**位置
        -   `umask`掩码
        -   **文件描述符**表

---

*环境变量：*

-   操作系统中用来**指定运行环境**的一些参数

-   特征：

    -   本质是**字符串**
    -   统一的格式：`名=值1:值2:值3`
    -   描述**进程环境信息**

-   **shell进程**的常见环境变量

    -   PATH：记录**可执行**程序的**搜索路径**

    -   SHELL：记录当前所使用的**命令解析器**

    -   HOME：当前用户家目录

    -   LANG：当前使用的语言和本地信息

        >   决定了字符编码、时间、货币等信息的显示格式

    -   TERM：当前终端类型

-   在c程序中使用环境变量：

    -   存储形式：`char *[]`数组，数组名为`environ`，内部存储字符串，`NULL`作为哨兵结尾

    -   加载位置：位于用户区，高于stack的起始位置

    -   引入环境变量表：`extern char **environ`

    -   相关函数

        -   `char *getenv(const char *name);`
        -   `int setenv(const char *name, const char *value, int overwrite)`
        -   `int unsetenv(const char *name);`

        >   `man getenv`、`man setenv`、`man unsetenv`



### 3.2 进程控制

*创建进程：*

- 方式一：**运行可执行程序**时，就会创建进程

  > 一般可执行程序对应进程的<u>父进程是`bash`/shell进程</u>，
  > shell进程会将前台交给该进程，自己到后台去，直到该进程结束，再回到前台

-   方式二：`pid_t fork(void);`

    >   `#include <unistd.h>`：Unix系统标准头文件

    -   创建n个进程：

        ```c
        int i;
        for (i = 0; i < n; i++) {
            pid_t pid = fork();
            if (pid == 0) {
                break;
            }
        }
        if (i < n) {
            // child process
        } else {
            // parent process
        }
        ```
    
    -   刚fork之后：
    
        - 父子相同处：全局变量、.data、.text、栈、堆、环境变量、用户ID、宿主目录、进程工作目录、信号处理方式...
        - 父子不同处：进程ID、fork返回值、父进程ID、进程运行时间、闹钟(定时器)、未决信号集
    
    -   **读时共享写时复制**
    
        -   共享的是**物理地址空间**，虚拟的地址空间当然可以直接复制多个
    
    -   父子进程的共享资源
    
        -   文件描述符
    
            > 打开文件的结构体
    
        -    mmap建立的映射区

---

*进程描述信息：*

- 进程id相关
  - 获得进程id：`pid_t getpid(void);`
  - 获得父进程id：`pid_t getppid(void);`
- 用户id相关
  - 获取当前进程实际用户ID：`uid_t getuid(void);`
  - 获取当前进程有效用户ID：`uid_t geteuid(void);`
  - 获取当前进程实际用户组ID：`gid_t getgid(void);`
  - 获取当前进程有效用户组ID：`gid_t getegid(void);`

---

*`exec`函数族：*

- fork创建的子进程往往要调用一种exec函数以执行另一个程序。当进程调用一种exec函数时，该进程的用户空间**代码和数据**完全被新程序**替换**，从新程序的**启动例程**开始执行

  > 启动例程：调用`main`函数的函数
  >
  > 调用exec并**不创建新进程**，所以调用exec前后该**进程的id并未改变**
  >
  > 一个程序调用了`exec`之后，在不出错的情况下，不再有返回值，原程序后续代码不会执行，若出错了才有返回值，并执行原程序后续代码

- :star:`int execlp(const char *file, const char *arg, ...);`

  > l：list，p：path

  - 加载一个进程，要依赖系统当前的PATH环境变量
  - `file`：可执行程序名
  - `arg, ...`：命令行参数，从`argv[0]`开始，可变参要以`NULL`结尾

  > 举例：`execlp("ls", "ls", "-l", "-F", NULL);`

- :star:`int execl(const char *path, const char *arg, ...);`

  - 加载一个进程， 通过`路径+程序名`来加载，不需要依赖系统当前的PATH环境变量

  > 举例：`execl("/bin/ls", "ls", "-l", "-F", NULL);`

- `int execle(const char *path, const char *arg, ..., char *const envp[]);`

  - 需要引入新的环境变量表

- `int execv(const char *path, char *const argv[]);`

  > v：vector

- `int execvp(const char *file, char *const argv[]);`

- `int execve(const char *path, char *const argv[], char *const envp[]);`

  - 只有`execve`是真正的系统调用

---

*回收子进程：*

- 孤儿进程：父进程先于子进程结束，则子进程成为孤儿进程，子进程的父进程成为init进程

  > “init进程”可能是整个系统的init进程，也可能是用户的init进程

- 僵尸进程：进程终止，父进程尚未回收，子进程**残留资源（PCB）**存放于内核中，变成僵尸（Zombie）进程。

    >   所谓回收就是在**回收PCB**

- `pid_t wait(int *status)`

  - 三个功能

    - **阻塞**并等待一个子进程退出
    - **回收**子进程残留资源
    - 获取子进程结束**状态**(退出原因)

  - 返回-1代表出错（无子进程）

  - 用`status`结合**宏函数**判断子进程终止原因

    - :star:`WIFEXITED(status)`：返回值非0代表子进程**正常结束**

      如上宏为真可以使用此宏`WEXITSTATUS(status)`：获取进程**退出状态**(`exit`的参数)

    - :star:`WIFSIGNALED(status)`：返回值非0代表**异常结束**

      > Linux中所有异常结束都是因为收到了**信号**

      如上宏为真可以使用此宏`WTERMSIG(status)`：取得使子进程终止的那个**信号的编号**

    - `WIFSTOPPED(status)`：返回值非0代表子进程处于**暂停状态**

      如上宏为真可以使用此宏`WSTOPSIG(status)`：获取使子进程暂停的那个**信号的编号**

      > `WIFCONTINUED(status)`为真 → 子进程暂停后已经继续运行

- `pid_t waitpid(pid_t pid, int *status, int options);`

  - `pid`：要回收的子进程id
    - :star:大于0则回收指定id子进程
    - :star:为-1则回收任意子进程（相当于`wait`）
    - 为0则回收和当前调用waitpid的进程同一个**进程组**的所有子进程
    - 小于-1则回收指定**进程组**内的任意子进程
  - `options`：若指定为0则**阻塞**；若指定为`WNOHANG`则**不阻塞**，只是检查子进程是否结束，结束则回收，否则**返回0**并继续运行

### 3.3 进程间通信

*管道：*



---

*`mmap`*：



### 3.4 进程信号

*信号的基本概念：*

- 信号是信息的载体，有如下**特征**：

  - 简单

    > 信号的**开销很小**，就算不使用信号也会有这样的开销

  - 不能携带大量信息

    > 一般来说只能带一个**标志**过去

  - 满足某个**特设条件**才发送

- 信号**机制**：

  - 进程收到信号后，不管执行到程序的什么位置，都要**中断**运行去处理信号，处理完毕再继续执行

    > 采用与**硬件中断**类似的异步模式。但信号是**软件层面**上实现的**中断**，早期常被称为“软中断”，有一定**延时性**（相对于硬件来说）

  - :star:**每个进程收到的所有信号，都是由<u>内核负责产生并发送</u>的，<u>内核处理</u>**:star:

- 信号**产生**的五种方式：

  - 终端按键产生
  - 硬件异常产生
  - 命令产生
  - 系统调用产生
  - 软件条件产生

- 信号**状态**：

  - **递达**：递送并且到达进程

    > 内核产生信号后会**立刻发送**给相应进程

  - **阻塞**（屏蔽、未决）：信号产生后受到阻塞，未能递达进程

- 信号的**编号**与**信号集**

  - 信号**编号**

    - 可以使用`kill –l`命令查看当前系统可使用的信号有哪些

    - 1-31号信号称之为**常规信号**（也叫普通信号或标准信号）

    - 34-64称之为实时信号

      > 与嵌入式开发和驱动编程有关

    > `man 7 signal`可以查看相关文档

  - **阻塞信号集(信号屏蔽字)**

    - 将某些信号加入集合，对他们设置屏蔽，收到这些信号时，对其的处理将推迟到解除屏蔽后

        >   常规信号会阻塞但**不支持排队**，产生多次**只记录一次**

  - **未决信号集**

    - 信号产生后未决信号集中**描述该信号的位**立刻翻转为1，表信号处于未决状态，信号被处理后对应位再翻转为0

    - 信号产生后由于某些原因(主要是阻塞)不能抵达，这类信号的集合称之为未决信号集。

      > 在屏蔽解除前，信号一直处于未决状态

- 信号的**三种处理方式**

  - 执行默认动作 
    - Term：终止进程
    - Ign：忽略信号（默认即时对该种信号忽略操作）
    - Core：终止进程并生成**Core文件**（记录进程死亡原因， 可用于gdb调试）
    - Stop：暂停进程
    - Cont：继续运行进程
  - 忽略：丢弃
  - 捕捉：调用用户处理函数

  > 值得注意的是 ***9) SIGKILL*** 和 ***19) SIGSTOP*** 信号，不允许忽略和捕捉，只能执行默认动作。甚至不能将其设置为阻塞。

- :star:信号**四要素**

  - 编号
  - 名称
  - 默认处理动作
  - 事件：使得该信号**产生**的事件

---

*信号的产生：*

- **终端按键**产生信号

  - Ctrl + c → ***2) SIGINT***：终止/中断

    > "INT" ----Interrupt

  - Ctrl + z → ***20) SIGTSTP***：暂停/停止

    > "T" ----Terminal 终端，只能停止与终端交互的进程

  - Ctrl + \ → ***3) SIGQUIT***：退出进程（核心已转储，也是终止进程）

- **硬件异常**产生

  - 浮点数例外：***8) SIGFPE***

    > 例如：除0
    >
    > "F" -----float 浮点数

  - 段错误：***11) SIGSEGV***

    > 例如：非法访问内存

  - 总线错误：***7) SIGBUS***

    > 例如：内存对齐出错

- **命令**产生

  - :star:`kill -信号编号 进程ID`：给对应ID的进程发送信号

    > 默认发送的是 ***15) SIGTERM***

- **系统调用**产生

  - :star:`int kill(pid_t pid, int sig);`：给对应ID的进程发送信号

    > `man 2 kill`查看相关文档

    - 成功返回0，失败返回-1并设置`errno`

  - `int raise(int sig);`：给当前进程自己发送信号

    `raise(signo) == kill(getpid(), signo);`

  - `void abort(void);`：给当前进程自己发送异常终止信号

    ***6\) SIGABRT*** 信号，终止并产生core文件

- 软件条件产生

  - :star:`unsigned int alarm(unsigned int seconds);`：设置定时器(闹钟)。在指定seconds后，内核会给当前进程发送 ***14) SIGALRM*** 信号

    > 进程收到该信号，默认动作**终止**

    - **每个进程都有且只有<u>唯一</u>个定时器**

    - 调用`alarm`后会取消旧闹钟，并**返回旧闹钟余下秒数**

      > `alarm(0)`取消闹钟

    - 定时**与进程状态无关**(自然定时法)

    > 使用time命令查看**程序执行的时间**：
    >
    > 实际执行时间 = 系统时间 + 用户时间 + **等待**时间
    >
    > > IO往往会造成较长的等待时间，程序运行的瓶颈在于IO，优化程序，首选优化IO

  - `int setitimer(int which, const struct itimerval *new_value, struct itimerval *old_value);`

    - `which`：指定定时方式

      > 自然定时：ITIMER_REAL → ***14）SIGLARM***
      >
      > 虚拟空间计时(用户空间)：ITIMER_VIRTUAL → ***26）SIGVTALRM***
      >
      > > 只计算进程占用cpu的时间
      >
      > 运行时计时(用户+内核)：ITIMER_PROF → ***27）SIGPROF***
      >
      > > 计算占用cpu及执行系统调用的时间

    - `man setitimer`学习其他参数
    
      > 可以设置周期定时

---

*信号集操作：*

- `sigset_t set;      // typedef unsigned long sigset_t;`

- 设置**自定义信号集**

  - `int sigemptyset(sigset_t *set);`：将某个信号集清0

    > 返回值：成功0、失败-1，下面3个函数返回值也一样

  - `int sigfillset(sigset_t *set);`：将某个信号集全部置1

  - `int sigaddset(sigset_t *set, int signum);`：将某个信号加入信号集

  - `int sigdelset(sigset_t *set, int signum);`：将某个信号清出信号集

  - `int sigismember(const sigset_t *set, int signum);`：判断某个信号是否在信号集中

    > 返回值：在集合1、不在：0、出错：-1

- **信号屏蔽字与未决信号集**的操作

  - :star:`int sigprocmask(int how, const sigset_t *set, sigset_t *oldset);`：屏蔽信号或解除屏蔽

    - `how`

      `SIG_BLOCK`：`set`表示需要屏蔽的信号

      `SIG_UNBLOCK`：`set`表示需要解除屏蔽的信号(set位为1代表解除屏蔽)

      `SIG_SETMASK`：`set`表示用于替代原始屏蔽及的新屏蔽集

    - 成功返回0，失败返回-1

  - `int sigpending(sigset_t *set);`：读取当前进程的**未决**信号集

    - 成功返回0，失败返回-1


---

*信号捕捉：*

- `sighandler_t signal(int signum, sighandler_t handler);`：注册一个信号捕捉函数

  > `typedef void (*sighandler_t)(int);`，参数是**信号编号**

  - 返回值为`sighandler_t `，若是`SIG_ERR`则代表出错，若不是则代表该信号之前的捕捉函数
  - `handler`是要注册的处理函数，也可赋值为`SIG_IGN`表**忽略**或`SIG_DFL`表执行**默认动作**

- :star:`int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);`

  - 成功：0；失败：-1

  - `struct sigaction`结构体重要成员

    - `sa_handler`成员：要注册的处理函数

    - `sigset_t sa_mask`：信号处理函数执行期间进程的**信号屏蔽字**

      > 仅在处理函数被调用期间屏蔽生效，是临时性设置；当然，如果处理函数执行期间未被屏蔽的信号到来，则依然按照正常的机制去处理

    - `int sa_flags`：通常设置为0，代表使用默认属性，即处理函数执行期间**自动屏蔽**被捕捉信号
    
        >   如果不希望自动阻塞被捕捉信号，则可以设置为`SA_NODEFER`，当然这种情况要求处理函数是可重入的（后面会讲”重入“）

- 内核实现信号捕捉的过程

  1. 进程收到成功**递达**的信号，陷入内核
  2. **内核**处理信号，如果有注册处理函数，则回到用户态**执行回调**
  3. 处理函数执行完后，执行特殊的**系统调用**函数`sigreturn`，再次回到内核
  4. 最后回到用户态继续向后执行

- 通过 ***17) SIGCHILD*** 信号回收子进程

    1.   屏蔽SIGCHILD信号
    2.   注册 SIGCHILD 信号处理函数
         -   在函数中通过`while ((pid = waitpid(0, &status, WNOHANG)) > 0)` 的方式回收子进程
    3.   解除对SIGCHILD信号的屏蔽

---

*`pause`函数与`sigsuspend`函数*：

-   `int pause(void);`：让进程主动阻塞，等待信号唤醒

    -   不能返回的情况

        -   信号的**默认处理动作**是终止进程，进程**终止**

            >   一般来说，**执行默认动作**就不能返回了

        -   信号被**忽略**

        -   信号被**屏蔽**

    -   可以返回的情况：**捕捉**且**处理函数**执行后

        -   返回 -1 并设置errno为EINTR

-   `int sigsuspend(const sigset_t *mask);`：让进程主动阻塞，等待信号唤醒，阻塞期间的信号屏蔽字由参数决定

---

*信号传参：*

-   发送信号时传参：`int sigqueue(pid_t pid, int sig, const union sigval value);`

    -   `union sigval {int  sival_int; void *sival_ptr;};`

        >   注意，不同进程**虚拟地址空间**不同，所以**不同进程之间**用信号传地址是没有太大意义的，但**同一个进程**可以

    -   成功返回0，失败返回-1并设置error

-   捕捉信号时接收到的参数：`int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);`

    -   `sigaction`结构体的`sa_sigaction`成员：`void (*sa_sigaction)(int, siginfo_t *, void *);`

        >   `siginfo_t`是较为复杂的结构体，详见`man sigaction`

    -   用`sa_sigaction`成员代替`sa_handler`，并且`sa_flags`要置为`SA_SIGINFO`


---

*中断系统调用：*

-   系统调用的一种分类

    -   慢速系统调用：可能会使进程永远阻塞的一类系统调用

        >   如，read、write、pause、wait...

    -   其他系统调用

-   慢速系统调用执行期间捕捉到信号，则系统调用会被中断，处理函数执行后，慢速系统调用通常会返回-1，并设置`errno`为`EINTR`

    >   想中断慢速系统调用，不能屏蔽、忽略、执行默认动作；
    >
    >   EINTR代表“被信号中断“

-   中断慢速系统调用后，如果想重启，可以自行在程序中书写重启的逻辑，也可以设置`sa_flags`参数为`SA_RESTART`

    >   `SA_INTERRUPT`为不重启



### 3.5 竞态条件

*时序竞态问题：*

-   竞态条件，跟系统负载有很紧密的关系，体现出信号的不可靠性。系统负载越严重，信号不可靠性越强。
-   竞态问题就是指由于进程抢占CPU时间片执行的**异步性和不确定性**导致的**数据不一致问题**。这种意外情况只能在编写程序过程中，提早预见，主动规避，而无法通过gdb程序调试等其他手段弥补。
-   条件：**共享**数据**并发**访问，且有**写**动作

---

*全局变量的异步读写*：

-   进程本身的函数和内核调用的**回调函数**可能会对全局变量有异步读写操作
-   解决方案
    -   不使用全局变量
    -   锁机制

---

*可重入与不可重入函数：*

-   一个函数在被调用执行期间，由于某种时序又被重复调用，称之为“重入”。
    -   不可重入函数意思是，在函数的执行过程中，受到异步时序影响**再次执行**此函数（原执行暂停，直到再次执行结束后再继续执行），最终得到的结果与两次**串行执行**函数不一致
-   可重入函数的特点
    -   不能含有全局变量和`static`变量
    -   不能使用`malloc`、`free`
    -   不是**标准IO**函数
-   信号处理程序能调用的可重入函数可参阅`man 7 signal`



### 3.6 进程组与会话

*终端与Shell进程：*

-   所谓终端，就是**所有输入输出设备的总称**

-   UNIX系统中用户可以通过**终端**登录系统，并得到一个**Shell进程**，终端就是Shell进程的**控制终端**。控制终端记录在PCB中，而`fork`时复制PCB，所以Shell进程启动的其他进程的控制终端也是该终端

-   终端的启动流程：init$\rarr$fork、exec$\rarr$getty$\rarr$login$\rarr$exec、bash

-   终端与用户进程的交互：

    用户进程

    ​	$\uarr\darr$

    系统调用

    ​	$\uarr\darr$

    line discipline

    ​	$\uarr\darr$

    终端设备驱动程序

    ​	$\uarr\darr$

    终端设备

    >   line disciline: 线路规程，用来过滤键盘输入的内容

-   `char *ttyname(int fd);`：由文件描述符查出对应的文件名/设备名

---

*进程组的概念与特性：*

- 进程组，也称之为**作业**，代表一个或多个进程的集合。**每个进程都属于一个进程组**，操作系统设计的进程组的概念，是为了简化**对多个进程的管理**。

- 父进程`fork`创建子进程的时候，默认子进程与父进程属于同一进程组，父进程为组长进程。**组长进程**的**进程ID**等于**组进程ID**。

- 进程组**生存期**：进程组创建的**最后一个进程离开**(终止或转移到另一个进程组)

  > 只要进程组中有一个进程存在，进程组就存在，与**组长进程是否终止**无关

---

*进程组操作函数：*

- `pid_t getpgrp(void);`：获取当前进程的进程组ID

- `pid_t getpgid(pid_t pid); `：获取指定进程的进程组ID

  - 如果`pid`为0，与`getpgrp`作用相同

- `int setpgid(pid_t pid, pid_t pgid);`：改变进程默认所属的进程组

  - 可用来**加入**一个现有的进程组或**创建**一个新进程组(并作为组长)

  - 成功返回0失败返回-1并设置errno

  - 权级问题：非root进程只能改变**自己创建的子进程**，或**有权限操作**的进程

    > 也可以改变自己的进程组

---

*会话的概念与特性：*

- 会话就是**一组进程组**
- 创建会话的进程**不能是原组长**进程。创建会话的进程会成为**首进程/会长**(session leader)，并且会成为一个**新进程组的组长**
- **新会话**<u>丢弃原有的控制终端</u>，**没有控制终端**，只在后台执行
- Shell进程创建出的进程，进程组会变化，但会话与Shell进程保持一致

---

*会话操作函数：*

- `pid_t getsid(pid_t pid);`：获取进程**所属的会话ID**
  - 成功返回会话ID，失败返回-1并设置errno
  - `pid`为0表示查看当前进程会话ID
- `pid_t setsid(void);`：创建一个会话，并以自己的ID设置**新进程组ID**，同时也是**新会话ID**
  - 成功返回新会话ID，失败返回-1并设置errno
  - 创建会话的一般流程：父进程`fork`并退出，子进程`setsid`

---

*守护进程：*

- Daemon(精灵)进程，是Linux中的**后台服务进程**，通常独立于控制终端，并且**周期性**地执行某种任务或等待处理某些发生的事件。一般采用以d结尾的名字。

- **创建守护进程**的模型

  1. 创建子进程，父进程退出

     > 形式上**脱离了控制终端**

  2. 在子进程中创建新会话

     > 使子进程**完全独立**出来，脱离控制，不受用户登录和注销的影响

  3. 改变**工作目录**为根目录等不会被删除的目录

     > `chdir()`函数

  4. 重设文件权限掩码

     > `umask()`函数
     >
     > 防止继承的文件创建屏蔽字拒绝某些权限，增加守护进程灵活性

  5. 关闭标准输入、输出、错误的**文件描述符**

     > 继承的打开文件不会用到，浪费系统资源，无法卸载；
     >
     > 更常用的做法是，将0、1、2重定向到/dev/null，保持可用的文件描述符从3开始

  6. 开始执行守护进程核心工作（周期性执行）

  7. 守护进程退出处理程序模型


  >   如果想让守护进程随着机器重启，可以修改`~/.bashrc`，将守护进程的启动加入进去



### 3.7 线程基础

*线程资源：*

-   共享资源

    -   大部分内存地址空间 (.text/.data/.bss/heap/共享库)、文件描述符表

        >   除了**栈**和errno变量不共享，其他的包括**全局变量**都共享，所以可以在一个线程中释放其他线程的申请的空间（`malloc`、`mmap`）

    -   当前工作目录、用户ID和组ID

    -   每种信号的处理方式

-   非共享资源

    - 线程id
    
    - 处理器现场和栈指针(内核栈)、独立的**栈空间**(用户空间栈)
    
      > 同一进程各线程栈的空间地址值是互相不冲突、不相同的
    
    - errno变量
    
    - **信号屏蔽字**
    
    -   调度优先级

---

*线程操作原语：*

>   编译链接时要加`-pthread`才可以链接到这些函数，同时注意版本`getconf GNU_LIBPTHREAD_VERSION`

-   `pthread_t pthread_self(void);`：获取线程ID
    -   `pthread_t`在Linux中本质是无符号整数

    -   该函数调用不会失败，返回的就是线程ID

        >   线程ID和LWP线程号不是同一个东西，**LWP线程号**是**CPU给线程分配时间片**的依据
        >
        >   >   `ps -Lf 进程ID`可以查看线程LWP号
    
-   `int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);`：
    -   `thread`：是传出参数，代表创建的线程ID

    -   `attr`：线程属性，默认可以传NULL

    -   `start_routine`：线程的主控函数

    -   `arg`：主控函数的参数

    -   成功返回0，失败直接返回error number

        >   Linux环境下所有线程API都是这样的返回
        
    -   循环创建多个子线程

        `pthread_create(&tid, NULL, thrd_func, (void *)arg)`

        -   子线程中`arg`可能的使用方式：`(int)arg`

        -   如果使用`(void *)&arg`这种方式，传入的是父线程的地址空间，可能会造成问题

            >   这种情况下可能的使用方式：`*((int *)arg)`

-   `void pthread_exit(void *retval);`

    -   `retval`表示线程退出状态，通常传`NULL`

    -   用`pthread_exit`退出主控线程或子线程，若**进程内还有其他线程**存在，则进程不会结束

        >   如果在主控线程或子线程中使用`exit`函数退出，会直接退出整个进程；
        >
        >   如果在主控线程中使用`return`退出，会直接退出整个进程；
        >
        >   如果在子线程的主控函数中使用`return`退出，相当于用`pthread_exit`退出

-   `int pthread_join(pthread_t thread, void **retval);`：**阻塞**等待线程退出，获取线程退出状态

    -   `retval`：存储线程结束状态，指向的是`pthread_exit`函数的入参，所以是`void**`类型
    -   可能的使用方式：`pthread_join(tid, (void **)&retval)`，`retval`是**一级指针**
    -   与进程的区别是，线程与线程之间也可以调用`pthread_join`来“回收”
    -   成功返回0，失败返回error number

-   `int pthread_detach(pthread_t thread);`：分离线程

    -   线程分离状态：线程与主控线程断开关系，结束后**自动释放**（清理PCB）
    -   如果用`pthread_join`回收分离的线程，会出错，返回22
    -   成功返回0，失败返回error number

-   `int pthread_cancel(pthread_t thread);`：杀死(取消)线程

    -   线程的取消并不是实时的，需要等待线程**到达**某个**<u>取消点(检查点)</u>**时

        -   取消点：线程检查是否被取消，并按请求进行动作的一个位置，通常是某些系统调用

            >   `man 7 pthreads`可以查看具备取消点的系统调用列表

        -   自行添加取消点：`pthread_testcancel();`

    -   如果用`pthread_join`回收取消的线程，会出错，返回-1

        >   `pthread.h: #define PTHREAD_CANCELED ((void *) -1)`

    -   成功返回0，失败返回error number

-   `int pthread_equal(pthread_t t1, pthread_t t2);`：比较两个线程ID是否相等

    -   当然，目前`pthread_t`就是整型，可以直接用`==`判等，之后如果改成其他的比如结构体类型，就需要用`pthread_equal`了


---

*线程属性：*

-   `pthread_attr_t `结构体的重要成员

    -   `int etachstate;   //线程的分离状态`

    -   `size_t stacksize;     //线程栈的大小`

        >   线程栈默认大小是**均分进程栈（8MB）**

    -   `size_t guardsize;    //线程栈末尾的警戒缓冲区大小`

        >   警戒区用于防止线程栈溢出

-   线性属性初始化与销毁

    -   `int pthread_attr_init(pthread_attr_t *attr);`：初始化线程属性
        -   应先初始化线程属性，再`pthread_create`创建线程。当然这个函数只是初始化，不是设置属性
        -   成功返回0，失败返回错误号
    -   `int pthread_attr_destroy(pthread_attr_t *attr);`：销毁线程属性所占用的资源
        -   成功返回0，失败返回错误号

-   线程分离的属性

    -   `int pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate);`：设置线程的分离属性

        -   `detachstate`

            `PTHREAD_CREATE_DETACHED`：分离

            `PTHREAD _CREATE_JOINABLE`：不分离

    -   `int pthread_attr_getdetachstate(pthread_attr_t *attr, int *detachstate);`：获取线程的分离属性

    >   如果设置一个线程为分离线程，而这个线程运行又非常快，它很可能在`pthread_create`函数返回之前就终止了，终止后可能将**线程号和系统资源**移交给其他的线程使用，这样调用`pthread_create`的线程就得到了**错误的线程号**。可以用线程同步的手段解决这个问题。

-   线程的栈空间属性

    -   `int pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize);`：设置栈地址和大小

        >   可以将线程的栈地址设置到**堆**中（`malloc`）

    -   `int pthread_attr_getstack(pthread_attr_t *attr, void **stackaddr, size_t *stacksize);`：获取栈地址和大小

    -   `int pthread_attr_setstacksize(pthread_attr_t *attr, size_t stacksize);`：设置栈大小

    -   `int pthread_attr_getstacksize(pthread_attr_t *attr, size_t *stacksize);`：获取栈大小


---

*线程使用注意事项：*

-   线程库版本问题`getconf GNU_LIBPTHREAD_VERSION`
-   避免僵尸线程，要么`join`回收，要么`detach`分离（或者修改线程属性使其分离）
-   尽量避免在多线程模型中使用`fork`。`fork`后子进程中只存在调用`fork`的“线程”，其他“线程”都退出了
-   尽量避免在多线程模型中使用信号机制



### 3.8 线程和进程的同步与互斥

*互斥量`mutex`：*

-   `pthread_mutex_t`本质是结构体，可以简单认为其只有0、1两种取值

-   `mutex`相关函数

    >   这些函数均是成功返回0，失败返回错误号

    -   `int pthread_mutex_init(pthread_mutex_t *restrict mutex, const pthread_mutexattr_t *restrict attr);`：初始化一个互斥锁
        -   可以理解为`mutex = 1`
        
        -   `restrict`关键字：所有修改**该指针指向内存**的操作，只能通过本指针完成，不能通过除本指针以外的其他变量或指针修改
        
        -   `attr`：互斥锁的属性，传入`NULL`为默认属性
        
        -   也可以使用**宏**直接初始化：（静态初始化）
        
            `pthead_mutex_t muetx = PTHREAD_MUTEX_INITIALIZER;`
        
    -   `int pthread_mutex_destroy(pthread_mutex_t *mutex);`：销毁一个互斥锁

    -   `int pthread_mutex_lock(pthread_mutex_t *mutex);`：上锁
        -   可理解为`mutex--`
        -   锁被占用则阻塞，直到成功获得锁
        
    -   `int pthread_mutex_unlock(pthread_mutex_t *mutex);`：解锁
        -   可理解为`mutex++`
        
    -   `int pthread_mutex_trylock(pthread_mutex_t *mutex);`：尝试上锁
        -   锁被占用不阻塞，返回`EBUSY`代表无法获得锁

-   `mutex`的应用

    1.   定义锁：`pthread_mutex_t mutex;`
         -   一般为**全局变量**
    2.   初始化锁
    3.   上锁
    4.   解锁

    >   锁的**粒度**应当尽量小

-   死锁

    -   两种产生情况
        -   不可重入锁
        -   两把锁
    -   对应解决方法
        -   可重入锁
        -   `trylock`失败则释放锁

---

*读写锁`rwlock`：*

-   `rwlock`特性

    -   :star:写独占、读共享
    -   :star:写锁优先级高

-   `rwlock`相关函数

    >   这些函数均是成功返回0，失败返回错误号。用法与`mutex`很相似

    -   `int pthread_rwlock_init(pthread_rwlock_t *restrict rwlock, const pthread_rwlockattr_t *restrict attr);`：初始化一把读写锁
        -   `attr`：传入`NULL`代表使用默认属性
        
        -   也可以使用**宏**直接初始化：（静态初始化）
        
            `pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;`
        
    -   `int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);`：销毁一把读写锁

    -   ` int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);`：请求读锁

    -   `int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);`：请求写锁

    -   `int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);`：解锁

    -   `int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);`：非阻塞请求读锁

    -   `int pthread_rwlock_trywrlock(pthread_rwlock_t *rwlock);`：非阻塞请求写锁

-   `rwlock`的应用：`pthread_rwlock t rwlock;`

    >   与`mutex`很相似

-   `rwlock`的优点：适合读多写少的场景，减少不必要的竞争

---

*条件变量`cond`：*

-   特点：

    -   条件变量本身不是锁！但它也可以造成线程阻塞。
    -   通常与互斥锁配合使用，给多线程提供一个会合的场所。

-   `cond`相关函数：

    >   这些函数均是成功返回0，失败返回错误号。

    -   `int pthread_cond_init(pthread_cond_t *restrict cond, const pthread_condattr_t *restrict attr);`：初始化一个条件变量

        -   也可以使用**宏**直接初始化：（静态初始化）

            `pthread_cond_t cond = PTHREAD_COND_INITIALIZER;`

    -   `int pthread_cond_destroy(pthread_cond_t *cond);`：销毁一个条件变量

    -   :star:`int pthread_cond_wait(pthread_cond_t *restrict cond, pthread_mutex_t *restrict mutex);`：阻塞等待一个条件变量满足
        -   `mutex`：需要传入一个也初始化好的`mutex`，并且已经对其**加锁**了

        -   会释放已掌握的互斥锁（**解锁互斥量**），相当于`pthread_mutex_unlock(&mutex)`

            >   **检查条件变量是否满足与加锁**的操作是不可分割的

        -   当被**唤醒**，函数返回即将时，会解除阻塞并重新申请**获取互斥锁**，相当于`pthread_mutex_lock(&mutex)`

    -   `int pthread_cond_signal(pthread_cond_t *cond);`：唤醒**至少一个**阻塞在条件变量上的线程

    -   `int pthread_cond_broadcast(pthread_cond_t *cond);`：唤醒**全部**阻塞在条件变量上的线程

    -   `int pthread_cond_timedwait(pthread_cond_t *restrict cond, pthread_mutex_t *restrict mutex, const struct timespec *restrict abstime);`：限时等待一个条件变量

        -   也会释放锁和申请锁

        -   `abstime`：绝对时间，是相对于`1970-1-1 00:00:00`的时间

            >   可以在`man sem_timedwait`中找到对应结构体的定义

            >   正确用法：
            >
            >   `time_t cur = time(NULL);`
            >
            >   `struct timespec t;`
            >
            >   `t.tv_sec = cur + 1`
            >
            >   `pthread_cond_timedwait(&cond, &mutex, &t)`

-   条件变量的优点：相比于`mutex`，可以减少不必要的竞争，提高效率

    >   例如生产者与消费者模型中，在没有产品时，使用条件变量，消费者就**不必互相竞争，而是都等待**

---

*信号量`semaphore`：*

-   `semaphore.h`，信号量，可以理解成互斥锁的“加强版”，可以进一步细化锁，保证互斥与同步，又提高并发度

-   主要应用函数（注意，没有`pthread`前缀，进程线程都可以用）

    >   这些函数都是成功返回0， 失败返回-1，同时设置errno

    -   `int sem_init(sem_t *sem, int pshared, unsigned int value);`：初始化一个信号量
        - `pshared`：0表示只用于线程间，非0表示可用于进程间
        
        - `value`：信号量初值
        
          > **信号量的初值决定了占用信号量的线程/进程个数**
        
    - `int sem_destroy(sem_t *sem);`：销毁一个信号量

    - `int sem_wait(sem_t *sem);`：给信号量加锁（`sem--`）

    - `int sem_post(sem_t *sem);`：给信号量解锁（`sem++`）

    - `int sem_trywait(sem_t *sem);`：尝试对信号量加锁

    -   `int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);`：限时尝试对信号量加锁

-   信号量的特点：可以由多个线程/进程占用

---

*进程间同步：*

- 通过互斥量`mutex`实现：指定初始化时的属性`pthread_mutexattr_t mattr attr`

  - `int pthread_mutexattr_init(pthread_mutexattr_t *attr);`：初始化一个**`mutex`属性**对象

  - `int pthread_mutexattr_destroy(pthread_mutexattr_t *attr);`：销毁**`mutex`属性**对象

  - `int pthread_mutexattr_setpshared(pthread_mutexattr_t *attr, int pshared);`：修改`mutex`的共享属性

    - `PTHREAD_PROCESS_PRIVATE`：进程间私有，即线程锁

      > 也是默认属性

    - `PTHREAD_PROCESS_SHARED`：进程锁

- 借助文件锁实现：`int fcntl(int fd, int cmd, ... /* arg */ );`

  - `cmd`：函数操作类型

    - `F_SETLK`：设置文件锁（trylock）

    - `F_SETLKW`：设置文件锁（lock、unlock）

      > 通过下面结构体的`l_type`成员指定

    - `F_GETLK`：获取文件锁

  - 可变参：`struct flock`

    `struct flock {`

    ​       `short l_type;       锁的类型：F_RDLCK 、F_WRLCK 、F_UNLCK`

    ​       `short l_whence;     偏移位置：SEEK_SET、SEEK_CUR、SEEK_END `

    ​       `off_t l_start;        起始偏移：1000`

    ​       `off_t l_len;         长度：0表示整个文件加锁`

    ​       `pid_t l_pid;        持有该锁的进程ID：(F_GETLK only)`

    ​    ` };`

    > 提供了读锁和写锁，也允许只锁一个文件的**一部分**

  > 多线程同步不能使用文件锁，因为同一个进程中的多线程共享文件描述符，也共享相应的文件结构体

## 4 网络编程



