# 🎯 Khaled's Frontend Guide — Today Until Saturday
> Angular 21 Standalone | Bootstrap 5 | Bookstore Theme
> **Your role:** Auth + Core Infrastructure (the skeleton everyone else depends on)

---

## 🧠 Before You Touch Anything — Read This

The project is already running. The routes exist. The navbar exists. The theme exists. **Your job is to fill in the auth brain** — the service, the guards, the interceptors, and the pages.

Here's the mental model for today:

```
You build the CORE:
  AuthService        → knows who the user is
  TokenInterceptor   → silently adds the token to every API request
  ErrorInterceptor   → handles 401/403 globally so you don't repeat yourself
  authGuard          → blocks pages from non-logged-in users
  adminGuard         → blocks admin page from non-admin users

Then you build the PAGES:
  Login              → calls AuthService.login()
  Register           → calls AuthService.register()
  Profile            → calls AuthService.updateProfile()
  Not Found          → simple 404 page

Then you CONNECT:
  Navbar             → reads AuthService state so links show/hide correctly
  app.config.ts      → registers interceptors globally
  app.routes.ts      → attaches guards to protected routes
```

Everything depends on `AuthService`. Build it first. Everything else follows.

---

## 📋 Checklist (tick as you go)

- [ ] Step 1 — Create the folder structure + 5 model files
- [ ] Step 2 — Build AuthService
- [ ] Step 3 — Build Token Interceptor
- [ ] Step 4 — Build Error Interceptor
- [ ] Step 5 — Build authGuard
- [ ] Step 6 — Build adminGuard
- [ ] Step 7 — Wire interceptors into app.config.ts
- [ ] Step 8 — Add guards to app.routes.ts
- [ ] Step 9 — Build Login page (TS + HTML)
- [ ] Step 10 — Build Register page (TS + HTML)
- [ ] Step 11 — Build Profile page (TS + HTML)
- [ ] Step 12 — Build Not-Found page
- [ ] Step 13 — Connect Navbar to AuthService

---

## 📁 Step 0 — Create the Folder Structure First

Before writing any code, create these folders/files so Angular doesn't complain about missing imports.

```bash
# From inside your project root (bookstore-frontend)
mkdir -p src/app/core/models
mkdir -p src/app/core/services
mkdir -p src/app/core/interceptors
mkdir -p src/app/core/guards
```

Then create the empty files:
```bash
touch src/app/core/models/user.model.ts
touch src/app/core/models/cart.model.ts
touch src/app/core/models/order.model.ts
touch src/app/core/models/review.model.ts
touch src/app/core/models/api-response.model.ts
touch src/app/core/models/index.ts
touch src/app/core/services/auth.service.ts
touch src/app/core/interceptors/token.interceptor.ts
touch src/app/core/interceptors/error.interceptor.ts
touch src/app/core/guards/auth.guard.ts
touch src/app/core/guards/admin.guard.ts
```

---

## 📖 Step 1 — TypeScript Models (Interfaces)

### What is this and why do we need it?

A **TypeScript interface** is a contract. It says: "this variable will ALWAYS have these exact fields."

Without it, TypeScript treats everything as `any`, which means:
- No autocomplete
- No error if you mistype a field name
- No idea what shape the API data is

**Example of why it matters:**
```ts
// WITHOUT interface (any) — TypeScript can't help you
const user: any = getUserFromToken();
console.log(user.fristName); // TYPO — but TypeScript won't warn you

// WITH interface — TypeScript catches the typo immediately
const user: User = getUserFromToken();
console.log(user.fristName); // ❌ TypeScript error: Property 'fristName' does not exist
```

---

### 📂 `src/app/core/models/user.model.ts`

```ts
export interface User {
  _id: string;
  email: string;
  firstName: string;
  lastName: string;
  dob: string;
  role: 'user' | 'admin';   // union type — can ONLY be one of these two values
  isVerified: boolean;
  createdAt: string;
}
```

> **Why `'user' | 'admin'` instead of just `string`?**
> This is called a **union type**. It restricts the value to only two possibilities.
> If you later write `if (user.role === 'superadmin')` — TypeScript will warn you that 'superadmin' can never happen.
> It's like an enum but simpler.

---

### 📂 `src/app/core/models/cart.model.ts`

