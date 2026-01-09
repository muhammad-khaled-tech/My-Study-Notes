---
title: Binary Tree
created: 2026-01-08
tags:
  - data-structures
  - trees
  - binary-tree
related:
  - "[[_Data Structures MOC]]"
  - "[[10-Introduction to trees]]"
  - "[[12-Binary Search Tree (BST)]]"
  - "[[15-Heaps]]"
---

يا أهلاً بك يا دكتور في أول نزهة حقيقية جوه "الغابة" اللي حكينا عنها. إحنا النهاردة هنمسك أول وأشهر نوع من الأشجار، وهو الـ **Binary Tree** (الشجرة الثنائية).

النوع ده هو "اللبنة الأساسية" لكل حاجة معقدة هتشوفها بعدين. لو فهمت الـ Binary Tree صح، الـ AVL والـ Red-Black والـ Heaps هيبقوا بالنسبة لك لعب عيال.

اربط الحزام، وتعال نفهم ليه رقم "2" هو الرقم السحري في تاريخ الكمبيوتر.

---

## المحطة الرابعة: الشجرة الثنائية - The Binary Tree

### 1. القصة والتاريخ: ليه "ثنائية" بالذات؟

بص يا سيدي، ليه العلماء ركزوا على إن كل نود يكون ليها إبنين بس؟ ليه مش تلاتة أو أربعة؟

الإجابة بترجع للفلسفة اللي بنى عليها Claude Shannon علم المعلومات. الكمبيوتر في أساسه "ثنائي" (0 أو 1)، (صح أو غلط)، (يمين أو شمال).

في الخمسينيات، المبرمجين لقوا إن الـ Binary Tree هي أبسط تمثيل لعملية "اتخاذ القرار". كل نود بتمثل سؤال، وإجابتك بتوديك يا إما للفرع الشمال يا إما للفرع اليمين. البساطة دي خلتنا نقدر نطبق معادلات رياضية مرعبة وسهلة في نفس الوقت لإدارة البيانات.

---

### 2. المستوى السطحي: "إيه ده؟" (The Basic Concept)

الـ **Binary Tree** هي شجرة، كل نود فيها عندها **على الأكثر** (At most) إبنين. يعني النود ممكن يكون عندها:

- 0 أبناء (Leaf Node).
    
- إبن واحد (يا شمال يا يمين).
    
- إبنين (Left Child و Right Child).
    

---

### 3. المستوى المتوسط: تصنيفات الشجر (Classifications)

هنا بقى الحتة اللي بتيجي في إنترفيوهات شركات الـ Big Tech، لأن المسميات دي بتفرق جداً في الـ Performance:

- **Full Binary Tree:** 
- دي الشجرة "الصارمة". كل نود فيها يا إما عندها **0** أبناء أو **2**. مفيش نود عندها إبن واحد "وحيد".
    
- **Complete Binary Tree:**
- دي الشجرة "المنظمة". كل المستويات فيها مليانة عدا الأخير، وفي المستوى الأخير، لازم العناصر تكون مرصوصة من **أقصى الشمال** (Left to Right) بدون أي فجوات. دي هي أساس الـ **Heap** اللي بيشغل الـ Priority Queues.
    
- **Perfect Binary Tree:**
- دي "عروسة الشجر". كل النودز الداخلية عندها إبنين، وكل الـ Leaves في نفس المستوى بالظبط. شجرة مثالية رياضياً.
    
- **Balanced Binary Tree:** 
- دي الشجرة "الرشيقة". الفرق بين طول الفرع الشمال والفرع اليمين لكل نود مبيزدش عن 1. دي اللي بتضمن لنا سرعة الـ $O(\log n)$.
    
- **Degenerate (Skewed) Tree:**
- دي "الشجرة العجوزة". كل نود ليها إبن واحد بس، فبقت شكلها شكل الـ Linked List وفقدت كل مميزات الشجر.
    

---

### 4. المستوى العميق: رحلة البحث عن الداتا (Tree Traversal)

في الـ Linked List، كان الطريق واحد. في الشجرة، إنت عندك متاهة. إزاي نلف على كل النودز ونطبعهم؟ العلماء اخترعوا طريقتين كبار:

تعال نتخيل إننا في "متاهة" (Maze) كبيرة، أو إننا بنبحث عن "كنز" جوه شجرة أو شبكة معقدة. الفرق بين **BFS** و **DFS** هو "شخصية" الباحث وطريقته في التحرك.

### 1. الـ BFS (Breadth-First Search) - "المُستكشف الحذر"

