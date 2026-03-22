# 📕 Angular Complete Guide — Part 3 of 3
## Reactive Forms + All Pages + Navbar + Testing + Error Reference
> Written for Khaled | Bookstore Project | Angular 21 Standalone

---

# TABLE OF CONTENTS

1. Reactive Forms — The Complete Guide
   - Template-driven vs Reactive — the full comparison
   - FormControl — the atomic unit
   - FormGroup — grouping controls
   - FormArray — dynamic lists of controls
   - AbstractControl — the base class everything shares
   - Validators — built-in and custom
   - Form state: valid/invalid, touched/untouched, dirty/pristine, pending
   - Form state in templates — showing errors correctly
   - valueChanges and statusChanges — reacting to form changes
   - patchValue vs setValue
   - Getting form values
   - Resetting forms
   - Disabling and enabling controls

2. Building Every Page — Line by Line
   - Login page — complete with every annotation
   - Register page — complete with every annotation
   - Profile page — complete with every annotation
   - Not-Found page — complete with every annotation

3. Navbar — Connecting Everything
   - Full navbar.ts with every line explained
   - How the reactive chain works end-to-end

4. The Full Auth Flow — How It All Connects
   - Visualizing the entire flow from login to authenticated state

5. Testing Your Work — The Exact Steps
   - Setup checklist
   - Feature tests one by one
   - What to check in DevTools

6. Common Errors Reference — Every Error Explained
   - Compilation errors
   - Runtime errors
   - Logical errors that don't throw
   - How to diagnose each one

---

---

# CHAPTER 1 — Reactive Forms: The Complete Guide

## 1.1 Template-Driven vs Reactive — The Full Comparison

Angular offers two approaches to forms. Understanding why you use Reactive Forms (instead of Template-Driven) will help you never question the choice.

**Template-Driven Forms:**

```html
<!-- The form structure lives in the HTML -->
<form #myForm="ngForm" (ngSubmit)="submit(myForm)">
  <input name="email" [(ngModel)]="email" required email />
  <input name="password" [(ngModel)]="password" required />
  <button type="submit">Login</button>
</form>
```

```typescript
// TypeScript just receives the form
email = '';
password = '';
submit(form: NgForm) {
  if (form.valid) {
    // do something
  }
}
```

**The problems with Template-Driven:**
1. The form structure is hidden in the HTML — hard to read, hard to test
2. Validation is scattered across HTML attributes (`required`, `email`, `minlength`)
3. The TypeScript class is "blind" — it can't know the form's structure without inspecting the HTML
4. Asynchronous validators and dynamic forms are painful

**Reactive Forms:**

```typescript
// The form structure lives in TypeScript — TypeScript is the source of truth
loginForm = new FormGroup({
  email:    new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required]),
});
```

```html
<!-- HTML just displays the form — bound to TypeScript via names -->
<form [formGroup]="loginForm" (ngSubmit)="submit()">
  <input formControlName="email" />
  <input formControlName="password" />
</form>
```

**The advantages of Reactive:**
1. Form structure is fully in TypeScript — easy to read, easy to test, easy to manipulate
2. All validation logic is in TypeScript
3. TypeScript autocomplete works on form values
4. Dynamic forms are trivial (add/remove controls programmatically)
5. Async validators are first-class
6. `valueChanges` and `statusChanges` give you Observables to react to

---

## 1.2 FormControl — The Atomic Unit

A `FormControl` represents a single input in a form.

```typescript
import { FormControl, Validators } from '@angular/forms';

// Basic creation:
const emailControl = new FormControl('');
// First argument: initial value (empty string here)

// With validators:
const emailControl = new FormControl('', [
  Validators.required,  // value must not be empty
  Validators.email,     // value must be a valid email format
]);
// Second argument: validator or array of validators

// With initial value:
const nameControl = new FormControl('Khaled');
// Input will start pre-filled with "Khaled"

// Typed FormControl (Angular 14+):
const ageControl = new FormControl<number>(0);
// TypeScript knows this control holds a number, not just any value
```

**Reading a FormControl's value:**

```typescript
const control = new FormControl('hello');

control.value;              // 'hello' — current value
control.valid;              // true/false — passes all validators
control.invalid;            // opposite of valid
control.touched;            // true if user has clicked away from the input
control.untouched;          // opposite of touched
control.dirty;              // true if value has been changed from initial
control.pristine;           // opposite of dirty — value unchanged from initial
control.pending;            // true while async validators are running
control.errors;             // object of validation errors, or null if valid
                            // e.g. { required: true } or { email: true }
control.status;             // 'VALID', 'INVALID', 'PENDING', 'DISABLED'
control.disabled;           // true if control is disabled
```

**Modifying a FormControl:**

```typescript
control.setValue('new value');     // replace the value
control.patchValue('new value');   // same as setValue for FormControl
control.reset();                   // reset to initial value, clear touched/dirty
control.markAsTouched();           // mark as touched (trigger validation display)
control.markAsDirty();             // mark as dirty
control.markAsPristine();          // mark as pristine
control.disable();                 // disable the control (value excluded from form.value)
control.enable();                  // re-enable
```

---

## 1.3 FormGroup — Grouping Controls

A `FormGroup` is a collection of `FormControl` objects. It groups related controls and tracks the aggregate state.

```typescript
import { FormGroup, FormControl, Validators } from '@angular/forms';

const loginForm = new FormGroup({
  email:    new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required, Validators.minLength(6)]),
});

// FormGroup aggregates states:
loginForm.valid;    // true ONLY if ALL controls are valid
loginForm.invalid;  // true if ANY control is invalid
loginForm.touched;  // true if ANY control has been touched
loginForm.dirty;    // true if ANY control's value has changed

// Accessing individual controls:
loginForm.get('email');              // returns the email FormControl (or null)
loginForm.get('email')?.value;       // the email's current value
loginForm.get('email')?.errors;      // the email's current errors
loginForm.controls['email'];         // alternative access (same result)
loginForm.controls.email;            // also works in TypeScript

// Getting all values at once:
loginForm.value;
// Returns: { email: 'k@test.com', password: 'abc123' }
// Note: disabled controls are EXCLUDED from .value
// Use loginForm.getRawValue() to include disabled controls

// Nested FormGroup:
const userForm = new FormGroup({
  name: new FormGroup({
    first: new FormControl(''),
    last:  new FormControl(''),
  }),
  email: new FormControl(''),
});
// Access nested: userForm.get('name.first') or userForm.get('name')?.get('first')
```

---

## 1.4 FormArray — Dynamic Lists of Controls

`FormArray` holds an array of `FormControl` or `FormGroup` objects. Used when the number of inputs isn't fixed (e.g., adding multiple phone numbers, multiple addresses).

```typescript
import { FormArray, FormControl, FormGroup } from '@angular/forms';

// Creating a FormArray:
const phonesForm = new FormGroup({
  name: new FormControl(''),
  phones: new FormArray([
    new FormControl('0100000000'),  // initial phone
  ])
});

// Access the FormArray:
const phonesArray = phonesForm.get('phones') as FormArray;

// Add a control dynamically:
phonesArray.push(new FormControl(''));

// Remove a control:
phonesArray.removeAt(0);

// Get all values:
phonesArray.value; // ['0100000000', '0112345678']
```

You don't use `FormArray` in your current project, but knowing it exists will be useful for the cart item list, order items, and any future dynamic forms.

---

## 1.5 AbstractControl — The Base Class

