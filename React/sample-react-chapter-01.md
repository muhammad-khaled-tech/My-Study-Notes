# الفصل الأول — React: الـ Component والـ JSX — لبنة كل حاجة

> **المتطلبات:** [[00-JavaScript-Essentials]] — لازم تعرف الـ ES6+ كويس: arrow functions، destructuring، spread operator، وmodules. الفصل ده بيبني فوقهم مباشرةً.

---

## البداية — المشكلة اللي React جاءت تحلّها

سنة 2013، Facebook كان بيواجه مشكلة حقيقية وكبيرة.

مش مشكلة في الـ servers، ولا في الـ database. المشكلة كانت في حاجة تانية خالص: **إزاي تخلّي الـ UI يتحدّث تلقائياً لما الـ data تتغيّر؟**

تخيّل معايا صفحة الـ Facebook feed. كل ثانية:
- إعلانات جديدة بتظهر
- الـ likes بتتحدّث في real-time
- الـ comments بتتضاف
- الـ notifications بتظهر في الـ header

في plain JavaScript، ده كان بيتعمل بالطريقة دي:

```javascript
// إزاي كنّا بنتحدّث الـ UI يدوياً — قبل React
function onLikePost(postId, newCount) {
  // لازم تعرف بالظبط إيه الـ element اللي محتاج يتحدّث
  const likeBtn = document.querySelector(`#post-${postId} .like-btn`);
  const likeCount = document.querySelector(`#post-${postId} .like-count`);
  const likeIcon = document.querySelector(`#post-${postId} .like-icon`);

  likeCount.textContent = newCount;                    // ← حدّث العدد
  likeBtn.classList.toggle('liked');                   // ← غيّر الـ style
  likeIcon.src = isLiked ? 'liked.png' : 'like.png'; // ← غيّر الأيقونة

  // وكمان لازم تحدّث الـ tooltip
  likeBtn.setAttribute('title', `${newCount} people liked this`);

  // وكمان لازم تحدّث الـ accessibility attributes
  likeBtn.setAttribute('aria-label', `Like, ${newCount} likes`);
}
```

كل تغيير بسيط في الـ data = عملية جراحة يدوية في الـ DOM. وكل ما التطبيق اتكبّر، الكود ده بقى:
- **هش** — تغيير الـ HTML structure بيكسّر الـ JavaScript
- **متكرر** — نفس الـ update logic في أماكن كتير
- **مستحيل الـ testing** — مربوط بالـ DOM مباشرةً

React جاءت بفكرة واحدة بسيطة غيّرت كل حاجة:

> بدل ما تقول "غيّر الـ element ده" — قول "الـ data دلوقتي شكلها كده" وخلّي React تفهم هي إيه اللي محتاج يتغيّر في الـ UI.

بمعنى آخر: أنت بتصف **النتيجة** مش **الخطوات**.

---

## [[01-What-Is-A-Component]] — الـ Component: الـ LEGO بتاع الـ Web

تخيّل معايا إنك بتبني بيت من LEGO. مش بتبنيه قطعة قطعة عشوائية — بتبني **وحدات**: غرفة نوم، صالة، مطبخ. كل وحدة مكتملة لوحدها، وممكن تستخدمها أكتر من مرة في البيت نفسه أو في بيوت تانية.

React بتفكّر بنفس الطريقة. الـ UI مش صفحة واحدة ضخمة — هو **مجموعة components** كل واحد مسؤول عن نفسه.

شوف صفحة TaskFlow بتاعتنا:

```
┌────────────────────────────────────────────────────────┐
│                    HEADER COMPONENT                    │
│   [TaskFlow Logo]    [Search]    [+New]    [Ali ▾]     │
├──────────────────┬─────────────────────────────────────┤
│                  │                                     │
│ SIDEBAR COMP     │        TASK BOARD                   │
│ ┌─────────────┐  │  ┌──────────┐  ┌──────────┐        │
│ │ My Tasks    │  │  │   TASK   │  │   TASK   │  ...   │
│ │ Team Tasks  │  │  │   CARD   │  │   CARD   │        │
│ │ Completed   │  │  │   COMP   │  │   COMP   │        │
│ └─────────────┘  │  └──────────┘  └──────────┘        │
│                  │                                     │
└──────────────────┴─────────────────────────────────────┘
```

كل جزء ده هو **component مستقل**. الـ `TaskCard` مش عارف إن في `Sidebar` — وده مقصود.

أبسط component ممكن تكتبه في React:

```jsx
// TaskCard.jsx — أبسط component ممكن
function TaskCard() {
  return (
    <div className="task-card">
      <h3>Fix login bug</h3>
      <span className="priority high">High Priority</span>
    </div>
  );
}

