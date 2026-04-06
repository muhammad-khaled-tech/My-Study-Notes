# 🍃 MongoDB & Mongoose — Module 5
# 🎯 Interview Gauntlet Vault — كل سؤال ممكن يتسألك فيه

> **تعليمات الاستخدام:** الأسئلة مرتبة من **Junior → Mid → Senior → Staff-level**. الـ interviewer الذكي بيبدأ بـ Junior ولو إجابتك ممتازة بيزق لـ Senior. الهدف مش تحفظ الإجابات — الهدف تفهم الـ reasoning وتقدر تشرحه بكلامك.

---

## 🟢 Level 1 — Junior Questions: الأساسيات اللي لو غلطت فيها الإنترفيو خلص

---

### ❓ س1: إيه هو MongoDB وإيه الفرق بينه وبين الـ SQL databases؟

> **الإجابة المتوقعة من Junior:**

MongoDB هو NoSQL document database — يعني بيخزن البيانات كـ **BSON documents** (زي JSON objects) في **collections** بدل ما يخزنها في rows وcolumns في جداول.

الفروق الجوهرية:

| | MongoDB | SQL (PostgreSQL/MySQL) |
|---|---|---|
| هيكل البيانات | Documents (BSON) | Rows في Tables |
| الـ Schema | مرن — في الكود | ثابت — في الـ DB |
| العلاقات | Embedding أو References | Foreign Keys وJOINs |
| الـ Scaling | Horizontal (sharding) سهل | Vertical أسهل |
| الـ Transactions | من v4+ | Full ACID من الأول |

> 💡 **نصيحة الإنترفيو:** لو قالك "أحسن إيه فيهم؟" — الإجابة الصح هي "بيتحدد على حسب الـ use case." الـ interviewer بيدور على شخص يعرف يفكر مش يحفظ.

---

### ❓ س2: إيه هو BSON وإيه علاقته بالـ JSON؟

> **الإجابة:**

الـ JSON هو text format — الإنسان بيقراه بسهولة. الـ BSON هو **Binary JSON** — اللي MongoDB بتستخدمه فعلاً لما بتخزن أو بتبعت البيانات على الـ network.

**ليه BSON؟**
- الـ Binary أسرع في الـ parsing من الـ Text
- بيدعم data types مش موجودة في JSON:

```
JSON يعرف:  String, Number, Boolean, Array, Object, null
BSON يزيد:  Date (حقيقي مش string), ObjectId, Int32/Int64,
            Decimal128, Binary, Regex, Timestamp
```

الـ Developer بيكتب JSON عادي — الـ MongoDB Driver بيعمل الـ conversion تلقائياً. إنت مش بتشوف الـ BSON أبداً.

---

### ❓ س3: إيه هو الـ `_id` في MongoDB وإزاي بيتعمل؟

> **الإجابة:**

كل document في MongoDB لازم يبقى ليه `_id` — ده الـ primary key. لو ماحددتوش، MongoDB بتعمله تلقائياً كـ **ObjectId**.

الـ ObjectId ده **12 bytes** مركّب من:

```
[ 4 bytes Timestamp ] [ 5 bytes Random (Machine + Process) ] [ 3 bytes Counter ]
  ↑                     ↑                                       ↑
  وقت الإنشاء          ضمان uniqueness cross-machine           يمنع collision
  بالثواني              حتى في distributed systems              في نفس الثانية
```

**الفوايد:**
- فريد عالمياً — حتى لو عندك 1000 server
- ممكن تعرف وقت إنشاء الـ document من الـ `_id` نفسه

```javascript
const id = new mongoose.Types.ObjectId('64f8a2b3c1d2e3f4a5b6c7d8');
console.log(id.getTimestamp()); // ← ISODate("2024-09-06T...")
```

---

### ❓ س4: إيه الفرق بين `find()` و`findOne()` و`findById()`؟

> **الإجابة:**

```javascript
// find() — بيرجع Array دايماً (حتى لو نتيجة واحدة أو مفيش نتائج)
const products = await Product.find({ category: 'electronics' });
// → [] لو مفيش، أو [doc1, doc2, ...]

// findOne() — بيرجع Document واحد أو null
const product = await Product.findOne({ name: 'iPhone' });
// → null لو مش موجود، أو { _id: ..., name: 'iPhone', ... }

// findById() — shorthand لـ findOne({ _id: id })
const product = await Product.findById('64f8a2b3c1d2e3f4a5b6c7d8');
// لو الـ id format غلط → CastError
// لو مش موجود → null
```

> 💡 لاحظ إن `findById()` لو الـ ID format مش ObjectId صح بيـ throw **CastError** — لازم تتعامل معاه في الـ error handler.

---

### ❓ س5: إيه هو الـ Mongoose Schema وإيه اللي بيعمله؟

> **الإجابة:**

الـ MongoDB نفسها schemaless — تقدر تحط أي document بأي شكل في أي collection. الـ **Mongoose Schema** بياخد الـ validation responsibility ده ويحطه في الـ application layer.

الـ Schema بيعمل:
1. يحدد شكل الـ document (الـ fields وأنواعها)
2. يعمل validation rules (required, min, max, enum, custom)
3. يحدد default values
4. بيعرّف indexes
5. بيسمح بتعريف middleware hooks وvirtual fields

```javascript
const productSchema = new mongoose.Schema({
  name:  { type: String, required: true, trim: true },
  price: { type: Number, required: true, min: 0 },
  category: { type: String, enum: ['electronics', 'clothing'] },
  inStock: { type: Boolean, default: true },
}, { timestamps: true }); // ← بيضيف createdAt وupdatedAt تلقائياً
```

---

### ❓ س6: إيه الفرق بين Schema والـ Model في Mongoose؟

> **الإجابة:**

```
Schema  = الـ Blueprint   → بيقول "الـ document المفروض يبقى شكله إيه"
Model   = الـ Factory     → بيقول "الـ collection دي اسمها إيه وازاي نتعامل معاها"
Document = الـ Instance   → object حقيقي بيمثل record واحد في الـ DB
```

```javascript
// Schema: مجرد تعريف — مش بيتكلم مع الـ DB
const userSchema = new mongoose.Schema({ name: String, email: String });

// Model: ربط الـ schema بالـ DB — منه بنعمل الـ queries
const User = mongoose.model('User', userSchema);
// ↑ MongoDB هتعمل collection اسمها 'users' (جمع + lowercase)

// Document: instance بيمثل user واحد في الـ DB
const user = new User({ name: 'Ahmed', email: 'ahmed@test.com' });
await user.save(); // ← دلوقتي بيتخزن في الـ DB
```

---

### ❓ س7: إيه هو الـ Error Code 11000 في MongoDB وازاي بتتعامل معاه؟

> **الإجابة:**

الـ `11000` هو **DuplicateKeyError** — بيحصل لما بتحاول تخزن document بقيمة في field معمول عليه `unique: true` موجودة بالفعل في الـ collection.

```javascript
// في الـ Error Handler
if (err.code === 11000) {
  const field = Object.keys(err.keyValue)[0]; // ← اسم الـ field المكرر
  const value = err.keyValue[field];           // ← القيمة المكررة
  return res.status(409).json({
    message: `الـ ${field} "${value}" موجود بالفعل`,
  });
}
```

لو ماعملتيش الـ handling ده، الـ error الـ raw هييجي للـ client كـ 500 error وده unprofessional وبيكشف معلومات عن الـ database structure.

---

### ❓ س8: إيه هو الـ `.lean()` وامتى بتستخدمه؟

> **الإجابة:**

لما بتعمل `find()` عادي، Mongoose بيرجع **Mongoose Document instances** — objects ثقيلة فيها كل الـ methods زي `.save()`, `.toObject()`, وكامل الـ prototype chain.

`.lean()` بيرجع **plain JavaScript objects** بدل كده — أخف وأسرع (ممكن 5-10x في الـ read operations).

