---
tags: [react, javascript, frontend, interview-prep]
part: 1
covers: "React Fundamentals · Components & Props · State & Hooks · Lifecycle & Effects · Performance Optimization · Routing & State Management · Advanced Patterns"
---

# ⚛️ React من الصفر (Q1 → نهاية الملف)

> [!info] 📖 إزاي تذاكر الملف ده؟
> الملف ده معمول كمرجع سريع ومكثف للمراجعة قبل الإنترفيو بيوم أو اتنين، بيغطي أشهر أسئلة ريأكت (React) من الأساسيات لحد المفاهيم المتقدمة بإجابات مثالية جاهزة تتقال للممتحن مباشرة.

## Q1 — إيه الـ React أصلاً وإيه المشكلة اللي بيحلها؟

### أصل الحكاية
ريأكت هي مكتبة جافاسكريبت لعمل واجهات المستخدم (UIs) مبنية على فكرة المكونات (Components). المشكلة اللي بتحلها هي إن التعديل المباشر في الـ DOM كان بطيء ومعقد جداً في التطبيقات الكبيرة، فريأكت جابت فكرة الـ (Virtual DOM) عشان تحدّث الشاشة بأسرع وأكفأ طريقة ممكنة.

```jsx
// A simple React component returning JSX
function Welcome() {
  return <h1>Hello, React!</h1>;
}
```

### الفايدة الانترفيوية
What is React and what problem does it solve?
**الإجابة المثالية:** React is a component-based JavaScript library for building user interfaces. It solves the performance and complexity issues of direct DOM manipulation by using a Virtual DOM to efficiently update only the parts of the UI that have changed.

---

## Q2 — إيه الـ Virtual DOM وإزاي بيختلف عن الـ Real DOM؟

### أصل الحكاية
الـ (Virtual DOM) هو مجرد نسخة خفيفة في الميموري بتمثل شكل الـ (Real DOM). الاختلاف إن الـ (Real DOM) تقيل وأي تعديل فيه بيخلي البراوزر يعيد رسم الشاشة، بينما الـ (Virtual DOM) خفيف والتعديل فيه مابياخدش وقت، وبعدين ريأكت بتقارن النسختين وتحدث الـ (Real DOM) بأقل التغييرات بس.

```jsx
// React creates an object representation (Virtual DOM) of this JSX behind the scenes
const element = <div className="app">Hello</div>;
/* Looks like: { type: 'div', props: { className: 'app', children: 'Hello' } } */
```

### الفايدة الانترفيوية
What is the Virtual DOM and how does it differ from the Real DOM?
**الإجابة المثالية:** The Virtual DOM is a lightweight in-memory representation of the Real DOM. Unlike the Real DOM which is slow and triggers layout recalculations upon updates, the Virtual DOM allows React to compute the minimal necessary changes in memory before applying them in batch to the Real DOM.

---

## Q3 — إزاي الـ Reconciliation Algorithm (الـ Diffing) بيشتغل عشان يحدّث الـ DOM بأقل تكلفة؟

### أصل الحكاية
الـ (Reconciliation) هي عملية المقارنة اللي بتحصل لما الـ (State) تتغير. ريأكت بتبني شجرة (Virtual DOM) جديدة وتقارنها بالقديمة في عملية اسمها الـ (Diffing). لو لقيت نوع العنصر اتغير، بتهد الشجرة دي وتبنيها من جديد، ولو نفس النوع، بتحدث بس الخصائص اللي اتغيرت.

```jsx
// React diffs the old and new elements and only updates the className attribute in the Real DOM
// Old: <div className="light" />
// New: <div className="dark" />
```

### الفايدة الانترفيوية
How does React's Reconciliation and Diffing algorithm work?
**الإجابة المثالية:** Reconciliation is the process where React compares the new Virtual DOM tree with the previous one. It uses a heuristic Diffing algorithm that replaces the entire subtree if the element types differ, or only updates the changed attributes if the element types remain the same, optimizing the update process.

---

## Q4 — إيه الـ JSX وإزاي بيتحول لـ JavaScript فعلي وقت الـ Build؟

