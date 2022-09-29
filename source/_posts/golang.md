---
title: golang
category: 学习资源
tags:
  - 计算机
  - go
  - golang
abbrlink: af1c25a3
date: 2022-09-28 09:45:40
---

## 1 快速入门

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



### 1.2 基础代码编写

```go
package main // 定义包

import "fmt" // import 引入fmt包

func main(){ // 与包同名，为入口函数
    fmt.Println("Hello, World!")
} 
```

> - 语句结尾**不需要加分号**
> - 通过换行区分语句，**不同语句不能写在同一行**
> - 格式化代码：go文件会在保存后自动格式化

*`fmt`包的常用方法*：

- `fmt.Println("xxx", "yyy", ...)`：输出若干个字符串，**中间用一个空格连接**，并在最后**换行**
- `fmt.Print("xxx", "yyy", ...)`：**连接**并输出若干个字符串
- `fmt.Printf("format string", format, ...)`：格式化输出
  - `%v`：**数据值**
  - `%d`：整型**数据**
  - `%T`：输出**数据类型**

*声明和定义变量*：

> 在go语言中<u>变量</u>**定义后必须使用**，不然报错；

- :star:`var 变量名 [类型] = 表达式`

  - `类型`可以省略，自动推导；但声明时如果不赋值，则**必须指定类型**

  - 一行声明或定义多个变量：

    - 可以一行**声明或定义**<u>同类型</u>的多个变量：`var id1, id2 type = exp1, exp2`

    - 一行**定义**类型可以不一致的多个变量：`var id1, id2 = exp1, exp2`
    
  - 批量**声明或定义**<u>类型可以不一致</u>的变量

    ```go
    var (
        变量名 [类型] = 表达式
        变量名 类型
        id1, id2 [类型] = exp1, exp1
        id1, id2 类型
    )
    ```
  
    > `类型`可以省略，自动推导，但声明时如果不赋值，则**必须指定类型**
  
- :star:`变量名1, 变量名2, 变量名3 := 表达式1, 表达式2, 表达式3`

  > 这叫作“短变量声明法”；
  >
  > 类型自动推导，且多个变量同时定义时<u>类型可以不一致</u>
  >
  > 短变量只能用于定义**局部变量**，不能用于全局变量的定义；
  >
  > > 这是因为，函数外的每个语句都必须以关键字开始（var、const、func 等）

  > **<u>匿名变量</u>**：多重赋值时忽略某个值，占位
  >
  > `_, xxx = foo(...)`
  >
  > > 匿名变量不占用**命名空间**，不会**分配内存**，所以匿名变量之间不存在重复声明

*定义常量*：

> 和`var`的用法基本一致，不再赘述相同的部分（当然常量中没有“短变量声明法”）

- `const 变量名 [类型] = 表达式`

  > 常量必须在声明的同时**赋值**

- 一行定义多个常量（与变量用法一致）

- 批量定义常量：

  ```go
  const (
  	常量名 [类型] = 表达式
      常量名 [类型]
      常量名1, 常量名2 = exp1, exp2
      常量名1, 常量名2 [类型]
  )
  ```

  > const 同时声明多个常量时，如果**省略**了值则表示和**上面一行中同一列的值**相同，所以这样也必须保证**<u>列对齐</u>**（变量就不能这样省略）

  > 常量计数器`iota`：在批量定义常量时自动累加
  >
  > - 每次`const`出现时，都会让iota初始化为0，然后自增长
  > - `iota`的值可以跳过
  > - 也可以在同一行中使用`iota`
  >
  > ```go
  > const a = iota // a=0
  > const (
  >     b = iota //b=0
  >     c //c=1
  >     d //2
  >     e = iota //3
  >     f = 100
  >     g = iota //5
  >     h, i = iota, iota //6, 6
  > )
  > ```

*注释*：

- 单行注释：`//`
- 多行注释：`/* */`



## 2 基础语法

### 2.1 基本数据类型

*整型*：

- 有符号整型：

  `int8 int16 int32 int64`

- 无符号整型：

  `uint8 uint16 uint32 uint64`

  > 赋值时不能是**负数**

