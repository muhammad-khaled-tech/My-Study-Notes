# 📒 Angular Complete Guide — Part 5 of 9
## Directives + Standalone vs NgModule + Angular Animations
> Hybrid: concept first, then bookstore application

---

# TABLE OF CONTENTS

1. Directives — The Complete Guide
   - What a directive is and how it differs from a component
   - Attribute directives vs structural directives
   - Built-in attribute directives: ngClass, ngStyle, ngModel
   - Built-in structural directives: NgIf, NgFor, NgSwitch (old syntax)
   - New control flow vs old directives (@if vs *ngIf)
   - Building a custom attribute directive
   - Building a custom structural directive
   - Host binding and host listener
   - Directive inputs
   - Bookstore application: a custom highlight directive

2. Standalone vs NgModule — Full Historical Context
   - The history: why NgModule existed
   - What NgModule actually did
   - The problems with NgModule
   - How standalone components work without NgModule
   - Migrating an NgModule app to standalone
   - When you might still encounter NgModule code
   - providedIn vs providers array — the full story
   - Bootstrapping: platformBrowserDynamic vs bootstrapApplication

3. Angular Animations — The Complete Guide
   - Setting up BrowserAnimationsModule / provideAnimations
   - The animations API: trigger, state, style, animate, transition
   - :enter and :leave — element insertion/removal animations
   - keyframes — multi-step animations
   - query and stagger — animating lists
   - AnimationBuilder — programmatic animations
   - Disabling animations
   - Bookstore application: book card entrance, route transition

---

---

# CHAPTER 1 — Directives: The Complete Guide

## 1.1 What Is a Directive?

A **directive** is a class that adds behavior to DOM elements. It is Angular's mechanism for extending HTML with new capabilities.

There are three types:

```
Component          — a directive WITH a template (the most common type)
Attribute Directive — changes the appearance or behavior of an existing element
Structural Directive — changes the structure of the DOM (adds/removes elements)
```

Every `@Component` is technically a directive with a template. When we say "directive" in Angular, we usually mean attribute or structural directives — the ones without their own template.

```html
<!-- Component (has its own template): -->
<app-book-card [book]="book"></app-book-card>

<!-- Attribute directive (modifies an existing element): -->
<p appHighlight>This paragraph gets highlighted behavior</p>

<!-- Structural directive (changes what's in the DOM): -->
<p *ngIf="isVisible">This may or may not be in the DOM</p>
```

---

## 1.2 Built-in Attribute Directives

### ngClass — Dynamic CSS Classes

`ngClass` applies CSS classes conditionally based on expressions.

```html
<!-- Object syntax — keys are class names, values are conditions: -->
<div [ngClass]="{
  'text-success': order.status === 'delivered',
  'text-warning': order.status === 'processing',
  'text-info':    order.status === 'out_for_delivery',
  'fw-bold':      order.isPriority
}">
  {{ order.status }}
</div>

<!-- Array syntax — always apply these classes: -->
<div [ngClass]="['card', 'border-book', isActive ? 'shadow' : '']">

<!-- String syntax — space-separated class names: -->
<div [ngClass]="'card border-book'">

<!-- Method returning an object: -->
<div [ngClass]="getStatusClasses(order)">
```

```typescript
getStatusClasses(order: Order): { [key: string]: boolean } {
  return {
    'text-success': order.status === 'delivered',
    'text-warning': order.status === 'processing',
  };
}
```

**When to use `[class.name]` vs `[ngClass]`:**

```html
<!-- Single class — use [class.name] (simpler): -->
<button [class.active]="isSelected">Click</button>

<!-- Multiple classes — use [ngClass]: -->
<div [ngClass]="{ 'active': isSelected, 'disabled': isDisabled, 'large': isLarge }">
```

---

### ngStyle — Dynamic Inline Styles

`ngStyle` applies inline styles dynamically.

```html
<!-- Object syntax: -->
<div [ngStyle]="{
  'color': book.isNew ? 'green' : 'inherit',
  'font-size': fontSize + 'px',
  'font-weight': isImportant ? 'bold' : 'normal'
}">

<!-- When to use [style.property] vs [ngStyle]: -->
<div [style.color]="textColor">         <!-- single style: use [style.property] -->
<div [ngStyle]="getStyles()">           <!-- multiple styles: use [ngStyle] -->
```

---

### ngModel — Two-Way Binding (Template-Driven Forms)

`ngModel` is the directive that enables two-way binding with `[()]`. It requires `FormsModule`.

```typescript
// In component:
import { FormsModule } from '@angular/forms';

@Component({
  imports: [FormsModule], // required for ngModel
  template: `
    <input [(ngModel)]="searchQuery" placeholder="Search books..." />
    <p>You typed: {{ searchQuery }}</p>
  `
})
export class SearchBar {
  searchQuery = '';
}
```

```html
<!-- Standalone ngModel without two-way binding: -->
<input [ngModel]="searchQuery" (ngModelChange)="onQueryChange($event)" />
<!-- [ngModel] binds the value (one direction: TS → DOM)     -->
<!-- (ngModelChange) fires when value changes (DOM → TS)     -->
<!-- Together they are equivalent to [(ngModel)]             -->
```

**Important:** In your bookstore project you use **Reactive Forms** (`formControlName`), not `ngModel`. Don't mix them — a form input should use either `formControlName` OR `[(ngModel)]`, never both.

---

## 1.3 New Control Flow vs Old Structural Directives

Angular 17 introduced built-in control flow (`@if`, `@for`, `@switch`) that replaces the old `*ngIf`, `*ngFor`, `*ngSwitch` directives.

```html
<!-- OLD way (still works, just older syntax): -->
<div *ngIf="isLoggedIn; else guestBlock">Welcome back!</div>
<ng-template #guestBlock>Please log in</ng-template>

<div *ngFor="let book of books; trackBy: trackByFn; let i = index">
  {{ i }}. {{ book.title }}
</div>

<!-- NEW way (Angular 17+): -->
@if (isLoggedIn) {
  <div>Welcome back!</div>
} @else {
  <div>Please log in</div>
}

@for (book of books; track book._id; let i = $index) {
  <div>{{ i }}. {{ book.title }}</div>
}
```

**Differences and why the new syntax is better:**

```
Old *ngIf: needs ng-template for else — verbose
New @if:   @else block is inline — clean

Old *ngFor: trackBy requires a separate method in TypeScript
New @for:  track inline — one less method to write

Old *ngFor: $implicit variable for the item — confusing name
New @for:  the variable name is explicit (book of books)

Performance: new control flow has better tree-shaking — unused directives
             are not included in the bundle
```

---

## 1.4 Building a Custom Attribute Directive

An attribute directive is applied to an existing element and changes its behavior or appearance.

**Concept: a tooltip directive**

