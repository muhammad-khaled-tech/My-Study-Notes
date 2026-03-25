# 🚀 Sprint 2: Data Types, Variables & Arrays — الـ Memory بالتفصيل

> **ملحوظة:** أنت عارف C/C++ — هنركّز على الفروقات الجوهرية، مش على الـ basics. كل قسم هنوصله للـ JVM internals وازاي الـ memory بتتأثر فعلاً.

---

## 📍 خريطة الـ Sprint

```
Module C → Primitive Types + Memory Model
         → Type Conversion & Casting (الـ implicit vs explicit)
         → Variables: Scope, Lifetime, Stack vs Heap
         → Arrays: 1D, 2D, Jagged Arrays تحت المجهر
```

---

# 🧱 الجزء الأول: Java's Strongly Typed System — ليه ده مهم؟

## 😤 المشكلة الساذجة

في C، الكود ده شرعي تماماً وبيتـ compile:

```c
// C — weakly typed, platform-dependent sizes
int x = 3.14;    // silent truncation → x = 3 (no error!)
printf("%d", x); // undefined behavior لو غلطت الـ format
char c = 300;    // overflow silently → c = 44
```

في Java؟ الـ compiler بيرفض الأول من السطر الأول:

```java
// Java — strongly typed, compile-time enforcement
int x = 3.14;   // ❌ COMPILE ERROR: incompatible types: possible lossy conversion
char c = 300;   // ❌ COMPILE ERROR: incompatible types
```

> 🔬 **DEEP-DIVE:**
> الـ Strong Typing في Java مش بس syntax rule — الـ Bytecode Verifier في الـ JVM بيعمل type-checking **تاني مرة** وقت الـ runtime قبل ما يشغّل أي class. ده جزء من الـ Security Model — حتى لو حد عدّل الـ `.class` file يدوياً، الـ JVM بترفضه.

---

# 🔢 الجزء الثاني: الـ 8 Primitive Types — مش مجرد حفظ

## جدول الـ Primitive Types الكامل

| النوع | الحجم | الـ Range | الـ Default | الاستخدام في الـ Production |
|-------|--------|-----------|-------------|---------------------------|
| `byte` | 8 bits | -128 to 127 | 0 | Network streams, file I/O, image processing |
| `short` | 16 bits | -32,768 to 32,767 | 0 | Embedded systems, legacy protocols |
| `int` | 32 bits | -2.1B to 2.1B | 0 | الـ default للأرقام الصحيحة |
| `long` | 64 bits | -9.2Q to 9.2Q | 0L | Timestamps, IDs (بدل int في الـ databases) |
| `float` | 32 bits | ±3.4e+38 | 0.0f | Graphics, game physics (أقل دقة) |
| `double` | 64 bits | ±1.8e+308 | 0.0 | الـ default للأرقام العشرية |
| `char` | 16 bits | '\u0000' to '\uffff' | '\u0000' | Unicode characters |
| `boolean` | ~1 bit* | true / false | false | Flags, conditions |

> 🔬 **DEEP-DIVE:**
> `boolean` حجمه "~1 bit" نظرياً بس في الـ JVM بيتخزن كـ `int` (4 bytes) في الـ local variables، وكـ `byte` (1 byte) في arrays! ده implementation detail بيتفاوت حسب الـ JVM. مفيش spec رسمية بتحدد الحجم الفعلي.

> ⚠️ **WARNING:**
> في Java، حجم `int` دايماً **32 bits** على أي platform. مش زي C اللي `int` حجمه بيتغيّر حسب الـ OS (16 أو 32 bits). ده جزء من الـ "Architecture-Neutral" promise.

---

## 🔍 Integer Types تحت الكبّوت

