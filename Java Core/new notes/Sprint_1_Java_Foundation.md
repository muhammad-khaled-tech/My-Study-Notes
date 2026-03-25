# 🚀 Sprint 1: من الـ Oak لحد الـ JVM — رحلة أعمق من الـ PDF

> **ملحوظة للـ Mentee:** أنت عندك C, C++, JavaScript, OOP. هنستخدم ده كـ leverage مش كـ crutch. هنقارن، هنعمّق، وهنوصل لـ Architect Level من أول Sprint.

---

## 📍 خريطة الـ Sprint

```
Module A → Java History & The "Why" (ليه Java اتخلقت أصلاً)
Module B → OOP Deep Dive + JVM Architecture + أول برنامج تحت المجهر
```

---

# 🏛️ الجزء الأول: ليه Java اتخلقت أصلاً؟

## 😤 المشكلة الساذجة (The Naive Problem)

تخيّل إنك في 1991 بتبني software لـ microwave oven. كتبت الكود بـ C++:

```cpp
// C++ code compiled for Intel 8051 (microwave controller)
void heatFood(int seconds) {
    PORTA = 0x01; // turn on magnetron — hardware specific!
    delay(seconds);
    PORTA = 0x00;
}
```

المشكلة؟ الـ microwave التاني بيشتغل بـ Motorola 68000. لازم تكتب كل حاجة من الأول.  
كل CPU → compiler جديد → كود جديد → فلوس كتير + وقت ضايع.

> **[DEEP-DIVE]**
> ده اللي بيسمّوه **"Platform Dependency Problem"**. في C/C++، الـ compiler بيترجم الكود مباشرةً لـ **native machine code** خاص بالـ CPU. الـ `.exe` على Windows مش هيشتغل على Linux لأن الـ binary instructions مختلفة تماماً.

---

## ☕ الحل: Java's Magic — الـ Bytecode

بدل ما نترجم لـ machine code مباشرةً، Java بتترجم لـ **Bytecode** — لغة وسيطة مش خاصة بأي CPU. بعدين الـ **JVM** (Java Virtual Machine) هي اللي بتشغّل الـ Bytecode ده على أي platform.

```
┌─────────────────────────────────────────────────────────┐
│                   Java Source Code                       │
│                    Example.java                          │
└──────────────────────────┬──────────────────────────────┘
                           │  javac (Java Compiler)
                           ▼
┌─────────────────────────────────────────────────────────┐
│                     Bytecode                             │
│                   Example.class                          │
│         (Platform-Independent Instructions)              │
└──────┬───────────────────┬───────────────────┬──────────┘
       │                   │                   │
       ▼                   ▼                   ▼
  JVM (Windows)      JVM (Linux)        JVM (macOS)
  Runs natively      Runs natively      Runs natively
```

**Write Once, Run Anywhere** — ده كان الـ motto اللي غيّر الدنيا.

---

## 🔍 مقارنة مع C++ و JS

| الجانب | C/C++ | JavaScript | Java |
|--------|-------|-----------|------|
| **Compilation** | Native machine code مباشرة | Interpreted في الـ browser/Node | Bytecode → JVM |
| **Portability** | ❌ مش portable | ✅ portable (بس في browser/Node) | ✅ portable (JVM على أي OS) |
| **Memory Management** | Manual (pointers, `delete`) | GC (single-threaded event loop) | GC (multi-threaded, Heap-managed) |
| **Type System** | Weakly typed (C) / Strongly typed (C++) | Dynamically typed | Statically & Strongly typed |
| **Multithreading** | OS threads manually | Single-threaded + Event Loop | Built-in `Thread` class + concurrency APIs |

> **[WARNING]**
> لو قايل "JS بيشتغل على كل حاجة"، اتنبّه! JS portable لأنه بيشتغل جوّا الـ browser أو Node.js اللي هما نفسهم native programs. Java portable لأن الـ Bytecode نفسه standard — الـ JVM هي اللي بتتكيّف.

---

## 🕰️ Timeline: تطور Java من 1991 لحد دلوقتي

