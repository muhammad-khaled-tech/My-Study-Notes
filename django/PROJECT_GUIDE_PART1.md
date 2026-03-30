# 🎓 ITI School Management System — Complete Learning Guide (Part 1)

> **Goal**: Understand every single line of this Django + Django REST Framework project so you can confidently discuss it with your instructor.

---

## 📁 Project Structure Overview

```
Students_lab/                  ← Root project folder
├── manage.py                  ← Django's command-line tool (run server, migrations, etc.)
├── db.sqlite3                 ← The actual database file (SQLite)
├── media/                     ← Where uploaded student images are saved
├── myenv/                     ← Your Python virtual environment (ignore this)
│
├── school_system/             ← PROJECT CONFIG package (created by django-admin startproject)
│   ├── __init__.py            ← Makes this folder a Python package
│   ├── settings.py            ← All project settings (database, apps, middleware, etc.)
│   ├── urls.py                ← ROOT URL router — the first place Django checks URLs
│   ├── wsgi.py                ← Entry point for production servers (ignore for now)
│   └── asgi.py                ← Entry point for async servers (ignore for now)
│
└── core/                      ← YOUR APP — where all your actual logic lives
    ├── __init__.py
    ├── apps.py                ← App configuration
    ├── admin.py               ← Register models to appear in Django Admin panel
    ├── models.py              ← Database tables defined as Python classes
    ├── forms.py               ← HTML form definitions (for template views)
    ├── serializers.py         ← DRF serializers (convert models ↔ JSON for API)
    ├── views.py               ← All view logic (template views + API views)
    ├── urls.py                ← App-level URL routing
    └── templates/core/        ← HTML templates
        ├── base.html
        ├── home.html
        ├── login.html
        ├── student_list.html
        ├── student_form.html
        ├── student_confirm_delete.html
        └── grade_form.html
```

> [!IMPORTANT]
> This project has **TWO interfaces**:
> 1. **Template Views** (HTML pages) — for browsers, uses Django forms
> 2. **REST API** (JSON endpoints) — for Postman/mobile apps, uses DRF serializers

---

## 1️⃣ `manage.py` — The Entry Point

```python
#!/usr/bin/env python
```
- **Line 1**: Shebang line — tells Linux "run this file with Python". Not needed on Windows, but good practice.

```python
"""Django's command-line utility for administrative tasks."""
import os
import sys
```
- **Line 2**: Docstring describing what this file does.
- **Lines 3-4**: Import `os` (to set environment variables) and `sys` (to access command-line arguments).

```python
def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'school_system.settings')
```
- **Line 9**: This tells Django: "When you start, go read `school_system/settings.py` for configuration."
- `setdefault` means: only set this if it's not already set.

```python
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)
```
- **Lines 10-18**: Try to import Django. If it fails, show a helpful error ("activate your virtualenv!").
- `execute_from_command_line(sys.argv)` — this takes whatever you typed (`python manage.py runserver`) and runs it.

```python
if __name__ == '__main__':
    main()
```
- **Lines 21-22**: Standard Python pattern — only run `main()` if this file is executed directly (not imported).

> [!TIP]
> You use this file like: `python manage.py runserver`, `python manage.py makemigrations`, `python manage.py migrate`, `python manage.py createsuperuser`

---

## 2️⃣ `school_system/settings.py` — Project Configuration

### The Imports

```python
from pathlib import Path
import os
```
- `Path` — modern Python way to handle file paths.
- `os` — needed for `os.path.join()` later.

### Base Directory

```python
BASE_DIR = Path(__file__).resolve().parent.parent
```
- `__file__` = the current file (`settings.py`)
- `.resolve()` = get the absolute path
- `.parent` = go up one folder (from `school_system/` to `Students_lab/`)
- `.parent` again = **now `BASE_DIR` points to the root `Students_lab/` folder**

> [!NOTE]
> We use `BASE_DIR` everywhere to build paths relative to the project root, so paths work on any computer.

### Security Settings

```python
SECRET_KEY = "django-insecure-^#d$bc2da14!&e3#e@nae*y_%6w4i@cp79j48x_+qe*(*b&$yv"
DEBUG = True
ALLOWED_HOSTS = []
```
- `SECRET_KEY` — Django uses this for encryption (sessions, CSRF tokens). In production, this must be truly secret.
- `DEBUG = True` — Shows detailed error pages. **NEVER** set to `True` in production.
- `ALLOWED_HOSTS = []` — Which domains can access this site. Empty = localhost only.

### Installed Apps

