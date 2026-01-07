يا أهلاً بك يا باشمهندس في **المحطة الثانية** من رحلتنا الممتعة. إحنا خلصنا الأساسيات (Arrays & Linked Lists)، ودلوقتي جه الوقت نبني أول "هيكل وظيفي" حقيقي. النهاردة هنتكلم عن الـ **Stack** (المكدس).

ده الهيكل اللي بسببه إنت قادر تعمل `Ctrl+Z` وإنت بتكتب كود، وهو اللي بيخلي الـ Browser يرجع لورا لما تدوس `Back`. من غير الـ Stack، علوم الحاسب كانت هتقف عاجزة أمام أبسط العمليات.

اربط الحزام، وتعال نغوص في أعماق "الكومة" ونعرف حكايتها من أيام الحرب الباردة.

---

## المحطة الثانية: المكدس - The Stack

### التعريف السريع

الـ **Stack** هو هيكل بيانات خطي (Linear Data Structure) بيتبع قاعدة صارمة جداً اسمها **LIFO** وهي اختصار لـ (**Last-In, First-Out**). بالبلدي كده: "اللي يدخل الآخر، يخرج الأول". هو عبارة عن مجموعة عناصر مرصوصة فوق بعضها، مسموح لك تتعامل بس مع العنصر اللي على الوش (**Top**).

---

### الشرح التفصيلي

#### 1. القصة والتاريخ: من "قبو" الألمان إلى ذاكرة الحواسيب

حكاية الـ Stack ممتعة جداً. في منتصف الخمسينيات (حوالي 1955)، عالمين ألمان اسمهم **Friedrich L. Bauer** و **Klaus Samelson** كانوا بيفكروا في طريقة تخلي الكمبيوتر يقدر يترجم المعادلات الرياضية المعقدة (زي $5 + (3 \times 2)$).

المشكلة كانت: الكمبيوتر بيقرأ من الشمال لليمين، بس في الرياضيات الضرب قبل الجمع. إزاي الكمبيوتر "يخزن" الـ 5 والـ + لحد ما يخلص العملية اللي جوه القوس؟

ابتكروا فكرة سموها وقتها "The Cellar" (القبو). قالوا إحنا هنرمي الأرقام فوق بعضها في قبو، وأول رقم هنحتاجه هو آخر رقم رميناه. بفضل الاختراع ده، العالم الأسطوري Edsger W. Dijkstra قدر يطور أول مترجم (Compiler) للغة ALGOL سنة 1960 باستخدام الـ Stack.

#### 2. المستوى السطحي: "إيه ده؟" (The Physical Analogy)

تخيل "منظم الأطباق" في بوفيه الفندق، أو "علبة المناديل"، أو حتى "خزنة المسدس".

في علبة المناديل: المنديل اللي على الوش هو آخر واحد المصنع حطه، وهو أول واحد إنت بتسحبه. مستحيل تسحب المنديل اللي تحت خالص من غير ما تشيل كل اللي فوقه. ده بالظبط الـ Stack.

#### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Core Operations)

الـ Stack بيعتمد على 4 عمليات أساسية ملهومش خامس:

- **Push:** إضافة عنصر جديد فوق الـ Stack.
    
- **Pop:** حذف (سحب) العنصر اللي على الوش.
    
- **Peek (or Top):** "بصة" سريعة على العنصر اللي فوق من غير ما تمسحه.
    
- **IsEmpty:** تشيك بسيط هل الـ Stack فاضي ولا لسه فيه داتا.
    

في الميموري، الـ Stack ممكن يتنفذ بطريقتين:

1. **Array-based Stack:** سريع جداً وموفر في الميموري، بس حجمه ثابت (Static).
    
2. **Linked List-based Stack:** حجمه "مطاط" (Dynamic)، بس بيستهلك ميموري أكتر بسبب الـ Pointers.
    

#### 4. المستوى العميق: "ليه اتصمم كده؟ والـ Trade-offs"

- **التحكم والقيود (Controlled Access):** الـ Stack بيمنعك إنك "تلعب" في نص الداتا. وده ميزة مش عيب! لأنه بيضمن إن الداتا بتخرج بالترتيب العكسي لترتيب دخولها. ده أساسي في الـ **Function Call Stack** في الـ OS. لما Function بتنادي Function تانية، الـ OS بيعمل "Push" لمكان السطر الحالي في الـ Stack عشان لما الـ Function التانية تخلص، يعمل "Pop" ويعرف هو كان واقف فين ويرجع يكمل.
    
