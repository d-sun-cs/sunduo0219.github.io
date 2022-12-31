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

所谓热加载就是当我们对代码进行修改时，程序能够自动重新加载并执行，这在我们开发中是非常便利的，可以快速进行代码测试，省去了每次手动重新编译

在gin中我们要实现热加载可以借助**第三方工具**

- ` go install github.com/pilu/fresh@latest`

  `go get github.com/pilu/fresh`

  `fresh`

  >   https://github.com/gravityblast/fresh

-   `go get -u github.com/codegangsta/gin`

    `gin run main.go`

    >   https://github.com/codegangsta/gin



## 2 路由

### 2.1 路由概述

路由（Routing）是由一个 **<u>URI</u>**（或者叫路径）和一个特定的 **<u>HTTP 方法</u>**（GET、POST 等）组成的，涉及到应用如何**响应客户端**对某个网站节点的访问



### 2.2 路由配置

*获得路由：*

```go
r := gin.Default()
```

>   `github.com/gin-gonic/gin`包

*静态路由举例：* 

```go
r.HTTP方法("/路径", func(c *gin.Context) { 
  c.String(200, "HTTP方法")
})
```

>   可以使用`http.StatusOK`代替`200`

*动态路由举例：*

```go
r.GET("/user/:uid", func(c *gin.Context) { 
  uid := c.Param("uid") 
  c.String(200, "userID=%s", uid) 
})
```



### 2.3 响应数据

*响应字符串：*

-   `c.String(code int, format string, values ...any)`

```go
r.GET("/user/:uid", func(c *gin.Context) { 
  uid := c.Param("uid") 
  c.String(200, "userID=%s", uid) 
})
```

---

*响应JSON：*

-   构造`map`的方式：

    ```go
    r.GET("/someJSON", func(c *gin.Context) { // 方式一：自己拼接 JSON 
        c.JSON(http.StatusOK, map[string]interface{}{
            "message": "Hello world!"
        }) 
    })
    ```

    >   可以用自定义类型`gin.H`代替`map[string]interface{}`

-   构造`struct`的方式：

    ```go
    r.GET("/moreJSON", func(c *gin.Context) { // 方法二：使用结构体 
        var msg struct { 
            Name string `json:"user"` 
            Message string 
            Age int 
        }
        msg.Name = "IT 营学院" 
        msg.Message = "Hello world!" 
        msg.Age = 18 
        c.JSON(http.StatusOK, msg) 
    })
    ```

---

*响应JSONP：*

-   与JSON类似，不同的地方在于，请求路径中可以有`callback`参数，返回“**执行回调**”的形式

```go
r.GET("/JSONP", func(c *gin.Context) { 
    data := map[string]interface{}{ 
        "foo": "bar", 
    }
    // /JSONP?callback=xxx 
    // 将返回：xxx({\"foo\":\"bar\"}) 
    c.JSONP(http.StatusOK, data) 
})
```

-   如果是普通的JSON响应，则不会返回`xxx(JSONstr)`这种形式，只有一个`JSONstr`

---

*响应XML：*

-   与JSON用法几乎完全相同，就是api换成了`c.XML`

---

*渲染HTML模板：*

>   举例的渲染方法见下一节

-   首先可以执行`router.LoadHTMLGlob("templates/*") `加载所有模板

    >   这就需要在项目根目录下创建一个`templates`文件夹，里面存在`html`文件

-   `c.HTML(http.StatusOK, "xxx.html", gin.H{...服务器数据})`



### 2.4 路由传值

*GET传值：*

-   query参数（`?key=value&key=value`）：

    -   `c.Query("key")`
    -   `c.DefaultQuery("key", defaultValue string)`

-   动态路由传值/路径参数/param参数：`c.Param("key")`

    ```go
    // /path/:pathVariable
    r.GET("/user/:uid", func(c *gin.Context) { 
        uid := c.Param("uid") 
        c.String(200, "userID=%s", uid) 
    })
    ```

---

*POST传值：*

-   表单参数：`c.PostForm("key")`、`c.DefaultPostForm("key", defaultValue)`

