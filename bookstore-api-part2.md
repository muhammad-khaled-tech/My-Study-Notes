# 🟠 PART 2 — "The Business Logic"

### Features, Data Models & Advanced Patterns

---

## Topic 6 — Mongoose Models Deep Dive

We have 6 models: `User` (covered in Part 1), `Book`, `Author`, `Category`, `Cart`, `Order`, `Review`. Let's go through each one with full surgical depth.

---

### 6A — `models/book.js`

---

#### 1. الكونسبت العام

تخيل إنك بتصمم **فيشة منتج في متجر**. الفيشة دي بتقول: اسم المنتج، سعره، الكمية في المخزن، صورته، مين صنعه، وهو في أي قسم. ده بالظبط الـ Book model.

بس هنا في حاجتين بتميزوا:

- **Virtual field** — معلومة بتتحسب on the fly من بيانات موجودة، زي إنك بتكتب على الفيشة "متوفر / قارب على النفاد / مش موجود" بناءً على الكمية اللي على الرف.
- **Index** — تخيل إنك في مكتبة كبيرة وعايز تلاقي كتاب بالاسم. لو مفيش فهرس، هتعدي على كل كتاب واحد واحد (Full Collection Scan). لو في فهرس، بتروح للحرف مباشرةً. ده بالظبط الـ MongoDB index.

---

#### 2. مثال عام بسيط

```js
const bookSchema = new mongoose.Schema({
  name: { type: String, required: true },
  stock: { type: Number, required: true, min: 0 }
});

// Virtual field — مش بتتخزن في DB
bookSchema.virtual('status').get(function () {
  return this.stock > 0 ? 'In Stock' : 'Out of Stock';
});

bookSchema.index({ name: 'text' }); // Full-text search
```

---

#### 3. شرح التطبيق

في `src/models/book.js`:

```js
bookSchema.virtual('status').get(function () {
  if (this.stock > 10) return 'In Stock';
  if (this.stock > 0) return 'Low Stock';
  return 'Out of Stock';
});
```

- الـ virtual بيستخدم `function()` عادية — مش arrow function — عشان يحتاج `this` يشاور على الـ document نفسه. لو استخدمت arrow function، `this` هيبقى `undefined`.

```js
bookSchema.index({ name: 'text' });
bookSchema.index({ price: 1 });
```

- `{ name: 'text' }` — ده Text Index. بيسمح بـ `$text: { $search: 'harry' }` اللي بتعمل full-text search جوه الـ `getAllBooks` controller.
- `{ price: 1 }` — ده Regular Index بترتيب ascending على الـ price field. بيسرّع queries الـ filtering زي `price.$gte` و `price.$lte`.

```js
{
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
}
```

- الـ virtuals بطبيعتها مش بتتحطش في الـ JSON output. لازم تقول لـ Mongoose صراحةً: "لما بتحول الـ document لـ JSON أو object، حط الـ virtuals جوّاه."

الـ `author` و `category` fields هم **references**:

```js
author: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Author',
  required: true
},
category: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Category',
  default: null  // كتاب ممكن يكون من غير category
}
```

ده الـ **Referenced relationship** — مش بنحط بيانات الـ author جوه الـ book مباشرةً، بنحط بس الـ `_id` بتاعه، ولما نعمل `.populate('author')` بيجيب البيانات كاملة.

---

#### 4. الربط بالصورة الكاملة

لما user يعمل `GET /api/books?search=harry&minPrice=10&maxPrice=50`:

1. `app.js` → `rateLimiter` → `httpLogger` → `routes/index.js`
2. `routes/book.js` → `getAllBooks` controller
3. الـ controller يبني الـ query object: `{ $text: { $search: 'harry' }, price: { $gte: 10, $lte: 50 } }`
4. يستدعي `paginate(Book, query, { populate: 'author category', sort: { name: 1 } }, page, limit)`
5. الـ `paginate` utility بتعمل `Book.find(query).populate(...)` و `Book.countDocuments(query)` بالـ parallel
6. الـ Text Index على `name` بيتشغّل — بيجيب الكتب اللي فيها "harry"
7. الـ Price Index على `price` بيسرّع الـ `$gte`/`$lte` filter
8. الـ Virtual `status` بييجي في الـ response لأن `toJSON: { virtuals: true }` شغّال
9. Response: `ApiResponse(200, 'Books fetched', { books, pagination })`

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ `name` field مفيهوش `text` search على أكتر من field:** الكود عامل Text Index على `name` بس. لو الـ user دور على اسم مؤلف أو وصف، مش هيلاقي حاجة. الأحسن كان:

```js
bookSchema.index({ name: 'text', description: 'text' }, { weights: { name: 2, description: 1 } });
```

الـ `weights` بتخلي matches في الـ `name` أهم من الـ `description`.

**عيب 2 — `toJSON: { virtuals: true }` مش كافية لكل السيناريوهات:** في الـ `Cart` controller، لما بيعملوا `.populate('books.bookId')` والـ book data بييجي، الـ virtual `status` مش ضامنين إنه هييجي في كل context. الأفضل تعمل explicit `transform` function على الـ Schema.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه استخدمنا `function()` عادية في الـ virtual getter بدل arrow function؟ إيه اللي كان هيحصل لو استخدمنا arrow?**
2. **إيه الفرق بين الـ Text Index والـ Regular Index في MongoDB؟ وإمتى تستخدم كل واحد؟**
3. **الـ Virtual field بيتخزن في الـ database ولا لأ؟ وليه محتاجين `toJSON: { virtuals: true }`؟**

---

### 6B — `models/author.js`

---

#### 1. الكونسبت العام

الـ Author model بسيط — اسم ومقدمة (bio). بس السؤال الحقيقي هو: **ليه الـ books مش embedded جوه الـ author؟**

تخيل معاك مكتبة. لو حطيت قائمة الكتب جوه بيانات المؤلف، كل ما تضيف كتاب جديد هتعدل الـ author document. وكمان لو عايز تعرض كل الكتب دون المؤلفين، هتجيب كل documents المؤلفين عشان توصل للكتب. ده inefficient.

الأفضل إن الـ **Book يشاور على Author** — مش العكس. الكتاب يتحمل المسؤولية لأنه الـ "child" في العلاقة.

---

#### 2. مثال عام بسيط

```js
// Referenced (what we have — correct)
const bookSchema = new mongoose.Schema({
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'Author' }
});

// Embedded (what we didn't do — would be wrong at scale)
const authorSchema = new mongoose.Schema({
  books: [{ title: String, price: Number }] // ❌ problematic
});
```

---

#### 3. شرح التطبيق

في `src/models/author.js`:

```js
const authorSchema = new Schema({
  name: { type: String, required: true, minlength: 2, maxlength: 100 },
  bio:  { type: String, maxlength: 500 }
}, { timestamps: true });
```

- `bio` مش `required` — مؤلف ممكن يتضاف من غير bio.
- `timestamps: true` — بيضيف `createdAt` و `updatedAt` تلقائياً.
- مفيش index هنا — عشان الـ authors مش بيتعملوا queries متكررة بالـ name.

---

#### 4. الربط بالصورة الكاملة

لما admin يعمل `GET /api/authors/:id`:

1. `authenticate` → `findAuthorById` controller
2. `Author.findById(id)` — بيجيب الـ author
3. `Book.find({ author: id })` — بيجيب كل الكتب بتاعته (بيستخدم الـ `author` index اللي موجود على الـ Book model)
4. بيدمج: `{ ...author.toObject(), bookCount: books.length, books }`
5. Response: `ApiResponse(200, 'Author fetched successfully', author)`

---

#### 5. العيوب اللي في الكود

**عيب 1 — N+1 Query Problem في `findAllAuthors`:**

```js
const authorsWithBookCount = await Promise.all(
  authors.map(async (author) => {
    const bookCount = await Book.countDocuments({ author: author._id }); // ❌ query per author!
    return { ...author.toObject(), bookCount };
  })
);
```

لو عندك 100 مؤلف → 101 query (1 للـ authors + 100 للـ count). الأصح استخدام MongoDB Aggregation:

```js
const authors = await Author.aggregate([
  { $lookup: { from: 'books', localField: '_id', foreignField: 'author', as: 'books' } },
  { $addFields: { bookCount: { $size: '$books' } } },
  { $project: { books: 0 } }
]);
```

