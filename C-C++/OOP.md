

ناس كتير فاكرة إن الـ Class حاجة "سحرية" مختلفة تماماً عن الـ Struct.

الحقيقة الصادمة: في الميموري، مفيش أي فرق بينهم!

الموضوع النهاردة عن: Object Memory Layout & The this Pointer.

يعني لما بتعمل new Object()، إيه اللي بيتخزن في الرامات؟ وهل الفانكشنز بتتنسخ جوه كل أوبجيكت؟

---

### 1. الصدمة الأولى: Class vs Struct 🤝

في لغات زي C# أو Java، الفرق بينهم كبير.

في C++، الفرق تافه جداً لدرجة الضحك:

- **Struct:**
- كل حاجة جواه **Public** (متاحة للكل) إلا لو أنت قلت غير كده.
    
- **Class:** 
- كل حاجة جواه **Private** (سرية) إلا لو أنت قلت غير كده.
    

بس! في الميموري؟ الاتنين واحد. الاتنين بيحصلهم Padding و Alignment بنفس الطريقة اللي شرحناها.



```C++
struct A { int x; }; // x is Public
class  B { int x; }; // x is Private
```

---

### 2. الصدمة الثانية: أين تسكن الفانكشن؟ 🏠

تخيل إنك عملت كلاس فيه 100 فانكشن، وعملت منه مليون Object.

هل البرنامج بتاعك هينفجر من كتر نسخ الفانكشنز؟

الإجابة: لأ!

حجم الأوبجيكت يعتمد على المتغيرات (Data) فقط. الفانكشنز ملهاش وزن.

- **المتغيرات (`int x, y`):** كل أوبجيكت ليه النسخة بتاعته (في الـ Stack أو Heap).
    
- **الفانكشنز (`print()`):** موجودة مرة واحدة بس في "قطاع الكود" (Code Section / Text Segment).
    

**مثال الإثبات:**



```C++
#include <iostream>
using namespace std;

class Empty {
    // كلاس فاضي مفيهوش داتا
public:
    void func1() { cout << "Hi"; }
    void func2() { cout << "Hello"; }
    void func3() { cout << "Bye"; }
};

class DataOnly {
public:
    int x; // 4 bytes
    int y; // 4 bytes
    void func() { cout << "Code"; } // 0 bytes in object
};

int main() {
    // المفاجأة: الكلاس الفاضي حجمه 1 بايت (مش صفر) عشان لازم يكون ليه عنوان في الميموري
    cout << "Size of Empty Class: " << sizeof(Empty) << endl; 

    // هنا الحجم 8 بايت (2 ints)
    // الفانكشنز لم تزد بايت واحد على الحجم
    cout << "Size of Data Class:  " << sizeof(DataOnly) << endl;

    return 0;
}
```

---

### 3. السحر الحقيقي: The `this` Pointer 🪄

طالما الفانكشن موجودة مرة واحدة بس في الميموري، ومش موجودة جوه الأوبجيكت..

إزاي لما أنادي obj1.print() بتطبع بيانات obj1، ولما أنادي obj2.print() بتطبع بيانات obj2؟

الإجابة: **الباراميتر المخفي (Hidden Parameter).**

الكومبايلر بيضحك عليك. لما بتكتب فانكشن جوه كلاس، هو بيزود باراميتر زيادة اسمه `this` من ورا ضهرك.

**اللي إنت بتكتبه:**



```C++
class Player {
    int health;
    void damage(int amount) {
        health -= amount; // مين health دي؟ دي بتاعة الأوبجيكت اللي ناداني
    }
};

// الاستدعاء
p1.damage(10);
```

**اللي الكومبايلر بيشوفه (الترجمة الحرفية لـ C):**



```C++
struct Player { int health; };

// الكومبايلر بيحولها لفانكشن عادية بتاخد مؤشر
void Player_damage(Player* const this, int amount) {
    this->health -= amount; // بيستخدم المؤشر عشان يوصل للميموري الصح
}

// الاستدعاءبيتحول لـ:
Player_damage(&p1, 10); // بيبعت عنوان p1 كأول باراميتر
```

> **الخلاصة:** الفانكشن عامة ومشتركة، بس إحنا بنبعتلها "عنوان" البيانات اللي تشتغل عليها في كل مرة.

يعني بالبلدي كده يعتبر ال سطر ده `Player* const this` معناه حاجة بتشاور على حاجه من نوع player  او يعني بتشاور على نفس ال عنوان فكده يعتبر ال  this  دي اصلا  alias لكل اوبجكت ---> كل اوبجكت بيتعمل من الكلاس بيتعمله  alias شايل عنوانه وبيتبعت للفانكشن وال  alias  ده اسمه  this  .. تخيل بقى :)

---

### 4. الـ Static Members (المنبوذين) 👽

لو عرفت متغير static جوه الكلاس، ده مابيبقاش جوه الأوبجيكت أصلاً.

ده بيترمي في منطقة الـ Global Data، وبيبقى مشترك بين كل النسخ.



```C++
class Server {
    int connectionID; // ده Instance Variable (جوه كل أوبجيكت) -> 4 بايت
    static int activeUsers; // ده Class Variable (مش جوه الأوبجيكت) -> 0 بايت من حجم الأوبجيكت
};

int main() {
    // حجم الأوبجيكت هو حجم connectionID بس
    cout << "Size: " << sizeof(Server) << endl; // 4 bytes
}
```

الـ `static` ده عايش براهم خالص، وموجود حتى لو معملتش ولا أوبجيكت.

---

### 5. سؤال للمحترفين (Next Level Teaser) 🔥

إحنا اتفقنا إن الفانكشنز مابتاخدش مساحة في الأوبجيكت.

بس فيه حالة استثنائية وحيدة بتخلي الكلاس يزود 8 بايت (مؤشر سري) غصب عنك، حتى لو مفيهوش داتا.

الحالة دي بتحصل لما نكتب كلمة `virtual` قبل الفانكشن.

**`virtual void print();`**

الكلمة دي بتغير شكل الميموري تماماً، وبتفتح باب الـ Polymorphism (تعدد الأشكال).

---


الموضوع: **Virtual Method Table (vtable) & vptr**.

