---
tags: [python, interview-prep, foundations]
part: 1 of 2
covers: "من الصفر لحد Functions + الفروقات الغريبة عن اللغات التانية"
---

# 🐍 بايثون من الصفر — الجزء الأول: الأساسيات والفروقات الغريبة

> [!info] إزاي تذاكر الملف ده
> كل سؤال هنا مصمم عشان يودّيك للي بعده. مش لازم تحفظ، افهم *ليه* بايثون بتتصرف كده مقارنة باللغات التانية. كل كود فيه كومنتات إنجليزي بس — علشان تتعود على لغة الانترفيو نفسها.

---

## Q1 — ليه بايثون معندهاش `var x = 5`؟

### أصل الحكاية
في C أو Java، أول حاجة بتعلمها هي إنك لازم تقول للكمبيوتر "أنا هعمل متغير اسمه x من نوع int، وحطله قيمة 5". بايثون بترفض الكلام ده تماماً. ليه؟ لأن الفلسفة مختلفة من الأساس: **المتغير في بايثون مش صندوق فيه قيمة، هو ملصق (label) واقف على حاجة موجودة في الذاكرة**.

```python
x = 5
# x is not a "box containing 5"
# x is a NAME that points to an integer object living in memory
print(id(x))  # memory address of the object 5 points to

y = x
# y now points to the SAME object, not a copy
print(id(y) == id(x))  # True
```

### الفايدة الانترفيوية
سؤال كلاسيكي: *"Explain how variable assignment works in Python."* الإجابة الصح: بايثون بتستخدم **name binding**، مش storage. كل قيمة هي object ليها identity وtype، والمتغير مجرد اسم بيتربط بيها.

> [!tip] Checkpoint
> لو حد سألك "هل بايثون statically typed ولا dynamically typed؟" — قوله: *dynamically typed*، يعني الـ type بتاع الـ variable بيتحدد وقت الـ runtime مش وقت الـ compile، والمتغير نفسه مالوش type ثابت، النوع بيبقى property للـ object مش للاسم.

---

## Q2 — طب لو المتغير مجرد ملصق، إزاي أعرف لو نسختين "نفس الحاجة" فعلاً؟

### أصل الحكاية
هنا بيجي أشهر فخ في بايثون كله: الفرق بين `==` و `is`.

```python
a = [1, 2, 3]
b = [1, 2, 3]
c = a

print(a == b)  # True -> same VALUES
print(a is b)  # False -> different objects in memory
print(a is c)  # True -> same object, c is just another label for a
```

### الفايدة الانترفيوية
`==` بتنادي على `__eq__` وبتقارن **القيمة**. `is` بتقارن **identity** (يعني `id(obj)` متطابق ولا لأ). دي من أكتر الأسئلة اللي بتتسأل في أي Python interview.

> [!warning] فخ شهير: Integer Caching
> ```python
> x = 5
> y = 5
> print(x is y)  # True! Python caches small integers (-5 to 256)
> 
> x = 500
> y = 500
> print(x is y)  # False (usually) - not cached, different objects
> ```
> السبب: بايثون بتعمل caching لأرقام صغيرة (من -5 لـ 256) عشان الأداء، فمتعتمدش على `is` أبداً في مقارنة القيم — استخدم `==`.

---

## Q3 — ليه في بايثون مفيش `{}` ولا `;`؟ الـ Indentation ده بجد بيفرق؟

### أصل الحكاية
في أغلب اللغات، الـ indentation مجرد "شياكة" — الكمبيوتر مش بيهتم بيها، هي بس عشان عين المبرمج. في بايثون، **الـ indentation جزء من الـ syntax نفسه**. لو غلطت فيها، الكود مش هيشتغل خالص.

```python
def check_age(age):
    if age >= 18:
        print("Adult")
        # This line MUST be indented to belong to the if block
    else:
        print("Minor")
    return age  # This is OUTSIDE the if/else, part of the function only
```