**الاسم بالعربي:** البحث بالعرض أولاً.

الفلسفة: "أنا مش هسيب شبر غير لما أعرفه".

تخيل إنك واقف في نص أوضة، وفيها أبواب كتير. الـ BFS بيعمل إيه؟

- يفتح كل الأبواب اللي قدامه **خطوة واحدة بس**.
    
- يبص ورا كل باب، وبعدين يرجع يفتح الأبواب اللي جوه الأبواب دي **خطوة واحدة كمان**.
    
- هو بيمشي في "دوائر" بتوسع تدريجياً. مبيسبش مستوى (Level) غير لما يخلصه كله.
    

**التشبيه الحركي:** زي الحجر اللي بترميه في المية، بيعمل دوائر بتكبر من المركز للخارج.

---

### 2. الـ DFS (Depth-First Search) - "المغامر الجريء"

**الاسم بالعربي:** البحث بالعمق أولاً.

الفلسفة: "أنا همشي ورا الخيط ده لآخر عمره، ولو مسدود هبقى أرجع".

تخيل نفس الأوضة والأبواب:

- الـ DFS بيختار باب واحد عشوائي ويدخل منه.
    
- ويلاقي باب جواه، يدخل منه.. وباب جواه، يدخل منه.
    
- بيفضل يغوص لأعمق نقطة ممكنة لحد ما يخبط في حيطة سد (Dead end).
    
- أول ما يتسد الطريق، يرجع خطوة لورا (Backtrack) ويشوف لو فيه باب تاني مرفهوش، ويدخل فيه لآخره برضه.
    

**التشبيه الحركي:** زي الغواص اللي بينزل لأعمق حتة في المحيط قبل ما يفكر يتحرك يميناً أو يساراً.

---

### 3. مقارنة سريعة (عشان نتخيل الفرق)

|**وجه المقارنة**|**BFS (Breadth)**|**DFS (Depth)**|
|---|---|---|
|**طريقة التحرك**|أفقية (دور بدور) - **Horizontal**|رأسية (فرع بفرع) - **Vertical**|
|**الأداة المستخدمة**|الـ **Queue** (طابور)|الـ **Stack** (أو الـ Recursion)|
|**الهدف الأساسي**|إيجاد **أقصر طريق** للهدف.|استكشاف **كل الاحتمالات** الممكنة.|
|**المثال الحي**|الـ "People you may know" في فيسبوك (بيجيب الدوائر القريبة منك).|حل "متاهة" أو لعبة شطرنج (بيشوف عواقب النقلة لآخرها).|

---

### 4. مثال "لعبة الاستغماية" (The Visualization)

تخيل إنك بتدور على صاحبك في عمارة 5 أدوار:

- **لو إنت BFS:** هتدخل الدور الأول، تفتح كل الشقق اللي فيه. ملقتهوش؟ تطلع الدور التاني تفتح كل الشقق.. وهكذا. (إنت ضامن إنك لو لقيته في الدور التاني، يبقى ده أقصر طريق ليه).
    
- **لو إنت DFS:** هتدخل أول شقة في الدور الأول، وتدخل أول أوضة فيها، وتفتح الدولاب اللي جوه الأوضة.. فضلت تغوص لحد ما وصلت لآخر نقطة في أول شقة، ملقتهوش؟ تخرج وتشوف الشقة اللي بعدها وتعمل نفس الحركة.
    

---
 تعال نغطس في أول "محيط" عندنا وهو الـ **BFS (Breadth-First Search)**.
إحنا اتفقنا إن الـ BFS هو "المستكشف الحذر" اللي بيمشي دور بدور. عشان نحول الفلسفة دي لكود حقيقي يشتغل على الكمبيوتر، محتاجين "مُحرك" بيضمن لنا إن اللي جه الأول هو اللي يتخدم الأول. والمحرك ده هو الـ **Queue** (الطابور).

---

## الغوص في أعماق الـ BFS: محرك الـ Queue

### 1. ليه الـ Queue هو بطل الحكاية؟

الـ BFS بيعتمد على مبدأ FIFO (First-In, First-Out).

تخيل الـ Queue كأنه "مفكرة المواعيد". إنت بتسجل فيها أسماء الناس اللي المفروض تزورهم.

- لما تزور "أب"، بتسجل أسماء "ولاده" في آخر الطابور.
    
- وبما إنك بتخلص الطابور بالترتيب، فإنت مستحيل تروح لـ "حفيد" (Level 3) غير لما تخلص كل "الولاد" (Level 2) اللي مسجلين قبله في الطابور.
    