إحنا اتفقنا إن الفانكشنز مبتأخدش مساحة جوه الأوبجيكت.

بس لو حطيت كلمة virtual قبل أي فانكشن، فجأة حجم الأوبجيكت بيزيد 8 بايت (مؤشر). ليه؟ وإيه اللي بيحصل؟

---

### 1. المشكلة: الكومبايلر "المتسرع" (Static Binding) 🏃‍♂️

تعالى نشوف الكومبايلر بيفكر إزاي من غير `virtual`.



```C++
#include <iostream>
using namespace std;

class Parent {
public:
    void print() { cout << "I am Parent" << endl; }
};

class Child : public Parent {
public:
    void print() { cout << "I am Child" << endl; } // Overriding
};

int main() {
    // مؤشر من نوع الأب، بيشاور على ابن
    Parent* ptr = new Child(); 
    
    // الكومبايلر هنا "غبي". بيبص على نوع المؤشر (Parent*)
    // وبيقول: "أكيد أنت تقصد دالة الأب"
    // فبيربطها وقت الـ Compilation (Static Binding)
    ptr->print(); 
    
    return 0;
}
```

**النتيجة:** `I am Parent` (غلط! أنا عايز الابن).

---

### 2. الحل: كلمة `virtual` (Dynamic Binding) 🐢

عشان نحل المشكلة، بنقول للكومبايلر: "يا عم اتقل شوية، متقررش هتنادي مين دلوقتي.. استنى لما البرنامج يشتغل وشوف الأوبجيكت ده أصله إيه".

C++

```C++
class Parent {
public:
    // الكلمة السحرية
    virtual void print() { cout << "I am Parent" << endl; }
};
```

الآن النتيجة: `I am Child` (صح!).

السؤال بقى: "هو عرف إزاي وقت التشغيل إن ده Child؟" 🤔

هنا يظهر دور الـ Hidden Pointer.

---

### 1. تخيل المشهد (الممثلين) 🎬

1. **المؤشر `ptr`:** ده "الزبون" اللي معاه عنوان البيت (الأوبجيكت).
    
2. **الأوبجيكت (في الـ Heap):** ده "البيت" نفسه.
    
3. **الـ `vptr`:** ده "البواب" اللي قاعد في مدخل البيت. وظيفته الوحيدة: يديك **الدفتر** الخاص بالبيت ده.
    
4. **الـ `vtable`:** ده "الدفتر" (قائمة أرقام تليفونات).
    
5. **الفانكشن (Code):** دي "الشقة" اللي إحنا عايزين نوصلها في الآخر.
    

---

### 2. الرحلة خطوة بخطوة (The Journey) 🚶‍♂️

السيناريو: إنت كتبت في الـ main:

ptr->print();

(و ptr ده بيشاور على أوبجيكت من نوع Child).

**الخطوة 1: الوصول للبيت (Dereferencing)**

- الكمبيوتر بيمسك العنوان اللي في `ptr` ويروح للمكان ده في الميموري (Heap).
    
- أول ما يدخل البيت، بيلاقي في وشه علطول "البواب" (**vptr**). ده موجود في أول 8 بايت غصب عن أي حد.
    

**الخطوة 2: سؤال البواب (Fetch vptr)**

- الكمبيوتر بيسأل البواب: "فين دفتر التليفونات بتاع العيلة دي؟".
    
- بما إن البيت ده نوعه `Child`، البواب (vptr) هيديك عنوان **"دفتر عائلة Child"** (`Child_vtable`).
    
    - _(لو كان البيت ده نوعه `Parent`، البواب كان هيديك عنوان "دفتر عائلة Parent")_.
        

**الخطوة 3: فتح الدفتر (vtable Lookup)**

- الكمبيوتر بيروح للدفتر ده (الجدول).
    
- الكومبايلر كان متفق معاه من بدري: "يا كمبيوتر، دالة `print` دايماً هتلاقيها في **السطر الأول** (Index 0) في أي دفتر".
    
- فالكمبيوتر بيبص في السطر الأول في الدفتر.
    

**الخطوة 4: العنوان النهائي (Dynamic Dispatch)**

- السطر الأول في "دفتر Child" مكتوب فيه: **عنوان دالة `Child::print`**.
    
- (لو كنا فتحنا دفتر Parent، كنا هنلاقي مكتوب فيه عنوان `Parent::print`).
    

**الخطوة 5: القفز (Execute)**

- الكمبيوتر بياخد العنوان ده، وينط عليه ينفذ الكود.
    

---

### 3. رسمة كروكي "بالبلدي" ✍️

Plaintext

```
1. ptr (معايا عنوان 0x500)
    |
    V
2. Object at 0x500 (دخلنا البيت)
   +----------------------+
   | vptr (البواب)        | ----> بيشاور على: (دفتر Child) 
   | int x                |              |
   | int y                |              |
   +----------------------+              |
                                         |
         +-------------------------------+
         |
         V
3. Child vtable (الدفتر)
   +------------------------------------+
   | Index 0 (print)  | --> 0x999 (عنوان كود Child::print)
   | Index 1 (attack) | --> 0x888 (عنوان كود Child::attack)
   +------------------------------------+
                                |
                                V
                       4. Code Section (الشقة)
                          [ cout << "I am Child" ]
```

---

### 4. ليه اللفة الطويلة دي؟ 🤔

عشان المرونة.

الـ ptr ميعرفش هو بيشاور على إيه بالظبط (ممكن Child، وممكن GrandChild، وممكن Parent).

هو "أعمى".

فالحل الوحيد إنه يروح يخبط على "البيت" نفسه، والبيت هو اللي يقوله: "أنا نوعي كذا، ودي عناويني".

- البيت بيقول نوعه عن طريق الـ **vptr**.
    
- والعناوين موجودة في الـ **vtable**.
    



---

### 6. كود يثبت زيادة الحجم (الدليل القاطع) ⚖️



