# الفصل 2 — الجزء الأول: المايجريشن والـ Eloquent: خلّي الـ Posts حقيقية

> **المتطلبات:** الفصل 1 كامل — BlogApp شغّال، الـ Routes والـ Blade Layout تمام، وعارف الفرق بين Model/View/Controller.

---

## البداية — الألم اللي هنحله النهارده

في الفصل اللي فات، الـ Posts كانت بيانات وهمية hardcoded في الـ Controller:

```php
// The fake data we used last time — useless in real life
$posts = [
    ['id' => 1, 'title' => 'Learn PHP', 'author' => 'Ahmed'],
];
```

لو أضفت Post جديدة من الـ Form — مش هتتحفظ. لو أعدت تشغيل الـ Server — كل حاجة اتمسحت. ده مش App — ده مجرد Static Page.

> اليوم هنوصّل الـ BlogApp لـ Database حقيقية — هنعرف إزاي نعمل Tables بـ Code، وإزاي Eloquent بيتحوّل من كود لـ SQL من غير ما تكتب SQL بنفسك.

---

## Section 1 — Blade Components: الـ UI Lego Blocks

### المشكلة

في كل صفحة عندك أزرار بألوان مختلفة:

```blade
{{-- You're copying this button HTML everywhere --}}
<button class="btn btn-primary btn-sm">View</button>
<button class="btn btn-secondary btn-sm">Edit</button>
<button class="btn btn-danger btn-sm">Delete</button>
```

لو عايز تغيّر الـ `btn-sm` لـ `btn-md` في كل المشروع — هتدور في كل ملف. الحل: **Blade Components**.

### إنشاء Component

```bash
# Generates two files: the class + the blade template
php artisan make:component Button
# ← creates app/View/Components/Button.php
# ← creates resources/views/components/button.blade.php
```

**الـ Class** في `app/View/Components/Button.php`:

```php
<?php

namespace App\View\Components;

use Illuminate\View\Component;

class Button extends Component
{
    // Declare the prop as a public property — Blade can access it automatically
    public function __construct(public string $type = 'primary')
    {
        // type defaults to 'primary' if not passed
    }

    public function render(): \Illuminate\View\View
    {
        return view('components.button'); // ← points to the blade template
    }
}
```

> [!note] 🐘 PHP Reminder
> الـ `public string $type = 'primary'` ده **Constructor Property Promotion** — ميزة PHP 8 بتعرّف الـ Property وتـassign قيمتها في سطر واحد جوّا الـ Constructor. قبل PHP 8 كنت لازم تعمل `public string $type;` فوق، وبعدين `$this->type = $type;` جوّا الـ Constructor. Laravel بيعتمد عليها كتير.

**الـ Template** في `resources/views/components/button.blade.php`:

```blade
{{-- $type is automatically available from the Component class's public property --}}
{{-- $slot contains everything written between the opening and closing tags --}}
<button {{ $attributes->merge(['class' => "btn btn-{$type} btn-sm"]) }}>
    {{ $slot }}
</button>
```

### الاستخدام

```blade
{{-- x- prefix tells Blade this is a component --}}
<x-button type="primary">View</x-button>
<x-button type="secondary">Edit</x-button>
<x-button type="danger">Delete</x-button>

{{-- The "slot" is the content between the tags (View, Edit, Delete) --}}
{{-- The type attribute maps to the $type property in Button.php --}}
```

> [!note] 🐘 PHP Reminder
> الـ `$attributes->merge()` ده Magic Object في Laravel اسمه `ComponentAttributeBag`. بيسمحلك تدمج الـ attributes اللي بتيجي من الـ caller مع الـ defaults — يعني لو كتبت `<x-button type="primary" id="save-btn">` فالـ `id` هيتضاف تلقائياً.

