---
title: gin
abbrlink: acec9806
date: 2022-09-29 16:17:03
tags:
  - golang
  - gin
---

## 1 快速入门

### 1.1 概述

> https://gin-gonic.com/zh-cn/

Gin是一个Go(Golang)编写的轻量级http web框架，运行速度非常快。

Gin最擅长的就是**Api接口的高并发**，如果项目的规模不大，业务相对简单，推荐使用Gin

当某个接口的性能遭到较大挑战的时候，这个还是可以考虑**使用Gin重写接口**

### 1.2 环境搭建

根据官网文档引入gin包

> 可能需要提前创建项目才能`go get`

```go
package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	// 创建默认的路由引擎
	r := gin.Default()
	// 配置路由
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	// 监听并在 0.0.0.0:8000 上启动服务
	r.Run(":8000")
}
```

### 1.3 热加载

