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

## Q35 — ليه Component بيعمل Re-render أصلاً؟

### أصل الحكاية
الـ Component بيعيد رسم نفسه (Re-render) في 3 حالات أساسية: أولاً لو الـ (State) بتاعته اتغيرت، ثانياً لو الـ (Props) اللي جياله من الأب اتغيرت، وثالثاً والأهم: لو الـ Parent Component بتاعه حصله Re-render (وقتها كل أبنائه هيحصلهم Re-render حتى لو مفيش حاجة اتغيرت فيهم).

```jsx
// A child component will re-render if the parent does, unless optimized
function Parent() {
  const [count, setCount] = useState(0);
  return <Child />; // Child re-renders every time count changes!
}
```

### الفايدة الانترفيوية
What causes a React component to re-render?
**الإجابة المثالية:** A React component re-renders when its state changes, its props change, or when its parent component re-renders. A parent's re-render forces all of its descendants to re-render by default.

---

## Q36 — إيه الـ `React.memo` وإزاي بيمنع Re-render غير ضروري؟

### أصل الحكاية
الـ `React.memo` بيغلف الـ Component ويقول لريأكت: "لو الـ (Props) ماتغيرتش، ماتعملش (Re-render) للـ Component ده حتى لو الأب حصله Re-render". ده بيحسن الأداء جداً في الـ Components اللي بتترسم كتير ومحتواها ثابت.

```jsx
// Child only re-renders if its props change
const Child = React.memo(function Child(props) {
  return <div>{props.text}</div>;
});
```

### الفايدة الانترفيوية
What is `React.memo`?
**الإجابة المثالية:** `React.memo` is a higher-order component that prevents a functional component from re-rendering if its props have not changed. It is a performance optimization tool for components that render frequently with the same props.

---

## Q37 — إيه الـ `useMemo` Hook وإمتى تستخدمه؟

### أصل الحكاية
الـ `useMemo` بيحفظ (Caches) نتيجة عملية حسابية تقيلة، ومابيحسبهاش تاني إلا لو المتغيرات اللي بتعتمد عليها اتغيرت. ده بيوفر وقت الـ (CPU) بدل ما الحسبة الثقيلة تتنفذ من الصفر في كل Render.

```jsx
// Only re-calculate expensive result if 'data' changes
const expensiveResult = useMemo(() => {
  return performHeavyCalculation(data);
}, [data]);
```

### الفايدة الانترفيوية
What is the `useMemo` hook used for?
**الإجابة المثالية:** `useMemo` is used to memoize the result of an expensive calculation so it is only re-computed when its dependencies change, rather than on every single render.

---

## Q38 — إيه الـ `useCallback` Hook وإزاي بيختلف عن `useMemo`؟ (جدول مقارنة)

### أصل الحكاية
الـ `useCallback` بيحفظ الـ (Function) نفسها مش نتيجتها، عشان ميخلقش دالة جديدة في الميموري كل Render. ده بيفيد جداً لو بتبعت الدالة دي كـ Prop لـ Component معموله `React.memo`، عشان عنوان الدالة (Reference) مايتغيرش ويكسر الـ Memoization.

| وجه المقارنة | `useMemo` | `useCallback` |
|---|---|---|
| بيرجع إيه؟ | بيرجع **قيمة** (نتيجة حسابية) | بيرجع **الدالة** (Function) نفسها |
| إمتى أستخدمه؟ | للحسابات التقيلة المعقدة | لتمرير دوال للـ Child Components بثبات |

