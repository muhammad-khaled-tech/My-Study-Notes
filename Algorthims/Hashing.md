يا أهلاً بيك يا بطل في منطقة "السحر الأسود" لعلوم الحاسب. إحنا دلوقتي قدام الـ **Hashing**. لو الـ Linear Search هو السلحفاة، والـ Binary Search هو العربية المرسيدس، فالـ **Hashing** هو "اللي بسرعة  الضوء" . إحنا هنا مش بندور على الداتا، إحنا بنخلي الداتا هي اللي تقولنا مكانها فين في خطوة واحدة بس $O(1)$.

اربط الحزام، وفتّح مخك معايا، عشان الموضوع ده هو اللي بيخلي شركات زي Google و Facebook تقدر تتعامل مع مليارات المستخدمين في أجزاء من الثانية.

---

## عالم الـ Hashing: الوصول اللحظي للبيانات

### التعريف السريع

الـ **Hashing** هو تكنيك بيستخدم "دالة رياضية" (Hash Function) عشان يحول أي "مفتاح" (Key) - زي اسم مستخدم أو رقم تليفون - لـ "رقم" (Index). الرقم ده هو عنوان المكان اللي هنخزن فيه الداتا في مصفوفة كبيرة بنسميها الـ **Hash Table**. الميزة الكبرى هي إننا بنوصل للداتا في وقت ثابت $O(1)$ بغض النظر عن حجم البيانات.

---

### الشرح التفصيلي (العمق التاريخي والفلسفي)

بص يا سيدي، في الخمسينيات، كانت أجهزة الكمبيوتر بتعاني من مشكلة "البطء" في البحث. في سنة 1953، مهندس في شركة IBM اسمه **Hans Peter Luhn** كان شغال على مشكلة تنظيم المعلومات، وفكر في فكرة عبقرية. قال: "بدل ما أدور في كل الرفوف، ليه ماعملش قاعدة رياضية تخلي كل معلومة يبقى ليها رف محدد ومعروف مسبقاً بناءً على اسمها؟".

من هنا ظهر مفهوم الـ **Hashing**. الفلسفة ورا الـ Hashing هي الـ **Space-Time Trade-off**. إحنا بنضحي بـ "مساحة ميموري" زيادة (عشان نعمل مصفوفة كبيرة) في مقابل إننا نوفر "وقت البحث" تماماً.

#### 1. المستوى السطحي: "إيه ده؟" (The Concept)

تخيل لو عندك 1000 مفتاح شقة، وكل مفتاح عليه رقم الشقة بتاعته. هل محتاج تدور في كل الشقق عشان تعرف المفتاح ده بتاع أنهي شقة؟ لأ، الرقم اللي على المفتاح بيقولك "روح لشقة رقم 50" فوراً. الـ Hashing بيحول أي داتا (اسم، فايل، صورة) لـ "رقم المفتاح" ده.

#### 2. المستوى المتوسط: "إزاي بيشتغل؟" (The Mechanics)

اللعبة كلها بتتم من خلال تلات أركان:

- **الـ Key:** المعلومة اللي عايز تخزنها أو تدور بيها (مثلاً: "Ahmed").
    
- **الـ Hash Function:** دي "الخلاط" أو الماكينة السحرية. بندخلها الكلمة، تطلعلنا رقم (مثلاً: 5).
    
    - _شرطها:_ لازم تكون **Deterministic** (لو دخلتلها "Ahmed" مليون مرة، تطلع 5 كل مرة).
        
- **الـ Hash Table:** مصفوفة (Array) كبيرة، بنروح للـ Index رقم 5 ونحط فيه الداتا بتاعتنا.
    

المشكلة الكبرى: الـ Collision (التصادم)

تخيل لو الـ Hash Function طلعت رقم 5 لـ "Ahmed" وكمان طلعت رقم 5 لـ "Mona"؟ ده بنسميه Collision. مستحيل تلاقي Hash Function كاملة 100% (بسبب نظرية رياضية اسمها Pigeonhole Principle أو "مبدأ برج الحمام": لو عندك 10 حمامات و9 عشش، لازم عشة واحدة على الأقل تشيل حمامتين).

#### 3. المستوى العميق: "ليه اتصمم كده؟" (The Engineering Trade-offs)

إزاي المهندسين بيحلوا مشكلة الـ Collision؟ عندنا مدرستين كبار:

أ) الـ Chaining (الربط المتسلسل):

في كل مكان (Bucket) في المصفوفة، بدل ما بنخزن عنصر واحد، بنعمل Linked List. لو "Ahmed" و "Mona" الاتنين Index 5، بنحطهم ورا بعض في الـ List.

- _الميزة:_ سهلة جداً والجدول مبيتميليش أبداً.
    
- _العيب:_ لو الـ Hash Function وحشة، كل الداتا هتتركن في مكان واحد والبحث هيقلب $O(n)$.
    

ب) الـ Open Addressing (العنونة المفتوحة):

لو المكان رقم 5 مشغول، بنشوف مكان تاني فاضي في الجدول. وليها كذا طريقة:

- **Linear Probing:** 
- بنشوف 6، لو مشغول نشوف 7.. وهكذا. (بيعمل مشكلة اسمها Primary Clustering).
    
- **Quadratic Probing:** 
- بنشوف (5 + 1^2)، ثم (5 + 2^2).. وهكذا.
    
- **Double Hashing:**
- بنستخدم دالة هاش تانية خالص تقولي أنط كام خطوة. (دي الأذكى).
    

الـ Load Factor ($\alpha$):

