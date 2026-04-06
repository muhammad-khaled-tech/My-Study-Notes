# ⚙️ Module 6: The Missing Heavyweights
> **ملحوظة:** ده الـ Advanced Expansion للـ Vault الأصلي. حطه في نفس الـ Folder في Obsidian وعمل Link منه.
> **المستوى:** Mid-Level → Senior Awareness
> **الهدف:** الحاجات اللي الدكاترة بيسألوا عنها وبيفرقوا بيها بين اللي فاهم ومجرد حافظ.

---

## 🗺️ الـ Roadmap

```
6.1 → Mongoose Middleware — فخ Arrow Function وـ this Context
6.2 → Aggregation Pipeline — $match, $group, $lookup
6.3 → Advanced Populate — Field Selection + Nested Populate
6.4 → Validation & Error Handling — Code 11000 والـ Custom Errors
```

---

# 6.1 🪝 Mongoose Middleware — تحت الكبوت الحقيقي

## الحكاية الكاملة: إيه اللي بيحصل لما بتعمل `.save()`؟

تخيل إنك بتحفظ User جديد. في Mongoose مش بتروح لـ MongoDB مباشرةً. الرحلة دي بتعدي على **Pipeline من الـ Hooks**:

```
.save() ←───────────────────────────────────────────────→ MongoDB

        pre('validate') → validate → post('validate')
                              ↓
        pre('save')    →   save   → post('save')
```

يعني قبل ما أي Document يوصل للـ Database، Mongoose بيوقفه عند كل Station وبيسألك: "عايز تعمل حاجة هنا؟"

---

## 🔐 الـ Use Case الملكي: Hash الـ Password

### الطريقة الصح ✅

```js
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;

userSchema.pre('save', async function (next) {
  // ─── الخطوة 1: هل الـ Password اتغيرت أصلاً؟ ───
  if (!this.isModified('password')) {
    return next(); // مش محتاج نعمل حاجة — روح الخطوة الجاية
  }

  // ─── الخطوة 2: عمل الـ Hash ───
  // bcrypt.hash(plainText, saltRounds)
  // saltRounds = 10 يعني 2^10 = 1024 عملية hashing داخلياً
  this.password = await bcrypt.hash(this.password, SALT_ROUNDS);

  // ─── الخطوة 3: امسح الـ passwordConfirm لو موجود ───
  this.passwordConfirm = undefined;

  next(); // ← مهم جداً! من غيرها الـ Middleware هيتعلق للأبد
});
```

**إيه اللي بيحصل تحت الكبوت في bcrypt؟**

```
plainPassword: "MySecret123"
       ↓
  bcrypt.hash()
       ↓
  [Generate Random Salt] → "$2b$10$randomSaltHere..."
       ↓
  [Hash 1024 times] → CPU-intensive intentionally!
       ↓
  stored: "$2b$10$randomSaltHere...hashedResult"
```

> [!abstract] 🧠 المفهوم المعماري — ليه bcrypt بطيء؟ وده ميزة!
>
> الـ `saltRounds: 10` معناه إن bcrypt بيعمل **2^10 = 1,024 iteration** داخلياً لكل Password.
>
> ده **مقصود ومتعمد**. لو Attacker سرق قاعدة البيانات وحاول يعمل **Brute Force**:
>
> | نوع الـ Hash | وقت تجربة مليون Password |
> |---|---|
> | MD5 (سريع جداً) | ثواني |
> | SHA256 (متوسط) | دقائق |
> | bcrypt (بطيء متعمد) | **سنين** |
>
> الـ `saltRounds` زودها تزيد الأمان وتزيد الـ CPU Load. 10 هو الـ Sweet Spot للـ Production.
>
> **الـ Salt:** رقم عشوائي بيضافه bcrypt للـ Password قبل الـ Hash. ده بيضمن إن نفس الـ Password "123456" عند Ahmed وعند Sara هيبقى ليهم Hashes مختلفة تماماً — ده بيقضي على **Rainbow Table Attacks**.

---

## ☠️ فخ Arrow Function — الخطأ اللي يخليك تفشل

```js
// ❌ كود مكسور — هيفشل بصمت أو بـ Error غريب
userSchema.pre('save', async (next) => {
  //                          ↑
  //              Arrow Function = كارثة هنا!

  console.log(this); // → undefined أو Window object!
  this.password = await bcrypt.hash(this.password, 10); // ← TypeError!
  next();
});

// ✅ الصح دايماً — Regular Function
userSchema.pre('save', async function (next) {
  //                          ↑
  //              Regular Function = this → الـ Document ✅

  console.log(this); // → { name: 'Ahmed', email: '...', password: '...' }
  this.password = await bcrypt.hash(this.password, 10); // ✅ شغال
  next();
});
```

