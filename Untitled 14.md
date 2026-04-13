# الفصل الثامن عشر — ٥٠ سؤال إنترفيو: من Fresh لـ Mid-Level

> **المتطلبات:** كل الفصول السابقة. الفصل ده هو التتويج — ٥٠ سؤال وإجابة Senior-Level في Python, Django, DRF, و System Design. الأسئلة اللي هتقابلك في أي إنترفيو Backend.

---

## البداية — إزاي تستعد للإنترفيو

الإنترفيو مش امتحان — هو محادثة. الـ interviewer مش عايزك تحفظ إجابات. عايزك تثبت إنك فاهم **إزاي** الحاجة بتشتغل، مش بس **إنها** بتشتغل. الإجابات اللي هنا مركزة على "الـ Why" و "الـ How" — بالظبط زي ما اتعلمنا في الرحلة كلها.

الأسئلة متقسمة ٤ أقسام:
1. **Python Fundamentals (١٠ أسئلة):** Memory, GIL, OOP, Functional, Decorators, Generators.
2. **Django Core (١٥ سؤالاً):** MVT, ORM, Migrations, Middleware, Signals, Auth, Caching.
3. **DRF & APIs (١٥ سؤالاً):** Serializers, ViewSets, JWT, Permissions, Throttling, Filtering.
4. **System Design & Best Practices (١٠ أسئلة):** Architecture, Scaling, Security, Performance.

كل سؤال متبوع بإجابة Senior-Level — مركزة، تقنية، وبتوضح الفهم العميق.

---

## الجزء الأول: Python Fundamentals (١٠ أسئلة)

### س ١: إيه هو الـ GIL في Python؟ وليه موجود؟ وإيه تأثيره على الـ Multi-threading؟

الـ GIL (Global Interpreter Lock) هو Mutex بيضمن إن Thread واحدة بس بتنفذ Python bytecode في أي لحظة في الـ CPython interpreter.

**ليه موجود؟**
CPython بتستخدم **Reference Counting** لإدارة الـ memory. كل object عنده عداد `ob_refcnt`. لو threads كتير عدلت الـ refcount في نفس الوقت، هيحصل race condition والـ memory هتفسد. الـ GIL هو الحل الأبسط — بيخلي كل عملية تعديل على الـ refcount atomic من غير locks معقدة.

**تأثيره على الـ Multi-threading:**
- **CPU-bound tasks:** الـ threads مش بتشتغل بالتوازي فعلياً. لو عندك 4 cores، الـ Python code هيشتغل على core واحد بس في أي لحظة. الأداء ممكن يبقى أسوأ من single-thread بسبب overhead الـ context switching.
- **I/O-bound tasks:** الـ GIL بيتحرر أثناء الـ I/O operations (network, file, sleep). الـ threads بتقدر تشتغل concurrently بكفاءة. Django و DRF بيستفيدوا من ده — معظم الـ requests I/O-bound (database queries, external APIs).

**الحلول:**
- **I/O-bound:** `threading` أو `asyncio` (الـ GIL بيتحرر).
- **CPU-bound:** `multiprocessing` (كل process ليه GIL مستقل وبيشتغل على core منفصل).
- **بدائل:** Jython أو IronPython (معندهمش GIL)، أو كتابة الـ CPU-intensive parts بـ C extension.

---

### س ٢: إيه الفرق بين `is` و `==` في Python؟ وامتى تستخدم كل واحد؟

`==` بتقارن **القيمة** (value equality). بتنادي `__eq__` method.
`is` بتقارن **الهوية** (identity equality). بتتأكد إن الاتنين نفس الـ object في الـ memory (نفس `id()`).

**القاعدة الذهبية:** استخدم `is` **فقط** مع singletons — `None`, `True`, `False`. لأنهم objects ثابتة في الـ memory (نسخة واحدة في الـ interpreter كله).

**المشكلة: Python Interning**
Python بتعمل caching للأعداد الصغيرة (-5 لـ 256) وبعض الـ strings القصيرة. ده ممكن يخلي `is` يرجع `True` بالصدفة:
```python
a = 256
b = 256
print(a is b)  # True (cached)

a = 257
b = 257
print(a is b)  # False (not cached)
```
السلوك ده implementation-specific ومش مضمون. استخدم `==` للمقارنة دايمًا — `is` بس لـ `None`.

---

### س ٣: إيه الفرق بين `__new__` و `__init__` في Python؟ وامتى تحتاج تـ override `__new__`؟

`__new__` هو الـ **constructor الحقيقي**. بيخلق الـ object في الـ memory ويرجعه.
`__init__` هو الـ **initializer**. بياخد الـ object اللي `__new__` خلقه ويملّيه بالبيانات.

**الترتيب:**
1. `__new__(cls, ...)` بتنادي — بترجع instance جديدة (غالباً `super().__new__(cls)`).
2. `__init__(self, ...)` بتنادي على الـ instance اللي رجعت — بتحط الـ initial state.

**امتى تحتاج تـ override `__new__`؟**
- **Singleton Pattern:** تضمن إن الـ class ليه instance واحدة بس.
- **Immutable Types Inheritance:** لو وارث من `str`, `int`, `tuple`. الـ `__init__` مش بتتنادى لأن الـ object immutable. لازم تعدل في `__new__`.
- **Metaclasses:** `__new__` في metaclass بتتحكم في إنشاء الـ class نفسه.

---

### س ٤: إيه هو الـ Decorator في Python؟ وإزاي بيشتغل من الداخل؟

الـ Decorator هو **Higher-Order Function** — بتاخد function وترجع function جديدة (أو callable). الـ `@` syntax ده مجرد syntactic sugar.

**إزاي بيشتغل:**
```python
@my_decorator
def my_func():
    pass

# Equivalent to:
my_func = my_decorator(my_func)
```

**التركيب الداخلي:**
```python
def my_decorator(func):
    @functools.wraps(func)  # Preserve metadata
    def wrapper(*args, **kwargs):
        # Pre-processing
        result = func(*args, **kwargs)
        # Post-processing
        return result
    return wrapper
```

