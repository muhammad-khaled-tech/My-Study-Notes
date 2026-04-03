# الفصل العاشر — 30 سؤال إنترفيو: من Junior لـ Junior

> **الهدف:** ملف المراجعة النهائية. كل سؤال هنا إجابته مش حفظ — فهم. ماشي من الأساسيات لأسئلة السيناريوهات الحقيقية.

> **كيفية الاستخدام:** اقرأ السؤال، جاوب في دماغك أو على ورقة، بعدين اكشف الإجابة. لو الإجابة ناقصة — ارجع للفصل المذكور.

---

## 🔵 TypeScript — الأساس (الفصل الأول)

---

### السؤال 1 — إيه الفرق بين `interface` و `type` في TypeScript؟

**الإجابة:**

كلاهما بيعرّفوا شكل الـ data، بس فيه فروق جوهرية:

| | `interface` | `type` |
|---|---|---|
| مناسبة لـ | Object shapes | أي حاجة (unions، functions، primitives) |
| الوراثة | `extends` سهلة ومقروءة | ممكن بس بـ `&` (intersection) |
| Declaration merging | ✅ ممكن تعرّفها مرتين وبتتدمج | ❌ خطأ لو عرّفتها مرتين |
| Convention في Angular | الاختيار المفضّل للـ object shapes | للـ unions والـ aliases |

```typescript
// interface — للـ object shapes
interface Project {
  id: string;
  title: string;
  status: ProjectStatus; // uses type below
}

// type — للـ unions والـ literals
type ProjectStatus = 'open' | 'in-progress' | 'completed';
```

> 📖 المرجع: الفصل الأول — Interfaces & Union Types

---

### السؤال 2 — إيه الـ Generic وليه بنستخدمه؟

**الإجابة:**

الـ Generic هو **placeholder للنوع** — بيخليك تكتب كود مرة واحدة يشتغل مع أنواع مختلفة من غير تضحية بالـ type safety.

```typescript
// بدون generic — محتاج تكتب الـ interface 3 مرات
interface ProjectApiResponse  { ok: boolean; data: Project;   }
interface ProposalApiResponse { ok: boolean; data: Proposal;  }
interface UserApiResponse     { ok: boolean; data: User;      }

// مع generic — مرة واحدة بس
interface ApiResponse<T> {
  ok: boolean;
  data: T;
}

// استخدام
const res: ApiResponse<Project>  = { ok: true, data: project  };
const res: ApiResponse<Proposal> = { ok: true, data: proposal };
// TypeScript يعرف نوع data في كل حالة بالظبط ✅
```

> 📖 المرجع: الفصل الأول — Generics

---

### السؤال 3 — إيه الفرق بين `?.` و `!` في TypeScript؟

**الإجابة:**

- **`?.` (Optional Chaining)** — defensive: "لو القيمة موجودة كمّل، لو لا ارجع `undefined` بهدوء بدون crash."
- **`!` (Non-null Assertion)** — assertive: "أنا شخصياً أضمن إن القيمة دي مش `null`، ثق بيّا يا TypeScript."

```typescript
// ?. — آمن، بيحمي من الـ crash
const name = user?.profile?.firstName; // undefined لو user أو profile مش موجود

// ! — خطر لو غلطت، بيُسكت الـ error
const name = user!.profile!.firstName; // crash لو user فعلاً null

// في Angular — الاستخدام الشائع
@Component({...})
class MyComponent {
  private sub!: Subscription; // ! = "هتتعيّن في ngOnInit، مش في الـ constructor"
}
```

> 📖 المرجع: الفصل الأول — Optional Chaining

---

### السؤال 4 — إيه الـ Decorator وإيه اللي بيحصل لما بنكتب `@Component`؟

**الإجابة:**

الـ Decorator هو **function بتشتغل على الـ class** وبتضيف عليه metadata أو سلوك إضافي.

لما بتكتب `@Component({...})`:
1. Angular بتاخد الـ metadata (selector, template, styles)
2. بتسجّل الـ class ده في Angular's component registry
3. بتربط الـ selector بالـ HTML tag اللي هيشغّله

```typescript
@Component({
  selector: 'app-projects',    // ← الـ HTML tag بتاعه
  template: `<h1>Projects</h1>`,
  standalone: true,
})
export class ProjectsComponent {
  // من غير الـ @Component، Angular مش هتعرف إن الـ class ده component
  // هتعامله كـ plain TypeScript class
}
```

