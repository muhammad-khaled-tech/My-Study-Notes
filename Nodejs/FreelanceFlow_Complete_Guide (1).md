# FreelanceFlow API — Complete Build Guide
> **Stack:** Node.js · Express · MongoDB (Mongoose) · JWT  
> **Timeline:** Thursday Morning → Friday Morning (~24 hrs)  
> **Pattern:** Each phase teaches you the concepts you need, then immediately applies them in the project.

---

## The Project: FreelanceFlow

A **Freelancer Project Marketplace API** — a simplified Upwork backend.

- **Clients** post projects with a budget, required skills, and a deadline.
- **Freelancers** browse open projects and submit proposals.
- When a Client **accepts a proposal**, a cascade fires automatically via a Mongoose hook: all competing proposals are rejected, and the project moves to `in_progress`.
- After completion, Clients leave **Reviews** for Freelancers.
- Both sides have a **stats dashboard** endpoint powered by MongoDB aggregation.

### Why this project for an interview?

| Feature | Concept it demonstrates |
|---|---|
| Role-based JWT (Client / Freelancer) | Authentication & Authorization |
| Project / Proposal lifecycle | Business Logic & State Machines |
| Auto-cascade on proposal accept | Mongoose `post('save')` Hook |
| Password hashing in model | Mongoose `pre('save')` Hook |
| Global error handler | Express 4-param Error Middleware |
| Stats endpoint | MongoDB Aggregation Pipeline |
| Soft-delete on Projects | Mongoose Query Middleware |

---

## Final Folder Structure

```
freelance-flow/
├── src/
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── project.controller.js
│   │   ├── proposal.controller.js
│   │   └── review.controller.js
│   ├── middlewares/
│   │   ├── auth.middleware.js
│   │   └── error.middleware.js
│   ├── models/
│   │   ├── User.model.js
│   │   ├── Project.model.js
│   │   ├── Proposal.model.js
│   │   └── Review.model.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── project.routes.js
│   │   ├── proposal.routes.js
│   │   └── review.routes.js
│   ├── utils/
│   │   ├── AppError.js
│   │   └── catchAsync.js
│   └── app.js
├── .env
└── server.js
```

---

## Phase 0 — Kickoff (~30 min)

```bash
mkdir freelance-flow && cd freelance-flow
npm init -y
npm install express mongoose dotenv bcryptjs jsonwebtoken helmet morgan
npm install --save-dev nodemon
```

**`package.json` scripts:**
```json
"scripts": {
  "start": "node server.js",
  "dev":   "nodemon server.js"
}
```

**`.env`:**
```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/freelanceflow
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRES_IN=7d
NODE_ENV=development
```

---

## Phase 1 — Foundation: Express App + Global Error Handling

---

### Concept: What Express Is and How It Works

Node.js ships with a built-in `http` module. It can create servers, but it is raw and verbose — you write giant `if/else` chains to handle different routes, manually parse request bodies, manually set headers. It gets out of hand fast.

Express is a thin layer that wraps Node's `http` module. When you write `const app = express()`, you get back a function — that function IS the request handler you'd pass to `http.createServer()`. Express adds a routing system, automatic body parsing, and the middleware pipeline on top of that.

Understanding this means understanding that **Express itself does nothing until you tell it what to do** — by registering middleware and routes in a specific order.

---

### Concept: The Request-Response Cycle

Every HTTP interaction follows one rule: a request comes in, passes through a chain of functions, and eventually one of those functions sends a response. Once a response is sent, the cycle is over — nothing after it runs.

```
Incoming request
      │
      ▼
  Middleware 1 → calls next() → Middleware 2 → calls next() → Route Handler
                                                                     │
                                                               sends response
                                                               cycle ends ✓
```

If any function in the chain calls `next(error)` instead of `next()`, Express skips all remaining normal middleware and jumps directly to the **Error Handler** — a special 4-param middleware at the very end.

---

### Concept: The `req` and `res` Objects

These are passed into every middleware and route handler.

`req` carries everything about the incoming request:
```javascript
req.params      // URL params:    /projects/:id  →  req.params.id
req.query       // Query string:  ?sort=newest   →  req.query.sort
req.body        // Parsed JSON body (requires express.json() middleware)
req.headers     // HTTP headers:  req.headers['authorization']
req.method      // 'GET', 'POST', 'PATCH', 'DELETE'
req.originalUrl // Full URL path

// You can ATTACH your own data — it travels to all downstream middleware
req.user = currentUser; // set in protect middleware, read in controllers
```

`res` sends the outgoing response:
```javascript
res.status(200).json({ data: ... }) // Most common — send JSON
res.status(204).send()              // No content (used after DELETE)
// Rule: send ONE response per request — calling res.json() twice causes an error
```

---

### Concept: Middleware

A middleware is any function with this signature:

```javascript
function myMiddleware(req, res, next) {
  // do something
  next(); // pass control forward — REQUIRED unless you send a response here
}
```

`next` is provided by Express. Calling it passes control to the next function in the chain. **If you never call `next()` and never send a response, the request hangs forever.** This is the single most common Express bug.

Middleware is registered with `app.use()`. Order of registration = order of execution. Global middleware (no path argument) runs for every request. Route-specific middleware runs only for its route.

```javascript
app.use(helmet());           // runs first, every request
app.use(express.json());     // runs second, every request

app.get('/users', handler);  // runs only for GET /users
```

---

### Concept: MVC Architecture

MVC separates your code into three responsibilities:

- **Model** — Mongoose schemas. Owns the data structure, validation rules, and data-related business logic (hooks, methods). Nothing else.
- **Controller** — the logic layer. Receives the request, calls the model, sends the response. Nothing else.
- **Routes** — map URLs + HTTP verbs to controller functions. Nothing else.

The point: each file has exactly one job. Controllers don't define schemas. Models don't send HTTP responses. When something breaks, you know exactly which layer to look in.

---

### Concept: Global Error Handling

Without centralized error handling, every controller looks like this:

```javascript
// The wrong way — try/catch copy-pasted everywhere
app.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'Not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message }); // duplicated in every route
  }
});
```

The solution has three pieces:

**`catchAsync(fn)`** — a wrapper that removes try/catch from every async controller. It wraps the function and forwards any rejected promise to `next()`:
```javascript
const catchAsync = (fn) => (req, res, next) => fn(req, res, next).catch(next);
```

