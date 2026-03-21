# 🎓 FreelanceFlow — Learning Journey (Part B)
> متابعة من Part A — Sprints 0 → 4
> **Part B يبدأ من:** Sprint 5 — Register Flow

---

# 👤 Sprint 5 — Register : أول Endpoint حقيقي

---

## المشكلة — الكود كله في `server.js`

دلوقتي كل حاجة في ملف واحد. كلما ضفنا route ضفناه في `server.js`. لو كملنا كده — الملف هيبقى 500 سطر وصعب تلاقي أي حاجة.

في production apps بنقسّم الكود على ملفات حسب مسؤولياتهم.

```mermaid
flowchart TD
    subgraph before["❌ قبل — كل حاجة في server.js"]
        S["server.js<br/>500+ سطر<br/>فيه routes وlogic وconnection وكل حاجة"]
    end

    subgraph after["✅ بعد — مقسّم صح"]
        SV["server.js<br/>بس connection وapp.listen"]
        AP["app.js<br/>Middlewares وRoutes mounting"]
        AR["auth.routes.js<br/>Route definitions"]
        AC["auth.controller.js<br/>Business logic"]
        UM["User.model.js<br/>Database schema"]
    end

    style before fill:#4a1212,color:#fff
    style after fill:#1a4731,color:#fff
```

---

## الـ MVC Pattern — إيه ده؟

MVC اختصار لـ Model-View-Controller. ده pattern لتنظيم الكود.

في الـ API بتاعتنا مفيش View (مفيش HTML). بس عندنا:

```mermaid
flowchart LR
    subgraph MVC["MVC في الـ API"]
        M["Model<br/>User.model.js<br/>شكل الداتا<br/>وقواعدها<br/>وهooksها"]
        C["Controller<br/>auth.controller.js<br/>الـ logic<br/>بياخد request<br/>بيكلم Model<br/>بيبعت response"]
        R["Routes<br/>auth.routes.js<br/>بيربط URLs<br/>بالـ Controllers"]
    end

    REQ["Request"] --> R
    R --> C
    C --> M
    M --> C
    C --> RES["Response"]

    style M fill:#276749,color:#fff
    style C fill:#2b6cb0,color:#fff
    style R fill:#553c9a,color:#fff
    style REQ fill:#2d3748,color:#fff
    style RES fill:#2d3748,color:#fff
```

كل طبقة عندها **مسؤولية واحدة بس:**

- **Model** — يعرف شكل الداتا وقواعدها. مش شغلته يعرف إيه الـ HTTP status code.
- **Controller** — يعرف يستقبل request ويرد response. مش شغلته يعرف تفاصيل الـ database.
- **Route** — يعرف يوصّل URL بـ Controller. مش شغلته يعرف الـ logic.

---

## إيه الـ `catchAsync` ولازم نعمله ليه؟

في كل controller هنكتب `async/await`. وكل `async` ممكن يـ throw error.

دلوقتي بنكتب كده في كل route:

```javascript
app.post('/test-user', async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.json({ user });
  } catch (err) {
    next(err); // ← بنكرر ده في كل controller
  }
});
```

لو عندنا 20 controller — هنكتب نفس الـ `try/catch` 20 مرة.

الحل: بنعمل **wrapper function** بتلف أي async function وبتمسك أي error تلقائياً:

```mermaid
flowchart TD
    subgraph without["❌ بدون catchAsync"]
        W1["controller 1<br/>try catch next err"]
        W2["controller 2<br/>try catch next err"]
        W3["controller 3<br/>try catch next err"]
    end

    subgraph with["✅ مع catchAsync"]
        WA["catchAsync<br/>واحدة بس<br/>bتمسك كل الـ errors"]
        WA --> C1["controller 1<br/>نظيف بدون try catch"]
        WA --> C2["controller 2<br/>نظيف بدون try catch"]
        WA --> C3["controller 3<br/>نظيف بدون try catch"]
    end

    style without fill:#4a1212,color:#fff
    style with fill:#1a4731,color:#fff
```

---

## 💻 خطوة 1 — الـ Folder Structure الجديدة

اعمل الـ folders دي:

```bash
mkdir src/controllers
mkdir src/routes
```

الـ structure هتبقى كده:

```
freelance-flow/
├── src/
│   ├── controllers/
│   │   └── auth.controller.js    ← جديد
│   ├── middlewares/
│   │   └── errorHandler.js
│   ├── models/
│   │   └── User.model.js
│   ├── routes/
│   │   └── auth.routes.js        ← جديد
│   └── utils/
│       └── AppError.js
│       └── catchAsync.js         ← جديد
├── .env
├── server.js
```

---

## 💻 خطوة 2 — اعمل `src/utils/catchAsync.js`

```javascript
// catchAsync هي function بتاخد function وبترجع function
// يعني: higher-order function
const catchAsync = (fn) => {
  return (req, res, next) => {
    // بتشغّل الـ async function
    // لو رجعت error — .catch(next) بيبعتها للـ error handler
    fn(req, res, next).catch(next);
  };
};

module.exports = catchAsync;
```

---

## شرح `catchAsync` بالتفصيل

```javascript
const catchAsync = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};
```

ده اللي بيحصل خطوة بخطوة:

```mermaid
flowchart TD
    A["catchAsync(myController)"] --> B["بترجع function جديدة<br/>(req, res, next) => ..."]
    B --> C["Express بيشغّل الـ function دي<br/>لما الـ request ييجي"]
    C --> D["fn(req, res, next)<br/>يعني بتشغّل الـ controller الأصلي"]
    D -->|نجح| E["Controller بعت response<br/>خلاص ✅"]
    D -->|فشل - throw أو reject| F[".catch(next)"]
    F --> G["next(err)<br/>بيوصل للـ Global Error Handler"]

    style A fill:#553c9a,color:#fff
    style B fill:#2b6cb0,color:#fff
    style E fill:#276749,color:#fff
    style F fill:#742a2a,color:#fff
    style G fill:#742a2a,color:#fff
```

**مثال عملي — الفرق:**

```javascript
// ❌ بدون catchAsync — مملّ ومتكرر
exports.register = async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json({ user });
  } catch (err) {
    next(err);
  }
};

// ✅ مع catchAsync — نظيف
exports.register = catchAsync(async (req, res, next) => {
  const user = await User.create(req.body);
  res.status(201).json({ user });
  // لو User.create رمى error — catchAsync بيمسكه ويبعته لـ next()
});
```

---

## 💻 خطوة 3 — اعمل `src/controllers/auth.controller.js`

```javascript
const User       = require('../models/User.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// REGISTER
// ══════════════════════════════════════════════════════
exports.register = catchAsync(async (req, res, next) => {

  // Step 1: اخلق الـ User
  // الـ password هيتعمله hash تلقائياً بسبب الـ pre-save hook
  const newUser = await User.create({
    name:     req.body.name,
    email:    req.body.email,
    password: req.body.password,
    role:     req.body.role,
  });

  // Step 2: بعت الـ response
  // 201 = Created — مش 200 OK
  res.status(201).json({
    status: 'success',
    data: {
      user: newUser,
    },
  });
});
```

---

## ليه `201` مش `200`؟

الـ HTTP Status Codes مش decoration — بيوصلوا معنى:

```mermaid
flowchart LR
    subgraph codes["HTTP Status Codes المهمة"]
        C200["200 OK<br/>الطلب نجح<br/>وفيه response body"]
        C201["201 Created<br/>اتعمل resource جديد بنجاح"]
        C204["204 No Content<br/>نجح بس مفيش حاجة ترجعها<br/>مثلاً بعد DELETE"]
        C400["400 Bad Request<br/>الـ client بعت بيانات غلط"]
        C401["401 Unauthorized<br/>مش logged in"]
        C403["403 Forbidden<br/>logged in بس مش مسموحلك"]
        C404["404 Not Found<br/>الـ resource مش موجود"]
        C500["500 Internal Server Error<br/>السيرفر وقع بسبب bug"]
    end

    style C200 fill:#276749,color:#fff
    style C201 fill:#276749,color:#fff
    style C204 fill:#276749,color:#fff
    style C400 fill:#744210,color:#fff
    style C401 fill:#742a2a,color:#fff
    style C403 fill:#742a2a,color:#fff
    style C404 fill:#744210,color:#fff
    style C500 fill:#4a1212,color:#fff
```

`POST /register` بيخلق user جديد — الصح إنك تبعت `201 Created`.

لو بعتنا `200 OK` — مش غلط technically، بس مش semantically صح. والـ clients اللي بتتكلم مع الـ API بتعتمد على الـ status codes دي.

---

## ليه بنكتب `req.body.name` بدل `...req.body`؟

```javascript
// ❌ خطر — بتثق في كل حاجة جاية من الـ client
const newUser = await User.create(req.body);

// ✅ آمن — بتحدد بالظبط إيه اللي بتقبله
const newUser = await User.create({
  name:     req.body.name,
  email:    req.body.email,
  password: req.body.password,
  role:     req.body.role,
});
```

تخيل حد بعت:

```json
{
  "name": "Mohamed",
  "email": "mo@test.com",
  "password": "pass1234",
  "role": "client",
  "isAdmin": true
}
```

لو استخدمنا `...req.body` — ممكن يبقى عندنا field زيادة في الـ document. Mongoose هيتجاهله لأنه مش في الـ Schema — بس ده habit خطير لازم تتجنبه من الأول.

```mermaid
flowchart TD
    A["Client بعت:<br/>name, email, password, role, isAdmin"] --> B{كيف بنتعامل مع الـ body؟}
    B -->|"User.create(req.body)"| C["❌ بتثق في كل حاجة<br/>خطر على المدى البعيد"]
    B -->|"User.create({ name, email, ... })"| D["✅ بتحدد بالظبط<br/>إيه اللي بتقبله"]

    style C fill:#4a1212,color:#fff
    style D fill:#1a4731,color:#fff
```

---

## 💻 خطوة 4 — اعمل `src/routes/auth.routes.js`

```javascript
const express = require('express');
const { register } = require('../controllers/auth.controller');

// express.Router() بيعمل mini-app
// بتحدد فيه routes وبعدين بتـ mount على الـ app الأساسي
const router = express.Router();

// POST /api/v1/auth/register
router.post('/register', register);

module.exports = router;
```

---

## شرح `express.Router()`

الـ `express.Router()` بيعمل router object — زي mini version من الـ `app`.

الفكرة: بدل ما تكتب `app.post('/api/v1/auth/register', handler)` في `server.js` — بتعمل router منفصل، وبتـ mount عليه الـ routes بتاعته، وبعدين بتوصّله على الـ app.

```mermaid
flowchart TD
    APP["app.js<br/>app.use('/api/v1/auth', authRouter)"]

    subgraph authRouter["auth.routes.js — authRouter"]
        R1["POST /register → register controller"]
        R2["POST /login → login controller"]
    end

    APP --> authRouter

    REQ1["POST /api/v1/auth/register"] --> APP
    REQ2["POST /api/v1/auth/login"] --> APP

    style APP fill:#553c9a,color:#fff
    style authRouter fill:#2b6cb0,color:#fff
```

لما بتعمل `app.use('/api/v1/auth', authRouter)` — Express بيقول:

> "أي request URL يبدأ بـ `/api/v1/auth` — اديه للـ authRouter."

والـ authRouter بعدين بيشوف باقي الـ URL — `/register` أو `/login` وبيوصلها للـ controller الصح.

---

## 💻 خطوة 5 — اعمل `app.js`

اعمل ملف جديد `app.js` في الـ root:

```javascript
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

// Import Routes
const authRoutes = require('./src/routes/auth.routes');

const app = express();

// ═══════════════════════════════
// Global Middlewares
// ═══════════════════════════════
app.use(express.json());

// ═══════════════════════════════
// Routes
// ═══════════════════════════════
app.use('/api/v1/auth', authRoutes);

// ═══════════════════════════════
// 404 — أي route مش موجودة
// ═══════════════════════════════
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

// ═══════════════════════════════
// Global Error Handler — آخر حاجة
// ═══════════════════════════════
app.use(globalErrorHandler);

module.exports = app;
```

---

## 💻 خطوة 6 — نظّف `server.js`

`server.js` دلوقتي مسؤوليته بس: وصّل الـ DB وشغّل الـ server.

```javascript
require('dotenv').config();

const mongoose = require('mongoose');
const app      = require('./app');

const PORT     = process.env.PORT     || 5000;
const MONGO_URI = process.env.MONGO_URI;

// ═══════════════════════════════
// Handle uncaught exceptions
// (errors خارج Express — زي syntax error في الكود)
// ═══════════════════════════════
process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down...');
  console.error(err.name, err.message);
  process.exit(1);
});

// ═══════════════════════════════
// Connect to MongoDB
// ═══════════════════════════════
mongoose
  .connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => {
    console.error('❌ MongoDB Connection Failed:', err.message);
    process.exit(1);
  });

// ═══════════════════════════════
// Start Server
// ═══════════════════════════════
const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

// ═══════════════════════════════
// Handle unhandled promise rejections
// (errors جوا async code مش اتمسكوا)
// ═══════════════════════════════
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! Shutting down...');
  console.error(err.name, err.message);
  server.close(() => process.exit(1));
});
```

---

## شرح `uncaughtException` و`unhandledRejection`

دول اتنين scenarios خطيرين:

```mermaid
flowchart TD
    subgraph uncaught["uncaughtException"]
        U1["Error حصل في<br/>synchronous code<br/>ومحدش مسكه بـ try/catch"]
        U1 --> U2["مثلاً: خطأ في top-level code"]
        U2 --> U3["process.exit(1)"]
    end

    subgraph unhandled["unhandledRejection"]
        R1["Promise rejected<br/>ومحدش عمله .catch()"]
        R1 --> R2["مثلاً: DB connection فشل<br/>بعد ما السيرفر اشتغل"]
        R2 --> R3["server.close() أولاً<br/>بعدين process.exit(1)"]
    end

    style uncaught fill:#742a2a,color:#fff
    style unhandled fill:#4a1212,color:#fff
```

**ليه `server.close()` قبل `process.exit()`؟**

`server.close()` بيوقف السيرفر من قبول requests جديدة — بس بيخلي الـ requests الموجودة خلاص تكمل. بعدين `process.exit(1)` بيوقف العملية كلها. ده أنظف من إنك توقف فجأة.

---

## الـ Request Flow الكاملة بعد التقسيم

```
    Client (Postman) ──► server.js: POST /api/v1/auth/register
    server.js ──► app.js: app(req, res)
    app.js ──► express.json(): express.json() parses body
    express.json() ──► auth.routes.js: يطابق /api/v1/auth
    auth.routes.js ──► auth.controller.js: يطابق POST /register
    auth.controller.js ──► User.model.js: User.create(data)
    User.model.js → pre-save hook — bcrypt.hash
    User.model.js ──► MongoDB: INSERT document
    MongoDB ──► User.model.js: user saved
    User.model.js ──► auth.controller.js: return newUser
    auth.controller.js ──► Client (Postman): res.status(201).json({ user })
```

---

## ✅ Checkpoint

شغّل السيرفر: `npm run dev`

المفروض تشوف:

```
🚀 Server running on port 5000
✅ MongoDB Connected
```

> [!example] Test 1 — Register صح
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/auth/register` **Body (raw JSON):**
> 
> ```json
> {
>   "name": "Mohamed",
>   "email": "newuser@test.com",
>   "password": "password123",
>   "role": "client"
> }
> ```
> 
> **Expected:**
> 
> ```json
> {
>   "status": "success",
>   "data": {
>     "user": {
>       "_id": "...",
>       "name": "Mohamed",
>       "email": "newuser@test.com",
>       "role": "client",
>       "createdAt": "...",
>       "updatedAt": "..."
>     }
>   }
> }
> ```
> 
> **لاحظ:** الـ `password` مش موجود في الـ response — `select: false` شغّال.
> 
> **لاحظ:** الـ status في Postman فوق: `201 Created` مش `200 OK`.

> [!example] Test 2 — Email موجود بالفعل
> ابعت نفس الـ request بنفس الـ email مرة تانية.
> 
> **Expected:** error بيقول duplicate

> [!example] Test 3 — بيانات ناقصة
> **Body:** `{ "name": "Ahmed" }`
> 
> **Expected:** ValidationError

> [!example] Test 4 — Route مش موجودة
> **Method:** `GET` **URL:** `http://localhost:5000/api/v1/auth/anything`
> 
> **Expected:** `{ "status": "fail", "message": "Can't find..." }`

---

## ملخص Sprint 5

اللي اتعلمته:

- **MVC Pattern** — كل layer عندها مسؤولية واحدة بس
- **`catchAsync`** — بتلف الـ async controllers وبتمسك الـ errors تلقائياً
- **`express.Router()`** — بتعمل mini-app للـ routes وبتـ mount على الـ app
- **`201 Created`** مش `200 OK` — الـ status codes بيوصّلوا معنى
- **`req.body.field`** مش `...req.body` — بتحدد بالظبط إيه اللي بتقبله
- **`app.js`** vs **`server.js`** — الأول للـ Express setup، التاني للـ DB وبدء التشغيل
- **`uncaughtException`** و**`unhandledRejection`** — للـ errors اللي خارج Express

---

> **جاهز للـ Sprint 6؟**
> 
> Sprint 6 هو **Login + JWT**. هنشوف إيه الـ JWT بالظبط — 3 أجزاء، إزاي بيتعمل، وإيه معنى "Stateless Authentication". وهنبني الـ login endpoint اللي بيرجع token.
> 
> قول "كمّل" لما تكون شفت الـ `201 Created` في Postman بنفسك.

---

---

# 🔑 Sprint 6 — Login + JWT : إزاي السيرفر بيتذكرك؟

---

## المشكلة — HTTP مش بيتذكر حاجة

قبل ما نبني الـ Login، لازم تفهم مشكلة أساسية في طبيعة الـ HTTP نفسه.

الـ HTTP بطبعه **Stateless** — يعني كل request مستقلة تماماً عن اللي قبلها.

تخيل إنك بتكلم حد على التليفون — بس كل مرة بتكلمه بينساك خالص ولازم تعرّف نفسك من الأول.

```
    User ──► Server: POST /login بـ email وpassword
    Server ──► User: أهلاً Mohamed ✅
    User ──► Server: GET /my-profile
    Server ──► User: مين أنت؟ ❌ مش فاكرك
    User ──► Server: POST /create-project
    Server ──► User: مين أنت؟ ❌ مش فاكرك
```

كل request وصلت للسيرفر من غير أي معلومة عن مين بعتها.

**الحل القديم — Sessions:**

```mermaid
flowchart TD
    subgraph sessions["الحل القديم — Sessions"]
        L["User عمل Login"] --> DB["السيرفر حفظ session<br/>في الـ Database<br/>session_id=abc123 → Mohamed"]
        DB --> C["بعت cookie للـ client<br/>session_id=abc123"]
        C --> R["كل request جاية<br/>السيرفر بيروح يجيب<br/>الـ session من الـ DB"]
    end

    style sessions fill:#4a1212,color:#fff
```

المشكلة مع الـ Sessions:

- كل request لازم query على الـ DB عشان تتحقق من الـ session
- لو عندك 3 servers — لازم كلهم يشوفوا نفس الـ sessions database
- مع scale كبير — بيبقى bottleneck

---

## الحل الحديث — JWT

JWT (JSON Web Token) بيحل المشكلة بطريقة مختلفة تماماً:

**بدل ما السيرفر يتذكرك — بنديك ورقة موقّعة تثبت هويتك.**

```
    User ──► Server: POST /login بـ email وpassword
    Server ──► Database: تحقق من الـ credentials
    Database ──► Server: صح ✅
    Server ──► User: خد الـ token ده: eyJhbGci...
    # الـ client بيحفظ الـ token
    User ──► Server: GET /my-profile Authorization: Bearer eyJhbGci...
    # بيتحقق من الـ token بدون DB
    Server ──► User: بيانات Mohamed ✅
    User ──► Server: POST /create-project Authorization: Bearer eyJhbGci...
    # بيتحقق من الـ token بدون DB
    Server ──► User: Project اتعمل ✅
```

**الفرق الجوهري:** السيرفر مش بيحفظ حاجة. بيتحقق من الـ token بـ math بس — من غير ما يروح للـ DB.

---

## إيه جوا الـ JWT بالظبط؟

الـ JWT شكله كده:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY0YWJjIiwiaWF0IjoxNjk5MDAwMDAwLCJleHAiOjE2OTk2MDQ4MDB9.xK9mP2Rz8vQY3nJ5tL7wA1bF4hN6sD0cE9uI2oM
```

فيه 3 أجزاء مفصولة بـ `.`

```mermaid
flowchart LR
    subgraph jwt["JWT = 3 أجزاء"]
        H["Header<br/>Base64<br/>{alg: HS256, typ: JWT}"]
        P["Payload<br/>Base64<br/>{id: '64abc', iat: ..., exp: ...}"]
        S["Signature<br/>HMAC SHA256"]
    end

    H -->|"."| P
    P -->|"."| S

    style H fill:#1a365d,color:#fff
    style P fill:#276749,color:#fff
    style S fill:#553c9a,color:#fff
```

**الجزء الأول — Header:**

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

بيقول الـ algorithm المستخدم في الـ signing هو `HS256`.

**الجزء التاني — Payload:**

```json
{
  "id": "64abc123",
  "iat": 1699000000,
  "exp": 1699604800
}
```

`id` — الـ user ID — ده اللي بنحطه عشان نعرف مين الـ user.

`iat` — issued at — وقت ما الـ token اتعمل.

`exp` — expiry — وقت انتهاء الصلاحية.

> ⚠️ الـ Payload مش مشفّر — بس مـ Base64 encoded. يعني أي حد يقدر يقراه. متحطش passwords أو sensitive data فيه.

**الجزء التالت — Signature:**

```
HMACSHA256(
  base64(header) + "." + base64(payload),
  SECRET_KEY
)
```

ده اللي بيخلي الـ JWT آمن. بيعمل hash للـ header والـ payload باستخدام الـ secret key اللي على السيرفر بس.

```mermaid
flowchart TD
    subgraph verify["إزاي السيرفر بيتحقق من الـ Token؟"]
        T["Token وصل:<br/>header.payload.signature"]
        T --> A["بيعمل الـ signature من الأول<br/>باستخدام الـ SECRET_KEY"]
        A --> B{الـ signature اللي عمله<br/>= الـ signature في الـ Token؟}
        B -->|نعم ✅| C["Token صح — يثق بالـ payload"]
        B -->|لأ ❌| D["Token اتعدّل — ارفضه"]
    end

    style T fill:#2d3748,color:#fff
    style A fill:#553c9a,color:#fff
    style C fill:#276749,color:#fff
    style D fill:#742a2a,color:#fff
```

لو حد غيّر الـ payload (مثلاً غيّر الـ `id` لـ user تاني) — الـ signature مش هيتطابق والسيرفر هيعرف إن الـ token اتعدّل.

---

## 💻 خطوة 1 — Install JWT

```bash
npm install jsonwebtoken
```

---

## 💻 خطوة 2 — ضيف الـ JWT settings في `.env`

```env
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb://127.0.0.1:27017/freelanceflow
JWT_SECRET=my-super-secret-key-change-this-in-production-min-32-chars
JWT_EXPIRES_IN=7d
```

**`JWT_SECRET`** — الكلمة السرية اللي بيتعمل بيها الـ signature. لازم تكون:

- طويلة (32+ character)
- عشوائية
- محفوظة في الـ `.env` — **مش في الكود أبداً**

**`JWT_EXPIRES_IN`** — بعد كام الـ token بينتهي. `7d` يعني 7 أيام. ممكن كمان `1h` أو `30d`.

---

## 💻 خطوة 3 — ضيف `login` في `auth.controller.js`

افتح `src/controllers/auth.controller.js` وعدّله:

```javascript
const jwt      = require('jsonwebtoken');
const User     = require('../models/User.model');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// Helper function — بنعملها مرة وبنستخدمها في register وlogin
// ══════════════════════════════════════════════════════
const signToken = (userId) => {
  return jwt.sign(
    { id: userId },               // الـ payload — إيه اللي هيتحط في الـ token
    process.env.JWT_SECRET,        // الـ secret key
    { expiresIn: process.env.JWT_EXPIRES_IN } // متى ينتهي
  );
};

const sendTokenResponse = (user, statusCode, res) => {
  // اعمل الـ token
  const token = signToken(user._id);

  // إزاي الـ password مش بيبان في الـ response
  // حتى لو Mongoose رجّعه في الـ document — بنشيله هنا
  user.password = undefined;

  res.status(statusCode).json({
    status: 'success',
    token,
    data: { user },
  });
};

// ══════════════════════════════════════════════════════
// REGISTER
// ══════════════════════════════════════════════════════
exports.register = catchAsync(async (req, res, next) => {
  const newUser = await User.create({
    name:     req.body.name,
    email:    req.body.email,
    password: req.body.password,
    role:     req.body.role,
  });

  sendTokenResponse(newUser, 201, res);
});

// ══════════════════════════════════════════════════════
// LOGIN
// ══════════════════════════════════════════════════════
exports.login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  // Step 1: تحقق إن الـ email والـ password موجودين في الـ request
  if (!email || !password) {
    return next(new AppError('Please provide email and password', 400));
  }

  // Step 2: دور على الـ user بالـ email
  // .select('+password') عشان password عنده select:false في الـ Schema
  const user = await User.findOne({ email }).select('+password');

  // Step 3: تحقق من إن الـ user موجود والـ password صح
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return next(new AppError('Incorrect email or password', 401));
  }

  // Step 4: ابعت الـ token
  sendTokenResponse(user, 200, res);
});
```

---

## مشكلة في الكود — `bcrypt` مش متعمله import

لاحظ إننا استخدمنا `bcrypt.compare` في الـ controller — بس `bcrypt` مش متعمله `require` هنا.

**ليه؟** لأن الـ compare منطقياً مش مكانه في الـ controller. هو عملية خاصة بالـ user data — مكانها في الـ **Model**.

الحل: نعمل **instance method** على الـ User model.

---

## إيه هو الـ Instance Method؟

الـ Instance Method هو function بتضيفها على الـ Schema — وبتبقى متاحة على كل document.

```mermaid
flowchart TD
    subgraph schema["User Schema"]
        M1["userSchema.methods.correctPassword"]
    end

    subgraph docs["كل User Document"]
        D1["user1.correctPassword(...)"]
        D2["user2.correctPassword(...)"]
        D3["user3.correctPassword(...)"]
    end

    schema --> docs

    style schema fill:#553c9a,color:#fff
    style docs fill:#276749,color:#fff
```

الـ `this` جوا الـ instance method بيبقى الـ document نفسه — زي بالظبط الـ pre-save hook.

---

## 💻 خطوة 4 — أضف Instance Method على User Model

افتح `src/models/User.model.js` وضيف بعد الـ hook:

```javascript
// ══════════════════════════════════════════════════════
// INSTANCE METHOD — متاح على كل user document
// ══════════════════════════════════════════════════════
userSchema.methods.correctPassword = async function (candidatePassword) {
  // this.password = الـ hashed password في الـ DB
  // candidatePassword = الـ password اللي الـ user بعته في الـ login
  return await bcrypt.compare(candidatePassword, this.password);
};
```

---

## 💻 خطوة 5 — صلّح الـ login في `auth.controller.js`

دلوقتي بدل `bcrypt.compare` — بنستخدم الـ instance method:

```javascript
const jwt        = require('jsonwebtoken');
const User       = require('../models/User.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

const signToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

const sendTokenResponse = (user, statusCode, res) => {
  const token = signToken(user._id);
  user.password = undefined;
  res.status(statusCode).json({
    status: 'success',
    token,
    data: { user },
  });
};

exports.register = catchAsync(async (req, res, next) => {
  const newUser = await User.create({
    name:     req.body.name,
    email:    req.body.email,
    password: req.body.password,
    role:     req.body.role,
  });
  sendTokenResponse(newUser, 201, res);
});

exports.login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  // Step 1: تحقق إن الـ fields موجودة
  if (!email || !password) {
    return next(new AppError('Please provide email and password', 400));
  }

  // Step 2: جيب الـ user مع الـ password
  const user = await User.findOne({ email }).select('+password');

  // Step 3: تحقق من الـ user والـ password
  // بنعمل الاتنين في شرط واحد عشان:
  // لو عملناهم منفصلين — ممكن نبيّن للهاكر إيه اللي غلط
  // هو مش عارف email ولا password — نخليه في الظلام
  if (!user || !(await user.correctPassword(password))) {
    return next(new AppError('Incorrect email or password', 401));
  }

  // Step 4: ابعت الـ token
  sendTokenResponse(user, 200, res);
});
```

---

## ليه بنعمل الـ Check في شرط واحد؟

```javascript
// ❌ غلط — بيكشف معلومة للهاكر
if (!user) {
  return next(new AppError('No user with this email', 401));
}
if (!(await user.correctPassword(password))) {
  return next(new AppError('Wrong password', 401));
}

// ✅ صح — نفس الرسالة في الحالتين
if (!user || !(await user.correctPassword(password))) {
  return next(new AppError('Incorrect email or password', 401));
}
```

```mermaid
flowchart TD
    subgraph wrong["❌ رسائل منفصلة — خطر"]
        W1["هاكر جرّب email عشوائي"] --> W2["رد: No user with this email"]
        W2 --> W3["هاكر عرف إن الـ email مش موجود<br/>يروح يجرب email تاني"]
        W4["هاكر جرّب email موجود"] --> W5["رد: Wrong password"]
        W5 --> W6["هاكر عرف إن الـ email صح<br/>يفضل يجرب passwords"]
    end

    subgraph correct["✅ رسالة واحدة — آمن"]
        C1["هاكر جرّب أي حاجة"] --> C2["رد: Incorrect email or password"]
        C2 --> C3["مش عارف إيه اللي غلط ✅"]
    end

    style wrong fill:#4a1212,color:#fff
    style correct fill:#1a4731,color:#fff
