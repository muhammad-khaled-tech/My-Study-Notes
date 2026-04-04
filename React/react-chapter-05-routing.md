# الفصل الخامس — React Router: التنقل بين الصفحات

> **المتطلبات:** [[04-useEffect]] — لازم تعرف الـ useEffect كويس لأنك هتحتاجه تجيب data لما الـ URL يتغيّر، وكمان لازم تعرف الـ state عشان تتعامل مع الـ loading وحالات الـ page المختلفة.

---

## البداية — ليه محتاج Router أصلاً؟

لو فتحت أي موقع حقيقي دلوقتي وبصّيت على الـ URL:

```
amazon.com/s?k=laptop&page=2
          ↑ صفحة بحث

amazon.com/dp/B09G9FPHY6
          ↑ صفحة منتج معيّن

amazon.com/gp/cart/view.html
          ↑ الكارت
```

كل صفحة عندها URL مختلف — بس الـ page ما اتعملتش reload خالص. إنت بتضغط "Back" في المتصفح وبترجع للصفحة اللي قبلها من غير ما السيرفر يتكلّم. ده اللي بيسمى **Client-Side Routing**.

في React من غير router، الـ app بتاعتك **صفحة واحدة بس**. مفيش `/tasks`، مفيش `/tasks/42`، مفيش `/settings`. كل حاجة في نفس المكان. مش بتقدر تـshare الـ URL، والـ "Back" button مش بيشتغل، والـ bookmarking مش بيشتغل.

React Router بتحلّ ده بـ trick ذكية: بتفحص الـ URL في الـ browser، وعلى أساسه بتقرر **إيه الـ component اللي يتعرض**. كل ده من غير ما السيرفر يعمل أي حاجة.

```
Browser URL changes to /tasks/42
          ↓
React Router reads the URL
          ↓
Matches the pattern /tasks/:id
          ↓
Renders <TaskDetails /> with id = "42"
          ↓
No server request. No page reload. ✅
```

---

## [[01-Installation-and-Setup]] — التنصيب والإعداد

```bash
npm install react-router-dom
```

بعدين في `main.jsx` — هتلفّ كل التطبيق في `<BrowserRouter>`:

```jsx
// main.jsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom'; // ← import
import App from './App.jsx';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>  {/* ← wrap everything */}
      <App />
    </BrowserRouter>
  </StrictMode>
);
```

الـ `BrowserRouter` بيعمل حاجتين:
1. **يراقب الـ URL** — أي تغيير في الـ URL يعرفه
2. **يوفّر الـ Context** — كل component جوّاه يقدر يوصل لمعلومات الـ route

> ⚠️ **انتبه:** لو نسيت تحطه أو حطيت component بيستخدم `useNavigate` أو `useParams` من **برّا** الـ `BrowserRouter` — هتاخد error فوري: *"useNavigate() may be used only in the context of a Router component"*.

---

## [[02-Defining-Routes]] — تعريف الـ Routes

جوّا الـ `App.jsx` بنحدد إيه اللي يتعرض لما كل URL:

```jsx
// App.jsx
import { Routes, Route } from 'react-router-dom';
import TaskBoard    from './pages/TaskBoard';
import TaskDetails  from './pages/TaskDetails';
import NewTask      from './pages/NewTask';
import Settings     from './pages/Settings';
import NotFound     from './pages/NotFound';

function App() {
  return (
    <Routes>
      {/* exact match — only /  */}
      <Route path="/"          element={<TaskBoard />}   />

      {/* dynamic segment — :id is a variable */}
      <Route path="/tasks/:id" element={<TaskDetails />} />

      {/* static routes */}
      <Route path="/tasks/new" element={<NewTask />}     />
      <Route path="/settings"  element={<Settings />}   />

      {/* catch-all — matches anything that didn't match above */}
      <Route path="*"          element={<NotFound />}   />
    </Routes>
  );
}
```

**إزاي React Router بيقرر إيه اللي يـmatch؟**

الـ Routes بتتقارن من فوق لتحت. أول route تـmatch هي اللي بتتعرض بس. عشان كده ترتيب الـ routes مهم.