```javascript
// ❌ بطيء — Mongoose Document كامل مع كل الـ methods
const products = await Product.find({ isActive: true });

// ✅ أسرع — plain JS object
const products = await Product.find({ isActive: true }).lean();
```

**الـ Trade-off:** مش تقدر تعمل `.save()` على الـ result بعد `.lean()`.

**القاعدة:** استخدم `.lean()` في كل GET request مش هتعدّل بعدها. امنعه في أي حاجة هتعمل فيها update.

---

### ❓ س9: إيه الفرق بين `deleteOne()` و`findByIdAndDelete()`؟

> **الإجابة:**

```javascript
// deleteOne() — بيحذف بس، مش بيرجع الـ document المحذوف
// بيشغّل pre('deleteOne') hook مش pre('findOneAndDelete')
await Product.deleteOne({ _id: id });
// → { acknowledged: true, deletedCount: 1 }

// findByIdAndDelete() — بيرجع الـ document المحذوف
// بيشغّل pre('findOneAndDelete') hook
const deleted = await Product.findByIdAndDelete(id);
// → الـ product document قبل الحذف، أو null لو مش موجود
```

**امتى كل واحد؟**
- `findByIdAndDelete()` لو محتاج الـ document المحذوف عشان تعمل cascade operations (زي حذف الـ reviews بتاعته)
- `deleteOne()` لو مش محتاج الـ document — أسرع لأنه مش بيـ fetch الـ document قبل الحذف

---

### ❓ س10: إيه هو الـ `$set` في MongoDB وليه مهم؟

> **الإجابة:**

ده من أخطر الـ pitfalls في MongoDB.

```javascript
// ❌ الغلط الشائع — بدون $set
await Product.updateOne({ _id: id }, { price: 50000 });
// النتيجة: الـ document بيتبدّل كله بـ { price: 50000 }
// name, category, stock, كل حاجة اتمسحت! 😱

// ✅ الصح — مع $set
await Product.updateOne({ _id: id }, { $set: { price: 50000 } });
// النتيجة: بس الـ price اتغير، باقي الـ fields بالحالها
```

`$set` بيقول لـ MongoDB "عدّل الـ fields دي بس وسيب الباقي." دايماً استخدمه في الـ updates إلا لو قصدك تبدّل الـ document كله (replace).

---

## 🟡 Level 2 — Mid-Level Questions: اللي بيفرق Junior عن Mid

---

### ❓ س11: إيه الفرق بين `save()` و`findByIdAndUpdate()`؟ وامتى تستخدم كل واحد؟

> **الإجابة:**

```
save()                              findByIdAndUpdate()
──────                              ───────────────────
2 DB round-trips (READ then WRITE)  1 DB round-trip
بيشغّل كل الـ Middleware            مش بيشغّل middleware by default
بيشغّل كل الـ Validators           مش بيشغّل validators بدون runValidators: true
محتاج تجيب الـ document الأول      بيعمل find + update في operation واحدة
```

```javascript
// save() — أبطأ لكن complete
const product = await Product.findById(id); // ← query 1: READ
product.price = 50000;
await product.save();                        // ← query 2: WRITE + middleware + validation

// findByIdAndUpdate() — أسرع لكن بدون middleware
const product = await Product.findByIdAndUpdate(
  id,
  { $set: { price: 50000 } },
  { new: true, runValidators: true }  // ← لازم تضيف runValidators يدوياً!
);
```

**القاعدة:** استخدم `save()` لما عندك pre-save middleware مهم (زي password hashing). استخدم `findByIdAndUpdate()` في باقي الـ cases لأنه أسرع.

---

### ❓ س12: إيه الـ `runValidators: true` وليه الـ Juniors بينسوه؟

> **الإجابة:**

في Mongoose، الـ Schema validation بتشتغل تلقائياً في `save()`. لكن في الـ update operations (`findByIdAndUpdate`, `updateOne`, etc.) الـ validation **مش بتشتغل** by default — لأن الـ Mongoose أصلاً مش بيعرف الـ document الكامل (بيعرف بس الـ fields اللي بتعدلها).

```javascript
// ❌ بدون runValidators — ممكن يتخزن price سالب
await Product.findByIdAndUpdate(id, { $set: { price: -1000 } });
// مش هيـ throw error حتى لو في schema: min: 0 !

// ✅ مع runValidators
await Product.findByIdAndUpdate(
  id,
  { $set: { price: -1000 } },
  { runValidators: true }  // ← دلوقتي هيـ throw ValidationError
);
```

> ⚠️ **انتبه:** `runValidators` بيشغّل الـ validators على الـ fields المتغيرة بس، مش على الـ document كله. Custom validators اللي بتستخدم `this` مش هتشتغل صح مع updates.

---

### ❓ س13: إيه الفرق بين `populate()` والـ `$lookup`؟ وامتى تستخدم كل واحد؟

> **الإجابة:**

```
populate()                          $lookup (Aggregation)
──────────                          ─────────────────────
Application-layer join              Database-layer join
2+ queries (n+1 pattern)            1 query في الـ MongoDB
أبسط في الكتابة                    أعقد في الكتابة
مناسب للـ simple CRUD              مناسب للـ analytics وcomplex queries
مش بيستخدم indexes على الـ join    بيستفيد من indexes على الـ join field
```

```javascript
// populate() — سهل بس أبطأ في large datasets
const product = await Product.findById(id).populate('seller', 'name email');
// → 2 queries: 1 للـ product، 1 لـ user

// $lookup — أسرع وأقوى بس أطول في الكود
const product = await Product.aggregate([
  { $match: { _id: mongoose.Types.ObjectId(id) } },
  { $lookup: { from: 'users', localField: 'seller', foreignField: '_id', as: 'seller' } },
  { $unwind: '$seller' },
]);
// → 1 query في الـ DB نفسها
```

**القاعدة:** `populate()` في الـ simple CRUD. `$lookup` في الـ aggregation أو لما الـ performance مشكلة.

---

### ❓ س14: إيه هو الـ Virtual Populate وامتى بيبقى أفضل من الـ Regular Reference؟

> **الإجابة:**

في الـ Regular Reference، الـ parent بيشيل الـ ObjectId للـ children (زي Product بيشيل `seller: ObjectId`).

في الـ Virtual Populate، مفيش حاجة زيادة في الـ parent — الـ child هو اللي شايل reference للـ parent، والـ Mongoose بيعمل reverse lookup.

```javascript
// productSchema — مش محتاج تخزن reviews IDs في الـ Product
productSchema.virtual('reviews', {
  ref: 'Review',          // ← جيب من الـ Review collection
  localField: '_id',      // ← الـ field في الـ Product
  foreignField: 'product', // ← الـ field في الـ Review
  justOne: false,
});

// الاستخدام
const product = await Product.findById(id).populate('reviews');
// ← بيعمل query على الـ reviews collection بحثاً عن { product: product._id }
```

**متى هو أفضل؟** لما الـ children (reviews) بتكون كتير ومش دايماً محتاجهم. لو حطّيت الـ reviews IDs في الـ Product، الـ array ممكن يكبر لآلاف وتجيبه حتى لما مش محتاجه.

---

### ❓ س15: إيه الـ Soft Delete وليه بنستخدمه بدل الـ Hard Delete في Production؟

> **الإجابة:**

**Hard Delete:** بيمسح الـ document من الـ DB نهائياً.

**Soft Delete:** بتضيف field زي `isDeleted: true` وـ `deletedAt` وبتـ filter عليه في كل query.

```javascript
// Hard Delete ❌ في production (نادراً)
await Product.findByIdAndDelete(id);

// Soft Delete ✅
await Product.findByIdAndUpdate(id, {
  $set: { isDeleted: true, deletedAt: new Date() }
});

// في كل query بعدها
const products = await Product.find({ isDeleted: { $ne: true } });
```

