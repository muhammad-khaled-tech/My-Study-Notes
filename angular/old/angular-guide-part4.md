# 📙 Angular Complete Guide — Part 4 of 9
## Component Communication + Angular Signals + Routing Deep Dive
> Assumes Parts 1–3 complete | Hybrid: concept first, then bookstore application

---

# TABLE OF CONTENTS

1. Component Communication
   - The problem: components are isolated by design
   - Parent → Child: @Input() — passing data down
   - Child → Parent: @Output() + EventEmitter — sending events up
   - @Input with setters — reacting when input changes
   - @Input transform (Angular 16+)
   - @ViewChild — parent accessing child component/element
   - @ViewChildren — multiple children
   - @ContentChild — accessing projected content
   - ng-content — content projection
   - Sibling communication via shared Service
   - Bookstore application: connecting BookCard to BookList

2. Angular Signals — Modern State Management
   - Why signals exist (the problem with Zone.js)
   - signal() — creating reactive values
   - Reading a signal
   - set(), update(), mutate()
   - computed() — derived values
   - effect() — reactive side effects
   - Signals vs BehaviorSubject — when to use which
   - input() signal — the new @Input
   - output() — the new @Output
   - Bookstore application: converting loading state to signals

3. Routing Deep Dive
   - Route parameters (:id)
   - Reading params with ActivatedRoute
   - Query parameters (?page=1&sort=title)
   - Reading and setting query params
   - Route data — static data on routes
   - Child routes and nested router-outlet
   - Router events — listening to navigation
   - Navigation extras (state, replaceUrl, skipLocationChange)
   - Resolvers — pre-loading data before route activates
   - canDeactivate guard — prevent leaving unsaved forms
   - RouterLink advanced (queryParams, fragment, relativeTo)
   - Programmatic navigation with extras
   - Bookstore application: book detail page with route params

---

---

# CHAPTER 1 — Component Communication

## 1.1 The Problem: Components Are Isolated by Design

In Angular, every component is a self-contained unit. Its properties, methods, and template are private to itself. This is good — it prevents the chaos of global state — but it creates a question: **how do components talk to each other?**

There are four main patterns:

```
Parent → Child     : @Input()              — parent passes data DOWN
Child → Parent     : @Output() + EventEmitter — child sends events UP
Any → Any          : Shared Service        — any component reads/writes shared state
Parent ← → Child   : @ViewChild            — parent directly accesses child's methods/properties
```

The direction matters. Think of the component tree:

```
AppComponent
  └── Navbar
  └── BookList
        └── BookCard  (×12)
        └── Pagination
  └── Profile
```

Data flows DOWN through `@Input()`. Events bubble UP through `@Output()`. For cross-branch communication (BookList ↔ Navbar), you use a Service.

---

## 1.2 Parent → Child: @Input()

`@Input()` marks a property as an **input** — the parent can set its value.

```typescript
// book-card.ts (CHILD)
import { Component, Input } from '@angular/core';
import { Book } from '../../../core/models/book.model';

@Component({
  selector: 'app-book-card',
  standalone: true,
  templateUrl: './book-card.html',
})
export class BookCard {
  @Input() book!: Book;
  // @Input() — this property can be set by the parent
  // book! — definite assignment assertion (parent MUST provide this)
  // Type: Book — TypeScript enforces the parent passes the right shape

  @Input() showPrice: boolean = true;
  // Optional input with a default value
  // If parent doesn't pass [showPrice], it stays true
}
```

```html
<!-- book-list.html (PARENT) -->
@for (book of books; track book._id) {
  <app-book-card
    [book]="book"
    [showPrice]="true"
  ></app-book-card>
}

<!-- [book]="book" → property binding: passes the loop variable to @Input() book -->
<!-- [showPrice]="true" → passes boolean true (with brackets = expression, not string) -->
<!-- showPrice="true" (no brackets) → passes the STRING "true", not boolean! -->
```

**The `!` on @Input:**

```typescript
@Input() book!: Book;
// The ! tells TypeScript: "I know this will be set before it's used"
// Without !, TypeScript complains: "Property 'book' has no initializer
//   and is not definitely assigned in the constructor"
// Alternative: @Input() book?: Book; — makes it optional (might be undefined)
// Use ! when the input is REQUIRED, ? when it's optional
```

**@Input with alias:**

```typescript
@Input('bookData') book!: Book;
// External name: 'bookData' (what the parent uses: [bookData]="...")
// Internal name: book (what you use inside the component: this.book)
// Useful for component library APIs where you want clean external names
```

---

