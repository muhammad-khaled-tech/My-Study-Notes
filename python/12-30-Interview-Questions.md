# الفصل صفر-إثنى عشر — ٣٠ سؤال إنترفيو: أساسيات Python و OOP

> **المتطلبات:** كل فصول Phase 0 من [[00-Python-Syntax-And-DataTypes]] لحد [[11-Virtual-Environments-And-PIP]]. الفصل ده هو التتويج — ٣٠ سؤال وإجابة من المستوى المبتدئ للمتوسط في أساسيات Python.

---

## البداية — إزاي تستعد للإنترفيو

الإنترفيو على وظيفة Junior Python Developer بيركز على:
1. **أساسيات اللغة:** المتغيرات، أنواع البيانات، الجمل الشرطية، الحلقات.
2. **هياكل البيانات:** Lists, Tuples, Dictionaries, Sets.
3. **الـ Functions:** تعريفها، parameters، return values، scope.
4. **OOP:** Classes, Objects, Inheritance, Encapsulation.
5. **التعامل مع الملفات والـ Exceptions.**
6. **الـ Modules والـ Virtual Environments.**

الأسئلة اللي تحت دي بتغطي كل ده. كل سؤال متبوع بإجابة مختصرة وواضحة — بالظبط اللي الـ interviewer عايز يسمعه.

---

## الجزء الأول: أساسيات Python (١٠ أسئلة)

### س ١: إيه هي أنواع البيانات الأساسية في Python؟

في Python، أنواع البيانات الأساسية هي:

- **`int`:** أرقام صحيحة. `5`, `-10`, `0`.
- **`float`:** أرقام عشرية. `3.14`, `-0.5`, `2.0`.
- **`str`:** نصوص. `"Hello"`, `'Python'`.
- **`bool`:** قيم منطقية. `True`, `False`.

**نقطة مهمة:** Python هي **dynamically typed** — المتغير مش محتاج تحدد نوعه. النوع بيتحدد تلقائياً من القيمة اللي بتحطها فيه.

---

### س ٢: إيه الفرق بين `list` و `tuple` في Python؟

- **`list`:** **Mutable** (قابلة للتغيير). تقدر تضيف، تشيل، وتعدل العناصر. بتستخدم `[]`. مثال: `[1, 2, 3]`.
- **`tuple`:** **Immutable** (غير قابلة للتغيير). بعد ما تنشئها، متقدرش تغيرها. بتستخدم `()`. مثال: `(1, 2, 3)`.

**الاستخدام:**
- `list`: لما تكون عايز مجموعة بيانات متغيرة (عربة تسوق).
- `tuple`: لما تكون عايز مجموعة بيانات ثابتة (إحداثيات، أيام الأسبوع) أو عايز تستخدمها كـ dictionary key.

---

### س ٣: إزاي بتعمل نسخة من List من غير ما تأثر على الـ List الأصلية؟

في Python، لو عملت `list2 = list1`، المتغيرين هيشاوروا على **نفس الـ object** في الذاكرة. أي تعديل في واحد هيظهر في التاني.

لعمل نسخة **مستقلة**:
- **Shallow Copy:** `list2 = list1.copy()` أو `list2 = list1[:]`. ده بيعمل List جديدة، لكن لو فيها nested lists، الـ nested lists هتفضل مشتركة.
- **Deep Copy:** `import copy; list2 = copy.deepcopy(list1)`. ده بيعمل نسخة مستقلة تماماً — حتى الـ nested objects.

```python
list1 = [[1, 2], [3, 4]]
list2 = list1.copy()
list1[0][0] = 99
print(list2[0][0])  # 99 — affected!

list3 = copy.deepcopy(list1)
list1[0][0] = 100
print(list3[0][0])  # 99 — unaffected!
```

---

### س ٤: إيه الفرق بين `==` و `is` في Python؟

