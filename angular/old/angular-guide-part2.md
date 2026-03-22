# 📗 Angular Complete Guide — Part 2 of 3
## RxJS Deep Dive + Services + HTTP + Interceptors + Guards
> Written for Khaled | Bookstore Project | Angular 21 Standalone

---

# TABLE OF CONTENTS

1. RxJS — The Full Picture
   - What is reactive programming
   - Observable vs Promise — the fundamental difference
   - Creating Observables
   - Subscribing — next, error, complete
   - The Subscription object
   - Unsubscribing and memory safety
   - Operators and the pipe() function
   - tap() — side effects without transformation
   - map() — transform each value
   - catchError() — intercept errors in the stream
   - throwError() — create an errored Observable
   - switchMap() — cancel and replace
   - takeUntil() — auto-unsubscribe pattern
   - Subject — a manual Observable
   - BehaviorSubject — Observable with current value
   - ReplaySubject and AsyncSubject (brief)
   - asObservable() — expose read-only streams

2. Angular Services — The Complete Guide
   - What a service is and why it exists
   - @Injectable in depth
   - Service architecture patterns
   - Building AuthService step by step with every line explained

3. HttpClient — The Complete Guide
   - Setting up provideHttpClient
   - GET, POST, PUT, PATCH, DELETE
   - Typed responses
   - HTTP headers and params
   - Error handling with HttpErrorResponse
   - Loading states pattern

4. HTTP Interceptors — The Complete Guide
   - What interceptors are
   - The HttpInterceptorFn type signature
   - The request pipeline
   - Cloning requests (why and how)
   - Building the Token Interceptor with every line explained
   - Building the Error Interceptor with every line explained
   - Registering interceptors in app.config.ts

5. Route Guards — The Complete Guide
   - What guards are and how routing works
   - CanActivateFn type
   - Return types: boolean, UrlTree, Observable, Promise
   - Building authGuard with every line explained
   - Building adminGuard with every line explained
   - Wiring guards in app.routes.ts — canActivate, canActivateChild
   - loadComponent — lazy loading explained

---

---

# CHAPTER 1 — RxJS: The Full Picture

## 1.1 What Is Reactive Programming?

Before RxJS, most asynchronous JavaScript code looked like this:

```javascript
// Callback style (old, leads to "callback hell"):
getUser(id, function(user) {
  getPosts(user.id, function(posts) {
    getComments(posts[0].id, function(comments) {
      // By now the nesting is unreadable
    });
  });
});

// Promise style (better, but still limited):
getUser(id)
  .then(user => getPosts(user.id))
  .then(posts => getComments(posts[0].id))
  .then(comments => console.log(comments))
  .catch(err => console.error(err));
```

Promises improved the situation, but they have fundamental limitations:
1. A Promise represents **one single future value** — it resolves once and is done
2. A Promise is **not cancellable** — once started, you can't stop it
3. Promises are not good for **streams of values** (e.g., WebSocket messages, user keystrokes)

**Reactive programming** is a paradigm where you work with **streams of values over time**. RxJS (Reactive Extensions for JavaScript) implements this paradigm.

---

## 1.2 Observable vs Promise — The Fundamental Difference

```
Promise:    —————————————[value]——▶  (emits once, then done)

Observable: ——[v1]——[v2]——[v3]——▶  (can emit multiple values over time)
         OR: ——————————————[v1]——▶  (can emit just once, like a Promise)
         OR: ————————————————————▶  (might never emit — and that's valid too)
         OR: ——[v1]——❌             (can error at any point)
         OR: ——[v1]——[v2]——|       (can complete, meaning "no more values")
```

**The crucial conceptual difference:**

A Promise executes immediately when created:
```typescript
const promise = new Promise(resolve => {
  console.log("This runs immediately!");
  resolve("data");
});
// "This runs immediately!" is logged RIGHT NOW
// Even if nobody is listening for the result
```

An Observable is **lazy** — it doesn't execute until someone subscribes:
```typescript
const observable = new Observable(subscriber => {
  console.log("This only runs when someone subscribes!");
  subscriber.next("data");
});
// Nothing is logged yet
// The function inside hasn't run

observable.subscribe(value => console.log(value));
// NOW "This only runs when someone subscribes!" is logged
// NOW "data" is logged
```

**This matters for HTTP requests:**

```typescript
// In AuthService:
login(email: string, password: string): Observable<any> {
  return this.http.post('/api/auth/login', { email, password });
  // THIS LINE DOES NOT SEND AN HTTP REQUEST
  // It creates an Observable that WILL send a request when subscribed
}

// In Login component:
this.auth.login(email, password).subscribe({
  next: res => { ... }
});
// NOW the HTTP request is sent — because someone subscribed
```

---

## 1.3 Creating Observables

You rarely create Observables from scratch in Angular. You mostly receive them from:
- `HttpClient.get()`, `.post()`, etc.
- `BehaviorSubject.asObservable()`
- Angular Router events
- Form `valueChanges` and `statusChanges`

But understanding how they work internally is important:

```typescript
import { Observable } from 'rxjs';

// Creating an Observable manually:
const myObservable = new Observable<number>(subscriber => {
  // This function runs when someone subscribes

  subscriber.next(1);    // emit value 1
  subscriber.next(2);    // emit value 2
  subscriber.next(3);    // emit value 3
  subscriber.complete(); // signal: no more values will be emitted

  // If something goes wrong:
  // subscriber.error(new Error("something failed"));
  // After error(), complete() is NOT called
});

// Subscribe to it:
myObservable.subscribe({
  next:     value => console.log('Got:', value),
  error:    err   => console.error('Error:', err),
  complete: ()    => console.log('Done!')
});
// Logs: Got: 1 → Got: 2 → Got: 3 → Done!
```

**HttpClient Observables specifically:**

When you call `this.http.get('/api/books')`, Angular's HttpClient creates an Observable that:
1. Sends an HTTP GET request when subscribed
2. Emits ONE value when the response arrives (the parsed JSON body)
3. Then immediately completes

This is why you don't need to call `complete()` manually for HTTP requests — HttpClient handles it.

---

## 1.4 Subscribing — next, error, complete

