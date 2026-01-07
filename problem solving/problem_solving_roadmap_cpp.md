# 🎯 Problem Solving Roadmap: Zero to Hero (550+ Problems)

> **Language: C++** | **Duration: 6 Months** | **Goal: Interview Ready**

---

## 📊 Overview & Timeline

| Phase | Duration | Problems | Daily Target | Difficulty |
|-------|----------|----------|--------------|------------|
| **Phase 1: Foundations** | 6 weeks | 100 | 2-3 | Easy + Some Medium |
| **Phase 2: Core Patterns** | 8 weeks | 200 | 3-4 | Medium |
| **Phase 3: Advanced Topics** | 6 weeks | 150 | 3-4 | Medium + Hard |
| **Phase 4: Mock Interviews** | 4 weeks | 100 | 3-4 | Mixed |

**Total: 550 problems in 24 weeks**

---

# 📘 Phase 1: Foundations (Weeks 1-6)

## Week 1-2: Arrays & Strings (35 Problems)

### Core Concepts
- Two Pointers Technique
- Sliding Window
- Prefix Sum
- In-place Manipulation

### Arrays - Easy (15 Problems)

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/) ⭐
- [ ] [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
- [ ] [27. Remove Element](https://leetcode.com/problems/remove-element/)
- [ ] [66. Plus One](https://leetcode.com/problems/plus-one/)
- [ ] [88. Merge Sorted Array](https://leetcode.com/problems/merge-sorted-array/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/) ⭐
- [ ] [122. Best Time to Buy and Sell Stock II](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/)
- [ ] [217. Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)
- [ ] [268. Missing Number](https://leetcode.com/problems/missing-number/)
- [ ] [283. Move Zeroes](https://leetcode.com/problems/move-zeroes/)
- [ ] [448. Find All Numbers Disappeared](https://leetcode.com/problems/find-all-numbers-disappeared-in-an-array/)
- [ ] [485. Max Consecutive Ones](https://leetcode.com/problems/max-consecutive-ones/)
- [ ] [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
- [ ] [561. Array Partition](https://leetcode.com/problems/array-partition/)
- [ ] [1929. Concatenation of Array](https://leetcode.com/problems/concatenation-of-array/)

### Strings - Easy (10 Problems)

- [ ] [14. Longest Common Prefix](https://leetcode.com/problems/longest-common-prefix/)
- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) ⭐
- [ ] [28. Find First Occurrence](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/)
- [ ] [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/) ⭐
- [ ] [242. Valid Anagram](https://leetcode.com/problems/valid-anagram/) ⭐
- [ ] [344. Reverse String](https://leetcode.com/problems/reverse-string/)
- [ ] [387. First Unique Character](https://leetcode.com/problems/first-unique-character-in-a-string/)
- [ ] [392. Is Subsequence](https://leetcode.com/problems/is-subsequence/)
- [ ] [409. Longest Palindrome](https://leetcode.com/problems/longest-palindrome/)
- [ ] [771. Jewels and Stones](https://leetcode.com/problems/jewels-and-stones/)

### Arrays/Strings - Medium (10 Problems)

- [ ] [3. Longest Substring Without Repeating](https://leetcode.com/problems/longest-substring-without-repeating-characters/) ⭐⭐
- [ ] [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/) ⭐
- [ ] [15. 3Sum](https://leetcode.com/problems/3sum/) ⭐⭐
- [ ] [49. Group Anagrams](https://leetcode.com/problems/group-anagrams/) ⭐
- [ ] [75. Sort Colors](https://leetcode.com/problems/sort-colors/)
- [ ] [167. Two Sum II](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)
- [ ] [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/)
- [ ] [238. Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/) ⭐⭐
- [ ] [443. String Compression](https://leetcode.com/problems/string-compression/)
- [ ] [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) ⭐

### 💡 C++ Patterns: Arrays & Strings

```cpp
#include <vector>
#include <unordered_map>
#include <unordered_set>
using namespace std;

// ============ TWO POINTERS ============
// Use when array is sorted or comparing from both ends
vector<int> twoPointers(vector<int>& arr, int target) {
    int left = 0, right = arr.size() - 1;
    while (left < right) {
        int sum = arr[left] + arr[right];
        if (sum == target) return {left, right};
        else if (sum < target) left++;
        else right--;
    }
    return {};
}

// ============ SLIDING WINDOW ============
// Use for subarray/substring problems
int slidingWindow(string& s) {
    unordered_set<char> window;
    int left = 0, maxLen = 0;
    
    for (int right = 0; right < s.size(); right++) {
        while (window.count(s[right])) {
            window.erase(s[left++]);
        }
        window.insert(s[right]);
        maxLen = max(maxLen, right - left + 1);
    }
    return maxLen;
}

// ============ FREQUENCY MAP ============
unordered_map<int, int> getFrequency(vector<int>& arr) {
    unordered_map<int, int> freq;
    for (int num : arr) freq[num]++;
    return freq;
}
```

---

## Week 3: Linked Lists (20 Problems)

### Core Concepts
- Fast & Slow Pointers (Floyd's Cycle Detection)
- Reversal Technique
- Dummy Node Trick

### Easy (12 Problems)

- [ ] [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/) ⭐
- [ ] [83. Remove Duplicates from Sorted List](https://leetcode.com/problems/remove-duplicates-from-sorted-list/)
- [ ] [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/) ⭐
- [ ] [160. Intersection of Two Linked Lists](https://leetcode.com/problems/intersection-of-two-linked-lists/)
- [ ] [203. Remove Linked List Elements](https://leetcode.com/problems/remove-linked-list-elements/)
- [ ] [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) ⭐⭐
- [ ] [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)
- [ ] [237. Delete Node in a Linked List](https://leetcode.com/problems/delete-node-in-a-linked-list/)
- [ ] [876. Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/) ⭐
- [ ] [1290. Convert Binary Number](https://leetcode.com/problems/convert-binary-number-in-a-linked-list-to-integer/)
- [ ] [2181. Merge Nodes in Between Zeros](https://leetcode.com/problems/merge-nodes-in-between-zeros/)
- [ ] [2130. Maximum Twin Sum](https://leetcode.com/problems/maximum-twin-sum-of-a-linked-list/)

### Medium (8 Problems)

- [ ] [2. Add Two Numbers](https://leetcode.com/problems/add-two-numbers/) ⭐
- [ ] [19. Remove Nth Node From End](https://leetcode.com/problems/remove-nth-node-from-end-of-list/) ⭐
- [ ] [24. Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/)
- [ ] [61. Rotate List](https://leetcode.com/problems/rotate-list/)
- [ ] [82. Remove Duplicates from Sorted List II](https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/)
- [ ] [92. Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/) ⭐
- [ ] [143. Reorder List](https://leetcode.com/problems/reorder-list/) ⭐⭐
- [ ] [148. Sort List](https://leetcode.com/problems/sort-list/)

### 💡 C++ Patterns: Linked Lists

```cpp
struct ListNode {
    int val;
    ListNode* next;
    ListNode(int x) : val(x), next(nullptr) {}
};

// ============ DUMMY NODE ============
ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
    ListNode dummy(0);
    ListNode* curr = &dummy;
    
    while (l1 && l2) {
        if (l1->val < l2->val) {
            curr->next = l1;
            l1 = l1->next;
        } else {
            curr->next = l2;
            l2 = l2->next;
        }
        curr = curr->next;
    }
    curr->next = l1 ? l1 : l2;
    return dummy.next;
}

// ============ FAST & SLOW POINTERS ============
ListNode* findMiddle(ListNode* head) {
    ListNode *slow = head, *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
    }
    return slow;
}

// ============ REVERSE LINKED LIST ============
ListNode* reverseList(ListNode* head) {
    ListNode *prev = nullptr, *curr = head;
    while (curr) {
        ListNode* next = curr->next;
        curr->next = prev;
        prev = curr;
        curr = next;
    }
    return prev;
}
```

---

## Week 4-5: Stack & Queue (25 Problems)

### Core Concepts
- Monotonic Stack
- Expression Evaluation
- BFS using Queue

### Stack - Easy (10 Problems)

- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) ⭐⭐
- [ ] [155. Min Stack](https://leetcode.com/problems/min-stack/) ⭐
- [ ] [225. Implement Stack using Queues](https://leetcode.com/problems/implement-stack-using-queues/)
- [ ] [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/)
- [ ] [496. Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/)
- [ ] [682. Baseball Game](https://leetcode.com/problems/baseball-game/)
- [ ] [844. Backspace String Compare](https://leetcode.com/problems/backspace-string-compare/)
- [ ] [1021. Remove Outermost Parentheses](https://leetcode.com/problems/remove-outermost-parentheses/)
- [ ] [1614. Maximum Nesting Depth](https://leetcode.com/problems/maximum-nesting-depth-of-the-parentheses/)
- [ ] [2390. Removing Stars From a String](https://leetcode.com/problems/removing-stars-from-a-string/)

### Stack - Medium (10 Problems)

- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) ⭐
- [ ] [71. Simplify Path](https://leetcode.com/problems/simplify-path/)
- [ ] [150. Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/) ⭐
- [ ] [224. Basic Calculator](https://leetcode.com/problems/basic-calculator/)
- [ ] [227. Basic Calculator II](https://leetcode.com/problems/basic-calculator-ii/)
- [ ] [394. Decode String](https://leetcode.com/problems/decode-string/) ⭐
- [ ] [503. Next Greater Element II](https://leetcode.com/problems/next-greater-element-ii/)
- [ ] [735. Asteroid Collision](https://leetcode.com/problems/asteroid-collision/)
- [ ] [739. Daily Temperatures](https://leetcode.com/problems/daily-temperatures/) ⭐
- [ ] [853. Car Fleet](https://leetcode.com/problems/car-fleet/)

### Queue - Medium (5 Problems)

- [ ] [17. Letter Combinations](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)
- [ ] [102. Binary Tree Level Order](https://leetcode.com/problems/binary-tree-level-order-traversal/) ⭐
- [ ] [127. Word Ladder](https://leetcode.com/problems/word-ladder/)
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) ⭐⭐
- [ ] [542. 01 Matrix](https://leetcode.com/problems/01-matrix/)

### 💡 C++ Patterns: Stack & Queue

```cpp
#include <stack>
#include <queue>
#include <unordered_map>
using namespace std;

// ============ MONOTONIC STACK ============
vector<int> nextGreaterElement(vector<int>& nums) {
    int n = nums.size();
    vector<int> result(n, -1);
    stack<int> st; // indices
    
    for (int i = 0; i < n; i++) {
        while (!st.empty() && nums[st.top()] < nums[i]) {
            result[st.top()] = nums[i];
            st.pop();
        }
        st.push(i);
    }
    return result;
}

// ============ VALID PARENTHESES ============
bool isValid(string s) {
    stack<char> st;
    unordered_map<char, char> pairs = {{')', '('}, {'}', '{'}, {']', '['}};
    
    for (char c : s) {
        if (pairs.count(c)) {
            if (st.empty() || st.top() != pairs[c]) return false;
            st.pop();
        } else {
            st.push(c);
        }
    }
    return st.empty();
}

// ============ BFS TEMPLATE ============
void bfs(int start) {
    queue<int> q;
    unordered_set<int> visited;
    q.push(start);
    visited.insert(start);
    
    while (!q.empty()) {
        int node = q.front(); q.pop();
        // Process node
        for (int neighbor : getNeighbors(node)) {
            if (!visited.count(neighbor)) {
                visited.insert(neighbor);
                q.push(neighbor);
            }
        }
    }
}
```

---

## Week 6: Hash Tables & Sets (20 Problems)

### Easy (10 Problems)

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/) ⭐⭐
- [ ] [136. Single Number](https://leetcode.com/problems/single-number/)
- [ ] [217. Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)
- [ ] [219. Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/)
- [ ] [242. Valid Anagram](https://leetcode.com/problems/valid-anagram/)
- [ ] [383. Ransom Note](https://leetcode.com/problems/ransom-note/)
- [ ] [387. First Unique Character](https://leetcode.com/problems/first-unique-character-in-a-string/)
- [ ] [389. Find the Difference](https://leetcode.com/problems/find-the-difference/)
- [ ] [645. Set Mismatch](https://leetcode.com/problems/set-mismatch/)
- [ ] [1207. Unique Number of Occurrences](https://leetcode.com/problems/unique-number-of-occurrences/)

### Medium (10 Problems)

- [ ] [3. Longest Substring Without Repeating](https://leetcode.com/problems/longest-substring-without-repeating-characters/) ⭐
- [ ] [36. Valid Sudoku](https://leetcode.com/problems/valid-sudoku/)
- [ ] [49. Group Anagrams](https://leetcode.com/problems/group-anagrams/) ⭐
- [ ] [128. Longest Consecutive Sequence](https://leetcode.com/problems/longest-consecutive-sequence/) ⭐⭐
- [ ] [187. Repeated DNA Sequences](https://leetcode.com/problems/repeated-dna-sequences/)
- [ ] [205. Isomorphic Strings](https://leetcode.com/problems/isomorphic-strings/)
- [ ] [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) ⭐
- [ ] [438. Find All Anagrams](https://leetcode.com/problems/find-all-anagrams-in-a-string/)
- [ ] [454. 4Sum II](https://leetcode.com/problems/4sum-ii/)
- [ ] [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) ⭐

### 💡 C++ Patterns: Hash Tables

```cpp
#include <unordered_map>
#include <unordered_set>
using namespace std;

// ============ TWO SUM PATTERN ============
vector<int> twoSum(vector<int>& nums, int target) {
    unordered_map<int, int> seen; // value -> index
    for (int i = 0; i < nums.size(); i++) {
        int complement = target - nums[i];
        if (seen.count(complement)) {
            return {seen[complement], i};
        }
        seen[nums[i]] = i;
    }
    return {};
}

// ============ LONGEST CONSECUTIVE ============
int longestConsecutive(vector<int>& nums) {
    unordered_set<int> numSet(nums.begin(), nums.end());
    int maxLen = 0;
    
    for (int num : numSet) {
        if (!numSet.count(num - 1)) { // Start of sequence
            int curr = num, len = 1;
            while (numSet.count(curr + 1)) {
                curr++;
                len++;
            }
            maxLen = max(maxLen, len);
        }
    }
    return maxLen;
}
```

---

# 📗 Phase 2: Core Patterns (Weeks 7-14)

## Week 7-9: Binary Trees (50 Problems)

### Core Concepts
- DFS (PreOrder, InOrder, PostOrder)
- BFS (Level Order)
- Lowest Common Ancestor
- Path Sum Problems

### Easy (20 Problems)

- [ ] [94. Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/)
- [ ] [100. Same Tree](https://leetcode.com/problems/same-tree/)
- [ ] [101. Symmetric Tree](https://leetcode.com/problems/symmetric-tree/)
- [ ] [104. Maximum Depth](https://leetcode.com/problems/maximum-depth-of-binary-tree/) ⭐
- [ ] [108. Convert Sorted Array to BST](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/)
- [ ] [110. Balanced Binary Tree](https://leetcode.com/problems/balanced-binary-tree/)
- [ ] [111. Minimum Depth](https://leetcode.com/problems/minimum-depth-of-binary-tree/)
- [ ] [112. Path Sum](https://leetcode.com/problems/path-sum/)
- [ ] [144. Binary Tree Preorder](https://leetcode.com/problems/binary-tree-preorder-traversal/)
- [ ] [145. Binary Tree Postorder](https://leetcode.com/problems/binary-tree-postorder-traversal/)
- [ ] [226. Invert Binary Tree](https://leetcode.com/problems/invert-binary-tree/) ⭐
- [ ] [235. LCA of a BST](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/) ⭐
- [ ] [257. Binary Tree Paths](https://leetcode.com/problems/binary-tree-paths/)
- [ ] [404. Sum of Left Leaves](https://leetcode.com/problems/sum-of-left-leaves/)
- [ ] [543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/) ⭐
- [ ] [572. Subtree of Another Tree](https://leetcode.com/problems/subtree-of-another-tree/)
- [ ] [617. Merge Two Binary Trees](https://leetcode.com/problems/merge-two-binary-trees/)
- [ ] [637. Average of Levels](https://leetcode.com/problems/average-of-levels-in-binary-tree/)
- [ ] [653. Two Sum IV - BST](https://leetcode.com/problems/two-sum-iv-input-is-a-bst/)
- [ ] [700. Search in a BST](https://leetcode.com/problems/search-in-a-binary-search-tree/)

### Medium (30 Problems)

- [ ] [98. Validate BST](https://leetcode.com/problems/validate-binary-search-tree/) ⭐⭐
- [ ] [102. Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) ⭐
- [ ] [103. Zigzag Level Order](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
- [ ] [105. Construct from Preorder & Inorder](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/) ⭐
- [ ] [106. Construct from Inorder & Postorder](https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
- [ ] [113. Path Sum II](https://leetcode.com/problems/path-sum-ii/)
- [ ] [114. Flatten to Linked List](https://leetcode.com/problems/flatten-binary-tree-to-linked-list/)
- [ ] [116. Populating Next Right Pointers](https://leetcode.com/problems/populating-next-right-pointers-in-each-node/)
- [ ] [199. Right Side View](https://leetcode.com/problems/binary-tree-right-side-view/) ⭐
- [ ] [230. Kth Smallest in BST](https://leetcode.com/problems/kth-smallest-element-in-a-bst/) ⭐
- [ ] [236. LCA of Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) ⭐⭐

### 💡 C++ Patterns: Binary Trees

```cpp
#include <queue>
#include <vector>
using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

// ============ DFS TRAVERSALS ============
void preorder(TreeNode* root, vector<int>& res) {
    if (!root) return;
    res.push_back(root->val);      // Root
    preorder(root->left, res);      // Left
    preorder(root->right, res);     // Right
}

void inorder(TreeNode* root, vector<int>& res) {
    if (!root) return;
    inorder(root->left, res);       // Left
    res.push_back(root->val);       // Root (BST: sorted order!)
    inorder(root->right, res);      // Right
}

void postorder(TreeNode* root, vector<int>& res) {
    if (!root) return;
    postorder(root->left, res);     // Left
    postorder(root->right, res);    // Right
    res.push_back(root->val);       // Root
}

// ============ BFS (LEVEL ORDER) ============
vector<vector<int>> levelOrder(TreeNode* root) {
    vector<vector<int>> result;
    if (!root) return result;
    
    queue<TreeNode*> q;
    q.push(root);
    
    while (!q.empty()) {
        int size = q.size();
        vector<int> level;
        for (int i = 0; i < size; i++) {
            TreeNode* node = q.front(); q.pop();
            level.push_back(node->val);
            if (node->left) q.push(node->left);
            if (node->right) q.push(node->right);
        }
        result.push_back(level);
    }
    return result;
}

// ============ LOWEST COMMON ANCESTOR ============
TreeNode* lca(TreeNode* root, TreeNode* p, TreeNode* q) {
    if (!root || root == p || root == q) return root;
    TreeNode* left = lca(root->left, p, q);
    TreeNode* right = lca(root->right, p, q);
    if (left && right) return root;
    return left ? left : right;
}
```

---

## Week 10-11: Dynamic Programming Basics (40 Problems)

### Core Concepts
- 1D DP (Fibonacci-like)
- 2D DP (Grid problems)
- Kadane's Algorithm
- Knapsack Variants

### Easy (15 Problems)

- [ ] [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) ⭐
- [ ] [118. Pascal's Triangle](https://leetcode.com/problems/pascals-triangle/)
- [ ] [119. Pascal's Triangle II](https://leetcode.com/problems/pascals-triangle-ii/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)
- [ ] [338. Counting Bits](https://leetcode.com/problems/counting-bits/)
- [ ] [392. Is Subsequence](https://leetcode.com/problems/is-subsequence/)
- [ ] [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
- [ ] [746. Min Cost Climbing Stairs](https://leetcode.com/problems/min-cost-climbing-stairs/) ⭐
- [ ] [1137. N-th Tribonacci](https://leetcode.com/problems/n-th-tribonacci-number/)

### Medium (25 Problems)

- [ ] [5. Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) ⭐⭐
- [ ] [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) ⭐⭐ (Kadane's)
- [ ] [62. Unique Paths](https://leetcode.com/problems/unique-paths/) ⭐
- [ ] [63. Unique Paths II](https://leetcode.com/problems/unique-paths-ii/)
- [ ] [64. Minimum Path Sum](https://leetcode.com/problems/minimum-path-sum/) ⭐
- [ ] [91. Decode Ways](https://leetcode.com/problems/decode-ways/) ⭐
- [ ] [139. Word Break](https://leetcode.com/problems/word-break/) ⭐⭐
- [ ] [152. Maximum Product Subarray](https://leetcode.com/problems/maximum-product-subarray/) ⭐
- [ ] [198. House Robber](https://leetcode.com/problems/house-robber/) ⭐⭐
- [ ] [213. House Robber II](https://leetcode.com/problems/house-robber-ii/)
- [ ] [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) ⭐⭐⭐
- [ ] [322. Coin Change](https://leetcode.com/problems/coin-change/) ⭐⭐⭐
- [ ] [416. Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) ⭐

### 💡 C++ Patterns: Dynamic Programming

```cpp
#include <vector>
#include <algorithm>
using namespace std;

// ============ FIBONACCI (Space Optimized) ============
int climbStairs(int n) {
    if (n <= 2) return n;
    int prev2 = 1, prev1 = 2;
    for (int i = 3; i <= n; i++) {
        int curr = prev1 + prev2;
        prev2 = prev1;
        prev1 = curr;
    }
    return prev1;
}

// ============ KADANE'S ALGORITHM ============
int maxSubArray(vector<int>& nums) {
    int maxSum = nums[0], currSum = nums[0];
    for (int i = 1; i < nums.size(); i++) {
        currSum = max(nums[i], currSum + nums[i]);
        maxSum = max(maxSum, currSum);
    }
    return maxSum;
}

// ============ 0/1 KNAPSACK ============
int knapsack(vector<int>& weights, vector<int>& values, int capacity) {
    int n = weights.size();
    vector<vector<int>> dp(n + 1, vector<int>(capacity + 1, 0));
    
    for (int i = 1; i <= n; i++) {
        for (int w = 1; w <= capacity; w++) {
            if (weights[i-1] <= w) {
                dp[i][w] = max(dp[i-1][w], 
                               dp[i-1][w - weights[i-1]] + values[i-1]);
            } else {
                dp[i][w] = dp[i-1][w];
            }
        }
    }
    return dp[n][capacity];
}

// ============ COIN CHANGE ============
int coinChange(vector<int>& coins, int amount) {
    vector<int> dp(amount + 1, amount + 1);
    dp[0] = 0;
    
    for (int i = 1; i <= amount; i++) {
        for (int coin : coins) {
            if (coin <= i) {
                dp[i] = min(dp[i], dp[i - coin] + 1);
            }
        }
    }
    return dp[amount] > amount ? -1 : dp[amount];
}
```

---

## Week 12-14: Graph Algorithms (50 Problems)

### Core Concepts
- DFS & BFS on Graphs
- Union Find (Disjoint Set)
- Topological Sort
- Shortest Path (Dijkstra)

### Medium (40 Problems)

- [ ] [133. Clone Graph](https://leetcode.com/problems/clone-graph/) ⭐
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) ⭐⭐⭐
- [ ] [207. Course Schedule](https://leetcode.com/problems/course-schedule/) ⭐⭐
- [ ] [210. Course Schedule II](https://leetcode.com/problems/course-schedule-ii/) ⭐
- [ ] [547. Number of Provinces](https://leetcode.com/problems/number-of-provinces/) ⭐
- [ ] [684. Redundant Connection](https://leetcode.com/problems/redundant-connection/) ⭐
- [ ] [695. Max Area of Island](https://leetcode.com/problems/max-area-of-island/) ⭐
- [ ] [743. Network Delay Time](https://leetcode.com/problems/network-delay-time/) ⭐
- [ ] [785. Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/) ⭐
- [ ] [994. Rotting Oranges](https://leetcode.com/problems/rotting-oranges/) ⭐⭐

### Hard (10 Problems)

- [ ] [127. Word Ladder](https://leetcode.com/problems/word-ladder/) ⭐⭐
- [ ] [1192. Critical Connections](https://leetcode.com/problems/critical-connections-in-a-network/) ⭐

### 💡 C++ Patterns: Graphs

```cpp
#include <vector>
#include <queue>
#include <unordered_set>
using namespace std;

// ============ DFS ON GRAPH ============
void dfs(int node, vector<vector<int>>& graph, vector<bool>& visited) {
    if (visited[node]) return;
    visited[node] = true;
    for (int neighbor : graph[node]) {
        dfs(neighbor, graph, visited);
    }
}

// ============ BFS ON GRAPH ============
void bfs(int start, vector<vector<int>>& graph) {
    queue<int> q;
    unordered_set<int> visited;
    q.push(start);
    visited.insert(start);
    
    while (!q.empty()) {
        int node = q.front(); q.pop();
        for (int neighbor : graph[node]) {
            if (!visited.count(neighbor)) {
                visited.insert(neighbor);
                q.push(neighbor);
            }
        }
    }
}

// ============ UNION FIND ============
class UnionFind {
public:
    vector<int> parent, rank_;
    
    UnionFind(int n) : parent(n), rank_(n, 0) {
        for (int i = 0; i < n; i++) parent[i] = i;
    }
    
    int find(int x) {
        if (parent[x] != x) parent[x] = find(parent[x]); // Path compression
        return parent[x];
    }
    
    bool unite(int x, int y) { // Union by rank
        int px = find(x), py = find(y);
        if (px == py) return false;
        if (rank_[px] < rank_[py]) swap(px, py);
        parent[py] = px;
        if (rank_[px] == rank_[py]) rank_[px]++;
        return true;
    }
};

// ============ TOPOLOGICAL SORT (Kahn's) ============
vector<int> topologicalSort(int n, vector<pair<int,int>>& edges) {
    vector<vector<int>> graph(n);
    vector<int> indegree(n, 0);
    
    for (auto& [u, v] : edges) {
        graph[u].push_back(v);
        indegree[v]++;
    }
    
    queue<int> q;
    for (int i = 0; i < n; i++) {
        if (indegree[i] == 0) q.push(i);
    }
    
    vector<int> result;
    while (!q.empty()) {
        int node = q.front(); q.pop();
        result.push_back(node);
        for (int neighbor : graph[node]) {
            if (--indegree[neighbor] == 0) q.push(neighbor);
        }
    }
    return result.size() == n ? result : vector<int>(); // Cycle check
}

// ============ DIJKSTRA'S ALGORITHM ============
vector<int> dijkstra(int n, vector<vector<pair<int,int>>>& graph, int start) {
    vector<int> dist(n, INT_MAX);
    priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;
    
    dist[start] = 0;
    pq.push({0, start});
    
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (d > dist[u]) continue;
        
        for (auto [v, w] : graph[u]) {
            if (dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                pq.push({dist[v], v});
            }
        }
    }
    return dist;
}
```

---

## Week 14: Backtracking & Recursion (30 Problems)

### Medium (25 Problems)

- [ ] [17. Letter Combinations](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) ⭐
- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) ⭐⭐
- [ ] [39. Combination Sum](https://leetcode.com/problems/combination-sum/) ⭐⭐
- [ ] [40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/)
- [ ] [46. Permutations](https://leetcode.com/problems/permutations/) ⭐⭐⭐
- [ ] [47. Permutations II](https://leetcode.com/problems/permutations-ii/)
- [ ] [78. Subsets](https://leetcode.com/problems/subsets/) ⭐⭐⭐
- [ ] [90. Subsets II](https://leetcode.com/problems/subsets-ii/)
- [ ] [77. Combinations](https://leetcode.com/problems/combinations/)
- [ ] [79. Word Search](https://leetcode.com/problems/word-search/) ⭐⭐
- [ ] [131. Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) ⭐

### Hard (5 Problems)

- [ ] [37. Sudoku Solver](https://leetcode.com/problems/sudoku-solver/) ⭐⭐
- [ ] [51. N-Queens](https://leetcode.com/problems/n-queens/) ⭐⭐⭐
- [ ] [212. Word Search II](https://leetcode.com/problems/word-search-ii/) ⭐⭐

### 💡 C++ Patterns: Backtracking

```cpp
#include <vector>
using namespace std;

// ============ GENERAL BACKTRACKING TEMPLATE ============
class Solution {
    vector<vector<int>> result;
    
    void backtrack(vector<int>& path, vector<int>& choices) {
        if (isSolution(path)) {
            result.push_back(path);
            return;
        }
        for (int choice : choices) {
            path.push_back(choice);    // Make choice
            backtrack(path, choices);   // Recurse
            path.pop_back();           // Undo choice
        }
    }
};

// ============ PERMUTATIONS ============
void permute(vector<int>& nums, vector<int>& path, 
             vector<bool>& used, vector<vector<int>>& result) {
    if (path.size() == nums.size()) {
        result.push_back(path);
        return;
    }
    for (int i = 0; i < nums.size(); i++) {
        if (used[i]) continue;
        used[i] = true;
        path.push_back(nums[i]);
        permute(nums, path, used, result);
        path.pop_back();
        used[i] = false;
    }
}

// ============ SUBSETS ============
void subsets(vector<int>& nums, int start, 
             vector<int>& path, vector<vector<int>>& result) {
    result.push_back(path);  // Every path is a valid subset
    for (int i = start; i < nums.size(); i++) {
        path.push_back(nums[i]);
        subsets(nums, i + 1, path, result);
        path.pop_back();
    }
}

// ============ COMBINATION SUM ============
void combinationSum(vector<int>& candidates, int target, int start,
                    vector<int>& path, vector<vector<int>>& result) {
    if (target == 0) {
        result.push_back(path);
        return;
    }
    if (target < 0) return;
    
    for (int i = start; i < candidates.size(); i++) {
        path.push_back(candidates[i]);
        combinationSum(candidates, target - candidates[i], i, path, result);
        path.pop_back();
    }
}
```

---

# 📕 Phase 3: Advanced Topics (Weeks 15-20)

## Week 15-16: Advanced DP (40 Problems)

### Hard Problems

- [ ] [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/) ⭐⭐⭐
- [ ] [72. Edit Distance](https://leetcode.com/problems/edit-distance/) ⭐⭐⭐
- [ ] [123. Best Time to Buy and Sell Stock III](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/) ⭐
- [ ] [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/) ⭐⭐
- [ ] [312. Burst Balloons](https://leetcode.com/problems/burst-balloons/) ⭐⭐

---

## Week 17-18: Binary Search Advanced (35 Problems)

### Medium (20 Problems)

- [ ] [33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/) ⭐⭐⭐
- [ ] [34. Find First and Last Position](https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/) ⭐⭐
- [ ] [74. Search a 2D Matrix](https://leetcode.com/problems/search-a-2d-matrix/) ⭐
- [ ] [153. Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/) ⭐⭐
- [ ] [162. Find Peak Element](https://leetcode.com/problems/find-peak-element/) ⭐
- [ ] [287. Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/) ⭐⭐

### Hard (15 Problems)

- [ ] [4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/) ⭐⭐⭐

### 💡 C++ Patterns: Binary Search

```cpp
#include <vector>
using namespace std;

// ============ CLASSIC BINARY SEARCH ============
int binarySearch(vector<int>& arr, int target) {
    int left = 0, right = arr.size() - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;  // Avoid overflow
        if (arr[mid] == target) return mid;
        else if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

// ============ FIND LEFTMOST (lower_bound) ============
int findFirst(vector<int>& arr, int target) {
    int left = 0, right = arr.size();
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] < target) left = mid + 1;
        else right = mid;
    }
    return left;
}

// ============ SEARCH ON ANSWER ============
// Find smallest x where predicate(x) is true
int searchOnAnswer(int lo, int hi, function<bool(int)> predicate) {
    while (lo < hi) {
        int mid = lo + (hi - lo) / 2;
        if (predicate(mid)) hi = mid;
        else lo = mid + 1;
    }
    return lo;
}
```

---

## Week 19-20: Heaps, Trie & Advanced DS (40 Problems)

### Heaps (20 Problems)

- [ ] [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) ⭐⭐⭐
- [ ] [215. Kth Largest Element](https://leetcode.com/problems/kth-largest-element-in-an-array/) ⭐⭐
- [ ] [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/) ⭐⭐⭐
- [ ] [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) ⭐
- [ ] [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) ⭐

### Trie (20 Problems)

- [ ] [208. Implement Trie](https://leetcode.com/problems/implement-trie-prefix-tree/) ⭐⭐⭐
- [ ] [211. Add and Search Words](https://leetcode.com/problems/design-add-and-search-words-data-structure/) ⭐⭐
- [ ] [212. Word Search II](https://leetcode.com/problems/word-search-ii/) ⭐⭐⭐

### 💡 C++ Patterns: Heap & Trie

```cpp
#include <queue>
#include <unordered_map>
using namespace std;

// ============ MIN HEAP (default in C++) ============
priority_queue<int, vector<int>, greater<int>> minHeap;

// ============ MAX HEAP ============
priority_queue<int> maxHeap;

// ============ CUSTOM COMPARATOR ============
auto cmp = [](pair<int,int>& a, pair<int,int>& b) {
    return a.first > b.first;  // Min heap by first element
};
priority_queue<pair<int,int>, vector<pair<int,int>>, decltype(cmp)> pq(cmp);

// ============ TRIE IMPLEMENTATION ============
class Trie {
    struct TrieNode {
        unordered_map<char, TrieNode*> children;
        bool isEnd = false;
    };
    TrieNode* root;
    
public:
    Trie() : root(new TrieNode()) {}
    
    void insert(string word) {
        TrieNode* node = root;
        for (char c : word) {
            if (!node->children.count(c)) {
                node->children[c] = new TrieNode();
            }
            node = node->children[c];
        }
        node->isEnd = true;
    }
    
    bool search(string word) {
        TrieNode* node = root;
        for (char c : word) {
            if (!node->children.count(c)) return false;
            node = node->children[c];
        }
        return node->isEnd;
    }
    
    bool startsWith(string prefix) {
        TrieNode* node = root;
        for (char c : prefix) {
            if (!node->children.count(c)) return false;
            node = node->children[c];
        }
        return true;
    }
};
```

---

# 📙 Phase 4: Mock Interviews (Weeks 21-24)

## FAANG Company Focus

### Meta/Facebook Favorites
- [ ] [56. Merge Intervals](https://leetcode.com/problems/merge-intervals/) ⭐⭐
- [ ] [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) ⭐⭐⭐
- [ ] [146. LRU Cache](https://leetcode.com/problems/lru-cache/) ⭐⭐⭐
- [ ] [380. Insert Delete GetRandom O(1)](https://leetcode.com/problems/insert-delete-getrandom-o1/)

### Google Favorites
- [ ] [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)
- [ ] [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)

### Amazon Favorites
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
- [ ] [937. Reorder Data in Log Files](https://leetcode.com/problems/reorder-data-in-log-files/)

---

# 📚 Resources & Tips

## 🔥 Success Tips

1. **Consistency > Intensity** - Solve 2-3 problems daily, not 20 in one day
2. **30-Minute Rule** - If stuck for 30 minutes, look at the solution
3. **Review Weekly** - Revisit solved problems after a week
4. **Code It Yourself** - Don't just read solutions

## 📊 Weekly Tracking Template

| Week | Topic | Target | Solved | Easy | Medium | Hard |
|------|-------|--------|--------|------|--------|------|
| 1 | Arrays | 15 | 0 | 0 | 0 | 0 |
| 2 | Strings | 20 | 0 | 0 | 0 | 0 |

## 🎓 Top Resources

**YouTube:**
- [NeetCode](https://www.youtube.com/@NeetCode) - Best for LeetCode
- [Abdul Bari](https://www.youtube.com/@abdul_bari) - Algorithms

**Websites:**
- [NeetCode.io](https://neetcode.io/) - Roadmap + Videos
- [LeetCode Patterns](https://seanprashad.com/leetcode-patterns/)

---

## ✅ Weekly Checklist

- [ ] Solved target problems for the week
- [ ] Reviewed 5+ old problems
- [ ] Understood core patterns
- [ ] Wrote notes on common pitfalls
- [ ] Solved 1 problem without any help

---

> **Remember:** This roadmap is ambitious (550 problems in 6 months). Even 300-400 quality solves is better than 550 rushed ones. **Consistency matters most!** 🚀
