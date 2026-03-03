# 📃 Angular Complete Guide — Part 8 of 9
## Testing: Jasmine + TestBed + Component Tests

---

# CHAPTER 1 — Testing Foundations

## 1.1 Jasmine Vocabulary

```typescript
describe('AuthService', () => {           // test suite — groups related tests
  let service: AuthService;

  beforeEach(() => {                       // runs before EVERY it block
    localStorage.clear();
    service = TestBed.inject(AuthService);
  });

  afterEach(() => { localStorage.clear(); }); // cleanup after every test

  it('should return false when no token', () => { // one test case
    expect(service.isLoggedIn()).toBeFalse();      // assertion
  });

  it('should return true for valid token', () => {
    localStorage.setItem('jwt_token', validToken);
    expect(service.isLoggedIn()).toBeTrue();
  });
});
```

---

## 1.2 Common Matchers

```typescript
// Equality
expect(value).toBe(5);                   // strict === equality
expect(value).toEqual({ a: 1 });         // deep equality (all properties)
expect(value).not.toBe(null);            // negation

// Truthiness
expect(value).toBeTrue();
expect(value).toBeFalse();
expect(value).toBeTruthy();              // any truthy value
expect(value).toBeFalsy();              // any falsy value
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(n).toBeGreaterThan(5);
expect(n).toBeLessThanOrEqual(10);

// Strings and arrays
expect(str).toContain('hello');
expect(str).toMatch(/pattern/);
expect(arr).toContain(item);
expect(arr).toHaveSize(3);

// Spies
expect(spy).toHaveBeenCalled();
expect(spy).toHaveBeenCalledTimes(2);
expect(spy).toHaveBeenCalledWith('arg1', jasmine.any(String));
expect(spy).not.toHaveBeenCalled();

// Errors
expect(() => riskyMethod()).toThrow();
expect(() => riskyMethod()).toThrowError('message');

// Force test failure (used inside callbacks where you expect an error):
fail('This line should not have been reached');
```

---

## 1.3 Spies — Mocking Dependencies

```typescript
// Spy on existing method — replace with controlled version:
const getTokenSpy = spyOn(service, 'getToken').and.returnValue('fake-token');
expect(getTokenSpy).toHaveBeenCalled();

// Create a full spy object for a dependency:
const authSpy = jasmine.createSpyObj<AuthService>('AuthService', [
  'login', 'logout', 'isLoggedIn', 'isAdmin', 'getCurrentUser', 'getToken'
]);

// Configure return values:
authSpy.isLoggedIn.and.returnValue(true);
authSpy.getCurrentUser.and.returnValue({ firstName: 'Khaled', email: 'k@test.com', role: 'user' });
authSpy.login.and.returnValue(of({ success: true, data: { token: 'abc' } }));
authSpy.login.and.returnValue(throwError(() => ({ status: 401, error: { message: 'Invalid' } })));

// Verify interactions:
expect(authSpy.login).toHaveBeenCalledWith('k@test.com', 'password');
expect(authSpy.logout).not.toHaveBeenCalled();
```

---

---

# CHAPTER 2 — Testing Services

## 2.1 AuthService — Complete Test Suite

```typescript
// auth.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { AuthService } from './auth.service';

// Helper: create a fake JWT with a given payload
function makeToken(payload: object): string {
  return `header.${btoa(JSON.stringify(payload))}.signature`;
}

const FUTURE = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
const PAST   = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago

describe('AuthService', () => {
  let service: AuthService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [
        HttpClientTestingModule,  // no real HTTP — you control responses
        RouterTestingModule,      // no real navigation
      ],
      providers: [AuthService]
    });

    service = TestBed.inject(AuthService);
    http    = TestBed.inject(HttpTestingController);
    localStorage.clear();
  });

  afterEach(() => {
    http.verify();        // fail if any unexpected HTTP request was made
    localStorage.clear();
  });

  // ─── isLoggedIn ─────────────────────────────────────────────────────────────

  describe('isLoggedIn()', () => {
    it('returns false when localStorage is empty', () => {
      expect(service.isLoggedIn()).toBeFalse();
    });

    it('returns false for expired token', () => {
      localStorage.setItem('jwt_token', makeToken({ exp: PAST }));
      expect(service.isLoggedIn()).toBeFalse();
    });

    it('returns true for valid unexpired token', () => {
      localStorage.setItem('jwt_token', makeToken({ exp: FUTURE }));
      expect(service.isLoggedIn()).toBeTrue();
    });

    it('returns false for malformed token', () => {
      localStorage.setItem('jwt_token', 'not.a.jwt');
      expect(service.isLoggedIn()).toBeFalse();
    });
  });

  // ─── isAdmin ────────────────────────────────────────────────────────────────

  describe('isAdmin()', () => {
    it('returns true for admin role token', () => {
      localStorage.setItem('jwt_token', makeToken({ role: 'admin', exp: FUTURE }));
      expect(service.isAdmin()).toBeTrue();
    });

    it('returns false for user role token', () => {
      localStorage.setItem('jwt_token', makeToken({ role: 'user', exp: FUTURE }));
      expect(service.isAdmin()).toBeFalse();
    });

    it('returns false when not logged in', () => {
      expect(service.isAdmin()).toBeFalse();
    });
  });

  // ─── login ──────────────────────────────────────────────────────────────────

  describe('login()', () => {
    it('saves token to localStorage on success', () => {
      const token = makeToken({ _id: '1', email: 'k@test.com', role: 'user', exp: FUTURE });

      service.login('k@test.com', 'password').subscribe();

      const req = http.expectOne('http://localhost:5000/api/auth/login');
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual({ email: 'k@test.com', password: 'password' });
      req.flush({ success: true, data: { token } });

      expect(localStorage.getItem('jwt_token')).toBe(token);
    });

    it('emits true on authStatus$ after login', () => {
      const token = makeToken({ exp: FUTURE });
      let status: boolean | undefined;
      service.authStatus$.subscribe(s => status = s);

      service.login('k@test.com', 'password').subscribe();
      http.expectOne('http://localhost:5000/api/auth/login')
          .flush({ success: true, data: { token } });

      expect(status).toBeTrue();
    });

    it('does NOT save token on HTTP error', () => {
      service.login('k@test.com', 'wrong').subscribe({ error: () => {} });
      http.expectOne('http://localhost:5000/api/auth/login')
          .flush({ message: 'Invalid' }, { status: 401, statusText: 'Unauthorized' });

      expect(localStorage.getItem('jwt_token')).toBeNull();
    });
  });

  // ─── logout ─────────────────────────────────────────────────────────────────

  describe('logout()', () => {
    it('removes token from localStorage', () => {
      localStorage.setItem('jwt_token', makeToken({ exp: FUTURE }));
      service.logout();
      expect(localStorage.getItem('jwt_token')).toBeNull();
    });

    it('emits false on authStatus$', () => {
      localStorage.setItem('jwt_token', makeToken({ exp: FUTURE }));
      let status: boolean | undefined;
      service.authStatus$.subscribe(s => status = s);

      service.logout();
      expect(status).toBeFalse();
    });
  });
});
```

