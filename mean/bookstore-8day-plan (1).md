# 📚 Online Bookstore — 8-Day Project Plan

---

## 👥 Team Assignments

|              | Person 1                                                                 | Person 2                                                                                   | Person 3                                                                    | Person 4                                           |
| ------------ | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------- | -------------------------------------------------- |
| **Backend**  | Auth routes + middleware + error handling + utilities                    | Books + Categories routes and schemas                                                      | Cart + Orders routes, schemas, and utilities                                | Authors + Reviews + Upload routes and schemas      |
| **Frontend** | Core infrastructure + Login + Register + Profile + all TypeScript models | BookService + Home + Book List + Book Detail + BookCard + StarRating + Frontend deployment | CartService + Navbar + Cart + Checkout + Order History + Backend deployment | AdminService + All Admin tables + Review component |

---

## 📋 Shared Contracts
> Agreed on Day 1 — never changed after this

- Every **successful** API response returns: `success`, `message`, `data`, and optionally `pagination`
- Every **error** response returns: `success: false`, `message`, and `errors`
- The **JWT payload** always contains: `_id`, `email`, and `role`
- **Pagination** always uses query params: `page` and `limit`
- Every route starts with `/api/`
- Token is stored in `localStorage` under the key `jwt_token`
- Authorization header format is always: `Bearer <token>`
- Dates are always returned in **ISO 8601** format

---

## 🗂 Project Folder Structure

### Backend

```
backend/
├── src/
│   ├── config/
│   │   ├── db.js                ← Person 1
│   │   └── cloudinary.js        ← Person 4
│   ├── middleware/
│   │   ├── authenticate.js      ← Person 1
│   │   ├── authorize.js         ← Person 1
│   │   ├── errorHandler.js      ← Person 1
│   │   └── logger.js            ← Person 3
│   ├── modules/
│   │   ├── auth/                ← Person 1
│   │   ├── books/               ← Person 2
│   │   ├── categories/          ← Person 2
│   │   ├── authors/             ← Person 4
│   │   ├── cart/                ← Person 3
│   │   ├── orders/              ← Person 3
│   │   ├── reviews/             ← Person 4
│   │   └── upload/              ← Person 4
│   ├── utils/
│   │   ├── ApiError.js          ← Person 1
│   │   ├── ApiResponse.js       ← Person 3
│   │   └── pagination.js        ← Person 3
│   └── app.js
├── .env
├── .env.example
├── .eslintrc.json
├── .gitignore
├── package.json
└── README.md
```

### Frontend

```
frontend/
└── src/app/
    ├── core/                              ← Person 1
    │   ├── services/auth.service.ts
    │   ├── guards/auth.guard.ts
    │   ├── guards/admin.guard.ts
    │   ├── interceptors/token.interceptor.ts
    │   ├── interceptors/error.interceptor.ts
    │   └── models/                        ← Person 1 writes ALL interfaces
    ├── features/
    │   ├── auth/                          ← Person 1
    │   ├── books/                         ← Person 2
    │   ├── cart/                          ← Person 3
    │   ├── orders/                        ← Person 3
    │   └── admin/                         ← Person 4
    └── shared/components/
        ├── navbar/                        ← Person 3
        ├── book-card/                     ← Person 2
        ├── star-rating/                   ← Person 2
        └── review-section/               ← Person 4
```

---

## 🗄 Database Schemas
> All decided together on Day 1. No schema changes allowed after this.

### User — Person 1
| Field | Details |
|---|---|
| `email` | unique, indexed, required |
| `firstName`, `lastName` | required |
| `dob` | required |
| `password` | hashed with bcrypt, never returned in responses |
| `role` | `"user"` or `"admin"`, defaults to `"user"` |
| `isVerified` | boolean, defaults to `false` (bonus feature) |

### Category — Person 2
| Field | Details |
|---|---|
| `name` | unique, required |

### Book — Person 2
| Field | Details |
|---|---|
| `name` | required, text index for search |
| `price` | required, must be positive, regular index for range filtering |
| `stock` | required, integer, minimum 0 |
| `coverImage` | Cloudinary URL, required |
| `author` | reference to Author, required |
| `category` | reference to Category, can be null if category is deleted |

### Author — Person 4
| Field | Details |
|---|---|
| `name` | required |
| `bio` | required |

### Cart — Person 3
| Field | Details |
|---|---|
| `user` | one-to-one, each user has one cart document |
| `items` | array of `{ book: ref, quantity: number }` |

