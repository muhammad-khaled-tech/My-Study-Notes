---
tags: [python, interview-prep, oop, functional-programming, advanced]
part: 2 of 2
covers: "OOP كامل + Functional Programming + Advanced Interview Tricks"
---

# 🐍 بايثون من الصفر — الجزء الثاني: OOP + Functional Programming + Advanced

> [!info] قبل ما تبدأ
> الملف ده بيفترض إنك خلصت الجزء الأول (mutability, is vs ==, first-class functions, laziness في `range`). لو مش فاكر حاجة منهم، ارجعلها الأول لأنها هتتبني عليها هنا.

---

# 📦 القسم الأول: Object-Oriented Programming

## Q21 — إزاي بايثون بتبني Class فعلياً؟ وإيه معنى `self`؟

### أصل الحكاية
في Java أو C#، الـ `this` بتبقى implicit — الكومبايلر بيحطها لوحده. بايثون على العكس، **بتجبرك تكتب `self` بصراحة** كأول parameter في كل method. ده مش تعقيد زيادة، ده بيكشفلك حاجة مهمة: الـ method في بايثون هي في الأساس **function عادية** بتاخد الـ instance كـ parameter أول.

```python
class Dog:
    def __init__(self, name):
        self.name = name  # self IS the instance being created

    def bark(self):
        return f"{self.name} says Woof!"

d = Dog("Rex")
print(d.bark())               # "Rex says Woof!"

# What Python REALLY does behind the scenes:
print(Dog.bark(d))             # exact same result -> method is just a function
```

### الفايدة الانترفيوية
سؤال بيميز بين الحفظ والفهم: *"What is `self` and is it a keyword?"* الإجابة الصح: **`self` مش keyword أصلاً** — هي مجرد convention (اسم متفق عليه). ممكن تسميها أي حاجة، لكن محدش بيعمل كده لأنها بتكسر القراءة للكل.

> [!tip] Checkpoint
> `__init__` مش الـ constructor الحقيقي — هي **initializer**. الـ constructor الفعلي هو `__new__` (اللي بيعمل الـ object فعلياً في الذاكرة)، و`__init__` بيجي بعده يهيئها. سؤال متقدم بيتسأل: *"What's the difference between `__new__` and `__init__`؟"*

---

## Q22 — إزاي الـ Inheritance شغالة في بايثون؟ وإيه الـ MRO؟

### أصل الحكاية
بايثون بتدعم **Multiple Inheritance** (كلاس يورّث من أكتر من كلاس)، حاجة مش موجودة في Java مثلاً. ده بيفتح باب لمشكلة اسمها **Diamond Problem**، وبايثون حلتها بخوارزمية اسمها **C3 Linearization** أو باختصار **MRO (Method Resolution Order)**.

```python
class Animal:
    def speak(self):
        return "Some sound"

class Swimmer:
    def speak(self):
        return "Splash"

class Duck(Animal, Swimmer):  # inherits from BOTH
    pass

d = Duck()
print(d.speak())        # "Some sound" -> follows MRO, Animal comes first

print(Duck.__mro__)
# (Duck, Animal, Swimmer, object) -> the exact lookup order Python uses
```

### الفايدة الانترفيوية
> [!warning] الـ Diamond Problem
> لو `Duck` ورثت من `Animal` و `Swimmer`، وكل واحد فيهم عنده method اسمها `speak`، بايثون بتحل التضارب ده بترتيب محدد (MRO) بتقدر تشوفه بـ `ClassName.__mro__` أو `ClassName.mro()`. ده سؤال متقدم لكن بيبان بيه إنك فاهم internals مش بس syntax.

---

## Q23 — إيه هو `super()` وليه بنستخدمه بدل ما ننادي على الكلاس الأب مباشرة؟

### أصل الحكاية
ممكن تفتكر إن `super()` مجرد اختصار لمناداة الكلاس الأب، لكنها أعمق من كده — هي بتحترم الـ MRO بالكامل، وده بيبقى فارق جوهري في حالة الـ multiple inheritance.

