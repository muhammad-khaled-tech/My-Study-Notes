# 📔 Angular Complete Guide — Part 7 of 9
## HTTP Advanced + Performance

---

# CHAPTER 1 — HTTP Advanced

## 1.1 Interceptor Chaining — Order Matters

When you register `withInterceptors([a, b, c])`, they form a chain:

```
Request  (outgoing): a → b → c → network
Response (incoming): c → b → a → component
```

```typescript
// Registered as: withInterceptors([tokenInterceptor, errorInterceptor])

// Request path:
//   tokenInterceptor: adds Authorization header
//   → errorInterceptor: passes through
//   → network

// Response path (success):
//   network responds
//   → errorInterceptor: no error, passes through
//   → tokenInterceptor: passes through
//   → component.subscribe() receives data

// Response path (401 error):
//   network returns 401
//   → errorInterceptor: catches error, calls auth.logout(), re-throws
//   → tokenInterceptor: passes error through
//   → component.subscribe() error handler runs
```

**Adding a third interceptor — loading bar:**

```typescript
// The loadingInterceptor should be FIRST (outermost)
// so it tracks ALL requests regardless of what happens inside

withInterceptors([loadingInterceptor, tokenInterceptor, errorInterceptor])

// Request:  loading.show() → add token → network
// Response: network → handle errors → hide loading
```

---

## 1.2 Retry Logic

```typescript
import { retry, timer } from 'rxjs';
import { HttpErrorResponse } from '@angular/common/http';

// Simple retry — 3 attempts, no delay:
this.http.get('/api/books').pipe(
  retry(3)
)

// Retry with delay:
this.http.get('/api/books').pipe(
  retry({ count: 3, delay: 1000 })
)

// Exponential backoff — smarter retry:
this.http.get('/api/books').pipe(
  retry({
    count: 3,
    delay: (error: HttpErrorResponse, retryCount: number) => {
      // Don't retry client errors (4xx) — they won't change on retry
      if (error.status >= 400 && error.status < 500) throw error;

      // Retry server errors (5xx) and network errors with growing delay:
      // retry 1 → wait 1s, retry 2 → wait 2s, retry 3 → wait 3s
      return timer(retryCount * 1000);
    }
  })
)
```

---

## 1.3 Caching — shareReplay

`shareReplay(1)` caches the last emission of an Observable. Subsequent subscribers get the cached value without triggering a new request.

```typescript
@Injectable({ providedIn: 'root' })
export class CategoryService {
  private http = inject(HttpClient);

  // The Observable is created ONCE and cached:
  private categories$ = this.http
    .get<ApiResponse<Category[]>>(`${environment.apiUrl}/categories`)
    .pipe(
      map(res => res.data),
      shareReplay(1)
      // First subscriber → HTTP fires → response cached
      // Second subscriber → gets cached response immediately (no HTTP)
      // Works even after the first subscriber unsubscribed
    );

  getCategories(): Observable<Category[]> {
    return this.categories$; // always the same Observable
  }
}
```

**Cache with time-based expiry:**

```typescript
@Injectable({ providedIn: 'root' })
export class BookService {
  private cache$: Observable<Book[]> | null = null;
  private cacheTimestamp: number | null = null;
  private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  getBooks(): Observable<Book[]> {
    const isExpired = !this.cacheTimestamp ||
      Date.now() - this.cacheTimestamp > this.CACHE_TTL;

    if (!this.cache$ || isExpired) {
      this.cacheTimestamp = Date.now();
      this.cache$ = this.http.get<ApiResponse<Book[]>>(this.api).pipe(
        map(res => res.data),
        shareReplay(1)
      );
    }

    return this.cache$;
  }

  invalidateCache(): void {
    this.cache$ = null;
    this.cacheTimestamp = null;
  }
}
```

---

## 1.4 Global Loading Indicator

```typescript
// loading.service.ts
@Injectable({ providedIn: 'root' })
export class LoadingService {
  private activeRequests = 0;
  private isLoading$ = new BehaviorSubject<boolean>(false);
  readonly loading$ = this.isLoading$.asObservable();

  show(): void {
    this.activeRequests++;
    this.isLoading$.next(true);
  }

  hide(): void {
    this.activeRequests = Math.max(0, this.activeRequests - 1);
    if (this.activeRequests === 0) {
      this.isLoading$.next(false);
    }
    // Only hide when ALL concurrent requests have finished
  }
}

// loading.interceptor.ts
import { finalize } from 'rxjs/operators';

export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const loading = inject(LoadingService);
  loading.show();

  return next(req).pipe(
    finalize(() => loading.hide())
    // finalize: runs on complete OR error — guaranteed cleanup
  );
};

// loading-bar.ts — the visual component
@Component({
  selector: 'app-loading-bar',
  standalone: true,
  imports: [AsyncPipe],
  template: `
    @if (loading.loading$ | async) {
      <div class="loading-bar">
        <div class="progress-line"></div>
      </div>
    }
  `,
  styles: [`
    .loading-bar {
      position: fixed; top: 0; left: 0;
      width: 100%; height: 3px; z-index: 9999;
    }
    .progress-line {
      height: 100%;
      background: var(--book-accent);
      animation: slide 1.2s infinite ease-in-out;
    }
    @keyframes slide {
      0%   { transform: translateX(-100%) scaleX(0.3); }
      50%  { transform: translateX(0)     scaleX(0.7); }
      100% { transform: translateX(100%)  scaleX(0.3); }
    }
  `]
})
export class LoadingBar {
  loading = inject(LoadingService);
}
```