```
1991 ── "Oak" project @ Sun Microsystems (James Gosling)
1995 ── Renamed to "Java", Java 1.0 released
1998 ── Java 2 (J2SE, J2EE, J2ME) — Enterprise era begins
2004 ── Java 5: Generics, Annotations, Autoboxing, Enums 🔥
2006 ── Java 6: Performance improvements
2011 ── Java 7 (Oracle acquired Sun): try-with-resources, Diamonds
2014 ── Java 8: Lambda, Stream API, Optional — REVOLUTION 🚀
2017 ── Java 9: Modules (Project Jigsaw)
2018 ── Java 11 (LTS): HTTP Client, var keyword
2021 ── Java 17 (LTS): Sealed Classes, Pattern Matching 🔥
2023 ── Java 21 (LTS): Virtual Threads (Project Loom) 🚀🚀
```

> **[DEEP-DIVE]**
> دلوقتي Java بتطلع release كل 6 شهور. LTS (Long-Term Support) releases هي اللي الشركات بتستخدمها في Production. في 2024، معظم الـ enterprises على Java 17 أو 21.

---

## ⚙️ الـ Java Buzzwords — بس مش kayf, بالـ "WHY"

الـ PDF بيذكر 11 buzzword. تعالى نشرحهم بطريقة معمارية:

| Buzzword | الـ "Why" الحقيقي |
|----------|------------------|
| **Simple** | Syntax شبيه C++، لكن بدون pointers، بدون multiple inheritance، بدون manual memory |
| **Secure** | Bytecode verifier + Security Manager + Sandbox — مش أي كود يقدر يوصل للـ OS مباشرة |
| **Portable** | الـ Bytecode + JVM specification موحّدة — IEEE 754 للـ floating point بيتطبّق على كل JVM |
| **Object-Oriented** | كل حاجة object (إلا الـ primitives) — مش زي C++ اللي بيقدر يمشي procedural |
| **Robust** | Strongly typed + Exception Handling + No pointers = تقليل الـ runtime crashes |
| **Multithreaded** | Built-in في اللغة نفسها، مش library خارجية زي pthreads في C |
| **Architecture-Neutral** | int دايماً 32-bit في Java، مش زي C اللي int حجمه بيتغيّر حسب الـ platform |
| **Interpreted + High Performance** | JIT Compiler بيحوّل الـ hot bytecode لـ native code — بيجمع الاتنين |
| **Distributed** | Built-in TCP/IP + RMI (Remote Method Invocation) support |
| **Dynamic** | Runtime type info (Reflection API) — بتقدر تعرف نوع الـ object وانت شايل reference عادي |

---

# 🧠 الجزء الثاني: JVM Architecture — تحت الكبّوت

## رحلة الـ `.java` من الكود لحد الـ CPU

```
┌──────────────────────────────────────────────────────────────┐
│                         JVM                                   │
│                                                               │
│  ┌─────────────┐    ┌──────────────────────────────────────┐ │
│  │ Class Loader│    │         Runtime Data Areas            │ │
│  │  Subsystem  │    │                                       │ │
│  │             │    │  ┌─────────┐  ┌──────────────────┐   │ │
│  │ 1. Bootstrap│    │  │  Stack  │  │       Heap        │   │ │
│  │ 2. Extension│    │  │ (per    │  │  ┌────────────┐   │   │ │
│  │ 3. App      │    │  │ thread) │  │  │  Young Gen │   │   │ │
│  └──────┬──────┘    │  │         │  │  │  (Eden +   │   │   │ │
│         │           │  │ Frames: │  │  │  Survivor) │   │   │ │
│         ▼           │  │ -locals │  │  ├────────────┤   │   │ │
│  ┌─────────────┐    │  │ -operand│  │  │  Old Gen   │   │   │ │
│  │  Bytecode   │    │  │  stack  │  │  │(Tenured)   │   │   │ │
│  │  Verifier   │    │  │ -ref to │  │  └────────────┘   │   │ │
│  └──────┬──────┘    │  │  const  │  └──────────────────┘   │ │
│         │           │  │  pool   │                           │ │
│         ▼           │  └─────────┘  ┌──────────────────┐   │ │
│  ┌─────────────┐    │               │   Metaspace       │   │ │
│  │  Execution  │    │               │ (Class metadata,  │   │ │
│  │   Engine    │    │               │  Static vars)     │   │ │
│  │             │    │               └──────────────────┘   │ │
│  │ Interpreter │    └──────────────────────────────────────┘ │
│  │ JIT Compiler│                                             │
│  │ GC          │                                             │
│  └─────────────┘                                             │
└──────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Class Loader Subsystem — مين بيجيب الكلاسات؟

الـ Class Loader بيمر بـ 3 مراحل:

```
1. LOADING     → يجيب الـ .class file من الـ disk/network ويحطه في الـ Memory
2. LINKING     → Verification (بيتحقق إن الـ bytecode سليم)
                 Preparation (بيعمل allocate للـ static variables)
                 Resolution (بيحلّ الـ symbolic references)
