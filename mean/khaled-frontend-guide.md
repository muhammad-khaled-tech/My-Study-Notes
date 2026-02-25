# 🎓 Khaled's Frontend Mentorship Guide
> Angular 21 | Bookstore Project | Your Role: Auth + Core Infrastructure
> Written like a professor sitting next to you — concept first, then code.

---

## 🧠 First — Understand What You're Actually Building

Before you touch a single file, let's talk about the big picture.

Your role in this project is not "build some pages." Your role is to build **the brain of the frontend**. Every other teammate's work depends on what you build today.

Think of it this way:

> Rana built the Books page. It shows books. But if a user isn't logged in, should they still see it? And if they try to add a book to cart, how does the backend know WHO is adding it?
>
> Salma built the Cart. But how does the cart page know the user's token? How does it send it automatically with every request?
>
> John built the Admin panel. But how does the app prevent a regular user from just typing `/admin` in the URL and getting in?

**You answer all of these questions.** You are building:

```
AuthService        → the single source of truth: "is someone logged in? who are they?"
Token Interceptor  → silently attaches the user's token to every HTTP request
Error Interceptor  → if the backend says 401 or 403, handle it globally — not in every component
authGuard          → the bouncer: "you can't see /profile unless you're logged in"
adminGuard         → the VIP bouncer: "you can't see /admin unless you're an admin"
Login page         → calls AuthService.login()
Register page      → calls AuthService.register()
Profile page       → calls AuthService.updateProfile()
Not Found page     → shows 404
Navbar wiring      → reads from AuthService so the links update automatically
```

Everything in this list connects to everything else. The order matters. We go top to bottom.

---

---

# 📖 STEP 1 — TypeScript Models (Interfaces)

## Professor Explanation First

Before we write a single model, answer this question: **what happens when your backend sends you data?**

Your backend sends JSON like this:
```json
{
  "success": true,
  "data": {
    "_id": "abc123",
    "email": "khaled@test.com",
    "firstName": "Khaled",
    "role": "user"
  }
}
```

In JavaScript, you'd just do `response.data.firstName` and call it a day. But this is TypeScript. TypeScript asks: **"what IS `response.data`? What shape does it have? What fields does it contain?"**

If you don't tell TypeScript the shape, it treats everything as `any` — which means:
- No autocomplete when you type `user.`
- No warning if you mistype `user.firstname` instead of `user.firstName`
- No idea what fields exist

**A TypeScript interface is you telling TypeScript: "this is the shape of this data."**

Think of it like a form with specific fields. A User form has: name, email, role. You can't put "favourite pizza" on a User form — it doesn't belong there. An interface enforces this.

```ts
// WITHOUT interface — TypeScript is blind
const user: any = getUser();
user.fristName  // typo — TypeScript says nothing. Bug in production.

// WITH interface — TypeScript sees everything
const user: User = getUser();
user.fristName  // ❌ TypeScript immediately: "Property 'fristName' does not exist on type 'User'. Did you mean 'firstName'?"
```

**This is why we write models before anything else** — because AuthService, the guards, and the pages all use these shapes.

---

## Now Apply It to the Project

Create these files (the folders might not exist yet — create them first):

```bash
mkdir -p src/app/core/models
mkdir -p src/app/core/services
mkdir -p src/app/core/interceptors
mkdir -p src/app/core/guards
```

---

### 📂 `src/app/core/models/user.model.ts`

```ts
export interface User {
  _id: string;
  email: string;
  firstName: string;
  lastName: string;
  dob: string;             // ISO date string like "2000-01-15"
  role: 'user' | 'admin'; // union type — only these two values are allowed
  isVerified: boolean;
  createdAt: string;
}
```

**Stop. Read this part:**

Notice `role: 'user' | 'admin'` — this is called a **union type**. It means role can be EXACTLY one of those two strings, nothing else. If you later write:

```ts
if (user.role === 'superadmin') { ... }
```

TypeScript will warn you: *"This condition will always be false because 'superadmin' is not assignable to 'user' | 'admin'."* That is TypeScript saving you from a bug.

---

### 📂 `src/app/core/models/cart.model.ts`

```ts
import { Book } from './book.model'; // your teammate Rana already created this

export interface CartItem {
  book: Book;       // the full book object — backend populates this
  quantity: number;
}

export interface Cart {
  _id: string;
  user: string;     // just the user's ID — not the full user object
  items: CartItem[];
  total: number;
}
```

---

### 📂 `src/app/core/models/order.model.ts`

```ts
export interface OrderItem {
  book: { _id: string; name: string; coverImage: string };
  quantity: number;
  priceAtPurchase: number; // price is "frozen" at purchase time — won't change if book price changes
}

export interface ShippingDetails {
  fullName: string;
  address: string;
  city: string;
  phone: string;
}

export interface Order {
  _id: string;
  user: string;
  items: OrderItem[];
  shippingDetails: ShippingDetails;
  status: 'processing' | 'out_for_delivery' | 'delivered';
  paymentMethod: string;
  paymentStatus: 'pending' | 'success';
  createdAt: string;
}
```

---

### 📂 `src/app/core/models/review.model.ts`

```ts
export interface Review {
  _id: string;
  user: { _id: string; firstName: string; lastName: string };
  book: string;
  rating: number;
  comment?: string; // the ? makes this field OPTIONAL
  createdAt: string;
}
```

**Stop. Read the `?` part:**

`comment?` means this field might exist and might not — and TypeScript is okay with both. Without the `?`, TypeScript would force every Review to have a comment. But in real life, users can rate a book without writing text. The `?` tells TypeScript: "absence is fine here."

---

### 📂 `src/app/core/models/api-response.model.ts`

This one needs a bigger explanation because it uses **Generics** — a concept that confuses a lot of people.

**Professor moment:**

Your backend always responds in this format:
```json
{ "success": true, "message": "ok", "data": { ... } }
```