`FormControl`, `FormGroup`, and `FormArray` all extend `AbstractControl`. That's why they share the same properties (`value`, `valid`, `touched`, etc.) and methods (`setValue`, `reset`, `markAsTouched`, etc.).

When you see `AbstractControl` as a type (e.g., in custom validators), it means the validator works for any of the three types.

---

## 1.6 Validators — Built-In and Custom

**Built-in validators:**

```typescript
import { Validators } from '@angular/forms';

Validators.required        // value must not be empty/null/''
Validators.email           // value must match email format (basic check)
Validators.minLength(6)    // value must be at least 6 characters long
Validators.maxLength(50)   // value must be at most 50 characters long
Validators.min(0)          // numeric value must be >= 0
Validators.max(100)        // numeric value must be <= 100
Validators.pattern('^[0-9]+$') // value must match the regex pattern
Validators.nullValidator   // does nothing (useful as a placeholder)

// Combining validators — pass an array:
new FormControl('', [Validators.required, Validators.email, Validators.maxLength(100)])
```

**What validators return:**

A validator is a function that returns:
- `null` if the value is valid
- An object with the error name as key if invalid

```typescript
// The Validators.required function looks roughly like this:
function required(control: AbstractControl): ValidationErrors | null {
  return control.value ? null : { required: true };
  // null = valid
  // { required: true } = invalid, with error named 'required'
}

// Validators.email looks roughly like:
function email(control: AbstractControl): ValidationErrors | null {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(control.value) ? null : { email: true };
  // null = valid email
  // { email: true } = invalid, error named 'email'
}
```

**Custom validator:**

```typescript
import { AbstractControl, ValidationErrors } from '@angular/forms';

// A validator that checks if two password fields match:
function passwordsMatch(group: AbstractControl): ValidationErrors | null {
  const password = group.get('password')?.value;
  const confirm  = group.get('confirmPassword')?.value;

  if (password !== confirm) {
    return { passwordsMismatch: true };
    // The key 'passwordsMismatch' becomes the error name
  }
  return null; // valid
}

// Apply to a FormGroup:
const registerForm = new FormGroup({
  password:        new FormControl('', [Validators.required]),
  confirmPassword: new FormControl('', [Validators.required]),
}, { validators: [passwordsMatch] }); // group-level validator
```

---

## 1.7 Form State — All the Properties Explained

Every form control and form group has these state properties:

```
valid / invalid
  valid:   ALL validators pass → no errors
  invalid: AT LEAST ONE validator fails → has errors
  These are always opposites: if valid is true, invalid is false and vice versa

touched / untouched
  touched:   the user has clicked on the input AND clicked away (blur event)
  untouched: the user has never interacted with this input
  We show validation errors ONLY when touched:
    If we showed errors from the start, the user sees red before they've even tried

dirty / pristine
  dirty:    the value has changed from the initial value
  pristine: the value is the same as when the form was created/reset
  Example: form starts with email='', user types something → dirty
           user deletes everything back to '' → STILL dirty (it was modified)

pending
  Only true when ASYNC validators are running
  Example: checking if username is already taken via API call
  Angular shows 'PENDING' status while waiting for the async validator to respond

disabled / enabled
  disabled: the control is not editable AND its value is excluded from form.value
  enabled:  normal state
```

---

## 1.8 Form State in Templates — Showing Errors Correctly

```html
<!-- Pattern you'll use everywhere: -->
@if (form.get('email')?.touched && form.get('email')?.invalid) {
  <small class="text-danger">Please enter a valid email</small>
}

<!-- Why BOTH touched AND invalid?

  If only invalid:
    - Errors show before the user even focuses the input
    - User sees red on an empty form → bad UX

  If only touched:
    - Even if the field is valid, "touched" is true after user interacts
    - You'd show error messages for valid inputs

  Both together:
    - Only show errors when the user has interacted AND the value is wrong
    - Perfect UX: no noise before interaction, clear feedback after -->

<!-- Checking specific errors: -->
@if (form.get('password')?.touched) {
  @if (form.get('password')?.hasError('required')) {
    <small class="text-danger">Password is required</small>
  }
  @if (form.get('password')?.hasError('minlength')) {
    <small class="text-danger">
      Password must be at least {{ form.get('password')?.getError('minlength')?.requiredLength }} characters
    </small>
    <!-- getError('minlength') returns: { requiredLength: 6, actualLength: 3 } -->
  }
}

<!-- Checking the entire form's validity (for submit button): -->
<button [disabled]="loginForm.invalid || loading" type="submit">
  Submit
</button>
<!-- Button is disabled if ANY field is invalid OR while the API call is loading -->

<!-- Showing form-level success/error: -->
@if (serverError) {
  <div class="alert alert-danger">{{ serverError }}</div>
}
@if (successMessage) {
  <div class="alert alert-success">{{ successMessage }}</div>
}
```

---

## 1.9 valueChanges and statusChanges

Every `FormControl` and `FormGroup` has Observable streams you can subscribe to:

```typescript
// Subscribe to value changes:
this.loginForm.get('email')!.valueChanges.subscribe(value => {
  console.log('Email changed to:', value);
  // Runs on every keystroke
});

// Subscribe to the whole form's value changes:
this.loginForm.valueChanges.subscribe(formValue => {
  console.log('Form value:', formValue); // { email: '...', password: '...' }
});

// Subscribe to validation status changes:
this.loginForm.statusChanges.subscribe(status => {
  console.log('Form status:', status); // 'VALID', 'INVALID', 'PENDING'
});

// Practical use — auto-save draft:
this.profileForm.valueChanges.pipe(
  debounceTime(500) // wait 500ms after last change before acting
).subscribe(value => {
  localStorage.setItem('profile-draft', JSON.stringify(value));
});
```

---

## 1.10 patchValue vs setValue

```typescript
const profileForm = new FormGroup({
  firstName: new FormControl(''),
  lastName:  new FormControl(''),
  dob:       new FormControl(''),
});

// setValue — must provide values for ALL fields:
profileForm.setValue({
  firstName: 'Khaled',
  lastName:  'Mohamed',
  dob:       '2000-01-15',
  // ❌ Error if you omit any field: "Must supply a value for form control with name: 'dob'"
});

// patchValue — can provide values for SOME fields:
profileForm.patchValue({
  firstName: 'Khaled',
  // lastName and dob remain unchanged
});
// ✅ No error — missing fields are simply not updated

// When to use each:
// setValue: when you have ALL values (replacing everything)
// patchValue: when you have SOME values (updating specific fields)

// In your Profile page:
this.profileForm.patchValue({
  firstName: user.firstName,
  lastName:  user.lastName,
  dob:       user.dob,
});
// patchValue is correct here — the form might have more fields in the future
// and we don't want to be forced to provide values for all of them
```

---

---

# CHAPTER 2 — Building Every Page

## 2.1 Login Page — Every Line Explained

### login.ts

