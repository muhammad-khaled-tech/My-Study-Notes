# 📕 الجزء الرابع: Google Gson (من الـ Appendix)

> **ملاحظة:** Gson مش جزء من Java الرسمية، لكنها مكتبة شهيرة جداً من Google.

---

# 🎯 الفهرس

1. **ما هو Gson؟** - المقدمة
2. **Gson vs JSON-B** - الفرق
3. **إعداد المشروع** - Dependencies
4. **الأساسيات** - toJson و fromJson
5. **GsonBuilder** - التخصيص
6. **القراءة/الكتابة من ملفات**

---

# 🤔 الفصل 1: ما هو Gson؟

## التعريف:

**Google Gson** = مكتبة من Google لتحويل Java Objects ↔ JSON

**تاريخها:**

- تم تطويرها بواسطة **Google**
- Open Source (مفتوحة المصدر)
- موجودة على GitHub: `github.com/google/gson`
- كانت موجودة **قبل** JSON-B (قبل 2017)

---

## ليه نستخدم Gson بدل JSON-B؟

### المقارنة:

| الخاصية     | JSON-B            | Gson                           |
| ----------- | ----------------- | ------------------------------ |
| **المصدر**  | Jakarta EE (رسمي) | Google                         |
| **المعيار** | JSR 367 (معيار)   | مكتبة مستقلة                   |
| **السهولة** | سهلة              | **أسهل قليلاً**                |
| **التخصيص** | محدود             | **أكثر مرونة**                 |
| **الشهرة**  | جديدة نسبياً      | **الأشهر** في المشاريع القديمة |

---

## متى نستخدم كل واحدة؟

### استخدم JSON-B لو:

- مشروع جديد بـ Jakarta EE
- عايز تلتزم بالمعايير
- مش محتاج تخصيص كتير

### استخدم Gson لو:

- مشروع قديم (قبل 2020)
- محتاج **PrettyPrinting** سهل
- محتاج **مرونة** أكتر في التخصيص
- بتشتغل مع مشاريع Google (Android مثلاً)

---

# 📦 الفصل 2: إعداد المشروع

## الـ Dependency المطلوبة:

### في Maven:

```xml
<dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
    <version>2.10.1</version>
</dependency>
```

**شرح:**

- `com.google.code.gson` = الـ Group ID
- `gson` = الـ Artifact ID
- `2.10.1` = أحدث إصدار (اكتب رقم أحدث لو موجود)

---

## الـ Imports المطلوبة:

```java
import com.google.gson.*;        // الأساسي (Gson, GsonBuilder)
import java.io.*;                // للتعامل مع Files
```

**شرح:**

- `com.google.gson.*` = كل classes الـ Gson
  - `Gson` = الـ Class الرئيسي
  - `GsonBuilder` = للتخصيص
- `java.io.*` = للقراءة من/الكتابة لملفات

---

# 🔰 الفصل 3: الأساسيات (Serialization & Deserialization)

## مثال بسيط جداً:

### الخطوة 1: تعريف Student Class

```java
public class Student {
    // ملاحظة: في Gson، الـ Fields ممكن تكون private!
    private String name;
    private int age;

    // Constructor فارغ
    public Student() {}

    // Getters & Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }

    // toString للطباعة
    @Override
    public String toString() {
        return "Student [ name: " + name + ", age: " + age + " ]";
    }
}
```

**فرق مهم عن JSON-B:**

- Gson بيشتغل مع **private fields** كمان!
- بيستخدم **Getters/Setters** لو موجودة
- لو مفيش Getters/Setters، بيستخدم **Reflection** للوصول للـ private fields

---

### الخطوة 2: Serialization (Object → JSON)

```java
public class GsonSerializationExample {
    public static void main(String[] args) {

        // ========== 1. إنشاء Object ==========
        Student student = new Student();
        student.setName("أحمد");
        student.setAge(25);

        // ========== 2. إنشاء Gson Instance ==========
        // الطريقة الأبسط:
        Gson gson = new Gson();

        // ========== 3. التحويل لـ JSON ==========
        // toJson(object) = تحويل Object لـ JSON String
        // بتاخد: Object
        // بترجع: String (JSON)
        String json = gson.toJson(student);

        // ========== 4. الطباعة ==========
        System.out.println(json);
    }
}
```

**Output:**

```json
{ "name": "أحمد", "age": 25 }
```

---

### الخطوة 3: Deserialization (JSON → Object)