```C++
#include <iostream>
using namespace std;

class NoVirtual {
public:
    int x;
    void show() { cout << "Hi"; }
};

class WithVirtual {
public:
    int x;
    virtual void show() { cout << "Hi"; } // الكلمة اللي بتدفعك 8 بايت
};

int main() {
    // 4 بايت (int) بس
    cout << "Size without virtual: " << sizeof(NoVirtual) << " bytes" << endl; 

    // 4 بايت (int) + 4 بايت (Padding) + 8 بايت (vptr) = 16 بايت!
    // (الـ Padding حصل عشان الـ vptr 8 بايت فلازم الـ int يتحاذى معاه)
    cout << "Size with virtual:    " << sizeof(WithVirtual) << " bytes" << endl;

    return 0;
}
```

> [!NOTE] ملحوظة مهمة
> 
> مهما زودت دوال virtual جوه الكلاس (100 دالة مثلاً)، حجم الأوبجيكت مش هيزيد غير الـ 8 بايت بتوع المؤشر بس.
> 
> اللي بيكبر هو "الجدول" (vtable)، وده موجود مرة واحدة للكلاس كله، مش جوه كل أوبجيكت.

---

### 7. التكلفة (The Cost of Magic) 💸

هل الـ `virtual` مجانية؟ لأ.

1. **Memory Overhead:** زيادة 8 بايت لكل أوبجيكت (تفرق لو عندك ملايين الأوبجيكتس الصغيرة).
    
2. **Performance Overhead:** استدعاء الدالة بياخد لفة أطول (Pointer Dereference مرتين) بدل ما ينط للكود علطول. ده بيخليها أبطأ سنة صغيرة، وبيمنع الكومبايلر من عمل Optimization اسمه `Inlining`.
    

عشان كدة في **Game Engines**، بيحاولوا يتجنبوا الـ Virtual في الحاجات اللي بتتكرر كتير جداً (زي الـ Particles أو الرصاصات)، لكن بيستخدموها في الحاجات الكبيرة (زي اللاعب والوحوش).

---

### أولاً: فخ التدمير (The Virtual Destructor Trap) 💣

المشكلة:

لما يكون عندك مؤشر من نوع Base* بيشاور على أوبجيكت من نوع Derived، وتيجي تعمل delete.

الكومبايلر بطبيعته "كسول" (Static Binding). بيبص على نوع المؤشر بس.

- لو المؤشر نوعه `Base`، هينادي الـ Destructor بتاع الـ `Base` ويمشي.
    
- طب والـ `Derived`؟ والذاكرة اللي حجزها؟ **تتسرب (Memory Leak)**.
    

الحل:

لازم تحط كلمة virtual قبل الـ Destructor بتاع الأب. دي بتجبر الكومبايلر يبص في الـ vtable وقت التشغيل (Runtime) وينادي الـ Destructor الصح (بتاع الابن الأول، وبعدين الأب).

**الكود (The Fix):**



```C++
#include <iostream>
using namespace std;

class Base {
public:
    Base() { 
        cout << "Base Constructed" << endl; 
    }

    // IMPORTANT: virtual destructor ensures derived destructors are called
    virtual ~Base() { 
        cout << "Base Destroyed" << endl; 
    }
};

class Derived : public Base {
    int* array;
public:
    Derived() { 
        // Allocating resource in heap
        array = new int[10]; 
        cout << "Derived Constructed (Memory Allocated)" << endl; 
    }

    ~Derived() { 
        // Releasing resource
        delete[] array; 
        cout << "Derived Destroyed (Memory Freed)" << endl; 
    }
};

int main() {
    // Upcasting: Base pointer pointing to Derived object
    Base* ptr = new Derived();

    cout << "--- Deleting Object ---" << endl;

    // If Base destructor was NOT virtual:
    // Only ~Base() would be called. ~Derived() would be skipped -> Memory Leak.
    
    // Since it IS virtual:
    // 1. ~Derived() is called first (Cleaning the array).
    // 2. ~Base() is called second (Cleaning the base part).
    delete ptr;

    return 0;
}
```

---

### ثانياً: معركة النسخ (Shallow vs. Deep Copy) 👯

المشكلة:

لما تنسخ أوبجيكت جواه مؤشر (Pointer) باستخدام علامة = العادية.

الكمبيوتر بيعمل Shallow Copy (نسخ سطحي).

- يعني بينسخ **العنوان** اللي جوه المؤشر، مش **القيمة** اللي بيشاور عليها.
    
- النتيجة: عندك 2 أوبجيكت (الأصلي والنسخة) ماسكين "نفس المفتاح" لنفس المكان في الميموري.
    
- الكارثة: لما الأول يموت ويعمل `delete`، التاني لما يجي يموت هيعمل `delete` لنفس المكان! البرنامج يفرقع (Double Free Error).
    

الحل (Deep Copy):

لازم تكتب Copy Constructor بنفسك.

تقول فيه: "لما تنسخني، روح احجز مكان جديد خاص بالنسخة، وانقل البيانات جواه".

**الكود (The Fix):**



```C++
#include <iostream>
using namespace std;

class Buffer {
private:
    int* data;
    int size;

public:
    // Constructor
    Buffer(int s) {
        size = s;
        // Allocate separate memory for this object
        data = new int[size]; 
        for(int i=0; i<size; i++) data[i] = 0; // Initialize
        cout << "Buffer created at address: " << data << endl;
    }

    // 1. Custom Copy Constructor (Deep Copy)
    Buffer(const Buffer& other) {
        cout << "Copy Constructor Called (Deep Copy)..." << endl;
        
        // Copy the non-pointer values
        this->size = other.size;

        // CRITICAL STEP: Allocate NEW memory block
        this->data = new int[other.size];

        // Copy the actual CONTENT, not the address
        for (int i = 0; i < size; i++) {
            this->data[i] = other.data[i];
        }
    }

    // Destructor
    ~Buffer() {
        // Safe to delete because each object owns its own memory
        delete[] data; 
        cout << "Buffer destroyed (Memory Freed)" << endl;
    }
};

int main() {
    Buffer b1(5); // Creates memory block A

    // Calls Copy Constructor
    Buffer b2 = b1; 
    
    // Now:
    // b1.data points to block A
    // b2.data points to block B (New separate block)
    
    // When scope ends:
    // b2 is destroyed -> deletes block B (Safe)
    // b1 is destroyed -> deletes block A (Safe)
    
    return 0;
}
```