```
URL: /tasks/new

Does it match "/"?          No  — /tasks/new ≠ /
Does it match "/tasks/:id"? Yes — but WAIT...
Does it match "/tasks/new"? Also Yes

React Router v6 is SMART — it picks the MOST SPECIFIC match.
/tasks/new is more specific than /tasks/:id (static beats dynamic)
So <NewTask /> renders. ✅
```

في React Router v6، مش محتاج تقلق عن الترتيب كتير — بيختار الأكثر تحديداً تلقائياً. ده تغيير جوهري عن v5.

---

## [[03-Link-and-NavLink]] — التنقل بين الصفحات: Link وNavLink

### الـ `<Link>` — بديل `<a href>` في React Router

في HTML العادي بنستخدم `<a href="/tasks">`. المشكلة إن الـ `<a>` بيعمل **full page reload** — الـ browser بيروح للسيرفر ويطلب الصفحة من الأول.

الـ `<Link>` بيعمل نفس الشكل بس من غير page reload:

```jsx
import { Link } from 'react-router-dom';

function Navbar() {
  return (
    <nav>
      {/* ✅ client-side navigation — no reload */}
      <Link to="/">Home</Link>
      <Link to="/tasks/new">+ New Task</Link>
      <Link to="/settings">Settings</Link>

      {/* ❌ full page reload — server request — DON'T use inside React Router apps */}
      <a href="/tasks/new">+ New Task</a>
    </nav>
  );
}
```

---

### الـ `<NavLink>` — زي `<Link>` بس بيعرف هو active ولا لأ

الـ `<NavLink>` بيضيف automatically `className="active"` على الـ link اللي URL بتاعه matches الـ URL الحالي:

```jsx
import { NavLink } from 'react-router-dom';

function Sidebar() {
  return (
    <aside className="sidebar">
      <NavLink
        to="/"
        className={({ isActive }) =>
          isActive ? 'nav-item active' : 'nav-item'
          // isActive: true when current URL matches "/"
        }
      >
        📋 All Tasks
      </NavLink>

      <NavLink
        to="/settings"
        className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}
      >
        ⚙️ Settings
      </NavLink>
    </aside>
  );
}
```

```css
/* styles.css */
.nav-item        { color: #666; padding: 8px 16px; }
.nav-item.active { color: #0066cc; background: #e8f0fe; font-weight: 600; }
```

> **نصيحة الخبراء:** الـ `NavLink` على `/` بياخد `end` prop عشان ميبقاش active في كل route:
> ```jsx
> <NavLink to="/" end>Home</NavLink>
> {/* Without "end": / is considered active for /tasks, /settings, etc. */}
> {/* With "end": only active when URL is exactly "/" */}
> ```

---

## [[04-useNavigate]] — التنقل برمجياً: useNavigate

الـ `<Link>` بيشتغل لما عندك link في الـ UI. بس أحياناً محتاج تعمل navigate **بعد حاجة حصلت** — بعد submit form، بعد تسجيل دخول، بعد مسح item:

```jsx
import { useNavigate } from 'react-router-dom';

function NewTaskForm() {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();

    await fetch('/api/tasks', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ title }),
    });

    // navigate programmatically after success
    navigate('/');
    // same as: user clicked a <Link to="/" />
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={title} onChange={e => setTitle(e.target.value)} />
      <button type="submit">Create Task</button>

      {/* cancel button — go back one step in history */}
      <button type="button" onClick={() => navigate(-1)}>
        Cancel
      </button>
    </form>
  );
}
```

**الـ navigate بتاخد:**

```jsx
navigate('/tasks');           // go to /tasks
navigate('/tasks/42');        // go to specific task
navigate(-1);                 // go BACK (like browser back button)
navigate(1);                  // go FORWARD
navigate('/login', { replace: true }); // replace current entry in history
                                        // back button won't return here
```

**الـ `replace: true` امتى تستخدمه؟**

تخيّل المستخدم عمل login. بعد الـ login نعمله navigate للـ dashboard. لو استخدمنا navigate عادي — لو ضغط Back هيرجع لصفحة الـ login. ده weird. باستخدام `replace: true` — الـ login page بتتشال من الـ history، فالـ Back button هياخده قبل الـ login مش ليها.

```jsx
// After login — replace the login page in history
navigate('/dashboard', { replace: true });
```

---

## [[05-useParams]] — قراءة الـ URL Parameters: useParams