**ليه `@wraps` ضروري؟**
بدونه، `wrapper` بتاخد اسم الـ original function. `my_func.__name__` هتبقى `'wrapper'`. ده بيبوظ الـ debugging والـ introspection (زي Django's URL resolver). `@wraps` بتنسخ الـ metadata (`__name__`, `__doc__`, `__module__`).

**Decorators بوسيطة (Factory Pattern):**
```python
def repeat(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(3)
def greet():
    print("Hello")
```
الطبقة الخارجية (`repeat`) بتاخد الـ argument وترجع الـ decorator الحقيقي.

---

### س ٥: إيه الفرق بين `@classmethod`, `@staticmethod`, و instance method؟ وامتى تستخدم كل واحد؟

الفرق في **أول argument** بيتم تمريره تلقائياً:

- **Instance Method:** `self` — الـ instance نفسها. بتقدر توصل لـ `self` والـ class attributes.
- **`@classmethod`:** `cls` — الـ class نفسها. بتقدر توصل لـ class attributes و alternative constructors.
- **`@staticmethod`:** مفيش لا `self` ولا `cls`. هي function عادية بس في الـ class namespace.

**امتى تستخدم إيه؟**
- **Instance Method:** دايمًا — لو بتتعامل مع instance data.
- **`@classmethod`:** Alternative constructors (`User.from_dict()`), Factory methods, أو لو محتاج توصل لـ class-level data.
- **`@staticmethod`:** Utility functions ليها علاقة بالـ class لكن مش محتاجة state (زي `Job.is_valid_budget()`). قليلة الاستخدام — غالباً `@classmethod` أنسب.

---

### س ٦: إيه هو الـ Generator في Python؟ وإيه فايدته مع الـ large datasets؟

الـ Generator هو function بتحتوي على `yield` بدل `return`. لما بتناديها، بترجع **Generator Object** (iterator) مش قيمة عادية.

**إزاي بيشتغل:**
- أول `next()`: بتنفذ الكود لحد أول `yield`، ترجع القيمة، وتوقف (pause).
- تاني `next()`: بتكمل من بعد الـ `yield` لحد الـ `yield` اللي بعده.
- لما توصل للنهاية: `StopIteration`.

**الفايدة مع الـ large datasets:**
- **Lazy Evaluation:** مش بتحمل كل البيانات في الـ memory مرة واحدة. بتولد element element.
- **Memory Efficient:** `range(1000000)` بياخد bytes قليلة. `list(range(1000000))` بياخد ~8MB.
- **Infinite Sequences:** تقدر تمثل infinite streams (زي sensor data).

**مثال عملي:**
```python
def read_large_file(file_path):
    with open(file_path) as f:
        for line in f:
            yield line.strip()

# 1 TB file — memory usage remains constant
for line in read_large_file("huge.log"):
    process(line)
```

---

### س ٧: إيه هي الـ Context Managers في Python؟ وإزاي `with` بتشتغل؟

الـ Context Manager هو object بيعمل implement لـ `__enter__` و `__exit__`. بيضمن إن الـ resources (files, locks, DB connections) تتقفل حتى لو حصل exception.

**إزاي `with` بتشتغل:**
1. `with obj as var:` → `var = obj.__enter__()`
2. الـ block بيتنفذ.
3. **مهما حصل** (حتى مع exception): `obj.__exit__(exc_type, exc_val, exc_tb)` بتنادي.

**الـ `__exit__` method:**
- لو الـ block خلص بنجاح: `exc_type = exc_val = exc_tb = None`.
- لو حصل exception: بتحتوي على تفاصيل الخطأ. لو `__exit__` رجعت `True`، الـ exception بيتم كتمه.

**طريقة أسهل: `@contextmanager`**
```python
from contextlib import contextmanager

@contextmanager
def managed_resource(*args):
    resource = acquire_resource(*args)  # __enter__
    try:
        yield resource  # Pass to 'as' block
    finally:
        release_resource(resource)  # __exit__ (always runs)
```

**استخدامات شائعة:**
- `with open('file.txt') as f:` (files)
- `with transaction.atomic():` (Django DB transactions)
- `with lock:` (threading locks)

---

### س ٨: إيه الفرق بين `deepcopy` و `shallow copy` في Python؟

- **Shallow Copy:** بتعمل object جديد، لكن الـ nested objects بتبقى **references** للـ objects الأصلية. بتستخدم `copy.copy()` أو `list[:]`.
- **Deep Copy:** بتعمل object جديد و **كل** الـ nested objects بتتعملهم copy recursively. بتستخدم `copy.deepcopy()`.

**المشكلة:**
```python
import copy

original = [[1, 2], [3, 4]]
shallow = copy.copy(original)
deep = copy.deepcopy(original)

original[0][0] = 99
print(shallow[0][0])  # 99 — affected!
print(deep[0][0])     # 1 — independent
```

**امتى تستخدم إيه؟**
- **Shallow:** أسرع. كافي لو الـ objects مش nested أو مش هتعدل الـ nested parts.
- **Deep:** أبطأ. ضروري لو عايز نسخة مستقلة تماماً (زي undo/redo systems).

---

### س ٩: إيه هو الـ Garbage Collection في Python؟ وإزاي بيختلف عن Reference Counting؟

Python بتستخدم **آليتين** لإدارة الـ memory:

**1. Reference Counting (الأساسي):**
- كل object عنده عداد `ob_refcnt`.
- لما العداد يوصل 0، الـ object بيتحذف **فوراً**.
- سريع وحتمي (deterministic).
- **المشكلة:** Cyclic References — objects بتشاور على بعض (A → B, B → A). العداد مش بيوصل 0.

**2. Garbage Collector (للـ cycles):**
- بيفحص الـ objects بشكل دوري.
- بيدور على cycles غير قابلة للوصول (unreachable).
- بيستخدم **Generational Hypothesis**: معظم الـ objects بتموت بسرعة. الـ GC بيقسم الـ objects لـ 3 generations. Gen 0 بتتفحص كتير، Gen 2 نادر.
- لو لقى cycle مش accessible من البرنامج، بيحذفها.

**التحكم في الـ GC:**
- `gc.collect()` — تشغيل GC يدوي.
- `gc.disable()` — إيقاف GC (لتحسين الأداء في تطبيقات معينة).
- `gc.set_threshold()` — تغيير thresholds الـ generations.

---

### س ١٠: إيه هي الـ Mutable Default Arguments في Python؟ وليه بتسبب مشاكل؟

لما بتحط mutable object (list, dict) كـ default argument، Python **بتخلقه مرة واحدة** وقت تعريف الـ function — مش كل ما الـ function بتنادي.

**المشكلة:**
```python
def append_to_list(item, my_list=[]):
    my_list.append(item)
    return my_list

print(append_to_list(1))  # [1]
print(append_to_list(2))  # [1, 2] — same list!
```

كل الـ calls بتشارك نفس الـ list object في الـ memory.

**الحل:**
```python
def append_to_list(item, my_list=None):
    if my_list is None:
        my_list = []
    my_list.append(item)
    return my_list
```
`None` immutable — مضمون إنه نفس الـ object كل مرة. بنعمل list جديدة جوا الـ function.

---

## الجزء الثاني: Django Core (١٥ سؤالاً)

### س ١١: اشرحلي رحلة الـ Request في Django من أول ما يوصل للسيرفر لحد ما يرجع Response.

1. **WSGI Server (Gunicorn/uWSGI):** بيستقبل HTTP request. بيحوله لـ Python `environ` dict.
2. **Django WSGI Handler:** `WSGIHandler` بياخد `environ` ويعمل `HttpRequest` object.
3. **Middleware Stack (Pre-Request):** الـ request بتمر على كل middleware في `MIDDLEWARE` list (بالترتيب). كل middleware يقدر يعدل الـ request أو يرجع response فوراً (يمنع التكملة).
4. **URL Dispatcher:** Django بتبص في `ROOT_URLCONF` وتدور على pattern يطابق `request.path`. أول match بينادي الـ view.
5. **View Execution:** الـ view (FBV أو CBV) بتتنفذ. بتتعامل مع الـ ORM، تجهز context، وترجع `HttpResponse`.
6. **Middleware Stack (Post-Response):** الـ response بتمر على **نفس** الـ middleware stack لكن **بالعكس** (من تحت لفوق). كل middleware يقدر يعدل الـ response.
7. **WSGI Handler (Output):** الـ `HttpResponse` بيتحول لـ HTTP response فعلي ويتبعت للـ client.

**نقطة مهمة:** الـ Middleware بتنفذ في **مرحلتين**. `process_request` من فوق لتحت. `process_response` من تحت لفوق. ده اسمه **Onion Model**.

---

### س ١٢: إيه الفرق بين MVT (Django) و MVC (Laravel/Rails)؟

في **MVC**:
- **Model:** البيانات والـ business logic.
- **View:** الـ presentation (HTML/CSS).
- **Controller:** الوسيط — بياخد request، يتعامل مع Model، يبعت data للـ View.

في **MVT (Django)**:
- **Model:** نفس الحاجة.
- **View:** ده الـ Controller! بياخد request، يتعامل مع Model، يبعت context للـ Template.
- **Template:** ده الـ View! مسؤول عن العرض فقط.

**الفرق العملي:** في Django، الـ Template مش بيقدر يوصل للـ Model مباشرةً (زي Blade في Laravel). الـ View لازم تجهز كل البيانات الأول. ده بيفرض **فصل أقوى** بين المنطق والعرض. Django بتسميه "View" لأنه "بيشوف" الـ request ويقرر الـ response.

---

### س ١٣: إيه هو الـ QuerySet في Django؟ وليه هو Lazy؟

الـ QuerySet هو object بيمثل **استعلام** عن الـ database — مش نتيجة الاستعلام. هو "وعد" بالبيانات.

**الـ Laziness:**
الـ QuerySet مش بينفذ الـ SQL query غير لما **تضطر** تلمس البيانات:
- **Iteration:** `for job in jobs:`
- **Slicing with step:** `jobs[0]` (single index)
- **`len(jobs)`, `list(jobs)`, `bool(jobs)`**
- **`.first()`, `.last()`, `.count()`, `.exists()`**

**ليه ده مهم؟**
تقدر تبني queries معقدة تدريجياً من غير ما تضغط على الـ database:
```python
qs = Job.objects.filter(status='open')  # No DB hit
qs = qs.exclude(budget__lt=1000)       # No DB hit
qs = qs.order_by('-created_at')        # No DB hit
jobs = list(qs)  # 💥 Single DB hit with optimized SQL
```

---

### س ١٤: إيه هو الـ N+1 Query Problem؟ وإزاي `select_related` و `prefetch_related` بيحلوه؟

**المشكلة:**
```python
jobs = Job.objects.all()  # Query 1: SELECT * FROM jobs (N rows)
for job in jobs:
    print(job.client.name)  # Query 2, 3, 4... (N queries) — SELECT * FROM clients WHERE id = job.client_id
```
لو عندك 100 job، ده 101 query. كارثة أداء.

**الحلول:**
- **`select_related()`:** للـ ForeignKey و OneToOne. بيعمل **SQL JOIN** — query واحدة بترجع كل حاجة. مثال: `Job.objects.select_related('client')`.
- **`prefetch_related()`:** للـ ManyToMany و Reverse ForeignKey. بيعمل **استعلامين منفصلين** ويربطهم في Python. مثال: `Job.objects.prefetch_related('skills')`.

**الفرق الجوهري:** `select_related` = JOIN في SQL (query واحدة). `prefetch_related` = استعلامين + ربط في Python.

---

### س ١٥: إيه الفرق بين `Q` objects و `F` objects في Django ORM؟

- **`Q` objects:** للـ **Complex Lookups** (OR, NOT, AND معقد). بتبني شجرة منطقية: `Q(budget__gt=5000) | Q(is_urgent=True)`.
- **`F` objects:** للـ **عمليات على مستوى الـ Database**. تقارن عمودين (`budget__gt=F('min_budget')`) أو تعمل atomic update (`Job.objects.update(views_count=F('views_count')+1)`).

**الفرق الجوهري:**
- `Q` = WHERE clause (منطق البحث).
- `F` = العمليات الحسابية والمقارنات بين الأعمدة (في WHERE أو SET clause).

الاتنين بيخلوا العمليات تحصل جوا الـ database (أسرع وأأمن — مفيش race conditions).

---

### س ١٦: إزاي Django بتعمل Migrations؟ وايه اللي بيحصل جوا `makemigrations` و `migrate`؟

**`makemigrations`:**
1. Django بتقارن بين **حالتين**: (1) الـ Models الحالية في `models.py`. (2) آخر حالة للـ Schema الـ Django عارفة إنها اتطبقت (من ملفات migration وجدول `django_migrations`).
2. الفرق بيتحول لـ **Migration File** — Python file فيه `operations` (زي `CreateModel`, `AddField`).
3. الملف ده بيوصف إزاي ننتقل من الحالة القديمة للجديدة.

**`migrate`:**
1. Django بتقرا الـ migration files اللي لسه متطبقتش (من `django_migrations` table).
2. بتبني **Dependency Graph** بين الـ migrations (Topological Sort).
3. بتنفذ الـ `operations` بالترتيب.
4. تسجل كل migration في `django_migrations` table.

**نقطة مهمة:** الـ Dependency Graph ده اللي بيسمح لـ apps مختلفة يكون عندهم migrations مستقلة.

---

### س ١٧: إيه هو الـ Middleware في Django؟ وإزاي بيشتغل (Onion Model)؟

الـ Middleware هو **Hook** بيسمحلك تعترض وتعالج الـ request قبل ما توصل للـ view، والـ response قبل ما يرجع للـ client.

**الـ Onion Model:**
- **Request Phase:** الـ middleware في `MIDDLEWARE` list بتنفذ بالترتيب (من فوق لتحت). كل واحد بياخد الـ request ويعمل عليه شغل.
- **Response Phase:** الـ response بتمر على **نفس** الـ middleware لكن **بالعكس** (من تحت لفوق).

**الترتيب مهم جداً:**
- `SessionMiddleware` لازم يكون قبل `AuthenticationMiddleware`.
- `AuthenticationMiddleware` لازم قبل `CsrfViewMiddleware`.
- `GZipMiddleware` لازم يكون آخر واحد (عشان يضغط الـ response بعد كل التعديلات).

**استخدامات شائعة:** Authentication, Session management, CSRF protection, Security headers, Request logging, Rate limiting.

---

### س ١٨: إزاي تبني Custom Middleware في Django؟

**الطريقة الحديثة (Function-based — Django 3.1+):**
```python
def custom_middleware(get_response):
    # One-time configuration (runs once at server start)
    
    def middleware(request):
        # Pre-processing (before view)
        response = get_response(request)  # Call next middleware/view
        # Post-processing (after view)
        return response
    
    return middleware
```

**الطريقة الكلاسيكية (Class-based):**
```python
class CustomMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Pre-processing
        response = self.get_response(request)
        # Post-processing
        return response
```

**التسجيل في `settings.py`:**
```python
MIDDLEWARE = [
    'myapp.middleware.CustomMiddleware',
    # ...
]
```

---

### س ١٩: إيه هي الـ Signals في Django؟ وامتى تستخدمها وامتى تتجنبها؟

الـ Signals هي تطبيق لـ **Observer Pattern**. Sender بيبعت إشارة، Receivers بيستمعوا ويتنفذوا.

**استخدامات جيدة:**
- **Decoupling Apps:** `post_save` على `User` في `accounts` app ينشئ `UserProfile` في `profiles` app.
- **Side Effects:** إرسال Welcome email بعد التسجيل، Logging, Analytics.
- **Cache Invalidation:** مسح cache بعد تغيير Model.

**تجنب Signals لما:**
- **الـ Logic جزء أساسي من الـ Model:** Override `save()` بدل Signal.
- **الـ Receiver بطيء (Email, API call):** استخدم Celery.
- **Validation:** الـ Signals مش مكانها. استخدم `clean()` أو `save()`.

**تحذيرات:**
- الـ Signals **Synchronous**. `save()` مش هترجع غير لما كل receivers يخلصوا.
- الـ Signals مش بتشتغل في `QuerySet.update()` أو `bulk_create()`.

---

### س ٢٠: إيه الفرق بين `AbstractUser` و `AbstractBaseUser`؟ وامتى تستخدم كل واحد؟

- **`AbstractUser`:** Extension للـ `User` الافتراضي. Django عملتلك كل الـ fields (`username`, `email`, `is_staff`). إنت بتضيف الحقول اللي عايزها. استخدمه في ٩٠٪ من المشاريع.
- **`AbstractBaseUser`:** القالب الفارغ. بيديك `password` و `last_login` بس. إنت بتكتب كل حاجة. استخدمه لو عايز login بـ `email` (من غير `username` خالص) أو تحكم كامل.

**القاعدة الذهبية:** ابدأ بـ Custom User Model من أول يوم (`AUTH_USER_MODEL = 'accounts.User'`). تغييره بعدين كابوس.

---

### س ٢١: إزاي بتعمل Custom Authentication Backend في Django؟

بتعمل class بيعمل implement لـ `authenticate()` و (اختياري) `get_user()`:

```python
from django.contrib.auth.backends import BaseBackend

class EmailBackend(BaseBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = User.objects.get(email=username)
        except User.DoesNotExist:
            return None
        
        if user.check_password(password):
            return user
        return None
    
    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None
```

**التسجيل:**
```python
AUTHENTICATION_BACKENDS = [
    'myapp.backends.EmailBackend',
    'django.contrib.auth.backends.ModelBackend',  # Fallback
]
```

**الترتيب مهم:** Django بتمر على الـ backends بالترتيب. أول واحد يرجع `User` (مش `None`) بينجح.

---

### س ٢٢: إيه الفرق بين Session Authentication و Token Authentication (JWT)؟

- **Session (Stateful):** الـ server بيخزن Session ID في database/cache. الـ client بيحتفظ بـ Cookie. Logout سهل (تمسح الـ session). Scaling أصعب (محتاج shared session storage). مناسب للمواقع التقليدية.
- **JWT (Stateless):** الـ server بيوقع Token ويديه للـ client. الـ client يبعت `Authorization: Bearer <token>`. الـ server بيفحص الـ signature (من غير database hit). Scaling سهل (أي server عنده الـ secret key). Logout محتاج Blacklist. مناسب للـ APIs و Mobile Apps.

**في DRF:** JWT (مع `simplejwt`) هو المعيار الحديث للـ APIs.

---

### س ٢٣: إيه هو الـ Caching في Django؟ وإزاي تطبقه؟

الـ Caching بيخزن نتايج العمليات المكلفة (DB queries, rendered templates) في memory (Redis/Memcached) عشان متتكررش.

**الأنواع:**
- **Per-Site Cache:** `UpdateCacheMiddleware` و `FetchFromCacheMiddleware` — بيخزن الـ site كله.
- **Per-View Cache:** `@cache_page(60 * 15)` — بيخزن response view معينة.
- **Template Fragment Cache:** `{% cache 500 sidebar %}` — بيخزن جزء من template.
- **Low-Level Cache API:** `cache.set('key', value, timeout)` — تحكم يدوي.

**الإعداد:**
```python
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

**Cache Invalidation:** أصعب جزء. استخدم `cache.delete(key)` أو `cache.clear()` بحذر.

---

### س ٢٤: إزاي بتتعامل مع File Uploads في Django؟

1. **في الـ Model:** `models.FileField(upload_to='uploads/%Y/%m/')` أو `models.ImageField()`.
2. **في الـ Form/Serializer:** `request.FILES` (Django) أو `request.data` (DRF — MultiPartParser).
3. **في الـ Settings:**
   - `MEDIA_URL = '/media/'`
   - `MEDIA_ROOT = BASE_DIR / 'media'`
4. **في الـ Development:** أضف `static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)` لـ `urlpatterns`.
5. **في الـ Production:** الـ web server (Nginx) هو اللي يخدم الـ media files — Django متخدمش static/media في production.

**Storage Backends:** `FileSystemStorage` (الافتراضي) أو `S3Boto3Storage` (لـ AWS S3). استخدم `django-storages`.

---

### س ٢٥: إيه هي أفضل practices لتنظيم Django Project؟

1. **Split Settings:** `settings/base.py`, `development.py`, `production.py`.
2. **Custom User Model:** من أول يوم (`AUTH_USER_MODEL = 'accounts.User'`).
3. **Environment Variables:** `python-decouple` + `.env` file. الأسرار مش في Git.
4. **`core` App:** للحاجات المشتركة — `BaseModel`, `TimestampMixin`, `UUIDMixin`.
5. **Apps منظمة:** كل app ليه `models.py`, `views.py`, `serializers.py`, `urls.py` خاصة بيه.
6. **API Versioning:** `/api/v1/` من الأول.
7. **`select_related` / `prefetch_related`:** دايمًا في الـ querysets.
8. **Indexes:** `db_index=True` و `class Meta: indexes = [...]`.
9. **Logging:** `LOGGING` dict في `settings.py`.
10. **Testing:** `pytest-django` و factories (`factory_boy`).

---

## الجزء الثالث: DRF & APIs (١٥ سؤالاً)

### س ٢٦: إيه الفرق بين `APIView` و `ViewSet` في DRF؟ وامتى تستخدم كل واحد؟

- **`APIView`:** تحكم كامل. بتكتب `get()`, `post()` يدوياً. مناسب للـ endpoints المعقدة أو غير القياسية (dashboard, search).
- **`ViewSet`:** بيجمع actions (`list`, `create`, `retrieve`) في class واحد. `ModelViewSet` بيدي CRUD كامل جاهز. مناسب لـ ٩٠٪ من الـ resources.

**القاعدة:** ابدأ بـ `ModelViewSet` + `Router`. لو الـ endpoint مش CRUD أو معقد، استخدم `APIView` أو `@action` decorator.

---

### س ٢٧: إيه الفرق بين `Serializer` و `ModelSerializer`؟

- **`Serializer`:** بتعرف كل field يدوياً. بتكتب `create()` و `update()` بنفسك. تحكم كامل.
- **`ModelSerializer`:** بيولد الـ fields تلقائياً من الـ Model. `create()` و `update()` جاهزين. أسرع وأقل كود.

**امتى تستخدم `Serializer`؟** لما الـ data مش مرتبطة بـ Model واحد (nested من كذا model)، أو لما محتاج تحكم كامل في الـ validation والـ saving.

---

### س ٢٨: إزاي بتعمل Validation في DRF Serializer؟

3 مستويات:
1. **Field-Level:** `def validate_<field_name>(self, value):`
2. **Cross-Field:** `def validate(self, data):` — تقارن fields ببعض.
3. **Object-Level:** برضه في `validate(self, data)` لكن بتستخدم `self.context['request']` أو `self.instance`.

**الترتيب:**
1. `to_internal_value()` (تحويل JSON لـ Python).
2. `validate_<field_name>()` لكل field.
3. `Field.validate()` (الـ default validation).
4. `validate()` (الـ cross-field والـ object-level).

---

### س ٢٩: إزاي تتعامل مع Nested Relationships في DRF (قراءة وكتابة)؟

**القراءة (GET):**
- `client = ClientSerializer(read_only=True)` — يرجع object كامل.

**الكتابة (POST/PUT):**
- `client_id = serializers.PrimaryKeyRelatedField(queryset=User.objects.all(), source='client', write_only=True)` — الـ client يبعت ID.

**نقطة مهمة:** نفس الـ field (`client`) ممكن يكون nested في القراءة و primary key في الكتابة باستخدام serializer منفصلين أو `write_only=True` field منفصل.

**Nested Write (إنشاء related objects جوا الـ POST):** محتاج override `create()` و `update()` — معقد. الأفضل تعمل endpoint منفصل للـ nested resource.

---

### س ٣٠: إيه هو `SerializerMethodField`؟ وامتى تستخدمه بدل `source`؟

`SerializerMethodField` بينادي **method** في الـ serializer عشان يحسب قيمة field.

**استخدامات:**
- قيم محسوبة: `application_count = obj.applications.count()`.
- قيم معتمدة على context: `has_applied = obj.applications.filter(freelancer=self.context['request'].user).exists()`.
- Logic معقد.

**الفرق عن `source`:**
- `source='client.username'` — direct attribute access. أسرع. مناسب للوصول للـ related fields.
- `SerializerMethodField` — method call. أبطأ شوية. مناسب للـ logic المعقد.

**تحذير:** `SerializerMethodField` بينادي method **لكل object**. لو الـ queryset كبير، هيعمل N+1 Query Problem لو المmethod فيها DB query. استخدم `annotate()` أو `prefetch_related()`.

---

### س ٣١: إزاي بتضيف Custom Actions في ViewSet؟

باستخدام `@action` decorator:

```python
@action(detail=True, methods=['post'])
def apply(self, request, pk=None):
    job = self.get_object()
    # logic...
    return Response(...)