3. INITIALIZATION → بينفّذ الـ static initializers والـ static blocks
```

**الـ 3 أنواع من الـ Class Loaders:**

```java
// Bootstrap ClassLoader — الـ parent
// بيلوّد core Java classes (java.lang.*, java.util.*)
// مكتوب بـ C++ ومش accessible من Java code

// Extension ClassLoader (Platform في Java 9+)
// بيلوّد من $JAVA_HOME/lib/ext

// Application ClassLoader
// بيلوّد الـ project classes (classpath بتاعك)
ClassLoader cl = MyClass.class.getClassLoader();
System.out.println(cl); // sun.misc.Launcher$AppClassLoader
```

> **[DEEP-DIVE]**
> الـ Class Loader بيشتغل بـ **Parent Delegation Model**: لما تطلب class، هيطلع لـ parent أول. لو الـ Bootstrap مش لاقيها، بينزل للـ Extension، بعدين للـ App. ده بيمنع أي حد يـ override الـ core Java classes.

---

## 🧱 Runtime Data Areas — الـ Memory Model

### Stack vs Heap — الفرق الجوهري

```java
public class MemoryDemo {
    // هذا الـ field اتخزن في الـ Heap (جزء من الـ object)
    private int instanceVar = 10;

    public void method() {
        int localVar = 5;           // ← Stack (primitive local variable)
        String name = "Ahmed";      // ← Stack (reference) + Heap (String object)
        Object obj = new Object();  // ← Stack (reference) + Heap (Object instance)

        // لما method بتخلّص:
        // localVar اتمسح أوتوماتيكلي من الـ Stack
        // الـ objects في الـ Heap → GC هيمسحهم لما مفيش references
    }
}
```

| منطقة الـ Memory | بيتخزن فيها إيه | في C++ المقابل |
|-----------------|----------------|---------------|
| **Stack** | Local variables, method calls, references | Stack frames (نفس الفكرة) |
| **Heap - Young Gen** | الـ new objects (حديثة) | `new` على الـ heap |
| **Heap - Old Gen** | Objects عاشت طويل وبقت "tenured" | لا يوجد مقابل — C++ مش عنده GC |
| **Metaspace** | Class metadata, static variables (Java 8+) | `.bss` / `.data` segments |
| **PC Register** | عنوان الـ instruction الجاية لكل thread | Instruction Pointer Register |

### مقارنة حاسمة مع C++

```cpp
// C++ — أنت المسؤول عن كل حاجة
void cppFunction() {
    int* ptr = new int(42); // allocated on heap
    // لو نسيت السطر ده → MEMORY LEAK إلى الأبد!
    delete ptr;
}

