# 🏗️ Bookstore Backend — Senior Architect Deep Dive (Part 1/3)

> **Reading order**: Entry Point → App Setup → Config → Middlewares

---

## 📁 Project Architecture Overview

```
bookstore-backend/
├── index.js              ← 🚀 ENTRY POINT (start here)
├── app.js                ← Express app config
├── vercel.json           ← Serverless deployment config
├── package.json          ← Dependencies & scripts
├── .env                  ← Environment variables
└── src/
    ├── config/           ← 3rd-party service configs (Cloudinary)
    ├── middlewares/       ← Auth, validation, error handling, rate limiting
    ├── models/           ← Mongoose schemas (User, Book, Cart, Order, etc.)
    ├── controllers/      ← Request handlers (business logic)
    ├── services/         ← Complex business logic (JWT, order placement)
    ├── validations/      ← Joi schemas for input validation
    └── utils/            ← Shared helpers (ApiError, ApiResponse, pagination)
```

### Request Lifecycle (MEMORIZE THIS)

```
Client Request
  → CORS (app.js)
    → JSON Parser (app.js)
      → HTTP Logger (pino)
        → Rate Limiter
          → Router (routes/index.js)
            → Authenticate middleware (JWT check)
              → Authorize middleware (role check)
                → Validate middleware (Joi schema)
                  → Controller (business logic)
                    → Service layer (complex operations)
                      → Model (MongoDB via Mongoose)
                        → Response (ApiResponse)
                          → Error Handler (if anything threw)
```

---

## 1️⃣ `index.js` — The Entry Point

### General Concept
This is the **very first file** Node.js executes. It has TWO jobs:
1. **Local dev**: Connect to MongoDB, start the Express server on a port.
2. **Vercel serverless**: Export a handler that connects to DB on-demand per request.

### Simple Example
```js
// Simplest possible entry point
const app = require('./app');
const mongoose = require('mongoose');
mongoose.connect(process.env.MONGO_URI);
app.listen(5000, () => console.log('Running'));
```

### Project Application — [index.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/index.js)

The file does more than the simple example:

- **Line 1-4**: Loads `.env`, imports mongoose, app, errorHandler
- **Line 8**: Mounts the global error handler as the LAST middleware
- **Line 14-17**: `connectDB()` — checks `mongoose.connection.readyState` to avoid reconnecting (important for Vercel cold starts)
- **Line 20-23**: `handler()` — wraps the app to ensure DB is connected before any request
- **Line 25-48**: `require.main === module` — only runs when executed directly (`node index.js`), NOT when Vercel imports it
- **Line 30-33**: Catches uncaught exceptions (sync errors that escape everything)
- **Line 45-48**: Catches unhandled promise rejections (async errors that escape everything)
- **Line 53**: Exports `handler` for Vercel

### Connections
| Connects To | How |
|---|---|
| `app.js` | Imports it as the Express application |
| `errorHandler.js` | Mounts it as final middleware |
| `mongoose` | Connects to MongoDB Atlas |
| `vercel.json` | Vercel routes all requests to this file |

### Code Flaws & Refactoring

> [!CAUTION]
> **FLAW 1 — Double errorHandler mounting**: `errorHandler` is mounted in BOTH `app.js` (line 22) AND `index.js` (line 8). This means it's registered twice. The second one in `index.js` will never execute because Express stops at the first error handler that sends a response. **Remove line 8 from index.js**.

> [!WARNING]
> **FLAW 2 — `catch` swallows the original error in Vercel handler**: In the `handler` function, if `connectDB()` fails, the error just propagates as an unhandled rejection. There's no `try/catch` around it.

> [!WARNING]
> **FLAW 3 — `.env` file is committed to Git**: The `.env` file contains real secrets (JWT_SECRET, Cloudinary keys, MongoDB credentials). This is a **critical security violation**. It should be in `.gitignore`.

### Interview Questions
1. **"What is `require.main === module` and why is it used here?"**
   → It checks if the file is being run directly (`node index.js`) vs. being imported by another file (Vercel). This lets you have dual-mode: local server + serverless function.

