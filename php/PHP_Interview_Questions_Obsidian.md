# 🎯 PHP — أسئلة إنترفيو شاملة (Zero to Hero)
### من اليوم الأول لحد اليوم الخامس — كل السكاشن من السهل للصعب

> **كيفية الاستخدام في Obsidian:** اضغط على السهم ◀ جنب كل سؤال عشان الإجابة تتفتح. حاول تجاوب بنفسك الأول!

---

**Tags:** #PHP #Interview #Backend #ITI #ZeroToHero

---

## 🏛️ القسم الأول — الـ Zend Engine ورحلة الـ Request

---

> [!question]- 🟢 س١: إيه الفرق بين الـ Static File والـ Dynamic File على الـ Web Server؟
> الـ **Static File** زي `.html`, `.css`, `.js`, `.png` — الـ Web Server بيبعتهم مباشرةً من الـ Disk للـ Browser من غير أي معالجة.
> الـ **Dynamic File** زي `.php` — الـ Web Server مش يقدر يشغّله لوحده، بيحتاج يبعته لـ PHP-FPM اللي بيشغّل الـ Zend Engine عشان يتنفذ ويولّد HTML.

---

> [!question]- 🟢 س٢: إيه هو الـ PHP-FPM وإيه دوره؟
> الـ **PHP-FPM** (FastCGI Process Manager) هو الـ Process Manager بتاع PHP. بيشتغل كـ Pool من الـ Worker Processes الجاهزين في الـ RAM. لمّا الـ Web Server (Nginx/Apache) بيستقبل Request على ملف `.php`، بيبعته لـ PHP-FPM عبر الـ FastCGI Protocol. PHP-FPM بياخد Worker فاضي ويبعتله الشغل، وده بيخلي الـ Server يتعامل مع Requests كتيرة في نفس الوقت بدون ما يفضل ينشئ Process جديدة مع كل Request.

---

> [!question]- 🟢 س٣: إيه المراحل الأربعة اللي بيمر بيها الـ Zend Engine عشان ينفّذ ملف PHP؟
> 1. **Lexing (Tokenization):** بياخد الـ Source Code النصي ويحوّله لـ Tokens (وحدات صغيرة زي `T_ECHO`, `T_VARIABLE`, إلخ).
> 2. **Parsing:** بياخد الـ Tokens ويبني منها **AST (Abstract Syntax Tree)** — شجرة بتمثل البنية المنطقية للكود. لو في Syntax Error بييجي من هنا.
> 3. **Compilation:** بيحوّل الـ AST لـ **Opcodes** — تعليمات بسيطة بيفهمها الـ Zend VM.
> 4. **Execution:** الـ **Zend VM** بينفّذ الـ Opcodes واحدة واحدة ويولّد الـ HTML Output.

---

> [!question]- 🟡 س٤: إيه هو الـ OPcache وليه مهم في الـ Production؟
> الـ **OPcache** هو Extension بيخزّن الـ Compiled Opcodes في الـ RAM بدل ما PHP يعيد عمليات الـ Lexing والـ Parsing والـ Compilation في كل Request. في المرة الأولى، بيعمل الـ 4 مراحل وبيحفظ الـ Opcodes. من المرة التانية، بيجيب الـ Opcodes جاهزة من الـ Cache ويشغّلها مباشرةً. ده بيسرّع الـ Performance بنسبة **50-70%** على الأقل. في الـ Production دايمًا `opcache.enable=1` في `php.ini`.

---

> [!question]- 🔴 س٥: إزاي تتحقق إن OPcache شغّال على السيرفر؟ وإيه هو الـ Unix Socket اللي Nginx بيستخدمه مع PHP-FPM؟
> **التحقق من OPcache:**
> ```bash
> php -r "var_dump(opcache_get_status()['opcache_enabled']);"
> # bool(true) → شغّال ✅
> ```
> **الـ Unix Socket:** بدل ما Nginx يتكلم مع PHP-FPM عبر TCP Port (أبطأ لأنه يعدّي على الـ Network Stack)، بيستخدم **Unix Domain Socket** — ملف على الـ Disk زي `/var/run/php/php8.2-fpm.sock`. ده أسرع لأن الـ Communication بتحصل في الـ Kernel مباشرةً من غير Network overhead. تلاقيه في الـ Nginx Config في `fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;`.

---

## 📦 القسم التاني — Variables والـ Data Types والـ Scope

---

> [!question]- 🟢 س٦: إيه الفرق بين `==` و `===` في PHP؟ وامتى ده بيسبب Bug؟
> - `==` → **Loose Comparison** — بيعمل Type Juggling قبل المقارنة (بيحوّل النوع تلقائياً).
> - `===` → **Strict Comparison** — لازم القيمة والنوع يكونوا متساويين.
>
> مثال على Bug شهير:
> ```php
> var_dump(0 == "hello"); // bool(true) ← خطر!
> var_dump(0 === "hello"); // bool(false) ← صح
>
> // Gotcha مع strpos()
> $pos = strpos("hello", "h"); // بيرجع 0 (أول position)
> if ($pos == false) { echo "مش موجود"; }  // ❌ غلط! 0 == false
> if ($pos === false) { echo "مش موجود"; } // ✅ صح
> ```

---

> [!question]- 🟢 س٧: إيه هو الـ Variable Scope في PHP؟ وإيه الفرق بين Local وGlobal وStatic؟
> - **Local:** المتغير اللي جوّا الـ Function مش مرئي من برّاها.
> - **Global:** المتغير برّا الـ Function مش مرئي جوّاها **تلقائياً** — لازم تستخدم `global $var;` أو `$GLOBALS['var']`.
> - **Static:** المتغير جوّا الـ Function بيتذكر قيمته بين الاستدعاءات (مش بيتحذف من الـ RAM بعد كل call).
> ```php
> function counter() {
>     static $count = 0; // ← بيتهيأ مرة واحدة بس
>     $count++;
>     echo $count;
> }
> counter(); // 1
> counter(); // 2
> counter(); // 3
> ```

---

> [!question]- 🟡 س٨: إيه الـ Data Types الموجودة في PHP؟ وإيه معنى إن PHP Loosely Typed؟
> PHP عندها **8 أنواع أساسية:**
> - Scalars: `int`, `float`, `string`, `bool`
> - Compound: `array`, `object`
> - Special: `null`, `resource`
>
> **Loosely Typed** معناها إنك مش محتاج تحدد النوع لما بتعرّف المتغير — PHP بتحدده تلقائياً حسب القيمة. وبتعمل **Type Juggling** (تحويل تلقائي) لمّا بتعمل عمليات بين أنواع مختلفة. بدأت من **PHP 7** تقدر تحدد الأنواع يدوياً بـ Type Declarations وReturn Types.

---

> [!question]- 🟡 س٩: إيه الفرق بين `isset()` و `empty()` و `is_null()`؟
> - `isset($var)` → بترجع `true` لو المتغير معرّف **ومش null**.
> - `empty($var)` → بترجع `true` لو المتغير فيه قيمة "فاضية": `""`, `0`, `"0"`, `null`, `false`, `[]`.
> - `is_null($var)` → بترجع `true` بس لو القيمة هي `null` بالظبط.
>
> ```php
> $a = 0;
> var_dump(isset($a));   // true  ← معرّف
> var_dump(empty($a));   // true  ← 0 يُعتبر فاضي
> var_dump(is_null($a)); // false ← مش null
> ```

---

