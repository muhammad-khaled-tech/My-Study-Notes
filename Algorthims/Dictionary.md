يا أهلاً بيك يا باشمهندس في محطة "نظم المعلومات" الحقيقية. إحنا خلصنا الـ **Hashing** اللي هو كان "المكنة" اللي بتشتغل تحت الكبوت، دلوقتي بقى جه الوقت نركب "الهيكل" أو الـ **Interface** اللي المبرمجين بيتعاملوا معاه في حياتهم اليومية، وهو الـ **Dictionary**.

في الـ ITI، وإنت شغال Open Source، مفيش مشروع هتلمسه (سواء Web بـ Python أو Backend بـ Node.js أو حتى Systems بـ C++) إلا وهتلاقي الـ Dictionary ده هو البطل. ده "القاموس" اللي بيخلي الداتا ليها معنى مش مجرد أرقام مرصوصة.

اربط الحزام، وتعال نغوص في أعماق الـ **Dictionary ADT**.

---

## القاموس البرمجي - Dictionary ADT

### التعريف السريع

الـ **Dictionary** (ويُسمى أحياناً **Map** أو **Associative Array**) هو نوع بيانات تجريدي (**Abstract Data Type**) بيخزن البيانات على هيئة أزواج من **المفتاح والقيمة (Key-Value Pairs)**. الفكرة الأساسية هي إنك بتستخدم "المفتاح" (زي اسمك أو رقمك القومي) عشان توصل لـ "القيمة" (زي بياناتك الشخصية) بشكل مباشر، بدلاً من استخدام الـ Index الرقمي التقليدي بتاع الـ Arrays.

---

### الشرح التفصيلي

بص يا سيدي، تعال نحكي القصة من أولها عشان نفهم "ليه" ده اتصمم أصلاً.

#### القصة التاريخية: من الفهارس الورقية للـ Symbol Tables

زمان، قبل ما الكمبيوتر يبقى في كل بيت، كان فيه مشكلة في تنظيم المعلومات. تخيل "سجل مدني" فيه بيانات 100 مليون مواطن. لو السجل ده عبارة عن **Array**، وعايز أجيب بيانات "أحمد محمد"، هضطر أمشي من أول صفحة لحد ما ألاقيه (Linear Search $O(N)$). ولو رتبناهم (Binary Search $O(\log N)$) لسه هناخد وقت.

المبرمجين الأوائل في الستينيات، وهما بيبنوا أول **Compilers** (المترجمات)، واجهوا مشكلة: لما المبرمج يكتب `int x = 10;` في الكود، الـ Compiler لازم يحفظ إن كلمة `x` دي نوعها `int` ومكانها في الـ Memory كذا. هما محتاجين "فهرس" يربط "الاسم" بـ "المعلومات". من هنا ظهر مفهوم الـ **Dictionary**.

#### المستوى السطحي: "إيه ده؟" (The Concept)

الـ Dictionary هو "علاقة" (Mapping). هو بيقول للكمبيوتر: "لما أسألك عن الكلمة دي، رد عليا بالمعلومة دي". المفتاح (**Key**) لازم يكون فريد (Unique)، مينفعش اتنين سكان في العمارة يكون ليهم نفس رقم الشقة، لكن القيمة (**Value**) ممكن تتكرر عادي (ممكن شقتين يكون فيهم نفس نوع السيراميك).

#### المستوى المتوسط: "إزاي بيشتغل؟" (The Mechanism)

الـ Dictionary ده "اسم شهرة"، لكن تحت الكبوت هو بيتم تنفيذه بواحدة من طريقتين مشهورين جداً:

1. **Hash-Based Dictionary:**
2. وده بيستخدم الـ **Hash Table** اللي لسه شارحينه. بياخد الـ Key، يدخله في الخلاط (Hash Function)، يطلّع Index، ويروح للمكان ده في الـ Array. ده بيدينا سرعة خرافية $O(1)$.
    
3. **Tree-Based Dictionary:** 
4. وده بيستخدم أشجار بحث متوازنة (**Balanced Binary Search Trees**) زي الـ **Red-Black Tree**. ده بيدينا سرعة $O(\log N)$ وبيميزه إن الداتا بتفضل مترتبة.
    

#### المستوى العميق: "ليه اتصمم كده؟" (The Engineering & Trade-offs)

ليه عندنا نوعين؟ وليه الـ Dictionary هو الـ King بتاع الـ Data Structures؟

- **المرونة (Flexibility):** الـ Array محدود بإن الـ Index لازم يكون `integer`. الـ Dictionary حررك؛ الـ Key ممكن يكون `string` (اسمك)، `float` (درجة حرارة)، أو حتى `Object` معقد.
    
- **الـ Time-Space Complexity:** * في الـ **Unordered Map** (المبني على الـ Hashing): إحنا بنكسب "وقت" ($O(1)$) بس بنضحي بـ "ترتيب". الداتا جوه الـ Memory مبعثرة تماماً.
    
    - في الـ **Ordered Map** (المبني على الـ Trees): إحنا بنضحي بـ "وقت" بسيط ($O(\log N)$) بس بنكسب إن الداتا دايماً مترتبة حسب الـ Key. لو عايز تطلع تقرير بأسماء الموظفين مترتبين أبجدياً، النوع ده هو صاحبك.
        
