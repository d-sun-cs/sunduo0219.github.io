---
title: MIT操作系统实验
date: 2022-10-23 22:15:02
tags:
  - 操作系统
  - 计算机
---

## Lab 3: page tables

> 参考资料：
>
> - http://t.csdn.cn/g0Rpl
>
>   - <u>**地址按页对齐**</u>：`PGROUNDUP`和`PGROUNDDOWN`获取的应当是**虚拟地址空间中的页面基址**，UP是对齐到**高地址另一页**的基址，DOWN是对齐到**低地址本页**的基址
>
>     > 另一页和本页是相对于传入的**虚拟地址**所在的页来说的。如果本来就已经对齐了，调用这两个宏后地址不变。
>
> - http://t.csdn.cn/pgFTT
>
>   - :star:**<u>*SATP*寄存器</u>**：`w_satp(MAKE_SATP(kernel_pagetable))`设置了**MMU要使用的页表**。在第一次调用该函数之前，没有开启页表机制，MMU不翻译地址，程序使用的都是**物理地址**。在调用该函数设置了页表后，MMU负责地址翻译，程序使用的地址都会被认为成是**逻辑地址**。
>
>     > 当然，kernel使用的page table大部分都是**直接映射**，所以开启页表机制后，kernel认为自己使用的一个地址是物理地址时，虽然这个地址之后会经过MMU翻译，但翻译出来的地址依然是**值相同的物理地址**。这也是为什么大部分kernel相关的函数可以在开启逻辑地址映射后能继续正常工作。
>
> - http://t.csdn.cn/jtD4j
>
>   - **<u>`walk`函数</u>**：地址的翻译本质上是由硬件MMU完成的，不需要操作系统干涉，xv6中提供`walk`函数**是对硬件地址翻译过程的模拟**，因为至少在初始化页表时是需要这种操作的
>
>     > 给MMU设置完页表所在内存位置后，MMU就可以利用该页表做地址转换。如果MMU发现某个PTE没有映射，就会产生**硬件级别的异常**。
>
>   - `PTE_U`是用户进程页表PTE带有的flag，对于内核来说如果有`PTE_U`则无法访问

### Task 1: Print a page table

*目标分析：*

- 任务要求在进程id为1的进程调用`exec`函数时打印其页表信息
- 打印的具体信息包括：
  - `pagetable_t`参数本身
  - 每个有效的页表项（PTE）：
    - 用若干个`..`表示PTE所在页表的层级
    - PTE所在页表中的索引
    - PTE本身的内容
    - 由PTE得出的物理地址


---

*实施方案：*

- `vmprint`函数的**声明与调用**

  - 在kernel/defs.h中声明函数：`void vmprint(pagetable_t);`。
  - 按指导书要求将`if(p->pid==1) vmprint(p->pagetable)`插入到kernel/exec.c对应位置。

- `vmprint`函数的实现：

  > 根据指导书提示，借鉴`freewalk`函数的实现

  - 在kernel/vm.c中定义`vmprint`函数，调用`vmprint_depth`函数：

    - `vmprint_depth`只定义在kernel/vm.c中：

      `void vmprint_depth(pagetbale_t pgtbl, int depth) {...}。`

    - `vmprint_depth`主要是为了实现**递归**的逻辑，同时多携带一个`depth`代表**页表级数**。

  - 实现递归函数`vmprint_depth`：

    1. 如果根页表（`depth == 1`），则打印任务要求的第一句话。
    2. 如果已经超过了三级，则递归结束。
    3. 根据`depth`，产生代表深度的前缀，即若干个`..。`
    4. 借鉴`freewalk`中的`for`循环，针对有效的PTE，按要求获取并打印其信息，并递归调用`vmprint_depth`函数，深度`depth`加1。

### Task 2: A kernel page table per process

*目标分析：*

- 在xv6的默认实现中，每个进程都有一个用户地址空间的页表，所有进程共用一个内核页表。此任务要求为**每个进程**也都分配**一个自己内核页表。**
- 为每个进程都分配一个内核页表后，还需要在必要的位置**使用**到进程的内核页表，而不是之前的**全局页表。**

