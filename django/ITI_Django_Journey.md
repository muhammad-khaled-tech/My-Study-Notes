# 🎓 رحلة Django — من الصفر للـ REST API
> بنبني من الصفر الحقيقي. سطر بسطر. مفيش حاجة هتعدي من غير ما تفهمها.
> **المشروع:** ITI School Management System — من Messy Monolith لـ Professional REST API

---

# 🗺️ خريطة الرحلة الكاملة

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'primaryBorderColor': '#4a5568', 'lineColor': '#718096', 'secondaryColor': '#1a202c', 'tertiaryColor': '#2d3748', 'background': '#1a202c', 'mainBkg': '#2d3748', 'nodeBorder': '#4a5568', 'clusterBkg': '#1a202c', 'titleColor': '#e2e8f0', 'edgeLabelBackground': '#2d3748', 'attributeBackgroundColorEven': '#2d3748', 'attributeBackgroundColorOdd': '#1a202c'}}}%%
graph TD
    P1["🏗️ المرحلة الأولى<br>الأساسيات والإعداد<br>Python on the Web"]
    P2["🧱 المرحلة الثانية<br>الـ Monolith MVP<br>MTV Architecture"]
    P3["🗄️ المرحلة الثالثة<br>إتقان الـ Database<br>ORM + Admin Panel"]
    P4["⚙️ المرحلة الرابعة<br>إعادة الهيكلة<br>CBVs + Middleware"]
    P5["🔐 المرحلة الخامسة<br>الأمان والـ Auth<br>Sessions + Permissions"]
    P6["🚀 المرحلة السادسة<br>عصر الـ API<br>Django REST Framework"]

    P1 --> P2 --> P3 --> P4 --> P5 --> P6

    style P1 fill:#276749,color:#e2e8f0,stroke:#2f855a
    style P2 fill:#2b6cb0,color:#e2e8f0,stroke:#2c5282
    style P3 fill:#744210,color:#e2e8f0,stroke:#975a16
    style P4 fill:#553c9a,color:#e2e8f0,stroke:#6b46c1
    style P5 fill:#702459,color:#e2e8f0,stroke:#97266d
    style P6 fill:#2c7a7b,color:#e2e8f0,stroke:#285e61
```

---

# 🏗️ المرحلة الأولى — الأساسيات والإعداد

---

## قبل ما نكتب سطر واحد كود — لازم نفهم إيه اللي بيحصل

أنت عارف إنك لما بتفتح browser وبتكتب `google.com` بيحصل request — response cycle. بس إيه اللي بيحصل بالظبط جوه ده؟

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffffff', 'mainBkg': '#ffffff', 'lineColor': '#444'}}}%%
graph TD
    %% تعريف ستايلات مريحة للعين (Clean & Modern)
    
    %% ستايل المستخدم (أزرق هادي)
    classDef userBox fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#1565c0,font-weight:bold;
    
    %% ستايل ديجانجو (بنفسجي فاتح)
    classDef djangoBox fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#7b1fa2,font-weight:bold;
    
    %% ستايل قاعدة البيانات (رمادي احترافي)
    classDef dbBox fill:#fafafa,stroke:#455a64,stroke-width:2px,color:#455a64;
    
    %% ستايل الرد النهائي (أخضر مينت)
    classDef outBox fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#2e7d32,font-weight:bold;

    %% --- طلب المستخدم ---
    subgraph S1 [" مرحلة الطلب - Request "]
        direction LR
        Request(["🌐 المتصفح يرسل طلب"]):::userBox
    end

    S1 ==> S2

    %% --- معالجة ديجانجو ---
    subgraph S2 [" محرك ديجانجو - Django Engine "]
        direction TB
        URL["🔍 URL Resolver"]:::djangoBox
        View["⚙️ View Logic"]:::djangoBox
        URL --> View
    end

    S2 ==> S3

    %% --- قاعدة البيانات ---
    subgraph S3 [" البيانات - SQLite "]
        direction LR
        DB[("🗄️ Database")]:::dbBox
        View -- "ORM Query" --> DB
        DB -- "Data" --> View
    end

    S3 ==> S4

    %% --- الرد النهائي ---
    subgraph S4 [" الرد - Response "]
        direction TB
        Response["📄 Template / JSON"]:::outBox
        Final([✅ وصول الرد للمتصفح]):::outBox
        View --> Response --> Final
    end
```

الـ Browser بيبعت HTTP Request → الـ Django بيستقبله → بيرد بـ HTTP Response.

ده الـ **Web Framework** — ببساطة هو كود جاهز بيتعامل مع كل ده بدلاً منك.

---

## ليه Django تحديداً؟

> [!abstract] 🧠 المفهوم المعماري
> Django بيقول لك "Batteries Included" — يعني كل حاجة جاهزة معاك من أول ما تبدأ:
> - **ORM** جاهز للتعامل مع الـ Database بـ Python بدل SQL.
> - **Admin Panel** جاهز تلقائياً من غير ما تكتب سطر.
> - **Authentication System** كامل جاهز.
> - **Template Engine** لعمل HTML ديناميكي.
> - **Forms System** مع Validation.
>
> قارنه بـ Flask مثلاً — Flask بيديك "المطبخ الفاضي"، Django بيديك "مطبخ فيه كل حاجة".

---

## ليه Python على الـ Web مختلف عن Python العادية؟

لما بتكتب script عادي بـ Python، بيشتغل مرة وينتهي. لكن الـ Web Server مختلف:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph LR
    subgraph عادي["Python Script عادي"]
        A1["ابدأ"] --> B1["نفّذ الكود"] --> C1["خلّص"]
    end
    subgraph ويب["Django Web Server"]
        A2["ابدأ"] --> B2["استنّى Request"]
        B2 --> C2["معالجة الـ Request"]
        C2 --> D2["ابعت Response"]
        D2 --> B2
    end

    style عادي fill:#1a202c,stroke:#4a5568
    style ويب fill:#1a202c,stroke:#2b6cb0
```

الـ Server مش بيخلص — بيفضل شغال ومستنّى requests طول ما هو شغّال. ده مفهوم الـ **Long-Running Process**.

---

## 💻 تجهيز البيئة — Ubuntu + VS Code

### الخطوة الأولى: تثبيت Python و pip

افتح terminal واتأكد إن Python مثبت:

```bash
python3 --version
pip3 --version
```

لو مش موجود:

```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv -y
```

### الخطوة التانية: إنشاء Virtual Environment

ده أهم خطوة — الـ Virtual Environment بيعزل dependencies المشروع عن الـ system Python.

```bash
mkdir iti-school
cd iti-school
python3 -m venv venv
```

شغّل الـ Virtual Environment:

```bash
source venv/bin/activate
```

هتشوف `(venv)` قبل الـ prompt — ده يعني الـ venv شغّال:

```
(venv) user@machine:~/iti-school$
```

> [!question] 🕵️ فخ الانترفيو: إيه الفرق بين `pip` و `pip3`؟
> 
> **الإجابة الصح:**
> 
> - **خارج الـ venv:** على أنظمة Linux (زي أوبنتو)، `pip` غالباً بيشير لـ Python 2، و `pip3` بيشير لـ Python 3.
>     
> - **داخل الـ venv:** الاتنين بيشيروا لنفس نسخة بايثون اللي اتعمل بيها الـ environment، فمفيش فرق بينهم.
>     
> 
> ---
> 
> **الهدف:** دايماً اشتغل جوا `venv` عشان تضمن إن مكتباتك معزولة ومبتتخانقش مع ملفات النظام الأساسية.

> [!warning] ⚠️ الفخ التاني: كارثة الـ Global Install
> 
> لو نسيت تعمل `source venv/bin/activate` وسطبت أي مكتبة، هتتحمل على الـ **System Python**. ده ممكن يبوظ ملفات الأوبنتو نفسه ويخلي النسخ تضرب في بعضها.

> [!tip] ✅ نصيحة ITI للتأكد
> 
> قبل ما تحمل أي حاجة، اكتب الأمر ده في التيرمينال:
> 
> `which pip`
> 
> - لو طلع لك مسار فيه `.venv/bin/pip` $\rightarrow$ إنت في الأمان.
>     
> - لو طلع لك `/usr/bin/pip` $\rightarrow$ اقفل تيرمينالك وفعل البيئة فوراً!
>

### الخطوة التالتة: تثبيت Django

```bash
pip install django
```

تأكد من التثبيت:

```bash
python -m django --version
# 4.x.x or 5.x.x
```

### الخطوة الرابعة: حفظ الـ Dependencies

```bash
pip freeze > requirements.txt
```

ده بيعمل ملف `requirements.txt` بكل الـ packages المثبتة. أي حد تاني هينزّل المشروع هيعمل:

```bash
pip install -r requirements.txt
```

وهيتثبت كل حاجة تلقائياً.

---

## 💻 إنشاء أول Django Project

```bash
django-admin startproject iti_school .
```

**ليه النقطة في الآخر؟**

النقطة بتقول لـ Django "اعمل الـ project في الـ folder الحالي" بدل ما يعمل folder جديد جوا folder تاني. بدونها هيعمل:
```
iti_school/
    iti_school/
        manage.py
```

بيها هيعمل:
```
iti_school/  ← folder المشروع بتاعك
    manage.py
    iti_school/  ← folder الإعدادات
```

### شجرة المشروع بعد الإنشاء:

```
iti-school/
├── venv/                    ← Virtual Environment (متحملوش على Git)
├── iti_school/              ← Package الإعدادات الرئيسي
│   ├── __init__.py
│   ├── settings.py          ← كل إعدادات المشروع
│   ├── urls.py              ← URL Routing الرئيسي
│   ├── asgi.py              ← للـ Async Deployment
│   └── wsgi.py              ← للـ WSGI Deployment
└── manage.py                ← سكاشة الأوامر
```

---

## فهم كل ملف بالتفصيل

### `manage.py` — القائد

ده ملف Python بيديك أوامر لإدارة المشروع. مش بتعدّله، بس بتستخدمه:

```bash
python manage.py runserver      # تشغيل السيرفر
python manage.py makemigrations # إنشاء migration files
python manage.py migrate        # تطبيق الـ migrations على الـ DB
python manage.py createsuperuser # إنشاء admin user
python manage.py startapp       # إنشاء app جديدة
python manage.py shell          # فتح Django Shell تفاعلي
```

### `settings.py` — قلب المشروع

ده أهم ملف. كل إعداد في Django بيمر من هنا.

```python
# settings.py — شرح تفصيلي لكل حاجة مهمة

# ده بيحدد الـ root directory للمشروع
# BASE_DIR هيبقى: /home/user/iti-school
BASE_DIR = Path(__file__).resolve().parent.parent

# SECRET_KEY — مفتاح سري بيستخدمه Django في:
# - التشفير، signing الـ cookies، الـ CSRF tokens
# ⚠️ دايماً خليه سري ومتحطوش على GitHub
SECRET_KEY = 'django-insecure-xxxxxxxxxxxxxxxxxxxx'

# DEBUG = True → بيظهر error pages تفصيلية
# DEBUG = False → للـ Production، بيخبي التفاصيل
DEBUG = True

# الـ domains المسموح ليها تخدم الـ app
# في الـ Development، فاضية عادةً
ALLOWED_HOSTS = []

# الـ Apps المفعّلة في المشروع
INSTALLED_APPS = [
    'django.contrib.admin',       # Admin Panel
    'django.contrib.auth',        # Authentication System
    'django.contrib.contenttypes',
    'django.contrib.sessions',    # Session Management
    'django.contrib.messages',    # Flash Messages
    'django.contrib.staticfiles', # Static Files (CSS, JS, Images)
    # هنا هنضيف apps المشروع بتاعنا بعدين
]

# الـ Middleware — layers بتشتغل قبل وبعد كل request
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',      # CSRF Protection
    'django.contrib.auth.middleware.AuthenticationMiddleware',  # Auth
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# ملف الـ URL الرئيسي
ROOT_URLCONF = 'iti_school.urls'

# إعدادات الـ Templates
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],  # هنضيف ده بعدين
        'APP_DIRS': True,  # يدور على templates جوا كل app
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# إعدادات الـ Database — SQLite by default
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',  # ملف SQLite في جذر المشروع
    }
}

# Static Files — CSS, JavaScript, Images
STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']  # هنضيفها بعدين

# Media Files — الملفات اللي المستخدمين بيرفعوها
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'  # هنضيفها بعدين

# Language & Timezone
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Africa/Cairo'  # ✅ حطيناها Cairo
USE_I18N = True
USE_TZ = True
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "إيه الفرق بين `STATIC_URL` و `STATICFILES_DIRS` و `STATIC_ROOT`؟"
>
> - **`STATIC_URL`**: الـ URL prefix اللي بيظهر في الـ browser للـ static files (زي `/static/style.css`).
> - **`STATICFILES_DIRS`**: folders بتدور Django فيها على الـ static files أثناء الـ Development.
> - **`STATIC_ROOT`**: المكان اللي `collectstatic` بيجمع كل الـ static files فيه للـ Production.
>
> الفخ: في الـ Development، `STATIC_ROOT` مش لازم. في الـ Production، `STATICFILES_DIRS` مش بيشتغل لوحده — لازم تعمل `collectstatic`.

---

## 💻 تشغيل أول مرة

```bash
python manage.py runserver
```

هتشوف في الـ terminal:

```
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).

You have 18 unapplied migration(s). Your project may not work properly until
you apply the migrations for app(s): admin, auth, contenttypes, sessions.
Run 'python manage.py migrate' to apply them.

October 01, 2024 - 10:00:00
Django version 5.x.x, using settings 'iti_school.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

افتح المتصفح على `http://127.0.0.1:8000/` — هتشوف صفحة الترحيب بتاعت Django.

