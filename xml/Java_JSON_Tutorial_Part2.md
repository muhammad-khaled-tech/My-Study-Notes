# 📗 الجزء الثاني: JSON-B والتحويل التلقائي (Binding)

> **هدف هذا الجزء:** فهم JSON-B من الصفر - إزاي نحول Java Objects لـ JSON والعكس **تلقائياً**.

---

# 🎯 الفهرس

1. **الفلسفة** - ليه محتاجين Automatic Binding؟
2. **فهم Serialization vs Deserialization**
3. **إعداد المشروع** - Dependencies المطلوبة
4. **الخطوات الأولى** - أبسط مثال
5. **الـ Annotations** - التحكم في السلوك
6. **أمثلة متقدمة** - Collections و Dates

---

# 🤔 الفصل 1: الفلسفة - ليه محتاجين JSON-B؟

## المشكلة مع JSON-P:

في Part 1، استخدمنا JSON-P وكتبنا كود كتير:

```java
// قراءة من JSON
JsonObject jsonObj = reader.readObject();
String name = jsonObj.getString("name");
int age = jsonObj.getInt("age");

// كتابة لـ JSON
JsonObject jsonObj = Json.createObjectBuilder()
    .add("name", "أحمد")
    .add("age", 25)
    .build();
```

### تخيل معايا:

لو عندك **100 حقل** (field) في الـ Class... هتكتب 100 سطر `add()`؟! 😱

---

## الحل: JSON-B (Automatic Binding)

**الفكرة البسيطة:**

```
عندك Java Class جاهز → JSON-B يحوله لـ JSON تلقائياً
عندك JSON String → JSON-B يحوله لـ Object تلقائياً
```

### مثال عملي:

```java
// عندك الـ Class ده:
class Person {
    String name;
    int age;
}

// JSON-B بيعمل كل حاجة تلقائي:
Person p = new Person();
p.name = "أحمد";
p.age = 25;

Jsonb jsonb = JsonbBuilder.create();
String json = jsonb.toJson(p);  // ← سطر واحد بس!
// النتيجة: {"name":"أحمد","age":25}
```

**مقارنة:**
| الطريقة | عدد الأسطر | التحكم | السهولة |
|---------|-----------|--------|---------|
| JSON-P | 10+ سطر | كامل | صعبة |
| JSON-B | 2 سطر | محدود | سهلة جداً |

---

# 🔄 الفصل 2: فهم Serialization vs Deserialization

## مصطلحين مهمين جداً:

### 1. Serialization (التسلسل)

**التعريف:** تحويل Object لـ JSON String

```
Java Object  →  JSON String
```

**مثال من الحياة:**

```
كتاب (Object) → نسخه لـ PDF (JSON String) عشان تبعته بالإيميل
```

**في JSON-B:**

```java
String json = jsonb.toJson(object);  // Object → String
```

---

### 2. Deserialization (إلغاء التسلسل)

**التعريف:** تحويل JSON String لـ Object

```
JSON String  →  Java Object
```

**مثال من الحياة:**

```
PDF (JSON String) → طباعته ككتاب (Object) عشان تقراه
```

**في JSON-B:**

```java
Person person = jsonb.fromJson(json, Person.class);  // String → Object
```

---

## ليه التسميات دي؟

**"Serialization"** = **تحويل لـ سلسلة** (Series = سلسلة)

- الـ Object معقد (فيه fields و methods)
- بنحوله لـ "سلسلة نصية" بسيطة

**"Deserialization"** = **عكس العملية**

- من السلسلة النصية
- نرجع للـ Object المعقد

---

# 📦 الفصل 3: إعداد المشروع

## الـ Dependencies المطلوبة:

لاستخدام JSON-B، محتاجين **مكتبتين**:

### 1. JSON-B API (الواجهة)

```xml
<dependency>
    <groupId>jakarta.json.bind</groupId>
    <artifactId>jakarta.json.bind-api</artifactId>
    <version>3.0.0</version>
</dependency>
```

**إيه هي؟**

- `jakarta.json.bind` = Package للـ JSON-B
- الـ API = الواجهة (Interfaces) بدون تنفيذ

**تشبيه:**

```
API = عقد (Contract) بيقول "المكتبة لازم تعمل كذا وكذا"
```

---

### 2. Yasson (التنفيذ)

```xml
<dependency>
    <groupId>org.eclipse</groupId>
    <artifactId>yasson</artifactId>
    <version>3.0.3</version>
</dependency>
```

**إيه هي؟**

- **Yasson** = تنفيذ (Implementation) للـ JSON-B API
- من تطوير Eclipse Foundation

**تشبيه:**

```
API = عقد بيقول "لازم تكون فيه طباعة"
Yasson = الطابعة الفعلية
```

**بدائل Yasson:**

- **Apache Johnzon** (تنفيذ تاني من Apache)
- الاثنين بينفذوا نفس الـ API

---

## الـ Imports المطلوبة:

```java
import jakarta.json.bind.*;               // الأساسي
import jakarta.json.bind.annotation.*;    // للـ Annotations (اختياري)
```

**شرح:**

- `jakarta.json.bind.*` = كل classes الأساسية (`Jsonb`, `JsonbBuilder`)
- `jakarta.json.bind.annotation.*` = للتحكم في السلوك (`@JsonbProperty`, `@JsonbTransient`)

---

# 🔰 الفصل 4: الخطوات الأولى - أبسط مثال

## المثال: Person Class

### الخطوة 1: تعريف الـ Class

