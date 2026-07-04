---
tags: [django, drf, python, backend, interview-prep, api]
part: 1
covers: "MVT Architecture · ORM & QuerySets · Serializers · Views & ViewSets · Auth & Permissions · Advanced Performance (N+1, Caching) · Signals & Middleware"
---

# 🧱 Django & DRF من الصفر (Q1 → نهاية الملف)

> [!info] 📖 إزاي تذاكر الملف ده؟
> الملف ده بيغطي رحلة بناء الـ API من أول الـ Request ما يدخل لحد ما الداتا ترجع لليوزر. كل سؤال بيبني على اللي قبله عشان يثبت المفاهيم التقنية بعمق ويديك إجابات نموذجية للإنترفيوهات.

## Q1 — هو إيه الـ (Django) ده أصلاً؟ وإيه حكاية الـ "Batteries Included" دي؟

### أصل الحكاية:
لما بنقرر ندخل عالم الـ (Backend) بنلاقي قدامنا طريقين؛ يا إما نبني كل حاجة من الصفر بأيدينا ونقعد نربط الداتا بيز ونعمل نظام حماية للمسارات ونعمل نظام تسجيل دخول لليوزرات، يا إما نستخدم فريم وورك يشيل الليلة دي عننا. الـ (Django) بيفكر كأنه شيف في مطعم مجهز؛ هو مش بس بيديك البوتاجاز، ده بيديك السكاكين والتوابل وحتة اللحمة كمان! دي فكرة الـ "Batteries Included" (البطاريات متضمنة) - يعني جانجو بييجي ومعاه كل حاجة هتحتاجها علشان تبني موقع أو (API) متكامل من غير ما تحتاج تدور على مكتبات خارجية تعملك الحاجات الأساسية زي الـ (Admin Panel) أو الـ (ORM) أو الـ (Authentication).
المشكلة العملية اللي بيحلها جانجو هي السرعة والأمان؛ بدل ما تضيع أسبوعين تضبط نظام الحماية من الـ (SQL Injection) والـ (CSRF Attacks) وتأمين الـ (Passwords) في الداتا بيز، جانجو بيبقى عامل حسابه في الحاجات دي من أول لحظة، وده بيخليك تركز على البزنس لوجيك (Business Logic) بتاعك على طول وتنجز مشروعك بسرعة.

علشان نشوف إزاي الإعدادات دي بتيجي جاهزة، خلينا نبص على شكل الـ `settings.py` اللي جانجو بيكريتها أوتوماتيك وبتوضح إزاي كل الأدوات دي مدمجة باي ديفولت (by default) ومش محتاجة تصطبها بنفسك.

```python
# settings.py
# Django automatically enables these core apps out of the box

INSTALLED_APPS: list[str] = [
    'django.contrib.admin',          # Built-in admin panel interface
    'django.contrib.auth',           # Authentication system (users, groups, permissions)
    'django.contrib.contenttypes',   # Database relation helper for models
    'django.contrib.sessions',       # Session framework for tracking requests
    'django.contrib.messages',       # Cookie- and session-based message framework
    'django.contrib.staticfiles',    # Static files management (CSS, JS, Images)
]
```

#### مثال 1: عمل مشروع جديد
علشان نكريت مشروع جديد بجانجو، بنستخدم أداة الـ (CLI) اللي بتنزل معاه وبتعمل لينا هيكل المشروع بالكامل في ثانية.

```python
# run this in your terminal to create the project template
# django-admin startproject myproject
```

#### مثال 2: استخدام نظام تسجيل الدخول الجاهز
هنا بنشوف إزاي بنستخدم الموديل الجاهز لليوزرات علشان نعمل يوزر جديد ونسيفه في الداتا بيز بكلمة سر متفرمة ومتأمنة (Hashed Password) من غير ما نكتب كود تشفير بنفسنا.

```python
from django.contrib.auth.models import User

# Creating a new user using Django's built-in User model and hashing mechanism
def create_new_user(username: str, email: str, password: str) -> User:
    # create_user hashes the password automatically using PBKDF2
    user: User = User.objects.create_user(
        username=username,
        email=email,
        password=password
    )
    return user
```

#### مثال 3: تأمين الفورمات ضد الـ CSRF
جانجو بيفرض حماية ضد هجمات الـ (Cross-Site Request Forgery) بشكل تلقائي. الكود ده بيوضح إزاي جانجو بيرفض الـ (POST requests) اللي معندهاش توكن الحماية ده.

```python
from django.views.decorators.csrf import csrf_protect
from django.http import HttpResponse, HttpRequest

@csrf_protect
def secure_submit_view(request: HttpRequest) -> HttpResponse:
    # If the request is POST, Django automatically validates the CSRF token in header/body
    if request.method == 'POST':
        return HttpResponse("Data saved safely because token was verified.")
    return HttpResponse("GET requests don't need CSRF token validation.")
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is Django and what does the "Batteries Included" philosophy mean?
* **الإجابة المثالية:** جانجو هو فريم وورك مكتوب بالـ Python مبني على فكرة توفير كل الأدوات الأساسية اللي المطور بيحتاجها علشان يبني موقع متكامل من غير ما يلف على مكتبات خارجية. معنى الـ "Batteries Included" إن الفريم وورك بييجي جاهز بنظام (Authentication) كامل للتعامل مع اليوزرات والصلاحيات، وجاهز بـ (ORM) قوي للتعامل مع الداتا بيز، ومعاه لوحة تحكم إدارية (Admin Panel) بتتبني لوحدها، بجانب أنظمة حماية مدمجة ضد الثغرات الشهيرة زي الـ (CSRF) والـ (SQL Injection) والـ (XSS). ده بيوفر وقت المطور وبيضمن إن السيستم مبني على قواعد حماية قوية وصح من الأول.

---

## Q2 — إيه الفرق بين الـ (Project) والـ (App) في جانجو؟ وليه متقسمين كده؟

### أصل الحكاية:
لما بنيجي نعمل مشروع بـ (Django)، أول خطوة بنعملها هي كتابة `startproject`. ده بيعمل لينا الـ (Project) الكبير. بعد كدة بنبدأ نكريت حاجات أصغر جواه اسمها الـ (Apps) عن طريق `startapp`.
التشبيه هنا: الـ (Project) عامل زي "المول التجاري" الكبير اللي بيوفر البنية التحتية، الإضاءة، الأمن، وتوصيلات الميه. الـ (App) هو "المحل" اللي بيتبنى جوة المول ده وبيقدم خدمة معينة ومستقلة بذاتها (زي كافيه، أو محل لبس). المول (الـ Project) دوره إنه يتحكم في الإعدادات العامة للموقع كله، والـ (Routing) الرئيسي للـ URLs، والـ Middlewares. المحل (الـ App) دوره يركز في وظيفته وبس (مثلاً App خاص باليوزرات، أو App للمنتجات، أو App للمدفوعات).
جانجو اتقسم كدة علشان يحقق مبدأ الـ (Reusability) أو إعادة الاستخدام. لو كتبت الـ (App) بتاع المنتجات بشكل صح وبطريقة مستقلة، هتقدر تفصله وتاخده زي ما هو وتنقله لمشروع تاني خالص وهيشتغل من غير ما تعيد كتابته من الصفر.

خلينا نبص على الهيكل التنظيمي للمشروع والـ (Apps) وإزاي بنربطهم في الإعدادات.

```python
# Project Directory Structure:
# myproject/                <-- The Project (The Mall)
#    settings.py            <-- Shared configurations
#    urls.py                <-- Main routing desk
#    wsgi.py
# shop/                     <-- An App (The Shoe Store)
#    models.py              <-- Shoe database tables
#    views.py               <-- Shoe business logic
#    urls.py                <-- Shoe specific URLs
```

#### مثال 1: تسجيل الـ App جوة الـ Project
بعد ما بنكريت الـ (App) عن طريق `python manage.py startapp shop` لازم نروح للمول (الـ Project) ونقوله إن في محل جديد فتح وسجل اسمه في الـ `settings.py`.

```python
# myproject/settings.py
# Registering the new 'shop' app to make Django aware of its models and migrations