**عيب 2 — `findAuthorById` بيجيب كل الكتب دفعة واحدة:** `Book.find({ author: id })` من غير pagination. لو المؤلف عنده 500 كتاب، هتجيبهم كلهم. لازم يبقى paginated.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه الـ `books` مش embedded جوه الـ `author` document في MongoDB؟**
2. **إيه هو الـ N+1 Query Problem؟ وكيف بيأثر على performance؟**
3. **إمتى تستخدم `$lookup` (aggregation) بدل `.populate()`؟**

---

### 6C — `models/category.js`

---

#### 1. الكونسبت العام

الـ Category model أبسط model في المشروع — بس فيه قرارات design مهمة جوّاه. تخيله زي **الأرفف في المكتبة** — كل رف عنده اسم (روايات، علوم، تاريخ). الكتاب بيتحط على رف واحد بس (أو من غير رف خالص). لو الرف اتشال، الكتب مش بتتمسح — بتبقى uncategorized.

---

#### 2. مثال عام بسيط

```js
const categorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true, trim: true }
}, { timestamps: true });
```

---

#### 3. شرح التطبيق

- `unique: true` — مفيش categorize اسمها "Fiction" مرتين. MongoDB بيعمل unique index تلقائياً على الـ field ده.
- `trim: true` — `" Fiction "` هتتخزن كـ `"Fiction"`. بيمنع duplicates من spaces زيادة.
- لما category تتمسح، في `deleteCategory` controller:

```js
await Book.updateMany({ category: req.params.id }, { category: null });
await Category.findByIdAndDelete(req.params.id);
```

ده الـ **Cascade Null pattern** — بدل ما تمسح الكتب (cascade delete)، بتعمل الـ books uncategorized. ده business decision مهم.

---

#### 4. الربط بالصورة الكاملة

لما admin يعمل `DELETE /api/categories/:id`:

1. `authenticate` → `restrictTo('admin')` → `deleteCategory`
2. `Category.findById(id)` → verify وجودها
3. `Book.updateMany(...)` → كل الكتب في الـ category → `category: null`
4. `Category.findByIdAndDelete(id)` → تمسح الـ category نفسها
5. الـ two operations دول مش في transaction! لو الـ `findByIdAndDelete` فشل بعد الـ `updateMany`، عندك books بـ `category: null` وكمان الـ category لسه موجودة... inconsistency!

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ delete operation مش في MongoDB Transaction:** لو الـ `Book.updateMany` نجحت والـ `Category.findByIdAndDelete` فشلت، هيبقى عندك data inconsistency. الحل: wrap them in a session/transaction.

**عيب 2 — `unique: true` مش case-insensitive:** `"fiction"` و `"Fiction"` هيتعاملوا كـ values مختلفة رغم إنهم نفس الـ category. الحل: إضافة `lowercase: true` للـ field أو `collation` على الـ index.

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين `unique: true` في الـ schema وبين إنك تعمل unique index يدوي؟**
2. **ليه استخدمنا `updateMany` بدل ما نمسح الـ books لما نمسح الـ category؟**
3. **لو الـ `Book.updateMany` نجحت والـ `Category.findByIdAndDelete` فشلت، إيه اللي هيحصل؟ وإزاي نحل ده؟**

---

### 6D — `models/cart.js`

---

#### 1. الكونسبت العام

الـ Cart زي **عربية التسوق في السوبرماركت** — كل user عنده عربية واحدة بس (one-to-one مع الـ user)، وجوّاها قائمة من الـ items (array embedded). الكتاب نفسه موجود في collection تانية (referenced)، بس الـ quantity خاصة بالـ cart.

---

#### 2. مثال عام بسيط

```js
const cartSchema = new mongoose.Schema({
  userId: { type: ObjectId, ref: 'User', unique: true }, // عربية واحدة لكل user
  books: [{
    bookId:   { type: ObjectId, ref: 'Book' },
    quantity: { type: Number, min: 1 }
  }]
});
```

---

#### 3. شرح التطبيق

```js
userId: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'User',
  required: true,
  unique: true  // 👈 critical — one cart per user enforced at DB level
}
```

الـ `books` array هي **embedded subdocuments** مش references كاملة. بس `bookId` نفسه reference للـ Book collection عشان نعمل `populate`.

في `addItem`:

```js
const cart = await Cart.findOne({ userId }) || new Cart({ userId, books: [] });
```

ده الـ **Get-or-Create pattern** — لو الـ user مفيهوش cart خالص، بنعمل واحدة جديدة في الميموري (مش في الـ DB لسه). بعدين `cart.save()` بتحفظها.

الـ `$pull` operator في `removeItem`:

```js
{ $pull: { books: { bookId } } }
```

MongoDB `$pull` بيشيل الـ element اللي match الـ condition من الـ array، في operation واحدة على الـ DB.

---

#### 4. الربط بالصورة الكاملة

لما user يعمل `POST /api/cart` (add item):

1. `router.use(protect)` — cart router كله protected في سطر واحد
2. `validate(addItemSchema)` → يتأكد إن `bookId` موجود وـ `quantity` عدد صحيح >= 1
3. `addItem` controller:
    - يجيب الـ book من DB — يتأكد إنه موجود وإن الـ stock كافي
    - يجيب الـ cart أو يعمل واحدة جديدة
    - يحسب `newQuantity = existing + added`
    - يتأكد `newQuantity <= book.stock`
    - يعدل أو يضيف الـ book في الـ array
    - `cart.save()` → `cart.populate(...)` → يحسب `totalPrice`
4. Response: `ApiResponse(201, 'Book added to cart successfully', { cart, totalPrice })`

---

#### 5. العيوب اللي في الكود

**عيب 1 — Race Condition في `addItem`:** لو userين في نفس اللحظة بيضيفوا نفس الكتاب للـ cart (مش متوقع لكن ممكن)، الـ `findOne` → `modify` → `save` pattern ممكن يعمل conflict. الحل: `findOneAndUpdate` مع `$inc` و `$setOnInsert`.

**عيب 2 — `totalPrice` بيتحسب في كل مرة على الـ application layer:** الكود بيعمل `reduce` على الـ books array في JS. لو الـ cart فيها 200 item وبتحسبها في كل request → inefficient. الأحسن يخزن `totalPrice` كـ field على الـ cart ويعمله update عند كل تعديل.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه الـ `books` في الـ cart embedded ومش referenced collection لوحدها؟**
2. **إيه الفرق بين الـ MongoDB `$pull` operator وبين إنك تجيب الـ document وتعدله في JavaScript وتعمل `save()`؟**
3. **ليه `unique: true` على الـ `userId` في الـ cart مهم جداً؟ إيه اللي هيحصل لو مكانش موجود؟**

---

### 6E — `models/order.js`

---

#### 1. الكونسبت العام

الـ Order Model زي **الفاتورة في المحل** — لما تشتري حاجة، الفاتورة بتتطبع بالسعر في اللحظة دي. لو السعر اتغير بكره، الفاتورة القديمة لازم تفضل بالسعر القديم. ده بالظبط الـ `priceAtPurchase` field.

---

#### 2. مثال عام بسيط

```js
items: [{
  bookId: { type: ObjectId, ref: 'Book' },
  quantity: Number,
  priceAtPurchase: Number  // 👈 snapshot of price at order time
}]
```

---

#### 3. شرح التطبيق

```js
status: {
  type: String,
  enum: ['processing', 'out_for_delivery', 'delivered'],
  default: 'processing'
}
```

ده **State Machine** — مش كل transition مسموحة. في `updateOrderStatus` controller:

```js
const StateTransition = {
  processing: 'out_for_delivery',
  out_for_delivery: 'delivered'
};

if (StateTransition[order.status] !== status) {
  throw new ApiError(400, `Can't change order status from '${order.status}' to '${status}'`);
}
```

يعني `processing` → `out_for_delivery` ✅، بس `processing` → `delivered` مباشرةً ❌.

الـ `paymentMethod` و `paymentStatus` fields:

```js
paymentMethod: { enum: ['COD', 'credit_card'] }
paymentStatus: { enum: ['pending', 'success'] }
```

في `services/order.js`:

```js
paymentStatus: paymentMethod === 'credit_card' ? 'success' : 'pending'
```

مدفوع بـ credit card → نعتبره success فوراً. COD → pending لحد ما يتسلم.

---

#### 4. الربط بالصورة الكاملة

Order creation flow: `POST /api/orders` → `protect` → `validate(placeOrderSchema)` → `placeOrder` controller → `orderPlacement` service (transaction) → creates Order doc with `priceAtPurchase` snapshot → clears cart → `ApiResponse(201, ...)`

---

#### 5. العيوب اللي في الكود

**عيب 1 — `StateTransition` object مش على الـ Model:** الـ state machine logic موجودة في الـ controller بدل ما تبقى على الـ Model نفسه. الأصح تحطها في الـ schema كـ instance method: `order.canTransitionTo(newStatus)`.

**عيب 2 — Payment Status بيتعمل manually:** `paymentStatus: paymentMethod === 'credit_card' ? 'success' : 'pending'` — ده assumption إن الـ credit card دايماً ينجح. في الواقع، لازم يكون عندك payment gateway (Stripe, Paymob) ولازم تستنى الـ webhook callback عشان تعمله `success`.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه بنخزن `priceAtPurchase` في الـ order item بدل ما نعتمد على `book.price` وقت الـ display؟**
2. **إيه هو الـ State Machine pattern؟ وليه مش بنسمح بأي transition؟**
3. **إيه الفرق بين `paymentMethod` و `paymentStatus`؟**

---

### 6F — `models/review.js`

---

#### 1. الكونسبت العام

الـ Review model فيه constraint واحد بيميزه: **user واحد ممكن يعمل review على كتاب مرة واحدة بس**. زي ما TripAdvisor مش بيسمحلك تحط أكتر من review على نفس الفندق بنفس الـ account.

ده بيتعمل على مستوى الـ Database بـ **Compound Unique Index** — مش على مستوى الـ Application code.

---

#### 2. مثال عام بسيط

```js
// Compound unique index — بيمنع نفس user يعمل review على نفس book أكتر من مرة
reviewSchema.index({ user: 1, book: 1 }, { unique: true });
```

---

#### 3. شرح التطبيق

```js
reviewSchema.index({ user: 1, book: 1 }, { unique: true });
```

لو حاولت تعمل review تاني لنفس الـ user-book combination، MongoDB بيرمي error بـ `code: 11000`. في `createReview` controller، الكود بيمسك الـ error ده:

```js
try {
  const review = await Review.create({ user: userId, book: bookId, rating, comment });
} catch (err) {
  if (err.code === 11000) {
    throw new ApiError(409, 'You have already reviewed this book');
  }
  throw new ApiError(500, 'Failed to create review', err);
}
```

ده أذكى من إنك تعمل `findOne` قبل الـ `create` — بتوفر DB query وبتعتمد على الـ DB نفسه كـ source of truth.

---

#### 4. الربط بالصورة الكاملة

لما user يعمل `POST /api/books/:bookId/reviews`:

1. `validate(createReviewSchema)` → rating بين 1 و 5
2. `protect` — `req.user` متاح (ملاحظة: الترتيب في `routes/book.js` غلط! `validate` قبل `protect`)
3. `createReview`:
    - يتأكد إن الـ book موجود
    - `Order.exists({ userId, status: 'delivered', 'items.bookId': bookId })` — purchase gate
    - `Review.create(...)` — لو duplicate → `err.code === 11000` → `ApiError(409)`
4. Response: `ApiResponse(201, 'Review created successfully', review)`

---

#### 5. العيوب اللي في الكود

**عيب 1 — الترتيب في `routes/book.js` خاطئ:**

```js
router.post('/:bookId/reviews', validate(createReviewSchema), protect, review.createReview);
```

الـ `validate` شغّال قبل الـ `protect`! يعني الـ body بيتـ validate قبل ما نعرف مين الـ user. الأصح: `protect` → `validate` → `createReview`.

**عيب 2 — `averageRating` بيتحسب بـ extra query في كل مرة:**

```js
const ratings = await Review.find({ book: bookId }).select('rating').lean();
const averageRating = ratings.length > 0
  ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1)
  : 0;
```

ده بيجيب كل الـ ratings في الـ memory ويعمل average في JS. لو الكتاب عنده 10,000 review، ده expensive جداً. الأحسن: MongoDB aggregation `$avg` أو تخزن الـ `averageRating` على الـ Book document نفسه وتعمله update مع كل review.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه استخدمنا Compound Unique Index بدل ما نعمل `findOne` قبل الـ `create` للتأكد من عدم التكرار؟**
2. **إيه الـ `err.code === 11000` ده؟ وبييجي منين؟**
3. **إيه مشكلة حساب الـ `averageRating` بالطريقة الحالية؟ وإيه الـ alternatives؟**

---

---

## Topic 7 — Books Module

### `routes/book.js` + `controllers/book.js` + `validations/book.js`

---

#### 1. الكونسبت العام

الـ Books module هو القلب التجاري للـ API. تخيله زي **واجهة المتجر** — أي حد ممكن يبص ع الكتب (public GET)، بس بس الـ admin اللي يضيف أو يعدل أو يمسح (protected write).

فيه pattern مهم هنا اسمه **Dynamic Query Building** — بدل ما تكتب query ثابتة، بتبني الـ query object بناءً على الـ query params اللي الـ user بعتها.

---

#### 2. مثال عام بسيط

```js
const query = {};
if (req.query.search)   query.$text = { $search: req.query.search };
if (req.query.category) query.category = req.query.category;
if (req.query.minPrice) query.price = { $gte: Number(req.query.minPrice) };
// بتبني الـ query object step by step
const books = await Book.find(query);
```

---

#### 3. شرح التطبيق

في `controllers/book.js` — `getAllBooks`:

```js
const { search, category, author, minPrice, maxPrice, page = 1, limit = 10 } = req.query;

