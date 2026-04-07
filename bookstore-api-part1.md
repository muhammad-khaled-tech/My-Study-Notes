# 🔵 PART 1 — "The Backbone"
## Foundation, Security & Cross-Cutting Concerns
### Bookstore API — ITI Project Deep Dive

> **Persona:** Senior Backend Architect grilling a Junior Dev.
> **Style:** Egyptian Developer — English tech terms + Arabic analogies بالعامية.
> **Template:** 6 fixed steps per topic — الكونسبت، مثال، شرح التطبيق، الربط، العيوب، أسئلة انترفيو.

---

# Topic 1 — Entry Points & App Bootstrap

## `index.js` + `app.js` + `vercel.json`

---

## 1A — `app.js` — The Express App Factory

---

### 1. الكونسبت العام

تخيل إنك بتبني **مبنى حكومي**. المبنى ده عنده:
- **باب رئيسي** — اللي كل الناس بتعدي منه
- **موظف الاستقبال** — بيشوف كل ورقة جاية وبيشيل المعلومات الزيادة
- **كاميرات مراقبة** — بتسجل كل حد دخل وخرج
- **حارس أمن** — بيتأكد إن مش في حد بيدخل بسرعة كبيرة
- **أدوار مختلفة** — كل دور فيه إدارة مختلفة

`app.js` هو **المبنى ده بالظبط** — بيحدد الشكل العام للـ API وبيحط الـ middlewares اللي هتشتغل على كل request قبل ما يوصل لأي route.

السؤال المهم: **ليه `app.js` منفصل عن `index.js`؟**

لأن `index.js` بتعمل حاجتين مختلفتين: بتشغّل الـ server (بتعمل listen على port)، وبتوصل بالـ DB. أما `app.js` بتعمل حاجة واحدة بس: بتعرّف شكل الـ Express application. الفصل ده بيسمحلك إنك تـ test الـ app من غير ما تشغّل server حقيقي — بتعمل `require('./app')` في الـ tests مباشرةً.

---

### 2. مثال عام بسيط

```js
const express = require('express');
const app = express();

// بترتيب: global middlewares الأول، ثم routes، ثم error handler آخر حاجة
app.use(express.json());          // بيحول الـ body من text لـ JSON object
app.use('/api', require('./routes')); // بيوصل الـ routes
app.use(errorHandler);            // لازم يكون آخر حاجة

module.exports = app; // بنـ export الـ app مش بنشغّله هنا
```

---

### 3. شرح التطبيق

في `app.js` بالكامل:

```js
const cors = require('cors');
const express = require('express');
const { httpLogger, errorHandler, rateLimiter } = require('./src/middlewares');
const routes = require('./src/routes');

const app = express();

app.use(cors({
  origin: [
    'http://localhost:4200',
    'https://your-frontend.vercel.app'
  ],
  credentials: true
}));

app.use(express.json());
app.use(httpLogger);
app.use(rateLimiter);

app.use('/api', routes);

app.use(errorHandler);

module.exports = app;
```

**CORS — `credentials: true` مع specific origins:**

الـ CORS (Cross-Origin Resource Sharing) هو الـ browser mechanism اللي بيمنع الـ frontend على `localhost:4200` من إنه يكلم الـ backend على `localhost:5000` من غير إذن. الـ server هو اللي بيقول "مسموح" أو "مش مسموح".

`credentials: true` معناه: "مسموح للـ requests إنها تبعت cookies وـ Authorization headers". لكن لما بتقول `credentials: true`، مش مسموح تقول `origin: '*'` (كل حاجة). ده قانون في الـ CORS spec — لو عايز credentials، لازم تحدد origins معينة.

**`express.json()` — بيعمل إيه بالظبط؟**

الـ HTTP request جاي كـ raw text في الـ body. `express.json()` بيقرأ الـ raw text ده، بيحوله من JSON string لـ JavaScript object، وبيحطه في `req.body`. من غيره، `req.body` هيبقى `undefined`.

**ترتيب الـ middlewares — ليه مهم جداً؟**

```
CORS check
    ↓
Body parsing (express.json)
    ↓
Logging (httpLogger)
    ↓
Rate limiting (rateLimiter)
    ↓
Routes (/api)
    ↓
Error Handler (آخر حاجة دايماً)
```

لو عكست الترتيب وحطيت `express.json()` بعد الـ routes، الـ routes مش هتلاقي `req.body` لأنه لسه ما اتحولش.

لو حطيت `errorHandler` في الأول، الـ errors من الـ routes مش هتوصله لأنه اتسجّل قبلهم.

---

### 4. الربط بالصورة الكاملة

لما Angular frontend بيبعت `POST /api/auth/login`:

1. الـ browser بيبعت request من `http://localhost:4200`
2. **CORS middleware** — بيشوف الـ `Origin` header: هل هو في قائمة الـ `allowed origins`؟ نعم → يكمل
3. **`express.json()`** — بيقرأ الـ raw body `{"email":"a@b.com","password":"123"}` ويحوله لـ JS object في `req.body`
4. **`httpLogger`** — بيسجل: `POST /api/auth/login — 200 — 45ms`
5. **`rateLimiter`** — بيشوف IP هذا الـ client: وصل الـ 100 request في الدقيقة؟ لأ → يكمل
6. **Routes** — `/api` → `/auth` → `/login` → `authenticate` middleware → `login` controller
7. Controller بيعمل شغله وبيبعت response
8. لو حصلت error في أي خطوة — `errorHandler` middleware بياخد الـ error ويبعت response منظم

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ CORS origin hardcoded في الكود:**

```js
origin: [
  'http://localhost:4200',
  'https://your-frontend.vercel.app' // ← ده TODO comment!
]
```

`'https://your-frontend.vercel.app'` ده مش URL حقيقي. لو حد deploy المشروع من غير ما يغير ده، الـ production frontend مش هيقدر يكلم الـ backend. الأصح:

```js
origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:4200']
```

وفي الـ `.env`:
```
ALLOWED_ORIGINS=http://localhost:4200,https://real-frontend.vercel.app
```

**عيب 2 — مفيش `helmet` middleware للـ security headers:**

الكود مش بيستخدم `helmet` package اللي بيضيف HTTP security headers مهمة زي:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Strict-Transport-Security`

دي headers بتحمي من attacks كتير. في production، غيابها يعتبر security gap.

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه `app.js` بيعمل `module.exports = app` بدل ما يعمل `app.listen()` مباشرةً؟ إيه الفايدة من الفصل ده؟**
2. **إيه الـ CORS وليه الـ browser بيمنع الـ cross-origin requests تلقائياً؟ من اللي بيقرر: الـ browser ولا الـ server؟**
3. **ليه `errorHandler` لازم يكون آخر middleware في الـ chain؟ إيه اللي هيحصل لو حطيناه في الأول؟**

---

## 1B — `index.js` — The Server Launcher + DB Connector + Vercel Handler

---

### 1. الكونسبت العام

`index.js` ده الـ file الأكثر complexity في المشروع رغم إنه صغير — لأنه بيعمل **3 أدوار مختلفة في نفس الوقت**:

تخيل إنك صاحب محل. `index.js` زي إنك:
1. **بتفتح المحل** (بتعمل `app.listen` على port) — Local development
2. **بتوصّل الكهرباء والمية** (بتوصل بالـ DB) — DB connection
3. **بتعمل نظام طلبات delivery** (بتـ export `handler` لـ Vercel) — Serverless deployment

والجزء الذكي: في الـ local development المحل مفتوح طول اليوم. في Vercel، المحل بيتفتح بس لما يجي order — وبعدين بيقفل. ده اللي بيسموه **Serverless**.

---

### 2. مثال عام بسيط

```js
// Local development mode
if (require.main === module) {
  app.listen(3000, () => console.log('Server running'));
}

// Serverless mode (Vercel)
module.exports = async (req, res) => {
  await connectDB(); // connect قبل كل request
  return app(req, res);
};
```

---

### 3. شرح التطبيق

**`require.main === module` — إيه ده؟**

في Node.js، لما بتشغّل file مباشرةً بـ `node index.js`، الـ `require.main` بيساوي `module`. لو file تاني عمل `require('./index')` عشان يستخدمه كـ module، `require.main` مش هيساوي `module`.

Vercel بيعمل `require('index.js')` عشان يستخدم الـ `handler` المـ exported. مش بيشغّله كـ main script. فالـ `if` block مش بيشتغل على Vercel — بيشتغل بس لما تقول `node index.js` على جهازك.

```js
if (require.main === module) {
  // ده بيشتغل بس لما تقول: node index.js
  // مش بيشتغل لما Vercel يعمل require('./index')
  mongoose.connect(DB)
    .then(() => console.log('Connected to DB successfully'))
    .catch((err) => console.error('Failed to connect to DB:', err.message));

  const PORT = process.env.PORT || 5000;
  const server = app.listen(PORT, () => {
    console.log(`App is running on http://localhost:${PORT}`);
  });
}
```

**الـ DB Connection Strategy للـ Serverless:**

```js
const connectDB = async () => {
  if (mongoose.connection.readyState >= 1) return; // already connected or connecting
  return mongoose.connect(DB);
};

const handler = async (req, res) => {
  await connectDB();
  return app(req, res);
};
```

في الـ traditional server، بتوصل بالـ DB مرة واحدة لما الـ server يبدأ، وبعدين الـ connection مفتوح طول اليوم.

في الـ Serverless (Vercel)، كل request ممكن يجي في **process جديدة** (اللي بيسموها "cold start"). لو ما عندكش check، هتعمل `mongoose.connect()` في كل request — ده wasteful وممكن يعمل مشاكل في connection limits على MongoDB Atlas.

الـ `readyState`:
- `0` = disconnected
- `1` = connected ✅
- `2` = connecting
- `3` = disconnecting

`readyState >= 1` — يعني "لو في connection موجود أو جاري الاتصال، متعملش connection جديد".

**الـ `handler` اللي بيتـ export لـ Vercel:**

```js
module.exports = handler;
```

Vercel بيستخدم الـ `handler` ده كـ serverless function — كل request بيجي → Vercel بيستدعي `handler(req, res)` → الـ handler بيتأكد إن الـ DB موصولة → بيمرر الـ request للـ Express app.

**الـ Error Handlers:**

```js
process.on('uncaughtException', (err) => {
  console.error('Uncaught exception, shutting down:', err);
  process.exit(1);
});

process.on('unhandledRejection', (err) => {
  console.error('Unhandled rejection, shutting down:', err);
  server.close(() => process.exit(1));
});
```

فرق مهم:
- **`uncaughtException`** — error جاي من synchronous code اللي محدش عمله `try/catch`
- **`unhandledRejection`** — Promise اتـ reject ومحدش عمل `.catch()` عليه

في حالة `uncaughtException`: مش بنحاول نكمل، بنقفل فوراً بـ `process.exit(1)`.
في حالة `unhandledRejection`: بنقفل الـ server بشكل graceful (بنستنى الـ requests الحالية تخلص) ثم بنقفل.

**لماذا `process.exit(1)` وليس `process.exit(0)`؟**
- `0` = exited successfully (no error)
- `1` = exited due to error

الـ process manager (nodemon, PM2, Docker) بيشوف الـ exit code عشان يعرف يعيد تشغيل الـ app ولا لأ.

---

### 4. الربط بالصورة الكاملة

**Scenario 1 — Local Development:**

```
npm run dev
    ↓
nodemon index.js
    ↓
require.main === module ✅ → دخل الـ if block
    ↓
mongoose.connect(DB) → "Connected to DB successfully"
    ↓
app.listen(5000) → "App is running on http://localhost:5000"
    ↓
Server ready — connection persistent
    ↓
Request جاي → Express middleware chain → response
```

**Scenario 2 — Vercel Production:**

```
Request جاي على https://bookstore-api.vercel.app/api/auth/login
    ↓
Vercel بيعمل require('./index') لاول مرة (Cold Start)
    ↓
require.main !== module ❌ → مش بيدخل الـ if block
    ↓
Vercel بيستدعي handler(req, res)
    ↓
connectDB() → readyState === 0 → mongoose.connect()
    ↓
app(req, res) → Express chain → response
    ↓
Request تاني جاي (Warm Start)
    ↓
handler(req, res)
    ↓
connectDB() → readyState === 1 → return مباشرةً (مش بيعمل connect جديد)
    ↓
app(req, res) → response
```

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ `errorHandler` بيتـ register مرتين:**

```js
// في app.js:
app.use(errorHandler);