INSTALLED_APPS: list[str] = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Registering our custom app
    'shop.apps.ShopConfig', 
]
```

#### مثال 2: توجيه المسارات من الـ Project للـ App
هنا بنشوف إزاي ملف الـ URLs الرئيسي للمشروع بياخد الطلب ويوجهه لملف الـ URLs الداخلي بتاع الـ (App) علشان يخليه يتعامل معاه.

```python
# myproject/urls.py
from django.contrib import admin
from django.urls import path, include

# Route requests starting with 'shop/' to the shop app's URLs file
urlpatterns: list = [
    path('admin/', admin.site.urls),
    path('shop/', include('shop.urls')), # Delegating to the app's URLs
]
```

#### مثال 3: ملف الـ URLs الخاص بالـ App نفسه
ده ملف الـ URLs الداخلي بتاع الـ (App) اللي بيحدد أنهي دالة أو كلاس هيتعامل مع المسار لما يجيلنا.

```python
# shop/urls.py
from django.urls import path
from .views import product_list_view

# Routing internally inside the shop app
urlpatterns: list = [
    path('products/', product_list_view, name='product-list'), # Resolves to /shop/products/
]
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is the difference between a Django Project and a Django App?
* **الإجابة المثالية:** الـ (Project) في جانجو هو الكونتينر الكبير اللي بيحتوي على الإعدادات العامة وتوصيلات الداتا بيز والـ URLs والـ Middlewares للمشروع كله. أما الـ (App) فهو تطبيق مصغر وجزء من الـ (Project) بيكون مسؤول عن وظيفة معينة ومحددة جوة السيستم (زي المدفوعات أو العربة). الـ (Project) الواحد ممكن يحتوي على كذا (App)، والـ (App) الواحد ممكن نستخدمه في أكتر من مشروع لو اتصمم بشكل مستقل. الفصل ده بيساعد في تنظيم الكود وتسهيل صيانته وتطبيق مبدأ الـ (Single Responsibility Principle) على مستوى التطبيق.

---

## Q3 — إيه هي معمارية الـ (MVT) وإزاي بتختلف عن الـ (MVC) الشهيرة؟

### أصل الحكاية:
في معمارية الـ (MVC) التقليدية اللي بنسمع عنها في لغات تانية، بيكون عندنا تلات حاجات: (Model) وهو الداتا، و (View) وهو الشكل النهائي للموقع، و (Controller) وهو العقل المفكر اللي بياخد الـ Request ويوجه الداتا.
جانجو لما نزل، المطورين بتوعه قالوا احنا هنعمل معمارية شبهها بس هنسميها (MVT) وهي اختصار لـ (Model, View, Template).
الناس سألوهم: طب فين الـ (Controller) اللي بيتحكم في الدنيا؟ قالوا: جانجو نفسه كـ (Framework) هو الـ (Controller). هو اللي بياخد الـ Request ويشوف الـ URL المطلوب ويبعته للـ View المناسب.
- الـ (Model) في جانجو: هو المسؤول عن بنية البيانات والتعامل مع الداتا بيز (الـ Data Layer).
- الـ (Template) في جانجو: هو ملف الـ HTML اللي بيتعرض فيه الداتا لليوزر (الـ Presentation Layer).
- الـ (View) في جانجو: هو البزنس لوجيك اللي بيتحكم في إيه اللي هيحصل بالداتا دي؛ بياخد الطلب، يطلب الداتا من الـ (Model)، ويبعتها للـ (Template) علشان تترندر وترجع لليوزر (الـ Logic Layer).
المشكلة اللي بتتحل هنا هي فصل الشغل؛ الباك إند ديفيلوبر بيكتب اللوجيك في الـ (View)، والفرونت إند ديفيلوبر بيعدل في الـ (Template) من غير ما حد يبوظ شغل التاني.

خلينا نبص على الكود البسيط ده لـ View بيوضح دور الـ (MVT) في تجميع الداتا وعرضها في تمبلت.

```python
# shop/views.py
from django.shortcuts import render
from django.http import HttpRequest, HttpResponse
from .models import Product

# The VIEW connects the Model and the Template
def product_list_view(request: HttpRequest) -> HttpResponse:
    # 1. Query data from the MODEL (Data Layer)
    products = Product.objects.filter(is_active=True)
    
    # 2. Pass the data to the TEMPLATE (Presentation Layer) inside the context dict
    context: dict = {
        'products': products,
        'title': 'Active Products'
    }
    
    # 3. Render and return the HTTP Response
    return render(request, 'shop/product_list.html', context)
```

دورة حياة الـ Request كاملة في جانجو بتوضح إزاي الـ (MVT) بيشتغل:

```mermaid
graph TD
    Client[Client / Browser] -->|1. HTTP Request| WSGI[WSGI / ASGI Server]
    WSGI -->|2. Middleware Chain| URLRouter[URL Router / urls.py]
    URLRouter -->|3. Match Route| View[View / views.py]
    View -->|4. Query Data| Model[Model / ORM]
    Model -->|5. SQL Queries| DB[(Database)]
    DB -->|6. Data Records| Model
    Model -->|7. QuerySet / Objects| View
    View -->|8. Render Data| Template[Template / HTML]
    Template -->|9. Rendered HTML / JSON| View
    View -->|10. Middleware Chain| WSGI
    WSGI -->|11. HTTP Response| Client
```

#### مثال 1: الموديل اللي بيمثل الداتا
هنا الموديل بيحدد شكل الجدول في الداتا بيز.

```python
# shop/models.py
from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_digits=2)
    is_active = models.BooleanField(default=True)
```

#### مثال 2: التمبلت اللي بيعرض الداتا
وده جزء من ملف الـ HTML اللي بياخد الداتا اللي باعتها الـ View ويعرضها لليوزر باستخدام لغة تمبلت جانجو (DTL).

```html
<!-- shop/templates/shop/product_list.html -->
<h1>{{ title }}</h1>
<ul>
    {% for product in products %}
        <li>{{ product.name }} - ${{ product.price }}</li>
    {% empty %}
        <li>No products found.</li>
    {% endfor %}
</ul>
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** Explain the MVT architecture in Django and how it differs from MVC.
* **الإجابة المثالية:** معمارية الـ (MVT) هي النسخة الخاصة بجانجو من الـ (MVC). الـ (Model) في جانجو بيقوم بنفس دور الـ (Model) في الـ (MVC) وهو التعامل مع البيانات والداتا بيز. الـ (Template) بيقوم بدور الـ (View) وهو ملفات الـ (HTML) المسؤولة عن العرض. أما الـ (View) في جانجو فبيقوم بدور الـ (Controller) وهو كتابة البزنس لوجيك وربط الـ Model بالـ Template. دور الـ (Controller) الرئيسي في جانجو بيقوم بيه الفريم وورك نفسه لما بيستقبل الـ Request ويوجهه للـ View المناسب بناء على ملف الـ URLs.

---

## Q4 — إزاي الـ (URL Routing) بيشتغل؟ وإزاي بنربط الـ URL بـ View معين؟

### أصل الحكاية:
الـ (URL Routing) هو زي الراجل اللي واقف على باب الشركة ويسألك: "أنت رايح أنهي مكتب؟" ويوجهك للمكتب الصح. لما يوزر بيكتب لينك في المتصفح بتاعه ويدوس إنتر، الـ (Request) ده بيوصل لجانجو، فجانجو بياخد الـ (URL) اللي مكتوب ويبدأ يقارنه بالـ (URLs) اللي متسجلة عنده في ملف `urls.py`.
جانجو بيمشي على ملف الـ `urls.py` ده سطر سطر من فوق لتحت. أول مسار بيطابق الـ (URL) اللي جاي، جانجو بيوقف البحث ويوجه الـ (Request) ده للـ (View) المرتبط بالمسار ده فوراً. لو السيرفر خلص الملف كله وملقاش أي تطابق، بيرجع لليوزر رد 404 (Page Not Found).
المشكلة اللي بيحلها الـ (URL Routing) هي تنظيم الـ (Endpoints) بتاعة الـ API والموقع، ويخلي المسارات نضيفة وسهلة القراءة ومستقلة تماماً عن اسم ملف الـ Python أو مكانه على السيرفر.

خلينا نشوف كود بيوضح إزاي بنكتب الـ (Paths) وبنستخدم الـ (Path Converters) لتمرير داتا من الـ URL للـ View.

```python
# shop/urls.py
from django.urls import path
from .views import product_detail_view, category_products_view