---

*实施方案：*

- 进程内核页表的**初始化**：

  1. 新增成员变量：在kernel/proc.h文件中，给`struct proc`结构体新增一个**成员变量**`pagetable_t kpgtbl`，用于存放**内核页表。**

  2. 定义进程内核页表初始化函数：任务要求不修改原全局页表，所以在kernel/vm.c文件中，新定义一个类似`kvminit`函数，用于初始化进程的内核页表。

     - 定义函数`kvm_per_proc_kpgbtl_init`直接复制`kvminit`函数的内容，然后将原先对全局页表的操作改成对局部变量`pagetable_t kpgbtl`的操作，并返回该局部变量。

       > 在做下一个任务时，发现**不能完全复制所有的映射关系**，具体修改会在下个任务中说明。

     - 为了能实现类似`kvmmap`的功能，再新定义一个函数`kvm_per_proc_kpgbtl_map`，相比于`kvmmap`函数，新增了`pagetable_t kpgbtl`作为参数，代表要增加映射的内核页表，且在函数体内部调用`mappages`时传入该参数。

     > 同时要将`kvm_per_proc_kpgbtl_init`函数和`kvm_per_proc_kpgbtl_map`函数添加到kernel/defs.h文件中，方便在其他文件中使用

  3. 调用进程内核页表初始化函数：在kernel/proc.c文件的`allocproc`函数中，**模仿用户页表的初始化方式**，调用`kvm_per_proc_kpgbtl_init`函数，为进程的`kpgbtl`成员初始化。

- 添加内核栈的映射：

  - 将`procinit`函数的`for`循环中对全局内核页表添加内核栈映射的代码移动到`allocproc`函数中，在初始化完进程内核页表后，紧接着为该进程创建内核栈，并调用`kvm_per_proc_kpgbtl_map`函数在进程内核页表中添加内核栈的映射。
  - 在`procinit`函数中依然保留初始化进程`lock`、设置进程`kstack`成员等代码不变。

- 内核页表的切换：

  - 在kernel/proc.c文件中的`scheduler`函数中，找到进程切换的代码`swtch(&c->context, &p->context);`。在进程切换执行前，模仿`kvminithart`函数，将进程的内核页表加载到CPU的satp寄存器中。
  - 任务要求在没有进程运行时依然使用全局内核页表，所以在`swtch`调用后，再调用一次`kvminithart`函数，重新加载全局页表到satp寄存器

- 内核页表的释放：

  > 这里所说的“释放”，主要指删除之前建立的映射关系

  - 在kernel/proc.c文件的`freeproc`函数中，模仿用户页表的释放方式，同样释放进程的内核页表

  - 模仿`proc_freepagetable`函数同样定义一个`proc_freekpgtbl`函数，用于给`freeproc`函数释放内核页表时调用。`proc_freekpgtbl`函数中首先调用`uvmunmap`，删除内核页表中对内核栈的映射（同时也释放内核栈的物理存储空间，因为内核栈是随着进程创建而创建的，并非之前的提前都创建好），然后调用一个新定义的函数`kvm_freekpgtbl`，释放内核页表的其他内容。

    > `kvm_freekpgtbl`定义在kernel/vm.c文件中，下一点中会讲。
    >
    > 这里之所以在kernel/proc.c文件中删除`kstack`的映射，在kernel/vm.c中删除其他映射，是因为`kstack`映射的添加代码位于kernel/proc.c文件中，而且是需要释放物理空间的，其他映射的添加代码位于kernel/vm.c文件中，并不需要释放物理空间。

  - 在kernel/vm.c文件中新定义`kvm_freekpgtbl`函数，模仿`freewalk`函数递归释放内核页表。其中的区别在于，当发现递归到最后一级页表项时，不再递归调用了，而只是清空该页表项并释放所在的最后一级页表