const query = {};
if (search) query.$text = { $search: search };
if (category) query.category = category;
if (author) query.author = author;
if (minPrice || maxPrice) {
  query.price = {};
  if (minPrice) query.price.$gte = Number(minPrice);
  if (maxPrice) query.price.$lte = Number(maxPrice);
}
```

لاحظ: `Number(minPrice)` — الـ query params بتيجي كـ strings دايماً من الـ URL. محتاج تحوّلها لـ Number عشان الـ MongoDB comparison يشتغل صح.

الـ `createBook` controller بيعمل **Referential Integrity Check** يدوياً:

```js
const author = await Author.findById(req.body.author);
if (!author) throw new ApiError(404, 'Author not found');
```

MongoDB مش بيعمل FK constraints تلقائياً زي SQL. لازم تعمل الـ check يدوياً في الـ Application layer.

في `validations/book.js`:

```js
const objectId = joi.string().hex().length(24);
```

ObjectId في MongoDB = 24 حرف hexadecimal. ده custom validator عشان Joi مش عارف MongoDB ObjectId by default.

---

#### 4. الربط بالصورة الكاملة

`GET /api/books?search=dune&minPrice=20&page=2`:

1. `app.js` → `httpLogger` (logs the request) → `rateLimiter` (checks IP)
2. `routes/index.js` → `routes/book.js` → `getAllBooks` (no `protect` — public)
3. Query built: `{ $text: { $search: 'dune' }, price: { $gte: 20 } }`
4. `paginate(Book, query, options, 2, 10)`:
    - `skip = (2-1) * 10 = 10` — تتخطى أول 10 نتيجة
    - `Promise.all([Book.find(...).skip(10).limit(10), Book.countDocuments(...)])`
5. Response includes books + pagination metadata

`POST /api/books` (admin only):

1. `protect` → `restrictTo('admin')` → `validate(createBookSchema)` → `createBook`
2. Check author exists → check category exists → `Book.create(req.body)` → `book.populate('author category')` → `ApiResponse(201)`

---

#### 5. العيوب اللي في الكود

**عيب 1 — `req.body` بيتمرر مباشرةً لـ `Book.create` في `createBook`:**

```js
const book = await Book.create(req.body);
```

حتى مع الـ Joi validation و `stripUnknown: true`، ده pattern خطير. لو في field زي `__v` أو حاجة تانية وصلت، ممكن تتخزن. الأحسن:

```js
const { name, price, stock, coverImage, author, category } = req.body;
const book = await Book.create({ name, price, stock, coverImage, author, category });
```

**عيب 2 — `updateBook` بيمرر `req.body` لـ `findByIdAndUpdate` من غير whitelist:** نفس المشكلة — ممكن fields غير متوقعة توصل لو الـ validation مفيهاش `unknown(false)`. الـ `updateBookSchema` فيه `stripUnknown` من الـ `validate` middleware، بس مش ضامن.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه بنعمل `Number(minPrice)` على الـ query param؟ إيه اللي هيحصل لو مكناش عملناه؟**
2. **إيه الـ Referential Integrity في MongoDB؟ وليه MongoDB مش بيعملها تلقائياً زي SQL؟**
3. **ليه الـ GET routes للكتب public ومش محتاجة `authenticate`؟**

---

---

## Topic 8 — Authors Module

### `routes/author.js` + `controllers/author.js` + `validations/author.js`

---

#### 1. الكونسبت العام

الـ Authors module فيه pattern مهم: **حماية العلاقات قبل الـ Delete**. زي ما مش ممكن تمسح supplier من نظام المخازن لو لسه عنده products مرتبطة بيه — إحنا مش بنسمح بمسح مؤلف لو عنده كتب.

---

#### 2. مثال عام بسيط

```js
// قبل ما نمسح — نتأكد إنه مش ليه dependencies
const hasBooks = await Book.exists({ author: id });
if (hasBooks) throw new ApiError(400, 'Cannot delete author with associated books');
```

---

#### 3. شرح التطبيق

`deleteAuthor` في الـ controller:

```js
const hasBooks = await Book.exists({ author: id });
if (hasBooks) throw new ApiError(400, 'Cannot delete author with associated books');
const author = await Author.findByIdAndDelete(id);
if (!author) throw new ApiError(404, 'Author not found');
```

`Book.exists()` — بترجع `null` أو `{ _id: ObjectId(...) }`. أسرع من `findOne` عشان مش بيجيب كل الـ document، بيجيب بس الـ `_id` (أو حتى بيستخدم COUNT internally في بعض versions).

`unknown(false)` في الـ validation:

```js
const createAuthorSchema = joi.object({
  name: joi.string().min(2).max(100).required(),
  bio: joi.string().max(500).optional()
}).unknown(false); // ❌ ترفض أي field تاني
```

الـ `unknown(false)` أكثر strictness من `stripUnknown: true`. الـ `stripUnknown` بيشيل الـ fields الزيادة في صمت. الـ `unknown(false)` بيرفع error لو في أي field غير معروف.

---

#### 4. الربط بالصورة الكاملة

`GET /api/authors` (public):

1. `findAllAuthors` → `paginate(Author, {}, { sort: { name: 1 } })` → `Promise.all(authors.map(...))` لحساب الـ bookCount
2. **N+1 Problem هنا!** — query per author

`DELETE /api/authors/:id` (admin):

1. `protect` → `restrictTo('admin')` → `deleteAuthor`
2. `Book.exists({ author: id })` → لو في كتب → `ApiError(400)`
3. `Author.findByIdAndDelete(id)` → delete
4. Response

---

#### 5. العيوب اللي في الكود

**عيب 1 — N+1 في `findAllAuthors` (تم ذكره في Models):** الحل المثالي هو MongoDB Aggregation Pipeline بدل `Promise.all`.

**عيب 2 — لما تمسح author، مش بتعمل cascade update للـ books:** الكود بيمنع مسح author لو عنده books — ده decision. البديل كان ممكن يبقى: تسمح بالمسح وتعمل `Book.updateMany({ author: id }, { author: null })`. كلا الـ decisions صح، بس المهم توضح السبب.

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين `Book.exists()` و `Book.findOne()` من ناحية الـ performance؟**
2. **إيه الفرق بين `unknown(false)` في Joi وبين `stripUnknown: true`؟**
3. **ليه مبنسمحش بمسح author لو عنده كتب؟ إيه الـ alternative اللي كنا ممكن نعمله؟**

---

---

## Topic 9 — Categories Module

### `routes/category.js` + `controllers/category.js` + `validations/category.js`

---

#### 1. الكونسبت العام

Categories هو الـ module الأبسط، بس فيه business logic دقيقة: **الـ Soft Cascade Delete**. بدل ما نمسح الكتب التابعة للـ category، بنعملهم uncategorized. زي إنك بتلغي قسم في شركة — الموظفين مش بيتطردوا، بيتنقلوا لـ "بدون قسم" لحد ما تحدد وضعهم.

---

#### 2. مثال عام بسيط

```js
// Cascade Null — قبل ما تمسح الـ category، اعمل الكتب بتاعتها بلا category
await Book.updateMany({ category: categoryId }, { $set: { category: null } });
await Category.findByIdAndDelete(categoryId);
```

---

#### 3. شرح التطبيق

```js
const deleteCategory = async (req, res) => {
  const category = await Category.findById(req.params.id);
  if (!category) throw new ApiError(404, 'Category not found');

  await Book.updateMany({ category: req.params.id }, { category: null });
  await Category.findByIdAndDelete(req.params.id);

  res.json(new ApiResponse(200, 'Category deleted, Books in this Category are now uncategorized'));
};
```

الـ `updateMany` هنا مش بتستخدم `$set` صراحةً — لكن Mongoose بيعمله تلقائياً لما تمرر plain object. الـ MongoDB driver بيضيف الـ `$set` نيابةً عنك.

الـ routes:

```js
router.get('/', getAllCategories); // public
router.post('/', protect, restrictTo('admin'), validate(createCategorySchema), createCategory);
router.patch('/:id', protect, restrictTo('admin'), validate(updateCategorySchema), updateCategory);
router.delete('/:id', protect, restrictTo('admin'), deleteCategory);
```

لاحظ إن الـ `deleteCategory` مفيهاش `validate` middleware — الـ `:id` بييجي من `req.params` مش `req.body`، والـ validation library (Joi) هنا configured عشان تـ validate الـ body بس.

---

#### 4. الربط بالصورة الكاملة

`DELETE /api/categories/:id`:

1. `protect` → `restrictTo('admin')` — two middlewares in sequence
2. `deleteCategory`:
    - `Category.findById(id)` — verify existence → `ApiError(404)` if not found
    - `Book.updateMany(...)` — null-ify all books in this category
    - `Category.findByIdAndDelete(id)` — delete the category
3. Response with descriptive message

ملاحظة: المشكلة إن الـ two operations مش atomic (مش في transaction). لو الـ second operation فشلت، عندك books بـ `null` category وكمان الـ category لسه موجودة في الـ DB.

---

#### 5. العيوب اللي في الكود

**عيب 1 — مفيش Transaction (تم ذكره):** الحل: استخدم `mongoose.startSession()` + `session.startTransaction()` لضمان atomicity.

**عيب 2 — `getAllCategories` من غير pagination:**

```js
const categories = await Category.find().sort({ name: 1 });
```

لو عندك 1000 category → كلها بتييجي في response واحد. لازم `paginate()`.

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين Cascade Delete وCascade Null؟ وإمتى تستخدم كل واحد؟**
2. **ليه الـ `deleteCategory` مش فيها `validate` middleware وده OK؟**
3. **إيه الـ Atomicity وليه مهمة في عملية الـ Delete + UpdateMany دي؟**

---

---

## Topic 10 — Cart Module

### `routes/cart.js` + `controllers/cart.js` + `validations/cart.js`

---

#### 1. الكونسبت العام

الـ Cart module هو الأكثر complexity من ناحية الـ business logic في الـ CRUD العادي. فيه **4 operations مختلفة** على نفس الـ resource، وكل واحدة فيها edge cases:

- **Get** — populate nested references
- **Add** — stock check + upsert pattern
- **Update quantity** — increment/decrement + remove if 0
- **Remove** — `$pull` operator

تخيله زي عربية تسوق حقيقية — لما تضيف item، بيتأكد إن الكمية متاحة. لما تخفض الكمية لصفر، Item بيتشال تلقائياً.

---

#### 2. مثال عام بسيط

```js
// Upsert pattern — جيب الـ cart أو اعمل واحدة جديدة
const cart = await Cart.findOne({ userId }) || new Cart({ userId, books: [] });

// لو الكتاب موجود → زوّد الكمية. لو لأ → أضف item جديد
const existing = cart.books.find(b => b.bookId.toString() === bookId);
if (existing) existing.quantity += quantity;
else cart.books.push({ bookId, quantity });