```typescript
// tooltip.directive.ts
import { Directive, ElementRef, HostListener, Input, Renderer2 } from '@angular/core';

@Directive({
  selector: '[appTooltip]',
  // selector with brackets: this is an ATTRIBUTE selector
  // Matches: <any-element appTooltip="...">
  // NOT: <appTooltip> (that would be a component)
  standalone: true,
})
export class TooltipDirective {
  @Input('appTooltip') tooltipText = '';
  // @Input('appTooltip'): the input name matches the directive selector
  // So <button appTooltip="Click to add"> passes "Click to add" as input
  // Internally accessed as: this.tooltipText

  private tooltipElement: HTMLElement | null = null;

  constructor(
    private el: ElementRef,
    // ElementRef: reference to the HOST element (the element the directive is on)
    // this.el.nativeElement: the actual DOM element

    private renderer: Renderer2
    // Renderer2: Angular's abstraction for DOM manipulation
    // ALWAYS use Renderer2 instead of direct DOM manipulation in directives
    // Why? It works in SSR (server-side rendering) where document doesn't exist
  ) {}

  @HostListener('mouseenter')
  // @HostListener: listens to an event on the HOST element (the element the directive is on)
  // 'mouseenter': fires when mouse enters the element
  onMouseEnter() {
    this.showTooltip();
  }

  @HostListener('mouseleave')
  onMouseLeave() {
    this.hideTooltip();
  }

  private showTooltip() {
    this.tooltipElement = this.renderer.createElement('div');
    // renderer.createElement: creates a DOM element safely
    this.renderer.addClass(this.tooltipElement, 'custom-tooltip');
    const text = this.renderer.createText(this.tooltipText);
    this.renderer.appendChild(this.tooltipElement, text);
    this.renderer.appendChild(document.body, this.tooltipElement);

    // Position the tooltip near the host element:
    const rect = this.el.nativeElement.getBoundingClientRect();
    this.renderer.setStyle(this.tooltipElement, 'position', 'fixed');
    this.renderer.setStyle(this.tooltipElement, 'top', `${rect.bottom + 5}px`);
    this.renderer.setStyle(this.tooltipElement, 'left', `${rect.left}px`);
  }

  private hideTooltip() {
    if (this.tooltipElement) {
      this.renderer.removeChild(document.body, this.tooltipElement);
      this.tooltipElement = null;
    }
  }
}
```

```html
<!-- Usage: -->
<button appTooltip="Add this book to your cart" class="btn btn-book-primary">
  Add to Cart
</button>
<!-- The directive adds tooltip behavior without modifying the button's template -->
```

---

## 1.5 Host Binding — Binding to the Host Element's Properties

```typescript
import { Directive, HostBinding, HostListener } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true,
})
export class HighlightDirective {
  @HostBinding('style.backgroundColor')
  // @HostBinding: binds a property OF the host element
  // 'style.backgroundColor': sets the background color CSS property
  backgroundColor = 'transparent';

  @HostBinding('class.highlighted')
  // Adds/removes the class 'highlighted' based on isHighlighted value
  isHighlighted = false;

  @HostListener('mouseenter')
  onEnter() {
    this.backgroundColor = 'rgba(212, 168, 83, 0.15)'; // book-accent transparent
    this.isHighlighted = true;
  }

  @HostListener('mouseleave')
  onLeave() {
    this.backgroundColor = 'transparent';
    this.isHighlighted = false;
  }
}
```

---

## 1.6 Building a Custom Structural Directive

Structural directives change the DOM structure — they add or remove elements. They use a microsyntax with `*`.

```typescript
// unless.directive.ts — the opposite of *ngIf
import { Directive, Input, TemplateRef, ViewContainerRef } from '@angular/core';

@Directive({
  selector: '[appUnless]',
  standalone: true,
})
export class UnlessDirective {
  private hasView = false;

  constructor(
    private templateRef: TemplateRef<any>,
    // TemplateRef: the template inside the directive (the element it's applied to)
    // When you write *appUnless="condition", Angular wraps the element in <ng-template>
    // and passes that template to your directive

    private viewContainer: ViewContainerRef
    // ViewContainerRef: where in the DOM to insert/remove the template
  ) {}

  @Input()
  set appUnless(condition: boolean) {
    // The setter runs every time the condition changes
    if (!condition && !this.hasView) {
      // condition is false AND we haven't rendered yet → render it
      this.viewContainer.createEmbeddedView(this.templateRef);
      this.hasView = true;
    } else if (condition && this.hasView) {
      // condition is true AND we're showing → remove it
      this.viewContainer.clear();
      this.hasView = false;
    }
  }
}
```

```html
<!-- Usage: -->
<div *appUnless="isLoggedIn">
  Please log in to continue
</div>
<!-- Shows when isLoggedIn is false, hides when true (opposite of *ngIf) -->
```

---

## 1.7 Bookstore Application: Book Card Hover Directive

```typescript
// book-hover.directive.ts
import { Directive, ElementRef, HostListener, Renderer2 } from '@angular/core';

@Directive({
  selector: '[appBookHover]',
  standalone: true,
})
export class BookHoverDirective {
  constructor(private el: ElementRef, private renderer: Renderer2) {}

  @HostListener('mouseenter')
  onEnter() {
    this.renderer.setStyle(this.el.nativeElement, 'transform', 'translateY(-4px)');
    this.renderer.setStyle(this.el.nativeElement, 'box-shadow', '0 8px 24px rgba(0,0,0,0.12)');
    this.renderer.setStyle(this.el.nativeElement, 'transition', 'all 0.2s ease');
  }

  @HostListener('mouseleave')
  onLeave() {
    this.renderer.setStyle(this.el.nativeElement, 'transform', 'translateY(0)');
    this.renderer.setStyle(this.el.nativeElement, 'box-shadow', 'none');
  }
}
```

```html
<!-- book-card.html -->
<div class="card border-book h-100" appBookHover>
  <!-- Card lifts on hover via the directive — no CSS needed -->
</div>
```

---

---

# CHAPTER 2 — Standalone vs NgModule: Full Historical Context

## 2.1 Why NgModule Existed

When Angular 2 launched in 2016, every application was organized into **Modules**. A module was a class decorated with `@NgModule` that grouped related components, directives, and pipes together and declared which external modules they needed.

The module system was inspired by the way backend frameworks (like Java Spring) organize code. At the time, it seemed like a good idea for large enterprise applications.

```typescript
// THE OLD WAY — you do NOT write this in your project
// But you will encounter it in older codebases, tutorials, and Stack Overflow answers

@NgModule({
  declarations: [
    // ALL components, directives, and pipes that BELONG to this module
    LoginComponent,
    RegisterComponent,
    AuthGuard,
    // You can ONLY use these in this module's templates
    // To use them elsewhere, you must export them
  ],
  imports: [
    // OTHER modules whose exports this module needs
    CommonModule,      // provides NgIf, NgFor, AsyncPipe, etc.
    ReactiveFormsModule,
    RouterModule,
    HttpClientModule,
  ],
  exports: [
    // What THIS module makes available to whoever imports it
    LoginComponent,
    RegisterComponent,
  ],
  providers: [
    // Services specific to this module (not root-level)
    AuthService,
  ]
})
export class AuthModule {}
```

---

## 2.2 The Problems With NgModule

**Problem 1: The invisible connection**

```typescript
// LoginComponent needed ReactiveFormsModule
// But where did ReactiveFormsModule get declared?
// Not in LoginComponent — in AuthModule (a completely separate file)
// To understand LoginComponent, you HAD to know which module it belonged to
// This was called "implicit dependencies" — nothing in the component told you
```

**Problem 2: Sharing components was painful**

```typescript
// If BookCardComponent was in BookModule and you wanted to use it in ProfileModule:
// Step 1: BookModule must add BookCardComponent to its exports array
// Step 2: ProfileModule must import BookModule in its imports array
// Step 3: Now ALL of BookModule's exports are available in ProfileModule
//         — even the ones you didn't want
// This led to "barrel modules" that exported everything, importing chaos
```

**Problem 3: Provider confusion**

```typescript
// Services could be provided at different levels:
// - Root level (singleton): providedIn: 'root'
// - Module level: listed in @NgModule providers[]
// - Component level: listed in @Component providers[]
// Each level created different scoping behavior
// Getting this wrong caused services to be instantiated multiple times
// or shared when they shouldn't be
```

**Problem 4: Compilation overhead**

```typescript
// NgModule compiled everything together
// Even components you never used were compiled and included in the bundle
// Tree-shaking (removing unused code) was limited
```

---

## 2.3 How Standalone Works (Angular 14–21)

Standalone components solve all NgModule problems by making each component **self-declaring**:

```typescript
// THE NEW WAY — what your bookstore project uses
@Component({
  selector: 'app-login',
  standalone: true,                              // no NgModule needed
  imports: [
    ReactiveFormsModule,  // declared HERE, at the component level
    RouterLink,           // visible only to THIS component's template
    CommonModule,         // exactly what THIS component needs
  ],
  templateUrl: './login.html',
})
export class Login {}
```

**What changed:**

```
OLD: Component → declares in Module → Module imports what it needs
NEW: Component → directly imports what it needs

OLD: To share a component, export from module, import the module
NEW: To share a component, just import the component class directly

OLD: Services can accidentally be multi-instanced
NEW: Services use providedIn: 'root' — always a singleton
```

---

## 2.4 Migrating NgModule Code to Standalone

You will encounter NgModule code in existing projects. Here's how to recognize it and convert it.

**Step 1 — Recognize old code:**

```typescript
// Old component — has NO standalone: true, belongs to a module
@Component({
  selector: 'app-old-login',
  // NO standalone property
  templateUrl: './old-login.component.html',
})
export class OldLoginComponent {}  // notice: "Component" suffix (old convention)

// Corresponding module:
@NgModule({
  declarations: [OldLoginComponent],
  imports: [ReactiveFormsModule, RouterModule],
})
export class AuthModule {}
```

**Step 2 — Convert the component:**

```typescript
// New component — standalone with its own imports
@Component({
  selector: 'app-login',
  standalone: true,              // ADD THIS
  imports: [                     // MOVE imports here from the module
    ReactiveFormsModule,
    RouterLink,
  ],
  templateUrl: './login.html',
})
export class Login {}            // remove "Component" suffix (new convention)
```

**Step 3 — Update where the component is used:**

```typescript
// OLD: another module imports AuthModule to use LoginComponent
@NgModule({
  imports: [AuthModule]  // to get LoginComponent
})
export class AppModule {}

// NEW: directly import the standalone component where needed
@Component({
  imports: [Login]  // import the component class directly
})
export class SomeParent {}

// Or in routes (lazy loading):
{
  path: 'login',
  loadComponent: () => import('./features/auth/login/login').then(c => c.Login)
}
```

---

## 2.5 Bootstrapping: Old vs New

**Old way (with NgModule):**

```typescript
// main.ts — old style
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
```

**New way (standalone):**

```typescript
// main.ts — new style (what your project uses)
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { App } from './app/app';

bootstrapApplication(App, appConfig)
  .catch(err => console.error(err));
```

The key difference: `bootstrapApplication` takes the ROOT COMPONENT directly, not a module. All global providers go in `appConfig` instead of `AppModule`.

---

## 2.6 providedIn vs providers Array

```typescript
// OPTION 1: providedIn: 'root' (preferred — what your project uses)
@Injectable({ providedIn: 'root' })
export class AuthService {}
// Creates ONE instance for the entire app — singleton
// Tree-shakeable: if nothing injects it, it's excluded from the bundle
// No need to add it anywhere — Angular finds it automatically

// OPTION 2: providers in app.config.ts (for services needing configuration)
export const appConfig: ApplicationConfig = {
  providers: [
    { provide: AuthService, useClass: AuthService },
    // Explicit registration — same effect as providedIn: 'root'
    // BUT: not tree-shakeable — always included in the bundle

    { provide: SomeToken, useValue: 'some string value' },
    // Provide a string, number, or object as an injectable value

    { provide: Logger, useFactory: () => new Logger('production') },
    // Provide an instance created by a factory function
  ]
};

// OPTION 3: providers in @Component (component-level service)
@Component({
  providers: [SomeLocalService]
  // Creates a NEW INSTANCE for this component and its children
  // Destroyed when the component is destroyed
  // Use when different component trees need isolated service instances
})
export class SomeComponent {}
```

---

## 2.7 When You'll Still Encounter NgModule Code

Even in 2025, you'll encounter NgModule code in:

1. **Third-party libraries** — Many Angular libraries still use NgModule to export their components/directives. You import their module: `imports: [MatButtonModule, MatInputModule]`

2. **Older projects** — Any Angular project started before Angular 14 uses NgModule throughout

3. **Stack Overflow answers** — Thousands of answers show NgModule syntax

4. **Official Angular docs** — Many examples still show both syntaxes

**How to use a third-party NgModule in a standalone component:**

```typescript
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';

@Component({
  standalone: true,
  imports: [
    MatButtonModule,   // import the MODULE (not a component class)
    MatInputModule,    // Angular correctly handles modules in standalone imports
  ],
})
export class MyComponent {}
// Angular automatically unwraps the module and makes its exports available
```

---

---

# CHAPTER 3 — Angular Animations: The Complete Guide

## 3.1 Setting Up Animations

```typescript
// app.config.ts — add animation provider
import { provideAnimations } from '@angular/platform-browser/animations';
// OR for no-op (disable) animations in tests:
// import { provideNoopAnimations } from '@angular/platform-browser/animations/testing';

export const appConfig: ApplicationConfig = {
  providers: [
    provideAnimations(), // ADD THIS — enables animations throughout the app
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([...])),
  ]
};
```

---

## 3.2 The Animations API

Angular animations use a declarative API based on these building blocks:

```typescript
import {
  trigger,     // creates an animation trigger (named group of states/transitions)
  state,       // defines a named state with associated styles
  style,       // defines CSS styles for a state or transition
  animate,     // defines the timing of a transition
  transition,  // defines when a transition runs (from-state => to-state)
  keyframes,   // multi-step animation
  query,       // query child elements within an animation
  stagger,     // create a cascade effect on a list
  group,       // run multiple animations in parallel
  sequence,    // run multiple animations one after another
} from '@angular/animations';
```

---

## 3.3 trigger, state, style, animate, transition

```typescript
// book-card.ts
import { Component, Input } from '@angular/core';
import { trigger, state, style, animate, transition } from '@angular/animations';

@Component({
  selector: 'app-book-card',
  standalone: true,
  templateUrl: './book-card.html',
  animations: [
    // animations is a @Component property — an array of triggers
    trigger('cardFlip', [
      // trigger('name', [states and transitions])
      // 'name' is what you use in the template: [@cardFlip]="state"

      state('default', style({
        // Defines what the element looks like in 'default' state
        transform: 'rotateY(0deg)',
        opacity: 1,
      })),

      state('flipped', style({
        transform: 'rotateY(180deg)',
        opacity: 0.5,
      })),

      transition('default => flipped', [
        // When state changes from 'default' to 'flipped', run this animation
        animate('300ms ease-in')
        // '300ms ease-in': duration + easing function
        // Can also be: '300ms 100ms ease-in' (duration, delay, easing)
      ]),

      transition('flipped => default', [
        animate('300ms ease-out')
      ]),

      transition('* => *', [
        // '*' means ANY state — catches all transitions not handled above
        animate('200ms ease')
      ]),
    ]),
  ]
})
export class BookCard {
  @Input() book!: Book;
  cardState = 'default';

  flip() {
    this.cardState = this.cardState === 'default' ? 'flipped' : 'default';
  }
}
```

```html
<!-- book-card.html -->
<div [@cardFlip]="cardState" (click)="flip()" class="card">
  <!-- [@cardFlip]="cardState": binds the 'cardFlip' trigger to the cardState variable -->
  <!-- When cardState changes, the transition animation runs automatically -->
  {{ book.title }}
</div>
```

---

## 3.4 :enter and :leave — Element Insertion/Removal

The most common animation use case: animate elements when they appear or disappear (via `@if` or `@for`).

```typescript
trigger('fadeInOut', [
  transition(':enter', [
    // ':enter' fires when the element is ADDED to the DOM
    // Happens when: *ngIf becomes true, @if condition becomes true, router loads component
    style({ opacity: 0, transform: 'translateY(-10px)' }),
    // Start state: invisible, moved up 10px
    animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
    // End state: fully visible, in normal position
    // Angular interpolates between start and end over 300ms
  ]),
  transition(':leave', [
    // ':leave' fires when the element is REMOVED from the DOM
    animate('200ms ease-in', style({ opacity: 0, transform: 'translateY(-10px)' }))
    // Animate to invisible before removing from DOM
  ]),
])
```

