# 📄 File 1: `PHPDay01_Part1.md`

# 🐘 PHP Day01 – الجزء الأول: من التاريخ للـ Superglobals (تحت الكبوت)

## 🎯 الـ Core Problem اللي بنحله

PHP اتعملت عشان تبني **dynamic web pages** بسرعة من غير ما تحرق دماغك في إدارة الميموري أو التعامل مع السوكيت يدوي. الفكرة: تخلط HTML مع كود server-side يتنفذ على الأباتشي ويخرج HTML نقي.

> [!DEEP-DIVE]
> PHP مش مجرد لغة، هي **SAPI** (Server API) بتتحكم في دورة حياة الطلب. Zend Engine هو اللي بيحول الكود لـ opcodes ويشغلها. الفرق بين PHP و Node.js إن PHP synchronous من أولها، وكل request بيعمل **reset كامل للـ state** (ما عدا الـ extensions اللي بتعمل persistent connections).

---

## 📜 1. التاريخ – ليه PHP فضلت صامدة 25 سنة؟

- **1994**: Rasmus Lerdorf عمل CGI scripts باسم Personal Home Page.
- **1997**: Zeev & Andi (Zend) rewrite parser وحولوه لـ PHP: Hypertext Preprocessor.
- **1999**: Zend Engine 1.0 – بداية OOP الحقيقي.
- **2020**: PHP 8.0 مع JIT compiler.

### 🔁 مقارنة مع C++/Java/JS

| اللغة | التنفيذ | الـ state بين الـ requests |
|-------|---------|----------------------------|
| C++ (CGI) | Process per request | ولا حاجة (كل process new) |
| Java (Servlet) | Thread per request داخل JVM | Session objects |
| Node.js | Event loop (single thread) | Closure / module cache |
| **PHP** (FPM) | Process pool, each request = new process reset | Session files / Redis |

PHP شبه **CGI في العزلة** لكن مع **opcache** و **preloading** (PHP 8) بيقلل الـ overhead.

---

## 🐧 2. LAMP على Ubuntu – مش مجرد XAMPP

XAMPP للـ development بس. في production على Ubuntu:

```bash
sudo apt update
sudo apt install apache2 mysql-server php8.1 libapache2-mod-php8.1
sudo systemctl status apache2
```

### 🧠 تحت الكبوت: الـ Apache (mod_php vs FPM)

- **mod_php**: PHP مدمج داخل Apache (كل child process يضخم الميموري)
- **PHP-FPM** (modern): Process pool خارجي، Apache/Nginx يتواصل معاه via FastCGI. **الأفضل** للمواقع الكبيرة.

> [!WARNING]
> لو استخدمت XAMPP على Ubuntu، هتلبس في permissions. الأباتشي بيشتغل بـ user `www-data`. أي ملف هتعمل له upload لازم يكون مملوك لـ `www-data` أو permissions 755/644.

---

## 🧩 3. Embedding PHP وتنفيذ السيرفر

السلايدات بتقول إن PHP code يتنفذ على السيرفر والراجل ياخد HTML بس.

### 📊 Visualization – Request lifecycle

```mermaid
sequenceDiagram
    participant Browser
    participant Apache as Apache (mod_php/FPM)
    participant Zend as Zend Engine
    participant OS as Linux FS
    Browser->>Apache: GET /index.php
    Apache->>Zend: Load & parse script
    Zend->>Zend: Compile to opcodes (if not cached)
    Zend->>Zend: Execute opcodes
    Zend->>OS: fopen, mysql, session files
    OS-->>Zend: data
    Zend-->>Apache: Generated HTML
    Apache-->>Browser: HTML response
```

### 💻 مقارنة مع Node.js

في Node.js أنت بتكتب `fs.readFile` callback أو async/await. في PHP كل حاجة **blocking** implicitly:

```php
// PHP - blocking but simple
$content = file_get_contents('/tmp/data.txt');
echo $content;
```

لو عملت `sleep(5)` في PHP، كل الـ requests التانية على نفس الـ FPM process هتتأخر (لو worker واحد). عشان كده نرفع عدد الـ workers.

---

