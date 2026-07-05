---
tags: [react, django, git, python, css, oop, solid, database, interview-prep]
covers: "أسئلة إنترفيو React/Django الحقيقية اللي جت لمحمد عبدالحق + Giza Add-ons + أسئلة إضافية متوقعة (موجتين) بنفس ستايل المحاور"
---

# 🆘 أغيثونا — إجابات إنترفيو React | Django

> [!info] 📖 عن الملف ده
> دي الأسئلة اللي جت فعلياً في إنترفيو React/Django (محمد عبدالحق مع يوسف حسين) + إضافات جيزة، مجمّعة بالترتيب الموضوعي عشان تراجعها بسهولة. كل سؤال إجابته مختصرة ومركزة على الجوهر اللي هيتقال في الإنترفيو.

---

## 🎨 الجزء الأول: HTML & CSS

### 1. إيه الـ Semantic Tags؟
هي عناصر HTML بتوصف **معنى** المحتوى مش بس شكله، زي `<header>`, `<nav>`, `<article>`, `<section>`, `<footer>` بدل ما تلف كل حاجة بـ `<div>`. الفايدة: تحسين الـ SEO، سهولة الوصول (Accessibility) لبرامج قراءة الشاشة، وكود أسهل في القراءة والصيانة.

### 2. Flex vs Grid
| | Flexbox | Grid |
|---|---|---|
| البُعد | Layout في بُعد واحد (صف أو عمود) | Layout في بُعدين (صفوف وأعمدة مع بعض) |
| الاستخدام الأمثل | ترتيب عناصر داخل Container زي navbar | تصميم صفحة كاملة (layout عام) |
| التحكم | بيتحكم في العناصر نسبة لبعضها | بيتحكم في شبكة كاملة محددة مسبقاً |

> [!tip] قاعدة سريعة: لو بتصمم سطر أو عمود واحد استخدم Flex، لو بتصمم شبكة كاملة (صفوف + أعمدة) استخدم Grid.

### 3. Px vs Rem vs Em
- **px**: وحدة ثابتة (Absolute) مبتتأثرش بأي حاجة تانية.
- **em**: نسبية لحجم الخط بتاع **العنصر الأب المباشر** — لو الأب اتغيّر، القيمة بتتغيّر معاه (ممكن يعمل تراكم Compounding في التعشيش العميق).
- **rem** (Root em): نسبية لحجم الخط بتاع **عنصر الـ `html` الجذري** بس، مهما كان مكان العنصر — ده بيخليها أسهل في التحكم والتناسق عبر الصفحة كلها، ولذلك بتكون الأفضل في المشاريع الكبيرة.

### 4. أنهي أسرع أداءً: Inline Styles ولا `<style>` Tag ولا External CSS؟
الترتيب من ناحية الأداء العام: **External CSS File** هي الأفضل عملياً لأن المتصفح بيعمل لها **Cache** فمتتحملش تاني في كل صفحة، وبتفصل الـ Concerns. الـ `<style>` tag جوا الصفحة أسرع في أول تحميل لصفحة واحدة بس مبيتعملهاش Cache. الـ **Inline Styles** أبطأ حل من ناحية الصيانة والأداء الكلي لأنها بتتكرر مع كل عنصر وبتمنع الـ Browser من تطبيق تحسينات الـ CSSOM بكفاءة، وبتكسر مبدأ الـ Separation of Concerns.

### 5. إيه هدف الـ `alt` Attribute؟
بيوفر **نص بديل** للصورة يتقرأ لو الصورة معملتش Load، أو لبرامج قراءة الشاشة لذوي الإعاقة البصرية (Accessibility)، وبيساهم في الـ SEO لأن محركات البحث بتقرأ النص ده لفهم محتوى الصورة.

---

## 🧱 الجزء الثاني: OOP

### 6. Composition vs Aggregation vs Association vs Inheritance
| العلاقة | الوصف | مثال |
|---|---|---|
| **Association** | علاقة عامة بين كلاسين مستقلين عن بعض تماماً | `Teacher` و`Student` |
| **Aggregation** | علاقة "has-a" لكن الطرفين ممكن يعيشوا لوحدهم (الـ Child مش تابع لـ lifetime الـ Parent) | `Department` و`Employee` — الموظف موجود حتى لو القسم اتلغى |
| **Composition** | علاقة "has-a" قوية، الـ Child **مش ممكن يعيش من غير** الـ Parent (Strong ownership) | `House` و`Room` — الأوضة بتتمسح لو البيت اتهد |
| **Inheritance** | علاقة "is-a" — الابن نوع من الأب وبياخد صفاته وسلوكه | `Dog` يرث من `Animal` |

### 7. Class vs Instance
الـ **Class** هي الـ blueprint أو القالب اللي بيوصف الخصائص والسلوكيات. الـ **Instance (Object)** هي النسخة الفعلية اللي اتعملها في الميموري باستخدام الـ Class ده، وكل Instance ليها قيمها الخاصة.

### 8. الأربع أعمدة بتاعت OOP (4 Pillars)
1. **Encapsulation**: تغليف البيانات وحمايتها من التعديل المباشر، والوصول ليها عن طريق methods محددة.
2. **Abstraction**: إخفاء التفاصيل المعقدة وإظهار الواجهة (Interface) البسيطة بس.
3. **Inheritance**: إعادة استخدام كود كلاس موجود عن طريق كلاس تاني يورث منه.
4. **Polymorphism**: نفس الاسم (method) بيتصرف بشكل مختلف حسب الكلاس اللي بينده.

### 9. Overloading vs Overriding
- **Overloading**: نفس اسم الدالة لكن بعدد/نوع Parameters مختلف، بيتحدد وقت الـ Compile (Compile-Time Polymorphism).
- **Overriding**: الابن بيعيد تعريف method موجودة في الأب بنفس الـ Signature، بيتحدد وقت الـ Runtime (Runtime Polymorphism).

### 10. أنواع الـ Inheritance
- **Single**: كلاس واحد يورث من كلاس واحد.
- **Multilevel**: سلسلة وراثة (A → B → C).
- **Hierarchical**: أكتر من كلاس بيورثوا من نفس الأب.
- **Multiple**: كلاس بيورث من أكتر من أب في نفس الوقت (مسموحة في C++، ممنوعة بين Classes في Java/Python بشكل مباشر لكن ممكنة عن طريق الـ Interfaces أو Mixins).
- **Hybrid**: خليط من أكتر من نوع من اللي فوق.

---

## 🏗️ الجزء الثالث: SOLID & Design

