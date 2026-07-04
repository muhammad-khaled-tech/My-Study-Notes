---
tags: [python, interview-prep, بايثون-من-الصفر]
part: 1
covers: "Variables · Data Types · Operators · Strings · Collections · Control Flow · Functions · Exception Handling · Built-ins Toolbox"
---

# 🐍 بايثون من الصفر — الأساسيات (Q1 → نهاية الملف)

> [!info] 📖 إزاي تذاكر الملف ده؟
> الملف ده بيغطي موضوعات 1 لـ 8 زائد ملحق للـ built-in functions، وكل سؤال بيبني على اللي قبله. اقرا بالترتيب، ونفّذ الكود بنفسك، وركز على الـ callouts عشان تعرف الفروق الدقيقة اللي بتسأل عنها في الإنترفيوهات.

---

## Q1 — إيه الـ Variable في بايثون وإزاي بايثون بتشوف "الاسم" و"الـ object" كحاجتين مختلفتين؟

### أصل الحكاية
في بايثون، لما إنت بتكتب `x = 10`، إنت مش بتعمل صندوق حطيت فيه رقم 10 زي ما بنتعلم في المدرسة. لا، بايثون بتعمل حاجتين منفصلتين: حاجة اسمها "الـ object" (وده البيانات الحقيقية اللي راكب في الميموري وعنده نوعه زي int أو string)، وحاجة تانية اسمها "الـ Name" أو الـ variable (وده مجرد لاصق بروقو أو بطة بتكتب عليها "x" وتلصقها على الـ object ده). يعني الـ variable مجرد عنوان أو reference بيشاور على الـ object الحقيقي اللي في الميموري.

```python
# Creating an object '10' in memory, and attaching a label 'x' to it
x = 10

# Checking the identity (memory address) of the object 'x' points to
print(id(x)) # e.g., 140731853342120 (some memory address)

# Checking the type of the object 'x' points to
print(type(x)) # <class 'int'>

# Reassigning 'x' to a new object '20'
x = 20
print(id(x)) # e.g., 140731853342440 (different memory address!)
# The '10' object is now orphaned if nothing else points to it
```

**Snippet 1: حالة بسيطة (أكتر من اسم لنفس الـ object)**
```python
a = [1, 2, 3]
b = a # 'b' is just another label pointing to the SAME list object

b.append(4)
print(a) # [1, 2, 3, 4] -> 'a' sees the change because they are the same object
print(a is b) # True
```

**Snippet 2: edge case (إعادة التسمية)**
```python
x = "Hello"
y = x # 'y' points to "Hello"
x = "World" # 'x' now points to a NEW object "World"

print(y) # Hello -> 'y' still points to the original "Hello" object
print(x) # World
```

**Snippet 3: حالة عملية (تمرير مرجع لفانكشن)**
```python
def modify_list(lst):
    # 'lst' here is a local label pointing to the SAME object passed in
    lst.append(100)

my_list = [1, 2]
modify_list(my_list)
print(my_list) # [1, 2, 100] -> The original list was modified
```

### الفايدة الانترفيوية
**"Explain how variables work in Python. Are they containers for values?"**
الإجابة: لا، الـ variables في بايثون مش حاويات (containers)، هي مجرد أسماء (names) أو مراجع (references) بتشاور على الـ objects اللي في الميموري. لما بتعمل assignment، بايثون بتعمل object جديد (لو القيمة جديدة) وبتلصق الاسم عليه. كده أي تعديل على الـ object من خلال أي اسم بيتشاف من كل الأسماء التانية اللي بتشاور على نفس الـ object.

> [!tip] Checkpoint
> الـ variable في بايثون هو مجرد post-it note بتلصقه على object في الميموري. الـ object هو اللي ليه نوع (type) و(identity)، مش الاسم.

> [!danger] فخ خطير
> لو فاكر إن لما بتعمل `y = x` بايثون بتعمل نسخة من القيمة، هتدمر الدنيا لما بتعدل على lists أو dicts. `y = x` بتعمل اسم جديد لنفس الـ object بالظبط.

---

## Q2 — إيه قواعد التسمية الإجبارية وإيه الـ PEP 8 conventions المتعارف عليها؟

### أصل الحكاية
عشان تسمي variable أو function في بايثون، فيه قواعد قانونية لو كسرتها بايثون هتزعق وتقولك SyntaxError، وفيه قواعد ذوق وكونفنشن (conventions) لو كسرتها، المبرمجين اللي هيشتغلوا معاك هيكرهوك ووقت الإنترفيو هيوقعوك. القوانين الإجبارية بتقول: الاسم لازم يبدأ بحرف أو (underscore)، وميبدأش برقم، وميكونش فيه مسافات أو رموز غريبة زي `@` أو `$`. أما الـ conventions (الـ PEP 8) فهي بتدي شكل محدد لكل حاجة عشان من أول نظرة تعرف ده فاريبل ولا كلاس ولا ثابت.

```python
# Valid Python variable names
user_name = "Ahmed" # Starts with a letter
_private_var = 42   # Starts with an underscore
__very_private = 99 # Double underscore (name mangling - advanced)

# Invalid names (will cause SyntaxError)
# 2nd_user = "Mahmoud" -> Starts with a number
# user-name = "Sara"   -> Contains a hyphen (Python thinks it's subtraction)
# user name = "Ali"    -> Contains a space
```

**Snippet 1: حالة بسيطة (PEP 8 basics)**
```python
# PEP 8 Naming Conventions
my_variable = 10         # Variables and functions: snake_case
MAX_CONNECTIONS = 100    # Constants: UPPER_SNAKE_CASE
class UserProfile:       # Classes: PascalCase (or CapWords)
    pass
```

**Snippet 2: edge case (الـ Underscore semantics)**
```python
_single_underscore = "Internal use hint" # Tells devs: please don't touch this outside the module
double_underscore__ = "Name mangling"    # Used in classes, e.g., __name becomes _ClassName__name
_ = "Throwaway variable"                 # Conventionally used when you don't care about the value

for _ in range(5):
    print("Looping") # We don't use the loop variable
```

**Snippet 3: حالة عملية (بناء اسم من parts)**
```python
prefix = "user"
suffix = "count"
# Dynamically naming is bad practice, but this shows valid string assembly
variable_name = f"{prefix}_{suffix}"
# Better to use a dictionary instead of dynamic variables in real code
data = {variable_name: 42}
print(data["user_count"]) # 42
```

### الفايدة الانترفيوية
**"What are the PEP 8 naming conventions for variables, functions, classes, and constants?"**
الإجابة: الـ variables والـ functions بتتكتب بـ snake_case (حروف صغيرة وكلمة بينها underscore). الـ classes بتتكتب بـ PascalCase (أول حرف من كل كلمة كابيتال). الـ constants بتتكتب بـ UPPER_SNAKE_CASE (كل الحروف كابيتال وبينها underscore). والـ internal/non-public methods أو variables بت prefixed بـ underscore واحد.

> [!warning] فخ شائع
// لاحظ هنا الكومنت إنجليزي بس
# Using camelCase for variables is legal but bad style
myVariableName = 10 # Works, but fails PEP 8 checks
```

> [!tip] Checkpoint
# القانوني: بداية بحرف أو _، ومفيش مسافات أو رموز.
# الذوق: variables=snake_case, Classes=PascalCase, Constants=UPPER_CASE.

---

## Q3 — إيه معنى إن بايثون Dynamically Typed وإيه الفرق بين dynamic وstatic typing؟

### أصل الحكاية
في بايثون، إنت مش بتحدد نوع المتغير (الـ type) قبل ما تستخدمه. بايثون بتقولك "اكتب القيمة وأنا هعرف نوعها بنفسي". ده معناه إن نفس الاسم ممكن يشاور على رقم في سطر، وبعدين في السطر اللي بعده يشاور على نص. بايثون بتعمل check على نوع الـ object وقت التشغيل (runtime)، مش وقت الكتابة (compile time). ده اللي بنسميه Dynamic Typing.

```python
# Dynamic typing: the variable 'x' changes type based on the object assigned
x = 10           # 'x' is pointing to an int object
print(type(x))   # <class 'int'>

x = "Hello"      # 'x' is now pointing to a str object
print(type(x))   # <class 'str'>

x = [1, 2, 3]    # 'x' is now pointing to a list object
print(type(x))   # <class 'list'>
```

**Snippet 1: حالة بسيطة (Type changes at runtime)**
```python
def process_data(data):
    # This function accepts any type, Python checks methods at runtime
    print(data)

process_data(10)        # Passes int
process_data("String")  # Passes str
```

**Snippet 2: edge case (Duck Typing)**
```python
# Python doesn't care about the type, only if it has the required method
class Duck:
    def speak(self): return "Quack"

class Person:
    def speak(self): return "Hello"

def make_sound(entity):
    # We don't check the type, we just call .speak()
    print(entity.speak())

make_sound(Duck())   # Quack
make_sound(Person()) # Hello
```

**Snippet 3: حالة عملية (Type Hinting - Static Typing in Dynamic language)**
```python
# Python 3+ Type hints: they don't enforce types at runtime, but help linters
def add_numbers(a: int, b: int) -> int:
    return a + b

# This will run fine at runtime, despite the hint!
result = add_numbers(5, "10") 
# TypeError happens later if we try to add int and str, but the call itself doesn't fail immediately
```

### الفايدة الانترفيوية
**"What's the difference between statically typed and dynamically typed languages?"**
الإجابة: في الـ statically typed languages، لازم تعلن عن نوع المتغير قبل ما تستخدمه، والمترجم (compiler) بيرفض الكود لو الأنواع مش متطابقة. أما في بايثون (dynamically typed)، إنت مش بتعرف الأنواع، والنوع بيتحدد وقت الـ runtime بناءً على الـ object اللي المتغير بيشاور عليه. بايثون بتعمل check على الأنواع وقت تنفيذ العمليات (operations)، وممكن نستخدم Type Hints عشان الـ linters والـ IDEs يساعدونا من غير ما نكسر طبيعة اللغة الـ dynamic.

> [!danger] فخ خطير
# Type hints (a: int = 5) are just annotations! They do NOT prevent assigning a string later.
a: int = 5
a = "Hello" # This runs perfectly fine in Python without errors.
```

> [!tip] Checkpoint
# Dynamic typing معناها النوع بيتحدد وقت التشغيل بناءً على القيمة، والاسم ممكن يشاور على أنواع مختلفة في أوقات مختلفة.

---

## Q4 — إيه الفرق الحقيقي بين `is` و`==`؟ (Small Integer Cache وString Interning)

### أصل الحكاية
الـ `==` بيسأل سؤال: "هل القيمة اللي جوه الـ object ده نفس القيمة اللي جوه الـ object ده التاني؟". أما الـ `is` فبيسأل سؤال تاني خالص: "هل الاسمين دول بيشاوروا على نفس الـ object في نفس مكان الميموري؟". يعني `is` بتقارن الـ identity (العنوان في الميموري)، و`==` بتقارن الـ value. بايثون عشان توفر في الميموري وتبقى سريعة، بتعمل حاجة اسمها caching للأرقام الصغيرة (من -5 لـ 256) وبعض الـ strings، يعني بتعمل object واحد لكل رقم وتخلي كل المتغيرات تشاور عليه، وده اللي بيخلي `a is b` ترجع True في حالات معينة مش هتكون True مع أرقام كبيرة.

```python
# '==' checks for value equality
a = [1, 2, 3]
b = [1, 2, 3]
print(a == b) # True -> Same values inside
print(a is b) # False -> Different objects in memory

# 'is' checks for identity (same memory address)
c = a
print(a is c) # True -> 'c' is just another label for the exact same object as 'a'
```

