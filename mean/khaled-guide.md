# 🧑‍💻 Khaled's Personal Guide — MEAN Bookstore Project
> Your role: **Person 1** — Auth + Middleware + Angular Core Infrastructure  
> This guide is written for you specifically. Every command, every file, every decision — in order.

---

## ⚡ Before You Start — One-Time Setup

```bash
# Make sure these are installed
node --version    # should be 18+
npm --version     # should be 9+
git --version

# Install Angular CLI globally if not already
npm install -g @angular/cli
```

---

---

# 📅 DAY 1 — Backend Foundation

> Your job today: build the shared backbone that EVERYONE depends on.  
> Push to `dev` before you do anything else — your teammates can't start without your middleware.

---

## Step 1 — Initialize the backend project

```bash
mkdir bookstore-backend && cd bookstore-backend
npm init -y
```

Install all packages:
```bash
npm install express mongoose bcryptjs jsonwebtoken joi dotenv cors helmet
npm install -D nodemon eslint
```

Create `.eslintrc.json`:
```json
{
  "env": { "node": true, "es2021": true },
  "extends": "eslint:recommended",
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error"
  }
}
```

Add to `package.json` scripts:
```json
"scripts": {
  "start": "node src/app.js",
  "dev": "nodemon src/app.js",
  "lint": "eslint src/"
}
```

---

## Step 2 — Create the folder structure

```bash
mkdir -p src/config src/middleware src/modules/auth src/utils
touch src/app.js
touch src/config/db.js
touch src/middleware/authenticate.js
touch src/middleware/authorize.js
touch src/middleware/errorHandler.js
touch src/utils/ApiError.js
touch src/utils/ApiResponse.js
```

---

## Step 3 — Create `.env` and `.env.example`

`.env` (never commit this):
```
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb+srv://<your-atlas-uri>
JWT_SECRET=your_super_secret_key_here
JWT_EXPIRES_IN=7d
FRONTEND_URL=http://localhost:4200
```

`.env.example` (commit this):
```
PORT=5000
NODE_ENV=development
MONGO_URI=
JWT_SECRET=
JWT_EXPIRES_IN=7d
FRONTEND_URL=
```

Create `.gitignore`:
```
node_modules/
.env
dist/
```

---

## Step 4 — Database connection (`src/config/db.js`)

```js
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`✅ MongoDB connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ MongoDB connection failed: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
```

---

## Step 5 — `ApiError` class (`src/utils/ApiError.js`)

```js
class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = ApiError;
```

> Every controller in the project throws `new ApiError(statusCode, message)` when something goes wrong. That's all — the errorHandler below catches it.

---

## Step 6 — `errorHandler` middleware (`src/middleware/errorHandler.js`)

```js
const ApiError = require('../utils/ApiError');

const errorHandler = (err, req, res, next) => {
  // Known operational error
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
    });
  }

  // MongoDB duplicate key (e.g. duplicate email)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(409).json({
      success: false,
      message: `${field} already exists`,
      errors: [],
    });
  }

  // MongoDB cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: 'Invalid ID format',
      errors: [],
    });
  }

  // Unknown error — never expose details in production
  console.error('UNHANDLED ERROR:', err);
  return res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message,
    errors: [],
  });
};

module.exports = errorHandler;
```

---

## Step 7 — `authenticate` middleware (`src/middleware/authenticate.js`)

```js
const jwt = require('jsonwebtoken');
const ApiError = require('../utils/ApiError');

const authenticate = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new ApiError(401, 'No token provided');
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new ApiError(401, 'Token expired'));
    }
    if (err.name === 'JsonWebTokenError') {
      return next(new ApiError(401, 'Invalid token'));
    }
    next(err);
  }
};

module.exports = authenticate;
```

---

## Step 8 — `authorize` middleware (`src/middleware/authorize.js`)

```js
const ApiError = require('../utils/ApiError');

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new ApiError(401, 'Not authenticated'));
    }
    if (!roles.includes(req.user.role)) {
      return next(new ApiError(403, 'Access denied — insufficient permissions'));
    }
    next();
  };
};

module.exports = authorize;
```

> Usage in routes: `router.post('/', authenticate, authorize('admin'), controller)`

---

## Step 9 — `app.js`

```js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Connect DB
connectDB();

