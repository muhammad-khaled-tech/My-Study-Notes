# 📚 محاضرة XML و JSON الكاملة

---

# 🔷 الفصل الأول: XML (eXtensible Markup Language)

---

## 1.1 مقدمة عن XML

### ما هو XML؟

**XML = eXtensible Markup Language** (لغة الترميز القابلة للتوسيع)

XML هي لغة لوصف البيانات بشكل هرمي منظم باستخدام **tags** مخصصة.

### لماذا "قابلة للتوسيع"؟

لأنك **أنت** اللي بتعمل الـ tags بتاعتك! مش زي HTML اللي الـ tags محددة.

```xml
<!-- في HTML: tags محددة مسبقاً -->
<h1>عنوان</h1>
<p>فقرة</p>

<!-- في XML: أنت بتعمل tags خاصة بيك -->
<طالب>
    <الاسم>أحمد</الاسم>
    <العمر>22</العمر>
</طالب>
```

---

## 1.2 XML Declaration (الإعلان)

كل ملف XML لازم يبدأ بـ **XML Prolog**:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
```

### شرح كل جزء:

| Parameter    | القيم الممكنة                   | الوصف                            | إجباري؟              |
| ------------ | ------------------------------- | -------------------------------- | -------------------- |
| `version`    | `1.0` أو `1.1`                  | إصدار XML المستخدم               | ✅ نعم               |
| `encoding`   | `UTF-8`, `UTF-16`, `ISO-8859-1` | ترميز الحروف                     | لا (الافتراضي UTF-8) |
| `standalone` | `yes` أو `no`                   | هل يعتمد على ملفات خارجية (DTD)؟ | لا (الافتراضي no)    |

### قواعد مهمة:

- الـ XML declaration **اختياري**، لكن لو موجود **لازم يكون أول سطر**
- **الترتيب مهم**: version → encoding → standalone
- الـ XML declaration **مفيش له closing tag** (مش بنكتب `<?/xml?>`)
- الـ Parameter names **case-sensitive** ولازم تكون **lowercase**

### أمثلة:

```xml
<!-- ✅ صحيح -->
<?xml version="1.0" encoding="UTF-8"?>

<!-- ✅ صحيح - single quotes -->
<?xml version='1.0' encoding='UTF-8'?>

<!-- ❌ غلط - ترتيب خاطئ -->
<?xml encoding="UTF-8" version="1.0"?>

<!-- ❌ غلط - حروف كبيرة -->
<?xml VERSION="1.0"?>
```

---

## 1.3 XML Documents Must Have a Root Element

كل ملف XML لازم يكون فيه **عنصر جذر واحد** (Root Element) يحتوي كل العناصر التانية:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!-- note هو الـ Root Element -->
<note>
    <to>آية</to>
    <from>أمين</from>
    <heading>تذكير</heading>
    <body>لا تنساني هذا الأسبوع!</body>
</note>
```

### البنية الهرمية:

```
<root>          ← الجذر (Parent لكل العناصر)
    <child>     ← ابن الجذر
        <subchild>...</subchild>  ← حفيد الجذر
    </child>
</root>
```

---

## 1.4 قواعد XML Syntax (بالتفصيل)

### القاعدة 1: كل Element لازم يكون له Closing Tag

```xml
<!-- ✅ صحيح -->
<paragraph>هذه فقرة.</paragraph>

<!-- ✅ صحيح - Self-closing للعناصر الفاضية -->
<line-break />
<br/>

<!-- ❌ غلط - مفيش closing tag -->
<paragraph>هذه فقرة.
```

> ⚠️ **ملاحظة**: الـ XML prolog `<?xml ... ?>` مش محتاج closing tag لأنه مش element!

---

### القاعدة 2: الـ Tags حساسة لحجم الحروف (Case Sensitive)

```xml
<!-- ✅ صحيح -->
<message>هذا صحيح</message>

<!-- ❌ غلط - Opening و Closing مختلفين -->
<Message>هذا خطأ</message>

<!-- ❌ غلط -->
<MESSAGE>هذا خطأ</message>
```

---

### القاعدة 3: العناصر لازم تكون متداخلة بشكل صحيح (Properly Nested)

```xml
<!-- ❌ غلط - تداخل خاطئ -->
<b><i>نص عريض ومائل</b></i>

<!-- ✅ صحيح - تداخل صحيح -->
<b><i>نص عريض ومائل</i></b>
```