---

### 2. الخوارزمية (الخطوات المنطقية)

لو قدامنا شجرة أو جراف، الـ BFS بيشتغل كالتالي:

1. **البداية:** حط الـ Root (نقطة البداية) في الـ **Queue**.
    
2. **الدوران:** طول ما الـ Queue مش فاضي، كرر الآتي:
    
    - اسحب (Pop) أول عنصر من الـ Queue.
        
    - **زوره (Visit):** اطبع قيمته أو اعمل العملية اللي محتاجها.
        
    - **الاستكشاف:** شوف كل جيرانه (أو ولاده). اللي ملمستوش قبل كده، حطه في **آخر الـ Queue**.
        
3. **النهاية:** لما الـ Queue يفضى، يبقى إنت غطيت كل المناطق المتاحة.
    

---

### 3. التطبيق العملي بلغة C++

ده كود BFS لشجرة ثنائية (Binary Tree). ركز إزاي الـ Queue هو اللي بيتحكم في "الرتم" بتاعنا:



```C++
#include <iostream>
#include <queue> // The heart of BFS

using namespace std;

struct Node {
    int data;
    Node *left, *right;
    Node(int val) : data(val), left(nullptr), right(nullptr) {}
};

// BFS implementation (Iterative using Queue)
void breadthFirstSearch(Node* root) {
    if (root == nullptr) return;

    // Create a queue to store nodes to be visited
    queue<Node*> q;

    // 1. Enqueue the root
    q.push(root);

    cout << "BFS Traversal: ";

    // 2. Loop until the queue is empty
    while (!q.empty()) {
        // Get the front element
        Node* current = q.front();
        q.pop();

        // Visit the node
        cout << current->data << " ";

        // 3. Enqueue children (left then right) to maintain level order
        if (current->left != nullptr) {
            q.push(current->left);
        }
        if (current->right != nullptr) {
            q.push(current->right);
        }
    }
    cout << endl;
}

int main() {
    /* Building a sample tree:
            1
           / \
          2   3
         / \   \
        4   5   6
    */
    Node* root = new Node(1);
    root->left = new Node(2);
    root->right = new Node(3);
    root->left->left = new Node(4);
    root->left->right = new Node(5);
    root->right->right = new Node(6);

    // BFS Output should be: 1 2 3 4 5 6
    breadthFirstSearch(root);

    return 0;
}
```

---

### 4. تحليل الأداء (Complexity Analysis)

- **Time Complexity:** $O(V + E)$ في الـ Graphs، أو $O(N)$ في الـ Trees.
    
    - _التفسير:_ إنت بتعدي على كل نود (V) وكل وصلة (E) مرة واحدة بالظبط.
        
- **Space Complexity:** $O(W)$ حيث $W$ هو أقصى عرض للشجرة (Maximum Width).
    
    - _التفسير:_ في أسوأ الحالات، الـ Queue ممكن يشيل ليفل كامل من الشجرة.
        

---

### 5. إمتى الـ BFS يكون هو "الجوكر"؟ (Use Cases)

1. **أقصر طريق (Shortest Path):** في الجرافات اللي الوصلات فيها ليها نفس الوزن (Unweighted Graphs)، الـ BFS بيضمن لك إن أول مرة توصل فيها للهدف، هي دي أقصر طريق. (زي Google Maps في حالة المسافات المتساوية).
    
2. **شبكات التواصل الاجتماعي:** لو عايز تعرف "دوائر الأصدقاء" (Friends of friends). أول ليفل هم أصحابك، تاني ليفل هم أصحاب أصحابك.
    
3. **الـ GPS والخرائط:** استكشاف أقرب صيدلية أو بنزينة لموقعك الحالي.
    

---

### 6. التحدي (The Edge Case)

لو الشجرة بتاعتك "عميقة جداً" بس "رفيعة"، الـ BFS هيكون ممتاز في الميموري. لكن لو الشجرة "عريضة جداً" (كل نود ليها 100 ابن مثلاً)، الـ Queue هيتنفخ ميموري بسرعة جداً. دي نقطة الضعف الوحيدة تقريباً.

---
دلوقتي جه وقت المغامرة الحقيقية مع الـ **DFS (Depth-First Search)**.
لو الـ BFS كان "المستكشف الحذر"، فالـ DFS هو "الغواص الجريء". هو مبيحبش الوقوف على الشط، هو عايز يوصل لأعمق نقطة في البحر، ولو لقاها مسدودة، يبدأ يرجع يدور على فتحة تانية.