### الخلاصة (Summary):

1. **Virtual Destructor:**
    
    - **Scenario:** You have a `Base*` pointing to a `new Derived()`.
        
    - **Rule:** Always make the Base destructor `virtual`.
        
    - **Reason:** To ensure the Derived destructor is called to prevent memory leaks.
        
2. **Deep Copy:**
    
    - **Scenario:** Your class has a raw pointer (`int* ptr`) that manages dynamic memory.
        
    - **Rule:** Implement a Copy Constructor.
        
    - **Reason:** To allocate _new_ memory for the copy, preventing "Double Free" crashes.
        

---

بما إننا فهمنا الـ virtual، الخطوة المنطقية اللي بعدها علطول (وبتجي في الامتحانات وش) هي:

Abstract Classes & Pure Virtual Functions.

ده الموضوع اللي بيحول الـ C++ من مجرد "كلاسات بتورث بعض" لـ "System Design" حقيقي (Interfaces).

---

### الفكرة: الكلاس "المدير" (Abstract Class) 👔

تخيل إنك بتعمل برنامج رسم (Paint). عندك أشكال كتير: دائرة، مربع، مثلث.

أنت عايز تعمل كلاس أب اسمه Shape، وعايز تحط فيه دالة اسمها draw().

السؤال: لو أنا قلتلك Shape s; s.draw();.. هيترسم إيه؟

ولا حاجة! كلمة "شكل" دي كلمة مجردة (Abstract). مفيش حاجة في الواقع اسمها "شكل" بس، لازم تكون يا دائرة يا مربع.

هنا بنعمل حاجتين:

1. بنمنع الكومبايلر إنه يعمل Object من الكلاس `Shape`.
    
2. بنجبر أي حد يورث من `Shape` إنه لازم يكتب كود الرسم بتاعه بنفسه (عقد إلزامي).
    

---

### السنتكس: الدالة الصفرية (Pure Virtual Function) 0️⃣

عشان تحول الدالة لـ "مجردة" وتخلي الكلاس Abstract، بنساويها بالصفر.



```C++
virtual void functionName() = 0;
```

بمجرد ما الكلاس يكون فيه **دالة واحدة** بالشكل ده:

1. الكلاس بيتحول لـ **Abstract Class**.
    
2. ممنوع تعمل منه `new Shape()` أو `Shape s` (هيديك Compilation Error).
    
3. أي كلاس يورث منه **مجبر** يعمل Implementation للدالة دي، وإلا هو كمان هيبقى Abstract ومش هيشتغل.
    

---

### المثال العملي: الأشكال الهندسية (Shapes) 📐



```C++
#include <iostream>
using namespace std;

// 1. Abstract Base Class
// You cannot create an instance of this class.
class Shape {
public:
    // Pure Virtual Function
    // "= 0" means: I don't have an implementation here.
    // Children MUST implement this.
    virtual void draw() = 0; 

    // Normal virtual destructor (Best Practice)
    virtual ~Shape() { cout << "~Shape" << endl; }
};

// 2. Concrete Class (Circle)
class Circle : public Shape {
public:
    // Override is mandatory here
    void draw() override {
        cout << "Drawing a Circle 🔴" << endl;
    }
};

// 3. Concrete Class (Rectangle)
class Rectangle : public Shape {
public:
    void draw() override {
        cout << "Drawing a Rectangle 🟦" << endl;
    }
};

int main() {
    // Shape s; // ERROR: Cannot instantiate abstract class

    // But we can use Pointers! (Polymorphism)
    Shape* s1 = new Circle();
    Shape* s2 = new Rectangle();

    s1->draw(); // Calls Circle::draw
    s2->draw(); // Calls Rectangle::draw

    delete s1;
    delete s2;

    return 0;
}
```

---

### تريكات الامتحان (Exam Tricks) 📝

**س1: هل ينفع الـ Abstract Class يكون فيه دوال عادية (مش Pure)؟**

- **ج:** أيوة طبعاً. ممكن يكون فيه متغيرات ودوال عادية شغالة، ومعاهم دالة واحدة بس Pure. (ده الفرق بينه وبين الـ Interface في لغة زي Java).
    

**س2: هل ينفع يكون فيه Constructor للـ Abstract Class؟**

- **ج:** أيوة! رغم إنك مش بتعمل منه Object مباشر، بس الـ Constructor بتاعه بينادى أوتوماتيك لما الابن يتولد (عشان يجهز المتغيرات المشتركة).
    

**س3: لو ورثت من Abstract Class ومعملتش override للدالة الـ Pure؟**

- **ج:** الكلاس الابن ده هيتحول هو كمان لـ Abstract Class، ومش هتعرف تعمل منه Object.
    

---

### الموضوع الثاني المهم: الـ Access Modifiers في الوراثة 🔐

ده سؤال بيجي في الـ MCQ كتير.

إنت عارف public و private و protected جوه الكلاس.

بس إيه الفرق لما أقول:

class Child : public Parent

و

class Child : private Parent ؟

الجدول ده تحفظه زي اسمك:

|**طريقة الوراثة (Inheritance Mode)**|**الـ Public في الأب بيبقى إيه في الابن؟**|**الـ Protected في الأب بيبقى إيه في الابن؟**|**الـ Private في الأب بيبقى إيه في الابن؟**|
|---|---|---|---|
|**`public`** (الاشهر)|بيفضل **Public**|بيفضل **Protected**|**مخفي** (Inaccessible)|
|**`protected`**|بيتحول **Protected**|بيفضل **Protected**|**مخفي** (Inaccessible)|
|**`private`**|بيتحول **Private**|بيتحول **Private**|**مخفي** (Inaccessible)|

**الزتونة:**

1. **Public Inheritance:** "أنا ابنه والناس عارفة إني ابنه". (الواجهة بتفضل زي ما هي).
    
2. **Private Inheritance:** "أنا ابنه بس في السر". (بستخدم الكود بتاعه داخلياً، بس محدش من بره يعرف إني ورثت منه، وكل دواله بتبقى Private عندي).
    

**مثال سريع:**