urlpatterns: list = [
    # 1. Matching dynamic integer as product primary key (pk)
    path('products/<int:pk>/', product_detail_view, name='product-detail'),
    
    # 2. Matching dynamic string as category slug
    path('category/<slug:category_slug>/', category_products_view, name='category-products'),
]
```

#### مثال 1: الـ View اللي بيستقبل الرقم الديناميكي من الـ URL
الـ View ده بياخد الـ `pk` اللي جانجو طلعه من الـ URL ويبدأ يستخدمه علشان يدور على المنتج في الداتا بيز.

```python
# shop/views.py
from django.http import HttpResponse, HttpRequest, Http404
from .models import Product

def product_detail_view(request: HttpRequest, pk: int) -> HttpResponse:
    try:
        # Fetching the product using the primary key passed from the URL pattern
        product = Product.objects.get(id=pk)
        return HttpResponse(f"Product: {product.name}, Price: {product.price}")
    except Product.DoesNotExist:
        raise Http404("This product does not exist in our store.")
```

#### مثال 2: استخدام الـ (Regular Expressions) في الـ URLs
ساعات بنحتاج نعمل شروط معقدة أكتر للمسارات، زي ماتشينج لتاريخ معين أو صيغة معينة. جانجو بيوفر الـ `re_path` للحالات دي.

```python
# shop/urls.py (Advanced Regex Matching)
from django.urls import re_path
from .views import archive_view

urlpatterns: list = [
    # Match dates like /archive/2026/
    re_path(r'^archive/(?P<year>[0-9]{4})/$', archive_view, name='archive-year'),
]
```

#### مثال 3: كتابة الـ View للـ Regex
الكود ده بيستقبل قيمة الـ `year` اللي اتفلترت بالـ (Regex) كـ (keyword argument).

```python
# shop/views.py
def archive_view(request: HttpRequest, year: str) -> HttpResponse:
    return HttpResponse(f"Showing archives for the year: {year}")
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** How does URL routing work in Django and what are path converters?
* **الإجابة المثالية:** الـ (URL Routing) في جانجو بيشتغل عن طريق مقارنة مسار الـ (Request) بالأنماط (Patterns) المتسجلة في ملف الـ `urls.py` الرئيسي والـ (Apps) التابعة ليه بشكل تتابعي من فوق لتحت. الـ (Path Converters) هي طرق لتحديد نوع البيانات اللي هتيجي في الـ (URL) وكمان سحبها وتمريرها كـ (Parameters) للـ (View) بشكل مباشر، زي الـ `<int:pk>` اللي بيضمن إن القيمة تكون رقم صحيح بس، والـ `<slug:name>` اللي بيقبل نصوص مفصلة بشرطة، والـ `<uuid:id>` وغيرها.

---

## Q5 — إيه الفرق الأساسي بين الـ (FBVs) والـ (CBVs) في جانجو العادي؟ وإمتى نستخدم كل واحد؟

### أصل الحكاية:
زي ما شفنا في Q4، بعد ما المسار يتحدد بنروح للـ (View). جانجو بيسمحلك تكتب الـ View ده بطريقتين: يا إما دالة بسيطة (Function-Based View - FBV) يا إما كلاس كامل (Class-Based View - CBV).
الـ (FBVs) هي الطريقة الكلاسيكية البسيطة؛ بتكتب دالة بتاخد الـ (Request) وتكتب كود عادي جواه (if conditions) علشان تفصل بين الـ (GET Request) والـ (POST Request). دي بتكون سهلة في القراية ومباشرة جداً ومفيش فيها أي سحر أو تعقيد.
الـ (CBVs) هي الطريقة التانية؛ بتعمل كلاس بيورث من كلاس أساسي في جانجو زي `View` أو `ListView`. ده بيخليك تقسم الكود لميثودز جاهزة زي `get()` و `post()` بدلاً من الـ (if conditions).
المشكلة اللي بتظهر هي: التكرار والوقت مقابل التعقيد. الـ (FBV) بتخليك تكرر كود كتير لو عندك كذا View بيعملوا نفس الحاجة بالظبط (زي إنك تجيب ليستة منتجات من الداتا بيز وتعرضها). الـ (CBV) بتلغي التكرار ده خالص بـ (Generic Views) جاهزة، بس لو حبيت تعمل حركة برة الصندوق أو تعدل تعديل مش تقليدي، بتلاقي نفسك غرقان في كلاسات ووراثة معقدة جداً وصعبة في الـ (Debugging).

خلينا نقارن بين الطريقتين بالكود علشان نوضح إزاي نفس العملية بتتعمل في الاتنين.

```python
# shop/views.py
from django.http import HttpRequest, HttpResponse
from django.views import View
from .models import Product

# --- WAY 1: Function-Based View (FBV) ---
def product_list_fbv(request: HttpRequest) -> HttpResponse:
    # Explicitly checking the HTTP method using conditional logic
    if request.method == 'GET':
        products = Product.objects.all()
        return HttpResponse(f"FBV response: {len(products)} products found.")
    return HttpResponse("Method not allowed", status=405)


# --- WAY 2: Class-Based View (CBV) ---
class ProductListCBV(View):
    # Django dispatches requests internally to helper methods matching the HTTP verb name
    def get(self, request: HttpRequest) -> HttpResponse:
        products = Product.objects.all()
        return HttpResponse(f"CBV response: {len(products)} products found.")
```

#### مثال 1: استخدام الـ (Generic ListView) لتوفير الكود
ده مثال لـ (CBV) بيستخدم الـ `ListView` الجاهز في جانجو. الكود ده بيجيب كل المنتجات أوتوماتيك ويبعتها لصفحة معينة من غير ما نكتب سطر استعلام واحد بإيدينا!

```python
# shop/views.py
from django.views.generic import ListView
from .models import Product

class ProductListView(ListView):
    model = Product                          # Tells Django to query Product.objects.all()
    template_name = 'shop/product_list.html' # Tells Django which template to render
    context_object_name = 'products'         # Changes the variable name inside the template context
```

#### مثال 2: استخدام الـ Decorators مع الـ FBV لحماية الصفحة
في الـ (FBV)، بنقدر نحمي الصفحة بسهولة جداً بكتابة (Decorator) فوق الدالة على طول.

```python
from django.contrib.auth.decorators import login_required

@login_required
def dashboard_fbv(request: HttpRequest) -> HttpResponse:
    return HttpResponse(f"Welcome back {request.user.username}!")
```

#### مثال 3: حماية الـ CBV باستخدام الـ (LoginRequiredMixin)
في الـ (CBV)، مش بينفع نستخدم الـ (Decorators) العادية بشكل مباشر فوق الكلاس، ولازم نستخدم (Mixin) ونخليه يورث منه.

