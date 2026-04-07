# 🏗️ Bookstore Backend — Senior Architect Deep Dive (Part 2/3)

> **Covers**: Models → Services → Utils

---

## 🗂️ MODELS — The Database Layer

---

## 10️⃣ `src/models/user.js` — User Model (THE MOST IMPORTANT MODEL)

### General Concept
Defines the **User** MongoDB schema using Mongoose. Handles user data, password hashing (bcrypt), and password-change detection for JWT invalidation. This is the **security backbone** of the app.

### Simple Example
```js
const userSchema = new mongoose.Schema({ email: String, password: String });
userSchema.pre('save', async function() { this.password = await bcrypt.hash(this.password, 12); });
module.exports = mongoose.model('User', userSchema);
```

### Project Application — [user.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/user.js)

**Schema Fields:**
| Field | Type | Key Details |
|---|---|---|
| `email` | String | unique, indexed, lowercase, validated with `validator.isEmail` |
| `firstName` | String | 2-25 chars, trimmed, lowercase |
| `lastName` | String | 2-25 chars, trimmed, lowercase |
| `dob` | Date | required, min 1900, max now |
| `password` | String | 8-50 chars, `select: false` (never returned in queries!) |
| `passwordChangedAt` | Date | set when password changes |
| `isVerified` | Boolean | default false (NOT USED ANYWHERE!) |
| `role` | String | enum `['user', 'admin']`, default `'user'` |

**Mongoose Middleware (Line 57-60):**
- `pre('save')` hook — runs BEFORE every `.save()` call
- `this.isModified('password')` — only hashes if password actually changed
- 12 salt rounds — strong but not too slow (~250ms)

**Instance Methods:**
- `changedPasswordAfter(JWTTimestamp)` (Line 61-71) — checks if password was changed after a token was issued
- `correctPassword(candidate, hashed)` (Line 73-78) — compares plain text with bcrypt hash

### Connections
| Connects To | How |
|---|---|
| `controllers/auth.js` | Creates users, finds users for login |
| `middlewares/authenticate.js` | Fetches user by decoded token ID |
| `services/auth.js` | Provides user data for JWT payload |

### Code Flaws

> [!CAUTION]
> **FLAW 1 — `isVerified` field exists but is NEVER used**: No email verification flow exists. Anyone can register and immediately use the API. Either implement email verification or remove the field.

> [!WARNING]
> **FLAW 2 — `dob` max is `Date.now()` — evaluated ONCE at schema definition time**: This is evaluated when the server starts, not on each request. A user registering with today's date as DOB might fail if the server has been running for days. Use a Joi validation or a custom Mongoose validator instead.

> [!WARNING]
> **FLAW 3 — Names forced to lowercase**: `firstName` and `lastName` have `lowercase: true`. "Mohamed" becomes "mohamed". This is unusual — typically you'd preserve case and compare case-insensitively.

> [!NOTE]
> **Missing**: No `phone` field, no `address` field (address is only in orders), no profile picture.

### Interview Questions
1. **"What is `select: false` on the password field?"**
   → It excludes the password from ALL query results by default. You must explicitly use `.select('+password')` to include it (like in the login controller). This prevents accidentally leaking password hashes.

2. **"How does the `pre('save')` middleware work and when does it NOT run?"**
   → It runs before `document.save()`. It does NOT run for `Model.findByIdAndUpdate()`, `Model.updateOne()`, etc. — only for `save()`. This is why `isModified('password')` is checked.

3. **"Why 12 salt rounds for bcrypt? What happens if you increase it to 20?"**
   → Salt rounds = 2^N iterations. 12 rounds ≈ 250ms. 20 rounds ≈ 60 seconds per hash — your login endpoint would take a minute. It's a tradeoff between security and performance.

---

## 11️⃣ `src/models/book.js` — Book Model

### General Concept
Defines books with name, price, stock, cover image, and references to Author and Category. Uses **virtuals** for computed fields and **text indexes** for search.

### Simple Example
```js
const bookSchema = new mongoose.Schema({ name: String, price: Number });
bookSchema.virtual('status').get(function() { return this.stock > 0 ? 'In Stock' : 'Out of Stock'; });
module.exports = mongoose.model('Book', bookSchema);
```

### Project Application — [book.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/book.js)

