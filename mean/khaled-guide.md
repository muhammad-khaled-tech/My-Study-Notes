# 🧑‍💻 Khaled's Personal Guide
> Role: Person 1 — Auth + Middleware + Angular Core  
> Based on: **bookstore-backend** + **bookstore-frontend** by John Roufaeil

---

## ⚠️ Read This First — What's Already Done vs What You Do

### Backend (bookstore-backend)
| Already there | You add |
|---|---|
| All packages installed (express, mongoose, bcryptjs, jsonwebtoken, joi, dotenv, cors, helmet, pino) | `.env` file |
| `index.js` with dotenv, express, mongoose.connect, app.listen | Folder structure inside `src/` |
| 4 empty barrel files in `src/` | All middleware, models, routes |
| ESLint configured | — |

### Frontend (bookstore-frontend)
| Already there | You add |
|---|---|
| Angular 21 project with routing | Angular Material |
| `app.config.ts` with provideRouter | All services, guards, interceptors |
| Empty `app.routes.ts` | All feature components |
| Plain `.css` (not SCSS) | Theme variables in `styles.css` |

### 🔴 Two things that change everything vs older guides

**1. Express 5** — async errors propagate automatically to your error handler.  
No `try/catch` needed in controllers. Just `throw new ApiError(...)` and Express catches it.

**2. Angular 21 Standalone** — there is no `app.module.ts`.  
Guards and interceptors are **functions**, not classes.  
Everything is wired through `app.config.ts`.  
Any Angular tutorial that mentions `NgModule` does not apply here.

---
---

# 📅 DAY 1 — Backend Foundation

---

### Step 1 — Clone and install

```bash
git clone https://github.com/john-roufaeil/bookstore-backend.git
cd bookstore-backend
npm install
```

---

### Step 2 — Create `.env`

`.env` (never commit — already in .gitignore):
```
PORT=5000
NODE_ENV=development
MONGO_URI=your_atlas_connection_string
JWT_SECRET=pick_any_long_random_string
JWT_EXPIRES_IN=7d
FRONTEND_URL=http://localhost:4200
```

`.env.example` (commit this — teammates need it):
```
PORT=5000
NODE_ENV=development
MONGO_URI=
JWT_SECRET=
JWT_EXPIRES_IN=7d
FRONTEND_URL=
```

---

### Step 3 — Create your folder structure

```bash
mkdir -p src/config
mkdir -p src/modules/auth
mkdir -p src/utils

touch src/config/db.js
touch src/utils/ApiError.js
touch src/utils/ApiResponse.js
touch src/middlewares/errorHandler.js
touch src/middlewares/authenticate.js
touch src/middlewares/authorize.js
touch src/modules/auth/auth.model.js
touch src/modules/auth/auth.validation.js
touch src/modules/auth/auth.service.js
touch src/modules/auth/auth.controller.js
touch src/modules/auth/auth.routes.js
```

---

### Step 4 — `src/config/db.js`

```js
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ DB connection failed:', err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
```

---

### Step 5 — `src/utils/ApiError.js`

```js
class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    this.isOperational = true;
  }
}

module.exports = ApiError;
```

---

### Step 6 — `src/utils/ApiResponse.js`

> The plan gives this to Person 3 but you need it on Day 2 for your own controllers.  
> Build it here. Person 3 just imports it.

```js
class ApiResponse {
  static success(res, statusCode, message, data, pagination = null) {
    const body = { success: true, message, data };
    if (pagination) body.pagination = pagination;
    return res.status(statusCode).json(body);
  }
}

module.exports = ApiResponse;
```

---

### Step 7 — `src/middlewares/errorHandler.js`

```js
const ApiError = require('../utils/ApiError');

const errorHandler = (err, req, res, next) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
    });
  }

  // MongoDB duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(409).json({ success: false, message: `${field} already exists`, errors: [] });
  }

  // Invalid ObjectId
  if (err.name === 'CastError') {
    return res.status(400).json({ success: false, message: 'Invalid ID format', errors: [] });
  }

  console.error('Unhandled error:', err);
  return res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message,
    errors: [],
  });
};

module.exports = errorHandler;
```

---

### Step 8 — `src/middlewares/authenticate.js`

```js
const jwt = require('jsonwebtoken');
const ApiError = require('../utils/ApiError');

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer '))
    return next(new ApiError(401, 'No token provided'));

  const token = authHeader.split(' ')[1];
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    const msg = err.name === 'TokenExpiredError' ? 'Token expired' : 'Invalid token';
    next(new ApiError(401, msg));
  }
};

module.exports = authenticate;
```