لما عندك route زي `/tasks/:id` — الـ `:id` هو **dynamic segment** بيتغيّر مع كل task.

الـ `useParams` بيقرأ القيم دي:

```jsx
// Route defined as: <Route path="/tasks/:id" element={<TaskDetails />} />

import { useParams } from 'react-router-dom';

function TaskDetails() {
  const { id } = useParams();
  // id = "42" when URL is /tasks/42
  // id = "abc" when URL is /tasks/abc
  // id is ALWAYS a string — convert if you need a number

  const [task, setTask]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

  useEffect(() => {
    if (!id) return;

    const controller = new AbortController();

    fetch(`/api/tasks/${id}`, { signal: controller.signal })
      .then(r => {
        if (!r.ok) throw new Error(r.status === 404 ? 'Task not found' : 'Server error');
        return r.json();
      })
      .then(data => { setTask(data);  setLoading(false); })
      .catch(err  => {
        if (err.name === 'AbortError') return;
        setError(err.message);
        setLoading(false);
      });

    return () => controller.abort();
  }, [id]); // re-run when id changes — if user navigates /tasks/1 → /tasks/2

  if (loading) return <div className="loading">Loading task...</div>;
  if (error)   return <div className="error">{error} — <Link to="/">Go back</Link></div>;
  if (!task)   return null;

  return (
    <div className="task-detail">
      <Link to="/">← All Tasks</Link>
      <h1>{task.title}</h1>
      <span className={`priority ${task.priority}`}>{task.priority}</span>
      <p>Assigned to: {task.assignee}</p>
    </div>
  );
}
```

**نقطة مهمة — الـ params دايماً strings:**

```jsx
const { id } = useParams(); // id = "42" (string, not number)

// If your API needs a number:
const numericId = Number(id);          // 42
const numericId = parseInt(id, 10);    // 42
const numericId = +id;                 // 42 — works but less readable

// Safe approach with fallback:
const numericId = id ? Number(id) : null;
```

**Multiple params في نفس الـ route:**

```jsx
// Route: <Route path="/projects/:projectId/tasks/:taskId" element={<TaskDetails />} />

function TaskDetails() {
  const { projectId, taskId } = useParams();
  // URL /projects/5/tasks/42 → projectId = "5", taskId = "42"
}
```

---

## [[06-useSearchParams]] — الـ Query Parameters: useSearchParams

الـ Query Parameters هي الـ `?key=value` بعد الـ URL. بتستخدمها للـ filtering والـ sorting والـ pagination — أي حاجة اختيارية مش جزء من هوية الـ resource.

```
/tasks?status=open&priority=high&page=2
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
       Query params — optional context for the same route
```

الـ `useSearchParams` شغله زي `useState` بالظبط — بس بدل ما يحفظ القيمة في الـ memory، بيحفظها في الـ URL:

```jsx
import { useSearchParams } from 'react-router-dom';

function TaskBoard() {
  // [currentParams, setterFunction] — same pattern as useState
  const [searchParams, setSearchParams] = useSearchParams();

  // reading params — always returns string or null
  const status   = searchParams.get('status')   ?? 'all';
  const priority = searchParams.get('priority') ?? 'all';
  const page     = Number(searchParams.get('page') ?? '1');

  function handleStatusChange(newStatus) {
    setSearchParams(prev => {
      // prev is the CURRENT params — don't lose them
      const next = new URLSearchParams(prev);
      next.set('status', newStatus);
      next.set('page', '1'); // reset page when filter changes
      return next;
    });
    // URL changes: /tasks → /tasks?status=open&page=1
    // Component re-renders with new values
    // URL is now shareable — anyone with this URL sees same filter ✅
  }

  function handlePageChange(newPage) {
    setSearchParams(prev => {
      const next = new URLSearchParams(prev);
      next.set('page', String(newPage));
      return next; // keeps status and priority, only updates page
    });
  }

  // fetch with current filter values
  const [tasks, setTasks]     = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);

    const url = `/api/tasks?status=${status}&priority=${priority}&page=${page}`;

    fetch(url, { signal: controller.signal })
      .then(r => r.json())
      .then(data => { setTasks(data); setLoading(false); })
      .catch(err => { if (err.name !== 'AbortError') setLoading(false); });

    return () => controller.abort();
  }, [status, priority, page]); // re-fetch when any filter changes

  return (
    <div>
      {/* Filter controls */}
      <div className="filters">
        <select value={status} onChange={e => handleStatusChange(e.target.value)}>
          <option value="all">All Status</option>
          <option value="open">Open</option>
          <option value="done">Done</option>
        </select>

        <select
          value={priority}
          onChange={e => {
            setSearchParams(prev => {
              const next = new URLSearchParams(prev);
              next.set('priority', e.target.value);
              next.set('page', '1');
              return next;
            });
          }}
        >
          <option value="all">All Priorities</option>
          <option value="high">High</option>
          <option value="medium">Medium</option>
          <option value="low">Low</option>
        </select>
      </div>

      {/* Task list */}
      {loading
        ? <div>Loading...</div>
        : tasks.map(task => <TaskCard key={task.id} {...task} />)
      }

      {/* Pagination */}
      <div className="pagination">
        <button disabled={page === 1}   onClick={() => handlePageChange(page - 1)}>Previous</button>
        <span>Page {page}</span>
        <button disabled={tasks.length < 10} onClick={() => handlePageChange(page + 1)}>Next</button>
      </div>
    </div>
  );
}
```

