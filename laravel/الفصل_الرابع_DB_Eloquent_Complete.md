# الفصل الرابع — DB Facade, Eloquent, Factory, Seeder & Tinker: بقى عندنا Database حقيقية

> **المتطلبات:** الفصل الثالث (Blade & Views) — لازم تعرف إزاي بتعرض البيانات في الـ Views، لأننا دلوقتي هنجيب البيانات دي من مكانها الحقيقي.

---

## البداية — المشكلة

تخيّل معايا إنك بنيت الـ BlogApp وكل حاجة شغالة — الـ Routes، الـ Controllers، الـ Blade Views. بس البيانات؟ مكتوبة في الكود بشكل hardcoded. كل ما عايز تضيف Post جديدة، بتفتح الكود وتكتب فيه يدوياً.

```php
// ❌ الطريقة المؤلمة — البيانات hardcoded في الـ Controller
public function index() {
    $posts = [
        ['title' => 'أول بوست', 'body' => 'محتوى...'],
        ['title' => 'تاني بوست', 'body' => 'محتوى تاني...'],
        // ← كل ما عايز بوست جديدة، بتجي هنا وبتكتب يدوياً
        // ← لو الـ App على Server، مفيش طريقة حد تاني يضيف بيانات
        // ← لو الـ Server اتعمله Restart، البيانات اتمسحت
    ];
    return view('posts.index', compact('posts'));
}
```

ده مش تطبيق — ده Word Document بشكل تاني. الـ App الحقيقي محتاج Database فيها البيانات محفوظة، ومحتاج طريقة يتكلم بيها مع الـ Database من الكود. في الفصل ده هنتعلم الطريقتين اللي Laravel بيقدمهم: **DB Facade** و**Eloquent ORM**.

---

## الجزء الأول — إعداد الـ Database Connection

قبل ما نبدأ أي حاجة، Laravel لازم يعرف يتكلم مع أنهي Database. الـ Configuration بتتعمل في ملفين:

### ملف `.env`

الملف ده في Root المشروع وبيتجاهله الـ Git. ده المكان الصح لأي بيانات حساسة.

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=blogapp       # ← اسم الـ Database
DB_USERNAME=root          # ← الـ Username
DB_PASSWORD=              # ← الـ Password (فاضي في الـ Local عادةً)
```

### ملف `config/database.php`

الملف ده بيستقرأ من الـ `.env` وبيعمل الـ Configuration. مش المفروض تعدّل فيه في الـ Development العادي، بس مفيد تعرفه.

```php
// config/database.php
'connections' => [
    'mysql' => [
        'driver'    => 'mysql',
        'host'      => env('DB_HOST', '127.0.0.1'),     // ← بيقرأ من .env أو بياخد Default
        'port'      => env('DB_PORT', '3306'),
        'database'  => env('DB_DATABASE', 'laravel'),
        'username'  => env('DB_USERNAME', 'root'),
        'password'  => env('DB_PASSWORD', ''),
        'charset'   => 'utf8mb4',                        // ← بيدعم Arabic و Emoji
        'collation' => 'utf8mb4_unicode_ci',
        // ...
    ],
],
```

> ⚠️ **انتبه:** بعد ما تعدّل في الـ `.env`، لو الـ App مش شايف التغييرات — شغّل `php artisan config:clear`. Laravel بيعمل Cache للـ Config، وده بيمسح الـ Cache.

---

## الجزء التاني — Migrations: الـ Database بتتبنى بالكود

### إيه هو الـ Migration؟

تخيّل إنك شغّال مع Team. كل Developer عنده Database محلية على الـ Laptop بتاعه. لو أنت عملت Table جديدة — إزاي بتعرّف زملاؤك بيها؟ بترسلهم Screenshot؟ بتكتب لهم الـ SQL؟ ده وجع.

الـ Migration هو ملف PHP بيوصف التغييرات على الـ Database. بدل ما كل حد يعمل الـ Table يدوياً — كل حد بيشغّل `php artisan migrate` وخلصت.

```
Migration هو:
┌────────────────────────────────────────────┐
│  ملف PHP بيقول: "الـ Database المفروض     │
│  تبقى شكلها كده"                           │
│                                            │
│  up()   → بيطبّق التغيير                  │
│  down() → بيتراجع عن التغيير               │
└────────────────────────────────────────────┘
```

### الـ Migration Commands

| Command | الغرض |
|---------|--------|
| `php artisan make:migration create_posts_table` | بيعمل Migration file جديد |
| `php artisan make:model Post -m` | بيعمل Model + Migration في أمر واحد |
| `php artisan migrate` | بيشغّل كل الـ Migrations اللي لسه ماتشغلتش |
| `php artisan migrate:status` | بيوريك حالة كل Migration (شغّل / ملشغلش) |
| `php artisan migrate:rollback` | بيتراجع عن آخر Batch من الـ Migrations |
| `php artisan migrate:reset` | بيتراجع عن كل الـ Migrations |
| `php artisan migrate:fresh` | بيمسح كل الـ Tables وبيشغّل الـ Migrations من الأول |
| `php artisan migrate:refresh` | بيعمل Rollback لكل الـ Migrations وبيشغّلهم تاني |

### الفرق بين `migrate:fresh` و`migrate:refresh`

الاتنين بيوصلوا لنفس النتيجة (Database نظيفة ومشغّلة)، بس بطريقتين مختلفتين:

| | `migrate:fresh` | `migrate:refresh` |
|---|---|---|
| الآلية | `DROP TABLE` مباشرةً لكل الـ Tables | بيشغّل `down()` لكل Migration بالترتيب العكسي |
| السرعة | أسرع | أبطأ (بيشغّل كل الـ `down()` methods) |
| لو `down()` فيها Bug | ما يأثرش | هتفشل |
| مناسب لـ | الـ Development اليومي | لما عايز تتأكد إن الـ `down()` شغّالة |

### بناء Migration كامل لجدول الـ Posts

```bash
# بيعمل الملفين مع بعض
php artisan make:model Post -m
```

الأمر ده بيعمل:
- `app/Models/Post.php` — الـ Model
- `database/migrations/2024_01_01_000000_create_posts_table.php` — الـ Migration

```php
// database/migrations/xxxx_create_posts_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();                    // ← BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
            $table->string('title');         // ← VARCHAR(255)
            $table->string('slug')->unique();// ← VARCHAR(255) UNIQUE
            $table->text('body');            // ← TEXT
            $table->foreignId('author_id')
                  ->constrained('users')    // ← FOREIGN KEY يشاور على users.id
                  ->cascadeOnDelete();      // ← لو الـ User اتحذف، Posts بتتحذف معاه
            $table->boolean('is_published')->default(false); // ← TINYINT DEFAULT 0
            $table->timestamp('published_at')->nullable();   // ← ممكن يكون فاضي
            $table->timestamps();            // ← created_at و updated_at
        });
    }

    public function down(): void
    {
        // ← بيمسح الـ Table لو عملنا Rollback
        Schema::dropIfExists('posts');
    }
};
```

### الـ Column Types الشائعة

```php
Schema::create('examples', function (Blueprint $table) {
    // === Numeric ===
    $table->id();                          // BIGINT UNSIGNED AUTO_INCREMENT
    $table->integer('views');              // INT
    $table->bigInteger('salary');          // BIGINT
    $table->unsignedInteger('score');      // INT UNSIGNED (مش بيقبل سالب)
    $table->decimal('price', 8, 2);        // DECIMAL(8,2) ← للأسعار والأموال
    $table->float('rating');               // FLOAT
    $table->boolean('is_active');          // TINYINT(1)

    // === Strings ===
    $table->string('name');                // VARCHAR(255)
    $table->string('code', 10);            // VARCHAR(10) ← تحديد الطول
    $table->text('description');           // TEXT
    $table->longText('content');           // LONGTEXT ← للمحتوى الطويل جداً
    $table->char('country_code', 2);       // CHAR(2) ← طول ثابت

    // === Dates ===
    $table->date('birth_date');            // DATE
    $table->dateTime('scheduled_at');      // DATETIME
    $table->timestamp('verified_at');      // TIMESTAMP
    $table->timestamps();                  // created_at و updated_at معاً
    $table->softDeletes();                 // deleted_at ← للـ Soft Delete

    // === Special ===
    $table->json('metadata');              // JSON ← بيخزن JSON
    $table->enum('status', ['draft', 'published', 'archived']); // ENUM
    $table->foreignId('user_id')->constrained(); // FK بيشاور على users.id

    // === Modifiers ===
    $table->string('middle_name')->nullable();  // ← ممكن يكون NULL
    $table->integer('order')->default(0);       // ← قيمة افتراضية
    $table->string('email')->unique();          // ← لازم يكون Unique
    $table->string('username')->index();        // ← بيعمل Index للبحث السريع
});
```

### تعديل Migration موجودة (إضافة Column)

لو عايز تضيف Column لـ Table موجودة، **مش بتعدّل في الـ Migration القديمة** — بتعمل Migration جديدة.

```bash
php artisan make:migration add_excerpt_to_posts_table
```

```php
public function up(): void
{
    Schema::table('posts', function (Blueprint $table) {
        // ← لازم تحدد إن بعد أنهي Column هتيجي
        $table->text('excerpt')->nullable()->after('body');
    });
}