---

---

# CHAPTER 3 — Testing Components

## 3.1 TestBed Setup Pattern

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';

describe('MyComponent', () => {
  let component: MyComponent;
  let fixture: ComponentFixture<MyComponent>;
  let serviceSpy: jasmine.SpyObj<MyService>;

  beforeEach(async () => {
    serviceSpy = jasmine.createSpyObj('MyService', ['getData']);
    serviceSpy.getData.and.returnValue(of([]));

    await TestBed.configureTestingModule({
      imports: [MyComponent],    // standalone component imports itself
      providers: [
        { provide: MyService, useValue: serviceSpy }
      ]
    }).compileComponents();     // async — compiles templates

    fixture   = TestBed.createComponent(MyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();   // renders the template
  });
});
```

---

## 3.2 Login Component — Complete Test Suite

```typescript
// login.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { of, throwError } from 'rxjs';
import { By } from '@angular/platform-browser';
import { Login } from './login';
import { AuthService } from '../../../core/services/auth.service';

describe('Login Component', () => {
  let component: Login;
  let fixture: ComponentFixture<Login>;
  let authSpy: jasmine.SpyObj<AuthService>;
  let routerSpy: jasmine.SpyObj<Router>;

  beforeEach(async () => {
    authSpy   = jasmine.createSpyObj('AuthService', ['login']);
    routerSpy = jasmine.createSpyObj('Router', ['navigate']);

    await TestBed.configureTestingModule({
      imports: [Login],
      providers: [
        { provide: AuthService, useValue: authSpy },
        { provide: Router,      useValue: routerSpy }
      ]
    }).compileComponents();

    fixture   = TestBed.createComponent(Login);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  // ─── Form state tests ────────────────────────────────────────────────────────

  it('should render "Welcome Back" heading', () => {
    const heading = fixture.nativeElement.querySelector('h3');
    expect(heading.textContent.trim()).toBe('Welcome Back');
  });

  it('should start with empty invalid form', () => {
    expect(component.loginForm.value).toEqual({ email: '', password: '' });
    expect(component.loginForm.invalid).toBeTrue();
  });

  it('should be invalid with bad email format', () => {
    component.loginForm.patchValue({ email: 'notvalid', password: 'abc123' });
    expect(component.loginForm.get('email')?.errors?.['email']).toBeTrue();
    expect(component.loginForm.invalid).toBeTrue();
  });

  it('should be valid with correct email and password', () => {
    component.loginForm.patchValue({ email: 'k@test.com', password: 'secret' });
    expect(component.loginForm.valid).toBeTrue();
  });

  // ─── Submit behavior ─────────────────────────────────────────────────────────

  it('should NOT call auth.login when form is invalid', () => {
    component.submitLogin();
    expect(authSpy.login).not.toHaveBeenCalled();
  });

  it('should set loading = true while request is in flight', () => {
    // Never resolves — simulates slow network
    authSpy.login.and.returnValue(new Observable(() => {}));
    component.loginForm.patchValue({ email: 'k@test.com', password: 'abc' });
    component.submitLogin();
    expect(component.loading).toBeTrue();
  });

  it('should navigate to /books on successful login', () => {
    authSpy.login.and.returnValue(of({ success: true, data: { token: 'abc' } }));
    component.loginForm.patchValue({ email: 'k@test.com', password: 'secret' });
    component.submitLogin();
    expect(routerSpy.navigate).toHaveBeenCalledWith(['/books']);
  });

  it('should display server error on failed login', () => {
    authSpy.login.and.returnValue(
      throwError(() => ({ error: { message: 'Invalid credentials' } }))
    );
    component.loginForm.patchValue({ email: 'k@test.com', password: 'wrong' });
    component.submitLogin();

    fixture.detectChanges(); // update template with new serverError value

    const alertEl = fixture.nativeElement.querySelector('.alert-danger');
    expect(alertEl).not.toBeNull();
    expect(alertEl.textContent.trim()).toBe('Invalid credentials');
  });

  it('should reset loading to false after error', () => {
    authSpy.login.and.returnValue(
      throwError(() => ({ error: { message: 'Error' } }))
    );
    component.loginForm.patchValue({ email: 'k@test.com', password: 'x' });
    component.submitLogin();
    expect(component.loading).toBeFalse();
  });

  // ─── DOM interaction tests ──────────────────────────────────────────────────

  it('should show validation error after touching email field', () => {
    const emailInput = fixture.debugElement.query(By.css('input[formControlName="email"]'));
    emailInput.triggerEventHandler('blur', null); // marks as touched
    fixture.detectChanges();

    const error = fixture.nativeElement.querySelector('small.text-danger');
    expect(error).not.toBeNull();
  });

  it('should disable submit button while loading', () => {
    authSpy.login.and.returnValue(new Observable(() => {}));
    component.loginForm.patchValue({ email: 'k@test.com', password: 'abc' });
    component.submitLogin();
    fixture.detectChanges();

    const button = fixture.nativeElement.querySelector('button[type="submit"]');
    expect(button.disabled).toBeTrue();
  });
});
```

---

## 3.3 BookCard Component — Input/Output Tests

```typescript
// book-card.spec.ts
describe('BookCard Component', () => {
  let component: BookCard;
  let fixture: ComponentFixture<BookCard>;

  const mockBook: Book = {
    _id: 'abc123', title: 'Clean Code',
    author: 'Robert Martin', price: 29.99,
    coverImage: '/img/cover.jpg', inStock: true
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BookCard]
    }).compileComponents();

    fixture   = TestBed.createComponent(BookCard);
    component = fixture.componentInstance;
    component.book = mockBook;    // provide required @Input
    fixture.detectChanges();
  });

  it('should display the book title', () => {
    const title = fixture.nativeElement.querySelector('[data-testid="book-title"], h5, .book-title');
    expect(title?.textContent).toContain('Clean Code');
  });

  it('should display the book price', () => {
    const price = fixture.nativeElement.querySelector('[data-testid="book-price"], .price');
    expect(price?.textContent).toContain('29.99');
  });

  it('should emit the book when "Add to Cart" is clicked', () => {
    let emittedBook: Book | undefined;
    component.addedToCart.subscribe((b: Book) => emittedBook = b);

    const btn = fixture.nativeElement.querySelector('button.add-to-cart, [data-testid="add-cart"]');
    btn?.click();
    fixture.detectChanges();

    expect(emittedBook).toEqual(mockBook);
  });

  it('should re-render when @Input book changes', () => {
    const newBook: Book = { ...mockBook, title: 'Refactoring', price: 34.99 };
    component.book = newBook;
    fixture.detectChanges();

    const title = fixture.nativeElement.querySelector('h5, .book-title');
    expect(title?.textContent).toContain('Refactoring');
  });
});
```

---

## 3.4 Testing Guards

```typescript
// auth.guard.spec.ts
import { TestBed } from '@angular/core/testing';
import { authGuard } from './auth.guard';
import { AuthService } from '../services/auth.service';
import { Router } from '@angular/router';

