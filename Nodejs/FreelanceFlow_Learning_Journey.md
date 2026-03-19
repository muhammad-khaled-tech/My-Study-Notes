# 🎓 FreelanceFlow — Learning Journey
> **الفكرة:** مش هنبني الـ project دفعة واحدة. هنبنيه sprint by sprint.
> كل sprint = concept واحد + أصغر كود ممكن + طريقة تتأكد إنه شغال.
> **Style:** الشرح بالعربي — الكود والـ technical terms بالإنجليزي.

---

# 🏁 Sprint 0 — The Bare-Bones Server

## 🇪🇬 Core Concept

يا Mohamed، قبل أي حاجة — لازم يكون عندنا سيرفر شغال.

تخيل إنك بتفتح محل. أول حاجة بتعملها إيه؟ بتفتح الباب وبتحط لافتة "مفتوح". ده بالظبط Sprint 0 — مش عندنا منتجات ولا كاشير ولا أي حاجة. بس الباب مفتوح والسيرفر بيرد.

**لو مش عندنا ده:** مفيش حاجة تشتغل بعدين. كل الـ sprints الجاية بتتبنى فوق الـ server ده.

---

## 💻 Minimum Viable Step

ابدأ بإنشاء الـ project:

```bash
mkdir freelance-flow && cd freelance-flow
npm init -y
npm install express dotenv
npm install --save-dev nodemon
```

**`package.json`** — ضيف الـ scripts دي:
```json
"scripts": {
  "dev": "nodemon server.js"
}
```

**`.env`**
```env
PORT=5000
NODE_ENV=development
```

**`server.js`** — ده كل حاجة دلوقتي:
```javascript
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 5000;

// Our first and only route — just to prove the server is alive
app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## ✅ Checkpoint

```bash
npm run dev
```

افتح Postman:

> **Method:** `GET`
> **URL:** `http://localhost:5000/`
> **Expected:** `FreelanceFlow server is alive! 🚀`

**لو شفت الرسالة دي → Sprint 0 خلص. الباب مفتوح.**

---

## 🔍 Deep-Dive

**ما اللي حصل technically؟**

`require('dotenv').config()` — بتقرأ الـ `.env` file وبتحط كل variable فيه على الـ `process.env` object. لازم تكون أول سطر في الكود قبل أي حاجة تانية تحاول تقرأ `process.env`.

`express()` — بترجع function. الـ function دي هي الـ request handler — نفس اللي بتحطها في `http.createServer()`. Express مش بيعمل server جديد — بيلف الـ Node.js `http` module.

`app.listen(PORT)` — بيبدأ يستنى connections على الـ port ده. كل request جاية هتعدي على كل middleware و route registered على الـ `app` object.

`(req, res)` في الـ route handler — دول objects فيهم كل حاجة عن الـ request الجاي و الـ response الرايح. مش هتعرف كل properties دلوقتي — هتتعلمهم وانت بتبني.

---

---

# 📦 Sprint 1 — The First Middleware: `express.json()`

## 🇪🇬 Core Concept

دلوقتي السيرفر شغال. بس لو بعت JSON body في الـ request — السيرفر مش هيفهمه.

تخيل إن حد بعتلك رسالة بالعربي بس مش عندك قاموس. الرسالة وصلت، بس مش قادر تفهمها.

`express.json()` هو القاموس ده. بيقول لـ Express: "أي request جاي بـ Content-Type: application/json — افهمه وحوّله لـ JavaScript object وحطه على `req.body`."

**لو مش عندنا ده:** `req.body` هيبقى `undefined` دايماً. مش هتقدر تعمل register، login، أو أي POST request.

---

## 💻 Minimum Viable Step

غيّر `server.js` بإضافة سطرين بس:

```javascript
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 5000;

// ✅ NEW: Tell Express to parse incoming JSON bodies
app.use(express.json());

app.get('/', (req, res) => {
  res.send('FreelanceFlow server is alive! 🚀');
});

// ✅ NEW: A test route that reads from req.body
app.post('/test-body', (req, res) => {
  console.log('req.body is:', req.body);
  res.json({ received: req.body });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## ✅ Checkpoint

افتح Postman وبعت الـ requests دي:

**Test 1 — بدون body:**

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-body`
> **Body:** None
> **Expected:** `{ "received": {} }`