---

*绑定到结构体：*

- 可以提取**JSON、form表单、QueryString类型**的参数到结构体中，key需要和结构体的字段对应

  ```go
  //注意首字母大写 
  type Userinfo struct { 
      Username string `form:"username" json:"user"` 
      Password string `form:"password" json:"password"` 
  }
  ```

  >   这里主要是`form`标签在起作用，`json`只是结构体转换成JSON后的key
  >
  >   > 无论是`form`还是`json`，结构体成员都要有公开访问权限

-   GET传值绑定到结构体：注意要传**地址**

    ```go
    router.GET("/", func(c *gin.Context) { 
        var userinfo Userinfo 
        if err := c.ShouldBind(&userinfo); err == nil { 
            c.JSON(http.StatusOK, userinfo) 
        } else { 
            c.JSON(http.StatusBadRequest, gin.H{
                "error": err.Error(),
            }) 
        } 
    })
    ```

-   POST传值绑定到结构体：用法相同

-   XML绑定到结构体：

    -   `bytesSlice, _ := c.GetRawData()`
    -   `xml.Unmarshal(bytesSlice, any)`

    ```go
    type Article struct { 
        Title string `xml:"title"` 
        Content string `xml:"content"` 
    }
    /*...*/
    router.POST("/xml", func(c *gin.Context) { 
        b, _ := c.GetRawData() // 从 c.Request.Body 读取请求数据
        article := &Article{} 
        if err := xml.Unmarshal(b, &article); err == nil { 
            c.JSON(http.StatusOK, article) 
        } else {
            c.JSON(http.StatusBadRequest, err.Error()) 
        } 
    })
    ```



### 2.5 路由分组

```
|-root
	|-main.go
	|-routers
		|-xxxRouter.go
		|-xxxxRouter.go
```

```go
// main.go
import ( 
    "gin_demo/routers"
    "github.com/gin-gonic/gin"
)
func main() {
	router := gin.Default()
    routers.AdminRoutesInit(router)
    routers.XxxRoutes(router)
    router.run(":port")
}
```

```go
// xxxRouter.go
package routers
/*...*/
func AdminRoutesInit(router *gin.Engine) { 
    adminRouter := router.Group("/admin") 
    { 
        adminRouter.GET("/user", func(c *gin.Context) { 
            c.String(http.StatusOK, "用户") 
        })
        adminRouter.GET("/news", func(c *gin.Context) { 
            c.String(http.StatusOK, "news") 
        }) 
    } 
}
```

-   路由分组的语法

    ```
    rGroup = router.Group("/xxxgroup")
    {
    	rGroup.HTTP方法(...)
    }
    ```

-   上面这种写法还不是最终版本，之后结合**控制器**会再改动

    

## 3 HTML模板渲染



## 4 控制器、中间件

### 4.1 控制器

*控制器架构：*

```
|- root
	|- main.go
	|- routers
	|- controllers
		|- controlerDir1
			|- xxxController.go
        |- controlerDir2
			|- xxxxController.go
```

```go
// xxxRouter.go
package routers

import (
	"gin_demo/controllers/xxx"
    // ...
)
/*...*/
func AdminRoutesInit(router *gin.Engine) { 
    adminRouter := router.Group("/admin") 
    { 
        adminRouter.GET("/user", xxx.UserMethod)
        adminRouter.GET("/news", xxx.NewsMethod) 
    } 
}
```

```go
// xxxController.go
package xxx
/*...*/
func UserMethod(c *gin.Context) { 
    c.String(http.StatusOK, "用户") 
}

func NewsMethod(c *gin.Context) { 
    c.String(http.StatusOK, "news") 
}
```

-   其实没有什么特殊的语法，就是把原来的匿名函数划分到不同的`controller`文件中了

---

*控制器继承：*

-   就是把函数挂载到**结构体的方法**上

```go
// xxxBaseController.go
package admin 

import (
    "net/http" "github.com/gin-gonic/gin" 
)

type BaseController struct {}

func (c BaseController) Success(ctx *gin.Context) { 
    ctx.String(http.StatusOK, "成功") 
}

func (c BaseController) Error(ctx *gin.Context) { 
    ctx.String(http.StatusOK, "失败") 
}
```