**القاعدة**: اللي اتفتح الأخير لازم يتقفل الأول!

---

### القاعدة 4: قيم الـ Attributes لازم تكون بين Quotes

```xml
<!-- ✅ صحيح - Double quotes -->
<note date="12/11/2020">
    <to>آية</to>
</note>

<!-- ✅ صحيح - Single quotes -->
<note date='12/11/2020'>
    <to>آية</to>
</note>

<!-- ❌ غلط - بدون quotes -->
<note date=12/11/2020>
```

---

## 1.5 Entity References (مراجع الكيانات)

### المشكلة:

بعض الحروف ليها معنى خاص في XML:

- `<` معناها بداية tag جديد
- `&` معناها بداية entity reference

### الحل: Entity References

```xml
<!-- ❌ غلط - هيعمل error -->
<message>الراتب < 1000</message>

<!-- ✅ صحيح - استخدام Entity Reference -->
<message>الراتب &lt; 1000</message>
```

### الـ 5 Entity References المحجوزة:

| Entity   | الحرف | الاسم          |
| -------- | ----- | -------------- |
| `&lt;`   | `<`   | less than      |
| `&gt;`   | `>`   | greater than   |
| `&amp;`  | `&`   | ampersand      |
| `&apos;` | `'`   | apostrophe     |
| `&quot;` | `"`   | quotation mark |

> 💡 **نصيحة**: `<` و `&` ممنوعين تماماً. الباقي مستحسن استبدالهم.

---

## 1.6 CDATA Sections

### المشكلة:

لو عندك نص طويل فيه حروف محجوزة كتير، هتتعب تستبدلهم واحد واحد!

### الحل: CDATA Section

CDATA = **C**haracter **DATA** - 
بتقول للـ Parser: "متقرأش ده كـ XML، اعتبره نص عادي!"

### Syntax:

```xml
<![CDATA[
    أي حاجة هنا مش هتتقرأ كـ XML!
    حتى < و > و & كلها هتبقى نص عادي.
]]>
```

### مثال عملي:

```xml
<description>
    <![CDATA[
        كود HTML مثلاً:
        <html>
            <body>
                <h1>عنوان</h1>
                <p>فقرة & نص</p>
            </body>
        </html>

        أو رموز رياضية: 5 < 10 && 20 > 15
    ]]>
</description>
```

### استخدامات CDATA:

- كود JavaScript جوه XML
- كود HTML
- نصوص فيها رموز كتير
- أي محتوى مش عايزه يتقرأ كـ XML

---

## 1.7 Comments (التعليقات)

```xml
<!-- هذا تعليق في XML -->

<!--
    تعليق
    على أكثر
    من سطر
-->
```

### قواعد التعليقات:

```xml
<!-- ✅ صحيح -->

<!-- ❌ غلط - مينفعش -- في النص -->
<!-- تعليق -- غلط -->
```

---

## 1.8 White-space و New Lines

### XML بيحافظ على المسافات:

```xml
<!-- XML: المسافات محفوظة -->
<text>Hello           World</text>
<!-- النتيجة: "Hello           World" -->

<!-- HTML: المسافات بتتحول لمسافة واحدة -->
<p>Hello           World</p>
<!-- النتيجة: "Hello World" -->
```

### New Line:

- **Windows**: يحفظ CR+LF (Carriage Return + Line Feed)
- **Unix/Mac**: يحفظ LF فقط
- **XML**: يخزن كـ LF دايماً

---

## 1.9 Well-Formed XML

ملف XML يعتبر **Well-Formed** لو:

| #   | القاعدة                     | مثال صحيح              | مثال خاطئ                |
| --- | --------------------------- | ---------------------- | ------------------------ |
| 1   | عنصر جذر واحد               | `<root>...</root>`     | عنصرين root              |
| 2   | كل element له closing tag   | `<x></x>` أو `<x/>`    | `<x>` بدون closing       |
| 3   | تداخل صحيح                  | `<x><y></y></x>`       | `<x><y></x></y>`         |
| 4   | Attribute values بين quotes | `id="1"`               | `id=1`                   |
| 5   | أسماء Tags صحيحة            | تبدأ بحرف، بدون مسافات | تبدأ برقم أو فيها مسافات |
| 6   | Attribute مش مكرر           | `<x id="1">`           | `<x id="1" id="2">`      |

---