```typescript
import { Component } from '@angular/core';
// Component: the decorator that turns this class into an Angular component

import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
// FormControl:          represents one form input
// FormGroup:            groups multiple FormControls together
// ReactiveFormsModule:  the Angular module that enables [formGroup] and formControlName in templates
// Validators:           built-in validation rules (required, email, minLength, etc.)

import { Router, RouterLink } from '@angular/router';
// Router:    service for programmatic navigation (this.router.navigate(['/books']))
// RouterLink: directive that enables routerLink="/path" in templates

import { CommonModule } from '@angular/common';
// CommonModule: provides NgIf, NgFor, NgClass, etc. (older directives)
// In Angular 17+, @if and @for are built-in — CommonModule is less required
// Still included for safety and for any pipes it provides

import { AuthService } from '../../../core/services/auth.service';
// Our AuthService — needed to call .login()
// Path: going up 3 levels from features/auth/login/ to reach the root src/app/
//       then down into core/services/

@Component({
  selector: 'app-login',
  // The HTML tag name: <app-login></app-login>
  // Used internally by Angular's router — not manually placed anywhere

  standalone: true,
  // This component manages its own dependencies
  // No NgModule needed — imports array handles everything

  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  // CommonModule: optional, safe to include
  // ReactiveFormsModule: REQUIRED — without it, [formGroup] and formControlName won't work
  // RouterLink: REQUIRED — without it, routerLink="/auth/register" won't work
  // If you forget ReactiveFormsModule, Angular throws:
  //   "Can't bind to 'formGroup' since it isn't a known property of 'form'"

  templateUrl: './login.html',
  // Path to the HTML template file — relative to THIS TypeScript file
  // Could also be: template: '<div>inline html</div>' but files are cleaner

  styleUrl: './login.css',
  // Path to the CSS file — styles here are SCOPED to this component only
  // A class named .card in login.css does NOT affect .card in other components
  // Angular achieves this by adding a unique attribute to your HTML elements
})
export class Login {
  // export: makes this class importable by the router (in app.routes.ts)

  loading = false;
  // boolean flag: true while API call is in flight
  // Used to: show spinner on button, disable button to prevent double-submit

  serverError = '';
  // string: stores error message from the backend (e.g. "Invalid credentials")
  // Empty string by default — @if (serverError) is false when empty → hidden

  loginForm = new FormGroup({
    // FormGroup: groups the email and password controls together
    // The object keys ('email', 'password') become the control NAMES
    // These names MUST match the formControlName attributes in the HTML

    email: new FormControl('', [Validators.required, Validators.email]),
    // FormControl constructor: (initialValue, validators[])
    // '': starts empty
    // Validators.required: value cannot be empty/null/''
    // Validators.email: value must look like an email (basic regex check)

    password: new FormControl('', [Validators.required]),
    // Only required — no format validation on password (backend validates length etc.)
  });

  constructor(private auth: AuthService, private router: Router) {}
  // Constructor injection of two dependencies
  // private auth: stored as this.auth — used to call this.auth.login()
  // private router: stored as this.router — used to call this.router.navigate()
  // Empty body: no initialization logic needed here — that goes in ngOnInit()
  // But Login doesn't implement OnInit — it has no initial data to load

  submitLogin() {
    // Called when the form is submitted (via (ngSubmit) in the template)

    if (this.loginForm.invalid) return;
    // loginForm.invalid is true if ANY control fails its validators
    // Early return: don't proceed if the form has errors
    // Why don't we need to show errors here? Angular automatically marks all
    // controls as "touched" when the form is submitted (since Angular 14)
    // — actually Angular does NOT auto-mark on submit by default
    // We handle this by checking touched in the template
    // Pro tip: add this.loginForm.markAllAsTouched() to show all errors on submit attempt

    this.loading = true;
    // Disable the button and show spinner
    // Change detection will run after this assignment and update the template

    this.serverError = '';
    // Clear any previous server error — we're starting a fresh attempt

    const { email, password } = this.loginForm.value;
    // Destructuring: extract email and password from the form's value object
    // loginForm.value returns: { email: 'k@test.com', password: 'abc123' }
    // Same as: const email = this.loginForm.value.email;
    //          const password = this.loginForm.value.password;

    this.auth.login(email!, password!).subscribe({
    // auth.login() returns an Observable — nothing happens until subscribe()
    // The ! after email and password: non-null assertion
    //   TypeScript types these as string | null | undefined because FormControl values can be null
    //   We KNOW they're not null here (form is valid — values exist)
    //   ! tells TypeScript to treat them as string

      next: () => {
        // Called when login succeeds (HTTP 200 response)
        // Note: no parameter needed — we don't use the response here
        // AuthService already saved the token in the tap() operator
        this.router.navigate(['/books']);
        // Navigate to the books page
        // ['/books']: array syntax — first element is the path
        // No need to set loading = false — we're navigating away from this component
      },
      error: (err) => {
        // Called when login fails (HTTP 400, 401, 422, 500, network error, etc.)
        this.serverError = err.error?.message || 'Login failed. Please try again.';
        // err.error: the backend's response body (parsed JSON)
        // err.error?.message: our backend's custom message field (optional chaining in case err.error is null)
        // || 'Login failed...': fallback if no message from backend
        this.loading = false;
        // Re-enable the button so user can try again
      },
    });
    // Note: no complete: handler needed
    // HttpClient Observables complete automatically after the response
    // loading is set to false in error handler and not needed in next (we navigate away)
  }
}
```

### login.html — Every Attribute Explained

