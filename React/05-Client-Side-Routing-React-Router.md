# File: 05-Client-Side-Routing-React-Router.md

> **المتطلبات:** [[01-React-Anatomy-and-JSX]] و [[02-State-Machines-useState-useReducer]] و [[04-The-Escape-Hatch-useEffect-useRef]] — لازم تعرف إزاي الـ components بتتبني وإزاي الـ state بتشتغل قبل ما تبدأ هنا. الـ routing هو اللي بيحوّل مجموعة components لتطبيق حقيقي.

---

## البداية — المشكلة الأصلية: الويب اتبنى على صفحات

الويب من أول يوم اتصمّم على فكرة واحدة بسيطة:

```
User clicks a link → Browser sends request to server → Server returns a NEW HTML page → Browser loads it
```

كل link = رحلة جديدة للـ server. كل page = ملف HTML منفصل. ده اللي بيتسمى **Multi-Page Application (MPA)**.

```
www.shop.com/           → server returns: index.html
www.shop.com/products   → server returns: products.html
www.shop.com/cart       → server returns: cart.html
www.shop.com/profile    → server returns: profile.html
```

وده كان شغّال تمام لمدة سنين. بس فيه مشكلة ظهرت لما التطبيقات اتعقّدت:

```
User is on /products → clicks "Add to Cart"
                      → full page reload to /cart
                      → loses scroll position
                      → loses any in-memory state
                      → spinner, white flash, jarring experience
                      → has to re-download the entire page shell (navbar, footer, styles)
                      → all that just to update a cart icon number
```

الـ overhead ده كان مقبول لما المواقع كانت بسيطة. بس لما بنبني Gmail أو Figma أو Notion — ده مش مقبول خالص.

الحل اللي ظهر كان ثوري:

> **بدل ما الـ server يبعت page جديدة — خلّي الـ browser نفسه يتحكم في الـ navigation من غير ما يروح للـ server خالص.**

وده بالظبط اللي بيسمّوه **Client-Side Routing**.

---

## Client-Side Routing — إزاي بيشتغل بالظبط؟

الـ browser عنده API اسمها **History API** — بتخلّيك تغيّر الـ URL في الـ address bar من غير ما تعمل request للـ server:

```javascript
// Native Browser History API — no page reload
window.history.pushState({}, '', '/products');
// URL changes to: www.yourapp.com/products
// But: NO request sent to server, NO page reload, DOM stays intact
```

React Router بتبني فوق الـ API دي وبتضيف طبقة اسمها **Route Matching** — يعني لما الـ URL يبقى `/products` تعرض `<ProductsPage />`، ولما يبقى `/cart` تعرض `<CartPage />` — كل ده من غير ما تسيب الصفحة.

```
URL changes (client-side only)
         ↓
React Router sees the new URL
         ↓
Matches it against your route definitions
         ↓
Renders the matching component
         ↓
User sees the "new page" — but it's actually a component swap
```

---

## التنصيب

```bash
npm install react-router-dom
```

> **ملاحظة:** دايماً `react-router-dom` للـ web projects — مش `react-router` لوحده. الـ `dom` version هي اللي فيها الـ browser-specific stuff زي `<Link>` وـ `<BrowserRouter>`.

---

## [[BrowserRouter]] — "العمود الفقري"

أول حاجة لازم تعملها: لفّ تطبيقك بالكامل في `<BrowserRouter>`. ده هو اللي بيدي كل الـ components بتاعتك access للـ routing context.

```jsx
// main.jsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom'; // [1] Import the provider
import App from './App';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter> {/* [2] Wrap the entire app */}
      <App />
    </BrowserRouter>
  </StrictMode>
);
```

من الـ `<BrowserRouter>` للأسفل — كل component في شجرتك يقدر يستخدم أي hook أو component من React Router.

---

## [[Routes-and-Route]] — "خريطة التطبيق"

### الـ Anatomy