- 特殊规定的整型：

  - `int`：32 位操作系统上就是`int32`，64 位操作系统上就是`int64`。这也是根据字面量**自动推导**出来的类型
  - `uint`：32 位操作系统上就是`uint32`，64 位操作系统上就是`uint64`
  - `uintptr`：无符号整型，用于存放一个**指针**

  > 实际项目中整数类型、切片、`map`的元素数量等都可以用int 来表示。在涉及到二进制传输、为了保持文件的结构不会受到不同编译目标平台字节长度的影响，不要使用`int`和`uint`

  > `unsafe.Sizeof(var)`是`unsafe`包的一个函数，可以返回整型变量占用的**字节数**

- 不同长度类型的转换：`int8(numVar) int32(numVar) int(numVar)`

  - 长度向更短转换时会**截断取低位**

- 数字字面量

  - 二进制：`0b11010`，`%b`
  - 八进制：`0o521`,`%o`
  - 十进制：`996`，`%d`
  - 十六进制：`0xc9`，`%x`

  > `%v`是自动推导的输出

---

*浮点型*：

> IEEE754

- `float32 float64`
- `float`：32 位操作系统上就是`float32`，64 位操作系统上就是`float64`。这也是根据字面量**自动推导**出来的类型
- 格式化输出
  - `%v`
  - `%f`：默认保留6位小数。`%.2f`为保留两位小数
- 科学计数法：`3.14e2`、`3.14E3`、`3.14e-4`、`0.0314E-5`
- 精度丢失问题
  - 可以使用第三方包解决：https://github.com/shopspring/decimal
- 类型转换
  - `float64(numVar) float32(numVar)`
  - `float`和`int`也可以互相转换，截取至整数位，其他同理

---

*布尔型*：

- `bool`，只有`true`和`false`两个值
  - 布尔类型变量的默认值为`false`
  - 布尔型无法参与**数值运算**，也无法与其他**类型**进行转换
  - 格式化输出为`%t`，就是字符串`“true”`或者`“false”`

---

*字符串*：

- `string`，`“xxx”`

  - Go语言中的字符串以**原生数据类型**出现
  - Go语言里的字符串的内部实现使用**UTF-8编码**

- 转义符

  | 转义符 | 换行符 |
  | ------ | ------ |
  | `\r`   | 回车   |
  | `\n`   | 换行符 |
  | `\t`   | 制表符 |
  | `\'`   | 单引号 |
  | `\"`   | 双引号 |
  | `\\`   | 反斜杠 |

- 多行字符串：使用反引号``

  - 反引号间换行将被作为字符串中的换行，但是所有的转义字符均无效，文本将会**原样输出**。

- 常用操作

  - `len(str)`

    > 注意一个utf8汉字占用三个字节；
    >
    > 不能用`unsafe.Sizeof`看字符串的长度，没有意义的

  - 拼接字符串：

    - `+`：两边的数据类型都必须是**字符串**
    - `fmt.Sprint("xxx", yyy, ...)`系列，会直接返回结果，而不是输出到控制台，所以可以用来拼接字符串

  - **分割**字符串：`strings.Split(s, sep string)`，根据`sep`将`s`拆分成切片

    > 需要引入`strings`包

  - **合并**字符串：`strings.Join(elems []string, sep string)`，用`sep`将`elems`切片合并成字符串

  - 子串

    - 子串出现的位置：

      `strings.Index(s, substr string)`

      `strings.LastIndex(s, substr string)`

    - 是否包含子串：`strings.contains(s, substr string)`

    - 是否有**前后缀**：

      `strings.HasPrefix(s, prefix string)`

      `strings.HasSuffix(s, suffix string)`

  - 转换为字符串：`string(var)`

---

***字符**与字符串*：

- 本质是`int`类型，`%v`输出时为ASCII码值或utf8编码值，`%c`输出为字符原样
- `uint6`/`byte`类型：代表了ASCII码的一个字符，<u>ASCII码表中有</u>的**字符**默认用这种类型
- `rune`/`int32`类型：代表一个UTF-8字符，<u>ASCII码表中没有</u>的**字符**默认用这种类型
- 遍历字符串：
  - `for i`：以`byte`类型遍历字符串，字符串可以直接用下标索引访问`str[i]`，但不能修改（can not assign）
  - `for range`：以`rune`类型遍历字符串
- 修改字符串：转换成切片，用下标索引的方式修改，再用`string(arr)`转换回来
  - 只有ASCII码表中的字符的字符串：转换为`[]byte(str)`
  - 含有ASCII码表以外字符的字符串：转换为`[]rune(str)`