> [!abstract] 🧠 المفهوم المعماري — فخ Arrow Function وـ `this`
>
> ده من أكتر الـ Bugs اللي بتضيع فيها ساعات.
>
> **الـ Rule الذهبية في JavaScript:**
>
> | نوع الـ Function | الـ `this` بتاعها |
> |---|---|
> | **Regular Function** `function() {}` | بيتحدد **وقت الاستدعاء** — بيبقى الـ Object اللي نادى الـ Function |
> | **Arrow Function** `() => {}` | بيتحدد **وقت التعريف** — بياخد الـ `this` من الـ Scope الـ surrounding |
>
> لما Mongoose بيشغّل الـ `pre('save')` Middleware، بيبعت الـ Document كـ `this` **للـ Regular Function**. لكن مع الـ Arrow Function، الـ `this` اتحجز من الوقت اللي اتعرفت فيه الـ Arrow Function — وده ممكن يبقى الـ `module.exports` أو `undefined` في strict mode.
>
> **القاعدة:** أي Mongoose Middleware أو Schema Method أو Virtual — استخدم **Regular Function دايماً**.

---

## 🔍 الـ `isModified()` — ليه لازمة؟

```js
// سيناريو بدون isModified:
// User غيّر اسمه بس
await User.findByIdAndUpdate(id, { $set: { name: 'New Name' } });

// ← لو ما عندناش الـ isModified Check،
//   الـ pre('save') مش هيتشغل هنا (لأن دي Update مش Save)

// لكن:
const user = await User.findById(id);
user.name = 'New Name';
await user.save(); // ← هنا الـ pre('save') بيتشغل!

// بدون isModified → هيعمل Hash للـ Hashed Password مرة تانية!
// النتيجة: Login مستحيل لأن "Hash of Hash" ≠ Original Password
```

> [!abstract] 🧠 المفهوم المعماري — `isModified()` تحت الكبوت
>
> Mongoose بيحتفظ داخلياً بـ "**Dirty Tracking**" — بيعرف أنهي Fields اتغيرت من آخر مرة اتجابت من الـ DB.
>
> `this.isModified('password')` بيسأل Mongoose: "هل الـ password Field اتغيرت في الـ Current Session دي؟"
>
> - لو User **جديد** → password اتغيرت (من undefined لـ value) → `isModified = true` → Hash ✅
> - لو User موجود وعمل Update لـ name بس → `isModified('password') = false` → تجاوز ✅
> - لو User موجود وغيّر الـ password → `isModified = true` → Hash ✅

---

> [!question] 🎯 سؤال انترفيو مشهور — Middleware & bcrypt
>
> **Q1 (Junior): إيه هو الـ Mongoose pre-save Middleware وإيه أشهر استخدام ليه؟**
> **A:** الـ `pre('save')` هو Hook بيتشغل تلقائياً قبل ما أي Document يتحفظ في MongoDB. أشهر استخداماته هو Hash الـ Password بـ bcrypt قبل التخزين — عشان الـ Plain Password ما توصلش قاعدة البيانات خالص.
>
> **Q2 (Junior): ليه لازم نستخدم Regular Function في الـ Middleware مش Arrow Function؟**
> **A:** لأن الـ `this` في الـ Middleware المفروض تبقى الـ Document الـ current. الـ Arrow Function مش بتحدد `this` خاصة بيها — بتاخده من الـ Lexical Scope اللي اتعرفت فيه. الـ Regular Function بتاخد `this` من اللي نادى عليها، وده هنا بيبقى الـ Document نفسه.
>
> **Q3 (Mid): إيه اللي بيحصل لو نسيت تكتب `next()` في الـ Middleware؟**
> **A:** الـ Request هيتعلق (Hang) للأبد. Mongoose بيستنى إنك تنادي `next()` عشان يعرف إن الـ Hook خلّص وممكن يكمل. من غيرها، الـ Promise مش هتـ Resolve ولا هتـ Reject — والـ Client هيستنى Response ما تيجيش.
>
> **Q4 (Mid): إيه الفرق بين `saltRounds: 10` و `saltRounds: 14` في bcrypt؟**
> **A:** كل رقم زيادة بيضاعف الـ Computation — 14 بيعمل 2^14 = 16,384 iteration بدل 1,024. ده بيزوّد الأمان لكن بيزوّد الـ CPU Load على السيرفر. في الـ Production، 10-12 هو الـ Sweet Spot. في الـ Tests، بنحط 1 عشان الـ Tests تبقى سريعة.

---

> [!example] 🏗️ سؤال في مناقشة المشروع
>
> **الدكتور:** "إيه اللي بيحصل بالظبط لما User بيعمل Register في مشروعكم؟"
>
> **الإجابة الكاملة:**
> "الـ Registration Flow بيمشي كده:
>
> 1. Angular بيبعت `POST /api/auth/register` بـ JSON فيه name, email, password
> 2. Express Route Handler بياخد الـ `req.body` ويعمل `new User(data)`
> 3. لما بنعمل `user.save()` — Mongoose بيوقف قبل ما يوصل MongoDB
> 4. الـ `pre('save')` Hook بيشتغل: بيلاقي إن `password` اتغيرت فبيعمل `bcrypt.hash()` بـ 10 salt rounds
> 5. الـ Plain Password بتتستبدل بالـ Hash في الـ Memory
> 6. Mongoose بيكمل ويحفظ الـ Document في MongoDB — الـ Plain Password دخلتش قاعدة البيانات خالص
> 7. بنرجع JWT Token للـ Client
>
> لو كتبنا الـ Middleware بـ Arrow Function، الـ `this` كانت هتبقى `undefined` وكنا هنلاقي `TypeError: Cannot read properties of undefined` وما عرفناش ليه!"