// Security & parsing
app.use(helmet());
app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }));
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Server is running' });
});

// Routes — teammates will add their routers here
// app.use('/api/auth', require('./modules/auth/auth.routes'));
// app.use('/api/books', require('./modules/books/books.routes'));
// app.use('/api/categories', require('./modules/categories/categories.routes'));
// app.use('/api/cart', require('./modules/cart/cart.routes'));
// app.use('/api/orders', require('./modules/orders/orders.routes'));
// app.use('/api/authors', require('./modules/authors/authors.routes'));
// app.use('/api/reviews', require('./modules/reviews/reviews.routes'));
// app.use('/api/upload', require('./modules/upload/upload.routes'));

// Error handler — MUST be last
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
```

---

## Step 10 — Push to GitHub

```bash
git init
git add .
git commit -m "setup: backend foundation — middleware, utils, app.js"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main

# Create dev branch
git checkout -b dev
git push origin dev
```

> 🔴 **Tell your teammates to pull from `dev` before they write a single line of controller code. Your middleware files must be there first.**

---

---

# 📅 DAY 2 — Complete Auth Routes

> Today you build the entire authentication system. By end of day your teammates should be able to register, log in, and get a JWT.

---

## Step 1 — User model (`src/modules/auth/user.model.js`)

```js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email:      { type: String, required: true, unique: true, lowercase: true, index: true },
  firstName:  { type: String, required: true, trim: true },
  lastName:   { type: String, required: true, trim: true },
  dob:        { type: Date,   required: true },
  password:   { type: String, required: true, select: false },
  role:       { type: String, enum: ['user', 'admin'], default: 'user' },
  isVerified: { type: Boolean, default: false },
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

module.exports = mongoose.model('User', userSchema);
```

---

## Step 2 — Joi validation (`src/modules/auth/auth.validation.js`)

```js
const Joi = require('joi');

const registerSchema = Joi.object({
  email:     Joi.string().email().required(),
  firstName: Joi.string().min(2).max(50).required(),
  lastName:  Joi.string().min(2).max(50).required(),
  dob:       Joi.date().max('now').required().messages({
    'date.max': 'Date of birth must be in the past',
  }),
  password:  Joi.string()
    .min(8)
    .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/)
    .required()
    .messages({
      'string.pattern.base': 'Password must contain uppercase, lowercase, and a number',
    }),
});

const loginSchema = Joi.object({
  email:    Joi.string().email().required(),
  password: Joi.string().required(),
});

const updateProfileSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName:  Joi.string().min(2).max(50),
  dob:       Joi.date().max('now'),
}).min(1); // at least one field required

// Middleware factory
const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false });
  if (error) {
    const errors = error.details.map(d => d.message);
    return res.status(400).json({ success: false, message: 'Validation failed', errors });
  }
  next();
};

module.exports = { registerSchema, loginSchema, updateProfileSchema, validate };
```

---

## Step 3 — Auth service (`src/modules/auth/auth.service.js`)

```js
const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  return jwt.sign(
    { _id: user._id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

module.exports = { generateToken };
```

---

## Step 4 — Auth controllers (`src/modules/auth/auth.controller.js`)

```js
const User = require('./user.model');
const { generateToken } = require('./auth.service');
const ApiError = require('../../utils/ApiError');

// POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { email, firstName, lastName, dob, password } = req.body;

    const exists = await User.findOne({ email });
    if (exists) throw new ApiError(409, 'Email already in use');

    const user = await User.create({ email, firstName, lastName, dob, password });

    const userObj = user.toObject();
    delete userObj.password;

    res.status(201).json({ success: true, message: 'Registered successfully', data: userObj });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // select: false on password — must explicitly request it
    const user = await User.findOne({ email }).select('+password');
    if (!user) throw new ApiError(401, 'Invalid credentials');

    const bcrypt = require('bcryptjs');
    const match = await bcrypt.compare(password, user.password);
    if (!match) throw new ApiError(401, 'Invalid credentials');

    const token = generateToken(user);

    const userObj = user.toObject();
    delete userObj.password;

    res.status(200).json({ success: true, message: 'Logged in', data: { token, user: userObj } });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/logout
const logout = async (req, res) => {
  res.status(200).json({ success: true, message: 'Logged out successfully' });
};

// GET /api/auth/me
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) throw new ApiError(404, 'User not found');
    res.status(200).json({ success: true, message: 'User fetched', data: user });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/auth/profile
const updateProfile = async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: req.body },
      { new: true, runValidators: true }
    );
    if (!user) throw new ApiError(404, 'User not found');
    res.status(200).json({ success: true, message: 'Profile updated', data: user });
  } catch (err) {
    next(err);
  }
};

