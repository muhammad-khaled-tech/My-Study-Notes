# 📚 MEAN Bookstore — Project Map
> ITI Graduation Project | 10-Day Sprint | 4 Members | MongoDB + Express + Angular + Node.js

---

## 🗺 Full Project Mindmap

```mermaid
mindmap
  root((MEAN Bookstore))
    Foundation Days 1-2
      All 4 Members Together
      Git Setup
        GitHub Org
        2 Repos backend + frontend
        Branch Protection on main
        No direct push to main
      DB Schemas Agreed
        users
        books
        authors
        categories
        carts
        orders
        reviews
      API Contract Locked
        Base URL localhost 5000 api
        Auth Header Bearer token
        Response shape success + data
      Postman Collection
    Backend Days 3-5
      Pair 1 Khaled + Salma
        Auth System
          Register
          Login JWT 7d
          protect middleware
          authorize roles
          Joi validation
        Books CRUD
          Search by name regex
          Filter category author price
          Server-side pagination
          Cloudinary upload
        Categories CRUD
          Block delete if books linked
        Authors CRUD
          Block delete if books linked
      Pair 2 Rana + John
        Cart API
          GET cart upsert
          POST add item
          DELETE remove item
          Stock validation
        Order Transaction
          MongoDB Replica Set required
          Start session
          Check stock
          Decrement stock
          Snapshot prices
          Create order
          Clear cart
          Commit or Abort
        Reviews API
          Verify purchase before review
          Compound unique index user + book
          Rating 1 to 5
          Comment max 500 chars
      Rotation Day 5
        Backend complete
        Pairs swap to Angular
    Frontend Days 6-8
      Khaled
        Book Detail Page
        Add to Cart button
      Salma
        Cart Page
        CartService
      Rana
        Checkout Page
        Order flow
      John
        Order History Page
        StatusBadge component
      Day 7
        Admin Module lazy loaded
        Books CRUD admin
        Authors Categories admin
        Orders management
        Review system complete
      Day 8
        Global error interceptor
        Responsive design mobile
        Loading states skeletons
        Empty states
        Form validation UX
    Deploy Days 9-10
      Backend to Render
        Web Service
        Env vars set
        CORS configured
        Health endpoint live
      Frontend to Vercel or Netlify
        environment prod ts updated
        ng build production
      E2E Testing on live URLs
      Documentation
        Backend README
        Frontend README
        ERD on dbdiagram io
        Postman collection exported
      Git Cleanup
        All branches merged
        git tag v1 0 0
      Presentation 10 min
        Overview 1 min
        Live demo 4 min
        Admin panel 2 min
        Schema justification 2 min
        QA 1 min
    MVP Decisions
      COD only no payment gateway
      No email verification
      No order cancellation
      JWT in localStorage
      Popular books = 8 newest
      Block delete on linked entities
      Price snapshot in orders
      Stock 0 blocks Add to Cart
```

---

## 📅 10-Day Gantt Timeline

```mermaid
gantt
    title MEAN Bookstore — 10-Day Sprint
    dateFormat D
    axisFormat Day %d

    section Foundation
    Day 1 - Setup Git Repos Schemas         :a1, 1, 1d
    Day 2 - Auth System JWT Middleware       :a2, 2, 1d

    section Backend APIs
    Day 3 - Books Categories Authors Cloudinary  :b1, 3, 1d
    Day 4 - Cart Orders Transaction Reviews      :b2, 4, 1d
    Day 5 - Hardening Tests Rotation to Angular  :b3, 5, 1d

    section Frontend Angular
    Day 6 - Shopping Flow Cart Checkout History  :c1, 6, 1d
    Day 7 - Reviews Admin Panel                  :c2, 7, 1d
    Day 8 - Polish Responsive Error Handling     :c3, 8, 1d

    section Deploy and Ship
    Day 9 - Deployment Integration Bug Hunt  :d1, 9, 1d
    Day 10 - Docs Cleanup Presentation Prep  :d2, 10, 1d
```

---

## 👥 Role Assignments

