---
title: golang
date: 2022-09-28 09:45:40
category: 学习资源
tags:
  - 计算机
  - go
---

## 1 概述

### 1.1 安装

下载地址：

- go官网：https://golang.org/dl/
- go官方镜像：https://golang.google.cn/dl/

终端命令：

- go verion

- 查看go环境：go env

  > Go1.11版本之后无需手动配置环境变量

go语言项目：

- 使用go mod管理项目，可以在你磁盘的任何位置新建一个项目。

  > 不需要非得把项目放到GOPATH指定目录下，Go1.13以后可以彻底不要GOPATH了

### 1.2 快速入门

```go
package main // 定义包

import "fmt" // import 引入fmt包

func main(){ // 与包同名，为入口函数
    fmt.Println("Hello, World!")
} 
```

代码编写：

- 语句结尾**不需要加分号**
- 通过换行区分语句，**不同语句不能写在同一行**
- 定义变量：`var i = "xxx"`
  - 在go语言中变量**定义后必须使用**，不然报错

fmt包的常用方法：

- `fmt.Println("xxx", "yyy", "...")`：输出若干个字符串，**中间用空格连接**，并在最后**换行**
- `fmt.Print("xxx", "yyy", "...")`：**连接**并输出若干个字符串
- `fmt.Printf("format string", format, ...)`：格式化输出
  - `%v`：自动推导类型

注释：

- 单行注释：`//`
- 多行注释：`/* */`

## 2 基础语法

### 2.1 数据类型





### 

