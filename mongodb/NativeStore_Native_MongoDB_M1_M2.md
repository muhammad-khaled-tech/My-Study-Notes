# 🍃 Native MongoDB — Node.js Driver Vault
# الجزء الأول — Module 1 & 2: بدون Mongoose، بدون Magic، الحقيقة الخام

> **المشروع:** NativeStore — متجر تقني بالـ Native MongoDB Driver بدون أي ODM.
> ده مش مشروع للتعلم فقط — ده فهم **إيه اللي Mongoose بيعمله فعلاً من تحت** قبل ما تستخدمه.
> اللي بيفهم الـ Native Driver، بيفهم كل ODM فوقيه — لأنهم كلهم في النهاية بيتكلموا بلغته.

---

# الفصل 1 — Setup & Connection: قبل ما تكتب سطر كود، لازم تبني الأرض

> **المتطلبات:** JavaScript Async/Await، إيه هو الـ Event Loop، وإيه معنى إن Node.js بيشتغل على Thread واحدة — لأن الـ Connection Pool هيتكلم في الكلام ده بالتفصيل.

---

## البداية — ليه Native Driver؟ مش Mongoose كفاية؟

تخيل معايا إنك بتتعلم تطبخ. فيه اتنين مسارات:

المسار الأول: تعلم تشغّل الـ Microwave — بتحط الأكل، بتضغط زرار، بتاخد الأكل جاهز. سريع وسهل. بس لو الـ Microwave عطل أو عايز تعمل أكلة مش في الـ menu؟ انت وقفت.

المسار التاني: تعلم الطبخ من أساسه — تقطيع، تتبيل، حرارة، توقيت. تقدر تعمل أي حاجة. تقدر تفهم ليه الـ Microwave بيشتغل.

الـ **Mongoose** هو الـ Microwave — أداة رائعة، بس لو ما فهمتش الـ **Native Driver** اللي تحتها، هتتعامل مع كتير من الـ bugs والـ performance issues وانت مش عارف السبب.

```
┌────────────────────────────────────────────────────────────────────┐
│              Stack بتاعنا في الـ NativeStore                       │
│                                                                    │
│   ┌──────────────────────────────────────────────────────────┐    │
│   │                  NativeStore App (Node.js)                │    │
│   │              كودنا — Business Logic — Routes              │    │
│   └──────────────────────┬───────────────────────────────────┘    │
│                           │  بيكلم                                │
│   ┌──────────────────────▼───────────────────────────────────┐    │
│   │           mongodb (Official Node.js Driver)               │    │
│   │     MongoClient — Collection API — BSON Serialization     │    │
│   │          ده اللي هنتعلمه في الـ File ده                   │    │
│   └──────────────────────┬───────────────────────────────────┘    │
│                           │  TCP/IP                               │
│   ┌──────────────────────▼───────────────────────────────────┐    │
│   │              MongoDB Server (mongod process)              │    │
│   │          WiredTiger Storage Engine — B-Tree Indexes       │    │
│   └──────────────────────────────────────────────────────────┘    │
│                                                                    │
│   ↑ كل حاجة بين كودك والـ DB بيعملها الـ Driver بدون ما تحس     │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🧩 كونسيبت 1: الـ Project Setup — بناء الأرض من الصفر

### 🧩 الكونسيبت

الـ `npm init` مش مجرد أمر بتكتبه وتخلص. ده بداية حياة الـ project. الـ `package.json` هو الـ DNA بتاع الكود — بيقول إيه dependencies المشروع، إيه الـ entry point، وإيه الـ scripts اللي هتشغّلها.

الـ `mongodb` package هو الـ **Official Node.js Driver** اللي بتحطه — بتاع MongoDB Inc. نفسها. مش third-party، مش community — هو الأصل اللي Mongoose مبني فوقيه.

فلسفة الـ Project Structure:

```
┌─────────────────────────────────────────────────────────────────┐
│                      NativeStore Structure                       │
│                                                                  │
│   nativestore/                                                   │
│   ├── src/                                                       │
│   │   ├── db/                                                    │
│   │   │   └── client.js       ← MongoClient الـ singleton هنا  │
│   │   ├── products/                                              │
│   │   │   └── product.service.js  ← Native queries هنا          │
│   │   └── index.js            ← Entry point                     │
│   ├── .env                    ← MONGO_URI هنا                   │
│   └── package.json                                              │
└─────────────────────────────────────────────────────────────────┘
```

الفكرة إن الـ `MongoClient` هو **singleton** — بتعمله مرة واحدة في الـ app كلها. مش في كل request. ليه؟ لأن بناء الـ connection pool بياخد وقت — لو بنيته في كل request، التطبيق هيبطّئ بشكل مجنون.

---

### 💡 مثال عام

```javascript
// مثال معزول — هنشوف ازاي npm init + mongodb بتشتغلوا
// مش بروح الـ Project لسه — مجرد فهم الـ steps

// Step 1: كده يكون شكل الـ package.json بعد npm init -y
{
  "name": "my-mongo-app",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  }
}

// Step 2: بعد npm install mongodb، هيظهر في الـ dependencies
{
  "dependencies": {
    "mongodb": "^6.x.x"   // ← الـ official driver — دي الـ version الحالية
  }
}

// Step 3: أبسط استخدام للـ Driver — connect وprint الـ DB names
import { MongoClient } from 'mongodb';

const client = new MongoClient('mongodb://localhost:27017');

async function main() {
  await client.connect();
  console.log('✅ Connected to MongoDB!');

  const adminDb = client.db('admin');
  const result = await adminDb.command({ listDatabases: 1 });
  console.log(result.databases);

  await client.close();
}

main();
```

---

### 📊 نتيجة المثال

لما تشغّل الكود ده في الـ terminal:

```
✅ Connected to MongoDB!
[
  { name: 'admin',  sizeOnDisk: 40960,  empty: false },
  { name: 'config', sizeOnDisk: 12288,  empty: false },
  { name: 'local',  sizeOnDisk: 73728,  empty: false }
]
```

الـ `admin`، `config`، `local` هم الـ **system databases** اللي MongoDB بتعملهم تلقائياً. الـ `local` بيستخدمه الـ Replication. الـ `config` بيستخدمه الـ Sharding. احنا مش هنلمسهم.

---

### 🏗️ تطبيق المشروع (Actionable)

**الخطوة 1 — ابني الـ Folder Structure:**

روح افتح الـ Terminal واكتب الأوامر دي بالترتيب بالظبط:

```bash
mkdir nativestore
cd nativestore
mkdir -p src/db src/products
npm init -y
npm install mongodb dotenv
npm install --save-dev nodemon
```

**الخطوة 2 — عدّل الـ `package.json`:**

افتح الـ `package.json` وعدّل الـ `scripts` section بالكود ده:

```json
{
  "name": "nativestore",
  "version": "1.0.0",
  "description": "Native MongoDB Driver — No ODM, No Magic",
  "main": "src/index.js",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "dotenv": "^16.0.0",
    "mongodb": "^6.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0"
  }
}
```

> ⚠️ **انتبه:** الـ `"type": "module"` بيخلّي Node.js يتعامل مع كل ملفاتك كـ ES Modules — يعني بتستخدم `import/export` مش `require/module.exports`. ده الـ modern way وهو اللي هنمشي عليه.

**الخطوة 3 — اعمل ملف `.env`:**

في الـ root بتاع المشروع (جنب `package.json`):

```bash
# .env
MONGO_URI=mongodb://localhost:27017
DB_NAME=nativestore
PORT=3000
```

**الخطوة 4 — اعمل ملف `src/index.js` مؤقت للتأكد:**

```javascript
// src/index.js
import 'dotenv/config';
import { MongoClient } from 'mongodb';