```java
public class IntegerDeepDive {
    public static void main(String[] args) {

        // ✅ أنواع مختلفة من الـ Integer Literals (Java 7+)
        int decimal     = 1_000_000;      // underscores للقراءة (بيتجاهلها الـ compiler)
        int octal       = 012;            // يبدأ بـ 0 → قيمته 10
        int hex         = 0xFF;           // يبدأ بـ 0x → قيمته 255
        int binary      = 0b1010_1010;    // يبدأ بـ 0b → قيمته 170

        long bigNum     = 9_223_372_036_854_775_807L; // L suffix إجباري للـ long literal

        System.out.println(decimal);  // 1000000
        System.out.println(octal);    // 10
        System.out.println(hex);      // 255
        System.out.println(binary);   // 170

        // Overflow Behavior — مهم جداً!
        int maxInt = Integer.MAX_VALUE; // 2_147_483_647
        System.out.println(maxInt + 1); // -2_147_483_648 ← OVERFLOW! مش exception
    }
}
```

> ⚠️ **WARNING:**
> الـ Integer Overflow في Java **صامت تماماً** — مش بيرمي exception. ده أشهر source للـ bugs في الأنظمة المالية. الـ solution في Java 8+:
> ```java
> int result = Math.addExact(maxInt, 1); // throws ArithmeticException on overflow ✅
> ```

---

## 🌊 Floating-Point — الـ IEEE 754 Problem

```java
public class FloatingPointTrap {
    public static void main(String[] args) {

        // ❌ المشكلة الكلاسيكية
        double a = 0.1;
        double b = 0.2;
        System.out.println(a + b);           // 0.30000000000000004 ← مش 0.3!
        System.out.println(a + b == 0.3);    // false ← !!

        // ✅ الحل للـ financial calculations
        // استخدم BigDecimal مش double
        java.math.BigDecimal x = new java.math.BigDecimal("0.1");
        java.math.BigDecimal y = new java.math.BigDecimal("0.2");
        System.out.println(x.add(y));        // 0.3 ✅
        System.out.println(x.add(y).compareTo(new java.math.BigDecimal("0.3")) == 0); // true ✅

        // float vs double precision
        float  f = 1.23456789f;
        double d = 1.23456789;
        System.out.println(f); // 1.2345679  ← rounded (7 significant digits)
        System.out.println(d); // 1.23456789 ← precise  (15-17 significant digits)

        // Special float values
        double posInf = 1.0 / 0.0;  // Infinity (مش exception زي C!)
        double negInf = -1.0 / 0.0; // -Infinity
        double nan    = 0.0 / 0.0;  // NaN (Not a Number)

        System.out.println(posInf);          // Infinity
        System.out.println(Double.isNaN(nan)); // true
        System.out.println(nan == nan);       // false ← NaN مش equal لنفسه!
    }
}
```

> 🔬 **DEEP-DIVE:**
> الـ `double` في Java بيتّبع **IEEE 754 double-precision standard** — نفس الـ standard في C/C++. المشكلة مش في Java، في الـ binary representation نفسها. `0.1` مش قابل للتمثيل بـ binary fraction بدقة كاملة، زي إن `1/3` مش قابل للتمثيل بـ decimal بدقة كاملة (0.3333...).

---

## 🔤 char — الـ Unicode Story

```java
public class CharDeepDive {
    public static void main(String[] args) {

        // char في Java = 16-bit Unicode (UTF-16 code unit)
        char letter  = 'A';
        char arabic  = '\u0639'; // ع
        char emoji   = '\u263A'; // ☺

        // char هو أصغر unsigned integer في Java!
        char c = 'A';           // Unicode value = 65
        int  i = c;             // Widening: char → int automatically
        System.out.println(i);  // 65

        // الـ arithmetic على char
        char next = (char)(c + 1); // cast مطلوب لأن النتيجة int
        System.out.println(next);  // B

        // Char في الـ String comparison
        char x = 65;            // 'A'
        char y = 'A';
        System.out.println(x == y); // true ← مقارنة بالـ value مباشرة (مش زي String)
    }
}
```

> ⚠️ **WARNING:**
> الـ `char` في Java هو **unsigned 16-bit**، الوحيد unsigned من الـ primitive types كلها! كل الباقي signed. وبما إنه 16-bit، الـ emoji والـ symbols الحديثة (Unicode > U+FFFF) بتحتاج **2 chars** (surrogate pair). ده بيخلي `String.length()` مش موثوق لو بتتعامل مع emoji — استخدم `codePointCount()` بدل كده.