ده رقم بيحدد "زحمة" الجدول. $\alpha = n/m$ (عدد العناصر / حجم الجدول). لو الرقم ده زاد عن 0.7 (يعني الجدول اتملى بنسبة 70%)، الأداء بيقل جداً، ولازم نعمل عملية اسمها Rehashing (نكبر الجدول ونعيد توزيع كل الداتا فيه).

---

#### كيفية العمل (How It Works) - سيناريو عملي

تخيل بنعمل سيستم لمحل موبايلات:

1. الزبون اسمه "Mina".
    
2. الـ Hash Function بتحسب مجموع الحروف (M=13, I=9, N=14, A=1) = 37.
    
3. حجم الجدول بتاعنا 10، فنقول `37 % 10 = 7`.
    
4. بنخزن بيانات "Mina" في الـ Index رقم 7.
    
5. لما يجي "Mina" تاني، بنحسب نفس الحسبة ونروح لـ Index 7 "خبط لزق" في خطوة واحدة.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود بيوريك إزاي بنعمل Hash Table بسيط بيستخدم الـ **Chaining** لحل التصادمات.

C++

```
#include <iostream>
#include <list>
#include <vector>
#include <string>

using namespace std;

/**
 * HashTable Class using Chaining (Linked Lists)
 * Goal: Constant time access O(1) on average.
 */
class HashTable {
private:
    int buckets; // حجم الجدول (عدد الأماكن المتاحة)
    vector<list<string>> table; // مصفوفة من الـ Linked Lists

    // دالة الـ Hash البسيطة: مجموع قيم الحروف ASCII modulo عدد الأماكن
    int hashFunction(string key) {
        int sum = 0;
        for (char c : key) {
            sum += c;
        }
        return sum % buckets;
    }

public:
    HashTable(int b) {
        this->buckets = b;
        table.resize(buckets);
    }

    // إضافة عنصر للجدول
    void insertItem(string key) {
        int index = hashFunction(key);
        table[index].push_back(key); // بنضيف في الـ Linked List بتاعة الـ Index ده
    }

    // البحث عن عنصر
    bool searchItem(string key) {
        int index = hashFunction(key);
        
        // بنلف بس على الـ List الصغيرة اللي في الـ Index ده
        for (string x : table[index]) {
            if (x == key) return true;
        }
        return false;
    }

    // طباعة شكل الجدول في الميموري (للفهم)
    void displayHash() {
        for (int i = 0; i < buckets; i++) {
            cout << "Bucket " << i << ": ";
            for (auto x : table[i])
                cout << " --> " << x;
            cout << endl;
        }
    }
};

int main() {
    // بنعمل جدول فيه 7 أماكن بس عشان نشوف الـ Collisions
    HashTable ht(7);

    string names[] = {"Ahmed", "Mona", "Mina", "Ali", "Sara", "Zain"};
    
    for (string s : names) {
        ht.insertItem(s);
    }

    cout << "--- Hash Table Structure (Chaining) ---" << endl;
    ht.displayHash();

    cout << "\n--- Search Results ---" << endl;
    cout << "Searching for 'Mina': " << (ht.searchItem("Mina") ? "Found ✅" : "Not Found ❌") << endl;
    cout << "Searching for 'Omar': " << (ht.searchItem("Omar") ? "Found ✅" : "Not Found ❌") << endl;

    return 0;
}
```

شرح الـ Output:

هتلاقي إن فيه أسماء خدت نفس الـ Bucket (حصل Collision)، والـ Linked List شالتهم هما الاتنين. لما بنعمل Search، بنروح للـ Bucket الصح فوراً وبندور جوا الـ List الصغيرة دي بس.

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Bad Hash Function:** 
2. لو الدالة بتاعتك بتطلع نفس الرقم لكل الكلمات (مثلاً دايماً بتطلع 0)، الـ Hash Table هيتحول لـ Linked List عادية والسرعة هتبقى $O(n)$. عشان كده الـ Hash Function هي "روح" الموضوع.
    
3. **Clustering:** 
4. في الـ Open Addressing، لو العناصر بدأت تتجمع ورا بعضها في أماكن متجاورة، البحث بيبطأ جداً. دي مشكلة مشهورة بنحلها بالـ Double Hashing.
    
5. **Security (Hash DoS Attack):** 
6. الهكرز ممكن يبعتوا داتا معمولة مخصوص عشان تعمل Collisions كتير جداً في الـ Web Servers، وده يوقع السيرفر لأنه هيستهلك الـ CPU كله في البحث جوه Linked Lists طويلة. (عشان كده اللغات الحديثة بتستخدم دالات هاش عشوائية).
    

---

### الربط بالمفاهيم التانية

الموضوع ده مرتبط بـ:

- **Compilers:**
- الـ Symbol Table اللي بيخزن أسماء الـ Variables في الكود معمول بـ Hash Table.
    
- **Cryptography:** 
- الـ SHA-256 والـ MD5 هما تطبيقات متطورة جداً للـ Hashing عشان نتأكد إن الفايلات متعدلتش.
    
- **Databases:**
- الـ Hash Index بيخليك تجيب الـ Row في لحظة.
    
- **Blockchain:** 
- البيتكوين والعملات الرقمية قايمة بالكامل على فكرة الـ "Hash Pointer".
    

### المصادر والقراءة الإضافية

- **كتاب CLRS (الفصل 11):** ده المرجع الأساسي اللي بيشرح كل أنواع الـ Hashing بالرياضيات بتاعتها.
    
- **فيديو Abdul Bari (Hashing):** [سلسلة فيديوهات الـ Hashing](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DknV86RlNJUA) - شرحه للـ Collisions والـ Probing لا يعلى عليه.
    
- **مقال IBM عن Hans Peter Luhn:** عشان تعرف قصة الراجل اللي غير تاريخ الـ Computing.
    

---

