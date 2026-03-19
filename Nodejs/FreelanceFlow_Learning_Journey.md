# 🎓 FreelanceFlow — Learning Journey
> بنبني من الصفر الحقيقي. سطر بسطر. مفيش حاجة هتعدي من غير ما تفهمها.

---

# 🏁 Sprint 0 — ليه السيرفر؟ وإيه ده أصلاً؟

---

## 🇪🇬 قبل ما نكتب سطر واحد كود — لازم نفهم إيه اللي بيحصل

أنت شغال بـ SQL قبل كده. يعني أنت عارف إن في database بتخزن فيها data، وبتعمل queries عليها.

بس فيه سؤال قبل ده: **مين اللي بيكلم الـ database ده؟**

لما بتفتح Postman أو browser وبتبعت request — الـ request دي مش بتوصل للـ database مباشرة. بتوصل لـ **server** أولاً. الـ server ده هو اللي بيسمع، بيفهم، بيرد، وبيتكلم مع الـ database.

```
أنت (Postman / Browser)
        │
        │  HTTP Request
        ▼
    [ SERVER ]   ← ده اللي بنبنيه دلوقتي
        │
        │  بيتكلم مع DB لو محتاج
        ▼
    [ DATABASE ]
```

**الـ server** ده برنامج شغال على جهاز (أو cloud)، بيستنى requests تيجيله، وبيرد عليها.

في Node.js، بنبني الـ server ده باستخدام **Express**.

---

## 🇪🇬 طب Express ده إيه بالظبط؟

Node.js عنده حاجة built-in اسمها `http` — تقدر تعمل بيها server. بس الكود بيبقى طويل جداً وصعب.

Express هو library بتسهّل الموضوع ده. بدل ما تكتب 50 سطر، بتكتب 5 سطور.

تخيله زي فرق ما بين تبني عربية من أجزاء خام، أو تاخد chassis جاهز وتبني عليه. Express هو الـ chassis.

---

## 💻 الخطوة الأولى — إنشاء الـ Project

افتح terminal واكتب:

```bash
mkdir freelance-flow
cd freelance-flow
npm init -y
```

**سطر بسطر إيه اللي حصل:**

`mkdir freelance-flow` — بتعمل folder جديد اسمه `freelance-flow`

`cd freelance-flow` — بتدخل جوا الـ folder ده

`npm init -y` — بتعمل ملف اسمه `package.json`

---

## 🇪🇬 طب `package.json` ده إيه؟

فكر فيه زي **بطاقة هوية المشروع**. بيقول:
- اسم المشروع إيه
- version إيه
- الـ libraries اللي المشروع بيحتاجها إيه

لو فتحته هتلاقيه شكله كده:

```json
{
  "name": "freelance-flow",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
```

مش محتاج تفهم كل سطر فيه دلوقتي. المهم إنه موجود.

---

## 💻 نثبّت Express

```bash
npm install express
```

ده بيحمّل Express ويحطه في folder اسمه `node_modules`. وبيضيف سطر في الـ `package.json` يقول "المشروع ده محتاج express".

```bash
npm install dotenv
npm install --save-dev nodemon
```

**إيه الـ packages دي؟**

`dotenv` — بيخليك تحط الـ settings السرية (زي كلمة سر الـ database) في ملف منفصل مش في الكود نفسه. هنشرحه أكتر بعدين.

`nodemon` — بدل ما توقف السيرفر وتشغله كل مرة بتغير الكود، `nodemon` بيعمل ده تلقائياً. الـ `--save-dev` معناها "ده بس للـ development، مش للـ production".

---

## 💻 عدّل الـ `package.json`

افتح `package.json` وغيّر الـ `"scripts"` تبقى كده:

```json
"scripts": {
  "dev": "nodemon server.js"
}
```

**ليه؟**

دلوقتي بدل ما تكتب `node server.js` كل مرة، هتكتب `npm run dev` وهيشغّل `nodemon` اللي بيراقب التغييرات تلقائياً.

---

## 💻 اعمل ملف `.env`

في نفس الـ folder، اعمل ملف جديد اسمه `.env` — بالنقطة في الأول.

```env
PORT=5000
NODE_ENV=development
```

**إيه الـ `.env` ده؟**

تخيل إنك بتبني app وعايز تنشره على الـ internet. مش هتكتب كلمة سر الـ database في الكود مباشرة، لأن لو رفعت الكود على GitHub، كل الناس هتشوفها.

الـ `.env` هو ملف خاص بجهازك أنت بس. بتحط فيه الـ settings السرية. وبتضيفه لـ `.gitignore` عشان متتحملش مع الكود.

`PORT=5000` — السيرفر هيشتغل على البورت ده. فكر في البورت زي رقم شقة في عمارة. الـ 5000 هو رقم الشقة بتاعت السيرفر بتاعنا.

`NODE_ENV=development` — بيقول إحنا في مرحلة development مش production. بعدين هنستخدم الـ value دي عشان نعرض error details أكتر.

---

## 💻 اعمل ملف `server.js`

ده أهم ملف. اعمله في نفس الـ folder:

```javascript
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 5000;

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 🇪🇬 شرح كل سطر لوحده

### السطر الأول:
```javascript
require('dotenv').config();
```

`require('dotenv')` — بتجيب الـ `dotenv` library اللي حملتها.

`.config()` — بتقوله "اقرأ الـ `.env` file وحط كل اللي فيه على `process.env`".

`process.env` هو object موجود دايماً في Node.js بيحتوي على متغيرات البيئة. بعد الـ `.config()`، هتلاقي `process.env.PORT` قيمتها `5000` و`process.env.NODE_ENV` قيمتها `"development"`.

**ليه لازم يكون أول سطر؟**

لأن أي كود بعده ممكن يحاول يقرأ `process.env.PORT` — لو `dotenv` ما اتشغلش قبله، هيلاقي القيمة `undefined`.

---

### السطر الثاني:
```javascript
const express = require('express');
```

`require('express')` — بتجيب الـ Express library وبتحطها في متغير اسمه `express`.

`require` في Node.js زي الـ `import` في JavaScript الحديثة — بتجيب حاجة من مكان تاني وتستخدمها.

---

### السطر التالت:
```javascript
const app = express();
```

`express()` — بتشغّل Express وبترجع **object** بنسميه `app`.

الـ `app` ده هو السيرفر بتاعنا. كل حاجة هتعملها بعدين — routes، middleware، error handlers — هتتعمل على الـ `app` ده.

فكر فيه زي لما بتقول `const router = express.Router()` في Angular — بتعمل instance.

---

### السطر الرابع:
```javascript
const PORT = process.env.PORT || 5000;
```

`process.env.PORT` — بتقرأ الـ `PORT` من الـ `.env` file. قيمتها `"5000"` (string).

`|| 5000` — ده fallback. يعني لو `process.env.PORT` كانت `undefined` لأي سبب، استخدم `5000` كـ default.

---

### السطر الخامس إلى السابع:
```javascript
app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});
```

ده أول **route** — زي endpoint في أي API.

`app.get` — يعني "لما يجيلك GET request".

`'/'` — على الـ path ده (الـ root — يعني `http://localhost:5000/`).

`(req, res) => { ... }` — دي الـ function اللي هتتشغل لما يجيلك الـ request ده.

`req` — اختصار **request**. فيه كل المعلومات عن الـ request الجاي (من مين؟ عايز إيه؟ بعت إيه؟).

`res` — اختصار **response**. بتستخدمه عشان ترد على الـ request.

`res.send('...')` — بيبعت الـ string دي كـ response.

---

### السطر الأخير:
```javascript
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

`app.listen(PORT)` — ده اللي بيشغّل السيرفر فعلاً. بيقول "ابدأ استنّى requests على الـ PORT ده".

قبل الـ سطر ده، السيرفر مش شغال. بعده، شغال وبيستنى.

`() => { console.log(...) }` — دي callback function بتتشغل لما السيرفر يبدأ بنجاح. بس بتطبع رسالة تأكيد.

---

## ✅ Checkpoint

شغّل السيرفر:

```bash
npm run dev
```

المفروض تشوف في الـ terminal:

```
Server running on port 5000
```

افتح Postman:

> **Method:** `GET`
> **URL:** `http://localhost:5000/`
> **Expected:** `FreelanceFlow server is alive! 🚀`

لو الرسالة وصلت — السيرفر شغال.