> 📖 المرجع: الفصل الأول — Decorators

---

## 🟠 Angular Architecture — اللبنات (الفصل الثاني والثاني ونص)

---

### السؤال 5 — إيه الفرق بين Standalone Component وـ NgModule؟

**الإجابة:**

- **NgModule (الطريقة القديمة):** كل component لازم يتسجّل في Module. الـ Module هو اللي بيعرف مين ييجي من مين.
- **Standalone Component (Angular 14+، الافتراضي في Angular 17+):** كل component مستقل بذاته، بيعلن الـ imports اللي محتاجها مباشرة من غير وسيط.

```typescript
// Standalone — الطريقة الحديثة والمفضّلة
@Component({
  selector: 'app-projects',
  standalone: true,             // ← مستقل
  imports: [CommonModule, RouterLink, ProjectCardComponent], // ← بيقول مين محتاجه هو
  template: `...`,
})
export class ProjectsComponent {}
```

في Angular 17+ كل الـ projects الجديدة standalone by default.

> 📖 المرجع: الفصل الثاني — Angular Architecture

---

### السؤال 6 — إيه الـ Dependency Injection وليه Angular بتستخدمه؟

**الإجابة:**

الـ Dependency Injection (DI) معناه: بدل ما الـ component ينشئ الـ services اللي محتاجها بنفسه، Angular بتديها له جاهزة.

```typescript
// بدون DI — الـ component بينشئ كل حاجة بنفسه
class ProjectsComponent {
  private service = new ProjectsService(new HttpClient(...)); // ❌ مربوط ومش قابل للـ testing
}

// مع DI — Angular بتدي الـ service جاهزة
class ProjectsComponent {
  private service = inject(ProjectsService); // ✅ Angular هتجيب نسخة جاهزة
}
```

**الفايدة:**
- نسخة واحدة بس من الـ service للـ app كلها (Singleton)
- سهل الـ testing — تقدر تحط fake service بدل الحقيقية
- فصل المسؤوليات: component بيعرف إنه يحتاج service، مش كيف ينشئها

> 📖 المرجع: الفصل الثاني والثاني ونص — DI

---

### السؤال 7 — إيه الـ Signal وعلاقته بـ Change Detection؟

**الإجابة:**

الـ Signal هو **reactive value** — لما قيمته بتتغيّر، كل اللي بيقرأه بيتحدّث تلقائياً.

```typescript
// بدون signal — Angular محتاج تفتيش كل الـ app لتعرف إيه اتغيّر
export class CounterComponent {
  count = 0; // plain property
  increment() { this.count++; } // Angular مش عارف متى يحدّث الـ view!
}

// مع signal — تحديد دقيق ومباشر
export class CounterComponent {
  count = signal(0); // signal
  increment() { this.count.update(v => v + 1); } // Angular يعرف بالظبط إيه اتغيّر

  // في الـ template: {{ count() }} — بيتقرأ كـ function call
}
```

الـ Signals جاءت تحل مشكلة إن Angular كانت بتعمل تفتيش لـ كل الـ components كل ما أي حاجة تتغيّر. مع Signals — التحديث دقيق وموضعي.

> 📖 المرجع: الفصل الثاني ونص — Signals

---

## 🟡 Template Syntax & Lifecycle (الفصل الثالث)

---

### السؤال 8 — إيه الـ lifecycle hooks الأساسية وامتى بنستخدم كل واحدة؟

**الإجابة:**

الـ lifecycle hooks هي methods بتتنفّذ في لحظات محددة من حياة الـ component:

```typescript
@Component({...})
export class ProjectsComponent implements OnInit, OnDestroy {

  ngOnInit(): void {
    // ✅ الاستخدام الأشهر:
    // - جلب data من الـ API
    // - الاشتراك في Observables
    // - تهيئة initial state
    this.loadProjects();
  }

  ngOnDestroy(): void {
    // ✅ تنظيف الـ subscriptions والـ timers قبل ما الـ component يُحذف
    // لو ما عملتش ده — memory leak!
    this.projectsSub.unsubscribe();
  }

  // ngOnChanges — بيشتغل لما @Input يتغيّر
  // ngAfterViewInit — بعد ما الـ view يتبني (للـ DOM manipulation)
  // ngOnChanges → ngOnInit → ngAfterViewInit → (changes) → ngOnDestroy
}
```

> 📖 المرجع: الفصل الثالث — Lifecycle

---