### Order — Person 3
| Field | Details |
|---|---|
| `user` | reference to User |
| `items` | array of `{ book, quantity, priceAtPurchase }` — price snapshot, never changes |
| `shippingDetails` | `{ fullName, address, city, phone }` |
| `status` | enum: `"processing"` → `"out_for_delivery"` → `"delivered"` |
| `paymentMethod` | defaults to `"COD"` |
| `paymentStatus` | enum: `"pending"`, `"success"` |
| `createdAt` | timestamp |

### Review — Person 4
| Field | Details |
|---|---|
| `user` | reference to User |
| `book` | reference to Book |
| `rating` | number 1–5 only |
| `comment` | optional, maximum 500 characters |
| **Index** | compound unique index on `(user, book)` — enforced at DB level |

---

## 📅 Day 1 — Group Architecture + Individual Setup
> First 2 hours: everyone together. Then split into individual tasks.

### 🤝 Everyone (First 2 Hours — Mandatory)
- Person 2 draws the ERD while everyone watches and corrects in real time
- Lock all 7 schemas — **no schema changes allowed after this meeting**
- Write down and agree on all shared contracts listed above
- Write down all route URLs for every module and have everyone confirm them
- Create both GitHub repositories
- Set up branch structure: `main → dev → feature/auth`, `feature/catalog`, `feature/commerce`, `feature/reviews-admin`
- Everyone clones both repos and confirms they run locally before the meeting ends

---

### 👤 Person 1
- Initialize Node.js project, install packages: `express`, `mongoose`, `bcryptjs`, `jsonwebtoken`, `joi`, `dotenv`, `cors`, `helmet`
- Create the DB connection file (logs success, exits on failure)
- Build `ApiError` — custom error class with `statusCode`, `message`, and optional `errors` array. Every controller throws this
- Build `errorHandler` middleware — handles `ApiError` instances, maps MongoDB code 11000 to 409, returns generic 500 for unknown errors, never exposes stack traces in production
- Build `authenticate` middleware — reads Authorization header, verifies JWT, attaches decoded user to `req.user`, throws 401 for missing/expired/invalid token
- Build `authorize` middleware — accepts role names, throws 403 if `req.user.role` not in list
- Set up `app.js` with `helmet`, `cors`, JSON body parser, placeholder router mounts, and `errorHandler` as the very last middleware
- Create `.env.example` with all required keys. Add `.env` to `.gitignore` immediately
- **Push middleware and utils to `dev` branch immediately — everyone else pulls before writing any controller**

---

### 👤 Person 2
- Build the Category schema (unique name field)
- Build the Book schema (all fields, text index on name, regular index on price, correct references to Author and Category)
- Finalize the ERD — all 7 collections, all fields, labeled relationship arrows
- Export ERD as PNG and add to backend repo root
- Create Angular project with routing and SCSS: `ng new bookstore-frontend --routing --style=scss`
- Install Angular Material and choose a theme
- Configure main routing file with lazy-loaded routes for: auth, books, cart, orders, admin
- Generate component files for: Home, Book List, Book Detail, BookCard, StarRating

---

### 👤 Person 3
- Build the Cart schema (one cart per user, items array with book reference and quantity)
- Build the Order schema — include `priceAtPurchase` on each item
- Build `ApiResponse.js` — utility with static `success()` method for consistent response shapes
- Build `pagination.js` — takes model, query, options, page, limit. Runs two parallel queries (data + count). Returns data + `{ total, page, limit, totalPages, hasNext, hasPrev }`
- Build `logger.js` using `pino` + `pino-http` with colorized output in dev mode
- Study MongoDB transaction patterns — write pseudocode because you implement this on Day 2
- Generate module and component files for: Cart, Checkout, Order History, Navbar

---

### 👤 Person 4
- Build the Author schema (name and bio)
- Build the Review schema with compound unique index on `(user, book)`
- Set up Cloudinary config file using three env vars: `cloud_name`, `api_key`, `api_secret`
- Test pre-signed URL generation locally — generate signature + timestamp, upload test image directly to Cloudinary without routing through your server, confirm `secure_url` returned
- Generate Admin module with routing and four components: `manage-books`, `manage-authors`, `manage-categories`, `manage-orders`
- Generate `review-section` component in shared folder
- Set up admin layout with `mat-sidenav` sidebar shell and navigation links

---

## 📅 Day 2 — Backend Routes