```html
<!-- app.html — put before navbar: -->
<app-loading-bar></app-loading-bar>
<app-navbar></app-navbar>
<router-outlet></router-outlet>
```

---

## 1.5 Request Cancellation with switchMap

Every keystroke in a search box shouldn't create an uncancellable HTTP request. `switchMap` cancels the previous request when a new one starts.

```typescript
@Component({ standalone: true, imports: [ReactiveFormsModule], ... })
export class BookSearch implements OnInit {
  searchControl = new FormControl('');
  results = signal<Book[]>([]);
  private bookService = inject(BookService);

  ngOnInit() {
    this.searchControl.valueChanges.pipe(
      debounceTime(300),
      // Wait 300ms after user stops typing before calling API

      distinctUntilChanged(),
      // Don't search if query didn't change (e.g. user typed then deleted same char)

      switchMap(query => {
        if (!query || query.trim().length < 2) return of([]);
        // Don't search for empty or single character

        return this.bookService.search(query.trim()).pipe(
          map(res => res.data),
          catchError(() => of([]))
          // If search fails, show empty results (don't crash)
        );
        // switchMap CANCELS the previous search Observable when new query arrives
        // User types 'ang' → GET /api/books?q=ang starts
        // User types 'angu' → previous request cancelled, GET /api/books?q=angu starts
        // Only the last request reaches results
      })
    ).subscribe(books => this.results.set(books));
  }
}
```

---

## 1.6 File Upload

```typescript
// book.service.ts
uploadCoverImage(bookId: string, file: File): Observable<ApiResponse<Book>> {
  const formData = new FormData();
  formData.append('coverImage', file, file.name);
  // DO NOT manually set Content-Type — HttpClient sets it automatically
  // with the required boundary: multipart/form-data; boundary=---XYZ

  return this.http.patch<ApiResponse<Book>>(
    `${this.api}/${bookId}/cover`, formData
  );
}

// Component:
onFileSelected(event: Event): void {
  const file = (event.target as HTMLInputElement).files?.[0];
  if (!file) return;

  if (!file.type.startsWith('image/')) {
    this.error.set('Only image files are allowed');
    return;
  }
  if (file.size > 5 * 1024 * 1024) {
    this.error.set('File must be under 5MB');
    return;
  }

  this.bookService.uploadCoverImage(this.bookId, file).subscribe({
    next: res => this.book.set(res.data),
    error: err => this.error.set(err.error?.message)
  });
}
```

```html
<label class="btn btn-outline-secondary btn-sm">
  📷 Change Cover
  <input type="file" accept="image/*" hidden (change)="onFileSelected($event)" />
</label>
```

---

---

# CHAPTER 2 — Performance

## 2.1 ChangeDetectionStrategy.OnPush

Default Angular re-checks ALL components on every event (click, HTTP, timer). For 50 book cards that means 50 unnecessary checks every click.

**OnPush** — only re-check this component when:
1. A reference-type `@Input()` changes (new object/array reference)
2. An event originates FROM this component
3. An Observable emits via `async` pipe
4. `markForCheck()` is called manually

```typescript
@Component({
  selector: 'app-book-card',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './book-card.html',
})
export class BookCard {
  @Input({ required: true }) book!: Book;
  // Parent must pass a new Book object reference to trigger re-render
  // Mutating book.price in parent will NOT trigger re-render — must create new object
}

// In parent — always use immutable updates with OnPush children:
// ❌ this.books[0].price = 29;           // mutates in place — no re-render
// ✅ this.books = this.books.map((b, i) => i === 0 ? {...b, price: 29} : b);
```

**With async pipe — markForCheck is automatic:**

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `@for (book of books$ | async; track book._id) { ... }`
})
export class BookList {
  books$ = this.bookService.getBooks().pipe(map(r => r.data));
  // async pipe subscribes and calls markForCheck() automatically when Observable emits
  // No manual markForCheck() needed
}
```

**With signals — also automatic:**

```typescript
@Component({ changeDetection: ChangeDetectionStrategy.OnPush })
export class BookList {
  books = toSignal(this.bookService.getBooks().pipe(map(r => r.data)), { initialValue: [] });
  // Signals work perfectly with OnPush — Angular tracks signal reads in templates
}
```

---

## 2.2 track in @for — DOM Reuse

Without good tracking, Angular destroys and recreates DOM nodes on every list update.

```html
<!-- Bad — track by reference (default if you write track item): -->
@for (book of books; track book) {
  <app-book-card [book]="book"></app-book-card>
}
<!-- If books array is replaced from API (all new object references):
     Angular thinks ALL items are new → destroys all 12 BookCard nodes → creates 12 new ones
     24 DOM operations for what might be zero actual changes -->

<!-- Good — track by unique ID: -->
@for (book of books; track book._id) {
  <app-book-card [book]="book"></app-book-card>
}
<!-- Angular matches by ID → same IDs = reuse existing DOM nodes → only update @Input
     For 12 books with 1 price change: 1 @Input update instead of 24 DOM operations -->