---

---

# 6.2 🔥 Aggregation Pipeline — عقل MongoDB الحقيقي

## الحكاية: إيه الـ Aggregation؟

كل اللي اتعلمناه في الـ CRUD — `find()`, `findOne()` — ده كويس لجلب Documents. لكن لو عايز تجاوب على أسئلة تحليلية:

- "إيه مجموع المبيعات لكل Category؟"
- "مين الـ Top 5 Users الأكتر Orders؟"
- "كام Order اتعمل في كل شهر؟"

الـ `find()` العادي مش هيكفي. هنا بييجي **Aggregation Pipeline**.

**الفكرة:** تخيل إن الـ Data بتاعتك بتعدي على سلسلة من الـ **Stations** — كل Station بتاخد الـ Output من اللي قبلها وبتعمل عليه تحويل معين.

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': {'primaryColor': '#1e293b', 'primaryTextColor': '#94a3b8', 'primaryBorderColor': '#334155', 'lineColor': '#64748b', 'secondaryColor': '#0f172a', 'tertiaryColor': '#1e293b', 'background': '#0f172a', 'mainBkg': '#1e293b', 'nodeBorder': '#475569', 'clusterBkg': '#0f172a', 'titleColor': '#e2e8f0', 'edgeLabelBackground': '#1e293b', 'nodeTextColor': '#e2e8f0'}}}%%
flowchart LR
    A["📦 كل الـ Orders<br/>في الـ Collection"]
    B["$match<br/>─────────<br/>فلتر:<br/>status = 'paid'"]
    C["$group<br/>─────────<br/>جمّع حسب<br/>productCategory<br/>واحسب المجموع"]
    D["$sort<br/>─────────<br/>رتّب تنازلي<br/>حسب الإيراد"]
    E["$limit<br/>─────────<br/>أول 5 بس"]
    F["✅ النتيجة:<br/>Top 5 Categories<br/>بالإيراد"]

    A -->|"1000 Order"| B
    B -->|"700 Order مدفوعة"| C
    C -->|"20 Category"| D
    D -->|"20 Category مرتبة"| E
    E --> F
```

---

## 🏗️ الـ Stages الأساسية

### `$match` — الـ Filter (زي WHERE في SQL)

```js
// جيب بس الـ Orders المدفوعة بعد 2024
{ $match: { status: 'paid', createdAt: { $gte: new Date('2024-01-01') } } }
```

### `$group` — التجميع (زي GROUP BY في SQL)

```js
// احسب إجمالي المبيعات لكل Category
{
  $group: {
    _id: '$category',          // ← اتجمع على أساس الـ category
    totalRevenue: { $sum: '$price' },    // مجموع الـ price
    orderCount:   { $sum: 1 },          // عدد الـ Documents
    avgPrice:     { $avg: '$price' },   // المتوسط
    maxPrice:     { $max: '$price' }    // الأعلى
  }
}
```

### `$lookup` — الـ JOIN (الأقوى)

```js
// جيب تفاصيل الـ User مع كل Order (زي JOIN)
{
  $lookup: {
    from: 'users',         // اسم الـ Collection التانية
    localField: 'userId',  // الـ Field في الـ Current Collection
    foreignField: '_id',   // الـ Field في الـ Foreign Collection
    as: 'userDetails'      // اسم الـ Field الجديدة في النتيجة
  }
}
```

---

## 💪 مثال حقيقي من مشروع: إجمالي المبيعات لكل Category

```js
// models/Order.js
const orderSchema = new mongoose.Schema({
  userId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  product:  { type: String },
  category: { type: String },
  price:    { type: Number },
  status:   { type: String, enum: ['pending', 'paid', 'cancelled'] },
  createdAt:{ type: Date, default: Date.now }
});