```html
<!-- Apply to elements controlled by @if: -->
<div [@fadeInOut]>
  @if (showMessage) {
    <div class="alert alert-success">Success!</div>
  }
</div>

<!-- Or directly on the animated element: -->
@if (showMessage) {
  <div class="alert alert-success" [@fadeInOut]>Success!</div>
}
```

---

## 3.5 Animating Routes — Page Transitions

```typescript
// app.ts — route transition animation
import { RouterOutlet } from '@angular/router';
import { trigger, transition, style, animate, query } from '@angular/animations';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, Navbar],
  templateUrl: './app.html',
  animations: [
    trigger('routeAnimation', [
      transition('* => *', [
        // For any route change:
        query(':enter', [
          // Query the ENTERING component:
          style({ opacity: 0, transform: 'translateX(20px)' }),
          animate('250ms ease-out', style({ opacity: 1, transform: 'translateX(0)' }))
        ], { optional: true })
        // optional: true — don't fail if no :enter element (e.g. redirect)
      ])
    ])
  ]
})
export class App {
  getRouteAnimation(outlet: RouterOutlet) {
    return outlet.activatedRouteData['animation'] || 'default';
  }
}
```

```html
<!-- app.html -->
<app-navbar></app-navbar>
<main [@routeAnimation]="getRouteAnimation(outlet)">
  <router-outlet #outlet="outlet"></router-outlet>
</main>
```

---

## 3.6 keyframes — Multi-Step Animations

`keyframes` lets you define multiple steps within a single animation, like CSS `@keyframes`.

```typescript
import { keyframes } from '@angular/animations';

trigger('bounce', [
  transition(':enter', [
    animate('600ms', keyframes([
      style({ transform: 'translateY(-20px)', offset: 0 }),
      // offset: 0 = start of animation (0%)
      style({ transform: 'translateY(5px)',  offset: 0.6 }),
      // offset: 0.6 = 60% through the animation
      style({ transform: 'translateY(-3px)', offset: 0.8 }),
      // offset: 0.8 = 80%
      style({ transform: 'translateY(0)',    offset: 1 }),
      // offset: 1 = end (100%)
    ]))
  ])
])
```

---

## 3.7 query and stagger — Animating Lists

`query` selects child elements. `stagger` creates a cascade effect — each child animates with a slight delay after the previous one.

```typescript
trigger('listAnimation', [
  transition('* => *', [
    query(':enter', [
      style({ opacity: 0, transform: 'translateY(20px)' }),
      stagger(60, [
        // stagger(delayBetweenItems, animations)
        // 60ms delay between each item's animation start
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ], { optional: true })
  ])
])
```

```html
<!-- Apply to the LIST CONTAINER, not individual items: -->
<div [@listAnimation]="books.length">
  @for (book of books; track book._id) {
    <app-book-card [book]="book"></app-book-card>
  }
</div>
<!-- Changing books.length triggers the animation -->
<!-- Each BookCard enters with a 60ms stagger between them -->
```

---

## 3.8 Disabling Animations

```typescript
// Disable all animations on a subtree:
<div [@.disabled]="prefersReducedMotion">
  <!-- All animations inside here are disabled -->
</div>

// TypeScript:
prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
// Respects the user's OS accessibility setting — always check this
```

---

## 3.9 Bookstore Application: Book Cards + Alert Animations

```typescript
// book-list.ts — list animation for books
import { Component, OnInit } from '@angular/core';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';
import { BookCard } from '../book-card/book-card';

@Component({
  selector: 'app-book-list',
  standalone: true,
  imports: [BookCard],
  templateUrl: './book-list.html',
  animations: [
    trigger('booksAnimation', [
      transition('* => *', [
        query(':enter', [
          style({ opacity: 0, transform: 'scale(0.95) translateY(10px)' }),
          stagger(40, [
            animate('250ms ease-out', style({ opacity: 1, transform: 'scale(1) translateY(0)' }))
          ])
        ], { optional: true })
      ])
    ]),
  ]
})
export class BookList implements OnInit {
  books: Book[] = [];
  // ...
}
```

```html
<!-- book-list.html -->
<div class="row g-4" [@booksAnimation]="books.length">
  @for (book of books; track book._id) {
    <div class="col-md-4 col-lg-3">
      <app-book-card [book]="book"></app-book-card>
    </div>
  }
</div>
```

```typescript
// For auth pages — fade in:
// login.ts
animations: [
  trigger('pageEnter', [
    transition(':enter', [
      style({ opacity: 0, transform: 'translateY(20px)' }),
      animate('400ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
    ])
  ])
]
```

```html
<!-- login.html — apply to the card: -->
<div class="card border-book shadow-sm p-4" [@pageEnter]>
```

---

# Quick Reference Card — Directives + Modules + Animations

## Directives Quick Reference

```typescript
// Attribute directive:
@Directive({ selector: '[appMyDirective]', standalone: true })
export class MyDirective {
  @Input('appMyDirective') config = '';    // input matching selector name
  @HostBinding('class.active') isActive = false; // bind to host property
  @HostListener('click') onClick() { }    // listen to host event
  constructor(private el: ElementRef, private renderer: Renderer2) {}
}

// Usage: <div appMyDirective="config-value">

// Built-in directives (add to component imports[]):
[ngClass]="{ 'class': condition }"
[ngStyle]="{ 'color': value }"
[(ngModel)]="variable"  // requires FormsModule
```

## Standalone vs NgModule Quick Reference

```typescript
// Standalone (modern — use this):
@Component({ standalone: true, imports: [ReactiveFormsModule, RouterLink, ...] })

// NgModule (old — you'll encounter in existing code):
@NgModule({ declarations: [Component], imports: [ReactiveFormsModule], exports: [Component] })

// Bootstrapping:
bootstrapApplication(App, appConfig)              // standalone
platformBrowserDynamic().bootstrapModule(AppModule) // NgModule
```

## Animations Quick Reference

```typescript
// In component:
animations: [
  trigger('name', [
    transition(':enter', [style({opacity:0}), animate('300ms', style({opacity:1}))]),
    transition(':leave', [animate('200ms', style({opacity:0}))]),
    state('active', style({color:'red'})),
    transition('* => active', animate('200ms')),
  ])
]

// In template:
[@name]              // always animated
[@name]="state"      // controlled by state variable
[@.disabled]="bool"  // disable animations conditionally
```

---

*End of Part 5. Saved to outputs.*
*Part 6: Angular Material/CDK + Advanced Forms (async validators, cross-field, FormArray)*

---

# CHAPTER 4 — Directives: Every Detail

## 4.1 The Directive Lifecycle

Directives have the same lifecycle hooks as components. They do NOT have `ngAfterViewInit` or `ngAfterContentInit` (those are component-only hooks tied to having a template/content).

```typescript
@Directive({ selector: '[appTracking]', standalone: true })
export class TrackingDirective implements OnInit, OnChanges, OnDestroy {

  @Input('appTracking') trackingId = '';

  constructor(private el: ElementRef) {
    // Runs first. this.el.nativeElement is available.
    // @Input values are NOT yet assigned — they're set AFTER constructor.
  }

  ngOnChanges(changes: SimpleChanges) {
    // Runs when any @Input() value changes.
    // On first run: changes contains ALL inputs with currentValue and no previousValue.
    // On subsequent runs: only changed inputs are in changes.
    if (changes['trackingId']) {
      const prev = changes['trackingId'].previousValue;
      const curr = changes['trackingId'].currentValue;
      console.log(`Tracking changed from ${prev} to ${curr}`);
    }
  }

  ngOnInit() {
    // Runs once after @Input values are first assigned.
    // Safe to use this.trackingId here.
    this.setupTracking();
  }

  ngOnDestroy() {
    // Runs when the host element is removed from the DOM.
    // Clean up: remove event listeners, cancel subscriptions.
    this.cleanupTracking();
  }

  private setupTracking() { /* ... */ }
  private cleanupTracking() { /* ... */ }
}
```

