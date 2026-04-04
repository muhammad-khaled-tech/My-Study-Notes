# File: 04-The-Escape-Hatch-useEffect-useRef.md

> **المتطلبات:** [[01-React-Anatomy-and-JSX]] و [[02-State-Machines-useState-useReducer]] — لازم تعرف إزاي React بتفكّر في الـ render cycle وإزاي الـ state بتتغير. الفصل ده هو اللي بتخرج فيه من sandbox React وبتلمس العالم الحقيقي.

---

## المشكلة — React عندها قاعدة واحدة صارمة

خليني أقولك على المبدأ الأساسي في React Fiber.

React بتبني الـ UI بطريقة معينة: بتاخد الـ state والـ props، وبتشغّل الـ component function، وبترجع JSX — وده بيتكرر في كل مرة حاجة بتتغير. الـ Fiber scheduler بيشتغل على الـ concept ده:

```
Input (state + props) → Pure Function → Output (JSX)
```

الكلمة المهمة هنا: **Pure Function.** يعني لو شغّلتها مرتين بنفس الـ input، المفروض ترجع نفس الـ output — من غير ما تعمل أي حاجة تانية في العالم. مش بتكلّم API، مش بتسجّل في database، مش بتعمل timer، مش بتلمس الـ DOM.

بس في الحياة الحقيقية — كل app محتاج يعمل الحاجات دي.

وده هو التناقض اللي محتاج حل.

---

## الأنالوجي — مصنع السيارات

تخيّل معايا إنك بتشتغل في مصنع سيارات. في خط الإنتاج (assembly line)، الشغل بيمشي بـ خطوات محددة ومتسلسلة — كل روبوت بيعمل حاجة واحدة بالظبط وبيمشّي الشغلانة للتالت. مفيش حد يتوقف خط الإنتاج عشان يعمل مكالمة تليفون.

بس المصنع كمان محتاج:
- **sensors** بترصد درجة الحرارة وتبعت alerts
- **أجهزة قياس** تسجّل كل العمليات في سجلات خارجية
- **safety valves** تقفل لو حاجة اتعملت غلط

الـ sensors دي مش جزء من خط الإنتاج — هي بتشتغل **بعد** كل batch وبتبلّغ عن النتيجة. وكل sensor عنده **threshold** — بيشتغل بس لو قيمة معينة اتغيّرت.

في React:
- خط الإنتاج = الـ render function
- الـ sensors = `useEffect`
- الـ thresholds = الـ dependency array
- قفل الـ safety valve قبل ما تعمل شغلانة جديدة = الـ cleanup function

---

## [[useEffect]] — السنسور الرسمي في React

### إزاي React Fiber بتتعامل مع الـ Effects داخلياً

قبل ما نكتب سطر كود، لازم تعرف الـ React Fiber بتخزّن الـ effects فين وامتى بتشغّلها.

كل component في React ليه **Fiber Node** — object داخلي في الـ memory بيخزّن كل حاجة عن الـ component: الـ state، الـ props، الـ hooks، وقائمة الـ effects.

```
Fiber Node (internal representation):
{
  type: UserProfile,
  stateNode: ...,
  memoizedState: ...,   // linked list of all hooks (useState, useEffect, etc.)
  updateQueue: ...,     // pending state updates
  effectTag: ...,       // flags like: HAS_EFFECT, NEEDS_UPDATE, etc.
}
```

لما بتكتب `useEffect`، React مش بتشغّله على طول. بتحطّه في **effect queue** — قائمة انتظار. وبعدين بعد ما الـ browser يرسم (paint) الـ UI، يعني بعد ما المستخدم يشوف الصفحة، بتيجي React وبتشغّل الـ effects اللي في الـ queue.

```
React renders the component
         ↓
React updates the DOM
         ↓
Browser PAINTS the screen (user sees it)
         ↓
React flushes the effect queue (useEffect runs HERE)
```

ده مهم جداً. `useEffect` مابيشتغلش أثناء الـ render. بيشتغل **بعد** الـ paint. عشان كده لو عندك side effect بيأخد وقت (زي fetch) — المستخدم هيشوف الـ UI الأول وبعدين الـ data بتييجي.