// controllers/statsController.js
const getSalesByCategory = async (req, res) => {
  const stats = await Order.aggregate([
    // Stage 1: خد بس الـ Orders المدفوعة
    {
      $match: { status: 'paid' }
    },

    // Stage 2: جمّع حسب الـ category واحسب الإحصائيات
    {
      $group: {
        _id: '$category',
        totalRevenue: { $sum: '$price' },
        orderCount:   { $sum: 1 },
        avgOrderValue:{ $avg: '$price' }
      }
    },

    // Stage 3: رتّب تنازلي حسب الإيراد
    {
      $sort: { totalRevenue: -1 }
    },

    // Stage 4: أضف اسم واضح بدل _id
    {
      $project: {
        _id: 0,
        category:      '$_id',
        totalRevenue:  { $round: ['$totalRevenue', 2] },
        orderCount:    1,
        avgOrderValue: { $round: ['$avgOrderValue', 2] }
      }
    }
  ]);

  res.json({ status: 'success', data: stats });
};
```

**النتيجة:**
```json
[
  { "category": "Electronics", "totalRevenue": 15420.50, "orderCount": 87, "avgOrderValue": 177.24 },
  { "category": "Books",       "totalRevenue": 3200.00,  "orderCount": 210, "avgOrderValue": 15.24 },
  { "category": "Clothing",    "totalRevenue": 2100.75,  "orderCount": 95, "avgOrderValue": 22.11 }
]
```

---

## 🔗 `$lookup` مثال — جيب الـ Orders مع بيانات الـ User

```js
const getOrdersWithUsers = async () => {
  return await Order.aggregate([
    // Stage 1: فلتر
    { $match: { status: 'paid' } },

    // Stage 2: JOIN مع الـ users Collection
    {
      $lookup: {
        from:         'users',      // اسم الـ Collection في MongoDB (Plural, Lowercase)
        localField:   'userId',     // Field في الـ orders
        foreignField: '_id',        // Field في الـ users
        as:           'user'        // هيحط النتيجة هنا كـ Array
      }
    },

    // Stage 3: الـ $lookup بيرجع Array دايماً — هنحولها لـ Object
    {
      $unwind: '$user'   // يفرد الـ Array لعناصر منفصلة
    },

    // Stage 4: اختار الـ Fields اللي محتاجها بس
    {
      $project: {
        product:  1,
        price:    1,
        'user.name':  1,
        'user.email': 1
      }
    }
  ]);
};
```

> [!abstract] 🧠 المفهوم المعماري — Aggregation vs find() تحت الكبوت
>
> **`find()`:** بيجيب Documents كما هي من الـ Collection — مفيش تحويل.
>
> **`aggregate()`:** بيشغّل الـ Data خلال Pipeline من الـ Stages. كل Stage بتاخد الـ Output من اللي قبلها. ده بيتعمل **داخل MongoDB نفسه** — يعني الـ Processing بيتعمل على السيرفر مش في Node.js.
>
> ده **أسرع بكتير** من إنك تجيب كل البيانات بـ `find()` وتعمل الحسابات في JavaScript.
>
> **الـ Order الصح للـ Stages للـ Performance:**
> 1. `$match` أول حاجة → قلّل الـ Documents بكير
> 2. `$sort` قبل `$limit`
> 3. `$lookup` بعد `$match` → الـ JOIN بيبقى على Documents أقل
>
> | Stage | المعادل في SQL |
> |---|---|
> | `$match` | `WHERE` |
> | `$group` | `GROUP BY` |
> | `$sort` | `ORDER BY` |
> | `$limit` | `LIMIT` |
> | `$project` | `SELECT` |
> | `$lookup` | `JOIN` |
> | `$unwind` | مش موجود — خاص بـ Arrays |

---

> [!question] 🎯 سؤال انترفيو مشهور — Aggregation
>
> **Q1 (Junior): إيه هو الـ Aggregation Pipeline وإيه الفرق بينه وبين `find()`؟**
> **A:** الـ Aggregation Pipeline هو سلسلة من الـ Stages كل واحدة بتحوّل الـ Data. `find()` بيجيب Documents كما هي. Aggregation بيتيح عمل Grouping, Calculations, Joins، وتحويل شكل الـ Data كلياً. الـ Processing بيحصل داخل MongoDB نفسه فده أسرع.
>
> **Q2 (Junior): إيه الفرق بين `$match` و `$group`؟**
> **A:** `$match` بيفلتر Documents — زي الـ WHERE في SQL. `$group` بيجمع Documents مع بعض حسب Field معينة وبيعمل Aggregation Functions زي `$sum`, `$avg`, `$count`.
>
> **Q3 (Mid): إيه هو `$unwind` ولماذا محتاجينه مع `$lookup`؟**
> **A:** الـ `$lookup` دايماً بيرجع الـ matched documents كـ Array — حتى لو كان Element واحد بس. الـ `$unwind` بيفرد الـ Array دي لـ Documents منفصلة عشان تعرف تتعامل مع الـ Fields بتاعتها مباشرةً.
>
> **Q4 (Mid): ليه مهم تحط `$match` في أول الـ Pipeline؟**
> **A:** لأن `$match` بيقلل عدد الـ Documents اللي هتعدي على باقي الـ Stages. لو حطيته بعد `$lookup` مثلاً، الـ JOIN هيتعمل على كل البيانات الأول وبعدين تتفلتر — ده أبطأ بكتير. حط `$match` أول حاجة عشان تقلل الـ Load على الـ Stages التانية.

---

> [!example] 🏗️ سؤال في مناقشة المشروع
>
> **الدكتور:** "هل استخدمتوا أي شيء أكثر من find() في MongoDB؟"
>
> **الإجابة:**
> "آه، استخدمنا الـ Aggregation Pipeline في [اذكر حالة من مشروعك — مثلاً: عرض إحصائيات للـ Dashboard].
>
> مثلاً: عندنا Endpoint بيرجع إجمالي الـ [Orders/Posts/Products] لكل [Category/User/Month]. استخدمنا `$match` الأول عشان نفلتر [الـ Paid Orders / Active Items]، وبعدين `$group` عشان نجمع حسب [الـ Category] ونحسب الـ Sum والـ Count. بعدين `$sort` عشان نرتب النتيجة.
>
> ده أحسن من إننا نجيب كل الـ Documents بـ `find()` ونعمل الحسابات في JavaScript — لأن الـ Processing بيتعمل داخل MongoDB نفسه وبيوصلنا النتيجة النهائية فقط."

---

---

# 6.3 🔬 Advanced Populate — ما وراء الأساسيات

## الحكاية: الـ Populate مش بس `.populate('field')`

الـ Populate الأساسي اتعلمناه. لكن في الـ Production، الدكاترة والـ Senior Devs بيسألوا عن الـ Nuances.

---

## 🎯 Field Selection في الـ Populate

```js
// ❌ بدون Field Selection — بتجيب كل بيانات الـ User
const post = await Post.findById(id).populate('author');
// post.author → { _id, name, email, password, age, role, createdAt, ... }
// بتجيب الـ password field! ده Security Risk خطير

