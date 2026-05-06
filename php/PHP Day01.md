هات كوباية الشاي بتاعتك يا هندسة.. ويلا بينا نبدأ حكاية الـ PHP من تحت الكبوت!

# 🐘 PHP: الحكاية الكاملة من قلب السيرفر - اليوم الأول

## 🌍 مقدمة: إحنا بنحكي حكاية وادي النيل والسيرفرات

تعالَ نفتكر زمان.. أيام ما كنا بنبني مواقع ثابتة بالـ HTML زي المقابر الفرعونية.. ما تتغيرش، ما تتنفسش. جيت تقول "عايز أعرض الوقت والتاريخ"؟ كنت ت rewrite الموقع كله وت re-upload. السيناريو المرعب ده كان هو الواقع اليومي لأي مطور ويب لحد ما ظهر الأب الروحي: **Rasmus Lerdorf** في سنة 1994.

وادي النيل خلق مننا حكايين.. وأنا هنا مش هاشرح لك PHP زي أي كورس عادي. لأ.. أنا هاخدك في **رحلة داخل السيرفر**، معاك تحت الكبوت، نشوف إزاي كل سطر بتكتبه بيتحول من مجرد كلام في ملف لأوامر بتتنفذ على قلب الـ CPU.

قبل ما نلمس أي كود، لازم تفهم **الرحلة الأسطورية** لأي فايل PHP من لحظة ما تضغط Enter في المتصفح لحد ما تشوف النتيجة قدام عينيك.

---

## 🚀 رحلة الفايل: من الكيبورد لحد شاشة العميل

تخيل معايا السيناريو ده:

أنا جالس على جهازي اللاب توب (ويندوز أو أي حاجة)، فاتح Chrome، وكتبت في الـ URL: `http://myawesome.com/index.php`

### 🧭 الخطوة 1: الطلب يمشي في السلك

المتصفح بيعمل طلب HTTP من نوع GET على البورت 80 (أو 443 لو HTTPS). الطلب ده بيعدي على الـ DNS، يوصل لسيرفر الأوبونتو الذي عليه موقعك.

السيرفر ده شغال عليه برنامج ويب سيرفر زي **Apache** أو **Nginx**. تخيل إنه زي بواب عاقل جدًا، بيستقبل الطلبات ويشوف هيعمل إيه.

```bash
# مثال لطلب HTTP خام من المتصفح لو فتحته بالـ DevTools
GET /index.php HTTP/1.1
Host: myawesome.com
User-Agent: Chrome/...
```

### 🚪 الخطوة 2: الـ Web Server يقرر مين المسؤول

أباتشي بيقرأ ملف الكونفيج بتاعه. بيشوف إن الملف طلبه له امتداد `.php`، فالبواب بيقول: "أنا مش فاهم PHP خالص.. ده لغة سكريبت. لازم أستدعي المترجم الفوري بتاعها."

وهنا تيجي قصة **PHP-FPM** أو **mod_php** حسب الإعدادات.

في العالم الحديث (وبالأخص على أوبونتو)، بنستخدم PHP-FPM (FastCGI Process Manager).

تخيل إن PHP-FPM عبارة عن **مصنع صغير مخصص لتنفيذ PHP**. فيه عمّال (processes) واقفين على أهبة الاستعداد. أباتشي بيروح يدق الباب على PHP-FPM عبر socket أو port، ويقول له: "خد يا معلم ملف `index.php` ده ونفذه لي".

### ⚙️ الخطوة 3: PHP-FPM يتسلم الملف ويتنفس في الروح

الـ PHP-FPM بياخد المسار الكامل للملف على الهارد ديسك (`/var/www/myawesome.com/index.php`). بيقرأ محتواه كـ string. وده أول تفاعل لـ **Zend Engine** مع الكود.

هنا هنعمل أول **Mermaid Diagram** يوضح الرحلة لحد دلوقتي:

```mermaid
flowchart TD
    A[المتصفح:<br/>Chrome/Firefox] -->|HTTP Request<br/>GET /index.php| B[Web Server<br/>Apache/Nginx]
    B -->|Pass request to<br/>PHP-FPM via FastCGI| C[PHP-FPM<br/>Process Manager]
    C -->|Read file from disk<br/>/var/www/.../index.php| D[Zend Engine<br/>(Brain of PHP)]
    D -->|Lexical & Syntax Analysis| E[Parse to Tokens]
    E -->|Compilation| F[Opcodes<br/>(Intermediate Code)]
    F -->|Execution| G[Output Buffer]
    G -->|HTML Response| B
    B -->|HTTP Response| A
```

### 🔧 الخطوة 4: Zend Engine – العقل اللي بيحول الكود لتعليمات

الـ Zend Engine ده بقى هو قلب PHP النابض. مشروع مستقل اشتغل عليه **Zeev Suraski** و **Andi Gutmans** في 1997 ليعيدوا كتابة الـ parser بالكامل. من غيره PHP ما كانت هتبقى حاجة.

تعالى نشوف إزاي Zend بيشوف ملف PHP:

#### 4.1 الـ Lexing (تحليل معجمي)
الـ Engine بيقرأ الكود حرف حرف. بيحول كل كلمة (مثلاً `echo` أو `$var` أو `;`) إلى **Token**. تخيل أن Token عبارة عن بطاقة تعريف فيها نوع الكلمة وقيمتها.

مثال: الكود `<?php echo "Hello";`

بيتحول إلى:

- `T_OPEN_TAG` -> `<?php`
- `T_ECHO` -> `echo`
- `T_WHITESPACE` -> `' '`
- `T_CONSTANT_ENCAPSED_STRING` -> `"Hello"`
- `T_SEMICOLON` -> `;`

#### 4.2 الـ Parsing (تحليل نحوي)
بعد ما يطلع tokens، يدخل على الـ parser اللي بيطبق قواعد اللغة. لو الكود فيه غلط نحوي (زي نسيت نقطة ونص)، هنا هيطلع error مشهور: `Parse error: syntax error, unexpected ...`

لو الكود سليم، الـ parser بيبني **شجرة تركيب مجردة (AST – Abstract Syntax Tree)**. الشجرة دي بتمثل هيكلية الكود، مين جوا مين.

#### 4.3 الـ Compilation إلى Opcodes
الـ AST بعد كده بيتحول إلى **Opcodes**، وهي تعليمات منخفضة المستوى مفهومة لآلة التنفيذ الافتراضية Zend VM.

الـ Opcode بقى زي لغة Assembly بس خاصة بـ PHP.

مثلاً `echo` تتحول إلى `ZEND_ECHO` و `+` تتحول إلى `ZEND_ADD`.

