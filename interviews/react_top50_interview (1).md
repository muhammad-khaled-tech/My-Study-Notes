# ⚛️ React — Top 50 Interview Questions
> مستخلص من ريبو [sudheerj/reactjs-interview-questions](https://github.com/sudheerj/reactjs-interview-questions) (44k ⭐)  
> مرتبين من الأشهر للأقل — ركّز على الـ Core أول

---

## 📦 SECTION 1 — React Fundamentals (الأساسيات اللي لازم تعرفها غيباً)

---

### 1. What is React?
React is an **open-source JavaScript library** for building user interfaces, developed by Facebook. It follows a **component-based architecture** and uses a **Virtual DOM** to efficiently update the UI.  
Key traits: declarative, component-based, unidirectional data flow.

---

### 2. What are the major features of React?
- **JSX** — syntax extension for writing HTML inside JS
- **Virtual DOM** — lightweight in-memory copy of real DOM
- **Component-based** — UI split into reusable pieces
- **Unidirectional Data Flow** — data flows parent → child
- **Server-Side Rendering (SSR)** — via Next.js or ReactDOMServer
- **Hooks** — use state & lifecycle in functional components

---

### 3. What is JSX?
JSX (JavaScript XML) is a syntax extension that lets you write HTML-like markup inside JavaScript. Browsers can't read JSX directly — **Babel** transpiles it to `React.createElement()` calls.

```jsx
// JSX
const element = <h1 className="title">Hello</h1>;

// After Babel transpilation:
const element = React.createElement('h1', { className: 'title' }, 'Hello');
```

---

### 4. What is the difference between Element and Component?

| | Element | Component |
|---|---|---|
| What | Plain object describing the DOM | Function or Class that returns Elements |
| Mutable? | Immutable | Has state, can re-render |
| Example | `<div>Hello</div>` | `function App() { return <div>Hello</div> }` |

---

### 5. What is the Virtual DOM? How does it work?
The Virtual DOM is a **lightweight JavaScript representation** of the real DOM. React keeps a virtual copy in memory.

**Reconciliation process:**
1. State changes → React creates a **new VDOM tree**
2. React **diffs** new tree vs old tree (diffing algorithm)
3. Only the **minimal set of real DOM changes** are applied (patching)

This is much faster than directly manipulating the real DOM every time.

---

### 6. What is the difference between Shadow DOM and Virtual DOM?

| | Virtual DOM | Shadow DOM |
|---|---|---|
| By | React (library concept) | Browser (native spec) |
| Purpose | Performance optimization | Encapsulation (CSS/DOM scoping) |
| Used in | React apps | Web Components |

---

### 7. What is React Fiber?
React Fiber is the **reimplemented reconciliation engine** introduced in React 16. It enables:
- **Incremental rendering** — split rendering work into chunks
- **Prioritization** — urgent updates (user input) interrupt less urgent ones (data fetch)
- **Pause, abort, or reuse** work as new updates come in
- Foundation for features like Suspense and Concurrent Mode

---

### 8. What is the difference between a Controlled and Uncontrolled Component?

**Controlled Component** — form data is handled by React state:
```jsx
const [value, setValue] = useState('');
<input value={value} onChange={e => setValue(e.target.value)} />
```

**Uncontrolled Component** — form data handled by the DOM via `ref`:
```jsx
const inputRef = useRef();
<input ref={inputRef} />
// Read: inputRef.current.value
```

> **Rule of thumb:** Prefer controlled — easier to validate & test.

---

### 9. What is the difference between `props` and `state`?

| | props | state |
|---|---|---|
| Owned by | Parent component | The component itself |
| Mutable by component? | ❌ Read-only | ✅ Yes, via setState/useState |
| Triggers re-render? | ✅ Yes | ✅ Yes |

---

### 10. Why should we not update state directly?

```jsx
// ❌ Wrong — React doesn't know state changed
this.state.count = 5;

// ✅ Correct — triggers re-render
this.setState({ count: 5 });
// or with hooks:
setCount(5);
```

Direct mutation bypasses React's change detection — the component won't re-render.

---

## 🎣 SECTION 2 — Hooks (أهم section في الإنترفيوهات الحديثة)

---

### 11. What are React Hooks? Why were they introduced?
Hooks are **functions** that let you use React state and lifecycle features inside **functional components**. Introduced in React 16.8.

**Problems they solved:**
- Avoid complex class components & `this` confusion
- Reuse stateful logic between components (custom hooks)
- Avoid HOC/render props "wrapper hell"

---

### 12. What does `useState` do?

```jsx
const [count, setCount] = useState(0);
// count  = current value
// setCount = setter function that triggers re-render
```

State updates are **asynchronous** and **batched** in React 18+.

---

### 13. What does `useEffect` do?

Handles **side effects** in functional components (data fetching, subscriptions, DOM manipulation).

```jsx
useEffect(() => {
  // runs after every render (default)
  document.title = `Count: ${count}`;

  return () => {
    // cleanup — runs before next effect OR on unmount
    subscription.unsubscribe();
  };
}, [count]); // dependency array — only re-run if count changes
```

**Dependency array variations:**
- `[]` — run once on mount (componentDidMount)
- `[dep]` — run on mount + when dep changes
- *(no array)* — run after **every** render

---

### 14. What is the difference between `useEffect` and `useLayoutEffect`?

| | `useEffect` | `useLayoutEffect` |
|---|---|---|
| When fires | After paint (async) | Before paint (sync) |
| Use case | Data fetching, subscriptions | DOM measurements, animations |
| Risk | None for most cases | Can block visual updates |

---

### 15. What does `useRef` do?

`useRef` returns a **mutable ref object** whose `.current` property persists across renders **without causing re-renders**.

Two main uses:
```jsx
// 1. Access DOM nodes directly
const inputRef = useRef(null);
<input ref={inputRef} />
inputRef.current.focus();

// 2. Store mutable value that doesn't trigger re-render
const timerRef = useRef(null);
timerRef.current = setInterval(...);
```

---

### 16. What does `useMemo` do?

**Memoizes the result** of an expensive computation — only recomputes when dependencies change.

```jsx
const expensiveResult = useMemo(() => {
  return heavyCalc(a, b);
}, [a, b]);
```

> Use when: computation is expensive AND deps don't change often.

---

### 17. What does `useCallback` do?

**Memoizes a function reference** — returns the same function instance unless dependencies change.

```jsx
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

> Useful when passing callbacks to child components wrapped in `React.memo` to prevent unnecessary re-renders.

---

### 18. What is the difference between `useMemo` and `useCallback`?

| | `useMemo` | `useCallback` |
|---|---|---|
| Returns | **Memoized value** (result) | **Memoized function** |
| Think of it as | `useMemo(() => fn(), deps)` | `useMemo(() => fn, deps)` |

---

### 19. What does `useContext` do?

Consumes a React Context without prop-drilling.

```jsx
// 1. Create
const ThemeContext = React.createContext('light');

// 2. Provide
<ThemeContext.Provider value="dark">
  <App />
</ThemeContext.Provider>

// 3. Consume
const theme = useContext(ThemeContext); // 'dark'
```

---

### 20. What are Custom Hooks?

Functions that start with `use` and encapsulate reusable stateful logic.

```jsx
function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(url)
      .then(r => r.json())
      .then(d => { setData(d); setLoading(false); });
  }, [url]);

  return { data, loading };
}