@action(detail=False, methods=['get'])
def featured(self, request):
    # logic...
    return Response(...)
```

- `detail=True` → URL: `/jobs/{pk}/apply/`.
- `detail=False` → URL: `/jobs/featured/`.

الـ Router بيضيف الـ URLs تلقائياً.

---

### س ٣٢: إيه هو الـ Router في DRF؟ وإزاي بيشتغل؟

الـ Router بيولد URL patterns تلقائياً من ViewSet:

```python
router = DefaultRouter()
router.register('jobs', JobViewSet, basename='job')
urlpatterns = router.urls
```

**الـ URLs المتولدة:**
- `GET /jobs/` → `job-list`
- `POST /jobs/` → `job-list`
- `GET /jobs/{id}/` → `job-detail`
- `PUT /jobs/{id}/` → `job-detail`
- `PATCH /jobs/{id}/` → `job-detail`
- `DELETE /jobs/{id}/` → `job-detail`

**`DefaultRouter` vs `SimpleRouter`:** `DefaultRouter` بيضيف API root view (`/`).

---

### س ٣٣: إزاي بتطبق JWT Authentication في DRF؟

1. `pip install djangorestframework-simplejwt`
2. في `settings.py`:
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
}
```
3. في `urls.py`:
```python
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
```
4. الـ client يبعت `username`/`password` لـ `/api/token/`، يستلم `access` و `refresh` tokens.
5. يبعت `Authorization: Bearer <access_token>` مع كل request.