2. **"What is the difference between `uncaughtException` and `unhandledRejection`?"**
   → `uncaughtException` catches synchronous throws that weren't in a try/catch. `unhandledRejection` catches rejected Promises that don't have a `.catch()`. Both are last-resort safety nets.

3. **"Why does the Vercel handler check `readyState` before connecting?"**
   → Vercel reuses the same process for multiple invocations (warm starts). Without this check, every request would try to open a new DB connection, causing connection pool exhaustion.

---

## 2️⃣ `app.js` — Express Application Setup

### General Concept
This file **creates and configures** the Express app. It's the "skeleton" — it sets up CORS, JSON parsing, logging, rate limiting, and mounts all routes. It does NOT start the server (that's `index.js`'s job).

### Simple Example
```js
const express = require('express');
const app = express();
app.use(express.json()); // parse JSON bodies
app.use('/api', routes);  // mount all routes under /api
module.exports = app;
```

### Project Application — [app.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/app.js)

- **Line 7-15**: CORS configured for Angular dev server (`localhost:4200`) and a placeholder Vercel URL
- **Line 16**: `express.json()` — parses incoming JSON request bodies
- **Line 17**: `httpLogger` — Pino HTTP logging middleware
- **Line 18**: `rateLimiter` — Custom in-memory rate limiter
- **Line 20**: All routes mounted under `/api` prefix
- **Line 22**: Error handler (the one that should be the ONLY one)

### Connections
| Connects To | How |
|---|---|
| `middlewares/index.js` | Imports httpLogger, errorHandler, rateLimiter |
| `routes/index.js` | Mounts all API routes under `/api` |
| `index.js` | Imported and used to start the server |

### Code Flaws

> [!WARNING]
> **FLAW — Hardcoded CORS origin**: The Vercel frontend URL is a TODO placeholder. In production, this should come from `process.env.FRONTEND_URL`.

> [!NOTE]
> **Good practice**: Separating `app.js` from `index.js` makes the app testable — you can import `app` in tests without starting the server.

### Interview Questions
1. **"Why separate app.js from index.js?"**
   → Separation of concerns: `app.js` defines the app, `index.js` runs it. This allows unit testing the app without binding to a port.

2. **"What does `express.json()` do internally?"**
   → It's a built-in middleware that reads the request body stream, parses it as JSON, and puts the result in `req.body`. It uses the `content-type` header to decide if parsing is needed.

3. **"In what order should middleware be registered and why does it matter?"**
   → Order matters because Express processes middleware top-to-bottom. CORS must come first (to add headers to all responses), then body parsing (so routes can read `req.body`), then logging, then routes, and error handlers LAST.

---

## 3️⃣ `src/config/cloudinary.js` — Third-Party Configuration

### General Concept
Configures the Cloudinary SDK with credentials from environment variables. Cloudinary is a cloud image hosting service — the app uses it for book cover images.

### Simple Example
```js
const cloudinary = require('cloudinary').v2;
cloudinary.config({ cloud_name: 'xxx', api_key: 'yyy', api_secret: 'zzz' });
module.exports = cloudinary;
```

### Project Application — [cloudinary.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/config/cloudinary.js)