```jsx
import { Routes, Route } from 'react-router-dom';

<Routes>
  {/* [1] Routes is the container — like a switch statement */}
  {/* It renders only the FIRST route that matches the current URL */}

  <Route path="/" element={<HomePage />} />
  {/* path → the URL segment to match */}
  {/* element → the component to render when it matches */}

  <Route path="/products" element={<ProductsPage />} />
  <Route path="/products/:id" element={<ProductDetailPage />} />
  {/* :id → a URL parameter — dynamic segment */}

  <Route path="*" element={<NotFoundPage />} />
  {/* * → wildcard — matches anything that didn't match above */}
</Routes>
```

---

### مثال عملي — بنية تطبيق كامل

```jsx
// App.jsx
import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import HomePage from './pages/HomePage';
import ProductsPage from './pages/ProductsPage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';
import ProfilePage from './pages/ProfilePage';
import NotFoundPage from './pages/NotFoundPage';

function App() {
  return (
    <div>
      {/* Navbar renders on EVERY page — it's outside <Routes> */}
      <Navbar />

      <main>
        <Routes>
          <Route path="/"           element={<HomePage />} />
          <Route path="/products"   element={<ProductsPage />} />
          <Route path="/products/:id" element={<ProductDetailPage />} />
          <Route path="/cart"       element={<CartPage />} />
          <Route path="/profile"    element={<ProfilePage />} />
          <Route path="*"           element={<NotFoundPage />} />
        </Routes>
      </main>
    </div>
  );
}
```

`<Routes>` بيشتغل زي الـ `switch` statement — بيشوف الـ URL الحالي، بيجرّب كل `<Route>` من فوق لتحت، وبيـ render أول واحد match. لو ما matchش حاجة — الـ `path="*"` بيمسك الكل.

---

## [[Link-and-NavLink]] — "الروابط اللي مابتعملش reload"

### `<Link>` — بديل الـ `<a>` العادي

```jsx
// ❌ WRONG — Regular anchor tag causes a full page reload
<a href="/products">Products</a>

// ✅ CORRECT — Link handles navigation client-side
import { Link } from 'react-router-dom';
<Link to="/products">Products</Link>
```

`<Link>` بيتعرض كـ `<a>` في الـ DOM (للـ accessibility والـ SEO)، بس بتمنع الـ default browser behavior (الـ request للـ server) وبتستخدم History API بدلها.

---

### `<NavLink>` — Link ذكي بيعرف هو active ولا لا

```jsx
import { NavLink } from 'react-router-dom';

// NavLink automatically adds an "active" class when its path matches the URL
<NavLink
  to="/products"
  className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}
>
  Products
</NavLink>

// Or with style
<NavLink
  to="/products"
  style={({ isActive }) => ({
    fontWeight: isActive ? 'bold' : 'normal',
    color: isActive ? '#0070f3' : '#333',
  })}
>
  Products
</NavLink>
```

`NavLink` بيدّيك function في الـ `className` و `style` props — الـ function بتاخد `{ isActive }` وبترجع اللي عايزه. React Router بيحسب الـ `isActive` تلقائياً بناءً على الـ URL الحالي.

### Navbar كاملة باستخدام NavLink:

```jsx
// components/Navbar.jsx
import { NavLink } from 'react-router-dom';
import './Navbar.css';

const links = [
  { to: '/',         label: 'Home' },
  { to: '/products', label: 'Products' },
  { to: '/cart',     label: 'Cart' },
  { to: '/profile',  label: 'Profile' },
];

function Navbar() {
  return (
    <nav className="navbar">
      <span className="logo">MyShop</span>
      <ul className="nav-links">
        {links.map(({ to, label }) => (
          <li key={to}>
            <NavLink
              to={to}
              className={({ isActive }) =>
                ['nav-link', isActive ? 'nav-link--active' : ''].join(' ')
              }
            >
              {label}
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  );
}
```

---

## [[URL-Parameters]] — "الـ Dynamic Segments"

### `useParams` — اقرأ الـ :id من الـ URL

```
Route definition: /products/:id
User visits:      /products/42
                  /products/abc-sneakers
                  /products/iphone-15-pro
```