export default TaskCard;
```

ده الـ component كله. لاحظ إنه:
1. **function عادية** بتـreturn HTML (أو ما يشبه الـ HTML)
2. الاسم بيبدأ بـ **حرف كبير** — ده مش convention، ده **قاعدة** (هنفهم ليه بعدين)
3. بيتـexport عشان نستخدمه في أماكن تانية

---

## [[02-What-Is-JSX]] — الـ JSX: مش HTML، بس أحسن

لما شفت الكود اللي فات، ممكن قلت "ده HTML جوا JavaScript؟ ده غريب!" — وانت صح.

الـ JSX (JavaScript XML) مش HTML حقيقي. هو **syntax sugar** — اختصار بيكتبه developer وبيتحوّل تلقائياً لـ JavaScript عادي.

```jsx
// اللي بتكتبه أنت:
const element = <h1 className="title">Hello, TaskFlow!</h1>;

// اللي React بتحوّله لـ JavaScript فعلاً:
const element = React.createElement(
  'h1',
  { className: 'title' },
  'Hello, TaskFlow!'
);
```

الـ JSX بيوفّرلك إنك تكتب الـ UI بشكل مقروء بدل ما تكتب `React.createElement` في كل حاجة. لو ما كانش في JSX، الكود كان هيبقى:

```javascript
// بدون JSX — صعب القراءة
function TaskCard() {
  return React.createElement(
    'div',
    { className: 'task-card' },
    React.createElement('h3', null, 'Fix login bug'),
    React.createElement('span', { className: 'priority high' }, 'High Priority')
  );
}
```

ده بالظبط زي الفرق بين تكتب email بالـ HTML editor أو تكتب الـ HTML tags يدوياً — النتيجة واحدة، بس تجربة الكتابة مختلفة جداً.

### القواعد الأساسية للـ JSX

```jsx
// 1. لازم يبقى في عنصر واحد (أو Fragment)
function Good() {
  return (           // ← الـ parentheses مش إلزامية بس بتساعد في الـ formatting
    <div>            // ← عنصر wrapper واحد
      <h1>Hello</h1>
      <p>World</p>
    </div>
  );
}

// ❌ ده هيطلع error
function Bad() {
  return (
    <h1>Hello</h1>   // ← عنصرين في نفس المستوى بدون wrapper
    <p>World</p>
  );
}

// ✅ بديل بدون div إضافية: Fragment
function AlsogGood() {
  return (
    <>               // ← Fragment — مش بيضيف element في الـ DOM
      <h1>Hello</h1>
      <p>World</p>
    </>
  );
}

// 2. className مش class
<div className="task-card">   // ← في JSX
<div class="task-card">       // ← في HTML عادي

// 3. الـ tags لازم تتقفل دايماً
<input type="text" />         // ← self-closing ✅
<input type="text">           // ← ❌ error في JSX (مش في HTML)
<br />                        // ✅
```

> **نصيحة الخبراء:** الـ JSX بيترجمه الـ Babel (أو الـ Vite build tool) لـ JavaScript عادي قبل ما يوصل للـ browser. الـ browser مش عارف إن في حاجة اسمها JSX — ده كود بينفّذه على الـ machine بتاعتك وقت الـ build.

---

## [[03-Props]] — الـ Props: كيف الـ Components بتتكلّم مع بعض

لو كل component عنده data ثابتة hardcoded — ده مش مفيد. الـ `TaskCard` بتاعتنا دايماً هتقول "Fix login bug"؟

الـ **Props** (Properties) هي الطريقة اللي بتبعت بيها data من component لـ component تاني. بالظبط زي الـ waiter اللي بيبعت الأوردر من الـ table للـ kitchen — هو مش عارف إيه اللي في الـ order، هو بس بينقله.

```jsx
// TaskCard.jsx — بيستقبل props
function TaskCard(props) {
  return (
    <div className="task-card">
      <h3>{props.title}</h3>                    {/* ← الـ {} بتقول لـ JSX: "ده JavaScript مش text" */}
      <span className={`priority ${props.priority}`}>
        {props.priority} Priority
      </span>
      <p>Assigned to: {props.assignee}</p>
    </div>
  );
}

