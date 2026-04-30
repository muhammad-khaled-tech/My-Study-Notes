---
title: PHP & Laravel Fundamentals — Study Notes
subject: Backend Development
date: 2026-04-30
topics:
  - PHP Introduction & Execution Model
  - PHP Tags & Syntax
  - Echo vs Print
  - Variables & Scope
  - Superglobals
  - References
  - isset / unset
  - Type System (Casting, Juggling, gettype, settype)
  - Falsy Values
  - Operators (Arithmetic, Comparison, Spaceship)
  - Control Flow (Switch, Match, Loops)
  - Break, Continue, Exit
---

# PHP & Laravel Fundamentals

## Table of Contents

- [1. PHP Foundations](#1-php-foundations)
  - [1.1 What is PHP?](#11-what-is-php)
  - [1.2 PHP Tags](#12-php-tags)
  - [1.3 PHP in HTML vs Standalone](#13-php-in-html-vs-standalone)
  - [1.4 Echo vs Print](#14-echo-vs-print)
- [2. Variables & Data Handling](#2-variables--data-handling)
  - [2.1 Variables & Scope](#21-variables--scope)
  - [2.2 Superglobals](#22-superglobals)
  - [2.3 References](#23-references)
  - [2.4 isset & unset](#24-isset--unset)
- [3. Type System](#3-type-system)
  - [3.1 Casting](#31-casting)
  - [3.2 Type Juggling](#32-type-juggling)
  - [3.3 gettype vs settype](#33-gettype-vs-settype)
  - [3.4 Falsy Values](#34-falsy-values)
- [4. Operators](#4-operators)
  - [4.1 Arithmetic & String](#41-arithmetic--string)
  - [4.2 Assignment](#42-assignment)
  - [4.3 Comparison & Spaceship](#43-comparison--spaceship)
  - [4.4 Increment & Decrement](#44-increment--decrement)
- [5. Control Flow](#5-control-flow)
  - [5.1 Switch & Match](#51-switch--match)
  - [5.2 Loops](#52-loops)
  - [5.3 Break, Continue & Exit](#53-break-continue--exit)
- [6. Master Cheat Sheet](#6-master-cheat-sheet)

---

# 1. PHP Foundations

## 1.1 What is PHP?

**PHP** (Hypertext Preprocessor) is a server-side scripting language that processes requests on the server and returns pure HTML to the browser. The client never sees PHP source code.

**Execution Flow:**
```
Browser Request → Web Server → PHP Runtime → (DB if needed) → Pure HTML → Browser
```

```php
<?php
  $name = "Ahmed";
  echo "Hello, " . $name . "!";
  // Output: Hello, Ahmed!
?>
```

| PHP Concept | JS / Node Equivalent |
|:---|:---|
| Server-side execution | Node.js / Django |
| `echo` | `console.log()` (outputs to browser) |
| `.` string concat | `+` string concat |
| `.php` file | `.js` route/controller file |

> ⚠️ PHP powers 79% of the web including WordPress and Laravel. Forgetting `;` at line end is the most common beginner error.

> 🔗 **Next:** PHP needs tags to distinguish code from plain text — see [1.2 PHP Tags](#12-php-tags).

---

## 1.2 PHP Tags

**PHP tags** are delimiters that tell the server where PHP code begins and ends. Without them, everything is treated as plain text.

```php
// ✅ Standard XML Tag — always use this
<?php echo '<p>Hello!</p>'; ?>

// ⚠️ Short Tag — needs php.ini config, avoid
<? echo '<p>Hello!</p>'; ?>

// ❌ SCRIPT Style — removed in PHP 7+
<script language='php'> echo '<p>Hello!</p>'; </script>

// ❌ ASP Style — disabled by default
<% echo '<p>Hello!</p>'; %>
```

| Style | Works By Default | PHP Version | Use? |
|:---|:---|:---|:---|
| `<?php ?>` | ✅ Yes | All | ✅ Always |
| `<? ?>` | ⚠️ Config needed | All | ❌ Avoid |
| `<script language='php'>` | ❌ No | Removed PHP 7+ | ❌ Never |
| `<% %>` | ❌ No | Disabled | ❌ Never |

> 💡 In pure PHP files with no HTML, omit the closing `?>` tag entirely — prevents accidental whitespace bugs.

---

## 1.3 PHP in HTML vs Standalone

PHP was designed to be embedded in HTML but also runs as a standalone CLI script — just like Node.js scripts.

```php
<!-- Embedded in HTML (.php file) -->
<html>
  <body>
    <h1><?php echo "Hello, Ahmed!"; ?></h1>
  </body>
</html>
```

```bash
# Standalone CLI execution
php script.php
# Output: Hello, Ahmed!
```

| Mode | Like In Your World | Use Case |
|:---|:---|:---|
| Embedded in HTML | Django templates | Classic PHP apps |
| Standalone script | `node script.js` | CLI tools, cron jobs |
| Pure API backend | Express.js | Laravel as JSON API |

> 💡 Your instructor starts with PHP-in-HTML to visually show what PHP outputs. In **Laravel**, you'll use **Blade templates** — cleaner, closer to Angular `*ngFor` or Django `{{ variable }}`.

---

## 1.4 Echo vs Print

Both output strings to the browser. `echo` is the universal choice.

```php
<?php
echo "Hello", " Ahmed";   // Output: Hello Ahmed — multiple args ✅
print "Hello";             // Output: Hello — single arg only
$x = print "Hi";          // Output: Hi — $x = 1 (unique to print)
// Output: $x is int(1)
?>
```

| Feature | `echo` | `print` |
|:---|:---|:---|
| Speed | Slightly faster | Slightly slower |
| Returns | `void` | `1` (usable in expressions) |
| Arguments | Multiple (comma-separated) | Single only |
| JS Equivalent | `console.log()` | N/A |

> ⚠️ Always use `echo`. `print` exists but you'll rarely need it in real projects.

---

# 2. Variables & Data Handling

## 2.1 Variables & Scope

All PHP variables are prefixed with `$`. PHP scope is **stricter than JS** — global variables are invisible inside functions unless explicitly imported.

```php
<?php
$globalName = "Ahmed"; // Global scope

// ─── LOCAL SCOPE ──────────────────────────────
function greet() {
    $local = "Ali";       // Dies when function ends
    echo $globalName;     // ❌ Undefined — PHP blocks globals
    
    global $globalName;   // ✅ Explicit import required
    echo $globalName;     // Output: Ahmed
}

// ─── STATIC SCOPE ─────────────────────────────
function counter() {
    static $count = 0;    // Survives between calls unlike local vars
    $count++;
    echo $count . "\n";
}
counter(); // Output: 1
counter(); // Output: 2
counter(); // Output: 3
?>
```

| Scope | Visibility | Keyword |
|:---|:---|:---|
| Local | Inside function only | none |
| Global | Outside functions only | `global $x` to import |
| Static | Inside function, persists | `static` |
| Superglobal | Everywhere, always | none needed |

> ⚠️ `$Name` and `$name` are **two different variables** — PHP is case-sensitive.

> ⚠️ Avoid `global` in Laravel — use **Dependency Injection** instead. `global` is a code smell in modern PHP.

> 🔗 Superglobals are the special case of scope — they break all rules. See [2.2 Superglobals](#22-superglobals).

---

## 2.2 Superglobals

**Superglobals** are PHP's built-in arrays, automatically populated before your code runs, accessible from any scope with no keyword needed.

```php
<?php
// ─── $_GET — URL parameters ────────────────────
// URL: example.com/user?id=5&name=Ahmed
echo $_GET['id'];             // Output: 5
echo $_GET['name'];           // Output: Ahmed

// ─── $_POST — Form body data ───────────────────
echo $_POST['email'];         // Output: user@example.com
echo $_POST['password'];      // Hidden from URL ✅

// ─── $_FILES — File uploads ────────────────────
// Structure of $_FILES['avatar']:
// [name] => photo.jpg | [type] => image/jpeg
// [tmp_name] => /tmp/php123 | [error] => 0 | [size] => 204800

move_uploaded_file(
    $_FILES['avatar']['tmp_name'],
    'uploads/' . $_FILES['avatar']['name']  // Move to permanent storage
);

// ─── $_SESSION ─────────────────────────────────
session_start();              // Must call first — like initializing middleware
$_SESSION['user_id'] = 42;
$_SESSION['role']    = 'admin';
echo $_SESSION['user_id'];    // Output: 42
session_destroy();            // Logout — destroys all session data

// ─── $_SERVER — Request metadata ───────────────
echo $_SERVER['REQUEST_METHOD']; // Output: GET or POST
echo $_SERVER['REMOTE_ADDR'];    // Output: user's IP
echo $_SERVER['HTTP_HOST'];      // Output: example.com

// ─── $_COOKIE ──────────────────────────────────
setcookie("user", "Ahmed", time() + 3600); // Expires in 1 hour
echo $_COOKIE['user'];        // Output: Ahmed (on NEXT request ⚠️)
?>
```

| Superglobal | Express.js Equivalent | Source |
|:---|:---|:---|
| `$_GET` | `req.query` | URL `?key=value` |
| `$_POST` | `req.body` | Form/JSON body |
| `$_REQUEST` | combined | GET + POST + COOKIE (avoid) |
| `$_FILES` | `req.file` (Multer) | `<input type="file">` |
| `$_SESSION` | `req.session` | Server-side memory |
| `$_COOKIE` | `req.cookies` | Browser storage |
| `$_ENV` | `process.env` | Server environment |
| `$_SERVER` | `req` object | Request headers & metadata |

> ⚠️ `$_COOKIE` set during current request is **not available until the next request**.

> ⚠️ **Never trust raw superglobal data** — always validate and sanitize before DB operations.

> 💡 **Laravel wraps all of these cleanly:**
> ```php
> $request->input('name');   // replaces $_GET / $_POST
> $request->file('avatar');  // replaces $_FILES
> $request->ip();            // replaces $_SERVER['REMOTE_ADDR']
> session('user_id');        // replaces $_SESSION
> ```

---

## 2.3 References

A **reference** (`&`) makes two variables point to the same memory location. Changing one changes both — identical to C++ pointers, but works on PHP primitives too.

```php
<?php
// ─── Basic Reference ───────────────────────────
$a = 5;
$b = &$a;   // $b points to same memory slot as $a
$b = 10;
echo $a;    // Output: 10 — changed via reference

// ─── Without reference (copy) ──────────────────
$c = $a;    // $c is an independent copy
$c = 99;
echo $a;    // Output: 10 — unchanged

// ─── Function Reference ────────────────────────
function addTen(&$value) {
    $value += 10;     // Modifies original, no return needed
}
$num = 5;
addTen($num);
echo $num;  // Output: 15
?>
```

| Behavior | Without `&` | With `&` |
|:---|:---|:---|
| Assignment | Creates a copy | Shares same memory |
| Modify copy | Original unchanged | Original changes too |
| C++ equivalent | Value copy | `int* ptr = &var` |
| JS equivalent | Primitive copy | Object reference |

> 🔗 In **Laravel**, you'll rarely use raw references — dependency injection handles shared state cleanly.

---

## 2.4 isset & unset

```php
<?php
$name  = "Ahmed";
$empty = "";
$null  = null;

// ─── isset() — exists AND is not null ──────────
var_dump(isset($name));    // bool(true)  — exists + has value
var_dump(isset($empty));   // bool(true)  — empty string ≠ null
var_dump(isset($null));    // bool(false) — exists but IS null ⚠️
var_dump(isset($age));     // bool(false) — never defined

// ─── unset() — destroy the variable ───────────
unset($name);
var_dump(isset($name));    // bool(false) — gone permanently

// ─── Real world: safe $_GET access ─────────────
if (isset($_GET['id'])) {
    $id = (int) $_GET['id'];   // Safe to use ✅
}
?>
```

| Function | Job | Returns | Modifies? | JS Equivalent |
|:---|:---|:---|:---|:---|
| `isset()` | Check exists & not null | `bool` | ❌ | `!== undefined && !== null` |
| `unset()` | Destroy variable | `void` | ✅ | `delete obj.key` |

> ⚠️ `isset()` returns `false` even if the variable exists but holds `null`. Use `array_key_exists()` when you need to detect `null` values in arrays.

> 💡 **Laravel replaces `isset($_GET)` with:** `$request->has('id')` or `$request->filled('id')`.

---

# 3. Type System

## 3.1 Casting

**Casting** forces a variable into a specific type at runtime. Critical because `$_GET` / `$_POST` data always arrives as strings.

```php
<?php
$value = "42.9abc";   // Typical raw input string

$asInt    = (int)    $value;  // Output: 42        — stops at non-numeric
$asFloat  = (float)  $value;  // Output: 42.9      — stops at non-numeric
$asString = (string) $value;  // Output: "42.9abc" — unchanged
$asBool   = (bool)   $value;  // Output: true      — non-empty = true
$asArray  = (array)  $value;  // Output: ["42.9abc"]

// ─── Safe DB input ─────────────────────────────
$id = (int) $_GET['id'];  // "5abc" → 5 ✅ safe for queries
?>
```

| Cast | Result | JS Equivalent |
|:---|:---|:---|
| `(int)` | Integer, strips decimals | `parseInt()` |
| `(float)` | Decimal number | `parseFloat()` |
| `(string)` | String | `String()` |
| `(bool)` | Boolean | `Boolean()` |
| `(array)` | Single-element array | `Array.from()` |

> ⚠️ **Bool trap:** `(bool) "false"` is `true` — the string is non-empty. Only `0`, `"0"`, `""`, `[]`, and `null` cast to `false`.

> ⚠️ Casting is not a substitute for **validation**. Validate first, then cast.

> 🔗 **Laravel Model Casting** — same concept, declarative:
> ```php
> protected $casts = [
>     'is_admin' => 'boolean',
>     'score'    => 'float',
>     'settings' => 'array',   // Auto-converts JSON ↔ PHP array
> ];
> ```

---

## 3.2 Type Juggling

**Type juggling** is PHP's automatic type conversion based on context — it happens without you asking.

```php
<?php
// PHP reads strings left-to-right, extracts leading numeric value
echo "15 case" + 5;   // Output: 20  — extracts 15, adds 5
echo "Omnia"   + 5;   // Output: 5   — no number found, "Omnia" = 0
echo "3.5abc"  + 1;   // Output: 4.5 — extracts 3.5, adds 1
echo "abc123"  + 1;   // Output: 1   — starts with letter = 0
?>
```

**Extraction Rule:**
```
"15 case"  → 15    ✅ starts with number
"Omnia"    → 0     ⚠️ starts with letter
"3.5abc"   → 3.5   ✅ starts with float
"abc123"   → 0     ⚠️ starts with letter
```

> ⚠️ **Critical JS difference:** `"15 case" + 5` in JS returns `"15 case5"` (string concat). PHP returns `20` (math). Major behavioral fork between the two languages.

> 💡 Use explicit casting `(int)` to remove juggling ambiguity. Don't rely on juggling in production code.

---

## 3.3 gettype vs settype

```php
<?php
$var = "42";

echo gettype($var);          // Output: string — read only, non-destructive

settype($var, "integer");    // Permanently mutates $var
echo $var;                   // Output: 42
echo gettype($var);          // Output: integer

// ─── Casting vs settype ────────────────────────
$x = "42";
$y = (int) $x;               // $x stays "string", $y is new int
settype($x, "integer");      // $x itself becomes int permanently ⚠️
?>
```

| Function | Destructive | Returns | JS Equivalent |
|:---|:---|:---|:---|
| `gettype()` | ❌ Read-only | Type name as `string` | `typeof` |
| `settype()` | ✅ Mutates original | `true` / `false` | None |

> 💡 Prefer `(int)$x` casting over `settype()` — safer, non-destructive, and more readable in Laravel code.

---

## 3.4 Falsy Values

Values that evaluate to `false` in a boolean context.

```php
<?php
var_dump((bool) 0);       // bool(false)
var_dump((bool) 0.0);     // bool(false)
var_dump((bool) "");      // bool(false)
var_dump((bool) "0");     // bool(false) ⚠️ only "0", not "false"
var_dump((bool) []);      // bool(false)
var_dump((bool) null);    // bool(false)

// Everything else is TRUTHY, including:
var_dump((bool) "false"); // bool(true) — non-empty string ⚠️
var_dump((bool) [0]);     // bool(true) — non-empty array
?>
```

| Value | PHP | JavaScript |
|:---|:---|:---|
| `0` | `false` | `false` |
| `""` | `false` | `false` |
| `"0"` | `false` | ✅ `true` ⚠️ |
| `[]` | `false` | ✅ `true` ⚠️ |
| `null` | `false` | `false` |
| `"false"` | `true` | `true` |

> ⚠️ **Biggest trap for JS devs:** In PHP, `"0"` and `[]` are **falsy**. In JS, both are **truthy**. This causes silent bugs in full-stack codebases.

---

# 4. Operators

## 4.1 Arithmetic & String

```php
<?php
$x = 10; $y = 3;

echo $x + $y;    // Output: 13   — addition
echo $x - $y;    // Output: 7    — subtraction
echo $x * $y;    // Output: 30   — multiplication
echo $x / $y;    // Output: 3.33 — division
echo $x % $y;    // Output: 1    — modulus (remainder)
echo $x ** $y;   // Output: 1000 — exponentiation (10³)

// ─── String operators ──────────────────────────
$a = "Hello, ";
$b = "World!";
echo $a . $b;    // Output: Hello, World! — concatenation
$a .= $b;        // $a is now "Hello, World!" — append in place
?>
```

| Operator | PHP | JS Equivalent |
|:---|:---|:---|
| `+` `-` `*` `/` `%` | Same | Same |
| `**` | Power | `**` (ES7+) or `Math.pow()` |
| `.` | String concat | `+` |
| `.=` | String append | `+=` |

---

## 4.2 Assignment

```php
<?php
$x = 5;
$x += 3;    // $x = 8   — same as JS
$x -= 3;    // $x = 5
$x *= 2;    // $x = 10
$x /= 2;    // $x = 5
$x %= 3;    // $x = 2

$str = "Hello ";
$str .= "World";  // $str = "Hello World" — PHP-specific string append
?>
```

> 💡 `.=` is the only PHP-specific assignment operator. All others are identical to JS.

---

## 4.3 Comparison & Spaceship

```php
<?php
$x = 5; $y = "5";

var_dump($x == $y);    // bool(true)  — loose, type juggling applied
var_dump($x === $y);   // bool(false) — strict, int ≠ string ⚠️
var_dump($x != $y);    // bool(false)
var_dump($x <> $y);    // bool(false) — identical to !=, PHP-only legacy
var_dump($x !== $y);   // bool(true)  — strict not-equal

// ─── Spaceship <=> — PHP-specific ─────────────
echo 5  <=> 10;   // Output: -1  (left is smaller)
echo 10 <=> 10;   // Output:  0  (equal)
echo 10 <=>  5;   // Output:  1  (left is greater)

// Practical use — array sorting (like JS array.sort((a,b) => a-b))
usort($array, fn($a, $b) => $a <=> $b);
?>
```

| Operator | Meaning | JS Equivalent |
|:---|:---|:---|
| `==` | Equal value (loose) | `==` |
| `===` | Equal value + type | `===` |
| `!=` | Not equal | `!=` |
| `<>` | Not equal (legacy) | ❌ None |
| `!==` | Not equal strict | `!==` |
| `<=>` | Spaceship (-1/0/1) | ❌ None |
| `> < >= <=` | Comparison | Same |

> ⚠️ **Always prefer `===`** over `==` to avoid silent type juggling bugs.

---

## 4.4 Increment & Decrement

Identical to JS — pre vs post determines when the change happens.

```php
<?php
$x = 5;
$y = ++$x;   // Increment first, then assign → $x = 6, $y = 6
$z = $x++;   // Assign first, then increment → $z = 6, $x = 7

// Rule: ++ before = change BEFORE use
//       ++ after  = change AFTER use
?>
```

---

# 5. Control Flow

## 5.1 Switch & Match

**`switch`** uses loose `==` comparison with fall-through. **`match`** (PHP 8+) uses strict `===`, no fall-through, and returns a value.

```php
<?php
$day = "Monday";

// ─── Switch (Classic) ──────────────────────────
switch($day) {
    case "Monday":
        echo "Start of week";
        break;              // ⚠️ Missing break = falls to next case silently
    case "Friday":
        echo "Almost weekend";
        break;
    default:
        echo "Midweek";
}

// ─── Match (PHP 8+ — Preferred) ────────────────
$result = match($day) {
    "Monday"          => "Start of week",   // Strict === comparison
    "Friday"          => "Almost weekend",  // No break needed
    default           => "Midweek",
};
echo $result;   // Output: Start of week
?>
```

| Feature | `switch` | `match` |
|:---|:---|:---|
| Comparison | `==` loose | `===` strict |
| Fall-through | ✅ Yes (needs `break`) | ❌ No |
| Returns value | ❌ No | ✅ Yes |
| PHP version | All | PHP 8+ |

> 💡 Prefer `match` in new code — it's safer, stricter, and cleaner.

---

## 5.2 Loops

PHP loop syntax is nearly identical to JS. `foreach` is the idiomatic PHP loop for arrays.

```php
<?php
// ─── For (Same as JS) ──────────────────────────
for ($i = 0; $i < 5; $i++) {
    echo $i;   // Output: 0 1 2 3 4
}

// ─── While ─────────────────────────────────────
$i = 0;
while ($i < 5) {
    echo $i;   // Output: 0 1 2 3 4
    $i++;
}

// ─── Do While — runs at least once ─────────────
$i = 10;
do {
    echo $i;   // Output: 10 — runs once even though condition is false
} while ($i < 5);

// ─── Foreach — ⭐ Most used in PHP & Laravel ────
$names = ["Ahmed", "Omnia", "Ali"];

foreach ($names as $name) {
    echo $name;   // Output: Ahmed Omnia Ali
}

foreach ($names as $index => $name) {
    echo "$index: $name\n";
    // Output: 0: Ahmed
    //         1: Omnia
    //         2: Ali
}

// Associative array (like JS object)
$user = ["name" => "Ahmed", "age" => 25];
foreach ($user as $key => $value) {
    echo "$key: $value\n";
    // Output: name: Ahmed
    //         age: 25
}
?>
```

| Loop | PHP | JS Equivalent |
|:---|:---|:---|
| `for` | Same | Same |
| `while` | Same | Same |
| `do...while` | Same | Same |
| `foreach` | `foreach($arr as $v)` | `for...of` |
| Key + Value | `foreach($arr as $k => $v)` | `for...in` / `Object.entries()` |

> 💡 **In Laravel Blade:** `@foreach($items as $item)` mirrors Angular's `*ngFor` and React's `.map()`.

---

## 5.3 Break, Continue & Exit

```php
<?php
for ($i = 0; $i < 10; $i++) {
    if ($i == 2) continue;   // Skip iteration — jump to next
    if ($i == 5) break;      // Stop loop — resume after loop
    echo $i;   // Output: 0 1 3 4
}
echo "After loop";   // ✅ This runs after break

// ─── Break with depth — PHP specific ───────────
for ($i = 0; $i < 3; $i++) {
    for ($j = 0; $j < 3; $j++) {
        if ($j == 1) break 2;   // Exits BOTH loops — JS cannot do this
        echo "$i,$j ";
    }
}
// Output: 0,0

// ─── Exit — kills entire script ────────────────
exit();             // Stop silently
exit(0);            // Stop — success (like process.exit(0))
exit(1);            // Stop — error
exit("Error msg");  // Stop + print message

echo "Never runs";  // ❌ Dead code after exit
?>
```

| Keyword | Scope | After it | JS Equivalent |
|:---|:---|:---|:---|
| `continue` | Current iteration | Next iteration runs | `continue` |
| `break` | Current loop | Code after loop runs | `break` |
| `break N` | N enclosing loops | Code after outer loop | ❌ None |
| `exit()` / `die()` | Entire script | Nothing runs | `process.exit()` |

> ⚠️ `exit()` and `die()` are identical aliases — both kill the script completely.

> ⚠️ **Never use `exit()` in Laravel** — it bypasses middleware, prevents proper HTTP responses from being sent, and breaks session handling. Use `return` or throw exceptions instead.

---

# 6. Master Cheat Sheet

```php
<?php
// ─── TAGS & OUTPUT ───────────────────────────────────────
<?php ... ?>              // Standard tag (only use this)
echo "Hi", " Ahmed";      // Fast output, multiple args
print "Hi";               // Single arg, returns 1

// ─── VARIABLES & SCOPE ───────────────────────────────────
$name = "Ahmed";          // Always $ prefix
global $name;             // Import global into function
static $count = 0;        // Persists between function calls
$b = &$a;                 // Reference — shared memory

// ─── SUPERGLOBALS ────────────────────────────────────────
$_GET['id'];              // URL: ?id=5        → req.query
$_POST['email'];          // Form body         → req.body
$_FILES['avatar'];        // File upload       → req.file (Multer)
$_SESSION['user_id'];     // Session data      → req.session
$_COOKIE['token'];        // Browser cookie    → req.cookies
$_ENV['APP_KEY'];         // Env variable      → process.env
$_SERVER['REMOTE_ADDR'];  // User IP           → req.ip

// ─── TYPE SYSTEM ─────────────────────────────────────────
(int)    $x;              // Cast to integer
(float)  $x;              // Cast to float
(bool)   $x;              // Cast to boolean
(string) $x;              // Cast to string
(array)  $x;              // Cast to array
gettype($x);              // Returns type name → typeof
settype($x, "integer");   // Mutates original permanently ⚠️
isset($x);                // Exists AND not null?
unset($x);                // Destroy variable
empty($x);                // Is falsy? (0, "", null, [], "0")

// ─── FALSY VALUES ────────────────────────────────────────
// false: 0, 0.0, "", "0", [], null
// true:  "false", [0], "0.0", any object

// ─── OPERATORS ───────────────────────────────────────────
$a . $b;                  // String concat (not +)
$a .= $b;                 // String append
5 <=> 10;                 // Spaceship → -1 | 0 | 1
$a === $b;                // Strict equality (value + type)
$a <> $b;                 // Not equal (legacy, same as !=)
$x ** 3;                  // Exponentiation (x³)

// ─── CONTROL FLOW ────────────────────────────────────────
match($x) { val => result, default => other };  // Strict switch (PHP 8+)
foreach($arr as $k => $v) {}                    // Best loop for arrays
break 2;                                        // Exit 2 nested loops
exit("Done");                                   // Halt script (avoid in Laravel)
die();                                          // Alias for exit()
?>
```

| Concept | PHP | JS / Node |
|:---|:---|:---|
| Variable prefix | `$name` | `let name` |
| String concat | `.` | `+` |
| Strict equal | `===` | `===` |
| Not-equal alt | `<>` | ❌ None |
| Spaceship | `<=>` | ❌ None |
| Power | `**` | `**` |
| Array loop | `foreach` | `for...of` |
| Env variable | `$_ENV` | `process.env` |
| Request body | `$_POST` | `req.body` |
| Kill script | `exit()` | `process.exit()` |
| Global scope | `global $x` | Automatic (var) |
| Strict scope | Yes (manual) | No (var leaks) |