---
## الغوص في أعماق الـ DFS: سحر الـ Stack والـ Recursion

### 1. ليه الـ Stack (أو الريكيرجن) هو المحرك؟

الـ DFS بيعتمد على مبدأ **LIFO (Last-In, First-Out)**.

- لما بتوصل لنقطة (Node)، وبتقرر تدخل في أول فرع يقابلك، إنت بترمى "مكانك الحالي" في الـ Stack وبتروح للفرع الجديد.
    
- بتفضل تعمل كده لحد ما توصل لآخر الطريق (Leaf Node).
    
- أول ما الطريق يتسد، بتعمل **Pop** من الـ Stack عشان تعرف إنت كنت فين قبل النقطة دي، وترجع لها عشان تشوف لو كان فيه فرع تاني مخدتوش. العملية دي بنسميها Backtracking
    

**ملحوظة للمحترفين:** إحنا غالباً بنستخدم الـ **Recursion** في الـ DFS لأن الـ Recursion بيستخدم الـ System Call Stack أوتوماتيكياً، فبيوفر علينا كتابة كود الـ Stack بإيدنا.

---

### 2. الخوارزمية (الخطوات المنطقية)

1. **البداية:** ابدأ من الـ Root.
    
2. **الغوص:** اذهب لأول ابن (غالباً الشمال) وكرر العملية (ريكيرجن).
    
3. **الارتداد Backtracking:** لو وصلت لنهاية فرع، ارجع للأب وشوف الابن اللي عليه الدور (اليمين).
    
4. **النهاية:** تنتهي العملية لما تزور كل الفروع وترجع للـ Root وتخلص كل ولاده.
    

---

### 3. التطبيق العملي بلغة C++ (الطريقة الـ Recursive)

ده أشهر شكل للـ DFS في الأشجار، وهو الـ **In-order Traversal** (واحد من أنواع الـ DFS الثلاثة):



```C++
#include <iostream>

using namespace std;

struct Node {
    int data;
    Node *left, *right;
    Node(int val) : data(val), left(nullptr), right(nullptr) {}
};

// DFS implementation (Recursive)
void depthFirstSearch(Node* root) {
    if (root == nullptr) return;

    // 1. Visit Left Child (Go Deep)
    depthFirstSearch(root->left);

    // 2. Visit Node itself
    cout << root->data << " ";

    // 3. Visit Right Child
    depthFirstSearch(root->right);
}

int main() {
    /* Sample Tree:
            1
           / \
          2   3
         / \
        4   5
    */
    Node* root = new Node(1);
    root->left = new Node(2);
    root->right = new Node(3);
    root->left->left = new Node(4);
    root->left->right = new Node(5);

    cout << "DFS (In-order) Traversal: ";
    // Output will be: 4 2 5 1 3
    depthFirstSearch(root);
    cout << endl;

    return 0;
}
```

---

### 4. تحليل الأداء (Complexity Analysis)

- **Time Complexity:** $O(V + E)$ أو $O(N)$. إنت برضه بتعدي على كل نود مرة واحدة.
    
- **Space Complexity:** $O(H)$ حيث $H$ هو ارتفاع الشجرة (Height).
    
    - _التفسير:_ في أسوأ الحالات (لو الشجرة عبارة عن خط مستقيم)، الـ Call Stack هيشيل كل النودز ورا بعضها.
        

---

### 5. إمتى الـ DFS يكون هو "البطل"؟ (Use Cases)

1. **حل المتاهات والغاز (Solving Puzzles):** الـ DFS مثالي لو عايز تجرب كل الاحتمالات الممكنة لحد ما توصل للحل (زي لعبة الـ Sudoku أو الـ N-Queens).
    
2. **اكتشاف الدورات (Cycle Detection):** لو عايز تعرف هل فيه "قفلة" أو دائرة مغلقة في الشبكة بتاعتك (مهم جداً في الـ Operating Systems عشان الـ Deadlock).
    
3. **الترتيب المنهجي (Topological Sort):** لو عندك مهام بتعتمد على بعضها، الـ DFS بيعرفك تبدأ بمين وتخلص مين الأول.
    
4. **إيجاد المسارات (Finding Paths):** لو مش فارق معاك الطريق قصير ولا طويل، المهم توصل وخلاص.
    

---

### 6. المقارنة الحاسمة (The Showdown)