```python
from django.contrib.auth.mixins import LoginRequiredMixin

class DashboardCBV(LoginRequiredMixin, View):
    # This view is protected and requires user to be logged in
    def get(self, request: HttpRequest) -> HttpResponse:
        return HttpResponse(f"Welcome back {request.user.username} from CBV dashboard!")
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is the difference between Function-Based Views and Class-Based Views in Django? When should you use each?
* **الإجابة المثالية:** الـ (FBVs) هي دوال بتستقبل الـ Request وبترجع Response، وبتتميز ببساطتها ووضوحها التام وسهولة استخدام الـ (Decorators) عليها، وهي الأنسب للمهام البسيطة أو اللوجيك المخصص المعقد. الـ (CBVs) هي كلاسات بتستغل الـ (Object-Oriented Programming) لتسهيل إعادة استخدام الكود عن طريق الـ (Inheritance) والـ (Generic Views)، وهي الأنسب للعمليات المتكررة زي الـ (CRUD operations) والـ (Forms). القرار بيعتمد على التعقيد؛ لو اللوجيك قياسي ونمطي يفضل (CBVs)، لو اللوجيك مخصص جداً وبسيط يفضل (FBVs).

---

## Q6 — إيه هو الـ (ORM) وإيه المشكلة اللي بيحلها مقارنة بكتابة (Raw SQL)؟

### أصل الحكاية:
لما بنتعامل مع الداتا بيز، اللغة الرسمية اللي بتفهمها هي الـ (SQL). عشان تجيب داتا كنت بتكتب كود شبه `SELECT * FROM products WHERE price > 100;`. المشكلة هنا إننا بنكتب كود الباك إند بلغة تانية خالص وهي الـ (Python) اللي بتتعامل مع الـ (Objects) والـ (Classes).
هنا بييجي دور الـ (ORM) وهي اختصار لـ (Object-Relational Mapping). الـ (ORM) هو المترجم اللي بيقف بين لغة الـ (Python) ولغة الـ (SQL).
الـ (ORM) بيفكر كدة: "أنا هخلي المطور يكتب كود Python نضيف جداً، وأنا هترجم الكود ده لـ SQL مناسب لنوع الداتا بيز اللي شغال عليها تحت في الخلفية".
بدل ما تقعد تكتب كويري SQL طويلة وتخاف من ثغرات الـ (SQL Injection) لو نسيت تعمل فلترة للداتا، الـ (ORM) بيهتم بالموضوع ده وبيفلتر المدخلات لوحده.
المشكلة العملية اللي بيحلها هي الـ (Database Portability) وسرعة التطوير؛ لو قررت فجأة تنقل من (SQLite) لـ (PostgreSQL) في بيئة الإنتاج، مش هتغير ولا سطر كود Python، الـ (ORM) هو اللي هيغير طريقة الترجمة لوحده للداتا بيز الجديدة.

خلينا نقارن بين كتابة الكويري بالـ SQL وكتابتها بـ Django ORM.

```python
# Comparing raw SQL query execution with Django ORM syntax

# --- Raw SQL equivalent (Manual connection and binding) ---
# SELECT * FROM shop_product WHERE is_active = True AND price > 100.00;

# --- Django ORM (Safe, clean and mapped to Python objects) ---
from decimal import Decimal
from .models import Product

# Django ORM generates the exact SQL above safely under the hood
active_expensive_products = Product.objects.filter(
    is_active=True, 
    price__gt=Decimal('100.00')
)
```

#### مثال 1: تعديل البيانات بالـ ORM
تعديل ريكورد في الداتا بيز بيبقى بسيط زي تعديل متغير عادي في أوبجكت Python ثم استدعاء ميثود `save()`.

```python
# Modifying a product status using Django ORM
def mark_product_out_of_stock(product_id: int) -> None:
    # 1. Fetch object from DB
    product = Product.objects.get(id=product_id)
    # 2. Change Python object property
    product.is_active = False
    # 3. Save triggers UPDATE query automatically
    product.save()
```

#### مثال 2: فخ الـ (Raw SQL Injection)
لو اضطرينا نكتب SQL يدوي، فيه غلطة شائعة جداً ممكن تدمر أمان الموقع لو دمجنا المدخلات مباشرة في النص (String concatenation).

```python
# BAD: Vulnerable to SQL Injection
def search_product_unsafe(user_input: str) -> list[Product]:
    query = f"SELECT * FROM shop_product WHERE name = '{user_input}'"
    return list(Product.objects.raw(query))

# GOOD: Safe parameterized raw query
def search_product_safe(user_input: str) -> list[Product]:
    query = "SELECT * FROM shop_product WHERE name = %s"
    # Django escapes user_input automatically to prevent SQL Injection
    return list(Product.objects.raw(query, [user_input]))
```

#### مثال 3: إنشاء ريكورد جديد وحفظه
الكود ده بيوضح إزاي الـ (ORM) بياخد أوبجكت بايثون جديد وبيكتبه في الداتا بيز بـ `create()`.

```python
# Creating and saving a new record in a single transaction
new_product = Product.objects.create(
    name="Wireless Headset",
    price=Decimal('59.99'),
    is_active=True
)
# new_product now contains the primary key (id) populated automatically by the database
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is Django ORM and what are its advantages over raw SQL?
* **الإجابة المثالية:** الـ (Django ORM) هو نظام وسيط بيسمح لينا بالتعامل مع قواعد البيانات عن طريق كتابة كود بايثون و (Objects) بدلاً من كتابة استعلامات (SQL) يدوية. أهم مميزاته هي: أولاً، الحماية التلقائية من ثغرات الـ (SQL Injection) عن طريق الـ (Parameterization) التلقائي. ثانياً، استقلالية قاعدة البيانات (Database Abstraction)؛ بحيث تقدر تغير نوع الداتا بيز من غير ما تعدل كود البزنس لوجيك. ثالثاً، سرعة التطوير والتكامل التام مع باقي أدوات جانجو زي الـ (Forms) والـ (Admin Panel).

---

## Q7 — إيه الفرق بين الـ (makemigrations) والـ (migrate)؟ وإيه اللي بيحصل في الداتا بيز بالظبط؟

### أصل الحكاية:
زي ما شفنا في Q6، الـ (ORM) بيخلينا نكتب الـ (Models) بلغة البايثون. طب إزاي الداتا بيز الفعلية (زي PostgreSQL) هتعرف إننا ضفنا جدول جديد أو مسحنا حقل معين؟ الداتا بيز مش بتفهم بايثون، بتفهم أوامر تعديل الجداول (DDL - Data Definition Language). هنا بييجي دور الـ (Migrations) كجسر بين كود البايثون والـ Schema بتاعة الداتا بيز.
العملية دي بتتقسم لخطوتين مهمين جداً:
الخطوة الأولى: `makemigrations`. جانجو بيبص على ملف الـ `models.py` ويقارن حالته الحالية بآخر حالة مسجلة في ملفات الـ (migrations) السابقة. لو لقى تغييرات، بيكريت ملف بايثون جديد في فولدر الـ `migrations` جواه وصف دقيق للتعديل ده (زي: "احنا هنضيف عمود جديد اسمه age في جدول user"). ده بيكون زي خطة التصميم الهندسي للمبنى.
الخطوة الثانية: `migrate`. هنا جانجو بياخد ملف الخطة ده، ويشوف أنهي خطط لسه منفذهاش على الداتا بيز الفعلية، ويترجم الخطط دي لأوامر SQL حقيقية زي `ALTER TABLE` أو `CREATE TABLE` وينفذها فوراً على الداتا بيز.
المشكلة العملية اللي بيحلها النظام ده هي تتبع التغيرات في الداتا بيز ومزامنتها بين كل المطورين في الفريق؛ مفيش مطور بيحتاج يعدل الجداول يدوياً على جهازه، الكل بيكتب نفس الأمر والـ migrations بتظبط السيستم لوحدها.

خلينا نشوف شكل الكود لما بنضيف موديل جديد، وإزاي ده بيتحول لملف خطة (Migration).

```python
# shop/models.py
from django.db import models

class Category(models.Model):
    title = models.CharField(max_length=100)
    # After saving this, we run: python manage.py makemigrations
```