const client = new MongoClient(process.env.MONGO_URI);

async function main() {
  try {
    await client.connect();
    console.log('✅ NativeStore connected to MongoDB');
    console.log(`📦 Database: ${process.env.DB_NAME}`);
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
  } finally {
    await client.close();
  }
}

main();
```

شغّل المشروع:

```bash
npm run dev
```

لو شفت الـ output ده، انت خلصت الـ Setup بنجاح:

```
✅ NativeStore connected to MongoDB
📦 Database: nativestore
```

---

## 🧩 كونسيبت 2: الـ Connection Pool — المدينة اللي تحت الكود

### 🧩 الكونسيبت

هنا بيحصل الـ magic اللي معظم الناس ما بتعرفوش — وده بالظبط اللي بيفرق في الـ interviews.

لما بتكتب `await client.connect()` — انت مش بتعمل **connection واحدة**. انت بتقول للـ Driver: *"ابني لي مدينة صغيرة من الـ connections جاهزة."*

الـ **Connection Pool** هو عبارة عن مجموعة من الـ TCP connections مفتوحة ومجهّزة للـ MongoDB. لما request بييجي، بياخد connection من الـ pool، بيعمل شغله، وبيرجعها للـ pool تاني. مش بيفتح connection جديدة — مش بيقفلها. بياخد وبيرد.

```
┌──────────────────────────────────────────────────────────────────────┐
│                    Connection Pool Under The Hood                     │
│                                                                       │
│   Node.js App                      MongoDB Server                    │
│   ──────────                       ──────────────                    │
│                                                                       │
│   Request 1 ──┐                                                      │
│   Request 2 ──┤   ┌─────────────────────────────────────────────┐   │
│   Request 3 ──┤   │           Connection Pool                    │   │
│   Request 4 ──┤   │                                              │   │
│   Request 5 ──┼──►│  Conn #1 ●──────────────────────────────►  │   │
│               │   │  Conn #2 ●──────────────────────────────►  │   │
│               │   │  Conn #3 ●──────────────────────────────►  │   │
│               │   │  Conn #4 ● (idle — waiting)                │   │
│               │   │  Conn #5 ● (idle — waiting)                │   │
│               │   │                                              │   │
│   Request 6 ──┘   │  ↑ Default: 5 connections (minPoolSize)    │   │
│                   │  Max: 100 connections (maxPoolSize)          │   │
│                   └─────────────────────────────────────────────┘   │
│                                                                       │
│   بدل ما كل request تبني وتكسر connection (بطيء جداً)،              │
│   الـ pool بيخلي الـ connections جاهزة دايماً.                      │
│                                                                       │
│   Latency to open new TCP connection:    ~100-300ms                  │
│   Latency to reuse pooled connection:    ~0.1-1ms                   │
│                                          ↑ الفرق ده هو سبب وجود الـ Pool
└──────────────────────────────────────────────────────────────────────┘
```

**الأرقام المهمة في الـ Pool:**

| الـ Option | الـ Default | المعنى |
|---|---|---|
| `maxPoolSize` | `100` | أقصى عدد connections في نفس الوقت |
| `minPoolSize` | `0` | أقل عدد connections تتفتح دايماً |
| `connectTimeoutMS` | `30000` | وقت الانتظار لفتح connection جديدة |
| `socketTimeoutMS` | `0` (∞) | وقت الانتظار لـ response من الـ DB |
| `waitQueueTimeoutMS` | `0` (∞) | لو الـ pool فاضت، أد ايه request ينتظر |

---

### 💡 مثال عام

```javascript
// مثال معزول — MongoClient مع custom pool settings
import { MongoClient } from 'mongodb';

const client = new MongoClient('mongodb://localhost:27017', {
  // Pool Configuration
  maxPoolSize: 10,          // ← مناسب لـ small/medium apps
  minPoolSize: 2,           // ← ابني 2 connections دايماً حتى لو مفيش traffic
  connectTimeoutMS: 5000,   // ← لو ما قدرش يتصل في 5 ثواني، throw error
  socketTimeoutMS: 45000,   // ← لو الـ DB مردتش في 45 ثانية، throw error

  // Server Selection
  serverSelectionTimeoutMS: 5000,  // ← لو ما لقاش MongoDB server في 5 ثواني

  // Connection Health
  heartbeatFrequencyMS: 10000,     // ← كل 10 ثواني بيتأكد إن الـ server لسه شغال
});

async function demo() {
  await client.connect();

  // بعد الـ connect، الـ pool اتبنى
  // جرب تعمل 3 operations في نفس الوقت
  const db = client.db('demo');
  const col = db.collection('items');

  const [r1, r2, r3] = await Promise.all([
    col.findOne({ _id: 1 }),    // ← بياخد Conn #1
    col.findOne({ _id: 2 }),    // ← بياخد Conn #2
    col.findOne({ _id: 3 }),    // ← بياخد Conn #3
  ]);
  // الـ 3 operations اشتغلوا في نفس الوقت على 3 connections مختلفة

  await client.close();
}

demo();
```

---

### 📊 نتيجة المثال

لو فتحت الـ **MongoDB Compass** وبصيت على الـ Current Operations أثناء تشغيل الكود، هتلاقي 3 connections نشطة بيشتغلوا في parallel في نفس اللحظة.

في الـ Console لو عملت `mongosh` وكتبت:

```javascript
// في الـ mongosh
db.serverStatus().connections
// {
//   current: 3,           ← الـ 3 connections اللي فتحناها
//   available: 838997,
//   totalCreated: 3
// }
```

---

### 🏗️ تطبيق المشروع (Actionable)

ده أهم ملف في المشروع كله — الـ **Singleton Client**. اعمل ملف `src/db/client.js` واكتب فيه الكود ده:

```javascript
// src/db/client.js
import { MongoClient } from 'mongodb';

// ──────────────────────────────────────────────────────────────────
// ده الـ Singleton بتاعنا.
// MongoClient واحد بس — بيتعمل مرة واحدة في حياة الـ process.
// كل الـ modules في المشروع هتـ import منه — مش هتعمله تاني.
// ──────────────────────────────────────────────────────────────────

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';
const DB_NAME   = process.env.DB_NAME   || 'nativestore';