- **Line 22-26**: `author` field — `ObjectId` referencing Author model (required)
- **Line 27-31**: `category` field — `ObjectId` referencing Category (optional, default null)
- **Line 33-36**: `toJSON: { virtuals: true }` — includes virtuals when converting to JSON
- **Line 38-42**: `status` virtual — computed from `stock` (>10: In Stock, >0: Low Stock, 0: Out of Stock)
- **Line 44**: Text index on `name` — enables `$text: { $search: "..." }` queries
- **Line 45**: Index on `price` — speeds up price range queries

### Connections
| Connects To | How |
|---|---|
| `models/author.js` | References Author via ObjectId |
| `models/category.js` | References Category via ObjectId |
| `controllers/book.js` | CRUD operations |
| `controllers/cart.js` | Stock validation on add-to-cart |
| `services/order.js` | Stock decrement on order placement |

### Code Flaws

> [!WARNING]
> **FLAW — No `description` field**: A bookstore without book descriptions is incomplete. This should be a `String` field with `maxlength`.

### Interview Questions
1. **"What is a Mongoose virtual and is it stored in MongoDB?"**
   → A virtual is a computed property defined on the schema. It is NOT stored in the database — it's calculated on-the-fly when you access it. The `status` virtual computes from `stock` each time.

2. **"What does a text index do and what are its limitations?"**
   → A text index enables full-text search with `$text`. Limitations: only ONE text index per collection, doesn't support partial matches well (use regex or Atlas Search for that), and language-specific stemming can cause unexpected results.