### أصل الحكاية
الـ (JSX) هو طريقة بنكتب بيها كود شبه الـ HTML جوا الجافاسكريبت عشان يسهل علينا بناء الواجهة. بس البراوزر مش بيفهمه، فبيجي أداة زي Babel وقت الـ (Build) تحوله لكود جافاسكريبت عادي باستخدام `React.createElement`.

```jsx
// JSX syntax
const element = <h1 className="title">Hello</h1>;

// Compiled to JavaScript by Babel
const compiled = React.createElement('h1', { className: 'title' }, 'Hello');
```

### الفايدة الانترفيوية
What is JSX and how is it transformed?
**الإجابة المثالية:** JSX is a syntax extension for JavaScript that allows us to write HTML-like markup inside JS files. Under the hood, bundlers and compilers like Babel transform JSX into `React.createElement()` calls that browsers can understand.

---

## Q5 — إيه الفرق بين الـ Elements والـ Components في React؟

### أصل الحكاية
الـ (Element) هو أصغر حاجة في ريأكت، وهو مجرد Object بيوصف اللي المفروض يظهر على الشاشة. أما الـ (Component) فهو بلوك كود أكبر بياخد بيانات ويرجع Elements.

```jsx
// React Element (just an object describing UI)
const element = <div>I am an element</div>;

// React Component (a function returning elements)
function MyComponent() {
  return <div>I am a component</div>;
}
```

### الفايدة الانترفيوية
What is the difference between an Element and a Component in React?
**الإجابة المثالية:** An Element is a plain object describing what you want to see on the screen. A Component is a function or a class that accepts inputs (props) and returns a React Element tree.

---

## Q6 — إيه الفرق بين الـ Functional Components والـ Class Components؟

### أصل الحكاية
زمان كنا بنستخدم الـ (Class Components) عشان نقدر نستخدم الـ (State) ودوال دورة الحياة (Lifecycle)، والـ (Functional) كانت مجرد دوال بسيطة. مع ظهور الـ (Hooks)، بقت الـ (Functional Components) قادرة تعمل كل حاجة وأسهل في الكتابة فبقت هي المعيار الأساسي.

| وجه المقارنة | Functional Components | Class Components |
|---|---|---|
| التركيب | `function MyComp() {}` | `class MyComp extends React.Component {}` |
| إدارة الحالة | بتستخدم `useState` Hook | بتستخدم `this.state` و `this.setState` |
| دورة الحياة | بتستخدم `useEffect` Hook | `componentDidMount`, `componentDidUpdate` |

```jsx
// Functional component using a hook
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### الفايدة الانترفيوية
What is the difference between Functional and Class Components?
**الإجابة المثالية:** Class Components use ES6 classes and have built-in state and lifecycle methods, but they can be verbose and suffer from `this` binding issues. Functional Components are simpler functions that now support state and side-effects via Hooks, making them the modern standard.

---

## Q7 — إيه الـ `key` prop في الـ Lists وليه مهم جداً وإيه اللي بيحصل لو استخدمت الـ index كـ key؟

### أصل الحكاية
الـ `key` هو هوية مميزة لكل عنصر جوا القايمة، وبيساعد ريأكت تتعرف على العناصر اللي اتضافت أو اتعدلت. لو استخدمت الـ Index، وأي عنصر اتمسح أو ترتيبه اتغير، ريأكت هتتلخبط وممكن تعرض داتا غلط.

```jsx
// Always use a unique identifier (like an ID) as the key, NOT the array index
function UserList({ users }) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li> 
      ))}
    </ul>
  );
}
```

> [!danger] فخ الإنترفيو
> استخدام الـ Index كـ key مسموح فقط لو القايمة دي مستحيل تتغير أو تترتب، ومافيهاش عناصر جواها State. غير كده، ده Anti-pattern خطير.

### الفايدة الانترفيوية
Why are keys important in React lists, and why is using the array index a bad idea?
**الإجابة المثالية:** Keys help React identify which items have changed, been added, or removed, making the reconciliation process efficient. Using the array index as a key is dangerous because if the list order changes, React might reuse components incorrectly, leading to UI bugs.

---

## Q8 — إيه الفرق بين الـ Library والـ Framework؟ وليه React بتتصنف Library مش Framework؟

### أصل الحكاية
الـ (Framework) بيفرض عليك هيكل كامل للتطبيق زي Angular. لكن الـ (Library) بتركز على حاجة واحدة بس، وريأكت بتركز على الواجهة بس (UI)، وبتسيبلك حرية اختيار باقي الأدوات زي الـ Routing والـ State Management.

```javascript
// React only imports the UI tools. For routing, you have to choose an external library.
import React from 'react';
import { BrowserRouter } from 'react-router-dom';
```

### الفايدة الانترفيوية
Is React a library or a framework, and what is the difference?
**الإجابة المثالية:** React is a library because it solely focuses on rendering UI components. Unlike a framework like Angular, which dictates an entire architecture, React requires developers to integrate third-party libraries for routing and state management.

---

## Q9 — إيه الـ Props وإزاي بتنتقل البيانات من Component لـ Component تاني؟

### أصل الحكاية
الـ (Props) هي الطريقة اللي الـ Component الأب بيبعت بيها بيانات للـ Component الابن. البيانات دي دايماً بتتنقل في اتجاه واحد بس من فوق لتحت (One-way Data Binding).

```jsx
// Passing data from Parent to Child via props
function Parent() {
  return <Child name="Ahmed" age={25} />;
}