```html
<div class="d-flex justify-content-center align-items-center"
     style="min-height: calc(100vh - 60px); background: var(--book-bg)">
<!-- Outer wrapper:
  d-flex: Bootstrap flexbox container
  justify-content-center: center horizontally
  align-items-center: center vertically
  min-height: at least full viewport minus navbar (60px)
  background: uses the CSS variable from styles.css (--book-bg: #fdfaf5) -->

  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 440px">
  <!-- Card container:
    border-book: custom class from styles.css (border-color: var(--book-border))
    shadow-sm: Bootstrap light shadow
    p-4: Bootstrap padding 4 (1.5rem all sides)
    fade-in: custom animation class from styles.css (fadeIn keyframe)
    max-width: prevents card from being too wide on large screens -->

    <h3 class="text-center font-serif mb-1">Welcome Back</h3>
    <!-- font-serif: uses Playfair Display font (defined in styles.css) -->

    <p class="text-center text-muted mb-4 small">Sign in to your account</p>

    <form [formGroup]="loginForm" (ngSubmit)="submitLogin()">
    <!-- [formGroup]="loginForm":
       Square brackets = property binding
       Connects this <form> element to the loginForm FormGroup in TypeScript
       Angular now tracks this form's state through the TypeScript class
       Without this: formControlName attributes below would throw errors

    (ngSubmit)="submitLogin()":
       Parentheses = event binding
       Listens to the form's ngSubmit event
       ngSubmit fires when: user clicks type="submit" button, OR presses Enter in an input
       It's Angular's version of the native 'submit' event
       Why ngSubmit instead of (submit)?
         ngSubmit prevents the browser's default form submission behavior
         (which would cause a full page reload)
         Angular handles it entirely in JavaScript -->

      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>

        <input class="form-control" type="email"
               formControlName="email"
               placeholder="you&#64;example.com" />
        <!-- formControlName="email":
           No square brackets — it's a static string attribute (not a bound expression)
           Connects this <input> to loginForm.controls['email']
           Angular now: reads this input's value from/to the FormControl,
                        applies the validators you defined in TypeScript,
                        tracks touched/dirty/valid state for this input

        placeholder="you&#64;example.com":
           &#64; is the HTML entity for @
           Direct @ in attribute values can sometimes confuse Angular's template parser
           Using the entity is safer and is the recommended practice in Angular templates

        type="email":
           HTML5 email type: shows @ keyboard on mobile, enables browser autocomplete
           Angular's Validators.email does NOT rely on this — it validates in TypeScript
           type="email" is for browser UX, Validators.email is for app logic -->

        @if (loginForm.get('email')?.touched && loginForm.get('email')?.invalid) {
        <!-- loginForm.get('email'): returns the FormControl for 'email' (or null)
           ?.touched: optional chaining — safe if get() returns null
           && (AND): BOTH conditions must be true to show the error

           Condition 1: touched — user has clicked on this field and then away
           Condition 2: invalid — the value fails at least one validator

           WHY both conditions?
           On first page load: touched=false, invalid=true (empty field fails required)
           → We DON'T show the error (user hasn't tried yet)

           After user clicks field and types 'notvalid':
           → touched=true, invalid=true (fails Validators.email)
           → We DO show the error

           After user types 'k@test.com':
           → touched=true, invalid=false (all validators pass)
           → We DON'T show the error (valid input!) -->

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

      @if (serverError) {
      <!-- serverError is a string — empty string is falsy in JavaScript
           When serverError = '': @if is false → error div is NOT in the DOM
           When serverError = 'Invalid credentials': @if is true → shows the alert -->
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
        <!-- {{ serverError }}: text interpolation — renders the string as text
             Automatically HTML-escapes the content — no XSS risk
             py-2: Bootstrap vertical padding reduced (compact alert)
             small: smaller font size for inline messages -->
      }

      <button class="btn btn-book-primary w-100 fw-bold py-2"
              type="submit"
              [disabled]="loading">
      <!-- type="submit": clicking this triggers the form's submit event
           → (ngSubmit) fires → submitLogin() is called

      [disabled]="loading":
         Property binding — binds the disabled DOM property to the loading variable
         When loading=true: button becomes disabled (can't click), prevents double-submit
         When loading=false: button is clickable
         The square brackets: makes it a dynamic expression, not the static "disabled" attribute
         [disabled]="true" is different from disabled (without brackets):
           disabled (no brackets): always disabled — static attribute
           [disabled]="loading" (with brackets): conditionally disabled based on variable -->

        @if (loading) {
          <span class="spinner-border spinner-border-sm me-2"></span>Signing in...
          <!-- Bootstrap spinner — shows while API call is in flight
               spinner-border-sm: small spinner size
               me-2: margin-end (right margin) to separate spinner from text -->
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
        <!-- routerLink="/auth/register":
             Angular's routing directive — handles navigation without full page reload
             Generates an <a href="/auth/register"> but intercepts the click
             Angular's router handles it: changes URL, loads Register component
             NEVER use href="/auth/register" — that causes a full page reload
             RouterLink must be in the component's imports array to work here -->
      </small>
    </div>
  </div>
</div>
```

---

## 2.2 Register Page — Explained

### register.ts

```typescript
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
  // Three state variables:
  // loading: disable form while submitting
  // serverError: backend error message (email already exists, validation failed, etc.)
  // successMessage: confirmation after successful registration

  registerForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    // minLength(2): at least 2 characters — single-letter names would be rejected

    lastName: new FormControl('', [Validators.required, Validators.minLength(2)]),

    email: new FormControl('', [Validators.required, Validators.email]),

    password: new FormControl('', [Validators.required, Validators.minLength(6)]),
    // minLength(6): minimum password length — matches your backend validation

    dob: new FormControl('', [Validators.required]),
    // dob: date of birth, as an ISO date string ("2000-01-15")
    // HTML type="date" input gives us a string in YYYY-MM-DD format
    // Backend expects 'dob' field — matches your User model
  });

  constructor(private auth: AuthService, private router: Router) {}

  submitRegister() {
    if (this.registerForm.invalid) return;

    this.loading = true;
    this.serverError = '';
    this.successMessage = '';
    // Clear both messages at the start of each attempt

    const { firstName, lastName, email, password, dob } = this.registerForm.value;
    // Destructure all five fields from the form value
    // All have type string | null | undefined (FormControl's value type)
    // We use ! to assert non-null (safe because form is valid at this point)

    this.auth.register({
      firstName: firstName!,
      lastName:  lastName!,
      email:     email!,
      password:  password!,
      dob:       dob!,
    }).subscribe({
      next: () => {
        this.successMessage = 'Account created! Redirecting to sign in...';
        // Show success message FIRST — give user feedback immediately
        // Then wait 1.5 seconds before navigating (so they can read the message)

        setTimeout(() => {
          this.router.navigate(['/auth/login']);
          // setTimeout: browser API — calls the function after the delay
          // 1500ms = 1.5 seconds — enough time to read the message
          // Why not navigate immediately? UX — user should see confirmation
          // Why not stay on register? They need to log in now — send them to login
        }, 1500);
      },
      error: (err) => {
        this.serverError = err.error?.message || 'Registration failed. Please try again.';
        // Common errors: "Email already registered", "Validation failed"
        this.loading = false;
      },
    });
  }
}
```

### register.html

```html
<div class="d-flex justify-content-center align-items-center py-5"
     style="min-height: calc(100vh - 60px); background: var(--book-bg)">
<!-- py-5: extra vertical padding (page is taller due to more fields — needs scroll room) -->

  <div class="card border-book shadow-sm p-4 fade-in" style="width: 100%; max-width: 480px">
  <!-- max-width: 480px — slightly wider than login (440px) to accommodate two-column name row -->

    <h3 class="text-center font-serif mb-1">Create Account</h3>
    <p class="text-center text-muted mb-4 small">Join the bookstore community</p>

    <form [formGroup]="registerForm" (ngSubmit)="submitRegister()">

      <div class="row g-3 mb-3">
      <!-- Bootstrap grid row:
           row: flex container for columns
           g-3: gap between columns (Bootstrap gutter)
           Two columns side by side for first/last name -->

        <div class="col-6">
        <!-- col-6: half-width Bootstrap column (out of 12 = 50%) -->
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" type="text"
                 formControlName="firstName"
                 placeholder="Ahmed" />
          @if (registerForm.get('firstName')?.touched && registerForm.get('firstName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>

        <div class="col-6">
          <label class="form-label small fw-semibold">Last Name</label>
          <input class="form-control" type="text"
                 formControlName="lastName"
                 placeholder="Hassan" />
          @if (registerForm.get('lastName')?.touched && registerForm.get('lastName')?.invalid) {
            <small class="text-danger">Min 2 characters</small>
          }
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Email</label>
        <input class="form-control" type="email"
               formControlName="email"
               placeholder="you&#64;example.com" />
        @if (registerForm.get('email')?.touched && registerForm.get('email')?.invalid) {
          <small class="text-danger">Valid email required</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Password</label>
        <input class="form-control" type="password"
               formControlName="password"
               placeholder="At least 6 characters" />
        @if (registerForm.get('password')?.touched && registerForm.get('password')?.invalid) {
          <small class="text-danger">Min 6 characters</small>
        }
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold">Date of Birth</label>
        <input class="form-control" type="date" formControlName="dob" />
        <!-- type="date": browser renders a native date picker
             Value submitted: string in 'YYYY-MM-DD' format ("2000-01-15")
             This matches what your backend's User model stores in the 'dob' field -->
        @if (registerForm.get('dob')?.touched && registerForm.get('dob')?.invalid) {
          <small class="text-danger">Date of birth is required</small>
        }
      </div>

      @if (serverError) {
        <div class="alert alert-danger py-2 small">{{ serverError }}</div>
      }
      @if (successMessage) {
        <div class="alert alert-success py-2 small">{{ successMessage }}</div>
        <!-- Green success alert — shows after successful registration
             User sees this for ~1.5 seconds before being redirected to login -->
      }

      <button class="btn btn-book-primary w-100 fw-bold py-2"
              type="submit"
              [disabled]="loading">
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

## 2.3 Profile Page — Every Line Explained

### profile.ts

```typescript
import { Component, OnInit } from '@angular/core';
// OnInit: interface that requires implementing ngOnInit()
// Implementing the interface is optional in Angular (it works without it)
// But it's best practice — TypeScript will warn you if you misspell ngOnInit

