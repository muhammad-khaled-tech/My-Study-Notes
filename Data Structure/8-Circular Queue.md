يا أهلاً بك يا دكتور في واحدة من أذكى "الخدع" الهندسية في تاريخ الـ Computer Science. إحنا المرة اللي فاتت لمسنا الـ Linear Queue، بس النهاردة إحنا قدام الـ **Circular Queue** (الطابور الدائري).

لو كنت فاكر إن الـ Queue العادي في الـ Array كان "مثالي"، فخليني أصدمك وأقولك إن الـ Linear Queue اللي بيعتمد على Array ثابت هو "مُسرف" جداً للميموري. وعشان نحل الإسراف ده، كان لازم المهندسين يفكروا بره الصندوق.. أو بالأصح، يفكروا جوه "الدائرة".

اربط الحزام، وتعال نفهم ليه الـ **Modulo Operator (%)** هو بطل حكاية النهاردة.

---

## المحطة الثالثة (ب): الطابور الدائري - The Circular Queue

### 1. القصة والتاريخ: معضلة "الانجراف الخطي" (The Linear Drift Problem)

بص يا سيدي، في الستينيات، لما كانت الميموري أغلى من الذهب، المبرمجين واجهوا مشكلة غريبة مع الـ Queue لما نفذوه بـ Array.

تخيل عندك Array حجمه 5. ضفت 5 عناصر، الـ Rear وصل لآخر مكان (Index 4). عملت Dequeue لـ 3 عناصر، فالمكان 0 و 1 و 2 بقوا فاضيين، والـ Front دلوقتي واقف عند 3.

لو جيت تضيف عنصر جديد (Enqueue)، الـ Rear هيقولك: "أنا آسف، الـ Array مليان!". مع إن فيه 3 أماكن فاضية في الأول!

المبرمجين وقتها كان قدامهم حلين:

1. **الشفتينج (Shifting):** كل ما نمسح عنصر من الأول، نزق كل اللي وراه خطوة لقدام. بس ده كارثة لأن الـ Complexity بتاعته $O(n)$.
    
2. **اللف (Circular Logic):** وده كان الحل العبقري. ليه ما نخليش الـ `Rear` لما يوصل لآخر الـ Array، يبص على أول مكان؟ لو لقاه فاضي، "يلف" ويروح يقعد فيه. ومن هنا ظهر الـ **Circular Queue**.
    

---

### 2. المستوى السطحي: "إيه ده؟" (The Physical Concept)

تخيل "صينية دائرية" عليها أطباق. إنت بتبدأ تحط الأطباق ورا بعضها. لما الصينية تلف وترجع لنقطة البداية، لو لقيت مكان فاضي (لأن حد سحب طبق وأكل)، تقدر تحط طبق جديد في نفس المكان. مفيش "بداية" و"نهاية" ثابتة في المكان، البداية والنهاية بيتحركوا في دايرة.

---

### 3. المستوى المتوسط: "إزاي بيشتغل؟" (The Magic of Modulo)

الـ Circular Queue بيعتمد على معادلة رياضية بسيطة جداً بس مفعولها سحر، وهي الـ Modulo (%).

بدل ما بنقول:

rear = rear + 1;

بقينا بنقول:

rear = (rear + 1) % size;

ليه؟

لو الـ size بتاعنا 5، والـ rear واقف عند 4 (آخر مكان):

$(4 + 1) \% 5 = 5 \% 5 = 0$

أوبا! الـ rear نط ورجع للـ Index رقم 0 أوتوماتيك. دي هي "اللفّة" اللي عملت الثورة.

#### حالات الـ Queue الدائري:

- **Empty:** لما الـ `front == -1`.
    
- **Full:** لما الـ `(rear + 1) % size == front`. (يعني الـ `rear` بقى "على قفا" الـ `front` بالظبط وما يفصلهمش غير خطوة واحدة).
    

---

### 4. المستوى العميق: "التحديات الهندسية" (The Engineering Depth)

إيه اللي يخلي المهندس يختار Circular Queue عن الـ Linked List Queue؟

1. **الـ Spatial Locality:** زي ما شرحنا في الـ Array، الداتا هنا متخزنة ورا بعضها في الـ RAM. ده بيخلي الـ CPU Cache طلقة في التعامل معاها، عكس الـ Linked List اللي الـ Nodes بتاعتها مبعثرة.
    
2. **صفر Memory Allocation:** في الـ Linked List، إنت كل شوية بتعمل `new` و `delete` وده بيستهلك وقت من الـ OS. في الـ Circular Queue، إنت حجزت الـ Array مرة واحدة وبس، وبتعيد استخدامه للأبد.
    
