# 📓 Angular Complete Guide — Part 6 of 9
## Angular Material/CDK + Advanced Forms
> Hybrid: concept first, then bookstore application
> Expanded edition — every concept explained line by line

---

# TABLE OF CONTENTS

1. Angular Material — Complete Guide
   - What Angular Material is and when to use it
   - Installation and setup
   - Theming system — custom themes with CSS variables
   - Typography
   - Core components: Button, Input, Card, Toolbar, Sidenav
   - Form components: MatFormField, MatInput, MatSelect, MatDatepicker, MatCheckbox
   - Feedback components: MatSnackBar, MatDialog, MatProgressSpinner
   - Data components: MatTable, MatPaginator, MatSort
   - MatIcon — using Material Icons
   - Mixing Angular Material with Bootstrap (your project's approach)
   - CDK — Component Dev Kit overview
   - CDK Overlay — custom dropdowns and tooltips
   - CDK DragDrop — drag and drop lists

2. Advanced Forms
   - Cross-field validation — passwords must match
   - Async validators — check email availability via API
   - Dynamic FormArray — add/remove shipping addresses
   - Form builder — the shorter syntax
   - setValidators and clearValidators — dynamic validation rules
   - Nested FormGroups — complex form structures
   - Bookstore: checkout form with dynamic order items

---

---

# CHAPTER 1 — Angular Material: Complete Guide

## 1.1 What Angular Material Is

Angular Material is Google's official UI component library for Angular. It implements Google's Material Design specification — a design language with consistent patterns for buttons, inputs, dialogs, tables, and dozens of other components.

**When to use Angular Material vs Bootstrap:**

```
Bootstrap:
  ✅ Great for quick layouts (grid, spacing, utilities)
  ✅ Familiar to most web developers
  ✅ Your bookstore project already uses it
  ❌ Angular-specific interactivity requires extra work
  ❌ No built-in date pickers, data tables, or dialogs

Angular Material:
  ✅ Built specifically for Angular — deep integration with forms, CDK, DI
  ✅ Accessibility (ARIA) handled automatically
  ✅ Rich interactive components (date picker, autocomplete, stepper, etc.)
  ✅ Consistent design language out of the box
  ❌ Opinionated styling — harder to match a custom design
  ❌ Larger bundle size

Your bookstore uses Bootstrap for layout + some Material components for complex interactions.
A common real-world pattern.
```

---

## 1.2 Installation and Setup

```bash
# Install Angular Material (run in project root):
ng add @angular/material

# This command:
# 1. Installs @angular/material and @angular/cdk
# 2. Asks: which prebuilt theme? (choose "Custom" to control it yourself)
# 3. Asks: set up global typography? (yes)
# 4. Asks: set up browser animations? (yes)
# 5. Automatically updates app.config.ts and styles.scss
```

```typescript
// app.config.ts — after ng add @angular/material:
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';

export const appConfig: ApplicationConfig = {
  providers: [
    provideAnimationsAsync(), // replaces provideAnimations() — loads lazily
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([...])),
  ]
};
```

---

## 1.3 Theming — Matching Your Bookstore Colors

Angular Material uses a theming system based on CSS custom properties (CSS variables). You can match your bookstore's color palette.

```scss
// styles.scss — define the Material theme
@use '@angular/material' as mat;

// Include Material core styles (required once):
@include mat.core();

// Define your custom palette using bookstore colors:
$bookstore-primary: mat.define-palette(mat.$brown-palette, 900);
// mat.$brown-palette: Material's built-in brown palette
// 900: the darkest shade (matches --book-primary: #1a120b)

$bookstore-accent: mat.define-palette(mat.$amber-palette, 600);
// mat.$amber-palette: gold/amber palette (matches --book-accent: #d4a853)

$bookstore-warn: mat.define-palette(mat.$red-palette);
// Standard red for errors

$bookstore-theme: mat.define-light-theme((
  color: (
    primary: $bookstore-primary,
    accent: $bookstore-accent,
    warn: $bookstore-warn,
  ),
  typography: mat.define-typography-config(
    $font-family: 'Inter, sans-serif'
  ),
  density: 0, // 0 is default, -1 is compact, -2 is more compact
));

// Apply the theme:
@include mat.all-component-themes($bookstore-theme);
```

---

## 1.4 Core Components

### MatButton

```html
<!-- Import in component: imports: [MatButtonModule] -->
<button mat-button>Flat button</button>
<button mat-raised-button>Raised button</button>
<button mat-raised-button color="primary">Primary color</button>
<button mat-raised-button color="accent">Accent color</button>
<button mat-stroked-button>Outlined button</button>
<button mat-icon-button><mat-icon>delete</mat-icon></button>
<button mat-fab color="primary"><mat-icon>add</mat-icon></button>

<!-- Disabled state: -->
<button mat-raised-button [disabled]="loading">Submit</button>
```

### MatCard

```html
<!-- Import: imports: [MatCardModule] -->
<mat-card>
  <mat-card-header>
    <mat-card-title>{{ book.title }}</mat-card-title>
    <mat-card-subtitle>{{ book.author }}</mat-card-subtitle>
  </mat-card-header>
  <img mat-card-image [src]="book.coverImage" [alt]="book.title" />
  <mat-card-content>
    <p>{{ book.description }}</p>
  </mat-card-content>
  <mat-card-actions>
    <button mat-button>Add to Cart</button>
    <button mat-button>View Details</button>
  </mat-card-actions>
</mat-card>
```

---

## 1.5 Form Components — MatFormField, MatInput

Angular Material's form fields integrate with Angular's reactive forms.

```html
<!-- Import: imports: [MatFormFieldModule, MatInputModule, ReactiveFormsModule] -->

<mat-form-field appearance="outline">
  <!-- appearance: 'fill' (default), 'outline', 'standard' -->

  <mat-label>Email</mat-label>
  <!-- mat-label: floating label — starts inside the field, floats up when focused/filled -->

  <input matInput type="email" formControlName="email" placeholder="you@example.com" />
  <!-- matInput: directive that makes a native input work inside mat-form-field -->

  <mat-icon matPrefix>email</mat-icon>
  <!-- matPrefix: icon before the input -->

  <mat-icon matSuffix>visibility</mat-icon>
  <!-- matSuffix: icon after the input -->

  <mat-hint>We'll never share your email</mat-hint>
  <!-- hint text below the field -->

  <mat-error>
    <!-- mat-error: shows when the form control is invalid AND touched -->
    @if (loginForm.get('email')?.hasError('required')) {
      Email is required
    }
    @if (loginForm.get('email')?.hasError('email')) {
      Please enter a valid email
    }
  </mat-error>
  <!-- mat-error connects to the Angular form — automatically shows/hides -->
</mat-form-field>
```

---

## 1.6 MatSelect — Dropdown

```html
<!-- Import: imports: [MatSelectModule, MatFormFieldModule] -->

<mat-form-field appearance="outline">
  <mat-label>Sort By</mat-label>
  <mat-select formControlName="sortBy">
    <mat-option value="title">Title (A-Z)</mat-option>
    <mat-option value="price-asc">Price (Low to High)</mat-option>
    <mat-option value="price-desc">Price (High to Low)</mat-option>
    <mat-option value="rating">Highest Rated</mat-option>
  </mat-select>
</mat-form-field>

<!-- Multiple selection: -->
<mat-select formControlName="categories" multiple>
  @for (cat of categories; track cat.id) {
    <mat-option [value]="cat.id">{{ cat.name }}</mat-option>
  }
</mat-select>
```

---

## 1.7 MatSnackBar — Toast Notifications

```typescript
// Import in component: imports: [] — SnackBar is a service, not a component import
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({ ... })
export class BookList {
  private snackBar = inject(MatSnackBar);

  addToCart(book: Book) {
    this.cartService.addItem(book._id).subscribe({
      next: () => {
        this.snackBar.open(
          `"${book.title}" added to cart!`,  // message
          'View Cart',                         // action button text (optional)
          {
            duration: 3000,          // auto-dismiss after 3 seconds
            horizontalPosition: 'end', // 'start' | 'center' | 'end'
            verticalPosition: 'bottom', // 'top' | 'bottom'
            panelClass: 'success-snackbar' // custom CSS class
          }
        );

        // Handle action button click:
        // this.snackBar.open(...).onAction().subscribe(() => {
        //   this.router.navigate(['/cart']);
        // });
      }
    });
  }
}
```

---

## 1.8 MatDialog — Modal Dialogs

```typescript
// confirm-dialog.ts — the dialog component
@Component({
  standalone: true,
  imports: [MatButtonModule, MatDialogModule],
  template: `
    <h2 mat-dialog-title>{{ data.title }}</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button [mat-dialog-close]="false">Cancel</button>
      <button mat-raised-button color="warn" [mat-dialog-close]="true">Confirm</button>
    </mat-dialog-actions>
  `
})
export class ConfirmDialog {
  constructor(public data: { title: string; message: string }) {}
  // data: injected by MatDialog — contains values passed when opening
}
```

```typescript
// book-list.ts — opening the dialog
import { MatDialog } from '@angular/material/dialog';
import { ConfirmDialog } from './confirm-dialog/confirm-dialog';

@Component({ ... })
export class BookList {
  private dialog = inject(MatDialog);

  deleteBook(book: Book) {
    const dialogRef = this.dialog.open(ConfirmDialog, {
      width: '400px',
      data: {
        title: 'Delete Book',
        message: `Are you sure you want to delete "${book.title}"?`
      }
    });

    dialogRef.afterClosed().subscribe(confirmed => {
      // confirmed: the value passed to [mat-dialog-close]
      // true if user clicked Confirm, false if Cancel
      if (confirmed) {
        this.bookService.delete(book._id).subscribe(() => {
          this.loadBooks();
        });
      }
    });
  }
}
```

---

## 1.9 MatTable — Data Tables

```typescript
// book-table.ts
import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';

@Component({
  standalone: true,
  imports: [MatTableModule, MatSortModule, MatPaginatorModule],
  template: `
    <table mat-table [dataSource]="books">
      <ng-container matColumnDef="title">
        <th mat-header-cell *matHeaderCellDef mat-sort-header>Title</th>
        <td mat-cell *matCellDef="let book">{{ book.title }}</td>
      </ng-container>

      <ng-container matColumnDef="price">
        <th mat-header-cell *matHeaderCellDef>Price</th>
        <td mat-cell *matCellDef="let book">\${{ book.price }}</td>
      </ng-container>

      <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
      <tr mat-row *matRowDef="let row; columns: displayedColumns;"
          (click)="selectBook(row)"></tr>
    </table>

    <mat-paginator
      [length]="totalBooks"
      [pageSize]="10"
      [pageSizeOptions]="[5, 10, 25, 50]"
      (page)="onPageChange($event)">
    </mat-paginator>
  `
})
export class BookTable {
  books: Book[] = [];
  displayedColumns = ['title', 'price'];
  totalBooks = 0;

  onPageChange(event: PageEvent) {
    this.loadBooks(event.pageIndex + 1, event.pageSize);
  }
}
```

---

## 1.10 CDK — Component Dev Kit

The CDK is the lower-level toolkit that Angular Material is built on. Use it when you want powerful behavior without Material's visual opinions.

```typescript
// CDK DragDrop — drag to reorder a list:
import { DragDropModule, CdkDragDrop, moveItemInArray } from '@angular/cdk/drag-drop';

@Component({
  standalone: true,
  imports: [DragDropModule],
  template: `
    <div cdkDropList (cdkDropListDropped)="drop($event)">
      @for (item of items; track item) {
        <div cdkDrag class="drag-item">{{ item }}</div>
      }
    </div>
  `
})
export class DragList {
  items = ['Book 1', 'Book 2', 'Book 3'];

  drop(event: CdkDragDrop<string[]>) {
    moveItemInArray(this.items, event.previousIndex, event.currentIndex);
    // moveItemInArray: CDK helper — reorders the array in place
  }
}
```

---

---

# CHAPTER 2 — Advanced Forms

## 2.1 Cross-Field Validation — Passwords Must Match

Cross-field validation validates multiple fields together. A group-level validator receives the entire `FormGroup`.

```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

// Custom validator factory:
function passwordsMatchValidator(): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    // Cast to FormGroup to access specific controls:
    const password = group.get('password')?.value;
    const confirm  = group.get('confirmPassword')?.value;

    if (!password || !confirm) return null;
    // Don't validate if either field is empty — let 'required' handle that

    if (password !== confirm) {
      return { passwordsMismatch: true };
      // Return error object — key is the error name
    }

    return null; // valid — passwords match
  };
}
```

```typescript
// register.ts — apply to FormGroup:
registerForm = new FormGroup({
  firstName:       new FormControl('', [Validators.required]),
  lastName:        new FormControl('', [Validators.required]),
  email:           new FormControl('', [Validators.required, Validators.email]),
  password:        new FormControl('', [Validators.required, Validators.minLength(6)]),
  confirmPassword: new FormControl('', [Validators.required]),
}, {
  validators: [passwordsMatchValidator()]
  // Group-level validator — runs AFTER all field validators pass
});
```

```html
<!-- register.html — show the group-level error: -->
@if (registerForm.hasError('passwordsMismatch') && registerForm.get('confirmPassword')?.touched) {
  <div class="alert alert-danger py-2 small">Passwords do not match</div>
}
<!-- registerForm.hasError('passwordsMismatch'): checks the GROUP-level error -->
<!-- (not on an individual control — on the form itself) -->
```

---

## 2.2 Async Validators — Check Email Availability

An **async validator** performs an asynchronous check (usually an API call) and returns an Observable or Promise.

```typescript
// email-available.validator.ts
import { AbstractControl, ValidationErrors, AsyncValidatorFn } from '@angular/forms';
import { Observable, of } from 'rxjs';
import { debounceTime, switchMap, map, catchError, first } from 'rxjs/operators';

export function emailAvailableValidator(authService: AuthService): AsyncValidatorFn {
  // AsyncValidatorFn: a function that returns Observable<ValidationErrors | null>

  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value || !control.value.includes('@')) {
      return of(null);
      // of(null): creates an Observable that immediately emits null (valid)
      // No point checking availability if the email format is already invalid
    }

    return of(control.value).pipe(
      debounceTime(400),
      // debounceTime: wait 400ms after the last keystroke before calling the API
      // Without this: API is called on EVERY keystroke — terrible for performance

      switchMap(email =>
        authService.checkEmailAvailable(email).pipe(
          map(isAvailable => isAvailable ? null : { emailTaken: true }),
          // null: email is available — valid
          // { emailTaken: true }: email is taken — invalid

          catchError(() => of(null))
          // If the API call fails, treat as valid (don't block the user)
        )
      ),

      first()
      // first(): completes the Observable after the first emission
      // Required for async validators — Angular expects them to complete
    );
  };
}
```

```typescript
// In AuthService — add the check method:
checkEmailAvailable(email: string): Observable<boolean> {
  return this.http.get<{ available: boolean }>(`${this.api}/check-email`, {
    params: { email }
  }).pipe(
    map(res => res.available)
  );
}
```

```typescript
// register.ts — use the async validator:
registerForm = new FormGroup({
  email: new FormControl('', {
    validators: [Validators.required, Validators.email],         // sync validators
    asyncValidators: [emailAvailableValidator(this.authService)], // async validators
    updateOn: 'blur'
    // updateOn: when to run validation
    // 'change' (default): validate on every keystroke — too many API calls
    // 'blur': validate when user clicks away — better for async
    // 'submit': validate only when form is submitted
  }),
  // ...
});
```

```html
<!-- Show async validation state: -->
<mat-form-field appearance="outline">
  <mat-label>Email</mat-label>
  <input matInput formControlName="email" />

  <!-- While async validator is running: -->
  @if (registerForm.get('email')?.pending) {
    <mat-spinner matSuffix diameter="20"></mat-spinner>
  }

  <mat-error>
    @if (registerForm.get('email')?.hasError('required')) { Email is required }
    @if (registerForm.get('email')?.hasError('email')) { Invalid email format }
    @if (registerForm.get('email')?.hasError('emailTaken')) { This email is already registered }
  </mat-error>
</mat-form-field>
```

---

## 2.3 FormBuilder — The Shorter Syntax

`FormBuilder` is a service that provides a shorter syntax for creating form groups and controls.

```typescript
import { FormBuilder, Validators } from '@angular/forms';

// Without FormBuilder:
registerForm = new FormGroup({
  email:    new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required, Validators.minLength(6)]),
  dob:      new FormControl('', [Validators.required]),
});

// With FormBuilder — exactly equivalent but shorter:
private fb = inject(FormBuilder);

registerForm = this.fb.group({
  email:    ['', [Validators.required, Validators.email]],
  // Array: [initialValue, validators[], asyncValidators[]]
  password: ['', [Validators.required, Validators.minLength(6)]],
  dob:      ['', Validators.required],
  // Can pass single validator without array
});

// Even shorter — nonNullable FormBuilder (controls can't be null):
private fb = inject(NonNullableFormBuilder);
registerForm = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  // values are now string, not string | null
});
```

---

## 2.4 Dynamic FormArray — Add/Remove Shipping Addresses

`FormArray` manages a dynamic list of form controls or groups. Perfect for "add another address" type forms.

```typescript
// checkout.ts — order with multiple shipping options
import { Component } from '@angular/core';
import { FormBuilder, FormArray, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './checkout.html',
})
export class Checkout {
  private fb = inject(FormBuilder);

  checkoutForm = this.fb.group({
    paymentMethod: ['card', Validators.required],

    shippingAddress: this.fb.group({
      // Nested FormGroup for the main shipping address
      fullName: ['', [Validators.required, Validators.minLength(3)]],
      address:  ['', Validators.required],
      city:     ['', Validators.required],
      phone:    ['', [Validators.required, Validators.pattern('^[0-9]{11}$')]],
    }),

    orderNotes: [''],
  });

  // Getter — makes template access cleaner:
  get shippingAddress() {
    return this.checkoutForm.get('shippingAddress') as FormGroup;
  }

  submitOrder() {
    if (this.checkoutForm.invalid) {
      this.checkoutForm.markAllAsTouched();
      return;
    }
    console.log(this.checkoutForm.value);
  }
}
```

**Full dynamic FormArray example — admin book categories:**

```typescript
// admin-book-form.ts
@Component({ standalone: true, imports: [ReactiveFormsModule, CommonModule], ... })
export class AdminBookForm {
  private fb = inject(FormBuilder);

  bookForm = this.fb.group({
    title:  ['', Validators.required],
    price:  [0,  [Validators.required, Validators.min(0)]],
    authors: this.fb.array([
      // FormArray starts with one author field
      this.fb.control('', Validators.required)
    ])
  });

  // Getter for the FormArray:
  get authors() {
    return this.bookForm.get('authors') as FormArray;
  }

  addAuthor() {
    this.authors.push(this.fb.control('', Validators.required));
    // push() adds a new FormControl to the array
    // Template automatically re-renders to show the new field
  }

  removeAuthor(index: number) {
    if (this.authors.length > 1) {
      this.authors.removeAt(index);
      // removeAt() removes the control at the given index
    }
  }

  submitBook() {
    if (this.bookForm.invalid) return;
    console.log(this.bookForm.value);
    // { title: 'Clean Code', price: 29.99, authors: ['Robert Martin'] }
  }
}
```

```html
<!-- admin-book-form.html -->
<form [formGroup]="bookForm" (ngSubmit)="submitBook()">

  <div class="mb-3">
    <label class="form-label">Title</label>
    <input class="form-control" formControlName="title" />
  </div>

  <div class="mb-3">
    <label class="form-label">Price</label>
    <input class="form-control" type="number" formControlName="price" />
  </div>

  <!-- FormArray section: -->
  <div class="mb-3">
    <label class="form-label fw-semibold">Authors</label>

    <div formArrayName="authors">
    <!-- formArrayName="authors": connects this div to the 'authors' FormArray
         Children use [formControlName]="i" (index as name) -->

      @for (author of authors.controls; track $index; let i = $index) {
        <div class="input-group mb-2">
          <input class="form-control"
                 [formControlName]="i"
                 placeholder="Author name" />
          <!-- [formControlName]="i": binds to authors.controls[i]
               Note: uses [] (property binding) because i is a variable, not a string -->

          @if (authors.length > 1) {
            <button type="button" class="btn btn-outline-danger"
                    (click)="removeAuthor(i)">
              Remove
            </button>
          }
        </div>
        @if (authors.at(i).touched && authors.at(i).invalid) {
          <small class="text-danger">Author name is required</small>
        }
      }
    </div>

    <button type="button" class="btn btn-outline-secondary btn-sm"
            (click)="addAuthor()">
      + Add Another Author
    </button>
  </div>

  <button class="btn btn-book-primary" type="submit">Save Book</button>
</form>
```

---

## 2.5 setValidators and clearValidators — Dynamic Validation

Sometimes validation rules change based on other form values.

```typescript
// checkout.ts — if user selects "gift", require a message
checkoutForm = this.fb.group({
  isGift:      [false],
  giftMessage: [''],
  // Initially no validators on giftMessage
});

constructor() {
  // React to isGift changes:
  this.checkoutForm.get('isGift')!.valueChanges.subscribe(isGift => {
    const giftMessageControl = this.checkoutForm.get('giftMessage')!;

    if (isGift) {
      giftMessageControl.setValidators([Validators.required, Validators.maxLength(200)]);
      // Add validators when gift is selected
    } else {
      giftMessageControl.clearValidators();
      // Remove all validators when not a gift
    }

    giftMessageControl.updateValueAndValidity();
    // REQUIRED after setValidators/clearValidators
    // Forces Angular to re-run validation with the new rules
    // Without this, the control's validity status doesn't update
  });
}
```

---

## 2.6 Bookstore: Complete Checkout Form

```typescript
// checkout.ts
@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './checkout.html',
})
export class Checkout {
  private fb = inject(FormBuilder);
  private orderService = inject(OrderService);
  private router = inject(Router);

  loading = signal(false);
  serverError = signal('');

  checkoutForm = this.fb.group({
    shippingAddress: this.fb.group({
      fullName: ['', [Validators.required, Validators.minLength(3)]],
      address:  ['', Validators.required],
      city:     ['', Validators.required],
      phone:    ['', [Validators.required, Validators.pattern('^01[0-9]{9}$')]],
      // Egyptian phone number: starts with 01, 11 digits total
    }),
    paymentMethod: ['cash', Validators.required],
    orderNotes: [''],
  });

  get shipping() {
    return this.checkoutForm.get('shippingAddress') as FormGroup;
  }

  placeOrder() {
    if (this.checkoutForm.invalid) {
      this.checkoutForm.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    this.orderService.createOrder(this.checkoutForm.value).subscribe({
      next: (res) => {
        this.router.navigate(['/orders'], {
          state: { newOrder: res.data }
        });
      },
      error: (err) => {
        this.serverError.set(err.error?.message || 'Order failed');
        this.loading.set(false);
      }
    });
  }
}
```

```html
<!-- checkout.html -->
<div class="container py-5" style="max-width: 640px">
  <h3 class="font-serif mb-4">Checkout</h3>

  <form [formGroup]="checkoutForm" (ngSubmit)="placeOrder()">

    <!-- Nested FormGroup — use formGroupName directive: -->
    <div formGroupName="shippingAddress" class="card border-book p-4 mb-4">
      <h5 class="fw-semibold mb-3">Shipping Address</h5>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Full Name</label>
        <input class="form-control" formControlName="fullName" />
        @if (shipping.get('fullName')?.touched && shipping.get('fullName')?.invalid) {
          <small class="text-danger">Full name is required (min 3 characters)</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Street Address</label>
        <input class="form-control" formControlName="address" placeholder="123 Main St" />
        @if (shipping.get('address')?.touched && shipping.get('address')?.invalid) {
          <small class="text-danger">Address is required</small>
        }
      </div>

      <div class="row g-3 mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">City</label>
          <input class="form-control" formControlName="city" />
        </div>
        <div class="col-6">
          <label class="form-label small fw-semibold">Phone</label>
          <input class="form-control" formControlName="phone" placeholder="01XXXXXXXXX" />
          @if (shipping.get('phone')?.touched && shipping.get('phone')?.hasError('pattern')) {
            <small class="text-danger">Valid Egyptian phone required (01XXXXXXXXX)</small>
          }
        </div>
      </div>
    </div>

    <div class="card border-book p-4 mb-4">
      <h5 class="fw-semibold mb-3">Payment Method</h5>
      <div class="d-flex gap-3">
        <label class="d-flex align-items-center gap-2">
          <input type="radio" formControlName="paymentMethod" value="cash" /> Cash on Delivery
        </label>
        <label class="d-flex align-items-center gap-2">
          <input type="radio" formControlName="paymentMethod" value="card" /> Credit Card
        </label>
      </div>
    </div>

    @if (serverError()) {
      <div class="alert alert-danger">{{ serverError() }}</div>
    }

    <button class="btn btn-book-primary w-100 fw-bold py-2"
            type="submit" [disabled]="loading()">
      @if (loading()) {
        <span class="spinner-border spinner-border-sm me-2"></span>Placing Order...
      } @else {
        Place Order
      }
    </button>
  </form>
</div>
```

---

# Quick Reference Card — Material + Advanced Forms

## Angular Material Quick Reference

```typescript
// Install: ng add @angular/material

// Common module imports:
imports: [
  MatButtonModule,       // mat-button, mat-raised-button, mat-icon-button
  MatFormFieldModule,    // mat-form-field, mat-label, mat-error, mat-hint
  MatInputModule,        // matInput directive
  MatSelectModule,       // mat-select, mat-option
  MatCardModule,         // mat-card and sub-components
  MatDialogModule,       // mat-dialog-title, mat-dialog-content, mat-dialog-actions
  MatSnackBarModule,     // injected service: MatSnackBar
  MatTableModule,        // mat-table
  MatPaginatorModule,    // mat-paginator
  MatIconModule,         // mat-icon
]

// Injected services (no imports[] needed):
private snackBar = inject(MatSnackBar);
private dialog = inject(MatDialog);
```

## Advanced Forms Quick Reference

```typescript
// Cross-field validation (group-level):
new FormGroup({ ... }, { validators: [myGroupValidator()] })
registerForm.hasError('myError')  // read group-level error

// Async validator:
new FormControl('', { asyncValidators: [asyncFn(service)] })
control.pending  // true while async validator runs

// FormBuilder (shorter syntax):
private fb = inject(FormBuilder);
this.fb.group({ field: ['', Validators.required] })
this.fb.array([this.fb.control('', Validators.required)])

// FormArray:
get myArray() { return this.form.get('items') as FormArray; }
this.myArray.push(this.fb.control(''))    // add item
this.myArray.removeAt(index)              // remove item
this.myArray.at(index).value              // read item value

// Dynamic validators:
control.setValidators([Validators.required])
control.clearValidators()
control.updateValueAndValidity()  // ALWAYS call after set/clearValidators
```

---

*End of Part 6. Saved to outputs.*
*Part 7: HTTP Advanced + Performance (OnPush, trackBy, defer blocks)*

---

# CHAPTER 3 — Advanced Forms: Every Concept In Depth

## 3.7 The Form Value Object — What You Actually Get

Understanding what `.value` and `.getRawValue()` return prevents a very common bug.

```typescript
const checkoutForm = new FormGroup({
  fullName:      new FormControl('Ahmed'),
  email:         new FormControl({ value: 'a@test.com', disabled: true }),
  // disabled: the control exists but its value is excluded from .value
  shippingCity:  new FormControl('Cairo'),
});

checkoutForm.value;
// Returns: { fullName: 'Ahmed', shippingCity: 'Cairo' }
// email is MISSING — disabled controls are excluded from .value

checkoutForm.getRawValue();
// Returns: { fullName: 'Ahmed', email: 'a@test.com', shippingCity: 'Cairo' }
// getRawValue() includes disabled controls
// Use this when you need ALL values regardless of disabled state

// Practical example: email shown as read-only but needed in the API call
submitOrder() {
  const allValues = this.checkoutForm.getRawValue();
  // use allValues.email even though the field is disabled in the UI
}
```

---

## 3.8 updateOn — Controlling When Validation Runs

By default, validation runs on every keystroke (`updateOn: 'change'`). You can change this per-control or per-group.

```typescript
// Per-control:
const emailControl = new FormControl('', {
  validators: [Validators.required, Validators.email],
  updateOn: 'blur'
  // Validation only runs when user leaves the field (blur event)
  // Better UX: user can type their full email before seeing errors
});

// Per-group — all controls in the group use this setting:
const loginForm = new FormGroup({
  email:    new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required]),
}, { updateOn: 'submit' });
// Validation only runs when the form is submitted
// No real-time validation at all — only on submit attempt

// Available values:
// 'change'  — default: validates on every keystroke
// 'blur'    — validates when input loses focus
// 'submit'  — validates when form.updateValueAndValidity() is called or form submitted

// updateOn for async validators specifically (recommended 'blur' always):
new FormControl('', {
  validators: [Validators.required, Validators.email],
  asyncValidators: [emailAvailableValidator(authService)],
  updateOn: 'blur'
  // Don't check email availability on every keystroke — only when done typing
})
```

---

## 3.9 statusChanges — Reacting to Validation State

```typescript
// React to validity changes:
this.registerForm.get('email')!.statusChanges.subscribe(status => {
  // status: 'VALID' | 'INVALID' | 'PENDING' | 'DISABLED'

  if (status === 'PENDING') {
    // Async validator running — show spinner
    this.emailCheckLoading = true;
  } else {
    this.emailCheckLoading = false;
  }

  if (status === 'VALID') {
    console.log('Email is valid and available');
  }
});

// Useful for: showing indicators on async validation, enabling "Next" buttons
// in multi-step forms only when the current step is valid

this.registerForm.statusChanges.subscribe(formStatus => {
  // React to the whole form's validity
  this.canSubmit = formStatus === 'VALID';
});
```

---

## 3.10 Nested FormGroups — Building Complex Forms

For forms with logical sections, nest FormGroups inside FormGroups. Each nested group can have its own validators.

```typescript
// admin-create-book.ts — a complex book creation form
adminBookForm = new FormGroup({

  // Basic info section:
  basicInfo: new FormGroup({
    title:       new FormControl('', [Validators.required, Validators.minLength(2)]),
    isbn:        new FormControl('', [Validators.pattern('^[0-9]{13}$')]),
    publishYear: new FormControl(new Date().getFullYear(), [
      Validators.required,
      Validators.min(1800),
      Validators.max(new Date().getFullYear())
    ]),
  }),

  // Pricing section:
  pricing: new FormGroup({
    price:         new FormControl(0,     [Validators.required, Validators.min(0)]),
    originalPrice: new FormControl(null),  // null = no original price (not on sale)
    currency:      new FormControl('EGP', Validators.required),
  }),

  // Stock section:
  stock: new FormGroup({
    quantity:  new FormControl(0,    [Validators.required, Validators.min(0)]),
    warehouse: new FormControl('main'),
  }),

});

// Accessing nested controls:
this.adminBookForm.get('basicInfo.title')?.value;
// Dot notation: navigate the group path
// Equivalent to: this.adminBookForm.get('basicInfo')?.get('title')?.value

// Patching nested groups:
this.adminBookForm.patchValue({
  basicInfo: { title: 'Clean Code', isbn: '9780132350884' },
  pricing:   { price: 199, currency: 'EGP' },
});
// patchValue handles nested objects automatically

// Validity of a nested group:
this.adminBookForm.get('basicInfo')?.valid; // is the basicInfo section valid?
this.adminBookForm.get('pricing')?.valid;   // is the pricing section valid?
```

```html
<!-- admin-create-book.html — formGroupName for nested groups -->
<form [formGroup]="adminBookForm" (ngSubmit)="submit()">

  <!-- Section 1: basic info -->
  <div formGroupName="basicInfo" class="card p-4 mb-3">
    <h5>Basic Information</h5>
    <div class="mb-3">
      <label class="form-label">Title</label>
      <input class="form-control" formControlName="title" />
      @if (adminBookForm.get('basicInfo.title')?.touched &&
           adminBookForm.get('basicInfo.title')?.invalid) {
        <small class="text-danger">Title required (min 2 characters)</small>
      }
    </div>
    <div class="mb-3">
      <label class="form-label">ISBN (13 digits)</label>
      <input class="form-control" formControlName="isbn" placeholder="9780000000000" />
    </div>
  </div>

  <!-- Section 2: pricing -->
  <div formGroupName="pricing" class="card p-4 mb-3">
    <h5>Pricing</h5>
    <div class="row g-3">
      <div class="col-4">
        <label class="form-label">Price</label>
        <input class="form-control" type="number" formControlName="price" />
      </div>
      <div class="col-4">
        <label class="form-label">Original Price (optional)</label>
        <input class="form-control" type="number" formControlName="originalPrice" />
      </div>
      <div class="col-4">
        <label class="form-label">Currency</label>
        <select class="form-select" formControlName="currency">
          <option value="EGP">Egyptian Pound (EGP)</option>
          <option value="USD">US Dollar (USD)</option>
        </select>
      </div>
    </div>
  </div>

  <button class="btn btn-book-primary" type="submit"
          [disabled]="adminBookForm.invalid">
    Create Book
  </button>
</form>
```

---

## 3.11 FormArray Deep Dive — Order Items in Checkout

A checkout form where the user's cart items are displayed as form controls (e.g. editable quantities):

```typescript
// cart-checkout.ts
export class CartCheckout implements OnInit {
  private fb = inject(FormBuilder);
  private cartService = inject(CartService);

  checkoutForm = this.fb.group({
    items: this.fb.array([]),
    // Empty initially — populated in ngOnInit from CartService

    shippingAddress: this.fb.group({
      fullName: ['', Validators.required],
      address:  ['', Validators.required],
      city:     ['', Validators.required],
      phone:    ['', [Validators.required, Validators.pattern('^01[0-9]{9}$')]],
    }),

    paymentMethod: ['cash', Validators.required],
  });

  get items(): FormArray {
    return this.checkoutForm.get('items') as FormArray;
    // TypeScript requires explicit cast because .get() returns AbstractControl | null
  }

  ngOnInit() {
    this.cartService.getCart().subscribe(cart => {
      cart.items.forEach(item => {
        this.items.push(this.fb.group({
          bookId:    [item.book._id],         // hidden — not editable by user
          bookTitle: [{ value: item.book.title, disabled: true }], // shown but not editable
          quantity:  [item.quantity, [Validators.required, Validators.min(1), Validators.max(99)]],
          unitPrice: [{ value: item.book.price, disabled: true }], // shown but not editable
        }));
      });
    });
  }

  // Computed total from FormArray values:
  get orderTotal(): number {
    return this.items.controls.reduce((sum, control) => {
      const qty   = control.get('quantity')?.value || 0;
      const price = control.get('unitPrice')?.value || 0;
      // unitPrice is disabled — must use getRawValue() on the control:
      const rawPrice = (control as FormGroup).getRawValue().unitPrice;
      return sum + (qty * rawPrice);
    }, 0);
  }

  removeItem(index: number): void {
    this.items.removeAt(index);
    // Dynamically removes the item from the form — template updates automatically
  }

  submitOrder(): void {
    if (this.checkoutForm.invalid) {
      this.checkoutForm.markAllAsTouched();
      return;
    }

    const rawValues = this.checkoutForm.getRawValue();
    // getRawValue(): gets ALL values including disabled controls (bookTitle, unitPrice)
    // Regular .value would omit them

    const orderPayload = {
      items: rawValues.items.map((item: any) => ({
        bookId:   item.bookId,
        quantity: item.quantity,
      })),
      shippingAddress: rawValues.shippingAddress,
      paymentMethod:   rawValues.paymentMethod,
    };

    this.orderService.createOrder(orderPayload).subscribe({ ... });
  }
}
```

```html
<!-- cart-checkout.html — iterating a FormArray -->
<div formArrayName="items">
<!-- formArrayName="items": connects to the 'items' FormArray -->
  @for (item of items.controls; track $index; let i = $index) {
    <div [formGroupName]="i" class="d-flex align-items-center border-bottom py-3">
    <!-- [formGroupName]="i": connect to items.controls[i] (the i-th FormGroup in the array) -->
    <!-- Note: [formGroupName] uses property binding (brackets) because i is a variable -->

      <div class="flex-grow-1">
        <span class="fw-semibold">{{ item.get('bookTitle')?.value }}</span>
        <small class="text-muted d-block">
          EGP {{ item.getRawValue().unitPrice }} each
        </small>
      </div>

      <div class="d-flex align-items-center gap-2">
        <input class="form-control" type="number"
               formControlName="quantity"
               style="width: 80px" />
        <!-- quantity is editable — shows validation errors -->
        @if (item.get('quantity')?.invalid && item.get('quantity')?.touched) {
          <small class="text-danger">1–99</small>
        }

        <button type="button" class="btn btn-sm btn-outline-danger"
                (click)="removeItem(i)">
          ✕
        </button>
      </div>

      <div class="ms-3 fw-bold" style="width: 80px; text-align: right">
        EGP {{ (item.get('quantity')?.value || 0) * item.getRawValue().unitPrice | number:'1.0-0' }}
      </div>
    </div>
  }
</div>

<div class="d-flex justify-content-between fw-bold fs-5 mt-3 pt-3 border-top">
  <span>Total:</span>
  <span>EGP {{ orderTotal | number:'1.0-0' }}</span>
</div>
```

---

## 3.12 Common Form Mistakes and How to Fix Them

**Mistake 1: Forgetting to call `updateValueAndValidity()`**

```typescript
// WRONG:
control.setValidators([Validators.required]);
// The control's status doesn't update until something triggers validation
// The form might show valid even though the required validator was just added

// CORRECT:
control.setValidators([Validators.required]);
control.updateValueAndValidity();
// Forces Angular to re-run all validators and update status/errors
```

**Mistake 2: Reading `.value` instead of `.getRawValue()` for disabled controls**

```typescript
// If email is disabled:
this.form.value.email;           // undefined (disabled controls excluded)
this.form.getRawValue().email;   // 'k@test.com' (includes disabled)
```

**Mistake 3: Using `setValue` when `patchValue` is needed**

```typescript
// WRONG — if you add a new field to the form later, setValue breaks:
this.form.setValue({
  firstName: user.firstName,
  lastName: user.lastName,
  // If you add 'bio' to the form, you must add it here too or setValue throws
});

// CORRECT — patchValue handles partial updates gracefully:
this.form.patchValue({
  firstName: user.firstName,
  lastName: user.lastName,
  // New 'bio' field in the form? patchValue just ignores it unless you provide it
});
```

**Mistake 4: Not marking touched before showing errors on invalid submit**

```typescript
// WRONG — errors don't show because fields aren't touched:
submitForm() {
  if (this.form.invalid) return;
  // User clicks submit on empty form — nothing happens, no visible errors
}

// CORRECT:
submitForm() {
  this.form.markAllAsTouched();
  // Now all controls are marked touched → all error messages appear
  if (this.form.invalid) return;
  // User sees exactly which fields need fixing
}
```

---

# Expanded Quick Reference — Material + Advanced Forms

## Angular Material Module Imports Cheatsheet

```typescript
// In your component's imports[]:
MatButtonModule      // <button mat-button>, <button mat-raised-button color="primary">
MatFormFieldModule   // <mat-form-field>, <mat-label>, <mat-error>, <mat-hint>
MatInputModule       // matInput directive on <input> inside mat-form-field
MatSelectModule      // <mat-select>, <mat-option>
MatCardModule        // <mat-card>, <mat-card-header>, <mat-card-title>, <mat-card-content>, <mat-card-actions>
MatDialogModule      // mat-dialog-title, mat-dialog-content, mat-dialog-actions, [mat-dialog-close]
MatTableModule       // mat-table, matColumnDef, *matHeaderCellDef, *matCellDef
MatPaginatorModule   // <mat-paginator>
MatSortModule        // matSort, mat-sort-header
MatIconModule        // <mat-icon>icon_name</mat-icon>
MatProgressSpinnerModule  // <mat-spinner>, <mat-progress-spinner>
MatCheckboxModule    // <mat-checkbox formControlName="agree">
MatRadioModule       // <mat-radio-group>, <mat-radio-button>
MatDatepickerModule  // <mat-datepicker>, matDatepicker on input
MatAutocompleteModule // <mat-autocomplete>, matAutocomplete on input
MatChipsModule       // <mat-chip-listbox>, <mat-chip-option>
MatSnackBarModule    // injected: MatSnackBar service
MatTooltipModule     // matTooltip="Hint text" directive

// CDK:
DragDropModule       // cdkDropList, cdkDrag, moveItemInArray
ScrollingModule      // <cdk-virtual-scroll-viewport>, *cdkVirtualFor
OverlayModule        // programmatic overlay positioning
```

## Advanced Forms Cheatsheet

```typescript
// FormBuilder shorthand:
this.fb.group({ field: ['initialValue', [Validators.required]] })
this.fb.array([this.fb.control('', Validators.required)])
this.fb.nonNullable.group({ ... })  // values never null

// FormArray operations:
const arr = form.get('items') as FormArray;
arr.push(this.fb.control(''));     // add at end
arr.insert(0, this.fb.control('')); // add at index 0
arr.removeAt(2);                    // remove index 2
arr.clear();                        // remove all
arr.at(0).value                     // get value at index 0
arr.length                          // count

// Nested groups in template:
<div formGroupName="shipping">      <!-- string name -->
<div [formGroupName]="variableName"> <!-- variable name -->
<div formArrayName="items">         <!-- array name -->
<input [formControlName]="i">       <!-- index as name (in array) -->

// Get value including disabled:
form.getRawValue()

// Dynamic validators:
control.setValidators([Validators.required]);
control.clearValidators();
control.updateValueAndValidity(); // always call after set/clear

// Group-level validator:
new FormGroup({ ... }, { validators: [myValidator()] })
form.hasError('myErrorKey')  // read group-level error

// Async validator:
new FormControl('', { asyncValidators: [asyncFn(service)], updateOn: 'blur' })
control.pending  // true while running

// Mark all touched (show all errors on submit attempt):
form.markAllAsTouched();
```

*End of Part 6 (expanded). Part 7: HTTP Advanced + Performance.*

---

# CHAPTER 4 — Angular Material: Every Component In Practice

## 4.1 MatAutocomplete — Search with Suggestions

One of Material's most powerful form components — a text input that shows suggestions from an API.

```typescript
// book-search-autocomplete.ts
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { AsyncPipe } from '@angular/common';
import { Observable, of } from 'rxjs';
import { debounceTime, distinctUntilChanged, switchMap, startWith } from 'rxjs/operators';

@Component({
  selector: 'app-book-search-autocomplete',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatAutocompleteModule,
    MatFormFieldModule,
    MatInputModule,
    AsyncPipe,
  ],
  template: `
    <mat-form-field appearance="outline" style="width:100%">
      <mat-label>Search books...</mat-label>
      <input matInput
             [formControl]="searchControl"
             [matAutocomplete]="auto"
             placeholder="Start typing a title or author" />
      <!-- [matAutocomplete]="auto": connect input to the autocomplete panel below -->

      <mat-autocomplete
        #auto="matAutocomplete"
        (optionSelected)="onBookSelected($event)"
        [displayWith]="displayBookTitle">
        <!-- #auto: template reference used by [matAutocomplete]="auto" above -->
        <!-- (optionSelected): fires when user clicks/keys to select an option -->
        <!-- [displayWith]: function that converts the option value back to a display string -->
        <!--   Without displayWith: input shows '[object Object]' after selection -->

        @for (book of suggestions$ | async; track book._id) {
          <mat-option [value]="book">
            <!-- [value]="book": the value emitted by (optionSelected) -->
            {{ book.title }}
            <small class="text-muted ms-2">by {{ book.author }}</small>
          </mat-option>
        }
      </mat-autocomplete>
    </mat-form-field>
  `
})
export class BookSearchAutocomplete {
  private bookService = inject(BookService);
  private router = inject(Router);

  searchControl = new FormControl('');

  suggestions$: Observable<Book[]> = this.searchControl.valueChanges.pipe(
    startWith(''),
    // startWith(''): emit an initial value so the pipe runs immediately
    debounceTime(300),
    distinctUntilChanged(),
    switchMap(value => {
      if (typeof value !== 'string') return of([]);
      // After selection, value is a Book object — don't search for it again
      if (value.length < 2) return of([]);
      return this.bookService.search(value).pipe(
        map(res => res.data.slice(0, 8)), // show max 8 suggestions
        catchError(() => of([]))
      );
    })
  );

  displayBookTitle = (book: Book | null): string => {
    // Called by [displayWith] — converts Book object to display string
    return book ? book.title : '';
  };

  onBookSelected(event: MatAutocompleteSelectedEvent) {
    const book: Book = event.option.value;
    this.router.navigate(['/books', book._id]);
  }
}
```

---

## 4.2 MatStepper — Multi-Step Forms

Perfect for checkout, registration wizards, or any multi-step process:

```typescript
import { MatStepperModule, StepperOrientation } from '@angular/material/stepper';

@Component({
  standalone: true,
  imports: [MatStepperModule, ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatButtonModule],
  template: `
    <mat-stepper [linear]="true" orientation="vertical">
    <!-- linear: true — user must complete each step before proceeding -->
    <!-- orientation: 'vertical' or 'horizontal' -->

      <!-- STEP 1: Shipping -->
      <mat-step [stepControl]="shippingForm" label="Shipping Address">
      <!-- [stepControl]: the FormGroup for this step
           Linear mode uses stepControl.valid to decide if user can proceed -->

        <form [formGroup]="shippingForm">
          <mat-form-field appearance="outline">
            <mat-label>Full Name</mat-label>
            <input matInput formControlName="fullName" />
            <mat-error>Full name is required</mat-error>
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Address</mat-label>
            <input matInput formControlName="address" />
          </mat-form-field>
        </form>

        <div class="mt-3">
          <button mat-button matStepperNext [disabled]="shippingForm.invalid">
            Next
          </button>
          <!-- matStepperNext: directive that advances the stepper -->
        </div>
      </mat-step>

      <!-- STEP 2: Payment -->
      <mat-step [stepControl]="paymentForm" label="Payment">
        <form [formGroup]="paymentForm">
          <mat-form-field appearance="outline">
            <mat-label>Card Number</mat-label>
            <input matInput formControlName="cardNumber" maxlength="16" />
          </mat-form-field>
        </form>

        <div class="mt-3">
          <button mat-button matStepperPrevious>Back</button>
          <!-- matStepperPrevious: goes back one step -->
          <button mat-raised-button color="primary" matStepperNext
                  [disabled]="paymentForm.invalid">
            Review Order
          </button>
        </div>
      </mat-step>

      <!-- STEP 3: Review (no form control needed — just show summary) -->
      <mat-step label="Review & Place Order">
        <div class="p-3">
          <h4>Order Summary</h4>
          <p><strong>Ship to:</strong> {{ shippingForm.get('fullName')?.value }}</p>
          <p><strong>Address:</strong> {{ shippingForm.get('address')?.value }}</p>
        </div>
        <div class="mt-3">
          <button mat-button matStepperPrevious>Back</button>
          <button mat-raised-button color="accent" (click)="placeOrder()">
            Place Order
          </button>
        </div>
      </mat-step>
    </mat-stepper>
  `
})
export class CheckoutStepper {
  private fb = inject(FormBuilder);

  shippingForm = this.fb.group({
    fullName: ['', Validators.required],
    address:  ['', Validators.required],
    city:     ['', Validators.required],
  });

  paymentForm = this.fb.group({
    cardNumber: ['', [Validators.required, Validators.pattern('^[0-9]{16}$')]],
    expiry:     ['', Validators.required],
    cvv:        ['', [Validators.required, Validators.pattern('^[0-9]{3,4}$')]],
  });

  placeOrder() {
    const orderData = {
      shipping: this.shippingForm.value,
      payment:  this.paymentForm.value,
    };
    console.log('Order:', orderData);
  }
}
```

---

## 4.3 MatChips — Tag Selection

Good for category filters, tag systems, and multi-select with visual feedback:

```typescript
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';

@Component({
  standalone: true,
  imports: [MatChipsModule, MatIconModule, ReactiveFormsModule],
  template: `
    <mat-chip-listbox multiple [formControl]="categoriesControl">
    <!-- multiple: allow selecting multiple chips -->
    <!-- [formControl]: connect to FormControl -->

      @for (category of allCategories; track category.id) {
        <mat-chip-option [value]="category.id" color="accent">
        <!-- [value]: what gets added to formControl when selected -->
          {{ category.name }}
        </mat-chip-option>
      }
    </mat-chip-listbox>

    <small class="text-muted d-block mt-2">
      Selected: {{ categoriesControl.value?.join(', ') || 'All categories' }}
    </small>
  `
})
export class CategoryFilter {
  allCategories = [
    { id: 'fiction', name: 'Fiction' },
    { id: 'non-fiction', name: 'Non-Fiction' },
    { id: 'science', name: 'Science' },
    { id: 'history', name: 'History' },
    { id: 'biography', name: 'Biography' },
  ];

  categoriesControl = new FormControl<string[]>([], { nonNullable: true });
  // nonNullable: value is always string[] never null
}
```

---

## 4.4 CDK Overlay — Custom Dropdowns

The CDK Overlay gives you full control over positioning custom popups without the Material visual style:

```typescript
import { Overlay, OverlayConfig, OverlayRef } from '@angular/cdk/overlay';
import { TemplatePortal } from '@angular/cdk/portal';

@Component({
  standalone: true,
  imports: [],
  template: `
    <button (click)="toggleMenu()" #trigger>
      Sort: {{ selectedSort }} ▾
    </button>

    <ng-template #menuTemplate>
      <div class="custom-dropdown card shadow border-0">
        @for (option of sortOptions; track option.value) {
          <div class="dropdown-item py-2 px-3 cursor-pointer"
               [class.active]="option.value === selectedSort"
               (click)="selectSort(option.value)">
            {{ option.label }}
          </div>
        }
      </div>
    </ng-template>
  `
})
export class CustomSortDropdown {
  @ViewChild('trigger', { read: ElementRef }) triggerEl!: ElementRef;
  @ViewChild('menuTemplate') menuTemplate!: TemplateRef<any>;

  private overlay = inject(Overlay);
  private viewContainerRef = inject(ViewContainerRef);
  private overlayRef: OverlayRef | null = null;

  selectedSort = 'title';
  sortOptions = [
    { value: 'title',       label: 'Title (A-Z)' },
    { value: 'price-asc',   label: 'Price: Low to High' },
    { value: 'price-desc',  label: 'Price: High to Low' },
    { value: 'rating',      label: 'Highest Rated' },
    { value: 'newest',      label: 'Newest First' },
  ];

  toggleMenu() {
    if (this.overlayRef?.hasAttached()) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  private openMenu() {
    const positionStrategy = this.overlay
      .position()
      .flexibleConnectedTo(this.triggerEl)
      // flexibleConnectedTo: position relative to the trigger element
      .withPositions([
        {
          originX:  'start', originY:  'bottom',
          overlayX: 'start', overlayY: 'top',
          // Attach overlay's top-left to trigger's bottom-left
          // Creates a dropdown effect
        },
        {
          originX:  'start', originY:  'top',
          overlayX: 'start', overlayY: 'bottom',
          // Fallback: if not enough space below, open above
        }
      ]);

    this.overlayRef = this.overlay.create({
      positionStrategy,
      hasBackdrop: true,
      // hasBackdrop: click outside to close
      backdropClass: 'cdk-overlay-transparent-backdrop',
      // transparent backdrop — closing on click but no visible dim
      scrollStrategy: this.overlay.scrollStrategies.reposition(),
      // reposition: keeps dropdown aligned when page scrolls
    });

    this.overlayRef.backdropClick().subscribe(() => this.closeMenu());

    const portal = new TemplatePortal(this.menuTemplate, this.viewContainerRef);
    this.overlayRef.attach(portal);
  }

  private closeMenu() {
    this.overlayRef?.dispose();
    this.overlayRef = null;
  }

  selectSort(value: string) {
    this.selectedSort = value;
    this.closeMenu();
  }
}
```

---

## 4.5 Mixing Material with Bootstrap — Best Practices

Your bookstore uses Bootstrap for grid and spacing, Material for complex interactive components. Here's how to make them coexist cleanly:

```scss
// styles.scss — prevent conflicts:

// 1. Material uses box-sizing: border-box — Bootstrap does too. Compatible.

// 2. Material has its own typography system.
//    Don't let it override your Bootstrap text styles:
// After ng add @angular/material, if you chose typography:
// @include mat.typography-hierarchy($bookstore-theme);
// This sets global h1-h6, p, body styles — might conflict with Bootstrap.
// Safer: don't use mat.typography-hierarchy, use Bootstrap's typography instead.

// 3. Material buttons vs Bootstrap buttons:
// Use Material buttons for interactive app actions (forms, dialogs)
// Use Bootstrap buttons for navigation and simple links
// Don't mix them on the same UI element

// 4. Material form fields vs Bootstrap form fields:
// Pick ONE for each form — don't put mat-form-field and .form-control
// in the same form section. Mixed forms look inconsistent.
// Recommendation: use Bootstrap forms for your main app (login, register, profile)
// Use Material form fields for any admin UIs or complex components

// 5. Z-index conflicts — Material overlay uses z-index 1000+:
// Bootstrap dropdowns/modals also use z-index 1000+.
// If a Material dialog appears behind a Bootstrap modal, fix with:
.mat-mdc-dialog-container { z-index: 1060 !important; }
// (1060 > Bootstrap modal z-index of 1055)
```

---

## 4.6 Admin Panel with Material Table — Complete Implementation

```typescript
// admin-books.ts — full admin book management with Material
import {
  MatTableModule, MatTableDataSource
} from '@angular/material/table';
import { MatSortModule, Sort, MatSort } from '@angular/material/sort';
import { MatPaginatorModule, PageEvent, MatPaginator } from '@angular/material/paginator';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-admin-books',
  standalone: true,
  imports: [
    MatTableModule, MatSortModule, MatPaginatorModule,
    MatProgressSpinnerModule, MatButtonModule, MatIconModule,
    AsyncPipe
  ],
  template: `
    <div class="container py-4">
      <div class="d-flex justify-content-between mb-4">
        <h3 class="font-serif">Manage Books</h3>
        <button mat-raised-button color="accent" (click)="openCreateDialog()">
          <mat-icon>add</mat-icon> Add Book
        </button>
      </div>

      @if (loading) {
        <div class="text-center py-5">
          <mat-progress-spinner mode="indeterminate" diameter="48" color="accent">
          </mat-progress-spinner>
        </div>
      } @else {
        <table mat-table [dataSource]="dataSource" matSort (matSortChange)="onSortChange($event)"
               class="w-100 mat-elevation-z2">

          <!-- Title Column -->
          <ng-container matColumnDef="title">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Title</th>
            <td mat-cell *matCellDef="let book">
              <div class="d-flex align-items-center gap-2 py-2">
                <img [src]="book.coverImage" alt="" width="32" height="40"
                     style="object-fit:cover;border-radius:2px" />
                {{ book.title }}
              </div>
            </td>
          </ng-container>

          <!-- Author Column -->
          <ng-container matColumnDef="author">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Author</th>
            <td mat-cell *matCellDef="let book">{{ book.author }}</td>
          </ng-container>

          <!-- Price Column -->
          <ng-container matColumnDef="price">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Price</th>
            <td mat-cell *matCellDef="let book">{{ book.price | currency:'EGP':'symbol':'1.0-0' }}</td>
          </ng-container>

          <!-- Stock Column -->
          <ng-container matColumnDef="stock">
            <th mat-header-cell *matHeaderCellDef>Stock</th>
            <td mat-cell *matCellDef="let book">
              <span [class]="book.stock > 0 ? 'text-success' : 'text-danger'">
                {{ book.stock > 0 ? book.stock + ' units' : 'Out of stock' }}
              </span>
            </td>
          </ng-container>

          <!-- Actions Column -->
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let book">
              <button mat-icon-button color="primary" (click)="openEditDialog(book)"
                      matTooltip="Edit book">
                <mat-icon>edit</mat-icon>
              </button>
              <button mat-icon-button color="warn" (click)="confirmDelete(book)"
                      matTooltip="Delete book">
                <mat-icon>delete</mat-icon>
              </button>
            </td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns; sticky: true"></tr>
          <!-- sticky: true — header stays visible when table scrolls -->
          <tr mat-row *matRowDef="let row; columns: displayedColumns;"
              class="table-row-hover"></tr>
        </table>

        <mat-paginator
          [length]="totalBooks"
          [pageSize]="pageSize"
          [pageSizeOptions]="[10, 25, 50]"
          showFirstLastButtons
          (page)="onPageChange($event)">
        </mat-paginator>
      }
    </div>
  `
})
export class AdminBooks implements OnInit {
  private bookService = inject(BookService);
  private dialog      = inject(MatDialog);
  private snackBar    = inject(MatSnackBar);

  displayedColumns = ['title', 'author', 'price', 'stock', 'actions'];
  dataSource = new MatTableDataSource<Book>();
  // MatTableDataSource: Angular Material's table data container
  // Handles client-side sorting, filtering, and pagination

  loading    = true;
  totalBooks = 0;
  page       = 1;
  pageSize   = 10;
  sortField  = 'title';
  sortDir    = 'asc';

  ngOnInit() { this.loadBooks(); }

  loadBooks() {
    this.loading = true;
    this.bookService.getAdminBooks(this.page, this.pageSize, this.sortField, this.sortDir)
      .subscribe({
        next: res => {
          this.dataSource.data = res.data;
          this.totalBooks      = res.total;
          this.loading         = false;
        },
        error: () => { this.loading = false; }
      });
  }

  onSortChange(sort: Sort) {
    this.sortField = sort.active;
    this.sortDir   = sort.direction || 'asc';
    this.page      = 1;
    this.loadBooks();
  }

  onPageChange(event: PageEvent) {
    this.page     = event.pageIndex + 1;
    this.pageSize = event.pageSize;
    this.loadBooks();
  }

  confirmDelete(book: Book) {
    const ref = this.dialog.open(ConfirmDialog, {
      width: '380px',
      data: {
        title:   'Delete Book',
        message: `Delete "${book.title}"? This cannot be undone.`,
        danger:  true,
      }
    });

    ref.afterClosed().subscribe(confirmed => {
      if (!confirmed) return;
      this.bookService.deleteBook(book._id).subscribe({
        next: () => {
          this.snackBar.open(`"${book.title}" deleted`, 'Dismiss', { duration: 3000 });
          this.loadBooks();
        },
        error: () => this.snackBar.open('Delete failed. Please try again.', 'OK', { duration: 4000 })
      });
    });
  }

  openCreateDialog() { /* open create form dialog */ }
  openEditDialog(book: Book) { /* open edit form dialog with book data */ }
}
```

---

# CHAPTER 5 — Advanced Forms: Complete Patterns

## 5.1 Multi-Step Form with State Persistence

For long forms where users shouldn't lose progress if they navigate away:

```typescript
@Injectable({ providedIn: 'root' })
export class MultiStepFormService {
  // Persist form state across navigation (e.g. registration with profile setup)
  private formData: Partial<RegistrationData> = {};

  save(step: string, data: object): void {
    this.formData = { ...this.formData, [step]: data };
    // Also persist to sessionStorage (survives page refresh but not new tab):
    sessionStorage.setItem('registration_draft', JSON.stringify(this.formData));
  }

  load(): Partial<RegistrationData> {
    const stored = sessionStorage.getItem('registration_draft');
    if (stored) {
      try { this.formData = JSON.parse(stored); }
      catch { this.formData = {}; }
    }
    return this.formData;
  }

  clear(): void {
    this.formData = {};
    sessionStorage.removeItem('registration_draft');
  }
}

// In multi-step registration component:
export class RegistrationStep2 implements OnInit {
  private formService = inject(MultiStepFormService);

  step2Form = this.fb.group({
    dob:     ['', Validators.required],
    address: ['', Validators.required],
    phone:   ['', Validators.required],
  });

  ngOnInit() {
    // Restore progress if user navigated back:
    const saved = this.formService.load();
    if (saved.step2) {
      this.step2Form.patchValue(saved.step2);
    }
  }

  next() {
    if (this.step2Form.invalid) return;
    this.formService.save('step2', this.step2Form.value);
    this.router.navigate(['/register/step3']);
  }
}
```

---

## 5.2 Custom Validator: Min/Max Date

```typescript
import { AbstractControl, ValidatorFn } from '@angular/forms';

function minAgeValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl) => {
    if (!control.value) return null;

    const dob  = new Date(control.value);
    const today = new Date();

    // Calculate age:
    let age = today.getFullYear() - dob.getFullYear();
    const monthDiff = today.getMonth() - dob.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
      age--; // birthday hasn't happened yet this year
    }

    if (age < minAge) {
      return { minAge: { required: minAge, actual: age } };
      // The error object can carry extra info for the template
    }

    return null;
  };
}

// Usage:
dobControl = new FormControl('', [
  Validators.required,
  minAgeValidator(18),  // must be at least 18 years old
]);
```

```html
<!-- Template — read extra info from the error object: -->
@if (dobControl.touched && dobControl.hasError('minAge')) {
  <small class="text-danger">
    You must be at least {{ dobControl.getError('minAge').required }} years old.
    You are {{ dobControl.getError('minAge').actual }}.
  </small>
}
```

---

## 5.3 Form Submission Patterns — Loading States and Feedback

```typescript
// The complete pattern for form submission — covers all cases:
export class Register {
  registerForm = this.fb.group({ /* ... */ });
  loading   = signal(false);
  success   = signal(false);
  serverError = signal('');

  submitRegister() {
    // 1. Validate and show all errors if invalid:
    this.registerForm.markAllAsTouched();
    if (this.registerForm.invalid) return;

    // 2. Prevent double-submit:
    if (this.loading()) return;

    // 3. Clear previous server errors:
    this.serverError.set('');

    // 4. Show loading state:
    this.loading.set(true);

    // 5. Disable the form to prevent changes while submitting:
    this.registerForm.disable();

    this.authService.register(this.registerForm.getRawValue()).subscribe({
      next: () => {
        // 6. Success:
        this.success.set(true);
        setTimeout(() => this.router.navigate(['/auth/login']), 2000);
        // Show success for 2 seconds then redirect
      },
      error: (err) => {
        // 7. Error handling:
        this.serverError.set(err.error?.message || 'Registration failed. Please try again.');
        this.loading.set(false);
        this.registerForm.enable();
        // Re-enable form so user can fix the error

        // If it's a field-specific error (e.g. email taken), mark that field:
        if (err.error?.field === 'email') {
          this.registerForm.get('email')?.setErrors({ serverError: err.error.message });
          // setErrors: add a custom error to a specific control
          // The control becomes invalid and shows the error in the template
        }
      }
    });
  }
}
```

```html
<!-- Template — complete feedback pattern: -->
@if (success()) {
  <div class="alert alert-success d-flex align-items-center gap-2" [@fade]>
    <i class="fa-solid fa-circle-check"></i>
    Account created! Redirecting to sign in...
  </div>
} @else {
  <form [formGroup]="registerForm" (ngSubmit)="submitRegister()">
    <!-- form fields here -->

    @if (serverError()) {
      <div class="alert alert-danger" [@fade]>{{ serverError() }}</div>
    }

    <button class="btn btn-book-primary w-100" type="submit"
            [disabled]="loading() || success()">
      @if (loading()) {
        <span class="spinner-border spinner-border-sm me-2"></span>
        Creating account...
      } @else {
        Create Account
      }
    </button>
  </form>
}
```

---

# Expanded Quick Reference — Angular Material Full API

## MatSnackBar

```typescript
// Injected (no imports[] needed):
private snackBar = inject(MatSnackBar);

// Show simple message:
this.snackBar.open('Book added to cart!', 'OK', {
  duration: 3000,          // auto dismiss ms (0 = never)
  horizontalPosition: 'end',   // 'start' | 'center' | 'end'
  verticalPosition: 'bottom',  // 'top' | 'bottom'
  panelClass: 'success-snack', // custom CSS class
});

// Show with action button and handle click:
const ref = this.snackBar.open('Item removed', 'Undo', { duration: 5000 });
ref.onAction().subscribe(() => this.undoRemove());
ref.afterDismissed().subscribe(info => {
  // info.dismissedByAction: true if user clicked action button
});
```

## MatDialog

```typescript
// Injected:
private dialog = inject(MatDialog);

// Open:
const ref = this.dialog.open(MyDialogComponent, {
  width: '500px',
  maxHeight: '80vh',
  disableClose: true,      // prevent closing by clicking backdrop
  data: { id: '123', name: 'Test' },  // passed to component as DI
  panelClass: 'custom-dialog',
});

// In dialog component — access data:
constructor(
  public dialogRef: MatDialogRef<MyDialogComponent>,
  @Inject(MAT_DIALOG_DATA) public data: { id: string; name: string }
) {}

// Close programmatically:
this.dialogRef.close('some-result');  // result passed to afterClosed()

// Handle result:
ref.afterClosed().subscribe(result => {
  if (result) { /* user confirmed */ }
});
```

## MatTable with Server-Side Data

```typescript
// Don't use MatTableDataSource for server-side pagination/sort:
dataSource: Book[] = [];  // plain array is fine with mat-table

// Handle sort:
@ViewChild(MatSort) sort!: MatSort;
ngAfterViewInit() {
  this.sort.sortChange.subscribe(() => this.loadBooks());
}
loadBooks() {
  const { active, direction } = this.sort;
  this.bookService.getBooks(this.page, this.pageSize, active, direction)
      .subscribe(res => {
        this.dataSource = res.data;
        this.total = res.total;
      });
}
```

*End of Part 6 (fully expanded). Part 7: HTTP Advanced + Performance.*