**بس فيه رسالة warning!**

```
You have 18 unapplied migration(s).
```

ده معناه إن Django عنده tables محتاج يعملها في الـ Database بس لسه ما عملهاش. الـ migrations دي للـ auth system والـ admin panel وغيرها. حلها:

```bash
python manage.py migrate
```

---

## إنشاء أول App — `school`

> [!abstract] 🧠 المفهوم المعماري
> في Django، المشروع (Project) بيتكون من Apps. كل App هي وحدة مستقلة بمسؤولية محددة.
>
> مثلاً في مشروعنا:
> - App `school` للطلاب والمواد والدرجات
> - ممكن نضيف App `contact` للـ Contact Us
> - ممكن نضيف App `accounts` للـ Authentication
>
> الفكرة إن كل app ممكن تتنقل بين مشاريع مختلفة. وده ما بيتقالش في الـ interviews لكنه الحقيقة الهندسية.

```bash
python manage.py startapp school
```

شجرة المشروع دلوقتي:

```
iti-school/
├── venv/
├── iti_school/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── school/                    ← الـ App الجديدة
│   ├── __init__.py
│   ├── admin.py               ← تسجيل Models في الـ Admin
│   ├── apps.py                ← إعدادات الـ App
│   ├── migrations/            ← ملفات الـ Migration
│   │   └── __init__.py
│   ├── models.py              ← تعريف الـ Database Tables
│   ├── tests.py               ← الـ Tests
│   └── views.py               ← الـ Business Logic
└── manage.py
```

**المهم جداً:** لازم تسجّل الـ App في `INSTALLED_APPS`:

```python
# iti_school/settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'school.apps.SchoolConfig',  # ← أضيف ده
]
```

لو نسيت تضيف الـ App في `INSTALLED_APPS` — Django مش هيعرفها. مش هيشوف models بتاعتها، مش هيعمل migrations، مش حاجة. ده من أشهر الأخطاء للمبتدئين.

---

## المرحلة الأولى Checkpoint ✅

عندنا دلوقتي:
- Virtual Environment مفعّل.
- Django مثبّت.
- Project `iti_school` إنشأناه.
- App `school` إنشأناها وسجّلناها.
- `settings.py` فاهمينه كامل.
- السيرفر بيشتغل على `http://127.0.0.1:8000/`.

---

# 🧱 المرحلة الثانية — الـ Monolith MVP

## معمارية Django: MTV

Django بيستخدم معمارية اسمها **MTV** — وهي نفس **MVC** بس بأسماء مختلفة:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096', 'secondaryColor': '#1a202c', 'clusterBkg': '#2d3748'}}}%%
graph TD
    subgraph MVC["المعمارية التقليدية MVC"]
        M1["Model<br>البيانات والمنطق"]
        V1["View<br>العرض والـ UI"]
        C1["Controller<br>التحكم والربط"]
    end
    subgraph MTV["معمارية Django MTV"]
        M2["Model<br>نفس الـ Model"]
        T2["Template<br>= View في MVC"]
        V2["View<br>= Controller في MVC"]
    end
    M1 -.->|"نفسه"| M2
    V1 -.->|"مقابله"| T2
    C1 -.->|"مقابله"| V2

    style MVC fill:#1a202c,stroke:#4a5568
    style MTV fill:#1a202c,stroke:#2b6cb0
    style M2 fill:#276749,color:#e2e8f0
    style T2 fill:#2b6cb0,color:#e2e8f0
    style V2 fill:#744210,color:#e2e8f0
```

> [!abstract] 🧠 المفهوم المعماري
> في Django:
> - **Model** = بيعرّف شكل البيانات في الـ Database (زي الـ Schema).
> - **View** = بيستقبل الـ Request، بيجيب البيانات من الـ Model، وبيبعتها للـ Template. (ده الـ Controller في المعمارية التقليدية).
> - **Template** = الـ HTML اللي الـ User بيشوفه. (ده الـ View في المعمارية التقليدية).
>
> الـ Django بعكس التسمية من MVC — الـ "View" في Django مش للـ "عرض"، ده للـ "منطق".

### تدفق الـ Request في Django:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
flowchart LR
    R["🌐 Request<br>من المتصفح"] --> U["📋 URL Resolver<br>urls.py"]
    U --> V["⚙️ View<br>views.py"]
    V --> M["🗄️ Model<br>models.py"]
    M --> DB["💾 Database<br>SQLite"]
    DB --> M
    M --> V
    V --> T["🖼️ Template<br>.html file"]
    T --> RS["📤 Response<br>HTML للمتصفح"]

    style R fill:#276749,color:#e2e8f0
    style U fill:#2b6cb0,color:#e2e8f0
    style V fill:#744210,color:#e2e8f0
    style M fill:#553c9a,color:#e2e8f0
    style DB fill:#2c7a7b,color:#e2e8f0
    style T fill:#702459,color:#e2e8f0
    style RS fill:#276749,color:#e2e8f0
```

---

## الـ Models — تعريف البيانات

### إيه الـ Model؟

الـ Model هو Python class بيعرّف شكل الـ table في الـ Database. كل attribute في الـ class بيبقى column في الـ table.

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph LR
    subgraph PY["Python Class"]
        CL["class Student:<br>    name = CharField<br>    age = IntegerField<br>    email = EmailField<br>    image = ImageField"]
    end
    subgraph DB["Database Table"]
        TB["students_student<br>─────────────<br>id (PK, Auto)<br>name (VARCHAR)<br>age (INTEGER)<br>email (VARCHAR)<br>image (VARCHAR)"]
    end
    PY -->|"ORM يترجم"| DB

    style PY fill:#1a202c,stroke:#2b6cb0
    style DB fill:#1a202c,stroke:#276749
```

### Models المشروع بتاعنا

```python
# school/models.py

from django.db import models


class Student(models.Model):
    """
    نموذج الطالب — بيمثّل table في الـ Database
    كل instance من الـ class = row في الـ table
    """
    name = models.CharField(max_length=100)          # VARCHAR(100)
    age = models.IntegerField()                       # INTEGER
    email = models.EmailField(unique=True)            # VARCHAR(254) UNIQUE
    image = models.ImageField(
        upload_to='students/',   # هيتحفظ في media/students/
        null=True,               # مسموح يكون NULL في الـ DB
        blank=True               # مسموح يكون فاضي في الـ Forms
    )

    class Meta:
        ordering = ['name']  # الترتيب الافتراضي عند الجلب

    def __str__(self):
        # بيتظهر لما بتعمل print(student) أو في الـ Admin Panel
        return f"{self.name} (Age: {self.age})"


class Subject(models.Model):
    """نموذج المادة"""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, default='')

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class Grade(models.Model):
    """
    نموذج الدرجة — بيربط Student بـ Subject مع قيمة الدرجة
    ده many-to-many relationship مع بيانات إضافية (الدرجة نفسها)
    """
    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE,   # لو الطالب اتمسح، مسح درجاته كمان
        related_name='grades'       # student.grades.all() ← بيرجع كل درجاته
    )
    subject = models.ForeignKey(
        Subject,
        on_delete=models.CASCADE,
        related_name='grades'
    )
    score = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0.0
    )

    class Meta:
        # منع تكرار نفس الطالب في نفس المادة أكتر من مرة
        unique_together = ('student', 'subject')
        ordering = ['-score']  # ترتيب تنازلي حسب الدرجة

    def __str__(self):
        return f"{self.student.name} - {self.subject.name}: {self.score}"
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "إيه الفرق بين `null=True` و `blank=True`؟"
>
> - **`null=True`**: على مستوى الـ **Database**. بيسمح للـ column إنه يكون NULL في قاعدة البيانات.
> - **`blank=True`**: على مستوى الـ **Django Forms Validation**. بيسمح للـ field إنه يكون فاضي في الـ form.
>
> مثال: `image = ImageField(null=True, blank=True)` — يعني الصورة مش إلزامية، وممكن الـ column في الـ DB يكون NULL.
>
> **الغلطة الشائعة:** تعمل `blank=True` بس من غير `null=True` على CharField — ده شغّال لأن Django بيحفظ empty string `""` بدل NULL. لكن على `ImageField` أو `FileField`، لازم تبقى الاتنين.

---

## Field Types الكاملة من الـ Slides

### Character & Text Fields:

```python
# CharField — للنصوص القصيرة (VARCHAR)
name = models.CharField(max_length=100)

# EmailField — نفس CharField بس بـ email validation
email = models.EmailField(unique=True)

# URLField — للـ URLs مع validation
website = models.URLField(blank=True)

# TextField — للنصوص الطويلة (TEXT في SQL)
description = models.TextField(blank=True)
```

### Numeric & Boolean Fields:

```python
# IntegerField — أرقام صحيحة (-2,147,483,648 to 2,147,483,647)
age = models.IntegerField()

# AutoField — بيزيد تلقائياً (ده الـ id الافتراضي)
# Django بيضيفه تلقائياً لو ما حددتش primary key
id = models.AutoField(primary_key=True)

# DecimalField — أرقام عشرية بدقة محددة (المالية مثلاً)
score = models.DecimalField(max_digits=5, decimal_places=2)
# max_digits=5, decimal_places=2 → يعني أقصاه 999.99

# BooleanField — True/False
is_active = models.BooleanField(default=True)
```

### Date & Time Fields:

```python
# DateField — تاريخ بس (بدون وقت)
birth_date = models.DateField(null=True, blank=True)

# DateTimeField — تاريخ + وقت
created_at = models.DateTimeField(auto_now_add=True)  # يتضبط لما الـ record يتعمل
updated_at = models.DateTimeField(auto_now=True)      # يتضبط كل ما الـ record يتحدث

# TimeField — وقت بس
class_time = models.TimeField(null=True)
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "إيه الفرق بين `auto_now` و `auto_now_add`؟"
>
> - **`auto_now_add=True`**: بيضبط القيمة **مرة واحدة بس** لما الـ object يتعمل لأول مرة. بعدين ما بيتغيّرش. استخدامه: `created_at`.
> - **`auto_now=True`**: بيضبط القيمة **كل مرة** تعمل `save()`. استخدامه: `updated_at`.
>
> **الفخ الكبير:** لما بتستخدم `auto_now=True` أو `auto_now_add=True`، الـ field بيبقى `editable=False` تلقائياً — يعني مش هتقدر تغيّره من الـ Admin Panel أو من الكود مباشرةً!

### Relationship Fields:

```python
# ForeignKey — many-to-one
# طالب واحد → درجات كتير
student = models.ForeignKey(
    Student,
    on_delete=models.CASCADE,    # خيارات: CASCADE, SET_NULL, PROTECT, SET_DEFAULT
    related_name='grades'
)

# OneToOneField — one-to-one
# يوزر واحد → profile واحد
profile = models.OneToOneField(
    User,
    on_delete=models.CASCADE
)

# ManyToManyField — many-to-many
# طالب متسجّل في مواد كتير، ومادة فيها طلاب كتير
subjects = models.ManyToManyField(Subject)
# Django بيعمل جدول وسيط تلقائياً
```

---

## Migrations — ترجمة الـ Models للـ Database

### خطوات الـ Migration:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph LR
    A["✏️ غيّرت في<br>models.py"] --> B["🔍 makemigrations<br>يفحص التغييرات"]
    B --> C["📄 migration file<br>اتعمل في migrations/"]
    C --> D["⚡ migrate<br>يطبّق التغييرات"]
    D --> E["🗄️ Database<br>اتحدّثت"]

    style A fill:#744210,color:#e2e8f0
    style B fill:#2b6cb0,color:#e2e8f0
    style C fill:#553c9a,color:#e2e8f0
    style D fill:#276749,color:#e2e8f0
    style E fill:#2c7a7b,color:#e2e8f0
```

قبل أي migration لازم تثبّت Pillow للـ ImageField:

```bash
pip install Pillow
```

بعدين:

```bash
python manage.py makemigrations school
```

هتشوف:

```
Migrations for 'school':
  school/migrations/0001_initial.py
    - Create model Student
    - Create model Subject
    - Create model Grade
```

بعدين طبّق التغييرات على الـ DB:

```bash
python manage.py migrate
```

### إيه اللي بيحصل جوا ملف الـ Migration؟

```python
# school/migrations/0001_initial.py — بيتولّد تلقائياً

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = []  # مش محتاجة حاجة قبلها

    operations = [
        migrations.CreateModel(
            name='Student',
            fields=[
                # id بيتضاف تلقائياً
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('age', models.IntegerField()),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('image', models.ImageField(blank=True, null=True, upload_to='students/')),
            ],
            options={
                'ordering': ['name'],
            },
        ),
        # ... باقي الـ Models
    ]
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال شائع جداً:** "إيه الفرق بين `makemigrations` و `migrate`؟"
>
> - **`makemigrations`**: بيفحص الـ models الحالية، ويقارنها بالـ migrations الموجودة، وبيعمل **migration file جديد** بيوصف التغييرات. مش بيلمس الـ Database.
> - **`migrate`**: بياخد الـ migration files الموجودة وبيطبّقها فعلاً على الـ **Database**.
>
> تقدر تعتبر `makemigrations` زي إنك بتكتب خطة تعديلات معمارية، و`migrate` هي تنفيذ الخطة دي فعلاً.

---

## الـ Views — منطق التطبيق

### أول View في المشروع

```python
# school/views.py

from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse
from .models import Student, Subject, Grade
from .forms import StudentForm, SubjectForm, GradeForm, ContactForm
from django.db.models import Sum