---

*基本数据类型转换*：

- Go语言中只有**强制类型转换**，没有隐式类型转换；类型不一致的数据无法进行基本运算

- 数值型的转换：`int()`、`float()`

- 字符串与其他类型的转换：

  - `fmt.Sprint`系列

  - `strconv`包

    - `strconf.FormatInt(i int64, base int)`

      > 注意必须是`int64`类型，`int`类型都不可以；`base`表示的是进制

    - `strconf.FormatInt(f float64, fmt byte, prec int, bitSize int)`

      > 参数1：要转换的值
      >
      > 参数2：格式化类型，'f'（-ddd.dddd）、'b'（-ddddp±ddd，指数为二进制）、'e'（-d.dddde±dd，十进制指数）、'E'（-d.ddddE±dd，十进制指数）、'g'（指数很大时用'e'格式，否则'f'格式）、'G'（指数很大时用'E'格式，否则'f'格式）。
      >
      > 参数3：保留的小数点个数，-1表示不对小数点格式化
      >
      > 参数4：格式化的类型：64或者32

    - `intVar, err := strconv.ParseInt(s string, base int, bitSize int)`

      > 转换失败返回0；`err`代表转换失败，可以用`_`忽略

    - `floatVal, err := strconv.ParseFloat(s string, bitSize int)`



### 2.2 运算符

*算术运算符*：

| 运算符 | 描述 |
| :----: | :--: |
|   +    | 相加 |
|   -    | 相减 |
|   *    | 相乘 |
|   /    | 相除 |
|   %    | 取余 |

- `++`和`--`在Go中代表一条独立的语句，必须放在变量后面，只能独立使用，不能和其他运算符和语句一起用
- 注意数据类型必须完全一致才能运算，`int64`和`int32`都不能一起运算
- 对于除法，如果操作数都是整数，则结果为整数（截断小数部分）

*关系运算符*：

| 运算符 |             描述             |
| :----: | :--------------------------: |
|   ==   |      检查两个值是否相等      |
|   !=   |     检查两个值是否不相等     |
|   >    |   检查左边值是否大于右边值   |
|   >=   | 检查左边值是否大于等于右边值 |
|   <    |   检查左边值是否小于右边值   |
|   <=   | 检查左边值是否小于等于右边值 |

*逻辑运算符*：

| 运算符 |     描述      |
| :----: | :-----------: |
|   &&   | 逻辑AND运算符 |
|  \|\|  | 逻辑OR运算符  |
|   !    | 逻辑NOT运算符 |

- 逻辑运算符具有短路性质

*赋值运算符*：

| 运算符 |                      描述                      |
| :----: | :--------------------------------------------: |
|   =    | 简单的赋值运算符，将一个表达式的值赋给一个左值 |
|   +=   |                  相加后再赋值                  |
|   -=   |                  相减后再赋值                  |
|   *=   |                  相乘后再赋值                  |
|   /=   |                  相除后再赋值                  |
|   %=   |                  求余后再赋值                  |

位运算：

| 运算符 |                描述                |
| :----: | :--------------------------------: |
|   &    |  参与运算的两数各对应的二进位相与  |
|   \|   |  参与运算的两数各对应的二进位相或  |
|   ^    | 参与运算的两数各对应的二进位相异或 |
|   <<   |              左移n位               |
|   >>   |            算术右移n位             |



### 2.3 流程控制

*`if`条件判断*：

```go
if exp1 {
    stmt1
} else if exp2 {
    stmt2
} else {
    stmt3
}
```

- Go语言规定与`if`匹配的左括号`{`必须与`if` 和表达式放在同一行，`{`放在其他位置会触发编译错误。同理，与`else`匹配的`{`也必须与`else`写在同一行，`else`也必须与上一个`if`或`else if`右边的大括号在同一行。而且`if..else`的大括号**都不能省略**，无论其中是否只有一条语句。

- 特殊写法：`if :=assginStmt; exp {...}`

  >也就是说，可以在`if`表达式之前添加一个赋值语句，再根据变量值进行判断；注意必须是`:=`赋值，`var`和其他语句都不行
  >
  >在这种情况下，`stmt`会位于**`if…else…`内部的作用域**

---