```go
// xxxController.go
package xxx
/*...*/
type UserController struct{
    // 继承的结构体controller
    BaseController
}

func (ucon UserController) User(c *gin.Context) { 
    if xxx {
	    c.String(http.StatusOK, "用户")    
    } else {
        ucon.Error(c)
    }
}

func (ucon UserController) News(c *gin.Context) { 
    c.String(http.StatusOK, "news") 
}
```

```go
// xxxRouter.go
package routers

import (
	"gin_demo/controllers/xxx"
    // ...
)
/*...*/
func AdminRoutesInit(router *gin.Engine) { 
    adminRouter := router.Group("/admin") 
    { 
        adminRouter.GET("/user", xxx.UserController{}.User)
        adminRouter.GET("/news", xxx.UserController{}.News) 
    } 
}
```

-   这样路由就只负责配置请求的路径关系，业务逻辑都由控制器处理



### 4.2 中间件

*中间件概述：*

-   Gin 框架允许开发者在处理请求的过程中，加入用户自己的钩子（Hook）函数。这个钩子函数就叫中间件

    >   中间件适合处理一些公共的业务逻辑，比如登录认证、权限校验、数据分页、记录日志、耗时统计等

-   通俗的讲：中间件就是**请求处理前后（但都是<u>正式响应之前</u>）**执行的一系列操作

    >   有点像**切面AOP**

---

*路由中间件：*

-   在路由函数中加入多个回调函数，最后一个回调函数用于处理请求并响应，前面的回调函数都是**中间件**

    >   例如GET方法：
    >
    >   ```go
    >   func (group *RouterGroup) GET(relativePath string, handlers ...HandlerFunc) IRoutes {...}
    >   ```

-   在中间件中，可以调用`c.Next()`，直接去执行下一个处理程序，

    -   它可能是**下一个中间件**，即**中间件**会按照在路由函数中注册的顺序**依次执行**
    -   也可能**就是最后一个回调函数**，即对**请求的处理**（但<u>没有正式响应</u>），然后再回到中间件执行`c.Next()`后的语句

    >   也就是在**处理请求的业务逻辑前后**分别执行语句，然后再返回
    >
    >   如果没有`c.Next()`，则会在执行完中间件中的所有语句后再响应请求

-   在中间件中，也可以调用`c.Abort()`，说明直接不再执行后续的中间件和业务逻辑处理请求，返回空。但同一中间件中`c.Abort()`后的语句会正常执行。

```go
//main.go
func initMiddleware1(ctx *gin.Context) { 
    fmt.Println("中间件1---before request process") 
    ctx.Next()
    fmt.Println("中间件1---after request process") 
}

func initMiddleware2(ctx *gin.Context) { 
    fmt.Println("中间件2---before request process") 
    ctx.Next()
    // ctx.Abort()
    fmt.Println("中间件2---after request process") 
}

func main() { 
    r := gin.Default() 
    r.GET("/", initMiddleware1, initMiddleware2, func(ctx *gin.Context) { 
        ctx.String(200, "首页--中间件演示") 
    })
    r.GET("/news", initMiddleware1, func(ctx *gin.Context) { 
        ctx.String(200, "新闻页面--中间件演示") 
    })
    r.Run(":8080") 
}
```

---

*全局中间件：*

- 上面讲的路由中间件是针对**单独一个路由**的，可以理解成不是全局的
- **全局中间件的注册**方法：`r.Use(middleWare1, middleWare2, ...)`
  - 这样在匹配所有路由时都会执行

---

*路由分组中间件：*

- 方式一：`r.Group("/path", middleWare1, middleWare2)`
- 方式二：`groupRouter.Use(middleWare1, middleWare2)`

---

*中间件、控制器数据共享：*

- 设置值：`ctx.Set("key", "value")`
- 获取值：`ctx.Get("key", "value")`

…



## 5 Cookie 与 Session

…





## 6 Gin 连接 MySQL