function Child(props) {
  return <p>Name: {props.name}, Age: {props.age}</p>;
}
```

### الفايدة الانترفيوية
What are Props in React and how does data flow?
**الإجابة المثالية:** Props are arguments passed into React components. They enable one-way data flow (top-down) from parent to child components, allowing components to be dynamic and reusable.

---

## Q10 — إيه معنى إن الـ Props تكون Read-Only (Immutable)؟

### أصل الحكاية
معناها إن الـ Component الابن مستحيل يعدل في الـ (Props) اللي جاية له من الأب. لو الابن عايز يغير حاجة، لازم الأب يبعتله Function (Callback) يناديها عشان الأب هو اللي يغير الـ State بتاعته.

```jsx
// A child component MUST NOT mutate its props directly.
function Child({ title }) {
  // title = "New Title"; // ERROR! Props are read-only.
  return <h1>{title}</h1>;
}
```

### الفايدة الانترفيوية
Why are Props considered read-only in React?
**الإجابة المثالية:** Props are read-only to maintain the unidirectional data flow and predictability of the application. A component must never mutate its own props; instead, state updates should be managed by the parent component.

---

## Q11 — إيه الـ `children` prop وإزاي بتستخدمه لعمل Components قابلة لإعادة الاستخدام؟

### أصل الحكاية
الـ `children` هو prop مميز بيحتوي على أي محتوى إنت بتحطه بين فتحة وقفلة الـ Component. ده بيسمحلك تعمل Components زي الـ Cards وتمرر جواها أي واجهة براحتك.

```jsx
// A wrapper component using the children prop
function Card({ children }) {
  return <div className="card-styling">{children}</div>;
}