**Snippet 1: حالة بسيطة (Small Integer Caching)**
```python
# Python caches integers from -5 to 256
x = 100
y = 100
print(x is y) # True -> Same cached object

w = 1000
z = 1000
print(w is z) # False -> Outside cache range, created separate objects
```

**Snippet 2: edge case (String Interning)**
```python
# Python interns some strings automatically (usually valid identifiers)
s1 = "hello_world"
s2 = "hello_world"
print(s1 is s2) # True -> Interned because it looks like an identifier

s3 = "hello world!"
s4 = "hello world!"
print(s3 is s4) # False -> Not interned automatically (space and !)
```

**Snippet 3: حالة عملية (Checking against None)**
```python
# Best practice for checking None is using 'is', not '=='
def find_user(user_id):
    if user_id == 999:
        return None
    return {"id": user_id}

user = find_user(999)

# Correct way
if user is None:
    print("User not found")

# Wrong way (works, but can be overridden by custom __eq__ methods)
if user == None:
    print("User not found (bad practice)")
```

### الفايدة الانترفيوية
**"What's the difference between `is` and `==`? Explain Small Integer Caching."**
الإجابة: `==` بتستدعي الـ `__eq__` method عشان تقارن القيم، أما `is` فبتقارن الـ memory addresses (الـ id). بايثون بيحتفظ بـ objects للأرقام من -5 لـ 256 (Small Integer Caching) وكمان بـ intern الـ strings اللي شكلها زي أسماء المتغيرات، عشان يعيد استخدامها ويوفر ميموري. عشان كده `a is b` ممكن تطلع True لأرقام صغيرة حتى لو معملناش assignment لبعض. وقاعدة ذهبية: دايماً استخدم `is None` مش `== None` لأن `None` هو object واحد (Singleton) في بايثون.

> [!warning] فخ شائع
# Never rely on caching for your logic!
# Just because `x is y` is True for 256 doesn't mean it's safe to use 'is' for integer comparison.
a = 256
b = 256
print(a is b) # True

a = 257
b = 257
print(a is b) # Might be False in interactive mode!
```

> [!danger] فخ خطير
# Comparing mutable objects like lists using 'is' when you meant '=='
list1 = [1,2]
list2 = [1,2]
if list1 is list2: # False! This block will never run
    print("Same list")
```

---

## Q5 — إيه معنى Mutable وImmutable وليه ده مهم؟ (مع الـ default mutable argument trap)

### أصل الحكاية
الـ Immutable معناها إن الـ object اللي إنت عملته، محتواه مش ممكن يتغير بعد ما اتعمل. لو حبيت تعدله، بايثون بتعمل object جديد خالص وتشاور عليه. زي الـ strings والـ ints والـ tuples. الـ Mutable معناها إنك ممكن تغير محتوى الـ object في نفس مكانه من غير ما بايثون تعمل object جديد، زي الـ lists والـ dicts. المشكلة الكبيرة بتحصل لما نستخدم mutable object كـ default argument في الـ function، لأن بايثون بتعمل الـ object ده مرة وحدة بس وقت تعريف الـ function، وكل مرة تناديها من غير ما تبعت القيمة، بتستخدم نفس الـ object بالتعديلات اللي حصلت فيه آخر مرة!

```python
# Immutable example
x = 10
print(id(x)) # 140...
x = x + 1    # We are NOT modifying the '10' object. We create a new '11' object.
print(id(x)) # 144... (different id)

# Mutable example
my_list = [1, 2]
print(id(my_list)) # 200...
my_list.append(3)  # We modify the list in place
print(id(my_list)) # 200... (same id!)
```

**Snippet 1: حالة بسيطة (The Default Mutable Argument Trap)**
```python
# The trap: the list is created ONCE when the function is defined
def add_item(item, my_list=[]):
    my_list.append(item)
    return my_list

print(add_item(1)) # [1]
print(add_item(2)) # [1, 2] -> The list persisted from the previous call!
print(add_item(3)) # [1, 2, 3]
```

**Snippet 2: الحل (The fix)**
```python
# Correct way: use None as default and create a new list inside
def add_item_safe(item, my_list=None):
    if my_list is None:
        my_list = [] # Creates a fresh list every time function is called without the arg
    my_list.append(item)
    return my_list

print(add_item_safe(1)) # [1]
print(add_item_safe(2)) # [2] -> Fresh list
```

**Snippet 3: edge case (Tuple immutability is shallow)**
```python
# Tuples are immutable, but what if they contain mutable objects?
my_tuple = (1, 2, [3, 4])
# my_tuple[0] = 10 -> TypeError: 'tuple' object does not support item assignment

# But we can modify the list INSIDE the tuple!
my_tuple[2].append(5)
print(my_tuple) # (1, 2, [3, 4, 5])
```

### الفايدة الانترفيوية
**"What is the default mutable argument trap in Python, and how do you fix it?"**
الإجابة: لما بتستخدم mutable object (زي list أو dict) كـ default argument في الـ function، بايثون بتعمل الـ object ده مرة وحدة بس وقت الـ definition (وقت تحميل الموديول)، ومش بتعمله جديد مع كل call. فلو عدلت عليه، التعديل بيفضل موجود في الـ calls اللي جاية. الحل هو إنك تحط default قيمته `None`، وجوه الفانكشن تعمل check `if my_list is None: my_list = []`.

> [!tip] Checkpoint
# Immutable: int, float, str, tuple, bool. (Any change makes a new object).
# Mutable: list, dict, set. (Changes happen in place).
# Default args are evaluated at function definition time, not call time.

> [!danger] فخ خطير
# Thinking a tuple with a list inside is completely immutable.
t = ([1],)
t[0] += [2] # This actually modifies the list, but throws an Error AND modifies it!
# (Because += on a list modifies in place, then tuple tries to reassign the item and fails)
print(t) # ([1, 2],)
```

---

## Q6 — إزاي بايثون بتدير الميموري بالـ Reference Counting؟ وإمتى بيجي الـ Garbage Collector؟

### أصل الحكاية
بايثون عشان تعرف إمتى تمسح الـ object من الميموري، بتستخدم نظام اسمه Reference Counting. كل object في بايثون جواه عداد (counter). كل ما تضيف اسم (reference) بيشاور على الـ object، العداد يزيد 1. كل ما تمسح اسم أو يشاور على حاجة تانية، العداد يقل 1. لما العداد يوصل لـ 0، بايثون بتعرف إن مفيش حد محتاج الـ object ده، فبت مسحه فوراً. بس فيه مشكلة اسمها "مرجع دائري" (Circular Reference) زي ما يكون list بيشاور على نفسه، هنا العداد مش هينزل لـ 0، وهنا بيدخل الـ Garbage Collector (GC) اللي بيدور ورا الحلقات دي وينظفها.

```python
import sys

a = [1, 2, 3]
# sys.getrefcount(a) returns the count. Note: passing 'a' as an argument adds 1 temporarily!
print(sys.getrefcount(a)) # 2 (one for 'a', one for the argument in getrefcount)

b = a
print(sys.getrefcount(a)) # 3 (now 'b' also points to it)

c = b
print(sys.getrefcount(a)) # 4

del b
print(sys.getrefcount(a)) # 3

del c
print(sys.getrefcount(a)) # 2
```

**Snippet 1: حالة بسيطة (Reference count dropping to zero)**
```python
x = [10, 20]
# The list object has a refcount of 1 (from 'x')
y = x
# refcount is 2
x = None
# refcount is 1 (only 'y' remains)
y = None
# refcount is 0 -> Python immediately deallocates the list from memory
```

**Snippet 2: edge case (Circular Reference)**
```python
import gc

# We disable GC to see the effect manually
gc.disable()

list1 = []
list2 = []

list1.append(list2) # list1 contains list2
list2.append(list1) # list2 contains list1 -> Circular reference!

del list1
del list2
# Even though we deleted the names, the objects still reference each other.
# Reference count is NOT zero. Memory leak!
# The GC (when enabled) specifically looks for these cycles to clean them up.
gc.enable()
# GC will eventually find and collect these unreachable cycles.
```

**Snippet 3: حالة عملية (Checking GC behavior)**
```python
import gc

class MyObject:
    def __del__(self):
        print("MyObject is being destroyed!")

obj1 = MyObject()
obj2 = MyObject()
obj1.ref = obj2
obj2.ref = obj1

# Create a cycle and remove outer references
del obj1
del obj2

# Force garbage collection
collected = gc.collect()
print(f"GC collected {collected} objects.")
# Output will show "MyObject is being destroyed!" twice
```

### الفايدة الانترفيوية
**"How does Python manage memory? Explain Reference Counting and the role of the Garbage Collector."**
الإجابة: بايثون بتعتمد أساساً على الـ Reference Counting؛ كل object ليه عداد، لما يوصل صفر بيتمسح. المشكلة الوحيدة في النظام ده هي الـ circular references (زي ما كائن A يشاور على B وB يشاور على A). هنا العداد مش هيوصل صفر، وهنا بيجي دور الـ Garbage Collector (GC) اللي بيشتغل في الخلفية وبيمسح الحلقات دي عشان يمنع الـ memory leaks.

> [!warning] فخ شائع
# sys.getrefcount(x) will always return at least 2 if you just created 'x'.
# Why? Because 'x' holds a reference, and passing 'x' into the function creates a second reference on the call stack!
```

> [!tip] Checkpoint
# Reference counting is immediate. GC is for circular references.
# You don't usually manage memory manually in Python, but knowing this explains unexpected object lifetimes.

---

## Q7 — إيه الـ Shallow Copy والـ Deep Copy وإمتى تستخدم كل واحدة؟

### أصل الحكاية
لما إنت عملت list جواها list (nested list)، وعملت `copy()` أو `list(old_list)`، بايثون بتعمل نسخة من الـ list الخارجية، بس العناصر اللي جواها (اللي هي الـ lists الداخلية) لسه بتشاور على نفس الـ objects الأصلية. ده اسمه Shallow Copy (نسخة سطحية). لو عدلت في الـ list الداخلية، الأصلية والنسخة الاتنين هيتعدلوا. عشان تعمل نسخة مستقلة تماماً لحد أعمق عنصر جوه عنصر، لازم تستخدم Deep Copy من الـ `copy` module.

```python
import copy

original = [[1, 2], [3, 4]]

# Shallow copy
shallow = copy.copy(original)
shallow[0][0] = 99

print("Original:", original) # Original: [[99, 2], [3, 4]] -> Inner list was shared!
print("Shallow:", shallow)   # Shallow: [[99, 2], [3, 4]]
```

**Snippet 1: حالة بسيطة (Shallow copy methods)**
```python
list1 = [1, 2, 3]
# These three create shallow copies (works fine for flat lists of immutables)
list2 = list1.copy()
list3 = list(list1)
list4 = list1[:]

list2.append(4)
print(list1) # [1, 2, 3] -> Unaffected because the integers are immutable, and we just appended to list2
```

**Snippet 2: edge case (Shallow copy vs Deep copy with nested mutables)**
```python
import copy

matrix = [[1, 2], [3, 4]]

# Shallow copy
shallow = copy.copy(matrix)
shallow[0].append(99)
print("Matrix:", matrix) # Matrix: [[1, 2, 99], [3, 4]] -> Ouch! Original mutated.

# Deep copy
deep = copy.deepcopy(matrix)
deep[0].append(88)
print("Matrix after deep:", matrix) # Matrix after deep: [[1, 2, 99], [3, 4]] -> Original safe!
print("Deep:", deep) # Deep: [[1, 2, 99, 88], [3, 4]]
```

