# 📘 Angular Complete Guide — Part 1 of 3
## TypeScript Deep Dive + Angular Foundations
> Written for Khaled | Bookstore Project | Angular 21 Standalone

---

# TABLE OF CONTENTS

1. TypeScript — Everything Angular Uses
   - Why TypeScript exists
   - Types and type annotations
   - Interfaces — contracts for your data
   - Union types and literal types
   - Optional fields and optional chaining
   - Non-null assertion operator
   - Generics — one shape for many types
   - Type aliases
   - Decorators — what they are and how Angular uses them
   - Access modifiers (private, public, protected, readonly)

2. Angular Architecture — How It All Works
   - What Angular actually does
   - How an Angular app boots up
   - What "standalone" means in Angular 21
   - The module system (old) vs standalone (new)

3. The @Component Decorator — In Depth
   - Every property explained
   - selector
   - templateUrl vs template
   - styleUrl vs styles
   - imports array
   - standalone: true

4. Dependency Injection — The Full Picture
   - What a dependency is
   - The problem DI solves
   - How Angular's injector works
   - @Injectable and providedIn
   - The inject() function vs constructor injection
   - Injection tokens
   - Singleton pattern explained

5. Change Detection — How Angular Knows What to Re-render
   - The default change detection strategy
   - Zone.js and what it does
   - Zoneless change detection (Angular 18+)
   - Signals (brief intro)
   - OnPush strategy

6. Angular Template Syntax — Every Notation Explained
   - Text interpolation {{ }}
   - Property binding [ ]
   - Event binding ( )
   - Two-way binding [( )]
   - Attribute binding vs property binding
   - Class binding and style binding
   - @if — conditional rendering
   - @else and @else if
   - @for — loops
   - @empty inside @for
   - @switch and @case
   - Template reference variables #
   - The async pipe
   - Pipes in general

7. Component Lifecycle Hooks — Every Hook Explained
   - The full order of execution
   - constructor
   - ngOnChanges
   - ngOnInit
   - ngDoCheck
   - ngAfterContentInit
   - ngAfterContentChecked
   - ngAfterViewInit
   - ngAfterViewChecked
   - ngOnDestroy
   - When to use which hook

---

---

# CHAPTER 1 — TypeScript: Everything Angular Uses

## 1.1 Why TypeScript Exists

JavaScript was designed in 1995 to add small interactive behaviors to web pages. Nobody expected it to be used to build massive applications with hundreds of files and dozens of developers.

The problem with JavaScript at scale: **it has no types**. A variable can be a number, then a string, then an object — JavaScript doesn't care. This is fine for small scripts. For a 50,000-line application, it's chaos.

```javascript
// JavaScript — no types, no safety
function calculateTotal(price, quantity) {
  return price * quantity;
}

calculateTotal("10", 5); // returns "1010101010" — string repetition, not multiplication!
// JavaScript silently does the wrong thing. No warning. Bug in production.
```

**TypeScript** is JavaScript with a type system layered on top. You add type annotations, and TypeScript checks them at compile time (before your code runs). Bugs that would only appear at runtime in JavaScript are caught while you're writing the code.

```typescript
// TypeScript — types catch the bug immediately
function calculateTotal(price: number, quantity: number): number {
  return price * quantity;
}

calculateTotal("10", 5);
// ❌ TypeScript Error: Argument of type 'string' is not assignable to parameter of type 'number'
// You see this in your editor BEFORE running the code.
```

Angular is written in TypeScript. Your entire project is TypeScript. Understanding it is not optional.

---

## 1.2 Types and Type Annotations

A **type annotation** is a colon followed by a type, placed after a variable name.

```typescript
// Basic type annotations
let name: string = "Khaled";
let age: number = 25;
let isLoggedIn: boolean = false;
let scores: number[] = [90, 85, 78];    // array of numbers
let tags: string[] = ["angular", "ts"]; // array of strings

// You can also write arrays like this (equivalent):
let scores2: Array<number> = [90, 85, 78];
```

**Type inference** — TypeScript is smart enough to infer the type from the assigned value. You don't always have to write the annotation:

```typescript
let name = "Khaled"; // TypeScript infers: string
let age = 25;        // TypeScript infers: number

name = 42; // ❌ Error: Type 'number' is not assignable to type 'string'
// TypeScript remembered "name is a string" even though you didn't say so explicitly
```

**The `any` type** — TypeScript's escape hatch. It turns off type checking for that variable. Avoid it whenever possible.

```typescript
let data: any = "hello";
data = 42;        // fine
data = { x: 1 };  // fine
data.doesntExist; // fine — TypeScript shuts up about anything typed as any
// Using any defeats the purpose of TypeScript
```

**The `void` type** — used for functions that don't return anything:

```typescript
function logout(): void {
  localStorage.removeItem('token');
  // no return statement — this function just performs an action
}
```

**The `null` and `undefined` types:**

```typescript
let token: string | null = null; // can be a string OR null
token = "eyJhbGci..."; // now it's a string — valid
token = null;          // valid — back to null
```

---

## 1.3 Interfaces — Contracts for Your Data

An **interface** defines the shape of an object. It's a contract: any variable of this type MUST have these fields with these types.

```typescript
// Define the shape
interface Book {
  _id: string;
  title: string;
  price: number;
  inStock: boolean;
}

// Use the shape
const book: Book = {
  _id: "abc123",
  title: "Clean Code",
  price: 29.99,
  inStock: true,
};

// TypeScript now enforces the shape
book.tittle;  // ❌ Error: Property 'tittle' does not exist on type 'Book'
              //          Did you mean 'title'?

const incomplete: Book = {
  _id: "123",
  title: "Some Book",
  // ❌ Error: Property 'price' is missing
  // ❌ Error: Property 'inStock' is missing
};
```

**Interfaces vs Classes** — an interface is ONLY a TypeScript construct. It doesn't exist in the compiled JavaScript. It's purely for type checking during development. A class creates actual runtime code.