```

ده اسمه **User Enumeration Attack Prevention** — منع الهاكر من معرفة الـ emails الموجودة في النظام.

---

## 💻 خطوة 6 — ضيف الـ login route

افتح `src/routes/auth.routes.js`:

```javascript
const express            = require('express');
const { register, login } = require('../controllers/auth.controller');

const router = express.Router();

router.post('/register', register);
router.post('/login',    login);    // ← جديد

module.exports = router;
```

---

## الـ Token Flow الكاملة — من Login لـ Protected Route

```
    # خطوة 1 — Login
    Client ──► Server: POST /api/v1/auth/login {email, password}
    Server → تحقق من الـ credentials
    Server → jwt.sign({id: user._id}, SECRET)
    Server ──► Client: { token: "eyJhbGci..." }
    # الـ client بيحفظ الـ token
    # في localStorage أو memory
    # خطوة 2 — استخدام الـ Token
    Client ──► Server: GET /api/v1/projects Authorization: Bearer eyJhbGci...
    Server → jwt.verify(token, SECRET)
    Server → بيطلع id من الـ payload
    Server → User.findById(id)
    Server ──► Client: { projects: [...] }
```

الـ `protect` middleware اللي هيعمل الـ verify ده — هنبنيه في Sprint 7.

---

## ✅ Checkpoint

> [!example] Test 1 — Register وخد الـ token
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/auth/register` **Body:**
> 
> ```json
> { "name": "Mohamed", "email": "test@example.com", "password": "password123", "role": "client" }
> ```
> 
> **Expected:**
> 
> ```json
> {
>   "status": "success",
>   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
>   "data": { "user": { ... } }
> }
> ```

> [!example] Test 2 — Login صح
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/auth/login` **Body:**
> 
> ```json
> { "email": "test@example.com", "password": "password123" }
> ```
> 
> **Expected:** نفس الـ response — token + user بدون password

> [!example] Test 3 — Password غلط
> **Body:** `{ "email": "test@example.com", "password": "wrongpassword" }`
> 
> **Expected:**
> 
> ```json
> { "status": "fail", "message": "Incorrect email or password" }
> ```

> [!example] Test 4 — Email مش موجود
> **Body:** `{ "email": "nobody@example.com", "password": "password123" }`
> 
> **Expected:** نفس الرسالة بالظبط — `"Incorrect email or password"` السيرفر مش بيقول مين اللي غلط.

**Test 5 — افحص الـ Token:**

خد الـ token من الـ response وروح على [jwt.io](https://jwt.io/) والصقه.

هتشوف الـ Payload بتاعه:

```json
{
  "id": "64abc...",
  "iat": 1699000000,
  "exp": 1699604800
}
```

لاحظ إن الـ `id` بتاع الـ user ده موجود — ده اللي هنستخدمه في الـ protect middleware.

---

## ملخص Sprint 6

اللي اتعلمته:

- الـ HTTP **Stateless** — بينسى كل request
- الـ Sessions القديمة بتحتاج DB query في كل request
- الـ JWT بيحل المشكلة بـ math — مش DB
- الـ JWT فيه 3 أجزاء: **Header** + **Payload** + **Signature**
- الـ Payload مش مشفّر — بس موقّع — ماتحطش sensitive data فيه
- `jwt.sign(payload, secret, options)` لصنع الـ token
- الـ instance method `correctPassword` — function على الـ document نفسه
- بنتحقق من الـ user والـ password في شرط واحد — User Enumeration Prevention
- `user.password = undefined` قبل الـ response — حتى لو `select: false`

---

> **جاهز للـ Sprint 7؟**
> 
> Sprint 7 هو **protect middleware** — إزاي نحمي الـ routes. هنبني الـ middleware اللي بيتحقق من الـ JWT في كل request، وبعدين هنبني الـ `restrictTo` عشان نفرق بين الـ client والـ freelancer.
> 
> قول "كمّل" لما تشوف الـ token في الـ response وتفتحه على jwt.io بنفسك.

---

---

# 🛡️ Sprint 7 — protect + restrictTo : حراسة الـ Routes

---

## المشكلة — كل الـ Routes مفتوحة لأي حد

دلوقتي أي حد يقدر يبعت request لأي route — سواء عمل login أو لأ. لو بنينا `POST /projects` — أي حد ممكن يخلق project من غير ما يكون logged in.

محتاجين حاجتين:

**الأولى — Authentication:** تأكد إن الـ user عمل login أصلاً. ده بيتعمل بـ `protect` middleware.

**التانية — Authorization:** تأكد إن الـ user المعين مسموحله يعمل الـ action ده. الـ client يقدر يخلق project — الـ freelancer لأ. ده بيتعمل بـ `restrictTo` middleware.

```mermaid
flowchart TD
    REQ["Request جاي"] --> P{protect<br/>هل في token صح؟}
    P -->|لأ — مفيش token| E1["401 Unauthorized<br/>Please log in"]
    P -->|لأ — token باظ| E2["401 Unauthorized<br/>Invalid token"]
    P -->|آه — token صح| R{restrictTo<br/>هل الـ role مسموح؟}
    R -->|لأ — freelancer يحاول يخلق project| E3["403 Forbidden<br/>Not allowed"]
    R -->|آه — client يخلق project| C["Controller يشتغل ✅"]

    style REQ fill:#2d3748,color:#fff
    style P fill:#553c9a,color:#fff
    style R fill:#2b6cb0,color:#fff
    style E1 fill:#742a2a,color:#fff
    style E2 fill:#742a2a,color:#fff
    style E3 fill:#744210,color:#fff
    style C fill:#276749,color:#fff
```

---

## الفرق بين 401 و403

```mermaid
flowchart LR
    subgraph s401["401 Unauthorized"]
        A1["مش عارف مين أنت"]
        A2["مش عامل login"]
        A3["الـ token باظ أو منتهي"]
    end

    subgraph s403["403 Forbidden"]
        B1["عارف مين أنت"]
        B2["عامل login وصح"]
        B3["بس مش مسموحلك<br/>بالـ action ده"]
    end

    style s401 fill:#742a2a,color:#fff
    style s403 fill:#744210,color:#fff
```

تخيل عمارة:

- **401** — مش عندك كارت دخول خالص — الباب مقفول.
- **403** — عندك كارت دخول — بس الكارت ده بيفتح الدور التاني بس، مش الدور التالت.

---

## إيه اللي هيعمله الـ `protect` middleware؟

```mermaid
flowchart TD
    A["Request وصل<br/>فيه Authorization header"] --> B

    subgraph step1["Step 1: استخرج الـ Token"]
        B["هل في Authorization header؟<br/>هل بيبدأ بـ 'Bearer '؟"]
        B -->|لأ| E1["AppError 401<br/>You are not logged in"]
    end

    B -->|آه| C

    subgraph step2["Step 2: تحقق من الـ Token"]
        C["jwt.verify(token, SECRET)"]
        C -->|Token باظ| E2["AppError 401<br/>Invalid token"]
        C -->|Token منتهي| E3["AppError 401<br/>Token expired"]
    end

    C -->|Token صح| D

    subgraph step3["Step 3: جيب الـ User من الـ DB"]
        D["User.findById(decoded.id)"]
        D -->|User مش موجود| E4["AppError 401<br/>User no longer exists"]
    end

    D -->|User موجود| F

    subgraph step4["Step 4: حط الـ User على الـ Request"]
        F["req.user = currentUser<br/>next()"]
    end

    style step1 fill:#1a365d,color:#fff
    style step2 fill:#553c9a,color:#fff
    style step3 fill:#276749,color:#fff
    style step4 fill:#2b6cb0,color:#fff
    style E1 fill:#742a2a,color:#fff
    style E2 fill:#742a2a,color:#fff
    style E3 fill:#742a2a,color:#fff
    style E4 fill:#742a2a,color:#fff
```

---

## `req.user` — إيه ده وليه مهم؟

لما الـ `protect` middleware يشتغل — بيحط الـ user على `req.user`.

ده يعني كل middleware وكل controller جاي بعده هيعرف مين الـ user ده من `req.user`.

```
    protect middleware → jwt.verify(token)
    protect middleware → User.findById(decoded.id)
    protect middleware → req.user = currentUser
    protect middleware ──► Controller: next()
    Controller → يستخدم req.user._id
    Controller → يستخدم req.user.role
    Controller → يستخدم req.user.email
```

مش محتاج في كل controller تروح تجيب الـ user من الـ DB تاني — `protect` عمل ده وحطه على `req.user` جاهز.

---

## 💻 خطوة 1 — اعمل `src/middlewares/auth.middleware.js`

```javascript
const jwt        = require('jsonwebtoken');
const { promisify } = require('util'); // built-in Node.js module
const User       = require('../models/User.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// PROTECT — تأكد إن الـ User logged in
// ══════════════════════════════════════════════════════
exports.protect = catchAsync(async (req, res, next) => {

  // ── Step 1: استخرج الـ token ──────────────────────
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer ')
  ) {
    // "Bearer eyJhbGci..." → نقسم على المسافة → ["Bearer", "eyJhbGci..."]
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next(
      new AppError('You are not logged in. Please log in to get access.', 401)
    );
  }

  // ── Step 2: تحقق من الـ token ────────────────────
  // jwt.verify بتاخد callback — بنحوّلها لـ Promise بـ promisify
  // لو الـ token باظ أو منتهي — بترمي error تلقائياً
  const decoded = await promisify(jwt.verify)(token, process.env.JWT_SECRET);
  // decoded = { id: '64abc...', iat: ..., exp: ... }

  // ── Step 3: تحقق إن الـ User لسه موجود ──────────
  // ممكن الـ token صح بس الـ account اتحذف بعد ما الـ token اتعمل
  const currentUser = await User.findById(decoded.id);

  if (!currentUser) {
    return next(
      new AppError('The user belonging to this token no longer exists.', 401)
    );
  }

  // ── Step 4: حط الـ User على الـ Request ──────────
  req.user = currentUser;
  next();
});

// ══════════════════════════════════════════════════════
// RESTRICT TO — تأكد إن الـ Role مسموح
// ══════════════════════════════════════════════════════
exports.restrictTo = (...roles) => {
  // بترجع middleware function
  // بتلف على الـ roles بـ closure
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(
        new AppError('You do not have permission to perform this action.', 403)
      );
    }
    next();
  };
};
```

---

## شرح `promisify(jwt.verify)` — ليه محتاجينها؟

الـ `jwt.verify` في الأصل بتاخد callback:

```javascript
// الطريقة القديمة — callbacks
jwt.verify(token, secret, (err, decoded) => {
  if (err) { /* handle error */ }
  // use decoded
});
```

بس إحنا بنشتغل بـ `async/await`. `promisify` من الـ `util` module في Node.js بتحوّل أي callback-based function لـ Promise:

```mermaid
flowchart LR
    A["jwt.verify<br/>callback-based"] -->|promisify| B["jwt.verify<br/>Promise-based"]
    B -->|await| C["decoded payload"]
    B -->|throw| D["JsonWebTokenError<br/>أو TokenExpiredError"]

    style A fill:#4a5568,color:#fff
    style B fill:#553c9a,color:#fff
    style C fill:#276749,color:#fff
    style D fill:#742a2a,color:#fff
```

لو الـ token باظ — `jwt.verify` بيرمي error تلقائياً — `catchAsync` بيمسكها وبيبعتها للـ global error handler.

---

## شرح `restrictTo(...roles)` — الـ Closure Pattern

```javascript
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) { ... }
  };
};
```

`...roles` — rest parameter. يعني ممكن تبعت أي عدد من الـ roles:

```javascript
restrictTo('client')               // roles = ['client']
restrictTo('client', 'admin')      // roles = ['client', 'admin']
restrictTo('freelancer', 'client') // roles = ['freelancer', 'client']
```

الـ function دي **بترجع function** — ده اللي بنسميه **Closure**:

```mermaid
flowchart TD
    A["restrictTo('client')"] --> B["بترجع function جديدة<br/>جوّاها roles = ['client']"]
    B --> C["Express بيشغّل الـ function دي<br/>لما الـ request ييجي"]
    C --> D{req.user.role<br/>في الـ roles array؟}
    D -->|آه — client| E["next() ✅"]
    D -->|لأ — freelancer| F["AppError 403 ❌"]

    style A fill:#553c9a,color:#fff
    style B fill:#2b6cb0,color:#fff
    style E fill:#276749,color:#fff
    style F fill:#742a2a,color:#fff
```

**ليه بنعمل closure ومش بنبعت الـ roles كـ argument عادي؟**

لأن الـ Express middleware signature ثابت: `(req, res, next)` — مش ممكن تضيف parameter زيادة. الـ closure بتخلينا نحفظ الـ roles في الـ function نفسها.

---

## الفرق بين `JsonWebTokenError` و`TokenExpiredError`

لما `jwt.verify` يفشل — بيرمي نوعين من الـ errors:

```mermaid
flowchart TD
    subgraph jwtErrors["JWT Errors"]
        E1["JsonWebTokenError<br/>الـ token اتعدّل أو باظ<br/>مثلاً: حد غيّر الـ payload"]
        E2["TokenExpiredError<br/>الـ token صح بس انتهت صلاحيته<br/>بعد الـ JWT_EXPIRES_IN"]
    end

    style jwtErrors fill:#742a2a,color:#fff
```

دلوقتي الـ global error handler بيبعت رسالة generic لأنهم مش `AppError`. محتاجين نعملهم handle خاص.

---

## 💻 خطوة 2 — تحسين الـ Error Handler

افتح `src/middlewares/errorHandler.js` وعدّله:

```javascript
const AppError = require('../utils/AppError');

// ═══════════════════════════════════════
// Specific Error Handlers
// ═══════════════════════════════════════

const handleJWTError = () =>
  new AppError('Invalid token. Please log in again.', 401);

const handleJWTExpiredError = () =>
  new AppError('Your token has expired. Please log in again.', 401);

const handleValidationError = (err) => {
  // Mongoose بيدي object فيه كل الـ validation errors
  const errors = Object.values(err.errors).map((el) => el.message);
  const message = `Invalid input data: ${errors.join('. ')}`;
  return new AppError(message, 400);
};

const handleDuplicateKeyError = (err) => {
  // MongoDB بيحط الـ value اللي اتكرر في الـ keyValue object
  const value = Object.values(err.keyValue)[0];
  const message = `Duplicate field value: "${value}". Please use another value.`;
  return new AppError(message, 400);
};

const handleCastError = (err) => {
  // ممكن حد يبعت ID غلط — مش ObjectId صح
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400);
};

// ═══════════════════════════════════════
// Response Senders
// ═══════════════════════════════════════

const sendErrorDev = (err, res) => {
  // في الـ development — ابعت كل التفاصيل للـ debugging
  res.status(err.statusCode).json({
    status:  err.status,
    message: err.message,
    error:   err,
    stack:   err.stack,
  });
};

const sendErrorProd = (err, res) => {
  if (err.isOperational) {
    // Operational error — آمن نبعت الـ message
    res.status(err.statusCode).json({
      status:  err.status,
      message: err.message,
    });
  } else {
    // Programming error — متكشفش التفاصيل
    console.error('💥 PROGRAMMING ERROR:', err);
    res.status(500).json({
      status:  'error',
      message: 'Something went very wrong.',
    });
  }
};