- **الـ Load Factor والـ Collision:** الـ Dictionary الذكي هو اللي بيعرف يراقب نفسه. لو عدد الـ Keys زاد وبدأ يحصل زحمة (Collisions)، الـ Dictionary بيعمل **Rehashing** أوتوماتيك عشان يحافظ على أداء الـ $O(1)$.
    

[Image: Logical structure of a Dictionary showing Keys pointing to Values through a black box mapping]

---

#### كيفية العمل (How It Works) - خطوة بخطوة

تخيل بنبني "قاموس ترجمة" (كلمة إنجليزي ومعناها بالعربي):

1. **Insertion (إضافة):**
    
    - المستخدم دخل `{"Apple", "تفاحة"}`.
        
    - السيستم يحسب الـ Hash بتاع كلمة "Apple" (وليكن طلع 10).
        
    - يروح للـ Index رقم 10 في الجدول ويخزن `("Apple", "تفاحة")`.
        
2. **Lookup (بحث):**
    
    - المستخدم بيسأل: "يعني إيه Apple؟".
        
    - السيستم يحسب الـ Hash لـ "Apple" تاني (هيطلع 10 برضه).
        
    - يروح لـ Index 10 ويجيب "تفاحة" في خطوة واحدة.
        
3. **Update (تحديث):**
    
    - لو دخلنا `{"Apple", "تفاحة خضراء"}`، السيستم هيلاقي الـ Key موجود أصلاً، فيروح يمسح القيمة القديمة ويحط الجديدة.
        

---

#### الأمثلة العملية (Practical Example)

في C++، الـ Dictionary موجود في الـ **STL** (Standard Template Library) بنوعين: `std::map` (المترتب) و `std::unordered_map` (السريع). تعال نستخدم السريع عشان نطبق اللي فهمناه في الـ Hashing.

C++

```
#include <iostream>
#include <string>
#include <unordered_map> // مكتبة الـ Dictionary السريع (Hash-based)

using namespace std;

int main() {
    // تعريف Dictionary: المفتاح string (اسم الطالب) والقيمة int (درجته)
    unordered_map<string, int> studentGrades;

    // 1. إضافة بيانات (Insertion) - O(1) average
    studentGrades["Ahmed"] = 95;
    studentGrades["Mona"] = 98;
    studentGrades["Zain"] = 88;
    // طريقة تانية للإضافة
    studentGrades.insert({"Sara", 92});

    // 2. الوصول لبيانات (Lookup) - O(1) average
    string name = "Mona";
    if (studentGrades.find(name) != studentGrades.end()) {
        cout << name << "'s grade is: " << studentGrades[name] << endl;
    } else {
        cout << "Student not found!" << endl;
    }

    // 3. التحديث (Update)
    studentGrades["Ahmed"] = 100; // أحمد شاطر وقفل الدرجة

    // 4. الحذف (Deletion)
    studentGrades.erase("Zain"); // زين سحب ورقه من الكورس

    // 5. لف على كل العناصر (Iteration)
    cout << "\n--- Student List ---" << endl;
    for (auto const& [key, val] : studentGrades) {
        cout << "Student: " << key << " | Grade: " << val << endl;
    }

    return 0;
}

/*
الـ Output المتوقع:
Mona's grade is: 98

--- Student List ---
Ahmed | 100
Mona | 98
Sara | 92
(لاحظ: الترتيب ممكن يتغير لأننا شغالين unordered_map)
*/
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **الـ Key Uniqueness:** لازم الـ Key يكون وحيد. لو حاولت تضيف Key موجود قبل كده، القيمة الجديدة "هتفرتك" القديمة (Overwrite). لو عايز تسمح بتكرار الـ Keys، بنستخدم حاجة اسمها **MultiMap**.
    
2. **الـ Key Immutability:** يفضل جداً إن الـ Key يكون نوع بيانات مبيتغيرش (Immutable) زي الـ `string` أو الـ `int`. لو استخدمت Object والـ Hash بتاعه اتغير وهو جوه الجدول، إنت فقدت الداتا دي للأبد لأنك مش هتعرف توصل لمكانها.
    
3. **الـ Memory Overhead:** الـ Dictionary بيستهلك ميموري أكتر من الـ Array بكتير (عشان الـ Hash Table والـ Pointers والـ Buckets). لو الميموري عندك أغلى من الوقت، فكر مرتين.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Dictionary ده مرتبط بـ:

- **JSON (JavaScript Object Notation):** 
- لغة تبادل البيانات في الـ Web هي في الأساس عبارة عن Nested Dictionaries.
    
- **Python's `dict` & JavaScript's `Object/Map`:** 
- دي الـ Data Structure الأساسية اللي اللغات دي مبنية عليها.
    
- **Databases:**
- الـ NoSQL Databases زي **MongoDB** أو **Redis** هي عبارة عن Dictionaries عملاقة متوزعة على سيرفرات.
    
- **Symbol Tables:**
- في الـ Compiler Design، عشان يربط الـ Variables بالـ Memory Addresses.
    

### المصادر والقراءة الإضافية

- **كتاب "C++ Primer":** جزء الـ Associative Containers بيشرح الـ `map` والـ `unordered_map` بعمق.
    
- **فيديو "The Map Data Structure" من قناة CS Dojo:** شرح مبسط جداً للمفهوم.
    
- **Documentation:** [cppreference.com](https://en.cppreference.com/w/cpp/container/unordered_map) - المرجع الرسمي لكل تفاصيل الـ STL.
    

---