- Reads 3 env vars: `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
- Exports the configured `cloudinary` instance

### Connections
| Connects To | How |
|---|---|
| `controllers/cloudinary.js` | Imports this to generate upload signatures |
| `.env` | Reads credentials from environment |

### Interview Questions
1. **"Why use signed uploads instead of uploading directly from the server?"**
   → Signed uploads let the **frontend** upload directly to Cloudinary (faster, less server load), while the signature ensures only authorized uploads happen.

2. **"What's the `.v2` in `require('cloudinary').v2`?"**
   → Cloudinary has multiple API versions. `.v2` is the current stable API. Without it, you'd get the legacy v1 API.

3. **"Why not hardcode credentials directly?"**
   → Environment variables keep secrets out of source code, allow different configs per environment (dev/staging/prod), and prevent accidental Git commits of sensitive data.

---

## 4️⃣ `src/middlewares/authenticate.js` — Authentication (JWT Verification)

### General Concept
**Authentication** = "WHO are you?" This middleware extracts the JWT token from the `Authorization` header, verifies it, finds the user in the database, and attaches `req.user` for downstream handlers.

### Simple Example
```js
const protect = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  const decoded = jwt.verify(token, SECRET);
  req.user = await User.findById(decoded._id);
  next();
};
```

### Project Application — [authenticate.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/authenticate.js)

- **Line 6-11**: Checks that `Authorization` header exists and starts with `Bearer`
- **Line 12**: Extracts the token part after `Bearer `
- **Line 16**: Verifies token using `services/auth.js` → `verifyToken()`
- **Line 18**: Fetches the full user from DB (ensures user still exists)
- **Line 21-22**: Checks if user changed password AFTER the token was issued (security)
- **Line 24**: Attaches user to `req.user` — now available in all downstream handlers

### Connections
| Connects To | How |
|---|---|
| `services/auth.js` | Uses `verifyToken()` to decode JWT |
| `models/user.js` | Fetches user by ID, calls `changedPasswordAfter()` |
| `utils/ApiError.js` | Throws 401 errors |
| All protected routes | Used as middleware before controllers |

### Code Flaws

> [!WARNING]
> **FLAW — No try/catch around `verifyToken`**: If the JWT is malformed or expired, `jwt.verify()` throws `JsonWebTokenError` or `TokenExpiredError`. In Express 5 (which this project uses), async errors are auto-caught, but if this somehow runs in Express 4, it would crash. The error handler does catch these in `errorHandler.js`, which is fine, but the error message could be more user-friendly.

### Interview Questions
1. **"What is the difference between Authentication and Authorization?"**
   → Authentication verifies identity (who you are). Authorization verifies permissions (what you're allowed to do). `authenticate.js` handles the first, `authorize.js` handles the second.

2. **"Why fetch the user from DB on every request instead of trusting the token?"**
   → The user might have been deleted, banned, or changed their password after the token was issued. The DB check ensures the token belongs to a still-valid user.

3. **"What does `changedPasswordAfter(iat)` do?"**
   → It compares the token's `iat` (issued-at timestamp) with `passwordChangedAt`. If the password was changed AFTER the token was issued, the token is invalid — this prevents using old tokens after a password change.

---

## 5️⃣ `src/middlewares/authorize.js` — Authorization (Role Check)

### General Concept
**Authorization** = "Are you ALLOWED to do this?" This is a higher-order function that takes a list of allowed roles and returns middleware. It checks if `req.user.role` is in the allowed list.

### Simple Example
```js
const restrictTo = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Forbidden' });
  next();
};
```

### Project Application — [authorize.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/authorize.js)

- **Line 3**: `restrictTo(...roles)` — closure pattern. Takes roles like `'admin'`
- **Line 5**: Checks `req.user.role` — `req.user` was set by `authenticate.js`
- **Line 6-9**: Throws 403 ApiError if role doesn't match

### Connections
| Connects To | How |
|---|---|
| `authenticate.js` | MUST run AFTER authenticate (needs `req.user`) |
| Routes (author, book, category, cloudinary, order) | Guards admin-only endpoints |

### Code Flaws

> [!NOTE]
> **Good pattern**: Using a closure (`...roles`) makes this reusable — `restrictTo('admin')`, `restrictTo('admin', 'moderator')`, etc.

### Interview Questions
1. **"What is a closure and how is it used here?"**
   → A closure is a function that "remembers" variables from its outer scope. `restrictTo('admin')` returns a new function that still has access to `roles = ['admin']` even after `restrictTo` has finished executing.

2. **"What happens if you put `restrictTo('admin')` BEFORE `protect` in the route chain?"**
   → It would crash because `req.user` doesn't exist yet. `protect` (authenticate) must always come first.

3. **"How would you add a 'moderator' role that can edit but not delete?"**
   → You'd use `restrictTo('admin', 'moderator')` for edit routes and `restrictTo('admin')` for delete routes. You'd also add `'moderator'` to the User model's `role` enum.

---

## 6️⃣ `src/middlewares/validate.js` — Input Validation (Joi)

### General Concept
A higher-order middleware that takes a Joi schema and validates `req.body` against it. If validation fails, it throws a 400 error with all error messages. If it passes, it replaces `req.body` with the sanitized value (thanks to `stripUnknown`).

### Simple Example
```js
const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body);
  if (error) throw new Error(error.message);
  next();
};
```

### Project Application — [validate.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/validate.js)

- **Line 4**: `abortEarly: false` — collects ALL errors, not just the first one
- **Line 5**: `stripUnknown: true` — removes fields not in the schema (security!)
- **Line 8**: On success, replaces `req.body` with sanitized value
- **Line 10**: Joins all error messages into one comma-separated string

### Connections
| Connects To | How |
|---|---|
| `validations/*.js` | Receives Joi schemas from these files |
| All routes | Used as middleware: `validate(createBookSchema)` |

### Code Flaws

> [!WARNING]
> **FLAW — Only validates `req.body`**: Query params (`req.query`) and URL params (`req.params`) are never validated by Joi. The `bookId` in `/books/:bookId/reviews` is never validated as a valid ObjectId format before hitting the controller. This could cause Mongoose CastErrors.

### Interview Questions
1. **"What does `stripUnknown: true` do and why is it important?"**
   → It removes any fields from the request body that aren't defined in the Joi schema. This prevents mass-assignment attacks where an attacker sends `{ role: 'admin' }` in a registration request.

2. **"What is `abortEarly: false`?"**
   → By default, Joi stops at the first error. `abortEarly: false` validates everything and returns ALL errors at once, which is better UX.

3. **"Why use Joi in addition to Mongoose validation?"**
   → Joi validates at the HTTP layer (before DB), gives better error messages, and can reject requests early without touching the database. Mongoose validation is a last line of defense.

---

## 7️⃣ `src/middlewares/errorHandler.js` — Global Error Handler

### General Concept
The **last** middleware in the chain. Express error handlers have 4 parameters `(err, req, res, next)`. This catches ALL errors thrown in the app and sends a formatted JSON response. In development it shows the full stack trace; in production it hides internal details.

### Simple Example
```js
const errorHandler = (err, req, res, next) => {
  res.status(err.statusCode || 500).json({ message: err.message });
};
```

### Project Application — [errorHandler.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/errorHandler.js)

- **Line 14**: In development → sends full error + stack trace via `devError()`
- **Line 17**: In production → creates a copy of the error
- **Line 18-28**: Transforms known MongoDB/JWT errors into user-friendly ApiErrors:
  - `CastError` → "Invalid ID format" (400)
  - `11000` code → "Duplicate field" (409)
  - `ValidationError` → Mongoose validation failed (400)
  - `JsonWebTokenError` → "Invalid token" (401)
  - `TokenExpiredError` → "Token expired" (401)

### Connections
| Connects To | How |
|---|---|
| `utils/ApiError.js` | Creates ApiError instances for known errors |
| `utils/errorHelpers.js` | Uses `devError()` and `productionError()` for formatting |
| `app.js` / `index.js` | Mounted as the last middleware |

### Code Flaws

> [!CAUTION]
> **FLAW — `error.name` is lost in spread**: Line 17 does `let error = { ...err, message: err.message }`. The spread operator doesn't copy the `name` property from Error objects because `name` is on the prototype, not the instance. This means `error.name === 'CastError'` on line 18 **may not work** in all cases. Fix: `let error = Object.assign(Object.create(err), err, { message: err.message })` or explicitly copy `name`.

### Interview Questions
1. **"Why does an Express error handler need exactly 4 parameters?"**
   → Express uses the function's `.length` (argument count) to distinguish error handlers from regular middleware. If you write `(err, req, res)` (3 params), Express won't recognize it as an error handler.

2. **"What is the difference between operational and programming errors?"**
   → Operational errors are expected (invalid input, not found, auth failure) — marked with `isOperational: true`. Programming errors are bugs (TypeError, null reference). In production, only operational errors show their message; programming errors show "something went wrong".

3. **"Why spread `err` into a new object instead of mutating it directly?"**
   → To avoid mutating the original error object, which could cause side effects in logging or other error handlers.

---

## 8️⃣ `src/middlewares/logger.js` — HTTP Request Logging (Pino)

### General Concept
Creates a structured JSON logger using Pino (fastest Node.js logger). In development, it uses `pino-pretty` for colorized human-readable output. In production, it outputs raw JSON for log aggregation tools.

### Simple Example
```js
const pino = require('pino');
const logger = pino({ level: 'info' });
logger.info('Server started');
```

### Project Application — [logger.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/logger.js)

- **Line 5-9**: Creates base Pino logger; uses `pino-pretty` in non-production
- **Line 12**: `pinoHttp({ logger })` — Creates HTTP middleware that logs every request/response automatically (method, URL, status code, response time)

### Connections
| Connects To | How |
|---|---|
| `app.js` | Mounted as middleware via `httpLogger` |

### Interview Questions
1. **"Why use Pino instead of console.log or Winston?"**
   → Pino is ~5x faster than Winston because it uses worker threads for serialization. In high-traffic APIs, logging can become a bottleneck.

2. **"What is structured logging and why is it important?"**
   → Structured logging outputs JSON objects instead of strings. Tools like ELK Stack or Datadog can parse, search, and alert on structured logs. `console.log("error")` is unsearchable.

3. **"What does pino-http log automatically?"**
   → Request method, URL, status code, response time in ms, request ID, and any errors. All without you writing a single `logger.info()` call.

---

## 9️⃣ `src/middlewares/rateLimit.js` — Rate Limiting

### General Concept
Prevents abuse (brute-force attacks, DDoS) by limiting how many requests a single IP can make within a time window. This implementation uses an **in-memory Map** (not Redis).

### Simple Example
```js
const counts = {};
const rateLimit = (req, res, next) => {
  counts[req.ip] = (counts[req.ip] || 0) + 1;
  if (counts[req.ip] > 100) return res.status(429).json({ error: 'Too many requests' });
  next();
};
```

### Project Application — [rateLimit.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/middlewares/rateLimit.js)

- **Line 1-2**: Uses a `Map` with 1-minute window, 100 requests max
- **Line 5-12**: Cleanup interval runs every 30 seconds, deletes expired entries
- **Line 14-34**: Tracks count + first request time per IP. Resets after window expires.

### Connections
| Connects To | How |
|---|---|
| `app.js` | Mounted globally — applies to ALL routes |

### Code Flaws

> [!CAUTION]
> **FLAW 1 — In-memory storage doesn't work on Vercel**: Vercel serverless functions are stateless. Each cold start creates a fresh `Map()`. This rate limiter is essentially **non-functional** in production on Vercel. You need Redis (e.g., Upstash) for serverless rate limiting.

> [!WARNING]
> **FLAW 2 — Memory leak potential**: The `setInterval` cleanup runs every 30s but only cleans entries older than 1 minute. Under heavy traffic, the Map could grow very large between cleanups.

> [!WARNING]
> **FLAW 3 — `req.ip` behind a proxy**: Behind Vercel's CDN, `req.ip` might always be the proxy's IP, not the client's. You need `app.set('trust proxy', true)` for `req.ip` to return the actual client IP from `X-Forwarded-For`.

### Interview Questions
1. **"Why doesn't in-memory rate limiting work in serverless?"**
   → Serverless functions are stateless — each invocation may run in a different container with fresh memory. The Map is empty on every cold start. You need external state (Redis).

2. **"What is a sliding window vs. fixed window rate limiter?"**
   → Fixed window resets at exact intervals (this implementation). Sliding window considers the last N seconds from NOW. Fixed window allows burst traffic at window boundaries.

3. **"What HTTP status code is used for rate limiting and why?"**
   → 429 Too Many Requests. It's a standard code that tells clients to slow down. Well-behaved clients will respect `Retry-After` headers (which this implementation doesn't set).