### السؤال 9 — إيه الفرق بين `*ngIf` (أو `@if`) و `[hidden]`؟

**الإجابة:**

| | `@if` / `*ngIf` | `[hidden]` |
|---|---|---|
| اللي بيحصل | بيشيل الـ element من الـ DOM كاملاً | بيخلي الـ element موجود لكن `display: none` |
| الـ lifecycle | ngOnInit وngOnDestroy بيشتغلوا | الـ component موجود دايماً في الـ memory |
| الـ performance | أحسن لو المحتوى مش ضروري يكون موجود | أحسن لو محتاج تخبّي وتظهر سريع بدون re-render |
| متى تستخدم | للشرط الأساسي (login/logout) | للـ toggle السريع المتكرر |

```html
<!-- @if — الـ element بيختفي من الـ DOM كاملاً -->
@if (isLoggedIn) {
  <app-dashboard />
}

<!-- [hidden] — موجود في الـ DOM بس مش ظاهر -->
<app-dashboard [hidden]="!isLoggedIn" />
```

> 📖 المرجع: الفصل الثالث — Template Syntax

---

### السؤال 10 — إيه الفرق بين Property Binding وـ Event Binding وـ Two-way Binding؟

**الإجابة:**

```html
<!-- Property Binding [prop] — بيبعت data من الـ component للـ template -->
<img [src]="user.avatar" />
<button [disabled]="isLoading">Save</button>

<!-- Event Binding (event) — بيسمع events من الـ template ويتصرف -->
<button (click)="onSave()">Save</button>
<input (input)="onSearch($event)" />

<!-- Two-way Binding [(ngModel)] — الاتنين مع بعض -->
<input [(ngModel)]="username" />
<!-- معناه: [ngModel]="username" + (ngModelChange)="username = $event" -->
<!-- التغيير في الـ input بيحدّث الـ variable، والـ variable بيحدّث الـ input -->
```

Two-way binding محتاج `FormsModule` — أو استخدم Reactive Forms (الأحسن).

> 📖 المرجع: الفصل الثالث — Template Syntax

---

## 🟢 RxJS — التيار (الفصل الرابع)

---

### السؤال 11 — إيه الـ Observable وإزاي بتختلف عن الـ Promise؟

**الإجابة:**

| | `Promise` | `Observable` |
|---|---|---|
| القيم | قيمة واحدة بس | قيم متعددة على مدار الوقت |
| التوقيت | بيشتغل فوراً لما يتنشأ | **lazy** — ما بيشتغلش إلا لما حد يعمل `subscribe` |
| الإلغاء | ❌ مش ممكن | ✅ ممكن بـ `unsubscribe()` |
| الـ operators | محدودة (then/catch) | مئات الـ operators (map, filter, debounce...) |
| مناسب لـ | HTTP request بسيط | Search input, WebSockets, أي stream مستمر |

```typescript
// Promise — بيشتغل فوراً، قيمة واحدة
const p = fetch('/api/projects'); // بيبدأ فوراً حتى لو ما حدش ينتظر النتيجة!

// Observable — lazy، قيم متعددة
const obs$ = this.http.get('/api/projects');
// ما بعتش request بعد! لازم:
obs$.subscribe(data => console.log(data)); // دلوقتي بيبعت الـ request
```

> 📖 المرجع: الفصل الرابع — RxJS

---

### السؤال 12 — إيه الفرق بين `map` و `switchMap` و `mergeMap`؟

**الإجابة:**

```typescript
// map — بيحوّل قيمة لقيمة تانية (مش Observable)
projects$.pipe(
  map(projects => projects.filter(p => p.status === 'open'))
  // بياخد Array ويرجع Array مفلتر
)

// switchMap — بيحوّل قيمة لـ Observable جديدة، ويلغي القديمة
searchTerm$.pipe(
  switchMap(term => this.api.search(term))
  // لو المستخدم كتب حاجة جديدة وهو لسه مستنّي نتيجة القديمة
  // switchMap يلغي الـ request القديمة ويبعت الجديدة فقط
  // ← مثالي للـ search
)

// mergeMap — بيحوّل لـ Observable ويخلّي كل الـ streams تشتغل مع بعض
clicks$.pipe(
  mergeMap(click => this.api.logClick(click))
  // كل click يبعت request مستقلة، كلهم شغّالين مع بعض
  // ← مثالي لو الترتيب مش مهم
)
```

> 📖 المرجع: الفصل الرابع — Higher-order Operators