**Test 2 — مع JSON body:**

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-body`
> **Header:** `Content-Type: application/json`
> **Body (raw JSON):** `{ "name": "Mohamed", "role": "client" }`
> **Expected:** `{ "received": { "name": "Mohamed", "role": "client" } }`

**شوف الـ terminal كمان** — المفروض تشوف:
```
req.body is: { name: 'Mohamed', role: 'client' }
```

**لو `req.body` وصل صح → Sprint 1 خلص.**

---

## 🔍 Deep-Dive

**`app.use()` بتعمل إيه؟**

`app.use(middleware)` بيضيف الـ middleware ده على الـ pipeline. كل request جاية هتعدي عليه أول ما توصل للـ route handler.

**الـ middleware pipeline بيشتغل إزاي؟**

```
POST /test-body
     │
     ▼
express.json()      ← reads raw body bytes, parses them,
     │                sets req.body = { name: 'Mohamed', ... }
     │                then calls next()
     ▼
/test-body handler  ← req.body is now available here
     │
     ▼
res.json(...)       ← response sent, cycle ends
```

**`express.json()` بيعمل إيه داخلياً؟**

بيشوف الـ `Content-Type` header في الـ request. لو كان `application/json`، بياخد الـ raw bytes من الـ request stream، بيعملهم `JSON.parse()`، وبيحط النتيجة على `req.body`. لو الـ Content-Type مش JSON — بيعمل `next()` من غير ما يعمل حاجة.

**ليه `app.use()` من غير path؟**

لأننا عايزين الـ body parser يشتغل على كل request. لو قولنا `app.use('/api', express.json())` — هيشتغل بس لما الـ URL يبدأ بـ `/api`.

---

---

# 🛡️ Sprint 2 — `AppError` + The Global Error Handler

## 🇪🇬 Core Concept

دلوقتي لو حاجة غلط في السيرفر — Express مش عارف يتعامل معاها بشكل صح. هيرجع HTML error page أو هيـ crash.

تخيل إنك بتشتغل في مستشفى. كل طوارئ بتيجي، مش كل دكتور يتعامل معاها لوحده من الأول للآخر. في قسم طوارئ مركزي بيشوف كل الحالات ويقرر إيه اللي يتعمل.

**الـ Global Error Handler** هو قسم الطوارئ ده.

**`AppError`** هو الـ form اللي بتملاه لما بتبعت حالة للطوارئ — بتقوله: إيه المشكلة (`message`)، ومدى خطورتها (`statusCode`).

**لو مش عندنا ده:** كل controller لازم يكتب نفس كود الـ error handling. وكل حاجة غير متوقعة هتـ crash السيرفر أو ترجع error message مش مفهوم.

---

## 💻 Minimum Viable Step

**خطوة 1 — اعمل `src/utils/AppError.js`:**

```javascript
class AppError extends Error {
  constructor(message, statusCode) {
    // Pass message to the native JavaScript Error class
    super(message);

    this.statusCode = statusCode;

    // 4xx = client's fault ('fail'), 5xx = server's fault ('error')
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    // This flag = "I made this error on purpose"
    // The error handler will use this to decide what to tell the client
    this.isOperational = true;
  }
}

module.exports = AppError;
```

**خطوة 2 — اعمل `src/middlewares/errorHandler.js`:**

```javascript
const globalErrorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status     = err.status     || 'error';

  res.status(err.statusCode).json({
    status:  err.status,
    message: err.message,
  });
};

module.exports = globalErrorHandler;
```

**خطوة 3 — اربطهم في `server.js`:**

```javascript
require('dotenv').config();
const express            = require('express');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const app  = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

// ✅ NEW: A route that throws a fake error — just to test our error handler
app.get('/test-error', (req, res, next) => {
  next(new AppError('This is a fake error for testing!', 400));
});

// ✅ NEW: Catch-all for routes that don't exist
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