```typescript
interface User {
  email: string;
  firstName: string;
}
// After TypeScript compiles → this interface completely disappears from JavaScript output

class UserService {
  login() { ... }
}
// After TypeScript compiles → this becomes actual JavaScript code
```

**Extending interfaces** — one interface can extend another:

```typescript
interface BaseEntity {
  _id: string;
  createdAt: string;
}

interface User extends BaseEntity {
  email: string;
  firstName: string;
  // User also gets _id and createdAt from BaseEntity
}

// A User now needs: _id, createdAt, email, firstName
```

---

## 1.4 Union Types and Literal Types

**Union type** — a value can be one of several types:

```typescript
// This variable can be a string OR null — nothing else
let token: string | null = null;

// This variable can be a number OR a string
let id: number | string = 42;
id = "abc123"; // also valid
```

**Literal types** — restrict a value to exact specific strings or numbers:

```typescript
// This role can ONLY be 'user' or 'admin' — no other string is allowed
type Role = 'user' | 'admin';

let userRole: Role = 'user';   // ✅ valid
userRole = 'admin';             // ✅ valid
userRole = 'moderator';         // ❌ Error: Type '"moderator"' is not assignable to type 'Role'

// Used in interfaces:
interface User {
  role: 'user' | 'admin'; // inline union literal type
}
```

**Why this matters in your project:**

In your `User` interface you have:
```typescript
role: 'user' | 'admin';
```

This means TypeScript will catch any comparison you write that can never be true:
```typescript
if (user.role === 'superadmin') {
  // ❌ TypeScript warning: This condition will always be false
  // because 'superadmin' is not in the union type
}
```

---

## 1.5 Optional Fields and Optional Chaining

**Optional field** — a field that may or may not exist on an object:

```typescript
interface Review {
  _id: string;
  rating: number;
  comment?: string; // the ? means: this field might be undefined
}

// Both of these are valid:
const reviewWithComment: Review = { _id: "1", rating: 5, comment: "Great book!" };
const reviewWithoutComment: Review = { _id: "2", rating: 4 }; // no comment — that's fine
```

**Optional chaining (`?.`)** — safely access properties on values that might be null or undefined:

```typescript
const user = auth.getCurrentUser(); // might return null

// Without optional chaining — crashes if user is null:
console.log(user.firstName); // ❌ TypeError: Cannot read properties of null

// With optional chaining — returns undefined safely if user is null:
console.log(user?.firstName); // returns undefined, does NOT crash

// Chaining multiple levels:
console.log(user?.address?.city); // safe even if user or address is null/undefined
```

**In your project you use this constantly:**

```typescript
// In login.html:
@if (loginForm.get('email')?.touched && loginForm.get('email')?.invalid)
//                           ^                              ^
// .get() might return null — ?. prevents crash if it does

// In auth.service.ts:
return this.getCurrentUser()?.role === 'admin';
//                          ^
// getCurrentUser() might return null — ?. returns undefined which !== 'admin'
```

---

## 1.6 Non-Null Assertion Operator (`!`)

Sometimes YOU know a value isn't null, but TypeScript doesn't. The `!` operator tells TypeScript: "trust me, this is not null."

```typescript
// TypeScript says: loginForm.value.email is string | null | undefined
// You know it's not null because the form is valid before you reach this line
const email = this.loginForm.value.email!; // the ! removes null/undefined from the type
//                                     ^
// TypeScript now treats email as: string (not string | null | undefined)
```

**Warning:** only use `!` when you are absolutely sure the value cannot be null/undefined. If you're wrong, you get a runtime crash with no warning.

```typescript
const element = document.getElementById('myId')!;
// Fine if you know that element exists in the DOM
// If the element doesn't exist, this crashes at runtime — TypeScript won't warn you
```

---

## 1.7 Generics — One Shape for Many Types

A **generic** is a type placeholder. It lets you write code that works with any type while still being type-safe.

**Without generics — repetition:**

```typescript
function getFirstString(arr: string[]): string {
  return arr[0];
}

function getFirstNumber(arr: number[]): number {
  return arr[0];
}

// Two functions doing the SAME thing for different types — wasteful
```

**With generics — write once, works for all types:**

```typescript
function getFirst<T>(arr: T[]): T {
  return arr[0];
}

// T is a placeholder — TypeScript replaces it with the actual type when you call the function
getFirst<string>(['a', 'b', 'c']); // T becomes string — returns string
getFirst<number>([1, 2, 3]);       // T becomes number — returns number

// TypeScript can often infer T automatically:
getFirst(['a', 'b', 'c']); // TypeScript infers T = string from the argument
```

**Generics in interfaces — used in your ApiResponse model:**

```typescript
interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T; // T is replaced with whatever you pass when using this interface
}

// Using the interface:
const userResponse: ApiResponse<User> = {
  success: true,
  message: "ok",
  data: { _id: "1", email: "k@test.com", firstName: "Khaled", ... }
  //     ^ TypeScript knows this must be a User object
};

const booksResponse: ApiResponse<Book[]> = {
  success: true,
  message: "ok",
  data: [{ _id: "1", title: "Clean Code", ... }]
  //     ^ TypeScript knows this must be a Book array
};
```

**Why this is powerful:** One interface, infinite possible `data` types. Without generics, you'd write `UserApiResponse`, `BookApiResponse`, `CartApiResponse`, `OrderApiResponse` — all identical except for the `data` type.

---

## 1.8 Type Aliases

A **type alias** creates a new name for a type. Unlike interfaces, type aliases can represent primitives, unions, tuples, and more.

```typescript
// Simple alias for a union type
type ID = string | number;

// Alias for an object type (similar to interface)
type Point = {
  x: number;
  y: number;
};

// Alias for a function type
type LoginFn = (email: string, password: string) => Observable<any>;

// Where interfaces and types differ:
// Interfaces can be extended (merged) — types cannot
// Types can represent unions, tuples, mapped types — interfaces cannot
```

In Angular, you'll mostly use `interface` for object shapes and `type` for union types and function types.

---

## 1.9 Decorators — What They Are and How Angular Uses Them