// في index.js:
app.use(errorHandler); // ← مرة تانية!
```

ده redundant. Express بيسجّل الـ middleware مرتين. في معظم الحالات مش هيعمل مشكلة واضحة، بس في edge cases ممكن يسبب double response. المكان الصح للـ `errorHandler` واحد بس — في `app.js`.

**عيب 2 — مفيش graceful shutdown على الـ Vercel handler:**

الـ `handler` الـ serverless مش عنده error handling لو `connectDB()` نفسها فشلت. لو MongoDB Atlas down، الـ handler هيرمي unhandled rejection. الأصح:

```js
const handler = async (req, res) => {
  try {
    await connectDB();
    return app(req, res);
  } catch (err) {
    console.error('DB connection failed:', err);
    res.status(503).json({ success: false, message: 'Service temporarily unavailable' });
  }
};
```

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه معنى `require.main === module`؟ وإزاي Vercel بيستخدم `index.js` بشكل مختلف عن `node index.js`؟**
2. **إيه الـ Cold Start في الـ Serverless functions؟ وليه الـ `readyState` check مهم لحل مشكلته؟**
3. **إيه الفرق بين `process.on('uncaughtException')` وـ `process.on('unhandledRejection')`؟ وليه بيعملوا `process.exit(1)`؟**

---

## 1C — `vercel.json` — Deployment Config

---

### 1. الكونسبت العام

`vercel.json` زي **دليل التعليمات اللي بتديه لشركة النقل** عشان يعرفوا يوصّلوا طلباتك. Vercel بيقرأ الـ file ده عشان يعرف: إيه الـ entry point؟ وإزاي يـ route الـ requests؟

---

### 2. مثال عام بسيط

```json
{
  "version": 2,
  "builds": [{ "src": "index.js", "use": "@vercel/node" }],
  "routes": [{ "src": "/(.*)", "dest": "index.js" }]
}
```

---

### 3. شرح التطبيق

```json
{
  "version": 2,
  "builds": [
    {
      "src": "index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "index.js"
    }
  ]
}
```

- **`version: 2`** — Vercel API version
- **`builds`** — بيقول لـ Vercel: "الـ entry point هو `index.js` واستخدم الـ `@vercel/node` builder عشان تحوّله لـ serverless function"
- **`routes`** — `/(.*)`  regex بتمسك أي URL (`/api/books`, `/api/auth/login`, etc.) وبترسله لـ `index.js`

بدون الـ `routes`، Vercel مكانش هيعرف إنه يبعت `/api/books` لـ `index.js` — كان هيحاول يلاقي ملف اسمه `api/books`.

---

### 4. الربط بالصورة الكاملة

```
Request: GET https://bookstore.vercel.app/api/books
    ↓
vercel.json → routes: /(.*) matches /api/books → dest: index.js
    ↓
Vercel بيستدعي الـ handler المـ exported من index.js
    ↓
handler(req, res) → connectDB() → app(req, res)
    ↓
Express routes → /api/books → getAllBooks controller
    ↓
Response
```

---

### 5. العيوب اللي في الكود

**عيب 1 — مفيش environment variables في `vercel.json`:**
الـ env vars (MONGO_URI, JWT_SECRET) لازم تتحط في Vercel dashboard يدوياً. الكود مش موثّق ليه كده في الـ `vercel.json`. بعض projects بتحط `env` section في الـ `vercel.json` كـ documentation (بدون القيم الفعلية).

**عيب 2 — الـ route pattern `/(.*)`  مش بتـ exclude الـ static files:**
لو حد add static files لاحقاً، كل حاجة هتروح لـ `index.js`. الأصح يكون في rules أوضح.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين الـ traditional Node.js server والـ Serverless function على Vercel؟**
2. **ليه محتاجين الـ `routes` section في `vercel.json`؟ إيه اللي هيحصل لو مكانتش موجودة؟**
3. **إيه معنى `@vercel/node` builder؟**

---

# Topic 2 — Database Configuration & Connection Strategy

## `mongoose.connect()` — الـ DB Lifecycle

---

### 1. الكونسبت العام

تخيل إن الـ Database زي **مخزن كبير في مدينة تانية**. عشان توصّل للمخزن، محتاج تفتح **طريق** (connection). الطريق ده بياخد وقت عشان يتفتح — مش فوري.

في الـ traditional server، بتفتح الطريق مرة واحدة لما الـ app يبدأ، وبيفضل مفتوح طول اليوم. كل request بتستخدم نفس الطريق ده.

في الـ Serverless، الـ app بيتوقف ويبدأ من أول وجديد مع كل request (أو مجموعة requests). لو مش اتعملتش management صح، هتفتح طريق جديد مع كل request — وده expensive جداً ومش الـ MongoDB Atlas بيسمح بعدد كبير من الـ concurrent connections.

الحل الذكي: **Connection Caching** — تفتح الطريق مرة واحدة، وفي كل request تقول "هل الطريق مفتوح؟ نعم؟ تمام، استخدمه. لأ؟ افتحه."

---

### 2. مثال عام بسيط

```js
const connectDB = async () => {
  // لو في connection موجود → رجّع من غير ما تعمل حاجة
  if (mongoose.connection.readyState >= 1) return;
  // لو مفيش → اعمل connection جديد
  return mongoose.connect(process.env.MONGO_URI);
};
```

---

### 3. شرح التطبيق

```js
const DB = process.env.MONGO_URI;

const connectDB = async () => {
  if (mongoose.connection.readyState >= 1) return;
  return mongoose.connect(DB);
};
```

**الـ `mongoose.connect()` — بتعمل إيه تحت الغطاء؟**

بتفتح **connection pool** — مش connection واحد، لكن مجموعة connections جاهزة (default: 5). لما يجي request، بياخد connection من الـ pool، بيستخدمه، وبيرجعه للـ pool. ده بيسمح بـ concurrent requests.

**الـ MONGO_URI بتاخد شكل:**
```
mongodb+srv://username:password@cluster.mongodb.net/bookstore?retryWrites=true
```

**ليه `async/await` هنا؟**

`mongoose.connect()` بترجع Promise — يعني الاتصال بيحصل في الـ background وبياخد وقت. الـ `await` بيقول "استنى لحد ما الاتصال يتم قبل ما تكمل".

---

### 4. الربط بالصورة الكاملة

```
Cold Start على Vercel (أول request):
handler() → connectDB() → readyState === 0
    ↓
mongoose.connect(MONGO_URI) ← بياخد ~200-500ms
    ↓
readyState = 1 (connected)
    ↓
app(req, res) → controller → User.findOne({email}) ← بيستخدم الـ connection
    ↓
Response

Warm Start (نفس process، request تاني):
handler() → connectDB() → readyState === 1
    ↓
return فوراً (no DB connection overhead)
    ↓
app(req, res) → controller → fast response
```

---

### 5. العيوب اللي في الكود

**عيب 1 — مفيش mongoose connection options:**

`mongoose.connect(DB)` من غير options. في production لازم تحط:
```js
mongoose.connect(DB, {
  serverSelectionTimeoutMS: 5000, // بعد 5 ثواني لو مش قادر يتوصل → error
  socketTimeoutMS: 45000,
  maxPoolSize: 10, // maximum connections in pool
});
```

**عيب 2 — مفيش retry logic:**

لو الـ connection فشل مرة واحدة، الـ app بيطلع error ومش بيحاول تاني. في production يفضل تكون عندك exponential backoff retry.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ Connection Pool وليه أفضل من إنك تفتح connection جديد مع كل request؟**
2. **إيه الـ `readyState` في Mongoose وإيه القيم المختلفة بتاعته؟**
3. **ليه بنحط الـ MONGO_URI في الـ `.env` file بدل ما نكتبه مباشرةً في الكود؟**

---
# Topic 3 — The Utils Layer (Your Custom Toolkit)

## `ApiError.js` + `ApiResponse.js` + `errorHelpers.js` + `pagination.js`

---

## 3A — `ApiError.js` — Custom Error Class

---

### 1. الكونسبت العام

تخيل إنك شغّال في مصنع وحصل غلطة. في نوعين من الغلطات:
1. **غلطة متوقعة (Operational)** — "المخزن خلص" أو "المنتج ده مش موجود". دي غلطة طبيعية، بتحصل، والـ user يفهمها.
2. **غلطة مش متوقعة (Programmer Bug)** — "كود خاطئ" أو "null pointer exception". دي غلطة في الكود نفسه، والـ user مش المفروض يشوف تفاصيلها.

JavaScript عندها built-in `Error` class. بس الـ `Error` العادية مش بتحتوي على `statusCode` (404, 401, 403...) اللي HTTP محتاجه. فالحل: نعمل **custom Error class** بنـ extend فيها الـ `Error` العادية ونضيف عليها.

ده زي إنك تاخد بطاقة تعريف عادية (Error) وتضيف عليها badge وظيفي (statusCode, isOperational).

---

### 2. مثال عام بسيط

```js
// الـ Error العادية — مش فيها statusCode
const err = new Error('User not found');
err.statusCode = 404; // بنضيفه يدوياً — مش clean

// الـ Custom Error — statusCode built-in
const err = new ApiError(404, 'User not found');
console.log(err.statusCode); // 404
console.log(err.message);    // 'User not found'
console.log(err.isOperational); // true
```

---

### 3. شرح التطبيق

```js
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message); // بيستدعي الـ Error constructor بالـ message
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}
module.exports = ApiError;
```

**`extends Error` — ليه مش بنعمل object عادي؟**

لأن لما بتـ `throw` حاجة، Express (وكل error handling system) بيتوقع إنها instance من `Error`. لو عملت `throw { statusCode: 404, message: '...' }` (plain object)، الـ error handler ممكن مايعرفوش يتعامل معاه بشكل صح. `instanceof Error` هيبقى `false`.

**`super(message)` — إيه ده؟**

الـ `super()` بيستدعي الـ parent class constructor — اللي هو `Error`. الـ `Error` constructor بياخد الـ `message` وبيحطه في `this.message`. لو ماستدعيتش `super()`، `this.message` هيبقى undefined.

**`this.status` — `'fail'` vs `'error'`:**

```js
this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
```

- **4xx errors** (400, 401, 403, 404, 409) → `status: 'fail'` — "الـ request فشل بسبب حاجة من جهة الـ client"
- **5xx errors** (500, 503) → `status: 'error'` — "في مشكلة في الـ server"

ده convention من [JSend specification](https://github.com/omniti-labs/jsend) — بيساعد الـ frontend يفرق بين "الـ request ده كان غلط" و "في مشكلة في الـ server".

**`this.isOperational = true` — الـ Flag المهم:**

ده flag بيقول: "الـ error ده متوقع ومعروف — مش bug في الكود". الـ error handler بيستخدم الـ flag ده في production:

```js
// في errorHelpers.js
const productionError = (err, res) => {
  if (err.isOperational) {
    // غلطة متوقعة → بعت رسالة تفصيلية
    return res.status(err.statusCode).json({ status: err.status, message: err.message });
  } else {
    // bug في الكود → بعت رسالة generic
    console.error('PROGRAMMING ERROR:', err);
    return res.status(500).json({ status: 'error', message: 'something went wrong' });
  }
};
```

الـ errors من Mongoose (ValidationError, CastError) و JWT (TokenExpiredError) مش عندهم `isOperational: true`. الـ error handler بيحوّلهم لـ ApiError قبل ما يبعتهم.

**`Error.captureStackTrace(this, this.constructor)` — ليه ده؟**

`captureStackTrace` ده V8 engine method (Node.js). بيعمل stack trace للـ error — الأسطر اللي أدت لحصول الـ error. الـ argument التاني (`this.constructor`) بيقول: "ابدأ الـ stack trace من الكود اللي عمل `new ApiError()`، متبدأش من الـ ApiError constructor نفسه". بيخلي الـ stack trace أنظف وأفيد للـ debugging.

---

### 4. الربط بالصورة الكاملة

في `controllers/auth.js`:
```js
if (await User.findOne({ email }))
  throw new ApiError(409, 'Email already in use');
```

Express 5 بيمسك الـ throw تلقائياً من الـ async function → بيبعته للـ `errorHandler` middleware:

```
throw new ApiError(409, 'Email already in use')
    ↓
Express 5 catches it automatically (no try/catch needed)
    ↓
errorHandler(err, req, res, next)
    ↓
err.isOperational === true → productionError()
    ↓
res.status(409).json({ status: 'fail', message: 'Email already in use' })
```

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ constructor بس بياخد `statusCode` و `message`:**

في كتير من المشاريع، الـ `ApiError` بياخد `details` argument تاني — for extra info (validation errors array مثلاً). الكود الحالي بيحط الـ details في الـ message string واحدة، ده مش structured.

```js
// الأحسن:
class ApiError extends Error {
  constructor(statusCode, message, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.details = details; // structured extra info
    // ...
  }
}
```

**عيب 2 — مفيش HTTP status code validation:**

`new ApiError(99, 'weird error')` هيتعمل من غير مشكلة. الأحسن تتأكد إن الـ statusCode valid HTTP code.

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه بنـ extend الـ `Error` class بدل ما نعمل object عادي ونعمله `throw`؟**
2. **إيه معنى `isOperational: true`؟ وكيف الـ error handler بيستخدم الـ flag ده؟**
3. **إيه الفرق بين `status: 'fail'` وـ `status: 'error'`؟ وبيتحددوا ازاي؟**

---

## 3B — `ApiResponse.js` — Standardized Response Shape

---

### 1. الكونسبت العام

تخيل إنك شغّال في call center كبير وكل موظف بيتكلم مع العملاء بطريقة مختلفة:
- موظف 1: "ماشي، الطلب اتعمل"
- موظف 2: `{ done: true, order: {...} }`
- موظف 3: `{ result: "success", payload: {...} }`

الـ frontend developer هيجنّن! مش عارف يـ parse الـ response.

`ApiResponse` هو **قالب موحد** — كل response في المشروع بياخد نفس الشكل:

```json
{
  "success": true,
  "message": "User created successfully",
  "data": { ... }
}
```

زي إن الشركة عملت template للـ call center وكل موظف بيملاه — مش بيكتب من دماغه.

---

### 2. مثال عام بسيط

```js
// بدون ApiResponse — inconsistent
res.status(200).json({ ok: true, user: userData });            // controller 1
res.status(200).json({ success: true, data: userData });       // controller 2 ← مختلف!
res.status(201).json({ created: true, result: userData });     // controller 3 ← مختلف تاني!