---

# 📦 الجزء الثالث: Variables — Scope, Lifetime, والـ Memory

## أنواع الـ Variables في Java

```java
public class VariableTypes {

    // 1. CLASS (STATIC) VARIABLE
    // في الـ Metaspace — shared بين كل الـ instances
    // بتتعمل initialize مرة واحدة لما الـ class بيتلوّد
    private static int instanceCount = 0;

    // 2. INSTANCE VARIABLE
    // في الـ Heap — كل object عنده نسخته الخاصة
    private String name;
    private int age;

    public VariableTypes(String name, int age) {
        this.name = name;
        this.age = age;
        instanceCount++;
    }

    public void demonstrateScope() {
        // 3. LOCAL VARIABLE
        // في الـ Stack — بتتمسح لما الـ method تخلّص
        // لازم تتعمل initialize قبل الاستخدام (مش زي instance vars)
        int localVar = 10; // مفيش default value للـ local vars!

        {
            // Block Scope
            int blockVar = 20; // موجودة بس جوّا الـ block ده
            System.out.println(localVar + blockVar); // 30
        }
        // System.out.println(blockVar); // ❌ COMPILE ERROR: cannot find symbol

        // 4. METHOD PARAMETER
        // نوع من الـ local variables
    }

    public static int getInstanceCount() { return instanceCount; }
}
```

## 🗺️ رسم توضيحي للـ Memory Layout

```
الـ JVM Memory لما الكود بيشتغل:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  METASPACE
  ┌─────────────────────────────────────────┐
  │  VariableTypes.class metadata           │
  │  static int instanceCount = 2           │← Class variable هنا
  └─────────────────────────────────────────┘

  HEAP
  ┌─────────────────────────────────────────┐
  │  Object 1: {name="Ahmed", age=25}       │← Instance variables هنا
  │  Object 2: {name="Sara",  age=30}       │
  └─────────────────────────────────────────┘

  STACK (Thread 1)
  ┌─────────────────────────────────────────┐
  │  Frame: demonstrateScope()              │
  │  ├── localVar = 10                      │← Local variable هنا
  │  └── blockVar = 20 (موجود بس في block) │
  ├─────────────────────────────────────────┤
  │  Frame: main()                          │
  │  └── args = [ref → String[] in Heap]   │
  └─────────────────────────────────────────┘
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> 🔬 **DEEP-DIVE:**
> في C++، local variables بتتعمل destruct بالترتيب العكسي لما بتخرج من الـ scope (LIFO) عن طريق الـ destructor. في Java، مفيش destructors — الـ GC هو المسؤول. لكن الـ Stack Frame بيتمسح فوراً لما الـ method تخلص، والـ references اللي كانت فيها بتبقى unreachable، فالـ GC يقدر يشيل الـ objects اللي كانوا بيشاوروا عليهم.

---

# 🔄 الجزء الرابع: Type Conversion — الـ Widening والـ Narrowing

## الـ Conversion Hierarchy

```
الـ Widening (Automatic — من صغير لكبير):
byte → short → int → long → float → double
                ↑
               char