public function down(): void
{
    Schema::table('posts', function (Blueprint $table) {
        $table->dropColumn('excerpt'); // ← الـ Rollback بيشيل الـ Column
    });
}
```

> ⚠️ **انتبه:** لو عدّلت في Migration قديمة وهي اتشغلت قبل كده — `php artisan migrate` مش هيحس بالتغيير. المفروض تعمل Migration جديدة للتعديل، أو تعمل `migrate:fresh` (في الـ Development بس).

> [!info] 📖 Docs Reference
> Migrations → https://laravel.com/docs/master/migrations

---

## الجزء التالت — DB Facade: الـ Query Builder

### الـ Facade هو إيه؟

> [!note] 🐘 PHP Reminder
> الـ Facades في PHP هي Design Pattern بيخليك توصل لـ Objects معقدة من خلال Interface بسيطة تشبه الـ Static Methods. لما بتكتب `DB::table('posts')` — مش بتشغّل Static Method حقيقية. Laravel بيستخدم Magic Method اسمها `__callStatic()` في PHP عشان يحول الـ Call ده للـ Object الحقيقي اللي اتعمل من قبل في الـ Service Container.

الـ `DB` Facade هو واجهة بتخليك تبني SQL Queries بـ PHP Code بدل ما تكتب SQL نص خالص. بيسمى **Query Builder** لأنك بتبني الـ Query بيس steps.

```php
use Illuminate\Support\Facades\DB; // ← لازم تعمل Import
```

### قراءة البيانات (SELECT)

```php
// جيب كل الـ Rows في الـ Table
$posts = DB::table('posts')->get();
// SQL: SELECT * FROM posts
// ← بيرجع Collection من stdClass Objects (مش Eloquent Models)

// جيب Row واحدة بالـ id
$post = DB::table('posts')->find(20);
// SQL: SELECT * FROM posts WHERE id = 20 LIMIT 1
// ← بيرجع stdClass أو null

// جيب أول Row
$firstPost = DB::table('posts')->first();
// SQL: SELECT * FROM posts LIMIT 1

// جيب Row بشرط
$post = DB::table('posts')
           ->where('slug', 'my-first-post')
           ->first();
// SQL: SELECT * FROM posts WHERE slug = 'my-first-post' LIMIT 1

// جيب Posts المنشورة
$published = DB::table('posts')
               ->where('is_published', true)
               ->get();
// SQL: SELECT * FROM posts WHERE is_published = 1
```

### الـ Where Conditions بالتفصيل

```php
// where بسيطة: where('column', 'value') ← افتراضياً المقارنة بـ =
DB::table('posts')->where('author_id', 1)->get();
// SQL: WHERE author_id = 1

// where بـ Operator مختلف
DB::table('posts')->where('views', '>', 100)->get();
// SQL: WHERE views > 100

DB::table('posts')->where('created_at', '>=', '2024-01-01')->get();
// SQL: WHERE created_at >= '2024-01-01'

// Where LIKE للبحث
DB::table('posts')->where('title', 'like', '%laravel%')->get();
// SQL: WHERE title LIKE '%laravel%'

// where مع كذا شرط (AND)
DB::table('posts')
   ->where('is_published', true)
   ->where('author_id', 1)
   ->get();
// SQL: WHERE is_published = 1 AND author_id = 1

// orWhere (OR)
DB::table('posts')
   ->where('author_id', 1)
   ->orWhere('author_id', 2)
   ->get();
// SQL: WHERE author_id = 1 OR author_id = 2

// whereIn
DB::table('posts')->whereIn('author_id', [1, 2, 3])->get();
// SQL: WHERE author_id IN (1, 2, 3)

// whereNull / whereNotNull
DB::table('posts')->whereNull('published_at')->get();
// SQL: WHERE published_at IS NULL

// whereBetween
DB::table('posts')->whereBetween('views', [100, 500])->get();
// SQL: WHERE views BETWEEN 100 AND 500
```

### الترتيب والتحديد والـ Pagination

```php
// orderBy
DB::table('posts')->orderBy('created_at', 'desc')->get();
// SQL: ORDER BY created_at DESC

// orderByDesc (Shorthand)
DB::table('posts')->orderByDesc('created_at')->get();

// latest() / oldest() ← بيستخدم created_at تلقائياً
DB::table('posts')->latest()->get();  // DESC
DB::table('posts')->oldest()->get();  // ASC

// limit / take
DB::table('posts')->limit(10)->get();
DB::table('posts')->take(10)->get(); // نفس الحاجة
// SQL: LIMIT 10

// offset / skip
DB::table('posts')->skip(20)->take(10)->get();
// SQL: LIMIT 10 OFFSET 20 ← الصفحة التالتة (10 Records لكل صفحة)

// select columns معينة
DB::table('posts')->select('id', 'title', 'created_at')->get();
// SQL: SELECT id, title, created_at FROM posts

// select مع Alias
DB::table('posts')->select('title as post_title')->get();
// SQL: SELECT title as post_title FROM posts
```

### إضافة وتعديل وحذف البيانات (INSERT, UPDATE, DELETE)

```php
// INSERT
DB::table('posts')->insert([
    'title'        => 'أول بوست',
    'slug'         => 'first-post',
    'body'         => 'محتوى البوست',
    'author_id'    => 1,
    'is_published' => false,
    'created_at'   => now(), // ← لازم تضيف الـ Timestamps يدوياً مع DB Facade
    'updated_at'   => now(),
]);
// بيرجع true أو false

// insertGetId ← لو محتاج الـ id اللي اتعمل
$id = DB::table('posts')->insertGetId([
    'title'      => 'بوست جديد',
    'author_id'  => 1,
    'created_at' => now(),
    'updated_at' => now(),
]);
// $id = 42 (مثلاً) ← الـ id اللي اتعمل

// INSERT أكتر من Row في مرة واحدة
DB::table('posts')->insert([
    ['title' => 'بوست 1', 'author_id' => 1, 'created_at' => now(), 'updated_at' => now()],
    ['title' => 'بوست 2', 'author_id' => 2, 'created_at' => now(), 'updated_at' => now()],
    ['title' => 'بوست 3', 'author_id' => 1, 'created_at' => now(), 'updated_at' => now()],
]);

// UPDATE
DB::table('posts')
   ->where('id', 1)
   ->update(['title' => 'عنوان معدّل', 'updated_at' => now()]);
// ← بيرجع عدد الـ Rows اللي اتأثرت

// UPDATE كل الـ Rows (بدون where)
DB::table('posts')->update(['is_published' => false]);
// ← بيأثر على كل الـ Records! كن حذر

// increment / decrement
DB::table('posts')->where('id', 1)->increment('views');         // views = views + 1
DB::table('posts')->where('id', 1)->increment('views', 5);      // views = views + 5
DB::table('posts')->where('id', 1)->decrement('views');         // views = views - 1