### 👤 Person 1
- Build the User schema
- Build Joi validation schemas:
  - **Register:** valid email format, firstName/lastName 2–50 chars, dob must be a past date, password min 8 chars with at least one uppercase + lowercase + number
  - **Login:** email and password both required
  - **Update Profile:** same optional fields as register, at least one must be present
- Build auth service: `hashPassword()` (bcrypt 12 rounds), `comparePassword()`, `generateToken()` (payload: `_id`, `email`, `role`)
- Build **Register** controller: validate → check email unique (409 if exists) → hash password → create user → strip password from response → return 201
- Build **Login** controller: validate → find user by email (401 if not found, never say which field is wrong) → compare passwords (401 on mismatch) → generate JWT → strip password → return 200 with token and user
- Build **Logout** controller — return 200 only, token removal is the client's responsibility
- Build **Update Profile** controller: `authenticate` runs first → validate body → find by `req.user._id` → update only provided fields → return updated user without password
- Build routes file and mount router in `app.js`

---

### 👤 Person 2
- Build category Joi validation: `createCategory` requires name 2–100 chars, `updateCategory` same rule
- **Create Category** — validate, create, return 201 (unique index handles duplicates via `errorHandler`)
- **Get All Categories** — find all sorted alphabetically, return 200
- **Update Category** — validate, find by ID and update, 404 if not found
- **Delete Category** — find (404 if missing) → `Book.updateMany` sets category to `null` on linked books → delete → return message explaining linked books are now uncategorized
- Build category routes with `authenticate` + `authorize('admin')` on all write operations
- Build book Joi validation: `createBook` requires all fields including valid URI for `coverImage` and valid ObjectIds for author and category. `updateBook` makes all fields optional but requires at least one
- Build book service with a function that constructs the MongoDB query object from filter params (handles text search, category, author, price range)
- **Create Book** — validate → verify author exists (404) → verify category exists if provided (404) → create → return with populated author and category → 201
- **Get All Books** — extract page, limit, filter params → build query → run paginated query and count in parallel → return data and pagination
- **Get Single Book** — find by ID with populated author and category, 404 if not found
- **Update Book** — validate, find and update, 404 if not found, return populated book
- **Delete Book** — find and delete, 404 if not found, return success message
- Build book routes file with auth middleware on admin-only operations

---

### 👤 Person 3
- Build cart Joi validation: `addToCart` requires valid `bookId` and `quantity` ≥ 1
- **View Cart** — find cart by user ID → if no cart return empty cart with zero total → populate each item's book (name, price, coverImage, stock) → calculate total → return
- **Add to Cart** — validate → find book (404) → check stock sufficient (400) → find or create cart → if book already in cart increase quantity (cap at stock) → if new push to items → save, populate, return
- **Remove from Cart** — find cart, filter out matching `bookId`, save and return
- Build cart routes with `authenticate` on all three routes
- Build order Joi validation: `placeOrder` requires `shippingDetails` with fullName, address, city, phone. `updateStatus` allows `"out_for_delivery"` or `"delivered"` and `paymentStatus` `"success"`
- Build the **order transaction service:**
  1. Start MongoDB session + `session.startTransaction()`
  2. Find user's cart with books populated — abort + 400 if empty
  3. For each cart item: find book with session (404 if missing) → check stock (abort + 400 with book name if insufficient) → reduce stock and save with session → build order item with `priceAtPurchase` snapshot
  4. Create order document with session
  5. Delete cart with session
  6. `session.commitTransaction()`
  7. On any error: `session.abortTransaction()` and re-throw
  8. Always call `session.endSession()` in `finally` block

---

### 👤 Person 4
- Build author Joi validation: `createAuthor` requires name (2–100 chars) and bio (10–1000 chars). `updateAuthor` makes both optional but requires at least one
- **Create Author** — validate, create, return 201
- **Update Author** — validate, find by ID and update, 404 if not found
- **List Authors** — find all sorted alphabetically, return 200
- Build author routes with `authenticate` + `authorize('admin')` on write operations
- Build review Joi validation: `addReview` requires rating 1–5, comment optional max 500 chars
- **Add Review** — validate → check book exists (404) → check user has at least one order with status `"delivered"` containing this `bookId` (403 if not) → create review → if duplicate key error return 409 "You have already reviewed this book" → populate user name → return 201
- **View Reviews** — check book exists → find all reviews for `bookId` sorted newest first with user firstName/lastName populated → calculate average rating → return reviews, `averageRating` (1 decimal), and count
- **Delete Review** — find (404) → verify `review.user` matches `req.user._id` (403 if not) → delete → return 200
- **Upload** — generate Cloudinary signature using current timestamp + API secret → return `{ signature, timestamp, cloudName, apiKey, folder }` to client so client uploads directly to Cloudinary without going through your server
- Build upload routes with `authenticate` + `authorize('admin')`

