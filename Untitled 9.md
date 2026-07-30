سؤال ممتاز جدًا وبيجي كتير في أسئلة الأساسيات (Core Java)! تعال نكسر الإجابات نقطة نقطة بأمثلة واضحة.

---

## 1. ايه هو الـ Type Promotion؟

الـ **Type Promotion (ترقية الأنواع)** هو سلوك تلقائي بتعمله الجافا أثناء **تقييم التعبيرات الحسابية (Expressions)**، حيث بيتم رفع (ترقية) أنواع البيانات الصغيرة تلقائيًا لأنواع أكبر لمنع الـ Overflow أثناء الحسابات.

### القواعد الذهبية للـ Type Promotion:

1. **أي `byte` أو `short` أو `char` بيتحول أوتوماتيك لـ `int**` لما يدخل في أي عملية حسابية.
2. لو التعبير الحسابي فيه عنصر من نوع `long` -> الناتج كله بيترقى لـ `long`.
3. لو فيه `float` -> الناتج بيترقى لـ `float`.
4. لو فيه `double` -> الناتج بيترقى لـ `double`.

> ⚠️ **سؤال إنترفيو شهير جدًا:**
> ```java
> byte a = 10;
> byte b = 20;
> byte c = a + b; // ❌ Compilation Error!
> 
> ```
> 
> 
> **ليه الكود ده مش بيكومبايل؟**
> لأن الجافا عملت **Type Promotion** للـ `a` والـ `b` لـ `int` أثناء العملية `a + b`! فالناتج بقى `int` وما ينفعش تحطه في `byte` من غير Casting صريح.
> **التصحيح:** `byte c = (byte)(a + b);`

---

## 2. مثال كود شامل لـ Casting مع (`char`, `int`, `float`, `byte`)

```java
public class CastingExample {
    public static void main(String[] args) {
        
        // 1. int -> byte (Explicit Casting - Narrowing)
        int bigNum = 100;
        byte b1 = (byte) bigNum; // 100 بتطابق نطاق الـ byte (-128 to 127)
        System.out.println("int to byte: " + b1); // Output: 100

        // 2. char <-> int
        char letter = 'A';
        int asciiCode = letter; // Implicit (Implicit Widening): 'A' يتحول لـ 65 تلقائيًا
        System.out.println("char to int: " + asciiCode); // Output: 65

        int numForChar = 66;
        char convertedChar = (char) numForChar; // Explicit: 66 يتحول لـ 'B'
        System.out.println("int to char: " + convertedChar); // Output: B

        // 3. float -> int -> byte (Explicit - Truncates Decimals)
        float myFloat = 98.75f;
        int intFromFloat = (int) myFloat; // بيطير الكسر خالص (98)
        byte byteFromFloat = (byte) myFloat; // بيطير الكسر ويبقيه byte (98)
        
        System.out.println("float to int: " + intFromFloat); // Output: 98
        System.out.println("float to byte: " + byteFromFloat); // Output: 98
    }
}

```

---

## 3. هل الـ `byte` ينفع يأخد Character Literal زي `byte b = "a";`؟

**إجابة قاطعة: لا، ينفعش خالص! ❌**

الكود ده:

```java
byte b = "a"; // ❌ Compilation Error!

```

بيضرب خطأ لأن `"a"` نوعها **`String`** (Object)، والـ `byte` نوع **Primitive numeric**. ما ينفعش تخزن Object جوه Primitive.

### لكن... هل ينفع `byte b = 'a';` (بـ Single Quotes)؟

**نعم، ينفع جدًا! ✅**

```java
byte b = 'a'; // Valid!

```

**السبب:** لأن `'a'` حرف (`char`) وله قيمة رقمية في الـ ASCII Table وهي **97**. وبما إن الـ 97 تقع جوه نطاق الـ `byte` (من `-128` إلى `127`)، فالجافا بتسمح بتحويل الـ `char` لـ `byte` تلقائيًا طالما القيمة Literal وثابتة.

---

## 4. متى نستخدم Single Quote `' '` ومتى نستخدم Double Quote `" "`؟

| المعيار | Single Quotes `' '` | Double Quotes `" "` |
| --- | --- | --- |
| **نوع البيانات** | `char` (Primitive) | `String` (Object/Class) |
| **المحتوى** | حرف واحد فقط (أو Escape Sequence) | نص كاملاً (صفر أو أكثر من الحروف) |
| **حجم الميموري** | ثابت (16-bit / 2 Bytes) | يتغير حسب طول النص |
| **أمثلة صحيحة** | `'A'`, `'5'`, `'$'`, `'\n'` | `"A"`, `"Hello World"`, `""` |
| **أمثلة خاطئة** | `'AB'` ❌ (أكثر من حرف) | مش بيضرب خطأ لو كتبت حرف واحد لكن نوعه بيكون `String` |

### ملخص سريع للـ Quotes:

```java
char c = 'a';   // حرف واحد فقط في الميموري
String s = "a"; // Object كامل من نوع String مخزّن جوه String Pool

```
---