> [!info] 📖 Docs Reference
> Blade Components → [https://laravel.com/docs/master/blade#components](https://laravel.com/docs/master/blade#components)

---

## Section 2 — Migrations: الـ Version Control للـ Database

### الفكرة الجوهرية

تخيّل إنك بتشتغل على مشروع مع 5 developers. كل واحد عنده database على جهازه. لو Ahmed أضاف Column جديد لـ `posts` table — إزاي باقي الـ Team يعرفوا ويضيفوا نفس الـ Column؟

قبل Migrations: Ahmed بيبعت على WhatsApp "روح الـ phpMyAdmin وأضف column اسمه `published` نوعه boolean". بعد أسبوع مش فاكر مين عمل التغيير ده ومين لأ.

مع Migrations: التغيير بيتحفظ كـ PHP file يتـcommit على Git — ونفس الـ `php artisan migrate` بيطبّقه على أجهزة الـ Team كلها.

```
Migration = SQL Schema changes written as PHP code
             + tracked in Git
             + reversible (up + down)
```

> [!note] 🐘 PHP Reminder
> الـ Migration files بتستخدم **Method Chaining** بشكل مكثّف — `$table->string('title')->nullable()->default('untitled')`. ده ممكن في PHP لأن كل Method على الـ `ColumnDefinition` object بترجع `$this`، اللي بيسمح باستدعاء Method تانية على نفس الـ Object على طول.

---

### 2.1 — الـ Artisan Commands للـ Migrations

| Command | الغرض |
|---------|--------|
| `php artisan make:migration create_posts_table` | إنشاء migration file جديد |
| `php artisan make:model Post -m` | إنشاء Model + Migration معاً |
| `php artisan migrate` | تنفيذ كل الـ Migrations اللي لسه ما اتنفّذتش |
| `php artisan migrate:fresh` | حذف كل الـ Tables وإعادة كل الـ Migrations من الصفر |
| `php artisan migrate:refresh` | Rollback كل الـ Migrations وإعادة تشغيلها |
| `php artisan migrate:reset` | Rollback كل الـ Migrations بدون إعادة تشغيل |
| `php artisan migrate:rollback` | Rollback آخر Batch فقط |
| `php artisan migrate:status` | عرض حالة كل Migration |

الفرق الحرج بين `fresh` و`refresh`:

| | `migrate:fresh` | `migrate:refresh` |
|---|---|---|
| الطريقة | `DROP TABLE` مباشرة | بيشغّل `down()` لكل migration |
| الأمان | ❌ بيتجاهل الـ `down()` methods | ✅ بيتبع الـ proper rollback |
| متى تستخدمه | Local dev — بيانات مش مهمة | لو الـ `down()` methods مكتوبة صح |
| الأسرع | أسرع | أبطأ |

> ⚠️ **انتبه:** `migrate:fresh` بتمسح كل بياناتك. مش المفروض تشغّله على الـ Production أبداً. خلّيها بس للـ Local Development.

---

### 2.2 — كتابة Migration

```bash
# Create model + migration in one command
php artisan make:model Post -m
# ← -m flag creates the migration file automatically
# ← creates: app/Models/Post.php
# ← creates: database/migrations/2025_01_01_000000_create_posts_table.php
```

افتح ملف الـ Migration في `database/migrations/`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();                           // ← auto-increment BIGINT primary key
            $table->string('title');                // ← VARCHAR(255) NOT NULL
            $table->text('body');                   // ← TEXT column
            $table->foreignId('author_id')          // ← BIGINT unsigned (FK)
                  ->constrained('users')            // ← references users.id
                  ->cascadeOnDelete();              // ← if user deleted, posts deleted too
            $table->timestamps();                   // ← created_at + updated_at DATETIME
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('posts'); // ← called on rollback — reverses the up()
    }
};
```

> ⚠️ **انتبه:** الـ `cascadeOnDelete()` قرار مهم — يعني لو مسحت User هيتمسح كل Posts بتاعته تلقائياً. البديل هو `nullOnDelete()` اللي بيخلّي الـ `author_id` يبقى `NULL`. اختار على حسب الـ Business Logic بتاعتك.

---

### 2.3 — Column Types الأساسية

```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();                              // BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
    $table->string('title');                   // VARCHAR(255)
    $table->string('slug')->unique();          // VARCHAR(255) UNIQUE
    $table->text('body');                      // TEXT
    $table->boolean('published')->default(false); // TINYINT(1) DEFAULT 0
    $table->integer('views')->default(0);      // INT DEFAULT 0
    $table->foreignId('author_id')->constrained('users');
    $table->timestamp('published_at')->nullable(); // TIMESTAMP NULL
    $table->timestamps();                      // created_at + updated_at
    $table->softDeletes();                     // deleted_at — for soft delete
});
```

---

## Section 3 — Eloquent ORM: تكلّم مع الـ Database بـ PHP

### الفكرة

**DB Facade** = بتكتب SQL بنفسك، Laravel بس بيـexecute.
**Eloquent** = بتكتب PHP، Laravel بيترجمه لـ SQL عنك.

```php
// DB Facade — you write raw SQL
$posts = DB::select('SELECT * FROM posts WHERE author_id = ?', [$userId]);

