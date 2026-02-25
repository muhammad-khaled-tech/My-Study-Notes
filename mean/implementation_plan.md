# 🧑‍💻 Khaled's Frontend Implementation Guide

> **Deadline:** Saturday · **Branch:** `dev` · **Role:** Person 1 — Auth + Core Infrastructure
> **Tech:** Angular 21 (standalone, no NgModule), Bootstrap 5, RxJS

---

## 🗺️ Big Picture — What You Need to Build

Your teammates have already built:
- ✅ **3 Models:** [Book](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/book.model.ts#4-16), [Author](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/author.model.ts#1-8), [Category](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/category.model.ts#1-7) (in `core/models/`)
- ✅ **3 Services:** [BookService](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/services/book.service.ts#7-47), `AuthorService`, `CategoryService` (in `core/services/`)
- ✅ **Navbar** (in `shared/navbar/`) — uses `@if (isLoggedIn)` but the flags are **hardcoded** `false`. You will make them dynamic
- ✅ **Shared Components:** `BookCard`, `StarRating`, `Pagination`, `BookFilters`, `EmptyState`
- ✅ **Routing** — all routes are mapped in [app.routes.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.routes.ts)
- ✅ **Environment** — [environment.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/environments/environment.ts) points to `http://localhost:5000/api`
- ✅ **Styling** — [styles.css](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/styles.css) has the Bookstore theme with CSS variables

**Your job (what's missing):**

| # | Task | Files |
|---|------|-------|
| 1 | Add missing TypeScript models | `core/models/user.model.ts`, `cart.model.ts`, `order.model.ts`, `review.model.ts`, `api-response.model.ts` |
| 2 | Build AuthService | `core/services/auth.service.ts` |
| 3 | Build Token Interceptor | `core/interceptors/token.interceptor.ts` |
| 4 | Build Error Interceptor | `core/interceptors/error.interceptor.ts` |
| 5 | Build Auth Guard | `core/guards/auth.guard.ts` |
| 6 | Build Admin Guard | `core/guards/admin.guard.ts` |
| 7 | Wire interceptors + guards into [app.config.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.config.ts) and [app.routes.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.routes.ts) | |
| 8 | Build Login Page | `features/auth/login/` |
| 9 | Finish Register Page | `features/auth/register/` (you started the form!) |
| 10 | Build Profile Page | `features/profile/` |
| 11 | Build Not-Found Page | `not-found/` |
| 12 | Connect Navbar to AuthService | [shared/navbar/navbar.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/shared/navbar/navbar.ts) |

---

## 📖 Step 1 — Add the Missing TypeScript Models

### Why do we need models?

Models (interfaces) are like **contracts** — they tell TypeScript: "when I get data from the API, this is the shape it will have." Without them, TypeScript treats everything as `any`, and you lose autocomplete, error checking, and readability.

Your teammates already created [Book](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/book.model.ts#4-16), [Author](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/author.model.ts#1-8), [Category](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/category.model.ts#1-7). You need to add: `User`, `CartItem`, `Cart`, `Order`, `Review`, and a generic `ApiResponse`.

---

### 📂 `src/app/core/models/user.model.ts` [NEW]

```ts
// This describes the User object your backend sends back.
// Notice: password is NEVER returned by the API — so it's NOT here.

export interface User {
  _id: string;
  email: string;
  firstName: string;
  lastName: string;
  dob: string;           // ISO date string like "2000-01-15"
  role: 'user' | 'admin'; // only two possible values — TypeScript enforces this
  isVerified: boolean;
  createdAt: string;
}
```

> **Why `'user' | 'admin'` instead of `string`?**
> This is a **union type**. It means `role` can ONLY be `'user'` or `'admin'`. If you accidentally write `user.role === 'moderator'`, TypeScript will warn you — that value is impossible.

---

### 📂 `src/app/core/models/cart.model.ts` [NEW]

```ts
import { Book } from './book.model';

// One item in the cart
export interface CartItem {
  book: Book;       // the full book object (populated by backend)
  quantity: number;
}

// The entire cart
export interface Cart {
  _id: string;
  user: string;      // just the user ID
  items: CartItem[];
  total: number;     // calculated by backend
}
```

---

### 📂 `src/app/core/models/order.model.ts` [NEW]

```ts
// Snapshot of an item at the time of purchase
export interface OrderItem {
  book: { _id: string; name: string; coverImage: string };
  quantity: number;
  priceAtPurchase: number;  // price is "frozen" — never changes even if book price changes later
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

### 📂 `src/app/core/models/review.model.ts` [NEW]

```ts
export interface Review {
  _id: string;
  user: { _id: string; firstName: string; lastName: string };
  book: string;
  rating: number;       // 1 to 5 
  comment?: string;     // optional — the ? means it might be missing
  createdAt: string;
}
```

---

### 📂 `src/app/core/models/api-response.model.ts` [NEW]

```ts
// Every API response from your backend has this shape.
// The <T> is a "generic" — it means "data can be anything".
//
// Example: ApiResponse<User> means { success, message, data: User }
// Example: ApiResponse<Book[]> means { success, message, data: Book[] }

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
  pagination?: PaginationMeta;  // only present on paginated endpoints
}
```

> **What is `<T>` (generics)?**
> Think of it like a **placeholder**. When you use `ApiResponse<User>`, TypeScript replaces every `T` with `User`. So `data` becomes `data: User`. This way, one interface works for ALL your API responses.

---

### 📂 Update [src/app/core/models/index.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/core/models/index.ts)

```ts
export type { Book } from './book.model';
export type { Author } from './author.model';
export type { Category } from './category.model';
export type { User } from './user.model';
export type { CartItem, Cart } from './cart.model';
export type { OrderItem, ShippingDetails, Order } from './order.model';
export type { Review } from './review.model';
export type { ApiResponse, PaginationMeta } from './api-response.model';
```

> **Why `export type` instead of just `export`?**
> Because interfaces are only used for type-checking — they don't exist at runtime. `export type` tells Angular's build tool: "this is just a type, don't try to bundle it as real code." It's a best practice in Angular 21.

---

## 📖 Step 2 — Build AuthService

### Why do we need this?

Every auth operation (login, register, logout, checking if user is logged in) should live in ONE central service. Components just **call** the service — they don't know how tokens work.

### How JWT works (quick refresher):

```
1. User logs in → backend returns a JWT token (a long string)
2. We save it in localStorage
3. Every future API request includes this token in the header
4. To know WHO the user is, we decode the token (it contains _id, email, role)
5. To logout, we just delete the token from localStorage
```

---

### 📂 `src/app/core/services/auth.service.ts` [NEW]

```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap, BehaviorSubject } from 'rxjs';
import { environment } from '../../../environments/environment';

// @Injectable({ providedIn: 'root' }) means:
// "Create ONE instance of this service for the entire app."
// This is called a SINGLETON. Every component that injects AuthService
// gets the SAME instance — so they all share the same login state.

@Injectable({ providedIn: 'root' })
export class AuthService {

  private api = `${environment.apiUrl}/auth`;
  private TOKEN_KEY = 'jwt_token';

  // BehaviorSubject is like a variable that components can "subscribe" to.
  // When its value changes, every subscriber gets notified automatically.
  // We use it so the Navbar updates instantly when user logs in/out.
  private loggedIn$ = new BehaviorSubject<boolean>(this.isLoggedIn());

  // Public observable — components subscribe to this (read-only)
  authStatus$ = this.loggedIn$.asObservable();

  constructor(private http: HttpClient, private router: Router) {}

  // ─── REGISTER ───────────────────────────────────────────
  // Sends user data to POST /api/auth/register
  // Returns an Observable — the component subscribes to get the result.
  register(data: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dob: string;
  }): Observable<any> {
    return this.http.post(`${this.api}/register`, data);
  }

  // ─── LOGIN ──────────────────────────────────────────────
  // 1. Sends email + password to backend
  // 2. If successful, backend returns { data: { token, user } }
  // 3. We save the token in localStorage
  // 4. We notify all subscribers that user is now logged in
  //
  // `tap()` is an RxJS operator — it lets you "peek" at the data
  // flowing through without changing it. Perfect for side effects
  // like saving to localStorage.

  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.api}/login`, { email, password }).pipe(
      tap(res => {
        if (res.data?.token) {
          localStorage.setItem(this.TOKEN_KEY, res.data.token);
          this.loggedIn$.next(true);   // tell Navbar: "user just logged in!"
        }
      })
    );
  }

  // ─── LOGOUT ─────────────────────────────────────────────
  // 1. Remove token from localStorage
  // 2. Notify subscribers
  // 3. Navigate to login page

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.loggedIn$.next(false);     // tell Navbar: "user just logged out!"
    this.router.navigate(['/auth/login']);
  }

  // ─── TOKEN HELPERS ──────────────────────────────────────

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  // Decode the JWT to get user info (without calling the API!)
  // JWT structure: header.payload.signature
  // We only need the payload (index [1])
  // atob() decodes base64 → then we parse the JSON

  getCurrentUser(): any | null {
    const token = this.getToken();
    if (!token) return null;
    try {
      const payload = token.split('.')[1];       // get the middle part
      const decoded = atob(payload);             // decode from base64
      return JSON.parse(decoded);                // parse JSON
    } catch {
      return null;                               // if token is corrupted
    }
  }

  // Check if user is currently logged in
  // We also check if the token is expired (exp field is in seconds)

  isLoggedIn(): boolean {
    try {
      const token = this.getToken();
      if (!token) return false;
      const { exp } = JSON.parse(atob(token.split('.')[1]));
      return exp * 1000 > Date.now();  // exp is in seconds, Date.now() is in ms
    } catch {
      return false;
    }
  }

  // Check if current user has admin role

  isAdmin(): boolean {
    return this.getCurrentUser()?.role === 'admin';
  }

  // ─── UPDATE PROFILE ─────────────────────────────────────

  updateProfile(data: { firstName?: string; lastName?: string; dob?: string }): Observable<any> {
    return this.http.patch(`${this.api}/profile`, data);
  }
}
```

> **Why `BehaviorSubject`?**
> Imagine you have 3 components that need to know if the user is logged in: the Navbar, the Cart page, and the Profile page. Without `BehaviorSubject`, you'd have to manually refresh each component. With it, they all "subscribe" and get notified automatically.
>
> **`BehaviorSubject` vs `Subject`:** A `BehaviorSubject` always has a current value. When a new component subscribes, it immediately gets the latest value. A regular `Subject` only emits when something new happens — late subscribers miss previous values.

---

## 📖 Step 3 — Build Token Interceptor

### What is an interceptor?

An interceptor is **middleware for HTTP requests**. It sits between your service and the actual network call. Every single HTTP request in your app passes through it.

It is like being automatically logged in—every request to the backend automatically includes your JWT token, so you don't have to add it manually in every single service method.

### How it works:
```
Component calls service.getBooks()
    ↓
HttpClient creates the request
    ↓
🔒 Token Interceptor adds "Authorization: Bearer <token>" header
    ↓
Request goes to the server
```

---

### 📂 `src/app/core/interceptors/token.interceptor.ts` [NEW]

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

// In Angular 21, interceptors are just FUNCTIONS — not classes.
// This function receives the request and a "next" handler.
// We clone the request (because requests are immutable — you can't modify them),
// add the Authorization header, and pass it along.

export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();

  // If no token, just pass the request through unchanged
  if (!token) return next(req);

  // Clone the request and add the Authorization header
  const clonedReq = req.clone({
    setHeaders: { Authorization: `Bearer ${token}` }
  });

  return next(clonedReq);
};
```

> **Why `req.clone()` instead of `req.headers.set()`?**
> HTTP requests in Angular are **immutable** (read-only). You can't change them directly. You have to create a copy with the change you want. This is a design choice for safety — it prevents accidental modifications.

---

## 📖 Step 4 — Build Error Interceptor

### What does this do?

It catches every HTTP **error response** from your API. Instead of handling errors in every single component, this interceptor handles common ones globally:

- **401 (Unauthorized)** — Token expired or invalid → auto-logout
- **403 (Forbidden)** — User doesn't have permission → show message + redirect

---

### 📂 `src/app/core/interceptors/error.interceptor.ts` [NEW]

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
    // catchError intercepts any error response from the API
    catchError(err => {
      if (err.status === 401) {
        // Token expired or invalid — force logout
        auth.logout();
      }
      if (err.status === 403) {
        // User tried to access something they shouldn't
        router.navigate(['/']);
        alert('Access denied');
        // You could also use a toast/snackbar library instead of alert()
      }
      // Re-throw the error so the component can still handle it
      // (e.g., show "Invalid credentials" on the login form)
      return throwError(() => err);
    })
  );
};
```