describe('authGuard', () => {
  let authSpy: jasmine.SpyObj<AuthService>;
  let routerSpy: jasmine.SpyObj<Router>;

  beforeEach(() => {
    authSpy   = jasmine.createSpyObj('AuthService', ['isLoggedIn']);
    routerSpy = jasmine.createSpyObj('Router', ['createUrlTree']);
    routerSpy.createUrlTree.and.callFake((path: string[]) => path as any);

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authSpy },
        { provide: Router,      useValue: routerSpy }
      ]
    });
  });

  it('returns true when user is logged in', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    const result = TestBed.runInInjectionContext(() =>
      authGuard({} as any, {} as any)
    );
    expect(result).toBeTrue();
  });

  it('redirects to /auth/login when not logged in', () => {
    authSpy.isLoggedIn.and.returnValue(false);
    TestBed.runInInjectionContext(() => authGuard({} as any, {} as any));
    expect(routerSpy.createUrlTree).toHaveBeenCalledWith(['/auth/login']);
  });
});
```

---

## 3.5 Testing the Token Interceptor

```typescript
// token.interceptor.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { tokenInterceptor } from './token.interceptor';
import { AuthService } from '../services/auth.service';

describe('tokenInterceptor', () => {
  let http: HttpClient;
  let httpMock: HttpTestingController;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(() => {
    authSpy = jasmine.createSpyObj('AuthService', ['getToken']);

    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [
        { provide: AuthService, useValue: authSpy },
        provideHttpClient(withInterceptors([tokenInterceptor]))
      ]
    });

    http     = TestBed.inject(HttpClient);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());

  it('should attach Authorization header when token exists', () => {
    authSpy.getToken.and.returnValue('my-token');

    http.get('/api/books').subscribe();

    const req = httpMock.expectOne('/api/books');
    expect(req.request.headers.get('Authorization')).toBe('Bearer my-token');
    req.flush([]);
  });

  it('should NOT attach header when no token', () => {
    authSpy.getToken.and.returnValue(null);

    http.get('/api/books').subscribe();

    const req = httpMock.expectOne('/api/books');
    expect(req.request.headers.has('Authorization')).toBeFalse();
    req.flush([]);
  });
});
```

---

## 3.6 Running Tests

```bash
# All tests, once, headless (for CI):
ng test --watch=false --browsers=ChromeHeadless

# Watch mode — reruns on file save:
ng test

# Single spec file:
ng test --include='**/auth.service.spec.ts'

# With coverage report:
ng test --code-coverage --watch=false
# Opens coverage/index.html — shows which lines are and aren't tested
```

---

# Quick Reference — Testing

```typescript
// TestBed:
await TestBed.configureTestingModule({
  imports: [StandaloneComponent],
  providers: [{ provide: SomeService, useValue: spy }]
}).compileComponents();
fixture = TestBed.createComponent(MyComponent);
component = fixture.componentInstance;
fixture.detectChanges();

