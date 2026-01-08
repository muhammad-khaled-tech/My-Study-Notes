---
title: Queue
created: 2026-01-08
tags:
  - data-structures
  - queue
  - adt
  - fifo
related:
  - "[[_Data Structures MOC]]"
  - "[[6-Stack]]"
  - "[[8-Circular Queue]]"
complexity:
  enqueue: O(1)
  dequeue: O(1)
---

يا أهلاً بك يا باشمهندس في **المحطة الثالثة** من رحلتنا العميقة في عالم هياكل البيانات. بعد ما "كدّسنا" الداتا فوق بعضها في الـ Stack، جه الوقت ننظمها في "طابور" محترم. النهاردة هنتكلم عن الـ **Queue** (الطابور).

ده الهيكل اللي بسببه الإنترنت شغال، والبرينتر بتطبع ورقك بالترتيب، والـ Operating System قادر يشغل مية برنامج في نفس الوقت من غير ما الدنيا تضرب في بعضها. اركن القهوة بتاعتك على جنب، وركز معايا في "رغي" الأستاذ الجامعي اللي هيغوص بيك في أعماق الـ FIFO وحكاياته التاريخية.

---

## [[Data Structures]]/المحطة الثالثة: الطابور - The Queue

### التعريف السريع

الـ **Queue** هو هيكل بيانات خطي (Linear Data Structure) بيتبع قاعدة عادلة جداً ومنطقية اسمها **FIFO** وهي اختصار لـ (**First-In, First-Out**). بالبلدي كده: "اللي يجي الأول، يتخدم الأول ويخرج الأول". هو عبارة عن ممر له مدخل من ناحية (الـ **Rear**) ومخرج من الناحية تانية خالص (الـ **Front**).

---

### الشرح التفصيلي

#### 1. القصة والتاريخ: من "نظرية الطوابير" إلى ثورة الـ Multi-tasking

حكاية الـ Queue أقدم بكتير من أجهزة الكمبيوتر الشخصية. في أوائل القرن العشرين (حوالي 1909)، عالم رياضيات دانمركي اسمه **Agner Krarup Erlang** كان شغال في شركة اتصالات، وكان بيحاول يحل مشكلة: "كم عدد الخطوط اللي محتاجينها عشان الناس اللي بتتصل متستناش كتير؟". ومن هنا اخترع "Queueing Theory" (نظرية الطوابير).

لما دخلنا عصر الكمبيوتر في الخمسينيات والستينيات، المهندسين في شركات زي **IBM** واجهوا مشكلة ضخمة: الـ CPU سريع جداً، والـ Input devices (زي الكروت المثقبة وقتها) بطيئة جداً. لو الـ CPU استنى كل كارت يخلص، هنضيع وقت مرعب. فاقترحوا فكرة الـ **Buffer**: مكان نخزن فيه المهام ورا بعضها في "طابور"، والـ CPU يسحب منها بالترتيب أول ما يفضى. بفضل الـ Queue، قدرنا ننتقل من مرحلة "برنامج واحد في المرة" لمرحلة الـ **Batch Processing** وبعدها الـ **Multi-tasking**.

#### 2. المستوى السطحي: "إيه ده؟" (The Physical Analogy)

تخيل طابور العيش، أو طابور الكاشير في السوبر ماركت. أول واحد وقف في الطابور هو أول واحد هيتحاسب ويمشي. مستحيل الكاشير يسيب أول واحد ويروح يحاسب اللي واقف في الآخر (إلا لو فيه "واسطة" ودي هناخدها في الـ Priority Queue لاحقاً).

في الـ Queue، إنت بتدخل من باب (الـ Back/Rear) وتخرج من باب تاني (الـ Front).

#### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Core Operations)

الـ Queue كـ ADT بيعرف لنا عمليات أساسية لازم تتوفر فيه:

- **Enqueue:** إضافة عنصر جديد في آخر الطابور (**Rear**).
    
- **Dequeue:** حذف (سحب) العنصر اللي عليه الدور في أول الطابور (**Front**).
    
- **Front (or Peek):** بصة على أول واحد في الطابور من غير ما تمسحه.
    
- **IsEmpty / IsFull:** عشان نعرف حالة الطابور قبل ما نتصرف.
    

التحدي الأكبر في التنفيذ (The Implementation Challenge):

لو نفذنا الـ Queue باستخدام Array عادي، هيحصل عندنا مشكلة اسمها "Linear Drift". كل ما تعمل Dequeue، الـ Front بيتحرك لليمين، ويسيب وراه أماكن فاضية في الـ Array مستحيل نستخدمها تاني! عشان كدة المبرمجين اخترعوا الـ Circular Queue (الطابور الدائري) اللي بيستخدم عملية الـ Modulo % عشان يخلي الـ Rear يلف ويرجع للأول تاني لو فيه مكان.

أما لو نفذناه بـ **Linked List**، فالدنيا بتبقى أسهل بكتير لأننا بنتحرك بـ Pointers بحرية في الميموري، وده اللي هنركز عليه النهاردة.

#### 4. المستوى العميق: "ليه اتصمم كده؟" (The Engineering Logic)

الـ Queue هو الوسيط (Mediator) المثالي بين أي اتنين سرعتهم مختلفة. في عالم الـ Systems، بنسميه **Asynchronous Buffer**.

- **Decoupling:** الـ Queue بيفصل الـ Producer (اللي بيبعت الداتا) عن الـ Consumer (اللي بيعالج الداتا). لو السيرفر جاله 1000 طلب في ثانية، مش هيقدر يخلصهم كلهم فوراً، فيحطهم في Queue، ويعالجهم واحد واحد براحته من غير ما الـ Client يحس إن السيستم وقع.
    