```typescript
// Full subscribe syntax:
someObservable.subscribe({
  next: (value) => {
    // Called for EACH value the Observable emits
    // For HttpClient: called once with the response data
    // For BehaviorSubject: called immediately with current value, then on each change
    console.log('Received:', value);
  },
  error: (err) => {
    // Called if the Observable errors
    // After this is called, 'complete' will NOT be called
    // err is the error value — for HttpClient it's an HttpErrorResponse
    console.error('Error:', err.status, err.message);
  },
  complete: () => {
    // Called once when the Observable signals it's done emitting
    // HttpClient Observables complete automatically after the response
    // For long-lived Observables (BehaviorSubject), this may never be called
    console.log('Stream completed');
  }
});

// Short form (if you only care about values, not errors or completion):
someObservable.subscribe(value => console.log(value));
// ⚠️ This is risky — errors are silently swallowed
// Always include an error handler in production code
```

---

## 1.5 The Subscription Object — Storing and Unsubscribing

When you call `.subscribe()`, it returns a `Subscription` object:

```typescript
import { Subscription } from 'rxjs';

const sub: Subscription = myObservable.subscribe({
  next: value => console.log(value)
});

// Later, when you want to stop listening:
sub.unsubscribe();
// From this point, the callback will no longer be called
// The Observable may still emit values — you just won't receive them

// Checking if it's already unsubscribed:
console.log(sub.closed); // true after unsubscribe, false while active
```

**Adding subscriptions together:**

```typescript
const mainSub = new Subscription();

mainSub.add(authService.authStatus$.subscribe(...));
mainSub.add(router.events.subscribe(...));
mainSub.add(someOther$.subscribe(...));

// Unsubscribe all at once:
mainSub.unsubscribe(); // all three subscriptions are cancelled
```

---

## 1.6 Operators and the pipe() Function

An **operator** is a function that transforms an Observable into another Observable.

`pipe()` is the method that chains operators together. It takes the output of one operator and feeds it as input to the next.

```typescript
// Without pipe (hypothetical — doesn't actually work like this):
catchError(map(someObservable));

// With pipe (actual syntax):
someObservable.pipe(
  map(value => value * 2),
  filter(value => value > 5),
  catchError(err => of(0))
);
```

Think of `pipe()` as a pipeline of transformations. The data flows through each operator in order:

```
Observable emits value
    → enters pipe()
    → goes through map()
    → goes through filter()
    → goes through catchError() (only if error)
    → reaches subscribe()
```

---

## 1.7 `tap()` — Side Effects Without Transformation

`tap()` lets you "peek" at values flowing through a pipe **without changing them**. The values pass through unchanged.

```typescript
this.http.post('/api/auth/login', { email, password }).pipe(
  tap(res => {
    // Look at the response — but don't change it
    console.log('Login response:', res); // for debugging
    if (res.data?.token) {
      localStorage.setItem('jwt_token', res.data.token); // side effect: save token
    }
  })
  // The response continues downstream UNCHANGED
  // The component that subscribes receives the full response
);
```

**tap() is for side effects.** A side effect is anything that affects state outside the data stream:
- Saving to localStorage
- Logging
- Updating a BehaviorSubject
- Triggering a notification

Without `tap()`, you'd have to subscribe, perform the side effect, then somehow pass the data along. `tap()` handles this cleanly in the pipe.

```typescript
// WITHOUT tap — messy:
login(email: string, password: string) {
  this.http.post('/api/auth/login', { email, password }).subscribe(res => {
    localStorage.setItem('jwt_token', res.data.token); // side effect
    this.navigateToBooks(res); // but how do I pass this to the component?
  });
  // Can't return the Observable anymore — we already subscribed
}

// WITH tap — clean:
login(email: string, password: string): Observable<any> {
  return this.http.post('/api/auth/login', { email, password }).pipe(
    tap(res => {
      localStorage.setItem('jwt_token', res.data.token); // side effect handled here
    })
    // The full response still flows through to the component's subscribe()
  );
}
```

---

## 1.8 `map()` — Transform Each Value

`map()` transforms each value emitted by an Observable.

```typescript
import { map } from 'rxjs/operators';

// Transform the response to only extract the data field:
this.http.get<ApiResponse<Book[]>>('/api/books').pipe(
  map(response => response.data) // transforms: ApiResponse<Book[]> → Book[]
).subscribe(books => {
  this.books = books; // now you directly get the array, not the wrapper
});

// Another example:
someNumbers$.pipe(
  map(n => n * 2)  // 1 → 2, 5 → 10, 3 → 6
);
```

---

## 1.9 `catchError()` — Intercept Errors in the Stream

`catchError()` intercepts an error in the Observable stream and lets you handle it — either by recovering (returning a new Observable) or re-throwing.

```typescript
import { catchError, throwError, of } from 'rxjs';

// Option 1: Handle the error and return a fallback value
this.http.get('/api/books').pipe(
  catchError(err => {
    console.error('Failed to load books:', err);
    return of([]); // of() creates an Observable that emits [] and completes
    // The subscriber receives [] instead of an error — graceful degradation
  })
);

// Option 2: Log and re-throw (what your error interceptor does)
someRequest$.pipe(
  catchError(err => {
    if (err.status === 401) {
      auth.logout(); // handle globally
    }
    return throwError(() => err); // re-throw so component can handle it too
  })
);

// Option 3: Transform the error into something more useful
someRequest$.pipe(
  catchError(err => {
    const userMessage = err.error?.message || 'Something went wrong';
    return throwError(() => new Error(userMessage));
  })
);
```

---

## 1.10 `throwError()` — Create an Errored Observable

`throwError()` creates an Observable that immediately errors when subscribed.

```typescript
import { throwError } from 'rxjs';

// Old syntax (deprecated):
throwError('something went wrong');

// New syntax (Angular 21 — use a factory function):
throwError(() => new Error('something went wrong'));
throwError(() => err); // re-throw an existing error

// Why factory function?
// The factory is lazy — it's only called when someone subscribes
// This prevents creating Error objects that are never used
```

---

## 1.11 `switchMap()` — Cancel and Replace

`switchMap()` is used when you want to make a new Observable from each emitted value, and **cancel any previous pending Observable**.

Common use case: search-as-you-type. Every keystroke triggers a new search request. With `switchMap`, old in-flight requests are cancelled when a new one starts.

```typescript
import { switchMap } from 'rxjs/operators';

// Search example:
this.searchControl.valueChanges.pipe(
  switchMap(query => this.bookService.search(query))
  // If user types fast:
  // types 'c' → starts GET /api/books?q=c
  // types 'cl' → CANCELS the previous request, starts GET /api/books?q=cl
  // types 'cle' → CANCELS again, starts GET /api/books?q=cle
  // Only the last one completes
).subscribe(results => {
  this.results = results;
});
```