---

### السؤال 13 — إيه الفرق بين `Subject` و `BehaviorSubject`؟

**الإجابة:**

كلاهما Observable وـ Observer في نفس الوقت — يعني تقدر تبعت ليها قيم وتستقبلها.

| | `Subject` | `BehaviorSubject` |
|---|---|---|
| الـ initial value | ❌ مفيش | ✅ لازم تديه قيمة أولية |
| لو اشتركت بعد emit | ❌ ما تجبش القيمة السابقة | ✅ بتجيب آخر قيمة اتبعتت فوراً |
| مناسب لـ | Events زي click | State زي currentUser |

```typescript
// BehaviorSubject — الأشهر في Angular services
private currentUser$ = new BehaviorSubject<User | null>(null);

// Component يشترك — يجيب القيمة الحالية فوراً حتى لو ما فيش حاجة جديدة
this.authService.currentUser$.subscribe(user => this.user = user);

// Login — كل المشتركين بيتحدّثوا
this.currentUser$.next(loggedInUser);
```

> 📖 المرجع: الفصل الرابع — Subjects

---

### السؤال 14 — ليه بنعمل `unsubscribe` وإيه البدائل؟

**الإجابة:**

لو ما عملتش `unsubscribe`، الـ Observable فاضل يبعت قيم حتى بعد ما الـ component يتحذف من الـ DOM — ده memory leak بيبطّئ التطبيق.

```typescript
// الطريقة التقليدية
private sub!: Subscription;

ngOnInit() {
  this.sub = this.service.getProjects().subscribe(...);
}

ngOnDestroy() {
  this.sub.unsubscribe(); // ✅ مهم جداً
}

// البديل الأنيق — takeUntilDestroyed (Angular 16+)
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

ngOnInit() {
  this.service.getProjects()
    .pipe(takeUntilDestroyed(this.destroyRef)) // تلقائياً بيعمل unsubscribe عند destroy
    .subscribe(...);
}

// البديل الـ template — async pipe
// بيعمل subscribe وunsubscribe تلقائياً
// {{ projects$ | async }}
```

> 📖 المرجع: الفصل الرابع — Memory Management

---

## 🔴 Services, HTTP, Interceptors, Guards (الفصل الخامس)

---

### السؤال 15 — إيه الـ `providedIn: 'root'` وإيه معناها؟

**الإجابة:**

```typescript
@Injectable({
  providedIn: 'root' // ← ده اللي بيعمل الـ service singleton
})
export class ProjectsService {}
```

`providedIn: 'root'` معناها:
- Angular بتنشئ **نسخة واحدة بس** من الـ service للـ app كلها
- أي component يـ`inject` الـ service ده بياخد نفس النسخة
- لو محدش بيستخدمها — Angular مش هتضمّها في الـ bundle (Tree-shakeable)

لو محتاج كل component ينشئ نسخته الخاصة — استخدم `providers: [MyService]` جوا الـ `@Component`.

> 📖 المرجع: الفصل الخامس — Services

---

### السؤال 16 — إيه الـ HTTP Interceptor وامتى بنستخدمه؟

**الإجابة:**

الـ Interceptor هو **middleware** بيشتغل على كل HTTP request وresponse. زي حارس على الباب بيفحص كل حاجة بتيجي وبتروح.

**أشهر استخدامات:**

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('token');

  // 1. إضافة الـ Authorization header لكل request
  const authReq = token
    ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
    : req;

  return next(authReq).pipe(
    // 2. معالجة الـ errors بشكل مركزي
    catchError(error => {
      if (error.status === 401) {
        // Token انتهى — logout تلقائي
        inject(AuthService).logout();
      }
      return throwError(() => error);
    })
  );
};
```

**تسجيل الـ Interceptor في `app.config.ts`:**
```typescript
provideHttpClient(withInterceptors([authInterceptor]))
```

> 📖 المرجع: الفصل الخامس — Interceptors

---

### السؤال 17 — إيه الـ Route Guard وإيه أنواعه؟

**الإجابة:**

الـ Guard هو **حارس أمام الـ Route** — بيقرر تسمح بالدخول أو لأ.

```typescript
// canActivate — هل المستخدم يقدر يدخل على الـ route ده؟
export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isLoggedIn()) {
    return true; // ✅ تفضّل
  }

  router.navigate(['/login']); // ❌ ارجع على الـ login
  return false;
};