## 1.3 Child → Parent: @Output() + EventEmitter

`@Output()` marks a property as an **event emitter** — the child can emit events that the parent listens to.

```typescript
// book-card.ts (CHILD)
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { Book } from '../../../core/models/book.model';

@Component({
  selector: 'app-book-card',
  standalone: true,
  templateUrl: './book-card.html',
})
export class BookCard {
  @Input() book!: Book;

  @Output() addToCart = new EventEmitter<Book>();
  // @Output() — this property emits events to the parent
  // EventEmitter<Book> — the type of data this event carries
  // addToCart — the event name (parent listens with (addToCart)="...")

  @Output() bookSelected = new EventEmitter<string>();
  // EventEmitter<string> — emits just the book ID

  onAddClick() {
    this.addToCart.emit(this.book);
    // .emit(value) — fires the event, passing the book to the parent
    // The parent's event handler receives this book as $event
  }

  onBookClick() {
    this.bookSelected.emit(this.book._id);
    // Emit just the ID — parent doesn't need the full book object
  }
}
```

```html
<!-- book-card.html (CHILD) -->
<div class="card" (click)="onBookClick()">
  <h5>{{ book.title }}</h5>
  <button (click)="onAddClick(); $event.stopPropagation()">Add to Cart</button>
  <!-- $event.stopPropagation() — prevents the button click from also triggering
       the card's (click) event (event bubbling) -->
</div>
```

```html
<!-- book-list.html (PARENT) -->
@for (book of books; track book._id) {
  <app-book-card
    [book]="book"
    (addToCart)="handleAddToCart($event)"
    (bookSelected)="navigateToBook($event)"
  ></app-book-card>
}
<!-- (addToCart)="..." — event binding: listens for the addToCart event
     $event — the value emitted by child.addToCart.emit(book) — it's the Book object
     (bookSelected)="..." — $event here is a string (the book ID) -->
```

```typescript
// book-list.ts (PARENT)
export class BookList {
  handleAddToCart(book: Book) {
    // book is $event — the Book object emitted by the child
    this.cartService.addToCart(book._id, 1).subscribe(...);
  }

  navigateToBook(bookId: string) {
    // bookId is $event — the string emitted by the child
    this.router.navigate(['/books', bookId]);
  }
}
```

---

## 1.4 @Input with Setters — Reacting When Input Changes

Sometimes you need to run logic when an `@Input` value changes. You can use a setter:

```typescript
// OPTION 1: ngOnChanges (covered in Part 1)
// OPTION 2: Property setter — cleaner for single inputs

export class BookCard {
  private _book!: Book;
  processedTitle = '';

  @Input()
  set book(value: Book) {
    // This setter runs every time the parent sets [book]="..."
    this._book = value;
    this.processedTitle = value.title.toUpperCase(); // do something with new value
  }

  get book(): Book {
    return this._book;
  }
}
```

---

## 1.5 @Input transform (Angular 16+)

Angular 16 added a `transform` option to `@Input()` that converts the incoming value:

```typescript
import { Component, Input, booleanAttribute, numberAttribute } from '@angular/core';

export class BookCard {
  @Input({ transform: booleanAttribute }) showPrice = true;
  // booleanAttribute: converts string "true"/"false"/"" to actual boolean
  // This allows: <app-book-card showPrice> (no value = true)
  //          or: <app-book-card showPrice="false">
  // Without transform, these would pass strings, not booleans

  @Input({ transform: numberAttribute }) maxLength = 100;
  // numberAttribute: converts string "150" to number 150
  // Allows: <app-book-card maxLength="150"> instead of [maxLength]="150"

  @Input({ required: true }) book!: Book;
  // required: true — Angular throws a compile-time error if parent forgets this input
  // Much clearer than the runtime crash you'd get without it
}
```

---

## 1.6 @ViewChild — Parent Accessing Child

`@ViewChild` gives a parent component a direct reference to a child component or DOM element in its own template.

```typescript
// parent.ts
import { Component, ViewChild, AfterViewInit } from '@angular/core';
import { SomeModal } from './some-modal/some-modal';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [SomeModal],
  template: `
    <app-some-modal #modal></app-some-modal>
    <button (click)="openModal()">Open</button>
  `
})
export class Parent implements AfterViewInit {
  @ViewChild('modal') modal!: SomeModal;
  // 'modal' — matches the template reference variable #modal
  // SomeModal — the type of the reference (the component class)
  // !  — will be assigned by AfterViewInit

  @ViewChild('modal', { static: false }) modalLate!: SomeModal;
  // static: false (default) — resolved after change detection
  //   Use for components inside @if or @for (might not exist initially)
  // static: true — resolved before change detection (ngOnInit)
  //   Use for components always present in the template

  ngAfterViewInit() {
    // @ViewChild references are available HERE — after view is initialized
    // NOT in constructor or ngOnInit
    console.log(this.modal); // the SomeModal component instance
  }

  openModal() {
    this.modal.open(); // call a public method on the child component
  }
}
```