But `data` can be ANYTHING. Sometimes it's a User, sometimes it's a Book array, sometimes it's a Cart.

The naive solution: write a separate interface for every possible response:
```ts
interface UserResponse   { success: boolean; message: string; data: User }
interface BookResponse   { success: boolean; message: string; data: Book[] }
interface CartResponse   { success: boolean; message: string; data: Cart }
// ... 20 more interfaces all looking identical except for "data"
```

That's terrible. The smart solution: **use a Generic**. A Generic is like a function parameter, but for types.

```ts
// T is a placeholder — you fill it in when you USE the interface
interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;           // T gets replaced with whatever you pass in
}

// Usage:
ApiResponse<User>    // data becomes: User
ApiResponse<Book[]>  // data becomes: Book[]
ApiResponse<Cart>    // data becomes: Cart
```

One interface. Works for everything. TypeScript fills in `T` each time.

```ts
export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  pagination?: PaginationMeta; // only on paginated endpoints
}
```

---

### 📂 `src/app/core/models/index.ts`

This file is a re-export barrel. It lets your teammates write one import line instead of five.

```ts
// Without this file, teammates write:
import { User } from '../core/models/user.model';
import { Order } from '../core/models/order.model';
import { Cart } from '../core/models/cart.model';

// With this file, they write:
import { User, Order, Cart } from '../core/models';
```

```ts
export type { User } from './user.model';
export type { CartItem, Cart } from './cart.model';
export type { OrderItem, ShippingDetails, Order } from './order.model';
export type { Review } from './review.model';
export type { ApiResponse, PaginationMeta } from './api-response.model';
```

`export type` instead of `export` — because interfaces are only TypeScript compile-time things. They don't exist in the final JavaScript. `export type` tells the bundler: "don't try to include this in the JavaScript bundle."

---

---

# 📖 STEP 2 — AuthService

## Professor Explanation First

Let's answer a question: **why a Service at all? Why not just write the login logic inside the Login component?**

Imagine you have three components that all need to know "is the user logged in?":
- The **Navbar** — to show/hide Cart, Profile, Logout links
- The **authGuard** — to decide if a protected route is accessible
- The **Profile page** — to pre-fill the user's name

If the login logic lives inside the Login component, these three can't reach it. A component's logic is private to that component.

A **Service** is a class that Angular creates **once** and **shares** across the entire application. Every component that needs it gets the exact same instance. This is called a **Singleton pattern**.

**Real-world analogy:**

Think of a hospital. The patient records database is one system shared by all doctors. When a doctor updates a record, every other doctor sees the update immediately. The doctors (components) don't each have their own copy of the records — they all access the same shared system (the service).

If each doctor had their own separate copy (putting logic in components), you'd have chaos: one copy says the patient is allergic to penicillin, another doesn't know that.

---

### What is a BehaviorSubject and why do we use it here?

**Professor moment — this is the most important concept in this step:**

Inside AuthService, we need a way to say: "the login state changed" — and have every subscriber immediately know.

A regular variable won't work:
```ts
isLoggedIn = false;
// If this changes, how does the Navbar know? It doesn't. It can't observe a variable.
```

An **Observable** is like a pipe. Data flows through it. Anyone who "subscribes" to it gets the data as it flows.

A **BehaviorSubject** is a special Observable that:
1. Always holds a **current value** (unlike regular Observables which might be silent)
2. When a new subscriber joins, it **immediately receives the current value** (they don't have to wait for the next emission)
3. When you call `.next(newValue)`, **every subscriber is notified immediately**

**Real-world analogy:**

A regular Observable is like a live radio station — if you tune in late, you miss what was broadcast. You only hear what comes after you tuned in.

A BehaviorSubject is like a radio station that also has a "last broadcast" feature — when you tune in, you immediately hear the most recent thing they said, then continue receiving live.

This is perfect for login state. When the Navbar component initializes (maybe after the user is already logged in), it needs to immediately know the current state — not wait for the next login/logout event.

---

### 📂 `src/app/core/services/auth.service.ts`

```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap, BehaviorSubject } from 'rxjs';
import { environment } from '../../../environments/environment';

// @Injectable({ providedIn: 'root' }) does two things:
// 1. Makes this class injectable (other things can "request" it via inject())
// 2. providedIn: 'root' = Angular creates ONE instance for the whole app (Singleton)
//    Every component that injects AuthService gets THE SAME object.

@Injectable({ providedIn: 'root' })
export class AuthService {

  private api = `${environment.apiUrl}/auth`; // e.g. "http://localhost:5000/api/auth"
  private TOKEN_KEY = 'jwt_token';            // the key we use in localStorage

  // BehaviorSubject starts with the current login state (checks localStorage immediately)
  // private = components can't change it directly — only AuthService can
  private loggedIn$ = new BehaviorSubject<boolean>(this.isLoggedIn());

  // We expose a read-only version — components can subscribe but not push new values
  authStatus$ = this.loggedIn$.asObservable();

  constructor(private http: HttpClient, private router: Router) {}

  // ─── REGISTER ────────────────────────────────────────────────────────────────
  // We return the Observable WITHOUT subscribing.
  // Why? Because the component decides what to do when it succeeds or fails.
  // Maybe the Login component navigates to /books.
  // Maybe a future admin component navigates somewhere else.
  // The Service shouldn't make that decision.
  register(data: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dob: string;
  }): Observable<any> {
    return this.http.post(`${this.api}/register`, data);
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────────
  // tap() is an RxJS operator that lets you "peek" at the data flowing through
  // the Observable WITHOUT stopping or changing it.
  // We use it to save the token as a side effect.
  //
  // Think of tap() like a CCTV camera on a highway — the cars (data) keep moving,
  // but the camera records what it sees without blocking traffic.
  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.api}/login`, { email, password }).pipe(
      tap(res => {
        if (res.data?.token) {
          localStorage.setItem(this.TOKEN_KEY, res.data.token);
          this.loggedIn$.next(true); // ← pushes "true" to all subscribers (Navbar, etc.)
        }
      })
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────
  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.loggedIn$.next(false);            // ← tells Navbar: "user is gone"
    this.router.navigate(['/auth/login']); // ← redirect to login
  }

  // ─── GET TOKEN ───────────────────────────────────────────────────────────────
  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  // ─── DECODE TOKEN → GET USER DATA ────────────────────────────────────────────
  // A JWT token looks like: xxxxx.yyyyy.zzzzz
  // The MIDDLE part (yyyyy) is the user data encoded in base64.
  // We decode it to get { _id, email, role, firstName, lastName, exp, ... }
  // No API call needed — the data is already inside the token.
  getCurrentUser(): any | null {
    const token = this.getToken();
    if (!token) return null;
    try {
      const payload = token.split('.')[1]; // grab the middle part
      const decoded = atob(payload);       // decode base64 to a JSON string
      return JSON.parse(decoded);          // parse that JSON string to an object
    } catch {
      return null; // token is malformed or tampered with
    }
  }

  // ─── IS USER LOGGED IN? ──────────────────────────────────────────────────────
  // We don't just check if the token EXISTS — we also check if it's EXPIRED.
  // JWT tokens have an "exp" field (expiry timestamp in seconds).
  // If the token expired, the user needs to log in again.
  isLoggedIn(): boolean {
    try {
      const token = this.getToken();
      if (!token) return false;
      const { exp } = JSON.parse(atob(token.split('.')[1]));
      return exp * 1000 > Date.now(); // exp is seconds, Date.now() is milliseconds
    } catch {
      return false;
    }
  }

  // ─── IS ADMIN? ───────────────────────────────────────────────────────────────
  isAdmin(): boolean {
    return this.getCurrentUser()?.role === 'admin';
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────────────────────
  updateProfile(data: { firstName?: string; lastName?: string; dob?: string }): Observable<any> {
    return this.http.patch(`${this.api}/profile`, data);
  }
}
```

---

---

# 📖 STEP 3 — Token Interceptor

## Professor Explanation First

You just built AuthService. Now imagine every API service (BookService, CartService, OrderService) has to manually attach the token to every request:

```ts
// In BookService:
getBooks() {
  const token = this.auth.getToken();
  return this.http.get('/api/books', {
    headers: { Authorization: `Bearer ${token}` }
  });
}