// canDeactivate — هل المستخدم يقدر يغادر الـ route؟
// استخدام: لما يحاول يغادر form فيها تعديلات غير محفوظة
export const unsavedChangesGuard: CanDeactivateFn<any> = (component) => {
  return component.hasUnsavedChanges
    ? confirm('في تغييرات غير محفوظة. متأكد تغادر؟')
    : true;
};

// canMatch / canActivateChild — لحماية lazy-loaded routes
```

> 📖 المرجع: الفصل الخامس — Guards

---

## 🟣 Reactive Forms (الفصل السادس)

---

### السؤال 18 — إيه الفرق بين Template-Driven Forms وـ Reactive Forms؟

**الإجابة:**

| | Template-Driven | Reactive Forms |
|---|---|---|
| أين الـ logic؟ | في الـ HTML | في الـ TypeScript |
| الـ validation | HTML attributes | Functions في الـ TS |
| الـ Testing | صعب | سهل — كود TS عادي |
| Dynamic forms | صعب | سهل جداً |
| Scale | مناسب للـ forms البسيطة | مناسب للـ production |
| Angular recommendation | غير مفضّلة | المفضّلة |

```typescript
// Reactive — كل الـ logic في TypeScript
loginForm = new FormGroup({
  email:    new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required, Validators.minLength(6)]),
});

onSubmit() {
  if (this.loginForm.valid) {
    this.auth.login(this.loginForm.value);
  }
}
```

> 📖 المرجع: الفصل السادس — Reactive Forms

---

### السؤال 19 — إيه الـ `FormBuilder` وليه بنستخدمه؟

**الإجابة:**

الـ `FormBuilder` هو helper service بيخلّي الكود أقصر وأوضح. النتيجة نفس بالظبط — بس بدون الـ `new FormGroup(new FormControl(...))` المتكررة.

```typescript
// بدون FormBuilder — كتير ومتكرر
form = new FormGroup({
  title:       new FormControl('', Validators.required),
  description: new FormControl('', Validators.required),
  budget:      new FormControl(0,  [Validators.required, Validators.min(1)]),
});

// مع FormBuilder — أنظف
private fb = inject(FormBuilder);

form = this.fb.group({
  title:       ['', Validators.required],
  description: ['', Validators.required],
  budget:      [0,  [Validators.required, Validators.min(1)]],
});
// النتيجة متطابقة تماماً — بس الكود أقصر ومقروء أكتر
```

> 📖 المرجع: الفصل السادس — FormBuilder

---

### السؤال 20 — إزاي بتعمل Custom Validator في Reactive Forms؟

**الإجابة:**

```typescript
// Custom Validator — function بترجع null لو valid، أو object لو invalid
function egyptianPhoneValidator(control: AbstractControl): ValidationErrors | null {
  const phone = control.value as string;

  if (!phone) return null; // لو فاضي — مش مسؤولية الـ validator ده (Validators.required شغلته)

  const isValid = /^(\+20|0)?1[0125]\d{8}$/.test(phone);

  return isValid ? null : { egyptianPhone: true };
  //                          ↑ اسم الـ error — بيتشاف في: form.get('phone').errors?.egyptianPhone
}

// الاستخدام
form = this.fb.group({
  phone: ['', [Validators.required, egyptianPhoneValidator]],
});

// في الـ template
@if (form.get('phone')?.errors?.['egyptianPhone']) {
  <p>رقم الهاتف المصري لازم يبدأ بـ 010, 011, 012, 015</p>
}
```

> 📖 المرجع: الفصل السادس — Custom Validators

---

## 🔵 Component Communication (الفصل السابع)

---

### السؤال 21 — إيه طرق التواصل بين الـ Components؟

**الإجابة:**

```
طرق التواصل:

1. @Input / @Output — بين Parent وـ Child
   Parent → Child: [data]="value"      (@Input)
   Child → Parent: (event)="handler()" (@Output + EventEmitter)

2. Service + BehaviorSubject — بين أي Components
   ComponentA → Service.subject.next(value) → ComponentB.subject.subscribe(...)

3. Signals — الطريقة الحديثة (Angular 16+)
   signal() / computed() / effect()

4. @ViewChild / @ContentChild — الـ Parent يوصل لـ Child مباشرة
```

```typescript
// @Input و@Output
// في Child
@Input() project!: Project;
@Output() projectSelected = new EventEmitter<Project>();

onSelect() {
  this.projectSelected.emit(this.project);
}