// DELETE
DB::table('posts')->where('id', 1)->delete();
// ← بيرجع عدد الـ Rows اللي اتحذفت

// حذف كل الـ Table
DB::table('posts')->delete(); // ← خطر! بيحذف كل حاجة
```

### Aggregates (إحصائيات)

```php
// count
$total = DB::table('posts')->count();
$published = DB::table('posts')->where('is_published', true)->count();

// max / min / avg / sum
$maxViews = DB::table('posts')->max('views');
$minViews = DB::table('posts')->min('views');
$avgViews = DB::table('posts')->avg('views');
$totalViews = DB::table('posts')->sum('views');

// exists / doesntExist
$exists = DB::table('posts')->where('slug', 'my-post')->exists();
// ← بيرجع true أو false
```

### Joins مع الـ DB Facade

```php
// INNER JOIN
$posts = DB::table('posts')
            ->join('users', 'posts.author_id', '=', 'users.id')
            ->select('posts.title', 'users.name as author_name')
            ->get();
// SQL: SELECT posts.title, users.name as author_name
//      FROM posts INNER JOIN users ON posts.author_id = users.id

// LEFT JOIN
$posts = DB::table('posts')
            ->leftJoin('comments', 'posts.id', '=', 'comments.post_id')
            ->select('posts.title', DB::raw('COUNT(comments.id) as comments_count'))
            ->groupBy('posts.id', 'posts.title')
            ->get();
```

### Raw Queries لما الـ Builder مش كافي

```php
// Raw Expression في الـ Select
$posts = DB::table('posts')
            ->select(DB::raw('COUNT(*) as total, author_id'))
            ->groupBy('author_id')
            ->get();

// Raw WHERE
$posts = DB::table('posts')
            ->whereRaw('views > ? AND is_published = ?', [100, 1])
            ->get();
// ← الـ ? هنا Bindings عشان تحمي من SQL Injection

// استخدام Raw SQL كامل (نادر — بس ممكن)
$posts = DB::select('SELECT * FROM posts WHERE author_id = ?', [1]);
DB::insert('INSERT INTO posts (title) VALUES (?)', ['Test']);
DB::update('UPDATE posts SET title = ? WHERE id = ?', ['New Title', 1]);
DB::delete('DELETE FROM posts WHERE id = ?', [1]);
```

> ⚠️ **انتبه:** لما بتستخدم Raw Queries، **دايماً استخدم Bindings (الـ ?)** ومتحطش المتغيرات مباشرةً في الـ SQL String. ده عشان تحمي نفسك من **SQL Injection**.

```php
// ❌ خطر جداً — SQL Injection
$id = $_GET['id']; // لو حد بعت: "1 OR 1=1"
DB::select("SELECT * FROM posts WHERE id = $id");

// ✅ الصح — بيستخدم Bindings
DB::select("SELECT * FROM posts WHERE id = ?", [$id]);
```

> [!info] 📖 Docs Reference
> Query Builder → https://laravel.com/docs/master/queries

---

## الجزء الرابع — Eloquent ORM: الـ Database بتبقى Objects

### إيه هو الـ ORM؟

الـ ORM (Object-Relational Mapping) هو فكرة إنك تتعامل مع الـ Database Tables كـ PHP Objects بدل ما تكتب SQL. كل Row في الـ Table بتبقى Object، وكل Column بيبقى Property.

```
الفكرة:
┌──────────────────┐         ┌──────────────────┐
│   posts TABLE    │  ←→     │   Post MODEL     │
│                  │         │                  │
│  id: 1           │         │  $post->id       │
│  title: "Laravel"│         │  $post->title    │
│  body: "..."     │         │  $post->body     │
│  author_id: 5    │         │  $post->author_id│
└──────────────────┘         └──────────────────┘
```

### إنشاء الـ Model

```bash
php artisan make:model Post          # Model فقط
php artisan make:model Post -m       # Model + Migration
php artisan make:model Post -mc      # Model + Migration + Controller
php artisan make:model Post -mcs     # Model + Migration + Controller + Seeder
php artisan make:model Post --all    # كل حاجة: Migration + Controller + Factory + Seeder
```

### الـ Model بالتفصيل

```php
// app/Models/Post.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory; // ← بيمكّن استخدام Factories مع الـ Model

    // === Convention إن مش عايز تحدد ===
    // اسم الـ Table: posts (بيأخد اسم الـ Model ويحوّله لـ Plural Snake Case)
    // الـ Primary Key: id
    // الـ Timestamps: created_at و updated_at

    // === لو عايز تغيّر الـ Conventions ===
    protected $table = 'blog_posts';       // ← لو اسم الـ Table مختلف
    protected $primaryKey = 'post_id';     // ← لو الـ PK مش 'id'
    public $incrementing = false;          // ← لو الـ PK مش Auto Increment
    protected $keyType = 'string';         // ← لو الـ PK String مش Integer
    public $timestamps = false;            // ← لو الـ Table مش عندها Timestamps

    // === Security ===
    // Option 1: $fillable ← بيحدد الـ Columns المسموح بيها
    protected $fillable = [
        'title',
        'slug',
        'body',
        'author_id',
        'is_published',
        'published_at',
    ];

    // Option 2: $guarded ← بيحدد الـ Columns الممنوعة (عكس $fillable)
    // protected $guarded = ['id']; // ← اسمح بكل حاجة إلا الـ id

    // === Casts ← بيحوّل الـ Columns لـ Types معينة ===
    protected $casts = [
        'is_published' => 'boolean',       // ← بدل 0/1 بيرجع true/false
        'published_at' => 'datetime',      // ← بيرجع Carbon Object
        'metadata'     => 'array',         // ← بيحوّل JSON لـ Array تلقائياً
    ];
}
```

### المشكلة الشهيرة: MassAssignmentException

```php
// لو مش عندك $fillable أو $guarded في الـ Model
Post::create(['title' => 'Test', 'body' => 'Body']);
// ← هتاخد: Illuminate\Database\Eloquent\MassAssignmentException
```

**ليه موجودة المشكلة دي؟**

تخيّل عندك Form فيها `title` و`body`. User شاطر بعت في الـ Request:

```
title=My Post&body=Content&is_admin=1
```

لو مفيش حماية — Laravel هيحط `is_admin = 1` في الـ Database! الـ `$fillable` بتقول: "الـ Columns دي بس اللي مسموح بيها من الـ Request".

> [!note] 🐘 PHP Reminder
> الـ `$fillable` و`$guarded` هما Properties في الـ PHP Class. لما بتعمل `Post::create([...])` — Eloquent بيشيل الـ Keys اللي مش في الـ `$fillable` قبل ما يعمل INSERT. ده مش Magic — ده PHP عادي بيفلتر الـ Array قبل الـ Query.

### قراءة البيانات (Retrieving)

```php
// جيب كل الـ Posts ← بترجع Collection من Post Objects
$posts = Post::all();

// جيب بترتيب معين
$posts = Post::orderBy('created_at', 'desc')->get();
$posts = Post::latest()->get(); // ← أحدث أول (بيستخدم created_at)
$posts = Post::oldest()->get(); // ← أقدم أول

// جيب Post بالـ id ← لو مش موجودة بترجع null
$post = Post::find(25);

// جيب Post بالـ id ← لو مش موجودة بـ throw 404
$post = Post::findOrFail(25);
// ← لو مش موجودة بترمي ModelNotFoundException → بيتحول لـ 404 Response تلقائياً

// جيب بشرط
$posts = Post::where('is_published', true)->get();
$post  = Post::where('slug', 'first-post')->first();
$post  = Post::where('slug', 'first-post')->firstOrFail(); // ← 404 لو مش موجود

// جيب Columns معينة بس
$posts = Post::select('id', 'title', 'slug')->get();
// ← أو
$posts = Post::all(['id', 'title', 'slug']);

// count / exists
$count  = Post::count();
$count  = Post::where('is_published', true)->count();
$exists = Post::where('slug', 'my-post')->exists();

