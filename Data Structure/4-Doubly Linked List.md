أهلاً بك يا بطل في "الشارع اللي بيودي ويجيب". لو كانت الـ Singly Linked List عبارة عن طريق اتجاه واحد (One-way Street)، فأنت النهاردة قدام طريق "رايح جاي" أو الـ **Doubly Linked List (DLL)**. دي المرحلة اللي بنبدأ فيها ندي للبيانات "ذاكرة" للمكان اللي جت منه، مش بس المكان اللي رايحة له.

اربط الحزام، لأننا هنشوف إزاي مؤشر واحد زيادة (Extra Pointer) ممكن يغير قواعد اللعبة تماماً في الـ Performance، وفي نفس الوقت يصدعنا في الـ Memory Management.

---

## القوائم المترابطة مزدوجة الاتجاه - Doubly Linked Lists

### التعريف السريع

الـ **Doubly Linked List** هي نسخة متطورة من الـ Linked List، كل عقدة (Node) فيها بتحتوي على تلات حاجات: المعلومة نفسها (**Data**)، ومؤشر يشاور على اللي بعدها (**Next**)، ومؤشر جديد خالص بيشاور على اللي قبلها (**Previous**). ده بيسمح لنا نتمشى في السلسلة في الاتجاهين براحتنا.

---

### الشرح التفصيلي

بص يا سيدي، تعال نفهم "ليه" العلماء فكروا في الـ DLL وماكتفوش بالـ Singly (SLL).

#### 1. القصة والفلسفة: "الرجوع للماضي"

تخيل إنك فاتح Browser (زي Chrome أو Firefox) وبتقلب في المواقع. إنت دخلت على Google، وبعدين Wikipedia، وبعدين YouTube. لو المتصفح شغال بـ Singly Linked List، هتعرف تروح للي بعده (Forward)، لكن لو حبيت ترجع لورا (Back Button)، المتصفح "هيصدم" لأنه مش عارف إنت جيت منين! لازم يلف السلسلة من أولها عشان يوصل للموقع اللي قبل YouTube.

من هنا ظهرت الحاجة لـ "مؤشر الخلف" (Previous Pointer). في سنة 1950-1960، مع تطور نظم الملفات (File Systems) وقواعد البيانات، المهندسين لقوا إنهم محتاجين هيكل بيانات يسمح بالـ **Bidirectional Traversal**.

#### 2. المستوى السطحي: "إيه ده؟" (The Concept)

الـ DLL عاملة زي "قطار السكة الحديد". كل عربية مربوطة باللي قدامها وباللي وراها. لو إنت واقف في نص القطر، تقدر تمشي ناحية الجرار أو تمشي ناحية آخر عربية. ده بيدينا مرونة (Flexibility) جبارة.

#### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Mechanics)

في الـ DLL، الـ Node بقت "أتخن" شوية. في الـ RAM، بدل ما بنحجز مساحة لـ (Data + 1 Pointer)، بنحجز لـ (Data + 2 Pointers).

- **head:** بيشاور على أول Node (الـ `prev` بتاعها دايماً بـ `nullptr`).
    
- **tail (اختياري بس مهم):** مؤشر بيشاور على آخر Node (الـ `next` بتاعها دايماً بـ `nullptr`). وجود الـ `tail` بيخلينا نقدر نضيف في الآخر في $O(1)$.
    

#### 4. المستوى العميق: "ليه اتصمم كده؟ والـ Trade-offs" (The Professional Insights)

هنا بقى الحتة اللي بتفرق مهندس الـ ITI الشاطر. ليه الـ DLL أغلى بس أحسن؟

- سرعة الحذف (The Deletion Magic): في الـ Singly، لو قلت لك "امسح الـ Node اللي في إيدك دي"، مش هتعرف! لازم تروح تجيب اللي قبلها عشان تربطه باللي بعدها، وعشان تجيب اللي قبلها لازم تلف السلسلة من الأول ($O(n)$).
    
    في الـ Doubly، الـ Node اللي في إيدك "عارفة" مين اللي قبلها ومين اللي بعدها. فالحذف بيتم في $O(1)$ بمنتهى البساطة. إنت بس بتقول للي قبلك: "شاوري على اللي بعدي"، وبتقول للي بعدك: "شاور على اللي قبلي".
    
- **الـ Memory Penalty:** في أنظمة الـ 64-bit، الـ Pointer بياخد 8 Bytes. لو إنت بتخزن `int` (بياخد 4 Bytes)، فأنت حرفياً بتضيع 16 Bytes (للـ pointers) عشان تخزن 4 Bytes داتا! دي تكلفة عالية جداً في الميموري، وعشان كده بنستخدم الـ DLL بس لما نكون محتاجين الـ Forward/Backward بجد.
    
- **الـ Complexity في الـ Coding:** في الـ Singly، إنت بتلعب بـ Pointer واحد. في الـ Doubly، إنت بتعمل "رقصة" بـ 4 Pointers في كل عملية إضافة أو حذف. لو غلطت في سطر واحد، السلسلة هتتكسر وهتلاقي نفسك في "Memory Leak" أو "Dangling Pointers".
    