- **Performance:** كل عمليات الـ Queue (Enqueue, Dequeue) في الـ Linked List بتتم في وقت ثابت **$O(1)$**. إحنا دايماً معانا Pointer للـ `Front` وآخر للـ `Rear` فمفيش أي لَف أو بحث.
    

---

### كيفية العمل (How It Works) - الـ Linked List Implementation

عشان نبني Queue محترم بالـ Linked List، محتاجين نراقب طرفين السلسلة:

1. **Front Pointer:** بيشاور على أول Node (اللي هتخرج في الـ Dequeue).
    
2. **Rear Pointer:** بيشاور على آخر Node (اللي ضفناها لسه في الـ Enqueue).
    

في الـ Enqueue: بنعمل Node جديدة، نخلي الـ Rear->next يشاور عليها، وبعدين ننقل الـ Rear نفسه ليها.

في الـ Dequeue: بناخد الداتا من الـ Front ونحرك الـ Front للي بعده، ونمسح الـ Node القديمة من الميموري.

---

### الأمثلة العملية (C++ Implementation)

ده كود بيطبق الـ Queue ADT باستخدام الـ Linked List، مع مراعاة المعايير الهندسية والكومنتات بالإنجليزية.

C++

```
#include <iostream>

using namespace std;

// The building block of our Queue
struct Node {
    int data;
    Node* next;

    Node(int val) {
        data = val;
        next = nullptr;
    }
};

// Queue Implementation using Linked List (Queue ADT)
class Queue {
private:
    Node *front, *rear; // Pointers to keep track of both ends

public:
    Queue() {
        front = rear = nullptr; // Initialize empty queue
    }

    // Enqueue: Add an element to the back (Rear)
    // Time Complexity: O(1)
    void enqueue(int val) {
        Node* newNode = new Node(val);

        // If queue is empty, both front and rear will point to the new node
        if (rear == nullptr) {
            front = rear = newNode;
            cout << val << " enqueued to queue" << endl;
            return;
        }

        // Add the new node at the end of queue and update rear
        rear->next = newNode;
        rear = newNode;
        cout << val << " enqueued to queue" << endl;
    }

    // Dequeue: Remove an element from the front (Front)
    // Time Complexity: O(1)
    void dequeue() {
        // If queue is empty, return underflow
        if (isEmpty()) {
            cout << "Queue Underflow! Nothing to dequeue." << endl;
            return;
        }

        // Store previous front and move front one node ahead
        Node* temp = front;
        cout << front->data << " dequeued from queue" << endl;
        front = front->next;

        // If front becomes NULL, then change rear also to NULL
        if (front == nullptr) {
            rear = nullptr;
        }

        delete temp; // Free memory
    }

    // Peek: Get the front element
    int getFront() {
        if (!isEmpty()) return front->data;
        return -1;
    }

    // Check if the queue is empty
    bool isEmpty() {
        return front == nullptr;
    }

    // Destructor to clean up memory
    ~Queue() {
        while (!isEmpty()) {
            dequeue();
        }
    }
};

int main() {
    Queue q;

    q.enqueue(10);
    q.enqueue(20);
    q.enqueue(30);

    cout << "Front element: " << q.getFront() << endl; // Should be 10

    q.dequeue(); // Removes 10
    q.dequeue(); // Removes 20

    cout << "Front element now: " << q.getFront() << endl; // Should be 30

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Queue Underflow:** محاولة الـ Dequeue من طابور فاضي. لازم تتشيك دايماً لو الـ `front == nullptr`.
    
2. **The Single Element Case:** لما يكون عندك عنصر واحد بس وتعمل له Dequeue، الـ `front` هيبحث عن `next` فيلاقيه `nullptr`. لازم في الحالة دي تصفر الـ `rear` كمان يدوي عشان ميفضلش بيشاور على مكان اتمسح (Dangling Pointer).
    
3. **Memory Management:** زي الـ Stack، كل Node بتعمل لها `new` لازم يتعمل لها `delete` في الـ Dequeue أو الـ Destructor، وإلا الميموري هتفضل "محجوزة" للـ OS والبرنامج هيحصل له Memory Leak.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Queue مرتبط بـ:

- **OS Scheduling:** خوارزمية **Round-Robin** بتستخدم Circular Queue عشان توزع وقت الـ CPU على البرامج بالتساوي.
    
- **Networking:** الـ Router بيستخدم Queues عشان يدير الـ Packets اللي جاية له. لو الـ Queue اتملى، بيحصل حاجة اسمها **Packet Drop**.
    
- **Breadth-First Search (BFS):** الخوارزمية دي في الـ Graphs والـ Trees مستحيل تشتغل من غير Queue عشان تزور النودز مستوى بمستوى.
    
- **Printer Spooling:** لما كذا جهاز يبعتوا أمر طباعة، البرينتر بتحطهم في Queue وتطبع بالترتيب.
    

### المصادر والقراءة الإضافية

- **كتاب "Data Structures and Algorithm Analysis in C++" لـ Mark Allen Weiss:** الفصل الثالث (Queues).
    
- **كورس CS50:** شرح الـ Queue والـ Stack كـ Data Structures أساسية في الـ C.
    
- **نظرية الطوابير (Queueing Theory):** لو حابب تشوف الجانب الرياضي وازاي بيحسبوا وقت الانتظار المتوقع.
    

---