**@ViewChild for DOM elements:**

```typescript
import { ElementRef, ViewChild } from '@angular/core';

export class Login implements AfterViewInit {
  @ViewChild('emailInput') emailInputRef!: ElementRef<HTMLInputElement>;
  // ElementRef wraps the native DOM element
  // The generic <HTMLInputElement> gives TypeScript the right DOM type

  ngAfterViewInit() {
    this.emailInputRef.nativeElement.focus();
    // .nativeElement — the actual DOM element
    // .focus() — native DOM method
  }
}
```

---

## 1.7 @ViewChildren — Multiple Children

```typescript
import { ViewChildren, QueryList } from '@angular/core';
import { BookCard } from './book-card/book-card';

export class BookList {
  @ViewChildren(BookCard) bookCards!: QueryList<BookCard>;
  // QueryList — Angular's collection type for multiple ViewChildren
  // QueryList is iterable and has useful methods

  ngAfterViewInit() {
    console.log(this.bookCards.length); // number of BookCard instances
    this.bookCards.forEach(card => console.log(card.book.title));

    // React to changes in the list:
    this.bookCards.changes.subscribe(() => {
      console.log('BookCard count changed:', this.bookCards.length);
    });
    // .changes is an Observable — fires when items are added/removed
  }
}
```

---

## 1.8 ng-content — Content Projection

Content projection lets you pass HTML content INTO a component from the outside. Like slots in web components.

```html
<!-- card.html — a generic card wrapper component -->
<div class="card border-book p-4">
  <ng-content></ng-content>
  <!-- ng-content is a placeholder — whatever the parent puts between
       <app-card> and </app-card> appears here -->
</div>
```

```html
<!-- Usage in parent template -->
<app-card>
  <h3>Title</h3>
  <p>Some description text</p>
  <button>Action</button>
</app-card>
<!-- The h3, p, and button are projected into <ng-content> -->
```

**Named slots (multiple content areas):**

```html
<!-- modal.html -->
<div class="modal">
  <div class="modal-header">
    <ng-content select="[slot='header']"></ng-content>
  </div>
  <div class="modal-body">
    <ng-content select="[slot='body']"></ng-content>
  </div>
  <div class="modal-footer">
    <ng-content select="[slot='footer']"></ng-content>
  </div>
</div>
```

```html
<!-- Usage -->
<app-modal>
  <h4 slot="header">Confirm Purchase</h4>
  <p slot="body">Are you sure you want to buy this?</p>
  <button slot="footer">Confirm</button>
</app-modal>
```

---

## 1.9 Sibling Communication via Shared Service

When two components don't have a direct parent-child relationship, use a shared Service with a `BehaviorSubject`.

```typescript
// cart.service.ts
@Injectable({ providedIn: 'root' })
export class CartService {
  private cartCount$ = new BehaviorSubject<number>(0);
  cartCount = this.cartCount$.asObservable();

  updateCount(count: number) {
    this.cartCount$.next(count);
  }
}

// BookCard component (no relation to Navbar):
onAddToCart() {
  this.cartService.addItem(this.book._id).subscribe(cart => {
    this.cartService.updateCount(cart.items.length);
    // Emits to all subscribers — including the Navbar
  });
}

// Navbar component:
ngOnInit() {
  this.cartService.cartCount.subscribe(count => {
    this.cartItemCount = count; // Navbar updates automatically
  });
}
```

---

## 1.10 Bookstore Application: BookCard ↔ BookList

Here's how the full component communication chain works in the bookstore:

```typescript
// book-card.ts
@Component({ selector: 'app-book-card', standalone: true, ... })
export class BookCard {
  @Input({ required: true }) book!: Book;
  @Output() addedToCart = new EventEmitter<Book>();

  onAddClick() {
    this.addedToCart.emit(this.book);
  }
}

// book-list.ts
@Component({ selector: 'app-book-list', standalone: true,
  imports: [BookCard, ...] })
export class BookList {
  books: Book[] = [];

  handleAddedToCart(book: Book) {
    // Connect to CartService here
    console.log('Adding to cart:', book.title);
  }
}
```