لما بنشغل أمر الـ `makemigrations` بيطلع ملف بايثون جديد جوة فولدر الـ `migrations/0001_initial.py` وبيبقى شكله كدة تقريباً:

```python
# shop/migrations/0001_initial.py
# Django auto-generated migration file

from django.db import migrations, models

class Migration(migrations.Migration):
    initial = True
    dependencies = []

    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=100)),
            ],
        ),
    ]
```

#### مثال 1: فحص الـ SQL الفعلي قبل التطبيق
علشان نكون متأكدين جانجو هيعمل إيه بالظبط في الداتا بيز، بنقدر نخليه يورينا أمر الـ SQL الحقيقي اللي هيتنفذ بس من غير ما ينفذه فعلاً، وده مفيد جداً في الإنتاج للتأكد من السلامة.

```python
# Run in terminal to see generated SQL for migration 0001:
# python manage.py sqlmigrate shop 0001
```

الناتج اللي بيعرضه الأمر ده على الشاشة بيكون كود SQL حقيقي:
```sql
-- Generated SQL for PostgreSQL
CREATE TABLE "shop_category" (
    "id" bigserial NOT NULL PRIMARY KEY, 
    "title" varchar(100) NOT NULL
);
```

#### مثال 2: معرفة حالة الـ Migrations
لو عايزين نعرف أنهي خطط اتنفذت وأنهي لسه مستني، بنستخدم الـ `showmigrations` اللي بيعرض حالة كل ملف.

```python
# Run in terminal:
# python manage.py showmigrations
# Output shows [X] for applied migrations, and [ ] for unapplied ones
```

#### مثال 3: التراجع عن خطوة migration
لو عملنا خطوة غلط وعايزين نرجع خطوة لورا في الداتا بيز، بنقدر نعمل `migrate` لاسم الملف اللي قبله عشان جانجو يعمل تراجع (Rollback).

```python
# Run in terminal to rollback to the initial state:
# python manage.py migrate shop zero
# This runs the DROP TABLE statements generated by Django under the hood
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is the difference between makemigrations and migrate in Django?
* **الإجابة المثالية:** أمر `makemigrations` هو المسؤول عن فحص التغيرات في الـ `models.py` وكتابة ملفات بايثون جديدة (تسمى migrations) بتوصف التعديل ده كـ (Draft) أو رسم هندسي. أما أمر `migrate` فهو المسؤول عن مقارنة ملفات الـ migrations دي بجدول اسمه `django_migrations` في الداتا بيز عشان يعرف إيه اللي لسه متنفذش، وبعدين يترجم الخطط دي لأوامر SQL حقيقية وينفذها علشان يغير هيكل الداتا بيز الفعلي.

---

## Q8 — إيه الفرق الجوهري بين (null=True) و (blank=True) في الـ (Models)؟

### أصل الحكاية:
ده أشهر سؤال بيوقع المبتدئين في الإنترفيوهات لأن المفهومين شبه بعض ظاهرياً بس بيشتغلوا في مستويات مختلفة خالص في الأبلكيشن.
الـ (ORM) بيقسم التعامل مع القيم الفاضية لحتتين:
- `null=True`: دي خاصة بـ "قاعدة البيانات" (Database level). معناها إن العمود ده في الداتا بيز مسموح إنه يتخزن فيه قيمة فاضية وهي (NULL). لو القيمة مش مبعوتة خالص، الـ SQL هيرضى يخزنها كـ `NULL`.
- `blank=True`: دي خاصة بـ "الـ Validation والتطبيق" (Application level). معناها لما اليوزر يملى فورم في الـ (Admin Panel) أو نبعت داتا للـ API، مسموح للمتصفح أو اليوزر إنه يسيب الخانة دي فاضية وميطلعش خطأ (Field is required).
التشبيه هنا: `blank=True` هي حارس البوابة الخارجي اللي بيفتشك؛ بيسمحلك تدخل من غير ما تكتب حاجة في الخانة دي. أما `null=True` فهي الخزنة جوة الداتا بيز؛ بتسمح للدرج إنه يفضل فاضي ومكتوب عليه (NULL).
المشكلة الكبيرة والخطأ الشائع بيحصل مع حقول النصوص زي الـ (CharField) أو الـ (TextField). لو عملت الاثنين مع بعض في نفس الحقل، الداتا بيز هيبقى فيها طريقتين لتمثيل النص الفاضي: يا إما نص فاضي حقيقي `""` يا إما `NULL`. جانجو بينصح بقوة إننا نستخدم `blank=True` بس مع النصوص، وجانجو لوحده هيخزن النص الفاضي كـ `""` ويوحد طريقة تمثيل الداتا الفاضية.

خلينا نقارن في جدول سريع بين تأثير كل خيار في الأبلكيشن.

| الخيار | مستوى التأثير | القيمة المخزنة في الداتا بيز | الاستخدام الشائع |
| :--- | :--- | :--- | :--- |
| `null=True` | Database level | `NULL` | الأرقام، التواريخ، والعلاقات (ForeignKey) |
| `blank=True` | Form/API Validation | `""` أو القيمة الافتراضية | الحقول النصية الاختيارية |

#### مثال 1: الطريقة الصحيحة لحقول النصوص
هنا بنشوف إزاي بنخلي حقل الاسم التاني اختياري من غير ما نخليه `null=True`.

```python
# shop/models.py
from django.db import models

class UserProfile(models.Model):
    # For text fields, use blank=True ONLY. Django stores empty value as ""
    middle_name = models.CharField(max_length=50, blank=True)
```

#### مثال 2: الاستخدام الصحيح مع التواريخ والأرقام
التواريخ والأرقام في الداتا بيز مش بينفع تتخزن كـ نصوص فاضية `""`. لو الحقل ده اختياري، لازم نستخدم `null=True` و `blank=True` مع بعض علشان الداتا بيز تقبل الـ `NULL` والـ Validation يقبل الفراغ.

```python
# Dates and numbers cannot hold empty strings, so they MUST use null=True
birth_date = models.DateField(null=True, blank=True)
discount_rate = models.IntegerField(null=True, blank=True)
```

#### مثال 3: فخ الـ (Null) مع العلاقات
لما نعمل علاقة زي الـ (ForeignKey) ونعوز نخليها اختيارية (يعني لو الموظف مش تابع لقسم معين)، لازم نستخدم الاثنين مع بعض. لو نسينا `null=True` وحطينا `blank=True` بس، الداتا بيز هترفض تخزن الريكورد وهيطلع خطأ (IntegrityError).

```python
class Employee(models.Model):
    # ForeignKeys must have null=True if the relationship is optional
    department = models.ForeignKey(
        'Department', 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True
    )
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is the difference between null=True and blank=True in Django models?
* **الإجابة المثالية:** الفرق هو إن `null=True` متعلق بقاعدة البيانات (Database Validation)، وبيحدد لو كان العمود في الجدول ينفع يقبل قيمة `NULL` ولا لأ. أما `blank=True` فمتعلق بالـ Validation بتاع الفريم وورك (Form validation)، وبيحدد لو كان الحقل اختياري وممكن نسيبه فاضي لما نملى الفورم أو نبعت داتا للـ API. مع الحقول النصية زي الـ (CharField)، بنستخدم `blank=True` بس لتجنب وجود قيمتين فاضيتين في الداتا بيز (`NULL` و `""`)، ومع الحقول غير النصية زي الأرقام والتواريخ والعلاقات، بنستخدم الاثنين مع بعض.

---

## Q9 — إيه هي العلاقات في الداتا بيز وإزاي بنعملها في جانجو؟ (OneToOne, ForeignKey, ManyToMany)