// Usage
const { data, loading } = useFetch('/api/users');
```

---

### 21. What are the rules of Hooks?

1. **Only call Hooks at the top level** — not inside loops, conditions, or nested functions
2. **Only call Hooks from React functions** — not from regular JavaScript functions

> React relies on the **call order** of hooks to track state correctly.

---

### 22. What is `useReducer`? When to use it over `useState`?

`useReducer` is an alternative to `useState` for **complex state logic**.

```jsx
const [state, dispatch] = useReducer(reducer, initialState);

function reducer(state, action) {
  switch (action.type) {
    case 'increment': return { count: state.count + 1 };
    case 'decrement': return { count: state.count - 1 };
    default: return state;
  }
}
```

**Prefer `useReducer` when:**
- State has multiple sub-values
- Next state depends on the previous state
- Complex update logic (think Redux-lite)

---

## 🏗️ SECTION 3 — Component Patterns & Lifecycle

---

### 23. What are the lifecycle methods of a class component?

```
MOUNTING:         constructor → render → componentDidMount
UPDATING:         render → componentDidUpdate
UNMOUNTING:       componentWillUnmount
ERROR:            componentDidCatch / getDerivedStateFromError
```

**Functional Hook Equivalents:**
- `componentDidMount` → `useEffect(() => {}, [])`
- `componentDidUpdate` → `useEffect(() => {}, [dep])`
- `componentWillUnmount` → `useEffect(() => { return cleanup }, [])`

---

### 24. What is `React.memo`?

A **Higher Order Component** that memoizes a functional component — prevents re-render if props haven't changed (shallow comparison).

```jsx
const MyComponent = React.memo(function MyComponent({ name }) {
  return <div>{name}</div>;
});
```

> Different from `useMemo`: `React.memo` wraps the **component**, `useMemo` memoizes a **value inside** a component.

---

### 25. What is a Higher-Order Component (HOC)?

A function that **takes a component and returns a new enhanced component**.

```jsx
function withLogger(WrappedComponent) {
  return function EnhancedComponent(props) {
    console.log('Rendering:', WrappedComponent.name);
    return <WrappedComponent {...props} />;
  };
}