> **Why `throwError(() => err)` instead of just `throw err`?**
> In RxJS, you can't use regular `throw`. You need `throwError()` — it creates an Observable that immediately errors. The [() => err](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.ts#5-15) is a factory function that creates the error lazily.

---

## 📖 Step 5 — Build Auth Guard and Admin Guard

### What is a Guard?

A guard is a **bouncer for routes**. Before Angular loads a page, it asks the guard: "Should this user be allowed in?" If the guard says no, the user gets redirected.

```
User clicks "My Orders"
    ↓
Angular asks authGuard: "Is user logged in?"
    ↓
  YES → load the Orders page
  NO  → redirect to /auth/login
```

---

### 📂 `src/app/core/guards/auth.guard.ts` [NEW]

```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// CanActivateFn is the type for a guard function.
// It must return: true (allow), false (block), or a UrlTree (redirect).

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);

  if (auth.isLoggedIn()) {
    return true;                                      // ✅ let them in
  }

  // ❌ not logged in — redirect to login page
  return inject(Router).createUrlTree(['/auth/login']);
};
```

---

### 📂 `src/app/core/guards/admin.guard.ts` [NEW]

```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);

  if (auth.isLoggedIn() && auth.isAdmin()) {
    return true;                                  // ✅ admin — let them in
  }

  // ❌ not admin — redirect to home
  return inject(Router).createUrlTree(['/']);
};
```