**الفرق بين Route Params وSearch Params:**

| | Route Params (`:id`) | Search Params (`?key=value`) |
|---|---|---|
| المكان في الـ URL | `/tasks/42` | `/tasks?page=2` |
| اختياري؟ | لأ — جزء من الـ route | أيوه — اختياري |
| يتغير مع كل resource؟ | أيوه — كل task بـ id مختلف | لأ — نفس الصفحة بـ context مختلف |
| الاستخدام | تحديد resource بعينه | filtering, sorting, pagination |
| Hook | `useParams()` | `useSearchParams()` |

---

## [[07-Nested-Routes]] — الـ Nested Routes: صفحة جوّا صفحة

تخيّل معايا Gmail. الـ Sidebar دايماً موجودة — بس المحتوى بيتغيّر بناءً على الـ section:

```
/mail/inbox   → sidebar + inbox list
/mail/starred → sidebar + starred list
/mail/sent    → sidebar + sent list
```

الـ Sidebar مش بتتعمل re-render في كل navigate. بس المحتوى بيتغيّر. ده الـ **Nested Routes**.

```jsx
// App.jsx
import { Routes, Route, Outlet } from 'react-router-dom';

function App() {
  return (
    <Routes>
      {/* Parent route — renders the Layout */}
      <Route path="/" element={<AppLayout />}>
        {/* Child routes — rendered inside <Outlet /> */}
        <Route index         element={<TaskBoard />}   />
        {/* index = renders when path is exactly "/" */}

        <Route path="tasks/:id" element={<TaskDetails />} />
        <Route path="settings"  element={<Settings />}   />
      </Route>

      {/* Outside the layout — full screen */}
      <Route path="/login"    element={<Login />}    />
      <Route path="*"         element={<NotFound />} />
    </Routes>
  );
}
```

الـ `AppLayout` فيه الـ `<Outlet />` — وده هو المكان اللي الـ child route بيتحط فيه:

```jsx
// AppLayout.jsx — the persistent shell
import { Outlet } from 'react-router-dom';

function AppLayout() {
  return (
    <div className="app-shell">
      <Navbar />            {/* always rendered — doesn't re-mount on navigation */}

      <div className="content">
        <Sidebar />         {/* always rendered */}

        <main>
          <Outlet />        {/* child route renders HERE */}
                            {/* TaskBoard, TaskDetails, or Settings depending on URL */}
        </main>
      </div>
    </div>
  );
}
```

```
URL: /

┌─────────────────────────────────────┐
│           <Navbar />                │
├──────────┬──────────────────────────┤
│          │                          │
│<Sidebar/>│  <Outlet /> renders      │
│          │  <TaskBoard />           │
│          │                          │
└──────────┴──────────────────────────┘

URL: /tasks/42

┌─────────────────────────────────────┐
│           <Navbar />                │  ← same — didn't re-mount
├──────────┬──────────────────────────┤
│          │                          │
│<Sidebar/>│  <Outlet /> renders      │  ← same
│          │  <TaskDetails id="42" /> │  ← ONLY this changed
│          │                          │
└──────────┴──────────────────────────┘
```