```C++
class Parent {
public:    int x;
protected: int y;
private:   int z;
};

// Public Inheritance (Is-A Relationship)
class PublicChild : public Parent {
    // x is public
    // y is protected
    // z is hidden
};

// Private Inheritance (Implemented-In-Terms-Of)
class PrivateChild : private Parent {
    // x becomes PRIVATE (Cannot be accessed from main)
    // y becomes PRIVATE
    // z is hidden
};

int main() {
    PublicChild pub;
    pub.x = 10; // OK

    PrivateChild priv;
    // priv.x = 10; // ERROR: x is private inside PrivateChild
}
```

---
تمام يا هندسة، طالما نبه عليه يبقى ده **سؤال مضمون في جيبك**. 💯

الـ Operator Overloading هو "الدلع" بتاع الـ C++.

أنت هدفك تخلي الكلاس بتاعك يتصرف كأنه int عادي.

يعني بدل ما تكتب:

c3 = c1.add(c2);

تكتب:

c3 = c1 + c2;

الكمبيوتر مبيفهمش يعني إيه "اجمع موظفين" أو "اضرب صندوقين". أنت اللي لازم تفهمه معنى العلامة (`+`, `-`, `*`, `==`) بالنسبة للكلاس بتاعك.

هنقسم الموضوع لـ 3 أجزاء بتيجي في الامتحانات:

1. **Binary Operators (`+`, `-`)**: كعضو جوه الكلاس.
    
2. **Output Operator (`<<`)**: ودي التريكة (لازم تكون `friend`).
    
3. **Unary Operators (`++`)**: الزيادة والنقصان.
    

---

### المثال الذهبي: الأعداد المركبة (Complex Numbers) 🧮

ده أشهر مثال بيتشرح عليه الموضوع ده، لأنه بيحتاج جمع وطباعة.

#### 1. جمع كائنين (`+` Operator)

لما بتكتب `c1 + c2`:

- الـ `c1` هو اللي بينادي الفانكشن (الـ `this`).
    
- الـ `c2` بيتبعت كـ Parameter.
    
- النتيجة بترجع في كائن جديد (New Object).
    

#### 2. طباعة الكائن (`<<` Operator) - سؤال الامتحان ⚠️

لما بتكتب `cout << c1`:

- مين اللي على الشمال؟ `cout` (مش الكائن بتاعك).
    
- عشان كده **مينفعش** تكون Member Function (لأن الـ Member لازم الكائن بتاعك يكون على الشمال).
    
- **الحل:** بنعملها **`friend` function** عشان تقدر تدخل جوه الكلاس وتجيب الـ private data، وفي نفس الوقت هي مش جزء منه.
    

---

### الكود الشامل (احفظ الـ Syntax ده صم) 📝



```C++
#include <iostream>
using namespace std;

class Complex {
private:
    float real;
    float imag;

public:
    // Constructor
    Complex(float r = 0, float i = 0) : real(r), imag(i) {}

    // ---------------------------------------------------------
    // 1. Binary Operator Overloading (+)
    // Syntax: ReturnType operatorOp(Parameter)
    // Meaning: c3 = c1 + c2  --> c1.operator+(c2)
    // ---------------------------------------------------------
    Complex operator+(const Complex& other) {
        cout << "Executing + operator" << endl;
        // Create a new object holding the result
        Complex result;
        result.real = this->real + other.real;
        result.imag = this->imag + other.imag;
        return result; // Return by Value (New Object)
    }

    // ---------------------------------------------------------
    // 2. Comparison Operator (==)
    // Returns true or false
    // ---------------------------------------------------------
    bool operator==(const Complex& other) {
        return (this->real == other.real && this->imag == other.imag);
    }

    // ---------------------------------------------------------
    // 3. Output Stream Operator (<<) - THE EXAM TRICK
    // Must be a 'friend' because 'cout' is the left operand.
    // Returns ostream& to allow chaining (cout << c1 << c2)
    // ---------------------------------------------------------
    friend ostream& operator<<(ostream& os, const Complex& c);
};

// Implementation of the friend function (Outside the class)
ostream& operator<<(ostream& os, const Complex& c) {
    // We can access private members (real, imag) because we are friends
    os << c.real << " + " << c.imag << "i";
    return os; // Return the stream object to enable chaining
}

int main() {
    Complex c1(3.0, 4.0);
    Complex c2(1.0, 2.0);

    // Using the overloaded + operator
    // Translated to: Complex c3 = c1.operator+(c2);
    Complex c3 = c1 + c2;

    // Using the overloaded << operator
    // Translated to: operator<<(cout, c3);
    cout << "Result: " << c3 << endl;

    // Using == operator
    if (c1 == c2) 
        cout << "Equal" << endl;
    else 
        cout << "Not Equal" << endl;

    return 0;
}
```

---

### تريكات مهمة للامتحان (Exam Tips) 💡

**1. ليه بنرجع `Complex` في الجمع، بس بنرجع `Complex&` في الـ `+=`؟**

- في `c1 + c2`: إحنا بنطلع ناتج جديد، والأصليين مبيتغيروش. فلازم نرجع `Object` جديد (Return by Value).
    
- في `c1 += c2`: إحنا بنعدل على `c1` نفسه. فلازم نرجع `*this` (Return by Reference).
    

**2. ليه دالة الـ `operator<<` بتاخد `ostream&` مش `ostream`؟**

- لأن `cout` كائن ممنوع يتنسخ (Non-copyable). لازم دايماً يتبعت بالـ Reference.
    

**3. الفرق بين `++c1` (Prefix) و `c1++` (Postfix):**

- دي بتيجي عشان يشوفك فاهم ولا حافظ.
    
- الـ **Prefix**: `operator++()` (فاضية).
    
- الـ **Postfix**: `operator++(int)` (بتاخد int وهمي). الـ `int` ده ملوش لازمة غير عشان الكومبايلر يفرق بينهم.
    

**مثال سريع للـ `++`:**



```C++
// Prefix (++c)
Complex& operator++() {
    real++; 
    return *this; // رجعني أنا بعد الزيادة
}

// Postfix (c++)
Complex operator++(int) {
    Complex temp = *this; // احفظ قيمتي القديمة
    real++;               // زودني
    return temp;          // رجع القديمة (عشان كده c++ بتستخدم القيمة القديمة الأول)
}
```

