---
title: AVL Tree
created: 2026-01-08
tags:
  - data-structures
  - trees
  - avl
  - self-balancing
  - O(logn)
related:
  - "[[_Data Structures MOC]]"
  - "[[12-Binary Search Tree (BST)]]"
  - "[[14-Red-Black Tree]]"
complexity:
  all_operations: O(log n)
---

يا أهلاً بك يا دكتور في "قسم العناية المركزة" للأشجار. إحنا المرة اللي فاتت سيبنا الـ BST وهي بتعاني من مشكلة "الميل" (Skewness). لو الداتا دخلت مترتبة، الشجرة بتتحول لـ Linked List وبنخسر كل مميزات الـ $O(\log n)$.

في سنة 1962، اتنين علماء روس، **Georgy Adelson-Velsky** و **Evgenii Landis**، قدموا للعالم أول هيكل بيانات بيعرف "يعدل نفسه بنفسه". وسموه على أول حروف من أساميهم: **AVL Tree**.

اربط الحزام، لأننا داخلين في أعماق "الرقص مع الأشجار" وعمليات الـ Rotations المعقدة.

---

## الأشجار المتوازنة ذاتياً - The AVL Tree

### 1. القصة والتاريخ: ثورة البحث السوفيتية

بص يا سيدي، في عز الحرب الباردة، كان فيه سباق مش بس في الفضاء، لكن في "سرعة معالجة البيانات". المشكلة كانت إن الـ BST العادية "غدارة". إنت بتبنيها وأنت فاكر إنها سريعة، وفجأة تلاقي الأداء وقع للأرض لأن الداتا جاية شبه مترتبة.

أديلسون ولانديس قالوا: "إحنا مش هنسيب الشجرة تنمو على هواها. إحنا هنحط 'ميزان' عند كل نود. لو كفة طبّت عن التانية، الشجرة لازم تعمل 'حركة بهلوانية' (Rotation) عشان ترجع الميزان لوضعه الطبيعي". ده كان أول تطبيق لمفهوم **Self-Balancing Binary Search Tree**.

---

### 2. المستوى السطحي: "ميزان الـ AVL" (The Balance Factor)

كل نود في الـ AVL عندها معلومة زيادة بنخزنها وهي الـ **Height** (الارتفاع). ومن الارتفاع ده بنحسب حاجة اسمها الـ **Balance Factor (BF)**:

$$BF = \text{Height}(LeftSubtree) - \text{Height}(RightSubtree)$$

القاعدة الصارمة:

الـ Balance Factor لأي نود في الشجرة لازم يكون -1 أو 0 أو 1.

- لو بقى **2** (ثقيلة من الشمال).
    
- لو بقى -2 (ثقيلة من اليمين).
    
    هنا الشجرة بتعلن حالة الطوارئ وتعمل Rotation.
    

---

### 3. المستوى المتوسط: الحركات البهلوانية (The 4 Rotations)

عندنا 4 حالات لعدم التوازن، وكل حالة ليها حركة معينة ترجعها لأصلها:

#### الحالة الأولى: Left-Left (LL) Case

الشجرة تقيلة من ناحية الشمال خالص (خط مستقيم لليسار). الحل: بنعمل **Single Right Rotation**.

Code snippet

```
graph TD
    subgraph "Before Rotation (LL)"
    A((3)) --- B((2))
    B --- C((1))
    A -.-> |BF=2| A
    end
    
    subgraph "After Right Rotation"
    B2((2)) --- C2((1))
    B2 --- A2((3))
    B2 -.-> |BF=0| B2
    end
```

#### الحالة الثانية: Right-Right (RR) Case

الشجرة تقيلة من ناحية اليمين خالص. الحل: بنعمل **Single Left Rotation**.

Code snippet

```
graph TD
    subgraph "Before Rotation (RR)"
    A((1)) --- B((2))
    B --- C((3))
    A -.-> |BF=-2| A
    end
    
    subgraph "After Left Rotation"
    B2((2)) --- A2((1))
    B2 --- C2((3))
    B2 -.-> |BF=0| B2
    end
```

#### الحالة الثالثة: Left-Right (LR) Case

الشجرة تقيلة من الشمال بس الابن الأخير ناحية اليمين (شكل "Z"). الحل: بنعمل **Left Rotation** للابن، وبعدين **Right Rotation** للأب.

Code snippet

```
graph TD
    subgraph "Before Rotation (LR)"
    A((3)) --- B((1))
    B --- C((2))
    A -.-> |BF=2| A
    end
    
    subgraph "Steps"
    Step1[1. Left Rotate B] --> Step2[2. Right Rotate A]
    end
```

#### الحالة الرابعة: Right-Left (RL) Case

عكس الـ LR. الحل: **Right Rotation** للابن، وبعدين **Left Rotation** للأب.

---