// Java — الـ GC مسؤول
void javaFunction() {
    Integer num = new Integer(42); // allocated on heap
    // لما num تخرج من الـ scope → GC هيشيلها
    // مفيش delete، مفيش memory leaks (نظرياً)
}
```

> **[WARNING]**
> "نظرياً" لأن في Java برضو ممكن يحصل memory leaks! لو احتفظت بـ references في static collections وما طلعتهاش، الـ GC مش هيمسحها. الـ GC بيمسح بس الـ unreachable objects.

---

## ♻️ Garbage Collector — الـ GC الحقيقي مش الـ Buzzword

الـ GC في Java بيشتغل على فكرة **Generational Hypothesis**: معظم الـ objects بتموت صغيّرة.

```
الـ Heap:
┌─────────────────────────────────────────────────────┐
│                    Young Generation                  │
│  ┌──────────────┐  ┌────────────┐  ┌─────────────┐  │
│  │     Eden     │  │ Survivor 0 │  │ Survivor 1  │  │
│  │  (new objs)  │  │   (S0)     │  │   (S1)      │  │
│  └──────────────┘  └────────────┘  └─────────────┘  │
│    Minor GC هنا (سريع جداً)                          │
├─────────────────────────────────────────────────────┤
│                    Old Generation                    │
│  Objects عاشت كتير (survived 15+ GC cycles)         │
│    Major GC / Full GC هنا (أبطأ)                    │
└─────────────────────────────────────────────────────┘
```

**خطوات الـ Minor GC:**

```
1. Object اتعمل new → اترمى في Eden
2. Eden اتملأ → Minor GC بدأ
3. الـ live objects من Eden → Survivor 0
4. Minor GC تاني → الناجين من S0 → S1 (age++)
5. لما age > 15 → الـ object يتنقل لـ Old Generation
6. Old Generation تملأ → Major GC (Stop-The-World) 😱
```

> **[DEEP-DIVE]**
> الـ **Stop-The-World (STW)** event هو لما الـ GC بيوقف كل الـ application threads عشان يعمل collection. ده السبب في الـ latency spikes في الـ Java apps. الـ GC algorithms الحديثة (G1GC, ZGC, Shenandoah) بيحاولوا يقللوا الـ STW pause لأقل من 1ms.

**أنواع الـ GC في Java:**

| GC | الاستخدام | الـ Pause |
|----|----------|---------|
| **Serial GC** | Single-threaded apps, small heaps | عالي |
| **Parallel GC** | Throughput-focused (default قبل Java 9) | متوسط |
| **G1GC** | الـ default من Java 9+ | منخفض ومتوقع |
| **ZGC** | Ultra-low latency (Java 15+ production) | < 1ms |
| **Shenandoah** | Low pause (Red Hat's contribution) | < 1ms |

---

## 🔥 JIT Compiler — ليه Java بقت بتنافس C++

```
أول مرة الـ method بتتنفّذ → Interpreter (بطيء)
                ↓
بعد عدد معين من المرات (threshold) → JIT Compiler بيلاقيها "hot"
                ↓
بيترجمها لـ native machine code وبيخزّنها في الـ Code Cache
                ↓
المرة الجاية → بيشتغل الـ native code مباشرة (سريع جداً!)
```

> **[DEEP-DIVE]**
> ده اللي بيخلّي الـ Java applications بتكون **أسرع لو شغّالة فترة طويلة** (Warm-up). الـ JIT بيعمل optimizations مش حتى الـ C++ compiler بيعملها — زي **Escape Analysis** (لو object مش هيخرج من الـ method، بيحطّه على الـ Stack مش الـ Heap) و **Inline Caching**.

---

# 🎯 الجزء الثالث: OOP في Java — مش بس تعريفات

## الـ 3 Pillars + الـ 4th الـ مخفي

الـ PDF بيذكر: Encapsulation, Inheritance, Polymorphism. لكن في الـ interviews بيسألوا عن **Abstraction** كـ 4th pillar.

---

## 🔒 Encapsulation — الـ Information Hiding

```java
// ❌ الطريقة الساذجة — public fields (violation of encapsulation)
class BadBankAccount {
    public double balance; // أي حد يغيّرها زي ما يعجبه!
    public String owner;
}

// ✅ الطريقة الصح
public class BankAccount {
    private double balance;   // ← hidden
    private String owner;     // ← hidden
    private final String accountId; // ← immutable after construction

    public BankAccount(String owner, String accountId) {
        this.owner = owner;
        this.accountId = accountId;
        this.balance = 0.0;
    }

    // Controlled access through methods
    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive: " + amount);
        }
        this.balance += amount;
    }

    public boolean withdraw(double amount) {
        if (amount <= 0 || amount > balance) {
            return false;
        }
        this.balance -= amount;
        return true;
    }

    public double getBalance() { return balance; } // Read-only access
    public String getOwner()   { return owner; }
    public String getAccountId() { return accountId; }
}
```

**Design Pattern Connection:** الـ Encapsulation هي الأساس لـ **Builder Pattern** وـ **Facade Pattern**. أنت بتخبّي الـ complexity وراء interface نظيف.

---

## 🧬 Inheritance — الهرم الوراثي

```java
// Base class (Superclass)
public class Animal {
    protected String name;  // protected → accessible في الـ subclasses
    protected int age;