**ليه Soft Delete في Production؟**
1. **Audit Trail:** تقدر ترجع تشوف "مين مسح إيه وامتى"
2. **Data Integrity:** لو عندك Orders قديمة بتـ reference الـ Product، مش هتكسر الـ reference
3. **Recovery:** لو مسحت بالغلط تقدر ترجعه
4. **Legal/Compliance:** بعض الأنظمة بتشترط إنك تحتفظ بالبيانات لفترة

---

### ❓ س16: إيه الـ Mongoose Middleware وإيه أنواعه؟

> **الإجابة:**

الـ Mongoose Middleware (أو Hooks) هو كود بيتشغّل تلقائياً **قبل أو بعد** operations معينة على الـ Schema.

**الأنواع:**

```javascript
// 1. Document Middleware — بيشتغل على Document instances
// Operations: save, validate, remove, updateOne, deleteOne
schema.pre('save', function(next) { /* this = Document */ });
schema.post('save', function(doc, next) { /* doc = saved document */ });

// 2. Query Middleware — بيشتغل على Query objects
// Operations: find, findOne, findOneAndUpdate, count, etc.
schema.pre('find', function() { /* this = Query */ });
schema.pre('findOneAndUpdate', function() { /* this = Query */ });

// 3. Aggregate Middleware
schema.pre('aggregate', function() { /* this = Aggregation object */ });

// 4. Model Middleware
schema.pre('insertMany', function(next, docs) { });
```

**أهم use cases:**
- `pre('save')` → password hashing، slug generation
- `post('save')` → send welcome email، update cache
- `post('findOneAndDelete')` → cascade delete related documents
- `pre('find')` → إضافة filter تلقائي زي `{ isDeleted: false }`

---

### ❓ س17: ليه لازم تستخدم Regular Function مش Arrow Function في الـ Mongoose Middleware؟

> **الإجابة:**

```javascript
// ❌ Arrow Function — this = undefined (أو global object)
userSchema.pre('save', async (next) => {
  console.log(this.name); // ← undefined! 😱
  // Arrow functions مش بيكون ليها this خاص بيها
  // بتـ inherit الـ this من الـ lexical scope (اللي هو module scope)
});

// ✅ Regular Function — this = Document instance
userSchema.pre('save', async function(next) {
  console.log(this.name); // ← 'Ahmed' ✅
  // Mongoose بيـ bind الـ this لـ Document عشانك
});
```

ده مش specific لـ Mongoose — ده طبيعة الـ JavaScript. الـ Arrow functions بيتـ "lexically bind" للـ `this` من الـ scope اللي اتعرفت فيه. الـ Regular functions بتاخد الـ `this` من الـ context اللي اتستدعت منه — وده بالظبط اللي Mongoose بيستغله.

---

### ❓ س18: إيه هو الـ `isModified()` في Mongoose وليه بنستخدمه في password hashing؟

> **الإجابة:**

الـ Mongoose بيعمل **dirty tracking** — بيتتبع الـ fields اللي اتغيرت في الـ current request على الـ Document. `isModified('fieldName')` بيرجع `true` لو الـ field اتغير.

```javascript
userSchema.pre('save', async function(next) {
  // لو user غيّر اسمه بس وعمل save
  // مش عايزين نعمل hash للـ password تاني — ده غير ضروري وبيستهلك CPU
  if (!this.isModified('password')) {
    return next(); // ← خلّي الـ save يكمل من غير hashing
  }
  
  // بس لو الـ password فعلاً اتغير — هنا نعمل hash
  this.password = await bcrypt.hash(this.password, 12);
  next();
});
```

بدون `isModified()` check، كل مرة user بيعمل أي update (حتى لو بيغيّر صورته بس)، الـ password هياخد وقت hash كامل — وده overhead غير ضروري وبيبطّي الـ app.

---

### ❓ س19: إيه الـ Pagination وإزاي بتعملها في MongoDB؟

> **الإجابة:**

في MongoDB، الـ pagination ببساطة: `skip()` + `limit()`

```javascript
const getProducts = async (page = 1, limit = 12) => {
  const skip = (page - 1) * limit;
  
  // ❌ طريقة بطيئة — 2 sequential queries
  const products = await Product.find().skip(skip).limit(limit).lean();
  const total = await Product.countDocuments();
  
  // ✅ طريقة أسرع — parallel
  const [products, total] = await Promise.all([
    Product.find().skip(skip).limit(limit).lean(),
    Product.countDocuments(),
  ]);
  
  return {
    data: products,
    pagination: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1,
    },
  };
};
```

> 💡 **Senior Note:** في collections ضخمة جداً (ملايين documents)، الـ `skip()` بيكون بطيء لأن MongoDB بتقرأ وتـ skip كل الـ documents. الحل هنا هو **Cursor-based Pagination**: بدل `page`, بتبعت آخر `_id` شوفته وبتعمل `find({ _id: { $gt: lastId } }).limit(n)`.

---

### ❓ س20: إيه الـ `$in` والـ `$nin` وامتى بتستخدمهم؟

> **الإجابة:**

```javascript
// $in — جيب documents اللي قيمة الـ field في الـ list دي
const products = await Product.find({
  category: { $in: ['electronics', 'books', 'clothing'] }
});
// → كل products اللي category بتاعتها إلكترونيات أو كتب أو ملابس

// $nin — جيب documents اللي قيمة الـ field مش في الـ list دي
const activeProducts = await Product.find({
  status: { $nin: ['deleted', 'archived', 'out_of_stock'] }
});

// استخدام مهم: $in مع Array of IDs (زي ما populate بيعمل تحت)
const userIds = ['id1', 'id2', 'id3'];
const users = await User.find({ _id: { $in: userIds } });
```

الـ `$in` هو اللي Mongoose بيستخدمه تحت الـ hood لما بتعمل `.populate()` — بيجمع كل الـ unique ObjectIds ويعمل `$in` query واحدة بدل ما يعمل query لكل ID.

---

## 🟠 Level 3 — Senior Questions: الـ Deep Understanding

---

### ❓ س21: إيه هو الـ `this` في `pre('findOneAndUpdate')` وإيه الفرق عن `pre('save')`؟

> **الإجابة:**

```javascript
// pre('save') — this = Document Instance
userSchema.pre('save', function() {
  console.log(this instanceof mongoose.Document); // ← true
  console.log(this.name);         // ← 'Ahmed' ✅
  console.log(this.isModified()); // ← method موجودة ✅
});

// pre('findOneAndUpdate') — this = Query Object
userSchema.pre('findOneAndUpdate', function() {
  console.log(this instanceof mongoose.Query); // ← true
  console.log(this.name);    // ← undefined ❌ مش Document
  
  // علشان توصل للـ update data:
  const update = this.getUpdate(); // ← { $set: { password: '...' } }
  
  // علشان توصل للـ filter:
  const filter = this.getFilter(); // ← { _id: '...' }
  
  // علشان توصل للـ options:
  const options = this.getOptions(); // ← { new: true, runValidators: true }
});
```

**ليه بيفرق؟** في `pre('save')`، الـ document موجود في الـ memory وبيتغير. في `pre('findOneAndUpdate')`، الـ Document مش اتحمّل — بس الـ query ومعاها الـ update operation. الـ Mongoose بيعمل الـ update في الـ DB مباشرة.

---

### ❓ س22: إزاي بتعمل cascade delete في Mongoose؟ وإيه الـ pitfall الرئيسي؟

> **الإجابة:**

```javascript
// لما بتحذف Product، محتاج تحذف كل Reviews بتاعتها تلقائياً
productSchema.post('findOneAndDelete', async function(doc) {
  if (doc) {
    await Review.deleteMany({ product: doc._id });
    console.log(`Deleted reviews for product: ${doc._id}`);
  }
});

// الاستخدام في الـ Controller
await Product.findByIdAndDelete(productId); // ← بيشغّل الـ hook تلقائياً
```

**الـ Pitfall الرئيسي:**

