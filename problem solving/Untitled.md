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

- [ ] [1. Two Sum](https://leetcode.com/problems/two-sum/) ⭐ (أهم مسألة للمبتدئين)
- [ ] [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
- [ ] [27. Remove Element](https://leetcode.com/problems/remove-element/)
- [ ] [66. Plus One](https://leetcode.com/problems/plus-one/)
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
- [ ] [1025. Divisor Game](https://leetcode.com/problems/divisor-game/)
- [ ] [1025. Divisor Game