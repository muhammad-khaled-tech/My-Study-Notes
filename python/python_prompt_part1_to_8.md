أنت خبير Python وكاتب محتوى تعليمي بالعامية المصرية، ومهمتك إنك تكتب ملف Markdown واحد كبير (بأسلوب Obsidian) اسمه "بايثون من الصفر — الجزء الأول: الأساسيات" يغطي المواضيع التالية بالترتيب ده بالظبط، من صفر مطلق لأعمق نقطة في كل موضوع، عشان أذاكر منه لإنترفيو بايثون.

---

## هيكل الملف:

**Frontmatter في الأول:**
```
---
tags: [python, interview-prep, بايثون-من-الصفر]
part: 1
covers: "Variables · Data Types · Operators · Strings · Collections · Control Flow · Functions · Exception Handling · Built-ins Toolbox"
---
```

**عنوان رئيسي:** `# 🐍 بايثون من الصفر — الأساسيات (Q1 → نهاية الملف)`

**Callout افتتاحي:**
```
> [!info] 📖 إزاي تذاكر الملف ده؟
> [جملتين بتشرح إن الملف ده بيغطي موضوعات 1-8 زائد ملحق built-in functions، وإن كل سؤال بيبني على اللي قبله]
```

---

## بنية كل سؤال (طبّقها بالظبط على كل Q):

1. **عنوان السؤال** بصيغة سؤال عامي طبيعي: `## Q{N} — [السؤال هنا بالعامية؟]`

2. **`### أصل الحكاية`** — فقرة عامية بتشرح الموضوع وإيه المشكلة اللي بيحلها. **ممنوع أي مقارنة بلغات تانية** (مش C، مش Java، مش JS — بايثون بس).

3. **كود Python** فيه **كومنتات إنجليزي بس جوا الكود** — runnable ومباشر، مع `print()` يوضح المخرجات كـ comment في الكود.

4. **2–3 code snippets إضافية** تغطي: (أ) حالة بسيطة، (ب) edge case، (ج) حالة عملية شبه واقعية.

5. **`### الفايدة الانترفيوية`** — فقرة بتربط الموضوع بسؤال إنترفيو حقيقي بصيغة *"Explain..."* أو *"What's the difference between...?"*

6. **Callouts حسب الحاجة:**
   - `> [!tip] Checkpoint` — ملخص سريع لما المفروض تكون فاهمه
   - `> [!warning]` — فخ شائع بيوقع فيه الناس
   - `> [!danger]` — فخ خطير بيبان في الإنترفيو بالظبط

7. **`---`** فاصل بين كل سؤال والتاني.

---

## قواعد اللغة والأسلوب:

- **الشرح النثري كله بالعامية المصرية** — مفيش فصحى خالص (مش "يُعرَّف" ولا "يُتيح لنا")
- **الكومنتات جوا الكود إنجليزي بس** — مش عربي، مش مزيج
- **الإنجليزي في الشرح النثري ممنوع** — حتى لو الكلمة تقنية، اكتبها بالعربي وحط الإنجليزي بين قوسين أو قبلها الـ مثلاً: "الـ reference count"
- ماتكتبش خاتمة أو ملخص في آخر الملف — كمل شرح وأمثلة لآخر لحظة
- كل جملة لازم تضيف فهم فعلي، مفيش حشو

---

## قاعدة التدرج داخل كل موضوع:

كل موضوع بيتغطى بسلسلة أسئلة تبدأ **بسيطة جداً** وتتصاعد تدريجياً:
- أول سؤال: تعريف الفكرة الأساسية من غير افتراض أي معرفة مسبقة
- الأسئلة الوسطى: edge cases وسلوك غير متوقع
- آخر سؤال في الموضوع: أعمق نقطة فيه + أشهر فخ إنترفيو مرتبط بيه

---

## ترقيم الأسئلة:

رقّم الأسئلة **تسلسلياً عبر كل الملف** من Q1 لآخر سؤال من غير ما ترجع لـ Q1 في كل موضوع جديد.

---

## المحتوى المطلوب بالترتيب ده بالظبط:

### 📌 الموضوع 1: Variables & Memory Model
غطّي الأسئلة دي بالتسلسل:
- إيه الـ Variable في بايثون وإزاي بايثون بتشوف "الاسم" و"الـ object" كحاجتين مختلفتين؟
- إيه قواعد التسمية الإجبارية وإيه الـ PEP 8 conventions المتعارف عليها؟
- إيه معنى إن بايثون Dynamically Typed وإيه الفرق بين dynamic وstatic typing؟
- إيه الفرق الحقيقي بين `is` و`==`؟ (Small Integer Cache وString Interning)
- إيه معنى Mutable وImmutable وليه ده مهم؟ (مع الـ default mutable argument trap)
- إزاي بايثون بتدير الميموري بالـ Reference Counting؟ وإمتى بيجي الـ Garbage Collector؟
- إيه الـ Shallow Copy والـ Deep Copy وإمتى تستخدم كل واحدة؟
- إيه الـ LEGB Rule وإزاي بايثون بتدور على أي اسم؟ (`global` وـ`nonlocal`)
- إيه الـ `del` statement وبيحذف الـ object فعلاً ولا بس الاسم؟
- إيه الـ `__slots__` وإمتى تستخدمه لتوفير الميموري؟

### 📌 الموضوع 2: Data Types
غطّي الأسئلة دي بالتسلسل:
- إيه الـ built-in types الأساسية في بايثون وإيه الفرق بين كل واحدة؟
- إيه الـ int في بايثون وليه مفيش integer overflow؟ (arbitrary precision)
- إيه الـ float وليه `0.1 + 0.2 != 0.3`؟ (IEEE 754 floating point)
- إزاي تقارن أرقام float بشكل آمن؟ (`math.isclose()` بدل `==`)
- إمتى تستخدم `decimal.Decimal` بدل `float`؟
- إيه الـ bool في بايثون وليه هو subclass من int؟ (True == 1، False == 0)
- إيه الـ None وإيه الفرق بينه وبين `0` و`False` و`""`؟
- إيه الـ Type Casting وإيه الفرق بين explicit وimplicit conversion؟
- إيه الـ Truthy والـ Falsy values وإزاي بايثون بتقيّمهم في الـ boolean context؟
- إزاي تتحقق من الـ type؟ (`type()` vs `isinstance()` — الفرق مهم!)
- إيه الفرق بين `bytes` و`bytearray` و`str`؟ وإمتى تستخدم كل واحدة؟
- إيه الفرق بين `repr()` و`str()`؟ وإمتى بايثون بتستدعي كل واحدة تلقائياً؟
- إيه `sys.maxsize` وإيه اختلاف حدود الأرقام بين البلاتفورمات؟
- إيه edge cases الأرقام اللي بتبان في الإنترفيو؟ (`inf`, `nan`, `//`, `%` مع negative numbers)

### 📌 الموضوع 3: Operators
غطّي الأسئلة دي بالتسلسل:
- إيه الـ arithmetic operators وإيه الفرق بين `/` و`//`؟
- إيه الـ `**` operator وإيه precedence rules في بايثون؟ (مع أمثلة تعقيد زي `not x == y` vs `(not x) == y`)
- إيه الـ comparison operators وإزاي بايثون بتسمح بـ chaining؟ (`1 < x < 10`)
- إيه الـ logical operators (`and`, `or`, `not`) وإزاي بيشتغلوا بـ short-circuit evaluation؟
- إزاي `and` و`or` بترجع القيمة نفسها مش بس `True`/`False`؟ (مثال: `x = 0 or "default"`)
- إيه الـ bitwise operators وإمتى بتيجي فايدتهم؟
- إيه الـ `@` operator (matrix multiplication) وفين بتظهر فايدته؟
- إيه الـ Walrus Operator (`:=`) وإزاي بيحل مشاكل فعلية؟ (Python 3.8+)
- إيه الـ ternary expression في بايثون وإيه الفرق بينه وبين الـ if/else العادية؟
- إيه الـ `in` وـ`not in` operators وإيه الفرق في الـ performance بين list وset وdict؟
- إزاي الـ augmented assignment (`+=`, `-=`) بتتصرف مختلف مع mutable وimmutable objects؟ (فخ إنترفيو كلاسيكي)