```javascript
// ❌ الغلط — deleteOne() بيشغّل hook تاني مش post('findOneAndDelete')
await Product.deleteOne({ _id: productId });
// → الـ reviews مش هتتحذف! 😱

// ❌ الغلط التاني — deleteMany() برضو مش بيشغّل الـ hook على كل document
await Product.deleteMany({ category: 'old' });
// → بيحذف الـ products لكن مش الـ reviews!
```

**الحل للـ deleteMany cascade:** لازم تجيب الـ IDs الأول ثم تحذفهم يدوياً:

```javascript
const products = await Product.find({ category: 'old' }).select('_id');
const ids = products.map(p => p._id);
await Product.deleteMany({ _id: { $in: ids } });
await Review.deleteMany({ product: { $in: ids } }); // ← cascade يدوي
```

---

### ❓ س23: إيه هو الـ Aggregation Pipeline وإيه الفرق بينه وبين الـ `find()`؟

> **الإجابة:**

```
find()                              Aggregation Pipeline
──────                              ─────────────────────
بيجيب documents كما هي             بيعالج ويحوّل البيانات
filtering فقط (match)              match + group + sort + join + calculate
بيرجع documents أو sub-set منها   ممكن يرجع أي شكل من البيانات
بيشتغل في الـ application layer    بيشتغل في الـ MongoDB Engine
```

الـ Aggregation Pipeline هو series من الـ stages — كل stage بياخد output السابقة وبيعمل عليها operation:

```javascript
const result = await Order.aggregate([
  { $match: { status: 'delivered' } },          // Stage 1: فلتر
  { $unwind: '$items' },                          // Stage 2: فكّ الـ array
  { $group: {                                     // Stage 3: تجميع
    _id: '$items.product',
    revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
    count: { $sum: 1 },
  }},
  { $sort: { revenue: -1 } },                    // Stage 4: ترتيب
  { $limit: 10 },                                // Stage 5: أول 10
]);
```

---

### ❓ س24: إيه هو الـ `$unwind` وليه بيكون ضروري قبل الـ `$group`؟

> **الإجابة:**

`$unwind` بياخد document فيه array وبيعمل منه documents منفصلة — واحد لكل element.

```javascript
// قبل $unwind
{ _id: 'order1', items: [{ product: 'p1', qty: 2 }, { product: 'p2', qty: 1 }] }

// بعد $unwind على '$items'
{ _id: 'order1', items: { product: 'p1', qty: 2 } }
{ _id: 'order1', items: { product: 'p2', qty: 1 } }
// ← 2 documents بدل 1!
```

**ليه ضروري قبل `$group`؟** لأنك لو عايز تـ group على الـ `items.product` عشان تعرف كل product اتباع كام مرة، لازم كل item يكون document مستقل. بدون `$unwind`، كل order هتعامل معاها كـ document واحد.

```javascript
// ⚠️ انتبه: preserveNullAndEmptyArrays
{ $unwind: { path: '$items', preserveNullAndEmptyArrays: true } }
// لو مفيش items، بدون الـ option ده الـ document هيتشال من النتائج
// مع الـ option، هييجي مع items = null
```

---

### ❓ س25: إيه هو الـ `$facet` وامتى بيفرق معاك؟

> **الإجابة:**

`$facet` بيخليك تشغّل multiple aggregation pipelines بالـ parallel على نفس الـ input documents في query واحدة.

```javascript
// بدون $facet — 3 queries منفصلة
const [products, total, priceRange] = await Promise.all([
  Product.aggregate([...paginatedProducts]),
  Product.aggregate([...countPipeline]),
  Product.aggregate([...priceRangePipeline]),
]);

// مع $facet — query واحدة
const result = await Product.aggregate([
  { $match: { isActive: true } }, // ← shared filter
  {
    $facet: {
      products: [{ $skip: 0 }, { $limit: 12 }],
      total: [{ $count: 'count' }],
      priceRange: [{ $group: { _id: null, min: { $min: '$price' }, max: { $max: '$price' } } }],
    },
  },
]);
// result[0].products, result[0].total, result[0].priceRange
```

**الفايدة:** قلّلنا من 3 round-trips للـ DB لـ round-trip واحدة. الـ documents اللي عدت على `$match` بتشتغل عليها الـ 3 pipelines بالـ parallel في الـ MongoDB.

---

### ❓ س26: إيه هو الـ Index في MongoDB وليه مهم للـ Performance؟

> **الإجابة:**

الـ Index هو data structure بيخلي MongoDB تلاقي الـ documents بسرعة من غير ما تقرأ الـ collection كلها. بالظبط زي **فهرس الكتاب** — بدل ما تقرأ كل الصفحات عشان تلاقي كلمة، بتروح للفهرس وبيقولك الصفحة رقم كام.

```javascript
// بدون index: MongoDB بتعمل COLLSCAN (collection scan)
// بتقرأ كل document في الـ collection — بطيء جداً في millions of docs

// مع index: MongoDB بتعمل IXSCAN (index scan)
// بتروح مباشرة للـ documents المطلوبة

// إنشاء Indexes
productSchema.index({ category: 1 });              // ← single field
productSchema.index({ category: 1, price: -1 });   // ← compound (category asc, price desc)
productSchema.index({ name: 'text', description: 'text' }); // ← text search
userSchema.index({ resetToken: 1 }, { sparse: true }); // ← sparse: مش كل user عنده token
userSchema.index({ sessionExpiry: 1 }, { expireAfterSeconds: 0 }); // ← TTL index
```

**إزاي تتأكد إن الـ query بتستخدم index:**

```javascript
const explained = await Product.find({ category: 'electronics' }).explain('executionStats');
// ابحث عن: "winningPlan.stage"
// IXSCAN = استخدم index ✅
// COLLSCAN = مش مستخدم index ❌
```

---

### ❓ س27: إيه هو الـ Compound Index وامتى بيشتغل وامتى لأ؟

> **الإجابة:**

الـ Compound Index هو index على أكتر من field واحد.

```javascript
// Index على: category أولاً، بعدين price
productSchema.index({ category: 1, price: -1 });
```

**قاعدة الـ Prefix:** الـ compound index بيشتغل لما الـ query بتستخدم الـ fields بنفس الترتيب من اليسار:

```javascript
// ✅ بيستخدم الـ index
Product.find({ category: 'electronics' })
Product.find({ category: 'electronics', price: { $gt: 1000 } })

// ❌ مش بيستخدم الـ index
Product.find({ price: { $gt: 1000 } }) // ← بدأ بـ price مش category
Product.find({ price: 1000, category: 'electronics' }) // ← نفس المشكلة
```

**قاعدة ESR (Equality, Sort, Range):**
رتّب fields الـ index بالشكل ده لأفضل performance:
1. Equality conditions أول (exact match)
2. Sort conditions
3. Range conditions أخير

---

### ❓ س28: إيه هو الـ N+1 Problem في Mongoose وإزاي بتحله؟

> **الإجابة:**

الـ N+1 Problem بيحصل لما بتعمل query تجيب N documents، وبعدين لكل document بتعمل query تانية — النتيجة N+1 queries على الـ DB.

```javascript
// ❌ N+1 Problem
const orders = await Order.find({ status: 'pending' }); // ← Query 1
for (const order of orders) {
  // Query 2, 3, 4, ... N+1 — بيحصل لكل order!
  const user = await User.findById(order.user);
  console.log(user.name);
}
// لو عندك 100 order → 101 queries! 😱

// ✅ الحل 1: استخدم populate (يعمل $in query واحدة)
const orders = await Order.find({ status: 'pending' })
  .populate('user', 'name email');
// → 2 queries بس: 1 للـ orders، 1 $in query للـ users

// ✅ الحل 2: استخدم $lookup (1 query كاملة في الـ DB)
const orders = await Order.aggregate([
  { $match: { status: 'pending' } },
  { $lookup: { from: 'users', localField: 'user', foreignField: '_id', as: 'user' } },
]);
```