```jsx
// pages/ProductDetailPage.jsx
import { useParams } from 'react-router-dom';
import { useState, useEffect } from 'react';

function ProductDetailPage() {
  // useParams returns an object with all URL parameters
  const { id } = useParams();
  // If URL is /products/42  → id = "42"  (always a string)
  // If URL is /products/abc → id = "abc"

  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();

    fetch(`/api/products/${id}`, { signal: controller.signal })
      .then(res => res.json())
      .then(data => {
        setProduct(data);
        setLoading(false);
      })
      .catch(err => {
        if (err.name !== 'AbortError') setLoading(false);
      });

    return () => controller.abort();
  }, [id]); // Re-fetch when id changes (user navigates between products)

  if (loading) return <p>Loading product...</p>;
  if (!product) return <p>Product not found.</p>;

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>${product.price}</span>
    </div>
  );
}
```

---

### Multiple Parameters

```jsx
// Route: /categories/:categoryId/products/:productId
const { categoryId, productId } = useParams();
```

---

## [[Query-Parameters]] — "الـ ?search=... و ?page=2"

الـ URL parameters (`/products/:id`) مناسبة للـ resource identity — يعني "أنهو product".
الـ Query parameters (`?page=2&sort=price`) مناسبة للـ UI state — يعني "عرض الصفحة دي بالـ settings دي".

```jsx
import { useSearchParams } from 'react-router-dom';

function ProductsPage() {
  // useSearchParams works like useState but synced with the URL query string
  const [searchParams, setSearchParams] = useSearchParams();

  // Reading query params
  const page     = Number(searchParams.get('page'))  || 1;   // ?page=2   → 2
  const sort     = searchParams.get('sort')          || 'name'; // ?sort=price → "price"
  const category = searchParams.get('category')      || '';

  function handlePageChange(newPage) {
    // Updates URL to ?page=3 without reloading the page
    setSearchParams(prev => {
      prev.set('page', newPage);
      return prev; // Keep existing params, just update page
    });
  }

  function handleSortChange(newSort) {
    setSearchParams(prev => {
      prev.set('sort', newSort);
      prev.set('page', 1); // Reset to page 1 when sort changes
      return prev;
    });
  }

  return (
    <div>
      <div className="controls">
        <select value={sort} onChange={e => handleSortChange(e.target.value)}>
          <option value="name">Sort by Name</option>
          <option value="price">Sort by Price</option>
          <option value="rating">Sort by Rating</option>
        </select>
      </div>

      {/* Products list here */}

      <div className="pagination">
        <button onClick={() => handlePageChange(page - 1)} disabled={page <= 1}>
          Previous
        </button>
        <span>Page {page}</span>
        <button onClick={() => handlePageChange(page + 1)}>
          Next
        </button>
      </div>
    </div>
  );
}
```

الفايدة الضخمة هنا: لما المستخدم يعمل **refresh** أو يشارك الـ URL مع حد تاني — هيلاقي نفس الصفحة ونفس الـ sort. الـ UI state بقت **shareable و bookmarkable**.

---

## [[Nested-Routes]] — "الـ Layouts وتداخل الصفحات"

ده أقوى concept في React Router v6 وأقل حد بيفهمه صح في الأول.

**المشكلة:** عندك dashboard فيه sidebar ثابتة — بس المحتوى الجوّه بيتغير:

```
/dashboard             → shows overview
/dashboard/analytics   → shows analytics (sidebar still there)
/dashboard/settings    → shows settings   (sidebar still there)
/dashboard/users       → shows users      (sidebar still there)
```

الـ sidebar مش لازم تتدمّر وتتعيد بناء في كل navigate. لازم تفضل كده والمحتوى الجوّه بس اللي بيتغير.

### الـ `<Outlet />` — فتحة التلقيم