// Usage
function App() {
  return (
    <Card>
      <h2>Card Title</h2>
    </Card>
  );
}
```

### الفايدة الانترفيوية
What is the `children` prop?
**الإجابة المثالية:** The `children` prop is a special prop that allows you to pass nested elements directly inside the opening and closing tags of a component. It is highly useful for creating reusable container or wrapper components.

---

## Q12 — إيه الفرق بين الـ Props والـ State؟

### أصل الحكاية
الـ (Props) هي بيانات جاية من بره ومينفعش الـ Component يغيرها. الـ (State) هي بيانات داخلية خاصة بالـ Component نفسه، وهو الوحيد اللي يقدر يعدلها، ولما تتعدل بيعمل (Re-render).

| وجه المقارنة | Props | State |
|---|---|---|
| المصدر | من الـ Parent Component | من داخل الـ Component نفسه |
| التعديل | Read-Only (Immutable) | Mutable (عن طريق `setState`) |

### الفايدة الانترفيوية
What is the difference between State and Props?
**الإجابة المثالية:** Props are read-only parameters passed from a parent to a child to configure it. State is a local, mutable data structure managed entirely within the component itself, and updating it triggers a re-render.

---

## Q13 — إيه الـ Prop Drilling وإيه المشكلة اللي بيسببها في الـ Component Tree الكبيرة؟

### أصل الحكاية
الـ (Prop Drilling) هو إنك تضطر تمرر (Props) خلال مستويات كتير من الـ Components اللي مش محتاجة الداتا دي، بس ككوبري للـ Components اللي تحت. المشكلة إن ده بيصعّب تتبع الداتا وبيخلي الكود مليان حشو.

```jsx
// Prop drilling: App -> Layout -> Sidebar -> UserProfile just to pass the user object.
function App() {
  const user = { name: 'Ali' };
  return <Layout user={user} />;
}
```

### الفايدة الانترفيوية
What is Prop Drilling and why is it a problem?
**الإجابة المثالية:** Prop drilling refers to the process of passing data through multiple intermediate components that do not need the data, simply to reach a deeply nested child component. It makes the codebase harder to maintain.

---

## Q14 — إيه الـ Composition وإزاي React بينصح بيها بدل الـ Inheritance بين الـ Components؟

### أصل الحكاية
ريأكت بتفضل إنك تبني الـ Components المعقدة عن طريق تركيب أجزاء صغيرة فوق بعضها باستخدام الـ `children`، بدل ما تعمل كلاس يورث من كلاس تاني (Inheritance). ده بيخلي الكود مرن أكتر بكتير.

```jsx
// Composition: Building a Dialog out of generic building blocks
function SplitPane({ left, right }) {
  return (
    <div className="split-pane">
      <div className="left">{left}</div>
      <div className="right">{right}</div>
    </div>
  );
}
```

### الفايدة الانترفيوية
Why does React recommend Composition over Inheritance?
**الإجابة المثالية:** React recommends composition because components are fundamentally meant to be isolated and reusable UI functions. Composition uses props and `children` to combine smaller components into larger ones without the tight coupling of class inheritance.

---

## Q15 — إيه الـ Controlled Components والـ Uncontrolled Components في الـ Forms؟ (جدول مقارنة)

### أصل الحكاية
في الـ (Controlled)، ريأكت هي اللي بتتحكم في قيمة الـ Input من خلال الـ State. في الـ (Uncontrolled)، الـ DOM هو اللي بيحتفظ بالقيمة وإنت بتجيبها وقت ما تحتاجها باستخدام `useRef`.

| وجه المقارنة | Controlled Components | Uncontrolled Components |
|---|---|---|
| مصدر الحقيقة | React State | الـ DOM نفسه |
| جلب القيمة | بتتربط بـ `value` وتقرأ من الـ State | بنستخدم `useRef` عشان نجيب القيمة |

```jsx
// Controlled Component (React State dictates the input value)
function ControlledInput() {
  const [text, setText] = useState("");
  return <input value={text} onChange={(e) => setText(e.target.value)} />;
}
```

### الفايدة الانترفيوية
What is the difference between Controlled and Uncontrolled Components?
**الإجابة المثالية:** In a Controlled Component, form data is handled by React state, giving you real-time control over the inputs. In an Uncontrolled Component, form data is handled by the DOM itself, and you access values using refs when needed.

---

## Q16 — إيه الـ Higher-Order Components (HOC) وإيه المشكلة اللي بتحلها؟

### أصل الحكاية
الـ (HOC) هو عبارة عن Function بتاخد Component وترجع Component جديد متزود عليه منطق (Logic) زيادة. بيستخدم لإعادة استخدام الـ Logic بين Components كتير، زي التأكد من تسجيل الدخول.

```jsx
// HOC that adds an 'isLoading' prop handling
function withLoading(WrappedComponent) {
  return function WithLoadingComponent({ isLoading, ...props }) {
    if (isLoading) return <div>Loading...</div>;
    return <WrappedComponent {...props} />;
  };
}
```

### الفايدة الانترفيوية
What is a Higher-Order Component (HOC)?
**الإجابة المثالية:** A Higher-Order Component is a function that takes a component and returns a new enhanced component. It is an advanced pattern used for reusing component logic, such as adding authentication checks across multiple components.

---

## Q17 — إيه الـ Render Props Pattern وإزاي بيختلف عن الـ HOC؟

### أصل الحكاية
الـ (Render Props) هو Pattern بنبعت فيه Function كـ prop للـ Component، والـ Component ده بيستدعي الـ Function دي عشان يحدد إيه اللي هيترسم. هو بديل للـ (HOC) وبيحل نفس مشكلة إعادة الاستخدام بس بطريقة أوضح.

```jsx
// Render Props pattern
function MouseTracker({ render }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  return render(position); // The child decides how to render the data
}

