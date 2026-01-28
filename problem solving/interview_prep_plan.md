# 🎯 2-Week Shadow Interview Prep Plan
**Goal**: Master DS, Algorithms & OOP fundamentals for ITI Training Interviews

---

## 📅 Week 1: Foundations + Pattern Recognition

### Day 1: Arrays & Strings + Two Pointers Pattern
**Core Concepts:**
- Array manipulation techniques
- String operations and common methods
- Two pointers: same direction vs opposite direction
- When to use: sorted arrays, palindromes, pair finding

**💡 Tips & Tricks:**
- Always check for empty arrays/strings first
- Two pointers from opposite ends → palindrome, pair sum problems
- Two pointers same direction → remove duplicates, sliding window
- Remember: `s.charAt(i)` in Java, `s[i]` in C++

**Problems to Solve:**
- [x] [Two Sum](https://leetcode.com/problems/two-sum/) - Easy - Use HashMap for O(n)
- [x] [Valid Palindrome](https://leetcode.com/problems/valid-palindrome/) - Easy - Two pointers technique
- [x] [Container With Most Water](https://leetcode.com/problems/container-with-most-water/) - Medium - Move pointer at shorter height
- [x] [3Sum](https://leetcode.com/problems/3sum/) - Medium - Sort + two pointers, skip duplicates
- [x] [Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/) - Easy - In-place with slow/fast pointers

**Key Takeaway:** Two pointers avoid nested loops, reducing O(n²) to O(n)

---

### Day 2: Linked Lists + Fast/Slow Pointer
**Core Concepts:**
- Singly vs Doubly linked lists
- Dummy node technique (simplifies edge cases!)
- Fast/slow pointer (Floyd's cycle detection)
- Reversing linked lists (iterative & recursive)

**💡 Tips & Tricks:**
- **Always use a dummy node** for problems modifying the head
- Fast/slow pointers: fast moves 2x, slow moves 1x → finds middle, detects cycles
- Draw diagrams! LL problems are visual
- Watch for null pointer exceptions: `if (node != null) node.next`

**Problems to Solve:**
- [x] [Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) - Easy - Master both iterative & recursive
- [x] [Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/) - Easy - Use dummy node
- [x] [Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/) - Easy - Fast/slow pointer
- [x] [Middle of Linked List](https://leetcode.com/problems/middle-of-the-linked-list/) - Easy - Fast/slow pointer
- [ ] [Remove Nth Node From End](https://leetcode.com/problems/remove-nth-node-from-end-of-list/) - Medium - Two pointers with gap

**Key Takeaway:** Dummy nodes prevent special cases for head modifications

---

### Day 3: Stacks & Queues + Monotonic Stack
**Core Concepts:**
- Stack: LIFO - use for backtracking, undo operations
- Queue: FIFO - use for BFS, level-order processing
- Monotonic Stack: maintain increasing/decreasing order
- When to use stack: matching pairs, next greater element

**💡 Tips & Tricks:**
- Stack for: parentheses matching, expression evaluation, DFS
- Queue for: BFS, level-order traversal, sliding window
- Monotonic stack trick: iterate once, find next greater/smaller in O(n)
- Java: `Stack<>`, `Queue<>` (use `LinkedList` or `ArrayDeque`)
- C++: `stack<>`, `queue<>`

**Problems to Solve:**
- [ ] [Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) - Easy - Classic stack problem
- [ ] [Min Stack](https://leetcode.com/problems/min-stack/) - Medium - Track min with each push
- [ ] [Daily Temperatures](https://leetcode.com/problems/daily-temperatures/) - Medium - Monotonic decreasing stack
- [ ] [Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/) - Easy - Two stacks technique
- [ ] [Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/) - Easy - Monotonic stack pattern

**Key Takeaway:** Monotonic stack eliminates nested loops for "next greater/smaller" problems

---

### Day 4: Binary Trees - Traversals & Basics
**Core Concepts:**
- Tree traversals: Inorder, Preorder, Postorder (recursive & iterative)
- Level-order traversal (BFS with queue)
- Tree properties: height, depth, balanced
- DFS vs BFS on trees

**💡 Tips & Tricks:**
- **Inorder on BST → sorted order** (very important!)
- Preorder: Root → Left → Right (good for copying tree)
- Postorder: Left → Right → Root (good for deleting tree)
- Level-order: Use queue, track level size for level-by-level processing
- Recursive template: base case (null check), process node, recurse left/right

**Problems to Solve:**
- [ ] [Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/) - Easy - Both recursive & iterative
- [ ] [Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/) - Easy - DFS or BFS
- [ ] [Same Tree](https://leetcode.com/problems/same-tree/) - Easy - Recursive comparison
- [ ] [Invert Binary Tree](https://leetcode.com/problems/invert-binary-tree/) - Easy - Swap left/right at each node
- [ ] [Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) - Medium - Queue + level size

**Key Takeaway:** Master recursive patterns - most tree problems are variations

---

### Day 5: Binary Search Trees (BST)
**Core Concepts:**
- BST property: left < node < right
- Search, insert, delete operations
- Validate BST (common interview question!)
- Lowest Common Ancestor (LCA)

**💡 Tips & Tricks:**
- Inorder traversal of BST gives sorted array
- Validate BST: track min/max ranges, NOT just left < root < right
- LCA in BST: if both nodes < root, go left; if both > root, go right
- BST search is O(log n) average, O(n) worst case (skewed tree)

**Problems to Solve:**
- [ ] [Search in BST](https://leetcode.com/problems/search-in-a-binary-search-tree/) - Easy - Iterative or recursive
- [ ] [Validate Binary Search Tree](https://leetcode.com/problems/validate-binary-search-tree/) - Medium - Use min/max bounds
- [ ] [Lowest Common Ancestor of BST](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/) - Medium - Use BST property
- [ ] [Kth Smallest Element in BST](https://leetcode.com/problems/kth-smallest-element-in-a-bst/) - Medium - Inorder traversal
- [ ] [Insert into BST](https://leetcode.com/problems/insert-into-a-binary-search-tree/) - Medium - Find correct position

**Key Takeaway:** Always consider BST property - it simplifies many problems

---

### Day 6: Tree Construction & Path Problems
**Core Concepts:**
- Build tree from traversals (Inorder + Preorder/Postorder)
- Path sum problems (root to leaf)
- Diameter, width of tree
- Subtree problems

**💡 Tips & Tricks:**
- Preorder gives root positions, Inorder gives left/right split
- Path problems: often need to pass accumulated sum in recursion
- Global variable for tracking max diameter/path sum
- Return multiple values: use array or class

**Problems to Solve:**
- [ ] [Path Sum](https://leetcode.com/problems/path-sum/) - Easy - DFS with target sum
- [ ] [Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/) - Easy - Height calculation variant
- [ ] [Construct Binary Tree from Preorder and Inorder](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/) - Medium - Classic pattern
- [ ] [Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/) - Hard - Use global max
- [ ] [Subtree of Another Tree](https://leetcode.com/problems/subtree-of-another-tree/) - Easy - Combine tree traversal + comparison

**Key Takeaway:** Tree problems often need helper functions with extra parameters

---

### Day 7: REST & REVIEW 🧘
**Activities:**
- [ ] Review notes from Days 1-6
- [ ] Redo 3-4 problems you struggled with
- [ ] Write down patterns you've learned
- [ ] Practice explaining solutions out loud
- [ ] Light exercise, good sleep!

**Quick Pattern Review Checklist:**
- [ ] Two Pointers: When to use opposite vs same direction?
- [ ] Linked Lists: When to use dummy node?
- [ ] Stacks: What problems need monotonic stack?
- [ ] Trees: Can you write DFS/BFS templates from memory?

---

## 📅 Week 2: Advanced Patterns + Mock Interviews

### Day 8: Hash Maps + Sliding Window
**Core Concepts:**
- Hash Map for O(1) lookup (frequency, seen elements)
- Sliding Window: fixed size vs variable size
- Window patterns: expand right, contract left
- When to use: subarray/substring problems with conditions

**💡 Tips & Tricks:**
- HashMap eliminates nested loops: O(n²) → O(n)
- Fixed window: move both pointers together
- Variable window: expand until invalid, then contract
- Track window state (sum, count, frequency map)
- Common pattern: `while (window invalid) { shrink from left }`

**Problems to Solve:**
- [ ] [Contains Duplicate](https://leetcode.com/problems/contains-duplicate/) - Easy - Use HashSet
- [ ] [Group Anagrams](https://leetcode.com/problems/group-anagrams/) - Medium - Sort string as key
- [ ] [Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) - Medium - Variable sliding window
- [ ] [Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) - Medium - Kadane's algorithm
- [ ] [Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) - Hard - Advanced sliding window (do if time)

**Key Takeaway:** Sliding window + HashMap = most substring/subarray problems solved

---

### Day 9: Binary Search Variations
**Core Concepts:**
- Binary search on sorted arrays
- Search in rotated arrays
- Finding boundaries (first/last occurrence)
- Binary search on answer space

**💡 Tips & Tricks:**
- Template: `while (left <= right)` with `mid = left + (right - left) / 2`
- Avoid overflow: use `left + (right - left) / 2` not `(left + right) / 2`
- Rotated array: one half is always sorted, check which half
- Finding first occurrence: when found, continue searching left (`right = mid - 1`)
- Finding last occurrence: when found, continue searching right (`left = mid + 1`)

**Problems to Solve:**
- [ ] [Binary Search](https://leetcode.com/problems/binary-search/) - Easy - Master the template
- [ ] [First Bad Version](https://leetcode.com/problems/first-bad-version/) - Easy - Find first occurrence
- [ ] [Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/) - Medium - Check which half is sorted
- [ ] [Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/) - Medium - Compare with right
- [ ] [Search a 2D Matrix](https://leetcode.com/problems/search-a-2d-matrix/) - Medium - Treat as 1D array

**Key Takeaway:** Binary search = whenever you can eliminate half the search space

---

### Day 10: Dynamic Programming Basics
**Core Concepts:**
- Memoization (top-down) vs Tabulation (bottom-up)
- Identify overlapping subproblems
- Define state and recurrence relation
- Classic patterns: Fibonacci, climbing stairs, house robber

**💡 Tips & Tricks:**
- Start with recursive solution, then add memoization
- DP array: `dp[i]` = answer for problem of size i
- Bottom-up: build from smallest subproblem
- Space optimization: often only need last 1-2 states
- Pattern: `dp[i] = f(dp[i-1], dp[i-2], ...)`

**Problems to Solve:**
- [ ] [Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) - Easy - Classic Fibonacci variant
- [ ] [Min Cost Climbing Stairs](https://leetcode.com/problems/min-cost-climbing-stairs/) - Easy - Choice at each step
- [ ] [House Robber](https://leetcode.com/problems/house-robber/) - Medium - Classic DP pattern
- [ ] [Coin Change](https://leetcode.com/problems/coin-change/) - Medium - Unbounded knapsack variant
- [ ] [Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) - Medium - O(n²) DP (skip if short on time)

**Key Takeaway:** DP = recursion + memoization, solve small → build to large

---

### Day 11: Graphs - BFS & DFS Fundamentals
**Core Concepts:**
- Graph representations: adjacency list vs matrix
- BFS (Queue) vs DFS (Stack/Recursion)
- Visited tracking (avoid cycles)
- Connected components

**💡 Tips & Tricks:**
- BFS: shortest path in unweighted graph, level-by-level
- DFS: explore as far as possible, good for path finding
- Always track visited nodes (Set or boolean array)
- Grid = implicit graph: neighbors are adjacent cells
- Common template: for each unvisited node, run BFS/DFS

**Problems to Solve:**
- [ ] [Number of Islands](https://leetcode.com/problems/number-of-islands/) - Medium - DFS or BFS on grid
- [ ] [Clone Graph](https://leetcode.com/problems/clone-graph/) - Medium - DFS with HashMap
- [ ] [Course Schedule](https://leetcode.com/problems/course-schedule/) - Medium - Cycle detection (topological sort)
- [ ] [Pacific Atlantic Water Flow](https://leetcode.com/problems/pacific-atlantic-water-flow/) - Medium - BFS/DFS from borders
- [ ] [Flood Fill](https://leetcode.com/problems/flood-fill/) - Easy - DFS on grid

**Key Takeaway:** Most graph problems = BFS/DFS + visited tracking

---

### Day 12: Backtracking Basics
**Core Concepts:**
- Explore all possibilities (decision tree)
- Choose → Explore → Unchoose (backtrack)
- Combinations vs Permutations
- Pruning invalid paths early

**💡 Tips & Tricks:**
- Backtracking template: base case → for each choice → recurse → backtrack
- Combinations: avoid duplicates by maintaining start index
- Permutations: use visited array or swap technique
- Draw decision tree to visualize
- Prune early to avoid unnecessary exploration

**Problems to Solve:**
- [ ] [Subsets](https://leetcode.com/problems/subsets/) - Medium - Classic backtracking
- [ ] [Permutations](https://leetcode.com/problems/permutations/) - Medium - Swap or visited array
- [ ] [Combination Sum](https://leetcode.com/problems/combination-sum/) - Medium - Can reuse elements
- [ ] [Letter Combinations of Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) - Medium - Map digits to letters
- [ ] [Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) - Medium - Backtrack + check palindrome

**Key Takeaway:** Backtracking = systematic exploration with undo mechanism

---

### Day 13: MOCK INTERVIEW DAY 🎤
**Simulate Real Interview Conditions:**

**Morning Session (3 problems, 45 min each):**
- [ ] [Valid Anagram](https://leetcode.com/problems/valid-anagram/) - Easy warmup
- [ ] [Merge Intervals](https://leetcode.com/problems/merge-intervals/) - Medium
- [ ] [Lowest Common Ancestor of Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) - Medium

**Interview Simulation Rules:**
1. Set 45-min timer per problem
2. **Speak out loud** - explain your thinking
3. Follow the framework: Clarify → Example → Approach → Code → Test
4. Don't look at solutions until time's up
5. After each problem, write what you could improve

**Afternoon Session (2 problems):**
- [ ] [Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/) - Medium
- [ ] [Implement Trie](https://leetcode.com/problems/implement-trie-prefix-tree/) - Medium

**Evening: Self-Review**
- [ ] What patterns did you recognize?
- [ ] Where did you get stuck?
- [ ] Were you able to explain clearly?
- [ ] Did you test your code?

---

### Day 14: Final Review & OOP Design Practice
**Morning: Weak Areas Reinforcement**
- [ ] Review Day 13 problems and solutions
- [ ] Redo 2-3 problems you struggled with most
- [ ] Write down all patterns on one page

**Afternoon: OOP Design Practice**

**Design Problem 1: Library Management System**
- [ ] Design classes: Book, Member, Library, Librarian
- [ ] Implement: borrowBook(), returnBook(), searchBook()
- [ ] Apply: Encapsulation, Inheritance (different book types)

**Design Problem 2: Parking Lot System**
- [ ] Design classes: ParkingLot, ParkingSpot, Vehicle, Ticket
- [ ] Implement: parkVehicle(), removeVehicle(), calculateFee()
- [ ] Apply: Polymorphism (different vehicle types)

**Design Problem 3: Deck of Cards**
- [ ] Design classes: Card, Deck, Hand, Game
- [ ] Implement: shuffle(), dealCard(), compareCards()
- [ ] Apply: Abstraction, Composition

**OOP Quick Reference:**
```
SOLID Principles (know basics):
S - Single Responsibility
O - Open/Closed
L - Liskov Substitution
I - Interface Segregation
D - Dependency Inversion
```

**Evening: Final Prep**
- [ ] Review all pattern notes
- [ ] Practice introducing yourself
- [ ] Prepare 2-3 questions to ask interviewer
- [ ] Get good sleep!

---

## 🎯 Interview Day Checklist

### Before the Interview:
- [ ] Get 7-8 hours sleep
- [ ] Eat a good breakfast
- [ ] Review pattern cheat sheet (don't cram)
- [ ] Test your setup (internet, IDE, etc.)
- [ ] Have water nearby

### During the Interview - THE FRAMEWORK:

**1. CLARIFY (2 min)**
- [ ] Restate the problem in your own words
- [ ] Ask about edge cases: empty input? nulls? duplicates?
- [ ] Ask about constraints: size limits? time/space requirements?
- [ ] Confirm input/output format

**2. EXAMPLE (2 min)**
- [ ] Work through 1-2 examples manually
- [ ] Include an edge case example
- [ ] Show your thinking process

**3. APPROACH (3-5 min)**
- [ ] Explain your approach BEFORE coding
- [ ] Mention time/space complexity
- [ ] Ask if they want you to proceed
- [ ] Discuss trade-offs if multiple approaches exist

**4. CODE (15-20 min)**
- [ ] Write clean, readable code
- [ ] Use meaningful variable names
- [ ] Add comments for complex logic
- [ ] Think out loud as you code

**5. TEST (5 min)**
- [ ] Walk through code with your example
- [ ] Test edge cases
- [ ] Fix any bugs you find

### Common Interview Mistakes to AVOID:
- ❌ Starting to code immediately without discussing approach
- ❌ Going silent for long periods
- ❌ Giving up too easily
- ❌ Not asking clarifying questions
- ❌ Using poor variable names (i, j, k everywhere)
- ❌ Not considering edge cases
- ❌ Not testing your code

---

## 📚 Pattern Cheat Sheet

### Arrays/Strings:
- Two Pointers: sorted array, palindrome, pair sum
- Sliding Window: subarray/substring with condition
- Prefix Sum: range sum queries

### Linked Lists:
- Dummy Node: modifying head
- Fast/Slow: cycle detection, middle node
- Reverse: iterative with 3 pointers

### Stacks/Queues:
- Stack: matching pairs, next greater element, DFS
- Queue: BFS, level-order traversal
- Monotonic Stack: next greater/smaller in O(n)

### Trees:
- DFS: Inorder/Preorder/Postorder
- BFS: Level-order traversal
- Recursion: height, diameter, path sum

### Graphs:
- BFS: shortest path, level-by-level
- DFS: explore all paths, detect cycles
- Always track visited nodes

### Dynamic Programming:
- Identify overlapping subproblems
- Define state: dp[i] = answer for size i
- Recurrence: dp[i] = f(dp[i-1], dp[i-2], ...)

---

## 🔧 Language-Specific Quick Reference

### Java Essentials:
```java
// Collections
ArrayList<Integer> list = new ArrayList<>();
HashMap<String, Integer> map = new HashMap<>();
HashSet<Integer> set = new HashSet<>();
Stack<Integer> stack = new Stack<>();
Queue<Integer> queue = new LinkedList<>();

// Common operations
map.getOrDefault(key, 0);
map.put(key, map.getOrDefault(key, 0) + 1);
Collections.sort(list);
list.toArray(new Integer[0]);
```

### C++ Essentials:
```cpp
// Containers
vector<int> vec;
map<string, int> mp;
unordered_map<string, int> ump;
set<int> st;
stack<int> stk;
queue<int> q;

// Common operations
mp[key]++; // auto-initializes to 0
sort(vec.begin(), vec.end());
vec.push_back(val);
```

---

## 💪 Confidence Boosters

**You Know More Than You Think:**
- ✅ You can implement basic DS from scratch
- ✅ You understand core algorithms
- ✅ You have strong OOP knowledge
- ✅ You can solve medium problems
- ✅ You have 2 weeks to sharpen these skills

**Remember:**
- Interviewers want you to succeed
- Asking questions shows thoughtfulness
- It's okay to think out loud
- Small bugs are normal - just fix them
- Explaining your approach > perfect code

**Final Words:**
You have a strong foundation. This plan focuses on **pattern recognition** and **interview technique** - the two things that matter most. Trust the process, stay consistent, and you'll do great!

---

## 📝 Daily Progress Tracker

Track your daily progress:
- Day 1: ___/5 problems | Feeling: ____
- Day 2: ___/5 problems | Feeling: ____
- Day 3: ___/5 problems | Feeling: ____
- Day 4: ___/5 problems | Feeling: ____
- Day 5: ___/5 problems | Feeling: ____
- Day 6: ___/5 problems | Feeling: ____
- Day 8: ___/5 problems | Feeling: ____
- Day 9: ___/5 problems | Feeling: ____
- Day 10: ___/5 problems | Feeling: ____
- Day 11: ___/5 problems | Feeling: ____
- Day 12: ___/5 problems | Feeling: ____
- Day 13: Mock Interview Complete: ____
- Day 14: Ready! 💪

**Good luck! You've got this! 🚀**