You don't use `switchMap` in your current project, but you'll need it soon when the search feature is built.

---

## 1.12 `takeUntil()` — Auto-Unsubscribe Pattern

Instead of manually storing subscriptions and calling `.unsubscribe()` in `ngOnDestroy`, `takeUntil()` lets you auto-unsubscribe when a "stop signal" Observable emits.

```typescript
import { Subject, takeUntil } from 'rxjs';

export class SomeComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>(); // the "stop signal"

  ngOnInit() {
    // Instead of: this.sub = something$.subscribe(...)
    something$.pipe(
      takeUntil(this.destroy$) // auto-unsubscribe when destroy$ emits
    ).subscribe(value => {
      this.data = value;
    });

    // You can have multiple subscriptions — all auto-unsubscribe:
    another$.pipe(takeUntil(this.destroy$)).subscribe(...);
    yetAnother$.pipe(takeUntil(this.destroy$)).subscribe(...);
  }

  ngOnDestroy() {
    this.destroy$.next(); // emit a value → all takeUntil subscriptions unsubscribe
    this.destroy$.complete(); // clean up the Subject itself
  }
}
```

This is cleaner than storing multiple `Subscription` objects when you have many subscriptions in a component.

---

## 1.13 Subject — A Manual Observable

A `Subject` is both an Observable AND an observer. You can both:
- Subscribe to it (receive values): `.subscribe()`
- Push values into it (emit values): `.next()`, `.error()`, `.complete()`

```typescript
import { Subject } from 'rxjs';

const subject = new Subject<string>();

// Subscribe to it:
subject.subscribe(value => console.log('Subscriber 1:', value));
subject.subscribe(value => console.log('Subscriber 2:', value));

// Push values in:
subject.next('hello');
// Logs: "Subscriber 1: hello" AND "Subscriber 2: hello"

subject.next('world');
// Logs: "Subscriber 1: world" AND "Subscriber 2: world"

// Late subscriber — misses previous values:
subject.subscribe(value => console.log('Late:', value));
subject.next('too late');
// Logs: "Subscriber 1: too late" / "Subscriber 2: too late" / "Late: too late"
// The late subscriber only gets values from AFTER they subscribed
```

This "late subscriber misses previous values" problem is why we use `BehaviorSubject` for auth state.

---

## 1.14 BehaviorSubject — Observable with Current Value

`BehaviorSubject` is a `Subject` that:
1. **Always holds a current value** — you must provide an initial value
2. **Immediately gives new subscribers the current value** — they don't miss anything
3. **Emits to all subscribers when `.next()` is called**

```typescript
import { BehaviorSubject } from 'rxjs';

const isLoggedIn$ = new BehaviorSubject<boolean>(false); // initial value: false

// Subscriber A joins:
isLoggedIn$.subscribe(val => console.log('A:', val));
// Immediately logs: "A: false" (gets current value right away)

// Push new value:
isLoggedIn$.next(true);
// Logs: "A: true"

// Subscriber B joins AFTER the value changed:
isLoggedIn$.subscribe(val => console.log('B:', val));
// Immediately logs: "B: true" (gets the CURRENT value, not the initial false)

// Push another value:
isLoggedIn$.next(false);
// Logs: "A: false" AND "B: false"

// Read current value synchronously (without subscribing):
console.log(isLoggedIn$.getValue()); // false
console.log(isLoggedIn$.value);      // false (same thing, property access)
```

**This is exactly what your AuthService needs:**

When the Navbar component initializes (after the user might already be logged in), it subscribes to `authStatus$`. With `BehaviorSubject`, it immediately receives `true` (because the user is already logged in). A plain `Subject` would give it nothing — it would have to wait for the next login/logout event.

---

## 1.15 asObservable() — Exposing Read-Only Streams

In `AuthService`, you have:

```typescript
private loggedIn$ = new BehaviorSubject<boolean>(this.isLoggedIn());
authStatus$ = this.loggedIn$.asObservable();
```

Why expose `authStatus$` instead of `loggedIn$` directly?

`loggedIn$` is a `BehaviorSubject` — it has `.next()`, meaning anyone with access can push new values:

```typescript
// If loggedIn$ was public:
someComponent.auth.loggedIn$.next(true); // ❌ component incorrectly marks user as logged in
// Components should NEVER be able to change auth state directly
```

`.asObservable()` converts the `BehaviorSubject` into a plain `Observable`. A plain Observable has no `.next()` method — it's read-only. Components can subscribe (read) but not push values (write).

```typescript
authStatus$.next(true); // ❌ TypeScript Error: Property 'next' does not exist on type 'Observable<boolean>'
```

This is the principle of **encapsulation** applied to reactive programming.

---

---

# CHAPTER 2 — Angular Services: The Complete Guide

## 2.1 What a Service Is

