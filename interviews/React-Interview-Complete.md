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