// في Parent
<app-project-card
  [project]="currentProject"
  (projectSelected)="handleSelection($event)"
/>
```

> 📖 المرجع: الفصل السابع — Component Communication

---

### السؤال 22 — إيه الفرق بين `@ViewChild` و `@ContentChild`؟

**الإجابة:**

- **`@ViewChild`** — الـ parent يوصل لـ element أو component **في الـ template بتاعه هو**
- **`@ContentChild`** — الـ parent يوصل لمحتوى **بيتحقن من بره** (بين opening وclosing tags)

```typescript
// @ViewChild — للـ template الخاص بالـ component
@Component({
  template: `<input #emailInput />`
})
class LoginComponent {
  @ViewChild('emailInput') input!: ElementRef;

  ngAfterViewInit() {
    this.input.nativeElement.focus(); // بيفوكس على الـ input بعد ما الـ view تتبني
  }
}

// @ContentChild — للمحتوى المحقون من بره
@Component({
  selector: 'app-card',
  template: `<div class="card"><ng-content /></div>`
})
class CardComponent {
  @ContentChild('cardHeader') header!: ElementRef;
}

// الاستخدام
<app-card>
  <h2 #cardHeader>Project Title</h2> <!-- ده اللي بيتحقن -->
</app-card>
```

> 📖 المرجع: الفصل السابع — ViewChild & ContentChild

---

## 🟠 Routing Deep (الفصل الثامن)

---

### السؤال 23 — إيه الـ Lazy Loading وليه بنستخدمه؟

**الإجابة:**

الـ Lazy Loading معناه: بدل ما تحمّل كل الـ app في أول request، كل feature بيتحمّل بس لما المستخدم يطلبه.

```typescript
// routes بدون lazy loading — كل حاجة بتتحمّل في البداية
{ path: 'projects', component: ProjectsComponent }  // ❌ جزء من الـ initial bundle

// routes مع lazy loading — بيتحمّل بس لما المستخدم يروح /projects
{
  path: 'projects',
  loadComponent: () =>
    import('./pages/projects/projects.component')
      .then(m => m.ProjectsComponent)              // ✅ chunk منفصل
}
```

**الفايدة:** الـ initial bundle بيبقى أصغر بكتير — التطبيق بيفتح أسرع.

**لما ييجي في الإنترفيو:** "Lazy Loading improves initial load performance by splitting the app into chunks. Only the required chunk is downloaded when the user navigates to that route."

> 📖 المرجع: الفصل الثامن — Lazy Loading

---

### السؤال 24 — إيه الفرق بين `snapshot.params` و `paramMap` كـ Observable؟

**الإجابة:**

```typescript
// snapshot.params — قيمة لحظية
// بتستخدمه لما مش متوقع الـ param يتغيّر وهو في نفس الـ component
ngOnInit() {
  const id = this.route.snapshot.params['id']; // string ثابتة
}

// paramMap كـ Observable — بتستخدمه لما الـ param ممكن يتغيّر
// مثال: صفحة profile بتتنقل بين users بدون reloading الـ component
ngOnInit() {
  this.route.paramMap.subscribe(params => {
    const id = params.get('id');
    this.loadProject(id); // بيشتغل كل ما الـ id يتغيّر في الـ URL
  });
}
```

> 📖 المرجع: الفصل الثامن — ActivatedRoute

---

### السؤال 25 — إيه الـ Resolver وامتى بنستخدمه؟

**الإجابة:**

الـ Resolver هو **pre-fetcher** — بيجيب الـ data قبل ما الـ component يظهر. المستخدم ما يشوفش loading spinner — الصفحة بتظهر وهي فيها data جاهزة.

```typescript
// resolver
export const projectResolver: ResolveFn<Project> = (route) => {
  const id = route.params['id'];
  return inject(ProjectsService).getProject(id); // Observable — Angular بيستنّى لحد ما يكمل
};

// في الـ routes
{
  path: 'projects/:id',
  component: ProjectDetailComponent,
  resolve: { project: projectResolver } // ← Angular بيحمّل الـ data الأول
}