// ✅ NEW: Global error handler — MUST be the last thing registered
app.use(globalErrorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

## ✅ Checkpoint

**Test 1 — الـ fake error:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/test-error`
> **Expected:**
> ```json
> { "status": "fail", "message": "This is a fake error for testing!" }
> ```

**Test 2 — route مش موجودة:**

> **Method:** `GET`
> **URL:** `http://localhost:5000/anything-random`
> **Expected:**
> ```json
> { "status": "fail", "message": "Can't find /anything-random on this server!" }
> ```

**Test 3 — تأكد من الـ status code في Postman:**

أعلى الـ response — المفروض يكتب `400 Bad Request` للـ Test 1 و `404 Not Found` للـ Test 2.

**لو الـ errors بيترجعوا كـ JSON مش كـ HTML → Sprint 2 خلص.**

---

## 🔍 Deep-Dive

**ليه الـ error handler عنده 4 parameters تحديداً؟**

Express بيتعرف على الـ error handler بالـ signature بتاعته. أي middleware بـ 4 parameters `(err, req, res, next)` بيتعامل معاه كـ error handler تلقائياً. لو كتبته بـ 3 parameters هيتعامل معاه كـ normal middleware ومش هيشتغل لما حصل error.

**إيه اللي بيحصل لما بتعمل `next(err)`؟**

```
next()           → go to the NEXT normal middleware
next(anything)   → SKIP all normal middleware
                   jump directly to the error handler
```

**إيه اللي بيخلي `AppError` مفيد أكتر من `new Error()` العادي؟**

الـ native `Error` object عنده `message` و `stack` بس. الـ `AppError` بيضيف:

- `statusCode` — عشان الـ error handler يعرف يبعت الـ HTTP status الصح
- `status` — `'fail'` أو `'error'` حسب الـ status code
- `isOperational = true` — الـ flag المهم. بعدين هنستخدمه عشان نفرق بين:
  - **Operational errors** (زي "user not found") — آمن نبعت الـ message للـ client
  - **Programming errors** (زي bug في الكود) — خطر نبعت التفاصيل، نبعت "Something went wrong" بدل كده

**`app.all('*')` بتعمل إيه؟**

`app.all` بيطابق أي HTTP method. الـ `'*'` بتطابق أي path. يعني: "أي request على أي path ومش اتعمله match بالـ routes اللي فوق — ادّيه للـ error handler كـ 404".

---

---

# 🗄️ Sprint 3 — MongoDB Connection + First Schema

## 🇪🇬 Core Concept

السيرفر شغال وعنده error handling. دلوقتي محتاجين نوصله بـ database.

MongoDB هو مكان حفظ الداتا. Mongoose هو الـ translator بيننا وبين MongoDB — بيحولنا من كلام JavaScript لـ database operations.

تخيل إن MongoDB هو مخزن كبير جداً فيه أدراج. كل drawer هو collection (زي `users`, `projects`). Mongoose هو اللي بيقولك: "الـ drawer ده هيستقبل بس أشياء معينة، بشكل معين."

- **Schema** = التعليمات اللي بتحدد شكل الداتا
- **Model** = الـ JavaScript class اللي بيديك methods تتعامل بيها مع الـ collection

**Sprint 3 هدفه:** نوصل بـ MongoDB ونعمل `User` model بسيط — **بدون أي hooks دلوقتي.** هنضيف الـ hooks في Sprint 4.

---

## 💻 Minimum Viable Step

**خطوة 1 — Install Mongoose:**
```bash
npm install mongoose
```

**خطوة 2 — ضيف الـ MONGO_URI في `.env`:**
```env
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb://localhost:27017/freelanceflow
```

> 💡 لو مش عندك MongoDB locally، استخدم MongoDB Atlas (free) وخد الـ connection string منه.

**خطوة 3 — اعمل `src/models/User.model.js`:**

```javascript
const mongoose = require('mongoose');

// The Schema: the rules and shape of every user document
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
    timestamps: true,
  }
);

const User = mongoose.model('User', userSchema);
module.exports = User;
```

**خطوة 4 — وصّل MongoDB وضيف test route في `server.js`:**

```javascript
require('dotenv').config();
const express            = require('express');
const mongoose           = require('mongoose');
const User               = require('./src/models/User.model');
const AppError           = require('./src/utils/AppError');
const globalErrorHandler = require('./src/middlewares/errorHandler');

const app  = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

// ✅ NEW: Connect to MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.error('❌ MongoDB Connection Failed:', err));

// ✅ NEW: Test route — creates a raw user (no hashing yet, Sprint 4 fixes this)
app.post('/test-user', async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json({ status: 'success', data: { user } });
  } catch (err) {
    next(err);
  }
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

## ✅ Checkpoint

**Test 1 — User creation صح:**

> **Method:** `POST`
> **URL:** `http://localhost:5000/test-user`
> **Body (raw JSON):** `{ "name": "Mohamed", "email": "mo@test.com", "password": "pass1234", "role": "client" }`
> **Expected:** user object كامل مع `_id` و `createdAt`

> ⚠️ **لاحظ:** الـ password ظاهر كـ plain text دلوقتي — Sprint 4 هيحل المشكلة دي.

**Test 2 — Validation error:**

> **Method:** `POST`
> **Body (raw JSON):** `{ "name": "Ahmed" }`
> **Expected:** error بيقول إن email و password مطلوبين

**Test 3 — Duplicate email:**

> ابعت نفس الـ Test 1 تاني مرة بنفس الـ email
> **Expected:** error إن الـ email موجود بالفعل

**لو الـ user اتحفظ في الـ database → Sprint 3 خلص.**

تتأكد بـ `mongosh`:
```
use freelanceflow
db.users.find()
```

---

## 🔍 Deep-Dive

**إيه الفرق بين Schema و Model؟**

```javascript
// Schema = the blueprint — defines shape and rules, NO DB interaction
const userSchema = new mongoose.Schema({ name: String });

// Model = compiled class — gives you all the query methods
const User = mongoose.model('User', userSchema);

User.find()               // query all users
User.create({})           // insert a document
User.findById(id)         // find by _id
User.findByIdAndUpdate()  // find + update atomically
User.deleteOne()          // delete matching document
```

**إيه معنى `unique: true` بالظبط؟**

```javascript
// Mongoose validator — runs BEFORE saving, throws ValidationError
required: [true, 'Email is required']

// MongoDB index — enforced at DB level, throws MongoServerError code 11000
unique: true
```

عشان كده الـ error اللي بييجي من `unique` مختلف شكله عن الـ validation error. هنتعامل معاه في الـ error handler بعدين.

**إيه اللي بيحصل داخلياً لما بتعمل `User.create(data)`؟**

```
User.create({ ... })
    │
    ▼
1. Validate data against Schema
    │
    ▼
2. Run pre('save') hooks    ← none yet, Sprint 4 adds these
    │
    ▼
3. Send INSERT to MongoDB
    │
    ▼
4. Run post('save') hooks   ← none yet
    │
    ▼
5. Return saved document (with _id, createdAt, updatedAt)
```

---

---

# ⏸️ Milestone Check

عملنا في الـ 3 sprints دول:

- **Sprint 0** ✅ — Express server alive
- **Sprint 1** ✅ — `express.json()` body parsing
- **Sprint 2** ✅ — `AppError` + Global Error Handler
- **Sprint 3** ✅ — MongoDB connection + User Schema

**الجاي في الـ sprints القادمة:**

- **Sprint 4** — Password Hashing Hook — ليه في الـ Model مش الـ Controller
- **Sprint 5** — Register flow (real controller + route)
- **Sprint 6** — Login + JWT — الـ Stateless concept
- **Sprint 7** — `protect` middleware — تأمين الـ routes
- **Sprint 8** — Projects CRUD
- **Sprint 9** — Proposals + الـ Cascade Hook

---

> **جاهز للـ Sprint 4؟**
> قول "كمّل" وهبدأ بـ password hashing — ده من أهم الـ concepts اللي المفروض تشرحه في الـ interview.