This is critical. Angular is built almost entirely on decorators. If you don't understand what a decorator IS, Angular will feel like magic.

**A decorator is a function that wraps another function, class, or property and adds behavior to it.**

Think of it like a label you stick on something that changes how that thing behaves.

**Simple decorator concept:**

```typescript
// A decorator is just a function that receives what it decorates
function Log(target: any, key: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${key} with`, args);
    return original.apply(this, args);
  };
  return descriptor;
}

class Calculator {
  @Log // this decorator wraps the add method — every call gets logged
  add(a: number, b: number) {
    return a + b;
  }
}

new Calculator().add(2, 3);
// Console: "Calling add with [2, 3]"
// Returns: 5
```

**Angular's decorators** — Angular provides decorators that transform plain TypeScript classes into Angular-specific things:

```typescript
@Component({...})   // transforms a class into a Component
@Injectable({...})  // transforms a class into a Service (injectable)
@NgModule({...})    // transforms a class into a Module (old way, not used in your project)
@Input()            // transforms a property into an input that accepts data from parent
@Output()           // transforms a property into an output that emits events to parent
@ViewChild()        // transforms a property into a reference to a child element/component
@HostListener()     // transforms a method into a DOM event listener
```

**What `@Component` actually does:**

When TypeScript sees `@Component({...})` on a class, it calls the `Component` function with your class as an argument. Angular's `Component` function:
1. Registers the class in Angular's component registry
2. Stores the metadata (selector, template, styles, imports) on the class
3. Connects the template to the class's properties and methods

Without the decorator, Angular would have no idea your class is a component. It would just be a regular TypeScript class.

---

## 1.10 Access Modifiers

TypeScript (and Angular) uses access modifiers to control who can access class members.

```typescript
class AuthService {
  public apiUrl = 'http://localhost:5000';   // anyone can read and write
  private token = 'secret';                  // ONLY AuthService can access this
  protected baseUrl = '/api';                // AuthService and subclasses can access
  readonly TOKEN_KEY = 'jwt_token';          // anyone can read, nobody can write
}

// Outside the class:
const service = new AuthService();
service.apiUrl;     // ✅ fine
service.token;      // ❌ Error: Property 'token' is private
service.TOKEN_KEY;  // ✅ fine (reading)
service.TOKEN_KEY = 'other'; // ❌ Error: Cannot assign to 'TOKEN_KEY' because it is read-only
```

**In Angular, the convention:**
- `private` for internal service state that components shouldn't touch directly
- `public` (or no modifier, which defaults to public) for methods components call
- `readonly` for constants that shouldn't change after initialization

**The `!` in class properties:**

```typescript
class Navbar {
  private authSub!: Subscription;
  //              ^
  // The ! is "definite assignment assertion"
  // It tells TypeScript: "I promise this will be assigned before it's used"
  // Used when you assign in ngOnInit instead of the constructor
  // Without !, TypeScript complains: "Property 'authSub' has no initializer"
}
```

---

---

# CHAPTER 2 — Angular Architecture: How It All Works

## 2.1 What Angular Actually Does

Angular is a **framework** — it gives you a structured way to build web applications. Unlike a library (like jQuery) that you call when you need it, a framework calls YOUR code. Angular is in charge; your components, services, and guards are the pieces it manages.

Angular handles:
- **Rendering** — taking your TypeScript + HTML and making a real DOM
- **Data binding** — keeping the template in sync with your TypeScript data
- **Routing** — changing what component is shown when the URL changes
- **HTTP** — sending requests to your backend
- **Dependency Injection** — creating and sharing services across components
- **Change Detection** — figuring out when something changed and re-rendering

You don't write a `main()` function that runs everything. You write components and Angular orchestrates when and how they run.

---

## 2.2 How an Angular App Boots Up

When you run `ng serve`, here's what happens step by step:

**Step 1 — `src/index.html` loads:**
```html
<!doctype html>
<html>
  <head>...</head>
  <body>
    <app-root></app-root>  <!-- this is a custom HTML tag — your root component -->
  </body>
</html>
```

**Step 2 — `src/main.ts` runs:**
```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { App } from './app/app';

