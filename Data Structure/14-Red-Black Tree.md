---
title: Red-Black Tree
created: 2026-01-08
tags:
  - data-structures
  - trees
  - red-black
  - self-balancing
  - O(logn)
related:
  - "[[_Data Structures MOC]]"
  - "[[12-Binary Search Tree (BST)]]"
  - "[[13-AVL Tree]]"
complexity:
  all_operations: O(log n)
---

يا أهلاً بك يا دكتور في "المعيار الصناعي" (The Industrial Standard). إحنا دلوقتي في حضرة الـ **Red-Black Tree (RBT)**. لو كانت الـ AVL هي الشجرة "المثالية" اللي بتهتم بمظهرها وتوازنها بالسنتيمتر، فالـ Red-Black هي الشجرة "العملية" اللي بتوازن بين سرعة البحث وسرعة التعديل.

دي الشجرة اللي بتشغل الـ `std::map` والـ `std::set` في لغة C++، وهي اللي بيستخدمها الـ Linux Kernel في جدولة العمليات (Completely Fair Scheduler).

اربط الحزام، وتعال نعرف ليه الألوان (الأحمر والأسود) غيرت تاريخ قواعد البيانات.

---

## الأشجار الحمراء والسوداء - The Red-Black Tree

### 1. القصة والتاريخ: من "أقلام الحبر" إلى المفاعلات النووية

بص يا سيدي، في سنة 1972، عالم ألماني أسطوري اسمه **Rudolf Bayer** اخترع هيكل بيانات سماه "Symmetric Binary B-Trees". كانت فكرة عبقرية بس معقدة شوية.

في سنة 1978، **Leonidas J. Guibas** و **Robert Sedgewick** (تلميذ دونالد كنوث) طوروا الفكرة دي وسموها **Red-Black Trees**.

ليه أحمر وأسود بالذات؟

الأسطورة بتقول إن "سيدجويك" وهو بيكتب البحث، كان عنده طابعة ليزر "Xerox" في المعمل، والطابعة دي مكنتش بتطبع غير لونين بس: الأحمر والأسود. فقرر يلون النودز بالألوان المتاحة عشان يسهل شرح "قواعد التوازن". ومن يومها والاسم لزق فيها!

---

### 2. المستوى السطحي: "القواعد الخمسة المقدسة" (The 5 Rules)

الـ RBT هي Binary Search Tree عادية، بس لازم تحقق 5 شروط صارمة في كل لحظة. لو شرط منهم انكسر، الشجرة بتعمل "إصلاح ذاتي" (Recoloring or Rotation).

1. **كل نود يا إما حمراء يا إما سوداء.**
    
2. **الـ Root دايماً أسود.**
    
3. **كل الـ Leaves (الـ NULLs اللي في الآخر) بنعتبرها سوداء.**
    
4. **النود الحمراء ولادها لازم يكونوا سود** (يعني ممنوع اتنين أحمر ورا بعض).
    
5. **أي مسار من أي نود لحد الـ Leaves اللي تحتها لازم يحتوي على نفس عدد النودز السوداء** (ده بنسميه الـ Black Height).
    

---

### 3. المستوى المتوسط: ليه هي أحسن من الـ AVL في "الكتابة"؟

بص يا دكتور، الـ AVL مهووسة بالتوازن، فبتعمل Rotations كتير جداً. الـ Red-Black "متساهلة" شوية. هي بتضمن إن أطول مسار في الشجرة مش أكتر من **ضعف** أقصر مسار.

- **AVL:** توازن مثالي -> بحث أسرع بكتير -> تعديل (إضافة/حذف) بطيء.
    
- **Red-Black:** توازن "كويس كفاية" -> بحث سريع -> تعديل (إضافة/حذف) طلقة.
    

عشان كدة في الـ **Real-world systems** اللي فيها إضافات ومسح كتير، الـ Red-Black هي الملكة.

---

### 4. المستوى العميق: حركات الإصلاح (Recoloring vs. Rotation)

لما بنضيف نود جديدة، دايماً بنضيفها **حمراء** (عشان منحرقش الـ Black Height). بس ده ممكن يكسر القاعدة رقم 4 (اتنين أحمر ورا بعض). هنا بنبص على "العم" (Uncle):

#### الحالة الأولى: الـ Uncle لونه أحمر

الحل هنا "سِلمي". بنغير الألوان بس (**Recoloring**). بنخلي الأب والعم سود، والجد أحمر.

Code snippet

```
graph TD
    subgraph "Case 1: Uncle is Red (Recoloring)"
    direction TB
    G((Grandparent - Black)) --- P((Parent - Red))
    G --- U((Uncle - Red))
    P --- N((New Node - Red))
    
    Update[Recolor: P, U become Black / G becomes Red]
    end
```

#### الحالة الثانية: الـ Uncle لونه أسود

هنا مفيش مفر من القوة الغاشمة. لازم نعمل **Rotation** (زي الـ AVL) وبعدين نغير الألوان.

Code snippet