```ts
import { Book } from './book.model';  // your teammate already made this

export interface CartItem {
  book: Book;
  quantity: number;
}

export interface Cart {
  _id: string;
  user: string;
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
  priceAtPurchase: number;
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
  comment?: string;   // the ? means this field is OPTIONAL — it might not exist
  createdAt: string;
}
```

> **Why `comment?` with a question mark?**
> Not every review has a comment — user might just give stars with no text.
> The `?` tells TypeScript: "this field might be undefined, and that's okay."
> Without it, TypeScript would force you to always provide a comment.

---

### 📂 `src/app/core/models/api-response.model.ts`

```ts
// T is a "placeholder" — when you use ApiResponse<User>,
// TypeScript replaces T with User everywhere in this interface.
// This way ONE interface works for ALL API responses.

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
  pagination?: PaginationMeta;
}
```

> **What is `<T>` (Generics)?**
> Think of it like a function parameter, but for types.
>
> ```ts
> ApiResponse<User>       // data is a User object
> ApiResponse<Book[]>     // data is an array of Books
> ApiResponse<string>     // data is a string
> ```
>
> Without generics, you'd need a separate interface for every possible response type.
> With generics, ONE interface handles everything.

---

### 📂 `src/app/core/models/index.ts`

This file re-exports everything so teammates can write:
`import { User, Order } from '../core/models'` instead of two separate import lines.

```ts
export type { User } from './user.model';
export type { CartItem, Cart } from './cart.model';
export type { OrderItem, ShippingDetails, Order } from './order.model';
export type { Review } from './review.model';
export type { ApiResponse, PaginationMeta } from './api-response.model';
```

> **Why `export type` instead of just `export`?**
> Interfaces only exist for type-checking during development — they disappear when code is compiled to JavaScript. `export type` tells the compiler: "don't try to bundle this as real JavaScript code."

---

## 📖 Step 2 — Build AuthService

### What is this and why do we need it?

A **Service** is a shared class that holds logic and data that multiple components need.

**Why not just put auth logic directly in the Login component?**
- The Navbar also needs to know if the user is logged in
- The Profile page also needs the current user's data
- The Guards also need to check login status

If you put the logic in the Login component, none of the others can reach it. A Service solves this — it's created once and shared everywhere.

### How JWT auth works in this project:

```
1. User fills Login form → component calls AuthService.login()
2. AuthService sends email + password to POST /api/auth/login
3. Backend verifies and returns { data: { token: "eyJ..." } }
4. AuthService saves token in localStorage
5. Later: every API request automatically includes this token (that's the interceptor's job)
6. To know WHO the user is: we decode the token (it contains _id, email, role inside it)
7. To logout: just delete the token from localStorage
```

The token looks like: `eyJhbGciOiJIUzI1NiJ9.eyJfaWQiOiIxMjMiLCJlbWFpbCI6InRlc3QifQ.signature`
It has 3 parts separated by dots. The MIDDLE part is the user data encoded in base64.

---

### 📂 `src/app/core/services/auth.service.ts`