> **ملاحظة:** في `useLayoutEffect` — اللي بيشتغل **قبل** الـ paint بس **بعد** الـ DOM update. دي لحالات تانية. الـ `useEffect` هو اللي بتستخدمه في 95% من الحالات.

---

### الـ Anatomy — التشريح سطر بسطر

```jsx
useEffect(() => {
  // [A] Effect body — runs after paint
}, [/* B — dependency array */]);
```

بس، خليني أكسر الموضوع أكتر.

**الجزء [A]: Effect Body**

```jsx
useEffect(() => {
  // Everything in here runs AFTER the browser paints
  // This is where you talk to the outside world:
  // — fetch data from an API
  // — add an event listener to window
  // — start a timer
  // — connect to a WebSocket
  // — initialize a third-party library (Chart.js, Google Maps, etc.)
});
```

**الـ Cleanup — جزء الـ [A] التاني:**

```jsx
useEffect(() => {
  // [A1] Setup: do the thing
  const subscription = subscribeToChannel('chat-room-1');

  // [A2] Cleanup: undo the thing
  return () => {
    subscription.unsubscribe();
  };
  // React calls this cleanup function:
  // — Before running the effect again (if deps changed)
  // — When the component unmounts (removed from DOM)
});
```

الـ cleanup زي الـ safety valve في المصنع — قبل ما أي batch جديد يبدأ، الـ valve القديم لازم يقفل. مش optional، ده responsibility.

---

### الـ Dependency Array — "الـ Threshold بتاع السنسور"

ده القلب. وفيه قاعدة داخلية لازم تعرفها.

لما React بتحدد "هل الـ deps اتغيّرت؟" — مش بتعمل deep comparison ومش بتستخدم `===` العادية. بتستخدم **`Object.is()`**.

```javascript
// Object.is() — how React compares dependencies

Object.is(1, 1);          // true  — same value
Object.is('hi', 'hi');    // true  — same string
Object.is(true, false);   // false — different

// The tricky cases:
Object.is(NaN, NaN);      // true  — unlike ===, which returns false for NaN
Object.is(0, -0);         // false — unlike ===, which returns true

// The most important case for you as a developer:
Object.is({}, {});        // false — two different object references
Object.is([], []);        // false — two different array references
```

الآخر ده هو أكتر source لـ bugs في `useEffect`. لو حطيت object أو array في الـ dependency array — هيتعدّ كـ "تغيّر" في كل render لأن في كل render بيتعمل object جديد.

```jsx
// ❌ This effect runs on EVERY render — not just when filter changes
function ProductList({ filter }) {
  useEffect(() => {
    fetchProducts(filter);
  }, [filter]); // Looks fine...
}

// But if the PARENT does this:
<ProductList filter={{ category: 'shoes' }} />
// Every render creates a NEW object — Object.is({...}, {...}) = false
// Effect runs every time
```

الحل ده موضوعه في الـ Module بتاع `useMemo`. بس المهم دلوقتي تعرف إن React بتستخدم `Object.is()` مش deep equality.

---

### الـ 3 أشكال بتاعة الـ Dependency Array

**الشكل الأول: مفيش array خالص**

```jsx
useEffect(() => {
  console.log('Runs after EVERY single render');
});
// The sensor has no threshold — fires after every production batch
// Rarely useful, usually a design smell
```

**الشكل الثاني: Array فاضية**

```jsx
useEffect(() => {
  console.log('Runs once — after the first render only');
}, []);
// The sensor fires once when the factory starts, then goes silent
// Use for: initial data fetch, one-time subscriptions, third-party lib setup
```

**الشكل الثالث: Array فيها values**

```jsx
useEffect(() => {
  console.log(`userId changed — now it's: ${userId}`);
}, [userId]);
// The sensor watches a specific measurement
// Fires after mount + any time userId changes (compared with Object.is)
```

---

### مثال 1 — Data Fetching

بص على الفرق بين الطريقتين.

**الطريقة الكارثية:**

```jsx
// ❌ WRONG — side effect inside the render function
function UserProfile({ userId }) {
  let user = null;

  // This runs on every render
  // And calling setUser triggers another render → infinite loop
  fetch(`/api/users/${userId}`)
    .then(r => r.json())
    .then(data => setUser(data));

  return <div>{user?.name}</div>;
}
```

خد بالك: مش بس هيعمل infinite loop — ده كمان بيخرق الـ React Fiber model. الـ render function المفروض تبقى pure. الـ fetch ده side effect وليه مكانه الصح.

**الطريقة الصح، خطوة بخطوة:**

الخطوة الأولى — جهّز الـ state:

```jsx
function UserProfile({ userId }) {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);
  // Three separate pieces of state — each controls a different part of the UI