// ═══════════════════════════════════════
// Global Error Handler
// ═══════════════════════════════════════
const globalErrorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status     = err.status     || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else {
    let error = { ...err, message: err.message };

    // حوّل الـ errors المعروفة لـ AppError
    if (error.name === 'CastError')       error = handleCastError(error);
    if (error.code === 11000)             error = handleDuplicateKeyError(error);
    if (error.name === 'ValidationError') error = handleValidationError(error);
    if (error.name === 'JsonWebTokenError')  error = handleJWTError();
    if (error.name === 'TokenExpiredError')  error = handleJWTExpiredError();

    sendErrorProd(error, res);
  }
};

module.exports = globalErrorHandler;
```

---

## `sendErrorDev` vs `sendErrorProd` — ليه الفرق؟

```mermaid
flowchart TD
    subgraph dev["Development — NODE_ENV=development"]
        D1["ابعت كل حاجة:<br/>message + stack + error object"]
        D2["عشان تقدر تـ debug"]
    end

    subgraph prod["Production — NODE_ENV=production"]
        P1{isOperational؟}
        P1 -->|آه — AppError| P2["ابعت message بس<br/>الـ client يستاهل يعرف"]
        P1 -->|لأ — bug| P3["ابعت 'Something went wrong'<br/>متكشفش stack trace للـ hacker"]
    end

    style dev fill:#1a365d,color:#fff
    style prod fill:#1a4731,color:#fff
    style P3 fill:#742a2a,color:#fff
```

الـ stack trace فيه معلومات عن الكود بتاعك — أسماء ملفات، أسطر. في الـ production ده معلومة للهاكر. في الـ development ده مفيد للـ debugging.

---

## 💻 خطوة 3 — جرّب الـ protect على route حقيقية

في `app.js` ضيف route جديدة للتجربة بس:

```javascript
const { protect } = require('./src/middlewares/auth.middleware');

// Test route — protected
app.get('/api/v1/me', protect, (req, res) => {
  res.json({
    status: 'success',
    data: { user: req.user },
  });
});
```

---

## ✅ Checkpoint

> [!example] Test 1 — من غير token
> **Method:** `GET` **URL:** `http://localhost:5000/api/v1/me` **Headers:** لا تضيف حاجة
> 
> **Expected:**
> 
> ```json
> { "status": "fail", "message": "You are not logged in. Please log in to get access." }
> ```

> [!example] Test 2 — بـ token صح
> اعمل login الأول وخد الـ token. **Method:** `GET` **URL:** `http://localhost:5000/api/v1/me` **Header:** `Authorization: Bearer <الـ token هنا>`
> 
> **Expected:** بيانات الـ user اللي عمل login — من غير password.

> [!example] Test 3 — بـ token باظ
> **Header:** `Authorization: Bearer thisisnotavalidtoken`
> 
> **Expected:**
> 
> ```json
> { "status": "fail", "message": "Invalid token. Please log in again." }
> ```

> [!example] Test 4 — بـ token منتهي
> في الـ `.env` غيّر `JWT_EXPIRES_IN=1s`، اعمل login، استنى ثانيتين، وبعدين بعت الـ request.
> 
> **Expected:**
> 
> ```json
> { "status": "fail", "message": "Your token has expired. Please log in again." }
> ```
> 
> رجّع `JWT_EXPIRES_IN=7d` بعدين.

**Test 5 — `restrictTo` بالتجربة:**

في `app.js` ضيف route:

```javascript
const { protect, restrictTo } = require('./src/middlewares/auth.middleware');

app.get('/api/v1/client-only', protect, restrictTo('client'), (req, res) => {
  res.json({ message: 'Welcome, client!' });
});
```

> سجّل دخول بـ user عنده `role: 'freelancer'` وبعت الـ request.
> 
> **Expected:**
> 
> ```json
> { "status": "fail", "message": "You do not have permission to perform this action." }
> ```
> 
> سجّل دخول بـ user عنده `role: 'client'` وبعت تاني.
> 
> **Expected:** `{ "message": "Welcome, client!" }`

---

## ملخص Sprint 7

اللي اتعلمته:

- **401 vs 403** — مش عارف مين أنت vs عارف بس مش مسموحلك
- الـ `protect` middleware بيعمل 4 steps: استخرج token، تحقق، جيب user، حط على req
- **`req.user`** — بيتبقى متاح في كل middleware وcontroller بعد `protect`
- **`promisify`** — بتحوّل callback functions لـ Promises
- **Closure في `restrictTo`** — بتحفظ الـ roles في الـ function الراجعة
- الـ error handler المحسّن — بيتعامل مع JWT errors وValidation وDuplicate وCast errors
- **`sendErrorDev` vs `sendErrorProd`** — stack trace في الـ dev بس مش في الـ prod

---

# 📋 Sprint 8 — Projects CRUD : أول Resource حقيقي

---

## إيه اللي هنبنيه؟

في FreelanceFlow، الـ Project هو أساس كل حاجة. الـ Client بيخلق Project وبيحدد:

- عنوان ووصف
- Budget (min وmax)
- Skills مطلوبة
- Deadline

الـ Freelancer بيشوف الـ Projects المفتوحة ويبعت proposals.

Sprint 8 هيبني الـ CRUD الكامل للـ Projects:

```mermaid
flowchart LR
    subgraph crud["Project CRUD"]
        C["POST /projects<br/>Create — client فقط"]
        R1["GET /projects<br/>Read All — أي logged-in user"]
        R2["GET /projects/:id<br/>Read One — أي logged-in user"]
        U["PATCH /projects/:id<br/>Update — client صاحب الـ project"]
        D["DELETE /projects/:id<br/>Delete — client صاحب الـ project<br/>Soft Delete"]
    end

    style C fill:#276749,color:#fff
    style R1 fill:#2b6cb0,color:#fff
    style R2 fill:#2b6cb0,color:#fff
    style U fill:#744210,color:#fff
    style D fill:#742a2a,color:#fff
```

---

## الـ Soft Delete — إيه ده؟

لما بنـ "Delete" project — مش هنمسحه من الـ DB فعلاً. هنغير الـ `status` بتاعه لـ `cancelled`.

**ليه Soft Delete؟**

```mermaid
flowchart TD
    subgraph hard["Hard Delete — المسح الحقيقي"]
        H1["db.projects.deleteOne(id)"]
        H1 --> H2["Project راح نهائياً"]
        H2 --> H3["لو الـ freelancer عنده proposal<br/>على الـ project ده — orphan data"]
        H3 --> H4["لو محتاجت تـ audit<br/>مش هتلاقي حاجة"]
    end

    subgraph soft["Soft Delete — تغيير الـ status"]
        S1["project.status = 'cancelled'<br/>project.save()"]
        S1 --> S2["Project لسه موجود في الـ DB"]
        S2 --> S3["بس مش بيظهر في الـ results العادية"]
        S3 --> S4["الـ proposals والـ relations سليمة ✅"]
        S4 --> S5["ممكن تـ restore لو محتاج ✅"]
    end

    style hard fill:#4a1212,color:#fff
    style soft fill:#1a4731,color:#fff
```

---

## الـ Project Lifecycle — State Machine

الـ Project مش بيبقى في حالة واحدة طول عمره. بيمر بـ states:

```mermaid
stateDiagram-v2
    [*] --> open : Client خلق Project
    open --> in_progress : Client قبل Proposal
    open --> cancelled : Client حذف Project
    in_progress --> completed : Client أكد الإتمام
    in_progress --> cancelled : في حالات خاصة
    cancelled --> [*]
    completed --> [*]
```

الـ transitions دي بتتحكم فيها الـ business logic — مش أي حد يقدر يغير الـ status لأي حاجة.

---

#### ليه `client: req.user._id` مش `client: req.body.client`؟

ده concept مهم جداً في الـ security.

تخيل السيناريو ده:

```json
POST /api/v1/projects
{
  "title": "Build a website",
  "client": "64abc999"
}
```

لو صدقنا الـ `client` من الـ `req.body` — ممكن حد يخلق project باسم حد تاني.

```mermaid
flowchart TD
    subgraph wrong["❌ الثقة في req.body"]
        W1["Hacker بعت:<br/>client: '64abc999' — ID حد تاني"]
        W1 --> W2["Server حفظ Project<br/>bا client: '64abc999'"]
        W2 --> W3["Project اتحط على حساب حد تاني 🔴"]
    end

    subgraph correct["✅ نأخذ من req.user"]
        C1["Hacker بعت:<br/>client: '64abc999'"]
        C1 --> C2["Server تجاهل الـ client من الـ body<br/>استخدم req.user._id"]
        C2 --> C3["Project اتحط على الـ logged-in user ✅"]
    end

    style wrong fill:#4a1212,color:#fff
    style correct fill:#1a4731,color:#fff
```

**القاعدة:** أي data تثبت هوية الـ user — لازم تيجي من `req.user` اللي الـ `protect` middleware بيحطه، مش من الـ `req.body` اللي الـ client بيبعته.

---

## 💻 خطوة 1 — اعمل `src/models/Project.model.js`

```javascript
const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema(
  {
    title: {
      type:      String,
      required:  [true, 'A project must have a title'],
      trim:      true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },

    description: {
      type:      String,
      required:  [true, 'A project must have a description'],
      minlength: [20, 'Description must be at least 20 characters'],
    },

    // Nested object — budget فيه min وmax
    budget: {
      min: {
        type:     Number,
        required: [true, 'Please provide a minimum budget'],
      },
      max: {
        type:     Number,
        required: [true, 'Please provide a maximum budget'],
      },
    },

    // Array of strings
    skillsRequired: {
      type:     [String],
      validate: {
        validator: (val) => val.length > 0,
        message:   'A project must require at least one skill',
      },
    },

    deadline: {
      type:     Date,
      required: [true, 'A project must have a deadline'],
      validate: {
        // 'this' هنا = الـ document — function عادية مش arrow
        validator: function (val) {
          return val > Date.now();
        },
        message: 'Deadline must be in the future',
      },
    },

    status: {
      type:    String,
      enum:    ['open', 'in_progress', 'completed', 'cancelled'],
      default: 'open',
    },

    // Reference للـ User Model
    client: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: [true, 'A project must have a client'],
    },

    // هيتملى لما proposal يتقبل — Sprint 9
    acceptedFreelancer: {
      type:    mongoose.Schema.Types.ObjectId,
      ref:     'User',
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON:     { virtuals: true },
    toObject:   { virtuals: true },
  }
);

// ══════════════════════════════════════════════════════
// Cross-field Validation — budget.max > budget.min
// ══════════════════════════════════════════════════════
projectSchema.pre('save', function (next) {
  if (this.budget.max <= this.budget.min) {
    return next(
      new Error('Maximum budget must be greater than minimum budget')
    );
  }
  next();
});

// ══════════════════════════════════════════════════════
// Index — بيسرّع الـ queries الشائعة
// ══════════════════════════════════════════════════════
projectSchema.index({ status: 1 });
projectSchema.index({ client: 1 });

const Project = mongoose.model('Project', projectSchema);
module.exports = Project;
```

---

## شرح `mongoose.Schema.Types.ObjectId` والـ `ref`

```javascript
client: {
  type: mongoose.Schema.Types.ObjectId,
  ref:  'User',
}
```

**`mongoose.Schema.Types.ObjectId`** — نوع خاص في MongoDB. كل document بيتخلق تلقائياً بـ `_id` من النوع ده. شبه الـ `INT AUTO_INCREMENT` في SQL — بس بدل رقم تسلسلي، ده hex string من 24 حرف.

**`ref: 'User'`** — بيقول لـ Mongoose: "الـ ObjectId ده بيشاور على document في الـ User collection."

ده اللي بيعمله الـ `.populate()` ممكن بعدين — بيستبدل الـ ID بالـ document الكامل.

```mermaid
flowchart LR
    subgraph before["قبل populate"]
        P1["Project Document:<br/>{<br/>  title: 'Build App',<br/>  client: '64abc123'<br/>}"]
    end

    subgraph after["بعد .populate('client')"]
        P2["Project Document:<br/>{<br/>  title: 'Build App',<br/>  client: {<br/>    _id: '64abc123',<br/>    name: 'Mohamed',<br/>    email: 'mo@test.com'<br/>  }<br/>}"]
    end

    before -->|.populate| after

    style before fill:#4a5568,color:#fff
    style after fill:#276749,color:#fff
```

---

## إيه الـ Index وليه مهم؟

```javascript
projectSchema.index({ status: 1 });
```

تخيل كتاب بدون فهرس — لو عايز تلاقي كلمة، لازم تقرأ من الصفحة الأولى لآخر صفحة.

الـ Index زي الفهرس — بيعمل data structure منفصلة بتسمح لـ MongoDB يلاقي الـ documents بسرعة من غير ما يقرأ الـ collection كلها.

```mermaid
flowchart TD
    subgraph no_index["بدون Index"]
        Q1["Project.find({ status: 'open' })"]
        Q1 --> S1["MongoDB بيقرأ كل document<br/>1, 2, 3 ... 10000"]
        S1 --> R1["بيرجع اللي عنده status = open<br/>بطيء جداً مع بيانات كبيرة"]
    end

    subgraph with_index["مع Index"]
        Q2["Project.find({ status: 'open' })"]
        Q2 --> S2["MongoDB بيروح للـ Index<br/>مباشرة للـ open projects"]
        S2 --> R2["سريع جداً ✅"]
    end

    style no_index fill:#4a1212,color:#fff
    style with_index fill:#1a4731,color:#fff
```

`{ status: 1 }` — الـ `1` يعني ascending order. `-1` يعني descending.

---

## 💻 خطوة 2 — اعمل `src/controllers/project.controller.js`