جرّب كمان تفتح المتصفح وتكتب `http://localhost:5000/` — المفروض تشوف نفس الرسالة.

---

## 🇪🇬 سؤال مهم قبل ما نكمل

لاحظ إن فيه `req` و `res` في كل route handler. ده مش اختياري ومش decoration — ده ضروري.

**`req`** — Express بيحط فيه كل المعلومات عن الـ request:
- `req.params` — الـ variables في الـ URL زي `/users/:id`
- `req.query` — الـ query string زي `?name=Mohamed`
- `req.body` — الـ JSON اللي بعتته في الـ request (محتاج middleware عشان يشتغل — Sprint 1)
- `req.headers` — الـ HTTP headers زي الـ Authorization

**`res`** — بتستخدمه عشان ترد:
- `res.send('text')` — بترد بـ plain text
- `res.json({ ... })` — بترد بـ JSON (ده اللي هنستخدمه دايماً في الـ API)
- `res.status(404).json({ ... })` — بتحدد الـ status code الأول وبعدين الـ JSON

---

## 🇪🇬 ملخص Sprint 0

اللي اتبنى:

- **Project folder** مع `package.json`
- **Express** كـ framework للـ server
- **dotenv** عشان نحط الـ settings في ملف منفصل
- **nodemon** عشان نشتغل بسهولة في الـ development
- **`server.js`** فيه سيرفر شغال بـ route واحدة

اللي اتعلمته:

- الـ server هو الوسيط بين الـ client والـ database
- `express()` بترجع `app` object ده السيرفر بتاعنا
- كل route عنده method (GET/POST/...) وpath وfunction
- `req` = الـ request الجاي، `res` = الـ response الرايح
- `app.listen()` هو اللي بيشغّل السيرفر فعلاً

---

> **جاهز للـ Sprint 1؟**
>
> Sprint 1 هيشرح `express.json()` — ليه لو بعت JSON في الـ request ومش عامل الـ middleware ده، `req.body` هيبقى `undefined`. وهنجرّب الفرق بأيدينا في Postman.
>
> قول "كمّل" لما تكون شغّلت الـ server وشفت الـ response بنفسك.

---

---

# 📦 Sprint 1 — `express.json()` : ليه السيرفر مش بيفهم الـ Body؟

---

## 🇪🇬 المشكلة الأولى — السيرفر بيسمع بس مش بيفهم

السيرفر شغال تمام. بس دلوقتي لو بعتله JSON — مش هيفهمه.

تخيل إنك بتكلم حد على التليفون. الكلام وصل. بس الكلام ده بالياباني وأنت مش عارف ياباني. الرسالة وصلت جسدياً، بس محتوى مش مفهوم.

ده بالظبط اللي بيحصل لما بتبعت JSON body للسيرفر من غير ما تقوله "افهم JSON".

---

## 🇪🇬 HTTP Request فيها إيه بالظبط؟

قبل ما نحل المشكلة، لازم نفهم شكل الـ HTTP request.

لما بتبعت request من Postman، مش بتبعت كلمة أو رقم بس. بتبعت **رسالة كاملة** فيها أجزاء:

```
POST /test-body HTTP/1.1
Host: localhost:5000
Content-Type: application/json
Authorization: Bearer xyz123

{ "name": "Mohamed", "role": "client" }
```

الجزء الأول ده اسمه **Headers** — معلومات عن الـ request نفسه.
الجزء التاني ده اسمه **Body** — الداتا اللي أنت بعتها.

الـ `Content-Type: application/json` في الـ header بيقول: "الـ body اللي بعتها ده JSON."

بس الـ Express مش بيفتح الـ body تلقائياً. زي ما البريد بيوصلك جواب مغلوف — حد لازم يفتح الغلاف ده.

---

## 🇪🇬 إيه هو الـ Middleware أصلاً؟

قبل ما نحل المشكلة، لازم تفهم مفهوم مهم جداً: **Middleware**.

تخيل محطة مترو. الـ request هو الراكب. بيدخل من باب المحطة (يبعت request)، وبيعدي على شبابيك مختلفة قبل ما يوصل للقطر (الـ route handler).

```mermaid
flowchart LR
    A[Request جاي] --> B[Middleware 1\nexpress.json]
    B --> C[Middleware 2\nAuth Check]
    C --> D[Route Handler\nالكود بتاعك]
    D --> E[Response راجع]

    style A fill:#2d3748,color:#fff
    style E fill:#2d3748,color:#fff
    style B fill:#2b6cb0,color:#fff
    style C fill:#2b6cb0,color:#fff
    style D fill:#276749,color:#fff
```

كل Middleware بتعمل حاجة للـ request — تعدّله، تفحصه، أو توقفه — وبعدين تقوله "روح للتالي" باستخدام `next()`.

لو أي middleware ما قالش `next()` ولا بعت response — الـ request بتعلق ومش بتوصل لحد.

---

## 🇪🇬 إيه اللي بيحصل من غير `express.json()`؟

خلينا نجرب نشوف المشكلة بنفسنا **قبل** ما نحلها.

---

## 💻 الخطوة الأولى — جرّب المشكلة

ضيف الـ route دي على `server.js` — **فوق** الـ `app.listen`:

```javascript
// Test route — WITHOUT express.json() middleware yet
app.post('/test-body', (req, res) => {
  console.log('req.body is:', req.body);
  res.json({ received: req.body });
});
```

شغّل السيرفر وافتح Postman:

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-body`
> **Body:** اختار `raw` وبعدين `JSON` وحط:
> ```json
> { "name": "Mohamed", "role": "client" }
> ```

شوف الـ response — هتلاقي:

```json
{ "received": undefined }
```

وفي الـ terminal هتشوف:

```
req.body is: undefined
```

**ليه؟** لأن Express استلم الـ request، بس ما فتحش الـ body. الغلاف موصلش، بس ما اتفتحش.

---

## 🇪🇬 إزاي الـ `express.json()` بيحل المشكلة؟

الـ `express.json()` هو middleware بيعمل حاجتين:

**أولاً:** بيشوف الـ `Content-Type` header في كل request.

**تانياً:** لو لاقى `Content-Type: application/json` — بياخد الـ raw text من الـ body، بيعمله `JSON.parse()`، وبيحط الناتج على `req.body`.

```mermaid
flowchart TD
    A["Request وصل\nBody: '{name: Mohamed}'"] --> B{Content-Type\nإيه؟}
    B -->|application/json| C[JSON.parse على الـ body]
    B -->|غير كده| D[اعمل next بدون تغيير]
    C --> E["req.body = { name: 'Mohamed' }"]
    E --> F[next — روح للـ Route Handler]
    D --> F

    style A fill:#2d3748,color:#fff
    style B fill:#744210,color:#fff
    style C fill:#2b6cb0,color:#fff
    style D fill:#4a5568,color:#fff
    style E fill:#276749,color:#fff
    style F fill:#2d3748,color:#fff
```

---

## 💻 الخطوة التانية — اضيف الـ Middleware

في `server.js`، ضيف السطر ده **فوق** الـ routes — ده مهم جداً:

```javascript
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 5000;

// ✅ NEW: This middleware runs for EVERY request before any route handler
// It reads the raw body, parses it as JSON, and puts it on req.body
app.use(express.json());

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