ده فارق كبير في الـ performance — الـ Navbar والـ Sidebar مش بيتعملوا unmount وremount في كل navigate. React بتفضّل الـ DOM instances الموجودة.

---

### Outlet مع Context

ممكن تبعت data من الـ parent layout للـ child routes عن طريق `<Outlet context={...}>`:

```jsx
// AppLayout.jsx
function AppLayout() {
  const [user, setUser] = useState(null);

  return (
    <div className="app-shell">
      <Navbar user={user} />
      <main>
        <Outlet context={{ user, setUser }} />
        {/* passes user data to ALL child routes */}
      </main>
    </div>
  );
}

// TaskBoard.jsx — receives context
import { useOutletContext } from 'react-router-dom';

function TaskBoard() {
  const { user } = useOutletContext();
  // has access to the user from the parent layout
}
```

---

## [[08-Protected-Routes]] — الـ Protected Routes: صفحات محتاجة Login

معظم التطبيقات عندها صفحات مش المفروض تتشوف من غير ما المستخدم يـlogin. إزاي بنحميها؟

**المنطق بسيط:** قبل ما تعرض أي صفحة محمية — افحص إيه الـ auth state. لو مش logged in، حوّله لصفحة الـ login بدل ما تعرض الصفحة.

بنعمل component اسمه `ProtectedRoute`:

```jsx
// components/ProtectedRoute.jsx
import { Navigate, Outlet } from 'react-router-dom';

function ProtectedRoute({ isLoggedIn }) {
  if (!isLoggedIn) {
    // replace: true — user can't press Back to return to protected page
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
  // if logged in — render the child route normally
}
```

وبنستخدمه في الـ routing هيكل:

```jsx
// App.jsx
function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(
    () => Boolean(localStorage.getItem('token')) // check on startup
  );

  return (
    <Routes>
      {/* Public routes — anyone can access */}
      <Route path="/login"  element={<Login  onLogin={() => setIsLoggedIn(true)} />} />
      <Route path="/signup" element={<Signup />} />

      {/* Protected routes — login required */}
      <Route element={<ProtectedRoute isLoggedIn={isLoggedIn} />}>
        <Route path="/"            element={<AppLayout />}>
          <Route index             element={<TaskBoard />}   />
          <Route path="tasks/:id"  element={<TaskDetails />} />
          <Route path="tasks/new"  element={<NewTask />}     />
          <Route path="settings"   element={<Settings />}   />
        </Route>
      </Route>

      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}
```

**الـ `<Navigate />`** — component بيعمل redirect فور ما يتـrender. زي `navigate()` بس كـ JSX:

```jsx
// As a component — renders nothing, just redirects
<Navigate to="/login" replace />

// Equivalent to:
const navigate = useNavigate();
navigate('/login', { replace: true });
```

---

### حفظ الـ Redirect Destination

مشكلة شائعة: المستخدم كان رايح `/tasks/42`، الـ login redirect وداه لـ `/login`، بعد الـ login المفروض يرجعه لـ `/tasks/42` مش للـ home.

```jsx
// ProtectedRoute.jsx — save where user was trying to go
import { Navigate, Outlet, useLocation } from 'react-router-dom';

function ProtectedRoute({ isLoggedIn }) {
  const location = useLocation();
  // location.pathname = the URL the user was trying to access

  if (!isLoggedIn) {
    return (
      <Navigate
        to="/login"
        replace
        state={{ from: location.pathname }}
        // passes the original destination in navigation state
      />
    );
  }

  return <Outlet />;
}

// Login.jsx — redirect to original destination after login
import { useNavigate, useLocation } from 'react-router-dom';

function Login({ onLogin }) {
  const navigate = useNavigate();
  const location = useLocation();

  // where were they trying to go?
  const from = location.state?.from ?? '/';

  async function handleLogin(credentials) {
    await loginUser(credentials);
    onLogin();
    navigate(from, { replace: true }); // send them where they wanted to go
  }
}
```

---

## [[09-useLocation]] — useLocation: معلومات الـ URL الحالي كامل

