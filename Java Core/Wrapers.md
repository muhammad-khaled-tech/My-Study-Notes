---
tags:
  - java-core
  - java-wrappers
  - java-autoboxing
  - java-collections-prerequisite
difficulty: 2
related:
  - "[[Data Types]]"
  - "[[Wrapper Classes & inner classes]]"
  - "[[Java collections]]"
---

ده موضوع مهم جداً يا هندسة، وللأسف ناس كتير بتستهون بيه وبيفاجئهم في الـ Machine Learning أو الـ Data Science لما يقابلوا مصطلحات زي `NaN` أو `Infinity`.

السلايدز دي بتتكلم عن Wrapper Classes (الأغلفة).

تعالى نطبق نظامنا: سؤال، مشكلة، وحل.

---

### سؤال: لماذا نحتاج إلى "تغليف" البيانات الأولية (Primitives) في كلاسات؟

#### س1: إيه المشكلة في الـ Primitives العادية (`int`, `double`, `boolean`)؟

ج:

الـ Primitives سريعة جداً وخفيفة على الميموري، لكنها "غبية" (Dumb Data Types).

1. **مش كائنات (Not Objects):** مينفعش تبعتها لأي دالة بتطلب `Object`.
    
2. **مفهاش دوال:** مينفعش تقول `x.toString()` أو `x.convert()`. الـ `int x = 5` هو مجرد رقم 5، ميعرفش يعمل أي حاجة تانية.
    
3. **ممنوعة في الـ Collections:** مينفعش تعمل `ArrayList<int>` (الجافا بتمنع ده لأن الـ Collections مصممة تشيل Objects بس).
    

#### س2: إزاي الـ Wrapper Classes حلت المشكلة دي؟ (الحل الذكي) 💡

ج:

الجافا عملت لكل Primitive "أخ كبير" (Wrapper Class).

- `int` -> `Integer`
    
- `double` -> `Double`
    
- `char` -> `Character`
    

الـ Wrapper ده عبارة عن **صندوق (Object)** بنحط جواه القيمة الـ primitive.

- **الميزة:** الصندوق ده "ذكي"، مليان دوال مساعدة (`methods`) وثوابت (`constants`)، وينفع يتحط في الـ `ArrayList`.
    

---

### سؤال: ما هي الاستخدامات الثلاثة الرئيسية للـ Wrapper Classes (شرح السلايد)؟

السلايد لخص الاستخدامات في 3 نقط، تعال نفصصهم:

#### 1. الاستخدام كـ Object (عشان الـ Collections)

- **المشكلة:** دالة بتاخد `Object` أو `ArrayList` مش بتقبل `int`.
    
- **الحل:** نستخدم `Integer`.
    

Java

```
// ❌ غلط:
// ArrayList<int> numbers = new ArrayList<>(); 

// ✅ صح:
ArrayList<Integer> numbers = new ArrayList<>();
numbers.add(10); // هنا الجافا حولت الـ 10 لـ Integer أوتوماتيك (Auto-boxing)
```

#### 2. استخدام الثوابت (Constants) - (صورة 2) 📏

- **المشكلة:** عايز أعرف أكبر رقم ممكن الـ `int` يشيله عشان ميعملش Overflow. هل أحفظ الرقم (2 مليار وكسور)؟
    
- **الحل:** الكلاس فيه ثوابت جاهزة.
    

Java

```
System.out.println("Max Integer: " + Integer.MAX_VALUE);
System.out.println("Min Integer: " + Integer.MIN_VALUE);
```

- **نقطة خطيرة في الصورة (2):** الـ `Float` والـ `Double` فيهم ثوابت خاصة جداً:
    
    - **`POSITIVE_INFINITY`**: لما تقسم رقم موجب على صفر (`1.0 / 0.0`).
        
    - **`NEGATIVE_INFINITY`**: لما تقسم رقم سالب على صفر (`-1.0 / 0.0`).
        
    - **`NaN` (Not a Number)**: لما تقسم صفر على صفر (`0.0 / 0.0`) أو تجيب جذر رقم سالب. دي مهمة جداً عشان البرنامج ما يضربش (Exception) ويكمل شغل عادي.
        

#### 3. دوال التحويل (Conversion Methods) - (صورة 1) 🛠️

دي أهم نقطة، والفرق بينهم بييجي في الامتحانات. السلايد مقسمهم لـ 3 أنواع:

**أ) التحويل من Wrapper لـ Primitive (`xxxValue`)**