```javascript
const Project    = require('../models/Project.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// CREATE PROJECT
// POST /api/v1/projects
// ══════════════════════════════════════════════════════
exports.createProject = catchAsync(async (req, res, next) => {
  // بنأخذ الـ client من req.user مش من req.body
  const project = await Project.create({
    title:          req.body.title,
    description:    req.body.description,
    budget:         req.body.budget,
    skillsRequired: req.body.skillsRequired,
    deadline:       req.body.deadline,
    client:         req.user._id,  // ← من الـ protect middleware
  });

  res.status(201).json({
    status: 'success',
    data:   { project },
  });
});

// ══════════════════════════════════════════════════════
// GET ALL PROJECTS
// GET /api/v1/projects
// ══════════════════════════════════════════════════════
exports.getAllProjects = catchAsync(async (req, res, next) => {
  // بنجيب بس الـ projects المفتوحة
  const projects = await Project.find({ status: 'open' })
    .populate('client', 'name email') // بدل ID — نجيب name وemail بس
    .sort('-createdAt');              // الأحدث أول

  res.status(200).json({
    status:  'success',
    results: projects.length,
    data:    { projects },
  });
});

// ══════════════════════════════════════════════════════
// GET ONE PROJECT
// GET /api/v1/projects/:id
// ══════════════════════════════════════════════════════
exports.getProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id)
    .populate('client', 'name email');

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  res.status(200).json({
    status: 'success',
    data:   { project },
  });
});

// ══════════════════════════════════════════════════════
// UPDATE PROJECT
// PATCH /api/v1/projects/:id
// ══════════════════════════════════════════════════════
exports.updateProject = catchAsync(async (req, res, next) => {
  // Step 1: جيب الـ project الأول
  const project = await Project.findById(req.params.id);

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  // Step 2: تأكد إن الـ user ده هو صاحب الـ project
  // .toString() عشان ObjectId مش string عادي
  if (project.client.toString() !== req.user._id.toString()) {
    return next(
      new AppError('You are not authorized to update this project', 403)
    );
  }

  // Step 3: منع الـ user من تغيير الـ status أو الـ client مباشرة
  const { status, client, acceptedFreelancer, ...allowedUpdates } = req.body;

  // Step 4: عمل الـ update
  const updatedProject = await Project.findByIdAndUpdate(
    req.params.id,
    allowedUpdates,
    {
      new:            true,  // ارجع الـ document بعد الـ update مش قبله
      runValidators:  true,  // شغّل الـ schema validators على الـ update
    }
  );

  res.status(200).json({
    status: 'success',
    data:   { project: updatedProject },
  });
});

// ══════════════════════════════════════════════════════
// DELETE PROJECT (SOFT DELETE)
// DELETE /api/v1/projects/:id
// ══════════════════════════════════════════════════════
exports.deleteProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id);

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  // تأكد إن الـ user هو صاحب الـ project
  if (project.client.toString() !== req.user._id.toString()) {
    return next(
      new AppError('You are not authorized to delete this project', 403)
    );
  }

  // منع حذف project لو فيه freelancer شغّال عليه
  if (project.status === 'in_progress') {
    return next(
      new AppError('Cannot cancel a project that is already in progress', 400)
    );
  }

  // Soft Delete — غيّر الـ status بدل ما تمسح
  project.status = 'cancelled';
  await project.save();

  // 204 No Content — نجح بس مفيش حاجة ترجعها
  res.status(204).json({
    status: 'success',
    data:   null,
  });
});
```

---

## شرح `findByIdAndUpdate` vs `.save()` — فرق مهم

```mermaid
flowchart TD
    subgraph save["doc.save()"]
        S1["بيشغّل pre-save hooks ✅"]
        S2["بيشغّل post-save hooks ✅"]
        S3["بيعمل validation ✅"]
        S4["أبطأ شوية<br/>لأنه بيجيب الـ doc الأول"]
    end

    subgraph findUpdate["findByIdAndUpdate()"]
        F1["مش بيشغّل pre-save hooks ❌"]
        F2["مش بيشغّل post-save hooks ❌"]
        F3["بيعمل validation بس لو قلتله<br/>runValidators: true"]
        F4["أسرع<br/>DB operation واحدة"]
    end

    style save fill:#1a4731,color:#fff
    style findUpdate fill:#1a365d,color:#fff
```

**متى نستخدم إيه؟**

`project.save()` — لما محتاجين الـ hooks تشتغل. مثلاً في الـ Soft Delete — لو ضفنا hook على الـ `save` بعدين.

`findByIdAndUpdate()` — لما بنعمل update بسيط ومش محتاجين hooks. أسرع وأنظف.

في الـ `updateProject` استخدمنا `findByIdAndUpdate` — مش محتاجين hooks هنا. في الـ `deleteProject` استخدمنا `project.save()` — عشان ممكن نضيف hooks بعدين.

---

## شرح `{ status, client, acceptedFreelancer, ...allowedUpdates }`

```javascript
const { status, client, acceptedFreelancer, ...allowedUpdates } = req.body;
```

ده **Object Destructuring** مع **Rest operator**.

بنقول: "خد `status` و`client` و`acceptedFreelancer` وحطهم في variables — والباقي حطه في `allowedUpdates`."

بعدين بنعمل update بـ `allowedUpdates` بس — من غير الـ fields الحساسة.

```mermaid
flowchart TD
    A["req.body = {<br/>  title: 'New Title',<br/>  budget: { min: 100, max: 500 },<br/>  status: 'completed',<br/>  client: '64hacker'<br/>}"] --> B["Destructuring"]

    B --> C["status = 'completed' ← بنتجاهله"]
    B --> D["client = '64hacker' ← بنتجاهله"]
    B --> E["allowedUpdates = {<br/>  title: 'New Title',<br/>  budget: { min: 100, max: 500 }<br/>}"]

    E --> F["findByIdAndUpdate(id, allowedUpdates)"]

    style C fill:#742a2a,color:#fff
    style D fill:#742a2a,color:#fff
    style E fill:#276749,color:#fff
```

---

## شرح `.populate('client', 'name email')`

```javascript
const project = await Project.findById(id).populate('client', 'name email');
```

الـ `client` في الـ DB بيتحفظ كـ ObjectId بس.

`.populate('client', 'name email')` بيقول:

- "روح في الـ User collection"
- "جيب الـ document اللي `_id` بتاعه = الـ `client` field ده"
- "بس جيب `name` و`email` بس — مش كل الـ fields"

```
    Controller ──► Mongoose: Project.findById(id).populate('client', 'name email')
    Mongoose ──► MongoDB: Query 1: db.projects.findOne({_id: id})
    MongoDB ──► Mongoose: { title: '...', client: ObjectId('64abc') }
    Mongoose ──► MongoDB: Query 2: db.users.findOne({_id: '64abc'}, {name:1, email:1})
    MongoDB ──► Mongoose: { name: 'Mohamed', email: 'mo@test.com' }
    Mongoose → Replace ObjectId with user document
    Mongoose ──► Controller: { title: '...', client: { name: 'Mohamed', email: '...' } }
```

**ملاحظة:** `.populate()` بتعمل query تانية على الـ DB. مش مجاني. استخدمه لما محتاجه فعلاً.

---

## 💻 خطوة 3 — اعمل `src/routes/project.routes.js`

```javascript
const express = require('express');
const {
  createProject,
  getAllProjects,
  getProject,
  updateProject,
  deleteProject,
} = require('../controllers/project.controller');

const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();

// كل الـ routes دي محتاجة login
router.use(protect);

router
  .route('/')
  .get(getAllProjects)
  .post(restrictTo('client'), createProject); // بس الـ client

router
  .route('/:id')
  .get(getProject)
  .patch(restrictTo('client'), updateProject) // بس الـ client
  .delete(restrictTo('client'), deleteProject); // بس الـ client

module.exports = router;
```

---

## شرح `router.use(protect)` — طريقة ذكية

```javascript
// ❌ الطريقة الطويلة — بتكرر protect في كل route
router.get('/', protect, getAllProjects);
router.post('/', protect, restrictTo('client'), createProject);
router.get('/:id', protect, getProject);
// ...

// ✅ الطريقة الذكية — protect مرة واحدة لكل routes تحته
router.use(protect);
router.get('/', getAllProjects);
router.post('/', restrictTo('client'), createProject);
```

`router.use(protect)` بيقول: "كل route جاي بعد السطر ده — شغّل `protect` عليه الأول."

---

## شرح `.route('/')` — الـ Method Chaining

```javascript
router
  .route('/')
  .get(getAllProjects)
  .post(restrictTo('client'), createProject);
```

بدل ما تكتب:

```javascript
router.get('/', getAllProjects);
router.post('/', restrictTo('client'), createProject);
```

الـ `.route('/')` بيقول "على الـ path ده" — وبعدين بتحدد كل HTTP method على حده.

أنظف وأوضح لما عندك نفس الـ path بأكتر من method.

---

## 💻 خطوة 4 — اربط الـ Routes في `app.js`

افتح `app.js` وضيف:

```javascript
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const authRoutes    = require('./src/routes/auth.routes');
const projectRoutes = require('./src/routes/project.routes'); // ← جديد

const app = express();

app.use(express.json());

app.use('/api/v1/auth',     authRoutes);
app.use('/api/v1/projects', projectRoutes); // ← جديد

app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

app.use(globalErrorHandler);

module.exports = app;
```

---

## الـ Full Request Flow للـ Project Create

```
    Client (Postman) ──► app.js: POST /api/v1/projects Authorization: Bearer token Body: { title, budget, ... }
    app.js ──► protect middleware: protect middleware
    protect middleware → jwt.verify(token)
    protect middleware ──► MongoDB: User.findById(decoded.id)
    MongoDB ──► protect middleware: currentUser
    protect middleware → req.user = currentUser
    protect middleware ──► project.routes.js: next()
    project.routes.js → restrictTo('client') req.user.role === 'client'? ✅
    project.routes.js ──► project.controller.js: createProject
    project.controller.js → { ...req.body, client: req.user._id }
    project.controller.js ──► Project.model.js: Project.create(data)
    Project.model.js → pre-save hook validate budget.max > budget.min
    Project.model.js ──► MongoDB: INSERT project
    MongoDB ──► Project.model.js: project saved
    Project.model.js ──► project.controller.js: return project
    project.controller.js ──► Client (Postman): 201 { project }
```

---

## ✅ Checkpoint

أول حاجة — اعمل users للتجربة:

```json
// User 1 — client
{ "name": "Ali Client", "email": "client@test.com", "password": "password123", "role": "client" }

// User 2 — freelancer
{ "name": "Sara Freelancer", "email": "freelancer@test.com", "password": "password123", "role": "freelancer" }
```

> [!example] Test 1 — Create Project كـ client
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/projects` **Header:** `Authorization: Bearer <client token>` **Body:**
> 
> ```json
> {
>   "title": "Build a React Dashboard",
>   "description": "Need an experienced developer to build a modern React dashboard with charts and real-time data.",
>   "budget": { "min": 500, "max": 2000 },
>   "skillsRequired": ["React", "Node.js", "MongoDB"],
>   "deadline": "2025-12-31"
> }
> ```
> 
> **Expected:** `201` + project object بـ `client: "64abc..."` (الـ ID بتاعك)

> [!example] Test 2 — Create Project كـ freelancer
> نفس الـ request بس بـ freelancer token
> 
> **Expected:** `403 Forbidden`

> [!example] Test 3 — Create Project من غير token
> من غير Authorization header
> 
> **Expected:** `401 Unauthorized`

> [!example] Test 4 — Get All Projects
> **Method:** `GET` **URL:** `http://localhost:5000/api/v1/projects` **Header:** `Authorization: Bearer <أي token>`
> 
> **Expected:** قائمة بالـ projects — client field فيه `name` و`email` مش ID بس

> [!example] Test 5 — Budget Validation
> **Body:** نفس الـ request بس `budget: { "min": 2000, "max": 500 }`
> 
> **Expected:** `400` — "Maximum budget must be greater than minimum budget"

> [!example] Test 6 — Update Project
> **Method:** `PATCH` **URL:** `http://localhost:5000/api/v1/projects/<project_id>` **Header:** `Authorization: Bearer <client token>` **Body:** `{ "title": "Updated Title" }`
> 
> **Expected:** `200` + project بالـ title الجديد

> [!example] Test 7 — Update Project بـ user تاني
> نفس الـ request بس بـ freelancer token (أو client تاني)
> 
> **Expected:** `403 Forbidden`

> [!example] Test 8 — Delete Project (Soft Delete)
> **Method:** `DELETE` **URL:** `http://localhost:5000/api/v1/projects/<project_id>` **Header:** `Authorization: Bearer <client token>`
> 
> **Expected:** `204 No Content`

> بعدين جرّب `GET /api/v1/projects` تاني — المفروض الـ project مش بيظهر لأن status بتاعه `cancelled`. بس لو فتحت MongoDB Compass — هتلاقيه لسه موجود في الـ DB.

---

## ملخص Sprint 8

اللي اتعلمته:

- **Soft Delete** — بنغيير الـ status مش بنمسح — للمحافظة على البيانات والـ relations
- **State Machine** — الـ project بيمر بـ states محددة، مش أي status أي وقت
- **`client: req.user._id`** مش `client: req.body.client` — الـ security principle
- **`mongoose.Schema.Types.ObjectId` + `ref`** — الـ foreign key في MongoDB
- **`.populate()`** — بيستبدل الـ ObjectId بالـ document الكامل (query تانية)
- **Indexes** — بيسرّعوا الـ queries الشائعة
- **`findByIdAndUpdate` vs `.save()`** — الأول أسرع والتاني بيشغّل الـ hooks
- **`router.use(protect)`** — بدل تكرار الـ middleware في كل route
- **`.route('/').get().post()`** — method chaining للـ routes

---

> **جاهز للـ Sprint 9؟**
> 
> Sprint 9 هو **Proposals + الـ Cascade Hook** — أعقد وأهم جزء في المشروع. هنبني نظام الـ proposals وهنشرح الـ `post('save')` hook اللي بيعمل cascade تلقائياً: لما proposal يتقبل — كل الـ proposals التانية على نفس الـ project بتترفض تلقائياً والـ project status بيتغير. ده من أكتر الـ concepts اللي بيتسأل عنها في الـ interviews.
> 
> قول "كمّل" لما تجرب الـ 8 tests وتشوف الـ soft delete بنفسك في الـ DB.

---

---

# 🔗 Sprint 9 — Proposals + الـ Cascade Hook : أهم Concept في المشروع

---

## إيه اللي هنبنيه؟

الـ Proposal هو "عرض" الـ Freelancer على الـ Project. بيقول:

- "أنا قادر أعمل ده"
- "مقابل كذا فلوس"
- "وده الـ cover letter بتاعي"

```mermaid
flowchart LR
    subgraph flow["Proposal Lifecycle"]
        C["Client ينشر Project<br/>status: open"]
        F1["Freelancer 1 يبعت Proposal<br/>status: pending"]
        F2["Freelancer 2 يبعت Proposal<br/>status: pending"]
        F3["Freelancer 3 يبعت Proposal<br/>status: pending"]
        C --> F1
        C --> F2
        C --> F3
        ACC["Client يقبل Proposal 2"]
        F1 --> ACC
        F2 --> ACC
        F3 --> ACC
        R1["Proposal 1 → rejected<br/>تلقائياً 🤖"]
        R3["Proposal 3 → rejected<br/>تلقائياً 🤖"]
        PROJ["Project → in_progress<br/>تلقائياً 🤖"]
        ACC --> R1
        ACC --> R3
        ACC --> PROJ
    end

    style C fill:#2b6cb0,color:#fff
    style F1 fill:#553c9a,color:#fff
    style F2 fill:#276749,color:#fff
    style F3 fill:#553c9a,color:#fff
    style ACC fill:#276749,color:#fff
    style R1 fill:#742a2a,color:#fff
    style R3 fill:#742a2a,color:#fff
    style PROJ fill:#744210,color:#fff
```

الجزء المهم هو الـ "تلقائياً 🤖" — ده اللي بيعمله الـ `post('save')` Hook.

---

## ليه الـ Cascade Logic مش في الـ Controller؟

ممكن تفكر: "ليه ما بكتبش في الـ controller إنه يعمل update على باقي الـ proposals والـ project؟"

