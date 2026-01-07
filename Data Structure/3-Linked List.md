
## المحطة الثانية: القوائم المترابطة - Linked Lists

### التعريف السريع

الـ **Linked List** هي هيكل بيانات خطي (Linear)، لكن العناصر بتاعته مش متخزنة ورا بعضها في الميموري. كل عنصر بنسميه **Node** (عقدة)، وكل Node بتتكون من جزئين: الـ **Data** (المعلومة) والـ **Pointer** (العنوان) اللي بيشاور على الـ Node اللي بعدها.

---

### الشرح التفصيلي

#### 1. القصة التاريخية: الثورة على جمود الـ IBM 704

في منتصف الخمسينيات (حوالي 1955-1956)، علماء زي **Allen Newell** و **Herbert Simon** كانوا شغالين على لغة برمجة اسمها **IPL** (Information Processing Language). كانوا بيحاولوا يعملوا برامج ذكاء اصطناعي أولية، واكتشفوا إن الـ Arrays "غبية" جداً في التعامل مع البيانات اللي حجمها بيتغير بسرعة أو اللي محتاجة إعادة ترتيب.

تخيل لو عندك Array فيه مليون اسم، وعايز تحشر اسم جديد في النص. الـ Array هيجبرك "تزق" نصف مليون اسم عشان توفر مكان. قالوا: "ليه ما نخليش كل معلومة تترمي في أي مكان فاضي في الميموري، ونحط معاها ورقة صغيرة مكتوب فيها عنوان المعلومة اللي بعدها؟". وبكده ولدت الـ **Linked List**.

#### 2. المستوى السطحي: "إيه ده؟" (The Concept)

تخيل "لعبة البحث عن الكنز". أنا بديك ورقة مكتوب فيها "روح للمطبخ". لما تروح المطبخ تلاقي ورقة تانية مكتوب فيها "روح للبلكونة". في البلكونة تلاقي الكنز.

المطبخ والبلكونة هم الـ Nodes، والورق اللي معاك هو الـ Pointers. طول ما إنت معاك عنوان أول مكان (Head)، تقدر توصل لكل السلسلة.

#### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Node Anatomy)

الـ Node في C++ بنمثلها بـ struct أو class. هي كائن بيشيل قيمته وعنوان زميله.

في الـ RAM، الـ Nodes بتكون مبعثرة في منطقة الـ Heap. الكمبيوتر مبيحجزش Block واحد كبير زي الـ Array، هو بيحجز "فتافيت" كل ما نطلب منه نزيد Node جديدة.

**أنواع الـ Linked Lists:**

- **Singly Linked List:** كل Node بتشاور على اللي بعدها بس. (طريق اتجاه واحد).
    
- **Doubly Linked List:** كل Node بتشاور على اللي بعدها واللي قبلها. (طريق اتجاهين).
    
- **Circular Linked List:** آخر Node بتشاور على أول واحدة. (سلسلة مقفولة).
    

#### 4. المستوى العميق: "ليه اتصمم كده؟" (The Trade-offs)

ليه ممكن نضحي بالـ Array ونستخدم Linked List؟

- **الإضافة والحذف (O(1)):** لو إنت معاك عنوان الـ Node، تقدر تضيف بعدها أو تمسحها في خطوة واحدة بمجرد تغيير الـ Pointers. مش محتاج "تزق" (Shift) أي داتا.
    
- **الديناميكية:** الـ Linked List "مطاطة". بتكبر وبتقصر طول ما فيه مساحة في الـ Heap. مفيش حاجة اسمها "الـ List اتملت" طالما الميموري فيها مكان.
    

**لكن، فيه ضريبة (The Price):**

- **No Random Access (O(n)):** لو عايز العنصر رقم 100، لازم تمر على 1 و 2 و 3... لحد ما توصل لـ 100. الـ CPU ميقدرش يحسب العنوان بعملية حسابية زي الـ Array.
    
