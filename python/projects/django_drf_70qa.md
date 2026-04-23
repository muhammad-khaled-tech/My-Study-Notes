---
tags:
  - django
  - django-rest-framework
  - interview
  - revision
  - backend
created: 2026-04-23
status: complete
questions_count: 70
---

# 🦄 Django & DRF — من الصفر للإنترفيو | 70 سؤال وجواب

> كل سؤال هنا بيبني على اللي قبله — متقفزش. الـ flow مقصود.
> الهدف مش حفظ إجابات — الهدف إنك تقدر تناقش أي نقطة من أي زاوية.

---

## 🗂️ فهرس المواضيع

| الباب | الأسئلة |
|---|---|
| [[#🔹 Django Architecture — إزاي بيشتغل؟]] | Q01 → Q07 |
| [[#🔹 Models والـ Database]] | Q08 → Q17 |
| [[#🔹 Migrations]] | Q18 → Q21 |
| [[#🔹 ORM والـ QuerySets]] | Q22 → Q31 |
| [[#🔹 Views — FBV و CBV]] | Q32 → Q38 |
| [[#🔹 URLs والـ Routing]] | Q39 → Q42 |
| [[#🔹 Forms والـ Auth]] | Q43 → Q48 |
| [[#🔹 Django REST Framework]] | Q49 → Q55 |
| [[#🔹 15 سؤال صعبين — متوسط]] | Q56 → Q70 |

---

## 🔹 Django Architecture — إزاي بيشتغل؟

---

### Q01 — إيه هو Django وإيه الـ MTV Pattern؟

**الجواب:**
Django هو **web framework** بيكتب بـ Python، مبني على فلسفة "batteries included" — يعني كل حاجة محتاجها موجودة جوه: auth, ORM, admin, forms.

الـ **MTV** هو الـ architecture pattern اللي Django بيتبعه:

```
MTV = Model + Template + View
```

```
M → Model      = التعامل مع الـ Database
T → Template   = الـ HTML اللي المستخدم بيشوفه
V → View       = الـ Logic اللي بيربط بينهم
```

بيشبه الـ MVC المعروف — بس التسمية مختلفة:

| MVC | MTV في Django |
|---|---|
| Model | Model |
| View (الـ UI) | Template |
| Controller (الـ Logic) | View |

> [!tip] نصيحة الإنترفيو
> لو سألوك "إيه الفرق بين MVC و MTV؟" — قول إن الـ View في Django بيقوم بدور الـ Controller، والـ Template بيقوم بدور الـ View. مجرد اختلاف في التسمية مش في المفهوم.

---

### Q02 — إيه رحلة الـ Request في Django؟

**الجواب:**
كل request بيعدي على محطات ثابتة بالترتيب ده:

```
Browser: GET /projects/5/
         ↓
1. WSGI/ASGI Server (gunicorn/uvicorn)
         ↓
2. Django Middleware Stack (بالترتيب — من فوق لتحت)
         ↓
3. URL Resolver (urls.py) → يطابق الـ pattern
         ↓
4. View (function أو class) تشتغل
         ↓
5. (لو محتاج) ORM → Database → بيرجع Data
         ↓
6. Template Rendering أو Serializer → JSON
         ↓
7. Middleware Stack (بالعكس — من تحت لفوق)
         ↓
8. HTTP Response → Browser ✅
```

> [!note] لاحظ
> الـ Middleware بيشتغل مرتين — مرة وهو رايح (process_request) ومرة وهو راجع (process_response). عشان كده ترتيبهم في `settings.py` مهم.

---

### Q03 — إيه هو الـ Middleware وإزاي بيشتغل؟

**الجواب:**
الـ Middleware هو حاجة بتقف **بين الـ request والـ view** — زي بوابة أمن في المبنى. كل request بيعدي عليها قبل ما يوصل للـ view وبعد ما الـ view يرجع response.

```python
# كل middleware في settings.py بيشتغل بالترتيب ده:
MIDDLEWARE = [
    'SecurityMiddleware',     # ← أول واحد بيشتغل في الـ request
    'SessionMiddleware',      # ← تاني
    'CsrfViewMiddleware',     # ← تالت
    'AuthenticationMiddleware', # ← هنا بيتحدد request.user
    'MessageMiddleware',      # ← آخر واحد
]
# وبيتعكس الترتيب في الـ response!
```

الـ Middleware المهمة:
- `AuthenticationMiddleware` → بيضيف `request.user` لكل request
- `CsrfViewMiddleware` → بيحمي من CSRF attacks
- `SessionMiddleware` → بيوفر الـ session للـ user

```python
# ازاي بتكتب middleware بنفسك
class TimingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response  # ← بيمثل الـ view (أو الـ middleware التالي)

    def __call__(self, request):
        import time
        start = time.time()

        response = self.get_response(request)  # ← بيشغل الـ view

        duration = time.time() - start
        response['X-Duration'] = str(duration)  # ← بيضيف header في الـ response
        return response
```

---

### Q04 — إيه الفرق بين WSGI وASGI في Django؟

**الجواب:**
دول بروتوكولات بتحدد إزاي الـ web server بيتكلم مع Django.

| | WSGI | ASGI |
|---|---|---|
| ظهر | 2003 | 2019 |
| النوع | Synchronous | Async-capable |
| server | gunicorn, uWSGI | uvicorn, daphne |
| يدعم | HTTP فقط | HTTP + WebSockets + SSE |
| مناسب لـ | معظم الـ apps | Chat, Real-time, Streaming |

```python
# wsgi.py — موجود تلقائياً
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
application = get_wsgi_application()

# asgi.py — موجود تلقائياً (Django 3.0+)
import os
from django.core.asgi import get_asgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
application = get_asgi_application()
```

> [!tip] نصيحة الإنترفيو
> لو بتستخدم Django بس بدون WebSockets — WSGI كافي. لو بتعمل chat app أو real-time notifications — محتاج ASGI مع Django Channels.

---

### Q05 — إيه الفرق بين Project وApp في Django؟

**الجواب:**
سؤال أساسي بيتسأل دايماً في الأول.

```
Project = الحاوية الكبيرة — فيها الـ settings, urls, wsgi الرئيسية
App     = وحدة وظيفية مستقلة جوه الـ Project
```

```bash
# project واحد — apps متعددة
freelance_api/          ← Project
├── settings.py
├── urls.py
├── accounts/           ← App: User registration, auth
├── projects/           ← App: Project listings
├── proposals/          ← App: Freelancer proposals
└── payments/           ← App: Billing
```

الـ App المفروض تكون **reusable** — يعني تقدر تنقلها لـ project تاني وتشتغل.

```python
# settings.py — لازم تضيف الـ app هنا عشان Django يشوفها
INSTALLED_APPS = [
    'django.contrib.admin',
    # ...
    'accounts',    # ← app بتاعتك
    'projects',
]
# لو ما ضفتهاش → migrations مش هتشتغل، models مش هتتعرف
```

---

### Q06 — إيه أهم الـ manage.py commands وبتعمل إيه؟

**الجواب:**
الـ `manage.py` هو CLI بتاع Django — بتعمل بيه كل حاجة.

```bash
# ── Development ──────────────────────────────────────
python manage.py runserver          # start dev server on :8000
python manage.py runserver 0.0.0.0:8000  # accessible from network

# ── Database ─────────────────────────────────────────
python manage.py makemigrations     # detect model changes → generate migration files
python manage.py migrate            # apply migrations to the actual DB
python manage.py showmigrations     # list all migrations + status (applied or not)
python manage.py sqlmigrate app 0001  # show the SQL a migration will run

# ── User Management ───────────────────────────────────
python manage.py createsuperuser    # create admin user interactively

# ── Debugging ─────────────────────────────────────────
python manage.py shell              # Python shell with Django loaded
python manage.py dbshell            # DB shell (psql, sqlite3, etc.)
python manage.py check              # check project for common problems

# ── Static Files ──────────────────────────────────────
python manage.py collectstatic      # gather all static files for production

# ── Testing ───────────────────────────────────────────
python manage.py test               # run all tests
python manage.py test projects      # run tests for specific app
```

---

### Q07 — إيه أهم settings في الـ settings.py؟

**الجواب:**

```python
# settings.py — أهم الـ settings اللي لازم تعرفها

DEBUG = True  # ← False دايماً في production! لو True وفيه error → بيظهر traceback للمستخدم

SECRET_KEY = 'your-secret-key'  # ← بيستخدم في الـ signing، لازم يكون سري وطويل

ALLOWED_HOSTS = ['localhost', 'api.mysite.com']  # ← لو DEBUG=False → لازم تحدد الـ hosts

INSTALLED_APPS = [...]   # ← كل app لازم تكون هنا

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',  # بدّلها لـ postgresql في production
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Static & Media files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'  # ← collectstatic بيحط الملفات هنا

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'  # ← الـ uploaded files بتتحفظ هنا

# Authentication
AUTH_USER_MODEL = 'accounts.User'  # ← لو عملت custom user model
LOGIN_URL = '/auth/login/'
LOGIN_REDIRECT_URL = '/dashboard/'

TIME_ZONE = 'Africa/Cairo'  # ← اهم من ما تتخيل في الـ DateTimeField
USE_TZ = True  # ← timezone-aware datetimes — True دايماً
```

---

## 🔹 Models والـ Database

---

### Q08 — إيه هو الـ Django Model وإزاي بيتحول لـ Database Table؟

**الجواب:**
الـ Model هو Python class بيرث من `models.Model` — كل attribute بيبقى column في الجدول.

```python
# models.py
from django.db import models

class Project(models.Model):
    title  = models.CharField(max_length=200)   # → VARCHAR(200) column
    budget = models.DecimalField(max_digits=10, decimal_places=2)  # → DECIMAL column
    is_active = models.BooleanField(default=True)  # → BOOLEAN column

# Django automatically adds:
# id = models.BigAutoField(primary_key=True)  ← unless you define your own
```

بعد ما تعمل `makemigrations` و`migrate`:

```sql
-- Django runs this SQL automatically:
CREATE TABLE "projects_project" (
    "id"        integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    "title"     varchar(200) NOT NULL,
    "budget"    decimal(10, 2) NOT NULL,
    "is_active" bool NOT NULL
);
```

اسم الـ table = `appname_modelname` (lowercase).

---

### Q09 — إيه الفرق بين `CharField` و`TextField`؟ وامتى تستخدم كل واحد؟

**الجواب:**
سؤال بسيط بس بيسألوه كتير عشان فيه فهم غلط شائع.

```python
# CharField → VARCHAR في الـ SQL — محتاج max_length دايماً
name = models.CharField(max_length=100)    # لو كتبت أكتر من 100 حرف → validation error

# TextField → TEXT في الـ SQL — بدون حد معين
description = models.TextField()           # مناسب للـ long text
```

| | CharField | TextField |
|---|---|---|
| SQL type | VARCHAR(n) | TEXT |
| max_length | مطلوب | مش مطلوب |
| Form widget | `<input type="text">` | `<textarea>` |
| مناسب لـ | اسم، عنوان، slug | وصف، محتوى، bio |

> [!tip] نصيحة الإنترفيو
> فيه فهم غلط إن TextField في الـ Database "أبطأ" من CharField. ده مش صح في PostgreSQL — الاتنين بيشتغلوا بنفس الكفاءة تقريباً. الفرق الحقيقي في الـ validation وإيه بيظهر في الـ forms.

---

### Q10 — إيه الفرق بين `null=True` و`blank=True`؟

**الجواب:**
ده من أكتر الأسئلة اللي بتاخذ وقت في الإنترفيو.

```python
# null=True → للـ DATABASE: الـ column يقبل NULL
# blank=True → للـ FORM / SERIALIZER: الـ field مش required في الـ validation

class Profile(models.Model):
    bio     = models.TextField(blank=True)         # ✅ form accepts empty, DB stores ""
    age     = models.IntegerField(null=True, blank=True)  # DB stores NULL, form optional
    website = models.URLField(null=True, blank=True)      # ← both needed for optional URL
```

القاعدة العملية:
- **CharField / TextField**: استخدم `blank=True` بس — **ما تستخدمش** `null=True`
  - عشان ما تخليش فيه طريقتين لتمثيل "فراغ": NULL وـ empty string
- **Numeric / Date / FK fields**: استخدم `null=True, blank=True` لما تحتاجهم optional

```python
# ❌ غلط — ليه في نصين معناهم "فاضي"؟
name = models.CharField(max_length=100, null=True, blank=True)

# ✅ صح
name = models.CharField(max_length=100, blank=True, default='')
age  = models.IntegerField(null=True, blank=True)  # ← هنا صح عشان رقم
```

---

### Q11 — إيه الفرق بين `auto_now` و`auto_now_add`؟

**الجواب:**

```python
class Project(models.Model):
    # auto_now_add → set ONCE when the object is CREATED, never changes again
    created_at = models.DateTimeField(auto_now_add=True)

    # auto_now → updated EVERY TIME the object is saved (on create AND update)
    updated_at = models.DateTimeField(auto_now=True)
```

| | `auto_now_add` | `auto_now` |
|---|---|---|
| متى بيتحدد | عند الإنشاء بس | كل مرة `.save()` |
| قابل للتعديل | ❌ (editable=False) | ❌ (editable=False) |
| مناسب لـ | `created_at` | `updated_at` |

> ⚠️ **انتبه:** الاتنين بيضبطوا `editable=False` تلقائياً — يعني مش هيظهروا في الـ forms أو admin. لو عايز تحكم في القيمة يدوياً، استخدم `default=timezone.now` بدلهم.

---

### Q12 — إيه الفرق بين `ForeignKey`, `OneToOneField`, `ManyToManyField`؟

**الجواب:**
دول بيمثلوا أنواع العلاقات بين الـ models.

```python
# ForeignKey → Many-to-One
# Many Tasks → One Project
class Task(models.Model):
    project = models.ForeignKey('Project', on_delete=models.CASCADE)
    # Task.project → one Project object
    # Project.task_set.all() → all tasks for this project (or use related_name)

# OneToOneField → One-to-One (like ForeignKey + unique constraint)
# One User → One Profile
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    # Profile.user → one User
    # User.profile → one Profile (NOT a queryset — single object)

# ManyToManyField → Many-to-Many
# One Project can have many Skills, one Skill can belong to many Projects
class Project(models.Model):
    skills = models.ManyToManyField('Skill', blank=True)
    # Django creates a hidden junction table automatically
    # project.skills.all() → queryset of Skills
    # skill.project_set.all() → queryset of Projects
```

```
ForeignKey      → N Projects belong to 1 User
OneToOneField   → 1 Profile belongs to 1 User  
ManyToManyField → N Projects have N Skills
```

---

### Q13 — إيه خيارات الـ `on_delete` وامتى تستخدم كل واحد؟

**الجواب:**
ده بيحدد إيه اللي بيحصل للـ child object لما الـ parent بيتمسح.

```python
# CASCADE → delete the child when the parent is deleted (most common)
task = models.ForeignKey(Project, on_delete=models.CASCADE)
# → لو مسحت الـ Project، كل الـ Tasks اتمسحت

# PROTECT → PREVENT deletion of parent if it has children
category = models.ForeignKey(Category, on_delete=models.PROTECT)
# → لو حاولت تمسح Category اللي فيها products → Database error

# SET_NULL → set the FK to NULL (requires null=True on the field)
owner = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
# → لو الـ User اتمسح، الـ Project بتفضل بس owner=NULL

# SET_DEFAULT → set FK to the default value
manager = models.ForeignKey(User, on_delete=models.SET_DEFAULT, default=1)
# → بيحط default user (المدير مثلاً) بدل الـ user المحذوف

# DO_NOTHING → do nothing — dangerous if DB has integrity constraints
log = models.ForeignKey(User, on_delete=models.DO_NOTHING)
# → بيسيب الـ FK بقيمة قديمة مش موجودة → ممكن يكسر الـ DB!
```

> [!tip] نصيحة الإنترفيو
> القاعدة: `CASCADE` للبيانات اللي ملهاش معنى بدون الـ parent (Tasks without Project). `PROTECT` للبيانات الحساسة اللي مش المفروض تتمسح سهل (Category with products). `SET_NULL` للعلاقات الاختيارية.

---

### Q14 — إيه هو الـ `related_name` وليه مهم؟

**الجواب:**
الـ `related_name` بيحدد إزاي توصل للـ related objects من الـ parent.

```python
class Task(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    # بدون related_name → تستخدم: project.task_set.all()

class Task(models.Model):
    project = models.ForeignKey(
        Project,
        on_delete=models.CASCADE,
        related_name='tasks'   # ← تحدد الاسم بنفسك
    )
    # بعدها → project.tasks.all()  ← أوضح وأقصر

# ── مهم جداً لما في FKs متعددة لنفس الـ model ──
class Project(models.Model):
    owner   = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_projects')
    manager = models.ForeignKey(User, on_delete=models.CASCADE, related_name='managed_projects')
    # لو ما حددتش related_name → Django هيطلع error! لأن هيكون فيه تضارب في الاسم
    # user.project_set هينفع لأيهم؟

# في الـ API
user.owned_projects.all()    # المشاريع اللي الـ user مالكها
user.managed_projects.all()  # المشاريع اللي بيداريها
```

---

### Q15 — إيه الـ `Meta` class في الـ Model وإيه أهم خياراتها؟

**الجواب:**

```python
class Project(models.Model):
    title     = models.CharField(max_length=200)
    budget    = models.DecimalField(max_digits=10, decimal_places=2)
    is_active = models.BooleanField(default=True)
    owner     = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        ordering = ['-created_at']       # default ordering for all querysets
        verbose_name = 'Project'         # human-readable name (singular)
        verbose_name_plural = 'Projects' # human-readable name (plural)
        db_table = 'freelance_projects'  # custom table name (default: appname_modelname)

        unique_together = [['owner', 'title']]  # combo must be unique (legacy way)
        # OR the modern way:
        constraints = [
            models.UniqueConstraint(fields=['owner', 'title'], name='unique_owner_title')
        ]

        indexes = [
            models.Index(fields=['is_active', 'created_at']),  # speed up common queries
            models.Index(fields=['owner', '-budget']),
        ]

        # permissions for the admin
        permissions = [
            ('can_publish_project', 'Can publish a project'),
        ]
```

---

### Q16 — إيه هو الـ `__str__` وليه مهم في الـ Model؟

**الجواب:**

```python
class Project(models.Model):
    title = models.CharField(max_length=200)
    owner = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.title} by {self.owner.username}"

# بدون __str__:
p = Project.objects.first()
print(p)         # → <Project object (1)>  ← مش مفيد

# مع __str__:
print(p)         # → "Freelance Website by ali"  ← واضح ومفيد

# بيتأثر:
# 1. Django Admin → اسم الـ object في الـ list view
# 2. Shell → لما تـ print أي object
# 3. Inline admins → اسم الـ related object
# 4. Serializers → لو استخدمت StringRelatedField
```

> [!tip] نصيحة الإنترفيو
> قاعدة عامة: `__str__` لازم يرجع string واضحة بتعرّف الـ object وتفيد في الـ debugging. مش لازم تكون مفصلة — بس تكون meaningful.

---

### Q17 — إزاي بتعمل custom validation على الـ Model؟

**الجواب:**

```python
from django.core.exceptions import ValidationError
from django.db import models

class Project(models.Model):
    title  = models.CharField(max_length=200)
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    start_date = models.DateField()
    end_date   = models.DateField()

    # field-level validator — يتعمل as a function
    def validate_positive(value):
        if value < 0:
            raise ValidationError("Budget must be positive.")

    budget = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[validate_positive]  # ← attach validator to field
    )

    # object-level validation — override clean()
    def clean(self):
        super().clean()
        if self.start_date and self.end_date:
            if self.end_date <= self.start_date:
                raise ValidationError("End date must be after start date.")

    def save(self, *args, **kwargs):
        self.full_clean()  # ← run all validators + clean() before saving
        super().save(*args, **kwargs)
```

> ⚠️ **انتبه:** `clean()` والـ validators مش بيتشتغلوا تلقائياً لما بتعمل `.save()` — لازم تستدعي `full_clean()` بنفسك. بس لو بتستخدم ModelForm أو DRF Serializer — بتشتغل تلقائياً.

---

## 🔹 Migrations

---

### Q18 — إيه هي الـ Migrations وليه موجودة أصلاً؟

**الجواب:**
تخيّل معايا إن عندك database فيها data حقيقية وقررت تضيف column جديد. إزاي تعمل ده من غير ما تمسح كل الـ data وتبدأ من الأول؟ ده بالظبط اللي الـ Migrations بتحله.

الـ Migrations هي **ملفات Python** بتوصف كل تغيير حصل على الـ database schema — زي git commits بس للـ tables.

```bash
# الـ workflow دايماً:
# 1. بتغير models.py
# 2. بتولّد migration file
python manage.py makemigrations

# 3. بتطبق التغيير على الـ DB
python manage.py migrate
```

```python
# projects/migrations/0002_project_add_is_featured.py
# Django بيولّده تلقائياً — ما بتكتبوش يدوياً (في الغالب)
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('projects', '0001_initial'),  # ← لازم يكون 0001 اتطبق الأول
    ]

    operations = [
        migrations.AddField(
            model_name='project',
            name='is_featured',
            field=models.BooleanField(default=False),
        ),
    ]
```

---

### Q19 — إيه الفرق بين `makemigrations` و`migrate`؟

**الجواب:**
سؤال بيتسأل دايماً للمبتدئين وبعد كده بيتسأله بشكل أعمق.

```
makemigrations → بيفتش في models.py ويولّد ملفات migration بس
                 (مش بيغير في الـ database!)

migrate        → بيطبق الـ migration files على الـ database الفعلية
                 (ده اللي بيغير الـ tables)
```

```bash
# لو عملت makemigrations بس من غير migrate:
# → الـ migration file اتعمل بس الـ table مش اتغيرت
# → لو شغّلت الـ project والـ model فيه field جديد بس مش في الـ DB → error

# ── أوامر مفيدة ──────────────────────────
python manage.py showmigrations             # شوف حالة كل migration
# [X] 0001_initial                         ← applied
# [ ] 0002_project_add_is_featured         ← not applied yet

python manage.py migrate projects 0001     # rollback: go back to migration 0001
python manage.py migrate projects zero     # rollback ALL migrations for the app
python manage.py sqlmigrate projects 0002  # show the SQL without running it
```

> [!warning] انتبه
> أكتر غلطة: بتعمل `makemigrations` وبعدين مش بتعمل `migrate` وبعدين تتعجب ليه الـ database مش بتتغير. الاتنين لازم يتعملوا مع بعض.

---

### Q20 — إيه هي الـ Data Migration وامتى تستخدمها؟

**الجواب:**
الـ Data Migration مش بس بتغير الـ schema (الـ structure) — بتشغّل كود Python عشان **تتعامل مع data فعلية** في الـ database.

```python
# مثال: عندي column جديد "status" وعايز أعبّيه بقيمة default حسب conditions

from django.db import migrations

def set_initial_status(apps, schema_editor):
    # استخدام apps.get_model بدل الـ import المباشر
    # ده مهم عشان الـ model هنا ممكن يختلف عن الـ current model
    Project = apps.get_model('projects', 'Project')

    for project in Project.objects.all():
        if project.budget > 10000:
            project.status = 'premium'
        else:
            project.status = 'standard'
        project.save()

def reverse_status(apps, schema_editor):
    # كيف ترجع للوراء — اكتبها دايماً للأمان
    Project = apps.get_model('projects', 'Project')
    Project.objects.update(status='')

class Migration(migrations.Migration):
    dependencies = [('projects', '0003_add_status_field')]

    operations = [
        migrations.RunPython(set_initial_status, reverse_status),
    ]
```

> [!warning] انتبه
> في الـ Data Migration، استخدم دايماً `apps.get_model()` مش `from projects.models import Project`. عشان لو الـ model اتغير بعد كده، الـ migration القديمة لازم تشتغل على النسخة القديمة من الـ model.

---

### Q21 — إزاي ترجع migration للوراء (Rollback)؟

**الجواب:**

```bash
# الـ rollback بيشتغل بعكس الـ operations في الـ migration file

# رجّع لـ migration معينة (undo كل اللي بعدها)
python manage.py migrate projects 0002
# → هيعمل unapply لـ 0003, 0004, etc. ويرجع للـ 0002

# رجّع كل الـ migrations للـ app دي
python manage.py migrate projects zero
# → هيرجع للـ zero-state (مفيش tables)

# لو الـ migration ليها reverse_code معمولة:
# migrations.RunPython(forward_func, backward_func)  ← الـ backward_func هي اللي بتتشغّل

# لو الـ migration معملهاش reverse:
# migrations.RunPython(forward_func, migrations.RunPython.noop)
# ← noop يعني "عمل rollback بدون ما تعمل حاجة" — مش هيرمي error بس هيسيب الـ data زي ما هي
```

---

## 🔹 ORM والـ QuerySets

---

### Q22 — إيه هو الـ ORM وإيه مميزاته؟

**الجواب:**
الـ ORM (Object-Relational Mapper) بيخليك تتعامل مع الـ database بـ Python بدل SQL.

```python
# بدون ORM — SQL مباشر
cursor.execute("SELECT * FROM projects_project WHERE is_active = TRUE AND budget > 1000")

# مع Django ORM — Python نقي
Project.objects.filter(is_active=True, budget__gt=1000)
```

المميزات:
- **Database agnostic**: نفس الكود بيشتغل على SQLite, PostgreSQL, MySQL
- **Security**: بيحمي من SQL Injection تلقائياً
- **Productivity**: أسرع في الكتابة والقراءة
- **Maintainability**: لو غيّرت الـ model → migration → مش محتاج تغير SQL

> [!tip] نصيحة الإنترفيو
> لو سألوك "هل ORM أبطأ من SQL مباشر؟" — الإجابة: أحياناً أيوه. بس في الغالب الفرق مش ملحوظ. والـ benefit في الـ security والـ maintainability أكبر. للحالات الحساسة فيه `raw()` و`connection.cursor()`.

---

### Q23 — إيه هو الـ QuerySet وهو lazy ازاي؟

**الجواب:**
الـ QuerySet هو **وصف لاستعلام** — مش نتيجة الاستعلام. يعني مش بيروح للـ database غير لما **تحتاج النتيجة فعلاً**.

```python
# هنا ما حصلش SQL query خالص
qs = Project.objects.filter(is_active=True).order_by('-budget')

# لسه مفيش SQL
qs2 = qs.filter(owner=user)

# هنا بس حصل SQL — لما احتجنا النتيجة فعلاً
for p in qs2:              # ← تقييم هنا
    print(p.title)

# أو
list(qs2)                  # ← تقييم
qs2[0]                     # ← تقييم
len(qs2)                   # ← تقييم
bool(qs2)                  # ← تقييم
```

الـ lazy evaluation مهمة عشان:
```python
# تقدر تبني الاستعلام على مراحل من غير ما تحوّل للـ DB في كل مرحلة
def get_projects(request):
    qs = Project.objects.all()

    if request.GET.get('active'):
        qs = qs.filter(is_active=True)    # لسه مفيش query

    if request.GET.get('owner'):
        qs = qs.filter(owner=request.user) # لسه مفيش query

    return qs.order_by('-created_at')[:10]  # هنا بس query واحدة بتعمل كل ده
```

---

### Q24 — إيه الفرق بين `get()`, `filter()`, `first()`?

**الجواب:**

```python
# get() → بترجع object واحد بالظبط
# إذا مش موجود → DoesNotExist exception
# إذا أكتر من واحد → MultipleObjectsReturned exception
project = Project.objects.get(pk=5)
project = Project.objects.get(id=5, owner=user)

# filter() → بترجع QuerySet (ممكن فاضية أو فيها عناصر)
# مش بترمي exception لو مفيش نتيجة
projects = Project.objects.filter(is_active=True)
# returns: <QuerySet [<Project: ...>, ...]>  or  <QuerySet []>

# first() → بترجع أول object أو None
project = Project.objects.filter(is_active=True).first()
# returns: <Project: ...>  or  None

# ── متى تستخدم إيه ──────────────────────────────────────
# get()    → لما متأكد الـ object موجود ومش مكرر (زي جلب بالـ pk)
# first()  → لما مش متأكد أو محتاج أحسن من exception
# filter() → لما محتاج list من النتائج
```

> ⚠️ **انتبه:** حاجة شائعة: استخدام `get()` من غير try/except. لو الـ object مش موجود → `DoesNotExist` exception هتكسر الـ view. استخدم `get_object_or_404()` في الـ views أو `filter().first()`.

---

### Q25 — إيه أهم الـ Lookup Types في Django ORM؟

**الجواب:**
الـ lookup types بتجي بعد `__` في الـ filter.

```python
# ── Text lookups ─────────────────────────────────────────
Project.objects.filter(title__exact='Website')       # = 'Website' (default)
Project.objects.filter(title__iexact='website')      # case-insensitive =
Project.objects.filter(title__contains='Web')        # LIKE '%Web%'
Project.objects.filter(title__icontains='web')       # LIKE '%web%' case-insensitive
Project.objects.filter(title__startswith='Free')     # LIKE 'Free%'
Project.objects.filter(title__endswith='API')        # LIKE '%API'

# ── Numeric lookups ───────────────────────────────────────
Project.objects.filter(budget__gt=1000)              # > 1000
Project.objects.filter(budget__gte=1000)             # >= 1000
Project.objects.filter(budget__lt=5000)              # < 5000
Project.objects.filter(budget__range=(1000, 5000))   # BETWEEN

# ── Null lookup ────────────────────────────────────────────
Project.objects.filter(end_date__isnull=True)        # IS NULL
Project.objects.filter(end_date__isnull=False)       # IS NOT NULL

# ── Date lookups ───────────────────────────────────────────
Project.objects.filter(created_at__year=2024)
Project.objects.filter(created_at__month=3)
Project.objects.filter(created_at__date='2024-03-15')

# ── Related model lookups — traverse __ across relations ──
Project.objects.filter(owner__username='ali')        # ForeignKey traversal
Project.objects.filter(owner__profile__city='Cairo') # Multi-level traversal
Project.objects.filter(skills__name='Python')        # ManyToMany traversal

# ── List lookup ────────────────────────────────────────────
Project.objects.filter(id__in=[1, 2, 3, 4])         # IN (1,2,3,4)
```

---

### Q26 — إزاي بتعمل OR queries في Django ORM؟

**الجواب:**
الـ `filter()` الـ default بيعمل AND — لو محتاج OR بتستخدم **Q objects**.

```python
from django.db.models import Q

# بدون Q — ده AND: is_active AND budget > 1000
Project.objects.filter(is_active=True, budget__gt=1000)

# بـ Q — ده OR: is_active OR budget > 1000
Project.objects.filter(
    Q(is_active=True) | Q(budget__gt=1000)
)

# AND مع OR
Project.objects.filter(
    Q(is_active=True) & (Q(title__icontains='web') | Q(title__icontains='api'))
)

# NOT
Project.objects.filter(~Q(is_active=False))  # ← ~ يعني NOT

# real world — search endpoint
def search_projects(query):
    if not query:
        return Project.objects.all()

    return Project.objects.filter(
        Q(title__icontains=query)       |
        Q(description__icontains=query) |
        Q(owner__username__icontains=query)
    ).distinct()  # ← distinct عشان المشروع ممكن يتطابق في أكتر من field
```

---

### Q27 — إيه الفرق بين `annotate()` و`aggregate()`؟

**الجواب:**
الاتنين بيعملوا حسابات، بس الفرق في **اللي بيرجعوه**.

```python
from django.db.models import Count, Sum, Avg, Max, Min

# aggregate() → بيرجع DICT واحد — إجمالي على كل الـ queryset
result = Project.objects.aggregate(
    total_projects=Count('id'),
    total_budget=Sum('budget'),
    avg_budget=Avg('budget'),
)
print(result)
# → {'total_projects': 25, 'total_budget': Decimal('125000'), 'avg_budget': Decimal('5000')}

# annotate() → بيضيف field محسوب لكل object في الـ queryset
projects = Project.objects.annotate(
    task_count=Count('tasks'),         # ← كل project هياخد task_count
    total_proposals=Count('proposals')
)

for p in projects:
    print(p.title, p.task_count)       # ← task_count متاح على كل object
    # → "Freelance Website 12"
```

```
aggregate() → single result dict    (حساب على الكل)
annotate()  → adds field to each object  (حساب لكل صف)
```

---

### Q28 — إيه الفرق بين `select_related` و`prefetch_related`؟

**الجواب:**
الاتنين بيحلوا نفس المشكلة (N+1) بطريقتين مختلفتين.

```python
# select_related → SQL JOIN — query واحدة
# للـ ForeignKey والـ OneToOneField فقط
projects = Project.objects.select_related('owner').all()
# SQL: SELECT projects.*, auth_user.* FROM projects JOIN auth_user ON owner_id = auth_user.id
# accessing project.owner → no extra DB query!

# prefetch_related → queries منفصلة + Python join
# للـ ManyToManyField والـ reverse FK
projects = Project.objects.prefetch_related('skills', 'tasks').all()
# SQL 1: SELECT * FROM projects
# SQL 2: SELECT * FROM skills WHERE id IN (...)
# SQL 3: SELECT * FROM tasks WHERE project_id IN (...)
# Django joins them in Python — accessing project.skills.all() → no extra query!

# combine both
projects = Project.objects.select_related('owner').prefetch_related('skills').all()
```

| | `select_related` | `prefetch_related` |
|---|---|---|
| العلاقة | FK, OneToOne | M2M, reverse FK |
| SQL | JOIN واحد | queries منفصلة |
| النتيجة | أسرع لعلاقة واحدة | أفضل للـ M2M |

---

### Q29 — إيه هو الـ N+1 Problem؟ وكيف تكشفه وتحله؟

**الجواب:**
ده أهم مشكلة performance في Django وبيتسألوا عليها كتير.

```python
# ── المشكلة ───────────────────────────────────────────────
projects = Project.objects.all()  # → 1 query

for project in projects:
    print(project.owner.username)
    # ← 1 query PER project!
    # لو في 100 project → 101 queries = N+1 problem
```

```python
# ── الحل ──────────────────────────────────────────────────
# select_related — يجيب الـ owner مع الـ projects في query واحدة
projects = Project.objects.select_related('owner').all()  # → 1 query فقط

for project in projects:
    print(project.owner.username)  # ← no extra query!
```

**إزاي تكشفه؟**
```python
# install django-debug-toolbar — بيوريك كل query في كل request
# أو في الـ shell:
from django.db import connection, reset_queries
from django.conf import settings
settings.DEBUG = True

reset_queries()
projects = list(Project.objects.all())
for p in projects: _ = p.owner.username
print(len(connection.queries))  # → 101 queries!

reset_queries()
projects = list(Project.objects.select_related('owner').all())
for p in projects: _ = p.owner.username
print(len(connection.queries))  # → 1 query ✅
```

---

### Q30 — إيه الفرق بين `.update()` و`.save()` في الـ ORM؟

**الجواب:**

```python
# .save() → يجيب الـ object، يعدّله، يحفظه — 2 queries + triggers events
project = Project.objects.get(pk=1)   # query 1: SELECT
project.budget = 7500
project.save()                         # query 2: UPDATE
# → triggers: signals (post_save), auto_now fields, full_clean() if called

# .update() → UPDATE مباشر في الـ DB — 1 query، بدون fetch
Project.objects.filter(owner=user).update(is_active=False)
# → 1 query فقط: UPDATE projects SET is_active=0 WHERE owner_id=X
# سريع جداً لو بتعمل bulk update
```

| | `.save()` | `.update()` |
|---|---|---|
| Queries | 2 (SELECT + UPDATE) | 1 (UPDATE مباشر) |
| Signals | post_save بيتشغّل ✅ | مش بيتشغّل ❌ |
| auto_now | بيتحدث ✅ | مش بيتحدث ❌ |
| Validation | بيتشغّل لو فعّلته | مش بيتشغّل |
| مناسب لـ | تعديل object واحد | bulk updates |

> ⚠️ **انتبه:** `.update()` مش بيشغّل الـ signals — يعني لو عندك `post_save` signal مهم (زي إرسال notification)، استخدم `.save()`.

---

### Q31 — إيه هو الـ `values()` و`values_list()` وامتى تستخدمهم؟

**الجواب:**

```python
# by default — queryset بيرجع model instances (objects)
projects = Project.objects.all()
# → [<Project: Website>, <Project: API>, ...]

# values() → بيرجع list of dicts — أسرع لو مش محتاج model methods
projects = Project.objects.values('id', 'title', 'budget')
# → [{'id': 1, 'title': 'Website', 'budget': 5000}, ...]

# values_list() → بيرجع list of tuples — أسرع من values()
projects = Project.objects.values_list('id', 'title')
# → [(1, 'Website'), (2, 'API'), ...]

# flat=True → بيرجع flat list (لو column واحد بس)
ids = Project.objects.values_list('id', flat=True)
# → [1, 2, 3, 4, 5]  ← مش tuples، list عادية

# ── الاستخدام العملي ──────────────────────────────────────
# بدل ما تجيب كل الـ object عشان تاخد الـ ids بس
ids = Project.objects.filter(is_active=True).values_list('id', flat=True)
# → بعدين ممكن تستخدمهم في query تانية:
Proposal.objects.filter(project_id__in=ids)
```

---

## 🔹 Views — FBV و CBV

---

### Q32 — إيه الفرق بين FBV وCBV؟ وامتى تستخدم كل واحد؟

**الجواب:**

```python
# FBV — Function Based View
def project_list(request):
    projects = Project.objects.all()
    return render(request, 'list.html', {'projects': projects})

# CBV — Class Based View (نفس الوظيفة)
from django.views.generic import ListView

class ProjectList(ListView):
    model = Project
    template_name = 'list.html'
    context_object_name = 'projects'
```

| | FBV | CBV |
|---|---|---|
| وضوح الكود | أسهل في القراءة | أكثر complexity |
| تكرار الكود | أكتر تكرار | inheritance يحل التكرار |
| Mixins | مش موجودة (بس decorators) | موجودة ✅ |
| مناسب لـ | logic بسيط، custom views | CRUD standard operations |

```
استخدم FBV لما: الـ logic خاص جداً أو مش بيناسب الـ generic views
استخدم CBV لما: بتعمل CRUD عادي أو عايز تستخدم الـ generic views
```

---

### Q33 — إيه هو `render()` و`get_object_or_404()`؟

**الجواب:**

```python
from django.shortcuts import render, get_object_or_404

# render() → shortcut بيعمل 3 خطوات في واحدة:
# 1. بياخد الـ template
# 2. بيعمل render مع الـ context
# 3. بيرجع HttpResponse

def project_detail(request, pk):
    project = Project.objects.get(pk=pk)
    return render(request, 'projects/detail.html', {'project': project})
    # equivalent to:
    # from django.template.loader import render_to_string
    # html = render_to_string('projects/detail.html', {'project': project}, request=request)
    # return HttpResponse(html)

# get_object_or_404() → بيعمل get() بس لو مش موجود بيرجع 404 response
def project_detail(request, pk):
    project = get_object_or_404(Project, pk=pk, is_active=True)
    # ← إذا مش موجود: Http404 exception → Django بيرجع 404 response
    # بدل ما تكتب:
    # try:
    #     project = Project.objects.get(pk=pk, is_active=True)
    # except Project.DoesNotExist:
    #     raise Http404("Project not found")
    return render(request, 'projects/detail.html', {'project': project})
```

---

### Q34 — إيه الـ Generic CBVs وإزاي بتشتغل؟

**الجواب:**

```python
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView

# ListView → GET /projects/ — بيجيب list من objects وبيعملها render
class ProjectList(ListView):
    model = Project
    template_name = 'projects/list.html'
    context_object_name = 'projects'  # اسم الـ variable في الـ template (default: object_list)
    paginate_by = 10                  # automatic pagination

    def get_queryset(self):
        # override the default queryset
        return Project.objects.filter(is_active=True).select_related('owner')

# DetailView → GET /projects/5/ — بيجيب object واحد
class ProjectDetail(DetailView):
    model = Project
    context_object_name = 'project'  # default: object

# CreateView → GET (show form) + POST (save) /projects/create/
class ProjectCreate(CreateView):
    model = Project
    fields = ['title', 'description', 'budget']
    success_url = reverse_lazy('project-list')

    def form_valid(self, form):
        form.instance.owner = self.request.user  # set owner before saving
        return super().form_valid(form)

# UpdateView → GET (show form) + POST (update) /projects/5/edit/
class ProjectUpdate(UpdateView):
    model = Project
    fields = ['title', 'description', 'budget']
    # default template: projects/project_form.html

# DeleteView → GET (confirm) + POST (delete) /projects/5/delete/
class ProjectDelete(DeleteView):
    model = Project
    success_url = reverse_lazy('project-list')
    # default template: projects/project_confirm_delete.html
```

---

### Q35 — إيه الـ Mixins وإزاي بتستخدمها مع CBVs؟

**الجواب:**
الـ Mixin هي class بتضيف behavior — مش بتستخدمها لوحدها، بتضيفها مع الـ generic view عن طريق multiple inheritance.

```python
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin

# LoginRequiredMixin → redirect to login if not authenticated
class ProjectCreate(LoginRequiredMixin, CreateView):
    model = Project
    fields = ['title', 'budget']
    login_url = '/auth/login/'        # where to redirect if not logged in

# UserPassesTestMixin → run a custom test, deny if False
class ProjectUpdate(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Project
    fields = ['title', 'budget']

    def test_func(self):
        # return True to allow, False to deny (403)
        project = self.get_object()
        return project.owner == self.request.user

# ← ترتيب الـ Mixins مهم!
# Django بيقرأهم من اليسار لليمين (MRO)
# LoginRequired لازم يجي قبل UserPassesTest
```

---

### Q36 — إزاي بتتعامل مع الـ HTTP Methods في الـ FBV؟

**الجواب:**

```python
from django.views.decorators.http import require_GET, require_POST, require_http_methods
from django.contrib.auth.decorators import login_required

# ── Using if/elif ─────────────────────────────────────────────
def project_form(request, pk=None):
    if request.method == 'GET':
        form = ProjectForm()
        return render(request, 'form.html', {'form': form})

    elif request.method == 'POST':
        form = ProjectForm(request.POST, request.FILES)  # FILES for file uploads
        if form.is_valid():
            project = form.save(commit=False)
            project.owner = request.user
            project.save()
            return redirect('project-list')
        return render(request, 'form.html', {'form': form})

    return HttpResponse(status=405)  # Method Not Allowed

# ── Using decorators — cleaner ─────────────────────────────────
@require_GET
def project_list(request):
    pass  # only GET allowed — Django returns 405 for anything else

@login_required
@require_POST
def delete_project(request, pk):
    project = get_object_or_404(Project, pk=pk, owner=request.user)
    project.delete()
    return redirect('project-list')
```

---

### Q37 — إيه الـ Context وإزاي بتضيف data للـ Template؟

**الجواب:**

```python
# Context = Python dict بيتبعت للـ template
# كل key بيبقى variable في الـ template

# ── في FBV ────────────────────────────────────────────────────
def project_list(request):
    projects = Project.objects.filter(is_active=True)
    return render(request, 'list.html', {
        'projects': projects,        # → {{ projects }} في الـ template
        'total': projects.count(),   # → {{ total }}
        'user_is_owner': True,       # → {% if user_is_owner %}
    })

# ── في CBV — override get_context_data() ──────────────────────
class ProjectList(ListView):
    model = Project
    template_name = 'list.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)  # ← لازم تستدعي super() الأول
        context['total'] = self.get_queryset().count()
        context['featured'] = Project.objects.filter(is_featured=True)[:3]
        return context
```

---

### Q38 — إيه الفرق بين `redirect()` و`HttpResponseRedirect()`؟

**الجواب:**

```python
from django.shortcuts import redirect
from django.http import HttpResponseRedirect
from django.urls import reverse

# HttpResponseRedirect — الطريقة الأساسية
return HttpResponseRedirect('/projects/')          # hardcoded URL — مش كويس
return HttpResponseRedirect(reverse('project-list'))  # better — by name

# redirect() — shortcut أسهل وأوضح
return redirect('project-list')                   # by URL name
return redirect('project-detail', pk=5)           # with args
return redirect('/projects/')                     # by URL string
return redirect(project)                          # by object — بيستدعي get_absolute_url()

# الـ status code الـ default = 302 (temporary redirect)
# لو عايز 301 (permanent):
return redirect('home', permanent=True)

# الاستخدام الأشهر بعد form submission:
def create_project(request):
    if request.method == 'POST':
        form = ProjectForm(request.POST)
        if form.is_valid():
            project = form.save()
            return redirect('project-detail', pk=project.pk)  # ← redirect بعد نجاح
```

---

## 🔹 URLs والـ Routing

---

### Q39 — إزاي Django بيطابق الـ URLs؟

**الجواب:**

```python
# Django بيقرأ urlpatterns من ROOT_URLCONF في settings.py
# بعدين بيجرب كل pattern واحدة واحدة من فوق لتحت
# أول pattern تتطابق → بيستدعي الـ view المرتبطة بيها

# freelance_api/urls.py
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('projects.urls')),   # ← يروّح للـ projects/urls.py
]

# projects/urls.py
app_name = 'projects'  # namespace — مهم جداً لتجنب تعارض الأسماء

urlpatterns = [
    path('projects/', views.ProjectList.as_view(), name='project-list'),
    # ← exact match: /api/projects/

    path('projects/<int:pk>/', views.ProjectDetail.as_view(), name='project-detail'),
    # ← captures integer: /api/projects/5/ → pk=5

    path('projects/<slug:slug>/', views.ProjectBySlug.as_view(), name='project-slug'),
    # ← captures slug: /api/projects/my-website/ → slug='my-website'

    path('projects/<uuid:uid>/', views.ProjectByUUID.as_view(), name='project-uuid'),
    # ← captures UUID: /api/projects/550e8400-e29b-41d4-a716-446655440000/

    path('projects/<str:code>/', views.ProjectByCode.as_view(), name='project-code'),
    # ← captures any string (but /, ?, #)
]
```

---

### Q40 — إيه الفرق بين `reverse()` و`reverse_lazy()`؟

**الجواب:**

```python
from django.urls import reverse, reverse_lazy

# reverse() → بيحسب الـ URL فوراً عند الاستدعاء
url = reverse('projects:project-detail', kwargs={'pk': 5})
# → '/api/projects/5/'

# بتستخدمها في functions وـ methods — بيتشغّل في runtime
def get_project_url(project):
    return reverse('projects:project-detail', kwargs={'pk': project.pk})

# reverse_lazy() → بيحسب الـ URL بـ lazy — مش فوراً
# بتستخدمها في class attributes — بيتعمل evaluate لما يتحتاج فعلاً
class ProjectCreate(CreateView):
    success_url = reverse_lazy('projects:project-list')  # ✅
    # لو استخدمت reverse() هنا → error! عشان الـ URLs مش loaded لما الـ class بيتعرّف
```

> [!tip] نصيحة الإنترفيو
> القاعدة: في الـ functions → `reverse()`. في الـ class attributes أو module level → `reverse_lazy()`. لو اتعكستوا → `ImproperlyConfigured` error.

---

### Q41 — إيه الـ URL Namespacing وليه مهم؟

**الجواب:**

```python
# المشكلة بدون namespace:
# عندك 'project-list' في app projects وكمان في app proposals
# Django مش عارف تقصد أيهم!

# الحل — app namespace
# projects/urls.py
app_name = 'projects'
urlpatterns = [
    path('', views.ProjectList.as_view(), name='project-list'),
]

# proposals/urls.py
app_name = 'proposals'
urlpatterns = [
    path('', views.ProposalList.as_view(), name='project-list'),  # نفس الاسم!
]

# الاستخدام مع namespace
reverse('projects:project-list')    # → يروح لـ projects app
reverse('proposals:project-list')   # → يروح لـ proposals app

# في الـ template
{% url 'projects:project-list' %}
{% url 'proposals:project-list' %}
```

---

### Q42 — إيه هي الـ CSRF وإزاي Django بيحميها؟

**الجواب:**
الـ CSRF (Cross-Site Request Forgery) هي هجمة: موقع تاني بيخلي الـ user يبعت request لموقعك من غير ما يعرف.

```python
# Django بيحمي بـ CSRF Token:
# 1. لما المستخدم يفتح الـ form → Django بيبعت cookie فيه token سري
# 2. لما المستخدم يـ submit → الـ form لازم تبعت نفس الـ token
# 3. Django بيتأكد إن الـ token صح → لو مش موجود → 403 Forbidden

# في أي form → لازم تحط {% csrf_token %}
```

```html
<form method="post">
    {% csrf_token %}  <!-- ← بيولّد: <input type="hidden" name="csrfmiddlewaretoken" value="..."> -->
    {{ form.as_p }}
    <button type="submit">Save</button>
</form>
```

```python
# في DRF:
# الـ API clients (mobile, frontend) مش بيستخدموا cookies عادةً
# عشان كده DRF بيستخدم Token أو JWT authentication بدل CSRF

# لو هتستخدم SessionAuthentication في DRF → محتاج CSRF
# لو هتستخدم TokenAuthentication أو JWT → مش محتاج CSRF للـ API
```

---

## 🔹 Forms والـ Auth

---

### Q43 — إيه الفرق بين `Form` و`ModelForm`؟

**الجواب:**

```python
from django import forms
from .models import Project

# Form — يدوي: بتعرّف كل field بنفسك
class ContactForm(forms.Form):
    name    = forms.CharField(max_length=100)
    email   = forms.EmailField()
    message = forms.CharField(widget=forms.Textarea)
    # مش مربوط بـ model — لازم تعمل save() بنفسك

# ModelForm — تلقائي: بيأخد الـ fields من الـ Model
class ProjectForm(forms.ModelForm):
    class Meta:
        model = Project
        fields = ['title', 'description', 'budget']
        # أو: exclude = ['owner', 'created_at']

    # تقدر تتحكم في الـ widgets
    widgets = {
        'description': forms.Textarea(attrs={'rows': 4}),
    }
    # تقدر تضيف validation زي form العادي
    def clean_budget(self):
        budget = self.cleaned_data['budget']
        if budget < 0:
            raise forms.ValidationError("Budget can't be negative.")
        return budget
```

```python
# الاستخدام في الـ view
def create_project(request):
    if request.method == 'POST':
        form = ProjectForm(request.POST)

        if form.is_valid():         # ← runs all validators
            project = form.save(commit=False)  # ← don't save to DB yet
            project.owner = request.user
            project.save()         # ← now save
            form.save_m2m()        # ← save ManyToMany fields (needed when commit=False)
            return redirect('project-list')
    else:
        form = ProjectForm()
    return render(request, 'form.html', {'form': form})
```

---

### Q44 — إزاي بتعمل Custom User Model وليه مهم تعملها من الأول؟

**الجواب:**
ده من أهم القرارات في أي Django project — ولو فاتك هتتعب.

```python
# accounts/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # AbstractUser already has: username, email, password, is_active, is_staff, etc.
    # just add your custom fields

    bio           = models.TextField(blank=True)
    phone         = models.CharField(max_length=20, blank=True)
    is_freelancer = models.BooleanField(default=False)
    avatar        = models.ImageField(upload_to='avatars/', blank=True, null=True)

    def __str__(self):
        return self.email

# settings.py — MUST be set BEFORE the first migration!
AUTH_USER_MODEL = 'accounts.User'

# في الكود كله — مش بتعمل import User مباشرة!
from django.contrib.auth import get_user_model
User = get_user_model()  # ← بيجيب الـ custom User model تلقائياً

# في الـ models الثانية
from django.conf import settings
owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
# ← أحسن من import User مباشرة — مش بيعمل circular imports
```

> ⚠️ **انتبه:** لو نسيت تعمل Custom User من البداية وبدأت تعمل migrations → هتكون في ورطة كبيرة. الحل الصح وقتها هو إنك تعمل project جديد. ده السبب اللي بيخلي الـ senior developers يعملوها دايماً أول خطوة.

---

### Q45 — إيه هي الـ Django Permissions وإزاي بتشتغل؟

**الجواب:**

```python
# Django بيولّد 4 permissions تلقائياً لكل model:
# app_label.add_modelname
# app_label.view_modelname
# app_label.change_modelname
# app_label.delete_modelname

# مثال: للـ Project model في الـ projects app:
# projects.add_project
# projects.view_project
# projects.change_project
# projects.delete_project

# ── Check permissions in views ─────────────────────────────────
from django.contrib.auth.decorators import permission_required

@permission_required('projects.add_project', raise_exception=True)
def create_project(request):
    pass  # only users with 'add_project' permission can access

# في الـ view
if request.user.has_perm('projects.change_project'):
    # allow editing
    pass

# ── Custom permissions ─────────────────────────────────────────
class Project(models.Model):
    class Meta:
        permissions = [
            ('can_publish_project', 'Can publish projects to the homepage'),
            ('can_feature_project', 'Can mark projects as featured'),
        ]

# ── Groups — مجموعة من permissions ──────────────────────────────
# Freelancers group: can add_proposal, view_project
# Clients group: can add_project, delete_proposal

# ← Admin → Groups → Add Group → add permissions
```

---

### Q46 — إيه الفرق بين Authentication وAuthorization؟

**الجواب:**

```
Authentication (التحقق من الهوية) → من إنت؟
Authorization  (الصلاحية)         → مسموح لك بإيه؟
```

```python
# Authentication — إثبات الهوية
from django.contrib.auth import authenticate, login

user = authenticate(request, username='ali', password='secret')
if user is not None:
    login(request, user)  # creates session → request.user = user
    # now the user is "authenticated"

# Authorization — بعد ما عرفنا مين هو
@login_required                              # must be authenticated
@permission_required('projects.add_project') # must have specific permission
def create_project(request):
    # is the user the OWNER of this specific project?
    project = get_object_or_404(Project, pk=pk)
    if project.owner != request.user:
        return HttpResponse(status=403)  # Forbidden — authenticated but not authorized
```

```
Login (authentication) → أنت ادخلت؟
Permission (authorization) → مسموح لك تعمل ده؟
Ownership check (authorization) → ده بتاعك؟
```

---

### Q47 — إيه الـ Django Sessions وإزاي بتشتغل؟

**الجواب:**

```python
# Session = data مخزّنة على الـ server مرتبطة بـ user
# بدلاً من إنك تبعت الـ user ID في كل request (غير آمن)
# Django بيعمل session key عشوائي، بيحطه في cookie، ويحفظ الـ data على السيرفر

# بيتفعّل بـ middleware:
# 'django.contrib.sessions.middleware.SessionMiddleware'

# الاستخدام
def my_view(request):
    # write to session
    request.session['cart'] = {'item_id': 5, 'qty': 2}
    request.session['last_viewed'] = 42

    # read from session
    cart = request.session.get('cart', {})

    # delete from session
    del request.session['last_viewed']

    # clear entire session
    request.session.flush()  # also deletes the session cookie

# Sessions بتتحفظ في:
# Database (default) — django_session table
# Cache (Redis — أسرع)
# File system
# Cookie (encrypted)

# settings.py
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'  # use Redis
SESSION_COOKIE_AGE = 1209600  # 2 weeks in seconds (default)
SESSION_EXPIRE_AT_BROWSER_CLOSE = False
```

---

### Q48 — إيه الفرق بين `@login_required` و`LoginRequiredMixin`؟

**الجواب:**

```python
# @login_required — للـ FBVs فقط (function decorator)
from django.contrib.auth.decorators import login_required

@login_required(login_url='/auth/login/')
def my_view(request):
    pass

# LoginRequiredMixin — للـ CBVs (بتضيفيها في الـ inheritance)
from django.contrib.auth.mixins import LoginRequiredMixin

class MyView(LoginRequiredMixin, ListView):
    login_url = '/auth/login/'
    redirect_field_name = 'next'  # default — adds ?next=/original-url/ to redirect
    model = Project

# مش تقدر تستخدم @login_required على CBV مباشرة:
# ❌ @login_required  ← بيتطبق على الـ class مش على الـ methods
# class MyView(ListView): ...

# الصح لو عايز تستخدم decorator على CBV:
from django.utils.decorators import method_decorator

@method_decorator(login_required, name='dispatch')  # applies to all HTTP methods
class MyView(ListView):
    model = Project
```

---

## 🔹 Django REST Framework

---

### Q49 — إيه هو DRF وليه نستخدمه بدل Django العادي؟

**الجواب:**
الـ DRF (Django REST Framework) هو library بتضيف فوق Django عشان تبني APIs بشكل محترف.

بدون DRF — لو عايز تعمل API view:
```python
# ده كتير جداً لمجرد endpoint بسيط
import json
from django.http import JsonResponse
from django.views import View

class ProjectListView(View):
    def get(self, request):
        projects = Project.objects.all()
        data = []
        for p in projects:
            data.append({
                'id': p.id,
                'title': p.title,
                'budget': str(p.budget),  # Decimal → str manually
                'owner': p.owner.username,
                'created_at': p.created_at.isoformat(),
            })
        return JsonResponse({'results': data})
```

مع DRF — نفس الحاجة:
```python
class ProjectListView(generics.ListAPIView):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    # ← 3 سطور فقط! والـ DRF بيعمل باقي الحاجات
```

DRF بيضيف:
- **Serializers** → object → JSON + validation
- **Generic Views** → CRUD جاهز
- **ViewSets + Routers** → URLs تلقائية
- **Authentication** → Token, JWT, Session
- **Permissions** → access control
- **Pagination** → تلقائي
- **Browsable API** → واجهة تجريبية في الـ browser

---

### Q50 — إيه الفرق بين `Serializer` و`ModelSerializer`؟

**الجواب:**

```python
from rest_framework import serializers
from .models import Project

# Serializer — يدوي: بتعرّف كل field بنفسك + create() و update()
class ProjectSerializer(serializers.Serializer):
    id      = serializers.IntegerField(read_only=True)
    title   = serializers.CharField(max_length=200)
    budget  = serializers.DecimalField(max_digits=10, decimal_places=2)

    def create(self, validated_data):
        return Project.objects.create(**validated_data)  # ← بتكتبها يدوياً

    def update(self, instance, validated_data):
        instance.title  = validated_data.get('title', instance.title)
        instance.budget = validated_data.get('budget', instance.budget)
        instance.save()
        return instance

# ModelSerializer — تلقائي: بياخد الـ fields من الـ Model
class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = ['id', 'title', 'budget', 'owner', 'created_at']
        read_only_fields = ['id', 'created_at']
        # ← create() و update() بيتعملوا تلقائياً!
```

الغالب 90% من الوقت بتستخدم `ModelSerializer`. بتستخدم `Serializer` بس لما الـ data مش بتيجي من model (زي serializing نتيجة حسابية).

---

### Q51 — إزاي الـ Validation بتشتغل في DRF؟

**الجواب:**

```python
class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = ['title', 'budget', 'start_date', 'end_date']

    # Level 1: field-level validation — method: validate_<fieldname>
    def validate_budget(self, value):
        if value < 0:
            raise serializers.ValidationError("Budget can't be negative.")
        if value > 1_000_000:
            raise serializers.ValidationError("Budget can't exceed 1M.")
        return value  # always return the value!

    # Level 2: object-level validation — cross-field checks
    def validate(self, data):
        start = data.get('start_date')
        end   = data.get('end_date')
        if start and end and end <= start:
            raise serializers.ValidationError({
                'end_date': "End date must be after start date."
            })
        return data

# الـ flow لما بتستدعي serializer.is_valid():
# 1. field-level type checking (built-in: CharField, DecimalField, etc.)
# 2. field-level validators (validators=[...] on the field)
# 3. validate_<fieldname>() methods
# 4. validate() method (cross-field)
# 5. model validators (لو ModelSerializer + unique_together, etc.)
# لو أي خطوة فيهم رمت exception → is_valid() = False، errors في .errors dict
```

---

### Q52 — إيه الفرق بين `APIView`, `Generic Views`, `ViewSets`؟

**الجواب:**
دول 3 مستويات من الـ abstraction في DRF.

```python
# Level 1: APIView — manual control, most flexible
class ProjectList(APIView):
    def get(self, request):
        projects = Project.objects.all()
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ProjectSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(owner=request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

# Level 2: Generic Views — less code, convention over configuration
class ProjectList(generics.ListCreateAPIView):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    # get() and post() are implemented automatically!

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

# Level 3: ViewSet — combines all actions in one class + Router generates URLs
class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    # list, create, retrieve, update, partial_update, destroy → all implemented!
```

```
متى تستخدم إيه؟
APIView       → logic خاص جداً، مش standard CRUD
Generic Views → standard CRUD لـ model واحد
ViewSet       → full REST resource، عايز Router يعمل URLs تلقائياً
```

---

### Q53 — إزاي الـ Router بيشتغل؟ وإيه الـ URLs اللي بيولّدها؟

**الجواب:**

```python
# projects/urls.py
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('projects', views.ProjectViewSet, basename='project')
router.register('skills', views.SkillViewSet, basename='skill')

urlpatterns = [
    path('', include(router.urls)),
]

# الـ URLs اللي DefaultRouter بيولّدها تلقائياً:
# GET    /projects/               → list action
# POST   /projects/               → create action
# GET    /projects/{pk}/          → retrieve action
# PUT    /projects/{pk}/          → update action
# PATCH  /projects/{pk}/          → partial_update action
# DELETE /projects/{pk}/          → destroy action
# GET    /                        → API root (DefaultRouter فقط)

# لو عندك custom actions:
# @action(detail=True, methods=['post'], url_path='activate')
# GET/POST /projects/{pk}/activate/
```

---

### Q54 — إيه الفرق بين `perform_create()` و`create()`؟

**الجواب:**

```python
# create() — الـ method الأساسية في CreateModelMixin
# بتتحكم في الـ flow كامل: validation, saving, response
def create(self, request, *args, **kwargs):
    serializer = self.get_serializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    self.perform_create(serializer)         # ← DRF بيفصل الـ saving هنا
    headers = self.get_success_headers(serializer.data)
    return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

# perform_create() — الـ hook البتاخده عشان تضيف logic بسيط قبل الـ save
# بتـ override بس الـ saving step مش الـ response
def perform_create(self, serializer):
    # هنا بتضيف extra data مش جاية من الـ request
    serializer.save(
        owner=self.request.user,           # set from request
        status='pending',                  # set default
        created_by_ip=self.request.META.get('REMOTE_ADDR')
    )
```

> [!tip] نصيحة الإنترفيو
> القاعدة: لو بس عايز تضيف data على الـ object قبل الـ save → `perform_create()`. لو عايز تغير الـ response كلها أو الـ validation flow → `create()`.

---

### Q55 — إيه الفرق بين Token Authentication وJWT؟

**الجواب:**

| | Token Auth (DRF) | JWT |
|---|---|---|
| التخزين | في الـ Database | لا — stateless |
| الانتهاء | مش بينتهي (حتى يتمسح) | ينتهي (expiry في الـ token نفسه) |
| Revoke | تمسحه من الـ DB | صعب (يحتاج blacklist) |
| Size | صغير | أكبر (Base64 encoded) |
| كتابة | `rest_framework.authtoken` | `djangorestframework-simplejwt` |
| مناسب لـ | server-to-server، simple apps | mobile apps، SPAs |

```python
# Token Auth — client sends:
# Authorization: Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b

# JWT — client sends:
# Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# JWT flow:
# 1. POST /auth/login/ → {access: "...", refresh: "..."}
# 2. Client uses access token in every request (expires in 5 min)
# 3. When access expires → POST /auth/refresh/ with refresh token → new access token
# 4. refresh token expires in 1 day → user must login again
```

---

## 🔹 15 سؤال صعبين — متوسط

---

### Q56 — إيه الـ `F()` Expression وليه أهم من ما تتخيل؟

**الجواب:**
الـ `F()` object بيخليك تشاور على **قيمة field في الـ database** من غير ما تجيبها للـ Python.

```python
from django.db.models import F

# ── المشكلة بدون F() ──────────────────────────────────────────
project = Project.objects.get(pk=1)    # query 1: SELECT
project.views_count += 1              # Python increment
project.save()                         # query 2: UPDATE
# ← لو اتنين requests حصلوا في نفس الوقت → race condition!
# كلاهما قرأ views_count=100، كلاهم save بـ 101 → الصح 102 اتضيع!

# ── الحل: F() ─────────────────────────────────────────────────
Project.objects.filter(pk=1).update(views_count=F('views_count') + 1)
# → SQL: UPDATE projects SET views_count = views_count + 1 WHERE id = 1
# ← بيتعمل في الـ DB مباشرة — atomic! مفيش race condition

# ── استخدامات تانية ───────────────────────────────────────────
# filter بـ قيمة field تانية
Project.objects.filter(budget__gt=F('min_budget'))
# → projects where budget > min_budget (comparing two columns)

# annotate بـ حسابات
from django.db.models import ExpressionWrapper, DurationField
Project.objects.annotate(
    duration=ExpressionWrapper(
        F('end_date') - F('start_date'),
        output_field=DurationField()
    )
)
```

---

### Q57 — إيه هي الـ Signals وامتى تستخدمها؟

**الجواب:**
الـ Signals هي نظام pub/sub جوه Django — بتخلي جزء من الكود يتفاعل مع events من جزء تاني من غير coupling مباشر.

```python
# signals.py
from django.db.models.signals import post_save, pre_delete, pre_save
from django.dispatch import receiver
from .models import Project
from django.contrib.auth import get_user_model

User = get_user_model()

# @receiver(signal, sender) → بيتشغّل تلقائياً لما الـ event يحصل
@receiver(post_save, sender=User)
def create_default_profile(sender, instance, created, **kwargs):
    # sender   → الـ model class (User)
    # instance → الـ object اللي اتعمل/اتحدّث
    # created  → True لو object جديد، False لو update
    if created:
        # create profile automatically when user is created
        from accounts.models import Profile
        Profile.objects.create(user=instance)

@receiver(pre_delete, sender=Project)
def backup_before_delete(sender, instance, **kwargs):
    # runs BEFORE deletion — useful for cleanup or backup
    import logging
    logging.info(f"Project {instance.pk} is being deleted by system")

# ← لازم تولّد connection في apps.py
# projects/apps.py
class ProjectsConfig(AppConfig):
    name = 'projects'

    def ready(self):
        import projects.signals  # ← connects all signals
```

> ⚠️ **انتبه:** Signals مش بتتشغّل مع `queryset.update()` — بس مع `.save()`. وكمان مش بتتشغّل في transactions من غير commit.

---

### Q58 — إيه هو `select_for_update()` وامتى تحتاجه؟

**الجواب:**
الـ `select_for_update()` بيعمل **pessimistic locking** على الـ rows في الـ database — يمنع أي transaction تانية من تعديلهم لحد ما الـ transaction الحالية تخلص.

```python
from django.db import transaction

def process_payment(project_id, amount):
    with transaction.atomic():  # ← wrap في atomic transaction دايماً مع select_for_update
        # SELECT ... FOR UPDATE — locks the row in the DB
        project = Project.objects.select_for_update().get(pk=project_id)
        # ← أي transaction تانية حاولت تعمل select_for_update على نفس الـ row هتستنى

        if project.budget < amount:
            raise ValueError("Insufficient budget")

        project.budget -= amount
        project.save()  # ← released when atomic block exits

# بدون locking — race condition:
# Thread 1 reads budget=1000
# Thread 2 reads budget=1000
# Thread 1 checks 1000 >= 800 → ok → saves 200
# Thread 2 checks 1000 >= 500 → ok → saves 500 ← WRONG! total deducted 1300 > 1000

# مع select_for_update:
# Thread 1 locks the row
# Thread 2 WAITS (blocked at select_for_update)
# Thread 1 finishes → releases lock
# Thread 2 reads the updated budget (200) → 200 < 500 → raises error ✅
```

---

### Q59 — إيه هو الـ Custom Exception Handler في DRF وإزاي تعمله؟

**الجواب:**

```python
# الـ default DRF response لو حصل error:
# {"detail": "Not found."}  ← مش consistent مع باقي الـ API

# عشان تعمل response format موحد
# utils/exceptions.py

from rest_framework.views import exception_handler
from rest_framework import status

def custom_exception_handler(exc, context):
    # call DRF's default handler first
    response = exception_handler(exc, context)

    if response is not None:
        # wrap in consistent format
        error_data = response.data

        # normalize: some errors are strings, some are dicts, some are lists
        if isinstance(error_data, dict):
            messages = error_data
        elif isinstance(error_data, list):
            messages = {'non_field_errors': error_data}
        else:
            messages = {'detail': error_data}

        response.data = {
            'success': False,
            'status_code': response.status_code,
            'errors': messages,
        }
    else:
        # unhandled exception — return 500
        from rest_framework.response import Response
        response = Response(
            {'success': False, 'status_code': 500, 'errors': {'detail': 'Internal server error'}},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    return response

# settings.py
REST_FRAMEWORK = {
    'EXCEPTION_HANDLER': 'utils.exceptions.custom_exception_handler',
}
```

---

### Q60 — إزاي بتعمل Custom Permission في DRF وإيه الفرق بين `has_permission` و`has_object_permission`؟

**الجواب:**

```python
from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsOwnerOrReadOnly(BasePermission):
    """
    has_permission   → بيتشغّل على كل request (list + detail)
    has_object_permission → بيتشغّل بس على detail views (retrieve, update, destroy)
    """

    def has_permission(self, request, view):
        # SAFE_METHODS = ('GET', 'HEAD', 'OPTIONS')
        if request.method in SAFE_METHODS:
            return True  # anyone can read

        # for write operations → must be authenticated
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        # called AFTER get_object() → obj is the actual Project/Task/etc.
        if request.method in SAFE_METHODS:
            return True  # anyone can read the object

        # only owner can modify
        return obj.owner == request.user

# ── الترتيب المهم: ──────────────────────────────────────────────
# 1. has_permission بيتشغّل الأول
# 2. لو True → get_object() بيتشغّل
# 3. لو فيه object → has_object_permission بيتشغّل
# لو has_permission = False → has_object_permission ما بيتشغّلش خالص!

class IsFreelancerOrAdmin(BasePermission):
    message = "Only freelancers or admins can perform this action."

    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.is_freelancer or request.user.is_staff
```

---

### Q61 — إيه الفرق بين `SerializerMethodField` و`source`؟

**الجواب:**

```python
class ProjectSerializer(serializers.ModelSerializer):

    # source → بيوصّل لـ attribute أو method على الـ object
    owner_name = serializers.CharField(source='owner.username', read_only=True)
    # ← بيجيب project.owner.username تلقائياً
    # بيشتغل مع dotted paths (ForeignKey traversal)

    owner_email = serializers.EmailField(source='owner.email', read_only=True)
    # ← project.owner.email

    # SerializerMethodField → بتكتب Python method بنفسك — أكتر مرونة
    task_count      = serializers.SerializerMethodField()
    is_overdue      = serializers.SerializerMethodField()
    formatted_budget = serializers.SerializerMethodField()

    class Meta:
        model = Project
        fields = ['id', 'title', 'owner_name', 'owner_email',
                  'task_count', 'is_overdue', 'formatted_budget']

    def get_task_count(self, obj):
        # obj is the Project instance
        return obj.tasks.count()

    def get_is_overdue(self, obj):
        from datetime import date
        return obj.end_date < date.today() if obj.end_date else False

    def get_formatted_budget(self, obj):
        return f"${obj.budget:,.2f}"  # → "$5,000.00"
```

```
source            → simple attribute traversal (dotted path)
SerializerMethodField → custom logic, calculations, anything Python
```

---

### Q62 — إزاي بتعمل Nested Serializer مع Write support؟

**الجواب:**

```python
# المشكلة: الـ nested serializer الـ default read-only فقط!

class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ['id', 'name']

class ProjectSerializer(serializers.ModelSerializer):
    # ← read only بشكل افتراضي
    skills = SkillSerializer(many=True, read_only=True)
    # لو حطيت read_only=False → مش هيشتغل تلقائياً لأنه محتاج كتابة في M2M

    class Meta:
        model = Project
        fields = ['id', 'title', 'skills']

    # ── الحل: override create() وـ update() ────────────────────
    def create(self, validated_data):
        skills_data = validated_data.pop('skills', [])   # extract skills before creating
        project = Project.objects.create(**validated_data)

        for skill_data in skills_data:
            skill, _ = Skill.objects.get_or_create(name=skill_data['name'])
            project.skills.add(skill)   # ← add to M2M

        return project

    def update(self, instance, validated_data):
        skills_data = validated_data.pop('skills', None)
        project = super().update(instance, validated_data)  # update regular fields

        if skills_data is not None:
            project.skills.clear()   # remove old skills
            for skill_data in skills_data:
                skill, _ = Skill.objects.get_or_create(name=skill_data['name'])
                project.skills.add(skill)

        return project

# بديل أبسط: قبول IDs بدل objects
class ProjectSerializer(serializers.ModelSerializer):
    skill_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Skill.objects.all(),
        source='skills',   # ← maps to the 'skills' field
        write_only=True
    )
    skills = SkillSerializer(many=True, read_only=True)  # for reading
```

---

### Q63 — إزاي بتعمل Custom Pagination في DRF؟

**الجواب:**

```python
from rest_framework.pagination import PageNumberPagination, CursorPagination
from rest_framework.response import Response

# ── Custom PageNumberPagination ────────────────────────────────
class ProjectPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'  # client can change: ?page_size=25
    max_page_size = 100
    page_query_param = 'page'

    def get_paginated_response(self, data):
        # override to customize the response format
        return Response({
            'success': True,
            'pagination': {
                'count': self.page.paginator.count,
                'total_pages': self.page.paginator.num_pages,
                'current_page': self.page.number,
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            },
            'results': data
        })

# ── CursorPagination — for real-time feeds (no page numbers) ───
class ProjectCursorPagination(CursorPagination):
    page_size = 10
    ordering = '-created_at'   # must be an ordered field
    # cursor = encrypted position in the queryset
    # safe for rapidly-updating data (no page drift)

# ── Apply to ViewSet ───────────────────────────────────────────
class ProjectViewSet(viewsets.ModelViewSet):
    pagination_class = ProjectPagination
    # or globally in settings.py:
    # 'DEFAULT_PAGINATION_CLASS': 'projects.pagination.ProjectPagination'
```

---

### Q64 — إيه هو الـ `transaction.atomic()` وامتى تستخدمه؟

**الجواب:**

```python
from django.db import transaction

# atomic() يضمن "all or nothing" — إما كل العمليات تنجح أو كلها ترجع للوراء

# ── use as context manager ──────────────────────────────────────
def create_project_with_tasks(project_data, tasks_data, user):
    with transaction.atomic():
        project = Project.objects.create(owner=user, **project_data)

        for task_data in tasks_data:
            Task.objects.create(project=project, **task_data)

        # لو أي حاجة هنا فشلت → project وكل الـ tasks بترجع للوراء!
        # مفيش partial data في الـ DB

# ── use as decorator ─────────────────────────────────────────────
@transaction.atomic
def transfer_budget(from_id, to_id, amount):
    from_project = Project.objects.select_for_update().get(pk=from_id)
    to_project   = Project.objects.select_for_update().get(pk=to_id)

    from_project.budget -= amount
    to_project.budget   += amount
    from_project.save()
    to_project.save()

# ── savepoints — nested transactions ────────────────────────────
def complex_operation():
    with transaction.atomic():
        create_main_record()

        try:
            with transaction.atomic():  # ← savepoint
                create_optional_record()  # might fail
        except Exception:
            pass  # rollback to savepoint, not the whole transaction

        create_another_record()  # ← still runs even if the nested one failed
```

---

### Q65 — إزاي بتكتب Custom Middleware في Django؟

**الجواب:**

```python
# ── Function-based middleware (modern style) ──────────────────
# utils/middleware.py

def request_logging_middleware(get_response):
    # one-time setup code here (on startup)
    import logging
    logger = logging.getLogger('django.request')

    def middleware(request):
        import time
        start = time.time()

        # CODE BEFORE VIEW RUNS:
        logger.info(f"→ {request.method} {request.path}")

        response = get_response(request)  # ← calls the view (and other middlewares)

        # CODE AFTER VIEW RUNS:
        duration = time.time() - start
        logger.info(f"← {response.status_code} ({duration:.3f}s)")

        # add custom header to every response
        response['X-Response-Time'] = f"{duration:.3f}s"
        return response

    return middleware

# ── Class-based middleware ─────────────────────────────────────
class APIKeyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.valid_keys = set(['key-123', 'key-456'])  # load from DB in __init__

    def __call__(self, request):
        if request.path.startswith('/api/'):
            api_key = request.headers.get('X-API-Key')
            if api_key not in self.valid_keys:
                from django.http import JsonResponse
                return JsonResponse({'error': 'Invalid API key'}, status=401)
                # ← return response WITHOUT calling get_response → short-circuits the chain

        return self.get_response(request)

# settings.py
MIDDLEWARE = [
    'utils.middleware.request_logging_middleware',
    'utils.middleware.APIKeyMiddleware',
    # ...
]
```

---

### Q66 — إيه الـ `get_queryset()` في الـ ViewSet وإزاي تستخدمها للـ filtering المتقدم؟

**الجواب:**

```python
class ProjectViewSet(viewsets.ModelViewSet):
    serializer_class = ProjectSerializer

    def get_queryset(self):
        # الـ default كان:
        # queryset = Project.objects.all()
        # بس override عشان:
        # 1. optimize بـ select_related
        # 2. filter by current user
        # 3. apply query params

        queryset = Project.objects.select_related('owner').prefetch_related('skills')

        # ── Filter by current user (user sees only their projects) ──
        if not self.request.user.is_staff:
            queryset = queryset.filter(owner=self.request.user)

        # ── Apply query params dynamically ─────────────────────────
        is_active = self.request.query_params.get('is_active')
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')

        min_budget = self.request.query_params.get('min_budget')
        if min_budget:
            queryset = queryset.filter(budget__gte=min_budget)

        search = self.request.query_params.get('search')
        if search:
            from django.db.models import Q
            queryset = queryset.filter(
                Q(title__icontains=search) | Q(description__icontains=search)
            )

        # ── Different queryset per action ────────────────────────────
        if self.action == 'list':
            return queryset.filter(is_active=True)  # list shows only active

        return queryset  # detail/update/delete shows all owned projects

    def get_serializer_class(self):
        # use different serializers for different actions
        if self.action == 'retrieve':
            return ProjectDetailSerializer  # more fields for detail
        if self.action in ['create', 'update', 'partial_update']:
            return ProjectWriteSerializer  # write serializer
        return ProjectListSerializer  # fewer fields for list
```

---

### Q67 — إزاي بتعمل `@action` في الـ ViewSet وإيه الفرق بين `detail=True` وـ `detail=False`؟

**الجواب:**

```python
from rest_framework.decorators import action
from rest_framework.response import Response

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

    # detail=True → URL: /projects/{pk}/action-name/
    # بيشتغل على object معين — تقدر تستدعي self.get_object()
    @action(detail=True, methods=['post'], url_path='activate')
    def activate(self, request, pk=None):
        project = self.get_object()  # ← بيجيب الـ project بالـ pk + permission check
        project.is_active = True
        project.save()
        return Response({'status': 'activated', 'id': project.id})

    @action(detail=True, methods=['get', 'post'], url_path='proposals')
    def proposals(self, request, pk=None):
        project = self.get_object()
        if request.method == 'GET':
            proposals = project.proposals.select_related('freelancer')
            serializer = ProposalSerializer(proposals, many=True)
            return Response(serializer.data)
        elif request.method == 'POST':
            serializer = ProposalSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(project=project, freelancer=request.user)
                return Response(serializer.data, status=201)
            return Response(serializer.errors, status=400)

    # detail=False → URL: /projects/action-name/
    # بيشتغل على الـ collection — مفيش pk
    @action(detail=False, methods=['get'], url_path='my-projects')
    def my_projects(self, request):
        projects = Project.objects.filter(owner=request.user)
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='statistics')
    def statistics(self, request):
        from django.db.models import Count, Sum, Avg
        stats = Project.objects.filter(owner=request.user).aggregate(
            total=Count('id'),
            total_budget=Sum('budget'),
            avg_budget=Avg('budget'),
        )
        return Response(stats)
```

---

### Q68 — إيه هو Django Caching وإزاي بتستخدمه في الـ API؟

**الجواب:**

```python
# cache = بتحفظ نتيجة expensive operation وبتجيبها من memory بدل ما تحسبها تاني

# settings.py — setup Redis (recommended for production)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'TIMEOUT': 300,  # default: 5 minutes
    }
}

# ── Low-level cache API ────────────────────────────────────────
from django.core.cache import cache

def get_featured_projects():
    cache_key = 'featured_projects_v1'  # versioning in key is a good practice
    data = cache.get(cache_key)         # returns None if not cached

    if data is None:
        # cache miss — compute the expensive query
        qs = Project.objects.filter(
            is_featured=True, is_active=True
        ).select_related('owner').prefetch_related('skills')

        from rest_framework_simplejwt.settings import api_settings
        data = ProjectSerializer(qs, many=True).data

        cache.set(cache_key, data, timeout=60 * 15)  # cache for 15 minutes

    return data

# ── Cache invalidation — مهم تعملها وإلا بياكل data قديمة ────
from django.db.models.signals import post_save, post_delete

@receiver(post_save, sender=Project)
@receiver(post_delete, sender=Project)
def invalidate_project_cache(sender, **kwargs):
    cache.delete('featured_projects_v1')
    cache.delete_pattern('project_*')  # needs django-redis for patterns

# ── DRF-specific caching with method_decorator ────────────────
from django.views.decorators.cache import cache_page
from django.utils.decorators import method_decorator

class ProjectViewSet(viewsets.ModelViewSet):
    @method_decorator(cache_page(60 * 5))  # cache list for 5 minutes
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
```

---

### Q69 — إيه الـ `prefetch_related` مع `Prefetch()` object وامتى تحتاجه؟

**الجواب:**

```python
from django.db.models import Prefetch

# prefetch_related() العادي — بيجيب كل الـ related objects
projects = Project.objects.prefetch_related('tasks').all()
# → بيجيب كل الـ tasks لكل project

# Prefetch() object — بيديك تحكم أكتر في الـ prefetch
from .models import Task

# بيفلتر الـ tasks المجلوبة
active_tasks_prefetch = Prefetch(
    'tasks',
    queryset=Task.objects.filter(status='active').select_related('assignee'),
    to_attr='active_tasks'  # ← بيحطهم في attribute اسمه active_tasks مش tasks
)

projects = Project.objects.prefetch_related(active_tasks_prefetch).all()

for project in projects:
    print(project.active_tasks)  # ← list (مش QuerySet) بسبب to_attr
    # أسرع عشان فلترنا في الـ DB مش في Python

# بدون Prefetch — كنا هنعمل:
for project in projects:
    active_tasks = project.tasks.filter(status='active')  # ← N queries!
    # كل iteration بتعمل query جديدة

# مع Prefetch — query واحدة إضافية بس بتجيب كل الـ active tasks:
# SELECT * FROM tasks WHERE project_id IN (1,2,3,...) AND status='active'
```

---

### Q70 — إزاي بتعمل API Rate Limiting (Throttling) في DRF؟

**الجواب:**

```python
# Throttling = تحديد عدد الـ requests اللي user ممكن يعملها في وقت معين

# ── Built-in throttle classes ──────────────────────────────────
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',   # للـ anonymous users
        'rest_framework.throttling.UserRateThrottle',   # للـ authenticated users
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',    # anonymous: 100 requests per day
        'user': '1000/day',   # authenticated: 1000 per day
        # 'minute': '60/minute', 'hour': '500/hour'
    }
}

# ── Custom Throttle ────────────────────────────────────────────
from rest_framework.throttling import UserRateThrottle

class BurstRateThrottle(UserRateThrottle):
    scope = 'burst'  # key in THROTTLE_RATES

class SustainedRateThrottle(UserRateThrottle):
    scope = 'sustained'

# settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'projects.throttles.BurstRateThrottle',
        'projects.throttles.SustainedRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'burst': '60/minute',      # max 60 requests per minute
        'sustained': '1000/day',   # max 1000 per day
    }
}

# ── Apply to specific view ─────────────────────────────────────
class LoginView(APIView):
    throttle_classes = [AnonRateThrottle]
    throttle_scope = 'login'

# ── Custom throttle with per-user limits ──────────────────────
from rest_framework.throttling import BaseThrottle

class PremiumUserThrottle(BaseThrottle):
    def allow_request(self, request, view):
        if not request.user.is_authenticated:
            return False

        # premium users get 10x the limit
        if request.user.is_premium:
            self.rate = '10000/day'
        else:
            self.rate = '100/day'

        return super().allow_request(request, view)

    def wait(self):
        # return seconds until next request is allowed
        return 60
```

---

## 🫒 زتونة الإنترفيو

> **"Django هو web framework مبني على MTV pattern — الـ Model بيمثل الـ DB schema وبيتعامل معاها عن طريق ORM قوي يتحكم في الـ N+1 problem بـ select_related وـ prefetch_related. الـ Migrations بتوثق كل تغيير في الـ schema بشكل منظم زي git. الـ Views بتيجي بشكلين: FBV للـ simple logic وـ CBV للـ CRUD المتكرر بـ Mixins. فوق Django، بنستخدم DRF عشان نبني REST APIs — الـ Serializers بتتكلف بالـ validation والـ serialization، الـ ViewSets مع الـ Routers بتوفر كتير من الـ boilerplate وبتضمن REST-compliant API. في الـ production، بنضيف Permissions مخصصة، JWT authentication، Caching بـ Redis، وـ Throttling للحماية. أهم قرار في الـ project هو Custom User Model من الـ migration الأولى — لو فاتك، دي ورطة."**

---

## 🗺️ Mindmap

```mermaid
mindmap
  root((Django & DRF Interview))
    Architecture
      MTV Pattern
      Request Lifecycle
      Middleware
      WSGI vs ASGI
      Project vs App
    Models
      Field Types<br/>CharField vs TextField
      null vs blank
      auto_now vs auto_now_add
      Relationships<br/>FK OneToOne M2M
      on_delete options
      related_name
      Meta class
      Custom Validation
    Migrations
      makemigrations vs migrate
      Data Migration
      Rollback
    ORM
      QuerySet Lazy
      get vs filter vs first
      Lookup Types
      Q objects OR
      annotate vs aggregate
      select_related<br/>prefetch_related
      N+1 Problem
      update vs save
    Views
      FBV vs CBV
      render<br/>get_object_or_404
      Generic Views<br/>ListView CreateView
      Mixins<br/>LoginRequired
      HTTP Methods
    URLs
      path patterns
      reverse vs reverse_lazy
      Namespacing
      CSRF
    Auth
      Form vs ModelForm
      Custom User Model
      Permissions
      Sessions
    DRF
      Serializer vs ModelSerializer
      Validation Flow
      APIView vs Generic vs ViewSet
      Router<br/>Auto URLs
      perform_create vs create
      Token vs JWT
    Hard Topics
      F expressions
      Signals
      select_for_update
      Custom Exception Handler
      has_permission vs has_object_permission
      SerializerMethodField vs source
      Nested Serializer Write
      Custom Pagination
      transaction.atomic
      Custom Middleware
      get_queryset override
      @action<br/>detail True vs False
      Caching<br/>Redis
      Prefetch object
      Throttling
```

---

*آخر تحديث: 2026-04-23 | Django 5.x + DRF 3.15+*