### 11. SOLID (شرح كل مبدأ)
- **S — Single Responsibility Principle**: كل Class لازم يكون له سبب واحد بس للتغيير (مسؤولية واحدة).
- **O — Open/Closed Principle**: الكود لازم يكون مفتوح للتوسعة، مقفول للتعديل — تضيف سلوك جديد من غير ما تلمس الكود القديم.
- **L — Liskov Substitution Principle**: أي كلاس ابن لازم يقدر يحل محل الأب من غير ما يكسر البرنامج.
- **I — Interface Segregation Principle**: متجبرش Class يعتمد على Methods مش محتاجها — قسّم الـ Interfaces الكبيرة لأصغر.
- **D — Dependency Inversion Principle**: اعتمد على Abstractions (Interfaces) مش على Concrete Classes مباشرة.

### 12. Dependency Inversion vs Dependency Injection
- **Dependency Inversion Principle (DIP)**: مبدأ تصميمي بيقول "الكلاسات عالية المستوى ميعتمدوش على كلاسات منخفضة المستوى، الاتنين يعتمدوا على Abstraction".
- **Dependency Injection (DI)**: **التقنية** اللي بتحقق المبدأ ده عملياً، عن طريق تمرير الـ Dependencies (عادة عن طريق الـ Constructor) بدل ما الكلاس ينشئها بنفسه جواه.

> [!tip] DIP هو "الفكرة"، DI هي "الأداة" اللي بتنفذها.

### 13. Singleton Pattern + استخداماته
Pattern بيضمن إن الكلاس ليه **Instance واحدة بس** طول عمر التطبيق، وبيوفر نقطة وصول عامة (Global Access Point) ليها. استخداماته الشائعة: **Database Connection Pool**، **Logger**، **Configuration Manager** — أي حاجة محتاج تتشارك فيها حالة واحدة عبر التطبيق كله من غير ما تتكرر.

---

## 🧩 الجزء الرابع: JavaScript & React

### 14. Filter vs Map vs Reduce
- **map()**: بتحول كل عنصر في المصفوفة لحاجة تانية، وبترجع مصفوفة جديدة **بنفس الطول**.
- **filter()**: بترجع مصفوفة جديدة فيها بس العناصر اللي حققت شرط معين (طولها أقل أو يساوي الأصلية).
- **reduce()**: بتجمع كل عناصر المصفوفة في **قيمة واحدة** (رقم، Object، مصفوفة تانية) عن طريق تراكم النتيجة عنصر بعد التاني.

### 15. Local Storage vs Session Storage vs Cookies
| | Local Storage | Session Storage | Cookies |
|---|---|---|---|
| العمر | يفضل موجود حتى بعد قفل المتصفح | بينتهي بمجرد قفل الـ Tab | حسب `expires`، ممكن يتحدد |
| الحجم | ~5-10MB | ~5-10MB | ~4KB بس |
| بيتبعت للسيرفر؟ | لأ | لأ | أيوه مع كل Request تلقائياً |
| الاستخدام الشائع | تخزين تفضيلات المستخدم | بيانات مؤقتة لجلسة الـ Tab | Authentication وTracking |

### 16. useMemo vs useCallback vs React.memo
- **`useMemo`**: بيعمل Cache لـ **قيمة (نتيجة حساب)** عشان ميتحسبش تاني كل Render إلا لو الـ Dependencies اتغيرت.
- **`useCallback`**: بيعمل Cache لـ **الـ Function نفسها** (الـ Reference بتاعتها) عشان متتعملش من الأول كل Render.
- **`React.memo`**: بيلف الـ Component نفسه ويمنعه من عمل Re-render لو الـ Props بتاعته متغيرتش.

> [!tip] الثلاثة أدوات هدفها واحد: منع إعادة حساب أو إعادة رسم حاجات مش محتاجة تتغيّر.

### 17. useState vs useRef
- **`useState`**: لما تغيّر القيمة بتعمل **Re-render** للـ Component، ومناسب لأي حاجة لازم تتعرض في الـ UI.
- **`useRef`**: بيحتفظ بقيمة بين الـ Renders **من غير ما يعمل Re-render**، ومناسب للوصول لـ DOM Element أو تخزين قيمة مش لازم تظهر في الـ UI.

---

## 🔐 الجزء الخامس: Auth, Tokens & Hashing

### 18. Token vs JWT
الـ **Token** مصطلح عام لأي string بيمثل هوية أو صلاحية (ممكن يكون Random string بيتخزن في الـ Database ويتراجع منها). الـ **JWT (JSON Web Token)** نوع خاص من الـ Tokens له تنسيق محدد (3 أجزاء) وبيحمل بيانات جواه (Self-Contained) فمحتاجش رجوع للـ Database عشان تتحقق منه.

### 19. مميزات وعيوب الـ JWT
- **المميزات**: Stateless (السيرفر مش محتاج يخزن حالة الجلسة)، سهل الاستخدام بين خدمات مختلفة (Microservices)، بيحمل بيانات جواه توفر Database lookup.
- **العيوب**: صعوبة الـ Revocation (إلغاؤه قبل انتهاء صلاحيته) لأنه مش متخزن في مكان مركزي، لو الحجم كبير بياخد Bandwidth أكتر، ولو الـ Secret Key اتسرب أي حد يقدر يزور Tokens.

### 20. محتويات الـ JWT
3 أجزاء متفصلة بنقطة (`.`):
1. **Header**: نوع الـ Token والـ Algorithm المستخدم.
2. **Payload**: البيانات نفسها (Claims) زي الـ User ID والصلاحيات.
3. **Signature**: توقيع مشفر بالـ Secret Key للتأكد إن الـ Token مش اتغيّر.

### 21. هل الـ Payload ممكن يتفك (Decode)؟
**أيوه**، الـ Payload بيتعمله **Encode بس مش Encryption** (عادة بصيغة Base64Url)، يعني أي حد يقدر يفك تشفيره ويقرا محتواه بسهولة. اللي بيحمي الـ Token من التزوير هو الـ **Signature** بس، مش إخفاء المحتوى. عشان كده متحطش بيانات حساسة (زي باسورد) جوا الـ Payload.

### 22. Access Token vs Refresh Token
- **Access Token**: عمره قصير، بيتبعت مع كل Request عشان يثبت هوية المستخدم.
- **Refresh Token**: عمره أطول، بيتخزن بأمان أكتر، ووظيفته الوحيدة إنه يطلب Access Token جديد لما القديم ينتهي، من غير ما المستخدم يعمل Login تاني.

### 23. استخدام أكتر من Access Token
مثال: مستخدم مسجل دخول من أكتر من جهاز (موبايل + لابتوب) في نفس الوقت، كل جهاز بياخد Access Token منفصل، عشان لو جهاز واحد اتسرق أو الـ Token بتاعه اتلغى، الأجهزة التانية تفضل شغالة عادي.

### 24. Hash vs Encryption
- **Hashing**: عملية **باتجاه واحد (One-Way)** ومينفعش ترجع للنص الأصلي منها. بتستخدم للباسوردات.
- **Encryption**: عملية **قابلة للعكس (Two-Way)** باستخدام مفتاح، تقدر تفك التشفير وترجع للنص الأصلي. بتستخدم للبيانات اللي محتاج تقرأها تاني زي رسايل مشفرة.

