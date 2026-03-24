# ⚙️ The Time Machine Proxy — Sprint 2: محرك الـ C++
> "أي أداة كافية لـ 1000 request. بس لما تيجي 50,000 — بتبدأ تعيش في الـ kernel."

---

# 📌 فهرس Sprint 2

1. [ليه C++ وليه دلوقتي؟ — المنطق قبل الكود](#1-ليه-c-وليه-دلوقتي-المنطق-قبل-الكود)
2. [C++ من الصفر — للـ Node.js Developer](#2-c-من-الصفر-للـ-nodejs-developer)
3. [TCP vs HTTP — الفرق الحقيقي](#3-tcp-vs-http-الفرق-الحقيقي)
4. [Phase 1 — بنبني أول TCP Server في C++](#4-phase-1-بنبني-أول-tcp-server-في-c)
5. [المشكلة — Thread-per-Connection والكارثة](#5-المشكلة-thread-per-connection-والكارثة)
6. [Deep Dive: الـ epoll — عيون الـ Kernel](#6-deep-dive-الـ-epoll-عيون-الـ-kernel)
7. [Phase 2 — TCP Server بـ epoll (Non-Blocking)](#7-phase-2-tcp-server-بـ-epoll-non-blocking)
8. [Deep Dive: الـ mmap — الذاكرة اللي بتكتب نفسها](#8-deep-dive-الـ-mmap-الذاكرة-اللي-بتكتب-نفسها)
9. [Phase 3 — الـ C++ Engine الكامل مع mmap](#9-phase-3-الـ-c-engine-الكامل-مع-mmap)
10. [بناء الـ Project وربطه بـ Node.js](#10-بناء-الـ-project-وربطه-بـ-nodejs)
11. [✅ Sprint 2 Checkpoint الشامل](#11-sprint-2-checkpoint-الشامل)
12. [ملخص Sprint 2 وما جاي](#12-ملخص-sprint-2-وما-جاي)

---

# 1. ليه C++ وليه دلوقتي؟ — المنطق قبل الكود

## مراجعة سريعة — المشكلة اللي توصّلنا ليها في Sprint 1

في Sprint 1 اكتشفنا إن Node.js عنده حاجة بتوجعنا لما بنيجي نكتب الـ Shadow Traffic على disk بسرعة عالية:

```
الـ Problem Stack:
─────────────────────────────────────────
writeFileSync       → يوقف الـ Event Loop كلياً ❌
writeFile (async)   → محدود بـ libuv Thread Pool (4 threads default) ❌
Worker Threads      → ~2MB/thread × 50k = 100GB RAM ❌
─────────────────────────────────────────
الحل المطلوب: نكتب على disk من غير أي thread، من غير أي blocking
```

الحل اسمه **`mmap`** — system call في Linux بيخلي الـ Kernel نفسه مسؤول عن الكتابة. وعشان نستدعي `mmap` مباشرة، محتاجين لغة بتتعامل مع الـ OS مباشرة — وده بالظبط C++.

## ليه مش C؟

C ممتازة وأسرع في بعض الحالات. بس C++ بتديك:
- **Classes** — بتنظّم الكود في الـ server بتاعنا (Connection class، Buffer class)
- **RAII** — Resource Acquisition Is Initialization — بيتأكد إن الـ memory والـ file descriptors بتتحرر تلقائياً حتى لو حصل error
- **STL** — containers جاهزة زي `std::vector` و`std::unordered_map` محتاجينها للـ connection management
- **بدون GC** — مفيش Garbage Collector، مفيش pause

---

# 2. C++ من الصفر — للـ Node.js Developer

## الفرق الجوهري في الـ Mental Model

لما بتكتب JavaScript، في "engine" بينك وبين الـ machine بيتكلم بدالك:

```mermaid
graph TD
    subgraph JS ["JavaScript World"]
        JSC["كودك"]
        V8["V8 Engine"]
        UV["libuv"]
        OS1["OS / Kernel"]
        JSC --> V8 --> UV --> OS1
    end

    subgraph CPP ["C++ World"]
        CPPC["كودك"]
        OS2["OS / Kernel"]
        CPPC -->|"system calls مباشرة"| OS2
    end

    style JS fill:#1a365d,color:#fff
    style CPP fill:#1c4532,color:#fff
```

في C++، أنت والـ OS وجهاً لوجه. مفيش وسيط.

## أساسيات C++ اللي هتحتاجها — مقارنة بـ JavaScript

### المتغيرات والـ Types

```cpp
// JavaScript — dynamic typing
let name = "Ahmed";        // ممكن تحولها لرقم بعدين
let count = 42;
let price = 99.5;

// C++ — static typing (لازم تحدد النوع من الأول)
std::string name = "Ahmed";  // string — ثابت النوع
int count = 42;              // integer — 4 bytes
double price = 99.5;         // floating point — 8 bytes
```

### الـ Functions

```cpp
// JavaScript
function add(a, b) {
    return a + b;
}

// C++ — لازم تحدد نوع الـ return وكل parameter
int add(int a, int b) {
    return a + b;
}

// لو الـ function مش بترجع حاجة
void logMessage(std::string msg) {
    std::cout << msg << std::endl;
}
```

### الـ Classes

```cpp
// JavaScript class
class Connection {
    constructor(socket, id) {
        this.socket = socket;
        this.id = id;
        this.buffer = "";
    }

    send(data) {
        // ...
    }
}

// C++ class — نفس الفكرة، syntax مختلف
class Connection {
public:
    // Constructor — زي الـ constructor في JS
    Connection(int socket_fd, int id)
        : socket_fd_(socket_fd), id_(id) {
        // initializer list — أسرع من التحيّل في الـ body
    }

    // Destructor — اللي مفيش مثيله في JS!
    // بيتشغل تلقائياً لما الـ object بيتدمّر
    ~Connection() {
        close(socket_fd_); // بنأكد إن الـ socket بيتقفل
    }

    void send(const std::string& data);

private:
    int socket_fd_;
    int id_;
    std::string buffer_;
};
```

> [!INFO]
> ## الـ Destructor — أهم فرق بين C++ وكل اللغات التانية
>
> في JavaScript، لما object ميبقاش عنده references، الـ GC بيحذفه في وقت مجهول.
>
> في C++، **الـ Destructor بيتشغل بالظبط** في اللحظة اللي الـ object بيخرج من الـ scope.
>
> ```cpp
> void handleConnection(int fd) {
>     Connection conn(fd, 1);  // Constructor اتشغّل
>     // ... شغّل على الـ connection
>     // بمجرد ما الـ function بتخلص...
>     // Destructor بيتشغل تلقائياً → close(fd_) بيتنفذ
> }
> // مفيش memory leak، مفيش open file descriptor
> ```
>
> ده اللي بيسموه **RAII** — وهو سلاح C++ الرئيسي ضد الـ resource leaks.

### الـ Pointers والـ References — مش هنخوض فيهم كتير

```cpp
// Reference — زي alias للمتغير الأصلي
// الـ & في الـ parameter يعني "مش هنعمل copy"
void processData(const std::string& data) {  // & = reference
    // data هنا بيشاور على نفس الـ string في الـ memory
    // مش copy منها — أسرع وأوفر memory
}

// Pointer — عنوان في الـ memory
int value = 42;
int* ptr = &value;  // ptr = عنوان value في الـ RAM
*ptr = 100;         // *ptr = اوصل للقيمة عبر العنوان
// value دلوقتي = 100
```

### الـ include — زي الـ require

```cpp
// JavaScript
const fs = require('fs');
const http = require('http');

// C++
#include <iostream>    // للـ cout وcerr
#include <string>      // للـ std::string
#include <vector>      // للـ std::vector (زي Array)
#include <unordered_map> // زي Object/Map في JS

// System headers (OS APIs)
#include <sys/socket.h>  // للـ socket functions
#include <netinet/in.h>  // للـ sockaddr_in
#include <sys/epoll.h>   // للـ epoll
#include <sys/mman.h>    // للـ mmap
#include <unistd.h>      // للـ close, read, write
#include <fcntl.h>       // للـ fcntl (non-blocking)
```

### الـ Compilation — خطوة مفيش مثيلها في JS

```bash
# JavaScript — شغّل مباشرة
node server.js

# C++ — لازم تـ compile الأول
g++ -o server server.cpp   # g++ = compiler, -o = output file name

# بعدين شغّل الـ compiled binary
./server
```

---

# 3. TCP vs HTTP — الفرق الحقيقي

## الـ OSI Model والـ Protocol Stack

```mermaid
graph TD
    subgraph APP ["Application Layer (Layer 7)"]
        HTTP["HTTP / HTTPS / WebSocket<br/>'GET /api/health HTTP/1.1'"]
    end

    subgraph TRANSPORT ["Transport Layer (Layer 4)"]
        TCP["TCP — Transmission Control Protocol<br/>بيضمن الـ order والـ reliability"]
        UDP["UDP — User Datagram Protocol<br/>أسرع، بس مش reliable"]
    end

    subgraph NETWORK ["Network Layer (Layer 3)"]
        IP["IP — بيوصّل الـ packets بين machines"]
    end

    subgraph LINK ["Data Link (Layer 2)"]
        ETH["Ethernet / WiFi"]
    end

    HTTP --> TCP
    TCP --> IP
    IP --> ETH

    style APP fill:#1a365d,color:#fff
    style TRANSPORT fill:#1c4532,color:#fff
    style NETWORK fill:#322259,color:#fff
    style LINK fill:#3d2214,color:#fff
```

**الزتونة:** HTTP بيشتغل **فوق** TCP. يعني كل HTTP request هي في الأصل bytes اتبعتت عبر TCP connection.

## ليه بنشتغل على TCP مباشرة؟

```mermaid
sequenceDiagram
    participant Node as Node.js (HTTP)
    participant CPP as C++ Engine (TCP)
    participant FS as File System

    Note over Node: بيتكلم HTTP — بيعمل parse للـ headers,<br/>بيتحقق من الـ content-type,<br/>بيبني JS objects في الـ V8 Heap
    Note over CPP: بيتكلم TCP — raw bytes بس.<br/>مش محتاج يعمل parse لأي حاجة.<br/>بيقرأ الـ bytes ويكتبها على disk مباشرة.

    Node->>CPP: bytes (عبر Unix Socket)
    CPP->>FS: mmap write (zero-copy)
```

الـ C++ Engine بتاعنا مش محتاج يفهم HTTP. هو بس بياخد bytes ويكتبها على disk. ده بيخليه:
1. **أسرع** — مفيش HTTP parsing overhead
2. **أبسط** — الكود أقل
3. **أكثر مرونة** — ينفع يسجّل أي protocol مش بس HTTP

---

# 4. Phase 1 — بنبني أول TCP Server في C++

## هيكل المجلدات

```
time-machine-proxy/
└── 📁 cpp-engine/
    ├── src/
    │   ├── main.cpp          ← Entry point (Phase 1: Basic TCP)
    │   ├── tcp_server.cpp    ← TCP Server Logic
    │   ├── tcp_server.h      ← Header file
    │   ├── epoll_server.cpp  ← Phase 2: epoll version
    │   ├── epoll_server.h
    │   ├── mmap_writer.cpp   ← Phase 3: mmap writer
    │   └── mmap_writer.h
    ├── Makefile
    └── README.md
```

## إنشاء الـ Makefile

```makefile
# cpp-engine/Makefile

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -g

# Phase targets
basic:
	$(CXX) $(CXXFLAGS) -o bin/basic_server src/main_basic.cpp src/tcp_server.cpp

epoll:
	$(CXX) $(CXXFLAGS) -o bin/epoll_server src/main_epoll.cpp src/epoll_server.cpp

engine:
	$(CXX) $(CXXFLAGS) -o bin/engine src/main_engine.cpp src/epoll_server.cpp src/mmap_writer.cpp

clean:
	rm -f bin/*

.PHONY: basic epoll engine clean
```

```bash
mkdir -p cpp-engine/src cpp-engine/bin
```

---

## الـ `tcp_server.h` — الـ Header File

في C++، بتعرف الـ interface في ملف `.h` (header) والـ implementation في ملف `.cpp`.

```cpp
// cpp-engine/src/tcp_server.h
#pragma once  // بيمنع الـ header من الـ include أكتر من مرة

#include <string>

// ================================================================
// BasicTCPServer — أبسط TCP server ممكن
// الهدف: نفهم TCP Sockets الأول قبل ما نكمّل
// ================================================================
class BasicTCPServer {
public:
    // Constructor — بياخد الـ port
    explicit BasicTCPServer(int port);

    // Destructor — بيقفل الـ server socket
    ~BasicTCPServer();

    // بيبدأ الـ server ويستنى connections
    void start();

private:
    int port_;
    int server_fd_;  // الـ File Descriptor بتاع الـ server socket

    // Helper functions
    int createSocket();
    void bindToPort();
    void listenForConnections();
    void handleConnection(int client_fd);
};
```

---

## الـ `tcp_server.cpp` — الـ Implementation

```cpp
// cpp-engine/src/tcp_server.cpp

#include "tcp_server.h"

// System includes
#include <sys/socket.h>   // socket(), bind(), listen(), accept()
#include <netinet/in.h>   // sockaddr_in
#include <arpa/inet.h>    // inet_ntoa() — بيحول IP لـ string
#include <unistd.h>       // close(), read(), write()
#include <cstring>        // memset()

// Standard includes
#include <iostream>
#include <stdexcept>

// ================================================================
// Constructor
// ================================================================
BasicTCPServer::BasicTCPServer(int port) : port_(port), server_fd_(-1) {
    // -1 يعني "مفيش file descriptor صالح لسه"
}

// ================================================================
// Destructor — RAII
// ================================================================
BasicTCPServer::~BasicTCPServer() {
    if (server_fd_ != -1) {
        close(server_fd_);
        std::cout << "[TCP] Server socket closed." << std::endl;
    }
}

// ================================================================
// createSocket — الخطوة الأولى
// ================================================================
int BasicTCPServer::createSocket() {
    // socket() — system call بيطلب من الـ OS يعمل socket جديد
    //
    // AF_INET     = Address Family Internet = IPv4
    // SOCK_STREAM = TCP (stream-based, reliable, ordered)
    // 0           = بروتوكول افتراضي للـ combination دي (TCP)
    //
    // بيرجع: file descriptor (رقم) يمثّل الـ socket
    // لو فشل: بيرجع -1
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (fd == -1) {
        throw std::runtime_error("socket() failed: " + std::string(strerror(errno)));
    }
    
    // =====================================================
    // SO_REUSEADDR — مهم جداً!
    // =====================================================
    // لو السيرفر اتوقف واتشغّل تاني على نفس الـ port
    // بدون الـ option دي: "Address already in use" error
    // السبب: الـ TCP بيفضل الـ connection في حالة TIME_WAIT
    //        لمدة 2×MSL (Maximum Segment Lifetime = 60s)
    // الحل: SO_REUSEADDR بيخلي الـ OS يسمح بإعادة استخدام الـ port فوراً
    int opt = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) == -1) {
        close(fd);
        throw std::runtime_error("setsockopt() failed");
    }
    
    return fd;
}

// ================================================================
// bindToPort — ربط الـ Socket بالـ Port
// ================================================================
void BasicTCPServer::bindToPort() {
    // sockaddr_in = بنية بيانات بتوصف IP address وPort
    struct sockaddr_in addr;
    
    // memset — بنصفّر الـ struct كلها
    // (عشان نتجنب garbage values في الـ fields غير المستخدمة)
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_family = AF_INET;          // IPv4
    addr.sin_port = htons(port_);       // htons = host-to-network byte order
                                         // (الـ network بيستخدم big-endian)
    addr.sin_addr.s_addr = INADDR_ANY;  // استنّى على كل الـ interfaces
                                         // (0.0.0.0)
    
    // bind() — بيربط الـ socket بالـ address والـ port
    if (bind(server_fd_, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        throw std::runtime_error("bind() failed: " + std::string(strerror(errno)));
    }
    
    std::cout << "[TCP] Bound to port " << port_ << std::endl;
}

// ================================================================
// listenForConnections — بيبدأ الـ Server يستنى
// ================================================================
void BasicTCPServer::listenForConnections() {
    // listen() — بيحول الـ socket لـ "passive socket"
    //            يعني جاهز يستقبل connections بس مش يبعت
    //
    // backlog = 128: حجم الـ queue بتاع الـ connections المنتظرة
    // لو جاي connections أسرع من ما الـ server يقبلها،
    // الـ kernel بيحطها في queue. لو القيمة دي اتملت → connection مرفوضة
    if (listen(server_fd_, 128) == -1) {
        throw std::runtime_error("listen() failed: " + std::string(strerror(errno)));
    }
    
    std::cout << "[TCP] Listening on port " << port_ << "..." << std::endl;
}

// ================================================================
// handleConnection — بيتعامل مع connection واحدة
// ================================================================
void BasicTCPServer::handleConnection(int client_fd) {
    char buffer[4096];  // 4KB buffer — عشان نقرأ الـ data
    
    // read() — system call بيقرأ data من الـ socket
    // بيرجع: عدد الـ bytes اللي اتقرأت
    //         0 لو الـ client قفل الـ connection
    //        -1 لو في error
    ssize_t bytes_read = read(client_fd, buffer, sizeof(buffer) - 1);
    
    if (bytes_read > 0) {
        buffer[bytes_read] = '\0';  // null-terminate عشان نطبع كـ string
        
        std::cout << "[TCP] Received " << bytes_read << " bytes:" << std::endl;
        std::cout << "---" << std::endl;
        std::cout << buffer << std::endl;
        std::cout << "---" << std::endl;
        
        // نرد على الـ client (بروتوكول بسيط)
        std::string response = "ACK: Received " + std::to_string(bytes_read) + " bytes\n";
        write(client_fd, response.c_str(), response.size());
    }
    
    // أقفل الـ connection
    close(client_fd);
}

// ================================================================
// start — الـ Main Loop
// ================================================================
void BasicTCPServer::start() {
    server_fd_ = createSocket();
    bindToPort();
    listenForConnections();
    
    std::cout << "[TCP] Server ready. Waiting for connections..." << std::endl;
    
    // =====================================================
    // ⚠️ دي النسخة البسيطة — Thread-per-Connection
    // هنشوف مشكلتها في القسم الجاي
    // =====================================================
    while (true) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        
        // accept() — system call بيستنى connection جديدة
        // بيـ "Block" — يعني الـ process بتوقف هنا تماماً
        // لحد ما client جديد يتوصّل
        // بيرجع: file descriptor جديد للـ client connection
        int client_fd = accept(server_fd_, (struct sockaddr*)&client_addr, &client_len);
        
        if (client_fd == -1) {
            std::cerr << "[TCP] accept() failed: " << strerror(errno) << std::endl;
            continue;
        }
        
        // بنطبع IP الـ client
        char client_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &client_addr.sin_addr, client_ip, INET_ADDRSTRLEN);
        std::cout << "[TCP] New connection from " << client_ip << std::endl;
        
        // ⚠️ بنعالج الـ connection هنا مباشرة (blocking!)
        // يعني مش هنقبل connection تانية لحد ما دي تخلص
        handleConnection(client_fd);
    }
}
```

## الـ `main_basic.cpp`

```cpp
// cpp-engine/src/main_basic.cpp
#include "tcp_server.h"
#include <iostream>
#include <stdexcept>

int main() {
    std::cout << "╔════════════════════════════════════╗" << std::endl;
    std::cout << "║   Basic TCP Server — Phase 1       ║" << std::endl;
    std::cout << "╚════════════════════════════════════╝" << std::endl;
    
    try {
        BasicTCPServer server(9000);
        server.start();
    } catch (const std::exception& e) {
        std::cerr << "[FATAL] " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
```

## Compile وShغّل

```bash
cd cpp-engine

# compile
g++ -std=c++17 -o bin/basic_server src/main_basic.cpp src/tcp_server.cpp

# شغّل
./bin/basic_server
```

## تست بـ netcat

```bash
# في تيرمينال تاني
echo "Hello from netcat!" | nc localhost 9000
# المفروض يجيلك: ACK: Received 19 bytes

# تست بـ curl (بيبعت HTTP request على raw TCP)
curl http://localhost:9000/test
# هتشوف الـ HTTP request الكاملة في الـ server logs
```

**مبروك — ده أول TCP server بتاعك في C++! 🎉**

---

# 5. المشكلة — Thread-per-Connection والكارثة

## المشكلة الواضحة في الكود اللي فوق

لاحظت في الـ `start()` loop إن `handleConnection()` بيتشغّل **قبل** ما `accept()` يتشغّل تاني. يعني:

```mermaid
sequenceDiagram
    participant S as Server
    participant C1 as Client 1
    participant C2 as Client 2

    C1->>S: Connection Request
    S->>S: accept() → client_fd_1
    S->>S: handleConnection(client_fd_1) ← يوقف هنا!
    
    Note over C2: مستنّي... مستنّي... مستنّي... ⏳
    
    S->>S: handleConnection خلّص
    C2->>S: Connection Request (بعد تأخير كبير!)
    S->>S: accept() → client_fd_2
```

**الـ Server بيعمل connection واحدة في وقت واحد بس.**

## الحل الساذج — Thread لكل Connection

```cpp
// ⚠️ مجرد مثال — مش هنستخدمه
#include <thread>

while (true) {
    int client_fd = accept(server_fd_, nullptr, nullptr);
    
    // اعمل thread جديد لكل connection
    std::thread t([client_fd]() {
        handleConnection(client_fd);
    });
    t.detach(); // خليه يشتغل لوحده
}
```

### ليه ده مش الحل؟

```mermaid
graph TD
    subgraph Problem ["مشكلة Thread-per-Connection على 10,000 connections"]
        C["10,000 concurrent connections"]
        T["10,000 OS Threads"]
        M["10,000 × 8MB Stack = 80GB RAM 💀"]
        CS["Context Switching Overhead<br/>(الـ OS بيروح بيجي بين 10k threads)"]
        
        C --> T
        T --> M
        T --> CS
    end

    style Problem fill:#4a1212,color:#fff
    style M fill:#742a2a,color:#fff,stroke:#fc8181
```

> [!DEEP-DIVE]
> ## 🔬 ليه Thread تاكل 8MB RAM؟
>
> لما الـ OS بيعمل thread جديد، بيخصص ليه:
>
> - **Stack Memory:** افتراضياً 8MB على Linux (ممكن تشوفها بـ `ulimit -s`)
>   - الـ Stack بيتخزن فيه: local variables، function call frames، return addresses
>   - اتصميم على كبر عشان ما يحصلش stack overflow
>
> - **Kernel Data Structures:** كل thread عنده `task_struct` في الـ kernel (~10KB)
>
> - **Thread Local Storage (TLS):** متغيرات خاصة بكل thread
>
> لما بتعمل 10,000 thread:
> - 10,000 × 8MB Stack = 80GB Virtual Memory (مش Physical RAM دايماً، بس الـ address space بيتحجز)
> - الـ context switching: الـ OS بيحفظ ويرجّع registers (16 registers × 8 bytes = 128 bytes) لكل thread switch
> - على 10k threads: الـ CPU بيقضي وقت أكبر في switching من الشغل الفعلي!
>
> **الحل اللي اخترناه: `epoll` — نخلّي الـ Kernel يبلّغنا بالـ events ومنستناش على threads.**

---

# 6. Deep Dive: الـ epoll — عيون الـ Kernel

## قبل الـ epoll — كانت في `select()` و`poll()`

لفهم ليه `epoll` ثورة، لازم تعرف المشكلة اللي حلّها.

### `select()` — الجد البشع

```c
// select() API
fd_set read_fds;
FD_ZERO(&read_fds);

// بتضيف كل الـ file descriptors يدوياً
for (int i = 0; i < num_connections; i++) {
    FD_SET(connections[i], &read_fds);
}

// select() بيبلّغك لما أي واحد فيهم جاهز للقراءة
select(max_fd + 1, &read_fds, NULL, NULL, NULL);

// بس مش بيقولك مين — لازم تدور بنفسك!
for (int i = 0; i < num_connections; i++) {
    if (FD_IS_SET(connections[i], &read_fds)) {
        // ده جاهز
    }
}
```

**المشكلة:**
1. بتبعت كل الـ FDs للـ Kernel في كل call — O(n) copy
2. الـ Kernel بيرجع لك كل الـ FDs تاني — O(n) copy تاني
3. أنت بتعمل loop على كلهم — O(n) search
4. الـ max FD value محدود بـ 1024 في الـ linux القديم

على 10,000 connections: كل "tick" = O(n) + O(n) + O(n) = بطيء جداً!

### `epoll` — الحل الأنيق

```mermaid
graph TD
    subgraph Kernel ["Linux Kernel"]
        ET["epoll Interest Table<br/>(Red-Black Tree)<br/>O(log n) insertion"]
        RQ["Ready Queue<br/>(Doubly Linked List)<br/>بس الـ FDs الجاهزة"]
    end

    subgraph App ["تطبيقك"]
        EC["epoll_create()<br/>بيعمل الـ epoll instance"]
        EA["epoll_ctl()<br/>بيضيف/يشيل FDs من الـ Interest Table"]
        EW["epoll_wait()<br/>بيستنى ويرجع بس الـ events الجاهزة"]
    end

    EA -->|"add FD"| ET
    ET -->|"لما FD يبقى جاهز"| RQ
    EW -->|"بتسأل"| RQ
    RQ -->|"بترجع الـ ready events بس"| EW

    style Kernel fill:#1c4532,color:#fff
    style App fill:#1a365d,color:#fff
    style RQ fill:#276749,color:#fff,stroke:#68d391,stroke-width:2px
```

**الفرق الجوهري:**

| | `select/poll` | `epoll` |
|--|--|--|
| **Complexity per call** | O(n) — بيمسح كل الـ FDs | O(1) — بيرجع بس الجاهزة |
| **Kernel-User copy** | O(n) في كل call | مرة واحدة عند الإضافة |
| **Max connections** | محدود | ملايين (limited by RAM) |
| **Suitable for** | < 1,000 FDs | 100,000+ FDs |

> [!DEEP-DIVE]
> ## 🔬 إزاي الـ Kernel يعرف لما FD يبقى جاهز؟
>
> ده سؤال عميق. الـ Kernel يعرف لأنه هو المسؤول عن الـ network stack!
>
> **الرحلة الكاملة لـ TCP packet:**
>
> 1. **Network Card (NIC)** بتستقبل الـ packet من الـ wire
> 2. بتعمل **DMA (Direct Memory Access)** — بتحط الـ packet في الـ RAM مباشرة من غير CPU
> 3. بتبعت **hardware interrupt** للـ CPU: "في packet جديد!"
> 4. الـ Kernel **Interrupt Handler** بيصحى ويبدأ يعالج الـ packet
> 5. الـ Kernel بيعمل **TCP/IP processing**: checksum، ordering، reassembly
> 6. الـ Kernel بيحط الـ data في **socket receive buffer** (في الـ kernel memory)
> 7. الـ Kernel بيعدّل الـ epoll Interest Table: "الـ FD ده دلوقتي عنده data جاهزة للقراءة"
> 8. الـ epoll instance بيتحرك: بيضيف الـ FD لـ Ready Queue
> 9. `epoll_wait()` بيصحى ويرجع للـ application بالـ event
>
> **الـ application مش صحي قبل الخطوة 9.** مش بياكل CPU. الـ interrupt هو اللي يصحّيه.

## الـ epoll APIs الـ 3

```c
// 1. epoll_create1() — إنشاء epoll instance
// بيرجع file descriptor يمثل الـ epoll
int epfd = epoll_create1(0);

// 2. epoll_ctl() — إضافة/تعديل/حذف FD من الـ monitoring
struct epoll_event ev;
ev.events = EPOLLIN;   // راقب لما يبقى فيه data للقراءة
ev.data.fd = client_fd; // الـ FD اللي عايز تراقبه

epoll_ctl(epfd,
          EPOLL_CTL_ADD,  // EPOLL_CTL_ADD / MOD / DEL
          client_fd,
          &ev);

// 3. epoll_wait() — استنّى events
struct epoll_event events[MAX_EVENTS];
int num_events = epoll_wait(epfd,    // الـ epoll instance
                             events,  // array تاخد فيه الـ events
                             MAX_EVENTS, // max events ترجعهم
                             -1);     // timeout (-1 = infinite)
// بيرجع عدد الـ events الجاهزة
// events[0..num_events-1] = الـ FDs اللي عندهم data
```

### الـ Edge Triggering vs Level Triggering

```mermaid
graph LR
    subgraph LT ["Level Triggered (Default)"]
        LT1["Data وصلت: 100 bytes"]
        LT2["epoll_wait بيرجع: ✅ EPOLLIN"]
        LT3["قرأت 40 bytes بس"]
        LT4["epoll_wait بيرجع تاني: ✅ EPOLLIN (لسه في 60 bytes)"]
        LT1 --> LT2 --> LT3 --> LT4
    end

    subgraph ET ["Edge Triggered (EPOLLET)"]
        ET1["Data وصلت: 100 bytes"]
        ET2["epoll_wait بيرجع: ✅ EPOLLIN"]
        ET3["قرأت 40 bytes بس"]
        ET4["epoll_wait: ❌ مش بيرجع! (لأن الـ state ما اتغيرش)"]
        ET5["لازم تقرأ كل الـ data في مرة واحدة!"]
        ET1 --> ET2 --> ET3 --> ET4
        ET4 --> ET5
    end

    style LT fill:#1a365d,color:#fff
    style ET fill:#1c4532,color:#fff
```

**اللي هنستخدمه:** `EPOLLIN` (Level Triggered) عشان أبسط في الـ implementation الأولى. في production، الـ Edge Triggered أسرع بس أصعب.

---

# 7. Phase 2 — TCP Server بـ epoll (Non-Blocking)

## `epoll_server.h`

```cpp
// cpp-engine/src/epoll_server.h
#pragma once

#include <string>
#include <functional>
#include <unordered_map>

// Maximum events نستنّيهم من epoll_wait في كل iteration
constexpr int MAX_EVENTS = 1024;

// ================================================================
// DataHandler — نوع الـ callback اللي بيتشغّل لما data تيجي
// ================================================================
// std::function — زي الـ callback في JavaScript
// بس type-safe
using DataHandler = std::function<void(int fd, const char* data, size_t len)>;

// ================================================================
// EpollServer — TCP Server بيستخدم epoll
// Non-blocking I/O — بيتعامل مع آلاف الـ connections بـ thread واحد
// ================================================================
class EpollServer {
public:
    explicit EpollServer(int port);
    ~EpollServer();

    // بتسجّل callback بيتنادى لما data تيجي على أي connection
    void onData(DataHandler handler);

    // بتبدأ الـ event loop
    void start();

    // بتوقف الـ server
    void stop();

private:
    int port_;
    int server_fd_;  // الـ listening socket
    int epoll_fd_;   // الـ epoll instance
    bool running_;

    DataHandler data_handler_;

    // Connection management
    std::unordered_map<int, std::string> connection_buffers_;

    // Helper functions
    void setupServer();
    void makeNonBlocking(int fd);
    void addToEpoll(int fd, uint32_t events);
    void removeFromEpoll(int fd);
    void acceptNewConnection();
    void handleClientData(int client_fd);
    void closeConnection(int client_fd);
    void eventLoop();
};
```

## `epoll_server.cpp`

```cpp
// cpp-engine/src/epoll_server.cpp

#include "epoll_server.h"

#include <sys/socket.h>
#include <sys/epoll.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <cstring>
#include <cerrno>

#include <iostream>
#include <stdexcept>

// ================================================================
// Constructor & Destructor
// ================================================================
EpollServer::EpollServer(int port)
    : port_(port), server_fd_(-1), epoll_fd_(-1), running_(false) {}

EpollServer::~EpollServer() {
    stop();
}

void EpollServer::stop() {
    running_ = false;
    // RAII — بيتأكد إن كل الـ FDs بتتقفل
    if (server_fd_ != -1) { close(server_fd_); server_fd_ = -1; }
    if (epoll_fd_ != -1)  { close(epoll_fd_);  epoll_fd_ = -1;  }
}

void EpollServer::onData(DataHandler handler) {
    data_handler_ = handler;
}

// ================================================================
// makeNonBlocking — المفتاح لكل حاجة
// ================================================================
// لما socket بيبقى "blocking":
//   read() → بتوقف لحد ما data تيجي
//   write() → بتوقف لحد ما الـ buffer يفضى
//
// لما socket بيبقى "non-blocking":
//   read() → لو مفيش data → بيرجع على طول بـ EAGAIN
//   write() → لو الـ buffer فاضي → بيرجع بـ EAGAIN
//
// epoll + non-blocking = سحر
void EpollServer::makeNonBlocking(int fd) {
    // fcntl = "file control" — بيتحكم في properties الـ file descriptor
    int flags = fcntl(fd, F_GETFL, 0);  // بيجيب الـ current flags
    if (flags == -1) {
        throw std::runtime_error("fcntl F_GETFL failed");
    }
    
    // بيضيف O_NONBLOCK للـ flags الموجودة
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
        throw std::runtime_error("fcntl F_SETFL failed");
    }
}

// ================================================================
// addToEpoll — بيسجّل FD في الـ epoll instance
// ================================================================
void EpollServer::addToEpoll(int fd, uint32_t events) {
    struct epoll_event ev;
    ev.events = events;
    ev.data.fd = fd;
    
    if (epoll_ctl(epoll_fd_, EPOLL_CTL_ADD, fd, &ev) == -1) {
        throw std::runtime_error("epoll_ctl ADD failed: " + std::string(strerror(errno)));
    }
}

// ================================================================
// removeFromEpoll
// ================================================================
void EpollServer::removeFromEpoll(int fd) {
    epoll_ctl(epoll_fd_, EPOLL_CTL_DEL, fd, nullptr);
}

// ================================================================
// setupServer — الإعداد الكامل
// ================================================================
void EpollServer::setupServer() {
    // ────────────────────────────────────────
    // Step 1: إنشاء الـ Server Socket
    // ────────────────────────────────────────
    server_fd_ = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd_ == -1) {
        throw std::runtime_error("socket() failed");
    }
    
    int opt = 1;
    setsockopt(server_fd_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    
    // ────────────────────────────────────────
    // Step 2: خلّي الـ Server Socket Non-Blocking
    // ────────────────────────────────────────
    makeNonBlocking(server_fd_);
    
    // ────────────────────────────────────────
    // Step 3: Bind وListen
    // ────────────────────────────────────────
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port_);
    addr.sin_addr.s_addr = INADDR_ANY;
    
    if (bind(server_fd_, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        throw std::runtime_error("bind() failed: " + std::string(strerror(errno)));
    }
    
    if (listen(server_fd_, SOMAXCONN) == -1) {
        // SOMAXCONN = maximum backlog قدرته الـ OS (عادةً 4096)
        throw std::runtime_error("listen() failed");
    }
    
    // ────────────────────────────────────────
    // Step 4: إنشاء الـ epoll Instance
    // ────────────────────────────────────────
    epoll_fd_ = epoll_create1(0);
    // epoll_create1(0) = epoll_create() الجديدة
    // 0 = no special flags
    
    if (epoll_fd_ == -1) {
        throw std::runtime_error("epoll_create1() failed");
    }
    
    // ────────────────────────────────────────
    // Step 5: سجّل الـ Server Socket في epoll
    // ────────────────────────────────────────
    // EPOLLIN = راقب لما يبقى في connections جديدة جاهزة لـ accept()
    addToEpoll(server_fd_, EPOLLIN);
    
    std::cout << "[EPOLL] Server ready on port " << port_ << std::endl;
}

// ================================================================
// acceptNewConnection — بيقبل connections جديدة (non-blocking)
// ================================================================
void EpollServer::acceptNewConnection() {
    // Non-blocking accept — ممكن يفشل بـ EAGAIN لو مفيش connections
    // بنعمل loop نقبل كل الـ pending connections في مرة واحدة
    while (true) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        
        int client_fd = accept(server_fd_,
                               (struct sockaddr*)&client_addr,
                               &client_len);
        
        if (client_fd == -1) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                // مفيش connections تانية — طبيعي في non-blocking
                break;
            }
            std::cerr << "[EPOLL] accept() error: " << strerror(errno) << std::endl;
            break;
        }
        
        // خلّي الـ client socket non-blocking كمان
        makeNonBlocking(client_fd);
        
        // سجّله في الـ epoll — راقبه لما بيبعت data
        addToEpoll(client_fd, EPOLLIN);
        
        // ابعت buffer فارغ للـ connection الجديدة
        connection_buffers_[client_fd] = "";
        
        char client_ip[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &client_addr.sin_addr, client_ip, INET_ADDRSTRLEN);
        std::cout << "[EPOLL] New connection: fd=" << client_fd
                  << " from " << client_ip << std::endl;
    }
}

// ================================================================
// handleClientData — بيقرأ data من client جاهز
// ================================================================
void EpollServer::handleClientData(int client_fd) {
    char buffer[65536];  // 64KB read buffer
    
    // Non-blocking read loop — بنقرأ كل الـ available data
    while (true) {
        ssize_t n = read(client_fd, buffer, sizeof(buffer));
        
        if (n == -1) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                // قرأنا كل الـ available data — طبيعي
                break;
            }
            // Error حقيقي
            std::cerr << "[EPOLL] read() error on fd=" << client_fd << std::endl;
            closeConnection(client_fd);
            return;
        }
        
        if (n == 0) {
            // الـ client قفل الـ connection
            std::cout << "[EPOLL] Connection closed: fd=" << client_fd << std::endl;
            closeConnection(client_fd);
            return;
        }
        
        // بنطلب الـ data handler يشتغل على الـ data دي
        if (data_handler_) {
            data_handler_(client_fd, buffer, static_cast<size_t>(n));
        }
    }
}

// ================================================================
// closeConnection — بيقفل connection ويشيلها من كل حاجة
// ================================================================
void EpollServer::closeConnection(int client_fd) {
    removeFromEpoll(client_fd);
    connection_buffers_.erase(client_fd);
    close(client_fd);
}

// ================================================================
// eventLoop — قلب الـ Server 🫀
// ================================================================
void EpollServer::eventLoop() {
    struct epoll_event events[MAX_EVENTS];
    
    std::cout << "[EPOLL] Event loop started." << std::endl;
    
    while (running_) {
        // =====================================================
        // epoll_wait — نقطة التوقف الوحيدة
        // =====================================================
        // بيستنى هنا لحد ما حاجة تحصل
        // مش بياكل CPU — الـ kernel بيصحّيه لما events تجي
        // timeout = -1 → استنّى للأبد
        int num_events = epoll_wait(epoll_fd_, events, MAX_EVENTS, -1);
        
        if (num_events == -1) {
            if (errno == EINTR) continue; // interrupted by signal — طبيعي
            throw std::runtime_error("epoll_wait() failed");
        }
        
        // =====================================================
        // معالجة كل الـ events اللي جت في نفس الوقت
        // =====================================================
        for (int i = 0; i < num_events; i++) {
            int event_fd = events[i].data.fd;
            uint32_t event_flags = events[i].events;
            
            if (event_fd == server_fd_) {
                // ده الـ server socket — يعني في connection جديدة!
                acceptNewConnection();
            } else if (event_flags & EPOLLIN) {
                // ده client socket — في data جاهزة للقراءة
                handleClientData(event_fd);
            } else if (event_flags & (EPOLLHUP | EPOLLERR)) {
                // الـ connection انقطعت أو في error
                std::cout << "[EPOLL] Connection error: fd=" << event_fd << std::endl;
                closeConnection(event_fd);
            }
        }
    }
}

// ================================================================
// start
// ================================================================
void EpollServer::start() {
    setupServer();
    running_ = true;
    eventLoop();
}
```

## `main_epoll.cpp`

```cpp
// cpp-engine/src/main_epoll.cpp

#include "epoll_server.h"
#include <iostream>
#include <csignal>

// =====================================================
// Global server pointer — عشان signal handler يوصله
// =====================================================
EpollServer* g_server = nullptr;

void signalHandler(int signum) {
    std::cout << "\n[EPOLL] Signal " << signum << " received. Shutting down..." << std::endl;
    if (g_server) g_server->stop();
}

int main() {
    std::cout << "╔════════════════════════════════════════╗" << std::endl;
    std::cout << "║   epoll TCP Server — Phase 2           ║" << std::endl;
    std::cout << "╚════════════════════════════════════════╝" << std::endl;
    
    // Handle Ctrl+C بشكل graceful
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);
    
    try {
        EpollServer server(9001);
        g_server = &server;
        
        // بنسجّل data handler — هيتشغّل على كل data تيجي
        server.onData([](int fd, const char* data, size_t len) {
            std::cout << "[DATA] fd=" << fd
                      << " bytes=" << len << std::endl;
            // هنا بعدين هنضيف الـ mmap writing
        });
        
        server.start();
    } catch (const std::exception& e) {
        std::cerr << "[FATAL] " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
```

## Compile وتست

```bash
# Compile
g++ -std=c++17 -o bin/epoll_server \
    src/main_epoll.cpp src/epoll_server.cpp

# شغّل
./bin/epoll_server
```

```bash
# في تيرمينال تاني — تست بـ connections متعددة في وقت واحد
for i in {1..10}; do
    echo "Request $i from client" | nc localhost 9001 &
done
wait

# المفروض تشوف في الـ server:
# [EPOLL] New connection: fd=5 from 127.0.0.1
# [EPOLL] New connection: fd=6 from 127.0.0.1
# ...
# [DATA] fd=5 bytes=19
# [DATA] fd=6 bytes=19
# ...
```

**الفرق المذهل:** السيرفر ده بيتعامل مع الـ 10 connections دي **في نفس الوقت** بـ thread واحد بس!

---

# 8. Deep Dive: الـ mmap — الذاكرة اللي بتكتب نفسها

## المشكلة مع Standard File I/O

لما بتكتب على file بـ `write()` system call، ده اللي بيحصل:

```mermaid
graph TD
    subgraph UserSpace ["User Space (تطبيقك)"]
        APP["Buffer في RAM بتاعك<br/>(مثلاً: 'Hello World')"]
    end

    subgraph KernelSpace ["Kernel Space"]
        PC["Page Cache<br/>(Buffer في RAM بتاع الـ Kernel)"]
    end

    subgraph Physical ["Physical Storage"]
        DISK["SSD / HDD"]
    end

    APP -->|"1. write() syscall<br/>COPY من User Space → Kernel Space"| PC
    PC -->|"2. بعدين (async) الـ Kernel يكتب<br/>على الـ disk"| DISK

    style UserSpace fill:#1a365d,color:#fff
    style KernelSpace fill:#1c4532,color:#fff
    style Physical fill:#3d2214,color:#fff
```

**المشكلة:** في كل `write()` call، في **data copy** من الـ user space للـ kernel space. ده overhead.

## الـ mmap — الحل الجذري

`mmap` بتقول للـ Kernel: "خلّي جزء من RAM بتاعي يمثّل ملف على disk مباشرة."

```mermaid
graph TD
    subgraph UserSpace ["User Space (تطبيقك)"]
        VIRT["Virtual Memory Region<br/>(0x7f... address)<br/>في address space بتاعك"]
    end

    subgraph KernelSpace ["Kernel Space"]
        PC["Page Cache<br/>(نفس الـ physical pages!)"]
    end

    subgraph Physical ["Physical Storage"]
        DISK["SSD / HDD"]
    end

    VIRT <-->|"Same Physical Memory!<br/>مش copy — نفس الـ pages"| PC
    PC -->|"الـ Kernel يكتب<br/>في الخلفية (msync)"| DISK

    style UserSpace fill:#1a365d,color:#fff
    style KernelSpace fill:#1c4532,color:#fff
    style Physical fill:#3d2214,color:#fff

    NOTE["⚡ لما تكتب في VIRT<br/>= بتكتب في PC مباشرة<br/>مفيش copy على الإطلاق!"]
    style NOTE fill:#276749,color:#fff
```

**الـ mmap بتاخد الـ page cache بتاع الـ Kernel وبتحطه في الـ virtual address space بتاعك مباشرة.**
كتابتك في الـ memory = كتابة في الـ Kernel page cache = ملف على disk. مفيش copy!

> [!DEEP-DIVE]
> ## 🔬 الـ mmap من جوّه — Virtual Memory و Page Faults
>
> لما بتعمل `mmap()` على ملف:
>
> 1. الـ Kernel بيضيف **VMA (Virtual Memory Area)** في الـ process memory map
>    - تقدر تشوف VMAs بتاع أي process بـ `cat /proc/PID/maps`
>
> 2. في الأول، الـ pages مش موجودة فعلاً في RAM — بس في الـ virtual address space
>
> 3. لما تكتب في الـ address ده:
>    - الـ CPU يحاول يوصل للـ physical page
>    - مش لاقيها → **Page Fault** exception
>    - الـ Kernel يصحى (page fault handler)
>    - يجيب الـ page من disk للـ RAM (Page Cache)
>    - يربطها بالـ virtual address
>    - يكمّل تنفيذ كودك من نفس السطر اللي حصل فيه الـ page fault
>
> 4. لما بتكتب، الـ page بتتعلّم كـ "dirty" (اتغيرت)
>
> 5. الـ Kernel بيكتب الـ dirty pages على disk في الخلفية (writeback) أو لما تعمل `msync()`
>
> **النتيجة:** من وجهة نظر كودك، بتكتب في الـ memory زي أي array. من وجهة نظر الـ Kernel، ده ملف على disk اتحدث.
> **مفيش context switch إضافي، مفيش copy، مفيش thread pool.**

## الـ mmap API

```cpp
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

// 1. افتح الملف
int fd = open("traffic.log", O_RDWR | O_CREAT, 0644);

// 2. حدد حجم الملف (المنطقة اللي هنعمل map عليها)
size_t file_size = 1024 * 1024 * 256; // 256MB مثلاً
ftruncate(fd, file_size); // بتحدد حجم الملف

// 3. عمل الـ mmap
void* mapped = mmap(
    nullptr,        // hint للـ Kernel على الـ address (nullptr = اختار بنفسك)
    file_size,      // حجم المنطقة
    PROT_READ | PROT_WRITE, // permissions: قراءة وكتابة
    MAP_SHARED,     // التغييرات بتتكتب على الملف الأصلي
    fd,             // الـ file descriptor
    0               // offset في الملف (من الأول)
);

if (mapped == MAP_FAILED) {
    // حصل error
    perror("mmap failed");
}

// 4. استخدم الـ mapped memory زي أي array
char* buffer = static_cast<char*>(mapped);
memcpy(buffer + offset, data, data_size); // كتابة بلا copy!

// 5. اعمل sync لو عايز تتأكد إن الـ data اتكتبت على disk فعلاً
msync(mapped, file_size, MS_ASYNC); // MS_ASYNC = خلّي الـ Kernel يكتب في الخلفية

// 6. عند الانتهاء
munmap(mapped, file_size); // احرر الـ mapping
close(fd);
```

---

# 9. Phase 3 — الـ C++ Engine الكامل مع mmap

## `mmap_writer.h`

```cpp
// cpp-engine/src/mmap_writer.h
#pragma once

#include <string>
#include <cstdint>
#include <atomic>

// ================================================================
// حجم الـ mmap file — 256MB
// كبير بما يكفي لملايين الـ requests
// لما يمتلي → بنعمل log rotation (Sprint 3)
// ================================================================
constexpr size_t MMAP_FILE_SIZE = 256ULL * 1024 * 1024; // 256MB

// ================================================================
// Header بتاع كل Traffic Entry في الملف
// ================================================================
// بنحط header قبل كل entry عشان نقدر نقرأ الـ file لاحقاً
// بنعرف فين كل entry وحجمها
#pragma pack(push, 1) // zero padding — بنضمن الـ size بالظبط
struct EntryHeader {
    uint64_t timestamp_ns;  // nano-seconds since epoch
    uint32_t data_length;   // حجم الـ data بالبايت
    uint8_t  method;        // 0=GET, 1=POST, 2=PUT, 3=DELETE
    uint8_t  reserved[3];   // padding للـ alignment
};
#pragma pack(pop)

// ================================================================
// MmapWriter — بيكتب traffic data على disk بـ mmap
// Thread-safe: بيستخدم atomic counter للـ position
// ================================================================
class MmapWriter {
public:
    explicit MmapWriter(const std::string& file_path);
    ~MmapWriter();

    // بيكتب data entry — returns false لو الملف امتلا
    bool write(const char* data, size_t length, uint8_t method = 0);

    // بيرجع كام byte اتكتب
    size_t bytesWritten() const;

    // بيرجع كام entry اتكتبت
    uint64_t entriesWritten() const;

    // Force flush للـ disk
    void sync();

private:
    std::string file_path_;
    int fd_;
    char* mapped_ptr_;
    size_t file_size_;

    // atomic — thread-safe counter بدون mutex
    std::atomic<size_t> write_offset_;
    std::atomic<uint64_t> entries_written_;

    void setup();
    void cleanup();
    uint64_t currentTimestampNs() const;
};
```

## `mmap_writer.cpp`

```cpp
// cpp-engine/src/mmap_writer.cpp

#include "mmap_writer.h"

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <cstring>
#include <ctime>

#include <iostream>
#include <stdexcept>

// ================================================================
// Constructor & Destructor
// ================================================================
MmapWriter::MmapWriter(const std::string& file_path)
    : file_path_(file_path),
      fd_(-1),
      mapped_ptr_(nullptr),
      file_size_(MMAP_FILE_SIZE),
      write_offset_(0),
      entries_written_(0) {
    setup();
}

MmapWriter::~MmapWriter() {
    cleanup();
}

// ================================================================
// setup — إنشاء وmap الملف
// ================================================================
void MmapWriter::setup() {
    // ────────────────────────────────
    // Step 1: افتح/إنشاء الملف
    // ────────────────────────────────
    fd_ = open(file_path_.c_str(),
               O_RDWR | O_CREAT,  // read+write، إنشاء لو مش موجود
               0644);              // permissions: rw-r--r--
    
    if (fd_ == -1) {
        throw std::runtime_error("open() failed for: " + file_path_);
    }
    
    // ────────────────────────────────
    // Step 2: حدد حجم الملف
    // ────────────────────────────────
    // ftruncate بيحدد حجم الملف
    // لو الملف أصغر → بيكبّره (بيملا الباقي بـ zero bytes)
    // لو الملف أكبر → بيقصّره (بيحذف من الآخر)
    if (ftruncate(fd_, static_cast<off_t>(file_size_)) == -1) {
        close(fd_);
        throw std::runtime_error("ftruncate() failed");
    }
    
    // ────────────────────────────────
    // Step 3: الـ mmap
    // ────────────────────────────────
    void* ptr = mmap(
        nullptr,                 // الـ Kernel يختار الـ address
        file_size_,              // حجم المنطقة
        PROT_READ | PROT_WRITE,  // read و write
        MAP_SHARED,              // التغييرات بتتكتب على الملف
        fd_,                     // الـ fd
        0                        // offset = من البداية
    );
    
    if (ptr == MAP_FAILED) {
        close(fd_);
        throw std::runtime_error("mmap() failed");
    }
    
    mapped_ptr_ = static_cast<char*>(ptr);
    
    // ────────────────────────────────
    // Step 4: Hint للـ Kernel
    // ────────────────────────────────
    // madvise = بنقول للـ Kernel إحنا هنكتب بشكل sequential
    // بيخلي الـ Kernel يعمل read-ahead ويحسّن الـ caching
    madvise(mapped_ptr_, file_size_, MADV_SEQUENTIAL);
    
    std::cout << "[MMAP] Mapped " << file_size_ / (1024 * 1024)
              << "MB file: " << file_path_ << std::endl;
}

// ================================================================
// cleanup — RAII cleanup
// ================================================================
void MmapWriter::cleanup() {
    if (mapped_ptr_ != nullptr) {
        // Force write كل الـ dirty pages على disk
        msync(mapped_ptr_, file_size_, MS_SYNC);
        munmap(mapped_ptr_, file_size_);
        mapped_ptr_ = nullptr;
    }
    if (fd_ != -1) {
        close(fd_);
        fd_ = -1;
    }
}

// ================================================================
// currentTimestampNs — بيرجع الوقت بالـ nanoseconds
// ================================================================
uint64_t MmapWriter::currentTimestampNs() const {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return static_cast<uint64_t>(ts.tv_sec) * 1'000'000'000ULL + ts.tv_nsec;
}

// ================================================================
// write — قلب الـ MmapWriter 🫀
// ================================================================
bool MmapWriter::write(const char* data, size_t length, uint8_t method) {
    // حجم الـ entry الكاملة: header + data
    size_t total_size = sizeof(EntryHeader) + length;
    
    // =====================================================
    // Atomic offset update — Thread-Safe بدون Mutex
    // =====================================================
    // fetch_add بيعمل الاتنين في operation واحدة atomic:
    // 1. بيجيب القيمة الحالية (ده offset بتاعنا)
    // 2. بيضيف total_size للقيمة
    // لو 2 threads وصلوا هنا في نفس الوقت:
    //   Thread A: بياخد offset=1000, counter بيبقى 1200
    //   Thread B: بياخد offset=1200, counter بيبقى 1400
    // مش ممكن يـ overwrite على بعض!
    size_t my_offset = write_offset_.fetch_add(total_size, std::memory_order_relaxed);
    
    // تحقق إن عندنا مساحة كافية
    if (my_offset + total_size > file_size_) {
        // الملف امتلا — log rotation في Sprint 3 هيحل ده
        std::cerr << "[MMAP] File full! Bytes written: " << my_offset << std::endl;
        write_offset_.fetch_sub(total_size, std::memory_order_relaxed); // rollback
        return false;
    }
    
    // =====================================================
    // كتابة الـ Header
    // =====================================================
    EntryHeader header;
    header.timestamp_ns = currentTimestampNs();
    header.data_length  = static_cast<uint32_t>(length);
    header.method       = method;
    memset(header.reserved, 0, sizeof(header.reserved));
    
    // memcpy إلى الـ mmap region — ده مش copy للـ Kernel!
    // ده copy في نفس الـ physical RAM (page cache)
    // الـ Kernel سيكتبها على disk في الخلفية
    memcpy(mapped_ptr_ + my_offset, &header, sizeof(EntryHeader));
    
    // =====================================================
    // كتابة الـ Data
    // =====================================================
    memcpy(mapped_ptr_ + my_offset + sizeof(EntryHeader), data, length);
    
    // عدّ الـ entries
    entries_written_.fetch_add(1, std::memory_order_relaxed);
    
    return true;
}

// ================================================================
// sync — Force flush
// ================================================================
void MmapWriter::sync() {
    if (mapped_ptr_) {
        msync(mapped_ptr_, write_offset_.load(), MS_ASYNC);
    }
}

size_t MmapWriter::bytesWritten() const {
    return write_offset_.load(std::memory_order_relaxed);
}

uint64_t MmapWriter::entriesWritten() const {
    return entries_written_.load(std::memory_order_relaxed);
}
```

---

## الـ Engine الكامل — `main_engine.cpp`

```cpp
// cpp-engine/src/main_engine.cpp
// ================================================================
// The Time Machine Proxy — C++ Engine
// ================================================================
// بيستقبل shadow traffic من الـ Node.js Proxy عبر TCP
// وبيكتبه على disk بـ mmap (zero-copy, non-blocking)
// ================================================================

#include "epoll_server.h"
#include "mmap_writer.h"

#include <iostream>
#include <csignal>
#include <memory>
#include <filesystem>

// ──────────────────────────────────────────────────────────────
// Configuration
// ──────────────────────────────────────────────────────────────
constexpr int    ENGINE_PORT     = 9500;
const std::string LOG_DIR        = "./logs/";
const std::string TRAFFIC_FILE   = LOG_DIR + "traffic.bin";

// ──────────────────────────────────────────────────────────────
// Globals للـ Signal Handler
// ──────────────────────────────────────────────────────────────
std::unique_ptr<EpollServer>  g_server;
std::unique_ptr<MmapWriter>   g_writer;

void shutdownHandler(int signum) {
    std::cout << "\n[ENGINE] Signal " << signum << " — shutting down..." << std::endl;
    
    if (g_writer) {
        g_writer->sync();
        std::cout << "[ENGINE] Flushed " << g_writer->entriesWritten()
                  << " entries (" << g_writer->bytesWritten() / 1024
                  << " KB) to disk." << std::endl;
    }
    
    if (g_server) {
        g_server->stop();
    }
    
    std::exit(0);
}

// ──────────────────────────────────────────────────────────────
// Data Handler — بيشغّل على كل chunk تيجي من الـ Node.js Proxy
// ──────────────────────────────────────────────────────────────
void onTrafficData(int fd, const char* data, size_t len) {
    // هنا بنكتب الـ data على disk بـ mmap
    // مفيش blocking، مفيش thread pool، مفيش copy للـ Kernel
    bool written = g_writer->write(data, len);
    
    if (!written) {
        std::cerr << "[ENGINE] Write failed — file might be full!" << std::endl;
    }
    
    // Stats كل 10,000 entry
    uint64_t count = g_writer->entriesWritten();
    if (count % 10000 == 0 && count > 0) {
        std::cout << "[ENGINE] 📊 Entries: " << count
                  << " | Written: " << g_writer->bytesWritten() / (1024 * 1024)
                  << " MB" << std::endl;
    }
}

// ──────────────────────────────────────────────────────────────
// main
// ──────────────────────────────────────────────────────────────
int main() {
    std::cout << "╔══════════════════════════════════════════════╗" << std::endl;
    std::cout << "║   🕰️  Time Machine Proxy — C++ Engine        ║" << std::endl;
    std::cout << "║   epoll + mmap | Zero-Blocking I/O           ║" << std::endl;
    std::cout << "╚══════════════════════════════════════════════╝" << std::endl;
    
    // Signal handlers
    signal(SIGINT,  shutdownHandler);
    signal(SIGTERM, shutdownHandler);
    
    try {
        // ────────────────────────────────────────
        // إنشاء الـ log directory
        // ────────────────────────────────────────
        std::filesystem::create_directories(LOG_DIR);
        
        // ────────────────────────────────────────
        // إنشاء الـ MmapWriter
        // ────────────────────────────────────────
        g_writer = std::make_unique<MmapWriter>(TRAFFIC_FILE);
        std::cout << "[ENGINE] MmapWriter ready: " << TRAFFIC_FILE << std::endl;
        
        // ────────────────────────────────────────
        // إنشاء الـ EpollServer
        // ────────────────────────────────────────
        g_server = std::make_unique<EpollServer>(ENGINE_PORT);
        g_server->onData(onTrafficData);
        
        std::cout << "[ENGINE] Listening on port " << ENGINE_PORT << std::endl;
        std::cout << "[ENGINE] Ready to receive shadow traffic..." << std::endl;
        
        g_server->start(); // Blocking — event loop
        
    } catch (const std::exception& e) {
        std::cerr << "[FATAL] " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
```

---

# 10. بناء الـ Project وربطه بـ Node.js

## Compile الـ Engine الكامل

```bash
cd cpp-engine

# Compile بكل الـ files
g++ -std=c++17 -O2 -Wall \
    -o bin/engine \
    src/main_engine.cpp \
    src/epoll_server.cpp \
    src/mmap_writer.cpp

# شغّل
./bin/engine
```

## تحديث الـ Node.js Proxy — إرسال Shadow Traffic للـ C++ Engine

```javascript
// node-proxy/src/shadow.js — النسخة الجديدة
// بدل ما نبعت HTTP request للـ Shadow Server
// بنبعت raw bytes للـ C++ Engine عبر TCP

require('dotenv').config();
const net = require('net'); // الـ built-in TCP module في Node.js

const ENGINE_HOST = process.env.ENGINE_HOST || 'localhost';
const ENGINE_PORT = parseInt(process.env.ENGINE_PORT || '9500');

// =====================================================
// Connection Pool — عشان ما نعملش connection جديدة
// مع كل request
// =====================================================
// في production، هنستبدل ده بـ Unix Domain Socket (Sprint 4)
// بس دلوقتي TCP كافي للـ testing

let engineSocket = null;
let isConnecting = false;
const pendingData = [];

function connectToEngine() {
    if (isConnecting || engineSocket) return;
    isConnecting = true;
    
    const socket = net.createConnection(ENGINE_PORT, ENGINE_HOST);
    
    socket.on('connect', () => {
        isConnecting = false;
        engineSocket = socket;
        console.log(`[SHADOW] Connected to C++ Engine on port ${ENGINE_PORT}`);
        
        // ابعت الـ data اللي كانت waiting
        while (pendingData.length > 0) {
            const data = pendingData.shift();
            engineSocket.write(data);
        }
    });
    
    socket.on('error', (err) => {
        isConnecting = false;
        engineSocket = null;
        console.error(`[SHADOW] Engine connection error: ${err.message}`);
    });
    
    socket.on('close', () => {
        engineSocket = null;
        console.warn('[SHADOW] Engine connection closed. Reconnecting...');
        // حاول تتوصّل تاني بعد ثانية
        setTimeout(connectToEngine, 1000);
    });
}

// ابدأ الـ connection لما الـ module يتحمّل
connectToEngine();

/**
 * بيبعت shadow data للـ C++ Engine
 * @param {object} req - Express request object
 * @param {Buffer} body - Request body
 */
function shadowToEngine(req, body) {
    // بنبني payload بسيط نبعته للـ Engine
    // في Sprint 4 هنعمل binary protocol أحسن
    const payload = JSON.stringify({
        ts: Date.now(),
        method: req.method,
        url: req.url,
        headers: {
            'content-type': req.headers['content-type'] || '',
            'user-agent': req.headers['user-agent'] || '',
        },
        bodyLength: body ? body.length : 0,
    }) + '\n'; // newline كـ delimiter

    const buffer = Buffer.from(payload);
    
    if (engineSocket && !engineSocket.destroyed) {
        // Fire & Forget — مش بنستنى acknowledgment
        engineSocket.write(buffer);
    } else {
        // حفظ في الـ pending queue لما الـ connection ترجع
        if (pendingData.length < 1000) { // max 1000 pending
            pendingData.push(buffer);
        }
        // حاول تتوصّل لو مش بتحاول
        connectToEngine();
    }
}

module.exports = { shadowToEngine };
```

## تحديث `proxy.js` عشان يستخدم الـ Engine

```javascript
// في node-proxy/src/proxy.js — غيّر الـ import ده:
const { shadowRequest } = require('./shadow');

// يبقى:
const { shadowToEngine } = require('./shadow');

// وفي الـ middleware:
// shadowRequest(SHADOW_URL, req, body);
// يبقى:
shadowToEngine(req, body);
```

---

# 11. ✅ Sprint 2 Checkpoint الشامل

## إعداد بيئة الـ Testing

```bash
# Terminal 1 — C++ Engine
cd cpp-engine
./bin/engine

# Terminal 2 — Original Server (v1)
cd node-proxy
PORT=4000 SERVER_NAME="Original v1" node test/target-server.js

# Terminal 3 — Node.js Proxy
cd node-proxy
node src/proxy.js
```

---

## Test 1 — الـ C++ Engine بيشتغل ويقبل connections

```bash
# تأكد إن الـ engine شغّال
lsof -i :9500 | grep engine

# تست مباشر بـ netcat
echo '{"method":"GET","url":"/test","ts":12345}' | nc localhost 9500

# في terminal الـ engine المفروض تشوف:
# [EPOLL] New connection: fd=5 from 127.0.0.1
# [ENGINE] Entries: 1 | Written: 0 MB
```

---

## Test 2 — الـ mmap بتكتب على disk

```bash
# بعد Test 1، شوف الملف اتعمل
ls -lh cpp-engine/logs/traffic.bin
# المفروض تشوفه 256MB (حجم الـ mmap)

# اقرأ أول bytes منه (بعد الـ EntryHeader)
xxd cpp-engine/logs/traffic.bin | head -20
# هتشوف الـ bytes بتاعت الـ JSON اللي بعتته
```

---

## Test 3 — End-to-End Flow

```bash
# ابعت request للـ Node.js Proxy
curl -X POST http://localhost:3000/api/data \
  -H "Content-Type: application/json" \
  -d '{"user": "ahmed", "test": "sprint2_complete", "amount": 999}'
```

**المفروض تشوف في الـ terminals:**

```
# Terminal 1 (C++ Engine):
[EPOLL] New connection: fd=5 from 127.0.0.1
[DATA] fd=5 bytes=128

# Terminal 2 (Original v1):
[Original v1] 2024-01-15T... | POST /api/data

# Terminal 3 (Proxy):
[PROXY] POST /api/data → http://localhost:4000
[PROXY] ✅ 200 /api/data (51ms)
```

---

## Test 4 — Performance: الـ mmap مقابل writeFileSync

بنعمل benchmark بسيط نقارن فيه:

```javascript
// node-proxy/test/benchmark.js
const fs = require('fs');
const net = require('net');

const ITERATIONS = 100_000;
const TEST_DATA = Buffer.from(JSON.stringify({
    method: 'POST',
    url: '/api/data',
    body: 'x'.repeat(200) // 200 bytes body
}));

// ─────────────────────────────────────────
// Test 1: writeFileSync (الطريقة الساذجة)
// ─────────────────────────────────────────
console.log('\n📊 Test 1: writeFileSync');
const start1 = process.hrtime.bigint();

for (let i = 0; i < ITERATIONS; i++) {
    fs.writeFileSync('/tmp/test_sync.log', TEST_DATA, { flag: 'a' });
}

const end1 = process.hrtime.bigint();
const duration1 = Number(end1 - start1) / 1_000_000;
console.log(`${ITERATIONS} writes: ${duration1.toFixed(2)}ms`);
console.log(`Throughput: ${(ITERATIONS / duration1 * 1000).toFixed(0)} writes/sec`);

// ─────────────────────────────────────────
// Test 2: TCP to C++ Engine (mmap)
// ─────────────────────────────────────────
console.log('\n📊 Test 2: C++ Engine (mmap via TCP)');

const socket = net.createConnection(9500, 'localhost', () => {
    const start2 = process.hrtime.bigint();
    let sent = 0;
    
    function sendNext() {
        if (sent >= ITERATIONS) {
            const end2 = process.hrtime.bigint();
            const duration2 = Number(end2 - start2) / 1_000_000;
            console.log(`${ITERATIONS} writes: ${duration2.toFixed(2)}ms`);
            console.log(`Throughput: ${(ITERATIONS / duration2 * 1000).toFixed(0)} writes/sec`);
            socket.destroy();
            return;
        }
        socket.write(TEST_DATA, sendNext);
        sent++;
    }
    
    sendNext();
});
```

```bash
node test/benchmark.js
```

**النتيجة المتوقعة على SSD:**

```
📊 Test 1: writeFileSync
100000 writes: ~8000ms
Throughput: ~12,500 writes/sec   ← البطيء

📊 Test 2: C++ Engine (mmap via TCP)
100000 writes: ~800ms
Throughput: ~125,000 writes/sec  ← 10x أسرع!
```

---

## Test 5 — تأكيد إن الـ epoll بيتعامل مع connections كتيرة

```bash
# شغّل 50 connection في وقت واحد
for i in {1..50}; do
    (echo "concurrent_test_$i" | nc localhost 9500) &
done
wait

# في terminal الـ Engine المفروض تشوف 50 connection
# بتتقبل وتتحل في وقت واحد — مش تسلسلي!
```

---

# 12. ملخص Sprint 2 وما جاي

## اللي اتعلمته في Sprint 2

```mermaid
mindmap
  root((Sprint 2))
    C++ Basics
      Static Typing
      Classes & RAII
      Destructors
      Compilation
    TCP Sockets
      socket()
      bind()
      listen()
      accept()
      read() / write()
    Non-Blocking I/O
      O_NONBLOCK
      EAGAIN / EWOULDBLOCK
      fcntl()
    epoll
      epoll_create1()
      epoll_ctl()
      epoll_wait()
      Event Loop
    mmap
      Virtual Memory
      Page Cache
      Page Faults
      Zero-Copy Writes
      msync()
    Architecture
      C++ Engine
      Node.js + C++ Integration
      TCP-based IPC
```

## الـ CV Bullet Points بعد Sprint 2

```
✅ Developed a high-performance C++ TCP server using Linux epoll for
   non-blocking I/O multiplexing, capable of handling 50,000+ concurrent
   connections on a single thread with zero thread-per-connection overhead.

✅ Implemented a zero-copy disk logging system using Linux mmap
   (memory-mapped files), achieving 10x throughput improvement over
   standard file I/O by leveraging the kernel page cache directly,
   eliminating user-kernel space data copies.
```

## السؤال اللي المفروض تعرف تجاوب عليه دلوقتي

**"فرّق بين `epoll` وـ`select()` وليه اخترت `epoll`؟"**

> **`select()`:** في كل call بتعمل copy للـ FD set من user space للـ kernel وبعدين copy تاني ترجع. الـ complexity O(n) لكل call. محدود بـ FD_SETSIZE (1024 غالباً).
>
> **`epoll`:** بتسجّل الـ FDs مرة واحدة بـ `epoll_ctl()`. الـ kernel بيدير Interest Table في الـ kernel space من غير copy. `epoll_wait()` بيرجع بس الـ FDs الجاهزة — O(1) بالنسبة لعدد الـ connections الكلي. مفيش limit على عدد الـ FDs.
>
> **اخترت `epoll` لأن:**
> 1. المشروع محتاج يتعامل مع حجم traffic عالي
> 2. الـ O(1) event detection بدل O(n) ضروري على 50k+ connections
> 3. مفيش limit على connections زي `select()`

---

**"ليه `mmap` وليه مش `write()`؟"**

> `write()` بيعمل data copy من user space للـ kernel page cache — ده overhead في كل call. مع 50k RPS، الـ copy overhead بيتراكم ويأثر على الـ latency.
>
> `mmap` بتخلي الـ application يشتغل مباشرة على الـ kernel page cache — نفس الـ physical pages. لما بتعمل `memcpy` في الـ mmap region، أنت بتكتب في الـ page cache مباشرة. الـ Kernel بيدبّر الكتابة على الـ physical disk في الخلفية (writeback).
>
> النتيجة: zero-copy writes، zero-blocking I/O، والـ throughput بتاعنا بقى 10x أحسن في الـ benchmark.

---

## خريطة Sprint 3 — تشويق 🔥

في Sprint 3 هتتعلم:

```mermaid
graph LR
    A["OS Tuning<br/>ulimit & sysctl<br/>بتخلي الـ OS يدعم<br/>50k+ connections"] --> B["Log Rotation<br/>(Bash)<br/>بتدوّر الـ 256MB mmap files<br/>بدون وقف السيرفر"]
    B --> C["Python Replay Engine<br/>asyncio & aiohttp<br/>بيعيد تشغيل الـ recorded traffic<br/>بـ 10k RPS على الـ Shadow Server"]

    style A fill:#322659,color:#fff
    style B fill:#3d2214,color:#fff
    style C fill:#1c4532,color:#fff
```

---

*Sprint 2 ✅ — لما تخلّص الـ Checkpoints وتشوف الـ 10x speedup، قولي وابدأ Sprint 3! 🚀*
