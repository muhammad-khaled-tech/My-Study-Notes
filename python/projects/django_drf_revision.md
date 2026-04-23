---
tags:
  - django
  - django-rest-framework
  - revision
  - backend
  - comprehensive
created: 2026-04-23
status: complete
---

# 🦄 مراجعة Django & DRF الشاملة — من الصفر للـ API

> الملف ده مش documentation — ده جلسة مذاكرة مع صاحبك اللي اشتغل Django وعارف فين الـ juniors بيتعبوا.
> كل حاجة مرتبة بالترتيب — من فكرة Django الأساسية لـ DRF Production-ready.
> الكود كومنتاته بالإنجليزي، الشرح بالمصري.

---

## 📋 فهرس

- [[#🔷 الجزء الأول — Django بتشتغل إزاي؟ الـ MTV Pattern]]
- [[#🔷 الجزء الثاني — Project Setup والـ Structure]]
- [[#🔷 الجزء الثالث — Models والـ Fields]]
- [[#🔷 الجزء الرابع — Migrations]]
- [[#🔷 الجزء الخامس — ORM والـ QuerySets]]
- [[#🔷 الجزء السادس — Views الـ FBV]]
- [[#🔷 الجزء السابع — Views الـ CBV]]
- [[#🔷 الجزء الثامن — URLs والـ Routing]]
- [[#🔷 الجزء التاسع — Templates والـ Template Language]]
- [[#🔷 الجزء العاشر — Forms والـ ModelForms]]
- [[#🔷 الجزء الحادي عشر — Django Admin]]
- [[#🔷 الجزء الثاني عشر — Authentication والـ Permissions]]
- [[#🔷 الجزء الثالث عشر — Django REST Framework المقدمة]]
- [[#🔷 الجزء الرابع عشر — Serializers]]
- [[#🔷 الجزء الخامس عشر — APIView والـ Generic Views]]
- [[#🔷 الجزء السادس عشر — ViewSets والـ Routers]]
- [[#🔷 الجزء السابع عشر — Permissions والـ Authentication في DRF]]
- [[#🔷 الجزء الثامن عشر — Pagination والـ Filtering]]
- [[#🔷 الجزء التاسع عشر — Advanced Topics والـ Best Practices]]

---

## 🔷 الجزء الأول — Django بتشتغل إزاي؟ الـ MTV Pattern

### الفكرة الأساسية

تخيّل معايا إنك بتبني موقع — كل request من المتخدم لازم يعدي على حاجات كتير: مين هو؟ هيروح فين؟ هياخد إيه؟ هيشوف إيه؟ لو كل ده مكانش منظم، الكود هيبقى فوضى.

Django اتبنى على فكرة **MTV** — وده مش حاجة جديدة، ده تطبيق لـ MVC Pattern اللي الـ web frameworks كلها بتشتغل بيه.

```
MTV = Model + Template + View
MVC = Model + View + Controller
```

الفرق بس في التسمية — الـ View في Django بيقوم بدور الـ Controller، والـ Template بيقوم بدور الـ View.

### رحلة الـ Request كاملة

```
Browser sends: GET /products/5/
        ↓
Django's URL Resolver (urls.py)
        ↓
matches pattern → calls the right View
        ↓
View function/class runs
        ↓
(optional) queries the Database via Model (ORM)
        ↓
View passes data to Template
        ↓
Template renders HTML
        ↓
Django returns HTTP Response to Browser ✅
```

> [!note] لاحظ
> الـ Request رحلته واحدة ثابتة — إنت بس بتعرّف كل محطة فيها إيه. ده اللي بيخلي Django منظم.

### إزاي الـ Django Settings بتشتغل

```python
# settings.py — قلب المشروع

# INSTALLED_APPS — بتخبر Django بالـ apps الموجودة
INSTALLED_APPS = [
    'django.contrib.admin',       # the admin panel
    'django.contrib.auth',        # the auth system
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'myapp',                      # ← your custom app goes here
]

# DATABASES — database connection config
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',  # use PostgreSQL in production!
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# MIDDLEWARE — list of layers every request passes through (order matters!)
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',  # ← adds request.user
    'django.contrib.messages.middleware.MessageMiddleware',
]
```

> [!tip] الـ Convention في Django
> الـ `BASE_DIR` هو مجلد المشروع. `BASE_DIR / 'db.sqlite3'` بيستخدم `pathlib.Path` — طريقة حديثة ومش بتتكسر على Windows/Linux.

---

## 🔷 الجزء الثاني — Project Setup والـ Structure

### إنشاء المشروع والـ App

```bash
# install Django in a virtual environment (always use venv!)
pip install django djangorestframework

# create a new project called "freelance_api"
django-admin startproject freelance_api .
# the dot (.) at the end puts the project in the current directory — cleaner structure

# create a new app called "projects"
python manage.py startapp projects
```

### الـ Structure اللي Django بيعملها

```
freelance_api/              ← root folder
│
├── manage.py               ← the CLI tool for everything
│
├── freelance_api/          ← project config package
│   ├── __init__.py
│   ├── settings.py         ← all configuration here
│   ├── urls.py             ← the main URL router
│   ├── asgi.py             ← for async server (Channels, etc.)
│   └── wsgi.py             ← for traditional WSGI server (gunicorn)
│
└── projects/               ← your app
    ├── __init__.py
    ├── admin.py            ← register models for the admin panel
    ├── apps.py             ← app config (name, signals, etc.)
    ├── models.py           ← database models (the "M" in MTV)
    ├── views.py            ← view logic (the "V" in MTV)
    ├── urls.py             ← app-level URL patterns
    ├── serializers.py      ← DRF serializers (you'll add this)
    ├── tests.py            ← unit tests
    └── migrations/         ← auto-generated migration files
        └── __init__.py
```

> [!note] مهم جداً
> بعد ما تعمل app، لازم تضيفها في `INSTALLED_APPS` في `settings.py`. Django مش بيشوفها تلقائياً!

### الـ manage.py Commands الأساسية

```bash
python manage.py runserver          # start dev server on port 8000
python manage.py runserver 8080     # on a different port

python manage.py makemigrations     # generate migration files from model changes
python manage.py migrate            # apply migrations to the database

python manage.py createsuperuser    # create an admin user
python manage.py shell              # open an interactive Python shell with Django loaded
python manage.py shell_plus         # enhanced shell (needs django-extensions)

python manage.py collectstatic      # gather all static files in one folder (for production)
python manage.py test               # run all tests

python manage.py showmigrations     # see all migrations and their status
python manage.py sqlmigrate projects 0001  # see the actual SQL for a migration
```

---

## 🔷 الجزء الثالث — Models والـ Fields

### الـ Model هو إيه بالظبط؟

الـ Model هو الـ Python class اللي بيمثل **جدول في الـ Database**. كل attribute في الـ class بيبقى **column** في الجدول. Django بيتعامل مع كل ده ويعمل الـ SQL تلقائياً — إنت مش محتاج تكتب `CREATE TABLE` خالص.

```python
# projects/models.py

from django.db import models
from django.contrib.auth.models import User

class Project(models.Model):
    # CharField → VARCHAR in SQL (requires max_length)
    title = models.CharField(max_length=200)

    # TextField → TEXT in SQL (no length limit, for long text)
    description = models.TextField(blank=True)  # blank=True → field is optional in forms

    # DecimalField → DECIMAL in SQL (use for money, never use FloatField for money!)
    budget = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    # BooleanField → BOOLEAN in SQL
    is_active = models.BooleanField(default=True)

    # DateTimeField → DATETIME in SQL
    # auto_now_add=True → set once at creation, never changes
    # auto_now=True     → updated every time the object is saved
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # ForeignKey → one Project has one owner (User), one User can have many Projects
    # on_delete=CASCADE → if User is deleted, their Projects are deleted too
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='projects')

    def __str__(self):
        # this is what Django shows in the admin panel and shell
        return f"{self.title} — {self.owner.username}"

    class Meta:
        # order by newest first when querying
        ordering = ['-created_at']
        # human-readable name in admin panel
        verbose_name = 'Project'
        verbose_name_plural = 'Projects'
```

### جدول الـ Field Types الأهم

| Field | SQL Type | الاستخدام |
|---|---|---|
| `CharField(max_length=n)` | VARCHAR(n) | نص قصير — اسم، عنوان |
| `TextField` | TEXT | نص طويل — وصف، محتوى |
| `IntegerField` | INTEGER | أرقام صحيحة |
| `FloatField` | FLOAT | أرقام عشرية (مش مناسب للفلوس!) |
| `DecimalField` | DECIMAL | فلوس وأرقام دقيقة |
| `BooleanField` | BOOLEAN | True/False |
| `DateField` | DATE | تاريخ بدون وقت |
| `DateTimeField` | DATETIME | تاريخ مع وقت |
| `EmailField` | VARCHAR | إيميل — بيعمل validation تلقائياً |
| `URLField` | VARCHAR | URL — بيعمل validation تلقائياً |
| `ImageField` | VARCHAR | بيحفظ path الصورة في DB (مش الصورة نفسها!) |
| `FileField` | VARCHAR | نفس ImageField بس لأي نوع ملف |
| `ForeignKey` | INTEGER + FK constraint | علاقة many-to-one |
| `ManyToManyField` | junction table | علاقة many-to-many |
| `OneToOneField` | INTEGER + UNIQUE FK | علاقة one-to-one |
| `JSONField` | JSON/TEXT | بيخزن JSON مباشرة (Django 3.1+) |

### الـ Field Options المهمة

```python
# options that work on almost every field type:

name = models.CharField(
    max_length=100,
    null=True,        # allow NULL in the database column
    blank=True,       # allow empty value in forms/serializers
    default='',       # default value if none provided
    unique=True,      # no two rows can have the same value
    db_index=True,    # create a DB index for faster lookups
    editable=False,   # hide from admin forms and ModelForms
    verbose_name='Full Name',  # human-readable label
    help_text='Enter the full name as shown on ID',  # shown in forms
)
```

> ⚠️ **انتبه:** `null=True` و`blank=True` مش نفس الحاجة!
> - `null=True` → للـ Database: الـ column يقبل NULL
> - `blank=True` → للـ Forms/Serializers: الـ field مش required
> - لـ CharField و TextField، بنستخدم بس `blank=True` وما نستخدمش `null=True` — عشان ما نخليش فيه طريقتين لتمثيل "فراغ" (NULL و empty string).

### العلاقات بين الـ Models

```python
# ─── ForeignKey (Many-to-One) ─────────────────────────────────
# Many Tasks can belong to One Project
class Task(models.Model):
    project = models.ForeignKey(
        'Project',                   # the related model (string to avoid circular imports)
        on_delete=models.CASCADE,    # delete tasks when project is deleted
        related_name='tasks',        # Project.tasks.all() ← use this from the other side
    )

# on_delete options:
# CASCADE     → delete related objects
# PROTECT     → raise error if you try to delete the referenced object
# SET_NULL    → set FK to NULL (requires null=True on the field)
# SET_DEFAULT → set FK to default value
# DO_NOTHING  → do nothing (dangerous — can break DB integrity)

# ─── ManyToManyField ──────────────────────────────────────────
# A Project can have many Skills, a Skill can belong to many Projects
class Skill(models.Model):
    name = models.CharField(max_length=50)

class Project(models.Model):
    skills = models.ManyToManyField(
        Skill,
        blank=True,                  # project can have no skills
        related_name='projects',     # Skill.projects.all()
    )
    # Django creates a hidden junction table "projects_project_skills" automatically

# ─── OneToOneField ────────────────────────────────────────────
# Extend the built-in User model without touching it
class Profile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',      # User.profile ← single object, not queryset
    )
    bio = models.TextField(blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
    # upload_to → subfolder inside MEDIA_ROOT
```

---

## 🔷 الجزء الرابع — Migrations

### المشكلة اللي الـ Migrations بتحلها

تخيّل معايا إنك عندك database فيها data حقيقية. قررت تضيف column جديد على table. إزاي تعمل ده من غير ما تمسح الـ database وتبدأ من الأول؟ ده بالظبط اللي الـ Migrations بتحله.

الـ Migrations هي **تاريخ موثق** لكل تغيير حصل على الـ database schema — زي Git commits بس للـ database.

```bash
# Step 1: you change your model in models.py (add a field, change something, etc.)
# Step 2: tell Django to generate a migration file describing the change
python manage.py makemigrations

# Step 3: apply the migration to the actual database
python manage.py migrate
```

### ملف الـ Migration — إيه اللي جوه؟

```python
# projects/migrations/0001_initial.py
# Django generates this — you usually don't write it by hand

from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):

    # this migration depends on auth's migrations (because we reference User)
    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]

    operations = [
        # CreateModel → runs CREATE TABLE statement
        migrations.CreateModel(
            name='Project',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True)),
                ('title', models.CharField(max_length=200)),
                ('description', models.TextField(blank=True)),
                ('budget', models.DecimalField(decimal_places=2, default=0.0, max_digits=10)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('owner', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='projects',
                    to='auth.user'
                )),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
```

### الـ Migration Operations الشائعة

```bash
# see all migrations and their applied status
python manage.py showmigrations

# see the SQL that a specific migration will run
python manage.py sqlmigrate projects 0001

# rollback to a specific migration (undo everything after it)
python manage.py migrate projects 0002

# rollback ALL migrations for an app (dangerous! loses data)
python manage.py migrate projects zero

# create an empty migration (for custom SQL or data migrations)
python manage.py makemigrations projects --empty --name=add_default_categories
```

> ⚠️ **انتبه:** لو عملت `makemigrations` ومش لاقيه شاف التغييرات، تأكد إن الـ app موجودة في `INSTALLED_APPS`. ده أكتر غلط شائع!

### الـ Data Migration — لما تحتاج تشغّل كود Python على الـ Database

```python
# ده حالة خاصة — لما مش بس عايز تغير schema، عايز تعدّل data فعلية

from django.db import migrations

def add_default_skills(apps, schema_editor):
    # get model at the time of THIS migration — not the current model class!
    Skill = apps.get_model('projects', 'Skill')
    default_skills = ['Python', 'Django', 'JavaScript', 'React']
    for skill_name in default_skills:
        Skill.objects.get_or_create(name=skill_name)

def reverse_default_skills(apps, schema_editor):
    # how to UNDO this migration — always write this for safety
    Skill = apps.get_model('projects', 'Skill')
    Skill.objects.filter(name__in=['Python', 'Django', 'JavaScript', 'React']).delete()

class Migration(migrations.Migration):
    dependencies = [
        ('projects', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(add_default_skills, reverse_default_skills),
    ]
```

---

## 🔷 الجزء الخامس — ORM والـ QuerySets

### الـ ORM هو إيه؟

الـ ORM (Object-Relational Mapper) هو اللي بيترجم كودك Python لـ SQL. بدل ما تكتب:
```sql
SELECT * FROM projects_project WHERE is_active = TRUE ORDER BY created_at DESC;
```

بتكتب:
```python
Project.objects.filter(is_active=True).order_by('-created_at')
```

والجميل إن ده بيشتغل على SQLite, PostgreSQL, MySQL بدون تغيير!

### الـ CRUD الأساسي

```python
# ─── CREATE ──────────────────────────────────────────────────
# Method 1: create() — one step
project = Project.objects.create(
    title='Freelance Website',
    description='A platform for freelancers',
    budget=5000.00,
    owner=user,
)

# Method 2: instantiate + save() — two steps (more control)
project = Project(title='Freelance Website', owner=user)
project.budget = 5000.00
project.save()  # ← INSERT happens here

# ─── READ ────────────────────────────────────────────────────
# get all projects (returns a QuerySet — lazy, not executed yet)
all_projects = Project.objects.all()

# get one object by primary key (raises DoesNotExist if not found)
project = Project.objects.get(pk=5)
project = Project.objects.get(id=5)  # same thing — pk == id by default

# get one or return None (safer than get() — no exception)
project = Project.objects.filter(id=5).first()  # returns None if not found

# get_or_create — useful for seeding or avoiding duplicates
project, created = Project.objects.get_or_create(
    title='Freelance Website',  # fields to search by
    defaults={'budget': 5000, 'owner': user}  # fields to set only on creation
)
# created is True if object was just created, False if it already existed

# ─── UPDATE ──────────────────────────────────────────────────
# Method 1: get + set + save (triggers signals, calls full_clean, etc.)
project = Project.objects.get(pk=1)
project.budget = 7500.00
project.save()

# Method 2: update() on queryset — runs UPDATE directly in DB (faster, no signals)
Project.objects.filter(owner=user).update(is_active=False)
# ⚠️ update() does NOT call save() — signals and auto_now fields won't update!

# ─── DELETE ──────────────────────────────────────────────────
# delete one object
project = Project.objects.get(pk=1)
project.delete()

# delete multiple objects
Project.objects.filter(is_active=False).delete()  # ⚠️ careful! no confirmation
```

### الـ QuerySet Methods الأهم

```python
# ─── Filtering ────────────────────────────────────────────────
# filter() returns QuerySet (multiple results)
active_projects = Project.objects.filter(is_active=True)

# chaining filters — they're combined with AND
user_active = Project.objects.filter(is_active=True).filter(owner=user)
# equivalent:
user_active = Project.objects.filter(is_active=True, owner=user)

# exclude() — opposite of filter
non_active = Project.objects.exclude(is_active=True)

# ─── Lookup Types ─────────────────────────────────────────────
# format: fieldname__lookup=value
Project.objects.filter(title__exact='Website')        # exact match (default)
Project.objects.filter(title__iexact='website')       # case-insensitive exact
Project.objects.filter(title__contains='Free')        # LIKE '%Free%'
Project.objects.filter(title__icontains='free')       # case-insensitive LIKE
Project.objects.filter(title__startswith='Free')      # LIKE 'Free%'
Project.objects.filter(title__endswith='API')         # LIKE '%API'
Project.objects.filter(budget__gt=1000)               # greater than
Project.objects.filter(budget__gte=1000)              # greater than or equal
Project.objects.filter(budget__lt=5000)               # less than
Project.objects.filter(budget__lte=5000)              # less than or equal
Project.objects.filter(budget__range=(1000, 5000))    # BETWEEN
Project.objects.filter(owner__username='ali')         # traverse FK — __ across relations!
Project.objects.filter(skills__name='Python')         # traverse M2M — get projects with Python skill
Project.objects.filter(created_at__year=2024)         # filter by year
Project.objects.filter(created_at__date='2024-01-01') # filter by exact date
Project.objects.filter(description__isnull=True)      # IS NULL

# ─── OR queries with Q objects ────────────────────────────────
from django.db.models import Q
result = Project.objects.filter(
    Q(title__icontains='web') | Q(title__icontains='api')
)
# NOT queries
result = Project.objects.filter(~Q(is_active=False))

# ─── Ordering ─────────────────────────────────────────────────
Project.objects.order_by('title')         # ascending
Project.objects.order_by('-title')        # descending (note the minus)
Project.objects.order_by('owner__username', '-created_at')  # multiple fields

# ─── Limiting Results ─────────────────────────────────────────
Project.objects.all()[:10]          # LIMIT 10
Project.objects.all()[10:20]        # LIMIT 10 OFFSET 10
# ⚠️ negative indexing doesn't work on QuerySets! (no Project.objects.all()[-1])

# ─── Aggregation ──────────────────────────────────────────────
from django.db.models import Count, Sum, Avg, Max, Min

Project.objects.count()                              # total count
Project.objects.filter(is_active=True).count()      # filtered count
Project.objects.aggregate(total=Sum('budget'))       # → {'total': 25000.00}
Project.objects.aggregate(avg=Avg('budget'), max_b=Max('budget'))

# annotate — add calculated field to each object in queryset
from django.db.models import Count
projects = Project.objects.annotate(task_count=Count('tasks'))
# now each project has a .task_count attribute
for p in projects:
    print(p.title, p.task_count)
```

### الـ N+1 Problem — أهم مشكلة Performance في Django

```python
# ─── THE PROBLEM: N+1 queries ─────────────────────────────────
projects = Project.objects.all()  # 1 query

for project in projects:
    print(project.owner.username)  # ← 1 query PER project! if 100 projects → 101 queries!

# ─── THE SOLUTION: select_related (for ForeignKey / OneToOne) ─
projects = Project.objects.select_related('owner').all()  # 1 query with JOIN
# now accessing project.owner doesn't hit the database again

# deeper traversal — follow the chain
projects = Project.objects.select_related('owner__profile').all()

# ─── prefetch_related (for ManyToMany / reverse FK) ───────────
projects = Project.objects.prefetch_related('skills', 'tasks').all()
# 3 queries total: one for projects, one for skills, one for tasks
# Django does the joining in Python, not SQL — better for M2M

# ─── combine both ─────────────────────────────────────────────
projects = Project.objects.select_related('owner').prefetch_related('skills').all()
```

> **نصيحة الخبراء:** في أي مشروع حقيقي، شغّل Django Debug Toolbar. هيوريك كل query بتتنفذ وعدد الـ queries في كل request. لو شفت رقم كبير، ابدأ تستخدم `select_related` و`prefetch_related`.

---

## 🔷 الجزء السادس — Views الـ FBV

### الـ FBV هو إيه؟

الـ Function-Based View هي الطريقة الأبسط — بتكتب function بتاخد `request` وبترجع `response`. مناسبة لـ logic بسيط وسريع.

```python
# projects/views.py

from django.shortcuts import render, get_object_or_404, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.decorators import login_required
from .models import Project

# simplest view ever
def hello(request):
    return HttpResponse("Hello, Django!")  # returns plain text

# returning JSON (before DRF)
def project_json(request, pk):
    project = get_object_or_404(Project, pk=pk)  # returns 404 if not found
    data = {
        'id': project.id,
        'title': project.title,
        'budget': str(project.budget),  # Decimal → string for JSON
    }
    return JsonResponse(data)

# rendering a template
def project_list(request):
    projects = Project.objects.filter(is_active=True).select_related('owner')
    context = {
        'projects': projects,         # ← passed to template
        'total': projects.count(),
    }
    return render(request, 'projects/list.html', context)
    # render() is shortcut for: HttpResponse(loader.render_to_string(...))

# detail view — using URL parameter
def project_detail(request, pk):
    # get_object_or_404 → if not found, returns 404 response automatically
    project = get_object_or_404(Project, pk=pk, is_active=True)
    return render(request, 'projects/detail.html', {'project': project})
```

### الـ HTTP Methods في FBV

```python
# handling multiple HTTP methods in one view
def project_form(request, pk=None):
    if request.method == 'GET':
        # show the form
        project = get_object_or_404(Project, pk=pk) if pk else None
        return render(request, 'projects/form.html', {'project': project})

    elif request.method == 'POST':
        # process the form submission
        title = request.POST.get('title')
        budget = request.POST.get('budget')

        if not title:
            return render(request, 'projects/form.html', {'error': 'Title is required'})

        if pk:
            # update existing
            project = get_object_or_404(Project, pk=pk, owner=request.user)
            project.title = title
            project.budget = budget
            project.save()
        else:
            # create new
            project = Project.objects.create(
                title=title,
                budget=budget,
                owner=request.user,
            )
        return redirect('project-detail', pk=project.pk)

    return HttpResponse(status=405)  # Method Not Allowed

# ─── require_http_methods decorator — cleaner way ─────────────
from django.views.decorators.http import require_http_methods, require_GET, require_POST

@require_GET
def project_list(request):
    # only GET allowed — Django returns 405 for other methods automatically
    projects = Project.objects.all()
    return render(request, 'projects/list.html', {'projects': projects})
```

### الـ Decorators الشائعة للـ FBV

```python
from django.contrib.auth.decorators import login_required, permission_required

# redirect to login if user is not authenticated
@login_required(login_url='/auth/login/')
def create_project(request):
    # request.user is guaranteed to be authenticated here
    pass

# require specific permission
@permission_required('projects.add_project', raise_exception=True)
def admin_create(request):
    pass

# custom decorator — e.g., check if user owns the project
from functools import wraps

def project_owner_required(view_func):
    @wraps(view_func)
    def wrapper(request, pk, *args, **kwargs):
        project = get_object_or_404(Project, pk=pk)
        if project.owner != request.user:
            return HttpResponse(status=403)  # Forbidden
        return view_func(request, pk, *args, **kwargs)
    return wrapper

@login_required
@project_owner_required
def edit_project(request, pk):
    pass
```

---

## 🔷 الجزء السابع — Views الـ CBV

### ليه CBV؟

الـ Class-Based Views جت عشان الـ FBV بتكرر كود كتير. تخيّل إن عندك 10 models وكل واحد محتاج list, detail, create, update, delete. ده 50 function! الـ CBV بتحل ده بـ inheritance و generic views.

```python
# projects/views.py

from django.views import View
from django.views.generic import (
    ListView, DetailView, CreateView, UpdateView, DeleteView, TemplateView
)
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.urls import reverse_lazy

# ─── Base View — manual CBV ───────────────────────────────────
class ProjectListView(View):
    def get(self, request):
        projects = Project.objects.all()
        return render(request, 'projects/list.html', {'projects': projects})

    def post(self, request):
        # handle POST here
        pass

# ─── ListView — shows a list of objects ───────────────────────
class ProjectList(ListView):
    model = Project
    template_name = 'projects/list.html'  # default: "projects/project_list.html"
    context_object_name = 'projects'      # default: "object_list" — ugly, override it!
    paginate_by = 10                      # automatic pagination!

    def get_queryset(self):
        # override to customize the queryset
        return Project.objects.filter(
            is_active=True
        ).select_related('owner').order_by('-created_at')

    def get_context_data(self, **kwargs):
        # add extra context variables
        context = super().get_context_data(**kwargs)
        context['total_active'] = self.get_queryset().count()
        return context

# ─── DetailView — shows one object ────────────────────────────
class ProjectDetail(DetailView):
    model = Project
    template_name = 'projects/detail.html'
    context_object_name = 'project'
    # URL must have a pk or slug parameter — Django auto-fetches the object

# ─── CreateView ───────────────────────────────────────────────
class ProjectCreate(LoginRequiredMixin, CreateView):
    model = Project
    fields = ['title', 'description', 'budget', 'skills']  # which fields to show
    template_name = 'projects/form.html'
    success_url = reverse_lazy('project-list')  # redirect after success
    # reverse_lazy: like reverse() but evaluated lazily (needed at class level)

    def form_valid(self, form):
        # called when form is valid — set the owner before saving
        form.instance.owner = self.request.user
        return super().form_valid(form)

# ─── UpdateView ───────────────────────────────────────────────
class ProjectUpdate(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Project
    fields = ['title', 'description', 'budget', 'skills']
    template_name = 'projects/form.html'

    def test_func(self):
        # UserPassesTestMixin calls this — return True to allow access
        project = self.get_object()
        return project.owner == self.request.user

    def get_success_url(self):
        return reverse_lazy('project-detail', kwargs={'pk': self.object.pk})

# ─── DeleteView ───────────────────────────────────────────────
class ProjectDelete(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Project
    template_name = 'projects/confirm_delete.html'
    success_url = reverse_lazy('project-list')

    def test_func(self):
        return self.get_object().owner == self.request.user
```

### الـ Mixins — اللبنات الجاهزة

```
LoginRequiredMixin     → user must be logged in
PermissionRequiredMixin → user must have specific permission
UserPassesTestMixin    → run a custom test (test_func must return True/False)
SuccessMessageMixin    → show a success message after form submission
```

```python
# combine mixins — order matters! left to right
class MyView(LoginRequiredMixin, PermissionRequiredMixin, UpdateView):
    permission_required = 'projects.change_project'
    login_url = '/login/'
    raise_exception = True  # raise PermissionDenied instead of redirect
```

---

## 🔷 الجزء الثامن — URLs والـ Routing

### كيف Django بيوصل الـ Request للـ View الصح

```
Request: GET /projects/5/
             ↓
Django reads ROOT_URLCONF in settings.py → "freelance_api.urls"
             ↓
freelance_api/urls.py → includes("projects.urls")
             ↓
projects/urls.py → matches "5/" with path('<int:pk>/')
             ↓
calls the registered view with pk=5 ✅
```

### ملف الـ URLs

```python
# freelance_api/urls.py — the ROOT URL config
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),

    # include app URLs under a prefix
    path('api/', include('projects.urls')),
    path('api/auth/', include('django.contrib.auth.urls')),
]

# serve media files in development (NOT in production!)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
```

```python
# projects/urls.py — app-level URLs
from django.urls import path
from . import views

# always define app_name — enables namespacing
app_name = 'projects'

urlpatterns = [
    # path() — exact string matching
    path('projects/', views.ProjectList.as_view(), name='project-list'),

    # <int:pk> — captures an integer and passes it as pk to the view
    path('projects/<int:pk>/', views.ProjectDetail.as_view(), name='project-detail'),

    # <str:slug> — captures a string
    path('projects/<slug:slug>/', views.ProjectBySlug.as_view(), name='project-slug'),

    # <uuid:uuid> — captures a UUID
    path('projects/<uuid:uuid>/', views.ProjectByUUID.as_view(), name='project-uuid'),

    path('projects/create/', views.ProjectCreate.as_view(), name='project-create'),
    path('projects/<int:pk>/edit/', views.ProjectUpdate.as_view(), name='project-update'),
    path('projects/<int:pk>/delete/', views.ProjectDelete.as_view(), name='project-delete'),
]
```

### الـ URL Name Reversing

```python
# in views.py — generate URL from name
from django.urls import reverse, reverse_lazy

# reverse() — immediate (use in functions)
url = reverse('projects:project-detail', kwargs={'pk': 5})
# → '/api/projects/5/'

# reverse_lazy() — lazy evaluation (use in class attributes)
success_url = reverse_lazy('projects:project-list')

# in templates
# {% url 'projects:project-detail' pk=project.pk %}
# → '/api/projects/5/'
```

> **نصيحة الخبراء:** استخدم دايماً `name=` مع كل URL. لو بكرا غيّرت الـ URL pattern من `/projects/` لـ `/p/`، مش هتحتاج تغير أي حاجة في الـ views أو الـ templates — بس تغير الـ `path()` في `urls.py`.

---

## 🔷 الجزء التاسع — Templates والـ Template Language

### الـ Template هو إيه؟

الـ Template هو ملف HTML فيه **placeholder variables** وبعض الـ logic البسيطة. Django بياخد الـ Template + الـ context (Python dict) ويعمل **render** لـ HTML نهائي.

```html
<!-- projects/templates/projects/list.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Projects</title>
</head>
<body>
    <h1>All Projects ({{ total_active }})</h1>

    <!-- for loop over a queryset -->
    {% for project in projects %}
        <div class="project-card">
            <!-- access attributes with dot notation -->
            <h2>{{ project.title }}</h2>
            <p>By: {{ project.owner.username }}</p>

            <!-- filters: value|filter_name -->
            <p>Budget: ${{ project.budget|floatformat:2 }}</p>
            <p>Created: {{ project.created_at|date:"d M Y" }}</p>

            <!-- truncate long text -->
            <p>{{ project.description|truncatewords:20 }}</p>

            <!-- generate URL by name -->
            <a href="{% url 'projects:project-detail' pk=project.pk %}">View</a>
        </div>

    {% empty %}
        <!-- shown if the loop has no items -->
        <p>No projects found.</p>
    {% endfor %}

    <!-- pagination -->
    {% if is_paginated %}
        {% if page_obj.has_previous %}
            <a href="?page={{ page_obj.previous_page_number }}">Previous</a>
        {% endif %}
        <span>Page {{ page_obj.number }} of {{ page_obj.num_pages }}</span>
        {% if page_obj.has_next %}
            <a href="?page={{ page_obj.next_page_number }}">Next</a>
        {% endif %}
    {% endif %}
</body>
</html>
```

### الـ Template Inheritance

```html
<!-- templates/base.html — the parent template -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Freelance API{% endblock %}</title>
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav><!-- navigation here --></nav>

    <main>
        {% block content %}
        <!-- child templates fill this block -->
        {% endblock %}
    </main>

    <footer><!-- footer here --></footer>
    {% block extra_js %}{% endblock %}
</body>
</html>
```

```html
<!-- projects/list.html — the child template -->
{% extends 'base.html' %}

{% block title %}Projects | Freelance API{% endblock %}

{% block content %}
    <h1>All Projects</h1>
    <!-- content here... -->
{% endblock %}

{% block extra_js %}
    <script src="{% static 'projects/js/list.js' %}"></script>
{% endblock %}
```

### أهم الـ Template Tags والـ Filters

```django
{# if/elif/else #}
{% if user.is_authenticated %}
    Hello, {{ user.username }}!
{% elif user.is_staff %}
    Staff user
{% else %}
    Please login
{% endif %}

{# with — create a local variable #}
{% with total=projects.count %}
    You have {{ total }} project{{ total|pluralize }}
{% endwith %}

{# include — embed another template #}
{% include 'partials/project_card.html' with project=project %}

{# load — load a tag library #}
{% load static %}
<img src="{% static 'img/logo.png' %}">

{% load humanize %}
{{ 1500000|intcomma }}      → 1,500,000
{{ project.created_at|naturaltime }}  → 3 hours ago

{# Common filters #}
{{ name|lower }}            → lowercase
{{ name|upper }}            → UPPERCASE
{{ name|title }}            → Title Case
{{ name|default:"N/A" }}    → show "N/A" if name is empty
{{ name|default_if_none:"N/A" }}  → show "N/A" if name is None
{{ list|length }}           → count of items
{{ text|linebreaks }}       → convert \n to <br> and <p>
{{ value|yesno:"Yes,No,Maybe" }}  → True/False/None → custom string
```

---

## 🔷 الجزء العاشر — Forms والـ ModelForms

### الـ Django Form

الـ Form في Django مش بس HTML — هو Python class بيتكلف بالـ validation والـ cleaning تلقائياً.

```python
# projects/forms.py

from django import forms
from .models import Project, Skill

# ─── Regular Form — not tied to a model ───────────────────────
class ContactForm(forms.Form):
    name = forms.CharField(max_length=100, label='Your Name')
    email = forms.EmailField()
    message = forms.CharField(widget=forms.Textarea, min_length=10)
    priority = forms.ChoiceField(choices=[
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
    ])

    # field-level validation — method name must be: clean_<fieldname>
    def clean_name(self):
        name = self.cleaned_data['name']
        if name.lower() in ['admin', 'test']:
            raise forms.ValidationError("Please use your real name.")
        return name.strip()  # always return the cleaned value!

    # form-level validation — runs after all field validations
    def clean(self):
        cleaned_data = super().clean()
        name = cleaned_data.get('name')
        message = cleaned_data.get('message')
        # cross-field validation
        if name and message and name.lower() in message.lower():
            raise forms.ValidationError("Your message looks like spam.")
        return cleaned_data


# ─── ModelForm — tied to a model (most common in Django) ──────
class ProjectForm(forms.ModelForm):
    class Meta:
        model = Project
        fields = ['title', 'description', 'budget', 'skills']
        # exclude = ['owner', 'created_at']  # alternative: exclude specific fields

        widgets = {
            'description': forms.Textarea(attrs={'rows': 4, 'class': 'form-control'}),
            'budget': forms.NumberInput(attrs={'min': 0, 'step': '0.01'}),
        }

        labels = {
            'title': 'Project Title',
        }

        error_messages = {
            'title': {
                'required': 'Please provide a title for your project.',
                'max_length': 'Title must be 200 characters or less.',
            }
        }

    def clean_budget(self):
        budget = self.cleaned_data['budget']
        if budget < 0:
            raise forms.ValidationError("Budget cannot be negative.")
        return budget
```

### استخدام الـ Form في الـ View

```python
# projects/views.py

def create_project(request):
    if request.method == 'POST':
        form = ProjectForm(request.POST)  # bind POST data to form

        if form.is_valid():
            # cleaned_data is populated after is_valid() is True
            project = form.save(commit=False)  # don't save to DB yet
            project.owner = request.user       # set fields not in the form
            project.save()                     # now save to DB
            form.save_m2m()                    # save M2M relations (needed when commit=False)
            return redirect('project-detail', pk=project.pk)

        # if not valid, re-render form with errors
    else:
        form = ProjectForm()  # unbound (empty) form for GET request

    return render(request, 'projects/form.html', {'form': form})
```

```html
<!-- projects/form.html -->
<form method="post" enctype="multipart/form-data">
    {% csrf_token %}    <!-- ALWAYS include this for POST forms! -->

    {{ form.as_p }}     <!-- render all fields as <p> tags -->
    {# or: {{ form.as_table }} — as table rows #}
    {# or: {{ form.as_ul }} — as <li> items #}

    <!-- render individual fields for more control -->
    <div class="field">
        {{ form.title.label_tag }}
        {{ form.title }}
        {% if form.title.errors %}
            <ul class="errors">
                {% for error in form.title.errors %}
                    <li>{{ error }}</li>
                {% endfor %}
            </ul>
        {% endif %}
    </div>

    <button type="submit">Save Project</button>
</form>
```

---

## 🔷 الجزء الحادي عشر — Django Admin

### الـ Admin Panel — أقوى feature في Django

بكام سطر كود، بتاخد CRUD interface كامل لكل models!

```python
# projects/admin.py

from django.contrib import admin
from .models import Project, Task, Skill

# ─── Simple registration ───────────────────────────────────────
admin.site.register(Skill)

# ─── Custom ModelAdmin ────────────────────────────────────────
@admin.register(Project)  # decorator = shortcut for admin.site.register(Project, ProjectAdmin)
class ProjectAdmin(admin.ModelAdmin):
    # columns shown in the list view
    list_display = ['title', 'owner', 'budget', 'is_active', 'created_at']

    # clickable columns (link to detail page)
    list_display_links = ['title']

    # columns that can be edited directly in the list view
    list_editable = ['is_active']

    # columns you can sort by
    ordering = ['-created_at']

    # columns in the right sidebar for filtering
    list_filter = ['is_active', 'created_at', 'owner']

    # search box — __ for related fields
    search_fields = ['title', 'description', 'owner__username', 'owner__email']

    # how many rows per page
    list_per_page = 25

    # read-only fields in the detail form
    readonly_fields = ['created_at', 'updated_at']

    # organize fields in the detail form into sections
    fieldsets = [
        ('Basic Info', {
            'fields': ['title', 'description', 'owner']
        }),
        ('Financial', {
            'fields': ['budget'],
            'classes': ['collapse'],  # collapsible section
        }),
        ('Status & Dates', {
            'fields': ['is_active', 'created_at', 'updated_at'],
        }),
    ]

    # for M2M fields — use a better widget
    filter_horizontal = ['skills']  # or filter_vertical

    # add custom actions (bulk operations)
    actions = ['deactivate_projects']

    def deactivate_projects(self, request, queryset):
        count = queryset.update(is_active=False)
        self.message_user(request, f'{count} project(s) deactivated.')

    deactivate_projects.short_description = 'Deactivate selected projects'

    # override queryset to optimize admin queries
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('owner')

    # add computed column to list_display
    def owner_email(self, obj):
        return obj.owner.email
    owner_email.short_description = 'Owner Email'
    # add 'owner_email' to list_display to use it
```

### الـ Inline Admin — عرض الـ related objects جوه الـ parent

```python
# show Tasks inside Project detail page
class TaskInline(admin.TabularInline):  # or StackedInline for more space
    model = Task
    extra = 1  # number of empty forms to show for adding new tasks
    fields = ['title', 'status', 'due_date']
    readonly_fields = ['created_at']

@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    inlines = [TaskInline]  # ← attach the inline
    # ... rest of config
```

---

## 🔷 الجزء الثاني عشر — Authentication والـ Permissions

### الـ Built-in Auth System

Django جاي بنظام authentication كامل: users, groups, permissions, sessions — كل ده جاهز!

```python
# the built-in User model — always import from here
from django.contrib.auth.models import User

# ─── Creating users ───────────────────────────────────────────
# NEVER do: user = User(username='ali', password='123')
# ← password would be stored as plain text!

# Always use create_user() — it hashes the password
user = User.objects.create_user(
    username='ali',
    email='ali@example.com',
    password='securepassword123',  # hashed with PBKDF2 by default
)

# create superuser (has all permissions)
superuser = User.objects.create_superuser(
    username='admin',
    email='admin@example.com',
    password='adminpass',
)

# ─── Authentication ───────────────────────────────────────────
from django.contrib.auth import authenticate, login, logout

def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        # authenticate checks credentials and returns User or None
        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)  # creates session, sets request.user
            return redirect('home')
        else:
            return render(request, 'auth/login.html', {'error': 'Invalid credentials'})

    return render(request, 'auth/login.html')

def logout_view(request):
    logout(request)  # clears the session
    return redirect('login')
```

### الـ Custom User Model — أهم حاجة تعملها في بداية المشروع

```python
# بدل ما تضيف Profile في model منفصل، أحسن تعمل Custom User من الأول

# accounts/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # AbstractUser already has: username, email, first_name, last_name,
    #                            password, is_active, is_staff, date_joined, etc.

    # add your extra fields
    bio = models.TextField(blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    is_freelancer = models.BooleanField(default=False)

    def __str__(self):
        return self.email

# settings.py — tell Django to use your custom User model
AUTH_USER_MODEL = 'accounts.User'

# ⚠️ CRITICAL: set this BEFORE running the first migration
# If you set it after, you'll have a mess with existing tables
```

### الـ Permissions

```python
# checking permissions in views
from django.contrib.auth.decorators import permission_required

@permission_required('projects.add_project', raise_exception=True)
def create_project(request):
    pass

# checking in code
if request.user.has_perm('projects.change_project'):
    # allow editing
    pass

if request.user.has_perms(['projects.add_project', 'projects.change_project']):
    pass

# checking in templates
{% if perms.projects.add_project %}
    <a href="{% url 'project-create' %}">Create Project</a>
{% endif %}

# Django auto-creates 4 permissions per model: add, view, change, delete
# format: "app_label.action_modelname" e.g. "projects.delete_project"
```

---

## 🔷 الجزء الثالث عشر — Django REST Framework المقدمة

### ليه DRF؟

تخيّل إنك بتعمل API — كل request بتاخد JSON وبترجع JSON. من غير DRF، هتكتب كود كتير: serialize objects manually, validate JSON, handle errors, authentication... DRF بيعمل كل ده تلقائياً.

```python
# settings.py — add DRF to installed apps
INSTALLED_APPS = [
    # ... django built-ins ...
    'rest_framework',
    'rest_framework.authtoken',  # if using token authentication
    'projects',
]

# DRF global settings
REST_FRAMEWORK = {
    # default authentication methods
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
    ],
    # default permission policy
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    # default pagination
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
    # default renderers (JSON + browsable API)
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',  # remove in production
    ],
}
```

### الـ DRF Architecture — نظرة عامة

```
HTTP Request
      ↓
Authentication (من هو المستخدم؟)
      ↓
Permission (مسموح له؟)
      ↓
Throttling (كتير أوي requests؟)
      ↓
View (APIView / ViewSet)
      ↓
Serializer → validates input data
      ↓
Model / ORM (database)
      ↓
Serializer → converts objects to JSON
      ↓
Response (JSON) ✅
```

---

## 🔷 الجزء الرابع عشر — Serializers

### الـ Serializer هو إيه؟

الـ Serializer في DRF بيعمل حاجتين:
1. **Serialization**: Python object → JSON (لما بترجع response)
2. **Deserialization + Validation**: JSON → Python object (لما بتاخد request)

```python
# projects/serializers.py

from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Project, Task, Skill

# ─── Basic Serializer — manual ────────────────────────────────
class SkillSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    name = serializers.CharField(max_length=50)

    def create(self, validated_data):
        return Skill.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.name = validated_data.get('name', instance.name)
        instance.save()
        return instance


# ─── ModelSerializer — auto from model ────────────────────────
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        # read_only_fields — these can't be changed via the API
        read_only_fields = ['id']


class ProjectSerializer(serializers.ModelSerializer):
    # by default, ForeignKey shows just the ID
    # use a nested serializer to show full object data
    owner = UserSerializer(read_only=True)

    # computed field — read only, just runs a method
    task_count = serializers.SerializerMethodField()

    # write-only field — accepted in input, not in output
    owner_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Project
        fields = [
            'id', 'title', 'description', 'budget', 'is_active',
            'owner', 'owner_id', 'task_count', 'skills',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_task_count(self, obj):
        # obj is the Project instance being serialized
        return obj.tasks.count()

    # field-level validation
    def validate_budget(self, value):
        if value < 0:
            raise serializers.ValidationError("Budget cannot be negative.")
        return value

    # object-level validation (cross-field)
    def validate(self, data):
        if data.get('budget', 0) > 1_000_000 and not data.get('is_active', True):
            raise serializers.ValidationError(
                "You can't deactivate a project with a budget over 1M."
            )
        return data

    def create(self, validated_data):
        # validated_data is the cleaned data after all validations pass
        # context has the request: self.context['request'].user
        owner = self.context['request'].user
        project = Project.objects.create(owner=owner, **validated_data)
        return project
```

### الـ Serializer الأنواع الشائعة

```python
# ─── Nested Serializer ────────────────────────────────────────
class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'due_date']

class ProjectDetailSerializer(serializers.ModelSerializer):
    # نظهر الـ tasks كـ list من objects
    tasks = TaskSerializer(many=True, read_only=True)
    # many=True → this is a list, not a single object

    class Meta:
        model = Project
        fields = ['id', 'title', 'description', 'budget', 'tasks']


# ─── SlugRelatedField — show related object's field instead of ID ──
class ProjectSerializer(serializers.ModelSerializer):
    # instead of showing skill IDs, show skill names
    skills = serializers.SlugRelatedField(
        many=True,
        slug_field='name',         # the field to show
        queryset=Skill.objects.all()  # needed for write operations
    )

    class Meta:
        model = Project
        fields = ['id', 'title', 'skills']


# ─── Dynamic fields — limit fields per request ────────────────
class DynamicFieldsSerializer(serializers.ModelSerializer):
    def __init__(self, *args, **kwargs):
        fields = kwargs.pop('fields', None)  # pop before calling super
        super().__init__(*args, **kwargs)
        if fields:
            allowed = set(fields)
            existing = set(self.fields)
            for field_name in existing - allowed:
                self.fields.pop(field_name)

# usage:
# serializer = ProjectSerializer(project, fields=['id', 'title'])
```

---

## 🔷 الجزء الخامس عشر — APIView والـ Generic Views

### APIView — الـ Manual CBV لـ DRF

```python
# projects/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .serializers import ProjectSerializer
from .models import Project

class ProjectListAPIView(APIView):
    permission_classes = [IsAuthenticated]  # override global default

    def get(self, request):
        projects = Project.objects.filter(
            is_active=True
        ).select_related('owner')

        # many=True → serialize a list of objects
        # context={'request': request} → needed for hyperlinked fields, etc.
        serializer = ProjectSerializer(projects, many=True, context={'request': request})
        return Response(serializer.data)  # Response auto-serializes to JSON

    def post(self, request):
        serializer = ProjectSerializer(data=request.data, context={'request': request})

        if serializer.is_valid():
            serializer.save()  # calls serializer.create() with validated_data
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProjectDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, pk):
        # helper method to get object or raise 404
        try:
            return Project.objects.get(pk=pk)
        except Project.DoesNotExist:
            from rest_framework.exceptions import NotFound
            raise NotFound(detail="Project not found.")

    def get(self, request, pk):
        project = self.get_object(pk)
        serializer = ProjectSerializer(project, context={'request': request})
        return Response(serializer.data)

    def put(self, request, pk):
        project = self.get_object(pk)
        # partial=False (default) → all fields required
        serializer = ProjectSerializer(project, data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, pk):
        project = self.get_object(pk)
        # partial=True → only provided fields are validated/updated
        serializer = ProjectSerializer(project, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        project = self.get_object(pk)
        project.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)  # 204 = success, no body
```

### Generic Views — بتكتب نص الكود

```python
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import Project
from .serializers import ProjectSerializer
from .permissions import IsOwnerOrReadOnly  # custom permission (later)

# ─── ListCreateAPIView — GET list + POST create ────────────────
class ProjectListCreateView(generics.ListCreateAPIView):
    serializer_class = ProjectSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # customize the queryset — e.g. filter by current user
        return Project.objects.filter(
            owner=self.request.user
        ).select_related('owner').prefetch_related('skills')

    def perform_create(self, serializer):
        # called when creating — set owner to current user
        serializer.save(owner=self.request.user)


# ─── RetrieveUpdateDestroyAPIView — GET + PUT + PATCH + DELETE ─
class ProjectDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProjectSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrReadOnly]

    def get_queryset(self):
        return Project.objects.select_related('owner').prefetch_related('skills', 'tasks')


# other generic views:
# ListAPIView              → GET list only
# CreateAPIView            → POST only
# RetrieveAPIView          → GET single only
# UpdateAPIView            → PUT + PATCH only
# DestroyAPIView           → DELETE only
# RetrieveUpdateAPIView    → GET + PUT + PATCH
# RetrieveDestroyAPIView   → GET + DELETE
```

---

## 🔷 الجزء السادس عشر — ViewSets والـ Routers

### الـ ViewSet — أحسن طريقة لـ RESTful APIs

الـ ViewSet بيجمع كل الـ actions (list, create, retrieve, update, destroy) في class واحد. وبعدين الـ Router بيعمل الـ URLs تلقائياً!

```python
# projects/views.py

from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Project
from .serializers import ProjectSerializer, ProjectDetailSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    # ModelViewSet gives you ALL CRUD operations automatically:
    # list()     → GET    /projects/
    # create()   → POST   /projects/
    # retrieve() → GET    /projects/{pk}/
    # update()   → PUT    /projects/{pk}/
    # partial_update() → PATCH /projects/{pk}/
    # destroy()  → DELETE /projects/{pk}/

    serializer_class = ProjectSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrReadOnly]

    def get_queryset(self):
        queryset = Project.objects.select_related('owner').prefetch_related('skills')
        # allow filtering via query params: /projects/?is_active=true
        is_active = self.request.query_params.get('is_active')
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == 'true')
        return queryset

    def get_serializer_class(self):
        # use different serializers for list vs detail
        if self.action == 'retrieve':
            return ProjectDetailSerializer
        return ProjectSerializer

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def perform_destroy(self, instance):
        # soft delete instead of hard delete
        instance.is_active = False
        instance.save()

    # ─── Custom Actions ───────────────────────────────────────
    # @action creates an extra endpoint beyond the standard CRUD
    @action(detail=True, methods=['post'], url_path='activate')
    def activate(self, request, pk=None):
        # URL: POST /projects/{pk}/activate/
        project = self.get_object()  # calls get_queryset() + filters by pk
        project.is_active = True
        project.save()
        return Response({'status': 'project activated'})

    @action(detail=False, methods=['get'], url_path='my-projects')
    def my_projects(self, request):
        # URL: GET /projects/my-projects/
        # detail=False → no pk in URL — it's a collection action
        projects = Project.objects.filter(owner=request.user)
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
```

### الـ Router — بيعمل URLs تلقائياً

```python
# projects/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
# register(prefix, viewset, basename)
router.register('projects', views.ProjectViewSet, basename='project')
router.register('skills', views.SkillViewSet, basename='skill')

# DefaultRouter auto-generates these URLs:
# GET    /projects/               → list
# POST   /projects/               → create
# GET    /projects/{pk}/          → retrieve
# PUT    /projects/{pk}/          → update
# PATCH  /projects/{pk}/          → partial_update
# DELETE /projects/{pk}/          → destroy
# POST   /projects/{pk}/activate/ → activate (custom action)
# GET    /projects/my-projects/   → my_projects (custom action)

urlpatterns = [
    path('', include(router.urls)),
]
```

---

## 🔷 الجزء السابع عشر — Permissions والـ Authentication في DRF

### الـ Built-in Permissions

```python
from rest_framework.permissions import (
    AllowAny,           # anyone can access — public endpoints
    IsAuthenticated,    # must be logged in
    IsAdminUser,        # must be staff (is_staff=True)
    IsAuthenticatedOrReadOnly,  # read=all, write=authenticated only
)

# apply globally in settings.py:
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': ['rest_framework.permissions.IsAuthenticated'],
}

# override per view:
class PublicProjectList(generics.ListAPIView):
    permission_classes = [AllowAny]  # anyone can see the list
    serializer_class = ProjectSerializer
    queryset = Project.objects.filter(is_active=True)
```

### الـ Custom Permissions

```python
# projects/permissions.py

from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsOwnerOrReadOnly(BasePermission):
    """
    Allow read access to all users.
    Allow write access only to the object's owner.
    """
    def has_permission(self, request, view):
        # called before has_object_permission — for general access
        # return True to let it proceed to has_object_permission
        return True

    def has_object_permission(self, request, view, obj):
        # called for detail views (retrieve, update, destroy)
        # SAFE_METHODS = ('GET', 'HEAD', 'OPTIONS')
        if request.method in SAFE_METHODS:
            return True  # anyone can read
        return obj.owner == request.user  # only owner can write


class IsFreelancer(BasePermission):
    """Only users marked as freelancers can access."""
    message = "You must be a registered freelancer to perform this action."

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.is_freelancer  # custom field on User model
        )
```

### الـ Authentication في DRF

```python
# ─── Token Authentication ─────────────────────────────────────
# settings.py
INSTALLED_APPS = ['rest_framework.authtoken']

# generate token URL — clients send: Authorization: Token <token_value>
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path('api/auth/login/', obtain_auth_token, name='api-login'),
]

# create token for user (in views or management command)
from rest_framework.authtoken.models import Token
token, created = Token.objects.get_or_create(user=user)
print(token.key)  # → "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"

# the client sends every request with this header:
# Authorization: Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b


# ─── JWT Authentication (more modern — needs djangorestframework-simplejwt) ──
# pip install djangorestframework-simplejwt

from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('api/auth/login/', TokenObtainPairView.as_view(), name='token-obtain'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
]

# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

# client sends: Authorization: Bearer <access_token>
# access tokens expire (default 5 min), refresh tokens last longer (default 1 day)
```

---

## 🔷 الجزء الثامن عشر — Pagination والـ Filtering

### الـ Pagination

```python
# ─── Global pagination in settings.py ────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
# client requests: GET /projects/?page=2
# response includes: count, next, previous, results

# ─── Custom Pagination ────────────────────────────────────────
from rest_framework.pagination import PageNumberPagination, LimitOffsetPagination

class ProjectPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'  # client can set: ?page_size=25
    max_page_size = 100
    page_query_param = 'page'

class LargeResultPagination(LimitOffsetPagination):
    default_limit = 10
    max_limit = 1000
    # client sends: ?limit=50&offset=100

# apply to a specific view:
class ProjectViewSet(viewsets.ModelViewSet):
    pagination_class = ProjectPagination
    # ...
```

### الـ Filtering

```python
# pip install django-filter

# settings.py
INSTALLED_APPS = ['django_filters']

REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}

# projects/filters.py
import django_filters
from .models import Project

class ProjectFilter(django_filters.FilterSet):
    # exact filter
    is_active = django_filters.BooleanFilter()

    # range filters
    budget_min = django_filters.NumberFilter(field_name='budget', lookup_expr='gte')
    budget_max = django_filters.NumberFilter(field_name='budget', lookup_expr='lte')

    # date range
    created_after = django_filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = django_filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')

    # filter by related field
    owner_username = django_filters.CharFilter(field_name='owner__username', lookup_expr='icontains')

    # filter by M2M
    skill = django_filters.CharFilter(field_name='skills__name', lookup_expr='iexact')

    class Meta:
        model = Project
        fields = ['is_active', 'budget_min', 'budget_max']

# projects/views.py
class ProjectViewSet(viewsets.ModelViewSet):
    filterset_class = ProjectFilter

    # SearchFilter: ?search=keyword — searches the listed fields
    search_fields = ['title', 'description', 'owner__username']

    # OrderingFilter: ?ordering=budget or ?ordering=-created_at
    ordering_fields = ['budget', 'created_at', 'title']
    ordering = ['-created_at']  # default ordering
```

---

## 🔷 الجزء التاسع عشر — Advanced Topics والـ Best Practices

### الـ Signals — بتشغّل كود لما events تحصل

```python
# projects/signals.py

from django.db.models.signals import post_save, pre_delete, m2m_changed
from django.dispatch import receiver
from django.contrib.auth.models import User
from .models import Project, Profile

# fires AFTER a User is saved (created or updated)
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    # sender → the model class
    # instance → the actual saved object
    # created → True if new object, False if updated
    if created:
        Profile.objects.create(user=instance)  # auto-create profile on user creation

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()  # save profile when user is saved

# ⚠️ IMPORTANT: signals don't fire on queryset.update() — only on .save()

# connect signals in apps.py
# projects/apps.py
from django.apps import AppConfig

class ProjectsConfig(AppConfig):
    name = 'projects'

    def ready(self):
        import projects.signals  # ← this connects the signals
```

### الـ Custom Exception Handler

```python
# utils/exceptions.py

from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    # call DRF's default first to get the standard response
    response = exception_handler(exc, context)

    if response is not None:
        # wrap in a consistent format
        response.data = {
            'success': False,
            'error': {
                'status_code': response.status_code,
                'message': response.data,
            }
        }
    return response

# settings.py
REST_FRAMEWORK = {
    'EXCEPTION_HANDLER': 'utils.exceptions.custom_exception_handler',
}
```

### الـ select_related vs prefetch_related مقارنة

| | `select_related` | `prefetch_related` |
|---|---|---|
| العلاقة | ForeignKey, OneToOne | ManyToMany, reverse FK |
| طريقة الـ Join | SQL JOIN واحد | queries منفصلة + Python join |
| عدد الـ Queries | 1 query | 2+ queries (but efficient) |
| مناسب لـ | علاقة واحدة (owner, profile) | علاقات متعددة (tags, skills) |

### الـ select_for_update — Race Conditions

```python
from django.db import transaction

def transfer_budget(from_project_id, to_project_id, amount):
    # wrap in atomic transaction — all or nothing
    with transaction.atomic():
        # lock the rows during the transaction — prevents race conditions
        from_project = Project.objects.select_for_update().get(pk=from_project_id)
        to_project = Project.objects.select_for_update().get(pk=to_project_id)

        if from_project.budget < amount:
            raise ValueError("Insufficient budget")

        from_project.budget -= amount
        to_project.budget += amount
        from_project.save()
        to_project.save()
        # if any exception happens here, BOTH saves are rolled back
```

### الـ Caching في Django

```python
# settings.py — setup Redis as cache backend
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}

# in views — cache expensive queryset
from django.core.cache import cache

def get_top_projects():
    cache_key = 'top_projects_list'
    result = cache.get(cache_key)

    if result is None:
        # cache miss — compute the expensive operation
        result = list(Project.objects.filter(
            is_active=True
        ).order_by('-budget')[:10].values())

        # store in cache for 15 minutes (900 seconds)
        cache.set(cache_key, result, timeout=900)

    return result

# invalidate cache when data changes
def invalidate_project_cache():
    cache.delete('top_projects_list')
    cache.delete_many(['key1', 'key2'])  # delete multiple keys at once

# ─── @cache_page decorator for views ─────────────────────────
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)  # cache for 15 minutes
def project_list(request):
    pass
```

### نصائح الـ Production

```python
# settings/production.py — separate settings for production

import os

DEBUG = False  # NEVER True in production

ALLOWED_HOSTS = ['api.mysite.com', 'www.mysite.com']

# security settings
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY')  # from env variable, never hardcoded!
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True

# Database — use PostgreSQL in production
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST', 'localhost'),
        'PORT': os.environ.get('DB_PORT', '5432'),
    }
}

# Static files — serve with WhiteNoise or Nginx
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files — use S3 or similar in production
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
AWS_STORAGE_BUCKET_NAME = os.environ.get('AWS_BUCKET_NAME')

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/django/error.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': True,
        },
    },
}
```

---

## 🗺️ خريطة Django & DRF كاملة

```mermaid
mindmap
  root((Django & DRF))
    Django Core
      MTV Pattern
        Model
        Template
        View
      Project Setup
        settings.py
        manage.py
        Apps
    Models & Database
      Field Types
        CharField<br/>TextField<br/>IntegerField
        DecimalField<br/>BooleanField<br/>DateTimeField
        ImageField<br/>JSONField
      Relationships
        ForeignKey<br/>on_delete options
        ManyToManyField<br/>junction table
        OneToOneField
      ORM
        CRUD Operations
        QuerySet Methods<br/>filter, exclude, annotate
        Lookups<br/>exact, contains, gt, lt
        Q Objects<br/>OR queries
        select_related<br/>prefetch_related
    Migrations
      makemigrations
      migrate
      Data Migrations
      Rollback
    Views
      FBV
        HttpResponse<br/>JsonResponse
        render shortcut
        Decorators
      CBV
        ListView<br/>DetailView
        CreateView<br/>UpdateView<br/>DeleteView
        Mixins<br/>LoginRequired
    URLs
      path patterns
        int slug uuid
      include
      reverse<br/>reverse_lazy
      app_name namespacing
    Templates
      DTL Syntax
        Variables<br/>Tags<br/>Filters
      Inheritance
        extends<br/>block<br/>include
      Static Files
    Forms
      Form
        clean_field<br/>clean
      ModelForm
        Meta class
        widgets<br/>labels
    Admin
      ModelAdmin
        list_display<br/>list_filter
        search_fields<br/>fieldsets
      Inlines
        TabularInline<br/>StackedInline
      Custom Actions
    Auth
      Built-in User
      Custom User<br/>AbstractUser
      Login Logout<br/>authenticate
      Permissions<br/>Groups
    Django REST Framework
      Serializers
        ModelSerializer
        Nested<br/>SerializerMethodField
        Validation<br/>validate_field
      Views
        APIView<br/>manual
        Generic Views<br/>ListCreate etc
        ViewSets<br/>ModelViewSet
        Custom Actions<br/>@action
      Routers
        DefaultRouter
        Auto URLs
      Permissions
        IsAuthenticated<br/>AllowAny
        Custom<br/>BasePermission
        has_object_permission
      Authentication
        Token Auth
        JWT<br/>simplejwt
        Session Auth
      Pagination
        PageNumber<br/>LimitOffset
        Custom Page Size
      Filtering
        DjangoFilterBackend
        SearchFilter<br/>OrderingFilter
        FilterSet
    Advanced
      Signals
        post_save<br/>pre_delete
        @receiver
      Caching
        cache.get<br/>cache.set
        Redis Backend
      Transactions
        atomic
        select_for_update
      Production
        DEBUG=False
        PostgreSQL
        Environment Variables
```

---

## ✅ Checkpoint — أسئلة إنترفيو Django & DRF

**س: إيه الفرق بين `null=True` و`blank=True` في الـ Field؟**
> `null=True` بيسمح للـ database column إنه يقبل قيمة NULL فعلياً. `blank=True` بيسمح للـ form أو الـ serializer إنه يقبل قيمة فاضية وقت الـ validation. لـ CharField و TextField، بنستخدم بس `blank=True` وما نستخدمش `null=True` عشان ما نخليش فيه طريقتين لتمثيل "فراغ" — يعني NULL و empty string.

**س: إيه الـ N+1 Problem وإزاي تحلها في Django؟**
> الـ N+1 problem بتحصل لما بتعمل query لجلب N objects، وبعدين لكل object بتعمل query تاني عشان تجيب الـ related object. الحل: `select_related()` للـ ForeignKey والـ OneToOne — بيعمل SQL JOIN واحد. `prefetch_related()` للـ ManyToMany والـ reverse FK — بيعمل queries منفصلة وبعدين بيعمل الـ join في Python.

**س: إيه الفرق بين `get()` و`filter().first()` في الـ ORM؟**
> `get()` بترجع object واحد وبترمي `DoesNotExist` exception لو مش موجود، و`MultipleObjectsReturned` لو أكتر من واحد. `filter().first()` بترجع أول object أو `None` لو مفيش — من غير exceptions. بنستخدم `get()` لما متأكد إن الـ result واحد بالظبط (زي جلب object بالـ id)، و`filter().first()` في الحالات التانية.

**س: إيه الفرق بين الـ Serializer العادي والـ ModelSerializer؟**
> الـ `Serializer` العادي بتعرّف كل field يدوياً وبتكتب `create()` و`update()` بنفسك. الـ `ModelSerializer` بيولّد الـ fields تلقائياً من الـ Model، وبيجيب `create()` و`update()` جاهزين. بنستخدم `ModelSerializer` في 90% من الحالات — أسرع وأقل كود. بنستخدم `Serializer` لما محتاج data مش بيتطابق مع أي model.

**س: إيه الفرق بين APIView والـ ViewSet؟**
> `APIView` بتكتب method لكل HTTP verb (`get`, `post`, `delete`...) وبتعمل URL ليها يدوياً. `ViewSet` بيجمع الـ actions دي في class واحد (`list`, `create`, `retrieve`...) والـ Router بيعمل الـ URLs تلقائياً. الـ ViewSet أسرع في الكتابة وأكتر consistency مع REST standards، بس الـ APIView بيديك control أكتر للـ custom logic.

**س: إيه أكبر غلطة الـ juniors بيعملوها في Django/DRF؟**
> تلاتة:
> 1. مش بيعملوا `select_related` و`prefetch_related` → الـ N+1 problem بتخلي الـ API بطيئة.
> 2. بيحطوا logic في الـ View بدل ما يحطوه في الـ Model أو الـ Serializer — الـ View المفروض تكون رفيعة.
> 3. مش بيغيروا الـ User model في أول المشروع — لو حاولت تعمله بعد ما عملت migrations، هتبقى في ورطة.

---

## 🛠️ Practical Exercise — بناء Freelance Projects API

### Task 1 — Setup المشروع

```bash
# create and activate virtual environment
python -m venv venv
source venv/bin/activate  # on Windows: venv\Scripts\activate

# install packages
pip install django djangorestframework djangorestframework-simplejwt django-filter pillow

# create project and app
django-admin startproject freelance_api .
python manage.py startapp projects
python manage.py startapp accounts

# add to INSTALLED_APPS and create initial migration
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

### Task 2 — Models والـ Serializers

ابني الـ models دية:
- `User` (custom, يرث من AbstractUser) — فيها `is_freelancer` field
- `Skill` — `name` بس
- `Project` — `title`, `description`, `budget`, `is_active`, `owner` (FK), `skills` (M2M)
- `Proposal` — freelancer بيقدم على project (FK لـ Project والـ User)

```python
# starter hint for Proposal model
class Proposal(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='proposals')
    freelancer = models.ForeignKey(
        settings.AUTH_USER_MODEL,  # always use settings.AUTH_USER_MODEL, not User directly!
        on_delete=models.CASCADE,
        related_name='proposals'
    )
    cover_letter = models.TextField()
    proposed_budget = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=20,
        choices=[('pending', 'Pending'), ('accepted', 'Accepted'), ('rejected', 'Rejected')],
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['project', 'freelancer']  # no duplicate proposals!
```

### Task 3 — الـ API Endpoints

ابني الـ endpoints دية باستخدام ViewSets:

| Endpoint | Method | Description |
|---|---|---|
| `/api/projects/` | GET | list all active projects |
| `/api/projects/` | POST | create project (authenticated only) |
| `/api/projects/{pk}/` | GET | project details |
| `/api/projects/{pk}/` | PATCH | update (owner only) |
| `/api/projects/{pk}/` | DELETE | soft delete (owner only) |
| `/api/projects/{pk}/proposals/` | GET | list proposals for a project |
| `/api/projects/{pk}/apply/` | POST | submit a proposal (custom action) |
| `/api/auth/login/` | POST | get JWT tokens |
| `/api/auth/refresh/` | POST | refresh access token |

| الملف | السؤال |
|---|---|
| `permissions.py` | هل الـ permission فارقة لو user مش freelancer يقدم على project؟ |
| `serializers.py` | إزاي بتمنع freelancer من تقديم أكتر من proposal على نفس الـ project؟ |
| `views.py` | فين أنسب مكان تحط الـ N+1 optimization؟ |

---

## 🫒 زتونة الإنترفيو

> **"Django framework بيشتغل على الـ MTV pattern — الـ Model بيتعامل مع الـ database عن طريق ORM قوي، الـ View بتحتوي الـ logic، والـ Template بتعرض الـ HTML. في الـ APIs، بنستخدم Django REST Framework اللي بيضيف Serializers للـ validation والـ serialization، وGeneric Views وViewSets اللي بتوفر كتير من الـ boilerplate. أهم نقطة في الـ performance هي N+1 problem — بنحلها بـ select_related للـ ForeignKey وprefetch_related للـ ManyToMany. في الأمان، دايماً بنستخدم Custom User Model من البداية، ومش بنحفظ sensitive data في الكود، وبنستخدم JWT للـ APIs أو Token Auth. الـ ViewSet مع Router بيوفر كتير من الوقت ويضمن REST-compliant API تلقائياً."**

---

```mermaid
flowchart TD
    A["HTTP Request"] --> B["URL Resolver<br/>urls.py"]
    B --> C{"Match Found?"}
    C -- No --> D["404 Not Found"]
    C -- Yes --> E["Middleware Stack<br/>Authentication<br/>CSRF<br/>Session"]
    E --> F["View<br/>FBV / CBV / APIView / ViewSet"]
    F --> G{"Needs Data?"}
    G -- Yes --> H["ORM Query<br/>Model.objects.filter()"]
    H --> I[("Database<br/>SQLite / PostgreSQL")]
    I --> H
    H --> J["QuerySet Result"]
    G -- No --> K["Direct Logic"]
    J --> L["Serializer / Template"]
    K --> L
    L --> M["Response<br/>JSON / HTML"]
    M --> N["Client ✅"]

    style A fill:#4f46e5,color:#fff
    style N fill:#059669,color:#fff
    style D fill:#dc2626,color:#fff
    style I fill:#d97706,color:#fff
```

---

*Next → مشروع حقيقي — ابني Freelance Platform API من الصفر بـ Django + DRF + PostgreSQL + Docker*

---
*آخر تحديث: 2026-04-23 | Django 5.x + DRF 3.15+*