```html
<!-- book-list.html -->
@for (book of books; track book._id) {
  <app-book-card
    [book]="book"
    (addedToCart)="handleAddedToCart($event)"
  ></app-book-card>
}
```

---

---

# CHAPTER 2 — Angular Signals: Modern State Management

## 2.1 Why Signals Exist

Angular has always used Zone.js for change detection. Zone.js monkey-patches browser APIs and tells Angular "something async happened, re-check everything." This works but has two problems:

1. **It's imprecise** — Angular re-checks ALL components, even ones that didn't change
2. **It requires Zone.js** — a 50kb library that overrides browser APIs (fragile, incompatible with some native browser features)

**Signals** (introduced in Angular 16, stable in Angular 17) solve this with a simpler model: you explicitly mark values as reactive, and Angular tracks exactly which templates depend on which values. Only those templates re-render when a value changes. No Zone.js needed.

---

## 2.2 signal() — Creating Reactive Values

```typescript
import { signal } from '@angular/core';

// Creating a signal:
const count = signal(0);         // initial value: 0
const name = signal('Khaled');   // initial value: 'Khaled'
const books = signal<Book[]>([]); // initial value: empty array (typed)
const loading = signal(false);   // initial value: false

// Reading a signal — CALL IT LIKE A FUNCTION:
console.log(count()); // 0
console.log(name());  // 'Khaled'
// This is NOT a method call — () reads the current value
// This is how Angular tracks dependencies: when Angular calls count() during rendering,
// it registers "this template depends on count"
```

---

## 2.3 set(), update(), mutate()

```typescript
const count = signal(0);

// set() — replace the value entirely:
count.set(5);
console.log(count()); // 5

// update() — compute new value from current:
count.update(current => current + 1);
console.log(count()); // 6
// update() receives the current value and returns the new value
// Equivalent to: count.set(count() + 1) — but cleaner

// For objects and arrays — mutate() (DEPRECATED, use update instead):
const books = signal<Book[]>([]);

// WRONG way (mutating in place — signal doesn't detect this):
books().push(newBook); // ❌ signal doesn't know this changed!

// RIGHT way — create a new array reference:
books.update(current => [...current, newBook]); // ✅
// Spread creates a new array — signal detects the reference change
```

---

## 2.4 computed() — Derived Values

`computed()` creates a signal whose value is derived from other signals. It automatically recalculates when its dependencies change.

```typescript
import { signal, computed } from '@angular/core';

const books = signal<Book[]>([]);
const searchQuery = signal('');

// computed automatically recalculates when books() or searchQuery() changes:
const filteredBooks = computed(() => {
  const query = searchQuery().toLowerCase();
  return books().filter(book =>
    book.title.toLowerCase().includes(query)
  );
});
// filteredBooks is READ-ONLY — you can't call filteredBooks.set()
// It recalculates lazily — only when something reads filteredBooks()

const bookCount = computed(() => books().length);
// Simple derived value — recalculates when books changes

// In template:
// {{ bookCount() }} — reads the computed signal — auto-refreshes when books changes
// @for (book of filteredBooks(); ...) — auto-filters when searchQuery changes
```

---

## 2.5 effect() — Reactive Side Effects

`effect()` runs a function whenever any signal it reads changes. Like `tap()` for signals.

```typescript
import { signal, effect } from '@angular/core';

const theme = signal<'light' | 'dark'>('light');

// This effect runs whenever theme() changes:
effect(() => {
  document.body.setAttribute('data-theme', theme());
  // Angular tracks: this effect reads theme(), so re-run when theme changes
});

// Practical example — persist to localStorage:
const userPrefs = signal({ fontSize: 16, theme: 'light' });

effect(() => {
  localStorage.setItem('userPrefs', JSON.stringify(userPrefs()));
  // Runs on every change — keeps localStorage in sync
});

// effects run ONCE immediately on creation (to establish dependencies),
// then again whenever any read signal changes
```

**Important: `effect()` must be called in an injection context** (constructor, field initializer, or factory):

```typescript
export class MyComponent {
  theme = signal('light');

  constructor() {
    effect(() => {
      document.body.setAttribute('data-theme', this.theme());
    });
    // ✅ constructor is an injection context
  }

  someMethod() {
    effect(() => { ... }); // ❌ Not an injection context
  }
}
```

---

## 2.6 Signals vs BehaviorSubject — When to Use Which