```

---

## 2.3 @defer Blocks — Template-Level Lazy Loading

`@defer` splits the template into pieces that load on demand, reducing initial bundle size.

```html
<!-- Book detail page — load reviews only when visible: -->
<div class="container py-5">

  <!-- Critical content — loads immediately: -->
  <h2 class="font-serif">{{ book()?.title }}</h2>
  <p>{{ book()?.description }}</p>

  <!-- Non-critical — deferred: -->
  @defer (on viewport; prefetch on idle) {
    <!-- Component JS downloads when browser is idle (prefetch)
         Component RENDERS when scrolled into view (on viewport) -->
    <app-book-reviews [bookId]="book()?._id ?? ''"></app-book-reviews>

  } @placeholder {
    <!-- Shown before trigger condition is met: -->
    <div class="text-muted mt-4 p-3 border rounded">
      Scroll down to see reader reviews
    </div>

  } @loading (minimum 300ms) {
    <!-- Shown while JS is downloading: -->
    <div class="text-center mt-4">
      <div class="spinner-border" style="color:var(--book-accent)"></div>
    </div>

  } @error {
    <!-- Shown if JS download fails: -->
    <p class="text-danger mt-4">Could not load reviews. Please refresh.</p>
  }
</div>
```

**All @defer triggers:**

```html
@defer (on viewport)          <!-- when element enters viewport -->
@defer (on idle)              <!-- when browser is not busy -->
@defer (on interaction)       <!-- on click, hover, or focus -->
@defer (on timer(3s))         <!-- after 3 second delay -->
@defer (when isLoggedIn())    <!-- when signal/expression becomes truthy -->
@defer (on viewport; prefetch on idle) <!-- different trigger for show vs prefetch -->
```

---

## 2.4 Preloading Strategies

```typescript
// app.config.ts — preload ALL route chunks in background after initial load:
import { PreloadAllModules, withPreloading } from '@angular/router';

provideRouter(routes, withPreloading(PreloadAllModules))
// Initial load: fast (only main bundle)
// After page loads: all chunks download quietly in background
// Navigation: instant (chunks already cached)

// Selective preloading — only preload marked routes:
export class SelectivePreloadStrategy implements PreloadingStrategy {
  preload(route: Route, fn: () => Observable<any>): Observable<any> {
    return route.data?.['preload'] ? fn() : of(null);
  }
}

// In routes:
{ path: 'books', loadComponent: ..., data: { preload: true } }
{ path: 'admin', loadComponent: ... } // not preloaded — rarely visited
```

---

## 2.5 Virtual Scrolling for Large Lists

```typescript
import { ScrollingModule } from '@angular/cdk/scrolling';

@Component({
  standalone: true,
  imports: [ScrollingModule],
  template: `
    <cdk-virtual-scroll-viewport
      itemSize="220"
      style="height: 80vh; width: 100%">
      <!-- itemSize: each item's height in px (must be uniform) -->

      <div *cdkVirtualFor="let book of allBooks; trackBy: trackByBook"
           class="p-2">
        <app-book-card [book]="book"></app-book-card>
      </div>
      <!-- Only ~5-10 items rendered in DOM at any time
           Even with 10,000 books, performance is constant -->
    </cdk-virtual-scroll-viewport>
  `
})
export class VirtualBookList {
  allBooks: Book[] = []; // could be thousands

  trackByBook(_: number, book: Book) {
    return book._id;
  }
}
```

---

# Quick Reference — HTTP Advanced + Performance

```typescript
// Retry:
.pipe(retry({ count: 3, delay: (err, n) => timer(n * 1000) }))

// Cache:
private books$ = this.http.get(...).pipe(shareReplay(1));

// Cancel old on new:
valueChanges.pipe(debounceTime(300), switchMap(q => service.search(q)))

// Loading interceptor:
export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  loadingService.show();
  return next(req).pipe(finalize(() => loadingService.hide()));
};

// OnPush:
@Component({ changeDetection: ChangeDetectionStrategy.OnPush })

// Track:
@for (item of items; track item._id) { }

// Defer:
@defer (on viewport) { <heavy></heavy> } @loading { <spinner></spinner> }

// Preload all:
provideRouter(routes, withPreloading(PreloadAllModules))
```

*End of Part 7. Part 8: Testing with Jasmine and TestBed.*

---

# CHAPTER 3 — HTTP Patterns Deep Dive

## 3.1 The Full Interceptor Chain — Execution Order Walkthrough

Let's trace a real request through all three interceptors to make the order concrete.

```typescript
// Registered: withInterceptors([loadingInterceptor, tokenInterceptor, errorInterceptor])

// ─── When BookList calls: this.http.get('/api/books') ────────────────────────

// OUTGOING REQUEST PATH (top to bottom):

// 1. loadingInterceptor runs first:
export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  loadingService.show(); // ← increment counter, show bar
  return next(req).pipe( // passes req to tokenInterceptor
    finalize(() => loadingService.hide())
  );
};

// 2. tokenInterceptor runs second:
export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken(); // 'eyJ...'
  if (!token) return next(req);
  const authReq = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  return next(authReq); // passes req WITH header to errorInterceptor
};

// 3. errorInterceptor runs third:
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe( // passes req to network
    catchError(err => {
      if (err.status === 401) auth.logout();
      if (err.status === 403) router.navigate(['/']);
      return throwError(() => err);
    })
  );
};

// 4. Network sends the request (with Authorization header)

// ─── INCOMING RESPONSE PATH (bottom to top):