```mermaid
flowchart LR
    subgraph TEAM["👥 Team"]
        K["🟡 Mohamed Khaled\nTeam Lead / Backend Anchor\n─────────────────\n· Git gatekeeper\n· Architecture decisions\n· Auth + Categories + Authors\n· Admin Panel Angular\n· Deployment to Render"]
        S["🟢 Salma Yasser\nBackend Developer\n─────────────────\n· Books CRUD + filtering\n· Joi validation\n· Reviews API\n· Cart Page Angular\n· Responsive design"]
        R["🔵 Rana Mohamed\nFull-Stack Rotator\n─────────────────\n· Angular services setup\n· Cart API backend\n· Auth flow Angular\n· Checkout Page\n· Loading states"]
        J["🩷 John Fayez\nFrontend Lead\n─────────────────\n· Angular routing lazy load\n· Order transaction backend\n· Books list page\n· Order History Page\n· Presentation prep"]
    end

    subgraph RULE["⚠ Git Rule"]
        PR["Everyone opens PRs\nKhaled merges to main\nNo direct push EVER"]
    end

    K & S & R & J --> PR
```

---

## 🏗 System Architecture

```mermaid
flowchart TD
    A["🩷 Angular Client\nVercel / Netlify\nAuthInterceptor adds Bearer token"]

    B["🟡 Express Gateway\nPort 5000\nAll requests pass through middleware chain"]

    MW["Middleware Chain\npino Logger → CORS → JWT protect → authorize roles → Joi validate → Controller → errorHandler"]

    subgraph ROUTES["Route Groups"]
        R1["🟢 /auth\nregister · login\nme · profile"]
        R2["🟢 /books\n/authors\n/categories"]
        R3["🟢 /cart\nGET · POST · DELETE"]
        R4["🔴 /orders\n⚡ MongoDB Transaction\nPOST · GET · PUT status"]
        R5["🟢 /reviews\nPurchase-gated\nGET · POST · DELETE"]
    end

    DB[("🟣 MongoDB Atlas\nReplica Set Required\n7 Collections\nIndexes on email · book name · price · author · category")]

    A -->|"HTTP + JWT"| B
    B --> MW
    MW --> R1 & R2 & R3 & R4 & R5
    R1 & R2 & R3 & R4 & R5 --> DB
```

---

## 🔴 Order Transaction — Step by Step

```mermaid
flowchart TD
    START(["POST /api/orders\nUser JWT + Shipping Address"])

    S1["① mongoose.startSession\nsession.startTransaction"]
    S2{"② Cart empty?"}
    S3["Abort → 400\nCart is empty"]
    S4{"③ For each item:\nbook.stock ≥ quantity?"}
    S5["Abort → 400\nInsufficient stock for book X"]
    S6["④ Decrement Stock\nBook.findByIdAndUpdate\n{ $inc: { stock: -quantity } }\n{ session }"]
    S7["⑤ Snapshot Items\n{ bookId · name · coverUrl\n  price ← book.price NOW\n  quantity }"]
    S8["⑥ Create Order\nstatus: processing\npaymentStatus: pending\npaymentMethod: COD"]
    S9["⑦ Clear Cart\nCart.findOneAndUpdate\n{ items: [] } { session }"]
    S10{"⑧ Any error\nduring steps 4-7?"}
    S11["session.abortTransaction\n🔄 ALL changes rolled back\nReturn 500"]
    S12["session.commitTransaction\nReturn 201 + Order"]

    START --> S1 --> S2
    S2 -->|Yes| S3
    S2 -->|No| S4
    S4 -->|No| S5
    S4 -->|All OK| S6 --> S7 --> S8 --> S9 --> S10
    S10 -->|Yes| S11
    S10 -->|No| S12

    style S3 fill:#3a1a1a,color:#EF4444
    style S5 fill:#3a1a1a,color:#EF4444
    style S11 fill:#3a1a1a,color:#EF4444
    style S12 fill:#0a2a0a,color:#34D399
    style START fill:#1a1a1a,color:#F59E0B
```

---

## 🗄 Database Schema — ER Diagram