**Snippet 3: حالة عملية (Complex object graph)**
```python
import copy

class Box:
    def __init__(self, items):
        self.items = items

    def __repr__(self):
        return f"Box({self.items})"

box1 = Box([1, 2, 3])
box2 = copy.copy(box1)       # Shallow: new Box, same list
box3 = copy.deepcopy(box1)   # Deep: new Box, new list

box2.items.append(4)
print(box1) # Box([1, 2, 3, 4]) -> Same list reference

box3.items.append(5)
print(box1) # Box([1, 2, 3, 4]) -> Completely independent
```

### الفايدة الانترفيوية
**"What's the difference between shallow copy and deep copy?"**
الإجابة: الـ Shallow copy بتعمل object جديد، بس بتنسخ الـ references اللي جواه بالظبط (يعني لو الـ object فيه lists تانية، النسخة هتشاور على نفس الـ lists). الـ Deep copy بتعمل object جديد وبتدور recursive عشان تعمل نسخة جديدة من أي object جواه. بنستخدم `copy.copy()` للـ shallow و`copy.deepcopy()` للـ deep.

> [!danger] فخ خطير
# Assuming `list.copy()` or `list[:]` makes your nested lists independent.
# It only copies the top level. If you have mutables inside mutables, changes will leak!
original = [[1], [2]]
new = original[:]
new[0][0] = 99
print(original[0][0]) # 99! It's not a deep copy.
```

> [!tip] Checkpoint
# Shallow = new container, same items.
# Deep = new container, recursively new items.
# Use copy module for both.
```

---

## Q8 — إيه الـ LEGB Rule وإزاي بايثون بتدور على أي اسم؟ (`global` وـ`nonlocal`)

### أصل الحكاية
لما إنت تكتب اسم متغير جوه فانكشن، بايثون بتدور على ده اسم فين؟ ليها ترتيب معين ثابت اسمه LEGB. L يعني Local (جوه الفانكشن الحالية). E يعني Enclosing (جوه الفانكشن اللي شالة الفانكشن دي، في حالة الـ closures). G يعني Global (في الموديول، بره كل الفانكشنز). B يعني Built-in (الحاجات اللي بايثون جايبها معاها زي `print` و`len`). لو حبيت أعدل على متغير global من جوه فانكشن، لازم أكتب `global x` عشان أقولها "متعملش متغير جديد محلي، عدل على اللي بره". ولو حبيت أعدل على متغير من فانكشن أب (Enclosing)، أستخدم `nonlocal x`.

```python
x = "global x"

def outer():
    x = "enclosing x"
    
    def inner():
        x = "local x"
        print(x) # Finds 'local x' first (L)
        
    inner()
    print(x) # Finds 'enclosing x' (E)

outer()
print(x) # Finds 'global x' (G)
```

**Snippet 1: حالة بسيطة (Modifying a global variable)**
```python
counter = 0

def increment():
    global counter # Tells Python we mean the 'counter' in the global scope
    counter += 1

increment()
increment()
print(counter) # 2
```

**Snippet 2: edge case (Using nonlocal)**
```python
def make_counter():
    count = 0
    
    def inner():
        nonlocal count # Tells Python we mean the 'count' in 'make_counter' (E)
        count += 1
        return count
        
    return inner

c = make_counter()
print(c()) # 1
print(c()) # 2
```

**Snippet 3: حالة عملية (Shadowing built-ins)**
```python
# Don't do this, but it shows the 'B' level being overridden
def my_func(list=[]): # 'list' is a built-in, but here it's used as an argument name
    list.append(1)
    return list

print(my_func()) # [1]
# The built-in list() is shadowed only within this function's scope
```

### الفايدة الانترفيوية
**"Explain the LEGB rule in Python. What is the difference between `global` and `nonlocal`?"**
الإجابة: LEGB هو ترتيب بحث بايثون عن الأسماء: Local، Enclosing، Global، Built-in. `global` بتستخدم عشان تعلن إنك بتعدل على متعر في الـ Global scope. `nonlocal` بتستخدم جوه nested function عشان تعلن إنك بتعدل على متغير في الـ Enclosing scope (الفانكشن الأب). من غير الكلمتين دول، بايثون هتعمل متغير محلي جديد لو حاولت تعمل assignment.

> [!warning] فخ شائع
# Trying to modify a global without the 'global' keyword
value = 10
def change():
    value += 1 # UnboundLocalError! Python thinks 'value' is local because of the assignment.
```

> [!danger] فخ خطير
# Overwriting built-ins.
list = [1, 2, 3] # You just ruined the built-in 'list()' constructor for your module!
# Now `list("abc")` will throw a TypeError.
```

---

## Q9 — إيه الـ `del` statement وبيحذف الـ object فعلاً ولا بس الاسم؟

### أصل الحكاية
الناس فاكرة إن `del x` معناه "امسح الـ object اللي `x` بيشاور عليه من الميموري". ده مش صحيح خالص. الـ `del` بيمسح الـ "الاسم" (الـ reference) من الـ namespace اللي إنت فيه. بيعني إنه بيشيل البطة اللي مكتوب عليها `x`. لما يشيلها، الـ reference count بتاع الـ object بيقل 1. لو الـ count وصل صفر، الـ object بيتمسح من الميموري تلقائياً (عن طريق الـ reference counting). بس لو في أسماء تانية لسه بيشاوروا عليه، الـ object بيفضل عايش في الميموري.

```python
x = [1, 2, 3]
y = x # Both 'x' and 'y' point to the same list object

del x # Deletes the name 'x' from the namespace

# print(x) -> NameError: name 'x' is not defined

# But the object is still alive because 'y' is still pointing to it!
print(y) # [1, 2, 3]
y.append(4)
print(y) # [1, 2, 3, 4]
```

**Snippet 1: حالة بسيطة (Deleting from a list)**
```python
my_list = ['a', 'b', 'c', 'd']
del my_list[1] # Deletes the item at index 1 ('b')
print(my_list) # ['a', 'c', 'd']

del my_list[0:2] # Deletes a slice
print(my_list) # ['d']
```

**Snippet 2: edge case (Deleting object attributes)**
```python
class Person:
    def __init__(self):
        self.name = "Ali"
        self.age = 30

p = Person()
print(p.name) # Ali

del p.age # Deletes the 'age' attribute from the object
# print(p.age) -> AttributeError: 'Person' object has no attribute 'age'
```

**Snippet 3: حالة عملية (Memory cleanup pattern)**
```python
import sys

large_data = [i for i in range(1000000)]
print(sys.getrefcount(large_data)) # 2

# We are done with 'large_data' and want to free memory immediately
del large_data
# The large list's refcount dropped to 0, memory is freed instantly.
```

### الفايدة الانترفيوية
**"Does `del` delete the object from memory?"**
الإجابة: لأ، الـ `del` بيمسح الـ reference (الاسم) بس. لما تعمل `del x`، بايثون بتفك ارتباط الاسم `x` بالـ object. الـ object بيتمسح من الميموري بس لما الـ reference count بتاعه يوصل لصفر (يعني مفيش أي اسم تاني بيشاور عليه).

> [!tip] Checkpoint
# `del` removes the binding (name), not necessarily the object.
# It can also delete items from lists/keys from dicts.
```

---

## Q10 — إيه الـ `__slots__` وإمتى تستخدمه لتوفير الميموري؟

### أصل الحكاية
أي كلاس تعمله في بايثون، كل object (instance) بتتعمله من الكلاس ده، بايثون بتعمل جواه قاموس (dict) مخبي اسمه `__dict__`. القاموس ده بيتخزن فيه كل الـ attributes (الخصائص) اللي إنت بتضيفها للـ object. ده مرن جداً، لأنك تقدر تضيف خصائص جديدة في أي وقت، بس بياخد ميموري كتير جداً، خصوصاً لو بتعمل ملايين الـ objects. عشان نوفر ميموري، بنستخدم `__slots__`. لما بتعرف `__slots__` في الكلاس، بايثون بتلغي الـ `__dict__` خالص، وتحجز مساحات ثابتة مسبقاً للخصائص اللي إنت كاتبها بس. ده بيخلي الـ object أخف بكتير وأسرع، بس بتفقد المرونة (مينفعش تضيف attribute جديد مش موجود في الـ slots).

```python
class WithoutSlots:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class WithSlots:
    # Pre-declare the allowed attributes
    __slots__ = ['x', 'y']
    
    def __init__(self, x, y):
        self.x = x
        self.y = y

obj1 = WithoutSlots(1, 2)
obj2 = WithSlots(1, 2)

# Without slots, you can add new attributes dynamically
obj1.z = 3 # Works fine

# With slots, you CANNOT add new attributes
# obj2.z = 3 -> AttributeError: 'WithSlots' object has no attribute 'z'
```

**Snippet 1: حالة بسيطة (Memory comparison)**
```python
import sys

obj_no_slots = WithoutSlots(1, 2)
obj_with_slots = WithSlots(1, 2)

# Notice the size difference (this doesn't count the dicts themselves, but shows structural savings)
print(sys.getsizeof(obj_no_slots)) # e.g., 56 bytes + dict overhead
print(sys.getsizeof(obj_with_slots)) # e.g., 48 bytes (no dict overhead)
```

**Snippet 2: edge case (Inheritance with slots)**
```python
class Base:
    __slots__ = ['x']

class Child(Base):
    # If Child doesn't define __slots__, it gets a __dict__ anyway!
    __slots__ = ['y']

c = Child()
c.x = 1
c.y = 2
# c.z = 3 -> AttributeError
```

**Snippet 3: حالة عملية (Data processing with millions of records)**
```python
# A realistic use case: processing millions of records where memory is tight
class Point:
    __slots__ = ('lat', 'lon', 'altitude')
    def __init__(self, lat, lon, alt):
        self.lat = lat
        self.lon = lon
        self.altitude = alt

# Creating 1 million points will use significantly less RAM than without __slots__
points = [Point(1.0, 2.0, 3.0) for _ in range(1000000)]
```

### الفايدة الانترفيوية
**"What are `__slots__` and when would you use them?"**
الإجابة: `__slots__` هي خاصية بتتلغي بيها الـ `__dict__` اللي بايثون بتعمله لكل object، وتستبدلها بمساحات ثابتة للخصائص المحددة بس. بنستخدمها لما بنعمل ملايين الـ objects من نفس الكلاس ونكون محتاجين نوفر ميموري RAM بشكل كبير. العيب الوحيد إننا نفقد المرونة في إضافة خصائص جديدة وقت التشغيل (runtime).

> [!warning] فخ شائع
# Using __slots__ breaks some things, like weak references, unless you explicitly add '__weakref__' to the slots tuple.
class MyObj:
    __slots__ = ['x', '__weakref__']
```

> [!tip] Checkpoint
# __slots__ saves memory by preventing the creation of __dict__.
# It restricts attribute creation to only those listed.
# Good for millions of objects, bad for dynamic/flexible classes.
```

---

## Q11 — إيه الـ built-in types الأساسية في بايثون وإيه الفرق بين كل واحدة؟

### أصل الحكاية
بايثون جاية معاها مجموعة من الأنواع الأساسية (built-in types) اللي بتغطي كل احتياجاتك من غير ما تحمل مكتبات. فيه أرقام (Numeric) زي الـ int وfloat وcomplex. فيه نصوص (Text) زي الـ str. فيه سلاسل (Sequences) زي الـ list والـ tuple والـ range. فيه مجموعات (Sets) زي الـ set والـ frozenset. وفيه قواميس (Mappings) زي الـ dict. أخيراً فيه أنواع زي None وbool. الفرق الأساسي بينهم بيكون في إيه اللي بيخزنوه (قيمة واحدة ولا مجموعة)، هل الترتيب مهم ولا لأ، وهل ممكن أعدل في محتواهم (Mutable) ولا لأ (Immutable).

```python
# Numeric types
an_int = 10
a_float = 3.14
a_complex = 2j

