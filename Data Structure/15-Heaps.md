---
title: Heaps
created: 2026-01-08
tags:
  - data-structures
  - trees
  - heap
  - priority-queue
  - O(logn)
related:
  - "[[_Data Structures MOC]]"
  - "[[11-Binary Tree]]"
  - "[[7-Queue]]"
complexity:
  peek: O(1)
  insert: O(log n)
  delete: O(log n)
---

يا أهلاً بك يا دكتور في المحطة اللي بنسميها "محطة الأولوية". إحنا سيبنا الأشجار اللي هدفها البحث (Search Trees)، ودخلنا في نوع خاص جداً من الأشجار هدفه "الترتيب حسب الأهمية". النهاردة هنتكلم عن الـ **Heap**.

لو الـ Binary Search Tree كانت "مكتبة"، فالـ Heap هو "غرفة الطوارئ" (Emergency Room) في المستشفى؛ مش مهم نلاقي كل المرضى دلوقتي، المهم إن "أخطر حالة" تكون قدام الدكتور فوراً.

اربط الحزام، وتعال نفهم ليه الـ Heap هو الشجرة الوحيدة اللي "بتكره" الـ Pointers وبتحب تعيش جوه Array.

---

## الـ Heap: شجرة الأولوية والكفاءة القصوى

### 1. القصة والتاريخ: من "الفرز" إلى عالم الـ Heapsort

حكاية الـ Heap بدأت سنة 1964 على يد العالم **J. W. J. Williams**. ويليامز مكانش بيدور على هيكل بيانات للتخزين بس، كان بيحاول يخترع أسرع خوارزمية ترتيب في الوقت ده، وهي الـ **Heapsort**.

ويليامز لاحظ إننا في أنظمة التشغيل (OS) محتاجين دايماً نعرف "مين العملية اللي ليها أعلى أولوية؟". لو استخدمنا Array مترتب، الإضافة هتبقى بطيئة ($O(N)$). ولو استخدمنا Linked List، البحث هيبقى بطيء. ففكر في هيكل بيانات "شبه شجرة" بس نقدر نخزنه في مصفوفة عشان نستغل سرعة الـ CPU Cache القصوى. ومن هنا ظهر الـ **Binary Heap**.

---

### 2. المستوى السطحي: "إيه ده؟" (The Concept)

الـ **Heap** هو شجرة ثنائية كاملة (**Complete Binary Tree**) بتحقق شرط معين بنسميه الـ **Heap Property**. والشرط ده نوعين:

- **Max-Heap:** قيمة الأب دايماً **أكبر من أو تساوي** قيم ولاده. يعني "الرأس الكبيرة" دايماً فوق عند الـ Root.
    
- **Min-Heap:** قيمة الأب دايماً **أصغر من أو تساوي** قيم ولاده. يعني "أصغر قيمة" هي اللي عند الـ Root.
    

**ملاحظة هامة:** الـ Heap مش مترتبة من الشمال لليمين زي الـ BST. إحنا بس ضامنين إن الأب أكبر من ولاده، لكن الأخوات علاقتهم ببعض مش مهمة.

---

### 3. المستوى المتوسط: السحر الحقيقي (Array Representation)

هنا بقى العبقرية الهندسية. الـ Heap هي شجرة، بس إحنا **مش بنستخدم Nodes و Pointers**. ليه؟ لأنها دايماً "Complete Binary Tree"، يعني مفيش فيها فجوات. ده بيخلينا نقدر نخزنها جوه **Array** عادي جداً ونوصل لأي أب أو ابن بعملية حسابية بسيطة:

لو إنت واقف عند Index رقم `i`:

- **الأب (Parent):** مكانه عند `(i - 1) / 2`
    
- **الابن الشمال (Left Child):** مكانه عند `(2 * i) + 1`
    
- **الابن اليمين (Right Child):** مكانه عند `(2 * i) + 2`
    

---

### 4. المستوى العميق: حركات الإصلاح (Heapify Up & Down)

إزاي الـ Heap بيحافظ على كرامته وشروطه لما نضيف أو نمسح؟

#### أ) الإضافة (Insertion / Heapify Up):

1. بنرمي العنصر الجديد في "آخر مكان فاضي" في الـ Array (عشان نحافظ على إنها Complete).
    
2. العنصر الجديد يبص لفوق: "هل أنا أكبر من أبويا؟". لو أه، يبدّل معاه (**Swap**).
    