const client = new MongoClient(MONGO_URI, {
  maxPoolSize: 10,
  minPoolSize: 2,
  connectTimeoutMS: 5000,
  serverSelectionTimeoutMS: 5000,
});

// بنـ export الـ db مش الـ client —
// الـ modules التانية محتاجة تكلم collections مش تـ manage الـ connection
export const db = client.db(DB_NAME);

// دي الـ function اللي هنستدعيها مرة واحدة في بداية الـ app
export async function connectDB() {
  try {
    await client.connect();

    // Ping بسيط يتأكد إن الـ connection تمام
    await db.command({ ping: 1 });

    console.log(`✅ NativeStore DB connected — pool ready`);
    console.log(`📦 Database: "${DB_NAME}" | maxPool: 10`);
  } catch (err) {
    console.error('❌ Failed to connect to MongoDB:', err.message);
    process.exit(1); // ← لو الـ DB مش شغال، الـ app مالهاش لازمة تكمل
  }
}

// لو الـ process اتقفل (Ctrl+C)، اقفل الـ pool بنظافة
process.on('SIGINT', async () => {
  await client.close();
  console.log('\n🔌 MongoDB connection pool closed gracefully');
  process.exit(0);
});
```

دلوقتي عدّل الـ `src/index.js`:

```javascript
// src/index.js
import 'dotenv/config';
import { connectDB } from './db/client.js';

async function startApp() {
  await connectDB();
  console.log('🚀 NativeStore is running...');
  // هنا هنضيف الـ routes والـ server لاحقاً
}

startApp();
```

شغّل `npm run dev` — المفروض تشوف:

```
✅ NativeStore DB connected — pool ready
📦 Database: "nativestore" | maxPool: 10
🚀 NativeStore is running...
```

---

## 🎯 سؤال انترفيو شامل — بعد كونسيبت 1 و2

> **"إيه الـ Connection Pool في MongoDB؟ وإيه المشكلة اللي بتحصل لو عملت `new MongoClient()` في كل request؟ وإيه الـ `minPoolSize` وامتى تزوّده؟"**

**الإجابة المقنعة:**

الـ **Connection Pool** هو مجموعة من الـ TCP connections جاهزة ومفتوحة مع الـ MongoDB Server. لما request بييجيلك، الـ Driver بياخد connection جاهزة من الـ pool، بينفّذ الـ query، وبيرجّع الـ connection للـ pool تاني.

لو عملت `new MongoClient()` وـ `connect()` في كل request — هتعمل **TCP Handshake** جديد في كل مرة. ده بيكلّف من 100 إلى 300ms لكل request — في الوقت اللي الـ reuse بتاع connection موجودة بياخد أقل من millisecond واحدة. في production مع 1000 request/sec، ده catastrophic.

الـ `minPoolSize` بتزوّده لما عندك app بيستقبل traffic دايماً — زي API بيتكلمه load balancer على مدار اليوم. الـ `0` (default) معناه إن الـ pool ممكن يوصل لـ zero connections وقت ما في requests — وأول request تييجي بعد الـ idle period بتاخد وقت عشان تبني connection من أول. الـ `minPoolSize: 2` بيضمن إن في connections جاهزة دايماً حتى في الـ quiet times.

الأنماط الغلط الشائعة:

```
❌ غلط: new MongoClient() في كل request
❌ غلط: client.close() بعد كل query
❌ غلط: MongoClient بـ maxPoolSize: 1 في production

✅ صح: Singleton MongoClient — مرة واحدة في حياة الـ process
✅ صح: client.close() بس في الـ SIGINT/SIGTERM handler
✅ صح: ضبط maxPoolSize على حسب عدد الـ concurrent requests المتوقعة
```

---

# الفصل 2 — الكتابة والقراءة: بنملا الـ DB بحياة حقيقية

---

## 🧩 كونسيبت 3: الـ Native Insert — الكتابة بلا قواعد... بس بحكمة

### 🧩 الكونسيبت

في الـ Mongoose، لما بتعمل insert، في **Schema** بيراجع البيانات أولاً. لو الـ field مش موجود في الـ Schema، اتعدم. لو مطلوب ومش موجود، throw error.

في الـ **Native Driver**؟ مفيش حاجة اسمها Schema من ناحية MongoDB. بتقوله "احفظ الـ Object ده" — وبيحفظه كما هو. الـ MongoDB نفسها بتقبل **أي document بأي شكل** — وده اللي بيتسمى **Dynamic Schema** أو **Schemaless** (مع إن الاسم ده misleading شوية — في schema، بس في مستوى الـ application مش الـ DB).

```
┌────────────────────────────────────────────────────────────────────┐
│                  Insert Flow — Native vs Mongoose                  │
│                                                                    │
│   NATIVE DRIVER:                                                   │
│                                                                    │
│   Your JS Object ──────────────────────────────► MongoDB          │
│   { name, price, tags }    BSON Serialize        stores it        │
│                            بدون validation        exactly         │
│                            بدون schema check      as-is           │
│                                                                    │
│   MONGOOSE:                                                        │
│                                                                    │
│   Your JS Object → Schema Validation → Middleware → MongoDB       │
│   { name, price }    ↑ لو field زيادة    pre-save    stores it    │
│                         بيتشاله          hooks        after ok    │
│                      ↑ لو required                                │
│                         مش موجود                                  │
│                         ValidationError                            │
│                                                                    │
│   ↑ الـ Native Driver أسرع لأن مفيش validation overhead          │
│   ↑ لكن المسؤولية عليك — انت بتـ validate في الـ code            │
└────────────────────────────────────────────────────────────────────┘
```

الـ Insert Methods في الـ Native Driver:

| الـ Method | الاستخدام | بيرجع |
|---|---|---|
| `insertOne(doc)` | إدراج document واحد | `{ acknowledged, insertedId }` |
| `insertMany(docs[])` | إدراج أكتر من document دفعة واحدة | `{ acknowledged, insertedIds, insertedCount }` |

---

### 💡 مثال عام

```javascript
// مثال معزول — insertOne و insertMany بالـ Native Driver
import { MongoClient } from 'mongodb';

const client = new MongoClient('mongodb://localhost:27017');
const db = client.db('demo');
const items = db.collection('items');