// App.jsx — بيبعت الـ props
function App() {
  return (
    <div>
      <TaskCard
        title="Fix login bug"          {/* ← ده prop */}
        priority="high"                {/* ← ده prop تاني */}
        assignee="Ali"                 {/* ← ده prop تالت */}
      />
      <TaskCard
        title="Update dashboard UI"
        priority="medium"
        assignee="Sara"
      />
    </div>
  );
}
```

اللي بيحصل هنا: الـ `App` بتبعت data للـ `TaskCard` كـ attributes، والـ `TaskCard` بتستقبلها في الـ `props` object.

### Destructuring الـ Props

في الواقع، بدل ما تكتب `props.title` في كل حاجة، الأكثر شيوعاً إنك تعمل destructuring:

```jsx
// ✅ الطريقة الأحسن — destructuring في الـ parameter
function TaskCard({ title, priority, assignee }) {
  return (
    <div className="task-card">
      <h3>{title}</h3>                {/* ← مش محتاج props.title */}
      <span className={`priority ${priority}`}>
        {priority} Priority
      </span>
      <p>Assigned to: {assignee}</p>
    </div>
  );
}
```

وممكن تحطّ default values:

```jsx
function TaskCard({ title, priority = 'low', assignee = 'Unassigned' }) {
  // لو ما اتبعتلكش priority — هتستخدم 'low' تلقائياً
  return (/* ... */);
}
```

> ⚠️ **انتبه:** الـ Props هي **read-only**. الـ `TaskCard` مش المفروض تغيّر الـ `title` اللي جالها. الـ data بتتدفق في اتجاه واحد بس: من الـ parent للـ child. لو محتاج تغيّر data — هنعرف الـ State في الفصل الجاي.

---

## [[04-Rendering-Lists]] — رسم Lists: الـ .map() اللي بتبنيلك الـ UI

في الحياة الحقيقية، مش هتكتب `<TaskCard />` يدوياً لكل task. هتجيبهم من API وترسمهم ديناميكياً.

```jsx
// App.jsx — بنجيب الـ tasks ونرسمهم
function App() {
  const tasks = [                          // ← في الواقع هتيجي من API
    { id: 1, title: 'Fix login bug',       priority: 'high',   assignee: 'Ali'  },
    { id: 2, title: 'Update UI',           priority: 'medium', assignee: 'Sara' },
    { id: 3, title: 'Write unit tests',    priority: 'low',    assignee: 'Omar' },
  ];

  return (
    <div className="task-board">
      {tasks.map(task => (               // ← الـ .map() بيحوّل كل task لـ TaskCard
        <TaskCard
          key={task.id}                  // ← مهم جداً — React محتاجه عشان تتبع التغييرات
          title={task.title}
          priority={task.priority}
          assignee={task.assignee}
        />
      ))}
    </div>
  );
}
```

ده من أهم الأسئلة في أي إنترفيو React: **ليه الـ `key` مهم؟**

الـ `key` prop هو طريقة React إنها تفرّق بين الـ elements في الـ list. لما list تتغيّر (element اتضاف، اتمسح، أو ترتيبه اتغيّر)، React بتستخدم الـ `key` عشان تعرف إيه اللي اتغيّر بالظبط بدون ما ترسم كل الـ list من الأول.

```jsx
// ❌ لا تستخدم الـ index كـ key لو الـ list بتتغيّر
{tasks.map((task, index) => (
  <TaskCard key={index} ... />  // ← لو task اتمسح من النص، كل الـ indexes هتتغيّر
))}

// ✅ استخدم unique ID ثابت
{tasks.map(task => (
  <TaskCard key={task.id} ... />  // ← الـ id ده مش بيتغيّر حتى لو الترتيب اتغيّر
))}
```

---

## 🗺️ خريطة React الأساسية

```mermaid
mindmap
  root((React Basics))
    Component
      Function بتـreturn UI
      اسمه بيبدأ بحرف كبير
      مستقل ومعاد الاستخدام
    JSX
      HTML-like syntax في JavaScript
      بيتحوّل لـ React.createElement
      className مش class
      كل tags لازم تتقفل
    Props
      Data من parent لـ child
      Read-only
      Destructuring مريح
      Default values ممكنة
    Rendering
      .map() للـ lists
      key prop إلزامي
      استخدم ID مش index