### 25. أنواع طرق الـ Hashing
- **MD5**: قديمة وغير آمنة دلوقتي (Collision-prone).
- **SHA-1/SHA-256**: أقوى من MD5 لكن مش مصممة أصلاً للباسوردات (سريعة جداً وده عيب هنا).
- **bcrypt**: مصممة خصيصاً للباسوردات، بطيئة عمداً ومعاها Salt مدمج، وده بيصعّب هجمات Brute-Force.
- **Argon2**: الأحدث والأقوى حالياً، فايز في مسابقة Password Hashing Competition.

---

## 🌿 الجزء السادس: Git

### 26. Revert vs Reset
- **`git revert`**: بيعمل commit **جديد** بيعكس تأثير commit قديم، من غير ما يمسح الـ History. آمن على الـ Branches المشتركة.
- **`git reset`**: بيرجع الـ HEAD لـ commit سابق ويمسح الـ History بعده (حسب النوع: `--soft`, `--mixed`, `--hard`). خطر لو استخدمته على Branch الناس بتسحب منه.

### 27. Branch مش موجود Locally — الحل؟
تستخدم `git fetch` عشان تجيب كل الـ Branches والـ Commits الجديدة من الـ Remote من غير ما تدمجها مع شغلك الحالي، وبعدها تعمل `git checkout branch_name` أو `git switch branch_name` عشان Git يعمل تلقائياً branch محلي بيتابع نفس الـ Remote branch.

### 28. Fetch vs Pull
- **`git fetch`**: بيجيب آخر تحديثات من الـ Remote **من غير** ما يدمجها مع شغلك الحالي — بس بيحدّث الـ Remote-tracking branches.
- **`git pull`**: بيعمل `fetch` وبعدها `merge` (أو `rebase` لو مضبوط كده) تلقائياً مع الـ Branch الحالي بتاعك.

### 29. Git Stash + استخدامه
`git stash` بيحفظ التغييرات الغير محفوظة (Uncommitted) بتاعتك في مكان مؤقت ويرجّع الـ Working Directory نضيف، من غير ما تعمل commit ليها. **استخدام عملي**: إنت شغال على Feature ولسه مخلصتش، وفجأة محتاج تعمل `checkout` لـ branch تاني بسرعة عشان hotfix عاجل — تعمل `git stash`، تحل المشكلة، وترجع تاني وتعمل `git stash pop` تكمل شغلك من نفس النقطة.

### 30. Rebase vs Merge
- **Merge**: بيعمل commit جديد (Merge Commit) بأبوين، بيحافظ على الـ History الحقيقي لكن بيخلي شكله متشعب (non-linear).
- **Rebase**: بياخد الـ commits بتاعتك ويعيد "لصقهم" فوق آخر نقطة في الـ branch التاني، فبيطلع الـ History **خطي (linear)** ونضيف، لكنه بيعيد كتابة الـ History الفعلي.

> [!warning] متعملش Rebase لـ branch الناس التانية بتسحب منه — استخدمه بس على شغلك الشخصي قبل الـ Push.

### 31. إزاي تحل الـ Merge Conflicts؟
1. Git بيوقف عملية الـ merge/rebase ويعلّم الملفات المتعارضة بعلامات `<<<<<<<`, `=======`, `>>>>>>>`.
2. تفتح الملف، تشوف الاختلافين، وتقرر تسيب أنهي جزء (أو تدمج الاتنين يدوياً).
3. تشيل علامات الـ conflict.
4. تعمل `git add` للملف بعد التعديل.
5. تكمل بـ `git commit` (في حالة merge) أو `git rebase --continue` (في حالة rebase).

---

## 🗄️ الجزء السابع: Database

### 32. Aggregate Function vs Window Function
- **Aggregate Function** (زي `SUM`, `COUNT`, `AVG`): بتجمع مجموعة صفوف في **صف واحد** بالنتيجة (بتقلل عدد الصفوف، خصوصاً مع `GROUP BY`).
- **Window Function** (زي `RANK() OVER()`, `ROW_NUMBER()`): بتعمل نفس الحسابات التجميعية لكن **من غير ما تقلل عدد الصفوف** — كل صف بيفضل موجود ومعاه نتيجة الحساب بتاعته بالنسبة لمجموعة (Window) معينة.

### 33. استراتيجيات تحسين أداء API بطيء (High-Latency)
- عمل **Caching** (Redis) للـ Responses المتكررة.
- **Pagination** بدل إرجاع كل البيانات مرة واحدة.
- تقليل عدد الـ Database Queries (حل مشكلة N+1، استخدام Eager Loading).
- إضافة **Indexes** مناسبة على الأعمدة المستخدمة في البحث.
- استخدام **Asynchronous Processing** (Queues) للعمليات اللي مش لازم تحصل فوراً.
- ضغط الـ Response (Compression) وتقليل حجم البيانات المرسلة (Select الأعمدة المطلوبة بس).
- استخدام **CDN** للمحتوى الثابت، و**Load Balancing** لتوزيع الحمل.

### 34. Normalization vs Denormalization
- **Normalization**: تقسيم البيانات لجداول متعددة لتقليل التكرار ومنع الـ Anomalies، بيحسّن سلامة البيانات لكن بيزود عدد الـ Joins المطلوبة.
- **Denormalization**: دمج بيانات من جداول متعددة في جدول واحد عمداً لتسريع القراءة (Read) على حساب التكرار.
- **استخدام Normalization**: أنظمة فيها كتابة كتير ولازم دقة عالية (بنوك).
- **استخدام Denormalization**: أنظمة فيها قراءة كتير وبطء الـ Joins بيأثر على الأداء (Reporting/Analytics/Data Warehouses).

### 35. حلول لزيادة سرعة استرجاع البيانات من الـ DB (أكتر من إجابة)
1. **Indexing** على الأعمدة المستخدمة في `WHERE`/`JOIN`/`ORDER BY`.
2. **Caching** (Redis/Memcached) للنتائج المتكررة.
3. **Denormalization** لو القراءة أهم من التكرار.
4. **Query Optimization** (تجنب `SELECT *`، استخدام `EXPLAIN` لتحليل الأداء).
5. **Partitioning/Sharding** للجداول الضخمة.
6. **Read Replicas** لتوزيع حمل القراءة عن السيرفر الأساسي.

### 36. مميزات وعيوب الـ Indexing + متى تستخدمه
- **المميزات**: بيسرّع عمليات البحث (`SELECT`) بشكل كبير جداً بدل الـ Full Table Scan.
- **العيوب**: بيبطئ عمليات الكتابة (`INSERT`/`UPDATE`/`DELETE`) لأن الـ Index لازم يتحدّث كل مرة، وبياخد مساحة تخزين إضافية.
- **استخدامه الأمثل**: أعمدة بتتقرأ كتير وبتتغير قليل، زي `email` أو `user_id` في جدول ضخم.