```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap, BehaviorSubject } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AuthService {

  private api = `${environment.apiUrl}/auth`;
  private TOKEN_KEY = 'jwt_token';

  // BehaviorSubject is a special Observable that:
  // 1. Always holds a current value
  // 2. When you change the value, ALL subscribers are notified automatically
  // We use it so the Navbar updates the moment user logs in or out.
  private loggedIn$ = new BehaviorSubject<boolean>(this.isLoggedIn());

  // We expose it as a read-only Observable — components can subscribe but not change it
  authStatus$ = this.loggedIn$.asObservable();

  constructor(private http: HttpClient, private router: Router) {}

  // ─── REGISTER ────────────────────────────────────────────────
  register(data: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dob: string;
  }): Observable<any> {
    return this.http.post(`${this.api}/register`, data);
    // We return the Observable — component will .subscribe() to get the result
    // We do NOT subscribe here (service doesn't own the lifecycle)
  }

  // ─── LOGIN ───────────────────────────────────────────────────
  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.api}/login`, { email, password }).pipe(
      // tap() lets you "peek" at the data without changing it
      // Perfect for side effects like saving the token
      tap(res => {
        if (res.data?.token) {
          localStorage.setItem(this.TOKEN_KEY, res.data.token);
          this.loggedIn$.next(true);   // ← notifies Navbar: "user logged in!"
        }
      })
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────────────
  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.loggedIn$.next(false);       // ← notifies Navbar: "user logged out!"
    this.router.navigate(['/auth/login']);
  }

  // ─── GET TOKEN ───────────────────────────────────────────────
  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  // ─── DECODE TOKEN → GET USER DATA ────────────────────────────
  // A JWT has 3 parts: header.payload.signature
  // The payload (middle part) is base64-encoded JSON with user data
  // We decode it WITHOUT calling the API — the data is already inside the token
  getCurrentUser(): any | null {
    const token = this.getToken();
    if (!token) return null;
    try {
      const payload = token.split('.')[1];   // get the middle part
      const decoded = atob(payload);         // decode base64 to JSON string
      return JSON.parse(decoded);            // parse JSON string to object
    } catch {
      return null;
    }
  }

  // ─── CHECK IF LOGGED IN ──────────────────────────────────────
  isLoggedIn(): boolean {
    try {
      const token = this.getToken();
      if (!token) return false;
      const { exp } = JSON.parse(atob(token.split('.')[1]));
      // exp is in SECONDS, Date.now() is in MILLISECONDS — so multiply exp by 1000
      return exp * 1000 > Date.now();
    } catch {
      return false;
    }
  }

  // ─── CHECK IF ADMIN ──────────────────────────────────────────
  isAdmin(): boolean {
    return this.getCurrentUser()?.role === 'admin';
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────
  updateProfile(data: { firstName?: string; lastName?: string; dob?: string }): Observable<any> {
    return this.http.patch(`${this.api}/profile`, data);
  }
}
```

> **Why BehaviorSubject and not a plain boolean?**
>
> Imagine: user logs in on the Login page. The Navbar is a separate component.
> If `isLoggedIn` is just a plain `boolean`, the Navbar has no way to know it changed.
> With `BehaviorSubject`, the Navbar "subscribes" and gets automatically notified every time the value changes.
>
> It's like a YouTube channel: once you subscribe, you get every new video automatically.
> Without subscribing, you'd have to manually check the channel every time.

---

## 📖 Step 3 — Build Token Interceptor

### What is an interceptor and why do we need it?

An **interceptor** sits between your code and the network. Every HTTP request passes through it.

**Without interceptor — you'd have to add the token manually everywhere:**
```ts
// You'd repeat this in EVERY service method — AuthService, BookService, CartService...
this.http.get('/api/profile', {
  headers: { Authorization: `Bearer ${token}` }
})
```

**With interceptor — you write it ONCE and it applies to everything:**
```ts
// The interceptor adds the token to every request automatically
// Your service methods are clean and don't mention tokens at all
this.http.get('/api/profile')  // token is added silently by the interceptor
```

### How it works:

```
Component calls service.getProfile()
    ↓
Angular's HttpClient creates the request
    ↓
🔒 Token Interceptor intercepts it — adds "Authorization: Bearer eyJ..." header
    ↓
Request goes to the server WITH the token
    ↓
Server authenticates the user and returns data
```

---

### 📂 `src/app/core/interceptors/token.interceptor.ts`

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

// In Angular 21, interceptors are plain FUNCTIONS (not classes).
// Parameters:
//   req  = the outgoing HTTP request
//   next = the next handler — calling it sends the request forward
export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();

  // No token? Just pass the request through unchanged (for login/register routes)
  if (!token) return next(req);

  // HTTP requests are IMMUTABLE — you cannot change them directly.
  // You must CLONE them and apply changes to the clone.
  const authReq = req.clone({
    setHeaders: { Authorization: `Bearer ${token}` }
  });

  return next(authReq);  // send the cloned request with the token
};
```

> **Why `req.clone()` and not `req.headers.set()`?**
> Angular HTTP requests are immutable (read-only by design). You can't modify them.
> Think of it like a frozen object — you can only create a new copy with your changes.
> This is intentional: it prevents bugs where different parts of your code accidentally modify the same request.

---

## 📖 Step 4 — Build Error Interceptor

### What is this and why do we need it?

Without this, every component would need to handle `401 Unauthorized` and `403 Forbidden` errors individually. That's a lot of duplicated code.