```

---

## ✅ Checkpoint — أسئلة إنترفيو React Basics

**س: إيه الـ Component في React؟**
> الـ Component هو function JavaScript بتـreturn JSX — بيصف شكل جزء من الـ UI. الـ Component مستقل، ممكن يتـreuse، ومسؤول عن الـ logic والـ UI بتوعه. الاسم لازم يبدأ بحرف كبير عشان React تفرّق بينه وبين الـ HTML tags العادية.

**س: إيه الـ JSX وهل الـ browser بيفهمها؟**
> الـ JSX هو syntax تشبه HTML جوا JavaScript — بس الـ browser مش بيفهمها مباشرةً. الـ build tool (Babel أو Vite) بيحوّلها لـ `React.createElement()` calls عادية قبل ما توصل للـ browser. هي بس طريقة أسهل للكتابة مش أكتر من كده.

**س: إيه الفرق بين Props والـ State؟**
> الـ Props هي data بتيجي من الـ parent component وهي read-only — الـ component مش المفروض يغيّرها. الـ State هي data داخلية بتخصّ الـ component نفسه وهي قابلة للتغيير. القاعدة: لو الـ data بتيجي من برّا = props. لو الـ component هو اللي بيتحكم فيها = state.

**س: ليه الـ `key` prop مهمة في الـ lists؟**
> React بتستخدم الـ `key` عشان تتبّع التغييرات في الـ list بكفاءة. بدون `key`، لما element يتمسح أو ترتيبه يتغيّر، React مش عارفة إيه اللي اتغيّر بالظبط فبتعيد رسم كل الـ list من الأول. مع الـ `key`، بتعرف تعمل الـ minimal update اللازمة. لازم الـ key تكون unique وثابتة — مش الـ array index.

**س: إيه الغلطة الأكتر شيوعاً للـ juniors في الـ JSX؟**
> في الغالب: نسيان إن الـ JSX لازم يرجع element واحد بس في الـ root. الحل إما تحط كل حاجة في `<div>` wrapper أو تستخدم `<>...</>` Fragment. غلطة تانية شائعة: كتابة `class` بدل `className` في الـ JSX.

---

## 🛠️ Practical Exercise — أول React App ليك

### Task 1 — Setup من الصفر

```bash
# إنشاء مشروع React جديد بـ Vite
npm create vite@latest taskflow -- --template react
cd taskflow
npm install
npm run dev
```

افتح `http://localhost:5173` وهتشوف صفحة React الافتراضية.

---

### Task 2 — أنشئ الـ TaskCard Component

في `src/components/TaskCard.jsx`:

```jsx
function TaskCard({ title, priority, assignee }) {
  return (
    <div style={{
      border: '1px solid #ddd',
      borderRadius: '8px',
      padding: '16px',
      marginBottom: '12px'
    }}>
      <h3>{title}</h3>
      <p>Priority: <strong>{priority}</strong></p>
      <p>Assigned to: {assignee}</p>
    </div>
  );
}

export default TaskCard;
```

---

### Task 3 — استخدم الـ Component في App

في `src/App.jsx`، استبدل كل المحتوى بـ:

```jsx
import TaskCard from './components/TaskCard';

const tasks = [
  { id: 1, title: 'Fix login bug',     priority: 'high',   assignee: 'Ali'  },
  { id: 2, title: 'Update UI',         priority: 'medium', assignee: 'Sara' },
  { id: 3, title: 'Write unit tests',  priority: 'low',    assignee: 'Omar' },
];

function App() {
  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '24px' }}>
      <h1>TaskFlow 🗂️</h1>
      {tasks.map(task => (
        <TaskCard
          key={task.id}
          title={task.title}
          priority={task.priority}
          assignee={task.assignee}
        />
      ))}
    </div>
  );
}

export default App;
```

| السؤال | اللي تفكّر فيه |
|---|---|
| ليه الـ `TaskCard` اسمه بيبدأ بحرف كبير؟ | لو كتبته بحرف صغير إيه اللي هيحصل؟ |
| لو مسحت الـ `key` إيه اللي هيحصل؟ | جرّب واشوف الـ console warning |
| إزاي تضيف task جديدة؟ | بدّل في الـ `tasks` array وشوف الـ UI |

---

## 🫒 زتونة الإنترفيو

> **"React بتبني الـ UI من components — كل component هو function JavaScript بتـreturn JSX وبتكون مسؤولة عن جزء معيّن من الشاشة. الـ JSX مش HTML حقيقي، هو syntax بتتحوّل لـ JavaScript قبل ما توصل للـ browser. الـ data بتتدفق من الـ parent للـ child عن طريق الـ props وهي read-only — الـ child مش المفروض يغيّرها. لما بنرسم lists، الـ key prop إلزامية وبنختار unique ID مش الـ index عشان React تقدر تتبّع التغييرات بكفاءة من غير ما ترسم كل حاجة من الأول."**

---

*Next → [[02-useState-and-State-Management]] — الـ State والـ useState: لما الـ Props مش كفاية وعايز الـ Component يتذكّر حاجة ويغيّر نفسه بنفسه.*