---

### Step 9 — `src/middlewares/authorize.js`

```js
const ApiError = require('../utils/ApiError');

const authorize = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user?.role))
    return next(new ApiError(403, 'Access denied'));
  next();
};

module.exports = authorize;
```

---

### Step 10 — Update barrel files

`src/middlewares/index.js`:
```js
exports.errorHandler  = require('./errorHandler');
exports.authenticate  = require('./authenticate');
exports.authorize     = require('./authorize');
```

`src/utils/index.js` (create this file):
```js
exports.ApiError    = require('./ApiError');
exports.ApiResponse = require('./ApiResponse');
```

---

### Step 11 — Update `index.js`

> The file already has dotenv, express, and mongoose.connect.  
> Replace it entirely with this cleaner version that adds your middleware:

```js
require('dotenv').config();
const process = require('node:process');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const connectDB = require('./src/config/db');
const { errorHandler } = require('./src/middlewares');

const app = express();

connectDB();

app.use(helmet());
app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }));
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Server is running' });
});

// Your auth routes
app.use('/api/auth', require('./src/modules/auth/auth.routes'));

// Teammates add their routes here (uncomment as they build them)
// app.use('/api/books',      require('./src/modules/books/books.routes'));
// app.use('/api/categories', require('./src/modules/categories/categories.routes'));
// app.use('/api/cart',       require('./src/modules/cart/cart.routes'));
// app.use('/api/orders',     require('./src/modules/orders/orders.routes'));
// app.use('/api/authors',    require('./src/modules/authors/authors.routes'));
// app.use('/api/reviews',    require('./src/modules/reviews/reviews.routes'));
// app.use('/api/upload',     require('./src/modules/upload/upload.routes'));

// Error handler — must be last
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server on http://localhost:${PORT}`));
```

---

### Step 12 — Test it runs

```bash
npm run dev
# Should see:
# ✅ MongoDB connected
# 🚀 Server on http://localhost:5000
```

Hit `http://localhost:5000/api/health` in browser → should see `{ success: true }`.

---

### Step 13 — Push to dev branch

```bash
git checkout -b dev
git add .
git commit -m "setup: db, middleware, utils, updated index.js"
git push origin dev
```

> 🔴 **Tell teammates in the group chat to pull `dev` now before writing any code.  
> Your `authenticate` and `authorize` files must be there before anyone writes a controller.**

---
---

# 📅 DAY 2 — Complete Auth Routes

---

### Step 1 — User model (`src/modules/auth/auth.model.js`)

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

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

module.exports = mongoose.model('User', userSchema);
```

Update `src/models/index.js`:
```js
exports.User = require('../modules/auth/auth.model');
```

---

### Step 2 — Validation (`src/modules/auth/auth.validation.js`)

```js
const Joi = require('joi');

const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false });
  if (!error) return next();
  const errors = error.details.map((d) => d.message);
  return res.status(400).json({ success: false, message: 'Validation failed', errors });
};

const registerSchema = Joi.object({
  email:     Joi.string().email().required(),
  firstName: Joi.string().min(2).max(50).required(),
  lastName:  Joi.string().min(2).max(50).required(),
  dob:       Joi.date().max('now').required()
    .messages({ 'date.max': 'Date of birth must be in the past' }),
  password:  Joi.string().min(8)
    .pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/).required()
    .messages({ 'string.pattern.base': 'Password needs uppercase, lowercase, and a number' }),
});

const loginSchema = Joi.object({
  email:    Joi.string().email().required(),
  password: Joi.string().required(),
});

const updateProfileSchema = Joi.object({
  firstName: Joi.string().min(2).max(50),
  lastName:  Joi.string().min(2).max(50),
  dob:       Joi.date().max('now'),
}).min(1);

module.exports = { validate, registerSchema, loginSchema, updateProfileSchema };
```

---

### Step 3 — Auth service (`src/modules/auth/auth.service.js`)

```js
const jwt = require('jsonwebtoken');