```jsx
// [1] Define nested routes in your route config
<Routes>
  <Route path="/dashboard" element={<DashboardLayout />}>
    {/* These are NESTED inside DashboardLayout */}
    <Route index element={<DashboardOverview />} />
    {/* "index" → renders when URL is exactly /dashboard */}

    <Route path="analytics" element={<AnalyticsPage />} />
    {/* Renders when URL is /dashboard/analytics */}

    <Route path="settings"  element={<SettingsPage />} />
    <Route path="users"     element={<UsersPage />} />
  </Route>
</Routes>
```

```jsx
// [2] DashboardLayout.jsx — the parent layout component
import { Outlet, NavLink } from 'react-router-dom';

function DashboardLayout() {
  return (
    <div className="dashboard">
      <aside className="sidebar">
        {/* Sidebar never re-mounts — it's part of the layout */}
        <NavLink to="/dashboard">Overview</NavLink>
        <NavLink to="/dashboard/analytics">Analytics</NavLink>
        <NavLink to="/dashboard/settings">Settings</NavLink>
        <NavLink to="/dashboard/users">Users</NavLink>
      </aside>

      <main className="content">
        {/* THIS is where the nested route's component renders */}
        <Outlet />
        {/*
          When URL is /dashboard           → <DashboardOverview /> renders here
          When URL is /dashboard/analytics → <AnalyticsPage />     renders here
          When URL is /dashboard/settings  → <SettingsPage />      renders here
        */}
      </main>
    </div>
  );
}
```

الـ `<Outlet />` هو الـ "فتحة" — زي placeholder بيقول: "الـ child route يتعرض هنا." الـ `DashboardLayout` نفسه مابيتـ re-mountش — بس الـ Outlet content بيتغير.

---

### Root Layout — تطبيق الكونسبت على الكل

```jsx
// App.jsx — A cleaner architecture using layouts
import { Routes, Route } from 'react-router-dom';
import RootLayout from './layouts/RootLayout';
import DashboardLayout from './layouts/DashboardLayout';

function App() {
  return (
    <Routes>
      {/* Root layout wraps everything — renders Navbar and Footer */}
      <Route element={<RootLayout />}>

        <Route path="/"         element={<HomePage />} />
        <Route path="/products" element={<ProductsPage />} />
        <Route path="/products/:id" element={<ProductDetailPage />} />
        <Route path="/cart"     element={<CartPage />} />

        {/* Dashboard has its OWN nested layout */}
        <Route path="/dashboard" element={<DashboardLayout />}>
          <Route index            element={<DashboardOverview />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="settings"  element={<SettingsPage />} />
        </Route>

        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  );
}
```

```jsx
// layouts/RootLayout.jsx
import { Outlet } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

function RootLayout() {
  return (
    <>
      <Navbar />    {/* Always visible */}
      <Outlet />    {/* Page content changes here */}
      <Footer />    {/* Always visible */}
    </>
  );
}
```

---

## [[Programmatic-Navigation]] — "الـ Navigation من الكود"

أحياناً مش عايز تنتظر المستخدم يضغط link — عايز تعمل navigate بعد event معين. مثلاً: بعد login ناجح، بعد submit form، أو بعد حذف item.

### `useNavigate` — الـ Hook للـ Programmatic Navigation

```jsx
import { useNavigate } from 'react-router-dom';

function LoginForm() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);

    const formData = new FormData(e.target);
    const credentials = {
      email:    formData.get('email'),
      password: formData.get('password'),
    };

    try {
      await loginUser(credentials); // API call
      navigate('/dashboard');        // Redirect on success
    } catch (error) {
      console.error('Login failed:', error);
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email"    type="email"    required />
      <input name="password" type="password" required />
      <button type="submit" disabled={loading}>
        {loading ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  );
}
```

### `navigate()` Options

```jsx
const navigate = useNavigate();

// Navigate to a path
navigate('/dashboard');

// Navigate with state (passed to the next page, not in URL)
navigate('/dashboard', { state: { from: 'login', welcomeBack: true } });

// Replace current history entry (no "back" button to previous page)
navigate('/dashboard', { replace: true });
// Useful after login — you don't want "back" to go to the login page

// Go back (like pressing the browser's back button)
navigate(-1);

// Go forward
navigate(1);

// Go back 2 steps
navigate(-2);
```

