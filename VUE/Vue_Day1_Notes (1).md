# Vue.js — Day 1 Study Notes
> For developers who already know JavaScript, React, or Angular.
> Built from session notes + [official Vue 3 docs](https://vuejs.org/guide/introduction).

---

## Table of Contents

1. [Why Vue?](#1-why-vue)
2. [SPA & SEO — The Problem Vue Solves with Nuxt](#2-spa--seo--the-problem-vue-solves-with-nuxt)
3. [Project Setup with Vite](#3-project-setup-with-vite)
4. [Folder Structure & Naming Conventions](#4-folder-structure--naming-conventions)
5. [The Single-File Component (SFC)](#5-the-single-file-component-sfc)
6. [Vue's Application Bootstrap](#6-vues-application-bootstrap)
7. [Reactivity — ref() and reactive()](#7-reactivity--ref-and-reactive)
8. [Template Syntax & Data Flow](#8-template-syntax--data-flow)
9. [Directives Deep Dive](#9-directives-deep-dive)
10. [Computed Properties](#10-computed-properties)
11. [Event Handling](#11-event-handling)
12. [Class & Style Bindings](#12-class--style-bindings)
13. [Components, Props & Emits](#13-components-props--emits)
14. [DaisyUI Integration](#14-daisyui-integration)
15. [Path Aliases: `@` vs Relative Paths](#15-path-aliases--vs-relative-paths)
16. [Answers to Session Questions](#16-answers-to-session-questions)
17. [Quick Reference Cheatsheet](#17-quick-reference-cheatsheet)

---

## 1. Why Vue?

### Background

Vue was created by **Evan You**, a former Google engineer who worked on Angular. He wanted Angular's structure, but lighter and more approachable. The result: Vue — a **progressive framework**, meaning you can adopt it gradually (add it to one page, or build an entire SPA).

**Companies using Vue in production:** GitLab, Alibaba, AliExpress, Adobe, Nintendo, Xiaomi.

### Mental Model

Think of Vue as sitting between React and Angular on a spectrum:

| | React | Vue | Angular |
|---|---|---|---|
| **Type** | UI Library | Progressive Framework | Full Framework |
| **Learning Curve** | Medium | Low–Medium | High |
| **Template Style** | JSX | HTML-based templates | HTML-based templates |
| **State** | useState / Redux | ref / Pinia | Services / RxJS |
| **Built-in Router** | No (React Router) | Yes (Vue Router) | Yes |
| **Two-way binding** | Manual | `v-model` | `[(ngModel)]` |
| **Opinionation** | Low | Medium | High |

Vue's template syntax will feel familiar from Angular (directives like `*ngFor` → `v-for`), while its component model will feel familiar from React.

---

## 2. SPA & SEO — The Problem Vue Solves with Nuxt

### Why does a plain SPA fail at SEO?

> **Your question from the session: "Why SPA fails in SEO — not just meta tags, but actual HTML files?"**

When a search engine crawler (like Googlebot) visits a regular SPA:

1. The server sends back a nearly **empty HTML file** — just a `<div id="app"></div>`.
2. Vue's JavaScript then runs in the browser and *fills in* the page content dynamically.
3. **The crawler may not execute JavaScript**, so it sees an empty page with nothing to index.

It's not just about `<meta>` tags — it's that **the actual meaningful HTML content doesn't exist on the server**. The crawler can't read what it can't see at request time.

```
Regular SPA flow:
Browser requests /products
  → Server sends: <div id="app"></div>  ← Crawler sees NOTHING useful
  → JavaScript runs
  → Vue renders: <div class="product-list">...</div>  ← Too late for crawlers
```

### The Solution: Nuxt.js (SSG/SSR)

> **Your question: "What is Nuxt / Nxtra tool? (SSG example)"**

**[Nuxt.js](https://nuxt.com/)** is Vue's meta-framework — the equivalent of **Next.js for React** or **Angular Universal for Angular**.

It solves SEO by offering two strategies:

**SSR (Server-Side Rendering):** The server renders the full HTML on every request, sends complete HTML to both the browser and the crawler.

**SSG (Static Site Generation):** All pages are pre-rendered at build time into static HTML files. Super fast and SEO-perfect. Ideal for blogs, docs, marketing pages.

```
With Nuxt SSR:
Browser requests /products
  → Server renders Vue → Sends: <div class="product-list"><div>Shoes...</div></div>
  ← Crawler reads fully rendered HTML immediately ✅
```

You don't need Nuxt for Day 1, but understanding *why it exists* gives you context for Vue's role in the ecosystem.

---

## 3. Project Setup with Vite

### What is Vite?

> **Your question: "What is Vite?"**

**Vite** (French for "fast") is a modern **build tool and dev server** created by Evan You (same author as Vue). It replaces older tools like Webpack/Create React App for Vue projects.

**Why Vite is fast:** Traditional bundlers like Webpack bundle *all* your code before starting the dev server. Vite uses native **ES Modules** — it only transforms files when the browser actually requests them.

| | Webpack (old) | Vite (new) |
|---|---|---|
| Dev server start | Slow (bundles everything first) | Near-instant |
| Hot reload | Seconds | Milliseconds |
| Production build | ✅ | ✅ (uses Rollup under the hood) |

### Creating Your Project

```bash
npm create vue@latest
```

**Choices made in session:**
- TypeScript: **No** (keeping it simple for Day 1)
- Vue Router: **Yes** (needed for SPA navigation)
- Pinia: **Yes** (state management — Vue's Vuex replacement)
- Testing, ESLint, etc.: **No** for now

Then:
```bash
cd your-project-name
npm install
npm run dev
```

### Why NOT use a CDN?

> **Your question: "Why not use CDN? (adv and disadv.)"**

**CDN advantages:**
- Zero setup — paste a `<script>` tag and go
- Great for quick experiments or adding Vue to a static page

**CDN disadvantages:**
- ❌ No Single-File Components (`.vue` files) — you lose Vue's best feature
- ❌ No tree shaking — you load the entire Vue library even if you only use 10% of it
- ❌ No build optimization (minification, code splitting)
- ❌ No TypeScript support
- ❌ Harder to manage imports and third-party libraries

**Best practice:** Always use the Vite-based setup for any real project. CDN is only for throwaway demos.

---

## 4. Folder Structure & Naming Conventions

After scaffolding, your `src/` folder should be organized like this:

```
src/
├── main.js           ← Entry point. Bootstraps the Vue app.
├── App.vue           ← Root component. Think of it as the layout shell.
├── assets/           ← Static files (images, global CSS)
├── components/       ← Reusable UI pieces (Button, Card, Navbar...)
└── pages/            ← Route-level components (orchestrators of components)
```

### Naming Convention: PascalCase

Vue components are always named in **PascalCase**:

```
✅  ProductCard.vue
✅  StudentTable.vue
✅  NavBar.vue

❌  productcard.vue
❌  student_table.vue
```

**Why?** PascalCase prevents conflicts with native HTML elements (which are lowercase). `<button>` is HTML. `<Button>` or `<MyButton>` is clearly a Vue component.

### Pages vs Components — Mental Model

- **`components/`** → Generic, reusable UI pieces. A `ProductCard` doesn't know or care about routing.
- **`pages/`** → These are the "screens" of your app. A `ProductsPage` *orchestrates* multiple components together. It knows about the current route, fetches data, and passes it down.

---

## 5. The Single-File Component (SFC)

This is Vue's **killer feature** — everything a component needs lives in one `.vue` file.

```vue
<!-- ProductCard.vue -->

<script setup>
// JavaScript logic lives here
// "setup" is the Composition API — modern Vue way (like React hooks)
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <!-- HTML structure lives here -->
  <!-- Only ONE root element required in Vue 2; Vue 3 allows multiple -->
  <div class="card">
    <p>Count: {{ count }}</p>
    <button @click="count++">Increment</button>
  </div>
</template>

<style scoped>
/* CSS lives here */
/* "scoped" means these styles ONLY apply to this component */
/* They won't leak into child or parent components */
.card {
  padding: 1rem;
}
</style>
```

### Vue SFC vs React vs Angular

| | Vue SFC | React | Angular |
|---|---|---|---|
| **Template** | `<template>` in `.vue` | JSX inside `.jsx/.tsx` | `template:` in `@Component` or `.html` file |
| **Script** | `<script setup>` | Same file as JSX | `.ts` file |
| **Styles** | `<style scoped>` | CSS Modules / styled-components | `.css` + `ViewEncapsulation` |
| **Scoped styles** | Built-in with `scoped` | Manual with CSS Modules | Built-in with Angular's encapsulation |

### `<script setup>` — Why "setup"?

`<script setup>` is the **Composition API** shorthand. It means everything you declare in it is automatically available in the template — no need to `return` anything (unlike the long-form `setup()` function).

```vue
<!-- Long-form (you won't use this, but good to know it exists) -->
<script>
export default {
  setup() {
    const name = ref('Ali')
    return { name } // Must manually return to make it available in template
  }
}
</script>

<!-- Short-form with <script setup> — everything is auto-exposed -->
<script setup>
import { ref } from 'vue'
const name = ref('Ali') // Automatically available in template ✅
</script>
```

---

## 6. Vue's Application Bootstrap

`main.js` is the entry point. Here's what it does and why:

```javascript
// main.js

import { createApp } from 'vue'   // Import Vue's app factory
import App from './App.vue'        // Import your root component
import router from './router'      // Import Vue Router
import './assets/style.css'        // Import global styles (e.g., DaisyUI)

const app = createApp(App)         // Create a Vue application instance using App as the root

app.use(router)                    // Register Vue Router as a plugin
// app.use(pinia)                  // You'd add Pinia here too
// app.use(anyOtherPlugin)         // Plugins are always registered before mount()

app.mount('#app')                  // Mount the app to the <div id="app"> in index.html
                                   // This is where Vue takes control of the DOM
```

### Mental Model

```
index.html          →   <div id="app"></div>  ← Empty shell
main.js             →   createApp(App).mount('#app')  ← Vue takes over this div
App.vue             →   The root component rendered inside #app
router              →   Controls which Page component renders based on URL
```

This is similar to React's `ReactDOM.render(<App />, document.getElementById('root'))` and Angular's `AppModule` bootstrap.

---

## 7. Reactivity — `ref()` and `reactive()`

### The Core Problem: Plain Variables Don't Update the UI

> **Mental Model: "Vue watches your data. When it changes, it re-renders. But it can only watch what it knows about."**

```javascript
// ❌ Plain JavaScript variable — Vue has no idea this changed
let name = 'Ahmed'
setTimeout(() => {
  name = 'Mohamed'  // UI will NOT update
}, 2000)
```

Vue needs a special wrapper to intercept reads and writes. That wrapper is `ref()`.

### `ref()` — Reactivity for Any Value

```javascript
import { ref } from 'vue'

// ✅ ref() wraps your value in a reactive container
const name = ref('Ahmed')

setTimeout(() => {
  name.value = 'Mohamed'  // .value tells Vue: "I'm changing this, please re-render"
}, 2000)
```

### What is a `ref` Under the Hood?

When you call `ref('Ahmed')`, Vue creates a **RefImpl** object — a special object with a `.value` property that has a **getter and setter**. The setter triggers Vue's reactivity system.

```
ref('Ahmed') creates:
{
  _value: 'Ahmed',
  get value() { /* track this dependency */ return this._value },
  set value(newVal) { this._value = newVal; /* trigger re-render */ }
}
```

This is why in your `<script setup>` you always write `name.value` to read or write — but in the `<template>`, Vue automatically unwraps it, so you just write `{{ name }}`.

```vue
<script setup>
import { ref } from 'vue'

const name = ref('Ahmed')  // In script: always use .value
name.value = 'Mohamed'     // ✅ correct
// name = 'Mohamed'        // ❌ breaks reactivity — reassigns the variable, not the ref
</script>

<template>
  <!-- In template: Vue auto-unwraps, no .value needed -->
  <p>{{ name }}</p>  <!-- ✅ displays 'Mohamed' -->
</template>
```

### `reactive()` — Reactivity for Objects

`reactive()` makes an **entire object** reactive, without needing `.value`.

```javascript
import { reactive } from 'vue'

const student = reactive({
  name: 'Ahmed',
  age: 21,
  grades: [90, 85, 78]
})

// No .value needed — access properties directly
student.name = 'Mohamed'   // ✅ triggers re-render
student.age = 22            // ✅ triggers re-render
```

### `ref()` vs `reactive()` — When to Use Which

> **Your question: "What is reactive and diff between it and ref?"**

| | `ref()` | `reactive()` |
|---|---|---|
| **Works with** | Primitives AND objects | Objects/Arrays only |
| **Access in script** | `name.value` | `obj.property` directly |
| **Access in template** | `{{ name }}` (auto-unwrapped) | `{{ obj.property }}` |
| **Can reassign?** | `name.value = newVal` ✅ | Cannot reassign the whole object ❌ |
| **Best for** | Single values, simple state | Grouped state (like a form) |

**Rule of thumb used by most Vue developers:** Default to `ref()` for everything. It's consistent and flexible.

```javascript
// Using ref() for an object — totally valid
const student = ref({
  name: 'Ahmed',
  age: 21
})
// In script: student.value.name
// In template: {{ student.name }} (auto-unwrapped)
```

### Common Beginner Mistakes with Reactivity

```javascript
// ❌ Mistake 1: Forgetting .value in script
const count = ref(0)
count = count + 1         // WRONG — reassigns the ref variable itself
count.value = count.value + 1  // ✅ correct
count.value++             // ✅ also correct

// ❌ Mistake 2: Destructuring a reactive() object — loses reactivity!
const state = reactive({ name: 'Ahmed', age: 21 })
const { name, age } = state    // ❌ name and age are now plain variables
// Fix: use toRefs() or just access state.name directly
import { toRefs } from 'vue'
const { name, age } = toRefs(state)  // ✅ now name.value and age.value are reactive

// ❌ Mistake 3: Expecting the template to use .value
// Wrong: {{ name.value }}   — Vue will try to read .value property of the unwrapped string
// Right: {{ name }}
```

---

## 8. Template Syntax & Data Flow

### The Two Data Flow Paths

> **Your question: "What are the 2 data flow paths? (template → script and vice versa)"**

Vue has a **one-way data flow** (script → template) with **events** for the reverse:

```
Script (reactive state)  →  Template (displays it)       [Script → Template]
Template (user action)   →  Script (events update state) [Template → Script]
```

```vue
<script setup>
import { ref } from 'vue'

const message = ref('Hello')  // State lives in script

function updateMessage() {    // Template calls this → updates script state
  message.value = 'World'
}
</script>

<template>
  <!-- Script → Template: displaying state -->
  <p>{{ message }}</p>

  <!-- Template → Script: event triggers state update -->
  <button @click="updateMessage">Change</button>
</template>
```

### Interpolation `{{ }}`

```vue
<template>
  <p>{{ name }}</p>              <!-- Display a ref value -->
  <p>{{ age + 1 }}</p>          <!-- JavaScript expressions work -->
  <p>{{ isOnline ? '🟢' : '🔴' }}</p>   <!-- Ternary expressions work -->
  <p>{{ message.toUpperCase() }}</p>     <!-- Method calls work -->
  <!-- ❌ Statements don't work: {{ if (x) { } }} -->
</template>
```

**Compared to React:** `{name}` in JSX vs `{{ name }}` in Vue templates — double curly braces in Vue.
**Compared to Angular:** Identical `{{ name }}` syntax.

---

## 9. Directives Deep Dive

Directives are special HTML attributes that start with `v-`. They tell Vue to do something to a DOM element.

### `v-for` — List Rendering

```vue
<script setup>
import { ref } from 'vue'

const students = ref([
  { id: 1, name: 'Ahmed', age: 20 },
  { id: 2, name: 'Sara',  age: 17 },
  { id: 3, name: 'Omar',  age: 22 },
])
</script>

<template>
  <table>
    <tr
      v-for="student in students"
      :key="student.id"
    >
    <!-- ^^^
         :key is REQUIRED. It gives Vue a stable identity for each item.
         Without it, Vue can't efficiently update only the changed row —
         it re-renders everything. Always use a unique ID, never the loop index
         when items can be reordered/deleted.
    -->
      <td>{{ student.id }}</td>
      <td>{{ student.name }}</td>
      <td>{{ student.age }}</td>
    </tr>
  </table>
</template>
```

**Compared to React:** `{students.map(s => <tr key={s.id}>...</tr>)}`
**Compared to Angular:** `*ngFor="let student of students"`

### `v-if` / `v-else-if` / `v-else` — Conditional Rendering

```vue
<template>
  <td v-if="student.age >= 18">
    {{ student.age }} (Adult)
  </td>
  <td v-else>
    {{ student.age }} (Minor)
  </td>
</template>
```

`v-if` **removes the element from the DOM entirely**. This is different from `v-show`.

### `v-show` — Toggle Visibility

```vue
<template>
  <!-- v-show keeps the element in the DOM, just toggles display: none -->
  <div v-show="isMenuOpen">Menu content</div>
</template>
```

**`v-if` vs `v-show` — When to use which:**

| | `v-if` | `v-show` |
|---|---|---|
| **DOM** | Adds/removes element | Always in DOM |
| **Performance** | Higher cost on toggle | Higher initial cost |
| **Use when** | Element rarely shows/hides | Element toggles frequently |
| **Example** | Error messages, auth-gated UI | Dropdown menus, modals |

### `v-model` — Two-Way Data Binding

This is Vue's most powerful directive for forms. It's actually a shorthand that combines `:value` binding and `@input` event listening.

```vue
<script setup>
import { ref } from 'vue'
const searchQuery = ref('')
</script>

<template>
  <input v-model="searchQuery" placeholder="Search..." />
  <p>You typed: {{ searchQuery }}</p>
</template>

<!--
v-model is syntactic sugar for:
<input :value="searchQuery" @input="searchQuery = $event.target.value" />
-->
```

**Compared to React:** In React you write this manually (controlled component pattern):
```jsx
<input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
```
Vue's `v-model` does this in one directive.

**Compared to Angular:** `[(ngModel)]="searchQuery"` — the "banana in a box" syntax. Same concept.

### `v-html` — Render Raw HTML

```vue
<script setup>
const htmlContent = ref('<strong>Bold text</strong>')
</script>

<template>
  <div v-html="htmlContent"></div>
  <!-- Renders actual bold text, not the string "<strong>..." -->
</template>
```

> ⚠️ **Security Warning:** Never use `v-html` with user-provided content. It opens you to **XSS attacks**. Only use it with trusted, sanitized HTML you control.

### `v-bind` — Binding HTML Attributes

```vue
<script setup>
const imageUrl = ref('https://example.com/photo.jpg')
const isDisabled = ref(true)
</script>

<template>
  <!-- Full syntax -->
  <img v-bind:src="imageUrl" />

  <!-- Shorthand (used 99% of the time) -->
  <img :src="imageUrl" />
  <button :disabled="isDisabled">Submit</button>

  <!-- v-bind vs regular attribute:
       :src="imageUrl"  → evaluates imageUrl as JavaScript
        src="imageUrl"  → treats "imageUrl" as a literal string
  -->
</template>
```

---

## 10. Computed Properties

> **Your question: "What is computed()?"**

A **computed property** is a reactive value that is automatically derived from other reactive state. It's like a formula in a spreadsheet — it recalculates *only when its dependencies change*, and the result is **cached**.

### Without `computed` (the wrong way)

```vue
<template>
  <!-- This re-runs on EVERY render, even if students didn't change -->
  <p>Adults: {{ students.filter(s => s.age >= 18).length }}</p>
</template>
```

### With `computed` (the right way)

```vue
<script setup>
import { ref, computed } from 'vue'

const students = ref([
  { id: 1, name: 'Ahmed', age: 20 },
  { id: 2, name: 'Sara',  age: 17 },
])

// computed() takes a getter function and returns a reactive, cached ref
const adultStudents = computed(() => {
  return students.value.filter(s => s.age >= 18)
})

const adultCount = computed(() => adultStudents.value.length)
</script>

<template>
  <p>Adults: {{ adultCount }}</p>
  <!-- adultCount only recalculates when students changes -->
</template>
```

### Mental Model for `computed`

```
students (ref)  →  adultStudents (computed)  →  adultCount (computed)
     ↑                      ↑
 When this changes,   this auto-recalculates (and is cached until next change)
```

**Compared to React:** `useMemo(() => students.filter(...), [students])`
**Compared to Angular:** Pipes or manual memoization

**Rule:** If you're deriving a value from existing state, use `computed`. Never mutate a computed property — it's read-only by design.

### Common Beginner Mistakes with `computed`

```javascript
// ❌ Don't put side effects in computed (no async, no console.log for debugging state)
const total = computed(() => {
  console.log('recalculating')   // This is a side effect — use watch() instead
  return items.value.reduce(...)
})

// ❌ Don't try to modify a computed
adultStudents.value = []  // This throws a warning — computed is read-only
```

---

## 11. Event Handling

### Basic Syntax

```vue
<template>
  <!-- Full syntax -->
  <button v-on:click="handleClick">Click me</button>

  <!-- Shorthand @ (used always) -->
  <button @click="handleClick">Click me</button>

  <!-- Inline expression (simple logic only) -->
  <button @click="count++">Increment</button>

  <!-- ⚠️ Quote gotcha: if you mix quotes, use template literals or a method -->
  <!-- ❌ This breaks: @click="alert('Hey')"  — inner quotes conflict in some cases -->
  <!-- ✅ Use a method instead: @click="showAlert" -->
</template>

<script setup>
import { ref } from 'vue'
const count = ref(0)

function handleClick() {
  count.value++
}

function showAlert() {
  alert('Hey!')
}
</script>
```

### Accessing the Event Object

```vue
<template>
  <input @input="handleInput" />
  <button @click="handleClickWithEvent">Click</button>
</template>

<script setup>
function handleInput(event) {
  // event is the native DOM event
  console.log(event.target.value)
}

function handleClickWithEvent(event) {
  console.log(event.target)
}
</script>
```

### Event Modifiers

Vue provides modifiers to handle common patterns without writing extra JavaScript:

```vue
<template>
  <!-- Prevent default form submission -->
  <form @submit.prevent="handleSubmit">...</form>

  <!-- Stop event propagation (like stopPropagation()) -->
  <button @click.stop="handleClick">...</button>

  <!-- Only fire once -->
  <button @click.once="handleClick">...</button>

  <!-- Key modifiers — only trigger on Enter key -->
  <input @keyup.enter="submitSearch" />
</template>
```

**Compared to React:**
```jsx
// React — manual
<form onSubmit={(e) => { e.preventDefault(); handleSubmit() }}>
// Vue — elegant
<form @submit.prevent="handleSubmit">
```

---

## 12. Class & Style Bindings

### Binding Classes Dynamically

```vue
<script setup>
import { ref } from 'vue'

const isActive = ref(true)
const hasError = ref(false)
const theme = ref('primary')
</script>

<template>
  <!-- Before (verbose) -->
  <div v-bind:class="{ active: isActive, error: hasError }"></div>

  <!-- After (shorthand) — ✅ used always -->
  <div :class="{ active: isActive, error: hasError }"></div>
  <!--          ↑ Object syntax: { 'class-name': boolean } -->

  <!-- Array syntax — multiple classes -->
  <div :class="[isActive ? 'active' : '', 'base-class']"></div>

  <!-- Combining static and dynamic classes -->
  <div class="card" :class="{ highlighted: isActive }"></div>
  <!-- Vue merges them: class="card highlighted" -->

  <!-- Using a computed class object (cleanest for complex logic) -->
  <div :class="buttonClasses"></div>
</template>

<script setup>
import { computed } from 'vue'
const buttonClasses = computed(() => ({
  'btn-primary': theme.value === 'primary',
  'btn-active':  isActive.value,
}))
</script>
```

---

## 13. Components, Props & Emits

### Mental Model for Components

```
App.vue (root)
├── NavBar.vue
├── ProductsPage.vue
│   ├── ProductCard.vue   ← receives product via props
│   └── ProductCard.vue   ← receives product via props
└── Footer.vue
```

Data flows **down** via props. Events flow **up** via emits.

### Props — Parent to Child

```vue
<!-- Parent: ProductsPage.vue -->
<script setup>
import ProductCard from '@/components/ProductCard.vue'

const products = ref([
  { id: 1, name: 'Shirt', image: '/shirt.jpg', price: 99 },
  { id: 2, name: 'Pants', image: '/pants.jpg', price: 149 },
])
</script>

<template>
  <ProductCard
    v-for="product in products"
    :key="product.id"
    :product="product"
    title="Featured Item"
  />
</template>
```

```vue
<!-- Child: ProductCard.vue -->
<script setup>
// defineProps is a compiler macro — no import needed, it's auto-available
const props = defineProps({
  title: {
    type: String,
    required: true,   // Shows a console warning in dev if not passed
                      // In production: silently fails (no error)
  },
  product: {
    type: Object,
    required: true,
    // If product is required but not passed, accessing product.name
    // will throw an error and the component won't render.
    // Best practice: use optional chaining in template → product?.name
  },
  navItems: {
    type: Array,
    default: () => [],  // Always use a factory function for objects/arrays
  },
})
</script>

<template>
  <div class="card">
    <h2>{{ title }}</h2>
    <!-- ✅ Optional chaining prevents crash if product is undefined -->
    <img :src="product?.image" :alt="product?.name" />
    <p>{{ product?.name }}</p>
    <p>${{ product?.price }}</p>
  </div>
</template>
```

### ⚠️ Critical Rule: The Owner of State Should Change It

> **From the session: "The owner of state is the one who should change it."**

If `ProductsPage` owns the `products` array, only `ProductsPage` should modify it. If `ProductCard` needs to trigger a change, it should emit an event and let the parent handle the actual mutation.

```
❌ Wrong: Child directly modifies a prop
  props.product.price = 50  // Mutating a prop — causes Vue warning + unpredictable behavior

✅ Right: Child emits, Parent updates
  Child emits 'price-changed'  →  Parent receives it  →  Parent updates the state
```

### Emits — Child to Parent

```vue
<!-- Child: ProductCard.vue -->
<script setup>
const props = defineProps({ product: { type: Object, required: true } })

// Declare the events this component can emit
const emit = defineEmits(['add-to-cart', 'remove-item'])

function handleAddToCart() {
  // emit(eventName, ...payload)
  emit('add-to-cart', props.product)
}
</script>

<template>
  <button @click="handleAddToCart">Add to Cart</button>
</template>
```

```vue
<!-- Parent: ProductsPage.vue -->
<template>
  <ProductCard
    :product="product"
    @add-to-cart="handleCartAdd"
  />
</template>

<script setup>
function handleCartAdd(product) {
  console.log('Added to cart:', product)
  // Parent updates its own state here ✅
}
</script>
```

### Common Beginner Mistakes with Props

```javascript
// ❌ Mistake 1: Mutating props directly
props.title = 'New Title'          // Vue warning + can cause bugs

// ❌ Mistake 2: Forgetting default for optional object/array props
defineProps({
  items: { type: Array }            // If not passed → undefined, then .map() crashes
})
// Fix:
defineProps({
  items: { type: Array, default: () => [] }   // Always a factory function for reference types
})

// ❌ Mistake 3: Not using optional chaining in template
// {{ product.name }}   → crashes if product is undefined
// {{ product?.name }}  → safely returns undefined (renders nothing)
```

---

## 14. DaisyUI Integration

**[DaisyUI](https://daisyui.com/)** is a Tailwind CSS component library that gives you pre-built, themeable classes like `.btn`, `.card`, `.badge`, etc.

### Why DaisyUI with Vue?

- Works as a `devDependency` (only needed at build time)
- **Tree-shakable build:** Vite + Tailwind only includes the CSS classes you actually use. The final bundle doesn't include all of DaisyUI — just what you reference.

### Installation

```bash
npm install -D tailwindcss daisyui
npx tailwindcss init
```

In `tailwind.config.js`:
```javascript
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts}'],
  plugins: [require('daisyui')],
}
```

In `main.js`:
```javascript
import './assets/style.css'  // Must import Tailwind's directives
```

In `assets/style.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Usage in Vue Templates

```vue
<template>
  <!-- DaisyUI classes work just like regular CSS classes -->
  <button class="btn btn-primary">Submit</button>

  <div class="card w-96 bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">Product Name</h2>
      <p>Description here</p>
      <div class="card-actions justify-end">
        <button class="btn btn-primary">Buy Now</button>
      </div>
    </div>
  </div>

  <!-- Combine with dynamic :class binding -->
  <button
    class="btn"
    :class="{ 'btn-primary': isActive, 'btn-ghost': !isActive }"
  >
    Dynamic
  </button>
</template>
```

---

## 15. Path Aliases: `@` vs Relative Paths

> **Your question: "What is the diff between relative path `.` and `@` alias? (adv, disadv, best practice)"**

### Relative Paths

```javascript
import ProductCard from '../../components/ProductCard.vue'
// ↑ Works, but fragile. If you move this file one folder up,
//   the path breaks and you must update it.
```

### `@` Alias

Vite automatically sets up `@` as an alias for your `src/` directory.

```javascript
import ProductCard from '@/components/ProductCard.vue'
// ↑ Always resolves to src/components/ProductCard.vue
//   regardless of where the importing file lives.
```

**Comparison:**

| | Relative (`.` / `..`) | `@` alias |
|---|---|---|
| **Readability** | Gets messy with deep nesting `../../..` | Always clean and absolute-looking |
| **Refactor safety** | Breaks when files move | Always works (points to `src/`) |
| **IDE support** | ✅ | ✅ (with path config) |
| **Best practice** | For same-folder sibling files | **Everything else** |

**Best Practice:** Use `@/` for all imports. Only use relative paths (e.g., `./utils.js`) when importing a file from the exact same directory.

---

## 16. Answers to Session Questions

A consolidated reference for every question from your notes:

**Q: Why does SPA fail at SEO?**
The server sends an empty HTML shell. Crawlers may not execute JavaScript, so they see no content. → Covered in [Section 2](#2-spa--seo--the-problem-vue-solves-with-nuxt).

**Q: What is Nuxt (the SSG tool)?**
Vue's meta-framework (like Next.js for React). Enables SSR and SSG for SEO-friendly Vue apps. → Covered in [Section 2](#2-spa--seo--the-problem-vue-solves-with-nuxt).

**Q: What is Vite?**
A fast build tool and dev server using native ES Modules. Created by Evan You. Replaces Webpack. → Covered in [Section 3](#3-project-setup-with-vite).

**Q: Why not use CDN?**
No SFC support, no tree shaking, no build optimization. CDN only works for trivial demos. → Covered in [Section 3](#3-project-setup-with-vite).

**Q: What are the 2 data flow paths?**
Script → Template (reactive state displayed via `{{ }}`) and Template → Script (events like `@click` update state). → Covered in [Section 8](#8-template-syntax--data-flow).

**Q: What is `computed()`?**
A cached reactive value derived from other state. Recalculates automatically when dependencies change. → Covered in [Section 10](#10-computed-properties).

**Q: What is `reactive()` and how does it differ from `ref()`?**
`ref()` wraps any value and requires `.value` in script. `reactive()` wraps objects only, no `.value` needed. Prefer `ref()` for consistency. → Covered in [Section 7](#7-reactivity--ref-and-reactive).

**Q: What is the diff between `@` alias and relative paths?**
`@` always points to `src/`, is refactor-safe and readable. Relative paths break when files move. → Covered in [Section 15](#15-path-aliases--vs-relative-paths).

**Q: `defineProps` is auto-accessible — why no import?**
`defineProps`, `defineEmits`, and `defineExpose` are **compiler macros** — they're processed by Vue's compiler at build time and don't need to be imported. They only work inside `<script setup>`.

---

## 17. Quick Reference Cheatsheet

```vue
<script setup>
import { ref, reactive, computed } from 'vue'

// Reactive state
const count = ref(0)                        // primitive → ref
const user  = reactive({ name: '', age: 0 }) // object  → reactive or ref

// Derived state (cached)
const doubled = computed(() => count.value * 2)

// Props (no import needed — compiler macro)
const props = defineProps({ title: { type: String, required: true } })

// Emits
const emit = defineEmits(['update', 'delete'])
emit('update', payload)
</script>

<template>
  <!-- Interpolation -->
  {{ count }}

  <!-- Attribute binding -->
  <img :src="url" />

  <!-- Two-way binding (forms) -->
  <input v-model="name" />

  <!-- Conditional -->
  <p v-if="show">Visible</p>
  <p v-else>Hidden</p>
  <p v-show="show">CSS-hidden only</p>

  <!-- Lists -->
  <li v-for="item in items" :key="item.id">{{ item.name }}</li>

  <!-- Events -->
  <button @click="handleClick">Click</button>
  <form @submit.prevent="handleSubmit">...</form>

  <!-- Dynamic classes -->
  <div :class="{ active: isActive, error: hasError }"></div>

  <!-- Raw HTML (use with caution) -->
  <div v-html="trustedHtml"></div>
</template>
```

---

### Useful Links

| Topic | Official Doc |
|---|---|
| Introduction | [vuejs.org/guide/introduction](https://vuejs.org/guide/introduction) |
| Creating an App | [vuejs.org/guide/essentials/application](https://vuejs.org/guide/essentials/application) |
| Reactivity Fundamentals | [vuejs.org/guide/essentials/reactivity-fundamentals](https://vuejs.org/guide/essentials/reactivity-fundamentals) |
| Template Syntax | [vuejs.org/guide/essentials/template-syntax](https://vuejs.org/guide/essentials/template-syntax) |
| Computed Properties | [vuejs.org/guide/essentials/computed](https://vuejs.org/guide/essentials/computed) |
| Class & Style Bindings | [vuejs.org/guide/essentials/class-and-style](https://vuejs.org/guide/essentials/class-and-style) |
| Conditional Rendering | [vuejs.org/guide/essentials/conditional](https://vuejs.org/guide/essentials/conditional) |
| List Rendering | [vuejs.org/guide/essentials/list](https://vuejs.org/guide/essentials/list) |
| Event Handling | [vuejs.org/guide/essentials/event-handling](https://vuejs.org/guide/essentials/event-handling) |
| Form Bindings (v-model) | [vuejs.org/guide/essentials/forms](https://vuejs.org/guide/essentials/forms) |
| Components Basics | [vuejs.org/guide/essentials/component-basics](https://vuejs.org/guide/essentials/component-basics) |
| Props | [vuejs.org/guide/components/props](https://vuejs.org/guide/components/props) |
| Events (Emits) | [vuejs.org/guide/components/events](https://vuejs.org/guide/components/events) |
| DaisyUI Docs | [daisyui.com](https://daisyui.com/) |
| Vue DevTools | [devtools.vuejs.org](https://devtools.vuejs.org/) |

---

> **Next Session Preview:** Lifecycle hooks (`onMounted`, `onUnmounted`), watchers (`watch`, `watchEffect`), Vue Router navigation, and Pinia state management.