```python
class Base:
    def __init__(self, x):
        self.x = x
        print("Base init")

class Child(Base):
    def __init__(self, x, y):
        super().__init__(x)   # follows MRO, not just "call the parent directly"
        self.y = y
        print("Child init")

c = Child(1, 2)
# Base init
# Child init
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> لو استخدمت `Base.__init__(self, x)` بدل `super().__init__(x)`، هيشتغل في الحالة البسيطة دي، لكن هيبوظ في multiple inheritance chains معقدة لأنه بيكسر ترتيب الـ MRO. الإجابة الاحترافية دايماً: **استخدم `super()`**.

---

## Q24 — إيه هي الـ Magic Methods (Dunder Methods)؟

### أصل الحكاية
دي من أقوى حاجات بايثون. أي عملية بتعملها على object — طباعة، جمع، مقارنة، حتى استخدامها في `len()` — كلها بترجع لـ **method خاصة اسمها زي كده `__method__`** (dunder = **d**ouble **under**score).

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        # called by print(), and in the REPL/debugger
        return f"Point({self.x}, {self.y})"

    def __eq__(self, other):
        # called when you use ==
        return self.x == other.x and self.y == other.y

    def __add__(self, other):
        # called when you use +
        return Point(self.x + other.x, self.y + other.y)

    def __len__(self):
        # called when you use len()
        return 2

p1 = Point(1, 2)
p2 = Point(3, 4)
print(p1 + p2)        # Point(4, 6) -> __add__ triggered by '+'
print(p1 == Point(1, 2))  # True -> __eq__ triggered by '=='
```

### الفايدة الانترفيوية
سؤال دايماً بيتسأل: *"What's the difference between `__str__` and `__repr__`؟"* — `__str__` للعرض البشري المقروء (بيتنادى في `print()`)، و`__repr__` للتمثيل الدقيق (بيتنادى في الـ REPL أو الـ debugger)، والقاعدة الذهبية: **لو معرفتش غير واحد بس، اعمل `__repr__`** لأنها بتبقى fallback للـ `__str__` لو مش موجودة.

> [!tip] Checkpoint
> ده اللي اسمه **Operator Overloading** — بايثون مش بتديك عمليات جاهزة على الـ custom classes، هي بتديك الـ hooks (الـ dunder methods) وانت اللي بتحدد المعنى.

---

## Q25 — إيه الفرق بين Class Variable و Instance Variable؟

### أصل الحكاية
فخ شائع جداً بيبان بسيط لكنه بيكسر كود ناس كتير.

```python
class Counter:
    count = 0  # CLASS variable -> shared across ALL instances

    def __init__(self):
        Counter.count += 1  # modifying the class variable itself
        self.id = Counter.count  # INSTANCE variable -> unique per object

c1 = Counter()
c2 = Counter()
print(c1.id, c2.id)      # 1 2 -> instance-specific
print(Counter.count)      # 2 -> shared, tracks total instances

# DANGER: mutable class variables are shared and can be a trap
class Team:
    members = []  # shared list! every instance mutates the SAME list

    def add_member(self, name):
        self.members.append(name)

t1 = Team()
t2 = Team()
t1.add_member("Mohamed")
print(t2.members)   # ['Mohamed'] -> leaked into t2! same trap as Q6 in Part 1
```

### الفايدة الانترفيوية
> [!danger] نفس فخ الـ mutable default arguments بس في شكل تاني
> لو الـ class variable كانت mutable (list/dict)، هي بتتشارك بين كل الـ instances — نفس منطق الفخ اللي شوفناه في الملف الأول. الحل: عرّف الـ mutable variables جوه `__init__` كـ instance variables.

---

## Q26 — إيه هي الـ `@property`؟ وليه أستخدمها بدل getter/setter عادي؟

### أصل الحكاية
لو جاي من Java، إنت متعود تكتب `getName()` و `setName()`. بايثون بتقولك: ابدأ بـ **public attribute عادي**، ولو احتجت logic إضافية بعدين (زي validation)، حوّلها لـ property من غير ما تغيّر الـ interface الخارجي خالص.