*`for`循环*：

```go
[:=assginStmt]
for [:=assginStmt]; exp; eachEndStmt {
    stmt
}
```

- 初始化赋值语句可以写在`for`外面，然后**第一个分号**前空着

- 注意：Go语言中是没有`while`语句的，我们可以通过`for`代替

  ```go
  for exp {
      stmt
  }
  ```

- 无限循环

  ```go
  for {
      stmt
  }
  ```

---

*`for range`键值循环：*

```go
for key, val := range enumerate {
    
}
```

- 数组、切片、字符串返回**索引和值**
- `map`返回**键和值**
- 通道（`channel`）只返回**通道内的值**

---

*`switch case`*：

```go
switch [:=assginStmt; ]var_ {
case val1, val2:
    stmt
    [break]
case val3, val33, val333:
    stmt
case val4:
    stmt
    [fallthrough]
default:
    stmt
}
```

- Go语言中每个`case`语句中可以不写`break`，不会出现穿透的现象。如果想要穿透，可以在一个`case`的末尾加上一行`fallthrough`，穿透一层

- `case`分支上还可以使用表达式，表达式和值可以混用？？：

  ```go
  switch {
  case exp1:
      stmt
  case exp2:
      stmt
  default:
      stmt
  }
  ```

  - 此时`switch`后不需要接标识符

---

*`break continue goto`*：

- `break`：

  - 用于循环语句中**跳出<u>当前</u>整个循环**

  - 在**多重循环**中，可以用标号`label`标出想`break`的循环：`break label`

    > 在语句的前一行左顶格加上一行`labelName:`即可用给该语句打上标签

- `continue`：只在`for`循环中使用，结束本次循环，开始下一次循环，也可以`continue label`

- `goto`：语句通过`label`进行代码间的**无条件跳转**



## 3 数组、切片、map

### 3.1 数组

*数组的声明和定义*：

- 声明数组，元素为默认值：`var arr [len]type`

  - `type`：数组中元素**数据类型**

  - `len`：数组**长度**

    > 长度不同，类型也不同；

- 定义数组：

  - `var arr = [len][type]{elem1, elem2, others}`

  - `arr := [len][type]{elem1, elem2, others}`

  - `arr := [len][type]{idx1: elem1, idx2: elem2, idx3: elem3, others}`

    > 指定索引，中间未指明的是默认值

  > 数组长度可以自动推断：`var arr = [...]type{elems}`，这个`...`就是**三个点的语法**

*访问数组*：

- 格式化输出：`%v`

- 获取或修改数组元素：`arr[idx]`

- 获得数组长度：`len(arr)`

- 遍历：

  - `for i := 0; i < len(arr); i++ {...}`
  - `for idx, val := range arr {...}`

- **数组名不是引用**，数组互相赋值时会直接复制一个新数组

  > Go中**基本数据类型和<u>数组</u>**都是值类型

*多维数组*：

- `var arr [len1][len2]type`

- `var arr = [len1][len2]type{{...},{...},...}`

  > 长度自动推导：`var arr = [...][len2]type{{...},{...},...}`
  >
  > > 注意，如果是二维数组，第二个维度的长度不能省略

### 3.2 切片

- 切片是有**相同类型**元素的**可变长**序列
- 引用数据类型
- 切片的本质是对底层数组的封装，包括底层数组的指针、切片的长度、切片的容量

*切片声明与定义*：

- 声明：`var slc []type`

  > 切片默认值为`nil`

- 定义：

  - `var slc = []type{elems}`

  - `var slc = []type{idx1: elem1, idx2: elem2, idx3: elem3, others}`

  - :star:基于数组定义切片：`arr[startIdx:endIdxExclude]`

    > `startIdx`、`startIdx:endIdxExclude`可以省略，代表取到头

  - 基于切片定义切片：类似

  - 基于字符串定义切片：`[]byte(str)`和`[]rune(str)`

    > 前面字符串的部分讲过

  - :star:`make([]T, size, cap)`函数创建切片
  
    - `size`：元素个数
    - `cap`：底层数组容量
  

*访问切片*：