> [!question]- 🔴 س١٠: إيه الفرق بين الـ Pass by Value والـ Pass by Reference في PHP؟ وامتى تستخدم كل واحد؟
> **Pass by Value (الافتراضي):** PHP بتعمل نسخة من المتغير وبتبعتها للـ Function. أي تغيير جوّا الـ Function مش بيأثر على الأصل.
>
> **Pass by Reference (بالـ &):** بتبعت "عنوان الذاكرة" — الـ Function والـ Caller بيشاركوا نفس المتغير في الـ RAM. أي تغيير جوّا الـ Function بيأثر على الأصل.
>
> ```php
> function addTax(&$price, $rate = 0.14) {
>     $price = $price * (1 + $rate); // ← بيعدّل الأصل
> }
> $productPrice = 100;
> addTax($productPrice);
> echo $productPrice; // 114
> ```
>
> استخدم الـ Reference لمّا تحتاج تعدّل المتغير الأصلي أو لمّا تشتغل مع Data ضخمة وعايز تتجنب نسخها في الـ RAM.

---

## 🔄 القسم التالت — Control Flow والـ Forms

---

> [!question]- 🟢 س١١: إيه الفرق بين `include` و `require` في PHP؟
> - **`include`:** لو الملف مش موجود، PHP بتطبع **Warning** والـ Script بيكمل التنفيذ.
> - **`require`:** لو الملف مش موجود، PHP بتطبع **Fatal Error** والـ Script بيوقف فوراً.
> - **`_once` versions:** `include_once` / `require_once` بيتأكدوا إن الملف اتحمّل مرة واحدة بس — مفيد لتجنب إعادة تعريف Functions أو Classes.
>
> القاعدة: استخدم `require_once` للـ Config Files والـ Classes الأساسية. استخدم `include` للـ Templates والـ Views.

---

> [!question]- 🟡 س١٢: إيه الفرق بين `$_GET` و `$_POST`؟ وامتى تستخدم كل واحد؟
> | | `$_GET` | `$_POST` |
> |---|---|---|
> | البيانات في | الـ URL Query String | الـ HTTP Body |
> | مرئية للمستخدم | ✅ نعم | ❌ لا |
> | الحد الأقصى | ~2000 حرف (URL Limit) | غير محدود عملياً |
> | مناسب لـ | Search queries, Filters, Pagination | Login, Forms, File Upload |
> | Cache/Bookmark | ✅ ممكن | ❌ |
>
> **القاعدة:** `GET` للعمليات القراءة اللي ممكن تتكرر بدون تأثير (Idempotent). `POST` لأي عملية بتغيّر State (إضافة، تعديل، حذف).

---

> [!question]- 🟡 س١٣: إيه الـ SuperGlobals في PHP؟ اذكر منها 5 مع وظيفة كل واحد.
> الـ SuperGlobals هي متغيرات مدمجة في PHP متاحة في كل مكان (حتى جوّا الـ Functions) من غير الحاجة لـ `global`:
> - `$_GET` → البيانات الجاية في الـ URL Query String.
> - `$_POST` → البيانات الجاية في الـ HTTP Body (Forms).
> - `$_FILES` → معلومات الملفات المرفوعة.
> - `$_SESSION` → بيانات الـ Session المخزّنة على السيرفر.
> - `$_COOKIE` → بيانات الـ Cookies المخزّنة في المتصفح.
> - `$_SERVER` → معلومات السيرفر والـ Request (زي `$_SERVER['REQUEST_METHOD']`).
> - `$_ENV` → متغيرات البيئة (Environment Variables).
> - `$GLOBALS` → كل المتغيرات الـ Global في البرنامج.

---

> [!question]- 🔴 س١٤: إيه هو الـ XSS وإزاي PHP تتحمى منه عند عرض بيانات الـ User؟
> الـ **XSS (Cross-Site Scripting)** بيحصل لمّا المستخدم بيكتب HTML أو JavaScript في الـ Form، وانت بتعرضه مباشرةً من غير ما تنظّفه. المتصفح بينفّذ الكود ده زي ما ينفّذ أي JavaScript تاني!
>
> **الحماية:** استخدم `htmlspecialchars()` دايمًا عند عرض أي بيانات جاية من المستخدم:
> ```php
> // ❌ خطر!
> echo $_POST['username'];
>
> // ✅ آمن
> echo htmlspecialchars($_POST['username'], ENT_QUOTES, 'UTF-8');
> // بيحوّل < لـ &lt;  و > لـ &gt;  و " لـ &quot;
> // فالمتصفح هيعرضها كنص عادي مش كـ HTML
> ```

---

## 📁 القسم الرابع — File Handling

---

> [!question]- 🟢 س١٥: اذكر الـ File Modes الأساسية في `fopen()` ووظيفة كل واحد.
> | Mode | الوظيفة |
> |---|---|
> | `r` | قراءة بس — الـ Pointer في الأول — الملف لازم يكون موجود |
> | `w` | كتابة بس — يمحي المحتوى القديم أو ينشئ الملف |
> | `a` | كتابة في الآخر (Append) — ما بيمحيش القديم — ينشئ لو مش موجود |
> | `r+` | قراءة وكتابة — الـ Pointer في الأول — الملف لازم يكون موجود |
> | `w+` | قراءة وكتابة — يمحي القديم — ينشئ لو مش موجود |
> | `a+` | قراءة وكتابة في الآخر — ما بيمحيش القديم |

---

> [!question]- 🟡 س١٦: إيه الفرق بين `fread()` و `fgets()` و `file_get_contents()`؟
> - **`fread($handle, $bytes)`:** بيقرأ عدد معيّن من الـ Bytes. مناسب لقراءة Binary Files أو جزء من الملف.
> - **`fgets($handle)`:** بيقرأ **سطر واحد** في كل مرة (حتى `\n`). مناسب لمعالجة ملفات نصية سطر بسطر.
> - **`file_get_contents($path)`:** بيقرأ **الملف كله** دفعة واحدة كـ String. الأسهل والأسرع للملفات الصغيرة، بس ممكن يكون مشكلة مع الملفات الكبيرة جداً.
>
> **القاعدة:** للملفات الكبيرة استخدم `fgets()` في Loop. للملفات الصغيرة استخدم `file_get_contents()`.

---

> [!question]- 🟡 س١٧: إيه هو الـ `flock()` وليه ضروري في البيئات المتعددة؟
> الـ **`flock()`** بتعمل **File Locking** — بتحجز الملف عشان Process واحدة بس تكتب فيه في نفس الوقت.
>
> **المشكلة:** لو 100 مستخدم بعتوا Form في نفس الوقت وكل Request حاولت تكتب في نفس الملف، الـ Data هتتخبّط (Race Condition).
> ```php
> $handle = fopen('users.txt', 'a');
> if (flock($handle, LOCK_EX)) {  // ← احجز Exclusive Lock
>     fwrite($handle, $newData);
>     flock($handle, LOCK_UN);    // ← فكّ القفل
> }
> fclose($handle);
> ```
> الـ `LOCK_EX` معناه Exclusive — العملية دي لوحدها تكتب. الـ `LOCK_SH` معناه Shared — أكتر من حد يقدر يقرأ في نفس الوقت.

---

> [!question]- 🔴 س١٨: إيه الفرق بين `file_put_contents()` بـ Flag `FILE_APPEND` وبدونه؟ وامتى تستخدم `LOCK_EX` معاها؟
> - **بدون Flag:** بيكتب فوق المحتوى القديم كاملاً (Overwrite).
> - **مع `FILE_APPEND`:** بيضيف في آخر الملف (مش بيمحي القديم).
> - **مع `LOCK_EX`:** بيعمل Exclusive Lock أثناء الكتابة — ضروري في الـ Web Environment لأن الـ PHP Requests بيتشغّلوا بالتوازي:
>
> ```php
> // ✅ الطريقة الآمنة في الـ Web
> file_put_contents(
>     'log.txt',
>     date('[Y-m-d H:i:s] ') . $message . PHP_EOL,
>     FILE_APPEND | LOCK_EX  // ← اضف في الآخر مع قفل
> );
> ```

