---
title: go-gRPC
abbrlink: 8f298335
date: 2022-10-01 10:09:40
tags:
  - go
  - gRPC
---

## 1 微服务

> https://www.mszlu.com/grpc/01/01.html



## 2 protobuf

### 2.1 概述

protobuf是谷歌开源的一种数据格式，适合高性能，对响应速度有要求的数据传输场景。

profobuf是二进制数据格式，需要编码和解码，数据本身不具有可读性。因此只能**反序列化**之后得到真正可读的数据。

优势：

- 序列化后体积相比Json和XML很小，适合网络传输
- 支持跨平台多语言
- 消息格式升级和兼容性还不错
- 序列化反序列化速度很快

安装：

1. 下载通用编译器：https://github.com/protocolbuffers/protobuf/releases

   > 下这个`protoc-21.7-win64.zip`

2. 配置环境变量

   > 举例：`F:\ProgramFiles\protoc-21.7-win64\bin`

3. 安装go专用的protoc的生成器：

   `go install github.com/golang/protobuf/protoc-gen-go`

   `go install google.golang.org/grpc/cmd/protoc-gen-go-grpc`

   > 安装后会在`GOPATH\bin`目录下生成可执行文件`protoc-gen-go`和`protoc-gen-go-grpc`，执行`protoc`命令会自动调用这个插件

   > Goland中也要安装Protocol Buffers插件

生成文件：

- `protoc --go_out=./xxxDir --go-grpc_out=./xxxDir ./pbfile/xxx.proto`

  > 这个会生成两个文件，一个对应`message`，一个对应`service`
  >
  > 这样写的话服务端需要额外实现一个接口，生成的proto文件里已经提供了默认实现类：
  >
  > ```go
  > type grpcServer struct {
  > 	pb.UnimplementedXxxServer
  > }
  > ```

- `protoc --go_out=plugins=grpc:./ ./xxx.proto `

  > 这样只会生成一个文件



### 2.2 语法

*“头部”：*

```protobuf
// 指定的当前proto语法的版本，有2和3
syntax = "proto3";

// 从执行protoc命令的当前目录开始算起
import "pbfile/xxx.proto"

// option go_package = "path;name"; 
// path 表示生成的go文件的存放地址，会自动生成目录的，一般与package一致
// name 表示生成的go文件所属的包名，如果不配置就按下面的package生成
option go_package="../service";

// 指定go文件生成出来的package
package service;

```

---

*`message`：*

- 消息就是需要传输的**数据格式**的定义，通过`message`关键字指定

```protobuf
message {
	字段规则 字段类型 字段名 = 标识号
}
```

- **字段规则**：

  - `required`：消息体中**必填字段**，`proto3`中不需要显式写明`required`了
  - `optional`：消息体中**可选字段**，在go中会生成指针
  - `repeated`：消息体中**可重复字段**，在go中重复的会被定义为**切片**

- **标识号**：在消息体的定义中，每个字段都必须要有一个唯一的标识号，标识号是$[0,2^{29}-1]$范围内的一个整数。

- **字段映射类型**：

  | .proto Type |                            Notes                             |  Go Type  |
  | :---------: | :----------------------------------------------------------: | :-------: |
  |  `double`   |                                                              | `float64` |
  |   `float`   |                                                              | `float32` |
  |   `int32`   | 使用变长编码，对于负值的效率很低，如果可能有负值，请使用sint64替代 |  `int32`  |
  |   `int64`   |                                                              |  `int64`  |
  |   `bool`    |                                                              |  `bool`   |
  |  `string`   |    一个字符串必须是UTF-8编码或者7-bit ASCII编码的文 本。     | `string`  |
  |   `bytes`   |                 可能包含任意顺序的字节数据。                 | `[]byte`  |
  |  `uint32`   |                         使用变长编码                         | `uint32`  |
  |  `uint64`   |                         使用变长编码                         | `uint64`  |
  |   sint32    |        使用变长编码，这些编码在负值时比int32高效的多         |   int32   |
  |   sint64    |   使用变长编码，有符号的整型值。编码时比通常的int64高效。    |   int64   |
  |   fixed32   | 总是4个字节，如果数值总是比总是比128大的话，这个类型会比uint32高效。 |  uint32   |
  |   fixed64   | 总是8个字节，如果数值总是比总是比256大的话，这个类型会比uint64高效。 |  uint64   |
  |  sfixed32   |                         总是4个字节                          |   int32   |
  |  sfixed64   |                         总是8个字节                          |   int64   |

> `enum`类型：
>
> 和`message`一样定义在外面
>
> ```protobuf
> enum enumType {
> 	enumElement0 = 0
> 	enumElement1 = 1
> 	enumElement2 = 2
> 	...
> }
> ```
>
> 

> 默认值：
>
> |   类型   |                            默认值                            |
> | :------: | :----------------------------------------------------------: |
> |   bool   |                            false                             |
> |   整型   |                              0                               |
> |  string  |                          空字符串""                          |
> | 枚举enum | 第一个枚举元素的值，因为Protobuf3强制要求第一个枚举元素的值必须是0，所以枚举的默认值就是0； |
> | message  |                不是null，而是DEFAULT_INSTANCE                |

> `Any`类型：
>
> - `import "google/protobuf/any.proto";`
> - `google.protobuf.Any`
>
> …