---

### `useLocation` — "أنا فين دلوقتي؟"

```jsx
import { useLocation } from 'react-router-dom';

function SomePage() {
  const location = useLocation();
  // location = {
  //   pathname: '/products',          — the URL path
  //   search:   '?page=2&sort=price', — query string
  //   hash:     '#section-3',         — hash fragment
  //   state:    { from: 'login' },    — state passed via navigate()
  //   key:      'abc123'              — unique key for this history entry
  // }

  // Common use case: redirect back after login
  const from = location.state?.from || '/dashboard';

  return <div>...</div>;
}
```

### حالة الاستخدام الكلاسيكية — Redirect After Login

```jsx
// ProtectedRoute redirects to /login, passing current location as state
function ProtectedRoute({ children }) {
  const isLoggedIn = useAuthStore(state => state.isLoggedIn);
  const location   = useLocation();

  if (!isLoggedIn) {
    // Pass current location so we can redirect back after login
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  return children;
}

// LoginPage reads the state and navigates back
function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const from     = location.state?.from || '/dashboard';

  async function handleLogin() {
    await loginUser(credentials);
    navigate(from, { replace: true }); // Goes back to where user was
  }
}
```

---

## [[Protected-Routes]] — "صفحات وراء Login"

ده pattern أساسي في أي تطبيق حقيقي.

```jsx
// components/ProtectedRoute.jsx
import { Navigate, useLocation } from 'react-router-dom';

function ProtectedRoute({ children }) {
  // Read auth state from wherever you store it (Context, Zustand, etc.)
  const isLoggedIn = useAuth(); // your custom hook
  const location   = useLocation();

  if (!isLoggedIn) {
    // Redirect to login, but remember where the user was trying to go
    return (
      <Navigate
        to="/login"
        state={{ from: location.pathname }}
        replace // Don't add /login to history — replace current entry
      />
    );
  }

  // User is authenticated — render the actual page
  return children;
}
```

```jsx
// App.jsx — Protecting routes
<Routes>
  <Route path="/login"    element={<LoginPage />} />
  <Route path="/register" element={<RegisterPage />} />

  {/* Public routes */}
  <Route path="/"         element={<HomePage />} />
  <Route path="/products" element={<ProductsPage />} />

  {/* Protected routes — require authentication */}
  <Route
    path="/dashboard"
    element={
      <ProtectedRoute>
        <DashboardLayout />
      </ProtectedRoute>
    }
  >
    <Route index            element={<DashboardOverview />} />
    <Route path="settings"  element={<SettingsPage />} />
  </Route>

  <Route
    path="/profile"
    element={
      <ProtectedRoute>
        <ProfilePage />
      </ProtectedRoute>
    }
  />
</Routes>
```

---

## [[Lazy-Loading-Routes]] — "لا تحمّل صفحات ما المستخدم ماطلبهاش"

بدون lazy loading — كل الـ code بتاع كل الصفحات بيتحمّل في البداية، حتى لو المستخدم مش هيزور 80% منهم.

```
Without lazy loading:
User opens / (home page)
Browser downloads: HomePage + ProductsPage + CartPage + DashboardPage + ...ALL pages
Total bundle: ~500KB — user pays for code they might never see
```

```jsx
// App.jsx — With lazy loading
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

// [1] Replace static imports with lazy imports
// lazy() takes a function that returns a dynamic import()
const HomePage          = lazy(() => import('./pages/HomePage'));
const ProductsPage      = lazy(() => import('./pages/ProductsPage'));
const ProductDetailPage = lazy(() => import('./pages/ProductDetailPage'));
const DashboardPage     = lazy(() => import('./pages/DashboardPage'));
const ProfilePage       = lazy(() => import('./pages/ProfilePage'));

function App() {
  return (
    // [2] Wrap Routes in Suspense — shows fallback while the chunk loads
    <Suspense fallback={<div className="page-loader">Loading...</div>}>
      <Routes>
        <Route path="/"             element={<HomePage />} />
        <Route path="/products"     element={<ProductsPage />} />
        <Route path="/products/:id" element={<ProductDetailPage />} />
        <Route path="/dashboard"    element={<DashboardPage />} />
        <Route path="/profile"      element={<ProfilePage />} />
      </Routes>
    </Suspense>
  );
}
```