def home(request):
    """
    الصفحة الرئيسية — بس للـ logged in users
    """
    return render(request, 'school/home.html')


def student_list(request):
    """
    عرض كل الطلاب
    """
    students = Student.objects.all()
    context = {
        'students': students,
        'title': 'قائمة الطلاب'
    }
    return render(request, 'school/student_list.html', context)
```

### الـ View ده بيعمل إيه بالظبط؟

لما يجي request على `/students/`:
1. Django بيروح لـ `urls.py` يلاقي أي view مسؤول عن الـ URL ده.
2. Django بيشغّل `student_list(request)`.
3. `Student.objects.all()` بيجيب كل الطلاب من الـ Database.
4. `render(request, 'school/student_list.html', context)` بياخد الـ template وبيحشيه بالـ data وبيرجع HTML.
5. الـ HTML ده بيترجع للمتصفح.

---

## الـ URLs — التوجيه

### urls.py الرئيسي:

```python
# iti_school/urls.py

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('school.urls')),  # كل الـ URLs بتاعت school
]

# ⚠️ ده بس للـ Development — مش للـ Production
# بيخلي Django يخدم ملفات الـ media (الصور المرفوعة)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
```

### urls.py الخاص بـ school app:

أول ما تعمل app جديدة، ملف `urls.py` مش بيتعمل تلقائياً. لازم تعمله بنفسك:

```python
# school/urls.py — اعمله بنفسك

from django.urls import path
from . import views

app_name = 'school'  # ← الـ namespace مهم جداً

urlpatterns = [
    # Home
    path('', views.home, name='home'),

    # Students CRUD
    path('students/', views.student_list, name='student_list'),
    path('students/create/', views.student_create, name='student_create'),
    path('students/<int:pk>/', views.student_detail, name='student_detail'),
    path('students/<int:pk>/update/', views.student_update, name='student_update'),
    path('students/<int:pk>/delete/', views.student_delete, name='student_delete'),

    # Subjects CRUD
    path('subjects/', views.subject_list, name='subject_list'),
    path('subjects/create/', views.subject_create, name='subject_create'),
    path('subjects/<int:pk>/update/', views.subject_update, name='subject_update'),
    path('subjects/<int:pk>/delete/', views.subject_delete, name='subject_delete'),

    # Grades
    path('grades/', views.grade_list, name='grade_list'),
    path('grades/create/', views.grade_create, name='grade_create'),
    path('grades/<int:pk>/update/', views.grade_update, name='grade_update'),
    path('grades/<int:pk>/delete/', views.grade_delete, name='grade_delete'),

    # Leaderboard
    path('leaderboard/', views.leaderboard, name='leaderboard'),

    # Contact
    path('contact/', views.contact, name='contact'),

    # Auth
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('profile/', views.profile, name='profile'),
]
```

> [!abstract] 🧠 المفهوم المعماري
> **URL Namespacing**: لما بتحدد `app_name = 'school'` في الـ `urls.py`، كل URL بيبقى له اسم زي `school:student_list`.
>
> في الـ Template:
> ```html
> <a href="{% url 'school:student_list' %}">الطلاب</a>
> ```
>
> في الـ View (Python):
> ```python
> from django.urls import reverse
> url = reverse('school:student_list')
> ```
>
> **ليه ده مهم؟** لو غيّرت الـ URL path من `/students/` لـ `/all-students/` مش هتحتاج تغيّر أي حاجة في الـ templates أو الـ views — بس تغيّر `path('all-students/', ...)` في `urls.py`.

---

## الـ Forms — التحقق من البيانات

### إنشاء Forms:

```python
# school/forms.py — اعمل الملف ده

from django import forms
from .models import Student, Subject, Grade
from django.contrib.auth.forms import AuthenticationForm


class StudentForm(forms.ModelForm):
    """
    ModelForm — بياخد الـ fields تلقائياً من الـ Model
    مش محتاج تعرّف كل field بنفسك
    """
    class Meta:
        model = Student
        fields = ['name', 'age', 'email', 'image']
        # أو تقدر تقول: fields = '__all__' لكل الـ fields
        widgets = {
            # بنضيف CSS classes للـ HTML inputs
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'اسم الطالب'
            }),
            'age': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '5',
                'max': '100'
            }),
            'email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'example@email.com'
            }),
            'image': forms.FileInput(attrs={
                'class': 'form-control'
            }),
        }

    def clean_age(self):
        """
        Custom validation للـ age field
        دايماً اسمها clean_<fieldname>
        """
        age = self.cleaned_data.get('age')
        if age and (age < 5 or age > 100):
            raise forms.ValidationError("العمر لازم يكون بين 5 و 100 سنة")
        return age

    def clean_email(self):
        """Validation إضافية على الـ email"""
        email = self.cleaned_data.get('email')
        if email:
            email = email.lower()  # بنحوّله لـ lowercase
        return email


class SubjectForm(forms.ModelForm):
    class Meta:
        model = Subject
        fields = ['name', 'description']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 3
            }),
        }


class GradeForm(forms.ModelForm):
    class Meta:
        model = Grade
        fields = ['student', 'subject', 'score']
        widgets = {
            'student': forms.Select(attrs={'class': 'form-select'}),
            'subject': forms.Select(attrs={'class': 'form-select'}),
            'score': forms.NumberInput(attrs={
                'class': 'form-control',
                'min': '0',
                'max': '100',
                'step': '0.5'
            }),
        }


class ContactForm(forms.Form):
    """
    Form عادية — مش ModelForm لأنها مش بتحفظ في Model
    """
    email = forms.EmailField(
        label='البريد الإلكتروني',
        widget=forms.EmailInput(attrs={'class': 'form-control'})
    )
    message = forms.CharField(
        label='الرسالة',
        widget=forms.Textarea(attrs={'class': 'form-control', 'rows': 5})
    )
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "إيه الفرق بين `Form` و `ModelForm`؟"
>
> - **`forms.Form`**: بتعرّف كل field بنفسك. مناسب للـ forms اللي مش مرتبطة بـ model (زي contact form، search form).
> - **`forms.ModelForm`**: بياخد الـ fields من الـ Model تلقائياً. بيعمل `save()` بيحفظ في الـ DB مباشرةً.
>
> ```python
> # ModelForm — بسيط
> form = StudentForm(request.POST, request.FILES)
> if form.is_valid():
>     form.save()  # ← كده بس، حفظ في الـ DB
>
> # Form عادية — لازم تعمل الحفظ بنفسك
> form = ContactForm(request.POST)
> if form.is_valid():
>     email = form.cleaned_data['email']
>     message = form.cleaned_data['message']
>     # بتعمل اللي محتاجه بنفسك
> ```

---

## الـ Views الكاملة للـ CRUD

### Students CRUD Views:

```python
# school/views.py — الكود الكامل

from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm
from django.contrib import messages
from django.db.models import Sum
from .models import Student, Subject, Grade
from .forms import StudentForm, SubjectForm, GradeForm, ContactForm


# ══════════════════════════════════════
#  HOME & AUTH VIEWS
# ══════════════════════════════════════

@login_required(login_url='school:login')
def home(request):
    """الصفحة الرئيسية — بس للـ logged in"""
    context = {
        'student_count': Student.objects.count(),
        'subject_count': Subject.objects.count(),
        'grade_count': Grade.objects.count(),
    }
    return render(request, 'school/home.html', context)


def login_view(request):
    """
    Login View باستخدام AuthenticationForm الجاهز من Django
    """
    if request.user.is_authenticated:
        return redirect('school:home')  # لو هو logged in، ودّيه للـ home

    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            # بعد الـ login، روح للصفحة اللي كان رايح ليها
            next_url = request.GET.get('next', 'school:home')
            return redirect(next_url)
        else:
            messages.error(request, 'اسم المستخدم أو كلمة السر غلط')
    else:
        form = AuthenticationForm()

    return render(request, 'school/login.html', {'form': form})


@login_required(login_url='school:login')
def logout_view(request):
    """Logout — بيمسح الـ session"""
    logout(request)
    messages.success(request, 'تم تسجيل الخروج بنجاح')
    return redirect('school:login')


@login_required(login_url='school:login')
def profile(request):
    """عرض معلومات المستخدم الحالي"""
    return render(request, 'school/profile.html', {'user': request.user})


# ══════════════════════════════════════
#  STUDENT VIEWS — Full CRUD
# ══════════════════════════════════════

@login_required(login_url='school:login')
def student_list(request):
    """عرض كل الطلاب"""
    students = Student.objects.all()
    return render(request, 'school/student_list.html', {'students': students})


@login_required(login_url='school:login')
def student_detail(request, pk):
    """عرض تفاصيل طالب واحد"""
    # get_object_or_404 — لو مش موجود بيرجع 404 تلقائياً
    student = get_object_or_404(Student, pk=pk)
    grades = student.grades.select_related('subject').all()
    return render(request, 'school/student_detail.html', {
        'student': student,
        'grades': grades
    })


@login_required(login_url='school:login')
def student_create(request):
    """إنشاء طالب جديد"""
    if request.method == 'POST':
        # request.FILES مهم للـ Image upload
        form = StudentForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم إضافة الطالب بنجاح!')
            return redirect('school:student_list')
    else:
        form = StudentForm()

    return render(request, 'school/student_form.html', {
        'form': form,
        'title': 'إضافة طالب جديد',
        'action': 'إضافة'
    })


@login_required(login_url='school:login')
def student_update(request, pk):
    """تعديل بيانات طالب"""
    student = get_object_or_404(Student, pk=pk)

    if request.method == 'POST':
        # instance=student ← بيقول "حدّث الطالب ده مش بتعمل واحد جديد"
        form = StudentForm(request.POST, request.FILES, instance=student)
        if form.is_valid():
            form.save()
            messages.success(request, f'تم تحديث بيانات {student.name} بنجاح!')
            return redirect('school:student_list')
    else:
        form = StudentForm(instance=student)  # بيعبّي الـ form بالبيانات الحالية

    return render(request, 'school/student_form.html', {
        'form': form,
        'student': student,
        'title': f'تعديل: {student.name}',
        'action': 'حفظ التعديلات'
    })


@login_required(login_url='school:login')
def student_delete(request, pk):
    """حذف طالب"""
    student = get_object_or_404(Student, pk=pk)

    if request.method == 'POST':
        name = student.name
        student.delete()
        messages.success(request, f'تم حذف الطالب {name} بنجاح')
        return redirect('school:student_list')

    # GET request → اعرض صفحة تأكيد الحذف
    return render(request, 'school/student_confirm_delete.html', {
        'student': student
    })


# ══════════════════════════════════════
#  SUBJECT VIEWS — Full CRUD مع Search
# ══════════════════════════════════════

@login_required(login_url='school:login')
def subject_list(request):
    """عرض المواد مع Search"""
    query = request.GET.get('q', '')  # بياخد الـ search query من الـ URL
    subjects = Subject.objects.all()

    if query:
        subjects = subjects.filter(name__icontains=query)
        # icontains = case-insensitive LIKE '%query%'

    return render(request, 'school/subject_list.html', {
        'subjects': subjects,
        'query': query
    })


@login_required(login_url='school:login')
def subject_create(request):
    if request.method == 'POST':
        form = SubjectForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم إضافة المادة بنجاح!')
            return redirect('school:subject_list')
    else:
        form = SubjectForm()
    return render(request, 'school/subject_form.html', {'form': form, 'title': 'إضافة مادة'})


@login_required(login_url='school:login')
def subject_update(request, pk):
    subject = get_object_or_404(Subject, pk=pk)
    if request.method == 'POST':
        form = SubjectForm(request.POST, instance=subject)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم التحديث بنجاح!')
            return redirect('school:subject_list')
    else:
        form = SubjectForm(instance=subject)
    return render(request, 'school/subject_form.html', {'form': form, 'subject': subject})


@login_required(login_url='school:login')
def subject_delete(request, pk):
    subject = get_object_or_404(Subject, pk=pk)
    if request.method == 'POST':
        subject.delete()
        messages.success(request, 'تم حذف المادة')
        return redirect('school:subject_list')
    return render(request, 'school/subject_confirm_delete.html', {'subject': subject})


# ══════════════════════════════════════
#  GRADE VIEWS — Full CRUD مع Search
# ══════════════════════════════════════

@login_required(login_url='school:login')
def grade_list(request):
    """عرض الدرجات مع Search بـ student ID أو subject name"""
    student_id = request.GET.get('student_id', '')
    subject_query = request.GET.get('subject', '')
    grades = Grade.objects.select_related('student', 'subject').all()

    if student_id:
        grades = grades.filter(student__id=student_id)
    if subject_query:
        grades = grades.filter(subject__name__icontains=subject_query)

    return render(request, 'school/grade_list.html', {
        'grades': grades,
        'student_id': student_id,
        'subject_query': subject_query,
    })


@login_required(login_url='school:login')
def grade_create(request):
    if request.method == 'POST':
        form = GradeForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم إضافة الدرجة بنجاح!')
            return redirect('school:grade_list')
    else:
        form = GradeForm()
    return render(request, 'school/grade_form.html', {'form': form, 'title': 'إضافة درجة'})


@login_required(login_url='school:login')
def grade_update(request, pk):
    grade = get_object_or_404(Grade, pk=pk)
    if request.method == 'POST':
        form = GradeForm(request.POST, instance=grade)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم التحديث')
            return redirect('school:grade_list')
    else:
        form = GradeForm(instance=grade)
    return render(request, 'school/grade_form.html', {'form': form, 'grade': grade})


@login_required(login_url='school:login')
def grade_delete(request, pk):
    grade = get_object_or_404(Grade, pk=pk)
    if request.method == 'POST':
        grade.delete()
        messages.success(request, 'تم حذف الدرجة')
        return redirect('school:grade_list')
    return render(request, 'school/grade_confirm_delete.html', {'grade': grade})


# ══════════════════════════════════════
#  LEADERBOARD — Bonus Feature
# ══════════════════════════════════════

@login_required(login_url='school:login')
def leaderboard(request):
    """
    أعلى 5 طلاب بإجمالي أعلى درجات
    ده بيستخدم annotate + aggregate من ORM
    """
    top_students = (
        Student.objects
        .annotate(total_score=Sum('grades__score'))  # بيحسب مجموع الدرجات لكل طالب
        .filter(total_score__isnull=False)           # بيشيل الطلاب اللي ملهومش درجات
        .order_by('-total_score')                    # ترتيب تنازلي
        [:5]                                         # أول 5 بس (LIMIT 5)
    )
    return render(request, 'school/leaderboard.html', {'top_students': top_students})


# ══════════════════════════════════════
#  CONTACT — Public (No Auth)
# ══════════════════════════════════════

def contact(request):
    """Contact form — بدون auth"""
    if request.method == 'POST':
        form = ContactForm(request.POST)
        if form.is_valid():
            # ممكن تعمل إيميل هنا أو تحفظ في DB
            messages.success(request, 'تم إرسال رسالتك بنجاح! هنرد عليك قريباً.')
            return redirect('school:contact')
    else:
        form = ContactForm()
    return render(request, 'school/contact.html', {'form': form})
```