app.post('/test-body', (req, res) => {
  console.log('req.body is:', req.body);
  res.json({ received: req.body });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 🇪🇬 شرح `app.use(express.json())` سطر بسطر

```javascript
app.use(express.json());
```

**`app.use(...)`** — بيقول لـ Express: "شغّل الـ middleware ده على كل request جاية، قبل ما تعمل أي حاجة تانية."

لاحظ مفيش path — مش `app.use('/api', ...)` — يعني هيشتغل على كل الـ routes.

**`express.json()`** — دي function موجودة جوا الـ Express library نفسها. بتنادي عليها وبترجعلك middleware function جاهزة للاستخدام.

**الترتيب مهم جداً:**

```mermaid
flowchart TD
    subgraph correct["✅ صح — app.use قبل الـ routes"]
        A1[app.use express.json] --> B1[app.post '/test-body']
    end

    subgraph wrong["❌ غلط — app.use بعد الـ routes"]
        A2[app.post '/test-body'] --> B2[app.use express.json]
    end

    style correct fill:#1a4731,color:#fff
    style wrong fill:#4a1212,color:#fff
```

لو حطيت `app.use(express.json())` بعد الـ route — الـ route هتشتغل من غير ما الـ middleware يشتغل عليها، وهيفضل `req.body` هو `undefined`.

---

## ✅ Checkpoint

بعد ما ضفت `app.use(express.json())` — ارجع لـ Postman وبعت نفس الـ request:

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-body`
> **Body (raw JSON):** `{ "name": "Mohamed", "role": "client" }`

دلوقتي المفروض تشوف:

```json
{ "received": { "name": "Mohamed", "role": "client" } }
```

وفي الـ terminal:

```
req.body is: { name: 'Mohamed', role: 'client' }
```

**جرّب كمان تبعت من غير `Content-Type` header:**

في Postman، شيل الـ `Content-Type: application/json` header وبعت نفس الـ body.

هتلاقي `req.body` رجع `{}` أو `undefined` — لأن Express مش عارف إن الـ body ده JSON من غير الـ header.

**ده درس مهم:** الـ `Content-Type` header مش decoration — ده إعلان رسمي للسيرفر عن شكل الداتا.

---

## 🔍 Deep-Dive — إيه اللي بيحصل داخل `express.json()` فعلاً؟

الـ HTTP body مش بييجي دفعة واحدة. بييجي كـ **stream** — chunks صغيرة من البيانات. الـ `express.json()` بيستنى يجمع كل الـ chunks دي، وبعدين بيعمل `JSON.parse()` على الناتج.

```mermaid
sequenceDiagram
    participant P as Postman
    participant M as express.json Middleware
    participant R as Route Handler

    P->>M: Request + Body chunks
    M->>M: جمع الـ chunks
    M->>M: JSON.parse على الـ body
    M->>M: req.body = النتيجة
    M->>R: next() — روح للـ route
    R->>P: res.json(req.body)
```

لو الـ JSON جاي malformed (مثلاً فيه syntax error) — الـ `express.json()` بيرمي error تلقائياً ومش بيكمل للـ route. هنشوف إزاي نتعامل مع الـ errors دي في Sprint 2.

---

## 🇪🇬 ملخص Sprint 1

اللي اتعلمته:

- الـ HTTP request فيها **Headers** وـ**Body** — مش body بس
- الـ `Content-Type` header بيقول للسيرفر شكل الـ body إيه
- من غير `express.json()` — `req.body` بيبقى `undefined` دايماً
- الـ Middleware هو function بتشتغل على كل request قبل ما توصل للـ route handler
- `app.use()` بيسجّل الـ middleware — لازم يكون **قبل** الـ routes

---

> **جاهز للـ Sprint 2؟**
>
> Sprint 2 هيكون عن `AppError` والـ Global Error Handler.
> هنشوف إيه اللي بيحصل لما السيرفر بيعمل crash من غير error handler، وهنبني نظام طوارئ مركزي يمسك كل الـ errors في مكان واحد.
>
> قول "كمّل" لما تكون جربت الـ checkpoint وشفت `req.body` يوصل صح.

---

---

# 🛡️ Sprint 2 — `AppError` + Global Error Handler : نظام الطوارئ

---

## 🇪🇬 المشكلة — إيه اللي بيحصل لو السيرفر عمل crash؟

جرّب دلوقتي من غير ما تعمل أي حاجة — افتح Postman وبعت:

> **Method:** `GET`
> **URL:** `http://localhost:5000/ayحاجة-مش-موجودة`

شفت إيه؟ Express رجّعلك HTML page. في API مش المفروض يرجعلك HTML — المفروض يرجعلك JSON.

دلوقتي جرّب تاني حاجة. ضيف الـ route دي مؤقتاً في `server.js`:

```javascript
app.get('/test-crash', (req, res) => {
  // Accessing a property on undefined — this will throw an error
  const user = undefined;
  res.json(user.name);
});
```

وبعت عليها GET request. هتلاقي السيرفر بيرجع HTML error page قبيحة.

المشكلة الأكبر؟ لو السيرفر في production — هيرجع تفاصيل الـ error للـ client. ده خطر أمني.

---

## 🇪🇬 الحل — نظام طوارئ مركزي

تخيل إنك بتشتغل في مستشفى. كل طوارئ بتيجي، مش كل دكتور يتعامل معاها لوحده. في قسم طوارئ مركزي بيستقبل كل الحالات.

```mermaid
flowchart TD
    A[Route Handler 1] -->|error| E
    B[Route Handler 2] -->|error| E
    C[Route Handler 3] -->|error| E
    D[Middleware]      -->|error| E
    E[🏥 Global Error Handler\nمكان واحد بيتعامل مع كل الـ errors]
    E --> F[JSON Response للـ Client]

    style E fill:#742a2a,color:#fff
    style F fill:#276749,color:#fff
```

بدل ما كل route تكتب نفس كود الـ error handling، في مكان واحد بيمسك كل الـ errors.

---

## 🇪🇬 `AppError` — ليه مش بنستخدم `new Error()` العادي؟

JavaScript عنده `Error` class built-in. بس فيه مشكلة — بيحمل `message` و `stack` بس. مش بيحمل `statusCode`.

في API، كل error لازم يكون ليه **HTTP status code**:
- `400` — Bad Request (الـ client بعت داتا غلط)
- `401` — Unauthorized (مش logged in)
- `403` — Forbidden (logged in بس مش مسموحلك)
- `404` — Not Found
- `500` — Server Error

```mermaid
flowchart LR
    subgraph native["new Error() — العادي"]
        A1[message: 'User not found']
        A2[stack: Error at ...]
    end

    subgraph custom["new AppError() — اللي هنبنيه"]
        B1[message: 'User not found']
        B2[statusCode: 404]
        B3["status: 'fail'"]
        B4[isOperational: true]
    end

    style native fill:#4a1212,color:#fff
    style custom fill:#1a4731,color:#fff
```

الـ `isOperational` flag مهم جداً. بيفرّق بين نوعين من الـ errors:

**Operational Error** — error أنت توقعته وعملته بقصد. مثل "User not found". آمن تبعت الـ message للـ client.

**Programming Error** — bug في الكود، حاجة ما توقعتهاش. مثل `cannot read property of undefined`. خطر تبعت التفاصيل للـ client — ممكن تكشف معلومات حساسة.

---

## 💻 الخطوة الأولى — اعمل `src/utils/AppError.js`

اعمل الـ folders الأول:

```bash
mkdir src
mkdir src/utils
mkdir src/middlewares
```

بعدين اعمل `src/utils/AppError.js`:

```javascript
class AppError extends Error {
  constructor(message, statusCode) {

    // super(message) بيبعت الـ message للـ Error class الأصلي
    // عشان الـ error.message يشتغل صح
    super(message);

    this.statusCode = statusCode;

    // لو الـ status code يبدأ بـ 4 (400, 401, 404...)
    // ده غلط من الـ client — نسميه 'fail'
    // لو يبدأ بـ 5 (500, 503...)
    // ده غلط من الـ server — نسميه 'error'
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    // الـ flag اللي بيقول "أنا عملت الـ error ده بقصد"
    // يعني آمن نبعت الـ message للـ client
    this.isOperational = true;

  }
}

module.exports = AppError;
```

---

## 🇪🇬 شرح `class AppError extends Error`

أنت بتعمل **class** جديدة اسمها `AppError` وبتقول إنها **ترث** من `Error` الموجودة في JavaScript.

`extends` معناها "خد كل حاجة موجودة في `Error` وزيد عليها."

يعني `AppError` عنده كل حاجة في `Error` العادي (message, stack, name...) وزيادة عليه الـ `statusCode` و`status` و`isOperational`.

```mermaid
flowchart TD
    A["Error — الأصلي\n- message\n- stack\n- name"] --> B["AppError — extends Error\n- message ✓ موروثة\n- stack ✓ موروثة\n- statusCode ← جديدة\n- status ← جديدة\n- isOperational ← جديدة"]

    style A fill:#2b6cb0,color:#fff
    style B fill:#276749,color:#fff
```

---

## 💻 الخطوة التانية — اعمل `src/middlewares/errorHandler.js`

```javascript
const globalErrorHandler = (err, req, res, next) => {

  // لو الـ error ما عندوش statusCode — يبقى غالباً programming error
  // نديه 500 كـ default
  err.statusCode = err.statusCode || 500;
  err.status     = err.status     || 'error';

  if (err.isOperational) {
    // Operational error — أنا عملته بقصد — آمن نبعت الـ message
    res.status(err.statusCode).json({
      status:  err.status,
      message: err.message,
    });
  } else {
    // Programming error — bug غير متوقع
    // نطبع التفاصيل في الـ server console للـ developer
    console.error('💥 UNEXPECTED ERROR:', err);

    // بس نبعت رسالة generic للـ client — مش نكشف التفاصيل
    res.status(500).json({
      status:  'error',
      message: 'Something went very wrong!',
    });
  }

};

module.exports = globalErrorHandler;
```

---

## 🇪🇬 ليه الـ error handler عنده 4 parameters؟

ده السر الأهم في الـ Sprint ده.

Express بيتعرف على الـ error handler **فقط** لو الـ function عندها بالظبط 4 parameters: `(err, req, res, next)`.

لو كتبت `(req, res, next)` — Express هيتعامل معاها كـ normal middleware مش error handler، ومش هيبعتلها الـ errors.

```mermaid
flowchart TD
    A["app.use\n(req, res, next) => {}"] --> B["Normal Middleware\nبيشتغل على كل request"]
    C["app.use\n(err, req, res, next) => {}"] --> D["Error Handler\nبيشتغل بس لما فيه error"]

    style B fill:#2b6cb0,color:#fff
    style D fill:#742a2a,color:#fff
```

---

## 🇪🇬 إزاي الـ Error بيوصل للـ Handler؟

مفتاح كل ده هو `next()`.

لما بتعمل `next()` من غير arguments — Express بيروح للـ middleware الجاي العادي.

لما بتعمل `next(أي حاجة)` — Express بيسكيب كل الـ normal middleware وبيروح على طول للـ error handler.

```mermaid
sequenceDiagram
    participant C as Client
    participant R as Route Handler
    participant N as next
    participant E as Error Handler

    C->>R: GET /test-error
    R->>N: next(new AppError('Not found', 404))
    Note over N: next() with argument =\nskip everything → go to error handler
    N->>E: err = AppError { message, statusCode, isOperational }
    E->>C: { status: 'fail', message: 'Not found' }
```

---

## 💻 الخطوة التالتة — اربط كل حاجة في `server.js`

```javascript
require('dotenv').config();
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const app  = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

// ✅ NEW: Route that intentionally throws an AppError
app.get('/test-error', (req, res, next) => {
  next(new AppError('This is a test error!', 400));
});

// ✅ NEW: Route that simulates an unexpected crash
app.get('/test-crash', (req, res, next) => {
  const user = undefined;
  // This line throws a TypeError — NOT an AppError
  // The global handler will catch it as a non-operational error
  res.json(user.name);
});

// ✅ NEW: Catch any route that doesn't exist → 404
// app.all('*') = any HTTP method + any path not matched above
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl}`, 404));
});