A service is a class that:
1. Holds shared **logic** (login, logout, fetch books, add to cart)
2. Holds shared **state** (is user logged in? what's in the cart?)
3. Is created **once** by Angular and shared across the whole app (singleton)

Components are for display. Services are for logic and state.

**The Single Responsibility Principle applied:**

```
Login component    → responsible for: rendering the form, showing errors
AuthService        → responsible for: login logic, token management, auth state
BookList component → responsible for: rendering the list, pagination UI
BookService        → responsible for: fetching books from the API
```

If you put login logic in the Login component, the Navbar can't use it. If you put it in a Service, everything can use it.

---

## 2.2 @Injectable in Depth

```typescript
@Injectable({
  providedIn: 'root'
  // Other options:
  // providedIn: 'platform'   — shared across multiple Angular apps on the same page (rare)
  // providedIn: SomeModule   — only available within a specific module (old NgModule pattern)
  // No providedIn at all     — you must manually add to providers[] somewhere
})
export class AuthService {}
```

**What `@Injectable` does mechanically:**

It attaches metadata to the class. Angular's compiler reads this metadata to know:
1. That this class CAN be injected (without `@Injectable`, injecting it might fail)
2. WHERE to register it (root injector, lazy module injector, etc.)
3. What its own dependencies are (so Angular can inject those too)

A service that has NO dependencies could technically work without `@Injectable`. But it's always best practice to add it — future changes might add dependencies, and `@Injectable` is required for `providedIn` to work.

---

## 2.3 Building AuthService — Every Line Explained

```typescript
import { Injectable } from '@angular/core';
// @Injectable decorator — required to mark this class as injectable

import { HttpClient } from '@angular/common/http';
// HttpClient — Angular's HTTP service, injected from Angular's core

import { Router } from '@angular/router';
// Router — Angular's navigation service, allows us to navigate programmatically

import { Observable, tap, BehaviorSubject } from 'rxjs';
// Observable  — the type returned by HTTP methods
// tap         — operator to perform side effects (save token)
// BehaviorSubject — reactive state holder for login status

import { environment } from '../../../environments/environment';
// environment.ts exports: { apiUrl: 'http://localhost:5000/api' }
// Using environment variables means you change the URL in one place
// not scattered throughout your services

@Injectable({ providedIn: 'root' })
// ONE instance for the whole app
// Angular creates this when first injected and reuses it everywhere
export class AuthService {

  private api = `${environment.apiUrl}/auth`;
  // Template literal: combines environment.apiUrl with '/auth'
  // Result: 'http://localhost:5000/api/auth'
  // private: only accessible within AuthService — components can't reach this

  private TOKEN_KEY = 'jwt_token';
  // The localStorage key name — stored as a constant to avoid typos
  // If you change the key name, you change it in ONE place

  private loggedIn$ = new BehaviorSubject<boolean>(this.isLoggedIn());
  // BehaviorSubject<boolean>: holds a boolean, starts with current login state
  // this.isLoggedIn() is called immediately to initialize with the REAL current state
  // Why call isLoggedIn() here instead of just using false?
  //   → If user refreshes the page, the component is recreated but the token is still
  //     in localStorage. We check it immediately so the initial state is correct.
  // private: only AuthService can push new values (encapsulation)

  authStatus$ = this.loggedIn$.asObservable();
  // Convert BehaviorSubject to read-only Observable
  // Components subscribe to this — they can read but NOT push values
  // No type annotation needed — TypeScript infers: Observable<boolean>

  constructor(private http: HttpClient, private router: Router) {}
  // Constructor injection of two dependencies
  // private http: HttpClient → stored as this.http
  // private router: Router   → stored as this.router
  // The constructor body is empty because there's no setup needed here

  // ─── REGISTER ────────────────────────────────────────────────────────────────

  register(data: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    dob: string;
  }): Observable<any> {
    // The parameter type is an inline object type — defines exactly what fields are required
    // Observable<any>: return type — we return an Observable of unknown response shape
    // Better typing: Observable<ApiResponse<{token: string; user: User}>> — but any works for now

    return this.http.post(`${this.api}/register`, data);
    // http.post(url, body) — sends a POST request with the data as the JSON body
    // Returns an Observable that emits when the response arrives
    // We do NOT subscribe here — we return the Observable for the component to subscribe
    // The component decides what to do on success/error (navigate, show message, etc.)
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────────

  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.api}/login`, { email, password }).pipe(
      // .pipe() chains operators on the Observable
      // { email, password } is shorthand for { email: email, password: password }
      // http.post<any> — the <any> generic tells HttpClient what to type the response as

      tap(res => {
        // tap() receives the response data without changing it
        // res is the parsed JSON from the backend:
        //   { success: true, message: "ok", data: { token: "eyJ...", user: {...} } }

        if (res.data?.token) {
          // res.data?.token — optional chaining: safe access if res.data is undefined
          // This condition is true when login succeeds and backend returns a token

          localStorage.setItem(this.TOKEN_KEY, res.data.token);
          // Store the JWT in localStorage under the key 'jwt_token'
          // localStorage persists across browser refreshes (unlike sessionStorage)
          // localStorage is synchronous — no callbacks or promises needed

          this.loggedIn$.next(true);
          // Push the value 'true' to the BehaviorSubject
          // All subscribers (Navbar, etc.) immediately receive 'true'
          // Angular detects the change and re-renders templates that use isLoggedIn
        }
      })
      // The response flows through tap() unchanged — the component still receives the full response
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────

  logout(): void {
    // return type void — this function doesn't return a value

    localStorage.removeItem(this.TOKEN_KEY);
    // Remove the token from localStorage
    // After this line, getToken() returns null, isLoggedIn() returns false

    this.loggedIn$.next(false);
    // Push 'false' to the BehaviorSubject
    // Navbar's subscription receives false → hides Cart/Profile links → re-renders

    this.router.navigate(['/auth/login']);
    // Programmatic navigation — equivalent to user clicking <a routerLink="/auth/login">
    // Takes an array: first element is the path, rest are parameters
    // ['/auth/login'] navigates to http://localhost:4200/auth/login
  }

  // ─── GET TOKEN ───────────────────────────────────────────────────────────────

  getToken(): string | null {
    // Return type: string | null — either the token string or null if not logged in
    return localStorage.getItem(this.TOKEN_KEY);
    // Returns the value if key exists, null if key doesn't exist
  }

  // ─── DECODE TOKEN → GET USER DATA ────────────────────────────────────────────

  getCurrentUser(): any | null {
    // A JWT has 3 parts separated by dots: header.payload.signature
    // Example: eyJhbGci.eyJfaWQiOiIxMjMiLCJlbWFpbCI6InRlc3QifQ.signature
    // The PAYLOAD (middle part) contains the user data, encoded in base64

    const token = this.getToken();
    if (!token) return null;
    // Early return if no token — avoid trying to decode null

    try {
      const payload = token.split('.')[1];
      // split('.') splits 'header.payload.signature' into ['header', 'payload', 'signature']
      // [1] gets the second element: 'payload' (the base64-encoded user data)

      const decoded = atob(payload);
      // atob() is a browser built-in function that decodes base64 to a string
      // Input:  'eyJfaWQiOiIxMjMiLCJlbWFpbCI6InRlc3QifQ'
      // Output: '{"_id":"123","email":"test","role":"user","exp":1234567890}'

      return JSON.parse(decoded);
      // JSON.parse() converts the JSON string to a JavaScript object
      // { _id: "123", email: "test", role: "user", exp: 1234567890, ... }
    } catch {
      return null;
      // catch with no parameter — if anything goes wrong (malformed token, invalid base64),
      // return null instead of crashing
    }
  }

  // ─── CHECK IF LOGGED IN ──────────────────────────────────────────────────────

  isLoggedIn(): boolean {
    try {
      const token = this.getToken();
      if (!token) return false;
      // No token = definitely not logged in

      const { exp } = JSON.parse(atob(token.split('.')[1]));
      // Destructure: pull out only the 'exp' field from the decoded payload
      // exp = the expiry timestamp in UNIX time (seconds since Jan 1, 1970)
      // Example: exp = 1735000000 (some future time)

      return exp * 1000 > Date.now();
      // exp * 1000: convert seconds to milliseconds (JavaScript uses milliseconds)
      // Date.now(): current time in milliseconds
      // If expiry time > now: token is valid → true
      // If expiry time < now: token is expired → false
    } catch {
      return false;
      // If decoding fails for any reason, treat as not logged in
    }
  }

  // ─── IS ADMIN ────────────────────────────────────────────────────────────────

  isAdmin(): boolean {
    return this.getCurrentUser()?.role === 'admin';
    // this.getCurrentUser() — decode and return user object (or null)
    // ?.role              — optional chaining: if null, returns undefined (not crash)
    // === 'admin'         — strict equality check
    // undefined === 'admin' → false (not admin if not logged in)
    // 'user' === 'admin'  → false
    // 'admin' === 'admin' → true
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────────────────────

  updateProfile(data: { firstName?: string; lastName?: string; dob?: string }): Observable<any> {
    // All three fields are optional (the ?)
    // This way you can update just firstName, or just dob, without sending the others

    return this.http.patch(`${this.api}/profile`, data);
    // PATCH (not PUT) — sends only the fields that changed, not the whole object
    // PUT would replace the entire resource
    // PATCH is semantically correct for partial updates
  }
}
```

---

---

# CHAPTER 3 — HttpClient: The Complete Guide

## 3.1 Setting Up provideHttpClient

Before any component or service can use `HttpClient`, it must be provided globally.

```typescript
// app.config.ts
import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withFetch(),
      // withFetch() makes HttpClient use the browser's native fetch() API internally
      // instead of the older XMLHttpRequest (XHR)
      // Benefits of fetch over XHR:
      //   - Better performance (streaming support)
      //   - Better browser compatibility
      //   - Works with Angular SSR (server-side rendering) natively
      //   - Smaller bundle size

      withInterceptors([tokenInterceptor, errorInterceptor])
      // Register interceptors here
      // MUST be inside provideHttpClient() — not as a separate provider
    )
  ]
};
```

---

## 3.2 All HTTP Methods

```typescript
@Injectable({ providedIn: 'root' })
export class BookService {
  private http = inject(HttpClient);
  private api = `${environment.apiUrl}/books`;