```
graph TD
    subgraph "Case 2: Uncle is Black (Rotation)"
    direction TB
    G2((Grandparent - Black)) --- P2((Parent - Red))
    G2 --- U2((Uncle - Black/NIL))
    P2 --- N2((New Node - Red))
    
    Action[Perform Rotation then Recolor]
    end
```

---

### 5. الأمثلة العملية (C++ Concept)

بما إن كود الـ RBT الكامل ممكن يوصل لـ 300 سطر، أنا هكتب لك الـ **Core Logic** لعملية الإضافة وتصحيح الألوان عشان تفهم الـ Engine شغال إزاي.

C++

```
#include <iostream>

using namespace std;

enum Color { RED, BLACK };

struct Node {
    int data;
    Color color;
    Node *left, *right, *parent;

    Node(int val) : data(val), color(RED), left(nullptr), right(nullptr), parent(nullptr) {}
};

class RedBlackTree {
private:
    Node* root;

    // Standard Left Rotation (same as AVL)
    void rotateLeft(Node* &ptr) {
        Node* right_child = ptr->right;
        ptr->right = right_child->left;
        if (ptr->right != nullptr) ptr->right->parent = ptr;
        right_child->parent = ptr->parent;
        if (ptr->parent == nullptr) root = right_child;
        else if (ptr == ptr->parent->left) ptr->parent->left = right_child;
        else ptr->parent->right = right_child;
        right_child->left = ptr;
        ptr->parent = right_child;
    }

    // Standard Right Rotation (same as AVL)
    void rotateRight(Node* &ptr) {
        Node* left_child = ptr->left;
        ptr->left = left_child->right;
        if (ptr->left != nullptr) ptr->left->parent = ptr;
        left_child->parent = ptr->parent;
        if (ptr->parent == nullptr) root = left_child;
        else if (ptr == ptr->parent->left) ptr->parent->left = left_child;
        else ptr->parent->right = left_child;
        left_child->right = ptr;
        ptr->parent = left_child;
    }

    // The Magic: Fixup after insertion to maintain RBT properties
    void fixViolation(Node* &ptr) {
        Node* parent_ptr = nullptr;
        Node* grandparent_ptr = nullptr;

        while ((ptr != root) && (ptr->color != BLACK) && (ptr->parent->color == RED)) {
            parent_ptr = ptr->parent;
            grandparent_ptr = ptr->parent->parent;

            /* Case A: Parent is left child of Grandparent */
            if (parent_ptr == grandparent_ptr->left) {
                Node* uncle_ptr = grandparent_ptr->right;

                /* Case 1: Uncle is Red (Only Recoloring) */
                if (uncle_ptr != nullptr && uncle_ptr->color == RED) {
                    grandparent_ptr->color = RED;
                    parent_ptr->color = BLACK;
                    uncle_ptr->color = BLACK;
                    ptr = grandparent_ptr;
                } else {
                    /* Case 2: ptr is right child (Left-Right rotation) */
                    if (ptr == parent_ptr->right) {
                        rotateLeft(parent_ptr);
                        ptr = parent_ptr;
                        parent_ptr = ptr->parent;
                    }
                    /* Case 3: ptr is left child (Right rotation) */
                    rotateRight(grandparent_ptr);
                    swap(parent_ptr->color, grandparent_ptr->color);
                    ptr = parent_ptr;
                }
            }
            /* Case B: Parent is right child (Symmetric to Case A) */
            else {
                // ... Mirror of Case A ...
            }
        }
        root->color = BLACK; // Rule 2: Root is always black
    }

public:
    RedBlackTree() { root = nullptr; }
    // ... insert method would call fixViolation ...
};
```

---

### 6. الـ Edge Cases والتفاصيل الدقيقة

- **The Black Height Property:** هي دي "كلمة السر" اللي بتخلي الشجرة متوازنة. لأنك لو عندك مسارين ليهم نفس عدد النودز السوداء، وأطول مسار ممكن يكون فيه نود حمراء بين كل نود سوداء، ده معناه إن أطول مسار مستحيل يزيد عن ضعف أقصر مسار.
    
- **NIL Leaves:** ليه بنعتبر الـ NULLs نودز سوداء؟ عشان نسهل الحسابات الرياضية والقواعد. لما بتيجي تبرمجها، ممكن تعمل نود واحدة "Sentinel" لونها أسود وتخلي كل الـ leaves تشاور عليها توفيراً للميموري.
    
- **Worst-Case Efficiency:** حتى في أسوأ حالاتها، الـ RBT بتقدم $O(\log n)$ للبحث والإضافة والحذف.
    

---

### الربط بالمفاهيم التانية

موضوع الـ Red-Black Tree مرتبط بـ:

- **Completely Fair Scheduler (CFS):** نظام توزيع المهام في الـ Linux Kernel بيستخدم RBT عشان يختار الـ process اللي خدت أقل وقت تنفيذ ويشغلها.
    
- **`std::map` and `std::set`:** في أغلب الـ C++ Compilers، الـ containers دي متنفذة بـ RBT.
    
- **Java `TreeMap` & `TreeSet`:** نفس الكلام في عالم جافا.
    
- **Database Engines:** بعض أنواع الـ In-memory databases بتفضل الـ RBT لسرعة التعديل فيها.
    

---