### 37. Primary Index vs Clustered Index vs Non-Clustered Index
- **Primary Index**: الـ Index المرتبط بالـ Primary Key بشكل طبيعي.
- **Clustered Index**: بيرتب **الجدول نفسه فعلياً** على القرص حسب قيمة العمود ده — بيبقى ليك Clustered Index واحد بس لكل جدول (غالباً على الـ Primary Key).
- **Non-Clustered Index**: بنية منفصلة بتشاور على مكان الصف الحقيقي في الجدول، وممكن يكون ليك أكتر من واحد منها على أعمدة مختلفة.

### 38. Data Warehousing
نظام مركزي بيجمع بيانات من مصادر متعددة (Databases مختلفة، APIs، ملفات) ويخزنها بشكل **محسّن للتحليل (Analytics)** مش للعمليات اليومية (OLAP مقابل OLTP). بيستخدم عادة بيانات Denormalized ومصمم للـ Reporting والـ Business Intelligence على مدى زمني طويل.

### 39. أسباب وحلول مشكلة الـ N+1
**السبب**: لما تعمل query يجيب قايمة (1 query)، وبعدين تلف على كل عنصر فيها وتعمل query تاني لجيب بياناتها المرتبطة (N queries)، فبتاخد N+1 query بدل query أو اتنين بس.
**الحل**: استخدام **Eager Loading** — في Django عن طريق `select_related()` أو `prefetch_related()`، في Eloquent عن طريق `with()` — عشان تجيب كل البيانات المرتبطة بـ Query واحد إضافي بدل واحد لكل عنصر.

### 40. Select_related vs Prefetch_related (Django) + العلاقات المناسبة لكل واحد
- **`select_related()`**: بيستخدم **SQL JOIN** واحد، ومناسب للعلاقات اللي بترجع Object واحد بس (`ForeignKey`، `OneToOneField`).
- **`prefetch_related()`**: بيعمل **Query منفصل** تاني ويربط النتايج في الـ Python نفسه، ومناسب للعلاقات اللي بترجع أكتر من Object (`ManyToManyField`، `ForeignKey` عكسية زي Reverse FK).

### 41. Like vs ILIKE
- **`LIKE`**: بحث نصي **Case-Sensitive** (بيفرق بين الحروف الكبيرة والصغيرة) في أغلب قواعد البيانات.
- **`ILIKE`**: نفس الفكرة لكن **Case-Insensitive** (متاحة في PostgreSQL تحديداً)، يعني `'Hello'` و`'hello'` بيتطابقوا.

---

## 🐍 الجزء الثامن: Django & Python Backend

### 42. Request Lifecycle في Django (Forward & Backward) + شرح الملفات
**رحلة الـ Request (Forward):**
1. الـ Request بتوصل لـ **WSGI/ASGI Server** (زي Gunicorn/Uvicorn).
2. بتمر على **Middleware** (بالترتيب المكتوب في `settings.py`).
3. بتوصل لـ **`urls.py`** اللي بيدور على الـ Pattern المطابق ويحدد أنهي View هيشتغل.
4. الـ **View** بينفذ منطق العمل، ممكن يستخدم **Serializers** و**Models**.
5. الـ View بيرجع **Response**.

**رحلة الرجوع (Backward):** الـ Response بترجع تاني عكس نفس المسار عبر الـ Middleware (بترتيب عكسي) قبل ما توصل للمستخدم.

- **`settings.py`**: ملف الإعدادات المركزي (Database، Installed Apps، Middleware، Static Files، إلخ).
- **`urls.py`**: خريطة الـ Routing اللي بتربط كل URL Pattern بالـ View المسؤول عنه.

### 43. الـ Serialization بالتفصيل (Input/Output)
الـ **Serialization** هي تحويل بيانات معقدة (زي Model Instances) لصيغة سهلة النقل زي JSON، والـ **Deserialization** هي العملية العكسية (تحويل JSON المُستلم لـ Python objects/Model instances بعد الـ Validation).
- **Output Serialization**: لما الـ API بيرجع بيانات للمستخدم (Model → JSON).
- **Input (De)serialization**: لما الـ API بيستقبل بيانات من المستخدم (JSON → Python data)، وبيتحقق من صحتها (Validation) قبل ما يحفظها في الـ Database.

### 44. أنواع الـ Views في Django
- **Function-Based Views (FBV)**: دالة بسيطة بتستقبل `request` وترجع `response`.
- **Class-Based Views (CBV)**: كلاس بيغلف منطق الـ View، بيدعم إعادة الاستخدام والوراثة (زي `ListView`, `DetailView`).
- **Generic Views**: CBVs جاهزة لعمليات شائعة (CRUD) بأقل كود ممكن.

### 45. الدالة القابلة للاستدعاء `.as_view()`
الـ Class-Based View نفسها **مش قابلة للاستدعاء مباشرة** كـ View function عادية في الـ `urls.py`. الميثود `.as_view()` بترجع دالة (Function) فعلية Django يقدر ينده عليها زي أي View عادي، وهي اللي بتتولى إنشاء Instance من الكلاس ونداء الـ Method المناسبة (`get`, `post`, إلخ) حسب نوع الـ Request.

### 46. ASGI vs WSGI
- **WSGI (Web Server Gateway Interface)**: الـ Standard التقليدي، **Synchronous** بس — بيتعامل مع Request واحد في كل مرة لكل Worker.
- **ASGI (Asynchronous Server Gateway Interface)**: الأحدث، بيدعم **Asynchronous** processing، الـ WebSockets، والـ HTTP/2، وبيسمح بالتعامل مع اتصالات متزامنة كتير بكفاءة أعلى.

---

## 🐍 الجزء التاسع: Python Core

### 47. Immutable vs Mutable
- **Mutable**: نوع بيانات ممكن تتغيّر قيمته بعد الإنشاء من غير ما يتغيّر الـ Object نفسه في الذاكرة (زي `list`, `dict`, `set`).
- **Immutable**: نوع بيانات مينفعش تتغيّر قيمته بعد الإنشاء، أي "تعديل" فعلياً بيعمل Object جديد (زي `int`, `str`, `tuple`, `float`).

### 48. أنواع البيانات في بايثون (Python Datatypes)
- **Numeric**: `int`, `float`, `complex`
- **Sequence**: `str`, `list`, `tuple`
- **Mapping**: `dict`
- **Set Types**: `set`, `frozenset`
- **Boolean**: `bool`
- **Binary**: `bytes`, `bytearray`
- **None Type**: `NoneType`

### 49. List vs Tuple
| | List | Tuple |
|---|---|---|
| قابل للتعديل؟ | أيوه (Mutable) | لأ (Immutable) |
| الأداء | أبطأ شوية | أسرع شوية في الوصول والتخزين |
| الاستخدام | بيانات ممكن تتغيّر | بيانات ثابتة (زي Coordinates أو Keys في Dictionary) |