import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../core/services/auth.service';
// Note: two levels up from features/profile/ to reach core/services/
// (not three like in auth/ which was features/auth/login/)

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  // RouterLink NOT needed — profile page has no navigation links
  // No routerLink attributes in the template
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class Profile implements OnInit {
  // implements OnInit: declares that this class will implement the OnInit interface
  // TypeScript will error if you rename ngOnInit or mistype it

  loading = false;
  successMessage = '';
  errorMessage = '';

  userEmail = '';
  // Displayed read-only above the form
  // Email is shown but cannot be edited here (change email is a separate flow)
  // Populated from decoded JWT — no API call needed

  profileForm = new FormGroup({
    firstName: new FormControl('', [Validators.required, Validators.minLength(2)]),
    lastName:  new FormControl('', [Validators.required, Validators.minLength(2)]),
    dob:       new FormControl('', [Validators.required]),
    // Note: email is NOT in this form — it's not editable here
    // The form only contains fields that can be updated via PATCH /api/auth/profile
  });

  constructor(private auth: AuthService) {}
  // Only one dependency: AuthService
  // No Router needed — profile page doesn't navigate away after save

  ngOnInit() {
    // Called ONCE after Angular creates the component
    // BEFORE the template is rendered to the user
    // This is the right place to pre-fill forms

    const user = this.auth.getCurrentUser();
    // getCurrentUser(): decodes the JWT from localStorage
    // Returns: { _id, email, firstName, lastName, dob, role, exp, ... }
    // Or: null (if no token or token is malformed)
    // NO HTTP request — the data is already in the token

    if (user) {
      // Guard: only try to use user data if it's not null
      // If somehow the user is null here (edge case), we just show empty form

      this.userEmail = user.email;
      // Store email separately — displayed as text, not in the form

      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName:  user.lastName,
        dob:       user.dob,
      });
      // patchValue: fill the specified form controls with values
      // The form fields are now pre-filled with the user's current data
      // After patchValue:
      //   profileForm.get('firstName').value === user.firstName → true
      //   profileForm.dirty → false (values set programmatically don't mark dirty)
      //   profileForm.touched → false (user hasn't interacted yet)
    }
  }

  submitProfile() {
    if (this.profileForm.invalid) return;

    this.loading = true;
    this.successMessage = '';
    this.errorMessage = '';

    const { firstName, lastName, dob } = this.profileForm.value;

    this.auth.updateProfile({
      firstName: firstName!,
      lastName:  lastName!,
      dob:       dob!,
    }).subscribe({
      // PATCH /api/auth/profile — partial update
      next: () => {
        this.successMessage = 'Profile updated successfully!';
        this.loading = false;
        // Note: we don't update the JWT token here
        // The token still has the OLD firstName/lastName
        // A proper implementation would:
        //   1. Have the backend return a new token (with updated data) in the response
        //   2. Save the new token: localStorage.setItem(TOKEN_KEY, res.data.token)
        // For now, the data is updated in the backend — on next login the new token will reflect it
      },
      error: (err) => {
        this.errorMessage = err.error?.message || 'Update failed. Please try again.';
        this.loading = false;
      },
    });
  }
}
```

### profile.html

```html
<div class="container py-5" style="max-width: 600px">
<!-- container: Bootstrap centered container
     py-5: vertical padding top and bottom
     max-width: constrain width for readability -->

  <div class="card border-book shadow-sm p-4 fade-in">

    <div class="d-flex align-items-center gap-3 mb-4">
    <!-- Profile header row: avatar icon + name/email info
         d-flex: flexbox
         align-items-center: vertically center icon and text
         gap-3: Bootstrap gap between flex children -->

      <div class="rounded-circle bg-book-primary d-flex align-items-center justify-content-center"
           style="width: 56px; height: 56px; flex-shrink: 0">
      <!-- Avatar circle:
           rounded-circle: Bootstrap — makes it a circle
           bg-book-primary: dark brown background (from styles.css custom class)
           flex-shrink: 0 — prevent shrinking when text is long -->
        <i class="fa-solid fa-user text-white fs-5"></i>
        <!-- Font Awesome user icon — white color, size 5 (Bootstrap) -->
      </div>

      <div>
        <h4 class="font-serif mb-0">My Profile</h4>
        <small class="text-muted">{{ userEmail }}</small>
        <!-- Display email as read-only text
             {{ userEmail }}: text interpolation — Angular renders the string here -->
      </div>
    </div>

    <form [formGroup]="profileForm" (ngSubmit)="submitProfile()">

      <div class="row g-3 mb-3">
        <div class="col-6">
          <label class="form-label small fw-semibold">First Name</label>
          <input class="form-control" type="text" formControlName="firstName" />
          <!-- No placeholder needed — the field is pre-filled via patchValue in ngOnInit -->
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
        <!-- type="date" pre-filled with user's DOB from patchValue
             Browser shows native date picker with current date pre-selected -->
      </div>

      @if (successMessage) {
        <div class="alert alert-success py-2 small">{{ successMessage }}</div>
      }
      @if (errorMessage) {
        <div class="alert alert-danger py-2 small">{{ errorMessage }}</div>
      }

      <button class="btn btn-book-primary w-100 fw-bold py-2"
              type="submit"
              [disabled]="loading">
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

## 2.4 Not-Found Page

### not-found.ts

```typescript
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
// RouterLink: needed for routerLink="/books" in the template

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink],
  // Only RouterLink needed — no forms, no services, no HTTP
  templateUrl: './not-found.html',
  styleUrl: './not-found.css',
})
export class NotFound {}
// Empty class — this is a "dumb" or "presentational" component
// It has no logic — just displays a 404 message
// All behavior is in the HTML (static content + one link)
```

### not-found.html

```html
<div class="d-flex flex-column justify-content-center align-items-center text-center fade-in"
     style="min-height: calc(100vh - 60px)">
<!-- Full-height centered layout:
     d-flex flex-column: vertical flex container
     justify-content-center: center vertically in the space
     align-items-center: center horizontally
     text-center: center text alignment
     min-height: at least full viewport minus navbar -->

  <h1 class="font-serif" style="font-size: 96px; color: var(--book-accent); line-height: 1">404</h1>
  <!-- Giant 404 in gold (--book-accent color)
       font-serif: Playfair Display for the elegant look
       line-height: 1 prevents extra spacing below the number -->

  <h4 class="font-serif mb-2">Page Not Found</h4>

  <p class="text-muted mb-4">The page you're looking for doesn't exist or was moved.</p>

  <a routerLink="/books" class="btn btn-book-primary px-4 py-2 fw-bold">
  <!-- routerLink="/books": navigates to the books page
       This is an <a> tag styled as a button — correct for navigation
       Use <button> for actions (submit, click events)
       Use <a> for navigation — semantically correct, better accessibility -->
    <i class="fa-solid fa-book me-2"></i>Browse Books
  </a>
</div>
```

---

---

