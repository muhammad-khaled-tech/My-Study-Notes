```
# 📚 دليل المشروع الشامل — Bookstore REST API
### من الفصل الأول للفصل الخامس (Chapters 1 → 24)
#### بقلم: Senior Backend Architect | لـ: Junior Developer قبل الـ Discussion

---

> **🎯 ملاحظة للـ Discussion:** أنت بنيت الـ Auth Module، الـ Middlewares، الـ Utilities، والـ DB Config. هتتسأل بشكل أساسي عن القرارات اللي اتخذتها في الأجزاء دي. الـ Guide ده مبني على ده.

---

# 🏛️ الفصل الأول: المدخل والبنية

---

## Chapter 01 — Project Architecture: الصورة الكاملة من فوق

---

### 1. الكونسبت العام (The Story)

تخيل إنك بتبني عمارة سكنية كبيرة. مش ممكن الناس تدخل العمارة وتوصل لشقتها في خطوة واحدة. لازم يعدوا على:

1. **الباب الخارجي (البواب)** — بيسمح أو بيمنع الدخول
2. **الريسيبشن** — بيسجل مين داخل وإمتى
3. **الأسانسير** — بيوديك للدور الصح
4. **باب الشقة** — بيتأكد إنك صاحب الشقة دي فعلاً
5. **الشقة نفسها** — اللي فيها كل حاجة جوزت تشوفها

المشروع ده بالظبط نفس الفكرة. أي Request بتيجي من المتصفح لازم تعدي على **طبقات محددة بالترتيب** قبل ما توصل لـ Database وترجع بـ Response.

الطبقات دي اسمها **Layered Architecture**، وده أكثر Pattern استخدام في Node.js Enterprise Projects.

```

HTTP Request │ ▼ ┌─────────────────┐ │ index.js │ ← Entry Point: DB Connection + Server Start └────────┬────────┘ │ ▼ ┌─────────────────┐ │ app.js │ ← Express App: Global Middlewares + Routes Mount └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Global MW │ ← CORS, JSON Parser, Logger, Rate Limiter │ (app.js level) │ └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Router Layer │ ← src/routes/ → يحدد الـ Endpoint │ (routes/) │ └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Route-Level MW │ ← validate(), protect(), restrictTo() │ (per-route) │ └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Controller │ ← src/controllers/ → يستقبل الـ Request وينسق └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Service Layer │ ← src/services/ → Business Logic المعقدة │ (if complex) │ └────────┬────────┘ │ ▼ ┌─────────────────┐ │ Model Layer │ ← src/models/ → التعامل مع MongoDB └────────┬────────┘ │ ▼ ┌─────────────────┐ │ MongoDB │ ← الـ Database الفعلي └─────────────────┘ │ ▼ (الرجعة) ┌─────────────────┐ │ Error Handler │ ← src/middlewares/errorHandler.js │ (last MW) │ ← بيمسك أي Error في أي طبقة └─────────────────┘ │ ▼ HTTP Response

````

---

### 2. مثال عام بسيط

```js
// ده مش كودك، ده فكرة الـ Layered Architecture في 10 سطور
const express = require('express');
const app = express();

// Layer 1: Global Middleware
app.use(express.json()); // كل Request هتعدي على ده

// Layer 2: Route (بيحدد المسار)
// Layer 3: Route-Level Middleware (protect - validate)
// Layer 4: Controller (بيتنفذ الـ logic)
app.get('/users', (req, res) => res.json({ users: [] }));

// Layer 5: Error Handler (لازم يبقى آخر حاجة)
app.use((err, req, res, next) => res.status(500).json({ error: err.message }));
````

---

### 3. شرح التطبيق في المشروع

في المشروع ده، الـ Layers اتقسمت على فولدرات زي دي:

|Layer|Location|المسؤولية|
|---|---|---|
|Entry Point|`index.js`|يبدأ الـ Server، يوصل الـ DB|
|App Config|`app.js`|يضم الـ Middlewares والـ Routes|
|Routing|`src/routes/`|يحدد الـ Endpoints|
|Validation|`src/middlewares/validate.js` + `src/validations/`|يتأكد إن الـ Input صح|
|Authentication|`src/middlewares/authenticate.js`|JWT|
|Authorization|`src/middlewares/authorize.js`|Roles|
|Business Logic|`src/controllers/` + `src/services/`|الـ Logic الفعلي|
|Data Access|`src/models/`|Mongoose Schemas|
|Utilities|`src/utils/`|ApiError, ApiResponse, paginate|

---

### 4. الربط بالصورة الكاملة (The Glue)

لو طلبت `POST /api/auth/register`:

```
Request: POST /api/auth/register
  │
  ▼ index.js → app(req, res) → connectDB()
  ▼ app.js → cors() → json() → httpLogger → rateLimiter
  ▼ routes/index.js → router.use('/auth', require('./auth'))
  ▼ routes/auth.js → router.post('/register', validate(registerSchema), register)
  ▼ middlewares/validate.js → Joi يتحقق من الـ Body
  ▼ controllers/auth.js → register() → User.findOne() → User.create()
  ▼ models/user.js → pre('save') hook → bcrypt.hash(password)
  ▼ MongoDB → يحفظ الـ User
  ▼ controllers/auth.js → res.json(new ApiResponse(201, ...))
  ▼ HTTP Response ✅
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — مفيش Service Layer لـ Auth:** الـ `register` و `login` logic موجودة في الـ Controller مباشرة. الصح إن الـ Controller يكون رفيع (thin) ويستدعي Service. لو المشروع اتكبر، هتلاقي نفسك بتكرر الـ `User.findOne` logic في أكتر من مكان.

```js
// ❌ اللي موجود — Logic في Controller
const register = async (req, res) => {
  if (await User.findOne({ email })) throw new ApiError(409, ...);
  const newUser = await User.create({ ... });
  // ...
};

// ✅ الأفضل — Controller يستدعي Service
const register = async (req, res) => {
  const newUser = await AuthService.register(req.body);
  res.status(201).json(new ApiResponse(201, 'User created', newUser));
};
```

**عيب 2 — مفيش API Versioning:** الـ Routes بتبدأ بـ `/api` بس. لو غيرت الـ API في المستقبل، مش هتعرف تشغل الإصدارين مع بعض. الأفضل `/api/v1/...`.

**عيب 3 — مفيش Health Check Endpoint:** مفيش `GET /api/health` أو `/api/ping`. ده standard في أي Production API عشان تعرف إن الـ Server شغال.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه الفرق بين الـ `middleware` والـ `controller` في Express؟ ليه مش بنحط كل الـ Logic في الـ middleware مباشرة؟

**Q2:** لو جه Error في الـ Controller، إزاي بيوصل للـ Error Handler؟ هل لازم نعمل حاجة خاصة؟ (الإجابة: `next(err)` أو throw في async)

**Q3:** ليه بنقسم الكود على فولدرات (routes, controllers, models) بدل ما نحط كل حاجة في ملف واحد؟

---

## Chapter 02 — index.js & app.js: The Two Guardians

---

### 1. الكونسبت العام (The Story)

تخيل إن عندك مطعم. الـ `app.js` ده **تصميم المطعم الداخلي** — المطبخ، الطاولات، قائمة الأكل، النظام اللي بيشتغل بيه كل حاجة. لكن الـ `app.js` ده مجرد تصميم — مش بيشغل نفسه.

الـ `index.js` ده **المدير اللي بيفتح المطعم كل يوم** — بيوصل الكهرباء (DB Connection)، بيفتح الباب للناس (Server Listen)، وبيتعامل مع الكوارث لو حصلت (uncaughtException, unhandledRejection).

الفصل ده بالظبط هو الفصل بين **"الـ App نفسها"** و**"عملية تشغيل الـ App"**. وده قرار معماري (architectural decision) مهم لأسباب اتنين:

1. **Testing:** لما تعمل Tests، بتـ import الـ `app.js` بدون ما تشغل الـ Server الفعلي.
2. **Serverless:** Vercel بيـ import الـ `index.js` كـ Module، مش بيشغله كـ Script.

---

### 2. مثال عام بسيط

```js
// app.js — التصميم بس
const express = require('express');
const app = express();
app.use(express.json());
app.get('/', (req, res) => res.send('Hello'));
module.exports = app; // بنـ export مش بنـ listen

// index.js — التشغيل
const app = require('./app');
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI).then(() => {
  app.listen(3000, () => console.log('Server on 3000'));
});
```

---

### 3. شرح التطبيق في المشروع

**في `app.js`:**

```js
const app = express();

// 1. CORS — من أول حاجة عشان OPTIONS requests تتعالج صح
app.use(cors({ origin: [...], credentials: true }));

// 2. JSON Parser — يحول الـ Body من String لـ Object
app.use(express.json());

// 3. Logger — يسجل كل Request
app.use(httpLogger);

// 4. Rate Limiter — يحمي من الـ Abuse
app.use(rateLimiter);

// 5. Routes — الأساس
app.use('/api', routes);

// 6. Error Handler — آخر حاجة دايماً
app.use(errorHandler);

module.exports = app; // ← بيـ export الـ app كـ function جاهزة
```

**في `index.js` — الجزء الأهم: الـ Vercel Serverless Trick:**

```js
// ده الجزء اللي بيفرق بين Local و Vercel

const handler = async (req, res) => {
  await connectDB(); // ← بيتأكد إن الـ DB متوصلة قبل أي Request
  return app(req, res); // ← بيدي الـ Request للـ app
};

// لو شغال locally:
if (require.main === module) {
  mongoose.connect(DB).then(() => {
    app.listen(PORT, () => console.log(`Running on ${PORT}`));
  });
}

// لو على Vercel — بيـ export الـ handler
module.exports = handler;
```

**سؤال مهم: إيه الفرق بين `app(req, res)` و `app.listen()`؟**

الـ Express app هي في الأساس **function** بتاخد `(req, res)`. الـ `app.listen()` بس بتقوله "استنى requests على Port معين". على Vercel، الـ Port management بيعمله Vercel نفسه، فبس بنديله الـ function.

**الـ connectDB function:**

```js
const connectDB = async () => {
  if (mongoose.connection.readyState >= 1) return; // ← الـ Caching trick
  return mongoose.connect(DB);
};
```

`readyState` بتاع Mongoose:

- `0` = disconnected
- `1` = connected ✅
- `2` = connecting
- `3` = disconnecting

لو الـ readyState بالفعل `>= 1`، مش هنعمل connection جديد. ده ضروري جداً في Serverless لأن كل Request ممكن تيجي في Lambda Function جديدة، والـ Connection ممكن يكون موجود خليه.

---

### 4. الربط بالصورة الكاملة (The Glue)

```
Vercel receives HTTP Request
        │
        ▼
index.js (exported handler)
        │
        ▼
connectDB() ← لو مش متوصل، يوصل الأول
        │
        ▼
app(req, res) ← Express يستلم
        │
        ▼
Global Middlewares (cors, json, logger, rateLimit)
        │
        ▼
Routes → Controllers → Models → MongoDB
        │
        ▼
HTTP Response
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ errorHandler اتضاف مرتين!**

```js
// في app.js:
app.use(errorHandler); // ← المرة الأولى ✅

// في index.js:
app.use(errorHandler); // ← المرة التانية ❌ DUPLICATE!
```

ده مش هيعمل حاجة خطيرة لأن Express هيستخدم الأول اللي يلاقيه، لكنه **redundant وبيدل على خلط في فهم الكود**. لو Tech Lead شافها هيسألك فوراً.

**عيب 2 — `process.on('uncaughtException')` بييجي بعد `mongoose.connect()`:**

```js
// الكود الحالي:
process.on('uncaughtException', (err) => { ... }); // ← سطر 1

mongoose.connect(DB) // ← سطر 2
  .then(() => app.listen(PORT));

process.on('unhandledRejection', (err) => { ... }); // ← سطر 3
```

الـ `uncaughtException` handler المفروض يكون **أول حاجة** في الملف قبل أي كود تاني، عشان يمسك أي error في الـ initialization phase نفسها.

**عيب 3 — مفيش Graceful Shutdown كامل:** الكود بيعمل `server.close()` بس. في Production المفروض كمان تـ close الـ DB connection:

```js
process.on('unhandledRejection', (err) => {
  server.close(async () => {
    await mongoose.connection.close(); // ← ده ناقص
    process.exit(1);
  });
});
```

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنفصل `app.js` عن `index.js`؟ مش ممكن نحط كل حاجة في ملف واحد؟

**Q2:** إيه هو الفرق بين `require.main === module` و `module.exports`؟ متى بتكون القيمة `true`؟

> **إجابة نموذجية:** `require.main === module` بتكون `true` لما تشغل الملف مباشرة بـ `node index.js`. لو حد عمل `require('./index')` من ملف تاني، بتكون `false`. ده اللي بيخلي Vercel يـ import الملف كـ module من غير ما يشغل الـ Server.

**Q3:** إيه هو "Cold Start" في Serverless، وإزاي الـ `connectDB` function بتحل المشكلة دي؟

---

## Chapter 03 — Barrel Exports (index.js files)

---

### 1. الكونسبت العام (The Story)

تخيل إنك بتصحى الصبح وعايز تاخد قهوة، عصير، وتوست. عندك اتنين خيارات:

**الخيار الأول (بدون Barrel):**

- تروح المطبخ تاخد القهوة
- ترجع أوضتك
- تروح المطبخ تاني تاخد العصير
- ترجع أوضتك
- تروح المطبخ تالت تاخد التوست

**الخيار التاني (مع Barrel):**

- الـ Barrel (الـ index.js) يجمع قهوة + عصير + توست في صينية واحدة
- تيجي تاخد الصينية في رحلة واحدة ✅

الـ Barrel Export بالضبط كده. بدل ما كل ملف يعمل `require` من مسارات طويلة لكل شيء، الـ `index.js` بيجمع كل الـ exports من الفولدر ويقدمها في endpoint واحد.

---

### 2. مثال عام بسيط

```js
// بدون Barrel — الطريقة الصعبة
const ApiError = require('./utils/ApiError');
const ApiResponse = require('./utils/ApiResponse');
const paginate = require('./utils/pagination');

// مع Barrel — src/utils/index.js
// utils/index.js:
module.exports = { ApiError, ApiResponse, paginate };

// أي ملف تاني:
const { ApiError, ApiResponse, paginate } = require('./utils'); // ← نظيف!
```

---

### 3. شرح التطبيق في المشروع

المشروع عنده **4 Barrel files** رئيسية:

**`src/utils/index.js`:**

```js
const ApiError = require('./ApiError');
const ApiResponse = require('./ApiResponse');
const paginate = require('./pagination');
module.exports = { ApiResponse, ApiError, paginate };
```

**`src/models/index.js`:**

```js
const Author = require('./author');
const Book = require('./book');
// ... etc
module.exports = { Author, Book, Cart, Category, Order, Review };
// ← ملاحظة: User مش موجود هنا! هيتسألوك عليه
```

**`src/middlewares/index.js`:**

```js
const protect = require('./authenticate');
const { restrictTo } = require('./authorize');
// ... etc
module.exports = { protect, restrictTo, errorHandler, validate, httpLogger, rateLimiter };
```

**`src/controllers/index.js`:**

```js
// ملاحظة: auth controller مش موجود في الـ barrel!
module.exports = { cart, book, category, cloudinary, review, author };
```

---

### 4. الربط بالصورة الكاملة (The Glue)

الـ Barrel files بتأثر على كل الطبقات. مثلاً في `src/controllers/book.js`:

```js
// بدلاً من:
const Author = require('../models/author');
const Book = require('../models/book');
const Category = require('../models/category');
const ApiResponse = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');
const paginate = require('../utils/pagination');