```jsx
// Preserves the function reference across re-renders
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

### الفايدة الانترفيوية
What is `useCallback` and how does it differ from `useMemo`?
**الإجابة المثالية:** `useCallback` memoizes a function definition, preventing it from being recreated on every render, which is useful for passing stable callbacks to child components. `useMemo` memoizes the returned value of a function.

---

## Q39 — إيه فخ استخدام `useMemo`/`useCallback` في كل حتة بدون داعي؟

### أصل الحكاية
الـ (Memoization) نفسها ليها تكلفة في الميموري وسرعة التنفيذ لأنها بتحتاج تقارن المتغيرات (Dependencies) كل مرة. لو استخدمتهم مع دوال أو حسابات بسيطة جداً، التكلفة دي هتبقى أسوأ من إنك تسيب الـ Component يعمل Re-render طبيعي. 

```jsx
// ❌ DANGER: Overusing memoization for simple things degrades performance
const simpleSum = useMemo(() => a + b, [a, b]); // Too simple, not worth memoizing!
```

### الفايدة الانترفيوية
Why shouldn't you use `useMemo` and `useCallback` everywhere?
**الإجابة المثالية:** Memoization comes with its own performance overhead due to memory allocation and dependency comparison. Using them for trivial calculations or components can actually degrade performance rather than improve it.

---

## Q40 — إيه الـ Code Splitting وإزاي `React.lazy` و`Suspense` بيقللوا حجم الـ Bundle الأولي؟

### أصل الحكاية
التطبيقات الكبيرة بيبقى حجم كود الجافاسكريبت بتاعها ضخم جداً لو اتحمل مرة واحدة (Bundle). الـ (Code Splitting) بيقسم الكود ده لأجزاء، و`React.lazy` بيخليك تحمل الـ Components بس وقت ما اليوزر يحتاجها (زي لما يفتح صفحة معينة)، و`Suspense` بيعرض شاشة تحميل (Loader) لحد ما الكود يوصل.

```jsx
// Dynamically import the component only when needed
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <React.Suspense fallback={<LoadingSpinner />}>
      <HeavyComponent />
    </React.Suspense>
  );
}
```

### الفايدة الانترفيوية
What is Code Splitting and how do `React.lazy` and `Suspense` work?
**الإجابة المثالية:** Code Splitting breaks a large JavaScript bundle into smaller chunks. `React.lazy` allows you to load components asynchronously only when they are rendered, while `Suspense` provides a fallback UI during the loading phase, significantly speeding up initial load times.

---

## Q41 — إيه الـ Virtualization وإمتى تحتاجها مع الـ Lists الطويلة جداً؟

### أصل الحكاية
لو عندك قايمة فيها 10 آلاف عنصر، رسمهم كلهم في الـ DOM هيعلق البراوزر. الـ (Virtualization) أو (Windowing) باستخدام مكتبة زي `react-window` بترسم فقط العناصر اللي ظاهرة حالياً في شاشة اليوزر، ولما تعمل Scroll تبدلهم، وده بيخلي الأداء طلقة.

```jsx
// Using a library like react-window to render only visible items
import { FixedSizeList as List } from 'react-window';

const Row = ({ index, style }) => (
  <div style={style}>Row {index}</div>
);

<List height={150} itemCount={1000} itemSize={35} width={300}>
  {Row}
