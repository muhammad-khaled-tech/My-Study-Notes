# الفصل 1 — الجزء الأول: المقدمة والتثبيت: لماذا وُجد Laravel أصلاً؟

> **المتطلبات:** PHP Basics + OOP — لو بتعرف تكتب Class وفاهم إيه معنى HTTP Request/Response، أنت جاهز تكمل.

---

## البداية — الألم اللي خلّى Laravel يتولد

قبل الـ Frameworks، كنت بتكتب PHP كده:

```php
// The old painful way — raw PHP, no structure, no safety
<?php
$conn = mysqli_connect("localhost", "root", "", "blog");

// ← SQL Injection vulnerability: $_GET['id'] comes directly from the user
$result = mysqli_query($conn, "SELECT * FROM posts WHERE id = " . $_GET['id']);
$post   = mysqli_fetch_assoc($result);
?>
<h1><?php echo $post['title']; ?></h1>
<p><?php echo $post['body']; ?></p>
```

كل page كانت ملف `.php` فيه HTML + SQL + Logic متخلطين مع بعض. لو عندك 50 page — نفس الـ `mysqli_connect` بيتكرر 50 مرة. لو غيّرت الـ database password، لازم تعدّل في 50 ملف.

> بدل ما تكتب نفس الكود في كل مكان وتخلط الـ Logic بالـ HTML — Laravel جاء بـ **MVC Pattern** وأدوات جاهزة بتعملك الـ Boilerplate تلقائياً.

---

## Section 1 — الـ MVC Pattern: المطبخ ومبدأ الـ Separation of Concerns

تخيّل مطعم فيه 3 أدوار واضحة:

- **المطبخ (Model)** — بيتعامل مع المكوّنات الفعلية (الـ Database).
- **الـ Waiter (Controller)** — بياخد الأوردر من الزبون، يروح يقول للمطبخ، ويجيب النتيجة.
- **الطبق (View)** — اللي الزبون بيشوفه في النهاية — HTML نضيف بدون أي Logic.

في Laravel الـ Flow بيمشي كده بالظبط:

```
User sends HTTP Request (e.g. GET /posts)
              |
              ▼
    routes/web.php         ← Traffic cop: which controller handles this URL?
              |
              ▼
    PostController.php     ← Waiter: receives request, asks the Model
              |
              ▼
    Post.php  (Model)      ← Kitchen: queries the database via Eloquent
              |
              ▼
  posts/index.blade.php    ← The Plate: pure HTML, no PHP logic here
              |
              ▼
    HTTP Response → Browser
```

الـ Flow بالشكل اللي ذكره المدرس:

```
routes → middleware → controller → model (database)
                              ↘ view (ui)
```

> [!note] 🐘 PHP Reminder
> الـ MVC مش Laravel اخترعه — ده **Design Pattern** قديم موجود من الـ 70s. فكرته الجوهرية هي **Separation of Concerns**: كل جزء من الكود عنده مسؤولية واحدة بس. الـ Model ما يعرفش عن الـ HTML، الـ View ما يعرفش عن الـ SQL، والـ Controller بس اللي بيربطهم.

---

## Section 2 — تاريخ Laravel: من CodeIgniter لـ Illuminate

في 2004، الراجل **DHH** (David Heinemeier Hansson) أطلق **Ruby on Rails** وغيّر دنيا الـ Web Frameworks — فكرة إن الـ Framework يعملك الـ Boilerplate وأنت تتركّز على الـ Business Logic.

PHP Community اتأثر وعمل Frameworks زي **CodeIgniter**. المشكلة إن CodeIgniter في 2010 كان slow في adopting modern PHP features زي الـ **Namespaces** — وPHP 5.3 كانت اتنزلت بمميزات قوية CodeIgniter مش بيستخدمها.

**Taylor Otwell** قرر يعمل حاجة أحسن:

| Version | التاريخ | أهم ما جاء بيه |
|---------|---------|----------------|
| Laravel 1 | June 2011 | Authentication, Routing, Models, Views |
| Laravel 2 | Sept 2011 | Controllers, **Blade** Template Engine, IoC Container |
| Laravel 3 | Feb 2012 | **Artisan CLI**, Events, Migrations, Bundles |
| Laravel 4 | May 2013 | إعادة كتابة كاملة — كود اسمه **Illuminate**، سحب Components من Symfony |
| Laravel 5 | Feb 2015 | Directory Structure جديدة، Socialite، dotenv |
| Laravel 6 | Sept 2019 | Semantic Versioning، Lazy Collections |
| Laravel 8+ | Sept 2020 | Release سنوي واحد |

> **نصيحة الخبراء:** الـ Version 4 ده الـ Turning Point الحقيقي — Taylor أعاد كتابة الـ Framework من الصفر وبنى فوق **Symfony Components** بدل ما يخترع كل حاجة من أوله. لحد النهارده، لو فتحت الـ `vendor/` folder هتلاقي `illuminate/` packages — دي هي قلب Laravel.

---

## Section 3 — Composer: الـ npm بتاع PHP

قبل Composer، لو محتاج Library في PHP — كنت بتدخل الموقع، تحمّل zip، تفكّه في مجلد `libs/`، وتعمل `require` يدوي. لو الـ Library دي محتاجة Library تانية — انت في ورطة تعمل نفس العملية من الأول.

```php
// The painful manual way before Composer
require 'libs/guzzle/GuzzleHttp.php';
require 'libs/guzzle/Client.php';
require 'libs/guzzle/Handler.php'; // ... and 20 more files
```

Composer حلّ ده تماماً:

```bash
# One command downloads + installs + autoloads everything
composer require guzzlehttp/guzzle  # ← handles ALL dependencies automatically
```

> [!note] 🐘 PHP Reminder
> Composer بيشتغل على مفهوم الـ **Autoloading** في PHP. بدل ما تعمل `require 'PostController.php'` في كل ملف، Composer بيبني Map بين كل اسم Class والملف بتاعه في `vendor/autoload.php`. لما بتكتب `new PostController()` — PHP بتسأل الـ autoloader: "الملف ده فين؟" وبيجيبهوله تلقائياً. اللي بيـactivate ده في Laravel هو السطر الأول في `public/index.php`.

```php
// public/index.php — first line of every Laravel request
require __DIR__.'/../vendor/autoload.php'; // ← Composer's magic bridge
```

---

## Section 4 — التثبيت: نثبّت الأدوات

### الـ Artisan Commands في الفصل ده

| Command | الغرض |
|---------|--------|
| `composer global require laravel/installer` | تثبيت Laravel Installer بشكل global |
| `laravel new app-name` | إنشاء مشروع Laravel جديد |
| `composer create-project laravel/laravel app-name` | نفس الغرض بدون الـ installer |
| `php artisan serve` | تشغيل Dev Server على port 8000 |
| `php artisan migrate` | تنفيذ الـ Migrations على الـ Database |

### طريقتا التثبيت

| | `laravel new` | `composer create-project` |
|---|---|---|
| السرعة | أسرع | أبطأ نسبياً |
| المتطلب | Laravel Installer مثبت globally | Composer فقط |
| متى تستخدمه | الاستخدام اليومي | لو الـ installer مش شغّال |

```bash
# Step 1: Install Composer from getcomposer.org/download/
composer --version  # verify installation

# Step 2: Install Laravel Installer globally
composer global require laravel/installer

# Step 3: Create the project (choose one)
laravel new blog-app                              # ← recommended
# OR
composer create-project laravel/laravel blog-app  # ← alternative
```

> ⚠️ **انتبه:** لو كتبت `laravel` وجالك "command not found" — المشكلة في الـ PATH. لازم تضيف Composer's global bin directory لـ PATH بتاعك. على Linux/Mac: أضف `export PATH="$HOME/.composer/vendor/bin:$PATH"` في `~/.bashrc` أو `~/.zshrc`.