3. **الثبات (Predictability):** في الأنظمة الحساسة (Real-time systems)، إنت محتاج تعرف إن الـ Queue مش هياخد أكتر من مساحة معينة عشان السيستم ميضربش. الـ Circular Queue بيضمن لك ده.
    

---

### الأمثلة العملية (C++ Implementation)

ده كود دسم لـ Circular Queue باستخدام Array، مع شرح كل سطر بالإنجليزية.

C++

```
#include <iostream>

using namespace std;

class CircularQueue {
private:
    int *arr;      // Pointer to dynamic array
    int front;     // Index of the front element
    int rear;      // Index of the last element
    int size;      // Maximum capacity

public:
    // Constructor to initialize the queue with a specific size
    CircularQueue(int s) {
        size = s;
        arr = new int[size];
        front = rear = -1; // Initially empty
    }

    // Enqueue: Add element in a circular manner
    void enqueue(int value) {
        // Condition for Full Queue
        if ((rear + 1) % size == front) {
            cout << "Queue is Full! Cannot enqueue " << value << endl;
            return;
        }

        // If it's the first element to be added
        if (front == -1) {
            front = 0;
        }

        // Circularly increment rear using Modulo
        rear = (rear + 1) % size;
        arr[rear] = value;
        cout << value << " added at index " << rear << endl;
    }

    // Dequeue: Remove element in a circular manner
    int dequeue() {
        if (front == -1) {
            cout << "Queue is Empty!" << endl;
            return -1;
        }

        int result = arr[front];

        // If the queue has only one element left
        if (front == rear) {
            front = rear = -1; // Reset to empty state
        } else {
            // Circularly increment front
            front = (front + 1) % size;
        }

        return result;
    }

    // Display the elements from front to rear
    void displayQueue() {
        if (front == -1) {
            cout << "Queue is empty!" << endl;
            return;
        }

        cout << "Queue elements: ";
        int i = front;
        while (true) {
            cout << arr[i] << " ";
            if (i == rear) break;
            i = (i + 1) % size; // Move circularly
        }
        cout << endl;
    }

    // Destructor to free Heap memory
    ~CircularQueue() {
        delete[] arr;
    }
};

int main() {
    CircularQueue cq(5);

    cq.enqueue(10);
    cq.enqueue(20);
    cq.enqueue(30);
    cq.enqueue(40);
    cq.enqueue(50); // Queue is now full

    cout << "Dequeued: " << cq.dequeue() << endl; // Removes 10, index 0 is now free
    cout << "Dequeued: " << cq.dequeue() << endl; // Removes 20, index 1 is now free

    cq.enqueue(60); // This will wrap around and take Index 0!
    cq.enqueue(70); // This will take Index 1!

    cq.displayQueue(); // Should show elements starting from index 2 to index 1

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **The Single Element Trap:** في الـ `dequeue` لو الـ `front == rear` ده معناه إننا بنمسح آخر عنصر. لازم نرجع الـ `front` والـ `rear` لـ `-1` عشان نصفر الـ Queue تماماً.
    
2. **The "Full" vs "Empty" Dilemma:** في بعض التصميمات، المهندسين بيسيبوا مكان واحد "فاضي" دايماً في الـ Array عشان يفرقوا بين الـ Full والـ Empty بشكل أسهل، بس الطريقة اللي استخدمناها فوق (باستخدام الـ -1) هي الأكثر توفيراً للمساحة.
    
3. **Buffer Overflow:** لو الـ `rear` لَف وخبط في الـ `front` وإنت معملتش تشيك، إنت هتمسح داتا قديمة لسه متقرتش، وده بنسميه **Data Corruption**.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Circular Queue مرتبط بـ:

- **Audio/Video Streaming:** الداتا اللي بتنزل من النت بتتحط في Circular Buffer (Queue). المشغل (Player) بياخد من الـ Front والنت بيحط في الـ Rear. لو النت سريع جداً، الـ Rear بيلف ويستنى الـ Player يخلص (Buffer Full).
    
- **Keyboard Buffer:** لما بتكتب بسرعة على الكيبورد، الحروف بتتحط في Circular Queue لحد ما الـ OS يقدر يعالجها.
    
- **Producer-Consumer Problem:** دي أشهر معضلة في الـ **Operating Systems** وبتتحل دائماً باستخدام الـ Circular Queue.
    

### المصادر والقراءة الإضافية

- **كتاب "Introduction to Algorithms" (CLRS):** الفصل العاشر، قسم الـ Queues.
    
- **Coursera - Algorithms Part I (Princeton):** شرح ممتاز للـ Circular Arrays.
    
- **YouTube:** دور على "Circular Queue Implementation" في قناة **MyCodeSchool**.
    