> **Why `createUrlTree` instead of `router.navigate`?**
> Guards must **return** something. `router.navigate()` doesn't return a value the guard can use. `createUrlTree()` creates a redirect instruction that Angular's router understands natively.

---

## 📖 Step 6 — Wire Everything into [app.config.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.config.ts)

### Why is this important?

In Angular 21 (standalone), there is **no `app.module.ts`**. All global providers go in [app.config.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.config.ts). If you don't register your interceptors here, they simply won't run.

---

### 📂 Update [src/app/app.config.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.config.ts)

Replace the current content with:

```ts
import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZonelessChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { tokenInterceptor } from './core/interceptors/token.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZonelessChangeDetection(),
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),

    // withInterceptors() tells Angular: "run these functions on EVERY HTTP request"
    // Order matters! Token interceptor runs first (adds header),
    // then error interceptor catches any errors.
    provideHttpClient(withInterceptors([tokenInterceptor, errorInterceptor])),
  ]
};
```

> **What changed?** We added `withInterceptors([...])` inside `provideHttpClient()`. Before, it was just `provideHttpClient()` with no interceptors — so no token was being sent to the backend.

---

## 📖 Step 7 — Add Guards to Routes

### 📂 Update [src/app/app.routes.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.routes.ts)

You need to protect certain routes: `cart`, `orders`, `profile` need login; `admin` needs admin role.