```
With lazy loading:
User opens / (home page)
Browser downloads: HomePage chunk only (~50KB) — fast initial load
User navigates to /products
Browser downloads: ProductsPage chunk (~80KB) — on demand
```

---

## Old Way ❌ vs Modern Way ✅ — المقارنة الكاملة

### سيناريو 1: النقل بين الصفحات

```jsx
// ❌ OLD WAY — Full page reload (traditional HTML anchor)
<a href="/products">Go to Products</a>
// Sends HTTP request to server
// Downloads new HTML page
// Re-parses and re-renders everything
// Loses all in-memory state

// ❌ ALSO WRONG — React Router v5 used <Switch> instead of <Routes>
import { Switch, Route } from 'react-router-dom'; // v5 API — don't use
<Switch>
  <Route exact path="/" component={HomePage} />   // "component" prop — v5 only
  <Route path="/products" component={ProductsPage} />
</Switch>
```

```jsx
// ✅ MODERN WAY — React Router v6 + client-side navigation
import { Routes, Route, Link } from 'react-router-dom';

<Link to="/products">Go to Products</Link>
// Intercepts the click, uses History API
// No request to server, no reload
// App state preserved

<Routes>
  <Route path="/"         element={<HomePage />} />     // "element" prop — v6
  <Route path="/products" element={<ProductsPage />} />
</Routes>
```

### سيناريو 2: Navigation بعد Action

```jsx
// ❌ OLD WAY — window.location causes full reload
async function handleLogin() {
  await loginUser(credentials);
  window.location.href = '/dashboard'; // Full reload — loses everything
}
```

```jsx
// ✅ MODERN WAY — useNavigate for client-side redirect
import { useNavigate } from 'react-router-dom';

function LoginForm() {
  const navigate = useNavigate();

  async function handleLogin() {
    await loginUser(credentials);
    navigate('/dashboard', { replace: true }); // Soft navigation, no reload
  }
}
```

### سيناريو 3: الـ Layouts

```jsx
// ❌ OLD WAY — Duplicating Navbar in every page (React Router v5 mindset)
function HomePage()     { return <><Navbar /><HomeContent /></>; }
function ProductsPage() { return <><Navbar /><ProductsContent /></>; }
function CartPage()     { return <><Navbar /><CartContent /></>; }
// Navbar re-mounts on every navigation — defeats the purpose of SPA
```

```jsx
// ✅ MODERN WAY — Nested routes with Outlet
// Navbar mounts ONCE and stays alive through all navigation
<Route element={<RootLayout />}> {/* Layout: Navbar + Outlet + Footer */}
  <Route path="/"         element={<HomePage />} />
  <Route path="/products" element={<ProductsPage />} />
  <Route path="/cart"     element={<CartPage />} />
</Route>
```

---

## الصورة الكاملة — Architecture بتاع الـ Routing

```
main.jsx
└── <BrowserRouter>              ← Connects app to browser History API
    └── <App />
        └── <Routes>             ← The route matcher
            ├── <Route element={<RootLayout />}>   ← Persistent shell
            │   │   <Navbar />                     ← Never remounts
            │   │   <Outlet />                     ← Page content goes here
            │   │   <Footer />                     ← Never remounts
            │   │
            │   ├── <Route path="/" element={<HomePage />} />
            │   ├── <Route path="/products" element={<ProductsPage />} />
            │   ├── <Route path="/products/:id" element={<ProductDetail />} />
            │   │
            │   └── <Route path="/dashboard" element={<DashboardLayout />}>
            │           <Sidebar />               ← Never remounts inside dashboard
            │           <Outlet />                ← Dashboard content goes here
            │           │
            │           ├── <Route index element={<Overview />} />
            │           ├── <Route path="analytics" element={<Analytics />} />
            │           └── <Route path="settings" element={<Settings />} />
            │
            └── <Route path="*" element={<NotFoundPage />} />
```

