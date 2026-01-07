يا أهلاً بك يا هندسة في الحلقة الأخيرة من "ثلاثية الروابط". إحنا النهاردة هنقفل الدائرة حرفياً! بعد ما درسنا الطريق اللي بيمشي لقدام بس (Singly)، والطريق اللي رايح جاي (Doubly)، جه الوقت نشوف الطريق اللي "مبينتهيش"، وهو الـ **Circular Linked List (CLL)**.

ده الهيكل اللي المبرمجين بيستخدموه لما يحبوا الداتا "تلف وتدور" من غير ما تخرج بره الميموري. اربط الحزام، عشان هنعرف ليه الـ `NULL` اختفى من حساباتنا النهاردة.

---

## المحطة الثالثة: القوائم المترابطة الدائرية - Circular Linked Lists

### التعريف السريع

الـ **Circular Linked List** هي نسخة معدلة من الـ Linked List (سواء كانت Singly أو Doubly)، بس الفرق الجوهري إن الـ **Last Node** (آخر عقدة) مش بتشاور على `NULL`؛ دي بتشاور بكل حب على الـ **First Node** (أول عقدة). وبكده السلسلة بتتحول لـ "حلقة مفرغة" أو Loop ملوش نهاية.

---

### الشرح التفصيلي

بص يا سيدي، تعال نحكي الحكاية اللي خلت الهيكل ده "فرض عين" على مهندسي الأنظمة.

#### 1. القصة والتاريخ: مشكلة الـ Round-Robin

في الستينيات، مع ظهور أنظمة التشغيل اللي بتسمح بكذا مستخدم (Multi-user systems)، ظهرت معضلة: "إزاي الـ CPU يوزع وقته على كذا برنامج (Process) بالعدل؟".

الحل كان خوارزمية اسمها Round-Robin Scheduling. الفكرة إننا بنحط كل العمليات في طابور، والـ CPU بيدي لكل واحدة "ثانية"، ولما يخلص الأخيرة، لازم يرجع فوراً للأولى يعيد الكرة.

لو استخدمنا Linked List عادية، الـ CPU كل ما يوصل للآخر هيضطر يلف من الأول يدور على الـ Head ($O(n)$). لكن المهندسين قالوا: "طب ما نربط آخر واحدة بأول واحدة!"، ومن هنا الـ CPU بقى بيمشي في دايرة $O(1)$ وبدون توقف.

#### 2. المستوى السطحي: "إيه ده؟" (The Concept)

تخيل "لعبة الكراسي الموسيقية". الأولاد واقفين في دايرة، وكل واحد حاطط إيده على كتف اللي قدامه. مفيش حد "أول" ومفيش حد "أخير" بالمعنى التقليدي، لأن الدايرة مقفولة.

في الميموري، إنت لو بدأت من أي Node وفضلت تمشي ورا الـ next pointer، هتلاقي نفسك رجعت لنفس النقطة اللي بدأت منها.

#### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Tail Pointer Trick)

هنا بقى "التريكاية" اللي بتفرق المحترف عن الهاوي. في الـ Singly والـ Doubly، كنا دايماً بنحفظ عنوان الـ Head.

في الـ Circular، الأذكى إننا نحفظ عنوان الـ Tail (آخر واحدة). ليه؟

- لأن الـ `Tail->next` هو الـ **Head**.
    
- فكده بـ Pointer واحد بس (الـ Tail)، إنت معاك "آخر السلسلة" ومعاك "أول السلسلة" في خطوة واحدة. ده بيخلي الإضافة في الأول أو في الآخر تتم في **$O(1)$** من غير مجهود.
    

#### 4. المستوى العميق: "ليه اتصمم كده؟ والـ Trade-offs"

- **الوصول المستمر (Continuous Access):** الـ CLL مثالية لأي تطبيق محتاج يلف على الداتا بشكل دوري (Cyclic). زي الـ Buffers اللي بتشيل الـ Audio/Video عشان لما تخلص الأغنية تبدأ من الأول تاني (Repeat mode).
    
- **إدارة الموارد:** في أنظمة الـ Embedded، بنستخدمها عشان ندير الـ Buffers المحدودة الحجم. الداتا الجديدة بتكتب فوق القديمة في دايرة (Circular Buffer).
    

**التحديات (The Risks):**

- **The Infinite Loop Trap:** دي أكبر مصيبة. لو كتبت `while(temp != nullptr)` في الـ Circular، البرنامج هيفضل يلف للأبد ومش هيقف (Infinite Loop) لأنك عمرك ما هتوصل لـ `nullptr`. لازم تغير الـ Logic بتاعك وتوقف لما الـ `temp` يرجع للـ `Head`.
    