const generateToken = (user) =>
  jwt.sign(
    { _id: user._id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );

module.exports = { generateToken };
```

---

### Step 4 — Controllers (`src/modules/auth/auth.controller.js`)

> Express 5 catches async throws automatically — no try/catch needed.

```js
const bcrypt = require('bcryptjs');
const User = require('./auth.model');
const { generateToken } = require('./auth.service');
const ApiError = require('../../utils/ApiError');
const ApiResponse = require('../../utils/ApiResponse');

const register = async (req, res) => {
  const { email, firstName, lastName, dob, password } = req.body;

  if (await User.findOne({ email }))
    throw new ApiError(409, 'Email already in use');

  const user = await User.create({ email, firstName, lastName, dob, password });
  const userObj = user.toObject();
  delete userObj.password;

  ApiResponse.success(res, 201, 'Registered successfully', userObj);
};

const login = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await bcrypt.compare(password, user.password)))
    throw new ApiError(401, 'Invalid credentials');

  const token = generateToken(user);
  const userObj = user.toObject();
  delete userObj.password;

  ApiResponse.success(res, 200, 'Logged in', { token, user: userObj });
};

const logout = async (req, res) => {
  ApiResponse.success(res, 200, 'Logged out successfully', null);
};

const getMe = async (req, res) => {
  const user = await User.findById(req.user._id);
  if (!user) throw new ApiError(404, 'User not found');
  ApiResponse.success(res, 200, 'User fetched', user);
};

const updateProfile = async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.user._id,
    { $set: req.body },
    { new: true, runValidators: true }
  );
  if (!user) throw new ApiError(404, 'User not found');
  ApiResponse.success(res, 200, 'Profile updated', user);
};

module.exports = { register, login, logout, getMe, updateProfile };
```

---

### Step 5 — Routes (`src/modules/auth/auth.routes.js`)

```js
const { Router } = require('express');
const { register, login, logout, getMe, updateProfile } = require('./auth.controller');
const { validate, registerSchema, loginSchema, updateProfileSchema } = require('./auth.validation');
const { authenticate } = require('../../middlewares');

const router = Router();

router.post('/register', validate(registerSchema), register);
router.post('/login',    validate(loginSchema),    login);
router.post('/logout',   authenticate,             logout);
router.get('/me',        authenticate,             getMe);
router.patch('/profile', authenticate, validate(updateProfileSchema), updateProfile);

module.exports = router;
```

Update `src/routes/index.js`:
```js
exports.authRoutes = require('../modules/auth/auth.routes');
```

---

### Step 6 — Postman test sequence

| # | Method + Route | What to send | Expected |
|---|---|---|---|
| 1 | POST `/api/auth/register` | `{email, firstName, lastName, dob:"2000-01-01", password:"Test123!"}` | 201 + user (no password field) |
| 2 | POST `/api/auth/register` | Same email again | 409 "Email already in use" |
| 3 | POST `/api/auth/register` | `password: "abc"` | 400 with validation message |
| 4 | POST `/api/auth/login` | `{email, password}` | 200 + token |
| 5 | POST `/api/auth/login` | Wrong password | 401 "Invalid credentials" |
| 6 | GET `/api/auth/me` | Header: `Authorization: Bearer <token>` | 200 + user |
| 7 | GET `/api/auth/me` | No header | 401 "No token provided" |
| 8 | PATCH `/api/auth/profile` | `{firstName:"New"}` + token | 200 + updated user |

---

### Step 7 — Commit

```bash
git add .
git commit -m "feat: complete auth — model, validation, service, controllers, routes"
git push origin dev
```

---
---

# 📅 DAY 3 — Angular Core

> Angular 21 = standalone components. No NgModule. No app.module.ts.  
> Providers go in `app.config.ts`. Guards and interceptors are plain functions.

---

### Step 1 — Clone and install Angular Material

```bash
git clone https://github.com/john-roufaeil/bookstore-frontend.git
cd bookstore-frontend
npm install
ng add @angular/material
# Choose any prebuilt theme (you override colors in CSS anyway)
# Say YES to typography
# Say YES to animations
```

---

### Step 2 — Add font to `src/index.html`

```html
<head>
  <meta charset="utf-8">
  <title>Bookstore</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@300;400;700&display=swap" rel="stylesheet">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>
```

---

### Step 3 — Classic Ivory theme in `src/styles.css`

```css
body {
  --bg-page:      #faf7f2;
  --bg-surface:   #ffffff;
  --bg-card:      #f5f0e8;
  --border:       #e5ddd0;
  --text-primary: #1a1208;
  --text-muted:   #7a6a5a;
  --primary:      #5C3D2E;
  --accent:       #D4A853;

  background-color: var(--bg-page);
  color: var(--text-primary);
  font-family: 'Merriweather', Georgia, serif;
  margin: 0;
}