</List>
```

### الفايدة الانترفيوية
What is list Virtualization (Windowing) in React?
**الإجابة المثالية:** Virtualization is a performance optimization technique for rendering large lists. Instead of rendering all DOM nodes, it only renders the items currently visible in the user's viewport, drastically reducing memory usage and rendering time.

---

## Q42 — إيه الـ React Router وإيه المشكلة اللي بيحلها في الـ Single Page Applications؟

### أصل الحكاية
تطبيقات (SPA) بتبقى صفحة (HTML) واحدة بس. الـ React Router بيخلينا نقدر نتنقل بين "صفحات" أو شاشات مختلفة جوه التطبيق بتاعنا، وبيلعب في مسار اللينك (URL) من غير ما يعمل Refresh كامل للصفحة، فبيخلي التجربة أسرع كتير.

```jsx
// Using React Router to navigate without page reloads
import { BrowserRouter, Route, Routes } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
      </Routes>
    </BrowserRouter>
  );
}
```

### الفايدة الانترفيوية
What is React Router and its purpose?
**الإجابة المثالية:** React Router is a standard library for routing in React. It enables navigation among views of various components in a Single Page Application (SPA), allowing the URL to change and keeping the UI in sync without a full page reload.

---

## Q43 — إيه الفرق بين الـ Client-Side Routing والـ Server-Side Routing؟

### أصل الحكاية
في الـ (Server-Side)، كل ما تدوس على لينك، البراوزر بيبعت طلب للسيرفر ويرجع بصفحة HTML جديدة بالكامل. أما في الـ (Client-Side) زي ريأكت، إنت بتحمل التطبيق مرة واحدة، ولما تدوس على لينك، الجافاسكريبت هو اللي بيبدل الـ Components على الشاشة من غير ما يكلم السيرفر لطلب صفحة جديدة.

```jsx
// Client-side navigation intercepting standard link clicks
import { Link } from 'react-router-dom';
// Using <Link> instead of <a> prevents the browser default reload
<Link to="/about">About Us</Link>
```

### الفايدة الانترفيوية
What is the difference between Client-Side and Server-Side Routing?
**الإجابة المثالية:** Server-Side Routing fetches a completely new HTML page from the server for every URL change. Client-Side Routing uses JavaScript to intercept the URL change and dynamically swap UI components directly in the browser, eliminating full page reloads.

---

## Q44 — إيه مشكلة الـ "Prop Drilling على مستوى التطبيق كله" اللي بتخلينا نحتاج State Management Library؟

### أصل الحكاية
لما التطبيق بيكبر، بتلاقي بيانات زي (بيانات اليوزر، الثيم، سلة المشتريات) محتاجينها في Components كتير بعيدة جداً عن بعض في الشجرة. لو فضلت تنقلها كـ Props، الكود هيبقى فوضى وصعب إدارته، وهنا بنحتاج مكان مركزي (Global Store) نخزن فيه الداتا دي.

```jsx
// Painful Prop Drilling for global state
<App user={user}>
  <Header user={user}>
    <Nav user={user}>
      <UserProfile user={user} /> // Finally using it!
    </Nav>
  </Header>
</App>
```

### الفايدة الانترفيوية
Why do we need State Management libraries in large React applications?
**الإجابة المثالية:** As applications grow, sharing state across deeply nested or totally unrelated components via prop drilling becomes unmaintainable. State management libraries provide a centralized global store, allowing any component to access shared data directly.

---

## Q45 — إيه الـ Context API وإمتى بتبقى كفاية بدل مكتبة خارجية زي Redux؟

### أصل الحكاية
الـ (Context API) هي أداة مدمجة جوا ريأكت بتسمحلك تشارك داتا بين الـ Components بدون تمرير Props. بتبقى كفاية جداً وممتازة لو الداتا بتاعتك **مش بتتغير كتير** (زي الـ Theme، أو بيانات اليوزر بعد تسجيل الدخول).

```jsx
// Creating and providing Context
const ThemeContext = createContext();

<ThemeContext.Provider value="dark">
  <MyApp />