```javascript
// ❌ لو حطيناه في الـ Controller
exports.acceptProposal = catchAsync(async (req, res, next) => {
  proposal.status = 'accepted';
  await proposal.save();

  // وبعدين نكتب الـ cascade يدوياً
  await Proposal.updateMany({ project: proposal.project, _id: { $ne: proposal._id } }, { status: 'rejected' });
  await Project.findByIdAndUpdate(proposal.project, { status: 'in_progress' });

  res.json({ ... });
});
```

المشكلة:

```mermaid
flowchart TD
    subgraph problem["المشكلة مع Controller Cascade"]
        P1["acceptProposal controller<br/>بيعمل cascade ✅"]
        P2["Admin script<br/>يقبل proposal مباشرة ❌<br/>مش بيعمل cascade"]
        P3["Background job<br/>يقبل proposal ❌<br/>مش بيعمل cascade"]
        P4["Test code<br/>❌<br/>مش بيعمل cascade"]
    end

    subgraph solution["الحل — Hook في الـ Model"]
        H["post-save Hook<br/>على الـ Proposal Model"]
        H --> A1["أي كود يعمل proposal.save()"]
        H --> A2["من أي مكان"]
        H --> A3["الـ cascade بيحصل تلقائياً 🤖"]
    end

    style problem fill:#4a1212,color:#fff
    style solution fill:#1a4731,color:#fff
```

الـ Hook في الـ Model بيضمن إن الـ business rule دي بتشتغل في أي scenario — مش بس لما الـ API route بتشتغل.

---

## الـ `post('save')` Hook — إزاي بيشتغل؟

```
    Controller ──► Proposal Model: proposal.status = 'accepted'
    Controller ──► Proposal Model: proposal.save()
    Proposal Model → Validation ✅
    Proposal Model → pre-save hooks (لو في)
    Proposal Model ──► Proposal Collection: INSERT/UPDATE to DB
    Proposal Collection ──► Proposal Model: Saved ✅
    Proposal Model ──► post-save Hook: شغّل post-save hook
    post-save Hook → doc.status === 'accepted'? ✅
    post-save Hook ──► Proposal Collection: updateMany — reject all others
    Proposal Collection ──► post-save Hook: Done ✅
    post-save Hook ──► Project Collection: findByIdAndUpdate — status: in_progress
    Project Collection ──► post-save Hook: Done ✅
    post-save Hook ──► Proposal Model: Hook finished
    Proposal Model ──► Controller: return proposal
    Controller → res.json(proposal)
```

الـ Controller مش شايف أي حاجة من الـ cascade — بس بيعمل `proposal.save()` والباقي بيحصل تلقائياً.

---

## 💻 خطوة 1 — اعمل `src/models/Proposal.model.js`

```javascript
const mongoose = require('mongoose');

const proposalSchema = new mongoose.Schema(
  {
    project: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'Project',
      required: [true, 'Proposal must belong to a project'],
    },

    freelancer: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: [true, 'Proposal must belong to a freelancer'],
    },

    coverLetter: {
      type:      String,
      required:  [true, 'Please provide a cover letter'],
      minlength: [50, 'Cover letter must be at least 50 characters'],
    },

    bidAmount: {
      type:     Number,
      required: [true, 'Please provide your bid amount'],
      min:      [1,    'Bid amount must be positive'],
    },

    status: {
      type:    String,
      enum:    ['pending', 'accepted', 'rejected'],
      default: 'pending',
    },
  },
  { timestamps: true }
);

// ══════════════════════════════════════════════════════
// COMPOUND INDEX
// Freelancer واحد يقدر يبعت proposal واحد بس لكل project
// ══════════════════════════════════════════════════════
proposalSchema.index(
  { project: 1, freelancer: 1 },
  { unique: true }
);

// ══════════════════════════════════════════════════════
// THE CASCADE HOOK
// بيشتغل بعد ما الـ proposal يتحفظ
// ══════════════════════════════════════════════════════
proposalSchema.post('save', async function (doc) {

  // بنفحص status الـ doc اللي اتحفظ
  // لو مش accepted — مش محتاجين نعمل حاجة
  if (doc.status !== 'accepted') return;

  // الـ Cascade Step 1:
  // ارفض كل الـ proposals التانية على نفس الـ project
  await mongoose.model('Proposal').updateMany(
    {
      project:  doc.project,           // نفس الـ project
      _id:      { $ne: doc._id },      // ليس هذا الـ proposal ($ne = not equal)
      status:   'pending',             // بس اللي لسه pending
    },
    { status: 'rejected' }
  );

  // الـ Cascade Step 2:
  // غيّر الـ project status وسجّل الـ freelancer المقبول
  await mongoose.model('Project').findByIdAndUpdate(
    doc.project,
    {
      status:              'in_progress',
      acceptedFreelancer:  doc.freelancer,
    }
  );
});

const Proposal = mongoose.model('Proposal', proposalSchema);
module.exports = Proposal;
```

---

## شرح الـ Compound Index

```javascript
proposalSchema.index(
  { project: 1, freelancer: 1 },
  { unique: true }
);
```

ده مش index على field واحد — ده index على **combination** من اتنين fields.

```mermaid
flowchart TD
    subgraph allowed["مسموح ✅"]
        A1["Freelancer A + Project 1 ← أول proposal"]
        A2["Freelancer A + Project 2 ← project مختلف ✅"]
        A3["Freelancer B + Project 1 ← freelancer مختلف ✅"]
    end

    subgraph blocked["ممنوع ❌"]
        B1["Freelancer A + Project 1 ← تاني مرة"]
        B1 --> B2["MongoDB: Duplicate Key Error code 11000"]
    end

    style allowed fill:#1a4731,color:#fff
    style blocked fill:#4a1212,color:#fff
```

نفس الـ Freelancer يقدر يبعت proposals على projects مختلفة — بس مش ينفع يبعت اتنين على نفس الـ project.

---

## `mongoose.model('Proposal')` vs `require('../models/Proposal.model')`

```javascript
// جوا الـ Hook بنستخدم:
await mongoose.model('Proposal').updateMany(...)
await mongoose.model('Project').findByIdAndUpdate(...)

// مش:
const Proposal = require('../models/Proposal.model');
const Project  = require('../models/Project.model');
```

**ليه؟**

لو عملنا `require` في الملف — هيحصل **Circular Dependency**:

```mermaid
flowchart LR
    subgraph circular["Circular Dependency — مشكلة"]
        PM["Proposal.model.js<br/>require Project.model"]
        PJ["Project.model.js"]
        PM --> PJ
        PJ -.->|لو Project يحتاج Proposal| PM
    end

    subgraph solution["الحل — Mongoose Registry"]
        MG["mongoose.model('Project')<br/>بيجيب من الـ Mongoose registry"]
        MG --> PJ2["Project Model<br/>مسجّل مسبقاً"]
    end

    style circular fill:#4a1212,color:#fff
    style solution fill:#1a4731,color:#fff
```

Mongoose بيحتفظ بـ registry داخلي لكل الـ Models. `mongoose.model('Name')` بيجيب الـ Model من الـ registry ده من غير ما يعمل require.

---

## 💻 خطوة 2 — اعمل `src/controllers/proposal.controller.js`

```javascript
const Proposal   = require('../models/Proposal.model');
const Project    = require('../models/Project.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// SUBMIT PROPOSAL
// POST /api/v1/projects/:projectId/proposals
// ══════════════════════════════════════════════════════
exports.submitProposal = catchAsync(async (req, res, next) => {

  // Step 1: جيب الـ project وتحقق إنه موجود ومفتوح
  const project = await Project.findById(req.params.projectId);

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  if (project.status !== 'open') {
    return next(new AppError('This project is no longer accepting proposals', 400));
  }

  // Step 2: تحقق إن الـ freelancer ده ما بعتش proposal قبل كده
  // الـ compound index هيمسك ده كمان — بس نعمل check صريح لرسالة أحسن
  const existingProposal = await Proposal.findOne({
    project:    req.params.projectId,
    freelancer: req.user._id,
  });

  if (existingProposal) {
    return next(
      new AppError('You have already submitted a proposal for this project', 400)
    );
  }

  // Step 3: اخلق الـ proposal
  const proposal = await Proposal.create({
    project:     req.params.projectId,
    freelancer:  req.user._id,       // ← من req.user مش req.body
    coverLetter: req.body.coverLetter,
    bidAmount:   req.body.bidAmount,
  });

  res.status(201).json({
    status: 'success',
    data:   { proposal },
  });
});

// ══════════════════════════════════════════════════════
// GET ALL PROPOSALS FOR A PROJECT
// GET /api/v1/projects/:projectId/proposals
// بس الـ client صاحب الـ project يقدر يشوف
// ══════════════════════════════════════════════════════
exports.getProjectProposals = catchAsync(async (req, res, next) => {

  const project = await Project.findById(req.params.projectId);

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  // تحقق إن الـ user ده هو صاحب الـ project
  if (project.client.toString() !== req.user._id.toString()) {
    return next(
      new AppError('You are not authorized to view these proposals', 403)
    );
  }

  const proposals = await Proposal.find({ project: req.params.projectId })
    .populate('freelancer', 'name email')
    .sort('-createdAt');

  res.status(200).json({
    status:  'success',
    results: proposals.length,
    data:    { proposals },
  });
});

// ══════════════════════════════════════════════════════
// ACCEPT PROPOSAL
// PATCH /api/v1/proposals/:id/accept
// ══════════════════════════════════════════════════════
exports.acceptProposal = catchAsync(async (req, res, next) => {

  // جيب الـ proposal مع الـ project الخاص بيه (populate)
  const proposal = await Proposal.findById(req.params.id)
    .populate('project');

  if (!proposal) {
    return next(new AppError('No proposal found with that ID', 404));
  }

  // تحقق إن الـ user ده هو صاحب الـ project
  if (proposal.project.client.toString() !== req.user._id.toString()) {
    return next(
      new AppError('You are not authorized to accept this proposal', 403)
    );
  }

  // تحقق إن الـ project لسه open
  if (proposal.project.status !== 'open') {
    return next(
      new AppError('This project already has an accepted proposal', 400)
    );
  }

  // غيّر الـ status — الـ CASCADE HOOK هيشتغل تلقائياً بعد الـ save
  proposal.status = 'accepted';
  await proposal.save(); // ← هنا الـ hook بيشتغل

  res.status(200).json({
    status: 'success',
    data:   { proposal },
  });
});
```

---

## شرح `.populate('project')` في `acceptProposal`

```javascript
const proposal = await Proposal.findById(req.params.id).populate('project');
```

محتاجين نعمل populate لأننا عايزين نوصل لـ `proposal.project.client` — يعني الـ client بتاع الـ project.

من غير populate:

```javascript
proposal.project          // = ObjectId('64abc...')
proposal.project.client   // = undefined ❌
```

مع populate:

```javascript
proposal.project          // = { _id, title, client: ObjectId, status, ... }
proposal.project.client   // = ObjectId('64xyz...') ✅
```

---

## 💻 خطوة 3 — اعمل `src/routes/proposal.routes.js`

```javascript
const express = require('express');
const {
  acceptProposal,
} = require('../controllers/proposal.controller');
const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();

router.use(protect);

// PATCH /api/v1/proposals/:id/accept
router.patch('/:id/accept', restrictTo('client'), acceptProposal);

module.exports = router;
```

---

## 💻 خطوة 4 — ضيف الـ Nested Routes في `project.routes.js`

الـ proposals مرتبطة بـ project — منطقياً المفروض الـ URL يكون:

`/api/v1/projects/:projectId/proposals`

```javascript
const express = require('express');
const {
  createProject,
  getAllProjects,
  getProject,
  updateProject,
  deleteProject,
} = require('../controllers/project.controller');

const {
  submitProposal,
  getProjectProposals,
} = require('../controllers/proposal.controller');

const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();

router.use(protect);

router
  .route('/')
  .get(getAllProjects)
  .post(restrictTo('client'), createProject);

router
  .route('/:id')
  .get(getProject)
  .patch(restrictTo('client'), updateProject)
  .delete(restrictTo('client'), deleteProject);

// Nested routes — proposals تحت project
router
  .route('/:projectId/proposals')
  .get(restrictTo('client'),     getProjectProposals)
  .post(restrictTo('freelancer'), submitProposal);

module.exports = router;
```

---

## 💻 خطوة 5 — ربط الـ Routes في `app.js`

```javascript
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const authRoutes     = require('./src/routes/auth.routes');
const projectRoutes  = require('./src/routes/project.routes');
const proposalRoutes = require('./src/routes/proposal.routes'); // ← جديد

const app = express();

app.use(express.json());

app.use('/api/v1/auth',      authRoutes);
app.use('/api/v1/projects',  projectRoutes);
app.use('/api/v1/proposals', proposalRoutes); // ← جديد

app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

app.use(globalErrorHandler);

module.exports = app;
```

---

## الـ URL Structure الكاملة دلوقتي

```mermaid
flowchart TD
    subgraph auth["/api/v1/auth"]
        A1["POST /register"]
        A2["POST /login"]
    end

    subgraph projects["/api/v1/projects"]
        P1["GET / — كل الـ projects"]
        P2["POST / — خلق project (client)"]
        P3["GET /:id — project واحد"]
        P4["PATCH /:id — update (client owner)"]
        P5["DELETE /:id — soft delete (client owner)"]
        P6["POST /:projectId/proposals — بعت proposal (freelancer)"]
        P7["GET /:projectId/proposals — شوف proposals (client owner)"]
    end

    subgraph proposals["/api/v1/proposals"]
        PR1["PATCH /:id/accept — قبول proposal (client owner)"]
    end

    style auth fill:#2b6cb0,color:#fff
    style projects fill:#276749,color:#fff
    style proposals fill:#553c9a,color:#fff
```

---

## ✅ Checkpoint — الـ Cascade بعينك

ده أهم checkpoint في المشروع كله. هتشوف الـ cascade بنفسك.

**الإعداد:**

اعمل register لـ 3 users:

```json
// Client
{ "name": "Ali", "email": "ali@test.com", "password": "password123", "role": "client" }

// Freelancer 1
{ "name": "Sara", "email": "sara@test.com", "password": "password123", "role": "freelancer" }

// Freelancer 2
{ "name": "Omar", "email": "omar@test.com", "password": "password123", "role": "freelancer" }
```

> [!example] Test 1 — خلق Project
> سجّل دخول بالـ client وخد الـ token. **POST** `/api/v1/projects` بالـ client token

> [!example] Test 2 — بعت Proposal من Freelancer 1
> سجّل دخول بـ Sara وخد الـ token.
> 
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/projects/<project_id>/proposals` **Header:** `Authorization: Bearer <Sara token>` **Body:**
> 
> ```json
> {
>   "coverLetter": "I am an experienced developer with 5 years of React experience. I have built similar dashboards before and can deliver within your deadline. My portfolio includes...",
>   "bidAmount": 1200
> }
> ```
> 
> **Expected:** `201` + proposal بـ `status: "pending"`

> [!example] Test 3 — بعت Proposal من Freelancer 2
> سجّل دخول بـ Omar وخد الـ token. نفس الـ request على نفس الـ project.

> [!example] Test 4 — حاول تبعت Proposal تاني من نفس الـ Freelancer
> بعت تاني بـ Sara token على نفس الـ project.
> 
> **Expected:** `400 — You have already submitted a proposal for this project`

> [!example] Test 5 — شوف الـ Proposals كـ Client
> **Method:** `GET` **URL:** `http://localhost:5000/api/v1/projects/<project_id>/proposals` **Header:** `Authorization: Bearer <Ali client token>`
> 
> **Expected:** قائمة بالـ proposals مع بيانات الـ freelancers

