# File: 04-The-Escape-Hatch-useEffect-useRef.md

> **المتطلبات:** [[01-React-Anatomy-and-JSX]] و [[02-State-Machines-useState-useReducer]] — لازم تعرف إزاي React بتفكر في الـ renders وإزاي الـ state بتشتغل قبل ما تبدأ هنا. الفصل ده هو النقطة اللي فيها React بتفتح لك باب للعالم الخارجي بره نظامها.

---

## البداية — أزمة وجودية اسمها "العالم الخارجي"

React عندها عقد واضح ومحترم معاك:

> **"أنا بتحكم في الـ UI بالكامل. أديني الـ state، وأنا هعمل الباقي."**

وده كلام جميل — وبيشتغل مع معظم حاجات. بس فيه صنف من المشاكل مش React قادر يحلها لوحده لأنها موجودة **بره** دايرة الـ state والـ rendering بتاعته.

تخيل معايا الـ scenarios دي:

```
1. عايز تجيب data من API لما الصفحة تفتح.
2. عايز تربط event listener على الـ window (مثلاً: resize, scroll, keypress).
3. عايز تشغّل setInterval — عداد بيتحدث كل ثانية.
4. عايز توصل لـ DOM element مباشرةً وتعمل focus() عليه.
5. عايز تربط third-party library (مثلاً: Chart.js, Google Maps) بـ div معين.
6. عايز تشوف الـ previous value بتاع state من غير ما ترندر تاني.
```

كل الـ scenarios دي فيها حاجة مشتركة: **بيحتاجوا تتجاوز نظام React وتلمس حاجة برّه.** API، DOM، timers، external libraries — دي كلها مش جزء من React's world.

ده اللي بيسمّوه **Side Effects** — أي حاجة بتعملها في الـ component غير إنك ترجع JSX للشاشة.

المشكلة إن React بتشتغل بطريقة معينة:

```
State/Props يتغير → React تعيد تنفيذ الـ function كلها → JSX جديد → DOM يتحدث
```

لو حاولت تعمل side effect **جوّا** الـ function مباشرةً، هيتنفذ في كل render — كل مرة أي حاجة بتتغير:

```jsx
// ❌ CATASTROPHIC — هيتنفذ في كل render
function UserProfile({ userId }) {
  // This runs on EVERY render — this will call the API hundreds of times!
  fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .then(data => setUser(data)); // This call triggers a render → which calls fetch again → infinite loop

  return <div>...</div>;
}
```

ده مش bug — ده **design problem**. React مصممة بحيث إن الـ function بتاع الـ component لازم تكون **pure** — بتأخد input وبترجع output من غير ما تأثر على العالم الخارجي.

بس إزاي نعمل side effects لو الـ function لازم تبقى pure؟

الإجابة كانت محتاجة **باب خلفي رسمي** يديك إياه React نفسها — باب مضبوط ومنظم. وده اللي بيسمّوه:

> **The Escape Hatch.**

---

## الأداتين — `useEffect` و `useRef`

الـ escape hatch مش أداة واحدة — هو أداتين بيكملوا بعض:

```
useEffect → "عايز أتصل بالعالم الخارجي في وقت معين"
useRef    → "عايز أمسك حاجة بين الـ renders من غير ما أعمل re-render"
```

خليني أشرحلك كل واحدة بعمق.

---

## [[useEffect]] — "الباب الرسمي للـ Side Effects"

### الـ Anatomy — التشريح سطر بسطر

```jsx
useEffect(() => {
  // [1] EFFECT BODY — الكود اللي عايز تشغّله
  // هنا بتتكلم مع العالم الخارجي

  return () => {
    // [2] CLEANUP FUNCTION — اختياري
    // بيتشغّل قبل ما الـ effect يتشغّل تاني
    // أو لما الـ component يتشال من الـ DOM
  };

}, [/* 3 — dependency array */]);
```

**[1] Effect Body:** الكود اللي عايز يتنفذ. مش بترجع JSX هنا — بترجع cleanup function أو لا بترجع حاجة.