**`AppError` class** — extends the native `Error` with a `statusCode` and an `isOperational` flag. The flag means "I created this error intentionally — safe to send its message to the client." Unexpected bugs don't have this flag, so the handler sends a generic response instead of leaking internals.

**The Global Error Handler** — a middleware with exactly **4 parameters** `(err, req, res, next)`. Express identifies it as an error handler because of the leading `err` param. It must be **registered last**, after all routes. Every `next(err)` call anywhere in the app ends up here.

---

### Game Plan

```
server.js
  ├── dotenv.config() — must be first, env vars needed by everything
  ├── process.on('uncaughtException') — register before anything runs
  ├── mongoose.connect(MONGO_URI)
  ├── const server = app.listen(PORT)
  └── process.on('unhandledRejection') — graceful shutdown

app.js
  ├── app.use(helmet())
  ├── app.use(express.json({ limit: '10kb' }))
  ├── app.use(morgan('dev'))  — dev only
  ├── app.use('/api/v1/auth', authRoutes)
  ├── app.use('/api/v1/projects', projectRoutes)
  ├── app.use('/api/v1/proposals', proposalRoutes)
  ├── app.use('/api/v1/reviews', reviewRoutes)
  ├── app.all('*') → next(new AppError('Route not found', 404))
  └── app.use(globalErrorHandler)  ← MUST be last

utils/AppError.js
  └── class AppError extends Error
        this.statusCode, this.status ('fail'/'error'), this.isOperational = true

utils/catchAsync.js
  └── (fn) => (req, res, next) => fn(req, res, next).catch(next)

middlewares/error.middleware.js
  ├── handleCastError()       → invalid ObjectId  → AppError 400
  ├── handleDuplicateKey()    → code 11000        → AppError 400
  ├── handleValidationError() → schema failures   → AppError 400
  ├── handleJWTError()        → bad signature     → AppError 401
  ├── handleJWTExpired()      → expired token     → AppError 401
  ├── sendErrorDev()          → full details + stack
  ├── sendErrorProd()         → isOperational ? real message : 'Something went wrong'
  └── globalErrorHandler(err, req, res, next) — checks NODE_ENV, routes to sender
```

---

### Reference Implementation

<details>
<summary>Phase 1 Code</summary>

**`server.js`**
```javascript
const dotenv = require('dotenv');
dotenv.config(); // Must be first — env vars must exist before anything reads them

const mongoose = require('mongoose');
const app      = require('./src/app');

const PORT = process.env.PORT || 5000;

// Catch synchronous crashes that happened before Express could handle them
process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down...', err.name, err.message);
  process.exit(1);
});

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.error('❌ MongoDB Connection Failed:', err));

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

// Catch async crashes (e.g., DB goes down mid-runtime)
// Close the server gracefully first — lets in-flight requests finish
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! Shutting down...', err.name, err.message);
  server.close(() => process.exit(1));
});
```

**`src/app.js`**
```javascript
const express = require('express');
const helmet  = require('morgan');
const morgan  = require('morgan');

const authRoutes     = require('./routes/auth.routes');
const projectRoutes  = require('./routes/project.routes');
const proposalRoutes = require('./routes/proposal.routes');
const reviewRoutes   = require('./routes/review.routes');
const { globalErrorHandler } = require('./middlewares/error.middleware');
const AppError = require('./utils/AppError');

const app = express();

// --- Global Middlewares ---
app.use(require('helmet')());             // Sets ~15 security HTTP headers automatically
app.use(express.json({ limit: '10kb' })); // Parse JSON body. Limit prevents giant payload attacks.

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev')); // Logs: "GET /api/v1/users 200 12ms"
}

// --- Routes ---
app.use('/api/v1/auth',      authRoutes);
app.use('/api/v1/projects',  projectRoutes);
app.use('/api/v1/proposals', proposalRoutes);
app.use('/api/v1/reviews',   reviewRoutes);

// --- 404 Handler: catches any path that didn't match a route above ---
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

// --- Global Error Handler: MUST be the last middleware registered ---
app.use(globalErrorHandler);

module.exports = app;
```

**`src/utils/AppError.js`**
```javascript
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);

    this.statusCode = statusCode;
    // 'fail' for 4xx (client's fault), 'error' for 5xx (server's fault)
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    // true = "I made this error on purpose" — safe to expose to client
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;
```

**`src/utils/catchAsync.js`**
```javascript
// Wraps any async controller. If it throws or rejects, .catch(next)
// forwards the error to Express's global error handler automatically.
// Zero try/catch blocks needed in any controller.
const catchAsync = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};

module.exports = catchAsync;
```

**`src/middlewares/error.middleware.js`**
```javascript
const AppError = require('../utils/AppError');

// Convert Mongoose/JWT errors into clean AppErrors the client can understand

// Someone passed a non-ObjectId string as a URL param: /api/projects/not-an-id
const handleCastErrorDB = (err) =>
  new AppError(`Invalid ${err.path}: ${err.value}.`, 400);

// Duplicate value on a unique-indexed field: e.g., email already exists
const handleDuplicateFieldsDB = (err) => {
  const field = Object.keys(err.keyValue)[0];
  return new AppError(`Duplicate value for '${field}'. Please use another value.`, 400);
};

// Schema validation failed on .save() or .create()
const handleValidationErrorDB = (err) => {
  const errors = Object.values(err.errors).map((el) => el.message);
  return new AppError(`Invalid input data. ${errors.join('. ')}`, 400);
};

const handleJWTError        = () => new AppError('Invalid token. Please log in again!', 401);
const handleJWTExpiredError = () => new AppError('Your token has expired! Please log in again.', 401);

const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status:  err.status,
    message: err.message,
    error:   err,
    stack:   err.stack,
  });
};

const sendErrorProd = (err, res) => {
  if (err.isOperational) {
    res.status(err.statusCode).json({ status: err.status, message: err.message });
  } else {
    console.error('💥 PROGRAMMING ERROR:', err);
    res.status(500).json({ status: 'error', message: 'Something went very wrong!' });
  }
};

// 4 parameters = Express treats this as an error handler, not normal middleware
const globalErrorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status     = err.status     || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else {
    let error = { ...err, message: err.message };
    if (error.name === 'CastError')         error = handleCastErrorDB(error);
    if (error.code === 11000)               error = handleDuplicateFieldsDB(error);
    if (error.name === 'ValidationError')   error = handleValidationErrorDB(error);
    if (error.name === 'JsonWebTokenError') error = handleJWTError();
    if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();
    sendErrorProd(error, res);
  }
};

module.exports = { globalErrorHandler };
```

