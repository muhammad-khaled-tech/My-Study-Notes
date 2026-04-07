# 🏗️ Bookstore Backend — Senior Architect Deep Dive (Part 3/3)

> **Covers**: Routes → Controllers → Validations → Bug Master List → Cheat Sheet

---

## 🛤️ ROUTES — URL Mapping Layer

---

## 23️⃣ `src/routes/index.js` — Route Aggregator

### General Concept
A central router that mounts all sub-routers under the `/api` prefix (set in `app.js`). Each domain gets its own file.

### Project Application — [routes/index.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/routes/index.js)

**Full URL Map:**
| Route Prefix | File | Description |
|---|---|---|
| `/api/auth` | `routes/auth.js` | Register, login, logout, profile |
| `/api/books` | `routes/book.js` | CRUD books + nested reviews |
| `/api/authors` | `routes/author.js` | CRUD authors |
| `/api/categories` | `routes/category.js` | CRUD categories |
| `/api/cart` | `routes/cart.js` | User's shopping cart |
| `/api/orders` | `routes/order.js` | Place & manage orders |
| `/api/reviews` | `routes/review.js` | Update/delete reviews |
| `/api/cloudinary-signature` | `routes/cloudinary.js` | Image upload signing |

### Interview Questions
1. **"What is the benefit of a centralized route index?"**
   → Single point of entry. You can see ALL API routes at a glance, add global middleware, or add API versioning (`/api/v1`, `/api/v2`).

2. **"How would you version this API?"**
   → Create `routes/v1/index.js` and `routes/v2/index.js`. Mount them as `app.use('/api/v1', v1Routes)` and `app.use('/api/v2', v2Routes)`.

3. **"Why are reviews mounted under BOTH `/books/:bookId/reviews` and `/reviews/:id`?"**
   → Creating and listing reviews require the `bookId` context (nested route). But updating/deleting a specific review only needs the review `id` (flat route).

---

## 24️⃣ `src/routes/auth.js` — Authentication Routes

### Project Application — [routes/auth.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/routes/auth.js)

| Method | Path | Middleware | Controller | Access |
|---|---|---|---|---|
| POST | `/auth/register` | `validate(registerSchema)` | `register` | Public |
| POST | `/auth/login` | `validate(loginSchema)` | `login` | Public |
| POST | `/auth/logout` | `authenticate` | `logout` | Logged in |
| GET | `/auth/me` | `authenticate` | `getUserProfile` | Logged in |
| PATCH | `/auth/profile` | `authenticate`, `validate(updateProfileSchema)` | `updateUserProfile` | Logged in |

### Middleware Chain Example (Register):
```
POST /api/auth/register
  → validate(registerSchema)   ← checks body with Joi
    → register controller      ← creates user in DB
```

---

## 25️⃣ `src/routes/book.js` — Book Routes

### Project Application — [routes/book.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/routes/book.js)

| Method | Path | Middleware | Access |
|---|---|---|---|
| GET | `/books` | none | Public |
| GET | `/books/:id` | none | Public |
| POST | `/books` | protect, restrictTo('admin'), validate | Admin |
| PATCH | `/books/:id` | protect, restrictTo('admin'), validate | Admin |
| DELETE | `/books/:id` | protect, restrictTo('admin') | Admin |
| POST | `/books/:bookId/reviews` | validate, **protect** | Logged in |
| GET | `/books/:bookId/reviews` | none | Public |

### Code Flaws

> [!CAUTION]
> **FLAW — Middleware order bug on POST `/books/:bookId/reviews`**: `validate(createReviewSchema)` comes BEFORE `protect`. This means an unauthenticated user's body is validated before checking if they're logged in. The correct order should be `protect` FIRST, then `validate`. (Line 14 in routes/book.js)

---

## 🎮 CONTROLLERS — Request Handlers

---

## 26️⃣ `src/controllers/auth.js` — Auth Controller

### General Concept
Handles user registration, login, logout (no-op), profile retrieval, and profile updates.

### Project Application — [controllers/auth.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/controllers/auth.js)