**[2] Cleanup Function:** زي ما بتفتح باب لازم تقفله. لو عملت `setInterval` — لازم تعمل `clearInterval`. لو اشتركت في event — لازم تلغي الاشتراك. React بتستدعيها تلقائياً في الوقت الصح.

**[3] Dependency Array:** ده القلب. بيحدد *امتى* الـ effect يشتغل.

---

### الـ Dependency Array — "متى أُشغَّل؟"

ده أكتر حاجة بتتسبب في bugs لو مافهمتيش. في 3 أشكال بس:

#### الشكل الأول: بدون array — "اشتغّل في كل render"

```jsx
useEffect(() => {
  console.log('I run after EVERY render');
  // بيتشغّل بعد أول render وبعد كل تحديث بعد كده
});
// ⚠️ نادراً ما تحتاجه — غالباً علامة على design problem
```

#### الشكل الثاني: Array فاضية `[]` — "اشتغّل مرة واحدة بس"

```jsx
useEffect(() => {
  console.log('I run ONCE — when the component mounts');
  // بيتنفذ مرة واحدة بس بعد أول render
  // معادل الـ componentDidMount في Class Components
}, []);
// ✅ ده اللي بتستخدمه لجلب initial data
```

#### الشكل الثالث: Array فيها values — "اشتغّل لما الـ values دي تتغير"

```jsx
useEffect(() => {
  console.log(`userId changed to: ${userId}`);
  // بيتشغّل بعد أول render + كل مرة userId تتغير
}, [userId]);
// ✅ ده اللي بتستخدمه لو الـ effect بيعتمد على قيم معينة
```

---

### مثال حقيقي — Data Fetching

**الطريقة القديمة الكارثية ❌ (Vanilla JS في Component):**

```jsx
// ❌ WRONG — Side effect directly in render function
function UserProfile({ userId }) {
  let user = null;

  // هيتنفذ في كل render — كارثة
  fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .then(data => {
      user = data; // ده مش هينفع — React مش هتعرف تعمل re-render
    });

  return <div>{user ? user.name : 'Loading...'}</div>;
}
```

**الطريقة الصح ✅ — useEffect مع state:**

```jsx
import { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

  useEffect(() => {
    // [STEP 1] Reset state لما userId تتغير
    setLoading(true);
    setError(null);

    // [STEP 2] ابعت الـ request
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

  }, [userId]); // [STEP 3] بيعمل re-fetch لما userId تتغير

  if (loading) return <p>Loading...</p>;
  if (error)   return <p>Error: {error}</p>;
  return <div><h1>{user.name}</h1></div>;
}
```

---

### الـ Race Condition — مشكلة الـ Data Fetching المتأخرة

فيه مشكلة خفية في الكود اللي فوق. تخيل المستخدم بدّل الـ userId بسرعة:

```
userId = 1 → fetch starts (slow network — takes 3 seconds)
userId = 2 → fetch starts (fast network — takes 0.5 seconds)

Result arrives order:
  userId=2 data arrives FIRST  → setUser(user2) ✅
  userId=1 data arrives SECOND → setUser(user1) ❌ WRONG! Shows old user!
```

ده اللي بيتسمى **Race Condition** — طلبين بيتسابقوا والأبطأ بيكسب غلط.

الحل هو **cleanup function** مع **AbortController**:

```jsx
useEffect(() => {
  // [1] Create an AbortController for this specific request
  const controller = new AbortController();

  setLoading(true);

  fetch(`/api/users/${userId}`, {
    signal: controller.signal // [2] Link the signal to the fetch
  })
    .then(res => res.json())
    .then(data => {
      setUser(data);
      setLoading(false);
    })
    .catch(err => {
      // [3] Ignore AbortError — it means we cancelled intentionally
      if (err.name !== 'AbortError') {
        setError(err.message);
        setLoading(false);
      }
    });

  // [4] Cleanup: runs BEFORE next effect OR on unmount
  return () => {
    controller.abort(); // Cancels the fetch if still in-flight
  };

}, [userId]);
```

لما `userId` تتغير، React بتعمل الآتي:
1. بتستدعي الـ cleanup function من الـ effect القديم → `controller.abort()`
2. بتشغّل الـ effect الجديد بالـ `userId` الجديدة