---

### س ٣٤: إيه هو Refresh Token؟ وليه مهم؟

- **Access Token:** قصير العمر (5-15 دقيقة). بيتبعت مع كل API request.
- **Refresh Token:** طويل العمر (7-30 يوم). بيتبعت **فقط** لـ `/api/token/refresh/` عشان يجيب Access Token جديد.

**ليه المزيج ده؟**
- **أمان:** لو Access Token اتسرق، السارق يقدر يستخدمه لمدة قصيرة بس.
- **تجربة مستخدم:** المستخدم مش محتاج يسجل دخوله كل 5 دقايق. الـ client بيعمل refresh تلقائياً.
- **تحكم:** تقدر تـ blacklist الـ Refresh Token (عند logout) وتمنع Access Tokens جديدة.

---

### س ٣٥: إزاي تبني Custom Permission في DRF؟

```python
from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.client == request.user
```

- `has_permission(self, request, view)` — check عام (بتتنادى قبل الـ view).
- `has_object_permission(self, request, view, obj)` — check على instance معينة (بتتنادى في `get_object()`).

**الفرق:** `has_permission` = "هل يقدر يشوف أي Job؟". `has_object_permission` = "هل يقدر يشوف الـ Job #42 دي؟".

---

### س ٣٦: إيه هو Throttling (Rate Limiting) في DRF؟ وإزاي تطبقه؟