```python
class Employee:
    def __init__(self, salary):
        self._salary = salary  # underscore = "internal, don't touch directly"

    @property
    def salary(self):
        return self._salary

    @salary.setter
    def salary(self, value):
        if value < 0:
            raise ValueError("Salary can't be negative")
        self._salary = value

e = Employee(5000)
print(e.salary)      # 5000 -> looks like attribute access, but calls a method
e.salary = 6000       # calls the setter, validates automatically
# e.salary = -100     # raises ValueError
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> ده مثال على فلسفة بايثون: **"We're all consenting adults here"** — مفيش `private` حقيقي زي Java. الـ `_salary` بـ underscore واحد يعني "convention: متلمسهاش من برة"، والـ `__salary` بـ underscore مزدوج بيعمل **name mangling** (بيتحول لـ `_Employee__salary`) عشان يقلل تضارب الأسماء في الوراثة.

---

## Q27 — إيه الفرق بين Class Method و Static Method و Instance Method؟

### أصل الحكاية
ثلاث أنواع methods، كل واحدة عندها access مختلف للـ class نفسها.

```python
class Pizza:
    def __init__(self, toppings):
        self.toppings = toppings

    def describe(self):  # instance method: needs 'self', accesses instance data
        return f"Pizza with {self.toppings}"

    @classmethod
    def margherita(cls):  # classmethod: needs 'cls', accesses class, not instance
        return cls(["cheese", "tomato"])  # alternative constructor pattern

    @staticmethod
    def is_valid_topping(topping):  # staticmethod: needs NEITHER self nor cls
        return topping in ["cheese", "tomato", "mushroom", "olive"]

p = Pizza.margherita()        # factory method pattern, very common
print(p.describe())
print(Pizza.is_valid_topping("cheese"))  # just a utility function living in the class
```

### الفايدة الانترفيوية
سؤال متقدم شائع: *"When would you use a classmethod over `__init__`؟"* الإجابة: لما محتاج **alternative constructors** — طرق مختلفة لبناء نفس الـ object (زي `margherita()` هنا بدل ما تكتب `Pizza(["cheese", "tomato"])` كل مرة).

---

## Q28 — إيه هي الـ Abstract Base Classes؟

### أصل الحكاية
أحياناً عايز تجبر أي كلاس يرث منك إنه "لازم" ينفذ method معينة، وإلا الكود ميشتغلش. بايثون بتديك `ABC` (Abstract Base Class) عشان كده.

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass  # no implementation - child classes MUST override this

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14159 * self.radius ** 2

# shape = Shape()  # TypeError: Can't instantiate abstract class Shape
c = Circle(5)
print(c.area())  # 78.53975
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> ده بيقربنا لمفهوم **Interfaces** اللي في لغات زي Java، لكن بايثون بتستخدم كمان **Duck Typing** ("لو بيمشي زي بطة وبيصوت زي بطة، يبقى بطة") — يعني في أغلب الأحيان مش لازم ABC خالص، بايثون بتثق إنك عارف اللي بتعمله.

---

# ⚡ القسم التاني: Functional Programming

## Q29 — إيه معنى إن الـ Functions "First-Class Citizens"؟ (تفصيل)

### أصل الحكاية
شوفنا الفكرة دي في الملف الأول بسرعة (Q4). هنا هنبني عليها الأساس الكامل للـ Functional Programming.

```python
def square(x):
    return x * x

def cube(x):
    return x ** 3

# Functions can be stored in data structures
operations = [square, cube]
for op in operations:
    print(op(3))  # 9, then 27

# Functions can be passed as arguments to other functions
def apply(func, value):
    return func(value)

print(apply(square, 5))  # 25

# Functions can be RETURNED from other functions
def get_operation(name):
    if name == "square":
        return square
    return cube

op = get_operation("square")
print(op(4))  # 16
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> الـ 3 خصائص دي (تتخزن في متغير، تتبعت كـ argument، ترجع من function) هي **تعريف first-class functions** بالظبط. أي سؤال يسألك "explain first-class functions" جاوب بالتلات نقط دول بالظبط.