بكده الـ request القديمة بتتلغى قبل ما تأثر على الـ state.

---

### مثال ثاني — Event Listeners

```jsx
// ❌ WRONG — Event listener added on every render, never removed
function WindowSize() {
  const [size, setSize] = useState({ width: window.innerWidth });

  // بيضيف listener في كل render من غير ما يشيله
  window.addEventListener('resize', () => {
    setSize({ width: window.innerWidth });
  });

  return <p>Width: {size.width}px</p>;
}
```

```jsx
// ✅ CORRECT — Add once, clean up on unmount
function WindowSize() {
  const [size, setSize] = useState({ width: window.innerWidth });

  useEffect(() => {
    // [1] Define the handler
    const handleResize = () => {
      setSize({ width: window.innerWidth });
    };

    // [2] Subscribe
    window.addEventListener('resize', handleResize);

    // [3] Cleanup — unsubscribe when component unmounts
    return () => {
      window.removeEventListener('resize', handleResize);
    };

  }, []); // Empty array — add listener once only

  return <p>Width: {size.width}px</p>;
}
```

---

### الـ Stale Closure — التنين الخفي

ده أصعب bug في `useEffect` وأكتر حاجة بتحير junior developers.

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      console.log(`Current count: ${count}`); // ⚠️ Always prints 0!
      setCount(count + 1);                     // ⚠️ Always sets to 1!
    }, 1000);

    return () => clearInterval(interval);
  }, []); // Empty array — runs once

  return <div>{count}</div>;
}
```

**إيه اللي بيحصل بالظبط؟**

لما الـ `useEffect` اشتغل لأول مرة، الـ callback بتاع `setInterval` "شاف" قيمة `count` اللي كانت `0` في اللحظة دي. **وقفش عليها.** ده اللي بيسمّوه **Closure** — الـ function "بتلتقط" القيمة من الـ scope اللي اتعملت فيه.

بما إن الـ dependency array فاضية، الـ effect مابيشتغلش تاني — والـ closure بقى stale (قديم) بيشاور على `count = 0` للأبد.

**الحل — Functional Update:**

```jsx
useEffect(() => {
  const interval = setInterval(() => {
    // ✅ Use the functional form — gets the LATEST state value
    setCount(prevCount => prevCount + 1);
    // prevCount هنا بييجي من React نفسها، مش من الـ closure
  }, 1000);

  return () => clearInterval(interval);
}, []); // Now safe with empty array
```

لما بتستخدم الـ functional form بتاعة `setState`، React بتديك أحدث قيمة للـ state في اللحظة دي — مش القيمة اللي الـ closure التقطها.

---

## [[useRef]] — "الذاكرة التانية اللي مابتصحيش الدنيا"

لو `useState` هو الذاكرة الرسمية اللي React بتشوفها وبتعمل re-render عشانها، فـ `useRef` هو الدفتر الجانبي — بتكتب فيه حاجات React مش مهتمة بيها ومش بتعمل re-render لما تتغير.

### الـ Anatomy

```jsx
const myRef = useRef(initialValue);

// myRef is: { current: initialValue }
// You read/write through: myRef.current
```

`useRef` بيرجع object واحد فيه property واحدة اسمها `current`. الـ object ده **بيفضل نفس الـ object** طول عمر الـ component — مش بيتعمل جديد في كل render. وأي تغيير في `myRef.current` **مابيعملش re-render**.

### الاستخدام الأول: الوصول لـ DOM Elements

ده أشهر استخدام لـ `useRef`. بدل ما تعمل `document.getElementById()` — React بتديك طريقة نظيفة:

```jsx
// ❌ OLD WAY — Vanilla JS approach (breaks React's model)
function SearchBox() {
  function handleClick() {
    // Reaching into DOM directly — bypasses React completely
    const input = document.getElementById('search-input');
    input.focus(); // Works but is not "the React way"
  }

  return (
    <div>
      <input id="search-input" type="text" />
      <button onClick={handleClick}>Focus</button>
    </div>
  );
}
```

```jsx
// ✅ THE REACT WAY — useRef for DOM access
import { useRef } from 'react';