The error interceptor handles common HTTP errors in ONE place:
- **401** = token expired or invalid → force logout automatically
- **403** = user tried to access something they're not allowed to → redirect home

```
Component calls service.getOrders()
    ↓
Request goes to server
    ↓
Server returns 401 (token expired)
    ↓
🚨 Error Interceptor catches it → calls auth.logout() → user goes to login page
    ↓
Component never even sees the error — it's handled globally
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

  return next(req).pipe(
    // catchError intercepts any error response from the server
    catchError(err => {
      if (err.status === 401) {
        // Token is expired or invalid — force the user to log in again
        auth.logout();
      }
      if (err.status === 403) {
        // User is logged in but not allowed to do this (e.g., regular user on admin page)
        router.navigate(['/']);
      }
      // We re-throw the error so components can still show their own error messages
      // (e.g., the Login form showing "Invalid credentials")
      return throwError(() => err);
    })
  );
};
```

> **Why `throwError(() => err)` and not just `throw err`?**
> In RxJS, you work with Observables, not regular JavaScript code.
> You can't use `throw` inside an Observable pipe — it breaks the stream.
> `throwError()` creates a new Observable that immediately errors out, which is the correct RxJS way to propagate errors.

---

## 📖 Step 5 — Build Auth Guard

### What is a Guard and why do we need it?

A **Guard** is a function that runs BEFORE Angular loads a route's component. It decides: "should this user be allowed on this page?"

Without guards, any user could type `/profile` or `/cart` in the browser and reach those pages even without being logged in. The guard is the bouncer.

```
User types /profile in the browser
    ↓
Angular Router checks: does this route have a canActivate guard?
    ↓
YES → runs authGuard function
    ↓
authGuard asks: is the user logged in?
    YES → loads the Profile component ✅
    NO  → redirects to /auth/login ❌
```

---

### 📂 `src/app/core/guards/auth.guard.ts`

```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// CanActivateFn = the type that Angular expects for a guard function
// Must return: true (allow), false (block silently), or a UrlTree (redirect)
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);

  if (auth.isLoggedIn()) {
    return true;  // ✅ user is logged in — let them through
  }

  // ❌ not logged in — redirect to login page
  // We use createUrlTree instead of router.navigate() because
  // guards must RETURN a value. router.navigate() doesn't return anything usable.
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
    return true;  // ✅ user is logged in AND is admin
  }

  // ❌ not admin — redirect to home
  return inject(Router).createUrlTree(['/']);
};
```

> **Why `createUrlTree` and not `router.navigate()`?**
> A guard must RETURN something Angular can act on.
> `router.navigate()` triggers navigation as a side effect and returns a Promise — Angular's router can't use that as a redirect instruction.
> `createUrlTree()` creates a proper redirect object that the router understands natively.

---

## 📖 Step 6 — Wire Interceptors into app.config.ts

### What is app.config.ts?

In Angular 21 there is **no app.module.ts**. Instead, all global providers (services, interceptors, HTTP client) are registered in `app.config.ts`. If you don't register your interceptors here, they simply do not run — it's as if they don't exist.

Your current `app.config.ts` only has `provideRouter`. You need to add `provideHttpClient` with the interceptors.

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

    // withInterceptors([...]) = "run these functions on every HTTP request"
    // ORDER MATTERS: token runs first (adds header), then error catches responses
    // withFetch() = use the modern fetch API internally (better performance)
    provideHttpClient(
      withFetch(),
      withInterceptors([tokenInterceptor, errorInterceptor])
    ),
  ]
};
```

> **What changed from before?**
> Before: `provideHttpClient()` — HTTP works but NO token is attached, NO error handling
> After: `provideHttpClient(withFetch(), withInterceptors([...]))` — both interceptors run on every request

---

## 📖 Step 7 — Add Guards to app.routes.ts

### What is `canActivate`?

`canActivate` is a property on a route that takes an array of guard functions.
Before loading the component, Angular calls each guard. If ANY guard returns false or a redirect — the page is blocked.

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
    canActivate: [authGuard],   // 🔒 must be logged in
  },
  {
    path: 'orders',
    canActivate: [authGuard],   // 🔒 must be logged in
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
    canActivate: [authGuard],   // 🔒 must be logged in
  },
  {
    path: 'admin',
    loadComponent: () => import('./features/admin/admin').then(c => c.Admin),
    canActivate: [adminGuard],  // 🔐 must be admin
  },
  {
    path: '**',
    component: NotFound,
  },
];
```