// ✅ مع Field Selection — بس اللي محتاجه
const post = await Post.findById(id).populate('author', 'name email');
// post.author → { _id, name, email }
// الـ _id بييجي تلقائياً دايماً

// ✅ لو مش عايز حتى الـ _id
const post = await Post.findById(id).populate('author', 'name email -_id');
// post.author → { name, email }

// ✅ الصيغة الـ Object (أوضح وأقوى)
const post = await Post.findById(id).populate({
  path: 'author',
  select: 'name email -_id',
  match: { isActive: true }  // فلتر إضافي على الـ populated Documents
});
```

> [!abstract] 🧠 المفهوم المعماري — ليه Field Selection مهم جداً؟
>
> من غير Field Selection في الـ Populate:
>
> 1. **Security:** الـ `password` (حتى لو Hashed) بتيجي في كل Response — ده غلط
> 2. **Performance:** بتنقل Data زيادة من MongoDB لـ Node.js عبر الـ Network
> 3. **Bandwidth:** الـ API Response بيبقى أكبر من اللازم
>
> الـ Rule: **Populate بس اللي Angular محتاجه فعلاً**.

---

## 🪆 Nested Populate — Populate داخل Populate

```js
// السيناريو: Post له Author (User) والـ User ده له Role Object
const postSchema = new mongoose.Schema({
  title:  String,
  author: { type: ObjectId, ref: 'User' }
});

const userSchema = new mongoose.Schema({
  name: String,
  role: { type: ObjectId, ref: 'Role' }  // User له Reference لـ Role
});

// جيب الـ Post مع الـ Author ومع الـ Role بتاع الـ Author
const post = await Post.findById(id).populate({
  path: 'author',
  select: 'name email',
  populate: {              // ← Nested populate!
    path: 'role',
    select: 'name permissions'
  }
});

// النتيجة:
// post.author.name → 'Ahmed'
// post.author.role.name → 'admin'
// post.author.role.permissions → ['read', 'write', 'delete']
```

---

## 🔥 Populate مع Array of References

```js
// Post له Array من الـ Comments
const postSchema = new mongoose.Schema({
  title:    String,
  comments: [{ type: ObjectId, ref: 'Comment' }]
});

// جيب الـ Post مع كل الـ Comments ومع الـ Author لكل Comment
const post = await Post.findById(id).populate({
  path: 'comments',
  populate: {
    path: 'author',
    select: 'name'
  }
});

// post.comments → Array من الـ Comment Objects
// كل comment.author → { name: '...' }
```

---

## ⚡ Populate vs Aggregation $lookup — امتى تستخدم إيه؟

```js
// Populate: Application-level — Mongoose بيعمل قريز تانية
const posts = await Post.find().populate('author', 'name');
// → Query 1: db.posts.find()
// → Query 2: db.users.find({ _id: { $in: [...] } })
// مناسب لما: عايز Code أبسط وحجم البيانات معقول