function SearchBox() {
  // [1] Create the ref — starts as null
  const inputRef = useRef(null);

  function handleClick() {
    // [3] Access the DOM element via .current
    inputRef.current.focus();
    // inputRef.current IS the actual <input> DOM element
  }

  return (
    <div>
      {/* [2] Attach the ref to the JSX element */}
      <input ref={inputRef} type="text" placeholder="Search..." />
      <button onClick={handleClick}>Focus Search</button>
    </div>
  );
}
```

**إيه اللي بيحصل بالترتيب؟**

```
1. React بترندر الـ JSX
2. بتشوف الـ ref={inputRef} على الـ <input>
3. بعد ما الـ DOM يتبني، بتحط مرجع الـ DOM element الحقيقي في inputRef.current
4. من اللحظة دي، inputRef.current = <input> الحقيقية في الـ DOM
5. تقدر تعمل عليها أي DOM methods: .focus(), .blur(), .scrollIntoView(), etc.
```

---

### مثال عملي — Video Player Controls

```jsx
import { useRef } from 'react';

function VideoPlayer({ src }) {
  const videoRef = useRef(null);

  function handlePlay() {
    videoRef.current.play(); // Native DOM method
  }

  function handlePause() {
    videoRef.current.pause(); // Native DOM method
  }

  function handleSkipForward() {
    videoRef.current.currentTime += 10; // Direct property manipulation
  }

  return (
    <div>
      <video ref={videoRef} src={src} />
      <button onClick={handlePlay}>▶ Play</button>
      <button onClick={handlePause}>⏸ Pause</button>
      <button onClick={handleSkipForward}>⏩ +10s</button>
    </div>
  );
}
```

---

### الاستخدام الثاني: تخزين قيم بين الـ Renders بدون Re-render

ده الاستخدام الأذكى وأقل حد بيفهمه في البداية.

**المشكلة:** محتاج أخزّن قيمة بين الـ renders — بس مش عايز الـ component يتـ re-render لما القيمة دي تتغير.

مثال: عايز تعرف الـ previous value بتاعة state معينة:

```jsx
// ❌ WRONG — Can't use useState for this
// لو استخدمت setState هيعمل re-render → infinite loop scenario
function PriceDisplay({ currentPrice }) {
  const [previousPrice, setPreviousPrice] = useState(currentPrice); // starts same

  // هنا المشكلة: مفيش طريقة نظيفة تعرف "آخر render كانت قيمته إيه"
  // لو عملت setState في useEffect هيسبب cascading renders
}
```

```jsx
// ✅ CORRECT — useRef to track previous value
import { useRef, useEffect } from 'react';

function PriceDisplay({ currentPrice }) {
  const previousPriceRef = useRef(currentPrice);

  useEffect(() => {
    // After render, update the ref to current value
    // This does NOT trigger a re-render
    previousPriceRef.current = currentPrice;
  }); // No dependency array — runs after every render

  const diff = currentPrice - previousPriceRef.current;
  const isUp = diff > 0;

  return (
    <div>
      <span style={{ color: isUp ? 'green' : 'red' }}>
        {currentPrice} {isUp ? '▲' : '▼'} ({diff > 0 ? '+' : ''}{diff})
      </span>
      <small>Was: {previousPriceRef.current}</small>
    </div>
  );
}
```

---

### مثال تاني — تتبع عدد الـ Renders

```jsx
import { useRef, useState } from 'react';

function RenderCounter() {
  const [value, setValue] = useState('');
  const renderCount = useRef(0); // ← مش state — مش هيسبب re-render

  // بيتنفذ في كل render لكن من غير ما يسبب render إضافي
  renderCount.current += 1;

  return (
    <div>
      <input
        value={value}
        onChange={e => setValue(e.target.value)}
        placeholder="Type something..."
      />
      <p>This component has rendered: {renderCount.current} times</p>
    </div>
  );
}
```

لو استخدمنا `useState` بدل `useRef` هنا — كل increment في الـ count هيعمل re-render → هيعمل increment → هيعمل re-render → **infinite loop**.

---

### مثال تالت — تخزين Timer IDs

```jsx
import { useRef, useState } from 'react';