- **`==`:** بتقارن **القيم**. `[1, 2] == [1, 2]` → `True`.
- **`is`:** بتقارن **الهوية** (نفس الـ object في الذاكرة). `[1, 2] is [1, 2]` → `False` (لأنهم objects مختلفة).

**القاعدة الذهبية:** استخدم `is` **فقط** مع `None`, `True`, `False`. استخدم `==` للمقارنات العادية.

---

### س ٥: إيه هي الـ `*args` و `**kwargs`؟ وامتى تستخدمهم؟

- **`*args`:** بيسمح للـ function تستقبل أي عدد من الـ **positional arguments**. بيجمعهم في **tuple**.
- **`**kwargs`:** بيسمح للـ function تستقبل أي عدد من الـ **keyword arguments**. بيجمعهم في **dictionary**.

**الاستخدام:** لما تكون مش عارف كام argument الـ user هيبعت.

```python
def print_all(*args, **kwargs):
    for arg in args:
        print(f"arg: {arg}")
    for key, value in kwargs.items():
        print(f"kwarg: {key} = {value}")

print_all(1, 2, 3, name="Ahmed", age=25)
```

---

### س ٦: إيه الفرق بين `break` و `continue` و `pass`؟

- **`break`:** بتخرج من الـ loop **فوراً**. بتنقل التنفيذ لأول سطر بعد الـ loop.
- **`continue`:** بت skip باقي التكرار **الحالي** وتنتقل للتكرار اللي بعده.
- **`pass`:** بتعمل **ولا حاجة**. مجرد placeholder لما يكون syntax محتاج كود لكن إنت مش عايز تعمل حاجة.

```python
for i in range(5):
    if i == 2:
        continue  # Skip 2
    if i == 4:
        break     # Stop at 4
    print(i)      # Prints: 0, 1, 3
```

---

### س ٧: إزاي بتقرا وتكتب ملفات في Python؟

باستخدام `open()` مع `with` statement (عشان تتقفل تلقائياً):

```python
# قراءة
with open("file.txt", "r", encoding="utf-8") as f:
    content = f.read()
    # أو for line in f: (للملفات الكبيرة)

# كتابة
with open("output.txt", "w", encoding="utf-8") as f:
    f.write("Hello, World!\n")
```

**أوضاع الفتح:**
- `"r"`: قراءة.
- `"w"`: كتابة (بيمسح القديم).
- `"a"`: إضافة في الآخر.
- `"r+"`: قراءة وكتابة.

---

### س ٨: إيه هي الـ `try/except/else/finally`؟ وامتى تستخدمهم؟

- **`try`:** بتحط فيه الكود اللي ممكن يرمي Exception.
- **`except`:** بيتنفذ لو حصل Exception معين. تقدر تمسك أنواع مختلفة.
- **`else`:** بيتنفذ **لو مفيش Exception حصل**.
- **`finally`:** بيتنفذ **دايماً** — سواء حصل Exception أو لأ. مثالي للتنظيف (قفل ملفات، قفل connections).

```python
try:
    num = int(input("Enter a number: "))
    result = 10 / num
except ValueError:
    print("That's not a valid number!")
except ZeroDivisionError:
    print("Cannot divide by zero!")
else:
    print(f"Result: {result}")
finally:
    print("Operation completed.")
```

---

### س ٩: إيه هو الـ List Comprehension؟ وليه هو أسرع من الـ `for` loop العادية؟

**List Comprehension** هي طريقة مختصرة لإنشاء Lists من iterable موجود.

```python
# بدل ما تكتب:
squares = []
for i in range(10):
    squares.append(i ** 2)

# تكتب:
squares = [i ** 2 for i in range(10)]
```

**ليه أسرع؟**
- الـ list comprehension بتنفذ في **C level** جوا Python interpreter. الـ `for` loop بتنفذ في Python level (bytecode).
- الـ overhead بتاع append method calls وتحديث الـ loop variable أقل بكتير.

---

### س ١٠: إيه الفرق بين `global` و `nonlocal`؟