# Text type
a_string = "Hello"

# Sequence types (Ordered)
a_list = [1, 2, 3]        # Mutable
a_tuple = (1, 2, 3)       # Immutable
a_range = range(5)        # Immutable, lazy sequence

# Set types (Unordered, Unique)
a_set = {1, 2, 3}         # Mutable
a_frozenset = frozenset([1, 2, 3]) # Immutable

# Mapping type (Key-Value)
a_dict = {"name": "Ali", "age": 30} # Mutable

# Boolean and None types
is_true = True
nothing = None
```

**Snippet 1: حالة بسيطة (Checking mutability)**
```python
# Lists are mutable
my_list = [1, 2]
my_list[0] = 99
print(my_list) # [99, 2]

# Tuples are immutable
my_tuple = (1, 2)
# my_tuple[0] = 99 -> TypeError: 'tuple' object does not support item assignment
```

**Snippet 2: edge case (Empty collections evaluation)**
```python
# All empty built-in collections evaluate to False
print(bool([]))        # False
print(bool({}))        # False
print(bool(set()))     # False
print(bool(""))        # False
print(bool(()))        # False
print(bool(None))      # False
print(bool(0))         # False
```

**Snippet 3: حالة عملية (Choosing a type based on need)**
```python
# Need unique items and fast lookup? Use set.
user_ids = {1, 2, 3, 1} # {1, 2, 3}

# Need key-value mapping? Use dict.
user_roles = {"Ali": "admin", "Sara": "editor"}

# Need a fixed record that shouldn't change? Use tuple.
coordinates = (34.05, -118.24)

# Need an ordered, changeable list? Use list.
shopping_cart = ["apple", "banana", "milk"]
```

### الفايدة الانترفيوية
**"Categorize the built-in data types in Python."**
الإجابة: بتنقسم لـ: Numeric (int, float, complex)، Text (str)، Sequences (list, tuple, range)، Sets (set, frozenset)، Mappings (dict)، Boolean (bool)، و NoneType. والتصنيف الفرعي المهم هو Mutable (list, set, dict) و Immutable (tuple, str, frozenset, numeric types).

> [!tip] Checkpoint
# Know the categories: Numeric, Sequence, Set, Mapping, Bool, None.
# Know which are mutable and which are immutable.
```

---

## Q12 — إيه الـ int في بايثون وليه مفيش integer overflow؟ (arbitrary precision)

### أصل الحكاية
في لغات تانية، الأرقام الصحيحة (integers) بياخدوا مساحة ثابتة من الميموري (مثلاً 32-bit أو 64-bit). فلو الرقم كبر عن الحد ده، بيحصل حاجة اسمها overflow (يعني الرقم يلف ويرجع يبدأ من أصغر رقم سالب). بايثون مبتعملش كده خالص. بايثون بتعمل الـ int بطريقة اسمها arbitrary precision (دقة غير محدودة). يعني لو الرقم كبير، بايثون بتعمل allocate لميموري زيادة عشان تستوعب الرقم كله. مفيش حد أقصى للرقم غير مساحة الـ RAM اللي في جهازك.

```python
# A very large number that would overflow in other languages
huge_number = 10**100
print(huge_number) 
# 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# Python handles it perfectly
print(huge_number * 10) # Just adds another zero!
```

**Snippet 1: حالة بسيطة (Basic arithmetic without overflow)**
```python
max_64_bit = 9223372036854775807 # 2^63 - 1

# Adding 1 to max 64-bit int
result = max_64_bit + 1
print(result) # 9223372036854775808 (No overflow, no wrapping around to negative)
```

**Snippet 2: edge case (Memory limits)**
```python
import sys

# You can calculate extremely large factorials
def factorial(n):
    if n == 0: return 1
    return n * factorial(n-1)

# 1000 factorial is an enormous number with 2568 digits
big_fact = factorial(1000)
print(len(str(big_fact))) # 2568
print(sys.getsizeof(big_fact)) # Takes some memory, but works perfectly
```

**Snippet 3: حالة عملية (Cryptography/Hashing)**
```python
# Large integers are common in cryptography
# RSA keys are just large integers
prime1 = 32416190071
prime2 = 32416189381

# The product is huge, Python handles it natively
modulus = prime1 * prime2
print(modulus) # 1050809373085526720951
```

### الفايدة الانترفيوية
**"Why is there no integer overflow in Python?"**
الإجابة: لأن بايثون بستخدم arbitrary-precision integers. أي رقم int بيتخزن كـ array of digits، ولما الرقم يكبر، بايثون بتعمل allocate مساحة أكبر في الميموري عشان تستوعبه. الـ limit الوحيد لحدوث overflow هو إن الميموري (RAM) بتاعتك تخلص.

> [!warning] فخ شائع
# Just because Python handles huge ints natively doesn't mean it's fast.
# Arithmetic on very large integers is slower than on small ones (which fit into a single CPU register).
# For heavy numerical computing, numpy (which uses C-types) is preferred.
```

> [!tip] Checkpoint
# Python ints have arbitrary precision.
# No overflow, limited only by RAM.
# Operations on massive ints are slower than on machine-level ints.
```

---

## Q13 — إيه الـ float وليه `0.1 + 0.2 != 0.3`؟ (IEEE 754 floating point)

### أصل الحكاية
الـ float في بايثون بيتخزن بنظام اسمه IEEE 754 (double precision 64-bit). المشكلة إن الكمبيوتر بيفكر بالنظام الثنائي (binary)، وفي أرقام عشرية زي 0.1 مينفعش تتخزن بدقة في النظام الثنائي (زي ما رقم 1/3 مينفعش يتكتب بالظبط في العشري). فبايثون بتخزن قيمة قريبة جداً من 0.1 بس مش 0.1 بالظبط. ولما بتجمع 0.1 + 0.2، الأخطاء الصغيرة دي بتجمع مع بعضها وتطلع رقم قريب من 0.3 بس فيه فرق في الأرقام العشرية الخفية، عشان كده لما تقارنهم بـ `==` بيرجع False.

```python
result = 0.1 + 0.2
print(result)        # 0.30000000000000004
print(result == 0.3) # False
```

**Snippet 1: حالة بسيطة (Showing the hidden digits)**
```python
# Using format to show many decimal places
print(f"{0.1:.20f}") # 0.10000000000000000555
print(f"{0.2:.20f}") # 0.20000000000000001110
print(f"{0.3:.20f}") # 0.29999999999999998890

# 0.1 + 0.2 actually gives a slightly different approximation than 0.3
```

**Snippet 2: edge case (Accumulation of errors)**
```python
total = 0.0
for _ in range(10):
    total += 0.1

print(total) # 0.9999999999999999 (not exactly 1.0)
```

**Snippet 3: حالة عملية (Financial calculations disaster)**
```python
# Never use floats for money!
account_balance = 1.00
price = 0.10

# Buying 10 items
for _ in range(10):
    account_balance -= price

print(account_balance == 0.00) # False!
print(account_balance) # 2.7755575615628914e-17 (A tiny positive number instead of 0)
```

### الفايدة الانترفيوية
**"Why does `0.1 + 0.2 != 0.3` evaluate to False in Python?"**
الإجابة: بسبب طريقة تخزين الـ floating-point numbers في معيار IEEE 754. أرقام زي 0.1 مش بيتمثلو بدقة تامة في النظام الثنائي (binary). بيتم تخزينهم كتقريب (approximation). لما بتجمع تقريببيين، الأخطاء الصغيرة بتتراكم (accumulate) فالنتيجة بتكون قريبة من 0.3 بس مش بالظبط، فالـ `==` بيفشل.

> [!danger] فخ خطير
# Using floats for financial systems.
# $0.01 errors can accumulate over millions of transactions to huge losses.
# Use `decimal.Decimal` instead for exact decimal arithmetic.
```

> [!tip] Checkpoint
# Floats are approximations in binary.
# 0.1 is not exactly 0.1 in memory.
# Never use == to compare floats.
```

---

## Q14 — إزاي تقارن أرقام float بشكل آمن؟ (`math.isclose()` بدل `==`)

### أصل الحكاية
عشان نتغلب على مشكلة التقريب في الـ floats، مش لازم نقارنهم بـ `==`. الطريقة الصح إننا نقول "هل الفرق بين الرقمين أصغر من قيمة معينة صغيرة جداً؟". القيمة دي اسمها tolerance. بايثون جايبة فانكشن جاهزة في الـ `math` module اسمها `isclose()` بتعمل المقارنة دي بشكل ذكي. بتقبل نسبة مئوية (relative tolerance) أو فرق ثابت (absolute tolerance) وتقولك هل الرقمين قريبين من بعض بما يخليهم يعتبروا متساويين في حدود الخطأ المسموح.

```python
import math

a = 0.1 + 0.2
b = 0.3

print(a == b)         # False
print(math.isclose(a, b)) # True (uses default relative tolerance of 1e-09)
```

**Snippet 1: حالة بسيطة (Absolute tolerance)**
```python
import math

# If we are comparing numbers close to zero, relative tolerance fails
# So we use absolute tolerance (abs_tol)
x = 1e-10
y = 0.0

print(math.isclose(x, y, abs_tol=1e-09)) # True, difference is within 1e-09
```

**Snippet 2: edge case (Large numbers)**
```python
import math

# For huge numbers, relative tolerance is better
val1 = 1e20
val2 = 1e20 + 1e10

# The difference is huge in absolute terms, but tiny relative to the numbers themselves
print(math.isclose(val1, val2, rel_tol=0.01)) # True (1% relative tolerance)
```

**Snippet 3: حالة عملية (Physics simulation)**
```python
import math

def check_collision(pos1, pos2):
    # We can't use exact equality for floating point coordinates
    if math.isclose(pos1[0], pos2[0]) and math.isclose(pos1[1], pos2[1]):
        return True
    return False

p1 = (0.1 + 0.2, 1.0)
p2 = (0.3, 1.0)

print(check_collision(p1, p2)) # True
```

### الفايدة الانترفيوية
**"How do you compare floating-point numbers safely in Python?"**
الإجابة: بنستخدم `math.isclose(a, b)`. الفانكشن دي بتقارن الـ floats بناءً على relative tolerance (نسبة مئوية) أو absolute tolerance (فرق ثابت). ده بيحل مشكلة الأخطاء الصغيرة الناتجة عن معيار IEEE 754 والمقارنة بـ `==`.

> [!warning] فخ شائع
# Trying to subtract floats and checking if the result is exactly 0
if (a - b) == 0.0: # This might fail even if they are conceptually equal
    pass

# Correct way
if math.isclose(a, b):
    pass
```

> [!tip] Checkpoint
# Always use math.isclose() for float comparisons.
# rel_tol for general large numbers.
# abs_tol for numbers very close to zero.
```

---

## Q15 — إمتى تستخدم `decimal.Decimal` بدل `float`؟

### أصل الحكاية
الـ float زي ما قلنا بيعمل تقريب في النظام الثنائي. بس لو إنت بتشتغل في تطبيق مالي، بنك، أو أي نظام بيتعامل مع فلوس، أي سنت ضايع أو زيادة ممكن يعمل كارثة. عشان كده بايثون عندها الـ `decimal` module. الـ Decimal بيتعامل مع الأرقام بالنظام العشري بالظبط زي ما إنت بتكتبها على الورق. 0.1 تبقى 0.1 بالظبط من غير تقريب. بطيء شوية من الـ float العادي، بس بيضمن لك دقة 100% في العمليات الحسابية العشرية.

