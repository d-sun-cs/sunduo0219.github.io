---
title: nginx
tags:
  - 计算机
  - nginx
category: 学习资源
abbrlink: a477be03
date: 2022-09-22 20:55:17
---

## 1 概述

### 1.1 安装与基本使用

- 目前有4种比较有名的版本：nginx开源、nginx商业、OpenResty、Tengine

- 运行nginx主目录下的`sbin/nginx`即可启动、终止、关闭、重新加载配置

  > nginx默认运行在80端口



### 1.2 目录结构

- sbin：存放可执行程序**nginx**
- conf：存放**配置文件**
- html：存放页面和其他**静态资源**
- logs：存放**日志**，包括访问日志、错误日志和nginx主进程id号
- *_temp：存放运行过程中的**临时文件**



### 1.3 基本运行原理

- Master作为**主进程**，调度Worker子进程
- Worker**子进程响应用户请求**，根据**配置文件**寻找资源



## 2 配置与应用场景

### 2.1 最小配置

- **业务（worker）进程数**和**单业务进程可接受连接数**
- **http模块**
  - **mime类型**配置
  - **sendfile**配置
  - **keepalive_timeout**配置
  - **server模块**配置**虚拟主机**，包括端口号、域名/主机名、资源映射等



### 2.2 虚拟主机



### 2.3 反向代理与负载均衡