async function insertDemo() {
  await client.connect();

  // ── insertOne ─────────────────────────────────────────
  const singleResult = await items.insertOne({
    name: 'Laptop Pro X',
    price: 35000,
    category: 'laptops',
    specs: { ram: '16GB', storage: '512GB SSD' },  // ← nested object
    tags: ['gaming', 'developer', 'portable'],       // ← array
    inStock: true,
    createdAt: new Date(),                           // ← Date object → ISODate في الـ DB
  });

  console.log('insertOne result:', singleResult);

  // ── insertMany ────────────────────────────────────────
  const manyResult = await items.insertMany([
    {
      name: 'Phone Alpha',
      price: 15000,
      category: 'phones',
      specs: { ram: '8GB', camera: '50MP' },       // ← specs مختلفة عن اللاب توب!
      inStock: true,
      createdAt: new Date(),
    },
    {
      name: 'Headphones Bass',
      price: 2500,
      category: 'accessories',
      // ↑ الـ document ده مالوش specs — وده مش مشكلة في MongoDB!
      color: 'Black',                               // ← field جديد ما جاش في اللي فاتوا
      inStock: false,
      createdAt: new Date(),
    },
  ]);

  console.log('insertMany result:', manyResult);

  await client.close();
}

insertDemo();
```

---

### 📊 نتيجة المثال

**الـ Console بيطبع:**

```javascript
// نتيجة insertOne
insertOne result: {
  acknowledged: true,
  insertedId: ObjectId('64f9a1b2c3d4e5f6a7b8c9d0')
  // ↑ MongoDB ولّدت الـ _id تلقائياً
}

// نتيجة insertMany
insertMany result: {
  acknowledged: true,
  insertedCount: 2,
  insertedIds: {
    '0': ObjectId('64f9a1b2c3d4e5f6a7b8c9d1'),
    '1': ObjectId('64f9a1b2c3d4e5f6a7b8c9d2')
  }
}
```

**اللي حصل في الـ DB:**

```javascript
// الـ items collection دلوقتي فيها 3 documents
// كل واحد ليه شكل مختلف شوية — وده طبيعي تماماً

// Document 1:
{
  _id: ObjectId('64f9a1b2c3d4e5f6a7b8c9d0'),
  name: 'Laptop Pro X',
  price: 35000,
  category: 'laptops',
  specs: { ram: '16GB', storage: '512GB SSD' },
  tags: ['gaming', 'developer', 'portable'],
  inStock: true,
  createdAt: ISODate('2024-09-07T10:30:00.000Z')
}

// Document 2:
{
  _id: ObjectId('64f9a1b2c3d4e5f6a7b8c9d1'),
  name: 'Phone Alpha',
  price: 15000,
  category: 'phones',
  specs: { ram: '8GB', camera: '50MP' },    // ← مختلف عن specs الـ laptop
  inStock: true,
  createdAt: ISODate('2024-09-07T10:30:00.000Z')
}

// Document 3:
{
  _id: ObjectId('64f9a1b2c3d4e5f6a7b8c9d2'),
  name: 'Headphones Bass',
  price: 2500,
  category: 'accessories',
  color: 'Black',     // ← field مش موجود في الـ documents التانية — وده ok!
  inStock: false,
  createdAt: ISODate('2024-09-07T10:30:00.000Z')
}
```

---

### 🏗️ تطبيق المشروع (Actionable)

اعمل ملف `src/products/product.service.js` واكتب فيه الكود ده:

```javascript
// src/products/product.service.js
import { db } from '../db/client.js';

// ──────────────────────────────────────────────────────────────────
// بنـ get الـ collection هنا — مش في الـ top level
// عشان الـ db object يكون ready بعد connectDB()
// ──────────────────────────────────────────────────────────────────
const getCollection = () => db.collection('products');