# CHAPTER 3 — Navbar: Connecting Everything

## 3.1 navbar.ts — Every Line Explained

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
// Component:  the decorator
// OnInit:     interface requiring ngOnInit() — for setting up the subscription
// OnDestroy:  interface requiring ngOnDestroy() — for cleanup/unsubscribe

import { RouterLink, RouterLinkActive } from '@angular/router';
// RouterLink:       enables routerLink="/books" on anchor tags
// RouterLinkActive: enables routerLinkActive="active-link" — adds a class when route is active

import { Subscription } from 'rxjs';
// Subscription: the type returned by .subscribe()
// We store it to call .unsubscribe() in ngOnDestroy

import { AuthService } from '../../core/services/auth.service';
// Path: two levels up from shared/navbar/ to reach core/services/

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  // No ReactiveFormsModule: navbar has no forms
  // No CommonModule: not needed in Angular 17+ for basic usage
  templateUrl: './navbar.html',
})
export class Navbar implements OnInit, OnDestroy {
  // implements OnInit, OnDestroy: TypeScript enforces that ngOnInit and ngOnDestroy exist
  // Without this, you could accidentally misspell and Angular would silently not call it

  isLoggedIn = false;
  // Initial state: not logged in
  // This will be immediately updated in ngOnInit via the subscription
  // But having it false initially is correct — shows guest nav on first render

  isAdmin = false;
  // Same reasoning — initially false, updated when subscription fires

  cartItemCount = 0;
  // Cart badge count — shows on the cart icon in the navbar
  // Currently hardcoded 0 — will be connected to CartService later

  private authSub!: Subscription;
  // private: only used within this class (nobody else needs to manage this subscription)
  // !: definite assignment assertion
  //    TypeScript sees that authSub has no initializer in the class body
  //    and would error: "Property 'authSub' has no initializer"
  //    The ! says: "I promise ngOnInit will assign this before it's used"
  //    Alternative: private authSub?: Subscription (optional) → then use authSub?.unsubscribe()
  //    Both work — the ? version is arguably safer

  constructor(private auth: AuthService) {}
  // Inject AuthService — stored as this.auth
  // No other dependencies needed

  ngOnInit() {
    // Called by Angular after the component is created and inputs are set
    // Perfect place for subscriptions

    this.authSub = this.auth.authStatus$.subscribe(loggedIn => {
    // auth.authStatus$: the public Observable from AuthService (read-only BehaviorSubject)
    // .subscribe(callback): start listening to the Observable
    //   Returns a Subscription object — stored in this.authSub for cleanup

    // The callback (loggedIn => { ... }):
    //   Runs IMMEDIATELY with the current value (because BehaviorSubject)
    //     If user is already logged in when Navbar initializes: loggedIn=true immediately
    //     If user just opened the app fresh: loggedIn=false immediately
    //   Runs AGAIN every time auth state changes:
    //     User logs in → AuthService calls loggedIn$.next(true) → this callback runs with true
    //     User logs out → AuthService calls loggedIn$.next(false) → this callback runs with false

      this.isLoggedIn = loggedIn;
      // Update the local variable
      // Angular's change detection sees this changed and re-renders the template
      // @if (isLoggedIn) in the template updates immediately

      this.isAdmin = this.auth.isAdmin();
      // Decode the token and check role === 'admin'
      // Called here (not in template) to avoid calling it on every change detection cycle
      // When loggedIn=false: getCurrentUser() returns null, isAdmin() returns false
      // When loggedIn=true: getCurrentUser() decodes token, isAdmin() checks role
    });
  }

  ngOnDestroy() {
    // Called by Angular JUST BEFORE removing this component from the DOM

    this.authSub?.unsubscribe();
    // ?: optional chaining — safe if authSub was never assigned (shouldn't happen but safe)
    // .unsubscribe(): stop listening to authStatus$
    //   From this point, the callback in ngOnInit will no longer run
    //   The BehaviorSubject no longer holds a reference to this component's callback
    //   The Navbar component object can be garbage collected

    // For the Navbar specifically:
    //   Navbar lives in app.html — always visible — never destroyed until browser tab closes
    //   So this ngOnDestroy effectively never runs in production
    //   BUT: it's critical habit — in other components (modals, dynamic lists, etc.) it matters a lot
  }

  onLogout() {
    // Called from the Logout button in navbar.html: (click)="onLogout()"
    this.auth.logout();
    // AuthService.logout() does:
    //   1. localStorage.removeItem('jwt_token')
    //   2. loggedIn$.next(false) → this Navbar's subscription fires → isLoggedIn = false → template re-renders
    //   3. router.navigate(['/auth/login']) → user sees login page
    // All in one method call — clean
  }
}
```

---

# CHAPTER 4 — The Full Auth Flow Visualized

This shows every piece working together, end-to-end:

```
═══════════════════════════════════════════════════════════════
REGISTRATION FLOW
═══════════════════════════════════════════════════════════════

User fills register form → clicks "Create Account"
    ↓
(ngSubmit) fires → Register.submitRegister() called
    ↓
registerForm.invalid? → YES: return (show validation errors in HTML)
                      → NO: continue
    ↓
loading = true (button disabled, spinner shows)
    ↓
auth.register({...}).subscribe()
    ↓ (HTTP POST /api/auth/register)
Backend creates user, returns { success: true, message: "Created" }
    ↓
next() fires:
  successMessage = "Account created! Redirecting..."
  setTimeout 1500ms → router.navigate(['/auth/login'])
    ↓
Register component is destroyed → Login component loads

═══════════════════════════════════════════════════════════════
LOGIN FLOW
═══════════════════════════════════════════════════════════════

User fills login form → clicks "Sign In"
    ↓
(ngSubmit) fires → Login.submitLogin() called
    ↓
loginForm.invalid? → return if invalid
    ↓
loading = true
    ↓
auth.login(email, password).subscribe()
    ↓
HttpClient creates POST /api/auth/login request
    ↓
[tokenInterceptor] → no token yet → passes request unchanged
    ↓
[errorInterceptor] → wraps response in catchError
    ↓
Request hits backend → backend validates → returns { data: { token: "eyJ...", user: {...} } }
    ↓
Response comes back through errorInterceptor → no error → passes through
    ↓
tap() in AuthService fires:
  localStorage.setItem('jwt_token', token)
  loggedIn$.next(true)
    ↓
BehaviorSubject notifies Navbar:
  isLoggedIn = true
  isAdmin = auth.isAdmin() (decodes token)
  Angular re-renders Navbar: Cart/Profile/Orders links appear, Sign In/Register disappear
    ↓
next() fires in Login component:
  router.navigate(['/books'])
    ↓
BookList component loads

═══════════════════════════════════════════════════════════════
SUBSEQUENT API REQUEST FLOW (e.g., user views cart)
═══════════════════════════════════════════════════════════════

User navigates to /cart
    ↓
Angular Router checks canActivate: [authGuard]
    ↓
authGuard() called:
  auth.isLoggedIn() → decodes token, checks exp → true
  returns true → navigation proceeds
    ↓
Cart component loads, calls CartService.getCart()
    ↓
HttpClient creates GET /api/cart request
    ↓
[tokenInterceptor]:
  auth.getToken() → localStorage.getItem('jwt_token') → "eyJ..."
  req.clone({ setHeaders: { Authorization: "Bearer eyJ..." } })
  returns next(authReq)
    ↓
[errorInterceptor]: wraps in catchError
    ↓