// بيكتب:
const { Author, Book, Category } = require('../models');
const { ApiResponse, ApiError, paginate } = require('../utils');
```

ده بيخلي كل controller أنظف وأسهل في القراءة.

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — User Model غائب من `src/models/index.js`:**

```js
// src/models/index.js — User مش موجود!
module.exports = { Author, Book, Cart, Category, Order, Review };
```

ده معناه إن أي ملف عايز يـ import الـ User Model لازم يعمله directly:

```js
// في auth.js controller:
const User = require('../models/user'); // ← مش من الـ barrel
```

ده مش خطأ فادح، لكنه **inconsistency** في الكود. إما تحط User في الـ barrel أو متحطش أي model فيها.

**عيب 2 — auth controller غائب من `src/controllers/index.js`:**

```js
// src/controllers/index.js:
module.exports = { cart, book, category, cloudinary, review, author };
// auth مش موجود!
```

نفس المشكلة. اتفرض إن `auth` اتعمل بشكل منفصل ومش محتاج الـ barrel، لكن التوثيق الـ مش واضح.

**عيب 3 — Circular Dependency Risk:** لو Model A عمل require لـ Model B، والـ B عمل require للـ barrel اللي فيه A — ممكن يحصل Circular Dependency. في المشروع ده مش موجود لكن الـ barrel pattern لازم تاخد باله منه في مشاريع أكبر.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Barrel Export Pattern وإيه فايدته؟

**Q2:** ليه الـ `User` model مش موجود في `src/models/index.js`؟ هل ده قصد أم نسيان؟

**Q3:** لو عندي فولدر `utils` بيه 10 ملفات وعملت `index.js` يـ export كلهم، هل ده ممكن يأثر على الـ Performance؟

> **إجابة:** بشكل عام لأ في Node.js، لأن الـ Modules بتتـ cache بعد أول `require`. لكن في بيئات زي Webpack أو Vite، ممكن يأثر على الـ Tree Shaking.

---

# ⚒️ الفصل الثاني: طبقة الـ Utils — الأدوات السرية

---

## Chapter 04 — ApiError Class

---

### 1. الكونسبت العام (The Story)

تخيل إنك اتصلت بـ Customer Service وقلتهم "في مشكلة". المشكلة دي ممكن تكون:

- "رقم أوردرك غلط" (خطأ من جهتك — 400)
- "مش مسجل عندنا" (مش موجود — 404)
- "الموقع وقع" (خطأ منا — 500)

كل نوع خطأ محتاج **معلومات مختلفة** عشان نتعامل معاه صح. لو بعتلك كل الأخطاء بنفس الشكل (مجرد `throw new Error('something went wrong')`)، مش هتعرف تـ handle كل حالة بشكل مختلف.

الحل هو إنك تعمل **Custom Error Class** وارثة من `Error`، وتضيف عليها معلومات إضافية زي:

- `statusCode`: الـ HTTP Status Code (400, 401, 403, 404, 500)
- `status`: 'fail' أو 'error'
- `isOperational`: هل الخطأ ده متوقع ولا حصل برمجي؟

---

### 2. مثال عام بسيط

```js
// الطريقة القديمة — throw Error عادي
throw new Error('User not found');
// المشكلة: مفيش statusCode، مفيش تفريق بين أنواع الأخطاء

// الطريقة الصح — Custom Error Class
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message);                     // استدعاء constructor الـ parent
    this.statusCode = statusCode;       // 400, 401, 404, 500
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;          // ده خطأ متوقع، مش bug
    Error.captureStackTrace(this, this.constructor); // Stack trace نظيف
  }
}

throw new ApiError(404, 'User not found'); // ✅
```

---

### 3. شرح التطبيق في المشروع

**`src/utils/ApiError.js`:**

```js
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}
module.exports = ApiError;
```

**التشريح سطر بسطر:**

- `super(message)`: لازم تستدعي الـ `Error` constructor بالـ message. من غيرها الـ `this.message` مش هيتحط.
    
- `this.status = '${statusCode}'.startsWith('4') ? 'fail' : 'error'`:
    
    - 4xx errors (400, 401, 404) → status = `'fail'` (خطأ من المستخدم)
    - 5xx errors (500, 503) → status = `'error'` (خطأ من السيرفر)
- `this.isOperational = true`: ده الفرق الجوهري. الـ `isOperational` flag بتقول للـ Error Handler إن الخطأ ده **متوقع ومتعمد** (زي "المستخدم مش موجود"). الأخطاء التانية (زي Bug في الكود) مش هتكون `isOperational`، وهنتعامل معاها بشكل مختلف.
    
- `Error.captureStackTrace(this, this.constructor)`: بتعمل Stack Trace نظيف بيبدأ من الـ ApiError نفسه، مش من الـ Error class. ده بيخلي الـ debugging أسهل.
    

**طريقة استخدامه في المشروع:**

```js
// في controllers/auth.js:
if (await User.findOne({ email }))
  throw new ApiError(409, 'Email already in use');

// في middlewares/authenticate.js:
throw new ApiError(401, 'you are not logged in');

// في middlewares/authorize.js:
throw new ApiError(403, 'you do not have permission');
```

---

### 4. الربط بالصورة الكاملة (The Glue)

الـ `ApiError` هي **الرسالة** اللي بتتبعت بين الطبقات:

```
Controller: throw new ApiError(404, 'User not found')
     │
     ▼ (في async functions، throw بيتحول لـ rejected Promise)
     │
     ▼ Express بيمسك الـ Error ويبعته للـ Error Handler
     │
errorHandler.js: err.statusCode = 404, err.isOperational = true
     │
     ▼ productionError() بيتحقق من isOperational
     │
     ▼ لو true: بيبعت الـ message للـ Client
     ▼ لو false: بيبعت "something went wrong" فقط
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ `throw` في async functions بيحتاج `next()`:**

في المشروع، الـ Controllers بتـ `throw` من غير `try/catch`. ده شغال لأن Express 5 بيـ handle الـ async errors تلقائياً. لكن في Express 4 ده كان مش شغال! المفروض يكون في تعليق يوضح إن المشروع بيفترض Express 5 أو بيستخدم wrapper.

في الكود الحالي، الـ Routes مش wrapped. معناه لو بتشتغل على Express 4، ممكن الـ unhandled rejections تعمل crash.

```js
// الأمان الكامل في Express 4:
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// ثم:
router.post('/register', asyncHandler(register));
```

**عيب 2 — مفيش Error Codes (Machine-Readable):** الـ ApiError بس عندها `statusCode` و `message`. في APIs الكبيرة، بيبعتوا كمان `errorCode` زي `USER_NOT_FOUND` عشان الـ Frontend يعرف يـ handle كل حالة بدون ما يحلل الـ message.

**عيب 3 — الـ constructor مش بيعمل validate للـ statusCode:** لو حد غلط وكتب `new ApiError('not a number', 'message')` هيمشي من غير error. الأفضل:

```js
if (!Number.isInteger(statusCode)) throw new TypeError('statusCode must be integer');
```

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه الفرق بين `throw new Error('...')` و `throw new ApiError(404, '...')`؟ ليه بنعمل Custom Error Class؟

**Q2:** إيه معنى `this.isOperational = true`؟ وإزاي الـ Error Handler بيستخدم الـ flag ده؟

> **إجابة نموذجية:** الـ `isOperational` بيفرق بين نوعين أخطاء: الأخطاء اللي انتظرناها (زي "المستخدم مش موجود") والأخطاء اللي مكانتيش في الحسبان (زي Bug في الكود). في الـ production، بنبعت message الأولى للـ client، أما التانية فبنخبي التفاصيل ونبعت رسالة عامة.

**Q3:** إيه هو `Error.captureStackTrace`، وليه بنستخدمه في الـ Custom Error؟

---

## Chapter 05 — ApiResponse Class

---

### 1. الكونسبت العام (The Story)

تخيل إنك بتطلب من 3 موظفين مختلفين في نفس الشركة إنهم يكتبوا ليك Report. الموظف الأول هيكتبه بـ Word، التاني بـ Excel، التالت هيبعت WhatsApp message. كل واحد بيـ format الرد بطريقة مختلفة.

الـ Client (Angular أو React) بتاعك هيتجنن وهو بيحاول يـ parse الـ Response لأن كل Endpoint بيرد بشكل مختلف.

الحل: **توحيد شكل كل Response في الـ API** باستخدام `ApiResponse` class. كده كل response هتبقى شايفها بنفس الشكل:

```json
{
  "success": true,
  "message": "User created successfully",
  "data": { ... }
}
```

---

### 2. مثال عام بسيط

```js
// بدون ApiResponse — كل controller بيعمل حاجة مختلفة ❌
res.json({ user: newUser, message: 'created' });       // Controller 1
res.json({ data: books, status: 'ok' });                // Controller 2
res.json({ result: order });                            // Controller 3

// مع ApiResponse — توحيد كامل ✅
class ApiResponse {
  constructor(statusCode, message, data = null) {
    this.success = statusCode < 400;
    this.message = message;
    this.data = data;
  }
}
res.json(new ApiResponse(200, 'User created', newUser));
res.json(new ApiResponse(200, 'Books fetched', books));
```

---

### 3. شرح التطبيق في المشروع

**`src/utils/ApiResponse.js`:**

```js
class ApiResponse {
  constructor(statusCode, message, data = null, pagination = null) {
    this.success = statusCode < 400;  // true للـ 2xx, false للـ 4xx و 5xx
    this.message = message;
    this.data = data;
    if (pagination) this.pagination = pagination; // ← بيضيف بس لو موجود
  }
}
```

**لاحظ التصميم الذكي:**

- `data = null`: لو مفيش data (زي logout)، هتبعت `null` مش هتعمل error.
- `if (pagination) this.pagination = pagination`: الـ pagination مش بتبان في الـ Response غير لو موجودة فعلاً. مش هتلاقي `"pagination": null` في كل response.

**الشكل الفعلي للـ Response على طول المشروع:**

```json
// GET /api/auth/me — بيانات المستخدم
{
  "success": true,
  "message": "User retrieved successfully",
  "data": {
    "_id": "...",
    "email": "mohamed@example.com",
    "firstName": "mohamed"
  }
}

// GET /api/books — كتب مع Pagination
{
  "success": true,
  "message": "Books fetched",
  "data": {
    "books": [...],
    "pagination": {
      "totalDocuments": 50,
      "page": 1,
      "limit": 10,
      "totalPages": 5,
      "hasPrev": false,
      "hasNext": true
    }
  }
}

// POST /api/auth/logout
{
  "success": true,
  "message": "User logged out successfully",
  "data": null
}
```

---

### 4. الربط بالصورة الكاملة (The Glue)

الـ `ApiResponse` هي **الإجابة** اللي ترجع من أي طبقة:

```
Controller بيتنفذ Logic
     │
     ▼
res.json(new ApiResponse(201, 'Book created', book))
     │
     ▼ بتتحول لـ JSON تلقائياً لأن الـ class عندها properties
     ▼ (الـ JSON.stringify بيشتغل على الـ object properties)
     │
     ▼
HTTP Response: 201 Created + JSON Body
```

**ملاحظة مهمة:** الـ `statusCode` اللي في `ApiResponse` مش بيتحدد في الـ HTTP Response. الـ HTTP Status بيتحدد بـ `res.status(201).json(...)`. الـ `success` في الـ class بس عشان الـ Frontend يعرف من غير ما يحلل الـ status code.

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ pagination متضمن في الـ data بعض الأحيان وفي الـ root أحيان تانية:**

```js
// في controllers/book.js:
res.json(new ApiResponse(200, 'Books fetched', { books, pagination }));
// هنا الـ pagination جوه الـ data!

// الـ ApiResponse constructor:
constructor(statusCode, message, data = null, pagination = null)
// هنا الـ pagination parameter الرابع غير مستخدم في الكود!
```

ده inconsistency كبيرة. الـ `pagination` parameter في الـ constructor موجود بس مش بيتستخدم في أي مكان. الـ Controllers بتحط الـ pagination جوه الـ data object.

**عيب 2 — الـ `success` field مش كافية:** بعض APIs بتبعت كمان `statusCode` في الـ Response body عشان الـ Client يستخدمه من غير ما يـ read الـ HTTP Status:

```js
// أفضل:
this.statusCode = statusCode;
this.success = statusCode < 400;
```

**عيب 3 — مفيش Type Safety:** الـ `data` ممكن يكون أي حاجة. في TypeScript ده كان ممكن يتحل، لكن في JavaScript العادي مفيش validation.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنعمل `ApiResponse` class بدل ما نـ hardcode الـ response في كل controller مباشرة؟

**Q2:** لو الـ `statusCode` هو 404، إيه قيمة `this.success`؟ ليه؟

> **إجابة:** `false`، لأن `404 < 400` بيرجع `false`. الشرط `statusCode < 400` بيتحقق إن الـ status في الـ 2xx range فقط اللي بتبقى success.

**Q3:** إيه الفرق بين الـ `statusCode` في `res.status(201)` والـ `statusCode` في `new ApiResponse(201, ...)`؟

---

## Chapter 06 — errorHelpers.js

---

### 1. الكونسبت العام (The Story)

تخيل إنك طبيب في مستشفى. لما المريض يجيلك ويقولك "بوجعني بطني"، بتعمل حاجتين:

1. **لو المريض هو أنت نفسك (Development):** بتقوله كل التفاصيل — "عندك التهاب في الزائدة الدودية، موقعه الجانب الأيمن، مستوى الألم 8/10، والـ scan بيظهر كذا..." — لأنك بتحاول تـ diagnose المشكلة.
    
2. **لو المريض زبون عادي (Production):** بتقوله بس "عندك مشكلة في الجهاز الهضمي، هنعملك علاج" — مش محتاج يعرف كل تفاصيل الـ scan والمصطلحات الطبية المعقدة.
    

`errorHelpers.js` بالظبط كده. بيفرق بين **إزاي تعرض الأخطاء في Development** وإزاي تعرضها في **Production**.

---

### 2. مثال عام بسيط

```js
// Development Error — كل التفاصيل
const devError = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,         // ← الـ Error object كامل
    message: err.message,
    stack: err.stack    // ← Stack Trace كامل
  });
};

// Production Error — الحد الأدنى
const productionError = (err, res) => {
  if (err.isOperational) {
    res.status(err.statusCode).json({ status: err.status, message: err.message });
  } else {
    res.status(500).json({ status: 'error', message: 'Something went wrong' });
  }
};
```

---

### 3. شرح التطبيق في المشروع

**`src/utils/errorHelpers.js`:**

```js
// 1. Development Error — كاشف كل حاجة للـ Developer
const devError = (err, res) => {
  return res.status(err.statusCode).json({
    status: err.status,
    error: err,           // الـ Error Object كامل بكل properties
    message: err.message, // الرسالة
    stack: err.stack      // Stack trace — أهم حاجة في الـ debugging
  });
};

// 2. Production Error — بيفرق بين Operational و Programming errors
const productionError = (err, res) => {
  if (err.isOperational) {
    // خطأ متوقع (مثلاً: User not found)
    return res.status(err.statusCode).json({
      status: err.status,
      message: err.message // نبعت الـ message الحقيقية
    });
  } else {
    // خطأ مش متوقع (Bug في الكود!)
    console.error('error', err); // نسجله للـ log بس
    return res.status(500).json({
      status: 'error',
      message: 'something went wrong' // نخبي التفاصيل
    });
  }
};
```

**الـ 3 MongoDB-Specific Error Handlers:**

```js
// 1. CastError: لما تبعت ID بصيغة غلط
// مثلاً: GET /api/books/not-a-valid-id
// MongoDB: CastError: Cast to ObjectId failed for value "not-a-valid-id"
const handleCastErrorDB = (err) => {
  const message = `Invalid ${err.path}: ${err.value}.`;
  // err.path = '_id', err.value = 'not-a-valid-id'
  // الرسالة: "Invalid _id: not-a-valid-id."
  return new ApiError(400, message);
};

// 2. Duplicate Key Error: لما تحاول تضيف email موجود
// MongoDB Error Code: 11000
const handleDuplicateFieldsDB = (err) => {
  const value = err.keyValue ? Object.values(err.keyValue)[0] : 'unknown';
  // err.keyValue = { email: 'test@test.com' }
  // value = 'test@test.com'
  const message = `Duplicate field value: "${value}". Please use another value.`;
  return new ApiError(409, message);
};

// 3. Mongoose Validation Error: لما الـ Schema validation يفشل
const handleValidationErrorDB = (err) => {
  const errors = Object.values(err.errors).map((el) => el.message);
  // err.errors = { firstName: {message: 'first name is required'}, ... }
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new ApiError(400, message);
};
```

---

### 4. الربط بالصورة الكاملة (The Glue)

الـ `errorHelpers.js` بيشتغل جوه `errorHandler.js`:

```
أي Error في أي مكان
        │
        ▼
errorHandler.js (الـ 4-argument middleware)
        │
        ├── NODE_ENV === 'development' ?
        │     └── devError(err, res) ← كل التفاصيل
        │
        └── NODE_ENV === 'production' ?
              ├── CastError → handleCastErrorDB → ApiError(400)
              ├── code 11000 → handleDuplicateFieldsDB → ApiError(409)
              ├── ValidationError → handleValidationErrorDB → ApiError(400)
              ├── JsonWebTokenError → ApiError(401, 'Invalid token')
              ├── TokenExpiredError → ApiError(401, 'Token expired')
              └── ثم productionError(error, res)
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — `console.error` في Production بدلاً من Structured Logging:**

```js
// في productionError:
console.error('error', err); // ← مش كافي في Production
```

المفروض نستخدم الـ `logger` (Pino) اللي موجود في المشروع بدل `console.error`:

```js
const { logger } = require('./logger');
logger.error({ err, msg: 'Unhandled error in production' });
```

**عيب 2 — مفيش معالجة لـ SyntaxError في الـ JSON Body:** لو المستخدم بعت JSON غلط (زي `{ name: }` بدون قيمة)، Express بيرمي `SyntaxError`. الكود الحالي مش بيـ handle ده explicitly.

```js
// الإضافة المطلوبة في errorHandler:
if (error.type === 'entity.parse.failed') {
  error = new ApiError(400, 'Invalid JSON in request body');
}
```

**عيب 3 — الـ `err.statusCode || 500` بيخلي كل unknown error 500:** ده صح من ناحية الـ HTTP Status، لكن لو developer نسي يحط `statusCode` على الـ ApiError بتاعه، هيتحول لـ 500 من غير أي تحذير. الأفضل إضافة warning log.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنخبي تفاصيل الـ Error في Production؟ هل ده مش بيصعب الـ Debugging؟

> **إجابة نموذجية:** بنخبي التفاصيل عشان الـ Security. لو Hacker شاف الـ Stack Trace، هيعرف أسماء الملفات، الـ Libraries المستخدمة، وربما جزء من الـ Logic. بدل كده، بنـ log التفاصيل على السيرفر ونبعت رسالة عامة للـ client. في Production، بنستخدم tools زي Sentry أو CloudWatch لنتابع الأخطاء.

**Q2:** إيه هو MongoDB Error Code `11000`؟ متى بيحصل؟

**Q3:** ليه `handleValidationErrorDB` موجود وعندنا بالفعل Joi validation? هل الـ Mongoose validation redundant؟

> **إجابة:** لا، مش redundant. الـ Joi بيتحقق على الـ HTTP Layer قبل ما أي حاجة توصل للـ DB. الـ Mongoose validation هو الـ "last line of defense" — لو في أي كود بيـ save للـ DB من غير مرور على الـ middleware (زي في Services مثلاً). الـ double validation هو best practice.

---

# 🛡️ الفصل الثالث: طبقة الـ Middlewares — حراس البوابة

---

## Chapter 07 — validate.js (Joi Validation)

---

### 1. الكونسبت العام (The Story)

تخيل إن في بيتك باب بحارس. الحارس ده عنده ورقة شروط — أي حد عايز يدخل لازم يكون:

- عنده ID
- عمره فوق 18
- مش ممنوع من الدخول

الحارس ده بيوقف الناس قبل ما يدخلوا. مش بيخليهم يدخلوا الأول ويتفحص بعدين.

الـ `validate.js` middleware بالظبط هو الحارس ده. بييجي قبل الـ Controller في الـ Route Chain، وبيتحقق إن الـ Request Body عنده كل الـ fields المطلوبة وبالصيغة الصح. لو في أي حاجة غلط، بيوقف الـ Request ومش بيخليها توصل للـ Controller أصلاً.

لكن فيه تفصيلة مهمة: الـ `validate` مش مجرد function — هي **Higher-Order Function** (function بترجع function). ده تصميم قوي جداً في JavaScript.

---

### 2. مثال عام بسيط

```js
// Higher-Order Function — function بترجع function
const validate = (schema) => {           // ← الـ factory function
  return (req, res, next) => {           // ← الـ middleware الفعلي
    const { error } = schema.validate(req.body);
    if (error) return next(new Error(error.message));
    next();
  };
};

// الاستخدام في الـ Route:
router.post('/register', validate(registerSchema), register);
//                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                        ده بيستدعي الـ factory function
//                        واللي بيرجع هو الـ middleware function
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/validate.js`:**

```js
const ApiError = require('../utils/ApiError');

const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, {
    abortEarly: false,   // ← لا توقف عند أول error، اجمع كل الأخطاء
    stripUnknown: true   // ← شيل أي field مش في الـ schema تلقائياً
  });
  if (!error) req.body = value; // ← استبدل الـ body بالـ value المنظف
  if (error) {
    const message = error.details.map((d) => d.message).join(', ');
    throw new ApiError(400, message);
  }
  next();
};

module.exports = validate;
```

**التشريح سطر بسطر:**

**`abortEarly: false`:** بدل ما Joi يوقف عند أول error ويقول "الـ email غلط" بس، هو يجمع كل الأخطاء ويبعتهم مرة واحدة: "الـ email غلط، الـ password قصيرة جداً، الـ firstName ناقص". ده أفضل بكتير لـ UX.

**`stripUnknown: true`:** لو المستخدم بعت field زيادة مش موجود في الـ Schema (زي `isAdmin: true`)، الـ Joi هيشيله تلقائياً من الـ `req.body`. ده protection مهم ضد **Mass Assignment Attacks**.

**`if (!error) req.body = value`:** الـ `value` اللي Joi بيرجعه هو الـ body **بعد الـ transformation** (زي default values، lowercase، trim). بنستبدل الـ `req.body` الأصلي بيه عشان الـ Controller يشتغل على البيانات المنظفة.

**`error.details.map((d) => d.message).join(', ')`:** الـ Joi error object عنده array اسمها `details`. كل element فيها عندها `message`. بنجمع الـ messages دي في string واحد.

مثال:

```js
// Input: { email: 'not-email', password: '123' }
// Joi errors:
// details[0].message = '"email" must be a valid email'
// details[1].message = '"password" length must be at least 8 characters long'
// بعد الـ join:
// '"email" must be a valid email, "password" length must be at least 8 characters long'
```

**استخدامه في الـ Routes:**

```js
// routes/auth.js:
router.post('/register', validate(registerSchema), register);
//                        ↑
//                        validate(registerSchema) → بيستدعي الـ factory
//                        بترجع middleware function جاهزة
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/auth/register
  { email: "bad-email", password: "123", firstName: "Mo" }
                │
                ▼
routes/auth.js: validate(registerSchema)
                │
                ▼ Joi يشوف الـ body
                │
                ├── email غلط ❌
                ├── password قصيرة ❌
                └── مفيش lastName ❌
                │
                ▼ abortEarly: false → بيجمع الـ 3 أخطاء
                │
                ▼ throw new ApiError(400, "all 3 messages joined")
                │
                ▼ Error ينتقل للـ errorHandler
                │
                ▼ HTTP 400 Bad Request + { success: false, message: "..." }

--- لو الـ Body صح ---

POST /api/auth/register
  { email: "mo@test.com", password: "Pass123!", firstName: "Mohamed", lastName: "Ali", isAdmin: true }
                │
                ▼ validate middleware
                │
                ▼ stripUnknown: true → بيشيل isAdmin
                ▼ req.body = { email, password, firstName, lastName } فقط ✅
                │
                ▼ register controller يشتغل على بيانات نظيفة
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ Validation بتشتغل على `req.body` بس:**

```js
const { error, value } = schema.validate(req.body, { ... });
```

مفيش validation على `req.params` أو `req.query`. مثلاً في `GET /api/books/:id`، الـ `id` في `req.params` مش بيتتحقق منه. لو حد بعت `id` مش ObjectId، MongoDB هيرمي `CastError`.

الأفضل:

```js
const validate = (schema, target = 'body') => (req, res, next) => {
  const { error, value } = schema.validate(req[target], { ... });
  // ...
};
// استخدام: validate(paramsSchema, 'params')
```

**عيب 2 — `throw` في middleware غير async:**

```js
const validate = (schema) => (req, res, next) => {
  // ...
  throw new ApiError(400, message); // ← throw في sync function
};
```

في Express 4، الـ `throw` في sync middleware بيشتغل تمام لأن Express بيـ wrap الـ sync middleware في try/catch. لكن لو الـ validate بقت async في المستقبل، لازم تتغير لـ `next(new ApiError(...))`.

**عيب 3 — مفيش Custom Error Messages Namespace:** الـ Joi messages الافتراضية زي `"email" must be a valid email` ممكن تكون غريبة للمستخدم. الأفضل تحدد custom messages في كل Schema (بعض الـ validations في المشروع بتعمل كده والبعض لأ).

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Higher-Order Function؟ ليه الـ `validate` عندنا Higher-Order Function؟

> **إجابة نموذجية:** الـ Higher-Order Function هي function بتاخد function كـ argument أو بترجع function. الـ `validate` بتاخد `schema` وبترجع الـ middleware function الفعلية. ده بيخلينا نـ reuse نفس الـ middleware logic مع schemas مختلفة: `validate(registerSchema)`، `validate(loginSchema)`، إلخ.

**Q2:** إيه فائدة `stripUnknown: true` في Joi؟ هل ده مش بيـ silently حذف data المستخدم؟

**Q3:** إيه الفرق بين Joi Validation والـ Mongoose Schema Validation؟ ليه عندنا الاتنين؟

---

## Chapter 08 — authenticate.js (JWT Authentication)

---

### 1. الكونسبت العام (The Story)

تخيل إنك بتدخل نادي رياضي. في أول ما بتدخل، بتديهم الـ ID بتاعك. هم بيتحققوا إنك عضو، وبيديك **كرت مؤقت** (بيت في جيبك). في كل مرة بعد كده بتيجي تستخدم أي خدمة في النادي (مسبح، جيم، مطعم)، بتدي الكرت المؤقت ده. الموظف بيتحقق من الكرت من غير ما يرجع يسأل الريسيبشن كل مرة.

الكرت المؤقت ده هو الـ **JWT (JSON Web Token)**.

الـ JWT عنده 3 أجزاء مفصولين بـ dot:

```
eyJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI2Nzg5IiwiZW1haWwiOiJtb0B0ZXN0LmNvbSIsInJvbGUiOiJ1c2VyIn0.SIGNATURE
└──────────────────┘  └──────────────────────────────────────────────────────────────┘  └─────────┘
      Header                                   Payload                                  Signature
  (Algorithm)                        (_id, email, role, iat, exp)                    (الـ encryption)
```

---

### 2. مثال عام بسيط

```js
const jwt = require('jsonwebtoken');

// إنشاء Token (في اللحظة دي المستخدم مشي من الريسيبشن)
const token = jwt.sign(
  { _id: '123', email: 'mo@test.com', role: 'user' }, // Payload
  'my-secret-key',                                      // Secret
  { expiresIn: '7d' }                                   // Expiry
);

// التحقق من Token (في كل endpoint محمي)
const decoded = jwt.verify(token, 'my-secret-key');
// decoded = { _id: '123', email: 'mo@test.com', role: 'user', iat: 1234567, exp: 1235678 }
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/authenticate.js`:**

```js
const protect = async (req, res, next) => {
  // Step 1: هل في Authorization header؟
  if (
    !req.headers.authorization ||
    !req.headers.authorization.startsWith('Bearer')
  ) {
    throw new ApiError(401, 'you are not logged in');
  }

  // Step 2: استخرج الـ Token
  // Authorization: "Bearer eyJhbGciOiJIUzI1NiJ9..."
  const token = req.headers.authorization.split(' ')[1];
  // split(' ') = ['Bearer', 'eyJhbGciOiJIUzI1NiJ9...']
  // [1] = 'eyJhbGciOiJIUzI1NiJ9...'

  if (!token) throw new ApiError(401, 'you are not logged in');

  // Step 3: التحقق من الـ Token (Verify = فك التشفير + التحقق من الـ Signature)
  const decodedToken = verifyToken(token);
  // لو الـ token غلط أو منتهي → jwt.verify بيرمي Error تلقائياً
  // الـ errorHandler هيمسكه ويتحول لـ ApiError(401)

  // Step 4: هل المستخدم لسه موجود في الـ DB؟
  // (ممكن الـ admin حذف الـ account بعد إصدار الـ token)
  const freshUser = await User.findById(decodedToken._id);
  if (!freshUser) throw new ApiError(401, 'user not found');

  // Step 5: هل المستخدم غير الـ Password بعد إصدار الـ Token؟
  if (freshUser.changedPasswordAfter(decodedToken.iat))
    throw new ApiError(401, 'user recently changed password');

  // Step 6: كل حاجة تمام — حط المستخدم على الـ req
  req.user = freshUser; // ← الـ controllers كلها بتستخدم req.user
  next();
};
```

**`src/services/auth.js` — الـ Token functions:**

```js
const generateToken = (user) =>
  jwt.sign(
    { _id: user._id, email: user.email, role: user.role }, // Payload
    process.env.JWT_SECRET,                                 // Secret من .env
    { expiresIn: process.env.JWT_EXPIRES_IN }              // من .env (مثلاً '7d')
  );

const verifyToken = (token) =>
  jwt.verify(token, process.env.JWT_SECRET);
// لو الـ token غلط: throws JsonWebTokenError
// لو منتهي: throws TokenExpiredError
```

**لماذا نعمل DB Query في الـ authenticate (Step 4)؟**

ده سؤال مهم جداً. بعض الـ APIs بتكتفي بـ `jwt.verify` وبتثق إن الـ payload فيه كل المعلومات اللي محتاجاها. ليه بنعمل `User.findById` زيادة؟

الإجابة: **الـ Token مش بيتغير لو الـ User اتغير.** لو:

1. حد سرق الـ Token وأنا لقيت كده وغيرت الـ Password
2. الـ Admin قفل الـ Account
3. المستخدم اتحذف

في الحالات دي، الـ Token لسه valid بس المفروض مش يتقبل. عشان كده بنرجع للـ DB نتأكد إن الـ User لسه موجود وما غيرش الـ Password.

---

### 4. الربط بالصورة الكاملة (The Glue)

```
GET /api/auth/me
Headers: { Authorization: "Bearer eyJ..." }
          │
          ▼ routes/auth.js: router.get('/me', authenticate, getUserProfile)
          │
          ▼ authenticate middleware:
          │   1. يشوف الـ Authorization header
          │   2. يستخرج الـ token
          │   3. verifyToken() → decodedToken = { _id, email, role, iat }
          │   4. User.findById(decodedToken._id) → freshUser
          │   5. changedPasswordAfter(decodedToken.iat) → false (مغيرش)
          │   6. req.user = freshUser
          │   7. next()
          │
          ▼ getUserProfile controller:
              const user = await User.findById(req.user._id);
              // ← بيستخدم req.user اللي الـ authenticate حطه
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — مفيش Token Refresh Mechanism:** الـ Token بينتهي (بعد فترة من `.env`). لما ينتهي، المستخدم لازم يـ login تاني من الأول. في Production، بيكون في `refreshToken` منفصل بـ expiry أطول. مش موجود في المشروع.

**عيب 2 — الـ `verifyToken` مش بتـ handle الـ Errors explicitly:**

```js
const verifyToken = (token) =>
  jwt.verify(token, process.env.JWT_SECRET);
  // لو الـ token غلط → بترمي JsonWebTokenError
  // الـ authenticate middleware مش بيـ catch ده explicitly
  // بيعتمد على الـ errorHandler إنه يمسكه