  // GET — retrieve data
  getBooks(): Observable<ApiResponse<Book[]>> {
    return this.http.get<ApiResponse<Book[]>>(this.api);
    // The generic <ApiResponse<Book[]>> tells TypeScript what shape to expect
    // HttpClient won't validate this at runtime — it's for TypeScript only
  }

  // GET with URL parameters
  getBookById(id: string): Observable<ApiResponse<Book>> {
    return this.http.get<ApiResponse<Book>>(`${this.api}/${id}`);
  }

  // GET with query parameters
  searchBooks(query: string, page: number): Observable<ApiResponse<Book[]>> {
    return this.http.get<ApiResponse<Book[]>>(this.api, {
      params: {
        search: query,
        page: page.toString(),
        limit: '10'
      }
      // Becomes: GET /api/books?search=angular&page=1&limit=10
    });
  }

  // POST — create new resource
  createBook(book: Partial<Book>): Observable<ApiResponse<Book>> {
    return this.http.post<ApiResponse<Book>>(this.api, book);
    // body (second argument) is automatically serialized to JSON
    // Content-Type: application/json header is added automatically
  }

  // PUT — replace entire resource
  replaceBook(id: string, book: Book): Observable<ApiResponse<Book>> {
    return this.http.put<ApiResponse<Book>>(`${this.api}/${id}`, book);
  }

  // PATCH — partial update
  updateBook(id: string, updates: Partial<Book>): Observable<ApiResponse<Book>> {
    return this.http.patch<ApiResponse<Book>>(`${this.api}/${id}`, updates);
  }

  // DELETE — remove resource
  deleteBook(id: string): Observable<ApiResponse<null>> {
    return this.http.delete<ApiResponse<null>>(`${this.api}/${id}`);
  }
}
```

---

## 3.3 HTTP Headers and Params

```typescript
// Custom headers for a specific request:
this.http.get('/api/data', {
  headers: {
    'Authorization': 'Bearer token',
    'X-Custom-Header': 'value'
  }
});

// Using HttpHeaders object (for dynamic headers):
import { HttpHeaders } from '@angular/common/http';

const headers = new HttpHeaders()
  .set('Authorization', `Bearer ${token}`)
  .set('Content-Type', 'application/json');

this.http.get('/api/data', { headers });

// Query parameters:
import { HttpParams } from '@angular/common/http';

const params = new HttpParams()
  .set('page', '1')
  .set('limit', '10')
  .set('sort', 'title');

this.http.get('/api/books', { params });
// Sends: GET /api/books?page=1&limit=10&sort=title
```

---

## 3.4 HttpErrorResponse — Understanding Error Objects

When an HTTP request fails, the `error` handler receives an `HttpErrorResponse`:

```typescript
import { HttpErrorResponse } from '@angular/common/http';

this.auth.login(email, password).subscribe({
  next: res => { ... },
  error: (err: HttpErrorResponse) => {
    console.log(err.status);        // HTTP status code: 400, 401, 404, 500...
    console.log(err.statusText);    // "Bad Request", "Unauthorized", "Not Found"...
    console.log(err.error);         // The response body (your backend's JSON error)
    console.log(err.error?.message); // Your backend's custom message field
    console.log(err.message);       // Angular's error message (less useful)
    console.log(err.url);           // The URL that failed

    // Typical backend error response:
    // { success: false, message: "Invalid email or password" }
    // So err.error = { success: false, message: "Invalid email or password" }
    // And err.error.message = "Invalid email or password"

    this.serverError = err.error?.message || 'Something went wrong';
  }
});
```

---

---

# CHAPTER 4 — HTTP Interceptors: The Complete Guide

## 4.1 What Is an Interceptor?

An interceptor is middleware that runs for every HTTP request and response. Think of it as a pipe that every HTTP request travels through:

```
Component calls service.getSomething()
    ↓
HttpClient creates the request object
    ↓
[tokenInterceptor runs] → adds Authorization header
    ↓
[errorInterceptor runs] → wraps the response Observable with catchError
    ↓
Request goes to the network
    ↓ (response comes back)
[errorInterceptor] → if error: handle 401/403 → re-throw
    ↓
[tokenInterceptor] → passes through
    ↓
