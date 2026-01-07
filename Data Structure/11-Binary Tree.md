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

- **Full Binary Tree:** دي الشجرة "الصارمة". كل نود فيها يا إما عندها **0** أبناء أو **2**. مفيش نود عندها إبن واحد "وحيد".
    
- **Complete Binary Tree:** دي الشجرة "المنظمة". كل المستويات فيها مليانة عدا الأخير، وفي المستوى الأخير، لازم العناصر تكون مرصوصة من **أقصى الشمال** (Left to Right) بدون أي فجوات. دي هي أساس الـ **Heap** اللي بيشغل الـ Priority Queues.
    
- **Perfect Binary Tree:** دي "عروسة الشجر". كل النودز الداخلية عندها إبنين، وكل الـ Leaves في نفس المستوى بالظبط. شجرة مثالية رياضياً.
    
- **Balanced Binary Tree:** دي الشجرة "الرشيقة". الفرق بين طول الفرع الشمال والفرع اليمين لكل نود مبيزدش عن 1. دي اللي بتضمن لنا سرعة الـ $O(\log n)$.
    
- **Degenerate (Skewed) Tree:** دي "الشجرة العجوزة". كل نود ليها إبن واحد بس، فبقت شكلها شكل الـ Linked List وفقدت كل مميزات الشجر.
    

---

### 4. المستوى العميق: رحلة البحث عن الداتا (Tree Traversal)

في الـ Linked List، كان الطريق واحد. في الشجرة، إنت عندك متاهة. إزاي نلف على كل النودز ونطبعهم؟ العلماء اخترعوا طريقتين كبار:

#### أ) العمق أولاً (Depth-First Search - DFS)

ودي بنستخدم فيها الـ **Recursion** (أو الـ Stack)، وليها 3 أذواق:

1. **Pre-order (Root, Left, Right):** بنزور الأب الأول، وبعدين ولاده. (تستخدم لعمل نسخة من الشجرة).
    
2. **In-order (Left, Root, Right):** بنزور الابن الشمال، وبعدين الأب، وبعدين الابن اليمين. (في الـ BST، الطريقة دي بتطبع الداتا **مترتبة**!).
    
3. **Post-order (Left, Right, Root):** بنزور الولاد الأول وبعدين الأب. (تستخدم لمسح الشجرة من الميموري أو حساب حجم الفولدرات).
    

#### ب) المستوى أولاً (Breadth-First Search - BFS)

ودي بنسميها **Level-order Traversal**. بنزور الشجرة "دور دور". الدور الأول (Root)، بعدين ولاده (الدور التاني)، بعدين أحفاده (الدور التالت). دي بتحتاج **Queue** عشان تشتغل صح.

---

### 5. الأمثلة العملية (C++ Implementation)

تعال نبني شجرة بسيطة ونطبق عليها الـ 3 أنواع بتوع الـ DFS. ركز في الـ Recursion لأنه هو "السحر" هنا.

C++

```
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

- **The Power of Recursion:** لاحظ إن الكود صغير جداً. ده لأن الشجرة هي هيكل بيانات **Recursive** بطبعه. كل فرع في الشجرة هو "شجرة صغيرة" (Subtree).
    
- **Height of an Empty Tree:** اصطلح العلماء إن ارتفاع الشجرة الفاضية هو `-1` أو `0` (حسب المرجع)، ونود واحدة ارتفاعها `0` أو `1`. ده بيفرق معاك في حسابات الـ AVL بعدين.
    
- **Memory Overhead:** في الـ Binary Tree، لو عندك $N$ نود، هيكون عندك بالظبط $N+1$ من الـ `nullptr` pointers ضايعين في الـ Leaves. في الـ Big Data، بنحاول نعالج ده بحاجة اسمها **Succinct Data Structures**.
    

---

### الربط بالمفاهيم التانية

- **Expression Trees:** الآلة الحاسبة بتحول معادلة زي $3 + 4 \times 2$ لشجرة ثنائية عشان تعرف تنفذ الضرب قبل الجمع.
    
- **Decision Trees:** في الـ Machine Learning، الشجر هو اللي بيقرأ البيانات ويقولك العميل ده "هيشتري" ولا "مش هيشتري".
    
- **Heaps:** دي نوع خاص من الـ Complete Binary Trees بنستخدمه عشان نجيب أكبر أو أصغر رقم في المصفوفة في وقت $O(1)$.
    

---

إيه رأيك يا دكتور في الـ Binary Trees؟ هل التصنيفات وطرق الـ Traversal كده بقت واضحة؟

إحنا دلوقتي جاهزين ندخل في "الوحش" اللي بجد، وهو الـ **Binary Search Tree (BST)**، اللي بسببه الداتا بتترتب وبنبحث فيها بسرعة البرق.

**هل ننتقل للـ Binary Search Tree (BST) أم نتعمق أكتر في الـ Level-order traversal والـ Queues؟**