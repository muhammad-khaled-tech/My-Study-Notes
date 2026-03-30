# 🎓 ITI School Management System — Learning Guide (Part 2)

## 7️⃣ `core/serializers.py` — Converting Models ↔ JSON

> [!IMPORTANT]
> **What is a Serializer?**
> - Django **Forms** convert HTML form data → Python objects (for template views)
> - DRF **Serializers** convert JSON data ↔ Python objects (for API views)
>
> Forms → for **browsers** (HTML). Serializers → for **API clients** (Postman, mobile apps).

### Imports

```python
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Student, Grade, Subject
```
- `serializers` — DRF's serializer module.
- `User` — Django's built-in user model (has username, email, password, etc.).
- `.models` — our custom models.

### RegisterSerializer — User Registration

```python
class RegisterSerializer(serializers.ModelSerializer):
```
- `ModelSerializer` — like `ModelForm` but for APIs. Auto-generates fields from a model.

```python
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)
```
- **We override** the password fields manually because:
  1. `write_only=True` — passwords should NEVER be sent back in API responses. When you GET a user, you won't see the password.
  2. `min_length=8` — password must be at least 8 characters.
  3. `password2` — confirmation field, doesn't exist in the User model, so we add it manually.

```python
    class Meta:
        model = User
        fields = ["id", "username", "email", "password", "password2"]
```
- Tells the serializer: "This serializer is based on Django's built-in `User` model."
- `fields` — only expose these fields in the API.

```python
    def validate(self, data):
        if data["password"] != data["password2"]:
            raise serializers.ValidationError({"password2": "Passwords do not match."})
        return data
```
- `validate(self, data)` — **object-level validation**. Runs after all individual field validations pass.
- `data` is a dictionary like `{"username": "ahmed", "password": "abc12345", "password2": "abc12345"}`.
- If passwords don't match → **raise an error** → DRF automatically returns a 400 Bad Request with the error message.
- If they match → **return data** to continue.

```python
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value
```
- `validate_email` — **field-level validation**. The naming pattern `validate_<fieldname>` is a DRF convention.
- DRF automatically calls `validate_email()` when the `email` field is being validated.
- `value` = the email string the user submitted.
- Checks if any user already has this email → if yes, reject.

```python
    def create(self, validated_data):
        validated_data.pop("password2")
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data.get("email", ""),
            password=validated_data["password"],
        )
        return user
```
- `create()` — called when `serializer.save()` is called.
- `validated_data.pop("password2")` — remove `password2` because the User model doesn't have this field.
- `User.objects.create_user(...)` — Django's special method that **hashes the password** before saving. Never use `User.objects.create()` because that saves the password as plain text!
- `.get("email", "")` — get email, or empty string if not provided.

### LoginSerializer — Login Validation

```python
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
```
- This is a plain `Serializer` (NOT `ModelSerializer`) because we're not creating/updating any model.
- We just need to validate that `username` and `password` are provided.
- `write_only=True` on password — never include password in responses.

> [!NOTE]
> **`Serializer` vs `ModelSerializer`**:
> - `Serializer` = you define all fields manually. Used when not tied to a specific model.
> - `ModelSerializer` = auto-generates fields from a model. Used for CRUD operations on models.

### SubjectSerializer

```python
class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = ["id", "name"]
```
- Simple serializer for Subject model. Converts to/from JSON like: `{"id": 1, "name": "Math"}`.

### GradeSerializer — More Complex

```python
class GradeSerializer(serializers.ModelSerializer):
    subject = SubjectSerializer(read_only=True)
```
- `subject = SubjectSerializer(read_only=True)` — **nested serializer**. When you READ a grade, instead of getting `"subject": 3` (just an ID), you get the full object:
  ```json
  "subject": {"id": 3, "name": "Math"}
  ```
- `read_only=True` — this field is only used in responses (GET), not in requests (POST/PUT).

```python
    subject_id = serializers.PrimaryKeyRelatedField(
        queryset=Subject.objects.all(), source="subject", write_only=True
    )
```
- `subject_id` — a **write-only** field. When CREATING a grade, you send `"subject_id": 3`.
- `PrimaryKeyRelatedField` — accepts an integer ID and validates that a Subject with that ID exists.
- `queryset=Subject.objects.all()` — the set of valid Subject IDs.
- `source="subject"` — tells DRF: "When saving, put this value into the `subject` field of the Grade model."
- `write_only=True` — only used in requests, not in responses.

```python
    student_id = serializers.PrimaryKeyRelatedField(
        queryset=Student.objects.all(), source="student", write_only=True
    )
```
- Same pattern for student. Send `"student_id": 1` when creating.

```python
    class Meta:
        model = Grade
        fields = ["id", "student_id", "subject", "subject_id", "grade_value"]
```