- **المساحة (Space):**
    
    - لو الشجرة "عريضة" (Wide): الـ **DFS** أحسن لأنه بيحجز ميموري بطول الفرع بس.
        
    - لو الشجرة "عميقة" (Deep): الـ **BFS** أحسن لأنه بيحجز ميموري بعرض الليفل بس.
        
- **الهدف:**
    
    - عايز أقصر طريق؟ خليك في الـ **BFS**.
        
    - عايز تستكشف كل الزوايا وتجرب احتمالات؟ خليك في الـ **DFS**.
        

---

### الزتونة:

يا محمد، الفرق الجوهري هو **"بكره ولا النهاردة؟"**.

- الـ **BFS** بيقولك: "أنا هخلص كل اللي حواليا النهاردة، وبكرة أشوف اللي بعدهم".
    
- الـ **DFS** بيقولك: "أنا همشي في السكة دي لآخرها، ومش راجع غير لما تخلص".
    

---

### 5. الأمثلة العملية (C++ Implementation)

تعال نبني شجرة بسيطة ونطبق عليها الـ 3 أنواع بتوع الـ DFS. ركز في الـ Recursion لأنه هو "السحر" هنا.



```C++
#include <iostream>

using namespace std;

// The basic building block: A Node with two hands
struct Node {
    int data;
    Node *left, *right;

    Node(int val) {
        data = val;
        left = right = nullptr;
    }
};

// 1. Pre-order Traversal: Root -> Left -> Right
void printPreOrder(Node* node) {
    if (node == nullptr) return;

    cout << node->data << " ";     // Visit the Root
    printPreOrder(node->left);     // Traverse Left Subtree
    printPreOrder(node->right);    // Traverse Right Subtree
}

// 2. In-order Traversal: Left -> Root -> Right
void printInOrder(Node* node) {
    if (node == nullptr) return;

    printInOrder(node->left);      // Traverse Left Subtree
    cout << node->data << " ";     // Visit the Root
    printInOrder(node->right);     // Traverse Right Subtree
}

// 3. Post-order Traversal: Left -> Right -> Root
void printPostOrder(Node* node) {
    if (node == nullptr) return;

    printPostOrder(node->left);     // Traverse Left Subtree
    printPostOrder(node->right);    // Traverse Right Subtree
    cout << node->data << " ";      // Visit the Root
}

int main() {
    // Manually creating a simple tree
    /* 1
           / \
          2   3
         / \
        4   5
    */
    Node* root = new Node(1);
    root->left = new Node(2);
    root->right = new Node(3);
    root->left->left = new Node(4);
    root->left->right = new Node(5);

    cout << "Pre-order: ";  printPreOrder(root);  cout << endl;  // 1 2 4 5 3
    cout << "In-order:  ";  printInOrder(root);   cout << endl;  // 4 2 5 1 3
    cout << "Post-order: "; printPostOrder(root); cout << endl;  // 4 5 2 3 1

    return 0;
}
```

---

### 6. الـ Edge Cases والتفاصيل الدقيقة

- **The Power of Recursion:** 
- لاحظ إن الكود صغير جداً. ده لأن الشجرة هي هيكل بيانات **Recursive** بطبعه. كل فرع في الشجرة هو "شجرة صغيرة" (Subtree).
    
- **Height of an Empty Tree:** 
- اصطلح العلماء إن ارتفاع الشجرة الفاضية هو `-1` أو `0` (حسب المرجع)، ونود واحدة ارتفاعها `0` أو `1`. ده بيفرق معاك في حسابات الـ AVL بعدين.
    
- **Memory Overhead:** 
- في الـ Binary Tree، لو عندك $N$ نود، هيكون عندك بالظبط $N+1$ من الـ `nullptr` pointers ضايعين في الـ Leaves. في الـ Big Data، بنحاول نعالج ده بحاجة اسمها **Succinct Data Structures**.
    

---

### الربط بالمفاهيم التانية

- **Expression Trees:**
- الآلة الحاسبة بتحول معادلة زي $3 + 4 \times 2$ لشجرة ثنائية عشان تعرف تنفذ الضرب قبل الجمع.
    
- **Decision Trees:** 
- في الـ Machine Learning، الشجر هو اللي بيقرأ البيانات ويقولك العميل ده "هيشتري" ولا "مش هيشتري".
    
- **Heaps:** 
- دي نوع خاص من الـ Complete Binary Trees بنستخدمه عشان نجيب أكبر أو أصغر رقم في المصفوفة في وقت $O(1)$.
    

---