// errorInterceptor's pipe runs first on the response:
//   → No error → catchError skipped → response passes through

// tokenInterceptor's next() resolves:
//   → No response-side logic → response passes through

// loadingInterceptor's finalize runs:
//   → loadingService.hide() ← decrement counter, hide bar

// 5. BookList.subscribe(next:...) receives the data
```

---

## 3.2 Handling Multiple Concurrent Requests Correctly

The loading counter pattern handles overlapping requests gracefully:

```
Timeline:
t=0ms   → BooksRequest starts   → count=1, bar shows
t=50ms  → ProfileRequest starts → count=2, bar still showing
t=200ms → BooksRequest ends     → count=1, bar still showing (count > 0)
t=350ms → ProfileRequest ends   → count=0, bar hides
```

Without the counter (naive boolean approach):
```typescript
// WRONG — naive boolean:
show() { this.isLoading$.next(true); }
hide() { this.isLoading$.next(false); } // hides even if another request is still running!

// BooksRequest ends at 200ms → isLoading = false → bar hides prematurely
// ProfileRequest is still running but the bar is gone
```

```typescript
// CORRECT — reference counting:
show() {
  this.activeRequests++;
  this.isLoading$.next(true);
}
hide() {
  this.activeRequests = Math.max(0, this.activeRequests - 1);
  // Math.max(0,...): safety guard — never go below 0
  // Can happen if: component subscribes but interceptor runs hide() after component destroys
  if (this.activeRequests === 0) {
    this.isLoading$.next(false);
    // Only hide when ALL requests finished
  }
}
```

---

## 3.3 Skipping the Loading Indicator for Silent Requests

Some requests should be invisible to the user — background refreshes, polling, analytics. You can skip the loading indicator using a custom HTTP header as a flag.

```typescript
// In the service making a "silent" request:
getSuggestionsQuietly(): Observable<Book[]> {
  return this.http.get<ApiResponse<Book[]>>('/api/books/suggestions', {
    headers: { 'X-Skip-Loading': 'true' }
    // Custom header — your interceptor checks for this
  }).pipe(map(res => res.data));
}

// In loading.interceptor.ts:
export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const skipLoading = req.headers.has('X-Skip-Loading');

  if (skipLoading) {
    // Clone the request WITHOUT the custom header (don't leak it to the backend)
    const cleanReq = req.clone({ headers: req.headers.delete('X-Skip-Loading') });
    return next(cleanReq); // pass through without show/hide
  }

  const loading = inject(LoadingService);
  loading.show();
  return next(req).pipe(finalize(() => loading.hide()));
};
```

---

## 3.4 HTTP Error Handling Patterns

Different error types need different handling strategies:

```typescript
import { HttpErrorResponse } from '@angular/common/http';

// Pattern 1 — In component: show user-friendly message
this.bookService.getBooks().subscribe({
  error: (err: HttpErrorResponse) => {
    switch (err.status) {
      case 0:
        this.error.set('No internet connection. Please check your network.');
        // status 0: network error (no internet, CORS issue, server unreachable)
        break;
      case 404:
        this.error.set('Books not found. Please try again later.');
        break;
      case 500:
        this.error.set('Server error. Our team has been notified.');
        break;
      default:
        this.error.set(err.error?.message || 'Something went wrong.');
    }
  }
});

// Pattern 2 — In interceptor: handle globally, re-throw for component
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      // Handle globally (auth, routing):
      if (err.status === 401) inject(AuthService).logout();
      if (err.status === 403) inject(Router).navigate(['/']);

      // Log to monitoring service (e.g. Sentry):
      // inject(MonitoringService).logError(err);

      // Re-throw with a cleaned-up error message:
      const cleanError = {
        ...err,
        userMessage: err.error?.message || getDefaultMessage(err.status)
      };
      return throwError(() => cleanError);
      // Component receives cleanError.userMessage — no need to map error in component
    })
  );
};

function getDefaultMessage(status: number): string {
  const messages: Record<number, string> = {
    0:   'Network error — check your connection',
    400: 'Invalid request',
    401: 'Session expired — please sign in again',
    403: 'You don\'t have permission to do that',
    404: 'Not found',
    500: 'Server error — please try again later',
  };
  return messages[status] || 'An unexpected error occurred';
}
```

---

## 3.5 Polling — Periodic Background Requests

For real-time-ish data that doesn't justify WebSockets:

```typescript
import { interval, switchMap } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

@Component({ ... })
export class OrderStatus implements OnInit {
  private destroyRef = inject(DestroyRef);
  order = signal<Order | null>(null);

  ngOnInit() {
    const orderId = this.route.snapshot.paramMap.get('id')!;

    interval(10_000).pipe(
      // interval(10000): emits 0, 1, 2, 3... every 10 seconds
      switchMap(() => this.orderService.getOrder(orderId)),
      // switchMap: on every tick, fetch fresh order data
      // switchMap cancels the previous HTTP call if it hasn't finished yet
      map(res => res.data),
      takeUntilDestroyed(this.destroyRef)
      // takeUntilDestroyed: Angular 16+ — auto-unsubscribes when component destroys
      // Replaces manual ngOnDestroy + Subject + takeUntil pattern
    ).subscribe(order => {
      this.order.set(order);
      if (order.status === 'delivered') {
        // Stop polling when order is delivered — no point checking anymore
        // (takeUntilDestroyed handles final cleanup when component destroys)
      }
    });
  }
}
```

---

# CHAPTER 4 — Performance Deep Dive

## 4.1 When OnPush Saves the Most Performance

OnPush matters most in these scenarios:

**Scenario A: Large lists of cards**
```
BookList renders 48 BookCard components
User types in the search box → Angular runs change detection
DEFAULT: All 48 BookCard checks run — most find nothing changed (wasted)
ONPUSH:  Only BookCards whose [book] input changed get checked
         Result: 47 skipped checks per keystroke