## 🏷️ 4. PHP Tags – ليه نستخدم `<?php`?

السلايدات ذكرت 4 أنواع:

| Tag | مثال | Problem |
|-----|------|---------|
| XML style | `<?php ... ?>` | **موصى به** بيشتغل في كل مكان |
| Short style | `<? ... ?>` | يحتاج `short_open_tag=On` في php.ini (خطير مع XML) |
| Script style | `<script language='php'>` | قديم، بيتعامل كـ HTML |
| ASP style | `<% ... %>` | يحتاج `asp_tags` (اتشال من PHP 7) |

**توصية هندسة**: استخدم `<?php` و `<?=` (short echo) فقط من PHP 5.4.

---

## 📝 5. Statements, Whitespace, Comments

PHP زي C++ في الـ statement termination (`;`) والـ whitespace مجرد تجاهل.

```php
// C++ style comment
# bash style (also works)
/* multi-line */
```

> [!DEEP-DIVE]
> Zend Engine زمان كان بيحتاج `;` قبل `?>`، دلوقتي مش لازم لو `?>` هي آخر حاجة في الملف. لكن أحسن تكتب ولا تحذف `?>` أبداً عشان تتجنب output buffer problems.

---

## 📅 6. `date()` – أول دالة dynamic

```php
echo "<p>Now: " . date('H:i, js F Y') . "</p>";
```

مقارنة مع Java: `new SimpleDateFormat("HH:mm, dS MMMM yyyy").format(new Date())` لكن PHP بتاخد timezone من `date.timezone` في php.ini.

على Ubuntu: `sudo nano /etc/php/8.1/cli/php.ini` وغير `date.timezone = "Africa/Cairo"`.

---

## 🌐 7. Form Variables – `$_GET`, `$_POST`, `$_REQUEST`

السلايدات بتقول إنك تقدر توصل للـ form fields بـ `$field_name` لو `register_globals = On` (إزالة تامة في PHP 5.4+). **الحل الآمن**:

```php
// HTML form method="GET"
$name = $_GET['name'] ?? '';
$password = $_POST['password'] ?? ''; // never use GET for passwords
```

### 🧠 Superglobals (الجزء الأول من القائمة)

| Array | Source | مثال |
|-------|--------|------|
| `$_GET` | URL query string | `/page.php?id=5` |
| `$_POST` | HTTP POST body (form urlencoded / multipart) | إرسال بيانات |
| `$_REQUEST` | Merge of GET, POST, COOKIE (order depends on `request_order`) | **خطر** لأنه ambiguous |

> [!WARNING]
> `$_REQUEST` في default setup بتجمع GET و POST و Cookie. لو عندك نفس الـ key في الاتنين، حاجة بتتكتب على التانية. **لا تستخدمها** في production.

### 🔁 مقارنة مع Node.js

في Express:
```js
// req.query, req.body, req.cookies
app.post('/form', (req, res) => {
  let name = req.body.name;
});
```

PHP بيعمل **parsing تلقائي** لكل request ويملأ الـ superglobals قبل ما الكود يبدأ. Zend Engine يخزنهم في hash table مخصصة.

---

## 🗃️ 8. Variables في PHP – اللي يخالف C++/Java

### القواعد الأساسية:

- كل variable بتبدأ بـ `$` (زي Perl أو Bash)
- لا تحتاج declaration، أول assignment تخلقها
- Case-sensitive (`$Name` ≠ `$name`)

```php
$txt = "Hello world!";   // string
$x = 5;                  // int
$x = "5";                // same variable now string (loose typing)
```

### 📉 Loosely Typed (أو Dynamic typing زي JS)

PHP على عكس C++ و Java، النوع بيتحدد في runtime وممكن يتغير.

**مقارنة:**

| لغة | Declaration | تغيير النوع |
|-----|-------------|--------------|
| C++ | `int x = 5;` | مستحيل (compile error) |
| Java | `int x = 5;` | مستحيل |
| JS | `let x = 5; x = "5";` | عادي |
| **PHP** | `$x = 5; $x = "5";` | عادي (لا تحذير) |

تحت الكبوت: كل variable في Zend Engine عبارة عن `zval` struct فيها union للـ types (long, double, string, array, object) مع reference counting.