### الفايدة الانترفيوية
سؤال شائع: *"What's PEP 8 and why does indentation matter in Python?"* الإجابة: PEP 8 هي الـ style guide الرسمي، وبتنصح بـ 4 spaces للـ indentation. لكن الأهم إنك تقول: الـ indentation في بايثون مش اختيارية — هي اللي بتحدد الـ **scope** بتاع الكود (block structure) بدل الأقواس المعقوصة.

> [!tip] Checkpoint
> `IndentationError` هو أول error هتقابله وانت بتتعلم — ده مش bug في بايثون، ده feature بيجبرك تكتب كود منظم.

---

## Q4 — كل حاجة في بايثون "Object"؟ حتى الأرقام والـ Functions؟

### أصل الحكاية
دي الجملة اللي بتلخص فلسفة بايثون كلها: **"Everything in Python is an object."** حتى الـ `int`، حتى الـ `function`، حتى الـ `class` نفسها.

```python
x = 5
print(type(x))          # <class 'int'>
print(x.bit_length())   # 3 -> even integers have methods!

def greet():
    return "hello"

print(type(greet))      # <class 'function'>
greet.custom_attr = "I am attached to a function object"
print(greet.custom_attr)
```

### الفايدة الانترفيوية
سؤال تجريبي: *"What does it mean that functions are first-class citizens in Python?"* معناها إن الـ function object زيها زي أي object تاني — تقدر تحطها في متغير، تبعتها كـ parameter، ترجعها من function تانية. ده الأساس اللي بيبني عليه الـ **Functional Programming** في بايثون (هنتكلم عنه بالتفصيل في الملف التاني).

---

## Q5 — إيه الفرق بين `None` و `null` و `undefined`؟

### أصل الحكاية
في JavaScript عندك `null` و `undefined` (اتنين مختلفين). بايثون بتبسطها في حاجة واحدة بس: `None`. لكن `None` ذات نفسه هو **object** كامل من نوع `NoneType`، مش مجرد "قيمة فاضية".

```python
x = None
print(type(x))       # <class 'NoneType'>
print(x is None)      # True -> the correct way to check
print(x == None)      # also True, but 'is' is the Pythonic convention
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> اتسأل كتير: *"Why do we use `is None` instead of `== None`?"* الإجابة: لأن `None` هو **singleton** — يعني نسخة واحدة بس موجودة في كل البرنامج، فـ `is` أسرع وأدق (مبتعتمدش على `__eq__` اللي ممكن يتعمل override ليها في classes مخصصة).

---

## Q6 — إيه معنى Mutable و Immutable؟ ده بيأثر إزاي على الكود؟

### أصل الحكاية
ده من أهم المفاهيم في بايثون كله، وده اللي بيفرقها عن لغات تانية بشكل جوهري. بعض الـ objects تقدر تغيرها "في مكانها" (mutable)، وبعضها لأ — لو عايز تغيرها لازم تعمل object جديد (immutable).

```python
# Immutable: str, int, float, tuple, frozenset, bool
s = "hello"
s_id_before = id(s)
s = s + " world"
print(id(s) == s_id_before)  # False -> a NEW object was created

# Mutable: list, dict, set
lst = [1, 2, 3]
lst_id_before = id(lst)
lst.append(4)
print(id(lst) == lst_id_before)  # True -> SAME object, modified in place
```

### الفايدة الانترفيوية
سؤال قاتل بيتسأل جداً: *"What happens when you pass a list to a function and modify it?"*

```python
def add_item(container):
    container.append("new")  # mutates the ORIGINAL list