---

## 📋 القسم الخامس — Arrays

---

> [!question]- 🟢 س١٩: إيه الأنواع التلاتة للـ Arrays في PHP؟
> 1. **Indexed Array:** المفاتيح أرقام تلقائية تبدأ من 0.
>    ```php
>    $fruits = ['Apple', 'Banana', 'Orange'];
>    ```
> 2. **Associative Array:** المفاتيح Strings محدّدة يدوياً.
>    ```php
>    $person = ['name' => 'Noha', 'age' => 28];
>    ```
> 3. **Multidimensional Array:** Array جوّا Array.
>    ```php
>    $students = [
>        ['name' => 'Omar', 'grade' => 90],
>        ['name' => 'Sara', 'grade' => 85],
>    ];
>    ```

---

> [!question]- 🟡 س٢٠: إيه الفرق بين `sort()` و `asort()` و `ksort()`؟
> - **`sort()`:** بيرتّب الـ Values تصاعدياً وبيعيد ترقيم الـ Keys من 0 (بيكسر الـ Association).
> - **`asort()`:** بيرتّب الـ Values تصاعدياً لكن **بيحافظ على الـ Keys** (Association Preserved).
> - **`ksort()`:** بيرتّب بالـ **Keys** مش الـ Values.
>
> ```php
> $prices = ['banana' => 5, 'apple' => 3, 'orange' => 7];
> asort($prices);
> // ['apple' => 3, 'banana' => 5, 'orange' => 7]  ← Keys محافظة عليها
> ```

---

> [!question]- 🟡 س٢١: إيه الفرق بين `array_map()` و `array_filter()` و `array_walk()`؟
> - **`array_map($fn, $arr)`:** بيطبّق Function على كل عنصر وبيرجع **Array جديدة** بالنتايج. مش بيغيّر الأصل.
> - **`array_filter($arr, $fn)`:** بيرجع **Array جديدة** فيها بس العناصر اللي الـ Function رجعت ليها `true`. مش بيغيّر الأصل.
> - **`array_walk(&$arr, $fn)`:** بيعدّل الـ Array **في المكان** (بالـ Reference) من غير ما يرجع Array جديدة.
>
> ```php
> $nums = [1, 2, 3, 4, 5, 6];
>
> $doubled  = array_map(fn($n) => $n * 2, $nums);   // [2,4,6,8,10,12]
> $evens    = array_filter($nums, fn($n) => $n % 2 === 0); // [2,4,6]
> array_walk($nums, function(&$val) { $val *= 10; }); // $nums = [10,20,30,40,50,60]
> ```

---

> [!question]- 🔴 س٢٢: إيه الفرق بين `array_merge()` و `+` (Union Operator) مع الـ Arrays؟
> - **`array_merge()`:** بيدمج الـ Arrays وبيعيد ترقيم الـ Numeric Keys. لو الـ Associative Keys متكررة، القيمة التانية بتكسب.
> - **`+` Operator:** بيضم الـ Arrays بس لو الـ Key مش موجود في الأول — بيحافظ على القيم الموجودة (الأول بيكسب). الـ Numeric Keys مش بتتغيّر.
>
> ```php
> $a = ['x' => 1, 0 => 'first'];
> $b = ['x' => 99, 0 => 'second', 'y' => 2];
>
> print_r(array_merge($a, $b));
> // ['x' => 99, 0 => 'first', 1 => 'second', 'y' => 2]
> // ← x اتكسر والـ Numeric Keys اتعادت ترقيمهم
>
> print_r($a + $b);
> // ['x' => 1, 0 => 'first', 'y' => 2]
> // ← الأول كسب في x و0، وy اتضافت
> ```

---

## 🔡 القسم السادس — String Manipulation

---

> [!question]- 🟢 س٢٣: إيه الفرق بين `trim()` و `ltrim()` و `rtrim()`؟
> - **`trim($str)`:** بتشيل الـ Whitespace (مسافات، tabs، newlines) من **الطرفين**.
> - **`ltrim($str)`:** بتشيل من **الطرف الأيسر** (Left/Start) بس.
> - **`rtrim($str)`** (نفس `chop()`): بتشيل من **الطرف الأيمن** (Right/End) بس.
>
> تقدر تحدد أنهي Characters تتشال في الـ Parameter التاني:
> ```php
> $text = "##Hello World##";
> echo trim($text, '#'); // "Hello World"
> ```

---

> [!question]- 🟢 س٢٤: إيه الفرق بين `explode()` و `implode()`؟
> - **`explode($delimiter, $string)`:** بتقسّم الـ **String لـ Array** حسب الـ Delimiter.
> - **`implode($glue, $array)`** (نفس `join()`): بتجمع الـ **Array في String** واحدة مع Separator بينهم.
>
> ```php
> $csv = "PHP,MySQL,Linux";
> $parts = explode(",", $csv);  // ['PHP', 'MySQL', 'Linux']
>
> $joined = implode(" | ", $parts); // "PHP | MySQL | Linux"
> ```

---

> [!question]- 🟡 س٢٥: إيه الـ Gotcha المشهور مع `strpos()` وإزاي تتجنبه؟
> `strpos()` بترجع `0` لو الـ Needle موجود في **أول** الـ Haystack، وبترجع `false` لو **مش موجود**.
>
> المشكلة: `0 == false` هو `true` في PHP بسبب الـ Type Juggling!
>
> ```php
> $str = "PHP is great";
>
> // ❌ Bug! هيقول "مش موجود" وهي موجودة في index 0
> if (strpos($str, "PHP") == false) {
>     echo "مش موجودة";
> }
>
> // ✅ الصح: استخدم === عشان تتحقق من النوع كمان
> if (strpos($str, "PHP") === false) {
>     echo "مش موجودة";
> }
> ```

---

> [!question]- 🟡 س٢٦: إيه الفرق بين `str_replace()` و `substr_replace()`؟
> - **`str_replace($search, $replace, $subject)`:** بيدور على **Pattern محدد** في الـ String ويستبدله. بيستبدل كل الـ Occurrences.
> - **`substr_replace($string, $replace, $start, $length)`:** بيستبدل جزء من الـ String بناءً على **موقع وطول** — مش بيدور على Pattern.
>
> ```php
> // str_replace: استبدل الكلمة
> echo str_replace("World", "PHP", "Hello World"); // "Hello PHP"
>
> // substr_replace: استبدل من index 6 وطوله 5 chars
> echo substr_replace("Hello World", "PHP", 6, 5); // "Hello PHP"
> ```

---

> [!question]- 🔴 س٢٧: إيه الفرق بين `strcmp()` و `strcasecmp()` وإزاي الـ Return Value بتتفسّر؟
> - **`strcmp($s1, $s2)`:** مقارنة **Case-Sensitive**.
> - **`strcasecmp($s1, $s2)`:** مقارنة **Case-Insensitive**.
>
> الـ Return Value:
> - `0` → متساويين.
> - `< 0` → الـ String الأولى "أصغر" أبجديًا (تيجي قبل التانية).
> - `> 0` → الـ String الأولى "أكبر" (تيجي بعد التانية).
>
> ```php
> echo strcmp("apple", "banana"); // رقم سالب ← apple قبل banana
> echo strcmp("Z", "A");          // رقم موجب ← Z بعد A
> echo strcasecmp("Hello", "HELLO"); // 0 ← متساويين (ignore case)
> ```