```

الأفضل لو الـ authenticate بيـ wrap الـ `verifyToken` في try/catch ويرمي `ApiError(401)` explicilty بدل ما يعتمد على errorHandler.

**عيب 3 — الـ DB Query في كل Request محمي:**

```js
const freshUser = await User.findById(decodedToken._id);
```

ده معناه إن **كل Request محمي بيعمل Query للـ DB** زيادة عن الـ Query الأصلي. في الـ High Traffic، ده ممكن يكون bottleneck. الحل المتقدم هو استخدام **Redis Cache** للـ User data أو تقليل الـ fresh check لـ sensitive operations بس.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** الـ JWT بيكون مخزن فين عند المستخدم؟ هل هو مخزن عندنا في الـ Server؟

> **إجابة نموذجية:** الـ JWT بيتخزن عند الـ Client (localStorage أو cookie). عندنا في السيرفر مش بنخزنه. ده اللي بيخلي JWT "stateless" — السيرفر بيتحقق من الـ Signature من غير ما يحتاج يـ query database. (لكن في مشروعنا بنعمل DB query عشان نتحقق إن الـ user لسه موجود — ده trade-off).

**Q2:** إيه الفرق بين `jwt.sign()` و `jwt.verify()`؟ وإيه الـ Secret بيعمله؟

**Q3:** إيه هو `decodedToken.iat`؟ وليه `changedPasswordAfter` بتستخدمه؟

> **إجابة:** `iat` = "issued at" — الـ timestamp اللي اتعمل فيه الـ token. `changedPasswordAfter` بتقارن الـ timestamp ده بوقت آخر تغيير للـ password. لو الـ password اتغيرت **بعد** إصدار الـ token، يبقى الـ token ده قديم ومش آمن.

---

## Chapter 09 — authorize.js (Role-Based Access Control)

---

### 1. الكونسبت العام (The Story)

تخيل إنك في شركة. كلكم بتدخلوا من نفس الباب (Authentication). لكن مش كلكم تقدروا تدخلوا غرفة الـ CEO أو غرفة الـ Servers. كل واحد عنده **دور** (Role) وكل دور عنده **صلاحيات** (Permissions).

الـ Authorization جاية بعد الـ Authentication. أول ما نعرف **مين انت** (Authentication)، بنسأل **إيه اللي مسموح لك تعمله** (Authorization).

في المشروع، في دورين بس: `user` و `admin`. الـ `restrictTo` middleware بيتحقق إن الـ `req.user.role` موجود في قائمة الـ roles المسموح بيها.

---

### 2. مثال عام بسيط

```js
// Higher-Order Function تاني!
const restrictTo = (...roles) => {           // rest parameters
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(new Error('No permission'));
    }
    next();
  };
};

// استخدام:
router.post('/books', protect, restrictTo('admin'), createBook);
//                              ↑
//                   restrictTo('admin') → بترجع middleware function
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/authorize.js`:**

```js
const restrictTo = (...roles) => {
  // ...roles = rest parameters → ['admin'] أو ['admin', 'moderator']
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

**ملاحظة مهمة — الترتيب في الـ Route:**

```js
// routes/category.js:
router.post('/', protect, restrictTo('admin'), validate(createCategorySchema), createCategory);
//              ↑          ↑
//        authenticate   authorize
//        (Step 1)      (Step 2)
```

الترتيب **حاسم** — الـ `protect` لازم يجي قبل `restrictTo` لأن الـ `restrictTo` بتستخدم `req.user.role` اللي الـ `protect` بيحطه. لو انعكس الترتيب هيحصل `Cannot read property 'role' of undefined`.

**HTTP Status الفرق:**

- `401 Unauthorized`: مش متعرف عليك — مش لوجن
- `403 Forbidden`: اتعرفنا عليك بس مش مسموحلك — صلاحيات ناقصة

---

### 4. الربط بالصورة الكاملة (The Glue)

```
DELETE /api/categories/123
Headers: { Authorization: "Bearer <user-token>" }
                    │
                    ▼ protect middleware
                    │  → verifyToken → decodedToken = { role: 'user', ... }
                    │  → req.user = { role: 'user', ... }
                    │  → next()
                    │
                    ▼ restrictTo('admin') middleware
                    │  → roles = ['admin']
                    │  → roles.includes('user') → false ❌
                    │  → throw new ApiError(403, 'no permission')
                    │
                    ▼ errorHandler
                    │  → HTTP 403 Forbidden
                    │  → { success: false, message: 'you do not have permission...' }

--- لو كان Admin Token ---

                    ▼ restrictTo('admin') middleware
                    │  → roles.includes('admin') → true ✅
                    │  → next()
                    │
                    ▼ deleteCategory controller يشتغل
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ Authorization بالـ Role فقط (Coarse-Grained):** الكود عنده admin و user بس. مفيش granular permissions زي "هذا الـ user يقدر يعمل create بس مش delete". في مشاريع كبيرة بيستخدموا **Permission-Based Authorization** أو **RBAC كامل**.

**عيب 2 — الـ `throw` في Sync Middleware:** نفس ملاحظة الـ validate — الـ throw في sync middleware شغال في Express 5. في Express 4 الأصح `return next(new ApiError(403, ...))`.

**عيب 3 — الـ Role مخزن في الـ JWT Payload والـ DB:** لو Admin غير role المستخدم من `user` لـ `admin` في الـ DB، الـ JWT القديم لسه بيقول `role: 'user'`. ده لأن الـ `req.user` بييجي من الـ `freshUser` اللي اتجبه من الـ DB في الـ authenticate step. **المشروع ده بيحله صح** لأن بيرجع للـ DB. لكن لو حد حذف الـ DB query، هتحصل مشكلة.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه الفرق بين Authentication و Authorization؟ دي فين وده فين في الكود؟

**Q2:** ليه لازم `protect` يجي قبل `restrictTo` في الـ Route chain؟ إيه اللي هيحصل لو انعكسوا؟

**Q3:** إيه الفرق بين HTTP 401 و HTTP 403؟

---

## Chapter 10 — errorHandler.js (Global Error Handler)

---

### 1. الكونسبت العام (The Story)

تخيل إنك بتلعب لعبة. في كل مستوى ممكن يحصل حاجة غلط — ممكن الشخصية تقع، ممكن العدو يضربها، ممكن الوقت ينتهي. بدل ما كل مستوى يـ handle الموت بنفسه بطريقة مختلفة، في نظام مركزي "Game Over Screen" واحد بيتعامل مع **كل** أنواع الموت بشكل موحد.

الـ `errorHandler.js` هو الـ "Game Over Screen" بتاع الـ API. هو الـ Global Error Handler اللي بيمسك **أي error في أي طبقة** وبيتعامل معاه بشكل موحد.

السر هو في الـ **4 Parameters**. Express الاعتيادي Middleware بياخد 3: `(req, res, next)`. لما Express يشوف middleware بـ **4 parameters**: `(err, req, res, next)` — بيعرف تلقائياً إنه Error Handler Middleware.

---

### 2. مثال عام بسيط

```js
// Regular Middleware — 3 params
app.use((req, res, next) => {
  console.log('Request received');
  next();
});

// Error Handler Middleware — 4 params (العلامة السرية!)
app.use((err, req, res, next) => {
  console.error(err.message);
  res.status(err.statusCode || 500).json({ message: err.message });
});

// لازم يكون آخر middleware في الـ app
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/errorHandler.js`:**

```js
const errorHandler = (err, req, res, _next) => {
  // Note: _next بالـ underscore → بيقول "مش بنستخدمها بس لازم تكون موجودة"
  // عشان Express يعرف إنه Error Handler (الـ 4 params signature)

  // Step 1: Set defaults لو الـ error مش ApiError
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  // Step 2: Development vs Production
  if (process.env.NODE_ENV === 'development') {
    devError(err, res);
    // ← بيبعت كل التفاصيل: error object, message, stack
  } else {
    // Step 3: Production — transform specific errors
    let error = { ...err, message: err.message };
    // لماذا نعمل spread؟ عشان نعمل shallow copy ومش نعدل على الـ original err

    if (error.name === 'CastError') {
      error = handleCastErrorDB(error);           // invalid ObjectId
    } else if (error.code === 11000) {
      error = handleDuplicateFieldsDB(error);     // duplicate unique field
    } else if (error.name === 'ValidationError') {
      error = handleValidationErrorDB(error);     // mongoose validation
    } else if (error.name === 'JsonWebTokenError') {
      error = new ApiError(401, 'Invalid token. Please log in again!');
    } else if (error.name === 'TokenExpiredError') {
      error = new ApiError(401, 'Your token has expired! Please log in again.');
    }

    productionError(error, res);
    // ← بيتحقق من isOperational ويبعت الـ message المناسبة
  }
};
```

**إزاي الـ Errors بتوصل للـ Error Handler؟**

**طريقة 1 — `next(err)` في async code:**

```js
app.get('/', async (req, res, next) => {
  try {
    const data = await someOperation();
  } catch(err) {
    next(err); // ← بتبعت الـ error للـ error handler
  }
});
```

**طريقة 2 — `throw` في Express 5 async:**

```js
// Express 5 بيـ catch الـ async errors تلقائياً
app.get('/', async (req, res) => {
  throw new ApiError(404, 'Not found'); // ← بيوصل للـ error handler مباشرة
});
```

**طريقة 3 — `throw` في sync middleware:**

```js
app.use((req, res, next) => {
  throw new ApiError(401, 'Unauthorized'); // ← Express بيمسكه تلقائياً
});
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
أي طبقة: throw new ApiError(404, 'User not found')
                      │
                      ▼ Express بيمسك الـ Error
                      │ (لأنه Unhandled في الـ chain)
                      │
                      ▼ errorHandler(err, req, res, _next)
                      │
                      ├── NODE_ENV = 'development':
                      │     devError → { status, error, message, stack }
                      │
                      └── NODE_ENV = 'production':
                            ├── CastError? → ApiError(400, 'Invalid ID')
                            ├── Code 11000? → ApiError(409, 'Duplicate')
                            ├── ValidationError? → ApiError(400, ...)
                            ├── JWTError? → ApiError(401, 'Invalid token')
                            └── productionError:
                                  ├── isOperational? → send message
                                  └── Not operational? → 'something went wrong'
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — `{ ...err, message: err.message }` مش بيعمل Deep Copy:**

```js
let error = { ...err, message: err.message };
```

الـ Spread Operator عامل `shallow copy`. الـ `Error` object في JavaScript عنده properties غير enumerable (زي `stack` و `message`). الـ spread مش بياخدهم تلقائياً، ولذلك `message` بياخده manually. لكن لو في nested objects في الـ error، هتبقى references مش copies.

**عيب 2 — مفيش معالجة لـ 404 Routes:**

```js
// في app.js، مفيش:
app.use('*', (req, res) => {
  throw new ApiError(404, `Can't find ${req.originalUrl} on this server!`);
});
```

لو حد طلب `/api/nonexistent`، Express هيرجعله HTML error page افتراضية بدل JSON. ده مش اتسوى في المشروع.

**عيب 3 — الـ Error Handler مضاف مرتين (زي ما اتكلمنا في Chapter 02):**

```js
// app.js: app.use(errorHandler);
// index.js: app.use(errorHandler); // ← duplicate
```

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه الـ Error Handler في Express لازم يكون عنده 4 parameters؟

**Q2:** ليه الـ Error Handler لازم يكون **آخر** middleware يتضاف للـ app؟ إيه اللي هيحصل لو حطيناه في النص؟

> **إجابة نموذجية:** لأن الـ Middleware في Express بيتنفذ بالترتيب. الـ Error Handler بيشتغل بس لما يجيله Error من الـ Middlewares اللي قبله. لو حطيناه في النص، الـ Routes والـ Middlewares اللي بعده مش هتوصلهم الـ Errors.

**Q3:** إيه هو `_next` في الـ Error Handler؟ ليه بنستخدم underscore؟

---

## Chapter 11 — rateLimit.js (Custom Rate Limiter)

---

### 1. الكونسبت العام (The Story)

تخيل إنك صاحب بوفيه مفتوح. المفروض كل شخص ياخد أكل معقول. لكن جاء واحد "أكلاتي" وبدأ يملا 20 طبق في مرة. لو مفيش قاعدة، هو هيخلص الأكل ومحدش غيره هياكل.

الـ Rate Limiting بيقول: "يا معلم، كل شخص يقدر يطلب request معين عدد مرات في فترة زمنية معينة." لو تجاوز الحد، بنقوله `429 Too Many Requests`.

المشروع ده عمل الـ Rate Limiter من الصفر باستخدام `Map` بدل library جاهزة زي `express-rate-limit`. الـ Map ده:

- **Key**: الـ IP Address
- **Value**: `{ count: 5, firstTime: 1234567890 }`

---

### 2. مثال عام بسيط

```js
const store = new Map(); // { 'ip1': { count: 3, firstTime: 123 } }
const WINDOW = 60 * 1000; // 1 minute
const MAX = 100;

const rateLimiter = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();
  const entry = store.get(ip);

  if (!entry || now - entry.firstTime >= WINDOW) {
    store.set(ip, { count: 1, firstTime: now }); // ← إما جديد أو انتهى الـ window
    return next();
  }

  if (entry.count < MAX) {
    entry.count++;
    return next();
  }

  return res.status(429).json({ message: 'Too many requests' });
};
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/rateLimit.js`:**

```js
const requests = new Map();   // الـ In-Memory store
const WINDOW_TIME = 60 * 1000; // 1 دقيقة بالـ milliseconds
const MAX_REQUESTS = 100;       // أقصى عدد requests في الـ window

// Cleanup Job — بيتشغل كل 30 ثانية لمسح الـ IPs القديمة
setInterval(() => {
  const now = Date.now();
  requests.forEach(({ firstTime }, ip) => {
    if (now - firstTime > WINDOW_TIME) {
      requests.delete(ip); // ← بيمسح الـ IP من الـ Map
    }
  });
}, WINDOW_TIME / 2); // ← كل 30 ثانية (نص الـ window)

const rateLimiter = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();

  // Case 1: أول مرة الـ IP ده بييجي
  if (!requests.has(ip)) {
    requests.set(ip, { count: 1, firstTime: now });
    return next();
  }

  let { count, firstTime } = requests.get(ip);

  // Case 2: الـ IP موجود في الـ Map
  if (now - firstTime < WINDOW_TIME) {
    // لسه في الـ Window
    if (count < MAX_REQUESTS) {
      count += 1;
      requests.set(ip, { count, firstTime }); // ← update الـ count
      return next();
    }
    // تجاوز الـ Limit!
    return res.status(429).json({ message: 'Too many requests. Please try again later.' });
  }

  // Case 3: الـ Window انتهت → reset
  requests.set(ip, { count: 1, firstTime: now });
  next();
};
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
أي HTTP Request
       │
       ▼ app.js: app.use(rateLimiter) ← من أول الـ middlewares
       │
       ▼ rateLimiter:
       │   → req.ip = '192.168.1.1'
       │   → requests.get('192.168.1.1') = { count: 99, firstTime: ... }
       │   → count < 100? → count = 100 → next()
       │
       ├── الـ 101st request من نفس الـ IP:
       │     count >= 100 → 429 Too Many Requests ❌
       │
       └── بعد دقيقة:
             now - firstTime >= WINDOW_TIME → reset → count = 1 ✅
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الأهم: مش بيشتغل على Serverless! 💥**

الـ Rate Limiter بيستخدم `Map` في الـ Memory. على Vercel Serverless، كل Request ممكن تشتغل في **Lambda Function مختلفة** — يعني الـ Map بتبدأ فاضية مع كل Lambda. ده معناه إن الـ Rate Limiter مش بيشتغل فعلياً على Production.

الحل الصح: استخدام **Redis** (External Store) أو library زي `express-rate-limit` مع Redis adapter.

**عيب 2 — الـ IP ممكن يكون غلط خلف Proxy:** `req.ip` بييجي من `X-Forwarded-For` header على Vercel. لو الـ app مش مضبوطة على trust proxy، ممكن يرجع IP الـ proxy نفسه بدل IP المستخدم.

```js
// في app.js لازم يضاف:
app.set('trust proxy', 1);
```

**عيب 3 — مفيش Differentiation بين Routes:** نفس الـ limit بيطبق على كل الـ endpoints. المفروض الـ `/api/auth/login` يكون عنده limit أقل (مثلاً 10 requests/minute) عشان يمنع الـ Brute Force attacks.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه عملت Custom Rate Limiter بدل `express-rate-limit`؟

> **إجابة نموذجية للـ Discussion:** عملته عشان أفهم كيف بيشتغل من الداخل، لكن للـ Production الحقيقية، `express-rate-limit` مع Redis store أفضل بكتير لأنه بيدعم Distributed Systems.

**Q2:** إيه هو `setInterval` في الكود ده ولماذا موجود؟

**Q3:** ليه الـ Rate Limiter مش بيشتغل صح على Vercel Serverless؟

---

## Chapter 12 — logger.js (Pino HTTP Logger)

---

### 1. الكونسبت العام (The Story)