// Eloquent — you write PHP, Laravel generates the SQL
$posts = Post::where('author_id', $userId)->get();
// ↑ generates: SELECT * FROM posts WHERE author_id = ?
```

| | DB Facade | Eloquent |
|---|---|---|
| الكتابة | SQL شبه خام | PHP خالص |
| الـ Output | Array of stdObjects | Collection of Model Objects |
| الـ Relations | يدوي | `$post->user` مباشرةً |
| متى تستخدمه | Complex queries صعبة في Eloquent | معظم الوقت |

> [!info] 📖 Docs Reference
> Eloquent ORM → [https://laravel.com/docs/master/eloquent](https://laravel.com/docs/master/eloquent)
> DB Facade → [https://laravel.com/docs/12.x/queries](https://laravel.com/docs/12.x/queries)

---

### 3.1 — إعداد الـ Model

```bash
# Post model was already created with -m flag
# Open app/Models/Post.php
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    // Whitelist columns that can be mass-assigned (e.g. Post::create([...]))
    protected $fillable = ['title', 'body', 'author_id'];

    // Laravel assumes table name = plural of class name → 'posts' ✅
    // If different: protected $table = 'my_posts';
}
```

> [!note] 🐘 PHP Reminder
> الـ `Post extends Model` ده **Class Inheritance** في PHP. الـ `Post` class بتورث من `Illuminate\Database\Eloquent\Model` اللي فيها كل الـ Magic: القدرة على الـ Query، الـ Timestamps، الـ Relations، إلخ. أنت بتكتب الـ `fillable` والـ Relations، والـ Parent Class بتعمل الباقي.

---

### 3.2 — الـ Eloquent CRUD

#### القراءة — Read

```php
// Get ALL posts as a Collection
$posts = Post::all();

// Get with conditions
$posts = Post::where('published', true)->get();

// Get one by primary key — throws exception if not found
$post = Post::findOrFail($id);
// ← findOrFail is better than find() — automatically returns 404 if not found

// Get first match
$post = Post::where('title', 'Learn PHP')->first();
```

#### الإنشاء — Create

```php
// Method 1: Mass Assignment — columns must be in $fillable
Post::create([
    'title'     => $request->title,
    'body'      => $request->body,
    'author_id' => $request->author_id,
]);

// Method 2: Manual assignment (no need for $fillable)
$post          = new Post();
$post->title   = $request->title;
$post->body    = $request->body;
$post->save(); // ← persists to DB
```

> ⚠️ **انتبه:** لو استخدمت `Post::create()` وما حطّيتش الـ `fillable` في الـ Model — هتاخد `MassAssignmentException`. ده Security feature — Laravel بيمنع إن الـ User يبعت field زي `is_admin` ويتحفظ تلقائياً.

#### التعديل — Update

```php
// Method 1: find then update
$post = Post::findOrFail($id);
$post->update([
    'title' => $request->title,
    'body'  => $request->body,
]);

// Method 2: mass update matching records
Post::where('author_id', $userId)->update(['published' => true]);
```

#### الحذف — Delete

```php
$post = Post::findOrFail($id);
$post->delete(); // ← runs DELETE query
```

---

### 3.3 — الـ Gotcha: `fillable` vs `guarded`

```php
// Option A: $fillable — whitelist (more secure, explicit)
protected $fillable = ['title', 'body', 'author_id'];
// Only these columns can be mass-assigned

// Option B: $guarded — blacklist (less verbose, slightly riskier)
protected $guarded = ['id'];
// Everything EXCEPT id can be mass-assigned