// In CartService:
getCart() {
  const token = this.auth.getToken();
  return this.http.get('/api/cart', {
    headers: { Authorization: `Bearer ${token}` }
  });
}

// In OrderService:
getOrders() {
  const token = this.auth.getToken();
  return this.http.get('/api/orders', {
    headers: { Authorization: `Bearer ${token}` }
  });
}
// ... and 20 more methods all doing the same repetitive thing
```

This is terrible for three reasons:
1. **Repetition** — the same 2 lines appear everywhere
2. **Fragility** — if the token key name changes, you update 20 places
3. **Forgettability** — a teammate writes a new service method and forgets to add the header. The backend returns 401. Hours of debugging.

**An HTTP Interceptor solves all of this.**

An interceptor is middleware that sits between your code and the network. **Every single HTTP request passes through it** — no exceptions. You write the token-attaching logic ONCE, and it applies everywhere automatically.

**Real-world analogy:**

Think of a company's email server. Before any email leaves the company, the server automatically adds a disclaimer at the bottom: "This email is confidential. © Company Name." 

Nobody asks the employees to add this disclaimer. Nobody can forget. Every outgoing email gets it automatically. The server intercepts every email and adds the disclaimer before sending.

Your Token Interceptor does the same: intercepts every outgoing HTTP request and adds the `Authorization` header before it leaves.

---

### Why `req.clone()` and not `req.headers.set()`?

**Professor moment:**

Angular HTTP requests are **immutable**. Once created, you can't change them. This is a design decision for safety and predictability.

Think of it like signing a cheque. Once you sign it and hand it over, it's locked. You can't sneak back and change the amount. If you want a different amount, you write a new cheque.

`req.clone({ setHeaders: { Authorization: '...' } })` creates a new request (a copy) with the header added. The original `req` is untouched.

---

### 📂 `src/app/core/interceptors/token.interceptor.ts`

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

// In Angular 21, interceptors are plain FUNCTIONS — not classes.
// This is simpler and more predictable.
//
// Parameters:
//   req  = the outgoing HTTP request (read-only)
//   next = a function that passes the request to the next handler (or to the network)
export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();

  // If there's no token (user not logged in), pass the request through unchanged.
  // This covers login and register — those requests don't need a token.
  if (!token) return next(req);

  // Clone the request and add the Authorization header to the clone.
  // We can't modify req directly — it's immutable.
  const authReq = req.clone({
    setHeaders: {
      Authorization: `Bearer ${token}`
    }
  });

  // Pass the cloned request (with the token) to the next handler
  return next(authReq);
};
```

---

---

# 📖 STEP 4 — Error Interceptor

## Professor Explanation First

Your backend returns different HTTP status codes for different errors:
- `400` Bad Request (validation failed)
- `401` Unauthorized (token missing, expired, or invalid)
- `403` Forbidden (logged in but not allowed)
- `404` Not Found
- `500` Server Error

Some of these need **global handling**. Specifically:

**401** — if your token expires while the user is browsing, EVERY request starts failing. You don't want the Cart page showing a cryptic error, the Profile page showing another error, and the Orders page showing another error. You want ONE response: logout the user and send them to login.

**403** — if a regular user somehow navigates to an admin-only endpoint, you want to redirect them home — not show them a broken page.

Without a global error interceptor, every component would need:
```ts
this.auth.login(email, pass).subscribe({
  error: (err) => {
    if (err.status === 401) { this.auth.logout(); }  // repeated in every component
    if (err.status === 403) { this.router.navigate(['']); } // repeated in every component
  }
})
```