---

### سؤال ممكن يجيلك نظري أو شفوي:

س: هل ينفع نعمل Overload للـ . (Dot operator) أو :: (Scope resolution)؟

ج: لأ! فيه 4 علامات ممنوع تلمسهم في C++:

1. `.` (Member access)
    
2. `::` (Scope resolution)
    
3. `?:` (Ternary operator)
    
4. `sizeof`
    

أي حاجة تانية (`+`, `-`, `[]`, `->`, `()`) دوس فيها براحتك.

---

### الجزء الأول: Copy Constructor (ماكينة التصوير) 📸

هو **Constructor** خاص جداً، بيتنده أوتوماتيك في لحظة واحدة بس: **لما تعمل أوبجيكت جديد باقتباس (نسخ) من أوبجيكت قديم.**

#### إمتى بيتنده؟ (The 3 Scenarios)

1. `MyClass obj2 = obj1;` (اللحظة دي بالذات).
    
2. `MyClass obj2(obj1);` (نفس المعنى بس شكل مختلف).
    
3. لما تبعت أوبجيكت لفانكشن **Pass by Value**.
    

#### الكود (Deep Copy Example)

هنعمل كلاس شايل `pointer` عشان نشوف فايدته الحقيقية.



```C++
#include <iostream>
using namespace std;

class SmartArray {
private:
    int* ptr;
    int size;

public:
    // 1. Normal Constructor
    SmartArray(int s) {
        size = s;
        ptr = new int[size]; // Allocate memory
        cout << "Memory Allocated at: " << ptr << endl;
    }

    // 2. THE COPY CONSTRUCTOR
    // Syntax: ClassName(const ClassName& other)
    SmartArray(const SmartArray& other) {
        cout << "Copy Constructor Called (Deep Copy)" << endl;
        
        // Copy the size
        this->size = other.size;
        
        // CRITICAL: Allocate NEW memory for the new object
        this->ptr = new int[other.size];
        
        // Copy values manually
        for (int i = 0; i < size; i++) {
            this->ptr[i] = other.ptr[i];
        }
    }

    // Destructor
    ~SmartArray() {
        delete[] ptr; // Clean up
    }
};

int main() {
    SmartArray arr1(5); // Normal Constructor
    
    // Here Copy Constructor is called!
    SmartArray arr2 = arr1; 
    
    return 0;
}
```

---

### الجزء الثاني: كتالوج الـ Operator Overloading الشامل 🧰

هنعمل كلاس اسمه Point (نقطة x, y) وهنطبق عليه كل العمليات الممكنة.

ركز في الـ Return Type والـ Parameters لكل واحد، لأن دي التريكة.



```C++
#include <iostream>
using namespace std;

class Point {
private:
    int x, y;

public:
    Point(int x = 0, int y = 0) : x(x), y(y) {}

    // ==========================================
    // 1. Arithmetic Operators (+, -, *, /)
    // Type: Binary (Takes 1 parameter)
    // Returns: New Object (By Value)
    // ==========================================
    Point operator+(const Point& other) {
        Point temp;
        temp.x = this->x + other.x;
        temp.y = this->y + other.y;
        return temp; // Return new result
    }

    // ==========================================
    // 2. Comparison Operators (==, !=, <, >)
    // Type: Binary
    // Returns: bool (True/False)
    // ==========================================
    bool operator==(const Point& other) {
        return (this->x == other.x && this->y == other.y);
    }

    // ==========================================
    // 3. Assignment Operator (=) - IMPORTANT
    // Type: Binary
    // usage: p1 = p2; (Existing objects)
    // Returns: Reference to *this (to allow a = b = c)
    // ==========================================
    Point& operator=(const Point& other) {
        // Self-assignment check (safety)
        if (this == &other) return *this;

        // Copy logic (Deep copy goes here usually)
        this->x = other.x;
        this->y = other.y;

        return *this;
    }

    // ==========================================
    // 4. Prefix Increment (++p)
    // Type: Unary (No parameters)
    // Returns: Reference (The object AFTER change)
    // ==========================================
    Point& operator++() {
        this->x++;
        this->y++;
        return *this; // Return updated object
    }

    // ==========================================
    // 5. Postfix Increment (p++)
    // Type: Unary (Takes dummy int)
    // Returns: Value (The object BEFORE change)
    // ==========================================
    Point operator++(int) {
        Point oldState = *this; // Save old value
        this->x++;              // Increment
        this->y++;
        return oldState;        // Return old value
    }

    // ==========================================
    // 6. Subscript Operator ([])
    // Usage: cout << p[0]; (0 for x, 1 for y)
    // Returns: Reference (To allow modification p[0] = 5)
    // ==========================================
    int& operator[](int index) {
        if (index == 0) return x;
        else if (index == 1) return y;
        
        // Error handling needed here normally
        static int err = -1; 
        return err;
    }
    
    // ==========================================
    // 7. Function Call Operator (Functor)
    // Usage: p(10, 20); -> Updates the point
    // ==========================================
    void operator()(int newX, int newY) {
        this->x = newX;
        this->y = newY;
        cout << "Functor called!" << endl;
    }

    // Friend Function for cout
    friend ostream& operator<<(ostream& os, const Point& p);
};

// ==========================================
// 8. Output Stream Operator (<<)
// Must be GLOBAL/FRIEND (Not member)
// ==========================================
ostream& operator<<(ostream& os, const Point& p) {
    os << "(" << p.x << ", " << p.y << ")";
    return os;
}

int main() {
    Point p1(10, 20);
    Point p2(5, 5);

    // 1. Plus
    Point p3 = p1 + p2; // (15, 25)

    // 2. Comparison
    if (p1 == p2) cout << "Equal" << endl;

    // 3. Assignment
    p1 = p2; // p1 becomes (5, 5)

    // 4. Increment
    ++p1; // p1 becomes (6, 6)

    // 5. Subscript
    p1[0] = 100; // sets x to 100
    cout << "X is: " << p1[0] << endl;

    // 6. Functor
    p1(50, 50); // Sets p1 to (50, 50)
    
    // 7. Output
    cout << p1 << endl;

    return 0;
}
```