// $lookup: Database-level — بيتعمل داخل MongoDB
const posts = await Post.aggregate([
  { $lookup: { from: 'users', localField: 'author', foreignField: '_id', as: 'author' } },
  { $unwind: '$author' }
]);
// → Query واحدة بس — أسرع مع Data ضخمة
// مناسب لما: محتاج Performance وعايز تعمل حسابات في نفس الوقت
```

> [!abstract] 🧠 المفهوم المعماري — Populate vs $lookup
>
> | المعيار | Populate | $lookup |
> |---|---|---|
> | **أين يتعمل؟** | Application (Node.js) | Database (MongoDB) |
> | **عدد الـ Queries** | 2 Queries | Query واحدة |
> | **السهولة** | ✅ أسهل كود | ❌ أعقد |
> | **الـ Performance** | كويس للـ Data المعقولة | ✅ أحسن مع Data ضخمة |
> | **التحكم** | Mongoose Features (match, select) | Pipeline كاملة |
> | **Nested Relations** | populate داخل populate | عدة $lookup |
>
> **الـ Rule العملي:** استخدم `populate` في الـ CRUD العادي. استخدم `$lookup` لما محتاج Aggregation + Join في نفس الوقت.

---

> [!question] 🎯 سؤال انترفيو مشهور — Advanced Populate
>
> **Q1 (Junior): إزاي تحدد إنك تجيب Fields معينة بس من الـ Populate؟**
> **A:** بتحط الـ Fields كـ String تاني في `.populate('field', 'name email')` أو بتستخدم الـ Object form: `.populate({ path: 'field', select: 'name email' })`. الـ `-fieldName` بيشيل الـ Field من النتيجة.
>
> **Q2 (Mid): إيه هو الـ Nested Populate وامتى تحتاجه؟**
> **A:** الـ Nested Populate بيتيح إنك تـ Populate داخل الـ Populated Document. مثلاً Post له Author، والـ Author له Role — بتعمل populate على الـ author وجواه populate تاني على الـ role. بتعمله بالـ Object form وبتحط `populate` property جوا الـ populate الخارجي.
>
> **Q3 (Mid): إيه الفرق بين Populate و `$lookup` في الـ Aggregation؟**
> **A:** Populate بيعمل Query تانية منفصلة في Node.js. الـ `$lookup` بيعمل الـ Join داخل MongoDB في Query واحدة. الـ `$lookup` أسرع مع Data ضخمة لكن Populate أبسط في الكود ومفيد للـ CRUD العادي.
>
> **Q4 (Mid): هل ممكن يحصل Security Issue لو ما حطيناش Field Selection في الـ Populate؟**
> **A:** آه! لو عندك User Schema فيه password field (حتى Hashed)، من غير Field Selection الـ Populate هيجيب الـ Hashed Password في الـ Response. المفروض دايماً تحدد إيه الـ Fields اللي محتاجها — مثلاً `'name email -_id'` — وتـ Exclude أي sensitive data زي الـ password أو الـ token.

---

> [!example] 🏗️ سؤال في مناقشة المشروع
>
> **الدكتور:** "في الـ API بتاعتكم، لما بترجعوا Post فيه Author، بترجعوا كل بيانات الـ Author؟"
>
> **الإجابة:**
> "لأ، بنستخدم Field Selection في الـ Populate. بنكتب `.populate('author', 'name email -_id')` عشان نرجع بس الاسم والـ Email ومش نرجع الـ Hashed Password أو باقي البيانات الحساسة. ده بيضمن Security وبيقلل حجم الـ Response.
>
> لو الـ API محتاجة معلومات Role الـ Author كمان، بنعمل Nested Populate — بنحط `populate` property جوا الـ populate الأول عشان نجيب الـ Role Object كمان."

---

---

# 6.4 🛡️ Validation & Error Handling — الدروع والسيوف

## الحكاية: الـ Validation مش طبقة واحدة

في مشروع Production، الـ Validation بتيجي من طبقتين:

```
Layer 1: Express/Controller Level  → بتتحقق من الـ Request Format
Layer 2: Mongoose Schema Level     → بتتحقق قبل الحفظ في DB
Layer 3: MongoDB Level             → الـ Unique Index
```

---

## 🏗️ Mongoose Schema Validation الكاملة

```js
const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'اسم المنتج مطلوب'],
    trim: true,
    minlength: [3, 'الاسم لازم يكون على الأقل 3 حروف'],
    maxlength: [100, 'الاسم لازم يكون أقل من 100 حرف']
  },

  price: {
    type: Number,
    required: [true, 'السعر مطلوب'],
    min: [0, 'السعر مش ممكن يكون سالب'],
    max: [1000000, 'السعر مش منطقي']
  },

  category: {
    type: String,
    required: true,
    enum: {
      values: ['electronics', 'books', 'clothing', 'food'],
      message: '{VALUE} مش Category معروفة'  // {VALUE} = الـ Input الغلط
    }
  },

  email: {
    type: String,
    validate: {
      validator: function(val) {
        // Custom Validator
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val);
      },
      message: 'الـ Email مش بصيغة صحيحة'
    }
  },

  slug: {
    type: String,
    unique: true  // MongoDB Index — مش Mongoose Validation
  }
});
```

> [!abstract] 🧠 المفهوم المعماري — `required` vs `unique` تحت الكبوت
>
> **`required: true`:**
> - بيشتغل على مستوى **Mongoose** في الـ Application
> - بيتشيك قبل ما أي Query توصل MongoDB
> - لو فشل: بيرمي `ValidationError` من Mongoose
>
> **`unique: true`:**
> - مش Mongoose Validator — ده بيقول لـ MongoDB تعمل **Unique Index**
> - الـ Check بيحصل على مستوى **MongoDB** نفسها
> - لو فشل: MongoDB بترمي Error بـ `code: 11000` (Duplicate Key Error)
> - الـ Error دي مش `ValidationError` — دي MongoDB Error!
>
> **الفرق العملي:** `required` بيتحقق قبل ما الـ Query تبعت. `unique` بيتحقق وقت الحفظ الفعلي في MongoDB.

---

## 🚨 الـ 11000 Error — الكارثة الشهيرة

```js
// لما حد يحاول يعمل User بـ Email موجود أصلاً:
// MongoDB Error: E11000 duplicate key error collection: users index: email_1