## 1.10 XML Elements بالتفصيل

### Element يحتوي على:

```xml
<bookstore>                              <!-- Element Content -->
    <book category="children">           <!-- Attribute -->
        <title>Harry Potter</title>      <!-- Text Content -->
        <author>J K. Rowling</author>
        <year>2005</year>
        <price>29.99</price>
    </book>
</bookstore>
```

| نوع المحتوى         | الوصف       | مثال                                  |
| ------------------- | ----------- | ------------------------------------- |
| **Text Content**    | نص فقط      | `<title>Harry Potter</title>`         |
| **Element Content** | عناصر تانية | `<book>` يحتوي `<title>` و `<author>` |
| **Mixed Content**   | نص + عناصر  | `<p>Hello <b>World</b></p>`           |
| **Empty**           | فاضي        | `<br/>`                               |

---

## 1.11 Empty Elements

عنصر مفيهوش محتوى:

```xml
<!-- طريقتين متكافئتين -->
<element></element>
<element/>           <!-- Self-Closing - الأكثر شيوعاً -->

<!-- أمثلة عملية -->
<br/>
<image src="photo.jpg" alt="صورة"/>
<status active="true"/>
```

---

## 1.12 XML Naming Rules

### قواعد تسمية الـ Elements:

| القاعدة                          | ✅ صحيح                        | ❌ خطأ            |
| -------------------------------- | ------------------------------ | ----------------- |
| يبدأ بحرف أو underscore          | `name`, `_id`                  | `1name`, `-id`    |
| يحتوي حروف، أرقام، `-`, `_`, `.` | `first_name`, `item-1`, `a.b`  | `first name`      |
| منع الحروف xml في البداية        | `xmlData` غلط، `xmalData` صحيح | `xml_data`, `XML` |
| Case Sensitive                   | `Name` ≠ `name`                | --                |
| بدون مسافات                      | `firstName`                    | `first Name`      |

---

## 1.13 Attributes vs Elements

### متى نستخدم Attribute؟ متى نستخدم Element؟

```xml
<!-- باستخدام Attribute -->
<person gender="female">
    <name>سارة</name>
</person>

<!-- باستخدام Element -->
<person>
    <gender>female</gender>
    <name>سارة</name>
</person>
```

### قواعد عامة:

| استخدم Attribute لـ     | استخدم Element لـ       |
| ----------------------- | ----------------------- |
| Metadata (بيانات وصفية) | Data (البيانات الفعلية) |
| IDs و References        | محتوى طويل              |
| قيم بسيطة               | محتوى معقد أو متداخل    |
| لا يتكرر                | ممكن يتكرر              |

### Attributes لها قيود:

- ❌ مش ممكن تحتوي structured data
- ❌ مش ممكن تتكرر
- ❌ صعب توسيعها للمستقبل

---

# 🔶 الفصل الثاني: JSON (JavaScript Object Notation)

---

## 2.1 مقدمة عن JSON

### ما هو JSON؟

**JSON = JavaScript Object Notation** (تدوين كائنات جافاسكريبت)

- لغة خفيفة لتبادل البيانات النصية
- مستقلة عن لغات البرمجة (كل اللغات تدعمها)
- أصغر وأسرع وأسهل من XML

### ملفات JSON:

- الامتداد: `.json`
- MIME Type: `application/json`

---

## 2.2 JSON vs XML

### التشابهات:

| الخاصية                      | JSON | XML |
| ---------------------------- | ---- | --- |
| نص عادي (Plain Text)         | ✅   | ✅  |
| مقروء للبشر (Human Readable) | ✅   | ✅  |
| هرمي (Hierarchical)          | ✅   | ✅  |
| يُقرأ بـ JavaScript          | ✅   | ✅  |
| ينتقل عبر AJAX               | ✅   | ✅  |

### الاختلافات:

| الخاصية            | JSON                       | XML         |
| ------------------ | -------------------------- | ----------- |
| Closing Tags       | ❌ لا                      | ✅ نعم      |
| الحجم              | أصغر 📦                    | أكبر 📦     |
| السرعة             | أسرع 🐇                    | أبطأ 🐢     |
| Parsing في JS      | `eval()` أو `JSON.parse()` | DOM Parsing |
| يدعم Arrays مباشرة | ✅ نعم                     | ❌ لا       |

---

## 2.3 لماذا JSON؟

### للـ AJAX:

**باستخدام XML:**