With a global error interceptor, you write this logic **once**, and it applies everywhere automatically. Components only need to handle errors specific to them (like showing "Invalid credentials" on the login form).

**The key concept:**

After the interceptor catches a 401 or 403 and handles it globally, it **re-throws the error**. This lets the component still receive the error if it needs to do something component-specific with it.

```
request fails with 401
    ↓
Error Interceptor catches it
    ↓
Calls auth.logout() — global action
    ↓
Re-throws the error — passes it down
    ↓
Login component's error handler also receives it
    ↓
Shows "Invalid credentials" under the form — component-specific action
```

---

### 📂 `src/app/core/interceptors/error.interceptor.ts`

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  // next(req) sends the request and returns an Observable of the response.
  // .pipe(catchError(...)) wraps it — if the Observable errors, catchError runs.
  return next(req).pipe(
    catchError(err => {
      if (err.status === 401) {
        // Token is expired or invalid.
        // Force logout — this removes token from localStorage,
        // sets loggedIn$ to false (Navbar updates), and navigates to /auth/login.
        auth.logout();
      }

      if (err.status === 403) {
        // User is authenticated but not authorized for this action.
        // Send them home.
        router.navigate(['/']);
      }

      // Re-throw so the component's error handler also runs.
      // This is important for things like showing "Invalid credentials" on the login form.
      // If we didn't re-throw, the component would never know an error happened.
      return throwError(() => err);
    })
  );
};
```

> **Why `throwError(() => err)` and not `throw err`?**
> We're inside an RxJS pipe — everything here is Observable-based, not regular JavaScript flow.
> `throw err` would crash the Observable stream in an uncontrolled way.
> `throwError(() => err)` creates a properly-behaved Observable that emits an error — which the subscribing component can catch in its `error:` handler.

---

---

# 📖 STEP 5 — Guards

## Professor Explanation First

You've built the auth brain (AuthService) and the HTTP middleware (interceptors). Now you need **route protection**.

Right now, if a user opens a browser and types `http://localhost:4200/profile` — Angular loads the Profile page. No questions asked. Even if the user is not logged in.

That's a problem. The Profile page tries to call `auth.getCurrentUser()`, gets null, and breaks. The API calls would fail with 401. The UI would be a mess.

A **Guard** is a function that Angular calls **before loading a route**. It gets to say: "yes, load this page" or "no, redirect them somewhere else."

**Real-world analogy:**

Imagine a nightclub. Before you walk in, there's a bouncer. The bouncer checks: "are you on the list?" If yes, you go in. If no, you're redirected to the queue (or sent home).

The route is the nightclub. The guard is the bouncer. The component (Profile, Cart, Admin) only loads if the guard says "yes."

```
User navigates to /profile
       ↓
Angular Router: "Does this route have a canActivate guard?"
       ↓ YES
Runs authGuard()
       ↓
authGuard checks: auth.isLoggedIn()
       ↓
  true  → return true  → Angular loads Profile component ✅
  false → return createUrlTree(['/auth/login']) → Angular redirects ❌
```

---

### Why `createUrlTree` and not `router.navigate()`?

**Professor moment:**

A guard must **return** a value that Angular's router can use. Angular accepts:
- `true` → allow navigation
- `false` → block navigation (silently, user stays where they are)
- `UrlTree` → redirect to a different URL

`router.navigate()` is a "fire and forget" function — it triggers navigation but returns `void` (or a Promise). Angular's router can't use that as a redirect instruction.

`router.createUrlTree(['/auth/login'])` creates a `UrlTree` object — a data structure representing a URL. Angular's router understands this natively and performs the redirect cleanly.

---

### 📂 `src/app/core/guards/auth.guard.ts`

```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);

  if (auth.isLoggedIn()) {
    return true; // ✅ logged in — allow navigation
  }

  // ❌ not logged in — redirect to login page
  return inject(Router).createUrlTree(['/auth/login']);
};
```

---

### 📂 `src/app/core/guards/admin.guard.ts`

```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);

  if (auth.isLoggedIn() && auth.isAdmin()) {
    return true; // ✅ logged in AND admin — allow navigation
  }

  // ❌ not admin (or not logged in) — send them to home
  return inject(Router).createUrlTree(['/']);
};
```

---

---

# 📖 STEP 6 — Wire Interceptors into app.config.ts

## Professor Explanation First

You've written interceptors. You've written guards. But Angular doesn't know they exist yet. You haven't plugged them in.

In Angular 21 there is **no app.module.ts**. The old way to register global things was to add them to `NgModule`. The new way is `app.config.ts` — this file IS the global configuration.

Think of `app.config.ts` as the **control panel of your application**. When Angular starts, this is the first thing it reads. It sets up:
- Routing (`provideRouter`)
- HTTP client (`provideHttpClient`)
- Change detection
- Any interceptors

**If you don't register your interceptors here, they don't run. Period.**

It doesn't matter how perfectly you wrote your `tokenInterceptor` function. If it's not in `withInterceptors([...])` inside `app.config.ts`, it's like a worker who showed up to the building but nobody gave them a badge — they can't get in.

---

### 📂 Replace `src/app/app.config.ts` entirely:

```ts
import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { tokenInterceptor } from './core/interceptors/token.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),

    provideHttpClient(
      withFetch(),                                          // use modern fetch API internally
      withInterceptors([tokenInterceptor, errorInterceptor]) // ORDER MATTERS: token first, then error
    ),
  ]
};
```

**Why does order matter in withInterceptors?**

Interceptors run in the order you list them on the WAY OUT (request going to server). On the WAY BACK (response coming from server), they run in reverse.

So with `[tokenInterceptor, errorInterceptor]`:
- Request: tokenInterceptor adds the header → errorInterceptor passes it through → request hits server
- Response: errorInterceptor catches any errors → tokenInterceptor passes it through → component gets response

