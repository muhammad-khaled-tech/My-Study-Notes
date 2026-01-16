# 📙 الجزء الثالث: Collections والـ Type Erasure Problem

> **هدف هذا الجزء:** فهم كيفية التعامل مع Arrays و Lists في JSON-B، وحل مشكلة Type Erasure.

---

# 🎯 الفهرس

1. **المشكلة** - ليه Collections مختلفة؟
2. **Raw Arrays** - تحويل `Dog[]`
3. **Generic Collections** - تحويل `List<Dog>`
4. **Type Erasure Problem** - المشكلة الكبيرة!
5. **الحلول العملية**
6. **Nested Objects** - البيانات المتداخلة

---

# 🤔 الفصل 1: المشكلة - ليه Collections مختلفة؟

## مراجعة سريعة:

في Part 2، شفنا إزاي نحول **Object واحد**:

```java
Person person = new Person("أحمد", 25);
String json = jsonb.toJson(person);
// النتيجة: {"name":"أحمد","age":25}
```

### السؤال: طيب لو عندنا **قائمة** من الأشخاص؟

```java
Person[] people = {
    new Person("أحمد", 25),
    new Person("سارة", 22),
    new Person("محمد", 30)
};
```

**عايزين النتيجة:**

```json
[
  { "name": "أحمد", "age": 25 },
  { "name": "سارة", "age": 22 },
  { "name": "محمد", "age": 30 }
]
```

---

## ليه Collections معقدة؟

### المشكلة 1: أنواع مختلفة

في Java، عندنا أنواع Collections كتير:

- **Array**: `Dog[]` (ثابت الحجم)
- **List**: `List<Dog>` (ديناميكي)
- **Set**: `Set<Dog>` (بدون تكرار)
- **Map**: `Map<String, Dog>` (key-value)

كل واحد ليه طريقة تعامل مختلفة!

### المشكلة 2: Generics في Java

```java
List<Dog> dogs = new ArrayList<>();
```

**السؤال:** لما نحول لـ JSON ونرجع تاني، JSON-B إزاي يعرف إن الـ List فيها `Dog` مش `Cat` مثلاً؟

**هنا بتظهر Type Erasure!**

---

# 📦 الفصل 2: Raw Arrays (المصفوفات الخام)

## الفكرة:

Arrays في Java **بتحتفظ** بنوع العناصر في الـ Runtime.

```java
Dog[] dogs;  // الـ JVM عارف إن ده Dog array
```

---

## مثال كامل:

### الخطوة 1: تعريف الـ Class

```java
public class Dog {
    public String name;
    public int age;
    public boolean bitable;

    // Constructor فارغ
    public Dog() {}

    // Constructor للراحة
    public Dog(String name, int age, boolean bitable) {
        this.name = name;
        this.age = age;
        this.bitable = bitable;
    }
}
```

---

### الخطوة 2: Serialization (Array → JSON)

```java
import jakarta.json.bind.*;

public class ArraySerialization {
    public static void main(String[] args) {

        // ========== 1. إنشاء Array من Dogs ==========
        Dog[] dogs = new Dog[] {
            new Dog("Falco", 4, false),
            new Dog("Cassidy", 2, true),
            new Dog("Max", 5, false)
        };

        // ========== 2. التحويل لـ JSON ==========
        Jsonb jsonb = JsonbBuilder.create();

        // toJson(array) = بتشتغل مع Arrays زي Objects عادي
        // بتاخد: Object (حتى لو Array)
        // بترجع: String (JSON Array)
        String json = jsonb.toJson(dogs);

        // ========== 3. الطباعة ==========
        System.out.println(json);
    }
}
```

**Output:**

```json
[
  { "age": 4, "bitable": false, "name": "Falco" },
  { "age": 2, "bitable": true, "name": "Cassidy" },
  { "age": 5, "bitable": false, "name": "Max" }
]
```

**لاحظ:**

- ✅ الـ Array اتحول لـ JSON Array `[ ]`
- ✅ كل عنصر اتحول لـ JSON Object `{ }`

---

### الخطوة 3: Deserialization (JSON → Array)

```java
import jakarta.json.bind.*;

public class ArrayDeserialization {
    public static void main(String[] args) {

        // ========== 1. JSON String ==========
        String json = "[" +
            "{\"name\":\"Falco\",\"age\":4,\"bitable\":false}," +
            "{\"name\":\"Cassidy\",\"age\":2,\"bitable\":true}" +
            "]";

        // ========== 2. التحويل لـ Array ==========
        Jsonb jsonb = JsonbBuilder.create();

        // fromJson(json, Dog[].class) ← لاحظ Dog[].class
        // بتاخد: String (JSON), Class (نوع الـ Array)
        // بترجع: T[] (Array من النوع المحدد)
        Dog[] dogs = jsonb.fromJson(json, Dog[].class);

        // ========== 3. استخدام النتيجة ==========
        for (Dog dog : dogs) {
            System.out.println("الكلب: " + dog.name +
                             " - العمر: " + dog.age);
        }
    }
}
```