---

### ❓ س29: إيه الـ Snapshot Pattern وليه بنستخدمه في الـ Orders؟

> **الإجابة:**

الـ Snapshot Pattern هو حفظ نسخة من البيانات المهمة **وقت عملية معينة** بدل الاعتماد الكامل على الـ reference.

```javascript
// ❌ بدون Snapshot — محتاج populate دايماً
const orderSchema = new mongoose.Schema({
  product: { type: ObjectId, ref: 'Product' },
  quantity: Number,
  // السعر مش محفوظ — هجيبه من الـ product
});
// المشكلة: لو السعر اتغير بعدين، الـ order القديمة هتعكس السعر الجديد!

// ✅ مع Snapshot — بيانات مهمة محفوظة وقت الشراء
const orderItemSchema = new mongoose.Schema({
  product: { type: ObjectId, ref: 'Product' },  // ← reference لو محتاج link
  name: String,     // ← snapshot اسم المنتج وقت الشراء
  price: Number,    // ← snapshot السعر وقت الشراء
  image: String,    // ← snapshot أول صورة وقت الشراء
  quantity: Number,
});
```

**ليه مهم؟**
- لو product اتحذف → الـ order لسه بتعرف اسمه وسعره
- لو السعر اتغير → الـ old orders بتفضل بالسعر القديم (ده مش bug — ده صح!)
- بيوفر populate calls في الـ order history

---

### ❓ س30: إيه الـ Transactions في MongoDB وامتى بتستخدمها؟

> **الإجابة:**

الـ Transactions في MongoDB (من v4+) بتضمن إن مجموعة من الـ operations تتنفذ كـ **atomic unit** — يعني إما كلها بتنجح أو كلها بتفشل. بالظبط زي ACID transactions في SQL.

```javascript
const session = await mongoose.startSession();

try {
  session.startTransaction();
  
  // Operation 1: تقليل stock الـ product
  const product = await Product.findOneAndUpdate(
    { _id: productId, stock: { $gte: quantity } },
    { $inc: { stock: -quantity } },
    { session, new: true }  // ← لازم تبعت الـ session!
  );
  
  if (!product) throw new Error('المنتج مش متاح بالكمية المطلوبة');
  
  // Operation 2: إنشاء الـ order
  const order = await Order.create(
    [{ user: userId, product: productId, quantity, price: product.price }],
    { session }  // ← نفس الـ session
  );
  
  // Operation 3: تسجيل الـ payment
  await Payment.create([{ order: order._id, amount: product.price * quantity }], { session });
  
  // لو وصلنا هنا والـ 3 operations نجحت — نـ commit
  await session.commitTransaction();
  return order;
  
} catch (error) {
  // لو أي operation فشلت — كل حاجة بترجع زي ما كانت
  await session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```

**امتى بتستخدم Transactions؟**
- نقل فلوس بين accounts
- تقليل stock + إنشاء order في نفس الوقت
- أي عملية محتاجة multiple write operations وكلها لازم تنجح أو تفشل مع بعض

---

## 🔴 Level 4 — Staff / Architect Questions: اللي بتعرف فيه المهندس من المبرمج

---

### ❓ س31: إيه هو الـ Connection Pool وإزاي بيؤثر على الـ Performance؟

> **الإجابة:**

لما Mongoose بتعمل `connect()` للـ MongoDB، مش بتفتح connection واحدة — بتفتح **pool of connections** (الـ default هو 5).

```
Pool of Connections:
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│  Conn1  │  Conn2  │  Conn3  │  Conn4  │  Conn5  │
│  FREE   │  FREE   │  FREE   │  FREE   │  FREE   │
└─────────┴─────────┴─────────┴─────────┴─────────┘

Request يجي → Conn1 بيتـ assign له → بيشتغل → بيرجع للـ pool
```

```javascript
mongoose.connect(uri, {
  maxPoolSize: 10,     // ← أقصى عدد connections (default: 5)
  minPoolSize: 2,      // ← minimum connections دايماً مفتوحة
  serverSelectionTimeoutMS: 5000, // ← وقت الانتظار لو الـ DB مش responsive
  socketTimeoutMS: 45000,         // ← وقت الانتظار لـ query تكمل
});
```

**لو جاء request أكتر من الـ pool size؟** الـ requests بتنتظر في queue. لو فاض الوقت بدون connection → timeout error.

**في Production:** الـ `maxPoolSize` بيتحدد على حسب:
- عدد الـ CPUs على سيرفر MongoDB
- الـ workload (read-heavy vs write-heavy)
- عدد الـ Node.js instances (لو بتستخدم PM2 cluster)

---

### ❓ س32: إيه هو الـ Mongoose Query Execution — إيه اللي بيحصل بين `find()` والـ DB؟

> **الإجابة:**

الـ Mongoose Query مش بيتنفذ فوراً لما تكتبه — ده **lazy execution**:

```javascript
// ده مش query تنفذت — ده Query object بس اتبني
const query = Product.find({ isActive: true });

// ده كمان مش query تنفذت — بس بنضيف modifiers
query.sort({ price: -1 }).limit(10).select('name price');

// الـ query بتتنفذ فعلاً لما:
// 1. تعمل await
const result = await query;

// 2. تعمل .then()
query.then(result => console.log(result));

// 3. تعمل .exec()
const result = await query.exec(); // ← نفس الـ await لكن أوضح
```

**الـ Execution Pipeline:**
```
query.find({ isActive: true })
          ↓
  Mongoose بيبني MQL (MongoDB Query Language)
          ↓
  بيبعته للـ MongoDB Driver
          ↓
  الـ Driver بيحوّله لـ BSON
          ↓
  بيبعته على network للـ MongoDB Server
          ↓
  MongoDB بتنفذه (بتستخدم Index لو موجود)
          ↓
  بترجع BSON results
          ↓
  الـ Driver بيحوّلها لـ JavaScript objects
          ↓
  Mongoose بيحوّلها لـ Document instances (أو plain objects لو .lean())
          ↓
  بترجع النتيجة
```

---

### ❓ س33: إيه هو الـ Mongoose Discriminator وامتى بتستخدمه؟

> **الإجابة:**

الـ Discriminator بيخليك تعمل multiple schemas بترث من schema واحد وكلهم بيتخزنوا في نفس الـ collection. ده بيحل مشكلة الـ polymorphic data.

```javascript
// مثال: في ShopFlow، كل types من notifications
const baseNotificationSchema = new mongoose.Schema({
  user: { type: ObjectId, ref: 'User', required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
}, { discriminatorKey: 'type' }); // ← الـ field اللي بيميّز النوع

const Notification = mongoose.model('Notification', baseNotificationSchema);

// OrderNotification — بيرث من Notification
const OrderNotification = Notification.discriminator(
  'OrderNotification',  // ← قيمة الـ discriminatorKey
  new mongoose.Schema({
    order: { type: ObjectId, ref: 'Order' },
    orderStatus: String,
  })
);

// ReviewNotification
const ReviewNotification = Notification.discriminator(
  'ReviewNotification',
  new mongoose.Schema({
    review: { type: ObjectId, ref: 'Review' },
    productName: String,
  })
);

// الاستخدام — كلهم في نفس الـ 'notifications' collection
await OrderNotification.create({ user: userId, order: orderId, orderStatus: 'shipped' });
await ReviewNotification.create({ user: userId, review: reviewId, productName: 'iPhone' });

// الـ document في الـ DB:
// { type: 'OrderNotification', user: ..., order: ..., orderStatus: 'shipped' }
// { type: 'ReviewNotification', user: ..., review: ..., productName: 'iPhone' }

// query — بيجيب كل أنواع الـ notifications
const all = await Notification.find({ user: userId }).sort({ createdAt: -1 });
```

---

### ❓ س34: إزاي بتعمل text search في MongoDB وإيه الـ limitations؟

> **الإجابة:**