</details>

---

## Phase 2 — Authentication & Authorization

---

### Concept: What Mongoose Is

MongoDB is schemaless — it accepts any document in any shape with no complaints. Mongoose wraps the MongoDB driver and adds structure: schemas define the shape and rules, models give you query methods, hooks let you inject logic before/after operations, and validators enforce rules before any write hits the database.

The chain: your code → Mongoose (schemas, validation, hooks) → MongoDB driver → MongoDB server.

---

### Concept: Schemas and Models

A **Schema** is a blueprint. It defines fields, types, and rules — but does not touch the database. A **Model** is compiled from a schema and represents a MongoDB collection. It has all the query methods: `find`, `create`, `findByIdAndUpdate`, `deleteOne`, etc.

Key field options you'll use constantly:

```javascript
const userSchema = new mongoose.Schema({
  name: {
    type:      String,
    required:  [true, 'Name is required'],  // [bool, custom error message]
    trim:      true,                         // strip whitespace automatically
    maxlength: [50, 'Name cannot exceed 50 characters'],
  },
  email: {
    type:      String,
    unique:    true,     // creates a DB-level unique index — NOT a Mongoose validator
                         // duplicates cause MongoDB error code 11000 (handled in error.middleware)
    lowercase: true,     // transforms value to lowercase before saving
  },
  password: {
    type:   String,
    select: false,       // NEVER returned in queries by default
                         // to include it: User.findOne().select('+password')
  },
  role: {
    type:    String,
    enum:    { values: ['client', 'freelancer'], message: 'Role must be client or freelancer' },
    default: 'freelancer',
  },
}, { timestamps: true }); // auto-adds createdAt and updatedAt
```

Query methods return **lazy query objects** — the DB isn't hit until you `await`:
```javascript
const users = await User.find({ role: 'client' }) // builds query
  .select('name email')   // only return these fields
  .sort('-createdAt')     // newest first (- prefix = descending)
  .limit(10);             // max 10 — database hit happens HERE on await
```

---

### Concept: Mongoose Hooks (`pre` and `post`)

Hooks run automatically before or after specific operations. Two categories:

**Document middleware** — `pre('save')` and `post('save')`. Triggered by `.save()` and `.create()`. Inside these, `this` is the document:

```javascript
userSchema.pre('save', async function (next) {
  // 'this' = the user document about to be saved
  if (!this.isModified('password')) return next(); // skip if password unchanged
  this.password = await bcrypt.hash(this.password, 12);
  next(); // always call next() — omitting it hangs the save forever
});
```

**Query middleware** — runs before/after `find`, `findOne`, `findById`, etc. `this` is the query object, not a document:

```javascript
userSchema.pre(/^find/, function (next) {
  // 'this' = the Query object — add an extra filter to every find query
  this.find({ active: { $ne: false } }); // never return deactivated users
  next();
});
```

**Critical rule:** `findByIdAndUpdate` and `updateMany` do NOT trigger `pre('save')`. They bypass the entire Mongoose document lifecycle. If hooks must run, use `.save()`. If you use `findByIdAndUpdate`, pass `{ runValidators: true }` to at least run schema validators.

---

### Concept: Instance Methods

Instance methods are functions defined on the schema that live on individual document instances. `this` inside them is the specific document:

```javascript
userSchema.methods.correctPassword = async function (candidatePassword) {
  // 'this.password' is the stored hash on this specific user document
  return await bcrypt.compare(candidatePassword, this.password);
};

// Usage — called on a document instance, not the Model:
const user = await User.findOne({ email }).select('+password');
const match = await user.correctPassword('mypassword123');
```

---

### Concept: JWT Authentication

After a successful login, the server creates a signed token and sends it back. The client attaches this token to every subsequent request. The server verifies the signature — no session stored anywhere.

A JWT has three dot-separated parts:
- **Header** — `{ "alg": "HS256" }` — the signing algorithm
- **Payload** — `{ "id": "64abc...", "iat": 1700000, "exp": 1700604800 }` — the data
- **Signature** — `HMACSHA256(base64(header) + "." + base64(payload), SECRET_KEY)`