### 📌 الموضوع 4: Strings
غطّي الأسئلة دي بالتسلسل:
- إيه أنواع الـ string literals في بايثون؟ (single، double، triple، raw strings)
- إيه معنى إن الـ string immutable وإزاي ده بيأثر على الكود؟
- إزاي الـ String Slicing بتشتغل؟ (syntax، negative indices، step)
- إيه أهم string methods اللي بتيجي في الإنترفيو؟ (split، join، strip، replace، find، startswith، endswith، upper/lower)
- إيه الـ f-strings وليه هما الـ best practice؟ (expressions، formatting specs زي `:.2f` و`:>10` و`:,`)
- إيه الفرق بين `%` formatting وـ`.format()` وـf-strings؟ (وليه f-strings أحسن)
- إزاي string concatenation في الـ loop غلط وإزاي تعملها صح؟ (`.join()`)
- إيه الـ String Interning وإمتى الـ `is` بيرجع True للـ strings؟
- إزاي بايثون بتقارن strings مع بعض؟ (lexicographic comparison)
- إيه `ord()` و`chr()` وإمتى بتستخدمهم؟
- إيه الفرق بين `str.encode()` و`bytes.decode()`؟ وإيه علاقتهم بـ UTF-8؟
- إيه الـ `textwrap.dedent()` واستخدامه مع الـ multiline strings؟
- إيه الفرق بين `repr()` والـ `__repr__` للـ strings؟ (تمهيد لسؤال أعمق في الـ OOP)
- إيه edge cases الـ encoding وـUTF-8 اللي بتيجي في الإنترفيو؟

### 📌 الموضوع 5: Collections (List, Tuple, Set, Dict)
غطّي الأسئلة دي بالتسلسل:
- إيه الفرق بين List وTuple وإمتى تستخدم كل واحدة؟
- إزاي الـ List Indexing وـSlicing بيشتغلوا؟ (مع negative indices)
- إيه أهم list methods؟ (`append` vs `extend`، `pop` vs `remove`، `sort` vs `sorted`)
- إزاي تستخدم slice assignment عشان تستبدل جزء من list؟ (`lst[1:3] = [...]`)
- إيه الـ List Comprehension وإزاي هي أحسن من الـ for loop؟ (مع nested comprehensions)
- إيه فخ `[[]] * 3`؟ وليه العناصر التلاتة بتشاور على نفس الـ list؟
- إيه الـ Tuple Unpacking وإزاي بيتستخدم؟ (including `*` extended unpacking)
- إيه الـ Set وإيه حالات الاستخدام الحقيقية؟ (uniqueness، membership testing)
- إيه الـ Set Operations؟ (union، intersection، difference، symmetric difference)
- إيه الـ Dict وإزاي بيشتغل internally؟ (hash table — بشكل مبسط)
- إيه معنى Hashability؟ وليه الـ mutable objects (زي list) مينفعش تبقى dict keys ولا set elements؟
- إيه أهم dict methods؟ (`get`، `setdefault`، `items/keys/values`، `update`)
- إيه فخ `dict.fromkeys()` مع mutable default value؟
- إيه الـ Dict Comprehension والـ defaultdict والـ Counter؟
- إيه الفرق في الـ performance بين list وset وdict للـ lookup؟ (O(n) vs O(1))
- إيه الـ frozenset وإمتى تستخدمه؟
- إيه الـ `collections.OrderedDict`؟ وليه dict العادية بقت ordered من Python 3.7 وإيه اللي فضل يميز OrderedDict؟
- إيه الـ `collections.deque`؟ وليه أحسن من list كـ queue؟ (`O(1)` للـ append/pop من الطرفين)
- إيه الـ `collections.namedtuple`؟ وإزاي بيبقى lightweight alternative للـ classes؟
- إيه الـ `|` وـ`|=` لدمج dictionaries؟ (Python 3.9+)
- إيه الـ unpacking operators `*` وـ`**` في كل سياقاتهم؟ (function calls، list/dict literals، assignment)
- إيه الـ `bisect` module وفين بيفيد في أسئلة الـ algorithms؟
- إيه `operator.itemgetter` كـ alternative لـ lambda في الـ sort key؟
- إزاي تختار بين الـ collections المختلفة بناءً على الـ use case؟