```python
INSTALLED_APPS = [
    "django.contrib.admin",          # Admin panel at /admin/
    "django.contrib.auth",           # User authentication system
    "django.contrib.contenttypes",   # Tracks all models in the project
    "django.contrib.sessions",       # Stores session data (login state)
    "django.contrib.messages",       # Flash messages ("Student saved!")
    "django.contrib.staticfiles",    # Serves CSS/JS files
    "rest_framework",                # ← DRF — adds API capabilities
    "rest_framework.authtoken",      # ← DRF Token Auth — creates Token model
    "core",                          # ← OUR APP — Django discovers our models/views
]
```

> [!IMPORTANT]
> **Why `rest_framework` and `rest_framework.authtoken`?**
> - `rest_framework` gives us `serializers`, `viewsets`, `APIView`, `Response`, etc.
> - `rest_framework.authtoken` creates a database table to store authentication tokens. Each user gets a unique token string like `"9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"` that they send in headers instead of username/password.

### REST Framework Configuration

```python
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.TokenAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}
```

**Authentication** = "WHO are you?" (proving identity)
- `TokenAuthentication` — Client sends header: `Authorization: Token <token_string>`
- `SessionAuthentication` — Uses browser cookies (for browsable API in browser)

**Permission** = "Are you ALLOWED to do this?"
- `IsAuthenticated` — Only logged-in users can access API endpoints (by default).

> [!TIP]
> Think of it like a building: **Authentication** = showing your ID card at the door. **Permission** = checking if your ID card gives you access to that specific room.

### Middleware

```python
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",       # HTTPS redirects, security headers
    "django.contrib.sessions.middleware.SessionMiddleware", # Enables req.session
    "django.middleware.common.CommonMiddleware",            # URL normalization
    "django.middleware.csrf.CsrfViewMiddleware",           # CSRF protection for forms
    "django.contrib.auth.middleware.AuthenticationMiddleware", # Attaches request.user
    "django.contrib.messages.middleware.MessageMiddleware",    # Flash messages
    "django.middleware.clickjacking.XFrameOptionsMiddleware", # Prevents iframe embedding
]
```

> [!NOTE]
> **Middleware** = a chain of "filters" that every request passes through. Each one does a small job. Think of it like airport security checkpoints — every passenger goes through each one in order.

### Templates Configuration

```python
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],            # Extra template directories (we use none)
        "APP_DIRS": True,      # ← Look for templates inside each app's templates/ folder
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",  # Makes 'request' available in templates
                "django.contrib.auth.context_processors.auth",  # Makes 'user' available in templates
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]
```
- `APP_DIRS: True` — This is why templates go in `core/templates/core/`. Django auto-discovers them.

### Database

```python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",  # Using SQLite (file-based database)
        "NAME": BASE_DIR / "db.sqlite3",          # Database file location
    }
}
```
- SQLite = a simple database stored in a single file (`db.sqlite3`). Good for development.

### Auth Redirects

```python
LOGIN_URL = "login"               # If not logged in, redirect here
LOGIN_REDIRECT_URL = "home"       # After login, go to home page
LOGOUT_REDIRECT_URL = "login"     # After logout, go to login page
```

### Media Files

```python
MEDIA_URL = "/media/"                              # URL prefix for uploaded files
MEDIA_ROOT = os.path.join(BASE_DIR, "media")       # Actual folder on disk
```
- When a student image is uploaded, it's saved in `media/students/filename.jpg`
- It's accessible via URL: `http://localhost:8000/media/students/filename.jpg`

---

## 3️⃣ `core/apps.py` — App Configuration

```python
from django.apps import AppConfig

class CoreConfig(AppConfig):
    name = 'core'
```
- Every Django app needs this class.
- `name = 'core'` — must match the folder name. Django uses this to find your app.

---

## 4️⃣ `core/models.py` — Database Tables

> [!IMPORTANT]
> **Models are the HEART of Django.** Each class = a database table. Each attribute = a column. Django automatically creates the SQL for you.

### Student Model

```python
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
```
- `models` — Django's ORM module. Every model field comes from here.
- `MinValueValidator, MaxValueValidator` — built-in validators to restrict values.

```python
class Student(models.Model):
```
- `class Student` — defines a Python class called Student.
- `models.Model` — **inherits from Django's base model**. This is what makes it a database table. Without this, it's just a regular Python class.

```python
    name = models.CharField(max_length=100)
```
- Creates a `VARCHAR(100)` column in the database.
- `CharField` = text field with a maximum length.

```python
    age = models.IntegerField(validators=[MinValueValidator(15), MaxValueValidator(25)])
```
- Creates an `INTEGER` column.
- `validators=[...]` — If you try to save a student with age < 15 or > 25, Django will reject it.
- These validators run during form validation and serializer validation, **not** at the database level.

