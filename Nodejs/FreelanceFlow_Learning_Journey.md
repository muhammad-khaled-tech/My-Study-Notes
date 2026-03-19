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
