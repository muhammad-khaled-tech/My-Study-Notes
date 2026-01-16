# 📖 شرح الأساسيات: JSON في Java من الصفر

---

## الجزء الأول: أنواع مكتبات JSON في Java

### 🤔 أولاً: ليه فيه أكتر من مكتبة؟

تخيل إنك عايز تاكل أكل. عندك خيارين:

1. **تطبخ بنفسك** (تتحكم في كل حاجة) ← ده زي **JSON-P**
2. **تطلب من مطعم** (جاهز ومريح) ← ده زي **JSON-B**

---

## 📊 جدول مقارنة كل الأنواع

| المكتبة     | الاسم الكامل    | الفكرة                      | مستوى التحكم | السهولة  |
| ----------- | --------------- | --------------------------- | ------------ | -------- |
| **JSON-P**  | JSON Processing | قراءة/كتابة JSON يدوياً     | عالي جداً    | صعب شوية |
| **JSON-B**  | JSON Binding    | تحويل تلقائي Objects ↔ JSON | منخفض        | سهل جداً |
| **Gson**    | Google JSON     | زي JSON-B بس من Google      | منخفض        | سهل جداً |
| **Jackson** | Jackson JSON    | الأشهر في المشاريع الكبيرة  | متوسط        | متوسط    |

---

## 🔵 JSON-P (JSON Processing)

### الفكرة:

أنت بتقرأ JSON حرف حرف وبتبني JSON قطعة قطعة. **تحكم كامل**.

### امتى نستخدمه؟

- لما JSON معقد ومش عارف شكله مسبقاً
- لما محتاج تقرأ جزء معين من JSON كبير
- لما مفيش Class جاهز يمثل البيانات

### المكونات:

```
JSON-P
├── للقراءة (Consuming)
│   ├── JsonReader      ← يقرأ JSON ويحوله لـ Objects
│   ├── JsonObject      ← يمثل { }
│   └── JsonArray       ← يمثل [ ]
│
└── للكتابة (Producing)
    ├── JsonWriter           ← يكتب JSON لملف أو String
    ├── JsonObjectBuilder    ← يبني { }
    └── JsonArrayBuilder     ← يبني [ ]
```

---

## 🟢 JSON-B (JSON Binding)

### الفكرة:

أنت عندك Java Class، المكتبة بتحوله لـ JSON تلقائي والعكس. **سحر!**

### امتى نستخدمه؟

- لما عندك Classes جاهزة (زي Student, Dog, Product)
- لما عايز كود نضيف وقصير
- معظم الحالات العادية

### المكونات:

```
JSON-B
└── Jsonb (Interface رئيسي)
    ├── toJson(object)     ← Object → JSON String
    └── fromJson(json)     ← JSON String → Object
```

---

## 🔴 الفرق العملي بمثال

### نفس المهمة بـ JSON-P vs JSON-B:

**المهمة**: عندنا JSON ونريد نقرأ الاسم والعمر

```json
{ "name": "أحمد", "age": 25 }
```

#### بـ JSON-P (الطريقة اليدوية):

```java
// 7 أسطر كود!
String json = "{\"name\":\"أحمد\",\"age\":25}";
JsonReader reader = Json.createReader(new StringReader(json));
JsonObject obj = reader.readObject();
reader.close();
String name = obj.getString("name");
int age = obj.getInt("age");
System.out.println(name + " - " + age);
```

#### بـ JSON-B (الطريقة التلقائية):

```java
// 3 أسطر كود!
String json = "{\"name\":\"أحمد\",\"age\":25}";
Person p = JsonbBuilder.create().fromJson(json, Person.class);
System.out.println(p.name + " - " + p.age);
```

---

# الجزء الثاني: شرح كل Class وكل Function

---

## 📘 JsonReader

### يعني إيه؟

**JsonReader** = "قارئ JSON" - بياخد JSON String أو File ويقرأه.

### إزاي نعمله؟

```java
// من String
JsonReader reader = Json.createReader(new StringReader(jsonString));

// من File
JsonReader reader = Json.createReader(new FileInputStream("file.json"));
```