bootstrapApplication(App, appConfig);
// This tells Angular: "App is the root component, appConfig is the global configuration"
```

**Step 3 — Angular reads `appConfig`:**
```typescript
// app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([...]))
  ]
};
// Angular sets up the router, HTTP client, and all providers listed here
```

**Step 4 — Angular compiles and renders the `App` component:**
```typescript
// app.ts
@Component({
  selector: 'app-root',   // matches <app-root> in index.html
  imports: [RouterOutlet, Navbar],
  templateUrl: './app.html',
})
export class App {}
```

Angular finds `<app-root>` in `index.html`, sees that it matches the `App` component's selector, and renders the component's template inside that tag.

**Step 5 — The router kicks in:**
Angular's router reads the current URL, finds the matching route in `app.routes.ts`, and renders the appropriate component inside `<router-outlet>`.

---

## 2.3 What "Standalone" Means in Angular 21

Before Angular 14, every component had to belong to an `NgModule`. A module was a class that declared which components it owned and which dependencies they needed.

```typescript
// OLD WAY (NgModule) — you do NOT use this in your project
@NgModule({
  declarations: [LoginComponent, RegisterComponent],
  imports: [ReactiveFormsModule, HttpClientModule, RouterModule],
  // If you forgot to add ReactiveFormsModule here, ALL form components broke
})
export class AuthModule {}
```

This was confusing because: if you needed `ReactiveFormsModule` in your component, you didn't import it in the component — you imported it in the MODULE, and then your component magically had access to it. The link between "my component needs X" and "X is available" was invisible and indirect.

**Standalone components (Angular 14+, the default in Angular 17+):**

```typescript
// NEW WAY (Standalone) — what your project uses
@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink, CommonModule],
  // The component DIRECTLY declares what it needs — no middleman module
  templateUrl: './login.html',
})
export class Login {}
```

Now every component is self-contained. It declares its own imports. There's no mystery about where things come from.

**In Angular 21, `standalone: true` is the default.** You technically don't need to write it, but it's good practice to include it for clarity.

---

---

# CHAPTER 3 — The @Component Decorator, In Depth

## 3.1 Every Property Explained

```typescript
@Component({
  // 1. selector — the HTML tag name that represents this component
  selector: 'app-login',

  // 2. standalone — this component manages its own dependencies (no NgModule needed)
  standalone: true,

  // 3. imports — what this component needs to use in its template
  imports: [CommonModule, ReactiveFormsModule, RouterLink],

  // 4. templateUrl — path to the HTML file (relative to this file)
  templateUrl: './login.html',

  // 4b. OR use template inline (for small templates):
  // template: '<p>Hello {{ name }}</p>',

  // 5. styleUrl — path to the CSS file
  styleUrl: './login.css',

  // 5b. OR use styles inline:
  // styles: ['.my-class { color: red; }'],

  // 6. changeDetection — how Angular decides when to re-render (covered later)
  // changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {}
```

---

### The `selector` property

The selector defines how you USE this component in another template.

```typescript
selector: 'app-navbar'
// Usage: <app-navbar></app-navbar>

selector: 'app-book-card'
// Usage: <app-book-card></app-book-card>

// Selectors can also be CSS selectors:
selector: '[appHighlight]'  // attribute selector
// Usage: <p appHighlight>text</p>

selector: '.my-widget'  // class selector
// Usage: <div class="my-widget"></div>
```

By convention, Angular component selectors always start with `app-` (or a custom prefix you define in `.angular.json`) to avoid conflicts with standard HTML tags.

---

### The `imports` array

This is where you declare what your component uses in its template. If something is missing from here, Angular will show a compilation error like "X is not a known element" or "Can't bind to 'Y'".

```typescript
imports: [
  CommonModule,          // NgIf, NgFor, NgClass, NgStyle (old directives — less needed in Angular 17+)
  ReactiveFormsModule,   // [formGroup], formControlName — needed for reactive forms
  FormsModule,           // [(ngModel)] — needed for template-driven forms
  RouterLink,            // routerLink="/books" — navigation links
  RouterLinkActive,      // routerLinkActive="active-class" — highlights active link
  HttpClientModule,      // DEPRECATED — use provideHttpClient() in app.config.ts instead
  AsyncPipe,             // | async — unwrap Observables in templates
]
```

**The most common error:** You try to use `[formGroup]` in your template but forgot `ReactiveFormsModule` in `imports`. Angular shows: `Can't bind to 'formGroup' since it isn't a known property of 'form'`.

---

---

# CHAPTER 4 — Dependency Injection: The Full Picture

## 4.1 What a "Dependency" Is

A **dependency** is anything a class needs to do its job.

```typescript
class Login {
  // Login needs AuthService to call login()
  // Login needs Router to navigate after login
  // These are Login's DEPENDENCIES
}
```

The naive way to get dependencies — create them yourself:

```typescript
class Login {
  private auth = new AuthService(new HttpClient(...), new Router(...));
  private router = new Router(...);
}
```

This is terrible because:
1. **Tight coupling** — Login is responsible for creating AuthService. If AuthService's constructor changes (needs a new parameter), you must update Login too.
2. **No sharing** — every component creates its own AuthService. There's no single shared state.
3. **Untestable** — you can't swap out the real AuthService with a fake one for testing.

---

## 4.2 The Problem DI Solves

**Dependency Injection** means: instead of a class creating its own dependencies, the framework creates them and hands them in.

```typescript
class Login {
  constructor(private auth: AuthService, private router: Router) {
    // Login does NOT create AuthService — it just asks for one
    // Angular's injector creates it and passes it in
  }
}
```

Now:
1. **Loose coupling** — Login doesn't know HOW AuthService is created. It just knows it gets one.
2. **Sharing** — Angular creates AuthService ONCE and gives the same instance to everyone who asks (singleton).
3. **Testable** — in tests, you can tell Angular to pass a fake AuthService instead.

---

## 4.3 How Angular's Injector Works

Angular maintains a registry called the **injector**. The injector is a map of "token → instance".

When a component or service asks for something:
1. Angular looks at the constructor parameters (or `inject()` calls)
2. Angular sees the type — e.g., `AuthService`
3. Angular checks the injector registry: "do I have an instance of AuthService?"
4. If YES: return the existing instance (singleton)
5. If NO: create a new instance, store it, return it

```
Login component is created
    ↓
Angular sees: constructor(private auth: AuthService)
    ↓
Angular checks injector: "do I have AuthService?"
    ↓
  NO — create new AuthService
     → AuthService needs HttpClient and Router
     → Angular checks injector for those, creates them if needed
     → Injects them into AuthService
     → AuthService is now ready
  YES — return existing AuthService instance
    ↓
Angular passes AuthService to Login
    ↓
Login is ready
```

---

## 4.4 @Injectable and providedIn

For Angular to manage a class in its injector, the class needs `@Injectable`:

```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  // ...
}
```

**`providedIn: 'root'`** means: register this service in the ROOT injector — the one that's shared by the entire application. This gives you a true singleton: one instance for the whole app.

**Other options:**

```typescript
@Injectable({ providedIn: 'root' })
// ONE instance for the whole app
// Every component that injects this gets the SAME object

@Injectable({ providedIn: 'any' })
// A NEW instance for each lazy-loaded module
// Rarely used

// Or register manually in app.config.ts providers:
providers: [
  { provide: SomeService, useClass: SomeService }
]
// Same effect as providedIn: 'root' but explicit in config
```

---

## 4.5 The `inject()` Function vs Constructor Injection

Angular 14+ introduced the `inject()` function as an alternative to constructor injection.

**Constructor injection (classic way):**
```typescript
export class Login {
  constructor(
    private auth: AuthService,
    private router: Router,
    private formBuilder: FormBuilder
  ) {}
}
// As more dependencies are added, the constructor grows large
// Order of parameters matters and can be confusing
```

**inject() function (modern way — what your project uses):**
```typescript
export class Login {
  private auth = inject(AuthService);
  private router = inject(Router);
  // Each dependency is declared as a class property
  // Clear, flat structure — no constructor needed
  // Order doesn't matter
}
```

Both approaches are valid in Angular 21. Your project mixes both:
- Services use `inject()` where possible (modern, clean)
- Components with forms often use the constructor (still perfectly fine)

**One rule:** `inject()` can ONLY be called in an **injection context** — during class field initialization, in a constructor, or in factory functions. You cannot call it inside a method:

```typescript
class MyService {
  private http = inject(HttpClient); // ✅ class field — injection context

  getData() {
    const http = inject(HttpClient); // ❌ Error: inject() must be called in an injection context
  }
}
```

---

## 4.6 The Singleton Pattern in Practice

**Proof that services are singletons:**

```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  instanceId = Math.random(); // a unique number when this instance is created
}

