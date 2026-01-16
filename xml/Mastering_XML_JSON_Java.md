# 🚀 كورس الاحتراف: XML & JSON في بيئة Java (Zero to Hero)

> **مقدمة:** هذا الملف ليس مجرد تلخيص، بل هو **دليل احترافي** يأخذك من الفهم السطحي إلى التطبيق العملي المتعمق، مع مشروع متكامل يتم بناؤه خطوة بخطوة.

---

# 🗺️ خريطة الكورس

1.  **Level 1: الـ Architecture (فلسفة البيانات)**
2.  **Level 2: احتراف الـ XML (ما وراء الأساسيات)**
3.  **Level 3: مشروع عملي (Part 1 - XML Database)**
4.  **Level 4: احتراف الـ JSON (الأداء والأنواع)**
5.  **Level 5: Java JSON-P (Low-Level Control)**
6.  **Level 6: مشروع عملي (Part 2 - Data Migration Tool)**
7.  **Level 7: Java JSON-B (Enterprise Binding)**
8.  **Level 8: مشروع عملي (Part 3 - Complete API Simulation)**

---

# 🎓 Level 1: الـ Architecture (فلسفة البيانات)

قبل كتابة أي كود، المحترف بيفكر في "تصميم البيانات".

### 🧠 س: متى ترفض استخدام JSON وتصر على XML؟

الجميع يقول JSON أخف وأسرع. لكن "المحترف" يختار XML في الحالات التالية:

1.  **Validation المعقد**: لو محتاج قواعد صارمة جداً (مثلاً: "حقل العمر لازم يكون بين 18 و 60، ولو أقل من 21 لازم يكون فيه حقل ولي الأمر"). JSON Schema موجودة بس XSD أقوى بكتير في العلاقات المعقدة.
2.  **Mixed Content**: لو بتكتب نص يتخلله تنسيق (زي ملف Word أو صفحة HTML).
    - _JSON (سيء جداً هنا):_ `{"paragraph": ["Hello ", {"bold": "world"}, " logic"]}`
    - _XML (مثالي):_ `<p>Hello <b>World</b> logic</p>`
3.  **Metadata Attributes**: لو محتاج تفصل بين "البيانات" و "وصف البيانات".

### 🏋️ تمرين تفاعلي (Architecture)

**المطلوب:** صمم هيكل بيانات لـ "فاتورة إلكترونية" (Invoice).
**الشروط:**

- الفاتورة ليها رقم وتاريخ.
- فيها قائمة منتجات.
- **التحدي:** العملة (Currency) لازم تكون جزء من السعر، بس مش عايزها تأثر على القيمة الرقمية عشان الجمع والطرح.

<details>
<summary>💡 الحل المقترح (اضغط هنا)</summary>

**الحل بذكاء XML (فصل البيانات عن الوصف):**

```xml
<invoice id="INV-2026-001">
    <!-- استخدمنا Attribute للعملة عشان السعر يفضل رقم صافي -->
    <totalAmount currency="EGP">5000.00</totalAmount>
</invoice>
```

**الحل بـ JSON (محتاج حيلة):**

```json
{
  "invoiceId": "INV-2026-001",
  "totalAmount": 5000.0,
  "currency": "EGP"
  // اضطرينا نعمل حقل زيادة
}
```

</details>

---

# 🎓 Level 2: احتراف الـ XML (ما وراء الأساسيات)

### 1. الـ Namespaces (عقدة المحترفين)

تخيل بنعمل سيستم لمكتبة، وبنستخدم XML بيوصف "كتاب" (Title, Author)، وXML تاني بيوصف "جدول HTML" (Table, Tr, Td).
المشكلة: كلمة `<table>` ممكن تعني "ترابيزة" في ملف الأثاث، و "جدول" في ملف HTML.

**الحل: XML Namespaces (`xmlns`)**

```xml
<root xmlns:f="http://www.furniture.com/schema"
      xmlns:h="http://www.w3.org/html/schema">

    <!-- دي ترابيزة -->
    <f:table material="wood">
        <f:price>500</f:price>
    </f:table>

    <!-- ده جدول HTML -->
    <h:table>
        <h:tr><h:td>بيانات</h:td></h:tr>
    </h:table>

</root>
```