// firstOrCreate ← لو موجود يجيبه، لو مش موجود يعمله
$post = Post::firstOrCreate(
    ['slug' => 'my-post'],           // ← شرط البحث
    ['title' => 'My Post', 'body' => '...'] // ← البيانات لو مش موجود
);

// updateOrCreate ← لو موجود يعدّله، لو مش موجود يعمله
$post = Post::updateOrCreate(
    ['slug' => 'my-post'],           // ← شرط البحث
    ['title' => 'Updated Title']     // ← البيانات
);
```

### إضافة البيانات (Creating)

```php
// الطريقة 1: create() ← محتاج $fillable في الـ Model
$post = Post::create([
    'title'     => 'بوست جديد',
    'slug'      => 'new-post',
    'body'      => 'المحتوى هنا',
    'author_id' => 1,
]);
// ← بيرجع الـ Post Object اللي اتعمل (مع الـ id)

// الطريقة 2: new + save() ← مش محتاج $fillable
$post = new Post();
$post->title     = 'بوست جديد';
$post->slug      = 'new-post';
$post->body      = 'المحتوى هنا';
$post->author_id = 1;
$post->save(); // ← بيعمل INSERT أو UPDATE (لو الـ Object موجود في الـ DB)
// ← بيرجع true أو false

echo $post->id; // ← ممكن تاخد الـ id بعد الـ save()
```

### تعديل البيانات (Updating)

```php
// الطريقة 1: find ثم update
$post = Post::find(25);
$post->update(['title' => 'عنوان جديد']);

// الطريقة 2: find ثم save
$post = Post::find(25);
$post->title = 'عنوان جديد';
$post->save();

// الطريقة 3: تعديل بدون جلب الـ Object (أسرع)
Post::where('author_id', 5)->update(['is_published' => false]);
// ← بيعمل UPDATE مباشرةً من غير ما يجيب الـ Records في الـ Memory

// increment / decrement
Post::find(1)->increment('views');         // ← views + 1
Post::where('id', 1)->increment('views', 5); // ← views + 5
```

### حذف البيانات (Deleting)

```php
// الطريقة 1: find ثم delete
$post = Post::find(25);
$post->delete();

// الطريقة 2: destroy بالـ id أو مجموعة ids
Post::destroy(25);           // ← حذف بـ id واحد
Post::destroy([1, 2, 3]);    // ← حذف أكتر من id
Post::destroy(1, 2, 3);      // ← نفس الحاجة

// الطريقة 3: حذف بشرط
Post::where('is_published', false)
     ->where('created_at', '<', now()->subYear())
     ->delete();
// ← حذف كل الـ Posts غير المنشورة من أكتر من سنة
```

### الـ Collections — مش Arrays عادية

لما بتعمل `Post::all()` أو `Post::get()` — بترجعلك **Eloquent Collection**، مش Array عادية.

> [!note] 🐘 PHP Reminder
> في PHP، الـ Array هي Data Structure بسيطة. الـ Collection في Laravel هي PHP Class بتـ Wrap الـ Array وبتضيف عليها فوق 150 Method. بمعنى آخر: الـ Collection هي Array + Superpowers.

```php
$posts = Post::all(); // ← Collection مش Array

// ===  أهم الـ Collection Methods ===

// filter ← بيفلتر بشرط (مش بيتعمل Query تانية)
$published = $posts->filter(fn($post) => $post->is_published === true);

// map ← بيحوّل كل Element
$titles = $posts->map(fn($post) => strtoupper($post->title));

// pluck ← جيب Column معينة بس
$titles = $posts->pluck('title');
// Result: Collection(['عنوان 1', 'عنوان 2', ...])

// pluck مع Key
$byId = $posts->pluck('title', 'id');
// Result: Collection([1 => 'عنوان 1', 2 => 'عنوان 2', ...])

// where (في الـ Memory مش في الـ DB)
$popular = $posts->where('views', '>', 1000);

// first / last
$first = $posts->first();
$last  = $posts->last();

// sortBy / sortByDesc
$sorted = $posts->sortBy('title');
$sorted = $posts->sortByDesc('views');

// take / skip
$latest5   = $posts->take(5);
$afterFirst = $posts->skip(3);

// count / isEmpty / isNotEmpty
$count = $posts->count();
$empty = $posts->isEmpty();

// each ← بيلف على كل Element
$posts->each(fn($post) => echo $post->title);

// groupBy
$grouped = $posts->groupBy('author_id');
// ← بيجمع الـ Posts حسب الـ author_id

// contains
$hasPost = $posts->contains('id', 25); // ← في Post بـ id = 25؟

// toArray / toJson
$array = $posts->toArray();
$json  = $posts->toJson();

// unique
$unique = $posts->unique('author_id'); // ← بيشيل التكرار

// values ← بيعيد ترتيب الـ Keys
$reindexed = $posts->values();

// sum / avg / max / min
$totalViews = $posts->sum('views');
$avgViews   = $posts->avg('views');
```

> [!info] 📖 Docs Reference
> Eloquent Collections → https://laravel.com/docs/master/eloquent-collections
> All Collection Methods → https://laravel.com/docs/master/collections#available-methods

---

## الجزء الخامس — Eloquent Relations: الـ Tables بتتكلم مع بعض

### الـ N+1 Problem أولاً

قبل ما نشرح الـ Relations، خلينا نفهم المشكلة اللي Relations بتحلّها لو استخدمناها غلط.

```php
// عندك 100 Post وعايز تعرض اسم الـ Author لكل Post
$posts = Post::all(); // ← 1 Query: SELECT * FROM posts

foreach ($posts as $post) {
    echo $post->user->name;
    // ← لكل Post بيعمل Query جديدة!
    // SELECT * FROM users WHERE id = 1
    // SELECT * FROM users WHERE id = 2
    // SELECT * FROM users WHERE id = 3
    // ... وهكذا 100 مرة
}

// النتيجة: 1 + 100 = 101 Query 🔥
// ده اللي بنسميه N+1 Problem
```

### إزاي تعمل Relation صح؟

#### الخطوة 1 — الـ Database Level (المهم جداً)

الـ Relation لازم تبدأ من الـ Database. لازم يكون في **Foreign Key** في الـ Migration قبل ما تعمل حاجة في الـ Model.

```php
// في Migration الـ posts table
$table->foreignId('author_id')
      ->constrained('users')    // ← FOREIGN KEY يشاور على users.id
      ->cascadeOnDelete();      // ← لو User اتحذف → Posts بتتحذف معاه
      // بدائل للـ cascadeOnDelete:
      // ->nullOnDelete()       // ← بيحط NULL في author_id
      // ->restrictOnDelete()   // ← بيمنع حذف الـ User لو عنده Posts
```

#### الخطوة 2 — الـ Model Level

```php
// app/Models/Post.php
public function user()
{
    return $this->belongsTo(User::class, 'author_id');
    //                                   ↑
    //                    اسم الـ FK في الـ posts Table
    //                    لو كان اسمه user_id (Convention) مش محتاج تكتبه
}

// app/Models/User.php
public function posts()
{
    return $this->hasMany(Post::class, 'author_id');
    //                                 ↑
    //                    نفس الـ FK لكن من ناحية الـ User
}
```

> [!note] 🐘 PHP Reminder
> لما بتكتب `$post->user` — ده مش Property حقيقية في الـ Class. PHP عندها Magic Method اسمها `__get($name)` بتتشغّل أوتوماتيك لما بتوصل لـ Property مش معرّفة. Eloquent بيـ Override الـ `__get()` دي وبيفتش في الـ Relations، ولما بيلاقي Method اسمها `user()` — بيشغّلها ويرجع النتيجة. الـ Result بيتخزن في الـ `$relations` Array في الـ Object عشان لو وصلته تاني ما يعملش Query تانية.

### hasMany و belongsTo بالتفصيل

```php
// === hasMany — User عنده كتير من الـ Posts ===

