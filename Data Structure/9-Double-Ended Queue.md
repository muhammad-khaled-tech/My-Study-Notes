يا أهلاً بك يا دكتور في "الجوكر" بتاع هياكل البيانات! إحنا خلصنا الـ Stack (بابه واحد) والـ Queue (باب دخول وباب خروج)، دلوقتي إحنا قدام الـ **Deque** (تنطق "Deck")، وهي اختصار لـ **Double-Ended Queue**.

لو الـ Stack والـ Queue هما آلات متخصصة، فالـ Deque هو "السكينة السويسري"؛ هو الهيكل اللي يقدر يمثل Stack ويقدر يمثل Queue في نفس الوقت، وبمرونة مرعبة.

اربط الحزام، وتعال نغوص في أعماق "السطر المزدوج" ونعرف حكايته وليه المهندسين بيعتبروه "المنقذ" في الحالات المعقدة.

---

## المحطة الثالثة (ج): الطابور مزدوج النهاية - The Deque

### 1. القصة والتاريخ: من "أوراق اللعب" إلى عبقرية دونالد كنوث

كلمة **Deque** صاغها العالم الأسطوري **Donald Knuth** (أبو الخوارزميات) في كتابه الشهير _The Art of Computer Programming_. كنوث لاحظ إن فيه مشاكل برمجية محتاجة مرونة أكتر من إننا نلتزم بـ FIFO أو LIFO بس.

تخيل "كوتشينة" (Deck of cards) محطوطة على التربيزة. إنت تقدر تسحب كارت من فوق، وتقدر تسحب كارت من تحت. وتقدر تضيف كارت فوق، وتقدر تضيف كارت تحت. الحرية دي هي اللي خلت الـ Deque حجر أساس في لغات زي **C++** (في الـ STL) و **Python** (في مكتبة collections). المبرمجين في السبعينيات استخدموها بكثافة عشان يبنوا "نظم إدارة الذاكرة" اللي محتاجة سرعة في التعامل مع الطرفين.

---

### 2. المستوى السطحي: "إيه ده؟" (The Concept)

الـ Deque هو طابور ملوش "قواعد مرور" صارمة. إنت واقف قدام ممر، الممر ده له فتحتين.

- تقدر تدخل من اليمين وتخرج من اليمين (كأنه **Stack**).
    
- تقدر تدخل من اليمين وتخرج من الشمال (كأنه **Queue**).
    
- تقدر تدخل من الشمال وتخرج من اليمين.
    
- تقدر تدخل من الشمال وتخرج من الشمال.
    

هو هيكل بيانات بيجمع بين مميزات الـ Stack والـ Queue في وعاء واحد.

---

### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Mechanics)

الـ Deque كـ ADT بيعرف لنا 4 عمليات أساسية:

1. **insertFront (pushFront):** إضافة عنصر في أول الطابور.
    
2. **insertLast (pushBack):** إضافة عنصر في آخر الطابور.
    
3. **deleteFront (popFront):** حذف عنصر من أول الطابور.
    
4. **deleteLast (popBack):** حذف عنصر من آخر الطابور.
    

إضافة لعمليات الـ `getFront` و `getLast` و `isEmpty`.

**التحدي الهندسي (The Choice):**

- لو نفذناه بـ **Array**: هنواجه نفس مشكلة الـ Circular Queue بس من الناحيتين، وهنحتاج معادلات Modulo معقدة شوية.
    
- لو نفذناه بـ **Singly Linked List**: الإضافة والحذف في الأول سهلة $O(1)$، والإضافة في الآخر سهلة $O(1)$ (لو معانا Tail)، بس **المصيبة** في الحذف من الآخر (popBack)؛ لأننا عشان نمسح آخر واحد لازم نوصل للي قبله، وده بياخد $O(n)$.
    
- **الحل الأمثل:** هو الـ **Doubly Linked List**. وجود الـ `prev` pointer بيخلينا نقدر نرجع من الـ `Tail` للـ Node اللي قبلها في خطوة واحدة، فبتبقى كل العمليات **$O(1)$**.
    

---

### 4. المستوى العميق: "ليه الـ Doubly Linked List هي الملكة هنا؟"

في الـ Deque، إحنا محتاجين "تناظر" (Symmetry) كامل.

- عشان تعمل `popBack` في وقت ثابت، لازم الـ `Tail` يكون عارف مين جاره اللي على شماله عشان يخليه هو الـ `Tail` الجديد.
    
- الـ Doubly Linked List بتوفر ده بمنتهى الكفاءة.
    
- الـ **Spatial Locality vs Flexibility:** الـ Deque في C++ (std::deque) مش بيتنفذ بـ Linked list عادية، بيتنفذ بـ "مصفوفة من المصفوفات" (Map of blocks) عشان يجمع بين سرعة الـ Array ومرونة الـ Linked list، بس في دراستنا الأكاديمية، الـ Doubly Linked List هي الشرح الأبسط والأقوى لمفهوم الـ Deque.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود دسم بيطبق الـ Deque باستخدام الـ **Doubly Linked List**، مع الكومنتات بالإنجليزية كما طلبت.