### 💡 ملخص "الزتونة" للامتحان:

1. *_Binary (+, -, _):__ `ReturnType operator+(const Type& other)`
    
2. **Boolean (==, <):** `bool operator==(const Type& other)`
    
3. **Assignment (=):** `Type& operator=(const Type& other)` (لازم ترجع `*this`).
    
4. **Output (<<):** `friend ostream& operator<<(ostream& os, const Type& obj)`
    
5. **Array ([]):** `int& operator[](int index)` (ترجع Reference عشان تقدر تعدل القيمة).
    

---

الـ **Arrow Operator (`->`)** هو السر وراء عمل الـ **Smart Pointers** (زي `std::shared_ptr` و `std::unique_ptr`).

فكرته غريبة شوية عن الباقين:

هو مش بيعمل العملية بنفسه، هو شغال بنظام "سلمني للي بعدي". لما بتعمله Overload، هو بيرجع "مؤشر حقيقي" (Raw Pointer)، والكومبايلر أوتوماتيك بيكرر علامة السهم تاني على المؤشر اللي رجع ده.

---

### الفكرة: المؤشر الذكي (The Smart Pointer Wrapper) 🎁

تخيل إنك عملت كلاس اسمه SmartPtr. الكلاس ده جواه مؤشر حقيقي T* ptr.

أنت عايز لما اليوزر يكتب sp->func().. الكلاس بتاعك ياخد الطلب ده ويوصله للمؤشر الحقيقي اللي جواه.

### الكود (Smart Pointer Simulation) 💻

ركز في دالة `operator->`، هتلاقيها مابتاخدش حاجة، وبترجع Pointer.



```C++
#include <iostream>
using namespace std;

// 1. The Class we want to access
class Employee {
public:
    void work() {
        cout << "Employee is working... 👷" << endl;
    }
    
    void sleep() {
        cout << "Employee is sleeping... 😴" << endl;
    }
};

// 2. The Smart Pointer Class (Wrapper)
class MySmartPtr {
private:
    Employee* ptr; // The actual raw pointer

public:
    // Constructor
    MySmartPtr(Employee* p = nullptr) : ptr(p) {}

    // Destructor (Auto-Cleanup!)
    ~MySmartPtr() {
        if (ptr) {
            delete ptr;
            cout << "Pointer deleted automatically! 🗑️" << endl;
        }
    }

    // ==========================================
    // THE ARROW OPERATOR OVERLOADING
    // Syntax: ReturnType* operator->()
    // It returns the raw pointer held inside
    // ==========================================
    Employee* operator->() {
        // You can add logic here (e.g., logging)
        cout << "[Log]: Accessing member via arrow..." << endl;
        return ptr;
    }
};

int main() {
    // Creating a Smart Pointer Object (Not a raw pointer)
    // Note: We used 'new', but we won't use 'delete' (Destructor handles it)
    MySmartPtr sp(new Employee());

    // USAGE:
    // Normally, 'sp' is an object, so we should use dot (.).
    // But since we overloaded '->', we can use it like a pointer!
    
    // Logic:
    // 1. sp->work() calls sp.operator->()
    // 2. operator->() returns the raw 'Employee*'
    // 3. Compiler effectively does: (rawPointer)->work()
    
    sp->work(); 
    sp->sleep();

    return 0;
}
```

---

### إيه اللي حصل تحت الكبوت؟ (The Compiler Trick) 🎩

لما أنت كتبت:

sp->work();

الكومبايلر ترجمها بالشكل ده (خطوتين):

1. نادى الفانكشن بتاعتك: `sp.operator->()` ... ودي رجعت مؤشر حقيقي `Employee*`.
    
2. استخدم المؤشر ده عشان ينادي الفانكشن: `(Returned_Pointer)->work()`.
    

### ليه ده مفيد؟

1. **Logging:** تقدر تعرف كام مرة حد استخدم المؤشر.
    
2. **Validation:** تقدر تتأكد إن المؤشر مش `NULL` قبل ما ترجعه (وتمنع Crash).
    
3. **Lazy Loading:** ممكن المؤشر يكون فاضي، ولما حد ينادي السهم `->`، تروح تحمل الداتا من الداتابيز في اللحظة دي بس!
    

---

### الموضوع: Static Members (ساعة الحائط) 🕒

الفكرة:

تخيل إحنا في فصل (Class).

- **Instance Variable:** كل طالب لابس "ساعة يد" خاصة بيه. لو غيرت ساعتي، ساعتك مش هتتغير.
    
- **Static Variable:** "ساعة الحائط" المعلقة فوق السبورة. هي ساعة واحدة بس، والكل شايفها. لو حد قدمها 5 دقايق، الفصل كله هيشوفها متقدمة.
    

الـ `static` متغير بيتحجز مرة واحدة بس في الميموري، ومش بيموت لما الأوبجيكت يموت. هو عايش مع الكلاس نفسه.

#### 1. الـ Syntax وقواعده 📜

1. **جوة الكلاس:** بتحط كلمة `static`.
    
2. **برة الكلاس:** (مهمة جداً) لازم تديله قيمة ابتدائية برة الـ `main` وبرة الكلاس.
    

#### 2. مثال الامتحان (العداد) 🔢

أشهر سؤال: "عد عدد الأوبجيكتس اللي اتعملت في البرنامج".



```C++
#include <iostream>
using namespace std;

class Robot {
public:
    int id; // متغير عادي (كل روبوت ليه رقم خاص)
    
    // متغير مشترك (عداد واحد لكل الروبوتات)
    static int count; 

    Robot() {
        count++; // زود العداد المشترك
        id = count; // خد رقم الدور الحالي
        cout << "Robot #" << id << " created." << endl;
    }

    // دالة ستاتيك (تقدر تناديها من غير ما تعمل أوبجيكت)
    static void showCount() {
        cout << "Total Robots: " << count << endl;
        // ملحوظة: دالة الـ static مينفعش تشوف الـ id العادي!
        // بتشوف بس المتغيرات الـ static زيها.
    }
};

// تهيئة المتغير الستاتيك (لازم برة الكلاس!)
int Robot::count = 0;

int main() {
    // ممكن أنادي الدالة من اسم الكلاس علطول
    Robot::showCount(); // Total: 0

    Robot r1; // count بقى 1
    Robot r2; // count بقى 2
    Robot r3; // count بقى 3

    Robot::showCount(); // Total: 3
    
    // خد بالك: r1.count هي هي r2.count هي هي Robot::count
    // كلهم بيشاوروا على نفس المكان في الميموري
    cout << "r1 sees: " << r1.count << endl; // 3

    return 0;
}
```