---

## الـ Templates — ما بيشوفه المستخدم

### هيكل الـ Templates:

أول ما تبدأ، عمل هيكل زي ده:

```
iti-school/
├── templates/
│   └── school/
│       ├── base.html              ← الـ Template الأم (Shared Layout)
│       ├── home.html
│       ├── login.html
│       ├── profile.html
│       ├── student_list.html
│       ├── student_detail.html
│       ├── student_form.html      ← لـ Create و Update
│       ├── student_confirm_delete.html
│       ├── subject_list.html
│       ├── subject_form.html
│       ├── subject_confirm_delete.html
│       ├── grade_list.html
│       ├── grade_form.html
│       ├── grade_confirm_delete.html
│       ├── leaderboard.html
│       └── contact.html
└── static/
    ├── css/
    │   └── style.css
    └── images/
        └── iti_logo.png
```

وتأكد إن settings.py فيه:

```python
TEMPLATES = [
    {
        ...
        'DIRS': [BASE_DIR / 'templates'],  # ← المهم ده
        'APP_DIRS': True,
        ...
    },
]
```

### `base.html` — الـ Template الأم:

```html
<!-- templates/school/base.html -->
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}ITI School{% endblock %}</title>
    {% load static %}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
    {% block extra_css %}{% endblock %}
</head>
<body>

{% if user.is_authenticated %}
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="{% url 'school:home' %}">🎓 ITI School</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:home' %}">الرئيسية</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:student_list' %}">الطلاب</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:subject_list' %}">المواد</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:grade_list' %}">الدرجات</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:leaderboard' %}">🏆 المتصدرين</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:profile' %}">👤 {{ user.username }}</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'school:logout' %}">خروج</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
{% endif %}

<div class="container mt-4">
    <!-- Flash Messages -->
    {% if messages %}
    {% for message in messages %}
    <div class="alert alert-{{ message.tags }} alert-dismissible fade show" role="alert">
        {{ message }}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    {% endfor %}
    {% endif %}

    {% block content %}
    {% endblock %}
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
{% block extra_js %}{% endblock %}
</body>
</html>
```

### `login.html`:

```html
<!-- templates/school/login.html -->
{% extends 'school/base.html' %}

{% block title %}تسجيل الدخول — ITI School{% endblock %}

{% block content %}
<div class="row justify-content-center mt-5">
    <div class="col-md-5">
        <div class="card shadow">
            <div class="card-header bg-dark text-white text-center">
                <h4>🎓 ITI School</h4>
                <p class="mb-0">تسجيل الدخول</p>
            </div>
            <div class="card-body p-4">
                <form method="POST">
                    {% csrf_token %}
                    <!-- ⚠️ csrf_token إلزامي في كل POST form في Django -->

                    <div class="mb-3">
                        <label class="form-label">اسم المستخدم</label>
                        {{ form.username }}
                        {% if form.username.errors %}
                        <div class="text-danger small">{{ form.username.errors }}</div>
                        {% endif %}
                    </div>
                    <div class="mb-3">
                        <label class="form-label">كلمة السر</label>
                        {{ form.password }}
                        {% if form.password.errors %}
                        <div class="text-danger small">{{ form.password.errors }}</div>
                        {% endif %}
                    </div>

                    {% if form.non_field_errors %}
                    <div class="alert alert-danger">{{ form.non_field_errors }}</div>
                    {% endif %}

                    <button type="submit" class="btn btn-dark w-100">دخول</button>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

### `student_list.html`:

```html
<!-- templates/school/student_list.html -->
{% extends 'school/base.html' %}
{% load static %}

{% block title %}الطلاب{% endblock %}

{% block content %}
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>👨‍🎓 قائمة الطلاب</h2>
    <a href="{% url 'school:student_create' %}" class="btn btn-success">+ إضافة طالب</a>
</div>

{% if students %}
<div class="row">
    {% for student in students %}
    <div class="col-md-4 mb-3">
        <div class="card h-100">
            {% if student.image %}
            <img src="{{ student.image.url }}"
                 class="card-img-top"
                 alt="{{ student.name }}"
                 style="height: 200px; object-fit: cover;">
            {% else %}
            <div class="bg-secondary text-white d-flex align-items-center justify-content-center"
                 style="height: 200px;">
                <span style="font-size: 4rem;">👤</span>
            </div>
            {% endif %}
            <div class="card-body">
                <h5 class="card-title">{{ student.name }}</h5>
                <p class="card-text text-muted">العمر: {{ student.age }} سنة</p>
                <p class="card-text">
                    <a href="mailto:{{ student.email }}">{{ student.email }}</a>
                </p>
            </div>
            <div class="card-footer">
                <a href="{% url 'school:student_detail' student.pk %}"
                   class="btn btn-sm btn-info">تفاصيل</a>
                <a href="{% url 'school:student_update' student.pk %}"
                   class="btn btn-sm btn-warning">تعديل</a>
                <a href="{% url 'school:student_delete' student.pk %}"
                   class="btn btn-sm btn-danger">حذف</a>
            </div>
        </div>
    </div>
    {% endfor %}
</div>
{% else %}
<div class="alert alert-info text-center">
    لا يوجد طلاب مسجلين حتى الآن.
    <a href="{% url 'school:student_create' %}">أضف أول طالب!</a>
</div>
{% endif %}
{% endblock %}
```

### `student_form.html` — للـ Create والـ Update:

```html
<!-- templates/school/student_form.html -->
{% extends 'school/base.html' %}