- **嵌套消息**

  - `message`定义出来的消息本身也可以作为一种**字段类型**
  - 在外部引用嵌套消息类型可以用`.`

  ```protobuf
  message Father {
      message Son {
      } 
  	repeated Son info = 1;
  }
  message PersonMessage {
  	Father.Son info = 1;
  }
  ```

- go语言中消息的**序列化与反序列化**：（`[]byte`）

  ```go
  // service.User是protobuf message 生成的
  user := &service.User{
      Username: "mszlu",
      Age: 20,
  }
  // 序列化
  marshal, err := proto.Marshal(user)
  if err != nil {
      panic(err)
  }
  // 反序列化
  newUser := &service.User{}
  err = proto.Unmarshal(marshal, newUser)
  if err != nil {
      panic(err)
  }
  ```

---

*`service`：*

```protobuf
service SearchService {
	rpc 方法名([stream]参数消息类型) returns ([stream]返回值消息类型);
}
```

- 如果想要将**消息类型**用在RPC系统中，可以在.proto文件中定义一个RPC服务接口，在go语言中会生成`interface`，这就是要进行的**远程过程调用**

  > 注意这个参数和返回值类型**只能是`message`**，而且都**只能有一个**

- `stream`代表**流式**通信，即会有多次请求或响应，而不是一次直接结束，下文会具体讲

- protoc-gen后会生成比较复杂的**存根和方法**，具体用法见下文



## 3 通信

### 3.1 一元通信

*服务端：*

1. 实现服务逻辑

   - 找到生成的.pb.go文件的`XxxxServer`接口，在自定义go文件中实现这个接口中的rpc方法

2. 注册服务

   `rpcServer := grpc.NewServer()`

   > `grpc`是包名

   `xxxPackage.RegisterXxxxServer(rpcServer, &XxxImpl)`

   > `xxxPackage`是**自定义proto文件中指定的包名**

3. 启动服务：

   `listener, err := net.Listen("tcp", ":port")`

   `err := rpcServer.Serve(listener)`

---

*客户端：*

1. 新建连接

   `conn, err := grpc.Dial("ip:port", grpc.WithTransportCredentials(insecure.NewCredentials()))`

   > 第二个参数是安全证书

2. 生成客户端并调用存根

   `xxxClient := xxxPackage.NewXxxClient(conn)`

   `respMessage, err:= xxxClient.XxxMethod(context.Background(), &xxxPackage.XxxMessage)`

   > 这个`XxxMethod`就是在proto文件中定义的rpc方法，`XxxMessage`和`respMessage`就是在proto文件中定义的消息类型在go语言中的实例

3. 关闭连接：`defer conn.Close()`



### 3.2 流式通信

*`stream`概述：*

- 在 HTTP/1.1 的时代，同一个时刻只能对一个请求进行处理或者响应，换句话说，下一个请求必须要等当前请求处理完才能继续进行

  > HTTP/1.1需要注意的是，在服务端没有response的时候，客户端是可以发起多个request的，但服务端依旧是顺序对请求进行处理, 并按照收到请求的次序予以返回。

- HTTP/2 的时代，**多路复用**的特性让一次同时处理多个请求成为了现实，并且同一个 TCP 通道中的请求不分先后、不会阻塞

- HTTP/2 中引入了**流(Stream)和帧(Frame)**的概念，当 TCP 通道建立以后，后续的所有操作都是以**流**的方式发送的，而**二进制帧是组成流的最小单位**，属于协议层上的流式传输。

  > HTTP/2 在一个 TCP 连接的基础上虚拟出多个 Stream, Stream 之间可以并发的请求和处理, 并且 HTTP/2 以二进制帧 (frame) 的方式进行数据传送, 并引入了头部压缩 (HPACK), 大大提升了交互效率

---

*双向`stream`的服务端：*

1. 实现服务逻辑

   - 找到生成的.pb.go文件的`XxxxServer`接口，在自定义go文件中实现这个接口中的rpc方法，方法的参数对应了**流式参数类型**，一般类型名为：`xxxPackage.Xxx_XxxServer`
   - 接收请求：`for {recv, err := streamMessage.Recv()}`
     - `recv`就是**消息类型实例**
     - 当`err == io.EOF`时代表请求结束
   - 响应数据：`err := streamMessage.Send(&xxxPackage.XxxMessage{})`

2. 注册服务

   `rpcServer := grpc.NewServer()`

   > `grpc`是包名

   `xxxPackage.RegisterXxxxServer(rpcServer, &XxxImpl)`

   > `xxxPackage`是**自定义proto文件中指定的包名**

3. 启动服务：

   `listener, err := net.Listen("tcp", ":port")`

   `err := rpcServer.Serve(listener)`

---

*双向`stream`的客户端：*

1. 新建连接

   `conn, err := grpc.Dial("ip:port", grpc.WithTransportCredentials(insecure.NewCredentials()))`

   > 第二个参数是安全证书

2. 生成客户端并调用存根

   `xxxClient := xxxPackage.NewXxxClient(conn)`

   `reqStream, err := xxxClient.XxxMethod(context.Background())`

   > 这里返回的`reqStrem`对应了**流式参数类型**，一般类型名为：`xxxPackage.Xxx_XxxClient`

3. (开启协程)发送流式请求

   - 发送请求：`reqStream.Send(&xxxPackage.XxxMessage{})`
   - 处理响应：`recv, err := reqStream.Recv()`
     - `recv`就是**消息类型实例**
     - 当`err == io.EOF`时代表请求结束

4. 关闭连接：`defer conn.Close()`











## 4 安全传输



