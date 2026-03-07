---
title: Problem Solving Roadmap
created: 2026-01-07
tags:
  - leetcode
  - dsa
  - interview-prep
  - algorithms
  - competitive-programming
status: in-progress
total_problems: 550
solved: 0
current_week: 1
---

# خطة Problem Solving الشاملة: من Zero إلى Hero (550+ مسألة)

## 📊 الإحصائيات والتوزيع الزمني

|المرحلة|المدة|عدد المسائل|المسائل/اليوم|الصعوبة|
|---|---|---|---|---|
|**Phase 1: Foundations**|6 أسابيع|100 مسألة|2-3 مسائل|Easy + بعض Medium|
|**Phase 2: Core Patterns**|8 أسابيع|200 مسألة|3-4 مسائل|Medium أساساً|
|**Phase 3: Advanced Topics**|6 أسابيع|150 مسألة|3-4 مسائل|Medium + Hard|
|**Phase 4: Mock Interviews**|4 أسابيع|100 مسألة|3-4 مسائل|Mixed|

**المجموع: 550 مسألة في 24 أسبوع = 6 شهور**

---

## 📈 Progress Tracking

| Week | Topic | Target | Solved | Date Started | Date Completed | Notes |
|------|-------|--------|--------|--------------|----------------|-------|
| 1 | Arrays | 15 | 0 | | | |
| 2 | Strings | 20 | 0 | | | |
| 3 | Linked Lists | 20 | 0 | | | |
| 4 | Stack | 12 | 0 | | | |
| 5 | Queue | 13 | 0 | | | |
| 6 | Hash Tables | 20 | 0 | | | |
| 7-9 | Binary Trees | 50 | 0 | | | |
| 10-11 | Dynamic Programming | 40 | 0 | | | |
| 12-14 | Graphs | 50 | 0 | | | |
| 14 | Backtracking | 30 | 0 | | | |
| 15-16 | Advanced DP | 40 | 0 | | | |
| 17-18 | Binary Search | 35 | 0 | | | |
| 19-20 | Heaps & Trie | 40 | 0 | | | |
| 20 | Bit Manipulation | 35 | 0 | | | |
| 21-24 | Mock Interviews | 100 | 0 | | | |

---

## 🧠 Pattern Recognition Guide

> **متى تستخدم إيه؟ Quick mental shortcuts**

| Problem Says... | Think About... |
|----------------|----------------|
| "Find pair/triplet..." | Two Pointers or HashMap |
| "Subarray with sum..." | Sliding Window or Prefix Sum |
| "Sorted array..." | Binary Search or Two Pointers |
| "Shortest path..." | BFS |
| "All possible combinations..." | Backtracking |
| "Minimum/Maximum..." | DP or Greedy |
| "Connected components..." | Union Find or DFS |
| "Top K elements..." | Heap |
| "Prefix matching..." | Trie |
| "Detect cycle..." | Fast & Slow Pointers |

---

## ⏱️ Time Complexity Cheat Sheet

| Pattern | Time | Space | Best For |
|---------|------|-------|----------|
| Two Pointers | O(n) | O(1) | Sorted arrays, pairs |
| Sliding Window | O(n) | O(k) | Subarray/substring |
| Binary Search | O(log n) | O(1) | Sorted data, search on answer |
| BFS | O(V+E) | O(V) | Shortest path, level-by-level |
| DFS | O(V+E) | O(H) | Explore all paths, backtracking |
| Dynamic Programming | O(n²) or O(n×m) | O(n) or O(n×m) | Optimization problems |
| Union Find | O(α(n)) ≈ O(1) | O(n) | Connected components |
| Heap Operations | O(log n) | O(n) | Priority-based selection |
| Trie Operations | O(L) | O(ALPHABET×L×N) | Prefix matching |

---

## 🎯 Phase 1: Foundations (Weeks 1-6) - 100 Problems

### الهدف: بناء الأساسيات + العادات الصحيحة

---

### **Week 1-2: Arrays & Strings (35 مسألة)**

#### 🔑 Core Concepts:

- Two Pointers Technique
- Sliding Window
- Prefix Sum
- In-place manipulation

#### 📝 Must-Solve Problems:

**Arrays - Easy (15 مسائل):**