```

```java
public class TypeConversion {
    public static void main(String[] args) {

        // ✅ WIDENING — automatic (no data loss)
        byte  b = 42;
        short s = b;    // byte → short  (automatic)
        int   i = s;    // short → int   (automatic)
        long  l = i;    // int → long    (automatic)
        float f = l;    // long → float  (automatic — but precision loss possible!)
        double d = f;   // float → double (automatic)

        System.out.println(d); // 42.0

        // ⚠️ TRICKY: long → float قد يخسر precision!
        long bigLong = 1_234_567_890_123L;
        float asFloat = bigLong; // automatic widening بس...
        System.out.println(bigLong);  // 1234567890123
        System.out.println(asFloat);  // 1.23456794E12 ← precision lost!

        // ❌ NARROWING — explicit cast required
        double pi = 3.14159;
        int truncated = (int) pi;    // الكسر بيتشال، مش بيتقرّب
        System.out.println(truncated); // 3

        // Overflow في الـ cast
        int big = 300;
        byte small = (byte) big;     // 300 - 256 = 44 (wrap-around)
        System.out.println(small);   // 44

        // char ↔ int casting
        char ch = 'A';
        int ascii = ch;              // widening: char → int
        char back = (char)(ascii + 1); // narrowing: int → char
        System.out.println(back);    // B
    }
}
```

## الـ Type Promotion في الـ Expressions

```java
public class TypePromotion {
    public static void main(String[] args) {

        byte a = 40, b = 50, c = 100;

        // ⚠️ المفاجأة — الـ expression نتيجته int مش byte!
        // byte d = a * b / c; // ❌ COMPILE ERROR: possible lossy conversion

        // الـ JVM بيـ promote كل byte/short/char لـ int في أي expression
        int d = a * b / c; // ✅
        System.out.println(d); // 20

        // نفس الكلام مع char
        char x = 'A', y = 'B';
        // char z = x + y; // ❌ COMPILE ERROR
        char z = (char)(x + y); // ✅ — 65 + 66 = 131 → '‡'

        // الـ Promotion Rules:
        // 1. لو عندك long في الـ expression → كلها تتحوّل لـ long
        // 2. لو عندك float               → كلها تتحوّل لـ float
        // 3. لو عندك double              → كلها تتحوّل لـ double
        // 4. غير كده                     → كلها تتحوّل لـ int
    }
}
```

> 🔬 **DEEP-DIVE:**
> الـ Type Promotion للـ `int` بيحصل لأن الـ JVM's operand stack optimized للـ 32-bit operations. الـ bytecode instructions زي `iadd` (integer add) شغّالة على 32-bit values. مفيش `badd` (byte add) — عشان كده الـ JVM بيعمل promote تلقائياً. ده performance optimization مش limitation.

---

# 📚 الجزء الخامس: Arrays — مش بس List من Variables

## ازاي الـ Array بيتخزن في الـ Memory

```java
public class ArrayMemoryModel {
    public static void main(String[] args) {

        // الـ array reference على الـ Stack
        // الـ array object نفسه على الـ Heap
        int[] numbers = new int[5];

        /*
        STACK:          HEAP:
        ┌──────────┐    ┌─────────────────────────────────┐
        │ numbers  │───▶│ [length=5] [0][0][0][0][0]      │
        │ (ref)    │    │  index:     0   1   2   3   4   │
        └──────────┘    └─────────────────────────────────┘
        */

        // Default values (مهم! مختلف من C)
        System.out.println(numbers[0]); // 0   (int default)

        boolean[] flags = new boolean[3];
        System.out.println(flags[0]);   // false (boolean default)

        String[] names = new String[3];
        System.out.println(names[0]);   // null (object reference default)

        // Array Initializer Syntax
        int[] months = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        System.out.println(months.length); // 12 (الـ length مش method، هو field)

        // ❌ Out of Bounds — Runtime Exception (مش compile time)
        // System.out.println(months[12]); // throws ArrayIndexOutOfBoundsException

        // Array هو Object — بيتـ pass بـ reference
        modifyArray(months);
        System.out.println(months[0]); // 99 ← اتغيّر!
    }