```python
from decimal import Decimal

# Float problem
print(0.1 + 0.2) # 0.30000000000000004

# Decimal solution
a = Decimal('0.1')
b = Decimal('0.2')
print(a + b) # 0.3 exactly!

# Notice the quotes: we MUST pass strings to Decimal, not floats!
bad_decimal = Decimal(0.1) # Inherits the float inaccuracy!
print(bad_decimal) # 0.1000000000000000055511151231257827021181583404541015625
```

**Snippet 1: حالة بسيطة (Financial precision)**
```python
from decimal import Decimal

price = Decimal('19.99')
tax_rate = Decimal('0.14')

tax = price * tax_rate
total = price + tax

print(tax)   # 2.7986
print(total) # 22.7886
# Exact arithmetic, no floating point artifacts.
```

**Snippet 2: edge case (Controlling precision)**
```python
from decimal import Decimal, getcontext

# You can set the global precision (number of significant digits)
getcontext().prec = 2

result = Decimal('1') / Decimal('3')
print(result) # 0.33 (Rounded to 2 significant digits)
```

**Snippet 3: حالة عملية (Banking ledger)**
```python
from decimal import Decimal

class Account:
    def __init__(self, balance_str):
        self.balance = Decimal(balance_str)
        
    def withdraw(self, amount_str):
        amount = Decimal(amount_str)
        if amount > self.balance:
            raise ValueError("Insufficient funds")
        self.balance -= amount
        return self.balance

acc = Account("100.00")
acc.withdraw("0.10")
acc.withdraw("0.20")
print(acc.balance) # 79.70 exactly
```

### الفايدة الانترفيوية
**"When should you use `decimal.Decimal` instead of `float`?"**
الإجابة: بنستخدم `Decimal` لما نحتاج دقة عشرية مطلقة، زي في الأنظمة المالية والمحاسبية، حيث إن الأخطاء الصغيرة في الـ float بتتراكم وتعمل مشاكل كبيرة. الـ Decimal بيمثل الأرقام بالنظام العشري زي ما إنت بتكتبها بالظبط من غير تقريب ثنائي.

> [!danger] فخ خطير
> ```python
> # Passing a float to Decimal inherits the exact float imprecision!
> d = Decimal(0.1) # Bad!
> # Always pass strings or integers
> d = Decimal('0.1') # Good!
> ```

> [!tip] Checkpoint
> # استخدم Decimal للفلوس ولما تحتاج دقة عشرية مية في المية.
> # إحسن تمرر string للـ Decimal مش float.

---

## Q16 — إيه الـ bool في بايثون وليه هو subclass من int؟ (True == 1، False == 0)

### أصل الحكاية
في بايثون، الـ `bool` (اللي قيمته `True` أو `False`) مش نوع مستقل بمعنى الكلمة، هو بالظبط subclass من الـ `int`. يعني تاريخياً بايثون ورثت الفكرة دي، فخلت `True` يساوي 1 و`False` يساوي 0. عشان كده إنت ممكن تعمل عمليات حسابية بـ `True` و`False` زيهم زي الأرقام، وممكن تعمل `sum()` على list من الـ bools عشان تعرف عددهم. ده سلوك مش موجود في كل اللغات، بس في بايثون ده الـ implementation الحقيقي.

```python
print(isinstance(True, int)) # True -> bool is a subclass of int

print(True == 1)   # True
print(False == 0)  # True

# Arithmetic with booleans
print(True + True) # 2
print(False + 5)   # 5
```

**Snippet 1: حالة بسيطة (Summing booleans)**
```python
# Counting how many True values are in a list
results = [True, False, True, True, False]
# Since True is 1, sum() works perfectly
count = sum(results)
print(count) # 3
```

**Snippet 2: edge case (Indexing with booleans)**
```python
# Because True is 1 and False is 0, you can use them as list indices
data = ["Off", "On"]

state = True
print(data[state]) # "On" (data[1])

state = False
print(data[state]) # "Off" (data[0])
```

**Snippet 3: حالة عملية (Bitmask operations)**
```python
# Read permissions as booleans
READ = True
WRITE = False
EXECUTE = True

# Treating them as ints to create a bitmask
# (True is 1, False is 0) -> 101 in binary -> 5 in decimal
permissions = (READ * 4) + (WRITE * 2) + (EXECUTE * 1)
print(permissions) # 5
```

### الفايدة الانترفيوية
**"Is `bool` a subclass of `int` in Python? Can you do math with booleans?"**
الإجابة: أيوة، الـ `bool` هو subclass من الـ `int`. `True` بيساوي 1 و`False` بيساوي 0. عشان كده إنت تقدر تعمل عمليات حسابية بيهم، وتستخدمهم كـ indices، وتعملهم `sum()` عشان تعد الـ True values في الـ list.

> [!warning] فخ شائع
> ```python
> # Checking identity instead of equality
> print(True is 1) # False! They are equal in value, but not the same object in memory.
> print(True == 1) # True
> ```

> [!tip] Checkpoint
> # bool inherits from int.
> # True = 1, False = 0.
> # You can do math with them, but don't rely on it for readability unless it's a specific trick like sum().

---

## Q17 — إيه الـ None وإيه الفرق بينه وبين `0` و`False` و`""`؟

### أصل الحكاية
الـ `None` في بايثون معناه "لام شيء" أو "غياب القيمة". هو مش صفر، لأن الصفر قيمة رقمية. ومش `False`، لأن `False` قيمة منطقية. ومش نص فاضي. الـ `None` بيرمز لإن المتغير موجود (عملنا له assignment)، بس مفيش قيمة متسجل فيه. بايثون بترجع `None` تلقائياً من أي فانكشن مش راجعة حاجة، وهو الـ default value اللي بنستخدمه للـ arguments لما نتجنب الـ mutable default trap. الـ `None` هو Singleton (أوبجكت واحد بس في الميموري كله)، عشان كده دايماً بنقارنه بـ `is None` مش `== None`.

```python
# None represents the absence of a value
x = None

print(x is None) # True -> The correct way to check for None

# None is NOT equal to falsy values in identity
print(x == 0)      # False
print(x == False)  # False
print(x == "")     # False

# But in a boolean context, None evaluates to False
if not x:
    print("x is falsy") # This prints
```

**Snippet 1: حالة بسيطة (Function default return)**
```python
def do_nothing():
    pass

result = do_nothing()
print(result)       # None
print(result is None) # True
```

**Snippet 2: edge case (Distinguishing None from 0)**
```python
# If 0 is a valid input, but None means "not provided"
def set_volume(level=None):
    if level is None:
        print("Using default volume")
    else:
        print(f"Setting volume to {level}")

set_volume(0)    # Setting volume to 0 (0 is a valid volume!)
set_volume(None) # Using default volume
```

**Snippet 3: حالة عملية (Dictionary .get() method)**
```python
user = {"name": "Ali", "age": 30}

# .get() returns None if the key doesn't exist, rather than throwing KeyError
email = user.get("email")
print(email)      # None
print(email is None) # True
```

### الفايدة الانترفيوية
**"What is `None` in Python, and how does it differ from `False` or `0`?"**
الإجابة: الـ `None` بي represents الغياب التام للقيمة، يعني المتغير موجود بس فاضي. `False` و`0` دول قيم فعلية (boolean و integer). الـ `None` بي evaluate لـ False في الـ boolean context بس هو مش `False`. بما إن `None` هو Singleton (أوبجكت واحد بس في الميموري)، فالطريقة الصح المقارنة بيه هي `if x is None` مش `==`.

> [!danger] فخ خطير
> ```python
> # Using '==' to check for None can be overridden by custom classes!
> class Weird:
>     def __eq__(self, other):
>         return True # Says it's equal to everything, even None!
> 
> w = Weird()
> print(w == None) # True (Misleading!)
> print(w is None) # False (Correct, it's not the None object)
> ```

> [!tip] Checkpoint
> # None = absence of value.
> # None is a singleton, always use `is None`.
> # None is falsy, but not equal to 0 or False.

---

## Q18 — إيه الـ Type Casting وإيه الفرق بين explicit وimplicit conversion؟

### أصل الحكاية
الـ Type Casting معناه إنك تحول من نوع بيانات لنوع تاني. في بايثون فيه نوعين من التحويل: Implicit (ضمني) وExplicit (صريح). الـ Implicit conversion بيحصل تلقائياً لما بايثون تشوف إنها حاجة آمنة ومفيهاش خسارة معلومات، زي لما تيجمع int مع float، بايثون بتحول الـ int لـ float عشان ماتخسرش الجزء العشري. الـ Explicit conversion هو لما إنت كمبرمج تتدخل وتقولها "حول ده لكده" باستخدام فانكشنز زي `int()` أو `str()`، وده بيحصل لما التحويل مش آمن أو مش تلقائي، زي تحويل نص لرقم.

```python
# Implicit Conversion (Automatic)
an_int = 10
a_float = 2.5
# Python automatically converts 'an_int' to a float to avoid data loss
result = an_int + a_float
print(type(result)) # <class 'float'>
print(result)       # 12.5

# Explicit Conversion (Manual)
a_string = "123"
# We MUST explicitly tell Python to convert the string to an int
an_int_from_str = int(a_string)
print(type(an_int_from_str)) # <class 'int'>
print(an_int_from_str + 5)   # 128
```

**Snippet 1: حالة بسيطة (Explicit string to number)**
```python
user_input = " 42 " # String from user input
# int() automatically strips whitespace and converts
num = int(user_input)
print(num * 2) # 84
```

**Snippet 2: edge case (Loss of data in explicit conversion)**
```python
# Converting float to int truncates the decimal part (doesn't round!)
price = 19.99
int_price = int(price)
print(int_price) # 19 (The .99 is lost forever)

# Converting string with decimals to int directly fails!
# int("19.99") -> ValueError!
# You have to do it in two steps: int(float("19.99"))
```

**Snippet 3: حالة عملية (Parsing mixed data)**
```python
data = ["10", "20.5", "30", "abc", "40"]

total = 0
for item in data:
    try:
        # Try to convert to float first (handles both "10" and "20.5")
        total += float(item)
    except ValueError:
        print(f"Cannot convert {item}")

print(total) # 80.5
```

### الفايدة الانترفيوية
**"What's the difference between implicit and explicit type casting?"**
الإجابة: الـ Implicit conversion بيحصل أوتوماتيك من بايثون لما تتعامل مع نوعين متوافقين والتحويل آمن (زي int لـ float). الـ Explicit conversion بيحصل لما إنت تستخدم فانكشنز زي `int()` أو `str()` عشان تحول قيمة بنفسك، وده ضروري لما التحويل مش آمن أو ممكن يضيع داتا (زي float لـ int).

> [!warning] فخ شائع
> ```python
> # int() does NOT round, it truncates towards zero.
> print(int(-3.9)) # -3 (not -4)
> 
> # Use round() if you want to round
> print(round(-3.9)) # -4
> ```

> [!tip] Checkpoint
> # Implicit: Python does it safely (int + float = float).
> # Explicit: You force it using int(), str(), float(), etc.
> # int() truncates, it doesn't round.

---

## Q19 — إيه الـ Truthy والـ Falsy values وإزاي بايثون بتقيّمهم في الـ boolean context؟

### أصل الحكاية
في بايثون، أي حاجة ممكن تتعامل معاها كأنها `True` أو `False` جوه `if` أو `while`. المش لازم تكون من نوع `bool` عشان تقارنها. بايثون بتعمل evaluate للـ objects بتاعتها وبتقولك ده Truthy (يعني بيساوي True في السياق ده) أو Falsy (يعني بيساوي False). القاعدة بسيطة جداً: كل الـ objects الفاضية أو الصفرية بتبقى Falsy، وكل حاجة تانية بتبقى Truthy. يعني `0`، `0.0`، `""` (نص فاضي)، `[]` (لستة فاضية)، `{}` (ديكت فاضي)، و`None` كلهم Falsy. أي حاجة فيها داتا بتبقى Truthy.