my_list = [1, 2, 3]
add_item(my_list)
print(my_list)  # [1, 2, 3, 'new'] -> changed! because lists are mutable
```

> [!danger] الفخ الأشهر في بايثون كله: Mutable Default Arguments
> ```python
> def append_to(element, target=[]):  # DANGER: default list created ONCE
>     target.append(element)
>     return target
> 
> print(append_to(1))  # [1]
> print(append_to(2))  # [1, 2] -> NOT [2]! same list reused every call
> ```
> السبب: الـ default argument بيتقيّم **مرة واحدة بس** وقت تعريف الـ function، مش كل مرة بتنادي عليها. الحل الصح:
> ```python
> def append_to(element, target=None):
>     if target is None:
>         target = []
>     target.append(element)
>     return target
> ```
> السؤال ده لو جالك في انترفيو وجاوبته صح، غالباً هتاخد نقطة كبيرة — لأنه بيفرّق بين اللي حفظ syntax واللي فاهم internals.

---

## Q7 — إزاي أعمل Swap بين متغيرين من غير `temp`؟

### أصل الحكاية
في C أو Java، عشان تبدل قيمة متغيرين لازم متغير مؤقت (temp). بايثون بتديك حل أنيق جداً بسبب mechanism اسمها **tuple packing/unpacking**.

```python
a, b = 5, 10
a, b = b, a  # right side builds a tuple (b, a) FIRST, then unpacks it
print(a, b)  # 10 5
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> اتسأل: *"How does multiple assignment work under the hood?"* الإجابة: بايثون بتبني الـ tuple بتاع اليمين الأول بالكامل (`(b, a)`)، وبعدين بتوزعه على المتغيرات اللي في الشمال. ده بيمنع الـ overwrite bug اللي ممكن يحصل في لغات تانية.

---

## Q8 — إيه الفرق بين `/` و `//` و `%`؟

### أصل الحكاية
بايثون بتفرّق بوضوح بين القسمة العادية والقسمة الصحيحة — حاجة مش موجودة بنفس الوضوح في لغات زي C.

```python
print(7 / 2)    # 3.5  -> true division, ALWAYS returns float
print(7 // 2)   # 3    -> floor division, rounds DOWN (toward negative infinity)
print(-7 // 2)  # -4   -> not -3! floors toward negative infinity, not zero
print(7 % 2)    # 1    -> remainder (modulo)
print(-7 % 2)   # 1    -> sign follows the DIVISOR, not the dividend
```

### الفايدة الانترفيوية
> [!warning] الفخ هنا
> ناس كتير بتفتكر `//` زي الـ `int()` casting بعد القسمة، لكن دي غلطة مع الأرقام السالبة. `-7 // 2` بتساوي `-4` مش `-3` لأن بايثون بتعمل **floor** (تنزل تحت) مش **truncate** (تقطع نحو الصفر).

---

## Q9 — إيه الفرق بين List و Tuple غير إن واحد بـ `[]` والتاني بـ `()`؟

### أصل الحكاية
دي حتة تفرقة جوهرية: الفرق مش شكلي، الفرق في **الطبيعة** بتاعة كل نوع.

```python
my_list = [1, 2, 3]   # mutable, slightly slower, more memory
my_tuple = (1, 2, 3)  # immutable, faster, less memory, hashable

my_list[0] = 99        # OK
# my_tuple[0] = 99      # TypeError: 'tuple' object does not support item assignment

# Because tuples are immutable, they can be used as dict keys!
d = {(1, 2): "point A"}
# d = {[1, 2]: "point A"}  # TypeError: unhashable type: 'list'
```

### الفايدة الانترفيوية
سؤال شائع: *"When would you use a tuple instead of a list?"* الإجابة: لما عايز البيانات تفضل ثابتة (زي coordinates أو RGB values)، أو لما محتاج تستخدمها كـ dictionary key أو set element (لازم تكون hashable، والـ mutable objects مش hashable).

---

## Q10 — إزاي بايثون بتعمل "String Formatting"؟ وليه الـ f-string أحسن حاجة؟

### أصل الحكاية
بايثون عدّت بمراحل: `%` formatting القديم، بعدين `.format()`، وأخيراً f-strings (من بايثون 3.6). كل واحدة بتحل مشكلة اللي قبلها.