{% block title %}{{ title }}{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="card">
            <div class="card-header">
                <h4>{{ title }}</h4>
            </div>
            <div class="card-body">
                <!--
                    enctype="multipart/form-data" ← إلزامي لو فيه file upload
                    بدونه، الصورة مش هتتبعت
                -->
                <form method="POST" enctype="multipart/form-data">
                    {% csrf_token %}

                    {% for field in form %}
                    <div class="mb-3">
                        <label class="form-label">{{ field.label }}</label>
                        {{ field }}
                        {% if field.errors %}
                        <div class="text-danger small mt-1">
                            {% for error in field.errors %}
                            {{ error }}
                            {% endfor %}
                        </div>
                        {% endif %}
                        {% if field.help_text %}
                        <div class="form-text text-muted">{{ field.help_text }}</div>
                        {% endif %}
                    </div>
                    {% endfor %}

                    <!-- لو بنعدّل، بنعرض الصورة الحالية -->
                    {% if student.image %}
                    <div class="mb-3">
                        <p class="text-muted">الصورة الحالية:</p>
                        <img src="{{ student.image.url }}"
                             alt="{{ student.name }}"
                             class="img-thumbnail"
                             style="max-height: 150px;">
                    </div>
                    {% endif %}

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-success">{{ action }}</button>
                        <a href="{% url 'school:student_list' %}"
                           class="btn btn-secondary">إلغاء</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## Django Template Language — كل شيء من الـ Slides

### المتغيرات:

```html
<!-- بيطبع قيمة المتغير -->
{{ student.name }}
{{ student.age }}
{{ grade.score }}

<!-- Chaining -->
{{ student.grades.count }}
```

### الـ Tags:

```html
<!-- for loop مع empty -->
{% for student in students %}
    <li>{{ forloop.counter }}. {{ student.name }}</li>
{% empty %}
    <li>لا يوجد طلاب</li>
{% endfor %}

<!-- if / elif / else -->
{% if student.age >= 18 %}
    <span class="badge bg-success">بالغ</span>
{% elif student.age >= 15 %}
    <span class="badge bg-warning">مراهق</span>
{% else %}
    <span class="badge bg-info">طفل</span>
{% endif %}

<!-- Template Inheritance -->
{% extends 'school/base.html' %}

{% block content %}
    <!-- محتوى الصفحة -->
{% endblock %}

<!-- URL Generation -->
<a href="{% url 'school:student_list' %}">الطلاب</a>
<a href="{% url 'school:student_detail' student.pk %}">{{ student.name }}</a>

<!-- CSRF Token — إلزامي في كل POST form -->
{% csrf_token %}

<!-- Load Static Files -->
{% load static %}
<img src="{% static 'images/logo.png' %}">
<link rel="stylesheet" href="{% static 'css/style.css' %}">

<!-- Comment -->
{# ده comment مش بيتظهر في الـ HTML #}
```

### الـ Filters:

```html
<!-- title case -->
{{ student.name | title }}

<!-- truncate text -->
{{ subject.description | truncatewords:20 }}

<!-- date formatting -->
{{ grade.created_at | date:"d/m/Y" }}

<!-- default value لو فاضي -->
{{ student.image | default:"no-image.png" }}

<!-- lower case -->
{{ student.email | lower }}

<!-- عدد العناصر في قائمة -->
{{ students | length }}

<!-- safe HTML — بيقول للـ Django متـ escape الـ HTML ده -->
{{ content | safe }}

<!-- linebreaks — بيحوّل newlines لـ <br> -->
{{ message | linebreaks }}
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "ليه Django بيعمل HTML escaping تلقائياً؟ وإيه الخطر من `| safe`؟"
>
> Django بـ default بيعمل **auto-escaping** — يعني لو المتغير فيه `<script>alert('xss')</script>` هيحوّله لـ `&lt;script&gt;...` فمش هيتنفّذ.
>
> `| safe` بتقول لـ Django "الـ HTML ده آمن، متـ escape-وش". لو استخدمته على بيانات جاية من المستخدم مباشرةً — ده **XSS vulnerability** كبير. استخدمه بس على HTML بتكتبه أنت في الكود.

---

## الـ Settings لـ Static و Media Files

```python
# iti_school/settings.py — الإضافات المهمة

import os  # لازم في الأول

# Static Files — CSS, JS, Images الثابتة
STATIC_URL = '/static/'
STATICFILES_DIRS = [
    BASE_DIR / 'static',  # folder static في جذر المشروع
]

# Media Files — الملفات اللي المستخدمين بيرفعوها
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'  # هيتحفظ هنا على الـ server

# Login Redirect
LOGIN_URL = '/login/'
LOGIN_REDIRECT_URL = '/'
```

وعمل الـ folders:

```bash
mkdir -p static/css static/images
mkdir media
```

---

## المرحلة الثانية Checkpoint ✅

عندنا دلوقتي:
- Models: `Student`, `Subject`, `Grade` مع كل الـ relationships.
- Forms: `StudentForm`, `SubjectForm`, `GradeForm`, `ContactForm`.
- Views: كل الـ CRUD لكل model مع Search.
- URLs: مرتبة ومتسمّاة بـ namespace.
- Templates: `base.html` مع Template Inheritance وكل الـ pages.
- Static Files: CSS محفوظ في `/static/`.
- Media Files: الصور بتتحفظ في `/media/students/`.

---

# 🗄️ المرحلة الثالثة — إتقان الـ Database

## الـ ORM في العمق

### إيه الـ ORM ده أصلاً؟

**ORM = Object-Relational Mapper**

بدل ما تكتب SQL مباشرةً، بتكتب Python وهو بيترجمها لـ SQL تلقائياً:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph LR
    PY["Python ORM<br>Student.objects.filter(age__gt=18)"]
    SQL["SQL<br>SELECT * FROM school_student<br>WHERE age > 18"]
    DB["SQLite Database"]

    PY -->|"ORM يترجم"| SQL
    SQL -->|"ينفّذ"| DB
    DB -->|"Python objects"| PY

    style PY fill:#276749,color:#e2e8f0
    style SQL fill:#2b6cb0,color:#e2e8f0
    style DB fill:#744210,color:#e2e8f0
```

### الـ Manager والـ QuerySet:

```python
# كل model عنده Manager اسمه objects
# Manager بيرجع QuerySet

# QuerySet = مجموعة من الـ objects + lazy evaluation
qs = Student.objects.all()
# ده لسه ما نفّذش SQL!
# الـ SQL بتتنفّذ لما تعمل:
# - iteration (for s in qs)
# - len(qs)
# - qs[0]
# - str(qs)
```

### القراءة (Read):

```python
# كل الطلاب
all_students = Student.objects.all()
# SQL: SELECT * FROM school_student

# فلترة
adults = Student.objects.filter(age__gte=18)
# SQL: SELECT * FROM school_student WHERE age >= 18

# استبعاد
young = Student.objects.exclude(age__gte=18)
# SQL: SELECT * FROM school_student WHERE NOT age >= 18

# طالب واحد بـ ID
student = Student.objects.get(pk=1)
# SQL: SELECT * FROM school_student WHERE id = 1 LIMIT 1
# ⚠️ لو مش موجود → DoesNotExist Exception
# ⚠️ لو أكتر من واحد → MultipleObjectsReturned Exception

# الأأمن: get_object_or_404
from django.shortcuts import get_object_or_404
student = get_object_or_404(Student, pk=1)
# لو مش موجود → HTTP 404 مباشرةً

# أول واحد
first_student = Student.objects.first()

# آخر واحد
last_student = Student.objects.last()

# عد
count = Student.objects.count()

# الترتيب
sorted_students = Student.objects.order_by('name')      # تصاعدي
sorted_students = Student.objects.order_by('-name')     # تنازلي (- في الأول)
sorted_students = Student.objects.order_by('-age', 'name')  # متعدد

# تحديد عدد (LIMIT و OFFSET)
top_3 = Student.objects.all()[:3]      # LIMIT 3
skip_5 = Student.objects.all()[5:10]   # OFFSET 5 LIMIT 5
```

### الـ Field Lookups:

الـ Field Lookups بيتكتبوا بـ `__` (double underscore) بعد اسم الـ field:

```python
# exact — المطابقة التامة (الافتراضي)
Student.objects.filter(name='Ahmed')
Student.objects.filter(name__exact='Ahmed')  # نفس الكلام

# iexact — case-insensitive
Student.objects.filter(name__iexact='ahmed')
# هيجيب: Ahmed, ahmed, AHMED, AhMeD

# contains — يحتوي على (LIKE '%value%')
Student.objects.filter(name__contains='med')

# icontains — case-insensitive contains
Student.objects.filter(name__icontains='med')

# startswith / istartswith
Student.objects.filter(name__startswith='A')
Student.objects.filter(name__istartswith='a')

# endswith / iendswith
Student.objects.filter(email__endswith='@gmail.com')

# gt, gte, lt, lte — أكبر من، أكبر أو يساوي، أصغر من، أصغر أو يساوي
Student.objects.filter(age__gt=18)    # > 18
Student.objects.filter(age__gte=18)   # >= 18
Student.objects.filter(age__lt=30)    # < 30
Student.objects.filter(age__lte=30)   # <= 30

# in — في قائمة
Student.objects.filter(age__in=[18, 19, 20])

# range — بين قيمتين
Student.objects.filter(age__range=(18, 25))
# SQL: WHERE age BETWEEN 18 AND 25

# isnull — هل NULL؟
Student.objects.filter(image__isnull=True)

# Relationship Lookups — عبر الـ ForeignKey
# الطلاب اللي ليهم درجات في مادة "Math"
Student.objects.filter(grades__subject__name='Math')
# ده بيعمل JOIN تلقائياً!

# الطلاب اللي درجاتهم أعلى من 80
Student.objects.filter(grades__score__gte=80)
```

> [!example] 💻 الكود الوحش vs الكود النضيف
> **الوحش — N+1 Query Problem:**
> ```python
> # views.py — كود بيعمل N+1 queries (كارثة الـ performance)
> def grade_list(request):
>     grades = Grade.objects.all()  # Query 1: جلب الدرجات
>     for grade in grades:
>         print(grade.student.name)  # Query 2,3,4...N: جلب كل student على حدة!
>         print(grade.subject.name)  # Query N+1,...: جلب كل subject على حدة!!
>     # لو عندك 100 درجة → 201 query!!!
> ```
>
> **النضيف — select_related:**
> ```python
> def grade_list(request):
>     # select_related بيعمل JOIN واحد بدل N queries
>     grades = Grade.objects.select_related('student', 'subject').all()
>     # Query واحد بس:
>     # SELECT grade.*, student.*, subject.*
>     # FROM grade
>     # JOIN student ON grade.student_id = student.id
>     # JOIN subject ON grade.subject_id = subject.id
>     for grade in grades:
>         print(grade.student.name)  # من الـ cache — مش query جديد
>         print(grade.subject.name)  # من الـ cache
>     # 1 query بس!
> ```

### الكتابة (Create, Update, Delete):

```python
# ══ CREATE ══

# الطريقة الأولى: instance.save()
student = Student()
student.name = "Ahmed Ali"
student.age = 20
student.email = "ahmed@example.com"
student.save()  # هنا بس بينفّذ الـ SQL

# الطريقة التانية: objects.create() — أسرع وأنضف
student = Student.objects.create(
    name="Ahmed Ali",
    age=20,
    email="ahmed@example.com"
)
# بيعمل الـ insert وبيرجع الـ object في خطوة واحدة

# الطريقة التالتة: get_or_create — يجيب أو يعمل
student, created = Student.objects.get_or_create(
    email="ahmed@example.com",  # بيدور بالـ email
    defaults={                  # لو ما لقاش، بيعمله بالـ defaults دي
        'name': 'Ahmed Ali',
        'age': 20
    }
)
# created = True لو اتعمل جديد، False لو لقاه موجود

# ══ UPDATE ══

# تحديث instance واحد
student = Student.objects.get(pk=1)
student.name = "Mohamed Ali"
student.save()  # UPDATE school_student SET name='...' WHERE id=1

# تحديث أكتر من record في خطوة واحدة (أسرع بكتير)
Student.objects.filter(age__lt=18).update(is_active=False)
# UPDATE school_student SET is_active=0 WHERE age < 18

# ══ DELETE ══

# حذف instance واحد
student = Student.objects.get(pk=1)
student.delete()  # DELETE FROM school_student WHERE id=1

# حذف مجموعة
Student.objects.filter(age__lt=5).delete()
# DELETE FROM school_student WHERE age < 5
```

### الـ Aggregation — التحليل الإحصائي:

ده اللي بيتستخدم في الـ Leaderboard:

```python
from django.db.models import Sum, Avg, Count, Max, Min, F

# مجموع كل الدرجات
from school.models import Grade
total = Grade.objects.aggregate(Sum('score'))
# {'score__sum': 4523.5}

# متوسط العمر
avg_age = Student.objects.aggregate(Avg('age'))
# {'age__avg': 21.3}

# أعلى درجة
max_score = Grade.objects.aggregate(Max('score'))
# {'score__max': 100.0}

# ══ annotate — بيضيف حقل محسوب لكل object ══

# كل طالب مع مجموع درجاته
students_with_totals = Student.objects.annotate(
    total_score=Sum('grades__score')
)
for s in students_with_totals:
    print(f"{s.name}: {s.total_score}")

# الـ Leaderboard كامل:
top_students = (
    Student.objects
    .annotate(total_score=Sum('grades__score'))
    .filter(total_score__isnull=False)
    .order_by('-total_score')
    [:5]
)
```

### الـ F() — مقارنة fields مع بعض:

```python
from django.db.models import F

# ابحث عن الطلاب اللي اسمهم الأول = اسمهم الأخير
# (مستحيل مثال كده في مشروعنا لكن مفيد تعرفه)
User.objects.filter(first_name=F('last_name'))

# زيادة قيمة field بدون جلبها أولاً (atomic operation)
Grade.objects.filter(student_id=1).update(
    score=F('score') + 5  # زود 5 درجات لكل مواد الطالب ده
)
# SQL: UPDATE grade SET score = score + 5 WHERE student_id = 1
# ⚠️ أأمن بكتير من:
# grade.score += 5; grade.save()  ← ممكن يحصل race condition
```

### Raw SQL — لما الـ ORM مش كفاية:

```python
# تقدر تكتب SQL خام لو محتاج
students = Student.objects.raw('SELECT * FROM school_student WHERE age > %s', [18])

# أو
from django.db import connection
with connection.cursor() as cursor:
    cursor.execute(
        "SELECT s.name, SUM(g.score) as total "
        "FROM school_student s "
        "JOIN school_grade g ON s.id = g.student_id "
        "GROUP BY s.id "
        "ORDER BY total DESC "
        "LIMIT 5"
    )
    rows = cursor.fetchall()
```

> [!abstract] 🧠 المفهوم المعماري
> الـ Raw SQL في Django هو **last resort** — استخدمه بس لو الـ ORM مش قادر يعمل الـ query اللي عايزها (زي window functions أو complex CTEs). في 99% من الحالات، الـ ORM كفاية ومأمون من **SQL Injection** لأنه بيستخدم **parameterized queries** تلقائياً.

---

## الـ Admin Panel — القوة الحقيقية لـ Django

### إنشاء Superuser:

```bash
python manage.py createsuperuser
# هيسألك:
# Username: admin
# Email: admin@iti.edu.eg
# Password: (اكتب أي password)
# Password (again): (كرره)
```

### تسجيل Models في Admin:

```python
# school/admin.py

from django.contrib import admin
from .models import Student, Subject, Grade


# الطريقة البسيطة
admin.site.register(Student)
admin.site.register(Subject)
admin.site.register(Grade)
```

### تخصيص Admin Panel:

```python
# school/admin.py — نسخة متقدمة

from django.contrib import admin
from .models import Student, Subject, Grade


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    # الأعمدة اللي بتظهر في List View
    list_display = ['name', 'age', 'email', 'student_image_preview']

    # فلاتر على اليمين
    list_filter = ['age']

    # Search
    search_fields = ['name', 'email']

    # ترتيب
    ordering = ['name']

    # عدد العناصر في الصفحة
    list_per_page = 20

    # الـ fields اللي بتتظهر في الـ Edit Form
    fields = ['name', 'age', 'email', 'image']

    # Custom column
    def student_image_preview(self, obj):
        from django.utils.html import mark_safe
        if obj.image:
            return mark_safe(f'<img src="{obj.image.url}" width="50" height="50" style="border-radius:50%">')
        return "لا توجد صورة"
    student_image_preview.short_description = "الصورة"


@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ['name', 'grade_count']
    search_fields = ['name']

    def grade_count(self, obj):
        return obj.grades.count()
    grade_count.short_description = "عدد الدرجات"


@admin.register(Grade)
class GradeAdmin(admin.ModelAdmin):
    list_display = ['student', 'subject', 'score']
    list_filter = ['subject', 'score']
    search_fields = ['student__name', 'subject__name']
    list_editable = ['score']  # بيخلي الـ score قابل للتعديل مباشرةً من القائمة
    ordering = ['-score']

    # Inline — بيعرض الـ Grades جوا صفحة الـ Student
    # (هنحطها جوا StudentAdmin بعدين)
```

### الـ Inline Admin:

```python
# school/admin.py — إضافة الـ Inline

class GradeInline(admin.TabularInline):
    """
    بيعرض درجات الطالب جوا صفحة تفاصيل الطالب في Admin
    """
    model = Grade
    extra = 1  # عدد الصفوف الفارغة للإضافة
    fields = ['subject', 'score']


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['name', 'age', 'email']
    inlines = [GradeInline]  # ← هنا بنضيف الـ Inline
    search_fields = ['name', 'email']
```

---

## الـ select_related و prefetch_related

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph TD
    subgraph select["select_related — لـ ForeignKey و OneToOne"]
        A1["Grade.objects.select_related<br>('student', 'subject')"]
        B1["SQL: JOIN واحد<br>يجيب كل البيانات"]
    end
    subgraph prefetch["prefetch_related — لـ ManyToMany و reverse FK"]
        A2["Student.objects.prefetch_related<br>('grades__subject')"]
        B2["SQL: 2 queries منفصلين<br>بيتعملوا Python join"]
    end

    A1 --> B1
    A2 --> B2

    style select fill:#1a202c,stroke:#276749
    style prefetch fill:#1a202c,stroke:#2b6cb0
```

```python
# select_related — للـ ForeignKey (JOIN في SQL)
grades = Grade.objects.select_related('student', 'subject').all()
# SQL: SELECT * FROM grade JOIN student JOIN subject

# prefetch_related — لـ ManyToMany أو الـ reverse relations
students = Student.objects.prefetch_related('grades__subject').all()
# SQL أول: SELECT * FROM student
# SQL تاني: SELECT * FROM grade WHERE student_id IN (1,2,3,...) + JOIN subject

# متى تستخدم أيهم؟
# select_related: لما تجي الـ data المربوطة بيها مرة في نفس الـ request
# prefetch_related: لما تجي مجموعة من الـ related objects (one-to-many, many-to-many)
```

---

## المرحلة الثالثة Checkpoint ✅

عندنا دلوقتي:
- ORM كامل: Create, Read, Update, Delete.
- Field Lookups: كل الـ patterns من `exact` للـ `icontains` للـ relationship lookups.
- Aggregation: `Sum`, `Avg`, `Count`, `annotate` للـ Leaderboard.
- F() expressions للـ atomic updates.
- Admin Panel مخصّص مع `list_display`, `search_fields`, `inlines`.
- N+1 Problem محلول بـ `select_related`.

---

# ⚙️ المرحلة الرابعة — إعادة الهيكلة: CBVs و Middleware

## المشكلة في الـ Function-Based Views

### قبل — الكود الوحش:

```python
# الكود اللي عندنا دلوقتي في الـ views.py
# لاحظ كمية الـ repetition!

@login_required(login_url='school:login')
def student_create(request):
    if request.method == 'POST':
        form = StudentForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            messages.success(request, 'تم الإضافة بنجاح!')
            return redirect('school:student_list')
    else:
        form = StudentForm()
    return render(request, 'school/student_form.html', {'form': form})

@login_required(login_url='school:login')
def subject_create(request):
    if request.method == 'POST':
        form = SubjectForm(request.POST)       # نفس الكلام!
        if form.is_valid():
            form.save()                        # نفس الكلام!
            messages.success(request, 'تم الإضافة بنجاح!')  # نفس الكلام!
            return redirect('school:subject_list')
    else:
        form = SubjectForm()                   # نفس الكلام!
    return render(request, 'school/subject_form.html', {'form': form})

# ده بيتكرر لـ Grade كمان! DRY Principle اتكسر تماماً.
```

### الحل — Class-Based Views (CBVs):

> [!abstract] 🧠 المفهوم المعماري
> **Class-Based Views (CBVs)** هي طريقة Django لكتابة الـ views كـ classes بدل functions. الفايدة:
> 1. **DRY** (Don't Repeat Yourself): كتابة الكود مرة واحدة.
> 2. **Mixins**: بتضيف functionality بالوراثة.
> 3. **Generic Views**: Views جاهزة للـ CRUD من Django نفسه.

---

## Class-Based Views — الأساسيات

### View بسيط:

```python
# school/views.py — نسخة CBV

from django.views import View
from django.views.generic import (
    ListView, DetailView, CreateView,
    UpdateView, DeleteView, TemplateView
)
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.messages.views import SuccessMessageMixin
from django.urls import reverse_lazy

from .models import Student, Subject, Grade
from .forms import StudentForm, SubjectForm, GradeForm


# ══════════════════════════════════════
#  CBV أساسي — مثل الـ FBV بس بـ class
# ══════════════════════════════════════

class HomeView(LoginRequiredMixin, TemplateView):
    """
    LoginRequiredMixin: بيعمل نفس @login_required
    TemplateView: بس بيعرض template من غير منطق
    """
    template_name = 'school/home.html'
    login_url = 'school:login'

    def get_context_data(self, **kwargs):
        """بنضيف الـ context هنا بدل ما نبعته في render()"""
        context = super().get_context_data(**kwargs)
        context['student_count'] = Student.objects.count()
        context['subject_count'] = Subject.objects.count()
        context['grade_count'] = Grade.objects.count()
        return context
```

### Generic Views للـ CRUD:

```python
# ══════════════════════════════════════
#  STUDENT VIEWS — Generic CBVs
# ══════════════════════════════════════

class StudentListView(LoginRequiredMixin, ListView):
    """
    ListView — بيعمل:
    1. يجيب Model.objects.all()
    2. يحطها في context بـ object_list أو model_name_list
    3. يعرض template
    """
    model = Student
    template_name = 'school/student_list.html'
    context_object_name = 'students'  # بدل 'object_list'
    login_url = 'school:login'
    paginate_by = 9  # Pagination تلقائي! 9 طلاب في الصفحة

    def get_queryset(self):
        """تخصيص الـ queryset"""
        return Student.objects.all()


class StudentDetailView(LoginRequiredMixin, DetailView):
    """
    DetailView — بياخد pk أو slug من الـ URL
    وبيجيب الـ object الواحد
    """
    model = Student
    template_name = 'school/student_detail.html'
    context_object_name = 'student'
    login_url = 'school:login'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['grades'] = self.object.grades.select_related('subject').all()
        return context


class StudentCreateView(LoginRequiredMixin, SuccessMessageMixin, CreateView):
    """
    CreateView — بيعمل:
    1. GET: بيعرض form فاضية
    2. POST: بيعمل validate وbيحفظ
    3. بيروح لـ success_url بعد الحفظ
    """
    model = Student
    form_class = StudentForm
    template_name = 'school/student_form.html'
    success_url = reverse_lazy('school:student_list')
    success_message = "تم إضافة الطالب %(name)s بنجاح! 🎉"
    login_url = 'school:login'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'إضافة طالب جديد'
        context['action'] = 'إضافة'
        return context


class StudentUpdateView(LoginRequiredMixin, SuccessMessageMixin, UpdateView):
    """
    UpdateView — نفس CreateView بس بياخد instance موجود
    """
    model = Student
    form_class = StudentForm
    template_name = 'school/student_form.html'
    success_url = reverse_lazy('school:student_list')
    success_message = "تم تحديث البيانات بنجاح!"
    login_url = 'school:login'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = f'تعديل: {self.object.name}'
        context['action'] = 'حفظ التعديلات'
        return context


class StudentDeleteView(LoginRequiredMixin, DeleteView):
    """
    DeleteView — بيعرض صفحة تأكيد حذف
    لما بيتأكد، بيحذف ويروح لـ success_url
    """
    model = Student
    template_name = 'school/student_confirm_delete.html'
    success_url = reverse_lazy('school:student_list')
    login_url = 'school:login'

    def delete(self, request, *args, **kwargs):
        """Override عشان نضيف success message"""
        student = self.get_object()
        messages.success(request, f'تم حذف الطالب {student.name}')
        return super().delete(request, *args, **kwargs)
```

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "ليه بنستخدم `reverse_lazy` مش `reverse` في الـ CBVs؟"
>
> لأن الـ `success_url = reverse('school:student_list')` بيتنفّذ وقت **تحميل الـ class** — قبل ما الـ URLs تتحمّل كلها! ده بيدي `NoReverseMatch` Error.
>
> `reverse_lazy` مش بينفّذ الـ reverse غير لما يُحتاج فعلاً (lazy evaluation). كل الـ `success_url` في الـ CBVs لازم تكون `reverse_lazy`.

### تحديث الـ urls.py للـ CBVs:

```python
# school/urls.py — نسخة CBV

from django.urls import path
from . import views  # هنا views.py بيحتوي الـ CBV classes

app_name = 'school'

urlpatterns = [
    path('', views.HomeView.as_view(), name='home'),

    # Students
    path('students/', views.StudentListView.as_view(), name='student_list'),
    path('students/create/', views.StudentCreateView.as_view(), name='student_create'),
    path('students/<int:pk>/', views.StudentDetailView.as_view(), name='student_detail'),
    path('students/<int:pk>/update/', views.StudentUpdateView.as_view(), name='student_update'),
    path('students/<int:pk>/delete/', views.StudentDeleteView.as_view(), name='student_delete'),
    # ... باقي الـ URLs
]
```

### Subject و Grade CBVs:

```python
# Subject CBVs — نفس الـ pattern بالظبط

class SubjectListView(LoginRequiredMixin, ListView):
    model = Subject
    template_name = 'school/subject_list.html'
    context_object_name = 'subjects'
    login_url = 'school:login'

    def get_queryset(self):
        """بنضيف الـ Search هنا"""
        query = self.request.GET.get('q', '')
        qs = Subject.objects.all()
        if query:
            qs = qs.filter(name__icontains=query)
        return qs

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['query'] = self.request.GET.get('q', '')
        return context


class SubjectCreateView(LoginRequiredMixin, SuccessMessageMixin, CreateView):
    model = Subject
    form_class = SubjectForm
    template_name = 'school/subject_form.html'
    success_url = reverse_lazy('school:subject_list')
    success_message = "تم إضافة المادة بنجاح!"
    login_url = 'school:login'


class SubjectUpdateView(LoginRequiredMixin, SuccessMessageMixin, UpdateView):
    model = Subject
    form_class = SubjectForm
    template_name = 'school/subject_form.html'
    success_url = reverse_lazy('school:subject_list')
    success_message = "تم التحديث بنجاح!"
    login_url = 'school:login'


class SubjectDeleteView(LoginRequiredMixin, DeleteView):
    model = Subject
    template_name = 'school/subject_confirm_delete.html'
    success_url = reverse_lazy('school:subject_list')
    login_url = 'school:login'
```

---

## Mixins — قوة الـ Multiple Inheritance

> [!abstract] 🧠 المفهوم المعماري
> **Mixin** هو class صغير بيضيف functionality معينة. بتستخدمه مع الـ CBV بالـ Multiple Inheritance.
>
> مثال: بدل ما تكتب `@login_required` على كل view:
> ```python
> # FBV — لازم تحط الـ decorator على كل function
> @login_required
> def student_list(request): ...
>
> @login_required
> def student_create(request): ...
> ```
>
> مع CBVs:
> ```python
> # CBV — تحط LoginRequiredMixin مرة وبيبقى مطبّق على كل method في الـ class
> class StudentListView(LoginRequiredMixin, ListView):
>     login_url = 'school:login'
>     ...
> ```

### أشهر الـ Mixins الجاهزة:

```python
from django.contrib.auth.mixins import (
    LoginRequiredMixin,       # بيتأكد إن الـ user logged in
    PermissionRequiredMixin,  # بيتأكد من permissions معينة
    UserPassesTestMixin,      # بتكتب test function بنفسك
)
from django.contrib.messages.views import SuccessMessageMixin  # رسالة نجاح تلقائية

# مثال على UserPassesTestMixin — بس الـ superuser يحذف
class StudentDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Student
    template_name = 'school/student_confirm_delete.html'
    success_url = reverse_lazy('school:student_list')

    def test_func(self):
        """الـ user بيعدّي الـ test ده؟"""
        return self.request.user.is_superuser

    def handle_no_permission(self):
        messages.error(self.request, 'مش عندك صلاحية الحذف!')
        return redirect('school:student_list')
```

### عمل Custom Mixin:

```python
# school/mixins.py — اعمل الملف ده

from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin


class SchoolLoginRequiredMixin(LoginRequiredMixin):
    """
    Mixin مخصص بيضيف login_url تلقائياً
    بدل ما تكتبه في كل view
    """
    login_url = 'school:login'
    raise_exception = False  # بيعمل redirect مش 403


class SuccessDeleteMixin:
    """
    Mixin بيضيف success message بعد الحذف
    """
    delete_success_message = "تم الحذف بنجاح"

    def delete(self, request, *args, **kwargs):
        obj = self.get_object()
        msg = self.delete_success_message
        if hasattr(obj, 'name'):
            msg = f"تم حذف {obj.name} بنجاح"
        result = super().delete(request, *args, **kwargs)
        messages.success(request, msg)
        return result


# استخدامه:
class StudentDeleteView(SchoolLoginRequiredMixin, SuccessDeleteMixin, DeleteView):
    model = Student
    template_name = 'school/student_confirm_delete.html'
    success_url = reverse_lazy('school:student_list')
    delete_success_message = "تم حذف الطالب بنجاح"
```

---

## الـ Middleware — الطبقات اللي بتلف الـ Requests

### إيه الـ Middleware؟

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph TD
    R["🌐 Request"] --> M1
    M1["Middleware 1<br>SecurityMiddleware"] --> M2
    M2["Middleware 2<br>SessionMiddleware"] --> M3
    M3["Middleware 3<br>AuthenticationMiddleware"] --> V
    V["⚙️ View<br>views.py"]
    V --> M3R
    M3R["Middleware 3<br>Response Phase"] --> M2R
    M2R["Middleware 2<br>Response Phase"] --> M1R
    M1R["Middleware 1<br>Response Phase"] --> RS["📤 Response"]

    style R fill:#276749,color:#e2e8f0
    style V fill:#744210,color:#e2e8f0
    style RS fill:#276749,color:#e2e8f0
```

الـ Middleware بيشتغل **قبل** وصول الـ request للـ view وبعد خروج الـ response منه. ده زي الـ onion layers.

### Middleware جاهزة مهمة في `settings.py`:

```python
MIDDLEWARE = [
    # بيضيف security headers (HSTS, X-Content-Type-Options, etc.)
    'django.middleware.security.SecurityMiddleware',

    # بيعمل sessions — بيحفظ ويحمّل session data
    'django.contrib.sessions.middleware.SessionMiddleware',

    # بيعمل حاجات زي append slash للـ URLs
    'django.middleware.common.CommonMiddleware',

    # بيحمي من CSRF attacks — بيتحقق من الـ csrf_token في الـ forms
    'django.middleware.csrf.CsrfViewMiddleware',

    # بيحط request.user تلقائياً — بيبقى available في كل view
    'django.contrib.auth.middleware.AuthenticationMiddleware',

    # بيدير الـ flash messages
    'django.contrib.messages.middleware.MessageMiddleware',

    # بيحمي من Clickjacking — بيضيف X-Frame-Options header
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

### عمل Custom Middleware:

```python
# school/middleware.py — اعمل الملف ده

import time
import logging

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware:
    """
    Middleware بيـ log كل request مع وقت التنفيذ
    """
    def __init__(self, get_response):
        """
        بيتشغل مرة واحدة لما السيرفر يبدأ
        get_response = الـ function الجاية (الـ middleware التالت أو الـ view)
        """
        self.get_response = get_response

    def __call__(self, request):
        """بيتشغل مع كل request"""
        # ━━━ قبل الـ view ━━━
        start_time = time.time()
        user = request.user if hasattr(request, 'user') else 'Anonymous'

        # ━━━ بعت الـ request للـ view ━━━
        response = self.get_response(request)

        # ━━━ بعد الـ view ━━━
        duration = time.time() - start_time
        logger.info(
            f"{request.method} {request.path} "
            f"[{response.status_code}] "
            f"{duration:.3f}s "
            f"User: {user}"
        )
        return response


class MaintenanceModeMiddleware:
    """
    Middleware بيعرض رسالة Maintenance لو الموقع في صيانة
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        from django.conf import settings
        from django.http import HttpResponse

        # لو الـ maintenance mode شغّال وده مش superuser
        if getattr(settings, 'MAINTENANCE_MODE', False):
            if not request.user.is_superuser:
                return HttpResponse(
                    "<h1>🔧 الموقع في صيانة</h1><p>هنرجع قريباً!</p>",
                    status=503
                )
        return self.get_response(request)
```

تسجيل الـ Middleware في `settings.py`:

```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    # ...
    'school.middleware.RequestLoggingMiddleware',  # ← ضيفه هنا
]
```

---

## المرحلة الرابعة Checkpoint ✅

عندنا دلوقتي:
- Class-Based Views بدل Function-Based Views.
- Generic Views: `ListView`, `DetailView`, `CreateView`, `UpdateView`, `DeleteView`.
- Mixins: `LoginRequiredMixin`, `SuccessMessageMixin`, custom mixins.
- Pagination تلقائي بـ `paginate_by`.
- Custom Middleware لـ logging.

---

# 🔐 المرحلة الخامسة — الأمان والـ Authentication

## Sessions — إزاي Django يتذكرك

### إيه الـ Session؟

HTTP مش بيتذكر — كل request مستقل تماماً. الـ Session هي الحل لإنك تحفظ بيانات المستخدم بين الـ requests.

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
sequenceDiagram
    participant م as المتصفح
    participant د as Django
    participant ق as قاعدة البيانات

    م->>د: POST /login/ (username, password)
    د->>ق: تحقق من البيانات
    ق-->>د: User object
    Note over د: أنشئ Session<br>session_key = "abc123xyz"
    د->>ق: احفظ Session في django_session table
    د-->>م: Response + Set-Cookie: sessionid=abc123xyz

    م->>د: GET /students/ (Cookie: sessionid=abc123xyz)
    Note over د: SessionMiddleware<br>يقرأ الـ cookie
    د->>ق: SELECT FROM django_session WHERE key='abc123xyz'
    ق-->>د: Session Data → user_id = 5
    Note over د: AuthMiddleware يجيب<br>request.user = User(id=5)
    د-->>م: HTML Page للـ User المعروف
```

### استخدام الـ Session مباشرةً:

```python
# في أي view

def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(request, username=username, password=password)
        if user:
            login(request, user)  # Django بيحفظ الـ session تلقائياً
            return redirect('school:home')

# بعد الـ login، تقدر تحفظ data في الـ session
def some_view(request):
    # حفظ في الـ session
    request.session['last_visited'] = 'student_list'
    request.session['cart_count'] = 5

    # قراءة من الـ session
    last_page = request.session.get('last_visited', 'home')

    # حذف من الـ session
    if 'cart_count' in request.session:
        del request.session['cart_count']

    # مسح كل الـ session
    request.session.flush()  # بيمسح session ويعمل جديد
```

### Session Settings:

```python
# settings.py

# مدة الـ session cookie (بالثواني)
SESSION_COOKIE_AGE = 86400 * 14  # 14 يوم

# بيمسح الـ session لما المتصفح يتقفل
SESSION_EXPIRE_AT_BROWSER_CLOSE = False

# اسم الـ cookie
SESSION_COOKIE_NAME = 'iti_sessionid'

# أأمن — بيبعت الـ cookie بس على HTTPS
SESSION_COOKIE_SECURE = False  # True في Production

# بيمنع JavaScript من قراءة الـ cookie (XSS protection)
SESSION_COOKIE_HTTPONLY = True
```

---

## Authentication — نظام المستخدمين الكامل

### الـ User Model الجاهز:

```python
from django.contrib.auth.models import User

# الـ fields المتاحة في Django's User model
"""
username      — اسم المستخدم (unique)
password      — مشفّر تلقائياً بـ PBKDF2
first_name    — الاسم الأول
last_name     — الاسم الأخير
email         — البريد الإلكتروني
is_active     — الحساب مفعّل؟
is_staff      — يقدر يدخل Admin Panel؟
is_superuser  — له كل الصلاحيات؟
date_joined   — تاريخ التسجيل
last_login    — آخر تسجيل دخول
"""

# إنشاء user
user = User.objects.create_user(
    username='ahmed',
    email='ahmed@iti.edu.eg',
    password='secret123'  # بيتشفّر تلقائياً
)

# إنشاء superuser
admin = User.objects.create_superuser(
    username='admin',
    email='admin@iti.edu.eg',
    password='admin123'
)

# التحقق من الـ password
from django.contrib.auth import authenticate
user = authenticate(username='ahmed', password='secret123')
# لو صح: بيرجع User object
# لو غلط: بيرجع None
```

### الـ Login / Logout Views:

```python
# school/views.py — Authentication Views

from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages


def login_view(request):
    """
    AuthenticationForm — form جاهز من Django
    بيعمل validation على الـ username والـ password تلقائياً
    """
    # لو هو logged in أصلاً، ودّيه للـ home
    if request.user.is_authenticated:
        return redirect('school:home')

    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)

            # لو في ?next= في الـ URL، روح ليه
            # ده بيحصل لما تحاول تفتح protected page وانت مش logged in
            next_url = request.GET.get('next')
            if next_url:
                return redirect(next_url)
            return redirect('school:home')
        else:
            messages.error(request, 'اسم المستخدم أو كلمة السر غلط!')
    else:
        form = AuthenticationForm()

    return render(request, 'school/login.html', {'form': form})


@login_required(login_url='school:login')
def logout_view(request):
    """Logout — بيمسح الـ session"""
    logout(request)
    messages.info(request, 'تم تسجيل الخروج بنجاح 👋')
    return redirect('school:login')


@login_required(login_url='school:login')
def profile(request):
    """صفحة الـ Profile — بيعرض بيانات الـ user الحالي"""
    return render(request, 'school/profile.html')
```

### settings.py للـ Authentication:

```python
# settings.py

# لو الـ URL المطلوب محمي، Django بيـ redirect هنا
LOGIN_URL = '/login/'

# بعد الـ login الناجح، روح لـ
LOGIN_REDIRECT_URL = '/'

# بعد الـ logout، روح لـ
LOGOUT_REDIRECT_URL = '/login/'
```

### الـ `@login_required` Decorator:

```python
from django.contrib.auth.decorators import login_required

# استخدام بسيط — بيستخدم LOGIN_URL من settings.py
@login_required
def student_list(request):
    ...

# أو بتحدد الـ login URL
@login_required(login_url='/login/')
def student_list(request):
    ...

# في الـ Template، بتتحقق بـ:
# {% if user.is_authenticated %}
# أو
# {{ request.user.username }}
# أو
# {{ user.is_staff }}  لو staff
```

### الـ Profile Template:

```html
<!-- templates/school/profile.html -->
{% extends 'school/base.html' %}

{% block title %}الملف الشخصي{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header bg-dark text-white">
                <h4>👤 الملف الشخصي</h4>
            </div>
            <div class="card-body">
                <table class="table">
                    <tr>
                        <th>اسم المستخدم</th>
                        <td>{{ user.username }}</td>
                    </tr>
                    <tr>
                        <th>الاسم الأول</th>
                        <td>{{ user.first_name | default:"غير محدد" }}</td>
                    </tr>
                    <tr>
                        <th>الاسم الأخير</th>
                        <td>{{ user.last_name | default:"غير محدد" }}</td>
                    </tr>
                    <tr>
                        <th>البريد الإلكتروني</th>
                        <td>{{ user.email | default:"غير محدد" }}</td>
                    </tr>
                    <tr>
                        <th>تاريخ الانضمام</th>
                        <td>{{ user.date_joined | date:"d/m/Y" }}</td>
                    </tr>
                    <tr>
                        <th>آخر دخول</th>
                        <td>{{ user.last_login | date:"d/m/Y H:i" }}</td>
                    </tr>
                    <tr>
                        <th>نوع الحساب</th>
                        <td>
                            {% if user.is_superuser %}
                            <span class="badge bg-danger">Superuser 👑</span>
                            {% elif user.is_staff %}
                            <span class="badge bg-warning">Staff ⭐</span>
                            {% else %}
                            <span class="badge bg-secondary">User 👤</span>
                            {% endif %}
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

---

## CSRF Protection — الحماية من التزوير

> [!bug] 🕵️ فخ الانترفيو
> **السؤال:** "إيه الـ CSRF attack وإزاي Django بيحمي منه؟"
>
> **CSRF** (Cross-Site Request Forgery) = هجوم بيخلي المستخدم يبعت request لموقعك من غير ما يعرف.
>
> مثال: أنت logged in في الـ ITI School. فتحت موقع تاني فيه:
> ```html
> <img src="http://iti-school.com/students/1/delete/" style="display:none">
> ```
> ده بيبعت GET request لحذف الطالب باستخدام الـ session بتاعتك!
>
> **حل Django**: كل POST form لازم يحتوي على `{% csrf_token %}` — ده token سري بيتغيّر مع كل session. `CsrfViewMiddleware` بيتحقق منه قبل أي POST. الموقع التاني مش يعرف الـ token ده، فالـ request هيتشاف ويترفض.

```html
<!-- في كل form POST: -->
<form method="POST">
    {% csrf_token %}  <!-- ← إلزامي دايماً -->
    <!-- fields -->
</form>

<!-- بيـ generate HTML زي ده: -->
<input type="hidden" name="csrfmiddlewaretoken" value="abc123xyz...randomtoken...">
```

---

## المرحلة الخامسة Checkpoint ✅

عندنا دلوقتي:
- Sessions: كيف تشتغل ومتى.
- Authentication: Login, Logout, `login_required`.
- Profile page بيعرض بيانات الـ user الحالي.
- CSRF Protection مفهوم وطريقة الحماية.
- `next` parameter لـ redirect بعد الـ login.

---

# 🚀 المرحلة السادسة — عصر الـ API: Django REST Framework

## ليه نحتاج API أصلاً؟

> [!abstract] 🧠 المفهوم المعماري
> الـ Monolith اللي بنيناه — Server بيعمل HTML وبيبعته للمتصفح. ده شغّال تمام، لكن فيه مشاكل:
>
> 1. **الـ Frontend مربوط بالـ Backend**: لو عايز React أو Flutter App — مش تقدر.
> 2. **Mobile Apps**: مش تقدر تعمل iOS/Android app يستخدم الـ Django Templates.
> 3. **Third Party Integration**: مش تقدر تسمح لـ services تانية تستخدم بياناتك.
>
> **الحل: REST API**
> بدل ما الـ server يبعت HTML، بيبعت JSON. أي client (React, Flutter, iOS, Postman) يقدر يستخدم الـ API.

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096', 'clusterBkg': '#1a202c'}}}%%
graph TD
    subgraph قبل["الـ Monolith القديم"]
        D1["Django Views"] -->|"HTML"| B1["متصفح فقط"]
    end
    subgraph بعد["بعد إضافة DRF"]
        D2["Django + DRF"] -->|"JSON"| C1["React / Vue"]
        D2 -->|"JSON"| C2["Flutter / React Native"]
        D2 -->|"JSON"| C3["iOS / Android"]
        D2 -->|"JSON"| C4["Services تانية"]
        D2 -->|"HTML"| C5["المتصفح (الـ Templates القديمة)"]
    end

    style قبل fill:#1a202c,stroke:#744210
    style بعد fill:#1a202c,stroke:#276749
```

## تثبيت Django REST Framework

```bash
pip install djangorestframework
pip install django-cors-headers  # للسماح بـ CORS للـ Frontend
```

إضافته في `settings.py`:

```python
INSTALLED_APPS = [
    # ...
    'rest_framework',
    'corsheaders',
    'school',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # ← لازم يكون في الأول
    # ... باقي الـ middleware
]

# إعدادات DRF
REST_FRAMEWORK = {
    # Authentication
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
        # بعدين هنضيف JWT
    ],
    # Permissions
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    # Pagination
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}

# CORS — في الـ Development، سمح لكل الـ origins
CORS_ALLOW_ALL_ORIGINS = True
# في الـ Production:
# CORS_ALLOWED_ORIGINS = [
#     'http://localhost:3000',  # React Dev
#     'https://iti-school-frontend.com',
# ]
```

## الـ Serializers — قلب الـ DRF

> [!abstract] 🧠 المفهوم المعماري
> الـ Serializer هو المسؤول عن:
> - **Serialization**: تحويل Django Model → JSON (للـ Response).
> - **Deserialization**: تحويل JSON → Django Model (للـ Request + Validation).
>
> هو نفس مفهوم الـ ModelForm بس للـ API.

```python
# school/serializers.py — اعمل الملف ده

from rest_framework import serializers
from .models import Student, Subject, Grade


class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = ['id', 'name', 'description']


class GradeSerializer(serializers.ModelSerializer):
    """Serializer للدرجة مع معلومات المادة"""
    subject_name = serializers.CharField(
        source='subject.name',
        read_only=True
    )

    class Meta:
        model = Grade
        fields = ['id', 'student', 'subject', 'subject_name', 'score']

    def validate_score(self, value):
        """Custom validation"""
        if value < 0 or value > 100:
            raise serializers.ValidationError("الدرجة لازم تكون بين 0 و 100")
        return value


class StudentSerializer(serializers.ModelSerializer):
    """Serializer للطالب"""
    # Nested serializer لعرض الدرجات مع الطالب
    grades = GradeSerializer(many=True, read_only=True)
    # حقل محسوب
    total_score = serializers.SerializerMethodField()
    # الصورة كـ URL
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Student
        fields = [
            'id', 'name', 'age', 'email',
            'image', 'image_url',
            'grades', 'total_score'
        ]
        extra_kwargs = {
            'image': {'write_only': True},  # للـ upload بس
        }

    def get_total_score(self, obj):
        """بيحسب مجموع الدرجات"""
        total = obj.grades.aggregate(
            total=models.Sum('score')
        )['total']
        return total or 0

    def get_image_url(self, obj):
        """بيرجع الـ URL الكامل للصورة"""
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None

    def validate_email(self, value):
        return value.lower()


class StudentListSerializer(serializers.ModelSerializer):
    """Serializer مبسّط للقوائم — بدون nested data"""
    class Meta:
        model = Student
        fields = ['id', 'name', 'age', 'email', 'image']
```

## الـ API Views

### ViewSets — أقوى طريقة في DRF:

```python
# school/api_views.py — اعمل الملف ده

from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.db.models import Sum

from .models import Student, Subject, Grade
from .serializers import (
    StudentSerializer, StudentListSerializer,
    SubjectSerializer, GradeSerializer
)


class StudentViewSet(viewsets.ModelViewSet):
    """
    ViewSet واحد بيعمل كل الـ CRUD تلقائياً:
    GET    /api/students/           → list()
    POST   /api/students/           → create()
    GET    /api/students/{id}/      → retrieve()
    PUT    /api/students/{id}/      → update()
    PATCH  /api/students/{id}/      → partial_update()
    DELETE /api/students/{id}/      → destroy()
    """
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated]

    # Search و Ordering تلقائي
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'email']
    ordering_fields = ['name', 'age']
    ordering = ['name']

    def get_serializer_class(self):
        """استخدم serializer مختلف حسب الـ action"""
        if self.action == 'list':
            return StudentListSerializer
        return StudentSerializer

    def get_serializer_context(self):
        """بنضيف الـ request للـ serializer context"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @action(detail=False, methods=['GET'])
    def leaderboard(self, request):
        """
        Custom action — /api/students/leaderboard/
        @action(detail=False) = مش محتاج pk
        @action(detail=True)  = محتاج pk (زي /api/students/1/grades/)
        """
        top_students = (
            Student.objects
            .annotate(total_score=Sum('grades__score'))
            .filter(total_score__isnull=False)
            .order_by('-total_score')[:5]
        )
        serializer = StudentListSerializer(top_students, many=True)
        data = []
        for s in top_students:
            data.append({
                'id': s.id,
                'name': s.name,
                'total_score': s.total_score,
            })
        return Response(data)

    @action(detail=True, methods=['GET'])
    def grades(self, request, pk=None):
        """
        /api/students/{id}/grades/ — درجات طالب معين
        """
        student = self.get_object()
        grades = student.grades.select_related('subject').all()
        serializer = GradeSerializer(grades, many=True)
        return Response(serializer.data)


class SubjectViewSet(viewsets.ModelViewSet):
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']


class GradeViewSet(viewsets.ModelViewSet):
    queryset = Grade.objects.select_related('student', 'subject').all()
    serializer_class = GradeSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['student__name', 'subject__name']
    ordering_fields = ['score']
```

### الـ API URLs:

```python
# school/api_urls.py — اعمل الملف ده

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import api_views

# Router — بيعمل الـ URLs تلقائياً للـ ViewSets
router = DefaultRouter()
router.register(r'students', api_views.StudentViewSet)
router.register(r'subjects', api_views.SubjectViewSet)
router.register(r'grades', api_views.GradeViewSet)

urlpatterns = [
    path('', include(router.urls)),
]

# الـ URLs اللي بتتعمل تلقائياً:
# GET    /api/students/
# POST   /api/students/
# GET    /api/students/{id}/
# PUT    /api/students/{id}/
# PATCH  /api/students/{id}/
# DELETE /api/students/{id}/
# GET    /api/students/leaderboard/    ← custom action
# GET    /api/students/{id}/grades/    ← custom action
```

في `iti_school/urls.py`:

```python
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('school.urls')),       # الـ Templates
    path('api/', include('school.api_urls')),  # الـ API
    # DRF Login/Logout للـ Browsable API
    path('api-auth/', include('rest_framework.urls')),
]
```

---

> [!example] 💻 الكود الوحش vs الكود النضيف
> **الوحش — كتابة API Views يدوياً بدون DRF:**
> ```python
> # يعني 200 سطر لعمل CRUD بسيط!
> import json
> from django.http import JsonResponse
> from django.views.decorators.csrf import csrf_exempt
>
> @csrf_exempt
> def students_api(request):
>     if request.method == 'GET':
>         students = list(Student.objects.values('id', 'name', 'age', 'email'))
>         return JsonResponse({'students': students})
>     elif request.method == 'POST':
>         data = json.loads(request.body)
>         # لازم تعمل validation يدوياً!
>         if 'name' not in data:
>             return JsonResponse({'error': 'name required'}, status=400)
>         if 'email' not in data:
>             return JsonResponse({'error': 'email required'}, status=400)
>         # ... إلخ
>         student = Student.objects.create(**data)
>         return JsonResponse({'id': student.id}, status=201)
>     # ... باقي الـ methods
> ```
>
> **النضيف — DRF ViewSet:**
> ```python
> # 10 سطور تعمل نفس الكلام بالضبط + validation + pagination + filtering!
> class StudentViewSet(viewsets.ModelViewSet):
>     queryset = Student.objects.all()
>     serializer_class = StudentSerializer
>     permission_classes = [IsAuthenticated]
> ```

---

## الـ Browsable API — ميزة DRF الرائعة

لما تشغّل السيرفر وتفتح `http://127.0.0.1:8000/api/students/` في المتصفح — مش هتشوف JSON خالص. هتشوف **Browsable API** — واجهة جميلة بتقدر منها تعمل GET, POST, PUT, DELETE من المتصفح مباشرةً بدون Postman!