module.exports = { register, login, logout, getMe, updateProfile };
```

---

## Step 5 — Auth routes (`src/modules/auth/auth.routes.js`)

```js
const express = require('express');
const router = express.Router();
const { register, login, logout, getMe, updateProfile } = require('./auth.controller');
const { registerSchema, loginSchema, updateProfileSchema, validate } = require('./auth.validation');
const authenticate = require('../../middleware/authenticate');

router.post('/register', validate(registerSchema), register);
router.post('/login',    validate(loginSchema),    login);
router.post('/logout',   authenticate,             logout);
router.get('/me',        authenticate,             getMe);
router.patch('/profile', authenticate, validate(updateProfileSchema), updateProfile);

module.exports = router;
```

---

## Step 6 — Mount the router in `app.js`

Uncomment this line in `app.js`:
```js
app.use('/api/auth', require('./modules/auth/auth.routes'));
```

---

## Step 7 — Test in Postman

Test in this exact order:

| # | Request | Expected |
|---|---|---|
| 1 | `POST /api/auth/register` with valid body | 201, user without password |
| 2 | `POST /api/auth/register` with same email | 409, "Email already in use" |
| 3 | `POST /api/auth/register` with weak password | 400, validation message |
| 4 | `POST /api/auth/login` with correct credentials | 200, token + user |
| 5 | `POST /api/auth/login` with wrong password | 401, "Invalid credentials" |
| 6 | `GET /api/auth/me` with valid Bearer token | 200, user object |
| 7 | `GET /api/auth/me` with no token | 401, "No token provided" |
| 8 | `PATCH /api/auth/profile` with `{ "firstName": "Test" }` | 200, updated user |
| 9 | `POST /api/auth/logout` | 200, success message |

---

## Step 8 — Commit

```bash
git add .
git commit -m "feat: complete auth routes — register, login, logout, profile"
git push origin dev
```

---

---

# 📅 DAY 3 — Switch to Angular Core

> Backend work is done. Today you build the infrastructure the entire frontend depends on.  
> Your teammates' Angular services and pages all rely on what you build today.

---

## Step 1 — Create the Angular project

```bash
cd ..  # go back to root
ng new bookstore-frontend --routing --style=scss
cd bookstore-frontend
ng add @angular/material
# Choose your theme (see theme suggestions file)
# Say YES to typography and animations
```

---

## Step 2 — Create the folder structure

```bash
# Core folder
mkdir -p src/app/core/services
mkdir -p src/app/core/guards
mkdir -p src/app/core/interceptors
mkdir -p src/app/core/models

# Features
mkdir -p src/app/features/auth

# Create files
touch src/app/core/services/auth.service.ts
touch src/app/core/guards/auth.guard.ts
touch src/app/core/guards/admin.guard.ts
touch src/app/core/interceptors/token.interceptor.ts
touch src/app/core/interceptors/error.interceptor.ts
```

---

## Step 3 — Environment files (`src/environments/`)

`environment.ts`:
```ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api'
};
```

`environment.prod.ts`:
```ts
export const environment = {
  production: true,
  apiUrl: 'WILL_BE_SET_AFTER_DEPLOYMENT'  // Person 3 will give you this URL on Day 5
};
```

---

## Step 4 — All TypeScript interfaces (`src/app/core/models/`)

> ⚠️ Write all of these. Your teammates import from here — nobody defines their own interfaces.

`src/app/core/models/index.ts`:
```ts
export interface User {
  _id: string;
  email: string;
  firstName: string;
  lastName: string;
  dob: string;
  role: 'user' | 'admin';
  isVerified: boolean;
  createdAt: string;
}

export interface Author {
  _id: string;
  name: string;
  bio: string;
}

export interface Category {
  _id: string;
  name: string;
}