تخيل إن بيتك عنده كاميرات مراقبة. الـ `console.log` زي واحد واقف في الباب ومش بيكتب حاجة — بس بيصرخ بصوت عالي "دخل حد!". الـ Pino Logger زي الكاميرات — بيسجل كل حاجة بتفاصيل: مين دخل، امتى، من فين، وإيه اللي عمله.

الـ Pino هو **أسرع HTTP Logger في Node.js ecosystem**. الـ Speed بتيجي من إنه بيكتب الـ Logs في **Ndjson format** (JSON سطر بسطر) بدل إنه يـ format كل حاجة في الوقت الفعلي.

---

### 2. مثال عام بسيط

```js
const pino = require('pino');
const pinoHttp = require('pino-http');

// الـ Logger الأساسي
const logger = pino({ level: 'info' });

// الـ HTTP Logger — بيـ wrap كل Request تلقائياً
const httpLogger = pinoHttp({ logger });

app.use(httpLogger); // ← كل request هتتسجل تلقائياً

// استخدام يدوي:
logger.info('Server started');
logger.error({ err }, 'Something went wrong');
```

---

### 3. شرح التطبيق في المشروع

**`src/middlewares/logger.js`:**

```js
const pino = require('pino');
const pinoHttp = require('pino-http');

const logger = pino({
  level: 'info',
  // في Development: بيستخدم pino-pretty لـ human-readable output
  transport: process.env.NODE_ENV !== 'production'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined
    // في Production: بيكتب JSON بدون formatting (أسرع)
});

const httpLogger = pinoHttp({ logger });

module.exports = { logger, httpLogger };
```

**في Development، الـ Output بيبقى زي ده:**

```
[2024-01-15 10:30:25] INFO: POST /api/auth/register
    statusCode: 201
    responseTime: 45 ms
    req: { method: 'POST', url: '/api/auth/register', ... }
    res: { statusCode: 201 }
```

**في Production، الـ Output بيبقى JSON خام:**

```json
{"level":30,"time":1705312225000,"req":{"method":"POST","url":"/api/auth/register"},"res":{"statusCode":201},"responseTime":45}
```

**ليه JSON في Production؟** لأن الـ Log Management Systems (زي Datadog، CloudWatch، ELK Stack) بتـ parse JSON automatically وبتعرف تعمل search وfilter عليه.

---

### 4. الربط بالصورة الكاملة (The Glue)

```
HTTP Request يوصل
       │
       ▼ app.js: app.use(httpLogger)
       │  → pinoHttp بيضيف req.log للـ request
       │  → بيبدأ يحسب الـ response time
       │
       ▼ باقي الـ Middlewares والـ Controllers...
       │
       ▼ لما الـ Response يتبعت:
          → pinoHttp بيسجل: method, url, statusCode, responseTime
          → في Development: pino-pretty format ملون
          → في Production: JSON raw line
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ logger مش بيتستخدم للـ Non-HTTP Errors:**

```js
// في errorHelpers.js:
console.error('error', err); // ← المفروض يكون logger.error
```

الـ `logger` object موجود ومتاح للاستخدام، لكن الـ errorHelpers مش بيـ import ومش بيستخدم. ده inconsistency في الـ logging strategy.

**عيب 2 — مفيش Log Levels مختلفة:** الكود بيحدد `level: 'info'` فقط. ده معناه إن `logger.debug()` calls مش هتتسجل. في Development، الأفضل تبقى `level: 'debug'` عشان تشوف أكتر تفاصيل.

**عيب 3 — الـ Sensitive Data ممكن تتسجل:** الـ `pinoHttp` بيسجل الـ Request body تلقائياً. لو في request فيه password أو token، هيتسجل في الـ Logs. لازم تعمل `redact`:

```js
const httpLogger = pinoHttp({
  logger,
  redact: ['req.body.password', 'req.headers.authorization'] // ← إخفاء البيانات الحساسة
});
```

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنستخدم Pino بدل `console.log`؟ إيه الـ difference في الـ Use Case؟

**Q2:** ليه الـ `pino-pretty` transport بيتستخدم في Development بس مش Production؟

> **إجابة:** `pino-pretty` بتعمل formatting وألوان لجعل الـ Logs قابلة للقراءة للـ Developer. لكن الـ formatting دي بتاخد وقت وـ Memory. في Production، السرعة أهم، وبنكتب JSON خام اللي بيتقرأ بـ Log Management Tools.

**Q3:** إيه هو `req.log` اللي `pinoHttp` بيضيفه للـ Request؟

---

# 🗄️ الفصل الرابع: طبقة الـ Models — خريطة البيانات

---

## Chapter 13 — User Model

---

### 1. الكونسبت العام (The Story)

الـ User Model هو "البطاقة الشخصية" لكل مستخدم في قاعدة البيانات. لكن مش بس بيحفظ البيانات — عنده منطق مدمج فيه:

- **قبل الحفظ:** لو في password جديد، يـ hash إياه تلقائياً
- **Instance Methods:** وظائف بتشتغل على كل document زي `correctPassword()` و `changedPasswordAfter()`

ده اللي بيسموه **Fat Model, Thin Controller** — الـ Logic بتتحول للـ Model بدل ما الـ Controller يتعمل ضخم.

---

### 2. مثال عام بسيط

```js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true, select: false } // ← hidden by default!
});

// Pre-save Hook: بيشتغل أوتوماتيك قبل كل save
userSchema.pre('save', async function() {
  if (!this.isModified('password')) return; // ← مش هيـ hash لو مش اتغير
  this.password = await bcrypt.hash(this.password, 12);
});

// Instance Method: بتشتغل على كل document
userSchema.methods.checkPassword = async function(plainText) {
  return bcrypt.compare(plainText, this.password);
};
```

---

### 3. شرح التطبيق في المشروع

**`src/models/user.js` — التشريح الكامل:**

```js
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    index: true,            // ← Index عشان الـ findOne({ email }) يبقى سريع
    required: [true, 'email is required'],
    unique: true,           // ← MongoDB Unique Index
    lowercase: true,        // ← بيحول للـ lowercase تلقائياً قبل الحفظ
    validate: [validator.isEmail, 'please provide a valid email']
    // validator هو library جاهزة بتتحقق من الـ email format
  },
  firstName: {
    type: String,
    required: [true, 'first name is required'],
    minlength: 2,
    maxlength: 25,
    trim: true,             // ← بيشيل الـ spaces الزيادة
    lowercase: true
  },
  password: {
    type: String,
    required: [true, 'password is required'],
    minlength: 8,
    maxlength: 50,
    select: false           // ← مش بيتجب تلقائياً في أي Query! الأهم في الـ Model
  },
  passwordChangedAt: Date,  // ← بيتحدث لما المستخدم يغير الـ password
  isVerified: {
    type: Boolean,
    default: false           // ← default: user غير مؤكد
  },
  role: {
    type: String,
    enum: ['user', 'admin'], // ← بس الـ values دول المسموحة
    default: 'user'          // ← كل user جديد بدور 'user'
  }
}, { timestamps: true });   // ← بيضيف createdAt و updatedAt تلقائياً
```

**الـ Pre-Save Hook:**

```js
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  // لو الـ password ما اتغيرش (زي update للـ firstName مثلاً) → مش هنعيد الـ hashing
  // ده performance optimization مهم!

  this.password = await bcrypt.hash(this.password, 12);
  // 12 = salt rounds. كل ما زادت، كل ما كان أصعب على الـ Brute Force
  // لكن بياخد وقت أطول في الـ hashing
  // 12 هو توازن جيد بين الأمان والـ Performance
});
```

**الـ Instance Methods:**

```js
// Method 1: بتتحقق من الـ Password
userSchema.methods.correctPassword = async function(candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
  // candidatePassword: الـ plain text اللي المستخدم بعته
  // userPassword: الـ hashed password من الـ DB
  // بنمرر userPassword explicitly لأن password.select = false
  // this.password مش متاح في الـ instance
};

// Method 2: هل الـ Password اتغير بعد إصدار الـ Token؟
userSchema.methods.changedPasswordAfter = function(JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = Number.parseInt(
      this.passwordChangedAt.getTime() / 1000, // ← تحويل من milliseconds لـ seconds
      10
    );
    return JWTTimestamp < changedTimestamp;
    // لو الـ JWT صدر قبل تغيير الـ Password → true (خطر!)
    // لو الـ JWT صدر بعد تغيير الـ Password → false (تمام)
  }
  return false; // مفيش تغيير في الـ Password
};
```

**`select: false` على الـ Password:**

ده من أهم الـ Security features في الـ Model. لما تعمل `User.findOne({ email })` عادي، الـ password مش بييجي في الـ result. لو حد مثلاً:

```js
const user = await User.findById(id);
res.json(user); // ← password مش موجود! ✅
```

لكن لما نحتاج نتحقق من الـ password (في الـ login)، بنضيف `select('+password')`:

```js
const user = await User.findOne({ email }).select('+password'); // ← بنجيب الـ password
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/auth/login
  { email: 'mo@test.com', password: 'Pass123!' }
                  │
                  ▼ controllers/auth.js → login()
                  │
                  ▼ User.findOne({ email }).select('+password')
                  │  → SELECT password explicitly (لأن select: false)
                  │
                  ▼ user.correctPassword('Pass123!', user.password)
                  │  → bcrypt.compare(plain, hashed) → true ✅
                  │
                  ▼ generateToken(user)
                  │  → jwt.sign({ _id, email, role }, secret, { expiresIn })
                  │
                  ▼ res.json({ token })

--- في كل Protected Request ---
                  │
                  ▼ protect middleware:
                  │  → User.findById(decodedToken._id)
                  │  → freshUser.changedPasswordAfter(decodedToken.iat)
                  │  → req.user = freshUser (بدون password!)
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — `dob` validation باستخدام `max: Date.now()` في الـ Schema:**

```js
dob: {
  type: Date,
  required: [true, 'date of birth is required'],
  min: '1900-01-01',
  max: Date.now() // ← المشكلة هنا!
}
```

`Date.now()` بيتقيّم مرة واحدة وقت تحميل الـ Module. ده معناه إن الـ max date بيتحدد مرة واحدة لما السيرفر بيبدأ. لو السيرفر شغال لمدة سنة، الـ max date ستبقى من سنة فاتت وأي حد بيحاول يسجل بـ DOB اليوم هيتمنع!

الحل:

```js
dob: {
  type: Date,
  validate: {
    validator: function(v) { return v <= Date.now(); }, // ← بيتقيّم وقت الـ validation
    message: 'Date of birth must be in the past'
  }
}
```

**عيب 2 — `isVerified` field موجود بدون Email Verification Flow:** الـ field موجود في الـ Schema (`isVerified: Boolean`) لكن مفيش في أي مكان في الكود email verification mechanism (send email, verify token). ده means الـ field عمياء موجودة مش بتستخدم.

**عيب 3 — مفيش `passwordConfirm` في الـ Registration:** لو المستخدم كتب الـ Password غلط مرتين، مش في validation. الـ Joi registerSchema كمان مش فيها `confirmPassword` check.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنعمل `select: false` على الـ password field في الـ Mongoose Schema؟ هل ده بيمنع تماماً إن الـ password يتجب؟

**Q2:** إيه هو الـ `pre('save')` hook؟ ليه بنتحقق من `isModified('password')` قبل الـ hashing؟

> **إجابة نموذجية:** الـ `pre('save')` بيشتغل قبل كل save operation. `isModified` بنستخدمها عشان نتجنب إننا نعيد الـ hashing في كل مرة نعدل الـ user (زي لما نعدل الـ firstName). لو الـ password ما اتغيرش، الـ hashing مش ضروري.

**Q3:** ليه `correctPassword` بتاخد الـ `userPassword` كـ parameter بدل ما تستخدم `this.password`؟

---

## Chapter 14 — Book Model

---

### 1. الكونسبت العام (The Story)

الـ Book Model مش بس بيحفظ بيانات الكتب — عنده تقنيتين متقدمتين مهمتين جداً:

1. **Virtual Field**: `status` — بيحسب حالة الكتاب (In Stock / Low Stock / Out of Stock) **on-the-fly** من الـ `stock` field من غير ما يتحفظ في الـ DB.
    
2. **Text Index**: بيسمح بعمل **Full-Text Search** على اسم الكتب باستخدام `$text: { $search: 'harry potter' }`.
    

---

### 2. مثال عام بسيط

```js
// Virtual Field — بيتحسب وقت القراءة، مش محفوظ في DB
bookSchema.virtual('isExpensive').get(function() {
  return this.price > 100;
});

// Text Index — بيمكن الـ Full-Text Search
bookSchema.index({ name: 'text', description: 'text' });
// بعد كده: Book.find({ $text: { $search: 'harry potter' } })
```

---

### 3. شرح التطبيق في المشروع

**`src/models/book.js`:**

```js
const bookSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true, min: 0 },
  stock: { type: Number, required: true, min: 0 },
  coverImage: { type: String, required: true }, // ← Cloudinary URL
  author: {
    type: mongoose.Schema.Types.ObjectId, // ← Reference للـ Author Document
    ref: 'Author',                         // ← Model name للـ Populate
    required: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    default: null  // ← Optional — الكتاب ممكن يكون uncategorized
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },    // ← لازمين عشان الـ Virtuals تبان في الـ Response
  toObject: { virtuals: true }   // ← لما بتستخدم .toObject() method
});

// Virtual Field
bookSchema.virtual('status').get(function () {
  if (this.stock > 10) return 'In Stock';
  if (this.stock > 0) return 'Low Stock';
  return 'Out of Stock';
});

// Text Index على الـ name field
bookSchema.index({ name: 'text' });
// ← بيعمل MongoDB Text Index على الـ name field
// ← بيسمح بـ: Book.find({ $text: { $search: 'clean code' } })

// Regular Index على الـ price للـ Range Queries
bookSchema.index({ price: 1 });
// ← بيسرع queries زي: Book.find({ price: { $gte: 50, $lte: 200 } })
```

**إزاي الـ Virtual بيتعمل في الـ Response:**

```json
// بدون toJSON: { virtuals: true }:
{
  "_id": "...",
  "name": "Clean Code",
  "stock": 5,
  "price": 150
  // status مش موجود!
}

// مع toJSON: { virtuals: true }:
{
  "_id": "...",
  "name": "Clean Code",
  "stock": 5,
  "price": 150,
  "status": "Low Stock"  // ← اتحسب تلقائياً!
}
```

**الـ Full-Text Search في الـ Controller:**

```js
// controllers/book.js:
const getAllBooks = async (req, res) => {
  const { search, category, author, minPrice, maxPrice } = req.query;

  const query = {};
  if (search) query.$text = { $search: search };
  // $text operator بيشتغل بس لو في Text Index على الـ field

  if (minPrice || maxPrice) {
    query.price = {};
    if (minPrice) query.price.$gte = Number(minPrice);
    if (maxPrice) query.price.$lte = Number(maxPrice);
  }

  const { data: books, pagination } = await paginate(Book, query, ...);
};
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
GET /api/books?search=clean+code&minPrice=50&maxPrice=200&category=<id>

  query object يتبني:
  {
    $text: { $search: 'clean code' }, // ← Full-Text Search
    price: { $gte: 50, $lte: 200 },  // ← Range Query (يستفيد من price index)
    category: '<id>'
  }
                │
                ▼ paginate() function
                │  → Book.find(query)
                │     .sort({ name: 1 })
                │     .populate('author category')
                │     .skip((page-1) * limit)
                │     .limit(limit)
                │
                ▼ MongoDB يستخدم الـ Indexes
                │  → Text Index للـ $text search
                │  → Price Index للـ range query
                │
                ▼ Response:
                  {
                    books: [{ name, price, stock, status: 'Low Stock', author: {...} }],
                    pagination: { ... }
                  }
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ Text Index على `name` بس:**

```js
bookSchema.index({ name: 'text' });
```

لو حد بحث عن اسم المؤلف أو الـ category، الـ Full-Text Search مش هيلاقيه. الأفضل:

```js
bookSchema.index({ name: 'text', description: 'text' }); // لو في description
```

**عيب 2 — مفيش `description` field للكتاب:** الـ Schema عنده `name, price, stock, coverImage, author, category`. مفيش `description` أو `isbn` أو `publishedDate`. ده مش error لكنه limitation في الـ domain model.

**عيب 3 — الـ `coverImage` بيخزن URL مش Cloudinary Public ID:** لو المستخدم حذف الصورة من Cloudinary بعدين، الـ URL في الـ DB لسه موجود وهيكسر. الأفضل تخزين `publicId` بدل الـ URL كامل عشان تعرف تتعامل مع الـ deletion.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Virtual Field في Mongoose؟ هل بيتحفظ في الـ Database؟

> **إجابة:** لا، الـ Virtual Field مش بيتحفظ في الـ DB. بيتحسب `on-the-fly` من الـ Document properties. فايدته إنك مش محتاج تحفظ data يمكن استنتاجها من data تانية.

**Q2:** إيه هو الـ `$text` operator في MongoDB؟ شرط تشتغل إيه؟

**Q3:** ليه محتاجين `toJSON: { virtuals: true }` و `toObject: { virtuals: true }` في الـ Schema options؟

---

## Chapter 15 — Cart Model

---

### 1. الكونسبت العام (The Story)

لما صممت الـ Cart، كان فيه قرار معماري مهم: هل تعمل **Collection مستقلة** للـ Cart Items (كل item = document)؟ أم تعمل **Embedded Array** داخل Document واحد للـ User؟

القرار اللي اتاخد هو الـ **Embedded Array** — الـ Cart كله (user + items) في Document واحد.

**ليه Embedded وليس Referenced؟**

- الـ Cart دايماً بتتقرأ كـ وحدة واحدة (محتاج كل الـ items مع بعض)
- الـ Cart مرتبطة بـ User واحد بس (1-to-1)
- الـ Write operations على الـ Cart دايماً بتحدث في نفس الـ Document
- ده بيخلي الـ Read/Write أسرع لأنه document واحد بدل multiple documents

---

### 2. مثال عام بسيط

```js
// Referenced Approach — مش اللي استخدمناه
// CartItem Collection: { cartId, bookId, quantity }
// Cart Collection: { userId }
// ← محتاج 2 queries للـ join