### الـ Methods:

| Method         | بترجع إيه       | بتعمل إيه                      |
| -------------- | --------------- | ------------------------------ |
| `readObject()` | `JsonObject`    | يقرأ `{ }` ويرجع JsonObject    |
| `readArray()`  | `JsonArray`     | يقرأ `[ ]` ويرجع JsonArray     |
| `read()`       | `JsonStructure` | يقرأ أي حاجة (Object أو Array) |
| `close()`      | `void`          | يقفل الـ Reader (مهم!)         |

### مثال كامل:

```java
String json = "{\"name\":\"سارة\",\"age\":22}";

// 1. إنشاء Reader
JsonReader reader = Json.createReader(new StringReader(json));

// 2. قراءة الـ JSON كـ Object
JsonObject person = reader.readObject();  // يرجع JsonObject

// 3. قفل الـ Reader (لازم!)
reader.close();

// 4. استخدام الـ JsonObject
System.out.println(person);  // {"name":"سارة","age":22}
```

---

## 📗 JsonObject

### يعني إيه؟

**JsonObject** = "كائن JSON" - يمثل `{ }` في JSON.

زي الـ `Map<String, Value>` - كل key ليها value.

### إزاي نجيبه؟

```java
// من JsonReader
JsonObject obj = reader.readObject();

// أو نبنيه من الصفر
JsonObject obj = Json.createObjectBuilder()
    .add("name", "أحمد")
    .build();
```

### الـ Methods (للقراءة):

| Method                 | بترجع إيه     | بتعمل إيه        | مثال                                |
| ---------------------- | ------------- | ---------------- | ----------------------------------- |
| `getString("key")`     | `String`      | تجيب نص          | `obj.getString("name")` → `"أحمد"`  |
| `getInt("key")`        | `int`         | تجيب رقم صحيح    | `obj.getInt("age")` → `25`          |
| `getBoolean("key")`    | `boolean`     | تجيب true/false  | `obj.getBoolean("active")` → `true` |
| `getJsonObject("key")` | `JsonObject`  | تجيب Object جواه | `obj.getJsonObject("address")`      |
| `getJsonArray("key")`  | `JsonArray`   | تجيب Array جواه  | `obj.getJsonArray("phones")`        |
| `keySet()`             | `Set<String>` | كل الـ keys      | `obj.keySet()` → `["name", "age"]`  |

### مثال:

```java
// JSON: {"name":"أحمد", "age":25, "active":true}

String name = obj.getString("name");      // "أحمد"
int age = obj.getInt("age");              // 25
boolean active = obj.getBoolean("active"); // true
```

---

## 📙 JsonArray

### يعني إيه؟

**JsonArray** = "مصفوفة JSON" - يمثل `[ ]` في JSON.

زي الـ `List` - قائمة عناصر.

### الـ Methods:

| Method                 | بترجع إيه    | بتعمل إيه                       |
| ---------------------- | ------------ | ------------------------------- |
| `getString(index)`     | `String`     | تجيب النص في الموقع index       |
| `getInt(index)`        | `int`        | تجيب الرقم في الموقع index      |
| `getJsonObject(index)` | `JsonObject` | تجيب الـ Object في الموقع index |
| `size()`               | `int`        | عدد العناصر                     |

### مثال:

```java
// JSON: ["Java", "Python", "JavaScript"]

JsonArray skills = obj.getJsonArray("skills");
String first = skills.getString(0);   // "Java"
String second = skills.getString(1);  // "Python"
int count = skills.size();            // 3

// Loop على كل العناصر
for (JsonValue skill : skills) {
    System.out.println(skill);
}
```

---

## 📕 JsonObjectBuilder

### يعني إيه؟

**JsonObjectBuilder** = "باني كائن JSON" - بتستخدمه عشان **تبني** JSON Object جديد.

### الـ Methods:

| Method              | بترجع إيه           | بتعمل إيه                          |
| ------------------- | ------------------- | ---------------------------------- |
| `add("key", value)` | `JsonObjectBuilder` | تضيف key-value                     |
| `build()`           | `JsonObject`        | تخلص البناء وترجع JsonObject نهائي |

### ليه `add()` بترجع JsonObjectBuilder؟

عشان تقدر تعمل **Method Chaining** (تربط methods ورا بعض):

```java
JsonObject person = Json.createObjectBuilder()
    .add("name", "محمد")      // ← يرجع Builder
    .add("age", 23)           // ← يرجع Builder
    .add("city", "القاهرة")   // ← يرجع Builder
    .build();                  // ← يرجع JsonObject النهائي
```

---

## 📒 JsonWriter

### يعني إيه؟

**JsonWriter** = "كاتب JSON" - بياخد JsonObject وبيكتبه لملف أو String.

### إزاي نعمله؟

```java
// للكتابة في Console
JsonWriter writer = Json.createWriter(System.out);

// للكتابة في String
StringWriter sw = new StringWriter();
JsonWriter writer = Json.createWriter(sw);

// للكتابة في File
JsonWriter writer = Json.createWriter(new FileWriter("output.json"));
```

### الـ Methods:

| Method             | بترجع إيه | بتعمل إيه              |
| ------------------ | --------- | ---------------------- |
| `writeObject(obj)` | `void`    | تكتب JsonObject        |
| `writeArray(arr)`  | `void`    | تكتب JsonArray         |
| `close()`          | `void`    | تقفل الـ Writer (مهم!) |

### مثال:

```java
// 1. بناء الـ Object
JsonObject person = Json.createObjectBuilder()
    .add("name", "علي")
    .add("age", 30)
    .build();

// 2. كتابة لملف
JsonWriter writer = Json.createWriter(new FileWriter("person.json"));
writer.writeObject(person);
writer.close();

// الملف هيحتوي: {"name":"علي","age":30}
```

---

## 📓 Jsonb (JSON-B)

### يعني إيه؟

**Jsonb** = "رابط JSON" - بيحول Objects لـ JSON والعكس **تلقائياً**.

### إزاي نعمله؟

```java
Jsonb jsonb = JsonbBuilder.create();
```

### الـ Methods:

| Method                  | بترجع إيه | بتعمل إيه                  |
| ----------------------- | --------- | -------------------------- |
| `toJson(object)`        | `String`  | تحول Object لـ JSON String |
| `fromJson(json, Class)` | `T`       | تحول JSON String لـ Object |

### مثال كامل:

```java
// الـ Class
public class Dog {
    public String name;
    public int age;
}

// استخدام JSON-B
Jsonb jsonb = JsonbBuilder.create();

// Object → JSON (Serialize)
Dog dog = new Dog();
dog.name = "Rex";
dog.age = 3;
String json = jsonb.toJson(dog);
// النتيجة: {"age":3,"name":"Rex"}

// JSON → Object (Deserialize)
String input = "{\"name\":\"Buddy\",\"age\":5}";
Dog newDog = jsonb.fromJson(input, Dog.class);
// newDog.name = "Buddy"
// newDog.age = 5
```

---

# 🎯 ملخص سريع

```
┌─────────────────────────────────────────────────────────────┐
│                    JSON-P (يدوي)                            │
├─────────────────────────────────────────────────────────────┤
│  JsonReader     →  يقرأ JSON                                │
│  JsonObject     →  يمثل { }                                 │
│  JsonArray      →  يمثل [ ]                                 │
│  JsonWriter     →  يكتب JSON                                │
│  JsonObjectBuilder → يبني { } جديد                          │
│  JsonArrayBuilder  → يبني [ ] جديد                          │
├─────────────────────────────────────────────────────────────┤
│                    JSON-B (تلقائي)                          │
├─────────────────────────────────────────────────────────────┤
│  Jsonb.toJson(obj)        →  Object → JSON                  │
│  Jsonb.fromJson(json, X)  →  JSON → Object                  │
└─────────────────────────────────────────────────────────────┘
```

**بالتوفيق في المناقشة! 🚀**