```

**Scenario B: Deep component trees**
```
App → Layout → Sidebar → NavSection → NavItem (×20)
User clicks a button in a completely different branch
DEFAULT: All 20 NavItem components get checked
ONPUSH:  NavItem components skip if their @Input didn't change
```

**How to add OnPush safely to existing components:**

```typescript
// Step 1: Add OnPush
@Component({ changeDetection: ChangeDetectionStrategy.OnPush })

// Step 2: Replace imperative subscribe + assign with async pipe:

// BEFORE (broken with OnPush — template won't update):
books: Book[] = [];
ngOnInit() {
  this.bookService.getBooks().subscribe(res => {
    this.books = res.data; // assignment — no markForCheck — template stays stale
  });
}

// AFTER option A — async pipe (automatic markForCheck):
books$ = this.bookService.getBooks().pipe(map(r => r.data));
// template: @for (book of books$ | async; track book._id)

// AFTER option B — toSignal (automatic):
books = toSignal(this.bookService.getBooks().pipe(map(r => r.data)), { initialValue: [] });
// template: @for (book of books(); track book._id)

// AFTER option C — manual markForCheck:
private cdr = inject(ChangeDetectorRef);
ngOnInit() {
  this.bookService.getBooks().subscribe(res => {
    this.books = res.data;
    this.cdr.markForCheck(); // tell Angular to re-check this component
  });
}
```

---

## 4.2 @defer — Every Trigger Explained with Use Cases

```html
<!-- 1. on viewport — best for: below-the-fold content -->
@defer (on viewport) {
  <app-book-reviews></app-book-reviews>
}
<!-- Download JS only when user scrolls to this element
     Critical metric: reduces Time to Interactive (TTI) for above-the-fold content -->

<!-- 2. on idle — best for: non-critical enhancements -->
@defer (on idle) {
  <app-live-chat></app-live-chat>
}
<!-- Download when browser has nothing better to do
     Won't compete with critical renders -->

<!-- 3. on interaction — best for: feature that appears on user action -->
@defer (on interaction) {
  <app-full-book-detail></app-full-book-detail>
}
<!-- Click, hover, or focus triggers download
     User indicated interest before we spend bandwidth -->

<!-- 4. on timer — best for: popups, banners, non-urgent reveals -->
@defer (on timer(5s)) {
  <app-newsletter-signup></app-newsletter-signup>
}
<!-- 5 seconds after page load — user has had time to read before the popup -->

<!-- 5. when expression — best for: auth-gated features -->
@defer (when isLoggedIn()) {
  <app-personal-recommendations></app-personal-recommendations>
}
<!-- Only load personalization code when the user is actually logged in
     Anonymous users never download this code -->

<!-- 6. Combining prefetch with display trigger (best of both worlds): -->
@defer (on viewport; prefetch on idle) {
  <app-book-detail-extended></app-book-detail-extended>
}
<!-- Code downloads during idle time (fast) but only SHOWS when scrolled in view
     Result: instant display when user reaches it -->