export interface Book {
  _id: string;
  name: string;
  price: number;
  stock: number;
  coverImage: string;
  author: Author;
  category: Category | null;
}

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

export interface OrderItem {
  book: Pick<Book, '_id' | 'name' | 'coverImage'>;
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

export interface Review {
  _id: string;
  user: Pick<User, '_id' | 'firstName' | 'lastName'>;
  book: string;
  rating: number;
  comment?: string;
  createdAt: string;
}

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

---

## Step 5 — AuthService (`src/app/core/services/auth.service.ts`)

```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { User } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private apiUrl = `${environment.apiUrl}/auth`;
  private TOKEN_KEY = 'jwt_token';

  constructor(private http: HttpClient, private router: Router) {}

  register(data: Partial<User> & { password: string }): Observable<any> {
    return this.http.post(`${this.apiUrl}/register`, data);
  }

  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/login`, { email, password }).pipe(
      tap(res => {
        if (res.data?.token) {
          localStorage.setItem(this.TOKEN_KEY, res.data.token);
        }
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.router.navigate(['/auth/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  getCurrentUser(): User | null {
    const token = this.getToken();
    if (!token) return null;
    try {
      // Decode JWT payload (base64 middle part) — no API call needed
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload as User;
    } catch {
      return null;
    }
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (!token) return false;
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      // Check expiry
      return payload.exp * 1000 > Date.now();
    } catch {
      return false;
    }
  }

  isAdmin(): boolean {
    return this.getCurrentUser()?.role === 'admin';
  }

  updateProfile(data: Partial<User>): Observable<any> {
    return this.http.patch(`${this.apiUrl}/profile`, data);
  }
}
```

---

## Step 6 — TokenInterceptor (`src/app/core/interceptors/token.interceptor.ts`)

```ts
import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';

@Injectable()
export class TokenInterceptor implements HttpInterceptor {
  constructor(private authService: AuthService) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = this.authService.getToken();
    if (token) {
      const cloned = req.clone({
        setHeaders: { Authorization: `Bearer ${token}` }
      });
      return next.handle(cloned);
    }
    return next.handle(req);
  }
}
```

---

## Step 7 — ErrorInterceptor (`src/app/core/interceptors/error.interceptor.ts`)

```ts
import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { AuthService } from '../services/auth.service';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(
    private authService: AuthService,
    private router: Router,
    private snackBar: MatSnackBar
  ) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError((err: HttpErrorResponse) => {
        if (err.status === 401) {
          this.authService.logout();
        }
        if (err.status === 403) {
          this.router.navigate(['/']);
          this.snackBar.open('Access denied', 'Close', { duration: 3000 });
        }
        return throwError(() => err);
      })
    );
  }
}
```

---

## Step 8 — Guards

`src/app/core/guards/auth.guard.ts`:
```ts
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(): boolean {
    if (this.authService.isLoggedIn()) return true;
    this.router.navigate(['/auth/login']);
    return false;
  }
}
```

`src/app/core/guards/admin.guard.ts`:
```ts
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({ providedIn: 'root' })
export class AdminGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(): boolean {
    if (this.authService.isAdmin()) return true;
    this.router.navigate(['/']);
    return false;
  }
}
```

---

## Step 9 — Register interceptors in `app.module.ts`

```ts
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { TokenInterceptor } from './core/interceptors/token.interceptor';
import { ErrorInterceptor } from './core/interceptors/error.interceptor';
import { MatSnackBarModule } from '@angular/material/snack-bar';

@NgModule({
  imports: [
    HttpClientModule,
    MatSnackBarModule,
    // ... other imports
  ],
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: TokenInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
  ],
})
export class AppModule {}
```

---

## Step 10 — Generate auth feature module

```bash
ng generate module features/auth --routing
ng generate component features/auth/login
ng generate component features/auth/register
```

---

## Step 11 — Login page (`src/app/features/auth/login/login.component.ts`)

```ts
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
})
export class LoginComponent {
  form: FormGroup;
  loading = false;
  serverError = '';

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {
    this.form = this.fb.group({
      email:    ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
    });
  }