---

## 4.2 Renderer2 vs Direct DOM Manipulation

Always use `Renderer2` in directives — never manipulate the DOM directly in Angular code.

```typescript
// WHY Renderer2 EXISTS — server-side rendering (SSR):
// When Angular runs on the server (Node.js), there is no browser DOM.
// `document`, `window`, `element.style`, `element.classList` — all crash on the server.
// Renderer2 is an abstraction: on the browser it uses real DOM APIs,
// on the server it uses a virtual DOM that works without a browser.

// ❌ Direct DOM manipulation (breaks SSR):
this.el.nativeElement.style.color = 'red';
this.el.nativeElement.classList.add('active');
this.el.nativeElement.addEventListener('click', handler);

// ✅ Renderer2 (works everywhere):
this.renderer.setStyle(this.el.nativeElement, 'color', 'red');
this.renderer.addClass(this.el.nativeElement, 'active');
this.renderer.listen(this.el.nativeElement, 'click', handler);
// renderer.listen() also RETURNS an unlisten function — useful for ngOnDestroy cleanup

// Full Renderer2 API:
this.renderer.createElement('div');            // create element
this.renderer.createText('hello');             // create text node
this.renderer.appendChild(parent, child);      // add child to parent
this.renderer.insertBefore(parent, newNode, refNode); // insert before a node
this.renderer.removeChild(parent, child);      // remove child
this.renderer.setAttribute(el, 'aria-label', 'close'); // set attribute
this.renderer.removeAttribute(el, 'aria-label');        // remove attribute
this.renderer.addClass(el, 'active');          // add CSS class
this.renderer.removeClass(el, 'active');       // remove CSS class
this.renderer.setStyle(el, 'color', 'red');    // set inline style
this.renderer.removeStyle(el, 'color');        // remove inline style
this.renderer.setProperty(el, 'value', 'text'); // set DOM property
this.renderer.setValue(textNode, 'new text');  // set text node value
```

---

## 4.3 Building a Complete Tooltip Directive — Step by Step

Let's build a production-quality tooltip directive with positioning, accessibility, and cleanup.

```typescript
// tooltip.directive.ts
import {
  Directive, ElementRef, HostListener, Input,
  OnDestroy, Renderer2, AfterViewInit
} from '@angular/core';

@Directive({
  selector: '[appTooltip]',
  standalone: true,
})
export class TooltipDirective implements OnDestroy {
  @Input('appTooltip') text = '';
  // 'appTooltip': input name matches directive selector
  // So <button appTooltip="Add to cart"> passes "Add to cart" to text

  @Input() tooltipPosition: 'top' | 'bottom' | 'left' | 'right' = 'bottom';
  // Secondary input — parent can customize: <button appTooltip="..." tooltipPosition="top">

  @Input() tooltipDelay = 300;
  // Show tooltip after 300ms delay — prevents flicker on fast mouse movements

  private tooltipEl: HTMLElement | null = null;
  private showTimeout: ReturnType<typeof setTimeout> | null = null;
  private hideTimeout: ReturnType<typeof setTimeout> | null = null;

  constructor(
    private el: ElementRef<HTMLElement>,
    private renderer: Renderer2
  ) {}

  @HostListener('mouseenter')
  @HostListener('focusin')  // also show on keyboard focus — accessibility
  onShow() {
    if (this.showTimeout) clearTimeout(this.showTimeout);
    if (this.hideTimeout) clearTimeout(this.hideTimeout);

    this.showTimeout = setTimeout(() => {
      this.createTooltip();
    }, this.tooltipDelay);
  }

  @HostListener('mouseleave')
  @HostListener('focusout') // hide on focus loss
  onHide() {
    if (this.showTimeout) clearTimeout(this.showTimeout);

    this.hideTimeout = setTimeout(() => {
      this.removeTooltip();
    }, 100); // small delay before hiding — prevents flicker when moving mouse to tooltip
  }

  private createTooltip() {
    if (this.tooltipEl || !this.text) return; // already showing, or no text

    this.tooltipEl = this.renderer.createElement('div') as HTMLElement;
    this.renderer.addClass(this.tooltipEl, 'app-tooltip');

    const textNode = this.renderer.createText(this.text);
    this.renderer.appendChild(this.tooltipEl, textNode);

    // Accessibility — tooltip role:
    this.renderer.setAttribute(this.tooltipEl, 'role', 'tooltip');

    // Link the host element to the tooltip for screen readers:
    const tooltipId = `tooltip-${Math.random().toString(36).substr(2, 9)}`;
    this.renderer.setAttribute(this.tooltipEl, 'id', tooltipId);
    this.renderer.setAttribute(this.el.nativeElement, 'aria-describedby', tooltipId);

    this.renderer.appendChild(document.body, this.tooltipEl);
    this.positionTooltip();
  }

  private positionTooltip() {
    if (!this.tooltipEl) return;

    const hostRect = this.el.nativeElement.getBoundingClientRect();
    const tipRect  = this.tooltipEl.getBoundingClientRect();
    const gap = 8; // pixels between host and tooltip

    let top: number, left: number;

    switch (this.tooltipPosition) {
      case 'top':
        top  = hostRect.top - tipRect.height - gap + window.scrollY;
        left = hostRect.left + (hostRect.width - tipRect.width) / 2 + window.scrollX;
        break;
      case 'bottom':
        top  = hostRect.bottom + gap + window.scrollY;
        left = hostRect.left + (hostRect.width - tipRect.width) / 2 + window.scrollX;
        break;
      case 'left':
        top  = hostRect.top  + (hostRect.height - tipRect.height) / 2 + window.scrollY;
        left = hostRect.left - tipRect.width - gap + window.scrollX;
        break;
      case 'right':
        top  = hostRect.top  + (hostRect.height - tipRect.height) / 2 + window.scrollY;
        left = hostRect.right + gap + window.scrollX;
        break;
    }

    this.renderer.setStyle(this.tooltipEl, 'position', 'absolute');
    this.renderer.setStyle(this.tooltipEl, 'top', `${top}px`);
    this.renderer.setStyle(this.tooltipEl, 'left', `${left}px`);
    this.renderer.setStyle(this.tooltipEl, 'z-index', '9999');
  }

  private removeTooltip() {
    if (this.tooltipEl) {
      this.renderer.removeChild(document.body, this.tooltipEl);
      this.renderer.removeAttribute(this.el.nativeElement, 'aria-describedby');
      this.tooltipEl = null;
    }
  }

  ngOnDestroy() {
    // If the element is destroyed while tooltip is showing, remove it
    if (this.showTimeout) clearTimeout(this.showTimeout);
    if (this.hideTimeout) clearTimeout(this.hideTimeout);
    this.removeTooltip();
  }
}
```

```scss
/* styles.scss — tooltip styles */
.app-tooltip {
  background: rgba(0, 0, 0, 0.85);
  color: #fff;
  font-size: 0.8rem;
  padding: 0.35rem 0.65rem;
  border-radius: 4px;
  pointer-events: none; /* tooltip doesn't intercept mouse events */
  white-space: nowrap;
  animation: tooltip-fade-in 150ms ease;
}

@keyframes tooltip-fade-in {
  from { opacity: 0; transform: translateY(-3px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

```html
<!-- Usage in bookstore: -->
<button
  appTooltip="Add this book to your cart"
  tooltipPosition="top"
  [tooltipDelay]="500"
  class="btn btn-book-primary"
  (click)="onAddClick()">
  Add to Cart