> [!DEEP-DIVE]
> الـ `zval` في PHP 8 أصغر حجمًا (16 byte على 64-bit) ومفيش `refcount` للـ immutable types. لكن الـ string variables اللي بتتعدل بتعمل copy-on-write.

---

## 🌍 9. Variable Scope – الحتة اللي بتفرقع للمبرمجين اللي جايين من C++

### Local vs Global

```php
$x = 5; // global scope

function myTest() {
    $y = 5; // local scope
    // echo $x; // ERROR: global not accessible inside function
    global $x;   // bring global into function
    $x = 15;     // modifies global $x
    var_dump($x); // 15
}

myTest();
var_dump($x); // 15 (modified)
```

**الفرق عن C++**: في C++ لو عندك متغير global و local بنفس الاسم، local يخفي global. لكن PHP لازم تستخدم `global` أو `$GLOBALS` array عشان توصل للمتغير العالمي.

### Static Scope

```php
function counter() {
    static $count = 0; // initialized only first call
    $count++;
    return $count;
}
echo counter(); // 1
echo counter(); // 2
```

> [!WARNING]
> Static variables في PHP ما بتستمرش بين الـ requests (لأن كل request process جديد أو عملية FPM جديدة). لكنها بتستمر بين استدعاءات الـ function **داخل نفس الـ request**. شبه static local variables في C++.

### Parameter Scope

```php
function greet($name) {  // $name is local
    echo $name;
}
greet("Noha");
```

### Constants – بالعكس الـ variables (لا دولار)

```php
define("SITE_NAME", "ITI");
const VERSION = "1.0";
echo SITE_NAME;  // no $

// Constants automatically global (inside functions too)
function test() {
    echo SITE_NAME; // works
}
```

**المقارنة مع Java**: `public static final String SITE_NAME = "ITI";`

### Superglobals (القائمة كاملة – بعضها هنستخدمه في اللاب)

| متغير | الاستخدام |
|-------|-----------|
| `$_GET` | Query parameters |
| `$_POST` | Form POST data |
| `$_REQUEST` | Merge – avoid |
| `$_COOKIE` | HTTP cookies |
| `$_FILES` | Uploaded files (lab 01 فيه form? مش واضح، بس هنستخدمه لو احتجنا) |
| `$_SESSION` | Session variables (start with `session_start()`) |
| `$_SERVER` | Server & request info (e.g., `$_SERVER['REQUEST_METHOD']`) |

كل واحد دول array associative. تحت الكبوت: PHP بيشتغل مع **HashTable** (تنفيذ Zend لـ hash map) كفاءة عالية.

---

## 🧠 خلاصة الجزء الأول

- PHP تاريخه نابع من الحاجة لـ dynamic web pages بـ simplicity.
- LAMP على Ubuntu = Apache + PHP-FPM أفضل من XAMPP.
- Superglobals `$_GET`, `$_POST` هما المصدر الأساسي لأي input.
- Variables dynamic typing زي JS لكن مع نسخ ومراجع مختلفة.
- الـ scope system مختلف عن C++: `global` keyword و `static` داخل function.
- Constants عالمية بدون `$`.

---

# 📄 File 2: `PHPDay01_Part2.md`

# 🐘 PHP Day01 – الجزء الثاني: المتغيرات المتغيرة، المشغلين، التحكم في التدفق، و10 أسئلة مقابلة محترمة

## 🎯 مقدمة: إحنا وصلنا لفين؟

الجزء الأول خلصنا فيه التاريخ، LAMP، superglobals، variable scope.  
الجزء ده هنكمل بكل ما يخص **البيانات نفسها**: المتغيرات المتغيرة، التحويلات، الـ operators والفروق الخفية، حلقات التكرار والتحكم في التدفق.  
كل ده على Ubuntu، مع الـ Zend Engine تحت الكبوت.

---

## 🔁 10. Variable Variables – الحتة اللي مش هتلاقيها في C++/Java

السلايدات (صفحة 43) ذكرت حاجة اسمها **variable of variable**.  
يعني اسم المتغير نفسه يجي من متغير تاني.