```

**The @placeholder, @loading, @error blocks in detail:**

```html
@defer (on viewport) {
  <app-reviews></app-reviews>

} @placeholder (minimum 100ms) {
  <!-- Shown BEFORE the defer trigger fires (before scrolling into view)
       minimum 100ms: show placeholder for at least 100ms even if trigger fires instantly
       This prevents a flash (placeholder appears and disappears too fast) -->
  <div class="reviews-skeleton">
    <div class="placeholder-glow">
      <span class="placeholder col-8 mb-2"></span>
      <span class="placeholder col-6 mb-2"></span>
      <span class="placeholder col-10"></span>
    </div>
  </div>

} @loading (minimum 500ms; after 100ms) {
  <!-- Shown while the component's JavaScript is downloading
       minimum 500ms: show loading for at least 500ms (prevents flash)
       after 100ms: DON'T show loading until 100ms has passed
         (if download is very fast, skip the loading state entirely — no flash) -->
  <div class="text-center p-4">
    <div class="spinner-border" style="color: var(--book-accent)"></div>
  </div>

} @error {
  <!-- Shown if the component JavaScript fails to download
       (network error, chunk not found on server, etc.) -->
  <div class="alert alert-warning">
    <i class="fa-solid fa-triangle-exclamation me-2"></i>
    Couldn't load reviews. <button class="btn btn-sm btn-link" (click)="retryDefer()">Retry</button>
  </div>
}
```

---

## 4.3 Measuring Performance — Angular DevTools

```
Install Angular DevTools Chrome Extension (https://angular.io/guide/devtools)

What it shows:
1. Component Tree — see all components and their state
2. Profiler — record a session and see:
   - Which components ran change detection
   - How many times each component re-rendered
   - Time spent in change detection

How to use the Profiler:
1. Click Record
2. Interact with your app (click, type, navigate)
3. Click Stop
4. See a bar chart: each bar = one change detection cycle
5. Taller bars = more time spent = potential optimization target
6. Click a bar to see which components re-rendered and why
```

---

## 4.4 Bundle Size — Practical Reduction Steps

```bash
# Generate production build stats:
ng build --stats-json

# Analyze with source-map-explorer:
npm install -g source-map-explorer
source-map-explorer dist/bookstore-frontend/browser/*.js

# OR with webpack-bundle-analyzer:
npm install --save-dev webpack-bundle-analyzer
npx webpack-bundle-analyzer dist/bookstore-frontend/browser/stats.json
```

**Common savings for the bookstore project:**

```typescript
// 1. Import only Material modules you use:
// BAD:
import { MatNativeDateModule } from '@angular/material/core'; // you don't use date pickers
// Just don't import it

// 2. Use date-fns instead of moment.js (if you need date formatting):
// moment.js: ~300KB   →  date-fns: ~13KB (only functions you import)
import { format } from 'date-fns'; // ~1KB tree-shaken
// vs: import moment from 'moment'; // imports everything

// 3. Import lodash functions individually:
import { debounce } from 'lodash-es'; // ~1KB
// vs: import _ from 'lodash'; // ~70KB

// 4. Check for duplicate Angular packages:
// If you use both @angular/core v17 and v16 (can happen with bad peer deps):
npm ls @angular/core
// Should only show one version
```

---

# Expanded Quick Reference — HTTP Advanced + Performance

```typescript
// Interceptor order:
withInterceptors([loadingInterceptor, tokenInterceptor, errorInterceptor])
// Request:  loading.show() → add token → wrap with catchError → network
// Response: network → catchError (handle 401/403) → loading.hide()

// Skip loading for silent requests:
this.http.get('/api/silent', { headers: { 'X-Skip-Loading': 'true' } })
// In interceptor: if (req.headers.has('X-Skip-Loading')) return next(cleanReq);

// Retry with smart error handling:
.pipe(retry({
  count: 3,
  delay: (err: HttpErrorResponse, n) => {
    if (err.status >= 400 && err.status < 500) throw err; // don't retry 4xx
    return timer(n * 1000); // retry 5xx/network with growing delay
  }
}))

// Cache:
private data$ = this.http.get(...).pipe(shareReplay(1));
// One instance — shared across all subscribers — one HTTP request total

// Poll every 10 seconds, stop when component destroys:
interval(10_000).pipe(
  switchMap(() => service.getStatus()),
  takeUntilDestroyed(inject(DestroyRef))
).subscribe(data => this.data.set(data));

// OnPush — only safe with:
// 1. async pipe:  books$ | async
// 2. Signals:     books()
// 3. markForCheck() after manual assign

// @defer triggers:
// on viewport | on idle | on interaction | on timer(Xs) | when expression
// Combine: (on viewport; prefetch on idle)

// @defer blocks:
// @placeholder (minimum Xms) { skeleton content }
// @loading (minimum Xms; after Xms) { spinner }
// @error { retry button }
```

*End of Part 7 (expanded). Part 8: Testing with Jasmine and TestBed.*

---

# CHAPTER 5 — Advanced RxJS Patterns for Angular

## 5.1 forkJoin — Parallel Requests That Must All Complete

`forkJoin` fires multiple Observables simultaneously and waits for ALL to complete, then emits all results at once. Perfect for loading a page that needs data from multiple endpoints.

```typescript
import { forkJoin } from 'rxjs';

@Component({ ... })
export class BookDetail implements OnInit {
  private bookService    = inject(BookService);
  private reviewService  = inject(ReviewService);
  private relatedService = inject(RelatedBooksService);

  book: Book | null = null;
  reviews: Review[] = [];
  relatedBooks: Book[] = [];
  loading = signal(true);

  ngOnInit() {
    const bookId = this.route.snapshot.paramMap.get('id')!;

    forkJoin({
      book:         this.bookService.getBookById(bookId).pipe(map(r => r.data)),
      reviews:      this.reviewService.getForBook(bookId).pipe(map(r => r.data)),
      relatedBooks: this.relatedService.getRelated(bookId).pipe(map(r => r.data)),
    }).subscribe({
      next: ({ book, reviews, relatedBooks }) => {
        // ALL three completed successfully
        // Destructured keys match the forkJoin object keys
        this.book         = book;
        this.reviews      = reviews;
        this.relatedBooks = relatedBooks;
        this.loading.set(false);
      },
      error: (err) => {
        // ANY ONE of them failed — forkJoin errors immediately
        this.error.set('Failed to load book details');
        this.loading.set(false);
      }
    });
    // All three HTTP requests fire at time 0 (in parallel)
    // Total wait time = slowest request
    // vs sequential: total wait time = sum of all requests
  }
}
```

**forkJoin vs combineLatest vs zip:**

```typescript
// forkJoin: waits for ALL to COMPLETE — used for HTTP (one-shot requests)
forkJoin([obs1$, obs2$, obs3$])
// Emits ONCE: [val1, val2, val3] when all complete

// combineLatest: emits whenever ANY one emits — used for live streams
combineLatest([stream1$, stream2$])
// Emits every time either stream emits: [latest1, latest2]
// Good for: combining user input with stored data in real time

// zip: pairs emissions one-to-one
zip([obs1$, obs2$])
// First emission of obs1 paired with first emission of obs2
// Second emission paired with second emission
// Rarely needed — mostly for pairing related sequences
```

---

## 5.2 combineLatest — Reactive Search with Multiple Filters

Building a book list that reacts to multiple simultaneous filters (search, category, sort):

```typescript
import { combineLatest } from 'rxjs';

@Component({ ... })
export class BookList implements OnInit {
  private bookService = inject(BookService);

  // Each filter is its own BehaviorSubject:
  private searchQuery$ = new BehaviorSubject<string>('');
  private category$    = new BehaviorSubject<string>('all');
  private sortBy$      = new BehaviorSubject<string>('title');
  private page$        = new BehaviorSubject<number>(1);

  books = signal<Book[]>([]);
  loading = signal(false);
  total = signal(0);

  // Form controls bound to the BehaviorSubjects:
  searchControl  = new FormControl('');
  categoryControl = new FormControl('all');
  sortControl    = new FormControl('title');

  ngOnInit() {
    // Wire form controls to BehaviorSubjects:
    this.searchControl.valueChanges.pipe(
      debounceTime(300), distinctUntilChanged()
    ).subscribe(q => {
      this.searchQuery$.next(q ?? '');
      this.page$.next(1); // reset to page 1 on search
    });

    this.categoryControl.valueChanges.subscribe(cat => {
      this.category$.next(cat ?? 'all');
      this.page$.next(1);
    });

    this.sortControl.valueChanges.subscribe(sort => {
      this.sortBy$.next(sort ?? 'title');
      this.page$.next(1);
    });

    // React to ANY filter changing:
    combineLatest([
      this.searchQuery$,
      this.category$,
      this.sortBy$,
      this.page$
    ]).pipe(
      // debounceTime here prevents double-firing when multiple filters change simultaneously:
      debounceTime(10),
      switchMap(([query, category, sort, page]) => {
        this.loading.set(true);
        return this.bookService.getBooks({ query, category, sort, page }).pipe(
          catchError(() => of({ data: [], total: 0 }))
        );
      })
    ).subscribe(res => {
      this.books.set(res.data);
      this.total.set(res.total);
      this.loading.set(false);
    });
    // When user types in search → searchQuery$ emits → combineLatest emits latest of all 4 →
    // switchMap fires new HTTP request, cancels previous
    // When user changes category → same flow, instant reaction
  }

  changePage(page: number) {
    this.page$.next(page);
  }
}
```

---

## 5.3 takeUntilDestroyed — Clean Auto-Unsubscribe

Angular 16+ provides `takeUntilDestroyed` — the cleanest way to auto-unsubscribe when a component is destroyed:

```typescript
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { DestroyRef } from '@angular/core';

@Component({ ... })
export class BookList {
  private destroyRef = inject(DestroyRef);
  // DestroyRef: Angular 16+ — emits when the component is destroyed

  ngOnInit() {
    // OLD way — verbose:
    private subscription = someObservable.subscribe();
    ngOnDestroy() { this.subscription.unsubscribe(); }

    // NEW way — takeUntilDestroyed:
    someObservable.pipe(
      takeUntilDestroyed(this.destroyRef)
      // Automatically unsubscribes when destroyRef emits (component destroyed)
      // No subscription variable, no ngOnDestroy cleanup
    ).subscribe(val => { /* ... */ });

    // Or in a field initializer (no need to pass destroyRef):
  }

  // In class field — destroyRef is implicit:
  private counter$ = interval(1000).pipe(
    takeUntilDestroyed(),
    // When used as a class field initializer (not in a method),
    // takeUntilDestroyed() automatically uses the current component's DestroyRef
  );
}
```

---

## 5.4 Subject Types — When to Use Each

```typescript
// Subject: manually emit values, no initial value, late subscribers miss previous emissions
const subject = new Subject<string>();
subject.next('A');  // emitted
const sub = subject.subscribe(v => console.log(v));
subject.next('B');  // sub receives 'B'
// sub missed 'A' — subscribed after it was emitted
// Use case: event bus between components, one-time notifications