- 处理内核地址转换问题：

  - 按照上述步骤更改完之后再运行xv6，出现`panic kvmpa`，这说明还要修改`kvmpa`相关的地址转换逻辑。

  - 在kernel/vm.c文件的`kvmpa`函数中，找到调用`walk`的代码，将传入的全局内核页表改成**当前进程的内核页表**。

  - 可以通过`myproc()`函数获取当前进程，然后访问`kpgtbl`成员。

    > 为此需要引入两个头文件，`spinlock.h proc.h`

### Task 3: Simplify `copyin/copyinstr`

*目标分析：*

- 将**用户地址空间的映射**加入每个进程的内核页表，让`copyin/copyinstr`函数能直接解引用**用户空间指针**，不必再转换成物理地址。当用户地址空间的映射发生变化时，也要同步修改进程内核页表中的映射。

- 进程虚拟地址空间从0开始，理论最高可达`MAXVA`，但本任务要求将用户地址空间的映射加入进程的内核页表，这就要求进程虚拟地址空间的映射不能与内核虚拟地址空间冲突。所以**用户进程的虚拟地址空间的使用上界必须小于内核虚拟地址空间的使用下界**。

  > 指导书上说内核虚拟地址空间的使用下界为`PLIC`，但实际上`CLINT`更低，所以在实施方案中，删除了`kvm_per_proc_kpgbtl_init`中对`CLINT`的映射。

---

*实施方案：*

- 简化`copyin/copyinstr`函数：

  - 在kernel/vm.c中，修改原`copyin`和`copyinstr`函数，让其调用新的`copyin_new`和`copyinstr_new`。这两个新的函数定义在kernel/vmcopyin.c文件中，所以还要将它们声明在kernel/defs.h文件中。

- 实现映射关系的复制（与删除）：

  - 在kernel/vm.c文件中，模仿`uvmcopy`函数，定义`uvm_map_copy`函数，复制进程页表的映射到进程内核页表中。需要改动的地方是，只复制映射关系，而不复制物理地址上的数据，所以要删除`kalloc`、`kfree`和`memmove`相关代码即可。同时，在复制时需要去除`PTE_U`标志，这样内核态下才能正常访问。其他部分保持一致。

    > 同时需要将`uvm_map_copy`函数声明在kernel/defs.h文件中，方便在其他文件中调用

  - `fork`函数中映射关系的复制：在kernel/proc.c文件的`fork`函数中，模仿给子进程copy内存的代码，调用`uvm_map_copy`函数，将子进程的用户地址映射copy到子进程内核页表中。

  - `exec`函数中映射关系的复制：在kernel/exec.c文件的`exec`函数中，当新的进程页表形成后，需要先调用`uvmunmap`函数将进程内核页表中原有的映射删除，再调用`uvm_map_copy`函数将新的进程页表中的映射关系复制过去。

    > 调用`uvmunmap`函数时应当使用`PGROUNDUP`保证**地址对齐**

  - `grow_proc`函数中映射关系的复制与删除：sbrk系统调用实际上调用了kernel/proc.c文件中的`grow_proc`函数，所以需要修改这个函数

    - 当进程地址空间增长时，为防止与内核地址空间冲突，需要保证增长后的新地址上界小于`PLIC`，若大于则返回`-1`代表增长失败，若小于再分配新的空间。分配更多的空间后，调用`uvm_map_copy`函数增加新的映射关系，注意需要使用`PGROUNDUP`使原地址空间大小向更高的页地址对齐，否则会出现重复映射的错误。
    - 当进程地址空间缩小时，模仿`uvmdealloc`函数的做法，对齐地址，调用 `uvmunmap`删除映射即可。

  - `userinit`函数中映射关系的复制：在kernel/proc.c文件的`userinit`函数中，当第一个进程的初始化指令存放并映射好，进程页表初步形成后，调用`uvm_map_copy`函数将映射关系复制到第一个进程的内核页表中。

> 指导书上问题的回答详见answers-pgtbl.txt

## Lab4: traps

> 参考资料：
>
> 

### Task1: RISC-V assembly

### Task2: Backtrace

### Task3: Alarm