```mermaid
erDiagram
    USERS {
        ObjectId _id PK
        String email "unique indexed"
        String firstName
        String lastName
        Date dob
        String password "hashed select=false"
        String role "user or admin"
        Date createdAt
    }

    AUTHORS {
        ObjectId _id PK
        String name "indexed"
        String bio
    }

    CATEGORIES {
        ObjectId _id PK
        String name "unique indexed"
        String description "optional"
    }

    BOOKS {
        ObjectId _id PK
        String name "indexed"
        Number price "min 0"
        Number stock "integer min 0"
        String coverUrl "Cloudinary"
        ObjectId author FK
        ObjectId category FK
        Date createdAt
    }

    CARTS {
        ObjectId _id PK
        ObjectId user FK "unique"
        Array items "book ref + qty + priceAtAdd"
        Date updatedAt
    }

    ORDERS {
        ObjectId _id PK
        ObjectId user FK "indexed"
        Array items "SNAPSHOT bookId name coverUrl price qty"
        Number totalAmount
        Object shippingAddress "street city country"
        String status "processing outForDelivery delivered"
        String paymentStatus "pending success"
        String paymentMethod "COD"
        Date createdAt
    }

    REVIEWS {
        ObjectId _id PK
        ObjectId user FK
        ObjectId book FK
        Number rating "1 to 5"
        String comment "max 500 chars optional"
        Date createdAt
    }

    USERS ||--o| CARTS : "has one"
    USERS ||--o{ ORDERS : "places"
    USERS ||--o{ REVIEWS : "writes"
    AUTHORS ||--o{ BOOKS : "writes"
    CATEGORIES ||--o{ BOOKS : "contains"
    BOOKS ||--o{ REVIEWS : "receives"
```

> ⚠ **Critical Design Notes:**
> - `ORDERS.items` is an **embedded snapshot array** — NOT a reference to BOOKS. Price is frozen at purchase time.
> - `REVIEWS` has a **compound unique index** on `(user, book)` — one review per purchase.
> - Before deleting an AUTHOR or CATEGORY, check `Book.exists({ author/category: id })` → return 400 if true.
> - `BOOKS.stock` is only ever decremented **inside a MongoDB transaction** — never directly.

---

## 🌿 Git Workflow

```mermaid
flowchart TD
    START(["🌅 Start of Day"])

    G1["git checkout main"]
    G2["git pull origin main"]
    G3["git checkout -b feature/task-name"]
    CODE["Write Code\nCommit every 30-60 min"]
    G4["git add .\ngit commit -m 'feat: description'"]
    G5["git push origin feature/task-name"]
    G6["Open Pull Request on GitHub\nAssign 1 reviewer"]
    REVIEW{"Peer Review"}
    FIX["Make requested changes\nPush to same branch"]
    MERGE["🟡 Khaled merges to main\nDeletes feature branch"]
    DONE(["✅ Task Complete"])

    START --> G1 --> G2 --> G3 --> CODE --> G4 --> G5 --> G6 --> REVIEW
    REVIEW -->|"Changes needed"| FIX --> G4
    REVIEW -->|"Approved"| MERGE --> DONE
    DONE --> START

    style MERGE fill:#1a1a0a,color:#F59E0B
    style START fill:#0a1a0a,color:#34D399
    style DONE fill:#0a1a0a,color:#34D399
```

### Commit Message Convention

```mermaid
flowchart LR
    A["feat:"]  --> A1["new feature added"]
    B["fix:"]   --> B1["bug fix"]
    C["setup:"] --> C1["config or init work"]
    D["refactor:"] --> D1["code improvement no behavior change"]
    E["docs:"]  --> E1["README Postman comments"]
```

### Branch Naming

```mermaid
flowchart LR
    subgraph FEATURES
        f1["feature/auth-middleware"]
        f2["feature/books-api"]
        f3["feature/cart-page"]
        f4["feature/admin-panel"]
    end
    subgraph FIXES
        b1["fix/order-stock-validation"]
        b2["fix/jwt-expiry"]
    end
    subgraph SETUP
        s1["setup/project-init"]
        s2["setup/deploy-render"]
    end
    MAIN(["main\n🔒 protected\nKhaled merges only"])
    FEATURES & FIXES & SETUP -->|"PR → Review → Merge"| MAIN
```

---

## 🔐 Authentication Flow