// ✅ NEW: Global Error Handler — لازم يكون آخر حاجة
app.use(globalErrorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 🇪🇬 ليه `app.all('*')` لازم يكون قبل الـ error handler وبعد كل الـ routes؟

```mermaid
flowchart TD
    A[GET /] --> B[Route Handler موجودة ✓]
    C[POST /test-body] --> D[Route Handler موجودة ✓]
    F[GET /أي-حاجة-تانية] --> G["app.all '*'\nمفيش route بتطابق → AppError 404"]
    G --> H[Global Error Handler]
    H --> I[JSON Response]

    style G fill:#744210,color:#fff
    style H fill:#742a2a,color:#fff
    style I fill:#276749,color:#fff
```

لو حطيت `app.all('*')` قبل الـ routes — هيمسك كل الـ requests ومش هييجيلها فرصة توصل للـ routes الحقيقية.

لو حطيت الـ error handler قبل `app.all('*')` — الـ 404 errors مش هتوصله.

**الترتيب الصح دايماً:**
1. Middlewares (`app.use`)
2. Routes (`app.get`, `app.post`, ...)
3. Catch-all 404 (`app.all('*')`)
4. Error Handler (`app.use` بـ 4 params) ← **آخر حاجة**

---

## ✅ Checkpoint

**Test 1 — AppError الـ intentional:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/test-error`
> **Expected:**
> ```json
> { "status": "fail", "message": "This is a test error!" }
> ```
> وفي Postman أعلى الـ response: `400 Bad Request`

**Test 2 — الـ unexpected crash:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/test-crash`
> **Expected:**
> ```json
> { "status": "error", "message": "Something went very wrong!" }
> ```
> وفي الـ terminal: `💥 UNEXPECTED ERROR: TypeError: Cannot read properties of undefined`

**Test 3 — Route مش موجودة:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/abcxyz`
> **Expected:**
> ```json
> { "status": "fail", "message": "Can't find /abcxyz" }
> ```
> وفي Postman: `404 Not Found`

**الفرق المهم بين Test 1 و Test 2:**

في الأول — الـ message الحقيقية وصلت للـ client لأن `isOperational = true`.

في التاني — الـ client شاف "Something went very wrong" بس، لأن الـ error ده مش `AppError` يعني `isOperational = undefined` يعني `false`.

---

## 🔍 Deep-Dive — إزاي Express بيمسك الـ Error من `async` code؟

فيه مشكلة مهمة. لو كتبت:

```javascript
app.get('/async-route', async (req, res, next) => {
  const user = await User.findById('wrong-id'); // throws error
  res.json(user);
});
```

لو `User.findById` رمت error — Express مش هيمسكها تلقائياً. الـ async error مش بتوصل للـ error handler إلا لو أنت بعتها يدوياً:

```javascript
// Option 1: try/catch manually
app.get('/async-route', async (req, res, next) => {
  try {
    const user = await User.findById('wrong-id');
    res.json(user);
  } catch (err) {
    next(err); // ← بعت الـ error يدوياً للـ handler
  }
});
```

ده كتير ومتكرر. في Sprint 3 هنعمل `catchAsync` wrapper بيعمل ده تلقائياً لأي async function. بس خليك عارف المشكلة دي دلوقتي.

---

## 🇪🇬 ملخص Sprint 2

اللي اتعلمته:

- من غير error handler — Express بيرجع HTML وممكن يكشف معلومات حساسة
- `AppError` بيضيف `statusCode` و`status` و`isOperational` على الـ `Error` العادي
- `isOperational = true` يعني "أنا عملت الـ error ده بقصد — آمن تبعته للـ client"
- الـ error handler لازم عنده 4 parameters بالظبط `(err, req, res, next)` عشان Express يعرفه
- `next(err)` بيسكيب كل الـ middlewares العادية ويروح على طول للـ error handler
- الترتيب في `server.js` حرفي: middlewares → routes → 404 → error handler

---

> **جاهز للـ Sprint 3؟**
>
> Sprint 3 هيبدأ MongoDB. مش هنكتب `User.create()` على طول.
> هنبدأ بسؤال: **ليه محتاج database أصلاً؟**
> وهنفهم الفرق بين MongoDB وSQL اللي أنت شغّلته قبل كده.
> وبعدين نفهم `Schema` و`Model` سطر بسطر.
>
> قول "كمّل" لما تكون جربت الـ 3 tests وشفت الفرق بين الـ operational والـ unexpected error بإيدك.

---

---

# 🛡️ Sprint 2 — AppError + Global Error Handler : نظام الطوارئ

---

## 🇪🇬 المشكلة — إيه اللي بيحصل لما السيرفر يتعب؟

دلوقتي لو حاجة غلط في السيرفر — مثلاً حد بعت بيانات ناقصة، أو طلب صفحة مش موجودة — Express مش عارف يتعامل معاها بشكل صح.

جرّب دلوقتي: افتح Postman وبعت request على route مش موجودة:

> **Method:** `GET`
> **URL:** `http://localhost:5000/هاي`

هتلاقي Express بيرجع HTML page كاملة فيها "Cannot GET /هاي".

ده مشكلتين في نفس الوقت:

**مشكلة 1:** إحنا بنبني API — المفروض كل حاجة ترجع JSON، مش HTML.

**مشكلة 2:** لو في كل controller كتبنا error handling لوحده — هيبقى عندنا نفس الكود متكرر في 20 مكان. وكل حاجة هتبقى شكلها مختلف.

---

## 🇪🇬 الحل — نظام طوارئ مركزي

تخيل مستشفى كبير. في كل أوضة ممكن حاجة تحصل. الحل مش إن كل دكتور يتعامل مع كل حالة لوحده من الصفر.

الحل هو إن في **قسم طوارئ مركزي واحد** — أي حالة طارئة في أي مكان في المستشفى، بيتم تحويلها لقسم الطوارئ ده اللي عارف يتعامل مع كل الحالات بطريقة موحدة.

```mermaid
flowchart TD
    A[Request جاي] --> B[Route Handler]
    B -->|حاجة غلط| C[next err]
    C --> D{Global Error Handler}
    D -->|Operational Error\nيعني خطأ متوقع| E[ابعت message واضحة\nللـ client]
    D -->|Programming Error\nيعني bug في الكود| F[ابعت رسالة generic\nوحفظ التفاصيل في الـ logs]

    style A fill:#2d3748,color:#fff
    style B fill:#2b6cb0,color:#fff
    style C fill:#744210,color:#fff
    style D fill:#553c9a,color:#fff
    style E fill:#276749,color:#fff
    style F fill:#742a2a,color:#fff
```

عندنا حاجتين لازم نبنيهم:

**الأولى: `AppError`** — class بنستخدمه عشان نعمل error منظم، فيه message وstatus code.

**التانية: Global Error Handler** — middleware خاص بيمسك كل الـ errors ويرد عليها بشكل موحد.

---

## 🇪🇬 ليه محتاجين `AppError` class خاصة؟

JavaScript عنده `Error` class عادي:

```javascript
throw new Error('Something went wrong');
```

بس الـ `Error` ده فيه `message` بس. مش فيه:
- الـ HTTP status code (404؟ 400؟ 500؟)
- هل ده error متوقع ولا bug في الكود؟

لو بعتنا error للـ client من غير status code — Express هيبعت 500 على طول حتى لو المشكلة كانت إن الـ user بعت بيانات غلط (ده المفروض 400).

الـ `AppError` بيضيف المعلومات دي:

```mermaid
flowchart LR
    subgraph native["Error العادي"]
        A1[message فقط]
    end

    subgraph custom["AppError بتاعنا"]
        B1[message]
        B2[statusCode - مثلاً 404]
        B3[status - fail أو error]
        B4[isOperational - true]
    end

    style native fill:#4a1212,color:#fff
    style custom fill:#1a4731,color:#fff
```

**`isOperational = true`** — ده الـ flag المهم. معناه "الـ error ده أنا عملته عن قصد". ده يخلي الـ error handler يعرف إنه يبعت الـ message للـ client بأمان.

لو `isOperational` مش موجود — معناه bug غير متوقع في الكود — الـ handler هيبعت رسالة generic ومش هيكشف التفاصيل.

---

## 💻 خطوة 1 — اعمل folder وملف `AppError`

```bash
mkdir src
mkdir src/utils
mkdir src/middlewares
```

اعمل ملف `src/utils/AppError.js`:

```javascript
class AppError extends Error {
  constructor(message, statusCode) {

    // super(message) بتبعت الـ message للـ parent class
    // يعني للـ Error العادي — عشان الـ .message property تشتغل
    super(message);

    // بنضيف الـ properties الجديدة اللي محتاجينها
    this.statusCode = statusCode;

    // لو الـ status code يبدأ بـ 4 — معناه غلط من الـ client
    // لو يبدأ بـ 5 — معناه غلط من السيرفر
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    // ده الفرق بين error متوقع وبين bug
    // true = أنا عملت الـ error ده عن قصد — آمن أبعت الـ message للـ client
    this.isOperational = true;
  }
}

module.exports = AppError;
```

---

## 🇪🇬 شرح `class AppError extends Error`

في SQL كنت بتتعامل مع tables وrows. في JavaScript عندنا **classes**.

الـ `class` هو template لإنشاء objects. زي الـ Schema في Mongoose (هنيجي عليها بعدين).

`extends Error` معناها: "الـ AppError ده مبني على الـ Error الأصلي — هياخد كل خصائصه ويضيف عليها."

```mermaid
flowchart TD
    A["Error الأصلي\n.message\n.stack"] -->|extends| B["AppError بتاعنا\n.message موروث\n.stack موروث\n.statusCode جديد\n.status جديد\n.isOperational جديد"]

    style A fill:#4a5568,color:#fff
    style B fill:#276749,color:#fff
```

`constructor(message, statusCode)` — ده اللي بيشتغل لما تعمل `new AppError(...)`. بياخد اتنين arguments:

- `message` — الرسالة اللي هتوصل للـ client
- `statusCode` — زي 404 أو 400 أو 500

---

## 💻 خطوة 2 — اعمل Global Error Handler

اعمل ملف `src/middlewares/errorHandler.js`:

```javascript
const globalErrorHandler = (err, req, res, next) => {

  // لو الـ error مش عنده statusCode — يبقى 500
  err.statusCode = err.statusCode || 500;
  err.status     = err.status     || 'error';

  res.status(err.statusCode).json({
    status:  err.status,
    message: err.message,
  });

};

module.exports = globalErrorHandler;
```

---

## 🇪🇬 شرح الـ Error Handler — ليه عنده 4 parameters؟

الـ middleware العادي عنده 3 parameters:

```javascript
(req, res, next) => { ... }       // normal middleware
```

الـ Error Handler عنده 4 parameters — `err` في الأول:

```javascript
(err, req, res, next) => { ... }  // error handler
```

**ده مش اتفاق أو convention.** Express بيتعرف على الـ error handler بالـ signature بتاعته. لو حطيت 4 parameters — Express بيعرف تلقائياً إن ده error handler ومش هيشغله غير لما يجي error.

```mermaid
flowchart TD
    A["next() بدون argument"] --> B["روح للـ middleware الجاي\nالعادي"]
    C["next(err) بـ argument"] --> D["اعزل كل الـ middlewares العادية\nروح على طول للـ error handler"]

    style A fill:#2b6cb0,color:#fff
    style B fill:#2b6cb0,color:#fff
    style C fill:#742a2a,color:#fff
    style D fill:#742a2a,color:#fff
```

---

## 💻 خطوة 3 — ربط كل حاجة في `server.js`

```javascript
require('dotenv').config();
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const app  = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

app.post('/test-body', (req, res) => {
  console.log('req.body is:', req.body);
  res.json({ received: req.body });
});

// ✅ NEW: Route لتجربة الـ error handler
app.get('/test-error', (req, res, next) => {
  // next بنبعتله الـ error — مش بنرميه بـ throw
  next(new AppError('This is a fake error!', 400));
});

// ✅ NEW: Catch-all — أي route مش موجودة
// app.all('*') يعني: أي method وأي path
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

// ✅ NEW: Global Error Handler — لازم يكون LAST حاجة
app.use(globalErrorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 🇪🇬 ليه استخدمنا `next(err)` مش `throw new AppError()`؟

سؤال مهم. ليه ما كتبناش:

```javascript
// ❌ ليه مش كده؟
app.get('/test-error', (req, res) => {
  throw new AppError('This is a fake error!', 400);
});
```

الـ `throw` بيشتغل كويس في الـ synchronous code. بس لو الكود كان `async` — زي لما بتستنى database query — الـ `throw` مش بيوصل للـ error handler.

```mermaid
flowchart TD
    subgraph sync["Synchronous Code"]
        A1["throw new Error"] -->|بيوصل| B1["Error Handler ✅"]
    end

    subgraph async["Async Code"]
        A2["await User.find()"] --> C2["throw new Error"]
        C2 -->|مش بيوصل| B2["Error Handler ❌"]
        C2 -->|بيروح| D2["Unhandled Rejection 💥"]
    end

    subgraph correct["الحل الصح دايماً"]
        A3["أي كود sync أو async"] --> C3["next(new AppError(...))"]
        C3 -->|بيوصل دايماً| B3["Error Handler ✅"]
    end

    style sync fill:#1a4731,color:#fff
    style async fill:#4a1212,color:#fff
    style correct fill:#1a365d,color:#fff
```

الـ `next(err)` بيشتغل في أي حالة — sync أو async. عشان كده بنستخدمه دايماً.

---

## 🇪🇬 ليه الـ Error Handler لازم يكون آخر حاجة؟

لأن Express بيشغّل الـ middleware والـ routes بالترتيب من فوق لتحت.

```mermaid
flowchart TD
    A["app.use(express.json)"] --> B["app.get('/')"]
    B --> C["app.post('/test-body')"]
    C --> D["app.get('/test-error')"]
    D --> E["app.all('*') — 404 catch-all"]
    E --> F["app.use(globalErrorHandler) ← لازم هنا"]

    style F fill:#553c9a,color:#fff
```

لو حطيت الـ error handler في الأول — request مش هتوصلها لأنها هتتوقف قبل ما تعدي عليه.

لو حطيت الـ `app.all('*')` بعد الـ error handler — الـ 404 مش هتشتغل لأن الـ routes اللي فوقيها هتمسك الـ requests قبل ما توصلها.

---

## ✅ Checkpoint

**Test 1 — الـ fake error:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/test-error`
>
> **Expected:**
> ```json
> { "status": "fail", "message": "This is a fake error!" }
> ```
> وفي أعلى Postman: `400 Bad Request`

**Test 2 — Route مش موجودة:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/اي-حاجة-تانية`
>
> **Expected:**
> ```json
> { "status": "fail", "message": "Can't find /اي-حاجة-تانية on this server!" }
> ```
> وفي أعلى Postman: `404 Not Found`

**Test 3 — تأكد إن الـ response JSON مش HTML:**

اللي كان بييجي قبل: HTML page طويلة من Express.
اللي المفروض ييجي دلوقتي: JSON نظيف.

---

## 🇪🇬 ملخص Sprint 2

اللي اتعلمته:

- الـ Error بدون handler بيرجع HTML — مش مناسب لـ API
- `AppError` بتضيف `statusCode` و`isOperational` على الـ Error الأصلي
- `isOperational = true` يعني "أنا عملت الـ error ده عن قصد — آمن يوصل للـ client"
- الـ Error Handler عنده **4 parameters** — Express بيعرفه بيهم
- `next(err)` بتبعت الـ error للـ handler — اشتغل مع sync وasync
- الـ Error Handler لازم يكون **آخر** حاجة في الـ `server.js`

---

> **جاهز للـ Sprint 3؟**
>
> Sprint 3 هيجاوب على سؤالك الأصلي — ليه محتاج Model أصلاً؟ وإيه الفرق بين MongoDB وSQL اللي اشتغلت بيها؟ وإزاي نوصل السيرفر بالـ database خطوة بخطوة؟
>
> قول "كمّل" لما تكون شفت الـ JSON error بيرجع صح في الـ Postman.

---

---

# 🗄️ Sprint 3 — MongoDB + Mongoose : ليه محتاجين Model أصلاً؟

---

## 🇪🇬 أول حاجة — ليه محتاجين Database أصلاً؟

السيرفر شغال. عارف يستقبل requests ويرد. بس فيه مشكلة واحدة كبيرة.

كل البيانات اللي بيشتغل بيها السيرفر دلوقتي **موجودة في الـ RAM** — يعني في الـ memory المؤقتة للسيرفر.

لما السيرفر يقف أو يتعمله restart — كل البيانات دي بتروح.

```mermaid
flowchart TD
    subgraph without_db["❌ من غير Database"]
        A1[User بعت بياناته] --> B1[Server حفظها في RAM]
        B1 --> C1[Server اتعمله restart]
        C1 --> D1[البيانات راحت 💨]
    end

    subgraph with_db["✅ مع Database"]
        A2[User بعت بياناته] --> B2[Server بعتها للـ DB]
        B2 --> C2[Server اتعمله restart]
        C2 --> D2[البيانات لسه موجودة ✅]
    end

    style without_db fill:#4a1212,color:#fff
    style with_db fill:#1a4731,color:#fff
```

الـ Database هو المكان اللي بيخزن البيانات بشكل دائم على الـ Hard Disk — مش RAM.

---

## 🇪🇬 SQL اللي أنت شغّالت بيه vs MongoDB

أنت شغّالت مع SQL قبل كده. خلينا نشوف الفرق الأساسي:

**في SQL:**

البيانات بتتحفظ في **Tables** — زي Excel sheet. كل row هو record. كل column هي field محدد.

```
USERS TABLE:
| id | name    | email           | age |
|----|---------|-----------------|-----|
| 1  | Mohamed | mo@test.com     | 25  |
| 2  | Ahmed   | ahmed@test.com  | 30  |
```

لازم تحدد الـ columns وأنواعها قبل ما تحط أي بيانات — ده اسمه **Schema** في SQL. وكل row لازم تمشي بالـ schema ده.

**في MongoDB:**

البيانات بتتحفظ في **Collections** — زي Tables.
بس بدل rows وcolumns، كل record هو **Document** — شبه JSON object.

```
USERS COLLECTION:
{ "_id": "64abc", "name": "Mohamed", "email": "mo@test.com", "age": 25 }
{ "_id": "64def", "name": "Ahmed",   "email": "ahmed@test.com" }
```

لاحظ إن الـ document التاني مفيهوش `age`. ده مقبول في MongoDB — كل document ممكن يبقى شكله مختلف.

```mermaid
flowchart LR
    subgraph sql["SQL"]
        direction TB
        T["Table: users"]
        T --> R1["Row: id=1, name=Mohamed, email=mo@test.com"]
        T --> R2["Row: id=2, name=Ahmed, email=ahmed@test.com"]
    end

    subgraph mongo["MongoDB"]
        direction TB
        C["Collection: users"]
        C --> D1["Document: {_id, name, email, age}"]
        C --> D2["Document: {_id, name, email}"]
    end

    style sql fill:#1a365d,color:#fff
    style mongo fill:#1a4731,color:#fff
```

**الفروق المهمة:**

**SQL** — Structured. كل البيانات لازم تمشي بنفس الـ schema. قوي في الـ relationships بين الـ tables (JOINs).

**MongoDB** — Flexible. كل document ممكن يبقى شكله مختلف. قوي في الـ data اللي طبيعتها متغيرة أو hierarchical.

في مشروعنا هنستخدم MongoDB. بس عشان نضيف structure وvalidation زي SQL — هنستخدم **Mongoose**.

---

## 🇪🇬 Mongoose — ليه محتاجينه؟

MongoDB في حد ذاته **schemaless** — يعني بيقبل أي document بأي شكل من غير أي validation.

```javascript
// MongoDB بدون Mongoose — بيقبل أي حاجة
db.users.insertOne({ name: "Mohamed" })
db.users.insertOne({ randomField: 123, anotherField: true })
db.users.insertOne({})  // document فاضي — مقبول!
```

ده خطر في production. مش هينفع user يتسجل من غير email. ومش هينفع password يتحفظ plain text.

**Mongoose** بيضيف طبقة فوق MongoDB بتعمل:

```mermaid
flowchart TD
    YourCode["الكود بتاعك"] --> Mongoose

    subgraph Mongoose["Mongoose Layer"]
        S["Schema\nحدد شكل الداتا"]
        V["Validation\nتحقق من الداتا قبل الحفظ"]
        H["Hooks\nشغّل كود قبل أو بعد الحفظ"]
        M["Methods\nأضف functions على الداتا"]
    end

    Mongoose --> Driver["MongoDB Node.js Driver"]
    Driver --> DB["MongoDB Database"]

    style YourCode fill:#2d3748,color:#fff
    style Mongoose fill:#553c9a,color:#fff
    style Driver fill:#2b6cb0,color:#fff
    style DB fill:#276749,color:#fff
```

يعني: أنت بتكلم Mongoose، وMongoose بيكلم MongoDB نيابة عنك بعد ما يتأكد إن الداتا صح.

---

## 🇪🇬 إيه الـ Schema بالظبط؟

الـ Schema هو **عقد** — بيقول: "كل document في الـ collection دي لازم يبقى شكله كده."

فكر فيه زي الـ CREATE TABLE في SQL:

```sql
-- SQL
CREATE TABLE users (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(50) NOT NULL,
  email    VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role     ENUM('client', 'freelancer') DEFAULT 'freelancer'
);
```

ده نفسه في Mongoose:

```javascript
// Mongoose Schema — نفس الفكرة بس بـ JavaScript
const userSchema = new mongoose.Schema({
  name:     { type: String,  required: true },
  email:    { type: String,  unique: true, required: true },
  password: { type: String,  required: true },
  role:     { type: String,  enum: ['client', 'freelancer'], default: 'freelancer' }
});
```

```mermaid
flowchart LR
    subgraph sql_schema["SQL Schema"]
        S1["VARCHAR(50) NOT NULL"] 
        S2["UNIQUE NOT NULL"]
        S3["ENUM('client','freelancer')"]
        S4["DEFAULT 'freelancer'"]
    end

    subgraph mongoose_schema["Mongoose Schema"]
        M1["type: String, maxlength: 50, required: true"]
        M2["type: String, unique: true, required: true"]
        M3["type: String, enum: ['client','freelancer']"]
        M4["default: 'freelancer'"]
    end

    S1 -.->|نفس الفكرة| M1
    S2 -.->|نفس الفكرة| M2
    S3 -.->|نفس الفكرة| M3
    S4 -.->|نفس الفكرة| M4

    style sql_schema fill:#1a365d,color:#fff
    style mongoose_schema fill:#1a4731,color:#fff
```

**لكن في فرق مهم:** الـ SQL schema بيتطبق على مستوى الـ database نفسه. الـ Mongoose schema بيتطبق على مستوى الـ application — في الكود بتاعنا. يعني لو حد اتصل بـ MongoDB مباشرة من غير Mongoose، ممكن يحط أي حاجة.

---

## 🇪🇬 إيه الـ Model بالظبط؟

الـ Schema هو الـ blueprint — التصميم.
الـ Model هو الـ class اللي بتستخدمه فعلاً عشان تتعامل مع الـ database.

تخيله زي كده:

```mermaid
flowchart TD
    subgraph analogy["مثال من الحياة"]
        BP["Blueprint المبنى\nالتصميم على الورق"] -->|ينفذ| BLD["المبنى الفعلي\nبتدخله وتتعامل معاه"]
    end

    subgraph code["في الكود"]
        SCH["userSchema\nالـ Schema — التعريف فقط\nمش بيتكلم مع الـ DB"] -->|mongoose.model| MDL["User Model\nبيتكلم مع الـ DB\nعنده User.find\nوUser.create\nوUser.findById\nوUser.deleteOne"]
    end

    style analogy fill:#2d3748,color:#fff
    style code fill:#2d3748,color:#fff
    style BP fill:#553c9a,color:#fff
    style BLD fill:#276749,color:#fff
    style SCH fill:#553c9a,color:#fff
    style MDL fill:#276749,color:#fff
```

الـ Schema لوحده مش بيعمل حاجة. لازم تعمل منه Model عشان تقدر تتعامل مع الـ database.

---

## 💻 خطوة 1 — Install Mongoose

```bash
npm install mongoose
```

---

## 💻 خطوة 2 — ضيف الـ MONGO_URI في `.env`

افتح الـ `.env` وضيف:

```env
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb://127.0.0.1:27017/freelanceflow
```

**شرح الـ URI:**

`mongodb://` — البروتوكول — زي `http://` بس لـ MongoDB.

`127.0.0.1` — الـ IP address بتاع جهازك المحلي. نفس `localhost`.

`27017` — البورت الافتراضي لـ MongoDB.

`freelanceflow` — اسم الـ database. لو مش موجود، MongoDB هيعمله تلقائياً لما تحفظ أول document.

> 💡 **لو مش عندك MongoDB locally:**
> روح على [mongodb.com/atlas](https://mongodb.com/atlas) — اعمل account مجاني وخد الـ connection string.
> هيبقى شكله: `mongodb+srv://username:password@cluster.mongodb.net/freelanceflow`

---

## 💻 خطوة 3 — اعمل الـ User Schema والـ Model

اعمل ملف `src/models/User.model.js`:

```javascript
const mongoose = require('mongoose');

// ══════════════════════════════════════
// الجزء الأول: Schema — التعريف
// ══════════════════════════════════════

const userSchema = new mongoose.Schema(
  {
    name: {
      type:     String,
      required: [true, 'Please provide your name'],
      trim:     true,
    },

    email: {
      type:      String,
      required:  [true, 'Please provide your email'],
      unique:    true,
      lowercase: true,
    },

    password: {
      type:     String,
      required: [true, 'Please provide a password'],
    },

    role: {
      type:    String,
      enum:    ['client', 'freelancer'],
      default: 'freelancer',
    },
  },

  {
    // Schema Options — الـ object التاني
    timestamps: true,
  }
);

// ══════════════════════════════════════
// الجزء التاني: Model — التنفيذ
// ══════════════════════════════════════

const User = mongoose.model('User', userSchema);

module.exports = User;
```

---

## 🇪🇬 شرح كل سطر في الـ Schema — بالتفصيل الكامل

### `new mongoose.Schema({ ... }, { ... })`

بتعمل Schema object جديد. بياخد **argument اتنين**:

- الأول: الـ fields وقواعدها
- التاني: الـ options العامة للـ schema

---

### `name: { type: String, required: [...], trim: true }`

**`type: String`**

بيقول إن الـ `name` field لازم يكون string. لو حد بعت number أو object — Mongoose هيرفضه.

القيم الممكنة:
- `String`
- `Number`
- `Boolean`
- `Date`
- `mongoose.Schema.Types.ObjectId` — للـ references بين collections (بنيجي عليها)

**`required: [true, 'Please provide your name']`**

مش `required: true` بس. ده array فيه اتنين:
- `true` — يعني الـ field ده إجباري
- `'Please provide your name'` — الرسالة اللي هتظهر لو حد ما بعتش الـ field ده

لو كتبت `required: true` بس من غير رسالة — Mongoose هيدي رسالة generic مش مفيدة.

**`trim: true`**

لو حد بعت `"  Mohamed  "` — بيشيل المسافات من الأول والآخر ويحفظ `"Mohamed"`. مش validator — ده transformation.

---

### `email: { type: String, required: [...], unique: true, lowercase: true }`

**`unique: true`**

ده **مش** Mongoose validator. ده بيعمل **Index** في MongoDB نفسه.

```mermaid
flowchart TD
    subgraph validator["Mongoose Validator"]
        V1["required: true"]
        V2["بيشتغل في الـ application layer"]
        V3["بيرمي ValidationError"]
    end

    subgraph index["MongoDB Index"]
        I1["unique: true"]
        I2["بيشتغل في الـ database layer"]
        I3["بيرمي MongoServerError code 11000"]
    end

    style validator fill:#1a365d,color:#fff
    style index fill:#553c9a,color:#fff
```

يعني لو بعتين users بنفس الـ email:

- الـ `required` هيعمل `ValidationError`
- الـ `unique` هيعمل `MongoServerError` بـ code `11000`

الاتنين بنتعامل معاهم في الـ error handler — بعدين في Sprint 2 المتقدم.

**`lowercase: true`**

مش validator — ده transformation. بيحول الـ email لـ lowercase قبل الحفظ.

يعني `"Mohamed@Test.COM"` هيتحفظ كـ `"mohamed@test.com"`. ده مهم عشان الـ email match يبقى consistent.

---

### `role: { type: String, enum: ['client', 'freelancer'], default: 'freelancer' }`

**`enum: ['client', 'freelancer']`**

بيقول إن الـ role مينفعش تبقى غير إحدى القيمتين دول. لو حد بعت `role: 'admin'` — Mongoose هيرفضه.

**`default: 'freelancer'`**

لو حد سجّل من غير ما يبعت role — القيمة الافتراضية هتبقى `'freelancer'`.

---

### `{ timestamps: true }` — الـ Schema Options

ده الـ argument التاني لـ `new mongoose.Schema(...)`.

`timestamps: true` بيقول لـ Mongoose: "ضيف تلقائياً fieldين على كل document":

- `createdAt` — وقت ما الـ document اتعمل
- `updatedAt` — وقت آخر تعديل عليه

من غير ما تكتب سطر زيادة — Mongoose بيديهم تلقائياً وبيحدّثهم تلقائياً.

```mermaid
flowchart LR
    A["User.create({name, email, password})"] --> B["Mongoose بيضيف\nتلقائياً"]
    B --> C["_id: ObjectId\ncreatedAt: Date.now()\nupdatedAt: Date.now()"]

    style A fill:#2d3748,color:#fff
    style B fill:#553c9a,color:#fff
    style C fill:#276749,color:#fff
```

---

### `mongoose.model('User', userSchema)`

ده السطر اللي بيحوّل الـ Schema لـ Model.

```javascript
const User = mongoose.model('User', userSchema);
```

**`'User'`** — اسم الـ Model. Mongoose بياخد الاسم ده ويعمله lowercase وplural عشان يحدد اسم الـ collection:

```
'User'     → collection: 'users'
'Product'  → collection: 'products'
'BlogPost' → collection: 'blogposts'
```

**`userSchema`** — الـ blueprint اللي عملناه.

**الناتج `User`** — ده الـ class اللي هنستخدمه في كل الـ controllers:

```javascript
// كل ده بيبقى متاح بعد ما تعمل Model
User.find()                // SELECT * FROM users
User.findById(id)          // SELECT * FROM users WHERE id = ?
User.findOne({ email })    // SELECT * FROM users WHERE email = ? LIMIT 1
User.create({ ... })       // INSERT INTO users VALUES (...)
User.findByIdAndUpdate()   // UPDATE users SET ... WHERE id = ?
User.findByIdAndDelete()   // DELETE FROM users WHERE id = ?
User.countDocuments()      // SELECT COUNT(*) FROM users
```

---

## 💻 خطوة 4 — وصّل الـ Server بـ MongoDB

في `server.js` ضيف الـ connection:

```javascript
require('dotenv').config();
const express            = require('express');
const mongoose           = require('mongoose');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');
const User               = require('./src/models/User.model');

const app  = express();
const PORT = process.env.PORT || 5000;

// ✅ CONNECT TO MONGODB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Connected');
  })
  .catch((err) => {
    console.error('❌ MongoDB Connection Failed:', err.message);
    process.exit(1); // لو الـ DB مش شغال — مفيش فايدة نكمل
  });

app.use(express.json());

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

// ✅ NEW: Test route — بنخلق user مباشرة عشان نشوف إن الـ DB شغال
app.post('/test-user', async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json({
      status: 'success',
      data:   { user },
    });
  } catch (err) {
    next(err);
  }
});

app.get('/test-error', (req, res, next) => {
  next(new AppError('This is a fake error!', 400));
});

app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

app.use(globalErrorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## 🇪🇬 شرح `mongoose.connect()`

```javascript
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => { console.log('✅ Connected') })
  .catch((err) => { process.exit(1) });
```

`mongoose.connect()` بترجع **Promise** — يعني بياخد وقت. مش بيحصل فوراً. لازم تستنى الـ database تقول "أنا جاهز".

`.then(...)` — بيشتغل لو الـ connection نجح.

`.catch(...)` — بيشتغل لو فشل. `process.exit(1)` بيوقف السيرفر كله — لو الـ database مش شغال، السيرفر مش هينفع يكمل.

```mermaid
sequenceDiagram
    participant S as server.js
    participant M as Mongoose
    participant DB as MongoDB

    S->>M: mongoose.connect(MONGO_URI)
    M->>DB: TCP Connection attempt
    alt Connection successful
        DB-->>M: Connected ✅
        M-->>S: .then() يشتغل
        S->>S: console.log Connected
    else Connection failed
        DB-->>M: Refused ❌
        M-->>S: .catch() يشتغل
        S->>S: process.exit(1)
    end
```

---

## 🇪🇬 شرح `User.create(req.body)` — الـ journey الكاملة

لما بتعمل `await User.create(req.body)` — في رحلة كاملة بتحصل:

```mermaid
flowchart TD
    A["User.create(req.body)"] --> B

    subgraph validation["Step 1: Validation"]
        B["Mongoose بيتحقق من الـ Schema:\nهل name موجود؟\nهل email موجود؟\nهل role في الـ enum؟"]
    end

    B -->|فشل| ERR1["ValidationError\nبتوصل للـ Error Handler"]
    B -->|نجح| C

    subgraph hooks["Step 2: Hooks"]
        C["بيشغّل pre-save hooks\n(مفيش حاليا — Sprint 4 هيضيفهم)"]
    end

    C --> D

    subgraph insert["Step 3: Database Insert"]
        D["بيبعت INSERT للـ MongoDB\nومنهم:\n_id يتولّد تلقائياً\ncreatedAt\nupdatedAt"]
    end

    D -->|فشل| ERR2["MongoServerError\nمثلاً duplicate email"]
    D -->|نجح| E

    subgraph posthooks["Step 4: Post Hooks"]
        E["بيشغّل post-save hooks\n(مفيش حاليا)"]
    end

    E --> F["بيرجع الـ document كامل"]

    style validation fill:#1a365d,color:#fff
    style hooks fill:#553c9a,color:#fff
    style insert fill:#276749,color:#fff
    style posthooks fill:#553c9a,color:#fff
    style ERR1 fill:#742a2a,color:#fff
    style ERR2 fill:#742a2a,color:#fff
```

---

## 🇪🇬 ليه استخدمنا `async/await` هنا؟

```javascript
app.post('/test-user', async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    ...
  } catch (err) {
    next(err);
  }
});
```

`User.create()` بياخد وقت — لازم يكلم الـ database على الشبكة. ده مش بيحصل فوراً.

`async` بتقول للـ function "أنت ممكن تستنى حاجة".

`await` بتقول "استنّى لحد ما الـ `User.create()` يخلص" — بس من غير ما توقف السيرفر كله.

```mermaid
sequenceDiagram
    participant R as Route Handler
    participant M as Mongoose
    participant DB as MongoDB

    R->>M: await User.create(data)
    Note over R: الـ route handler بيستنى
    Note over R: بس السيرفر كله مش واقف
    M->>DB: INSERT document
    DB-->>M: Document saved ✅
    M-->>R: بيرجع الـ user document
    R->>R: res.json(user)