---

## 🎯 القسم السابع — Regular Expressions

---

> [!question]- 🟢 س٢٨: إيه الفرق بين `preg_match()` و `preg_match_all()`؟
> - **`preg_match($pattern, $subject, $matches)`:** بتوقف بعد أول Match وبترجع `1` أو `0`. الـ `$matches[0]` فيها الـ Match الأول.
> - **`preg_match_all($pattern, $subject, $matches)`:** بتكمل في الـ String كلها وبتجمع **كل الـ Matches** وبترجع عدد الـ Matches.
>
> ```php
> $str = "rain in SPAIN falls mainly";
> preg_match('/ain/i', $str, $m);       // $m[0] = "ain"
> preg_match_all('/ain/i', $str, $all); // $all[0] = ["ain","AIN","ain","ain"]
> ```
> استخدم `preg_match()` لو بس عايز تتحقق من وجود الـ Pattern. استخدم `preg_match_all()` لو عايز كل الـ Occurrences.

---

> [!question]- 🟡 س٢٩: إيه الـ Pattern المشهور للـ Email Validation بـ Regex؟ واشرح كل جزء فيه.
> ```php
> $pattern = "/^([a-z0-9\+_\-]+)(\.[a-z0-9\+_\-]+)*@([a-z0-9\-]+\.)+[a-z]{2,6}$/ix";
> ```
> - `^` → لازم يبدأ من أول الـ String
> - `[a-z0-9\+_\-]+` → جزء الـ Username: حروف، أرقام، +، _، -
> - `(\.[a-z0-9\+_\-]+)*` → ممكن يكون `first.last` format (اختياري)
> - `@` → الـ @ الإلزامية
> - `([a-z0-9\-]+\.)+` → الـ Domain (ممكن متعدد زي `iti.gov`)
> - `[a-z]{2,6}` → الـ TLD من 2 لـ 6 حروف (eg, com, info)
> - `$` → لازم ينتهي هنا
> - `i` → Case-Insensitive | `x` → تجاهل الـ Whitespace في الـ Pattern

---

> [!question]- 🟡 س٣٠: إيه الفرق بين استخدام Regex و `filter_var()` لـ Email Validation؟ وأيهم أفضل؟
> - **Regex يدوي:** مرن لكن صعب تغطي كل حالات الـ Email الصحيحة (المعيار أعقد مما نتخيل). ممكن يرفض Emails صحيحة أو يقبل غلط.
> - **`filter_var($email, FILTER_VALIDATE_EMAIL)`:** بيستخدم الـ RFC المعياري المدمج في PHP نفسه. أكثر موثوقية وبيتحدّث مع PHP.
>
> ```php
> // ✅ الأفضل في Production
> if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
>     echo "إيميل غير صحيح";
> }
> ```
> استخدم `filter_var()` في الـ Production. استخدم الـ Regex اليدوي لو محتاج Validation أكثر تحكماً وخصوصية.

---

> [!question]- 🔴 س٣١: ماذا تعني الـ Quantifiers التالية في الـ Regex: `*` و `+` و `?` و `{2,6}`؟ وإيه الفرق بين Greedy وLazy؟
> - `*` → صفر أو أكتر مرات.
> - `+` → واحدة أو أكتر مرات.
> - `?` → صفر أو مرة واحدة (اختياري).
> - `{2,6}` → من 2 لـ 6 مرات بالظبط.
>
> **Greedy vs Lazy:**
> - **Greedy (الافتراضي):** بياخد أطول Match ممكن. مثال: `<.+>` على `<b>text</b>` بيرجع `<b>text</b>` كاملة.
> - **Lazy (بـ `?` بعد الـ Quantifier):** بياخد أقصر Match ممكن. مثال: `<.+?>` على نفس النص بيرجع `<b>` بس.

---

## 📤 القسم التامن — File Upload والـ Sessions والـ Cookies

---

> [!question]- 🟢 س٣٢: إيه الـ Attributes الإجبارية في الـ HTML Form عشان تشتغل File Upload؟
> لازم يكون في الـ Form:
> 1. **`method="POST"`** → الـ GET مش بيدعم File Upload.
> 2. **`enctype="multipart/form-data"`** → من غيرها الملف مش هيتبعت — PHP هتستقبل اسم الملف بس مش محتواه.
>
> ```html
> <form action="upload.php" method="POST" enctype="multipart/form-data">
>     <input type="file" name="photo" />
>     <input type="submit" />
> </form>
> ```

---

> [!question]- 🟡 س٣٣: ليه الاعتماد على `$_FILES['file']['type']` للتحقق من نوع الملف خطر؟ وإيه الحل الصح؟
> `$_FILES['file']['type']` بييجي من **المتصفح** — والمتصفح ممكن يتزوّر. المستخدم يقدر يرفع ملف `.php` ويغيّر الـ MIME Type بتاعه لـ `image/jpeg` بسهولة.
>
> **الحل الصح (بالتدرج):**
> ```php
> // 1. Whitelist من الـ Extensions
> $ext = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));
> $allowed = ['jpg', 'jpeg', 'png', 'gif'];
> if (!in_array($ext, $allowed)) { die("Extension غير مسموح"); }
>
> // 2. التحقق من الـ MIME Type الحقيقي (من محتوى الملف)
> $finfo = finfo_open(FILEINFO_MIME_TYPE);
> $mime  = finfo_file($finfo, $_FILES['file']['tmp_name']);
> $allowedMimes = ['image/jpeg', 'image/png', 'image/gif'];
> if (!in_array($mime, $allowedMimes)) { die("MIME Type غير مسموح"); }
> ```

---

> [!question]- 🟡 س٣٤: إيه الفرق بين الـ Session والـ Cookie؟ وامتى تستخدم كل واحد؟
> | | Session | Cookie |
> |---|---|---|
> | مكان الـ Data | السيرفر (`/tmp/sess_xxx`) | المتصفح |
> | الحجم | غير محدود عملياً | 4 KB max |
> | الأمان | أعلى (Data على السيرفر) | أقل (Data عند المستخدم) |
> | الاستمرارية | تنتهي بإغلاق المتصفح (default) | ممكن تستمر لفترة طويلة |
> | الـ ID | الـ PHPSESSID بيتحفظ في Cookie | القيمة الكاملة في Cookie |
>
> استخدم **Session** لـ Login State والبيانات الحساسة. استخدم **Cookie** لتفضيلات المستخدم غير الحساسة (لغة، Theme) اللي محتاج تستمر بعد إغلاق المتصفح.

---

> [!question]- 🔴 س٣٥: ليه `session_start()` لازم تكون قبل أي Output؟ وإيه الـ Session Fixation Attack؟
> **ليه قبل الـ Output:** `session_start()` بتبعت `Set-Cookie: PHPSESSID=...` في الـ HTTP Headers. الـ HTTP Headers لازم تيجي قبل الـ HTTP Body (أي Output). لو عملت `echo` أو طبعت HTML قبلها، الـ Headers اتبعتوا فعلاً والـ PHP بتديك: `Cannot modify header information — headers already sent`.
>
> **Session Fixation Attack:** المهاجم بيبعت لضحيته Link فيه Session ID هو اخترعه (`?PHPSESSID=attacker_known_id`). لو الضحية سجّلت دخول بالـ ID ده، المهاجم بيقدر يستخدم نفس الـ ID يدخل على حسابها.
>
> **الحل:** استخدم `session_regenerate_id(true)` بعد أي Login ناجح عشان تعمل Session ID جديد.
> ```php
> if ($loginSuccessful) {
>     session_regenerate_id(true); // ← ID جديد، القديم اتحذف
>     $_SESSION['user_id'] = $userId;
> }
> ```