const LoggedButton = withLogger(Button);
```

**Common examples:** `connect()` in Redux, `withRouter` in React Router.

---

### 26. What are render props?

A technique where a component receives a **function as a prop** that returns JSX, enabling logic sharing.

```jsx
<DataFetcher url="/api/users" render={(data) => (
  <UserList users={data} />
)} />
```

---

### 27. What are Pure Components?

`React.PureComponent` implements `shouldComponentUpdate` with a **shallow comparison** of props and state. If nothing changed, it skips re-render.

```jsx
class MyComponent extends React.PureComponent { ... }
// Functional equivalent: React.memo()
```

---

### 28. What is the purpose of `key` prop in lists?

Keys help React **identify which items changed, added, or removed** in a list. React uses keys during reconciliation to minimize DOM updates.

```jsx
// ❌ Bad — using index as key causes issues when list reorders
items.map((item, index) => <Item key={index} {...item} />)

// ✅ Good — use stable unique IDs
items.map(item => <Item key={item.id} {...item} />)
```

---

### 29. What is the `children` prop?

`children` is a special prop that represents whatever is nested between a component's opening and closing tags.

```jsx
function Card({ children }) {
  return <div className="card">{children}</div>;
}

<Card>
  <h1>Hello</h1>  {/* This is children */}
</Card>
```

---

### 30. What are Error Boundaries?

Class components that **catch JavaScript errors** in their child tree and display a fallback UI instead of crashing.

```jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, info) {
    logError(error, info);
  }

  render() {
    if (this.state.hasError) return <h1>Something went wrong.</h1>;
    return this.props.children;
  }
}
```

> ⚠️ Error boundaries do **NOT** catch: event handlers, async code, or errors in the boundary itself.

---

## 🌐 SECTION 4 — Context, State Management & Performance

---

### 31. What is Context API? When should you use it?

Context provides a way to pass data through the component tree **without prop drilling**.

```jsx
const UserContext = React.createContext(null);

// Provide at top level
<UserContext.Provider value={currentUser}>
  <App />
</UserContext.Provider>