#### 4.4 الـ Execution
الـ Executor (جزء من Zend VM) بياخد الـ Opcodes ويبدأ ينفذها واحدة واحدة. كل Opcode بيقول للـ VM تعمل حاجة معينة: تاخد قيم متغيرات، تجمع أرقام، تخرج نص، إلخ.

**أثناء التنفيذ** الـ VM بتتعامل مع الذاكرة الرئيسية (RAM)، وبتستخدم stack و heap للمتغيرات.

الـ Zend Engine ذكي جدًا.. فيه حاجة اسمها **Opcache** (متاحة من PHP 5.5). الـ Opcache بيخزن الـ Opcodes المتكونة في الذاكرة المشتركة عشان لو الملف اترجع تاني، ما يحتاجش يعيد parsing و compilation. يروح يجيب الـ Opcodes على طول ويبدأ تنفيذ. ده بيسرع الموقع أضعافًا.

#### 4.5 التعامل مع الـ Output
أثناء التنفيذ، أي حاجة بتتعمل لها `echo` أو `print` أو نص خارج PHP tags بيروح في **Output Buffer**. تقدر تتحكم في البفر ده بـ `ob_start()` بس ده حكاية تانية. في الآخر كل النص بيتجمع في Response Body.

### 📦 الخطوة 5: الرجوع للـ Web Server وإرسال الرد

بعد ما التنفيذ يخلص، PHP-FPM بيرجع الـ HTML الناتج (مع headers زي Content-Type) إلى الـ Web Server. أباتشي ياخد الرد ويضيف عليه headers تخصه، ويرسله بالكامل إلى المتصفح.

المتصفح يستلم النص ويتفهم إنه HTML ويعرضه للمستخدم. والرحلة تنتهي (مؤقتًا).

---

دى كانت أول **رحلة تحت الكبوت**. حطها في دماغك.. لأن كل حاجة هنتكلم عنها لاحقًا هتحصل **في الـ Execution Environment** ده.

دلوقتي نبدأ نغطي المحتوى اللي أنت جاي عشانه. نفتكر التاريخ، نشوف إيه حكمة PHP، ونغوص في المتغيرات والعمليات.

---

## 📜 1. تاريخ PHP – من Personal Home Page لثورة ويب

تعالى أحكيلك الحكاية من الأول:

في سنة 1994، كان فيه مبرمج اسمه **Rasmus Lerdorf** (جرينلاندي/دنماركي). كان عايز يتتبع مين بيزور صفحته الشخصية على الإنترنت (زي الـ CV بتاعه). استخدم لغة Perl في الأول، لكن لقاها تقيلة.

قرر يكتب مجموعة من الـ CGI scripts بلغة C تسمح له بمعالجة بسيطة للـ forms والوصول للقاعدة. أسماهم "Personal Home Page Tools".

سنة 1995، أعلن عن الكود بتاعه عشان الناس تستفيد. السكريبتات كانت بدائية جدًا، لكنها جابت انتباه عالم صغير من المطورين.

**ثورة 1997**: اتنين مطورين إسرائيليين من Technion IIT، **Zeev Suraski** و **Andi Gutmans**، كانوا بيستخدموا PHP لكن حسوا إن الـ parser الأصلي بقى ضعيف. فكتبوا parser جديد من الصفر، وأسسوا PHP 3.

غيروا الاسم من Personal Home Page لـ **PHP: Hypertext Preprocessor** (نوع من الـ recursion المضحك).

في 1999، عملوا rewrite كامل للـ core وأنتجوا **Zend Engine** (من أسمائهم Zeev + Andi). وأسسوا شركة Zend Technologies اللي لسه قايمة لحد دلوقتي وتدير تطور PHP.

ومن ساعتها والنسخة بتتطور (PHP 4 بقى فيه Zend Engine 1.0، PHP 5 جاب الـ object-oriented model الكامل، PHP 7 قفزة أداء هائلة بفضل JIT وتغيير بنى البيانات، وصولاً لـ PHP 8.0 اللي فيه JIT أقوى وأنواع أكثر).

**ليه PHP 8 مميز؟** فيه حاجة اسمها **JIT (Just In Time compilation)**. الـ JIT بقى يقدر يحول الـ opcodes لـ كود آلة (machine code) في وقت التنفيذ، ويسرع العمليات الحسابية الثقيلة جدًا. ده فتح الباب لاستخدام PHP في الـ machine learning والحوسبة الرقمية بشكل أفضل.

---

## ❤️ 2. ليه PHP بقى؟ (إجابة من قلب الميدان)

أنا هديك الدوافع الحقيقية لاختيار PHP كمهندس معماري:

### 2.1 سهولة التعلم (Ease of Learning)
PHP متسامح جدًا في البداية. ما تحتاش تعرف إيه الذاكرة، تتعامل مع pointers زي C. المتغيرات بتنزل بالـ `$` وبتنتهي بـ `;` زي C لكن بدون صرامة. أي حد يعرف HTML يقدر يدمج PHP في خلال نص ساعة.

### 2.2 الدعم الكائنات (Object-Oriented Support)
من PHP 5 الكامل بقى فيه OOP حقيقي: classes, inheritance, interfaces, traits, abstract classes, final, و namespace. PHP 8 جاب الـ attributes (Annotations) و union types و match expression.

### 2.3 قابلية الحمل (Portability)
الكود اللي تكتبه على Windows هيشتغل على Linux و macOS و Solaris. أنت بتكتب مرة، والسيرفرات بتضمن التنفيذ. (عكس بعض التقنيات .. لكن مش هنقارن).

### 2.4 المصدر المفتوح (Open Source)
الكود بتاع PHP نفسه (Zend Engine) متاح على GitHub. تقدر تفتح issue، تقدم PR، أو حتى تعدل الـ C وتعمل build خاص بيك. إنت مش مربوط بفيندر.

### 2.5 دعم هائل (Support and Documentation)
الموقع الرسمي `php.net` بمثابة القرآن. لكل دالة صفحة فيها أمثلة وتفاصيل وتاريخ الإصدار وتعليقات المطورين. فيه مجتمعات عربية وأجنبية ضخمة.

### 2.6 متعدد المنصات والـ databases
يتواصل مع MySQL و PostgreSQL و SQLite و MongoDB وحتى Oracle. فيه PDO اللي بيوحد التعامل مع قواعد البيانات.

### 2.7 بيئة التطوير المتكاملة (XAMPP / LAMP / WAMP / MAMP)

تعالى ناخد **LAMP** كمثال:

- **L**inux – نظام التشغيل (تقدر تستخدم Ubuntu Server).
- **A**pache – ويب سيرفر.
- **M**ySQL (أو MariaDB) – قاعدة البيانات.
- **P**HP – لغة البرمجة.