> **Why `loadComponent` instead of just `component`?**
> `loadComponent` = lazy loading. The component's JavaScript is only downloaded when the user actually navigates to that route. This makes the initial page load faster.
> `component` = eager loading. All components are downloaded upfront, even if the user never visits those pages.

---

## 📖 Step 8 — Build Login Page

### How Reactive Forms work

There are two ways to do forms in Angular. You're using **Reactive Forms** — the better way.

```
TypeScript file → defines the form and its rules
HTML template   → just displays the form, bound to TypeScript

They talk to each other through NAMES.
If TypeScript has: loginForm = new FormGroup({ email: new FormControl('') })
Then HTML uses:    formControlName="email"
They're connected by the word "email".
```

**The flow when user clicks Submit:**
```
User fills form → clicks Submit
    ↓
(ngSubmit) fires → calls submitLogin()
    ↓
TypeScript checks: is form.invalid? → stop if yes
    ↓
Calls auth.login(email, password) → returns Observable
    ↓
.subscribe({ next, error }) listens for the result
    ↓
next: → navigate to /books
error: → show error message on the form
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
  // ReactiveFormsModule is REQUIRED for [formGroup] and formControlName to work
  // RouterLink is REQUIRED for routerLink="/auth/register" in the template
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  loading = false;
  serverError = '';

  loginForm = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitLogin() {
    if (this.loginForm.invalid) return;  // stop if validation fails

    this.loading = true;
    this.serverError = '';

    const { email, password } = this.loginForm.value;

    this.auth.login(email!, password!).subscribe({
      next: () => {
        this.router.navigate(['/books']);
      },
      error: (err) => {
        this.serverError = err.error?.message || 'Login failed. Please try again.';
        this.loading = false;
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

    <!-- [formGroup] connects this <form> to the loginForm defined in TypeScript -->
    <!-- (ngSubmit) calls submitLogin() when the form is submitted -->
    <form [formGroup]="loginForm" (ngSubmit)="submitLogin()">

      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <!-- formControlName="email" links this input to loginForm.controls.email -->
        <input class="form-control" type="email"
               formControlName="email"
               placeholder="you@example.com" />
        <!-- Show error ONLY after user has touched the field (clicked away) -->
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

      <!-- Server error (e.g. "Invalid credentials") -->
      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }

      <!-- [disabled]="loading" disables the button while request is in flight -->
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

> **Key Angular syntax used here:**
> - `[formGroup]="loginForm"` — square brackets = property binding (TypeScript → HTML)
> - `(ngSubmit)="submitLogin()"` — parentheses = event binding (HTML → TypeScript)
> - `formControlName="email"` — no brackets because it's a string value, not a variable
> - `@if (condition) { }` — Angular 17+ control flow (replaces `*ngIf`)
> - `{{ serverError }}` — double curly braces = interpolation, displays variable as text
> - `[disabled]="loading"` — binds the disabled attribute to the loading variable

---

## 📖 Step 9 — Build Register Page

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

    this.auth.register({ firstName: firstName!, lastName: lastName!, email: email!, password: password!, dob: dob! })
      .subscribe({
        next: () => {
          this.successMessage = 'Account created! Redirecting to login...';
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

## 📖 Step 10 — Build Profile Page

### How it works

Profile is different from Login/Register:
- On load (`ngOnInit`): decode the token to pre-fill the form with current values — NO API call needed
- On submit: call `auth.updateProfile()` with only the changed fields

```
Page opens
    ↓
ngOnInit runs
    ↓
auth.getCurrentUser() → decodes token → gets { firstName, lastName, dob }
    ↓
form.patchValue() → fills the form fields automatically
    ↓