الـ Throttling بيحدد عدد الـ requests اللي مستخدم يقدر يبعت في فترة زمنية.

**في `settings.py`:**
```python
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    }
}
```

**Custom Throttle:**
```python
from rest_framework.throttling import SimpleRateThrottle

class BurstRateThrottle(SimpleRateThrottle):
    scope = 'burst'
    rate = '10/minute'
    
    def get_cache_key(self, request, view):
        return f"burst_{request.user.id}"
```

**إزاي بيشتغل؟** بيستخدم cache key (user ID أو IP). بيزود عداد لكل request. لو وصل للـ limit → 429 Too Many Requests.

---

### س ٣٧: إزاي بتعمل Filtering في DRF؟

**1. `DjangoFilterBackend` (لـ exact matching والـ ranges):**
```python
class JobFilter(django_filters.FilterSet):
    budget_min = django_filters.NumberFilter(field_name='budget_min', lookup_expr='gte')
    class Meta:
        model = Job
        fields = ['status', 'category']
```

**2. `SearchFilter` (لـ text search):**
```python
search_fields = ['title', 'description']
```

**3. `OrderingFilter` (للترتيب):**
```python
ordering_fields = ['created_at', 'budget']
```

**الدمج:**
```python
class JobViewSet(ModelViewSet):
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = JobFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'budget']
```