body.dark-mode {
  --bg-page:      #1a1208;
  --bg-surface:   #241810;
  --bg-card:      #2e1f12;
  --border:       #3d2a1a;
  --text-primary: #f5f0e8;
  --text-muted:   #a09080;
  --primary:      #D4A853;
  --accent:       #8B5E3C;
}

/* Tell teammates to use these — never hardcode colors */
.book-cover { width: 100%; height: 220px; object-fit: cover; display: block; }

.badge { padding: 3px 10px; border-radius: 4px; font-size: 12px; font-weight: 700; }
.badge.processing       { background: #FEF3C7; color: #92400E; }
.badge.out_for_delivery { background: #DBEAFE; color: #1E40AF; }
.badge.delivered        { background: #D1FAE5; color: #065F46; }

body.dark-mode .badge.processing       { background: #451a0366; color: #FCD34D; }
body.dark-mode .badge.out_for_delivery { background: #1e3a5f66; color: #93C5FD; }
body.dark-mode .badge.delivered        { background: #06402a66; color: #6EE7B7; }
```

---

### Step 4 — Create folder structure

```bash
mkdir -p src/app/core/services
mkdir -p src/app/core/guards
mkdir -p src/app/core/interceptors
mkdir -p src/app/core/models
mkdir -p src/environments
```

---

### Step 5 — Environment files

`src/environments/environment.ts`:
```ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api'
};
```

`src/environments/environment.prod.ts`:
```ts
export const environment = {
  production: true,
  apiUrl: 'REPLACE_WITH_RAILWAY_URL_ON_DAY_5'
};
```

---

### Step 6 — All TypeScript interfaces (`src/app/core/models/index.ts`)

> Write all of these. Teammates import from here — nobody defines their own.

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

### Step 7 — AuthService (`src/app/core/services/auth.service.ts`)

```ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { User } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http   = inject(HttpClient);
  private router = inject(Router);
  private api    = `${environment.apiUrl}/auth`;
  private KEY    = 'jwt_token';

  register(data: Partial<User> & { password: string }): Observable<any> {
    return this.http.post(`${this.api}/register`, data);
  }

  login(email: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.api}/login`, { email, password }).pipe(
      tap(res => { if (res.data?.token) localStorage.setItem(this.KEY, res.data.token); })
    );
  }

  logout(): void {
    localStorage.removeItem(this.KEY);
    this.router.navigate(['/auth/login']);
  }

  getToken(): string | null { return localStorage.getItem(this.KEY); }

  getCurrentUser(): any | null {
    const token = this.getToken();
    if (!token) return null;
    try { return JSON.parse(atob(token.split('.')[1])); }
    catch { return null; }
  }

  isLoggedIn(): boolean {
    try {
      const token = this.getToken();
      if (!token) return false;
      const { exp } = JSON.parse(atob(token.split('.')[1]));
      return exp * 1000 > Date.now();
    } catch { return false; }
  }

  isAdmin(): boolean { return this.getCurrentUser()?.role === 'admin'; }

  updateProfile(data: Partial<User>): Observable<any> {
    return this.http.patch(`${this.api}/profile`, data);
  }
}
```

---

### Step 8 — Token interceptor (`src/app/core/interceptors/token.interceptor.ts`)

> Angular 21: interceptors are functions, not classes.

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();
  if (!token) return next(req);
  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }));
};
```

---

### Step 9 — Error interceptor (`src/app/core/interceptors/error.interceptor.ts`)

```ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { AuthService } from '../services/auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth  = inject(AuthService);
  const router = inject(Router);
  const snack  = inject(MatSnackBar);

  return next(req).pipe(
    catchError(err => {
      if (err.status === 401) auth.logout();
      if (err.status === 403) {
        router.navigate(['/']);
        snack.open('Access denied', 'Close', { duration: 3000 });
      }
      return throwError(() => err);
    })
  );
};
```

---

### Step 10 — Guards (`src/app/core/guards/`)

`auth.guard.ts`:
```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.isLoggedIn()) return true;
  return inject(Router).createUrlTree(['/auth/login']);
};
```

`admin.guard.ts`:
```ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.isAdmin()) return true;
  return inject(Router).createUrlTree(['/']);
};
```

---

### Step 11 — Wire providers into `app.config.ts`

> Replace the existing file entirely:

```ts
import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { MAT_SNACK_BAR_DEFAULT_OPTIONS } from '@angular/material/snack-bar';
import { routes } from './app.routes';
import { tokenInterceptor } from './core/interceptors/token.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideAnimationsAsync(),
    provideHttpClient(withInterceptors([tokenInterceptor, errorInterceptor])),
    { provide: MAT_SNACK_BAR_DEFAULT_OPTIONS, useValue: { duration: 3000 } },
  ],
};
```

---

### Step 12 — Routes (`app.routes.ts`)

```ts
import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  { path: '', redirectTo: 'books', pathMatch: 'full' },
  {
    path: 'auth',
    children: [
      { path: 'login',    loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent) },
      { path: 'register', loadComponent: () => import('./features/auth/register/register.component').then(m => m.RegisterComponent) },
      { path: 'profile',  loadComponent: () => import('./features/auth/profile/profile.component').then(m => m.ProfileComponent), canActivate: [authGuard] },
    ]
  },
  // Teammates add their routes below:
  // { path: 'books',  loadComponent: ... }
  // { path: 'cart',   loadComponent: ..., canActivate: [authGuard] }
  // { path: 'orders', loadComponent: ..., canActivate: [authGuard] }
  // { path: 'admin',  loadComponent: ..., canActivate: [adminGuard] }
  { path: '**', loadComponent: () => import('./features/not-found/not-found.component').then(m => m.NotFoundComponent) },
];
```

---

### Step 13 — Generate components

```bash
ng generate component features/auth/login    --standalone --skip-tests
ng generate component features/auth/register --standalone --skip-tests
ng generate component features/auth/profile  --standalone --skip-tests
ng generate component features/not-found     --standalone --skip-tests
```

---

### Step 14 — Login component

`features/auth/login/login.component.ts`:
```ts
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink,
    MatFormFieldModule, MatInputModule, MatButtonModule,
    MatProgressSpinnerModule, MatCardModule],
  templateUrl: './login.component.html',
})
export class LoginComponent {
  private fb     = inject(FormBuilder);
  private auth   = inject(AuthService);
  private router = inject(Router);

