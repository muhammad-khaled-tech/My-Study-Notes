# الفصل 1 — الجزء الثاني: الهيكل والـ Routing والـ Blade: أول صفحة حقيقية

> **المتطلبات:** الفصل 1 الجزء الأول — المشروع شغّال على `http://127.0.0.1:8000` وفاهم إيه معنى MVC.

---

## البداية — مشكلة الـ Developer اللي مش عارف يتجّه

تخيّل إنك نزّلت Laravel وفتحت المشروع — لقيت 20 مجلد و15 ملف في الـ root. مش عارف تكتب الـ Route فين، الـ View فين، ولا إيه الفرق بين `app/` و`resources/`. بتـguess وبتحط ملفات في أماكن غلط.

> الـ Directory Structure في Laravel مش عشوائية — كل مجلد ليه فلسفة واضحة. لما تفهمها مرة واحدة، هتعرف فين أي حاجة قبل ما تدوّر عليها.

---

## Section 1 — Directory Structure: خريطة المشروع

### المجلدات اللي هتتعامل معاها كل يوم

```
blog-app/
│
├── app/                        ← ← ← قلب الـ Application
│   ├── Http/
│   │   ├── Controllers/        ← Controllers هنا
│   │   └── Middleware/         ← Middleware هنا
│   └── Models/                 ← Eloquent Models هنا
│
├── config/                     ← كل الـ Settings (app, database, mail, ...)
│
├── database/
│   ├── migrations/             ← تعريف شكل الـ Tables كـ Code
│   ├── seeders/                ← بيانات وهمية للـ Development
│   └── factories/              ← Factories لإنشاء fake data بسرعة
│
├── public/                     ← ← ← الـ Web Server بيـpoint هنا
│   └── index.php               ← Entry Point — كل Request بيدخل منه
│
├── resources/
│   └── views/                  ← ← ← Blade Templates هنا
│
├── routes/
│   ├── web.php                 ← ← ← Routes بتاعت الـ Web (Browser)
│   └── api.php                 ← Routes بتاعت الـ API (JSON)
│
├── storage/                    ← Logs + Cache + Compiled Blade Files
├── tests/                      ← Unit & Feature Tests
├── vendor/                     ← Composer Packages (لا تلمسه يدوياً)
│
├── .env                        ← Environment Variables (لا يتـcommit على Git)
├── .env.example                ← Template للـ .env (لازم يتـcommit)
├── artisan                     ← Entry Point لكل php artisan commands
├── composer.json               ← PHP Dependencies
└── composer.lock               ← Exact versions اللي اتثبّتت
```

> ⚠️ **انتبه:** الملف `webpack.mix.js` اللي ظهر في الـ Slides ده قديم من زمن **Laravel Mix**. الـ Laravel الحديث (v10+) بيستخدم **Vite** و`vite.config.js` بدلاً منه. لو شفت `webpack.mix.js` في مشروع — ده مشروع قديم.

### الملفات المهمة في الـ Root

| الملف | الغرض |
|-------|--------|
| `.env` | Environment variables — DB credentials, API keys، لا يتـcommit |
| `.env.example` | Template للـ `.env` — لازم يتـcommit عشان باقي الـ team |
| `artisan` | PHP script — كل `php artisan` commands بتمشي منه |
| `composer.json` | PHP dependencies مع version constraints |
| `composer.lock` | Exact versions — لازم يتـcommit |
| `package.json` | Frontend dependencies (npm) |

> [!note] 🐘 PHP Reminder
> الملف `artisan` في الـ root ده plain PHP script — لو فتحته هتلاقيه بيعمل `require __DIR__.'/vendor/autoload.php'` ثم بيشغّل الـ Laravel Application في **Console Mode** بدل الـ HTTP Mode. الفرق بينهم إن الـ HTTP Mode بيعمل Response للـ Browser، والـ Console Mode بيطبع في الـ Terminal.

---

## Section 2 — Routing: بوّابة كل Request

### الفكرة الجوهرية

لما User يكتب `/posts` في المتصفح — مين يقول لـ Laravel إيه اللي المفروض يحصل؟ الـ Router. ملف `routes/web.php` هو الـ Traffic Cop بتاع الـ Application.

> [!note] 🐘 PHP Reminder
> لما بتكتب `Route::get(...)` — ده مش بتستدعي Method على Object عادي. `Route::` ده **Facade** في Laravel، وهو بيستخدم الـ PHP **Static Method syntax** (`::`) كـ shortcut للوصول للـ underlying Router object من الـ Service Container. مش محتاج تعمل `new Router()` — Laravel بيعمله عنك.