```python
name = "Mohamed"
age = 25

old_style = "My name is %s and I am %d" % (name, age)
format_style = "My name is {} and I am {}".format(name, age)
f_string = f"My name is {name} and I am {age}"  # cleanest and fastest

# f-strings can even evaluate expressions inline
print(f"Next year I'll be {age + 1}")
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> f-strings مش بس أنضف — هي كمان أسرع وقت الـ runtime لأنها بتتقيّم مرة واحدة كـ bytecode، عكس `.format()` اللي بيعمل method call كامل.

---

## Q11 — إيه هي List Comprehension، وليه بيحبوها في الانترفيوهات؟

### أصل الحكاية
لو جاي من لغة زي Java، إنت متعود إنك تكتب loop كامل عشان تبني list. بايثون بتديك طريقة تكتب بيها الفكرة في سطر واحد، وده بيبقى إثبات إنك "بتفكر Pythonic".

```python
# The "old" way
squares = []
for i in range(10):
    if i % 2 == 0:
        squares.append(i ** 2)

# The Pythonic way
squares = [i ** 2 for i in range(10) if i % 2 == 0]
print(squares)  # [0, 4, 16, 36, 64]

# Dict comprehension works the same way
squares_dict = {i: i ** 2 for i in range(5)}

# Set comprehension too
unique_lengths = {len(word) for word in ["cat", "dog", "elephant"]}
```

### الفايدة الانترفيوية
سؤال شائع: *"Rewrite this loop as a one-liner."* لو قدرت تحول أي `for` loop بسيط لـ comprehension، ده بيدي انطباع إنك متمكن من الـ language idioms، مش بس بتكتب كود شغال.

> [!warning] لكن حذاري
> comprehension معقدة أكتر من سطرين بتبقى صعبة القراءة. الـ readability أهم من الـ "شياكة" — لو الـ logic معقد، ارجع للـ loop العادي.

---

## Q12 — إيه معنى Truthy و Falsy في بايثون؟

### أصل الحكاية
بايثون مش بتحتاج منك تكتب `if len(my_list) > 0:` — هي بتقدر "تحس" لو الـ object فاضي أو لأ من غير ما تقارنه بحاجة.

```python
# All of these are considered "falsy"
falsy_values = [False, None, 0, 0.0, "", [], {}, set(), ()]

if []:
    print("won't print")
else:
    print("empty list is falsy")

# Idiomatic Python: check emptiness directly, don't compare to length
my_list = []
if not my_list:       # Pythonic
    print("list is empty")
if len(my_list) == 0:  # works, but less idiomatic
    print("also works")
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> اتسأل: *"What values are falsy in Python?"* لازم تعرفهم غيباً: `False`, `None`, `0`, `0.0`, `""`, `[]`, `{}`, `set()`, `()`. أي object تاني بشكل افتراضي بيبقى truthy، إلا لو الـ class بتاعه عمل override لـ `__bool__` أو `__len__`.

---

## Q13 — إيه الفرق بين `*args` و `**kwargs`؟

### أصل الحكاية
أحياناً مش عارف مقدماً كام argument هيتبعت للـ function. بايثون حلت المشكلة دي بـ "packing" — تجميع أي عدد من الـ arguments في structure واحدة.

```python
def describe(*args, **kwargs):
    # args is a TUPLE of positional arguments
    # kwargs is a DICT of keyword arguments
    print("Positional:", args)
    print("Keyword:", kwargs)

describe(1, 2, 3, name="Mohamed", role="lead")
# Positional: (1, 2, 3)
# Keyword: {'name': 'Mohamed', 'role': 'lead'}

# Unpacking works the OPPOSITE way too
def add(a, b, c):
    return a + b + c

nums = [1, 2, 3]
print(add(*nums))  # unpacks list into 3 separate positional args

info = {"a": 1, "b": 2, "c": 3}
print(add(**info))  # unpacks dict into keyword arguments
```

### الفايدة الانترفيوية
سؤال بيتسأل جداً: *"How would you write a function that accepts any number of arguments?"* — دي بالظبط الإجابة، والاسم `args`/`kwargs` مجرد convention، النجمة `*`/`**` هي اللي بتعمل الشغل الفعلي.

---

## Q14 — إيه هو الـ Walrus Operator `:=`؟

### أصل الحكاية
حاجة جديدة نسبياً (بايثون 3.8+)، بتسمحلك تعمل assignment و**تستخدم القيمة في نفس السطر** — حاجة كانت مستحيلة قبل كده في بايثون.