```javascript
// 1. لازم يبقى عندك text index
productSchema.index({ name: 'text', description: 'text', tags: 'text' },
  { weights: { name: 10, description: 5, tags: 1 } } // ← اسم أهم من description
);

// 2. الاستخدام
const results = await Product.find(
  { $text: { $search: 'iphone pro max' } }, // ← بيدور على أي كلمة
  { score: { $meta: 'textScore' } }          // ← بيضيف relevance score
).sort({ score: { $meta: 'textScore' } });  // ← ترتيب حسب الـ relevance

// $text بيدعم:
// - 'iphone pro' → الكلمتين
// - '"iphone pro"' → العبارة بالظبط (exact phrase)
// - 'iphone -samsung' → iphone بس مش samsung
```

**الـ Limitations:**
1. بيدعم لغة واحدة بـ default (English stemming)
2. مش بيدعم الـ partial matching — "ipho" مش هيلاقي "iphone"
3. بتقدر تعمل text index واحد بس على الـ collection
4. مش بيدعم الـ Arabic/العربي بشكل مثالي

**البديل في Production:** **MongoDB Atlas Search** (بيستخدم Apache Lucene) — أقوى بكتير وبيدعم fuzzy search، autocomplete، والعربي.

---

### ❓ س35: إيه هو الـ Mongoose Populate مع الـ `match` Option وإيه الـ Gotcha؟

> **الإجابة:**

```javascript
// الـ match بيضيف conditions على الـ populated documents
const products = await Product.find()
  .populate({
    path: 'seller',
    match: { isVerified: true, role: 'seller' }, // ← condition على الـ users
  });
```

**الـ Gotcha الخطير:**

```javascript
// الـ match مش بيشيل الـ product من النتائج!
// لو الـ seller مش verified، seller بيبقى null بس الـ product بيفضل

const products = await Product.find().populate({
  path: 'seller',
  match: { isVerified: true },
});

// ❌ تتوقع: products بس من sellers verified
// الحقيقة: كل الـ products بيجوا، لو الـ seller مش verified → seller = null

// ✅ الحل: تعمل filter بعد الـ populate
const verifiedProducts = products.filter(p => p.seller !== null);
```

ده من أكتر الـ bugs المخفية في Mongoose. الـ match بيعمل filter على الـ **populated documents** مش على الـ **parent documents**.

---

### ❓ س36: إيه هو الـ `$lookup` مع Sub-pipeline وإزاي بيختلف عن الـ Basic `$lookup`؟

> **الإجابة:**

الـ Basic `$lookup` بيجيب كل الـ matched documents من الـ foreign collection. الـ Sub-pipeline بيخليك تعمل processing إضافية على الـ matched documents قبل ما يتـ merge.

```javascript
// Basic $lookup — بيجيب كل fields كل الـ matched reviews
{
  $lookup: {
    from: 'reviews',
    localField: '_id',
    foreignField: 'product',
    as: 'reviews',
  }
}

// $lookup مع Sub-pipeline — أقوى بكتير (من MongoDB 5.0+)
{
  $lookup: {
    from: 'reviews',
    localField: '_id',
    foreignField: 'product',
    as: 'reviews',
    pipeline: [
      { $match: { rating: { $gte: 4 } } },     // ← بس reviews 4 stars فأكتر
      { $sort: { createdAt: -1 } },              // ← آخر reviews
      { $limit: 3 },                             // ← 3 reviews بس
      { $project: { rating: 1, comment: 1 } },  // ← fields محددة
      {
        $lookup: {                               // ← nested lookup!
          from: 'users',
          localField: 'user',
          foreignField: '_id',
          as: 'user',
          pipeline: [{ $project: { name: 1, avatar: 1 } }],
        },
      },
      { $unwind: '$user' },
    ],
  }
}
```

الـ Sub-pipeline بيـ reduce الـ data المتبعتة على الـ network وبيـ reduce الـ memory usage لأن الـ processing بتحصل في الـ DB مش في الـ Node.js.

---

### ❓ س37: إيه هو الـ Mongoose `toJSON()` وـ `toObject()` وليه مهمين؟

> **الإجابة:**

الـ Mongoose Document عنده طريقتين لتحويله لـ plain object:
- `toObject()` — بيرجع plain JavaScript object
- `toJSON()` — بيتستدعى تلقائياً لما تعمل `JSON.stringify()` أو لما بترد بـ `res.json()`

```javascript
const userSchema = new mongoose.Schema({
  name: String,
  password: { type: String, select: false },
}, {
  toJSON: {
    virtuals: true,   // ← اعرض الـ virtual fields في الـ JSON
    transform: function(doc, ret) {
      delete ret.password;     // ← شيل الـ password من الـ JSON response دايماً
      delete ret.__v;          // ← شيل الـ version key
      ret.id = ret._id;        // ← اضيف id بجانب _id
      delete ret._id;          // ← شيل _id لو عايز id بس
      return ret;
    },
  },
  toObject: { virtuals: true },
});
```

```javascript
// ده بيتشغّل تلقائياً
const user = await User.findById(id);
res.json(user); // ← هنا toJSON بيتشتغل → password مش هييجي في الـ response
```

**الـ Use Case المهم:** بدل ما تكتب `select('-password')` في كل query، تحط الـ transform في الـ Schema وهو بيشيله تلقائياً من أي response.

---

### ❓ س38: إيه هي أنواع الـ Indexes وامتى تستخدم كل نوع؟

> **الإجابة:**

```javascript
// 1. Single Field Index — الأساسي
productSchema.index({ price: 1 }); // 1 = ascending, -1 = descending

// 2. Compound Index — على أكتر من field
productSchema.index({ category: 1, price: -1 });
// القاعدة: بيشتغل للـ queries اللي بتستخدم الـ prefix (category, أو category+price)
// مش بيشتغل لو بدأت بـ price لوحده

// 3. Unique Index
userSchema.index({ email: 1 }, { unique: true });
// → بيـ throw 11000 error لو القيمة موجودة

// 4. Sparse Index — بيبني index بس على الـ documents اللي فيها الـ field
userSchema.index({ googleId: 1 }, { sparse: true });
// مفيد: بتاخد unique + sparse → unique بس بين الـ documents اللي فيها الـ field

// 5. TTL Index — automatic document expiration
const sessionSchema = new mongoose.Schema({
  token: String,
  expiresAt: Date,
});
sessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
// MongoDB background job بيمسح documents لما expiresAt < now

// 6. Text Index — للـ full-text search
productSchema.index({ name: 'text', description: 'text' });

// 7. Partial Index — index على subset من الـ documents
productSchema.index(
  { price: 1 },
  { partialFilterExpression: { isActive: true } }
  // ← بيبني index بس على الـ active products
  // → أصغر في الـ size وأسرع في الـ inserts
);
```

---

### ❓ س39: إيه الفرق بين `updateOne()` و`findOneAndUpdate()` وامتى كل واحد يكون أسرع؟

> **الإجابة:**

```javascript
// updateOne() — بيعمل update وبيرجع metadata بس
const result = await Product.updateOne(
  { _id: id },
  { $set: { price: 50000 } }
);
// result = { matchedCount: 1, modifiedCount: 1, acknowledged: true }
// مش بيجيب الـ document — أسرع!

// findOneAndUpdate() — بيعمل update وبيرجع الـ document
const product = await Product.findOneAndUpdate(
  { _id: id },
  { $set: { price: 50000 } },
  { new: true } // ← بيرجع الـ document بعد التعديل
);
// product = { _id: ..., name: 'iPhone', price: 50000, ... }
// أبطأ لأنه محتاج يجيب الـ document من الـ DB
```

**امتى كل واحد؟**

| الحاجة | استخدم |
|---|---|
| بس عايز تعمل update ومش محتاج الـ document | `updateOne()` — أسرع |
| محتاج الـ document بعد الـ update | `findOneAndUpdate({ new: true })` |
| محتاج تشغّل post-save middleware | `findById()` ثم `save()` |
| Bulk update لكتير من documents | `updateMany()` |