// Embedded Approach — اللي استخدمناه ✅
// Cart Collection: { userId, books: [{ bookId, quantity }] }
// ← document واحد = كل البيانات
const cartSchema = new mongoose.Schema({
  userId: { type: ObjectId, ref: 'User', unique: true }, // ← 1 cart per user
  books: [{ bookId: ObjectId, quantity: Number }]         // ← Embedded array
});
```

---

### 3. شرح التطبيق في المشروع

**`src/models/cart.js`:**

```js
const cartSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true  // ← كل user عنده cart واحدة بس!
  },
  books: [
    {
      bookId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Book',
        required: true
      },
      quantity: {
        type: Number,
        required: true,
        min: 1  // ← quantity لازم تكون على الأقل 1
      }
    }
  ]
}, { timestamps: true });
```

**الـ Unique constraint على userId:** ده بيضمن إن كل user مش ممكن يبقى عنده أكتر من Cart واحدة. لو حاولت تعمل Cart تانية لنفس الـ userId، MongoDB هيرمي Duplicate Key Error (11000).

**إزاي الـ Cart Controller بيستخدمه:**

```js
// في controllers/cart.js:
// لو الـ Cart موجودة → جيبها، لو لأ → اعمل واحدة جديدة
const cart = await Cart.findOne({ userId }) || new Cart({ userId, books: [] });
//                                              ↑
//                                              بيعمل instance جديد بس مش بيحفظه
//                                              للـ DB لحد ما نعمل cart.save()
```

**الـ `$pull` operator للحذف:**

```js
// في removeItem:
const cart = await Cart.findOneAndUpdate(
  { userId },
  { $pull: { books: { bookId } } }, // ← بيشيل من الـ array بشرط
  { new: true }
);
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/cart — إضافة كتاب للـ Cart

  1. Cart.findOne({ userId }) → cart موجود أو null
  2. لو null → new Cart({ userId, books: [] })
  3. cart.books.find(b => b.bookId === bookId) → موجود في الـ cart؟
  4. لو موجود → زيد الـ quantity
  5. لو مش موجود → cart.books.push({ bookId, quantity })
  6. check stock: newQuantity > book.stock → ApiError(400)
  7. cart.save() → بيحفظ الـ Document كامل
  8. cart.populate() → بيجيب book details
  9. totalPrice = reduce على الـ books array
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — Race Condition في الـ Stock Check:**

```js
// في addItem:
const newQuantity = (bookInCart?.quantity || 0) + quantity;
if (newQuantity > book.stock) throw new ApiError(400, 'Not enough stock');
// ثم:
cart.books.push({ bookId, quantity: newQuantity });
await cart.save();
```

لو اتنين users حاولوا يضيفوا نفس الكتاب في نفس الوقت، ممكن الاتنين يشوفوا `book.stock = 5` وكلهم يضيفوا 5. في الـ Order Service، في Transaction بيحل المشكلة دي، لكن في الـ Cart نفسها مفيش protection.

**عيب 2 — الـ `cart.save()` ثم `cart.populate()` — 2 Operations:**

```js
await cart.save();
await cart.populate({ path: 'books.bookId', ... });
```

ده 2 DB operations منفصلين. الأفضل ممكن يكون populate مع findOne واحد. لكن Mongoose مش بيسمح بـ populate مع save في نفس الوقت، فده acceptable trade-off.

**عيب 3 — مفيش TTL (Time To Live) للـ Abandoned Carts:** الـ Carts الفاضية أو القديمة بتفضل في الـ DB للأبد. في Production، بنعمل TTL index عشان نمسح الـ Carts اللي ما فيهاش activity من فترة:

```js
cartSchema.index({ updatedAt: 1 }, { expireAfterSeconds: 30 * 24 * 60 * 60 }); // 30 days
```

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه الفرق بين Embedded Documents و Referenced Documents في MongoDB؟ ليه اخترنا Embedded للـ Cart?

**Q2:** إيه هو `$pull` operator في MongoDB وإزاي بيشتغل؟

**Q3:** إيه معنى `unique: true` على الـ `userId` في الـ Cart Schema؟ إيه اللي يحصل لو حاولنا نعمل Cart تانية لنفس الـ User؟

---

## Chapter 16 — Order Model

---

### 1. الكونسبت العام (The Story)

الـ Order Model عنده فلسفة مهمة جداً: **لازم الـ Order يكون Snapshot من الواقع وقت الشراء**.

تخيل إنك اشتريت كتاب بـ 100 جنيه. بعد أسبوع، الأدمن غير سعر الكتاب لـ 150 جنيه. أوردرك المفروض لسه يقول 100 جنيه — مش المفروض يتأثر بتغيير السعر.

ده سبب وجود `priceAtPurchase` field — بيحفظ **السعر وقت الشراء** مش reference للـ Book اللي ممكن تتغير.

وعنده كمان **State Machine** للـ Status — مش أي status ممكن يتغير لأي status.

---

### 2. مثال عام بسيط

```js
// الفكرة: price snapshot
const orderItemSchema = {
  bookId: ObjectId,
  quantity: Number,
  priceAtPurchase: Number  // ← مش بيتغير حتى لو البوك اتغير
};

// State Machine
const StateTransition = {
  'processing': 'out_for_delivery',      // → ممكن يتحول لـ
  'out_for_delivery': 'delivered'        // → ممكن يتحول لـ
  // 'delivered': لا شيء ← Final state
};
```

---

### 3. شرح التطبيق في المشروع

**`src/models/order.js`:**

```js
const orderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [
    {
      bookId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Book',
        required: true
      },
      quantity: { type: Number, required: true, min: 1 },
      priceAtPurchase: { type: Number, required: true, min: 0 }
      // ← الـ snapshot المهم!
    }
  ],
  shippingDetails: {
    fullName: { type: String, required: true },
    address: { type: String, required: true },
    city: { type: String, required: true },
    phone: { type: String, required: true }
    // ← Embedded shipping info — snapshot تاني!
    // لو المستخدم غير عنوانه، الأوردر القديم لسه بيوري العنوان الأصلي
  },
  status: {
    type: String,
    enum: ['processing', 'out_for_delivery', 'delivered'],
    default: 'processing'
  },
  paymentMethod: {
    type: String,
    enum: ['COD', 'credit_card'],
    default: 'COD'
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'success'],
    default: 'pending'
  }
}, { timestamps: true });
```

**الـ State Machine في الـ Controller:**

```js
// controllers/order.js:
const StateTransition = {
  processing: 'out_for_delivery',
  out_for_delivery: 'delivered'
};

const updateOrderStatus = async (req, res) => {
  const { status } = req.body;
  const order = await Order.findById(id);

  if (status) {
    if (StateTransition[order.status] !== status) {
      throw new ApiError(400, `Can't change order status from '${order.status}' to '${status}'`);
    }
    // ← processing → delivered مباشرة: ❌ مسموحش
    // ← processing → out_for_delivery: ✅ مسموح
    // ← out_for_delivery → delivered: ✅ مسموح
    order.status = status;
  }
};
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/orders (Order Placement Flow)

services/order.js (Transaction):
  1. Cart.findOne({ userId }) → cart items
  2. لكل item: Book.findById → تحقق من الـ stock
  3. بناء orderItems = [{ bookId, quantity, priceAtPurchase: book.price }]
  4. Book.findByIdAndUpdate(id, { $inc: { stock: -quantity } }) → خصم من الـ stock
  5. Order.create([orderData], { session }) → إنشاء الأوردر
  6. cart.books = [] → مسح الـ cart
  7. session.commitTransaction() → تأكيد كل الخطوات مع بعض
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — مفيش حساب الـ Total Price في الـ Order:**

```js
// الـ Order Model مش عنده totalPrice field
// المفروض يتحسب من:
// items.reduce((sum, item) => sum + item.priceAtPurchase * item.quantity, 0)
```

ده معناه لازم الـ Frontend أو الـ Client يحسبه من الـ items. الأفضل تحفظه في الـ Order:

```js
totalPrice: { type: Number, required: true }
```

**عيب 2 — الـ `paymentMethod === 'credit_card'` logic مبسطة جداً:**

```js
paymentStatus: paymentMethod === 'credit_card' ? 'success' : 'pending'
```

في الواقع، الـ credit card payment محتاج integration مع payment gateway (Stripe, Paymob). هنا بيفترض إن الـ credit card payment ناجح دايماً — ده مش realistic.

**عيب 3 — مفيش Cancellation Flow:** الـ Status enum بيه `processing, out_for_delivery, delivered`. مفيش `cancelled`. لو العميل عايز يلغي الأوردر؟

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه بنحفظ `priceAtPurchase` في الـ Order Item بدل ما نرجع للـ Book ونجيب الـ price؟

**Q2:** إيه هو الـ State Machine Pattern؟ ليه استخدمناه هنا؟

**Q3:** ليه الـ `shippingDetails` Embedded في الـ Order ومش Referenced للـ User Address؟

---

## Chapter 17 — Review Model

---

### 1. الكونسبت العام (The Story)

الـ Review Model عنده قيد مهم جداً: **كل مستخدم يقدر يكتب review واحدة بس لكل كتاب**. المتجر ما يقدرش يسمح لحد يكتب 100 review لنفس الكتاب عشان يرفع الـ rating.

الحل: **Compound Unique Index** على `{ user, book }` — ده بيخلي MongoDB يرفض أي document تاني بنفس الـ user و book.

---

### 2. مثال عام بسيط

```js
// Single Field Unique Index — email لازم unique
userSchema.index({ email: 1 }, { unique: true });

// Compound Unique Index — الـ combination لازم unique
reviewSchema.index({ user: 1, book: 1 }, { unique: true });
// ← نفس الـ user يقدر يعمل review لكتب مختلفة ✅
// ← نفس الـ user مش يقدر يعمل review تانية لنفس الكتاب ❌
```

---

### 3. شرح التطبيق في المشروع

**`src/models/review.js`:**

```js
const reviewSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  book: {
    type: Schema.Types.ObjectId,
    ref: 'Book',
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  comment: {
    type: String,
    maxLength: 500  // ← اختياري بس بـ limit
  }
}, { timestamps: true });

// الـ Compound Unique Index — هنا بقى السر!
reviewSchema.index({ user: 1, book: 1 }, { unique: true });
// 1 = ascending order في الـ Index
// unique: true = MongoDB يرفض duplicate combinations
```

**إزاي الـ Controller بيتعامل مع الـ Duplicate:**

```js
// controllers/review.js:
try {
  const review = await Review.create({ user: userId, book: bookId, rating, comment });
  return res.json(new ApiResponse(201, 'Review created successfully', review));
} catch (err) {
  if (err.code === 11000) {
    // 11000 = MongoDB Duplicate Key Error
    throw new ApiError(409, 'You have already reviewed this book');
  }
  throw new ApiError(500, 'Failed to create review', err);
}
```

**الـ Purchase Gate — Business Rule مهم:**

```js
// ممكن تكتب review بس لو اشتريت الكتاب ووصلك!
const hasPurchased = await Order.exists({
  userId,
  'status': 'delivered',           // ← الأوردر وصل
  'items.bookId': bookId            // ← وفيه الكتاب ده
});
if (!hasPurchased) {
  throw new ApiError(403, 'You can not review this book until you have purchased and received it.');
}
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/books/:bookId/reviews
  { rating: 5, comment: "Great book!" }
                  │
                  ▼ validate(createReviewSchema)
                  │
                  ▼ protect → req.user
                  │
                  ▼ createReview controller:
                  │   1. Book.findById(bookId) → موجود؟
                  │   2. Order.exists({ userId, status: 'delivered', 'items.bookId': bookId })
                  │      → اشترى وستلم؟
                  │   3. Review.create({ user, book, rating, comment })
                  │      → لو duplicate → err.code === 11000 → ApiError(409)
                  │
                  ▼ Response: 201 Created
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — Extra Validation في الـ Controller بعد Joi:**

```js
// في createReview controller:
if (!rating) throw new ApiError(400, 'Rating is required');
if (rating < 1 || rating > 5) throw new ApiError(400, 'Rating must be between 1 and 5');
```

الـ Joi Schema بالفعل عندها:

```js
rating: joi.number().integer().min(1).max(5).required()
```

الـ validation دي في الـ Controller **redundant** — Joi بالفعل بيتحقق من نفس الشيء. ده بيحصل لما الـ Developer ينسى إن في validation layer. الـ Controller المفروض يثق في الـ Joi ويشتغل على البيانات النظيفة.

**عيب 2 — Average Rating بيتحسب من Query تانية:**

```js
const ratings = await Review.find({ book: bookId }).select('rating').lean();
const averageRating = ratings.length > 0
  ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1)
  : 0;
```

ده بيجيب كل الـ ratings من الـ DB في كل مرة بيجيب فيها الـ reviews. لو الكتاب عنده 10,000 review، هيجيب 10,000 document عشان يحسب الـ average. الحل الأفضل: استخدام MongoDB Aggregation:

```js
const agg = await Review.aggregate([
  { $match: { book: mongoose.Types.ObjectId(bookId) } },
  { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } }
]);
```

**عيب 3 — مفيش `isAllowedToUpdate` function:**

```js
// في deleteReview: isAllowedToToDelete (helper function)
const isAllowedToToDelete = (user, review) => {
  if (user.role === 'admin') return true;
  return user._id.toString() === review.user.toString();
};

// في updateReview: الـ check موجود مباشرة في الكود
if (req.user._id.toString() !== review.user.toString())
  throw new ApiError(403, 'Unauthorized to update this review');