// DOM:
fixture.nativeElement.querySelector('.class')
fixture.debugElement.query(By.css('.class'))
element.click(); fixture.detectChanges();
input.value = 'x'; input.dispatchEvent(new Event('input'));

// HTTP:
const req = http.expectOne('/api/path');
req.flush(data);                                      // success
req.flush({}, { status: 401, statusText: 'Error' }); // error
http.verify();                                         // no unexpected calls

// Spies:
spy.method.and.returnValue(of(data));
spy.method.and.returnValue(throwError(() => err));
expect(spy.method).toHaveBeenCalledWith('arg');

// Guards:
TestBed.runInInjectionContext(() => myGuard({} as any, {} as any));
```

*End of Part 8. Part 9: Deployment — ng build, environments, Docker.*

---

# CHAPTER 4 — Testing Patterns and Recipes

## 4.1 Testing Components with Signals

If your component uses signals instead of plain properties, the testing approach is the same — signals are synchronous.

```typescript
// Component using signals:
export class Login {
  loading = signal(false);
  serverError = signal('');
  // ...
}

// In the test:
it('should set loading to true while request is in flight', () => {
  authSpy.login.and.returnValue(new Observable(() => {})); // never resolves

  component.loginForm.patchValue({ email: 'k@test.com', password: 'abc' });
  component.submitLogin();

  expect(component.loading()).toBeTrue();
  //                        ^^
  // Reading a signal: call it like a function
  // Angular signals are synchronous — no detectChanges needed to read value
});

it('should show error in template when serverError signal has value', () => {
  authSpy.login.and.returnValue(
    throwError(() => ({ error: { message: 'Invalid credentials' } }))
  );
  component.loginForm.patchValue({ email: 'k@test.com', password: 'wrong' });
  component.submitLogin();

  fixture.detectChanges(); // re-render template with updated signal value

  const alertEl = fixture.nativeElement.querySelector('.alert-danger');
  expect(alertEl?.textContent?.trim()).toBe('Invalid credentials');
});
```

---

## 4.2 Testing Observable Emissions — authStatus$

Testing that a service emits the right values through an Observable:

```typescript
it('should emit true then false on login then logout', () => {
  const emittedValues: boolean[] = [];

  // Collect all emissions:
  service.authStatus$.subscribe(val => emittedValues.push(val));
  // BehaviorSubject: emits initial value (false) immediately on subscribe

  // Login:
  const token = makeToken({ exp: FUTURE });
  service.login('k@test.com', 'pw').subscribe();
  http.expectOne('http://localhost:5000/api/auth/login')
      .flush({ success: true, data: { token } });

  // Logout:
  service.logout();

  expect(emittedValues).toEqual([false, true, false]);
  //                             ^      ^     ^
  //                    initial  login  logout
});
```

---

## 4.3 Testing ngOnInit — Pre-Fill Behavior

```typescript
// Profile component pre-fills form from auth service
describe('Profile Component', () => {
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    authSpy = jasmine.createSpyObj('AuthService', ['getCurrentUser', 'updateProfile']);
    authSpy.getCurrentUser.and.returnValue({
      _id: '1', email: 'k@test.com',
      firstName: 'Khaled', lastName: 'Mohamed', dob: '2000-01-15', role: 'user'
    });

    await TestBed.configureTestingModule({
      imports: [Profile],
      providers: [{ provide: AuthService, useValue: authSpy }]
    }).compileComponents();

    fixture = TestBed.createComponent(Profile);
    component = fixture.componentInstance;
    fixture.detectChanges(); // triggers ngOnInit → patchValue
  });

  it('should pre-fill form with user data from token', () => {
    expect(component.profileForm.get('firstName')?.value).toBe('Khaled');
    expect(component.profileForm.get('lastName')?.value).toBe('Mohamed');
    expect(component.profileForm.get('dob')?.value).toBe('2000-01-15');
  });

  it('should display user email above the form', () => {
    fixture.detectChanges();
    const emailEl = fixture.nativeElement.querySelector('small.text-muted');
    expect(emailEl?.textContent).toContain('k@test.com');
  });

  it('should show success message after successful update', () => {
    authSpy.updateProfile.and.returnValue(of({ success: true }));

    component.profileForm.patchValue({ firstName: 'Ahmed', lastName: 'Hassan', dob: '2000-01-15' });
    component.submitProfile();
    fixture.detectChanges();

    const successEl = fixture.nativeElement.querySelector('.alert-success');
    expect(successEl).not.toBeNull();
    expect(successEl.textContent).toContain('updated successfully');
  });
});
```

---

## 4.4 Testing Navbar — Subscription Behavior

```typescript
describe('Navbar Component', () => {
  let authSpy: jasmine.SpyObj<AuthService>;
  let authStatus$: BehaviorSubject<boolean>;

  beforeEach(async () => {
    authStatus$ = new BehaviorSubject<boolean>(false);
    authSpy = jasmine.createSpyObj('AuthService', ['logout', 'isAdmin']);
    authSpy.isAdmin.and.returnValue(false);
    Object.defineProperty(authSpy, 'authStatus$', { get: () => authStatus$.asObservable() });
    // Object.defineProperty: override the authStatus$ property on the spy
    // because createSpyObj only creates method spies, not property spies

    await TestBed.configureTestingModule({
      imports: [Navbar],
      providers: [{ provide: AuthService, useValue: authSpy }]
    }).compileComponents();

    fixture = TestBed.createComponent(Navbar);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should show Sign In link when not logged in', () => {
    authStatus$.next(false);
    fixture.detectChanges();

    const signInLink = fixture.nativeElement.querySelector('a[routerLink="/auth/login"]');
    expect(signInLink).not.toBeNull();
  });

  it('should show Logout button when logged in', () => {
    authSpy.isAdmin.and.returnValue(false);
    authStatus$.next(true);
    fixture.detectChanges();

    const logoutBtn = fixture.nativeElement.querySelector('button.logout-btn, [data-testid="logout"]');
    expect(logoutBtn).not.toBeNull();
  });

  it('should show Admin link for admin user', () => {
    authSpy.isAdmin.and.returnValue(true);
    authStatus$.next(true);
    fixture.detectChanges();

    const adminLink = fixture.nativeElement.querySelector('a[routerLink="/admin"]');
    expect(adminLink).not.toBeNull();
  });

  it('should call auth.logout() when logout button clicked', () => {
    authStatus$.next(true);
    fixture.detectChanges();

    component.onLogout();
    expect(authSpy.logout).toHaveBeenCalled();
  });

  it('should unsubscribe in ngOnDestroy (no memory leak)', () => {
    const unsubscribeSpy = spyOn(component['authSub'], 'unsubscribe');
    component.ngOnDestroy();
    expect(unsubscribeSpy).toHaveBeenCalled();
  });
});
```

---

## 4.5 Testing Route Guards — adminGuard

```typescript
describe('adminGuard', () => {
  let authSpy: jasmine.SpyObj<AuthService>;
  let routerSpy: jasmine.SpyObj<Router>;

  beforeEach(() => {
    authSpy   = jasmine.createSpyObj('AuthService', ['isLoggedIn', 'isAdmin']);
    routerSpy = jasmine.createSpyObj('Router', ['createUrlTree']);
    routerSpy.createUrlTree.and.callFake((cmds: string[]) => cmds);

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authSpy },
        { provide: Router,      useValue: routerSpy }
      ]
    });
  });

  it('allows admin user through', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    authSpy.isAdmin.and.returnValue(true);

    const result = TestBed.runInInjectionContext(() =>
      adminGuard({} as any, {} as any)
    );
    expect(result).toBeTrue();
  });

  it('redirects logged-in non-admin to home', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    authSpy.isAdmin.and.returnValue(false);

    TestBed.runInInjectionContext(() => adminGuard({} as any, {} as any));
    expect(routerSpy.createUrlTree).toHaveBeenCalledWith(['/']);
  });

  it('redirects non-logged-in user to home (not login)', () => {
    authSpy.isLoggedIn.and.returnValue(false);
    authSpy.isAdmin.and.returnValue(false);

    TestBed.runInInjectionContext(() => adminGuard({} as any, {} as any));
    expect(routerSpy.createUrlTree).toHaveBeenCalledWith(['/']);
    // adminGuard redirects to '/' not '/auth/login' — by design
  });
});
```

---

## 4.6 Test Coverage — Reading the Report

```bash
ng test --code-coverage --watch=false
# Opens coverage/ folder. Open coverage/index.html in browser.
```

The report shows four metrics for each file:

```
Statements: 85%   — 85% of individual code statements were executed
Branches:   72%   — 72% of if/else/ternary branches were tested
Functions:  90%   — 90% of functions were called at least once
Lines:      85%   — 85% of lines were executed
```

**What good coverage looks like:**

```
services/auth.service.ts    → aim for 90%+ (critical business logic)
components/login/login.ts   → aim for 80%+ (user-facing interactions)
guards/auth.guard.ts        → aim for 100% (security-critical)
interceptors/*.ts           → aim for 90%+
components/not-found/       → 60%+ is fine (trivial component)
models/*.ts                 → doesn't need tests (interfaces have no logic)
```

**Excluding files from coverage:**

```typescript
// In a file you don't want measured (e.g., generated mock data):
/* istanbul ignore file */