> [!TIP]
> **The read/write split pattern:**
> - **Reading** (GET): returns `"subject": {"id": 3, "name": "Math"}` (nested object, friendly)
> - **Writing** (POST): accepts `"subject_id": 3` (just an ID, simple)
>
> This gives the best of both worlds!

### StudentSerializer

```python
class StudentSerializer(serializers.ModelSerializer):
    gpa = serializers.ReadOnlyField(source="calculate_gpa")
```
- `ReadOnlyField` — a field that only appears in responses, never in requests.
- `source="calculate_gpa"` — DRF calls the `calculate_gpa()` method on the Student model and puts the result here.
- So the JSON response includes `"gpa": 85.5` automatically!

```python
    grades = GradeSerializer(many=True, read_only=True)
```
- `grades` — uses the `related_name="grades"` from the Grade → Student ForeignKey.
- `many=True` — a student has MANY grades, so serialize them as a JSON array.
- `read_only=True` — grades are displayed when reading a student, but you create grades separately.

```python
    class Meta:
        model = Student
        fields = ["id", "name", "age", "email", "image", "gpa", "grades"]
```
- The full API response for a student looks like:
  ```json
  {
    "id": 1,
    "name": "Ahmed",
    "age": 20,
    "email": "ahmed@iti.com",
    "image": "/media/students/ahmed.jpg",
    "gpa": 87.5,
    "grades": [
      {"id": 1, "subject": {"id": 1, "name": "Math"}, "grade_value": "90.00"},
      {"id": 2, "subject": {"id": 2, "name": "Science"}, "grade_value": "85.00"}
    ]
  }
  ```

---

## 8️⃣ `core/views.py` — All the Logic

### Imports

```python
from django.shortcuts import render, redirect, get_object_or_404
```
- `render(request, template, context)` — renders an HTML template and returns it as a response.
- `redirect(url_name)` — sends the browser to a different URL (HTTP 302 redirect).
- `get_object_or_404(Model, ...)` — tries to find an object. If not found, shows a 404 error page.

```python
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
```
- `AuthenticationForm` — Django's built-in login form (username + password fields).
- `login(request, user)` — creates a session for the user (logs them in).
- `logout(request)` — destroys the session.
- `authenticate(username, password)` — checks credentials, returns User or None.
- `@login_required` — a **decorator** that protects a view. If user is not logged in, redirects to LOGIN_URL.

```python
from rest_framework import viewsets, status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token
```
- `viewsets` — DRF's ViewSets (we'll explain below).
- `status` — HTTP status code constants (e.g., `status.HTTP_201_CREATED = 201`).
- `generics` — generic API views with common patterns built in.
- `APIView` — base class for custom API views.
- `Response` — DRF's response class (automatically converts to JSON).
- `AllowAny` — permission that allows unauthenticated access.
- `IsAuthenticated` — permission that requires authentication.
- `Token` — the Token model (stores auth tokens in the database).

---

### Template Views (HTML-based)

#### Home View

```python
@login_required
def home_view(request):
    return render(request, "core/home.html")
```
- `@login_required` — if user is not logged in, they get redirected to `/login/`.
- `request` — an object containing everything about the HTTP request (method, user, POST data, etc.).
- `render(...)` — loads `core/templates/core/home.html` and sends it to the browser.

#### Login View

```python
def login_view(request):
    if request.method == "POST":                    # User submitted the form
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():                         # Username and password are correct
            user = form.get_user()                  # Get the authenticated User object
            login(request, user)                    # Create session → user is now logged in
            return redirect("home")                 # Go to home page
    else:                                           # User just opened the page (GET)
        form = AuthenticationForm()                 # Empty form
    return render(request, "core/login.html", {"form": form})
```

> [!IMPORTANT]
> **The GET/POST pattern** — this is the most important pattern in Django template views:
> 1. **GET request** (user opens the page) → show empty form
> 2. **POST request** (user submits the form) → validate → if valid: save & redirect. If invalid: show form with errors.
>
> This pattern is repeated in `student_add`, `student_edit`, `student_delete`, and `add_grade`.

#### Student CRUD Views

```python
@login_required
def student_list(request):
    students = Student.objects.all()     # SELECT * FROM student → get all students
    return render(request, "core/student_list.html", {"students": students})
```
- `Student.objects.all()` — QuerySet of all students.
- `{"students": students}` — **context dictionary**. This makes the `students` variable available inside the template.

```python
@login_required
def student_add(request):
    if request.method == "POST":
        form = StudentForm(request.POST, request.FILES)   # Bind form with submitted data
```
- `request.POST` — dictionary of submitted text data.
- `request.FILES` — dictionary of uploaded files (for the image field).
- Both are needed because we have an `ImageField`.

```python
        if form.is_valid():       # Runs all validators (age 15-25, unique email, etc.)
            form.save()           # INSERT INTO student (...) VALUES (...)
            return redirect("student_list")
    else:
        form = StudentForm()      # Empty form for GET request
    return render(request, "core/student_form.html", {"form": form})
```

