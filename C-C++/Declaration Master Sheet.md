

# C++ Declaration Master Sheet 🛡️

> [!TIP] The Golden Rule: Right-to-Left
> 
> To understand any complex declaration, start from the variable name and read backwards (from right to left).
> 
> Always prioritize parentheses () over everything else.

---

## 1. Pointers & References Basics

| **Syntax**    | **Read As**        | **Meaning**                                                | **⚠️ Exam Trap**                                     |
| ------------- | ------------------ | ---------------------------------------------------------- | ---------------------------------------------------- |
| `int* p;`     | Pointer to int     | A variable holding the **address** of an integer.          | Can be `nullptr`.                                    |
| `int& r = x;` | Reference to int   | An **alias** (nickname) for `x`. They are the same entity. | **Must** be initialized immediately. Cannot be NULL. |
| `int *p, q;`  | p is ptr, q is int | `p` is a pointer, but `q` is just a normal `int`!          | The `*` only applies to the immediate variable name. |
| `int **ptr;`  | Pointer to Pointer | A pointer holding the address of another pointer.          | Used for dynamic 2D arrays.                          |
| `void* p;`    | Void Pointer       | A generic pointer (can point to int, float, etc.).         | Cannot be dereferenced (`*p`) without casting.       |

---

## 2. The `const` Nightmare (Right-to-Left Rule)

> [!EXAMPLE] How to read:
> 
> Start at the variable name and look left.
> 
> - Is `const` next to the **type**? → The **Data** is constant.
>     
> - Is `const` next to the **variable name**? → The **Address** is constant.
>     

|**Syntax**|**Read Right-to-Left ⬅️**|**Interpretation**|**Summary**|
|---|---|---|---|
|`const int* p;`|`p` is a ptr to `const int`|You can move the pointer, but you **cannot change the value** inside.|**Read-only Data**|
|`int const* p;`|(Same as above)|Same meaning. `const` is before the `*`.|**Read-only Data**|
|`int* const p;`|`p` is a `const` ptr to `int`|You **cannot move the pointer** (fixed address), but you can change the value inside.|**Fixed Address**|
|`const int* const p;`|`const` ptr to `const int`|Maximum security. Neither the address nor the value can change.|**Totally Constant**|

---

## 3. Arrays vs. Pointers (The Parenthesis Trap) 👹

This is the most common exam trick. Look for the **Parentheses `()`**.

|**Syntax**|**Type**|**Meaning**|**Visualization**|
|---|---|---|---|
|`int* arr[5];`|**Array of Pointers**|An array of 5 slots. Each slot holds a pointer (`int*`).|`[ptr] [ptr] [ptr] [ptr] [ptr]`|
|`int (*ptr)[5];`|**Pointer to Array**|A **single pointer**. It points to a whole array of 5 integers.|`ptr` ➡️ `[int, int, int, int, int]`|
|`int arr[5];`|Normal Array|`arr` decays into a `const pointer` to the first element.|`arr` $\approx$ `&arr[0]`|

> [!NOTE] Quick Check
> 
> - **`(*ptr)` inside brackets:** It is ONE pointer (protected by the shield).
>     
> - **`*arr` exposed:** It is MANY pointers (an array).
>     

---

## 4. Functions & Returns

|**Syntax**|**Context**|**Critical Warning ⚠️**|
|---|---|---|
|`int* func();`|Return by Address|**Never** return the address of a local variable (stack memory). It leads to a Dangling Pointer.|
|`int& func();`|Return by Reference|Returns the actual object. Used in `Operator Overloading` (e.g., `a=b=c`).|
|`void f(int* p)`|Pass by Address|Function can modify original value. Must use `->` or `*`.|
|`void f(int& r)`|Pass by Reference|Function modifies original value. Cleaner syntax (no `*` needed).|
|`void f(const int& r)`|Pass by Const Ref|**Best Practice.** Fast (no copying) + Safe (no modification).|

---

## 5. Dynamic Memory (Heap)

|**Allocation**|**Deallocation**|**Note**|
|---|---|---|
|`int* p = new int;`|`delete p;`|Allocates single integer.|
|`int* p = new int[5];`|`delete[] p;`|Allocates array. **Must use `[]` to delete!**|

---

> [!success] Next Step
> 
> Copy this into your Obsidian vault.
> 
> Now, do you want to apply this cheat sheet to solve the "Mini Exam" questions we discussed earlier? (Specifically the array pointer arithmetic question)?