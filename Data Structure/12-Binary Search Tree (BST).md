---
title: Binary Search Tree (BST)
created: 2026-01-08
tags:
  - data-structures
  - trees
  - bst
  - O(logn)
related:
  - "[[_Data Structures MOC]]"
  - "[[11-Binary Tree]]"
  - "[[13-AVL Tree]]"
  - "[[14-Red-Black Tree]]"
complexity:
  search: O(log n)
  insert: O(log n)
  delete: O(log n)
---

يا أهلاً بك يا دكتور في "بيت القصيد" وجوهرة التاج في عالم هياكل البيانات. إحنا دلوقتي قدام الـ **Binary Search Tree (BST)**. لو كانت الشجرة الثنائية العادية اللي شرحناها المرة اللي فاتت هي "الهيكل"، فالـ BST هي "العقل المفكر".

ده الهيكل اللي بسببه الداتا مش بس متخزنة، دي متخزنة بذكاء يخليك تجيب الإبرة من وسط كوم القش في لمح البصر. اربط الحزام، وهات قهوتك، لأننا داخلين في أعماق خوارزمية غيرت وجه البحث في تاريخ الحاسوب.

---

## شجرة البحث الثنائية - The Binary Search Tree (BST)

### 1. القصة والتاريخ: معضلة "السرعة مقابل المرونة"

بص يا سيدي، في الستينيات، المهندسين في شركات زي **IBM** و **Control Data Corporation** واجهوا معضلة فلسفية وهندسية مرعبة:

1. الـ **Sorted Array** كان سريع جداً في البحث ($O(\log n)$) بفضل الـ Binary Search، بس لو حبيت "تضيف" رقم جديد في النص، كنت بتضطر تزق نص الميموري وده بطيء جداً ($O(n)$).
    
2. الـ **Linked List** كانت مرنة جداً في الإضافة ($O(1)$)، بس عشان "تبحث" عن رقم، كنت لازم تمشي السلسلة من أولها لآخرها ($O(n)$).
    

سألوا نفسهم: "هل نقدر نبني هيكل بيانات يجمع بين سرعة البحث في الـ Array ومرونة الإضافة في الـ Linked List؟".

في سنة 1960، ظهر مفهوم الـ BST. الفكرة كانت عبقرية: بدل ما نخزن الأرقام في خط مستقيم، هنخزنهم في شجرة، بس بشرط (قاعدة ذهبية) تنظم المرور جوه الشجرة دي.

---

### 2. المستوى السطحي: "إيه ده؟" (The Golden Rule)

الـ **BST** هي Binary Tree عادية جداً، بس عليها "قيد" أو "شرط" صارم لكل نود جوه الشجرة:

- كل القيم اللي في **الناحية الشمال** (Left Subtree) لازم تكون **أصغر** من قيمة النود الحالية.
    
- كل القيم اللي في **الناحية اليمين** (Right Subtree) لازم تكون **أكبر** من قيمة النود الحالية.
    

تخيل إنك واقف عند الـ Root، ومعاك رقم بتدور عليه. لو الرقم أصغر من الـ Root، إنت واثق 100% إن الرقم ده مستحيل يكون في الناحية اليمين، فبترمي نص الشجرة وتدخل شمال. دي هي نفس فكرة الـ Binary Search بس على شكل شجرة.

---

### 3. المستوى المتوسط: العمليات الأساسية (Core Operations)

#### أ) البحث (Search) - $O(\log n)$

إنت بتبدأ من الـ Root وتتفرع. في كل خطوة، إنت بتقسم مساحة البحث لنصين. ده بيخليك توصل لأي نود في وقت قياسي.

#### ب) الإضافة (Insertion) - $O(\log n)$

عشان تضيف رقم، بتمشي وراه كأنك بتدور عليه. أول ما توصل لمكان فاضي (`nullptr`) يكون هو ده المكان اللي الرقم "يستحق" يقعد فيه عشان يحافظ على توازن القاعدة الذهبية.

#### ج) الحذف (Deletion) - "التحدي الحقيقي"

الحذف في الـ BST هو اللي بيفرق المبرمج الهاوي عن المحترف، لأننا عندنا 3 حالات:

1. **حذف Leaf Node (ورقة):** دي سهلة، بنقطع الغصن بتاعها وخلاص.
    
2. **حذف Node ليها إبن واحد:** بنمسحها ونخلي جدها يمسك إيد ابنها (زي الـ Linked List).
    
3. **حذف Node ليها إبنين:** دي بقى "الزتونة". بنبدل النود دي بأصغر عنصر في ناحيتها اليمين (**In-order Successor**) أو أكبر عنصر في ناحيتها الشمال (**In-order Predecessor**)، وبعدين نمسح العنصر ده من مكانه القديم.
    

---

### 4. المستوى العميق: التحليل الهندسي (The Balanced Paradox)

ليه بنقول إن الـ BST سرعتها $O(\log n)$؟