```mermaid
sequenceDiagram
    participant U as Angular Client
    participant G as Express Gateway
    participant DB as MongoDB

    Note over U,DB: Registration
    U->>G: POST /auth/register { email firstName lastName dob password }
    G->>G: Joi validates all fields
    G->>DB: Check email unique
    DB-->>G: OK
    G->>DB: Save user with bcrypt hashed password
    DB-->>G: User created
    G-->>U: 201 { token JWT 7d user }

    Note over U,DB: Login
    U->>G: POST /auth/login { email password }
    G->>DB: Find user by email
    DB-->>G: User document
    G->>G: bcrypt.compare password
    G-->>U: 200 { token JWT 7d user }

    Note over U,DB: Protected Request
    U->>G: GET /books Authorization Bearer token
    G->>G: protect middleware verifies JWT
    G->>G: req.user = decoded payload
    G-->>U: 200 { books paginated }

    Note over U,DB: Admin Only Request
    U->>G: POST /books Authorization Bearer adminToken
    G->>G: protect middleware OK
    G->>G: authorize admin checks req.user.role
    G->>DB: Create book + upload to Cloudinary
    DB-->>G: Book created
    G-->>U: 201 { book with coverUrl }

    Note over U,DB: Unauthorized
    U->>G: DELETE /books/123 Authorization Bearer userToken
    G->>G: protect OK user role
    G->>G: authorize admin FAILS
    G-->>U: 403 Forbidden
```

---

## ⚡ API Contract Summary

```mermaid
flowchart LR
    subgraph AUTH["🔐 Auth Routes — no JWT needed"]
        a1["POST /auth/register"]
        a2["POST /auth/login"]
        a3["GET /auth/me ← JWT"]
        a4["PUT /auth/profile ← JWT"]
    end

    subgraph CATALOG["📚 Catalog — GET public · CUD admin only"]
        b1["GET /books ?search ?category ?author ?minPrice ?maxPrice ?page ?limit"]
        b2["GET /books/:id"]
        b3["POST /books ← Admin multipart form-data"]
        b4["PUT /books/:id ← Admin"]
        b5["DELETE /books/:id ← Admin"]
        b6["GET /authors · POST · PUT · DELETE ← Admin"]
        b7["GET /categories · POST · PUT · DELETE ← Admin"]
    end

    subgraph SHOPPING["🛒 Shopping — JWT required"]
        c1["GET /cart"]
        c2["POST /cart/items { bookId quantity }"]
        c3["DELETE /cart/items/:bookId"]
        c4["POST /orders { shippingAddress } ← Transaction"]
        c5["GET /orders/my"]
        c6["GET /orders ← Admin"]
        c7["PUT /orders/:id/status { status paymentStatus } ← Admin"]
    end

    subgraph REVIEWS["⭐ Reviews — purchase gated"]
        d1["GET /reviews?bookId="]
        d2["POST /reviews { bookId rating comment }"]
        d3["DELETE /reviews/:id ← owner only"]
    end
```

---

## 🚨 Risk Register

```mermaid
quadrantChart
    title Risk Matrix — Likelihood vs Impact
    x-axis Low Likelihood --> High Likelihood
    y-axis Low Impact --> High Impact
    quadrant-1 Monitor
    quadrant-2 Act Now
    quadrant-3 Ignore
    quadrant-4 Watch

    MongoDB Transactions Local: [0.8, 0.85]
    Git Merge Conflicts: [0.75, 0.6]
    Angular Skill Gap: [0.6, 0.8]
    Deployment Failure: [0.5, 0.55]
    Scope Creep Payment Gateway: [0.5, 0.85]
    Cloudinary Upload Issues: [0.4, 0.3]
    Atlas Connection Issues: [0.3, 0.7]
```

### Mitigations

| Risk | Mitigation |
|---|---|
| MongoDB Transactions fail locally | Switch ALL devs to Atlas immediately. Max 1hr debugging. Khaled resolves Day 4. |
| Git merge conflicts | Strict workflow. Small PRs. Team Lead resolves conflicts via screen share. |
| Angular skill gap | Stronger Angular member unblocks others. Pair programming on Days 6–7. |
| Deployment failure Day 9 | Deploy backend by EOD Day 8 as safety net. Keep CORS permissive initially. |
| Scope creep | Payment gateway and email verification are OUT OF SCOPE. Not negotiable. |

---

## 📋 Day-by-Day Full Task Reference

### Day 1 — Foundation (All 4 Together)
**Goal:** Every member has running environment, agreed schemas, first commit pushed.