- 输出、访问元素、遍历与数组类似
- 切片长度/元素个数：`len(slc)`
- 切片容量/**<u>切片第一个</u>元素**到**底层数组元素<u>末尾</u>**的元素个数：`cap(slc)`

*切片扩容*：

> Go中不能通过下标给切片扩容

- 追加元素：`append(slc, newElems)`

- 合并切片：`append(slc, anotherSlc...)`

  > 这个`...`是三个点的语法

- 切片扩容策略：有较为复杂的策略

- 切片删除元素：Go中没有专门删除切片元素的api，可以用`append`自己构造

*切片复制*：

- `copy(dst []Type, src []Type)`

---

***`sort`包**数组切片排序*

- 升序排序

  - `sort.Ints(arrOrSlc)`
  - `sort.Float64s(arrOrSlc)`
  - `sort.Strings(arrOrSlc)`

- 降序排序

  > 使用`sort.Reverse(arrOrSlc)` 来调换`slice.Interface.Less `,也就是比较函数

  - `sort.Sort(sort.Reverse(sort.IntSlice(intList)))`
  - `sort.Sort(sort.Reverse(sort.Float64Slice(floatList)))`
  - `sort.Sort(sort.Reverse(sort.StringSlice(stringList)))`

### 3.3 map

`map `是一种无序的基于`key-value`的数据结构，Go语言中的`map`是**引用类型**

*`map`创建*：

- `make(map[keyType]valueType)`

  > 后面可以再跟一个参数代表**长度**；`map`默认值为`nil`

- `var mp = map[keyType]valueType{key1:value1, key2:value2, key3:value3,}`

*`map`访问：*

- 格式化输出：`%v`

- 获取值、添加/修改键值对：`mp[key]`、`mp[key] = value`

- 循环遍历：`for key, value := range mp {...}`

- 查找键是否存在并尝试获取值：`value, isExist := mp[key]`

  - 如果不存在，`value`为默认值，`isExist`为`false`
  - 如果存在，`value`为`key`对应值，`isExist`为`true`

- 删除键值对：`delete(mp, key)`


*`map`与切片：*

- 元素为`map`类型的切片：
  - `make([]map[keyType]valueType, size, cap)`
- 值为切片类型的`map`
  - `make(map[keyType][]valueType)`



## 4 函数、指针、结构体

### 4.1 函数

*定义函数*：

```go
func 函数名(参数列表)(返回值列表) {
    函数体
}
```

- 参数列表：`argName argType, argName argType, ...`

  - 如果所有参数的类型都相同：`arg1, arg2, arg3 sameType`

  - 如果是**可变参数**，则必须是参数列表的最后一个，且只能有一个：`variableArg ...type`

    > 本质是用一个**切片**接收

- 返回值列表：`retType, retType, ...`

  - 如果只有一个返回值可以不要**括号**

  - 返回值命名：`retName retType, retName retType`

    > 相同类型也可以`ret1, ret2, ret3 sameType`

    - 相当于已经**声明**好了，可以直接在函数体内使用
    - 返回的时候一行`return`就够了，其他的不用加
    - 命名与不命名不要混用

*变量/常量的作用域：*

- 全局变量：全局变量是定义在**函数外部**的变量，它在**程序整个运行周期内**都有效。在函数中可以访问到全局变量
- 局部变量：局部变量是**函数内部**定义的变量， 函数内定义的变量无法在该函数外使用
  - 如果局部变量和全局变量重名，**优先访问局部变量**
  - **语句块中定义的变量**也只在该语句块中生效（块作用域）

*自定义类型与变量：*

- 自定义函数类型：`type 函数类型名 func(参数列表)(返回值列表)`

- 自定义函数类型变量的使用：

  ```go
  type calculation func(int, int) int
  func add(x, y int) int {
      return x + y
  }
  func sub(x, y int) int {
      return x - y
  }
  func main() {
      var c calculation // 声明一个calculation 类型的变量c
      c = add // 把add 赋值给c
      fmt.Printf("type of c:%T\n", c) // type of c:main.calculation
      f := sub // 将函数add 赋值给变量f1
      fmt.Printf("type of f:%T\n", f) // type of f:func(int, int) int
  }
  ```

  - 注意，**自定义**函数类型和类型**自动推导**的函数类型是不完全一样的

- 自定义数据类型：`type 数据类型名 基本数据类型名`

*函数作为参数和返回值：*





### 4.2 指针



### 4.3 结构体



## 5 包与接口

### 5.1 包



### 5.2 接口



## 6 goroutine