```python
    email = models.EmailField(unique=True)
```
- `EmailField` = a `CharField` that also validates email format (must contain `@`).
- `unique=True` — No two students can have the same email. This IS enforced at the database level.

```python
    image = models.ImageField(upload_to="students/", null=True, blank=True)
```
- `ImageField` — stores an uploaded image file.
- `upload_to="students/"` — files are saved inside `media/students/` folder.
- `null=True` — the database allows NULL (no value).
- `blank=True` — Django forms allow leaving this field empty.

> [!TIP]
> **`null` vs `blank`**:
> - `null=True` → **Database level**: the column can be NULL
> - `blank=True` → **Form/validation level**: the field can be submitted empty
> - For text fields, usually use `blank=True` only. For non-text fields, use both.

```python
    def __str__(self):
        return self.name
```
- `__str__` — When Python tries to print this object (in admin panel, shell, etc.), it shows the student's name instead of `Student object (1)`.

```python
    def calculate_gpa(self):
        all_my_grades = Grade.objects.filter(student=self)
```
- `Grade.objects` — the **Manager**. Think of it as a "gateway" to the Grade database table.
- `.filter(student=self)` — SQL: `SELECT * FROM grade WHERE student_id = <this_student's_id>`
- Returns a **QuerySet** (a lazy list of Grade objects).

```python
        if not all_my_grades.exists():
            return 0.0
```
- `.exists()` — efficient check if any grades exist (doesn't load all data).
- If no grades, GPA is 0.0.

```python
        total_sum = 0
        for g in all_my_grades:
            total_sum += g.grade_value
        count = all_my_grades.count()
        average = total_sum / count
        return round(average, 2)
```
- Loop through all grades, sum them up, divide by count.
- `round(average, 2)` — round to 2 decimal places (e.g., 85.67).

### Subject Model

```python
class Subject(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name
```
- Simple model: just a subject name (e.g., "Math", "Science").

### Grade Model

```python
class Grade(models.Model):
    student = models.ForeignKey(
        Student, on_delete=models.CASCADE, related_name="grades"
    )
```
- `ForeignKey` — creates a **relationship**: each Grade belongs to ONE Student.
- **In the database**, this creates a `student_id` integer column that references the Student table.
- `on_delete=models.CASCADE` — if you delete a Student, **all their grades are automatically deleted too**.
- `related_name="grades"` — lets you do `student.grades.all()` to get all grades for a student (reverse relationship).

```python
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
```
- Each Grade is for ONE Subject. If the subject is deleted, all grades for it are deleted.

```python
    grade_value = models.DecimalField(max_digits=5, decimal_places=2)
```
- `DecimalField` — precise decimal number (not `FloatField` which can have floating-point errors).
- `max_digits=5` — total digits (e.g., 100.00 = 5 digits).
- `decimal_places=2` — digits after the decimal point.

```python
    def __str__(self):
        return f"{self.student.name} - {self.subject.name}: {self.grade_value}"
```
- Displays like: `"Ahmed - Math: 95.50"` in the admin panel.

---

## 5️⃣ `core/forms.py` — Django Forms for Templates

```python
from django import forms
from .models import Student, Grade
```
- `forms` — Django's form library.
- `.models` — the dot means "from the same package (core folder)".

```python
class StudentForm(forms.ModelForm):
    class Meta:
        model = Student
        fields = ["name", "age", "email", "image"]
```

> [!IMPORTANT]
> **What is `ModelForm`?** It's a shortcut. Instead of manually creating each form field, Django automatically generates them FROM your model. It creates:
> - A text input for `name`
> - A number input for `age`
> - An email input for `email`
> - A file upload for `image`
>
> AND it knows how to save to the database with `form.save()`.

- `class Meta` — a special inner class that tells `ModelForm` which model and fields to use.
- `fields = [...]` — only include these fields in the form. This is important for security — you don't want users to edit fields they shouldn't.

```python
class GradeForm(forms.ModelForm):
    class Meta:
        model = Grade
        fields = ["student", "subject", "grade_value"]
```
- Same concept: auto-generates a form for grades.
- `student` and `subject` will be rendered as `<select>` dropdowns (because they're ForeignKey fields).

---

## 6️⃣ `core/admin.py` — Admin Panel Registration

```python
from django.contrib import admin
from .models import Student, Subject, Grade

admin.site.register(Student)
admin.site.register(Subject)
admin.site.register(Grade)
```
- `admin.site.register(Student)` — tells Django: "Show the Student table in the admin panel at `/admin/`".
- After this, you can go to `http://localhost:8000/admin/` and create/edit/delete students, subjects, and grades through a nice GUI.
- You need a superuser account to access it: `python manage.py createsuperuser`.

---

> **Continue to Part 2** for: Serializers, Views, URLs, and Templates explained line by line.