1. جلب ملف XML
2. استخدام XML DOM للتنقل في الملف
3. استخراج القيم وتخزينها

**باستخدام JSON:**

1. جلب JSON String
2. `eval()` أو `JSON.parse()` - خلاص!

---

## 2.4 بنية JSON

JSON مبني على هيكلين:

### 1. Object (كائن):

```json
{
  "firstName": "أحمد",
  "lastName": "عمر"
}
```

- يبدأ بـ `{` وينتهي بـ `}`
- مجموعة من name/value pairs
- كل name يتبعه `:`
- الـ pairs مفصولة بـ `,`

### 2. Array (مصفوفة):

```json
{
  "employees": [
    { "firstName": "جون", "lastName": "دو" },
    { "firstName": "آنا", "lastName": "سميث" },
    { "firstName": "بيتر", "lastName": "جونز" }
  ]
}
```

- يبدأ بـ `[` وينتهي بـ `]`
- قائمة مرتبة من القيم
- القيم مفصولة بـ `,`

---

## 2.5 أنواع القيم في JSON (Value Types)

| النوع       | المثال                | الوصف                |
| ----------- | --------------------- | -------------------- |
| **String**  | `"name": "أمين"`      | نص بين double quotes |
| **Number**  | `"id": 100`           | رقم (صحيح أو عشري)   |
| **Boolean** | `"flag": true`        | `true` أو `false`    |
| **null**    | `"myVar": null`       | قيمة فارغة           |
| **Object**  | `{"id": 1, "x": "y"}` | كائن متداخل          |
| **Array**   | `"students": [...]`   | مصفوفة               |

---

## 2.6 String في JSON

```json
{
  "message": "Hello\nWorld",
  "path": "C:\\Users\\Name",
  "quote": "He said \"Hi\""
}
```

### Escape Characters:

| Escape   | المعنى          |
| -------- | --------------- |
| `\"`     | Double quote    |
| `\\`     | Backslash       |
| `\/`     | Forward slash   |
| `\b`     | Backspace       |
| `\f`     | Form feed       |
| `\n`     | New line        |
| `\r`     | Carriage return |
| `\t`     | Tab             |
| `\uXXXX` | Unicode         |

---

## 2.7 Number في JSON

```json
{
  "integer": 100,
  "negative": -50,
  "decimal": 3.14,
  "scientific": 1.5e10
}
```

> ⚠️ **ملاحظة**: JSON لا يدعم Octal أو Hexadecimal (زي `0x1F` أو `017`)

---

## 2.8 مثال شامل

```json
{
  "book": [
    {
      "id": 100,
      "language": "Java",
      "edition": "third",
      "author": "Herbert Schildt"
    },
    {
      "id": 200,
      "language": "C++",
      "edition": "second",
      "author": "E.Balagurusamy"
    }
  ]
}
```

---

## 2.9 JSON Technologies

| التقنية          | الوصف                   | المقابل في XML |
| ---------------- | ----------------------- | -------------- |
| **JSON Schema**  | للتحقق من صحة JSON      | XSD            |
| **JSON Pointer** | للتنقل في JSON          | XPath          |
| **JSON-P**       | Java API للـ Processing | JAXP           |
| **JSON-B**       | Java API للـ Binding    | JAXB           |

---

# 🔷 الفصل الثالث: JSON-P (JSON Processing)

---

## 3.1 مقدمة

**JSON-P = Java API for JSON Processing**

- **JSON-P 1.0**: JEE7 - JSR 353
- **JSON-P 1.1**: JEE8 - JSR 374

### أهداف الـ API:

1. **Streaming**: إنتاج/استهلاك JSON (زي StAX للـ XML)
2. **Object Model**: بناء Object Model (زي DOM للـ XML)

---

## 3.2 JSON-P APIs Overview

```
┌────────────────────────────────────────────────────────────┐
│                      JSON-P APIs                           │
├─────────────┬──────────────────────────────────────────────┤
│             │       Consuming       │      Producing       │
├─────────────┼───────────────────────┼──────────────────────┤
│ Streaming   │     JsonParser        │    JsonGenerator     │
│ (Low-level) │                       │                      │
├─────────────┼───────────────────────┼──────────────────────┤
│ Object Model│     JsonReader        │    JsonWriter        │
│ (High-level)│                       │  JsonObjectBuilder   │
│             │                       │  JsonArrayBuilder    │
└─────────────┴───────────────────────┴──────────────────────┘
```