```

الـ `try/catch` حوالين `await User.create()` عشان لو حصل error — بنبعته للـ `next(err)` اللي بيوصله للـ global error handler.

---

## ✅ Checkpoint

شغّل السيرفر. المفروض تشوف في الـ terminal:

```
Server running on port 5000
✅ MongoDB Connected
```

**Test 1 — اخلق User صح:**

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-user`
> **Body (raw JSON):**
> ```json
> {
>   "name": "Mohamed",
>   "email": "mo@test.com",
>   "password": "pass1234",
>   "role": "client"
> }
> ```
>
> **Expected:**
> ```json
> {
>   "status": "success",
>   "data": {
>     "user": {
>       "_id": "...",
>       "name": "Mohamed",
>       "email": "mo@test.com",
>       "password": "pass1234",
>       "role": "client",
>       "createdAt": "...",
>       "updatedAt": "..."
>     }
>   }
> }
> ```

> ⚠️ **لاحظ:** الـ `password` ظاهر كـ plain text. ده مشكلة كبيرة — Sprint 4 هيحلها.

**Test 2 — بعت من غير required fields:**

> **Body:** `{ "name": "Ahmed" }`
>
> **Expected:** ValidationError رسالة فيها "Please provide your email" و"Please provide a password"

**Test 3 — نفس الـ email مرتين:**