  submit() {
    if (this.form.invalid) return;
    this.loading = true;
    this.serverError = '';
    this.form.disable();

    const { email, password } = this.form.value;
    this.auth.login(email, password).subscribe({
      next: () => { this.router.navigate(['/books']); },
      error: (err) => {
        this.serverError = err.error?.message || 'Login failed';
        this.loading = false;
        this.form.enable();
      }
    });
  }
}
```

`login.component.html`:
```html
<div class="auth-container">
  <mat-card class="auth-card">
    <mat-card-header>
      <mat-card-title>Welcome back</mat-card-title>
      <mat-card-subtitle>Sign in to your account</mat-card-subtitle>
    </mat-card-header>

    <mat-card-content>
      <form [formGroup]="form" (ngSubmit)="submit()">

        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="email" />
          <mat-error *ngIf="form.get('email')?.hasError('required')">Email is required</mat-error>
          <mat-error *ngIf="form.get('email')?.hasError('email')">Enter a valid email</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Password</mat-label>
          <input matInput type="password" formControlName="password" />
          <mat-error *ngIf="form.get('password')?.hasError('required')">Password is required</mat-error>
        </mat-form-field>

        <p class="server-error" *ngIf="serverError">{{ serverError }}</p>

        <button mat-raised-button color="primary" type="submit" class="full-width" [disabled]="loading">
          <mat-spinner *ngIf="loading" diameter="20"></mat-spinner>
          <span *ngIf="!loading">Sign In</span>
        </button>

      </form>
    </mat-card-content>

    <mat-card-actions>
      <a routerLink="/auth/register">Don't have an account? Register</a>
    </mat-card-actions>
  </mat-card>
</div>
```

---

## Step 12 — Commit

```bash
git add .
git commit -m "feat: Angular core — interfaces, AuthService, interceptors, guards, Login, Register"
git push origin dev
```

---

---

# 📅 DAY 4 — Profile Page + Auth Polish

> Shorter day. Profile page + make login/register feel production-quality.

---

## Step 1 — Generate Profile component

```bash
ng generate component features/auth/profile
```

---

## Step 2 — Profile component (`profile.component.ts`)

```ts
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
})
export class ProfileComponent implements OnInit {
  form!: FormGroup;
  loading = false;
  email = '';

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit() {
    const user = this.auth.getCurrentUser();  // decode from token — no API call
    this.email = user?.email || '';
    this.form = this.fb.group({
      firstName: [user?.['firstName'] || '', [Validators.required, Validators.minLength(2)]],
      lastName:  [user?.['lastName']  || '', [Validators.required, Validators.minLength(2)]],
      dob:       [user?.['dob']       || '', [Validators.required]],
    });
  }

  submit() {
    if (this.form.invalid) return;
    this.loading = true;
    this.form.disable();

    this.auth.updateProfile(this.form.value).subscribe({
      next: () => {
        this.snackBar.open('Profile updated!', 'Close', { duration: 3000 });
        this.loading = false;
        this.form.enable();
      },
      error: (err) => {
        this.snackBar.open(err.error?.message || 'Update failed', 'Close', { duration: 3000 });
        this.loading = false;
        this.form.enable();
      }
    });
  }
}
```

---

## Step 3 — Commit

```bash
git add .
git commit -m "feat: Profile page with token decode, form pre-fill, update handler"
git push origin dev
```

---

---

# 📅 DAY 5 — Wire Profile + Spot Check Teams

> Your own wiring is quick. Spend most of this day checking everyone else's integration.

---

## Checklist for spot-checking teammates

Open DevTools → Network tab on each page and verify:

**Protected routes (Cart, Orders, Admin, Profile)**
- [ ] Every request has `Authorization: Bearer <token>` header
- [ ] Removing the token from localStorage + refreshing → redirected to login

**Public routes (Home, Book List, Book Detail, Login, Register)**
- [ ] No Authorization header on any request

**Error handling**
- [ ] Manually expire the token (or delete it mid-session) → 401 → logout + redirect to login
- [ ] Log in as regular user, navigate to `/admin` → redirected to home with no crash
- [ ] Confirm 403 shows a snackbar message, doesn't show an error page

**Cart count in Navbar**
Wire this in Person 3's Navbar — make sure it subscribes correctly:
```ts
// In navbar.component.ts
import { CartService } from '../../../core/services/cart.service';