```php
$varName = "username";
$$varName = "Noha";   // same as $username = "Noha"
echo $username;       // "Noha"
```

### 🧠 المقارنة مع اللغات التانية

| لغة | إمكانية التحكم في اسم المتغير ديناميكياً |
|------|-------------------------------------------|
| C++ | مستحيل (أسماء المتغيرات ثابتة وقت الترجمة) |
| Java | مستحيل (reflection تقدر توصل لأسماء الحقول لكن مش تغيرها) |
| JS | ممكن باستخدام `eval` أو `window[variableName]` |
| **PHP** | **مدمجة أصلاً** وبتشتغل في أي scope |

### ⚠️ تحت الكبوت – Zend Engine

لما بتكتب `$$varName`، Zend بيحسب قيمة `$varName` (وهي string) وبعدين يدور على متغير في symbol table الحالية بنفس الاسم.  
الـ symbol table في الـ function scope أو global scope هي **HashTable** اسمها `EG(current_execute_data)->symbol_table`.  
هي عملية متوسطة السرعة، لكن كتير من الـ static analyzers بتنهار لو شافتها.

> [!WARNING]
> استخدم variable variables بحرص جداً. بتخلي الكود صعب القراءة والتتبع، وبتفتح باب لـ security issues لو كنت بتستخدم input من المستخدم كاسم متغير.  
> `$evil = $_GET['field']; $$evil = 'hacked';` كارثة.

---

## 🧪 11. Variable Casting – زي C++ لكن من غير ألم

في PHP تقدر تحدد نوع مؤقت باستخدام `(type)`، زي C تماماً.

```php
$var = 5;
$floatVar = (float) $var;   // 5.0
$boolVar = (bool) $var;     // true
```

### 🧠 كأنك في C++:

```cpp
int x = 5;
float y = (float)x;
```

بس الفرق إن PHP مش بتحذرك لو فقدت بيانات (مثلاً `(int) 5.9` = 5 بدون تحذير).  
وفيه دالة `settype` بتغير النوع في نفس المتغير:

```php
$var = "123abc";
settype($var, "int");  // $var = 123
```

### 📊 Visualization – أنواع البيانات الأساسية في Zend

```mermaid
graph TD
    Z[zval] --> T[type: IS_LONG, IS_DOUBLE, IS_STRING, IS_ARRAY, IS_OBJECT, IS_NULL, IS_TRUE, IS_FALSE, IS_RESOURCE]
    T --> L[long value]
    T --> D[double value]
    T --> S[string structure with len and hash]
    T --> A[HashTable for array]
    O[IS_OBJECT] --> C[zend_object + handlers]
```

> [!DEEP-DIVE]
> PHP 8 قلب نظام الأنواع: بقى فيه `IS_TRUE` و `IS_FALSE` منفصلين عن `IS_BOOL` القديم، عشان optimize الـ type checks.

---

## 🧬 12. Variable Functions – إزاي تسأل المتغير “إنت إيه؟”

السلايدات صفحة 57-61 بتحكي عن الكشف على الأنواع.

### أشهر الوظائف:

```php
gettype($var);         // returns string: "integer", "string", "array", etc.
is_int($var);
is_string($var);
is_array($var);
is_null($var);
isset($var);           // true if exists and not null
empty($var);           // true if 0, "", null, false, [] (empty)
unset($var);           // delete variable
```

### 🔁 مقارنة مع Java

في Java بتستخدم `instanceof` للكائنات، أما primitive types فمعروفة وقت التصريح.  
في PHP كل الـ variables هي `zval`، فـ `is_int` بتروح تشوف `Z_TYPE_P(zv) == IS_LONG` تحت الكبوت.

### 🧙 `empty()` سر من أسرار PHP

```php
$zero = 0;
$emptyString = "";
$nullVar = null;
$falseBool = false;
$emptyArray = [];

var_dump(empty($zero));        // true
var_dump(empty($emptyString)); // true
var_dump(empty($nullVar));     // true
var_dump(empty($falseBool));   // true
var_dump(empty($emptyArray));  // true
```

