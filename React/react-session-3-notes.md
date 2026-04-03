# 📘 React Learning Notes
### Session: React Router DOM + Hooks (useEffect, useState, useRef)

---

## 📑 Table of Contents

- [🧠 React Router DOM — What & Why](#-react-router-dom--what--why)
- [🧠 BrowserRouter vs Routes vs Route vs Router](#-browserrouter-vs-routes-vs-route-vs-router)
- [🧠 `<a>` Tag vs `<Link>`](#-a-tag-vs-link)
- [🧠 NavLink — Active Link Styling](#-navlink--active-link-styling)
- [🧠 Nested Routes & `<Outlet />`](#-nested-routes--outlet-)
- [🧠 `useParams`](#-useparams)
- [🧠 `useNavigate`](#-usenavigate)
- [🧠 `useLocation` & `useSearchParams`](#-uselocation--usesearchparams)
- [🧠 HTTP Requests — Axios vs Fetch](#-http-requests--axios-vs-fetch)
- [🧠 `useState` — Local Component State](#-usestate--local-component-state)
- [🧠 `useEffect` — Side Effects & Lifecycle](#-useeffect--side-effects--lifecycle)
- [🧠 `useEffect` Dependency Array — Deep Dive](#-useeffect-dependency-array--deep-dive)
- [🧠 The Infinite Loop Problem — Why `useEffect` Exists for Fetching](#-the-infinite-loop-problem--why-useeffect-exists-for-fetching)
- [🧠 `useRef`](#-useref)
- [🚀 Final Takeaways](#-final-takeaways)

---

## 🧠 React Router DOM — What & Why

### ⚡ Core Idea
A third-party library that syncs your React UI with the browser URL — enabling SPA navigation without server reloads.

### ❓ Problem It Solves
React is a **view library only** — zero URL awareness out of the box. Without a router, you'd manually parse `window.location.pathname` with brittle `if/else` logic to decide what to render.

### 🏗️ Before vs After
- **Before:** URL change → browser sends a new HTTP request → server returns a new HTML page → React app fully unmounts and restarts (all state lost)
- **After:** URL change → React Router intercepts it via the HTML5 History API → swaps only the matching component → state is preserved

### 🔗 Angular vs React
| Feature | Angular | React Router |
|---|---|---|
| Origin | Built-in (`@angular/router`) | 3rd-party (`react-router-dom`) |
| Config style | Centralized TS array | Declarative JSX components |
| Placeholder | `<router-outlet>` | `<Outlet />` / `<Routes>` block |
| Navigate imperatively | `this.router.navigate(['/path'])` | `navigate('/path')` via hook |

### 🧪 Example — Installation & Basic Setup
```bash
npm install react-router-dom
```
```jsx
// main.jsx — wrap at the ROOT so every component can access routing
import { BrowserRouter } from 'react-router-dom';
import { createRoot } from 'react-dom/client';

createRoot(document.getElementById('root')).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
);
```

💡 **Key Insights**
- Placing `<BrowserRouter>` in `main.jsx` (not inside `App`) ensures `App` itself and every global provider can use routing hooks
- React Router v6+ matches the **most specific route** — order of `<Route>` tags inside `<Routes>` no longer matters
- For v6.4+ advanced features (Loaders, Actions), use `createBrowserRouter` + `<RouterProvider>` instead

⚠️ **Common Traps**
- Putting `<BrowserRouter>` inside `App.jsx` means `App` itself can't use `useNavigate`
- Any component using `<Link>`, `useNavigate`, or `useParams` **must** be a descendant of `<BrowserRouter>` — violating this causes an instant context error crash

📚 **From Docs**
- React Router manages the URL and navigation stack; `<BrowserRouter>` uses the browser's native HTML5 History API
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 BrowserRouter vs Routes vs Route vs Router

### ⚡ Core Idea
Three distinct layers with different jobs: the **environment** (`BrowserRouter`), the **switchboard** (`Routes`), and the **destination mapping** (`Route`). `Router` is the raw engine you almost never touch.

### ❓ Problem It Solves
Each abstraction handles one specific responsibility — keeping routing code clean and composable.

### 🏗️ Before vs After
- **Before:** One monolithic router object that mixed URL tracking, matching, and rendering all together (like Angular's `RouterModule`)
- **After:** Each piece is a focused React component with a single job

### 🔗 Angular vs React
| Concept | React | Angular Equivalent |
|---|---|---|
| `<BrowserRouter>` | Wraps the app, wires up HTML5 History API | `RouterModule.forRoot()` |
| `<Routes>` | Intelligent `switch` — picks the best match | Implicit — Angular handles this internally |
| `<Route>` | Maps one URL string to one React element | `{ path: '...', component: ... }` in routes array |
| `<Router>` | Raw base class, requires manual history config | The `Router` injectable service |

### 🧪 Example
```jsx
// App.jsx
import { Routes, Route } from 'react-router-dom';

export default function App() {
  return (
    <div>
      <nav>...</nav>
      <Routes>                                          {/* switchboard */}
        <Route path="/" element={<Home />} />           {/* destination */}
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="*" element={<NotFound />} />       {/* 404 catch-all */}
      </Routes>
    </div>
  );
}
```

💡 **Key Insights**
- `<Routes>` behaves exactly like a `switch(url)` statement — only one `<Route>` renders at a time
- `path="*"` is the catch-all wildcard (equivalent to Angular's `{ path: '**' }`)
- `element={<Home />}` (v6 standard) accepts **instantiated JSX** so you can pass props inline: `element={<Home user="Admin" />`
- Only `<Route>` or `<React.Fragment>` can be **direct children** of `<Routes>` — placing a `<div>` directly inside throws an error

⚠️ **Common Traps**
- Importing `{ Router }` instead of `{ BrowserRouter }` in a web project — crashes immediately because `Router` needs a manually created history object
- Placing a `<div>` or `<nav>` as a direct child of `<Routes>` causes a runtime error

📚 **From Docs**
- `<Routes>` picks the best matching route using a scoring algorithm — the most specific path wins
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 `<a>` Tag vs `<Link>`

### ⚡ Core Idea
`<Link>` intercepts the click and updates the URL via JavaScript. `<a>` triggers a hard browser reload that destroys the entire React app.

### ❓ Problem It Solves
Using a plain `<a>` tag in a SPA completely wipes React's in-memory state (useState, Context, Redux) and causes a visual flash — negating the entire purpose of a SPA.

### 🏗️ Before vs After
- **Before:** `<a href="/dashboard">` → hard reload → React unmounts entirely → all state lost
- **After:** `<Link to="/dashboard">` → `event.preventDefault()` runs silently → URL updates via History API → only the matching `<Routes>` block re-renders

### 🔗 Angular vs React
| Element | Angular | React Router |
|---|---|---|
| SPA navigation | `routerLink="/path"` | `<Link to="/path">` |
| Hard reload | `href="/path"` | `href="/path"` |

### 🧪 Example
```jsx
import { Link } from 'react-router-dom';
import { useState } from 'react';

function Navigation() {
  const [count, setCount] = useState(0);
  return (
    <nav>
      <button onClick={() => setCount(count + 1)}>Clicks: {count}</button>
      <a href="/dashboard">❌ Hard reload — count resets to 0</a>
      <Link to="/dashboard">✅ Client nav — count is preserved</Link>
    </nav>
  );
}
```

💡 **Key Insights**
- `<Link>` renders as a standard `<a>` tag in the final DOM (good for SEO/accessibility) — it just adds an `onClick` that calls `event.preventDefault()`
- Use a plain `<a>` only for **external URLs** (e.g., `href="https://google.com"`) or file downloads

⚠️ **Common Traps**
- Trying to style an "active" link using `<Link>` — it has no awareness of the current URL. Use `<NavLink>` for that

📚 **From Docs**
- `<Link>` renders an accessible `<a>` element with a real `href`, so right-click → "Open in new tab" works correctly
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 NavLink — Active Link Styling

### ⚡ Core Idea
`<NavLink>` is a `<Link>` that knows whether its destination matches the current URL — it exposes an `isActive` boolean for conditional styling.

### ❓ Problem It Solves
Without `<NavLink>`, you'd manually read `window.location.pathname` and compare it to each link's destination just to bold the active tab.

### 🏗️ Before vs After
- **Before:** Manually checking `window.location.pathname === '/dashboard'` to conditionally apply CSS classes
- **After:** `<NavLink>` auto-applies `class="active"` or exposes `isActive` for dynamic class strings

### 🔗 Angular vs React
| Concept | Angular | React Router |
|---|---|---|
| Component | `<a routerLink="/path">` | `<NavLink to="/path">` |
| Active class | `routerLinkActive="my-class"` | Default: `class="active"` or callback |
| Exact match | `[routerLinkActiveOptions]="{exact: true}"` | `<NavLink end>` prop |

### 🧪 Example
```jsx
import { NavLink } from 'react-router-dom';

function Navigation() {
  return (
    <nav>
      {/* Standard CSS: React auto-adds class="active" when URL matches */}
      <NavLink to="/dashboard" className="nav-item">Dashboard</NavLink>

      {/* Tailwind: className accepts a callback exposing isActive */}
      <NavLink
        to="/profile"
        className={({ isActive }) =>
          isActive ? "text-blue-500 font-bold" : "text-gray-500"
        }
      >
        Profile
      </NavLink>

      {/* 'end' forces exact match — prevents '/' from always being active */}
      <NavLink to="/" end>Home</NavLink>
    </nav>
  );
}
```

💡 **Key Insights**
- `<NavLink>` is **not just for top navbars** — use it anywhere the user needs visual feedback: sidebars, tab bars, pagination, multi-step forms
- The `end` prop is the equivalent of Angular's `[routerLinkActiveOptions]="{exact: true}"`
- You can return a custom class name string from the callback to rename `"active"` to anything

⚠️ **Common Traps**
- Using Tailwind's `active:bg-blue-500` — CSS `:active` pseudo-class means "mouse is currently pressed down," NOT "this route is active." You must use the `({ isActive })` callback
- The `/` Home link will always appear active without the `end` prop because `/` is a partial match of every path

📚 **From Docs**
- `<NavLink>` also exposes `isPending` (for transitions) and `isTransitioning` as part of the callback
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 Nested Routes & `<Outlet />`

### ⚡ Core Idea
Nest `<Route>` tags inside each other to share a parent layout. `<Outlet />` is the injection point inside the parent component where the matching child renders.

### ❓ Problem It Solves
Without nesting, you'd have to manually import and render shared layout elements (like a sidebar) inside every single page — duplicating code and remounting the layout on every navigation.

### 🏗️ Before vs After
- **Before:** Every page re-renders the full layout including the sidebar. No shared shell
- **After:** Parent component mounts once (sidebar stays stable). Only the content inside `<Outlet />` swaps when the URL changes

### 🔗 Angular vs React
| Concept | Angular | React Router |
|---|---|---|
| Child route setup | `children: [{ path: 'profile', component: Profile }]` | `<Route path="..."><Route path="profile" .../></Route>` |
| Injection point | `<router-outlet>` in parent template | `<Outlet />` in parent component JSX |
| Default child | `path: ''` (empty string) | `<Route index .../>` prop |

### 🧪 Example
```jsx
// App.jsx — define the hierarchy
import { Routes, Route } from 'react-router-dom';

export default function App() {
  return (
    <Routes>
      <Route path="/dashboard" element={<DashboardLayout />}>
        <Route index element={<h2>Welcome</h2>} />           {/* /dashboard */}
        <Route path="profile" element={<Profile />} />       {/* /dashboard/profile */}
        <Route path="settings" element={<Settings />} />     {/* /dashboard/settings */}
      </Route>
    </Routes>
  );
}

// DashboardLayout.jsx — parent must include <Outlet />
import { Outlet, Link } from 'react-router-dom';

function DashboardLayout() {
  return (
    <div className="flex">
      <aside>
        <Link to="/dashboard/profile">Profile</Link>
        <Link to="/dashboard/settings">Settings</Link>
      </aside>
      <main>
        <Outlet /> {/* child component injects exactly here */}
      </main>
    </div>
  );
}
```

💡 **Key Insights**
- `<Outlet />` renders `null` if on the parent URL with no matching child — unless an `index` route is defined
- Child paths are **relative** — never start them with `/`. Writing `path="/profile"` breaks nesting by treating it as an absolute URL
- The `index` prop is cleaner than `path=""` for the default child — it explicitly signals "render this when the parent URL is matched exactly"
- You can nest infinitely deep; an `<Outlet />` can live inside a component that was itself rendered by another `<Outlet />`

⚠️ **Common Traps**
- Setting up nested `<Route>` tags in `App.jsx` but **forgetting `<Outlet />`** in the parent component — URL updates but the screen never changes
- Starting a child path with `/` (e.g., `path="/profile"`) — React Router treats it as absolute, breaking the parent layout entirely
- Putting `<Outlet />` inside `App.jsx` next to `<Routes>` — it belongs inside the **parent layout component**, not where routes are defined

📚 **From Docs**
- `<Outlet>` can receive a `context` prop to pass data down to child routes without prop drilling
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 `useParams`

### ⚡ Core Idea
A hook that extracts **dynamic URL segments** (defined with `:`) from the current URL and returns them as a plain object.

### ❓ Problem It Solves
Reusable pages (ProductDetails, UserProfile) need to load different data based on an ID in the URL — without manually parsing `window.location.pathname.split('/')`.

### 🏗️ Before vs After
- **Before:** `const id = window.location.pathname.split('/')[2]` — fragile, not reactive
- **After:** React Router parses the URL against your `<Route path>` definition and returns a clean `{ paramName: value }` object

### 🔗 Angular vs React
| Concept | Angular | React Router |
|---|---|---|
| Route definition | `{ path: 'products/:id' }` | `<Route path="/products/:id" />` |
| Read parameter | `route.snapshot.paramMap.get('id')` | `const { id } = useParams()` |
| On URL change | `route.params.subscribe(...)` (Observable) | Automatic re-render with new value |

### 🧪 Example
```jsx
import { Routes, Route, useParams } from 'react-router-dom';

function ProductDetails() {
  const { productId } = useParams(); // name MUST match the ':productId' in Route
  return <h2>Product #{productId}</h2>;
}

function App() {
  return (
    <Routes>
      <Route path="/products/:productId" element={<ProductDetails />} />
    </Routes>
  );
}

// Multiple params: /stores/:storeId/items/:itemId
// const { storeId, itemId } = useParams();
```

💡 **Key Insights**
- The destructured variable name **must exactly match** what follows `:` in the `path` — a mismatch returns `undefined` silently
- No Observable cleanup needed (unlike Angular) — React re-renders the component automatically when the URL param changes

⚠️ **Common Traps**
- Naming mismatch: `<Route path="/users/:userId" />` but `const { id } = useParams()` — `id` will be `undefined`

📚 **From Docs**
- `useParams` returns an object of key/value pairs from dynamic segments of the current URL that were matched by the nearest `<Route>`
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 `useNavigate`

### ⚡ Core Idea
A hook that returns a `navigate()` function for **programmatic** URL changes — triggered by code logic, not user clicks.

### ❓ Problem It Solves
`<Link>` requires a user click. You often need to redirect automatically — after a successful login, after form submission, or when a user lacks permissions.

### 🏗️ Before vs After
- **Before:** Returning a `<Navigate>` component from render logic, cluttering JSX with control flow
- **After:** A clean function call `navigate('/dashboard')` placed exactly where your logic lives

### 🔗 Angular vs React
| Feature | Angular | React Router |
|---|---|---|
| Tool | `Router` (injected service) | `useNavigate()` hook |
| Basic usage | `this.router.navigate(['/dashboard'])` | `navigate('/dashboard')` |
| Go back | `location.back()` | `navigate(-1)` |
| Replace history | `navigate([...], { replaceUrl: true })` | `navigate('/path', { replace: true })` |

### 🧪 Example
```jsx
import { useNavigate } from 'react-router-dom';

export default function LoginForm() {
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    await fakeAuthApi();

    // { replace: true } prevents the user from pressing Back to return to login
    navigate('/dashboard', { replace: true });
  };

  return <form onSubmit={handleLogin}><button type="submit">Log In</button></form>;
}
```

💡 **Key Insights**
- `{ replace: true }` replaces the current history entry instead of pushing a new one — essential for login redirects so "Back" doesn't return to the login screen
- Pass hidden data between routes without polluting the URL: `navigate('/profile', { state: { fromLogin: true } })`. Read it in the target with `useLocation().state`
- `navigate(-1)` goes back, `navigate(1)` goes forward — just like the browser history API

⚠️ **Common Traps**
- Calling `navigate('/dashboard')` **directly in the component body** (during render) instead of inside an event handler or `useEffect` — this triggers a render loop and crashes the app

📚 **From Docs**
- `useNavigate` is the v6 replacement for the old `useHistory` hook
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 `useLocation` & `useSearchParams`

### ⚡ Core Idea
`useLocation` returns the full current URL context (pathname, hash, hidden state). `useSearchParams` is a specialized hook for reading and updating the `?key=value` query string.

### ❓ Problem It Solves
Native `window.location.search` doesn't trigger React re-renders when query params change. You need reactive, React-aware access to URL data.

### 🏗️ Before vs After
- **Before:** Manually parsing `window.location.search` with `URLSearchParams` — no re-render on change
- **After:** `useSearchParams` returns a `[state, setter]` tuple (identical to `useState`) — component re-renders automatically when params change

### 🔗 Angular vs React
| Concept | Angular | React Router |
|---|---|---|
| Read query param | `ActivatedRoute.queryParamMap.get('q')` | `searchParams.get('q')` |
| Set query param | `router.navigate([], { queryParams: { q: 'new' } })` | `setSearchParams({ q: 'new' })` |
| Hidden nav state | `router.getCurrentNavigation().extras.state` | `useLocation().state` |

### 🧪 Example
```jsx
import { useLocation, useSearchParams } from 'react-router-dom';

export default function SearchResults() {
  const location = useLocation();
  console.log(location.pathname);  // "/search"
  console.log(location.state);     // hidden data passed via navigate()

  const [searchParams, setSearchParams] = useSearchParams();
  const query = searchParams.get('q'); // ?q=react → "react"

  // ✅ Update ONE param without wiping the others
  const updateQuery = () => {
    setSearchParams(prev => {
      prev.set('q', 'angular');
      return prev;
    });
  };

  return <div><p>Query: {query}</p><button onClick={updateQuery}>Switch</button></div>;
}
```

💡 **Key Insights**
- `searchParams` is an instance of the native browser `URLSearchParams` API — access values with `.get('key')`, not `searchParams.key`
- To update one param without losing others, use the functional updater form shown above
- Use `location.state` for data that shouldn't appear in the URL (large objects, flags like `{ fromRegistration: true }`)

⚠️ **Common Traps**
- `searchParams.q` → **always `undefined`**. Use `searchParams.get('q')`
- `setSearchParams({ q: 'new' })` **replaces the entire query string** — all other params are lost. Use the functional form with `prev.set()`

📚 **From Docs**
- `useSearchParams` works identically to `useState` but reads/writes from the URL query string instead of component memory
- Reference: [https://reactrouter.com/](https://reactrouter.com/)

---

## 🧠 HTTP Requests — Axios vs Fetch

### ⚡ Core Idea
Both `axios` and native `fetch` make HTTP requests. Axios reduces boilerplate (auto JSON parsing, auto error throwing). `fetch` requires manual handling but has zero dependencies.

### ❓ Problem It Solves
React has no built-in HTTP client (unlike Angular's `HttpClientModule`). You pick your own tool based on project complexity.

### 🏗️ Before vs After
- **Before (Angular):** `HttpClientModule` + RxJS Observables — powerful but requires `.subscribe()` even for simple one-shot requests
- **After (React + Axios):** Standard `async/await` Promises — linear, readable, no stream management

### 🔗 Angular vs React
| Feature | Angular `HttpClient` | `fetch()` | `axios` |
|---|---|---|---|
| Source | Built-in framework | Built-in browser | 3rd-party (npm) |
| JSON parsing | Auto | Manual (`res.json()`) | Auto |
| 4xx/5xx errors | Auto-throws | Manual (`if (!res.ok)`) | Auto-throws |
| Interceptors | Native class | Custom wrapper required | Native config |
| Paradigm | RxJS Observables (lazy) | Promises (eager) | Promises (eager) |

### 🧪 Example
```jsx
// fetch — more boilerplate
const loadWithFetch = async () => {
  const res = await fetch('https://api.example.com/user');
  if (!res.ok) throw new Error('HTTP error!'); // mandatory manual check
  const data = await res.json();               // mandatory manual parse
  setUser(data);
};

// axios — less boilerplate
import axios from 'axios';

const loadWithAxios = async () => {
  const { data } = await axios.get('https://api.example.com/user');
  // auto-parsed, auto-throws on 4xx/5xx
  setUser(data);
};
```

💡 **Key Insights**
- Axios always wraps the server response inside a `data` property — access it as `response.data`, not `response`
- `fetch` only enters `catch` on **network failure** (no internet) — a 404 or 500 response is a **successful** Promise to `fetch`
- Modern industry standard: pass either into **TanStack Query (React Query)** for caching, deduplication, and loading states
- Install: `npm install axios`

⚠️ **Common Traps**
- `setUser(response)` with Axios — you're storing the full Axios response object. Use `setUser(response.data)`
- `try/catch` with `fetch` does NOT catch 404/500 — always check `if (!res.ok)` before parsing

📚 **From Docs**
- React places zero restrictions on how you fetch data — the pattern is framework-agnostic
- Reference: [https://react.dev/learn/escape-hatches](https://react.dev/learn/escape-hatches)

---

## 🧠 `useState` — Local Component State

### ⚡ Core Idea
Declares a reactive state variable inside a functional component. Every call to the setter triggers a **full re-render** of that component.

### ❓ Problem It Solves
React functional components are plain functions — they have no persistent memory between calls. `useState` gives a component memory that survives re-renders.

### 🏗️ Before vs After
- **Before (Angular):** Mutable class properties + Zone.js automatically detects changes and updates the view
- **After (React):** Immutable state snapshot + explicit setter function that tells React to re-render

### 🔗 Angular vs React
- Angular: `this.count = 5` → Zone.js detects mutation → auto re-render
- React: `setCount(5)` → explicit signal → React re-renders the full component function

### 🧪 Example
```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0); // [current value, setter function]

  return <button onClick={() => setCount(count + 1)}>Count: {count}</button>;
}
```

💡 **Key Insights**
- Calling a setter is not just updating a variable — it's an **instruction to React to re-execute the entire component function**
- Never mutate state directly (`count = 5`) — React won't detect it and won't re-render
- State updates may be **batched** — never rely on `count` being updated immediately after calling `setCount`

⚠️ **Common Traps**
- Mutating state directly like Angular class properties — no re-render occurs
- Calling `setState` in the component body (outside event handlers or `useEffect`) — causes an infinite render loop

📚 **From Docs**
- `useState` returns a pair: the current state value and a function to update it
- Reference: [https://react.dev/reference/react/useState](https://react.dev/reference/react/useState)

---

## 🧠 `useEffect` — Side Effects & Lifecycle

### ⚡ Core Idea
Runs code **after** React renders the UI. Used for anything that reaches outside React (API calls, subscriptions, DOM manipulation, timers).

### ❓ Problem It Solves
React components must be pure (input → UI output). Side effects placed directly in the component body would block screen painting, run on every render, and break React's rendering model.

### 🏗️ Before vs After
- **Before (Angular):** Separate lifecycle hooks (`ngOnInit`, `ngOnChanges`, `ngOnDestroy`) for each phase
- **After (React):** One `useEffect` handles mount, update, and cleanup using a dependency array and an optional return function

### 🔗 Angular vs React
| Lifecycle Phase | Angular | React `useEffect` |
|---|---|---|
| On mount | `ngOnInit` | `useEffect(() => {...}, [])` |
| On specific change | `ngOnChanges` (filtered) | `useEffect(() => {...}, [myVar])` |
| On every render | `ngDoCheck` | `useEffect(() => {...})` (no array) |
| On destroy | `ngOnDestroy` | `return () => {...}` inside the effect |

### 🧪 Example — Full Pattern
```jsx
import { useState, useEffect } from 'react';
import axios from 'axios';

export default function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    // 1. SETUP — runs after paint
    const controller = new AbortController();

    const fetchUser = async () => {
      try {
        const { data } = await axios.get(`/api/users/${userId}`, {
          signal: controller.signal
        });
        setUser(data);
      } catch (err) {
        if (err.name !== 'CanceledError') console.error(err);
      }
    };

    fetchUser();

    // 2. CLEANUP — runs before next effect OR on unmount
    return () => controller.abort();

  }, [userId]); // 3. DEPENDENCY — only re-run when userId changes

  return <div>{user ? user.name : 'Loading...'}</div>;
}
```

💡 **Key Insights**
- `useEffect` runs **asynchronously after the browser paints** — the UI is visible first, then the effect fires
- The exact execution order per render: `component renders → browser paints screen → useEffect runs`
- **Do not use `useEffect` for derived data** — if you have `firstName` and `lastName`, compute `const fullName = firstName + ' ' + lastName` directly in the component body. No effect needed
- React 18 `<StrictMode>` intentionally mounts → unmounts → remounts components in **dev only** to test cleanup functions — not a bug

⚠️ **Common Traps**
- Making the `useEffect` callback itself `async`: `useEffect(async () => {...})` — React expects the callback to return either nothing or a cleanup function. `async` functions always return a Promise. **Wrap async logic inside a named function and call it**
- Omitting the dependency array `[]` when you mean "run once" — without it, the effect runs after every single render
- "Lying" to React: using a variable inside the effect but leaving it out of the dependency array — React locks in the stale value from the first render

📚 **From Docs**
- Effects let you synchronize a component with an external system. If you're not syncing with anything external, you might not need an Effect
- Reference: [https://react.dev/reference/react/useEffect](https://react.dev/reference/react/useEffect#reference)
- Reference: [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)

---

## 🧠 `useEffect` Dependency Array — Deep Dive

### ⚡ Core Idea
A "trigger whitelist" — React runs the effect only when a value in this list has **changed** (compared using `Object.is` / `===`).

### ❓ Problem It Solves
A component often manages multiple unrelated state variables. Without dependencies, typing in a text input would re-trigger an expensive API call or reconnect a WebSocket — wasting resources and breaking behavior.

### 🏗️ Before vs After
- **Before (Angular):** `ngOnChanges(changes: SimpleChanges)` then manually `if (changes['roomId'])` for each variable
- **After (React):** Drop `roomId` into the array — React automatically skips the effect if `roomId` didn't change

### 🔗 Angular vs React
| Array Type | React Syntax | Angular Equivalent | Runs when... |
|---|---|---|---|
| Empty | `useEffect(fn, [])` | `ngOnInit` | Once on mount only |
| With vars | `useEffect(fn, [id])` | `ngOnChanges` (filtered) | Mount + when `id` changes |
| No array | `useEffect(fn)` | `ngDoCheck` | Mount + after every render |

### 🧪 Example — Chat Room Isolation
```jsx
export default function ChatRoom({ roomId }) {
  const [draftMessage, setDraftMessage] = useState('');

  useEffect(() => {
    console.log(`[CONNECT] Joining: ${roomId}`);

    return () => {
      console.log(`[DISCONNECT] Leaving: ${roomId}`);
      // Cleanup runs BEFORE next effect, or on unmount
    };
  }, [roomId]); // typing in draftMessage causes re-render but effect is skipped

  return <input value={draftMessage} onChange={e => setDraftMessage(e.target.value)} />;
}
```
When `roomId` changes from `"general"` → `"sports"`:
1. Cleanup runs: `[DISCONNECT] Leaving: general`
2. Effect runs: `[CONNECT] Joining: sports`

💡 **Key Insights**
- React compares dependencies using `Object.is()` (strict equality `===`)
- **Stale closure trap:** If you use a variable inside the effect but omit it from the array, the effect "sees" the value from the first render forever — even as it changes
- **Object/Array/Function pitfall:** `{} === {}` is `false` in JavaScript. Declaring these inside a component and putting them in the dependency array will cause the effect to run on every render because they're recreated as new references each time

⚠️ **Common Traps**
- Omitting a variable you use inside the effect from the array — stale data, silent bug
- Putting inline objects/arrays in the dependency array without memoization (`useMemo`/`useCallback`) — causes infinite effect loops

📚 **From Docs**
- React uses `Object.is` to compare dependency values — the same comparison algorithm as `===` for primitives
- Reference: [https://react.dev/reference/react/useEffect#reference](https://react.dev/reference/react/useEffect#reference)

---

## 🧠 The Infinite Loop Problem — Why `useEffect` Exists for Fetching

### ⚡ Core Idea
A React component is a **plain JavaScript function** that re-executes top-to-bottom on every state update. Fetching data in the function body updates state → triggers re-render → fetches again → infinite loop.

### ❓ Problem It Solves
Every developer hits this wall when first using React after Angular. Angular components are classes — `ngOnInit` runs once. React components are functions — they run completely every single render.

### 🏗️ Before vs After
- **Before (the loop):** `fetch → setData → re-render → fetch → setData → re-render → ∞`
- **After (with `useEffect`):** `render → paint → useEffect fires once ([] dependency) → setData → re-render → useEffect sees [] hasn't changed → stops`

### 🔗 Angular vs React
- Angular: `this.data = response` updates a class property. Does **not** re-run `constructor` or `ngOnInit`
- React: `setData(response)` tells React to **re-execute the entire component function** from line 1

### 🧪 Example
```jsx
import { useState, useEffect } from 'react';

export default function UserProfile() {
  const [data, setData] = useState(null);

  // 🔴 INFINITE LOOP — runs every render:
  // fetch('...').then(res => res.json()).then(result => setData(result));

  // ✅ CORRECT — runs once on mount:
  useEffect(() => {
    fetch('https://api.example.com/data')
      .then(res => res.json())
      .then(result => setData(result));
  }, []); // empty array = "only on mount"

  return <div>{data ? data.name : 'Loading...'}</div>;
}
```

💡 **Key Insights**
- `useEffect` + `useState` are a **team**, not alternatives. Effect fetches; state stores
- The `[]` dependency array is what breaks the loop — `useEffect` sees nothing changed and doesn't re-run
- An `onClick` handler avoids the loop too — it only fires on user interaction, not during render

⚠️ **Common Traps**
- Forgetting `[]` when you mean "run once" — without it, effect runs after every render → same infinite loop

📚 **From Docs**
- You Might Not Need an Effect: if you're computing something from existing state/props, do it during render — no Effect needed
- Reference: [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)

---

## 🧠 `useRef`

### ⚡ Core Idea
A persistent, mutable "box" (`{ current: value }`) that stores data across renders **without triggering a re-render** when mutated. Also used for direct DOM element access.

### ❓ Problem It Solves
Two separate needs:
1. **Mutable data that shouldn't re-render:** Timer IDs, previous state values, animation flags
2. **Direct DOM access:** Focusing an input, measuring element dimensions, integrating 3rd-party DOM libraries

### 🏗️ Before vs After
- **Before:** `let timerId` inside the component (erased on every render) or `document.getElementById` (breaks React's declarative model)
- **After:** `useRef` holds data that survives re-renders and attaches to DOM elements via the `ref` JSX attribute

### 🔗 Angular vs React
| Concept | Angular | React |
|---|---|---|
| DOM access | `@ViewChild('myEl')` | `const ref = useRef(); <div ref={ref}>` |
| Mutable data | Class properties (`this.timerId`) | `ref.current = ...` |
| Re-render trigger | No (unless bound in template) | Never |

### 🧪 Example
```jsx
import { useRef, useState } from 'react';

export default function TimerWithFocus() {
  const [count, setCount] = useState(0);

  // 1. DATA REF: Stores timer ID — no re-render when changed
  const timerRef = useRef(null);

  // 2. DOM REF: Direct reference to the <input> element
  const inputRef = useRef(null);

  const startTimer = () => {
    timerRef.current = setInterval(() => setCount(c => c + 1), 1000);
  };

  const stopTimer = () => {
    clearInterval(timerRef.current); // read the stored ID
  };

  const focusInput = () => {
    inputRef.current.focus(); // native DOM API call
  };

  return (
    <div>
      <p>Count: {count}</p>
      <input ref={inputRef} placeholder="Click 'Focus' to activate me" />
      <button onClick={focusInput}>Focus Input</button>
      <button onClick={startTimer}>Start</button>
      <button onClick={stopTimer}>Stop</button>
    </div>
  );
}
```

💡 **Key Insights**
- `useRef` returns `{ current: initialValue }`. You read/write via `.current`
- Mutating `ref.current` **never** causes a re-render — use `useState` for any value that needs to be displayed
- A `let` variable declared inside a component is erased every render. `useRef` persists across them
- The initial value passed to `useRef(null)` is only used once — it's ignored on re-renders

⚠️ **Common Traps**
- Using `ref.current` to display dynamic text — mutating it won't update the screen. Use `useState` for visual data
- Reading or writing `ref.current` during the **render phase** (main function body) — treat the render as pure. Only use refs inside event handlers or `useEffect`
- Trying to pass a `ref` to a custom component like `<MyComponent ref={ref} />` without wrapping it in `React.forwardRef` — it won't work by default

📚 **From Docs**
- When you want a component to remember some information, but you don't want that information to trigger new renders, you can use a ref
- Reference: [https://react.dev/reference/react/useRef](https://react.dev/reference/react/useRef)
- Reference: [https://react.dev/learn/escape-hatches](https://react.dev/learn/escape-hatches)

---

## 🚀 Final Takeaways

- **React Router is just components.** There's no separate config file — your routing hierarchy is visible directly in JSX. `<BrowserRouter>` → `<Routes>` → `<Route>` = environment → switchboard → destination
- **Always wrap `BrowserRouter` in `main.jsx`**, not inside `App.jsx`, so `App` and all global providers can use routing hooks
- **`<Link>` preserves state. `<a>` destroys it.** Use `<NavLink>` when you need active styling. Use `<Outlet />` wherever child routes should inject their content
- **`useState` and `useEffect` are a team:** `useState` is the warehouse (stores data), `useEffect` is the delivery truck (fetches it). Never put an API call directly in the component body — it creates an infinite loop because React re-runs the function on every state update
- **The dependency array is a trigger whitelist:** `[]` = run once on mount. `[var]` = run on mount + when `var` changes. No array = run after every render (almost never what you want)
- **`useRef` for "invisible" data:** Anything you need to persist across renders but don't want to display (timer IDs, DOM references, previous values) belongs in a ref. If it's displayed on screen → `useState`. If it's behind the scenes → `useRef`
- **Avoid `useEffect` for derived data:** `const fullName = firstName + ' ' + lastName` directly in the component body is always better than a `useEffect` that watches `firstName` and `lastName` and updates a `fullName` state

---

*Sources: [react.dev](https://react.dev) · [reactrouter.com](https://reactrouter.com)*