| Member | Tasks |
|---|---|
| Khaled | Create GitHub org + 2 repos · Set branch protection · Init backend with all packages · Create folder structure · Share .env.example · Push setup PR |
| Salma | Init Angular project · Install Angular Material · Create folder structure /core /shared /features /admin · Set up environments · Push setup PR |
| Rana | Review all 6 DB schemas with team · Document decisions in repo wiki · Create Mongoose model files (empty shells) |
| John | Set up Postman workspace · Create collection with all endpoint folders · Add env variables for base URL and token · Ensure everyone can access collection |

**DoD:** Backend `/health` returns `{ status: "ok" }` · Angular runs on :4200 · All 4 members made ≥1 commit · Models exist · Postman shared

---

### Day 2 — Auth System
**Goal:** Registration, login, JWT middleware, role-based protection working.

| Member | Tasks |
|---|---|
| Khaled | User model + bcrypt pre-save hook · /auth/register + /auth/login · protect middleware · authorize middleware · centralized error handler · pino logger |
| Salma | Joi validation schemas · Wire Joi to auth routes · GET /auth/me + PUT /auth/profile · Seed script (1 admin + 2 users) |
| Rana | Angular AuthService (login register logout getToken isLoggedIn isAdmin) · AuthInterceptor — services only no UI |
| John | Angular Login + Register pages (Angular Material) · AuthGuard · Lazy loading routing module |

**DoD:** Register → login → JWT → me → all work in Postman · 401 without token · 403 wrong role · Angular login page renders

---

### Day 3 — Books, Categories, Authors
**Goal:** Full catalog CRUD with Cloudinary upload.

| Member | Tasks |
|---|---|
| Khaled | Category model + CRUD (block delete if books) · Author model + CRUD (block delete if books) · Cloudinary SDK config · Upload middleware (multer + cloudinary stream) |
| Salma | Book model · GET /books with search/filter/pagination · GET /books/:id · POST/PUT/DELETE /books (admin + upload) · Add DB indexes |
| Rana | Angular BookService · CategoryService · AuthorService — HttpClient wrappers only |
| John | Angular Books List page: grid + search (debounced RxJS) + filter sidebar + loading spinner + empty state |

**DoD:** Full CRUD verified in Postman · Cloudinary URL in response · Search returns correct results · Delete category with books → 400 · Books page displays from API

---

### Day 4 — Cart, Orders, Reviews
**Goal:** Cart and Order with MongoDB transactions. Most complex day.

| Member | Tasks |
|---|---|
| Khaled | ⚠ CRITICAL: Verify Atlas Replica Set works for transactions · Test in isolation · Document solution in README |
| Salma | Review model + compound unique index · POST /reviews (purchase verification) · GET /reviews?bookId= paginated · DELETE /reviews/:id owner only |
| Rana | Cart model · GET/POST/DELETE cart endpoints · Stock validation on add · findOneAndUpdate upsert |
| John | Order model (snapshot items NOT refs) · POST /orders full transaction (8 steps) · GET /orders/my · GET /orders admin · PUT /orders/:id/status admin |

**DoD:** Cart → order flow works in Postman · Stock decremented · Order has snapshotted prices · Stock > order quantity → 400 · Review without purchase → 403

---

### Day 5 — Backend Hardening + Rotation
**Goal:** Backend locked. Angular auth flow done. Pairs rotate.

| Member | Tasks |
|---|---|
| Khaled | Full backend review · Verify all Joi/auth wired · Write 10-15 Postman tests with assertions · Fix bugs — buffer day |
| Salma | ROTATION → Angular · Home page: hero + 8 newest books + authors section · Angular Material cards · Responsive |
| Rana | Complete Angular auth flow: login → JWT → redirect → logout · Navbar shows user name · isAdmin nav items |
| John | Complete Books List: all filters wired + debounced + pagination + real API · Loading + error states |

**DoD:** All backend routes tested with assertions · Zero unhandled rejections · User can register/login/logout in browser · Home page shows live data · 15-min retrospective held

---

### Day 6 — Shopping Flow
**Goal:** Core shopping flow works end-to-end in browser.