---

## 📅 Day 3 — Backend Finishes + Frontend Core Starts

> After today Person 1 is fully on frontend. If teammates have auth bugs, they read `authenticate.js` and `authorize.js` themselves first.

### 👤 Person 1
- Write **all TypeScript interfaces** in `core/models/`: User, Book, Author, Category, CartItem, Cart, OrderItem, ShippingDetails, Order, Review. Everyone imports from these — nobody defines their own
- Build **AuthService:**
  - `register()` — POST to register endpoint
  - `login()` — POST, on success save token to `localStorage`
  - `logout()` — remove token from `localStorage`, navigate to login
  - `getToken()` — read from `localStorage`
  - `getCurrentUser()` — decode JWT payload from stored token and return user object. **Never call the API for this**
  - `isLoggedIn()` — returns whether a token exists
  - `isAdmin()` — checks decoded user's `role === "admin"`
  - `updateProfile()` — PATCH to profile endpoint
- Build **TokenInterceptor** — intercepts every outgoing HTTP request, clones it and adds the Authorization header if a token exists. This makes auth work transparently across the whole app
- Build **ErrorInterceptor** — on 401: call `authService.logout()`. On 403: navigate home and show snackbar message
- Build **AuthGuard** — checks `isLoggedIn()`, redirects to `/auth/login` if false
- Build **AdminGuard** — checks `isAdmin()`, redirects to home if false
- Register both interceptors in `app.module.ts` providers so they apply globally
- Build **Login page:** reactive form (email + password) → field-level `mat-error` messages → spinner on submit button while loading → form disabled while loading → navigate to `/books` on success → show server error below form → link to register page
- Build **Register page:** reactive form (email, firstName, lastName, dob, password) → navigate to login on success with success snackbar → show server error on failure

---

### 👤 Person 2
- Finish any remaining book controller logic from Day 2
- Test every catalog route in Postman:
  - Create category as admin → 201
  - Create same category name again → 409
  - Get all categories → 200 with array
  - Update category → 200 with updated data
  - Delete category → 200, confirm linked books have `null` category in DB
  - Create author → 201, update → 200, get all → 200
  - Create book with valid author + category → 201 with populated data
  - Create book with non-existent author ID → 404
  - Search books by partial name → relevant results only
  - Filter by category, author, price range → correct books only
  - Paginate → page 2 returns different books than page 1
  - Get single book → populated author and category shown
  - Update book as admin → changes reflected
  - Delete book as admin → 200
  - Create book as regular user → 403
- Mount all catalog routers in `app.js`

---

### 👤 Person 3
- **Place Order** controller — validate body, call transaction service, return 201 with created order
- **View My Orders** — find orders by `req.user._id` → sort newest first → paginate → populate book name and `coverImage` → return with pagination
- **Get All Orders (admin)** — find all, support optional status filter from query params → paginate → populate user (firstName, lastName, email) and book name → return with pagination
- **Update Order Status** — validate → find order (404) → enforce transitions: `processing → out_for_delivery` only, `out_for_delivery → delivered` only, `delivered → nowhere` (400 on invalid) → update and save → return updated order
- Build routes file — register `/my` BEFORE `/:id` to prevent Express treating "my" as an ID param
- Mount order and cart routers in `app.js`
- Test full order flow in Postman:
  - Add books to cart → place order → "processing" status created
  - Verify book stock reduced in DB
  - Verify cart is empty after order
  - Place order with zero-stock book → 400
  - Test all invalid status transitions → confirm 400

---

### 👤 Person 4
- Test every review and upload route in Postman:
  - Add review without login → 401
  - Add review for book never ordered → 403
  - Add review for book with order status "processing" → 403
  - Add review for book with "delivered" order → 201
  - Add second review for same book → 409
  - Get reviews → reviews array, averageRating, and count all correct
  - Delete own review → 200
  - Delete another user's review → 403
  - Get pre-signed URL as admin → returns signature, timestamp, cloudName, apiKey, folder
  - Use signature to upload test image → confirm `secure_url` returned
  - Create book using that URL as `coverImage` → confirm it works