```

الخطوة التانية — اكتب الـ effect:

```jsx
  useEffect(() => {
    // Reset state when userId changes — before the new fetch starts
    setLoading(true);
    setError(null);

    fetch(`/api/users/${userId}`)
      .then(res => {
        if (!res.ok) throw new Error('User not found');
        return res.json();
      })
      .then(data => {
        setUser(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });

  }, [userId]); // Re-runs when userId changes
```

الخطوة التالتة — الـ render:

```jsx
  if (loading) return <p>Loading...</p>;
  if (error)   return <p>Error: {error}</p>;
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

---

### الـ Race Condition — المشكلة اللي مش واضحة

الكود اللي فوق فيه مشكلة خفية. تخيّل المستخدم بدّل الـ `userId` بسرعة:

```
userId = 1 → fetch starts (network is slow, takes 3 seconds)
userId = 2 → fetch starts (network is fast, takes 0.3 seconds)

Arrival order:
  userId=2 data arrives: setUser(user2) ✅ correct
  userId=1 data arrives: setUser(user1) ❌ wrong! old data wins!
```

الحل: `AbortController`.

```jsx
useEffect(() => {
  const controller = new AbortController();
  setLoading(true);

  fetch(`/api/users/${userId}`, { signal: controller.signal })
    .then(res => res.json())
    .then(data => {
      setUser(data);
      setLoading(false);
    })
    .catch(err => {
      // Ignore the error if WE cancelled the request intentionally
      if (err.name !== 'AbortError') {
        setError(err.message);
        setLoading(false);
      }
    });

  return () => {
    // Cleanup: cancel the in-flight request before the next effect runs
    controller.abort();
  };

}, [userId]);
```

لما `userId` تتغير، React بتشغّل الـ cleanup أول — فبتعمل `abort()` على الـ request القديمة — وبعدين بتشغّل الـ effect الجديد بالـ `userId` الجديدة. الـ race condition اتحلت.

---

### الـ Stale Closure — التنين اللي جوّه الـ Closures

ده أصعب bug في `useEffect` وأكتر حاجة بتلخبط الناس.

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      console.log(count); // Always prints 0
      setCount(count + 1); // Always sets to 1
    }, 1000);

    return () => clearInterval(interval);
  }, []); // Empty array — runs once

  return <div>{count}</div>;
}
```

إيه اللي بيحصل جوّا؟

لما الـ effect اشتغل لأول مرة، الـ callback بتاع `setInterval` "اتشبك" بـ `count` اللي كانت قيمتها `0` في اللحظة دي. ده الـ JavaScript closure العادي. بما إن الـ effect مابيشتغلش تاني (empty deps) — الـ closure فضل بيشاور على `count = 0` للأبد.

الـ Fiber node بيتحدث بـ `count` الجديدة في كل render — بس الـ closure اللي جوّا الـ interval مش عارف يشوف ده.

**الحل — Functional Update:**

```jsx
useEffect(() => {
  const interval = setInterval(() => {
    // Don't read count from the closure
    // Ask React for the LATEST value instead
    setCount(prevCount => prevCount + 1);
    // React passes the current value as prevCount — no closure involved
  }, 1000);

  return () => clearInterval(interval);
}, []); // Safe now — we're not depending on count
```

لما بتستخدم `setState(prev => ...)` — مش بتقرأ الـ state من الـ closure. بتطلب من React نفسها تديك أحدث قيمة في اللحظة دي.

---

### React 18 StrictMode — ليه الـ Effect بيشتغل مرتين في الـ Dev؟

لو لاحظت في development إن الـ effect بتاعك بيشتغل مرتين — ده مش bug. ده feature.

React 18 في `StrictMode` بتعمل الآتي عمداً:

```
Mount → run effect → run cleanup → run effect again
```

بتعمل ده عشان تتأكد إن الـ cleanup function بتاعتك صح ومش هتخلّي أي resource معلّق. لو الـ app بتاعك بيتكسر بسبب ده — معناه عندك cleanup ناقصة.

في production: الـ effect بيشتغل مرة واحدة بس.

---

## [[useRef]] — الـ Sticky Note على جنب المكنة

### المشكلة اللي `useState` مش بتحلّها

`useState` عندها عقد واضح: "لو بيانات بتاعتك اتغيّرت، هأعمل re-render عشان الـ UI يتحدث."

بس أحياناً محتاج تحفظ حاجة من غير ما تعمل re-render. زي إنك بتكتب ملاحظة على ورقة جانبية — مش بتعلّق الكلام في وسط خط الإنتاج.

الحالات دي:
- مرجع لـ DOM element عشان تعمل `.focus()` أو `.scrollIntoView()`
- الـ ID بتاع `setInterval` — محتاجه في الـ cleanup بس مش بتعرضه
- الـ previous value من render فات
- عداد renders للـ debugging

---

### الـ Internal Representation

`useRef` في الـ Fiber هو ببساطة:

```javascript
// What React stores for useRef(initialValue):
{
  current: initialValue
}
// That's it. A plain object.
// React doesn't watch it, doesn't proxy it, doesn't react to changes in .current
// It's just a stable box that survives re-renders
```

الـ object نفسه بيفضل **نفس الـ object** طول عمر الـ component — مش بيتعمل جديد في كل render. وأي تغيير في `.current` مابيلفتش نظر React خالص.

---

### الاستخدام الأول — الوصول لـ DOM Elements

**الطريقة القديمة المتكسرة:**

```jsx
// ❌ Reaching past React directly into the DOM
function SearchBox() {
  function handleClick() {
    document.getElementById('search').focus();
    // Works, but you're bypassing React completely
    // React doesn't know you touched the DOM — can cause subtle bugs
  }
  return <input id="search" type="text" />;
}
```

**الطريقة الصح:**

الخطوة الأولى — عمل الـ ref:

```jsx
import { useRef } from 'react';