```jsx
import { useLocation } from 'react-router-dom';

function SomePage() {
  const location = useLocation();

  // location object:
  // {
  //   pathname: "/tasks/42",       — current path
  //   search:   "?status=open",    — query string (including ?)
  //   hash:     "#comments",       — URL fragment (including #)
  //   state:    { from: "/login" } — data passed via navigate()/Link state
  //   key:      "default"          — unique key for this history entry
  // }

  console.log(location.pathname); // "/tasks/42"
  console.log(location.search);   // "?status=open"
}
```

**الاستخدامات العملية:**

```jsx
// 1. Analytics — track which pages the user visits
useEffect(() => {
  analytics.track('page_view', { path: location.pathname });
}, [location.pathname]); // fires on every navigation

// 2. Conditional rendering based on current page
function Navbar() {
  const location = useLocation();
  const isHomePage = location.pathname === '/';

  return (
    <nav>
      {!isHomePage && <Link to="/">← Back to Tasks</Link>}
    </nav>
  );
}

// 3. Passing state between pages (without URL params)
// Page A — send data silently
<Link to="/tasks/new" state={{ duplicateFrom: task }}>
  Duplicate Task
</Link>

// Page B — receive the state
function NewTask() {
  const location = useLocation();
  const duplicateFrom = location.state?.duplicateFrom;
  // pre-fill the form if duplicating
}
```

> ⚠️ **انتبه:** الـ `state` مش موجود في الـ URL — لو المستخدم عمل refresh، الـ state بيتمسح. استخدمه بس للـ transient data اللي مش محتاجها تتذكّر.

---

## [[10-404-and-Redirects]] — الـ 404 والـ Redirects

```jsx
// App.jsx — complete routing structure

function App() {
  return (
    <Routes>
      <Route path="/"           element={<Home />}    />
      <Route path="/tasks"      element={<Tasks />}   />
      <Route path="/tasks/:id"  element={<TaskDetails />} />

      {/* Old URL — redirect to new one */}
      <Route path="/todo/:id" element={<Navigate to="/tasks/:id" replace />} />
      {/* Note: this won't pass :id dynamically — for dynamic redirects use a component */}

      {/* 404 — must be last */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}

// NotFound.jsx
function NotFound() {
  const location = useLocation();

  return (
    <div className="not-found">
      <h1>404</h1>
      <p>No page found at <code>{location.pathname}</code></p>
      <Link to="/">Go Home</Link>
    </div>
  );
}
```

---

## [[11-Putting-It-Together]] — TaskFlow بالـ Routing كاملاً

ده الـ structure الكامل للـ TaskFlow مع الـ routing:

```
src/
├── pages/
│   ├── TaskBoard.jsx      ← /
│   ├── TaskDetails.jsx    ← /tasks/:id
│   ├── NewTask.jsx        ← /tasks/new
│   ├── Settings.jsx       ← /settings
│   ├── Login.jsx          ← /login
│   └── NotFound.jsx       ← *
├── layouts/
│   └── AppLayout.jsx      ← persistent shell (Navbar + Sidebar)
├── components/
│   ├── Navbar.jsx
│   ├── Sidebar.jsx
│   ├── TaskCard.jsx
│   └── ProtectedRoute.jsx
└── App.jsx                ← routing configuration
```

```jsx
// App.jsx — full routing setup
import { Routes, Route, Navigate } from 'react-router-dom';

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(
    () => Boolean(localStorage.getItem('taskflow_token'))
  );

  return (
    <Routes>
      {/* Public */}
      <Route
        path="/login"
        element={
          isLoggedIn
            ? <Navigate to="/" replace />  // already logged in → go home
            : <Login onLogin={() => setIsLoggedIn(true)} />
        }
      />

      {/* Protected — requires login */}
      <Route element={<ProtectedRoute isLoggedIn={isLoggedIn} />}>
        <Route element={<AppLayout onLogout={() => setIsLoggedIn(false)} />}>
          <Route index              element={<TaskBoard />}   />
          <Route path="tasks/new"   element={<NewTask />}     />
          <Route path="tasks/:id"   element={<TaskDetails />} />
          <Route path="settings"    element={<Settings />}   />
        </Route>
      </Route>

      {/* 404 */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}
```