function StopWatch() {
  const [time, setTime]       = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  // Store the interval ID in a ref — not state
  // لو حطيناه في state، كل مرة بنحدث الـ ID هيعمل re-render مش محتاجه
  const intervalRef = useRef(null);

  function handleStart() {
    setIsRunning(true);
    intervalRef.current = setInterval(() => {
      setTime(prev => prev + 1);
    }, 1000);
  }

  function handleStop() {
    setIsRunning(false);
    clearInterval(intervalRef.current); // ← بنوصل للـ ID اللي حطيناه
  }

  function handleReset() {
    setIsRunning(false);
    clearInterval(intervalRef.current);
    setTime(0);
  }

  return (
    <div>
      <h2>{time}s</h2>
      <button onClick={handleStart} disabled={isRunning}>Start</button>
      <button onClick={handleStop} disabled={!isRunning}>Stop</button>
      <button onClick={handleReset}>Reset</button>
    </div>
  );
}
```

---

### `useState` vs `useRef` — امتى تختار أيهما؟

```
سؤال واحد: "لو القيمة دي اتغيرت، محتاج الـ UI يتغير؟"

YES → useState
NO  → useRef
```

| السيناريو | الأداة الصح |
|---|---|
| عداد بيتعرض على الشاشة | `useState` |
| interval ID محتاج أخزّنه وأستخدمه في cleanup | `useRef` |
| اسم المستخدم بيتعرض في الـ UI | `useState` |
| مرجع لـ DOM element عشان أعمل `.focus()` | `useRef` |
| loading state بيظهر spinner | `useState` |
| previous value للمقارنة | `useRef` |
| form field values بتتعرض | `useState` |
| عداد renders للـ debugging | `useRef` |

---

## الصورة الكاملة — إزاي `useEffect` و `useRef` بيكملوا بعض

```
┌─────────────────────────────────────────────────────────────────┐
│                    REACT COMPONENT                              │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │               RENDER WORLD (Pure)                      │    │
│  │   State, Props → JSX → DOM update                      │    │
│  │   React controls everything here                       │    │
│  └──────────────────────┬─────────────────────────────────┘    │
│                         │                                       │
│                    ┌────▼────┐                                  │
│                    │ useRef  │ ← "أنا بمسك حاجات بين           │
│                    │.current │    الـ renders بهدوء"            │
│                    └────┬────┘                                  │
│                         │                                       │
│                    ┌────▼──────┐                                │
│                    │useEffect  │ ← "أنا الباب الرسمي للـ       │
│                    │(side FX)  │    outside world"              │
│                    └────┬──────┘                                │
│                         │                                       │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │         OUTSIDE WORLD               │
        │  APIs, DOM, Timers, Libraries       │
        │  WebSockets, localStorage, etc.     │
        └─────────────────────────────────────┘
```

---

## Old Way ❌ vs Modern Way ✅ — المقارنة الكاملة

### سيناريو 1: Fetching Data

```jsx
// ❌ OLD WAY — Class Component (React 15 era)
class UserList extends React.Component {
  constructor(props) {
    super(props);
    this.state = { users: [], loading: true };
  }

  componentDidMount() {
    // Runs after mount — equivalent to useEffect(fn, [])
    fetch('/api/users')
      .then(res => res.json())
      .then(data => this.setState({ users: data, loading: false }));
  }

  componentDidUpdate(prevProps) {
    // Runs after every update — messy comparison needed
    if (prevProps.filter !== this.props.filter) {
      fetch(`/api/users?filter=${this.props.filter}`)
        .then(res => res.json())
        .then(data => this.setState({ users: data }));
    }
  }

  componentWillUnmount() {
    // Cleanup — but we already lost the reference to abort the fetch!
    // Race condition risk is high here
  }