بص يا دكتور، الـ $\log n$ مرتبط بـ ارتفاع الشجرة (Height). لو الشجرة متوازنة (Balanced)، الارتفاع هيكون قصير. لكن لو الشجرة "مالت" وبقت Skewed (زي ما حكينا في المحطة صفر)، سرعتها هتقلب فوراً لـ $O(n)$ وتتحول لـ Linked List غبية.

عشان كدة، الـ BST العادية بنعتبرها "خطرة" في الـ Production، لأن لو الداتا دخلت مترتبة (مثلاً 1, 2, 3, 4, 5)، الشجرة هتبني نفسها في خط مستقيم. وعشان نحل ده، العلماء اخترعوا الـ **Self-Balancing Trees** اللي بتعدل نفسها أوتوماتيك (زي الـ AVL).

|**العملية**|**الـ Best/Average Case**|**الـ Worst Case (Skewed)**|
|---|---|---|
|**Search**|$O(\log n)$|$O(n)$|
|**Insert**|$O(\log n)$|$O(n)$|
|**Delete**|$O(\log n)$|$O(n)$|

---

### 5. الأمثلة العملية (C++ Implementation)

ده كود دسم بيوريك إزاي تبني BST وتعمل فيها Search و Insert، مع الكومنتات بالإنجليزية.

C++

```
#include <iostream>

using namespace std;

// Node structure for BST
struct Node {
    int data;
    Node *left, *right;

    Node(int val) {
        data = val;
        left = right = nullptr;
    }
};

class BST {
private:
    Node* root;

    // Helper function for recursive insertion
    Node* insertRecursive(Node* node, int val) {
        // 1. If the tree/branch is empty, create a new node
        if (node == nullptr) {
            return new Node(val);
        }

        // 2. Otherwise, recur down the tree
        if (val < node->data) {
            node->left = insertRecursive(node->left, val);
        } else if (val > node->data) {
            node->right = insertRecursive(node->right, val);
        }

        // Return the unchanged node pointer
        return node;
    }

    // Helper function for searching
    bool searchRecursive(Node* node, int target) {
        if (node == nullptr) return false; // Not found
        if (node->data == target) return true; // Found it!

        // Deciding which branch to take
        if (target < node->data) {
            return searchRecursive(node->left, target);
        } else {
            return searchRecursive(node->right, target);
        }
    }

    // In-order traversal to see sorted data
    void inOrder(Node* node) {
        if (node == nullptr) return;
        inOrder(node->left);
        cout << node->data << " ";
        inOrder(node->right);
    }

public:
    BST() { root = nullptr; }

    void insert(int val) {
        root = insertRecursive(root, val);
    }

    bool search(int val) {
        return searchRecursive(root, val);
    }

    void display() {
        inOrder(root);
        cout << endl;
    }
};

int main() {
    BST tree;

    // Inserting elements
    tree.insert(50);
    tree.insert(30);
    tree.insert(70);
    tree.insert(20);
    tree.insert(40);
    tree.insert(60);
    tree.insert(80);

    // After In-order traversal, data must be sorted: 20 30 40 50 60 70 80
    cout << "In-order traversal of the BST: ";
    tree.display();

    // Searching
    int key = 60;
    cout << "Searching for " << key << ": " << (tree.search(key) ? "Found ✅" : "Not Found ❌") << endl;

    return 0;
}
```

---

### 6. الـ Edge Cases والتفاصيل الدقيقة

- **In-order Traversal Property:** دي أهم ملاحظة في الـ BST. لو عملت In-order Traversal (Left, Root, Right) لأي BST في الدنيا، الداتا هتطلع لك **مترتبة تصاعدياً** أوتوماتيك! دي خاصية سحرية بنستخدمها عشان نتأكد إن الشجرة سليمة.
    
- **Duplicate Values:** غالباً الـ BST مش بتسمح بالتكرار. لو حاولت تضيف رقم موجود، يا إما تتجاهله، يا إما تزود عداد (Counter) جوه النود، يا إما تقرر إن التكرار دايماً يروح يمين (أو شمال) حسب اتفاقك.
    
- **Successor & Predecessor:** في عملية الحذف، الـ In-order Successor هو أصغر قيمة في الفرع اليمين (يعني تمشي يمين خطوة، وبعدين تفضل تمشي شمال لحد ما تخلص).
    

---

### الربط بالمفاهيم التانية

- **Database Indexes:** الـ B-Tree هي النسخة "العضلات" من الـ BST، بتستخدمها الـ Databases عشان تخزن ملايين السجلات وتجيبها في لمح البصر.
    
- **Binary Search Algorithm:** الـ BST هي "تجسيد" لخوارزمية الـ Binary Search في شكل هيكل بيانات دائم.
    
- **Memory Management:** الـ BST بتستخدم الـ Heap ميموري بشكل مكثف، وفهمها بيخليك "أستاذ" في التعامل مع الـ Pointers.
    

---