cartCount$ = this.cartService.cartCount$;
```
```html
<!-- In navbar template -->
<button mat-icon-button routerLink="/cart">
  <mat-icon matBadge="{{ cartCount$ | async }}" matBadgeColor="warn">shopping_cart</mat-icon>
</button>
```

---

## Commit

```bash
git add .
git commit -m "fix: spot check integration — auth headers, guards, cart count wired"
git push origin dev
```

---

---

# 📅 DAY 6 — Integration Testing

> No new code. Your job is to run through every auth-related test case and fix what breaks.

---

## Your personal test checklist

- [ ] Register → success toast → redirected to login
- [ ] Register same email → "Email already in use" shown in form (not a snackbar)
- [ ] Register with short password → inline validation under the field
- [ ] Login with correct credentials → token in localStorage → redirected to `/books`
- [ ] Login with wrong password → "Invalid credentials" inline in form
- [ ] After login → Profile page shows pre-filled name and email
- [ ] Update profile → new name reflected immediately
- [ ] Logout → localStorage cleared → `/orders` redirects to login
- [ ] Login as admin account → "Admin Panel" link appears in navbar
- [ ] `isAdmin()` returns `true` for admin, `false` for regular user

---

---

# 📅 DAY 7 — Error Polish + 404 Page + Backend README

---

## Step 1 — Audit every error across the app

Go through every form and every HTTP call your code makes. Enforce this rule:

> **Never show a raw error object. Always show either a `mat-error` under a field OR a `MatSnackBar` toast.**

Pattern for any component that makes HTTP calls:
```ts
error: (err) => {
  const msg = err.error?.message || 'Something went wrong';
  this.snackBar.open(msg, 'Close', { duration: 4000 });
}
```

---

## Step 2 — Generate 404 page

```bash
ng generate component features/not-found
```

`not-found.component.html`:
```html
<div class="not-found">
  <h1>404</h1>
  <p>Page not found</p>
  <a mat-raised-button color="primary" routerLink="/books">Back to Books</a>
</div>
```

Add wildcard route at the **very bottom** of `app-routing.module.ts`:
```ts
{ path: '**', component: NotFoundComponent }
```

---

## Step 3 — Backend README (`backend/README.md`)

```markdown
# 📚 Bookstore API

## Tech Stack
- Node.js + Express
- MongoDB + Mongoose
- JWT Authentication
- Cloudinary (image storage)
- Joi (validation)
- Railway (deployment)

## Setup

\`\`\`bash
git clone <repo-url>
cd bookstore-backend
cp .env.example .env
# Fill in all values in .env
npm install
npm run dev
\`\`\`

## Environment Variables

| Variable | Description |
|---|---|
| `PORT` | Server port (default 5000) |
| `MONGO_URI` | MongoDB Atlas connection string |
| `JWT_SECRET` | Secret key for JWT signing |
| `JWT_EXPIRES_IN` | Token expiry (e.g. `7d`) |
| `CLOUDINARY_CLOUD_NAME` | From your Cloudinary dashboard |
| `CLOUDINARY_API_KEY` | From your Cloudinary dashboard |
| `CLOUDINARY_API_SECRET` | From your Cloudinary dashboard |
| `NODE_ENV` | `development` or `production` |
| `FRONTEND_URL` | Deployed frontend URL (for CORS) |

## Live API
`https://<your-railway-url>`

## Postman Collection
See `/postman-collection.json` in this repo

## API Routes