- **Memory Overhead:** كل Node بتخزن Pointer زيادة. لو الـ Data حجمها صغير، إنت بتضيع نص الميموري في العناوين.
    
- **Cache Unfriendliness:** لأن الـ Nodes بعيدة عن بعض في الميموري، الـ CPU Cache بيعاني (Cache Misses) لأن الداتا مش Contiguous.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود بيشرح إزاي تبني Singly Linked List من الصفر، مع الكومنتات بالإنجليزية كما طلبت.

C++

```
#include <iostream>

using namespace std;

// Define the structure of a Node
struct Node {
    int data;       // The actual information
    Node* next;     // Pointer to the next node in memory

    // Constructor to initialize the node easily
    Node(int val) {
        data = val;
        next = nullptr; // Initially, it points to nothing
    }
};

class LinkedList {
private:
    Node* head; // The starting point of the list

public:
    LinkedList() {
        head = nullptr; // Start with an empty list
    }

    // Add a node at the beginning: O(1) complexity
    void insertAtFront(int val) {
        Node* newNode = new Node(val); // Create node in Heap
        newNode->next = head;          // Point new node to current head
        head = newNode;                // Move head to the new node
    }

    // Display the list by traversing node by node: O(n) complexity
    void display() {
        Node* temp = head; // Start from the head
        while (temp != nullptr) {
            cout << temp->data << " -> ";
            temp = temp->next; // Move to the next memory address
        }
        cout << "NULL" << endl;
    }

    // Destructor to clean up memory from the Heap
    ~LinkedList() {
        Node* current = head;
        while (current != nullptr) {
            Node* nextNode = current->next;
            delete current; // Free the memory
            current = nextNode;
        }
    }
};

int main() {
    LinkedList list;

    // Adding elements
    list.insertAtFront(30);
    list.insertAtFront(20);
    list.insertAtFront(10);

    // Expected Output: 10 -> 20 -> 30 -> NULL
    cout << "Linked List Content: " << endl;
    list.display();

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

- **The Empty List:** لازم تتأكد دايماً إن الـ `head` مش `nullptr` قبل ما تحاول توصل لـ `head->data` وإلا البرنامج هيعمل **Crash**.
    
- **Memory Leaks:** في C++، كل مرة بتستخدم `new` لازم يقابلها `delete`. لو مسحت Node ونسيت تمسحها من الميموري، الداتا هتفضل محجوزة والبرنامج "هيسرب" ميموري لحد ما الجهاز يهنج.
    
- **The Last Node:** دايماً آخر Node لازم الـ `next` بتاعها يكون `nullptr`. ده هو الـ "حائط الصد" اللي بيقول للـ Loop بتاعتك "وقفي هنا، السلسلة خلصت".
    

---

### الربط بالمفاهيم التانية

موضوع الـ Linked List مرتبط بـ:

- **Stacks & Queues:** ممكن يتنفذوا باستخدام الـ Linked List عشان يكونوا Dynamic.
    
- **Garbage Collection:** لغات زي Java بتستخدم الـ Pointers عشان تعرف أنهي Objects مفيش حد بيشاور عليها فتمسحها.
    
- **Operating Systems:** الـ "Free List" اللي الـ Kernel بيستخدمها عشان يعرف أماكن الميموري الفاضية هي عبارة عن Linked List.
    

### المصادر والقراءة الإضافية

- **كتاب "Algorithms in C++" لـ Robert Sedgewick:** الفصل الثالث بيشرح الـ Linked Lists والـ Memory Management بعمق مذهل.
    
- **GeeksForGeeks:** قسم الـ Linked List فيه شرح لكل الـ Edge cases والـ Problems المشهورة.
    
- **فن البرمجة (The Art of Computer Programming):** المجلد الأول لنكلوث (Donald Knuth) بيشرح الجانب الرياضي لربط البيانات.
    

---