// In component A:
const auth = inject(AuthService);
console.log(auth.instanceId); // e.g. 0.7342

// In component B:
const auth = inject(AuthService);
console.log(auth.instanceId); // same: 0.7342 — SAME instance!
```

This is why `BehaviorSubject` works for shared state. When Login calls `this.loggedIn$.next(true)`, the Navbar (which has the SAME service instance) immediately sees the new value through its subscription.

---

---

# CHAPTER 5 — Change Detection: How Angular Knows What to Re-render

## 5.1 The Problem Angular Solves

When you do `this.isLoggedIn = true` in TypeScript, how does Angular know to re-render the navbar template?

In vanilla JavaScript, nothing happens automatically. You'd have to manually update the DOM: `document.querySelector('.cart-link').style.display = 'block'`.

Angular detects your changes and updates the DOM for you. But HOW?

---

## 5.2 Zone.js — The Classic Approach

Angular (before v18 zoneless) uses a library called **Zone.js** to detect changes. Zone.js monkey-patches (overrides) all asynchronous browser APIs:

- `setTimeout`, `setInterval`
- `Promise.then`
- DOM event listeners (`addEventListener`)
- HTTP requests (`XMLHttpRequest`)

When any of these complete, Zone.js notifies Angular: "something async just finished — there might be changes." Angular then runs change detection: it compares the current state of all template-bound variables against what was previously rendered, and updates the DOM where needed.

```typescript
// This is what happens when you click the login button:
submitLogin() {
  this.loading = true;   // ← Zone.js sees this change
  // Angular schedules a change detection run
  // Template re-renders: button becomes disabled, spinner appears

  this.auth.login(email, password).subscribe({
    next: () => {
      this.router.navigate(['/books']);
      // Zone.js sees the Promise from navigate() resolve
      // Angular runs change detection again
    }
  });
}
```

---

## 5.3 Zoneless Change Detection (Angular 18+)

Your project uses `provideZonelessChangeDetection()` in `app.config.ts`. This is the NEW approach (available from Angular 18, stable in Angular 19+).

Without Zone.js, Angular no longer automatically detects changes. You must explicitly tell Angular when to re-render using:
1. **Signals** (Angular 16+) — reactive primitives that Angular tracks
2. **Manual marking** with `ChangeDetectorRef.markForCheck()`

```typescript
// Zoneless with Signals:
loading = signal(false);   // signal() creates a reactive value
// When signal value changes, Angular automatically re-renders template

// In template:
@if (loading()) {  // calling signal like a function reads its value
  <spinner></spinner>
}

// In TypeScript:
this.loading.set(true);  // .set() changes the value AND triggers re-render
```

**For your project:** The components use plain boolean properties (`loading = false`) which work with both Zone.js and zoneless because Angular's HTTP client and Router internally use signals or explicit change detection notification. For any new component you write, prefer signals if possible — but plain booleans work fine for this project's scope.

---

## 5.4 ChangeDetectionStrategy.OnPush

By default, Angular re-runs change detection on a component whenever ANYTHING changes anywhere in the application. For large apps with hundreds of components, this is slow.

`OnPush` tells Angular: "only re-check this component if:
1. Its `@Input()` values change
2. An event originates from this component
3. An Observable it's subscribed to emits (via async pipe)
4. You manually call `markForCheck()`"

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  // ...
})
export class BookCard {
  @Input() book!: Book; // only re-renders when this input changes
}
```

Your project doesn't use `OnPush` explicitly (it would add complexity for a first project), but knowing it exists is important.

---

---

# CHAPTER 6 — Angular Template Syntax: Every Notation

## 6.1 Text Interpolation `{{ }}`

Double curly braces display a TypeScript expression as text in the template.

```html
<!-- Basic variable -->
<h1>{{ title }}</h1>
<!-- If title = "Bookstore", renders: <h1>Bookstore</h1> -->

<!-- Property access -->
<p>{{ user.firstName }}</p>

<!-- Expression (evaluated) -->
<p>{{ 2 + 2 }}</p>      <!-- renders: 4 -->
<p>{{ 'hello'.toUpperCase() }}</p>  <!-- renders: HELLO -->

<!-- Ternary -->
<p>{{ isLoggedIn ? 'Welcome back!' : 'Please log in' }}</p>

<!-- Method call -->
<p>{{ getFullName() }}</p>
```

**What you CANNOT do in interpolation:**
```html
<!-- No assignments -->
{{ x = 5 }}  <!-- ❌ not allowed -->

<!-- No new keyword -->
{{ new Date() }}  <!-- ❌ not allowed — use a pipe instead -->

<!-- No increment/decrement -->
{{ i++ }}  <!-- ❌ not allowed -->
```

---

## 6.2 Property Binding `[ ]`

Square brackets bind a TypeScript expression to a DOM property or component input.

```html
<!-- Disable a button based on a variable -->
<button [disabled]="loading">Submit</button>
<!-- When loading = true  → button becomes disabled -->
<!-- When loading = false → button is enabled -->

<!-- Set the src of an image -->
<img [src]="book.coverImageUrl" />
<!-- Equivalent to: element.src = book.coverImageUrl -->

<!-- Set an Angular component's @Input -->
<app-book-card [book]="selectedBook"></app-book-card>
<!-- Passes the selectedBook object to BookCard's @Input() book property -->

<!-- Conditional class — add class 'active' when condition is true -->
<li [class.active]="currentPage === 1">Page 1</li>

<!-- Conditional style -->
<div [style.color]="isError ? 'red' : 'green'">Message</div>
```