```
┌─────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ Feature             │ BehaviorSubject (RxJS)        │ Signal                       │
├─────────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Reading             │ .getValue() or subscribe()    │ call like function: count()  │
│ Writing             │ .next(newValue)               │ .set() or .update()          │
│ Derived values      │ pipe(map(...))                │ computed()                   │
│ Side effects        │ pipe(tap(...))                │ effect()                     │
│ In templates        │ | async pipe required         │ just call it: {{ count() }}  │
│ Operators           │ Full RxJS (switchMap, etc.)   │ None (simpler)               │
│ Multi-step streams  │ ✅ Perfect                    │ ❌ Not designed for this      │
│ HTTP responses      │ ✅ Observable is HTTP-native  │ Use with toSignal() helper    │
│ Complexity          │ Higher learning curve         │ Simpler                      │
│ Change detection    │ Works with Zone.js            │ Works with or without Zone.js│
└─────────────────────┴──────────────────────────────┴──────────────────────────────┘

Rule of thumb:
- Simple component state (loading, error, count) → Signal
- Shared state across components → BehaviorSubject or Signal in a Service  
- HTTP calls and complex async flows → Observable (use toSignal() to convert if needed)
- New code in Angular 17+ → prefer Signals for component state
```

---

## 2.7 toSignal() — Convert Observable to Signal

```typescript
import { toSignal } from '@angular/core/rxjs-interop';

@Component({ ... })
export class BookList {
  private bookService = inject(BookService);

  // Convert Observable to Signal — no subscribe() needed in TS:
  books = toSignal(
    this.bookService.getBooks().pipe(map(res => res.data)),
    { initialValue: [] as Book[] }
  );
  // books is now a Signal<Book[]>
  // Initial value: [] (before the Observable emits)
  // Automatically unsubscribes when component is destroyed!

  // In template: @for (book of books(); ...) — no | async needed
}
```

---

## 2.8 input() signal — The New @Input (Angular 17.1+)

```typescript
import { Component, input, output } from '@angular/core';

export class BookCard {
  // New signal-based input:
  book = input.required<Book>();
  // book() reads the value — it's a signal now
  // .required: compile error if parent doesn't provide it
  // Replaces: @Input({ required: true }) book!: Book;

  showPrice = input<boolean>(true);
  // showPrice() reads the value
  // Default value: true
  // Replaces: @Input() showPrice = true;

  // In template: {{ book().title }} — reading the signal
  // Automatically reactive — template updates when parent changes [book]
}
```

---

## 2.9 Bookstore: Converting Loading State to Signals

```typescript
// Before (plain boolean):
export class Login {
  loading = false;
  serverError = '';

  submitLogin() {
    this.loading = true;
    this.auth.login(email, pass).subscribe({
      next: () => { this.router.navigate(['/books']); },
      error: (err) => { this.serverError = err.error?.message; this.loading = false; }
    });
  }
}

// After (signals):
import { signal } from '@angular/core';

export class Login {
  loading = signal(false);
  serverError = signal('');

  submitLogin() {
    this.loading.set(true);
    this.auth.login(email, pass).subscribe({
      next: () => { this.router.navigate(['/books']); },
      error: (err) => {
        this.serverError.set(err.error?.message || 'Login failed');
        this.loading.set(false);
      }
    });
  }
}
```

```html
<!-- Template with signals — note the () to read: -->
<button [disabled]="loading()" type="submit">
  @if (loading()) {
    <span class="spinner-border spinner-border-sm me-2"></span>Signing in...
  } @else {
    Sign In
  }
</button>

@if (serverError()) {
  <div class="alert alert-danger">{{ serverError() }}</div>
}
```

---

---

# CHAPTER 3 — Routing Deep Dive

## 3.1 Route Parameters (:id)

A route parameter is a dynamic segment of the URL, declared with `:paramName`.

```typescript
// In app.routes.ts:
{
  path: 'books/:id',
  loadComponent: () => import('./features/books/book-detail/book-detail').then(c => c.BookDetail)
}
// :id matches any string: /books/abc123, /books/678def, etc.
// The matched value ('abc123') is available in the component via ActivatedRoute
```

---

## 3.2 Reading Params with ActivatedRoute