// مع ApiResponse — consistent دايماً
res.status(201).json(new ApiResponse(201, 'User created', userData));
```

---

### 3. شرح التطبيق

```js
class ApiResponse {
  constructor(statusCode, message, data = null, pagination = null) {
    this.success = statusCode < 400;
    this.message = message;
    this.data = data;
    if (pagination) this.pagination = pagination;
  }
}
module.exports = ApiResponse;
```

**`this.success = statusCode < 400` — الـ Boolean المشتق:**

بدل ما تقول `success: true` أو `success: false` يدوياً في كل controller، بيتحسب تلقائياً من الـ statusCode. 200, 201, 204 → `success: true`. 400, 401, 404, 500 → `success: false`.

**`data = null` — Default parameter:**

لو ماعديتش `data`، بيبقى `null`. بعض responses مش عندها data (زي `logout`). الـ frontend بيعرف يتعامل مع `data: null`.

**`if (pagination) this.pagination = pagination`:**

الـ `pagination` field بس بيتضاف للـ response لو اتعمله pass. لو ماعديتيش pagination، الـ `pagination` key مش بيظهر في الـ JSON خالص. أنظف من إنك تحط `pagination: null` في كل response.

**`res.json(new ApiResponse(...))` — كيف بيشتغل؟**

`res.json()` بتاخد object وبتحوله JSON وبتبعته. `new ApiResponse(...)` بيعمل object. Express بيستدعي `JSON.stringify()` تلقائياً على الـ object ده. الـ class properties (success, message, data) بتبقى في الـ JSON.

---

### 4. الربط بالصورة الكاملة

في `controllers/auth.js`:
```js
res.status(201).json(new ApiResponse(201, 'User created successfully', userObj));
```

`new ApiResponse(201, 'User created successfully', userObj)` بيعمل object:
```js
{
  success: true,      // 201 < 400 → true
  message: 'User created successfully',
  data: { _id: '...', email: '...', firstName: '...' }
}
```

`res.status(201).json(object)` → بيحوله JSON وبيبعته للـ client مع status code 201.

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ `pagination` parameter بياخد مكانه كـ 4th argument:**

في `controllers/author.js`، الـ paginate utility بيرجع `{ data, pagination }`. الـ controller بيعمل:

```js
return res.json(new ApiResponse(200, 'Authors fetched', { authors: authorsWithBookCount, pagination }));
```

بيحط الـ pagination **جوه الـ data** بدل ما يمررها كـ argument رابع للـ ApiResponse. يعني الـ `pagination` constructor parameter مش بيتستخدم خالص في المشروع — dead code! الـ team مش consistent في استخدامها.

**عيب 2 — الـ status code في الـ `ApiResponse` بيتكرر مع `res.status()`:**

```js
res.status(201).json(new ApiResponse(201, 'User created', data));
```

الـ 201 بيتكتب مرتين. لو حد غيّر الأول ونسي التاني، `success` هيبقى calculated غلط. الأحسن إن الـ `ApiResponse` بتـ set `res.status()` بنفسها.

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه محتاجين `ApiResponse` class في الأصل؟ إيه المشكلة لو كل controller بيعمل الـ response بطريقته؟**
2. **`this.success = statusCode < 400` — إيه الـ statusCodes اللي هتدي `false` هنا؟**
3. **ليه الـ `pagination` field بيتضاف conditionally (`if (pagination)`) بدل ما يكون دايماً في الـ response؟**

---

## 3C — `errorHelpers.js` — Converting Ugly Errors to Clean Messages

---

### 1. الكونسبت العام

تخيل إنك موظف استقبال في مستشفى. لما دكتور بيقول "المريض عنده acute myocardial infarction"، أنت بتترجمها للأهل: "عنده أزمة قلبية".

`errorHelpers.js` بيعمل نفس الكلام — بياخد الـ errors الـ technical من MongoDB وـ JWT (اللي فيها terms زي "CastError" و "ValidationError" و "JsonWebTokenError") وبيحوّلها لرسائل بشرية مفهومة.

---

### 2. مثال عام بسيط

```js
// MongoDB CastError — الـ user بعت ID مش صالح
// error.message = 'Cast to ObjectId failed for value "abc" at path "_id"'
// ده scary ومش مفيد للـ client

// handleCastErrorDB بيحوّله لـ:
// 'Invalid _id: abc.'
// ده واضح ومفيد!
```

---

### 3. شرح التطبيق

**`devError` — للـ Development:**

```js
const devError = (err, res) => {
  return res.status(err.statusCode).json({
    status: err.status,
    error: err,        // ← الـ error object كامل
    message: err.message,
    stack: err.stack   // ← stack trace — مين بعت الـ error وفين في الكود
  });
};
```

في development، بتحتاج كل التفاصيل عشان تـ debug. الـ `stack` بيقولك "Error حصل في `controllers/auth.js` line 45، اللي اتستدعت من `routes/auth.js` line 12". مفيد جداً.

**`productionError` — للـ Production:**

```js
const productionError = (err, res) => {
  if (err.isOperational) {
    return res.status(err.statusCode).json({
      status: err.status,
      message: err.message  // بس الرسالة — مش stack trace
    });
  } else {
    console.error('PROGRAMMING ERROR:', err); // بيسجّل للـ server logs
    return res.status(500).json({
      status: 'error',
      message: 'something went wrong' // generic — مش بنفضح تفاصيل الـ bug
    });
  }
};
```

**`handleCastErrorDB` — Invalid MongoDB ObjectId:**

```js
const handleCastErrorDB = (err) => {
  const message = `Invalid ${err.path}: ${err.value}.`;
  return new ApiError(400, message);
};
```

الـ CastError بييجي لما `req.params.id` مش صالح ObjectId. مثلاً `GET /api/books/abc` — "abc" مش ObjectId. MongoDB بيحاول يعمل `cast` من string "abc" لـ ObjectId وبيفشل. الـ `err.path` = `"_id"` و `err.value` = `"abc"`.

**`handleDuplicateFieldsDB` — Unique Index Violation:**

```js
const handleDuplicateFieldsDB = (err) => {
  const value = err.keyValue ? Object.values(err.keyValue)[0] : 'unknown';
  const message = `Duplicate field value: "${value}". Please use another value.`;
  return new ApiError(409, message);
};
```

الـ error code `11000` بييجي لما بتحاول تحفظ value موجودة في unique field. مثلاً تسجيل user بـ email موجود. `err.keyValue` = `{ email: 'a@b.com' }`. `Object.values(err.keyValue)[0]` = `'a@b.com'`.

**`handleValidationErrorDB` — Mongoose Schema Validation:**

```js
const handleValidationErrorDB = (err) => {
  const errors = Object.values(err.errors).map((el) => el.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new ApiError(400, message);
};
```

الـ `err.errors` في Mongoose ValidationError هو object — key لكل field فاشل. `Object.values()` بياخد الـ values (error objects). `.map(el => el.message)` بياخد الـ message من كل error. `.join('. ')` بيحوطهم في string واحد.

---

### 4. الربط بالصورة الكاملة

في `errorHandler.js`:
```js
const errorHandler = (err, req, res, _next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    devError(err, res);
  } else {
    let error = { ...err, message: err.message };

    if (error.name === 'CastError') error = handleCastErrorDB(error);
    else if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    else if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
    else if (error.name === 'JsonWebTokenError') error = new ApiError(401, 'Invalid token. Please log in again!');
    else if (error.name === 'TokenExpiredError') error = new ApiError(401, 'Your token has expired! Please log in again.');

    productionError(error, res);
  }
};
```

**`let error = { ...err, message: err.message }` — ليه مش بنعدل `err` مباشرةً؟**

لأن `err` هو الـ original error object. الـ spread operator `{...err}` بيعمل shallow copy. بعدين `message: err.message` بنضيفها explicitly لأن الـ `message` property في الـ `Error` objects مش enumerable (مش بتظهر في الـ spread). ده subtlety مهم.

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ `error.name === 'JsonWebTokenError'` في الـ spread object مش هيشتغل:**

لما بتعمل `let error = { ...err }` على Error object، الـ `name` property (اللي بييجي من الـ prototype) مش بيتنسخ في الـ spread. يعني `error.name` ممكن يكون `undefined`. الـ check `error.name === 'JsonWebTokenError'` ممكن ما يشتغلش!

الحل:
```js
if (err.name === 'JsonWebTokenError') error = new ApiError(401, 'Invalid token');
```
بتشيك على `err` الـ original مش على الـ `error` الـ spread.

**عيب 2 — مفيش handler لـ `MongoNetworkError`:**

لو الـ DB اتقطع في النص (network issue)، MongoDB driver بيرمي `MongoNetworkError`. الكود مش بيتعامل معاه explicitly — هيوصل كـ `isOperational: false` error وهيرجع generic "something went wrong". ده correct behavior بس يفضل تسجّله بشكل مميز.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ CastError في Mongoose وإمتى بييجي؟ إيه مثال عملي عليه؟**
2. **إيه الفرق بين `error.name === 'CastError'` وـ `error.code === 11000`؟ ليه بعضها بيتشيك بـ `name` وبعضها بـ `code`؟**
3. **ليه في production بنبعت `'something went wrong'` للـ non-operational errors بدل الـ error message الحقيقية؟**

---

## 3D — `pagination.js` — The Reusable Paginator

---

### 1. الكونسبت العام

تخيل إنك بتدور على كتب في مكتبة عندها مليون كتاب. لو المكتبة جابتلك كل المليون كتاب مرة واحدة — هتغرق! الأذكى إنها بتقولك: "عندنا مليون كتاب. هل تيجي الـ 10 الأولى؟ وبعدين الـ 10 التانية؟"

ده بالظبط الـ Pagination. بدل ما ترجع كل documents دفعة واحدة، بترجع **صفحة** في كل مرة.

الـ `paginate` utility هنا بتعمل حاجة ذكية: بتجيب الـ data والـ count **بالتوازي** — مش واحدة بعد التانية.

---

### 2. مثال عام بسيط

```js
// بدون parallel — بطيء (sequential)
const books = await Book.find().skip(0).limit(10);   // ← استنى
const total = await Book.countDocuments();            // ← استنى تاني

// مع parallel — أسرع
const [books, total] = await Promise.all([
  Book.find().skip(0).limit(10),    // ← ابدأ
  Book.countDocuments()             // ← ابدأ في نفس الوقت
]);
// الاتنين بيشتغلوا مع بعض → بيخلصوا أسرع
```

---

### 3. شرح التطبيق

```js
const paginate = async (model, filterObject, options, page, limit) => {
  const skip = (page - 1) * limit;

  const [data, totalDocuments] = await Promise.all([
    model.find(filterObject)
      .sort(options.sort)
      .select(options.select)
      .populate(options.populate)
      .skip(skip)
      .limit(limit),
    model.countDocuments(filterObject)
  ]);

  const totalPages = Math.ceil(totalDocuments / limit);
  const hasPrev = page > 1;
  const hasNext = page < totalPages;

  return {
    data,
    pagination: {
      totalDocuments,
      page,
      limit,
      totalPages,
      hasPrev,
      hasNext
    }
  };
};
```

**`skip = (page - 1) * limit` — الـ Math:**

- Page 1: `skip = (1-1) * 10 = 0` → أول 10 documents
- Page 2: `skip = (2-1) * 10 = 10` → من document 11 لـ 20
- Page 3: `skip = (3-1) * 10 = 20` → من document 21 لـ 30

**`Promise.all([...])` — Parallel Execution:**

الـ `await` العادية sequential:
```js
const a = await queryA(); // 200ms
const b = await queryB(); // 200ms
// Total: 400ms
```

الـ `Promise.all` parallel:
```js
const [a, b] = await Promise.all([queryA(), queryB()]);
// Total: ~200ms (الأطول من الاتنين)
```

لو أي واحدة فيهم فشلت، `Promise.all` بيرفض وبييجي بالأول error.

**`totalPages = Math.ceil(totalDocuments / limit)`:**

مثال: 25 documents, limit 10:
- `25 / 10 = 2.5`
- `Math.ceil(2.5) = 3` ← 3 صفحات (الأخيرة فيها 5 بس)

`Math.floor(2.5) = 2` — غلط! لأن في صفحة 3 عندها documents.

**`hasPrev` و `hasNext`:**

- `hasPrev = page > 1` — لو في page 1، مفيش صفحة سابقة
- `hasNext = page < totalPages` — لو في آخر صفحة، مفيش صفحة تالية

الـ frontend بيستخدم ده عشان يعرف يظهر أو يخفي أزرار الـ navigation.

---

### 4. الربط بالصورة الكاملة

في `controllers/book.js`:
```js
const { data: books, pagination } = await paginate(
  Book,
  query,
  { populate: 'author category', sort: { name: 1 } },
  Number(page),
  Number(limit)
);