// Usage
<MouseTracker render={(pos) => <div>X: {pos.x}, Y: {pos.y}</div>} />
```

### الفايدة الانترفيوية
What is the Render Props pattern?
**الإجابة المثالية:** The Render Props pattern involves passing a function as a prop to a component, which that component uses to determine what to render. It solves the same code reusability problems as HOCs but offers a more explicit data flow.

---

## Q18 — إيه الـ State وإزاي بيختلف عن الـ Props في التحكم فيه؟

### أصل الحكاية
الـ (State) هي ذاكرة الـ Component الخاصة بيه، وبيستخدمها عشان يحتفظ ببيانات بتتغير بمرور الوقت بناءً على تفاعل المستخدم. عكس الـ (Props) اللي بتيجي من بره، الـ State بتتدار من جوا الـ Component نفسه ولما تتغير بتعمل إعادة رسم (Re-render).

```jsx
// State is managed internally
function Counter() {
  const [count, setCount] = useState(0); // State
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### الفايدة الانترفيوية
What is State in React and how does it differ from Props?
**الإجابة المثالية:** State is a built-in object that stores property values belonging to a component. While Props are passed from the outside and are read-only, State is managed internally by the component itself, and updating it triggers a UI re-render.

---

## Q19 — إيه الـ `useState` Hook وإزاي بيشتغل؟

### أصل الحكاية
الـ `useState` هو دالة بتسمح للـ (Functional Components) إنها تحتفظ بـ State. بترجعلك Array فيه عنصرين: القيمة الحالية للـ State، ودالة عشان تحدث بيها القيمة دي.

```jsx
// useState returns the current state and a setter function
const [name, setName] = useState('Ahmed');

// Updating the state
<button onClick={() => setName('Ali')}>Change Name</button>
```

### الفايدة الانترفيوية
What is the `useState` Hook?
**الإجابة المثالية:** The `useState` hook allows functional components to have state variables. It takes the initial state as an argument and returns an array containing the current state value and a function to update it.

---

## Q20 — ليه بنستخدم الـ Functional Update Form في `setState` بدل القيمة المباشرة أحياناً؟

### أصل الحكاية
لما تكون الـ State الجديدة بتعتمد على الـ State القديمة، يُفضل تمرر Function للـ Setter (زي `setCount(prev => prev + 1)`). لأن ريأكت ممكن يجمع كذا تحديث مع بعض (Batching)، فلو استخدمت القيمة المباشرة ممكن تعتمد على قيمة قديمة مش متحدثة.

```jsx
// Correct way to update state based on previous state
function increment() {
  setCount(prevCount => prevCount + 1);
}
```

### الفايدة الانترفيوية
Why use the functional update form in `setState` (`setCount(prev => prev + 1)`)?
**الإجابة المثالية:** You should use the functional update form when the new state depends on the previous state. It guarantees that you are working with the most up-to-date state value, especially since React can batch state updates asynchronously.

---

## Q21 — إيه قواعد استخدام الـ Hooks الأساسية؟

### أصل الحكاية
الـ (Hooks) لازم تتنادى دايماً في الـ Top Level بتاع الـ Component، يعني مينفعش تحطها جوه (Loops) أو `if conditions` أو دوال متداخلة. ريأكت بتعتمد على ترتيب استدعاء الـ Hooks عشان تعرف تربط كل State بالـ Hook بتاعها.

```jsx
function BadComponent() {
  // ERROR! Hooks cannot be inside conditions
  if (condition) {
    const [data, setData] = useState(null); 
  }
}
```

### الفايدة الانترفيوية
What are the Rules of Hooks?
**الإجابة المثالية:** Hooks must only be called at the top level of a React functional component or custom hook. They cannot be called inside loops, conditions, or nested functions to ensure they are executed in the exact same order on every render.

---

## Q22 — إيه الـ `useContext` Hook وإزاي بيحل مشكلة الـ Prop Drilling؟

### أصل الحكاية
الـ `useContext` بيسمحلك تقرأ داتا من (Context) موجود في مستوى أعلى في الشجرة، من غير ما تضطر تمرر الداتا دي عن طريق الـ Props في كل مستوى في النص. ده بيحل مشكلة الـ (Prop Drilling) للداتا العامة زي الـ Theme أو بيانات اليوزر.

```jsx
// Accessing Context directly without props
const ThemeContext = React.createContext('light');

function Display() {
  const theme = useContext(ThemeContext);
  return <div>Current theme: {theme}</div>;
}
```

### الفايدة الانترفيوية
What is `useContext` and how does it solve Prop Drilling?
**الإجابة المثالية:** The `useContext` hook lets a component subscribe to React Context without introducing nesting. It solves Prop Drilling by allowing deep components to consume global data directly, bypassing the intermediate components that don't need it.

---

## Q23 — إيه الـ `useReducer` Hook وإمتى تستخدمه بدل `useState`؟

### أصل الحكاية
الـ `useReducer` هو بديل للـ `useState`، بس بيستخدم لما تكون الـ State معقدة وفيها أكتر من قيمة بيعتمدوا على بعض، أو لما يكون منطق التحديث (Logic) كبير. بتكتب دالة (Reducer) بتحدد إزاي الـ State تتغير بناءً على (Action).

```jsx
// Reducer function taking current state and action
function reducer(state, action) {
  if (action.type === 'increment') return { count: state.count + 1 };
  return state;
}

const [state, dispatch] = useReducer(reducer, { count: 0 });
// dispatch({ type: 'increment' })
```

### الفايدة الانترفيوية
When should you use `useReducer` instead of `useState`?
**الإجابة المثالية:** You should use `useReducer` when you have complex state logic that involves multiple sub-values, or when the next state depends heavily on the previous one. It centralizes the state transition logic in a single reducer function.

---

## Q24 — إيه الفرق بين `useReducer` وRedux؟

### أصل الحكاية
الاتنين بيستخدموا نفس الفكرة (Reducer و Actions)، بس `useReducer` هو Hook مدمج جوه ريأكت لإدارة (Local State) جوه Component واحد (أو عدد قليل مع Context)، أما (Redux) فهي مكتبة خارجية لإدارة الـ (Global State) للتطبيق كله.

| وجه المقارنة | `useReducer` | Redux |
|---|---|---|
| النطاق | Local State (خاص بـ Component) | Global State (لكل التطبيق) |
| الإعداد | جاهز ومدمج في React | محتاج تسطيب وإعدادات (Store, Middleware) |

### الفايدة الانترفيوية
What is the difference between `useReducer` and Redux?
**الإجابة المثالية:** Both share the same architecture of dispatching actions to a reducer. However, `useReducer` is a built-in React hook meant for complex local state within a component, while Redux is a standalone library used for managing application-wide global state.

---

## Q25 — إيه الـ Custom Hooks وإزاي بتعمل واحد لإعادة استخدام منطق معين بين Components؟

### أصل الحكاية
الـ (Custom Hook) هو دالة جافاسكريبت عادية بتبدأ بكلمة `use`، وبتقدر تنادي جواها Hooks تانية. بنعمله عشان ناخد منطق متكرر (زي مثلاً جلب بيانات أو حالة الإنترنت) ونحطه في مكان واحد ونعيد استخدامه.

```jsx
// Custom Hook for fetching data
function useFetch(url) {
  const [data, setData] = useState(null);
  useEffect(() => { fetch(url).then(r => r.json()).then(setData); }, [url]);
  return data;
}

// Reusing the logic
const data = useFetch('/api/users');
```

### الفايدة الانترفيوية
What are Custom Hooks?
**الإجابة المثالية:** Custom hooks are JavaScript functions whose names start with "use" and that may call other hooks. They allow developers to extract and share stateful logic and side effects across multiple components without duplicating code.

---

## Q26 — إيه الـ `useRef` Hook وإزاي بيختلف عن الـ State في إنه مبيعملش Re-render؟

### أصل الحكاية
الـ `useRef` بيرجعلك Object فيه خاصية `current` تقدر تخزن فيها أي قيمة. الاختلاف الجوهري عن الـ State إن لما قيمة الـ `useRef` تتغير، **مابتعملش (Re-render)** للـ Component، والقيمة دي بتفضل محفوظة بين الـ Renders.

```jsx
// Changing ref value does NOT trigger re-render
const renderCount = useRef(0);
useEffect(() => {
  renderCount.current += 1;
});
```

### الفايدة الانترفيوية
How does `useRef` differ from `useState`?
**الإجابة المثالية:** The `useRef` hook holds a mutable value in its `.current` property that persists across renders. Unlike `useState`, mutating a ref does not trigger a component re-render, making it perfect for storing mutable values that shouldn't affect the UI visually.

---

## Q27 — إمتى تستخدم `useRef` عملياً؟

### أصل الحكاية
أشهر استخدامين ليه: أول حاجة إنك توصل لعنصر في الـ DOM مباشرة (زي إنك تعمل Focus على Input). وتاني حاجة إنك تخزن قيمة عايز تحتفظ بيها بين الـ Renders من غير ما تسبب إعادة رسم، زي إنك تخزن ID بتاع `setInterval`.

```jsx
// 1. Accessing DOM element directly
const inputRef = useRef(null);
const focusInput = () => inputRef.current.focus();

<input ref={inputRef} />
```

### الفايدة الانترفيوية
What are the practical use cases for `useRef`?
**الإجابة المثالية:** `useRef` is primarily used to directly access and manipulate DOM elements without using document.getElementById. It is also used to store mutable instance variables that persist across renders without causing unnecessary UI updates, such as timer IDs.

---

## Q28 — إيه الـ Component Lifecycle الأساسي؟

### أصل الحكاية
أي Component بيمر بـ 3 مراحل أساسية: التركيب (Mounting) لما يظهر لأول مرة، التحديث (Updating) لما الـ Props أو الـ State تتغير، والإزالة (Unmounting) لما يتمسح من الشاشة.

```jsx
// Lifecycles handled by useEffect
useEffect(() => {
  console.log("Mounted!"); // Mounting phase
  return () => console.log("Unmounted!"); // Unmounting phase
}, []); 
```

### الفايدة الانترفيوية
What are the main phases of a React component's lifecycle?
**الإجابة المثالية:** The component lifecycle consists of three main phases: Mounting (when the component is first inserted into the DOM), Updating (when it re-renders due to prop or state changes), and Unmounting (when it is removed from the DOM).

---

## Q29 — إيه الـ `useEffect` Hook وإزاي بيحاكي الـ Lifecycle Methods؟

### أصل الحكاية
الـ `useEffect` بيسمح للـ Functional Components إنها تعمل تأثيرات جانبية (Side Effects) زي جلب البيانات من API أو تعديل الـ DOM. هو بيجمع مهام دوال الـ (Class Components) القديمة كلها في مكان واحد.

```jsx
// Simulating componentDidMount
useEffect(() => {
  fetchData();
}, []); // Empty array ensures it runs only once
```

### الفايدة الانترفيوية
What is the `useEffect` hook?
**الإجابة المثالية:** `useEffect` is a hook that lets you perform side effects in functional components. By controlling its dependency array and cleanup function, it can replicate the behavior of class lifecycle methods like `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount`.

---

## Q30 — إيه الـ Dependency Array في `useEffect` وإزاي بيتحكم في إمتى الـ Effect بيتنفذ تاني؟

### أصل الحكاية
مصفوفة الاعتماديات (Dependency Array) هي الباراميتر التاني في الـ `useEffect`. إنت بتحط فيها المتغيرات اللي الـ Effect بيعتمد عليها، وريأكت بتنفذ الـ Effect ده تاني **فقط** لو أي متغير جوا المصفوفة دي اتغير.

```jsx
const [userId, setUserId] = useState(1);
// Runs again ONLY when userId changes
useEffect(() => {
  fetchUser(userId);
}, [userId]); 
```

### الفايدة الانترفيوية
What is the purpose of the dependency array in `useEffect`?
**الإجابة المثالية:** The dependency array tells React when to re-run the effect. React will compare the current values in the array with their values from the previous render, and will only re-execute the effect if at least one dependency has changed.

---

## Q31 — إيه الفرق بين `useEffect` بـ Dependency Array فاضية `[]` وبدون Dependency Array خالص؟

### أصل الحكاية
لو حطيت مصفوفة فاضية `[]`، الـ Effect هيتنفذ مرة واحدة بس أول ما الـ Component يظهر. لو محطيتش مصفوفة خالص، الـ Effect هيتنفذ بعد **كل** تحديث (Render) يحصل للـ Component، وده ممكن يبطأ التطبيق جداً.

| الـ Array | إمتى بيتنفذ؟ |
|---|---|
| `useEffect(fn, [])` | مرة واحدة بس في البداية (Mounting) |
| `useEffect(fn)` | بعد كل Render (تحديث) |

### الفايدة الانترفيوية
What happens if you omit the dependency array in `useEffect`?
**الإجابة المثالية:** If you omit the dependency array completely, the effect will run after every single render of the component. Passing an empty array `[]` ensures the effect runs exactly once after the initial mount.

---

## Q32 — إيه الـ Cleanup Function في `useEffect` وإمتى بتتنفذ؟

### أصل الحكاية
دالة التنضيف (Cleanup Function) هي الدالة اللي إنت بترجعها (Return) جوه الـ `useEffect`. دي بتتنفذ لما الـ Component يتمسح من الشاشة (Unmounting)، أو قبل ما الـ Effect يتنفذ المرة الجاية، عشان تنضف وراها زي إلغاء (Timer).

```jsx
useEffect(() => {
  const timer = setInterval(() => console.log('Tick'), 1000);
  
  // Cleanup function to clear the interval
  return () => clearInterval(timer);
}, []);
```

### الفايدة الانترفيوية
What is the cleanup function in `useEffect`?
**الإجابة المثالية:** The cleanup function is the function returned from an effect. React runs it before the component unmounts or before re-running the effect due to dependency changes, to clean up subscriptions, timers, or event listeners and prevent memory leaks.

---

## Q33 — إيه أشهر فخ في `useEffect`؟ (الـ Infinite Loop)

### أصل الحكاية
أشهر فخ هو الدخول في حلقة مفرغة (Infinite Loop). ده بيحصل لما تحدث (State) جوه الـ Effect، ويكون الـ Effect مفيش فيه مصفوفة اعتماديات، أو تكون حاطط الـ State دي نفسها جوه المصفوفة. فالتحديث يعمل Render، والـ Render يشغل الـ Effect، وهكذا.

```jsx
// ❌ DANGER: Infinite Loop!
const [count, setCount] = useState(0);
useEffect(() => {
  setCount(count + 1); // Triggers re-render, running effect again!
}); 
```

> [!warning] فخ كمان
> لو حطيت Object أو Array بتتعرّف جوه الـ Component في الـ Dependency Array، هتعمل Infinite Loop لأن عنوانها في الميموري (Reference) بيتغير كل Render.

### الفايدة الانترفيوية
How do you cause and prevent an infinite loop in `useEffect`?
**الإجابة المثالية:** An infinite loop occurs when you update a state variable inside an effect without properly configuring the dependency array. It is prevented by correctly specifying exact dependencies and ensuring object references are stable.

---

## Q34 — إيه الفرق بين `useEffect` و`useLayoutEffect`؟

### أصل الحكاية
الـ `useEffect` بيشتغل في الخلفية **بعد** ما الشاشة تترسم، فمش بيعطل الرؤية. الـ `useLayoutEffect` بيشتغل **قبل** ما البراوزر يعرض التعديلات على الشاشة (Synchronous)، وبنستخدمه نادراً لو بنقيس أبعاد عنصر في الـ DOM عشان نمنع الشاشة ترمش (Flicker).

```jsx
// Block the browser from painting until this finishes
useLayoutEffect(() => {
  const height = ref.current.clientHeight;
  // Make immediate DOM mutations based on height
}, []);
```

### الفايدة الانترفيوية
What is the difference between `useEffect` and `useLayoutEffect`?
**الإجابة المثالية:** `useEffect` runs asynchronously after the browser has painted the screen, making it suitable for most side effects. `useLayoutEffect` runs synchronously immediately after DOM mutations but before the screen is painted, useful for measuring elements to prevent visual flickering.

---