```java
// Person.java
public class Person {
    // الـ Fields لازم تكون public أو يكون فيها getters/setters
    public String name;
    public int age;

    // Constructor فارغ (MUST HAVE!)
    public Person() {
    }

    // Constructor للراحة
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
}
```

**ملاحظات مهمة جداً:**

| القاعدة                                         | السبب                                 |
| ----------------------------------------------- | ------------------------------------- |
| **لازم يكون فيه Constructor فارغ**              | JSON-B بيستخدمه عشان ينشئ Object جديد |
| **الـ Fields لازم public** (أو getters/setters) | عشان JSON-B يقدر يوصلها               |
| **الـ Class لازم يكون public**                  | عشان JSON-B يشوفه                     |

---

### الخطوة 2: Serialization (Object → JSON)

```java
import jakarta.json.bind.*;

public class SerializationExample {
    public static void main(String[] args) {

        // ========== 1. إنشاء Object ==========
        Person person = new Person("أحمد", 25);

        // ========== 2. إنشاء Jsonb Instance ==========
        // JsonbBuilder.create() = مصنع بيصنع Jsonb
        // بترجع: Jsonb (المحول)
        Jsonb jsonb = JsonbBuilder.create();

        // ========== 3. التحويل لـ JSON ==========
        // toJson(object) = حول الـ Object لـ JSON String
        // بتاخد: Object (أي object)
        // بترجع: String (JSON)
        String json = jsonb.toJson(person);

        // ========== 4. الطباعة ==========
        System.out.println(json);
    }
}
```

**Output:**

```json
{ "age": 25, "name": "أحمد" }
```

**لاحظ:**

- ✅ كل الـ fields اتحولت تلقائياً!
- ✅ الأنواع اتعرفت تلقائياً (`int` → number, `String` → string)
- ⚠️ الترتيب ممكن يختلف (JSON unordered)

---

### الخطوة 3: Deserialization (JSON → Object)

```java
import jakarta.json.bind.*;

public class DeserializationExample {
    public static void main(String[] args) {

        // ========== 1. JSON String ==========
        String json = "{\"name\":\"سارة\",\"age\":22}";

        // ========== 2. إنشاء Jsonb Instance ==========
        Jsonb jsonb = JsonbBuilder.create();

        // ========== 3. التحويل لـ Object ==========
        // fromJson(json, class) = حول JSON String لـ Object
        // بتاخد: String (JSON), Class (النوع المطلوب)
        // بترجع: T (الobject من النوع المحدد)
        Person person = jsonb.fromJson(json, Person.class);

        // ========== 4. استخدام الـ Object ==========
        System.out.println("الاسم: " + person.name);
        System.out.println("العمر: " + person.age);
    }
}
```

**Output:**

```
الاسم: سارة
العمر: 22
```

---

## شرح تفصيلي للـ Methods:

### 1. `JsonbBuilder.create()`

**Return Type:** `Jsonb`

**الغرض:** ينشئ instance من `Jsonb` (المحول)

**ليه مش `new Jsonb()`؟**

- `Jsonb` هو **Interface** (مش class)
- الـ `JsonbBuilder` هو **Factory** (مصنع) بينشئ التنفيذ الفعلي

**تشبيه:**

```
أنت مش بتعمل طابعة بإيدك
بتطلب من المصنع (Builder) يصنعلك واحدة
```

---

### 2. `jsonb.toJson(object)`

**Signature:** `String toJson(Object object)`

**Parameters:**

- `object` → أي Java Object

**Return Type:** `String`

**الغرض:** يحول Object لـ JSON String

**كيف بيشتغل؟**

1. بيفحص الـ Object (Reflection)
2. بيلف على كل الـ public fields
3. بيحول كل field لـ JSON value
4. بيرجع String

---

### 3. `jsonb.fromJson(json, class)`

**Signature:** `<T> T fromJson(String json, Class<T> clazz)`

**Parameters:**

- `json` → JSON String
- `clazz` → الـ Class المطلوب (مثل `Person.class`)

**Return Type:** `T` (نفس النوع اللي طلبته)

**الغرض:** يحول JSON String لـ Object

**كيف بيشتغل؟**

1. بيقرأ JSON String
2. بينشئ Object جديد (باستخدام Constructor الفارغ)
3. بيملأ الـ fields من JSON
4. بيرجع الـ Object

---

# 🏋️ تمرين عملي 1

## المطلوب:

عندك الـ Class ده:

```java
class Product {
    public String name;
    public double price;
    public Product() {}
}
```

**اعمل الآتي:**

1. أنشئ `Product` اسمه "لابتوب" سعره 15000
2. حوله لـ JSON
3. اطبع الـ JSON
4. حول الـ JSON تاني لـ `Product` object
5. اطبع الاسم والسعر

<details>
<summary>💡 الحل</summary>

```java
import jakarta.json.bind.*;

public class ProductTest {
    public static void main(String[] args) {
        // 1. إنشاء Object
        Product p = new Product();
        p.name = "لابتوب";
        p.price = 15000;

        // 2-3. تحويل وطباعة
        Jsonb jsonb = JsonbBuilder.create();
        String json = jsonb.toJson(p);
        System.out.println("JSON: " + json);

        // 4-5. إرجاع واستخدام
        Product p2 = jsonb.fromJson(json, Product.class);
        System.out.println("الاسم: " + p2.name);
        System.out.println("السعر: " + p2.price);
    }
}
```

</details>

---

**يتبع في Part 3...** (هشرح Annotations و Collections و Nested Objects)

**بالتوفيق! 🚀**