- **الوظيفة:** "فك الغلاف". معاك صندوق `Integer` وعايز تطلع الـ `int` اللي جواه.
    

Java

```
Integer iOb = new Integer(100); // (deprecated style)
int i = iOb.intValue(); // رجعنا لـ primitive
```

**ب) التحويل من String لـ Primitive (`parseXXX`)** ⚠️ **مهمة جداً**

- **الوظيفة:** معاك نص "123" وعايز تحوله لرقم `int` عشان تجمع وتطرح.
    
- **الناتج:** بيرجع **Primitive** (`int`).
    

Java

```
String s = "123";
int num = Integer.parseInt(s); // خفيف وسريع
```

**ج) التحويل من String لـ Wrapper (`valueOf`)** ⚠️ **مهمة جداً**

- **الوظيفة:** معاك نص "123" وعايز تحوله لصندوق `Integer` (Object).
    
- **الناتج:** بيرجع **Object** (`Integer`).
    

Java

```
String s = "123";
Integer numObj = Integer.valueOf(s); // بيرجع أوبجكت
```

---

### سؤال: كيف نتعامل مع أنظمة الأرقام المختلفة (Binary, Hex)؟

السلايد الأولاني تحت خالص فيه كود مثير للاهتمام:

Integer.toHexString(254)

#### س: لو عايز أعرض الرقم بس بالنظام الست عشري (Hex) أو الثنائي (Binary)؟

**ج:** الـ Wrapper Classes فيها دوال "ترجمة" جاهزة.

Java

```
int n = 254;

// 1. تحويل لـ Binary (0, 1)
System.out.println(Integer.toBinaryString(n)); // Output: 11111110

// 2. تحويل لـ Hexadecimal (0-9, A-F)
System.out.println(Integer.toHexString(n));    // Output: fe

// 3. تحويل لـ Octal (0-7)
System.out.println(Integer.toOctalString(n));  // Output: 376
```

---

### الخلاصة (الزتونة) 🫒

|**الطريقة**|**الوظيفة**|**بترجع إيه؟**|
|---|---|---|
|**`parseInt("10")`**|بتحول النص لرقم عادي|**`int`** (Primitive)|
|**`valueOf("10")`**|بتحول النص لكائن|**`Integer`** (Object)|
|**`intValue()`**|بتفك الكائن لرقم عادي|**`int`** (Primitive)|
|**`NaN`**|نتيجة عملية غير منطقية (0.0/0.0)|قيمة خاصة في الـ Double|

---
ده "كود المعمل" الشامل يا هندسة. 🧪👨‍💻

الكود ده أنا مجمعة لك فيه كل "الخلاصة" بتاعت الـ Wrappers. هو مقسم لوحدات (Methods) لكل نوع، عشان تاخده Copy وتحطه في الـ IDE عندك (زي IntelliJ أو Eclipse) وتعمل Run وتتفرج على العظمة.

الكود بيغطي: `Integer`, `Double`, `Character`, `Boolean`.

### 🧪 WrapperLab.java