3. يفضل "يطلع لفوق" لحد ما يلاقي أب أكبر منه أو يوصل للـ Root.
    

Code snippet

```
graph TD
    subgraph "Heapify Up (Insert 50 in Max-Heap)"
    A((40)) --- B((30))
    A --- C((20))
    B --- D((10))
    B --- E((50 - New))
    E -.-> |Swap with 30| B
    end
```

#### ب) الحذف (Extract Max/Min / Heapify Down):

إحنا دايماً بنمسح الـ **Root** (لأنه هو ده اللي عليه الدور).

1. بناخد "آخر عنصر" في الـ Array ونحطه مكان الـ Root اللي اتمسح.
    
2. العنصر ده بيبقى غالباً صغير، فيبدأ "ينزل لتحت": يقارن نفسه بولاده، ويبدل مع "الكبير" فيهم.
    
3. يفضل ينزل لحد ما يستقر في مكانه الصح.
    

---

### 5. الأمثلة العملية (C++ Implementation)

ده كود دسم لـ **Max-Heap** باستخدام الـ `vector` في C++، مع شرح كل خطوة هندسية.

C++

```
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class MaxHeap {
private:
    vector<int> heap;

    // Helper to get indices
    int parent(int i) { return (i - 1) / 2; }
    int leftChild(int i) { return (2 * i) + 1; }
    int rightChild(int i) { return (2 * i) + 2; }

    // Restore heap property from bottom to top
    void heapifyUp(int i) {
        while (i != 0 && heap[parent(i)] < heap[i]) {
            swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    // Restore heap property from top to bottom
    void heapifyDown(int i) {
        int largest = i;
        int left = leftChild(i);
        int right = rightChild(i);

        if (left < heap.size() && heap[left] > heap[largest])
            largest = left;

        if (right < heap.size() && heap[right] > heap[largest])
            largest = right;

        if (largest != i) {
            swap(heap[i], heap[largest]);
            heapifyDown(largest);
        }
    }

public:
    void insert(int key) {
        heap.push_back(key); // Add to the end
        heapifyUp(heap.size() - 1); // Fix property
    }

    int extractMax() {
        if (heap.size() == 0) return -1;
        
        int root = heap[0];
        heap[0] = heap.back(); // Replace root with last element
        heap.pop_back();
        
        heapifyDown(0); // Fix property
        return root;
    }

    void display() {
        for (int x : heap) cout << x << " ";
        cout << endl;
    }
};

int main() {
    MaxHeap mh;
    mh.insert(10);
    mh.insert(30);
    mh.insert(20);
    mh.insert(5);
    mh.insert(1);
    mh.insert(50);

    cout << "Max Heap Elements: ";
    mh.display(); // Root should be 50

    cout << "Extracting Max: " << mh.extractMax() << endl;
    cout << "Heap after extraction: ";
    mh.display();

    return 0;
}
```

---

### 6. الـ Edge Cases والتفاصيل الدقيقة

- **Complexity:**
    
    - **Peek (Get Max/Min):** $O(1)$ - هو أول عنصر في الـ Array دايماً.
        
    - **Insert/Delete:** $O(\log N)$ - لأننا بنمشي بطول ارتفاع الشجرة.
        
- **Why not BST?** الـ BST عشان تجيب منها الـ Max لازم تمشي أقصى اليمين. ولو الشجرة مش متوازنة هتبقى $O(N)$. الـ Heap بتضمن لك الـ Max في $O(1)$ وبتضمن إن التوازن دايماً موجود لأنها Complete.
    
- **Memory Efficiency:** مفيش Pointers! يعني مفيش 8 bytes ضايعين لكل نود. ده بيخلي الـ Heap صديقة جداً للميموري.
    

---

### الربط بالمفاهيم التانية

- **Priority Queues:** الـ Heap هي المحرك اللي بيشغل أي Priority Queue في الدنيا.
    
- **Heapsort:** خوارزمية ترتيب سرعتها دايماً $O(N \log N)$ وبتتم In-place (جوه نفس المصفوفة).
    
- **Graph Algorithms:** خوارزميات زي **Dijkstra** و **Prim** بتستخدم الـ Min-Heap عشان تختار أقصر طريق بسرعة.
    
- **OS Memory Management:** الـ "Heap Memory" اللي بنعمل فيها `new` و `malloc` اتسمت كده تاريخياً لأنها كانت بتدار بطرق مشابهة (وإن كانت دلوقتي أعقد بكتير).
    