- Mount author, review, and upload routers in `app.js`
- Build **Admin Panel layout** with `mat-sidenav`: sidebar with navigation links to Books, Authors, Categories, Orders — main content area with router outlet — placeholder table components for each section so routing works

---

## 📅 Day 4 — Frontend Feature Pages
> Use mock data today. Do not wire to the real API yet — that is Day 5. Focus on getting the UI right.

### 👤 Person 1
- Build **Profile page:** on init read user from `authService.getCurrentUser()` (no API call) → pre-fill form with firstName, lastName, dob → show email as read-only → on submit call `updateProfile()` → success snackbar or error message
- Polish Login and Register pages: every field must have a `mat-error` → submit button shows spinner and is disabled while loading → form disabled during loading

---

### 👤 Person 2
- Build **StarRatingComponent:** inputs `rating` (number) and `readonly` (boolean) → output `ratingChange` event → readonly mode: display filled/empty stars, no interaction → interactive mode: stars clickable with hover preview → Angular Material icons, gold filled, gray empty
- Build **BookCardComponent:** input `book` object → output `addToCart` event → display cover image (fixed height, `object-fit: cover`), book name, author name, category (fallback "Uncategorized"), StarRating readonly, price → show "Out of Stock" + disable button when `stock === 0` → clicking card navigates to detail, clicking button emits event
- Build **Home page** (mock data): Popular Books grid of BookCards + "View All Books" button — Popular Authors section with 4 author cards showing name and truncated bio
- Build **Book List page** (mock data): filter sidebar (search input, category checkboxes, author checkboxes, min/max price inputs, Apply + Clear buttons) — main area with BookCard grid, "No books found" empty state, pagination with prev/next and "Page X of Y"

---

### 👤 Person 3
- Build **Navbar:** logo on left → Books always visible → not logged in: Login + Register → logged in: Cart (item count badge), My Orders, Profile, Logout → admin: also Admin Panel → `routerLinkActive` on current page → cart badge subscribes to `cartCount$` from CartService
- Build **CartService:** `BehaviorSubject` starting at 0 for item count → `cartCount$` observable → method stubs: `getCart()`, `addToCart()`, `removeFromCart()`, `refreshCartCount()`
- Build **Cart page** (mock data): items list (cover, name, author, price, quantity, subtotal, remove button) — order summary panel (subtotal, "Shipping: Free", total) — "Proceed to Checkout" + "Continue Shopping" — empty state with "Browse Books" button
- Build **Checkout page** (mock data): left column reactive form (Full Name, Address, City, Phone with validation) — right column order summary (items, quantities, total, "Payment: Cash on Delivery") — "Place Order" button shows spinner while loading and is disabled after first click to prevent double submission
- Build **Order History page** (mock data): expandable accordion panels — header shows short order ID, date, total, colored status badge (blue=processing, orange=out_for_delivery, green=delivered) — expanded shows items with quantities + prices at purchase + shipping address — "No orders yet" empty state with "Start Shopping"

---

### 👤 Person 4
- Build **AdminService** with method stubs for all operations: `getBooks`, `createBook`, `updateBook`, `deleteBook`, `getPresignedUrl`, `getAuthors`, `createAuthor`, `updateAuthor`, `getCategories`, `createCategory`, `updateCategory`, `deleteCategory`, `getAllOrders`, `updateOrderStatus`
- Build **Manage Books table:** `mat-table` columns: Cover thumbnail, Name, Author, Price, Stock, Actions — "Add New Book" button — edit button opens dialog, delete button shows confirmation dialog first
- Build **Book Dialog:** fields (Name, Price, Stock, Author dropdown, Category dropdown) — file input for image upload → show preview on select → show progress bar while uploading → store returned URL in form → on save call create or update depending on context
- Build **Manage Authors table:** columns Name, Bio (truncated), Actions — "Add Author" button opens dialog with name and bio textarea
- Build **Manage Categories table:** columns Name, Actions — "Add Category" button — delete shows warning "Books linked to this category will become uncategorized"
- Build **Manage Orders table:** columns Order ID, Customer Name, Date, Items count, Total, Status, Payment Status, Actions — status update dropdown in Actions column
- Build **Review Section component shell** (mock data): input `bookId` — display average rating — conditional review form (clickable StarRating + comment textarea max 500 chars) — each review shows: reviewer name, star rating, date, delete button on own reviews only — "Login to leave a review" for logged-out users — "Purchase this book to leave a review" for users without a purchase — hide form and show own review with delete if already reviewed