// BehaviorSubject: has a current value, new subscribers get the latest emission immediately
const behavior = new BehaviorSubject<boolean>(false); // initial value: false
behavior.next(true);
const sub = behavior.subscribe(v => console.log(v)); // immediately logs: true
behavior.next(false); // sub receives false
// behavior.getValue(): reads current value synchronously
// Use case: auth state, cart count, user preferences, any "current state"

// ReplaySubject: replays N last emissions to new subscribers
const replay = new ReplaySubject<string>(3); // buffer 3 emissions
replay.next('A');
replay.next('B');
replay.next('C');
replay.next('D');
const sub = replay.subscribe(v => console.log(v)); // logs: B, C, D (last 3)
// Use case: activity history, recently viewed items, notification queue

// AsyncSubject: only emits the LAST value, and only when complete() is called
const async = new AsyncSubject<number>();
async.next(1);
async.next(2);
async.next(3);
async.complete(); // NOW it emits: 3 (only the last value)
// Use case: wrapping a one-shot process that should share only the final result
```

---

## 5.5 Custom HTTP Cache Service

A proper caching service that handles stale data, concurrent requests, and cache invalidation by key:

```typescript
@Injectable({ providedIn: 'root' })
export class CacheService {
  private cache = new Map<string, { data$: Observable<any>; timestamp: number }>();
  private readonly TTL = 5 * 60 * 1000; // 5 minutes