If anyone tampers with the payload (changes the `id` to someone else's), the signature no longer matches. `jwt.verify()` throws a `JsonWebTokenError`, which the global error handler catches and converts to a 401.

The client sends the token in every request: `Authorization: Bearer eyJhbGci...`

---

### Concept: The `protect` Middleware and `restrictTo` Factory

`protect` handles **authentication** — verifying who you are:
1. Extract the token from the `Authorization` header
2. Verify signature and expiry with `jwt.verify()`
3. Confirm the user still exists in the database
4. Attach the user to `req.user` for all downstream handlers

`restrictTo` handles **authorization** — verifying what you're allowed to do. It is a **factory function** — a function that returns a middleware. The returned middleware "closes over" the roles array:

```javascript
exports.restrictTo = (...roles) => {
  return (req, res, next) => {     // this function remembers 'roles'
    if (!roles.includes(req.user.role)) return next(new AppError('Forbidden', 403));
    next();
  };
};

// Used on routes — protect runs first, attaches req.user, then restrictTo checks the role:
router.post('/', protect, restrictTo('client'), createProject);
```

---

### Game Plan

```
User.model.js
  ├── Fields: name, email (unique, lowercase), password (select:false),
  │           role (enum: client|freelancer, default:'freelancer'),
  │           active (Boolean, select:false, default:true)
  ├── Schema options: timestamps: true
  ├── pre('save') hook:
  │     if (!this.isModified('password')) return next()
  │     this.password = await bcrypt.hash(this.password, 12)
  ├── pre(/^find/) hook:
  │     this.find({ active: { $ne: false } })
  └── methods.correctPassword(candidate, hashed) → bcrypt.compare()

auth.controller.js — register:
  1. Destructure { name, email, password, role } from req.body
  2. User.findOne({ email }) → exists → AppError 400
  3. User.create({ ... }) → pre-save hook hashes password automatically
  4. jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn })
  5. user.password = undefined (strip from response)
  6. res.status(201).json({ token, data: { user } })

auth.controller.js — login:
  1. Check email + password present → AppError 400
  2. User.findOne({ email }).select('+password')
  3. if (!user || !(await user.correctPassword(...))) → AppError 401
     (check together — don't reveal whether the email exists)
  4. sign + send token

auth.middleware.js — protect:
  1. Read Authorization header → split 'Bearer <token>'
  2. No token → AppError 401
  3. await promisify(jwt.verify)(token, JWT_SECRET) → decoded or throws
  4. User.findById(decoded.id) → null → AppError 401
  5. req.user = currentUser → next()

auth.middleware.js — restrictTo:
  (...roles) => (req, res, next) =>
    !roles.includes(req.user.role) → AppError 403
    else next()
```

---

### Reference Implementation

<details>
<summary>Phase 2 Code</summary>

**`src/models/User.model.js`**
```javascript
const mongoose = require('mongoose');
const bcrypt   = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type:      String,
      required:  [true, 'Please provide your name'],
      trim:      true,
      maxlength: [50, 'Name cannot exceed 50 characters'],
    },
    email: {
      type:      String,
      required:  [true, 'Please provide your email'],
      unique:    true,
      lowercase: true,
      match:     [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    password: {
      type:      String,
      required:  [true, 'Please provide a password'],
      minlength: [8, 'Password must be at least 8 characters'],
      select:    false,
    },
    role: {
      type:    String,
      enum:    { values: ['client', 'freelancer'], message: 'Role must be client or freelancer' },
      default: 'freelancer',
    },
    active: { type: Boolean, default: true, select: false },
  },
  { timestamps: true }
);

// HOOK: hash password before any save where password was modified
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// QUERY MIDDLEWARE: automatically exclude deactivated users from all find queries
userSchema.pre(/^find/, function (next) {
  this.find({ active: { $ne: false } });
  next();
});

// INSTANCE METHOD: compare a plaintext password to the stored hash
userSchema.methods.correctPassword = async function (candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
};

module.exports = mongoose.model('User', userSchema);
```

**`src/controllers/auth.controller.js`**
```javascript
const jwt        = require('jsonwebtoken');
const User       = require('../models/User.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

const createSendToken = (user, statusCode, res) => {
  const token   = signToken(user._id);
  user.password = undefined; // strip from the in-memory document before JSON serialization
  res.status(statusCode).json({ status: 'success', token, data: { user } });
};

exports.register = catchAsync(async (req, res, next) => {
  const { name, email, password, role } = req.body;

  // Manual check → better error message than the raw MongoDB 11000 duplicate key error
  const existing = await User.findOne({ email });
  if (existing) return next(new AppError('Email already in use.', 400));

  const newUser = await User.create({ name, email, password, role });
  createSendToken(newUser, 201, res);
});

exports.login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;
  if (!email || !password) return next(new AppError('Please provide email and password!', 400));

  // .select('+password') overrides the select:false in the schema for this query only
  const user = await User.findOne({ email }).select('+password');

  // Check both at once — separate checks reveal whether the email exists (security risk)
  if (!user || !(await user.correctPassword(password, user.password))) {
    return next(new AppError('Incorrect email or password', 401));
  }

  createSendToken(user, 200, res);
});
```

**`src/middlewares/auth.middleware.js`**
```javascript
const jwt           = require('jsonwebtoken');
const { promisify } = require('util'); // built-in Node.js — converts callback APIs to Promises
const User          = require('../models/User.model');
const AppError      = require('../utils/AppError');
const catchAsync    = require('../utils/catchAsync');

exports.protect = catchAsync(async (req, res, next) => {
  // 1. Extract token
  let token;
  if (req.headers.authorization?.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  if (!token) return next(new AppError('You are not logged in!', 401));

  // 2. Verify signature and expiry
  // promisify wraps jwt.verify (callback-style) so we can await it
  // Throws JsonWebTokenError or TokenExpiredError if invalid — caught by catchAsync
  const decoded = await promisify(jwt.verify)(token, process.env.JWT_SECRET);

  // 3. Confirm user still exists (account may have been deleted after token was issued)
  const currentUser = await User.findById(decoded.id);
  if (!currentUser) return next(new AppError('The user for this token no longer exists.', 401));

  // 4. Attach user to request for all downstream handlers
  req.user = currentUser;
  next();
});

// Factory function: returns a middleware with the allowed roles baked in via closure
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(new AppError('You do not have permission to perform this action', 403));
    }
    next();
  };
};
```

**`src/routes/auth.routes.js`**
```javascript
const express        = require('express');
const { register, login } = require('../controllers/auth.controller');

const router = express.Router();
router.post('/register', register);
router.post('/login',    login);

module.exports = router;
```

</details>

---

## Phase 3 — Projects & Proposals: Business Logic

---

### Concept: Business Logic vs CRUD

CRUD is just moving data in and out of a database. Business logic is the rules that control *how* data is allowed to change. In FreelanceFlow:

- A project's lifecycle: `open → in_progress → completed / cancelled`
- A proposal's lifecycle: `pending → accepted / rejected`
- When a proposal is accepted: every other pending proposal on that project must be rejected automatically, and the project must move to `in_progress` — without the controller doing anything extra

That last rule belongs in a Mongoose `post('save')` hook on the Proposal model, not in the controller. If you put it in the controller, it only runs when that route is called. A background job, an admin tool, or any other code path that accepts a proposal would silently bypass it. When the rule lives in a hook, it runs unconditionally — regardless of where the save was triggered.

---

### Concept: Custom Validators and Cross-Field Validation

Field-level validators check one field in isolation. For rules that compare two fields (e.g., "max budget must exceed min budget"), use a `pre('save')` hook — it has access to the entire document via `this`:

```javascript
projectSchema.pre('save', function (next) {
  if (this.budget.max <= this.budget.min) {
    return next(new Error('Maximum budget must exceed minimum budget'));
    // Passing an error to next() aborts the save — document is NOT written to DB
  }
  next();
});
```

Single-field custom logic uses the `validate` property:
```javascript
deadline: {
  type: Date,
  validate: {
    validator: function (val) { return val > Date.now(); },
    message: 'Deadline must be a future date',
  },
}
```

---

### Concept: Virtual Populate (Reverse Relationship)

The `Project` document doesn't store proposal IDs. Each `Proposal` stores a `project` reference. To get a project's proposals without storing IDs on the project, you define a **virtual**:

```javascript
projectSchema.virtual('proposals', {
  ref:          'Proposal', // look in the Proposal collection
  foreignField: 'project',  // find Proposals where 'project' field equals...
  localField:   '_id',      // ...this project's '_id'
});
```

Nothing is stored in the database. When you call `.populate('proposals')`, Mongoose runs a second query behind the scenes. Requires `toJSON: { virtuals: true }` in schema options for the result to appear in `res.json()`.

---

### Concept: Compound Indexes

A regular unique index enforces uniqueness on one field. A **compound unique index** enforces uniqueness on a *combination* of fields:

```javascript
proposalSchema.index({ project: 1, freelancer: 1 }, { unique: true });
// Same freelancer, different projects   ✓ (allowed)
// Different freelancers, same project   ✓ (allowed)
// Same freelancer + same project again  ✗ (MongoDB throws code 11000)
```

The controller catches this first with a clear error message, but the index is the DB-level guarantee that no edge case can bypass.

---

### Concept: The `post('save')` Cascade Hook

When `.save()` is called on a Proposal document with `status: 'accepted'`, the `post('save')` hook fires after the write completes:

```javascript
proposalSchema.post('save', async function (doc) {
  if (doc.status !== 'accepted') return;

  // Reject all other pending proposals on this project
  await mongoose.model('Proposal').updateMany(
    { project: doc.project, _id: { $ne: doc._id }, status: 'pending' },
    { status: 'rejected' }
  );

  // Move the project forward
  await mongoose.model('Project').findByIdAndUpdate(doc.project, {
    status: 'in_progress',
    acceptedFreelancer: doc.freelancer,
  });
});
```

`mongoose.model('Proposal')` is used instead of requiring the model directly — this avoids circular dependency issues between models that reference each other.

---

### Game Plan

```
Project.model.js
  ├── Fields: title, description, budget{min,max}, skillsRequired[String],
  │           deadline, status(open|in_progress|completed|cancelled, default:'open'),
  │           client(ref:User, required), acceptedFreelancer(ref:User, default:null)
  ├── pre('save') → validate budget.max > budget.min
  ├── Virtual 'proposals': ref:'Proposal', foreignField:'project', localField:'_id'
  ├── Schema options: timestamps, toJSON:{virtuals:true}, toObject:{virtuals:true}
  └── Indexes: {status,skillsRequired}, {client}

Proposal.model.js
  ├── Fields: project(ref:Project), freelancer(ref:User),
  │           coverLetter(minLength:50), bidAmount(min:1),
  │           status(pending|accepted|rejected, default:'pending')
  ├── Compound index: {project:1, freelancer:1} unique
  └── post('save') hook:
        if status !== 'accepted' → return
        Proposal.updateMany({ same project, not this one, pending }) → rejected
        Project.findByIdAndUpdate(project, { status:'in_progress', acceptedFreelancer })

project.controller.js
  createProject   → [protect, restrictTo('client')]
                    Project.create({ ...req.body, client: req.user._id })

  getAllProjects   → [protect]
                    Project.find({ status:'open', ...query filters }).populate('client')
                    .sort(req.query.sort || '-createdAt')

  getProject      → [protect]
                    Project.findById(id).populate('client').populate('proposals')

  updateProject   → [protect, restrictTo('client')]
                    Check project.client === req.user._id
                    Strip { status, client, acceptedFreelancer } from req.body
                    findByIdAndUpdate(id, safeUpdates, { new:true, runValidators:true })

  deleteProject   → [protect, restrictTo('client')]
                    Check ownership → check status !== 'in_progress'
                    project.status = 'cancelled' → project.save()

proposal.controller.js
  submitProposal  → [protect, restrictTo('freelancer')]
                    Find project → check status === 'open'
                    Check no existing { project + freelancer } proposal
                    Proposal.create({ ...body, project, freelancer: req.user._id })

  acceptProposal  → [protect, restrictTo('client')]
                    Proposal.findById(id).populate('project')
                    Check proposal.project.client === req.user._id
                    Check project.status === 'open'
                    proposal.status = 'accepted' → proposal.save()
                    (hook handles the entire cascade automatically)

  getProjectProposals → [protect, restrictTo('client')]
                    Check project.client === req.user._id
                    Proposal.find({ project }).populate('freelancer','name email')
```

---

### Reference Implementation

<details>
<summary>Phase 3 Code</summary>

**`src/models/Project.model.js`**
```javascript
const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema(
  {
    title: {
      type:      String,
      required:  [true, 'A project must have a title'],
      trim:      true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type:      String,
      required:  [true, 'A project must have a description'],
      minlength: [20, 'Description must be at least 20 characters'],
    },
    budget: {
      min: { type: Number, required: [true, 'Please provide a minimum budget'] },
      max: { type: Number, required: [true, 'Please provide a maximum budget'] },
    },
    skillsRequired: {
      type:     [String],
      validate: { validator: (val) => val.length > 0, message: 'At least one skill required' },
    },
    deadline: {
      type:     Date,
      required: [true, 'A project must have a deadline'],
      validate: {
        validator: function (val) { return val > Date.now(); },
        message:   'Deadline must be a future date',
      },
    },
    status: {
      type:    String,
      enum:    ['open', 'in_progress', 'completed', 'cancelled'],
      default: 'open',
    },
    client:             { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    acceptedFreelancer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  },
  { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } }
);

// Cross-field validation: can't be done at the field level
projectSchema.pre('save', function (next) {
  if (this.budget.max <= this.budget.min) {
    return next(new Error('Maximum budget must be greater than minimum budget'));
  }
  next();
});

// Virtual populate: fetch proposals on demand without storing their IDs here
projectSchema.virtual('proposals', {
  ref: 'Proposal', foreignField: 'project', localField: '_id',
});

projectSchema.index({ status: 1, skillsRequired: 1 });
projectSchema.index({ client: 1 });

module.exports = mongoose.model('Project', projectSchema);
```

**`src/models/Proposal.model.js`**
```javascript
const mongoose = require('mongoose');

const proposalSchema = new mongoose.Schema(
  {
    project:    { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: [true, 'Proposal must belong to a project'] },
    freelancer: { type: mongoose.Schema.Types.ObjectId, ref: 'User',    required: [true, 'Proposal must belong to a freelancer'] },
    coverLetter: { type: String, required: [true, 'Please provide a cover letter'], minlength: [50, 'Cover letter must be at least 50 characters'] },
    bidAmount:   { type: Number, required: [true, 'Please provide your bid amount'], min: [1, 'Bid amount must be positive'] },
    status:      { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
  },
  { timestamps: true }
);

// DB-level guarantee: one proposal per freelancer per project
proposalSchema.index({ project: 1, freelancer: 1 }, { unique: true });

// CASCADE HOOK: fires after any proposal is saved
// When accepted: rejects all competitors and advances the project status
proposalSchema.post('save', async function (doc) {
  if (doc.status !== 'accepted') return;

  await mongoose.model('Proposal').updateMany(
    { project: doc.project, _id: { $ne: doc._id }, status: 'pending' },
    { status: 'rejected' }
  );

  await mongoose.model('Project').findByIdAndUpdate(doc.project, {
    status: 'in_progress', acceptedFreelancer: doc.freelancer,
  });
});

module.exports = mongoose.model('Proposal', proposalSchema);
```

**`src/controllers/project.controller.js`**
```javascript
const Project    = require('../models/Project.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

exports.createProject = catchAsync(async (req, res, next) => {
  const project = await Project.create({ ...req.body, client: req.user._id });
  res.status(201).json({ status: 'success', data: { project } });
});

exports.getAllProjects = catchAsync(async (req, res, next) => {
  const queryObj = { status: 'open', ...req.query };
  ['page', 'sort', 'limit', 'fields'].forEach((f) => delete queryObj[f]);

  let query = Project.find(queryObj).populate('client', 'name email');
  query = query.sort(req.query.sort?.split(',').join(' ') || '-createdAt');

  const projects = await query;
  res.status(200).json({ status: 'success', results: projects.length, data: { projects } });
});

exports.getProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id)
    .populate('client', 'name email')
    .populate('proposals'); // virtual populate — runs a second DB query

  if (!project) return next(new AppError('No project found with that ID', 404));
  res.status(200).json({ status: 'success', data: { project } });
});

exports.updateProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id);
  if (!project) return next(new AppError('No project found with that ID', 404));

  if (project.client.toString() !== req.user._id.toString()) {
    return next(new AppError('You are not authorized to update this project', 403));
  }

  const { status, client, acceptedFreelancer, ...allowedUpdates } = req.body;

  // Using findByIdAndUpdate (not .save()) — no hooks need to fire for a simple field update
  const updated = await Project.findByIdAndUpdate(req.params.id, allowedUpdates, {
    new: true, runValidators: true,
  });

  res.status(200).json({ status: 'success', data: { project: updated } });
});

exports.deleteProject = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.id);
  if (!project) return next(new AppError('No project found with that ID', 404));

  if (project.client.toString() !== req.user._id.toString()) {
    return next(new AppError('You are not authorized to delete this project', 403));
  }
  if (project.status === 'in_progress') {
    return next(new AppError('Cannot cancel a project that is already in progress', 400));
  }

  // Soft delete — using .save() in case we add pre-save hooks to Project later
  project.status = 'cancelled';
  await project.save();

  res.status(204).json({ status: 'success', data: null });
});
```

**`src/controllers/proposal.controller.js`**
```javascript
const Proposal   = require('../models/Proposal.model');
const Project    = require('../models/Project.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

exports.submitProposal = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.projectId);
  if (!project) return next(new AppError('No project found with that ID', 404));
  if (project.status !== 'open') return next(new AppError('This project is no longer accepting proposals', 400));

  const existing = await Proposal.findOne({ project: req.params.projectId, freelancer: req.user._id });
  if (existing) return next(new AppError('You have already submitted a proposal for this project', 400));

  const proposal = await Proposal.create({
    ...req.body, project: req.params.projectId, freelancer: req.user._id,
  });

  res.status(201).json({ status: 'success', data: { proposal } });
});

exports.acceptProposal = catchAsync(async (req, res, next) => {
  const proposal = await Proposal.findById(req.params.id).populate('project');
  if (!proposal) return next(new AppError('No proposal found with that ID', 404));

  if (proposal.project.client.toString() !== req.user._id.toString()) {
    return next(new AppError('You are not authorized to accept this proposal', 403));
  }
  if (proposal.project.status !== 'open') {
    return next(new AppError('This project already has an accepted proposal', 400));
  }

  // Using .save() — NOT findByIdAndUpdate — because we NEED the post('save') hook to fire
  proposal.status = 'accepted';
  await proposal.save();

  res.status(200).json({ status: 'success', data: { proposal } });
});

exports.getProjectProposals = catchAsync(async (req, res, next) => {
  const project = await Project.findById(req.params.projectId);
  if (!project) return next(new AppError('No project found with that ID', 404));
  if (project.client.toString() !== req.user._id.toString()) {
    return next(new AppError('You can only view proposals for your own projects', 403));
  }

  const proposals = await Proposal.find({ project: req.params.projectId })
    .populate('freelancer', 'name email').sort('-createdAt');

  res.status(200).json({ status: 'success', results: proposals.length, data: { proposals } });
});
```

**`src/routes/project.routes.js`**
```javascript
const express    = require('express');
const { createProject, getAllProjects, getProject, updateProject, deleteProject } = require('../controllers/project.controller');
const { submitProposal, getProjectProposals } = require('../controllers/proposal.controller');
const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();
router.use(protect);

router.route('/').get(getAllProjects).post(restrictTo('client'), createProject);
router.route('/:id').get(getProject).patch(restrictTo('client'), updateProject).delete(restrictTo('client'), deleteProject);
router.route('/:projectId/proposals').get(restrictTo('client'), getProjectProposals).post(restrictTo('freelancer'), submitProposal);

module.exports = router;
```

**`src/routes/proposal.routes.js`**
```javascript
const express          = require('express');
const { acceptProposal } = require('../controllers/proposal.controller');
const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();
router.use(protect);
router.patch('/:id/accept', restrictTo('client'), acceptProposal);

module.exports = router;
```

</details>

---

## Phase 4 — Reviews & Dashboard Stats

---

### Concept: Static Methods

A **static method** lives on the Model class, not on document instances. Use static methods for operations that involve the whole collection — aggregations, bulk calculations, anything that isn't specific to one document:

```javascript
reviewSchema.statics.calcAverageRating = async function (freelancerId) {
  // 'this' = the Review MODEL — has access to this.aggregate()
  const stats = await this.aggregate([
    { $match: { freelancer: freelancerId } },
    { $group: { _id: '$freelancer', numRatings: { $sum: 1 }, avgRating: { $avg: '$rating' } } },
  ]);
  // update the User document with the new values...
};

// Called on the MODEL, not a document instance:
await Review.calcAverageRating(someFreelancerId);
```

This is paired with `post('save')` and `post(/^findOneAnd/)` hooks so that every time a review is created or deleted, the freelancer's `avgRating` on their User document is automatically recalculated.

---

### Concept: The `pre/post(/^findOneAnd/)` Hook Workaround

When a review is deleted via `findOneAndDelete`, the `post` hook doesn't receive the deleted document — it's already gone from the DB. The solution is a two-step pattern:

1. **`pre` hook** — find and store the document on `this` (the query object) while it still exists
2. **`post` hook** — use the stored document to trigger the recalculation after deletion

```javascript
reviewSchema.pre(/^findOneAnd/, async function (next) {
  this.currentDoc = await this.findOne(); // capture before deletion
  next();
});

reviewSchema.post(/^findOneAnd/, async function () {
  if (this.currentDoc) {
    await this.currentDoc.constructor.calcAverageRating(this.currentDoc.freelancer);
  }
});
```

---

### Concept: The MongoDB Aggregation Pipeline

The aggregation pipeline processes a collection through a sequence of stages. Each stage transforms the documents and passes results to the next. The entire computation runs inside MongoDB — not in Node.js memory.

```javascript
await Review.aggregate([
  // Stage 1: filter — keep only reviews for this freelancer
  { $match: { freelancer: freelancerId } },

  // Stage 2: group and calculate
  { $group: {
      _id:          '$freelancer',  // group key
      avgRating:    { $avg: '$rating' },
      totalReviews: { $sum: 1 },
      minRating:    { $min: '$rating' },
      maxRating:    { $max: '$rating' },
  }},

  // Stage 3: sort results
  { $sort: { avgRating: -1 } },

  // Stage 4: shape the output
  { $project: { _id: 0, avgRating: 1, totalReviews: 1 } },
]);
```

For stats dashboards this is the right tool — it returns aggregate numbers directly from the database instead of requiring you to fetch thousands of documents and calculate in JavaScript.

---

### Game Plan

```
Review.model.js
  ├── Fields: reviewer(ref:User), freelancer(ref:User), project(ref:Project),
  │           rating(1–5), comment(minLength:10)
  ├── Compound index: {reviewer:1, project:1} unique
  ├── Static calcAverageRating(freelancerId):
  │     aggregate: $match freelancerId → $group avg + count
  │     findByIdAndUpdate(freelancerId, { avgRating, ratingsCount })
  │     if no results → reset to 0
  ├── post('save') → this.constructor.calcAverageRating(this.freelancer)
  ├── pre(/^findOneAnd/) → this.currentDoc = await this.findOne()
  └── post(/^findOneAnd/) → this.currentDoc.constructor.calcAverageRating(...)

review.controller.js
  createReview      → [protect, restrictTo('client')]
                      Find project → check status === 'completed'
                      Check project.client === req.user._id
                      Check project.acceptedFreelancer === freelancerId
                      Review.create({ reviewer, freelancer, project, rating, comment })

  getFreelancerReviews → [protect]
                      Review.find({ freelancer }).populate('reviewer','name')
                                                  .populate('project','title')

  getFreelancerStats  → [protect]
                      Cast req.params.id to ObjectId (required for aggregation $match)
                      Proposal.aggregate: $match freelancer → $group by status, count
                      Review.aggregate: $match freelancer → $group avg/min/max/count
                      Return combined stats object
```

---

### Reference Implementation

<details>
<summary>Phase 4 Code</summary>

**`src/models/Review.model.js`**
```javascript
const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    reviewer:   { type: mongoose.Schema.Types.ObjectId, ref: 'User',    required: true },
    freelancer: { type: mongoose.Schema.Types.ObjectId, ref: 'User',    required: true },
    project:    { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: true },
    rating:  { type: Number, required: [true, 'Please provide a rating'], min: [1, 'Min 1'], max: [5, 'Max 5'] },
    comment: { type: String, required: [true, 'Please provide a comment'], minlength: [10, 'Min 10 characters'] },
  },
  { timestamps: true }
);

reviewSchema.index({ reviewer: 1, project: 1 }, { unique: true });

// STATIC METHOD: recalculate and persist the freelancer's average rating
reviewSchema.statics.calcAverageRating = async function (freelancerId) {
  const stats = await this.aggregate([
    { $match: { freelancer: freelancerId } },
    { $group: { _id: '$freelancer', numRatings: { $sum: 1 }, avgRating: { $avg: '$rating' } } },
  ]);

  if (stats.length > 0) {
    await mongoose.model('User').findByIdAndUpdate(freelancerId, {
      ratingsCount: stats[0].numRatings,
      avgRating:    Math.round(stats[0].avgRating * 10) / 10,
    });
  } else {
    await mongoose.model('User').findByIdAndUpdate(freelancerId, { ratingsCount: 0, avgRating: 0 });
  }
};

// After a review is saved: recalculate
// this.constructor = Review model — allows calling the static method from an instance context
reviewSchema.post('save', function () {
  this.constructor.calcAverageRating(this.freelancer);
});

// Before findOneAnd*: capture the document while it still exists in the DB
reviewSchema.pre(/^findOneAnd/, async function (next) {
  this.currentDoc = await this.findOne();
  next();
});

// After findOneAnd*: recalculate using the captured document
reviewSchema.post(/^findOneAnd/, async function () {
  if (this.currentDoc) {
    await this.currentDoc.constructor.calcAverageRating(this.currentDoc.freelancer);
  }
});

module.exports = mongoose.model('Review', reviewSchema);
```

**`src/controllers/review.controller.js`**
```javascript
const mongoose   = require('mongoose');
const Review     = require('../models/Review.model');
const Project    = require('../models/Project.model');
const Proposal   = require('../models/Proposal.model');
const AppError   = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

exports.createReview = catchAsync(async (req, res, next) => {
  const { freelancerId, projectId, rating, comment } = req.body;

  const project = await Project.findById(projectId);
  if (!project) return next(new AppError('No project found with that ID', 404));
  if (project.status !== 'completed') return next(new AppError('You can only review completed projects', 400));
  if (project.client.toString() !== req.user._id.toString()) return next(new AppError('You can only review projects you own', 403));
  if (project.acceptedFreelancer?.toString() !== freelancerId) return next(new AppError('This freelancer did not work on this project', 400));

  const review = await Review.create({
    reviewer: req.user._id, freelancer: freelancerId, project: projectId, rating, comment,
  });
  res.status(201).json({ status: 'success', data: { review } });
});

exports.getFreelancerReviews = catchAsync(async (req, res, next) => {
  const reviews = await Review.find({ freelancer: req.params.freelancerId })
    .populate('reviewer', 'name').populate('project', 'title').sort('-createdAt');
  res.status(200).json({ status: 'success', results: reviews.length, data: { reviews } });
});

exports.getFreelancerStats = catchAsync(async (req, res, next) => {
  // Must cast to ObjectId — aggregation $match requires BSON type, not a string
  const freelancerId = new mongoose.Types.ObjectId(req.params.id);

  const proposalStats = await Proposal.aggregate([
    { $match: { freelancer: freelancerId } },
    { $group: { _id: '$status', count: { $sum: 1 } } },
  ]);

  const reviewStats = await Review.aggregate([
    { $match: { freelancer: freelancerId } },
    { $group: {
        _id: null,
        avgRating:    { $avg: '$rating' },
        totalReviews: { $sum: 1 },
        minRating:    { $min: '$rating' },
        maxRating:    { $max: '$rating' },
    }},
  ]);

  res.status(200).json({
    status: 'success',
    data: {
      proposals: proposalStats,
      reviews:   reviewStats[0] || { avgRating: 0, totalReviews: 0 },
    },
  });
});
```

**`src/routes/review.routes.js`**
```javascript
const express    = require('express');
const { createReview, getFreelancerReviews, getFreelancerStats } = require('../controllers/review.controller');
const { protect, restrictTo } = require('../middlewares/auth.middleware');

const router = express.Router();
router.use(protect);

router.post('/',                        restrictTo('client'), createReview);
router.get('/freelancer/:freelancerId', getFreelancerReviews);
router.get('/stats/freelancer/:id',     getFreelancerStats);

module.exports = router;
```

</details>

---

## API Endpoint Reference

### Auth
| Method | Endpoint | Access | Description |
|---|---|---|---|
| POST | `/api/v1/auth/register` | Public | Register as client or freelancer |
| POST | `/api/v1/auth/login` | Public | Login → receive JWT |

### Projects
| Method | Endpoint | Access | Description |
|---|---|---|---|
| GET | `/api/v1/projects` | Any logged-in | All open projects |
| POST | `/api/v1/projects` | Client only | Create a project |
| GET | `/api/v1/projects/:id` | Any logged-in | Single project + proposals |
| PATCH | `/api/v1/projects/:id` | Client (owner) | Update fields |
| DELETE | `/api/v1/projects/:id` | Client (owner) | Soft delete |

### Proposals
| Method | Endpoint | Access | Description |
|---|---|---|---|
| POST | `/api/v1/projects/:id/proposals` | Freelancer | Submit a proposal |
| GET | `/api/v1/projects/:id/proposals` | Client (owner) | View all proposals |
| PATCH | `/api/v1/proposals/:id/accept` | Client (owner) | Accept → triggers cascade |

### Reviews & Stats
| Method | Endpoint | Access | Description |
|---|---|---|---|
| POST | `/api/v1/reviews` | Client | Leave a review |
| GET | `/api/v1/reviews/freelancer/:id` | Any logged-in | Freelancer reviews |
| GET | `/api/v1/reviews/stats/freelancer/:id` | Any logged-in | Dashboard stats |

---

## Interview Survival Kit

**"What is the difference between Authentication and Authorization?"**
> Authentication verifies identity — who are you? It checks the JWT signature and confirms the user exists in the database. Authorization checks permissions — are you allowed to do this? It checks the user's role against what the route requires. In this codebase `protect` handles authentication, `restrictTo` handles authorization. They always run in sequence.

**"How does JWT work? What are its three parts?"**
> Header (the signing algorithm), Payload (data — user ID, issued-at, expiry), Signature (a cryptographic hash of header + payload signed with the server's secret key). The server stores nothing. On each request it re-verifies the math. If the payload was tampered with, the signature won't match and `jwt.verify` throws.

**"Why do we hash passwords instead of encrypting them?"**
> Encryption is reversible — steal the key, decrypt every password. Hashing is one-way — nothing to steal. bcrypt also adds a random salt automatically, so two identical passwords produce different hashes, defeating rainbow table attacks.

**"What is the difference between Document and Query middleware in Mongoose?"**
> Document middleware (`pre('save')`, `post('save')`) — `this` is the document, triggered by `.save()` and `.create()`. Query middleware (`pre(/^find/)`) — `this` is the query object, triggered by `find`, `findOne`, `findById`, etc. Critical: `findByIdAndUpdate` does NOT trigger document middleware.

**"What is the difference between `.save()` and `findByIdAndUpdate()`?"**
> `findByIdAndUpdate` is a direct MongoDB operation — bypasses all pre/post save hooks, skips validators by default (pass `{ runValidators: true }` to enable them). `.save()` goes through the full Mongoose lifecycle — every hook runs, every validator runs. Rule: if hooks matter, use `.save()`.

**"What is `catchAsync` and why do we need it?"**
> A higher-order function that wraps every async controller. Without it, an unhandled promise rejection in an async handler would crash the server. With it, any rejection is forwarded to `next(err)` and handled by the global error handler. Eliminates try/catch from every single controller.

**"What is the `isOperational` flag on AppError?"**
> It separates intentional errors (user sent bad data, resource not found) from unexpected bugs. The global error handler sends the real message to the client only when `isOperational` is true. For unexpected bugs it logs internally and sends a generic "Something went wrong" — never leaking implementation details.

---

## Friday Morning Checklist

- [ ] `POST /auth/register` → token returned, password absent from response
- [ ] `POST /auth/login` → correct credentials return token, wrong credentials return 401
- [ ] Protected route without token → 401
- [ ] Freelancer calling a client-only route → 403
- [ ] `POST /projects` → `client` in response is `req.user._id`, not from body
- [ ] Accept a proposal → all other pending proposals on same project are rejected → project is `in_progress`
- [ ] `GET /projects/:id` → proposals array populated via virtual
- [ ] Invalid ObjectId in URL → 400, not a 500 crash
- [ ] Duplicate email on register → clear 400 message
- [ ] `NODE_ENV=production` → no stack trace in error response
- [ ] Stats endpoint → aggregated numbers, not raw documents

---

> **Last tip for the shadowing interview:** Talk while you code. When you type `proposal.status = 'accepted'` followed by `.save()`, say out loud: "I'm using `.save()` here instead of `findByIdAndUpdate` because I need the `post('save')` hook to fire — it handles rejecting the other proposals and updating the project status automatically." Explaining the *why* behind every decision is what separates mid-level from junior.