**Output:**

```
الكلب: Falco - العمر: 4
الكلب: Cassidy - العمر: 2
```

---

## نقطة مهمة: Dog[].class

**السؤال:** إيه الفرق بين `Dog.class` و `Dog[].class`؟

```java
Dog.class      // ← نوع: Dog (object واحد)
Dog[].class    // ← نوع: Dog[] (array)
```

**في Runtime:**

- `Dog.class` → `Class<Dog>`
- `Dog[].class` → `Class<Dog[]>`

JSON-B بيستخدم ده عشان يعرف يعمل Array وليس Object واحد.

---

# 🧩 الفصل 3: Generic Collections (القوائم العامة)

## المشكلة الكبيرة: Type Erasure

### ما هو Type Erasure؟

**في وقت الكتابة (Compile Time):**

```java
List<Dog> dogs = new ArrayList<>();  // الـ Compiler عارف ده List<Dog>
```

**في وقت التشغيل (Runtime):**

```java
List dogs = new ArrayList<>();  // الـ JVM شايفه List فقط! (مش عارف Dog)
```

**السبب:** Java بتمسح (Erase) الـ Generic Types في الـ Runtime عشان Backward Compatibility.

---

## التجربة العملية:

### Serialization (List → JSON) - شغال عادي ✅

```java
import jakarta.json.bind.*;
import java.util.*;

public class ListSerialization {
    public static void main(String[] args) {

        // ========== 1. إنشاء List ==========
        List<Dog> dogs = new ArrayList<>();
        dogs.add(new Dog("Falco", 4, false));
        dogs.add(new Dog("Cassidy", 2, true));

        // ========== 2. التحويل لـ JSON ==========
        Jsonb jsonb = JsonbBuilder.create();
        String json = jsonb.toJson(dogs);

        // ✅ بيشتغل عادي!
        System.out.println(json);
    }
}
```

**Output:**

```json
[
  { "age": 4, "bitable": false, "name": "Falco" },
  { "age": 2, "bitable": true, "name": "Cassidy" }
]
```

**ليه شغال؟** لأن JSON-B بيقدر يشوف العناصر الموجودة في الـ List ويحولهم.

---

### Deserialization (JSON → List) - المشكلة! ❌

```java
import jakarta.json.bind.*;
import java.util.*;

public class ListDeserializationProblem {
    public static void main(String[] args) {

        String json = "[{\"name\":\"Falco\",\"age\":4,\"bitable\":false}]";

        Jsonb jsonb = JsonbBuilder.create();

        // ❌ المشكلة: إزاي نكتب الـ Class؟
        // List<Dog>.class  ← ده مش موجود!

        // لو كتبنا:
        List<?> dogs = jsonb.fromJson(json, List.class);

        // النتيجة:
        // dogs = [Map, Map, Map]  ← مش Dog objects!
        // كل عنصر هيكون LinkedHashMap<String, Object>

        System.out.println(dogs.get(0).getClass());
        // Output: class java.util.LinkedHashMap
    }
}
```

**المشكلة:**

- JSON-B مش عارف نوع العناصر
- فبيحول كل object لـ `Map<String, Object>`

---

# 🔧 الفصل 4: الحلول العملية

## الحل 1: استخدم Arrays بدل Lists

**الفكرة:** Arrays **بتحتفظ** بالنوع، فنستخدمها ونحولها لـ List بعدين.

```java
import jakarta.json.bind.*;
import java.util.*;

public class Solution1_UseArrays {
    public static void main(String[] args) {

        String json = "[{\"name\":\"Falco\",\"age\":4,\"bitable\":false}]";

        Jsonb jsonb = JsonbBuilder.create();

        // ========== الحل ==========
        // 1. نحول لـ Array الأول
        Dog[] dogsArray = jsonb.fromJson(json, Dog[].class);

        // 2. نحول الـ Array لـ List
        List<Dog> dogsList = Arrays.asList(dogsArray);

        // ✅ دلوقتي عندنا List<Dog> صحيح!
        for (Dog dog : dogsList) {
            System.out.println(dog.name + " - " + dog.age);
        }
    }
}
```

**Output:**

```
Falco - 4
```

**مميزات الحل:**

- ✅ بسيط
- ✅ بيشتغل دايماً

**عيوب الحل:**

- `Arrays.asList()` بيرجع **Fixed-size list** (مينفعش تضيف/تشيل عناصر)
- لو عايز Mutable list، لازم:
  ```java
  List<Dog> dogsList = new ArrayList<>(Arrays.asList(dogsArray));
  ```

---

## الحل 2: Wrapper Class (الأفضل للمشاريع الكبيرة)

**الفكرة:** نعمل Class جديد يلف (wrap) الـ List.