</ThemeContext.Provider>
```

### الفايدة الانترفيوية
When should you use the Context API instead of Redux?
**الإجابة المثالية:** The Context API is built into React and is ideal for sharing global data that does not change frequently, such as user authentication state or UI themes. It avoids the extra boilerplate of Redux.

---

## Q46 — إيه الـ Redux بشكل عام؟

### أصل الحكاية
الـ Redux هي مكتبة لإدارة الـ (Global State) بتعتمد على 3 حاجات: الـ (Store) هو المخزن الكبير، والـ (Action) هو طلب التعديل اللي بنبعته، والـ (Reducer) هو الموظف اللي بياخد الطلب ويحدث الـ Store. ده بيخلي تتبع الداتا دقيق جداً.

```javascript
// A simple Redux reducer logic
function counterReducer(state = { value: 0 }, action) {
  switch (action.type) {
    case 'counter/incremented':
      return { value: state.value + 1 };
    default:
      return state;
  }
}
```

### الفايدة الانترفيوية
What is Redux and what are its core concepts?
**الإجابة المثالية:** Redux is a predictable state container. Its core concepts are the Store (holding the global state), Actions (plain objects describing what happened), and Reducers (pure functions that specify how the state changes in response to an action).

---

## Q47 — إيه الفرق بين الـ Context API والـ Redux من ناحية الأداء مع تحديثات متكررة؟

### أصل الحكاية
الـ (Context API) بيعمل Re-render لكل الـ Components اللي بتستخدمه لو قيمته اتغيرت، فلو الداتا بتتغير بسرعة، هيعمل بطء. لكن (Redux) أذكى، بيسمح للـ Component يشترك في **جزء معين بس** من الـ State، فمش بيعمل Re-render إلا لو الجزء ده اتغير.

| وجه المقارنة | Context API | Redux |
|---|---|---|
| تحديثات سريعة ومعقدة | ضعيف الأداء (بيعمل Re-render كتير) | ممتاز (بيعمل Re-render للمشتركين في الجزء المتغير بس) |
| الإعداد | سهل جداً | معقد ومحتاج كود كتير (Boilerplate) |

### الفايدة الانترفيوية
How does Context API compare to Redux in terms of performance with frequent updates?
**الإجابة المثالية:** Context API triggers a re-render for all consumers whenever its value changes, making it inefficient for high-frequency state updates. Redux handles this better because components can subscribe to specific slices of the state, preventing unnecessary re-renders.

---

## Q48 — إيه الـ React Query (أو SWR) وإيه المشكلة اللي بتحلها في التعامل مع الـ Server State تحديداً؟

### أصل الحكاية
زمان كنا بنستخدم Redux عشان نخزن الداتا اللي جاية من الـ API (الـ Server State). بس ده كان معقد جداً. الـ (React Query) جت حلت المشكلة دي بإنها بتتكفل بجلب الداتا، وتحفظها (Caching)، وتعيد جلبها، وتديلك حالات الـ (Loading) جاهزة من غير ما تكتب كود كتير.

```jsx
// React Query handles fetching, caching, loading, and error states elegantly
const { data, isLoading, error } = useQuery('users', fetchUsers);