### 50. Exception Handling في بايثون
بتستخدم `try`/`except`/`else`/`finally`:
- `try`: الكود اللي ممكن يعمل Exception.
- `except`: بيمسك نوع Exception معين ويتعامل معاه.
- `else`: بينفذ لو الـ `try` نجح من غير أي Exception.
- `finally`: بينفذ **دايماً** سواء حصل Exception أو لأ (مناسب للـ Cleanup زي قفل ملف أو اتصال).

### 51. لو حصل Error ومحتاج المنطق يكمل عادي — استخدام `pass` جوا `except`
لما تحط `pass` جوا `except`، إنت بتقول لبايثون "امسك الخطأ ده وتجاهله تماماً، وكمل تنفيذ الكود اللي بعده من غير ما توقف البرنامج". مفيد لما الخطأ متوقع ومش مؤثر على استمرار المنطق، لكن لازم تستخدمه بحذر عشان ميبقاش بتكتم أخطاء مهمة كنت المفروض تعالجها أو تسجلها (Log).

### 52. Decorators
دالة بتاخد دالة تانية كـ Input وبترجع دالة معدّلة، بتسمح لك تضيف سلوك جديد لدالة موجودة من غير ما تعدّل كودها الأصلي مباشرة. بتتكتب بصيغة `@decorator_name` فوق الدالة، وأشهر استخداماتها: Logging، Authentication Checks، Caching، وقياس زمن التنفيذ.

### 53. Shallow Copy vs Deep Copy
- **Shallow Copy**: بتنسخ الـ Object نفسه بس، لكن لو فيه Objects متداخلة جواه (Nested)، بتفضل بتشاور على نفس الـ References الأصلية — تعديل الجواني بيأثر على النسخة الأصلية.
- **Deep Copy**: بتنسخ الـ Object **وكل حاجة جواه** بشكل كامل ومستقل، فتعديل النسخة الجديدة مش هيأثر على الأصلية خالص.

### 54. Closures
دالة داخلية بـ**تفتكر** المتغيرات من الـ Scope الخارجي بتاعها حتى بعد ما الدالة الخارجية تخلص تنفيذها. بتستخدم لعمل "حالة خاصة" (Private State) محتفظ بيها بين استدعاءات متعددة، زي عمل Counter بيحتفظ بقيمته من غير متغيرات Global.

---

## ➕ الجزء العاشر: Giza Add-ons

### 55. `*args` vs `**kwargs`
- **`*args`**: بيسمح للدالة تستقبل عدد غير محدد من الـ Positional Arguments، بتتجمع في `tuple`.
- **`**kwargs`**: بيسمح للدالة تستقبل عدد غير محدد من الـ Keyword Arguments، بتتجمع في `dict`.

### 56. متى تستخدم Recursion ومتى تستخدم Loop
- **Recursion**: مناسبة للمشاكل اللي طبيعتها متكررة هرمياً (Tree Traversal، Divide and Conquer زي Merge Sort)، الكود بيبقى أوضح لكن فيها تكلفة أداء إضافية (Function Call Overhead) وخطر الـ Stack Overflow لو العمق كبير.
- **Loop**: أسرع وأقل استهلاكاً للذاكرة، مناسبة للمعالجة التكرارية البسيطة (زي المرور على قايمة).

### 57. Webhook
آلية بتخلي نظام معين "يبلّغ" نظام تاني تلقائياً لما حدث معين يحصل، عن طريق إرسال HTTP Request (عادة POST) لـ URL محدد مسبقاً، بدل ما النظام التاني يفضل يسأل (Polling) "حصل حاجة؟" باستمرار. مثال: Stripe بيبعت Webhook لموقعك لما عملية دفع تتم بنجاح.

### 58. Middlewares
طبقة كود بتشتغل **بين** وصول الـ Request للسيرفر ووصوله للـ View/Controller النهائي (أو العكس مع الـ Response)، بتستخدم لتنفيذ منطق مشترك زي الـ Authentication، الـ Logging، أو تعديل الـ Request/Response قبل ما يكمل مساره.

### 59. PUT vs PATCH
- **`PUT`**: بيستبدل الـ Resource **بالكامل** — لازم تبعت كل الحقول حتى لو مش هتتغير، وإلا هتتمسح.
- **`PATCH`**: بيعمل **تعديل جزئي** — بتبعت بس الحقول اللي عايز تغيّرها.

### 60. Lazy Loading
تقنية بتأجل تحميل جزء من البيانات أو الموارد **لحد ما يتم احتياجه فعلياً**، بدل ما يتحمل كله من الأول. بتحسّن وقت التحميل الأولي والأداء العام، وبتستخدم في تحميل الصور، تحميل العلاقات في الـ ORM، أو تحميل أجزاء من تطبيق React (`React.lazy`).

### 61. Null vs Undefined في JavaScript
- **`undefined`**: قيمة بتديها JavaScript **تلقائياً** لمتغير اتعرّف لكن معملوش تهيئة، أو لباراميتر متبعتش.
- **`null`**: قيمة بيحطها **المبرمج بنفسه عمداً** عشان يقول "المتغيّر ده فاضي قصداً ومفيهوش قيمة".

### 62. إزاي تتعامل مع Migration Conflicts؟
لما اتنين مطورين يعملوا Migrations مختلفة في نفس الوقت من نفس النقطة الأصلية، بيحصل تعارض في ترتيب أو محتوى الـ Migrations. الحل:
1. تحدد أنهي Migration المفروض تتنفذ الأول منطقياً.
2. تعمل Merge Migration (في Django فيه أمر `makemigrations --merge` بيعمل ده تلقائياً) أو تعيد ترتيب الـ dependencies يدوياً.
3. تتأكد من اختبار الـ Migrations على بيئة تجريبية قبل تطبيقها على قاعدة بيانات حقيقية.

### 63. إزاي تتعامل مع Merge Conflicts؟ (زي سؤال Git فوق)
نفس خطوات حل الـ Conflict اللي اتشرحت في سؤال 31: تحديد الملفات المتعارضة، فتحها وحل التعارض يدوياً بين النسختين، عمل `git add` للملفات بعد التعديل، وبعدين إكمال العملية بـ `commit` أو `rebase --continue` حسب السياق.

---

## 🔮 أسئلة إضافية متوقعة (نفس ستايل المحاور)

> [!info] ليه الأسئلة دي بالذات؟
> بعد تحليل الأسئلة اللي جت فعلياً، واضح إن المحاور بيحب: مقارنات "X vs Y" السريعة، أسئلة "استخدم إمتى؟"، وتغطية كل طبقة في الـ Stack (HTML/CSS → OOP/SOLID → Git → Auth → DB → Backend Framework → Python). الأسئلة دي امتداد منطقي لنفس الموضوعات اللي سألها بالفعل، فمتوقع تيجي بنفس الصيغة.