---

## 3.3 Streaming API

### متى نستخدمها؟

- لما محتاج **جزء معين** من JSON كبير
- لما **محتاجش** access عشوائي للبيانات
- لما الـ **Performance** مهم جداً

### JsonParser:

- يقرأ JSON بشكل **تسلسلي** (Forward-only)
- Event-based (Pull Parsing)
- **Low-level API**

---

## 3.4 Object Model API

### الفكرة:

يحول JSON لـ **Object Model** في الذاكرة (زي DOM للـ XML)

### الـ Types الرئيسية:

| Type         | يمثل                    | المقابل في JSON      |
| ------------ | ----------------------- | -------------------- |
| `JsonObject` | Map of name/value pairs | `{ }`                |
| `JsonArray`  | Ordered list of values  | `[ ]`                |
| `JsonValue`  | Any JSON value          | String, Number, etc. |

---

## 3.5 Consuming JSON (JsonReader)

### إنشاء JsonReader:

```java
// من InputStream
JsonReader reader = Json.createReader(new FileInputStream("data.json"));

// من Reader
JsonReader reader = Json.createReader(new FileReader("data.json"));

// من String
JsonReader reader = Json.createReader(new StringReader(jsonString));
```

### قراءة البيانات:

```java
// Step 1: إنشاء Reader
JsonReader reader = Json.createReader(new StringReader(json));

// Step 2: قراءة الـ JSON كـ Object
JsonObject obj = reader.readObject();  // لـ { }
// أو
JsonArray arr = reader.readArray();    // لـ [ ]
// أو
JsonStructure struct = reader.read();  // لأي نوع

// Step 3: إغلاق الـ Reader
reader.close();
```

### استخراج البيانات من JsonObject:

```java
JsonObject person = reader.readObject();

// getString - للنصوص
String name = person.getString("name");

// getInt - للأرقام الصحيحة
int age = person.getInt("age");

// getBoolean - للـ true/false
boolean active = person.getBoolean("active");

// getJsonObject - لـ nested object
JsonObject address = person.getJsonObject("address");

// getJsonArray - للـ arrays
JsonArray phones = person.getJsonArray("phones");
```

### استخراج البيانات من JsonArray:

```java
JsonArray skills = person.getJsonArray("skills");

// بالـ index
String first = skills.getString(0);
String second = skills.getString(1);

// عدد العناصر
int count = skills.size();

// Loop
for (JsonValue skill : skills) {
    System.out.println(skill);
}
```

---

## 3.6 Producing JSON (JsonWriter + Builders)

### JsonObjectBuilder:

```java
JsonObject person = Json.createObjectBuilder()
    .add("firstName", "Duke")
    .add("lastName", "Java")
    .add("age", 18)
    .add("city", "JavaTown")
    .build();  // ← يرجع JsonObject
```

### JsonArrayBuilder:

```java
JsonArray skills = Json.createArrayBuilder()
    .add("Java")
    .add("Python")
    .add("JavaScript")
    .build();  // ← يرجع JsonArray
```

### تداخل Builders:

```java
JsonObject model = Json.createObjectBuilder()
    .add("firstName", "Duke")
    .add("lastName", "Java")
    .add("age", 18)
    .add("phoneNumbers", Json.createArrayBuilder()
        .add(Json.createObjectBuilder()
            .add("type", "mobile")
            .add("number", "111-111-1111"))
        .add(Json.createObjectBuilder()
            .add("type", "home")
            .add("number", "222-222-2222")))
    .build();
```

**النتيجة:**

```json
{
  "firstName": "Duke",
  "lastName": "Java",
  "age": 18,
  "phoneNumbers": [
    { "type": "mobile", "number": "111-111-1111" },
    { "type": "home", "number": "222-222-2222" }
  ]
}
```

### JsonWriter:

```java
// للكتابة في Console
JsonWriter writer = Json.createWriter(System.out);
writer.writeObject(jsonObject);
writer.close();

// للكتابة في ملف
JsonWriter writer = Json.createWriter(new FileWriter("output.json"));
writer.writeObject(jsonObject);
writer.close();
```

---

# 🔶 الفصل الرابع: JSON-B (JSON Binding)

---

## 4.1 مقدمة

**JSON-B = Java API for JSON Binding**

- JEE8: JSR 367 Specification

### الفكرة:

تحويل **تلقائي** بين Java Objects و JSON - **بدون** كتابة كود يدوي!

```
Java Object  ←────→  JSON String
                ↑
            JSON-B
```

---

## 4.2 Mapping an Object

### الـ Class:

```java
public class Dog {
    public String name;
    public int age;
    public boolean bitable;
}
```

### Serialization (Object → JSON):

```java
// إنشاء Object
Dog dog = new Dog();
dog.name = "Falco";
dog.age = 4;
dog.bitable = false;

// إنشاء Jsonb
Jsonb jsonb = JsonbBuilder.create();

// التحويل
String result = jsonb.toJson(dog);
// النتيجة: {"age":4,"bitable":false,"name":"Falco"}
```

### Deserialization (JSON → Object):

```java
// JSON String
String json = "{\"age\":4,\"bitable\":false,\"name\":\"Falco\"}";

// التحويل
Dog dog = jsonb.fromJson(json, Dog.class);

// استخدام الـ Object
System.out.println(dog.name);  // Falco
System.out.println(dog.age);   // 4
```

---

## 4.3 Mapping a Raw Collection (Array)

```java
// Array من Dogs
Dog[] dogs = new Dog[] {
    new Dog("Falco", 4, false),
    new Dog("Cassidy", 2, true)
};

// Serialize
Jsonb jsonb = JsonbBuilder.create();
String result = jsonb.toJson(dogs);
// النتيجة: [{"age":4,"bitable":false,"name":"Falco"},{"age":2,"bitable":true,"name":"Cassidy"}]

// Deserialize
Dog[] dogsBack = jsonb.fromJson(result, Dog[].class);
```

---

## 4.4 Mapping a Generic Collection

```java
// List من Dogs
List<Dog> list = new ArrayList<>();
list.add(new Dog("Falco", 4, false));
list.add(new Dog("Cassidy", 2, true));

// Serialize
Jsonb jsonb = JsonbBuilder.create();
String result = jsonb.toJson(list);

// Deserialize - ⚠️ مشكلة Type Erasure
// الحل: استخدم Array بدل List
Dog[] dogs = jsonb.fromJson(result, Dog[].class);
List<Dog> listBack = Arrays.asList(dogs);
```

> ⚠️ **ملاحظة مهمة**: بسبب Type Erasure في Java، لما نعمل `fromJson(json, List.class)` مش هيعرف إن الـ List فيها `Dog` - هيرجع `List<Map>` بدلاً منها!

---

## 4.5 متطلبات الـ Class لـ JSON-B

| المتطلب                                  | الوصف                                           |
| ---------------------------------------- | ----------------------------------------------- |
| **Default Constructor**                  | Constructor فاضي (بدون parameters)              |
| **Public Fields** أو **Getters/Setters** | عشان يقدر يوصل للبيانات                         |
| **Thread Safe**                          | Jsonb instances thread-safe وممكن يتعملها cache |

---

# 🎯 ملخص نهائي

## XML:

- **Declaration**: `<?xml version="1.0" encoding="UTF-8"?>`
- **Root Element**: لازم واحد بس
- **Closing Tags**: لازم لكل element
- **Case Sensitive**: نعم
- **Proper Nesting**: لازم
- **Quoted Attributes**: لازم
- **Entity References**: `&lt;` `&gt;` `&amp;` `&apos;` `&quot;`
- **CDATA**: `<![CDATA[ ... ]]>`

## JSON:

- **Object**: `{ "key": "value" }`
- **Array**: `[ value1, value2 ]`
- **Types**: String, Number, Boolean, null, Object, Array
- **No Comments**: ممنوع التعليقات
- **Double Quotes Only**: للـ Strings والـ Keys

## JSON-P:

- **JsonReader**: قراءة JSON → `readObject()`, `readArray()`
- **JsonObject**: يمثل `{ }` → `getString()`, `getInt()`, etc.
- **JsonArray**: يمثل `[ ]` → `getString(index)`, `size()`
- **JsonWriter**: كتابة JSON → `writeObject()`, `writeArray()`
- **Builders**: `Json.createObjectBuilder()`, `Json.createArrayBuilder()`

## JSON-B:

- **Jsonb**: الـ Interface الرئيسي
- **toJson(object)**: Object → JSON String
- **fromJson(json, Class)**: JSON String → Object

---

**بالتوفيق في المحاضرة والمناقشة!** 🚀