---

## 🗄️ القسم التاسع — MySQL وPDO

---

> [!question]- 🟢 س٣٦: إيه الفرق بين MySQLi وPDO؟ وأيهم تختار في مشروع جديد؟
> | | MySQLi | PDO |
> |---|---|---|
> | الـ Databases | MySQL فقط | 12+ Database (MySQL, PostgreSQL, SQLite, ...) |
> | الـ API | Procedural + OOP | OOP فقط |
> | Named Parameters | ❌ (بس `?`) | ✅ (`:name` و `?`) |
> | الأداء | مشابه | مشابه |
>
> **الاختيار:** في أي مشروع جديد، اختار **PDO** دايمًا. أكثر مرونة، وبتقدر تغيّر الـ Database Engine من MySQL لـ PostgreSQL بتغيير الـ DSN بس.

---

> [!question]- 🟡 س٣٧: إيه الـ SQL Injection؟ وإزاي الـ Prepared Statements بتحمي منه؟
> **SQL Injection:** المهاجم بيحقن SQL Code جوّا الـ Input عشان يعدّل الـ Query. مثال:
> ```php
> // ❌ خطر! لو username = "' OR '1'='1"
> $query = "SELECT * FROM users WHERE username = '$username'";
> // Query هتبقى: ... WHERE username = '' OR '1'='1'
> // هترجع كل المستخدمين!
> ```
>
> **الـ Prepared Statements الحل:**
> ```php
> // ✅ آمن — الـ Query والـ Data بيتبعتوا للـ Server منفصلين
> $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
> $stmt->execute([$username]);
> ```
> الـ Database بتفصل الـ Query Structure عن الـ Data — أي شيء في الـ Data بيُعامل كقيمة مش كـ SQL Code.

---

> [!question]- 🟡 س٣٨: إيه الفرق بين `bindParam()` و `bindValue()` في PDO؟
> - **`bindParam($param, &$variable)`:** بيربط بـ **Reference** للمتغير. القيمة بتتقرأ **وقت الـ execute()** — مش وقت الـ Bind. مفيد في الـ Loops.
> - **`bindValue($param, $value)`:** بيربط بـ **القيمة نفسها** وقت الـ Bind. أي تغيير بعده على المتغير مش بيأثر.
>
> ```php
> // bindParam في Loop — قيمة مختلفة في كل iteration
> $stmt = $pdo->prepare("INSERT INTO logs (msg) VALUES (?)");
> foreach ($messages as $msg) {
>     $stmt->bindParam(1, $msg); // ← بياخد القيمة الحالية لـ $msg
>     $stmt->execute();
> }
>
> // bindValue — القيمة بتتحدد فوراً
> $stmt->bindValue(':status', 'active'); // ← "active" محفوظة
> ```

---

> [!question]- 🔴 س٣٩: إيه هو الـ PDO Transaction؟ وإيه مبادئ الـ ACID؟
> **Transaction** هو مجموعة من الـ SQL Operations اللي لازم تنجح **كلها** أو تفشل **كلها**. لو أي خطوة فشلت، بتعمل **Rollback** لكل اللي حصل قبلها.
>
> ```php
> try {
>     $pdo->beginTransaction();
>     $pdo->exec("UPDATE accounts SET balance = balance - 500 WHERE id = 1");
>     $pdo->exec("UPDATE accounts SET balance = balance + 500 WHERE id = 2");
>     $pdo->commit(); // ← لو كل حاجة تمام
> } catch (Exception $e) {
>     $pdo->rollBack(); // ← لو في خطأ، ارجع لما قبل
> }
> ```
>
> **ACID:**
> - **A**tomicity → إما الكل أو لا حاجة.
> - **C**onsistency → الـ Database تفضل في State منطقي.
> - **I**solation → الـ Transactions مش بتأثر على بعض.
> - **D**urability → بعد الـ Commit، البيانات محفوظة حتى لو السيرفر وقع.

---

> [!question]- 🔴 س٤٠: إيه الفرق بين Named وPositional Placeholders في PDO؟ وأيهم أفضل؟
> - **Positional (`?`):** بتحط `?` في الـ Query والقيم بتتبعت بالترتيب.
> - **Named (`:name`):** بتديّ كل Parameter اسم وتبعت الـ Values كـ Associative Array.
>
> ```php
> // Positional — لازم الترتيب يكون صح
> $stmt = $pdo->prepare("INSERT INTO users VALUES (?, ?, ?)");
> $stmt->execute([$name, $email, $age]);
>
> // Named — أوضح وأأمن في الـ Queries الطويلة
> $stmt = $pdo->prepare("INSERT INTO users VALUES (:name, :email, :age)");
> $stmt->execute([':name' => $name, ':email' => $email, ':age' => $age]);
> ```
>
> **Named أفضل** في الـ Queries المعقدة لأن الترتيب مش مهم، والكود أوضح، وتقدر تكرر نفس الـ Parameter في الـ Query أكتر من مرة.

---

## 📅 القسم العاشر — Date & Time

---

> [!question]- 🟢 س٤١: إيه هو الـ Unix Timestamp وليه بيبدأ من 1 January 1970؟
> الـ **Unix Timestamp** هو عدد الـ Seconds اللي عدّت من **1 يناير 1970 الساعة 00:00:00 UTC**. الرقم ده بيُخزّن كـ Integer.
>
> **ليه 1970؟** لأن نظام Unix اتعمل في أواخر الستينات، وقررت الـ Bell Labs إن الـ Epoch (نقطة الصفر) تكون أول 1970 — كان قرار عملي في وقته.
>
> في PHP: `time()` بترجع الـ Timestamp الحالي. أفضل من تخزين التاريخ كـ String لأنه رقم عالمي مش متأثر بالـ Timezone أو الـ Locale.

---

> [!question]- 🟡 س٤٢: إيه الفرق بين `date()` و `DateTime` Class؟ وأيهم أفضل في الـ Code الحديث؟
> - **`date($format, $timestamp)`:** Function قديمة — بتاخد Timestamp وبترجع String.
> - **`DateTime` Class:** OOP Interface — أوضح وأسهل للتعامل مع التواريخ والـ Timezones والـ Arithmetic.
>
> ```php
> // date() — الطريقة القديمة
> echo date('d/m/Y H:i:s', time());
>
> // DateTime — الطريقة الحديثة (أفضل)
> $dt = new DateTime('now', new DateTimeZone('Africa/Cairo'));
> echo $dt->format('d/m/Y H:i:s');
>
> // DateTime Arithmetic — سهل ومقروء
> $dt->modify('+30 days');
> $diff = $dt->diff(new DateTime('2025-01-01'));
> echo $diff->days . " days remaining";
> ```

---

---

## ⚙️ القسم الحادي عشر — Functions وClosures

---

> [!question]- 🟢 س٤٣: إيه الـ Variadic Function في PHP؟ وإزاي تعمل واحدة؟
> الـ Variadic Function هي Function بتقبل **عدد غير محدود من الـ Arguments** بالـ `...` (Spread Operator) قبل الـ Parameter Name. PHP بتجمع كل الـ Arguments الزيادة في **Array**.
>
> ```php
> function sum(string $label, ...$numbers): float {
>     $total = array_sum($numbers); // ← $numbers Array
>     echo "$label: $total";
>     return $total;
> }
>
> sum("Total", 10, 20, 30, 40); // "Total: 100"
> ```

---