// Consume anywhere below
const user = useContext(UserContext);
```

**Use when:** theme, locale, auth user, UI settings — data many components need at different nesting levels.

**Avoid when:** data is only needed 1-2 levels down (just use props).

---

### 32. What is the difference between Context API and Redux?

| | Context API | Redux |
|---|---|---|
| Best for | Simple global state | Complex state with many actions |
| Dev tools | Basic | Excellent (Redux DevTools) |
| Middleware | ❌ No built-in | ✅ Thunk, Saga, etc. |
| Boilerplate | Low | Higher |
| Performance | Re-renders all consumers on change | Selective subscription |

---

### 33. What is `React.lazy` and `Suspense`?

**Code splitting** — load components only when needed.

```jsx
const LazyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
    </Suspense>
  );
}
```

`Suspense` shows the fallback UI while the lazy component is loading.

---

### 34. What is prop drilling? How do you avoid it?

**Prop drilling** = passing props through multiple intermediate components that don't need them, just to reach a deeply nested component.

**Solutions:**
1. **Context API** — for shared global-ish state
2. **Redux / Zustand** — for complex app state
3. **Component composition** — restructure components

---

### 35. How do you prevent unnecessary re-renders?

- `React.memo` — memoize functional components
- `useMemo` — memoize expensive computed values
- `useCallback` — memoize callbacks passed to children
- `useReducer` over `useState` for complex state
- Avoid creating new objects/arrays inline in JSX props
- Split large components into smaller focused ones

---

## 🔀 SECTION 5 — React Router

---

### 36. What is React Router?

A library for **declarative routing** in React applications. It keeps UI in sync with the URL.

```jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

<BrowserRouter>
  <Routes>
    <Route path="/" element={<Home />} />
    <Route path="/about" element={<About />} />
    <Route path="/user/:id" element={<User />} />
  </Routes>
</BrowserRouter>
```

---

### 37. What is the difference between `BrowserRouter` and `HashRouter`?

| | BrowserRouter | HashRouter |
|---|---|---|
| URL style | `/about` | `/#/about` |
| Needs server config | ✅ Yes (handle 404s) | ❌ No |
| SEO | Better | Worse |

---

### 38. How do you programmatically navigate in React Router v6?

```jsx
import { useNavigate } from 'react-router-dom';

function LoginPage() {
  const navigate = useNavigate();

  const handleLogin = () => {
    // ... login logic
    navigate('/dashboard');
    // or navigate(-1) to go back
  };
}
```

---

### 39. What are route parameters? How do you access them?

```jsx
// Route definition
<Route path="/user/:id" element={<User />} />

// Inside User component
import { useParams } from 'react-router-dom';
const { id } = useParams();
```

---

### 40. What is a Protected Route?

A route that redirects unauthenticated users to a login page.

```jsx
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" />;
}

<Route path="/dashboard" element={
  <ProtectedRoute><Dashboard /></ProtectedRoute>
} />
```

---

## 🧰 SECTION 6 — Advanced Concepts

---

### 41. What are Fragments?

Fragments let you **group multiple elements without adding extra DOM nodes**.

```jsx
// Long form
<React.Fragment>
  <td>Name</td>
  <td>Age</td>
</React.Fragment>

// Short form (most common)
<>
  <td>Name</td>
  <td>Age</td>
</>
```

---

### 42. What are Portals?

Portals render children **outside the parent DOM hierarchy** while maintaining React's event bubbling.

```jsx
ReactDOM.createPortal(
  <Modal />,
  document.getElementById('modal-root')
)
```

**Use case:** Modals, tooltips, dropdowns — elements that need to visually escape overflow:hidden containers.

---

### 43. What is `forwardRef`?

Lets a parent component **pass its ref down to a child** component's DOM element.

```jsx
const FancyInput = React.forwardRef((props, ref) => (
  <input ref={ref} {...props} />
));

// Parent usage
const inputRef = useRef();
<FancyInput ref={inputRef} />
inputRef.current.focus(); // works!
```

---

### 44. What is the difference between `componentDidMount` and `useEffect`?

| | `componentDidMount` | `useEffect(() => {}, [])` |
|---|---|---|
| Timing | After first render | After first render (same) |
| Component type | Class only | Functional only |
| Cleanup | `componentWillUnmount` | Return function from useEffect |
| Runs twice in StrictMode? | ❌ No | ✅ Yes (in dev only) |

---

### 45. What is StrictMode?