---

## ملخص مقارنة الرحلة

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#2b6cb0', 'primaryTextColor': '#e2e8f0', 'lineColor': '#718096'}}}%%
graph LR
    subgraph P1["Phase 1: الأساسيات"]
        A1["django-admin startproject<br>startapp, settings, venv"]
    end
    subgraph P2["Phase 2: MVP"]
        A2["Models → Forms → Views<br>FBV + Templates"]
    end
    subgraph P3["Phase 3: Database"]
        A3["ORM Operations<br>Aggregation, Admin Panel"]
    end
    subgraph P4["Phase 4: Refactoring"]
        A4["CBVs, Mixins<br>Middleware"]
    end
    subgraph P5["Phase 5: Security"]
        A5["Sessions, Auth<br>login_required, CSRF"]
    end
    subgraph P6["Phase 6: API"]
        A6["DRF Serializers<br>ViewSets, Router"]
    end

    P1 --> P2 --> P3 --> P4 --> P5 --> P6

    style P1 fill:#276749,color:#e2e8f0,stroke:#2f855a
    style P2 fill:#2b6cb0,color:#e2e8f0,stroke:#2c5282
    style P3 fill:#744210,color:#e2e8f0,stroke:#975a16
    style P4 fill:#553c9a,color:#e2e8f0,stroke:#6b46c1
    style P5 fill:#702459,color:#e2e8f0,stroke:#97266d
    style P6 fill:#2c7a7b,color:#e2e8f0,stroke:#285e61