`empty()` بتشتغل من غير ما تطلع warning لو المتغير مش موجود أصلاً.  
تحت الكبوت: بتستدعي `zend_is_true` مع فحص وجود المتغير في الـ symbol table.

> [!WARNING]
> الفرق بين `isset` و `empty`:  
> `isset($x)` => `$x` موجود و !== null  
> `empty($x)` => `!isset($x) || $x == false` (loose comparison)

---

## 🔣 13. المشغلين (Operators) – العقدة اللي بتفرق بين مطور وهاكر

### + – * / % (عادي زي C)

```php
$a = 10; $b = 3;
$sum = $a + $b;   // 13
$div = $a / $b;   // 3.333.. (float, not integer division)
```

**PHP مختلفة عن C/C++:** القسمة دايماً بترجع float لو مش مظبوطة.  
في C++ `int / int` = int. في PHP `int / int` double لو فيه كسر.

### 🔗 الـ Dot (.) للـ string concatenation – مش علامة زائد

```php
$first = "Hello, ";
$second = "World!";
$result = $first . $second;   // "Hello, World!"
```

عكس Java و JS اللي تستخدم `+`، PHP تستخدم `.` لأن `+` محجوزة للأرقام.  
لو كتبت `"5" + "3"` في PHP هتطلع 8 (تحويل إلى int)، مش "53". دي trap كتير بتقع فيها.

### ⚖️ مقارنة (Comparison) – اللي ع越长

| Operator | المعنى | Example | Loose vs Strict |
|----------|--------|---------|----------------|
| `==` | equal (loose) | `5 == "5"` | true |
| `===` | identical (type + value) | `5 === "5"` | false |
| `!=` or `<>` | not equal | `5 != "5"` | false |
| `!==` | not identical | `5 !== "5"` | true |
| `<=>` | spaceship (PHP 7) | `5 <=> 10` | -1 (less) |

#### 🚀 Spaceship operator (`<=>`)

```php
echo 5 <=> 10;   // -1 (left < right)
echo 10 <=> 10;  // 0  (equal)
echo 15 <=> 10;  // 1  (left > right)
```

مفيد جداً في الـ sorting custom functions. شبه `compare` في C++ `std::strong_ordering`.

### 📘 Loose comparison (==) جدول لازم تحفظه:

```php
var_dump(0 == "abc");    // true? in PHP, yes because "abc" becomes 0
var_dump("" == 0);       // true
var_dump("123" == 123);  // true
var_dump(null == false); // true (both falsy)
```

> [!WARNING]
> الـ loose comparison سبب من أكبر أسباب الثغرات. استخدم `===` و `!==` دائماً إلا لو عندك سبب مقنع جداً.

### 🤝 Reference Operator (&)

```php
$a = 5;
$b = &$a;   // $b is reference to $a
$a = 7;
echo $b;    // 7
unset($a);  // removes $a but $b still holds 7
```

الفرق عن C++: في C++ الـ reference مستحيل تعيد ربطه، لكن في PHP ممكن:

```php
$a = 5; $b = 10;
$x = &$a;
$x = &$b;   // now $x references $b
```

تحت الكبوت: الـ reference في PHP بتنفذ باستخدام `zend_reference` struct فيها `zval` و `refcount`.  
لما تعمل `$b = &$a`، Zend بتحول `$a` لـ reference إذا لزم الأمر.

### ➕ Pre/Post increment – نفس C تماماً لكن مهم

```php
$i = 4;
echo ++$i;   // 5, $i = 5
$i = 4;
echo $i++;   // 4, $i = 5
```

### 🧹 Error suppression operator `@`

```php
$result = @(25 / 0);   // No warning, $result = false?
var_dump($result);     // false
```

تحت الكبوت: `@` بيخلي الـ error handler يتجاهل الخطأ عن طريق زيادة `EG(no_error)` flag. لكنه بيخفي حاجات كتير، استخدمه فقط في أماكن قليلة جداً (زي قراءة ملف قديم `@unlink`).

---

## 🔁 14. Control Flow – نفس C لكن بزيادات

### if / elseif / else

```php
if ($age >= 18) {
    echo "Adult";
} elseif ($age >= 13) {
    echo "Teen";
} else {
    echo "Child";
}
```