```python
@login_required
def student_edit(request, pk):
    student = get_object_or_404(Student, id=pk)
```
- `pk` — primary key, comes from the URL: `/students/edit/3/` → `pk = 3`.
- `get_object_or_404` — finds student with `id=3`. If doesn't exist → 404 error.

```python
    if request.method == "POST":
        form = StudentForm(request.POST, request.FILES, instance=student)
```
- `instance=student` — **THIS IS THE KEY DIFFERENCE from add**. It tells the form: "Don't create a new student. Update THIS existing student."
- Without `instance`, `form.save()` does `INSERT`. With `instance`, it does `UPDATE`.

```python
@login_required
def student_delete(request, pk):
    student = get_object_or_404(Student, id=pk)
    if request.method == "POST":       # Only delete on POST (confirmation)
        student.delete()               # DELETE FROM student WHERE id = pk
        return redirect("student_list")
    return render(request, "core/student_confirm_delete.html", {"student": student})
```
- **Why POST for delete?** GET requests should never change data. The GET shows a confirmation page, the POST actually deletes.

---

### REST API Views

#### RegisterAPIView

```python
class RegisterAPIView(generics.CreateAPIView):
```
- `CreateAPIView` — a generic view that **only handles POST requests** for creating objects.
- It automatically handles: receiving JSON → validating with serializer → saving → returning response.

```python
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
```
- `serializer_class` — which serializer to use for validation/creation.
- `permission_classes = [AllowAny]` — **anyone** can register (even without a token). This overrides the global `IsAuthenticated` default.

```python
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
```
- `self.get_serializer(data=request.data)` — creates a RegisterSerializer with the POST data.
- `is_valid(raise_exception=True)` — validate. If invalid, DRF auto-returns 400 error.
- `serializer.save()` — calls `RegisterSerializer.create()` which calls `User.objects.create_user()`.
- `Token.objects.get_or_create(user=user)` — creates an auth token for the new user. Returns `(token_object, was_created_boolean)`. We use `_` to ignore the boolean.

```python
        return Response(
            {
                "user": {"id": user.id, "username": user.username, "email": user.email},
                "token": token.key,
            },
            status=status.HTTP_201_CREATED,
        )
```
- Returns JSON with user info and their token. HTTP 201 = "Created successfully".
- The client saves this token and sends it in future requests.

#### LoginAPIView

```python
class LoginAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = authenticate(
            username=serializer.validated_data["username"],
            password=serializer.validated_data["password"],
        )
```
- `APIView` — base class. You manually define `get()`, `post()`, `put()`, etc.
- `authenticate()` — Django checks username/password against the database. Returns User object if valid, `None` if invalid.

```python
        if user is None:
            return Response(
                {"error": "Invalid username or password."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
```
- If credentials are wrong → return 401 Unauthorized.

```python
        token, _ = Token.objects.get_or_create(user=user)
        return Response(
            {"user": {"id": user.id, ...}, "token": token.key},
            status=status.HTTP_200_OK,
        )
```
- If valid → get/create token → return it. Client uses this token for future requests.

#### LogoutAPIView

```python
class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]    # Must be logged in to log out

    def post(self, request):
        request.user.auth_token.delete()     # Delete the token from database
        return Response({"message": "Successfully logged out."}, status=status.HTTP_200_OK)
```
- `request.user` — the currently authenticated user (DRF sets this from the token).
- `.auth_token` — the Token object associated with this user.
- `.delete()` — deletes the token. Now the old token is invalid and the client must log in again.

#### StudentViewSet — Full CRUD in 4 lines!

```python
class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated]
```

> [!IMPORTANT]
> **This is the magic of `ModelViewSet`!** With just these 4 lines, you get ALL of these endpoints:
>
> | Method | URL | Action | What it does |
> |--------|-----|--------|-------------|
> | GET | `/api/students/` | list | Get all students |
> | POST | `/api/students/` | create | Create a student |
> | GET | `/api/students/1/` | retrieve | Get student with id=1 |
> | PUT | `/api/students/1/` | update | Full update of student 1 |
> | PATCH | `/api/students/1/` | partial_update | Partial update of student 1 |
> | DELETE | `/api/students/1/` | destroy | Delete student 1 |
>
> `ModelViewSet` inherits from: `CreateModelMixin`, `RetrieveModelMixin`, `UpdateModelMixin`, `DestroyModelMixin`, `ListModelMixin`, and `GenericViewSet`. Each mixin provides one action.

#### GradeViewSet

```python
class GradeViewSet(viewsets.ModelViewSet):
    queryset = Grade.objects.all()
    serializer_class = GradeSerializer
    permission_classes = [IsAuthenticated]
```
- Same pattern. Full CRUD for grades.

---

> **Continue to Part 3** for: URLs routing and HTML Templates explained.