- [x] [1. Two Sum](https://leetcode.com/problems/two-sum/) ⭐ (أهم مسألة للمبتدئين)
- [x] [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
- [x] [27. Remove Element](https://leetcode.com/problems/remove-element/)
- [x] [66. Plus One](https://leetcode.com/problems/plus-one/)
- [ ] [88. Merge Sorted Array](https://leetcode.com/problems/merge-sorted-array/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/) ⭐
- [ ] [122. Best Time to Buy and Sell Stock II](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/)
- [ ] [217. Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)
- [ ] [268. Missing Number](https://leetcode.com/problems/missing-number/)
- [ ] [283. Move Zeroes](https://leetcode.com/problems/move-zeroes/)
- [ ] [448. Find All Numbers Disappeared in an Array](https://leetcode.com/problems/find-all-numbers-disappeared-in-an-array/)
- [ ] [485. Max Consecutive Ones](https://leetcode.com/problems/max-consecutive-ones/)
- [ ] [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
- [ ] [561. Array Partition](https://leetcode.com/problems/array-partition/)
- [ ] [1929. Concatenation of Array](https://leetcode.com/problems/concatenation-of-array/)

**Strings - Easy (10 مسائل):**

- [ ] [14. Longest Common Prefix](https://leetcode.com/problems/longest-common-prefix/)
- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) ⭐ (مهمة جداً)
- [ ] [28. Find the Index of the First Occurrence](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/)
- [ ] [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/) ⭐
- [ ] [242. Valid Anagram](https://leetcode.com/problems/valid-anagram/) ⭐
- [ ] [344. Reverse String](https://leetcode.com/problems/reverse-string/)
- [ ] [387. First Unique Character in a String](https://leetcode.com/problems/first-unique-character-in-a-string/)
- [ ] [392. Is Subsequence](https://leetcode.com/problems/is-subsequence/)
- [ ] [409. Longest Palindrome](https://leetcode.com/problems/longest-palindrome/)
- [ ] [771. Jewels and Stones](https://leetcode.com/problems/jewels-and-stones/)

**Arrays/Strings - Medium (10 مسائل):**

- [ ] [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) ⭐⭐
- [ ] [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/) ⭐
- [ ] [15. 3Sum](https://leetcode.com/problems/3sum/) ⭐⭐ (مهمة للـ interviews)
- [ ] [49. Group Anagrams](https://leetcode.com/problems/group-anagrams/) ⭐
- [ ] [75. Sort Colors](https://leetcode.com/problems/sort-colors/) (Dutch Flag Problem)
- [ ] [167. Two Sum II](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)
- [ ] [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/)
- [ ] [238. Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/) ⭐⭐
- [ ] [443. String Compression](https://leetcode.com/problems/string-compression/)
- [ ] [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) ⭐

#### 💡 Tips & Tricks:

```python
# Two Pointers Pattern:
# استخدمه لما يكون الـ array sorted أو محتاج تقارن elements من الطرفين
def two_pointers_example(arr, target):
    left, right = 0, len(arr) - 1
    while left < right:
        current_sum = arr[left] + arr[right]
        if current_sum == target:
            return [left, right]
        elif current_sum < target:
            left += 1
        else:
            right -= 1

# Sliding Window Pattern:
# لما المسألة تطلب "subarray" أو "substring" 
def sliding_window_example(s):
    window = set()
    left = 0
    max_length = 0
    
    for right in range(len(s)):
        while s[right] in window:
            window.remove(s[left])
            left += 1
        window.add(s[right])
        max_length = max(max_length, right - left + 1)
    
    return max_length

# HashMap للـ frequency counting:
from collections import Counter
def frequency_pattern(arr):
    freq = Counter(arr)
    # freq = {} بديل يدوي
    # for num in arr:
    #     freq[num] = freq.get(num, 0) + 1
    return freq
```

---

### **Week 3: Linked Lists (20 مسألة)**

#### 🔑 Core Concepts:

- Fast & Slow Pointers (Floyd's Cycle Detection)
- Reversal Technique
- Dummy Node Trick

#### 📝 Must-Solve Problems:

**Linked List - Easy (12 مسائل):**

- [ ] [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/) ⭐
- [ ] [83. Remove Duplicates from Sorted List](https://leetcode.com/problems/remove-duplicates-from-sorted-list/)
- [ ] [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/) ⭐ (Fast & Slow Pointers)
- [ ] [160. Intersection of Two Linked Lists](https://leetcode.com/problems/intersection-of-two-linked-lists/)
- [ ] [203. Remove Linked List Elements](https://leetcode.com/problems/remove-linked-list-elements/)
- [ ] [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) ⭐⭐ (لازم تحفظها)
- [ ] [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)
- [ ] [237. Delete Node in a Linked List](https://leetcode.com/problems/delete-node-in-a-linked-list/)
- [ ] [876. Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/) ⭐
- [ ] [1290. Convert Binary Number in a Linked List to Integer](https://leetcode.com/problems/convert-binary-number-in-a-linked-list-to-integer/)
- [ ] [2181. Merge Nodes in Between Zeros](https://leetcode.com/problems/merge-nodes-in-between-zeros/)
- [ ] [2130. Maximum Twin Sum of a Linked List](https://leetcode.com/problems/maximum-twin-sum-of-a-linked-list/)

**Linked List - Medium (8 مسائل):**

- [ ] [2. Add Two Numbers](https://leetcode.com/problems/add-two-numbers/) ⭐
- [ ] [19. Remove Nth Node From End of List](https://leetcode.com/problems/remove-nth-node-from-end-of-list/) ⭐
- [ ] [24. Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/)
- [ ] [61. Rotate List](https://leetcode.com/problems/rotate-list/)
- [ ] [82. Remove Duplicates from Sorted List II](https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/)
- [ ] [92. Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/) ⭐
- [ ] [143. Reorder List](https://leetcode.com/problems/reorder-list/) ⭐⭐
- [ ] [148. Sort List](https://leetcode.com/problems/sort-list/) (Merge Sort على Linked List)

#### 💡 Tips & Tricks:

```python
# Dummy Node Pattern:
def merge_sorted_lists(l1, l2):
    dummy = ListNode(0)
    current = dummy
    
    while l1 and l2:
        if l1.val < l2.val:
            current.next = l1
            l1 = l1.next
        else:
            current.next = l2
            l2 = l2.next
        current = current.next
    
    current.next = l1 or l2
    return dummy.next  # مش dummy نفسه!

# Fast & Slow Pointers (Tortoise & Hare):
def find_middle(head):
    slow = fast = head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
    return slow  # slow هيبقى في الـ middle

# Reversal Template (احفظه كويس):
def reverse_linked_list(head):
    prev = None
    curr = head
    while curr:
        next_temp = curr.next  # حفظ الـ next
        curr.next = prev       # عكس الاتجاه
        prev = curr            # تحريك prev
        curr = next_temp       # تحريك curr
    return prev
```

---

### **Week 4-5: Stack & Queue (25 مسألة)**

#### 🔑 Core Concepts:

- Monotonic Stack
- Expression Evaluation
- BFS using Queue

#### 📝 Must-Solve Problems:

**Stack - Easy (10 مسائل):**

- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) ⭐⭐ (أهم مسألة Stack)
- [ ] [155. Min Stack](https://leetcode.com/problems/min-stack/) ⭐
- [ ] [225. Implement Stack using Queues](https://leetcode.com/problems/implement-stack-using-queues/)
- [ ] [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/)
- [ ] [496. Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/)
- [ ] [682. Baseball Game](https://leetcode.com/problems/baseball-game/)
- [ ] [844. Backspace String Compare](https://leetcode.com/problems/backspace-string-compare/)
- [ ] [1021. Remove Outermost Parentheses](https://leetcode.com/problems/remove-outermost-parentheses/)
- [ ] [1614. Maximum Nesting Depth of the Parentheses](https://leetcode.com/problems/maximum-nesting-depth-of-the-parentheses/)
- [ ] [2390. Removing Stars From a String](https://leetcode.com/problems/removing-stars-from-a-string/)

**Stack - Medium (10 مسائل):**

- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) ⭐
- [ ] [71. Simplify Path](https://leetcode.com/problems/simplify-path/)
- [ ] [150. Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/) ⭐
- [ ] [224. Basic Calculator](https://leetcode.com/problems/basic-calculator/)
- [ ] [227. Basic Calculator II](https://leetcode.com/problems/basic-calculator-ii/)
- [ ] [394. Decode String](https://leetcode.com/problems/decode-string/) ⭐
- [ ] [503. Next Greater Element II](https://leetcode.com/problems/next-greater-element-ii/)
- [ ] [735. Asteroid Collision](https://leetcode.com/problems/asteroid-collision/)
- [ ] [739. Daily Temperatures](https://leetcode.com/problems/daily-temperatures/) ⭐ (Monotonic Stack)
- [ ] [853. Car Fleet](https://leetcode.com/problems/car-fleet/)

**Queue - Medium (5 مسائل):**

- [ ] [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)
- [ ] [102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) ⭐
- [ ] [127. Word Ladder](https://leetcode.com/problems/word-ladder/)
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) ⭐⭐ (BFS approach)
- [ ] [542. 01 Matrix](https://leetcode.com/problems/01-matrix/)

#### 💡 Tips & Tricks:

```python
# Monotonic Stack Pattern (للـ next greater/smaller):
def next_greater_elements(nums):
    result = [-1] * len(nums)
    stack = []  # stack of indices
    
    for i in range(len(nums)):
        while stack and nums[stack[-1]] < nums[i]:
            idx = stack.pop()
            result[idx] = nums[i]
        stack.append(i)
    
    return result

# Valid Parentheses Template:
def is_valid_parentheses(s):
    stack = []
    mapping = {')': '(', '}': '{', ']': '['}
    
    for char in s:
        if char in mapping:
            top = stack.pop() if stack else '#'
            if mapping[char] != top:
                return False
        else:
            stack.append(char)
    
    return not stack

# BFS Template (للـ Queue):
from collections import deque

def bfs(start):
    queue = deque([start])
    visited = {start}
    
    while queue:
        node = queue.popleft()
        # Process node
        
        for neighbor in get_neighbors(node):
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
```

---

### **Week 6: Hash Tables & Sets (20 مسألة)**

#### 📝 Must-Solve Problems:

**Hash Table - Easy (10 مسائل):**

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/) ⭐⭐ (راجعها تاني)
- [ ] [136. Single Number](https://leetcode.com/problems/single-number/) (XOR trick)
- [ ] [217. Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)
- [ ] [219. Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/)
- [ ] [242. Valid Anagram](https://leetcode.com/problems/valid-anagram/)
- [ ] [383. Ransom Note](https://leetcode.com/problems/ransom-note/)
- [ ] [387. First Unique Character in a String](https://leetcode.com/problems/first-unique-character-in-a-string/)
- [ ] [389. Find the Difference](https://leetcode.com/problems/find-the-difference/)
- [ ] [645. Set Mismatch](https://leetcode.com/problems/set-mismatch/)
- [ ] [1207. Unique Number of Occurrences](https://leetcode.com/problems/unique-number-of-occurrences/)

**Hash Table - Medium (10 مسائل):**

- [ ] [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) ⭐
- [ ] [36. Valid Sudoku](https://leetcode.com/problems/valid-sudoku/)
- [ ] [49. Group Anagrams](https://leetcode.com/problems/group-anagrams/) ⭐
- [ ] [128. Longest Consecutive Sequence](https://leetcode.com/problems/longest-consecutive-sequence/) ⭐⭐
- [ ] [187. Repeated DNA Sequences](https://leetcode.com/problems/repeated-dna-sequences/)
- [ ] [205. Isomorphic Strings](https://leetcode.com/problems/isomorphic-strings/)
- [ ] [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) ⭐
- [ ] [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/)
- [ ] [454. 4Sum II](https://leetcode.com/problems/4sum-ii/)
- [ ] [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) ⭐

#### 💡 Tips & Tricks:

```python
# HashMap للـ Two Sum Pattern:
def two_sum(nums, target):
    seen = {}  # {value: index}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            return [seen[complement], i]
        seen[num] = i

# Counter للـ Frequency Analysis:
from collections import Counter

def top_k_frequent(nums, k):
    count = Counter(nums)
    # استخدم most_common أو heap
    return [num for num, freq in count.most_common(k)]

# Set للـ O(1) lookup:
def longest_consecutive(nums):
    num_set = set(nums)
    max_length = 0
    
    for num in num_set:
        # ابدأ sequence بس لو ده أول عنصر
        if num - 1 not in num_set:
            current = num
            length = 1
            
            while current + 1 in num_set:
                current += 1
                length += 1
            
            max_length = max(max_length, length)
    
    return max_length
```

---

## 🚀 Phase 2: Core Patterns (Weeks 7-14) - 200 Problems

### **Week 7-9: Binary Trees (50 مسألة)**

#### 🔑 Core Concepts:

- DFS (PreOrder, InOrder, PostOrder)
- BFS (Level Order)
- Lowest Common Ancestor
- Path Sum Problems

#### 📝 Must-Solve Problems:

**Binary Trees - Easy (20 مسائل):**

- [ ] [94. Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/)
- [ ] [100. Same Tree](https://leetcode.com/problems/same-tree/)
- [ ] [101. Symmetric Tree](https://leetcode.com/problems/symmetric-tree/)
- [ ] [104. Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/) ⭐
- [ ] [108. Convert Sorted Array to Binary Search Tree](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/)
- [ ] [110. Balanced Binary Tree](https://leetcode.com/problems/balanced-binary-tree/)
- [ ] [111. Minimum Depth of Binary Tree](https://leetcode.com/problems/minimum-depth-of-binary-tree/)
- [ ] [112. Path Sum](https://leetcode.com/problems/path-sum/)
- [ ] [144. Binary Tree Preorder Traversal](https://leetcode.com/problems/binary-tree-preorder-traversal/)
- [ ] [145. Binary Tree Postorder Traversal](https://leetcode.com/problems/binary-tree-postorder-traversal/)
- [ ] [226. Invert Binary Tree](https://leetcode.com/problems/invert-binary-tree/) ⭐
- [ ] [235. Lowest Common Ancestor of a BST](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/) ⭐
- [ ] [257. Binary Tree Paths](https://leetcode.com/problems/binary-tree-paths/)
- [ ] [404. Sum of Left Leaves](https://leetcode.com/problems/sum-of-left-leaves/)
- [ ] [543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/) ⭐
- [ ] [572. Subtree of Another Tree](https://leetcode.com/problems/subtree-of-another-tree/)
- [ ] [617. Merge Two Binary Trees](https://leetcode.com/problems/merge-two-binary-trees/)
- [ ] [637. Average of Levels in Binary Tree](https://leetcode.com/problems/average-of-levels-in-binary-tree/)
- [ ] [653. Two Sum IV - Input is a BST](https://leetcode.com/problems/two-sum-iv-input-is-a-bst/)
- [ ] [700. Search in a Binary Search Tree](https://leetcode.com/problems/search-in-a-binary-search-tree/)

**Binary Trees - Medium (30 مسألة):**

- [ ] [98. Validate Binary Search Tree](https://leetcode.com/problems/validate-binary-search-tree/) ⭐⭐
- [ ] [102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) ⭐
- [ ] [103. Binary Tree Zigzag Level Order Traversal](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
- [ ] [105. Construct Binary Tree from Preorder and Inorder](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/) ⭐
- [ ] [106. Construct Binary Tree from Inorder and Postorder](https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
- [ ] [113. Path Sum II](https://leetcode.com/problems/path-sum-ii/)
- [ ] [114. Flatten Binary Tree to Linked List](https://leetcode.com/problems/flatten-binary-tree-to-linked-list/)
- [ ] [116. Populating Next Right Pointers](https://leetcode.com/problems/populating-next-right-pointers-in-each-node/)
- [ ] [117. Populating Next Right Pointers II](https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/)
- [ ] [129. Sum Root to Leaf Numbers](https://leetcode.com/problems/sum-root-to-leaf-numbers/)
- [ ] [199. Binary Tree Right Side View](https://leetcode.com/problems/binary-tree-right-side-view/) ⭐
- [ ] [230. Kth Smallest Element in a BST](https://leetcode.com/problems/kth-smallest-element-in-a-bst/) ⭐
- [ ] [236. Lowest Common Ancestor of a Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) ⭐⭐
- [ ] [337. House Robber III](https://leetcode.com/problems/house-robber-iii/)
- [ ] [450. Delete Node in a BST](https://leetcode.com/problems/delete-node-in-a-bst/)
- [ ] [513. Find Bottom Left Tree Value](https://leetcode.com/problems/find-bottom-left-tree-value/)
- [ ] [515. Find Largest Value in Each Tree Row](https://leetcode.com/problems/find-largest-value-in-each-tree-row/)
- [ ] [538. Convert BST to Greater Tree](https://leetcode.com/problems/convert-bst-to-greater-tree/)
- [ ] [662. Maximum Width of Binary Tree](https://leetcode.com/problems/maximum-width-of-binary-tree/)
- [ ] [863. All Nodes Distance K in Binary Tree](https://leetcode.com/problems/all-nodes-distance-k-in-binary-tree/)
- [ ] [889. Construct Binary Tree from Preorder and Postorder](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-postorder-traversal/)
- [ ] [894. All Possible Full Binary Trees](https://leetcode.com/problems/all-possible-full-binary-trees/)
- [ ] [951. Flip Equivalent Binary Trees](https://leetcode.com/problems/flip-equivalent-binary-trees/)
- [ ] [958. Check Completeness of a Binary Tree](https://leetcode.com/problems/check-completeness-of-a-binary-tree/)
- [ ] [979. Distribute Coins in Binary Tree](https://leetcode.com/problems/distribute-coins-in-binary-tree/)
- [ ] [987. Vertical Order Traversal](https://leetcode.com/problems/vertical-order-traversal-of-a-binary-tree/)
- [ ] [1008. Construct BST from Preorder](https://leetcode.com/problems/construct-binary-search-tree-from-preorder-traversal/)
- [ ] [1026. Maximum Difference Between Node and Ancestor](https://leetcode.com/problems/maximum-difference-between-node-and-ancestor/)
- [ ] [1130. Minimum Cost Tree From Leaf Values](https://leetcode.com/problems/minimum-cost-tree-from-leaf-values/)
- [ ] [1325. Delete Leaves With a Given Value](https://leetcode.com/problems/delete-leaves-with-a-given-value/)

#### 💡 Tips & Tricks:

```python
# DFS Templates (الـ 3 أنواع):

# 1. PreOrder (Root → Left → Right):
def preorder(root):
    if not root:
        return []
    return [root.val] + preorder(root.left) + preorder(root.right)

# 2. InOrder (Left → Root → Right) - مهم للـ BST:
def inorder(root):
    if not root:
        return []
    return inorder(root.left) + [root.val] + inorder(root.right)

# 3. PostOrder (Left → Right → Root):
def postorder(root):
    if not root:
        return []
    return postorder(root.left) + postorder(root.right) + [root.val]

# BFS (Level Order) Template:
from collections import deque

def level_order(root):
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        level = []
        
        for _ in range(level_size):
            node = queue.popleft()
            level.append(node.val)
            
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        
        result.append(level)
    
    return result

# Lowest Common Ancestor Pattern:
def lca(root, p, q):
    if not root or root == p or root == q:
        return root
    
    left = lca(root.left, p, q)
    right = lca(root.right, p, q)
    
    if left and right:
        return root
    return left or right
```

---

### **Week 10-11: Dynamic Programming - Basics (40 مسألة)**

#### 🔑 Core Concepts:

- 1D DP (Fibonacci-like)
- 2D DP (Grid problems)
- Kadane's Algorithm
- Knapsack variants

#### 📝 Must-Solve Problems:

**DP - Easy (15 مسائل):**

- [ ] [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) ⭐ (أول مسألة DP)
- [ ] [118. Pascal's Triangle](https://leetcode.com/problems/pascals-triangle/)
- [ ] [119. Pascal's Triangle II](https://leetcode.com/problems/pascals-triangle-ii/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)
- [ ] [338. Counting Bits](https://leetcode.com/problems/counting-bits/)
- [ ] [392. Is Subsequence](https://leetcode.com/problems/is-subsequence/)
- [ ] [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
- [ ] [746. Min Cost Climbing Stairs](https://leetcode.com/problems/min-cost-climbing-stairs/) ⭐
- [ ] [1137. N-th Tribonacci Number](https://leetcode.com/problems/n-th-tribonacci-number/)
- [ ] [1646. Get Maximum in Generated Array](https://leetcode.com/problems/get-maximum-in-generated-array/)
- [ ] [1025. Divisor Game](https://leetcode.com/problems/divisor-game/)

**DP - Medium (25 مسألة):**

- [ ] [5. Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) ⭐⭐
- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
- [ ] [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) ⭐⭐ (Kadane's)
- [ ] [62. Unique Paths](https://leetcode.com/problems/unique-paths/) ⭐
- [ ] [63. Unique Paths II](https://leetcode.com/problems/unique-paths-ii/)
- [ ] [64. Minimum Path Sum](https://leetcode.com/problems/minimum-path-sum/) ⭐
- [ ] [91. Decode Ways](https://leetcode.com/problems/decode-ways/) ⭐
- [ ] [96. Unique Binary Search Trees](https://leetcode.com/problems/unique-binary-search-trees/)
- [ ] [120. Triangle](https://leetcode.com/problems/triangle/)
- [ ] [139. Word Break](https://leetcode.com/problems/word-break/) ⭐⭐
- [ ] [152. Maximum Product Subarray](https://leetcode.com/problems/maximum-product-subarray/) ⭐
- [ ] [198. House Robber](https://leetcode.com/problems/house-robber/) ⭐⭐
- [ ] [213. House Robber II](https://leetcode.com/problems/house-robber-ii/)
- [ ] [221. Maximal Square](https://leetcode.com/problems/maximal-square/)
- [ ] [279. Perfect Squares](https://leetcode.com/problems/perfect-squares/)
- [ ] [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) ⭐⭐⭐
- [ ] [322. Coin Change](https://leetcode.com/problems/coin-change/) ⭐⭐⭐ (مهمة جداً)
- [ ] [343. Integer Break](https://leetcode.com/problems/integer-break/)
- [ ] [357. Count Numbers with Unique Digits](https://leetcode.com/problems/count-numbers-with-unique-digits/)
- [ ] [376. Wiggle Subsequence](https://leetcode.com/problems/wiggle-subsequence/)
- [ ] [413. Arithmetic Slices](https://leetcode.com/problems/arithmetic-slices/)
- [ ] [416. Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) ⭐ (Knapsack)
- [ ] [494. Target Sum](https://leetcode.com/problems/target-sum/) ⭐
- [ ] [516. Longest Palindromic Subsequence](https://leetcode.com/problems/longest-palindromic-subsequence/)
- [ ] [673. Number of Longest Increasing Subsequence](https://leetcode.com/problems/number-of-longest-increasing-subsequence/)

#### 💡 Tips & Tricks:

```python
# DP Template العام:
# 1. Define state: dp[i] يعني إيه؟
# 2. Find recurrence relation: dp[i] = f(dp[i-1], dp[i-2], ...)
# 3. Initialize base cases
# 4. Fill the dp array

# مثال: Fibonacci
def fib(n):
    if n <= 1:
        return n
    
    dp = [0] * (n + 1)
    dp[0], dp[1] = 0, 1
    
    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]
    
    return dp[n]

# Kadane's Algorithm (Maximum Subarray):
def max_subarray(nums):
    max_sum = current_sum = nums[0]
    
    for num in nums[1:]:
        current_sum = max(num, current_sum + num)
        max_sum = max(max_sum, current_sum)
    
    return max_sum

# 0/1 Knapsack Pattern:
def knapsack(weights, values, capacity):
    n = len(weights)
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]
    
    for i in range(1, n + 1):
        for w in range(1, capacity + 1):
            if weights[i-1] <= w:
                dp[i][w] = max(
                    dp[i-1][w],  # don't take item
                    dp[i-1][w - weights[i-1]] + values[i-1]  # take item
                )
            else:
                dp[i][w] = dp[i-1][w]
    
    return dp[n][capacity]

# Space Optimization (1D DP):
def climb_stairs(n):
    if n <= 2:
        return n
    
    prev2, prev1 = 1, 2
    
    for i in range(3, n + 1):
        current = prev1 + prev2
        prev2, prev1 = prev1, current
    
    return prev1
```

---

### **Week 12-14: Graph Algorithms (50 مسألة)**

#### 🔑 Core Concepts:

- DFS & BFS on Graphs
- Union Find (Disjoint Set)
- Topological Sort
- Shortest Path (Dijkstra, Bellman-Ford)

#### 📝 Must-Solve Problems:

**Graphs - Medium (40 مسائل):**

- [ ] [133. Clone Graph](https://leetcode.com/problems/clone-graph/) ⭐
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) ⭐⭐⭐ (أهم مسألة Graph)
- [ ] [207. Course Schedule](https://leetcode.com/problems/course-schedule/) ⭐⭐ (Topological Sort)
- [ ] [210. Course Schedule II](https://leetcode.com/problems/course-schedule-ii/) ⭐
- [ ] [261. Graph Valid Tree](https://leetcode.com/problems/graph-valid-tree/) (Premium)
- [ ] [269. Alien Dictionary](https://leetcode.com/problems/alien-dictionary/) (Premium)
- [ ] [310. Minimum Height Trees](https://leetcode.com/problems/minimum-height-trees/)
- [ ] [323. Number of Connected Components](https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/) (Premium)
- [ ] [332. Reconstruct Itinerary](https://leetcode.com/problems/reconstruct-itinerary/)
- [ ] [399. Evaluate Division](https://leetcode.com/problems/evaluate-division/)
- [ ] [417. Pacific Atlantic Water Flow](https://leetcode.com/problems/pacific-atlantic-water-flow/) ⭐
- [ ] [433. Minimum Genetic Mutation](https://leetcode.com/problems/minimum-genetic-mutation/)
- [ ] [490. The Maze](https://leetcode.com/problems/the-maze/) (Premium)
- [ ] [505. The Maze II](https://leetcode.com/problems/the-maze-ii/) (Premium)
- [ ] [547. Number of Provinces](https://leetcode.com/problems/number-of-provinces/) ⭐
- [ ] [582. Kill Process](https://leetcode.com/problems/kill-process/) (Premium)
- [ ] [684. Redundant Connection](https://leetcode.com/problems/redundant-connection/) ⭐ (Union Find)
- [ ] [685. Redundant Connection II](https://leetcode.com/problems/redundant-connection-ii/)
- [ ] [695. Max Area of Island](https://leetcode.com/problems/max-area-of-island/) ⭐
- [ ] [721. Accounts Merge](https://leetcode.com/problems/accounts-merge/) (Union Find)
- [ ] [743. Network Delay Time](https://leetcode.com/problems/network-delay-time/) ⭐ (Dijkstra)
- [ ] [752. Open the Lock](https://leetcode.com/problems/open-the-lock/)
- [ ] [785. Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/) ⭐
- [ ] [787. Cheapest Flights Within K Stops](https://leetcode.com/problems/cheapest-flights-within-k-stops/)
- [ ] [797. All Paths From Source to Target](https://leetcode.com/problems/all-paths-from-source-to-target/)
- [ ] [802. Find Eventual Safe States](https://leetcode.com/problems/find-eventual-safe-states/)
- [ ] [841. Keys and Rooms](https://leetcode.com/problems/keys-and-rooms/)
- [ ] [863. All Nodes Distance K in Binary Tree](https://leetcode.com/problems/all-nodes-distance-k-in-binary-tree/)
- [ ] [886. Possible Bipartition](https://leetcode.com/problems/possible-bipartition/)
- [ ] [909. Snakes and Ladders](https://leetcode.com/problems/snakes-and-ladders/)
- [ ] [934. Shortest Bridge](https://leetcode.com/problems/shortest-bridge/)
- [ ] [947. Most Stones Removed](https://leetcode.com/problems/most-stones-removed-with-same-row-or-column/) (Union Find)
- [ ] [994. Rotting Oranges](https://leetcode.com/problems/rotting-oranges/) ⭐⭐
- [ ] [1020. Number of Enclaves](https://leetcode.com/problems/number-of-enclaves/)
- [ ] [1059. All Paths from Source Lead to Destination](https://leetcode.com/problems/all-paths-from-source-lead-to-destination/) (Premium)
- [ ] [1091. Shortest Path in Binary Matrix](https://leetcode.com/problems/shortest-path-in-binary-matrix/)
- [ ] [1129. Shortest Path with Alternating Colors](https://leetcode.com/problems/shortest-path-with-alternating-colors/)
- [ ] [1197. Minimum Knight Moves](https://leetcode.com/problems/minimum-knight-moves/) (Premium)
- [ ] [1254. Number of Closed Islands](https://leetcode.com/problems/number-of-closed-islands/)
- [ ] [1319. Number of Operations to Make Network Connected](https://leetcode.com/problems/number-of-operations-to-make-network-connected/)

**Graphs - Hard (10 مسائل):**

- [ ] [127. Word Ladder](https://leetcode.com/problems/word-ladder/) ⭐⭐
- [ ] [126. Word Ladder II](https://leetcode.com/problems/word-ladder-ii/)
- [ ] [675. Cut Off Trees for Golf Event](https://leetcode.com/problems/cut-off-trees-for-golf-event/)
- [ ] [765. Couples Holding Hands](https://leetcode.com/problems/couples-holding-hands/)
- [ ] [778. Swim in Rising Water](https://leetcode.com/problems/swim-in-rising-water/)
- [ ] [815. Bus Routes](https://leetcode.com/problems/bus-routes/)
- [ ] [827. Making A Large Island](https://leetcode.com/problems/making-a-large-island/)
- [ ] [1091. Shortest Path in Binary Matrix](https://leetcode.com/problems/shortest-path-in-binary-matrix/)
- [ ] [1192. Critical Connections in a Network](https://leetcode.com/problems/critical-connections-in-a-network/) ⭐
- [ ] [1293. Shortest Path in a Grid with Obstacles](https://leetcode.com/problems/shortest-path-in-a-grid-with-obstacles-elimination/)

#### 💡 Tips & Tricks:

```python
# DFS on Graph (Adjacency List):
def dfs(node, graph, visited):
    if node in visited:
        return
    
    visited.add(node)
    
    for neighbor in graph[node]:
        dfs(neighbor, graph, visited)

# BFS on Graph:
from collections import deque

def bfs(start, graph):
    queue = deque([start])
    visited = {start}
    
    while queue:
        node = queue.popleft()
        
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

# Union Find Template:
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # path compression
        return self.parent[x]
    
    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        
        if px == py:
            return False
        
        # union by rank
        if self.rank[px] < self.rank[py]:
            self.parent[px] = py
        elif self.rank[px] > self.rank[py]:
            self.parent[py] = px
        else:
            self.parent[py] = px
            self.rank[px] += 1
        
        return True

# Topological Sort (Kahn's Algorithm):
from collections import deque, defaultdict

def topological_sort(n, edges):
    graph = defaultdict(list)
    indegree = [0] * n
    
    for u, v in edges:
        graph[u].append(v)
        indegree[v] += 1
    
    queue = deque([i for i in range(n) if indegree[i] == 0])
    result = []
    
    while queue:
        node = queue.popleft()
        result.append(node)
        
        for neighbor in graph[node]:
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0:
                queue.append(neighbor)
    
    return result if len(result) == n else []  # cycle detection

# Dijkstra's Algorithm:
import heapq

def dijkstra(graph, start):
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    pq = [(0, start)]  # (distance, node)
    
    while pq:
        current_dist, node = heapq.heappop(pq)
        
        if current_dist > distances[node]:
            continue
        
        for neighbor, weight in graph[node]:
            distance = current_dist + weight
            
            if distance < distances[neighbor]:
                distances[neighbor] = distance
                heapq.heappush(pq, (distance, neighbor))
    
    return distances
```

---

### **Week 14: Backtracking & Recursion (30 مسألة)**

#### 📝 Must-Solve Problems:

**Backtracking - Medium (25 مسائل):**

- [ ] [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) ⭐
- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) ⭐⭐
- [ ] [39. Combination Sum](https://leetcode.com/problems/combination-sum/) ⭐⭐
- [ ] [40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/)
- [ ] [46. Permutations](https://leetcode.com/problems/permutations/) ⭐⭐⭐
- [ ] [47. Permutations II](https://leetcode.com/problems/permutations-ii/)
- [ ] [78. Subsets](https://leetcode.com/problems/subsets/) ⭐⭐⭐
- [ ] [90. Subsets II](https://leetcode.com/problems/subsets-ii/)
- [ ] [77. Combinations](https://leetcode.com/problems/combinations/)
- [ ] [79. Word Search](https://leetcode.com/problems/word-search/) ⭐⭐
- [ ] [93. Restore IP Addresses](https://leetcode.com/problems/restore-ip-addresses/)
- [ ] [131. Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) ⭐
- [ ] [216. Combination Sum III](https://leetcode.com/problems/combination-sum-iii/)
- [ ] [254. Factor Combinations](https://leetcode.com/problems/factor-combinations/) (Premium)
- [ ] [267. Palindrome Permutation II](https://leetcode.com/problems/palindrome-permutation-ii/) (Premium)
- [ ] [291. Word Pattern II](https://leetcode.com/problems/word-pattern-ii/) (Premium)
- [ ] [320. Generalized Abbreviation](https://leetcode.com/problems/generalized-abbreviation/) (Premium)
- [ ] [351. Android Unlock Patterns](https://leetcode.com/problems/android-unlock-patterns/) (Premium)
- [ ] [377. Combination Sum IV](https://leetcode.com/problems/combination-sum-iv/)
- [ ] [401. Binary Watch](https://leetcode.com/problems/binary-watch/)
- [ ] [473. Matchsticks to Square](https://leetcode.com/problems/matchsticks-to-square/)
- [ ] [491. Non-decreasing Subsequences](https://leetcode.com/problems/non-decreasing-subsequences/)
- [ ] [526. Beautiful Arrangement](https://leetcode.com/problems/beautiful-arrangement/)
- [ ] [784. Letter Case Permutation](https://leetcode.com/problems/letter-case-permutation/)
- [ ] [842. Split Array into Fibonacci Sequence](https://leetcode.com/problems/split-array-into-fibonacci-sequence/)

**Backtracking - Hard (5 مسائل):**

- [ ] [37. Sudoku Solver](https://leetcode.com/problems/sudoku-solver/) ⭐⭐
- [ ] [51. N-Queens](https://leetcode.com/problems/n-queens/) ⭐⭐⭐
- [ ] [52. N-Queens II](https://leetcode.com/problems/n-queens-ii/)
- [ ] [212. Word Search II](https://leetcode.com/problems/word-search-ii/) ⭐⭐
- [ ] [301. Remove Invalid Parentheses](https://leetcode.com/problems/remove-invalid-parentheses/)

#### 💡 Tips & Tricks:

```python
# Backtracking Template العام:
def backtrack(path, choices):
    if is_solution(path):
        result.append(path[:])  # save a copy
        return
    
    for choice in choices:
        # Make choice
        path.append(choice)
        
        # Recurse
        backtrack(path, get_new_choices())
        
        # Undo choice (backtrack)
        path.pop()

# Permutations Template:
def permute(nums):
    result = []
    
    def backtrack(path):
        if len(path) == len(nums):
            result.append(path[:])
            return
        
        for num in nums:
            if num in path:
                continue
            path.append(num)
            backtrack(path)
            path.pop()
    
    backtrack([])
    return result

# Subsets Template:
def subsets(nums):
    result = []
    
    def backtrack(start, path):
        result.append(path[:])
        
        for i in range(start, len(nums)):
            path.append(nums[i])
            backtrack(i + 1, path)
            path.pop()
    
    backtrack(0, [])
    return result

# Combination Sum Template:
def combination_sum(candidates, target):
    result = []
    
    def backtrack(start, path, current_sum):
        if current_sum == target:
            result.append(path[:])
            return
        
        if current_sum > target:
            return
        
        for i in range(start, len(candidates)):
            path.append(candidates[i])
            backtrack(i, path, current_sum + candidates[i])  # i للـ reuse
            path.pop()
    
    backtrack(0, [], 0)
    return result
```

---

## 🔥 Phase 3: Advanced Topics (Weeks 15-20) - 150 Problems

### **Week 15-16: Advanced DP (40 مسألة)**

**DP - Hard (40 مسائل):**

- [ ] [10. Regular Expression Matching](https://leetcode.com/problems/regular-expression-matching/) ⭐⭐
- [ ] [32. Longest Valid Parentheses](https://leetcode.com/problems/longest-valid-parentheses/) ⭐⭐
- [ ] [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/) ⭐⭐⭐
- [ ] [44. Wildcard Matching](https://leetcode.com/problems/wildcard-matching/)
- [ ] [72. Edit Distance](https://leetcode.com/problems/edit-distance/) ⭐⭐⭐ (مهمة جداً)
- [ ] [85. Maximal Rectangle](https://leetcode.com/problems/maximal-rectangle/)
- [ ] [87. Scramble String](https://leetcode.com/problems/scramble-string/)
- [ ] [97. Interleaving String](https://leetcode.com/problems/interleaving-string/)
- [ ] [115. Distinct Subsequences](https://leetcode.com/problems/distinct-subsequences/)
- [ ] [123. Best Time to Buy and Sell Stock III](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/) ⭐
- [ ] [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/) ⭐⭐
- [ ] [132. Palindrome Partitioning II](https://leetcode.com/problems/palindrome-partitioning-ii/)
- [ ] [140. Word Break II](https://leetcode.com/problems/word-break-ii/)
- [ ] [174. Dungeon Game](https://leetcode.com/problems/dungeon-game/)
- [ ] [188. Best Time to Buy and Sell Stock IV](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iv/) ⭐
- [ ] [265. Paint House II](https://leetcode.com/problems/paint-house-ii/) (Premium)
- [ ] [276. Paint Fence](https://leetcode.com/problems/paint-fence/) (Premium)
- [ ] [312. Burst Balloons](https://leetcode.com/problems/burst-balloons/) ⭐⭐
- [ ] [321. Create Maximum Number](https://leetcode.com/problems/create-maximum-number/)
- [ ] [354. Russian Doll Envelopes](https://leetcode.com/problems/russian-doll-envelopes/)
- [ ] [403. Frog Jump](https://leetcode.com/problems/frog-jump/)
- [ ] [410. Split Array Largest Sum](https://leetcode.com/problems/split-array-largest-sum/)
- [ ] [446. Arithmetic Slices II - Subsequence](https://leetcode.com/problems/arithmetic-slices-ii-subsequence/)
- [ ] [472. Concatenated Words](https://leetcode.com/problems/concatenated-words/)
- [ ] [514. Freedom Trail](https://leetcode.com/problems/freedom-trail/)
- [ ] [517. Super Washing Machines](https://leetcode.com/problems/super-washing-machines/)
- [ ] [542. 01 Matrix](https://leetcode.com/problems/01-matrix/)
- [ ] [552. Student Attendance Record II](https://leetcode.com/problems/student-attendance-record-ii/)
- [ ] [600. Non-negative Integers without Consecutive Ones](https://leetcode.com/problems/non-negative-integers-without-consecutive-ones/)
- [ ] [629. K Inverse Pairs Array](https://leetcode.com/problems/k-inverse-pairs-array/)
- [ ] [639. Decode Ways II](https://leetcode.com/problems/decode-ways-ii/)
- [ ] [656. Coin Path](https://leetcode.com/problems/coin-path/) (Premium)
- [ ] [664. Strange Printer](https://leetcode.com/problems/strange-printer/)
- [ ] [689. Maximum Sum of 3 Non-Overlapping Subarrays](https://leetcode.com/problems/maximum-sum-of-3-non-overlapping-subarrays/)
- [ ] [691. Stickers to Spell Word](https://leetcode.com/problems/stickers-to-spell-word/)
- [ ] [714. Best Time to Buy and Sell Stock with Transaction Fee](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-with-transaction-fee/)
- [ ] [730. Count Different Palindromic Subsequences](https://leetcode.com/problems/count-different-palindromic-subsequences/)
- [ ] [741. Cherry Pickup](https://leetcode.com/problems/cherry-pickup/)
- [ ] [801. Minimum Swaps To Make Sequences Increasing](https://leetcode.com/problems/minimum-swaps-to-make-sequences-increasing/)
- [ ] [818. Race Car](https://leetcode.com/problems/race-car/)

---

### **Week 17-18: Binary Search & Two Pointers Advanced (35 مسألة)**

**Binary Search - Medium (20 مسائل):**

- [ ] [33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/) ⭐⭐⭐
- [ ] [34. Find First and Last Position](https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/) ⭐⭐
- [ ] [74. Search a 2D Matrix](https://leetcode.com/problems/search-a-2d-matrix/) ⭐
- [ ] [81. Search in Rotated Sorted Array II](https://leetcode.com/problems/search-in-rotated-sorted-array-ii/)
- [ ] [153. Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/) ⭐⭐
- [ ] [154. Find Minimum in Rotated Sorted Array II](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array-ii/)
- [ ] [162. Find Peak Element](https://leetcode.com/problems/find-peak-element/) ⭐
- [ ] [240. Search a 2D Matrix II](https://leetcode.com/problems/search-a-2d-matrix-ii/) ⭐
- [ ] [275. H-Index II](https://leetcode.com/problems/h-index-ii/)
- [ ] [278. First Bad Version](https://leetcode.com/problems/first-bad-version/)
- [ ] [287. Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/) ⭐⭐
- [ ] [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) (Binary Search approach)
- [ ] [354. Russian Doll Envelopes](https://leetcode.com/problems/russian-doll-envelopes/)
- [ ] [367. Valid Perfect Square](https://leetcode.com/problems/valid-perfect-square/)
- [ ] [374. Guess Number Higher or Lower](https://leetcode.com/problems/guess-number-higher-or-lower/)
- [ ] [378. Kth Smallest Element in a Sorted Matrix](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/) ⭐
- [ ] [410. Split Array Largest Sum](https://leetcode.com/problems/split-array-largest-sum/)
- [ ] [436. Find Right Interval](https://leetcode.com/problems/find-right-interval/)
- [ ] [475. Heaters](https://leetcode.com/problems/heaters/)
- [ ] [528. Random Pick with Weight](https://leetcode.com/problems/random-pick-with-weight/)

**Binary Search - Hard (15 مسألة):**

- [ ] [4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/) ⭐⭐⭐
- [ ] [69. Sqrt(x)](https://leetcode.com/problems/sqrtx/)
- [ ] [302. Smallest Rectangle Enclosing Black Pixels](https://leetcode.com/problems/smallest-rectangle-enclosing-black-pixels/) (Premium)
- [ ] [644. Maximum Average Subarray II](https://leetcode.com/problems/maximum-average-subarray-ii/) (Premium)
- [ ] [668. Kth Smallest Number in Multiplication Table](https://leetcode.com/problems/kth-smallest-number-in-multiplication-table/)
- [ ] [719. Find K-th Smallest Pair Distance](https://leetcode.com/problems/find-k-th-smallest-pair-distance/) ⭐
- [ ] [774. Minimize Max Distance to Gas Station](https://leetcode.com/problems/minimize-max-distance-to-gas-station/) (Premium)
- [ ] [786. K-th Smallest Prime Fraction](https://leetcode.com/problems/k-th-smallest-prime-fraction/)
- [ ] [793. Preimage Size of Factorial Zeroes Function](https://leetcode.com/problems/preimage-size-of-factorial-zeroes-function/)
- [ ] [878. Nth Magical Number](https://leetcode.com/problems/nth-magical-number/)
- [ ] [887. Super Egg Drop](https://leetcode.com/problems/super-egg-drop/) ⭐⭐
- [ ] [1062. Longest Repeating Substring](https://leetcode.com/problems/longest-repeating-substring/) (Premium)
- [ ] [1095. Find in Mountain Array](https://leetcode.com/problems/find-in-mountain-array/)
- [ ] [1201. Ugly Number III](https://leetcode.com/problems/ugly-number-iii/)
- [ ] [1283. Find the Smallest Divisor](https://leetcode.com/problems/find-the-smallest-divisor-given-a-threshold/)

#### 💡 Binary Search Tips:

```python
# Binary Search Template (Classical):
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2  # avoid overflow
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1

# Binary Search للـ leftmost position:
def find_first(arr, target):
    left, right = 0, len(arr)
    
    while left < right:
        mid = left + (right - left) // 2
        
        if arr[mid] < target:
            left = mid + 1
        else:
            right = mid
    
    return left

# Binary Search على الـ answer (معندكش array):
def binary_search_answer(predicate, lo, hi):
    """
    Find the smallest x where predicate(x) is True
    """
    while lo < hi:
        mid = lo + (hi - lo) // 2
        
        if predicate(mid):
            hi = mid
        else:
            lo = mid + 1
    
    return lo
```

---

### **Week 19-20: Heaps, Trie, & Advanced Data Structures (40 مسألة)**

**Heaps - Medium/Hard (20 مسائل):**
- [ ] [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) ⭐⭐⭐
- [ ] [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) ⭐⭐
- [ ] [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) (Premium) ⭐
- [ ] [264. Ugly Number II](https://leetcode.com/problems/ugly-number-ii/)
- [ ] [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/) ⭐⭐⭐
- [ ] [313. Super Ugly Number](https://leetcode.com/problems/super-ugly-number/)
- [ ] [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) ⭐
- [ ] [355. Design Twitter](https://leetcode.com/problems/design-twitter/)
- [ ] [373. Find K Pairs with Smallest Sums](https://leetcode.com/problems/find-k-pairs-with-smallest-sums/)
- [ ] [378. Kth Smallest Element in a Sorted Matrix](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/)
- [ ] [407. Trapping Rain Water II](https://leetcode.com/problems/trapping-rain-water-ii/)
- [ ] [451. Sort Characters By Frequency](https://leetcode.com/problems/sort-characters-by-frequency/)
- [ ] [502. IPO](https://leetcode.com/problems/ipo/)
- [ ] [692. Top K Frequent Words](https://leetcode.com/problems/top-k-frequent-words/)
- [ ] [703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/)
- [ ] [767. Reorganize String](https://leetcode.com/problems/reorganize-string/)
- [ ] [846. Hand of Straights](https://leetcode.com/problems/hand-of-straights/)
- [ ] [857. Minimum Cost to Hire K Workers](https://leetcode.com/problems/minimum-cost-to-hire-k-workers/)
- [ ] [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) ⭐
- [ ] [1046. Last Stone Weight](https://leetcode.com/problems/last-stone-weight/)

**Trie - Medium/Hard (20 مسائل):**
- [ ] [208. Implement Trie](https://leetcode.com/problems/implement-trie-prefix-tree/) ⭐⭐⭐
- [ ] [211. Design Add and Search Words Data Structure](https://leetcode.com/problems/design-add-and-search-words-data-structure/) ⭐⭐
- [ ] [212. Word Search II](https://leetcode.com/problems/word-search-ii/) ⭐⭐⭐
- [ ] [336. Palindrome Pairs](https://leetcode.com/problems/palindrome-pairs/)
- [ ] [421. Maximum XOR of Two Numbers](https://leetcode.com/problems/maximum-xor-of-two-numbers-in-an-array/) ⭐
- [ ] [472. Concatenated Words](https://leetcode.com/problems/concatenated-words/)
- [ ] [588. Design In-Memory File System](https://leetcode.com/problems/design-in-memory-file-system/) (Premium)
- [ ] [642. Design Search Autocomplete System](https://leetcode.com/problems/design-search-autocomplete-system/) (Premium)
- [ ] [648. Replace Words](https://leetcode.com/problems/replace-words/)
- [ ] [676. Implement Magic Dictionary](https://leetcode.com/problems/implement-magic-dictionary/)
- [ ] [677. Map Sum Pairs](https://leetcode.com/problems/map-sum-pairs/)
- [ ] [720. Longest Word in Dictionary](https://leetcode.com/problems/longest-word-in-dictionary/)
- [ ] [745. Prefix and Suffix Search](https://leetcode.com/problems/prefix-and-suffix-search/)
- [ ] [820. Short Encoding of Words](https://leetcode.com/problems/short-encoding-of-words/)
- [ ] [1065. Index Pairs of a String](https://leetcode.com/problems/index-pairs-of-a-string/) (Premium)
- [ ] [1166. Design File System](https://leetcode.com/problems/design-file-system/) (Premium)
- [ ] [1233. Remove Sub-Folders from the Filesystem](https://leetcode.com/problems/remove-sub-folders-from-the-filesystem/)
- [ ] [1268. Search Suggestions System](https://leetcode.com/problems/search-suggestions-system/)
- [ ] [1804. Implement Trie II](https://leetcode.com/problems/implement-trie-ii-prefix-tree/) (Premium)
- [ ] [1858. Longest Word With All Prefixes](https://leetcode.com/problems/longest-word-with-all-prefixes/) (Premium)

#### 💡 Heap & Trie Tips:
```python
# Heap (Priority Queue) in Python:
import heapq

# Min Heap (default):
min_heap = []
heapq.heappush(min_heap, 5)
heapq.heappush(min_heap, 3)
smallest = heapq.heappop(min_heap)  # 3

# Max Heap (negate values):
max_heap = []
heapq.heappush(max_heap, -5)
heapq.heappush(max_heap, -3)
largest = -heapq.heappop(max_heap)  # 5

# Heapify existing list:
arr = [3, 1, 4, 1, 5]
heapq.heapify(arr)  # O(n)

# K largest elements:
k_largest = heapq.nlargest(k, arr)

# Trie Implementation:
class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_end = False

class Trie:
    def __init__(self):
        self.root = TrieNode()
    
    def insert(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end = True
    
    def search(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.is_end
    
    def starts_with(self, prefix):
        node = self.root
        for char in prefix:
            if char not in node.children:
                return False
            node = node.children[char]
        return True
````

---

### **Week 20: Bit Manipulation & Math (35 مسألة)**

**Bit Manipulation (20 مسائل):**

- [ ] [136. Single Number](https://leetcode.com/problems/single-number/) ⭐
- [ ] [137. Single Number II](https://leetcode.com/problems/single-number-ii/)
- [ ] [190. Reverse Bits](https://leetcode.com/problems/reverse-bits/)
- [ ] [191. Number of 1 Bits](https://leetcode.com/problems/number-of-1-bits/)
- [ ] [201. Bitwise AND of Numbers Range](https://leetcode.com/problems/bitwise-and-of-numbers-range/)
- [ ] [231. Power of Two](https://leetcode.com/problems/power-of-two/)
- [ ] [260. Single Number III](https://leetcode.com/problems/single-number-iii/)
- [ ] [268. Missing Number](https://leetcode.com/problems/missing-number/)
- [ ] [318. Maximum Product of Word Lengths](https://leetcode.com/problems/maximum-product-of-word-lengths/)
- [ ] [338. Counting Bits](https://leetcode.com/problems/counting-bits/) ⭐
- [ ] [371. Sum of Two Integers](https://leetcode.com/problems/sum-of-two-integers/)
- [ ] [389. Find the Difference](https://leetcode.com/problems/find-the-difference/)
- [ ] [393. UTF-8 Validation](https://leetcode.com/problems/utf-8-validation/)
- [ ] [421. Maximum XOR of Two Numbers](https://leetcode.com/problems/maximum-xor-of-two-numbers-in-an-array/)
- [ ] [461. Hamming Distance](https://leetcode.com/problems/hamming-distance/)
- [ ] [477. Total Hamming Distance](https://leetcode.com/problems/total-hamming-distance/)
- [ ] [693. Binary Number with Alternating Bits](https://leetcode.com/problems/binary-number-with-alternating-bits/)
- [ ] [762. Prime Number of Set Bits](https://leetcode.com/problems/prime-number-of-set-bits-in-binary-representation/)
- [ ] [898. Bitwise ORs of Subarrays](https://leetcode.com/problems/bitwise-ors-of-subarrays/)
- [ ] [1356. Sort Integers by The Number of 1 Bits](https://leetcode.com/problems/sort-integers-by-the-number-of-1-bits/)

**Math (15 مسائل):**

- [ ] [7. Reverse Integer](https://leetcode.com/problems/reverse-integer/)
- [ ] [9. Palindrome Number](https://leetcode.com/problems/palindrome-number/)
- [ ] [50. Pow(x, n)](https://leetcode.com/problems/powx-n/) ⭐
- [ ] [60. Permutation Sequence](https://leetcode.com/problems/permutation-sequence/)
- [ ] [69. Sqrt(x)](https://leetcode.com/problems/sqrtx/)
- [ ] [149. Max Points on a Line](https://leetcode.com/problems/max-points-on-a-line/)
- [ ] [166. Fraction to Recurring Decimal](https://leetcode.com/problems/fraction-to-recurring-decimal/)
- [ ] [168. Excel Sheet Column Title](https://leetcode.com/problems/excel-sheet-column-title/)
- [ ] [171. Excel Sheet Column Number](https://leetcode.com/problems/excel-sheet-column-number/)
- [ ] [172. Factorial Trailing Zeroes](https://leetcode.com/problems/factorial-trailing-zeroes/)
- [ ] [204. Count Primes](https://leetcode.com/problems/count-primes/) ⭐
- [ ] [223. Rectangle Area](https://leetcode.com/problems/rectangle-area/)
- [ ] [258. Add Digits](https://leetcode.com/problems/add-digits/)
- [ ] [263. Ugly Number](https://leetcode.com/problems/ugly-number/)
- [ ] [279. Perfect Squares](https://leetcode.com/problems/perfect-squares/)

---

## 🎯 Phase 4: Company-Specific & Mock Interviews (Weeks 21-24) - 100 Problems

### **Week 21-22: FAANG Favorites (50 مسألة)**

**Meta/Facebook (15 مسائل):**

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/)
- [ ] [15. 3Sum](https://leetcode.com/problems/3sum/)
- [ ] [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)
- [ ] [31. Next Permutation](https://leetcode.com/problems/next-permutation/)
- [ ] [56. Merge Intervals](https://leetcode.com/problems/merge-intervals/) ⭐⭐
- [ ] [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) ⭐⭐⭐
- [ ] [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)
- [ ] [236. Lowest Common Ancestor](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/)
- [ ] [238. Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/)
- [ ] [273. Integer to English Words](https://leetcode.com/problems/integer-to-english-words/)
- [ ] [301. Remove Invalid Parentheses](https://leetcode.com/problems/remove-invalid-parentheses/)
- [ ] [314. Binary Tree Vertical Order Traversal](https://leetcode.com/problems/binary-tree-vertical-order-traversal/) (Premium)
- [ ] [380. Insert Delete GetRandom O(1)](https://leetcode.com/problems/insert-delete-getrandom-o1/)
- [ ] [543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/)
- [ ] [670. Maximum Swap](https://leetcode.com/problems/maximum-swap/)

**Google (15 مسائل):**

- [ ] [2. Add Two Numbers](https://leetcode.com/problems/add-two-numbers/)
- [ ] [17. Letter Combinations](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)
- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/)
- [ ] [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)
- [ ] [127. Word Ladder](https://leetcode.com/problems/word-ladder/)
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
- [ ] [207. Course Schedule](https://leetcode.com/problems/course-schedule/)
- [ ] [212. Word Search II](https://leetcode.com/problems/word-search-ii/)
- [ ] [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) (Premium)
- [ ] [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)
- [ ] [329. Longest Increasing Path in Matrix](https://leetcode.com/problems/longest-increasing-path-in-a-matrix/)
- [ ] [759. Employee Free Time](https://leetcode.com/problems/employee-free-time/) (Premium)
- [ ] [843. Guess the Word](https://leetcode.com/problems/guess-the-word/) (Premium)
- [ ] [google.com/problems](https://leetcode.com/company/google/)

**Amazon (10 مسائل):**

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/)
- [ ] [5. Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/)
- [ ] [48. Rotate Image](https://leetcode.com/problems/rotate-image/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
- [ ] [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)
- [ ] [215. Kth Largest Element](https://leetcode.com/problems/kth-largest-element-in-an-array/)
- [ ] [937. Reorder Data in Log Files](https://leetcode.com/problems/reorder-data-in-log-files/)
- [ ] [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/)
- [ ] [Amazon Company Tag](https://leetcode.com/company/amazon/)

**Microsoft (10 مسائل):**

- [ ] [13. Roman to Integer](https://leetcode.com/problems/roman-to-integer/)
- [ ] [46. Permutations](https://leetcode.com/problems/permutations/)
- [ ] [48. Rotate Image](https://leetcode.com/problems/rotate-image/)
- [ ] [103. Binary Tree Zigzag](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
- [ ] [146. LRU Cache](https://leetcode.com/problems/lru-cache/) ⭐⭐⭐
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
- [ ] [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)
- [ ] [236. Lowest Common Ancestor](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/)
- [ ] [387. First Unique Character](https://leetcode.com/problems/first-unique-character-in-a-string/)
- [ ] [Microsoft Company Tag](https://leetcode.com/company/microsoft/)

---

### **Week 23-24: Mixed Practice & System Design Prep (50 مسائل)**

**High-Frequency Interview Questions (50 مسائل):**

- [ ] [3. Longest Substring Without Repeating](https://leetcode.com/problems/longest-substring-without-repeating-characters/)
- [ ] [4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/)
- [ ] [5. Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/)
- [ ] [10. Regular Expression Matching](https://leetcode.com/problems/regular-expression-matching/)
- [ ] [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/)
- [ ] [15. 3Sum](https://leetcode.com/problems/3sum/)
- [ ] [17. Letter Combinations](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)
- [ ] [19. Remove Nth Node From End](https://leetcode.com/problems/remove-nth-node-from-end-of-list/)
- [ ] [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/)
- [ ] [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/)
- [ ] [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
- [ ] [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)
- [ ] [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
- [ ] [33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/)
- [ ] [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
- [ ] [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)
- [ ] [46. Permutations](https://leetcode.com/problems/permutations/)
- [ ] [48. Rotate Image](https://leetcode.com/problems/rotate-image/)
- [ ] [49. Group Anagrams](https://leetcode.com/problems/group-anagrams/)
- [ ] [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/)
- [ ] [54. Spiral Matrix](https://leetcode.com/problems/spiral-matrix/)
- [ ] [55. Jump Game](https://leetcode.com/problems/jump-game/)
- [ ] [56. Merge Intervals](https://leetcode.com/problems/merge-intervals/)
- [ ] [62. Unique Paths](https://leetcode.com/problems/unique-paths/)
- [ ] [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/)
- [ ] [72. Edit Distance](https://leetcode.com/problems/edit-distance/)
- [ ] [73. Set Matrix Zeroes](https://leetcode.com/problems/set-matrix-zeroes/)
- [ ] [75. Sort Colors](https://leetcode.com/problems/sort-colors/)
- [ ] [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/)
- [ ] [78. Subsets](https://leetcode.com/problems/subsets/)
- [ ] [79. Word Search](https://leetcode.com/problems/word-search/)
- [ ] [84. Largest Rectangle in Histogram](https://leetcode.com/problems/largest-rectangle-in-histogram/)
- [ ] [91. Decode Ways](https://leetcode.com/problems/decode-ways/)
- [ ] [98. Validate Binary Search Tree](https://leetcode.com/problems/validate-binary-search-tree/)
- [ ] [102. Binary Tree Level Order](https://leetcode.com/problems/binary-tree-level-order-traversal/)
- [ ] [104. Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/)
- [ ] [105. Construct Binary Tree from Preorder and Inorder](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
- [ ] [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)
- [ ] [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)
- [ ] [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)
- [ ] [128. Longest Consecutive Sequence](https://leetcode.com/problems/longest-consecutive-sequence/)
- [ ] [139. Word Break](https://leetcode.com/problems/word-break/)
- [ ] [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)
- [ ] [146. LRU Cache](https://leetcode.com/problems/lru-cache/)
- [ ] [152. Maximum Product Subarray](https://leetcode.com/problems/maximum-product-subarray/)
- [ ] [153. Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/)
- [ ] [155. Min Stack](https://leetcode.com/problems/min-stack/)
- [ ] [198. House Robber](https://leetcode.com/problems/house-robber/)
- [ ] [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
- [ ] [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)

---

## 📚 الموارد الإضافية والنصائح

### 🔥 نصائح عامة للنجاح:

**1. اللي يخليك تنجح:**

- اتعامل مع Problem Solving زي الـ Gym - **consistency أهم من intensity**
- حل 2-3 مسائل يومياً أفضل من 20 مسألة في يوم واحد كل أسبوع
- لو مسألة وقفت معاك أكتر من 30 دقيقة، **اتفرج على الـ solution**
- **راجع المسائل اللي حلتها** بعد أسبوع - هتنسى الحل وده كويس!

**2. طريقة الحل الصحيحة:**

```
1. اقرأ المسألة 3 مرات (افهم الـ input/output)
2. حل أمثلة على الورق (edge cases)
3. فكر في الـ brute force solution الأول
4. حاول تحسنها (Time/Space complexity)
5. اكتب الكود
6. Test مع الأمثلة
7. Submit
8. اقرأ solutions تانية (هتتعلم patterns جديدة)
```

**3. تجنب الأخطاء دي:**

- ❌ حل المسائل عشوائياً بدون ترتيب
- ❌ الاستسلام بسرعة وانت بتحل
- ❌ عدم مراجعة المسائل القديمة
- ❌ التركيز على Hard problems في الأول
- ❌ عدم كتابة الكود بنفسك (مجرد قراءة الـ solution)

---

### 📊 جدول التتبع الأسبوعي:

اعمل ملف Excel أو Google Sheets بالتنسيق ده:

|Week|Topic|Target|Solved|Easy|Medium|Hard|Notes|
|---|---|---|---|---|---|---|---|
|1|Arrays|15|0|0|0|0||
|2|Strings|20|0|0|0|0||
|...|...|...|...|...|...|...|...|

---

### 🎓 مصادر إضافية:

**YouTube Channels:**

- [NeetCode](https://www.youtube.com/@NeetCode) - أفضل channel للـ LeetCode
- [Back To Back SWE](https://www.youtube.com/@BackToBackSWE)
- [Abdul Bari (Algorithms)](https://www.youtube.com/@abdul_bari)
- [Errichto (Competitive Programming)](https://www.youtube.com/@Errichto)

**Websites:**

- [NeetCode.io](https://neetcode.io/) - Roadmap + Video Solutions
- [LeetCode Patterns](https://seanprashad.com/leetcode-patterns/)
- [Tech Interview Handbook](https://www.techinterviewhandbook.org/)

**Books (optional):**

- Cracking the Coding Interview (CTCI)
- Elements of Programming Interviews (EPI)
- Grokking Algorithms

---

## ✅ Checklist نهاية كل أسبوع:

- [ ] حليت الـ target problems للأسبوع
- [ ] راجعت 5 مسائل قديمة على الأقل
- [ ] فهمت الـ patterns الأساسية للـ topic
- [ ] كتبت ملاحظات عن الـ common pitfalls
- [ ] حاولت أحل مسألة واحدة بدون مساعدة

---

## 🔄 Spaced Repetition Review

> **راجع المسائل المهمة بعد فترة عشان تثبت في ذاكرتك**

| Problem | First Solve | Day 3 Review | Week 1 Review | Week 2 Review | Month Review |
|---------|-------------|--------------|---------------|---------------|--------------|
| Two Sum | [ ] | [ ] | [ ] | [ ] | [ ] |
| Valid Parentheses | [ ] | [ ] | [ ] | [ ] | [ ] |
| Reverse Linked List | [ ] | [ ] | [ ] | [ ] | [ ] |
| Binary Tree Level Order | [ ] | [ ] | [ ] | [ ] | [ ] |
| Number of Islands | [ ] | [ ] | [ ] | [ ] | [ ] |
| Coin Change | [ ] | [ ] | [ ] | [ ] | [ ] |
| LRU Cache | [ ] | [ ] | [ ] | [ ] | [ ] |
| (أضف مسائل تانية هنا) | [ ] | [ ] | [ ] | [ ] | [ ] |

---

## 📝 Personal Notes Per Week

### Week 1 Notes:
- 
- 

### Week 2 Notes:
- 
- 

### Week 3 Notes:
- 
- 

*(أضف notes لكل أسبوع وانت ماشي)*

---

## ⚠️ Common Mistakes to Avoid

### Arrays & Strings:
- [ ] Off-by-one errors in loop boundaries
- [ ] Not handling empty arrays/strings
- [ ] Forgetting negative numbers exist

### Linked Lists:
- [ ] Losing reference to head
- [ ] Not handling null pointers
- [ ] Forgetting to update both next and prev in doubly linked

### Trees:
- [ ] Not handling null root
- [ ] Confusing BST with regular binary tree
- [ ] Stack overflow in deep recursion

### DP:
- [ ] Wrong base case initialization
- [ ] Incorrect state transition
- [ ] Not considering all subproblems

---

**ملاحظة أخيرة:** الـ roadmap ده طموح جداً (550 مسألة في 6 شهور). لو لقيت نفسك متأخر، **مفيش مشكلة**! الأهم الـ consistency مش السرعة. حتى لو وصلت لـ 300-400 مسألة بجودة عالية، ده أفضل بكتير من 550 مسألة حلتهم بسرعة ونسيتهم.

**بالتوفيق! 🚀**