This is correct. Token runs first when sending. Error catches on the way back.

---

---

# 📖 STEP 7 — Add Guards to app.routes.ts

## Professor Explanation First

You built the guards. You wired up the HTTP client. Now you need to tell the Router: "for THESE routes, check the guard before loading."

This is done with a `canActivate` property on each route that needs protection.

**What `canActivate` does:**

```
User navigates to /profile
Router finds the route definition for 'profile'
Router sees canActivate: [authGuard]
Router calls authGuard()
  Returns true  → load ProfileComponent
  Returns UrlTree → navigate to that URL instead
```

You can protect a **parent route** to protect all its children at once. Look at how `orders` is protected — one `canActivate` on the parent covers both `/orders` and `/orders/checkout`.

---

### 📂 Replace `src/app/app.routes.ts` entirely:

```ts
import { Routes } from '@angular/router';
import { NotFound } from './not-found/not-found';
import { authGuard } from './core/guards/auth.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'books',
    pathMatch: 'full',
  },
  {
    path: 'auth',
    children: [
      {
        path: 'login',
        loadComponent: () => import('./features/auth/login/login').then(c => c.Login),
      },
      {
        path: 'register',
        loadComponent: () => import('./features/auth/register/register').then(c => c.Register),
      },
    ],
  },
  {
    path: 'books',
    loadComponent: () => import('./features/books/book-list/book-list').then(c => c.BookList),
  },
  {
    path: 'authors',
    loadComponent: () => import('./features/authors/author-list/author-list').then(c => c.AuthorList),
  },
  {
    path: 'cart',
    loadComponent: () => import('./features/cart/cart').then(c => c.Cart),
    canActivate: [authGuard],  // 🔒 must be logged in
  },
  {
    path: 'orders',
    canActivate: [authGuard],  // 🔒 protects /orders AND /orders/checkout at once
    children: [
      {
        path: '',
        loadComponent: () => import('./features/orders/order-history/order-history').then(c => c.OrderHistory),
      },
      {
        path: 'checkout',
        loadComponent: () => import('./features/orders/checkout/checkout').then(c => c.Checkout),
      },
    ],
  },
  {
    path: 'profile',
    loadComponent: () => import('./features/profile/profile').then(c => c.Profile),
    canActivate: [authGuard],  // 🔒 must be logged in
  },
  {
    path: 'admin',
    loadComponent: () => import('./features/admin/admin').then(c => c.Admin),
    canActivate: [adminGuard], // 🔐 must be admin
  },
  {
    path: '**',       // matches ANY route that wasn't matched above
    component: NotFound,
  },
];
```

> **What is `loadComponent` vs `component`?**
> `loadComponent` is **lazy loading** — the component's JavaScript is only downloaded when the user visits that route. The initial app bundle is smaller and loads faster.
> `component` is **eager loading** — the component is downloaded upfront with everything else, even if the user never visits that page.
> Use `loadComponent` everywhere except the 404 page (which is loaded anyway when nothing else matches).

---

---

# 📖 STEP 8 — Login Page

## Professor Explanation First

We're finally building a page. Let's talk about **Reactive Forms** — because the Login page uses them, and if you don't understand them, you'll be confused by every form forever.

### The Two Ways to Do Forms in Angular

**Template-Driven Forms** — you define the form IN the HTML. Angular reads it.
**Reactive Forms** — you define the form IN TypeScript. HTML just displays it.

You're using Reactive Forms. Here's why they're better for this project:
- You can programmatically enable/disable the form (disable while API call is loading)
- Validation logic is in TypeScript, not scattered in HTML attributes
- Easier to test and reason about
- When you call `loginForm.value`, you get a clean object — no DOM manipulation

### The Mental Model for Reactive Forms

```
TypeScript file → creates the form and its rules (source of truth)
HTML template   → displays the form (just the view)
They communicate through NAMES.
```

**Example:**
```ts
// TypeScript — defines structure
loginForm = new FormGroup({
  email: new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required])
});
```

```html
<!-- HTML — displays it, bound by name -->
<form [formGroup]="loginForm">
  <input formControlName="email" />    <!-- "email" matches the key above -->
  <input formControlName="password" /> <!-- "password" matches the key above -->
</form>
```

The string `"email"` in `formControlName="email"` must exactly match the key `email` in your `FormGroup`. That's the connection.

### The Flow When User Submits

```
User fills email + password → clicks Submit
    ↓
(ngSubmit) fires → calls submitLogin()
    ↓
TypeScript checks loginForm.invalid
  invalid? → return (do nothing, HTML shows validation errors)
  valid?   → continue
    ↓
loading = true (button shows spinner, is disabled)
    ↓
Calls auth.login(email, password) → returns Observable
    ↓
.subscribe() listens:
  next  → navigate to /books (success)
  error → show error message, loading = false (failure)
```

---

### 📂 `src/app/features/auth/login/login.ts`

```ts
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  // ReactiveFormsModule → required for [formGroup] and formControlName to work in HTML
  // RouterLink         → required for routerLink="/auth/register" in HTML
  // CommonModule       → not strictly needed in Angular 17+ but safe to include
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  loading = false;
  serverError = '';

  // Define the form with two fields, both required
  // Validators.email ensures proper email format (not just non-empty)
  loginForm = new FormGroup({
    email:    new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitLogin() {
    // If any field fails validation, Angular marks the form invalid.
    // We stop here — the HTML will show the error messages automatically.
    if (this.loginForm.invalid) return;

    this.loading = true;
    this.serverError = '';

    const { email, password } = this.loginForm.value;

    // auth.login() returns an Observable.
    // Nothing happens until we subscribe.
    // subscribe() is the trigger that actually sends the HTTP request.
    this.auth.login(email!, password!).subscribe({
      next: () => {
        // Success — backend returned a token, AuthService saved it.
        // Navigate to books page.
        this.router.navigate(['/books']);
      },
      error: (err) => {
        // Failure — show the backend's error message (e.g. "Invalid credentials")
        this.serverError = err.error?.message || 'Login failed. Please try again.';
        this.loading = false; // re-enable the button
      },
    });
  }
}
```

