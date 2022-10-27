---
title: MIT操作系统实验
date: 2022-10-23 22:15:02
tags:
  - 操作系统
  - 计算机
---

## Lab 3

### Task 1: Print a page table

目标分析：

- 指导书已经指明了打印函数的声明以及调用方式，会在进程id为1的进程（shell进程）调用`exec`函数时打印其页表信息
- 

实施方案：

- exec.c：将`if(p->pid==1) vmprint(p->pagetable)`插入到对应位置
- kernel/vm.c：定义`vmprint()`函数
- 

### Task 2: A kernel page table per process



### Task 3: Simplify `copyin/copyinstr`