لما تنزل حزمة زي **XAMPP** (على ويندوز) أو **LAMP** بتاعت Bitnami (على لينكس)، أنت بتحصل على كل حاجة معبأة. تنصيبها سهل جدًا. بعدين تفتح المتصفح وتكتب `http://localhost` وتشوف "It works!".

**اختبار بسيط لـ PHP:**

اعمل ملف `/var/www/html/info.php` (على لينكس) أو `C:/xampp/htdocs/info.php` (ويندوز)، وحط فيه:

```php
<?php
phpinfo();
?>
```

تفتح المتصفح على `http://localhost/info.php` – هتشوف صفحة ضخمة كل تفاصيل إعدادات PHP والسيرفر. أمان مهم: امسح الملف بعد ما تخلص لأنه بيكشف معلومات حساسة.

**نوع الملف:** امتداده `.php` أو `.phtml`، وبيحتوي على خليط من HTML و JavaScript و CSS و PHP. الفرق إن أي كود PHP بين `<?php ?>` بيتنفذ على السيرفر.

---

## 💡 3. PHP تقدر تعمل إيه؟ (قائمة القدرات)

- **توليد محتوى ديناميكي:** زي عرض الوقت، أو إحصائيات المستخدم، أو منشورات بلوج.
- **فتح وكتابة الملفات على السيرفر:** تقدر تقرأ ملف `file.txt` وتكتب فيه جديد.
- **جمع بيانات الفورم:** المستخدم يبعت بياناته، PHP تستقبل وتعالج وتخزن.
- **إرسال واستقبال Cookies:** تذكر المستخدمين وتسجل دخولهم.
- **التعامل مع قواعد البيانات:** إضافة، حذف، تعديل.
- **تقييد وصول المستخدمين:** صفحات مخفية، صلاحيات.
- **تشفير البيانات:** عبر `openssl_encrypt`.

كل ده بيحصل على السيرفر، والمستخدم النهائي بيشوف بس HTML نقي.

---

## 🏷️ 4. تضمين PHP في HTML

الصورة التقليدية لملف `.php` إنه غالبًا HTML وبعض الأجزاء اللي مكتوب فيها PHP.

```php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Welcome to PHP</title>
</head>
<body>
    <h1><?php echo "Welcome to my website"; ?></h1>
</body>
</html>
```

الـ PHP interpreter (اللي بيشتغل ورا الكواليس داخل Zend Engine) بيمسح على الفايل ويبحث عن `<?php` و `?>`، أي حاجة برا الـ tags بيتم التعامل معاها كـ HTML static، أي حاجة جوه البداية والنهاية بيحولها output من السكريبت.

**طيب إزاي السيرفر بيعرف الفرق؟** هو مفيش فرق حقيقي.. الـ interpreter بيحول الملف كله لـ tokens، وأي نص خارج PHP tags بيتحول إلى `T_INLINE_HTML` token، وأثناء التنفيذ بيتم `echo` الضمني له.

---

## 🏷️ 5. علامات PHP المختلفة (PHP Tags)

PHP بتدعم أكتر من أسلوب لفتح وإغلاق الكود:

### ✅ أسلوب XML (موصى به)
```php
<?php echo 'Hello'; ?>
```
ده اللي بنستخدمه. لأنه مضمون إنه يشتغل على كل السيرفرات، ومحدش يقدر يقفله من php.ini.

### ⚠️ الأسلوب القصير (Short style)
```php
<? echo 'Hello'; ?>
```
**ملاحظة خطيرة:** عشان ده يشتغل، لازم تكون الإعداد `short_open_tag = On` في `php.ini`. كثير من السيرفرات بتقفله لأنه بتعارض مع XML declaration `<?xml`.

### 📜 أسلوب SCRIPT (نادر)
```php
<script language='php'> echo 'Hello'; </script>
```
طويل وقديم. متستخدمش.

### 🚫 أسلوب ASP (مهمل)
```php
<% echo 'Hello'; %>
```
كان بيستخدمه اللي جايين من ASP، لكن دلوقتي محتاج `asp_tags = On` (اتشال من PHP 7).

**الأمر الموصي به:** دايما اكتب `<?php` و `?>`.

---

## 📏 6. الجمل والتعليمات والفراغات

كل تعليمة PHP بتخلص بفاصلة منقوطة `;`.

```php
echo 'Hello';
$name = 'Noha';
```

الفراغات (white spaces) زي المسافات، الأسطر الجديدة، التاب، كلها بتتجاهل من الـ PHP engine والمتصفح بيجمعها في صفحة واحدة.

يعني الكتابة:
```php
echo 'Hello ';
echo 'World';
```
معناها نفس `echo 'Hello '; echo 'World';`

نصيحة مهنية: استخدم فراغات عشان readability.

---

## 💬 7. التعليقات (Comments)

التعليقات مش بتنفذها PHP، فقط للبشر.

```php
/* هذا تعليق متعدد الأسطر
   C-style 
   Prepared by Noha Shehab */

// هذا تعليق سطر واحد C++ style

# هذا تعليق سطر واحد Unix style
```

**تطبيق عملي:** لما تعمل debugging، استخدم `/* */` لتكبيس جزء من الكود ولما تخلص فكه.

---

## ⏱️ 8. ديناميكية التاريخ والوقت

PHP عندها دالة `date('format')` بتجيب الوقت الحالي من السيرفر (حسب timezone المحدد في php.ini).

```php
echo "<p>Now, Its ";
echo date('H:i , jS F Y');
echo "</p>";
```

لو شغال على سيرفر في مصر، هيظهر الوقت بتاع مصر. `H:i` للـ 24 ساعة، `jS` رقم اليوم مع الترتيب (1st, 2nd, 3rd...)، `F` اسم الشهر كامل، `Y` السنة بأربع أرقام.

تغيير التايم زون: استخدم `date_default_timezone_set('Africa/Cairo')`.

---

## 📝 9. متغيرات الفورم (Form Variables)

تخيل عندك HTML form، والـ action بتاعها بيشاور على `form.php`. إزاي تستقبل البيانات؟

**أولًا: الفورم HTML** (حفظ باسم `form.html`)

```html
<!DOCTYPE html>
<html>
<body>
<form action="form.php" method="GET">
    <input type="text" name="name">
    <input type="password" name="password">
    <input type="submit">
</form>
</body>
</html>
```

**ثانيًا: معالج PHP** (`form.php`)

```php
<?php
var_dump($_GET);
?>
```

**السيناريو:** لما تبعث الفورم، المتصفح يبني GET request بـ query string (لو method GET). مثلاً: `form.php?name=Ahmed&password=123`. PHP بتخزن هذه القيم في **superglobal array** اسمها `$_GET`.

نفس الكلام مع `method="POST"` استخدم `$_POST`.