---

### 2.1 — أبسط Route: الـ Closure Route

```php
// routes/web.php

// The simplest possible route — a closure handles the request directly
Route::get('/posts', function () {
    return 'All Posts Page'; // ← returns plain text (fine for testing)
});
```

الـ `Route::get` بياخد:
1. الـ URI (`'/posts'`)
2. الـ Handler — إما Closure أو Controller Method

---

### 2.2 — Controller Route: الطريقة الصح

الـ Closure Routes كويسة للـ testing بس. في الـ Production بتستخدم Controllers:

```php
// routes/web.php
use App\Http\Controllers\PostController; // ← always import the class

Route::get('/posts', [PostController::class, 'index']);
//                    ↑ the class           ↑ the method
```

> [!note] 🐘 PHP Reminder
> `[PostController::class, 'index']` ده PHP **Array**. الـ `::class` magic constant بترجع الـ Full Class Name كـ String — يعني `PostController::class` بترجع `"App\Http\Controllers\PostController"`. Laravel بياخد الـ Array ده، يـinstantiate الـ Controller، ويستدعي الـ Method المحدد.

---

### 2.3 — Route Parameters: المتغيّرات في الـ URL

```php
// Captures the {id} segment from the URL
Route::get('/posts/{id}', [PostController::class, 'show']);
// When user visits /posts/42 → $id = 42
```

في الـ Controller:

```php
public function show($id)
{
    // $id = 42 if user visited /posts/42
    return "Showing post number: {$id}";
}
```

#### Optional Parameters

```php
// The ? makes the parameter optional — must have a default value
Route::get('/posts/{category?}', [PostController::class, 'index']);
```

```php
public function index($category = null)
{
    // $category = null if user visited /posts
    // $category = 'tech' if user visited /posts/tech
}
```

---

### 2.4 — Named Routes: الأسماء بدل الـ URLs

تخيّل إنك كتبت URL الـ `/posts` في 30 ملف Blade. بعدين قررت تغيّر الـ URL لـ `/articles`. هتروح تعدّل في 30 ملف.

الحل: Named Routes.

```php
Route::get('/posts', [PostController::class, 'index'])->name('posts.index');
//                                                              ↑ give it a name
```

دلوقتي في أي مكان في الكود:

```php
// In a Controller — generate URL from name
return redirect()->route('posts.index'); // ← URL changes? no problem.
```

```blade
{{-- In a Blade View --}}
<a href="{{ route('posts.index') }}">All Posts</a>
{{--         ↑ generates the correct URL automatically --}}
```

> **نصيحة الخبراء:** اتعوّد على Named Routes من أول يوم. الـ Convention الـ Larvel بيتّبعه: `resource.action` — يعني `posts.index`، `posts.show`، `posts.create`، `posts.store`، `posts.edit`، `posts.update`، `posts.destroy`. لو اتبعت الـ Convention ده هيبقى كودك متسق ومفيش لبس.

---

### 2.5 — Resource Routes: الـ CRUD في سطر واحد

بدل ما تكتب 7 routes للـ CRUD يدوياً:

```php
// ❌ The verbose way — 7 routes manually
Route::get('/posts',           [PostController::class, 'index']);
Route::get('/posts/create',    [PostController::class, 'create']);
Route::post('/posts',          [PostController::class, 'store']);
Route::get('/posts/{id}',      [PostController::class, 'show']);
Route::get('/posts/{id}/edit', [PostController::class, 'edit']);
Route::put('/posts/{id}',      [PostController::class, 'update']);
Route::delete('/posts/{id}',   [PostController::class, 'destroy']);

// ✅ The Laravel way — one line generates all 7 routes
Route::resource('posts', PostController::class);
```

الـ 7 Routes اللي بيعملها `Route::resource`:

| HTTP Method | URI | Controller Method | Route Name |
|-------------|-----|-------------------|------------|
| GET | `/posts` | `index()` | `posts.index` |
| GET | `/posts/create` | `create()` | `posts.create` |
| POST | `/posts` | `store()` | `posts.store` |
| GET | `/posts/{post}` | `show()` | `posts.show` |
| GET | `/posts/{post}/edit` | `edit()` | `posts.edit` |
| PUT/PATCH | `/posts/{post}` | `update()` | `posts.update` |
| DELETE | `/posts/{post}` | `destroy()` | `posts.destroy` |