> [!example] Test 6 — شوف الـ Proposals بـ Freelancer Token
> نفس الـ request بـ Sara token.
> 
> **Expected:** `403 Forbidden`

> [!example] Test 7 — ⭐ اقبل Proposal Sara
> **Method:** `PATCH` **URL:** `http://localhost:5000/api/v1/proposals/<sara_proposal_id>/accept` **Header:** `Authorization: Bearer <Ali client token>`
> 
> **Expected:** `200` + proposal بـ `status: "accepted"`

**Test 8 — ⭐⭐ تحقق من الـ Cascade:**

بعد الـ accept — روح على MongoDB Compass أو شغّل:

```bash
db.proposals.find({ project: ObjectId('<project_id>') })
```

هتشوف:

- Sara's proposal: `status: "accepted"` ✅
- Omar's proposal: `status: "rejected"` 🤖 تلقائياً

```bash
db.projects.findOne({ _id: ObjectId('<project_id>') })
```

هتشوف:

- `status: "in_progress"` 🤖 تلقائياً
- `acceptedFreelancer: ObjectId('<sara_id>')` 🤖 تلقائياً

**ده الـ Cascade Hook شغّال.**

> [!example] Test 9 — حاول تبعت Proposal على Project في_progress
> اعمل proposal جديد على نفس الـ project.
> 
> **Expected:** `400 — This project is no longer accepting proposals`

---

## ملخص Sprint 9

اللي اتعلمته:

- الـ `post('save')` Hook بيشتغل **بعد** ما الـ document يتحفظ في الـ DB
- الـ Cascade مكانه في الـ **Model** مش الـ Controller — عشان يشتغل في أي scenario
- الـ **Compound Index** `{ project, freelancer }` بيمنع duplicate proposals على مستوى الـ DB
- `mongoose.model('Name')` بتجيب من الـ Mongoose registry من غير circular dependency
- `.populate('project')` في الـ `acceptProposal` ضروري عشان توصل لـ `proposal.project.client`
- الـ **Nested Routes** `/:projectId/proposals` بيخلي الـ URL semantically صح
- لما Proposal يتقبل — 3 حاجات بتحصلوا تلقائياً: الـ proposal بيبقى accepted، الباقيين rejected، والـ project بيتحول لـ in_progress

---

> **جاهز للـ Sprint 10؟**
> 
> Sprint 10 هو **Reviews + Aggregation Pipeline** — آخر feature في المشروع. هنبني نظام التقييم والـ Dashboard Stats باستخدام الـ MongoDB Aggregation Pipeline. وهنشرح الـ static method وإزاي الـ `avgRating` بيتحسب تلقائياً بعد كل review.
> 
> قول "كمّل" لما تشوف الـ cascade بنفسك في MongoDB Compass.

---

---

# ⭐ Sprint 10 — Reviews + Aggregation Pipeline

---

## إيه اللي هنبنيه؟

بعد ما الـ project يخلص — الـ client يقدر يقيّم الـ freelancer. التقييم ده بيأثر على الـ `avgRating` بتاع الـ freelancer.

المشكلة: الـ `avgRating` مش field ثابت — بيتغير كل ما review يتضاف أو يتحذف. محتاجين نحسبه من الـ reviews كلها وندّيه على الـ User document.

الحل: **Static Method + Hooks**

```mermaid
flowchart TD
    subgraph trigger["Events بتشغّل الـ Recalculation"]
        E1["Review جديد اتضاف<br/>post-save hook"]
        E2["Review اتحذف<br/>post findOneAndDelete hook"]
    end

    subgraph calc["Static Method: calcAverageRating"]
        C1["Aggregate كل الـ reviews<br/>للـ freelancer ده"]
        C2["احسب المتوسط<br/>والعدد"]
        C3["حدّث الـ User document<br/>بالـ avgRating الجديد"]
    end

    E1 --> calc
    E2 --> calc

    style trigger fill:#2b6cb0,color:#fff
    style calc fill:#276749,color:#fff
```

---

## الـ MongoDB Aggregation Pipeline — إيه ده؟

الـ Aggregation Pipeline هو طريقة تشغّل عمليات حسابية على الـ database من غير ما تجيب الـ documents كلها لـ Node.js.

تخيله زي خط تجميع في مصنع — كل stage بياخد الـ input من اللي قبله ويطلع output للـ stage الجاي:

```mermaid
flowchart LR
    D["كل الـ Reviews<br/>في الـ DB"]
    D --> S1

    subgraph S1["Stage 1: $match"]
        M["فلتر — خد بس<br/>الـ reviews بتاعت<br/>الـ freelancer ده"]
    end

    S1 --> S2

    subgraph S2["Stage 2: $group"]
        G["اجمع — احسب<br/>المتوسط والعدد"]
    end

    S2 --> R["النتيجة:<br/>{ avgRating: 4.5, numRatings: 12 }"]

    style D fill:#2d3748,color:#fff
    style S1 fill:#2b6cb0,color:#fff
    style S2 fill:#553c9a,color:#fff
    style R fill:#276749,color:#fff
```

**ليه مش بنجيب الـ reviews ونحسب في Node.js؟**

```mermaid
flowchart TD
    subgraph bad["❌ الطريقة البطيئة"]
        B1["جيب كل الـ reviews من الـ DB"]
        B1 --> B2["1000 review — كلهم في الـ RAM"]
        B2 --> B3["احسب المتوسط في JavaScript"]
        B3 --> B4["كتير على الـ network وبطيء"]
    end

    subgraph good["✅ الـ Aggregation Pipeline"]
        G1["MongoDB يحسب داخلياً"]
        G1 --> G2["بيرجع نتيجة واحدة بس"]
        G2 --> G3["سريع جداً — بغض النظر عن عدد الـ reviews"]
    end

    style bad fill:#4a1212,color:#fff
    style good fill:#1a4731,color:#fff
```

---

## الـ Static Method — إيه ده وفين مكانه؟

الـ **Static Method** هو function على الـ **Model نفسه** — مش على الـ document.

```mermaid
flowchart LR
    subgraph instance["Instance Method<br/>على الـ document"]
        IM["user.correctPassword()<br/>this = الـ user document"]
    end

    subgraph static["Static Method<br/>على الـ Model"]
        SM["Review.calcAverageRating(id)<br/>this = الـ Review Model"]
    end

    style instance fill:#2b6cb0,color:#fff
    style static fill:#553c9a,color:#fff
```

بنستخدم static method هنا لأن الـ operation ده بيخص الـ collection كلها — مش document واحد.

---

## 💻 خطوة 1 — أضف `avgRating` و`ratingsCount` على الـ User Schema

افتح `src/models/User.model.js` وضيف الـ fields دي:

```javascript
avgRating: {
  type:    Number,
  default: 0,
  min:     [0, 'Rating must be at least 0'],
  max:     [5, 'Rating cannot exceed 5'],
},

ratingsCount: {
  type:    Number,
  default: 0,
},
```

---

## 💻 خطوة 2 — اعمل `src/models/Review.model.js`

```javascript
const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    project: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'Project',
      required: [true, 'Review must belong to a project'],
    },

    reviewer: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: [true, 'Review must have a reviewer'],
    },

    freelancer: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: [true, 'Review must have a freelancer'],
    },

    rating: {
      type:     Number,
      required: [true, 'Please provide a rating'],
      min:      [1, 'Rating must be at least 1'],
      max:      [5, 'Rating cannot exceed 5'],
    },

    comment: {
      type:      String,
      required:  [true, 'Please provide a comment'],
      minlength: [10, 'Comment must be at least 10 characters'],
    },
  },
  { timestamps: true }
);

// كل client يقدر يقيّم مرة واحدة بس لكل project
reviewSchema.index({ project: 1, reviewer: 1 }, { unique: true });

// ══════════════════════════════════════════════════════
// STATIC METHOD — بيشتغل على الـ Model مش الـ document
// ══════════════════════════════════════════════════════
reviewSchema.statics.calcAverageRating = async function (freelancerId) {
  // 'this' هنا = الـ Review Model

  const stats = await this.aggregate([
    // Stage 1: خد بس الـ reviews اللي للـ freelancer ده
    {
      $match: { freelancer: freelancerId },
    },

    // Stage 2: احسب المتوسط والعدد
    {
      $group: {
        _id:          '$freelancer',    // اجمع حسب الـ freelancer
        numRatings:   { $sum: 1 },      // عدد الـ reviews
        avgRating:    { $avg: '$rating' }, // متوسط الـ rating
      },
    },
  ]);

  // لو في reviews — حدّث الـ User
  if (stats.length > 0) {
    await mongoose.model('User').findByIdAndUpdate(freelancerId, {
      ratingsCount: stats[0].numRatings,
      avgRating:    Math.round(stats[0].avgRating * 10) / 10, // round to 1 decimal
    });
  } else {
    // لو مفيش reviews — reset للـ defaults
    await mongoose.model('User').findByIdAndUpdate(freelancerId, {
      ratingsCount: 0,
      avgRating:    0,
    });
  }
};

// ══════════════════════════════════════════════════════
// HOOK 1: بعد إضافة review — احسب الـ average
// ══════════════════════════════════════════════════════
reviewSchema.post('save', function () {
  // 'this' = الـ review document
  // 'this.constructor' = الـ Review Model
  this.constructor.calcAverageRating(this.freelancer);
});

// ══════════════════════════════════════════════════════
// HOOK 2: بعد حذف review — احسب الـ average تاني
// الـ findOneAndDelete مش بيشغّل post('save')
// محتاجين workaround خاص
// ══════════════════════════════════════════════════════
reviewSchema.pre(/^findOneAnd/, async function (next) {
  // قبل الـ delete — جيب الـ document وحفظه على الـ query object
  // لأن بعد الـ delete مش هنلاقيه في الـ DB
  this.reviewDoc = await this.model.findOne(this.getQuery());
  next();
});

reviewSchema.post(/^findOneAnd/, async function () {
  // بعد الـ delete — استخدم الـ document اللي حفظناه
  if (this.reviewDoc) {
    await this.reviewDoc.constructor.calcAverageRating(
      this.reviewDoc.freelancer
    );
  }
});

const Review = mongoose.model('Review', reviewSchema);
module.exports = Review;
```

---

## شرح `this.constructor.calcAverageRating()`

```javascript
reviewSchema.post('save', function () {
  this.constructor.calcAverageRating(this.freelancer);
});
```

`this` جوا الـ `post('save')` = الـ review document.

`this.constructor` = الـ Class اللي الـ document ده instance منها — يعني الـ Review Model.

يعني `this.constructor.calcAverageRating(...)` = `Review.calcAverageRating(...)`.

**ليه مش كتبنا `Review.calcAverageRating()` مباشرة؟**

```mermaid
flowchart TD
    subgraph problem["المشكلة لو كتبنا Review مباشرة"]
        P1["reviewSchema.post('save', function() {"]
        P2["  Review.calcAverageRating(...)"]
        P3["Review مش معرّف لسه وقت تعريف الـ schema!"]
        P4["const Review = mongoose.model('Review', reviewSchema)"]
        P5["التعريف بييجي بعد"]
    end

    subgraph solution["الحل — this.constructor"]
        S1["this.constructor بيتحسب<br/>وقت تشغيل الـ hook"]
        S2["مش وقت تعريف الـ schema"]
        S3["Review بيكون معرّف بالفعل ✅"]
    end

    style problem fill:#4a1212,color:#fff
    style solution fill:#1a4731,color:#fff
```

---

## شرح الـ `pre/post findOneAnd` Workaround

ده من أصعب الـ concepts في Mongoose — بس مهم تفهمه.

**المشكلة:**

```
    Controller ──► Mongoose: Review.findOneAndDelete({ _id: id })
    Mongoose ──► MongoDB: DELETE document
    MongoDB ──► Mongoose: Deleted ✅
    Mongoose ──► post-save hook: post-save hook؟
    # ❌ مش بيشتغل! findOneAndDelete مش بيشغّل post-save
```

**الـ Solution — pre + post query middleware:**

```
    Controller ──► Mongoose: Review.findOneAndDelete({ _id: id })
    # pre /^findOneAnd/ hook بيشتغل
    Mongoose ──► MongoDB: findOne({ _id: id }) — جيب الـ doc قبل الحذف
    MongoDB ──► Mongoose: review document
    Mongoose → this.reviewDoc = review document
    Mongoose ──► MongoDB: DELETE document
    MongoDB ──► Mongoose: Deleted ✅
    # post /^findOneAnd/ hook بيشتغل
    Mongoose → this.reviewDoc.constructor.calcAverageRating(...)
    Mongoose ──► MongoDB: Update User avgRating
```

`/^findOneAnd/` هو regex بيطابق `findOneAndDelete` و`findOneAndUpdate` وكل حاجة تبدأ بـ `findOneAnd`.

---

## 💻 خطوة 3 — اعمل `src/controllers/review.controller.js`

```javascript
const Review     = require('../models/Review.model');
const Project    = require('../models/Project.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

// ══════════════════════════════════════════════════════
// CREATE REVIEW
// POST /api/v1/reviews
// ══════════════════════════════════════════════════════
exports.createReview = catchAsync(async (req, res, next) => {

  // Step 1: جيب الـ project وتحقق إنه completed
  const project = await Project.findById(req.body.projectId);

  if (!project) {
    return next(new AppError('No project found with that ID', 404));
  }

  if (project.status !== 'completed') {
    return next(
      new AppError('You can only review completed projects', 400)
    );
  }

  // Step 2: تحقق إن الـ reviewer هو صاحب الـ project
  if (project.client.toString() !== req.user._id.toString()) {
    return next(
      new AppError('You can only review projects you own', 403)
    );
  }

  // Step 3: تحقق إن الـ freelancer ده فعلاً اشتغل على الـ project
  if (project.acceptedFreelancer.toString() !== req.body.freelancerId) {
    return next(
      new AppError('This freelancer did not work on this project', 400)
    );
  }

  // Step 4: اخلق الـ review
  const review = await Review.create({
    project:    req.body.projectId,
    reviewer:   req.user._id,
    freelancer: req.body.freelancerId,
    rating:     req.body.rating,
    comment:    req.body.comment,
  });

  res.status(201).json({
    status: 'success',
    data:   { review },
  });
});

// ══════════════════════════════════════════════════════
// GET FREELANCER STATS (Dashboard)
// GET /api/v1/reviews/stats/:freelancerId
// ══════════════════════════════════════════════════════
exports.getFreelancerStats = catchAsync(async (req, res, next) => {
  const mongoose = require('mongoose');

  const freelancerId = new mongoose.Types.ObjectId(req.params.freelancerId);

  // Aggregation Pipeline 1 — Proposal stats
  const proposalStats = await mongoose.model('Proposal').aggregate([
    {
      $match: { freelancer: freelancerId },
    },
    {
      $group: {
        _id:   '$status',   // اجمع حسب الـ status
        count: { $sum: 1 }, // عدد الـ proposals في كل status
      },
    },
  ]);

  // Aggregation Pipeline 2 — Review stats
  const reviewStats = await Review.aggregate([
    {
      $match: { freelancer: freelancerId },
    },
    {
      $group: {
        _id:          null,              // مش محتاجين نجمع حسب حاجة
        avgRating:    { $avg: '$rating' },
        totalReviews: { $sum: 1 },
        minRating:    { $min: '$rating' },
        maxRating:    { $max: '$rating' },
      },
    },
  ]);

  res.status(200).json({
    status: 'success',
    data: {
      proposals: proposalStats,
      reviews:   reviewStats[0] || { avgRating: 0, totalReviews: 0 },
    },
  });
});
```