**استخدام `$_REQUEST`**: دي بتجمع `$_GET` و `$_POST` و `$_COOKIE` معًا. لكن مش دقيقة للأمان، الأفضل تستخدم النوع المحدد.

**فين التوثيق:** دايماً PHP تخلق المتغيرات بدون `register_globals` (اتشال من PHP 5.4). يعني ما تفكرش انك توصل لـ `$name` مباشرة. دايمًا استخدم `$_GET['name']`.

---

## 📦 10. المتغيرات والحرفيات (Variables and Literals)

**Literal:** القيمة نفسها زي `5` أو `"Hello"`.

### الفرق بين السلسلتين المزدوجة والمفردة

#### "مزدوجة" (Double quote)
بتتعامل مع `$variable` وتحاول تحللها (تقييمها).

```php
$name = "Noha";
echo "Hello $name"; // Hello Noha
```

#### 'مفردة' (Single quote)
بتعتبر النص حرفي (literal) بدون معالجة.

```php
echo 'Hello $name'; // Hello $name
```

لما تستخدم escape sequences في المزدوجة زي `\n` (سطر جديد) أو `\t` (تب)، في المفردة معظم escapes مش شغالة إلا `\\` و `\'`.

**أداء:** السلسلة المفردة أسرع قليلاً لأن الـ parser مش بيدور على متغيرات. استخدم المفردة إلا لو محتاج interpolation للمتغيرات.

---

## 🔤 11. معرفات المتغيرات (Identifiers)

قواعد بسيطة:

1. أي طول، مكونة من أحرف (a-z, A-Z، وأحرف غير لاتينية لكن بلاش)، أرقام، وشرطة تحت `_`.
2. لا تبدأ برقم.
3. Case-sensitive (يعني `$myVar` غير `$myvar`).
4. المتغير بيبدأ بـ `$` ثم الاسم.

```php
$validVariable = 5;
$_another_valid = 10;
$var123 = 15;

// ممنوع
// $123var = 0;  
// $my var = 10; // مسافة ممنوعة

```

PHP مش بيفرض نوع المتغير – ونشوف السبب بعد شوية.

---

## 💰 12. إنشاء أول متغير

```php
$txt = "Hello world!";
$x = 5;
$floating = 7.5;
```

الحظ: ما فيش `var $txt;` زي JavaScript ولا `int x = 5;` زي C. PHP هو loosely typed: المتغير بياخد نوعه تلقائيًا من القيمة اللي اتخزنت فيه.

عند تنفيذ `$txt = "Hello"` الـ Zend Engine بيعمل allocation في heap لل string ويخزن المؤشر في جدول الرموز (symbol table).

---

## ⚖️ 13. PHP: لغة مرنة الأنواع (Loosely Typed)

الموضوع بسيط: المتغير في PHP عبارة عن **حاوية** من نوع `zval` (Zend Value) في لغة C. الـ `zval` فيها بيانات عن النوع والقيمة الحقيقية. لما تعمل `$x = 5`، الـ `zval` يجعل النوع IS_LONG. بعد كده تعمل `$x = "five"`، النوع يتحول لـ IS_STRING. PHP بتحول تلقائي حسب السياق.

الـ strongly typed زي C# لازم تعلن النوع مرة واحدة ويبقى ثابت.

PHP 7+ أدخلت إمكانية الـ **declaration type** للدوال وخصائص الكلاس، لكن لسه في الجمل العادية المتغير يتحول بحرية.

---

## 🔭 14. نطاق المتغيرات (Variable Scope)

النطاق بيحدد منين تقدر تستخدم المتغير. تعالا نتعمق مع سيناريوهات واقعية.

### 📍 النطاق المحلي (Local Scope)

أي متغير بيتعرف **داخل دالة**، بيكون محليًا فيها فقط.

```php
function myTest() {
    $y = 5;      // محلي للدالة
    echo $y;     // 5
}
myTest();
echo $y; // خطأ: undefined variable $y
```

لما بتنتهي الدالة، الـ memory الخاصة بـ $y بتتحرر (إلا لو استخدمنا static).

### 🌍 النطاق العام (Global Scope)

المتغير اللي يتعرف برا أي دالة (في الـ script root) بيبقى global scope. لكن فين المشكلة؟ **الدوال مش بتشوف المتغيرات العالمية بصفة افتراضية**.

```php
$x = 5; // global

function myTest() {
    echo $x; // Warning: undefined variable $x (هيطلع فارغة)
}
myTest();
```

**الحل: الكلمة المفتاحية `global`**

```php
$x = 5;
function myTest() {
    global $x;
    echo $x; // 5
    $x = 15; // بتعدل الـ global برضه
}
myTest();
echo $x; // 15
```

الـ global بتقول لـ Zend Engine: "داخل هذه الدالة، أي استخدام لـ $x يرجع للمتغير العالمي، مش تنشي واحد محلي."

**طريقة تانية: مصفوفة `$GLOBALS`**

```php
$x = 5;
function myTest() {
    $GLOBALS['x'] = 20;
}
myTest();
echo $x; // 20
```

`$GLOBALS` دي superglobal array دايماً متاحة، وفيها كل المتغيرات العالمية.

### 🔒 النطاق الثابت (Static Scope)

تخيل دالة بتعد عداد. كل مرة تنادى، العداد يزيد. لكن المتغير المحلي بيتحذف بعد تنفيذ الدالة. هنا تظهر `static`:

```php
function counter() {
    static $count = 0;
    $count++;
    echo $count;
}
counter(); // 1
counter(); // 2
counter(); // 3
```

المتغير الثابت بيتم تهيئة مرة واحدة فقط عند أول استدعاء، وبعد كده بيحتفظ بقيمته بين الاستدعاءات. هو لسه محلي (مش عالمي)، لكن الذاكرة بتاعته ما بتتحررش.

**إزاي شغال تحت الكبوت؟** الـ Zend Engine بيسجل المتغير الثابت كجزء من الـ function entry، ويكون موجود في الذاكرة في منطقة مستقلة.

### 🧷 النطاق الوسيطي (Parameter Scope)

المعلمات اللي بتعديها للدالة هي متغيرات محلية ضمن الدالة:

```php
function greet($name) {
    echo "Hello $name";
}
greet("Noha"); // Hello Noha
// $name غير معرف خارج الدالة
```

### 🌌 السوبر جلوبال (SuperGlobal)

موجود في كل مكان بلا استثناء. دول مصفوفات مدمجة (built-in arrays) فيها بيانات الطلب والجلسة:

- `$_GET` : parameters from query string (method GET)
- `$_POST` : parameters from POST request
- `$_REQUEST` : تجميع GET, POST, COOKIE معًا (الأمر مثير للجدل)
- `$_COOKIE` : cookies المرسلة من المتصفح
- `$_FILES` : بيانات الملفات المرفوعة
- `$_SESSION` : بيانات الجلسة (اللى بتتخزن عالسيرفر)
- `$_SERVER` : معلومات عن السيرفر والطلب
- `$GLOBALS` : كل المتغيرات العالمية.

### 🧠 ملخص قواعد النطاق الستة (من الشرائح):

1. المتغيرات العامة مرئية في كل السكربت ولكن ليس داخـل الدوال (ما لم تستخدم global).
2. المتغيرات العامة داخل الدوال بـ `global` تشير لنفس المتغير العام.
3. المتغيرات الثابتة داخل الدوال غير مرئية خارجها، لكنها تحتفظ بقيمتها بين الاستدعاءات.
4. المتغيرات المنشأة داخل الدوال هي محلية وتتحذف بعد انتهاء الدالة.
5. السوبر جلوبالات مرئية في كل مكان، داخل وخارج الدوال.
6. الثوابت (constants) بمجرد تعريفها، مرئية عالميًا في كل مكان.

---

## 📌 15. الثوابت (Constants)

فكر في الثابت زي "قيمة لا تتغير طوال حياة السكربت". لا تحتوي على علامة دولار `$`.

```php
define("SITE_NAME", "PHP Avengers");
const VERSION = "1.0";

echo SITE_NAME; // PHP Avengers
echo VERSION;   // 1.0
```

**الفرق بين define و const:**
- `define` تُستخدم في زمن التنفيذ (runtime) ويمكن استخدامها في أي مكان، وتقبل تعابير غير ثابتة.
- `const` تستخدم في زمن الترجمة (compile-time) ويجب تعريفها في أعلى نطاق. لكن const أسرع قليلاً.

الثوابت مفيدة لعناوين URL، إعدادات قاعدة البيانات، أي لا تتغير.

---

## 🔁 16. Echo و Print

الاتنين بيعرضوا نصوص، لكن في فروقات:

### `echo` (مفضلة)
- يمكنها أخذ عدة معاملات مفصولة بفواصل.
- لا ترجع قيمة (void).
- أسرع قليلاً.

```php
echo "Hello", " ", "World"; // Hello World
```

### `print`
- تأخذ معامل واحد فقط، وترجع القيمة 1 (int).
- يمكن استعمالها في تعابير.

```php
$result = print("Hello"); // Hello, ثم $result = 1
```

النصيحة: استخدم `echo` للسرعة.

---

## 📊 17. أنواع بيانات المتغيرات (Data Types)

PHP بتدعم الأنواع الأساسية التالية:

1. **Integer** – أعداد صحيحة ( موجب أو سالب). المدى حسب المنصة (32/64-bit).
2. **Float** (أو double) – أعداد حقيقية (مثل 3.14).
3. **String** – سلسلة أحرف. داخل اقتباسات.
4. **Boolean** – `true` أو `false`.
5. **Array** – تجميعة مفهرسة (رقمي أو ترابطي).
6. **Object** – نموذج من كلاس.
7. **NULL** – متغير ليس له قيمة.
8. **Resource** – مقبض لموارد خارجية ( ملف مفتوح، اتصال ب DB). نوع خاص.

**التعرف على النوع:** استخدم `gettype()` أو دوال `is_*`.

```php
$x = 100;
echo gettype($x); // integer
if (is_int($x)) { echo "Yes"; }
```

---

## 🔄 18. تحويل الأنواع (Type Casting)

عند الحاجة، تجبر PHP تتعامل مع متغير كنوع مختلف مؤقتًا.

```php
$var1 = 0;
$var2 = (float)$var1; // $var2 float 0.0
$str = "123";
$num = (int)$str; // 123
```

أنواع التحويل: (int), (float), (string), (bool), (array), (object), (unset) (مهمل).

**طيب وإزاي نحول دائمًا؟** استخدم `settype()`:

```php
$val = "3.14";
settype($val, "float");
echo gettype($val); // double
```

---

## 🎭 19. المتغير من النوع "variable of variable"

ده مفهوم فريد: الـ variable variable يعني أن اسم المتغير نفسه يمكن تخزينه في متغير آخر.

```php
$varName = "age";
$$varName = 30;
echo $age; // 30
```

التفسير: لما تحط علامة دولارين `$$`، PHP بتاخد قيمة `$varName` (وهى "age") وتعتبرها اسم متغير جديد، ثم تسند له القيمة.

استخدام حذر: ممكن تسبب تعقيد، لكن مفيدة في بعض الحالات الديناميكية.

---

## ➕ 20. المعاملات (Operators) بكل تفاصيلها

### 1. المعاملات الحسابية (Arithmetic)

| المعامل | الاسم | مثال | النتيجة |
|--------|------|------|---------|
| + | جمع | $x + $y | مجموع |
| - | طرح | $x - $y | فرق |
| * | ضرب | $x * $y | حاصل ضرب |
| / | قسمة | $x / $y | خارج القسمة (Float) |
| % | باقي القسمة | $x % $y | باقي صحيح |
| ** | أسية | $x ** $y | $x مرفوع لـ $y |

```php
$a = 10; $b = 3;
echo $a % $b; // 1
echo $a ** $b; // 1000
```

### 2. معامل تسلسل النصوص (Concatenation)

النقطة `.` تستخدم لربط السلاسل.

```php
$first = "Hello, ";
$second = "World!";
$result = $first . $second; // Hello, World!
```

توجد عملية مركبة: `$first .= $second` يعني `$first = $first . $second`.

### 3. المعاملات المنطقية (Logical)

للجمع بين الشروط:

```php
$a = 50;
if ($a >= 0 && $a <= 100) {
    echo "Inside range";
}
```

- `&&` (AND): true لو الاتنين true.
- `||` (OR): true لو واحد على الأقل true.
- `!` (NOT): يعكس القيمة المنطقية.
- `and` و `or` و `xor` لها أولوية أقل من `&&` و `||`. استخدم `&&` و `||` في التعابير العادية.

### 4. المعاملات المركبة (Combined assignment)

مختصرات:

```php
$x += 5; // $x = $x + 5
$y -= 2;
$z *= 3;
$str .= " appended";
```

### 5. معاملات الزيادة والنقصان (Increment/Decrement)

جداً مهم في الحلقات:

```php
$a = 4;
echo ++$a; // 5 (pre-increment: زود ثم استخدم)
echo $a++; // 5 (post-increment: استخدم ثم زود) -> بعدها $a مهم 6
echo --$a; // 5 (decrement)
```

الفرق بين `$a++` و `++$a` هو في ترتيب الزيادة وإرجاع القيمة. الـ post-increment بيعمل TMP copy من القيمة القديمة.