### 4. المستوى العميق: لماذا الـ AVL هي الأسرع في البحث؟

بص يا دكتور، الـ AVL مهووسة بالتوازن (Strictly Balanced). ده بيخلي ارتفاع الشجرة دايماً في أقل مستوياته الممكنة ($1.44 \log n$).

- **في البحث:** هي أسرع من الـ Red-Black Tree لأن توازنها أدق.
    
- **في الإضافة والحذف:** هي أبطأ شوية لأنها بتعمل Rotations كتير عشان تحافظ على التوازن الصارم ده.
    

---

### 5. الأمثلة العملية (C++ Implementation)

ده كود دسم بيطبق الـ AVL Tree مع الـ Rotations، ركز جداً في دالة الـ `rebalance` والـ `height`.

C++

```
#include <iostream>
#include <algorithm>

using namespace std;

// AVL Node Structure
struct Node {
    int key;
    Node *left, *right;
    int height; // Every node stores its own height

    Node(int val) {
        key = val;
        left = right = nullptr;
        height = 1; // New nodes are added as leaf
    }
};

class AVLTree {
private:
    Node* root;

    // Helper to get node height safely
    int height(Node* n) {
        return (n == nullptr) ? 0 : n->height;
    }

    // Get balance factor of node
    int getBalance(Node* n) {
        return (n == nullptr) ? 0 : height(n->left) - height(n->right);
    }

    // Right Rotate (used for LL case)
    Node* rightRotate(Node* y) {
        Node* x = y->left;
        Node* T2 = x->right;

        // Perform rotation
        x->right = y;
        y->left = T2;

        // Update heights
        y->height = max(height(y->left), height(y->right)) + 1;
        x->height = max(height(x->left), height(x->right)) + 1;

        return x; // New root
    }

    // Left Rotate (used for RR case)
    Node* leftRotate(Node* x) {
        Node* y = x->right;
        Node* T2 = y->left;

        // Perform rotation
        y->left = x;
        x->right = T2;

        // Update heights
        x->height = max(height(x->left), height(x->right)) + 1;
        y->height = max(height(y->left), height(y->right)) + 1;

        return y; // New root
    }

    Node* insert(Node* node, int key) {
        // 1. Standard BST insertion
        if (node == nullptr) return new Node(key);

        if (key < node->key)
            node->left = insert(node->left, key);
        else if (key > node->key)
            node->right = insert(node->right, key);
        else return node; // No duplicate keys

        // 2. Update height of this ancestor node
        node->height = 1 + max(height(node->left), height(node->right));

        // 3. Get balance factor to check for imbalance
        int balance = getBalance(node);

        // Case 1: Left Left (LL)
        if (balance > 1 && key < node->left->key)
            return rightRotate(node);

        // Case 2: Right Right (RR)
        if (balance < -1 && key > node->right->key)
            return leftRotate(node);

        // Case 3: Left Right (LR)
        if (balance > 1 && key > node->left->key) {
            node->left = leftRotate(node->left);
            return rightRotate(node);
        }

        // Case 4: Right Left (RL)
        if (balance < -1 && key < node->right->key) {
            node->right = rightRotate(node->right);
            return leftRotate(node);
        }

        return node;
    }

    void inOrder(Node* root) {
        if (root != nullptr) {
            inOrder(root->left);
            cout << root->key << " ";
            inOrder(root->right);
        }
    }

public:
    AVLTree() { root = nullptr; }
    void insert(int key) { root = insert(root, key); }
    void display() { inOrder(root); cout << endl; }
};

int main() {
    AVLTree tree;

    /* Constructing tree given in the graph 
       Adding numbers in a way that would skew a normal BST
    */
    tree.insert(10);
    tree.insert(20);
    tree.insert(30); // RR rotation happens here
    tree.insert(40);
    tree.insert(50); // RR rotation happens here
    tree.insert(25); // RL rotation happens here

    cout << "In-order traversal of AVL tree: ";
    tree.display(); // Should be sorted: 10 20 25 30 40 50

    return 0;
}
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Deletion Complexity:** الحذف في الـ AVL أصعب من الإضافة، لأنك بعد ما بتمسح النود، لازم تعمل "Backtracking" لحد الـ Root وتصلح الـ Balance Factor لكل نود في طريقك. ممكن حذف نود واحدة يسبب سلسلة من الـ Rotations (Cascading Rotations).
    
2. **Height storage:** إحنا بنخزن الـ Height جوه كل نود عشان نوفر وقت الحساب. لو مكنتش بتخزنه، كنت هتضطر تحسبه في كل لفة وده هيخلي الـ Complexity تقع من $O(\log n)$ لـ $O(n \log n)$.
    
3. **Strict Balance:** الـ AVL مثالية لقواعد البيانات اللي فيها "بحث كتير" (Read-heavy) وإضافات قليلة.
    

---