await cart.save();
```

---

#### 3. شرح التطبيق

**`router.use(protect)`** في `routes/cart.js`:

```js
router.use(protect);
```

بدل ما تحط `protect` على كل route، بتحطه على الـ router نفسه — بيطبق على كل الـ routes اللي جاية بعده. أنيق وDRY.

**`addItem` — الـ Stock Validation:**

```js
const newQuantity = (bookInCart?.quantity || 0) + quantity;
if (newQuantity > book.stock) {
  throw new ApiError(400, `Not enough stock. Only ${book.stock} available`);
}
```

الـ optional chaining `?.` — لو `bookInCart` null أو undefined، `?.quantity` بيرجع `undefined` وبـ `|| 0` بيبقى 0. Clean.

**`updateItemQuantity` — الـ Decrement with Auto-Remove:**

```js
if (action === 'increment') {
  // stock check then increment
} else if (bookInCart.quantity <= 1) {
  cart.books.pull({ bookId }); // Mongoose array pull
} else {
  bookInCart.quantity -= 1;
}
```

لو الـ quantity هتبقى 0 أو أقل → بيشيل الـ item من الـ cart. UX decision جميل.

**الـ `populate` chain:**

```js
await cart.populate({
  path: 'books.bookId',
  select: 'name price coverImage stock author',
  populate: { path: 'author', select: 'name' }
});
```

Nested populate: كتاب جوه cart → بيجيب بيانات الكتاب → وجوّاها بيجيب بيانات المؤلف. حلقة من 3 collections في populate واحد.

---

#### 4. الربط بالصورة الكاملة

`PATCH /api/cart/quantity` (update item quantity):

1. `protect` (applied globally on cart router) → `validate(updateQuantitySchema)` → `updateItemQuantity`
2. `Cart.findOne({ userId })` → verify cart exists
3. `cart.books.find(...)` → verify book in cart
4. If `increment`: `Book.findById(bookId)` → stock check → `bookInCart.quantity += 1`
5. If `decrement` and `quantity <= 1`: `cart.books.pull({ bookId })`
6. `cart.save()` → fresh `findOne` with full `populate` → calculate `totalPrice`
7. Response: `ApiResponse(200, 'Quantity incremented/decremented successfully', { cart, totalPrice })`

ملاحظة: الكود بيعمل `findOne` تاني بعد الـ `save` عشان يجيب الـ populated data. ده extra DB round trip.

---

#### 5. العيوب اللي في الكود

**عيب 1 — Extra DB round trip في `updateItemQuantity`:**

```js
await cart.save();
// ثم
const updatedCart = await Cart.findOne({ userId }).populate(...);
```

ممكن تستخدم `cart.populate(...)` بعد الـ `save` مباشرةً بدل `findOne` جديد — نفس اللي بيعملوه في `addItem`.

**عيب 2 — الـ `totalPrice` مش بيتأثر بـ discount أو promotions:** الكود بيحسب `totalPrice` = sum of `price * quantity` بدون أي مجال لـ discounts أو coupons. لو الـ product roadmap هيضم ده لازم يتعاد تصميم الـ Cart model.

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه معنى `router.use(protect)` وإزاي بيختلف عن حطها على كل route؟**
2. **إيه الـ Nested Populate في Mongoose؟ وكام DB queries بيعمل؟**
3. **ليه `cart.books.pull({ bookId })` شغّالة وإيه الفرق بينها وبين `$pull` في `findOneAndUpdate`؟**

---

---

## Topic 11 — Orders Module & MongoDB Transactions

### `services/order.js` + `controllers/order.js` + `routes/order.js`

---

#### 1. الكونسبت العام

ده **الـ Topic الأهم في Part 2** وممكن يبقى الأهم في المشروع كله.

تخيل إنك بتشتري من موقع. حصل كده:

1. الـ stock اتخصم
2. الـ order اتعمل
3. الـ cart اتشال

لو حصلت مشكلة في الـ step 2 (فشل حفظ الـ order) بعد ما الـ stock اتخصم، عندك **مشكلة كبيرة** — المخزن قل والـ order ماتعملش! ده بالظبط المشكلة اللي الـ Database Transactions بتحلها.

الـ **ACID Transaction** = كل العمليات دي بتتعمل أو مش بتتعمل خالص. كلها نجحت؟ Commit. أي حاجة فشلت؟ Rollback لأول نقطة.

---

#### 2. مثال عام بسيط

```js
const session = await mongoose.startSession();
session.startTransaction();
try {
  await Book.findByIdAndUpdate(id, { $inc: { stock: -1 } }, { session });
  await Order.create([{ ...orderData }], { session });
  await session.commitTransaction();
} catch (err) {
  await session.abortTransaction(); // ↩️ كل حاجة ترجع زي ما كانت
  throw err;
} finally {
  session.endSession();
}
```

---

#### 3. شرح التطبيق

في `services/order.js` — الـ Transaction Flow الكاملة:

**الخطوة 1 — Start Session:**

```js
const session = await mongoose.startSession();
session.startTransaction();
```

الـ `session` زي "بلوكنوت" بيسجل فيه كل التعديلات مؤقتاً — مش بتتكتب في الـ DB الحقيقية لحد ما `commitTransaction()`.

**الخطوة 2 — Validate all items FIRST:**

```js
for (const item of cart.books) {
  const book = await Book.findById(item.bookId).session(session);
  if (!book) throw new ApiError(404, `Book ${item.bookId} not found`);
  if (book.stock < item.quantity) throw new ApiError(400, `Not enough stock for '${book.name}'`);
  orderItems.push({ bookId: item.bookId, quantity: item.quantity, priceAtPurchase: book.price });
}
```

ده **Two-Phase approach**:

- Phase 1: validate all → if anything fails, abort before touching anything
- Phase 2: decrement stock for all

ليه مش بنعمل validate + decrement في loop واحدة؟ عشان لو الـ book الأخير فشل في الـ validation، كنا نضطر نـ rollback كل الـ decrements اللي عملناها قبله — أصعب. بـ two phases، لو الـ validation loop فشلت، مكناش لمسنا الـ stock خالص.

**الخطوة 3 — Decrement stock:**

```js
for (const item of orderItems) {
  await Book.findByIdAndUpdate(
    item.bookId,
    { $inc: { stock: -item.quantity } },
    { session } // 👈 مهم — كل operation داخل نفس الـ session
  );
}
```

`$inc: { stock: -quantity }` — atomic increment/decrement في MongoDB. أسرع وأأمن من `find` → modify → `save`.

**الخطوة 4 — Create Order:**

```js
const [order] = await Order.create([{...orderData}], { session });
```

لاحظ:

- `Order.create([{...}])` — array syntax! لما بتستخدم `create` مع session في transaction، لازم تمرر array. ده Mongoose requirement — مش اختياري.
- نتيجته array، ففي destructuring: `const [order] = ...`

**الخطوة 5 — Clear Cart:**

```js
cart.books = [];
await cart.save({ session });
```

**الخطوة 6 — Commit or Abort:**

```js
await session.commitTransaction();
return order;
} catch (error) {
  await session.abortTransaction();
  throw new ApiError(500, 'Failed to place order', error.message);
} finally {
  session.endSession();
}
```

الـ `finally` بيشتغل دايماً — سواء الـ try نجح أو الـ catch اشتغل. لازم `endSession()` تتعمل دايماً عشان تحرر الـ resources.

**الـ State Machine في `updateOrderStatus`:**

```js
const StateTransition = {
  processing: 'out_for_delivery',
  out_for_delivery: 'delivered'
};
if (StateTransition[order.status] !== status) {
  throw new ApiError(400, `Can't change order status from '${order.status}' to '${status}'`);
}
```

ده object بيعمل mapping: من الـ status الحالي → الـ status المسموح بيه التالي. مش في enum validation — في business logic validation.

---

#### 4. الربط بالصورة الكاملة

`POST /api/orders`:

1. `protect` → `validate(placeOrderSchema)` → `placeOrder` controller
2. Controller: `const order = await orderPlacement(userId, shippingDetails, paymentMethod)`
3. Service:
    - `startSession()` → `startTransaction()`
    - `Cart.findOne({ userId }).session(session)` — cart must be read INSIDE session
    - Loop 1: Validate all books (stock check, existence check) → build `orderItems` array with `priceAtPurchase`
    - Loop 2: `$inc` stock for all books
    - `Order.create([...], { session })` — creates order document inside transaction
    - `cart.books = []; cart.save({ session })` — clears cart
    - `commitTransaction()` — persists everything atomically
4. Controller: `ApiResponse(201, 'Order placed successfully', order)`

لو أي خطوة فشلت → `abortTransaction()` → كل الـ DB changes بتترجع → الـ user بياخد error message → الـ cart لسه كاملة.

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ Catch بيلف الـ error في ApiError(500) دايماً:**

```js
} catch (error) {
  await session.abortTransaction();
  throw new ApiError(500, 'Failed to place order', error.message);
}
```

لو الـ `error` اللي اتـ throw جوه الـ try كان `ApiError(400, 'Not enough stock...')`، الـ catch بيلفه في `ApiError(500)` وبيضيع الـ original status code والـ message الـ meaningful. الأحسن:

```js
} catch (error) {
  await session.abortTransaction();
  throw error; // re-throw as-is
}
```

**عيب 2 — الـ `StateTransition` object في الـ controller مش على الـ Model:** Business rules لازم تبقى قريبة من الـ data definition. الأصح تحطها في `models/order.js` كـ static property:

```js
OrderSchema.statics.allowedTransition = {
  processing: 'out_for_delivery',
  out_for_delivery: 'delivered'
};
```

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه هو الـ ACID وإيه علاقته بالـ MongoDB Transactions؟ ليه MongoDB كان مش بيدعم transactions قبل الـ version 4?**
2. **ليه `Order.create([{...}], { session })` بتاخد array بدل object عادي؟**
3. **ليه بنعمل Two-Phase loop (validate أولاً، ثم decrement) بدل loop واحدة؟**

---

---

## Topic 12 — Reviews Module

### `controllers/review.js` + `routes/book.js` (nested) + `routes/review.js`

---

#### 1. الكونسبت العام

الـ Reviews module فيه **Purchase Gate Pattern** — مش كل user يقدر يعمل review، بس اللي اشترى الكتاب فعلاً وستلمه. زي Amazon بالظبط — "Verified Purchase" badge.

ده بيمنع spam reviews ويحافظ على trust في الـ ratings.

---

#### 2. مثال عام بسيط

```js
// Purchase Gate — تأكد إن الـ user اشترى وستلم الكتاب ده
const hasPurchased = await Order.exists({
  userId,
  status: 'delivered',      // لازم يكون delivered (مش بس ordered)
  'items.bookId': bookId    // لازم يكون الكتاب ده في الـ order
});
if (!hasPurchased) throw new ApiError(403, 'You must purchase and receive this book first');
```

---

#### 3. شرح التطبيق

الـ `createReview` controller بالتفصيل:

```js
const hasPurchased = await Order.exists({
  userId,
  'status': 'delivered',
  'items.bookId': bookId
});
```

`'items.bookId'` — dot notation للـ querying nested array fields في MongoDB. ده بيدور في الـ `items` array على أي element عنده `bookId` = الـ value ده.

```js
try {
  const review = await Review.create({ user: userId, book: bookId, rating, comment });
} catch (err) {
  if (err.code === 11000) {
    throw new ApiError(409, 'You have already reviewed this book');
  }
  throw new ApiError(500, 'Failed to create review', err);
}
```

الـ `err.code === 11000` — MongoDB unique index violation. ده بييجي من الـ compound index `{ user: 1, book: 1 }` على الـ Review model.

الـ `isAllowedToDelete` helper:

```js
const isAllowedToToDelete = (user, review) => {
  if (user.role === 'admin') return true;
  return user._id.toString() === review.user.toString();
};
```

Note: `user._id` هو ObjectId، `review.user` هو ObjectId — لازم `.toString()` على الاتنين عشان المقارنة تشتغل. ObjectId comparison بـ `===` مش شغّال عشان هم objects مختلفة في الميموري حتى لو بنفس القيمة.

الـ `averageRating` calculation:

```js
const ratings = await Review.find({ book: bookId }).select('rating').lean();
const averageRating = ratings.length > 0
  ? (ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length).toFixed(1)
  : 0;