    static void modifyArray(int[] arr) {
        arr[0] = 99; // بيعدّل على الـ original array في الـ Heap
    }
}
```

> ⚠️ **WARNING:**
> في Java، الـ Array هو **Object** على الـ Heap. لما بتـ pass array لـ method، بتبعت الـ reference مش copy. التعديل جوّا الـ method بيأثر على الـ original — نفس سلوك C مع الـ pointers، بس من غير explicit pointer syntax.

---

## 🔲 2D Arrays — الـ "Arrays of Arrays"

```java
public class MultiDimensionalArrays {
    public static void main(String[] args) {

        // الطريقة الأولى: Regular 2D array
        int[][] matrix = new int[3][4]; // 3 rows, 4 columns

        /*
        في الـ Heap — مش contiguous memory زي C!

        matrix (ref) ──▶ [ ref0 | ref1 | ref2 ]   ← array of references
                            │       │       │
                            ▼       ▼       ▼
                         [0,0,0,0] [0,0,0,0] [0,0,0,0]  ← 3 separate arrays
        */

        // تعبئة وطباعة
        for (int i = 0; i < matrix.length; i++) {
            for (int j = 0; j < matrix[i].length; j++) {
                matrix[i][j] = i * 4 + j;
            }
        }

        // الطريقة الثانية: Initializer
        int[][] identity = {
            {1, 0, 0},
            {0, 1, 0},
            {0, 0, 1}
        };

        // JAGGED ARRAYS — كل row حجمها مختلف
        // مش موجودة في C بنفس السهولة
        int[][] jagged = new int[3][];
        jagged[0] = new int[1];
        jagged[1] = new int[3];
        jagged[2] = new int[2];

        System.out.println(jagged[0].length); // 1
        System.out.println(jagged[1].length); // 3
        System.out.println(jagged[2].length); // 2
    }
}
```

> 🔬 **DEEP-DIVE:**
> في C/C++، الـ `int arr[3][4]` بيتخزن كـ **contiguous block** في الـ memory (row-major order). في Java، الـ `int[][] arr` هو فعلاً **array of array references** — كل row في مكان منفصل في الـ Heap. ده بيديك flexibility للـ Jagged Arrays، لكن بيرفع الـ cache misses عند الـ traversal الكبير. لو بتعمل matrix math performance-critical، استخدم 1D array وتعامل معاه كـ 2D باستخدام `arr[i * cols + j]`.

---

## 🆕 Array Features الحديثة (Java 8+)

```java
import java.util.Arrays;
import java.util.stream.IntStream;