Component's subscribe({ next, error }) receives the result
```

---

## 4.2 The HttpInterceptorFn Type Signature

```typescript
import { HttpInterceptorFn, HttpRequest, HttpHandlerFn, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';

// The full type:
type HttpInterceptorFn = (
  req: HttpRequest<unknown>,  // the outgoing request (immutable)
  next: HttpHandlerFn         // function to pass the request to the next handler
) => Observable<HttpEvent<unknown>>;

// In practice you write it as:
export const myInterceptor: HttpInterceptorFn = (req, next) => {
  // req  = the HTTP request object (read-only)
  // next = a function: call next(req) to pass the request along
  //        returns an Observable<HttpEvent<unknown>> — the response stream

  return next(req); // pass through unchanged
};
```

---

## 4.3 Cloning Requests — Why and How

Angular HTTP requests are **immutable** (frozen after creation). If you try to directly modify a request, you'll get either a TypeScript error or a runtime error.

The reason for immutability: Angular might process the same request object in multiple places. If one interceptor modified it in place, other parts of the system might see the modified version unexpectedly.

The solution: **clone** the request with the modifications you want.

```typescript
// What req.clone() can do:
const modifiedReq = req.clone({
  // Set or replace headers:
  setHeaders: {
    'Authorization': 'Bearer token',
    'X-Request-ID': 'abc123'
  },

  // Append to existing headers:
  headers: req.headers.append('X-Extra', 'value'),

  // Change the URL:
  url: req.url.replace('http://', 'https://'),

  // Change the request body:
  body: { ...req.body, extraField: 'value' },

  // Change the HTTP method:
  method: 'POST',

  // Set query parameters:
  setParams: { page: '1', limit: '10' },
});

return next(modifiedReq); // send the cloned, modified request
```

---

## 4.4 Token Interceptor — Every Line Explained

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
// HttpInterceptorFn: the type for functional interceptors (Angular 15+)

import { inject } from '@angular/core';
// inject(): the DI function — lets us get services without a constructor

import { AuthService } from '../services/auth.service';
// Our AuthService — we need it to get the current token

export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  // This function is called for EVERY HTTP request made by the application
  // req: the outgoing request (read-only)
  // next: function to pass the request to the next interceptor or to the network

  const token = inject(AuthService).getToken();
  // inject(AuthService): get the singleton AuthService instance
  // .getToken(): calls localStorage.getItem('jwt_token') → returns string | null
  // inject() works here because interceptors run in an injection context

  if (!token) return next(req);
  // If there's no token (user not logged in), pass the request unchanged
  // This covers: /api/auth/login, /api/auth/register, /api/books (public)
  // These endpoints don't need authentication — passing them without a header is correct

  const authReq = req.clone({
    setHeaders: {
      Authorization: `Bearer ${token}`
      // Template literal: 'Bearer ' + the token string
      // Format expected by your Express backend: "Authorization: Bearer eyJhbGci..."
      // The space between 'Bearer' and the token is required by the Bearer token standard (RFC 6750)
    }
  });
  // req.clone() creates a NEW request object with the header added
  // authReq is the cloned request — identical to req except for the new header
  // req itself is unchanged (still immutable)

  return next(authReq);
  // Pass the modified request (with token) to the next handler
  // The network sends authReq (with Authorization header) instead of req (without)
  // Everything from this point on uses the token-bearing request
};
```

---

## 4.5 Error Interceptor — Every Line Explained

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
// Same as token interceptor — functional interceptor type

import { inject } from '@angular/core';
// DI function for getting services

import { catchError, throwError } from 'rxjs';
// catchError: RxJS operator — intercepts errors in the Observable stream
// throwError: creates a new Observable that immediately emits an error

import { Router } from '@angular/router';
// Angular's router — needed to programmatically navigate on 403

import { AuthService } from '../services/auth.service';
// Our service — needed to call logout() on 401

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  // Both injected at the start — they're needed in the error handler

  return next(req).pipe(
    // next(req): send the request forward, returns Observable<HttpEvent>
    // .pipe(): chain operators onto the response Observable
    // If the request succeeds, catchError is skipped entirely
    // If the request fails (non-2xx status), catchError intercepts it

    catchError(err => {
      // err is an HttpErrorResponse when HTTP fails
      // err.status: the HTTP status code (401, 403, 404, 500, ...)

      if (err.status === 401) {
        // 401 Unauthorized: the server doesn't recognize the token
        // Causes: token expired, token tampered, token missing
        // Action: force logout — clean up localStorage and redirect to login

        auth.logout();
        // logout() does three things:
        //   1. localStorage.removeItem('jwt_token')
        //   2. loggedIn$.next(false) → Navbar updates
        //   3. router.navigate(['/auth/login']) → redirect to login
      }

      if (err.status === 403) {
        // 403 Forbidden: the server knows who you are but you don't have permission
        // Example: regular user tries to access admin-only endpoint
        // Action: redirect to home (don't logout — the user IS authenticated)

        router.navigate(['/']);
        // Navigate to the home route ('/')
        // Don't logout — being forbidden doesn't mean the token is invalid
      }

      return throwError(() => err);
      // Re-throw the error so it continues down the Observable chain
      // Without this line, the error would be "swallowed" here and the component
      // would receive neither a value nor an error — the subscribe never completes

      // WHY we need to re-throw:
      // The Login component's error handler shows "Invalid credentials" under the form
      // If we swallowed the error here, the Login component would never see it
      // Re-throwing lets BOTH the interceptor AND the component handle the error

      // throwError(() => err): factory function creates a new Observable that errors
      // When this is subscribed to, it immediately calls the error handler
      // () => err: lazy factory — only creates the error when subscribed
    })
  );
};
```

---

## 4.6 Wiring Interceptors in app.config.ts

```typescript
import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
// ApplicationConfig: type for the config object
// provideBrowserGlobalErrorListeners: catches unhandled errors in browser context

import { provideRouter } from '@angular/router';
// provideRouter: sets up Angular's routing system

import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';
// provideHttpClient: registers Angular's HttpClient
// withFetch:         tells HttpClient to use fetch() internally (not XHR)
// withInterceptors:  registers functional interceptors

import { routes } from './app.routes';
// Your route definitions — imported and passed to provideRouter