- **التعقيد في الـ Coding:** التعامل مع الـ CLL أصعب شوية في حالات "المسح" خصوصاً لو السلسلة فيها Node واحدة بس. لازم الـ Node دي تشاور على نفسها!
    

---

### كيفية العمل (How It Works) - سيناريو الـ Traversal

عشان نلف على الـ Circular ونطبعها، بنعمل الآتي:

1. بنبدأ من الـ `Head`.
    
2. بنستخدم `do-while loop` عشان نضمن إننا دخلنا السلسلة الأول.
    
3. بنمشي لحد ما نلاقي الـ Pointer رجع تانية يشاور على الـ `Head`.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود لـ **Singly Circular Linked List** بيستخدم الـ `tail` pointer عشان نكون "رغايين" في الكفاءة (Efficiency).

C++

```
#include <iostream>

using namespace std;

// Node structure for the circular chain
struct Node {
    int data;
    Node* next;

    Node(int val) {
        data = val;
        next = nullptr;
    }
};

class CircularLinkedList {
private:
    Node* tail; // Pointing to the last node is smarter in CLL

public:
    CircularLinkedList() {
        tail = nullptr;
    }

    // Insert at the front: O(1) complexity
    void insertFront(int val) {
        Node* newNode = new Node(val);
        if (tail == nullptr) {
            tail = newNode;
            tail->next = tail; // Point to itself to close the circle
            return;
        }
        newNode->next = tail->next; // New node points to the current head
        tail->next = newNode;       // Tail points to the new head
    }

    // Insert at the back: O(1) complexity
    void insertEnd(int val) {
        insertFront(val); // Same logic as insertFront
        tail = tail->next; // Just shift the tail to the new last node
    }

    // Display the circle: O(n)
    void display() {
        if (tail == nullptr) {
            cout << "List is empty!" << endl;
            return;
        }

        Node* temp = tail->next; // Start from the Head (tail->next)
        do {
            cout << temp->data << " -> ";
            temp = temp->next;
        } while (temp != tail->next); // Stop when we return to head
        
        cout << "(Back to Head)" << endl;
    }

    // Destructor to clean Heap memory
    ~CircularLinkedList() {
        if (tail == nullptr) return;

        Node* current = tail->next; // Start from head
        tail->next = nullptr;       // Break the circle to make it a normal list
        
        while (current != nullptr) {
            Node* nextNode = current->next;
            delete current;
            current = nextNode;
        }
    }
};

int main() {
    CircularLinkedList cll;

    cll.insertEnd(10);
    cll.insertEnd(20);
    cll.insertEnd(30);
    cll.insertFront(5);

    // Expected Output: 5 -> 10 -> 20 -> 30 -> (Back to Head)
    cout << "Circular Linked List Content:" << endl;
    cll.display();

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Single Node List:** لما يكون عندك عنصر واحد بس، الـ `next` بتاعه بيشاور على نفسه. دي حالة لازم تتهندل صح في الحذف، وإلا الـ `tail` هيفضل يشاور على ميموري اتمسحت.
    
2. **Searching in CLL:** لو بتدور على عنصر مش موجود، لازم يكون عندك عداد أو تقارن الـ `temp` بالـ `head`. لو نسيت، الـ `search` هيفضل يلف للأبد ويستهلك الـ CPU بنسبة 100%.
    
3. **Splitting a CLL:** من المسائل المشهورة في الإنترفيوهات هي "إزاي تقسم دايرة لدايرتين؟". الحل بيعتمد على خوارزمية **Tortoise and Hare** (السلحفاة والأرنب) عشان تلاقي نص الدايرة وتكسر الروابط.
    

---

### الربط بالمفاهيم التانية

موضوع الـ CLL مرتبط بـ:

- **Round-Robin Scheduling:** توزيع مهام المعالج في الـ OS.
    
- **Multiplayer Games:** لو عندك لعبة "بتبادل الأدوار" (Turn-based game) زي بنك الحظ أو الكوتشينة، الـ CLL بتدير مين عليه الدور.
    
- **Circular Queues:** اللي هنستخدمها في المحطة الجاية عشان نبني طابور مبيخلصش في الـ Arrays.
    

### المصادر والقراءة الإضافية

- **كتاب CLRS (الفصل 10):** بيشرح الـ Circular Lists مع الـ Sentinel nodes.
    
- **Algorithm Design Manual (Steven Skiena):** بيشرح الـ Josephus Problem وكيفية حلها بالـ CLL.
    
- **GeeksForGeeks:** تمارين متقدمة على الـ Doubly Circular Linked List.
    