**Property vs Attribute:**

This is a subtle but important distinction:

```html
<!-- Attribute (static, in HTML source): -->
<input value="hello" />
<!-- Sets the INITIAL value. After user types, attribute doesn't update. -->

<!-- Property binding (dynamic, in JavaScript): -->
<input [value]="myVariable" />
<!-- Binds to the DOM property — updates dynamically when myVariable changes -->
```

Most of the time, property binding does what you want. But some HTML attributes don't have corresponding DOM properties. For those, use `attr.`:

```html
<td [attr.colspan]="2">Cell spanning 2 columns</td>
<!-- colspan is an HTML attribute, not a DOM property -->
<!-- Without attr. prefix, Angular would look for a 'colspan' DOM property (doesn't exist) -->
```

---

## 6.3 Event Binding `( )`

Parentheses listen to DOM events and call TypeScript methods.

```html
<!-- Click event -->
<button (click)="submitLogin()">Sign In</button>

<!-- Input event (fires on every keystroke) -->
<input (input)="onInput($event)" />

<!-- Change event (fires when input loses focus with a new value) -->
<input (change)="onChange($event)" />

<!-- Form submit (fires when form is submitted) -->
<form (ngSubmit)="submitLogin()">

<!-- Key events -->
<input (keyup.enter)="search()" />  <!-- only fires on Enter key -->
<input (keydown.escape)="cancel()" />
```

**The `$event` object:**

`$event` is the DOM event object. What it contains depends on the event type:

```typescript
onInput(event: Event) {
  const input = event.target as HTMLInputElement;
  console.log(input.value); // current value in the input field
}

onClick(event: MouseEvent) {
  console.log(event.clientX, event.clientY); // click position
}
```

**Custom events from child components:**

```typescript
// In child component (BookCard):
@Output() addToCart = new EventEmitter<Book>();

onAddClick() {
  this.addToCart.emit(this.book); // emits the book object
}
```

```html
<!-- In parent template: -->
<app-book-card [book]="b" (addToCart)="handleAddToCart($event)"></app-book-card>
<!-- $event here is the Book object that was emitted -->
```

---

## 6.4 Two-Way Binding `[( )]`

Two-way binding is a combination of property binding and event binding. The variable updates when the input changes, AND the input updates when the variable changes.

The syntax `[()]` is nicknamed "banana in a box."

```html
<!-- Two-way binding with ngModel (requires FormsModule) -->
<input [(ngModel)]="username" />

<!-- This is equivalent to: -->
<input [value]="username" (input)="username = $event.target.value" />
```

**You don't use `[(ngModel)]` in your project.** Your project uses **Reactive Forms**, which manage binding differently through `formControlName`. Two-way binding with `ngModel` is for **Template-Driven Forms** (a different approach). Don't mix them.

---

## 6.5 Class Binding and Style Binding

**Class binding** — conditionally add/remove CSS classes:

```html
<!-- Add class 'active-link' when condition is true -->
<a [class.active-link]="isCurrentRoute">Books</a>

<!-- Bind multiple classes with an object -->
<div [ngClass]="{
  'text-success': isValid,
  'text-danger': isError,
  'fw-bold': isImportant
}">Status</div>
```

**Style binding** — set inline styles:

```html
<!-- Set a single style property -->
<div [style.color]="isError ? 'red' : 'black'">Message</div>
<div [style.font-size.px]="fontSize">Text</div>  <!-- .px unit suffix -->

<!-- Set multiple styles with an object -->
<div [ngStyle]="{
  'color': textColor,
  'font-size': fontSize + 'px',
  'font-weight': isBold ? 'bold' : 'normal'
}">Styled text</div>
```

In your project, most styling uses static Bootstrap classes. You'll mainly use class binding for things like the active navigation link.

---

## 6.6 `@if` — Conditional Rendering

Angular 17+ introduced a new control flow syntax. `@if` replaces the old `*ngIf` directive.

```html
<!-- Basic @if -->
@if (isLoggedIn) {
  <p>Welcome back!</p>
}
<!-- If isLoggedIn is false, <p> doesn't exist in the DOM at all (not just hidden) -->

<!-- @if with @else -->
@if (isLoggedIn) {
  <button (click)="logout()">Logout</button>
} @else {
  <a routerLink="/auth/login">Sign In</a>
}

<!-- @if with @else if -->
@if (loading) {
  <span class="spinner-border"></span>
} @else if (error) {
  <div class="alert alert-danger">{{ error }}</div>
} @else {
  <div class="content">{{ data }}</div>
}
```

**The key difference from CSS `display: none`:**

`@if` removes the element from the DOM entirely when the condition is false. `display: none` hides it but it still exists in the DOM and its change detection still runs. `@if` is more performant for complex conditional blocks.

---

## 6.7 `@for` — Loops

`@for` replaces the old `*ngFor` directive.

```html
<!-- Basic @for -->
@for (book of books; track book._id) {
  <div class="book-card">{{ book.title }}</div>
}
```

**The `track` clause is REQUIRED in Angular 17+.** It tells Angular how to identify each item in the list, so Angular can efficiently update only the items that changed (instead of destroying and recreating the entire list).

```html
<!-- Always track by a unique ID -->
@for (book of books; track book._id) { ... }
@for (user of users; track user._id) { ... }

<!-- If items don't have IDs, you can track by the item itself: -->
@for (name of names; track name) { ... }

<!-- Or by index (least efficient, last resort): -->
@for (item of items; track $index) { ... }
```

**Loop variables available inside @for:**

```html
@for (book of books; track book._id; let i = $index, let isFirst = $first, let isLast = $last, let isEven = $even) {
  <div [class.first-item]="isFirst" [class.last-item]="isLast">
    {{ i + 1 }}. {{ book.title }}
  </div>
}
```