---

### 📂 `src/app/features/auth/login/login.html`

```html
<div class="d-flex justify-content-center align-items-center"
     style="min-height: calc(100vh - 60px); background: var(--book-bg)">

  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 440px">

    <h3 class="text-center font-serif mb-1">Welcome Back</h3>
    <p class="text-center text-muted mb-4 small">Sign in to your account</p>

    <!--
      [formGroup]="loginForm"  → square brackets = property binding (TS → HTML)
                                  connects this form tag to the loginForm in TypeScript
      (ngSubmit)="submitLogin()" → parentheses = event binding (HTML → TS)
                                    calls submitLogin() when form is submitted
    -->
    <form [formGroup]="loginForm" (ngSubmit)="submitLogin()">

      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <!--
          formControlName="email" → no brackets (it's a static string, not a variable)
                                    connects this input to loginForm.controls.email
        -->
        <input class="form-control" type="email"
               formControlName="email"
               placeholder="you@example.com" />
        <!--
          @if → Angular 17+ control flow, replaces *ngIf
          We show the error ONLY when the field is:
            1. touched (user clicked on it and then away)  AND
            2. invalid (fails validation)
          Without "touched", errors show before the user even tries to fill the form.
        -->
        @if (loginForm.get('email')?.touched && loginForm.get('email')?.invalid) {
          <small class="text-danger">Please enter a valid email</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Password</label>
        <input class="form-control" type="password"
               formControlName="password"
               placeholder="Enter your password" />
        @if (loginForm.get('password')?.touched && loginForm.get('password')?.invalid) {
          <small class="text-danger">Password is required</small>
        }
      </div>

      <!-- Server-side error (from the backend, e.g. "Invalid credentials") -->
      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }

      <!--
        [disabled]="loading" → property binding
                               when loading is true, this button becomes disabled
                               prevents double-submit while the API call is in flight
      -->
      <button class="btn btn-book-primary w-100 fw-bold py-2"
              type="submit"
              [disabled]="loading">
        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Signing in...
        } @else {
          Sign In
        }
      </button>

    </form>

    <div class="text-center mt-3">
      <small class="text-muted">
        Don't have an account?
        <a routerLink="/auth/register"
           class="text-decoration-none fw-semibold"
           style="color: var(--book-accent)">Register</a>
      </small>
    </div>

  </div>
</div>
```

---

---

# 📖 STEP 9 — Register Page

## Professor Explanation First

Register follows the exact same pattern as Login. Same form structure, same subscribe pattern. The only differences:

1. More fields (firstName, lastName, dob in addition to email + password)
2. On success, we **don't log in automatically** — we redirect to Login and let the user sign in. This is a deliberate UX choice: some apps verify email before activating the account.
3. We show a success message before redirecting (using `setTimeout` to give them 1.5 seconds to read it)

Once you understand Login, Register is just more of the same. Read through it and it should feel familiar.

---

### 📂 `src/app/features/auth/register/register.ts`

```ts
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './register.html',
  styleUrl: './register.css',
})
export class Register {
  loading = false;
  serverError = '';
  successMessage = '';

  registerForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    lastName:  new FormControl('', [Validators.required, Validators.minLength(2)]),
    email:     new FormControl('', [Validators.required, Validators.email]),
    password:  new FormControl('', [Validators.required, Validators.minLength(6)]),
    dob:       new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitRegister() {
    if (this.registerForm.invalid) return;

    this.loading = true;
    this.serverError = '';

    const { firstName, lastName, email, password, dob } = this.registerForm.value;

    this.auth.register({
      firstName: firstName!,
      lastName:  lastName!,
      email:     email!,
      password:  password!,
      dob:       dob!,
    }).subscribe({
      next: () => {
        this.successMessage = 'Account created! Redirecting to sign in...';
        // Give the user 1.5 seconds to read the success message, then redirect
        setTimeout(() => this.router.navigate(['/auth/login']), 1500);
      },
      error: (err) => {
        this.serverError = err.error?.message || 'Registration failed. Please try again.';
        this.loading = false;
      },
    });
  }
}
```

---

### 📂 `src/app/features/auth/register/register.html`

```html
<div class="d-flex justify-content-center align-items-center py-5"
     style="min-height: calc(100vh - 60px); background: var(--book-bg)">

  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 480px">

    <h3 class="text-center font-serif mb-1">Create Account</h3>
    <p class="text-center text-muted mb-4 small">Join the bookstore community</p>

    <form [formGroup]="registerForm" (ngSubmit)="submitRegister()">

      <div class="row g-3 mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" type="text" formControlName="firstName" placeholder="Ahmed" />
          @if (registerForm.get('firstName')?.touched && registerForm.get('firstName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
        <div class="col-6">
          <label class="form-label small fw-semibold">Last Name</label>
          <input class="form-control" type="text" formControlName="lastName" placeholder="Hassan" />
          @if (registerForm.get('lastName')?.touched && registerForm.get('lastName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <input class="form-control" type="email" formControlName="email" placeholder="you@example.com" />
        @if (registerForm.get('email')?.touched && registerForm.get('email')?.invalid) {
          <small class="text-danger">Valid email required</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Password</label>
        <input class="form-control" type="password" formControlName="password" placeholder="At least 6 characters" />
        @if (registerForm.get('password')?.touched && registerForm.get('password')?.invalid) {
          <small class="text-danger">Min 6 characters</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Date of Birth</label>
        <input class="form-control" type="date" formControlName="dob" />
        @if (registerForm.get('dob')?.touched && registerForm.get('dob')?.invalid) {
          <small class="text-danger">Date of birth is required</small>
        }
      </div>

      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }
      @if (successMessage) {
        <div class="alert alert-success py-2 small">{{ successMessage }}</div>
      }

      <button class="btn btn-book-primary w-100 fw-bold py-2" type="submit" [disabled]="loading">
        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Creating account...
        } @else {
          Create Account
        }
      </button>

    </form>

    <div class="text-center mt-3">
      <small class="text-muted">
        Already have an account?
        <a routerLink="/auth/login"
           class="text-decoration-none fw-semibold"
           style="color: var(--book-accent)">Sign In</a>
      </small>
    </div>

  </div>
</div>
```