```

مفيش consistency — الـ delete عنده helper function والـ update مش عنده. المفروض يكون في helper function مشتركة للاتنين.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Compound Unique Index؟ كيف بيختلف عن الـ Single Field Unique Index؟

**Q2:** ليه بنعمل `err.code === 11000` check في الـ try/catch بدل ما نتحقق من الـ duplicate قبل الـ create؟

> **إجابة نموذجية:** ممكن نعمل `Review.findOne({ user, book })` قبل الـ create. لكن ده Race Condition — لو اتنين requests وصلوا في نفس الوقت، ممكن الاتنين يشوفوا إنه مفيش review وكلهم يعملوا create. الـ Database Unique Index هو الضامن الحقيقي — حتى في الـ Race Condition، واحد بس هينجح والتاني هيفشل بـ 11000.

**Q3:** إيه هو الـ Purchase Gate في الـ review system؟ وليه ده Business Decision مهم؟

---

## Chapter 18 — Author Model

---

### 1. الكونسبت العام (The Story)

الـ Author Model هو الأبسط في المشروع — مجرد `name` و `bio`. لكن التفاصيل المهمة هنا مش في الـ Model نفسه، لكن في **إزاي الـ Controller بيتعامل معاه** — خصوصاً مشكلة الـ **N+1 Query**.

---

### 2. مثال عام بسيط

```js
const authorSchema = new Schema({
  name: { type: String, required: true, minlength: 2, maxlength: 100 },
  bio: { type: String, maxlength: 500 } // ← Optional
}, { timestamps: true });
```

---

### 3. شرح التطبيق في المشروع

**`src/models/author.js`:**

```js
const authorSchema = new Schema({
  name: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 100
  },
  bio: {
    type: String,
    maxlength: 500
    // ← Optional field، required مش موجود
  }
}, { timestamps: true });
```

**الـ N+1 Problem في `findAllAuthors`:**

```js
// controllers/author.js:
const findAllAuthors = async (req, res) => {
  const { data: authors } = await paginate(Author, {}, { sort: { name: 1 } });
  // ← Query 1: جيب 10 authors

  const authorsWithBookCount = await Promise.all(
    authors.map(async (author) => {
      const bookCount = await Book.countDocuments({ author: author._id });
      // ← Query N: لكل author، روح DB وعد الكتب
      return { ...author.toObject(), bookCount };
    })
  );
};
```

لو عندنا 10 authors، هنعمل **11 queries** (1 للـ authors + 10 للـ book counts). ده هو الـ N+1 Query Problem الكلاسيكي.

الحل بـ MongoDB Aggregation (Query واحدة):

```js
const authorsWithBookCount = await Author.aggregate([
  {
    $lookup: {
      from: 'books',
      localField: '_id',
      foreignField: 'author',
      as: 'books'
    }
  },
  {
    $addFields: {
      bookCount: { $size: '$books' }
    }
  },
  {
    $project: { books: 0 } // ← إخفاء الـ books array، خلي bookCount بس
  }
]);
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
GET /api/authors
        │
        ▼ protect مش مطلوب (public endpoint)
        │
        ▼ findAllAuthors controller:
        │   Query 1: paginate(Author, {}, {sort: {name: 1}}) → 10 authors
        │   Query 2-11: لكل author → Book.countDocuments({ author: id })
        │   Promise.all → بيشغل الـ 10 queries بالتوازي (مش واحدة واحدة)
        │
        ▼ Response: { authors: [{...author, bookCount: 5}], pagination: {...} }
```

**Note:** الـ `Promise.all` بيشغل الـ queries بالتوازي مش sequence، ده بيقلل الـ latency. بدل 10 × 50ms = 500ms، بيبقى تقريباً 50ms (الأطول query). لكن لسه N+1 problem.

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — N+1 Query Problem (تم شرحه فوق)**

**عيب 2 — مفيش index على `name` في Author:** الـ Authors بيتسرتوا بـ `name` في كل query. الأفضل:

```js
authorSchema.index({ name: 1 }); // ← يسرع الـ sort
```

**عيب 3 — `deleteAuthor` بيحذف الـ author لو مفيش books:**

```js
const hasBooks = await Book.exists({ author: id });
if (hasBooks) throw new ApiError(400, 'Cannot delete author with associated books');
const author = await Author.findByIdAndDelete(id);
```

ده Race Condition صغير — لو في نفس اللحظة حد أضاف book لنفس الـ author بعد الـ `Book.exists` check وقبل الـ `findByIdAndDelete`، هيتحذف الـ author وفضلت books من غير author. في الـ Low Traffic app ده مش مشكلة عملية، لكن ممكن يتحل بـ Transaction.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ N+1 Query Problem؟ ازاي بيأثر على الـ Performance؟

**Q2:** إيه الفرق بين `Promise.all` و `await` في loop؟

> **إجابة:** `await` في loop بيشغل الـ queries واحدة واحدة (sequential). `Promise.all` بيشغلهم كلهم في نفس الوقت (parallel). `Promise.all` أسرع بكتير في الحالات دي.

**Q3:** إيه هو `Book.exists({ author: id })`؟ هل هو نفس `Book.findOne({ author: id })`؟

---

## Chapter 19 — Category Model

---

### 1. الكونسبت العام (The Story)

الـ Category Model هو الأبسط في المشروع. الـ complexity مش في الـ Model نفسه — في الـ `deleteCategory` logic في الـ Controller اللي بيعمل **Cascading Update**.

---

### 2. مثال عام بسيط

```js
const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true, // ← مش ممكن يكون في categories بنفس الاسم
    trim: true
  }
}, { timestamps: true });
```

---

### 3. شرح التطبيق في المشروع

**`src/models/category.js`:**

```js
const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,  // ← Unique Index تلقائي
    trim: true     // ← بيشيل spaces قبل وبعد
  }
}, { timestamps: true });
```

**الـ Cascading Update في `deleteCategory`:**

```js
// controllers/category.js:
const deleteCategory = async (req, res) => {
  const category = await Category.findById(req.params.id);
  if (!category) throw new ApiError(404, 'Category not found');

  // الخطوة المهمة: قبل الحذف، اعمل update للكتب المرتبطة
  await Book.updateMany(
    { category: req.params.id },  // ← ابحث عن الكتب اللي في الـ category دي
    { category: null }             // ← اعملها uncategorized
  );

  await Category.findByIdAndDelete(req.params.id);

  res.json(new ApiResponse(200, 'Category deleted, Books in this Category are now uncategorized'));
};
```

ده بيضمن إن لو حذفت category، الكتب المرتبطة بيها مش بتتحذف (ده كان هيكون Destructive). بدل كده بيبقوا `uncategorized` (`category: null`).

---

### 4. الربط بالصورة الكاملة (The Glue)

```
DELETE /api/categories/:id

  1. protect → req.user
  2. restrictTo('admin') → role === 'admin'?
  3. deleteCategory:
     a. Category.findById(id) → موجود؟
     b. Book.updateMany({ category: id }, { category: null }) → كل الكتب uncategorized
     c. Category.findByIdAndDelete(id) → حذف الـ category

  ⚠️ مفيش Transaction! لو الـ updateMany نجح والـ findByIdAndDelete فشل،
  الكتب هتبقى uncategorized والـ category لسه موجودة
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — مفيش Transaction في الـ deleteCategory:** الخطوتين (updateMany ثم deleteById) مش في Transaction. لو حصل error بينهم، data consistency هتتكسر.

**عيب 2 — الـ `updateCategory` بيستخدم `returnDocument: 'after'`:**

```js
const category = await Category.findByIdAndUpdate(
  req.params.id,
  { name: req.body.name },
  { returnDocument: 'after' } // ← Mongoose بتستخدم { new: true }
);
```

`returnDocument: 'after'` هو MongoDB Driver option. Mongoose بتستخدم `{ new: true }`. الاتنين شغالين في الـ Mongoose version الحديثة، لكن `{ new: true }` هو الـ Idiomatic Mongoose way. ده inconsistency في الكود (بعض الـ controllers بيستخدم `new: true` وده بيستخدم `returnDocument: 'after'`).

**عيب 3 — مفيش Subcategories:** الـ Schema مش بتدعم hierarchy (categories فيها subcategories). ده في الـ scope، بس مهم تذكره كـ potential limitation.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Cascading Update؟ ليه مش عملنا Cascading Delete بدله؟

**Q2:** إيه الفرق بين `{ new: true }` و `{ returnDocument: 'after' }` في Mongoose؟

**Q3:** ليه مش استخدمنا Transaction في الـ deleteCategory بين الـ updateMany والـ deleteById؟ هل ده مشكلة؟

---

# ✅ الفصل الخامس: طبقة الـ Validations — الحارس الأول

---

## Chapter 20 — Joi Basics وكيف نكتب Schema

---

### 1. الكونسبت العام (The Story)

تخيل إن الـ API بتاعتك عبارة عن شباك استقبال في بنك. أي حد يجي يقدم طلب، في موظف بيشوف الأوراق الأول. الموظف ده عنده قائمة شروط:

- لازم تجيب بطاقة هوية (required field)
- لازم رقم التليفون يكون 11 رقم (format validation)
- لازم العنوان يكون أقل من 200 حرف (length limit)

لو الأوراق مش تمام، بيرجعك من الباب ومش بيكملش معاك. ده هو Joi.

**Joi** هي library للـ Validation بتسمح لك تكتب **Schema** — وصفة تحدد شكل البيانات المطلوبة. ثم بتـ validate الـ data ضد الـ schema دي.

---

### 2. مثال عام بسيط

```js
const Joi = require('joi');

// تعريف الـ Schema
const userSchema = Joi.object({
  name: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(18).max(120).optional()
});

// Validation
const { error, value } = userSchema.validate({
  name: 'Mo',
  email: 'mo@test.com',
  age: 25,
  extraField: 'hacking' // ← هيتشال لو stripUnknown: true
});

if (error) console.log(error.details); // Array of errors
else console.log(value); // البيانات المنظفة
```

---

### 3. شرح التطبيق في المشروع

**الـ Joi Types المستخدمة في المشروع:**

```js
// String validations:
Joi.string()           // لازم يكون string
  .min(2)              // minimum length
  .max(100)            // maximum length
  .required()          // لازم موجود
  .optional()          // اختياري
  .email()             // format email
  .uri()               // format URL
  .hex().length(24)    // MongoDB ObjectId (24 hex chars)
  .valid('COD', 'credit_card')  // enum — واحدة من القيم دول بس
  .pattern(/regex/)    // custom regex

// Number validations:
Joi.number()
  .integer()           // لازم integer (مش decimal)
  .min(0)              // minimum value
  .max(5)              // maximum value
  .positive()          // > 0

// Date validations:
Joi.date()
  .max('now')          // في الماضي

// Object validations:
Joi.object({
  field: Joi.string().required()
}).min(1)              // على الأقل field واحد
  .unknown(false)      // مش بيسمح بـ unknown fields (explicit stripUnknown)
```

**الـ `.messages()` method:**

```js
// auth.js validation:
dob: Joi.date()
  .max('now')
  .required()
  .messages({
    'date.max': 'Date of birth must be in the past'
    // ← بتغير الـ default Joi message لرسالة custom
  })

password: Joi.string()
  .min(8)
  .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  .required()
  .messages({
    'string.pattern.base': 'Password needs uppercase, lowercase, and a number'
  })
```

**الـ `.default()` method:**

```js
// cart.js validation:
const addItemSchema = joi.object({
  bookId: joi.string().required(),
  quantity: joi.number().integer().min(1).default(1)
  // لو المستخدم مش بعت quantity، بيتحط 1 تلقائياً
});

// order.js validation:
paymentMethod: joi.string().valid('COD', 'credit_card').default('COD')
```

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/cart
  Body: { bookId: '507f1f77bcf86cd799439011' }
                  │
                  ▼ validate(addItemSchema)
                  │
                  ▼ addItemSchema.validate(req.body, { abortEarly: false, stripUnknown: true })
                  │   → quantity missing → default: 1 يتطبق
                  │   → value = { bookId: '507f...', quantity: 1 }
                  │
                  ▼ req.body = value (المنظف مع الـ defaults)
                  │
                  ▼ addItem controller:
                      const { bookId, quantity = 1 } = req.body;
                      // quantity = 1 من الـ Joi default
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — ObjectId validation مش consistent:**

```js
// book.js validation:
const objectId = joi.string().hex().length(24);
// ← Custom ObjectId validator: hex string of 24 chars ✅

// cart.js validation:
bookId: joi.string().required()
// ← مجرد string بدون ObjectId format validation ❌
```

لو المستخدم بعت `bookId: 'not-an-id'`، الـ Joi هيقبله، والـ MongoDB هيرمي CastError بعدين. الأفضل استخدام نفس الـ `objectId` custom validator في كل مكان.

**عيب 2 — مفيش Custom Error Messages في معظم الـ Schemas:** بعض الـ schemas عندها `.messages()` والبعض لأ. ده بيخلي الرسائل inconsistent.

**عيب 3 — `unknown(false)` vs `stripUnknown: true` — استخدام مختلط:**

```js
// author.js validation:
const createAuthorSchema = joi.object({ ... }).unknown(false);
// ← بيرمي error لو في unknown fields

// في validate middleware:
schema.validate(req.body, { stripUnknown: true });
// ← بيشيل الـ unknown fields بصمت
```

`unknown(false)` في الـ Schema + `stripUnknown: true` في الـ options بيتعارضوا. الـ `stripUnknown` في الـ options بياخد priority ويشيل الـ fields من غير error. لو عايز ترمي error، خلي `stripUnknown: false` في الـ options.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الفرق بين `abortEarly: false` و `abortEarly: true` (الـ default) في Joi؟

**Q2:** إيه هو `.default()` في Joi وكيف بيشتغل مع الـ `validate()` method؟

**Q3:** ليه بنعمل Joi validation في الـ HTTP Layer بدل ما نعتمد على الـ Mongoose validation بس؟

> **إجابة نموذجية:** الـ Joi validation بتشتغل قبل ما أي DB query يحصل. لو الـ request غلط، بنرده فوراً من غير DB hit. ده أسرع وبيحمي الـ DB من الـ load الزيادة. الـ Mongoose validation هو الـ last line of defense في حالة الـ bugs.

---

## Chapter 21 — Auth Validations

---

### 1. الكونسبت العام (The Story)

الـ Auth Validations هي أول حاجة المستخدم بيمر عليها وقت التسجيل والـ Login. هي "الباب الأمامي" — قبل ما أي Logic يحصل، بنتأكد إن البيانات بشكل مقبول.

---

### 2. مثال عام بسيط

```js
// registerSchema — أكتر شيء بيمسكوا فيه في الـ Discussion
const schema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string()
    .min(8)
    .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/) // Regex: uppercase + lowercase + digit
    .required()
});
```

---

### 3. شرح التطبيق في المشروع

**`src/validations/auth.js`:**

```js
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  // ← email() بيتحقق من format: xxx@xxx.xxx

  firstName: Joi.string().min(2).max(50).required(),
  lastName: Joi.string().min(2).max(50).required(),

  dob: Joi.date()
    .max('now')  // ← لازم يكون في الماضي
    .required()
    .messages({ 'date.max': 'Date of birth must be in the past' }),

  password: Joi.string()
    .min(8)
    .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    // Regex يشرح:
    // (?=.*[a-z]) → lookahead: لازم في lowercase letter
    // (?=.*[A-Z]) → lookahead: لازم في uppercase letter
    // (?=.*\d) → lookahead: لازم في digit
    .required()
    .messages({
      'string.pattern.base': 'Password needs uppercase, lowercase, and a number'
    })
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
  // ← في الـ login مش محتاجين نتحقق من الـ password format
  // بس لازم يكون موجود
});

const updateProfileSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName: Joi.string().min(2).max(50),
  dob: Joi.date().max('now')
}).min(1);
// ← .min(1) معناها على الأقل field واحد لازم يكون موجود
// لو بعت body فاضي: Joi هيرمي error
```

**الـ `updateProfileSchema` — ملاحظة مهمة:** كل الـ fields اختيارية، لكن `.min(1)` على الـ Object بيقول "لازم يكون في على الأقل field واحد". ده بيمنع الـ `PATCH /profile` request الفاضية من اللا فائدة.

---

### 4. الربط بالصورة الكاملة (The Glue)

```
POST /api/auth/register
  Body: { email: 'mo@test.com', password: 'weak', firstName: 'Mo' }
                  │
                  ▼ validate(registerSchema)
                  │   → password: 'weak' → min(8) failed ❌
                  │   → password: 'weak' → pattern failed ❌
                  │   → lastName: missing → required failed ❌
                  │   (abortEarly: false → يجمع كل الأخطاء)
                  │
                  ▼ ApiError(400, "three error messages joined by comma")
                  │
                  ▼ errorHandler → HTTP 400 Bad Request
```

---

### 5. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — مفيش `confirmPassword` validation:** الـ `registerSchema` بتاخد password من غير تأكيد. المستخدم ممكن يكتب الـ password غلط.

```js
// الإضافة المطلوبة:
confirmPassword: Joi.string()
  .valid(Joi.ref('password')) // ← لازم تساوي الـ password
  .required()
  .messages({ 'any.only': 'Passwords must match' })
```