public class ModernArrays {
    public static void main(String[] args) {

        int[] numbers = {5, 3, 8, 1, 9, 2, 7, 4, 6};

        // Sorting
        Arrays.sort(numbers); // in-place sort (dual-pivot quicksort)
        System.out.println(Arrays.toString(numbers)); // [1, 2, 3, 4, 5, 6, 7, 8, 9]

        // Binary Search (المصفوفة لازم تكون sorted أولاً)
        int idx = Arrays.binarySearch(numbers, 7);
        System.out.println("Index of 7: " + idx); // 6

        // Copying
        int[] copy = Arrays.copyOf(numbers, 5);         // أول 5 elements
        int[] rangeCopy = Arrays.copyOfRange(numbers, 2, 6); // من index 2 لـ 5

        // Filling
        int[] filled = new int[5];
        Arrays.fill(filled, 42); // [42, 42, 42, 42, 42]

        // Comparing
        int[] a = {1, 2, 3};
        int[] b = {1, 2, 3};
        System.out.println(a == b);             // false ← comparing references!
        System.out.println(Arrays.equals(a, b)); // true  ← comparing content ✅

        // Java 8+: Streams من Array
        int sum = IntStream.of(numbers).sum();
        int max = IntStream.of(numbers).max().getAsInt();
        System.out.println("Sum: " + sum + ", Max: " + max);

        // Parallel sort للـ large arrays (Java 8+)
        int[] bigArray = new int[100_000];
        Arrays.parallelSort(bigArray); // بيستخدم Fork/Join framework
    }
}
```

---

# 🌊 الجزء السادس: String — الـ Special Object

الـ PDF بيذكر String Literals. خليني أوسّع جداً لأن ده من أهم الـ topics في الـ interviews.

```java
public class StringDeepDive {
    public static void main(String[] args) {

        // الطريقة الأولى: String Literal → من الـ String Pool
        String s1 = "Hello";
        String s2 = "Hello";
        System.out.println(s1 == s2);      // true ← نفس الـ object في الـ Pool!

        // الطريقة التانية: new String → Object جديد في الـ Heap
        String s3 = new String("Hello");
        String s4 = new String("Hello");
        System.out.println(s3 == s4);      // false ← objects مختلفين
        System.out.println(s3.equals(s4)); // true  ← نفس الـ content

        /*
        HEAP Memory Model:
        ┌─────────────────────────────────────────────┐
        │                  HEAP                        │
        │  ┌─────────────────────────────────┐        │
        │  │        String Pool              │        │
        │  │  ┌──────────┐                  │        │
        │  │  │ "Hello"  │◀── s1, s2 (refs) │        │
        │  │  └──────────┘                  │        │
        │  └─────────────────────────────────┘        │
        │                                             │
        │  ┌──────────┐  ┌──────────┐                │
        │  │ "Hello"  │  │ "Hello"  │                │
        │  │ (copy 1) │  │ (copy 2) │                │
        │  └──────────┘  └──────────┘                │
        │      ▲               ▲                      │
        │      s3              s4                     │
        └─────────────────────────────────────────────┘
        */

        // String هو IMMUTABLE في Java
        String original = "Hello";
        String modified = original.concat(" World");
        System.out.println(original); // "Hello" ← لم تتغيّر!
        System.out.println(modified); // "Hello World" ← object جديد

        // الـ intern() method — بتنقل الـ string للـ Pool
        String s5 = new String("Java").intern();
        String s6 = "Java";
        System.out.println(s5 == s6); // true ← نفس الـ Pool object
    }
}
```

> 🔬 **DEEP-DIVE:**
> الـ **String Pool** (أو String Intern Pool) موجود في الـ Heap من Java 7 (قبل كده كان في الـ PermGen اللي اتعمل remove في Java 8). الـ Pool بيشتغل بـ **Flyweight Design Pattern** — بيشارك الـ immutable objects بدل ما يعمل copies. ده بيوفّر memory ضخم في الـ applications اللي بتتعامل مع كتير من الـ string literals.

> ⚠️ **WARNING:**
> الـ String Immutability معناها إن كل عملية زي `+` أو `concat()` بتعمل **object جديد**. لو بتعمل string concatenation في loop:
> ```java
> // ❌ كارثة في الـ Performance — بيعمل n objects
> String result = "";
> for (int i = 0; i < 10000; i++) {
>     result += i; // new object كل iteration!
> }
>
> // ✅ الصح — استخدم StringBuilder
> StringBuilder sb = new StringBuilder();
> for (int i = 0; i < 10000; i++) {
>     sb.append(i); // بيعدّل على نفس الـ buffer
> }
> String result2 = sb.toString();
> ```

---

# 🏋️ Practical Exercise (PE)

<details>
<summary>💻 PE: نظام بحث وتحليل درجات — اضغط للتفاصيل والحل</summary>

## 🎯 السيناريو

أنت بتبني نظام لتحليل درجات طلاب ITI:

1. عمل array من 1000 درجة عشوائية (0-100)
2. حسب الـ min, max, average
3. نفّذ Linear Search ورصّد الوقت
4. افرز الـ array ونفّذ Binary Search ورصّد الوقت
5. قارن الوقتين واطبع التحليل

## ✅ الـ Architect Solution

```java
import java.util.Arrays;
import java.util.Random;

public class GradeAnalyzer {

    private static final int ARRAY_SIZE = 1_000_000; // نزوّد للتأثير
    private static final int SEARCH_TARGET = 75;

    public static void main(String[] args) {
        int[] grades = generateGrades(ARRAY_SIZE);

        // تحليل الـ statistics
        analyzeStats(grades);

        // Linear Search
        long linearTime = measureLinearSearch(grades, SEARCH_TARGET);
        System.out.printf("Linear Search: %,d ns%n", linearTime);

        // Sort ثم Binary Search
        int[] sortedGrades = grades.clone(); // مش نعدّل الـ original
        Arrays.sort(sortedGrades);

        long binaryTime = measureBinarySearch(sortedGrades, SEARCH_TARGET);
        System.out.printf("Binary Search: %,d ns%n", binaryTime);

        // مقارنة
        System.out.printf("Binary Search أسرع بـ: %.2fx%n",
            (double) linearTime / binaryTime);
    }