    public Animal(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public void eat() {
        System.out.println(name + " is eating");
    }

    // بيتعمل override في الـ subclasses
    public String makeSound() {
        return "...";
    }

    @Override
    public String toString() {
        return "Animal{name=" + name + ", age=" + age + "}";
    }
}

// Subclass
public class Dog extends Animal {
    private String breed;

    public Dog(String name, int age, String breed) {
        super(name, age);  // ← استدعاء الـ parent constructor أولاً (إجباري)
        this.breed = breed;
    }

    @Override  // ← الـ annotation ده بيحميك من typos
    public String makeSound() {
        return "Woof!";
    }

    public void fetch() {
        System.out.println(name + " is fetching!");
    }
}
```

> **[WARNING]**
> Java بتدعم **Single Inheritance فقط** للـ classes (مش زي C++ اللي بيدعم multiple inheritance). ليه؟ عشان يتجنبوا **"Diamond Problem"**. لو Class C يـ extend من A و B، وكلهم عندهم نفس الـ method، مين اللي هيتنفّذ؟ Java حلّت المشكلة دي بـ **Interfaces** (هنتكلم عنها في Sprint 4).

---

## 🎭 Polymorphism — الوجوه المتعددة

الأهم من أنواع الـ Polymorphism في Java:

### Runtime Polymorphism (Dynamic Dispatch)

```java
public class PolymorphismDemo {
    public static void main(String[] args) {
        // الـ reference نوعه Animal، لكن الـ object الحقيقي Dog
        Animal animal1 = new Dog("Rex", 3, "German Shepherd");
        Animal animal2 = new Cat("Whiskers", 2);
        Animal animal3 = new Animal("Generic", 1);

        Animal[] zoo = {animal1, animal2, animal3};

        // Runtime Polymorphism — JVM بيقرر أي makeSound() يتنفّذ وقت الـ runtime
        for (Animal a : zoo) {
            System.out.println(a.name + " says: " + a.makeSound());
        }
        // Output:
        // Rex says: Woof!
        // Whiskers says: Meow!
        // Generic says: ...
    }
}
```

**تحت الكبّوت — ازاي الـ JVM بيعرف أي method يتنفّذ؟**

```
كل Object في الـ Heap عنده pointer لـ:
┌─────────────────┐
│   Object Header │
│  ┌────────────┐ │
│  │  Mark Word │ │  (GC info, lock state, hash code)
│  ├────────────┤ │
│  │ Class Ptr  │ ──────→ Method Table (vtable) في الـ Metaspace
│  └────────────┘ │            ↓
│   Object Fields │        makeSound() → Dog.makeSound() ✅
└─────────────────┘
```

> **[DEEP-DIVE]**
> ده اللي بيسمّوه **Virtual Method Table (vtable)**. كل class عنده vtable في الـ Metaspace بيحتوي على pointers للـ methods الفعلية. لما بتعمل `animal.makeSound()`، الـ JVM بيجري على الـ vtable بتاع الـ actual type (مش الـ declared type) ويجيب الـ correct method. ده overhead بسيط جداً بسبب الـ JIT optimization.

---

## 🎨 Abstraction — الـ 4th Pillar

```java
// Abstract Class — بتعرّف contract + shared implementation
public abstract class Shape {
    protected String color;

    public Shape(String color) {
        this.color = color;
    }

    // Abstract method — لازم كل subclass تـ implement
    public abstract double calculateArea();

    // Concrete method — shared behavior
    public void displayInfo() {
        System.out.printf("Shape: %s, Color: %s, Area: %.2f%n",
            getClass().getSimpleName(), color, calculateArea());
    }
}

public class Circle extends Shape {
    private double radius;

    public Circle(String color, double radius) {
        super(color);
        this.radius = radius;
    }

    @Override
    public double calculateArea() {
        return Math.PI * radius * radius;
    }
}

public class Rectangle extends Shape {
    private double width, height;

    public Rectangle(String color, double width, double height) {
        super(color);
        this.width = width;
        this.height = height;
    }

    @Override
    public double calculateArea() {
        return width * height;
    }
}
```

---

# 💻 الجزء الرابع: أول برنامج Java — سطر بسطر تحت المجهر

```java
/*
 * هذا multiline comment — الـ compiler بيتجاهله تماماً
 * اسم الملف لازم يتطابق مع اسم الـ public class: Example.java
 */
public class Example {