// Option C: Allow everything (dangerous — never in production)
protected $guarded = [];
```

> **نصيحة الخبراء:** استخدم `$fillable` دايماً في الـ Production — أكثر أماناً لأنك بتحدد بالظبط إيه اللي مسموح بـ Mass Assignment. الـ `$guarded = []` بتشوفها في Tutorials عشان تختصر الكود، لكن في real apps ممكن تسمح لـ attacker يـset columns حساسة.

---

## 🛠️ Hands-On — نوصّل BlogApp للـ Database الحقيقية

### الخطوة 1 — التأكد من الـ Database Config

في `.env` تأكد إن الـ SQLite settings صح:

```env
DB_CONNECTION=sqlite
# DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD not needed for SQLite
```

لو شايل الـ SQLite file مش موجود، عمله:

```bash
touch database/database.sqlite  # creates the SQLite file
```

---

### الخطوة 2 — إنشاء الـ Posts Migration

```bash
php artisan make:model Post -m
# ← creates Post model + migration file
```

افتح الـ Migration file في `database/migrations/` وعدّله:

```php
public function up(): void
{
    Schema::create('posts', function (Blueprint $table) {
        $table->id();
        $table->string('title');
        $table->text('body');
        $table->string('author')->default('Anonymous'); // simple string for now
        $table->timestamps();
    });
}
```

شغّل الـ Migration:

```bash
php artisan migrate
```

**✅ جرّب دلوقتي:** شغّل `php artisan migrate:status` — المفروض تشوف `posts` migration حالته `Ran`.

---

### الخطوة 3 — تعديل الـ Model

افتح `app/Models/Post.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $fillable = ['title', 'body', 'author'];
    // ← without this, Post::create() will throw MassAssignmentException
}
```

---

### الخطوة 4 — تعديل الـ Controller لاستخدام Eloquent

افتح `app/Http/Controllers/PostController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Post;         // ← import the Post model
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index()
    {
        $posts = Post::latest()->get(); // ← fetches all posts, newest first
        return view('posts.index', compact('posts'));
    }

    public function create()
    {
        return view('posts.create');
    }

    public function store(Request $request)
    {
        Post::create([
            'title'  => $request->title,
            'body'   => $request->body,
            'author' => $request->author,
        ]);

        return redirect()->route('posts.index'); // ← redirect after save
    }

    public function show($id)
    {
        $post = Post::findOrFail($id); // ← 404 if not found
        return view('posts.show', compact('post'));
    }

    public function edit($id)
    {
        $post = Post::findOrFail($id);
        return view('posts.edit', compact('post'));
    }

    public function update(Request $request, $id)
    {
        $post = Post::findOrFail($id);
        $post->update([
            'title'  => $request->title,
            'body'   => $request->body,
            'author' => $request->author,
        ]);

        return redirect()->route('posts.index');
    }

    public function destroy($id)
    {
        $post = Post::findOrFail($id);
        $post->delete();

        return redirect()->route('posts.index');
    }
}
```

---

### الخطوة 5 — تعديل الـ Blade View

افتح `resources/views/posts/index.blade.php` وعدّل الـ `@forelse` loop:

```blade
@forelse ($posts as $post)
    <tr>
        <td>{{ $loop->iteration }}</td>
        <td>{{ $post->title }}</td>
        {{-- ← $post is now an Eloquent Model object, access columns as properties --}}
        <td>{{ $post->author }}</td>
        <td>{{ $post->created_at->format('Y-m-d') }}</td>
        {{-- ← created_at is a Carbon object — has format(), diffForHumans(), etc. --}}
        <td>
            <a href="{{ route('posts.show', $post->id) }}" class="btn btn-sm btn-primary">View</a>
            <a href="{{ route('posts.edit', $post->id) }}" class="btn btn-sm btn-secondary">Edit</a>
            <form action="{{ route('posts.destroy', $post->id) }}" method="POST" style="display:inline">
                @method('DELETE')
                {{-- ← HTML forms only support GET/POST — @method spoofs DELETE --}}
                @csrf
                {{-- ← Cross-Site Request Forgery protection token --}}
                <button type="submit" class="btn btn-sm btn-danger">Delete</button>
            </form>
        </td>
    </tr>
@empty
    <tr><td colspan="5" class="text-center">No posts yet.</td></tr>
@endforelse
```

> [!note] 🐘 PHP Reminder
> لما بتكتب `$post->title` على Eloquent Model — ده مش property عادية. Laravel بيستخدم الـ PHP Magic Method `__get()` اللي بتشتغل أي ما حاولت تاخد property مش معرّفة على الـ Object. Eloquent بيستخدمها عشان يـfetch قيمة الـ Column من الـ internal attributes array.

**✅ جرّب دلوقتي:** افتح `http://127.0.0.1:8000/posts/create`، أضف Post جديدة، وشوف إنها ظهرت في الـ `/posts` list. بعدين جرّب الـ Edit والـ Delete.