**Key flows:**
- **Register** (Line 6-25): Check duplicate email → create user → delete password from response object → return 201
- **Login** (Line 27-39): Find user with password (+select) → compare with bcrypt → generate JWT → return token
- **Logout** (Line 42-44): Returns 200 with no action — **token is NOT invalidated**

### Code Flaws

> [!CAUTION]
> **FLAW 1 — `logout` is a no-op**: JWT is stateless. The token remains valid until it expires. Without a token blacklist, "logging out" is meaningless.

> [!WARNING]
> **FLAW 2 — `updateUserProfile` allows updating ANY field**: `req.body` is passed directly to `findByIdAndUpdate`. If the Joi schema doesn't block `role` or `password`, a user could escalate privileges. The `updateProfileSchema` in validations allows only `firstName`, `lastName`, `dob` + `stripUnknown: true` in validate.js saves you here, but it's defense-in-depth to ALSO whitelist fields in the controller.

> [!WARNING]
> **FLAW 3 — `register` does `delete userObj.password`**: This works, but the password field has `select: false` — it wouldn't be returned in queries anyway. However, `User.create()` returns the full document including password, so the manual delete IS necessary here. Good.

### Interview Questions
1. **"Why use `User.findOne({ email }).select('+password')` in login?"**
   → Because the User schema has `password: { select: false }`. Without `+password`, the password field wouldn't be included, and you couldn't compare it with bcrypt.

2. **"What is the difference between `bcrypt.hash()` and `bcrypt.compare()`?"**
   → `hash(plain, saltRounds)` creates a hashed+salted string. `compare(plain, hash)` checks if the plain text matches the hash. Compare re-hashes with the same salt (embedded in the hash) and checks equality.

3. **"How would you implement real logout with JWT?"**
   → Use a Redis set of blacklisted token IDs (or the `jti` claim). On every authenticated request, check if the token is blacklisted. On logout, add the token to the blacklist with TTL = remaining token lifetime.

---

## 27️⃣ `src/controllers/book.js` — Book Controller

### Project Application — [controllers/book.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/controllers/book.js)

**Key features:**
- **getAllBooks** — supports search, category/author/price filters, pagination
- **createBook** — validates author and category exist before creation
- **updateBook** — validates foreign keys before update
- **deleteBook** — no orphan cleanup (reviews for this book remain!)

### Code Flaws

> [!WARNING]
> **FLAW — Deleting book doesn't clean up reviews, cart items, or order references**: After deleting a book, `Review` docs, `Cart` entries, and `Order` items still reference it. Populate calls on these will return `null` for the bookId.

### Interview Questions
1. **"What is `$text: { $search }` and how does it work?"**
   → It's MongoDB's full-text search operator. It uses the text index on `name` to find documents containing the search terms. It supports stemming (searching "running" finds "run") and stop words.

2. **"What does `populate('author category')` do under the hood?"**
   → It runs separate `findById` queries on the Author and Category collections and replaces the ObjectId fields with the full documents. It's NOT a join — it's multiple queries.

3. **"Why validate that author/category exist before creating a book?"**
   → MongoDB doesn't enforce foreign key constraints like SQL databases. Without manual validation, you could create a book referencing a non-existent author. Populate would return `null`.

---

## 28️⃣ `src/controllers/cart.js` — Cart Controller

### Project Application — [controllers/cart.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/controllers/cart.js)

**Operations:** getCartItems, addItem, removeItem, updateItemQuantity

**Key logic in `addItem`** (Line 25): Uses `|| new Cart()` pattern — if cart doesn't exist, creates a new one in memory, then `save()` creates it in DB.

**Key logic in `updateItemQuantity`** (Line 76-87): Uses `action` string (`'increment'`/`'decrement'`) instead of a numeric delta. Decrementing to 0 removes the item.

### Code Flaws

> [!WARNING]
> **FLAW — Race condition**: Two simultaneous "add to cart" requests could both read stock=1, both pass the check, and both add — resulting in quantity 2 for stock 1. No transaction or atomic operation is used.