### 64. Box-Sizing: content-box vs border-box
- **`content-box`** (الافتراضي): الـ `width`/`height` بتتحسب للمحتوى بس، والـ padding والـ border بتتضاف فوقهم فيكبروا الحجم النهائي.
- **`border-box`**: الـ `width`/`height` بتشمل الـ padding والـ border جواها، فالحجم النهائي بيفضل ثابت زي ما حددته بالظبط. غالباً بيتفضل في المشاريع الحديثة لأنه أسهل في الحسابات.

### 65. Position: relative vs absolute vs fixed vs sticky
| القيمة | بتتمركز بالنسبة لـ | بتتحرك مع الـ Scroll؟ |
|---|---|---|
| `relative` | مكانها الطبيعي هي نفسها | أيوه |
| `absolute` | أقرب Ancestor بـ `position` غير `static` | أيوه |
| `fixed` | الـ Viewport (الشاشة) | لأ |
| `sticky` | بتتصرف Relative لحد نقطة معينة وبعدها Fixed | جزئياً |

### 66. Method Overriding في سياق الـ Access Modifiers
هل ممكن الـ Method في الابن تكون Access Level أضعف من الأب وقت الـ Overriding؟ **لأ** — قاعدة عامة في أغلب اللغات (Java مثلاً): الـ Method المُعاد تعريفها في الابن لازم تكون **بنفس مستوى الوصول أو أوسع**، مش أضيق، عشان متكسرش مبدأ الـ Liskov Substitution.

### 67. Abstract Class vs Interface
- **Abstract Class**: ممكن يحتوي على Methods منفذة (implementation) وعلى State (Fields)، والكلاس بيورث من واحد بس.
- **Interface**: عقد سلوك بحت (بدون implementation في الغالب)، والكلاس ممكن يـ`implement` أكتر من Interface في نفس الوقت.

### 68. Coupling vs Cohesion
- **Coupling (الترابط بين الكلاسات)**: كل ما قل، كل ما كان أحسن (Loose Coupling) — يعني الكلاسات مش معتمدة على تفاصيل بعض بشكل مباشر.
- **Cohesion (تماسك الكلاس الواحد)**: كل ما زاد، كل ما كان أحسن (High Cohesion) — يعني كل حاجة جوا الكلاس مرتبطة بمسؤولية واحدة واضحة.

### 69. Git: Cherry-pick
بتاخد commit معين من branch وتطبقه على branch تاني من غير ما تعمل merge للـ branch كله. مفيد لما محتاج fix معين بس من branch تاني بدون كل التغييرات التانية اللي فيه.

### 70. Git: HEAD وDetached HEAD State
الـ **HEAD** هو مؤشر بيشاور على آخر commit إنت واقف عليه دلوقتي. الـ **Detached HEAD** بتحصل لما تعمل checkout مباشرة لـ commit معين (مش لـ branch)، فأي commits جديدة تعملها مش هتتبع لأي branch وممكن تضيع لو انتقلت لمكان تاني من غير ما تعمل branch منها الأول.

### 71. Same-Origin Policy وعلاقته بالـ CORS
الـ **Same-Origin Policy** قاعدة أمان في المتصفح بتمنع صفحة من نطاق (Origin) معين إنها تعمل Request لنطاق مختلف بشكل افتراضي. الـ **CORS** هي الآلية اللي بتسمح للسيرفر يحدد صراحة "مسموح لمين" يعمل Requests ليه من نطاقات تانية، عن طريق Headers زي `Access-Control-Allow-Origin`.

### 72. XSS vs CSRF
- **XSS (Cross-Site Scripting)**: المهاجم بيحقن كود JavaScript خبيث في صفحة موثوقة، بينفذ في متصفح الضحية.
- **CSRF (Cross-Site Request Forgery)**: المهاجم بيخدع المستخدم المسجل دخول إنه ينفذ Request مش قاصده (زي تحويل فلوس) من غير علمه، مستغل إن المتصفح بيبعت الـ Cookies تلقائياً.

### 73. OAuth vs JWT
الـ **OAuth** هو **بروتوكول تفويض** (Authorization Protocol) بيحدد "إزاي" تدي تطبيق تالت صلاحية الوصول لبياناتك في خدمة تانية (زي تسجيل الدخول بجوجل). الـ **JWT** هو مجرد **صيغة Token** ممكن OAuth يستخدمها كـ Access Token، لكن مش شرط — الاتنين مفاهيم مختلفة بيشتغلوا مع بعض أحياناً.

### 74. Optimistic vs Pessimistic Locking (مكمل لموضوع تحسين أداء الـ DB)
- **Pessimistic Locking**: بتقفل الصف (Row) وقت القراءة عشان محدش يعدّله لحد ما تخلص، بيمنع التعارض لكن بيبطئ النظام لو الحمل عالي.
- **Optimistic Locking**: بتسمح للكل يقرأ ويعدّل، وبتتحقق وقت الحفظ بس (عن طريق version number) إن حد تاني معدلش نفس الصف قبلك، وإلا العملية ترفض وتتعاد.

### 75. Database Sharding vs Replication (مكمل لموضوع تحسين الأداء)
- **Sharding**: بتقسّم البيانات نفسها على أكتر من سيرفر (كل سيرفر شايل جزء مختلف).
- **Replication**: بتنسخ **نفس البيانات** على أكتر من سيرفر، غالباً عشان توزيع حمل القراءة أو الـ High Availability.

### 76. Django: `settings.py` — إعدادات مهمة لازم تعرفها
أشهر الإعدادات اللي بتتسأل عنها: `DATABASES` (إعدادات الاتصال بقاعدة البيانات)، `INSTALLED_APPS` (الـ Apps المفعّلة في المشروع)، `MIDDLEWARE` (ترتيب الـ Middleware اللي بيشتغل على كل Request)، `ALLOWED_HOSTS` (حماية أمنية بتحدد أنهي Domains مسموح تخدم منها التطبيق)، `DEBUG` (لازم تبقى `False` في الإنتاج لأسباب أمنية).

### 77. Django ORM: `filter()` vs `get()`
- **`filter()`**: بيرجع **QuerySet** (ممكن يكون فاضي أو فيه أكتر من نتيجة)، وميرميش Exception لو مفيش نتايج.
- **`get()`**: بيرجع **Object واحد بس**، ولو مفيش نتيجة بيرمي `DoesNotExist`، ولو فيه أكتر من نتيجة بيرمي `MultipleObjectsReturned`.

### 78. Python: Generators vs Lists
- **List**: بتحسب وتخزن **كل العناصر في الذاكرة** مرة واحدة.
- **Generator**: بيحسب كل عنصر **وقت الحاجة بس (Lazy Evaluation)** عن طريق `yield`، فبيوفر ذاكرة جداً مع مجموعات بيانات ضخمة لأنه مبيخزنش كل حاجة مرة واحدة.