// Ignore a specific line:
/* istanbul ignore next */
const unusedFallback = value ?? 'default';

// Ignore a function:
/* istanbul ignore next */
function debugHelper() { console.log(this); }
```

---

## 4.7 Writing Testable Code — Design for Testing

Your code is hard to test if:

```typescript
// ❌ Hard to test — creates dependencies inside:
export class BookList {
  books: Book[] = [];

  loadBooks() {
    const http = new HttpClient(/* ... */);  // creating inside — can't inject mock
    http.get('/api/books').subscribe(res => this.books = res);
  }
}

// ❌ Hard to test — uses global state directly:
export class AuthService {
  getToken() {
    return window.localStorage.getItem('jwt_token'); // direct window reference
    // Can mock localStorage in tests but window reference is fragile
  }
}

// ✅ Easy to test — all dependencies injected:
export class BookList {
  private bookService = inject(BookService); // injectable mock

  loadBooks() {
    this.bookService.getBooks().subscribe(res => this.books = res);
  }
}

// ✅ Easy to test — localStorage access abstracted:
@Injectable({ providedIn: 'root' })
export class StorageService {
  get(key: string): string | null { return localStorage.getItem(key); }
  set(key: string, value: string): void { localStorage.setItem(key, value); }
  remove(key: string): void { localStorage.removeItem(key); }
}
// In tests: spyOn(storageService, 'get').and.returnValue('fake-token');
```

---

# Expanded Quick Reference — Testing

## Setup Patterns

```typescript
// Minimal standalone component test:
beforeEach(async () => {
  const spy = jasmine.createSpyObj('ServiceName', ['method1', 'method2']);
  spy.method1.and.returnValue(of(mockData));

  await TestBed.configureTestingModule({
    imports: [ComponentUnderTest],
    providers: [{ provide: ServiceName, useValue: spy }]
  }).compileComponents();

  fixture   = TestBed.createComponent(ComponentUnderTest);
  component = fixture.componentInstance;
  fixture.detectChanges(); // renders + runs ngOnInit
});
```

## Service with HTTP

```typescript
// Must use HttpClientTestingModule (not real HttpClient):
TestBed.configureTestingModule({
  imports: [HttpClientTestingModule, RouterTestingModule],
  providers: [ServiceUnderTest]
});
http = TestBed.inject(HttpTestingController);
afterEach(() => { http.verify(); localStorage.clear(); });