```java
// 1. تعريف الـ Wrapper Class
public class DogList {
    public List<Dog> dogs;  // ← لاحظ: public field

    public DogList() {
        this.dogs = new ArrayList<>();
    }
}

// 2. الاستخدام
public class Solution2_WrapperClass {
    public static void main(String[] args) {

        // Serialization
        DogList list = new DogList();
        list.dogs.add(new Dog("Falco", 4, false));

        Jsonb jsonb = JsonbBuilder.create();
        String json = jsonb.toJson(list);
        // النتيجة: {"dogs":[{"name":"Falco",...}]}

        // Deserialization
        DogList result = jsonb.fromJson(json, DogList.class);
        // ✅ بيشتغل تمام!

        for (Dog dog : result.dogs) {
            System.out.println(dog.name);
        }
    }
}
```

**مميزات الحل:**

- ✅ نظيف ومنظم
- ✅ بيشتغل مع Mutable lists
- ✅ مناسب للـ APIs (JSON Schema واضح)

---

# 🏋️ تمرين عملي 1

## المطلوب:

عندك JSON ده:

```json
{
  "students": [
    { "name": "أحمد", "grade": 85 },
    { "name": "سارة", "grade": 92 },
    { "name": "محمد", "grade": 78 }
  ]
}
```

**اعمل:**

1. Class اسمه `Student` فيه `name` و `grade`
2. Wrapper class اسمه `ClassRoom` فيه `List<Student>`
3. حول الـ JSON لـ `ClassRoom` object
4. اطبع أسماء الطلاب ودرجاتهم

<details>
<summary>💡 الحل</summary>

```java
import jakarta.json.bind.*;
import java.util.*;

// 1. Student Class
class Student {
    public String name;
    public int grade;
    public Student() {}
}

// 2. Wrapper Class
class ClassRoom {
    public List<Student> students;
    public ClassRoom() {
        this.students = new ArrayList<>();
    }
}

// 3. Main
public class ClassRoomTest {
    public static void main(String[] args) {
        String json = "{\"students\":[" +
            "{\"name\":\"أحمد\",\"grade\":85}," +
            "{\"name\":\"سارة\",\"grade\":92}," +
            "{\"name\":\"محمد\",\"grade\":78}" +
            "]}";

        Jsonb jsonb = JsonbBuilder.create();
        ClassRoom room = jsonb.fromJson(json, ClassRoom.class);

        for (Student s : room.students) {
            System.out.println(s.name + ": " + s.grade);
        }
    }
}
```

</details>

---

# 🌳 الفصل 5: Nested Objects (البيانات المتداخلة)

## المفهوم:

**Nested Object** = Object جوه Object جوه Object...

```json
{
  "person": {
    "name": "أحمد",
    "address": {
      "city": "القاهرة",
      "street": "شارع النيل",
      "building": {
        "number": 10,
        "floor": 3
      }
    }
  }
}
```

---

## مثال عملي كامل:

```java
// ========== 1. تعريف الـ Classes ==========
class Building {
    public int number;
    public int floor;
    public Building() {}
}

class Address {
    public String city;
    public String street;
    public Building building;  // ← Nested!
    public Address() {}
}

class Person {
    public String name;
    public Address address;  // ← Nested!
    public Person() {}
}

// ========== 2. الاستخدام ==========
public class NestedObjectsExample {
    public static void main(String[] args) {

        // Serialization
        Person person = new Person();
        person.name = "أحمد";
        person.address = new Address();
        person.address.city = "القاهرة";
        person.address.street = "شارع النيل";
        person.address.building = new Building();
        person.address.building.number = 10;
        person.address.building.floor = 3;

        Jsonb jsonb = JsonbBuilder.create();
        String json = jsonb.toJson(person);
        System.out.println(json);

        // Deserialization
        Person result = jsonb.fromJson(json, Person.class);

        // الوصول للبيانات المتداخلة
        System.out.println("الاسم: " + result.name);
        System.out.println("المدينة: " + result.address.city);
        System.out.println("رقم المبنى: " + result.address.building.number);
    }
}
```

**Output:**

```json
{
  "address": {
    "building": { "floor": 3, "number": 10 },
    "city": "القاهرة",
    "street": "شارع النيل"
  },
  "name": "أحمد"
}
```

**JSON-B بيتعامل مع Nested Objects تلقائياً!** ✅

---

# 📝 ملخص الجزء الثالث

| الموضوع                     | الحل                                       |
| --------------------------- | ------------------------------------------ |
| **Arrays**                  | استخدم `Dog[].class`                       |
| **Lists** (Serialization)   | بيشتغل عادي                                |
| **Lists** (Deserialization) | استخدم Arrays ثم حول، أو Wrapper Class     |
| **Type Erasure**            | استخدم `Dog[].class` بدل `List<Dog>.class` |
| **Nested Objects**          | بيشتغل تلقائياً                            |

---

**يتبع في Part 4: Google Gson** (من الـ Appendix)

**بالتوفيق! 🚀**