// ── createProduct ─────────────────────────────────────────────────
// بناخد الـ data من الـ controller، بنـ add الـ metadata، وبنحفظ
export async function createProduct(data) {
  const collection = getCollection();

  // Validation بسيطة — هنا مسؤوليتنا لأن مفيش Mongoose Schema
  if (!data.name || !data.price || !data.category) {
    throw new Error('name, price, and category are required');
  }
  if (typeof data.price !== 'number' || data.price <= 0) {
    throw new Error('price must be a positive number');
  }

  const document = {
    ...data,
    inStock: data.inStock ?? true,   // ← default value بنعمله إحنا
    viewCount: 0,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const result = await collection.insertOne(document);

  // بنرجع الـ document كامل مع الـ _id اللي MongoDB ولّدته
  return { _id: result.insertedId, ...document };
}

// ── seedProducts ──────────────────────────────────────────────────
// بنملا الـ DB ببيانات تجريبية — مرة واحدة للبداية
export async function seedProducts() {
  const collection = getCollection();

  const existingCount = await collection.countDocuments();
  if (existingCount > 0) {
    console.log(`ℹ️  Products already seeded (${existingCount} docs) — skipping`);
    return;
  }

  const products = [
    {
      name: 'MacBook Pro M3',
      price: 89000,
      category: 'laptops',
      specs: { ram: '18GB', storage: '512GB', chip: 'M3 Pro' },
      tags: ['apple', 'developer', 'premium'],
      inStock: true,
      viewCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      name: 'Samsung Galaxy S24',
      price: 32000,
      category: 'phones',
      specs: { ram: '12GB', camera: '200MP', display: '6.2 inch' },
      tags: ['samsung', 'android', 'flagship'],
      inStock: true,
      viewCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      name: 'Sony WH-1000XM5',
      price: 11000,
      category: 'accessories',
      color: 'Black',
      noiseCancel: true,
      batteryHours: 30,
      // ↑ لاحظ — مفيش specs هنا، وده مش مشكلة. الـ Dynamic Schema في action
      inStock: true,
      viewCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      name: 'Dell XPS 15',
      price: 67000,
      category: 'laptops',
      specs: { ram: '32GB', storage: '1TB', gpu: 'RTX 4060' },
      tags: ['dell', 'gaming', 'developer'],
      inStock: false,
      viewCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const result = await collection.insertMany(products);
  console.log(`✅ Seeded ${result.insertedCount} products into NativeStore`);
}
```

دلوقتي عدّل `src/index.js` تستدعي الـ seed:

```javascript
// src/index.js
import 'dotenv/config';
import { connectDB } from './db/client.js';
import { seedProducts } from './products/product.service.js';

async function startApp() {
  await connectDB();
  await seedProducts();
  console.log('🚀 NativeStore is running...');
}

startApp();
```

شغّل `npm run dev` — المفروض تشوف:

```
✅ NativeStore DB connected — pool ready
📦 Database: "nativestore" | maxPool: 10
✅ Seeded 4 products into NativeStore
🚀 NativeStore is running...
```

---

## 🧩 كونسيبت 4: الـ ObjectId والـ BSON — اللي بيسافر بين Node.js والـ DB

### 🧩 الكونسيبت

لما بتكتب `{ name: "Laptop", price: 35000 }` في الـ JavaScript — وبتبعته للـ MongoDB — في رحلة كاملة بتحصل قبل ما الـ data توصل للـ disk.

الـ JavaScript بيخزن كل حاجة كـ **JSON format** (JavaScript Object Notation). بس الـ MongoDB مش بتخزن JSON — بتخزن **BSON** (Binary JSON).

**إيه الفرق؟**

```
┌─────────────────────────────────────────────────────────────────────┐
│                        JSON vs BSON                                 │
│                                                                     │
│   JSON:                          BSON:                             │
│   ──────                         ──────                            │
│   Text-based                     Binary-based                      │
│   Human readable                 Machine optimized                  │
│   Limited types:                 Rich types:                       │
│     String                         String                           │
│     Number (no distinction)        Int32, Int64, Double, Decimal128 │
│     Boolean                        Boolean                          │
│     null                           Null                             │
│     Array                          Array                            │
│     Object                         Document (Object)                │
│     ──── ده بس ────               Date  ← مش موجود في JSON!        │
│                                    ObjectId ← مش موجود في JSON!    │
│                                    Binary ← مش موجود في JSON!      │
│                                    Regex ← مش موجود في JSON!       │
│                                                                     │
│   Size: نصبياً أكبر              Size: أصغر وأسرع في parsing       │
│   لأنه text كله                  لأنه binary مع length prefixes    │
└─────────────────────────────────────────────────────────────────────┘
```

**الـ ObjectId — المعجزة الصغيرة:**

الـ `_id` في كل document مش مجرد رقم عشوائي. ده **12 bytes** مصمّمة بدقة:

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ObjectId — 12 bytes                            │
│                                                                     │
│   64f9a1b2   c3d4e5   f6a7   b8c9d0                               │
│   ─────────   ──────   ────   ──────                               │
│   4 bytes     3 bytes  2 bytes 3 bytes                             │
│                                                                     │
│   Unix         Machine  PID    Random                              │
│   Timestamp    ID       ────   Counter                             │
│   ─────────                                                        │
│   ↑ ده بيخلي كل ObjectId                                          │
│   يعبّر عن الوقت اللي اتعمل فيه!                                   │
│                                                                     │
│   ObjectId('64f9a1b2...').getTimestamp()                           │
│   → 2024-09-07T10:30:00.000Z                                      │
│                                                                     │
│   ↑ ده معناه إنك ممكن تعرف امتى الـ document اتعمل                │
│   بدون ما يكون عندك createdAt field — من الـ _id نفسه!            │
└─────────────────────────────────────────────────────────────────────┘
```

ليه ObjectId أحسن من `AUTO_INCREMENT` في SQL؟

| الجانب | AUTO_INCREMENT (SQL) | ObjectId (MongoDB) |
|---|---|---|
| الـ Generation | بيتولّد في الـ DB | بيتولّد في الـ Driver (client-side) |
| الـ Uniqueness | في حدود الـ table | Globally unique — حتى لو عندك 10 DB servers |
| الـ Order | Sequential تماماً | Roughly ordered (بالـ timestamp) |
| الـ Scalability | صعب مع distributed DBs | طبيعي مع الـ Sharding |

---

### 💡 مثال عام

```javascript
// مثال معزول — ObjectId وBSON types
import { MongoClient, ObjectId } from 'mongodb';

const client = new MongoClient('mongodb://localhost:27017');

async function bsonDemo() {
  await client.connect();
  const db = client.db('demo');
  const col = db.collection('bson_test');

  // ── إنشاء ObjectId يدوياً ─────────────────────────────────────
  const manualId = new ObjectId();
  console.log('New ObjectId:', manualId);
  console.log('As string:', manualId.toString());
  console.log('Timestamp inside:', manualId.getTimestamp());

  // ── Insert مع BSON types مختلفة ──────────────────────────────
  await col.insertOne({
    _id: manualId,              // ← ObjectId
    name: 'Test Item',          // ← String (BSON String)
    price: 1500,                // ← Number (BSON Int32)
    rating: 4.5,                // ← Number (BSON Double)
    inStock: true,              // ← Boolean
    tags: ['a', 'b'],           // ← Array
    meta: { views: 0 },         // ← Nested Document
    createdAt: new Date(),      // ← JavaScript Date → BSON Date
    // ↑ ده مش string! ده ISODate حقيقي في الـ DB — بتقدر تعمل date comparisons عليه
  });

  // ── Query بـ ObjectId — لازم تحوّله من String ────────────────
  const idAsString = manualId.toString();

  // ❌ غلط — هيرجع null لأن MongoDB بتقارن ObjectId بـ ObjectId مش بـ string
  const wrong = await col.findOne({ _id: idAsString });

  // ✅ صح — لازم تـ convert للـ ObjectId object الأول
  const correct = await col.findOne({ _id: new ObjectId(idAsString) });

  console.log('Wrong query result:', wrong);     // null
  console.log('Correct query result:', correct); // الـ document

  await client.close();
}

bsonDemo();
```

---

### 📊 نتيجة المثال

```javascript
// الـ Console
New ObjectId: new ObjectId('64f9a1b2c3d4e5f6a7b8c9d0')
As string: '64f9a1b2c3d4e5f6a7b8c9d0'
Timestamp inside: 2024-09-07T10:30:42.000Z

Wrong query result: null
// ↑ لأن '64f9a1b2...' (string) ≠ ObjectId('64f9a1b2...') (binary)

Correct query result: {
  _id: new ObjectId('64f9a1b2c3d4e5f6a7b8c9d0'),
  name: 'Test Item',
  price: 1500,
  rating: 4.5,
  inStock: true,
  tags: [ 'a', 'b' ],
  meta: { views: 0 },
  createdAt: 2024-09-07T10:30:42.000Z
}
```

---

### 🏗️ تطبيق المشروع (Actionable)

الـ ObjectId بيجي مهم جداً لما بتتعامل مع الـ routes. اعمل ملف `src/db/helpers.js`:

```javascript
// src/db/helpers.js
import { ObjectId } from 'mongodb';

// ──────────────────────────────────────────────────────────────────
// Helper لتحويل string لـ ObjectId بأمان
// بدل ما تكتب new ObjectId() وتيجيلك exception بدون error handling
// ──────────────────────────────────────────────────────────────────
export function toObjectId(id) {
  // ObjectId.isValid() بيتحقق إن الـ string هيتحول بنجاح
  if (!ObjectId.isValid(id)) {
    throw new Error(`Invalid ID format: "${id}"`);
  }
  return new ObjectId(id);
}

// Helper لجيب الـ timestamp من الـ ObjectId
export function getDocumentCreationTime(id) {
  const objectId = toObjectId(id);
  return objectId.getTimestamp();
  // ده بيرجع Date object — نفس وقت الإنشاء حتى لو مفيش createdAt field
}

// Helper لـ pagination metadata
export function buildPaginationMeta({ total, page, limit }) {
  const totalPages = Math.ceil(total / limit);
  return {
    total,
    page,
    limit,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1,
  };
}
```

دلوقتي أضف function لـ `product.service.js` تجيب product بالـ ID:

```javascript
// في src/products/product.service.js — أضف الـ import والـ function دول

import { db } from '../db/client.js';
import { toObjectId } from '../db/helpers.js';  // ← أضف السطر ده

// ── getProductById ──────────────────────────────────────────────
export async function getProductById(id) {
  const collection = getCollection();

  // toObjectId بترمي Error واضحة لو الـ format غلط
  // بدل الـ BSONTypeError الغامضة من MongoDB
  const objectId = toObjectId(id);

  const product = await collection.findOne({ _id: objectId });

  if (!product) {
    throw new Error(`Product not found with id: ${id}`);
  }

  return product;
}
```

---

## 🎯 سؤال انترفيو شامل — بعد كونسيبت 3 و4

> **"إيه الـ BSON وليه MongoDB بتستخدمه بدل JSON؟ وإيه الـ ObjectId — وإيه المشكلة اللي ممكن تحصل لما بتعمل query بـ string بدل ObjectId؟"**

**الإجابة المقنعة:**

الـ **BSON (Binary JSON)** هو التنسيق اللي MongoDB بتخزن بيه البيانات على الـ disk وبتنقلها على الـ network. بالرغم من إن اسمه فيه JSON، إلا إنه binary مش text — وده بيديه 3 مزايا رئيسية:

الأولى: **Rich Type System** — الـ JSON عنده `number` واحد بيغطي كل حاجة، الـ BSON عنده `Int32`، `Int64`، `Double`، `Decimal128` — وده مهم جداً في التطبيقات المالية عشان تتجنب floating-point errors. كمان الـ BSON عنده `Date` type حقيقي وـ `ObjectId` وـ `Binary` — مش موجودين في JSON.

التانية: **Size Efficiency** — الـ BSON بيخزّن الـ length قبل كل field (length-prefixed encoding)، ده بيخلي parsing أسرع بكتير لأن الـ DB بتقفز للـ field اللي محتاجاه بدل ما تقرأ كل حاجة.

التالتة: **Traversal Speed** — نفس الـ length-prefix بيخلي MongoDB تتخطى fields مش محتاجاها في الـ scan.

بالنسبة للـ **ObjectId** — ده 12-byte identifier اتصمم بذكاء: 4 bytes Unix timestamp، 3 bytes machine identifier، 2 bytes process ID، 3 bytes random counter. ده بيديه خاصية مهمة: **globally unique بدون coordination** — مش محتاج الـ DB تعمل lock أو تسأل server تاني قبل ما تولّد الـ ID. ده مهم جداً في الـ distributed systems والـ sharding.

المشكلة الشائعة هي إن الـ developer بياخد الـ `_id` كـ string من الـ request parameters — `req.params.id` مثلاً — ويعمل `findOne({ _id: req.params.id })`. ده بيرجع `null` دايماً، لأن `"64f9a1b2..."` (string) مختلف تماماً عن `ObjectId("64f9a1b2...")` (binary). لازم دايماً تعمل `new ObjectId(id)` — وتـ wrap في `ObjectId.isValid()` الأول عشان لو الـ string format غلط، بيـ throw exception.

```javascript
// ✅ الطريقة الصح دايماً
const safeQuery = async (id) => {
  if (!ObjectId.isValid(id)) return null; // أو throw error
  return collection.findOne({ _id: new ObjectId(id) });
};
```

---

## 🧩 كونسيبت 5: الـ Native Find & Queries — الاستعلام عن البيانات بالـ MQL

### 🧩 الكونسيبت

الـ **MQL (MongoDB Query Language)** هو اللغة اللي بتتكلم بيها مع MongoDB. مش SQL — ده objects بتبعتهم وـ MongoDB بتفسّرهم.

في حاجتين أساسيتين في الـ query: الـ **Filter** (مين اللي عايزه) والـ **Projection** (الـ fields اللي عايز ترجّعها).

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Anatomy of a Find Query                       │
│                                                                     │
│   collection.find( filter , options )                               │
│                    ──────   ───────                                │
│                    │        │                                       │
│                    │        └─ {                                    │
│                    │              projection: { name: 1, price: 1 }│
│                    │              sort:       { price: -1 }         │
│                    │              skip:       20                    │
│                    │              limit:      10                    │
│                    │           }                                    │
│                    │                                               │
│                    └─ {                                             │
│                          category: 'laptops',    ← exact match    │
│                          price: { $lte: 50000 }, ← operator       │
│                          inStock: true,          ← boolean         │
│                          tags: { $in: ['apple'] }← array operator  │
│                       }                                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**الـ Query Operators الأساسية:**

| الـ Operator | المعنى | مثال |
|---|---|---|
| `$eq` | يساوي (default) | `{ price: { $eq: 1000 } }` = `{ price: 1000 }` |
| `$ne` | لا يساوي | `{ status: { $ne: 'deleted' } }` |
| `$gt` | أكبر من | `{ price: { $gt: 5000 } }` |
| `$gte` | أكبر من أو يساوي | `{ price: { $gte: 5000 } }` |
| `$lt` | أصغر من | `{ price: { $lt: 20000 } }` |
| `$lte` | أصغر من أو يساوي | `{ price: { $lte: 20000 } }` |
| `$in` | موجود في array | `{ category: { $in: ['phones','laptops'] } }` |
| `$nin` | مش موجود في array | `{ category: { $nin: ['accessories'] } }` |
| `$exists` | الـ field موجود أصلاً | `{ specs: { $exists: true } }` |
| `$and` | الشرطين معاً | `{ $and: [{ price: { $gt: 5000 } }, { inStock: true }] }` |
| `$or` | أي من الشرطين | `{ $or: [{ category: 'phones' }, { category: 'laptops' }] }` |
| `$regex` | pattern matching | `{ name: { $regex: 'pro', $options: 'i' } }` |

**الفرق بين `find()` و `findOne()`:**

```
collection.find(filter)
  → بيرجع Cursor — مش Array مباشرة!
  → لازم تعمل .toArray() أو تـ iterate عليه
  → لو مفيش نتائج → cursor فاضي مش null

collection.findOne(filter)
  → بيرجع document واحد مباشرة
  → لو مفيش نتائج → null
  → لو لقى أكتر من واحد → بياخد الأول بس
```

---

### 💡 مثال عام

```javascript
// مثال معزول — find و findOne مع operators مختلفة
import { MongoClient } from 'mongodb';

const client = new MongoClient('mongodb://localhost:27017');

async function findDemo() {
  await client.connect();
  const db = client.db('demo');
  const products = db.collection('products');

  // ── findOne — بياخد الأول اللي بيلاقيه ──────────────────────
  const laptop = await products.findOne(
    { category: 'laptops' },
    { projection: { name: 1, price: 1, _id: 0 } }
    //             ↑ 1 = اجيبه   ↑ 0 = ماتجيبوش
  );
  console.log('First laptop:', laptop);

  // ── find مع operators ─────────────────────────────────────────
  const affordable = await products
    .find({
      price: { $lte: 15000 },   // أصغر من أو يساوي 15000
      inStock: true,
    })
    .sort({ price: 1 })         // ترتيب تصاعدي بالسعر (1 = asc, -1 = desc)
    .limit(5)
    .toArray();                  // ← لازم toArray() عشان تحوّل الـ Cursor لـ Array

  console.log('Affordable in-stock:', affordable);

  // ── find مع $or ───────────────────────────────────────────────
  const techItems = await products
    .find({
      $or: [
        { category: 'phones' },
        { category: 'laptops' },
      ],
    })
    .sort({ createdAt: -1 })    // الأحدث الأول
    .toArray();

  console.log('Phones and laptops:', techItems.length, 'items');

  // ── find مع $regex (Search) ───────────────────────────────────
  const searchResults = await products
    .find({
      name: { $regex: 'pro', $options: 'i' },  // 'i' = case-insensitive
    })
    .projection({ name: 1, price: 1 })
    .toArray();

  console.log('Search "pro":', searchResults);

  // ── Pagination ────────────────────────────────────────────────
  const page = 2;
  const limit = 2;

  const [items, total] = await Promise.all([
    products
      .find({})
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)   // ← تخطى الـ docs اللي فاتت
      .limit(limit)
      .toArray(),
    products.countDocuments({}),   // ← إجمالي الـ count للـ pagination
  ]);

  console.log('Page 2 items:', items);
  console.log('Total:', total);

  await client.close();
}

findDemo();
```

---

### 📊 نتيجة المثال

```javascript
// لو الـ DB فيها الـ 4 products اللي عملناهم في الـ seed

// findOne result:
First laptop: { name: 'MacBook Pro M3', price: 89000 }
// ↑ بس name وprice — _id اتشالت بسبب projection { _id: 0 }

// find affordable in-stock:
Affordable in-stock: [
  { _id: ObjectId('...'), name: 'Sony WH-1000XM5', price: 11000, ... },
  { _id: ObjectId('...'), name: 'Samsung Galaxy S24', price: 32000, ... }
]
// ↑ Dell XPS 15 اتشال لأن inStock: false
// ↑ MacBook اتشال لأن price: 89000 > 15000

// Phones and laptops count:
Phones and laptops: 3 items
// ↑ MacBook + Samsung + Dell

// Search "pro":
Search "pro": [
  { _id: ObjectId('...'), name: 'MacBook Pro M3', price: 89000 },
  // ↑ بس MacBook لأنه الوحيد اللي فيه "pro" في الاسم
]

// Pagination page 2:
Page 2 items: [
  { ..., name: 'Samsung Galaxy S24', ... },
  { ..., name: 'MacBook Pro M3', ... }
]
Total: 4
```

---

### 🏗️ تطبيق المشروع (Actionable)

أضف الـ query functions دي لـ `src/products/product.service.js`:

```javascript
// في src/products/product.service.js — أضف الـ functions دول

// ── getProducts — مع Filter + Sort + Pagination ──────────────────
export async function getProducts({ page = 1, limit = 10, category, keyword, maxPrice, inStock } = {}) {
  const collection = getCollection();

  // ── بناء الـ Filter ديناميكياً ────────────────────────────────
  const filter = {};

  if (category) {
    filter.category = category;                      // exact match
  }

  if (keyword) {
    filter.name = { $regex: keyword, $options: 'i' };// case-insensitive search
  }

  if (maxPrice !== undefined) {
    filter.price = { $lte: Number(maxPrice) };
  }

  if (inStock !== undefined) {
    filter.inStock = inStock === 'true' || inStock === true;
  }

  // ── Pagination Math ───────────────────────────────────────────
  const pageNum  = Math.max(1, parseInt(page));
  const limitNum = Math.min(50, Math.max(1, parseInt(limit)));  // max 50 per page
  const skip     = (pageNum - 1) * limitNum;

  // ── Run Query + Count في parallel ────────────────────────────
  const [products, total] = await Promise.all([
    collection
      .find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limitNum)
      .project({ __v: 0 })       // ← شال الـ __v لو موجود
      .toArray(),

    collection.countDocuments(filter),
  ]);

  return {
    products,
    pagination: {
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum),
      hasNextPage: pageNum < Math.ceil(total / limitNum),
      hasPrevPage: pageNum > 1,
    },
  };
}

// ── getProductsByCategory ─────────────────────────────────────────
export async function getProductsByCategory(category) {
  const collection = getCollection();

  return collection
    .find({ category })
    .sort({ price: 1 })
    .toArray();
}

// ── searchProducts ────────────────────────────────────────────────
export async function searchProducts(keyword) {
  if (!keyword || keyword.trim().length < 2) {
    throw new Error('Search keyword must be at least 2 characters');
  }

  const collection = getCollection();

  return collection
    .find({
      $or: [
        { name:     { $regex: keyword, $options: 'i' } },
        { category: { $regex: keyword, $options: 'i' } },
        { tags:     { $elemMatch: { $regex: keyword, $options: 'i' } } },
      ],
    })
    .sort({ viewCount: -1 })   // الأكتر مشاهدة الأول في الـ search results
    .limit(20)
    .toArray();
}
```

اعمل ملف `src/index.js` النهائي اللي بيختبر كل الـ functions:

```javascript
// src/index.js — نسخة الاختبار الكاملة
import 'dotenv/config';
import { connectDB } from './db/client.js';
import { seedProducts, getProducts, searchProducts, getProductById } from './products/product.service.js';

async function startApp() {
  await connectDB();
  await seedProducts();

  console.log('\n──── Test: getProducts (page 1) ────');
  const page1 = await getProducts({ page: 1, limit: 2 });
  console.log('Products:', page1.products.map(p => p.name));
  console.log('Pagination:', page1.pagination);

  console.log('\n──── Test: getProducts with category filter ────');
  const laptops = await getProducts({ category: 'laptops' });
  console.log('Laptops:', laptops.products.map(p => p.name));

  console.log('\n──── Test: searchProducts ────');
  const searchRes = await searchProducts('pro');
  console.log('Search "pro":', searchRes.map(p => p.name));

  console.log('\n✅ All tests passed');
}

startApp();
```

---

## 🎯 سؤال انترفيو شامل — بعد كونسيبت 5

> **"في الـ Native MongoDB Driver، إيه الفرق بين `find()` و`findOne()`؟ وإيه الـ Cursor ولماذا بيرجع مش Array؟ وامتى تستخدم `$or` مقابل `$in`؟"**

**الإجابة المقنعة:**

**`findOne()`** بيبعت query للـ MongoDB بـ `limit: 1` — بياخد أول document بيلاقيه ويرجعه مباشرة كـ JavaScript object، أو `null` لو مفيش نتائج. **`find()`** مختلف جوهرياً — مش بيرجع البيانات كلها دفعة واحدة. بيرجع **Cursor**.

الـ **Cursor** هو pointer على الـ result set في الـ MongoDB Server — مش الـ data نفسها. الفكرة إنك ممكن عندك مليون document في الـ result، ولو جابتهم كلهم في الذاكرة مرة واحدة، الـ Node.js process هتـ crash. الـ Cursor بيخليك تجيبهم بـ batches — الـ default batch size هو 101 document أول مرة وبعدين 16MB chunks.

لما بتعمل `.toArray()` — بتقوله جيب كل الـ batches وحوّلهم لـ array. ده مقبول لو عارف إن الـ result set صغير. لو بتتعامل مع كميات كبيرة، بتستخدم `.forEach()` أو `for await...of` عشان تعالج كل document على حدى بدون ما تحمّل الكل في الذاكرة.

بالنسبة لـ **`$or` vs `$in`**:

```javascript
// اللي بتعمله $in —
{ category: { $in: ['phones', 'laptops'] } }

// نفس النتيجة لو عملته بـ $or —
{ $or: [{ category: 'phones' }, { category: 'laptops' }] }

// بس في فرق في الـ performance:
// $in على نفس الـ field = أسرع بكتير — MongoDB بتعمله في operation واحدة
// $or على fields مختلفة = ممكن يحتاج multiple index lookups

// القاعدة:
// نفس الـ field + أكتر من value → $in دايماً
// fields مختلفة + أكتر من شرط → $or
```

---

## 🗺️ خريطة Module 1 & 2 كاملة

```
NativeStore — Module 1 & 2 — ما اتعلمناه

Setup
├── npm init + npm install mongodb
├── package.json (type: module)
├── .env (MONGO_URI, DB_NAME)
└── src/index.js (entry point)

Connection
├── MongoClient Singleton
├── Connection Pool (maxPoolSize, minPoolSize)
├── connectDB() — مرة واحدة في الـ app
└── SIGINT handler — graceful shutdown

Insert
├── insertOne → { acknowledged, insertedId }
├── insertMany → { insertedCount, insertedIds }
├── Dynamic Schema — كل document شكله مختلف وده طبيعي
└── Manual validation — مسؤوليتنا مش الـ DB

BSON & ObjectId
├── BSON = Binary JSON — rich types
├── ObjectId = 12 bytes (timestamp + machine + pid + counter)
├── getTimestamp() — وقت الإنشاء من الـ _id نفسه
└── new ObjectId(string) — لازم convert قبل الـ query

Find & Queries
├── findOne → document أو null
├── find → Cursor (مش Array!)
├── .toArray() — لما تعرف الـ result صغير
├── Query Operators ($eq, $gt, $lt, $in, $or, $regex)
├── Projection { field: 1 } / { field: 0 }
├── sort, skip, limit — للـ pagination
└── Promise.all([find, countDocuments]) — للـ pagination مع metadata
```

---

## ✅ Checkpoint — أسئلة إنترفيو Module 1 & 2

**س: إيه الـ Singleton Pattern في MongoClient وليه مهم؟**
> الـ `MongoClient` لازم يتعمل **مرة واحدة في حياة الـ process** ويتشارك بين كل الـ modules. لو عملته في كل request أو في كل module بمستقل، هتعمل عشرات الـ Connection Pools — كل واحد بياخد resources وبيفتح connections جديدة على الـ MongoDB Server. ده بيؤدي لـ connection exhaustion بسرعة وبيبطّئ التطبيق بشكل مجنون. الـ Singleton بيضمن pool واحدة منظّمة ومُدارة.

**س: إيه الفرق بين JSON وBSON وليه MongoDB اختارت BSON؟**
> الـ JSON هو text-based format بـ type system محدود. الـ BSON هو binary encoding بيضيف types مش موجودة في JSON: `Date`، `ObjectId`، `Int32`، `Int64`، `Decimal128`، `Binary`. المزايا: (1) أصغر في الحجم وأسرع في الـ parsing لأنه binary مع length prefixes. (2) بيدعم types أكثر دقة للأرقام — مهم في الـ financial applications. (3) الـ MongoDB بتقدر تتخطى الـ fields مش محتاجاها بسرعة بدل ما تقرأ كل حاجة.

**س: ليه `find()` بيرجع Cursor مش Array وامتى تعمل `.toArray()`؟**
> الـ Cursor هو pointer على الـ result set في الـ Server — مش الـ data نفسها. ده بيحميك من `OutOfMemoryError` لو الـ result كبير. بتعمل `.toArray()` بس لما متأكد إن الـ result محدود الحجم (زي pagination مع limit). لو بتعمل export أو processing لكميات كبيرة، استخدم `for await...of cursor` أو `cursor.forEach()` عشان تعالج كل document على حدى.

**س: إيه أكبر فرق بين الـ Native Driver والـ Mongoose من ناحية Insert؟**
> الـ Mongoose بيمرر الـ data على Schema validation وMiddleware قبل ما يبعتها للـ DB. الـ required fields بتتتحقق، الـ types بتتكاست، الـ pre-save hooks بتشتغل. الـ Native Driver مش بيعمل أي من ده — بياخد الـ object ويبعته للـ MongoDB كما هو (بعد تحويله لـ BSON). ده معناه الـ Native أسرع، لكن الـ Validation مسؤوليتك — لازم تعملها في الـ application layer بنفسك، وده بالظبط اللي عملناه في `createProduct()`.

---

## 🫒 زتونة الإنترفيو — Module 1 & 2

> **"لما بتسألوني عن الـ Native MongoDB Driver، أنا مش بفكر فيه كـ 'بديل أبسط من Mongoose.' أنا بفكر فيه كـ الـ foundation اللي كل حاجة شايلة عليه. الـ MongoClient مش مجرد object — ده Connection Pool Manager. بيبني مدينة صغيرة من الـ TCP connections ويديرها تلقائياً. الغلطة الأساسية اللي بيعملها الناس هي `new MongoClient()` في كل request — ده بيقتل الـ performance لأن كل TCP connection بتاخد 100-300ms تتفتح. الـ Singleton pattern بيحل ده بالكامل.**
>
> **الـ Insert في الـ Native بـ Dynamic Schema معناه إن MongoDB مش هترفض أي document — لأن الـ schema enforcement مش في الـ DB، ده في الـ application code. ده بيديك مرونة أكبر لكن بيحمّلك المسؤولية.**
>
> **الـ ObjectId مش مجرد ID — ده timestamp + machine + pid + counter في 12 bytes. بيعمل `.getTimestamp()` ويديك وقت الإنشاء بدون `createdAt` field. والـ query بـ string بدل ObjectId هو أكتر bug شايف في code reviews — `'64f9...'` مش نفس `ObjectId('64f9...')` في الـ binary level.**
>
> **والـ find بيرجع Cursor مش Array — ده مش implementation detail، ده architectural decision. عشان ما تحملش ملايين الـ documents في الذاكرة. `.toArray()` بس لما الـ result محدود. غير كده، `for await...of` هو الـ correct pattern."**

---

*Next → [[File 2 — Module 3 & 4]] — Native Update & Delete + Indexes & Performance: هتعرف إزاي بتعدّل وتحذف بالـ Atomic Operators، وإيه الـ Index وليه بيفرق بين query بتاخد 5ms وquery بتاخد 5 seconds.*