</button>
```

---

## 4.4 The * Prefix — What It Actually Means

When you write `*ngIf` or `*appUnless`, Angular desugars it into an `<ng-template>`:

```html
<!-- What you write: -->
<div *ngIf="isLoggedIn" class="user-panel">Welcome!</div>

<!-- What Angular actually compiles: -->
<ng-template [ngIf]="isLoggedIn">
  <div class="user-panel">Welcome!</div>
</ng-template>
```

Angular transforms `*directiveName="expression"` into:
1. Wraps the element in `<ng-template>`
2. Binds `[directiveName]="expression"` on the `<ng-template>` tag
3. The directive receives `TemplateRef` (the wrapped element) and `ViewContainerRef` (where to insert it)

This is why structural directives can add or remove elements: they control whether the `TemplateRef` is rendered into the `ViewContainerRef`.

```typescript
// When Angular calls createEmbeddedView(templateRef):
// → Stamps the template into the DOM at the ViewContainerRef location
// → The element APPEARS

// When Angular calls viewContainer.clear():
// → Removes everything stamped from the ViewContainerRef
// → The element DISAPPEARS (no display:none — physically removed from DOM)

// This is DIFFERENT from [style.display]="isVisible ? '' : 'none'"
// Hidden elements are still in the DOM — *ngIf removes them entirely
// Removed elements free memory (component destroyed) and hide from tab order
```

---

## 4.5 ngClass vs Class Binding — When to Use Each

```html
<!-- [class.name]: one class, one condition — most readable: -->
<button [class.btn-primary]="isSelected" [class.btn-outline-secondary]="!isSelected">
  Select
</button>

<!-- [ngClass] object: multiple classes, multiple conditions: -->
<div [ngClass]="{
  'card':         true,
  'border-book':  true,
  'shadow-lg':    isHovered,
  'opacity-50':   isDisabled,
  'selected-card': isSelected
}">

<!-- [ngClass] expression (method returns the object — good for complex logic): -->
<div [ngClass]="getCardClasses(book)">

<!-- [ngClass] array (always apply these): -->
<div [ngClass]="['card', 'border-book', isLarge ? 'p-5' : 'p-3']">

<!-- [class] binding (replaces ALL classes with this string — use carefully): -->
<div [class]="computedClassString">
<!-- This REPLACES the class attribute entirely — any static classes in the template are lost -->
<!-- Unlike [ngClass] which ADDS to existing classes -->
```

---

## 4.6 ngStyle vs Style Binding — When to Use Each

```html
<!-- [style.property]: single property — cleanest: -->
<p [style.color]="textColor">Colored text</p>
<p [style.font-size.px]="fontSize">Big or small text</p>
<!-- The .px suffix automatically appends 'px' to the value -->

<!-- [style.property.unit] — with unit suffix: -->
<div [style.width.%]="progressPercentage">Progress bar</div>
<div [style.margin-top.rem]="spacing">Spaced element</div>

<!-- [ngStyle] — multiple dynamic properties: -->
<div [ngStyle]="{
  'color':        book.isNew ? 'green' : 'inherit',
  'font-weight':  book.isBestseller ? 'bold' : 'normal',
  'font-size':    isLarge ? '1.2rem' : '1rem'
}">

<!-- [style] binding (replaces ALL inline styles — use carefully): -->
<div [style]="computedStyleObject">
```

---

## 4.7 Building a Permission Directive — Real-World Example

A directive that shows/hides elements based on user roles — used throughout admin UIs:

```typescript
// has-role.directive.ts
import { Directive, Input, OnInit, TemplateRef, ViewContainerRef } from '@angular/core';
import { AuthService } from '../services/auth.service';

@Directive({
  selector: '[appHasRole]',
  standalone: true,
})
export class HasRoleDirective implements OnInit {
  @Input('appHasRole') requiredRole: 'admin' | 'user' | string = 'user';

  private hasView = false;

  constructor(
    private templateRef: TemplateRef<any>,
    private viewContainer: ViewContainerRef,
    private auth: AuthService
  ) {}

  ngOnInit() {
    const currentUser = this.auth.getCurrentUser();
    const userRole    = currentUser?.role;

    const hasPermission =
      this.requiredRole === 'user' ||           // everyone can see 'user' content
      (this.requiredRole === 'admin' && userRole === 'admin'); // only admin sees 'admin' content

    if (hasPermission && !this.hasView) {
      this.viewContainer.createEmbeddedView(this.templateRef);
      this.hasView = true;
    } else if (!hasPermission && this.hasView) {
      this.viewContainer.clear();
      this.hasView = false;
    }
  }
}
```

```html
<!-- Usage: show "Edit" and "Delete" only to admins: -->
<div class="book-card">
  <h5>{{ book.title }}</h5>

  <a [routerLink]="['/books', book._id]" class="btn btn-book-primary">View</a>

  <div *appHasRole="'admin'" class="admin-controls mt-2">
    <button class="btn btn-warning btn-sm me-1">Edit</button>
    <button class="btn btn-danger btn-sm">Delete</button>
  </div>
  <!-- admin-controls div is not rendered at all for non-admin users -->
  <!-- Not just hidden — physically absent from the DOM -->
</div>
```

---

---

# CHAPTER 5 — NgModule: Complete Historical Understanding

## 5.1 The Full NgModule Declaration

To truly understand standalone, you need to understand what NgModule actually did. Here is a complete NgModule-based application:

```typescript
// app.module.ts — the old root module
@NgModule({
  declarations: [
    // EVERY component, directive, and pipe MUST be declared in exactly ONE module
    // You cannot declare a component in two modules — Angular throws an error
    AppComponent,
    NavbarComponent,
    LoginComponent,
    RegisterComponent,
    ProfileComponent,
    BookListComponent,
    BookCardComponent,
    BookDetailComponent,
    AuthGuard,
    AdminGuard,
    TokenInterceptor,   // interceptors were declared differently — not here, in providers
    TruncatePipe,
    HighlightDirective,
    // Forgot to add a new component here? Template compilation fails with:
    // "Can't bind to 'book' since it isn't a known property of 'app-book-card'"
    // But the actual error message doesn't tell you WHY — confusing for beginners
  ],

  imports: [
    // Other NgModules whose exported declarations this module can use
    BrowserModule,         // required in root module — provides NgIf, NgFor, etc.
    RouterModule.forRoot(routes), // router with root-level setup
    ReactiveFormsModule,   // enables reactive forms throughout
    HttpClientModule,      // enables HttpClient throughout
    MatButtonModule,       // Angular Material button
    MatInputModule,        // Angular Material input
  ],

  providers: [
    AuthService,           // services could go here (or in providedIn: 'root')
    BookService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: TokenInterceptor,
      multi: true          // multi: true means "add to list" not "replace"
      // This was how you registered interceptors — very different from withInterceptors()
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true          // had to repeat this for every interceptor
    },
  ],

  bootstrap: [AppComponent] // the root component to render in index.html
})
export class AppModule {}
```

```typescript
// A feature module — e.g. BooksModule
@NgModule({
  declarations: [
    BookListComponent,
    BookCardComponent,
    BookDetailComponent,
    BookSearchComponent,
  ],
  imports: [
    CommonModule,        // NOT BrowserModule — only root uses BrowserModule
    // CommonModule: provides NgIf, NgFor, AsyncPipe, etc. for non-root modules
    RouterModule,        // NOT .forRoot() — for non-root modules
    SharedModule,        // your own shared components/pipes/directives
  ],
  exports: [
    BookListComponent,   // only BookList needs to be visible outside
    // BookCard, BookDetail, BookSearch are internal to BooksModule
  ]
})
export class BooksModule {}
```

---

## 5.2 The Module Boundary Problem in Detail

The most confusing NgModule behavior: module boundaries and what's visible where.

```
BooksModule declares: [BookCard, BookList, BookDetail]
BooksModule exports: [BookList]