```python
# Before walrus: you'd call the function twice, wasting computation
data = [1, 2, 3, 4, 5]
# if len(data) > 3:
#     print(f"List is long: {len(data)}")

# With walrus: compute once, assign, and check
if (n := len(data)) > 3:
    print(f"List is long: {n}")

# Very common in while loops reading input/data streams
# while (chunk := file.read(1024)):
#     process(chunk)
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> اتسأل ليه اتضافت أصلاً: عشان توفر إعادة حساب أو استدعاء تاني لنفس الـ expression جوه شرط أو loop condition. بتخلي الكود أقصر وأحياناً أسرع.

---

## Q15 — إيه الفرق بين `global` و `nonlocal`؟

### أصل الحكاية
بايثون بتقفل كل function جوه "scope" خاص بيها. لو عايز تعدّل متغير خارج الـ scope ده، لازم تقول لبايثون بصراحة إنك ناوي كده.

```python
counter = 0

def increment_global():
    global counter          # refers to the module-level 'counter'
    counter += 1

def outer():
    count = 0
    def inner():
        nonlocal count      # refers to 'count' in the ENCLOSING function
        count += 1
    inner()
    inner()
    return count

increment_global()
print(counter)     # 1
print(outer())      # 2
```

### الفايدة الانترفيوية
سؤال دقيق بيميز بين المستويات: *"What's the difference between `global` and `nonlocal`?"* — `global` بتشاور على متغير على مستوى الـ module، `nonlocal` بتشاور على متغير في function محيطة (enclosing function) — دي أساس فهم الـ **closures** اللي هنتكلم عنها في الملف التاني.

---

## Q16 — الـ Slicing في بايثون — إيه أقوى حاجة فيه؟

### أصل الحكاية
لغات كتير بتديك `substring()` أو `subarray()` بشكل معقد. بايثون عملتها syntax واحد بسيط وقوي جداً: `[start:stop:step]`.

```python
nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

print(nums[2:5])     # [2, 3, 4]     -> stop is EXCLUSIVE
print(nums[:3])       # [0, 1, 2]     -> start defaults to 0
print(nums[7:])       # [7, 8, 9]     -> stop defaults to end
print(nums[::2])      # [0, 2, 4, 6, 8]  -> every 2nd element
print(nums[::-1])     # [9, 8, ..., 0]   -> reverses the list!
print(nums[-3:])      # [7, 8, 9]     -> negative indices count from the end
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> `nums[::-1]` هو الطريقة الـ idiomatic لعكس أي sequence في بايثون — بيتسأل جداً كـ "one-liner trick". ولازم تعرف إن الـ slicing بترجع **نسخة جديدة**، مش reference للـ original.

---

## Q17 — إيه الفرق بين `import module` و `from module import thing`؟

### أصل الحكاية
دي مش مجرد اختلاف شكلي — بتأثر على الـ **namespace** وإزاي بتنادي على الحاجات.

```python
import math
print(math.sqrt(16))   # must prefix with module name

from math import sqrt
print(sqrt(16))          # can call directly, but pollutes local namespace

from math import sqrt as square_root  # renaming to avoid name clashes
print(square_root(16))
```

### الفايدة الانترفيوية
> [!warning] فخ شائع: `from module import *`
> بتجيب كل حاجة من الموديول للـ namespace الحالي، وده ممكن يعمل **name collisions** (تضارب أسماء) صعبة الاكتشاف. في الشغل الاحترافي، تجنبها تماماً واستخدم `import module` أو `from module import specific_thing`.

---

## Q18 — إزاي بايثون بتتعامل مع الأخطاء؟ `try/except` بس كده؟

### أصل الحكاية
بايثون بتتبع فلسفة اسمها **EAFP**: *"Easier to Ask Forgiveness than Permission"* — يعني جرّب تنفذ الكود، ولو حصل error، امسكه. ده عكس فلسفة **LBYL** (*Look Before You Leap*) اللي شائعة في لغات تانية زي C.