### 📌 الموضوع 6: Control Flow
غطّي الأسئلة دي بالتسلسل:
- إزاي الـ `if/elif/else` بتشتغل في بايثون؟ (مع الـ truthy/falsy evaluation)
- إيه الفرق بين `for` وـ`while` وإمتى تستخدم كل واحدة؟
- إزاي الـ `for` loop بتتعامل مع أي iterable؟ (مش بس lists)
- إيه `break` وـ`continue` وـ`pass` وإيه الفرق بينهم؟
- إيه الـ `else` على الـ loops (for/while) وإزاي بتشتغل؟ (ده من أغرب Features بايثون)
- إزاي تعمل break من جوا nested loop في بايثون؟ (مفيش labeled break زي لغات تانية)
- إيه الـ `range()` وإيه الفرق بين `range(n)` وـ`range(start, stop, step)`؟
- إزاي تعمل loop على أكتر من sequence في نفس الوقت؟ (`zip`، `enumerate`)
- إيه الـ `zip_longest` من `itertools` وإيه الفرق عن `zip` العادية؟
- إيه الـ `any()` وـ`all()` وإمتى بتيجي فايدتهم مع الـ iterables؟
- إيه أساسيات الـ `itertools`؟ (`chain`، `product`، `combinations`، `islice`)
- إيه الـ conditions (الـ filter part) جوا الـ comprehensions؟
- إيه الـ `match/case` statement في Python 3.10+؟

### 📌 الموضوع 7: Functions
غطّي الأسئلة دي بالتسلسل:
- إزاي تعرّف function في بايثون وإيه الـ return behavior؟ (None by default)
- إيه الفرق بين positional وkeyword arguments؟
- إيه الـ `*args` وـ`**kwargs` وإزاي بيشتغلوا؟
- إيه الـ Default Arguments trap وليه ممنوع تستخدم mutable default؟
- إزاي بايثون بتعامل مع الـ function arguments في الميموري؟ (pass-by-object-reference)
- إزاي بايثون بترجع أكتر من قيمة من function واحدة؟ (tuple packing/unpacking)
- إيه الـ First-Class Functions وإزاي تبعت function كـ argument؟
- إيه الـ Closures وإزاي بتشتغل؟ (capturing variables from enclosing scope)
- إيه الـ `nonlocal` في سياق الـ closures؟
- إيه الـ factory functions pattern؟ (functions that return functions)
- إيه الـ `*` وـ`/` في الـ function signature؟ (keyword-only وpositional-only arguments — Python 3.8+)
- إيه الـ Recursion وإيه الـ recursion limit في بايثون؟ (`sys.setrecursionlimit`)
- إيه الـ `functools.lru_cache` وإزاي بيحسن الـ performance؟
- إيه الـ `functools.partial` وإزاي بيبقى تطبيق عملي للـ closures؟
- إيه الـ `functools.wraps` وليه محتاجه (حتى قبل ما ندخل الـ decorators بالتفصيل)؟
- إيه الـ docstrings وـ`__doc__`؟ وإيه الفرق بينهم وبين الـ comment العادي؟
- إيه `getattr` / `setattr` / `hasattr` / `delattr`؟ وفين بيبانوا في dynamic programming؟