Request hits backend WITH Authorization header
Backend validates token → serves cart data
    ↓
Response returns → Cart component receives data → renders cart items

═══════════════════════════════════════════════════════════════
LOGOUT FLOW
═══════════════════════════════════════════════════════════════

User clicks Logout in Navbar
    ↓
(click)="onLogout()" fires → Navbar.onLogout() called
    ↓
auth.logout():
  localStorage.removeItem('jwt_token')
  loggedIn$.next(false)
  router.navigate(['/auth/login'])
    ↓
BehaviorSubject notifies Navbar:
  isLoggedIn = false
  Navbar re-renders: Cart/Profile/Orders disappear, Sign In/Register appear
    ↓
Router navigates to /auth/login
Login component loads
```

---

---

# CHAPTER 5 — Testing Your Work: The Exact Steps

## 5.1 Pre-Flight Checklist

Before testing in the browser:

```bash
# 1. Make sure backend is running:
cd bookstore-backend && node server.js
# Should see: "Server running on port 5000"

# 2. Make sure frontend compiles without errors:
cd bookstore-frontend && ng serve
# Should see: "✔ Compiled successfully"
# ANY TypeScript or template error shows here — fix all errors before testing in browser

# 3. Check for common missing files:
ls src/app/core/models/       # should have user, cart, order, review, api-response, index
ls src/app/core/services/     # should have auth.service.ts
ls src/app/core/interceptors/ # should have token.interceptor.ts, error.interceptor.ts
ls src/app/core/guards/       # should have auth.guard.ts, admin.guard.ts
```

---

## 5.2 Test 1 — Registration

```
1. Open: http://localhost:4200/auth/register
2. WITHOUT filling anything, click "Create Account"
   Expected: form fields show validation errors (touched after submit attempt)
   Note: if errors don't show, add this.registerForm.markAllAsTouched()
         to the beginning of submitRegister()

3. Fill invalid email (e.g. "notanemail")
   Expected: email field shows error immediately after you click away

4. Fill valid data:
   First Name: Ahmed (or any 2+ char name)
   Last Name: Hassan
   Email: test@test.com
   Password: 123456
   DOB: any past date

5. Click "Create Account"
   Expected: spinner appears, then "Account created! Redirecting..."
   Expected: after 1.5 seconds → redirect to /auth/login
   
6. Go to /auth/register again and try the same email
   Expected: server error "Email already registered" (or similar backend message)
```

---

## 5.3 Test 2 — Login + Navbar Update

```
1. Open: http://localhost:4200/auth/login
2. Fill with the credentials you just registered
3. Click "Sign In"
   Expected: button shows spinner while loading
   Expected: after success → redirect to /books
   Expected: Navbar NOW shows Cart, My Orders, Profile, Logout
             (was showing Sign In / Register before)

4. Open DevTools → Application tab → Local Storage → localhost:4200
   Expected: key 'jwt_token' with a long string value starting with 'eyJ'
```

---

## 5.4 Test 3 — Token Is Being Sent

```
1. While logged in, go to any page that makes an API call
2. Open DevTools → Network tab
3. Click on one of the API requests (filter by /api/ if needed)
4. Click "Headers" tab
5. Look in "Request Headers"
   Expected: Authorization: Bearer eyJ.....
```

---

## 5.5 Test 4 — Auth Guard Works

```
1. Open DevTools → Application → Local Storage → delete 'jwt_token'
2. Try to navigate to /profile by typing it in the URL bar
   Expected: immediately redirected to /auth/login
3. Try /cart → same result
4. Try /orders → same result
5. Try /books → loads normally (not protected)
```

---

## 5.6 Test 5 — Admin Guard Works

```
1. Log in with a non-admin account
2. Try to navigate to /admin
   Expected: redirected to / (home/books page)
3. (To test admin access, you'd need to manually set role:'admin' in your MongoDB
   for a test user, then log in as that user)
```

---

## 5.7 Test 6 — Profile Page Pre-fills

```
1. Log in
2. Navigate to /profile
   Expected: First Name and Last Name are pre-filled with your name
   Expected: Date of Birth is pre-filled
   Expected: Your email shows above the form (read-only)

3. Change First Name to something different
4. Click "Save Changes"
   Expected: spinner shows → "Profile updated successfully!" message appears
```

---

## 5.8 Test 7 — Logout

```
1. Click Logout in the Navbar
   Expected: redirect to /auth/login
   Expected: Navbar shows Sign In / Register again (Cart/Profile/Orders hidden)
   Expected: jwt_token removed from localStorage (check DevTools)

2. Press browser back button
   Expected: you're back on /books or wherever you were
   Expected: Navbar still shows guest state (Sign In / Register)
   Note: browser back doesn't re-login you — token is gone
```

---

## 5.9 Test 8 — Not-Found Page

```
1. Navigate to any nonsense URL: /anyrandompath or /books/doesntexist
   Expected: "404" in gold text, "Page Not Found", "Browse Books" button
2. Click "Browse Books"
   Expected: navigates to /books
```

---

# CHAPTER 6 — Common Errors Reference

## Compilation Errors (you see these in the terminal / ng serve output)

---

**Error: `Can't bind to 'formGroup' since it isn't a known property of 'form'`**

```
What it means:
  Angular sees [formGroup]="loginForm" in your template but doesn't know what formGroup is.
  
Why it happens:
  ReactiveFormsModule is missing from the component's imports array.
  
Fix:
  In your component's @Component decorator:
  imports: [CommonModule, ReactiveFormsModule, RouterLink]
  Make sure ReactiveFormsModule is in the list.
```

---

**Error: `'X' is not a known element`** (e.g., `'app-navbar' is not a known element`)

```
What it means:
  You're using a component in a template but that component is not imported.
  
Why it happens:
  The host component's imports array doesn't include the component being used.
  
Fix:
  In app.ts (or wherever the component is used):
  imports: [RouterOutlet, Navbar]  // add Navbar here
  Make sure to also import the class at the top:
  import { Navbar } from './shared/navbar/navbar';
```

---

**Error: `NullInjectorError: No provider for HttpClient`**

```
What it means:
  A service tried to inject HttpClient but Angular can't find a provider for it.
  
Why it happens:
  provideHttpClient() is missing from app.config.ts providers array.
  
Fix:
  In app.config.ts:
  providers: [
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([...]))  // ADD THIS
  ]
```

---

**Error: `Property 'X' does not exist on type 'Y'`**

```
What it means:
  TypeScript can't find the property you're accessing.
  
Why it happens:
  Usually: you have 'any' type somewhere, or the interface is missing the field,
  or you have a typo in the property name.
  
Fix:
  Check the interface definition — does it have the field?
  Check for typos: 'firstName' vs 'firstname' vs 'first_name'
  If the field is optional, access it with ?. operator
```

---

**Error: `Object is possibly 'null'`**

```
What it means:
  TypeScript sees that a value might be null but you're using it without null check.
  
Why it happens:
  formGroup.get('email') returns FormControl | null
  auth.getCurrentUser() returns any | null
  localStorage.getItem() returns string | null
  
Fix:
  Option 1: Optional chaining: form.get('email')?.value
  Option 2: Non-null assertion: form.get('email')!.value (use when you're SURE it's not null)
  Option 3: Null check: const control = form.get('email'); if (control) { control.value }
```

---

## Runtime Errors (visible in browser console)

---

**Error: `ERROR TypeError: Cannot read properties of null (reading 'role')`**

```
What it means:
  You tried to access .role on something that is null.
  