> **نصيحة الخبراء:** لاحظ الـ `@method('DELETE')` و`@csrf` في الـ Form. HTML بيدعم GET وPOST بس — Laravel بيحلّ ده بإنه يحط hidden input اسمه `_method` قيمته `DELETE` ويقرأه ويـroute بناءً عليه. والـ `@csrf` بيحمي من Cross-Site Request Forgery بحقن token مخفي في كل Form.

---

## 🗺️ خريطة الفصل الثاني — الجزء الأول

```mermaid
mindmap
  root((Laravel Day 2 — Part 1))
    Blade Components
      php artisan make:component
      Class + Template
      Props as Public Properties
      slot for content
      x-component-name syntax
    Migrations
      Version Control for DB
      up() and down()
      Schema::create
      Column Types
      Fresh vs Refresh vs Rollback
    Eloquent ORM
      Model extends Model
      fillable vs guarded
      CRUD Methods
      all() where() get()
      findOrFail() create() update() delete()
    DB Facade vs Eloquent
      DB raw SQL strings
      Eloquent PHP objects
      Collections output
```

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه الفرق بين `migrate:fresh` و`migrate:refresh`؟**
> الـ `migrate:fresh` بتعمل `DROP TABLE` على كل الـ Tables مباشرةً وبعدين بتشغّل كل الـ Migrations من الصفر — سريعة لكن بتتجاهل الـ `down()` methods. الـ `migrate:refresh` بتشغّل الـ `down()` لكل Migration بالترتيب العكسي (rollback) وبعدين بتشغّل الـ `up()` تاني. الأولى أسرع وأبسط للـ Local dev، والثانية أدق لو الـ `down()` methods مهمة لك.

**س: إيه هو الـ `$fillable` ولماذا مهم؟**
> الـ `$fillable` هو Whitelist للـ Columns اللي مسموح بـ Mass Assignment — يعني تتمشي في `Post::create($request->all())`. من غيره، Laravel بيـthrow `MassAssignmentException`. ده Security feature — لو User بعت `is_admin=1` في الـ Form وأنت مش مُـfiltering — من غير `$fillable` هيتحفظ في الـ DB. الـ `$fillable` بيحمي من ده.

**س: إيه الفرق بين `find()` و`findOrFail()`؟**
> الـ `find($id)` بترجع `null` لو الـ Record مش موجود. الـ `findOrFail($id)` بترجع الـ Record أو بتـthrow `ModelNotFoundException` اللي Laravel بيترجمها تلقائياً لـ 404 HTTP Response. في الـ Production دايماً `findOrFail` أفضل لأنها بتتعامل مع الحالة الغلط تلقائياً.

**س: ليه بنستخدم `@method('DELETE')` في الـ Forms؟**
> الـ HTML Forms بتدعم بس `GET` و`POST`. لمّا Laravel شايف `_method=DELETE` في الـ Form data — بيعامل الـ Request كـ DELETE request ويـroute على المناسب. الـ `@method('DELETE')` بيولّد `<input type="hidden" name="_method" value="DELETE">` تلقائياً. نفس الفكرة مع `PUT` و`PATCH`.

**س: إيه أكبر غلطة الـ Juniors مع Eloquent؟**
> إنهم مش بيحطوا `$fillable` في الـ Model ثم بيتعجّبوا من الـ MassAssignmentException. الغلطة التانية إنهم بيستخدموا `Post::all()` ويحطوها في الـ View من غير ما يفكّروا في الـ Performance — لو عندك مليون Post، `all()` بتجيبهم كلهم في الـ Memory دفعة واحدة. الصح استخدام `paginate()` أو `limit()`.

---

## 🫒 زتونة الإنترفيو

> **"الـ Migrations في Laravel هي Version Control للـ Database — كل تغيير في الـ Schema بيتكتب كـ PHP file بـ `up()` للتطبيق و`down()` للـ Rollback، وبيتـcommit على Git زي أي كود تاني. Eloquent هو الـ ORM — الـ Post Model بيمثّل الـ `posts` Table، وأي Object منه بيمثّل Row. بكتب PHP وLaravel بيترجمه لـ SQL: `Post::where('published', true)->get()` بدل `SELECT * FROM posts WHERE published = 1`. القاعدة الأساسية: `$fillable` دايماً في الـ Model للحماية من Mass Assignment، و`findOrFail()` بدل `find()` عشان الـ 404 بيتعمل تلقائياً."**

---

*Next → الفصل 2 — الجزء الثاني: الـ Relations (1-to-Many) + N+1 Problem + Factory + Seeder + Tinker*