Available loop variables:
- `$index` — zero-based position (0, 1, 2...)
- `$first` — true for the first item
- `$last` — true for the last item
- `$even` — true for items at even indexes (0, 2, 4...)
- `$odd` — true for items at odd indexes (1, 3, 5...)
- `$count` — total number of items

---

## 6.8 `@empty` Inside `@for`

```html
@for (book of books; track book._id) {
  <app-book-card [book]="book"></app-book-card>
} @empty {
  <p class="text-muted">No books found.</p>
}
<!-- @empty renders when the books array is empty or null -->
```

---

## 6.9 `@switch` and `@case`

For when you have many conditions:

```html
@switch (order.status) {
  @case ('processing') {
    <span class="badge bg-warning">Processing</span>
  }
  @case ('out_for_delivery') {
    <span class="badge bg-info">Out for Delivery</span>
  }
  @case ('delivered') {
    <span class="badge bg-success">Delivered</span>
  }
  @default {
    <span class="badge bg-secondary">Unknown</span>
  }
}
```

---

## 6.10 Template Reference Variables `#`

A template reference variable gives you a reference to a DOM element or component.

```html
<!-- Reference to an input element -->
<input #emailInput type="email" />
<button (click)="focusInput(emailInput)">Focus</button>
<!-- emailInput is now the actual HTMLInputElement — you can call .focus(), .value, etc. -->

<!-- Reference to an Angular component -->
<app-some-modal #modal></app-some-modal>
<button (click)="modal.open()">Open Modal</button>
<!-- modal is the component instance — you can call its public methods -->
```

In TypeScript, you can access template references using `@ViewChild`:

```typescript
@ViewChild('emailInput') emailInputRef!: ElementRef;

ngAfterViewInit() {
  this.emailInputRef.nativeElement.focus(); // focus the input when view loads
}
```

---

## 6.11 Pipes

Pipes transform displayed values without changing the underlying data.

```html
{{ user.createdAt | date:'MMM d, y' }}      <!-- "Jan 15, 2024" -->
{{ book.price | currency:'USD' }}             <!-- "$29.99" -->
{{ book.title | uppercase }}                  <!-- "CLEAN CODE" -->
{{ book.title | lowercase }}                  <!-- "clean code" -->
{{ book.title | titlecase }}                  <!-- "Clean Code" -->
{{ longText | slice:0:100 }}                  <!-- first 100 characters -->
{{ bigNumber | number:'1.2-2' }}              <!-- "1,234.50" -->
{{ obj | json }}                              <!-- JSON string — useful for debugging -->
```

**The `async` pipe — very important:**

```html
<!-- Without async pipe (manual subscribe in TypeScript): -->
<!-- TypeScript: this.books$ = this.bookService.getBooks() -->
<!-- TypeScript: ngOnInit() { this.books$.subscribe(books => this.books = books) } -->
<div @for (book of books; track book._id) { ... }</div>

<!-- With async pipe (no subscribe needed in TypeScript): -->
<!-- TypeScript: books$ = this.bookService.getBooks() -->
<div @for (book of (books$ | async) ?? []; track book._id) { ... }</div>
<!-- The async pipe: subscribes to the Observable, renders value when it arrives,
     and automatically UNSUBSCRIBES when the component is destroyed (no memory leaks!) -->
```

The `async` pipe is a memory-safe way to use Observables in templates. It handles the full lifecycle automatically.

---

---

# CHAPTER 7 — Component Lifecycle Hooks

## 7.1 What Are Lifecycle Hooks?

Angular creates, updates, and destroys components. At each stage, it calls specific methods on your component class — if those methods exist. These are lifecycle hooks.

You "hook into" a lifecycle phase by implementing the method. If you don't need a phase, you simply don't implement it.

---

## 7.2 The Full Order of Execution

When a component is created and rendered for the first time:

```
1. constructor()           — class is instantiated
2. ngOnChanges()           — @Input() values are set (if component has inputs)
3. ngOnInit()              — component is initialized
4. ngDoCheck()             — change detection runs
5. ngAfterContentInit()    — projected content (<ng-content>) is initialized
6. ngAfterContentChecked() — projected content is checked
7. ngAfterViewInit()       — component's own view (and child views) is initialized
8. ngAfterViewChecked()    — component's view is checked
```

On every subsequent change detection cycle:
```
2. ngOnChanges()           — if @Input() values changed
4. ngDoCheck()             — always
6. ngAfterContentChecked() — always
8. ngAfterViewChecked()    — always
```

When the component is removed:
```
9. ngOnDestroy()           — cleanup before removal
```

---

## 7.3 constructor

```typescript
export class Login {
  private auth: AuthService;

  constructor(auth: AuthService) {
    this.auth = auth;
    // Angular calls this first
    // Use it for: injecting dependencies
    // Do NOT use it for: API calls, DOM access, complex initialization
    // At this point, @Input() values are NOT set yet, view is NOT rendered
  }
}

// Modern equivalent with inject():
export class Login {
  private auth = inject(AuthService);
  // inject() is called during field initialization — before the constructor
  // No constructor needed for simple injection
}
```

---

## 7.4 ngOnChanges

```typescript
import { OnChanges, SimpleChanges, Input } from '@angular/core';

export class BookCard implements OnChanges {
  @Input() book!: Book;

  ngOnChanges(changes: SimpleChanges) {
    // Called EVERY TIME an @Input() value changes from the parent
    // Also called BEFORE ngOnInit (on the very first render)
    // NOTE: does NOT fire if you mutate an object (must be a new reference)

    if (changes['book']) {
      const previous = changes['book'].previousValue;
      const current = changes['book'].currentValue;
      const isFirst = changes['book'].firstChange; // true on initial render
      console.log(`Book changed from ${previous?.title} to ${current.title}`);
    }
  }
}
```