---

## 📅 Day 5 — Wire Everything to Real API

### 👤 Person 1
- Wire **Profile page** to real API: decode token on init, pre-fill form, handle success and error on submit
- Spot check every other person's pages with DevTools open:
  - Protected routes include the Authorization header in every request
  - Public routes do not include the header
  - A 401 response correctly logs the user out and redirects to login
  - A 403 shows the appropriate message without crashing the app
- Wire cart count to Navbar by subscribing to `cartService.cartCount$` via async pipe
- Ensure `refreshCartCount()` is called when the user logs in

---

### 👤 Person 2
- Build **BookService**, **CategoryService**, **AuthorService** with real HttpClient calls — `BookService.getBooks()` converts params object to `HttpParams`, all other methods are straightforward GET/POST/PATCH/DELETE
- Wire **Home page:** on init call `getBooks()` (limit 8) and `getAuthors()`, use real responses to populate both sections
- Wire **Book List page:** on init call `getCategories()` + `getAuthors()` for filter sidebar → on init call `loadBooks()` → search uses RxJS Subject with `debounceTime(400ms)` + `distinctUntilChanged()` → filter and page changes call `loadBooks()` with updated params → loading and error states
- Wire **Book Detail page:** on init read book ID from route params and call `getBook(id)` → "Add to Cart" calls `cartService.addToCart()`, redirect to login if not logged in → success snackbar → show server error on failure

---

### 👤 Person 3
- Wire **Cart page:** on init check login (redirect if not) → call `getCart()` → remove button calls `removeFromCart(bookId)` → show empty state when items array is empty
- Wire **Checkout page:** on init call `getCart()` to populate summary panel → Place Order calls `orderService.placeOrder()` with shipping form values → on success: snackbar + navigate to `/orders` → on error: show in snackbar + re-enable button → disable button immediately on click, only re-enable on error
- Wire **Order History page:** on init call `getMyOrders()` → show loading state → show empty state if no orders
- **Deploy backend to Railway:**
  1. Push all backend code to GitHub
  2. Create new Railway project connected to backend repository
  3. Add all env vars: `MONGO_URI`, `JWT_SECRET`, `JWT_EXPIRES_IN`, `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`, `PORT`, `NODE_ENV`, `FRONTEND_URL`
  4. Confirm logs show "MongoDB connected" and "Server running"
  5. Test that the live URL responds correctly
  6. Share live backend URL with Person 2

---

### 👤 Person 4
- Wire **Manage Books table:** on init call `getBooks()` + load authors and categories for dialog dropdowns → reload books list after dialog closes with a save or delete
- Wire **Book Dialog image upload:**
  1. File selected → show preview via `FileReader`
  2. Call `adminService.getPresignedUrl()` to get signature data
  3. POST file directly to Cloudinary's upload endpoint using the signature (not through your backend)
  4. Extract `secure_url` and store in form
  5. Show progress bar during upload, clear on done
  6. On failure: show error message and allow retry
- Wire Manage Authors and Categories tables the same way as books
- Wire **Manage Orders table:** load on init → status dropdown calls `updateOrderStatus()` and reloads on success
- Wire **Review Section component:**
  - On init call reviews endpoint for `bookId` and display results
  - If logged in, call `getMyOrders()` and check if any order has status `"delivered"` and contains this `bookId` → set `hasPurchased`
  - Check if user already has a review in the loaded list → set `alreadyReviewed`
  - Submit calls reviews POST endpoint, on success reload
  - Delete calls delete endpoint, reloads on success
- Place `<app-review-section [bookId]="bookId">` inside Person 2's Book Detail page at the bottom

---

## 📅 Day 6 — Full Integration Testing
> No new features. Fix bugs only. Work through every item as a team.

### Auth Flow
- [ ] Register with valid data → success toast → redirected to login
- [ ] Register with duplicate email → "Email already in use" shown in form
- [ ] Register with weak password → validation message shown under password field
- [ ] Login with correct credentials → token in localStorage → redirected to books
- [ ] Login with wrong password → "Invalid credentials" shown in form
- [ ] Navigate to `/orders` without login → redirected to `/auth/login`
- [ ] Navigate to `/admin` as regular user → redirected to home
- [ ] Login as admin → "Admin Panel" link appears in navbar
- [ ] Admin navigates to `/admin` → admin panel loads correctly
- [ ] Logout → token removed → protected pages redirect to login
- [ ] Profile update → new name shown after save