### 6. معامل الإسناد بالمرجع (Reference Operator `&`)

```php
$a = 5;
$b = &$a; // $b يشير لنفس مكان $a
$a = 7;
echo $b; // 7
```

متغيرات reference مش نسخ. بتوفر في الذاكرة. لكن انتبه: لو أسندت قيمة جديدة لـ `$b`، `$a` تتغير. ولو عملت `unset($b)`، `$a` تفضل موجودة.

### 7. معاملات المقارنة (Comparison)

نركز على أشهرهم:

- `==` (يساوي) – قيم متساوية بعد تحويل الأنواع.
- `===` (متطابق) – نفس القيمة ونفس النوع.
- `!=` أو `<>` – لا يساوي.
- `!==` – غير متطابق (نوع مختلف أو قيمة مختلفة).
- `<=>` (المركبة spaceship, PHP 7+) – يرجع -1 لو اليسار أصغر، 0 لو متساويين، 1 لو اليسار أكبر.

مثال:

```php
var_dump(5 == "5");   // true
var_dump(5 === "5");  // false
var_dump(5 <=> 10);   // -1
```

### 8. معامل instanceof للكائنات

لم نتطرق للـ OOP بعد، لكن باختصار:

```php
class Sample {}
$obj = new Sample();
if ($obj instanceof Sample) {
    echo "Yes";
}
```

### 9. معامل إخفاء الأخطاء (Error suppression `@`)

قصداً لا تحجب كل الأخطاء، لكن قد تستخدم أحيانًا لتجاهل أخطاء بسيطة:

```php
$a = @(25/0); // INF بدون تحذير
var_dump($a);
```

بدون `@` هيفضل يطلع warning.

### 10. معامل التنفيذ (Execution backticks `` ` ``)

يقوم بتنفيذ الأمر كنظام تشغيل (shell) ويعيد الناتج:

```php
$out = `ls -la`;
echo "<pre>$out</pre>";
```

للاستخدام الآمن في بيئة مضبوطة فقط، وإلا خطر أمني.

---

## 🛠️ 21. دوال المتغيرات (Variable functions)

دوال مدمجة للتعامل مع أنواع المتغيرات واكتشافها.

### `gettype($var)` – ترجع نوع المتغير كـ string

```php
$num = 10.5;
echo gettype($num); // double
```

### `settype($var, $type)` – تغير النوع بشكل دائم

```php
$str = "123";
settype($str, "int");
echo $str + 5; // 128
```

### دوال الاستفهام `is_*` (ترجع true/false)

- `is_int()` (أو `is_integer()` أو `is_long()`)
- `is_float()` (أو `is_double()` أو `is_real()`)
- `is_string()`
- `is_bool()`
- `is_array()`
- `is_object()`
- `is_null()`
- `is_resource()`
- `is_scalar()` (تحقق إذا كان int, float, string, bool)
- `is_numeric()` (تحقق إذا كان رقم أو سلسلة رقمية)

### دوال الوجود `isset()`, `unset()`, `empty()`

- `isset($var)` – ترجع true لو المتغير موجود وقيمته مش null.
- `unset($var)` – تحذف المتغير تمامًا (يختفي من جدول الرموز).
- `empty($var)` – ترجع true لو المتغير غير موجود، أو موجود وقيمته صفر، أو سلسلة فارغة، أو null، أو false، أو مصفوفة فارغة.

```php
$name = "";
if (empty($name)) { // true
    echo "اسم فارغ";
}
```

## 🧠 22. تدفق التحكم والجمل التكرارية (Flow Control)

### 🔹 `if` الشرطية

```php
if ($age >= 18) {
    echo "Adult";
} elseif ($age >= 12) {
    echo "Teen";
} else {
    echo "Child";
}
```

### 🔹 `switch`

```php
switch ($color) {
    case 'red':
        echo "Stop";
        break;
    case 'green':
        echo "Go";
        break;
    default:
        echo "Wait";
}
```

**ملحوظة:** `break` مهم عشان ما ينفذش الـ cases اللاحقة.

### 🔹 `for` loop

```php
for ($i = 0; $i < 10; $i++) {
    echo $i . " ";
}
```

الـ for بتنفذ ثلاث أجزاء: تهيئة، شرط الاستمرار، تعبير الزيادة.

### 🔹 `foreach` للمصفوفات

```php
$colors = array("red", "green", "blue");
foreach ($colors as $value) {
    echo $value;
}
```

### 🔹 `while` و `do-while`

الـ while تفحص الشرط قبل التنفيذ.

```php
$i = 1;
while ($i <= 5) {
    echo $i++;
}
```

الـ do-while بتنفذ مرة واحدة على الأقل ثم تفحص الشرط.

```php
$x = 1000;
do {
    echo "Welcome to do while looping"; // هتنفذ مرة واحدة حتى لو الشرط false
} while ($x < 10);
```

### 🔹 `break`, `continue`, `exit`

- `break;` بتخرج من أقرب حلقة (for/while/switch).
- `continue;` بتتخطى باقي التعليمة في التكرار الحالي وتنتقل للتالي.
- `exit;` أو `exit();` بإنهاء السكربت بالكامل فورًا.

```php
for ($i=0; $i<10; $i++) {
    if ($i == 4) break;   // يخرج عند 4
    echo $i;
}
```

```php
for ($i=0; $i<5; $i++) {
    if ($i == 2) continue; // يتخطى الطباعة عندما i=2
    echo $i; // 0 1 3 4
}
```

```php
if (!$user_logged_in) {
    exit("Unauthorized"); // يوقف كل التنفيذ ويرجع الرسالة
}
```

---

## 🧪 23. حل اللاب العملي (Lab 01) خطوة بخطوة

اللاب المطلوب: بناء HTML form وإرسال البيانات إلى PHP server ثم طباعتها بشكل منظم.

### المطلوب الأول: إنشاء الفورم `form.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Lab 01 - User Info</title>
    <style>
        body { font-family: Arial; margin: 30px; }
        input { margin: 5px; }
    </style>
</head>
<body>
    <form action="process.php" method="POST">
        <label>Name: <input type="text" name="username" required></label><br>
        <label>Password: <input type="password" name="pass" required></label><br>
        <label>Email: <input type="email" name="email"></label><br>
        <input type="submit" value="Send">
    </form>
</body>
</html>
```

### المطلوب الثاني: معالج البيانات `process.php`

```php
<?php
// التحقق من أن الطريقة POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // الحصول على البيانات مع تنظيف أولي
    $name = isset($_POST['username']) ? htmlspecialchars($_POST['username']) : '';
    $password = isset($_POST['pass']) ? $_POST['pass'] : '';
    $email = isset($_POST['email']) ? filter_var($_POST['email'], FILTER_SANITIZE_EMAIL) : '';