if (isLoading) return <span>Loading...</span>;
if (error) return <span>Error fetching data</span>;
```

### الفايدة الانترفيوية
What problem does React Query (or SWR) solve?
**الإجابة المثالية:** React Query simplifies handling asynchronous server state. It out-of-the-box manages data fetching, caching, background synchronization, and loading/error states, effectively removing the need to store server data in global state libraries like Redux.

---

## Q49 — إيه الـ Error Boundaries وإزاي بتمسك الأخطاء في شجرة الـ Components من غير ما التطبيق كله يقفل؟

### أصل الحكاية
لو حصل (Error) في الـ (Render) بتاع Component معين، التطبيق كله بيكراش والشاشة بتبقى بيضا. الـ (Error Boundaries) هي (Class Components) مخصصة بتمسك الأخطاء دي، وتمنع التطبيق من إنه يقفل، وتعرض شاشة بديلة (Fallback UI) بدل الـ Component اللي باظ.

```jsx
// Error Boundary requires Class Components (using componentDidCatch or getDerivedStateFromError)
class ErrorBoundary extends React.Component {
  state = { hasError: false };
  static getDerivedStateFromError(error) { return { hasError: true }; }
  render() {
    if (this.state.hasError) return <h1>Something went wrong.</h1>;
    return this.props.children; 
  }
}
```

### الفايدة الانترفيوية
What are Error Boundaries in React?
**الإجابة المثالية:** Error boundaries are React components that catch JavaScript errors anywhere in their child component tree, log those errors, and display a fallback UI instead of crashing the whole application tree.

---

## Q50 — إيه الـ Portals في React وإمتى تستخدمها؟

### أصل الحكاية
الـ (Portals) بتسمحلك ترسم Component في مكان مختلف تماماً في الـ (DOM Tree) بره الـ (Parent) المباشر بتاعه. ده مفيد جداً لما تحب تعمل (Modal) أو (Tooltip) وماتعوزش الـ CSS بتاع الـ Parent (زي الـ `overflow: hidden`) يأثر عليه أو يخفيه.

```jsx
// Renders the Modal component inside a specific DOM node outside the 'root'
function Modal({ children }) {
  return ReactDOM.createPortal(
    <div className="modal">{children}</div>,
    document.getElementById('modal-root')
  );
}
```

### الفايدة الانترفيوية
What are React Portals and when should you use them?
**الإجابة المثالية:** Portals provide a first-class way to render children into a DOM node that exists outside the DOM hierarchy of the parent component. They are commonly used for Modals, Tooltips, and Dropdowns to avoid CSS constraints like `overflow: hidden` or `z-index` issues from parent containers.

---

## Q51 — إيه الـ Fragments (`<>...</>`) وليه بنستخدمها بدل ما نلف الـ JSX بـ `div` زيادة؟

### أصل الحكاية
في ريأكت لازم كل Component يرجع عنصر واحد بس (Parent Element). زمان كنا بنضطر نلف الكود كله بـ `<div>` زيادة، وده كان بيبوظ الـ (HTML Semantic) ويزحم الـ DOM. الـ (Fragments) بتحل ده بإنها تلف العناصر من غير ما تترسم في الـ DOM النهائي.

```jsx
// Using a Fragment to group multiple elements without adding an extra node to the DOM
function Columns() {
  return (
    <>
      <td>Hello</td>
      <td>World</td>
    </>
  );
}
```

### الفايدة الانترفيوية
What are React Fragments?
**الإجابة المثالية:** React Fragments (`<React.Fragment>` or `<>...</>`) let you group a list of children without adding an extra node to the DOM. This is useful for returning multiple elements while keeping the DOM clean and preserving CSS layout mechanics like Flexbox or Grid.

---

## Q52 — إيه الفرق بين الـ SSR والـ CSR والـ SSG؟

### أصل الحكاية
- الـ **CSR (Client-Side Rendering):** ريأكت بتبعت صفحة فاضية وجافاسكريبت، والبراوزر هو اللي بيبني الـ UI (أداء بطيء في الأول، ومضر لـ SEO).
- الـ **SSR (Server-Side Rendering):** السيرفر بيبني الـ UI ويبعت صفحة HTML جاهزة مع كل طلب (ممتاز لـ SEO وأول تحميل سريع، بس السيرفر بيتعب).
- الـ **SSG (Static Site Generation):** الـ HTML بيتبني مرة واحدة وقت الـ Build وبيتقدم لكل اليوزرز (أسرع حاجة، بس للصفحات اللي مابتتغيرش كتير).

| التقنية | متى يتم بناء الـ HTML؟ | مميزات |
|---|---|---|
| CSR | في متصفح اليوزر | تفاعل أسرع بعد التحميل |
| SSR | على السيرفر لكل طلب | SEO ممتاز، أول ظهور أسرع |
| SSG | على السيرفر وقت الـ Build | أداء صاروخي، مثالي للمدونات |

### الفايدة الانترفيوية
What is the difference between Client-Side Rendering (CSR), Server-Side Rendering (SSR), and Static Site Generation (SSG)?
**الإجابة المثالية:** In CSR, the browser downloads a minimal HTML page and uses JavaScript to render the UI. In SSR, the server generates the full HTML for every request, improving initial load and SEO. In SSG, the HTML is generated once at build time, offering the best performance for static content.

---

## Q53 — إيه الـ Hydration في سياق الـ SSR؟

### أصل الحكاية
لما بتستخدم SSR، السيرفر بيبعت صفحة (HTML) حية شكلاً بس ميتة فعلياً (مفيش زراير بتشتغل). البراوزر بيحمل الـ (JavaScript) بعدين ويربطه بالـ HTML اللي موجود عشان يخليه يتفاعل مع اليوزر. عملية الربط دي وبث الروح في الصفحة اسمها (Hydration).

```jsx
// In SSR (like Next.js), ReactDOM.hydrate is used instead of ReactDOM.render
// It attaches event listeners to the existing server-rendered HTML markup.
import { hydrateRoot } from 'react-dom/client';
hydrateRoot(document.getElementById('root'), <App />);
```

### الفايدة الانترفيوية
What is Hydration in React?
**الإجابة المثالية:** Hydration is the process where React attaches event listeners and state to the static HTML markup generated by the server during Server-Side Rendering (SSR), effectively turning it into a fully interactive React application.

---

## Q54 — إيه الـ Strict Mode في React وليه بيعمل Renders مرتين في الـ Development؟

### أصل الحكاية
الـ (Strict Mode) هو أداة ريأكت بتشغلها وقت التطوير (Development) بس عشان تكتشف المشاكل في الكود بدري. بتعمل كدا عن طريق إنها بتشغل كل الـ Components والـ Effects مرتين ورا بعض عشان تتأكد إن الـ Functions بتاعتك (Pure) ومفيش أي (Side Effects) مستخبية بتأثر على الداتا.

```jsx
// Enabling Strict Mode for the entire app
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