```java
public class GsonDeserializationExample {
    public static void main(String[] args) {

        // ========== 1. JSON String ==========
        String json = "{\"name\":\"سارة\",\"age\":22}";

        // ========== 2. إنشاء Gson Instance ==========
        Gson gson = new Gson();

        // ========== 3. التحويل لـ Object ==========
        // fromJson(json, class) = تحويل JSON لـ Object
        // بتاخد: String (JSON), Class (النوع)
        // بترجع: T (الـ Object)
        Student student = gson.fromJson(json, Student.class);

        // ========== 4. استخدام النتيجة ==========
        System.out.println(student);
        // Output: Student [ name: سارة, age: 22 ]
    }
}
```

---

## مقارنة مع JSON-B:

| العملية           | JSON-B                        | Gson                         |
| ----------------- | ----------------------------- | ---------------------------- |
| **إنشاء المحول**  | `JsonbBuilder.create()`       | `new Gson()`                 |
| **Object → JSON** | `jsonb.toJson(obj)`           | `gson.toJson(obj)`           |
| **JSON → Object** | `jsonb.fromJson(json, Class)` | `gson.fromJson(json, Class)` |

**الطريقتين متشابهين جداً!** ✅

---

# 🎨 الفصل 4: GsonBuilder (التخصيص)

## المشكلة:

الـ JSON اللي طبعناه فوق كان **كله في سطر واحد**:

```json
{ "name": "أحمد", "age": 25 }
```

**صعب القراءة!** لو عايز JSON منسق (Pretty Printing)؟

---

## الحل: GsonBuilder

```java
public class PrettyPrintingExample {
    public static void main(String[] args) {

        Student student = new Student();
        student.setName("أحمد");
        student.setAge(25);

        // ========== استخدام GsonBuilder ==========
        // 1. إنشاء Builder
        GsonBuilder builder = new GsonBuilder();

        // 2. تفعيل Pretty Printing
        // setPrettyPrinting() = ينسق الـ JSON بشكل جميل
        // بترجع: GsonBuilder (نفس الـ builder للربط)
        builder.setPrettyPrinting();

        // 3. بناء Gson Instance
        // create() = ينشئ Gson بالإعدادات اللي حددناها
        // بترجع: Gson
        Gson gson = builder.create();

        // 4. التحويل
        String json = gson.toJson(student);
        System.out.println(json);
    }
}
```

**Output (منسق!):**

```json
{
  "name": "أحمد",
  "age": 25
}
```

**أجمل بكتير!** ✨

---

## الطريقة الأقصر (Method Chaining):

```java
Gson gson = new GsonBuilder()
    .setPrettyPrinting()
    .create();
```

**ليه بيشتغل؟** لأن `setPrettyPrinting()` بترجع الـ `GsonBuilder` نفسه.

---

## خيارات أخرى في GsonBuilder:

```java
GsonBuilder builder = new GsonBuilder();

// 1. Pretty Printing (تنسيق جميل)
builder.setPrettyPrinting();

// 2. serializeNulls (يخزن الـ null values في JSON)
builder.serializeNulls();
// بدونها: {"name":"أحمد"}
// معاها: {"name":"أحمد","middleName":null}

// 3. setDateFormat (تنسيق التواريخ)
builder.setDateFormat("yyyy-MM-dd HH:mm:ss");

// 4. البناء النهائي
Gson gson = builder.create();
```

---

# 📁 الفصل 5: القراءة/الكتابة من/لملفات

## الكتابة لملف (Serialization):

```java
import com.google.gson.*;
import java.io.*;

public class WriteToFileExample {
    public static void main(String[] args) {

        try {
            // ========== 1. إنشاء Object ==========
            Student student = new Student();
            student.setName("أحمد علي");
            student.setAge(25);

            // ========== 2. إنشاء Gson ==========
            Gson gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();

            // ========== 3. الكتابة لملف ==========
            // FileWriter = كاتب ملفات
            // بتاخد: String (اسم الملف)
            FileWriter writer = new FileWriter("student.json");

            // كتابة JSON للملف
            writer.write(gson.toJson(student));

            // إغلاق الـ Writer (مهم جداً!)
            writer.close();

            System.out.println("تم الحفظ في student.json");

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

**النتيجة:** ملف `student.json` هيتعمل فيه:

```json
{
  "name": "أحمد علي",
  "age": 25
}
```

---

## القراءة من ملف (Deserialization):

```java
import com.google.gson.*;
import java.io.*;