?>
<!DOCTYPE html>
<html>
<head><title>User Data</title></head>
<body>
    <h1>البيانات المستلمة:</h1>
    <ul>
        <li><strong>Name:</strong> <?php echo $name; ?></li>
        <li><strong>Password:</strong> <?php echo str_repeat('*', strlen($password)); ?></li>
        <li><strong>Email:</strong> <?php echo $email; ?></li>
    </ul>
    <a href="form.html">Back to form</a>
</body>
</html>
<?php
} else {
    // لو حد حاول يفتح process.php مباشرة بدون POST
    header('Location: form.html');
    exit;
}
?>
```

### خطوات التشغيل العملي على أوبونتو:

1. ثبت حزمة LAMP (استخدم Bitnami أو `sudo apt install apache2 php libapache2-mod-php`).
2. ضع الملفين `form.html` و `process.php` في `/var/www/html/` (أو `/home/user/public_html` حسب الإعداد).
3. أعط صلاحية `www-data` للمجلد: `sudo chown -R www-data:www-data /var/www/html`.
4. افتح المتصفح على `http://localhost/form.html`.
5. املأ البيانات، اضغط Send.

**ملاحظات أمان:** لا تعرض كلمة المرور نصًا صريحًا أبدًا – في اللاب عرضنا نجوم فقط. وللمراسلة الحقيقية استخدم HTTPS و POST.

---

## 🎬 الخلاصة النهائية (حكاية اليوم الأول)

أنت دلوقتي عارف إن PHP ليست مجرد لغة، لكنها إمبراطورية لها تاريخ طويل، ومحرك Zend Engine هو الـ maestro اللي بيدير كل حاجة تحت الكبوت. فهمت الفرق بين السكربت السايت والـ server-side، وعرفت إن المتغيرات عندها نطاقات وثوابت وقواعد حفظ.

عرفت إن المعاملات بكثرة وأهمية debugging عبر `var_dump` و `isset`. وإن التحكم في التدفق بأدوات if, switch, loops يسمح لك ببناء منطق معقد.

قبل ما ننتهي، أذكرك: اللي تعلمته اليوم هو حجر الأساس. الغد سنتعمق في الدوال، المصفوفات، التعامل مع الملفات، وبدأ قصة الـ OOP.

تذكر دائمًا: PHP هتموت؟ لأ، PHP لسة بتدفع رزق ناس كتير جدًا، وWordPress وLaravel وSymfony مبنيين عليها، وفيس بوك كان معتمد عليها في البداية.

هلا والله يا هندسة.. جبت الكوباية التانية؟ يلا بينا نكمل الحكاية من حيث ما وقفنا.

دلوقتي إحنا فاهمين إن PHP لغة server-side، وفاهمين الرحلة بتاعة الفايل من الكيبورد لحد الشاشة، وعرفنا ننشيء متغيرات ونستقبل فورم ونطبع بيانات. لكن لسة في حاجات عميقة جدًا محتاجين نغوص فيها عشان نقدر نقول "أنا فاهم PHP".

---

## 🔁 24. تكملة: معاملات المقارنة المتقدمة والـ Ternary Operator (مش موجود في السلايدات لكن أساسي)

السلايدات ذكرت المعاملات الأساسية، بس أنا كـ راوي محترف لازم أضيف الحاجات اللي هتخليك تشتغل زي المحترفين.

### 24.1 Ternary Operator `? :`

ده اختصار لـ `if-else` في تعبير واحد.

```php
$age = 20;
$status = ($age >= 18) ? "Adult" : "Minor";
echo $status; // Adult
```

**تحت الكبوت:** الـ ternary operator بيتم تحويله بواسطة Zend Engine إلى opcode `ZEND_JMP` مع شرط. بيفيد في الكود القصير.

### 24.2 Null Coalescing Operator `??` (PHP 7+)

لو المتغير موجود ومش null، استخدمه، وإلا استخدم البديل.

```php
$name = $_GET['name'] ?? 'Guest';
// يعني لو $_GET['name'] مش موجود، خلي $name = 'Guest'
```

قبل PHP 7 كنت هتعمل:
```php
$name = isset($_GET['name']) ? $_GET['name'] : 'Guest';
```

`??` أسرع وأوضح.

### 24.3 Nullsafe Operator `?->` (PHP 8)

لما تشتغل مع objects (وهنوصلها قريب)، ده بيحميك من error لو الكائن null.

```php
$user = null;
$city = $user?->address?->city ?? 'Unknown';
```

مش هنعمق فيه دلوقتي، لكن خلينا عارفين إنه موجود.

---

## 🧪 25. فهم الـ Superglobals بالتفصيل (عشان مفيش حاجة أهم)

السلايدات ذكرتهم بس سريعًا. خليني أشرح كل واحد مع سيناريو واقعي.

### `$_SERVER`
مصفوفة فيها بيانات عن السيرفر والطلب.

```php
echo $_SERVER['REQUEST_METHOD']; // GET or POST
echo $_SERVER['HTTP_USER_AGENT']; // المتصفح
echo $_SERVER['REMOTE_ADDR']; // عنوان IP الزائر
echo $_SERVER['SCRIPT_FILENAME']; // المسار الكامل للملف الحالي
```

### `$_GET` و `$_POST` و `$_REQUEST`
- `$_GET`: البيانات تظهر في الـ URL (مثلاً `page.php?id=5`). تستخدم للقراءة فقط، وليست آمنة للبيانات الحساسة.
- `$_POST`: البيانات تنتقل في body الطلب، لا تظهر في URL، تستخدم للإرسال (تسجيل دخول، تعليقات).
- `$_REQUEST`: تجمع الـ GET و POST و COOKIE. **ملحوظة:** ممكن تسبب تضارب، الأفضل تختار النوع المناسب.

### `$_COOKIE`
الكوكيز اللي المتصفح بعتها للسيرفر. متنساش إنها بتتبعت مع كل طلب.

```php
setcookie('user', 'Noha', time()+3600); // يرسل كوكيز للمتصفح
$user = $_COOKIE['user'] ?? '';
```

### `$_SESSION`
بتخزن بيانات على السيرفر نفسه، وتبعت بس session id في كوكيز للمتصفح.

```php
session_start();
$_SESSION['user_id'] = 5;
```

بعد كده تقدر ترجع البيانات في أي صفحة تانية بعد `session_start()`.

### `$_FILES`
لرفع الملفات.

```php
$uploaded_file = $_FILES['myfile']['tmp_name'];
move_uploaded_file($uploaded_file, '/uploads/'.$_FILES['myfile']['name']);
```