---

## Q30 — إيه هو الـ Closure؟

### أصل الحكاية
دي حتة سحرية شوية. الـ closure هو function "فاكرة" المتغيرات اللي كانت حواليها وقت ما اتعرفت، حتى لو الـ outer function خلصت شغلها وراحت.

```python
def make_multiplier(factor):
    def multiply(x):
        return x * factor  # 'factor' is captured from the enclosing scope
    return multiply

double = make_multiplier(2)
triple = make_multiplier(3)

print(double(5))   # 10 -> remembers factor=2
print(triple(5))    # 15 -> remembers factor=3, independently!

# Proof the closure "remembers" its own environment:
print(double.__closure__[0].cell_contents)  # 2
```

### الفايدة الانترفيوية
سؤال بيتسأل جداً في الـ senior interviews: *"What is a closure and give a real use case."* استخدام حقيقي: **decorators** (السؤال الجاي)، وكمان بتستخدم في عمل "factories" لـ functions مخصصة، زي `make_multiplier` هنا.

> [!warning] فخ شهير: Closures جوه Loop
> ```python
> functions = []
> for i in range(3):
>     functions.append(lambda: i)  # captures the VARIABLE i, not its value at creation time
> 
> print([f() for f in functions])  # [2, 2, 2] -> NOT [0, 1, 2]!
> ```
> السبب: الـ closure بتمسك بالـ **variable نفسها** مش القيمة وقت التعريف، وبما إن `i` بتتغير طول الـ loop، كل الـ lambdas بتشوف آخر قيمة ليها. الحل:
> ```python
> functions = [lambda i=i: i for i in range(3)]  # default arg captures value NOW
> print([f() for f in functions])  # [0, 1, 2]
> ```

---

## Q31 — إيه هو الـ Decorator؟ وإزاي هو استخدام عملي للـ Closures؟

### أصل الحكاية
الـ decorator هو function بتاخد function تانية، وبترجع نسخة "معدّلة" منها من غير ما تلمس الكود الأصلي. ده تطبيق مباشر لكل حاجة اتكلمنا عنها لحد دلوقتي: first-class functions + closures.

```python
import time

def timer(func):
    def wrapper(*args, **kwargs):  # accepts ANY arguments, thanks to Q13
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f}s")
        return result
    return wrapper  # this IS a closure - remembers 'func'

@timer  # equivalent to: slow_function = timer(slow_function)
def slow_function():
    time.sleep(1)
    return "done"

slow_function()
# slow_function took 1.0001s
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> `@timer` مجرد **syntactic sugar** لـ `slow_function = timer(slow_function)`. لو فهمت الجملة دي هتقدر تشرح decorator لأي حد. decorators شائعة جداً في الشغل الحقيقي: `@staticmethod`, `@property` (شوفناهم فوق)، وفي frameworks زي Flask: `@app.route("/")`.

> [!danger] فخ شائع: ضياع الـ metadata
> ```python
> print(slow_function.__name__)  # 'wrapper', NOT 'slow_function'!
> ```
> الحل: استخدم `functools.wraps`:
> ```python
> from functools import wraps
> def timer(func):
>     @wraps(func)  # preserves __name__, __doc__, etc.
>     def wrapper(*args, **kwargs):
>         ...
>     return wrapper
> ```

---

## Q32 — إيه هو الـ Generator؟ وإيه الفرق بينه وبين List؟

### أصل الحكاية
فاكر `range()` من الملف الأول وإزاي هي lazy (مش بتخزن كل حاجة في الذاكرة؟). الـ generator هو نفس الفكرة، لكن انت اللي بتكتبها بنفسك.

```python
def count_up_to(n):
    i = 1
    while i <= n:
        yield i    # pauses here, remembers state, resumes on next call
        i += 1

gen = count_up_to(3)
print(next(gen))   # 1
print(next(gen))   # 2
print(next(gen))   # 3
# print(next(gen))  # StopIteration

# The Pythonic way to consume a generator
for num in count_up_to(3):
    print(num)