> **قاعدة ذهبية:** الـ URL المكتوب في الـ xmlns مش لازم يكون موقع شغال، هو مجرد "اسم فريد" (Unique ID).

---

# 🛠️ مشروع عملي الخطوة 1: (MegaStore Configuration)

سنقوم ببناء نظام لمتجر إلكتروني ضخم.
**المهمة:** إنشاء ملف `store_config.xml` يحفظ إعدادات النظام.

**المتطلبات التقنية:**

1.  استخدم **Namespaces** لفصل إعدادات الـ Database عن إعدادات الـ UI.
2.  استخدم **CDATA** لكتابة قالب رسالة الترحيب (HTML).
3.  استخدم **Attributes** للبيانات الوصفية (زي الـ Version).

**الحل المطلوب تنفيذه:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns:db="http://megastore.com/db"
        xmlns:ui="http://megastore.com/ui">

    <!-- إعدادات قاعدة البيانات -->
    <db:connection pool-size="20">
        <db:host>localhost</db:host>
        <db:port>5432</db:port>
        <db:password check-strength="true">SecretPass!123</db:password>
    </db:connection>

    <!-- إعدادات الواجهة -->
    <ui:theme dark-mode="true" />

    <ui:welcome-template>
        <!-- CDATA عشان نكتب HTML براحتنا -->
        <![CDATA[
            <div class="welcome">
                <h1>Welcome to MegaStore! & Enjoy</h1>
            </div>
        ]]>
    </ui:welcome-template>

</config>
```

---

# 🎓 Level 4: احتراف الـ JSON

### معلومة للمحترفين: The Numbers Problem

في JSON، الأرقام خطيرة.

- `{"id": 9223372036854775807}` (أكبر رقم Long في Java).
- في JavaScript، الأرقام دقتها أقل (Double Precision). لو بعت الرقم ده لـ Frontend مكتوب بـ JS، هيفقد دقته وممكن يتغير!
- **نصيحة المحترفين:** لو الرقم `id` أو `BigInteger` وهيروح لـ Browser، ابعته كـ **String** في JSON: `{"id": "9223372036854775807"}`.

### JSON Schema (التحقق)

زي ما XML عنده XSD، الـ JSON عنده JSON Schema.

```json
{
  "type": "object",
  "properties": {
    "price": { "type": "number", "minimum": 0 }
  },
  "required": ["price"]
}
```

---

# 🎓 Level 5: Java JSON-P (الأداء العالي)

**السؤال:** ليه استخدم `JsonParser` (Streaming) المعقد بدل `JsonReader` (Object Model) السهل؟
**الإجابة:** الـ **Memory!!**

- لو عندك ملف JSON حجمه **2 جيجا**.
- `JsonReader` هيحمل الـ 2 جيجا كلها في الـ RAM ← `OutOfMemoryError` 💥.
- `JsonParser` بيمشي عليه سطر سطر (Cursor)، بيستهلك كام KB بس من الـ RAM.

### 🛠️ مشروع عملي الخطوة 2: (The Large Report Processor)

تخيل عندنا ملف `sales_log.json` فيه مليون عملية بيع. عايزين نحسب "إجمالي المبيعات".

**الملف الضخم (تخيلي):**

```json
[
  {"id": 1, "amount": 100},
  {"id": 2, "amount": 50},
  ... (مليون سطر) ...
]
```

**كود المحترفين (Streaming API):**

```java
import jakarta.json.stream.JsonParser;
import java.io.StringReader;

public class SalesProcessor {
    public static void main(String[] args) {
        String json = "[{\"amount\": 100}, {\"amount\": 50}, {\"amount\": 200}]";

        JsonParser parser = Json.createParser(new StringReader(json));
        double totalSales = 0;

        while (parser.hasNext()) {
            JsonParser.Event event = parser.next();

            // لو وصلنا لاسم المفتاح "amount"
            if (event == JsonParser.Event.KEY_NAME && parser.getString().equals("amount")) {
                parser.next(); // نتحرك للقيمة
                totalSales += parser.getInt(); // نجمع
            }
        }
        System.out.println("Total Sales: " + totalSales);
    }
}
```

> **لاحظ:** مخزناش ولا object في الذاكرة! جمعنا ومشينا. ده الكود اللي بيفرق المبدئ عن المحترف.

---

# 🎓 Level 7: Java JSON-B (Enterprise Binding)

هنا بقى الشغل المريح للـ Business Applications.

### 1. التعامل مع اختلاف الأسماء (`@JsonbProperty`)

في Java بنسمي المتغيرات `camelCase` (مثل `firstName`).
في JSON أحياناً الـ API اللي جايلك بيكون `snake_case` (مثل `first_name`).

**الحل:**

```java
public class User {
    @JsonbProperty("first_name") // ربط الاسم في JSON بالمتغير ده
    public String firstName;