> [!question]- 🟡 س٤٤: إيه الـ Closure في PHP؟ وإيه الفرق بين `use` بالـ Value وبالـ Reference؟
> الـ **Closure** هي Anonymous Function بتتخزّن في Variable — هي Object من الـ `Closure` class. مش ليها اسم.
>
> `use` بتخلّي الـ Closure تشوف Variables من الـ Scope الخارجي:
> ```php
> $discount = 0.1;
>
> // use by Value — نسخة من الـ Variable وقت التعريف
> $calcByVal = function($price) use($discount) {
>     return $price * (1 - $discount);
> };
> $discount = 0.5; // تغيير بعد التعريف
> echo $calcByVal(100); // 90 ← مش 50، لأنه شايل النسخة القديمة (0.1)
>
> // use by Reference — بيشوف التغييرات
> $calcByRef = function($price) use(&$discount) {
>     return $price * (1 - $discount);
> };
> echo $calcByRef(100); // 50 ← شاف التغيير (0.5)
> ```

---

> [!question]- 🔴 س٤٥: إيه الفرق بين `bindTo()` و`call()` لربط الـ Closure بالـ Class؟ وامتى تحتاج تحدد الـ Scope؟
> - **`bindTo($object, $class)`:** بيرجع **Closure جديدة** مربوطة بالـ Object. الـ `$class` (الـ Scope) ضروري لو عايز توصل لـ Private/Protected Members.
> - **`call($object)`:** PHP 7+ — بيشغّل الـ Closure مباشرةً على الـ Object بدون ما يرجع Closure جديدة. الـ Scope بيتحدد تلقائياً من الـ Object.
>
> ```php
> class Vault { private $secret = "gold"; }
>
> $peek = function() { echo $this->secret; };
>
> // bindTo مع Scope
> $bound = $peek->bindTo(new Vault(), Vault::class);
> $bound(); // "gold"
>
> // call — أبسط وأنظف
> $peek->call(new Vault()); // "gold"
> ```
> **لازم تحدد الـ Scope** (الـ Class Name) لمّا عايز توصل لـ `private` أو `protected` Members.

---

## 🏛️ القسم الثاني عشر — OOP Basics

---

> [!question]- 🟢 س٤٦: إيه الـ Access Modifiers التلاتة في PHP وإيه وظيفة كل واحد؟
> - **`public`:** متاح من أي مكان — جوّا الـ Class، من الـ Subclasses، ومن بره الـ Class.
> - **`protected`:** متاح جوّا الـ Class ومن الـ Subclasses بس. مش متاح من بره.
> - **`private`:** متاح **بس** جوّا الـ Class اللي عرّفته. الـ Subclasses مش تشوفه ومش ترثه.
>
> القاعدة في الـ Design: خلّي الـ Properties `private` دايمًا وفتح عليهم `public` Getters/Setters لو محتاج — ده الـ Encapsulation الصح.

---

> [!question]- 🟡 س٤٧: إيه الفرق بين `$this` و `self` و `static` جوّا الـ Class؟
> - **`$this`:** مؤشر للـ **Object الحالي** (Instance). بيُستخدم للـ Instance Properties والـ Methods. بيتحدد في الـ Runtime.
> - **`self`:** مؤشر للـ **Class اللي عرّفت الـ Method** فيها. بيُستخدم للـ Static Members والـ Constants. بيتحدد في الـ Compile Time.
> - **`static`:** زي `self` بس بيرجع الـ **Class الفعلية** اللي اتنادي منها (Late Static Binding) — مهم في الـ Inheritance.
>
> ```php
> class ParentClass {
>     public static function create() { return new self(); }   // دايمًا ParentClass
>     public static function make()   { return new static(); } // الـ Class الفعلية
> }
> class Child extends ParentClass {}
> $obj = Child::create(); // instanceof ParentClass ← self
> $obj = Child::make();   // instanceof Child ← static (Late Static Binding)
> ```

---

> [!question]- 🟡 س٤٨: إيه الـ Magic Methods اذكر منها 5 مع وظيفة كل واحد.
> | Magic Method | بيتشغّل لمّا |
> |---|---|
> | `__construct()` | عند إنشاء Object جديد بـ `new` |
> | `__destruct()` | عند حذف الـ Object من الـ RAM (أو انتهاء الـ Script) |
> | `__get($name)` | محاولة قراءة Property غير موجودة أو غير متاحة |
> | `__set($name, $value)` | محاولة كتابة Property غير موجودة أو غير متاحة |
> | `__call($name, $args)` | استدعاء Method غير موجودة على الـ Object |
> | `__callStatic($name, $args)` | استدعاء Static Method غير موجودة |
> | `__toString()` | محاولة استخدام الـ Object كـ String (مع echo) |
> | `__clone()` | بعد عمل `clone` على الـ Object |

---

> [!question]- 🔴 س٤٩: إيه الفرق بين Shallow Copy وDeep Copy في الـ Cloning؟ وإزاي تعمل Deep Copy في PHP؟
> - **Shallow Copy (الافتراضي في PHP):** بيعمل نسخة من الـ Object، لكن الـ Properties اللي هي Objects تانية **مش بتتنسخ** — الـ Original والـ Clone بيشاركوا نفس الـ Object الداخلي.
> - **Deep Copy:** كل حاجة بتتنسخ — حتى الـ Nested Objects.
>
> ```php
> class Address { public $city; }
> class Person {
>     public $name;
>     public Address $address;
>
>     public function __clone() {
>         // Deep Copy: انسخ الـ Nested Object يدوياً
>         $this->address = clone $this->address;
>     }
> }
>
> $p1 = new Person();
> $p1->address = new Address();
> $p1->address->city = "Cairo";
>
> $p2 = clone $p1;
> $p2->address->city = "Alex"; // ← مش هيأثر على $p1 (Deep Copy)
> echo $p1->address->city; // "Cairo" ✅
> ```

---

## 🌳 القسم الثالت عشر — Inheritance وAbstract Classes

---

> [!question]- 🟢 س٥٠: إيه الـ `final` keyword في PHP؟ واستخدمها مع Classes ومع Methods.
> - **`final` Method:** مش ممكن تتـ Override في أي Subclass.
> - **`final` Class:** مش ممكن تتـ Extended خالص.
>
> ```php
> class Animal {
>     final public function breathe() { echo "breathing"; }
>     // ❌ أي Subclass ما تقدرش تعمل override لـ breathe()
> }
>
> final class Singleton {
>     // ❌ مينفعش تعمل class extends Singleton
> }
> ```
> بيُستخدم لمّا عايز تضمن إن الـ Implementation دي مش هتتغيّر في أي مكان في الـ Codebase.

---

> [!question]- 🟡 س٥١: إيه الفرق بين الـ Abstract Class والـ Interface في PHP؟ امتى تستخدم كل واحد؟
> | | Abstract Class | Interface |
> |---|---|---|
> | Methods | ممكن تكون Implemented أو Abstract | كلها Abstract (PHP 8+ ممكن Constants) |
> | Properties | ممكن | ❌ |
> | Inheritance | Class تـ extends واحدة بس | Class تـ implements أكتر من واحدة |
> | Constructor | ممكن | ❌ |
> | الغرض | Base Template مشترك مع Code قابل للمشاركة | عقد/Contract إجباري |
>
> **Abstract Class:** لمّا الـ Subclasses بتشترك في Implementation حقيقية (Code مشترك).
> **Interface:** لمّا بس عايز تضمن إن الـ Class عندها Methods معيّنة (Contract) بغض النظر عن الـ Implementation.

---