> [!info] 📖 Docs Reference
> Routing → [https://laravel.com/docs/master/routing](https://laravel.com/docs/master/routing)
> Resource Controllers → [https://laravel.com/docs/master/controllers#resource-controllers](https://laravel.com/docs/master/controllers#resource-controllers)

---

## Section 3 — Blade Templating Engine: HTML بأسلوب Laravel

### الفكرة

قبل Blade، كنت بتكتب HTML + PHP متخلطين:

```php
<!-- The old painful way — PHP tags inside HTML -->
<?php foreach($posts as $post): ?>
    <h2><?php echo htmlspecialchars($post['title']); ?></h2>
<?php endforeach; ?>
```

Blade بيخليها أنظف وأسهل — وبيضيف فوقيها Layout Inheritance اللي بيحلّ مشكلة تكرار الـ Navbar والـ Footer في كل page.

> [!note] 🐘 PHP Reminder
> الـ Blade files مش بتتـparse مباشرةً — Laravel بيـcompile كل `.blade.php` file لـ plain PHP وبيحتفظ بيه في `storage/framework/views/`. يعني `{{ $post->title }}` بتتحوّل لـ `<?php echo e($post->title); ?>`. الـ `e()` function دي بتعمل `htmlspecialchars()` تلقائياً — وده سر الـ XSS protection.

---

### 3.1 — طباعة البيانات: `{{ }}` vs `{!! !!}`

```blade
{{-- {{ }} — Safe output: escapes HTML to prevent XSS --}}
{{ $post->title }}
{{-- Outputs: &lt;script&gt; if title contains HTML — user safe --}}

{{-- {!! !!} — Raw output: NO escaping — dangerous with user input --}}
{!! $post->body !!}
{{-- Outputs: actual HTML rendered — use ONLY with trusted content --}}
```

متى تستخدم كل واحدة؟

| | `{{ }}` | `{!! !!}` |
|---|---|---|
| الـ XSS Protection | ✅ آمن — يـescape HTML | ❌ لا — يطبع HTML خام |
| متى تستخدمه | **دايماً** بشكل افتراضي | فقط لو أنت اللي كتبت الـ Content (مش User Input) |
| مثال | `{{ $user->name }}` | `{!! $post->formatted_body !!}` |

> ⚠️ **انتبه:** الغلطة الشائعة جداً إن الـ Juniors بيستخدموا `{!! !!}` عشان "بيعمل مشكلة مع الـ HTML" — وبيفتحوا ثغرة XSS. القاعدة: لو الـ content جاي من User → `{{ }}` دايماً.

---

### 3.2 — الـ Directives: الـ Logic في Blade

#### الـ Conditions

```blade
@if ($post->published)
    <span>Published</span>
@elseif ($post->draft)
    <span>Draft</span>
@else
    <span>Unknown</span>
@endif

{{-- Shorthand for @if(!isset($var)) --}}
@unless ($user->isAdmin())
    <p>You don't have admin access</p>
@endunless
```

#### الـ Loops

```blade
@foreach ($posts as $post)
    <h2>{{ $post->title }}</h2>
    <p>By: {{ $post->author }}</p>
@endforeach

{{-- @forelse handles empty collections gracefully --}}
@forelse ($posts as $post)
    <h2>{{ $post->title }}</h2>
@empty
    <p>No posts found.</p>  {{-- ← shown when $posts is empty --}}
@endforelse
```

> [!note] 🐘 PHP Reminder
> الـ `@foreach` في Blade بتتحوّل لـ `foreach` عادي في PHP. لكن Blade بيضيف فوقيها متغيّر سحري اسمه `$loop` بيديك معلومات عن الـ iteration — زي `$loop->first`، `$loop->last`، `$loop->index`، `$loop->count`. ده بيوفّر عليك كتابة Counter يدوي.

```blade
@foreach ($posts as $post)
    @if ($loop->first)
        <hr> {{-- separator before first item only --}}
    @endif
    <h2>{{ $post->title }}</h2>
@endforeach
```

---

### 3.3 — Layout Inheritance: الـ Navbar مرة واحدة بس

المشكلة: لو عندك 10 pages وكل واحدة فيها نفس الـ Navbar والـ Footer — تغيير حاجة فيهم يخليك تعدّل في 10 ملفات.

الحل في Blade: **Layout Inheritance**.

#### الخطوة 1: اعمل Layout File

```blade
{{-- resources/views/layouts/app.blade.php --}}
<!DOCTYPE html>
<html>
<head>
    <title>@yield('title', 'ITI Blog')</title>
    {{--          ↑ slot name   ↑ default value if not provided --}}
</head>
<body>

    {{-- Navbar lives here ONCE — all pages inherit it --}}
    <nav>
        <a href="/">ITI Blog</a>
        <a href="{{ route('posts.index') }}">All Posts</a>
    </nav>

    <main>
        @yield('content')
        {{-- ↑ each child page fills this slot with its own content --}}
    </main>

    <footer>
        <p>ITI Blog © 2025</p>
    </footer>

</body>
</html>
```

#### الخطوة 2: الـ Child View ترث من الـ Layout

```blade
{{-- resources/views/posts/index.blade.php --}}
@extends('layouts.app')
{{-- ↑ NOTE: the slides had a typo "@exnteds" — the correct directive is @extends --}}

@section('title', 'All Posts')
{{-- ↑ fills the @yield('title') slot in the layout --}}

@section('content')
    <h1>All Posts</h1>

    @forelse ($posts as $post)
        <div>
            <h2>{{ $post->title }}</h2>
            <p>{{ $post->body }}</p>
        </div>
    @empty
        <p>No posts yet.</p>
    @endforelse
@endsection
{{-- ↑ everything between @section and @endsection goes into @yield('content') --}}
```

#### الخطوة 3: الـ `@include` لـ Reusable Partials

```blade
{{-- Include a partial view (no inheritance, just insertion) --}}
@include('partials.alert')

{{-- Include with data --}}
@include('posts.form', ['method' => 'POST', 'post' => null])
{{--                     ↑ passes variables to the included view --}}
```

الفرق بين `@extends` و`@include`:

| | `@extends` | `@include` |
|---|---|---|
| الفكرة | الـ Child **ترث** من الـ Layout | الـ View **تضم** جزء آخر |
| الاستخدام | Layout الـ Page كاملة | Navbar، Form، Alert، Footer |
| عدد المرات | مرة واحدة في أول الملف | في أي مكان ومرات |

> [!info] 📖 Docs Reference
> Blade Templates → [https://laravel.com/docs/master/blade](https://laravel.com/docs/master/blade)

---

## Section 4 — إنشاء الـ Controller: الـ Artisan Commands

### الـ Artisan Commands في الفصل ده

| Command | الغرض |
|---------|--------|
| `php artisan make:controller PostController` | Controller فارغ |
| `php artisan make:controller PostController --resource` | Controller بالـ 7 methods الـ CRUD جاهزة |
| `php artisan route:list` | يعرض كل الـ Routes المسجّلة |

```bash
# Create a Resource Controller — generates all 7 CRUD methods automatically
php artisan make:controller PostController --resource
```

اللي بيتعمل في `app/Http/Controllers/PostController.php`:

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index()   { /* GET /posts       — list all posts   */ }
    public function create()  { /* GET /posts/create — show create form */ }
    public function store()   { /* POST /posts       — save new post    */ }
    public function show($id) { /* GET /posts/{id}   — show one post    */ }
    public function edit($id) { /* GET /posts/{id}/edit — show edit form */ }
    public function update(Request $request, $id) { /* PUT /posts/{id} — save edits */ }
    public function destroy($id) { /* DELETE /posts/{id} — delete post   */ }
}
```

> **نصيحة الخبراء:** دايماً استخدم `--resource` حتى لو مش محتاج الـ 7 Methods كلها. أسهل إنك تشيل methods مش محتاجها من إنك تكتبها من الصفر. وبعدين هو بيعمل Documentation ضمني — أي حد يفتح الـ Controller يفهم هيلاقي فيه إيه.

---

## 🛠️ Hands-On — نكمّل على BlogApp: أول صفحة CRUD حقيقية

### الخطوة 1 — إنشاء الـ Resource Controller

```bash
# Generate PostController with all 7 CRUD methods
php artisan make:controller PostController --resource
```

**✅ جرّب دلوقتي:** افتح `app/Http/Controllers/PostController.php` — المفروض تلاقي الـ 7 methods موجودة.

---

### الخطوة 2 — تسجيل الـ Resource Route

افتح `routes/web.php` وأضف:

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PostController; // ← import the controller

Route::get('/', function () {
    return view('welcome');
});

// One line generates all 7 CRUD routes
Route::resource('posts', PostController::class);
```

**✅ جرّب دلوقتي:** شغّل الأمر ده وشوف كل الـ Routes اللي اتعملت:

```bash
php artisan route:list
# Should show 7 routes: posts.index, posts.create, posts.store, etc.
```

---

### الخطوة 3 — إنشاء الـ Layout

```bash
# Create the layouts directory
mkdir -p resources/views/layouts
```

اعمل ملف `resources/views/layouts/app.blade.php`:

```blade
<!DOCTYPE html>
<html lang="ar" dir="ltr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'ITI Blog')</title>
    {{-- Link to Bootstrap CDN for quick styling --}}
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

    <nav class="navbar navbar-dark bg-dark px-4">
        <a class="navbar-brand" href="/">ITI Blog</a>
        <a class="nav-link text-white" href="{{ route('posts.index') }}">All Posts</a>
        {{-- ↑ route('posts.index') generates /posts automatically --}}
    </nav>

    <div class="container mt-4">
        @yield('content')
        {{-- ↑ child views fill this slot --}}
    </div>

</body>
</html>
```

---

### الخطوة 4 — إنشاء Posts Index View

```bash
mkdir -p resources/views/posts
```

اعمل ملف `resources/views/posts/index.blade.php`:

```blade
@extends('layouts.app')
{{-- ↑ inherit the layout — navbar and footer come for free --}}

@section('title', 'All Posts')

@section('content')

    <div class="d-flex justify-content-between mb-3">
        <h1>All Posts</h1>
        <a href="{{ route('posts.create') }}" class="btn btn-success">Create Post</a>
    </div>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>#</th>
                <th>Title</th>
                <th>Posted By</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($posts as $post)
                <tr>
                    <td>{{ $loop->iteration }}</td>
                    <td>{{ $post['title'] }}</td>
                    <td>{{ $post['author'] }}</td>
                    <td>
                        <a href="{{ route('posts.show', $post['id']) }}" class="btn btn-sm btn-primary">View</a>
                        <a href="{{ route('posts.edit', $post['id']) }}" class="btn btn-sm btn-secondary">Edit</a>
                        <button class="btn btn-sm btn-danger">Delete</button>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="4" class="text-center">No posts yet.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

@endsection
```

---

### الخطوة 5 — ربط الـ Controller بالـ View

افتح `app/Http/Controllers/PostController.php` وعدّل الـ `index` method:

```php
public function index()
{
    // Fake data for now — we'll replace with DB in a later chapter
    $posts = [
        ['id' => 1, 'title' => 'Learn PHP',         'author' => 'Ahmed'],
        ['id' => 2, 'title' => 'Solid Principles',  'author' => 'Mohamed'],
        ['id' => 3, 'title' => 'Design Patterns',   'author' => 'Ali'],
    ];

    // Pass $posts to the view — available as $posts inside the blade file
    return view('posts.index', compact('posts'));
    //                          ↑ compact('posts') = ['posts' => $posts]
}
```

**✅ جرّب دلوقتي:** افتح `http://127.0.0.1:8000/posts` — المفروض تشوف جدول فيه الـ 3 posts مع الـ Navbar اللي جاية من الـ Layout.

---

### الخطوة 6 — Bonus: فهم `{{ }}` vs `{!! !!}` عملياً

في الـ Controller أضف post بـ HTML في الـ title:

```php
['id' => 4, 'title' => '<script>alert("XSS!")</script>', 'author' => 'Hacker'],
```

**✅ جرّب دلوقتي:** شوف الفرق:

```blade
{{ $post['title'] }}
{{-- Output: &lt;script&gt;alert("XSS!")&lt;/script&gt; — safe, shown as text --}}

{!! $post['title'] !!}
{{-- Output: actual alert popup — XSS vulnerability! --}}
```

> **نصيحة الخبراء:** ده مش مجرد نظري. في real apps، الـ Users ممكن يحطوا `<script>` في الـ form fields. الـ `{{ }}` بتحميك تلقائياً. الـ `{!! !!}` بتستخدمها فقط لو أنت generate الـ HTML ده بنفسك في الكود — زي Markdown renderer.

---

## 🗺️ خريطة الفصل الأول — الجزء الثاني

```mermaid
mindmap
  root((Laravel Day 1 — Part 2))
    Directory Structure
      app/ Controllers + Models
      routes/ web.php + api.php
      resources/views Blade files
      public/ Entry Point index.php
      database/ Migrations + Seeders
      storage/ Cache + Logs
      vendor/ Composer Packages
    Routing
      Closure Routes testing only
      Controller Routes production
      Route Parameters id
      Named Routes posts.index
      Resource Routes 7 CRUD in 1 line
    Blade
      Echo Safe {{ }}
      Echo Raw {!! !!}
      Directives @if @foreach @forelse
      Layout Inheritance @extends @yield
      Sections @section @endsection
      Partials @include
    Controller
      make:controller --resource
      7 CRUD Methods
      return view with compact
```

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه الفرق بين `{{ }}` و`{!! !!}` في Blade؟**
> الـ `{{ }}` بتـescape الـ HTML قبل ما تطبعه — يعني لو `$name` فيه `<script>` هتتحوّل لـ `&lt;script&gt;` وتتعرض كـ text مش كـ Code. ده بيحمي من XSS. الـ `{!! !!}` بتطبع الـ HTML خام من غير أي escape — بتستخدمها بس لو أنت اللي generate الـ Content ده في الكود، زي HTML جاي من Markdown Parser. أي Input جاي من User — `{{ }}` دايماً.

**س: إيه الفرق بين `@extends` و`@include` في Blade؟**
> `@extends` بتستخدمها لما الـ View عايزة ترث Layout كامل — بتبقى في أول الملف وبتحدد الـ Parent Layout. الـ Child بعدين بتملأ الـ `@yield` slots. `@include` بتستخدمها لما عايز تحط جزء صغير (Partial) جوّا View — زي Alert component أو Form. الفرق الجوهري: `@extends` هو Template Inheritance، و`@include` هو File Insertion.

**س: إيه اللي بتعمله `Route::resource` وإيه بديله؟**
> `Route::resource('posts', PostController::class)` بتسجّل 7 Routes بـ HTTP Methods مختلفة دفعة واحدة: GET لـ index، create، show، edit — وPOST لـ store — وPUT/PATCH لـ update — وDELETE لـ destroy. البديل هو تسجيل الـ 7 Routes يدوياً بـ `Route::get`، `Route::post`، إلخ. الفرق مش في الـ Performance — الـ `resource` بس convenience وبتضمن إنك تتبع الـ RESTful naming convention.

**س: إزاي تبعت Data من الـ Controller للـ Blade View؟**
> عندك طريقتين: الأولى `return view('posts.index', compact('posts'))` — والـ `compact()` بتاخد أسامي الـ Variables كـ strings وبتعمل array منها. الثانية `return view('posts.index', ['posts' => $posts])` — وده more explicit. في الـ View، الـ Variable بيبقى متاح بنفس الاسم `$posts`. الـ compact طريقة أشيك بتوفّر تكرار الاسم.

**س: إيه أكبر غلطة الـ Juniors في الـ Routing؟**
> غلطتان شائعتان: الأولى إنهم بيحطوا الـ `Route::resource` وبعدين بيحطوا routes يدوية لنفس الـ resource فوقيه — وده بيعمل route conflicts. الثانية إنهم مش بيستخدموا Named Routes ويكتبوا الـ URL hardcoded في الـ Blade — فلما الـ URL يتغيّر بيلاقوا links مكسورة في 20 ملف.

---

## 🫒 زتونة الإنترفيو

> **"الـ Routing في Laravel هو أول حاجة بتحدد مصير الـ Request — الـ `routes/web.php` بيربط كل URL بـ Controller Method، وأقوى feature فيه هو `Route::resource` اللي بيولّد الـ 7 CRUD routes في سطر واحد مع Named Routes جاهزة. الـ Blade هو الـ Templating Engine — بيحوّل `{{ }}` لـ `htmlspecialchars()` تلقائياً للحماية من XSS، وبيوفّر Layout Inheritance عبر `@extends` و`@yield` عشان الـ Navbar والـ Footer يتكتبوا مرة واحدة بس. في الـ Production، أي input من User لازم يمشي عبر `{{ }}` مش `{!! !!}` — والـ `{!! !!}` بتستخدمها بس للـ trusted HTML زي اللي أنت generate في الكود."**

---

*Next → الفصل 2: Database والـ Migrations — بنخلي الـ Posts حقيقية في Database بدل الـ Fake Array*