```python
# Falsy values
falsy_values = [0, 0.0, "", [], {}, set(), None, False]

for val in falsy_values:
    if not val:
        print(f"{repr(val)} is Falsy")

# Truthy values (everything else)
truthy_values = [1, -1, "Hello", [0], {"key": ""}, [None]]

for val in truthy_values:
    if val:
        print(f"{repr(val)} is Truthy")
```

**Snippet 1: حالة بسيطة (Checking for empty lists)**
```python
# Common Pythonic way to check if a list is empty
my_list = []

# BAD way
if len(my_list) == 0:
    print("Empty")

# GOOD Pythonic way
if not my_list:
    print("Empty list!") # This runs because [] is falsy
```

**Snippet 2: edge case (Non-empty containers with falsy items)**
```python
# A list containing falsy values is still truthy because the list itself is not empty
weird_list = [0, None, ""]

if weird_list:
    print("List is truthy!") # This runs!
    print(len(weird_list)) # 3
```

**Snippet 3: حالة عملية (Default values using 'or')**
```python
# The 'or' operator returns the first truthy value
user_input = "" # User didn't enter anything

# If user_input is falsy (""), it falls back to "Guest"
username = user_input or "Guest"
print(username) # "Guest"

user_input = "Ali"
username = user_input or "Guest"
print(username) # "Ali"
```

### الفايدة الانترفيوية
**"What are Truthy and Falsy values in Python? Give examples."**
الإجابة: بايثون بتقيّم الـ objects في الـ boolean context (زي `if`) بناءً على محتواها. الـ Falsy values هي: `False`، `None`، أي صفر رقمي (`0`، `0.0`)، وأي حاوية فاضية (`""`، `[]`، `{}`، `()`). أي حاجة تانية بتبقى Truthy. ده بيخلينا نكتب كود نظيف زي `if my_list:` بدل ما نكتب `if len(my_list) > 0:`.

> [!danger] فخ خطير
> ```python
> # Checking if a number is valid vs checking if it's not None
> def process(value):
>     # If value is 0, this condition fails! 0 is falsy!
>     if value:
>         print("Processing")
>     else:
>         print("Skipping 0 or None")
> 
> process(0) # Skips 0! If 0 is a valid input, this is a bug.
> 
> # Correct way if 0 is valid:
> if value is not None:
>     print("Processing")
> ```

> [!tip] Checkpoint
> # Falsy: 0, None, "", [], {}, ()
> # Truthy: Everything else (including negative numbers!).
> # Use `if my_list:` to check for empty, but use `if x is not None:` if 0 is a valid value.

---

## Q20 — إزاي تتحقق من الـ type؟ (`type()` vs `isinstance()` — الفرق مهم!)

### أصل الحكاية
لما تيجي تسأل "هل المتغير ده من نوع كذا؟"، فيه طريقتين: `type(x) == int` أو `isinstance(x, int)`. `type()` بتجيب النوع بالظبط من غير ما تبحث في الوراثة (inheritance). `isinstance()` بتشوف لو النوع ده أو أي أب (parent class) ليه. بما إن بايثون لغة بتعتمد على الـ OOP والـ inheritance كتير، فالـ `isinstance()` هي الـ best practice دايماً. لو استخدمت `type()` مع subclass، هتطلع False حتى لو الأب هو اللي بتدور عليه.

```python
class Animal:
    pass

class Dog(Animal):
    pass

d = Dog()

# type() checks for EXACT type match
print(type(d) == Dog)     # True
print(type(d) == Animal)  # False! type() ignores inheritance

# isinstance() checks for the type AND parent classes
print(isinstance(d, Dog))   # True
print(isinstance(d, Animal))# True! It knows Dog is an Animal
```

**Snippet 1: حالة بسيطة (Built-in types)**
```python
x = [1, 2, 3]

# isinstance works perfectly for built-ins too
print(isinstance(x, list)) # True

# You can pass a tuple of types to check against multiple
print(isinstance(x, (list, tuple, set))) # True
```

**Snippet 2: edge case (Booleans and integers)**
```python
# Remember Q16? bool is a subclass of int!
print(isinstance(True, int)) # True!
print(type(True) == int)     # False!

# So if you check `isinstance(x, int)`, True will pass!
```

**Snippet 3: حالة عملية (Duck typing vs Type checking)**
```python
# Pythonic code often avoids type checking entirely (Duck Typing)
def process_data(data):
    # Instead of checking type, we check behavior (hasattr)
    if hasattr(data, "__iter__"):
        for item in data:
            print(item)
    else:
        print("Not iterable")

process_data([1, 2]) # Works
process_data("Hi")   # Works
process_data(42)     # Not iterable
```

### الفايدة الانترفيوية
**"What is the difference between `type()` and `isinstance()`? Which one should you use?"**
الإجابة: `type()` بترجع النوع المباشر للـ object بالظبط، وبتفشل لو الـ object من subclass. `isinstance()` بتنجح لو الـ object من النوع ده أو أي subclass بيرث منه. دايماً لازم تستخدم `isinstance()` لأنها بتحترم الـ OOP والـ inheritance. كمان `isinstance()` بتقبل tuple of types فتقدر تسأل عن أكتر من نوع في نفس الوقت.

> [!warning] فخ شائع
> ```python
> # Using type() in if statements breaks polymorphism
> if type(obj) == MyClass:
>     obj.do_something()
> 
> # This will fail for anyone who subclassed MyClass!
> # Use isinstance(obj, MyClass) instead.
> ```

> [!tip] Checkpoint
> # `type()` is strict (exact match).
> # `isinstance()` is flexible (checks inheritance).
> # Always prefer `isinstance()` for type checking in Python.

---

## Q21 — إيه الفرق بين `bytes` و`bytearray` و`str`؟ وإمتى تستخدم كل واحدة؟

### أصل الحكاية
الـ `str` بتاعة بايثون 3 بتخزن النصوص كـ Unicode (حروف مفهومة للبشر). بس لما تيجي تبعت داتا على النتورك أو تكتبها في ملف binary، الكمبيوتر مش بيفهم الـ Unicode مباشرة، لازم داتا خام (raw data) من 0 و1، ودي بتبقى سلاسل من الـ bytes. الـ `bytes` هي sequence من الـ bytes بسها immutable (مش بتتعدل زي الـ str). الـ `bytearray` هي نفس الفكرة بس mutable (تقدر تعدل عليها زي الـ list). التحويل بينهم بيحصل عن طريق الـ encode (من str لـ bytes) والـ decode (من bytes لـ str).

```python
# String (Text, Unicode)
text = "Hello"

# Encode string to bytes (using UTF-8)
byte_data = text.encode('utf-8')
print(type(byte_data)) # <class 'bytes'>
print(byte_data)        # b'Hello'

# Decode bytes back to string
decoded_text = byte_data.decode('utf-8')
print(decoded_text)     # Hello

# bytearray (Mutable bytes)
mutable_bytes = bytearray(byte_data)
mutable_bytes[0] = 74 # 'J' in ASCII
print(mutable_bytes) # bytearray(b'Jello')
```

**Snippet 1: حالة بسيطة (Encoding Arabic text)**
```python
arabic_text = "أهلا"

# UTF-8 represents Arabic characters as multiple bytes
ar_bytes = arabic_text.encode('utf-8')
print(ar_bytes) # b'\xd8\xa3\xd9\x87\xd9\x84\xd8\xa7'

# If we try to decode with wrong encoding, it might fail or look like garbage
print(ar_bytes.decode('utf-8')) # أهلا
```

**Snippet 2: edge case (Modifying bytearray)**
```python
# bytes are immutable
b = b"test"
# b[0] = 84 -> TypeError: 'bytes' object does not support item assignment

# bytearray allows mutation
ba = bytearray(b"test")
ba[0] = 84 # 'T'
print(ba) # bytearray(b'Test')
```

**Snippet 3: حالة عملية (Reading a file in binary mode)**
```python
# Writing binary data to a file (like an image)
with open("test.bin", "wb") as f:
    f.write(b"\x00\x01\x02\xFF")

# Reading it back
with open("test.bin", "rb") as f:
    data = f.read()
    print(data) # b'\x00\x01\x02\xff'
    print(type(data)) # <class 'bytes'>
```

### الفايدة الانترفيوية
**"What's the difference between `str`, `bytes`, and `bytearray`?"**
الإجابة: الـ `str` بتخزن نصوص Unicode للبشر. الـ `bytes` بتخزن raw bytes (للملفات والناتورك) وهي immutable. الـ `bytearray` هي نفس حاجة زي الـ bytes بس mutable. التحويل بين `str` و`bytes` بيحصل عن طريق `encode()` و`decode()` وغالباً بنستخدم UTF-8.

> [!danger] فخ خطير
> ```python
> # Mixing str and bytes causes TypeErrors in Python 3!
> print("Hello" + b" World")
> # TypeError: can only concatenate str (not "bytes") to str
> 
> # You must decode the bytes first, or encode the str
> print("Hello" + b" World".decode('utf-8')) # Hello World
> ```

> [!tip] Checkpoint
> # str = Human text (Unicode).
> # bytes = Raw binary data (Immutable).
> # bytearray = Raw binary data (Mutable).
> # Use encode/decode to switch between str and bytes.

---

## Q22 — إيه الفرق بين `repr()` و`str()`؟ وإمتى بايثون بتستدعي كل واحدة تلقائياً؟

### أصل الحكاية
الـ `str()` بترجع نسخة "مقروءة" من الـ object، يعني شكل حلو للبشر العاديين. الـ `repr()` بترجع نسخة "دقيقة" من الـ object، شكلها تقني ومفروض تكون unambiguous (مفيهاش لبس). القاعدة الذهبية في بايثون إن الـ `repr()` مفروض لما تقراه أو تعمله print، تقدر تنسخه وتعمله `eval()` ويرجعلك الـ object نفسه. لما بتدوس `print()` بايثون بتنادي `__str__`. بس لما بتكتب اسم المتغير في الـ REPL (الشاشة التفاعلية) أو تشوفه جوا list، بايثون بتنادي `__repr__`.

```python
import datetime

now = datetime.datetime.now()

# str() is for humans (readable)
print(str(now)) # 2023-10-25 14:30:22.123456

# repr() is for developers (unambiguous, looks like valid code)
print(repr(now)) # datetime.datetime(2023, 10, 25, 14, 30, 22, 123456)
```

**Snippet 1: حالة بسيطة (String example)**
```python
s = "Hello\nWorld"

# str prints it formatted (with the actual newline)
print(s)
# Output:
# Hello
# World

# repr shows the string literal exactly as it is in code (escaped)
print(repr(s)) # 'Hello\nWorld'
```

**Snippet 2: edge case (List inside print)**
```python
class Person:
    def __init__(self, name):
        self.name = name
        
    def __str__(self):
        return f"Person named {self.name}"
        
    def __repr__(self):
        return f"Person('{self.name}')"

p = Person("Ali")

print(p) # Calls __str__ -> "Person named Ali"
print([p]) # Calls __repr__ on the list, which calls __repr__ on items!
# Output: [Person('Ali')]
```

**Snippet 3: حالة عملية (The eval() trick)**
```python
# A good repr can be evaluated to recreate the object
import decimal
d = decimal.Decimal('3.14')
repr_str = repr(d) # "Decimal('3.14')"

# eval runs the string as Python code
d2 = eval(repr_str) 
print(d == d2) # True
```