  loading     = signal(false);
  serverError = signal('');

  form = this.fb.group({
    email:    ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
  });

  submit() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.serverError.set('');
    this.form.disable();

    this.auth.login(this.form.value.email!, this.form.value.password!).subscribe({
      next: () => this.router.navigate(['/books']),
      error: (err) => {
        this.serverError.set(err.error?.message || 'Login failed');
        this.loading.set(false);
        this.form.enable();
      },
    });
  }
}
```

`login.component.html`:
```html
<div class="auth-wrap">
  <mat-card>
    <mat-card-header><mat-card-title>Sign In</mat-card-title></mat-card-header>
    <mat-card-content>
      <form [formGroup]="form" (ngSubmit)="submit()">

        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="email" />
          @if (form.get('email')?.hasError('required') && form.get('email')?.touched) {
            <mat-error>Email is required</mat-error>
          }
          @if (form.get('email')?.hasError('email')) {
            <mat-error>Enter a valid email</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Password</mat-label>
          <input matInput type="password" formControlName="password" />
          @if (form.get('password')?.hasError('required') && form.get('password')?.touched) {
            <mat-error>Password is required</mat-error>
          }
        </mat-form-field>

        @if (serverError()) {
          <p style="color: var(--warn, red); font-size: 13px">{{ serverError() }}</p>
        }

        <button mat-raised-button color="primary" type="submit"
                class="full-width" [disabled]="loading()">
          @if (loading()) { <mat-spinner diameter="20" /> }
          @else { Sign In }
        </button>

      </form>
    </mat-card-content>
    <mat-card-actions>
      <a routerLink="/auth/register">No account? Register</a>
    </mat-card-actions>
  </mat-card>
</div>
```

---

### Step 15 — Commit

```bash
git add .
git commit -m "feat: Angular core — models, AuthService, interceptors, guards, Login, Register routes"
git push origin dev
```

---
---

# 📅 DAY 4 — Profile Page + Register + Auth Polish

---

### Profile component (`features/auth/profile/profile.component.ts`)

```ts
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatCardModule } from '@angular/material/card';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule,
    MatFormFieldModule, MatInputModule, MatButtonModule,
    MatProgressSpinnerModule, MatCardModule],
  templateUrl: './profile.component.html',
})
export class ProfileComponent implements OnInit {
  private fb    = inject(FormBuilder);
  private auth  = inject(AuthService);
  private snack = inject(MatSnackBar);

  loading = signal(false);
  email   = signal('');
  form!: ReturnType<typeof this.fb.group>;