```ts
import { Routes } from '@angular/router';
import { NotFound } from './not-found/not-found';
import { authGuard } from './core/guards/auth.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./features/books/home/home').then(m => m.Home)
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
    children: [
      {
        path: '',
        loadComponent: () => import('./features/books/book-list/book-list').then(m => m.BookList)
      },
      {
        path: ':id',
        loadComponent: () => import('./features/books/book-detail/book-detail').then(m => m.BookDetail)
      }
    ]
  },
  {
    path: 'authors',
    loadComponent: () =>
      import('./features/authors/author-list/author-list').then(c => c.AuthorList),
  },
  {
    // 🔒 Protected: must be logged in
    path: 'cart',
    loadComponent: () => import('./features/cart/cart').then(c => c.Cart),
    canActivate: [authGuard],
  },
  {
    // 🔒 Protected: must be logged in
    path: 'orders',
    canActivate: [authGuard],
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/orders/order-history/order-history').then(c => c.OrderHistory),
      },
      {
        path: 'checkout',
        loadComponent: () => import('./features/orders/checkout/checkout').then(c => c.Checkout),
      },
    ],
  },
  {
    // 🔒 Protected: must be logged in
    path: 'profile',
    loadComponent: () => import('./features/profile/profile').then(c => c.Profile),
    canActivate: [authGuard],
  },
  {
    // 🔐 Protected: must be admin
    path: 'admin',
    loadComponent: () => import('./features/admin/admin').then(c => c.Admin),
    canActivate: [adminGuard],
  },
  {
    path: '**',
    component: NotFound,
  },
];
```