// Expect exactly one request:
const req = http.expectOne('http://localhost:5000/api/auth/login');
expect(req.request.method).toBe('POST');
expect(req.request.body).toEqual({ email: 'k@test.com', password: 'pw' });

// Respond with success:
req.flush({ success: true, data: { token: 'abc' } });

// Respond with error:
req.flush({ message: 'Invalid' }, { status: 401, statusText: 'Unauthorized' });
```

## Common Assertions

```typescript
// Component state:
expect(component.loading).toBeFalse();
expect(component.loading()).toBeFalse();   // if using signal
expect(component.serverError).toBe('Invalid credentials');
expect(component.loginForm.valid).toBeTrue();
expect(component.loginForm.get('email')?.errors?.['email']).toBeTrue();

// DOM:
const el = fixture.nativeElement.querySelector('.alert-danger');
expect(el).not.toBeNull();                 // element exists
expect(el.textContent.trim()).toBe('...');  // text content
expect(el.disabled).toBeTrue();            // property

// Spy:
expect(spy.method).toHaveBeenCalled();
expect(spy.method).toHaveBeenCalledWith('arg1');
expect(spy.method).toHaveBeenCalledTimes(1);
expect(spy.method).not.toHaveBeenCalled();

// Guard:
TestBed.runInInjectionContext(() => myGuard({} as any, {} as any));
```

## Spy Return Values

```typescript
// Synchronous:
spy.method.and.returnValue('value');
spy.method.and.returnValue(true);
spy.method.and.returnValue(null);

// Observable success:
spy.method.and.returnValue(of(data));

// Observable error:
spy.method.and.returnValue(throwError(() => ({ status: 401, error: { message: 'err' } })));

// Observable that never completes (simulate slow network):
spy.method.and.returnValue(new Observable(() => {}));

// Different values on successive calls:
spy.method.and.returnValues('first', 'second', 'third');

// Call the real implementation AND record:
spyOn(service, 'method').and.callThrough();
```

*End of Part 8 (expanded). Part 9: Deployment.*

---

# CHAPTER 5 — Testing Services with Complex Logic

## 5.1 Testing BookService — Pagination and Params

```typescript
// book.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { BookService } from './book.service';
import { Book } from '../models/book.model';

describe('BookService', () => {
  let service: BookService;
  let http: HttpTestingController;

  const mockBooks: Book[] = [
    { _id: '1', title: 'Clean Code',  author: 'Robert Martin',  price: 29.99, coverImage: '', inStock: true },
    { _id: '2', title: 'Refactoring', author: 'Martin Fowler',  price: 34.99, coverImage: '', inStock: true },
  ];

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [BookService]
    });
    service = TestBed.inject(BookService);
    http    = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  describe('getBooks()', () => {
    it('calls the correct URL with default params', () => {
      service.getBooks().subscribe();
      const req = http.expectOne(r => r.url === 'http://localhost:5000/api/books');
      req.flush({ success: true, data: mockBooks, total: 2 });
    });

    it('sends page and limit as query params', () => {
      service.getBooks(2, 6).subscribe();

      const req = http.expectOne(r =>
        r.url === 'http://localhost:5000/api/books' &&
        r.params.get('page') === '2' &&
        r.params.get('limit') === '6'
      );
      // r.params.get() reads query string parameters from the request
      expect(req.request.method).toBe('GET');
      req.flush({ success: true, data: [], total: 0 });
    });

    it('returns books from the response data field', () => {
      let result: Book[] | undefined;
      service.getBooks().pipe(map(r => r.data)).subscribe(books => result = books);

      http.expectOne(r => r.url.includes('/books'))
          .flush({ success: true, data: mockBooks, total: 2 });

      expect(result).toEqual(mockBooks);
      expect(result?.length).toBe(2);
    });
  });

  describe('getBookById()', () => {
    it('calls /books/:id endpoint', () => {
      service.getBookById('123').subscribe();
      const req = http.expectOne('http://localhost:5000/api/books/123');
      expect(req.request.method).toBe('GET');
      req.flush({ success: true, data: mockBooks[0] });
    });

    it('propagates 404 error', () => {
      let error: any;
      service.getBookById('nonexistent').subscribe({
        error: err => error = err
      });
      http.expectOne('http://localhost:5000/api/books/nonexistent')
          .flush({ message: 'Not found' }, { status: 404, statusText: 'Not Found' });

      expect(error.status).toBe(404);
    });
  });

  describe('createBook()', () => {
    it('sends POST with book data', () => {
      const newBook = { title: 'New Book', author: 'Author', price: 19.99 };

      service.createBook(newBook as any).subscribe();
      const req = http.expectOne('http://localhost:5000/api/books');

      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual(newBook);
      req.flush({ success: true, data: { _id: '3', ...newBook } });
    });
  });
});
```

---

## 5.2 Testing Components with Routes — RouterTestingModule

When a component uses `Router`, `ActivatedRoute`, or `RouterLink`, you need router test utilities:

```typescript
import { RouterTestingModule } from '@angular/router/testing';
import { ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';

describe('BookDetail Component', () => {
  let component: BookDetail;
  let fixture: ComponentFixture<BookDetail>;
  let bookServiceSpy: jasmine.SpyObj<BookService>;

  const mockBook: Book = {
    _id: 'abc123', title: 'Clean Code',
    author: 'Robert Martin', price: 29.99,
    coverImage: '/img/cover.jpg', inStock: true
  };

  beforeEach(async () => {
    bookServiceSpy = jasmine.createSpyObj('BookService', ['getBookById']);
    bookServiceSpy.getBookById.and.returnValue(of({ success: true, data: mockBook }));

    await TestBed.configureTestingModule({
      imports: [
        BookDetail,
        RouterTestingModule,
        // RouterTestingModule: provides test versions of Router, RouterLink, RouterOutlet
      ],
      providers: [
        bookServiceSpy,
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: {
              paramMap: {
                get: (key: string) => key === 'id' ? 'abc123' : null
                // Mock the route parameter :id = 'abc123'
              }
            },
            paramMap: of(new Map([['id', 'abc123']]))
            // Mock the observable version too
          }
        }
      ]
    }).compileComponents();

    fixture   = TestBed.createComponent(BookDetail);
    component = fixture.componentInstance;
    fixture.detectChanges(); // triggers ngOnInit → calls getBookById('abc123')
  });

  it('should call getBookById with the route param', () => {
    expect(bookServiceSpy.getBookById).toHaveBeenCalledWith('abc123');
  });

  it('should display book title after loading', () => {
    fixture.detectChanges();
    const titleEl = fixture.nativeElement.querySelector('h2');
    expect(titleEl?.textContent).toContain('Clean Code');
  });

  it('should display book price', () => {
    fixture.detectChanges();
    const priceEl = fixture.nativeElement.querySelector('[data-testid="book-price"]');
    expect(priceEl?.textContent).toContain('29.99');
  });

  it('should show error state when getBookById fails', () => {
    bookServiceSpy.getBookById.and.returnValue(
      throwError(() => ({ status: 404, error: { message: 'Not found' } }))
    );

    fixture = TestBed.createComponent(BookDetail);
    component = fixture.componentInstance;
    fixture.detectChanges();

    const errorEl = fixture.nativeElement.querySelector('.alert-danger, .error-message');
    expect(errorEl).not.toBeNull();
  });
});
```

---

## 5.3 Testing with the async/await Pattern

For components with asynchronous operations, you can use `async/await` with `fixture.whenStable()`:

```typescript
it('should show books after async load', async () => {
  // Set up spy to return Observable:
  bookServiceSpy.getBooks.and.returnValue(of({ success: true, data: mockBooks, total: 2 }));

  fixture.detectChanges(); // triggers ngOnInit

  await fixture.whenStable();
  // whenStable(): waits for all async operations (Promises, Observable microtasks) to settle

  fixture.detectChanges(); // re-render after async completion

  const bookCards = fixture.debugElement.queryAll(By.directive(BookCard));
  expect(bookCards.length).toBe(2);
});