الفرق عن C: `elseif` (كلمة واحدة) مش `else if` بس الاتنين بيشتغلوا.

### switch – لازم break

```php
switch ($color) {
    case "red":
        echo "danger";
        break;  // if no break, fallthrough
    case "green":
        echo "success";
        break;
    default:
        echo "unknown";
}
```

PHP 8 match expression (أقوى): لا يحتاج break, بيرجع value.

```php
$result = match($status) {
    200, 201 => "OK",
    404 => "Not Found",
    default => "Unknown"
};
```

### for loop

```php
for ($i = 0; $i < 10; $i++) {
    echo $i;
}
```

### foreach – أهم حاجة في PHP

```php
$fruits = ["apple", "banana", "cherry"];
foreach ($fruits as $fruit) {
    echo $fruit;
}

// with key
foreach ($fruits as $index => $fruit) {
    echo "$index: $fruit";
}
```

تحت الكبوت: `foreach` بتستخدم internal array pointer، لكن PHP 7+ بيعمل copy on write. لو غيرت الـ array جوه الـ foreach، أحياناً بيعمل duplication.

### while / do-while

```php
$i = 0;
while ($i < 10) {
    echo $i++;
}

do {
    echo $i;
} while ($i < 10);
```

### break, continue, exit

```php
for ($i = 0; $i < 10; $i++) {
    if ($i == 4) break;      // exit loop
    if ($i == 2) continue;   // skip to next iteration
}
exit;  // stop entire script
```

الفرق بين `break` و `exit`:  
- `break` بيخرج من أعمق loop أو switch.  
- `exit` أو `die()` بيوقف تنفيذ الـ script بالكامل ويرسل response.

---

## 🧠 خلاصة الجزء الثاني

- Variable variables: dynamic variable names بمخاطرة.
- Type casting و checking functions هما الأساس في الـ defensive coding.
- Operators: لاحظ الفرق بين `==` و `===` و `<=>`.
- Reference (`&`) تشبه reference في C++ لكن أكثر مرونة.
- Control flow قريب جداً من C مع إضافة `foreach` القوية.

---

## 📚 10 أسئلة انترفيو (Interview Questions) تغطي المحاضرة كاملة

### سؤال 1 (History + LAMP)  
**"ليه PHP بنستخدمه مع Apache أو Nginx مش standalone زي Node.js؟"**  
> الإجابة: PHP معمول أصلاً كـ SAPI (Server API) بيتنفذ ضمن web server عبر mod_php أو FPM. ممكن تشغله standalone باستخدام built-in server (`php -S localhost:8000`) بس ده مش production-ready. Node.js مبني من الأول على event loop يسمح بكونه server مستقل. طبيعة PHP synchronous بتناسب المعالجة القصيرة للـ requests مع إعادة ضبط كامل للـ state بعد كل request، فوجوده داخل Apache/Nginx بيوفر process management و load balancing.

### سؤال 2 (Superglobals)  
**"إيه الفرق بين `$_GET` و `$_POST` و `$_REQUEST`، وإمتى تستخدم `$_REQUEST`؟"**  
> الإجابة: `$_GET` للبيانات في URL، `$_POST` للبيانات في body (غير visible). `$_REQUEST` بتجمع الثلاثة حسب ترتيب `variables_order` في php.ini (عادة GPCS). `$_REQUEST` خطر لأن ممكن تتعارض القيم وتسبب ambiguity، وأيضاً قد تحتوي على cookies مما يعرض لـ session fixation. لا تستخدمها إلا لو عندك سبب واضح جداً.

### سؤال 3 (Variable scope)  
**"عندنا متغير خارج function، إزاي نعدله من جوه function من غير استخدام `global` keyword؟"**  
> الإجابة: باستخدام `$GLOBALS` array: `$GLOBALS['x'] = 15;`. ده بديل `global $x;`. الفرق إن `$GLOBALS` بيوصل لأي متغير عالمي بدون ما تعمل import. تحت الكبوت: `global $x;` بتضيف reference في symbol table المحلية.