function SearchBox() {
  // Starts as null — the DOM element doesn't exist yet during this line
  const inputRef = useRef(null);
```

الخطوة التانية — ربطه بالـ JSX:

```jsx
  return (
    <input
      ref={inputRef}  // React will set inputRef.current = this DOM node after mount
      type="text"
      placeholder="Search..."
    />
  );
```

الخطوة التالتة — استخدامه:

```jsx
  function handleFocusClick() {
    // After mount, inputRef.current IS the actual <input> DOM element
    inputRef.current.focus();
    inputRef.current.select(); // select all text
    inputRef.current.scrollIntoView(); // scroll the element into view
  }
```

إيه اللي React بتعمله داخلياً؟

```
React renders JSX → sees ref={inputRef} attribute
     ↓
React builds the DOM node
     ↓
React sets inputRef.current = the actual DOM node
     ↓
Now inputRef.current gives you direct access to the real DOM element
```

---

### مثال — Video Player

ده مثال بيوضّح إن `useRef` بيديك قوة الـ imperative DOM API في قلب الـ declarative React:

```jsx
import { useRef } from 'react';

function VideoPlayer({ src }) {
  const videoRef = useRef(null);

  // These are imperative commands — not state updates
  // React doesn't know or care that the video is playing
  // It's the DOM's job to manage that
  const play  = () => videoRef.current.play();
  const pause = () => videoRef.current.pause();
  const skip  = (seconds) => {
    videoRef.current.currentTime += seconds;
  };

  return (
    <div>
      <video ref={videoRef} src={src} />
      <button onClick={play}>▶ Play</button>
      <button onClick={pause}>⏸ Pause</button>
      <button onClick={() => skip(10)}>+10s ⏩</button>
      <button onClick={() => skip(-10)}>⏪ -10s</button>
    </div>
  );
}
```

---

### الاستخدام الثاني — تخزين قيم بين الـ Renders بدون Re-render

**المشكلة:**

```jsx
// ❌ WRONG — using state for an interval ID
function Timer() {
  const [intervalId, setIntervalId] = useState(null);
  const [count, setCount]           = useState(0);

  function start() {
    const id = setInterval(() => setCount(c => c + 1), 1000);
    setIntervalId(id); // This triggers a re-render — unnecessary
                       // The UI doesn't need to display the interval ID
  }

  function stop() {
    clearInterval(intervalId);
  }
}
```

**الحل:**

```jsx
// ✅ CORRECT — interval ID is internal bookkeeping, not UI state
function Timer() {
  const [count, setCount]   = useState(0);
  const intervalRef         = useRef(null); // Not state — no re-render on change

  function start() {
    intervalRef.current = setInterval(() => setCount(c => c + 1), 1000);
    // Stored in the ref — survives re-renders, doesn't cause one
  }

  function stop() {
    clearInterval(intervalRef.current);
  }

  return (
    <div>
      <p>{count}s</p>
      <button onClick={start}>Start</button>
      <button onClick={stop}>Stop</button>
    </div>
  );
}
```

---

### الاستخدام التالت — الـ Previous Value Pattern

```jsx
import { useRef, useEffect } from 'react';

// A reusable hook to get the value from the previous render
function usePrevious(value) {
  const ref = useRef(undefined);

  useEffect(() => {
    // This runs AFTER render — so during this render,
    // ref.current still holds the OLD value
    ref.current = value;
  }); // No deps — updates after every render

  // Returns the value from the PREVIOUS render
  return ref.current;
}
```

```jsx
// Usage
function PriceDisplay({ price }) {
  const previousPrice = usePrevious(price);

  const isUp   = price > previousPrice;
  const isDown = price < previousPrice;

  return (
    <div>
      <span style={{ color: isUp ? 'green' : isDown ? 'red' : 'black' }}>
        ${price}
      </span>
      <small> (was ${previousPrice})</small>
    </div>
  );
}
```

الـ trick هنا: الـ `useEffect` بيشتغل **بعد** الـ render. فلحظة ما الـ component بيـ render، `ref.current` لسّه بيشاور على القيمة القديمة. بعد الـ render بيتحدث للجديدة. يعني في أي render: بتقرأ القديمة، وبعدين بتحدّث للجديدة عشان الـ render الجاي.

---

### `useState` vs `useRef` — متى تختار أيهما؟

سؤال واحد بس بيحل الموضوع:

```
"لو القيمة دي اتغيّرت، المستخدم المفروض يشوف حاجة اتغيّرت في الـ UI؟"

YES → useState
NO  → useRef
```

| السيناريو | الأداة |
|---|---|
| عداد بيتعرض على الشاشة | `useState` |
| Interval ID محتاج أعمل `clearInterval` بيه | `useRef` |
| Loading state بيظهر spinner | `useState` |
| مرجع لـ `<input>` عشان أعمل `.focus()` | `useRef` |
| اسم المستخدم في الـ UI | `useState` |
| Previous value للمقارنة الداخلية | `useRef` |
| عداد renders للـ debugging | `useRef` |
| Error message بيتعرض للمستخدم | `useState` |

---

## الصورة الكاملة — إزاي الاتنين بيكمّلوا بعض

```
┌─────────────────────────────────────────────────────────┐
│                 REACT FIBER NODE                        │
│                                                         │
│  memoizedState: [useState hook] → [useRef hook] → ...  │
│                   ↑ triggers re-render    ↑ silent      │
│                                                         │
│  effectList:   [useEffect #1] → [useEffect #2] → ...   │
│                  ↑ scheduled for AFTER paint            │
└──────────────────────────────┬──────────────────────────┘
                               │
                    After browser paints
                               │
                               ▼
              ┌────────────────────────────┐
              │   useEffect runs           │
              │   — can read ref.current   │
              │   — can call setState      │
              │   — can touch outside world│
              └────────────┬───────────────┘
                           │
                           ▼
              ┌────────────────────────────┐
              │     OUTSIDE WORLD          │
              │  APIs, DOM, Timers,        │
              │  WebSockets, Libraries     │
              └────────────────────────────┘
```

---

## Old Way ❌ vs Modern Way ✅

### Data Fetching

```jsx
// ❌ OLD WAY — Class Component lifecycle methods
class UserList extends React.Component {
  state = { users: [], loading: true };

  componentDidMount() {
    // Runs once after mount — but no built-in cancellation
    fetch('/api/users')
      .then(r => r.json())
      .then(users => this.setState({ users, loading: false }));
  }

  componentDidUpdate(prevProps) {
    // Manual comparison — easy to forget or get wrong
    if (prevProps.filter !== this.props.filter) {
      fetch(`/api/users?filter=${this.props.filter}`)
        .then(r => r.json())
        .then(users => this.setState({ users }));
      // No cleanup — race condition is always possible here
    }
  }

  // componentWillUnmount exists but you've already lost the fetch reference
}
```

```jsx
// ✅ MODERN WAY — useEffect with proper cleanup
function UserList({ filter }) {
  const [users, setUsers]     = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);

    fetch(`/api/users?filter=${filter}`, { signal: controller.signal })
      .then(r => r.json())
      .then(data => {
        setUsers(data);
        setLoading(false);
      })
      .catch(err => {
        if (err.name !== 'AbortError') setLoading(false);
      });

    return () => controller.abort(); // Automatic cleanup — no manual comparison needed

  }, [filter]); // Object.is(prevFilter, newFilter) — re-runs only when filter truly changes
}
```

### DOM Access

```jsx
// ❌ OLD WAY — direct DOM query
function LoginForm() {
  function handleError() {
    document.querySelector('#email').focus(); // bypasses React
  }
  return <input id="email" type="email" />;
}
```

```jsx
// ✅ MODERN WAY — useRef
function LoginForm() {
  const emailRef = useRef(null);

  function handleError() {
    emailRef.current.focus(); // React-aware, predictable
  }

  return <input ref={emailRef} type="email" />;
}
```

---

## 🫒 زتونة الإنترفيو

> **`useEffect` is React's mechanism for synchronizing a component with systems that live outside React's render cycle. Internally, React Fiber schedules effects into an effect queue and flushes them after the browser has painted — this is why `useEffect` is called a "passive effect." Dependency comparison uses `Object.is()`, not deep equality — meaning object and array literals in the dependency array will always be treated as "changed" since each render creates a new reference. The cleanup function returned from an effect is invoked by React before the next effect run and on unmount, which is the correct place to cancel fetch requests via `AbortController`, clear timers, and unsubscribe from event listeners. The stale closure problem — where an effect captures an outdated variable value — is resolved either by adding the variable to the dependency array (so the effect re-runs with fresh data) or by using functional state updates (`setState(prev => ...)`) which bypass the closure by asking React for the current value at call time. In React 18 StrictMode, effects are intentionally mounted, cleaned up, and mounted again in development to surface missing cleanup logic. `useRef`, on the other hand, returns a plain stable object `{ current: value }` that persists for the entire component lifetime without triggering re-renders on mutation — React stores it in the Fiber's `memoizedState` linked list but places no reactive proxy around it. Its two canonical uses are: holding a reference to a real DOM node (assigned automatically when you pass the ref to a JSX element's `ref` prop) and persisting mutable implementation details across renders — interval IDs, previous values, scroll positions — that the UI doesn't need to display but the component logic depends on. The decision rule between the two: if a changing value must update what the user sees, use `useState`; if it's internal bookkeeping invisible to the user, use `useRef`.**

---

## ✅ Checkpoint

| السؤال | الإجابة المتوقعة |
|---|---|
| امتى بالظبط بيشتغل `useEffect`؟ | بعد ما الـ browser يرسم (paint) الـ UI — مش أثناء الـ render |
| React بتقارن الـ dependencies بإيه؟ | بـ `Object.is()` — مش deep equality ومش `===` العادية |
| ليه object literal في الـ deps array مشكلة؟ | لأن كل render بيعمل object جديد — `Object.is({}, {}) = false` دايماً |
| إيه الـ Race Condition وإزاي تحلها؟ | طلبين بيتسابقوا والأبطأ يغلب الأحدث. الحل: `AbortController` في الـ cleanup |
| إيه الـ Stale Closure وإزاي تحلها؟ | الـ effect بيلتقط قيمة قديمة من الـ closure. الحل: functional `setState(prev => ...)` |
| ليه `useEffect` بيشتغل مرتين في dev؟ | React 18 StrictMode بيعمل ده عمداً عشان يكشف missing cleanup |
| إيه الفرق الجوهري بين `useState` و `useRef`؟ | تغيير `state` يعمل re-render. تغيير `ref.current` لا. |
| إيه الـ previous value pattern وإزاي بيشتغل؟ | `useEffect` بيشتغل بعد الـ render — فالـ ref بيتقرأ بالقيمة القديمة ثم بيتحدث للجديدة بعد الـ render |
| إيه الفرق بين `useEffect` و `useLayoutEffect`؟ | `useEffect` بيشتغل بعد الـ paint. `useLayoutEffect` بيشتغل بعد الـ DOM update بس قبل الـ paint |

---

## 🛠️ Practical Lab

### Task 1 — اقرأ وتوقع

اقرأ الكود ده وجاوب على الأسئلة:

```jsx
function MysteryComponent({ query }) {
  const [results, setResults] = useState([]);
  const callCount             = useRef(0);
  const inputRef              = useRef(null);

  useEffect(() => {
    callCount.current += 1;

    const controller = new AbortController();

    fetch(`/api/search?q=${query}`, { signal: controller.signal })
      .then(r => r.json())
      .then(data => setResults(data))
      .catch(err => {
        if (err.name !== 'AbortError') console.error(err);
      });

    return () => controller.abort();
  }, [query]);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return (
    <div>
      <input ref={inputRef} value={query} readOnly />
      <p>Fetched {callCount.current} times</p>
      <ul>{results.map((r, i) => <li key={i}>{r.title}</li>)}</ul>
    </div>
  );
}
```

**الأسئلة:**
1. `callCount.current` بيتعرض في الـ UI — بس لو اتغيّر، هل الـ UI بيتحدث؟ ليه؟
2. لو `query` اتغيّرت 3 مرات — الـ fetch effect اشتغل كام مرة؟
3. لو المستخدم غيّر الـ `query` وهو الـ request لسّه ما رجعتش — إيه اللي هيحصل للـ request القديمة؟
4. الـ `inputRef` بيعمل focus امتى بالظبط؟

---

### Task 2 — Fix the Bugs

في الكود ده 3 bugs. حددهم واشرح ليه كل واحد bug، وبعدين صلّحهم:

```jsx
// BUGGY CODE
function LivePrice({ symbol }) {
  const [price, setPrice] = useState(0);

  // Bug 1 — async directly in useEffect
  useEffect(async () => {
    const data = await fetch(`/api/price/${symbol}`).then(r => r.json());
    setPrice(data.price);
  }, []);

  // Bug 2 — stale closure
  useEffect(() => {
    const interval = setInterval(() => {
      setPrice(price + (Math.random() - 0.5));
    }, 1000);
  }, []);

  // Bug 3 — missing dependency array
  useEffect(() => {
    document.title = `${symbol}: $${price.toFixed(2)}`;
  });

  return <h2>{symbol}: ${price.toFixed(2)}</h2>;
}
```

---

### Task 3 — ابني من الصفر

ابني component اسمه `<GitHubCard username="gaearon" />` بالمتطلبات دي:

```
API: https://api.github.com/users/{username}

1. اجيب: name, avatar_url, public_repos, followers, html_url

2. Handle: loading state, error state, 404

3. لو username اتغيّر → اجيب data جديدة
   (اعمل input يخلي المستخدم يغيّر الـ username)

4. استخدم AbortController في الـ cleanup

5. بعد ما الـ data تييجي، اعمل focus تلقائي
   على زرار "Visit Profile" — باستخدام useRef

6. document.title يتغير لـ "GitHub: {name}"
   ويرجع للـ "GitHub Explorer" لما الـ component يتشال
```

**Bonus:** ابني `usePrevious(value)` واستخدمه عشان تعرض:
`"Previously viewing: {previousUsername}"`

---

> **التالي:** [[05-Client-Side-Routing-React-Router]] — عرفنا نتحكم في الـ lifecycle وفي العالم الخارجي. دلوقتي إزاي نبني تطبيق فيه صفحات كتير والـ URL بيتغير من غير ما الصفحة تعمل reload؟