User edits and clicks Save → calls auth.updateProfile()
```

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
  userEmail = '';

  profileForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    lastName:  new FormControl('', [Validators.required, Validators.minLength(2)]),
    dob:       new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService) {}

  ngOnInit() {
    // Decode token to get user data — no API call needed
    const user = this.auth.getCurrentUser();
    if (user) {
      this.userEmail = user.email;
      // patchValue fills the form with existing values
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

## 📖 Step 11 — Build Not-Found Page

Simple — no logic, no forms. Just a 404 page with a link home.

### 📂 `src/app/not-found/not-found.ts`

```ts
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './not-found.html',
  styleUrl: './not-found.css',
})
export class NotFound {}
```

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

## 📖 Step 12 — Connect Navbar to AuthService

### What needs to change?

Right now the Navbar has hardcoded values:
```ts
isLoggedIn = false;  // hardcoded! will never change
isAdmin = false;     // hardcoded! will never change
```

You need to replace these with live values from `AuthService`. When the user logs in, the Navbar should immediately show Cart/Orders/Profile links without any page refresh.

**How it works:**
```
AuthService has a BehaviorSubject called loggedIn$
    ↓
Navbar subscribes to authStatus$ in ngOnInit
    ↓
User logs in → AuthService calls loggedIn$.next(true)
    ↓
Navbar's subscription callback fires → isLoggedIn = true
    ↓
Angular re-renders the Navbar → links appear instantly
```

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

  private authSub!: Subscription;

  constructor(private auth: AuthService) {}

  ngOnInit() {
    // Subscribe to auth state changes
    // Every time user logs in or out, this callback runs automatically
    this.authSub = this.auth.authStatus$.subscribe(loggedIn => {
      this.isLoggedIn = loggedIn;
      this.isAdmin = this.auth.isAdmin();
    });
  }

  ngOnDestroy() {
    // Always unsubscribe when component is destroyed — prevents memory leaks
    this.authSub?.unsubscribe();
  }

  onLogout() {
    this.auth.logout();
  }
}
```

> **Why unsubscribe in ngOnDestroy?**
> When you subscribe to an Observable, it keeps listening forever — even after the component is gone from the screen. This is a memory leak: the old component stays alive in memory, consuming resources.
> `ngOnDestroy` runs when Angular removes the component. We unsubscribe there to clean up.
>
> The Navbar lives for the whole app session so it won't actually be destroyed until the tab is closed. But it's still a good habit that protects you in every other component.

---

## ✅ Testing Your Work — Do This After Each Step

### After Step 2 (AuthService):
```
Open browser console → run: localStorage.setItem('jwt_token', 'test')
Then run: localStorage.removeItem('jwt_token')
```

### After Steps 3-6 (Interceptors + Guards):
```
ng serve → check browser console for errors
```

### After Steps 8-10 (Login + Register + Profile):
1. Go to `/auth/register` → create an account
2. Go to `/auth/login` → sign in
3. Check Navbar: Cart, Orders, Profile should appear
4. Open DevTools → Network tab → click any page → check request headers for `Authorization: Bearer ...`
5. Go to `/profile` → your name should be pre-filled

### After Step 11 (Guards wired):
1. Open DevTools → Application → Local Storage → delete `jwt_token`
2. Try going to `/profile` in the URL bar → should redirect to `/auth/login`
3. Try going to `/admin` while logged in as regular user → should redirect to `/`

### Full flow test:
1. `/auth/register` → register
2. `/auth/login` → login
3. Navbar shows protected links ✅
4. `/profile` → name pre-filled ✅
5. Logout → links disappear ✅
6. `/profile` → redirected to login ✅
7. `/doesntexist` → 404 page ✅

---

## 🚨 Common Errors and Fixes

**`NullInjectorError: No provider for HttpClient`**
→ You forgot to add `provideHttpClient()` to `app.config.ts`. Go back to Step 6.

**`Can't bind to 'formGroup' since it isn't a known property`**
→ You forgot `ReactiveFormsModule` in the component's `imports: []` array.

**`authStatus$ is undefined`** or Navbar doesn't update
→ AuthService is not injected properly. Check the constructor parameter name.

**TypeScript error: `Property 'X' does not exist on type 'never'`**
→ You're missing an interface or the import is wrong. Check Step 1.

**Guards aren't working (page loads even without login)**
→ You forgot to add `canActivate: [authGuard]` to the route in `app.routes.ts`. Go back to Step 7.

**Token not appearing in request headers**
→ The interceptor is not registered. Go back to Step 6 and make sure `withInterceptors([tokenInterceptor, errorInterceptor])` is inside `provideHttpClient()`.