// ❌ من غير Error Handling — الـ Server هيرجع 500 Internal Server Error مش معبّر
const createUser = async (req, res) => {
  const user = await User.create(req.body); // ← ممكن يرمي MongoServerError
  res.status(201).json(user);
};

// ✅ مع Error Handling صح
const createUser = async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json({ status: 'success', data: user });
  } catch (err) {
    // الـ Duplicate Key Error بيجي بـ code 11000
    if (err.code === 11000) {
      // err.keyValue → { email: 'ahmed@test.com' }
      const field = Object.keys(err.keyValue)[0];
      const value = err.keyValue[field];
      return res.status(409).json({
        status: 'fail',
        message: `الـ ${field} "${value}" موجود بالفعل. حاول تستخدم قيمة تانية.`
      });
    }

    // الـ Mongoose Validation Errors
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({
        status: 'fail',
        message: messages.join('. ')
      });
    }

    // باقي الـ Errors
    next(err);
  }
};
```

---

## 🎯 الـ Global Error Handler — الطريقة الاحترافية

```js
// utils/AppError.js — Custom Error Class
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = statusCode >= 400 && statusCode < 500 ? 'fail' : 'error';
    this.isOperational = true;  // ده Error متوقع وتحت السيطرة

    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;

// middleware/errorHandler.js — الـ Global Handler
const handleDuplicateKeyError = (err) => {
  const field = Object.keys(err.keyValue)[0];
  const value = err.keyValue[field];
  return new AppError(`قيمة الـ ${field} "${value}" مكررة`, 409);
};

const handleValidationError = (err) => {
  const messages = Object.values(err.errors).map(e => e.message);
  return new AppError(messages.join('. '), 400);
};

const handleCastError = (err) => {
  // لو حد بعت ID مش صالح زي "abc" بدل ObjectId
  return new AppError(`الـ ${err.path}: "${err.value}" مش ID صحيح`, 400);
};

const globalErrorHandler = (err, req, res, next) => {
  let error = { ...err, message: err.message };

  // حوّل الـ MongoDB Errors لـ Operational Errors مفهومة
  if (err.code === 11000)            error = handleDuplicateKeyError(err);
  if (err.name === 'ValidationError') error = handleValidationError(err);
  if (err.name === 'CastError')      error = handleCastError(err);

  res.status(error.statusCode || 500).json({
    status:  error.status  || 'error',
    message: error.message || 'حصل حاجة غلط على السيرفر'
  });
};

// app.js — آخر حاجة قبل app.listen
app.use(globalErrorHandler);
```

> [!abstract] 🧠 المفهوم المعماري — أنواع الـ Mongoose/MongoDB Errors
>
> | نوع الـ Error | `err.name` | السبب |
> |---|---|---|
> | Validation Failed | `ValidationError` | Field Required مش موجودة أو Data مش بالشروط |
> | Duplicate Key | `MongoServerError` + `code: 11000` | Value موجودة في Unique Index |
> | Invalid ID | `CastError` | بعتوا ID مش بصيغة ObjectId |
> | Connection Lost | `MongoNetworkError` | السيرفر مش متوصل بـ MongoDB |
>
> **الـ CastError:** لو Route بتاعك `GET /users/:id` والـ User بعت `/users/abc` بدل ObjectId صح — Mongoose بيحاول يحوّل "abc" لـ ObjectId ومش بيقدر → بيرمي CastError. لازم تـ Handle ده وترجع 400 مش 500.

---

## 🔒 ملاحظة مهمة: `unique` مش Validator

```js
// ⚠️ ده لأ — unique مش Mongoose Validator
userSchema.path('email').validate(async function(email) {
  // لو عملت Custom Validator زي ده للـ Unique Check — ده Race Condition خطير!
  // لأن اتنين Requests ممكن يوصلوا في نفس الوقت ويعدوا الـ Check مع بعض
  const count = await User.countDocuments({ email });
  return count === 0;
}, 'Email موجود');