> ابعت Test 1 تاني مرة بنفس الـ email بالظبط.
>
> **Expected:** Error بيقول الـ email موجود بالفعل — رسالة مش جميلة دلوقتي، بنحسنها بعدين.

**Test 4 — بعت role غلط:**

> **Body:** `{ "name": "Sara", "email": "sara@test.com", "password": "pass1234", "role": "admin" }`
>
> **Expected:** ValidationError بيقول إن `admin` مش في الـ enum

---

## 🇪🇬 ملخص Sprint 3

اللي اتعلمته:

- الـ database ضرورية عشان البيانات متروحش لما السيرفر يقف
- MongoDB بتخزن **Documents** في **Collections** — زي rows في tables في SQL
- Mongoose بيضيف validation وstructure فوق MongoDB
- الـ **Schema** هو التعريف — بيحدد شكل الداتا وقواعدها
- الـ **Model** هو الـ class اللي بتتعامل بيه مع الـ database
- `mongoose.model('User', schema)` بيخلق collection اسمها `users` في الـ DB
- `User.create(data)` بيعمل validation الأول، بعدين بيحفظ في الـ DB
- الـ `timestamps: true` بيضيف `createdAt` و`updatedAt` تلقائياً

---

> **جاهز للـ Sprint 4؟**
>
> Sprint 4 هو أهم sprint في الـ security — **Password Hashing**.
>
> هنشوف ليه الـ `password: "pass1234"` اللي بيتحفظ دلوقتي خطر جداً، وهنفهم إيه الـ hashing وليه مختلف عن الـ encryption، وهنبني الـ `pre('save')` hook اللي بيعمل hash للـ password تلقائياً قبل ما يتحفظ في الـ DB.
>
> قول "كمّل" لما تكون شفت الـ user اتحفظ في الـ DB بنفسك وجربت الـ 4 tests.