---

## شرح الـ Aggregation Pipeline بالتفصيل

```javascript
const proposalStats = await Proposal.aggregate([
  { $match: { freelancer: freelancerId } },
  { $group: { _id: '$status', count: { $sum: 1 } } },
]);
```

**`$match`** — زي الـ `WHERE` في SQL. بيفلتر الـ documents.

**`$group`** — زي الـ `GROUP BY` في SQL.

`_id: '$status'` — اجمع حسب الـ status field. الـ `$` قبل `status` يعني "قيمة الـ field ده".

`count: { $sum: 1 }` — لكل document في الـ group، ضيف 1 للـ count.

**النتيجة:**

```json
[
  { "_id": "pending",  "count": 3 },
  { "_id": "accepted", "count": 1 },
  { "_id": "rejected", "count": 2 }
]
```

```mermaid
flowchart TD
    subgraph input["Input — كل Proposals للـ freelancer"]
        I1["pending"]
        I2["accepted"]
        I3["pending"]
        I4["rejected"]
        I5["pending"]
        I6["rejected"]
    end

    subgraph stage1["$match — فلتر بالـ freelancerId"]
        M["بس proposals الـ freelancer ده"]
    end

    subgraph stage2["$group — اجمع حسب status"]
        G1["pending: 3"]
        G2["accepted: 1"]
        G3["rejected: 2"]
    end

    input --> stage1 --> stage2

    style input fill:#2d3748,color:#fff
    style stage1 fill:#2b6cb0,color:#fff
    style stage2 fill:#276749,color:#fff
```

---

## 💻 خطوة 4 — اعمل `src/routes/review.routes.js`

```javascript
const express = require('express');
const {
  createReview,
  getFreelancerStats,
} = require('../controllers/review.controller');
const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();

router.use(protect);

router.post('/',                           restrictTo('client'), createReview);
router.get('/stats/:freelancerId',         getFreelancerStats);

module.exports = router;
```

---

## 💻 خطوة 5 — ربط في `app.js`

```javascript
const reviewRoutes = require('./src/routes/review.routes');

app.use('/api/v1/reviews', reviewRoutes);
```

---

## خطوة مهمة — Project يتكمّل

لاحظ إن الـ `createReview` بيشترط إن الـ project بـ `status: 'completed'`. لكن مفيش route بتحول الـ project لـ completed حتى دلوقتي.

ضيف route بسيطة في الـ project controller:

```javascript
// في project.controller.js
exports.completeProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id);

  if (!project) return next(new AppError('No project found', 404));

  if (project.client.toString() !== req.user._id.toString()) {
    return next(new AppError('Not authorized', 403));
  }

  if (project.status !== 'in_progress') {
    return next(new AppError('Project must be in_progress to complete', 400));
  }

  project.status = 'completed';
  await project.save();

  res.status(200).json({ status: 'success', data: { project } });
});
```

وفي `project.routes.js`:

```javascript
const { ..., completeProject } = require('../controllers/project.controller');

router.patch('/:id/complete', restrictTo('client'), completeProject);
```

---

## ✅ Checkpoint

> [!example] Test 1 — أكمل الـ Project
> **Method:** `PATCH` **URL:** `http://localhost:5000/api/v1/projects/<project_id>/complete` **Header:** `Authorization: Bearer <client token>`
> 
> **Expected:** `200` + project بـ `status: "completed"`

> [!example] Test 2 — اعمل Review
> **Method:** `POST` **URL:** `http://localhost:5000/api/v1/reviews` **Header:** `Authorization: Bearer <client token>` **Body:**
> 
> ```json
> {
>   "projectId":    "<project_id>",
>   "freelancerId": "<sara_id>",
>   "rating":       5,
>   "comment":      "Excellent work! Sara delivered the project on time and the quality was outstanding."
> }
> ```
> 
> **Expected:** `201` + review object

**Test 3 — تحقق إن الـ avgRating اتحدّث:**

```bash
db.users.findOne({ email: 'sara@test.com' })
```

> هتشوف `avgRating: 5` و`ratingsCount: 1` — اتضافوا تلقائياً بالـ static method.

> [!example] Test 4 — اعمل Review تاني على project تاني
> اعمل project جديد، خليه يخلص، وبعدين review بـ rating مختلف. روح شوف الـ `avgRating` اتحسب تاني.

> [!example] Test 5 — Dashboard Stats
> **Method:** `GET` **URL:** `http://localhost:5000/api/v1/reviews/stats/<sara_id>` **Header:** `Authorization: Bearer <أي token>`
> 
> **Expected:**
> 
> ```json
> {
>   "status": "success",
>   "data": {
>     "proposals": [
>       { "_id": "accepted", "count": 1 },
>       { "_id": "rejected", "count": 1 }
>     ],
>     "reviews": {
>       "avgRating": 4.5,
>       "totalReviews": 2,
>       "minRating": 4,
>       "maxRating": 5
>     }
>   }
> }
> ```

---

## ملخص Sprint 10

اللي اتعلمته:

- **Aggregation Pipeline** — بيحسب على الـ DB مش في Node.js — أسرع بكتير مع data كبيرة
- **`$match`** زي `WHERE` — **`$group`** زي `GROUP BY` في SQL
- **Static Method** — على الـ Model مش الـ document — `this` = الـ Model
- **`this.constructor`** — بيجيب الـ Model من الـ document بدون circular dependency
- الـ **`pre/post findOneAnd` workaround** — عشان تشغّل logic بعد delete أو update بـ query middleware
- الـ **Business Rules في الـ Review** — بس completed projects، بس الـ client صاحبه، بس الـ freelancer اللي اشتغل عليه

---

---

# 🎯 Sprint 11 — Interview Survival Kit

---

## اللي هنعمله هنا

مش كود — ده مراجعة نهائية. كل سؤال ممكن يتسألك في الـ interview مع الإجابة بالظبط بالطريقة اللي المفروض تقولها.

---

## ❓ الأسئلة المتوقعة وإجاباتها

---

### "فرّق بين Authentication وAuthorization"

> **Authentication** — "مين أنت؟" — بنتحقق من هوية الـ user عن طريق الـ JWT. الـ `protect` middleware بيعمل ده.
> 
> **Authorization** — "مسموحلك تعمل ده؟" — بنتحقق من الـ role بعد ما عرفنا مين الـ user. الـ `restrictTo` middleware بيعمل ده.
> 
> الاتنين بيشتغلوا على الترتيب — `protect` الأول عشان يعرف مين الـ user، وبعدين `restrictTo` يشوف هل ينفع يعمل ده.

---

### "إيه هو الـ JWT وإزاي بيشتغل؟"

> الـ JWT فيه 3 أجزاء: **Header** (algorithm) + **Payload** (data زي user ID) + **Signature** (HMAC hash للـ header والـ payload بالـ secret key).
> 
> لما السيرفر بيستقبله، بيعمل الـ signature من الأول باستخدام الـ secret key. لو الـ signature اللي عمله مطابق للـ signature في الـ token — الـ token صح. لو الـ payload اتغيّر — الـ signature مش هيتطابق والسيرفر يرفضه.
> 
> الـ JWT **Stateless** — السيرفر مش بيحفظ حاجة. كل المعلومات في الـ token نفسه.

---

### "ليه bcrypt وليه مش encryption؟"

> الـ Encryption قابل للعكس — لو حد سرق الـ key يقدر يفك كل الـ passwords. الـ Hashing مش قابل للعكس خالص.
> 
> `bcrypt` بالذات مصمم يكون **بطيء** عن قصد عشان يصعّب الـ brute force attacks. وبيضيف **salt** تلقائياً — يعني نفس الـ password بيدي hash مختلف لكل user، فمش ممكن تعمل rainbow table attack.
> 
> وقت الـ login مش بنفك الـ hash — بنعمل hash للـ password الجديد ونقارن الـ hashes.

---

### "إيه هو الـ Mongoose Middleware (Hooks)؟"

> في نوعين أساسيين:
> 
> **Document Middleware** — زي `pre('save')` وـ`post('save')`. `this` جوّاه = الـ document. بيشتغل مع `.save()` وـ`.create()` **بس**.
> 
> **Query Middleware** — زي `pre(/^find/)`. `this` جوّاه = الـ query. بيشتغل مع `.find()` وـ`.findOne()` وغيرهم.
> 
> **المشكلة المهمة:** `findByIdAndUpdate` **مش** بيشغّل document middleware. لو عندك hook مهم زي password hashing — لازم تستخدم `.save()` مش `findByIdAndUpdate`.

---

### "إيه الفرق بين `.save()` وـ`findByIdAndUpdate()`؟"

> `save()` بيمر بـ الـ Mongoose lifecycle كامل — validation، pre-save hooks، post-save hooks.
> 
> `findByIdAndUpdate()` بيتكلم MongoDB مباشرة — أسرع، بس بيتجاوز الـ hooks والـ validators (إلا لو ضفت `{ runValidators: true }`).
> 
> القاعدة: لو في hook مهم لازم يشتغل — استخدم `.save()`. لو update بسيط ومفيش hooks مهمة — `findByIdAndUpdate()` أسرع وأنظف.

---

### "إيه هو الـ `catchAsync` وليه بنستخدمه؟"

> هو higher-order function — بتاخد async function وبترجع function جديدة. الـ function الجديدة بتشغّل الـ original وبتعمل `.catch(next)` على أي rejection.
> 
> من غيره، لو promise رُفضت في async route handler — Express مش بيعرف يمسك الـ error دي بدون `try/catch`. معاه، أي error بتروح تلقائياً للـ global error handler.
> 
> النتيجة: مفيش `try/catch` في أي controller.

---

### "إيه الـ `isOperational` flag في `AppError`؟"

> بيفرق بين نوعين من الـ errors:
> 
> **Operational Errors** — أنا عملتها عن قصد. زي "User not found" أو "Invalid credentials". آمن أبعت الـ message للـ client.
> 
> **Programming Errors** — bugs غير متوقعة. زي null reference أو typo. خطر أبعت التفاصيل للـ client — ممكن يكشف الـ architecture.
> 
> الـ global error handler بيشوف `isOperational` — لو `true` يبعت الـ message. لو `false` يبعت "Something went wrong" ويـ log الـ error داخلياً.

---

### "إيه الـ Cascade Hook وليه مكانه في الـ Model؟"

> الـ Cascade هو الـ `post('save')` hook على الـ Proposal model. لما proposal يتحفظ بـ `status: 'accepted'` — بيرفض كل الـ proposals التانية على نفس الـ project ويحول الـ project لـ `in_progress` تلقائياً.
> 
> مكانه في الـ Model لأن الـ business rule دي مرتبطة بالـ data نفسها — مش بـ API endpoint معين. لو حطيناها في الـ controller، أي كود تاني يعمل `proposal.save()` من غير الـ API هيـ bypass الـ logic.

---

### "إيه هو الـ Aggregation Pipeline؟"

> هو طريقة تعمل calculations معقدة على الـ MongoDB server نفسه بدل ما تجيب الـ data لـ Node.js وتحسب فيها.
> 
> بيمر بـ stages: `$match` (زي WHERE) ← `$group` (زي GROUP BY + aggregates) ← `$sort` ← `$project`.
> 
> أسرع بكتير مع data كبيرة لأن الحساب بيحصل على الـ DB server مش في الـ RAM بتاع الـ application.

---

### "إيه الفرق بين 401 و403؟"

> **401 Unauthorized** — "مش عارف مين أنت". مفيش token أو الـ token باظ. الـ solution: اعمل login.
> 
> **403 Forbidden** — "عارف مين أنت، بس مش مسموحلك". عامل login، بس الـ role بتاعك مش ليه permission على الـ action ده.

---

## 🚨 أكتر الأخطاء اللي الناس بتعملها

```mermaid
flowchart TD
    subgraph mistakes["أخطاء شائعة"]
        M1["❌ استخدام arrow function في الـ Mongoose hooks<br/>بيخلي 'this' = undefined"]
        M2["❌ نسيان next() في الـ middleware<br/>بيخلي الـ request تعلق"]
        M3["❌ حط الـ error handler قبل الـ routes<br/>مش هيشتغل"]
        M4["❌ الثقة في req.body للـ sensitive fields<br/>زي client أو role"]
        M5["❌ استخدام findByIdAndUpdate مع fields فيها hooks<br/>زي password"]
        M6["❌ مش إضافة runValidators: true<br/>مع findByIdAndUpdate"]
        M7["❌ return next() من غير return<br/>بيبعت response اتنين"]
    end

    style mistakes fill:#4a1212,color:#fff
```

---

## ✅ الـ Checklist النهائي قبل الـ Interview

```
الـ Server والـ Setup
  ✅ express.json() موجود قبل الـ routes
  ✅ Global error handler آخر حاجة في app.js
  ✅ dotenv.config() أول سطر في server.js
  ✅ process.on uncaughtException وunhandledRejection موجودين

الـ Authentication
  ✅ password عنده select: false في الـ Schema
  ✅ pre-save hook بيعمل hash للـ password فقط لما isModified
  ✅ function عادية في الـ hooks مش arrow function
  ✅ JWT_SECRET في .env مش في الكود
  ✅ تحقق من user وpassword في شرط واحد في الـ login

الـ Authorization
  ✅ protect قبل restrictTo دايماً
  ✅ تحقق من .toString() لما بتقارن ObjectIds

الـ Business Logic
  ✅ client: req.user._id مش req.body.client
  ✅ freelancer: req.user._id مش req.body.freelancer
  ✅ Cascade Hook في الـ Model مش الـ Controller
  ✅ mongoose.model() في الـ hooks مش require

الـ Error Handling
  ✅ next(new AppError(...)) مش throw
  ✅ return next(...) عشان ما تبعتش response اتنين
  ✅ catchAsync على كل async controller
```

---

## كلمة الأخير

اللي بنيته ده مش بس project — ده الـ foundations اللي كل production Node.js API بتتبنى عليها.

لما المحاور يسألك في الـ interview — مش المهم تحفظ الكود. المهم تشرح **ليه**:

- ليه الـ hash في الـ Model مش الـ Controller
- ليه `next(err)` مش `throw`
- ليه `protect` قبل `restrictTo`
- ليه الـ Cascade في الـ Hook مش في الـ Controller

الـ "ليه" هو اللي بيفرق بين Junior وMid-level developer.

**بالتوفيق يا Mohamed 🚀**