---

## 🫒 زتونة الإنترفيو

> **React Router v6 implements client-side routing by intercepting browser navigation events and leveraging the History API (`pushState`/`replaceState`) to mutate the URL without issuing an HTTP request, then diffing the new URL against a declarative route tree to decide which component to render. The core primitives are: `<BrowserRouter>` (the context provider that connects React to the browser's history stack), `<Routes>` (the matcher — renders only the first matching `<Route>`), and `<Route>` (declares a path-to-component mapping via the `element` prop, replacing v5's `component` prop). URL parameters (`:id`) are accessed via `useParams()`, query strings via `useSearchParams()` (which behaves like `useState` synchronized to the URL), and programmatic navigation via `useNavigate()`. The most powerful v6 feature is nested routes with `<Outlet />` — a parent route renders a persistent layout shell (Navbar, Sidebar) and declares an `<Outlet />` as a placeholder; child routes render into that outlet without unmounting the parent, enabling zero-flicker layout persistence across navigations. Protected routes are implemented as wrapper components that read auth state and either render `children` or return `<Navigate replace />` to the login page — passing the attempted path via location state for post-login redirect. Finally, lazy loading via `React.lazy()` combined with `<Suspense>` splits the bundle per-route, ensuring users download only the code for pages they actually visit.**

---

## ✅ Checkpoint — اختبر فهمك

| السؤال | الإجابة المتوقعة |
|---|---|
| إيه الفرق بين `<BrowserRouter>` وـ `<HashRouter>`؟ | `BrowserRouter` بيستخدم History API (`/products`). `HashRouter` بيستخدم الـ hash (`/#/products`) — للـ static hosts اللي مش بتدعم URL rewriting. |
| إيه الـ `<Outlet />`  وامتى بيتستخدم؟ | Placeholder في الـ parent layout بيـ render فيه الـ child route component. بيتستخدم مع nested routes عشان تعمل layouts ثابتة. |
| إيه الفرق بين `useParams` وـ `useSearchParams`؟ | `useParams` بيقرأ الـ dynamic segments من الـ path (`/products/:id`). `useSearchParams` بيقرأ ويعدّل الـ query string (`?page=2`). |
| إيه الفرق بين `navigate('/x')` وـ `navigate('/x', { replace: true })`؟ | الأولى بتضيف entry جديدة في الـ history stack (back button يرجع). الثانية بتعوّض الـ entry الحالية — مناسبة بعد login. |
| إيه الـ `index` route؟ | الـ child route اللي بيتعرض لما الـ parent path بالظبط يتطابق. مثلاً `<Route index element={<Overview />}>` يتعرض عند `/dashboard`. |
| ليه بنستخدم `<Link>` بدل `<a>`؟ | `<a>` بيعمل full page reload (HTTP request للـ server). `<Link>` بيعمل client-side navigation من غير reload مع الحفاظ على الـ app state. |
| إيه الـ stale navigation bug وازاي بيحصل؟ | لو استخدمت `window.location.href` بدل `navigate()` — هيعمل full reload ويخسر الـ React state كله. |
| إيه `lazy()` وامتى بنستخدمه في الـ routing؟ | بيخلّي React تحمّل الـ component code on-demand (code splitting). بنستخدمه مع الـ routes عشان نقلّل الـ initial bundle size. |

---

## 🛠️ Practical Lab

### Task 1 — اقرأ وتوقع

اقرأ الكود ده وجاوب على الأسئلة:

```jsx
// App.jsx
function App() {
  return (
    <Routes>
      <Route element={<RootLayout />}>
        <Route path="/"    element={<HomePage />} />
        <Route path="/blog" element={<BlogLayout />}>
          <Route index         element={<BlogListPage />} />
          <Route path=":slug"  element={<BlogPostPage />} />
        </Route>
        <Route
          path="/write"
          element={
            <ProtectedRoute>
              <WritePostPage />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  );
}
```

**الأسئلة:**
1. المستخدم فتح `/blog` — أنهو components بتتعرض؟ بالترتيب من بره لجوّه.
2. المستخدم فتح `/blog/how-to-use-react` — إيه قيمة `slug` في `BlogPostPage`؟
3. المستخدم غير logged in وحاول يفتح `/write` — إيه اللي هيحصل بالظبط؟
4. المستخدم فتح `/contact` — أنهو component يتعرض؟

---

### Task 2 — Fix the Bugs

الكود ده فيه 4 bugs. حددهم وصلّحهم:

```jsx
// BUGGY CODE — Find all 4 bugs

// Bug 1
import { Switch, Route } from 'react-router-dom';

function App() {
  return (
    // Bug 2
    <Switch>
      <Route path="/products" element={<ProductsPage />} />
      <Route path="/products/:id" element={<ProductDetailPage />} />
      <Route path="/" element={<HomePage />} />
    </Switch>
  );
}

// Bug 3 — in Navbar
function Navbar() {
  return (
    <nav>
      <a href="/products">Products</a>
      <a href="/cart">Cart</a>
    </nav>
  );
}

// Bug 4 — in LoginPage
function LoginPage() {
  async function handleLogin() {
    await loginUser();
    window.location.href = '/dashboard'; // Bug 4
  }
  return <button onClick={handleLogin}>Login</button>;
}
```

**الـ Bugs:**
- Bug 1: Import من API قديمة (v5)
- Bug 2: الـ matcher القديم بدل الحديث
- Bug 3: Links بتعمل full page reload
- Bug 4: Navigation بيخسر الـ React state

---

### Task 3 — ابني من الصفر

ابني **تطبيق Blog** كامل بالـ structure التالية:

**الـ Routes:**
```
/                  → HomePage    (list of featured posts)
/blog              → BlogListPage (all posts, with ?page= and ?tag= query params)
/blog/:slug        → BlogPostPage (single post, fetched by slug)
/about             → AboutPage
/login             → LoginPage
/dashboard         → ProtectedRoute → DashboardPage (index: recent posts)
/dashboard/new     → ProtectedRoute → NewPostPage
/dashboard/posts   → ProtectedRoute → ManagePostsPage
*                  → NotFoundPage
```

**المتطلبات:**

```
1. RootLayout: Navbar (NavLink active states) + Outlet + Footer
   Navbar links: Home, Blog, About, Dashboard (if logged in), Login/Logout

2. DashboardLayout: nested — Sidebar + Outlet
   Sidebar links: Overview, New Post, Manage Posts

3. BlogListPage:
   - اقرأ ?page و ?tag من الـ URL
   - اعرض فلتر بالـ tags — لما تضغط tag يحدّث الـ URL
   - Pagination تحت

4. BlogPostPage:
   - اقرأ :slug من الـ URL
   - Fetch post data (use JSONPlaceholder or mock data)
   - لو post مش موجود → redirect لـ /blog

5. ProtectedRoute:
   - لو مش logged in → redirect لـ /login مع state: { from: pathname }
   - LoginPage بعد login تـ navigate لـ location.state.from

6. Lazy load: BlogPostPage و DashboardPage وـ NewPostPage
```

**Bonus:**
- اعمل custom hook اسمه `usePagination(totalItems, itemsPerPage)` بيرجع `{ currentPage, totalPages, goToPage }` ومربوط بالـ URL.

---

> **التالي:** [[06-Form-Architecture-React-Hook-Form-Zod]] — عرفنا نتنقل بين الصفحات بشكل احترافي. دلوقتي ازاي نبني forms جاهزة للـ production مع validation حقيقي — من غير ما نتجنّن في manage كل field بـ useState.