### أصل الحكاية:
الداتا بيز مبنية على ربط الجداول ببعضها علشان نمنع تكرار البيانات وننظمها. في جانجو، بنمثل العلاقات دي بتلات أنواع أساسية من الحقول في الـ (Models):
1. `OneToOneField` (واحد لواحد): كل سطر في الجدول الأول مرتبط بسطر واحد بس في الجدول التاني. التشبيه: اليوزر والبروفايل بتاعه؛ كل يوزر ليه بروفايل واحد، والبروفايل ده خاص بيوزر واحد بس.
2. `ForeignKey` (واحد لكثير - Many-to-One): سطر واحد في جدول مرتبط بـ سطور كتير في جدول تاني. التشبيه: الكاتب والكتب؛ كاتب واحد ممكن يكتب كتب كتير، بس الكتاب الواحد ليه كاتب واحد بس.
3. `ManyToManyField` (كثير لكثير): كذا سطر في جدول مرتبط بـ كذا سطر في جدول تاني. التشبيه: الطالب والكورسات؛ الطالب يقدر يسجل في كورس أو أكتر، والكورس بيبقى فيه طالب أو أكتر.
المشكلة العملية اللي بيحلها ضبط العلاقات دي هي الحفاظ على سلامة البيانات (Referential Integrity)؛ يعني لو مسحت كاتب، إيه اللي يحصل للكتب بتاعته؟ جانجو بيخلينا نحدد ده بـ `on_delete` زي `CASCADE` (امسح الكتب مع الكاتب) أو `SET_NULL` (سيب الكتب وامسح اسم الكاتب بس).

خلينا نكتب الموديلز اللي بتمثل العلاقات دي عملياً مع استخدام الـ `related_name` لتسهيل البحث العكسي.

```python
# shop/models.py
from django.db import models
from django.contrib.auth.models import User

# 1. OneToOne Relationship
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    bio = models.TextField(blank=True)


# 2. ForeignKey (Many-to-One)
class Product(models.Model):
    name = models.CharField(max_length=200)
    # One merchant can have many products
    merchant = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')


# 3. ManyToMany Relationship
class Tag(models.Model):
    name = models.CharField(max_length=50)
    # A product can have many tags, and a tag can belong to many products
    products = models.ManyToManyField(Product, related_name='tags')
```

#### مثال 1: البحث العكسي (Reverse Lookup)
لما نستخدم الـ `related_name` بنقدر نوصل للداتا المرتبطة بسهولة جداً من الطرف التاني للعلاقة. الكود ده بيوريك إزاي تجيب كل المنتجات الخاصة بيوزر معين بدون كتابة فلترة معقدة.

```python
# Fetch all products created by a specific user using the related_name
def get_user_products(user: User) -> list[Product]:
    # Django uses 'products' related_name to perform reverse query automatically
    user_products = user.products.all()
    return list(user_products)
```

#### مثال 2: فخ الـ (on_delete) المفقود
في الإصدارات الجديدة من جانجو، إجباري تحدد الـ `on_delete` مع الـ `ForeignKey` والـ `OneToOneField`. لو نسيت تحدده، جانجو مش هيقبل يشتغل وهيطلع خطأ وقت الـ compilation.

```python
# BAD: Will throw a TypeError during Django startup
# category = models.ForeignKey('Category')

# GOOD: Must specify on_delete behavior explicitly
# category = models.ForeignKey('Category', on_delete=models.PROTECT)
```

#### مثال 3: وسيط علاقة ManyToMany مخصص (through)
ساعات بنحتاج نخزن معلومات إضافية عن العلاقة بين الجدولين (مثلاً: تاريخ انضمام الطالب للكورس). جانجو بيسمح لنا نعمل جدول وسيط مخصص باستخدام خيار `through`.

```python
class Student(models.Model):
    name = models.CharField(max_length=100)
    courses = models.ManyToManyField('Course', through='Enrollment')

class Course(models.Model):
    title = models.CharField(max_length=100)

# The custom intermediary table
class Enrollment(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    date_enrolled = models.DateField(auto_now_add=True)
    grade = models.CharField(max_length=2, blank=True)
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** Explain DB relationships in Django and what 'related_name' is used for.
* **الإجابة المثالية:** العلاقات في جانجو بتتعمل بتلات طرق: `OneToOneField` لربط ريكورد بواحد تاني مماثل، و `ForeignKey` لعمل علاقة (One-to-Many)، و `ManyToManyField` لعلاقة (Many-to-Many). الـ `related_name` هو خيار بنستخدمه لتحديد الاسم اللي هنعمل بيه استعلام عكسي (Reverse Lookup) من الجدول التاني. لو معرفناهوش، جانجو بيكريت اسم افتراضي بيكون عبارة عن اسم الموديل متبوعاً بـ `_set` (زي `product_set`)، واستخدامه بيخلي الكود أنظف وأسهل في القراءة.

---

## Q10 — إيه هو مبدأ الـ (Lazy Evaluation) في الـ (QuerySets)؟ وليه هو سلاح ذو حدين؟

### أصل الحكاية:
لما بنكتب في كود جانجو سطر زي `active_users = User.objects.filter(is_active=True)`، للوهلة الأولى بنفتكر إن جانجو راح للداتا بيز وجاب اليوزرات حالا والسطر ده خد وقت في التنفيذ. الحقيقة هي إن السطر ده سريع جداً لأنه ملمسش الداتا بيز أصلاً!
ده بنسميه الـ (Lazy Evaluation) أو "التقييم الكسول".
الـ (QuerySet) بيفكر كدة: "أنا مش هعمل مشوار للداتا بيز وأتحرك من مكاني غير لما المطور يجبرني ويحتاج الداتا دي فعلياً علشان يعرضها أو يستخدمها".
طب إمتى جانجو بيجبر الـ (QuerySet) إنه يروح للداتا بيز؟
1. لما تلف عليها بـ (Loop) زي `for user in active_users`.
2. لما تحولها لـ (List) زي `list(active_users)`.
3. لما تعمل عليها (Slicing) مع تحديد خطوة معينة أو تحاول تطبعها.
4. لما تعمل عليها اختبار شرطي زي `if active_users`.
الميزة الكبيرة (سلاح ذو حدين - الجانب الإيجابي): توفير الاستعلامات؛ تقدر تقعد تفلتر وتعدل في الـ (QuerySet) كذا مرة في كود البايثون، وفي الآخر جانجو هيجمع الفلاتر دي كلها ويبعت استعلام SQL واحد للداتا بيز لما تحتاج الداتا.
العيب والخطورة (الجانب السلبي): لو مش فاهم المفهوم ده، ممكن تكرر الاستعلامات من غير ما تحس وتعمل ضغط رهيب على الداتا بيز (Database hits) لأنك بتعمل (Evaluate) للـ QuerySet كذا مرة ورا بعض بشكل غير مباشر.

خلينا نشوف الكود ده ونشوف إزاي الفلترة المتكررة مش بتعمل غير استعلام واحد بس في الآخر.

```python
# shop/views.py
from django.db.models import QuerySet
from .models import Product

def lazy_demo() -> int:
    # 1. No database query is executed here yet
    q1: QuerySet = Product.objects.filter(is_active=True)
    
    # 2. Still no database query executed
    q2: QuerySet = q1.filter(price__gt=50)
    
    # 3. Still no database query executed
    q3: QuerySet = q2.exclude(name__icontains="damaged")
    
    # 4. Now, the QuerySet is evaluated and ONE SQL query hits the database
    product_list = list(q3) 
    
    return len(product_list)
```

#### مثال 1: فخ التقييم المتكرر (Multiple Evaluations)
الكود ده بيوضح خطأ شائع جداً بيخلي جانجو يروح للداتا بيز مرتين ورا بعض بدل مرة واحدة بسبب استخدام الـ QuerySet مرتين بشكل منفصل.

```python
# BAD: Hits the database twice
def print_products_bad() -> None:
    products = Product.objects.all()
    
    if products:  # DB hit 1: Checks if any records exist
        for product in products:  # DB hit 2: Fetches the data to iterate
            print(product.name)