```

`.lean()` — بيرجع plain JavaScript objects بدل Mongoose documents. أسرع وأقل memory consumption لأن Mongoose مش بيضيف methods و getters على الـ result.

---

#### 4. الربط بالصورة الكاملة

**Review Creation Flow:** `POST /api/books/:bookId/reviews`:

1. `validate(createReviewSchema)` (order في الـ route file غلط — قبل protect!)
2. `protect` → `req.user` متاح
3. `createReview`:
    - `Book.findById(bookId)` → book exists?
    - `Order.exists({ userId, status: 'delivered', 'items.bookId': bookId })` → purchased?
    - `Review.create(...)` → duplicate? → `err.code === 11000` → `ApiError(409)`
4. `ApiResponse(201, 'Review created successfully', review)`

**Review Deletion Flow:** `DELETE /api/reviews/:id`:

1. `protect` → `req.user`
2. `deleteReview`:
    - `Review.findById(id)` → exists?
    - `isAllowedToDelete(req.user, review)` → admin or owner?
    - `Review.findByIdAndDelete(id)`
3. `ApiResponse(200, 'Review deleted successfully')`

---

#### 5. العيوب اللي في الكود

**عيب 1 — ترتيب الـ middleware في route الـ create review خاطئ:**

```js
router.post('/:bookId/reviews', validate(createReviewSchema), protect, review.createReview);
```

الـ `validate` قبل الـ `protect` — يعني الـ body بيتـ validate قبل ما نعرف مين الـ user. الأصح: `protect` → `validate` → `createReview`. لو الـ body فاشل الـ validation وكمان الـ user مش logged in، الـ user بياخد validation error بدل authentication error — confusing.

**عيب 2 — `averageRating` بيتحسب بـ application-level reduce:** كما ذكرنا — لو في 10,000 review، بتجيبهم كلهم في الـ memory. الأصح:

```js
const result = await Review.aggregate([
  { $match: { book: new mongoose.Types.ObjectId(bookId) } },
  { $group: { _id: '$book', averageRating: { $avg: '$rating' }, count: { $sum: 1 } } }
]);
const averageRating = result[0]?.averageRating?.toFixed(1) || 0;
```

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه بنستخدم `.toString()` لما بنقارن ObjectIds في JavaScript؟**
2. **إيه الـ `.lean()` في Mongoose؟ وإمتى تستخدمه ومتى لأ؟**
3. **إيه الـ Purchase Gate Pattern وليه هو أفضل من مجرد السماح لأي logged-in user بالـ review؟**

---

---

## Topic 13 — Cloudinary Integration

### `config/cloudinary.js` + `controllers/cloudinary.js` + `routes/cloudinary.js`

---

#### 1. الكونسبت العام

فيه طريقتين لرفع صورة:

1. **Server-side upload** — الـ user بيبعت الصورة للـ server، والـ server بيرفعها لـ Cloudinary.
2. **Client-side signed upload** — الـ server بيدي الـ frontend "تصريح موقّع"، والـ frontend بيرفع الصورة مباشرةً لـ Cloudinary من غير ما تعدي على الـ server.

المشروع بيستخدم **الطريقة التانية**. ليه؟ عشان الـ server مش بيتحمل الـ bandwidth بتاعة رفع الصور. Cloudinary بيستلم الصورة مباشرةً من المتصفح — أسرع وأقل load على الـ server.

بس المشكلة: الـ API key والـ secret لازم يكونوا على الـ server — مش ترسلهم للـ frontend. الحل: الـ server بيعمل **Signature** صالح لوقت محدد، يبعثه للـ frontend، والـ frontend بيستخدمه في الـ upload request.

---

#### 2. مثال عام بسيط

```js
// Server-side: generates a signature
const timestamp = Math.floor(Date.now() / 1000);
const signature = cloudinary.utils.api_sign_request(
  { timestamp, folder: 'uploads' },
  process.env.CLOUDINARY_API_SECRET // السر ده مش بيتبعتش للـ frontend
);
// بتبعت: { timestamp, signature, cloudName, apiKey, folder }
// الـ apiKey مش سر — الـ secret هو السر
```

---

#### 3. شرح التطبيق

في `config/cloudinary.js`:

```js
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});
module.exports = cloudinary;
```

ده **Singleton pattern** — الـ Cloudinary SDK بيتـ configure مرة واحدة وبيتـ export. كل مرة أي module يعمل `require('../config/cloudinary')`، بياخد نفس الـ configured instance.

في `controllers/cloudinary.js`:

```js
const getUploadSignature = async (req, res) => {
  const timestamp = Math.floor(Date.now() / 1000); // Unix timestamp in seconds
  const folder = 'book-covers';

  const signature = cloudinary.utils.api_sign_request(
    { timestamp, folder },
    process.env.CLOUDINARY_API_SECRET
  );
```

الـ `timestamp` بيتعمل بالـ seconds (مش milliseconds). `Date.now()` بيرجع milliseconds → `/1000` → `Math.floor`.

الـ signature بيعمل هاش على `{ timestamp, folder }` مع الـ API Secret. الـ Cloudinary بيعمل نفس الـ hash على الـ server بتاعه ويتأكد إنهم متطابقين — تأكيد إن الـ request جاي من server موثوق.

البيانات اللي بترجع للـ frontend:

```js
{ timestamp, signature, cloudName, apiKey, folder }
```

- `apiKey` — مش سر (زي الـ username)
- `signature` — مؤقت ومقيّد بالـ timestamp والـ folder
- `CLOUDINARY_API_SECRET` — **مش بيتبعتش خالص**

---

#### 4. الربط بالصورة الكاملة

الـ Flow الكاملة لرفع صورة غلاف كتاب:

1. Admin يفتح صفحة "Add Book" في الـ Angular frontend
2. بيختار صورة → الـ frontend بيعمل `GET /api/cloudinary-signature` مع الـ JWT
3. `protect` → `restrictTo('admin')` → `getUploadSignature`
4. الـ server بيرجع `{ timestamp, signature, cloudName, apiKey, folder }`
5. الـ frontend بيعمل POST مباشرةً لـ Cloudinary API بـ `{ file, timestamp, signature, api_key, folder }`
6. Cloudinary بيـ verify الـ signature → بيرفع الصورة → بيرجع `secure_url`
7. الـ frontend بيحط الـ `secure_url` في الـ form field `coverImage`
8. Admin يبعت `POST /api/books` مع الـ `coverImage: "https://res.cloudinary.com/..."`

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ Signature مش بتنتهي:** الـ `timestamp` بيتحدد لكن Cloudinary بيسمح برفع الصور باستخدام الـ signature لفترة معينة (عادة 1 ساعة). الكود مش بيضيف `eager_async` أو expiry control. لو الـ signature اتسرب، ممكن حد يستخدمه في رفع صور في الـ folder بتاعك.

**عيب 2 — مفيش validation على اللي بيتـ upload:** الـ server بيعطي الـ signature وبعدها مش عارف إيه اللي اتـ upload على Cloudinary. ممكن الـ frontend يرفع أي نوع ملف. الحل: إضافة `allowed_formats` في الـ signature parameters:

```js
cloudinary.utils.api_sign_request(
  { timestamp, folder, allowed_formats: 'jpg,png,webp' },
  process.env.CLOUDINARY_API_SECRET
);
```

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين Server-side upload وClient-side signed upload في Cloudinary؟ وإيه مزايا كل approach؟**
2. **ليه الـ `CLOUDINARY_API_SECRET` مش بيتبعتش للـ frontend رغم إن الـ `api_key` بيتبعت؟**
3. **إيه الـ Singleton Pattern وكيف بيتطبق في `config/cloudinary.js`؟**

---

---

## Topic 14 — Validation Architecture (Joi — Deep Dive)

### كل الـ `validations/*.js` files + `middlewares/validate.js`

---

#### 1. الكونسبت العام

الـ Validation layer زي **بوابة الأمن في المطار** — قبل ما أي request يوصل للـ controller، لازم يعدي على الـ X-ray (Joi schema). لو فيه حاجة مش تمام → يترجع. مش هيوصل للداخل.

فيه فرق مهم بين **Joi validation** (middleware layer) و **Mongoose validation** (model layer):

||Joi|Mongoose|
|---|---|---|
|يشتغل|قبل ما يوصل للـ DB|لحظة الـ save للـ DB|
|هدفه|Clean & safe input|DB-level integrity|
|Error messages|Custom, user-friendly|Generic|
|يتكلم عن|Business rules|Schema rules|

---

#### 2. مثال عام بسيط

```js
// الـ Higher-Order Function في validate.js
const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, {
    abortEarly: false,  // جمّع كل الأخطاء مع بعض
    stripUnknown: true  // شيل الـ fields الزيادة
  });
  if (error) throw new ApiError(400, error.details.map(d => d.message).join(', '));
  req.body = value; // ← الـ sanitized و coerced data
  next();
};
```

---

#### 3. شرح التطبيق

**`validate.js` — Higher-Order Function:**

`validate(schema)` بترجع function. الـ function دي هي الـ middleware. ده pattern اسمه **Function Factory** أو **Higher-Order Function**.

ليه مش بنكتب middleware مباشرةً؟ عشان كل route محتاج schema مختلفة. بدل ما تعمل `validateRegister`, `validateLogin`, `validateUpdateProfile` — بتعمل `validate(registerSchema)`, `validate(loginSchema)`.

`abortEarly: false`:

- Default Joi behavior: يوقف عند أول error.
- مع `abortEarly: false`: يكمل على الـ object كله ويجمع **كل** الأخطاء.
- أفضل UX: "الاسم قصير جداً، والـ email غلط، والـ password ضعيف" في message واحدة.

`stripUnknown: true`:

- أي field في الـ `req.body` مش موجود في الـ schema → بيتشال.
- Security layer: يمنع **Mass Assignment Attack**.
- بعد الـ validation، `req.body` بيتحل محله الـ `value` المنظّف من Joi.

**Auth Validation — `validations/auth.js`:**

```js
password: Joi.string()
  .min(8)
  .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  .required()
  .messages({ 'string.pattern.base': 'Password needs uppercase, lowercase, and a number' })
```

الـ `.pattern()` مع `.messages()` — بتـ override الـ error message للـ pattern failure. بدل الـ generic "string.pattern.base" message، بترجع human-readable message.

```js
const updateProfileSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName: Joi.string().min(2).max(50),
  dob: Joi.date().max('now')
}).min(1); // 👈 لازم على الأقل field واحدة
```

`.min(1)` على الـ object schema — مش على الـ string. بتقول: "الـ request body لازم يحتوي على field واحدة على الأقل". ده بيمنع PATCH request فارغة.

**Book Validation — `validations/book.js`:**

```js
const objectId = joi.string().hex().length(24);
```

Custom ObjectId validator — `hex()` بتتأكد كل الحروف hexadecimal (0-9, a-f)، `length(24)` بتتأكد الطول. ده لأن Joi مش بيعرف MongoDB ObjectId by default.

```js
category: objectId.allow(null) // في الـ update — ممكن تحط null عشان تشيل الـ category
```

**Author Validation — `validations/author.js`:**

```js
}).unknown(false); // strict — أي field زيادة = error
```

مقارنةً بـ `stripUnknown: true` في الـ middleware: هنا الـ schema نفسها بترفض الـ extra fields. الـ `stripUnknown` بيشيلهم في صمت. الـ `unknown(false)` بيرجع error. المؤلفون team قرروا إنهم يكونوا أكثر strictness.

---

#### 4. الربط بالصورة الكاملة

`POST /api/auth/register`:

1. Request يوصل بـ body: `{ email, firstName, lastName, dob, password, hackerField: "xss" }`
2. `validate(registerSchema)` middleware:
    - `schema.validate(req.body, { abortEarly: false, stripUnknown: true })`
    - `hackerField` → stripped (not in schema)
    - validation passes → `req.body = { email, firstName, lastName, dob, password }` (clean)
3. `register` controller يستقبل `req.body` نظيف وآمن
4. `User.create(req.body)` — لو حاجة فاتت الـ Joi، الـ Mongoose schema كـ second line of defense

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ `validate` middleware بيـ validate الـ body بس:** الـ `req.params` (زي `/:id`) والـ `req.query` (زي `?page=2`) مش بيتـ validate. لو حد بعت `?page=abc`، `Number('abc')` = `NaN`، وده ممكن يعمل مشاكل. الحل: تمدد الـ `validate` middleware عشان يقبل `'body' | 'params' | 'query'` كـ option.

**عيب 2 — الـ ObjectId validation في Joi مش بتتأكد من الـ Structure الفعلية:** `hex().length(24)` بتـ validate الـ format بس. بس ممكن يكون ObjectId مش موجود في الـ DB. ده الـ Referential Integrity check اللي لازم يكون في الـ controller — Joi مش المكان الصح له.

---

#### 6. أسئلة انترفيو "جونيور"

1. **إيه الفرق بين `abortEarly: false` و `abortEarly: true` في Joi؟ وإيه أفضل من ناحية UX؟**
2. **إيه الـ Mass Assignment Attack؟ وكيف `stripUnknown: true` بتساعد في منعه؟**
3. **إيه الفرق بين Joi validation وMongoose validation؟ وليه بنستخدم الاتنين مع بعض؟**

---

---

## Topic 15 — Routing Architecture & Project Structure

### `routes/index.js` + `app.js` + الـ Barrel Exports

---

#### 1. الكونسبت العام

تخيل إن الـ API زي **مبنى إداري كبير**. عندك باب رئيسي (`app.js`) — اللي جواه reception (الـ global middlewares). بعدين في الـ lobby في لافتة بتقولك: "إدارة الكتب — الدور 3، إدارة المستخدمين — الدور 1" (`routes/index.js`). وكل دور عنده أوضاته الداخلية (الـ sub-routes زي `routes/book.js`).

الـ **Barrel Export pattern** هو: بدل ما كل module يعرف مكان كل file، في ملف وحيد (`index.js`) بيجمعهم — وكل حد بيعمل `require` من المجلد مباشرةً.

---

#### 2. مثال عام بسيط

```js
// بدون Barrel — messy
const ApiError = require('../utils/ApiError');
const ApiResponse = require('../utils/ApiResponse');
const paginate = require('../utils/pagination');

// مع Barrel (utils/index.js) — clean
const { ApiError, ApiResponse, paginate } = require('../utils');
```

---

#### 3. شرح التطبيق

**الـ Two-Level Routing:**

```
app.js                    →  app.use('/api', routes)
routes/index.js           →  router.use('/books', require('./book'))
routes/book.js            →  router.get('/', getAllBooks)
                               router.post('/:bookId/reviews', ...)
```

URL الكامل: `/api` + `/books` + `/` = `/api/books`

**الـ Middleware Order في `app.js`:**

```js
app.use(cors({ origin: [...], credentials: true }));
app.use(express.json());
app.use(httpLogger);
app.use(rateLimiter);
app.use('/api', routes);
app.use(errorHandler);
```

الترتيب مهم جداً:

1. **CORS** — أول حاجة. لو request غير مسموح بيه، نرفضه قبل أي processing.
2. **express.json()** — بيحوّل الـ raw body لـ `req.body`. لازم قبل أي route يحتاج `req.body`.
3. **httpLogger** — بيسجل كل request/response. قبل الـ routes عشان يلقط كل حاجة.
4. **rateLimiter** — بيفرز الـ IPs قبل ما يوصلوا للـ routes.
5. **routes** — الـ actual business logic.
6. **errorHandler** — **لازم يكون آخر حاجة** — بيستقبل الـ errors من كل الـ routes.

**ليه `errorHandler` لازم يكون آخر middleware؟**

Express بيتعرف على الـ Error Handler من الـ 4-argument signature: `(err, req, res, next)`. لو حطيته قبل الـ routes، الـ routes التانية مش هتتـ register بشكل صحيح. والأهم: الـ `next(err)` من الـ routes بيدور على أول error handler بعد الـ route — لو هو قبل، مش هيلاقيه.

**الـ Barrel Exports:**

```js
// middlewares/index.js
module.exports = {
  protect,
  restrictTo,
  errorHandler,
  validate,
  httpLogger,
  rateLimiter
};
```

بيسمح بـ:

```js
const { protect, restrictTo, validate } = require('../middlewares');
```

بدل 3 requires منفصلين.

**الـ CORS Configuration:**

```js
cors({
  origin: ['http://localhost:4200', 'https://your-frontend.vercel.app'],
  credentials: true
})
```

- `credentials: true` — بيسمح بإرسال cookies و authorization headers في الـ cross-origin requests.
- `origin` محدد — مش `'*'`. لأن `credentials: true` مش بيشتغل مع `origin: '*'` — CORS spec بترفضه.

---

#### 4. الربط بالصورة الكاملة

Request life cycle من أوله لآخره:

```
Client
  ↓
CORS check (app.js)
  ↓
Body parsing — express.json()
  ↓
httpLogger — logs the request
  ↓
rateLimiter — IP check (Map lookup)
  ↓
/api → routes/index.js
  ↓
/books → routes/book.js
  ↓
Route matching: GET / → getAllBooks
  ↓
Controller runs → calls paginate() → DB query
  ↓
Controller returns → res.json(new ApiResponse(...))
  ↓
httpLogger — logs the response
  ↓
Client receives JSON
```

لو error حصل في أي خطوة:

```
throw new ApiError(...)
  ↓
Express catches it (Express 5 auto-catches async errors)
  ↓
Passes to errorHandler(err, req, res, next)
  ↓
devError or productionError
  ↓
Client receives error JSON
```

ملاحظة مهمة: المشروع بيستخدم **Express 5** (`"express": "^5.2.1"`). في Express 5، الـ async errors في routes بيتـ catch تلقائياً وبيتـ forward للـ error handler. في Express 4، كنت محتاج تعمل `try/catch` في كل controller أو تستخدم `express-async-errors` package.

---

#### 5. العيوب اللي في الكود

**عيب 1 — الـ errorHandler بيتـ register مرتين:**

في `app.js`:

```js
app.use(errorHandler);
```

وفي `index.js`:

```js
app.use(errorHandler);
```

بيتـ register مرتين! Express 5 كويّس وده مش هيعمل مشكلة واضحة، بس redundant وممكن يسبب double-responses في بعض edge cases. المكان الصح ليه واحد بس — في `app.js` وبس.

**عيب 2 — الـ CORS origin hardcoded:**

```js
origin: ['http://localhost:4200', 'https://your-frontend.vercel.app']
```

`'https://your-frontend.vercel.app'` — ده TODO comment في الكود الفعلي. لو حد deploy من غير ما يغير ده، الـ production frontend مش هيشتغل. الأصح: `origin: process.env.ALLOWED_ORIGINS.split(',')` من الـ `.env`.

---

#### 6. أسئلة انترفيو "جونيور"

1. **ليه الـ `errorHandler` لازم يكون آخر middleware في الـ app؟ إيه اللي هيحصل لو حطيناه في الأول؟**
2. **إيه الـ Barrel Export pattern وإيه فايدته؟**
3. **إيه الفرق بين Express 4 وExpress 5 في التعامل مع الـ async errors؟ وليه ده مهم للكود بتاعنا؟**

---

# 🎯 ملخص إجمالي — أهم النقاط

|Topic|أهم Pattern|أخطر عيب|
|---|---|---|
|Book Model|Virtual fields + Text Index|`toJSON: virtuals` مش كافية دايماً|
|Author Model|Referenced relationship|N+1 Query Problem|
|Category Model|Cascade Null on delete|مفيش Transaction على الـ delete|
|Cart Model|Embedded array + Upsert pattern|Race condition في `addItem`|
|Order Model|`priceAtPurchase` snapshot + State Machine|Catch بيلف الـ original error|
|Review Model|Compound Unique Index|`averageRating` بـ application reduce|
|Books Module|Dynamic Query Building|`req.body` مباشرةً في `create`|
|Authors Module|`Book.exists()` + guard before delete|N+1 في `findAllAuthors`|
|Categories Module|Cascade Null pattern|مفيش Atomicity|
|Cart Module|`router.use(protect)` + nested populate|Extra DB round trip|
|**Orders Module**|**MongoDB ACID Transaction**|**Catch بيخفي original error**|
|Reviews Module|Purchase Gate + `err.code === 11000`|Middleware order خاطئ في route|
|Cloudinary|Signed Upload (server-less bandwidth)|مفيش file type restriction|
|Validation (Joi)|Higher-Order Function + `stripUnknown`|مش بيـ validate params وquery|
|Routing|Two-level routing + Barrel exports|errorHandler registered مرتين|

---

> 🔥 **خلاص! Part 2 كامل. لو عندك أي topic عايز نعمق فيه أكتر أو تتدرب على الأسئلة — قولي!**