```typescript
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({ ... })
export class BookDetail implements OnInit {
  private route = inject(ActivatedRoute);
  // ActivatedRoute: service that holds info about the CURRENTLY ACTIVE route
  // Each component gets its own ActivatedRoute instance for its own route

  bookId = '';

  // METHOD 1: Snapshot (one-time read — good when navigating away and back creates a new component)
  ngOnInit() {
    this.bookId = this.route.snapshot.paramMap.get('id') ?? '';
    // snapshot: the current state of the route (doesn't update if the route changes)
    // paramMap.get('id'): reads the ':id' parameter value
    // ?? '': nullish coalescing — use '' if get() returns null
  }

  // METHOD 2: Observable (reactive — good when parameter can change without component recreation)
  ngOnInit() {
    this.route.paramMap.subscribe(params => {
      this.bookId = params.get('id') ?? '';
      // This fires every time :id changes, even if the same component is reused
      // Example: user goes from /books/123 to /books/456 — same BookDetail component
      // Snapshot would still show '123' — paramMap Observable would update to '456'
    });
  }

  // METHOD 3: Signals (Angular 17+ — cleanest)
  bookId = toSignal(
    this.route.paramMap.pipe(map(params => params.get('id') ?? '')),
    { initialValue: '' }
  );
}
```

---

## 3.3 Query Parameters

Query parameters are the key=value pairs after `?` in the URL. Example: `/books?page=2&sort=price&category=fiction`

```typescript
// Reading query params:
export class BookList implements OnInit {
  private route = inject(ActivatedRoute);

  ngOnInit() {
    // Snapshot (one-time):
    const page = this.route.snapshot.queryParamMap.get('page') ?? '1';
    const sort = this.route.snapshot.queryParamMap.get('sort') ?? 'title';

    // Observable (reactive):
    this.route.queryParamMap.subscribe(params => {
      const page = params.get('page') ?? '1';
      const sort = params.get('sort') ?? 'title';
      this.loadBooks(+page, sort); // + converts string to number
    });
  }
}
```

```typescript
// Setting query params programmatically:
export class BookList {
  private router = inject(Router);

  goToPage(page: number) {
    this.router.navigate([], {
      // [] means "stay on the current route" — don't change the path
      relativeTo: this.route,    // relative to current route
      queryParams: { page },     // set these query params
      queryParamsHandling: 'merge'
      // 'merge': keep existing params, only change the ones you specify
      // 'preserve': keep all existing params unchanged (ignore queryParams)
      // '' (default): replace ALL query params with queryParams
    });
    // URL becomes: /books?page=2&sort=title (if sort was already there and we merge)
  }
}
```

```html
<!-- Setting query params in templates: -->
<a routerLink="/books" [queryParams]="{ page: 2, sort: 'title' }">
  Page 2
</a>
<!-- Result URL: /books?page=2&sort=title -->

<a routerLink="/books" [queryParams]="{ page: 3 }" queryParamsHandling="merge">
  Next Page
</a>
<!-- Keeps existing params, adds/changes page to 3 -->
```

---

## 3.4 Route Data — Static Data

You can attach static data to any route. Useful for things like page titles, breadcrumbs, or permission flags.

```typescript
// In app.routes.ts:
{
  path: 'admin',
  loadComponent: () => import('./features/admin/admin').then(c => c.Admin),
  canActivate: [adminGuard],
  data: {
    title: 'Admin Dashboard',
    breadcrumb: 'Admin',
    requiresAdmin: true
  }
}

// Reading in component:
export class Admin implements OnInit {
  private route = inject(ActivatedRoute);

  ngOnInit() {
    const title = this.route.snapshot.data['title']; // 'Admin Dashboard'
    document.title = title; // set browser tab title
  }
}
```

---

## 3.5 Child Routes and Nested router-outlet

For layouts where a section of the page stays constant while the inner content changes.

```typescript
// app.routes.ts — profile section with sub-pages:
{
  path: 'profile',
  loadComponent: () => import('./features/profile/profile-layout').then(c => c.ProfileLayout),
  canActivate: [authGuard],
  children: [
    {
      path: '',       // /profile
      loadComponent: () => import('./features/profile/profile-info').then(c => c.ProfileInfo),
    },
    {
      path: 'orders', // /profile/orders
      loadComponent: () => import('./features/profile/profile-orders').then(c => c.ProfileOrders),
    },
    {
      path: 'security', // /profile/security
      loadComponent: () => import('./features/profile/profile-security').then(c => c.ProfileSecurity),
    }
  ]
}
```

```html
<!-- profile-layout.html — the persistent shell -->
<div class="container py-4">
  <div class="row">
    <div class="col-3">
      <!-- Sidebar stays constant -->
      <nav class="nav flex-column">
        <a routerLink="/profile" routerLinkActive="active" [routerLinkActiveOptions]="{exact:true}">My Info</a>
        <a routerLink="/profile/orders" routerLinkActive="active">Orders</a>
        <a routerLink="/profile/security" routerLinkActive="active">Security</a>
      </nav>
    </div>
    <div class="col-9">
      <router-outlet></router-outlet>
      <!-- Child route components render HERE — sidebar stays -->
    </div>
  </div>
</div>
```