```python
# LBYL style (check first, common in other languages)
d = {"a": 1}
if "b" in d:
    print(d["b"])
else:
    print("key not found")

# EAFP style (Pythonic - try first, handle failure)
try:
    print(d["b"])
except KeyError:
    print("key not found")

# Multiple exception types, plus else and finally
try:
    result = 10 / 0
except ZeroDivisionError as e:
    print(f"Error: {e}")
except TypeError:
    print("wrong type")
else:
    print("runs only if NO exception happened")
finally:
    print("always runs, exception or not")
```

### الفايدة الانترفيوية
سؤال مفاهيمي عميق: *"What is EAFP and why does Python favor it?"* الإجابة: لأنها بتبقى أسرع وقت الـ runtime في أغلب الحالات (مفيش double-checking)، وبتقلل الـ race conditions (زي إنك تتشيك إن الملف موجود، وبين التشيك والفتح حد يمسحه).

---

## Q19 — إيه الفرق بين Shallow Copy و Deep Copy؟

### أصل الحكاية
لما عندك list جوه list، النسخ العادي بيبقى كارثة لو ماعرفتش الفرق ده.

```python
import copy

original = [[1, 2], [3, 4]]

shallow = original.copy()          # or list(original) or original[:]
deep = copy.deepcopy(original)

shallow[0][0] = "CHANGED"
print(original)  # [['CHANGED', 2], [3, 4]] -> inner list is SHARED!

deep[1][0] = "SAFE"
print(original)  # unaffected -> deep copy duplicates EVERYTHING recursively
```

### الفايدة الانترفيوية
> [!danger] فخ كلاسيكي
> `shallow copy` بتعمل نسخة من الـ outer container بس، لكن الـ elements الجوانية (لو mutable زي lists) بتفضل **مشتركة** (نفس الـ reference). الـ `deep copy` بتنسخ كل حاجة recursively. ده سؤال بيفرق بين اللي فاهم memory model بايثون واللي لأ.

---

## Q20 — ليه بايثون فيها `range()` بدل ما تكتب list أرقام على طول؟

### أصل الحكاية
هنا بنلمس مفهوم مهم جداً هيتكرر في الملف التاني: **Lazy Evaluation**. `range()` مش بتبني list كامل في الذاكرة، هي بتولّد الأرقام واحد واحد وقت الحاجة بس.

```python
r = range(1_000_000)
print(type(r))          # <class 'range'> -> NOT a list!
print(r)                 # range(0, 1000000) -> stored as start/stop/step only

# Almost no memory used, regardless of the range size
import sys
print(sys.getsizeof(r))              # tiny, e.g. 48 bytes
print(sys.getsizeof(list(r)))         # huge, several MB
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> `range` هو أول مثال هتقابله على "lazy" objects في بايثون — نفس الفكرة هتلاقيها تاني في `map()`, `filter()`, و **generators** (تفصيل كامل في الملف التاني تحت الـ FP). فكرة الـ laziness دي أساسية في أي Python performance interview question.

---

## 🫒 زتونة الإنترفيو (Interview Zaytona)

لو هيسألوك سؤال واحد بس من كل الملف ده، الأغلب هيبقى واحد من دول:

1. **"Explain mutable default arguments and why they're dangerous."** (Q6)
2. **"What's the difference between `is` and `==`?"** (Q2)
3. **"What is EAFP and how does Python's exception handling reflect it?"** (Q18)
4. **"Explain shallow vs deep copy with an example."** (Q19)

> [!success] الخلاصة
> الفكرة الأساسية اللي المفروض تطلع بيها من الملف ده: بايثون مش "بتخبي" التعقيد عنك زي بعض اللغات — هي بتديك أدوات بسيطة الشكل (زي `=` و `[]`) لكن وراها **object model** واضح ومتسق. لو فهمت الـ mental model ده (كل حاجة object، الأسماء labels، mutability بتفرق)، أي سؤال تفصيلي هتقدر تستنتجه حتى لو مذاكرتوش حرفياً.

---

**التالي:** الملف التاني هيغطي OOP كامل (classes, inheritance, magic methods) + Functional Programming (lambda, map/filter/reduce, decorators, generators, closures) + أسئلة الانترفيو المتقدمة.