  render() {
    const { users, loading } = this.state;
    if (loading) return <p>Loading...</p>;
    return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
  }
}
```

```jsx
// ✅ MODERN WAY — Function Component + useEffect
function UserList({ filter }) {
  const [users, setUsers]     = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);

    fetch(`/api/users?filter=${filter}`, { signal: controller.signal })
      .then(res => res.json())
      .then(data => {
        setUsers(data);
        setLoading(false);
      })
      .catch(err => {
        if (err.name !== 'AbortError') setLoading(false);
      });

    return () => controller.abort(); // Auto-cleanup on change or unmount

  }, [filter]); // Re-runs when filter changes — no manual comparison

  if (loading) return <p>Loading...</p>;
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

---

### سيناريو 2: DOM Access

```jsx
// ❌ OLD WAY — document.querySelector (breaks React's abstraction)
function LoginForm() {
  function handleSubmit() {
    const emailInput = document.querySelector('#email');
    emailInput.focus(); // Works but bypasses React
    emailInput.style.borderColor = 'red'; // Mutating DOM directly — dangerous
  }
  return <input id="email" type="email" />;
}
```

```jsx
// ✅ MODERN WAY — useRef for DOM access
function LoginForm() {
  const emailRef = useRef(null);

  function handleSubmit() {
    // React knows about this ref — safe and predictable
    emailRef.current.focus();
    emailRef.current.style.borderColor = 'red'; // Still works if needed
  }

  return <input ref={emailRef} type="email" />;
}
```

---

## 🫒 زتونة الإنترفيو

> **`useEffect` is React's official mechanism for synchronizing a component with an external system — APIs, timers, event listeners, third-party libraries. It runs after every render by default, but the dependency array controls its frequency: an empty array (`[]`) causes it to run once on mount, and a populated array causes it to re-run only when any of the listed values change. Critically, `useEffect` supports a cleanup function — returned from the effect body — which React invokes before the next effect execution or on unmount, preventing memory leaks and race conditions. The stale closure problem — where an effect captures an outdated value from a previous render — is solved either via the dependency array (include the value so the effect re-runs with fresh data) or via functional state updates (`setState(prev => ...)`) which bypass the closure entirely. `useRef`, on the other hand, solves a different problem: persisting a mutable value across renders without triggering a re-render. It returns a stable object `{ current: value }` that survives the entire component lifetime. Its two primary use cases are: (1) holding a reference to a real DOM element (via the `ref` JSX attribute) to imperatively call native methods like `.focus()` or `.play()`, and (2) storing internal implementation details — like interval IDs, previous values, or subscription objects — that the UI doesn't need to display but the component needs to remember. The decision rule is simple: if a changing value should update the UI, use `useState`; if it's internal bookkeeping, use `useRef`.**

---

## ✅ Checkpoint — اختبر فهمك

| السؤال | الإجابة المتوقعة |
|---|---|
| إيه الفرق بين `useEffect(fn)` و `useEffect(fn, [])` و `useEffect(fn, [x])`؟ | الأولى بتشتغل بعد كل render. الثانية مرة واحدة بعد الـ mount. الثالثة بعد الـ mount + لما `x` تتغير. |
| إيه الـ Race Condition في Data Fetching وازاي تحلها؟ | لما طلبين بيتسابقوا والأبطأ بييجي تاني فبيعوّض الأحدث. الحل هو `AbortController` في الـ cleanup function. |
| إيه الـ Stale Closure وامتى بتحصل؟ | لما الـ effect "بيلتقط" قيمة قديمة من الـ closure بتاعه. بتحصل غالباً مع `setInterval` وـ empty dependency array. |
| إيه الفرق بين `useState` و `useRef`؟ | كلاهما بيحفظ قيم بين الـ renders، بس تغيير `state` بيعمل re-render وتغيير `ref.current` لا. |
| امتى تستخدم `useRef` بدل `useState`؟ | لما القيمة مش محتاجة تظهر في الـ UI — زي DOM refs، interval IDs، previous values، أو internal flags. |
| إيه الـ cleanup function وامتى بتتشغّل؟ | function بترجعها من الـ effect. React بتشغّلها قبل ما الـ effect يشتغّل تاني أو لما الـ component يتشال من الـ DOM. |
| ليه مش المفروض تعمل async function مباشرةً جوا `useEffect`؟ | لأن `useEffect` المفروض يرجع cleanup function أو لا يرجع حاجة. الـ async function بترجع Promise مش cleanup. |
| إيه الحل لو عايز تستخدم async/await في `useEffect`؟ | تعرّف function async جوا الـ effect وتاستدعيها: `useEffect(() => { const fetchData = async () => {...}; fetchData(); }, [])` |