---

### س ٣٨: إيه الفرق بين `PageNumberPagination`, `LimitOffsetPagination`, و `CursorPagination`؟

- **`PageNumberPagination`:** `/jobs/?page=2`. بسيطة لكن بطيئة مع large offsets (`OFFSET 10000`). مناسبة للـ admin panels.
- **`LimitOffsetPagination`:** `/jobs/?limit=20&offset=40`. مرنة، نفس مشكلة الأداء.
- **`CursorPagination`:** `/jobs/?cursor=abc`. بتستخدم `WHERE (created_at, id) > (last_date, last_id)`. أسرع بكتير مع ملايين الـ records. Consistent (مفيش items مكررة أو مفقودة). الأحسن للـ production.

**القاعدة:** `CursorPagination` لـ APIs الحقيقية. `PageNumberPagination` لـ الـ admin أو الـ data الصغيرة.

---

### س ٣٩: إزاي بتعمل API Versioning في DRF؟

أسهل طريقة: **URL Path Versioning**:
```python
# config/urls.py
urlpatterns = [
    path('api/v1/', include('api_v1_urls')),
    # path('api/v2/', include('api_v2_urls')),  # Future
]
```

**لما تحتاج v2:**
- اعمل `jobs/api/v2/views.py` و `jobs/api/v2/serializers.py`.
- اعمل `api_v2_urls.py` جديد.
- v1 تفضل شغالة للـ clients القدام.

**Accept Header Versioning:** `Accept: application/json; version=1.0`. RESTful لكن أصعب في الـ testing.

---

### س ٤٠: إزاي بتوثق الـ API بتاعك في DRF؟

باستخدام `drf-yasg` (Yet Another Swagger Generator):

1. `pip install drf-yasg`
2. في `urls.py`:
```python
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(title="HireLink API", default_version='v1'),
    public=True,
)

urlpatterns = [
    path('swagger/', schema_view.with_ui('swagger'), name='swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc'), name='redoc'),
]
```

الـ documentation بيتولد تلقائياً من الـ code (docstrings, serializers). Swagger UI بيدي واجهة تفاعلية لتجربة الـ API.

---

## الجزء الرابع: System Design & Best Practices (١٠ أسئلة)

### س ٤١: إزاي تصمم Database Schema لـ Freelance Platform (زي HireLink)؟

**الكيانات الرئيسية:**
- **User:** Custom User Model (`email`, `user_type` (client/freelancer), `rating`).
- **Job:** `title`, `description`, `budget_min`, `budget_max`, `status`, `client_id` (FK), `category_id` (FK).
- **Skill:** `name`. علاقة ManyToMany مع Job (`JobSkill` through model).
- **Category:** `name`, `parent_id` (self FK للـ subcategories).
- **Application:** `job_id` (FK), `freelancer_id` (FK), `cover_letter`, `proposed_budget`, `status`. `unique_together=['job', 'freelancer']`.
- **Review:** `job_id` (FK), `reviewer_id` (FK), `reviewee_id` (FK), `rating`, `comment`. `unique_together=['job', 'reviewer', 'reviewee']`.
- **Message:** `sender_id` (FK), `receiver_id` (FK), `content`, `is_read`.
- **Notification:** `user_id` (FK), `type`, `title`, `message`, `is_read`, `data` (JSONField).