> [!info] 📖 Docs Reference
> Installation Guide → [https://laravel.com/docs/master/installation](https://laravel.com/docs/master/installation)

---

## 🛠️ Hands-On — نبني BlogApp من الصفر

### الخطوة 1 — إنشاء المشروع

```bash
# Create our BlogApp — this is the project we'll build throughout the course
laravel new blog-app

# If the interactive wizard shows up (Laravel 11+), choose:
# - Starter kit: None
# - Testing framework: PHPUnit
# - Database: SQLite (simplest for local dev, no setup needed)
```

**✅ جرّب دلوقتي:** بعد ما الـ installer يخلّص، شغّل:

```bash
cd blog-app
php artisan serve  # ← starts dev server at http://127.0.0.1:8000
```

افتح المتصفح على `http://127.0.0.1:8000` — المفروض تشوف الـ Laravel Welcome Page الحمرا الجميلة.

---

### الخطوة 2 — أول Route حقيقية

افتح `routes/web.php`. هتلاقيه كده:

```php
<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome'); // ← serves resources/views/welcome.blade.php
});
```

دلوقتي أضف Route جديدة للـ BlogApp:

```php
// Add this below the existing route
Route::get('/hello', function () {
    return 'مرحباً بك في BlogApp!'; // ← simplest response: plain text
});
```

**✅ جرّب دلوقتي:** افتح `http://127.0.0.1:8000/hello` في المتصفح — المفروض تشوف النص ده مباشرةً.

---

### الخطوة 3 — فهم علاقة .env و config

الـ Flow المهم اللي المدرس ذكره:

```
code ← config/ ← .env
```

يعني عملياً:

```
.env                        config/ files                  your code
───────────────────────     ────────────────────────────   ──────────────────────────
APP_NAME=Blog            →  config/app.php:                config('app.name')
                               'name' => env('APP_NAME')   // returns "Blog"

DB_DATABASE=blog_db      →  config/database.php:           config('database.default')
                               'database' => env('DB_DATABASE')
```

الـ `.env` مش بيتـcommit على Git — لأن كل developer عنده database credentials مختلفة. لو استنسخت project لازم تعمل:

```bash
cp .env.example .env          # copy the template
php artisan key:generate      # generates APP_KEY
```

> ⚠️ **انتبه:** مش المفروض تستخدم `env()` مباشرةً في Controllers أو Models أبداً.

```php
// ❌ Wrong — breaks when config is cached in production
$name = env('APP_NAME');

// ✅ Correct — always reads from the config layer
$name = config('app.name');
```

> **نصيحة الخبراء:** في الـ Production بتعمل `php artisan config:cache` — وده بيخبّز كل الـ config في ملف واحد ويعطّل `env()` خارج الـ config files. لو لاحظت إن تغييراتك في `.env` مش بتظهر locally — جرّب `php artisan config:clear`.

**✅ جرّب دلوقتي:** افتح `.env` وغيّر `APP_NAME` لـ `"ITI Blog"`. افتح `config/app.php` وشوف إزاي بيقرأ منه. بعدين في الـ Route اللي عملناها أضف:

```php
Route::get('/hello', function () {
    return 'مرحباً بك في ' . config('app.name'); // ← should print "مرحباً بك في ITI Blog"
});
```

---

## 🗺️ خريطة الفصل الأول — الجزء الأول

```mermaid
mindmap
  root((Laravel Day 1 — Part 1))
    Why Laravel
      Raw PHP Pain
      No Structure
      No Security
    MVC Pattern
      Model → Database
      View → HTML
      Controller → Logic
      Flow: Route→Controller→Model→View
    History
      Ruby on Rails 2004 Inspiration
      CodeIgniter Problem namespaces
      Laravel 1-3 Early Versions
      Laravel 4 Illuminate + Symfony
      Laravel 8+ Annual Releases
    Composer
      Dependency Manager like npm
      Autoloading Magic
      composer.json vs composer.lock
    Installation
      laravel new
      composer create-project
      php artisan serve
    env and config
      .env not committed to Git
      config reads from env
      use config() not env() in code
```

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه هو الـ MVC Pattern وإزاي Laravel بيطبّقه؟**
> الـ MVC بيقسم الـ Application لـ 3 طبقات بمسؤولية واحدة لكل منها: الـ **Model** بيتكلم مع الـ Database، الـ **View** بيعرض HTML للـ User بدون Logic، والـ **Controller** هو الـ Orchestrator اللي بياخد الـ Request، يسأل الـ Model، وبيبعت الداتا للـ View. في Laravel، الـ Routes في `routes/web.php` بتوجّه الـ Request للـ Controller الصح، والـ Controller بيتكلم مع الـ Eloquent Model، وبيرجع Blade View.

**س: إيه الفرق بين `composer.json` و`composer.lock`؟**
> الـ `composer.json` بتكتب فيه الـ dependencies مع version constraints زي `"^10.0"` — يعني "نسخة 10 أو أي حاجة compatible". الـ `composer.lock` بيسجّل الـ exact versions اللي اتثبّتت فعلاً. لما بتعمل `composer install` على server — بيقرأ من الـ `lock` file لضمان إن نفس الـ versions موجودة عند كل الـ developers. **القاعدة: الـ `lock` لازم يتـcommit على Git.**

**س: ليه Laravel عمل Rewrite كامل في الـ Version 4؟**
> الـ Versions 1-3 كان Laravel كاتب كل حاجة من الصفر. في Version 4، Taylor قرر يبني فوق **Symfony Components** بدل إعادة اختراع العجلة — عمل Layer اسمها **Illuminate** فوقيها. ده خلّى Laravel يستفيد من كود battle-tested ويتفرغ لإضافة الـ Developer Experience المميزة بتاعته زي Artisan وEloquent.

**س: ليه `env()` مش المفروض تتاستخدمها خارج الـ `config/` folder؟**
> لما بتعمل `php artisan config:cache` في الـ production — الـ config بيتخبّز في ملف واحد cached وبيتـignore الـ `.env` file تماماً. لو كتبت `env()` مباشرةً في Controller — هيرجع `null` في الـ production. الحل: `env()` بس جوّا `config/` files، وبعدين في كل حاجة تانية بتستخدم `config('key.name')`.

**س: إيه أكبر غلطة الـ Juniors عند تثبيت Laravel؟**
> غلطتان كلاسيكيتان: الأولى إنهم بيـpoint الـ Web Server على الـ root folder مش على `public/` — وده بيـexpose الـ `.env` file والـ vendor folder للعالم. الثانية إنهم بيحذفوا `.env.example` من الـ repo — فلما حد يعمل `git clone` مش بيلاقي template للـ `.env` ومش عارف الـ variables المطلوبة.

---

## 🫒 زتونة الإنترفيو

> **"Laravel هو PHP Web Framework بيطبّق الـ MVC Pattern — كل Request بتدخل من `public/index.php` وتمشي على Routes في `routes/web.php` اللي بتوجّهها للـ Controller المسؤول، الـ Controller بيستخدم Eloquent Models يتكلم مع الـ Database، وبيرجع Blade Views للـ User. الفريم ورك بُني فوق Symfony Components تحت اسم Illuminate من Laravel 4، وده بيعني إننا استفدنا من سنين من الـ battle-testing. بخصوص الـ config: القاعدة الذهبية هي إن `env()` بس بتتاستخدم داخل `config/` files، وكل الكود التاني بيتكلم مع `config()` لأن في الـ production الـ `.env` بيتـignore بعد الـ caching."**

---

*Next → الفصل 1 — الجزء الثاني: هيكل المشروع بالتفصيل + Routing الكامل (Parameters, Named Routes) + Blade Templating Engine من الـ `{{ }}` للـ Layout Inheritance*