---

---

# 📖 STEP 10 — Profile Page

## Professor Explanation First

Profile is different from Login and Register in one important way: when the page opens, the form should already be filled with the user's current data.

**How do we get the user's current data without making an API call?**

Remember: the JWT token you saved in localStorage already contains the user's data encoded inside it. You can decode it with `auth.getCurrentUser()` — no network request needed.

This is the beauty of JWTs: they carry the user's info with them. As long as the token isn't expired, you have access to the user's `firstName`, `lastName`, `dob`, `email`, and `role` — instantly, from localStorage.

**The flow:**
```
ngOnInit runs (immediately when page loads)
    ↓
auth.getCurrentUser() → decodes the JWT → returns { firstName, lastName, dob, email, ... }
    ↓
profileForm.patchValue({ firstName, lastName, dob }) → fills the form fields
    ↓
User sees their current data pre-filled ✅
    ↓
User edits → clicks Save → calls auth.updateProfile()
```

**`patchValue` vs `setValue`:**
- `setValue` requires you to provide values for ALL fields in the form
- `patchValue` lets you provide values for SOME fields — the rest stay as they are

Use `patchValue` when you're partially filling a form. Use `setValue` only when you're replacing all values at once.

---

### 📂 `src/app/features/profile/profile.ts`

```ts
import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class Profile implements OnInit {
  loading = false;
  successMessage = '';
  errorMessage = '';
  userEmail = ''; // displayed read-only above the form (can't be changed here)

  profileForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    lastName:  new FormControl('', [Validators.required, Validators.minLength(2)]),
    dob:       new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService) {}

  // ngOnInit runs once, immediately after the component is created.
  // Perfect for: fetching data, pre-filling forms, setting up subscriptions.
  ngOnInit() {
    const user = this.auth.getCurrentUser(); // decode token — no API call

    if (user) {
      this.userEmail = user.email; // show email read-only in the template

      // patchValue fills the form fields with existing values
      // This is why the form appears pre-filled when the user lands on this page
      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName:  user.lastName,
        dob:       user.dob,
      });
    }
  }

  submitProfile() {
    if (this.profileForm.invalid) return;

    this.loading = true;
    this.successMessage = '';
    this.errorMessage = '';

    const { firstName, lastName, dob } = this.profileForm.value;

    this.auth.updateProfile({ firstName: firstName!, lastName: lastName!, dob: dob! })
      .subscribe({
        next: () => {
          this.successMessage = 'Profile updated successfully!';
          this.loading = false;
        },
        error: (err) => {
          this.errorMessage = err.error?.message || 'Update failed. Please try again.';
          this.loading = false;
        },
      });
  }
}
```

---

### 📂 `src/app/features/profile/profile.html`

```html
<div class="container py-5" style="max-width: 600px">
  <div class="card border-book shadow-sm p-4 fade-in">

    <!-- Profile header: avatar icon + email -->
    <div class="d-flex align-items-center gap-3 mb-4">
      <div class="rounded-circle bg-book-primary d-flex align-items-center justify-content-center"
           style="width: 56px; height: 56px; flex-shrink: 0">
        <i class="fa-solid fa-user text-white fs-5"></i>
      </div>
      <div>
        <h4 class="font-serif mb-0">My Profile</h4>
        <small class="text-muted">{{ userEmail }}</small>
      </div>
    </div>

    <form [formGroup]="profileForm" (ngSubmit)="submitProfile()">

      <div class="row g-3 mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" type="text" formControlName="firstName" />
          @if (profileForm.get('firstName')?.touched && profileForm.get('firstName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
        <div class="col-6">
          <label class="form-label small fw-semibold">Last Name</label>
          <input class="form-control" type="text" formControlName="lastName" />
          @if (profileForm.get('lastName')?.touched && profileForm.get('lastName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Date of Birth</label>
        <input class="form-control" type="date" formControlName="dob" />
      </div>

      @if (successMessage) {
        <div class="alert alert-success py-2 small">{{ successMessage }}</div>
      }
      @if (errorMessage) {
        <div class="alert alert-danger py-2 small">{{ errorMessage }}</div>
      }

      <button class="btn btn-book-primary w-100 fw-bold py-2" type="submit" [disabled]="loading">
        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Saving...
        } @else {
          Save Changes
        }
      </button>

    </form>
  </div>
</div>
```

---

---

# 📖 STEP 11 — Not-Found Page

## Professor Explanation First

The `**` route in `app.routes.ts` matches any URL that wasn't matched by other routes. Angular loads the `NotFound` component for those URLs.

This page is the simplest thing you'll build today — no logic, no forms, no API calls. Just a 404 message and a link back home.

The one thing worth noting: notice it uses `component: NotFound` (not `loadComponent`). The 404 route is a catch-all, so lazy loading doesn't make sense here. The component is tiny and always potentially needed.

---

### 📂 `src/app/not-found/not-found.ts`

```ts
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink], // needed for routerLink in the template
  templateUrl: './not-found.html',
  styleUrl: './not-found.css',
})
export class NotFound {}
// No logic needed — pure display component
```

---

### 📂 `src/app/not-found/not-found.html`