  ngOnInit() {
    const user = this.auth.getCurrentUser(); // decode token — no API call
    this.email.set(user?.email ?? '');
    this.form = this.fb.group({
      firstName: [user?.firstName ?? '', [Validators.required, Validators.minLength(2)]],
      lastName:  [user?.lastName  ?? '', [Validators.required, Validators.minLength(2)]],
      dob:       [user?.dob       ?? '', Validators.required],
    });
  }

  submit() {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.form.disable();
    this.auth.updateProfile(this.form.value).subscribe({
      next: () => {
        this.snack.open('Profile updated!', 'Close');
        this.loading.set(false);
        this.form.enable();
      },
      error: (err) => {
        this.snack.open(err.error?.message || 'Update failed', 'Close');
        this.loading.set(false);
        this.form.enable();
      },
    });
  }
}
```

### Auth polish checklist for Day 4
- [ ] Every field on Login has `mat-error` with a message
- [ ] Every field on Register has `mat-error` with a message
- [ ] Submit button shows `<mat-spinner>` and is `[disabled]="loading()"` on all forms
- [ ] Form is `.disable()`d while request is in flight so user can't edit mid-request

---
---

# 📅 DAY 5 — Spot Check Integration

> Your own wiring is done. Spend this day checking teammates' pages.

### DevTools checklist (Network tab)
- [ ] Cart, Orders, Profile, Admin — all requests have `Authorization: Bearer <token>`
- [ ] Home, Books list, Login, Register — no Authorization header
- [ ] Delete token from localStorage, refresh a protected page → redirected to login
- [ ] Login as regular user, go to `/admin` → redirect to home, no crash
- [ ] Trigger a 401 (expire the token) → auto logout

### Dark mode toggle — give this to Person 3 for the navbar
```ts
toggleDark() {
  document.body.classList.toggle('dark-mode');
}
```

---
---

# 📅 DAY 6 — Integration Testing

Your personal test list:
- [ ] Register → 201 → redirected to login
- [ ] Same email → "Email already in use" in form (not a snackbar)
- [ ] Weak password → validation message under the field
- [ ] Login → token in localStorage → land on `/books`
- [ ] Wrong password → "Invalid credentials" under the form
- [ ] Profile page pre-fills from token (no extra API call on load)
- [ ] Update profile → success snackbar
- [ ] Logout → token cleared → `/orders` redirects to `/auth/login`
- [ ] Admin account → Admin Panel link visible in navbar
- [ ] `isAdmin()` returns true for admin, false for regular user

---
---

# 📅 DAY 7 — Error Polish + 404 Page + Backend README

### Error rule — apply everywhere in your code
```ts
error: (err) => {
  this.snack.open(err.error?.message || 'Something went wrong', 'Close');
  this.loading.set(false);
  this.form.enable();
}
```

### 404 component (`features/not-found/not-found.component.html`)
```html
<div style="text-align:center; padding: 80px 20px">
  <h1 style="font-size: 72px; margin:0; color: var(--primary)">404</h1>
  <p style="color: var(--text-muted)">Page not found</p>
  <a mat-raised-button color="primary" routerLink="/books">Back to Books</a>
</div>
```

The wildcard `**` route is already in `app.routes.ts` from Day 3 — nothing to add.

### Commit
```bash
git add .
git commit -m "feat: 404 page, error polish, backend README"
git push origin dev
```

---
---

# 📅 DAY 8 — Final Checks

```bash
# Check for stray console.logs
grep -r "console.log" src/

# Linters
npm run lint   # backend
ng lint        # frontend
```

Live deployment checklist:
- [ ] Full auth flow works on deployed URLs (not localhost)
- [ ] No `.env` in GitHub — check the repo page directly
- [ ] README setup instructions work from a fresh clone
- [ ] No `console.log` in production code
- [ ] All routes return correct status codes

---

## ✅ Complete Deliverables

| Item | Notes |
|---|---|
| `errorHandler`, `authenticate`, `authorize` | Express 5 compatible |
| Complete auth API | register, login, logout, getMe, updateProfile |
| No try/catch in controllers | Express 5 handles async throws |
| All TypeScript interfaces | Shared — team imports from `core/models` |
| `AuthService` | JWT decoded locally, no extra API calls |
| `tokenInterceptor` + `errorInterceptor` | Functional style — Angular 21 |
| `authGuard` + `adminGuard` | Functional style — Angular 21 |
| Providers in `app.config.ts` | No NgModule anywhere |
| Login + Register + Profile | Standalone, signals, `@if` syntax |
| Classic Ivory theme + dark mode | In `styles.css` via CSS variables |
| 404 page + wildcard route | Already wired in `app.routes.ts` |