    @JsonbTransient // تجاهل هذا الحقل تماماً (زي password)
    public String internalId;
}
```

### 2. التعامل مع التواريخ (Dates)

التواريخ دايماً بتعمل مشاكل. JSON-B بيسهلها:

```java
public class Event {
    @JsonbDateFormat("yyyy-MM-dd") // حددنا الفورمات
    public LocalDate eventDate;
}
```

---

# 🛠️ مشروع عملي الخطوة 3: (MegaStore API Simulation)

هنعمل Class يمثل "المنتج"، وهنحوله لـ JSON ونرجعه تاني، بس بشروط احترافية.

**المطلوب:**

1.  الـ Class اسمه `Product`.
2.  السعر `price` يظهر في JSON باسم `cost`.
3.  المنتج فيه حقل `profit` السري (لا يجب أن يظهر في JSON).
4.  تاريخ الإنتاج `productionDate` بصيغة `Day/Month/Year`.

**التنفيذ (انسخ هذا الكود وجربه):**

```java
import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import jakarta.json.bind.annotation.*;
import java.time.LocalDate;

// 1. تعريف الـ Model باحترافية
class Product {
    public String name;

    @JsonbProperty("cost")  // تغيير الاسم في JSON
    public double price;

    @JsonbTransient         // إخفاء الحقل
    public double profit;

    @JsonbDateFormat("dd/MM/yyyy") // تنسيق التاريخ
    public LocalDate productionDate;

    public Product() {} // Constructor فارغ إجباري

    public Product(String n, double p, double prof, LocalDate d) {
        this.name = n; this.price = p; this.profit = prof; this.productionDate = d;
    }
}

public class MegaStoreApp {
    public static void main(String[] args) {
        // إنشاء منتج
        Product laptop = new Product("MacBook", 2000.0, 500.0, LocalDate.of(2026, 1, 15));

        // التحويل (Serialization)
        Jsonb jsonb = JsonbBuilder.create();
        String json = jsonb.toJson(laptop);

        System.out.println("--- Generated JSON ---");
        System.out.println(json);
        // المتوقع: {"cost":2000.0, "name":"MacBook", "productionDate":"15/01/2026"}
        // لاحظ اختفاء profit وتغير price وتنسيق التاريخ
    }
}
```

---

# 🧠 أسئلة انترفيو للمناقشة (Pro Level)

1.  **س: لو عندنا JSON فيه List of Objects، وعايزين نحوله لـ `ArrayList<User>` بـ JSON-B، إيه المشكلة اللي هتقابلنا؟**

    - **ج:** مشكلة **Type Erasure**. الـ `List<User>.class` في الـ Runtime بتبقى `List` بس، فـ JSON-B مش بيعرف نوع اللي جواها.
    - **الحل:** نستخدم `new ArrayList<User>(){}.getClass().getGenericSuperclass()` (TypeToken في Gson) أو نستخدم Arrays `User[].class` ونحولها لـ List.

2.  **س: إيه الفرق بين `JsonbTransient` و الكلمة المحجوزة `transient` في Java؟**

    - **ج:** `transient` بتمنع الحفظ في الـ Java Serialization (Binary)، لكن `@JsonbTransient` بتمنع الحفظ في JSON Serialization بس.

3.  **س: هل XML ميت (Dead)؟**
    - **ج:** لأ. XML مازال الملك في الـ Enterprise Integration، البنوك (SOAP Services)، وملفات الـ Office (.docx) والـ Android Layouts. هو فقط مات في الـ Web Frontend.

---

> **نصيحة أخيرة:** البرمجة مش حفظ Syntax. البرمجة هي معرفة "متى" تستخدم الأداة.
>
> - بيانات ضخمة؟ → **Streaming API**.
> - API سريع؟ → **JSON-B**.
> - Config معقد؟ → **XML namespaces**.