### 📌 الموضوع 8: Exception Handling
غطّي الأسئلة دي بالتسلسل:
- إيه الـ Exception Hierarchy في بايثون؟ (BaseException → Exception → ...)
- إيه الفرق بين SyntaxError والـ Exceptions التانية؟
- إزاي `try/except` بتشتغل وإزاي تمسك exceptions محددة؟
- إيه الفرق بين EAFP وLBYL وأنهي approach أفضل في بايثون؟
- إيه الـ `else` على الـ `try/except` وإمتى بيتشغل؟
- إيه الـ `finally` وليه بيتشغل دايماً حتى لو فيه return؟
- إزاي تعمل Custom Exception Classes؟
- إيه الـ `raise` وـ`raise from` وإيه الفرق بينهم؟
- إزاي تمسك Exception وتحتفظ بيها وترميها تاني؟ (`raise` without arguments)
- إيه أشهر built-in exceptions اللي بتيجي في الإنترفيو؟ (ValueError، TypeError، KeyError، AttributeError، IndexError، NameError)
- إيه الـ Context Managers (`with` statement) وعلاقتها بالـ exception handling؟
- إيه الـ `assert` statement وإزاي بيشتغل؟ ومتى بيبقى غير آمن الاعتماد عليه؟ (بيتعطل مع flag الـ `-O`)
- إيه الـ `contextlib.suppress` وإزاي بديل أنيق لـ `try/except/pass`؟
- إيه الفرق بين الـ `warnings` module والـ exceptions؟
- إيه الـ chained exceptions بالتفصيل؟ (`__cause__` vs `__context__`)
- إيه الـ `ExceptionGroup` وـ`except*` في Python 3.11+؟

### 📌 ملحق: Built-in Functions الأساسية والـ Introspection
غطّي الأسئلة دي بالتسلسل (ده ملحق بعد الـ 8 مواضيع، بيجمع built-ins بتتكرر في كل مكان):
- إيه أهم الـ built-in functions اللي بتستخدمها كل يوم؟ (`map`، `filter`، `zip`، `enumerate`، `sorted`، `reversed`)
- إيه الفرق بين `map`/`filter` وـList Comprehension؟ وليه أغلب الـ Python developers بيفضلوا الـ comprehension؟
- إزاي تستخدم `min()`/`max()`/`sorted()` مع الـ `key` parameter؟
- إيه `sum()`، `abs()`، `round()` وإيه edge cases الـ rounding؟ (banker's rounding)
- إيه `dir()`، `vars()`، `help()` كـ أدوات introspection؟
- إيه كل الـ arguments بتاعة `print()`؟ (`sep`، `end`، `file`، `flush`)
- إزاي تستخدم الـ `*` في الـ unpacking جوا assignment؟ (`first, *rest = [1, 2, 3, 4]`)

---

## قاعدة الاستمرارية (الأهم):

**متوقفش الكتابة نفسك ولا تلخص ولا تختصر عشان "تخلص الملف بسرعة".** اكتب باستفاضة وأمثلة كتير على طول لحد ما توصل فعلياً لآخر الـ tokens المسموحة ليك في الرد، حتى لو وقفت في نص سؤال أو نص جملة. **ممنوع تعمل خاتمة أو ملخص نهائي** في آخر أي رد — كمل شرح وأمثلة بس. لو حسيت إنك قرّبت من الحد، كمل في نفس الجملة، وأنا هقولك "كمل" وانت تكمل بالظبط من نفس النقطة اللي وقفت فيها من غير ما تعيد أو تلخص اللي فات.

---

ابدأ دلوقتي من Q1 وامشي بالترتيب.