---

#### 3. تريكات الـ MCQ في الـ Static ⚠️

**س1: هل دالة الـ `static` ينفع تستخدم كلمة `this`؟**

- **ج:** **لأ مستحيل!** لأن `this` ده عنوان الأوبجيكت الحالي، والـ `static` دالة بتاعت الكلاس كله ملهاش صاحب (أوبجيكت) محدد.
    

**س2: هل دالة الـ `static` ينفع تنادي متغير عادي (Non-static)؟**

- **ج:** **لأ!** (Error). لأنها مش عارفة المتغير ده تبع انهي أوبجيكت فيهم.
    
    - (الستاتيك يكلم ستاتيك بس.. العادي يكلم كله).
        

**س3: إيه حجم الأوبجيكت اللي فيه `static int`؟**

- **ج:** الـ `static` **لا يحسب** ضمن حجم الأوبجيكت (sizeof). لأنه متخزن في مكان لوحده (Global Memory) مش جوه الأوبجيكت.
    

---
تمام، يبقى ريحنا من "وجع دماغ" التعامل مع الملفات. 📁❌

كدة فاضل لنا **محطتين صغيرين** ونقفل المنهج ونبدأ حل امتحانات فوراً:

1. **Templates:** (إزاي تكتب كود "جوكر" يشتغل على أي نوع داتا).
    
2. **Exception Handling:** (إزاي تمنع البرنامج يضرب لما يحصل Error).
    

دول بييجوا في الامتحان أسئلة "مضمونة" (Write code snippet).

يلا ناخدهم في "كبسولة" سريعة. 💊

---

### المحطة قبل الأخيرة: Templates (القالب الجوكر) 🃏

المشكلة:

أنت عايز تعمل دالة تجمع رقمين.

- لو `int`: `int add(int a, int b) { return a+b; }`
    
- لو `float`: `float add(float a, float b) { return a+b; }`
    
- لو double: ...
    
    هتفضل تكرر نفس الكود 100 مرة؟ لأ.
    

الحل:

بنعمل "قالب" (Template). بنقول للكومبايلر: "أنا هستخدم نوع مجهول اسمه T، ولما حد ينادي الدالة، ابقى شيل الـ T وحط النوع اللي هو بعته".

#### 1. Function Template (دالة لكل الأنواع)



```C++
#include <iostream>
using namespace std;

// السطر السحري: T ده مجرد اسم (ممكن تسميه Type او Gamosa عادي)
template <typename T>
T add(T a, T b) {
    return a + b;
}

int main() {
    // الكومبايلر هنا هيعمل نسخة int من الدالة
    cout << add(5, 10) << endl;      // 15
    
    // الكومبايلر هنا هيعمل نسخة float من الدالة
    cout << add(3.5f, 2.1f) << endl; // 5.6
    
    // ممكن تحدد النوع بنفسك لو عايز
    cout << add<double>(5.5, 2.2) << endl; 

    return 0;
}
```

#### 2. Class Template (كلاس لكل الأنواع) 📦

سؤال الامتحان المشهور: **"اعمل كلاس `Pair` بيشيل قيمتين من أي نوع"**.



```C++
template <typename T>
class Pair {
private:
    T first;
    T second;
public:
    Pair(T f, T s) : first(f), second(s) {}

    T getMax() {
        return (first > second) ? first : second;
    }
};

int main() {
    // لازم تحدد النوع بين < > وأنت بتعرف الأوبجيكت
    Pair<int> p1(10, 20); 
    cout << p1.getMax() << endl; // 20

    Pair<float> p2(5.5, 3.3);
    cout << p2.getMax() << endl; // 5.5
}
```

تريكة الامتحان:

لو عايز تخلي الكلاس يشيل نوعين مختلفين؟ (مثلاً int و string مع بعض)؟

بسيطة: template <typename T1, typename T2>

---

### المحطة الأخيرة: Exception Handling (شبكة الأمان) 🕸️

الفكرة:

لما بتقسم على صفر 5 / 0، البرنامج بيعمل Crash ويقفل في وش اليوزر.

إحنا عايزينه لما يغلط، يطلع رسالة شيك "ممنوع القسمة على صفر" ويكمل شغل عادي.

الكلمات المفتاحية الثلاثة:

1. **`try`**: "جرب تنفذ الكود ده (اللي شاكين إنه خطر)".
    
2. **`throw`**: "لو حصلت مشكلة، ارمي قنبلة (Error)".
    
3. **`catch`**: "القط القنبلة دي واتصرف معاها قبل ما تفرقع البرنامج".
    

#### كود الامتحان (Division by Zero) ➗

C++

```
#include <iostream>
using namespace std;

double division(int a, int b) {
    if (b == 0) {
        // بنرمي Error (ممكن نرمي رقم، نص، أو أوبجيكت كامل)
        throw "Division by zero error!";
    }
    return (double)a / b;
}

int main() {
    int x = 10, y = 0;

    try {
        // المنطقة الخطرة
        cout << division(x, y) << endl;
        cout << "This line will NOT execute if error happens" << endl;
    } 
    catch (const char* msg) {
        // منطقة الطوارئ (بتتنفذ بس لو حصل throw)
        cout << "Exception Caught: " << msg << endl;
    }

    cout << "Program continues..." << endl; // البرنامج كمل وممتش

    return 0;
}
```

#### تريكة الـ MCQ ⚠️

س: لو رميت throw ومفيش catch بتستقبله؟

ج: البرنامج هيعمل terminate (Crash) فوراً. الـ catch إلزامي عشان الأمان يشتغل.

---