ProfileModule imports: [BooksModule]
→ ProfileModule can use: <app-book-list>  ✅
→ ProfileModule CANNOT use: <app-book-card> ❌ (not exported from BooksModule)
→ ProfileModule CANNOT use: <app-book-detail> ❌ (not exported)

SharedModule declares: [TruncatePipe, ButtonComponent, CardComponent]
SharedModule exports: [TruncatePipe, ButtonComponent, CardComponent]

BooksModule imports: [SharedModule]
→ BookList template can use: {{ text | truncate }}     ✅
→ BookList template can use: <app-button>               ✅
→ BookCard template can use: <app-card>                 ✅

BUT: AdminModule also needs TruncatePipe
→ AdminModule must also import SharedModule
→ Each module that needs shared things must import SharedModule
→ SharedModule's providers (if any) are instantiated once per import
   → this caused the "multiple service instances" bug
```

---

## 5.3 Lazy Modules vs Lazy Components — The Difference

**NgModule era — lazy loading was done at the module level:**

```typescript
// Old routes.ts — lazy loading modules:
{
  path: 'books',
  loadChildren: () => import('./features/books/books.module').then(m => m.BooksModule)
  // loadChildren: loads an entire module (and all its declarations)
  // The chunk includes ALL components in BooksModule — even ones not immediately needed
}
```

**Standalone era — lazy loading at the component level:**

```typescript
// New routes.ts — lazy loading individual components:
{
  path: 'books',
  loadComponent: () => import('./features/books/book-list/book-list').then(c => c.BookList)
  // loadComponent: loads ONE component — much more granular
  // BookCard can be lazy-loaded separately if needed
  // Smaller chunks → faster navigation
}
```

**The standalone approach gives you finer control:**
```
Old: /books → loads BooksModule (BookList + BookCard + BookDetail + BookSearch all at once)
New: /books → loads BookList only
     /books/123 → loads BookDetail only
     Each route chunk is as small as possible
```

---

## 5.4 Migrating a Real NgModule Component

Let's convert a real BookCard from NgModule to standalone:

```typescript
// BEFORE: NgModule version
// book-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
// NO imports array — NgModule handles this

@Component({
  selector: 'app-book-card',
  // NO standalone: true
  templateUrl: './book-card.component.html',
  styleUrls: ['./book-card.component.scss']
  // Notice: "styleUrls" with an array — old convention
  // New: "styleUrl" (singular) with a string
})
export class BookCardComponent { // "Component" suffix — old naming convention
  @Input() book!: Book;
  @Input() showPrice: boolean = true;
  @Output() addToCart = new EventEmitter<Book>();
  // Functionality is identical — just the class decorator is different
}

// books.module.ts — BookCardComponent must be declared here:
@NgModule({
  declarations: [BookCardComponent, BookListComponent, BookDetailComponent],
  imports: [CommonModule, RouterModule],
  exports: [BookCardComponent]
})
export class BooksModule {}
```

```typescript
// AFTER: Standalone version
// book-card.ts (removed "Component" from filename)
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CurrencyPipe } from '@angular/common';

@Component({
  selector: 'app-book-card',
  standalone: true,               // ADD THIS
  imports: [RouterLink, CurrencyPipe], // ADD WHAT THE TEMPLATE USES
  templateUrl: './book-card.html',
  styleUrl: './book-card.scss'    // singular, string (new convention)
})
export class BookCard { // removed "Component" suffix (new convention)
  @Input() book!: Book;
  @Input() showPrice: boolean = true;
  @Output() addToCart = new EventEmitter<Book>();
}
// BooksModule no longer needs to declare or export this — the class is self-contained
```

---

## 5.5 SharedModule Pattern vs Direct Imports

**Old pattern — SharedModule:**

```typescript
// shared.module.ts — a module that exports commonly used things
@NgModule({
  declarations: [TruncatePipe, LoadingSpinnerComponent, ButtonComponent],
  imports: [CommonModule],
  exports: [
    CommonModule,           // re-export so importers get NgIf, NgFor etc. too
    TruncatePipe,
    LoadingSpinnerComponent,
    ButtonComponent,
  ]
})
export class SharedModule {}

// Usage: any module that needs these imports SharedModule:
@NgModule({
  imports: [SharedModule] // gets everything in one import
})
export class BooksModule {}
```

**New pattern — direct imports:**

```typescript
// No SharedModule needed. Each component imports exactly what it needs:
@Component({
  standalone: true,
  imports: [
    RouterLink,               // navigation links in the template
    CurrencyPipe,             // {{ book.price | currency }}
    LoadingSpinner,           // <app-loading-spinner>
    TruncatePipe,             // {{ text | truncate:100 }}
  ]
})
export class BookCard {}
// Explicit, readable — you know exactly what this template uses
// No need to hunt through module files to find where TruncatePipe was declared
```

---

---

# CHAPTER 6 — Angular Animations: Deep Reference

## 6.1 The Animation Pipeline — What Happens Under the Hood

When you define an animation trigger and Angular detects a state change, here's the precise sequence:

```
1. Angular detects: [@triggerName]="newState" changed from oldState to newState
2. Angular looks for a matching transition: 'oldState => newState'
   → Also checks: 'oldState => *', '* => newState', '* => *'
3. Angular evaluates the style() at the START of the transition
   → These styles are applied immediately (frame 0)
4. Angular begins the animate() tween from start styles to end styles
   → Interpolates CSS properties over the specified duration
5. Angular applies the state() style as the final resting state
   → These remain after the animation completes
```

---

## 6.2 state() vs style() in animate() — The Difference

```typescript
trigger('buttonState', [

  state('normal', style({
    // state() styles: the RESTING STATE of the element when it's in 'normal'
    // These styles persist AFTER the animation finishes
    backgroundColor: 'var(--book-primary)',
    transform: 'scale(1)',
  })),

  state('pressed', style({
    backgroundColor: 'var(--book-accent)',
    transform: 'scale(0.95)',
  })),

  transition('normal => pressed', [
    // The animate() call's style() is the ENDPOINT of this specific animation
    // If no state() is defined, style() in animate() sets the final style
    // If state() IS defined, it overrides style() in animate() at completion
    animate('100ms ease-in', style({
      transform: 'scale(0.95)',  // same as state('pressed') — they must match
    }))
  ]),

  transition('pressed => normal', [
    animate('200ms ease-out')
    // No style() argument: Angular uses the 'normal' state() as the target
    // This is cleaner when you have state() defined
  ]),
])
```

---

## 6.3 group() and sequence() — Parallel vs Sequential Animations

```typescript
trigger('complexEnter', [
  transition(':enter', [

    // sequence(): animations run ONE AFTER ANOTHER
    sequence([
      style({ opacity: 0, transform: 'translateY(30px)' }),
      animate('200ms ease-out', style({ opacity: 1, transform: 'translateY(0)' })),
      // Opacity fade completes FIRST
      animate('100ms', style({ transform: 'scale(1.02)' })),
      // THEN scale up slightly
      animate('100ms', style({ transform: 'scale(1)' })),
      // THEN scale back
    ]),

    // group(): animations run IN PARALLEL (simultaneously)
    group([
      animate('300ms ease-out', style({ opacity: 1 })),
      // Opacity and transform animate AT THE SAME TIME
      animate('300ms cubic-bezier(0.34, 1.56, 0.64, 1)', style({ transform: 'scale(1)' })),
      // cubic-bezier for spring/bounce effect
    ]),
  ]),
])
```

---

## 6.4 AnimationEvent — Listening to Animation Lifecycle

```html
<!-- Listen for when animation starts/finishes: -->
<div
  [@slideIn]="state"
  (@slideIn.start)="onAnimationStart($event)"
  (@slideIn.done)="onAnimationDone($event)">