// في User Model
public function posts()
{
    return $this->hasMany(
        Post::class,    // ← الـ Related Model
        'author_id',    // ← اسم الـ FK في الـ posts Table
        'id'            // ← الـ Local Key في الـ users Table (افتراضياً id)
    );
    // اللي بيحصل: SELECT * FROM posts WHERE author_id = {$this->id}
}

// الاستخدام
$user = User::find(1);

// بتوصل للـ posts كـ Property ← Eloquent بيشغّل الـ Query ويخزن النتيجة
$posts = $user->posts; // ← Collection من Post Objects

// بتوصل للـ posts كـ Method ← بيرجع Query Builder تقدر تزيد عليه
$publishedPosts = $user->posts()->where('is_published', true)->get();
//                          ↑↑
//                    الـ () بتخلّيه Query Builder مش Collection

$postCount = $user->posts()->count(); // ← أسرع من $user->posts->count()
// لأن posts()->count() بيعمل: SELECT COUNT(*) FROM posts WHERE author_id = 1
// وde posts->count() بيجيب كل الـ Posts في الـ Memory وبعدين بيعدّهم
```

```php
// === belongsTo — Post تنتمي لـ User ===

// في Post Model
public function user()
{
    return $this->belongsTo(
        User::class,    // ← الـ Related Model
        'author_id',    // ← اسم الـ FK في الـ posts Table
        'id'            // ← الـ Key في الـ users Table (افتراضياً id)
    );
    // اللي بيحصل: SELECT * FROM users WHERE id = {$this->author_id}
}

// الاستخدام
$post = Post::find(1);
$author = $post->user;        // ← User Object
$authorName = $post->user->name; // ← اسم الـ Author
```

### Eager Loading — حل الـ N+1

```php
// ✅ الحل: Eager Loading بـ with()
$posts = Post::with('user')->get();
// بيعمل Query واحدة جنب الـ Posts:
// Query 1: SELECT * FROM posts
// Query 2: SELECT * FROM users WHERE id IN (1, 2, 3, ...) ← كل الـ IDs دفعة واحدة

// Eager Loading أكتر من Relation
$posts = Post::with(['user', 'comments', 'tags'])->get();

// Nested Eager Loading (Relations بتاعت Relations)
$posts = Post::with('user.profile')->get();
// جيب الـ Posts مع الـ User مع الـ Profile بتاع كل User

// Eager Loading مع Conditions
$posts = Post::with(['comments' => function ($query) {
    $query->where('is_approved', true)->orderBy('created_at', 'desc');
}])->get();
// ← جيب الـ Posts مع Comments المعتمدة بس، مرتّبة من الأحدث

// withCount ← عدد الـ Related Records من غير ما تجيبهم
$posts = Post::withCount('comments')->get();
foreach ($posts as $post) {
    echo $post->comments_count; // ← عدد الـ Comments لكل Post
}
// SQL: SELECT posts.*, (SELECT COUNT(*) FROM comments WHERE post_id = posts.id) as comments_count
```

### Lazy Eager Loading — لما تكتشف إنك محتاجه بعدين

```php
$posts = Post::all(); // جبت الـ Posts بدون Relations

// بعدين اكتشفت إنك محتاج الـ Users
$posts->load('user'); // ← بيعمل Query للـ Users ويضيفهم للـ Collection الموجودة

// ومحتاج Comments برضو
$posts->load(['user', 'comments']);
```

### الـ Relation كـ Query Builder

```php
$user = User::find(1);

// بدل ما تجيب كل الـ Posts وبعدين تفلتر في الـ PHP
// ❌ أبطأ — بيجيب كل الـ Posts في الـ Memory
$publishedPosts = $user->posts->filter(fn($p) => $p->is_published);

// ✅ أسرع — بيعمل الـ Filter في الـ Database
$publishedPosts = $user->posts()->where('is_published', true)->get();

// تقدر تضيف أي Query Builder Methods
$recentPosts = $user->posts()
                    ->where('is_published', true)
                    ->orderByDesc('created_at')
                    ->take(5)
                    ->get();
```

### hasOne — علاقة 1 لـ 1

```php
// مثال: User عنده Profile واحد
// في users_profiles table: user_id FK

// في User Model
public function profile()
{
    return $this->hasOne(Profile::class, 'user_id');
    // SELECT * FROM profiles WHERE user_id = {$this->id} LIMIT 1
}

// الاستخدام
$user = User::find(1);
$bio  = $user->profile->bio; // ← Profile Object
```

### الـ Default Conventions للـ Relations

| Relation | الـ FK المتوقع |
|---|---|
| `Post::belongsTo(User::class)` | `user_id` في posts table |
| `User::hasMany(Post::class)` | `user_id` في posts table |
| `User::hasOne(Profile::class)` | `user_id` في profiles table |

لو الـ FK مختلف (زي `author_id`) — لازم تحدده صراحةً في الـ Relation.

> [!info] 📖 Docs Reference
> Eloquent Relationships → https://laravel.com/docs/master/eloquent-relationships

---

## الجزء السادس — Database Factory: مصنع البيانات الـ Fake

### المشكلة

الـ App شغال تمام بس الـ Database فاضية. مش هتعرف تختبر الـ Pagination ولا الـ Performance ولا أي حاجة بجد لو عندك 3 Posts بس. محتاج تملّي الـ Database ببيانات تجريبية واقعية بسرعة.

### إنشاء الـ Factory

```bash
php artisan make:factory PostFactory
# ← بيعمل ملف في database/factories/PostFactory.php
```

```php
// database/factories/PostFactory.php
namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class PostFactory extends Factory
{
    // بتحدد الـ Model بتاع الـ Factory ده
    // ← لو اسم الـ Factory بيطابق Convention (PostFactory → Post Model) مش محتاج
    // protected $model = Post::class;

    public function definition(): array
    {
        $title = fake()->sentence(6); // ← جملة عشوائية من 6 كلمات

        return [
            'title'        => $title,
            'slug'         => Str::slug($title), // ← بيحوّل الـ Title لـ URL-friendly
            'body'         => fake()->paragraphs(4, true), // ← 4 فقرات كـ String واحد
            'author_id'    => User::factory(),   // ← بيعمل User جديد تلقائياً لكل Post
            'is_published' => fake()->boolean(70), // ← 70% فرصة إنها Published
            'published_at' => fake()->optional(0.7)->dateTimeThisYear(), // ← 70% قيمة
            'created_at'   => fake()->dateTimeThisYear(),
        ];
    }

    // ===  Factory States ← Variants للـ Factory ===

    // State: Published
    public function published(): static
    {
        return $this->state(fn(array $attributes) => [
            'is_published' => true,
            'published_at' => now(),
        ]);
    }

    // State: Draft
    public function draft(): static
    {
        return $this->state(fn(array $attributes) => [
            'is_published' => false,
            'published_at' => null,
        ]);
    }

    // State: لـ User معين
    public function forUser(User $user): static
    {
        return $this->state(fn(array $attributes) => [
            'author_id' => $user->id,
        ]);
    }
}
```

### أهم الـ Faker Methods

```php
// Fake Text
fake()->word()                    // "lorem"
fake()->words(3, true)            // "lorem ipsum dolor"
fake()->sentence(6)               // "Lorem ipsum dolor sit amet consectetur."
fake()->sentences(3, true)        // ← 3 جمل كـ String
fake()->paragraph(3)              // فقرة
fake()->paragraphs(4, true)       // ← 4 فقرات كـ String
fake()->text(200)                 // نص من 200 حرف

// Fake Names & Emails
fake()->name()                    // "John Doe"
fake()->firstName()               // "John"
fake()->lastName()                // "Doe"
fake()->email()                   // "john.doe@example.com"
fake()->safeEmail()               // "@example.com" ← آمن للـ Testing
fake()->userName()                // "john_doe"

// Fake Numbers
fake()->numberBetween(1, 100)     // رقم بين 1 و 100
fake()->randomFloat(2, 10, 100)   // رقم عشري بين 10 و 100 بـ 2 خانات
fake()->randomDigit()             // رقم من 0 لـ 9
fake()->randomElement([1, 2, 3])  // عنصر عشوائي من Array