- **`global`:** بتسمحلك **تعدل** متغير global (معرف بره أي function) من جوا function.
- **`nonlocal`:** بتسمحلك **تعدل** متغير في enclosing scope (في nested functions).

```python
x = 10  # Global

def outer():
    y = 20  # Enclosing
    
    def inner():
        global x
        nonlocal y
        x = 100   # Modifies global x
        y = 200   # Modifies enclosing y
    
    inner()
    print(y)  # 200

outer()
print(x)  # 100
```

---

## الجزء الثاني: هياكل البيانات (٥ أسئلة)

### س ١١: إيه الفرق بين `list`, `tuple`, `set`, `dict`؟

| Data Structure | Ordered | Mutable | Duplicates | Access | Use Case |
|---|---|---|---|---|---|
| **List** | نعم | نعم | مسموح | `list[0]` | قائمة مهام، عربة تسوق |
| **Tuple** | نعم | لا | مسموح | `tuple[0]` | إحداثيات، ثوابت |
| **Set** | لا | نعم | ممنوع | `item in set` | عناصر فريدة، عمليات رياضية |
| **Dict** | نعم (3.7+) | نعم | Keys ممنوع | `dict[key]` | دليل تليفونات، JSON |

---

### س ١٢: إزاي تشيل التكرارات من List؟

أسهل طريقة: **حولها لـ Set وبعدين ارجعها لـ List**.

```python
numbers = [1, 2, 2, 3, 3, 3, 4]
unique = list(set(numbers))
print(unique)  # [1, 2, 3, 4] (الترتيب مش مضمون)
```

لو عايز تحافظ على الترتيب:

```python
seen = set()
unique = []
for item in numbers:
    if item not in seen:
        seen.add(item)
        unique.append(item)
# أو باستخدام dict (Python 3.7+):
unique = list(dict.fromkeys(numbers))
```

---

### س ١٣: إزاي تدمج Dictionary مع Dictionary تانية؟

في 3 طرق:

```python
dict1 = {"a": 1, "b": 2}
dict2 = {"b": 3, "c": 4}

# 1. update() — تعدل dict1
dict1.update(dict2)  # dict1 = {"a": 1, "b": 3, "c": 4}

# 2. ** unpacking (Python 3.5+) — ترجع dict جديدة
merged = {**dict1, **dict2}  # القيم المتأخرة بتكتب اللي قبلها

# 3. | operator (Python 3.9+)
merged = dict1 | dict2
```

---

### س ١٤: إيه هي الـ Hash Table؟ وليه الـ Dict سريعة؟

**Hash Table** هي Data Structure بتستخدم **hash function** عشان تحول المفتاح (key) لـ index في array. العملية بتاخد وقت ثابت O(1) في المتوسط.

**ليه الـ Dict سريعة؟**
- الـ Dict في Python مبنية على Hash Table.
- لما تعمل `dict[key]`، Python بتحسب hash(key)، وتستخدمه عشان توصل **مباشرةً** للمكان اللي فيه القيمة.
- مفيش loop على كل العناصر — الوصول فوري.

**الشرط:** المفاتيح لازم تكون **hashable** (Immutable). `int`, `str`, `tuple` ينفعوا. `list` ما ينفعش.

---

### س ١٥: إيه الفرق بين `.append()` و `.extend()` في Lists؟

- **`.append(item)`:** بتضيف **عنصر واحد** في نهاية الـ List. لو مررت List، هتضيف الـ List كعنصر واحد (nested).
- **`.extend(iterable)`:** بتضيف **كل عناصر** الـ iterable في نهاية الـ List. بتفرد العناصر.

```python
lst = [1, 2]
lst.append([3, 4])
print(lst)  # [1, 2, [3, 4]]

lst = [1, 2]
lst.extend([3, 4])
print(lst)  # [1, 2, 3, 4]
```

---

## الجزء الثالث: الـ Functions والـ Scope (٥ أسئلة)