### الفايدة الانترفيوية
**"What is the difference between `__str__` and `__repr__`?"**
الإجابة: `__str__` بيدي تمثيل مقروء للبشر (بيتنادي لما تعمل `print` أو `str()`). `__repr__` بيدي تمثيل دقيق للمبرمجين (بيتنادي في الـ REPL، أو جوا collections زي الـ lists، أو لما تعمل `repr()`). هدف الـ `__repr__` إنه يكون unambiguous، والمثالي إنه يقدر يعيد إنشاء الـ object عن طريق `eval()`.

> [!warning] فخ شائع
> ```python
> # If you only define __repr__, Python uses it for __str__ as well.
> # But if you only define __str__, __repr__ defaults to something ugly like <__main__.MyClass object at 0x...>
> class My:
>     def __str__(self): return "Hi"
> 
> m = My()
> print(m) # Hi
> print([m]) # [<__main__.MyClass object at 0x7f8b9c2b3d90>] (Ugly!)
> ```

> [!tip] Checkpoint
> # `str()` = readable, human-friendly.
> # `repr()` = unambiguous, developer-friendly, used in REPL/lists.
> # Always implement `__repr__` for your classes at minimum!

---

## Q23 — إيه `sys.maxsize` وإيه اختلاف حدود الأرقام بين البلاتفورمات؟

### أصل الحكاية
زي ما قلنا في Q12، الـ `int` في بايثون مفيش له حد أقصى (arbitrary precision). بس، بايثون بتستخدم الـ pointers داخلياً عشان تتعامل مع الميموري والـ containers. الـ `sys.maxsize` بيدّي أكبر رقم ممكن بايثون تستخدمه كـ index لـ list أو string أو أي container. ده الرقم بيتحدد بناءً على معمارية الجهاز (Architecture). لو الجهاز 32-bit، الرقم هيكون `2**31 - 1`. لو الجهاز 64-bit (وهو الغالبية)، الرقم هيكون `2**63 - 1`. مش معناه إنك مينفعش تعمل رقم أكبر من كده، معناه إنك مينفعش تعمل list فيها أكتر من كده عنصر.

```python
import sys

# Maximum size for a container (list, str, etc.)
print(sys.maxsize) 
# On 64-bit: 9223372036854775807 (2**63 - 1)

# You CAN have integers larger than sys.maxsize
huge_num = sys.maxsize + 1
print(huge_num) # 9223372036854775808 (Works perfectly, no overflow)

# But you CANNOT create a list with sys.maxsize elements (not enough RAM)
# [0] * sys.maxsize -> MemoryError
```

**Snippet 1: حالة بسيطة (Checking platform architecture)**
```python
import sys

if sys.maxsize == 2**63 - 1:
    print("Running on a 64-bit Python interpreter")
elif sys.maxsize == 2**31 - 1:
    print("Running on a 32-bit Python interpreter")
```

**Snippet 2: edge case (Floating point limits)**
```python
import sys

# sys.maxsize is about integers and containers.
# Floats have their own limit: sys.float_info.max
print(sys.float_info.max) # 1.7976931348623157e+308

# If you exceed the float max, you get 'inf' (infinity)
print(sys.float_info.max * 2) # inf
```

**Snippet 3: حالة عملية (Slicing with maxsize)**
```python
import sys

# A common trick to get the rest of a list from a certain index
my_list = [1, 2, 3, 4, 5]
# Instead of doing my_list[2:len(my_list)], you can use sys.maxsize
# Python will automatically cap it to the length of the list
rest = my_list[2:sys.maxsize]
print(rest) # [3, 4, 5]

# Note: usually we just do my_list[2:], but this shows why maxsize works in slices.
```

### الفايدة الانترفيوية
**"What is `sys.maxsize`? Does it limit the size of Python integers?"**
الإجابة: `sys.maxsize` بي represent أقصى حجم لحاوية (container) زي الـ list بناءً على معمارية الـ Python interpreter (32-bit ولا 64-bit). هو مش بيحد حجم الـ integers، لأن الـ int في بايثون arbitrary precision. بس بيحد أكبر رقم ممكن يتستخدم كـ index.

> [!warning] فخ شائع
> ```python
> # Confusing sys.maxsize with sys.float_info.max
> # sys.maxsize is for integers/containers indices.
> # sys.float_info.max is the absolute limit for floating point numbers.
> ```

> [!tip] Checkpoint
> # `sys.maxsize` = max container size/index (depends on 32/64 bit).
> # Integers can exceed it.
> # Floats have `sys.float_info.max`.

---

## Q24 — إيه edge cases الأرقام اللي بتبان في الإنترفيو؟ (`inf`, `nan`, `//`, `%` مع negative numbers)

### أصل الحكاية
في بايثون في حاجات في الأرقام بتلخبط الناس جداً في الإنترفيو. أول حاجة الـ `inf` (infinity) و`nan` (Not a Number). دول مش أرقام عادية، دول جايين من معيار الـ float. `inf` بتاعة بايثون أكبر من أي رقم، و`nan` هي نتيجة عمليات مش معروفة زي `0/0` بالـ float. أي عملية بتعملها مع `nan` بتطلع `nan`. حاجة تانية بتلخبط الناس هي الـ floor division (`//`) والـ modulo (`%`) لما تستخدمهم مع أرقام سالبة، لأن بايثون بتدور الـ floor division لتحت دايماً (ناحية السالب اللانهاية)، وده بيخلي الـ باقي (modulo) دايماً يبقى نفس إشارة المقسوم عليه (divisor).

```python
# Infinity and NaN
pos_inf = float('inf')
neg_inf = float('-inf')
nan_val = float('nan')

print(10 > pos_inf) # False
print(-10 > neg_inf) # True

# NaN is never equal to anything, even itself!
print(nan_val == nan_val) # False
print(nan_val is nan_val) # True (identity is true, but equality is false!)

# Any operation with NaN results in NaN
print(nan_val + 10) # nan
```

**Snippet 1: حالة بسيطة (Negative floor division)**
```python
# Positive floor division
print(7 // 2) # 3 (3.5 floors to 3)

# Negative floor division
# -7 / 2 = -3.5. Floor goes DOWN towards negative infinity -> -4
print(-7 // 2) # -4

# Regular division
print(-7 / 2) # -3.5
```

**Snippet 2: edge case (Negative modulo)**
```python
# The modulo result has the same sign as the divisor (second operand)
# -7 % 2: -7 = (-4 * 2) + 1. Remainder is 1
print(-7 % 2) # 1

# 7 % -2: 7 = (-4 * -2) + (-1). Remainder is -1
print(7 % -2) # -1

# -7 % -2: -7 = (3 * -2) + (-1). Remainder is -1
print(-7 % -2) # -1
```

**Snippet 3: حالة عملية (Checking for NaN safely)**
```python
import math

val = float('nan')

# NEVER use '==' to check for NaN
if val == float('nan'): # This is False!
    print("Is NaN")

# Use math.isnan()
if math.isnan(val):
    print("Correctly identified as NaN") # This runs
```

### الفايدة الانترفيوية
**"How do `//` and `%` behave with negative numbers in Python? What about `NaN`?"**
الإجابة: الـ `//` (floor division) دايماً بي round لأسفل (ناحية سالب مالانهاية). عشان كده `-7 // 2` بتساوي `-4` مش `-3`. الـ `%` (modulo) نتيجته دايماً بياخد إشارة الـ divisor (الرقم التاني). بالنسبة لـ `NaN`، هو مش بيساوي أي حاجة حتى نفسه، فعشان نختبره لازم نستخدم `math.isnan()` مش `==`.

> [!danger] فخ خطير
> ```python
> # Assuming -7 // 2 is -3 (like in C or Java)
> # In Python, floor division goes to the lower integer.
> # -3.5 floors to -4!
> 
> # Assuming you can check NaN with ==
> if x != x: # This actually works for NaN because NaN != NaN, but it's bad practice!
>     pass
> # Use math.isnan(x) instead.
> ```

> [!tip] Checkpoint
> # `//` rounds down (towards -inf).
> # `%` takes the sign of the divisor.
> # `float('inf')` is infinity.
> # `float('nan')` never equals itself. Use `math.isnan()`.

---

## Q25 — إيه الـ arithmetic operators وإيه الفرق بين `/` و`//`؟

### أصل الحكاية
بايثون عندها كل عوامل الحساب الأساسية (الجمع، الطرح، الضرب، القسمة). بس القسمة عندها نوعين. القسمة العادية `/` دايماً بترجع float حتى لو القسمة تزن (يعني 10 قسمة 2 تطلع 5.0 مش 5). القسمة الـ floor `//` بتقسم وبتجيب أكبر عدد صحيح أصغر من النتيجة (بتدور لتحت). والـ modulo `%` بيجيب باقي القسمة. والـ exponent `**` بيضرب الرقم في نفسه.

```python
# Standard Division (Always returns float)
print(10 / 2)  # 5.0
print(10 / 3)  # 3.3333333333333335

# Floor Division (Returns int if both are ints, float if any is float)
print(10 // 2) # 5
print(10 // 3) # 3

# Floor division with float
print(10.0 // 3) # 3.0
```

**Snippet 1: حالة بسيطة (Modulo and Exponent)**
```python
# Modulo (remainder)
print(10 % 3) # 1

# Exponent (power)
print(2 ** 3) # 8
print(4 ** 0.5) # 2.0 (Square root!)
```

**Snippet 2: edge case (Floor division with floats)**
```python
# Floor division with negative floats
# 10.5 / 3 = 3.5. Floor is 3.0
print(10.5 // 3) # 3.0

# -10.5 / 3 = -3.5. Floor goes down to -4.0
print(-10.5 // 3) # -4.0
```

**Snippet 3: حالة عملية (Checking even/odd)**
```python
def is_even(num):
    # Using modulo to check if remainder is 0
    return num % 2 == 0

print(is_even(4)) # True
print(is_even(7)) # False
```

### الفايدة الانترفيوية
**"What is the difference between `/` and `//` in Python?"**
الإجابة: الـ `/` هي القسمة العادية وبترجع `float` دايماً. الـ `//` هي الـ floor division، بترجع `int` لو الاتين `int`، وبتدور الناتج لتحت (ناحية سالب مالانهاية). يعني `10 // 3` بـ `3`، و`-10 // 3` بـ `-4`.

> [!warning] فخ شائع
> ```python
> # Thinking // is just "chopping off the decimal part"
> # It is FLOOR division, which goes down!
> print(3.9 // 1) # 3.0 (Correct, chops it)
> print(-3.1 // 1) # -4.0 (Not -3.0! It goes down to -4)
> ```

> [!tip] Checkpoint
> # `/` = float division (always float).
> # `//` = floor division (rounds down to negative infinity).
> # `**` = exponent.
> # `%` = modulo.

---

## Q26 — إيه الـ `**` operator وإيه precedence rules في بايثون؟ (مع أمثلة تعقيد)

### أصل الحكاية
الـ `**` عامل الأس (exponent). بايثون بتحترم ترتيب العمليات (PEMDAS). بس فيه قاعدتين غريبين في بايثون: الأولانية، الأس بيربط من اليمين لليسار (right-associative)، يعني `2 ** 3 ** 2` مش هتتضرب 2 في 3 الأول، هتتنفذ من اليمين: `2 ** (3**2)`. القاعدة التانية، عامل النفي `-` بيبدأ الأول قبل الـ `**` لو كان جوه الأقواس، بس لو بره، الـ `**` بيشغل الأول. كمان عوامل المقارنة زي `==` ليها precedence أقل من العوامل الحسابية، وعشان كده `not x == y` بتترجم لـ `not (x == y)` مش `(not x) == y`.