# Generator expression: like list comprehension, but LAZY
squares_gen = (x ** 2 for x in range(1_000_000))  # instant, no memory used yet
squares_list = [x ** 2 for x in range(1_000_000)]  # builds ALL million items NOW
```

### الفايدة الانترفيوية
سؤال أداء كلاسيكي: *"When would you use a generator instead of a list?"* الإجابة: لما البيانات كبيرة جداً أو infinite، ولما انت محتاج تعالج item واحدة في المرة (زي قراءة ملف ضخم سطر سطر) — الـ generator بيستخدم ذاكرة ثابتة تقريباً بغض النظر عن حجم البيانات.

> [!tip] Checkpoint
> `yield` بتحول أي function عادية لـ generator function. الفرق الجوهري: `return` بتنهي الـ function تماماً، `yield` بـ **توقفها مؤقتاً وتحتفظ بالـ state** (قيم المتغيرات، مكان الوقوف) لحد ما حد ينادي `next()` تاني.

---

## Q33 — إيه هي `map`, `filter`, و `reduce`؟

### أصل الحكاية
دول التلات أدوات الكلاسيكية للـ functional programming في بايثون — كل واحدة بتاخد function وتطبقها على sequence بطريقة مختلفة.

```python
from functools import reduce

nums = [1, 2, 3, 4, 5]

# map: transform EVERY element
doubled = list(map(lambda x: x * 2, nums))
print(doubled)  # [2, 4, 6, 8, 10]

# filter: keep elements that pass a condition
evens = list(filter(lambda x: x % 2 == 0, nums))
print(evens)  # [2, 4]

# reduce: combine ALL elements into a SINGLE value
total = reduce(lambda acc, x: acc + x, nums)
print(total)  # 15 -> ((((1+2)+3)+4)+5)

# In modern Python, comprehensions are often preferred for readability
doubled_pythonic = [x * 2 for x in nums]
evens_pythonic = [x for x in nums if x % 2 == 0]
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> اتسأل جداً: *"Why isn't `reduce` a built-in function anymore in Python 3?"* الإجابة: Guido van Rossum (مبتكر بايثون) اعتبرها **less readable** من الـ explicit loop في أغلب الحالات، فنقلها لـ `functools` بدل ما تفضل built-in زي `map`/`filter`. ده بيوريك إن بايثون بتفضّل الوضوح على "الشياكة الوظيفية" حتى لو كانت من عائلة الـ FP.

---

## Q34 — إيه هو `lambda`؟ وإمتى استخدمه وإمتى لأ؟

### أصل الحكاية
الـ `lambda` هي function بلا اسم (anonymous function)، محدودة بسطر واحد (expression واحد بس، مفيش statements).

```python
add = lambda a, b: a + b
print(add(3, 4))  # 7

# Most common real use: as a quick "key" for sorting
people = [{"name": "Ali", "age": 30}, {"name": "Sara", "age": 25}]
sorted_people = sorted(people, key=lambda p: p["age"])
print(sorted_people)  # Sara (25) first, then Ali (30)
```

### الفايدة الانترفيوية
> [!warning] إمتى متستخدمهاش
> لو الـ logic معقدة أو محتاجة أكتر من سطر، استخدم `def` عادية بدل lambda. PEP 8 نفسه بينصح متعملش:
> ```python
> f = lambda x: x * 2  # BAD: assigning a lambda to a name
> def f(x): return x * 2  # GOOD: use a regular function instead
> ```
> الاستخدام الصحي الوحيد للـ lambda هو كـ argument مؤقت (زي `key=` في `sorted()`)، مش كـ function دائمة بتتخزن في متغير.

---

## Q35 — إيه هي الـ Higher-Order Functions؟ إزاي `map`/`filter`/`sorted` كلهم مثال عليها؟

### أصل الحكاية
دي الفكرة اللي بتلخص كل حاجة ذكرناها في القسم ده: أي function بتاخد function كـ input، أو بترجع function كـ output، اسمها **Higher-Order Function**.