res.json(new ApiResponse(200, 'Books fetched', { books, pagination }));
```

الـ Response:
```json
{
  "success": true,
  "message": "Books fetched",
  "data": {
    "books": [...],
    "pagination": {
      "totalDocuments": 145,
      "page": 2,
      "limit": 10,
      "totalPages": 15,
      "hasPrev": true,
      "hasNext": true
    }
  }
}
```

---

### 5. العيوب اللي في الكود

**عيب 1 — `page` و `limit` مش بيتـ validate:**

لو الـ user بعت `page=0` أو `limit=-5` أو `limit=10000`، الـ `paginate` هتشتغل بقيم غريبة. `skip = (0-1) * 10 = -10` → MongoDB بيتعامل معاه كـ 0، بس النتيجة غير متوقعة. لازم يكون في validation:

```js
const safePage = Math.max(1, Number(page) || 1);
const safeLimit = Math.min(100, Math.max(1, Number(limit) || 10));
```

**عيب 2 — `paginate` مش بتـ handle الـ default values:**

في `controllers/author.js`:
```js
const { data: authors, pagination } = await paginate(
  Author,
  {},
  { sort: { name: 1 } } // ← مفيش page وlimit!
);
```

`page` و `limit` هيبقوا `undefined` → `skip = (undefined - 1) * undefined = NaN`. Mongoose بيـ ignore الـ NaN values وبيرجع كل documents! الـ default values لازم تبقى جوّا الـ `paginate` function نفسها أو يتبعتوا دايماً من الـ controller.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين `Promise.all` و sequential `await`؟ وإمتى تستخدم كل واحد؟**
2. **ليه بنستخدم `Math.ceil` في حساب `totalPages` وليس `Math.floor` أو `Math.round`؟**
3. **إيه اللي هيحصل لو `Promise.all` فيه قيمتين وواحدة منهم فشلت؟**

---

---

# Topic 4 — The Middleware Pipeline

## الـ 6 Middlewares بالكامل

---

## 4A — `logger.js` — Pino HTTP Logger

---

### 1. الكونسبت العام

تخيل إنك مدير مطعم. عايز تعرف: كام طلب جه النهارده؟ أيه الأطباق اللي اتطلبت أكتر؟ في أيه طلبات استغرقت وقت طويل؟

`logger.js` ده **الـ سجل الرسمي** للـ API — بيسجل كل request جاي وكل response راح: الـ method، الـ URL، الـ status code، الوقت اللي اخد. ده مش زي `console.log` العادية — ده **structured logging**.

**ليه Pino وليس `console.log`؟**

`console.log('User logged in at ' + new Date())` — بيطلع text عادي. مش تقدر تعمل عليه search أو filter أو analysis.

Pino بتطلع JSON:
```json
{"level":30,"time":1700000000000,"req":{"method":"POST","url":"/api/auth/login"},"res":{"statusCode":200},"responseTime":45}
```

الـ JSON ده تقدر ترفعه لـ log aggregation service (Datadog, Elastic, CloudWatch) وتعمل عليه queries زي: "كل الـ requests اللي خدت أكتر من 500ms" أو "كم 401 error حصل في آخر ساعة".

---

### 2. مثال عام بسيط

```js
const pino = require('pino');
const pinoHttp = require('pino-http');

// الـ logger نفسه — بيكتب JSON
const logger = pino({ level: 'info' });

// الـ HTTP middleware — بيسجل كل request/response تلقائياً
const httpLogger = pinoHttp({ logger });

logger.info('Server started');          // manual log
logger.error('Something went wrong');   // manual error log
```

---

### 3. شرح التطبيق

```js
const logger = pino({
  level: 'info',
  transport: process.env.NODE_ENV !== 'production'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined
});

const httpLogger = pinoHttp({ logger });

module.exports = { logger, httpLogger };
```

**`level: 'info'` — Log Levels:**

Pino عندها مستويات:
- `trace` — أدق تفاصيل (بيتشغّل في debug فقط)
- `debug` — معلومات تفصيلية للـ development
- `info` — معلومات عادية — request/response logs ✅
- `warn` — تحذيرات
- `error` — أخطاء
- `fatal` — أخطاء مميتة

لما بتقول `level: 'info'`، بيسجّل `info` وكل اللي فوقها (`warn`, `error`, `fatal`). بيتجاهل `trace` و `debug`.

**`transport: { target: 'pino-pretty' }` — في Development بس:**

الـ JSON الخام صعب يتقرأ بالعين:
```
{"level":30,"time":1700000000,"msg":"POST /api/auth/login 200 45ms"}
```

`pino-pretty` بيحوّل ده لـ:
```
[12:30:45] INFO: POST /api/auth/login 200 45ms
```

مع ألوان! بس ده بياخد resources إضافية، فبيشتغل بس في development. في production، الـ JSON الخام أفضل لأنه بيروح لـ log service.

**الفرق بين `logger` و `httpLogger`:**

- `logger` — للـ manual logging: `logger.info('Connected to DB')`, `logger.error(err, 'DB failed')`
- `httpLogger` — middleware بيوضع في `app.use(httpLogger)` وبيسجل كل request/response تلقائياً من غير ما تعمل حاجة

---

### 4. الربط بالصورة الكاملة

في `app.js`:
```js
app.use(httpLogger); // بيشتغل على كل request
```

لما `POST /api/auth/login` بييجي:
1. `httpLogger` middleware بيتشغّل → بيسجّل: `{ method: 'POST', url: '/api/auth/login', ... }`
2. الـ request بيكمل → login controller → response
3. `httpLogger` بيلاقي الـ response ويكمّل الـ log entry: `{ statusCode: 200, responseTime: 45 }`
4. بيكتب الـ complete log entry

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ logger مش بيـ redact الـ sensitive data:**

لو user بعت الـ password في الـ request body، والـ logger بيسجّل الـ request body كاملة، الـ password هيتسجّل في الـ logs! هكذا:

```js
const logger = pino({
  level: 'info',
  redact: ['req.body.password', 'req.headers.authorization'] // بيخفي الـ sensitive fields
});
```

**عيب 2 — الـ `logger` export مش بيتستخدم في أي controller:**

الكود بيـ export `{ logger, httpLogger }` بس `httpLogger` هو اللي بيتستخدم في `app.js`. الـ `logger` نفسه مش بيتستخدم في أي مكان في الكود للـ manual logging. الـ `console.log` في `index.js` مش بيستخدم الـ pino logger. ده inconsistency.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين `console.log` وـ structured logging زي Pino؟ ليه الـ JSON format أفضل في production؟**
2. **إيه الـ Log Levels وليه مهم إننا نحدد `level: 'info'` وليس `level: 'trace'`؟**
3. **ليه `pino-pretty` بيشتغل بس في development وليس production؟**

---

## 4B — `rateLimit.js` — The Hand-Built Rate Limiter

---

### 1. الكونسبت العام

تخيل إن عندك محل وفي زبون بيجي كل ثانية ويسألك عن سعر كل حاجة في المحل. ده مش زبون حقيقي — ده إما bot أو حد بيحاول يعطّل محلك (DDoS attack).

الـ Rate Limiter ده **الأمن اللي بيقول**: "يا عم، 100 سؤال في الدقيقة كافيين. لو فوق ده، اتفضل برّه لمدة دقيقة."

الجزء المميز في الكود ده: **مش بيستخدم أي library خارجية** — بيعمل الـ rate limiting من الصفر باستخدام JavaScript `Map`.

---

### 2. مثال عام بسيط

```js
const requests = new Map(); // { ip → { count, firstTime } }

const rateLimiter = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();

  if (!requests.has(ip)) {
    requests.set(ip, { count: 1, firstTime: now }); // أول request
    return next();
  }

  const { count, firstTime } = requests.get(ip);
  if (now - firstTime < 60000 && count >= 100) {
    return res.status(429).json({ message: 'Too many requests' });
  }
  // update وكمّل
};
```

---

### 3. شرح التطبيق

```js
const requests = new Map();
const WINDOW_TIME = 60 * 1000; // 1 minute in milliseconds
const MAX_REQUESTS = 100;
```

**الـ `Map` — ليه وليس Object عادي؟**

`Map` أفضل من Object عادي لـ key-value pairs لأن:
- Keys في Map ممكن تكون أي type (مش بس strings)
- الـ performance في `get`, `set`, `has` على Map أسرع لما الـ data تكبر
- عندها `forEach`, `size` properties built-in
- مش فيها الـ prototype pollution problem اللي في الـ plain objects

**الـ Cleanup `setInterval`:**

```js
setInterval(() => {
  const now = Date.now();
  requests.forEach(({ firstTime }, ip) => {
    if (now - firstTime > WINDOW_TIME) {
      requests.delete(ip);
    }
  });
}, WINDOW_TIME / 2); // بيشتغل كل 30 ثانية
```

ده زي **حارس النظافة** — كل 30 ثانية بيمر على الـ Map ويشيل الـ IPs اللي فاتت نافذتهم. من غير ده، الـ Map هتكبر لـ الأبد وتاكل كل الـ memory.

`WINDOW_TIME / 2` = 30 ثانية — بيشتغل مرتين في كل نافذة زمنية. ده كافي.

**منطق الـ Rate Limiter خطوة بخطوة:**

```js
const rateLimiter = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();

  // الحالة 1: IP جديد — أول مرة نشوفه
  if (!requests.has(ip)) {
    requests.set(ip, { count: 1, firstTime: now });
    return next();
  }

  let { count, firstTime } = requests.get(ip);

  // الحالة 2: نفس الـ IP، جوّا الـ window الزمنية
  if (now - firstTime < WINDOW_TIME) {
    if (count < MAX_REQUESTS) {
      // لسه تحت الـ limit → زوّد الـ count وكمّل
      count += 1;
      requests.set(ip, { count, firstTime });
      return next();
    }
    // وصل الـ limit → ارفض
    return res.status(429).json({ message: 'Too many requests. Please try again later.' });
  }

  // الحالة 3: الـ window انتهت → ابدأ window جديدة
  requests.set(ip, { count: 1, firstTime: now });
  next();
};
```

الـ **3 scenarios** بالترتيب:
1. IP ما شفناهوش قبل كده → ابدأ tracking جديد
2. IP شفناه وجوّا الـ window الزمنية → شيك على الـ count
3. IP شفناه بس الـ window انتهت → reset وابدأ من الأول

---

### 4. الربط بالصورة الكاملة

```
Request من IP: 192.168.1.1
    ↓
rateLimiter middleware
    ↓
requests.has('192.168.1.1')? → false (أول مرة)
    ↓
requests.set('192.168.1.1', { count: 1, firstTime: 1700000000 })
    ↓
next() → httpLogger → routes → controller
    ↓
(بعد 99 request في نفس الدقيقة...)
    ↓
count = 100 >= MAX_REQUESTS
    ↓
res.status(429).json({ message: 'Too many requests...' })
    ↓
(بعد 60 ثانية...)
    ↓
now - firstTime >= WINDOW_TIME → reset
    ↓
next() → كمّل عادي
```

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ rate limiter في memory بس (مش distributed):**

لو الـ API بيشتغل على أكتر من server instance (horizontal scaling) أو على Vercel (serverless — كل instance مختلف)، كل instance عنده `Map` منفصلة. IP ممكن يبعت 100 request لكل instance → يعمل 200 request في الدقيقة من غير مشكلة!

الحل: استخدام external store زي **Redis** للـ rate limiting data — كل instances بيتكلموا على نفس الـ Redis instance. أو استخدام library زي `express-rate-limit` مع `redis` store.

**عيب 2 — الـ 429 response مش بيحتوي على `Retry-After` header:**

Standard HTTP practice إن الـ 429 response يحتوي على `Retry-After` header — بيقول للـ client "استنى X ثواني وبعدين حاول تاني". الكود مش بيعمل ده:

```js
const retryAfter = Math.ceil((WINDOW_TIME - (now - firstTime)) / 1000);
res.set('Retry-After', retryAfter);
return res.status(429).json({
  message: `Too many requests. Try again in ${retryAfter} seconds.`
});
```

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ Rate Limiting وليه محتاجينه؟ إيه الـ attacks اللي بيحميها منها؟**
2. **ليه الـ Map أفضل من الـ plain object (`{}`) في الحالة دي؟**
3. **إيه مشكلة الـ in-memory rate limiting في بيئة Serverless زي Vercel؟ وإيه الحل؟**

---

## 4C — `validate.js` — The Joi Validation Middleware

---

### 1. الكونسبت العام

تخيل إنك موظف في بنك وبتستلم طلبات من العملاء. قبل ما تعمل أي حاجة، لازم تتأكد من:
- الاسم موجود؟
- رقم الحساب فيه 16 رقم؟
- المبلغ إيجابي؟

ده بالظبط الـ Input Validation. `validate.js` ده **موظف الاستقبال** اللي بيشيك على كل الـ papers قبل ما الطلب يوصل للـ manager (controller).

الـ pattern المستخدم هنا اسمه **Higher-Order Function** — function بتاخد schema وبترجع middleware function. زي إنك تدي موظف الاستقبال قائمة الـ requirements، وهو يعمل check ليك.

---

### 2. مثال عام بسيط

```js
// Higher-Order Function — function بتاخد schema وبترجع middleware
const validate = (schema) => {
  return (req, res, next) => {       // ← ده الـ middleware
    const { error, value } = schema.validate(req.body);
    if (error) return res.status(400).json({ message: error.message });
    req.body = value;  // الـ body المنظّف
    next();
  };
};