> **What is `canActivate`?**
> It's an array of guard functions. Before loading the component, Angular calls each guard. If ANY guard returns false or a redirect, the route is blocked. You can stack multiple guards: `canActivate: [authGuard, adminGuard]`.

---

## 📖 Step 8 — Build the Login Page

### How Reactive Forms work (quick refresher):

Reactive forms have **two parts**:
1. **TypeScript file:** You define the form structure with `FormGroup` and `FormControl`
2. **HTML template:** You bind inputs to the form using `[formGroup]` and `formControlName`

The form controls live in TypeScript — the HTML just **displays** them. This means validation, values, and state are all managed in TypeScript.

```
TypeScript (source of truth):
  form = new FormGroup({
    email: new FormControl('', [Validators.required])
  })

HTML (display):
  <input formControlName="email" />

They are connected by the name "email".
```

---

### 📂 [src/app/features/auth/login/login.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/auth/login/login.ts)

```ts
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  // We use simple boolean flags instead of signals here for simplicity
  loading = false;
  serverError = '';

  // Define the form: two fields, both required
  loginForm = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitLogin() {
    // Don't submit if form is invalid (validation errors exist)
    if (this.loginForm.invalid) return;

    this.loading = true;
    this.serverError = '';

    // Get form values (the ! tells TypeScript "I know these are not null")
    const email = this.loginForm.value.email!;
    const password = this.loginForm.value.password!;

    // Call the AuthService — it returns an Observable
    // .subscribe() is how you "listen" for the result
    this.auth.login(email, password).subscribe({
      next: () => {
        // Success! Navigate to books page
        this.router.navigate(['/books']);
      },
      error: (err) => {
        // Show the error message from the backend
        this.serverError = err.error?.message || 'Login failed';
        this.loading = false;
      },
    });
  }
}
```

---

### 📂 [src/app/features/auth/login/login.html](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/auth/login/login.html)

```html
<div class="d-flex justify-content-center align-items-center" style="min-height: calc(100vh - 60px); background: var(--book-bg)">
  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 440px">
    <h3 class="text-center font-serif mb-1">Welcome Back</h3>
    <p class="text-center text-muted mb-4">Sign in to your account</p>

    <!-- [formGroup] connects this HTML form to the TypeScript FormGroup -->
    <form [formGroup]="loginForm" (ngSubmit)="submitLogin()">

      <!-- EMAIL FIELD -->
      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <!-- formControlName connects this input to loginForm.email -->
        <input class="form-control" type="email" formControlName="email"
               placeholder="you&#64;example.com" />
        <!-- Show error only when field is touched (user clicked away) AND invalid -->
        @if (loginForm.get('email')?.touched && loginForm.get('email')?.invalid) {
          <small class="text-danger">Please enter a valid email</small>
        }
      </div>

      <!-- PASSWORD FIELD -->
      <div class="mb-3">
        <label class="form-label small fw-semibold">Password</label>
        <input class="form-control" type="password" formControlName="password"
               placeholder="Enter your password" />
        @if (loginForm.get('password')?.touched && loginForm.get('password')?.invalid) {
          <small class="text-danger">Password is required</small>
        }
      </div>

      <!-- SERVER ERROR (e.g., "Invalid credentials") -->
      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }

      <!-- SUBMIT BUTTON -->
      <button class="btn btn-book-primary w-100 fw-bold py-2" type="submit" [disabled]="loading">
        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Signing in...
        } @else {
          Sign In
        }
      </button>
    </form>

    <div class="text-center mt-3">
      <small class="text-muted">Don't have an account?
        <a routerLink="/auth/register" class="text-decoration-none" style="color: var(--book-accent)">Register</a>
      </small>
    </div>
  </div>
</div>
```