public class ReadFromFileExample {
    public static void main(String[] args) {

        try {
            // ========== 1. إنشاء Gson ==========
            Gson gson = new Gson();

            // ========== 2. القراءة من ملف ==========
            // BufferedReader = قارئ ملفات بكفاءة
            // FileReader = يقرأ من ملف
            BufferedReader reader = new BufferedReader(
                new FileReader("student.json")
            );

            // fromJson بتاخد Reader مباشرة!
            // fromJson(reader, class)
            // بتاخد: Reader, Class
            // بترجع: T (الـ Object)
            Student student = gson.fromJson(reader, Student.class);

            // إغلاق الـ Reader
            reader.close();

            // ========== 3. استخدام النتيجة ==========
            System.out.println(student);

        } catch (FileNotFoundException e) {
            System.out.println("الملف مش موجود!");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

**Output:**

```
Student [ name: أحمد علي, age: 25 ]
```

---

## ليه BufferedReader مش FileReader مباشرة؟

```java
// ❌ بطيء - بيقرأ حرف حرف
FileReader reader = new FileReader("file.json");

// ✅ أسرع - بيقرأ في Chunks (أجزاء كبيرة)
BufferedReader reader = new BufferedReader(new FileReader("file.json"));
```

**تشبيه:**

```
FileReader = نقل المياه بكوب صغير (حرف حرف)
BufferedReader = نقل المياه بجردل كبير (أسرع)
```

---

# 🏋️ تمرين عملي نهائي

## المطلوب:

اعمل برنامج بيعمل الآتي:

1. Class اسمه `Product` فيه:

   - `String name`
   - `double price`
   - `boolean inStock`

2. أنشئ Product جديد (لابتوب، 15000، true)

3. احفظه في ملف `product.json` بـ **Pretty Printing**

4. اقرأ الملف تاني واطبع البيانات

<details>
<summary>💡 الحل الكامل</summary>

```java
import com.google.gson.*;
import java.io.*;

// Class
class Product {
    private String name;
    private double price;
    private boolean inStock;

    public Product() {}

    public void setName(String name) { this.name = name; }
    public void setPrice(double price) { this.price = price; }
    public void setInStock(boolean inStock) { this.inStock = inStock; }

    public String getName() { return name; }
    public double getPrice() { return price; }
    public boolean isInStock() { return inStock; }

    @Override
    public String toString() {
        return "Product [" + name + ", السعر: " + price +
               ", متاح: " + inStock + "]";
    }
}

// Main
public class ProductManager {
    public static void main(String[] args) {

        // 1-2. إنشاء Product
        Product laptop = new Product();
        laptop.setName("لابتوب");
        laptop.setPrice(15000);
        laptop.setInStock(true);

        // إنشاء Gson مع Pretty Printing
        Gson gson = new GsonBuilder()
            .setPrettyPrinting()
            .create();

        // 3. الحفظ
        try {
            FileWriter writer = new FileWriter("product.json");
            writer.write(gson.toJson(laptop));
            writer.close();
            System.out.println("✅ تم الحفظ!");
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 4. القراءة
        try {
            BufferedReader reader = new BufferedReader(
                new FileReader("product.json")
            );
            Product loadedProduct = gson.fromJson(reader, Product.class);
            reader.close();

            System.out.println("✅ تم القراءة: " + loadedProduct);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

**Output:**

```
✅ تم الحفظ!
✅ تم القراءة: Product [لابتوب, السعر: 15000.0, متاح: true]
```

</details>

---

# 📝 ملخص Gson

| العملية             | الكود                                            |
| ------------------- | ------------------------------------------------ |
| **إنشاء Gson بسيط** | `new Gson()`                                     |
| **إنشاء Gson مخصص** | `new GsonBuilder().setPrettyPrinting().create()` |
| **Object → JSON**   | `gson.toJson(object)`                            |
| **JSON → Object**   | `gson.fromJson(json, Class.class)`               |
| **كتابة لملف**      | `writer.write(gson.toJson(obj))`                 |
| **قراءة من ملف**    | `gson.fromJson(reader, Class.class)`             |

---

# 🎓 الخلاصة النهائية من السلسلة كاملة

```
Part 1: JSON-P (القراءة/الكتابة اليدوية)
  → JsonReader, JsonWriter, JsonObjectBuilder

Part 2: JSON-B (التحويل التلقائي)
  → Jsonb, toJson(), fromJson()

Part 3: Collections & Type Erasure
  → Arrays, Lists, Wrapper Classes, Nested Objects

Part 4: Gson (البديل من Google)
  → GsonBuilder, Pretty Printing, File I/O
```

---

**مبروك! خلصت السلسلة كاملة! 🎉**

**بالتوفيق في الامتحان! 🚀**