// الاستخدام
router.post('/register', validate(registerSchema), register);
//                        ↑ بتستدعيها بـ schema وبترجع middleware
```

---

### 3. شرح التطبيق

```js
const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true
  });
  if (!error) req.body = value;
  if (error) {
    const message = error.details.map((d) => d.message).join(', ');
    throw new ApiError(400, message);
  }
  next();
};
```

**`schema.validate()` — بيرجع إيه؟**

```js
const { error, value } = schema.validate(req.body, options);
```

- `error` — لو في validation errors، ده Joi ValidationError object. لو الـ validation نجح، `error` = `undefined`.
- `value` — الـ data المنظّفة والـ coerced. مثلاً لو الـ schema قال `Joi.number()` وإنت بعتت `"42"` (string)، الـ `value` هيحتوي على `42` (number) — Joi بيعمل type coercion.

**`abortEarly: false` — جمّع كل الأخطاء:**

Default Joi behavior: يوقف عند أول error.

بـ `abortEarly: false`: بيكمل validation على كل الـ fields ويجمع كل الأخطاء.

مثال: User بعت form بـ email غلط وـ password قصير:
- **`abortEarly: true`** → "email invalid"
- **`abortEarly: false`** → "email invalid, password must be at least 8 characters"

الـ UX بيكون أحسن مع `false` — الـ user بيعرف كل الأخطاء دفعة واحدة.

**`stripUnknown: true` — المنظّف الأمني:**

لو الـ req.body جاي بـ fields مش موجودة في الـ schema، `stripUnknown: true` بيشيلها.

مثال: User بعت:
```json
{ "email": "a@b.com", "password": "Secret123", "isAdmin": true, "role": "admin" }
```

الـ `registerSchema` عارف بس `email, firstName, lastName, dob, password`.

بعد الـ validation مع `stripUnknown: true`، `req.body` هيبقى:
```json
{ "email": "a@b.com", "password": "Secret123" }
```

`isAdmin` و `role` اتشالوا. ده بيحمي من **Mass Assignment Attack** — هجوم بيحاول فيه الـ user يحط fields حساسة في الـ body.

**`error.details.map(d => d.message).join(', ')` — جمع رسائل الأخطاء:**

`error.details` هي array من objects — كل object يمثل validation error على field معين. كل منهم عنده `.message`. الـ `.map()` بيستخرج الـ messages، الـ `.join(', ')` بيحطهم في string واحد.

مثال:
```
"email" must be a valid email, "password" length must be at least 8 characters
```

**`req.body = value` — تحديث الـ body:**

بعد الـ validation، الـ `value` هو الـ data المنظّف. بنـ override الـ `req.body` بالـ `value` المنظّف. كده الـ controller بيستقبل body نظيف وآمن ومن غير الـ fields الزيادة.

---

### 4. الربط بالصورة الكاملة

`POST /api/auth/register` مع body: `{ "email": "bad-email", "password": "123", "hack": "xss" }`

```
validate(registerSchema) middleware:
    ↓
schema.validate({ email: 'bad-email', password: '123', hack: 'xss' }, { abortEarly: false, stripUnknown: true })
    ↓
value = { email: 'bad-email', password: '123' }  ← 'hack' اتشال
error.details = [
  { message: '"email" must be a valid email' },
  { message: '"password" length must be at least 8 characters' },
  { message: '"password" with value "123" fails to match the required pattern' }
]
    ↓
message = '"email" must be a valid email, "password" length must be at least 8 characters, ...'
    ↓
throw new ApiError(400, message)
    ↓
Express 5 catches → errorHandler → res.status(400).json({ success: false, message: '...' })
```

---

### 5. العيوب اللي في الكود

**عيب 1 — بيـ validate بس `req.body`:**

الـ middleware بيشيك على `req.body` بس. بس في أحيان كتير محتاج تـ validate:
- `req.params` — زي `/:id`
- `req.query` — زي `?page=abc&limit=xyz`

لو `page=abc`، `Number('abc') = NaN`، والـ `paginate` function هتتعامل مع NaN بشكل غير متوقع. الحل:

```js
const validate = (schema, source = 'body') => (req, res, next) => {
  const { error, value } = schema.validate(req[source], { abortEarly: false, stripUnknown: true });
  if (error) throw new ApiError(400, error.details.map(d => d.message).join(', '));
  req[source] = value;
  next();
};
```

**عيب 2 — الـ Joi error messages مش كلها customized:**

بعض الـ messages زي `"firstName" is not allowed to be empty` مش friendly للـ user. الأحسن تعمل `.messages()` على كل schema لتخصيص الرسائل.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ Higher-Order Function؟ وليه `validate` بيرجع function بدل ما يكون middleware مباشرةً؟**
2. **إيه الـ Mass Assignment Attack؟ وكيف `stripUnknown: true` بيحمي منه؟**
3. **إيه الفرق بين Joi validation وـ Mongoose validation؟ وليه محتاجين الاتنين مع بعض؟**

---

## 4D — `errorHandler.js` — The Global Error Catcher

---

### 1. الكونسبت العام

تخيل إنك مدير في شركة كبيرة. كل موظف في أي مشكلة بيبعتها لك. أنت بتشوف المشكلة:
- لو مشكلة عادية ومتوقعة (operational): بتبعت رسالة واضحة للعميل
- لو مشكلة غير متوقعة (bug في الكود): بتقول للعميل "في مشكلة تقنية" وبتسجّل التفاصيل في ملف داخلي

وعندك وضع development: بتقول كل تفاصيل المشكلة عشان الفريق يحلها.
وعندك وضع production: بتقول للعميل كلام محترم وبتخبي التفاصيل الحساسة.

`errorHandler.js` ده بالظبط الـ "مدير القسم" ده.

---

### 2. مثال عام بسيط

```js
// الـ 4 arguments هم اللي بيميزوه كـ Error Handler في Express
const errorHandler = (err, req, res, next) => {
  if (process.env.NODE_ENV === 'development') {
    // في development: بعت كل شيء
    res.status(err.statusCode || 500).json({ error: err, stack: err.stack });
  } else {
    // في production: بعت بس اللي الـ user محتاجه
    res.status(err.statusCode || 500).json({ message: err.message });
  }
};
```

---

### 3. شرح التطبيق

```js
const errorHandler = (err, req, res, _next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    devError(err, res);
  } else {
    let error = { ...err, message: err.message };

    if (error.name === 'CastError') error = handleCastErrorDB(error);
    else if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    else if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
    else if (error.name === 'JsonWebTokenError') error = new ApiError(401, 'Invalid token. Please log in again!');
    else if (error.name === 'TokenExpiredError') error = new ApiError(401, 'Your token has expired! Please log in again.');

    productionError(error, res);
  }
};
module.exports = errorHandler;
```

**الـ 4-Argument Signature — `(err, req, res, next)`:**

ده أهم جزء في الـ error handler. Express بيتعرف على الـ Error Handler بس لو عنده **بالظبط 4 parameters**. لو بتعمل `(err, req, res)` من غير الـ `next`، Express مش هيتعرف عليه كـ error handler.

الـ `_next` (بـ underscore) — convention بيقول "الـ parameter ده موجود عشان Express يعرف إن ده error handler، بس مش بنستخدمه فعلاً". الـ underscore بيقول للـ linter "أنا عارف إنه مش بيتستخدم".

**`err.statusCode || 500` — Fallback:**

لو الـ error جاي من حاجة مش موقعة (زي `throw new Error('random error')`)، مش هيكون عنده `statusCode`. الـ `|| 500` بيضمن إن الـ response دايماً يبقى له status code.

**`let error = { ...err, message: err.message }` — ليه مش `err` مباشرةً؟**

لو غيّرنا `err` مباشرةً (بـ `err = handleCastErrorDB(err)`)، بنعدل على الـ original error object — ده مش clean. بنعمل copy عشان نشتغل عليها من غير ما نأثر على الـ original.

`message: err.message` بيتضاف explicitly لأن `message` في Error objects هو **non-enumerable property** — مش بيظهر في spread operator `{...err}`. لازم تحطه يدوياً.

**تسلسل الـ error classification:**

```js
if (error.name === 'CastError') ...        // MongoDB invalid ObjectId
else if (error.code === 11000) ...         // MongoDB duplicate key
else if (error.name === 'ValidationError') // Mongoose schema validation
else if (error.name === 'JsonWebTokenError') // JWT invalid signature
else if (error.name === 'TokenExpiredError') // JWT expired
// لو مش أي من دول → productionError هيشيك isOperational
```

---

### 4. الربط بالصورة الكاملة

**Scenario: User بعت request بـ invalid MongoDB ID:**

`GET /api/books/not-valid-id`:

```
Book.findById('not-valid-id')
    ↓
MongoDB: Cast to ObjectId failed for value "not-valid-id" at path "_id"
    ↓
Mongoose throws CastError { name: 'CastError', path: '_id', value: 'not-valid-id' }
    ↓
Express 5 catches it automatically
    ↓
errorHandler(castError, req, res, next)
    ↓
process.env.NODE_ENV === 'production' → classification
    ↓
error.name === 'CastError' → handleCastErrorDB(error)
    ↓
returns new ApiError(400, 'Invalid _id: not-valid-id.')
    ↓
productionError(apiError, res)
    ↓
apiError.isOperational === true
    ↓
res.status(400).json({ status: 'fail', message: 'Invalid _id: not-valid-id.' })
```

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ spread على Error object مش reliable:**

```js
let error = { ...err, message: err.message };
```

الـ spread على Error instance مش بيـ copy كل properties. مثلاً `err.name` (اللي بييجي من `Error.prototype.name`) مش بيتنسخ. فـ `error.name` ممكن يبقى `'Object'` بدل `'CastError'`. الـ checks في الـ if-else ممكن ما تشتغلش صح.

الأصح:
```js
if (err.name === 'CastError') error = handleCastErrorDB(err);
else if (err.code === 11000) error = handleDuplicateFieldsDB(err);
// ...بتشيك على err الـ original مش على الـ spread
```

**عيب 2 — مفيش logging للـ errors في production:**

الـ `productionError` بيعمل `console.error` للـ non-operational errors. بس `console.error` في production مش كافي — لازم يتم تسجيل الـ errors في نظام logging حقيقي. المفروض يستخدم الـ `logger` من `logger.js`:

```js
logger.error({ err }, 'Unhandled server error');
```

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه الـ Error Handler في Express لازم يكون عنده بالظبط 4 parameters؟ إيه اللي هيحصل لو حطيت 3 بس؟**
2. **Express 5 بيمسك الـ async errors تلقائياً — إيه الـ mechanism ده وإزاي كان بيتعمل في Express 4؟**
3. **ليه `message: err.message` بيتحط explicitly في الـ spread؟ إيه الـ non-enumerable properties؟**

---

## 4E — `authenticate.js` (protect) — JWT Verifier & User Attacher

---

### 1. الكونسبت العام

تخيل إنك بتدخل ناد رياضي. عند الباب في حارس. بيطلب منك الكارنيه (الـ token). بيشيك عليه:
1. هل الكارنيه موجود؟
2. هل التوقيع على الكارنيه حقيقي؟ (مش مزيّف)
3. هل الكارنيه لسه صالح؟ (مش منتهي)
4. هل اسمك في قائمة الأعضاء؟ (الـ user لسه موجود في الـ DB)
5. هل الكارنيه اتعمل بعد إنك غيّرت كلمة السر؟ (security check)

لو كل الشروط اتحققت: "اتفضل". لو أي حاجة غلط: "آسف، مقدرش تدخل".

ده بالظبط `authenticate.js` — بيـ verify الـ JWT وبيحط الـ user في الـ request.

---

### 2. مثال عام بسيط

```js
const protect = async (req, res, next) => {
  // 1. جيب الـ token من الـ header
  const token = req.headers.authorization?.split(' ')[1]; // 'Bearer xyz' → 'xyz'
  if (!token) throw new ApiError(401, 'Not logged in');

  // 2. تأكد من صحة الـ token
  const decoded = jwt.verify(token, process.env.JWT_SECRET); // بيرمي error لو مش valid

  // 3. تأكد إن الـ user لسه موجود في الـ DB
  const user = await User.findById(decoded._id);
  if (!user) throw new ApiError(401, 'User not found');

  // 4. حط الـ user في الـ request للـ controllers اللي بعده
  req.user = user;
  next();
};
```

---

### 3. شرح التطبيق

```js
const protect = async (req, res, next) => {
  // الخطوة 1: تحقق من وجود الـ Authorization header
  if (
    !req.headers.authorization
    || !req.headers.authorization.startsWith('Bearer')
  ) {
    throw new ApiError(401, 'you are not logged in');
  }

  // الخطوة 2: استخرج الـ token من الـ header
  const token = req.headers.authorization.split(' ')[1];
  if (!token) throw new ApiError(401, 'you are not logged in');

  // الخطوة 3: verify الـ token
  const decodedToken = verifyToken(token);

  // الخطوة 4: جيب الـ user من الـ DB
  const freshUser = await User.findById(decodedToken._id);
  if (!freshUser) throw new ApiError(401, 'user not found');

  // الخطوة 5: تأكد إنه مش غيّر الـ password بعد الـ token
  if (freshUser.changedPasswordAfter(decodedToken.iat))
    throw new ApiError(401, 'user recently changed password');

  // الخطوة 6: حط الـ user في الـ request
  req.user = freshUser;
  next();
};
```

**`Authorization: Bearer <token>` — ليه "Bearer"؟**

"Bearer" هو نوع الـ authentication scheme. البديل زي "Basic" (username:password base64). "Bearer" معناه "حامل هذا الـ token مسموح له بالدخول" — اسم تاريخي من OAuth standard. الـ `split(' ')[1]` بيشيل الـ "Bearer " ويجيب الـ token الفعلي.

**`verifyToken(token)` من `services/auth.js`:**

```js
const verifyToken = (token) => jwt.verify(token, process.env.JWT_SECRET);
```

`jwt.verify()` بيعمل حاجتين:
1. بيفك الـ token وبيتحقق إن الـ signature صح (مش حد عدّل فيه)
2. بيتحقق إن الـ token مش منتهي (بيشوف الـ `exp` claim)

لو أي منهم فشل → بيرمي error (JsonWebTokenError أو TokenExpiredError) → الـ errorHandler بيمسكهم ويحوّلهم لـ ApiError(401).

بيرجع الـ **decoded payload**:
```js
{
  _id: 'user-mongodb-id',
  email: 'user@example.com',
  role: 'user',
  iat: 1700000000, // issued at (timestamp)
  exp: 1700604800  // expires at (timestamp)
}
```

**ليه بنجيب الـ user من الـ DB تاني رغم إننا عندنا البيانات في الـ token؟**

ده سؤال مهم جداً! عندنا `_id`, `email`, `role` في الـ token — ليه ما بنستخدمهومش مباشرةً؟

**3 أسباب:**

1. **الـ user ممكن يتمسح** — لو admin مسح user من الـ DB، الـ token بتاعه لسه valid. الـ `User.findById()` هيرجع `null` → بنرفض.

2. **الـ user ممكن يغيّر دوره** — لو user اتعمله `admin` بعد ما عمل login، الـ token القديم لسه بيقول `role: 'user'`. بنجيب الـ freshUser من الـ DB عشان الـ role يبقى up-to-date.

3. **الـ `changedPasswordAfter` check** — لو user غيّر الـ password، كل الـ tokens القديمة لازم تتبطّل (security).

**`changedPasswordAfter(decodedToken.iat)` — الـ Password Change Check:**

```js
// في models/user.js
userSchema.methods.changedPasswordAfter = function (JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = Number.parseInt(
      this.passwordChangedAt.getTime() / 1000, 10
    );
    return JWTTimestamp < changedTimestamp; // true = password changed AFTER token was issued
  }
  return false; // password never changed
};
```

الـ `iat` (issued at) في الـ JWT هو timestamp بالـ seconds لحظة إنشاء الـ token. الـ `passwordChangedAt` هو timestamp لحظة آخر تغيير للـ password.

لو `iat < passwordChangedAt` → التوكن اتعمل قبل آخر تغيير password → التوكن ده مش valid تاني!

مثال: User عمل login الساعة 10، أخد token. الساعة 11 غيّر الـ password. الساعة 12 حاول يستخدم التوكن القديم:
- `iat` = 10:00 timestamp
- `passwordChangedAt` = 11:00 timestamp
- `iat < passwordChangedAt` → `true` → رفض!

**`req.user = freshUser`:**

بعد كل الـ checks، بنحط الـ user object في الـ `req`. كل middleware وـ controller بعد الـ `protect` في الـ chain بيلاقي `req.user` موجود ومعبّي. ده اللي بيخلي `req.user._id` متاح في كل controller محتاجه.

---

### 4. الربط بالصورة الكاملة

`GET /api/auth/me` مع header `Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...`:

```
protect middleware:
    ↓