```Java
public class WrapperLab {

    public static void main(String[] args) {
        System.out.println("=== Welcome to Wrapper Classes Lab ===\n");

        testInteger();   // تجربة الأعداد الصحيحة
        testDouble();    // تجربة الأرقام العشرية والحالات الخاصة
        testCharacter(); // تجربة الحروف والتحقق منها
        testBoolean();   // تجربة المنطق

        System.out.println("\n=== End of Lab ===");
    }

    // 1. Integer Wrapper (سيد الأرقام الصحيحة)
    public static void testInteger() {
        System.out.println("--- 1. Testing Integer Class ---");

        // أ) الثوابت (Constants)
        System.out.println("Max Value: " + Integer.MAX_VALUE); // 2 مليار وشوية
        System.out.println("Min Value: " + Integer.MIN_VALUE);

        // ب) التحويل من String لـ int (Parsing) - بيرجع Primitive
        String numStr = "123";
        int primitiveInt = Integer.parseInt(numStr);
        System.out.println("Parsed int: " + (primitiveInt + 5)); // نجمع عليه عشان نتأكد إنه رقم

        // ج) التحويل من String لـ Integer Object (valueOf) - بيرجع Object
        Integer objInt = Integer.valueOf("456");
        System.out.println("Integer Object: " + objInt);

        // د) أنظمة الأعداد (Binary, Hex, Octal)
        int n = 255;
        System.out.println("255 in Binary: " + Integer.toBinaryString(n)); // 11111111
        System.out.println("255 in Hex:    " + Integer.toHexString(n));    // ff

        // هـ) دوال المقارنة (Utility)
        System.out.println("Max of (10, 20): " + Integer.max(10, 20));
        System.out.println("Compare (5, 10): " + Integer.compare(5, 10)); // -1 معناها الأول أصغر
        System.out.println();
    }

    // 2. Double Wrapper (مخزن اللانهاية)
    public static void testDouble() {
        System.out.println("--- 2. Testing Double Class ---");

        // أ) الثوابت الخطيرة (Infinity & NaN)
        double divByZero = 1.0 / 0.0;
        double zeroByZero = 0.0 / 0.0;
        
        System.out.println("1.0 / 0.0 = " + divByZero); // Infinity
        System.out.println("0.0 / 0.0 = " + zeroByZero); // NaN

        // ب) الكشف عن المصائب (Checking)
        // دي مهمة جداً عشان البرنامج ما يضربش منك في الحسابات
        System.out.println("Is 'divByZero' Infinite? " + Double.isInfinite(divByZero)); // true
        System.out.println("Is 'zeroByZero' NaN?      " + Double.isNaN(zeroByZero));      // true

        // ج) التحويل (Parsing)
        String price = "99.99";
        double priceVal = Double.parseDouble(price);
        System.out.println("Parsed Price: " + priceVal);
        System.out.println();
    }

    // 3. Character Wrapper (المحقق كونان) 🕵️‍♂️
    public static void testCharacter() {
        System.out.println("--- 3. Testing Character Class ---");

        char c1 = 'A';
        char c2 = '9';
        char c3 = ' ';

        // دوال التحقق (is methods)
        System.out.println("'A' is Letter?     " + Character.isLetter(c1));      // true
        System.out.println("'9' is Digit?      " + Character.isDigit(c2));       // true
        System.out.println("' ' is Whitespace? " + Character.isWhitespace(c3));  // true
        System.out.println("'a' is LowerCase?  " + Character.isLowerCase('a'));  // true

        // دوال التحويل
        System.out.println("To UpperCase 'b':  " + Character.toUpperCase('b'));
        System.out.println();
    }

    // 4. Boolean Wrapper (حارس البوابة)
    public static void testBoolean() {
        System.out.println("--- 4. Testing Boolean Class ---");

        // التحويل الذكي (Parsing)
        // أي كلمة غير "true" (بأي حروف كابيتال أو سمول) هتعتبر false
        boolean b1 = Boolean.parseBoolean("TRUE");
        boolean b2 = Boolean.parseBoolean("true");
        boolean b3 = Boolean.parseBoolean("Yes"); // خدعة

        System.out.println("Parse 'TRUE': " + b1); // true
        System.out.println("Parse 'true': " + b2); // true
        System.out.println("Parse 'Yes':  " + b3); // false (مش فاهم غير true)
        
        // عمليات منطقية
        System.out.println("Logical AND (true, false): " + Boolean.logicalAnd(true, false));
        System.out.println();
    }
}
```

---

### حاجات لازم تجربها بنفسك في الكود ده وتشوف النتيجة (Challenges) 🔥:

1. في جزء الـ Integer:
    
    جرب تغير السطر ده: Integer.parseInt("123") وخليه Integer.parseInt("123a").
    
    - **المتوقع:** شوف الـ Exception اللي هيطلعلك واسمه إيه (عشان ده أشهر Error هتشوفه في حياتك).
        
2. في جزء الـ Double:
    
    جرب تقسم int على int بـ صفر (مثلاً 1 / 0) بدل 1.0 / 0.0.
    
    - **المتوقع:** هل هيديك `Infinity` ولا البرنامج هيضرب (`ArithmeticException`)؟ (فيه فرق بين قسمة الـ integers وقسمة الـ doubles).
        
3. في جزء الـ Boolean:
    
    جرب Boolean.valueOf("True") وشوف هل بيرجع Boolean object ولا boolean primitive؟
    



---

### سؤال: ما هو الـ Autoboxing و الـ Unboxing وكيف أراحنا من "اللف والدوران"؟

#### س1: إيه المشكلة قبل Java 5 (عصر الكتابة اليدوية)؟ ✍️

ج:

زمان، الجافا كانت "غبية" جداً في التحويل.

لو معاك رقم int وعايز تحطه في صندوق Integer، كان لازم تعمل كل حاجة بإيدك.

- **التغليف اليدوي:** `Integer x = new Integer(10);`
    