```

---

## الـ JWT Authentication — للـ Production APIs

```bash
pip install djangorestframework-simplejwt
```

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

# iti_school/urls.py
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    # ...
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
```

**الاستخدام:**

```bash
# خطوة 1: اطلب الـ token
POST /api/token/
{
    "username": "admin",
    "password": "admin123"
}

# الـ Response:
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}

# خطوة 2: استخدم الـ access token في كل request
GET /api/students/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

---

## الـ Leaderboard Template الكامل:

```html
<!-- templates/school/leaderboard.html -->
{% extends 'school/base.html' %}

{% block title %}🏆 المتصدرين{% endblock %}

{% block content %}
<h2 class="mb-4">🏆 لوحة المتصدرين — أعلى 5 طلاب</h2>

{% if top_students %}
<div class="row">
    {% for student in top_students %}
    <div class="col-12 mb-3">
        <div class="card {% if forloop.first %}border-warning{% endif %}">
            <div class="card-body d-flex align-items-center">
                <div class="me-3" style="font-size: 2rem;">
                    {% if forloop.counter == 1 %}🥇
                    {% elif forloop.counter == 2 %}🥈
                    {% elif forloop.counter == 3 %}🥉
                    {% else %}{{ forloop.counter }}
                    {% endif %}
                </div>
                <div class="flex-grow-1">
                    <h5 class="mb-1">{{ student.name }}</h5>
                    <small class="text-muted">
                        {% for grade in student.grades.all %}
                        <span class="badge bg-secondary me-1">
                            {{ grade.subject.name }}: {{ grade.score }}
                        </span>
                        {% endfor %}
                    </small>
                </div>
                <div class="text-end">
                    <span class="fs-4 fw-bold text-success">
                        {{ student.total_score|floatformat:1 }}
                    </span>
                    <br>
                    <small class="text-muted">إجمالي</small>
                </div>
            </div>
        </div>
    </div>
    {% endfor %}