```
Browser: /tasks/42 (user is logged in)

Routes tree evaluation:
→ /login → no match
→ ProtectedRoute → isLoggedIn=true → renders <Outlet />
  → AppLayout → renders Navbar + Sidebar + <Outlet />
    → index → no match (path is /tasks/42)
    → tasks/new → no match
    → tasks/:id → ✅ MATCH — id = "42"
      → renders <TaskDetails /> inside AppLayout's <Outlet />

Final DOM:
<Navbar />
<Sidebar />
<TaskDetails id="42" />
```

---

## 🗺️ خريطة React Router كاملة

```mermaid
mindmap
  root((React Router))
    الإعداد
      BrowserRouter في main.jsx
      يلفّ كل التطبيق
    تعريف الـ Routes
      Routes container
      Route path + element
      index route
      wildcard *
    الـ Navigation
      Link — بدون reload
      NavLink — مع active state
      end prop للـ root
      useNavigate — برمجياً
      navigate بـ replace
      navigate(-1) للـ back
    قراءة الـ URL
      useParams — dynamic segments
      useSearchParams — query string
      useLocation — full URL info
    الـ Patterns المتقدمة
      Nested Routes + Outlet
      ProtectedRoute + Navigate
      Redirect destination مع state
      Outlet context للـ data
    الـ Hooks الكاملة
      useNavigate
      useParams
      useSearchParams
      useLocation
      useOutletContext
```

---

## ✅ Checkpoint — أسئلة إنترفيو React Router

**س: إيه الفرق بين `<Link>` و`<a href>`؟**
> الـ `<a href>` بيعمل full page reload — الـ browser بيروح للسيرفر ويطلب صفحة جديدة، الـ JavaScript بيتحمّل من الأول، الـ React state بيضيع. الـ `<Link>` من React Router بيعمل client-side navigation — بيغيّر الـ URL في الـ browser من غير ما يروح للسيرفر، الـ component المناسب بيتعرض، والـ state بيتحفظ. في production React app: `<a href>` بيستخدم بس للـ external links برّا التطبيق.

**س: إيه الفرق بين Route Params وSearch Params؟**
> الـ Route Params زي `/tasks/:id` هي جزء من الـ URL path نفسه وغالباً بتحدد resource معيّن. الـ Search Params زي `?status=open&page=2` هي اختيارية وبتيجي بعد `?`، بتستخدم للـ filtering والـ sorting والـ pagination. تقرأ الأولى بـ `useParams()`، والتانية بـ `useSearchParams()`. الفرق العملي: لو بتشوف task معيّنة → route param. لو بتفلتر قائمة tasks → search params.

**س: إيه الـ Nested Routes وليه بنستخدمها؟**
> الـ Nested Routes بتخليك تعمل layout ثابت (Navbar + Sidebar) بيفضل موجود مع تغيير المحتوى الداخلي فقط. الـ parent route بيـrender الـ layout وبيحط `<Outlet />` في المكان اللي المحتوى المتغيّر هيظهر فيه. الفايدة: الـ Navbar والـ Sidebar مش بيتعملوا unmount وremount في كل navigate — ده بيحسّن الـ performance ويحفظ الـ state بتاعهم.

**س: إزاي بتعمل Protected Routes في React؟**
> بتعمل `ProtectedRoute` component بيفحص الـ auth state: لو مش logged in بيـrender `<Navigate to="/login" replace />` وده بيعمل redirect فوراً. لو logged in بيـrender `<Outlet />` اللي بيعرض الـ child route. بتحط الـ protected routes كـ children للـ `ProtectedRoute` في الـ routing tree. بتستخدم `replace: true` عشان الـ back button ميرجعش لصفحة محمية بعد الـ redirect.

**س: ما الفرق بين `useNavigate(-1)` وإعادة navigate للـ home؟**
> `navigate(-1)` بيتحرك للخلف في الـ browser history — زي الضغط على Back. لو المستخدم جه من صفحة تانية، هيرجعها. لو مفيش history (فتح الصفحة مباشرةً)، ما بيحصل حاجة. `navigate('/')` بيروح للـ home بشكل explicit من غير ما يهتم بالـ history. الأولى أنسب في Cancel buttons، التانية أنسب بعد logout أو إجراء مهم.