- **فك الغلاف اليدوي:** `int y = x.intValue();`.
    

تخيل لو بتعمل عملية حسابية بسيطة، كنت بتكتب سطور كود عشان بس تحول الأنواع!

---

#### س2: يعني إيه Autoboxing (التغليف التلقائي)؟ 🎁

ج:

هي عملية بتحصل لما الجافا تلاقي إنك محتاج Object (زي Integer)، بس أنت اديتها Primitive (زي int).

- **اللي بيحصل:** الجافا "أوتوماتيك" بتاخد الرقم، وتحطه جوه صندوق Wrapper.
    
- **الكود:**
    
    
    
    ```Java
    // Autoboxing: Java converts int (100) to Integer object automatically
    Integer intObject = 100;
    ```
    

---

#### س3: يعني إيه Auto-unboxing (فك الغلاف التلقائي)؟ 🔓

ج:

دي العكس. لما الجافا تلاقي إنك محتاج قيمة رقمية (Primitive) عشان تحسب أو تخزن، بس اللي معاك هو صندوق (Object).

- **اللي بيحصل:** الجافا "أوتوماتيك" بتفتح الصندوق، وتطلع الرقم اللي جواه عشان تستخدمه.
    
- **الميزة:** مبقتش محتاج تنادي دوال زي `intValue()` أو `doubleValue()` بنفسك.
    
- **الكود:**
    
    
    
    ```Java
    // Auto-unboxing: Java extracts int from intObject automatically
    int i = intObject;
    ```
    

---

#### س4: هل الموضوع مقتصر على علامة "يساوي" بس؟ (Methods Magic) 🎩

ج:

لأ، السلايد التاني بيوضح نقطة مهمة جداً: Autoboxing بيحصل في الدوال كمان!.

تخيل عندك دالة مستنية تستلم `Integer` (Object)، وأنت بعتلها رقم `5` (primitive).

- **زمان:** Error.
    
- **دلوقتي:** الجافا بتعمل Autoboxing للـ 5 وتبعتها للدالة.
    

**مثال تطبيقي (Methods):**



```Java
public class BoxDemo {
    
    // الدالة دي طالبة Object (Integer)
    static void takeObject(Integer num) {
        System.out.println("Object received: " + num);
    }

    // الدالة دي بترجع Primitive (int)
    static int givePrimitive() {
        return new Integer(50); // بنرجع Object!
    }

    public static void main(String[] args) {
        // 1. Autoboxing in Argument Passing
        // بعتنا 10 (int) للدالة اللي عايزة Integer
        takeObject(10); // الجافا عملت boxing لوحدها

        // 2. Auto-unboxing in Return
        // الدالة رجعت Object، بس احنا خزنناه في int
        int val = givePrimitive(); // الجافا عملت unboxing لوحدها
    }
}
```

---

### تحذير البروفيسور (نقطة للمحترفين مش في السلايد) ⚠️

رغم إن الموضوع سحر ومريح، بس فيه **"فخ قاتل"** لازم تاخد بالك منه: **`NullPointerException`**.

- الـ **Auto-unboxing** بيحاول ينادي `intValue()` في الخلفية.
    
- لو الـ Object ده كان بـ `null`.. الجافا هتيجي تفك الصندوق هتلاقيه مش موجود أصلاً!
    



```Java
Integer x = null;
// int y = x; // 💥 مصيبة! هيدرب NullPointerException لأن الصندوق فاضي
```

### الخلاصة (الزتونة) 🫒

|**المفهوم**|**الاتجاه**|**الوصف**|**مثال**|
|---|---|---|---|
|**Autoboxing**|`Primitive` ➡️ `Wrapper`|بيحط الرقم في صندوق|`Integer x = 10;`|
|**Unboxing**|`Wrapper` ➡️ `Primitive`|بيطلع الرقم من الصندوق|`int y = new Integer(10);`|

كده السحر ده بقى واضح؟ ده خلى الكود أنضف بكتير، بس خلي بالك من الـ `null`! 😉

---

## 🔗 Related Notes

> [!TIP] **مسار التعلم (Learning Path)**
> - **سابق:** [[Data Types]] - لفهم الأنواع البدائية الأساسية قبل تغليفها
> - **مكمل:** [[Wrapper Classes & inner classes]] - شرح أعمق مع Inner Classes
> - **تطبيق:** [[Java collections]] - أين نستخدم Wrappers بشكل إجباري
> - **تحذير:** [[Exceptions]] - NullPointerException مع Auto-unboxing