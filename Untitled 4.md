### 🔴 JS Internals — الحاجات الناقصة

**Memory Model العميق** — الملفات بتتكلم عن الـ Heap والـ Stack بس مش بتشرح بالظبط إيه اللي بيروح فين. المتعلم محتاج يعرف إن Primitives بتروح Stack، Objects بتروح Heap، والـ Reference بتروح Stack. وإيه الـ Stack Frame بالظبط وإيه الـ Heap Segment.

**V8 Hidden Classes & Inline Caching** — ده غائب تماماً وهو سؤال senior خطير. لما بتضيف properties لـ Object بترتيب مختلف، V8 بيعمل Hidden Class جديدة وبيـdeoptimize الكود. ده بيفسر ليه `{x:1, y:2}` أسرع من نفس الـ Object لو ضفت `x` الأول وبعدين `y`.

**Garbage Collection Algorithms** — Mark & Sweep وإزاي بيتعمل، الـ Generational GC (Young Generation/Old Generation)، وإزاي الـ Minor GC والـ Major GC بيشتغلوا. الملفات بتذكر GC بس مش بتشرح الـ algorithm.

**WeakRef & FinalizationRegistry** — ES2021 features مش موجودة خالص، وهم مهمين لفهم الـ Memory Management العملي.

**Symbol deep dive** — الـ Well-known Symbols (`Symbol.iterator`, `Symbol.toPrimitive`, `Symbol.hasInstance`) وإزاي بتبني Protocols عليهم.

---

### 🟡 JS Functional Programming — الحاجات الناقصة

**Compose vs Pipe** — الملفات بتذكر HOF بس مش بتشرح الـ function composition pattern بالشكل الصح. إزاي بتبني `compose(f, g, h)(x)` وإيه الفرق بين right-to-left (compose) وleft-to-right (pipe).

**Memoization deep dive** — مش مجرد caching، هو فهم إمتى Memoization بتكون anti-pattern (lو الـ function غير pure)، وإزاي تبني generic memoize function.

**Transducers** — ده advanced FP بس مهم جداً للـ performance. إزاي تعمل `map().filter().reduce()` في pass واحد من غير intermediate arrays.

**Railway-Oriented Programming** — الـ Either/Result Monad للـ error handling من غير exceptions. ده pattern بيتسأل عنه في functional-leaning companies.

**Lazy Evaluation & Infinite Sequences** — باستخدام Generators عشان تبني infinite lists وتـevaluate بس الـ values اللي محتاجها.

**Point-Free Style** — إزاي تكتب functions من غير ما تذكر arguments صراحة. بيفتح باب لكتابة كود أكثر composability.

---

### 🟢 Backend/Node.js — الحاجات الناقصة (للـ Junior/Mid-level)

**HTTP Module Deep Dive** — الـ req/res objects من جوا، Status Codes philosophy، Headers management، Content Negotiation، Keep-Alive connections. ده الـ foundation قبل Express.

**Express.js Architecture** — الـ Middleware Pipeline كـ pattern، إزاي بتبني Error Handling Middleware (الـ 4 parameters trick)، الـ Router كـ Mini-App، والـ Request Lifecycle من app.use لحد res.send.

**Authentication & Authorization** — JWT anatomy (Header.Payload.Signature)، Signing vs Encryption، Token Storage (الـ XSS vs CSRF tradeoff)، Refresh Token pattern، وSession-based vs Token-based.

**Database Patterns in Node.js** — Connection Pooling (ليه ومتى)، الـ Repository Pattern، N+1 Query problem وإزاي تحله، Transactions في async context.

**Centralized Error Handling** — Custom Error Classes (extending Error)، Operational vs Programmer Errors، الـ uncaughtException و unhandledRejection handlers، وإزاي تبني error middleware في Express.

**Validation Patterns** — Schema validation (Joi/Zod)، Input sanitization vs validation، والـ difference بين validation في الـ Controller vs الـ Service layer.

**Testing in Node.js** — Unit vs Integration vs E2E، مفهوم الـ Test Double (Mock, Stub, Spy, Fake)، Testing async code، وsupertest للـ API testing.

**Security Essentials** — CORS من جوا (مش بس npm install cors)، Rate Limiting، Helmet وليه كل header بتحطه مهم، SQL Injection vs NoSQL Injection، والـ OWASP Top 10 المبسط.

**Clustering & Horizontal Scaling** — الـ cluster module، PM2 كـ Process Manager، إزاي بتتعامل مع Shared State في clustered environment، والـ Sticky Sessions problem.

**Graceful Shutdown** — إزاي تعمل shutdown صح في Node.js سيرفر (الـ SIGTERM handler، إزاي توقف قبول requests جديدة وتخلي الموجودة تخلص).