req.headers.authorization = 'Bearer eyJ...' → startsWith('Bearer') ✅
    ↓
token = 'eyJ...'
    ↓
verifyToken(token) → decoded = { _id: 'abc123', email: 'user@b.com', role: 'user', iat: 1700000 }
    ↓
User.findById('abc123') → freshUser = { _id, email, role, passwordChangedAt: null, ... }
    ↓
freshUser !== null ✅
    ↓
changedPasswordAfter(1700000) → passwordChangedAt = null → false ✅
    ↓
req.user = freshUser
    ↓
next() → getUserProfile controller
    ↓
const user = await User.findById(req.user._id); // req.user متاح!
```

---

### 5. العيوب اللي في الكود

**عيب 1 — بعد الـ token verification، بتعمل DB query تاني في كل request:**

```js
const freshUser = await User.findById(decodedToken._id);
```

كل request محتاج authentication بيعمل DB query. لو عندك 1000 concurrent requests، ده 1000 DB queries إضافية. البديل: cache الـ user في Redis لمدة قصيرة (1-5 دقايق). بتوفر الـ DB queries على حساب إن الـ user data ممكن تبقى stale بشكل طفيف.

**عيب 2 — `logout` مش بيبطّل الـ token:**

```js
const logout = async (req, res) => {
  res.json(new ApiResponse(200, 'User logged out successfully'));
};
```

الـ logout مش بيعمل حاجة! الـ token لسه valid لحد ما ينتهي صلاحيته. لو حد عنده الـ token بعد الـ logout، هيقدر يستخدمه. الحل الحقيقي: **Token Blacklisting** — بتحفظ الـ token في Redis كـ "blacklisted" وفي الـ `protect` بتشيك إنه مش في القائمة السوداء.

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه بنجيب الـ user من الـ DB في كل request رغم إن معلوماته موجودة في الـ JWT payload؟**
2. **إيه الـ `iat` claim في الـ JWT وكيف بيستخدمه `changedPasswordAfter`؟**
3. **إيه مشكلة الـ logout الحالي؟ وإيه الحل الصحيح؟**

---

## 4F — `authorize.js` (restrictTo) — Role-Based Access Control

---

### 1. الكونسبت العام

تخيل إنك في شركة. في أبواب مختلفة:
- باب غرفة الـ CEO — بس للمدير العام
- باب غرفة المبيعات — للـ sales team فقط
- باب الاستقبال — للكل

`restrictTo` ده **نظام الباج والصلاحيات** — بيشوف الـ badge بتاعك (role) ويقرر هل مسموحلك تدخل.

الـ **Closure Pattern** المستخدم هنا: بتقول "مسموح لمين" مرة واحدة، وبيرجعلك function تفتّش عليها.

---

### 2. مثال عام بسيط

```js
// Closure Pattern — بتعمل middleware بناءً على الـ roles المسموح بيها
const restrictTo = (...roles) => {            // ['admin', 'moderator']
  return (req, res, next) => {               // ← ده الـ middleware الفعلي
    if (!roles.includes(req.user.role)) {    // req.user بييجي من protect
      throw new ApiError(403, 'Not allowed');
    }
    next();
  };
};
```

---

### 3. شرح التطبيق

```js
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      throw new ApiError(
        403,
        'you do not have permission to perform this action'
      );
    }
    next();
  };
};
```

**`...roles` — Rest Parameters:**

بيسمح بتمرير أي عدد من الـ roles:
```js
restrictTo('admin')                    // roles = ['admin']
restrictTo('admin', 'moderator')       // roles = ['admin', 'moderator']
restrictTo('admin', 'seller', 'super') // roles = ['admin', 'seller', 'super']
```

الـ rest parameters بتحوّل كل الـ arguments في array.

**`roles.includes(req.user.role)` — الـ Check:**

الـ `roles` array لا تزال accessible جوّا الـ returned function بسبب الـ **Closure** — الـ function بتتذكر الـ variables اللي في الـ scope اللي اتعملت فيه حتى لو هو انتهى.

`req.user.role` جاي من الـ `protect` middleware اللي شغّل قبله. لو `protect` ما شغّلش قبل `restrictTo`، `req.user` هيبقى `undefined` → `undefined.role` → crash!

**الفرق بين 401 و 403:**

- **401 Unauthorized** — "مش عارف أنت مين. عرّف نفسك." (Not authenticated)
- **403 Forbidden** — "أنا عارف أنت مين، بس مش مسموحلك." (Not authorized)

الـ `restrictTo` بيستخدم 403 لأن الـ user معروف (الـ `protect` اشتغل وجاب `req.user`)، بس ما عندوش الصلاحية.

---

### 4. الربط بالصورة الكاملة

`DELETE /api/categories/:id` (admin only):

```
protect middleware:
    ↓
token valid, user found → req.user = { _id: '...', role: 'user', ... }
    ↓
next()
    ↓
restrictTo('admin') middleware:
    ↓
roles = ['admin']
    ↓
roles.includes(req.user.role) → roles.includes('user') → false
    ↓
throw new ApiError(403, 'you do not have permission...')
    ↓
errorHandler → res.status(403).json({ status: 'fail', message: '...' })
```

لو user عنده role = 'admin':
```
roles.includes('admin') → true
    ↓
next() → deleteCategory controller
```

---

### 5. العيوب اللي في الكود

**عيب 1 — الـ `restrictTo` دايماً يحتاج `protect` قبله — مش enforced:**

لو developer نسي يحط `protect` قبل `restrictTo`:
```js
router.delete('/:id', restrictTo('admin'), deleteCategory); // protect ناسية!
```

`req.user` هيبقى `undefined` → `req.user.role` → TypeError crash. الأحسن إن `restrictTo` نفسها تتحقق:

```js
if (!req.user) throw new ApiError(401, 'Authentication required');
```

**عيب 2 — مفيش granular permissions:**

الـ system عنده بس `'user'` و `'admin'`. في applications حقيقية، ممكن تحتاج permissions أدق — زي `can:edit-books` أو `can:view-orders`. الـ RBAC (Role-Based Access Control) الحالي بسيط — في production لازم يتطوّر لـ ABAC (Attribute-Based Access Control) أو Permission-based system.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ Closure في JavaScript؟ وكيف `restrictTo` بيستخدمه؟**
2. **إيه الفرق بين 401 و 403 HTTP status codes؟ وإمتى نستخدم كل واحد؟**
3. **ليه `restrictTo` لازم يكون بعد `protect` في الـ middleware chain؟ إيه اللي هيحصل لو انعكسوا؟**

---

---

# Topic 5 — The Auth Module (Your Main Area 🔥)

## `services/auth.js` + `models/user.js` + `controllers/auth.js` + `routes/auth.js` + `validations/auth.js`

---

## 5A — `services/auth.js` — JWT Generation & Verification

---

### 1. الكونسبت العام

الـ **JWT (JSON Web Token)** زي **تذكرة ملاهي**. لما بتشتري التذكرة، بيكتبوا عليها: اسمك، النوع (VIP أو عادي)، وتاريخ الانتهاء. وبيختموها بختم خاص.

لما تدخل أي لعبة، بيشوفوا التذكرة:
- هل الختم حقيقي؟ (signature verification)
- هل التذكرة لسه صالحة؟ (expiry check)
- إيه صلاحياتك؟ (role)

من غير ما يرجعوا ويسألوا شباك التذاكر كل مرة! ده الـ **Stateless Authentication** — الـ server مش محتاج يخزن الـ sessions.

---

### 2. مثال عام بسيط

```js
const jwt = require('jsonwebtoken');

// إنشاء token — زي "طبع التذكرة"
const token = jwt.sign(
  { _id: user._id, role: user.role },  // payload — المعلومات جوه التذكرة
  'my-super-secret',                   // secret — الـ ختم الخاص
  { expiresIn: '7d' }                  // بينتهي بعد 7 أيام
);

// التحقق من token — زي "فحص التذكرة"
const decoded = jwt.verify(token, 'my-super-secret');
// decoded = { _id: '...', role: 'user', iat: 1700000, exp: 1700604800 }
```

---

### 3. شرح التطبيق

```js
const generateToken = (user) =>
  jwt.sign(
    { _id: user._id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );

const verifyToken = (token) =>
  jwt.verify(token, process.env.JWT_SECRET);

module.exports = { generateToken, verifyToken };
```

**إيه اللي بنحطه في الـ JWT Payload وليه؟**

```js
{ _id: user._id, email: user.email, role: user.role }
```

- `_id` — عشان نعرف مين الـ user بدون DB query في بعض الحالات
- `email` — معلومة هوية إضافية
- `role` — عشان الـ frontend يعرف يخفي/يظهر features بناءً عليه

**مش بنحط:**
- `password` — ده سر، مش ياخد مكانه في payload
- معلومات حساسة زيادة — الـ payload بيتـ decode بدون secret (مش بيتـ verify) — أي حد يقدر يقراه!

**الـ JWT Structure (3 parts مفصولة بنقاط):**

```
eyJhbGciOiJIUzI1NiJ9.eyJfaWQiOiJhYmMifQ.xyz123
    ↑                      ↑                  ↑
  Header (base64)      Payload (base64)   Signature (HMAC)
```

الـ Header والـ Payload مجرد base64 — أي حد يقدر يقرأهم. الـ Signature هو اللي بيثبت إن الـ payload ما اتغيّرش.

**`JWT_SECRET` — الـ ختم الخاص:**

الـ `JWT_SECRET` هو المفتاح اللي بيتعمل بيه الـ signature. لو حد عرفه، يقدر يعمل tokens مزيّفة بأي user ID أو role. لازم:
- يكون طويل ومعقد (min 32 chars)
- مش يتشاركش ومش يتحطش في الكود
- يتغيّر لو اتكشف

**`JWT_EXPIRES_IN: '7d'` — ليه expiry مهمة؟**

الـ JWTs مش بتتخزن في الـ server (stateless). لو token اتسرّق، مش تقدر تبطّله! الـ expiry بيضمن إن الـ damage محدود — بعد 7 أيام الـ token بيبقى useless.

---

### 4. الربط بالصورة الكاملة

**Login flow:**
```
POST /api/auth/login
    ↓
login controller:
    ↓
User.findOne({ email }).select('+password')
    ↓
user.correctPassword(password, user.password) → bcrypt.compare
    ↓
generateToken(user) → jwt.sign({ _id, email, role }, JWT_SECRET, { expiresIn })
    ↓
res.json(new ApiResponse(200, 'User logged in', { token }))
```

**Authenticated request:**
```
GET /api/auth/me with Authorization: Bearer <token>
    ↓
protect middleware:
    ↓
verifyToken(token) → jwt.verify(token, JWT_SECRET)
    ↓
decoded = { _id: '...', email: '...', role: '...', iat: ..., exp: ... }
    ↓
User.findById(decoded._id) → freshUser
    ↓
req.user = freshUser
    ↓
getUserProfile controller
```

---

### 5. العيوب اللي في الكود

**عيب 1 — `JWT_SECRET` من غير minimum length validation:**

`process.env.JWT_SECRET` ممكن يكون `'abc'` (3 حروف) ولو حد نسي يحطها في الـ `.env`. الـ JWT هيتعمل بس هيكون insecure. المفروض:

```js
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}
```

**عيب 2 — مفيش Refresh Token mechanism:**

الـ access token بتانته 7 أيام. كل 7 أيام الـ user محتاج يعمل login تاني. الـ standard practice هو:
- **Access Token**: قصير (15 دقيقة)
- **Refresh Token**: طويل (30 يوم)، بيتخزن في الـ DB

بكده الـ access token لو اتسرّق، بينتهي بسرعة. والـ refresh token ممكن يتبطّل (revoked) في الـ DB.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ JWT وإيه الـ 3 parts بتاعته؟ هل الـ payload سري؟**
2. **إيه الـ Stateless Authentication وليه أفضل من الـ Sessions في بعض الحالات؟**
3. **إيه مشكلة الـ JWTs في الـ logout وكيف الـ Token Blacklisting بتحلها؟**

---

## 5B — `models/user.js` — The User Schema (Your Masterpiece)

---

### 1. الكونسبت العام

الـ User Model ده **أهم model في المشروع** — كل حاجة تانية بتعتمد عليه. وفيه 4 concepts مهمة:

1. **`select: false` على الـ password** — بتخفي الـ password في كل queries
2. **`pre('save')` hook** — بيعمل hash للـ password تلقائياً قبل الحفظ
3. **Instance Methods** — functions بتتعمل على كل user document
4. **`passwordChangedAt` check** — security check ضد الـ token reuse بعد تغيير الـ password

---

### 2. مثال عام بسيط

```js
const userSchema = new mongoose.Schema({
  password: {
    type: String,
    select: false  // ← مش بييجي في queries عادية
  }
});