### Interview Questions
1. **"What is `$pull` in MongoDB?"**
   → An update operator that removes elements from an array matching a condition. `{ $pull: { books: { bookId } } }` removes the subdocument where `bookId` matches.

2. **"What's the difference between `findOneAndUpdate` and `find` + `save`?"**
   → `findOneAndUpdate` is atomic (single DB operation). `find` + modify + `save` is two operations with a gap — another request could modify the document between them (race condition).

3. **"Why calculate `totalPrice` server-side instead of trusting the client?"**
   → Never trust the client for prices. A malicious client could send `totalPrice: 0`. The server must always calculate from the DB.

---

## 29️⃣ `src/controllers/order.js` — Order Controller

### Project Application — [controllers/order.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/controllers/order.js)

**Key: StateTransition pattern** (Line 45-48):
```js
const StateTransition = {
  processing: 'out_for_delivery',
  out_for_delivery: 'delivered'
};
```

This ensures orders follow `processing → out_for_delivery → delivered`. You cannot skip states or go backwards.

### Code Flaws

> [!WARNING]
> **FLAW — `updateOrderStatus` validation schema allows setting status to ANY valid enum value, but the StateTransition pattern in the controller rejects invalid transitions**: The Joi schema (`updateOrderStatusSchema`) accepts `'processing'` as a valid status. An admin could try to set a `delivered` order back to `processing` — the Joi passes but the controller rejects. This is fine functionally, but the error message could be confusing. Better: validate transitions in the Joi schema with `.custom()`.

---

## 30️⃣ `src/controllers/review.js` — Review Controller

### Project Application — [controllers/review.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/controllers/review.js)

**Key features:**
- **Purchase verification**: Only users with `delivered` orders containing the book can review it
- **Ownership check**: Only the review author (or admin) can delete; only author can update
- **Average rating**: Calculated on-the-fly from all reviews

### Code Flaws

> [!WARNING]
> **FLAW — Average rating computed in JavaScript, not MongoDB**: Fetches ALL ratings then reduces. Use `Review.aggregate([{ $match: { book } }, { $group: { _id: null, avg: { $avg: '$rating' } } }])` for better performance.

---

## ✅ VALIDATIONS — Joi Schemas

---

## 31️⃣ Validation Schemas Summary

| File | Schemas | Key rules |
|---|---|---|
| `auth.js` | register, login, updateProfile | Password: min 8, needs uppercase+lowercase+number |
| `author.js` | create, update | Name: 2-100 chars. `unknown(false)` rejects extra fields |
| `book.js` | create, update | ObjectId validated as 24-char hex string. Price must be positive |
| `cart.js` | addItem, updateQuantity, removeItem | bookId: just `string().required()` — **NOT validated as ObjectId** |
| `category.js` | create, update | Just a name: 2-100 chars |
| `order.js` | placeOrder, updateStatus | Shipping details: fullName, address, city, phone (all strings, no format validation) |
| `review.js` | create, update | Rating: integer 1-5. Comment: max 500 chars |

### Code Flaws

> [!CAUTION]
> **FLAW 1 — Cart `bookId` not validated as ObjectId**: `cart.js` uses `joi.string().required()` for `bookId`. Any string passes. Should use `joi.string().hex().length(24)` like `book.js` does.

> [!WARNING]
> **FLAW 2 — Order `phone` has no format validation**: `joi.string().required()` accepts "abc" as a phone number. Should use `.pattern(/^[+]?[\d\s-]{7,15}$/)`.

> [!WARNING]
> **FLAW 3 — Auth `registerSchema` has no `confirmPassword` field**: Users can't verify they typed the password correctly.

> [!WARNING]
> **FLAW 4 — `updateOrderStatusSchema` has `status` as required**: But the controller checks `if (status)` — implying it should be optional (you might want to update only `paymentStatus`).

---

# 🐛 MASTER BUG & SECURITY LIST