// Fake Dates
fake()->date()                    // "2024-03-15"
fake()->dateTime()                // DateTime Object
fake()->dateTimeThisYear()        // تاريخ في السنة دي
fake()->dateTimeBetween('-1 year', 'now') // بين سنة فاتت وحلوقتي
fake()->unixTime()                // Unix Timestamp

// Fake Internet
fake()->url()                     // "http://example.com"
fake()->slug()                    // "lorem-ipsum-dolor"
fake()->ipv4()                    // "192.168.1.1"
fake()->imageUrl(640, 480)        // URL لصورة Placeholder

// Fake Boolean & Optional
fake()->boolean()                 // true أو false (50/50)
fake()->boolean(70)               // true بنسبة 70%
fake()->optional(0.7)->word()     // بيرجع Word بنسبة 70% أو null

// Arabic / Localized Faker
fake('ar_SA')->name()             // ← اسم عربي (لو محتاج)
```

### استخدام الـ Factory

```php
// عمل Post واحدة
$post = Post::factory()->create();
// ← بيعمل User + Post في الـ Database وبيرجع الـ Post Object

// عمل Post بدون حفظ في الـ DB (للـ Testing)
$post = Post::factory()->make();

// عمل أكتر من Post
$posts = Post::factory(50)->create(); // ← 50 Post في الـ Database

// باستخدام الـ States
$publishedPost = Post::factory()->published()->create();
$draftPost     = Post::factory()->draft()->create();

// لـ User معين
$user  = User::find(1);
$posts = Post::factory(10)->forUser($user)->create();

// بـ Override لبعض البيانات
$post = Post::factory()->create([
    'title'     => 'عنوان محدد أنا اخترته',
    'author_id' => 1,
    // ← باقي البيانات هتيجي من الـ Factory definition()
]);

// عمل User مع Posts بتاعته في خطوة واحدة
$user = User::factory()
            ->has(Post::factory(5))  // ← 5 Posts لكل User
            ->create();

// أو بـ Syntax تاني
$user = User::factory()
            ->hasPosts(5)  // ← بيشتغل لو عندك posts() Relation في الـ User Model
            ->create();

// عمل Post مع User بتاعها
$post = Post::factory()
             ->for(User::factory()->create())
             ->create();
```

> [!info] 📖 Docs Reference
> Eloquent Factories → https://laravel.com/docs/master/eloquent-factories

---

## الجزء السابع — Database Seeder: ملّي الـ Database

### الـ Seeder هو إيه؟

الـ Factory وصفة — الـ Seeder طبّاخ. الـ Seeder هو Class بيستخدم الـ Factories (أو أي طريقة تانية) ويضخ البيانات في الـ Database.

```bash
php artisan make:seeder PostSeeder
# ← بيعمل ملف في database/seeders/PostSeeder.php
```

### كتابة الـ Seeder

```php
// database/seeders/PostSeeder.php
namespace Database\Seeders;

use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Seeder;

class PostSeeder extends Seeder
{
    public function run(): void
    {
        // الطريقة 1: بـ Factory ← الأسرع والأبسط
        Post::factory(500)->create();
        // ← بيعمل 500 Post مع 500 User جديد

        // الطريقة 2: لو عايز Posts كلها لنفس User
        $user = User::first(); // أو User::find(1)
        Post::factory(100)->forUser($user)->create();

        // الطريقة 3: بيانات ثابتة
        Post::create([
            'title'        => 'Welcome to BlogApp',
            'slug'         => 'welcome',
            'body'         => 'This is the first post.',
            'author_id'    => 1,
            'is_published' => true,
            'published_at' => now(),
        ]);

        // الطريقة 4: بيانات من Array
        $posts = [
            ['title' => 'About Us', 'slug' => 'about'],
            ['title' => 'Contact',  'slug' => 'contact'],
        ];
        foreach ($posts as $data) {
            Post::create(array_merge($data, ['author_id' => 1, 'is_published' => true]));
        }
    }
}
```

### الـ DatabaseSeeder الرئيسي

```php
// database/seeders/DatabaseSeeder.php
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ← الترتيب مهم جداً! Users الأول عشان Posts محتاجة author_id
        $this->call([
            UserSeeder::class,  // أول: عمل الـ Users
            PostSeeder::class,  // تاني: عمل الـ Posts (محتاجة Users موجودين)
        ]);

        // أو تعمل الـ Seeding مباشرةً هنا
        User::factory(10)->create();
        Post::factory(500)->create();

        // طباعة رسايل في الـ Terminal
        $this->command->info('✅ Database seeded successfully!');
        $this->command->info('Created 10 users and 500 posts.');
    }
}
```

### تشغيل الـ Seeders

```bash
# شغّل الـ DatabaseSeeder الرئيسي
php artisan db:seed

# شغّل Seeder معين بس
php artisan db:seed --class=PostSeeder

# Fresh Migration + Seed في أمر واحد (الـ Combo الأشهر في الـ Development)
php artisan migrate:fresh --seed

# لو عايز تضيف بيانات جديدة من غير ما تمسح القديمة
php artisan db:seed --class=PostSeeder
```

### Seeder أذكى — مع التحقق من البيانات الموجودة

```php
public function run(): void
{
    // لو عايز الـ Seeder يشتغل مرة واحدة بس
    if (Post::count() === 0) {
        Post::factory(500)->create();
        $this->command->info('Posts seeded!');
    } else {
        $this->command->warn('Posts table already has data. Skipping...');
    }
}
```

> [!info] 📖 Docs Reference
> Database Seeding → https://laravel.com/docs/master/seeding

---

## الجزء الثامن — Artisan Tinker: الـ Terminal بيكلّم الـ DB

### Tinker هو إيه بالضبط؟

Tinker هو **REPL** (Read-Eval-Print Loop) بيشتغل جوّه Laravel Application. يعني بتكتب PHP Code في الـ Terminal وبينفّذه على الفور، مع access كامل لكل حاجة في الـ App — الـ Models، الـ Helpers، الـ Config، الـ Routes، كل حاجة.

```bash
php artisan tinker
# ← بيفتح الـ Tinker Shell
# Psy Shell v0.12.0 (PHP 8.2) by Justin Hileman
# >>>
```

### استخدامات الـ Tinker العملية

```php
// === اختبار الـ Eloquent ===

// جيب كل الـ Posts
>>> Post::all()

// جيب Post بـ id
>>> Post::find(1)

// عمل Post جديدة
>>> Post::create(['title' => 'Test', 'body' => 'Body', 'author_id' => 1, 'slug' => 'test'])

// تعديل Post
>>> $post = Post::find(1)
>>> $post->title = 'New Title'
>>> $post->save()

// حذف Post
>>> Post::find(1)->delete()

// اختبار Relations
>>> $user = User::find(1)
>>> $user->posts
>>> $user->posts->count()
>>> $user->posts()->where('is_published', true)->get()

// === اختبار الـ Factories ===
>>> Post::factory()->make()         // ← بيعمل Object بس من غير ما يحفظه
>>> Post::factory()->create()       // ← بيعمل في الـ DB
>>> Post::factory(5)->create()      // ← 5 Posts جديدة

// === اختبار الـ Helpers ===
>>> now()
>>> now()->addDays(7)
>>> Str::slug('Hello World')        // "hello-world"
>>> Str::random(10)                 // random string
>>> bcrypt('password')             // Hashed password

// === اختبار الـ Config ===
>>> config('app.name')
>>> config('database.default')

// === اختبار Query Builder ===
>>> DB::table('posts')->count()
>>> DB::table('posts')->where('is_published', true)->count()

// الخروج
>>> exit
```

### نصايح مهمة للـ Tinker

```php
// تقدر تكتب Multi-line Code
>>> $posts = Post::where('is_published', true)
...            ->orderByDesc('created_at')
...            ->take(5)
...            ->get()

// لو الـ Result طويل، ابعته لـ dd() 
>>> dd(Post::find(1)->toArray())

// تقدر تستخدم Variables بين الأوامر
>>> $user = User::find(1)
>>> $user->posts()->count()     // ← المتغير $user لسه موجود