    private static int[] generateGrades(int size) {
        Random rand = new Random(42); // seed ثابت للـ reproducibility
        int[] arr = new int[size];
        for (int i = 0; i < size; i++) {
            arr[i] = rand.nextInt(101); // 0 to 100
        }
        return arr;
    }

    private static void analyzeStats(int[] grades) {
        int min = grades[0], max = grades[0];
        long sum = 0;

        for (int grade : grades) { // Enhanced for loop (for-each)
            if (grade < min) min = grade;
            if (grade > max) max = grade;
            sum += grade;
        }

        System.out.printf("Array Size: %,d%n", grades.length);
        System.out.printf("Min: %d | Max: %d | Avg: %.2f%n",
            min, max, (double) sum / grades.length);
    }

    private static long measureLinearSearch(int[] arr, int target) {
        long start = System.nanoTime();
        int result = linearSearch(arr, target);
        long end = System.nanoTime();

        System.out.println("Linear Search result index: " + result);
        return end - start;
    }

    private static int linearSearch(int[] arr, int target) {
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == target) return i;
        }
        return -1;
    }

    private static long measureBinarySearch(int[] arr, int target) {
        long start = System.nanoTime();
        int result = Arrays.binarySearch(arr, target);
        long end = System.nanoTime();

        System.out.println("Binary Search result index: " + result);
        return end - start;
    }
}
```

## 📊 Expected Output (تقريباً)

```
Array Size: 1,000,000
Min: 0 | Max: 100 | Avg: 50.04
Linear Search result index: 7
Linear Search: 1,250,430 ns
Binary Search result index: 502,341
Binary Search:     1,240 ns
Binary Search أسرع بـ: 1008.41x
```

## 🏛️ الدرس المعماري

| Algorithm | Time Complexity | الـ Use Case |
|-----------|----------------|-------------|
| Linear Search | O(n) | Unsorted data, small arrays |
| Binary Search | O(log n) | **Sorted** data, large arrays |
| Arrays.sort() | O(n log n) | Dual-pivot Quicksort (Java's impl) |

</details>

---

# 🎯 Interview Survival Kit — Sprint 2

<details>
<summary>🔥 أسئلة الـ Interviews + الإجابات الـ Senior-Level — اضغط للتفاصيل</summary>

---

### Q1: "What is the difference between `int` and `Integer` in Java?"

```java
// int → primitive, على الـ Stack، لا يقبل null
int x = 5;
// int y = null; // ❌ COMPILE ERROR

// Integer → Wrapper class, object على الـ Heap، يقبل null
Integer a = 5;     // Autoboxing: Integer.valueOf(5)
Integer b = null;  // ✅ valid

// Integer Cache: من -128 لـ 127 بيتـ cache
Integer i1 = 127;
Integer i2 = 127;
System.out.println(i1 == i2); // true  ← من الـ cache

Integer i3 = 128;
Integer i4 = 128;
System.out.println(i3 == i4); // false ← objects جدد كل مرة

// الـ Unboxing Trap
Integer val = null;
// int result = val + 1; // ❌ NullPointerException! (unboxing null)
```

---

### Q2: "Why are Strings immutable in Java?"

**الإجابة الـ Senior — 3 أسباب:**

```
1. SECURITY:
   الـ String بيُستخدم في class names, file paths, DB connections.
   لو كان mutable، ممكن حد يغيّر الـ value بعد الـ validation check.

2. STRING POOL / CACHING:
   الـ immutability هي اللي بتخلّي الـ String Pool ممكن.
   لو String كان mutable، مش ممكن تشارك references.
   (Flyweight Design Pattern)

3. THREAD SAFETY:
   الـ immutable objects automatically thread-safe.
   مفيش حاجة تعمل synchronization لما تشارك String بين threads.