```python
# All of these are higher-order functions:
sorted(nums, key=lambda x: -x)      # takes a function as argument
map(str.upper, ["a", "b"])            # takes a function as argument
make_multiplier(2)                     # RETURNS a function (from Q30)

# Decorators are higher-order functions that take AND return functions
def timer(func):  # takes a function
    ...
    return wrapper  # AND returns a function
```

### الفايدة الانترفيوية
> [!success] الخلاصة الكبرى للقسم ده
> كل حاجة FP في بايثون — lambda, map/filter/reduce, closures, decorators — بترجع لأصل واحد بسيط: **الـ function هي object زي أي object تاني**. لو ركزت الفهم بتاعك على المبدأ ده، أي سؤال جديد تقابله في الموضوع ده هتقدر تستنتج إجابته حتى لو مش فاكره حرفياً.

---

# 🎯 القسم التالت: Advanced / Tricky Interview Questions

## Q36 — إيه الفرق بين `__init__.py` و module عادي؟

### أصل الحكاية
لما عندك مجلد فيه ملفات بايثون وعايز بايثون تتعامل معاه كـ **package** واحد قابل للـ import، بتحط فيه ملف اسمه `__init__.py`.

```python
# project/
#   my_package/
#     __init__.py
#     module_a.py
#     module_b.py

# __init__.py can control what gets exposed when someone does:
# from my_package import *
from .module_a import important_function
__all__ = ["important_function"]
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> من بايثون 3.3+، الملف ده بقى **اختياري تقنياً** (namespace packages)، لكن لسه بيتستخدم جداً في الشغل الحقيقي عشان التحكم في الـ imports وعمل initialization logic للـ package.

---

## Q37 — إيه معنى GIL (Global Interpreter Lock)؟

### أصل الحكاية
سؤال متقدم بيتسأل كتير جداً في الانترفيوهات الأعلى مستوى. بايثون (تحديداً CPython، التطبيق الأشهر) عندها قفل داخلي بيمنع أكتر من thread واحد إنه ينفذ Python bytecode **في نفس اللحظة بالظبط**، حتى لو عندك أكتر من CPU core.

```python
import threading

def cpu_heavy_task():
    total = 0
    for i in range(10**7):
        total += i
    return total

# Even with multiple threads, CPU-bound tasks DON'T speed up
# because the GIL only lets one thread run Python code at a time
threads = [threading.Thread(target=cpu_heavy_task) for _ in range(4)]
```

### الفايدة الانترفيوية
> [!warning] السؤال المتوقع
> *"How would you achieve true parallelism in Python despite the GIL?"* الإجابة: استخدم **`multiprocessing`** بدل `threading` للـ CPU-bound tasks (بيفتح processes منفصلة كل واحدة بالـ interpreter الخاص بيها، فمفيش GIL مشترك). أما للـ I/O-bound tasks (زي network requests)، `threading` أو `asyncio` بيبقوا فعالين جداً لأن الـ GIL بتتفك أثناء انتظار الـ I/O.

---

## Q38 — إيه الفرق بين `deepcopy` وبين إعادة استخدام نفس الـ object في Multithreading؟ (يعني: إيه معنى Thread Safety؟)

### أصل الحكاية
سؤال بيربط كذا مفهوم سابق. لو عندك object mutable (زي list) بيتشارك بين أكتر من thread، ومفيش حماية، ممكن يحصل **race condition**.

```python
import threading

counter = 0
lock = threading.Lock()

def increment():
    global counter
    for _ in range(100000):
        with lock:  # ensures only ONE thread modifies counter at a time
            counter += 1

threads = [threading.Thread(target=increment) for _ in range(2)]
for t in threads:
    t.start()
for t in threads:
    t.join()

print(counter)  # 200000, guaranteed correct BECAUSE of the lock
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> حتى إن `counter += 1` سطر واحد، هو مش **atomic** — بيتحول لعدة خطوات (read, add, write)، وبينهم ممكن thread تاني يتدخل. الـ `Lock` بيضمن إن الخطوات دي متتقطعش. سؤال كلاسيكي في السنيور انترفيوهات.