---

## 🛠️ Practical Lab

### Task 1 — اقرأ وتوقع

اقرأ الكود ده وجاوب على الأسئلة:

```jsx
import { useState, useEffect, useRef } from 'react';

function MysteryComponent({ query }) {
  const [results, setResults] = useState([]);
  const callCount = useRef(0);
  const inputRef = useRef(null);

  useEffect(() => {
    callCount.current += 1;
    console.log(`Effect ran ${callCount.current} times`);

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
1. الـ `callCount.current` بيتعرض على الشاشة — بس لو تغيّر, هل الـ UI هيتحدث؟ ليه؟
2. لو `query` اتغيرت 3 مرات، الـ fetch effect اشتغل كام مرة؟
3. إيه اللي بيحصل لو المستخدم غيّر الـ `query` وهو الـ API call اللحتة دي لسه ما رجعتش؟
4. الـ `inputRef` بيتـ focus — امتى بالظبط؟

---

### Task 2 — Fix the Bug

الكود ده فيه 3 bugs. حددهم وصلّحهم:

```jsx
// BUGGY CODE — Find all 3 bugs
import { useState, useEffect } from 'react';

function LivePrice({ symbol }) {
  const [price, setPrice] = useState(0);
  const [change, setChange] = useState(0);

  // Bug 1
  useEffect(async () => {
    const data = await fetch(`/api/price/${symbol}`).then(r => r.json());
    setPrice(data.price);
    setChange(data.change);
  }, []);

  // Bug 2
  useEffect(() => {
    const interval = setInterval(() => {
      setPrice(price + Math.random() - 0.5);
    }, 1000);
  }, []);

  // Bug 3
  useEffect(() => {
    document.title = `${symbol}: $${price}`;
  });

  return (
    <div>
      <h2>{symbol}: ${price.toFixed(2)}</h2>
      <span>{change > 0 ? '+' : ''}{change.toFixed(2)}%</span>
    </div>
  );
}
```

**الـ Bugs:**
- Bug 1: `useEffect` مع `async` function مباشرةً
- Bug 2: Stale closure + missing cleanup
- Bug 3: Missing dependency array — بيشتغّل في كل render من غير لازمة

---

### Task 3 — ابني من الصفر

ابني component اسمه `<GitHubUser username="torvalds" />` بيعمل الآتي:

```
1. يجيب data من GitHub API:
   https://api.github.com/users/{username}

2. يعرض:
   - الصورة (avatar_url)
   - الاسم (name)
   - عدد الـ repos (public_repos)
   - عدد الـ followers (followers)
   - رابط الـ profile (html_url)

3. لو username اتغيّر — يجيب الـ data الجديدة
   (اعمل زرار أو input تقدر تغيّر الـ username بيه)

4. يتعامل مع الـ loading state وـ error state

5. يستخدم AbortController في الـ cleanup

6. لما الـ data تيجي، يعمل focus تلقائياً على زرار "Visit Profile"
   (استخدم useRef)
```

**الـ API response شكله:**

```json
{
  "name": "Linus Torvalds",
  "avatar_url": "https://...",
  "public_repos": 8,
  "followers": 220000,
  "html_url": "https://github.com/torvalds"
}
```

**Bonus:** خلّي الـ document title يتغير لـ `GitHub: {name}` لما الـ data تيجي، ويرجع للأصل لما الـ component يتشال.

---

> **التالي:** [[05-Client-Side-Routing-React-Router]] — عرفنا نتحكم في lifecycle الـ component وفي العالم الخارجي. دلوقتي إزاي نبني تطبيق فيه صفحات كتير والـ URL بيتغير من غير ما الصفحة تعمل reload؟