```

---

### Q3: "What happens when you do `String s = "a" + "b" + "c"`?"

```java
// الإجابة المفاجأة: الـ Java Compiler بيعمل Compile-Time Optimization!
String s = "a" + "b" + "c";
// بيتحوّل لـ: String s = "abc"; (في الـ bytecode)
// الـ String Pool بيحتوي على "abc" مباشرة

// لكن لو في variables:
String x = "a";
String y = "b";
String z = x + y; // هنا بيتحوّل لـ:
// new StringBuilder().append(x).append(y).toString()
// Java 9+: StringConcatFactory (أسرع وأكفأ)
```

---

### Q4: "What is the difference between Array and ArrayList?"

| الجانب | Array | ArrayList |
|--------|-------|-----------|
| **Size** | Fixed at creation | Dynamic |
| **Type** | Primitives + Objects | Objects only (Generics) |
| **Performance** | أسرع (direct memory) | أبطأ قليلاً (overhead) |
| **Null** | يقبل | يقبل |
| **Syntax** | `arr[0]` | `list.get(0)` |
| **Multi-dim** | ممكن native | List of Lists |

---

### Q5: (Hardcore) "Explain the memory layout of a 2D array in Java vs C."

```
C (int arr[3][4]):
┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
│  │  │  │  │  │  │  │  │  │  │  │  │ ← Contiguous 48 bytes
└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
 row 0 (4 ints) row 1 (4 ints) row 2 (4 ints)
 Cache-friendly ✅

Java (int[][] arr = new int[3][4]):
Heap:
arr ──▶ [ref0 | ref1 | ref2]     ← array of references (12 bytes + header)
          │       │       │
          ▼       ▼       ▼
       [0,0,0,0] [0,0,0,0] [0,0,0,0] ← 3 separate objects, scattered in Heap
       Not contiguous ⚠️

الـ Impact:
- Java 2D arrays أبطأ في iteration كتير بسبب cache misses
- الـ Solution للـ performance-critical code:
  int[] flat = new int[3 * 4];
  flat[row * 4 + col] = value; // تعامل معاه كـ 2D
```

---

### Q6: "What is the difference between `==` for primitives vs objects?"

```java
// Primitives: == بتقارن القيمة
int a = 5, b = 5;
System.out.println(a == b); // true ← comparing values

// Objects: == بتقارن الـ reference (العنوان في الـ memory)
String s1 = new String("hello");
String s2 = new String("hello");
System.out.println(s1 == s2);      // false ← different objects
System.out.println(s1.equals(s2)); // true  ← same content

// الـ Golden Rule:
// للـ objects → دايماً .equals()
// للـ null check → ==
// للـ enums → == (هما singletons)
```

---

### Q7: (Tricky) "What does this print?"

```java
byte b = 127;
b++;
System.out.println(b); // ما هو الـ output?
```

**الإجابة:** يطبع `-128`!

لأن `byte` range هو -128 to 127. لما تزوّد على 127، بيحصل overflow وبيـ wrap حواليه لـ -128. ده بيحصل silently من غير exception.

```
Binary representation of 127:  0111_1111
Add 1:                          1000_0000
Interpreted as signed byte:    -128 (two's complement)
```

</details>

---

# 📋 ملخص Sprint 2

```
✅ فهمنا الـ 8 Primitive Types وحجمهم الثابت (مش زي C)
✅ فهمنا الـ Floating-Point precision problem والـ BigDecimal solution
✅ فهمنا Variable Types: static, instance, local, parameter
✅ فهمنا الـ Stack vs Heap للـ variables
✅ فهمنا الـ Widening vs Narrowing Conversion + Type Promotion
✅ فهمنا الـ Array memory layout (arrays of arrays)
✅ فهمنا الـ String Pool والـ Immutability
✅ عندنا PE: Grade Analyzer مع Linear vs Binary Search timing

Sprint 3 الجاي → Operators, Control Flow, String Handling Deep Dive
```

---

*📁 Sprint 2 — ITI Core Java Intake 46 | Dec 2025*
*🏛️ Mentor: Elite Egyptian Java Principal Architect*