3. **"What is `ref: 'Author'` and how does `populate()` use it?"**
   → `ref` tells Mongoose which model to use when you call `.populate('author')`. Populate replaces the ObjectId with the full document from the Author collection (it's a separate query under the hood — like a JOIN).

---

## 12️⃣ `src/models/author.js` — Author Model

### General Concept
Simple model for book authors with `name` and `bio`.

### Project Application — [author.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/author.js)

- Name: 2-100 chars, required
- Bio: optional, max 500 chars
- Timestamps enabled

### Connections
| Connects To | How |
|---|---|
| `models/book.js` | Books reference authors via `author` field |
| `controllers/author.js` | CRUD + book count queries |

### Interview Questions
1. **"Should author be a separate collection or embedded in Book?"**
   → Separate is better because one author can have many books. Embedding would duplicate author data in every book document and make updates hard (update in 100 places vs. 1).

2. **"What is the N+1 query problem and does `findAllAuthors` have it?"**
   → Yes! `findAllAuthors` fetches all authors, then for EACH author runs `Book.countDocuments()`. If there are 100 authors, that's 101 queries. Fix: use `$lookup` aggregation or batch the book counts.

3. **"What happens when you delete an author who has books?"**
   → The `deleteAuthor` controller correctly checks `Book.exists({ author: id })` first and rejects the deletion if books exist. This prevents orphaned book documents.

---

## 13️⃣ `src/models/category.js` — Category Model

### General Concept
Minimal model — just a unique category name.

### Project Application — [category.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/category.js)

- `name`: required, unique, trimmed
- When deleted, `controllers/category.js` sets all books in that category to `category: null`

### Interview Questions
1. **"What's the difference between `unique: true` in Mongoose vs. a unique index in MongoDB?"**
   → `unique: true` in Mongoose creates a unique index in MongoDB. But Mongoose doesn't enforce uniqueness itself — MongoDB does. If you create the schema after data exists, duplicates won't be cleaned up.

2. **"Why set books to `category: null` on deletion instead of cascade-deleting books?"**
   → Deleting a category shouldn't destroy inventory. Setting to null keeps the books available but uncategorized. This is a soft-reference cleanup.

3. **"Could you use an enum for categories instead of a separate collection?"**
   → Enums are fixed at code level. A separate collection lets admins create/edit categories at runtime without code changes or redeployment.

---

## 14️⃣ `src/models/cart.js` — Cart Model

### General Concept
One Cart per User (unique `userId`). Contains an array of `{ bookId, quantity }` subdocuments.

### Project Application — [cart.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/cart.js)

- `userId`: unique — ONE cart per user (enforced at DB level)
- `books`: array of subdocuments with `bookId` (ref Book) and `quantity` (min 1)

### Interview Questions
1. **"Why is the cart a separate document instead of embedded in User?"**
   → Separation of concerns. The cart changes frequently (add/remove items) while user data is relatively static. Separate documents mean smaller writes and less lock contention.

2. **"What happens if two requests try to modify the same cart simultaneously?"**
   → Race condition! Both read the same cart, modify it, and save. The last save wins. The order service fixes this with transactions, but the cart controller does NOT use transactions.

3. **"Why `unique: true` on userId?"**
   → Ensures each user can only have ONE cart. Without this, calling `new Cart({ userId, books: [] })` multiple times could create duplicate carts.

---

## 15️⃣ `src/models/order.js` — Order Model

### General Concept
Records a completed purchase. Contains items (with `priceAtPurchase` — snapshot of price at buy time), shipping details, payment info, and status tracking.

### Project Application — [order.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/order.js)

**Key design decisions:**
- `priceAtPurchase` — not a reference to book price! Stores the price at the moment of purchase. If book price changes later, orders aren't affected.
- `status` enum: `processing` → `out_for_delivery` → `delivered` (enforced by `StateTransition` in controller)
- `paymentMethod`: `COD` or `credit_card`
- `paymentStatus`: `pending` or `success`

### Interview Questions
1. **"Why store `priceAtPurchase` instead of referencing the book's current price?"**
   → Prices change. An order placed at $10 should always show $10, even if the book price later changes to $15. This is called "denormalization for historical accuracy."

2. **"What is a MongoDB transaction and why is it used for order placement?"**
   → A transaction ensures ALL operations (check stock, decrement stock, create order, clear cart) either ALL succeed or ALL fail. Without it, you could have a scenario where stock is decremented but order creation fails — lost inventory.

3. **"How does the state machine pattern work in `updateOrderStatus`?"**
   → The `StateTransition` object maps valid transitions: `processing → out_for_delivery → delivered`. You can't skip states or go backwards. This prevents invalid state like "processing → delivered".

---

## 16️⃣ `src/models/review.js` — Review Model

### General Concept
User reviews for books with rating (1-5) and optional comment. Compound unique index ensures one review per user per book.

### Project Application — [review.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/models/review.js)

- **Line 29**: `reviewSchema.index({ user: 1, book: 1 }, { unique: true })` — compound unique index

### Interview Questions
1. **"What is a compound index and how does `{ user: 1, book: 1 }` work?"**
   → It creates ONE index on TWO fields together. `{ unique: true }` means the COMBINATION must be unique — same user can review different books, different users can review same book, but same user CANNOT review same book twice.

2. **"Why does the createReview controller also check `Order.exists()` for purchase verification?"**
   → Business rule: only users who bought AND received the book can review it. This prevents fake reviews. The query checks for `status: 'delivered'`.

3. **"How is the average rating calculated and what's the performance concern?"**
   → `getBookReviews` fetches ALL ratings for a book and computes the average in JavaScript. For a book with 10,000 reviews, this is inefficient. Better: use MongoDB `$avg` aggregation or store a pre-computed `averageRating` on the Book model.

---

## 🔧 SERVICES — Business Logic Layer

---

## 17️⃣ `src/services/auth.js` — JWT Token Service

### General Concept
Handles JWT (JSON Web Token) creation and verification. Separates token logic from controllers for reusability.

### Simple Example
```js
const generateToken = (user) => jwt.sign({ _id: user._id }, SECRET, { expiresIn: '90d' });
const verifyToken = (token) => jwt.verify(token, SECRET);
```

### Project Application — [auth.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/services/auth.js)

- **Line 6**: Token payload includes `_id`, `email`, `role`
- **Line 8**: Uses `JWT_EXPIRES_IN` from env (currently `90d` — 90 days)

### Code Flaws

> [!CAUTION]
> **FLAW — 90-day token expiration is TOO LONG**: If a token is stolen, the attacker has 90 days of access. Industry standard is 15 minutes for access tokens + a refresh token mechanism.

> [!WARNING]
> **FLAW — No token blacklist/revocation**: The `logout` endpoint in `controllers/auth.js` does NOTHING — it just returns 200. The token is still valid. True logout requires a blacklist (Redis set of revoked tokens) or short-lived tokens.

> [!WARNING]
> **FLAW — Email in JWT payload**: Including `email` in the JWT increases token size unnecessarily. The `_id` is sufficient to look up the user.

### Interview Questions
1. **"What are the three parts of a JWT?"**
   → Header (algorithm + type), Payload (data + iat + exp), Signature (HMAC of header + payload with secret). The signature is what prevents tampering.

2. **"What is the difference between `jwt.sign()` and `jwt.verify()`?"**
   → `sign()` creates a new token with a payload and secret. `verify()` checks the signature is valid and the token isn't expired, then returns the decoded payload.

3. **"How would you implement token refresh?"**
   → Issue TWO tokens on login: short-lived access token (15 min) and long-lived refresh token (7 days, stored in httpOnly cookie). When access token expires, client sends refresh token to get a new access token.

---

## 18️⃣ `src/services/order.js` — Order Placement Service (MongoDB Transaction)

### General Concept
The most complex piece of business logic. Uses a **MongoDB transaction** to atomically: validate cart → check stock → create order items → decrement stock → clear cart. If ANY step fails, ALL changes are rolled back.

### Simple Example
```js
const session = await mongoose.startSession();
session.startTransaction();
try {
  await Model.create([doc], { session });
  await session.commitTransaction();
} catch (e) {
  await session.abortTransaction();
}
```

### Project Application — [order.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/services/order.js)

- **Line 6-7**: Start a session + transaction
- **Line 10-13**: Find the user's cart (within the transaction session)
- **Line 16-30**: For each book in cart: verify it exists, verify stock is sufficient, snapshot the price
- **Line 32-38**: Decrement stock for each book using `$inc: { stock: -quantity }`
- **Line 40-47**: Create the order document (with `[{ }]` array syntax for transactions)
- **Line 49-50**: Clear the cart
- **Line 52**: Commit all changes at once

### Code Flaws

> [!CAUTION]
> **FLAW — Catch block masks the ORIGINAL error**: Line 56 catches any error and wraps it in a generic `ApiError(500, 'Failed to place order')`. If the original error was a 400 "Not enough stock", the user sees 500 "Failed to place order" instead. The original ApiError is lost. Fix: re-throw ApiErrors as-is and only wrap unknown errors.

```js
// FIX:
catch (error) {
  await session.abortTransaction();
  if (error instanceof ApiError) throw error; // preserve original
  throw new ApiError(500, 'Failed to place order');
}
```

> [!WARNING]
> **FLAW — Transaction requires MongoDB Replica Set**: `startSession()` only works with replica sets or MongoDB Atlas. A standalone local MongoDB instance will throw an error. This must be documented.

### Interview Questions
1. **"What is ACID and how does MongoDB transaction ensure it?"**
   → Atomicity (all or nothing), Consistency (valid state), Isolation (no interference), Durability (persisted). MongoDB multi-document transactions provide ACID guarantees across multiple collections.

2. **"Why pass `{ session }` to every query inside the transaction?"**
   → Without `{ session }`, the query runs OUTSIDE the transaction. It won't see uncommitted changes and won't be rolled back if the transaction aborts.

3. **"Why use `Order.create([{...}], { session })` with an ARRAY instead of `Order.create({...})`?"**
   → Mongoose's `Model.create()` only accepts `options` (including `session`) when you pass an array of documents. The single-object form `create({})` doesn't accept options as a second argument.

---

## 🛠️ UTILS — Shared Helpers

---

## 19️⃣ `src/utils/ApiError.js` — Custom Error Class

### General Concept
Extends JavaScript's `Error` class to add `statusCode`, `status`, and `isOperational` properties. This lets the error handler distinguish between "expected" errors (bad input, not found) and "unexpected" bugs.

### Project Application — [ApiError.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/utils/ApiError.js)

- **Line 5**: `status` is `'fail'` for 4xx codes, `'error'` for 5xx
- **Line 6**: `isOperational = true` — marks it as a "known" error
- **Line 7**: `Error.captureStackTrace` — removes this constructor from the stack trace for cleaner debugging

### Interview Questions
1. **"Why extend the built-in Error class instead of using plain objects?"**
   → Extending Error gives you proper stack traces, `instanceof` checks, and compatibility with `throw` / `try-catch`. Plain objects don't have stack traces.

2. **"What does `Error.captureStackTrace(this, this.constructor)` do?"**
   → It captures the stack trace but excludes the ApiError constructor itself from the trace. The stack starts from where `new ApiError()` was CALLED, not from inside the constructor.

3. **"What is `isOperational` used for?"**
   → The error handler checks `isOperational` in production. If true, it sends the error message to the client. If false (a bug), it sends "something went wrong" to avoid leaking internal details.

---

## 20️⃣ `src/utils/ApiResponse.js` — Standardized Response

### General Concept
Creates a consistent response shape for ALL successful API responses: `{ success, message, data, pagination }`.

### Project Application — [ApiResponse.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/utils/ApiResponse.js)

- `success`: boolean derived from statusCode < 400
- `pagination`: only included if provided (conditional property)

### Interview Questions
1. **"Why use a response wrapper instead of sending raw data?"**
   → Consistency. Every client knows to check `response.success`, read `response.data`, handle `response.message`. Without it, some endpoints might return `{ user }`, others `{ books }` — inconsistent.

2. **"Why is `pagination` conditionally added?"**
   → Not all responses have pagination (single-resource GETs). Adding a null `pagination` field to every response is noise.

3. **"How would you add rate-limit headers to this response?"**
   → You wouldn't do it here — that's middleware's job. But you could extend the response with `meta: { rateLimit: { remaining, reset } }` for API clients.

---

## 21️⃣ `src/utils/pagination.js` — Reusable Pagination

### General Concept
A generic function that takes any Mongoose model + filter + options and returns paginated results with metadata (totalDocuments, totalPages, hasNext, hasPrev).

### Project Application — [pagination.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/utils/pagination.js)

- Uses `Promise.all` to run `find()` and `countDocuments()` in parallel (good!)
- **Line 2**: `skip = (page - 1) * limit` — standard offset pagination formula

### Code Flaws

> [!WARNING]
> **FLAW — No default values for page/limit**: If `page` or `limit` are `undefined` (not passed), `skip` becomes `NaN` and the query breaks. Some callers pass defaults, but the function itself should have defaults like `page = 1, limit = 10`.

> [!WARNING]
> **FLAW — Offset pagination is slow on large datasets**: `skip(10000)` forces MongoDB to scan and discard 10,000 documents. For large collections, use cursor-based pagination (keyset pagination) with `_id` or `createdAt`.

### Interview Questions
1. **"What is the difference between offset pagination and cursor-based pagination?"**
   → Offset: `skip(N).limit(M)` — simple but slow for large offsets, inconsistent with real-time inserts. Cursor: uses a pointer (`{ _id: { $gt: lastId } }`) — always fast O(1), but you can't jump to "page 50".

2. **"Why use `Promise.all` for find + countDocuments?"**
   → Both are independent DB queries. Running them in parallel (Promise.all) takes ~1x the time of the slower query. Running them sequentially takes ~2x.

3. **"What happens when `page` exceeds `totalPages`?"**
   → The function returns an empty `data` array but correct `pagination` metadata. The caller should check `hasNext` before requesting the next page.

---

## 22️⃣ `src/utils/errorHelpers.js` — Error Formatting

### General Concept
Helper functions used by `errorHandler.js` to format errors differently for development vs. production, plus transformers for common MongoDB errors.

### Project Application — [errorHelpers.js](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-backend/src/utils/errorHelpers.js)

- `devError()` — returns EVERYTHING: status, full error object, message, stack trace
- `productionError()` — only returns message for operational errors; "something went wrong" for bugs
- `handleCastErrorDB()` — "Invalid ObjectId" → 400
- `handleDuplicateFieldsDB()` — "Duplicate email" → 409
- `handleValidationErrorDB()` — Mongoose validation errors → 400

### Interview Questions
1. **"Why show stack traces in development but not production?"**
   → Stack traces contain file paths, line numbers, and internal logic — gold for attackers. In development, they help you debug. In production, they're a security risk.

2. **"What MongoDB error code is 11000?"**
   → Duplicate key error. Triggered when you try to insert a document that violates a unique index (e.g., registering with an email that already exists).

3. **"What is a CastError in Mongoose?"**
   → Thrown when you pass an invalid type where an ObjectId is expected. For example, `Book.findById('not-a-valid-id')` throws a CastError because `'not-a-valid-id'` isn't a valid 24-character hex string.