### Catalog Flow
- [ ] Admin creates author → appears in authors table immediately
- [ ] Admin creates category → appears in categories table
- [ ] Admin creates book with Cloudinary image → book card shows cover correctly
- [ ] Admin edits book → changes reflected in table
- [ ] Admin deletes book → removed from table
- [ ] Books page loads with real books from API
- [ ] Search by partial book name → relevant results shown
- [ ] Filter by category → only that category's books shown
- [ ] Filter by author → only that author's books shown
- [ ] Filter by price range → correct books shown
- [ ] Clear filters → all books return
- [ ] Pagination: page 2 shows different books than page 1
- [ ] Book detail page loads all correct info: name, cover, author, category
- [ ] Admin deletes a category → linked books show "Uncategorized" and are not deleted

### Commerce Flow
- [ ] Logged-in user clicks "Add to Cart" → success toast shown
- [ ] Cart count badge in navbar increments
- [ ] Cart page shows added item with correct price
- [ ] Add same book again → quantity increases, not a second line item
- [ ] Remove item → cart updates and total recalculates
- [ ] Empty cart → empty state shown
- [ ] Checkout page shows correct items and total matching cart
- [ ] Submit checkout with empty fields → validation errors shown under each field
- [ ] Place order → loading spinner → redirected to `/orders`
- [ ] Order appears in history with "processing" status badge
- [ ] Book stock reduced in DB (verify via admin books table)
- [ ] Cart is empty after successful order
- [ ] Admin sees order in manage-orders table
- [ ] Admin changes status to "out_for_delivery" → user sees update on next refresh
- [ ] Admin changes status to "delivered" → user sees update
- [ ] Admin tries to reverse "delivered" back → blocked with 400 error
- [ ] Place order with out-of-stock book → proper error message shown

### Review Flow
- [ ] Logged-out user on book detail → "Login to leave a review"
- [ ] Logged-in user with no purchase → "Purchase this book to leave a review"
- [ ] User with order status "processing" → blocked message still shown
- [ ] Admin sets order to "delivered" → review form appears on refresh
- [ ] Submit review → appears in reviews list
- [ ] Average rating updates correctly after submission
- [ ] Review form disappears after submission
- [ ] User tries to review same book again → "You have already reviewed this book"
- [ ] Only user's own review shows a delete button
- [ ] Delete own review → disappears from list and average updates

### Upload Flow
- [ ] Admin opens "Add Book" dialog → image upload button visible
- [ ] Select image → preview shows immediately
- [ ] Progress bar appears and disappears on upload complete
- [ ] Save book → book appears with correct cover from Cloudinary
- [ ] Non-admin cannot reach `/admin` → guard redirects before they see anything

---

## 📅 Day 7 — Polish + Deployment

### 👤 Person 1
- Review every error message across all pages — no raw error objects shown to users anywhere
- All errors must be either a `mat-snackbar` message or an inline `mat-error` under a form field
- Verify every submit button across every form has a spinner and is disabled during requests
- Add a **404 Not Found page** and a wildcard route at the very bottom of the routing configuration
- Write **Backend README:** tech stack, setup steps (clone → copy `.env.example` → fill values → install → run), description of every env var, live API URL, Postman collection location, summary table of all routes grouped by module

---

### 👤 Person 2
- Make books grid responsive: 4 columns desktop → 2 tablet → 1 mobile
- Ensure all book cover images use `object-fit: cover` with a fixed height for consistent display
- Add loading state while books are fetching
- **Deploy frontend to Vercel:**
  1. Update `environment.prod.ts` with live backend URL from Person 3
  2. Confirm `environment.ts` still points to localhost
  3. Run `ng build --configuration=production` and confirm no errors
  4. Connect frontend GitHub repo to Vercel dashboard with correct output directory
  5. Test every page on the live Vercel URL and confirm no CORS errors in browser console
- **Export ERD** as high-resolution PNG → add to backend repo root → reference it in backend README

---

### 👤 Person 3
- Make cart page stack vertically on mobile: items list on top, summary panel below
- Ensure checkout "Place Order" button is disabled immediately on first click and only re-enabled on error response
- Make order status badge colors readable on all screen sizes
- Write **Frontend README:** tech stack, setup steps (clone → install → update env file → run dev), production build command, live app URL, brief feature list

---