### 79. Python: `is` vs `==`
- **`==`**: بتقارن **القيمة** (Value Equality).
- **`is`**: بتقارن **الهوية** (Identity) — يعني هل الاتنين فعلياً نفس الـ Object في نفس مكان الذاكرة (نفس الـ `id()`).

### 80. Python: `@staticmethod` vs `@classmethod` vs Instance Method
- **Instance Method**: بتاخد `self`، وليها وصول لبيانات الـ Instance المحدد.
- **`@classmethod`**: بتاخد `cls` بدل `self`، وليها وصول لبيانات الـ Class نفسه مش Instance معين (مفيدة كـ Alternative Constructors).
- **`@staticmethod`**: مبتاخدش `self` ولا `cls` خالص، دالة عادية بس منطقياً مرتبطة بالكلاس (زي دالة Utility).

### 81. React: Controlled vs Uncontrolled Components
- **Controlled**: قيمة الـ Input بتتحكم فيها الـ React State بالكامل (`value` + `onChange`)، وده الأسلوب المفضل غالباً لأنه بيديك تحكم كامل.
- **Uncontrolled**: الـ DOM نفسه بيحتفظ بالقيمة، وإنت بتوصلها وقت الحاجة بس عن طريق `ref`.

### 82. React: Virtual DOM
تمثيل خفيف (Lightweight Copy) للـ Real DOM موجود في الذاكرة. لما الـ State تتغيّر، React بيعمل مقارنة (Diffing) بين النسخة الجديدة من الـ Virtual DOM والقديمة، وبيحدّث في الـ Real DOM **بس الأجزاء اللي فعلاً اتغيرت** بدل إعادة رسم الصفحة كلها، وده بيحسّن الأداء بشكل كبير.

### 83. REST: إيه الفرق بين `POST` و`PUT` من ناحية الـ Idempotency؟
- **`POST`**: **مش Idempotent** — لو كررت نفس الـ Request عدة مرات، هيتعمل Resource جديد في كل مرة.
- **`PUT`**: **Idempotent** — لو كررت نفس الـ Request بنفس البيانات عدة مرات، النتيجة النهائية هتفضل واحدة (نفس الـ Resource بنفس القيم).

### 84. Environment Variables — ليه مهمة؟
بتخزن قيم حساسة أو بتتغير حسب البيئة (زي Database credentials، API Keys، Secret Keys) **بره الكود نفسه** في ملفات زي `.env`، عشان: (1) متسربش أسرار في الـ Git repo، (2) تقدر تغيّر الإعدادات بين Development/Staging/Production من غير ما تلمس الكود.

### 85. Rate Limiting
تقنية بتحدد **أقصى عدد Requests** مسموح بيه من مستخدم أو IP معين في فترة زمنية محددة، بتستخدم لحماية الـ API من إساءة الاستخدام (Abuse) أو هجمات الـ Brute Force، وبتحافظ على استقرار السيرفر تحت الحمل العالي.

---

## 🔮 موجة تالتة: فجوات مهمة محتمل تتسأل

> [!info] ليه الأسئلة دي بالذات؟
> دي مواضيع أساسية جداً في أي إنترفيو React/Django ومحدش سألها في الجلسة اللي جتلك، لكنها بنفس مستوى الصعوبة ونفس أسلوب "X vs Y" اللي المحاور بيحبه، فمتوقع تيجي في جولة تانية أو مع محاور مختلف.

### 86. Promise vs async/await
الـ **Promise** هو Object بيمثل نتيجة عملية Asynchronous (لسه شغالة، نجحت، أو فشلت)، وبتتعامل معاه بـ `.then()`/`.catch()`. الـ **async/await** هو Syntax Sugar فوق الـ Promises بيخليك تكتب كود Asynchronous **بشكل يشبه الكود العادي المتسلسل (Synchronous-looking)**، وده بيخلي الكود أسهل في القراءة ومنع الـ "Callback Hell" أو تسلسل `.then()` الطويل.

### 87. JavaScript Event Loop
الآلية اللي بتخلي JavaScript (رغم إنها Single-Threaded) تقدر تتعامل مع عمليات Asynchronous من غير ما توقف تنفيذ باقي الكود. الفكرة: أي عملية Async (زي `setTimeout` أو `fetch`) بتتحط في **Queue** منفصلة، والـ **Event Loop** بيفضل بيراقب الـ **Call Stack**، ولما تفضى، بياخد أول حاجة من الـ Queue وينفذها.

> [!tip] Checkpoint: الـ Microtask Queue (بتاعت الـ Promises) بتتنفذ **قبل** الـ Macrotask Queue (بتاعت `setTimeout`) حتى لو الـ `setTimeout` كان بـ 0 ملي ثانية — سؤال فخ شائع.

### 88. CSS Specificity
القاعدة اللي بتحدد "أنهي CSS Rule هيتطبق" لو أكتر من Rule بيستهدفوا نفس العنصر. الترتيب من الأقوى للأضعف تقريباً: **Inline Styles** > **IDs** (`#id`) > **Classes/Attributes/Pseudo-classes** (`.class`) > **Elements/Pseudo-elements** (`div`). الـ `!important` بيتخطى الترتيب ده كله، ولذلك استخدامه بكثرة يعتبر ممارسة سيئة.

### 89. React: `useEffect` ودورة الحياة (Lifecycle)
`useEffect` بيحاكي 3 مراحل من الـ Class Component Lifecycle:
- **Dependency Array فاضية `[]`**: بتتنفذ مرة واحدة بس بعد أول Render (زي `componentDidMount`).
- **من غير Dependency Array خالص**: بتتنفذ بعد **كل** Render (نادراً ما تكون الحاجة الصح).
- **مع Cleanup Function (`return () => {...}`)**: بتتنفذ قبل ما الـ Component يتشال من الشاشة (زي `componentWillUnmount`).

### 90. React: Context API
آلية بتحل مشكلة الـ **Prop Drilling** (تمرير Props عبر عدة مستويات من Components مش محتاجينها فعلياً بس عشان توصل لـ Component عميق). بتخليك تشارك بيانات (زي الـ Theme أو بيانات المستخدم المسجل دخول) مع أي Component في الشجرة من غير ما تمررها يدوياً درجة درجة.

### 91. React: أهمية الـ `key` Prop في القوائم
الـ `key` بتساعد React يعرف **أنهي عنصر اتغيّر، اتضاف، أو اتشال** من القايمة بكفاءة وقت عملية الـ Reconciliation (Diffing)، بدل ما يعيد رسم القايمة كلها من الصفر. استخدام الـ `index` كـ `key` مع قوايم بيتغيّر ترتيبها بيسبب مشاكل في الـ State وأداء ضعيف.