A **development-only** tool that helps find problems in your app by intentionally double-invoking lifecycle methods and hooks.

```jsx
<React.StrictMode>
  <App />
</React.StrictMode>
```

**What it detects:**
- Unsafe lifecycle methods
- Legacy string ref API usage
- Deprecated findDOMNode
- Unexpected side effects (by running effects twice in dev)

---

### 46. What is the difference between `createElement` and `cloneElement`?

```jsx
// createElement — creates a new element from scratch
React.createElement(Button, { color: 'red' }, 'Click me');

// cloneElement — clones existing element and merges new props
React.cloneElement(existingButton, { color: 'blue' });
```

`cloneElement` is used in HOC patterns and compound components.

---

### 47. What are Synthetic Events in React?

React wraps native browser events in a **SyntheticEvent** — a cross-browser wrapper with the same interface as native events.

```jsx
// e is SyntheticEvent, not a native DOM event
function handleClick(e) {
  e.preventDefault(); // works cross-browser
  console.log(e.target.value);
}
```

As of React 17, events are attached to the **root container** (not `document`), improving isolation for micro-frontends.

---

### 48. What is reconciliation?

Reconciliation is React's algorithm for **updating the DOM** efficiently. When state/props change:

1. React builds a **new VDOM tree**
2. **Diffs** it against the old tree using the heuristics:
   - Different element type → destroy old, build new
   - Same element type → update attributes only
   - Lists → use `key` prop for matching
3. Applies only the **minimum DOM changes**

---

### 49. What are the differences between React 17 and React 18?

| Feature | React 17 | React 18 |
|---|---|---|
| Root API | `ReactDOM.render()` | `ReactDOM.createRoot()` |
| Automatic Batching | ❌ Only in event handlers | ✅ All async contexts |
| Concurrent Features | ❌ | ✅ `useTransition`, `useDeferredValue` |
| Suspense SSR | Limited | Full streaming SSR |
| `useId` hook | ❌ | ✅ |

---

### 50. What is `useTransition` in React 18?

`useTransition` marks state updates as **non-urgent** — letting React keep the UI responsive while they compute.

```jsx
const [isPending, startTransition] = useTransition();

function handleSearch(value) {
  // Urgent: update input immediately
  setQuery(value);

  // Non-urgent: can be interrupted
  startTransition(() => {
    setSearchResults(heavyFilter(value));
  });
}

// Show loading indicator while transitioning
{isPending && <Spinner />}
```

---

## 🫒 زتونة الإنترفيو (The Golden Cheat Sheet)

```
الـ 10 اللي بتجوا دايماً:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Virtual DOM  →  diff + patch, لا بيمسّ الـ real DOM غير اللي اتغيّر
2. Controlled vs Uncontrolled  →  state vs ref
3. useEffect deps  →  [] once, [dep] on change, nothing = always
4. useMemo vs useCallback  →  value vs function
5. keys in lists  →  stable unique IDs, never index
6. memo / useMemo / useCallback  →  تلاتتهم بيمنعوا re-render بس بطرق مختلفة
7. Context vs Redux  →  simple sharing vs complex state machine
8. Error Boundaries  →  class only, catches child errors, not async
9. Hooks rules  →  top level + React functions فقط
10. React 18  →  createRoot + automatic batching + useTransition

الفرق الفكري اللي بيعجب الإنترفيو:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• React بـ declarative — بتقوله "شيل إيه" مش "إزاي تشيله"
• Fiber = React scheduler — بيقدر يوقف الشغل ويكمله بعدين
• useEffect بيشتغل AFTER paint — لو محتاج قبل paint → useLayoutEffect
• forwardRef لما الـ parent محتاج يوصل لـ DOM node جوّه الـ child
• Portals بتبني جوّه React tree بس خارج الـ DOM tree
```

---

> 📌 **Source:** [sudheerj/reactjs-interview-questions](https://github.com/sudheerj/reactjs-interview-questions) — 44.6k ⭐  
> ✨ Good luck in your interview! أنت أكيد جاهز 🔥