> **Key Angular concepts used here:**
> - `[formGroup]="loginForm"` — binds the `<form>` to your TypeScript FormGroup
> - `formControlName="email"` — binds the `<input>` to the specific FormControl
> - [(ngSubmit)="submitLogin()"](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.ts#5-15) — calls your method when form is submitted
> - `@if (condition) { ... }` — Angular 21's new control flow syntax (replaces `*ngIf`)
> - `[disabled]="loading"` — property binding: disables the button when `loading` is true
> - `{{ serverError }}` — interpolation: displays the variable's value as text

---

## 📖 Step 9 — Finish the Register Page

You already started the TypeScript with the form! Now you need to:
1. Wire it to `AuthService`
2. Send `dob` instead of `dateOfBirth` (that's what the backend expects)
3. Bind the HTML to the form

---

### 📂 [src/app/features/auth/register/register.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/auth/register/register.ts)

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

  registerForm = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
    // Password: min 8 chars, must have uppercase + lowercase + number
    password: new FormControl('', [
      Validators.required,
      Validators.minLength(8),
      Validators.pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/)
    ]),
    firstName: new FormControl('', [Validators.required, Validators.minLength(2), Validators.maxLength(50)]),
    lastName: new FormControl('', [Validators.required, Validators.minLength(2), Validators.maxLength(50)]),
    dob: new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitRegister() {
    if (this.registerForm.invalid) return;

    this.loading = true;
    this.serverError = '';

    // Spread the form values into the register call
    // The backend expects: { email, password, firstName, lastName, dob }
    const formData = this.registerForm.value;

    this.auth.register({
      email: formData.email!,
      password: formData.password!,
      firstName: formData.firstName!,
      lastName: formData.lastName!,
      dob: formData.dob!,
    }).subscribe({
      next: () => {
        // Success! Go to login page so user can sign in
        this.router.navigate(['/auth/login']);
      },
      error: (err) => {
        this.serverError = err.error?.message || 'Registration failed';
        this.loading = false;
      },
    });
  }
}
```

---

### 📂 [src/app/features/auth/register/register.html](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/auth/register/register.html)

```html
<div class="d-flex justify-content-center align-items-center" style="min-height: calc(100vh - 60px); background: var(--book-bg)">
  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 480px">
    <h3 class="text-center font-serif mb-1">Create Account</h3>
    <p class="text-center text-muted mb-4">Join thousands of book lovers today</p>

    <form [formGroup]="registerForm" (ngSubmit)="submitRegister()">

      <!-- NAME ROW: two fields side by side -->
      <div class="row mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" formControlName="firstName" placeholder="Khaled" />
          @if (registerForm.get('firstName')?.touched && registerForm.get('firstName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
        <div class="col-6">
          <label class="form-label small fw-semibold">Last Name</label>
          <input class="form-control" formControlName="lastName" placeholder="Mohamed" />
          @if (registerForm.get('lastName')?.touched && registerForm.get('lastName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
      </div>

      <!-- EMAIL -->
      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <input class="form-control" type="email" formControlName="email"
               placeholder="you&#64;example.com" />
        @if (registerForm.get('email')?.touched && registerForm.get('email')?.invalid) {
          <small class="text-danger">Please enter a valid email</small>
        }
      </div>

      <!-- DATE OF BIRTH -->
      <div class="mb-3">
        <label class="form-label small fw-semibold">Date of Birth</label>
        <input class="form-control" type="date" formControlName="dob" />
        @if (registerForm.get('dob')?.touched && registerForm.get('dob')?.invalid) {
          <small class="text-danger">Date of birth is required</small>
        }
      </div>

      <!-- PASSWORD -->
      <div class="mb-3">
        <label class="form-label small fw-semibold">Password</label>
        <input class="form-control" type="password" formControlName="password"
               placeholder="Min 8 chars, uppercase + number" />
        @if (registerForm.get('password')?.touched && registerForm.get('password')?.invalid) {
          <small class="text-danger">Min 8 chars with uppercase, lowercase, and a number</small>
        }
      </div>

      <!-- SERVER ERROR -->
      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }

      <!-- SUBMIT -->
      <button class="btn btn-book-primary w-100 fw-bold py-2" type="submit" [disabled]="loading">
        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Creating...
        } @else {
          Create Account
        }
      </button>
    </form>

    <div class="text-center mt-3">
      <small class="text-muted">Already have an account?
        <a routerLink="/auth/login" class="text-decoration-none" style="color: var(--book-accent)">Sign in</a>
      </small>
    </div>
  </div>
</div>
```

> **Why `formControlName="dob"` and not `formControlName="dateOfBirth"`?**
> The `formControlName` must match the key in your FormGroup **exactly**. Your backend expects a field called `dob`. So we name the form control `dob` to keep things consistent.

---

## 📖 Step 10 — Build the Profile Page

The profile page:
1. Reads user info from the JWT token (no API call needed!)
2. Shows a form with firstName, lastName, dob pre-filled
3. Shows email as read-only (backend doesn't allow changing it)
4. On submit, calls `authService.updateProfile()`

---

### 📂 [src/app/features/profile/profile.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/profile/profile.ts)

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
  email = '';

  profileForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    lastName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    dob: new FormControl('', [Validators.required]),
  });

  constructor(private auth: AuthService) {}

  // OnInit runs once when the component loads
  // We use it to pre-fill the form with current user data
  ngOnInit() {
    const user = this.auth.getCurrentUser();
    if (user) {
      this.email = user.email;
      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName: user.lastName,
        dob: user.dob ? user.dob.substring(0, 10) : '', // format: "2000-01-15"
      });
    }
  }

  submitProfile() {
    if (this.profileForm.invalid) return;

    this.loading = true;
    this.successMessage = '';
    this.errorMessage = '';

    this.auth.updateProfile(this.profileForm.value as any).subscribe({
      next: () => {
        this.successMessage = 'Profile updated successfully!';
        this.loading = false;
      },
      error: (err) => {
        this.errorMessage = err.error?.message || 'Update failed';
        this.loading = false;
      },
    });
  }
}
```

> **What is `ngOnInit`?**
> It's a lifecycle hook — a method Angular calls automatically at specific moments. `ngOnInit` runs once, right after the component is created and its inputs are set. It's the right place to load data or set up the form.
>
> **Why not put it in the constructor?**
> The constructor runs before Angular finishes setting up the component. `ngOnInit` runs after everything is ready.

---

### 📂 [src/app/features/profile/profile.html](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/features/profile/profile.html)

```html
<div class="d-flex justify-content-center py-5" style="min-height: calc(100vh - 60px); background: var(--book-bg)">
  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 480px">
    <h3 class="font-serif mb-1">My Profile</h3>
    <p class="text-muted mb-4">Manage your account details</p>

    <!-- Email is read-only — can't be changed -->
    <div class="mb-3">
      <label class="form-label small fw-semibold">Email</label>
      <input class="form-control bg-light" [value]="email" disabled />
      <small class="text-muted">Email cannot be changed</small>
    </div>

    <form [formGroup]="profileForm" (ngSubmit)="submitProfile()">
      <div class="row mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" formControlName="firstName" />
          @if (profileForm.get('firstName')?.touched && profileForm.get('firstName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
        <div class="col-6">
          <label class="form-label small fw-semibold">Last Name</label>
          <input class="form-control" formControlName="lastName" />
          @if (profileForm.get('lastName')?.touched && profileForm.get('lastName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Date of Birth</label>
        <input class="form-control" type="date" formControlName="dob" />
      </div>

      <!-- SUCCESS / ERROR MESSAGES -->
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

## 📖 Step 11 — Build the Not-Found Page

Simple page shown when users navigate to a route that doesn't exist.

### 📂 [src/app/not-found/not-found.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/not-found/not-found.ts)

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

### 📂 [src/app/not-found/not-found.html](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/not-found/not-found.html)

```html
<div class="text-center py-5 fade-in" style="min-height: calc(100vh - 60px)">
  <h1 class="font-serif" style="font-size: 96px; color: var(--book-accent)">404</h1>
  <p class="text-muted mb-4" style="font-size: 18px">Oops! This page doesn't exist</p>
  <a routerLink="/" class="btn btn-book-primary px-4 py-2 fw-bold">
    <i class="fa-solid fa-house me-2"></i>Back to Home
  </a>
</div>
```

---

## 📖 Step 12 — Connect Navbar to AuthService

Right now the Navbar has hardcoded `isLoggedIn = false`. You need to make it read from `AuthService` so it updates dynamically.

### 📂 Update [src/app/shared/navbar/navbar.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/shared/navbar/navbar.ts)

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

  // We store the subscription so we can clean it up when Navbar is destroyed
  // (prevents memory leaks)
  private authSub!: Subscription;

  constructor(private auth: AuthService) {}

  ngOnInit() {
    // Subscribe to auth status changes
    // Every time user logs in/out, this callback runs
    this.authSub = this.auth.authStatus$.subscribe(loggedIn => {
      this.isLoggedIn = loggedIn;
      this.isAdmin = this.auth.isAdmin();
    });
  }

  ngOnDestroy() {
    // Always unsubscribe to prevent memory leaks
    this.authSub?.unsubscribe();
  }

  onLogout() {
    this.auth.logout();
  }
}
```

> **Why `OnDestroy` and `unsubscribe`?**
> When you subscribe to an Observable, it keeps listening forever — even after the component is removed from the page. This causes a **memory leak**. `ngOnDestroy` runs when Angular removes the component, so we use it to clean up.
>
> **The Navbar is in [app.html](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.html) so it's always visible** — it won't actually be destroyed until the user closes the tab. But it's still best practice to unsubscribe.

---

## ✅ Summary Checklist

| #   | Task                                                                                                                                                                                        | Status |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1   | Add missing models (User, Cart, Order, Review, ApiResponse)                                                                                                                                 | 🔲     |
| 2   | Build AuthService                                                                                                                                                                           | 🔲     |
| 3   | Build Token Interceptor                                                                                                                                                                     | 🔲     |
| 4   | Build Error Interceptor                                                                                                                                                                     | 🔲     |
| 5   | Build Auth Guard                                                                                                                                                                            | 🔲     |
| 6   | Build Admin Guard                                                                                                                                                                           | 🔲     |
| 7   | Wire interceptors into [app.config.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.config.ts) | 🔲     |
| 8   | Add guards to [app.routes.ts](file:///home/mkhaled/Desktop/mohamed%20khaled%20/ITI%20open%20source%20applications%20devolpment/Bookstore/bookstore-frontend/src/app/app.routes.ts)          | 🔲     |
| 9   | Build Login Page (TS + HTML)                                                                                                                                                                | 🔲     |
| 10  | Finish Register Page (TS + HTML)                                                                                                                                                            | 🔲     |
| 11  | Build Profile Page (TS + HTML)                                                                                                                                                              | 🔲     |
| 12  | Build Not-Found Page (TS + HTML)                                                                                                                                                            | 🔲     |
| 13  | Connect Navbar to AuthService                                                                                                                                                               | 🔲     |

---

## ⏱️ Suggested Time Breakdown

| Block | Tasks | Estimated Time |
|-------|-------|---------------|
| **Block 1** | Models (Step 1) | 20 min |
| **Block 2** | AuthService (Step 2) | 30 min |
| **Block 3** | Interceptors (Steps 3-4) | 20 min |
| **Block 4** | Guards + Wiring (Steps 5-7) | 20 min |
| **Block 5** | Login Page (Step 8) | 30 min |
| **Block 6** | Register Page (Step 9) | 20 min |
| **Block 7** | Profile + Not-Found + Navbar (Steps 10-12) | 30 min |
| **Block 8** | Testing the full auth flow | 30 min |
| **Total** | | **~3.5 hours** |

---

## 🧪 How to Test When Done

1. `ng serve` — make sure it compiles with no errors
2. Go to `/auth/register` — create an account
3. Go to `/auth/login` — sign in
4. Check Navbar: Cart, Orders, Profile links should now appear
5. Go to `/profile` — should show your name pre-filled
6. Open browser DevTools → Network tab → any API request should have `Authorization: Bearer <token>` header
7. Delete the token from localStorage (DevTools → Application → Local Storage) → refresh → should redirect to login
8. Go to `/asdjkfhsd` → 404 page should show
9. Login as regular user → go to `/admin` → should redirect to home