    // نقطة الدخول لأي Java application
    // الـ JVM بتدور على الـ method دي بالـ signature ده بالضبط
    public static void main(String[] args) {

        // System   → class موجود في java.lang (بتتـ import تلقائياً)
        // out      → static field من نوع PrintStream
        // println  → method على الـ PrintStream object
        System.out.println("Hello, Architect!");
    }
}
```

**تفصيل كل keyword:**

| الـ Keyword | الـ "Why" |
|------------|----------|
| `public` | الـ JVM بتتشغّل من خارج الـ class، لازم تشوفها |
| `static` | الـ JVM بتستدعيها قبل ما يتعمل أي object — مفيش instance |
| `void` | الـ JVM مش بتستخدم أي return value من main |
| `String[] args` | Command-line arguments — `java MyApp arg1 arg2` |

---

## ⚙️ رحلة الكود من `.java` لـ Output

```
1. كتبت: Example.java
         ↓
2. javac Example.java
         ↓
3. اتعمل: Example.class (Bytecode)
         ↓
4. java Example
         ↓
5. الـ JVM بدأت:
   a) Bootstrap ClassLoader شيل java.lang.* من الـ JDK
   b) App ClassLoader شيل Example.class
   c) Bytecode Verifier تحقق من سلامة الـ bytecode
   d) JVM دوّرت على main(String[] args)
   e) اتعمل Stack Frame لـ main
   f) System.out.println نفّذت → كتبت على الـ stdout
   g) main خلّصت → Stack Frame اتشال
   h) لو مفيش threads تانية → JVM اتقفلت
```

---

## 🗝️ الـ Java Keywords (61 keyword)

الأهم إنك تفهم **التصنيفات**، مش تحفظ الكل:

```
Access Modifiers:    public, protected, private, (default)
Class-related:       class, abstract, interface, extends, implements, enum
Method-related:      void, return, static, final, native, synchronized
OOP:                 new, this, super, instanceof
Primitive Types:     byte, short, int, long, float, double, char, boolean
Control Flow:        if, else, switch, case, default, for, while, do, break, continue
Exception Handling:  try, catch, finally, throw, throws
Others:              import, package, var (Java 10+)
Reserved (unused):   goto, const
```

> **[DEEP-DIVE]**
> في Java 10 اتضاف `var` كـ **local variable type inference**:
> ```java
> var list = new ArrayList<String>(); // compiler بيـ infer النوع
> var name = "Ahmed";                  // نوعه String
> ```
> مهم: `var` مش keyword بالمعنى التقليدي — ممكن تستخدمه كـ variable name في الكود القديم (مش recommended).

---

# 🏋️ Practical Exercise (PE)

<details>
<summary>💻 PE: بناء نظام إدارة موظفين بسيط — اضغط للتفاصيل</summary>

## 🎯 السيناريو

أنت بتبني HR system بسيط. المطلوب:

1. Abstract class `Employee` بيها: `name`, `id`, `baseSalary` وـ abstract method `calculateBonus()`
2. Subclass `SeniorEngineer` بتحسب الـ bonus = 30% من الـ baseSalary
3. Subclass `JuniorEngineer` بتحسب الـ bonus = 10% من الـ baseSalary
4. Method `printPayslip()` في الـ base class بتطبع التفاصيل
5. في الـ main، عمل array من `Employee` references وطبع الـ payslip لكل واحد

## ✅ الـ Architect Solution

```java
// Employee.java
public abstract class Employee {
    private final String id;        // immutable — ID لا يتغير
    protected String name;
    protected double baseSalary;

    public Employee(String id, String name, double baseSalary) {
        if (baseSalary < 0) {
            throw new IllegalArgumentException("Salary cannot be negative");
        }
        this.id = id;
        this.name = name;
        this.baseSalary = baseSalary;
    }

    // Abstract — كل نوع موظف بيحدد الـ bonus بتاعه
    public abstract double calculateBonus();

    // Template Method Pattern 🏛️
    public final void printPayslip() {
        System.out.println("=".repeat(40));
        System.out.printf("Employee: %s (ID: %s)%n", name, id);
        System.out.printf("Role: %s%n", getClass().getSimpleName());
        System.out.printf("Base Salary:  EGP %.2f%n", baseSalary);
        System.out.printf("Bonus:        EGP %.2f%n", calculateBonus());
        System.out.printf("Total:        EGP %.2f%n", baseSalary + calculateBonus());
        System.out.println("=".repeat(40));
    }

