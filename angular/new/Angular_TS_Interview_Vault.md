# Angular & TypeScript Interview Questions & Answers

> 🇪🇬 الملف ده مخصص للـ Freshers والـ Junior Developers اللي بيحضّروا للـ Technical Interviews. الأسئلة مرتبة من الأسهل للأصعب، وكل إجابة مكتوبة بالعامية المصرية التقنية عشان تفهم مش تحفظ.  
> **الـ Tech Stack:** Angular 17+ · TypeScript 5+ · RxJS 7+

---

### Table of Contents

| No. | Questions |
| --- | --------- |
| **— TypeScript Basics —** | |
| 1 | [إيه هو TypeScript وإيه الفرق بينه وبين JavaScript؟](#1-إيه-هو-typescript-وإيه-الفرق-بينه-وبين-javascript) |
| 2 | [إيه هي الـ Basic Types الأساسية في TypeScript؟](#2-إيه-هي-الـ-basic-types-الأساسية-في-typescript) |
| 3 | [إيه الفرق بين `any` و`unknown` و`never`؟](#3-إيه-الفرق-بين-any-وunknown-وnever) |
| 4 | [إيه هو الـ Interface في TypeScript وإزاي بتستخدمه؟](#4-إيه-هو-الـ-interface-في-typescript-وإزاي-بتستخدمه) |
| 5 | [إيه الفرق بين الـ Interface والـ Type Alias؟](#5-إيه-الفرق-بين-الـ-interface-والـ-type-alias) |
| 6 | [إيه هي الـ Classes في TypeScript وإيه دور الـ Access Modifiers؟](#6-إيه-هي-الـ-classes-في-typescript-وإيه-دور-الـ-access-modifiers) |
| 7 | [إيه هو الـ Generic في TypeScript وإزاي بتستخدمه؟](#7-إيه-هو-الـ-generic-في-typescript-وإزاي-بتستخدمه) |
| 8 | [إيه هو الـ Union Type والـ Intersection Type؟](#8-إيه-هو-الـ-union-type-والـ-intersection-type) |
| 9 | [إيه هو الـ Optional Chaining `?.` والـ Nullish Coalescing `??`؟](#9-إيه-هو-الـ-optional-chaining--والـ-nullish-coalescing-) |
| 10 | [إيه هو الـ Enum في TypeScript وامتى بتستخدمه؟](#10-إيه-هو-الـ-enum-في-typescript-وامتى-بتستخدمه) |
| **— Angular Core & Architecture —** | |
| 11 | [إيه هو Angular وإيه أهم مميزاته؟](#11-إيه-هو-angular-وإيه-أهم-مميزاته) |
| 12 | [إيه هو الـ NgModule وإيه المكونات اللي جوّاه؟](#12-إيه-هو-الـ-ngmodule-وإيه-المكونات-اللي-جوّاه) |
| 13 | [إيه هو الـ Standalone Component وإزاي بيختلف عن الـ Module-based؟](#13-إيه-هو-الـ-standalone-component-وإزاي-بيختلف-عن-الـ-module-based) |
| 14 | [إزاي بتعمل Angular Project جديد بالـ CLI خطوة بخطوة؟](#14-إزاي-بتعمل-angular-project-جديد-بالـ-cli-خطوة-بخطوة) |
| 15 | [إيه أهم الـ Angular CLI Commands اللي لازم تعرفها؟](#15-إيه-أهم-الـ-angular-cli-commands-اللي-لازم-تعرفها) |
| 16 | [إيه هو الـ `main.ts` وإيه دوره في تشغيل الـ App؟](#16-إيه-هو-الـ-maints-وإيه-دوره-في-تشغيل-الـ-app) |
| 17 | [إيه الفرق بين الـ AOT والـ JIT Compilation في Angular؟](#17-إيه-الفرق-بين-الـ-aot-والـ-jit-compilation-في-angular) |
| 18 | [إيه هو ملف الـ `angular.json` وبيعمل إيه؟](#18-إيه-هو-ملف-الـ-angularjson-وبيعمل-إيه) |
| **— Components & Data Binding —** | |
| 19 | [إيه هو الـ Component في Angular وإزاي بتعمله؟](#19-إيه-هو-الـ-component-في-angular-وإزاي-بتعمله) |
| 20 | [إيه هو الـ Interpolation وإزاي بتستخدمه؟](#20-إيه-هو-الـ-interpolation-وإزاي-بتستخدمه) |
| 21 | [إيه هو الـ Property Binding وإزاي بيختلف عن الـ Interpolation؟](#21-إيه-هو-الـ-property-binding-وإزاي-بيختلف-عن-الـ-interpolation) |
| 22 | [إيه هو الـ Event Binding وإزاي بتتعامل مع الـ Events؟](#22-إيه-هو-الـ-event-binding-وإزاي-بتتعامل-مع-الـ-events) |
| 23 | [إيه هو الـ Two-Way Data Binding و`[(ngModel)]`؟](#23-إيه-هو-الـ-two-way-data-binding-وngmodel) |
| 24 | [إيه هو الـ `@Input()` وإزاي بتبعت data من Parent لـ Child Component؟](#24-إيه-هو-الـ-input-وإزاي-بتبعت-data-من-parent-لـ-child-component) |
| 25 | [إيه هو الـ `@Output()` والـ `EventEmitter` وإزاي بتتواصل من Child لـ Parent؟](#25-إيه-هو-الـ-output-والـ-eventemitter-وإزاي-بتتواصل-من-child-لـ-parent) |
| 26 | [إيه هي الـ Lifecycle Hooks في Angular وإيه ترتيبها؟](#26-إيه-هي-الـ-lifecycle-hooks-في-angular-وإيه-ترتيبها) |
| 27 | [إيه الفرق بين الـ `ngOnInit` والـ `constructor`؟](#27-إيه-الفرق-بين-الـ-ngoninit-والـ-constructor) |
| 28 | [إيه هو الـ `@ViewChild` وإزاي بتوصل لـ Child Element من الـ Template؟](#28-إيه-هو-الـ-viewchild-وإزاي-بتوصل-لـ-child-element-من-الـ-template) |
| **— Directives & Pipes —** | |
| 29 | [إيه هو الـ Directive في Angular وإيه أنواعه؟](#29-إيه-هو-الـ-directive-في-angular-وإيه-أنواعه) |
| 30 | [إزاي بتستخدم `*ngIf` والـ `@if` الجديدة في Angular 17+؟](#30-إزاي-بتستخدم-ngif-والـ-if-الجديدة-في-angular-17) |
| 31 | [إزاي بتستخدم `*ngFor` والـ `@for` الجديدة في Angular 17+؟](#31-إزاي-بتستخدم-ngfor-والـ-for-الجديدة-في-angular-17) |
| 32 | [إيه هو الـ `[ngClass]` و`[ngStyle]` وامتى بتستخدم أنهي فيهم؟](#32-إيه-هو-الـ-ngclass-وngstyle-وامتى-بتستخدم-أنهي-فيهم) |
| 33 | [إيه هو الـ Pipe في Angular وإيه أشهر الـ Built-in Pipes؟](#33-إيه-هو-الـ-pipe-في-angular-وإيه-أشهر-الـ-built-in-pipes) |
| 34 | [إزاي بتعمل Custom Pipe بتاعك في Angular؟](#34-إزاي-بتعمل-custom-pipe-بتاعك-في-angular) |
| **— Services & Dependency Injection —** | |
| 35 | [إيه هو الـ Service في Angular وليه بنستخدمه؟](#35-إيه-هو-الـ-service-في-angular-وليه-بنستخدمه) |
| 36 | [إيه هو الـ Dependency Injection ببساطة؟](#36-إيه-هو-الـ-dependency-injection-ببساطة) |
| 37 | [إيه هو الـ `@Injectable()` وإيه معنى `providedIn: 'root'`؟](#37-إيه-هو-الـ-injectable-وإيه-معنى-providedin-root) |
| 38 | [إيه الفرق بين الـ `providers` في الـ Component والـ Module؟](#38-إيه-الفرق-بين-الـ-providers-في-الـ-component-والـ-module) |
| 39 | [إزاي بتعمل HTTP Calls بالـ `HttpClient` في Angular؟](#39-إزاي-بتعمل-http-calls-بالـ-httpclient-في-angular) |
| **— RxJS & Routing Basics —** | |
| 40 | [إيه هو الـ Observable وإيه الفرق بينه وبين الـ Promise؟](#40-إيه-هو-الـ-observable-وإيه-الفرق-بينه-وبين-الـ-promise) |
| 41 | [إزاي بتستخدم الـ `subscribe()` وإيه المشاكل اللي ممكن تحصل؟](#41-إزاي-بتستخدم-الـ-subscribe-وإيه-المشاكل-اللي-ممكن-تحصل) |
| 42 | [إيه هي أشهر الـ RxJS Operators وإزاي بتستخدمها؟](#42-إيه-هي-أشهر-الـ-rxjs-operators-وإزاي-بتستخدمها) |
| 43 | [إيه هو الـ Subject في RxJS وإيه أنواعه؟](#43-إيه-هو-الـ-subject-في-rxjs-وإيه-أنواعه) |
| 44 | [إيه هو الـ Angular Router وإزاي بتضيف Routes للـ App؟](#44-إيه-هو-الـ-angular-router-وإزاي-بتضيف-routes-للـ-app) |
| 45 | [إيه الفرق بين الـ `routerLink` والـ `router.navigate()`؟](#45-إيه-الفرق-بين-الـ-routerlink-والـ-routernavigate) |
| 46 | [إزاي بتبعت وتجيب الـ Route Parameters في Angular؟](#46-إزاي-بتبعت-وتجيب-الـ-route-parameters-في-angular) |
| 47 | [إيه هو الـ Route Guard وإزاي بتحمي الـ Routes؟](#47-إيه-هو-الـ-route-guard-وإزاي-بتحمي-الـ-routes) |

---

## Section 1: TypeScript Basics

### 1. إيه هو TypeScript وإيه الفرق بينه وبين JavaScript؟

الـ TypeScript هو "Superset" من الـ JavaScript — يعني أي كود JavaScript صح في TypeScript. الفرق الجوهري إن TypeScript بيضيف عليه نظام Types ثابت بيتشيك في وقت الـ Compilation مش الـ Runtime.

**بمعنى آخر:** JavaScript بتحط أي قيمة في أي variable من غير ما تقولّه نوعها، وده بيودي لـ bugs بتظهر بس لما الـ user يشغّل الكود. TypeScript بيقولك على الـ bug ده وانت لسه بتكتب الكود.

```typescript
// JavaScript — مفيش حماية من الغلط
let username = "Ahmed";
username = 42; // ✅ JavaScript قبلها من غير مشكلة
console.log(username.toUpperCase()); // 💥 Runtime Error! 42 مش string

// TypeScript — بيمسك الغلط قبل ما يحصل
let username: string = "Ahmed";
username = 42; // ❌ Compile Error: Type 'number' is not assignable to type 'string'
```

| الفرق | JavaScript | TypeScript |
| ----- | ---------- | ---------- |
| **الـ Typing** | Dynamic (في الـ Runtime) | Static (في الـ Compile Time) |
| **الـ Extension** | `.js` | `.ts` |
| **الـ Browsers** | بتشغّله مباشرة | محتاج Transpiler (tsc) |
| **الـ Errors** | بتظهر في الـ Runtime | بتظهر في الـ Compile Time |
| **Angular** | مش مستخدمة رسمياً | الـ default language |

> **ملاحظة:** الـ TypeScript بيتحوّل لـ JavaScript عادي في النهاية عن طريق الـ TypeScript Compiler (`tsc`). يعني الـ Browser مش هيشوف TypeScript أصلاً.

**[⬆ Back to Top](#table-of-contents)**

---

### 2. إيه هي الـ Basic Types الأساسية في TypeScript؟

الـ TypeScript عنده Types جاهزة تقدر تستخدمهم مباشرة. دي أهمهم:

```typescript
// ① الـ Primitive Types
let name: string = "Ahmed";          // نص
let age: number = 25;                 // رقم (int أو float، مفيش فرق)
let isActive: boolean = true;         // true أو false
let nothing: null = null;             // فاضي بشكل صريح
let notDefined: undefined = undefined;// غير معرّف

// ② الـ Arrays
let names: string[] = ["Ahmed", "Sara", "Omar"];     // طريقة 1
let scores: Array<number> = [90, 85, 92];             // طريقة 2

// ③ الـ Tuple — array بعدد وأنواع ثابتة بالترتيب
let person: [string, number] = ["Ahmed", 25];
// person[0] = string دايماً | person[1] = number دايماً

// ④ الـ Object
let user: { name: string; age: number; isAdmin: boolean } = {
  name: "Sara",
  age: 30,
  isAdmin: false,
};

// ⑤ الـ Function
function add(a: number, b: number): number {
  return a + b;
}

// Function مش بترجع حاجة
function logMessage(msg: string): void {
  console.log(msg);
}

// ⑥ الـ any — بتقفل الـ Type Checking (استخدمها أقل ما تقدر)
let randomThing: any = "text";
randomThing = 42;         // ✅ مقبول
randomThing = true;       // ✅ مقبول — بس بتفقد فايدة TypeScript
```

**[⬆ Back to Top](#table-of-contents)**

---

### 3. إيه الفرق بين `any` و`unknown` و`never`؟

الـ 3 دول من أكثر الأسئلة اللي بتتسأل فيها، والناس كتير بتلخبطهم.

```typescript
// ① any — بتقول لـ TypeScript "متعترضش على أي حاجة"
let data: any = "hello";
data = 42;
data.toUpperCase();   // ✅ TypeScript مش هيشتكي حتى لو Runtime Error
data.whatever();      // ✅ برضو مش هيشتكي — خطر!

// ② unknown — "مش عارف النوع، بس مش هعمل عليه أي operation من غير ما أتأكد"
let input: unknown = "hello";
// input.toUpperCase(); // ❌ Error — لازم تتأكد الأول
if (typeof input === "string") {
  input.toUpperCase(); // ✅ دلوقتي TypeScript عارف إنه string
}

// ③ never — "الكود ده مش المفروض يوصله أبداً"
function throwError(message: string): never {
  throw new Error(message); // Function مش بترجع — بتـ throw دايماً
}

// استخدام شهير لـ never في Exhaustive Checks
type Shape = "circle" | "square";

function getArea(shape: Shape): number {
  switch (shape) {
    case "circle":  return 3.14 * 10 * 10;
    case "square":  return 10 * 10;
    default:
      const _exhaustive: never = shape; // لو ضفت type جديد ونسيت تضيفه هنا، هيديك Error
      throw new Error(`Unknown shape: ${shape}`);
  }
}
```

| | `any` | `unknown` | `never` |
| - | ----- | --------- | ------- |
| **معناه** | أي حاجة، بدون فحص | أي حاجة، بس بفحص | مستحيل يحصل |
| **الأمان** | ❌ خطر | ✅ آمن | ✅ للـ logic |
| **متى تستخدمه** | Migration من JS بس | Input خارجي مجهول | Functions بـ throw أو infinite loops |

**[⬆ Back to Top](#table-of-contents)**

---

### 4. إيه هو الـ Interface في TypeScript وإزاي بتستخدمه؟

الـ Interface بيعرّف "شكل" الـ Object — يعني بيقول الـ Object ده لازم يكون عنده إيه من properties ومن methods، من غير ما يقول إزاي بتتنفّذ.

تخيّل معايا إنك بتطلب اشتراك في نادي. الـ Interface هو الـ Form اللي بيقولك: "لازم تكتب الاسم، العمر، ورقم التليفون. لو ناقص حاجة من دول، مش هينفعك تكمّل."

```typescript
// تعريف الـ Interface
interface User {
  id: number;
  name: string;
  email: string;
  age?: number;         // ← الـ ? معناها Optional — ممكن تبقى موجودة أو لأ
  readonly createdAt: Date; // ← readonly: تتحدد مرة واحدة بس
}

// استخدام الـ Interface
const newUser: User = {
  id: 1,
  name: "Ahmed Hassan",
  email: "ahmed@example.com",
  createdAt: new Date(),
};

// newUser.createdAt = new Date(); // ❌ Error — readonly!
newUser.age = 25; // ✅ Optional، فممكن تضيفه بعدين

// Interface مع Function
interface AuthService {
  login(email: string, password: string): boolean;
  logout(): void;
  getCurrentUser(): User | null;
}

// Interface للـ Arrays
interface StringArray {
  [index: number]: string; // Index Signature
}
const myArray: StringArray = ["Ahmed", "Sara"]; // ✅

// Extending Interfaces — الوراثة في Interfaces
interface Admin extends User {
  role: "superadmin" | "editor";
  permissions: string[];
}

const admin: Admin = {
  id: 2,
  name: "Sara Admin",
  email: "sara@example.com",
  createdAt: new Date(),
  role: "superadmin",
  permissions: ["create", "delete", "update"],
};
```

**[⬆ Back to Top](#table-of-contents)**

---

### 5. إيه الفرق بين الـ Interface والـ Type Alias؟

الاتنين بيعملوا حاجة شبه بعض في معظم الحالات، بس فيه فروق مهمة.

```typescript
// ① Interface
interface Point {
  x: number;
  y: number;
}

// ② Type Alias
type Point2 = {
  x: number;
  y: number;
};

// كلاهما بيشتغلوا نفس الشغل هنا
const p1: Point = { x: 10, y: 20 };
const p2: Point2 = { x: 10, y: 20 };

// ─────────────────────────────────────────
// الفرق ①: Declaration Merging — موجودة في Interface بس
interface Animal {
  name: string;
}
interface Animal {
  sound: string; // ← بيتجمع مع الـ Interface الأول
}
// النتيجة: Animal = { name: string; sound: string; }

// Type Alias مش بيدعم ده
// type Animal = { name: string; };
// type Animal = { sound: string; }; // ❌ Error — Duplicate identifier!

// ─────────────────────────────────────────
// الفرق ②: Type Alias بيقدر يعمل Union Types وPrimitive Aliases
type ID = string | number;           // ✅ تقدر مع Type
type Status = "active" | "inactive"; // ✅ String Literal Union
// interface ID = string | number;   // ❌ Interface مش بتقدر

// ─────────────────────────────────────────
// الفرق ③: الـ Extends
interface Dog extends Animal {           // Interface بيستخدم extends
  breed: string;
}

type Cat = Animal & { indoor: boolean }; // Type بيستخدم Intersection &
```

**القاعدة العملية:**
- استخدم **Interface** لما بتعرّف شكل Object أو Class Contract.
- استخدم **Type** لما محتاج Union Types، Mapped Types، أو Conditional Types.

**[⬆ Back to Top](#table-of-contents)**

---

### 6. إيه هي الـ Classes في TypeScript وإيه دور الـ Access Modifiers؟

الـ Classes في TypeScript بتورث كل حاجة من الـ ES6 Classes وبتضيف عليها Access Modifiers اللي بتتحكم في مين يقدر يوصل لإيه.

```typescript
class BankAccount {
  // Access Modifiers
  public owner: string;      // ← الكل يوصله (default)
  private balance: number;   // ← Class بس
  protected accountNo: string; // ← Class والـ Subclasses بس
  readonly bankName: string = "National Bank"; // ← readonly: مش بتتغير

  constructor(owner: string, initialBalance: number) {
    this.owner = owner;
    this.balance = initialBalance;
    this.accountNo = Math.random().toString(36).substring(2);
  }

  // Shorthand Constructor — بدل ما تكتب كل ده
  // constructor(public owner: string, private balance: number) {}
  // TypeScript بيعمل الـ assignment تلقائياً!

  // Getter
  get currentBalance(): number {
    return this.balance;
  }

  // Setter مع Validation
  set depositAmount(amount: number) {
    if (amount <= 0) throw new Error("المبلغ لازم يكون أكبر من صفر");
    this.balance += amount;
  }

  public withdraw(amount: number): boolean {
    if (amount > this.balance) {
      console.log("رصيد غير كافٍ!");
      return false;
    }
    this.balance -= amount;
    return true;
  }
}

// Inheritance
class SavingsAccount extends BankAccount {
  private interestRate: number;

  constructor(owner: string, balance: number, rate: number) {
    super(owner, balance); // ← لازم أول سطر
    this.interestRate = rate;
  }

  applyInterest(): void {
    // تقدر توصل لـ protected من الـ Parent
    console.log(`Applying interest for account: ${this.accountNo}`);
    // this.balance → ❌ Error — private في الـ Parent
  }
}

// Static Members — بتبقى على الـ Class نفسها مش على الـ Objects
class MathUtils {
  static readonly PI = 3.14159;

  static circleArea(radius: number): number {
    return MathUtils.PI * radius * radius;
  }
}
console.log(MathUtils.PI);              // ✅
console.log(MathUtils.circleArea(5));   // ✅
```

**[⬆ Back to Top](#table-of-contents)**

---

### 7. إيه هو الـ Generic في TypeScript وإزاي بتستخدمه؟

الـ Generic بيخليك تكتب كود "مرن" بيشتغل مع أنواع مختلفة من غير ما تكرر نفس الكود أو تستخدم `any`.

تخيّل معايا إنك عندك صندوق (Box). الصندوق ممكن يحتوي على أي حاجة — كتاب، لعبة، أكل. الـ Generic هو إنك بتقول: "الصندوق ده بيحتوي على [X]"، وبتحدد X لما تستخدم الصندوق.

```typescript
// بدون Generic — مشكلة!
function getFirstElement(arr: any[]): any { // ← بتخسر معلومة الـ Type
  return arr[0];
}
const first = getFirstElement([1, 2, 3]);
// first.toFixed() // TypeScript مش عارف إنه number!

// مع Generic — ✅
function getFirstElement<T>(arr: T[]): T {
  return arr[0];
}

const firstNum = getFirstElement<number>([1, 2, 3]);
firstNum.toFixed(2); // ✅ TypeScript عارف إنه number

const firstStr = getFirstElement<string>(["Ahmed", "Sara"]);
firstStr.toUpperCase(); // ✅ TypeScript عارف إنه string

// TypeScript كمان بيقدر يـ infer الـ Type لوحده
const firstBool = getFirstElement([true, false]); // <boolean> اتحددت تلقائياً

// Generic مع Interface
interface ApiResponse<T> {
  data: T;
  statusCode: number;
  message: string;
}

// بتستخدمها مع أي نوع
type UserResponse = ApiResponse<User>;
type ProductsResponse = ApiResponse<Product[]>;

// Generic مع Classes
class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1];
  }
}

const numStack = new Stack<number>();
numStack.push(1);
numStack.push(2);
console.log(numStack.pop()); // 2

// Generic Constraints — بتقيّد الـ Generic بشروط
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]; // ← بيضمن إن الـ key موجودة في الـ Object
}
const user = { name: "Ahmed", age: 25 };
getProperty(user, "name"); // ✅
// getProperty(user, "salary"); // ❌ Error — "salary" مش موجودة في User
```

**[⬆ Back to Top](#table-of-contents)**

---

### 8. إيه هو الـ Union Type والـ Intersection Type؟

**Union Type** = "ممكن يكون النوع ده أو ده" (الـ OR).
**Intersection Type** = "لازم يكون النوع ده وده مع بعض" (الـ AND).

```typescript
// ① Union Type — استخدام | (OR)
type StringOrNumber = string | number;
let id: StringOrNumber;
id = "abc-123"; // ✅
id = 456;       // ✅
// id = true;   // ❌ — boolean مش في الـ Union

// Union مع Type Guards
function printId(id: string | number): void {
  if (typeof id === "string") {
    // هنا TypeScript عارف إنه string
    console.log(id.toUpperCase());
  } else {
    // هنا TypeScript عارف إنه number
    console.log(id.toFixed(2));
  }
}

// Union مع Literal Types
type Status = "pending" | "active" | "inactive" | "banned";
let userStatus: Status = "active"; // ✅
// userStatus = "deleted";         // ❌ Error — مش في الـ Union!

// ─────────────────────────────────────────
// ② Intersection Type — استخدام & (AND)
interface Serializable {
  serialize(): string;
}
interface Loggable {
  log(): void;
}

// لازم يكون عنده الاتنين مع بعض
type SerializableAndLoggable = Serializable & Loggable;

class DataManager implements SerializableAndLoggable {
  serialize(): string {
    return JSON.stringify(this);
  }
  log(): void {
    console.log(this.serialize());
  }
}

// Intersection مع Objects
type Employee = { name: string; employeeId: number };
type Manager = { department: string; reports: number };
type ManagerEmployee = Employee & Manager; // لازم يكون عنده كل الـ properties

const manager: ManagerEmployee = {
  name: "Ahmed",
  employeeId: 101,
  department: "Engineering",
  reports: 5,
};
```

**[⬆ Back to Top](#table-of-contents)**

---

### 9. إيه هو الـ Optional Chaining `?.` والـ Nullish Coalescing `??`؟

دول اتنين من أهم الـ operators اللي بتحميك من الـ "Cannot read properties of null/undefined" الشهيرة دي.

```typescript
interface Address {
  city?: string;
  zip?: {
    code: string;
  };
}
interface User {
  name: string;
  address?: Address; // ← Optional
}

const user: User = { name: "Ahmed" }; // مفيش address

// ❌ الطريقة القديمة — مؤلمة
const zip = user && user.address && user.address.zip && user.address.zip.code;

// ✅ Optional Chaining ?.
// لو أي حاجة في السلسلة null أو undefined، بيرجع undefined من غير Error
const zipCode = user?.address?.zip?.code;
console.log(zipCode); // undefined — من غير أي Error 🎉

// Optional Chaining مع Arrays والـ Methods
const users: User[] | null = null;
const firstUser = users?.[0];          // undefined
const nameLen = user?.name?.length;    // number أو undefined

// ─────────────────────────────────────────
// ② Nullish Coalescing ?? — "لو null أو undefined، حط القيمة دي بدلها"
const username = null ?? "Guest";    // "Guest"
const score = undefined ?? 0;        // 0
const level = 0 ?? 1;               // 0 ← هنا الفرق عن ||

// الفرق بين ?? و||
const value1 = 0 || "default";      // "default" ← لأن 0 هو falsy
const value2 = 0 ?? "default";      // 0 ← لأن 0 مش null/undefined

// دمج الاتنين مع بعض — قوة حقيقية
const displayName = user?.address?.city ?? "City not provided";
console.log(displayName); // "City not provided"
```

**[⬆ Back to Top](#table-of-contents)**

---

### 10. إيه هو الـ Enum في TypeScript وامتى بتستخدمه؟

الـ Enum (Enumeration) بيخليك تعرّف مجموعة من الـ Constants بأسماء واضحة بدل ما تستخدم أرقام أو strings من غير معنى.

```typescript
// ① Numeric Enum (الـ default)
enum Direction {
  Up,    // = 0
  Down,  // = 1
  Left,  // = 2
  Right, // = 3
}

let playerDirection: Direction = Direction.Up;
console.log(playerDirection);         // 0
console.log(Direction[0]);            // "Up" — Reverse Mapping!

// Numeric Enum مع قيم محددة
enum HttpStatus {
  OK = 200,
  Created = 201,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  InternalServerError = 500,
}

function handleResponse(status: HttpStatus): void {
  switch (status) {
    case HttpStatus.OK:
      console.log("✅ Success!");
      break;
    case HttpStatus.NotFound:
      console.log("❌ Resource not found");
      break;
    default:
      console.log("Unknown status");
  }
}

// ② String Enum — أوضح وأأمن في الـ Debugging
enum UserRole {
  Admin = "ADMIN",
  Editor = "EDITOR",
  Viewer = "VIEWER",
}

const role: UserRole = UserRole.Admin;
console.log(role); // "ADMIN" — واضح في الـ logs

// ③ Const Enum — أسرع (بيتحذف في الـ Compilation)
const enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE",
}
const bg: Color = Color.Blue; // بيتحوّل لـ "BLUE" مباشرة في الكود المترجم
```

> **نصيحة:** في Angular كتير بنستخدم الـ String Enums للـ API Status codes والـ User Roles عشان الـ Debugging بيبقى أوضح.

**[⬆ Back to Top](#table-of-contents)**

---

## Section 2: Angular Core & Architecture

### 11. إيه هو Angular وإيه أهم مميزاته؟

Angular هو Framework من Google مبني على TypeScript، بيستخدم لبناء Single Page Applications (SPAs). مش مجرد Library زي React — ده Framework كامل بيجيب معاه كل حاجة جاهزة: Router، HTTP Client، Forms، Testing.

```
Angular Architecture — Overview:

┌─────────────────────────────────────────────────┐
│                  Angular Application             │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐ │
│  │ Components│  │ Services │  │    Modules    │ │
│  │(UI Logic) │  │(Business │  │ (Standalone)  │ │
│  └──────────┘  │  Logic)  │  └───────────────┘ │
│       ↕        └──────────┘         ↕           │
│  ┌──────────┐       ↕         ┌───────────────┐ │
│  │Templates │  ┌──────────┐   │   Router      │ │
│  │  (HTML)  │  │  RxJS /  │   │  (Navigation) │ │
│  └──────────┘  │  HTTP    │   └───────────────┘ │
│                └──────────┘                     │
└─────────────────────────────────────────────────┘
```

**أهم مميزات Angular:**
- **Two-Way Data Binding:** الـ UI والـ Data بيتزامنوا تلقائياً.
- **Dependency Injection:** نظام DI قوي جداً مدمج في الـ Framework.
- **TypeScript First:** مبني عليه من الأساس — مش اختياري.
- **RxJS:** الـ Reactive Programming مدمج.
- **Angular CLI:** أداة قوية لبناء وتطوير وtest الـ App.
- **Standalone Components (Angular 14+):** مش محتاج NgModules.

**[⬆ Back to Top](#table-of-contents)**

---

### 12. إيه هو الـ NgModule وإيه المكونات اللي جوّاه؟

الـ `NgModule` هو "حاوية" بتجمع Components وServices وDirectives وPipes اللي بتتعامل مع بعض. الـ Angular Apps القديمة كانت مبنية عليه بالكامل.

```typescript
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { AppRoutingModule } from './app-routing.module';

import { AppComponent } from './app.component';
import { UserListComponent } from './user-list/user-list.component';
import { UserCardComponent } from './user-card/user-card.component';

@NgModule({
  declarations: [
    // ← الـ Components والـ Directives والـ Pipes الخاصة بالـ Module ده
    AppComponent,
    UserListComponent,
    UserCardComponent,
  ],
  imports: [
    // ← Modules تانية محتاجة جوا الـ Module ده
    BrowserModule,
    FormsModule,
    AppRoutingModule,
  ],
  providers: [
    // ← الـ Services اللي هتكون available في الـ Module ده
    // (في الغالب بنستخدم providedIn: 'root' بدل كده)
  ],
  bootstrap: [AppComponent], // ← الـ Root Component — بيكون موجود في AppModule بس
  exports: [
    // ← Components بتاعتك اللي عايز Modules تانية تستخدمها
    UserCardComponent,
  ]
})
export class AppModule {}
```

| Property | بيعمل إيه |
| -------- | --------- |
| `declarations` | الـ Components والـ Directives والـ Pipes بتاعة الـ Module |
| `imports` | Modules تانية محتاجها |
| `providers` | الـ Services |
| `bootstrap` | الـ Root Component (في AppModule بس) |
| `exports` | حاجات عايز تبقى متاحة لـ Modules تانية |

**[⬆ Back to Top](#table-of-contents)**

---

### 13. إيه هو الـ Standalone Component وإزاي بيختلف عن الـ Module-based؟

من Angular 14 وبيتطور في 17+، الـ Standalone Components بتخليك تعمل Components من غير ما تحطها في NgModule. ده بيبسّط الكود جداً وبيخلي كل Component مسؤول عن نفسه.

```typescript
// ✅ Standalone Component — Angular 14+
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { UserCardComponent } from './user-card/user-card.component';

@Component({
  selector: 'app-user-list',
  standalone: true, // ← المفتاح هنا!
  imports: [
    // بدل ما تحطها في NgModule، بتحط الـ imports هنا مباشرة
    CommonModule,
    RouterModule,
    UserCardComponent, // ← تقدر تـ import Standalone Components تانية مباشرة
  ],
  template: `
    <h2>Users</h2>
    <app-user-card *ngFor="let user of users" [user]="user" />
  `,
})
export class UserListComponent {
  users = ['Ahmed', 'Sara', 'Omar'];
}

// ─────────────────────────────────────────
// الـ main.ts في Standalone App
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, {
  providers: [
    // هنا بتحط الـ global providers
  ]
});
```

| | Module-based | Standalone |
| - | ------------ | ---------- |
| **الـ `NgModule`** | إلزامي | مش مطلوب |
| **الـ imports** | في الـ Module | في الـ Component مباشرة |
| **الـ Boilerplate** | أكتر | أقل |
| **الـ Angular Version** | الأصل | 14+ (الـ default في 17+) |

**[⬆ Back to Top](#table-of-contents)**

---

### 14. إزاي بتعمل Angular Project جديد بالـ CLI خطوة بخطوة؟

```bash
# ① تثبيت الـ Angular CLI عالمياً (مرة واحدة بس)
npm install -g @angular/cli

# تأكد إن التثبيت نجح
ng version

# ② إنشاء Project جديد
ng new my-banking-app
# الـ CLI هيسألك:
# - هتضيف Angular routing? (Yes/No) → Yes
# - أي stylesheet format? → CSS أو SCSS حسب تفضيلك

# ③ الدخول على الـ Project وتشغيله
cd my-banking-app
ng serve
# أو:
ng serve --open  # ← بيفتح الـ Browser تلقائياً على http://localhost:4200

# ④ إنشاء Project مع Standalone Components (Angular 17+ الـ default)
ng new my-app --standalone
```

**هيكل الـ Project اللي هيتعمل:**
```
my-banking-app/
├── src/
│   ├── app/
│   │   ├── app.component.ts       ← الـ Root Component
│   │   ├── app.component.html     ← الـ Template
│   │   ├── app.component.scss     ← الـ Styles
│   │   ├── app.component.spec.ts  ← الـ Tests
│   │   └── app.module.ts          ← الـ Root Module
│   ├── assets/                    ← Fonts, Images, etc.
│   ├── index.html                 ← الـ HTML الرئيسي
│   ├── main.ts                    ← Entry Point
│   └── styles.scss                ← Global Styles
├── angular.json                   ← Angular Config
├── package.json                   ← NPM Dependencies
└── tsconfig.json                  ← TypeScript Config
```

**[⬆ Back to Top](#table-of-contents)**

---

### 15. إيه أهم الـ Angular CLI Commands اللي لازم تعرفها؟

```bash
# ─── إنشاء Building Blocks ───
ng generate component components/user-list
ng g c components/user-list                # shorthand
# بيعمل: user-list.component.ts/.html/.scss/.spec.ts

ng generate service services/auth
ng g s services/auth
# بيعمل: auth.service.ts + auth.service.spec.ts

ng generate module features/products
ng g m features/products

ng generate pipe pipes/truncate
ng g p pipes/truncate

ng generate directive directives/highlight
ng g d directives/highlight

ng generate guard guards/auth
ng g guard guards/auth

# ─── Build & Serve ───
ng serve                          # Development server
ng serve --port 4300              # على port مختلف
ng build                          # Production build (في dist/ folder)
ng build --configuration=staging  # Build لـ environment معين

# ─── Testing ───
ng test                           # Unit Tests بـ Karma
ng e2e                            # End-to-End Tests

# ─── Linting ───
ng lint                           # بيتحقق من الـ Code Style

# ─── Update ───
ng update                                         # بيشوف إيه اللي محتاج يتحدّث
ng update @angular/core @angular/cli              # تحديث Angular نفسه
```

**[⬆ Back to Top](#table-of-contents)**

---

### 16. إيه هو الـ `main.ts` وإيه دوره في تشغيل الـ App؟

الـ `main.ts` هو نقطة البداية لأي Angular Application. هو أول ملف بيتشغّل لما الـ Browser يحمّل الـ App.

```typescript
// main.ts في الـ NgModule-based App (القديم)
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic()
  .bootstrapModule(AppModule) // ← بيبدأ الـ App من الـ AppModule
  .catch(err => console.error(err));

// ─────────────────────────────────────────
// main.ts في الـ Standalone App (الحديث — Angular 17+)
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, appConfig) // ← بيبدأ من الـ Component مباشرة
  .catch(err => console.error(err));

// ─────────────────────────────────────────
// app.config.ts — الـ App-level Config في Standalone
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),    // ← تفعيل الـ Routing
    provideHttpClient(),      // ← تفعيل الـ HTTP Client
  ]
};
```

**ترتيب تشغيل الـ App:**
```
Browser يحمّل index.html
        ↓
index.html بيلوّد main.ts
        ↓
main.ts بيعمل bootstrap للـ AppComponent
        ↓
AppComponent بيتعمل render في <app-root>
        ↓
App شغّالة ✅
```

**[⬆ Back to Top](#table-of-contents)**

---

### 17. إيه الفرق بين الـ AOT والـ JIT Compilation في Angular؟

```
JIT (Just-In-Time):
Browser يحمّل الـ App
        ↓
Angular Compiler بيتحمّل في الـ Browser
        ↓
بيـ Compile الـ Templates في الـ Browser (بطيء!)
        ↓
الـ App بتشتغل

AOT (Ahead-Of-Time):
ng build بيتشغّل على سيرفرك
        ↓
Angular Compiler بيـ Compile كل حاجة قبل الـ Deployment
        ↓
Browser بيحمّل كود JavaScript جاهز (سريع!)
        ↓
الـ App بتشتغل أسرع بكتير ✅
```

| | JIT | AOT |
| - | --- | --- |
| **وقت الـ Compilation** | في الـ Browser (Runtime) | قبل الـ Deployment (Build Time) |
| **الـ Speed** | أبطأ في البداية | أسرع للـ User |
| **الـ Bundle Size** | أكبر (بيشمل الـ Compiler) | أصغر |
| **الـ Errors** | بتظهر في الـ Runtime | بتظهر في الـ Build |
| **متى بيستخدم** | `ng serve` (Development) | `ng build` (Production) |

> **في Angular 9+:** الـ Ivy Compiler هو الـ default وهو AOT بطبيعته حتى في الـ Development.

**[⬆ Back to Top](#table-of-contents)**

---

### 18. إيه هو ملف الـ `angular.json` وبيعمل إيه؟

الـ `angular.json` هو الملف اللي بيتحكم في كل إعدادات الـ Angular Project. الـ CLI بيقراه عشان يعرف يعمل إيه.

```jsonc
// angular.json — أهم الأجزاء
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "options": {
            "outputPath": "dist/my-app",    // ← بيتحط فين الـ Build
            "index": "src/index.html",
            "main": "src/main.ts",          // ← Entry Point
            "styles": ["src/styles.scss"],  // ← Global Styles
            "assets": ["src/assets"],       // ← Static Files
            "budgets": [                    // ← حدود حجم الـ Bundle
              {
                "type": "initial",
                "maximumWarning": "500kb",
                "maximumError": "1mb"
              }
            ]
          },
          "configurations": {
            "production": {
              "optimization": true,          // ← تصغير الكود
              "sourceMap": false,
              "fileReplacements": [          // ← بيستبدل environment files
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.prod.ts"
                }
              ]
            }
          }
        },
        "serve": {
          "options": {
            "port": 4200,
            "proxyConfig": "proxy.conf.json" // ← لو محتاج API Proxy
          }
        }
      }
    }
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

## Section 3: Components & Data Binding

### 19. إيه هو الـ Component في Angular وإزاي بتعمله؟

الـ Component هو اللبنة الأساسية لأي Angular App. كل حاجة شايفها على الشاشة هي Component. الـ Component عبارة عن 3 حاجات: TypeScript Class (اللوجيك)، Template HTML (الشكل)، و Stylesheet (الـ Styles).

```typescript
// user-card.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-card',        // ← الـ HTML Tag بتاعته
  standalone: true,
  imports: [CommonModule],
  templateUrl: './user-card.component.html',   // ← الـ Template في ملف منفصل
  styleUrls: ['./user-card.component.scss'],
  // أو:
  template: `<h2>Hello {{ name }}</h2>`,        // ← Inline Template
  styles: [`h2 { color: blue; }`],              // ← Inline Styles
})
export class UserCardComponent {
  name: string = 'Ahmed';
  isLoggedIn: boolean = true;
  score: number = 95.5;
}
```

```html
<!-- user-card.component.html -->
<div class="user-card">
  <h2>{{ name }}</h2>
  <p>Score: {{ score | number:'1.1-2' }}</p>
  <span *ngIf="isLoggedIn">🟢 Online</span>
</div>
```

```html
<!-- إزاي بتستخدم الـ Component في Template تاني -->
<app-user-card></app-user-card>
```

**[⬆ Back to Top](#table-of-contents)**

---

### 20. إيه هو الـ Interpolation وإزاي بتستخدمه؟

الـ Interpolation هو أبسط طريقة لعرض data من الـ TypeScript Class في الـ HTML Template. بتستخدم `{{ }}` الـ double curly braces.

```typescript
// product.component.ts
@Component({
  selector: 'app-product',
  standalone: true,
  template: `
    <h1>{{ productName }}</h1>
    <p>Price: {{ price }} EGP</p>
    <p>Discounted: {{ price * 0.9 }} EGP</p>
    <p>{{ isAvailable ? '✅ In Stock' : '❌ Out of Stock' }}</p>
    <p>{{ productName.toUpperCase() }}</p>
    <p>{{ getDescription() }}</p>
  `
})
export class ProductComponent {
  productName: string = 'iPhone 15 Pro';
  price: number = 55000;
  isAvailable: boolean = true;

  getDescription(): string {
    return `${this.productName} — Available at ${this.price} EGP`;
  }
}
```

> **انتبه:** الـ Interpolation مخصص للـ string values بس. لو عايز تبعت قيمة لـ attribute زي `disabled` أو `href`، لازم تستخدم الـ Property Binding.
>
> الـ Interpolation مش بيعمّل `<script>` tags لو حد بعت كود خبيث — Angular بيـ sanitize تلقائياً.

**[⬆ Back to Top](#table-of-contents)**

---

### 21. إيه هو الـ Property Binding وإزاي بيختلف عن الـ Interpolation؟

الـ Property Binding بيربط الـ property بتاعة الـ HTML element بـ value من الـ Component. بتستخدم `[property]="expression"`.

```typescript
@Component({
  selector: 'app-demo',
  standalone: true,
  template: `
    <!-- Property Binding — بيربط property في الـ DOM -->
    <button [disabled]="isLoading">
      {{ isLoading ? 'Saving...' : 'Save' }}
    </button>

    <img [src]="imageUrl" [alt]="imageAlt" [width]="imageWidth" />

    <input [value]="username" [placeholder]="inputPlaceholder" />

    <!-- Class Binding -->
    <div [class.active]="isActive">
      Active only when isActive = true
    </div>

    <!-- Style Binding -->
    <p [style.color]="textColor" [style.fontSize.px]="fontSize">
      Styled Text
    </p>

    <!-- ❌ الفرق عن Interpolation -->
    <!-- Interpolation — بيعمل String -->
    <img src="{{ imageUrl }}" />  <!-- ← ممكن يطلع broken لحظة التحميل -->

    <!-- Property Binding — أحسن للـ non-string values -->
    <img [src]="imageUrl" />      <!-- ← أسرع وأأمن -->
  `
})
export class DemoComponent {
  isLoading: boolean = false;
  isActive: boolean = true;
  imageUrl: string = 'https://example.com/avatar.jpg';
  imageAlt: string = 'User Avatar';
  imageWidth: number = 100; // ← number مش string — مناسب لـ Property Binding
  username: string = 'ahmed_dev';
  inputPlaceholder: string = 'Enter your name';
  textColor: string = 'dodgerblue';
  fontSize: number = 16;
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 22. إيه هو الـ Event Binding وإزاي بتتعامل مع الـ Events؟

الـ Event Binding بيخليك "تسمع" لـ events زي الـ click، keyup، submit وتستجاب عليها. بتستخدم `(event)="handler()"`.

```typescript
@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <!-- Click Event -->
    <button (click)="increment()">+1</button>
    <span>{{ count }}</span>
    <button (click)="decrement()">-1</button>

    <!-- Event مع $event object -->
    <input (keyup)="onKeyUp($event)" placeholder="Type here..." />
    <p>You typed: {{ typedText }}</p>

    <!-- Submit Event -->
    <form (submit)="onSubmit($event)">
      <input [(ngModel)]="username" />
      <button type="submit">Login</button>
    </form>

    <!-- Mouse Events -->
    <div
      (mouseover)="onHover(true)"
      (mouseout)="onHover(false)"
      [class.hovered]="isHovered">
      Hover me!
    </div>

    <!-- Key Events — فلترة لمفتاح معين -->
    <input (keyup.enter)="onEnterPressed()" placeholder="Press Enter..." />
  `
})
export class CounterComponent {
  count: number = 0;
  typedText: string = '';
  username: string = '';
  isHovered: boolean = false;

  increment(): void { this.count++; }
  decrement(): void { this.count--; }

  onKeyUp(event: KeyboardEvent): void {
    this.typedText = (event.target as HTMLInputElement).value;
  }

  onSubmit(event: Event): void {
    event.preventDefault(); // ← منع الـ Form من الـ Reload
    console.log('Logging in:', this.username);
  }

  onHover(state: boolean): void { this.isHovered = state; }

  onEnterPressed(): void { console.log('Enter pressed!'); }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 23. إيه هو الـ Two-Way Data Binding و`[(ngModel)]`؟

الـ Two-Way Binding بيجمع الـ Property Binding والـ Event Binding في واحد. التغيير في الـ UI بيحدّث الـ Data والعكس بالعكس. الـ Syntax بتاعه `[(ngModel)]` اتشهر بالاسم "Banana in a Box" 🍌.

```typescript
// لازم تـ import FormsModule الأول!
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-login-form',
  standalone: true,
  imports: [FormsModule], // ← ضروري لـ [(ngModel)]
  template: `
    <h2>Login</h2>

    <!-- [(ngModel)] = Two-Way Binding -->
    <input [(ngModel)]="email" placeholder="Email" type="email" />
    <input [(ngModel)]="password" placeholder="Password" type="password" />

    <p>Hello, {{ email }}</p>
    <!-- بمجرد ما الـ user يكتب في الـ input، الـ email بيتحدث تلقائياً -->

    <!-- إزاي [(ngModel)] بتشتغل من تحت -->
    <!-- ده بالظبط نفس: -->
    <input [value]="email" (input)="email = $any($event.target).value" />

    <button (click)="onLogin()">Login</button>
    <button (click)="resetForm()">Reset</button>
  `
})
export class LoginFormComponent {
  email: string = '';
  password: string = '';

  onLogin(): void {
    console.log('Logging in with:', this.email);
  }

  resetForm(): void {
    this.email = '';       // ← بيعمل reset للـ input في الـ UI تلقائياً
    this.password = '';
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 24. إيه هو الـ `@Input()` وإزاي بتبعت data من Parent لـ Child Component؟

الـ `@Input()` بيخلي الـ Child Component يستقبل data من الـ Parent Component عن طريق الـ Template.

```
Parent Component
     ↓  [data]="parentValue"  ↓
Child Component (@Input() data)
```

```typescript
// child: user-card.component.ts
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string;
}

@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card">
      <img [src]="user.avatar || 'default.jpg'" [alt]="user.name" />
      <h3>{{ user.name }}</h3>
      <p>{{ user.email }}</p>
      <span *ngIf="isHighlighted" class="badge">⭐ Featured</span>
    </div>
  `
})
export class UserCardComponent {
  @Input() user!: User;            // ← required input (Angular 16+: @Input({required: true}))
  @Input() isHighlighted: boolean = false; // ← optional مع default value

  // Angular 16+ — Required Input بشكل رسمي
  // @Input({ required: true }) user!: User;
}

// ─────────────────────────────────────────
// parent: user-list.component.ts
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, UserCardComponent],
  template: `
    <h2>Our Team</h2>

    <!-- بتبعت data لكل Card -->
    <app-user-card
      *ngFor="let user of users; let i = index"
      [user]="user"
      [isHighlighted]="i === 0">
    </app-user-card>
  `
})
export class UserListComponent {
  users: User[] = [
    { id: 1, name: 'Ahmed Hassan', email: 'ahmed@company.com' },
    { id: 2, name: 'Sara Ahmed', email: 'sara@company.com' },
    { id: 3, name: 'Omar Khaled', email: 'omar@company.com' },
  ];
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 25. إيه هو الـ `@Output()` والـ `EventEmitter` وإزاي بتتواصل من Child لـ Parent؟

الـ `@Output()` بيخلي الـ Child يبعت Events للـ Parent. زي ما الـ `@Input()` بيجيب data للأسفل، الـ `@Output()` بيبعت events للأعلى.

```
Parent Component (بيـ listen للـ event)
     ↑  (eventName)="handler($event)"  ↑
Child Component (@Output() eventName = new EventEmitter())
```

```typescript
// child: user-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `
    <div class="card">
      <h3>{{ user.name }}</h3>
      <button (click)="onSelectUser()">View Profile</button>
      <button (click)="onDeleteUser()">🗑️ Delete</button>
    </div>
  `
})
export class UserCardComponent {
  @Input() user!: { id: number; name: string };

  @Output() userSelected = new EventEmitter<number>(); // ← بتبعت الـ id
  @Output() userDeleted = new EventEmitter<{ id: number; name: string }>();

  onSelectUser(): void {
    this.userSelected.emit(this.user.id); // ← بيبعت الـ event للـ Parent
  }

  onDeleteUser(): void {
    this.userDeleted.emit(this.user); // ← بيبعت الـ user object كامل
  }
}

// ─────────────────────────────────────────
// parent: user-list.component.ts
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [UserCardComponent, CommonModule],
  template: `
    <app-user-card
      *ngFor="let user of users"
      [user]="user"
      (userSelected)="onUserSelected($event)"
      (userDeleted)="onUserDeleted($event)">
    </app-user-card>

    <p *ngIf="selectedUserId">Selected ID: {{ selectedUserId }}</p>
  `
})
export class UserListComponent {
  users = [
    { id: 1, name: 'Ahmed' },
    { id: 2, name: 'Sara' },
  ];
  selectedUserId: number | null = null;

  onUserSelected(userId: number): void {
    this.selectedUserId = userId; // ← $event = الـ value اللي الـ Child بعته
    console.log('User selected:', userId);
  }

  onUserDeleted(user: { id: number; name: string }): void {
    this.users = this.users.filter(u => u.id !== user.id);
    console.log(`Deleted: ${user.name}`);
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 26. إيه هي الـ Lifecycle Hooks في Angular وإيه ترتيبها؟

الـ Lifecycle Hooks هي methods جاهزة Angular بيستدعيها تلقائياً في أوقات مختلفة في حياة الـ Component.

```typescript
import {
  Component, Input, OnInit, OnChanges, OnDestroy,
  AfterViewInit, AfterContentInit, DoCheck,
  SimpleChanges
} from '@angular/core';

@Component({
  selector: 'app-lifecycle-demo',
  standalone: true,
  template: `<p>{{ message }}</p>`
})
export class LifecycleDemoComponent implements OnInit, OnChanges, OnDestroy, AfterViewInit {
  @Input() message: string = '';

  // ① constructor — مش Lifecycle Hook رسمي، بس أول حاجة بتحصل
  constructor() {
    console.log('1. constructor — الـ Class اتعملت، الـ Inputs لسه مجاتش');
  }

  // ② ngOnChanges — بيتنادى لما @Input يتغير
  ngOnChanges(changes: SimpleChanges): void {
    console.log('2. ngOnChanges — Input اتغير:', changes['message']);
    // changes['message'].previousValue → القيمة القديمة
    // changes['message'].currentValue  → القيمة الجديدة
    // changes['message'].firstChange   → true لو أول مرة
  }

  // ③ ngOnInit — بيتنادى مرة واحدة بعد ما كل الـ Inputs اتحطت
  ngOnInit(): void {
    console.log('3. ngOnInit — ✅ أنسب مكان لجلب الـ Data من الـ API');
  }

  // ④ ngDoCheck — بيتنادى في كل Change Detection cycle
  ngDoCheck(): void {
    // استخدمه بحرص — بيتنادى كتير جداً!
  }

  // ⑤ ngAfterContentInit — بعد الـ Content Projection (ng-content)
  ngAfterContentInit(): void {
    console.log('5. ngAfterContentInit');
  }

  // ⑥ ngAfterViewInit — بعد ما الـ Template اتعرض كامل
  ngAfterViewInit(): void {
    console.log('6. ngAfterViewInit — ✅ أنسب مكان للـ DOM manipulation و@ViewChild');
  }

  // ⑦ ngOnDestroy — قبل ما الـ Component يتحذف
  ngOnDestroy(): void {
    console.log('7. ngOnDestroy — ✅ هنا بنعمل Cleanup: unsubscribe من الـ Observables');
  }
}
```

**ترتيب الـ Lifecycle:**
```
constructor()
     ↓
ngOnChanges() ← لو في @Input
     ↓
ngOnInit()
     ↓
ngDoCheck()
     ↓
ngAfterContentInit()
     ↓
ngAfterViewInit()
     ↓
[الـ Component شغّال] ← ngOnChanges() / ngDoCheck() بيتنادوا لما يحصل تغيير
     ↓
ngOnDestroy()
```

**[⬆ Back to Top](#table-of-contents)**

---

### 27. إيه الفرق بين الـ `ngOnInit` والـ `constructor`؟

ده سؤال كلاسيكي في الإنترفيوز وكتير بتيجي فيه.

```typescript
import { Component, Input, OnInit } from '@angular/core';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `<p>{{ user?.name }}</p>`
})
export class UserProfileComponent implements OnInit {
  @Input() userId!: number;
  user: any = null;

  // ❌ الـ constructor للـ Dependency Injection بس
  constructor(private userService: UserService) {
    // الـ Inputs (@Input) لسه مجاتش هنا! userId هيبقى undefined
    console.log('constructor — userId:', this.userId); // undefined!

    // ❌ متعملش API calls هنا
    // this.userService.getUser(this.userId); // userId = undefined!
  }

  // ✅ الـ ngOnInit للـ Logic والـ API Calls
  ngOnInit(): void {
    // الـ Inputs وصلت هنا
    console.log('ngOnInit — userId:', this.userId); // 123 ✅

    // ✅ صح — هنا بتجيب الـ Data
    this.userService.getUser(this.userId).subscribe(user => {
      this.user = user;
    });
  }
}
```

| | `constructor` | `ngOnInit` |
| - | ------------- | ---------- |
| **وقت التنفيذ** | فور إنشاء الـ Class | بعد الـ Inputs |
| **الـ @Input** | ❌ غير متاح (undefined) | ✅ متاح |
| **الاستخدام** | Dependency Injection فقط | Logic والـ API Calls |
| **Angular Specific** | لأ (TypeScript عادي) | أيوه (Angular Hook) |

**[⬆ Back to Top](#table-of-contents)**

---

### 28. إيه هو الـ `@ViewChild` وإزاي بتوصل لـ Child Element من الـ Template؟

الـ `@ViewChild` بيخليك تمسك reference لـ Element أو Component موجود في الـ Template وتتعامل معاه من الـ TypeScript Class.

```typescript
import { Component, ViewChild, ElementRef, AfterViewInit, OnInit } from '@angular/core';
import { UserCardComponent } from './user-card.component';

@Component({
  selector: 'app-demo',
  standalone: true,
  imports: [UserCardComponent],
  template: `
    <input #emailInput type="email" placeholder="Enter email" />
    <button (click)="focusInput()">Focus Input</button>

    <app-user-card #userCard [user]="currentUser"></app-user-card>
    <button (click)="resetCard()">Reset Card</button>
  `
})
export class DemoComponent implements AfterViewInit {
  currentUser = { id: 1, name: 'Ahmed' };

  // مسك reference لـ HTML Element بالـ #emailInput
  @ViewChild('emailInput') emailInputRef!: ElementRef<HTMLInputElement>;

  // مسك reference لـ Child Component بالـ #userCard
  @ViewChild('userCard') userCardRef!: UserCardComponent;

  // ✅ الـ @ViewChild بيكون متاح بعد ngAfterViewInit
  ngAfterViewInit(): void {
    console.log('Input element:', this.emailInputRef.nativeElement);
    // هنا تقدر تتعامل مع الـ DOM element مباشرة
  }

  focusInput(): void {
    this.emailInputRef.nativeElement.focus(); // ← Focus مباشر على الـ Input
  }

  resetCard(): void {
    // تقدر تستدعي methods من الـ Child Component مباشرة
    // this.userCardRef.someMethod();
  }
}
```

> **انتبه:** التعامل المباشر مع الـ DOM عبر `nativeElement` مش مستحسن إلا لو مفيش بديل. الأفضل استخدام Angular's abstractions زي Data Binding.

**[⬆ Back to Top](#table-of-contents)**

---

## Section 4: Directives & Pipes

### 29. إيه هو الـ Directive في Angular وإيه أنواعه؟

الـ Directive هو "تعليمة" بتضيفها لـ HTML Element عشان تغير سلوكه أو شكله. في Angular 3 أنواع من الـ Directives:

```typescript
// ① Component Directive — ده هو الـ Component نفسه! بيضيف Template
// كل Component هو Directive بتاعته Template

// ─────────────────────────────────────────
// ② Structural Directive — بتغير هيكل الـ DOM
// بيضيف أو بيشيل Elements من الـ DOM

// *ngIf — بيضيف/بيشيل Element
<div *ngIf="isLoggedIn">Welcome back!</div>

// *ngFor — بيعمل Loop
<li *ngFor="let item of items">{{ item }}</li>

// *ngSwitch — بيختار element حسب قيمة
<div [ngSwitch]="userRole">
  <p *ngSwitchCase="'admin'">Admin Panel</p>
  <p *ngSwitchCase="'user'">User Dashboard</p>
  <p *ngSwitchDefault>Guest View</p>
</div>

// ─────────────────────────────────────────
// ③ Attribute Directive — بتغير شكل أو سلوك Element موجود
// [ngClass], [ngStyle] — Angular Built-in
// ممكن تعملها Custom:

import { Directive, ElementRef, HostListener, Input } from '@angular/core';

@Directive({
  selector: '[appHighlight]', // ← هتستخدمها كـ attribute
  standalone: true,
})
export class HighlightDirective {
  @Input() appHighlight: string = 'yellow'; // ← لون الـ highlight

  constructor(private el: ElementRef) {}

  @HostListener('mouseenter') onMouseEnter(): void {
    this.el.nativeElement.style.backgroundColor = this.appHighlight;
  }

  @HostListener('mouseleave') onMouseLeave(): void {
    this.el.nativeElement.style.backgroundColor = '';
  }
}
```

```html
<!-- استخدام الـ Custom Directive -->
<p appHighlight="lightblue">Hover over me!</p>
<p [appHighlight]="'pink'">Hover over me too!</p>
```

**[⬆ Back to Top](#table-of-contents)**

---

### 30. إزاي بتستخدم `*ngIf` والـ `@if` الجديدة في Angular 17+؟

```html
<!-- ① الطريقة القديمة — *ngIf (لا زالت شغّالة) -->
<div *ngIf="isLoggedIn">
  <h2>Welcome, {{ username }}!</h2>
</div>

<!-- *ngIf مع else -->
<div *ngIf="isLoggedIn; else guestTemplate">
  <h2>Welcome back!</h2>
</div>
<ng-template #guestTemplate>
  <h2>Please login first</h2>
</ng-template>

<!-- *ngIf مع then و else -->
<ng-container *ngIf="isLoading; then loadingTmpl; else contentTmpl"></ng-container>
<ng-template #loadingTmpl><p>Loading...</p></ng-template>
<ng-template #contentTmpl><p>Content loaded!</p></ng-template>

<!-- ─────────────────────────────────────────── -->
<!-- ② الطريقة الجديدة — @if (Angular 17+) — أوضح وأسهل! -->
@if (isLoggedIn) {
  <h2>Welcome back, {{ username }}!</h2>
} @else if (isPending) {
  <p>Your account is pending approval</p>
} @else {
  <p>Please login</p>
}

<!-- @if مع async pipe -->
@if (user$ | async; as user) {
  <p>Hello, {{ user.name }}</p>
}
```

```typescript
@Component({
  selector: 'app-auth-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (authState === 'loading') {
      <div class="spinner">Loading...</div>
    } @else if (authState === 'authenticated') {
      <div class="dashboard">Welcome {{ username }}</div>
    } @else {
      <div class="login-form">Please sign in</div>
    }
  `
})
export class AuthDemoComponent {
  authState: 'loading' | 'authenticated' | 'guest' = 'guest';
  username = 'Ahmed';
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 31. إزاي بتستخدم `*ngFor` والـ `@for` الجديدة في Angular 17+؟

```html
<!-- ① الطريقة القديمة — *ngFor -->
<ul>
  <li *ngFor="let product of products; let i = index; trackBy: trackByProductId">
    {{ i + 1 }}. {{ product.name }} — {{ product.price }} EGP
  </li>
</ul>

<!-- الـ Local Variables في *ngFor -->
<div *ngFor="let item of items;
             let i = index;
             let first = first;
             let last = last;
             let even = even;
             let odd = odd">
  <span *ngIf="first">🥇 First!</span>
  {{ item }}
  <span *ngIf="last">🏁 Last!</span>
</div>

<!-- ─────────────────────────────────────────── -->
<!-- ② الطريقة الجديدة — @for (Angular 17+) — track إلزامي! -->
@for (product of products; track product.id) {
  <div class="product-card">
    <h3>{{ product.name }}</h3>
    <p>{{ product.price }} EGP</p>
  </div>
} @empty {
  <p>No products found! 🛒</p>
}

<!-- Local Variables في @for -->
@for (item of items; track item.id; let idx = $index, f = $first, l = $last) {
  <div [class.first]="f" [class.last]="l">
    {{ idx + 1 }}. {{ item.name }}
  </div>
}
```

```typescript
@Component({
  selector: 'app-products',
  standalone: true,
  imports: [CommonModule],
  template: `
    @for (product of products; track product.id) {
      <div class="card">{{ product.name }}</div>
    } @empty {
      <p>No products available</p>
    }
  `
})
export class ProductsComponent {
  products = [
    { id: 1, name: 'Laptop', price: 25000 },
    { id: 2, name: 'Phone', price: 15000 },
  ];

  // للـ *ngFor القديم — trackBy function
  trackByProductId(index: number, product: any): number {
    return product.id; // ← بيقول Angular تـ track بالـ id مش الـ position
  }
}
```

> **ليه الـ `track` مهم؟** لما الـ list بتتغير، Angular بيعرف يحدّث العناصر المتغيّرة بس بدل ما يعيد رسم الـ list كلها من الأول. ده بيحسّن الـ Performance جداً.

**[⬆ Back to Top](#table-of-contents)**

---

### 32. إيه هو الـ `[ngClass]` و`[ngStyle]` وامتى بتستخدم أنهي فيهم؟

```typescript
@Component({
  selector: 'app-styling-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <!-- ① [ngClass] — لإضافة CSS Classes بشكل ديناميكي -->

    <!-- طريقة 1: Object — key = الـ class، value = condition -->
    <button [ngClass]="{
      'btn-primary': isPrimary,
      'btn-loading': isLoading,
      'btn-disabled': !isEnabled
    }">
      Click me
    </button>

    <!-- طريقة 2: Array of Classes -->
    <div [ngClass]="['card', 'shadow', isActive ? 'active' : 'inactive']">
      Dynamic classes
    </div>

    <!-- طريقة 3: String -->
    <div [ngClass]="currentTheme">Theme: {{ currentTheme }}</div>

    <!-- ─────────────────────────────────────────── -->
    <!-- ② [ngStyle] — لإضافة CSS Styles مباشرة -->

    <p [ngStyle]="{
      'color': textColor,
      'font-size': fontSize + 'px',
      'font-weight': isBold ? 'bold' : 'normal',
      'background-color': isHighlighted ? '#fffde7' : 'transparent'
    }">
      Styled paragraph
    </p>
  `
})
export class StylingDemoComponent {
  isPrimary = true;
  isLoading = false;
  isEnabled = true;
  isActive = true;
  currentTheme = 'dark-theme';
  textColor = 'dodgerblue';
  fontSize = 18;
  isBold = true;
  isHighlighted = true;
}
```

| | `[ngClass]` | `[ngStyle]` |
| - | ----------- | ----------- |
| **بيعمل إيه** | بيضيف/بيشيل CSS Classes | بيضيف Inline CSS |
| **الأفضل لـ** | التحكم في Classes معرّفة في الـ CSS | قيم ديناميكية بالكامل |
| **الـ Performance** | أحسن (الـ Browser cache الـ classes) | أبطأ نسبياً |

**[⬆ Back to Top](#table-of-contents)**

---

### 33. إيه هو الـ Pipe في Angular وإيه أشهر الـ Built-in Pipes؟

الـ Pipe بيحوّل شكل الـ Data في الـ Template من غير ما يغير الـ Data الأصلية. بتستخدمه بالـ `|` operator.

```html
<!-- Built-in Pipes — أمثلة شاملة -->

<!-- ① DatePipe — تنسيق التواريخ -->
<p>{{ today | date }}</p>                          <!-- Jan 15, 2025 -->
<p>{{ today | date:'dd/MM/yyyy' }}</p>             <!-- 15/01/2025 -->
<p>{{ today | date:'fullDate' }}</p>               <!-- Wednesday, January 15, 2025 -->
<p>{{ today | date:'shortTime' }}</p>              <!-- 3:45 PM -->

<!-- ② UpperCase / LowerCase / TitleCase -->
<p>{{ 'hello world' | uppercase }}</p>             <!-- HELLO WORLD -->
<p>{{ 'HELLO WORLD' | lowercase }}</p>             <!-- hello world -->
<p>{{ 'ahmed hassan' | titlecase }}</p>            <!-- Ahmed Hassan -->

<!-- ③ CurrencyPipe -->
<p>{{ 55000 | currency }}</p>                      <!-- $55,000.00 -->
<p>{{ 55000 | currency:'EGP':'symbol':'1.0-0' }}</p> <!-- EGP55,000 -->

<!-- ④ NumberPipe (DecimalPipe) -->
<p>{{ 1234567.89 | number }}</p>                   <!-- 1,234,567.89 -->
<p>{{ 95.456 | number:'1.0-2' }}</p>               <!-- 95.46 -->
<p>{{ 0.75 | percent }}</p>                        <!-- 75% -->
<p>{{ 0.756 | percent:'1.1-2' }}</p>               <!-- 75.60% -->

<!-- ⑤ SlicePipe — لقطع Arrays والـ Strings -->
<p>{{ 'Hello World' | slice:0:5 }}</p>             <!-- Hello -->
<ul>
  <li *ngFor="let item of items | slice:0:3">{{ item }}</li>
  <!-- بيعرض أول 3 عناصر بس -->
</ul>

<!-- ⑥ JsonPipe — للـ Debugging -->
<pre>{{ myObject | json }}</pre>

<!-- ⑦ AsyncPipe — للـ Observables والـ Promises (مهم جداً!) -->
<p>{{ user$ | async | json }}</p>
<div *ngIf="products$ | async as products">
  <p *ngFor="let p of products">{{ p.name }}</p>
</div>

<!-- ⑧ Chaining Pipes -->
<p>{{ today | date:'fullDate' | uppercase }}</p>
<!-- WEDNESDAY, JANUARY 15, 2025 -->
```

```typescript
@Component({
  selector: 'app-pipes-demo',
  standalone: true,
  imports: [CommonModule, DatePipe, CurrencyPipe, DecimalPipe],
  template: `...`
})
export class PipesDemoComponent {
  today = new Date();
  items = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
  myObject = { name: 'Ahmed', age: 25, role: 'Developer' };
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 34. إزاي بتعمل Custom Pipe بتاعك في Angular؟

```bash
# بالـ CLI
ng generate pipe pipes/truncate
ng g p pipes/truncate
```

```typescript
// truncate.pipe.ts — بيقطع النص لو طويل
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate',   // ← الاسم اللي هتستخدمه في الـ Template
  standalone: true,
  pure: true,         // ← Pure Pipe: بيتحسب بس لو الـ input اتغير (الـ default)
})
export class TruncatePipe implements PipeTransform {
  // transform بياخد الـ value وOptional parameters
  transform(value: string, maxLength: number = 100, suffix: string = '...'): string {
    if (!value) return '';
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength) + suffix;
  }
}

// search-filter.pipe.ts — بيفلتر List بناءً على search term
@Pipe({
  name: 'searchFilter',
  standalone: true,
  pure: false, // ← Impure: بيتحسب في كل Change Detection cycle
})
export class SearchFilterPipe implements PipeTransform {
  transform(items: any[], searchTerm: string, field: string = 'name'): any[] {
    if (!items || !searchTerm) return items;
    return items.filter(item =>
      item[field]?.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }
}
```

```html
<!-- استخدام الـ Custom Pipes -->
<p>{{ longText | truncate:50 }}</p>
<p>{{ longText | truncate:30:'— read more' }}</p>

<input [(ngModel)]="searchTerm" placeholder="Search..." />
<ul>
  <li *ngFor="let user of users | searchFilter:searchTerm:'name'">
    {{ user.name }}
  </li>
</ul>
```

**[⬆ Back to Top](#table-of-contents)**

---

## Section 5: Services & Dependency Injection

### 35. إيه هو الـ Service في Angular وليه بنستخدمه؟

الـ Service هو Class عادية بتحتوي على الـ Business Logic والـ Data اللي محتاج يتشارك بين أكتر من Component. الـ Components المفروض تكون مسؤولة عن الـ UI بس — كل حاجة تانية في الـ Service.

```typescript
// user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';

interface User {
  id: number;
  name: string;
  email: string;
}

@Injectable({
  providedIn: 'root', // ← Singleton: نسخة واحدة للـ App كلها
})
export class UserService {
  private apiUrl = 'https://jsonplaceholder.typicode.com/users';

  // BehaviorSubject للـ State Management البسيط
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {}

  // ① جلب كل المستخدمين
  getAllUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }

  // ② جلب مستخدم بالـ ID
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  // ③ إضافة مستخدم
  createUser(user: Partial<User>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }

  // ④ تحديث الـ State
  setCurrentUser(user: User | null): void {
    this.currentUserSubject.next(user);
  }
}
```

```typescript
// user-list.component.ts — بستخدم الـ Service
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngFor="let user of users">{{ user.name }}</div>
  `
})
export class UserListComponent implements OnInit {
  users: User[] = [];

  constructor(private userService: UserService) {} // ← Injection

  ngOnInit(): void {
    this.userService.getAllUsers().subscribe(users => {
      this.users = users;
    });
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 36. إيه هو الـ Dependency Injection ببساطة؟

الـ Dependency Injection (DI) هو نظام Angular بيوفّر للـ Components والـ Services اللي هما "محتاجينها" من غير ما يعملوا `new` بنفسهم.

تخيّل معايا إنك مستأجر شقة. محتاج كهرباء وميه. مش هتبني محطة كهرباء لنفسك — بتوصّل الشقة بالشبكة الموجودة وبتاخد الخدمة جاهزة. ده هو الـ DI.

```typescript
// ❌ بدون DI — أنت بتعمل كل حاجة بنفسك
class UserComponent {
  private userService: UserService;
  private httpClient: HttpClient;

  constructor() {
    // بتعمل كل شيء يدوياً — مشكلة!
    this.httpClient = new HttpClient(/* ... */);  // معقد جداً!
    this.userService = new UserService(this.httpClient);
    // لو الـ UserService اتغيرت، لازم تعدل هنا!
  }
}

// ✅ مع DI — Angular بيجيبلك اللي محتاجه
class UserComponent {
  // بتقوله إنت محتاج إيه في الـ constructor
  // Angular بيجيبلك الـ instance الجاهزة
  constructor(private userService: UserService) {
    // Angular عارف UserService محتاجة HttpClient
    // وعارف HttpClient محتاجة backend
    // بيجمع كل حاجة تلقائياً
  }
}
```

```
كيف DI بيشتغل:

UserComponent يحتاج UserService
        ↓
Angular Injector بيبص في الـ Registry
        ↓
هو عنده UserService instance؟
        ↓ نعم            ↓ لأ
بيديه الـ       بيعمل instance جديدة
existing one    وبيحطها في الـ Registry
        ↓
Component جاهز للاستخدام ✅
```

**[⬆ Back to Top](#table-of-contents)**

---

### 37. إيه هو الـ `@Injectable()` وإيه معنى `providedIn: 'root'`؟

الـ `@Injectable()` decorator بيقول لـ Angular: "الـ Class دي ممكن تتـ inject في حاجات تانية."

```typescript
// ① providedIn: 'root' — الأكثر استخداماً
@Injectable({
  providedIn: 'root' // ← Singleton: نسخة واحدة للـ App كلها
})
export class AuthService {
  isLoggedIn = false;
  // كل Component يحقنه هيشوف نفس الـ isLoggedIn value
}

// ② providedIn: 'any' — نسخة مختلفة لكل lazy-loaded module
@Injectable({
  providedIn: 'any'
})
export class FeatureService { /* ... */ }

// ③ provided في Module محدد
@NgModule({
  providers: [SpecialService] // ← متاح للـ Module ده بس
})
export class AdminModule { }

// ④ provided في Component — نسخة لكل Instance من الـ Component
@Component({
  selector: 'app-form',
  providers: [FormValidationService] // ← نسخة جديدة مع كل App-form
})
export class FormComponent { }
```

> **ليه `providedIn: 'root'` هو الأفضل في الغالب؟** لأنه بيـ enable الـ Tree Shaking — لو الـ Service مش بتستخدم، Angular CLI بيشيلها من الـ Bundle تلقائياً وبيقلل حجمه.

**[⬆ Back to Top](#table-of-contents)**

---

### 38. إيه الفرق بين الـ `providers` في الـ Component والـ Module؟

```typescript
// ─────────────────────────────────────────────
// ① في الـ Module providers — Module-level Scope
@NgModule({
  providers: [CounterService] // ← نسخة واحدة بين كل الـ Components في الـ Module
})
export class FeatureModule { }

// كل الـ Components في FeatureModule هتشوف نفس الـ instance
@Component({ selector: 'app-comp-a' })
class CompA {
  constructor(private counter: CounterService) {
    counter.count = 5; // ← هيأثر على CompB!
  }
}
@Component({ selector: 'app-comp-b' })
class CompB {
  constructor(private counter: CounterService) {
    console.log(counter.count); // ← 5 — نفس الـ instance!
  }
}

// ─────────────────────────────────────────────
// ② في الـ Component providers — Component-level Scope
@Component({
  selector: 'app-comp-a',
  providers: [CounterService] // ← نسخة جديدة لكل instance من CompA
})
class CompA {
  constructor(private counter: CounterService) {
    counter.count = 5; // ← مش هيأثر على CompB!
  }
}
@Component({
  selector: 'app-comp-b',
  providers: [CounterService] // ← نسخة جديدة تانية خالص
})
class CompB {
  constructor(private counter: CounterService) {
    console.log(counter.count); // ← 0 — نسخة مستقلة
  }
}
```

| | `providedIn: 'root'` | Module Providers | Component Providers |
| - | -------------------- | ---------------- | ------------------- |
| **الـ Scope** | الـ App كلها | الـ Module | الـ Component وChilds |
| **الـ Instances** | 1 Singleton | 1 لكل Module | 1 لكل Component Instance |
| **Tree Shaking** | ✅ | ❌ | ❌ |

**[⬆ Back to Top](#table-of-contents)**

---

### 39. إزاي بتعمل HTTP Calls بالـ `HttpClient` في Angular؟

```typescript
// ① الإعداد — في app.config.ts أو AppModule
// app.config.ts
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(), // ← لازم تضيفه الأول
  ]
};

// ─────────────────────────────────────────────
// ② الاستخدام في Service
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

interface Product {
  id: number;
  name: string;
  price: number;
}

@Injectable({ providedIn: 'root' })
export class ProductService {
  private apiUrl = 'https://api.example.com/products';

  constructor(private http: HttpClient) {}

  // GET — جلب كل المنتجات
  getProducts(): Observable<Product[]> {
    return this.http.get<Product[]>(this.apiUrl);
  }

  // GET مع Params
  searchProducts(keyword: string, page: number = 1): Observable<Product[]> {
    const params = new HttpParams()
      .set('search', keyword)
      .set('page', page.toString());
    return this.http.get<Product[]>(this.apiUrl, { params });
  }

  // POST — إضافة منتج
  createProduct(product: Partial<Product>): Observable<Product> {
    const headers = new HttpHeaders({ 'Content-Type': 'application/json' });
    return this.http.post<Product>(this.apiUrl, product, { headers });
  }

  // PUT — تحديث كامل
  updateProduct(id: number, product: Product): Observable<Product> {
    return this.http.put<Product>(`${this.apiUrl}/${id}`, product);
  }

  // PATCH — تحديث جزئي
  patchProduct(id: number, changes: Partial<Product>): Observable<Product> {
    return this.http.patch<Product>(`${this.apiUrl}/${id}`, changes);
  }

  // DELETE
  deleteProduct(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}

// ─────────────────────────────────────────────
// ③ الاستخدام في Component
@Component({
  selector: 'app-products',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngIf="isLoading">Loading...</div>
    <div *ngIf="error">Error: {{ error }}</div>
    <div *ngFor="let p of products">{{ p.name }} — {{ p.price }}</div>
  `
})
export class ProductsComponent implements OnInit, OnDestroy {
  products: Product[] = [];
  isLoading = false;
  error = '';
  private subscription = new Subscription();

  constructor(private productService: ProductService) {}

  ngOnInit(): void {
    this.isLoading = true;
    const sub = this.productService.getProducts().subscribe({
      next: (products) => {
        this.products = products;
        this.isLoading = false;
      },
      error: (err) => {
        this.error = err.message;
        this.isLoading = false;
      },
      complete: () => console.log('Done!')
    });
    this.subscription.add(sub);
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe(); // ← مهم جداً — منع Memory Leaks!
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

## Section 6: RxJS & Routing Basics

### 40. إيه هو الـ Observable وإيه الفرق بينه وبين الـ Promise؟

الـ Observable هو من الـ RxJS Library وهو "تيار من البيانات" ممكن يجيب قيمة أو أكتر على مدار الوقت. الـ Promise بيرجع قيمة واحدة بس.

تخيّل معايا: الـ Promise زي طلب طعام من مطعم — بيجيلك مرة واحدة، وبعدين خلص. الـ Observable زي الـ live streaming — بيكون فيه محتوى جديد كل الوقت، وتقدر توقّفه امتى ما تحب.

```typescript
import { Observable, of, from, interval } from 'rxjs';

// ─────────────────────────────────────────────
// Promise — مرة واحدة بس
const myPromise = new Promise<string>((resolve, reject) => {
  setTimeout(() => resolve('Data from API'), 1000);
});

myPromise.then(data => console.log(data)); // 'Data from API'
// مش تقدر توقفه! مش تقدر ترجع قيم كتيرة

// ─────────────────────────────────────────────
// Observable — قيم متعددة على مدار الوقت
const myObservable = new Observable<string>(observer => {
  observer.next('First value');   // ← قيمة 1
  observer.next('Second value');  // ← قيمة 2
  setTimeout(() => {
    observer.next('Third value'); // ← قيمة 3 (بعد ثانية)
    observer.complete();          // ← خلّص
  }, 1000);
});

// لازم تعمل subscribe عشان يبدأ يشتغل!
const subscription = myObservable.subscribe({
  next: (value) => console.log(value),
  error: (err) => console.error(err),
  complete: () => console.log('Done!')
});

// تقدر توقفه!
subscription.unsubscribe();

// ─────────────────────────────────────────────
// أشكال مختلفة للـ Observable
const fromArray$ = from([1, 2, 3, 4, 5]);  // من Array
const single$ = of('hello', 'world');        // من قيم مباشرة
const timer$ = interval(1000);              // كل ثانية بيبعت رقم
```

| | `Promise` | `Observable` |
| - | --------- | ------------ |
| **عدد القيم** | واحدة بس | صفر إلى ما لا نهاية |
| **الـ Cancel** | ❌ مستحيل | ✅ بـ unsubscribe() |
| **الـ Lazy** | ❌ بيبدأ فوراً | ✅ بيبدأ بس لما تـ subscribe |
| **الـ Operators** | محدودة (.then, .catch) | كتيرة جداً (RxJS) |
| **Angular** | نادر | الـ default |

**[⬆ Back to Top](#table-of-contents)**

---

### 41. إزاي بتستخدم الـ `subscribe()` وإيه المشاكل اللي ممكن تحصل؟

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription, fromEvent } from 'rxjs';
import { UserService } from './user.service';

@Component({
  selector: 'app-demo',
  standalone: true,
  template: `<p>{{ username }}</p>`
})
export class DemoComponent implements OnInit, OnDestroy {
  username = '';

  // ① طريقة 1: Subscription Object
  private subscription = new Subscription();

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    // subscribe() بياخد Object بـ 3 callbacks
    const sub = this.userService.getCurrentUser().subscribe({
      next: (user) => {         // ← لما يجي data
        this.username = user.name;
      },
      error: (err) => {         // ← لما يحصل error
        console.error('Error:', err);
      },
      complete: () => {         // ← لما الـ Observable يخلص
        console.log('Stream completed');
      }
    });

    this.subscription.add(sub); // ← بضيفه للـ Subscription

    // إضافة subscriptions أخرى
    const scrollSub = fromEvent(window, 'scroll').subscribe(() => {
      console.log('User scrolled');
    });
    this.subscription.add(scrollSub);
  }

  // ② ✅ مهم جداً — Cleanup في ngOnDestroy
  ngOnDestroy(): void {
    this.subscription.unsubscribe(); // ← بيوقف كل الـ subscriptions
    // لو مش عملتش ده هيحصل Memory Leak!
  }
}
```

```typescript
// ③ طريقة أحسن — Async Pipe (مش محتاج unsubscribe)
@Component({
  selector: 'app-better',
  standalone: true,
  imports: [CommonModule],
  template: `
    <!-- الـ Async Pipe بيعمل subscribe وunsubscribe تلقائياً -->
    <div *ngIf="users$ | async as users">
      <p *ngFor="let user of users">{{ user.name }}</p>
    </div>

    <p>{{ currentUser$ | async | json }}</p>
  `
})
export class BetterComponent implements OnInit {
  users$!: Observable<User[]>;
  currentUser$!: Observable<User>;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.users$ = this.userService.getAllUsers();
    this.currentUser$ = this.userService.getCurrentUser();
    // مش محتاج subscribe ولا unsubscribe! 🎉
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 42. إيه هي أشهر الـ RxJS Operators وإزاي بتستخدمها؟

الـ Operators هم "أدوات" بتعدّل أو بتفلتر الـ Observable stream. بتستخدمهم مع الـ `pipe()` method.

```typescript
import { of, from, interval, throwError } from 'rxjs';
import { map, filter, tap, take, catchError, switchMap, debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { HttpClient } from '@angular/common/http';

// ① map — بيحوّل كل value
of(1, 2, 3, 4, 5).pipe(
  map(n => n * 2)              // 2, 4, 6, 8, 10
).subscribe(console.log);

// في Real App — تحويل API response
this.http.get<any[]>('/api/users').pipe(
  map(users => users.map(u => ({ id: u.id, fullName: `${u.first} ${u.last}` })))
);

// ─────────────────────────────────────────────
// ② filter — بيفلتر القيم
of(1, 2, 3, 4, 5, 6).pipe(
  filter(n => n % 2 === 0)    // 2, 4, 6 — الأرقام الزوجية بس
).subscribe(console.log);

// ─────────────────────────────────────────────
// ③ tap — بيعمل side effect من غير ما يغير الـ stream
this.http.get('/api/products').pipe(
  tap(data => console.log('Data received:', data)), // ← للـ Debugging
  map(products => products.filter(p => p.inStock))
);

// ─────────────────────────────────────────────
// ④ take — بياخد عدد معين من القيم وبيخلص
interval(1000).pipe(
  take(5)                      // بياخد 5 قيم بس ثم complete
).subscribe(console.log);      // 0, 1, 2, 3, 4

// ─────────────────────────────────────────────
// ⑤ catchError — معالجة الـ Errors
this.http.get('/api/users').pipe(
  catchError(err => {
    console.error('API Error:', err);
    return of([]); // ← ترجع قيمة افتراضية بدل الـ Error
  })
);

// ─────────────────────────────────────────────
// ⑥ switchMap — لما تحتاج Observable جوا Observable (HTTP Call بعد event)
// الأهم: بيلغي الـ previous Observable لو جاء request جديد
this.searchInput.valueChanges.pipe(
  debounceTime(300),            // ← انتظر 300ms بعد آخر كلمة
  distinctUntilChanged(),       // ← لو نفس الـ value، ما تبعتش request
  switchMap(term =>             // ← ابعت API Request بالـ term الجديد
    this.http.get(`/api/search?q=${term}`)
  )
).subscribe(results => this.searchResults = results);
```

**[⬆ Back to Top](#table-of-contents)**

---

### 43. إيه هو الـ Subject في RxJS وإيه أنواعه؟

الـ Subject هو Observable و Observer في نفس الوقت — يعني تقدر تـ subscribe عليه وفي نفس الوقت تبعت قيم فيه. بيستخدم كتير في الـ Angular للـ State Management البسيط والتواصل بين الـ Components.

```typescript
import { Subject, BehaviorSubject, ReplaySubject, AsyncSubject } from 'rxjs';

// ─────────────────────────────────────────────
// ① Subject — بسيط، بيبعت القيمة للـ subscribers الحاليين بس
const subject = new Subject<string>();

subject.subscribe(v => console.log('Subscriber 1:', v));
subject.next('Hello');       // Subscriber 1: Hello

subject.subscribe(v => console.log('Subscriber 2:', v));
subject.next('World');       // Subscriber 1: World, Subscriber 2: World
// Subscriber 2 ما شافش "Hello" لأنه subscribe بعدها

// ─────────────────────────────────────────────
// ② BehaviorSubject — الأشهر في Angular!
// عنده initial value وبيدي كل subscriber آخر قيمة فوراً
const currentUser$ = new BehaviorSubject<string | null>(null); // initial value = null

currentUser$.subscribe(user => console.log('Observer 1:', user)); // null — فوراً

currentUser$.next('Ahmed');
// Observer 1: Ahmed

currentUser$.subscribe(user => console.log('Observer 2:', user)); // Ahmed — بياخد آخر قيمة
currentUser$.next('Sara');
// Observer 1: Sara, Observer 2: Sara

// الاستخدام الشهير في Auth Service
@Injectable({ providedIn: 'root' })
export class AuthService {
  private isLoggedIn$ = new BehaviorSubject<boolean>(false);

  get isAuthenticated$() {
    return this.isLoggedIn$.asObservable(); // ← بيمنع الـ external code من الـ next()
  }

  login(): void {
    this.isLoggedIn$.next(true);
  }

  logout(): void {
    this.isLoggedIn$.next(false);
  }
}

// ─────────────────────────────────────────────
// ③ ReplaySubject — بيحفظ عدد معين من القيم ويعيدها لكل subscriber جديد
const replay$ = new ReplaySubject<number>(3); // احفظ آخر 3 قيم

replay$.next(1);
replay$.next(2);
replay$.next(3);
replay$.next(4);

replay$.subscribe(v => console.log(v)); // 2, 3, 4 (آخر 3 بس)
```

**[⬆ Back to Top](#table-of-contents)**

---

### 44. إيه هو الـ Angular Router وإزاي بتضيف Routes للـ App؟

الـ Angular Router بيخليك تعمل Single Page Application بـ navigation بين "صفحات" من غير ما الـ page تعمل reload.

```typescript
// app.routes.ts — تعريف الـ Routes
import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { AboutComponent } from './pages/about/about.component';
import { UserListComponent } from './pages/users/user-list.component';
import { UserDetailComponent } from './pages/users/user-detail.component';
import { NotFoundComponent } from './pages/not-found/not-found.component';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  // ① Route بسيطة
  { path: '', component: HomeComponent },         // localhost:4200/
  { path: 'about', component: AboutComponent },   // localhost:4200/about

  // ② Route مع Parameter
  { path: 'users', component: UserListComponent },
  { path: 'users/:id', component: UserDetailComponent }, // :id = Dynamic Param

  // ③ Route مع Guard (حماية)
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [authGuard]
  },

  // ④ Lazy Loading — بيحمّل الـ Module بس لما المستخدم يروحله
  {
    path: 'admin',
    loadComponent: () =>
      import('./pages/admin/admin.component').then(m => m.AdminComponent),
  },

  // ⑤ Nested Routes — Routes جوا Routes
  {
    path: 'products',
    children: [
      { path: '', component: ProductListComponent },
      { path: ':id', component: ProductDetailComponent },
      { path: ':id/edit', component: ProductEditComponent },
    ]
  },

  // ⑥ Redirect
  { path: 'home', redirectTo: '', pathMatch: 'full' },

  // ⑦ Wildcard — لأي route مش موجودة
  { path: '**', component: NotFoundComponent },
];

// ─────────────────────────────────────────────
// app.config.ts — تفعيل الـ Router
import { provideRouter } from '@angular/router';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes)
  ]
};

// ─────────────────────────────────────────────
// app.component.html — لازم تحط <router-outlet>
```

```html
<!-- app.component.html -->
<nav>
  <a routerLink="/">Home</a>
  <a routerLink="/about">About</a>
  <a routerLink="/users">Users</a>
</nav>

<!-- هنا بيتعرض الـ Component المناسب للـ Route -->
<router-outlet></router-outlet>
```

**[⬆ Back to Top](#table-of-contents)**

---

### 45. إيه الفرق بين الـ `routerLink` والـ `router.navigate()`؟

```html
<!-- ① routerLink — بتستخدمه في الـ Template (HTML) -->

<!-- Static Route -->
<a routerLink="/about">About Us</a>

<!-- Dynamic Route -->
<a [routerLink]="['/users', userId]">View Profile</a>
<!-- بيعمل: /users/123 -->

<!-- مع Query Params -->
<a [routerLink]="['/products']" [queryParams]="{ category: 'electronics', page: 1 }">
  Electronics
</a>
<!-- بيعمل: /products?category=electronics&page=1 -->

<!-- routerLinkActive — بيضيف CSS class لما الـ Route تبقى active -->
<a routerLink="/home" routerLinkActive="active-link">Home</a>
<a routerLink="/about" routerLinkActive="active-link">About</a>
```

```typescript
// ② router.navigate() — بتستخدمه في الـ TypeScript Class
import { Router } from '@angular/router';

@Component({ /* ... */ })
export class LoginComponent {
  constructor(private router: Router) {}

  onLoginSuccess(): void {
    // Static Navigation
    this.router.navigate(['/dashboard']);

    // Dynamic Navigation مع Parameters
    this.router.navigate(['/users', 123]);
    // Result: /users/123

    // مع Query Params
    this.router.navigate(['/products'], {
      queryParams: { category: 'books', page: 1 }
    });
    // Result: /products?category=books&page=1

    // Relative Navigation
    this.router.navigate(['../sibling'], { relativeTo: this.activatedRoute });

    // مع Replace الـ History (مش هيرجع بالـ Back button)
    this.router.navigate(['/home'], { replaceUrl: true });
  }
}
```

| | `routerLink` | `router.navigate()` |
| - | ------------ | ------------------- |
| **مكان الاستخدام** | HTML Template | TypeScript Class |
| **متى تستخدم** | Buttons وLinks في الـ UI | بعد Event (login, submit) |

**[⬆ Back to Top](#table-of-contents)**

---

### 46. إزاي بتبعت وتجيب الـ Route Parameters في Angular؟

```typescript
// ① تعريف الـ Route مع Parameter
{ path: 'users/:id', component: UserDetailComponent }
{ path: 'products/:category/:id', component: ProductDetailComponent }

// ─────────────────────────────────────────────
// ② جلب الـ Parameter في الـ Component
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, ParamMap } from '@angular/router';
import { switchMap } from 'rxjs/operators';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-user-detail',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngIf="user">
      <h1>{{ user.name }}</h1>
      <p>{{ user.email }}</p>
    </div>
  `
})
export class UserDetailComponent implements OnInit {
  user: any = null;

  constructor(
    private route: ActivatedRoute,  // ← بيجيبلك معلومات الـ Route الحالية
    private userService: UserService
  ) {}

  ngOnInit(): void {
    // ① طريقة 1: Snapshot — بياخد القيمة مرة واحدة
    const id = this.route.snapshot.paramMap.get('id');
    // مشكلة: لو الـ route اتغير من users/1 لـ users/2، مش هيتحدث!

    // ② طريقة 2: Observable — بيتفاعل مع أي تغيير في الـ Route
    this.route.paramMap.pipe(
      switchMap((params: ParamMap) => {
        const userId = params.get('id')!;
        return this.userService.getUserById(+userId);
      })
    ).subscribe(user => {
      this.user = user;
    });

    // Query Params
    this.route.queryParamMap.subscribe(params => {
      const page = params.get('page') || '1';
      const category = params.get('category') || 'all';
      console.log('Page:', page, 'Category:', category);
    });
  }
}

// ─────────────────────────────────────────────
// ③ Navigation مع Parameters
@Component({ /* ... */ })
export class UserListComponent {
  constructor(private router: Router) {}

  viewUser(userId: number): void {
    this.router.navigate(['/users', userId]);
    // Result: /users/123
  }

  searchProducts(category: string): void {
    this.router.navigate(['/products'], {
      queryParams: { category, page: 1 }
    });
    // Result: /products?category=electronics&page=1
  }
}
```

**[⬆ Back to Top](#table-of-contents)**

---

### 47. إيه هو الـ Route Guard وإزاي بتحمي الـ Routes؟

الـ Route Guard بيمنع المستخدم من الدخول لـ Route معينة لو مش مستوفي شروط معينة — زي مثلاً لو مش Logged In.

```typescript
// ① الطريقة الحديثة — Functional Guard (Angular 14+)
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// auth.guard.ts
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true; // ← المستخدم عنده Permission — يدخل
  } else {
    // Redirect لصفحة الـ Login مع حفظ الـ URL اللي كان رايحله
    router.navigate(['/login'], {
      queryParams: { returnUrl: state.url }
    });
    return false; // ← منع الدخول
  }
};

// admin.guard.ts — Guard للـ Role
export const adminGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.hasRole('admin')) {
    return true;
  }
  router.navigate(['/unauthorized']);
  return false;
};

// ─────────────────────────────────────────────
// ② تطبيق الـ Guard على الـ Routes
export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [authGuard]        // ← لازم تكون logged in
  },
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [authGuard, adminGuard] // ← لازم تكون logged in + admin
  },
  {
    path: 'settings',
    component: SettingsComponent,
    canActivate: [authGuard],
    canDeactivate: [unsavedChangesGuard] // ← لما تحاول تمشي من صفحة فيها تغييرات
  }
];

// ─────────────────────────────────────────────
// ③ canDeactivate Guard — لما تحاول تخرج من صفحة فيها unsaved changes
export const unsavedChangesGuard: CanDeactivateFn<CanComponentDeactivate> = (component) => {
  if (component.hasUnsavedChanges()) {
    return confirm('عندك تغييرات لم تُحفظ. هل تريد المغادرة؟');
  }
  return true;
};
```

**[⬆ Back to Top](#table-of-contents)**

---

## 🗺️ خريطة Angular & TypeScript كاملة

```
Angular & TypeScript — Learning Map
┌─────────────────────────────────────────────────────────────┐
│ TypeScript                                                   │
│  ├── Types: string, number, boolean, any, unknown, never     │
│  ├── Interface & Type Alias                                  │
│  ├── Classes & Access Modifiers                              │
│  ├── Generics                                                │
│  └── Enums & Union/Intersection Types                        │
│                                                             │
│ Angular Core                                                 │
│  ├── NgModule vs Standalone                                  │
│  ├── Angular CLI                                             │
│  ├── AOT vs JIT                                              │
│  └── main.ts & app.config.ts                                 │
│                                                             │
│ Components                                                   │
│  ├── @Component Decorator                                    │
│  ├── Data Binding: Interpolation, Property, Event, Two-Way   │
│  ├── @Input() & @Output() + EventEmitter                     │
│  ├── Lifecycle Hooks: OnInit, OnDestroy, AfterViewInit       │
│  └── @ViewChild                                             │
│                                                             │
│ Directives & Pipes                                           │
│  ├── *ngIf / @if, *ngFor / @for                             │
│  ├── ngClass, ngStyle                                        │
│  ├── Built-in Pipes: date, currency, async                   │
│  └── Custom Pipes                                           │
│                                                             │
│ Services & DI                                               │
│  ├── @Injectable & providedIn: 'root'                        │
│  ├── Dependency Injection                                    │
│  └── HttpClient: GET, POST, PUT, DELETE                      │
│                                                             │
│ RxJS & Routing                                              │
│  ├── Observable vs Promise                                   │
│  ├── subscribe() & Async Pipe                                │
│  ├── Operators: map, filter, switchMap, debounceTime         │
│  ├── Subject & BehaviorSubject                               │
│  ├── Router & Routes Configuration                           │
│  ├── routerLink vs router.navigate()                         │
│  ├── Route Parameters & Query Params                         │
│  └── Route Guards: canActivate, canDeactivate                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🫒 زتونة الإنترفيو — الملخص الذهبي

> **"Angular هو Framework كامل مبني على TypeScript بيوفرلك كل حاجة من الأساس — Router، HTTP Client، Forms، وDependency Injection. الـ TypeScript بيحميك من الـ Bugs قبل ما تحصل عن طريق Static Typing. أي Angular App مبنية من Components — كل واحدة عندها Template للـ UI وClass للـ Logic. الـ Data بتتحرك في اتجاه واحد من الـ Parent للـ Child بالـ @Input()، ومن الـ Child للـ Parent بالـ @Output() مع EventEmitter. الـ Services بتحتوي على الـ Business Logic وبتتشارك بين الـ Components عن طريق الـ Dependency Injection اللي Angular بيديره بنفسه. الـ RxJS بيعملك bridge بين الـ Async world والـ UI — والـ Async Pipe هو أفضل طريقة للتعامل معاه لأنه بيعمل الـ subscribe والـ unsubscribe تلقائياً ومن غير memory leaks."**

---

*Next → Angular Reactive Forms, HTTP Interceptors, State Management with NgRx, Angular Signals, and Performance Optimization*