**When ngOnChanges does NOT fire:**
```typescript
// In parent:
this.book.price = 29.99; // MUTATING the object — ngOnChanges will NOT fire
// Angular checks object REFERENCES, not deep equality

this.book = { ...this.book, price: 29.99 }; // NEW reference — ngOnChanges WILL fire
```

---

## 7.5 ngOnInit

```typescript
import { OnInit } from '@angular/core';

export class Profile implements OnInit {
  userEmail = '';
  profileForm!: FormGroup;

  ngOnInit() {
    // Called ONCE after the first ngOnChanges (if any) and after the constructor
    // @Input() values ARE set at this point
    // View is NOT yet rendered
    //
    // Use it for:
    // ✅ API calls to load initial data
    // ✅ Pre-filling forms with existing data
    // ✅ Setting up subscriptions
    // ✅ Complex initialization that depends on @Input values

    const user = this.auth.getCurrentUser();
    if (user) {
      this.userEmail = user.email;
      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName: user.lastName,
      });
    }
  }
}
```

**ngOnInit vs constructor — why the distinction matters:**

```typescript
constructor(private auth: AuthService) {
  // ❌ Don't call APIs here
  // The component isn't fully ready. Inputs aren't set. Angular might destroy
  // the component before it's fully initialized (in some routing scenarios).
  this.auth.getProfile().subscribe(...); // risky
}

ngOnInit() {
  // ✅ Safe to call APIs and use @Input values
  this.auth.getProfile().subscribe(...); // correct
}
```

---

## 7.6 ngOnDestroy

```typescript
import { OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';

export class Navbar implements OnDestroy {
  private authSub!: Subscription;

  ngOnInit() {
    this.authSub = this.auth.authStatus$.subscribe(loggedIn => {
      this.isLoggedIn = loggedIn;
    });
  }

  ngOnDestroy() {
    // Called ONCE just before Angular removes the component from the DOM
    // Use it for: cleaning up to prevent memory leaks
    //
    // Things to clean up:
    // ✅ Unsubscribe from Observables (most important)
    // ✅ Clear intervals/timeouts: clearInterval(this.timer)
    // ✅ Remove DOM event listeners you added manually
    // ✅ Release any external resources

    this.authSub?.unsubscribe();
    // The ?. prevents a crash if authSub was never assigned
    // (e.g., if ngOnInit never ran because the component was destroyed immediately)
  }
}
```

**The memory leak scenario explained:**

```typescript
ngOnInit() {
  this.auth.authStatus$.subscribe(loggedIn => {
    this.isLoggedIn = loggedIn;
    // This anonymous function has a closure over `this`
    // which means it holds a reference to the component
  });
  // Subscription is never stored — will NEVER be unsubscribed
}

// User navigates away → Angular removes Navbar from DOM
// BUT: the subscription is still alive!
// The BehaviorSubject still holds a reference to this callback
// This callback holds a reference to this Navbar instance
// The Navbar instance stays in memory FOREVER — memory leak
// Every time auth state changes, this dead component's callback still runs
```

---

## 7.7 ngAfterViewInit

```typescript
import { AfterViewInit, ViewChild, ElementRef } from '@angular/core';

export class Login implements AfterViewInit {
  @ViewChild('emailInput') emailInputRef!: ElementRef;

  ngAfterViewInit() {
    // Called ONCE after the component's template is fully rendered
    // @ViewChild references ARE available here
    // Use it for: accessing DOM elements, calling methods on child components

    this.emailInputRef.nativeElement.focus(); // auto-focus the email input
  }
}
```

---

## 7.8 Quick Reference — When to Use Which Hook

| Hook | Use Case |
|------|----------|
| `constructor` | Inject dependencies only. Nothing else. |
| `ngOnChanges` | React to `@Input()` changes. Compare previous vs current. |
| `ngOnInit` | First-time setup: API calls, form pre-fill, subscriptions. |
| `ngOnDestroy` | Cleanup: unsubscribe, clear timers, release resources. |
| `ngAfterViewInit` | Access DOM elements via `@ViewChild`. Auto-focus inputs. |
| `ngAfterContentInit` | Access projected content via `@ContentChild`. |
| `ngDoCheck` | Custom change detection. Rarely needed. Heavy performance cost. |

---

---

# Quick Reference Card — TypeScript + Template Syntax

## TypeScript Syntax Quick Reference

```typescript
// Type annotation
let name: string = "Khaled";

// Interface
interface User { _id: string; email: string; role: 'user' | 'admin'; }

// Optional field
interface Review { comment?: string; }

// Generic interface
interface ApiResponse<T> { data: T; success: boolean; }

// Usage: ApiResponse<User>, ApiResponse<Book[]>

// Optional chaining
user?.firstName       // undefined if user is null — does NOT crash

// Non-null assertion
const email = this.form.value.email!  // "trust me it's not null"

// Access modifiers
private token = '';   // only this class
public login() {}     // anyone (default if omitted)
readonly KEY = 'jwt'; // cannot be reassigned

// Definite assignment
private sub!: Subscription; // "I promise this gets assigned before use"
```

## Template Syntax Quick Reference

```html
{{ variable }}                    <!-- text interpolation -->
[property]="expression"           <!-- property binding: TS → DOM -->
(event)="method($event)"          <!-- event binding: DOM → TS -->
[(ngModel)]="variable"            <!-- two-way binding (template-driven forms only) -->
[class.active]="condition"        <!-- conditional class -->
[style.color]="expression"        <!-- style binding -->

@if (condition) { }               <!-- conditional block -->
@if (a) { } @else if (b) { }     <!-- if/else if -->
@if (a) { } @else { }            <!-- if/else -->
@for (x of list; track x.id) { } <!-- loop (track is required) -->
@for (...) { } @empty { }        <!-- loop with empty state -->
@switch (val) { @case (x) { } }  <!-- switch statement -->

#myRef                            <!-- template reference variable -->
value | pipeName                  <!-- pipe transformation -->
value | async                     <!-- async pipe: unwrap Observable -->
```

---

*End of Part 1. Save this file. Part 2 covers RxJS Deep Dive + Services + HTTP + Interceptors + Guards.*