// في الـ component — الـ data موجودة فوراً
ngOnInit() {
  this.project = this.route.snapshot.data['project']; // جاهزة بدون subscribe
}
```

**المقارنة:** Resolver مناسب لو الـ page مش محتاجة تظهر بدون data. لو الـ loading state مقبول — اعمل الـ HTTP call في الـ ngOnInit عادي.

> 📖 المرجع: الفصل الثامن — Resolvers

---

## 🟤 Custom Directives & Pipes (الفصل التاسع)

---

### السؤال 26 — إيه الفرق بين Structural Directive وـ Attribute Directive؟

**الإجابة:**

| | Structural Directive | Attribute Directive |
|---|---|---|
| علامة مميزة | `*` قبلها (أو `@` في الـ control flow الجديد) | من غير `*` |
| اللي بتعمله | بتغيّر هيكل الـ DOM (تضيف أو تشيل elements) | بتغيّر مظهر أو سلوك element موجود |
| أمثلة | `*ngFor`، `@if`، `@for` | `ngClass`، `ngStyle`، Custom highlight directive |

```typescript
// Attribute Directive مثال
@Directive({
  selector: '[appHighlight]',
  standalone: true,
})
export class HighlightDirective {
  private el = inject(ElementRef);

  @Input() appHighlight = 'yellow';

  @HostListener('mouseenter') onMouseEnter() {
    this.el.nativeElement.style.backgroundColor = this.appHighlight;
  }

  @HostListener('mouseleave') onMouseLeave() {
    this.el.nativeElement.style.backgroundColor = '';
  }
}

// الاستخدام
<p appHighlight="lightblue">Hover me!</p>
```

> 📖 المرجع: الفصل التاسع — Directives

---

### السؤال 27 — إيه الـ Pipe وإزاي بتعمل Custom Pipe؟

**الإجابة:**

الـ Pipe هو **transformer في الـ template** — بياخد قيمة وبيرجّعها بشكل تاني.

```typescript
// Custom Pipe
@Pipe({
  name: 'truncate',
  standalone: true,
  pure: true, // ← هنشرحه في السؤال الجاي
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit = 100, trail = '...'): string {
    return value.length > limit
      ? value.substring(0, limit) + trail
      : value;
  }
}

// الاستخدام في الـ template
{{ project.description | truncate:50:'...' }}
// لو الوصف أطول من 50 حرف بيتاخد أول 50 حرف وبيتضاف '...'
```

> 📖 المرجع: الفصل التاسع — Pipes

---

### السؤال 28 — إيه الفرق بين Pure Pipe وـ Impure Pipe؟

**الإجابة:**

| | Pure Pipe (`pure: true`) | Impure Pipe (`pure: false`) |
|---|---|---|
| بيشتغل امتى؟ | بس لما الـ input value نفسه يتغيّر (reference change) | كل مرة Change Detection بتشتغل |
| الـ performance | ✅ سريع — Angular بتعمل cache للنتيجة | ❌ بطيء — بيتحسب كل مرة |
| متى تستخدمه؟ | 99% من الحالات | لو الـ pipe بتعتمد على side effects أو mutable data |

```typescript
// Pure (الافتراضي) — بياخد array ويرجع مفلتر
@Pipe({ name: 'filterByStatus', pure: true }) // ← الافتراضي
export class FilterPipe implements PipeTransform {
  transform(projects: Project[], status: string): Project[] {
    return projects.filter(p => p.status === status);
  }
}

// تحذير مهم: لو بتعمل push() في الـ array من غير ما تعمل array جديدة
// الـ pure pipe ما هتشوف التغيير لأن الـ reference مش اتغيّر!
// الحل: this.projects = [...this.projects, newProject]; // reference جديدة
```

> 📖 المرجع: الفصل التاسع — Pure vs Impure Pipes

---

## 🎯 أسئلة السيناريوهات — الجزء اللي بيفرق

---

### السؤال 29 — سيناريو: Search بـ Debounce

**السؤال في الإنترفيو:** عندك search bar — المستخدم بيكتب، وعايز تبعت request للـ API. ازاي تعمل ده من غير ما تبعت request لكل حرف؟

**الإجابة:**

```typescript
@Component({...})
export class SearchComponent {
  private projectsService = inject(ProjectsService);
  searchControl = new FormControl('');
  results$!: Observable<Project[]>;

  ngOnInit() {
    this.results$ = this.searchControl.valueChanges.pipe(
      debounceTime(400),       // استنّى 400ms بعد آخر حرف
      distinctUntilChanged(),  // لو نفس القيمة — ما بعتش
      filter(term => term !== null && term.length >= 2), // ما تبعتش لو أقل من 2 حروف
      switchMap(term =>
        this.projectsService.search(term) // لو المستخدم كتب تاني — ألغي القديمة وابعت جديدة
      )
    );
  }
}
```

```html
<input [formControl]="searchControl" placeholder="ابحث..." />