**عيب 2 — `loginSchema` بتتحقق من email format في الـ login:** لو المستخدم كتب email غلط (مش email format)، Joi هيرجعه بـ "must be a valid email" قبل ما يجرب في الـ DB. ده في الحقيقة يـ leak information بطريقة غير مباشرة (إن الـ input validation موجود وبيشتغل). في بعض الـ Security considerations، بيفضلوا يردوا برسالة generic واحدة دايماً "incorrect email or password" من غير تخصيص.

**عيب 3 — مفيش Validation للـ email في `updateProfileSchema`:** المستخدم مش يقدر يغير الـ email من الـ profile endpoint. ده قرار design، لكن مفيش تعليق يوضح السبب في الكود.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** إيه هو الـ Positive Lookahead في الـ Regex (`(?=.*[A-Z])`)؟ شرح الـ Regex المستخدم في الـ password validation.

**Q2:** ليه `loginSchema` مش بتتحقق من الـ password format (uppercase, lowercase, digit)؟

> **إجابة:** في الـ login، بنتحقق بس إن الـ password موجود. لو عملنا format validation، هنمنع users قدامى إنهم يـ login لو كلمة السر بتاعتهم تبقى ضعيفة قبل ما نحط الـ policy. كمان، الـ format validation في الـ login معلوماتية (بتقول للـ attacker الـ password policy).

**Q3:** إيه معنى `.min(1)` على Joi Object؟ بيختلف إزاي عن `.min(1)` على Joi String؟

---

## Chapter 22 — Book, Author, Category Validations

---

### 1. الكونسبت العام (The Story)

الـ Validations دي للـ Admin Operations — إنشاء وتعديل الكتب والمؤلفين والتصنيفات. الـ Admin مش مستخدم عادي، لكن لسه محتاج validation عشان الـ data integrity محفوظة.

---

### 2. شرح التطبيق في المشروع

**`src/validations/book.js`:**

```js
// Custom ObjectId validator (أذكى من مجرد string)
const objectId = joi.string().hex().length(24);
// hex() = characters من 0-9 و a-f فقط
// length(24) = MongoDB ObjectId دايماً 24 character

const createBookSchema = joi.object({
  name: joi.string().min(1).max(200).required(),
  price: joi.number().positive().required(),
  // positive() = أكبر من 0 (مش بس 0 أو أكبر)
  stock: joi.number().integer().min(0).required(),
  // integer() = مش ممكن يكون 5.5 كتاب
  // min(0) = ممكن يكون 0 (نافذ من المخزن)
  coverImage: joi.string().uri().required(),
  // uri() = لازم يكون URL صالح
  author: objectId.required(),
  category: objectId.optional()
  // Category اختيارية — ممكن الكتاب Uncategorized
});

const updateBookSchema = joi.object({
  name: joi.string().min(1).max(200),
  price: joi.number().positive(),
  stock: joi.number().integer().min(0),
  coverImage: joi.string().uri(),
  author: objectId,
  category: objectId.allow(null) // ← .allow(null) مهم!
  // لو Admin عايز يعمل الكتاب Uncategorized، يبعت null
}).min(1);
```

**الـ `.allow(null)` على الـ category في الـ update:**

ده important detail. في الـ Create، `category` اختياري (يعني ممكن ماتبعتوش). لكن في الـ Update، لو عايز تـ remove الـ category من كتاب، لازم تبعت `category: null`. من غير `.allow(null)` ده، Joi هيرفض الـ null value.

**`src/validations/author.js`:**

```js
const createAuthorSchema = joi.object({
  name: joi.string().min(2).max(100).required(),
  bio: joi.string().max(500).optional()
}).unknown(false);
// unknown(false) = مش بيسمح بأي field زيادة مش في الـ schema
// هيرمي error لو في extra fields (لكن الـ middleware بيعمل stripUnknown قبله!)

const updateAuthorSchema = joi.object({
  name: joi.string().min(2).max(100).optional(),
  bio: joi.string().max(500).optional()
}).min(1).unknown(false);
```

**`src/validations/category.js`:**

```js
const createCategorySchema = joi.object({
  name: joi.string().min(2).max(100).required()
});

const updateCategorySchema = joi.object({
  name: joi.string().min(2).max(100).required()
  // ← في الـ update، الـ name required لأن ده الـ field الوحيد
});
```

---

### 3. الربط بالصورة الكاملة (The Glue)

```
POST /api/books
  Body: { name: "Clean Code", price: -10, stock: 5.5, author: "not-an-id" }
                  │
                  ▼ protect → restrictTo('admin')
                  │
                  ▼ validate(createBookSchema):
                  │   price: -10 → positive() failed ❌
                  │   stock: 5.5 → integer() failed ❌
                  │   author: 'not-an-id' → hex().length(24) failed ❌
                  │
                  ▼ ApiError(400, "price must be positive, stock must be integer, ...")
```

---

### 4. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — `objectId` validator معرفش في ملف مشترك:**

```js
// في book.js validation:
const objectId = joi.string().hex().length(24);

// في cart.js validation:
bookId: joi.string().required() // ← مش بيستخدم الـ objectId validator
```

لو حد عمل shared `validators.js` file:

```js
// validators.js:
exports.objectId = joi.string().hex().length(24);
```

كان يبقى consistent في كل مكان.

**عيب 2 — `coverImage` بياخد أي URL:** `joi.string().uri()` بيتحقق إن الـ value URL، لكن مش بيتحقق إنه URL من Cloudinary. ممكن Admin يضيف URL من أي موقع تاني. لو Cloudinary CDN اتعطل، الصور كلها تعطلت.

**عيب 3 — مفيش validation على `minPrice > maxPrice` في الـ Query Params:** في الـ Book controller، المستخدم ممكن يبعت `?minPrice=200&maxPrice=50`. مفيش validation إن الـ minPrice أصغر من الـ maxPrice. المفروض في query params schema.

---

### 5. أسئلة انترفيو "جونيور"

**Q1:** إيه هو `joi.string().hex().length(24)`؟ ليه بنستخدمه للـ MongoDB ObjectId بدل مجرد `joi.string()`؟

**Q2:** إيه الفرق بين `joi.number().positive()` و `joi.number().min(0)`؟

> **إجابة:** `positive()` = أكبر من صفر (0 نفسه مش مسموح). `min(0)` = أكبر من أو يساوي صفر (0 مسموح). للـ price استخدمنا `positive()` لأن السعر لازم يكون فوق 0. للـ stock استخدمنا `min(0)` لأن الـ stock ممكن يوصل 0 (نافذ).

**Q3:** ليه `category: objectId.allow(null)` في `updateBookSchema` بس مش في `createBookSchema`؟

---

## Chapter 23 — Cart Validations

---

### 1. الكونسبت العام (The Story)

الـ Cart Validations بتغطي 3 operations: إضافة item، تعديل الـ quantity، وحذف item. كل operation ليه schema مختلفة.

---

### 2. شرح التطبيق في المشروع

**`src/validations/cart.js`:**

```js
const addItemSchema = joi.object({
  bookId: joi.string().required(),
  // ← ملاحظة: مش بيستخدم hex().length(24) — عيب!
  quantity: joi.number().integer().min(1).default(1)
  // default: لو ما بعتش quantity، هيتحط 1
});

const updateQuantitySchema = joi.object({
  bookId: joi.string().required(),
  action: joi.string().valid('increment', 'decrement').required()
  // valid() = enum — بس الـ values دول مسموحة
  // مش 'increase', مش 'add', بس 'increment' أو 'decrement'
});

const removeItemSchema = joi.object({
  bookId: joi.string().required()
});
```

**ليه الـ `action` field بدل quantity في الـ update؟**

ده قرار Design مهم. بدل ما المستخدم يبعت `quantity: 3` ويحتاج الـ backend يعرف هل زاد أو نقص، بنبعت `action: 'increment'` أو `action: 'decrement'`. ده:

- أوضح في الـ Intent
- بيمنع edge cases زي `quantity: 0` أو negative quantities
- بيسمح للـ Controller يـ handle الـ logic بثقة

---

### 3. الربط بالصورة الكاملة (The Glue)

```
routes/cart.js:
  router.use(protect); // ← الـ protect بيطبق على كل الـ routes

  router.get('/', cart.getCartItems);
  // مفيش validate هنا لأن مفيش body

  router.post('/', validate(addItemSchema), cart.addItem);
  router.patch('/quantity', validate(updateQuantitySchema), cart.updateItemQuantity);
  router.delete('/', validate(removeItemSchema), cart.removeItem);
  // ← الـ DELETE عنده body! ده غير تقليدي لكن Axios/fetch بيدعمه
```

**ملاحظة مهمة: DELETE request مع body:** الـ HTTP Spec ما بتمنعش الـ DELETE request يكون عنده body. لكن بعض servers والـ Middleware ممكن يتجاهلوه. الـ Express بيستقبله تمام لأن `express.json()` موجود. لكن ده مش conventional — الأفضل يكون `DELETE /api/cart/:bookId` من غير body.

---

### 4. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — الـ `bookId` مش بيتتحقق إنه MongoDB ObjectId:** (اتكلمنا عنه في Chapter 22)

**عيب 2 — الـ `action` enum في updateQuantitySchema مش في الـ Model:** الـ `action` values (`increment`, `decrement`) hard-coded في الـ validation. لو الـ Controller اتغير وأضاف `action: 'reset'`, لازم تتحدث الـ validation manually. الأفضل تكون constants مشتركة.

**عيب 3 — DELETE request بـ body مش idiomatic:** الأفضل `DELETE /api/cart/:bookId` من غير body. حاجات زي Swagger/OpenAPI ممكن تعمل مشاكل في الـ documentation.

---

### 6. أسئلة انترفيو "جونيور"

**Q1:** ليه `updateQuantitySchema` بيستخدم `action: 'increment' | 'decrement'` بدل إنك تبعت الـ quantity الجديدة مباشرة؟

**Q2:** هل مسموح لـ HTTP DELETE request يبعت body؟ وليه استخدمناه هنا بدل URL parameter؟

**Q3:** إيه الـ difference بين `joi.string().valid('a', 'b')` و `joi.string().enum(['a', 'b'])`؟

> **إجابة:** `joi.string().valid('a', 'b')` هو الـ Joi way الصح. `.enum()` مش method في Joi (ده TypeScript terminology). الـ `.valid()` بيستخدم rest parameters.

---

## Chapter 24 — Order & Review Validations

---

### 1. الكونسبت العام (The Story)

الـ Order Validation هي الأكثر تعقيداً في المشروع — عندها Nested Object للـ shippingDetails. والـ Review Validation عندها guard على الـ rating.

---

### 2. شرح التطبيق في المشروع

**`src/validations/order.js`:**

```js
const placeOrderSchema = joi.object({
  shippingDetails: joi.object({
    // ← Nested Joi Object!
    fullName: joi.string().required(),
    address: joi.string().required(),
    city: joi.string().required(),
    phone: joi.string().required()
    // ← phone مش بيتحقق من format! ممكن يبعت أي string
  }).required(),
  // ← الـ shippingDetails object نفسه required

  paymentMethod: joi.string().valid('COD', 'credit_card').default('COD')
  // ← لو مش بعتش paymentMethod → default: 'COD'
});

const updateOrderStatusSchema = joi.object({
  status: joi.string().valid('processing', 'out_for_delivery', 'delivered').required(),
  paymentStatus: joi.string().valid('pending', 'success')
  // ← paymentStatus اختياري — ممكن تحدث الـ status من غير ما تغير الـ paymentStatus
});
```

**الـ State Machine في الـ validation vs الـ Controller:**

ملاحظة: الـ `updateOrderStatusSchema` بيقبل أي من الـ 3 status values. لكن الـ State Machine في الـ controller هو اللي بيحدد إيه المسموح به:

```js
// Validation: بيقبل أي من التلاتة
status: joi.string().valid('processing', 'out_for_delivery', 'delivered')

// Controller: بيطبق الـ State Machine
if (StateTransition[order.status] !== status) {
  throw new ApiError(400, `Can't change from '${order.status}' to '${status}'`);
}
```

يعني ممكن تبعت valid status من الـ validation perspective، لكن الـ controller بيتحقق إن الـ transition منطقي. ده فصل واضح للمسؤوليات.

**`src/validations/review.js`:**

```js
const createReviewSchema = joi.object({
  rating: joi.number().integer().min(1).max(5).required(),
  comment: joi.string().max(500).optional()
}).unknown(false);
// unknown(false) = مش بيسمح بـ extra fields
// ده مهم عشان المستخدم ما يبعتش extra data

const updateReviewSchema = joi.object({
  rating: joi.number().integer().min(1).max(5).optional(),
  comment: joi.string().max(500).optional()
}).unknown(false).min(1);
// .min(1) = على الأقل field واحد في الـ update body
```

**الـ Redundant validation في الـ Review controller:**

```js
// في controllers/review.js:
if (!rating) throw new ApiError(400, 'Rating is required');
if (rating < 1 || rating > 5) throw new ApiError(400, 'Rating must be between 1 and 5');

// ده redundant مع:
rating: joi.number().integer().min(1).max(5).required()
// في الـ schema
```

---

### 3. الربط بالصورة الكاملة (The Glue)

```
POST /api/orders
  Body: {
    shippingDetails: { fullName: "Mohamed", address: "Cairo", city: "Cairo", phone: "01234567890" },
    paymentMethod: "COD"
  }
                  │
                  ▼ validate(placeOrderSchema)
                  │   → Nested object validation ✅
                  │   → paymentMethod valid ✅
                  │   → value = { shippingDetails: {...}, paymentMethod: 'COD' }
                  │
                  ▼ placeOrder controller:
                      const { shippingDetails, paymentMethod } = req.body;
                      const order = await orderPlacement(userId, shippingDetails, paymentMethod);
```

---

### 4. العيوب اللي في الكود (The Critical Eye)

**عيب 1 — `phone` في `shippingDetails` مش بيتحقق من format:**

```js
phone: joi.string().required()
// ← أي string مقبول! '123', 'hello', 'PHONE_NUMBER'
```

الأفضل:

```js
phone: joi.string().pattern(/^01[0-9]{9}$/).required()
// ← Egyptian mobile number format: 01X XXXXXXXX
```

**عيب 2 — `placeOrderSchema` مش بتتحقق من الـ Cart:** الـ Validation بتتحقق من الـ request body بس. مش ممكن تتحقق من إن الـ Cart مش فاضي في الـ Joi layer — ده بيحصل في الـ Service layer. ده acceptable separation، لكن يهمك تعرف الـ reason.

**عيب 3 — `updateOrderStatusSchema` بتقبل `status: 'processing'`:** الـ State Machine بيمنع الـ backward transitions، لكن الـ validation بتقبل حتى الـ Status الحالي. لو الأوردر `processing` وبعت `status: 'processing'`، الـ StateTransition check هيرمي error. الأفضل تتحقق منه في الـ Validation نفسها.

---

### 5. أسئلة انترفيو "جونيور"

**Q1:** إزاي بنعمل Validation لـ Nested Object في Joi؟ إيه الـ syntax؟

**Q2:** ليه الـ `updateOrderStatusSchema` بتقبل الـ 3 status values كلها حتى لو في Controller بيتحقق من الـ State Machine؟ هل ده مش redundant؟

> **إجابة نموذجية:** الـ Validation layer مسؤوليتها تتحقق إن الـ "data type and format" صح. الـ Business Logic (إن processing→delivered مش مسموح) هي مسؤولية الـ Controller/Service layer. الفصل ده هو الـ Separation of Concerns. الـ Validation بتقول "الـ value valid"، والـ Controller بيقول "الـ transition valid".

**Q3:** إيه معنى `.unknown(false)` في Joi Object؟ ومتى بيكون مفيد أكثر من `stripUnknown: true` في الـ middleware؟

---

> ⚡ **END OF PART 1 (Chapters 1-24)**
> 
> الفصول دي غطت:
> 
> - ✅ الفصل الأول: Architecture + index.js/app.js + Barrel Exports
> - ✅ الفصل الثاني: ApiError + ApiResponse + errorHelpers
> - ✅ الفصل الثالث: validate + authenticate + authorize + errorHandler + rateLimit + logger
> - ✅ الفصل الرابع: User + Book + Cart + Order + Review + Author + Category Models
> - ✅ الفصل الخامس: Joi Basics + Auth + Book/Author/Category + Cart + Order/Review Validations
> 
> رد بـ **"continue"** للفصول من 6 لـ 10 (Services → Controllers → Routes → Cloudinary → Vercel → Pagination → Full Picture Traces)