    public String getId() { return id; }
}

// SeniorEngineer.java
public class SeniorEngineer extends Employee {
    private static final double BONUS_RATE = 0.30;

    public SeniorEngineer(String id, String name, double baseSalary) {
        super(id, name, baseSalary);
    }

    @Override
    public double calculateBonus() {
        return baseSalary * BONUS_RATE;
    }
}

// JuniorEngineer.java
public class JuniorEngineer extends Employee {
    private static final double BONUS_RATE = 0.10;

    public JuniorEngineer(String id, String name, double baseSalary) {
        super(id, name, baseSalary);
    }

    @Override
    public double calculateBonus() {
        return baseSalary * BONUS_RATE;
    }
}

// HRSystem.java
public class HRSystem {
    public static void main(String[] args) {
        // Runtime Polymorphism في الـ action
        Employee[] team = {
            new SeniorEngineer("EMP001", "Ahmed Hassan",   25000),
            new JuniorEngineer("EMP002", "Sara Mohamed",   12000),
            new SeniorEngineer("EMP003", "Khaled Youssef", 30000),
            new JuniorEngineer("EMP004", "Nour Ali",       10000)
        };

        double totalPayroll = 0;
        for (Employee emp : team) {
            emp.printPayslip();
            totalPayroll += emp.baseSalary + emp.calculateBonus();
        }

        System.out.printf("%nTotal Company Payroll: EGP %.2f%n", totalPayroll);
    }
}
```

## 🏛️ الـ Design Pattern المستخدم

**Template Method Pattern** (GoF Behavioral):
- `printPayslip()` هو الـ template — بيحدد الـ structure
- `calculateBonus()` هو الـ "hook" — كل subclass بتـ override الجزء الخاص بها
- الـ `final` على `printPayslip()` بيمنع الـ subclasses من تغيير الـ structure

</details>

---

# 🎯 Interview Survival Kit — Sprint 1

<details>
<summary>🔥 الأسئلة الصعبة + الإجابات الـ Senior-Level — اضغط للتفاصيل</summary>

---

### Q1: "What is the difference between JDK, JRE, and JVM?"

**الإجابة الـ Junior:** JDK للـ development، JRE للـ running، JVM للـ execution.

**الإجابة الـ Senior:**
```
JDK (Java Development Kit)
├── JRE (Java Runtime Environment)
│   ├── JVM (Java Virtual Machine)
│   │   ├── Class Loader
│   │   ├── Bytecode Verifier
│   │   ├── Interpreter
│   │   ├── JIT Compiler
│   │   └── Garbage Collector
│   └── Java Class Libraries (java.lang, java.util, etc.)
└── Development Tools
    ├── javac (compiler)
    ├── javadoc
    ├── jdb (debugger)
    └── jconsole / jvisualvm (profiling)

ملحوظة: من Java 9+، الـ JRE standalone اتشالت. بقى في JDK فقط.
```

---

### Q2: "Is Java fully Object-Oriented?"

**الإجابة الـ Junior:** آه، كل حاجة في Java objects.

**الإجابة الـ Senior:**
لأ، Java **مش** fully OO لـ 2 أسباب:
1. **Primitive types** (int, double, char, boolean, etc.) مش objects — عندهم Wrapper classes بس (Integer, Double).
2. **Static methods and variables** مش مرتبطة بـ object instance.

لو عايز **fully OO language**، شوف Smalltalk أو Scala. Java عملت الـ compromise ده عشان **performance** — الـ primitives بيخزّنوا في الـ Stack مباشرة، أسرع بكتير من الـ Heap.

---

### Q3: "Explain the Java Memory Model and where each variable type is stored."

```java
public class MemoryModel {
    static int staticVar = 10;          // Metaspace
    int instanceVar = 20;               // Heap (جزء من الـ object)