```python
# Exponent is right-associative
# Evaluated as 2 ** (3 ** 2) -> 2 ** 9
print(2 ** 3 ** 2) # 512

# Unary minus vs Exponent precedence
# ** has higher precedence than - on the right side
print(-2 ** 2) # -4 (Evaluated as -(2 ** 2))

# But if we use parentheses
print((-2) ** 2) # 4
```

**Snippet 1: حالة بسيطة (Logical operators precedence)**
```python
x = True
y = False

# '==' has higher precedence than 'not'
# This means: not (x == y)
print(not x == y) # not (True == False) -> not False -> True

# If we meant (not x) == y
print((not x) == y) # (False) == False -> True (coincidentally same result here)
```

**Snippet 2: edge case (Precedence between 'and' and 'or')**
```python
# 'and' has higher precedence than 'or'
# A or B and C is evaluated as A or (B and C)
result = True or False and False
print(result) # True (True or (False and False) -> True or False -> True)

# To force the 'or' first, use parentheses
result2 = (True or False) and False
print(result2) # False (True and False -> False)
```

**Snippet 3: حالة عملية (Complex validation logic)**
```python
age = 25
has_license = True
has_permit = False

# We want to allow if (age > 21 and has_license) OR has_permit
# Because 'and' binds tighter, we can write it without parentheses:
can_drive = age > 21 and has_license or has_permit
print(can_drive) # True

# BUT it's always better to use parentheses for readability!
can_drive_clear = (age > 21 and has_license) or has_permit
```

### الفايدة الانترفيوية
**"Explain operator precedence in Python. How does `not x == y` evaluate?"**
الإجابة: بايثون بتحترم PEMDAS. الـ `**` right-associative. عوامل المقارنة (زي `==`) ليها precedence أعلى من الـ logical operators (`not`, `and`, `or`). عشان كده `not x == y` بتتقيّم لـ `not (x == y)`. والـ `and` ليها precedence أعلى من الـ `or`.

> [!danger] فخ خطير
> ```python
> # The -2 ** 2 trap!
> # People think (-2) * (-2) = 4
> # Python sees -(2 ** 2) = -4
> print(-2 ** 2) # -4!
> 
> # Always use parentheses for unary minus with exponent if you mean the base is negative.
> print((-2) ** 2) # 4
> ```

> [!tip] Checkpoint
> # `**` is right-associative: `2**3**2` = `2**9`.
> # `-2 ** 2` = `-4`.
> # `not x == y` = `not (x == y)`.
> # `and` beats `or`.

---

## Q27 — إيه الـ comparison operators وإزاي بايثون بتسمح بـ chaining؟ (`1 < x < 10`)

### أصل الحكاية
في لغات تانية، عشان تتأكد إن رقم بين رقمين، لازم تكتب `x > 1 and x < 10`. بايثون جايبة حاجة حلوة جداً اسمها Chained Comparisons. إنت تقدر تكتبها بالظبط زي الرياضة: `1 < x < 10`. بايثون بتفهمها وبتترجمها لـ `1 < x and x < 10`. الميزة هنا مش بس شكلها حلو، بايثون بتحسب `x` مرة واحدة بس، ولو الجزء الأول `1 < x` طلع False، بايثون مش بتكمل وتعمل short-circuit. ده مفيد جداً لو `x` فانكشن مكلفة أو لوnull.

```python
x = 5

# Chained comparison (Pythonic and efficient)
print(1 < x < 10) # True

# This is evaluated as: (1 < x) and (x < 10)
# If the first is False, the second is not evaluated.
print(10 < x < 20) # False
```

**Snippet 1: حالة بسيطة (Multiple operators in chain)**
```python
x = 5
y = 10

# You can chain different operators
print(0 < x <= y < 20) # True (0 < 5 and 5 <= 10 and 10 < 20)
```

**Snippet 2: edge case (Evaluating function calls safely)**
```python
def get_value():
    print("Calculating value...")
    return 5

# Because of chaining and short-circuiting:
# If 1 < get_value() is False, get_value() won't be called again for the second check!
# Wait, actually Python evaluates it once and reuses it.
print(1 < get_value() < 10) 
# Prints "Calculating value..." ONCE, then True.
```

**Snippet 3: حالة عملية (Checking bounds in arrays)**
```python
def get_neighbor(arr, index):
    # Check if index is valid in one clean line
    if 0 <= index < len(arr):
        return arr[index]
    return None

data = [10, 20, 30]
print(get_neighbor(data, 1)) # 20
print(get_neighbor(data, 5)) # None
```

### الفايدة الانترفيوية
**"How does comparison chaining work in Python? E.g., `1 < x < 10`"**
الإجابة: بايثون بتسمح بكتابة المقارنات ورا بعض زي الرياضة `1 < x < 10`. بايثون بترجمها لـ `1 < x and x < 10`. الميزة إنها بتقيّم `x` مرة واحدة بس، وبتعمل short-circuit (لو أول مقارنة False، بتفصل ومش بتحسب التانية).

> [!warning] فخ شائع
> ```python
> # Chaining is not the same as (1 < x) < 10!
> # (1 < x) < 10 evaluates the boolean result of (1 < x) and compares it to 10.
> # If x = 5: (1 < 5) is True. True < 10 -> 1 < 10 -> True (Coincidentally works)
> # If x = 0: (1 < 0) is False. False < 10 -> 0 < 10 -> True (Wrong! 0 is not > 1)
> ```

> [!tip] Checkpoint
> # `a < b < c` = `a < b and b < c`.
> # `b` is evaluated only once.
> # Short-circuits if any part is False.

---

## Q28 — إيه الـ logical operators (`and`, `or`, `not`) وإزاي بيشتغلوا بـ short-circuit evaluation؟

### أصل الحكاية
العوامل المنطقية `and` و`or` و`not` بيتستخدموا لدمج الشروط. بس بايثون (زي لغات تانية) بتعمل حاجة اسمها short-circuit evaluation. يعني إيه؟ معنى `and` إن الاتنين لازم يكونوا True. فلو بايثون شافت الجزء الأول False، مش هتدخل أصلاً تختبر الجزء التاني، لأن النتيجة أكيد False. ومعنى `or` إن واحد منهم بس True يبقى كفاية. فلو شافت الأول True، مش هتختبر التاني. ده بيحمينا من أخطاء الـ None وزي ما نقول `if user and user.is_active()`.

```python
# Short-circuit with 'and'
# If the first is False, the second is NOT evaluated.
def check_second():
    print("Second checked!")
    return True

print(False and check_second()) # False (check_second never runs)

# Short-circuit with 'or'
# If the first is True, the second is NOT evaluated.
print(True or check_second()) # True (check_second never runs)
```

**Snippet 1: حالة بسيطة (Preventing AttributeError)**
```python
user = None

# If user is None, the second part is not evaluated.
# This prevents: AttributeError: 'NoneType' object has no attribute 'is_admin'
if user and user.is_admin():
    print("Welcome admin")
else:
    print("Access denied") # This runs
```

**Snippet 2: edge case (Complex short-circuiting)**
```python
# Order matters for performance!
# Put the cheapest/most likely to fail condition first.
def expensive_check():
    import time
    time.sleep(2)
    return True

def cheap_check():
    return False

# If cheap_check is False, expensive_check is skipped!
if cheap_check() and expensive_check():
    print("This won't print, and no 2-second delay!")
```

**Snippet 3: حالة عملية (Validating inputs)**
```python
def process_file(filepath):
    # Check if filepath is not None AND file exists
    if filepath and os.path.exists(filepath):
        # Only run if both are true
        pass
```

### الفايدة الانترفيوية
**"What is short-circuit evaluation in Python? Give an example."**
الإجابة: هي إن بايثون بتبطل تقييم باقي الشروط لما النتيجة تبقى محسومة. في الـ `and`، لو الأول False، بايثون بترجع False فوراً من غير ما تختبر الباقي. في الـ `or`، لو الأول True، بترجع True فوراً. ده بينفعنا نكتب `if obj and obj.method()` عشان نتجنب أخطاء الـ None.

> [!danger] فخ خطير
> ```python
> # Relying on side effects in logical operators
> # If you put a function with side effects after 'and' or 'or', it might not run!
> 
> def send_email():
>     print("Email sent")
>     return True
> 
> is_valid = False
> if is_valid and send_email(): # send_email() NEVER RUNS!
>     pass
> ```

> [!tip] Checkpoint
> # `and`: Stops at the first False.
> # `or`: Stops at the first True.
> # Useful for `if x and x.attr`.

---

## Q29 — إزاي `and` و`or` بترجع القيمة نفسها مش بس `True`/`False`؟ (مثال: `x = 0 or "default"`)

### أصل الحكاية
ده من أهم الأسئلة اللي بتفرق مبرمج بايثون المبتديء عن المتقدم. الـ `and` و`or` في بايثون مش بيرجعوا `True` أو `False` بالضرورة. هما بيرجعوا "القيمة" اللي وقف عندها الـ short-circuit. الـ `or` بيرجع أول قيمة Truthy يلاقيها، ولو كلهن Falsy بيرجع آخر واحدة. الـ `and` بيرجع أول قيمة Falsy يلاقيها، ولو كلهن Truthy بيرجع آخر واحدة. ده بيخلينا نعمل حاجات زي `x = name or "Guest"` (لو name فاضي، حط Guest)، أو `config = env_config and file_config`.

```python
# 'or' returns the first truthy value, or the last value if all are falsy.
print(10 or 20)       # 10 (10 is truthy, stops here)
print(0 or 20)        # 20 (0 is falsy, checks next)
print(0 or "")        # "" (both falsy, returns the last one)

# 'and' returns the first falsy value, or the last value if all are truthy.
print(10 and 20)      # 20 (10 is truthy, checks next, returns last)
print(0 and 20)       # 0 (0 is falsy, stops here and returns 0)
```

**Snippet 1: حالة بسيطة (Setting default values)**
```python
# The classic Pythonic default value pattern
user_input = "" # Falsy

# If user_input is falsy, fall back to "Guest"
username = user_input or "Guest"
print(username) # Guest

user_input = "Ali"
username = user_input or "Guest"
print(username) # Ali
```

**Snippet 2: edge case (Chaining 'or')**
```python
# Chaining multiple 'or's returns the first truthy one
config = env_config or file_config or default_config or "No config"
# It will evaluate from left to right until it finds a truthy value.
```

**Snippet 3: حالة عملية (Conditional execution with 'and')**
```python
# You can use 'and' to run a function only if a condition is true
is_logged_in = True

# If is_logged_in is True, it evaluates and returns the second part (the function call)
is_logged_in and print("Welcome back!") # Prints "Welcome back!"

is_logged_in = False
is_logged_in and print("Welcome back!") # Does nothing, returns False
```

### الفايدة الانترفيوية
**"What do `and` and `or` return in Python? Are they strictly boolean?"**
الإجابة: لأ، `and` و`or` في بايثون بيرجعوا الـ object نفسه اللي وقف عنده الـ evaluation. `or` بيرجع أول قيمة Truthy (أو آخر Falsy لو كلهن Falsy). `and` بيرجع أول قيمة Falsy (أو آخر Truthy لو كلهن Truthy). ده بيسمح بكتابة patterns زي `x = a or b` لتحديد default value من غير ما نستخدم `if`.

> [!warning] فخ شائع
> ```python
> # Assuming 'or' returns a boolean
> result = (5 or 0)
> if result == True: # This is False! result is 5, not True.
>     print("This won't print")
> 
> # Correct check
> if result: # This checks truthiness, works fine.
>     print("This prints")
> ```

> [!tip] Checkpoint
> # `a or b`: Returns `a` if truthy, else `b`.
> # `a and b`: Returns `a` if falsy, else `b`.
> # This is NOT boolean logic, it's value returning!