**Indexes:**
- `Job`: `status`, `client_id`, `category_id`, `created_at`.
- `Application`: `job_id`, `freelancer_id`, `status`.
- `Review`: `reviewee_id`.
- `Message`: `sender_id`, `receiver_id`, `created_at`.

**Performance Considerations:**
- UUIDs كـ PK (أمان ومنع التخمين).
- `select_related` للـ FKs, `prefetch_related` للـ M2M.
- Cached `rating` في User model.
- Soft delete للـ Jobs (بدل الحذف الفعلي).

---

### س ٤٢: إزاي تتعامل مع Race Conditions في Django؟ (زي قبول Application واحدة بس)

**الحل: Database Transactions + `select_for_update()`**

```python
from django.db import transaction

@transaction.atomic
def accept_application(application_id):
    job = Job.objects.select_for_update().get(applications__id=application_id)
    
    if job.status != 'open':
        raise ValidationError('Job is not open')
    
    if job.applications.filter(status='accepted').exists():
        raise ValidationError('Another application already accepted')
    
    application = job.applications.get(id=application_id)
    application.status = 'accepted'
    application.save()
    
    job.status = 'in_progress'
    job.save()
    
    job.applications.exclude(id=application_id).update(status='rejected')
```

**ليه `select_for_update()`؟** بيعمل **Row-Level Lock** على الـ Job row. أي transaction تانية هتستنى. بيمنع اتنين يقبلوا Applications مختلفة لنفس الـ Job في نفس الوقت.

**بديل (Optimistic Locking):** استخدم `version` field. `UPDATE ... WHERE version = X`. لو الـ rows affected = 0 → ارجع خطأ.

---

### س ٤٣: إزاي تحسن أداء Django API؟ (Performance Optimization)

1. **Database Queries:**
   - `select_related()` للـ ForeignKeys.
   - `prefetch_related()` للـ ManyToMany و Reverse FKs.
   - `annotate()` و `aggregate()` بدل ما تحسب في Python.
   - `values()` و `values_list()` لو محتاج fields معينة بس.
   - `only()` و `defer()` لتحميل fields معينة.
   - Indexes على الـ fields المستخدمة في الـ filtering والـ ordering.

2. **Caching:**
   - Redis/Memcached للـ frequently accessed data.
   - `@cache_page` للـ views.
   - Template fragment caching.
   - Cache الـ serializer output.

3. **Pagination:**
   - `CursorPagination` أفضل من `PageNumberPagination` للـ large datasets.
   - `limit` معقول (20-50 items).

4. **Async Tasks:**
   - Celery للعمليات البطيئة (Emails, image processing).
   - الـ API response يبقى سريع (يرجع 202 Accepted).

5. **Database Optimization:**
   - Connection pooling (`django-db-connection-pool` أو `pgbouncer`).
   - Read replicas للـ read-heavy applications.
   - Database sharding لو الـ data ضخمة جداً.

6. **Web Server:**
   - Gunicorn مع `gevent` أو `uvicorn` (ASGI) للـ async.
   - Nginx للـ static/media files والـ reverse proxy.

---

### س ٤٤: إزاي تؤمن Django API؟ (Security Best Practices)

1. **Authentication:**
   - JWT للـ APIs (Access + Refresh tokens).
   - `django-allauth` للـ social login.
   - 2FA للـ sensitive operations.

2. **Authorization:**
   - Custom Permissions في DRF.
   - Object-level permissions (`has_object_permission`).

3. **Input Validation:**
   - Serializer validation (field-level + object-level).
   - Sanitize user input (DRF بتعملها automatically).

4. **Rate Limiting:**
   - Throttling في DRF (`AnonRateThrottle`, `UserRateThrottle`).

5. **HTTPS:**
   - `SECURE_SSL_REDIRECT = True`.
   - HSTS headers.

6. **Secrets Management:**
   - Environment variables (`.env` file مش في Git).
   - `python-decouple`.

7. **SQL Injection Protection:**
   - Django ORM بتحمي automatically. تجنب `raw()` SQL إلا للضرورة.

8. **XSS Protection:**
   - Django templates بتعمل auto-escaping.
   - DRF JSONRenderer مش بيعرض لـ XSS.

9. **CSRF Protection:**
   - Django Forms بتحتاج `{% csrf_token %}`.
   - DRF (JWT) مش محتاجة CSRF tokens.

10. **Security Headers:**
    - `django-csp` (Content Security Policy).
    - `X-Frame-Options`, `X-Content-Type-Options`.

---

### س ٤٥: إزاي تصمم API لـ High Traffic (Scaling Django)؟

1. **Stateless Architecture:**
   - JWT بدل Sessions (مفيش sticky sessions).
   - الـ API server ميحتفظش بحالة.

2. **Load Balancing:**
   - Nginx أو AWS ALB قدام كذا Gunicorn instance.
   - Round-robin أو least-connections.

3. **Database Scaling:**
   - Connection pooling (`pgbouncer`).
   - Read replicas للـ read queries.
   - Indexes optimized.
   - Sharding (لو الـ data ضخمة جداً).

4. **Caching Layer:**
   - Redis للـ frequently accessed data.
   - Cache الـ serializer output.
   - CDN للـ static/media files.

5. **Async Processing:**
   - Celery للـ background tasks.
   - Redis/RabbitMQ كـ message broker.

6. **Web Server Optimization:**
   - Gunicorn مع `gevent` أو `uvicorn` (ASGI).
   - Keep-alive connections.

7. **Monitoring & Profiling:**
   - Django Debug Toolbar (development).
   - `django-silk` أو `py-spy` للـ profiling.
   - Sentry للـ error tracking.
   - Prometheus + Grafana للـ metrics.

8. **Microservices (لو احتاجت):**
   - قسم الـ monolith لـ services (Jobs, Payments, Notifications).
   - API Gateway (Kong, Traefik).

---

### س ٤٦: إزاي بتعمل Background Tasks في Django؟ (Celery)

1. **تثبيت Celery:**
   ```bash
   pip install celery redis
   ```

2. **`celery.py` في المشروع:**
   ```python
   from celery import Celery
   
   app = Celery('hirelink')
   app.config_from_object('django.conf:settings', namespace='CELERY')
   app.autodiscover_tasks()
   ```