import { tokenInterceptor } from './core/interceptors/token.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';
// Your interceptor functions — imported to be registered

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    // Catches JavaScript errors that Angular doesn't handle and logs them
    // Prevents silent failures in production

    provideRouter(routes),
    // Sets up routing with your route definitions
    // routes is the array from app.routes.ts

    provideHttpClient(
      withFetch(),
      // Use fetch() instead of XHR
      // Angular apps with SSR require this — and it's generally the better choice

      withInterceptors([tokenInterceptor, errorInterceptor])
      // Register interceptors IN ORDER
      // tokenInterceptor runs first (adds the header before the request goes out)
      // errorInterceptor wraps the response (catches errors coming back)
      //
      // The order also affects RESPONSE flow (reverse order):
      // Response comes back → errorInterceptor handles it → tokenInterceptor passes through
      //
      // If you put errorInterceptor first: it would wrap the request BEFORE tokenInterceptor adds the header
      // But the token header is only needed for the REQUEST path, so order only matters for request-side logic
    ),
    // Note: provideHttpClient() MUST include withInterceptors()
    // If you register interceptors separately (not inside provideHttpClient), they won't run
  ]
};
```

---

---

# CHAPTER 5 — Route Guards: The Complete Guide

## 5.1 What Guards Are and How Routing Works

First, understand the routing pipeline without guards:

```
User navigates to /profile
    ↓
Angular Router looks through app.routes.ts
    ↓
Finds: { path: 'profile', loadComponent: () => import(...) }
    ↓
Loads the Profile component
    ↓
Renders it inside <router-outlet>
```

With a guard:
```
User navigates to /profile
    ↓
Angular Router finds: { path: 'profile', canActivate: [authGuard], loadComponent: ... }
    ↓
Angular calls authGuard()
    ↓
  authGuard returns true  → Angular continues → loads Profile component
  authGuard returns UrlTree → Angular cancels navigation → redirects to UrlTree's path
  authGuard returns false  → Angular cancels navigation silently
```

Guards can also be async — they can return `Observable<boolean>` or `Promise<boolean>`, which Angular awaits before deciding whether to proceed.

---

## 5.2 CanActivateFn — The Guard Type

```typescript
import { CanActivateFn, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree } from '@angular/router';

// Full type signature:
type CanActivateFn = (
  route: ActivatedRouteSnapshot,  // info about the route being activated
  state: RouterStateSnapshot      // the current router state (URL, etc.)
) => boolean | UrlTree | Observable<boolean | UrlTree> | Promise<boolean | UrlTree>;

// In practice:
export const myGuard: CanActivateFn = (route, state) => {
  // route.params — URL parameters: for /books/:id, route.params['id']
  // route.queryParams — query string: for /books?page=2, route.queryParams['page']
  // state.url — the URL being navigated to: '/profile'

  return true; // or false, or UrlTree, or Observable/Promise of those
};

// If you don't need route/state, you can omit the parameters:
export const simpleGuard: CanActivateFn = () => {
  return inject(AuthService).isLoggedIn();
};
```

---

## 5.3 authGuard — Every Line Explained

```typescript
import { inject } from '@angular/core';
// inject(): DI function — gets services in a functional context

import { CanActivateFn, Router } from '@angular/router';
// CanActivateFn: the type that Angular expects for a guard
// Router: needed for createUrlTree() — creating redirect instructions

import { AuthService } from '../services/auth.service';
// Our AuthService — needed to check isLoggedIn()

export const authGuard: CanActivateFn = () => {
// CanActivateFn signature: (route, state) => boolean | UrlTree | ...
// We don't use route or state, so we omit the parameters entirely (TypeScript allows this)

  const auth = inject(AuthService);
  // Get the AuthService singleton
  // inject() works here because guards run in Angular's injection context

  if (auth.isLoggedIn()) {
    return true;
    // Return true: Angular proceeds with the navigation
    // The Profile/Cart/Orders component will load normally
  }

  return inject(Router).createUrlTree(['/auth/login']);
  // The user is NOT logged in — block the navigation and redirect instead

  // inject(Router): get the Router service
  // .createUrlTree(['/auth/login']): create a UrlTree representing the path '/auth/login'
  //   UrlTree is NOT a string — it's an Angular router instruction object
  //   It encodes a path, query params, fragment, etc.
  //   ['/auth/login'] means: absolute path to /auth/login (the leading / means absolute)

  // WHY createUrlTree() instead of router.navigate()?
  //   A guard must RETURN something Angular can act on synchronously
  //   router.navigate() returns a Promise<boolean> — Angular can't use that as a redirect
  //   createUrlTree() returns a UrlTree object — Angular understands this directly
  //   Angular sees the UrlTree and performs the redirect as part of the navigation cycle
};
```

---

## 5.4 adminGuard — Every Line Explained

```typescript
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  // Get the AuthService singleton (same instance as everywhere else)

  if (auth.isLoggedIn() && auth.isAdmin()) {
    // TWO conditions must both be true:
    // 1. auth.isLoggedIn(): token exists AND is not expired
    // 2. auth.isAdmin(): decoded token has role === 'admin'
    //
    // Why check isLoggedIn() when isAdmin() already checks the token?
    // If the user is not logged in, getCurrentUser() returns null
    // null?.role === 'admin' → false (safe due to optional chaining)
    // So technically isAdmin() alone would work — but isLoggedIn() && isAdmin()
    // is more explicit and readable: "is logged in AND is admin"

    return true;
    // Both conditions met — allow navigation to /admin
  }

  return inject(Router).createUrlTree(['/']);
  // User is either not logged in OR is logged in but not admin
  // In either case: redirect to home ('/')
  //
  // Note: we redirect to '/' (home) not '/auth/login' because:
  // If the user IS logged in but just not an admin, sending them to login is wrong
  // They're already logged in — home is the appropriate destination
  // If the user is NOT logged in, adminGuard redirects to '/' which then
  // the home route might redirect through authGuard if protected
  // In your project home (/books) is public so they just see the books page
};
```

---

## 5.5 app.routes.ts — Every Property Explained

```typescript
import { Routes } from '@angular/router';
// Routes: TypeScript type for the route array — ensures correct structure

import { NotFound } from './not-found/not-found';
// Direct import (not lazy) because ** route needs to be always available