- **الـ Performance:** كل عمليات الـ Stack (Push, Pop, Peek) بتتم في وقت ثابت **$O(1)$**. مفيش لَف ولا دوران ولا تدوير. إنت دايماً بتتعامل مع الـ `Top`.
    
- **المخاطر (Memory Issues):**
    
    - **Stack Overflow:** لو فضلت تعمل Push في Stack حجمه محدود لحد ما الميموري تخلص. (ده السبب في اسم الموقع الشهير!).
        
    - **Stack Underflow:** لو حاولت تعمل Pop من Stack وهو أصلاً فاضي.
        

---

### كيفية العمل (How It Works) - سيناريو الـ Array Implementation

1. بنعرف Array وحجمه $N$.
    
2. بنعرف متغير اسمه `top` وقيمته المبدئية `-1` (يعني الـ Stack فاضي).
    
3. في الـ **Push**: بنزود الـ `top` بواحد ونحط الداتا في `arr[top]`.
    
4. في الـ **Pop**: بناخد الداتا من `arr[top]` وننقص الـ `top` بواحد.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود احترافي لـ Stack باستخدام الـ Array، مع الكومنتات بالإنجليزية.

C++

```
#include <iostream>

using namespace std;

#define MAX_SIZE 100 // Maximum capacity of the stack

class Stack {
private:
    int top;            // Index of the top element
    int arr[MAX_SIZE];  // Static array to store elements

public:
    Stack() {
        top = -1; // Initialize stack as empty
    }

    // Push an element onto the stack: O(1)
    bool push(int x) {
        if (top >= (MAX_SIZE - 1)) {
            cout << "Stack Overflow! Cannot push " << x << endl;
            return false;
        }
        arr[++top] = x;
        cout << x << " pushed into stack\n";
        return true;
    }

    // Pop the top element: O(1)
    int pop() {
        if (top < 0) {
            cout << "Stack Underflow! No elements to pop\n";
            return 0;
        }
        int x = arr[top--];
        return x;
    }

    // Peek the top element without removing it: O(1)
    int peek() {
        if (top < 0) {
            cout << "Stack is Empty\n";
            return 0;
        }
        return arr[top];
    }

    // Check if the stack is empty
    bool isEmpty() {
        return (top < 0);
    }
};

int main() {
    Stack myStack;

    myStack.push(10);
    myStack.push(20);
    myStack.push(30);

    cout << myStack.pop() << " popped from stack\n";
    
    cout << "Top element is: " << myStack.peek() << endl;

    cout << "Is stack empty? " << (myStack.isEmpty() ? "Yes" : "No") << endl;

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Fixed vs Dynamic Capacity:** لو شغال بـ Array، لازم دايما تتشيك على الـ `top` قبل الـ Push عشان متخرجش بره حدود المصفوفة. لو عايز Stack مبيخلصش، استخدم الـ `std::vector` أو الـ `Linked List`.
    
2. **Recursion Depth:** كل مرة بتنادي Function ريكيرسيف (Recursive)، الـ OS بيحجز مكان في الـ System Stack. لو الـ Recursion ده ملوش نهاية، هيحصل الـ **Stack Overflow** الشهير والبرنامج هيقفل فوراً.
    
3. **Reverse Polish Notation (RPN):** الـ Stack هو اللي بيحل المعادلات الرياضية في الآلات الحاسبة المتطورة. هو بيحول $3 + 4$ لـ $3\ 4\ +$ وبيتعامل معاها بالـ Push والـ Pop.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Stack مرتبط بـ:

- **Undo/Redo:** كل حركة بتعملها بتتعمل لها "Push". لما تدوس Undo بنعمل "Pop".
    
- **Browser History:** كل صفحة بتزورها بتدخل Stack. لما تدوس Back، بنعمل Pop لأحدث صفحة.
    
- **DFS (Depth-First Search):** الخوارزمية دي في الـ Graphs بتعتمد كلياً على الـ Stack عشان "تغوص" في الأعماق وترجع تاني.
    
- **Compiler Parsing:** التأكد إن الأقواس في الكود بتاعك مقفولة صح `(( ))`.
    

### المصادر والقراءة الإضافية

- **كتاب CLRS (Chapter 10):** بيشرح الـ Stack والـ Queue كـ Elementary Data Structures.
    
- **Introduction to Programming with C++ لـ Daniel Liang:** ممتاز في شرح الـ Function Call Stack.
    
- **GeeksForGeeks:** تمارين على استخدام الـ Stack في حل مشاكل معقدة زي "The Stock Span Problem".
    

---

يا أهلاً بك يا دكتور في أمتع جزء في رحلتنا! أنت دلوقتي سألت "سؤال المليون دولار" في علوم الحاسب. ليه بنسمي الـ Stack وغيره **Abstract Data Type (ADT)**؟ وليه نطبقه بالـ Linked List تحديداً؟

اقعد بقى واستعد لجرعة مركزة من "الرغي العلمي" المتين اللي هيخليك تشوف الكود ده وكأنه لوحة فنية مرسومة بعناية.

---

## المحطة الثانية (ب): الـ Stack كـ ADT وتطبيقه بالـ Linked List

### 1. لغز الـ Abstract Data Type (ADT): ليه بنسميه كدة؟

بص يا سيدي، كلمة **Abstract** (تجريدي) في البرمجة مش معناها "خيال"؛ معناها **"فصل الـ (ماذا) عن الـ (كيف)"**.

- **المستوى السطحي (What it is):** الـ ADT هو "كتالوج" أو "عقد" (Contract) بيقولك إيه العمليات المتاحة على الداتا دي (زي Push و Pop)، بس ملوش دعوة إنت هتنفذها إزاي تحت الكبوت.
    
- **المستوى المتوسط (Logic vs Implementation):** تخيل "ماكينة القهوة". الـ ADT هو الزراير اللي بره (Espresso, Latte). إنت عارف إنك لما تدوس Espresso هينزل قهوة. هل يهمك المواسير اللي جوه بلاستيك ولا نحاس؟ هل يهمك الموتور شغال بالكهرباء ولا بالبطارية؟ لأ. المهم إن "الفعل" حصل.
    
- **المستوى العميق (The Engineering Why):** إحنا بنستخدم الـ ADT عشان الـ **Encapsulation** والـ **Flexibility**. أنا ممكن النهاردة أعمل الـ Stack بـ Array، وبكرة أغيره لـ Linked List. المبرمج اللي بيستخدم الكلاس بتاعي مش هيغير سطر واحد في كوده، لأن "الزراير" (الـ Interface) هي هي، أنا بس غيرت "المواسير" (الـ Implementation).
    

---

### 2. التطبيق العملي: الـ Stack باستخدام الـ Linked List

ليه بنحب نطبق الـ Stack بالـ Linked List؟

في الـ Array، كنا دايماً بنخاف من الـ Stack Overflow لأن الحجم ثابت. لكن مع الـ Linked List، الـ Stack بتاعك "مفتوح"؛ طول ما الـ RAM فيها نفس، الـ Stack هيكبر معاك.

#### القصة التاريخية: الـ Dynamic Stacks في الـ LISP

في أواخر الخمسينيات، لما مبرمجين لغة **LISP** كانوا بيبنوا أنظمة ذكاء اصطناعي، لقوا إنهم مش عارفين يتوقعوا الـ Stack محتاج يشيل كام عنصر. فبدل ما يحجزوا مساحة ضخمة من الميموري ويضيعوها، استخدموا الـ Linked Lists. ده خلاهم يقدروا يبنوا برامج ريكيرسيف (Recursive) معقدة جداً من غير ما البرنامج يضرب "Overflow" فجأة.

#### الميكانيكية (How it works):

في الـ Stack، إنت محتاج تتعامل مع الـ **Top** بس.

- في الـ Linked List، أنسب مكان للـ Top هو الـ **Head**.
    
- الـ **Push** هتبقى عبارة عن `insertAtFront`.
    
- الـ **Pop** هتبقى عبارة عن `deleteFromFront`.
    
- كده العمليتين هيفضلوا دايماً **$O(1)$**.
    

---

### 3. الأمثلة العملية (The C++ Masterclass)

ده كود بيطبق الـ Stack ADT باستخدام الـ Linked List، مع مراعاة كل تفاصيل الـ Memory Management والكومنتات بالإنجليزية.

C++

```
#include <iostream>

