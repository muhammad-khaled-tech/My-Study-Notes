# 🏆 المرجع الأعظم — Crowdfund Backend
## Python + Django + DRF + مشروعنا من الصفر للاحتراف

> **لفريق:** Mohamed Khaled · Andrew Emad · Rana Mohamed · Mohamed Abdelhaq · Mohamed Sameh  
> **المشروع:** Crowdfunding Platform — Django 5.2 + DRF + PostgreSQL + JWT Cookies + Cloudinary + EC2  
> **الهدف:** مذاكرة واحدة تكفي — Python + Django Core + DRF + جولة كاملة في الكود

---

> **⚡ قبل ما تبدأ — اقرأ ده:**  
> الملف ده مش شرح أكاديمي. ده **ذاكرة الفريق** — مكتوب بالأسلوب اللي بنفكر بيه. كل مفهوم بيتبدأ بقصة وبيتوسع لحد الكود الحقيقي بتاع مشروعنا. حافظ عليه.

---

# الفهرس

- [[#الجزء الأول — Python اللي لازم تعرفه]]
- [[#الجزء الثاني — Django Core من الصفر]]
- [[#الجزء الثالث — Django REST Framework]]
- [[#الجزء الرابع — جولة في مشروعنا App by App]]
- [[#الجزء الخامس — مين عمل إيه؟ Git Chronicle]]
- [[#الجزء السادس — الغانتليت أسئلة الدفاع المتوقعة]]

---

# الجزء الأول — Python اللي لازم تعرفه

> مش هنذاكر Python من الصفر. هنذاكر الجزء اللي Django بيبني عليه كل حاجة — OOP، decorators، kwargs، comprehensions. ده الـ foundation.

---

## 1.1 — OOP: الكلاس هو العقد الاجتماعي

تخيل معايا إن في مدينة. كل مواطن في المدينة ده **instance**. التصميم المشترك بتاع كل المواطنين — الشكل، الحقوق، الواجبات — ده الـ **class**.

Django نفسه مبني على OOP بالكامل. الـ `Model`، الـ `View`، الـ `Serializer` — كلها classes بترثها وبتعدّل عليها.

```python
# الـ Class هو القالب — الـ Instance هو النسخة الحية
class User:
    # Class variable — مشتركة بين كل الـ instances
    site_name = "CrowdFund"

    def __init__(self, first_name, email):
        # Instance variables — خاصة بكل object
        self.first_name = first_name
        self.email = email

    def greet(self):
        return f"Hello {self.first_name} from {self.site_name}!"

# إنشاء instance
user1 = User("Mohamed", "mo@example.com")
print(user1.greet())  # Hello Mohamed from CrowdFund!
```

---

### Inheritance — الميراث اللي بنى مشروعنا

في مشروعنا، كل view بترث من `APIView` أو `generics.ListCreateAPIView`. كل model بيرث من `models.Model`. كل serializer من `serializers.ModelSerializer`.

**المبدأ:** بدل ما تكتب كل حاجة من الصفر، ترث functionality جاهزة وبتعدل عليها فقط.

```python
# الأب — super class
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        raise NotImplementedError("Subclass must implement speak()")

    def __str__(self):
        return f"Animal: {self.name}"

# الابن — يرث ويعدل
class Dog(Animal):
    def speak(self):
        return "Woof!"

# لو عايز تستدعي الأب من الابن
class GoldenRetriever(Dog):
    def __init__(self, name, color):
        super().__init__(name)  # استدعاء الأب
        self.color = color
```

**ليه `super()` مهمة في Django؟**  
في كتير من الـ views والـ models، Django بيتوقع منك تستدعي `super()` عشان الـ parent class تكمل شغلها الداخلي.

---

### Dunder Methods — السحر المخفي

الـ **dunder** = double underscore = `__method__`. دي methods خاصة Python بتستدعيها تلقائياً في مواقف معينة.

```python
class Project:
    def __init__(self, title, target):
        self.title = title
        self.target = target

    def __str__(self):
        # Python بيستدعيه لما تعمل print(project) أو str(project)
        return f"Project: {self.title}"

    def __repr__(self):
        # للـ debugging — أوضح من __str__
        return f"Project(title={self.title!r}, target={self.target})"

    def __len__(self):
        # لو عملت len(project) — مش منطقية هنا بس كمثال
        return len(self.title)

    def __eq__(self, other):
        # لو عملت project1 == project2
        return self.title == other.title
```

> **في مشروعنا:** شوف `apps/projects/models.py` — كل model فيه `__str__` عشان الـ Admin Panel يعرض اسم الـ object بشكل مفهوم.

---

## 1.2 — *args و **kwargs — الأسلحة السرية

ده بيتسأل عنه كتير. الفكرة بسيطة:

- `*args` = accept any number of **positional** arguments → بتجمعهم في **tuple**
- `**kwargs` = accept any number of **keyword** arguments → بتجمعهم في **dict**

```python
# *args — عدد غير محدد من المتغيرات
def sum_all(*args):
    print(type(args))   # <class 'tuple'>
    return sum(args)

sum_all(1, 2, 3, 4)   # 10
sum_all(10, 20)        # 30

# **kwargs — عدد غير محدد من الـ keyword arguments
def create_user(**kwargs):
    print(type(kwargs))  # <class 'dict'>
    # kwargs = {'first_name': 'Mohamed', 'email': 'mo@test.com'}
    return User(**kwargs)

create_user(first_name="Mohamed", email="mo@test.com", role="admin")
```

**في مشروعنا بالضبط:**

```python
# apps/authentication/models.py
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        #  **extra_fields هيستقبل أي fields إضافية
        # first_name, last_name, mobile_number, role, ...
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)  # بيفرد الـ dict
        user.set_password(password)
        user.save(using=self._db)
        return user
```

---

## 1.3 — Decorators — الغلاف السحري

الـ decorator هو **function بتلف function تانية** وبتضيف عليها behavior إضافي من غير ما تغير الكود الأصلي.

تخيل إن عندك باب. الـ decorator هو الـ security guard قدام الباب — بيعمل checks قبل ما يخلي حد يدخل.

```python
# decorator بسيط
def require_login(func):
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('/login/')
        return func(request, *args, **kwargs)   # يدخل للدالة الأصلية
    return wrapper

@require_login
def dashboard(request):
    return render(request, 'dashboard.html')

# ده مكافئ تماماً لـ:
# dashboard = require_login(dashboard)
```

**في Django:**
```python
from django.contrib.auth.decorators import login_required
from functools import wraps

@login_required   # decorator جاهز من Django
def profile_view(request):
    pass

# DRF بيستخدم @action decorator في ViewSets
from rest_framework.decorators import action

class ProjectViewSet(ModelViewSet):
    @action(detail=True, methods=['post'])
    def rate(self, request, pk=None):
        pass
```

---

## 1.4 — List Comprehensions + Generator Expressions

```python
# القديم — verbose
tag_instances = []
for tag in tags_data:
    instance, _ = Tag.objects.get_or_create(name=tag)
    tag_instances.append(instance)

# الجديد — comprehension — أسرع وأنضف
# من مشروعنا الحقيقي في serializers.py:
tag_instances = [Tag.objects.get_or_create(name=tag)[0] for tag in tags_data]

# مع condition
pending_projects = [p for p in projects if p.status == "pending"]

# Dict comprehension
user_lookup = {user.email: user.id for user in users}

# Generator — أكفأ في الـ memory (lazy evaluation)
# بدل ما يحمل كل الـ data في الـ RAM دفعة واحدة
big_query = (p.title for p in Project.objects.all())
```

**في مشروعنا:**
```python
# apps/projects/serializers.py — ProjectSerializer.create()
image_instances = [Image(path=img, project=project) for img in images_data]
Image.objects.bulk_create(image_instances)
# bulk_create = insert كل الصور في query واحدة مش كل صورة لوحدها
```

---

## 1.5 — Virtual Environments

```bash
# إنشاء بيئة افتراضية
python -m venv venv

# تفعيل (Linux/Mac)
source venv/bin/activate

# تفعيل (Windows)
venv\Scripts\activate

# تثبيت الـ packages
pip install django djangorestframework

# حفظ الـ dependencies
pip freeze > requirements.txt

# تثبيت من ملف موجود
pip install -r requirements.txt
```

> **في مشروعنا:** الـ `venv/` موجود في `.gitignore` عشان ما يتـcommit-ش — كل واحد بيعمل بيئته الخاصة.

---

# الجزء الثاني — Django Core من الصفر

## 2.1 — ليه Django؟ قصة المطبخ الكبير

تخيل معايا إنك بتفتح مطعم كبير. عندك:
- **الكاشير** اللي بيستقبل الطلبات → Router + URLs
- **الطباخ** اللي بيعمل الأكل → View
- **الريسيبي** اللي بيحدد المكونات → Model
- **الترتيب على الطبق** قبل ما يتبعت → Template / Serializer

ده بالظبط نموذج Django — **MTV: Model → Template → View**

|Django MTV|MVC اللي بتعرفه|الوظيفة|
|---|---|---|
|Model|Model|البيانات + قواعد العمل|
|Template|View|عرض البيانات للمستخدم|
|View|Controller|المنطق + ربط الـ Model بالـ Template|

> **ملاحظة:** في مشروعنا مفيش Templates لأننا بنعمل REST API — الـ View بترجع JSON مش HTML.

---

## 2.2 — Project vs App — الفرق المهم

```
crowdfund-backend/          ← هذا هو الـ PROJECT
├── config/                 ← إعدادات المشروع (settings, urls)
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── apps/                   ← مجلد الـ APPS
│   ├── authentication/     ← APP مستقل للـ auth
│   ├── profiles/           ← APP مستقل للـ profiles
│   ├── projects/           ← APP مستقل للـ projects
│   ├── donations/          ← APP مستقل للـ donations
│   └── core/               ← APP placeholder للـ utilities
└── manage.py
```

**الفرق:**
- **Project** = التطبيق الكامل — settings، root URLs، configuration
- **App** = وحدة وظيفية مستقلة — models، views، urls، serializers خاصة بها

**لماذا نفصل الـ apps؟**  
لأن كل app مسؤولة عن domain محدد. لو محتاج تضيف feature في الـ donations — بتبص على `apps/donations/` بس. مش تغرق في كود كتير.

---

## 2.3 — settings.py — كل سطر وليه

ده أهم ملف في المشروع. هنشرح **ملفنا الحقيقي** سطر بسطر.

```python
# config/settings.py

from pathlib import Path
from decouple import config, Csv  # مكتبة لقراءة .env
from datetime import timedelta

# الـ BASE_DIR = المسار الجذر للمشروع
BASE_DIR = Path(__file__).resolve().parent.parent
# __file__ = config/settings.py
# .parent    = config/
# .parent.parent = crowdfund-backend/

# المتغيرات الحساسة من .env — مش مكتوبة هنا عشان الأمان
SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='', cast=Csv())
```

### INSTALLED_APPS — تسجيل الـ Apps

```python
INSTALLED_APPS = [
    # تسلسل مهم: local apps أولاً، ثم 3rd party، ثم Django defaults

    # تطبيقاتنا — لازم تكون قبل django.contrib.auth عشان الـ AUTH_USER_MODEL
    'apps.authentication',
    'apps.projects',
    'apps.core',
    'apps.profiles',
    'apps.donations',

    # مكتبات خارجية
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',  # للـ logout — بيخزن التوكنز الملغية
    'django_extensions',
    'corsheaders',          # للسماح للـ React frontend تتكلم معانا
    'cloudinary_storage',   # تخزين الصور على Cloudinary
    'cloudinary',
    'django_filters',       # للـ search و filter

    # Django defaults
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
```

> **سؤال مهم:** ليه `apps.authentication` قبل `django.contrib.auth`؟  
> عشان لما Django يبدأ، بيشوف `AUTH_USER_MODEL = 'authentication.User'` وبيحتاج الـ app دي تكون متسجلة أول.

### MIDDLEWARE — الحراس على البوابة

```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',     # HTTPS enforcement
    'corsheaders.middleware.CorsMiddleware',             # CORS headers — لازم تكون قبل CommonMiddleware
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',         # CSRF protection — مهم للـ cookies
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

**الـ Middleware = حارس بيشوف كل request وكل response**  
أي HTTP request بتعدي على كل الـ middlewares بالترتيب قبل ما توصل للـ view. والـ response بتعدي عليهم بالعكس.

```
Request  →  SecurityMiddleware  →  CorsMiddleware  →  CsrfMiddleware  →  AuthMiddleware  →  View
Response ←  SecurityMiddleware  ←  CorsMiddleware  ←  CsrfMiddleware  ←  AuthMiddleware  ←  View
```

### Database — PostgreSQL via Supabase

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',  # مش SQLite
        'NAME': config('DB_NAME'),       # postgres
        'USER': config('DB_USER'),       # postgres.xxxxxxxxx
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),       # xxxx.pooler.supabase.com
        'PORT': config('DB_PORT'),       # 6543
    }
}
```

### AUTH_USER_MODEL — الإعلان الأهم

```python
AUTH_USER_MODEL = 'authentication.User'
# ده بيقول لـ Django:
# "مش تستخدم الـ User الافتراضي بتاعك — استخدم الـ User بتاعنا"
# لازم يتحدد قبل أول migration
```

### REST_FRAMEWORK — إعدادات DRF

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'apps.authentication.authentication.CookieJWTAuthentication',
        # بدل Header-based JWT، بنقرأ التوكن من الـ httpOnly cookie
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
        # الـ default: كل endpoint يحتاج auth — إلا لو override-ت
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,  # 10 عناصر لكل صفحة
}
```

### SIMPLE_JWT — إعدادات التوكن

```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),   # ينتهي بعد 30 دقيقة
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),       # ينتهي بعد أسبوع
    'ROTATE_REFRESH_TOKENS': True,     # كل مرة بتعمل refresh → refresh token جديد
    'BLACKLIST_AFTER_ROTATION': True,  # الـ refresh القديم يتضاف للـ blacklist تلقائي

    # إعدادات الـ Cookie
    'AUTH_COOKIE': 'access',           # اسم الـ cookie للـ access token
    'AUTH_COOKIE_REFRESH': 'refresh',  # اسم الـ cookie للـ refresh token
    'AUTH_COOKIE_HTTP_ONLY': True,     # JavaScript مش يقدر يقراه — أمان ضد XSS
    'AUTH_COOKIE_SECURE': IS_PRODUCTION,   # True = HTTPS only في production
    'AUTH_COOKIE_SAMESITE': 'Lax' if not IS_PRODUCTION else 'None',
    # 'None' = يشتغل cross-origin (React على domain مختلف)
    # 'Lax'  = local development
}
```

---

## 2.4 — Models — تصميم قاعدة البيانات

الـ **Model** هو **Python class بيمثل جدول في قاعدة البيانات**.  
كل attribute في الـ class = column في الجدول.  
كل instance من الـ class = row في الجدول.

```python
from django.db import models

class Project(models.Model):
    title = models.CharField(max_length=255)        # VARCHAR(255)
    details = models.TextField()                     # TEXT — طويل
    target = models.FloatField()                     # FLOAT
    current_money = models.FloatField(default=0)
    is_featured = models.BooleanField(default=False) # BOOLEAN
    start_date = models.DateField()                  # DATE
    end_date = models.DateField()                    # DATE
    created_at = models.DateTimeField(auto_now_add=True)  # يُسجَّل مرة واحدة عند الإنشاء
    updated_at = models.DateTimeField(auto_now=True)      # يُحدَّث في كل save()
```

### Field Types الأساسية

|Field|SQL Type|ملاحظة|
|---|---|---|
|`CharField(max_length=n)`|VARCHAR(n)|نصوص قصيرة — max_length إلزامي|
|`TextField()`|TEXT|نصوص طويلة بدون حد|
|`IntegerField()`|INTEGER|أرقام صحيحة|
|`FloatField()`|DOUBLE PRECISION|أرقام عشرية|
|`BooleanField()`|BOOLEAN|True/False|
|`DateField()`|DATE|تاريخ فقط|
|`DateTimeField()`|TIMESTAMP|تاريخ + وقت|
|`EmailField()`|VARCHAR(254)|بيتحقق من صيغة الإيميل|
|`URLField()`|VARCHAR(200)|بيتحقق من صيغة الـ URL|
|`ImageField()`|VARCHAR|بيخزن الـ path — يحتاج Pillow|
|`ForeignKey()`|INTEGER (FK)|علاقة many-to-one|
|`ManyToManyField()`|Pivot Table|علاقة many-to-many|

### Field Options الشائعة

```python
class User(AbstractBaseUser):
    # null=True  → قاعدة البيانات تقبل NULL
    # blank=True → الـ form validation تقبل فراغ
    birthdate = models.DateField(null=True, blank=True)

    # unique=True → لا يتكرر في الجدول
    email = models.EmailField(unique=True)

    # default → قيمة افتراضية
    is_activated = models.BooleanField(default=False)

    # choices → قائمة خيارات محددة
    ROLE_CHOICES = (('admin', 'Admin'), ('user', 'User'))
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='user')

    # auto_now_add → يُسجَّل وقت الإنشاء فقط — read-only
    created_at = models.DateTimeField(auto_now_add=True)

    # validators → validation إضافية
    from django.core.validators import RegexValidator
    mobile_number = models.CharField(
        validators=[RegexValidator(regex=r'^01[0125][0-9]{8}$')],
        max_length=11
    )
```

### Relationships — العلاقات

```python
# ForeignKey — Many-to-One
# "كل project له user واحد، لكن user ممكن يكون له projects كتير"
class Project(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.PROTECT,   # لو حذفت الـ user، امنع الحذف لو عنده projects
        related_name='projects'     # user.projects.all() → كل projects اليوزر ده
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT    # امنع حذف الـ category لو في projects بيها
    )

# on_delete options:
# CASCADE   → احذف الـ related objects معاه
# PROTECT   → امنع الحذف لو في related objects
# SET_NULL  → اعمل الـ FK = NULL (يحتاج null=True)
# SET_DEFAULT → اعمل الـ FK = default value

# ManyToManyField — Many-to-Many
# "كل project ممكن عنده tags كتير، وكل tag ممكن يكون في projects كتير"
class Project(models.Model):
    tags = models.ManyToManyField(Tag, blank=True)
    # Django بيعمل pivot table اسمها projects_project_tags تلقائياً
```

### TextChoices — الأنيق

```python
# من مشروعنا — طريقة أحدث وأوضح من tuple
class Project(models.Model):
    class Status(models.TextChoices):
        BANNED   = "banned",   "Banned"
        PENDING  = "pending",  "Pending"
        FINISHED = "finished", "Finished"
        CANCELED = "canceled", "Canceled"

    status = models.CharField(
        max_length=20,
        choices=Status.choices,   # [('banned','Banned'), ('pending','Pending'), ...]
        default=Status.PENDING    # = "pending"
    )

# الاستخدام:
project.status = Project.Status.FINISHED
# أو:
project.status = "finished"
```

### Meta class — بيانات عن الـ Model نفسه

```python
class ProjectRating(models.Model):
    project = models.ForeignKey(Project, ...)
    user    = models.ForeignKey(User, ...)
    stars   = models.PositiveSmallIntegerField(...)

    class Meta:
        # unique_together = مش ينفع نفس الـ user يعمل أكتر من rating لنفس الـ project
        unique_together = ("project", "user")
        # بديل أحدث (في CommentReport, ProjectReport):
        # constraints = [
        #     models.UniqueConstraint(fields=["project","user"], name="unique_project_report_per_user")
        # ]
        ordering = ['-created_at']   # ترتيب افتراضي عند الـ query
        db_table = 'custom_table_name'  # لو عايز تغير اسم الجدول
```

---

## 2.5 — ORM — بتتكلم مع قاعدة البيانات بـ Python

الـ **ORM (Object-Relational Mapper)** هو الترجمان اللي بيحول Python code لـ SQL.

مش هتكتب SQL في مشروعك — هتكتب Python وـORM يترجمه.

```python
# إنشاء
project = Project.objects.create(title="Solar Panels", target=50000, ...)
# → INSERT INTO projects_project (title, target, ...) VALUES ('Solar Panels', 50000, ...)

# قراءة
all_projects = Project.objects.all()
# → SELECT * FROM projects_project

# فلترة
pending = Project.objects.filter(status="pending")
# → SELECT * FROM projects_project WHERE status = 'pending'

# فلترة معقدة
featured_pending = Project.objects.filter(status="pending", is_featured=True)
# → WHERE status='pending' AND is_featured=TRUE

# الأول أو آخر
first = Project.objects.first()
last  = Project.objects.last()

# البحث عن واحد — بيطلع استثناء لو مش موجود
project = Project.objects.get(id=1)
# → SELECT * WHERE id=1 — لو مش موجود → DoesNotExist exception

# get_or_404 — من DRF (في الـ views)
from django.shortcuts import get_object_or_404
project = get_object_or_404(Project, id=pk)
# لو مش موجود → 404 response تلقائي

# Exclude
non_pending = Project.objects.exclude(status="pending")

# Ordering
sorted_projects = Project.objects.order_by('-created_at')  # - = تنازلي
```

### Lookups — البحث المتقدم

```python
# Double underscore = lookup
Project.objects.filter(title__contains="Solar")     # LIKE '%Solar%'
Project.objects.filter(title__icontains="solar")    # LIKE '%solar%' (case insensitive)
Project.objects.filter(target__gte=10000)           # >= 10000
Project.objects.filter(target__lte=100000)          # <= 100000
Project.objects.filter(created_at__year=2026)       # السنة

# Related fields — بتمشي عبر الـ FK
Project.objects.filter(user__email="mo@test.com")   # JOIN مع جدول الـ users
Project.objects.filter(category__name="Technology") # JOIN مع الـ categories
Project.objects.filter(tags__name="ai")             # JOIN مع الـ tags
```

### select_related و prefetch_related — Performance 🚀

ده من أهم الأشياء اللي اتعملت في مشروعنا (Rana عملتها في الـ profiles).

**المشكلة — N+1 Query Problem:**
```python
# ❌ غلط — N+1 queries
projects = Project.objects.all()  # Query 1: جيب كل الـ projects
for project in projects:
    print(project.user.email)     # Query لكل project! → 100 project = 101 queries!
```

**الحل:**
```python
# ✅ select_related — للـ ForeignKey (One-to-One, Many-to-One)
# بيعمل SQL JOIN واحد بدل N queries
projects = Project.objects.select_related('user').all()
# → SELECT projects.*, users.* FROM projects JOIN users ON ...

# ✅ prefetch_related — للـ ManyToMany أو Reverse FK
# بيعمل query منفصلة واحدة وبيعمل الـ join في Python
projects = Project.objects.prefetch_related('image_set', 'tags').all()

# في مشروعنا — الكلتين معاً:
base_queryset = Project.objects.annotate(
    avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0))
).select_related('user').prefetch_related('image_set')
```

### annotate و aggregate — الحسابات

```python
from django.db.models import Avg, Count, Sum, Value
from django.db.models.functions import Coalesce

# annotate = بيضيف column محسوب لكل row
projects = Project.objects.annotate(
    avg_rate=Avg('ratings__stars')  # متوسط التقييمات لكل project
)
# الآن projects[0].avg_rate = 4.2 مثلاً

# لكن لو مفيش ratings؟ avg_rate = None → مشكلة!
# Coalesce = "لو None → استخدم القيمة الثانية"
projects = Project.objects.annotate(
    avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0))
)
# الآن avg_rate = 0.0 لو مفيش ratings

# aggregate = بيرجع قيمة واحدة للكل
total = Project.objects.aggregate(total=Sum('current_money'))
# {'total': 1500000.0}
```

---

## 2.6 — Migrations — تاريخ قاعدة البيانات

الـ **migration** = snapshot من تغيير في الـ models. بتخلي Django يعرف إزاي يعدل قاعدة البيانات.

```bash
# بعد ما تعدل الـ model:
python manage.py makemigrations          # Django يفحص الـ models ويعمل migration file
python manage.py migrate                 # Django يطبق الـ migrations على قاعدة البيانات

# بتشوف الـ migrations المتاحة:
python manage.py showmigrations

# بتتراجع migration:
python manage.py migrate apps_name 0005  # يرجع لـ migration 0005
```

**في مشروعنا — قصة الـ migrations بتاعت الـ projects:**

```
0001 → أول create لـ Project, Category, Tag
0002 → حذف Project (كانوا بيجربوا وشيلوه)
0003 → إعادة إنشاء Project بشكل صح
0004 → حذف avg_rate (قرروا يحسبوه في الـ ORM مش يخزنوه)
0005 → إضافة Comment model
0006 → إضافة CommentReport
0007 → إضافة ProjectReport
0008 → إضافة ProjectRating
0010 → إضافة image field على Project
0011_A → إضافة avg_rate و tags (من branch واحد)
0011_B → نفس الإضافة من branch تاني → CONFLICT!
0015 → merge migration لحل الـ conflict
0017_A → إضافة parent للـ Comment (threaded replies)
0017_B → حذف avg_rate من الـ model (قرروا يحسبوه بالـ annotation)
0018 → merge migration تاني
```

> ده دليل حي على إن الـ migrations بتسجل تاريخ قرارات الفريق. الـ conflicts بتحصل لما اتنين يشتغلوا على نفس الـ app في نفس الوقت.

---

## 2.7 — manage.py Commands

```bash
python manage.py runserver              # شغل الـ server على port 8000
python manage.py runserver 0.0.0.0:8000 # متاح من أي IP

python manage.py createsuperuser        # إنشاء admin account
python manage.py shell                  # interactive Python shell + Django loaded

python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations

python manage.py collectstatic          # يجمع الـ static files للـ production

# في مشروعنا:
python seed_data.py                     # ملأ قاعدة البيانات ببيانات تجريبية
```

---

# الجزء الثالث — Django REST Framework

## 3.1 — ليه DRF؟

Django الأصلي بيرجع HTML. مشروعنا بيرجع JSON عشان React frontend يستهلكه.

DRF هو الطبقة اللي بتحول Django من **web framework** لـ **API framework**:
- بيعرف يرجع JSON بدل HTML
- بيديك Serializers لتحويل Python objects لـ JSON والعكس
- بيديك Permission classes جاهزة
- بيديك ViewSets للـ CRUD في كود أقل

---

## 3.2 — Serializers — المترجم الثنائي

الـ **Serializer** = **مترجم في الاتجاهين**:
- **Serialization:** Python object → JSON (للـ response)
- **Deserialization:** JSON → Python data → Validation → Model instance (للـ request)

```
Client                    Serializer               Database
 ──────────────────────────────────────────────────────────
 POST {title, target}  →  validation  →  save()  →  DB
 GET                   ←  to_json()   ←  query() ←  DB
```

### ModelSerializer — الأسرع

```python
from rest_framework import serializers
from .models import Category

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = "__all__"   # أو list بالأسماء: ['id', 'name', 'created_at']
        # read_only_fields — الـ client مش يقدر يكتب فيهم
        read_only_fields = ['id', 'created_at']
```

### Extra Fields — SerializerMethodField

بيضيف field محسوب مش موجود في الـ model:

```python
# من مشروعنا — DonationSerializer
class DonationSerializer(serializers.ModelSerializer):
    user_fullname = serializers.SerializerMethodField()
    project_name  = serializers.ReadOnlyField(source="project.title")

    class Meta:
        model = Donation
        fields = ["id", "amount", "project", "user", "user_fullname", "project_name", "created_at"]
        read_only_fields = ["user", "project"]

    def get_user_fullname(self, obj):
        # اسم الميثود لازم يبدأ بـ get_ + اسم الـ field
        return f"{obj.user.first_name} {obj.user.last_name}"
```

### SlugRelatedField — بدل الـ ID

```python
# بدل ما يرجع [1, 2, 3] (IDs)، بيرجع ['ai', 'startup', 'egypt'] (أسماء)
tags_names = serializers.SlugRelatedField(
    many=True,
    read_only=True,
    slug_field='name',   # الـ attribute اللي هيتعرض
    source='tags'        # الـ field في الـ model
)
```

### Validation في الـ Serializer

```python
class RegisterSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True, required=True)

    # Field-level validation — validate_<field_name>
    def validate_birthdate(self, value):
        if value and value > timezone.now().date():
            raise serializers.ValidationError("Birthdate cannot be in the future.")
        return value

    # Object-level validation — validate() — للـ cross-field checks
    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs

    # Overriding create() — كيف يُحفظ في قاعدة البيانات
    def create(self, validated_data):
        validated_data.pop('confirm_password')  # شيل الـ field الـ extra
        return User.objects.create_user(**validated_data)  # يهاش الـ password
```

### Context — بعت معلومات للـ Serializer

```python
# الـ view بتبعت الـ request كـ context
serializer = CommentSerializer(comments, many=True, context={"request": request})

# في الـ serializer، بتقدر تاخد الـ request
def get_is_reported_by_me(self, obj):
    request = self.context.get("request")
    if not request or not request.user.is_authenticated:
        return False
    return ProjectReport.objects.filter(project_id=obj.id, user_id=request.user.id).exists()
```

---

## 3.3 — Views — ثلاث مستويات

### المستوى الأول: APIView (أكثر تحكماً)

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class DonationList(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        donations = Donation.objects.filter(user=request.user)
        serializer = DonationSerializer(donations, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = DonationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)  # لو invalid → 400 تلقائي
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
```

### المستوى الثاني: Generic Views (أسرع كتابة)

```python
from rest_framework import generics

# ListCreateAPIView = GET (list) + POST (create)
class ProjectImageListView(generics.ListCreateAPIView):
    serializer_class = ImageSerializer

    def get_queryset(self):
        return Image.objects.filter(project_id=self.kwargs['project_id'])

    def create(self, request, *args, **kwargs):
        files = request.FILES.getlist('image')
        project = get_object_or_404(Project, id=self.kwargs['project_id'])
        instances = [Image(path=f, project=project) for f in files]
        Image.objects.bulk_create(instances)
        return Response({"detail": "Images uploaded."}, status=status.HTTP_201_CREATED)

# Generics المتاحة:
# ListAPIView         → GET list فقط
# CreateAPIView       → POST فقط
# RetrieveAPIView     → GET single object فقط
# UpdateAPIView       → PUT/PATCH فقط
# DestroyAPIView      → DELETE فقط
# ListCreateAPIView   → GET list + POST
# RetrieveUpdateAPIView   → GET + PUT/PATCH
# RetrieveDestroyAPIView  → GET + DELETE
# RetrieveUpdateDestroyAPIView → GET + PUT/PATCH + DELETE
```

### المستوى الثالث: ViewSets (الـ CRUD الكامل في كود أقل)

```python
from rest_framework.viewsets import ModelViewSet
from rest_framework import filters

class ProjectViewSet(ModelViewSet):
    serializer_class = ProjectSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ["title", "details"]

    def get_queryset(self):
        # كل project بيتعمل annotate بـ avg_rate ديناميكياً
        return Project.objects.annotate(
            avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0))
        ).select_related('user').prefetch_related('image_set')

    def get_permissions(self):
        # permissions مختلفة حسب الـ action
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    def get_object(self):
        # override عشان نتحقق من ملكية الـ project
        obj = super().get_object()
        if self.action not in ['retrieve']:
            if obj.user != self.request.user:
                raise PermissionDenied("You do not have permission to edit this project.")
        return obj

    def perform_create(self, serializer):
        # حفظ الـ user من الـ request مش من الـ form
        serializer.save(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        # override الـ delete عشان نعمل soft delete (cancel مش delete فعلي)
        instance = self.get_object()
        if (instance.current_money / instance.target) > 0.25:
            raise PermissionDenied("Can't cancel — reached more than 25% of target")
        instance.status = 'canceled'
        instance.save()
        return Response({"detail": self.get_serializer(instance).data}, status=200)
```

**الـ ViewSet actions:**

|Action|HTTP Method|URL Pattern|
|---|---|---|
|`list`|GET|`/projects/`|
|`create`|POST|`/projects/`|
|`retrieve`|GET|`/projects/{id}/`|
|`update`|PUT|`/projects/{id}/`|
|`partial_update`|PATCH|`/projects/{id}/`|
|`destroy`|DELETE|`/projects/{id}/`|

---

## 3.4 — URLs و Routers

### Path و include

```python
# config/urls.py
from django.urls import path, include

urlpatterns = [
    path('admin/',        admin.site.urls),
    path('api/auth/',     include('apps.authentication.urls')),
    path('api/users/',    include('apps.profiles.urls')),
    path('api/projects/', include('apps.projects.urls')),
    path('api/donations/',include('apps.donations.urls')),
]
```

### DefaultRouter — مع ViewSets

```python
# apps/projects/urls.py
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r"categories", CategoryViewSet)   # → /categories/ + /categories/{id}/
router.register(r"tags", TagViewSet)              # → /tags/ + /tags/{id}/
router.register(r"", ProjectViewSet, basename='project')  # → / + /{id}/

urlpatterns = [
    path("home/",   HomepageView.as_view(),    name="homepage"),
    path("search/", ProjectSearchView.as_view(), name="project-search"),
    path("", include(router.urls)),  # include الـ router URLs
    path("<int:pk>/similar/", SimilarProjectsView.as_view(), name="similar-projects"),
    path("<int:pk>/rate/",    ProjectRatingCreateView.as_view(), name="project-rate"),
    # ...
]
```

---

## 3.5 — Permissions

```python
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAuthenticatedOrReadOnly

# AllowAny           → أي حد يدخل (حتى anonymous)
# IsAuthenticated    → لازم يكون logged in
# IsAuthenticatedOrReadOnly → logged in للكتابة، anonymous للقراءة فقط

class ProjectCommentCollectionView(APIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    # GET /comments/ → أي حد يقدر يشوف التعليقات
    # POST /comments/ → لازم logged in

# Custom Permission
from rest_framework.permissions import BasePermission

class IsProjectOwner(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user
```

---

## 3.6 — JWT Authentication — الإيميل السري

الـ **JWT (JSON Web Token)** = بطاقة هوية مشفرة:

```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.signature
│─────────────────────│───────────────────│──────────│
     Header                 Payload         Signature
   (algorithm)           (user_id, exp)  (HMAC-SHA256)
```

**عادةً:** التوكن بيتبعت في الـ `Authorization: Bearer <token>` header.

**في مشروعنا:** بنبعته في **httpOnly cookie** — أأمن من الـ header!

**ليه httpOnly cookie أأمن؟**
- JavaScript code مش يقدر يقرأ httpOnly cookie
- لو في XSS attack (كود malicious في الـ browser) → مش يقدر يسرق التوكن
- مع الـ header، أي JavaScript يقدر يقرأه من localStorage

### CookieJWTAuthentication — نظامنا المخصص

```python
# apps/authentication/authentication.py
from rest_framework_simplejwt.authentication import JWTAuthentication

class CookieJWTAuthentication(JWTAuthentication):
    def authenticate(self, request):
        # 1. دور على التوكن في الـ cookies الأول
        raw_token = request.COOKIES.get(settings.SIMPLE_JWT['AUTH_COOKIE'])

        # 2. لو مش موجود في الـ cookie، دور في الـ header (fallback)
        if raw_token is None:
            header = self.get_header(request)
            if header is None:
                return None
            raw_token = self.get_raw_token(header)
            if raw_token is None:
                return None

        # 3. اتحقق من التوكن
        try:
            validated_token = self.get_validated_token(raw_token)
        except (InvalidToken, TokenError):
            return None  # لو انتهى أو غلط، خلي الـ view يقرر

        return self.get_user(validated_token), validated_token
```

---

## 3.7 — Pagination

```python
# في settings.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}

# الاستخدام في الـ URL:
# GET /api/projects/?page=2
# الـ response:
{
    "count": 50,          # إجمالي العناصر
    "next": "/api/projects/?page=3",
    "previous": "/api/projects/?page=1",
    "results": [...]      # الـ 10 عناصر بتاعة الصفحة دي
}
```

---

## 3.8 — Search و Filtering

```python
from rest_framework import filters
from django_filters.rest_framework import DjangoFilterBackend

class ProjectSearchView(generics.ListAPIView):
    serializer_class = ProjectSerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter, DjangoFilterBackend]

    # search بيبحث في الـ fields دي بـ ?search=keyword
    search_fields = ["title", "details", "category__name", "tags__name",
                     "user__first_name", "user__last_name"]

    # filterset بيفلتر بـ ?category=1
    filterset_fields = ["category"]

    def get_queryset(self):
        return Project.objects.filter(status="pending").annotate(...)
```

---

# الجزء الرابع — جولة في مشروعنا App by App

> هنا بنفتح الـ codebase ونشرح كل سطر مهم. ده القلب بتاع الملف.

---

## 4.1 — نظرة عامة على المشروع

**اسم المشروع:** Crowdfunding Platform — نسخة Backend  
**الوظيفة:** REST API يسمح لليوزرز بإنشاء projects للتبرعات، إضافة صور وتاجز، التبرع للـ projects، التعليق، التقييم، والإبلاغ.

**Stack بالكامل:**

|Layer|Technology|ليه؟|
|---|---|---|
|Framework|Django 5.2 + DRF 3.17|Batteries included + powerful REST tools|
|Auth|JWT in httpOnly cookies|أأمن من localStorage|
|Database|PostgreSQL (Supabase-hosted)|Production-grade, ACID compliant|
|Media|Cloudinary|مش هنخزن الصور على الـ server نفسه|
|Email|Brevo SMTP|إرسال activation emails|
|Container|Docker|بيئة متساوية dev و production|
|CI/CD|GitHub Actions → AWS EC2|Auto-deploy على كل push لـ dev|

---

## 4.2 — Custom User Model — ليه وكيف

Django بيجيب **default User** فيه: username، email، password، first_name، last_name.

مشروعنا **بيتلوج بـ email مش username** وعنده fields إضافية (mobile_number، birthdate، role...) فبنعمل **Custom User Model**.

> ⚠️ **قاعدة ذهبية:** لازم تعمل الـ Custom User Model **قبل أول migration**. بعدين صعبة جداً تغير.

### AbstractBaseUser vs AbstractUser

- **`AbstractUser`** = يرث كل الـ default User + بتضيف fields
- **`AbstractBaseUser`** = من الصفر تقريباً — أكثر تحكماً — احنا استخدمنا ده

```python
# apps/authentication/models.py

from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.core.validators import RegexValidator

class UserManager(BaseUserManager):
    """
    كل Custom User محتاج Custom Manager.
    الـ Manager هو الـ interface بين Django وقاعدة البيانات للعمليات الخاصة.
    """
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')

        email = self.normalize_email(email)
        # normalize_email = بيحول aaaaa@GMAIL.COM → aaaaa@gmail.com
        # عشان نمنع duplicate accounts بسبب اختلاف الـ case

        user = self.model(email=email, **extra_fields)
        user.set_password(password)   # hashing بـ PBKDF2
        user.save(using=self._db)     # self._db = نفس الـ database اللي الـ Manager عليها
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_activated', True)
        extra_fields.setdefault('role', 'admin')
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    objects = UserManager()   # بديل الـ default manager

    egyptian_phone_regex = RegexValidator(
        regex=r'^01[0125][0-9]{8}$',
        message="Phone must start with 010, 011, 012, or 015 followed by 8 digits."
    )

    # Fields
    first_name    = models.CharField(max_length=255)
    last_name     = models.CharField(max_length=255)
    email         = models.EmailField(unique=True)
    mobile_number = models.CharField(validators=[egyptian_phone_regex], max_length=11, unique=True)
    profile_pic   = models.ImageField(upload_to='project/', blank=True, null=True)
    role          = models.CharField(max_length=10, choices=[('admin','Admin'),('user','User')], default='user')
    birthdate     = models.DateField(null=True, blank=True)
    fb_profile    = models.URLField(null=True, blank=True)
    country       = models.CharField(max_length=100, null=True, blank=True)
    is_activated  = models.BooleanField(default=False)   # لازم يفعّل الـ email
    joined_at     = models.DateTimeField(null=True, blank=True)  # لما يفعّل
    last_activation_sent = models.DateTimeField(auto_now_add=True)  # للـ cooldown
    created_at    = models.DateTimeField(auto_now_add=True)
    is_staff      = models.BooleanField(default=False)  # للـ Django Admin

    # ده اللي بيقول لـ Django: "استخدم الـ email كـ identifier للـ login"
    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'mobile_number']
    # REQUIRED_FIELDS = الـ fields اللي بتتطلب لما تعمل createsuperuser
    # (بالإضافة للـ USERNAME_FIELD + password اللي بتتطلب تلقائياً)
```

> **`PermissionsMixin`** بيضيف: `is_superuser`، `groups`، `user_permissions` — اللي محتاجاها للـ Admin.

---

## 4.3 — Email Activation — نظام تفعيل الـ Account

**القصة الكاملة:**
1. يوزر بيـregister
2. Django بيعمل حساب جديد `is_activated=False`
3. بيبعت email فيه signed token (فيه الـ user ID + timestamp)
4. اليوزر بيضغط على الـ link
5. Django بيتحقق من التوكن — صح ومش انتهت مدته؟
6. `is_activated = True` وبيتسجل `joined_at`

### TimestampSigner — التوقيع المشفر

```python
# apps/authentication/utils.py
from django.core.signing import TimestampSigner
from urllib.parse import quote

def send_activation_email(user):
    signer = TimestampSigner(salt='activation')
    # TimestampSigner = بيعمل توقيع مشفر + بيضمن timestamp

    token = quote(signer.sign(str(user.pk)), safe='')
    # signer.sign(str(1)) → "1:1wD4jp:XKn0yqgvM9TThATEAXHxYdzJDl7-yHhPIrg41HFoEk8"
    #                          │  │       └──────────────────────────────────────────┘
    #                          │  timestamp                    signature
    #                          user_id

    # quote() = URL-encode عشان : مش بيتعامل صح في URLs
    activation_url = f"{settings.FRONTEND_URL}/activate/{token}"
    # ...

# apps/authentication/views.py — ActivateAccountView
signer = TimestampSigner(salt='activation')
try:
    user_pk = signer.unsign(token, max_age=86400)   # 86400 ثانية = 24 ساعة
    # لو انتهت المدة → SignatureExpired
    # لو التوكن اتعدل → BadSignature
```

---

## 4.4 — Login + JWT Cookies

```python
# apps/authentication/views.py — LoginView

class LoginView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []  # مهم: لو مفيش ده، Django هيحاول يـauthenicate أولاً
    # وممكن يطلع error لو في expired cookie

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data['user']

        # إنشاء JWT tokens
        refresh = RefreshToken.for_user(user)
        access  = str(refresh.access_token)

        response = Response({'message': 'Login successful.'}, status=200)

        # وضع التوكنز في cookies
        response.set_cookie(
            key='access',          # اسم الـ cookie
            value=access,          # JWT access token
            httponly=True,         # JavaScript مش يشوفه — أمان ضد XSS
            secure=IS_PRODUCTION,  # HTTPS only في production
            samesite='Lax',        # local dev  |  'None' في production (cross-origin)
            path='/',
        )
        response.set_cookie(
            key='refresh',
            value=str(refresh),
            # نفس الإعدادات
        )
        return response
```

### Logout — Blacklisting

```python
class LogoutView(APIView):
    def post(self, request):
        refresh_token = request.COOKIES.get('refresh')

        if refresh_token:
            try:
                token = RefreshToken(refresh_token)
                token.blacklist()  # بيضيف الـ token في جدول blacklist
                # الـ token_blacklist app في INSTALLED_APPS هي المسؤولة عن ده
            except TokenError:
                pass  # انتهى أو غلط — مش مشكلة، المهم نمسح الـ cookies

        response = Response({'message': 'Logout successful.'}, status=200)
        response.delete_cookie('access',  path='/')
        response.delete_cookie('refresh', path='/')
        return response
```

---

## 4.5 — Projects App — أكبر App في المشروع

### Models

```python
# apps/projects/models.py

class Category(models.Model):
    name       = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name or f"Category {self.id}"


class Tag(models.Model):
    name       = models.CharField(max_length=255, unique=True, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class Project(models.Model):
    class Status(models.TextChoices):
        BANNED   = "banned",   "Banned"
        PENDING  = "pending",  "Pending"
        FINISHED = "finished", "Finished"
        CANCELED = "canceled", "Canceled"

    title        = models.CharField(max_length=255)
    start_date   = models.DateField()
    end_date     = models.DateField()
    details      = models.TextField()
    target       = models.FloatField()
    current_money= models.FloatField(default=0, blank=True)
    is_featured  = models.BooleanField(default=False)
    status       = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    tags         = models.ManyToManyField(Tag, blank=True)
    category     = models.ForeignKey(Category, on_delete=models.PROTECT)
    user         = models.ForeignKey(User, on_delete=models.PROTECT)
    created_at   = models.DateTimeField(auto_now_add=True)
    # avg_rate مش موجود هنا — بيتحسب بـ annotate في كل query


class Image(models.Model):
    path    = models.ImageField(upload_to='project/', blank=True, null=True, max_length=10000)
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    # CASCADE = لو الـ project اتحذف، الصور بتتحذف معاه


class ProjectRating(models.Model):
    project    = models.ForeignKey(Project, on_delete=models.CASCADE, related_name="ratings")
    user       = models.ForeignKey(User,    on_delete=models.CASCADE, related_name="project_ratings")
    stars      = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("project", "user")  # يوزر واحد = تقييم واحد لكل project


class Comment(models.Model):
    project    = models.ForeignKey(Project, on_delete=models.CASCADE)
    user       = models.ForeignKey(User, on_delete=models.CASCADE)
    parent     = models.ForeignKey(
        "self",              # self-referential FK
        on_delete=models.CASCADE,
        null=True, blank=True,
        related_name="replies"
    )
    content    = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)


class CommentReport(models.Model):
    comment    = models.ForeignKey(Comment, on_delete=models.CASCADE)
    user       = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["comment", "user"],
                name="unique_comment_report_per_user"
            )
        ]


class ProjectReport(models.Model):
    project    = models.ForeignKey(Project, on_delete=models.CASCADE)
    user       = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["project", "user"],
                name="unique_project_report_per_user"
            )
        ]
```

### ProjectSerializer — الأكثر تعقيداً

```python
class ProjectSerializer(serializers.ModelSerializer):
    # Read-only fields مشتقة من علاقات
    category_name = serializers.ReadOnlyField(source="category.name")
    # source="category.name" = obj.category.name

    # SerializerMethodField = field محسوب من method
    user_fullname    = serializers.SerializerMethodField()
    user_profile_pic = serializers.SerializerMethodField()
    is_reported_by_me= serializers.SerializerMethodField(read_only=True)
    calculate_average_rating = serializers.SerializerMethodField()
    uploaded_image_url = serializers.SerializerMethodField()

    # avg_rate من الـ annotation (مش من الـ model)
    avg_rate = serializers.FloatField(read_only=True)

    # write_only fields — للـ input فقط، مش بيتعرض في الـ response
    tags = serializers.ListField(
        child=serializers.CharField(max_length=255),
        required=False,
        write_only=True,
        validators=[validate_max_tags]   # لا يتجاوز 10 tags
    )
    images = serializers.ListField(
        child=serializers.ImageField(...),
        write_only=True,
        required=False,
        validators=[validate_max_images]  # لا يتجاوز 4 صور
    )

    # read_only fields — للـ response فقط
    tags_names = serializers.SlugRelatedField(
        many=True, read_only=True, slug_field='name', source='tags'
    )
    images_urls = ImageSerializer(many=True, read_only=True, source='image_set')

    class Meta:
        model = Project
        fields = [...]
        extra_kwargs = {
            "category": {"write_only": True},   # بتبعت ID، بتاخد category_name
            "user":     {"read_only": True},    # بيتحدد تلقائياً من الـ request
        }

    def create(self, validated_data):
        images_data = validated_data.pop('images', [])
        tags_data   = validated_data.pop('tags', [])
        project = Project.objects.create(**validated_data)

        if tags_data:
            # get_or_create = لو الـ tag موجود → جيبه، لو مش موجود → اعمله
            tag_instances = [Tag.objects.get_or_create(name=tag)[0] for tag in tags_data]
            project.tags.add(*tag_instances)

        if images_data:
            image_instances = [Image(path=img, project=project) for img in images_data]
            Image.objects.bulk_create(image_instances)  # insert كل الصور في query واحدة

        return project
```

### HomepageView — أكثر view تعقيداً

```python
class HomepageView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        # base queryset مع performance optimizations
        base_queryset = Project.objects.annotate(
            avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0))
            # Coalesce = "لو Avg بيرجع None (مفيش ratings) → ارجع 0.0"
        ).select_related('user').prefetch_related('image_set')

        latest_projects  = base_queryset.order_by("-created_at")[:5]
        featured_projects= base_queryset.filter(is_featured=True)[:5]
        top_rated_projects = (
            base_queryset
            .filter(ratings__isnull=False)  # بس اللي عندهم ratings
            .distinct()                      # مش يكرر project بسبب multiple ratings
            .order_by("-avg_rate", "-created_at")[:5]
        )
        categories = Category.objects.all()

        return Response({
            "latest":   ProjectSerializer(latest_projects,   many=True, context={"request": request}).data,
            "featured": ProjectSerializer(featured_projects, many=True, context={"request": request}).data,
            "top_rated":ProjectSerializer(top_rated_projects,many=True, context={"request": request}).data,
            "categories": CategorySerializer(categories, many=True).data,
        })
```

### ProjectReportCreateView — Toggle Logic

```python
class ProjectReportCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        project = get_object_or_404(Project, pk=pk)

        # دور على report موجود
        report = ProjectReport.objects.filter(project=project, user=request.user).first()

        if report:
            # موجود → امسحه (unflag)
            report.delete()
            return Response({"detail": "project unflagged"}, status=200)

        # مش موجود → اعمله (flag)
        ProjectReport.objects.create(project=project, user=request.user)
        return Response({"detail": "project flagged as inappropriate"}, status=201)
```

---

## 4.6 — Donations App — منطق العمل المعقد

```python
# apps/donations/views.py

class DonationCreateRetrieve(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, project_id):
        project = get_object_or_404(Project, id=project_id)

        # 1. التحقق من حالة الـ project
        if project.status != "pending":
            return Response(
                {"msg": f"This project is already {project.status}"},
                status=400
            )

        serializer = DonationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        amount = serializer.validated_data.get('amount', 0.0)
        remaining = project.target - project.current_money

        # 2. التحقق من قيمة التبرع
        if amount > remaining:
            return Response(
                {"msg": f"Donation exceeds remaining target. Max: {remaining}"},
                status=400
            )

        # 3. تحديث الـ project
        project.current_money += amount

        # 4. الانتقال التلقائي لـ finished
        if project.current_money >= project.target:
            project.status = "finished"

        project.save()

        # 5. حفظ الـ donation
        serializer.save(user=request.user, project=project)
        return Response(serializer.data, status=201)
```

---

## 4.7 — Profiles App

```python
# apps/profiles/views.py

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    # MultiPartParser = عشان نقدر نستقبل files (profile pic)

    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response(serializer.data, status=200)

    def patch(self, request):
        # partial=True = مش كل الـ fields إلزامية
        serializer = ProfileSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=200)

    def delete(self, request):
        # 1. تأكد من الـ password
        serializer = DeleteAccountSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        if not request.user.check_password(serializer.validated_data['password']):
            return Response({'password': 'incorrect password'}, status=400)

        # 2. حاول تحذف — PROTECT FK بيمنع لو في projects أو donations
        try:
            request.user.delete()
            return Response({'detail': 'account deleted successfully'}, status=204)
        except ProtectedError:
            return Response({
                'detail': 'Cannot delete account because you have active projects or donations.'
            }, status=400)
```

---

## 4.8 — Cloudinary — تخزين الصور على السحابة

```python
# config/settings.py
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': config('CLOUDINARY_CLOUD_NAME'),
    'API_KEY':    config('CLOUDINARY_API_KEY'),
    'API_SECRET': config('CLOUDINARY_API_SECRET'),
}

STORAGES = {
    'default': {
        'BACKEND': 'cloudinary_storage.storage.MediaCloudinaryStorage'
        # كل ImageField.save() → بيتحمل على Cloudinary تلقائياً
    },
    'staticfiles': {
        'BACKEND': 'django.core.files.storage.FileSystemStorage'
        # الـ static files على الـ server
    }
}
```

**كيف بيشتغل:**
```
User uploads image  →  Django ImageField  →  Cloudinary Storage Backend
                                               → upload to Cloudinary
                                               → save URL in DB
```

**حذف صورة من Cloudinary:**
```python
# apps/projects/views.py — ProjectImageDetailView
def delete(self, request, project_id, pk, format=None):
    image = get_object_or_404(Image, project=project_id, id=pk)
    image.path.delete()   # ← بيحذف من Cloudinary أولاً
    image.delete()        # ← ثم بيحذف الـ row من DB
    return Response(status=204)
```

---

## 4.9 — Docker + CI/CD

### Dockerfile

```dockerfile
FROM python:3.12-slim        # صورة Python خفيفة

WORKDIR /app                  # الـ working directory داخل الـ container

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt   # تثبيت الـ packages

COPY . .                      # نسخ كل الكود

EXPOSE 8000                   # الـ port اللي بيشتغل عليه Django

CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
# migrate أولاً، ثم runserver — 0.0.0.0 يعني متاح من أي IP
```

### GitHub Actions — CI/CD Pipeline

```yaml
# .github/workflows/deploy-ec2.yml

name: Deploy to EC2
on:
  push:
    branches: [dev]        # على أي push لـ dev branch

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy on EC2 over SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.EC2_HOST }}     # IP الـ server
          username: ${{ secrets.EC2_USER }} # ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}   # SSH private key
          script: |
            cd "${{ secrets.EC2_PROJECT_PATH }}"

            # Serialize concurrent deploys (في حالة backend و frontend بيتنشروا في نفس الوقت)
            lock_file="/tmp/crowdfund-deploy.lock"
            exec 9>"${lock_file}" && flock -x 9

            # Pull latest code
            git -C crowdfund-backend fetch origin dev
            git -C crowdfund-backend reset --hard origin/dev

            # Rebuild and restart only the backend container
            docker compose -p crowdfund up -d --build --no-deps backend

            # Cleanup to save disk space
            docker builder prune -af || true
            docker image prune -f   || true
```

---

# الجزء الخامس — مين عمل إيه؟ Git Chronicle

> ده سجل حقيقي من الـ git log. كل واحد يعرف ايه شغله ويقدر يشرحه.

---

## 📊 جدول المساهمات

| عضو الفريق | GitHub | الـ Features الرئيسية |
|---|---|---|
| **Mohamed Abdelhaq** | `mohamedabdelhaq-123` | Auth bugs fixes، CORS setup، `/auth/me/` endpoint، UX expiration handling، CookieTokenRefreshView، project report toggle، JWT auth class fix |
| **Andrew Emad** | `andrewemad@Andrew.local` | Donations logic + fixes، project images (Cloudinary upload/delete)، project access restrictions، max tags/images validation، README، admin registration |
| **Rana Mohamed** | `ranamohamed24` | Profile app كاملة (update، delete account، public profile، my projects، my donations)، avg_rate annotation + query optimization، user_profile_pic في serializers |
| **Mohamed Sameh** | `muhammad.khaled.tech` (kholy2011) | CI/CD (Dockerfile + GitHub Actions)، comments reply feature، migration conflict fix (0011 custom SQL)، reporting logic، settings fixes، CORS |
| **Mohamed Khaled** | `muhammad-khaled-tech` | Homepage + categories view، search + django-filter integration، API routing sync مع frontend requirements |

---

## 📅 Timeline المشروع

```
Apr 15, 2026  ← بداية المشروع
│
├── Day 1-2 (Apr 15-16): Setup
│   ├── Mohamed Abdelhaq: Project init، Custom User model، auth migrations
│   ├── Mohamed Sameh: CI/CD setup، Dockerfile
│   └── Andrew: Initial changes، project structure
│
├── Day 3 (Apr 17): Core Features
│   ├── Andrew: Images model، Tags/Images management، project restrictions
│   ├── Mohamed Sameh: Comments + replies، reporting، avg_rate migration fix
│   ├── Mohamed Abdelhaq: /auth/me/ endpoint، JWT auth fix
│   └── Mohamed Khaled: Homepage view، search
│
├── Day 4 (Apr 18): Polish + Integration
│   ├── Rana: Profile app، avg_rate optimization، user_profile_pic
│   ├── Andrew: Donations logic، donation fix
│   ├── Mohamed Abdelhaq: Bug fixes، CORS، UX improvements
│   └── Mohamed Sameh: CI/CD fixes، settings
│
└── Apr 22, 2026 ← Andrew: README
```

---

## 🔍 Commits المميزة (للمراجعة)

### Mohamed Abdelhaq
```bash
# fix(auth): disable JWT auth classes on LoginView to allow stale cookie login
# → السبب: لو في expired access cookie، LoginView كانت ترفض الـ request قبل ما تبص على الـ credentials
# الحل: authentication_classes = [] على LoginView و LogoutView

# feat: implement /auth/me/ endpoint for frontend session validation
# → الـ frontend بيستدعيه عند كل refresh عشان يتأكد السيشن ماشية

# Ux expiration handling
# → معالجة حالة انتهاء الـ token بطريقة smooth للـ frontend
```

### Andrew Emad
```bash
# restrict user access to the projects, custom soft delete logic, restrict max tags/images
# → الأكثر شمولاً في مساهماته — الـ ownership check، الـ cancel protection، الـ validators

# user can now donate to project
# → donation logic مع: status check، amount cap، auto-finish

# fixed deleting in cloudinary
# → image.path.delete() قبل image.delete()

# add readme
# → الـ README الاحترافية
```

### Rana Mohamed
```bash
# feat(profile): add endpoints for profile updates, account deletion, user projects, and public view
# → كل الـ /api/users/ endpoints في commit واحد

# fix: add avg_rate and query optimization
# → select_related + prefetch_related + Coalesce annotation
# → قلل عدد queries بشكل كبير

# fix(projects): add user_profile_pic in project and comment serializers
# → عشان الـ frontend يعرض صورة الـ user جنب كل project وكل comment
```

### Mohamed Sameh
```bash
# Added comments reply
# → parent ForeignKey على Comment model + validation في الـ serializer

# Create 0011_project_avg_rate.py
# → manual migration عشان يحل conflict — كتب raw SQL:
# ALTER TABLE ADD COLUMN IF NOT EXISTS avg_rate

# Fixed reporting logic
# → toggle: report مرة → flag، مرة تانية → unflag

# Edited Dockerfile and CICD
# → production-grade setup
```

### Mohamed Khaled
```bash
# feat: expand search capabilities and integrate django-filter
# → search_fields: title, details, category__name, tags__name, user names
# → filterset_fields: category

# Sync API fixes with frontend requirements: improved routing, serializers, and annotations
# → frontend طالب تغييرات، محمد خالد sync-ها في الـ backend
```

---

# الجزء السادس — الغانتليت: أسئلة الدفاع المتوقعة

> ده جزء المراجعة السريعة. اقرأ السؤال وحاول تجاوب قبل ما تفتح الإجابة.

---

## Python Questions

> **Q1: ما الفرق بين `*args` و `**kwargs`؟ ادي مثال من مشروعنا.**

`*args` = positional arguments → tuple  
`**kwargs` = keyword arguments → dict  
**من مشروعنا:**
```python
def create_user(self, email, password=None, **extra_fields):
    user = self.model(email=email, **extra_fields)
    # extra_fields = {'first_name': 'Mo', 'mobile_number': '01012345678', ...}
```

> **Q2: ما هو الـ decorator وكيف استخدمناه؟**

Function بتلف function تانية وتضيف behavior. في DRF، `@action(detail=True, methods=['post'])` لتسجيل endpoints إضافية في ViewSet.

> **Q3: ما الفرق بين `null=True` و `blank=True` في Django؟**

- `null=True` → قاعدة البيانات تقبل NULL
- `blank=True` → Django form/serializer validation تقبل فراغ
- عادةً بتيجوا مع بعض للـ optional text fields

> **Q4: اشرح `get_or_create` من مشروعنا.**

```python
tag_instances = [Tag.objects.get_or_create(name=tag)[0] for tag in tags_data]
# get_or_create(name=tag) → (instance, created_bool)
# [0] → جيب الـ instance بس
# لو الـ tag موجود → جيبه من DB
# لو مش موجود → اعمله في DB وجيبه
```

---

## Django Questions

> **Q5: اشرح الـ Django Request-Response Cycle كاملاً.**

```
Client
  ↓ HTTP Request
URLs (config/urls.py) → match pattern
  ↓
Middleware Stack (security, cors, csrf, auth, ...)
  ↓
View (apps/projects/views.py → ProjectViewSet.list())
  ↓
ORM (Project.objects.filter(...))
  ↓
Database (PostgreSQL via psycopg2)
  ↑
Response (serialized JSON)
  ↑
Middleware Stack (reverse)
  ↑
Client (JSON response)
```

> **Q6: ليه عملنا Custom User Model بدل الـ default؟**

3 أسباب:
1. بنـlogin بـ email مش username (`USERNAME_FIELD = 'email'`)
2. محتاجين fields إضافية: mobile_number، birthdate، country، role، is_activated
3. mobile_number Egyptian validator

> **Q7: ما هو الـ on_delete وما الخيارات المتاحة؟**

بيحدد ماذا يحدث للـ rows المرتبطة لو الـ parent اتحذف:
- **CASCADE:** احذف معاه → Comment عند حذف Project
- **PROTECT:** امنع الحذف → Project عند حذف User (عشان مش نحذف projects غصب)
- **SET_NULL:** اعمل NULL → Category عند حذفها من Project (قديم في مشروعنا)

> **Q8: اشرح الـ select_related و prefetch_related وليه استخدمناهم.**

- `select_related` → SQL JOIN للـ FK — كل شيء في query واحدة
- `prefetch_related` → query منفصلة وـjoin في Python — للـ M2M وReverse FK

**من مشروعنا:**
```python
Project.objects.annotate(avg_rate=...).select_related('user').prefetch_related('image_set')
# select_related('user')  → 1 query بدل N لجلب الـ user مع كل project
# prefetch_related('image_set') → query واحدة للصور بدل N
```

> **Q9: ما هو الـ migration وليه مهم؟**

Snapshot بيسجل تغيير في الـ models. مهم لأنه:
1. بيسمح لكل الـ team يشتغل على نفس الـ schema
2. بيسمح بـ rollback لـ state سابق
3. بيخزن تاريخ تطور قاعدة البيانات

> **Q10: اشرح الـ Middleware Cycle.**

```
Request: SecurityMW → CorsMW → SessionMW → CommonMW → CsrfMW → AuthMW → View
Response: SecurityMW ← CorsMW ← SessionMW ← CommonMW ← CsrfMW ← AuthMW ← View
```
كل middleware ممكن يعدل أو يوقف الـ request/response.

---

## DRF Questions

> **Q11: ما الفرق بين `APIView`، `GenericView`، و`ViewSet`؟**

|نوع|المرونة|سطور الكود|متى تستخدمه؟|
|---|---|---|---|
|`APIView`|أعلى|أكثر|logic معقد، no standard CRUD|
|`GenericView`|متوسط|متوسط|CRUD مع تعديل|
|`ViewSet`|أقل|أقل|CRUD standard كامل|

**من مشروعنا:**
- `APIView`: LoginView، LogoutView، DonationCreateRetrieve، HomepageView
- `GenericView`: ProjectImageListView، ProjectSearchView
- `ViewSet`: ProjectViewSet، CategoryViewSet، TagViewSet

> **Q12: اشرح `perform_create` و`perform_update` في ViewSet.**

```python
def perform_create(self, serializer):
    serializer.save(user=request.user)
# الـ user مش بيجي من الـ form (عشان الـ user field read_only)
# بيجي من الـ authenticated request
```

> **Q13: ما الفرق بين `read_only`، `write_only`، و `source` في Serializer؟**

- `read_only=True` → يتعرض في response، لا يُقبل في request
- `write_only=True` → يُقبل في request، لا يتعرض في response
- `source="category.name"` → بدل ما يـaccess الـ field مباشرة، بيعمل traverse

**من مشروعنا:**
```python
category_name = serializers.ReadOnlyField(source="category.name")
# read_only → يتعرض في response فقط
# source    → بدل obj.category_name (مش موجود) → obj.category.name

category = {"write_only": True}  # extra_kwargs
# بتبعت category_id في الـ POST
# بتاخد category_name في الـ response
```

> **Q14: اشرح `is_valid(raise_exception=True)` وما هو بديله.**

```python
# مع raise_exception=True
serializer.is_valid(raise_exception=True)
# لو validation فشلت → 400 Bad Request تلقائي مع error details

# البديل
if not serializer.is_valid():
    return Response(serializer.errors, status=400)
```

> **Q15: كيف تعمل Custom Validator في DRF؟**

```python
def validate_max_images(value):
    if len(value) > 4:
        raise ValidationError("You cannot add more than 4 images.")

images = serializers.ListField(
    ...,
    validators=[validate_max_images]
)
```

> **Q16: اشرح JWT — الـ Access Token والـ Refresh Token.**

- **Access Token:** قصير العمر (30 دقيقة) — بيُرسل مع كل request
- **Refresh Token:** طويل العمر (7 أيام) — بيُستخدم فقط لجلب access token جديد
- **في مشروعنا:** كلاهما في httpOnly cookies (مش Authorization header)
- **ROTATE_REFRESH_TOKENS=True:** كل مرة بتعمل refresh، بتاخد refresh token جديد والقديم يتضاف لـ blacklist

> **Q17: ليه استخدمنا httpOnly Cookies بدل Authorization Header؟**

- **الـ Header:** التوكن بيتخزن في localStorage → قابل للسرقة بـ XSS attack
- **httpOnly Cookie:** JavaScript مش يقدر يقراه → محمي من XSS
- المشكلة الوحيدة: CSRF attacks → حلها بـ `CsrfViewMiddleware` + `CSRF_TRUSTED_ORIGINS`

> **Q18: اشرح CORS في مشروعنا ولماذا محتاجينه.**

CORS = Cross-Origin Resource Sharing  
React frontend (على localhost:5173) وDjango backend (على localhost:8000) → different origins → browser بيرفض الـ requests تلقائياً.

```python
CORS_ALLOWED_ORIGINS = ['http://localhost:5173', 'http://localhost:3000', 'https://crowdfund.duckdns.org']
CORS_ALLOW_CREDENTIALS = True  # عشان الـ cookies تتبعت
# CorsMiddleware في الـ MIDDLEWARE list — لازم قبل CommonMiddleware
```

---

## Project-Specific Questions

> **Q19: اشرح نظام تفعيل الـ account — TimestampSigner.**

```
Register → is_activated=False → TimestampSigner.sign(user_pk) → URL
User clicks URL → TimestampSigner.unsign(token, max_age=86400)
  → SignatureExpired (> 24 hrs) → Error
  → BadSignature (tampered)    → Error
  → OK → is_activated=True + joined_at=now()
```

> **Q20: اشرح منطق cancel project protection.**

```python
def destroy(self, request, *args, **kwargs):
    instance = self.get_object()
    if (instance.current_money / instance.target) > 0.25:
        raise PermissionDenied("Can't cancel — > 25% funded")
    if instance.status != 'pending':
        raise PermissionDenied(f"Project is already {instance.status}")
    instance.status = 'canceled'
    instance.save()
    # مش بنحذف من DB — soft delete بتغيير الـ status
```

> **Q21: اشرح منطق الـ donation cap.**

```python
amount    = request.data['amount']
remaining = project.target - project.current_money
if amount > remaining:
    → Error: "Max donation is {remaining}"
# بعدين:
project.current_money += amount
if project.current_money >= project.target:
    project.status = "finished"   # تلقائي يخلص
project.save()
```

> **Q22: اشرح delete account protection (ProtectedError).**

```python
try:
    user.delete()
except ProtectedError:
    → Error: "Can't delete — has active projects or donations"
```

الـ `ProtectedError` بيتحصل لأن `Project.user = ForeignKey(on_delete=PROTECT)` وكمان `Donation.user = ForeignKey(on_delete=PROTECT)`.  
Django بيرمي exception قبل ما يحذف.

> **Q23: اشرح الـ avg_rate وليه مش بنخزنه في الـ model.**

```python
# بدل model field = بنحسبه في كل query بـ annotation
Project.objects.annotate(avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0)))
```

**ليه ده أفضل؟** لو خزناه في الـ model، بنحتاج نـupdate كل project بعد كل rating → race conditions. بـ annotation، بنحسبه في real-time من الـ ratings.

> **Q24: اشرح Similar Projects feature.**

```python
class SimilarProjectsView(generics.ListAPIView):
    def get_queryset(self):
        project_id = self.kwargs.get("pk")
        current_project = Project.objects.get(id=project_id)
        return (
            Project.objects
            .filter(tags__in=current_project.tags.all(), status="pending")
            # tags__in = أي project فيه tag مشترك
            .exclude(id=project_id)  # مش يرجع الـ project نفسه
            .distinct()              # مش يكرر project بسبب أكتر من tag مشترك
            [:4]
        )
```

> **Q25: اشرح threaded comments (parent FK).**

```python
class Comment(models.Model):
    parent = models.ForeignKey(
        "self",                  # self-referential — بيشاور على نفس الـ model
        null=True, blank=True,   # None = top-level comment
        related_name="replies"   # comment.replies.all() = كل الـ replies
    )
# validation في CommentSerializer:
def validate_parent(self, parent):
    if parent and parent.parent is not None:
        raise ValidationError("Replies cannot be nested further.")
    # بنسمح بـ 1 level فقط من الـ replies
```

> **Q26: اشرح Docker الـ deployment process.**

```
git push → GitHub Actions triggered → SSH to EC2
→ git pull latest code
→ docker compose up --build --no-deps backend
   (--no-deps = مش يعيد build الـ frontend)
→ docker prune (تنظيف)
```

> **Q27: ليه استخدمنا `bulk_create` للصور؟**

```python
image_instances = [Image(path=img, project=project) for img in images_data]
Image.objects.bulk_create(image_instances)
# بدل:
# for img in images_data:
#     Image.objects.create(path=img, project=project)  ← N queries!
# bulk_create = INSERT واحد لكل الصور
```

> **Q28: ما هي `django-decouple` وليه بنستخدمها؟**

```python
from decouple import config, Csv
SECRET_KEY = config('SECRET_KEY')  # بتقرأ من .env file
```

بدل ما نكتب الـ secrets مباشرة في الكود (وبيتـcommit على GitHub)، بنخليهم في `.env` file اللي موجود في `.gitignore`.

> **Q29: اشرح `Coalesce` وليه محتاجينها.**

```python
from django.db.models.functions import Coalesce
from django.db.models import Avg, Value

annotate(avg_rate=Coalesce(Avg('ratings__stars'), Value(0.0)))
# Avg('ratings__stars') → None لو مفيش ratings
# Coalesce(None, 0.0)   → 0.0
# بدونها، avg_rate = None → error في الـ serializer
```

> **Q30: اشرح الـ resend activation cooldown mechanism.**

```python
cooldown = timedelta(minutes=2)
if user.last_activation_sent and (timezone.now() - user.last_activation_sent < cooldown):
    remaining = (user.last_activation_sent + cooldown - timezone.now()).seconds
    return Response({'error': f'Wait {remaining} seconds'}, status=429)

# 429 = Too Many Requests
# last_activation_sent = auto_now_add → بيتحدث في send_activation_email()
```

---

## Bonus Questions 🌟

> **Q31: ما هو `token_blacklist` وكيف يشتغل؟**

مكتبة من simplejwt. عند الـ logout، بيحط الـ refresh token في جدول `token_blacklist_blacklistedtoken`. لما يجي refresh request، بيتحقق الجدول ده أولاً. لو موجود → يرفض.  
`BLACKLIST_AFTER_ROTATION=True` → كل refresh token قديم بيتضاف تلقائياً لما يتعمل rotate.

> **Q32: اشرح `source='image_set'` في الـ serializer.**

```python
images_urls = ImageSerializer(many=True, read_only=True, source='image_set')
# image_set = الـ default reverse name للـ FK
# Image.project = ForeignKey(Project) → project.image_set.all()
# لو كتبنا related_name='images' كانت بتبقى project.images.all()
```

> **Q33: ما الفرق بين `GET /api/auth/me/` و `GET /api/users/me/`؟**

- `/api/auth/me/` → **MeSerializer** = id, email, first_name, last_name, role, profile_pic  
  للـ frontend عشان يعرف إيه الـ session الحالية
- `/api/users/me/` → **ProfileSerializer** = كل الـ profile fields (birthdate, country, fb_profile, ...)  
  للـ profile page

> **Q34: ليه `authentication_classes = []` على LoginView؟**

لو تركناه افتراضي، Django بيحاول يـauthenticate الـ request. لو في expired access cookie، **`CookieJWTAuthentication.authenticate()` بترجع `None`** (مش بترمي error). بس في بعض الحالات، ده كان بيسبب behavior غريب مع الـ CSRF.

Mohamed Abdelhaq fix-ها: `authentication_classes = []` → Django ميحاولش يـauthenticate → الـ LoginView تشتغل بـ fresh session دايماً.

> **Q35: اشرح `ROTATE_REFRESH_TOKENS` و `BLACKLIST_AFTER_ROTATION`.**

```
User logs in     → access(30min) + refresh(7days)
30 min later     → access expired, user calls /token/refresh/
  ROTATE=True    → new access + NEW refresh token
  BLACKLIST=True → old refresh token → blacklisted
  
ليه ده مهم؟ لو حد سرق الـ refresh token، بعد أول استخدام
يتـblacklist ومش ينفع تاني.
```

---

## 🧠 زتونة الإنترفيو — الملخص اللي يفرق

> قبل ما تدخل الدفاع، تأكد إنك فاهم الـ 5 نقاط دول:

**1. الـ Custom User Model:** ليه `AbstractBaseUser` + كيف `USERNAME_FIELD = 'email'` بيغير الـ login behavior.

**2. الـ JWT Cookie Flow:** Register → Activate → Login (cookies) → Authenticated Requests → Refresh → Logout (blacklist + clear cookies).

**3. الـ N+1 Query Problem وحلها:** `select_related` للـ FK، `prefetch_related` للـ M2M، وإزاي Rana حسنت الـ performance في الـ profiles.

**4. الـ Soft Delete:** مش بنحذف الـ project من DB — بنغير `status = 'canceled'`. ليه؟ للـ audit trail وعشان الـ donations المرتبطة بيها تفضل موجودة.

**5. الـ Permissions في ViewSet:** `get_permissions()` بتغير الـ permission classes حسب الـ action — `list/retrieve` = AllowAny، بقية الـ actions = IsAuthenticated.

---

> **📌 ملاحظة أخيرة:** لو اتسألت عن أي سطر كود، قول "ده شغل [اسم العضو] في [اسم الـ app]" وشرحه. الـ panel هيقدر قيمتك مش بس على إنك فاهم — على إنك تعرف مشروعك.

---

*آخر تحديث: قبل الدفاع مباشرة — بالتوفيق يا فريق 🚀*