> [!question]- 🔴 س٥٢: إيه هو الـ Late Static Binding في PHP وليه مهم في الـ Inheritance؟
> الـ **Late Static Binding** بيُحدد الـ Class الفعلية اللي اتنادي منها الـ Method في الـ Runtime بدل الـ Compile Time.
>
> ```php
> class Base {
>     public static function create_self()   { return new self(); }   // دايمًا Base
>     public static function create_static() { return new static(); } // الـ Class الفعلية
> }
> class Child extends Base {}
>
> $obj1 = Child::create_self();   // instanceof Base   ← self مش بيتغيّر
> $obj2 = Child::create_static(); // instanceof Child  ← static بيتكيّف
> ```
> مهم في الـ Design Patterns زي الـ **Factory Pattern** والـ **Fluent Builder** اللي محتاج فيهم إنك ترجع Instance من الـ Class الحقيقية مش الـ Parent.

---

## 🧩 القسم الرابع عشر — Traits وGenerators

---

> [!question]- 🟡 س٥٣: إيه الـ Traits في PHP ولماذا وُجدوا؟
> الـ **Trait** هو مجموعة Methods تقدر "تستخدمها" (تلصقها) في أي Class بالـ `use` keyword. وُجدوا عشان يحلوا مشكلة **مشاركة الكود** بين Classes مش بترث من بعض — لأن PHP بتدعم Single Inheritance بس.
>
> ```php
> trait Timestamps {
>     public function getCreatedAt(): string { return date('Y-m-d'); }
>     public function getUpdatedAt(): string { return date('Y-m-d H:i:s'); }
> }
>
> class User    { use Timestamps; } // ← Classes مختلفة
> class Product { use Timestamps; } // ← بدون Inheritance
> class Order   { use Timestamps; }
>
> $u = new User();
> echo $u->getCreatedAt(); // "2025-01-15"
> ```
> الـ Trait مينفعش يتـ Instantiate لوحده. هو مجرد "مجموعة Methods جاهزة للنسخ".

---

> [!question]- 🟡 س٥٤: إيه الـ Generators في PHP؟ وإيه الفرق الجوهري بين `yield` و `return`؟
> الـ **Generator** هو Function فيها `yield` بدل `return`. بدل ما ترجع كل البيانات دفعة واحدة، بترجع **قيمة واحدة في كل مرة** بتطلبها.
>
> `return` → بتوقف الـ Function وترجع قيمة وتنهي.
> `yield` → بتوقف الـ Function مؤقتاً، بترجع قيمة، وبتستكمل من نفس المكان المرة الجاية.
>
> ```php
> // بدون Generator: بيخزّن مليون رقم في الـ RAM (~33 MB)
> function oldWay($n) { $arr = []; for($i=0;$i<$n;$i++) $arr[]=rand(); return $arr; }
>
> // مع Generator: بيخزّن رقم واحد في كل مرة (~1 KB)
> function newWay($n) { for($i=0;$i<$n;$i++) yield rand(); }
>
> foreach (newWay(1000000) as $num) { /* معالجة */ }
> ```

---

> [!question]- 🔴 س٥٥: إيه اللي بيحصل لو كان فيه تعارض في Method Names بين Traits مختلفة في نفس الـ Class؟
> لو استخدمت Traits متعددة عندهم Method بنفس الاسم، PHP بتطلع **Fatal Error** لحد ما تحل التعارض يدوياً بالـ `insteadof` و `as` keywords:
>
> ```php
> trait A { public function hello() { echo "Hello from A"; } }
> trait B { public function hello() { echo "Hello from B"; } }
>
> class MyClass {
>     use A, B {
>         A::hello insteadof B; // ← استخدم الـ hello بتاعت A
>         B::hello as helloB;   // ← اعمل Alias للـ hello بتاعت B
>     }
> }
>
> $obj = new MyClass();
> $obj->hello();  // "Hello from A"
> $obj->helloB(); // "Hello from B"
> ```

---

## 🦜 القسم الخامس عشر — Polymorphism وReflection وNamespaces

---

> [!question]- 🟡 س٥٦: إيه الفرق بين Method Overriding وMethod Overloading؟ وإزاي PHP بتتعامل مع كل واحد؟
> - **Method Overriding (Runtime Polymorphism):** الـ Subclass بتعرّف Method بنفس اسم الـ Parent وتغيّر الـ Implementation. ده اللي PHP بتدعمه بالشكل العادي.
> - **Method Overloading (Compile-Time Polymorphism):** نفس الـ Method باختلاف الـ Parameters (زي Java/C++). PHP **مش بتدعمه** بالشكل الكلاسيكي.
>
> PHP بتحاكي الـ Overloading بـ `__call()`:
> ```php
> class FlexClass {
>     public function __call($name, $args) {
>         // بتتصرف حسب اسم الـ Method وعدد الـ Arguments
>         if ($name === 'save' && count($args) === 1) {
>             echo "Saving: {$args[0]}";
>         }
>     }
> }
> ```

---

> [!question]- 🟡 س٥٧: إيه الـ Anonymous Classes في PHP 7؟ وامتى تستخدمها؟
> الـ **Anonymous Class** هي Class من غير اسم بتتعرّف وبتتـ Instantiate في نفس الوقت. بتستخدمها لمّا محتاج Object بسيط مرة واحدة ومش هتعوزه تاني.
>
> ```php
> interface Logger {
>     public function log(string $msg): void;
> }
>
> function process(Logger $logger) {
>     $logger->log("Processing started");
> }
>
> // بدل ما تعرّف Class كاملة، استخدم Anonymous
> process(new class implements Logger {
>     public function log(string $msg): void {
>         echo "[LOG] $msg\n";
>     }
> });
> ```
> مفيدة في الـ Testing (Mocking) وفي الـ Callbacks اللي محتاج فيها Object صغير.

---

> [!question]- 🟡 س٥٨: إيه هو الـ Reflection في PHP وامتى يُستخدم؟
> الـ **Reflection API** بتسمح للكود يفحص نفسه في الـ Runtime — يعرف إيه الـ Methods والـ Properties والـ Attributes الموجودة في أي Class.
>
> ```php
> class MyService {
>     private string $name;
>     public function getName(): string { return $this->name; }
>     public function setName(string $n): void { $this->name = $n; }
> }
>
> $ref = new ReflectionClass(MyService::class);
> foreach ($ref->getMethods() as $method) {
>     echo $method->getName() . " — " .
>          ($method->isPublic() ? "public" : "private") . "\n";
> }
> ```
> بيُستخدم في: **Unit Testing** (PHPUnit)، **Dependency Injection Containers** (Symfony/Laravel)، وبناء **Framework Features** زي Auto-wiring.

---

> [!question]- 🔴 س٥٩: إيه هو الـ Namespace في PHP وإزاي يحل مشكلة الـ Name Collision؟
> الـ **Namespace** بيمنع التعارض في أسماء الـ Classes والـ Functions لمّا بتستخدم Libraries مختلفة عندهم نفس الأسماء.
>
> ```php
> // ملف: App/Database.php
> namespace App\Services;
> class Database { public function connect() { echo "App DB"; } }
>
> // ملف: Third/Database.php
> namespace ThirdParty\Db;
> class Database { public function connect() { echo "Third DB"; } }
>
> // ملف: index.php
> use App\Services\Database as AppDB;
> use ThirdParty\Db\Database as ThirdDB;
>
> (new AppDB())->connect();   // "App DB"
> (new ThirdDB())->connect(); // "Third DB"
> ```
> قاعدة: الـ Namespace لازم يكون أول Statement في الـ File (قبل أي Code). الـ PSR-4 Standard بيربط الـ Namespace بـ Directory Structure.

---