---

### ❓ س40: إزاي بتعمل Data Migration آمنة في MongoDB من غير downtime؟

> **الإجابة:**

الـ Schema change في MongoDB أسهل من SQL لكن محتاجة strategy. مثال: إضافة `fullName` field لكل users موجودين.

**الـ Strategy: Expand/Contract Pattern (Zero Downtime)**

```javascript
// الـ المرحلة 1 (Expand): بتضيف الـ field الجديد من غير ما تمسح القديم
// الـ application بتكتب في الاتنين وبتقرأ من الجديد مع fallback للقديم
userSchema.virtual('displayName').get(function() {
  return this.fullName || `${this.firstName} ${this.lastName}`; // ← fallback
});

// الـ Migration Script — بيشتغل background
const migrateUsers = async () => {
  const batchSize = 1000;
  let lastId = null;
  let processed = 0;

  while (true) {
    const filter = lastId ? { _id: { $gt: lastId }, fullName: { $exists: false } }
                          : { fullName: { $exists: false } };
    
    const users = await User.find(filter)
      .select('firstName lastName')
      .limit(batchSize)
      .lean();
    
    if (users.length === 0) break;
    
    const bulkOps = users.map(user => ({
      updateOne: {
        filter: { _id: user._id },
        update: { $set: { fullName: `${user.firstName} ${user.lastName}` } },
      },
    }));
    
    await User.bulkWrite(bulkOps); // ← أسرع من updateMany لكل document
    
    lastId = users[users.length - 1]._id;
    processed += users.length;
    console.log(`Migrated ${processed} users...`);
    
    await new Promise(resolve => setTimeout(resolve, 100)); // ← throttle عشان ماتضغطش الـ DB
  }
  
  console.log('Migration complete!');
};

// المرحلة 2 (Contract): بعد ما كل الـ users اتعدّلوا، بتشيل الـ old fields
```

---

### ❓ س41: إيه هو الـ `bulkWrite()` وامتى بيكون أسرع من الـ operations العادية؟

> **الإجابة:**

`bulkWrite()` بيبعت multiple write operations (insert, update, delete) في **request واحدة** للـ MongoDB بدل ما تبعت كل operation منفصلة.

```javascript
const operations = [
  // Insert
  { insertOne: { document: { name: 'Product A', price: 100 } } },
  
  // Update
  {
    updateOne: {
      filter: { _id: productId1 },
      update: { $set: { price: 200 }, $inc: { stock: -1 } },
    },
  },
  
  // Upsert — insert لو مش موجود، update لو موجود
  {
    updateOne: {
      filter: { sku: 'ABC123' },
      update: { $set: { name: 'Product B', price: 150 } },
      upsert: true,
    },
  },
  
  // Delete
  { deleteOne: { filter: { _id: productId2 } } },
];

const result = await Product.bulkWrite(operations, {
  ordered: false, // ← لو false: كل الـ operations بتحاول تتنفذ حتى لو في errors
                  // لو true: بيوقف عند أول error
});

console.log(result.insertedCount);  // عدد الـ inserts
console.log(result.modifiedCount);  // عدد الـ updates
console.log(result.deletedCount);   // عدد الـ deletes
```

**ليه أسرع؟** بدل N network round-trips للـ DB، بتعمل واحدة بس. في scenarios زي import 10,000 products من Excel، الفرق بين `bulkWrite()` ولوب من `create()` ممكن يكون دقائق.

---

### ❓ س42: إيه هو الـ Mongoose Plugin System وإزاي بتستخدمه؟

> **الإجابة:**

الـ Mongoose Plugin بيخليك تضيف functionality مشتركة لـ multiple schemas من غير ما تكرر الكود.

```javascript
// plugins/softDelete.js — Plugin عام للـ Soft Delete
const softDeletePlugin = function(schema, options) {
  // إضافة الـ fields
  schema.add({
    isDeleted: { type: Boolean, default: false, index: true },
    deletedAt: { type: Date, default: null },
  });

  // إضافة instance method
  schema.methods.softDelete = async function() {
    this.isDeleted = true;
    this.deletedAt = new Date();
    return this.save();
  };

  // إضافة static method
  schema.statics.findNotDeleted = function(filter = {}) {
    return this.find({ ...filter, isDeleted: false });
  };

  // إضافة pre hook تلقائي
  schema.pre(/^find/, function() {
    // بيـ apply على كل find queries
    if (!this.getFilter().includeDeleted) {
      this.where({ isDeleted: false });
    }
  });
};

// الاستخدام على أي schema
productSchema.plugin(softDeletePlugin);
userSchema.plugin(softDeletePlugin);
orderSchema.plugin(softDeletePlugin);

// أو على مستوى الـ global (على كل الـ schemas)
mongoose.plugin(softDeletePlugin);
```

---

### ❓ س43: ازاي بتتعامل مع الـ Large Files في MongoDB وليه مش المفروض تخزنهم في Documents عادية؟

> **الإجابة:**

الـ MongoDB Document size limit هو **16MB**. الصور والفيديوهات والملفات الكبيرة ممكن تتعدى ده.

**الحلول:**

```javascript
// 1. GridFS — MongoDB's built-in file storage
// بيقسم الـ file على chunks صغيرة (255KB كل chunk) ويخزنها في collections
const mongoose = require('mongoose');
const { GridFSBucket } = require('mongodb');

const uploadFile = async (fileBuffer, filename, mimeType) => {
  const bucket = new GridFSBucket(mongoose.connection.db, {
    bucketName: 'uploads',
    chunkSizeBytes: 255 * 1024, // ← 255KB chunks
  });
  
  return new Promise((resolve, reject) => {
    const uploadStream = bucket.openUploadStream(filename, {
      metadata: { mimeType, uploadedAt: new Date() },
    });
    uploadStream.end(fileBuffer);
    uploadStream.on('finish', () => resolve(uploadStream.id));
    uploadStream.on('error', reject);
  });
};

// 2. External Storage (الأفضل في Production)
// بتحفظ الـ file في S3 / Cloudinary / Azure Blob
// وبتحفظ الـ URL بس في الـ MongoDB Document

const productSchema = new mongoose.Schema({
  name: String,
  images: [{
    url: String,       // ← S3 URL
    publicId: String,  // ← Cloudinary public ID للحذف
    width: Number,
    height: Number,
  }],
});
// ← الـ image نفسها في Cloudinary، الـ metadata في MongoDB
```

**الـ Best Practice:** دايماً استخدم external storage (S3, Cloudinary) وخزّن الـ URL في MongoDB. GridFS مناسب للـ files اللي محتاج تـ stream منها مباشرة (زي فيديوهات في internal system).

---

### ❓ س44: إيه هو الـ Read Preference في MongoDB وامتى بيبقى مهم؟

> **الإجابة:**

في MongoDB Replica Set (وده الـ production setup الطبيعي)، عندك **Primary node** بتتم عليه الـ writes، وعندك **Secondary nodes** بتستقبل writes من الـ Primary.

الـ **Read Preference** بيحدد من فين بتقرأ:

```javascript
mongoose.connect(uri, {
  readPreference: 'primary', // default — بتقرأ من الـ Primary دايماً (consistent)
});

// Options:
// 'primary'         — Primary بس (default, strong consistency)
// 'primaryPreferred' — Primary لو متاح، Secondary لو لأ
// 'secondary'       — Secondary بس (ممكن تقرأ stale data)
// 'secondaryPreferred' — Secondary لو متاح، Primary لو لأ
// 'nearest'         — الـ node الأقرب network-wise

// في query معينة
const analytics = await Order.find({})
  .read('secondary') // ← اقرأ من secondary عشان مش هنعدّل
  .lean();
```