### س ١٦: إيه الفرق بين Parameter و Argument؟

- **Parameter:** المتغير اللي في **تعريف** الـ function. `def greet(name):` — `name` ده parameter.
- **Argument:** القيمة الفعلية اللي بتمررها لما **تنادي** الـ function. `greet("Ahmed")` — `"Ahmed"` ده argument.

---

### س ١٧: إيه هي الـ Default Parameters؟ وإيه المشكلة المحتملة معاها؟

**Default Parameters** هي parameters ليها قيمة افتراضية لو الـ caller مبعتهاش.

```python
def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

greet("Ahmed")        # Hello, Ahmed!
greet("Sara", "Hi")   # Hi, Sara!
```

**المشكلة: Mutable Default Arguments**

```python
def add_item(item, lst=[]):
    lst.append(item)
    return lst

print(add_item(1))  # [1]
print(add_item(2))  # [1, 2] — نفس الـ list!
```

الـ default list بتتعمل **مرة واحدة** وقت تعريف الـ function. كل الـ calls بتشارك نفس الـ list.

**الحل:** استخدم `None`:

```python
def add_item(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst
```

---

### س ١٨: إيه هي الـ Lambda Function؟ وامتى تستخدمها؟

**Lambda** هي function صغيرة **من غير اسم**. بتتكتب في سطر واحد وبتستخدم للعمليات البسيطة.

```python
# Function عادية
def add(x, y):
    return x + y

# Lambda
add = lambda x, y: x + y
```

**الاستخدام:** مع functions زي `map()`, `filter()`, `sorted()`.

```python
numbers = [1, 2, 3, 4]
squared = list(map(lambda x: x ** 2, numbers))
even = list(filter(lambda x: x % 2 == 0, numbers))

students = [{"name": "Ahmed", "grade": 85}, {"name": "Sara", "grade": 92}]
students.sort(key=lambda s: s["grade"])
```

**تحذير:** لو الـ lambda بقت معقدة، اكتب function عادية باسم واضح.

---

### س ١٩: إيه هو الـ Closure في Python؟

**Closure** هو inner function بتتذكر الـ variables من الـ enclosing scope حتى بعد ما الـ outer function تخلص تنفيذها.

```python
def make_multiplier(factor):
    def multiplier(number):
        return number * factor  # factor is "remembered"
    return multiplier

double = make_multiplier(2)
triple = make_multiplier(3)

print(double(5))  # 10
print(triple(5))  # 15
```

`double` و `triple` كل واحدة فيهم closure — بتتذكر قيمة `factor` اللي اتعملت بيها. الـ Decorators في Python مبنية على الـ closures.

---

### س ٢٠: إيه الفرق بين `return` و `yield`؟

- **`return`:** بترجع قيمة و **تنهي** الـ function. الـ state كله بيتنسي.
- **`yield`:** بترجع قيمة و **توقف** الـ function مؤقتاً. الـ state كله بيتحفظ. لما تنادي `next()` تاني، بتكمل من حيث وقفت.

الـ functions اللي فيها `yield` اسمها **Generators**. بتستخدم للـ lazy evaluation — معالجة بيانات كبيرة من غير ما تحملها كلها في الذاكرة.

```python
def count_up_to(n):
    i = 1
    while i <= n:
        yield i
        i += 1

gen = count_up_to(3)
print(next(gen))  # 1
print(next(gen))  # 2
print(next(gen))  # 3
```

---

## الجزء الرابع: OOP (٥ أسئلة)

### س ٢١: إيه هو الـ Class والـ Object؟ إيه الفرق بينهم؟

- **Class:** هو "القالب" أو "المخطط". بيوصف الـ attributes والـ methods اللي الـ objects هيكون عندها. `class Car:`.
- **Object (Instance):** هو "نسخة" من الـ class. `my_car = Car()`.

**التشبيه:** Class هو المخطط الهندسي للعربية. Object هو العربية الفعلية اللي طالعة من خط الإنتاج.