### 92. Django Signals
آلية بتسمح لأجزاء مختلفة من التطبيق "تتبلّغ" لما حدث معين يحصل، من غير ما تربطهم ببعض مباشرة (Decoupling). مثال شائع: `post_save` signal بتتنفذ تلقائياً بعد ما Model يتحفظ، ومفيدة مثلاً لإنشاء `Profile` تلقائياً لما `User` جديد يتسجل.

### 93. DRF: `ModelSerializer` vs `Serializer`
- **`Serializer`**: بتكتب كل الحقول (Fields) والـ Validation يدوياً بنفسك، مرونة كاملة.
- **`ModelSerializer`**: بتولّد الحقول تلقائياً من الـ Model نفسه (زي `Meta.fields`)، بتوفر وقت كبير في الحالات اللي الـ Serializer بيطابق الـ Model تقريباً بالكامل.

### 94. DRF: ViewSets & Routers
الـ **ViewSet** بيجمع منطق كذا View (List، Retrieve، Create، Update، Delete) في كلاس واحد بدل ما تكتبهم منفصلين. الـ **Router** بياخد الـ ViewSet ده ويولّد كل الـ URL Patterns المرتبطة بيه تلقائياً (زي `/items/` و`/items/{id}/`)، فبتوفر كتابة الـ `urls.py` يدوياً.

### 95. DRF: Pagination & Throttling
- **Pagination**: بتقسّم نتايج الـ API الكبيرة لصفحات بدل إرجاعها كلها مرة واحدة (زي `PageNumberPagination`، `LimitOffsetPagination`).
- **Throttling**: نوع من الـ Rate Limiting بتحدد كام Request المستخدم يقدر يعمله في فترة معينة، بتتفرق عن الـ Permissions لأنها بتتحكم في "المعدل" مش "هل مسموح أصلاً".

### 96. Types of SQL Joins
| النوع | بيرجع |
|---|---|
| **INNER JOIN** | الصفوف اللي ليها تطابق في الجدولين بس |
| **LEFT JOIN** | كل صفوف الجدول الشمال + المتطابق من اليمين (أو `NULL` لو معندوش تطابق) |
| **RIGHT JOIN** | عكس الـ LEFT — كل صفوف الجدول اليمين + المتطابق من الشمال |
| **FULL OUTER JOIN** | كل الصفوف من الجدولين، متطابقة أو لأ |

### 97. Foreign Key vs Unique Key
- **Foreign Key**: بتربط عمود في جدول بـ Primary Key في جدول تاني، وبتفرض سلامة العلاقة بين الجداول (Referential Integrity). ممكن تتكرر قيمتها في نفس الجدول.
- **Unique Key**: بتضمن إن قيم العمود ده **متتكررش** جوا نفس الجدول، لكن مالهاش علاقة بجدول تاني بالضرورة.

### 98. Database Transactions & ACID
الـ **Transaction** هي مجموعة عمليات لازم تتنفذ كلها بنجاح أو تترفض كلها كوحدة واحدة (زي تحويل فلوس بين حسابين). خصائصها الأربعة (**ACID**):
- **Atomicity**: كل حاجة أو لا حاجة.
- **Consistency**: البيانات تفضل صحيحة قبل وبعد الـ Transaction.
- **Isolation**: كل Transaction بتشتغل من غير ما تتأثر بالتانية اللي شغالة في نفس الوقت.
- **Durability**: بمجرد ما الـ Transaction تتعمل لها Commit، البيانات بتفضل محفوظة حتى لو حصل Crash.

### 99. Python: الـ GIL (Global Interpreter Lock)
قفل داخلي في الـ CPython (التنفيذ القياسي لبايثون) بيضمن إن **Thread واحد بس** يقدر ينفذ Python Bytecode في نفس اللحظة، حتى لو عندك أكتر من Thread. ده معناه إن الـ **Multithreading** في بايثون مش هيسرّع مهام تعتمد على المعالج (CPU-bound) فعلياً، لكنه لسه مفيد للمهام اللي بتستنى (I/O-bound) زي طلبات الشبكة. للاستفادة الحقيقية من أكتر من Core، بتستخدم **Multiprocessing** بدل Multithreading.

### 100. Python: List Comprehension vs Loop التقليدي
الـ **List Comprehension** (`[x*2 for x in range(10)]`) بتعمل نفس شغل الـ `for` loop العادي في سطر واحد، وعادة بتكون **أسرع شوية** لأنها محسّنة داخلياً في الـ CPython، وأقصر وأوضح في القراءة للحالات البسيطة. لكن لو المنطق معقد أو فيه شروط كتير متداخلة، الـ Loop التقليدي بيكون أوضح وأسهل في الصيانة.

### 101. Python: أشهر Magic/Dunder Methods
- **`__init__`**: الـ Constructor، بيتنفذ لما تعمل Object جديد.
- **`__str__`**: بيتحكم في الشكل اللي الـ Object بيظهر بيه لو عملتله `print()`.
- **`__eq__`**: بيتحكم في سلوك المقارنة بـ `==` بين Objects.
- **`__len__`**: بيخلي `len(obj)` تشتغل على الـ Object بتاعك.
- **`__repr__`**: بيديك تمثيل نصي للـ Object مفيد للـ Debugging (بيتفرق عن `__str__` في الهدف: `__repr__` للمطورين، `__str__` للعرض العادي).

### 102. HTTP Status Codes — الفئات الخمسة
| الفئة | المعنى | مثال |
|---|---|---|
| **1xx** | Informational — الطلب استلم ولسه بيتعالج | `100 Continue` |
| **2xx** | Success — الطلب نجح | `200 OK`, `201 Created` |
| **3xx** | Redirection — محتاج خطوة إضافية | `301 Moved Permanently` |
| **4xx** | Client Error — غلطة من اللي بعت الطلب | `400 Bad Request`, `404 Not Found` |
| **5xx** | Server Error — غلطة من السيرفر نفسه | `500 Internal Server Error` |

### 103. Docker — إيه هو وليه بيتستخدم؟
أداة بتسمح لك "تغلّف" التطبيق مع كل الـ Dependencies والإعدادات بتاعته جوا **Container** واحد معزول وقابل للنقل. الفايدة الأساسية: حل مشكلة **"شغال على جهازي بس مش شغال على السيرفر"**، لأن الـ Container بيشتغل بنفس الطريقة بالظبط على أي بيئة (Development، Staging، Production) طالما فيها Docker.

### 104. Unit Testing vs Integration Testing
- **Unit Testing**: بيختبر **وحدة واحدة معزولة** من الكود (زي Function أو Method واحدة) بمعزل تام عن باقي النظام (بيستخدم Mocking للـ Dependencies).
- **Integration Testing**: بيختبر **أكتر من جزء بيشتغلوا مع بعض** (زي View بينادي فعلياً على الـ Database)، عشان يتأكد إن التكامل بينهم شغال صح.