### 👤 Person 4
- Make admin sidebar collapsible on mobile with hamburger toggle in toolbar
- All admin tables scroll horizontally on mobile instead of breaking layout
- Build **complete Postman collection** organized into folders: Auth, Categories, Authors, Books, Cart, Orders, Reviews, Upload — every route has correct HTTP method, `{{baseUrl}}` URL, request body where needed, Authorization header on protected routes — login request has test script that auto-saves token to `{{token}}` — admin login saves to `{{adminToken}}` separately — export as JSON and add to backend repository

---

## 📅 Day 8 — Final Checks + Bonus Features

### Everyone — Morning Checklist
> Run the entire Day 6 test checklist again on **LIVE deployed URLs only** — not localhost

**Code Quality**
- [ ] Every team member has at least 5 meaningful commits on each repo
- [ ] Commit messages are clean and descriptive
- [ ] No `console.log()` statements anywhere in production code
- [ ] `.env` file is NOT in the repository
- [ ] `.env.example` has all required keys with placeholder values only
- [ ] Both repos have `.gitignore` covering `node_modules`, `.env`, and `dist/`
- [ ] ESLint passes on backend with zero errors
- [ ] `ng lint` passes on frontend with zero errors

**Deliverables**
- [ ] Postman collection imports without errors and all requests run successfully
- [ ] README setup instructions work — follow them from scratch to verify
- [ ] ERD image is in the repository and readable at normal zoom

**Live Deployment**
- [ ] All routes return correct status codes: 200 (GET), 201 (create), 400 (validation), 401 (no token), 403 (wrong role), 404 (not found), 409 (duplicate)
- [ ] Images load from Cloudinary URLs on live frontend
- [ ] No mixed content errors — all URLs are HTTPS
- [ ] CORS works correctly between live frontend and live backend
- [ ] App works on mobile screen size

---

### Everyone — Afternoon Bonus Features
> Only begin if the deployed app passes **every check above**

**Priority 1 — Email Verification (Person 1)**
- On register: generate random verification token, save to user document, send email via Nodemailer with link containing the token
- Add `GET /api/auth/verify/:token`: find user by token, set `isVerified: true`, clear token
- In login: if `isVerified === false`, return 403 "Please verify your email first"
- Frontend: after registration navigate to "Check Your Email" page instead of login

**Priority 2 — Payment Gateway (Person 3)**
- Install Stripe Node.js library
- Add route that creates a Stripe PaymentIntent for cart total
- Configure Stripe webhook that updates order `paymentStatus` to `"success"` on successful payment
- Frontend: install Stripe.js, replace Cash on Delivery section with Stripe card input element

---

## 📊 8-Day Summary Table

| Day | Person 1 | Person 2 | Person 3 | Person 4 |
|---|---|---|---|---|
| **1** | Auth middleware + backend foundation | Book + Category schemas + ERD + Angular setup | Cart + Order schemas + utilities + Angular setup | Author + Review schemas + Cloudinary setup |
| **2** | Complete auth routes | Category + Book routes | Cart routes + Order transaction | Author + Review + Upload routes |
| **3** | Switch to Angular core | Finish book routes + Postman testing | Finish order routes + Postman testing | Test all routes + Admin panel shell |
| **4** | Auth pages + Profile page | StarRating + BookCard + Home + Book List | Navbar + Cart + Checkout + Order History | Admin tables + Review component |
| **5** | Wire profile + spot check teams | Wire catalog to real API | Wire commerce + deploy backend | Wire admin + wire review component |
| **6** | Integration testing — bugs only | Integration testing — bugs only | Integration testing — bugs only | Integration testing — bugs only |
| **7** | Error polish + 404 + Backend README | Responsive + deploy frontend + ERD | Mobile cart + Frontend README | Admin mobile + Postman collection |
| **8** | Final checks on live app + bonus | Final checks on live app + bonus | Final checks on live app + bonus | Final checks on live app + bonus |

---

## 🔄 Daily Sync Rules

- **Every morning — 15-minute standup. Each person answers:**
  1. What did I finish yesterday?
  2. What am I doing today?
  3. Am I blocked by anything?
- If stuck for more than **2 hours** → post in the group chat immediately. Do not lose half a day silently.
- After Day 3: Person 1 is **not** the auth support person — read `authenticate.js` and `authorize.js` yourself first.
- Before merging any branch into `dev`: at least one other team member must review the code.
- Any schema change after Day 1 **must be discussed with the whole team first.**