| Method | Route | Auth | Description |
|---|---|---|---|
| POST | /api/auth/register | Public | Register a new user |
| POST | /api/auth/login | Public | Login and get JWT |
| POST | /api/auth/logout | JWT | Logout |
| GET | /api/auth/me | JWT | Get current user |
| PATCH | /api/auth/profile | JWT | Update profile |
| GET | /api/books | Public | Get all books (search, filter, paginate) |
| GET | /api/books/:id | Public | Get single book |
| POST | /api/books | Admin | Create book |
| PATCH | /api/books/:id | Admin | Update book |
| DELETE | /api/books/:id | Admin | Delete book |
| GET | /api/categories | Public | Get all categories |
| POST | /api/categories | Admin | Create category |
| PATCH | /api/categories/:id | Admin | Update category |
| DELETE | /api/categories/:id | Admin | Delete category |
| GET | /api/authors | Public | Get all authors |
| POST | /api/authors | Admin | Create author |
| PATCH | /api/authors/:id | Admin | Update author |
| GET | /api/cart | JWT | View cart |
| POST | /api/cart | JWT | Add to cart |
| DELETE | /api/cart/:bookId | JWT | Remove from cart |
| POST | /api/orders | JWT | Place order (transaction) |
| GET | /api/orders/my | JWT | My orders |
| GET | /api/orders | Admin | All orders |
| PATCH | /api/orders/:id/status | Admin | Update status |
| GET | /api/reviews?bookId= | Public | Get reviews for a book |
| POST | /api/reviews | JWT | Add review (delivered gate) |
| DELETE | /api/reviews/:id | JWT | Delete own review |
| GET | /api/upload/signature | Admin | Get Cloudinary pre-signed URL |
```

---

## Step 4 — Commit

```bash
git add .
git commit -m "feat: 404 page, wildcard route, error polish, backend README"
git push origin dev
```

---

---

# 📅 DAY 8 — Final Checks + Bonus (Email Verification)

---

## Morning — Run full checklist on live URLs

> Test on the **deployed Railway + Vercel URLs** only — not localhost.

- [ ] Every auth flow works on live URL
- [ ] No `console.log` in production code: `grep -r "console.log" src/`
- [ ] ESLint passes: `npm run lint`
- [ ] `ng lint` passes in frontend
- [ ] `.env` not in GitHub repo: check on GitHub directly

---

## Bonus — Email Verification (if time allows)

### Backend changes

Install Nodemailer:
```bash
npm install nodemailer
```

Add to `.env`:
```
EMAIL_USER=your@gmail.com
EMAIL_PASS=your_app_password   # Gmail App Password — not your actual password
```

Add `verificationToken` field to User model:
```js
verificationToken: { type: String, default: null }
```

Update Register controller to send verification email:
```js
const crypto = require('crypto');
const nodemailer = require('nodemailer');

// After creating user:
const verificationToken = crypto.randomBytes(32).toString('hex');
await User.findByIdAndUpdate(user._id, { verificationToken });

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS }
});

await transporter.sendMail({
  to: user.email,
  subject: 'Verify your Bookstore account',
  html: `<p>Click to verify: <a href="${process.env.FRONTEND_URL}/auth/verify?token=${verificationToken}">Verify Email</a></p>`
});
```

Add verify route in `auth.routes.js`:
```js
router.get('/verify/:token', async (req, res, next) => {
  try {
    const user = await User.findOne({ verificationToken: req.params.token });
    if (!user) throw new ApiError(400, 'Invalid or expired token');
    user.isVerified = true;
    user.verificationToken = null;
    await user.save();
    res.json({ success: true, message: 'Email verified. You can now log in.' });
  } catch (err) { next(err); }
});
```

Update Login controller to check `isVerified`:
```js
if (!user.isVerified) {
  throw new ApiError(403, 'Please verify your email before logging in');
}
```

### Frontend changes

After successful register — navigate to a "Check Your Email" page instead of login:
```ts
// In register.component.ts
next: () => {
  this.router.navigate(['/auth/check-email']);
}
```

Generate and build the component:
```bash
ng generate component features/auth/check-email
```

---

## Final commit

```bash
git add .
git commit -m "feat: final checks + email verification bonus"
git push origin dev

# Merge to main for submission
git checkout main
git merge dev
git tag v1.0.0
git push origin main --tags
```

---

## ✅ You're done. What you delivered:

| Deliverable | Status |
|---|---|
| Express + Mongoose backend foundation | ✅ |
| ApiError + errorHandler + authenticate + authorize | ✅ |
| Complete auth system (register, login, logout, profile) | ✅ |
| All TypeScript interfaces (shared across team) | ✅ |
| AuthService with JWT decode (no extra API calls) | ✅ |
| TokenInterceptor + ErrorInterceptor | ✅ |
| AuthGuard + AdminGuard | ✅ |
| Login + Register + Profile pages | ✅ |
| 404 page + wildcard route | ✅ |
| Backend README | ✅ |
| Email verification (bonus) | ✅ |