## 🔥 القسم السادس عشر — أسئلة متقدمة مركّبة

---

> [!question]- 🔴 س٦٠: ازاي تبني Singleton Design Pattern في PHP بشكل صح؟
> الـ **Singleton** بيضمن إن Class ما عندهاش غير Instance واحدة طول عمر الـ Application.
>
> ```php
> class DatabaseConnection {
>     private static ?self $instance = null;
>     private \PDO $pdo;
>
>     // ← Constructor Private عشان يمنع new من بره
>     private function __construct() {
>         $this->pdo = new \PDO('mysql:host=localhost;dbname=mydb', 'user', 'pass');
>     }
>
>     // ← منع الـ Clone
>     private function __clone() {}
>
>     // ← منع الـ Unserialization
>     public function __wakeup() { throw new \Exception("Cannot unserialize"); }
>
>     public static function getInstance(): self {
>         if (self::$instance === null) {
>             self::$instance = new self();
>         }
>         return self::$instance;
>     }
>
>     public function getPdo(): \PDO { return $this->pdo; }
> }
>
> $db1 = DatabaseConnection::getInstance();
> $db2 = DatabaseConnection::getInstance();
> var_dump($db1 === $db2); // bool(true) ← نفس الـ Object
> ```

---

> [!question]- 🔴 س٦١: إيه الفرق بين `interface` و `abstract class` في سياق الـ Dependency Injection؟
> في الـ DI، الـ Interface هو الـ Contract المثالي لأن:
> 1. الـ Code بيعتمد على الـ Abstraction مش الـ Implementation (SOLID - Dependency Inversion).
> 2. تقدر تغيّر الـ Implementation من غير ما تغيّر الـ Code اللي بيستخدمه.
>
> ```php
> interface CacheDriver {
>     public function get(string $key): mixed;
>     public function set(string $key, mixed $value, int $ttl = 3600): void;
> }
>
> class RedisCache implements CacheDriver { /* ... */ }
> class FileCache  implements CacheDriver { /* ... */ }
>
> class UserService {
>     // ← بيعتمد على الـ Interface مش الـ Implementation
>     public function __construct(private CacheDriver $cache) {}
>
>     public function getUser(int $id): array {
>         $key = "user:$id";
>         return $this->cache->get($key) ?? $this->fetchFromDb($id);
>     }
> }
>
> // تقدر تستبدل Redis بـ File Cache من غير ما تعدّل UserService
> $service = new UserService(new FileCache());
> ```

---

> [!question]- 🔴 س٦٢: إيه الفرق بين الـ `__toString()` Magic Method والـ `Stringable` Interface في PHP 8؟
> - **`__toString()`:** Magic Method بتحوّل الـ Object لـ String لمّا تستخدمه في سياق String (مع `echo`, string concatenation, إلخ).
> - **`Stringable` Interface:** PHP 8 أضافت الـ Interface دي — أي Class عندها `__toString()` بتـ Implement الـ `Stringable` تلقائياً. بتيجي في وجودها فايدة كبيرة في الـ Type Hinting.
>
> ```php
> class Money {
>     public function __construct(
>         private float $amount,
>         private string $currency = 'EGP'
>     ) {}
>
>     public function __toString(): string {
>         return number_format($this->amount, 2) . ' ' . $this->currency;
>     }
> }
>
> // Type Hinting بالـ Interface
> function displayPrice(Stringable|string $price): void {
>     echo "السعر: $price\n";
> }
>
> $price = new Money(250.5);
> displayPrice($price); // "السعر: 250.50 EGP"
> echo $price;          // "250.50 EGP"
> ```

---

> [!question]- 🔴 س٦٣: إيه الـ Named Arguments في PHP 8 وإزاي بيغيّروا طريقة استخدام Functions؟
> الـ **Named Arguments** بيسمحوا إنك تبعت الـ Arguments للـ Function بالاسم بدل الترتيب — مفيد جداً للـ Functions اللي عندها parameters كتيرة أو اختيارية.
>
> ```php
> // الطريقة القديمة — لازم تتذكر الترتيب
> $result = array_slice($array, 0, 5, true);
>
> // Named Arguments — واضح ومقروء
> $result = array_slice(
>     array: $array,
>     offset: 0,
>     length: 5,
>     preserve_keys: true
> );
>
> // مفيد جداً مع Constructor Promotion
> class Config {
>     public function __construct(
>         public readonly string $host = 'localhost',
>         public readonly int    $port = 3306,
>         public readonly string $charset = 'utf8mb4'
>     ) {}
> }
>
> $cfg = new Config(port: 5432, charset: 'utf8'); // بدون ما تحدد host
> ```

---

> [!question]- 🔴 س٦٤: إيه الـ Fibers في PHP 8.1 وإزاي بتختلف عن الـ Generators؟
> الـ **Fibers** هي آلية لـ **Cooperative Multitasking** — بتخلي الكود يوقف تنفيذه ويدي الـ Control لجزء تاني، وبعدين يرجع يكمل من نفس المكان.
>
> | | Generator | Fiber |
> |---|---|---|
> | التواصل | من الـ Generator للـ Caller فقط | في الاتجاهين |
> | الاستخدام | Iterating على Data | Async-style Programming |
> | الـ Suspension | بـ `yield` | بـ `Fiber::suspend()` |
>
> ```php
> $fiber = new Fiber(function(): void {
>     $value = Fiber::suspend('first');  // ← بيوقف وبيبعت 'first'
>     echo "Got: $value\n";             // ← بيكمل لمّا يتنادى resume()
>     Fiber::suspend('second');
> });
>
> $val1 = $fiber->start();       // $val1 = 'first'
> $val2 = $fiber->resume('hi'); // طبع "Got: hi"، $val2 = 'second'
> ```
> الـ Fibers هي الأساس اللي الـ Async Frameworks زي ReactPHP وAmphp بتبنى عليه.

---

> [!question]- 🔴 س٦٥: لو عندك هذا الكود، إيه الـ Output وليه؟
> ```php
> class Counter {
>     private static int $count = 0;
>     public function __construct() { self::$count++; }
>     public function __destruct() { self::$count--; }
>     public static function getCount(): int { return self::$count; }
> }
>
> $a = new Counter();
> $b = new Counter();
> $c = clone $b;
> unset($b);
> echo Counter::getCount();
> ```
> **الإجابة: `2`**
>
> التحليل خطوة بخطوة:
> 1. `new Counter()` → `__construct()` → `$count = 1`
> 2. `new Counter()` → `__construct()` → `$count = 2`
> 3. `clone $b` → **`__construct()` مش بيتشغّل عند الـ Clone!** → `$count = 2` (لو محتاج، استخدم `__clone()`)
> 4. `unset($b)` → `__destruct()` → `$count = 1`... بس `$c` هي clone من `$b` والـ `$a` لسه موجودة.
>
> **الـ Output:** `2` (الـ `$a` والـ `$c` لسه في الـ RAM)

---

## 📊 ملخص الأسئلة حسب المستوى

| المستوى | عدد الأسئلة | الأقسام |
|---|---|---|
| 🟢 سهل | 16 سؤال | Basics, Types, File Modes, Arrays Basics |
| 🟡 متوسط | 30 سؤال | OOP, PDO, Regex, Sessions, Traits |
| 🔴 صعب | 19 سؤال | Zend Engine, Transactions, Fibers, Design Patterns |

---

> **نصيحة أخيرة:** مش كفاية تقرأ الأجوبة — اكتبها بنفسك في IDE واتأكد إنها بتشتغل. الـ Muscle Memory أهم من الـ Memory في الإنترفيو. 🚀