3. **`tasks.py` في الـ app:**
   ```python
   from celery import shared_task
   from django.core.mail import send_mail
   
   @shared_task
   def send_welcome_email(user_id):
       user = User.objects.get(id=user_id)
       send_mail('Welcome!', '...', 'from@example.com', [user.email])
   ```

4. **استدعاء الـ task:**
   ```python
   send_welcome_email.delay(user.id)  # Async
   ```

5. **تشغيل Celery:**
   ```bash
   celery -A hirelink worker -l info
   ```

**فوائد Celery:**
- الـ API response سريع (الـ task بيتشغل في الخلفية).
- Retries تلقائية لو الـ task فشل.
- Scheduled tasks (زي `celery beat`).

---

### س ٤٧: إزاي بتعمل Testing في Django؟ (Unit Tests, Integration Tests)

**1. Unit Tests (`tests.py`):**
```python
from django.test import TestCase
from .models import Job

class JobModelTest(TestCase):
    def test_job_creation(self):
        job = Job.objects.create(title='Test', budget_min=100)
        self.assertEqual(job.status, 'draft')
```

**2. DRF API Tests:**
```python
from rest_framework.test import APITestCase
from rest_framework import status

class JobAPITest(APITestCase):
    def test_list_jobs(self):
        response = self.client.get('/api/v1/jobs/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
```

**3. Factories (`factory_boy`):**
```python
import factory
from .models import Job

class JobFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Job
    title = factory.Faker('sentence')
    budget_min = 1000
```

**4. Mocking (`unittest.mock`):**
```python
from unittest.mock import patch

@patch('myapp.tasks.send_email.delay')
def test_email_sent(self, mock_send):
    response = self.client.post('/api/register/', data)
    mock_send.assert_called_once()
```

**5. Coverage:**
```bash
coverage run manage.py test
coverage report
```

**Best Practices:**
- اختبر الـ Models, Serializers, Permissions.
- اختبر الـ edge cases (validation errors, 404, 403).
- استخدم `setUpTestData` للـ shared data.
- الـ tests تبقى سريعة (استخدم SQLite في الـ tests).

---

### س ٤٨: إيه هي الـ CORS؟ وإزاي تتعامل معاها في Django؟

**CORS (Cross-Origin Resource Sharing):** آلية أمان في المتصفحات بتمنع موقع `example.com` من إنه يعمل API request لـ `api.another.com` إلا لو الـ server سمح بده.

**المشكلة:** Frontend (React على `localhost:3000`) عايز يتعامل مع API (Django على `localhost:8000`). المتصفح هيرفض.

**الحل في Django:**
1. `pip install django-cors-headers`
2. في `settings.py`:
```python
INSTALLED_APPS = [
    'corsheaders',
    # ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # As high as possible
    # ...
]

# Development
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
]

# Production
CORS_ALLOWED_ORIGINS = [
    'https://hirelink.com',
    'https://app.hirelink.com',
]
```

**الـ Middleware بيضيف headers:**
- `Access-Control-Allow-Origin: http://localhost:3000`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE`

---

### س ٤٩: إزاي بتعمل Logging في Django؟

في `settings.py`:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'class': 'logging.FileHandler',
            'filename': BASE_DIR / 'logs/django.log',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
        'hirelink': {  # Custom logger for your app
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

**استخدامه:**
```python
import logging

logger = logging.getLogger(__name__)

def my_view(request):
    logger.info('User accessed the view', extra={'user': request.user.id})
```

**في Production:**
- استخدم `RotatingFileHandler` عشان متكترش الـ log files.
- استخدم Sentry أو ELK Stack للـ centralized logging.
- متسجلش بيانات حساسة (passwords, tokens).

---

### س ٥٠: إزاي بتدي Deployment لـ Django Project؟ (Production Checklist)

1. **Security Settings:**
   - `DEBUG = False`
   - `ALLOWED_HOSTS = ['hirelink.com']`
   - `SECURE_SSL_REDIRECT = True`
   - `SESSION_COOKIE_SECURE = True`
   - `CSRF_COOKIE_SECURE = True`
   - `SECURE_HSTS_SECONDS = 31536000`

2. **Database:**
   - PostgreSQL (مش SQLite).
   - Connection pooling (`pgbouncer`).

3. **Static/Media Files:**
   - `python manage.py collectstatic`
   - Nginx يخدم الـ static/media files.
   - AWS S3 أو Cloudflare R2 للـ media files.

4. **Web Server:**
   - Gunicorn مع `gevent` أو `uvicorn` (ASGI).
   - Nginx كـ reverse proxy.

5. **Process Manager:**
   - `systemd` أو `supervisor` لإدارة Gunicorn و Celery.

6. **Environment Variables:**
   - `.env` file أو system environment variables.
   - الأسرار (SECRET_KEY, DB_PASSWORD) مش في الكود.

7. **Monitoring:**
   - Sentry للـ error tracking.
   - Prometheus + Grafana للـ metrics.
   - Health check endpoint (`/health/`).

8. **Backups:**
   - Database backups يومية.
   - Media files backups.

9. **CI/CD:**
   - GitHub Actions أو GitLab CI.
   - Run tests before deployment.
   - Automated deployment.

10. **Scaling:**
    - Load balancer قدام كذا Gunicorn instance.
    - Redis للـ caching والـ sessions.
    - Read replicas للـ database.

---

## 📝 خلاصة الرحلة

دي كانت رحلة متكاملة من أول سطر Python لحد Production-Ready API. بدأنا بفهم الـ Memory Model والـ GIL، اتعمقنا في OOP والـ Functional Programming، بنينا Django Core قوي، واحترفنا DRF لبناء APIs حديثة. وأخيراً، جمعنا كل ده في مشروع HireLink حقيقي.

الـ ٥٠ سؤال إنترفيو دول هما تتويج الرحلة. مش مجرد إجابات — هم proof إنك فاهم **إزاي** الحاجة بتشتغل، مش بس **إنها** بتشتغل. النهارده أنت جاهز لأي إنترفيو Backend من Fresh لـ Mid-Level.

**الخطوة الجاية:** طبق اللي اتعلمته. ابنِ مشروعك الخاص. واجه مشاكل حقيقية. اقرا الـ official docs. وافضل دايمًا تسأل: "ليه؟".

بالتوفيق يا هندسة. 🚀