---

### س ٢٢: إيه هو `self`؟ وليه لازم تحطه في الـ methods؟

**`self`** هو reference للـ **instance الحالية**. لما تعمل `obj.method()`، Python بتمرر `obj` كـ أول argument تلقائياً — وده اللي بنسميه `self`.

```python
class Student:
    def __init__(self, name):
        self.name = name  # self.name هو attribute بتاع الـ instance
    
    def greet(self):
        print(f"Hello, I'm {self.name}")

student = Student("Ahmed")
student.greet()  # Python بتحولها لـ: Student.greet(student)
```

`self` مش keyword — تقدر تسميه أي حاجة، لكن `self` هو الـ convention.

---

### س ٢٣: إيه هو الـ Inheritance؟ وليه بنستخدمه؟

**Inheritance (الوراثة)** هي آلية بتسمح لـ Class (Child) إنه **يرث** attributes و methods من Class تاني (Parent).

```python
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        pass

class Dog(Animal):
    def speak(self):
        return f"{self.name} says Woof!"

dog = Dog("Rex")
print(dog.speak())  # Rex says Woof!
```

**ليه بنستخدمه؟**
- **DRY:** الكود المشترك بيتكتب مرة واحدة في الـ Parent.
- **Extensibility:** تقدر تبني على الـ Parent من غير ما تلمسه.
- **Polymorphism:** تقدر تتعامل مع objects من أنواع مختلفة بنفس الطريقة.

---

### س ٢٤: إيه الفرق بين Instance Method و Class Method و Static Method؟

- **Instance Method:** أول parameter `self`. بتشتغل على instance. `def method(self):`.
- **Class Method:** أول parameter `cls`. بتشتغل على الـ class نفسه. `@classmethod def method(cls):`.
- **Static Method:** مفيش `self` ولا `cls`. Function عادية في الـ class namespace. `@staticmethod def method():`.

```python
class Example:
    class_var = 0
    
    def instance_method(self):
        return "instance"
    
    @classmethod
    def class_method(cls):
        cls.class_var += 1
        return cls.class_var
    
    @staticmethod
    def static_method():
        return "static"
```

**الاستخدامات:**
- Instance Method: أغلب الوقت.
- Class Method: Alternative constructors (`from_string()`), factory methods.
- Static Method: Utility functions ليها علاقة بالـ class.

---

### س ٢٥: إيه هو `@property`؟ وليه بنستخدمه؟

**`@property`** بيخلي method تتصرف كأنها attribute. بيديك control على الوصول للـ attributes (getter, setter) من غير ما تغير الـ API.

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius
    
    @property
    def radius(self):
        return self._radius
    
    @radius.setter
    def radius(self, value):
        if value <= 0:
            raise ValueError("Radius must be positive")
        self._radius = value
    
    @property
    def area(self):
        return 3.14159 * self._radius ** 2

c = Circle(5)
print(c.radius)  # 5 — like an attribute
print(c.area)    # 78.53975 — computed property
c.radius = 10    # Uses setter with validation
```

**ليه بنستخدمه؟**
- **Encapsulation:** تقدر تخبي implementation details.
- **Validation:** تقدر تتحقق من القيم قبل ما تتخزن.
- **Backward Compatibility:** لو بدأت بـ public attribute وعايز تضيف validation بعدين.

---

## الجزء الخامس: Modules و Virtual Environments (٥ أسئلة)

### س ٢٦: إيه هو الـ Module؟ وإزاي بتستورده؟

**Module** هو ملف Python (`.py`) بيحتوي على functions, classes, variables.

**طرق الـ import:**
```python
import math                 # Import module
print(math.pi)

from math import pi, sqrt   # Import specific items
print(pi)