// بيشتغل تلقائياً قبل save
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return; // بس لو الـ password اتغيّر
  this.password = await bcrypt.hash(this.password, 12);
});
```

---

### 3. شرح التطبيق الكامل

**الـ Email Field:**

```js
email: {
  type: String,
  index: true,           // ← index عشان البحث بيه سريع
  required: [true, 'email is required'],
  unique: true,
  lowercase: true,       // ← بيحوّل لـ lowercase قبل الحفظ
  validate: [validator.isEmail, 'please provide a valid email']
}
```

`index: true` — عشان `User.findOne({ email })` بتتعمل في كل login request. من غير index، MongoDB بيعمل full collection scan على كل users للدور على email واحد. مع index، direct lookup.

`lowercase: true` — `"Ahmed@Gmail.COM"` بيتخزن كـ `"ahmed@gmail.com"`. بيمنع duplicates من case differences.

`validate: [validator.isEmail, ...]` — Mongoose custom validator. الـ `validator` library بتتحقق إن الـ email format صح. ده Mongoose-level validation (layer تاني بعد Joi).

**الـ Password Field:**

```js
password: {
  type: String,
  required: [true, 'password is required'],
  minlength: 8,
  maxlength: 50,
  select: false  // ← مهم جداً!
}
```

`select: false` — الـ password مش بييجي في أي query عادية:

```js
User.findOne({ email })              // password مش موجود
User.findById(id)                    // password مش موجود
User.findOne({ email }).select('+password')  // password موجود! ← بتطلبه صراحة
```

ده security feature مهم — حتى لو نسيت تحذف الـ password من الـ response، مش هيكون موجود أصلاً.

**`pre('save')` Hook — Bcrypt Hashing:**

```js
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  this.password = await bcrypt.hash(this.password, 12);
});
```

الـ `pre('save')` بيشتغل قبل أي `save()` call — سواء كانت `User.create()` أو `user.save()`.

`this.isModified('password')` — لو بتعدّل اسم الـ user مثلاً (مش الـ password)، الـ hook بيشتغل (لأنه `pre save`)، بس الـ `isModified('password')` بيرجع `false` → الـ `return` بيمنع إعادة الـ hash. من غير الـ guard ده، كل مرة تعدّل أي field في الـ user، الـ password بيتـ hash تاني على نفسه → بيتخرب!

`bcrypt.hash(password, 12)`:
- `12` هو الـ **salt rounds** — عدد المرات اللي بيعمل فيها bcrypt الـ hashing operation
- كل +1 بيضاعف الوقت. `12 rounds` بياخد حوالي 250ms — expensive by design
- ده بيجعل brute force attacks غير عملية لأن كل محاولة بتاخد وقت

**`correctPassword` Instance Method:**

```js
userSchema.methods.correctPassword = async function (candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
};
```

`bcrypt.compare()` — بياخد الـ plain text password وبيقارنه بالـ hashed version. ليه ما بتقارنيش عادي؟ لأن الـ bcrypt hash بيحتوي على **salt** (random string مضافة للـ password قبل الـ hash). كل مرة تعمل hash لنفس الكلمة، النتيجة مختلفة! `bcrypt.compare` بيعرف يتعامل مع الـ salt.

نلاحظ إن الـ method بتاخد `userPassword` كـ argument بدل ما تستخدم `this.password`. ليه؟ لأن `select: false` على الـ password field — `this.password` ممكن يبقى `undefined` لو الـ document ماتجبلوش بـ `select('+password')`. بتمرر الـ password explicitly عشان تتأكد إنه موجود.

**`changedPasswordAfter` Instance Method:**

```js
userSchema.methods.changedPasswordAfter = function (JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = Number.parseInt(
      this.passwordChangedAt.getTime() / 1000, 10
    );
    return JWTTimestamp < changedTimestamp;
  }
  return false;
};
```

`this.passwordChangedAt.getTime()` — بيرجع milliseconds. `/1000` → seconds. الـ `JWTTimestamp` (الـ `iat`) هو كمان بالـ seconds. المقارنة لازم تكون بنفس الوحدة.

`Number.parseInt(..., 10)` — الـ `10` هو الـ radix (base 10 = decimal). بيمنع JavaScript من إنه يفسّر الرقم كـ octal لو بدأ بـ 0.

---

### 4. الربط بالصورة الكاملة

**Registration flow:**
```
POST /api/auth/register
    ↓
validate(registerSchema) → Joi validates email, password pattern, etc.
    ↓
register controller:
User.findOne({ email }) → existing? → ApiError(409)
    ↓
User.create({ email, firstName, lastName, dob, password })
    ↓
pre('save') hook fires:
  - isModified('password') → true (newly created)
  - bcrypt.hash('Secret123', 12) → '$2b$12$...'
  - this.password = '$2b$12$...'
    ↓
User document saved in MongoDB with HASHED password
    ↓
newUser.toObject() → delete userObj.password (عشان مش يتبعت للـ client)
    ↓
res.status(201).json(new ApiResponse(201, 'User created', userObj))
```

---

### 5. العيوب اللي في الكود

**عيب 1 — `isVerified` field موجود بس مفيش email verification flow:**

```js
isVerified: { type: Boolean, default: false }
```

الـ field موجود في الـ schema، بس مفيش endpoint لـ email verification. يعني كل الـ users عندهم `isVerified: false` دايماً. الـ `protect` middleware مش بيشيك عليه. الـ field ده "dead code" في الوضع الحالي.

**عيب 2 — `updateUserProfile` بيسمح بتحديث أي field:**

```js
const updateUserProfile = async (req, res) => {
  const user = await User.findByIdAndUpdate(req.user._id, req.body, {
    new: true,
    runValidators: true
  });
};
```

الـ `req.body` بعد `validate(updateProfileSchema)` بيحتوي بس على `firstName`, `lastName`, `dob` — ده كويس. بس لو حد بعت `{ role: 'admin' }` وبيطلع من الـ Joi validation (ممكن لو `stripUnknown` مش شغّال بشكل صح)، `findByIdAndUpdate` هيحدّث الـ role! الأحسن تحدد الـ fields صراحةً:

```js
const { firstName, lastName, dob } = req.body;
const user = await User.findByIdAndUpdate(req.user._id, { firstName, lastName, dob }, { new: true, runValidators: true });
```

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ `select: false` في Mongoose؟ وكيف بتطلب الـ field ده بعد ما يتخبى؟**
2. **ليه `pre('save')` hook محتاج الـ guard `if (!this.isModified('password')) return`؟ إيه اللي هيحصل من غيره؟**
3. **ليه `bcrypt.compare()` وليس مجرد مقارنة string عادية؟ إيه دور الـ salt في الـ bcrypt؟**

---

## 5C — `controllers/auth.js` — Register, Login, Logout, Profile

---

### 1. الكونسبت العام

الـ controllers ده زي **موظفي الخدمة** — كل موظف متخصص في حاجة:
- موظف التسجيل: بياخد بيانات user جديد ويسجّله
- موظف الدخول: بيتحقق من الـ credentials وبيدي token
- موظف بيانات الـ profile: بيجيب بيانات الـ user

الـ controller مش بيعمل logic معقدة — بيـ delegate للـ model وللـ service. ده الـ **Thin Controller** pattern.

---

### 2. مثال عام بسيط

```js
// Thin Controller — بيـ orchestrate مش بيعمل business logic
const register = async (req, res) => {
  const existing = await User.findOne({ email: req.body.email }); // model
  if (existing) throw new ApiError(409, 'Email in use');           // guard

  const user = await User.create(req.body);                       // model
  res.status(201).json(new ApiResponse(201, 'Created', user));    // response
};
```

---

### 3. شرح التطبيق

**`register` controller:**

```js
const register = async (req, res) => {
  const { email, firstName, lastName, dob, password } = req.body;

  if (await User.findOne({ email }))
    throw new ApiError(409, 'Email already in use');

  const newUser = await User.create({ email, firstName, lastName, dob, password });
  const userObj = newUser.toObject();
  delete userObj.password;

  res.status(201).json(new ApiResponse(201, 'User created successfully', userObj));
};
```

`User.findOne({ email })` في `if` expression مباشرةً — elegant بس بيحتاج تفكير. الـ `await` بييجي بالـ user object (truthy) أو `null` (falsy). لو الـ user موجود → throw.

`newUser.toObject()` — بيحوّل الـ Mongoose document لـ plain JS object. لازم نعمله قبل `delete userObj.password` لأن Mongoose documents مش بسهل تعدّل عليهم مباشرةً.

`delete userObj.password` — بيشيل الـ password من الـ object قبل ما يتبعت للـ client. بالرغم من `select: false` على الـ schema، الـ `User.create()` بيرجع document بيحتوي على الـ password (عشان هو نفسه اللي عمله). لازم تحذفه يدوياً.

**`login` controller:**

```js
const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) throw new ApiError(400, 'please provide email and password');

  const user = await User.findOne({ email }).select('+password');

  if (!user || !(await user.correctPassword(password, user.password)))
    throw new ApiError(401, 'incorrect email or password');

  const token = generateToken(user);
  res.json(new ApiResponse(200, 'User logged in successfully', { token }));
};
```

`if (!email || !password)` — هذا الـ check redundant مع Joi validation (الـ loginSchema بتطلب email وـ password). بس defensive programming مش بيضر.

`.select('+password')` — عشان نعمل `bcrypt.compare` لازم نجيب الـ password. الـ `+` قبل الاسم بيقول "جيب الـ field ده حتى لو هو `select: false`".

`if (!user || !(await user.correctPassword(password, user.password)))` — بنجمع الـ حالتين (user مش موجود + password غلط) في رسالة واحدة. ليه؟ **Security** — لو قلنا "email مش موجود" أو "password غلط" بشكل منفصل، بنساعد الـ attacker يعرف emails موجودة في النظام.

**`logout` controller:**

```js
const logout = async (req, res) => {
  res.json(new ApiResponse(200, 'User logged out successfully'));
};
```

Stateless JWT logout — الـ server مش بيعمل حاجة. الـ client هو المسؤول عن حذف الـ token من الـ localStorage. هذا هو الـ limitation الأساسي للـ JWT.

**`getUserProfile` controller:**

```js
const getUserProfile = async (req, res) => {
  const user = await User.findById(req.user._id);
  if (!user) throw new ApiError(404, 'user not found');
  res.json(new ApiResponse(200, 'User retrieved successfully', user));
};
```

ملاحظة: `req.user` موجود بالفعل من الـ `protect` middleware. الـ DB query هنا redundant — الـ `req.user` نفسه هو الـ freshUser. ممكن نكتب ببساطة:
```js
res.json(new ApiResponse(200, 'User retrieved successfully', req.user));
```

---

### 4. الربط بالصورة الكاملة

**Full Login Flow:**

```
POST /api/auth/login { email: "a@b.com", password: "Secret123" }
    ↓
validate(loginSchema) → email valid, password present ✅
    ↓
login controller:
    ↓
User.findOne({ email: 'a@b.com' }).select('+password')
  → { _id: 'abc', email: 'a@b.com', password: '$2b$12$...', role: 'user' }
    ↓
user.correctPassword('Secret123', '$2b$12$...') → bcrypt.compare → true ✅
    ↓
generateToken(user) → jwt.sign({ _id: 'abc', email: 'a@b.com', role: 'user' }, SECRET, { expiresIn: '7d' })
  → 'eyJhbGciOiJIUzI1NiJ9...'
    ↓