Where it likely occurs:
  auth.isAdmin() → getCurrentUser()?.role
  If optional chaining is missing, this crashes.
  
Fix:
  Always use optional chaining when accessing properties on things that might be null:
  getCurrentUser()?.role === 'admin'  // safe
  getCurrentUser().role === 'admin'   // crashes if getCurrentUser() returns null
```

---

**Error: `ERROR Error: NG04002: Cannot match any routes`**

```
What it means:
  A routerLink or router.navigate() is pointing to a path that doesn't exist in app.routes.ts.
  
Fix:
  Check the path in routerLink — must exactly match a path in your routes array.
  Common issue: missing leading slash in app.routes.ts, or typo in path name.
```

---

## Logical Errors (no error thrown, but behavior is wrong)

---

**Problem: Navbar doesn't update after login**

```
Symptom:
  User logs in successfully, redirects to /books, but Navbar still shows "Sign In".

Diagnosis:
  Check 1: Is authSub = this.auth.authStatus$.subscribe(...) in ngOnInit?
  Check 2: Does AuthService.login() actually call loggedIn$.next(true)?
  Check 3: Is the Navbar using AuthService from the SAME import path as Login?
           Both must import from the same file — different paths = different singletons... actually
           Angular guarantees a singleton per providedIn: 'root' — but check the path anyway.

Fix:
  Make sure AuthService.login() calls this.loggedIn$.next(true) in the tap() operator.
  Make sure Navbar's ngOnInit subscribes to this.auth.authStatus$.
```

---

**Problem: Token not being sent with requests**

```
Symptom:
  User is logged in, API calls work, but DevTools shows no Authorization header.
  Backend returns 401 errors.

Diagnosis:
  Check 1: Is withInterceptors([tokenInterceptor, errorInterceptor]) inside provideHttpClient()?
  Check 2: Is the token actually in localStorage? (DevTools → Application → Local Storage)
  Check 3: Does tokenInterceptor properly call inject(AuthService).getToken()?

Fix:
  In app.config.ts, make sure interceptors are registered:
  provideHttpClient(withFetch(), withInterceptors([tokenInterceptor, errorInterceptor]))
```

---

**Problem: Guard redirects even when logged in**

```
Symptom:
  User is logged in but navigating to /profile redirects to login.

Diagnosis:
  Check: auth.isLoggedIn() in AuthService — is it checking token expiry correctly?
  Check: Is the token actually stored under the correct key ('jwt_token')?
  Check: Is the TOKEN_KEY constant the same in getToken() and login()?

Debug:
  Add console.log to authGuard:
  export const authGuard: CanActivateFn = () => {
    const auth = inject(AuthService);
    console.log('Guard check - token:', auth.getToken());
    console.log('Guard check - isLoggedIn:', auth.isLoggedIn());
    ...
  }
```

---

**Problem: Profile page shows empty form (not pre-filled)**

```
Symptom:
  User is logged in, navigates to /profile, but all fields are empty.

Diagnosis:
  Check 1: Does ngOnInit exist and implement OnInit?
  Check 2: Is patchValue called? Add console.log(user) before patchValue to see what's there.
  Check 3: Does getCurrentUser() return null? The token might be expired or malformed.

Fix:
  In profile.ts ngOnInit, add debugging:
  const user = this.auth.getCurrentUser();
  console.log('getCurrentUser result:', user);
  if (user) { this.profileForm.patchValue({...}) }
```

---

**Problem: Error messages don't show**

```
Symptom:
  User submits invalid form, no red error messages appear under inputs.

Diagnosis:
  Check: Are you checking both touched AND invalid in the template?
  @if (form.get('email')?.touched && form.get('email')?.invalid)
  If you only check invalid: errors show before user interacts (bad UX initially)
  If touched is never becoming true: user needs to click the field and click away

Fix (show errors on submit attempt even without touching):
  At the start of your submit method, add:
  this.loginForm.markAllAsTouched();
  This marks every control as touched, triggering all error displays
```

---

## 6.1 The `markAllAsTouched()` Pattern

The most common UX improvement to add to all your forms:

```typescript
submitLogin() {
  this.loginForm.markAllAsTouched();
  // ← Add this as the FIRST line in every submit method
  // This marks every control as touched immediately
  // So if the user clicks Submit without filling anything:
  // → All error messages appear at once
  // → Much better than silently doing nothing

  if (this.loginForm.invalid) return;
  // Now the form.invalid check makes more sense:
  // errors are visible, user knows why submission failed

  // ... rest of submit logic
}
```

---

# Final Quick Reference Card — Everything in One Place

## The Files You Created and What Each Does

```
src/app/core/models/
  user.model.ts          → interface User (shape of user from API/JWT)
  cart.model.ts          → interface CartItem, Cart
  order.model.ts         → interface OrderItem, ShippingDetails, Order
  review.model.ts        → interface Review
  api-response.model.ts  → generic interface ApiResponse<T>
  index.ts               → re-exports all models for clean imports

src/app/core/services/
  auth.service.ts        → login, register, logout, getToken, getCurrentUser, isAdmin

src/app/core/interceptors/
  token.interceptor.ts   → adds Authorization header to every request
  error.interceptor.ts   → handles 401 (logout) and 403 (redirect home) globally

src/app/core/guards/
  auth.guard.ts          → blocks routes if not logged in → redirects to /auth/login
  admin.guard.ts         → blocks routes if not admin → redirects to /

src/app/app.config.ts    → registers HttpClient + interceptors globally
src/app/app.routes.ts    → all routes with canActivate guards applied

src/app/features/auth/login/
  login.ts               → form definition, submitLogin(), loading state
  login.html             → [formGroup], formControlName, (ngSubmit), @if for errors

src/app/features/auth/register/
  register.ts            → 5-field form, submitRegister(), success/error messages
  register.html          → same pattern as login, two-column name row

src/app/features/profile/
  profile.ts             → implements OnInit, patchValue pre-fill, updateProfile()
  profile.html           → shows email read-only, editable form

src/app/not-found/
  not-found.ts           → empty class with RouterLink import
  not-found.html         → 404 display with back-to-books button

src/app/shared/navbar/
  navbar.ts              → subscribes to authStatus$, OnDestroy cleanup, onLogout()
```

## The Dependency Chain

```
app.config.ts
  └── provideHttpClient → makes HttpClient available everywhere
  └── withInterceptors([tokenInterceptor, errorInterceptor])
        ├── tokenInterceptor → needs AuthService.getToken()
        └── errorInterceptor → needs AuthService.logout(), Router

app.routes.ts
  ├── canActivate: [authGuard]  → needs AuthService.isLoggedIn()
  └── canActivate: [adminGuard] → needs AuthService.isLoggedIn() + isAdmin()

AuthService
  ├── needs HttpClient (for login/register/updateProfile)
  ├── needs Router (for logout redirect)
  └── exposes: authStatus$ (BehaviorSubject as Observable)

Navbar
  └── subscribes to AuthService.authStatus$

Login, Register, Profile
  └── call AuthService.login() / register() / updateProfile()
  └── return Observable → component subscribes → handles next/error
```

---

*End of Part 3. All three files are complete.*
*Total guide: ~22,000 words across 3 files.*
*Part 1: TypeScript + Angular Foundations*
*Part 2: RxJS + Services + HTTP + Interceptors + Guards*
*Part 3: Reactive Forms + Pages + Navbar + Testing + Errors*