  get<T>(key: string, source: Observable<T>): Observable<T> {
    const cached = this.cache.get(key);
    const now = Date.now();

    if (cached && now - cached.timestamp < this.TTL) {
      return cached.data$ as Observable<T>; // return cached Observable
    }

    // Create new Observable with shareReplay:
    const data$ = source.pipe(
      shareReplay(1),
      catchError(err => {
        this.cache.delete(key); // don't cache errors
        return throwError(() => err);
      })
    );

    this.cache.set(key, { data$, timestamp: now });
    return data$;
  }

  invalidate(key: string): void {
    this.cache.delete(key);
  }

  invalidateAll(): void {
    this.cache.clear();
  }
}

// In BookService:
@Injectable({ providedIn: 'root' })
export class BookService {
  private cache = inject(CacheService);

  getBooks(params: BookParams): Observable<ApiResponse<Book[]>> {
    const cacheKey = `books:${JSON.stringify(params)}`;
    // Unique key per unique set of parameters
    // Same params → same key → cache hit
    // Different page/sort → different key → new request

    return this.cache.get(
      cacheKey,
      this.http.get<ApiResponse<Book[]>>(this.api, { params: params as any })
    );
  }

  createBook(data: CreateBookDto): Observable<ApiResponse<Book>> {
    return this.http.post<ApiResponse<Book>>(this.api, data).pipe(
      tap(() => this.cache.invalidateAll())
      // After creating a book, all book list caches are stale
    );
  }
}
```

---

## 5.6 Performance — Bundle Analysis Walkthrough

When you run `ng build --stats-json`, you get a `stats.json` file. Here's what to look for:

```bash
npx webpack-bundle-analyzer dist/bookstore-frontend/browser/stats.json
# Opens interactive treemap at http://127.0.0.1:8888
```

**Reading the treemap:**

```
Rectangles: each rectangle = one module/file
Size: bigger rectangle = more code = potentially worth optimizing
Colors: different libraries/modules

LOOK FOR:
├── rxjs/               — should be 50-80KB, mostly operators
│   If very large: you imported rxjs entirely instead of specific operators
│
├── @angular/            — core framework ~100KB (normal)
│
├── @angular/material/   — watch this one
│   If > 200KB: you imported MatModule (everything) instead of specific modules
│   Fix: import only MatButtonModule, MatInputModule etc.
│
├── lodash or moment     — RED FLAG if present
│   lodash: 70KB+ → use lodash-es with named imports OR native JS equivalents
│   moment: 300KB+ → replace with date-fns (import only what you use)
│
└── your-app/            — should be the largest chunk (your code)
    If small: good, your code is lean
    If contains node_modules mixed in: webpack config issue
```

---

# Expanded Quick Reference — HTTP Advanced + Performance

## RxJS Operators Used in Angular Services

```typescript
// One-time requests (HTTP):
forkJoin({ a: obs1$, b: obs2$ })   // parallel, all must complete
combineLatest([obs1$, obs2$])      // reactive, emits on any change
zip([obs1$, obs2$])                // pairs emissions one-to-one

// Transforming:
map(v => transform(v))             // transform each emission
switchMap(v => observable$)        // cancel previous, start new (search, navigation)
mergeMap(v => observable$)         // run all concurrently (parallel uploads)
concatMap(v => observable$)        // run sequentially (order matters)
exhaustMap(v => observable$)       // ignore new until current completes (submit button)

// Filtering:
filter(v => condition)             // only emit if condition true
debounceTime(300)                  // wait 300ms after last emission
distinctUntilChanged()             // skip if same as previous
take(1)                            // complete after one emission
first()                            // same but errors if stream empties
skip(1)                            // skip first emission (BehaviorSubject initial value)

// Error handling:
catchError(err => of(fallback))    // recover from error with fallback value
catchError(err => throwError(err)) // re-throw (interceptor pattern)
retry({ count: 3, delay: 1000 })   // retry failed observable
finalize(() => cleanup())          // always runs on complete or error

// Side effects:
tap(v => sideEffect(v))           // inspect without changing

// Combining:
startWith(initialValue)            // emit initial value before observable starts
pairwise()                         // emit [previous, current] pairs

// Cleanup:
takeUntil(destroy$)                // unsubscribe when destroy$ emits
takeUntilDestroyed(destroyRef)     // Angular 16+ auto-unsubscribe
shareReplay(1)                     // cache and share last emission
```

## Performance Decision Tree

```
My component re-renders too often?
  → Add ChangeDetectionStrategy.OnPush
  → Replace subscribe+assign with async pipe or Signals

My @for list is slow when data changes?
  → Add track item.id to @for
  → Ensure parent creates new array references (not mutating)

My page takes too long to load initially?
  → Use @defer for below-the-fold content
  → Check bundle size: ng build --stats-json
  → Lazy load all routes with loadComponent

My API is called too many times?
  → Use shareReplay(1) for reference data (categories, authors)
  → Add debounceTime(300) to search inputs
  → Add switchMap to cancel previous search requests

My component doesn't update after Observable emits?
  → Using OnPush + subscribe + assign → add markForCheck()
  → Or switch to async pipe (handles OnPush automatically)
  → Or switch to toSignal() (handles OnPush automatically)
```

*End of Part 7 (fully expanded). Part 8: Testing with Jasmine and TestBed.*