**امتى مهم؟**
- **Analytics Queries:** بتـ read من Secondary عشان ماتضغطيش على الـ Primary
- **Reporting:** نفس السبب — heavy reads مش محتاجة latest data
- **Geo-distributed apps:** بتقرأ من الـ nearest node للـ user

---

### ❓ س45: ازاي بتعمل Full-text Search في MongoDB وإيه البديل الـ Production-grade؟

> **الإجابة:**

**الطريقة الأولى: MongoDB Text Index (بسيطة)**

```javascript
// الـ setup
productSchema.index(
  { name: 'text', description: 'text', tags: 'text' },
  { weights: { name: 10, description: 3, tags: 1 }, default_language: 'arabic' }
);

// الاستخدام
const results = await Product.find(
  { $text: { $search: '"شاشة سامسونج" -تلف' } }, // ← exact phrase، استثناء
  { score: { $meta: 'textScore' } }
).sort({ score: { $meta: 'textScore' } }).lean();
```

**الـ Limitations:**
- مش بيدعم partial matching (autocomplete)
- مش بيدعم typo-tolerance (fuzzy search)
- الـ Arabic support محدود

**الطريقة التانية: MongoDB Atlas Search (Production-grade)**

```javascript
// بيستخدم Apache Lucene تحت
const results = await Product.aggregate([
  {
    $search: {
      index: 'products_search', // ← index بتعرّفه في Atlas
      compound: {
        must: [{
          text: {
            query: 'ايفون',
            path: ['name', 'description'],
            fuzzy: { maxEdits: 1 }, // ← بيقبل typos
          },
        }],
        should: [{
          range: {
            path: 'ratings.average',
            gte: 4,
            score: { boost: { value: 2 } }, // ← المنتجات اللي rating عالي أهم
          },
        }],
      },
      highlight: { path: 'name' }, // ← بيـ highlight الكلمة المتحة في النتيجة
    },
  },
  { $limit: 20 },
  { $project: { name: 1, price: 1, score: { $meta: 'searchScore' } } },
]);
```

---

## 🎯 Bonus — الأسئلة السيناريو اللي بتظهر في الـ Final Rounds

---

### ❓ س46: "عندنا endpoint بطيء — بياخد 3 ثواني. ازاي بتـ debug وبتحسّنه؟"

> **الإجابة المنهجية:**

```javascript
// Step 1: حدد الـ slow query
// في Mongoose، فعّل query logging
mongoose.set('debug', true);
// أو استخدم mongoose-morgan أو custom middleware

// Step 2: فهم الـ query
const result = await Product
  .find({ category: 'electronics', isActive: true })
  .sort({ price: -1 })
  .explain('executionStats'); // ← أهم حاجة

// النقاط اللي بتبص فيها في الـ explain output:
// executionStats.totalDocsExamined vs nReturned
// لو totalDocsExamined >> nReturned = مش مستخدم index كفاية
// executionTimeMillis = وقت التنفيذ

// Step 3: حل المشكلة على حسب السبب

// سبب 1: مش مستخدم index
productSchema.index({ category: 1, isActive: 1, price: -1 });

// سبب 2: بيجيب fields زيادة
.select('name price images') // ← projection

// سبب 3: بيجيب documents كتير من غير pagination
.limit(20) // ← pagination

// سبب 4: populate كتير (N+1)
// ← حوّله لـ $lookup في aggregation

// سبب 5: مش مستخدم lean()
.lean() // ← في GET requests

// سبب 6: multiple sequential queries
// ← استخدم Promise.all للـ parallel execution
```

---

### ❓ س47: "ازاي بتضمن uniqueness للـ email في MongoDB في distributed system؟"

> **الإجابة:**

```javascript
// الحل الأول (الأبسط): unique index
userSchema.index({ email: 1 }, { unique: true });
// MongoDB بتضمن uniqueness على مستوى الـ database حتى في distributed system
// لو 2 writes جوا في نفس الوقت، واحدة بتنجح والتانية بتـ fail بـ 11000

// الحل التاني: findOneAndUpdate مع upsert
const user = await User.findOneAndUpdate(
  { email: normalizedEmail },  // ← الـ filter
  {
    $setOnInsert: {             // ← بس بيتـ set لو ده insert (مش update)
      name,
      password: hashedPassword,
      createdAt: new Date(),
    },
  },
  {
    upsert: true,  // ← create لو مش موجود
    new: true,
    rawResult: true,
  }
);

// rawResult.lastErrorObject.updatedExisting = true → user موجود (duplicate)
// rawResult.lastErrorObject.updatedExisting = false → user جديد اتعمل
if (user.lastErrorObject.updatedExisting) {
  throw new Error('الإيميل موجود بالفعل');
}
```

---

### ❓ س48: "عندك collection فيها 50 مليون document. ازاي بتعمل query فعّالة؟"

> **الإجابة الشاملة:**

```javascript
// 1. Indexes أولاً — مش اختياري
collection.createIndex({ userId: 1, createdAt: -1 }); // ← compound
collection.createIndex({ status: 1 }, { partialFilterExpression: { status: 'active' } });

// 2. Projection — جيب بس اللي محتاجه
await Collection.find(filter).select('name status createdAt').lean();

// 3. Cursor للـ large data processing
const cursor = Collection.find(filter).lean().cursor();
for await (const doc of cursor) {
  await processDocument(doc); // ← مش بتحمّل كل الـ 50M في الـ memory!
}

// 4. Aggregation مع $match أول
await Collection.aggregate([
  { $match: { status: 'active', userId: id } }, // ← يستخدم الـ index
  { $group: { _id: '$category', count: { $sum: 1 } } },
]);

// 5. Pagination بـ cursor بدل skip (أسرع للـ deep pages)
// بدل: .skip(10000).limit(20) ← بطيء جداً
// استخدم:
await Collection.find({
  _id: { $gt: lastSeenId } // ← أسرع من skip
}).limit(20).lean();

// 6. Read from Secondary
await Collection.find(filter).read('secondary').lean();

// 7. Sharding (على مستوى الـ DB architecture)
// بتقسّم الـ collection على multiple servers بـ shard key
// مثلاً: { userId: 'hashed' } — بيوزّع الـ data بالتساوي
```

---

## 🫒 زتونة الإنترفيو — الـ Module 5 كله في جملتين

> **"المتقدم للـ MongoDB Senior Position لازم يعرف إن كل decision فيه trade-off: populate سهل لكن app-layer join، $lookup أصعب لكن DB-layer وأسرع. lean() بيكسر الـ Mongoose magic لكن بيرجع performance. runValidators: true ضروري في updates لكن بيـ add overhead. الـ Middleware هو المكان الصح للـ cross-cutting concerns زي hashing والـ cascade — مش الـ Controller. والـ Aggregation Pipeline هو الـ answer لأي سؤال analytics. اللي بيفرق Senior عن Junior مش إنه عارف الـ API — إنه يعرف امتى يستخدم كل option وليه."**

---

```
┌─────────────────────────────────────────────────────────────────────┐
│                 📊 إحصائيات الـ Module 5                            │
├─────────────────────────────────────────────────────────────────────┤
│  🟢 Junior Level (س1-10):    10 أسئلة — الـ survival questions      │
│  🟡 Mid Level (س11-20):      10 أسئلة — اللي بيفرق Junior عن Mid   │
│  🟠 Senior Level (س21-30):   10 أسئلة — الـ deep understanding     │
│  🔴 Staff Level (س31-45):    15 أسئلة — الـ architect thinking      │
│  🎯 Scenario (س46-48):       3 أسئلة — real-world problem solving   │
├─────────────────────────────────────────────────────────────────────┤
│  📝 المجموع: 48 سؤال وجواب كامل                                    │
│  🏆 Coverage: من BSON لـ Sharding                                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

*الـ 4 Modules + الـ 48 سؤال دول بيكوّنوا أقوى MongoDB Interview Vault بالعربي. لو عايز Mock Interview تطبيقي — قولي "ابدأ" وهاخد دور الـ Interviewer 🎤*