### الفايدة الانترفيوية
What is React Strict Mode and why does it render components twice?
**الإجابة المثالية:** React Strict Mode is a development-only tool that highlights potential problems in an application. It intentionally double-invokes components and effects to help developers spot impure functions, unexpected side effects, and legacy lifecycle usage.

---

## Q55 — إيه الفرق بين الـ Synthetic Events في React والـ Native DOM Events؟

### أصل الحكاية
ريأكت مابتستخدمش الـ Events بتاعت البراوزر مباشرة. هي بتعمل طبقة تغليف (Wrapper) اسمها (Synthetic Event) بتوحد شكل الـ Events وسلوكها عبر كل البراوزرات (يعني كودك هيشتغل على كروم وسفاري وفايرفوكس بنفس الطريقة بالظبط). ده كمان بيحسن الأداء عن طريق الـ Event Delegation.

```jsx
// React passes a SyntheticEvent (e), which has the same interface as native events
function handleClick(e) {
  e.preventDefault(); // Works consistently across all browsers
  console.log(e.target.value);
}
```

### الفايدة الانترفيوية
What are Synthetic Events in React?
**الإجابة المثالية:** A Synthetic Event is a cross-browser wrapper around the browser's native event. React uses it to ensure that events have consistent behavior across different browsers and to optimize performance using a single event listener at the root of the document (Event Delegation).

---

## Q56 — إيه اللي بيحصل بالظبط لما تعمل `setState`؟ (أشهر سؤال إنترفيو)

### أصل الحكاية
لما بتنادي `setState`، ريأكت مابتغيرش الشاشة في لحظتها. اللي بيحصل بالترتيب:
1. ريأكت بتسجل إن الـ State دي هتتغير وبتجمع التحديثات مع بعض (Batching) لو فيه كذا تحديث.
2. ريأكت بتنده الـ Component Function من أول وجديد (Render Phase) وتقارن شجرة الـ Virtual DOM الجديدة بالقديمة (Reconciliation).
3. لو لقت تغيير فعلي، بتروح تحدث الـ Real DOM بالتغيير ده بس (Commit Phase).

```jsx
function incrementTwice() {
  // Due to batching, React groups these updates and re-renders only ONCE.
  setCount(c => c + 1);
  setCount(c => c + 1);
}
```

### الفايدة الانترفيوية
What happens exactly when you call `setState` in React?
**الإجابة المثالية:** When `setState` is called, React batches the state updates and schedules a re-render. During the render phase, it creates a new Virtual DOM tree and diffs it against the old one. Finally, in the commit phase, it updates the actual DOM with only the necessary changes computed from the diffing process.

---