// ✅ الصح: خلي MongoDB Unique Index يعمل شغله
// وـ Handle الـ 11000 Error في الـ Controller
```

---

> [!question] 🎯 سؤال انترفيو مشهور — Validation & Error Handling
>
> **Q1 (Junior): إيه هو الـ Error Code 11000 في MongoDB وإيه سببه؟**
> **A:** الـ 11000 هو `Duplicate Key Error`. بيحصل لما حد بيحاول يحفظ Document بقيمة موجودة بالفعل في Field عندها `unique: true` Index. الـ Error بييجي من MongoDB نفسها مش من Mongoose.
>
> **Q2 (Junior): إيه الفرق بين `ValidationError` و `MongoServerError code 11000`؟**
> **A:** `ValidationError` بتييجي من Mongoose لما الـ Data مش بتطابق الـ Schema Rules زي `required` أو `minlength`. الـ `11000` بييجي من MongoDB لما بتحاول تحفظ Duplicate Value في Unique Index. الاتنين غلط لكن بيجوا من طبقات مختلفة.
>
> **Q3 (Mid): إيه هو الـ CastError في Mongoose وإزاي بتـ Handle ده؟**
> **A:** الـ CastError بيحصل لما Mongoose بيحاول يحوّل قيمة من نوع لنوع تاني وما بيقدرش — أشهر مثال: Route بياخد `:id` والـ User بعت String عادي بدل ObjectId صحيح. بنـ Handle بتـ Catch الـ `CastError` في الـ Global Error Handler ونرجع 400 مع رسالة واضحة.
>
> **Q4 (Mid): ليه مش مناسب تعمل Custom Validator للـ Unique Check بدل `unique: true`؟**
> **A:** لأن ده هيعمل Race Condition. لو اتنين Requests وصلوا في نفس الوقت، كل واحد هيعمل `countDocuments` ويلاقي 0، وكل واحد هيعتقد إن الـ Email مش موجود وهيكمل الحفظ — النتيجة: Duplicates في الـ DB. الـ MongoDB Unique Index عنده Atomic Guarantee — بيضمن إن واحد بس يعدي والتاني يتـ Reject.

---

> [!example] 🏗️ سؤال في مناقشة المشروع
>
> **الدكتور:** "لو User حاول يـ Register بـ Email موجود، إيه اللي بيحصل في مشروعكم؟"
>
> **الإجابة الكاملة:**
> "الـ Email Field عنده `unique: true` في الـ Schema — ده بيعمل MongoDB Unique Index. لما حد بيحاول يـ Register بـ Email موجود:
>
> 1. الـ Request بييجي للـ Controller وبيعمل `User.create(data)`
> 2. Mongoose بيبعت الـ Document لـ MongoDB
> 3. MongoDB بتلاقي إن الـ Email موجود في الـ Unique Index
> 4. بترمي Error بـ `code: 11000` و `keyValue: { email: '...' }`
> 5. الـ Error بيتصاعد لـ Global Error Handler بتاعنا
> 6. بنـ Check `err.code === 11000`، بنجيب اسم الـ Field المكرر من `err.keyValue`، وبنرجع **409 Conflict** مع رسالة واضحة زي 'الـ Email ده موجود بالفعل'
>
> من غير الـ Error Handler ده، كنا هنرجع 500 Internal Server Error مش معبّر ومش مفيد للـ User."

---

---

# 🚨 زتونة Module 6 — المراجعة السريعة

```
✅ pre('save')     → Hook قبل الحفظ — استخدم Regular Function مش Arrow Function
✅ this.isModified → تأكد إن الـ Field اتغيرت فعلاً قبل تعمل Hash أو حاجة
✅ next()          → لازم تناديها في كل Middleware وإلا الـ Request هيتعلق
✅ Aggregation     → Pipeline من Stages — $match → $group → $sort → $project
✅ $match أول      → قلل الـ Data الأول عشان الـ Pipeline تبقى أسرع
✅ $lookup         → JOIN في MongoDB — بيرجع Array فلازم $unwind
✅ populate select → دايماً حدد الـ Fields عشان ما ترجعش sensitive data
✅ Nested populate → populate داخل populate بالـ Object form
✅ 11000           → Duplicate Key Error — رجّع 409 مع رسالة واضحة
✅ ValidationError → Mongoose Schema Error — رجّع 400
✅ CastError       → ID غلط — رجّع 400
✅ unique ≠ Validator → unique بيعمل DB Index مش Mongoose Validation
```

---

> [!abstract] 🧠 النصيحة الذهبية للدفاع
>
> لو الدكتور بدأ يضغط وحسيت إنك مش متأكد، قول الجملة دي:
>
> **"استخدمنا [الـ Concept ده] عشان [سبب تقني واحد واضح]، وعارفين إن الـ Trade-off بتاعه إنه [عيب واحد]. في مشروعنا ده كان مناسب لأن [سبب من المشروع]."**
>
> الدكتور مش بيدور على حفظ — بيدور على إنك **فاهم ليه** اتخذت القرار ده.
>
> **ربنا يوفقكم** 🤲💪 — إنتوا جهزتوا أكتر من اللي المشروع محتاجه!

---

*🏁 نهاية Module 6 — The Missing Heavyweights*
*Linked to: MongoDB_Mongoose_Vault.md*