using namespace std;

// The building block of our Stack
struct Node {
    int data;
    Node* next;

    Node(int val) {
        data = val;
        next = nullptr;
    }
};

// Stack Implementation using Linked List (Stack ADT)
class Stack {
private:
    Node* top; // This acts as the 'Head' of the Linked List

public:
    Stack() {
        top = nullptr; // Initially, the stack is empty
    }

    // Push: Add a new element at the TOP (Head of the list)
    // Time Complexity: O(1)
    void push(int val) {
        Node* newNode = new Node(val); // Create new node in the Heap
        newNode->next = top;           // Link new node to the previous top
        top = newNode;                 // Update top pointer to the new node
        cout << val << " pushed to stack" << endl;
    }

    // Pop: Remove the top element (Head of the list)
    // Time Complexity: O(1)
    int pop() {
        if (isEmpty()) {
            cout << "Stack Underflow! Nothing to pop." << endl;
            return -1;
        }

        Node* temp = top;        // Keep a temporary pointer to the current top
        int poppedValue = temp->data;
        top = top->next;         // Move top to the next node
        delete temp;             // Free the memory of the old top (Crucial step!)
        
        return poppedValue;
    }

    // Peek: Just look at the top element
    // Time Complexity: O(1)
    int peek() {
        if (!isEmpty()) {
            return top->data;
        }
        cout << "Stack is empty!" << endl;
        return -1;
    }