---

## 🧠 26. النوع Resource – المقبض السري

نوع `resource` هو مؤشر لموارد خارجية لا يمكن تمثيلها كقيمة PHP عادية. مثال: فتح ملف، اتصال قاعدة بيانات، صورة.

```php
$file = fopen('data.txt', 'r'); // $file هو resource
echo gettype($file); // resource
fclose($file);
```

الـ resource يتحرر تلقائيًا بعد انتهاء السكربت، لكن من الأفضل إغلاقه يدويًا لتوفير الذاكرة.

---

## 🔁 27. تكملة عامة: المتغيرات الثابتة (Static Variables) في سياق متقدم

التكملة: المتغير الثابت لا يقتصر فقط على العدادات. تقدر تخزن أي حاجة تحتاج تحتفظ بقيمتها بين استدعاءات الدالة، مثل اتصال بقاعدة بيانات نستخدمه كـ singleton.

```php
function getDB() {
    static $connection = null;
    if ($connection === null) {
        $connection = new PDO('mysql:...');
    }
    return $connection;
}
```

---

## 🔄 28. الـ Include و Require – (لم تذكر في السلايدات لكنها حجر الأساس)

رغم إن السلايدات ما ذكرتهمش، لكن أي مشروع PHP محترم بيستخدمهم. أنت محتاج تقسم الكود على عدة ملفات.

- `include 'file.php';` لو الملف مش موجود، يطلع warning ويكمل السكربت.
- `require 'file.php';` لو مش موجود، يطلع fatal error ويوقف السكربت.
- `include_once` و `require_once` بيضمنوا إن الملف يتضمن مرة واحدة فقط (مفيد للمكتبات).

```php
// config.php
define('DB_HOST', 'localhost');

// index.php
require_once 'config.php';
echo DB_HOST;
```

**تحت الكبوت:** الـ include بيتم تنفيذه في زمن التنفيذ (runtime) داخل نطاق الـ function الحالي لو اتضمن جوه function. Zend Engine بيفتح الملف ويحول محتواه لـ opcodes ويدمجه في التنفيذ.

---

## 🧪 29. حل اللاب العملي (Lab 01) – رؤية معمقة

أنا حليت اللاب بطريقة بسيطة، لكن دعنا نضيف عليها تغليف بقواعد أمان حقيقية عشان تكون جاهز للإنتاج.

### improved `process.php` مع حماية:

```php
<?php
declare(strict_types=1); // يفرض types صارمة في الدوال (لسه مشروحة)

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Method Not Allowed');
}

// التطهير والتحقق
$name = trim($_POST['username'] ?? '');
if ($name === '') {
    die('Name is required');
}
$password = $_POST['pass'] ?? '';
if (strlen($password) < 4) {
    die('Weak password');
}
$email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
if (!$email) {
    $email = 'No valid email provided';
}

// الآن اطبعها بأمان ضد XSS
?>
<!DOCTYPE html>
<html>
<head><title>User Data</title></head>
<body>
    <h1>Welcome, <?= htmlspecialchars($name) ?>!</h1>
    <p>Email: <?= htmlspecialchars($email) ?></p>
    <p>Password length: <?= strlen($password) ?> characters (stored securely in real app)</p>
</body>
</html>
```

**ملاحظات أمنية:**
- `htmlspecialchars()` بتمنع حقن HTML (XSS).
- `filter_input` بتنقي البريد الإلكتروني.
- أبدًا متخزنش كلمة المرور نص عادي؛ استخدم `password_hash()`.

---

## 🧭 30. المسار الكامل للمبتدئ: الخلاصة النهائية لليوم الأول

تعالا نرتب أفكارك:

1. **إيه PHP؟** لغة سيرفر سايد، حرة، مفتوحة المصدر، بتتنفذ بواسطة Zend Engine.
2. **إزاي تشتغل؟** تنصب XAMPP أو LAMP، تفتح localhost، تكتب كود جوه `<?php ?>`.
3. **المتغيرات:** بتبدأ بـ `$`، case-sensitive، loosely typed.
4. **النطاقات:** global، local، static، parameter, superglobal.
5. **الثوابت:** بتتعرف بـ `define()` أو `const`، مفيش دولار.
6. **الإدخال من المستخدم:** عبر `$_GET` و `$_POST`.
7. **التحكم في التدفق:** if, switch, for, foreach, while, do-while.
8. **المعاملات:** +, -, *, /, %, ., =, ==, ===, &&, ||, !, ??, <=>.
9. **دوال المتغيرات:** `isset()`, `unset()`, `empty()`, `gettype()`, `settype()`.
10. **أساسيات الأمان:** `htmlspecialchars()`, `filter_input`, لا تثق في أي إدخال.

---

## 📚 المصادر والأدوات اللي محتاجها بعد اليوم

- `php.net/manual` – المرجع الرسمي (اقرأ عن كل دالة قبل ما تستخدمها).
- Xdebug – أداة debugging عظيمة.
- PHP_CodeSniffer – لكتابة كود نظيف.
- Composer – مدير حزم PHP (ليهنأ بيه قريب).

---

## ✨ كلمة أخيرة من الراوي

انت النهارده أخدت الخطوة الأولى في عالم الـ PHP. مش مجرد "عرفت syntax" لأ.. أنت عرفت إيه بيحصل جوه السيرفر، عرفت الـ Zend Engine بيزفر كده إزاي، وعرفت ليه `localhost/info.php` بيعرض كل الأسرار.

تذكر: PHP مش قديمة ولا ميتة. هي مثل النيل، قديم لكنه يجري ومتجدد. كل يوم فيه تحديثات وإصدارات جديدة ومكتبات أقوى. أنت بقى ليك مكان في وادي الـ PHP يا معلم.

لو عايزني أفتحلك اليوم الثاني بتاع الدوال والمصفوفات والـ OOP، قولي "إفتح الباب". وإلى ذلك الحين، جرب تكتب كود كتير، غير فيه، اغلط وتعلم.

السلايد بتاعة النهاردة اتعملت بمساعدة الأستاذة **Noha Shehab**، اللي بتشجعنا نحكي القصص التقنية دي. شكرًا لها، ولك يا صديقي على طول البال في القراية.

**وبكده يختتم اليوم الأول من حكاية PHP تحت الكبوت.**

```php
<?php
// رمز اليوم: استمرارية
while ($alive) {
    $you->learn();
    $you->practice();
    $you->becomeBetter();
}
?>
```

يلا بينا ننام على معلومة دلع 😴💤. الليلة جاية نكمل بقى مع المصفوفات والدوال، ونبدأ نلمس الـ Object-Oriented.

**أطلبوا الخير، وكملوا الحكاية لما تشتهوا.** سلام.