```html
<div class="d-flex flex-column justify-content-center align-items-center text-center fade-in"
     style="min-height: calc(100vh - 60px)">
  <h1 class="font-serif" style="font-size: 96px; color: var(--book-accent); line-height: 1">404</h1>
  <h4 class="font-serif mb-2">Page Not Found</h4>
  <p class="text-muted mb-4">The page you're looking for doesn't exist or was moved.</p>
  <a routerLink="/books" class="btn btn-book-primary px-4 py-2 fw-bold">
    <i class="fa-solid fa-book me-2"></i>Browse Books
  </a>
</div>
```

---

---

# 📖 STEP 12 — Connect Navbar to AuthService

## Professor Explanation First

Right now the Navbar has:
```ts
isLoggedIn = false; // hardcoded — will never change
isAdmin = false;    // hardcoded — will never change
```

So even after the user logs in, the Navbar still shows "Sign In" and "Register" buttons, and hides Cart/Orders/Profile. That's broken.

**The fix:** make the Navbar **subscribe** to `AuthService.authStatus$`. Every time the user logs in or out, the `BehaviorSubject` inside AuthService emits a new value, the Navbar's subscription callback runs, and `isLoggedIn` is updated. Angular detects the change and re-renders the navbar template.

This is the reactive pattern: the Navbar doesn't poll or check — it just listens and reacts.

**About `ngOnDestroy` and unsubscribing:**

When you subscribe to an Observable, the subscription keeps listening **even after the component is gone**. This creates a memory leak — the component object stays alive in memory, consuming resources, even though it's no longer visible.

`ngOnDestroy` is a lifecycle hook that Angular calls when it removes a component from the page. You unsubscribe there to clean up.

The Navbar won't actually be destroyed in this app (it's always visible). But it's a habit you must build for every component that subscribes — because in other components (modal dialogs, dynamic lists, etc.), forgetting to unsubscribe will cause real bugs.

---

### 📂 Replace `src/app/shared/navbar/navbar.ts` entirely:

```ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { Subscription } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './navbar.html',
})
export class Navbar implements OnInit, OnDestroy {
  isLoggedIn = false;
  isAdmin = false;
  cartItemCount = 0;

  // We store the subscription so we can cancel it in ngOnDestroy
  // The ! tells TypeScript "I know this will be assigned before it's used"
  private authSub!: Subscription;

  constructor(private auth: AuthService) {}

  ngOnInit() {
    // Subscribe to the auth status stream.
    // The callback here runs EVERY TIME loggedIn$ emits a new value.
    // It also runs IMMEDIATELY with the current value (because it's a BehaviorSubject).
    this.authSub = this.auth.authStatus$.subscribe(loggedIn => {
      this.isLoggedIn = loggedIn;
      this.isAdmin = this.auth.isAdmin();
    });
  }

  ngOnDestroy() {
    // Cancel the subscription to prevent memory leaks.
    // The ?. is "optional chaining" — if authSub was never assigned, this won't crash.
    this.authSub?.unsubscribe();
  }

  onLogout() {
    // AuthService handles everything: removes token, notifies subscribers, navigates
    this.auth.logout();
  }
}
```

The HTML template for the Navbar is **already correct** in the project — it already uses `@if (isLoggedIn)` and `@if (isAdmin)`. You just needed to make those variables come from real data instead of being hardcoded.

---

---

# ✅ Final Checklist + Testing

## After you're done, test this exact sequence:

**Test 1 — Registration:**
1. Go to `/auth/register`
2. Fill the form → submit
3. Should see success message → redirect to `/auth/login`

**Test 2 — Login + Navbar:**
1. Go to `/auth/login`
2. Enter credentials → submit
3. Should redirect to `/books`
4. Navbar should now show: Cart, My Orders, Profile, Logout (Cart/Orders/Profile were hidden before)

**Test 3 — Token is being sent:**
1. Open browser DevTools → Network tab
2. Navigate to any page that calls an API
3. Click on a request → Headers tab
4. Should see: `Authorization: Bearer eyJ...`

**Test 4 — Guard works:**
1. Open DevTools → Application → Local Storage → delete `jwt_token`
2. Type `/profile` in the URL bar → should redirect to `/auth/login`
3. Type `/cart` → same thing
4. Type `/admin` while logged in as regular user → should redirect to `/`

**Test 5 — Profile pre-fills:**
1. Log in
2. Go to `/profile`
3. Your first name, last name, date of birth should already be in the form — not empty

**Test 6 — Logout:**
1. Click Logout in the Navbar
2. Should go to `/auth/login`
3. Navbar should show only "Sign In" and "Register"
4. Try going to `/profile` → redirected to `/auth/login`

**Test 7 — 404:**
1. Type `/anyrandompath` in URL bar
2. Should show the 404 page with "Browse Books" button

---

## When Something Breaks — Common Errors

**`NullInjectorError: No provider for HttpClient`**
→ `provideHttpClient()` is missing from `app.config.ts`. Go back to Step 6.

**`Can't bind to 'formGroup' since it isn't a known property of 'form'`**
→ `ReactiveFormsModule` is missing from the component's `imports: []`. Check the `@Component` decorator.

**Token not appearing in request headers (Network tab)**
→ `withInterceptors([tokenInterceptor, errorInterceptor])` is missing from `provideHttpClient()` in `app.config.ts`.

**Guards not working (protected page loads even without login)**
→ `canActivate: [authGuard]` is missing from that route in `app.routes.ts`.

**Navbar doesn't update after login**
→ The `authSub = this.auth.authStatus$.subscribe(...)` is not in `ngOnInit`, or AuthService is not injected in the Navbar constructor.

**Profile page shows empty form (not pre-filled)**
→ `this.profileForm.patchValue(...)` is not being called, or `auth.getCurrentUser()` is returning null (token might not be saved correctly in login).

**TypeScript errors about missing properties**
→ You're probably using the data without the interface, or the interface has a typo. Check Step 1.