    // Check if empty
    bool isEmpty() {
        return top == nullptr;
    }

    // Destructor to clean up all nodes and prevent memory leaks
    ~Stack() {
        while (!isEmpty()) {
            pop();
        }
        cout << "Stack destroyed and memory cleared." << endl;
    }
};

int main() {
    Stack s;

    // Practical usage
    s.push(10);
    s.push(20);
    s.push(30);

    cout << "Top element is: " << s.peek() << endl; // Should be 30

    cout << s.pop() << " removed from stack" << endl; // Removes 30
    cout << s.pop() << " removed from stack" << endl; // Removes 20

    if (s.isEmpty()) {
        cout << "Stack is empty now." << endl;
    } else {
        cout << "Stack still has: " << s.peek() << endl; // Should be 10
    }

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Memory Management (The Silence Killer):** في الـ Array Stack، مكنتش بتشيل هم الـ `delete`. هنا، في كل `pop` لو نسيت تعمل `delete temp` إنت حرفياً بتعمل **Memory Leak**. الداتا بتتمسح من الـ Stack بس بتفضل محجوزة في الـ RAM للأبد.
    
2. **Pointer Manipulation:** لاحظ إننا بنعمل الـ Push والـ Pop عند الـ **Head**. لو فكرت تعملهم عند الـ Tail، الـ Pop هتبقى تكلفتها $O(N)$ لأنك لازم تلف السلسلة كلها عشان توصل للـ Node اللي قبل الـ Tail. عشان كدة "التصميم" الذكي بيخلي الـ Top هو الـ Head.
    
3. **Null Pointer Access:** دايماً في الـ `peek()` والـ `pop()` لازم تتشيك `isEmpty()`. لو حاولت تعمل `top->data` والـ `top` بـ `nullptr` السيستم هيديك **Segmentation Fault** فوراً.
    

---

### الربط بالمفاهيم التانية

- **Compiler Design:** الـ ADT ده هو اللي بيستخدمه الـ Compiler عشان يتأكد إن الأقواس في كودك `[ { ( ) } ]` مقفولة صح. بـ "Push" القوس المفتوح وبـ "Pop" لما يلاقي قوس مقفول من نفس النوع.
    
- **Operating Systems:** الـ **Kernel Stack** لكل Process هو تطبيق حي للـ Linked List Stack.
    
- **Backtracking Algorithms:** زي حل المتاهات (Maze solving) أو الـ N-Queens problem، الـ Stack بيحفظ الطريق اللي مشيناه عشان نعرف نرجع (Backtrack) لو خبطنا في حيطة سد.
    

### المصادر والقراءة الإضافية

- **كتاب "Data Structures and Algorithm Analysis" لـ Mark Allen Weiss:** الفصل الثالث (ADTs).
    
- **Documentation:** الـ `std::stack` في C++ هي "Container Adapter" (يعني ADT)، وتقدر تخليها تستخدم `std::list` (Linked list) أو `std::vector` تحتها.
    
- **YouTube:** دور على "Pointer implementation of Stack" في قناة **Abdul Bari**.
    

---

