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

- `-I 目录`：指定头文件所在目录
- `-D 宏名`：指定一个宏
- `-O1`、`-O2`、`-O3`：生成汇编之前**优化**代码，`-O`后面数字越大，优化等级越大
- `-Wall`：输出**警告**信息
- `-g`：添加调试信息，之后可以用gdb工具调试

---

*静态库的制作：*

…







### 1.2 gdb





### 1.3 makefile

*一个规则：*



---

*两个函数：*



---

*三个变量：*



---



## 2 系统调用函数

### 2.1 IO



### 2.2 文件目录操作





## 3 进程与线程

### 3.1 进程相关信息

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
  - 获取当前进程使用用户组ID：`gid_t getgid(void);`
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

  - 加载一个进程，需要借助PATH环境变量
  - `file`：可执行程序名
  - `arg, ...`：命令行参数，从`argv[0]`开始，可变参要以`NULL`结尾

  > 举例：`execlp("ls", "ls", "-l", "-F", NULL);`

- :star:`int execl(const char *path, const char *arg, ...);`

  - 加载一个进程， 通过`路径+程序名`来加载，不需要环境变量

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

    > 采用与**硬件中断**类似的异步模式。但信号是**软件层面**上实现的**中断**，早期常被称为“软中断”

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

  - **未决信号集**

    - 信号产生后未决信号集中**描述该信号的位**立刻翻转为1，表信号处于未决状态，信号被处理后对应位再翻转为0

    - 信号产生后由于某些原因(主要是阻塞)不能抵达，这类信号的集合称之为未决信号集。

      > 在屏蔽解除前，信号一直处于未决状态

- 信号的**三种处理方式**

  - 执行默认动作 
    - Term：终止进程
    - Ign：忽略信号（默认即时对该种信号忽略操作）
    - Core：终止进程并生成**Core文件**（查验进程死亡原因， 用于gdb调试）
    - Stop：暂停进程
    - Cont：继续运行进程
  - 忽略：丢弃
  - 捕捉：调用用户处理函数

  > 值得注意的是 ***9) SIGKILL*** 和 ***19) SIGSTOP*** 信号，不允许忽略和捕捉，只能执行默认动作。甚至不能将其设置为阻塞。

- 信号**四要素**

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

  - `int raise(int sig);`：给当前进程自己发送信号

    `raise(signo) == kill(getpid(), signo);`

  - `void abort(void);`：给当前进程自己发送异常终止信号

    ***6\) SIGABRT*** 信号，终止并产生core文件

- 软件条件产生

  - :star:`unsigned int alarm(unsigned int seconds);`：设置定时器(闹钟)。在指定seconds后，内核会给当前进程发送 ***14) SIGALRM*** 信号

    > 进程收到该信号，默认动作终止

    - **每个进程都有且只有<u>唯一</u>个定时器**

    - 调用`alarm`后会取消旧闹钟，并返回旧闹钟余下秒数

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

- 设置自定义信号集

  - `int sigemptyset(sigset_t *set);`：将某个信号集清0

    > 返回值：成功0、失败-1，下面3个函数返回值也一样

  - `int sigfillset(sigset_t *set);`：将某个信号集全部置1

  - `int sigaddset(sigset_t *set, int signum);`：将某个信号加入信号集

  - `int sigdelset(sigset_t *set, int signum);`：将某个信号清出信号集

  - `int sigismember(const sigset_t *set, int signum);`：判断某个信号是否在信号集中

    > 返回值：在集合1、不在：0、出错：-1

- 信号屏蔽字与未决信号集的操作

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

  > `typedef void (*sighandler_t)(int);`

  - 返回值为`sighandler_t `，若是`SIG_ERR`则代表出错，若不是则代表该信号之前的捕捉函数
  - `handler`是要注册的处理函数，也可赋值为`SIG_IGN`表**忽略**或`SIG_DFL`表执行**默认动作**

- :star:`int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);`

  - 成功：0；失败：-1

  - `struct sigaction`结构体重要成员

    - `sa_handler`成员：要注册的处理函数

    - `sigset_t sa_mask`：信号处理函数执行期间进程的**信号屏蔽字**

      > 仅在处理函数被调用期间屏蔽生效，是临时性设置

    - `int sa_flags`：通常设置为0，表使用默认属性，处理函数执行期间被捕捉信号再次到来时**自动屏蔽**，而且阻塞的常规信号不支持排队，产生多次**只记录一次**

- 内核实现信号捕捉的过程

  1. 进程收到成功递达的信号，陷入内核
  2. 内核处理信号，如果有注册处理函数，则回到用户态执行处理函数
  3. 处理函数执行完后，执行特殊的系统调用函数`sigreturn`，再次回到内核
  4. 最后回到用户态继续向后执行



### 3.5 进程组与守护进程



### 3.6 线程