### سؤال 4 (Variable variables)  
**"ما هي الـ variable variables، وهل لها مثيل في Java أو C++؟"**  
> الإجابة: هي متغيرات بيتم تحديد اسمها من خلال محتوى متغير تاني (`$$varName`). لا يوجد مكافئ مباشر في C++/Java. في Java ممكن تحاكيها باستخدام Map<String, Object>، وفي C++ باستخدام unordered_map<string, any>. لكن PHP بتقدمها كلغة ديناميكية.

### سؤال 5 (Type juggling)  
**"أكتب مثال يوضح الفرق بين `==` و `===` في PHP مع شرح السلوك غير المتوقع؟"**  
> الإجابة: `0 == "abc"` ترجع true لأن PHP بتحاول تحويل الـ string "abc" إلى integer فتعطي 0. `0 === "abc"` ترجع false لأن النوع مختلف (int vs string). مثال آخر: `"" == 0` = true، `"" === 0` = false. الـ loose comparison ممكن يستغل في تجاوز checks.

### سؤال 6 (References)  
**"كيف تعمل الـ references في PHP تحت الكبوت، وما الفرق بينها وبين الـ pointers في C++؟"**  
> الإجابة: الـ reference في PHP عبارة عن `zend_reference` struct مع refcount. لما تعمل `$b = &$a`، Zend بتربط `$b` بنفس `zval` بعد تحويله لـ reference type. الفرق عن C++: reference في C++ لا تعاد ربطها (rebindable)، لكن في PHP ممكن. أيضاً في PHP مش محتاج `*` أو `&` في الاستخدام، syntax أنظف.

### سؤال 7 (Superglobals + forms)  
**"كيف تتعامل مع form submission فيها method="GET" و method="POST" بأمان؟"**  
> الإجابة: استخدم `$_GET` والقيم تظهر في URL فلا تضع بيانات حساسة. استخدم `$_POST` للبيانات الخاصة وكلمة المرور. دائماً filter المدخلات: `filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL)`. و escape المخرجات: `htmlspecialchars($_POST['name'], ENT_QUOTES, 'UTF-8')`.

### سؤال 8 (Operators + side effects)  
**"ما هو الـ spaceship operator (`<=>`)، ومتى ظهر، وكيف يبسط المقارنات؟"**  
> الإجابة: ظهر في PHP 7. يرجع -1 إذا القيمة اليسرى أقل، 0 إذا متساويتين، 1 إذا اليسرى أكبر. بينفع جداً في `usort`: `usort($array, fn($a, $b) => $a <=> $b);` بدل كتابة if statements.

### سؤال 9 (Variable functions + isset/empty)  
**"إيه الفرق بين `isset($x)` و `empty($x)` و `is_null($x)` مع أمثلة؟"**  
> الإجابة:  
> - `isset($x)` → true إذا $x موجودة و ≠ null.  
> - `empty($x)` → true إذا $x غير موجودة أو قيمتها falsy: 0, "", null, false, [], "0".  
> - `is_null($x)` → true فقط إذا $x = null، ولكن لو $x غير معرفة تطلع warning.  
> مثال: `$x = 0;` → isset=true, empty=true, is_null=false.

### سؤال 10 (Server-side vs Client-side)  
**"فيمَ يختلف تنفيذ كود PHP عن تنفيذ JavaScript من ناحية البيئة وthreading وإدارة الذاكرة؟"**  
> الإجابة: PHP script يتنفذ على السيرفر مرة واحدة لكل request، وكل request يبدأ ببيئة جديدة (process في FPM أو thread في mod_php قديم). الذاكرة بتتحرر بعد نهاية الطلب تلقائياً (request-bound). JavaScript في المتصفح أو Node.js يعيش في event loop طويل، والذاكرة (closures, variables) بتفضل موجودة طالما الـ context موجود. PHP ما فيهاش shared memory بين requests بدون أدوات إضافية (مثل Redis). الـ concurrency في PHP بالعمليات المتعددة، في Node.js بالـ async I/O على thread واحد.

---

[أنا خلصت الشرح النظري بالكامل.. قولي "هات اللاب" عشان أكتبلك حلول الـ Labs بأسلوب الـ Production]