# GOOD: Hits the database once
def print_products_good() -> None:
    products = Product.objects.all()
    
    # Convert to list to evaluate once and cache the result
    product_list = list(products)  # DB hit 1: Fetches all data
    
    if product_list:  # Uses cached list, no DB hit
        for product in product_list:  # Uses cached list, no DB hit
            print(product.name)
```

#### مثال 2: استخدام الـ `exists()` والـ `count()` بذكاء
ساعات بنحتاج نعرف بس لو كان فيه داتا موجودة أو عددها كام من غير ما نجيب الداتا كلها للميموري. جانجو بيوفر ميثودز مخصصة بتعمل كويري سريعة جداً بترجع رقم أو قيمة منطقية بس.

```python
# GOOD: exists() executes a fast 'LIMIT 1' query instead of loading all objects
def has_active_products() -> bool:
    return Product.objects.filter(is_active=True).exists()

# GOOD: count() executes 'SELECT COUNT(*)' directly in SQL
def get_product_count() -> int:
    return Product.objects.filter(is_active=True).count()
```

#### مثال 3: فخ التكرار جوة اللوب (Unintentional Evaluation)
لما بنطلب داتا مرتبطة جوة لوب، ده بيجبر الـ ORM يعمل استعلام جديد مع كل لفة، وده هنشرحه بالتفصيل في السؤال الجاي كأكبر مشكلة أداء.

```python
# Lazy evaluation trap in loops (Demonstrating N+1 preview)
def print_merchant_names_bad() -> None:
    # QuerySet of products is lazy
    products = Product.objects.all()
    
    for product in products:
        # Every iteration triggers a new query to fetch the merchant object
        print(product.merchant.username)
```

### الفايدة الانترفيوية:
* **صيغة السؤال في الإنترفيو:** What is Lazy Evaluation in Django QuerySets?
* **الإجابة المثالية:** الـ (Lazy Evaluation) في جانجو يعني إن الـ (QuerySet) مش بيتنفذ في قاعدة البيانات فوراً وقت إنشائه. جانجو بيقعد يجمع شروط الفلترة والترتيب ويبني كود الـ SQL في الميموري، ومش بيبعت الاستعلام الفعلي للداتا بيز غير لما نطلب الداتا دي بشكل صريح (Evaluation Trigger) زي إننا نلف عليها بـ (Loop) أو نحولها لـ (List) أو نعمل عليها عمليات فحص. الميزة إنها بتوفر استعلامات غير ضرورية وتسمح بدمج الفلاتر، وعيبها إن المطور لو مش فاهمها ممكن يعمل استعلامات متكررة من غير ما يقصد ويسبب مشاكل أداء كبيرة للسيستم.

---

## الجزء الخامس: مواضيع متقدمة في البنية والأداء (Architecture & Performance)

### Q21: إيه هو الـ Middleware في جانجو وإزاي بيشتغل؟ (Django Middleware Architecture)
**أصل الحكاية:**
الـ Middleware هو عبارة عن طبقات أو بوابات بيعدي عليها الـ Request قبل ما يوصل للـ View، وبيعدي عليها الـ Response وهو راجع من الـ View للمستخدم. بنستخدمه عشان ننفذ منطق عام يتطبق على كل الـ Requests زي الـ Authentication، التعامل مع الـ CORS، تسجيل الـ Logs، أو ضغط الـ Data.

**مثال عملي بالكود:**
```python
from typing import Callable, Any
from django.http import HttpRequest, HttpResponse
import time
import logging

logger = logging.getLogger(__name__)

class RequestTimeLoggingMiddleware:
    """
    ميدلوير بيحسب الوقت اللي خده الريكويست عشان يتنفذ
    """
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response
        # الـ setup بيحصل مرة واحدة بس أول ما السيرفر يشتغل

    def __call__(self, request: HttpRequest) -> HttpResponse:
        # الكود هنا بيتنفذ قبل ما الريكويست يوصل للـ View (أو للميدلوير اللي بعده)
        start_time = time.time()

        # بنبعت الريكويست يكمل رحلته
        response = self.get_response(request)

        # الكود هنا بيتنفذ بعد ما الـ View يخلص ويرجع الـ Response
        duration = time.time() - start_time
        logger.info(f"Request to {request.path} took {duration:.4f} seconds")

        return response
```

**الفايدة الانترفيوية:**
* **صيغة السؤال في الإنترفيو:** Explain Django Middleware and how you create a custom one.
* **الإجابة المثالية:** الـ Middleware في جانجو بيشتغل كـ (Hook) في دورة حياة الـ Request/Response. بنرتب الميدلويرز في الـ `settings.py` كأنهم طبقات بصل (Onion architecture). كل ميدلوير بياخد الـ Request، ممكن يعدل فيه، وبعدين يمرره للي بعده من خلال `get_response`، ولما الـ View يخلص، الـ Response بيرجع يمر على كل الميدلويرز بالعكس. بنعمل Custom Middleware عن طريق كلاس بياخد `get_response` في الـ `__init__`، وبننفذ اللوجيك بتاعنا جوة دالة `__call__`، سواء قبل الـ `get_response` (للريكويست) أو بعده (للريسبونس).

---

### Q22: إزاي بتدير عملية الـ Authentication والـ Permissions في DRF؟ والفرق بين Token و JWT؟
**أصل الحكاية:**
الـ Authentication هو "أنت مين؟" والـ Permissions هي "مسموح لك تعمل إيه؟". في DRF، الـ Authentication بيبني الـ `request.user`، والـ Permissions بتتحقق إذا كان الـ `user` ده يقدر ينفذ الأكشن ده ولا لأ.
أشهر طرق الـ Auth للـ APIs هي الـ Token Authentication (التوكن بيتخزن في الداتا بيز وكل ريكويست بيعمل استعلام عشان يتأكد منه) والـ JWT (JSON Web Token) (التوكن بيحتوي على البيانات نفسها ومش محتاج استعلام من الداتا بيز، مجرد بنفك التشفير ونتأكد من الـ Signature).

**مثال عملي بالكود:**
```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, BasePermission
from rest_framework.request import Request
from rest_framework_simplejwt.authentication import JWTAuthentication

class IsMerchantUser(BasePermission):
    """
    Custom Permission عشان نتأكد إن اليوزر نوعه تاجر
    """
    def has_permission(self, request: Request, view: APIView) -> bool:
        # الـ Authentication بيضمن إن اليوزر موجود، الـ Permission بيتأكد من الصلاحية
        return bool(request.user and request.user.is_authenticated and hasattr(request.user, 'merchant_profile'))

    def has_object_permission(self, request: Request, view: APIView, obj: Any) -> bool:
        # بنتأكد إن التاجر ده هو صاحب الأوبجكت
        return obj.owner == request.user

class SecureDataView(APIView):
    # بنحدد طريقة التأكد من الهوية (JWT)
    authentication_classes = [JWTAuthentication]
    # بنحدد الصلاحيات المطلوبة
    permission_classes = [IsAuthenticated, IsMerchantUser]

    def get(self, request: Request) -> Response:
        return Response({"message": "Secure data accessed successfully!"})