from math import *          # Import everything (not recommended)
import numpy as np          # Import with alias
```

---

### س ٢٧: إيه هو `__name__ == "__main__"`؟ وليه بنستخدمه؟

لما تشغل ملف Python مباشرةً (`python file.py`)، المتغير `__name__` بيبقى `"__main__"`. لو الملف اتستورد كـ module (`import file`)، `__name__` بيبقى اسم الملف (`"file"`).

```python
def main():
    print("Running...")

if __name__ == "__main__":
    main()  # Runs only when executed directly
```

**الاستخدام:** تحط كود اختبار أو كود تشغيل في `if __name__ == "__main__":` عشان يتنفذ بس لما الملف يتشغل مباشرةً — مش لما يتستورد.

---

### س ٢٨: إيه هو الـ Virtual Environment؟ وليه هو مهم؟

**Virtual Environment (`venv`)** هي بيئة Python معزولة لمشروع معين. بتحتوي على نسخة من Python و pip خاصة بالمشروع.

**ليه مهم؟**
- **عزل:** كل مشروع ليه مكتباته وإصداراته الخاصة. مفيش تضارب بين المشاريع.
- **نظافة:** مكتبات المشروع مش بتتلخبط مع مكتبات النظام.
- **Portability:** تقدر تشارك المشروع وأي حد يعمل venv ويثبت نفس المكتبات.

**الأوامر الأساسية:**
```bash
python -m venv myenv      # Create
source myenv/bin/activate # Activate (Mac/Linux)
myenv\Scripts\activate    # Activate (Windows)
deactivate                # Deactivate
```

---

### س ٢٩: إزاي تثبت مكتبة خارجية؟ وإزاي تشارك المكتبات مع فريقك؟

**تثبيت مكتبة:**
```bash
pip install requests
pip install requests==2.31.0  # Version spécifique
```

**مشاركة المكتبات مع الفريق:**
1. اعمل `requirements.txt`:
```bash
pip freeze > requirements.txt
```

2. حط `requirements.txt` في Git.

3. أي حد ياخد المشروع يعمل:
```bash
pip install -r requirements.txt
```

**نقطة مهمة:** الـ `venv` folder نفسه **مش بيتحط في Git**. حطه في `.gitignore`.

---

### س ٣٠: إيه هي `pip freeze`؟ وإيه الفرق بينها وبين `pip list`؟

- **`pip list`:** بيعرض **كل** المكتبات المثبتة في البيئة الحالية. الصيغة: `Package    Version`.
- **`pip freeze`:** بيعرض المكتبات المثبتة **بصيغة `requirements.txt`**. الصيغة: `Package==Version`.

```bash
$ pip list
Package    Version
---------- -------
pip        24.0
requests   2.31.0

$ pip freeze
requests==2.31.0
```

`pip freeze` مش بتعرض `pip` نفسه ولا المكتبات اللي متثبتة بـ `setuptools`. الصيغة بتاعتها جاهزة للـ `pip install -r`.

---

## 📝 خلاصة الرحلة

دي كانت رحلة Phase 0 كاملة — من أول متغير في Python لحد ما تنظم مشروع كامل بـ OOP و Modules و Virtual Environment.

**إيه اللي اتعلمناه؟**
- **أساسيات Python:** Variables, Data Types, Control Flow, Loops.
- **هياكل البيانات:** Lists, Tuples, Dictionaries, Sets.
- **الـ Functions:** Parameters, Return, Scope, Lambda, Generators.
- **OOP:** Classes, Objects, Inheritance, Properties, Special Methods.
- **تنظيم الكود:** Modules, Packages, Virtual Environments, pip.

الـ ٣٠ سؤال إنترفيو دول هما تتويج الرحلة. مش مجرد إجابات — هم proof إنك فاهم الأساسيات كويس.

**الخطوة الجاية:** ابدأ في الـ 18 فايل المتقدمة (Phase 1: Python Architecture) — الـ GIL، الـ Memory Model، الـ Decorators، والـ Advanced OOP. الأساس اللي بنيته في Phase 0 هيخلي الرحلة المتقدمة سلسة وممتعة.

بالتوفيق يا هندسة! 🚀