</div>
```

```typescript
import { AnimationEvent } from '@angular/animations';

onAnimationStart(event: AnimationEvent) {
  console.log('Animation started');
  console.log('From state:', event.fromState);   // 'void' or 'normal' or 'active'
  console.log('To state:', event.toState);       // 'normal' or 'active' or 'void'
  console.log('Total time:', event.totalTime);   // duration in ms
  console.log('Element:', event.element);        // the DOM element
}

onAnimationDone(event: AnimationEvent) {
  // Animation completed — now safe to remove the element, redirect, etc.
  if (event.toState === 'void') {
    // The :leave animation finished — element is now removed from DOM
    // If you need to do something AFTER the exit animation, do it here
    this.router.navigate(['/next-page']);
  }
}
```

---

## 6.5 Disabling Animations for Accessibility

Always check the user's motion preference:

```typescript
// In the root App component or a dedicated service:
@Component({ selector: 'app-root', standalone: true })
export class App {
  prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  // True if the user has enabled "reduce motion" in their OS accessibility settings
  // (Settings → Accessibility → Reduce Motion on macOS/iOS)
  // (Settings → Ease of Access → Animation → Turn off animations on Windows)
}
```

```html
<!-- app.html — disable all animations for users who prefer reduced motion: -->
<main [@.disabled]="prefersReducedMotion">
  <router-outlet></router-outlet>
</main>
<!-- [@.disabled]="true" on a parent disables all animations in the subtree -->
```

---

## 6.6 Bookstore Application — Complete Animation Setup

```typescript
// app.config.ts — enable animations:
import { provideAnimations } from '@angular/platform-browser/animations';

export const appConfig: ApplicationConfig = {
  providers: [
    provideAnimations(),
    // ...other providers
  ]
};
```

```typescript
// animations.ts — centralize all animations (reusable across components):
import { trigger, transition, style, animate, query, stagger, state } from '@angular/animations';

// 1. Fade in/out — for modals, alerts, overlays
export const fadeAnimation = trigger('fade', [
  transition(':enter', [
    style({ opacity: 0 }),
    animate('200ms ease-out', style({ opacity: 1 }))
  ]),
  transition(':leave', [
    animate('150ms ease-in', style({ opacity: 0 }))
  ]),
]);

// 2. Slide up enter — for cards, forms appearing from bottom
export const slideUpAnimation = trigger('slideUp', [
  transition(':enter', [
    style({ opacity: 0, transform: 'translateY(20px)' }),
    animate('300ms cubic-bezier(0.25, 0.8, 0.25, 1)',
      style({ opacity: 1, transform: 'translateY(0)' }))
  ]),
  transition(':leave', [
    animate('200ms ease-in',
      style({ opacity: 0, transform: 'translateY(-10px)' }))
  ]),
]);

// 3. Book list stagger — cards appear one by one
export const bookListAnimation = trigger('bookList', [
  transition('* => *', [
    query(':enter', [
      style({ opacity: 0, transform: 'scale(0.96) translateY(12px)' }),
      stagger(45, [
        animate('280ms cubic-bezier(0.25, 0.8, 0.25, 1)',
          style({ opacity: 1, transform: 'scale(1) translateY(0)' }))
      ])
    ], { optional: true }),
  ])
]);

// 4. Loading skeleton pulse
export const pulseAnimation = trigger('pulse', [
  state('on', style({ opacity: 1 })),
  state('off', style({ opacity: 0.4 })),
  transition('on <=> off', animate('800ms ease-in-out')),
]);
```

```typescript
// book-list.ts — using the shared animations:
import { bookListAnimation } from '../../../shared/animations';

@Component({
  animations: [bookListAnimation],
  // Import from shared file — not redefined in every component
})
export class BookList {
  books = signal<Book[]>([]);
}
```

```html
<!-- book-list.html -->
<div class="row g-4" [@bookList]="books().length">
  @for (book of books(); track book._id) {
    <div class="col-sm-6 col-md-4 col-lg-3">
      <app-book-card [book]="book"></app-book-card>
    </div>
  }
</div>
```

```typescript
// login.ts — using fade and slideUp:
import { fadeAnimation, slideUpAnimation } from '../../../shared/animations';

@Component({
  animations: [fadeAnimation, slideUpAnimation],
})
export class Login {}
```

```html
<!-- login.html -->
<div class="auth-page" [@fade]>
  <div class="card border-book p-5 shadow" [@slideUp]>
    <h3 class="font-serif mb-4">Welcome Back</h3>
    <!-- form content -->

    @if (serverError()) {
      <div class="alert alert-danger" [@fade]>{{ serverError() }}</div>
    }
  </div>
</div>
```

---

# Expanded Quick Reference — Directives + NgModule + Animations

## Custom Directive Template

```typescript
@Directive({ selector: '[appMyDirective]', standalone: true })
export class MyDirective implements OnInit, OnDestroy {
  @Input('appMyDirective') config = '';   // match selector name for clean usage
  @Input() extraOption = false;           // secondary input

  @HostBinding('class.active') isActive = false;       // bind host element property
  @HostBinding('attr.aria-expanded') expanded = false; // bind host attribute

  @HostListener('click', ['$event'])   // listen to host event, get $event
  onClick(event: MouseEvent) { this.isActive = !this.isActive; }

  @HostListener('keydown.enter')  // only listen to Enter key
  onEnter() { this.isActive = !this.isActive; }

  constructor(
    private el: ElementRef<HTMLElement>,
    private renderer: Renderer2,
  ) {}

  ngOnInit() {
    // this.config is available here (not in constructor)
  }

  ngOnDestroy() {
    // clean up timers, subscriptions, DOM elements you created
  }
}
```

## NgModule vs Standalone Comparison

```
Feature              NgModule                    Standalone
─────────────────────────────────────────────────────────────
Component declares   In @NgModule.declarations   In @Component.imports
Imports              Via @NgModule.imports        Directly in @Component.imports
Sharing              Export from Module           Import the class directly
Bootstrapping        platformBrowserDynamic()     bootstrapApplication()
Lazy loading         loadChildren (module)        loadComponent (component)
Interceptors         HTTP_INTERCEPTORS token      withInterceptors([...])
Services             @NgModule.providers          providedIn: 'root'
Tree shaking         Limited                      Full
Introduced           Angular 2 (2016)             Angular 14+ (2022)
```

## Animation Quick Reference

```typescript
// Setup: provideAnimations() in app.config.ts

// In @Component:
animations: [
  trigger('name', [
    state('stateName', style({ cssProperty: 'value' })),
    transition('a => b',  [animate('300ms ease-out')]),
    transition(':enter',  [style({opacity:0}), animate('300ms', style({opacity:1}))]),
    transition(':leave',  [animate('200ms ease-in', style({opacity:0}))]),
    transition('* => *',  [animate('200ms')]),
  ])
]

// In template:
[@name]                    // always animating (auto state management)
[@name]="stateVar"         // bound to variable
(@name.start)="handler($event)"   // animation started
(@name.done)="handler($event)"    // animation completed
[@.disabled]="reducedMotion"      // disable subtree animations

// Key functions:
style({ ... })             // CSS properties object
animate('300ms ease-out')  // duration [delay] easing
animate('300ms', style({ ... }))  // with explicit end state
stagger(50, [animate(...)])        // 50ms between each child
query(':enter', [...], { optional: true })  // select entering children
group([animate(...), animate(...)])          // parallel animations
sequence([animate(...), animate(...)])       // sequential animations
keyframes([style({offset:0}), style({offset:1})])  // multi-step
```

*End of Part 5 (fully expanded). Part 6: Angular Material/CDK + Advanced Forms.*