```

**الفايدة الانترفيوية:**
* **صيغة السؤال في الإنترفيو:** How does DRF handle Auth vs Permissions? Why choose JWT over standard Tokens?
* **الإجابة المثالية:** DRF بيفصل بين تحديد الهوية (Authentication) اللي بيعبي الـ `request.user`، وبين الصلاحيات (Permissions) اللي بتقرر الموافقة أو الرفض. بنستخدم كلاسات مخصصة زي `BasePermission` عشان نتحكم في الـ `has_permission` على مستوى الـ Endpoint ككل، و `has_object_permission` على مستوى الريكورد الواحد. بالنسبة للفرق، الـ Standard Token بيتخزن في الداتا بيز وبيعمل (I/O overhead) مع كل ريكويست. أما الـ JWT فهو (Stateless)، بيشيل الداتا (Payload) زي الـ user_id ومُوقّع بـ (Secret Key). الـ JWT أفضل في الـ Microservices والأنظمة اللي عليها ضغط لأننا بنتحقق منه بـ (CPU calculation) من غير ما نكلم الداتا بيز.

---

### Q23: إيه أهمية الـ Pagination وإيه أنواعها في DRF؟ (Pagination & Filtering)
**أصل الحكاية:**
لما يكون عندنا آلاف الريكوردز، مستحيل نرجعهم كلهم في ريسبونس واحد لأن ده هيوقع الميموري بتاعة السيرفر وهيخلي الـ API بطيء جداً. الـ Pagination بيقسم الداتا لصفحات. والـ Filtering بيخلينا نرجع الداتا اللي بتطابق شروط معينة بس عشان نقلل حجم البيانات.

**مثال عملي بالكود:**
```python
from rest_framework.pagination import PageNumberPagination, CursorPagination
from rest_framework.generics import ListAPIView
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters
from myapp.models import Product
from myapp.serializers import ProductSerializer

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100

class ProductListView(ListAPIView):
    queryset = Product.objects.filter(is_active=True).order_by('-created_at')
    serializer_class = ProductSerializer
    
    # تحديد نوع التقسيم
    pagination_class = StandardResultsSetPagination
    
    # تفعيل الفلترة والبحث والترتيب
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    
    # الحقول المسموح بالفلترة المباشرة بيها
    filterset_fields = ['category', 'in_stock']
    # الحقول المسموح بالبحث النصي فيها
    search_fields = ['name', 'description']
    # الحقول المسموح الترتيب بناءً عليها
    ordering_fields = ['price', 'created_at']
```

**الفايدة الانترفيوية:**
* **صيغة السؤال في الإنترفيو:** What pagination styles does DRF provide and when to use Cursor Pagination?
* **الإجابة المثالية:** DRF بيوفر كذا نوع: `PageNumberPagination` (التقليدي، بيستخدم LIMIT/OFFSET وبيجيب رقم الصفحة بس مشكلته إنه بطيء جداً مع الداتا الكبيرة عشان الـ DB بتسكان كل الريكوردز اللي قبل الـ OFFSET)، و `LimitOffsetPagination`، و `CursorPagination`. الـ Cursor Pagination هو الأفضل من ناحية الأداء مع الجداول الضخمة (Big Data) لأنه بيعتمد على قيمة مؤشر (مثلاً الـ ID أو timestamp) وبيعمل استعلام بـ `WHERE id > cursor`، وده بيستغل الـ Indexing في الداتا بيز ومبيعملش Table Scan كامل، بس عيبه إننا منقدرش ننط لصفحة معينة في النص، بنتحرك قدام ورا بس.

---

### Q24: إزاي بنحسن أداء الـ API باستخدام الـ Caching في جانجو؟ (Redis/Memcached)
**أصل الحكاية:**
لو عندنا Endpoint بيرجع بيانات مش بتتغير كتير وبياخد وقت طويل عشان يتحسب أو يجمع داتا من كذا مكان، من الغباء إننا نخليه ينفذ نفس الشغل لكل مستخدم. الحل إننا نحفظ النتيجة النهائية (JSON Response) في ميموري سريعة جداً زي Redis أو Memcached لفترة معينة، وأي ريكويست ييجي نرجعله النتيجة المحفوظة دي مباشرة من غير ما نلمس الداتا بيز.

**مثال عملي بالكود:**
```python
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.request import Request
from django.core.cache import cache

class ExpensiveReportView(APIView):
    
    # كاش للفيو كله لمدة 15 دقيقة
    @method_decorator(cache_page(60 * 15))
    def get(self, request: Request) -> Response:
        # الكود ده هيتنفذ مرة واحدة كل 15 دقيقة
        report_data = self.calculate_heavy_report()
        return Response(report_data)
        
    def calculate_heavy_report(self) -> dict:
        # تجميع داتا معقدة جداً
        return {"total_sales": 1000000, "top_products": [...]}

class CustomCacheExampleView(APIView):
    def get(self, request: Request) -> Response:
        cache_key = f"user_stats_{request.user.id}"
        
        # بنحاول نجيب الداتا من الكاش الأول
        data = cache.get(cache_key)
        
        if not data:
            # لو مش موجودة، بنحسبها
            data = {"stats": "some expensive calculation"}
            # بنحفظها في الكاش لمدة ساعة
            cache.set(cache_key, data, timeout=3600)
            
        return Response(data)
```

**الفايدة الانترفيوية:**
* **صيغة السؤال في الإنترفيو:** How do you implement caching in Django and invalidate it when data changes?
* **الإجابة المثالية:** بنستخدم الـ Caching على مستويات مختلفة. ممكن نكش الـ View بالكامل باستخدام `@cache_page` لو الداتا عامة ومش مرتبطة باليوزر. وممكن نكش أجزاء معينة (Low-level caching) باستخدام `cache.set` و `cache.get`. لو الداتا اتغيرت، لازم نعمل (Cache Invalidation) عن طريق مسح المفتاح `cache.delete` وقت ما يحصل الـ Update. Redis هو الخيار الأفضل لأنه بيدعم (Data structures) معقدة و(Persistence)، بعكس Memcached اللي بيخزن (Strings) بس في الميموري.

---

### Q25: إيه الفرق بين Django Test Case و Pytest؟ وإزاي بتكتب Tests للـ APIs؟
**أصل الحكاية:**
كتابة الـ Tests مش رفاهية، دي الحاجة الوحيدة اللي بتضمن إن كودك لما يتغير ميكسرش أجزاء تانية في السيستم. جانجو بييجي بـ `TestCase` مبني على `unittest` بتاع بايثون، بس في الصناعة دلوقتي الأغلب بيستخدم `pytest` لأنه بيكتب كود أقل (Less boilerplate)، بيوفر (Fixtures) ممتازة، ونتيجته أوضح بكتير.

**مثال عملي بالكود:**
```python
import pytest
from rest_framework.test import APIClient
from django.urls import reverse
from myapp.models import Product

# بنستخدم Fixture عشان نجهز الداتا قبل التست
@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def sample_product(db) -> Product:
    # الـ db fixture بتسمح للـ pytest يكتب في الداتا بيز بتاعة التست
    return Product.objects.create(name="Test Product", price=100.0)

# بنحدد إن التست ده بيتعامل مع الداتا بيز
@pytest.mark.django_db
def test_get_product_list(api_client: APIClient, sample_product: Product) -> None:
    # Arrange
    url = reverse('product-list')
    
    # Act
    response = api_client.get(url)
    
    # Assert
    assert response.status_code == 200
    assert len(response.data['results']) == 1
    assert response.data['results'][0]['name'] == "Test Product"

@pytest.mark.django_db
def test_create_product_unauthorized(api_client: APIClient) -> None:
    url = reverse('product-list')
    data = {"name": "New Product", "price": 50.0}
    
    response = api_client.post(url, data)
    
    # لازم يترفض لأننا معملناش Authentication
    assert response.status_code == 401
```

**الفايدة الانترفيوية:**
* **صيغة السؤال في الإنترفيو:** How do you test Django APIs and why prefer Pytest over standard unittest?
* **الإجابة المثالية:** بكتب الـ Tests للـ APIs باستخدام `APIClient` من DRF عشان أعمل (Integration tests) تتأكد من الـ Request، الـ Routing، الـ Serializer، والـ Response. بفضل استخدام `pytest` و `pytest-django` لكذا سبب: أولاً، مفيش داعي أعمل كلاسات بتورث من `TestCase` وبكتب دوال عادية. ثانياً، بستخدم عبارة `assert` العادية بدل دوال زي `assertEqual` الطويلة. ثالثاً، نظام الـ (Fixtures) في `pytest` بيخلي إعادة استخدام التجهيزات (Setup logic) زي إنشاء يوزر وهمي أسهل بكتير وبقدر أشاركه بين ملفات التست بسهولة.