</div>
{% else %}
<div class="alert alert-info">لا توجد درجات مسجلة حتى الآن.</div>
{% endif %}
{% endblock %}
```

---

## الـ settings.py النهائي الكامل:

```python
# iti_school/settings.py — النسخة النهائية

from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-غيّر-ده-في-الـ-production'

DEBUG = True

ALLOWED_HOSTS = ['localhost', '127.0.0.1']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third Party
    'rest_framework',
    'corsheaders',
    # Local Apps
    'school.apps.SchoolConfig',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'school.middleware.RequestLoggingMiddleware',
]

ROOT_URLCONF = 'iti_school.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'iti_school.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'ar'
TIME_ZONE = 'Africa/Cairo'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

LOGIN_URL = '/login/'
LOGIN_REDIRECT_URL = '/'
LOGOUT_REDIRECT_URL = '/login/'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}

CORS_ALLOW_ALL_ORIGINS = DEBUG  # True في Development بس

SESSION_COOKIE_AGE = 86400 * 14  # 14 يوم
SESSION_COOKIE_HTTPONLY = True
```

---

## الـ Structure النهائية للمشروع:

```
iti-school/
├── venv/                           ← لا تحملها على Git
├── iti_school/
│   ├── __init__.py
│   ├── settings.py                 ← الإعدادات الكاملة
│   ├── urls.py                     ← Root URLs
│   ├── asgi.py
│   └── wsgi.py
├── school/
│   ├── migrations/
│   │   ├── __init__.py
│   │   └── 0001_initial.py
│   ├── __init__.py
│   ├── admin.py                    ← Admin Panel تخصيص
│   ├── api_urls.py                 ← API URLs (DRF Router)
│   ├── api_views.py                ← API ViewSets
│   ├── apps.py
│   ├── forms.py                    ← Django Forms
│   ├── middleware.py               ← Custom Middleware
│   ├── mixins.py                   ← Custom Mixins
│   ├── models.py                   ← Student, Subject, Grade
│   ├── serializers.py              ← DRF Serializers
│   ├── tests.py
│   ├── urls.py                     ← Template URLs
│   └── views.py                    ← CBVs
├── templates/
│   └── school/
│       ├── base.html
│       ├── home.html
│       ├── login.html
│       ├── profile.html
│       ├── student_list.html
│       ├── student_detail.html
│       ├── student_form.html
│       ├── student_confirm_delete.html
│       ├── subject_list.html
│       ├── subject_form.html
│       ├── subject_confirm_delete.html
│       ├── grade_list.html
│       ├── grade_form.html
│       ├── grade_confirm_delete.html
│       ├── leaderboard.html
│       └── contact.html
├── static/
│   └── css/
│       └── style.css
├── media/                          ← الصور المرفوعة (لا تحملها على Git)
│   └── students/
├── db.sqlite3                      ← لا تحملها على Git
├── requirements.txt
├── .gitignore
└── manage.py
```

### ملف `.gitignore`:

```gitignore
# Virtual Environment
venv/
env/

# Django
*.pyc
__pycache__/
db.sqlite3
media/
staticfiles/

# Environment Variables
.env
*.env

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

---

## أوامر المشروع الكاملة للمراجعة السريعة

```bash
# ━━━ تجهيز المشروع من الصفر ━━━
python3 -m venv venv
source venv/bin/activate
pip install django djangorestframework django-cors-headers Pillow
django-admin startproject iti_school .
python manage.py startapp school

# ━━━ الأوامر اليومية ━━━
python manage.py runserver              # تشغيل السيرفر
python manage.py makemigrations         # بعد كل تغيير في models.py
python manage.py migrate                # تطبيق الـ migrations
python manage.py createsuperuser        # إنشاء admin

# ━━━ الـ Django Shell للـ Testing ━━━
python manage.py shell
# >>> from school.models import Student
# >>> Student.objects.all()
# >>> Student.objects.create(name="Test", age=20, email="test@test.com")

# ━━━ حفظ الـ Dependencies ━━━
pip freeze > requirements.txt

# ━━━ تثبيت من ملف موجود ━━━
pip install -r requirements.txt
```

---

> الجزء ده دسم جداً ووصلت لآخر سعة الرسالة، انسخه عندك وقولي كمل عشان أصبلك باقي الرحلة بنفس العمق.

> **في الجزء الجاي:**
> - شرح مفصّل لـ Pagination في الـ Templates و API.
> - الـ Contact Form مع حفظها في DB وعرضها في Admin.
> - Testing: كتابة Unit Tests لكل الـ Models والـ Views.
> - Deployment: نشر المشروع على VPS (Ubuntu + Nginx + Gunicorn).
> - Advanced DRF: Filtering بـ `django-filter`, Throttling, Versioning.
> - Production Settings: `python-decouple`, PostgreSQL بدل SQLite.