// With HttpTestingController — need to flush manually:
it('should update title after HTTP response', fakeAsync(() => {
  // fakeAsync required for HttpClientTesting:
  fixture.detectChanges();
  // Component makes HTTP call in ngOnInit

  const req = http.expectOne('/api/books');
  req.flush({ data: mockBooks });
  // Flush synchronously (fakeAsync makes this work)

  fixture.detectChanges(); // update template

  const title = fixture.nativeElement.querySelector('h4');
  expect(title?.textContent).toContain('2 Books');
}));
```

---

## 5.4 Testing Pipes

```typescript
// truncate.pipe.spec.ts
import { TruncatePipe } from './truncate.pipe';

describe('TruncatePipe', () => {
  let pipe: TruncatePipe;

  beforeEach(() => {
    pipe = new TruncatePipe();
    // Pipes are pure classes — just instantiate directly, no TestBed needed
  });

  it('returns the original string when shorter than limit', () => {
    expect(pipe.transform('Hello', 10)).toBe('Hello');
  });

  it('truncates long strings and appends ellipsis', () => {
    expect(pipe.transform('Hello World', 5)).toBe('Hello...');
  });

  it('handles null/undefined input gracefully', () => {
    expect(pipe.transform(null as any, 10)).toBe('');
    expect(pipe.transform(undefined as any, 10)).toBe('');
  });

  it('uses custom suffix when provided', () => {
    expect(pipe.transform('Hello World', 5, ' (more)')).toBe('Hello (more)');
  });

  it('handles empty string', () => {
    expect(pipe.transform('', 10)).toBe('');
  });
});
```

---

## 5.5 Testing Animations

Animations can be disabled in tests using `provideNoopAnimations()`:

```typescript
import { provideNoopAnimations } from '@angular/platform-browser/animations/testing';

beforeEach(async () => {
  await TestBed.configureTestingModule({
    imports: [MyAnimatedComponent],
    providers: [
      provideNoopAnimations(),
      // NoopAnimations: animations run instantly with zero duration
      // Components that use [@trigger] still work — they just don't animate
      // This prevents flaky tests caused by animation timing
    ]
  }).compileComponents();
});
```

---

## 5.6 End-to-End Testing Overview (Playwright/Cypress)

Unit tests test individual classes. End-to-end (E2E) tests simulate a real user in a real browser.

Angular projects can use either **Cypress** or **Playwright** for E2E tests.

```bash
# Install Playwright:
npm install -D @playwright/test
npx playwright install

# Basic E2E test for login:
```

```typescript
// tests/login.spec.ts — Playwright
import { test, expect } from '@playwright/test';

test('user can log in and see books page', async ({ page }) => {
  await page.goto('http://localhost:4200/auth/login');

  // Fill the login form:
  await page.fill('input[type="email"]', 'khaled@test.com');
  await page.fill('input[type="password"]', 'password123');
  await page.click('button[type="submit"]');

  // Wait for navigation to books page:
  await page.waitForURL('**/books');

  // Verify books page is shown:
  await expect(page.locator('h2')).toContainText('Our Books');

  // Verify navbar shows logged-in state:
  await expect(page.locator('[data-testid="user-nav"]')).toBeVisible();
});