---

## 3.6 Router Events

The Angular Router emits events throughout the navigation lifecycle. You can subscribe to observe navigation:

```typescript
import { Router, NavigationStart, NavigationEnd, NavigationError, NavigationCancel } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({ selector: 'app-root', ... })
export class App implements OnInit {
  private router = inject(Router);
  isNavigating = signal(false);

  ngOnInit() {
    this.router.events.subscribe(event => {
      if (event instanceof NavigationStart) {
        this.isNavigating.set(true);
        // Navigation began — show global loading indicator
      }
      if (event instanceof NavigationEnd) {
        this.isNavigating.set(false);
        // Navigation completed — hide loading indicator
        window.scrollTo(0, 0); // scroll to top on route change
      }
      if (event instanceof NavigationCancel) {
        this.isNavigating.set(false);
        // Navigation was cancelled (e.g., guard returned false)
      }
      if (event instanceof NavigationError) {
        this.isNavigating.set(false);
        console.error('Navigation error:', event.error);
      }
    });

    // Using filter to only handle specific events (cleaner):
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe(event => {
      // Only NavigationEnd events reach here
    });
  }
}
```

---

## 3.7 canDeactivate Guard — Prevent Leaving with Unsaved Changes

```typescript
// edit-book.guard.ts
import { CanDeactivateFn } from '@angular/router';
import { EditBook } from '../features/books/edit-book/edit-book';

export const unsavedChangesGuard: CanDeactivateFn<EditBook> = (component) => {
  // component is the instance of the component being navigated away from
  // We can check its state to decide if we should allow navigation

  if (component.hasUnsavedChanges()) {
    return confirm('You have unsaved changes. Leave anyway?');
    // confirm() shows a browser dialog — returns true (leave) or false (stay)
    // Better UX: use a custom modal component instead
  }
  return true; // no unsaved changes — allow navigation
};

// In routes:
{
  path: 'admin/books/edit/:id',
  loadComponent: () => import('./features/books/edit-book/edit-book').then(c => c.EditBook),
  canDeactivate: [unsavedChangesGuard]
}

// In the component:
export class EditBook {
  editForm!: FormGroup;

  hasUnsavedChanges(): boolean {
    return this.editForm.dirty; // dirty = user has changed values
  }
}
```

---

## 3.8 Resolvers — Pre-Loading Data Before Activation

A resolver fetches data BEFORE the component loads. The component receives the data as route data — no loading state needed.

```typescript
// book-detail.resolver.ts
import { ResolveFn } from '@angular/router';
import { Book } from '../core/models/book.model';
import { BookService } from '../core/services/book.service';

export const bookDetailResolver: ResolveFn<Book> = (route) => {
  const bookService = inject(BookService);
  const id = route.paramMap.get('id')!;
  return bookService.getBookById(id).pipe(
    map(res => res.data)
  );
  // This Observable is subscribed to by Angular
  // Angular waits for it to emit, then activates the route with the data
};

// In routes:
{
  path: 'books/:id',
  loadComponent: () => import('./features/books/book-detail/book-detail').then(c => c.BookDetail),
  resolve: { book: bookDetailResolver }
  // 'book' is the key — accessed as route.snapshot.data['book']
}

// In the component — data is already there, no loading state needed:
export class BookDetail implements OnInit {
  private route = inject(ActivatedRoute);
  book!: Book;

  ngOnInit() {
    this.book = this.route.snapshot.data['book'];
    // Data is pre-loaded — component renders immediately with full data
  }
}
```

---

## 3.9 Navigation Extras

```typescript
const router = inject(Router);

// Navigate with query params:
router.navigate(['/books'], { queryParams: { page: 2, sort: 'price' } });

// Navigate preserving current query params:
router.navigate(['/books', bookId], { queryParamsHandling: 'preserve' });

// Replace current history entry (back button won't go back):
router.navigate(['/auth/login'], { replaceUrl: true });
// Used after logout — user shouldn't be able to go "back" to their profile

// Skip adding to browser history:
router.navigate(['/books'], { skipLocationChange: true });
// URL doesn't change — useful for internal redirects

// Pass state (not visible in URL — disappears on refresh):
router.navigate(['/order-confirmation'], {
  state: { orderId: '12345', total: 99.99 }
});

// Read state in destination component:
const navigation = this.router.getCurrentNavigation();
const state = navigation?.extras.state as { orderId: string; total: number };
// OR after navigation (in ngOnInit):
const state = history.state;
```