res.json(new ApiResponse(200, 'User logged in', { token: 'eyJ...' }))
```

---

### 5. العيوب اللي في الكود

**عيب 1 — `getUserProfile` بيعمل DB query redundant:**

`req.user` موجود بالفعل من الـ `protect` middleware وهو fresh data. الـ extra `User.findById(req.user._id)` ده extra DB round trip من غير فايدة.

**عيب 2 — `updateUserProfile` بيمرر `req.body` لـ `findByIdAndUpdate` مباشرةً:**

```js
const user = await User.findByIdAndUpdate(req.user._id, req.body, { new: true, runValidators: true });
```

حتى مع `validate(updateProfileSchema)`، الأحسن تكون explicit:
```js
const { firstName, lastName, dob } = req.body;
const user = await User.findByIdAndUpdate(req.user._id, { firstName, lastName, dob }, ...);
```

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه بنجمع رسالة "email غلط" و"password غلط" في رسالة واحدة؟ إيه الـ security reason؟**
2. **`newUser.toObject()` ثم `delete userObj.password` — ليه مش نقدر نعمل `delete newUser.password` مباشرةً؟**
3. **الـ logout controller فارغ تقريباً — ده correct behavior ولا فيه مشكلة؟ وإيه الحل الأفضل؟**

---

## 5D — `routes/auth.js` — Middleware Chaining on Routes

---

### 1. الكونسبت العام

الـ routes ملف زي **لوحة التوجيه في المبنى** — بيحدد: هذا الطريق يوصّل لمين؟ وقبل ما توصل، هل محتاج تعدي على الـ security check؟

---

### 2. مثال عام بسيط

```js
// بدون middleware — أي حد يوصل للـ controller
router.get('/me', getUserProfile);

// مع middleware chain — محتاج تـ authenticate الأول
router.get('/me', authenticate, getUserProfile);
//                  ↑ step 1        ↑ step 2
```

---

### 3. شرح التطبيق

```js
router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);
router.post('/logout', authenticate, logout);
router.get('/me', authenticate, getUserProfile);
router.patch('/profile', authenticate, validate(updateProfileSchema), updateUserProfile);
```

**الـ Middleware Chain — بتشتغل بالترتيب:**

`router.patch('/profile', authenticate, validate(updateProfileSchema), updateUserProfile)`:

1. Request جاي لـ `PATCH /api/auth/profile`
2. `authenticate` — تحقق من الـ token → attach `req.user`
3. `validate(updateProfileSchema)` — تحقق من الـ body
4. `updateUserProfile` — نفّذ الـ update

لو `authenticate` فشل → الـ chain تتوقف. مش هيوصل للـ validate ولا للـ controller.

لو `validate` فشل → الـ chain تتوقف. مش هيوصل للـ controller.

**ترتيب مهم: `authenticate` قبل `validate`:**

في حالة `logout` و `me` و `profile`:
- `authenticate` الأول: بيتأكد إنك logged in قبل أي validation
- `validate` التاني: بيـ validate الـ body

ده الترتيب الصح. في `routes/book.js` في review route الترتيب معكوس — ده bug ذكرناه في Part 2.

---

### 4. الربط بالصورة الكاملة

```
PATCH /api/auth/profile
  Authorization: Bearer eyJ...
  Body: { "firstName": "Ahmed" }
    ↓
app.js → routes/index.js → routes/auth.js
    ↓
authenticate middleware:
  - verify token ✅
  - find user ✅
  - req.user = freshUser
    ↓
validate(updateProfileSchema):
  - { firstName: 'Ahmed' } → valid, min(1) check passes ✅
  - req.body = { firstName: 'ahmed' } (lowercase via Mongoose on save)
    ↓
updateUserProfile:
  - User.findByIdAndUpdate(req.user._id, { firstName: 'Ahmed' }, { new: true, runValidators: true })
  - returns updated user
    ↓
res.json(new ApiResponse(200, 'User updated successfully', user))
```

---

### 5. العيوب اللي في الكود

**عيب 1 — مفيش route لـ `changePassword`:**

مفيش endpoint لتغيير الـ password. الـ `updateUserProfile` مش بيسمح بتغيير الـ password (عشان `updateProfileSchema` مش فيها `password` field). ده يعني لو user عايز يغيّر الـ password، مفيش طريقة! ده missing feature.

**عيب 2 — مفيش rate limiting خاص على الـ `/login` route:**

الـ global rate limiter بيسمح بـ 100 request/minute لكل IP. بس الـ `/login` route محتاج rate limiting أصعب (مثلاً 5 محاولات/دقيقة) عشان تحمي من brute force attacks على الـ passwords. الـ global limit مش كافي.

---

### 6. أسئلة انترفيو "جونيور"

1. **إيه الـ Middleware Chain وإزاي Express بينفّذها؟ إيه اللي بيحصل لو middleware استدعت `next(err)` بدل `next()`؟**
2. **ليه الـ `/register` و `/login` routes ماعندهاش `authenticate` middleware؟**
3. **لو خلطنا ترتيب `authenticate` و `validate` في `router.patch('/profile', validate(...), authenticate, ...)`، إيه المشكلة؟**

---

## 5E — `validations/auth.js` — Joi Schemas for Auth

---

### 1. الكونسبت العام

الـ validation schemas دي زي **عقد الشروط** اللي بتعمله مع الـ client: "لو عايز تسجّل، لازم email حقيقي، password فيه uppercase وـ lowercase ورقم، وكل الـ fields الإلزامية موجودة."

Joi بيسمح بتعريف هذه الشروط بشكل declarative — بدل ما تكتب `if` statements كتير.

---

### 2. مثال عام بسيط

```js
const Joi = require('joi');

const schema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required()
});

const { error } = schema.validate({ email: 'bad', password: '123' });
// error.details = [
//   { message: '"email" must be a valid email' },
//   { message: '"password" length must be at least 8 characters' }
// ]
```

---

### 3. شرح التطبيق

**`registerSchema`:**

```js
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  firstName: Joi.string().min(2).max(50).required(),
  lastName: Joi.string().min(2).max(50).required(),
  dob: Joi.date()
    .max('now')
    .required()
    .messages({ 'date.max': 'Date of birth must be in the past' }),
  password: Joi.string()
    .min(8)
    .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .required()
    .messages({
      'string.pattern.base': 'Password needs uppercase, lowercase, and a number'
    })
});
```

`Joi.string().email()` — بيستخدم `isemail` library داخلياً للتحقق من format الـ email.

`Joi.date().max('now')` — `'now'` هو special keyword في Joi بيعني "الوقت الحالي". بيتأكد إن تاريخ الميلاد في الماضي.

`.messages({ 'date.max': '...' })` — بيـ override الـ error message الـ default للـ `date.max` validation. الـ key `'date.max'` هو اسم الـ rule في Joi.

`/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/` — Regex Pattern:
- `(?=.*[a-z])` — lookahead: لازم في lowercase letter واحدة على الأقل
- `(?=.*[A-Z])` — lookahead: لازم في uppercase letter واحدة على الأقل
- `(?=.*\d)` — lookahead: لازم في digit واحد على الأقل

الـ `.messages({ 'string.pattern.base': '...' })` بيحط رسالة human-readable بدل الـ regex في رسالة الـ error.

**`loginSchema`:**

```js
const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});
```

مش بيـ validate password pattern في الـ login! ليه؟ **Security through obscurity** — مش عايز تقول للـ hacker "الـ password لازم يكون كذا" عشان يساعده يخمّن. كل اللي يعرفه: "password مطلوب".

**`updateProfileSchema`:**

```js
const updateProfileSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName: Joi.string().min(2).max(50),
  dob: Joi.date().max('now')
}).min(1);
```

`.min(1)` على الـ object — مش على string! معناها "الـ object لازم يحتوي على field واحدة على الأقل". بيمنع PATCH request فارغة `{}` — ليه بتبعت update من غير حاجة تعدّلها؟

---

### 4. الربط بالصورة الكاملة

```
POST /api/auth/register { email: "test", password: "123", dob: "2099-01-01" }
    ↓
validate(registerSchema):
    ↓
schema.validate(body, { abortEarly: false, stripUnknown: true })
    ↓
errors = [
  '"email" must be a valid email',
  '"firstName" is required',
  '"lastName" is required',
  '"dob" must be less than or equal to "now"',
  '"password" length must be at least 8 characters',
  'Password needs uppercase, lowercase, and a number'
]
    ↓
throw new ApiError(400, '"email" must be a valid email, "firstName" is required, ...')
    ↓
errorHandler → res.status(400).json({ success: false, message: '...' })
```

---

### 5. العيوب اللي في الكود

**عيب 1 — مفيش `confirmPassword` validation:**

في معظم registration forms، بتطلب من الـ user يكتب الـ password مرتين للتأكيد. الكود مش بيعمل ده. Joi بيدعم ده بـ `.valid(Joi.ref('password'))`.

**عيب 2 — `updateProfileSchema` بيسمح بتحديث الـ `dob` بس ما بيمنعش تحديثات متكررة:**

مفيش business rule بيمنع user من إنه يغيّر تاريخ ميلاده 100 مرة. في بعض applications، ده restricted.

---

### 6. أسئلة انترفيو "جونيور"

1. **ليه `loginSchema` مش بتـ validate password pattern رغم إن `registerSchema` بتعمله؟**
2. **إيه الـ `.min(1)` على الـ Joi object schema؟ وكيف بتختلف عن `.min(1)` على الـ string؟**
3. **إيه الـ Regex Lookahead؟ واشرح الـ pattern `/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/` خطوة بخطوة.**

---

---

# 🎯 ملخص Part 1 — Quick Reference

## أهم الـ Patterns المستخدمة

| Pattern | الـ File | الشرح |
|---------|---------|-------|
| App Factory | `app.js` | بتـ export الـ app من غير ما تشغّله |
| Serverless Handler | `index.js` | handler wrapper لـ Vercel مع DB connection caching |
| require.main === module | `index.js` | بيفرق بين local run وـ module import |
| Connection Caching | `index.js` | `readyState >= 1` check لمنع multiple connections |
| Custom Error Class | `ApiError.js` | extends Error مع statusCode وـ isOperational |
| Standardized Response | `ApiResponse.js` | consistent JSON shape لكل responses |
| Error Classification | `errorHelpers.js` | تحويل Mongoose/JWT errors لـ ApiErrors |
| Parallel DB Queries | `pagination.js` | `Promise.all` لـ find + countDocuments |
| Higher-Order Function | `validate.js` | `validate(schema)` بترجع middleware |
| Mass Assignment Protection | `validate.js` | `stripUnknown: true` |
| Structured Logging | `logger.js` | Pino JSON logging مع dev/prod transport |
| In-Memory Rate Limiting | `rateLimit.js` | Map + sliding window + cleanup interval |
| JWT Stateless Auth | `services/auth.js` | generateToken + verifyToken |
| select: false | `models/user.js` | password hidden by default |
| pre('save') Hook | `models/user.js` | bcrypt hashing تلقائي |
| Instance Methods | `models/user.js` | correctPassword + changedPasswordAfter |
| Closure for Middleware | `authorize.js` | `restrictTo(...roles)` returns middleware |
| Token Freshness Check | `authenticate.js` | `changedPasswordAfter(iat)` |
| Thin Controller | `controllers/auth.js` | delegates to model + service |
| Middleware Chain | `routes/auth.js` | `authenticate, validate, controller` |

---

## أهم الـ Security Layers بالترتيب

```
Request
    ↓
1. CORS (app.js)                 — منع unauthorized origins
    ↓
2. Rate Limiting (rateLimit.js)  — منع abuse وـ DDoS
    ↓
3. Body Parsing (express.json)   — تحويل raw body لـ JS object
    ↓
4. Input Validation (validate.js) — Joi schema validation + stripUnknown
    ↓
5. Authentication (authenticate.js) — JWT verification + user freshness
    ↓
6. Authorization (authorize.js)  — Role check
    ↓
7. Controller                    — Business logic
    ↓
8. Mongoose Validation           — Schema-level DB validation (last resort)
    ↓
9. Error Handler (errorHandler.js) — Global error catching + formatting
    ↓
Response
```

---

## أسرع الـ Bugs اللي تتكلم عنها في الـ Interview

| Bug | الـ File | الأثر |
|-----|---------|-------|
| `errorHandler` مسجّل مرتين | `app.js` + `index.js` | Redundant, potential double response |
| CORS origin hardcoded | `app.js` | Production frontend ممكن يتحجب |
| Rate limiter في memory | `rateLimit.js` | مش شغّال مع horizontal scaling |
| `validate` بيـ validate body بس | `validate.js` | params وـ query غير validated |
| `logout` stateless | `controllers/auth.js` | Token لسه valid بعد logout |
| `getUserProfile` extra DB query | `controllers/auth.js` | `req.user` موجود بالفعل |
| `isVerified` field بلا flow | `models/user.js` | Dead code |
| مفيش `changePassword` endpoint | `routes/auth.js` | Missing critical feature |
| مفيش specific rate limit على `/login` | `routes/auth.js` | Vulnerable to brute force |
| `spread` على Error object غير reliable | `errorHandler.js` | `name` property ممكن تضيع |

---

> 🔥 **Part 1 خلص! كل topic فيه الـ 6 steps كاملين — الكونسبت، المثال، التطبيق، الربط، العيوب، والأسئلة.**
> **جاهز للانترفيو!** 🚀