**س: إيه الـ `<Navigate />` وامتى تستخدمه بدل `useNavigate()`؟**
> الاتنين بيعملوا نفس الشيء بس في سياقات مختلفة. `<Navigate />` هو component — بتستخدمه جوّا الـ JSX في حالات conditional rendering زي `isLoggedIn ? <Navigate to="/login" /> : <Dashboard />`. الـ `useNavigate()` هو hook — بتستخدمه جوّا event handlers وasync functions زي بعد submit form أو بعد API call. مش تقدر تستخدم hook جوّا JSX مباشرةً.

---

## 🛠️ Practical Exercise — TaskFlow بالـ Router كامل

### Task 1 — تنصيب وإعداد

```bash
npm install react-router-dom
```

في `main.jsx` لفّ التطبيق بـ `<BrowserRouter>`.

---

### Task 2 — ابني هيكل الـ Pages

```bash
mkdir src/pages src/layouts
touch src/pages/TaskBoard.jsx
touch src/pages/TaskDetails.jsx
touch src/pages/Settings.jsx
touch src/pages/NotFound.jsx
touch src/layouts/AppLayout.jsx
```

في `App.jsx`:

```jsx
import { Routes, Route } from 'react-router-dom';
import AppLayout    from './layouts/AppLayout';
import TaskBoard    from './pages/TaskBoard';
import TaskDetails  from './pages/TaskDetails';
import Settings     from './pages/Settings';
import NotFound     from './pages/NotFound';

function App() {
  return (
    <Routes>
      <Route path="/" element={<AppLayout />}>
        <Route index          element={<TaskBoard />}   />
        <Route path="tasks/:id" element={<TaskDetails />} />
        <Route path="settings"  element={<Settings />}   />
      </Route>
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}
```

في `AppLayout.jsx`:

```jsx
import { Outlet, NavLink } from 'react-router-dom';

function AppLayout() {
  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <aside style={{ width: 200, background: '#f5f5f5', padding: 16 }}>
        <h2>TaskFlow</h2>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <NavLink to="/"         end>📋 All Tasks</NavLink>
          <NavLink to="/settings">⚙️ Settings</NavLink>
        </nav>
      </aside>

      <main style={{ flex: 1, padding: 24 }}>
        <Outlet />
      </main>
    </div>
  );
}
```

---

### Task 3 — الـ Challenge: اربط الـ TaskCard بالـ TaskDetails

في `TaskBoard.jsx`، اجعل كل task card قابلة للضغط وتـnavigate لـ `/tasks/:id`:

```jsx
// hint: use <Link> or <useNavigate>
// hint: taskId from your API should go in the URL
// hint: in TaskDetails, use useParams() to get the id, then fetch the task
```

| السؤال | اللي تفكّر فيه |
|---|---|
| لو ضغطت Back بعد فتح task — فين هيرجع؟ | جرّب `navigate(-1)` بدل `navigate('/')` |
| لو فتحت `/tasks/99999` مباشرةً — إيه اللي المستخدم هيشوفه؟ | handle الـ 404 من الـ API |
| لو الـ Sidebar فيها active state — إيه اللي بيحصل على `/tasks/42`؟ | الـ root NavLink مش المفروض تكون active |

---

## 🫒 زتونة الإنترفيو

> **"React Router gives React the ability to map URLs to components — making a single-page app feel like a multi-page app without any server requests on navigation. The foundation is `<BrowserRouter>` wrapping the app, `<Routes>` containing route definitions, and each `<Route>` mapping a path to a component. For reading the URL: `useParams()` reads dynamic segments like `:id`, `useSearchParams()` reads query strings like `?status=open`, and `useLocation()` gives you the full URL object. For navigating: `<Link>` is the declarative way, `useNavigate()` is the programmatic way (after form submission, after login). Nested routes with `<Outlet>` let you build persistent layouts where only the inner content changes on navigation — the Navbar and Sidebar don't remount. Protected routes are just a component that checks auth state and renders either `<Navigate to='/login' />` or `<Outlet />`. Everything lives in the URL — that's what makes the app shareable and bookmarkable."**

---

*Next → [[06-Forms]] — الـ Forms: إزاي تستقبل input من المستخدم وتـvalidate وتبعته للـ API بطريقة صح.*