| Member | Tasks |
|---|---|
| Khaled | Book Detail page: info + Add to Cart (disabled stock=0, hidden not logged in) + reviews display + write-review form |
| Salma | Cart page: items list + total + remove button + proceed to checkout (auth guard) + CartService |
| Rana | Checkout page: order summary + shipping address form + Place Order → POST /orders → navigate to history + error handling |
| John | Order History page: orders list + status badges + thumbnails + total + OrderService + StatusBadge component |

**DoD:** Full E2E happy path in browser: Register → Browse → Add to Cart → Checkout → Order in History · Out-of-stock shows disabled button

---

### Day 7 — Reviews + Admin Panel
**Goal:** Review system done. Admin panel core complete.

| Member | Tasks |
|---|---|
| Khaled | Angular Admin module (lazy, AdminGuard) · Admin Books: table + create/edit forms + file upload FormData |
| Salma | Admin Authors page CRUD · Admin Categories page CRUD · Reusable form components |
| Rana | Admin Orders page: all orders table + status dropdown + payment toggle + real-time DOM update |
| John | ReviewService on Book Detail · Star rating input component · Average rating display · Show/hide form based on purchase check |

**DoD:** Admin creates book with cover → appears on books page · Admin updates order status · Purchaser sees review form · Non-purchaser does not

---

### Day 8 — Polish + Responsive + Error Handling
**Goal:** Production-quality UX.

| Member | Tasks |
|---|---|
| Khaled | Global HTTP error interceptor (401 logout, 403 forbidden, 500 generic) · NotificationService (Angular Material Snackbar) · Wire throughout app |
| Salma | Responsive: books grid 4→2→1 cols · Mobile navbar hamburger · Cart mobile layout · Test 375px/768px/1280px |
| Rana | Loading spinners all pages · Skeleton loaders books grid · Empty states (No books found, Cart empty with CTA) |
| John | 404 page · Form validation inline errors (reactive forms) · Admin sidebar nav · Backend README complete |

**DoD:** Mobile display correct · All forms show validation errors · All API errors show Snackbar · Backend README written and accurate

---

### Day 9 — Deploy + Integration
**Goal:** Both apps live with public URLs.

| Member | Tasks |
|---|---|
| Khaled | Deploy backend → Render.com · Set all env vars · Verify /health live · Configure CORS · Document URL |
| Salma | Update environment.prod.ts · Deploy frontend → Vercel/Netlify · Verify live app connects to live backend |
| Rana + John | Full E2E bug hunt on deployed URLs · Document bugs in GitHub Issues · Fix P0 (breaking) bugs first |

**DoD:** Both apps live · Full happy path works on deployed URLs · P0 bugs fixed · P1 (visual) bugs documented

---

### Day 10 — Final Polish + Presentation
**Goal:** Clean, documented, presentable.

| Member | Tasks |
|---|---|
| Khaled | Final code review · All branches merged · Stale branches deleted · git tag v1.0.0 · Export Postman/Swagger |
| Salma | Frontend README · ERD on dbdiagram.io · ERD image in backend README |
| Rana | Fix remaining visual bugs · Remove console.logs · Run ng lint + eslint · Commit clean |
| John | Prep 10-min presentation: Overview 1min · Live demo 4min · Admin 2min · Schema justification 2min · Q&A 1min · Assign speakers |

**DoD:** Clean commit histories from all 4 · READMEs complete · ERD linked · Live URLs in READMEs · Postman accessible · Team can explain every decision

---

## 🏛 MVP Scope Decisions (Do Not Change)

| Decision | What | Why |
|---|---|---|
| Price snapshot | Orders store price at purchase time, not a book reference | Immutable financial records |
| Stock=0 behavior | Block add-to-cart in Angular + validate on backend at order | Dual validation |
| Author/Category delete | Block if books exist → 400 | Prevents orphaned data |
| Popular books | 8 most recently created | Zero query complexity |
| JWT storage | localStorage (academic project) | HttpOnly cookies add deployment complexity |
| Payment | COD only — no gateway | Gateway = 2-3 extra days |
| Email verification | Skipped (PDF marks as bonus) | Requires mail server setup |
| Order cancellation | Not implemented (not in PDF) | Adds stock-restore logic = scope creep |
| Cloudinary | Backend SDK upload (not pre-signed URL) | Pre-signed URL = frontend-backend coordination complexity |

---

*Generated from the 10-Day Master Plan — ITI MEAN Bookstore Project*