// Tinker بيتذكر الـ use statements اللي بتعملها
>>> use App\Models\Post
>>> Post::all() // ← من غير ما تكتب App\Models\Post
```

> **نصيحة الخبراء:** الـ Tinker هو أسرع طريقة لاختبار الأفكار. قبل ما تكتب الكود في الـ Controller، جرّب الـ Query في الـ Tinker وتأكد إنها شغالة صح. ده بيوفّر وقت كتير من الـ Debugging.

> [!info] 📖 Docs Reference
> Artisan Tinker → https://laravel.com/docs/master/artisan#tinker

---

## الجزء التاسع — الـ Gotchas والأخطاء الشائعة

### غلطة 1: نسيان `$fillable` وعدم فهم المشكلة

```php
// ❌ الغلط — مفيش $fillable
class Post extends Model {}

Post::create(['title' => 'Test']); // ← MassAssignmentException

// ✅ الصح
class Post extends Model {
    protected $fillable = ['title', 'body', 'author_id'];
}

// أو لو بتـ Trust نفسك وما عايزش تفكر فيها (مش Recommended في Production)
class Post extends Model {
    protected $guarded = []; // ← بيسمح بكل الـ Columns
}
```

### غلطة 2: إختلاط `->posts` و`->posts()`

```php
$user = User::find(1);

// posts (بدون أقواس) ← بيشغّل الـ Query ويرجع Collection
$posts = $user->posts;          // Collection
$count = $user->posts->count(); // ← بيجيب كل الـ Posts في الـ Memory وبعدين بيعدّهم

// posts() (بأقواس) ← بيرجع Query Builder
$posts = $user->posts()->get(); // Collection
$count = $user->posts()->count(); // ← SQL: SELECT COUNT(*) ... أسرع بكتير

// الفرق العملي
$user->posts->where('is_published', true);       // ← الـ filter بيحصل في PHP
$user->posts()->where('is_published', true)->get(); // ← الـ WHERE بيحصل في الـ DB ✅
```

### غلطة 3: استخدام `find()` وعدم التحقق من الـ null

```php
// ❌ الغلط
$post = Post::find($id);
echo $post->title; // ← لو الـ id مش موجود → $post = null → Error!

// ✅ الصح — استخدم findOrFail()
$post = Post::findOrFail($id);
// ← لو مش موجود بيرمي ModelNotFoundException → بيتحول لـ 404 تلقائياً

// أو تتحقق يدوياً
$post = Post::find($id);
if (!$post) {
    return redirect()->route('posts.index')->with('error', 'Post not found');
}
```

### غلطة 4: الـ N+1 Problem من غير إدراك

```php
// ❌ N+1 — القاتل الصامت للـ Performance
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->user->name;     // ← Query لكل Post!
    echo $post->category->name; // ← Query تانية لكل Post!
}
// لو عندك 100 Post: 1 + 100 + 100 = 201 Query 😱

// ✅ الحل: Eager Loading
$posts = Post::with(['user', 'category'])->get();
// 3 Queries فقط بدل 201

// كيف تكتشف الـ N+1:
// 1. شغّل Laravel Debugbar (في الـ Development)
// 2. استخدم DB::getQueryLog()
DB::enableQueryLog();
// ... الكود بتاعك
$queries = DB::getQueryLog();
dd(count($queries)); // ← شوف عدد الـ Queries
```

### غلطة 5: `migrate:fresh` في الـ Production

```bash
# ❌ كارثة — بيمسح كل البيانات
php artisan migrate:fresh  # في الـ Production!

# ✅ الصح في الـ Production
php artisan migrate  # بيشغّل الـ Migrations الجديدة بس من غير مسح
```

### غلطة 6: استخدام الـ `DB::raw()` بشكل خاطئ

```php
// ❌ SQL Injection خطر
$search = request('search'); // لو حد بعت: "'; DROP TABLE posts; --"
DB::table('posts')->whereRaw("title = '$search'")->get(); // 💀

// ✅ استخدم Bindings دايماً
DB::table('posts')->whereRaw("title = ?", [$search])->get();
// ← Eloquent بيعمل Escape للـ Value تلقائياً
```

---

## 🛠️ Hands-On — ربط الـ BlogApp بالـ Database خطوة بخطوة

### الخطوة 1 — إعداد الـ Database

تأكد إن الـ `.env` عندك صح:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=blogapp
DB_USERNAME=root
DB_PASSWORD=
```

```bash
# عمل الـ Database (لو مش موجودة)
# افتح MySQL وشغّل:
# CREATE DATABASE blogapp;

# أو اعمله بـ Artisan
php artisan db:create  # ← بيعمل الـ Database المكتوبة في الـ .env
```

**✅ جرّب دلوقتي:** شغّل `php artisan migrate` — لو اشتغل من غير Error يبقى الـ Connection صح.

---

### الخطوة 2 — عمل Migration وModel للـ Posts

```bash
php artisan make:model Post -m
```

افتح الـ Migration الجديدة في `database/migrations/` وعدّلها:

```php
public function up(): void
{
    Schema::create('posts', function (Blueprint $table) {
        $table->id();
        $table->string('title');
        $table->string('slug')->unique();
        $table->text('body');
        $table->foreignId('author_id')
              ->constrained('users')
              ->cascadeOnDelete();
        $table->boolean('is_published')->default(false);
        $table->timestamp('published_at')->nullable();
        $table->timestamps();
    });
}
```

```bash
php artisan migrate
```

**✅ جرّب دلوقتي:** افتح الـ DB في TablePlus أو phpMyAdmin — المفروض تشوف جدول `posts` بالـ Columns الصح.

---

### الخطوة 3 — إعداد الـ Post Model

```php
// app/Models/Post.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'slug',
        'body',
        'author_id',
        'is_published',
        'published_at',
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'published_at' => 'datetime',
    ];

    // Relation: Post belongs to User
    public function user()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}

// app/Models/User.php — ضيف الـ Relation
public function posts()
{
    return $this->hasMany(Post::class, 'author_id');
}
```

---

### الخطوة 4 — ربط الـ Controller بالـ DB

```php
// app/Http/Controllers/PostController.php
namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    // === INDEX: عرض كل الـ Posts ===
    public function index()
    {
        // Eager Load الـ user عشان نعرض اسم الـ Author
        $posts = Post::with('user')
                     ->latest()      // ORDER BY created_at DESC
                     ->paginate(10); // ← Pagination لاحقاً

        return view('posts.index', compact('posts'));
    }

    // === SHOW: عرض Post واحدة ===
    public function show(Post $post) // ← Route Model Binding
    {
        $post->load('user'); // ← Lazy Eager Load لو مش مجبوبة
        return view('posts.show', compact('post'));
    }

    // === STORE: حفظ Post جديدة ===
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|min:5|max:255',
            'body'  => 'required|min:10',
        ]);

        Post::create([
            'title'     => $validated['title'],
            'slug'      => \Illuminate\Support\Str::slug($validated['title']),
            'body'      => $validated['body'],
            'author_id' => auth()->id(), // ← id الـ User اللي Logged In
        ]);

        return redirect()->route('posts.index')
                         ->with('success', 'تم إضافة البوست بنجاح!');
    }

    // === UPDATE: تعديل Post ===
    public function update(Request $request, Post $post)
    {
        $validated = $request->validate([
            'title' => 'required|min:5|max:255',
            'body'  => 'required|min:10',
        ]);

        $post->update([
            'title' => $validated['title'],
            'body'  => $validated['body'],
        ]);

        return redirect()->route('posts.show', $post)
                         ->with('success', 'تم تعديل البوست!');
    }

    // === DESTROY: حذف Post ===
    public function destroy(Post $post)
    {
        $post->delete();
        return redirect()->route('posts.index')
                         ->with('success', 'تم حذف البوست!');
    }
}
```

**✅ جرّب دلوقتي:** افتح `/posts` — المفروض يشتغل من غير Error (الـ Page هتبقى فاضية عادي).

---