---

## Q39 — إزاي أعمل Custom Exception؟

### أصل الحكاية
بدل ما ترمي `Exception` عامة، الممارسة الاحترافية إنك تعمل exception classes مخصصة بتوريك بالظبط إيه اللي حصل.

```python
class InsufficientFundsError(Exception):
    """Raised when a withdrawal exceeds the available balance."""
    def __init__(self, balance, amount):
        self.balance = balance
        self.amount = amount
        super().__init__(f"Cannot withdraw {amount}, balance is only {balance}")

class Account:
    def __init__(self, balance):
        self.balance = balance

    def withdraw(self, amount):
        if amount > self.balance:
            raise InsufficientFundsError(self.balance, amount)
        self.balance -= amount

acc = Account(100)
try:
    acc.withdraw(150)
except InsufficientFundsError as e:
    print(e)  # Cannot withdraw 150, balance is only 100
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> Custom exceptions بترث من `Exception` (أو من exception أكتر تحديداً زي `ValueError`)، وبتخلي الكود بتاعك **self-documenting** — أي حد يقرا `except InsufficientFundsError` فاهم بالظبط المشكلة إيه من غير ما يفتح الـ implementation.

---

## Q40 — إيه معنى Context Manager؟ `with` statement بتعمل إيه بالظبط؟

### أصل الحكاية
لو فتحت ملف وماقفلتوش، أو فتحت اتصال database ونسيت تقفله، ده resource leak. بايثون بتحل المشكلة دي بـ `with`، اللي بيضمن الـ cleanup **حتى لو حصل exception**.

```python
class FileManager:
    def __init__(self, filename):
        self.filename = filename

    def __enter__(self):
        # called when entering the 'with' block
        self.file = open(self.filename, 'w')
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        # called when LEAVING the block, even if an exception occurred
        self.file.close()
        print("File closed automatically")
        return False  # False means: don't suppress the exception

with FileManager("test.txt") as f:
    f.write("Hello")
# File is guaranteed to be closed here, no matter what happened above
```

### الفايدة الانترفيوية
> [!tip] Checkpoint
> ده تطبيق تاني على مبدأ RAII شبيه بلغات تانية، لكن بايثون بتعمله بـ `__enter__`/`__exit__`. البديل السريع من `contextlib`:
> ```python
> from contextlib import contextmanager
> 
> @contextmanager
> def file_manager(filename):
>     f = open(filename, 'w')
>     try:
>         yield f
>     finally:
>         f.close()
> ```
> ده بيدمج بين الـ generators (Q32) والـ context managers في أداة واحدة أنيقة.

---

## 🫒 زتونة الإنترفيو (Interview Zaytona) — الجزء الثاني

لو هيسألوك سؤال واحد بس من الملف ده، الأغلب هيبقى واحد من دول:

1. **"Explain closures with a real example."** (Q30) — وخصوصاً فخ الـ loop
2. **"How do decorators work internally?"** (Q31)
3. **"Generators vs lists — when and why?"** (Q32)
4. **"What is the GIL and how do you work around it?"** (Q37)
5. **"Explain `__init__` vs `__new__`, or `super()` and MRO."** (Q21, Q23)

> [!success] الخلاصة الكبرى للملفين مع بعض
> بايثون بنيت على مبدأين بسيطين بيتفرع منهم كل حاجة:
> 1. **كل حاجة object** (functions, classes, حتى الـ modules نفسها)
> 2. **الوضوح أهم من الشياكة** (EAFP, تفضيل `for` loop على `reduce`, PEP 8)
> 
> أي سؤال انترفيو غريب هتقابله، ارجع للمبدأين دول وهتقدر تستنتج الإجابة المنطقية حتى لو مكنتش حافظها حرفياً.

---

**كده خلصنا الـ 40 سؤال الأساسية.** لو عايز نزود جولة تالتة فيها أسئلة أصعب (coding challenges كاملة زي "implement your own decorator that caches results" أو "write a generator-based Fibonacci")، قولي وهنعملها كملف تالت.