    public void method() {
        int localVar = 30;              // Stack
        String str = "Hello";           // Stack (ref) + String Pool in Heap
        Object obj = new Object();      // Stack (ref) + Heap (object)
        Integer boxed = 127;            // Stack (ref) + Integer Cache (-128 to 127)
    }
}
```

> **Trick question follow-up:** "Is String stored on Stack or Heap?"
>
> الـ reference variable على الـ Stack. الـ String object نفسه في الـ **String Pool** (جزء من الـ Heap من Java 7+). قبل Java 7 كانت الـ String Pool في الـ PermGen.

---

### Q4: "What happens if you call `System.gc()`?"

**الإجابة الـ Junior:** بينفّذ الـ GC.

**الإجابة الـ Senior:**
`System.gc()` هو مجرد **hint** للـ JVM — مش guarantee إن الـ GC هيشتغل. الـ JVM حرة تتجاهله. في production code، استدعاء `System.gc()` manually هو **anti-pattern** لأن:
1. الـ GC has better info عن الـ heap state منك.
2. بيسبب **Stop-The-World** pause غير متوقع.
3. الـ JVM's GC heuristics optimized أحسن من أي manual intervention.

---

### Q5: "What is the difference between Overloading and Overriding?"

| | Overloading | Overriding |
|--|------------|-----------|
| **Resolution** | Compile-time (Static Dispatch) | Runtime (Dynamic Dispatch) |
| **يحصل فين** | في نفس الـ class | في الـ Subclass |
| **Method Signature** | لازم يختلف (parameters) | لازم يتطابق بالضبط |
| **Return Type** | ممكن يختلف | لازم نفسه أو Covariant |
| **@Override** | لا يُستخدم | يُستخدم (مهم جداً!) |

```java
class Calculator {
    // Overloading — نفس الاسم، parameters مختلفة
    public int add(int a, int b)          { return a + b; }
    public double add(double a, double b) { return a + b; }
    public int add(int a, int b, int c)   { return a + b + c; }
}

class ScientificCalculator extends Calculator {
    // Overriding — نفس الـ signature بالضبط
    @Override
    public int add(int a, int b) {
        System.out.println("Scientific add called");
        return super.add(a, b); // تقدر تستدعي الـ parent
    }
}
```

---

### Q6: (Hardcore) "If Java is platform-independent, why do we have different JVMs for Windows and Linux?"

**الإجابة المثالية:**
الـ Java Bytecode هو الـ platform-independent part. الـ JVM نفسها هي native program مكتوبة بـ C/C++ وـ compiled لكل OS.

```
الـ contract هو:
[Your Java Code] → [Standard Bytecode] → [Any JVM that follows the JVM Spec]

الـ JVM Spec (JSR-292) بيحدد:
- إزاي الـ bytecode instructions بتشتغل
- إزاي الـ memory management بيحصل
- إزاي الـ threading بيشتغل

Oracle JVM (HotSpot)، Amazon Corretto، Azul Zulu، GraalVM —
كلهم بيطبّقوا نفس الـ spec، فالـ bytecode بيشتغل على كلهم.
```

---

### Q7: "What is the difference between `==` and `.equals()` in Java?"

```java
String a = new String("Hello");
String b = new String("Hello");
String c = "Hello";
String d = "Hello";

System.out.println(a == b);       // false ← comparing heap addresses
System.out.println(a.equals(b));  // true  ← comparing content

System.out.println(c == d);       // true  ← BOTH from String Pool (same object!)
System.out.println(c.equals(d));  // true  ← comparing content
```

> **[WARNING]**
> ده من أشهر أسباب الـ bugs في Java. **دايماً** استخدم `.equals()` لمقارنة Objects. `==` بس للـ primitives.
>
> Exception: لما بتـ compare بـ `null`: استخدم `==` أو `Objects.equals(a, b)`.

</details>

---

# 📋 ملخص Sprint 1

```
✅ فهمنا ليه Java اتخلقت (Platform Independence Problem)
✅ فهمنا الـ Bytecode والـ JVM Architecture بالتفصيل
✅ فهمنا الـ Class Loader, Heap, Stack, GC
✅ فهمنا الـ 4 OOP Pillars بـ Java-specific implementation
✅ فهمنا أول برنامج Java سطر بسطر
✅ عندنا PE بيطبّق كل حاجة + Interview Kit

الـ Sprint الجاي → Data Types, Variables, Memory Model, Arrays (Sprint 2)
```

---

*📁 Sprint 1 — ITI Core Java Intake 46 | Dec 2025*
*🏛️ Mentor: Elite Egyptian Java Principal Architect*