| # | Severity | File | Issue |
|---|---|---|---|
| 1 | 🔴 CRITICAL | `.env` | **Secrets committed to Git** — DB credentials, JWT secret, Cloudinary keys all exposed |
| 2 | 🔴 CRITICAL | `services/auth.js` | **90-day JWT expiration** — stolen tokens valid for 3 months |
| 3 | 🔴 CRITICAL | `controllers/auth.js` | **Logout does nothing** — no token invalidation mechanism |
| 4 | 🟠 HIGH | `index.js` + `app.js` | **Double errorHandler** mounting — errorHandler registered twice |
| 5 | 🟠 HIGH | `routes/book.js` | **Middleware order bug** — validate runs BEFORE protect on review creation |
| 6 | 🟠 HIGH | `middlewares/rateLimit.js` | **Rate limiter broken on Vercel** — in-memory Map resets on cold starts |
| 7 | 🟠 HIGH | `services/order.js` | **Catch block masks original errors** — all errors become 500 |
| 8 | 🟡 MEDIUM | `validations/cart.js` | **bookId not validated as ObjectId** — any string accepted |
| 9 | 🟡 MEDIUM | `validations/order.js` | **No phone format validation** — accepts any string |
| 10 | 🟡 MEDIUM | `controllers/book.js` | **No cleanup on book deletion** — orphaned reviews/cart items |
| 11 | 🟡 MEDIUM | `controllers/review.js` | **Average rating computed in JS** not MongoDB aggregation |
| 12 | 🟡 MEDIUM | `controllers/author.js` | **N+1 query** in findAllAuthors — separate count query per author |
| 13 | 🟡 MEDIUM | `models/user.js` | **`isVerified` field never used** — no email verification flow |
| 14 | 🟡 MEDIUM | `utils/pagination.js` | **No default values** for page/limit — NaN if undefined |
| 15 | 🟢 LOW | `app.js` | **Hardcoded CORS origin** — Vercel URL is a TODO |
| 16 | 🟢 LOW | `models/user.js` | **Names forced lowercase** — "Mohamed" → "mohamed" |
| 17 | 🟢 LOW | `middlewares/rateLimit.js` | **No `trust proxy`** — req.ip may be the proxy, not the client |

---

# 📋 DISCUSSION CHEAT SHEET

## Architecture Patterns Used
- **MVC + Service Layer**: Model → Controller → Route (with Services for complex logic)
- **Repository Pattern** (implicit): Mongoose models act as repositories
- **Middleware Pipeline**: Express middleware chain for cross-cutting concerns
- **Barrel Exports**: `index.js` files in each folder re-export all modules
- **Higher-Order Functions**: `validate(schema)`, `restrictTo(...roles)` — functions returning middleware

## Key Technologies To Know
| Tech | What It Does | Your File |
|---|---|---|
| Express 5 | HTTP framework (async error handling built-in) | `app.js` |
| Mongoose 9 | MongoDB ODM (schemas, validation, hooks) | `models/*.js` |
| JWT | Stateless authentication tokens | `services/auth.js` |
| Bcrypt | Password hashing (one-way) | `models/user.js` |
| Joi | Request body validation | `validations/*.js` |
| Pino | Structured JSON logging | `middlewares/logger.js` |
| Cloudinary | Cloud image hosting | `config/cloudinary.js` |
| Vercel | Serverless deployment | `vercel.json`, `index.js` |

## Top Questions You Might Be Asked
1. "Walk me through what happens when a user places an order" → Cart validation → stock check → transaction → stock decrement → order creation → cart cleared
2. "How do you handle authentication?" → JWT in Authorization header → verify → fetch fresh user → attach to req
3. "How do you handle errors?" → ApiError class → throw anywhere → caught by Express 5 → errorHandler formats response
4. "What security measures are in place?" → bcrypt hashing, JWT auth, role-based access, Joi validation, stripUnknown, rate limiting, CORS
5. "What would you improve?" → Real logout (token blacklist), shorter token TTL + refresh tokens, Redis rate limiting, email verification, cursor pagination

---

> **Good luck with your discussion! 🚀** Read Parts 1-3 in order. Focus on the Request Lifecycle diagram and the Master Bug List — those show you understand the system deeply.