### الخطوة 5 — عمل Factory وSeeder وملء الـ Database

```bash
php artisan make:factory PostFactory
php artisan make:seeder PostSeeder
```

```php
// database/factories/PostFactory.php
public function definition(): array
{
    $title = fake()->sentence(6);
    return [
        'title'        => $title,
        'slug'         => \Illuminate\Support\Str::slug($title) . '-' . fake()->unique()->randomNumber(4),
        'body'         => fake()->paragraphs(4, true),
        'author_id'    => \App\Models\User::factory(),
        'is_published' => fake()->boolean(70),
        'published_at' => fake()->optional(0.7)->dateTimeThisYear(),
        'created_at'   => fake()->dateTimeThisYear(),
    ];
}

// database/seeders/PostSeeder.php
public function run(): void
{
    Post::factory(500)->create();
    $this->command->info('✅ Created 500 posts!');
}

// database/seeders/DatabaseSeeder.php
public function run(): void
{
    $this->call([PostSeeder::class]);
}
```

```bash
php artisan db:seed
# أو
php artisan migrate:fresh --seed
```

**✅ جرّب دلوقتي:** ارجع لـ `/posts` — المفروض تشوف 500 Post من الـ Database. الـ App بقى حي!

---

### الخطوة 6 — اختبار كل حاجة بالـ Tinker

```bash
php artisan tinker
```

```php
// جرّب الـ Queries دي جوّه الـ Tinker

// كام Post عندنا؟
>>> Post::count()

// جيب أول Post مع الـ User بتاعها
>>> Post::with('user')->first()

// جيب Posts مع Views أكتر من 100
>>> Post::with('user')->where('is_published', true)->latest()->take(5)->get()

// جرّب الـ Collection Methods
>>> Post::all()->groupBy('is_published')

// جيب User مع عدد Posts بتاعته
>>> User::withCount('posts')->first()
```

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه الفرق بين `DB::table()` وEloquent Model؟**
> الـ `DB::table()` هو Query Builder خالص — بيرجعلك `stdClass` Objects وبيتطلب منك تكتب اسم الـ Table. الـ Eloquent هو ORM — بيتعامل مع الـ Database من خلال PHP Classes (Models)، وبيجي معاه Relations وEvents وCasts وScopes وكل الـ Features الكاملة. الـ DB Facade أسرع نانو-ثانية في الـ Simple Queries، بس الـ Eloquent بيوفّر Abstraction وFeatures بتخلّي الكود أنظف وأسهل في الـ Maintenance. في الـ Production الحقيقي، بستخدم Eloquent في الـ 95% من الوقت والـ DB Facade بس في الـ Complex Reporting Queries.

**س: إيه هو الـ N+1 Problem وإزاي بتحلّه؟**
> الـ N+1 Problem بيحصل لما بتجيب N Record من الـ DB وبعدين في Loop بتعمل Query لكل Record. مثلاً: لو جبت 100 Post وفي الـ Loop طلبت `$post->user->name` — بيعمل 100 Query إضافية. النتيجة 101 Query بدل 2. الحل هو **Eager Loading** بـ `Post::with('user')->get()` — بيعمل Query واحدة تانية بـ `WHERE id IN (...)` وبيجيب كل الـ Users دفعة واحدة. اكتشافه بيتم عن طريق Laravel Debugbar أو DB::getQueryLog().

**س: إيه الفرق بين `$post->user` و`$post->user()`؟**
> `$post->user` بدون أقواس هو **Dynamic Property** — بيشغّل الـ Relation Query مرة واحدة وبيحفظ النتيجة في الـ `$relations` Array جوّه الـ Object. لو وصلته تاني مش هيعمل Query. بترجعلك User Object. `$post->user()` بالأقواس بيرجعلك **BelongsTo Query Builder** — تقدر تضيف عليه Conditions وبعدين تستخدم `->get()` أو `->first()`. الفرق العملي: `$post->user()->where(...)->get()` الـ Filter بيحصل في الـ DB، بينما `$post->user->where(...)` الـ Filter بيحصل في الـ PHP على الـ Collection.

**س: إيه الفرق بين `migrate:fresh` و`migrate:refresh`؟**
> الاتنين بيخلوا الـ Database نظيفة ومشغّلة، بس بطريقتين مختلفتين. الـ `migrate:fresh` بيعمل `DROP TABLE` مباشرةً لكل الـ Tables ثم يشغّل الـ Migrations — أسرع وأضمن. الـ `migrate:refresh` بيشغّل الـ `down()` Method لكل Migration بالترتيب العكسي ثم يشغّل الـ `up()` تاني — أبطأ ولو في الـ `down()` Bug هتفشل. في الـ Development بستخدم `migrate:fresh` طول الوقت. أياً منهم **ممنوعان في الـ Production** لأنهم بيمسحوا البيانات.

**س: ليه بنحتاج الـ `$fillable` في الـ Model؟**
> الـ `$fillable` بتحمي من **Mass Assignment Vulnerability**. لو مش موجودة وجبت الـ Request كلها بـ `Post::create($request->all())` — ممكن User يضيف Columns حساسة في الـ Request زي `is_admin = 1` أو `role = admin` وتتخزن في الـ DB. الـ `$fillable` بتحدد الـ Whitelist — الـ Columns اللي مسموح بيها فقط. البديل هو `$guarded` اللي بيحدد الـ Blacklist (الممنوع).

**س: إيه الفرق بين الـ Factory والـ Seeder؟**
> الـ Factory هي "الوصفة" — Class بيعرف كيف يولّد Data Fake واقعية لـ Model معين باستخدام مكتبة Faker. الـ Seeder هو "الطبّاخ" — Class بيستخدم الـ Factory ويحدد كام Record هيتعمل وفين وامتى. الـ Factory بيستخدم برضو في الـ Tests لإنشاء Test Data. الـ Seeder هدفه ملء الـ Database ببيانات أولية أو تجريبية بأمر `php artisan db:seed`.

**س: إيه أكبر غلطة الـ Juniors مع الـ Eloquent؟**
> أكبر غلطة هي الـ N+1 Problem من غير ما يحسوا بيها. بيكتبوا Loop عادي ومش بيعرفوا إن كل iteration بتعمل Query جديدة للـ DB. لو عندك 1000 Record — بتعمل 1001 Query في كل Request. الحل بيبقى `with()` للـ Eager Loading. الغلطة التانية الشائعة هي نسيان `->firstOrFail()` واستخدام `->first()` بدون تحقق من الـ null، وده بيعمل Error لما الـ Record مش موجود.

---

## 🫒 زتونة الإنترفيو

> **"في Laravel، عندنا طريقتين للتكلم مع الـ Database: الـ DB Facade اللي هو Query Builder بيخليك تبني SQL Queries بـ PHP Code بشكل Object-Oriented من غير ما تكتب Raw SQL، والـ Eloquent ORM اللي هو الـ Core الحقيقي لـ Laravel وبيخليك تتعامل مع الـ Tables كـ PHP Objects. الـ Eloquent جاي معاه Relations زي `hasMany` و`belongsTo` بتربط الـ Models ببعض على مستوين: الـ DB Level بـ Foreign Keys في الـ Migrations، والـ Model Level بـ Methods في الـ Class. أهم حاجة في الـ Relations هي استخدام Eager Loading بـ `with()` عشان تتجنب الـ N+1 Problem اللي ممكن تعمل 1001 Query بدل 2. للبيانات التجريبية، بستخدم Factory (اللي بيولّد Data Fake باستخدام Faker Library) مع Seeder (اللي بيضخّها في الـ DB). والـ Tinker بيخليني أختبر أي Eloquent Code مباشرةً من الـ Terminal من غير ما أعمل Controller. الفرق الجوهري بين DB Facade وEloquent إن Eloquent بيفكر بـ Objects وRelations، والـ DB Facade بيفكر بـ Tables وRows."**

---

*Next → الفصل الخامس — Authentication & Middleware: إزاي تحمي الـ Routes وتتحكم في مين يقدر يدخل على إيه في الـ BlogApp*