@for (project of results$ | async; track project.id) {
  <app-project-card [project]="project" />
}
```

> 📖 المرجع: الفصل الرابع — debounceTime, switchMap

---

### السؤال 30 — سيناريو: Authentication Flow كامل

**السؤال في الإنترفيو:** وصّف كيف تبني نظام authentication في Angular — من Login لحد ما الـ user يكون protected على كل الـ pages.

**الإجابة:**

```
الصورة الكاملة:

1. AuthService — يحتفظ بـ state الـ user (BehaviorSubject)
         ↓
2. Login Component — Reactive Form + يستدعي AuthService.login()
         ↓
3. AuthService.login() — HTTP call للـ backend
         ↓
4. Backend يرجع JWT token
         ↓
5. AuthService يحفظ الـ token في localStorage + يحدّث الـ BehaviorSubject
         ↓
6. HTTP Interceptor — بيضيف الـ token تلقائياً لكل request
         ↓
7. Route Guard (canActivate) — بيتحقق من AuthService.isLoggedIn() قبل كل route
         ↓
8. لو الـ token انتهى (401 response) — الـ Interceptor يـlogout ويروح login
```

```typescript
// AuthService
@Injectable({ providedIn: 'root' })
export class AuthService {
  private currentUser$ = new BehaviorSubject<User | null>(null);
  isLoggedIn = computed(() => !!this.currentUser$.value); // أو signal

  login(creds: LoginCredentials): Observable<void> {
    return this.http.post<AuthResponse>('/api/auth/login', creds).pipe(
      tap(res => {
        localStorage.setItem('token', res.token);
        this.currentUser$.next(res.user);
      }),
      map(() => void 0)
    );
  }

  logout() {
    localStorage.removeItem('token');
    this.currentUser$.next(null);
    this.router.navigate(['/login']);
  }
}

// authGuard
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isLoggedIn() ? true : router.createUrlTree(['/login']);
};

// authInterceptor
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('token');
  const authReq = token
    ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
    : req;

  return next(authReq).pipe(
    catchError(err => {
      if (err.status === 401) inject(AuthService).logout();
      return throwError(() => err);
    })
  );
};
```

> 📖 المرجع: الفصل الخامس — Services + Interceptors + Guards

---

## 📋 الملخص السريع — أهم النقاط

```
TypeScript
├── Interface = object blueprint (compile-time only)
├── Generic<T> = reusable type placeholder
├── ?. = safe navigation  |  ! = trust me it's not null
└── @Decorator = metadata for Angular's registry

Angular Core
├── Component = UI unit (template + logic + styles)
├── Signal = reactive value with precise change detection
├── DI = Angular injects services, you don't create them
└── Standalone = no NgModule needed (Angular 17+)

RxJS
├── Observable = lazy async stream (≠ Promise)
├── switchMap = cancel old, start new (search, navigation)
├── BehaviorSubject = stateful Observable (auth, cart)
└── unsubscribe = prevent memory leaks (or use async pipe)

HTTP Layer
├── Service = data logic goes here, NOT in component
├── Interceptor = middleware for all requests (token, errors)
└── Guard = protect routes (canActivate, canDeactivate)

Forms
├── Reactive Forms = logic in TS, testable, scalable
├── FormBuilder = shorthand for FormGroup/FormControl
└── Custom Validator = function → null (valid) | object (error)

Routing
├── Lazy loading = split app into chunks = faster initial load
├── paramMap$ = Observable (for params that change)
├── Resolver = pre-fetch data before component renders
└── canDeactivate = prevent leaving unsaved forms

Directives & Pipes
├── Structural = changes DOM structure (*ngFor, @if)
├── Attribute = changes element appearance/behavior
├── Pure Pipe = cached, fast (use 99% of the time)
└── Impure Pipe = recalculates every cycle (avoid unless needed)
```

---

## 🫒 زتونة الإنترفيو الشاملة

> **"Angular is a complete platform: TypeScript gives you type safety, Components give you UI encapsulation, Services + DI give you shared logic without coupling, RxJS gives you reactive async streams, Interceptors give you centralized HTTP control, and the Router gives you navigation with lazy loading for performance. Understanding why each piece exists — not just how to use it — is what separates a junior who memorized the API from one who can architect a real application."**

---

*عقبال ما تشتغل في أحسن شركة Angular في مصر وفي العالم.* 🚀