test('invalid credentials show error message', async ({ page }) => {
  await page.goto('http://localhost:4200/auth/login');
  await page.fill('input[type="email"]', 'wrong@test.com');
  await page.fill('input[type="password"]', 'wrongpassword');
  await page.click('button[type="submit"]');

  // Error message should appear:
  await expect(page.locator('.alert-danger')).toBeVisible();
  await expect(page.locator('.alert-danger')).toContainText('Invalid credentials');

  // Should still be on login page:
  await expect(page.url()).toContain('/auth/login');
});
```

---

# CHAPTER 6 — Test-Driven Development (TDD) in Angular

## 6.1 Writing the Test Before the Code

TDD: write a failing test first, then write just enough code to make it pass.

```typescript
// STEP 1: Write the test FIRST (component doesn't exist yet):
it('should display "No books found" when books array is empty', () => {
  component.books = [];
  fixture.detectChanges();
  const msg = fixture.nativeElement.querySelector('[data-testid="empty-state"]');
  expect(msg).not.toBeNull();
  expect(msg.textContent.trim()).toBe('No books found');
});
// TEST FAILS — 'empty-state' element doesn't exist yet

// STEP 2: Add just enough template to make it pass:
// In book-list.html:
// @if (books.length === 0) {
//   <p data-testid="empty-state">No books found</p>
// }
// TEST PASSES ✅

// STEP 3: Refactor if needed (improve the message, add styling)
// TEST STILL PASSES ✅
```

## 6.2 Using data-testid Attributes

Avoid selecting elements by CSS class or element type — these change when you restyle or refactor.

```html
<!-- FRAGILE — breaks when you change class names or HTML structure: -->
<button class="btn btn-book-primary fw-bold">Add to Cart</button>
<!-- Test: fixture.nativeElement.querySelector('.btn-book-primary') -->
<!-- Breaks if you rename the class -->

<!-- STABLE — test ID never changes: -->
<button class="btn btn-book-primary fw-bold" data-testid="add-to-cart-btn">
  Add to Cart
</button>
<!-- Test: fixture.nativeElement.querySelector('[data-testid="add-to-cart-btn"]') -->
<!-- Renaming the class doesn't break the test -->
```

```typescript
// Helper function for cleaner test code:
function getByTestId(fixture: ComponentFixture<any>, testId: string): HTMLElement | null {
  return fixture.nativeElement.querySelector(`[data-testid="${testId}"]`);
}

// Usage:
const btn   = getByTestId(fixture, 'add-to-cart-btn');
const error = getByTestId(fixture, 'error-message');
const title = getByTestId(fixture, 'book-title');
expect(btn).not.toBeNull();
expect(error?.textContent).toBe('Invalid credentials');
```

---

# Expanded Quick Reference — Testing Complete Reference

## Test File Structure

```typescript
describe('ComponentOrService', () => {
  // Shared variables:
  let component: MyComponent;
  let fixture: ComponentFixture<MyComponent>;
  let serviceSpy: jasmine.SpyObj<MyService>;

  // Setup — runs before EACH test:
  beforeEach(async () => {
    serviceSpy = jasmine.createSpyObj('MyService', ['method']);
    serviceSpy.method.and.returnValue(of(mockData));

    await TestBed.configureTestingModule({
      imports: [MyComponent],
      providers: [{ provide: MyService, useValue: serviceSpy }]
    }).compileComponents();

    fixture   = TestBed.createComponent(MyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  // Grouped by feature:
  describe('initialization', () => {
    it('should render heading', () => {
      expect(fixture.nativeElement.querySelector('h3')).not.toBeNull();
    });
  });

  describe('form validation', () => {
    it('should start invalid', () => {
      expect(component.form.invalid).toBeTrue();
    });
  });

  describe('submit behavior', () => {
    it('should not call service when invalid', () => {
      component.submit();
      expect(serviceSpy.method).not.toHaveBeenCalled();
    });

    it('should navigate on success', () => {
      component.form.patchValue({ field: 'value' });
      component.submit();
      expect(routerSpy.navigate).toHaveBeenCalledWith(['/success']);
    });
  });
});
```

## Complete Mock Data Factories

```typescript
// test-helpers.ts — reusable factories for tests:

export function mockBook(overrides: Partial<Book> = {}): Book {
  return {
    _id:        overrides._id        ?? 'default-id',
    title:      overrides.title      ?? 'Test Book',
    author:     overrides.author     ?? 'Test Author',
    price:      overrides.price      ?? 19.99,
    coverImage: overrides.coverImage ?? '/test-cover.jpg',
    inStock:    overrides.inStock    ?? true,
    ...overrides
  };
}

export function mockUser(overrides: Partial<User> = {}): User {
  return {
    _id:       overrides._id       ?? 'user-id-1',
    email:     overrides.email     ?? 'test@test.com',
    firstName: overrides.firstName ?? 'Test',
    lastName:  overrides.lastName  ?? 'User',
    role:      overrides.role      ?? 'user',
    dob:       overrides.dob       ?? '2000-01-01',
    ...overrides
  };
}

export function makeToken(payload: Partial<JwtPayload> = {}): string {
  const defaultPayload = {
    _id: 'user-1', email: 'test@test.com', role: 'user',
    exp: Math.floor(Date.now() / 1000) + 3600,
    ...payload
  };
  return `header.${btoa(JSON.stringify(defaultPayload))}.signature`;
}

// Usage in tests:
const book = mockBook({ title: 'Custom Title', price: 99 });
const adminUser = mockUser({ role: 'admin' });
const adminToken = makeToken({ role: 'admin' });
```

*End of Part 8 (fully expanded). Part 9: Deployment — ng build, environments, Docker, CI/CD.*