import { authGuard } from './core/guards/auth.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  {
    path: '',
    // path: '' matches the root URL (http://localhost:4200/)
    redirectTo: 'books',
    // Instead of loading a component, redirect to '/books'
    pathMatch: 'full',
    // 'full': only redirect if the ENTIRE URL is '' (not if it's just a prefix)
    // Without 'full': '' would match EVERYTHING (every URL starts with '')
    // causing infinite redirect loops
  },

  {
    path: 'auth',
    // path: 'auth' matches /auth
    // No component here — this is a parent route that just groups children
    children: [
      // Children inherit the parent path: 'auth/login', 'auth/register'
      {
        path: 'login',
        loadComponent: () => import('./features/auth/login/login').then(c => c.Login),
        // loadComponent: lazy loading — only download Login's code when user navigates here
        // () => import(): dynamic import — returns a Promise<module>
        // .then(c => c.Login): extract the Login named export from the module
        // c is the entire module object — c.Login is the component class
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
    // No guard — books are publicly visible
  },

  {
    path: 'authors',
    loadComponent: () => import('./features/authors/author-list/author-list').then(c => c.AuthorList),
    // Also public
  },

  {
    path: 'cart',
    loadComponent: () => import('./features/cart/cart').then(c => c.Cart),
    canActivate: [authGuard],
    // canActivate: array of guard functions to run before activating this route
    // ALL guards in the array must return true — if any return false/UrlTree, navigation is blocked
    // You could have: canActivate: [authGuard, someOtherGuard]
    // Both would need to pass for the route to activate
  },

  {
    path: 'orders',
    canActivate: [authGuard],
    // Guard on the PARENT route — protects ALL children automatically
    // Both /orders and /orders/checkout require login
    children: [
      {
        path: '',
        // path: '' inside children matches /orders (the parent path with nothing after)
        loadComponent: () => import('./features/orders/order-history/order-history').then(c => c.OrderHistory),
      },
      {
        path: 'checkout',
        // Matches /orders/checkout
        loadComponent: () => import('./features/orders/checkout/checkout').then(c => c.Checkout),
      },
    ],
  },

  {
    path: 'profile',
    loadComponent: () => import('./features/profile/profile').then(c => c.Profile),
    canActivate: [authGuard],
  },

  {
    path: 'admin',
    loadComponent: () => import('./features/admin/admin').then(c => c.Admin),
    canActivate: [adminGuard],
    // adminGuard checks BOTH login AND admin role
    // Regular users who are logged in → redirected to home
    // Not logged in users → redirected to home (adminGuard redirects to '/', not login)
  },

  {
    path: '**',
    // ** is a wildcard — matches ANYTHING not matched by the routes above
    // MUST be the LAST route — routes are checked in ORDER, top to bottom
    // If ** was first, it would match everything and nothing else would ever match
    component: NotFound,
    // Note: component (not loadComponent) — 404 doesn't benefit from lazy loading
    // It's a tiny component and might be needed in low-bandwidth situations
  },
];
```

---

## 5.6 Understanding loadComponent — Lazy Loading Explained

Without lazy loading (eager loading):

```typescript
// app.ts (or app.module.ts old way)
import { BookList } from './features/books/book-list/book-list';
import { Login } from './features/auth/login/login';
import { Register } from './features/auth/register/register';
import { Profile } from './features/profile/profile';
import { Cart } from './features/cart/cart';
// ... all components imported at the top

// When the user first opens your app, ALL of this code is downloaded
// Even if they only ever look at the books page and never log in
// Large initial bundle = slow first load
```

With lazy loading (`loadComponent`):

```typescript
// Only one tiny routes.ts file is downloaded initially
// Component code is downloaded ON DEMAND when the route is first visited:

// User visits /books → BookList code downloads
// User visits /auth/login → Login code downloads
// User never visits /cart → Cart code is NEVER downloaded
```

**How `() => import().then()` works:**

```typescript
loadComponent: () => import('./features/auth/login/login').then(c => c.Login)

// Step by step:
// 1. () => ... creates a function (the "loader function")
//    Angular calls this function when the route is first activated
//
// 2. import('./features/auth/login/login')
//    Dynamic import — downloads the module file and returns a Promise
//    The Promise resolves to the module object: { Login: [class Login], ... }
//
// 3. .then(c => c.Login)
//    c is the module object
//    c.Login is the Login class (the named export from login.ts)
//    We extract and return just the class
//
// Angular receives the Login class and renders it
```

---

---

# Quick Reference Card — RxJS + Services + HTTP

## RxJS Quick Reference

```typescript
// Observable — async data stream
const obs$ = this.http.get('/api/data');
// Nothing happens until .subscribe() is called

// Subscribe
obs$.subscribe({
  next: value => { },    // receives each emitted value
  error: err => { },     // receives errors
  complete: () => { },   // called when stream ends
});

// Unsubscribe
const sub = obs$.subscribe(...);
sub.unsubscribe();  // stop listening

// pipe() — chain operators
obs$.pipe(
  tap(val => console.log(val)),         // side effect — doesn't change value
  map(val => val.data),                 // transform each value
  catchError(err => throwError(() => err)) // handle errors
).subscribe(...);

// BehaviorSubject — Observable with current value
const state$ = new BehaviorSubject<boolean>(false); // initial value: false
state$.next(true);           // push new value — all subscribers notified
state$.getValue();           // read current value synchronously
state$.asObservable();       // read-only Observable (no .next() method)
```

## HTTP Quick Reference

```typescript
// GET
this.http.get<ResponseType>('/api/resource')
this.http.get('/api/resource', { params: { page: '1' } })

// POST
this.http.post<ResponseType>('/api/resource', bodyObject)

// PATCH (partial update)
this.http.patch<ResponseType>('/api/resource/id', changesObject)

// PUT (full replacement)
this.http.put<ResponseType>('/api/resource/id', fullObject)

// DELETE
this.http.delete<ResponseType>('/api/resource/id')

// Error handling in subscribe:
.subscribe({
  error: (err: HttpErrorResponse) => {
    err.status       // 400, 401, 404, 500...
    err.error        // response body (your backend's JSON)
    err.error?.message // your backend's message field
  }
})
```

## Guard Quick Reference

```typescript
// Auth guard — must be logged in
export const authGuard: CanActivateFn = () => {
  return inject(AuthService).isLoggedIn()
    ? true
    : inject(Router).createUrlTree(['/auth/login']);
};

// Admin guard — must be admin
export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  return (auth.isLoggedIn() && auth.isAdmin())
    ? true
    : inject(Router).createUrlTree(['/']);
};

// In routes:
{ path: 'profile', canActivate: [authGuard], loadComponent: () => ... }
```

---

*End of Part 2. Both files are saved. Part 3 covers Reactive Forms Deep Dive + All Pages + Navbar + Testing.*