---

## 3.10 RouterLink Advanced

```html
<!-- Absolute path: -->
<a routerLink="/books">Books</a>

<!-- With params: -->
<a [routerLink]="['/books', book._id]">View Book</a>
<!-- Result: /books/abc123 -->

<!-- With query params: -->
<a [routerLink]="['/books']" [queryParams]="{ page: 2, sort: 'title' }">
  Browse
</a>
<!-- Result: /books?page=2&sort=title -->

<!-- With fragment (#section): -->
<a [routerLink]="['/about']" fragment="team">Meet the Team</a>
<!-- Result: /about#team -->

<!-- Relative navigation (inside child route): -->
<a routerLink="./orders">My Orders</a>
<!-- . means relative to current route — if on /profile, goes to /profile/orders -->

<!-- routerLinkActive — add class when route is active: -->
<a routerLink="/books" routerLinkActive="active-link">Books</a>
<!-- 'active-link' class is added when current URL starts with /books -->

<!-- Exact match only: -->
<a routerLink="/" routerLinkActive="active-link" [routerLinkActiveOptions]="{ exact: true }">
  Home
</a>
<!-- Without exact: true, this would be active on EVERY route (every URL contains /) -->
```

---

## 3.11 Bookstore Application: Book Detail Page

```typescript
// app.routes.ts — add book detail route:
{
  path: 'books',
  children: [
    {
      path: '',
      loadComponent: () => import('./features/books/book-list/book-list').then(c => c.BookList),
    },
    {
      path: ':id',
      loadComponent: () => import('./features/books/book-detail/book-detail').then(c => c.BookDetail),
    }
  ]
}
```

```typescript
// book-detail.ts
import { Component, OnInit, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { BookService } from '../../../core/services/book.service';
import { Book } from '../../../core/models/book.model';

@Component({
  selector: 'app-book-detail',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './book-detail.html',
})
export class BookDetail implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private bookService = inject(BookService);

  book = signal<Book | null>(null);
  loading = signal(true);
  error = signal('');

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.router.navigate(['/books']);
      return;
    }

    this.bookService.getBookById(id).subscribe({
      next: (res) => {
        this.book.set(res.data);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set('Book not found');
        this.loading.set(false);
      }
    });
  }
}
```

```html
<!-- book-detail.html -->
@if (loading()) {
  <div class="spinner-overlay">
    <div class="spinner-border" style="color: var(--book-accent)"></div>
  </div>
} @else if (error()) {
  <div class="container py-5 text-center">
    <p class="text-danger">{{ error() }}</p>
    <a routerLink="/books" class="btn btn-book-primary">Back to Books</a>
  </div>
} @else if (book()) {
  <div class="container py-5">
    <a routerLink="/books" class="text-muted text-decoration-none mb-3 d-block">
      ← Back to Books
    </a>
    <h2 class="font-serif">{{ book()!.title }}</h2>
    <p class="text-muted">{{ book()!.description }}</p>
    <h4 class="text-gold">${{ book()!.price }}</h4>
    <button class="btn btn-book-primary">Add to Cart</button>
  </div>
}
```

---

# Quick Reference Card — Communication + Signals + Routing

## Component Communication

```typescript
// Parent → Child
@Input() data!: Type;                    // required input
@Input() data: Type = defaultValue;      // optional with default
@Input({ required: true }) data!: Type;  // compile-time required (Angular 16+)

// Child → Parent
@Output() event = new EventEmitter<Type>();
this.event.emit(value); // in child method

// Parent listens:
(event)="handler($event)"  // $event is the emitted value

// Parent accesses child:
@ViewChild('ref') child!: ChildComponent;
// Use in ngAfterViewInit() or later
```

## Signals

```typescript
const val = signal(0);        // create
val();                         // read
val.set(5);                    // replace
val.update(v => v + 1);       // compute new from old

const derived = computed(() => val() * 2);  // auto-recalculates
effect(() => { console.log(val()); });       // runs on change
```

## Routing

```typescript
// Route params
this.route.snapshot.paramMap.get('id')       // one-time read
this.route.paramMap.subscribe(p => p.get('id')) // reactive

// Query params
this.route.snapshot.queryParamMap.get('page') // one-time
router.navigate([], { queryParams: { page: 2 }, queryParamsHandling: 'merge' })

// Navigate
router.navigate(['/books', id])
router.navigate(['/auth/login'], { replaceUrl: true })
```

---

*End of Part 4. Saved to outputs.*
*Part 5 covers: Directives + Standalone vs NgModule + Angular Animations*