---

### كيفية العمل (How It Works) - سيناريو الإضافة

لما بنيجي نضيف Node في نص الـ Doubly Linked List، بنعمل 4 خطوات (The 4-Way Handshake):

1. الـ `next` بتاع الـ Node الجديدة يشاور على الـ Node اللي عليها الدور.
    
2. الـ `prev` بتاع الـ Node الجديدة يشاور على الـ Node اللي قبلها.
    
3. الـ `next` بتاع الـ Node اللي "قبلها" يتغير ويشاور على الـ Node الجديدة.
    
4. الـ `prev` بتاع الـ Node اللي "بعدها" يتغير ويشاور على الـ Node الجديدة.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود احترافي لـ Doubly Linked List، مع تركيز على الـ English comments والـ Memory Clean-up.

C++

```
#include <iostream>

using namespace std;

// Node structure for Doubly Linked List
struct Node {
    int data;
    Node* next;
    Node* prev;

    Node(int val) {
        data = val;
        next = nullptr;
        prev = nullptr;
    }
};

class DoublyLinkedList {
private:
    Node* head;
    Node* tail; // Tail makes inserting at the end O(1)

public:
    DoublyLinkedList() {
        head = nullptr;
        tail = nullptr;
    }

    // Insert at the beginning: O(1)
    void insertFront(int val) {
        Node* newNode = new Node(val);
        if (head == nullptr) {
            head = tail = newNode;
            return;
        }
        newNode->next = head;
        head->prev = newNode;
        head = newNode;
    }

    // Insert at the end: O(1) thanks to the tail pointer
    void insertBack(int val) {
        Node* newNode = new Node(val);
        if (tail == nullptr) {
            head = tail = newNode;
            return;
        }
        newNode->prev = tail;
        tail->next = newNode;
        tail = newNode;
    }

    // Traversal from Front to Back
    void displayForward() {
        Node* temp = head;
        while (temp != nullptr) {
            cout << temp->data << " <-> ";
            temp = temp->next;
        }
        cout << "NULL" << endl;
    }

    // Traversal from Back to Front (The unique DLL feature)
    void displayBackward() {
        Node* temp = tail;
        while (temp != nullptr) {
            cout << temp->data << " <-> ";
            temp = temp->prev;
        }
        cout << "NULL" << endl;
    }

    // Destructor to prevent memory leaks
    ~DoublyLinkedList() {
        Node* current = head;
        while (current != nullptr) {
            Node* nextNode = current->next;
            delete current;
            current = nextNode;
        }
    }
};

int main() {
    DoublyLinkedList dll;

    dll.insertBack(10);
    dll.insertBack(20);
    dll.insertFront(5); // List: 5 <-> 10 <-> 20

    cout << "Forward Display:" << endl;
    dll.displayForward();

    cout << "Backward Display:" << endl;
    dll.displayBackward();

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Empty List:** لما الـ List تكون فاضية، الـ `head` والـ `tail` لازم يبقوا `nullptr`. أول Node تدخل هي اللي بتمثل الـ Head والـ Tail في نفس الوقت.
    
2. **Deleting the Head:** لو مسحت أول عنصر، لازم تخلي الـ `prev` بتاع الـ Head الجديد بـ `nullptr` فوراً، وإلا السيستم هيحاول يرجع لمكان ملوش وجود (Invalid memory access).
    
3. **The "Middle" Insertion:** لما تضيف في النص، لازم تتأكد إنك ربطت الـ 4 وصلات صح. لو نسيت واحدة، السلسلة هتبقى "مقطوعة" من ناحية وشغالة من ناحية تانية، ودي أصعب Bug ممكن تكتشفه.
    

---

### الربط بالمفاهيم التانية

موضوع الـ DLL مرتبط بـ:

- **LRU Cache (Least Recently Used):** دي أشهر خوارزمية في الـ Operating Systems لإدارة الميموري. بتستخدم **Hash Map** مع **Doubly Linked List** عشان تعرف مين أكتر داتا استخدمناها ومين "مركونة" فنمصحها.
    
- **Undo/Redo Logic:** في برامج الـ Text Editors زي VS Code، الـ DLL بتشيل الـ states بتاعة الكود عشان تقدر ترجع لورا وتطلع لقدام.
    
- **Music Players:** الـ Playlist اللي بتقدر تدوس فيها `Next` و `Previous`.
    

### المصادر والقراءة الإضافية

- **كتاب CLRS (Chapter 10):** بيشرح الـ DLL والـ Circular DLL بالتحليل الرياضي.
    
- **Robert Sedgewick - Algorithms:** بيوضح إزاي الـ DLL بتحسن أداء الـ Queues.
    
- **Standard Template Library (STL):** في C++، الـ `std::list` هي حرفياً Doubly Linked List. ممكن تقرأ الـ documentation بتاعها عشان تشوف الـ methods المعقدة اللي فيها.
    