C++

```
#include <iostream>

using namespace std;

// Node structure for Doubly Linked List
struct Node {
    int data;
    Node *next, *prev;

    Node(int val) {
        data = val;
        next = prev = nullptr;
    }
};

// Deque Implementation using Doubly Linked List
class Deque {
private:
    Node *front, *rear;

public:
    Deque() {
        front = rear = nullptr;
    }

    // Add element at the beginning: O(1)
    void insertFront(int val) {
        Node* newNode = new Node(val);
        if (front == nullptr) {
            front = rear = newNode;
        } else {
            newNode->next = front;
            front->prev = newNode;
            front = newNode;
        }
        cout << val << " inserted at Front" << endl;
    }

    // Add element at the end: O(1)
    void insertLast(int val) {
        Node* newNode = new Node(val);
        if (rear == nullptr) {
            front = rear = newNode;
        } else {
            newNode->prev = rear;
            rear->next = newNode;
            rear = newNode;
        }
        cout << val << " inserted at Last" << endl;
    }

    // Remove from the front: O(1)
    void deleteFront() {
        if (isEmpty()) {
            cout << "Deque Underflow!" << endl;
            return;
        }
        Node* temp = front;
        front = front->next;

        if (front == nullptr) rear = nullptr;
        else front->prev = nullptr;

        cout << temp->data << " removed from Front" << endl;
        delete temp;
    }

    // Remove from the last: O(1) - This is why we use DLL!
    void deleteLast() {
        if (isEmpty()) {
            cout << "Deque Underflow!" << endl;
            return;
        }
        Node* temp = rear;
        rear = rear->prev;

        if (rear == nullptr) front = nullptr;
        else rear->next = nullptr;

        cout << temp->data << " removed from Last" << endl;
        delete temp;
    }

    int getFront() { return (isEmpty()) ? -1 : front->data; }
    int getLast() { return (isEmpty()) ? -1 : rear->data; }
    bool isEmpty() { return front == nullptr; }

    ~Deque() {
        while (!isEmpty()) deleteFront();
    }
};

int main() {
    Deque dq;

    dq.insertLast(10);   // Deque: 10
    dq.insertLast(20);   // Deque: 10, 20
    dq.insertFront(5);   // Deque: 5, 10, 20
    dq.insertFront(2);   // Deque: 2, 5, 10, 20

    cout << "Front: " << dq.getFront() << ", Last: " << dq.getLast() << endl;

    dq.deleteFront();    // Removes 2
    dq.deleteLast();     // Removes 20

    cout << "After deletions - Front: " << dq.getFront() << ", Last: " << dq.getLast() << endl;

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Single Node Deletion:** لما يكون فيه عنصر واحد وتمسحه (سواء من قدام أو ورا)، لازم تصفر الـ `front` والـ `rear` مع بعض، وإلا واحد فيهم هيفضل بيشاور على ميموري اتمسحت.
    
2. **Memory Management:** لاحظ الـ `delete temp`. في الـ Deque إنت شغال بـ Pointers كتير، فأي غلطة في المسح هتسبب Memory Leak أسرع من الـ Stack.
    
3. **The `prev` linkage:** أهم خطوة في الـ `insertFront` هي إنك تربط الـ `front->prev` بالـ Node الجديدة، دي اللي المبرمجين دايماً بيفتكروها في الـ `next` وينسوها في الـ `prev`.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Deque مرتبط بـ:

- **A-Steal Algorithm (Job Stealing):** في الـ Operating Systems الحديثة (زي اللي بتشغل Java أو Go)، المعالجات بتوزع المهام على بعضها. لو معالج خلص شغله، بيروح يسرق (Steal) مهام من معالج تاني. بيسرقها من الـ "آخِر" بتاع الـ Deque بتاع المعالج التاني عشان ميحصلش تصادم (Conflict).
    
- **Undo/Redo History:** المتصفحات المتقدمة بتستخدم Deque عشان تدير سجل الصفحات؛ تمسح القديم من ورا وتضيف الجديد من قدام، مع إمكانية التنقل في الاتجاهين.
    
- **Sliding Window Problems:** في الـ Algorithms المعقدة، بنستخدم Deque عشان نحفظ الـ Max أو الـ Min في "نافذة متحركة" فوق Array.
    

### المصادر والقراءة الإضافية

- **Donald Knuth - TAOCP Vol 1:** المرجع الأصلي للـ Deque.
    
- **C++ STL Documentation:** اقرأ عن `std::deque` وشوف إزاي بتنفذ الـ "Random Access Iterator" مع إنها مش Array واحدة.
    
- **LeetCode:** ابحث عن مسألة "Sliding Window Maximum" عشان تشوف قوة الـ Deque الحقيقية.
    

---

