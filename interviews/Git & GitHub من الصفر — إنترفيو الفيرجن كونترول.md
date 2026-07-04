---
tags: [git, github, interview-prep, version-control]
part: 1
covers: "Git Internals · Branching · Merging vs Rebasing · Remote Workflows · Collaboration · GitHub Specifics · Advanced Recovery · Real-World Work Scenarios"
---

# 🌿 Git & GitHub من الصفر (Q1 → نهاية الملف)

> [!info] 📖 إزاي تذاكر الملف ده؟
> الملف ده معمول عشان يغطيلك كل جوانب Git و GitHub من الصفر تماماً لحد أدق وأعمق التفاصيل اللي بتتسأل في الإنترفيوهات. كل سؤال مبني على اللي قبله، ومربوط بسيناريوهات حقيقية من بيئة الشغل عشان تفهم المنطق مش مجرد حفظ أوامر.

---

## Q1 — يعني إيه Git أصلاً؟ وإيه الفرق بينه وبين GitHub ولا هما حاجة واحدة؟

### أصل الحكاية
تخيل إنك شغال في شركة اسمها "InboxSales" ومعاك زميلتك منى في التيم. إنتوا الاتنين شغالين على نفس البروجكت. زمان، قبل ما الـ Git يظهر، كنت عشان تدمج شغلك مع منى، كنت بتاخد الفولدر بتاعك وتضغطه Zip وتبعتلهولها على Slack أو تحطه على Google Drive. منى تفتح الملف، وتكتشف إنك عدلت في ملف الـ `auth.js` اللي هي كمان كانت شغالة عليه! هنا بتحصل الكارثة الكلاسيكية: شغلك يمسح شغلها، أو تقعدوا بالساعات تقارنوا السطور يدوي عشان تطلعوا بنسخة شغالة.

الـ Git جه عشان يحل السحلة دي. هو عبارة عن نظام مراقبة وإدارة للنسخ (Version Control System). بيشتغل بالكامل على جهازك المحلي (Local Machine) من غير ما يحتاج إنترنت. بيسجل كل حركة وهمسة بتحصل في الملفات، ومين عمل إيه وإمتى.
أما الـ GitHub؟ ده بقى عبارة عن موقع أو منصة سحابية (Hosting Platform) بنرفع عليها الـ Repository اللي الـ Git مالي عينه منها على جهازنا. يعني الـ Git هو الأداة اللي بتدير المشروع محلياً، والـ GitHub هو الكافيه أو المساحة المشتركة اللي بنتقابل فيها عشان نرفع شغلنا لبعض، ونعمل مراجعة للكود (Code Review)، وندير الـ Pull Requests.

```bash
# Check if Git is installed and see the version
git --version
# Output: git version 2.43.0

# Configure your identity locally (essential for Git to know who made commits)
git config --global user.name "Ahmad Backend"
git config --global user.email "ahmad@inboxsales.com"

# View your configurations
git config --list
# Output: 
# user.name=Ahmad Backend
# user.email=ahmad@inboxsales.com
```

#### مثال 1: الشغل أوفلاين في الطيارة
لو إنت مسافر في طيارة ومفيش إنترنت، تقدر تعدل في الكود، وتعمل Commit وتعمل كمان Branches جديدة وتدمجها. الـ Git شغال معاك 100% لأن كل الداتا والتواريخ متسجلة محلياً في الفولدر السحري `.git` على جهازك. لما الطيارة تهبط وتوصل بإنترنت، تقدر ترفع التغييرات دي كلها لـ GitHub بـ `git push`.

#### مثال 2: السيرفر السحابي وقع
لو سيرفرات GitHub وقعت في يوم من الأيام، التيم بتاعك مش هيوقف شغل! كل مطور عنده نسخة كاملة من تاريخ المشروع كله على جهازه. تقدروا تنقلوا الكود لبعض عن طريق شبكة داخلية أو سيرفر بديل لأن Git نظام موزع (Distributed).

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the difference between Git and GitHub to a non-technical stakeholder, and discuss if we can use Git without GitHub."*
>
> **الإجابة المثالية:**
> الـ Git هو البرنامج الأساسي اللي بيشتغل على أجهزتنا محلياً عشان يراقب التغييرات ويحفظ تاريخ المشروع، وهو نظام إدارة نسخ موزع ومستقل تماماً عن أي سيرفر خارجي. أما الـ GitHub فهو منصة سحابية بنستخدمها عشان نستضيف المشاريع اللي متكودة بـ Git لتسهيل التعاون بين أفراد الفريق ومراجعة الكود بشكل مركزي. نقدر نشتغل بـ Git من غير GitHub نهائي عن طريق الاعتماد على إدارته المحلية أو باستخدام منصات بديلة زي GitLab أو Bitbucket، لأن Git لا يعتمد في جوهره على أي خادم سحابي ليقوم بوظيفته الأساسية.

> [!tip] Checkpoint
> افتكر دايماً: Git هو المحرك اللي جوه العربية، و GitHub هو الجراج السحابي اللي بتركن فيه العربية وتخلي الميكانيكية التانيين يشوفوها.

---

## Q2 — يعني إيه Repository (Repo)؟ والـ folder السحري `.git` ده جواه إيه وبتاع إيه؟

### أصل الحكاية
لما دخلت شركة "InboxSales" جديد، التيك ليد (Tech Lead) قالك: "اعمل فولدر جديد للـ service دي وابدأ الـ Repo بتاعتك". إنت عملت فولدر وكتبت جواه `git init`. فجأة، وبدون مقدمات، ظهر فولدر مخفي اسمه `.git`. 
الفولدر ده هو "عقل" الـ Repository. الـ Repository (المستودع) مش مجرد الفولدر اللي فيه ملفات الكود بتاعتك؛ هو عبارة عن مشروعك مضافاً إليه الفولدر الخفي `.git` اللي بيشيل قاعدة البيانات كاملة لتاريخ المشروع. 

لو مسكت الفولدر ده ودلته (Deleted)، المشروع بتاعك هيتحول في ثانية لفولدر عادي جداً والـ Git هيتساوى عنده المشروع ده بأي فولدر تاني على الكمبيوتر، وهيضيع تاريخ التعديلات والـ Branches والـ commits كلها ومستحيل ترجعها إلا لو عندك نسخة تانية برة جهازك.

```bash
# Initialize a new empty Git repository
git init
# Output: Initialized empty Git repository in /home/mkhaled/Desktop/GRAD-inpoxsales/.git/

# List all files including hidden ones to see the .git folder
ls -la
# Output: 
# drwxr-xr-x  3 user group 4096 Jul  4 19:00 .
# drwxr-xr-x 20 user group 4096 Jul  4 19:00 ..
# drwxr-xr-x  7 user group 4096 Jul  4 19:00 .git

# Explore what is inside the .git directory
ls -la .git
# Output:
# drwxr-xr-x 2 user group 4096 Jul  4 19:00 branches
# -rw-r--r-- 1 user group   92 Jul  4 19:00 config
# -rw-r--r-- 1 user group   73 Jul  4 19:00 description
# -rw-r--r-- 1 user group   23 Jul  4 19:00 HEAD
# drwxr-xr-x 2 user group 4096 Jul  4 19:00 hooks
# drwxr-xr-x 2 user group 4096 Jul  4 19:00 info
# drwxr-xr-x 4 user group 4096 Jul  4 19:00 objects
# drwxr-xr-x 4 user group 4096 Jul  4 19:00 refs
```

#### مثال 1: كارثة حذف فولدر `.git`
مطور جديد في التيم حب ينظف البروجكت ومسح الفولدرات المخفية ومنها `.git`. لما عمل `git status` لقاه بيقوله: `fatal: not a git repository`. الكود لسه قدامه بس مفيش أي وسيلة يعرف بيها الملفات دي كانت إيه من يومين أو مين عدل السطر ده. الحل الوحيد إنه يعمل `git clone` تاني للـ Repo من على GitHub عشان يسترجع الفولدر ده بالتاريخ بتاعه.

#### مثال 2: نقل المشروع بالـ History الكامل
لو أخدت فولدر المشروع كوبي وبست على فلاشة واديته لزميلك، طالما الفولدر الخفي `.git` موجود جواه، زميلك هيفتح الـ terminal ويعمل `git log` وهيلاقي كل الـ commits والتواريخ والـ branches كاملة كأنك شغال على جهازه بالظبط.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the purpose of the `.git` folder, and what are its key contents?"*
>
> **الإجابة المثالية:**
> مجلد `.git` هو المستودع الفعلي الذي يحتوي على كل البيانات الوصفية (Metadata) وتاريخ التغييرات الخاص بالمشروع. أهم محتوياته تشمل: ملف `config` لحفظ إعدادات المستودع المحلية، وملف `HEAD` الذي يشير إلى الفرع الحالي النشط، ومجلد `objects` وهو قاعدة البيانات التي تخزن محتويات الملفات (Blobs) والمجلدات (Trees) والتسجيلات (Commits)، ومجلد `refs` الذي يحتوي على مؤشرات الفروع (Branches) والوسوم (Tags). مسح هذا المجلد يفقد المشروع هويته كمستودع Git ويحذف تاريخه بالكامل محلياً.

> [!danger]
> إياك تعدل يدوياً في ملفات مجلد `.git` إلا لو عارف كويس جداً بتعمل إيه، تعديل سطر غلط في ملفات زي الـ `index` أو الـ `HEAD` ممكن يبوظ الـ Repo بالكامل ويخليه غير قابل للقراءة.

---

## Q3 — إيه هما الـ Three Areas (المناطق الثلاثة) في Git؟ وإزاي الكود بيتنقل بينهم؟

### أصل الحكاية
في "InboxSales"، كنت شغال على تذكرة (Ticket) تعديل في قاعدة البيانات. كتبت الكود الجديد، بس قبل ما تسجله بشكل نهائي، التيك ليد طلب منك تبص على مشكلة تانية. هنا بتفهم إن Git مش بيسجل التغييرات فوراً أول ما تكتبها. Git متقسم لـ 3 مناطق منطقية منفصلة بتعدي عليها عشان تحافظ على ترتيب ونظافة الـ History بتاعك:

1. **الـ Working Directory (بيئة العمل الحالية):** ده الفولدر اللي قدام عينك وبتعدل فيه الملفات في الـ VS Code. التغييرات هنا لسه Git شايفها بس مش محتفظ بيها بشكل رسمي (Untracked أو Modified).
2. **الـ Staging Area / Index (منطقة التحضير):** دي زي صندوق التعبئة أو المسرح الخلفي. بتنقي فيها الملفات اللي خلصتها وجاهزة للـ Commit بـ `git add`. بتسمحلك تختار تعديلات معينة بس تسجلها وتسيب الباقي يكمل شغل.
3. **الـ Local Repository (المستودع المحلي):** لما بتعمل `git commit`، التغييرات اللي كانت في الـ Staging Area بتتسجل بشكل نهائي وأبدي في قاعدة بيانات Git المحلية وتاخد رقم تعريفي (Hash)، وكده بقت جزء من تاريخ المشروع.

```bash
# 1. We edit a file locally (Working Directory)
echo "const dbConfig = {};" >> db.js

# Check status - Git sees the change but it's in Working Directory (red color)
git status
# Output:
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#	modified:   db.js

# 2. Move it to the Staging Area (Index)
git add db.js

# Check status - now it's in the Staging Area (green color, ready to commit)
git status
# Output:
# Changes to be committed:
#   (use "git restore --staged <file>..." to unstage)
#	modified:   db.js

# 3. Save it to the Local Repository
git commit -m "feat: configure database connection settings"
# Output:
# [main 4c3d2e1] feat: configure database connection settings
#  1 file changed, 1 insertion(+)
```

#### مثال 1: اختيار ملفات معينة فقط للـ Commit
شغلت إيدك وعدلت في 3 ملفات: `auth.js` و `db.js` و `temp_debug.log`. إنت عايز تسجل تغييرات الـ `auth.js` والـ `db.js` بس، ومش عايز تسجل ملف الـ log المؤقت ده. الـ Staging Area بتنقذك هنا: هتعمل `git add auth.js db.js` وبكده الـ commit الجاي هيشملهم هما بس، وهيستبعد الـ log من غير ما تضطر تمسحه من جهازك.

#### مثال 2: التراجع عن خطوة الـ Staging
عملت `git add .` بالغلط وضفت ملفات مش مجهزها للـ Commit. عشان ترجع الملفات دي تاني للـ Working Directory من غير ما تخسر التعديلات اللي جواها، بتستخدم الـ restore:
`git restore --staged <filename>`، وبكده رجعتها للمنطقة الحمراء (Working Directory) عشان تظبطها براحتك.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the Git workflow using the three areas (Working Directory, Staging Area, Local Repository) and why the Staging Area is useful."*
>
> **الإجابة المثالية:**
> تنقسم بيئة العمل في Git إلى ثلاث مناطق أساسية: مجلد العمل (Working Directory) حيث نقوم بتعديل الملفات فعلياً، ومنطقة التحضير (Staging Area / Index) وهي مساحة وسيطة نحدد فيها التغييرات المحددة التي نرغب في تضمينها في التسجيل القادم، والمستودع المحلي (Local Repository) الذي يحتوي على التاريخ المؤرشف والآمن للمشروع. تكمن أهمية منطقة التحضير في إعطاء المطور تحكماً كاملاً ودقيقاً في شكل الـ commits، بحيث يمكن صياغة commits مركزة ومنفصلة حتى لو تم تعديل عدة ملفات مختلفة في نفس الوقت.

> [!tip] Checkpoint
> - ملف أحمر = في الـ Working Directory (مش جاهز).
> - ملف أخضر = في الـ Staging Area (جاهز للتحزيم).
> - ملف مسجل = في الـ Repository (اتسيف خلاص).

---

## Q4 — هو الـ Commit في Git عبارة عن Snapshot (لقطة كاملة) ولا Diff (فروقات وتعديلات)؟

### أصل الحكاية
كتير من المطورين لما بيسألوا نفسهم: "هو Git بيحفظ الملفات إزاي؟" بيفترضوا إنه بيشيل السطر اللي اتشال والسطر اللي اتضاف (الـ Diffs) عشان يوفر مساحة. المنطق ده منطقي على فكرة، بس Git مش شغال كده!
Git بياخد **Snapshot (لقطة كاملة)** من كل ملفات المشروع في لحظة الـ commit. 

عشان تفهم المنطق ده: لو ملف `app.js` محتواه 100 سطر وتعدل فيه حرف واحد، Git مش هيشيل الحرف ده بس؛ هو هيعمل نسخة كاملة وجديدة من الملف ده ويخزنها عنده! 
"طب والمساحة يا عم Git؟" Git ذكي جداً؛ لو الملف متعدلش خالص في الـ commit الجديد، Git مش بيكرره في الـ database؛ هو بس بيعمل Pointer (مؤشر) يشير للنسخة الأصلية اللي اتخزنت في الـ commit اللي قبله. الطريقة دي بتخلي عمليات التنقل بين الـ Branches والـ Commits سريعة جداً لأنها مجرد تغيير مؤشرات مش إعادة بناء للملفات من الفروقات.

```bash
# Let's see how Git represents a commit's metadata and structure
# We use 'git cat-file -p' (pretty print) to peek into Git's internal database.
# Note: replace 'HEAD' with any commit hash to inspect it.

git cat-file -p HEAD
# Output:
# tree 8f4a3c220f11904db3584860b0ffde18f3ef4230
# parent 3a2c1b00ffde18f3ef42308f4a3c220f11904db
# author Ahmad Backend <ahmad@inboxsales.com> 1719946800 +0300
# committer Ahmad Backend <ahmad@inboxsales.com> 1719946800 +0300
#
# feat: add user registration endpoint
```

#### مثال 1: فحص الـ Tree Object
لما بنبص على نتيجة الـ `cat-file` فوق، بنلاقي سطر اسمه `tree` ومكتوب جنبه Hash. الـ Tree ده بيمثل الـ Snapshot بتاعة الفولدر كله. لو دخلنا جواه بـ `git cat-file -p 8f4a3c2...` هنلاقيه جواه لستة بكل الملفات اللي في المشروع وكل ملف مشاور على النسخة بتاعته كاملة (Blob)، مش شوية سطور فروقات.

#### مثال 2: سرعة الـ Checkout
بسبب إن Git شغال بنظام الـ Snapshots، لما بتعمل `git checkout` لـ branch قديم من سنة فاتت، العملية بتاخد أجزاء من الثانية. Git مش بيقعد يجمع آلاف الـ diffs ورا بعض عشان يبني النسخة؛ هو حرفياً بيروح يجيب الـ Snapshot الجاهزة المخزنة للملفات دي ويرميها في الـ Working Directory بتاعك فوراً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Does Git store commits as differences (diffs) or snapshots? Explain the architectural benefits of this approach."*
>
> **الإجابة المثالية:**
> يخزن Git البيانات كلقطات كاملة للحالة (Snapshots) وليس كفروقات تراكمية (Diffs). عند كل تسجيل (Commit)، يأخذ Git لقطة لجميع الملفات في ذلك الوقت ويخزن مؤشراً لها؛ وإذا لم يتغير الملف، فإنه لا يعيد تخزينه بل يشير فقط إلى الملف السابق المطابق. الفائدة المعمارية من هذا الأسلوب هي جعل العمليات مثل التنقل بين الفروع (Branching & Checkout) ومقارنة التواريخ سريعة جداً بتكلفة زمنية ثابتة O(1) تقريباً، لأن Git لا يحتاج إلى حساب وتطبيق سلسلة طويلة من الفروقات لإعادة بناء الملف في لحظة معينة.

> [!tip] Checkpoint
> - نظام الـ Diff: بيحفظ تعديلات (مثال: + سطر 5، - سطر 12).
> - نظام الـ Snapshot: بيحفظ الملف بالكامل كما هو في حالته الحالية، ويشير للملف القديم لو مفيش تعديل.

---

## Q5 — إيه هو الـ SHA-1 Hash؟ وإزاي الـ Commits بتاخد الـ ID بتاعها؟

### أصل الحكاية
لو فتحت `git log` في مشروع InboxSales، هتلاقي كل commit مكتوب قدامه كود طويل غريب كأنه طلاسم، مثلاً: `4c3d2e1b8f4a3c220f11904db3584860b0ffde18`. الكود ده مش عشوائي ومفتكس؛ ده اسمه **SHA-1 Hash**.
الـ Git مش بيستخدم أرقام متسلسلة زي (Commit 1, Commit 2) لأنه شغال بنظام موزع. لو إنت شغال أوفلاين وزميلتك منى شغالة أوفلاين، وإنت عملت commit وهي عملت commit، وسميتوهم بالترتيب 1 و 2، لما تيجوا تدمجوا هيحصل تداخل وتعارض.

عشان كده Git بيستخدم خوارزمية تشفير اسمها SHA-1 (بتاخد 160 بت، وبتتمثل بـ 40 حرف ستة عشري Hexadecimal). 
الـ Hash ده بيتحسب بناءً على **محتوى الـ commit بالكامل**، وده بيشمل:
- محتويات الملفات (الـ Blobs).
- هيكل المجلدات (الـ Tree).
- بيانات الكاتب والمطور (Author/Committer).
- التاريخ والوقت بالثانية.
- الـ Hash بتاع الـ Commit الأب (Parent Commit).

أي تغيير ولو بسيط جداً (حتى لو مسافة زيادة في ملف) هيغير الـ Hash ده بالكامل. ده بيدي Git خاصية أمان وحماية للبيانات (Data Integrity)، يعني مستحيل تعدل في تاريخ المشروع القديم من غير ما الـ Hash يتغير والكل يكتشف ده فوراً.

```bash
# View recent commits with their full SHA-1 hashes
git log

# Output:
# commit 4c3d2e1b8f4a3c220f11904db3584860b0ffde18 (HEAD -> main)
# Author: Ahmad Backend <ahmad@inboxsales.com>
# Date:   Sat Jul 4 19:15:00 2026 +0300
# 
#     feat: configure database connection settings

# You can use only the first 7 characters of the hash to refer to a commit
git show 4c3d2e1
```

#### مثال 1: تأثير الـ parent في تغيير الـ Hash
لو كتبت نفس الرسالة وعملت نفس التغييرات على نفس الملفات بالظبط في جهازين مختلفين، الـ Hash هيطلع مختلف. ليه؟ لأن الـ Timestamp (الوقت) مختلف، وممكن الـ parent commit اللي مبني عليه يكون مختلف. الـ Hash بصمة فريدة لا تتكرر.

#### مثال 2: كشف التلاعب بالـ History
لو مطور حاول يدخل على الـ history القديم ويعدل رقم حساب بنكي في كود من شهر فات عشان يسرق فلوس مثلاً، الـ Hash بتاع الـ commit ده هيتغير. وبناء عليه، الـ Hash بتاع كل الـ commits اللي بعده هتتغير (لأن كل commit شايل جواه الـ hash بتاع الـ parent بتاعه). الـ Git هيضرب في الـ server ويقول إن الـ history متلاعب فيه ومرفوض تماماً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"How does Git generate a commit SHA-1 ID, and why is this cryptographic hashing important for version control?"*
>
> **الإجابة المثالية:**
> يقوم Git بتوليد معرّف الـ Commit باستخدام خوارزمية التشفير SHA-1 التي تنتج بصمة فريدة بطول 40 حرفاً سداسياً عشرياً. يتم حساب هذا المعرف بناءً على محتوى الـ Commit بالكامل بما يشمل هيكل المجلدات الحالي، محتوى الملفات، رسالة الـ commit، بيانات المطور والتوقيت الزمني، ومعرف الـ Commit الأب (Parent Commit). تكمن أهمية هذا التجزير (Hashing) في ضمان سلامة وموثوقية البيانات (Data Integrity)؛ حيث يمنع التلاعب بالتاريخ القديم لأن أي تعديل طفيف سيغير المعرف الخاص بالـ commit والـ commits اللاحقة، مما يسهل اكتشاف التلاعب فوراً، كما أنه يسهل تحديد النسخ الفريدة وتفادي تعارض التسمية في بيئة العمل الموزعة.

> [!warning]
> في الإصدارات الحديثة، Git بدأ يدعم SHA-256 كبديل لـ SHA-1 لتجنب احتمالية حدوث "Collision" (تصادم الهاشات)، وإن كان حدوث تصادم في SHA-1 بالصدفة في مشروع حقيقي شبه مستحيل عملياً.

---

## Q6 — إيه هما الـ Git Objects الأربعة الأساسيين (blob, tree, commit, tag)؟ وإزاي بيشكلوا قاعدة البيانات؟

### أصل الحكاية
لما بتعمل commit، الـ Git مش بيبص للموضوع على إنه شوية سطور وخلاص؛ هو بيتعامل مع المشروع كقاعدة بيانات كائنات (Object Database). أي حاجة بيخزنها Git بتدخل جوه فولدر `.git/objects` على هيئة واحد من 4 كائنات رئيسية:

1. **الـ Blob (Binary Large Object):** ده بيمثل محتوى الملف فقط! يعني الحروف والأكواد اللي مكتوبة جوه الملف. الـ Blob ميعرفش اسم الملف إيه، ولا هو في أنهي فولدر، ولا صلاحياته إيه (Read/Write). هو بيخزن الكود بس. لو عندك ملفين بنفس المحتوى بالظبط بأسامي مختلفة، Git هيعملهم Blob واحد بس ويوفر مساحة!
2. **الـ Tree (الشجرة):** دي بتمثل الفولدر (Directory). وهي اللي بتدي الملفات هويتها. الـ Tree عبارة عن ملف نصي جواه لستة بالملفات والفولدرات اللي جواه، وكل سطر فيه بيشاور على الـ Hash بتاع الـ Blob (محتوى الملف) واسمه وصلاحياته، أو بيشاور على Tree تانية (Sub-directory).
3. **الـ Commit (التسجيل):** ده الكائن اللي بيربط الدنيا ببعضها. هو بيشاور على Tree رئيسية (اللي بتمثل الـ root folder للمشروع في اللحظة دي)، وبيشاور على الـ Commit الأب (Parent Commit) عشان يبني السلسلة، وبيشيل جواه بيانات الكاتب ورسالة الـ commit.
4. **الـ Tag (الوسم):** ده كائن بيشاور على Commit معين عشان يديله اسم سهل (زي `v1.0.0` مثلاً) بدل الـ Hash الطويل المعقد.

كل الكائنات دي بتتخزن مضغوطة باستخدام مكتبة Zlib ومكتبة التجزير للتأكد من السلامة.

```bash
# Write a raw string into Git database and get its blob SHA-1 hash
echo "Hello InboxSales" | git hash-object -w --stdin
# Output: e69de29bb2d1d6434b8b29ae775ad8c2e48c5391

# Retrieve the type of the object we just created
git cat-file -t e69de29
# Output: blob

# Retrieve the content of that object
git cat-file -p e69de29
# Output: Hello InboxSales
```

#### مثال 1: ملفين متطابقين بأسماء مختلفة
مطور في التيم عمل كوبي لملف الـ `config.json` وسماه `config.backup.json`. المشروع مساحته زادت؟ لا! الـ Git لقى إن المحتوى (Content) متطابق 100%، فعمل Blob واحد بس في مجلد الكائنات، وعمل سطرين في الـ Tree بيشاوروا على نفس الـ Hash بأسماء مختلفة. ده بيخلى Git ذكي جداً في استهلاك المساحة.

#### مثال 2: تتبع الفولدرات الفاضية
حاولت تعمل فولدر فاضي وتضيفه للـ Git. لما تعمل `git status` هتلاقيه مش شايفه نهائي! ليه؟ لأن Git بيخزن الملفات كـ Blobs ويربطها بـ Trees. الفولدر الفاضي ملوش Blobs جواه، وبالتالي مفيش Tree تقدر تتبعه. عشان كده بنتحايل على الموضوع ونحط ملف خفي اسمه `.gitkeep` جوه الفولدر الفاضي عشان نخليه يتشاف.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain how Git reconstructs your project directory structure at a specific commit using the four Git object types."*
>
> **الإجابة المثالية:**
> يقوم Git بإعادة بناء هيكل المشروع عند أي Commit محدد من خلال تتبع المؤشرات بين الكائنات الأربعة. يبدأ من كائن الـ Commit الذي يشير إلى كائن الـ Tree الرئيسي للمشروع (الذي يمثل الفولدر الجذري). يقرأ Git كائن الـ Tree هذا، والذي يحتوي على قائمة بالأسماء والـ Hashes الخاصة بالملفات (Blobs) والمجلدات الفرعية (Trees الأخرى). يقوم Git بالنزول تفرعياً عبر هذه الـ Trees واستبدال كل معرف Blob بمحتواه الفعلي المخزن في قاعدة بيانات الكائنات، مع الاحتفاظ بأسماء الملفات وصلاحياتها كما حددتها الـ Tree، ليعيد في النهاية تشكيل بيئة العمل الكاملة بدقة وسرعة فائقة.

> [!tip] Checkpoint
> - الـ Blob = كود الملف فقط.
> - الـ Tree = خريطة الفولدر (الأسماء والمؤشرات).
> - الـ Commit = بيانات التسجيل ومؤشر الـ Tree والـ Parent.
> - الـ Tag = لافتة مكتوب عليها اسم مميز مشيرة لـ Commit.

---

## Q7 — إيه هو الـ HEAD؟ وإيه معنى إنه Pointer لـ Pointer (مؤشر لمؤشر)؟

### أصل الحكاية
في بروجكت InboxSales، وإنت بتنقل بين الـ Branches، بتسأل نفسك: "هو Git بيعف منين أنا واقف في أنهي Branch دلوقتي؟ وأي commit هعمله هيتسجل على أنهي خط؟" 
الإجابة هي ملف صغير جداً ومخفي جوه الـ Repo اسمه `HEAD` (بيتحفظ في `.git/HEAD`).

الـ `HEAD` في Git هو عبارة عن لافتة أو مؤشر (Pointer). في الحالة الطبيعية، هو مش بيشير لـ Commit مباشرة؛ هو بيشير لـ **Branch** (زي `main` أو `feature-login`)، والـ Branch بدوره هو عبارة عن مؤشر بيشير لأحدث Commit اتعمل على الخط ده. عشان كده بنسمي الـ `HEAD` إنه "مؤشر لمؤشر" (Pointer to a Pointer).
لما بتعمل commit جديد، الـ branch بيتحرك خطوة لقدام ويشير للـ commit الجديد، وبما إن الـ HEAD مشاور على الـ branch، فالـ HEAD بيتحرك معاه تلقائياً.

```bash
# View the contents of the HEAD file directly
cat .git/HEAD
# Output: ref: refs/heads/main

# Now check the commit hash that the main branch points to
cat .git/refs/heads/main
# Output: 4c3d2e1b8f4a3c220f11904db3584860b0ffde18

# View where HEAD is currently pointing using git log
git log -1
# Output shows: (HEAD -> main) commit 4c3d2e1...
```

#### مثال 1: سحلة الـ Detached HEAD State
دخلت على مشروع وعملت `git checkout <commit-hash>` عشان تشوف كود قديم من أسبوع. فجأة طلعلك تحذير مرعب بيقولك: `You are in 'detached HEAD' state`. إيه اللي حصل؟
اللي حصل إن الـ HEAD ساب الـ branch ومشاور مباشرة على الـ Commit hash. بقى مؤشر مباشر للـ Commit مش مؤشر لمؤشر. لو عملت أي commits جديدة هنا، هتبقى طايرة في الهواء (Orphaned/Dangling commits) بمجرد ما تتنقل لـ branch تاني لأن مفيش branch شايلها ومثبتها.

#### مثال 2: الخروج الآمن من الـ Detached HEAD
لو كتبت كود مهم وإنت في حالة الـ Detached HEAD وعايز تحافظ عليه مش تضيعه، الحل إنك تعمل branch جديد فوراً وإنت واقف في مكانك بـ `git switch -c new-temporary-branch` وبكده الـ HEAD هيرجع يشير للـ branch الجديد والـ branch يشير للـ commits بتاعتك وكله يبقى في الأمان.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the HEAD in Git, how does it differ from a branch pointer, and what is a 'detached HEAD' state?"*
>
> **الإجابة المثالية:**
> الـ HEAD هو مؤشر خاص في Git يحدد الفرع النشط حالياً وموقع العمل الحالي في شجرة التاريخ. في الحالة العادية، يكون HEAD مؤشراً غير مباشر (Pointer to a Pointer) لأنه يشير إلى مرجع فرع (Branch Reference) مثل `main` والفرع بدوره يشير إلى الـ commit الأحدث. أما حالة الـ "Detached HEAD" فتحدث عندما نقوم بعمل checkout لـ commit معين مباشرة بالـ Hash بتاعه أو لـ Remote branch وليس لـ local branch؛ في هذه الحالة يشير HEAD مباشرة إلى الـ commit دون وسيط، مما يعني أن أي commits جديدة يتم إنشاؤها لن تنتمي لأي فرع محلي وستكون معرضة للفقدان عند الانتقال لمكان آخر ما لم يتم ربطها بفرع جديد فوراً.

> [!danger]
> إياك تسيب كود في Detached HEAD وتروح لـ branch تاني قبل ما تعمله branch، الكود ده هيفضل في الـ database شوية بس الـ Garbage Collector بتاع Git هيمسحه بعد فترة ومش هتعرف توصله بسهولة.

---

## Q8 — إيه الفرق الفعلي والعملياتي بين الـ Working Tree والـ Index (Staging Area) والـ `.git` directory؟

### أصل الحكاية
عشان تتقن الـ Git وتجاوب بثقة في الإنترفيو، لازم تتخيل الـ 3 مناطق دول كـ "حالات فيزيائية" للكود بتاعك في مشروع InboxSales.
لما بتعدل ملف الـ `server.js` وتضيف سطر كود، التغيير ده موجود في **الـ Working Tree (أو Working Directory)** فقط. دي المساحة الحية اللي نظام التشغيل بتاعك والـ VS Code بيشوفوها. التغييرات هنا مؤقتة جداً وغير محمية بأي شكل من Git.

لما بتنفذ `git add server.js`، إنت بتاخد لقطة من الملف وبتحطها في **الـ Index (الـ Staging Area)**. الـ Index ده فعلياً هو ملف ثنائي (Binary File) موجود في `.git/index`. الملف ده بيحتوي على لستة مرتبة بكل أسماء الملفات في مشروعك والـ SHA-1 Hashes المقابلة ليها في اللحظة دي. لما بتعمل add، الـ Git بيعمل blob جديد للملف في مجلد الـ objects ويحدث الـ index عشان يشير للـ blob الجديد ده.
أخيراً، لما بتكتب `git commit`، الـ Git بياخد محتويات الـ Index دي ويعمل منها Tree object ويسجلها في **الـ `.git` directory (المستودع المحلي)** كـ commit رسمي.

```bash
# Compare working directory changes with the staging area (index)
git diff

# Compare staging area changes (index) with the repository (last commit)
git diff --staged # or --cached

# Look at the status of a specific file in these areas
git status -s
# Output:
# M  db.js    <- (First letter 'M' is green, meaning it's modified in Staging)
#  M auth.js  <- (Second letter 'M' is red, meaning it's modified in Working Tree but not staged)
```

#### مثال 1: التعديل المزدوج لملف واحد
عدلت ملف `app.js` وضفته للـ Staging بـ `git add app.js`. بعدها بربع ساعة، وإنت لسه ما عملتش commit، عدلت سطر كمان في نفس الملف `app.js`. دلوقتي الملف بقى Staged بالنسخة القديمة، و Modified بالنسخة الجديدة! لو عملت commit دلوقتي، التعديلات الأولى بس هي اللي هتتسيف والتعديلات الأخيرة هتفضل برة الـ commit.

#### مثال 2: تنظيف الـ Working Tree بدون لمس الـ Repo
شغلت إيدك وكتبت أكواد تجريبية كتير في الـ Working Tree ولقيت الدنيا باظت وعايز ترجع لآخر نسخة آمنة في الـ Repo من غير ما تخسر الـ Staged files:
بتستخدم `git restore <filename>` عشان ترجع الملف لحالته اللي متسجلة في الـ Index.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Programmatically describe the difference between the Working Tree, the Index, and the Git Repository. What happens to the `.git/index` file during a checkout?"*
>
> **الإجابة المثالية:**
> الـ Working Tree هي الملفات الفعلية الموجودة على القرص الصلب والتي يتعامل معها المطور مباشرة. الـ Index (الـ Staging Area) هو ملف ثنائي وسيط في المسار `.git/index` يمثل الحالة المتوقعة للـ commit القادم ويحتوي على خريطة بالملفات ومؤشرات كائناتها. الـ Git Repository هو مستودع الكائنات والتاريخ الفعلي. عند عمل checkout لـ branch جديد، يقوم Git بتحديث الـ Index ليطابق الـ commit الأحدث في هذا الفرع، ثم يقوم بنسخ هذه الملفات من قاعدة بيانات الكائنات إلى الـ Working Tree لتحديث الملفات أمام المطور.

---

## Q9 — إزاي `git init` بتشتغل جوّه؟ وإيه اللي بيتولد في مجلد `.git` لحظة تشغيلها؟

### أصل الحكاية
كلنا حافظين إن `git init` هي أول خطوة في أي مشروع. بس التيك ليد في InboxSales سألك في الإنترفيو: "لما بتكتب الأمر ده، إيه اللي بيحصل ورا الكواليس في نظام التشغيل؟ وإيه الهيكل الأدنى اللي بيتخلق؟"
الـ Git أداة بسيطة جداً في جوهرها. لما بتنفذ `git init`، الـ Git بيعمل فولدر اسمه `.git` وبيحط فيه الهيكل الأساسي اللي هيحتاجه لإدارة مشروعك. الهيكل ده بيتكون من ملفات وفولدرات محددة بتتبني فوراً:

1. **مجلد `objects/`:** بيكون فاضي في الأول (جواه فولدرين فرعيين `info` و `pack`)، وده اللي هيتخزن فيه الـ blobs والـ trees والـ commits بعد كده.
2. **مجلد `refs/`:** جواه `heads` (للفروع المحلية) و `tags` (للوسوم)، وبيكون فاضي برضه مستني أول branch يتعمل.
3. **ملف `HEAD`:** ملف نصي بسيط جداً جواه سطر واحد: `ref: refs/heads/master` (أو `main` حسب إعدادات جهازك). هو بيشير للـ branch الافتراضي اللي لسه متخلقش أصلاً!
4. **ملف `config`:** ده ملف إعدادات مستودعك المحلي.
5. **مجلد `hooks/`:** جواه ملفات تجريبية للـ scripts التلقائية.

```bash
# Let's create a temp folder and run init to trace the creation
mkdir temp_git_test && cd temp_git_test
git init
# Output: Initialized empty Git repository in .../temp_git_test/.git/

# Find all files created initially
find .git
# Output:
# .git
# .git/config
# .git/objects
# .git/objects/pack
# .git/objects/info
# .git/HEAD
# .git/info
# .git/info/exclude
# .git/description
# .git/hooks
# ...
# .git/refs
# .git/refs/heads
# .git/refs/tags
```

#### مثال 1: تغيير اسم الفرع الافتراضي عند الـ Init
زادت الانتقادات لاسم `master` وبقى التيم بيفضل يبدأ بـ `main`. لو عايز تخلي الـ init تلقائياً تظبط الـ HEAD على `main` من أول لقطة:
تقدر تنفذ `git config --global init.defaultBranch main` قبل ما تعمل `git init` للمشروع الجديد.

#### مثال 2: استخدام الـ Hooks لفرض قواعد الكود
جوه `.git/hooks` فيه ملف اسمه `pre-commit.sample`. لو شلت كلمة `.sample` وكتبت جواه script بيعمل linter أو run tests للكود، المطور مش هيعرف يعمل `git commit` أبداً لو الكود بتاعه فيه أخطاء تنسيق، لأن الـ commit هيقف تلقائياً!

### الفايدة الانترفيوية
> **Interview Question:**
> *"When you run `git init`, what structure is created under the hood, and how does Git use it?"*
>
> **الإجابة المثالية:**
> عند تشغيل `git init` يقوم Git بإنشاء مجلد `.git` بالهيكل الأدنى المطلوب لإدارة النسخ. يتم إنشاء مجلد `objects` لحفظ الكائنات لاحقاً، ومجلد `refs` لحفظ مرجعيات الفروع والوسوم. كما ينشأ ملف `HEAD` الذي يحتوي على مسار الفرع الافتراضي (غالباً `refs/heads/main` أو `master`). في هذه اللحظة، لا يوجد أي commit أو فرع فعلي على القرص؛ لكن Git يعرف أين سيكتب التاريخ الأولي لأنه يقرأ قيمة ملف `HEAD`؛ وعند أول عملية commit، سيقوم Git بإنشاء الفرع المذكور في `HEAD` تلقائياً وجعله يشير إلى الـ commit الأول كـ Root Commit للمشروع.

---

## Q10 — إيه هو الـ `.gitignore`؟ وإزاي بيشتغل الـ Pattern Matching فيه ونتعامل مع ملفات اتسجلت بالغلط؟

### أصل الحكاية
في InboxSales، كنت بتجرب مكتبة جديدة وعملت `npm install`. فجأة لقيت الـ VS Code كاتبلك إن فيه 40 ألف ملف متعدل (اللي هما فولدر الـ `node_modules`). طبعاً كارثة لو عملت لهم add و commit ورفعتهم على GitHub. هنا بيجي دور ملف `.gitignore`.

ملف الـ `.gitignore` هو ملف نصي عادي بتكتب فيه أسماء الملفات والفولدرات أو الأنماط (Patterns) اللي مش عايز Git يراقبها ولا تظهرلك في الـ `git status`. 
بيشتغل بنظام الـ Wildcards (زي النجمة `*` والـ Double Asterisk `**` وعلامة التعجب `!`). 
الخطأ الشائع هنا: لو فيه ملف كان متسجل ومتتبع فعلاً (Tracked) في الـ Repo من زمان، وبعدين ضفته للـ `.gitignore` عشان توقف تتبعه، الـ Git **مش هيتجاهله** وهيستمر يراقب تعديلاته! `.gitignore` بيشتغل فقط على الملفات اللي لسه Untracked.

```bash
# Create a .gitignore file
touch .gitignore

# Add patterns to ignore
echo "node_modules/" >> .gitignore
echo "*.env" >> .gitignore  # Ignore all environment configuration files
echo "dist/**/*.log" >> .gitignore # Ignore all files ending with .log inside any folder under dist

# Check what happens if a file is ignored but we try to add it anyway
git add config.env
# Output:
# The following paths are ignored by one of your .gitignore files:
# config.env
# hint: Use -f if you really want to add them.

# How to remove a file from tracking but keep it locally on disk (The ultimate fix)
git rm --cached database.config
# Output: rm 'database.config'
```

#### مثال 1: فخ حذف الملفات من جهازك بالخطأ
مطور لقى ملف الـ `.env` اترفع على GitHub بالخطأ ومكتوب فيه باسورادات. حب يشيله من الـ Git فكتب `git rm database.env`. لما عمل commit و push، لقى الملف اتحذف من جهازه ومسح كل الشغل المحلي!
الحل الصح كان إنه يكتب `git rm --cached database.env` عشان يشيل المراقبة من الـ Git بس يسيب الملف سليم زي ما هو على الهارد ديسك بتاعه.

#### مثال 2: استثناء ملف معين وسط مجلد متجاهل
التيم قرر يتجاهل كل ملفات الـ PDF في مشروع التوثيق، بس عايزين ملف واحد بس اسمه `essential_guide.pdf` يترفع ويتبع. بنستخدم علامة التعجب `!` للاستثناء:
```text
*.pdf
!essential_guide.pdf
```
بكده Git هيتجاهل كل الـ PDFs ما عدا الملف ده بالظبط.

### الفايدة الانترفيوية
> **Interview Question:**
> *"You added `.env` to `.gitignore`, but it still appears in `git status` and is tracked by Git. Why does this happen, and how do you resolve it without deleting the local file?"*
>
> **الإجابة المثالية:**
> يحدث هذا لأن ملف `.gitignore` يؤثر فقط على الملفات غير المتتبعة (Untracked Files)؛ فإذا تم تسجيل ملف `.env` وعمل commit له مسبقاً في المستودع، فإن Git سيستمر في تتبعه ومراقبة أي تغييرات تطرأ عليه متجاهلاً القاعدة الموجودة في `.gitignore`. لحل هذه المشكلة دون حذف الملف المحلي من الجهاز، يجب إزالة الملف من ذاكرة التتبع (Index) الخاصة بـ Git باستخدام الأمر `git rm --cached .env` ثم عمل commit لهذه الإزالة وضخها للمستودع، ليقوم Git بعدها باحترام قاعدة التجاهل.

> [!warning]
> لما بتعمل `git rm --cached` لملف وترفع الشغل، المطورين التانيين لما يعملوا `git pull` الملف ده هيتحذف من عندهم محلياً لأن الـ commit بيقول لـ Git امسح الملف ده من نظام التتبع والمشروع. نبه زمايلك ياخدوا نسخة احتياطية من ملفات إعداداتهم المحلية قبل السحب.

---

## Q11 — إيه هي دورة حياة الملف (File Lifecycle) في الـ Git؟

### أصل الحكاية
عشان كودك في InboxSales يتحرك من فكرة في دماغك لملف شغال على السيرفر، الملف بيمر بمراحل انتقالية دقيقة كأنه في خط إنتاج مصنع.
الـ Git بيصنف أي ملف في فولدر مشروعك لـ حالتين كبار:
- **غير متتبع (Untracked):** ملف لسه مولود جديد، Git ميعرفش عنه حاجة ولا مهتم بيه.
- **متتبع (Tracked):** ملف دخل تحت رادار Git خلاص، وله 3 حالات فرعية:
  1. **غير معدل (Unmodified):** ملف مسجل في آخر commit ومحصلش فيه أي تغيير.
  2. **معدل (Modified):** ملف متتبع بس إنت غيرت فيه سطر أو حرف في الـ Working Tree ولسه ما جهزتوش.
  3. **محضر (Staged):** ملف معدل وإنت عملتله `git add` عشان يتحط في الـ commit الجاي.

فهمك للمخطط الانتقالي ده هو اللي بيخليك تدير مشروعك بكفاءة عالية وتمنع الكود من التداخل.

```
+---------------------------------------------------------------+
|                      File Lifecycle                           |
+---------------------------------------------------------------+
|                                                               |
|        [New File]                                             |
|            |                                                  |
|            v                                                  |
|       +------------+     git add      +----------+            |
|       | Untracked  | ---------------> |  Staged  |            |
|       +------------+                  +----------+            |
|                                             |                 |
|                                             | git commit      |
|                                             v                 |
|       +------------+   Edit File      +------------+          |
|       |  Modified  | <--------------- | Unmodified |          |
|       +------------+                  +------------+          |
|             |                                                 |
|             +-------------------------------->                |
|                        git add                                |
+---------------------------------------------------------------+
```

```bash
# Track the lifecycle step by step
touch new_feature.js # State: Untracked

git status -s
# Output: ?? new_feature.js

git add new_feature.js # State: Staged (Tracked)
git status -s
# Output: A  new_feature.js

git commit -m "feat: init new feature" # State: Unmodified
git status -s
# Output: (empty, clean working directory)

echo "// modification" >> new_feature.js # State: Modified
git status -s
# Output:  M new_feature.js
```

#### مثال 1: تعديل ملف محضر بالفعل
إنت شغال على ملف `auth.js` وعملتله `git add auth.js` لأنه جاهز. وقبل الـ commit افتكرت تعديل بسيط، فعدلته في نفس الملف وسيبته. دلوقتي الملف بقى Staged بالنسخة القديمة، و Modified بالنسخة الجديدة! لو عملت `git commit` من غير ما تعمل `git add` تاني، النسخة اللي هتتسيف هي النسخة اللي اتعملها add الأولانية بس والتعديل التاني هيضيع من الـ commit ده وهيفضل معلق برة.

#### مثال 2: إرجاع ملف لحالته الأصلية تماماً
عملت تعديلات في كود الـ `db.js` واكتشفت إن التعديلات دي خربت الدنيا وعايز تمسح كل تعديلاتك وترجع الملف لحالته النظيفة في آخر commit:
بتنفذ `git restore db.js` وبكده بيرجع الملف فوراً لحالة Unmodified وتتمسح التغييرات المحلية تماماً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Describe the lifecycle of a file in Git, and explain what happens when you modify a file that has already been staged but not yet committed."*
>
> **الإجابة المثالية:**
> تبدأ دورة حياة الملف كملف غير متتبع (Untracked) عند إنشائه، وعند تشغيل الأمر `git add` ينتقل الملف مباشرة إلى حالة المحضر (Staged) ويصبح متتبعاً. بعد عمل `git commit` ينتقل الملف إلى حالة غير المعدل (Unmodified) حيث يطابق آخر نسخة مسجلة. إذا قام المطور بالتعديل على الملف لاحقاً، ينتقل إلى حالة المعدل (Modified) محلياً في مجلد العمل، ويتطلب تشغيل `git add` مجدداً لإعادته لحالة الـ Staged تمهيداً للتسجيل القادم، ليعود بعد الـ commit إلى حالة الـ Unmodified وهكذا تستمر الدورة.

> [!tip] Checkpoint
> - ملف جديد = Untracked (??).
> - عملت add = Staged (A أو M).
> - عملت commit = Unmodified (نظيف).
> - عدلت فيه = Modified (M حمراء).

---

## Q12 — إزاي نستخدم git status و git diff عشان نفهم إيه اللي اتغير في ملفاتنا بالظبط؟

### أصل الحكاية
في InboxSales، أحمد كان شغال على كود الـ Express backend وعدل ملف `server.js` وملف `auth.js`.
لما كتب `git status` عشان يشوف إيه اللي حصل، الـ Git قاله إن الملفين دول `modified`. بس أحمد لسه ناسي هو عدل إيه بالظبط جوة ملف `auth.js`! هل مسح سطر؟ هل زود إعدادات جديدة؟ هل غير اسم متغير؟
هنا بييجي دور البطل الثاني: `git diff`.
الأمر `git status` بيديك نظرة عامة (High-level overview) عن حالة الملفات (مين متعدل ومين مش متتبع ومين جاهز). لكن `git diff` بيديك نظرة تفصيلية ميكروسكوبية (Line-by-line diff) عن السطور اللي اتعدلت أو اتحذفت أو اتضافت.
الـ Git بيقارن الكود الحالي في الـ Working Directory بالنسخة اللي موجودة في الـ Staging Area.
ولو أحمد عمل `git add auth.js` وحب يشوف التعديلات اللي جهزها، وجرب يكتب `git diff` عادي، هيلاقي الشاشة فاضية! وده لأن `git diff` الافتراضي بيقارن الـ Working Directory بالـ Staging Area، وبما إن أحمد نقل التعديلات للـ Staging Area خلاص، فمفيش فروقات بينهم. عشان كدة لازم يكتب `git diff --staged` أو `git diff --cached` عشان يقارن الـ Staging Area بآخر commit.

```bash
# Display short status to see flags quickly
git status -s
# Output:
#  M server.js       <- Red 'M': modified in working directory (unstaged)
# M  auth.js         <- Green 'M': modified and staged (ready for commit)
# ?? new_config.json <- Untracked file

# Show line-by-line changes for server.js (unstaged changes)
git diff server.js
# Output snippet:
# - const PORT = 3000;
# + const PORT = process.env.PORT || 5000;

# Show changes that are staged and ready to commit
git diff --staged
# Output snippet:
# - function login(user) {
# + function login(user, deviceMetadata) {

# Compare your working directory and staging area directly with last commit
git diff HEAD
```

#### مثال 1: فلترة الفروقات لملف واحد
أحمد شغال في مشروع كبير فيه 50 ملف متعدل، وعايز يشوف فروقات ملف `config/db.js` بس عشان يركز فيه. لو كتب `git diff` هيتغرق كود. الحل إنه يحدد المسار: `git diff config/db.js` وبكده Git هيعرضله فروقات الملف ده بس ويسيب الباقي.

#### مثال 2: إزاي تقارن كلمتين في نفس السطر بدل السطر كله؟
ساعات التعديل بيكون تغيير حرف أو كلمة واحدة في سطر طويل، والـ diff العادي بيجيب السطر كله ممسوح والسطر كله متضاف. أحمد بيستخدم عملية `--word-diff` عشان Git يوريله الكلمة اللي اتغيرت بالظبط بين أقواس:
`git diff --word-diff server.js`
ده بيسهل جداً مراجعة السطور الطويلة أو ملفات النصوص.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the difference between running `git diff` and `git diff --staged`, and when would you use each?"*
>
> **الإجابة المثالية:**
> الأمر `git diff` بدون أي وسيط يقارن التغييرات الموجودة في دليل العمل (Working Directory) مع تلك الموجودة في منطقة التحضير (Staging Area). نستخدمه لنرى ما قمنا بتعديله محلياً ولم نقم بتحضيره بعد. أما الأمر `git diff --staged` (أو المترادف له `git diff --cached`) فيقوم بمقارنة التغييرات المحضرة في الـ Staging Area مع آخر commit (HEAD). نستخدمه لمراجعة الكود الذي قمنا بعمل `git add` له والتأكد من أنه جاهز تماماً وبحالة صحيحة قبل كتابة الـ commit.

---

## Q13 — إيه الفرق بين git add . و git add -A و git add -p؟ وإمتى نستخدم كل واحد؟

### أصل الحكاية
في InboxSales، أحمد عدل كود في ملف `index.js` ومسح ملف قديم اسمه `legacy_helper.js` وعمل ملف جديد خالص اسمه `new_feature.js`.
لما جه يحضر شغله، كان محتار يكتب إيه. زمان في نسخ Git القديمة (قبل 2.0)، كان فيه فرق شاسع بين الأوامر دي؛ لكن دلوقتي الفروقات بقت بتعتمد أكتر على مكانك في الفولدر والـ interactive workflow.
- `git add .`: بيضيف كل الملفات الجديدة والمعدلة والممسوحة في المجلد الحالي (Current Directory) والمجلدات الفرعية اللي تحته بس. لو أحمد واقف جوة فولدر `src/controllers` وكتب `git add .` التعديلات اللي برة الفولدر ده (مثلاً في `public/`) مش هتتسجل!
- `git add -A` (أو `git add --all`): بيضيف كل التغييرات في المستودع بالكامل (Repository-wide) من أي مكان إنت واقف فيه، سواء ملفات جديدة، معدلة، أو ممسوحة.
- `git add -p` (أو `--patch`): ده بقى "الساحر" بتاع Git. ده بيسمحلك تراجع التعديلات تفصيلياً جزء جزء (Hunks) وتختار تضيف إيه للـ staging وتأجل إيه للـ commit اللي بعده.

```bash
# Stage everything in the current directory and below
git add .

# Stage every change in the entire repository regardless of where you are
git add -A

# Interactive staging: step-by-step review of changes
git add -p
# Git will display a hunk of code and ask:
# Stage this hunk? [y, n, q, a, d, j, J, g, /, e, ?]?
# y - yes (stage this hunk)
# n - no (do not stage this hunk)
# s - split (split the current hunk into smaller hunks if possible)
# e - edit (manually edit the current hunk)
# q - quit (exit interactive mode)
```

#### مثال 1: حل مشكلة "الكود المخلط"
أحمد كان شغال على ميزة تسجيل الدخول (Login)، وفي نفس الوقت لقى سطر كود فيه خرق أمني (Security bug) في ملف `auth.js` فعدله. لو عمل `git add auth.js` و commit واحد، الـ commit ده هيبقى شايل ميزتين ملهمش علاقة ببعض. أحمد استخدم `git add -p auth.js` واختار `y` للسطور الخاصة بحل الثغرة الأمنية، واختار `n` لسطور الـ Login. عمل commit للثغرة الأول باسم `fix: security vulnerability` وبعدين عمل add و commit لباقي الملف للـ Login. بكده الـ history فضل نظيف ومرتب.

#### مثال 2: الملفات الممسوحة في النسخ القديمة والحديثة
لو إنت شغال على سيرفر قديم عليه نسخة Git 1.x وعملت مسح لملف يدوي وجربت تعمل `git add .` هتتفاجأ إن الملف الممسوح لسه ظاهر في `git status` كـ deleted ومش staged! في النسخ القديمة كان لازم تستخدم `git add -A` عشان يلقط الحذف، أو تعمل `git rm`. أما في Git 2.0+، تم توحيد السلوك وبقى `git add .` بيلقط الملفات الممسوحة تلقائياً زي `-A`.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Imagine you made multiple unrelated changes in a single file: a bugfix and a refactor. How can you stage only the bugfix for the next commit while leaving the refactor unstaged?"*
>
> **الإجابة المثالية:**
> يمكن تحقيق ذلك باستخدام الأمر التفاعلي `git add -p` (أو `git add --patch`). يقوم هذا الأمر بتقسيم التعديلات داخل الملف الواحد إلى أجزاء صغيرة تسمى Hunks، ويعرضها Git على المطور جزءاً تلو الآخر. يمكنني حينها اختيار `y` (نعم) للجزء الذي يحتوي على حل المشكلة (Bugfix) ليتم نقله لمنطقة التحضير (Staging Area)، واختيار `n` (لا) للجزء الخاص بإعادة الهيكلة (Refactor) ليظل معلقاً في دليل العمل. إذا كان الجزءان متقاربين جداً، يمكنني الضغط على `s` لتقسيم الجزء إلى أجزاء أصغر، أو `e` لتعديل الجزء يدوياً وتحديد السطور المطلوبة بدقة.

---

## Q14 — إيه هي القواعد الذهبية لكتابة الـ Commit Message؟ وإيه هو نظام الـ Conventional Commits؟

### أصل الحكاية
في أول يوم لأحمد في InboxSales، عمل تعديل في ملف الـ `billing.js` وكتب في رسالة الـ commit: `fixed billing`.
التيك ليد رفض الـ Pull Request علطول وقاله: "إحنا هنا مش بنكتب مذكرات شخصية ولا ألغاز. الـ commit ده لو حصلت بسببه مشكلة في الإنتاج بعد شهرين، محدش هيعرف يقرأ الـ history ويفهم الـ commit ده كان بيعمل إيه بالظبط".
الـ Commit في Git هو وثيقة تاريخية للمشروع. لو رسائل الـ commits مبهدلة، الـ history بيفقد قيمته تماماً.
وعشان كدة التيمز المحترفة بتلتزم بـ **Conventional Commits** (الالتزامات القياسية)، وهو نظام بيوحد شكل الرسايل عشان تكون واضحة للبشر، وتقدر البرامج تقراها وتولد Changelog تلقائي وتحدد رقم الإصدار الجديد (Semantic Versioning).
الصيغة العامة للـ Conventional Commit هي:
`<type>(<scope>): <description>`

حيث الـ `type` بيعبر عن نوع التغيير:
- `feat`: ميزة جديدة بيستفيد منها المستخدم (Feature).
- `fix`: حل مشكلة أو bug في الكود (Bug fix).
- `docs`: تعديل في ملفات التوثيق فقط (Documentation) زي الـ `README.md`.
- `style`: تعديلات على التنسيق والـ formatting (مسافات، سيمي كولون) بدون تغيير في منطق الكود.
- `refactor`: تعديل في بنية الكود لتحسينه بدون إضافة ميزات جديدة أو حل مشاكل.
- `test`: إضافة اختبارات جديدة أو تعديل اختبارات قائمة.
- `chore`: تحديث مكتبات (Dependencies)، أو ملفات إعدادات الـ build والـ CI/CD.

```bash
# Good commit following Conventional Commits (type + scope + short desc)
git commit -m "feat(auth): add JWT token expiration validation"

# Multi-line commit for complex changes (Header + Blank Line + Body)
git commit -m "fix(billing): resolve Stripe webhook timeout issue

We noticed that when Stripe sends a payment success webhook, our database
write takes more than 5 seconds, causing a timeout. This commit adds an
asynchronous queue worker to handle the database write in the background."
```

#### مثال 1: قاعدة الـ 50/72 حرف
أحمد بيلتزم بحدود المساحة في رسايل الكوميت:
1. السطر الأول (العنوان) لا يزيد عن 50 حرف عشان يظهر كامل في واجهة GitHub والـ `git log --oneline`.
2. استخدام صيغة الأمر (Imperative mood) في السطر الأول. يعني تكتب: `fix: handle null token` مش `fixed null token` ولا `fixes null token`.
3. سطر فاضي كامل بعد العنوان.
4. متن الرسالة (Body) لا يزيد طول السطر فيه عن 72 حرف عشان يكون مريح في القراءة في أي Terminal.

#### مثال 2: استخدام الـ Commit Templates
عشان التيم كله يلتزم بنفس النظام، التيك ليد عمل ملف template اسمه `.gitmessage` وكتب فيه هيكل الرسالة المطلوبة، وخلى Git يستخدمه تلقائياً عند كتابة أي commit:
`git config --global commit.template ~/.gitmessage`
دلوقتي لما أحمد يكتب `git commit` من غير `-m`، بيتفتحله الـ editor والـ template مكتوب قدامه كـ تعليقات يفكره بالخطوات.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What are the principles of a good commit message, and why is the imperative mood preferred in the summary line?"*
>
> **الإجابة المثالية:**
> الرسالة الجيدة للملفات المسجلة يجب أن تبدأ بسطر عنوان قصير وموجز (لا يتعدى 50 حرفاً) مكتوب بصيغة الأمر (Imperative mood)، يليه سطر فارغ، ثم متن تفصيلي يشرح "لماذا" تم التغيير وليس "ماذا" تم، لأن الكود نفسه يوضح ماذا تغير. تُفضل صيغة الأمر (مثال: `Add authorization middleware` بدلاً من `Added...`) لأنها تطابق الطريقة التي يولد بها Git نفسه رسائله التلقائية (مثل: `Merge branch...` أو `Revert...`). السطر الأول يصف فعلياً ما سيفعله هذا الـ commit عند تطبيقه على المشروع.

---

## Q15 — إزاي نعدل في آخر commit عملناه بـ git commit --amend؟ وإيه خطورته لو اترفع؟

### أصل الحكاية
أحمد عمل commit وكتب الرسالة: `feat: add database connection`. وبعد ما داس Enter وجرب الكود، افتكر إنه نسي يضيف ملف الـ `.env.example` في الـ staging، أو لقى غلطة إملائية (Typo) في كلمة جوة الرسالة.
لو أحمد عمل commit جديد عشان يحل الغلطة دي، الـ history هيبقى شكله مبهدل:
`commit 1: feat: add database connection`
`commit 2: fix typo in config`
ده تصرف غير احترافي. الحل هنا هو استخدام الأمر السحري `git commit --amend`.
الأمر ده بياخد أي تعديلات واقفة في الـ Staging Area حالياً ويدمجها مباشرة جوة **آخر commit** اتعمل، ويخليك تعدل الرسالة كمان. كأن الكوميت القديم اتمسح وحل محله الكوميت الجديد بالتعديلات الجديدة.
لكن، انتبه! تحت الغطاء, الـ `amend` مش بيعدل الكوميت الأصلي فعلياً في قاعدة البيانات؛ هو بيخلق كوميت جديد تماماً بـ SHA-1 Hash مختلف، ويحرك مؤشر الفرع عليه، ويسيب الكوميت القديم معلق في الهوا (Dangling).
وهنا بتكمن خطورته الكبرى لو الكوميت الأصلي كان اترفع (Pushed) للسيرفر المشترك.

```bash
# Scenario: Forget to add a file to the last commit
# 1. Stage the forgotten file
git add config/db.template.js

# 2. Amend the last commit without changing its message
git commit --amend --no-edit
# Output: [main 9f3e4b1] feat: add database connection
# Note that the commit hash changed from the previous one!

# Scenario: Just want to fix the commit message of the last commit
git commit --amend -m "feat(database): initialize connection pool"
```

#### مثال 1: الكارثة الجماعية (Force Push Conflict)
أحمد عمل commit ورفعه على فرع `main` المشترك بـ `git push`. زميله شادي عمل `git pull` وبدأ يكتب كود فوق الكوميت ده.
أحمد اكتشف غلطة في الكوميت فعمل `git commit --amend` ورفع الكوميت الجديد بـ `git push --force`.
لما شادي ييجي يرفع شغله، الـ Git هيرفض تماماً وهيقوله إن الـ history متضارب (Divergent history). شادي هيضطر يحل Conflict وهمي ناتج عن إن أحمد غير ماضي الكوميت اللي شادي كان بيبني عليه! عشان كدة القاعدة الذهبية: **لا تعدل كوميت تم رفعه ومشاركته مع الآخرين أبداً**.

#### مثال 2: استخدام الـ Amend لتنظيف الـ local branches
طالما أحمد شغال على جهازه محلياً في فرع منفصل ومحدش معاه فيه، يقدر يعمل `--amend` براحته 50 مرة في اليوم عشان يخلي الكوميتس نظيفة ومركزة قبل ما يعمل الـ Pull Request النهائي. في الحالة دي الـ force push لفرعه الخاص مقبول لأنه الوحيد اللي شغال عليه.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What happens under the hood when you run `git commit --amend`, and why is it dangerous to amend a commit that has already been pushed to a remote repository?"*
>
> **الإجابة المثالية:**
> تحت الغطاء، لا يقوم Git بتعديل الكومة (Commit) الحالية، بل يقوم بإنشاء كائن تسجيل جديد تماماً (New Commit Object) يحتوي على التغييرات الجديدة والقديمة معاً، ويمنحه معرف Hash جديد، ثم يقوم بتحريك مؤشر الفرع الحالي ليشير إليه، تاركاً التسجيل القديم معلقاً ليتم التخلص منه لاحقاً بواسطة الـ Garbage Collector. تعديل تسجيل تم رفعه بالفعل (Pushed) خطير جداً لأنه يعيد كتابة التاريخ؛ وإذا كان هناك مطورون آخرون قد بنوا عملهم على التسجيل القديم، فسيؤدي ذلك إلى تعارض وتكرار في التاريخ عند قيامهم بالسحب والدمج، مما يضطرنا لعمل Force Push قد يدمر أو يلغي تعديلات زملائنا.

---

## Q16 — إزاي نعمل فلترة وعرض احترافي للـ History باستخدام git log؟

### أصل الحكاية
المشروع في InboxSales بقاله سنتين شغال، وجوا الـ Repository فيه أكتر من 5,000 commit.
التيك ليد دخل على أحمد وقاله: "فيه مشكلة حسابية ظهرت في حساب الفواتير، وعايزين نعرف مين الـ commit اللي عدل ملف الـ `billing.js` في شهر مايو اللي فات، وبحثنا في الـ commits العادية وتعبنا".
لو أحمد كتب `git log` وسكت، هيدخل في دوامة لا تنتهي من الصفحات وهيقعد يدوس Space لحد الصبح.
الـ Git كقاعدة بيانات تاريخية بيوفر محرك بحث وفلترة قوي جداً جوة الـ Terminal. تقدر تفلتر بالوقت، بالمطور، بالملف، بل وبمحتوى التعديل نفسه!

```bash
# 1. The ultimate clean visual log (One-line per commit, with branch tree structure)
git log --oneline --graph --all --decorate

# 2. Filter commits by a specific author
git log --author="Ahmad Backend"

# 3. Filter commits by a specific date range
git log --since="2026-05-01" --until="2026-05-31"

# 4. Search commit messages for a specific keyword
git log --grep="Stripe"

# 5. Show only commits that modified a specific file
git log -- follow src/services/billing.js

# 6. The Pickaxe search: find commits where a specific string was added or removed in the code
git log -S "STRIPE_API_SECRET_KEY" -p
```

#### مثال 1: تتبع التغييرات لـ Function معينة (Function History)
أحمد عايز يعرف تاريخ تعديل دالة `calculateTax` جوة ملف `tax.js` بس، مش عايز يشوف أي تعديلات تانية في الملف. Git ذكي كفاية إنه يقدر يبحث بالـ Syntax:
`git log -L :calculateTax:src/utils/tax.js`
الأمر ده هيطلعله فقط الكوميتس والسطور اللي عدلت الدالة دي تحديداً على مر تاريخ المشروع!

#### مثال 2: البحث عن الكوميتس الضائعة (Reflog log)
ساعات أحمد بيعمل commit ويمسحه بالخطأ أو يرجع عنه بـ `git reset --hard`. الكوميت ده مش هيظهر في الـ `git log` العادي لأن مؤشر الفرع اتحرك بعيد عنه. عشان يلاقيه، بيستخدم:
`git log -g` (المعروف بـ `git reflog`)
ده بيعرض سجل تحركات مؤشر الـ HEAD بالكامل، ومنه بيقدر يسترجع الـ Hash بتاع الكوميت المحذوف ويرجعه للحياة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"How would you find a commit that introduced a specific string (e.g., an API key or configuration value) in the codebase, even if the file was deleted or moved?"*
>
> **الإجابة المثالية:**
> يمكنني استخدام خيار البحث المتقدم في Git المعروف باسم الـ Pickaxe عبر الأمر `git log -S "<string>"` ومعه الخيار `-p` لعرض الفروقات (Patches). هذا الأمر يبحث في كامل تاريخ المستودع عن اللحظات التي تغير فيها عدد مرات ظهور هذه السلسلة النصية (إضافة أو حذفاً) في محتوى الملفات، وليس فقط في رسائل الكوميت. وإذا تم نقل الملف أو تغيير مساره، يمكنني إضافة خيار `--follow` للتأكد من تتبع الملف عبر الأسماء المختلفة التي اتخذها تاريخياً.

---

## Q17 — إيه الفرق بين git restore و git checkout في التراجع عن التعديلات؟ وإيه حكاية التحديثات الجديدة؟

### أصل الحكاية
زمان، كان فيه أمر في Git اسمه `git checkout`. الأمر ده كان عامل زي "الجوكر" أو السويسري اللي بيعمل كل حاجة:
- عايز تروح لفرع تاني؟ `git checkout feature-branch`
- عايز تعمل فرع جديد وتروحله؟ `git checkout -b new-branch`
- عايز تتراجع عن تعديلات في ملف وترجعه لأصله؟ `git checkout -- config.js`
اللخبطة دي خلت مجتمع Git يشتكي من إن الأمر واحد بس وممكن يعمل كوارث لو كتبت بارامتر غلط (بدل ما تمسح تعديلات ملف، تلاقي نفسك غيرت الفرع!).
عشان كدة، بداية من نسخة Git 2.23 (سنة 2019)، قرر مطورو Git تقسيم المهام دي على أمرين جداد واضحين ومحددين:
1. `git switch`: للتنقل بين الفروع وإنشائها فقط.
2. `git restore`: للتراجع عن التعديلات واستعادة الملفات فقط.
الأمر `checkout` لسه شغال عشان التوافق مع النسخ القديمة (Backward compatibility)، بس في الإنترفيوهات وفي بيئة العمل الحديثة، يفضل جداً استخدام الأدوات الجديدة لأنها بتعبر عن نيتك بوضوح وتمنع الأخطاء.

```bash
# OLD WAY: Discard unstaged changes in a file
git checkout -- src/app.js

# NEW WAY (Git 2.23+): Discard unstaged changes in a file
git restore src/app.js

# OLD WAY: Unstage a file (remove it from Staging Area to Working Directory)
git reset HEAD src/app.js

# NEW WAY (Git 2.23+): Unstage a file
git restore --staged src/app.js

# Restore a file to its state from 3 commits ago
git restore --source=HEAD~3 src/app.js
```

#### مثال 1: إنقاذ ملفات العمل بالكامل
أحمد خرب الدنيا في مجلق `controllers` بالكامل وعايز يمسح كل التعديلات اللي محصلهاش staging ويرجع الفولدر للحالة النظيفة اللي كان عليها في آخر commit. بيكتب:
`git restore controllers/`
بضغطة زرار واحدة، كل الملفات جوة الفولدر ده بترجع لحالتها النظيفة تماماً.

#### مثال 2: سحب نسخة ملف من فرع تاني
أحمد شغال في فرع الـ `feature` ومحتاج يشوف ملف الـ `schema.sql` كان شكله إيه في فرع الـ `main` ويجيبه عنده في الـ working tree عشان يقارن. بيستخدم الـ `--source`:
`git restore --source=main src/db/schema.sql`
ده بياخد محتوى الملف من الفرع التاني وينسخه فوراً في جهازه للتعديل عليه.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Why did Git introduce `git restore` and `git switch` to replace parts of `git checkout`, and what is the difference between `git restore <file>` and `git restore --staged <file>`?"*
>
> **الإجابة المثالية:**
> تم تقديم `git restore` و `git switch` لحل مشكلة تداخل المسؤوليات في الأمر القديم `git checkout` والذي كان يستخدم لتبديل الفروع واستعادة الملفات معاً، مما سبب ارتباكاً وأخطاءً للمطورين.
> الفرق بين خيارات الاستعادة:
> - الأمر `git restore <file>`: يقوم بإلغاء التغييرات غير المحضرة في دليل العمل (Working Directory) وجعل الملف يطابق النسخة الموجودة في منطقة التحضير (أو آخر commit إن لم يكن هناك staging).
> - الأمر `git restore --staged <file>`: يقوم بإزالة الملف من منطقة التحضير (Staging Area) وإعادته إلى دليل العمل كملف معدل ولكن غير محضر، دون خسارة التعديلات البرمجية التي تمت كتابتها داخل الملف.

---

## Q18 — يعني إيه git stash؟ وإزاي نستخدمه لحفظ الشغل المؤقت من غير ما نعمل commit؟

### أصل الحكاية
أحمد شغال بقاله 4 ساعات على ميزة معقدة جداً لتوليد تقارير المبيعات في فرع `feature/reports`. الكود متبهدل، فيه ملفات ناقصة، و tests بتفشل، ومفيش أي حاجة تنفع يتعملها commit نظيف.
فجأة، رن جرس الإنذار في شركة InboxSales! فيه ثغرة أمنية خطيرة في الـ Production (على فرع `main`) ولازم أحمد يدخل يعمل Hotfix حالاً.
أحمد محتاج يروح لفرع `main` بـ `git switch main`؛ بس الـ Git هيرفض ويطلعله رسالة حمراء مرعبة:
`error: Your local changes to the following files would be overwritten by checkout... Please commit your changes or stash them before you switch branches.`
لو أحمد عمل commit للكود المبهدل ده عشان يغير الفرع بس، هيوسخ سجل المشروع (Commit History) برسائل ملهاش لازمة زي `wip` أو `temp`.
هنا بييجي دور الـ **Stash** (الدرج السري).
بأمر واحد، الـ Git بياخد كل التغييرات المعلقة (سواء staged أو unstaged) ويحفظها في درج مؤقت على جنب، ويرجع الـ Working Directory لحالة نظيفة تماماً كأن أحمد ملمسش الكود.
دلوقتي يقدر أحمد يروح يحل الـ bug في `main` ويرفعها، ويرجع لفرع التقارير، ويفتح الدرج ويطلع شغله ويكمل من مكان ما وقف!

```bash
# 1. Save all tracked changes to the stash with a descriptive message
git stash save "WIP: half-done sales pdf generation"
# Alternative syntax in modern Git:
git stash push -m "WIP: half-done sales pdf generation"

# 2. List all items currently saved in your stash list
git stash list
# Output: stash@{0}: On feature/reports: WIP: half-done sales pdf generation

# 3. Apply the changes from stash and KEEP them in the stash storage
git stash apply stash@{0}

# 4. Apply the changes and REMOVE them from the stash storage (Most common)
git stash pop

# 5. Stash including untracked files (crucial, otherwise new files are left behind!)
git stash -u # or --include-untracked

# 6. Delete all stashed items
git stash clear
```

#### مثال 1: فخ الملفات الجديدة (Untracked Files)
أحمد عمل ملف جديد اسمه `new_helper.js` وعدل ملف `index.js`. كتب `git stash` وغير الفرع. لما رجع، لقى ملف `new_helper.js` لسه واقف مكانه برة الـ stash!
وده لأن الـ Stash الافتراضي بيشيل الملفات الـ Tracked بس. عشان يشيل الملفات الجديدة اللي لسه معملهاش `git add` خالص، كان لازم يكتب `git stash -u` (شامل الـ untracked) أو `git stash -a` (شامل كل شيء حتى الملفات المتجاهلة في `.gitignore`).

#### مثال 2: فض الاشتباك بعد استرجاع الشغل (Stash Conflict)
أحمد عمل stash لشغله، وراح حل الـ bug في `main`. التعديل بتاع الـ bug عدل نفس السطور اللي أحمد شغال عليها في فرع التقرير. لما رجع أحمد وكتب `git stash pop` حصل Conflict!
الـ Git ذكي: مش هيمسح الـ stash من الدرج هيفضل محتفظ بيه كـ safety net. أحمد بيحل الـ conflict يدوي، وبعد ما يتأكد إن الكود سليم، بيمسح الـ stash يدوياً بـ `git stash drop`.

### الفايدة الانترفيوية
> **Interview Question:**
> *"How does `git stash` work, how do you include untracked files in a stash, and what is the difference between `git stash pop` and `git stash apply`?"*
>
> **الإجابة المثالية:**
> الـ `git stash` يأخذ التغييرات الحالية في دليل العمل ومنطقة التحضير ويحفظها مؤقتاً في هيكل بيانات (Stack) خاص بـ Git، ليعود دليل العمل نظيفاً تماماً. لتضمين الملفات غير المتتبعة (Untracked Files)، يجب استخدام الخيار `-u` أو `--include-untracked`.
> الفرق بين الاسترجاع:
> - `git stash apply`: يطبق التغييرات المحفوظة على فرعك الحالي ولكنه يحافظ على نسخة التغييرات داخل مستودع الـ stash دون مسحها (مفيد لو أردت تطبيق نفس التغييرات على فروع متعددة).
> - `git stash pop`: يطبق التغييرات على فرعك الحالي ويقوم فوراً بحذفها (Drop) من مستودع الـ stash لتنظيف الذاكرة المؤقتة.

---

## Q19 — إيه الفرق بين git rm و git mv؟ وإزاي الـ Git بيكتشف إعادة تسمية الملفات تلقائياً؟

### أصل الحكاية
أحمد عايز ينظف الكود في InboxSales؛ فقرر يمسح ملف `old_tracker.js` وينقل ملف الـ `auth_v1.js` لفولدر جديد ويغير اسمه لـ `auth.js`.
لو أحمد عمل التعديلات دي يدوي من نافذة الـ VS Code أو الـ File Explorer:
1. الـ Git هيشوف ملف `old_tracker.js` كـ `deleted` بس غير محضر (unstaged). هيضطر أحمد يكتب `git add old_tracker.js` عشان ينقل الحذف للـ staging.
2. الـ Git هيشوف ملف الـ `auth.js` كملف جديد تماماً (Untracked)، وهيفتكر إن `auth_v1.js` اتمسح. بكده أحمد خسر تاريخ الكوميتس (Commit History) القديم بتاع الملف ده على GitHub؛ هيظهر في الـ PR كأن أحمد مسح 500 سطر وكتب 500 سطر جداد، مش كأنه مجرد نقل وتغيير اسم!
لتفادي ده، Git بيوفر أمرين سهلين: `git rm` للحذف، و `git mv` للنقل وإعادة التسمية.

```bash
# Delete file from disk and stage the deletion in one step
git rm src/old_tracker.js

# Rename/move file on disk and stage the change in one step
git mv src/auth_v1.js src/services/auth.js

# See how Git displays the status
git status
# Output:
# Rename: src/auth_v1.js -> src/services/auth.js (100% match)
```

#### مثال 1: الحذف من التتبع مع الحفاظ على الملف محلياً
أحمد كتب باسوراد في ملف `local_config.json` وعايز يشيله من الـ Git نهائي بس يسيبه على جهازه عشان الأبلكيشن يشتغل. لو كتب `git rm` الملف هيتمسح من الكمبيوتر. الحل هو:
`git rm --cached local_config.json`
ده بيشيل الملف من الـ Staging Area ونظام التتبع، وبيسيبه سليم على القرص الصلب.

#### مثال 2: إزاي Git بيكتشف الـ Rename سحرياً؟
تحت الغطاء، الـ Git **مبيخزنش** أي معلومات عن عملية "إعادة التسمية" كأكشن منفصل! قاعدة بيانات Git بتخزن ملفات كاملة (Blobs). لما أحمد يغير اسم ملف، Git بيسجل إن فيه Blob اتمسح وفيه Blob جديد اتعمل.
عند تشغيل `git status` أو `git diff`، بيشتغل محرك الكشف التلقائي (Rename Detection Engine). بيقارن الـ Hash والمحتوى بتاع الملف الممسوح بالملف الجديد. لو لقى تطابق في المحتوى (مثلاً بنسبة 50% أو أكتر)، الـ Git بيقرر يعرضه في الشاشة كـ `renamed` عشان يسهل القراءة، ويحافظ على ربط الـ history تلقائياً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"How does Git track file renames, and what happens when you rename a file using the operating system's file manager versus using `git mv`?"*
>
> **الإجابة المثالية:**
> لا يقوم Git بتسجيل أو تتبع عمليات إعادة التسمية (Renames) بشكل صريح في قاعدة بياناته؛ بل يعتمد على آلية ديناميكية تسمى Rename Detection أثناء العرض. إذا قمنا بتغيير الاسم عبر مدير ملفات النظام، سيعتبرها Git عمليتين منفصلتين: حذف للملف القديم وإضافة لملف جديد غير متتبع، وسيتطلب الأمر منا إضافتهما يدوياً للمرحلة (Staging). أما استخدام `git mv` فيقوم بتحديث الملف على القرص وتسجيل الحذف والإضافة معاً في منطقة التحضير في خطوة واحدة. في الحالتين، عند قراءة التاريخ، يقارن Git محتويات الملفات المحذوفة والمضافة، وإذا تجاوز التشابه حداً معيناً (عادة 50%) يعرضها كعملية إعادة تسمية تلقائياً.

---

## Q20 — إزاي الـ Git بيتعامل مع أذونات الملفات (File Permissions)؟ وإيه هو الـ core.filemode؟

### أصل الحكاية
في InboxSales، أحمد كتب Script بلغة Bash لتسهيل الـ deployment وسماه `deploy.sh`. ولأنه شغال على جهاز لينكس (Linux)، كتب في الـ Terminal:
`chmod +x deploy.sh` عشان يخليه قابل للتنفيذ كـ برنامج.
لما رفع الملف وزميله شادي سحبه على جهاز ويندوز، ورجع رفعه تاني، لقى الـ Git بيقول إن فيه تغيير في ملف `deploy.sh` رغم إن شادي مغيرش حرف واحد في الكود!
المشكلة دي بتحصل لأن أنظمة التشغيل بتدير صلاحيات الملفات بطرق مختلفة تماماً.
الـ Git مصمم عشان يشتغل عبر كل الأنظمة؛ وعشان كدة هو **مبيحتفظش** بكل صلاحيات الملفات المعقدة (زي مين يقرأ ومين يكتب في نظام Linux). الـ Git بيركز في الـ Metadata بتاعته على حاجة واحدة بس:
هل الملف ده عادي (Regular File) ولا قابل للتنفيذ (Executable File)؟
بيترجم ده لنظام أرقام الـ Unix File Mode (الـ Mode bits):
- `100644`: ملف عادي غير قابل للتنفيذ.
- `100755`: ملف قابل للتنفيذ (Executable).
لو شادي على ويندوز، نظام الويندوز ميعرفش الـ executable bit دي، فممكن المحرر بتاعه يغير الـ metadata دي بالخطأ ويرفع الملف كـ `100644`.

```bash
# Check the file mode tracked by Git for a file
git ls-files --stage
# Output:
# 100755 e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 0 deploy.sh
# ^^^^^^
# Note the octal file mode (100755 means executable)

# If Windows setup is messing up file permissions, turn off filemode tracking locally:
git config core.filemode false

# Manually change the file mode in Git tracking database without changing the OS permissions
git update-index --chmod=+x deploy.sh
# To remove execution permission:
git update-index --chmod=-x deploy.sh
```

#### مثال 1: حل مشكلة التعديلات الوهمية في ويندوز
شادي شغال على ويندوز وكل ما يعمل `git status` يلاقي ملفات كتير متعدلة، ولما يعمل `git diff` يلاقي الفروقات فاضية أو يظهر تغيير في الـ mode بس:
`old mode 100755`
`new mode 100644`
التيك ليد قاله اكتب الأمر ده في جهازك عشان نلغي مراقبة الصلاحيات محلياً:
`git config --global core.filemode false`
بكده الـ Git هيتجاهل الاختلافات دي ويركز في محتوى الملفات بس.

#### مثال 2: إزاي تخلي Script Executable من على ويندوز؟
شادي عمل script على ويندوز وعايز يتأكد إنه لما يترفع على سيرفر الإنتاج (لينكس) ينزل وهو Executable وجاهز للتشغيل مباشرة من غير ما نضطر نعمل `chmod` على السيرفر. شادي بينفذ الأمر ده محلياً:
`git update-index --chmod=+x build.sh`
ثم بيعمل commit ويرفعه. السيرفر لما يسحبه هيلاقيه نازل بوضع `100755` مباشرة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"How does Git track file permissions across different operating systems like Windows and Linux, and what does the configuration `core.filemode` do?"*
>
> **الإجابة المثالية:**
> لا يقوم Git بتخزين صلاحيات الملفات الكاملة (POSIX permissions) بل يخزن فقط علامة تشير إلى ما إذا كان الملف قابلاً للتنفيذ (Executable) بوضع `100755` أو ملفاً عادياً بوضع `100644`.
> الخيار `core.filemode` يحدد ما إذا كان Git سيراقب ويسجل التغييرات في صلاحية التنفيذ هذه داخل مجلد العمل. في بيئات المطورين المختلطة (ويندوز ولينكس)، يفضل تعطيل هذا الخيار عبر ضبطه على `false` لمنع حدوث تعديلات وهمية ناتجة عن عدم دعم نظام ملفات ويندوز للـ Executable bit بشكل متطابق مع أنظمة Unix.

---

## Q21 — يعني إيه `.gitattributes`؟ وإزاي بيحميك من خناقات سطور ويندوز ولينكس (LF vs CRLF)؟

### أصل الحكاية
في InboxSales، أحمد (شغال لينكس) وشادي (شغال ويندوز) شغالين على نفس ملف الـ `settings.json`.
كل ما أحمد يسحب شغل شادي، بيلاقي الـ Git كاتب إن الملف كله اتعدل بالكامل، وكل السطور متعلمة باللون الأحمر كأنها اتمسحت واتكتبت من جديد.
الخناقة التاريخية دي سببها نهايات السطور (Line Endings):
- أنظمة ويندوز بتنهي السطور بـ `CRLF` (Carriage Return + Line Feed) وتكتب `\r\n`.
- أنظمة لينكس وماك بتنهي السطور بـ `LF` (Line Feed) وتكتب `\n`.
لما شادي بيحفظ الملف على ويندوز، المحرر بتاعه بيحط `\r\n`. ولما أحمد يفتحه على لينكس، الـ Git بيشوف الـ `\r` كحرف غريب إضافي في نهاية كل سطر، فيعتبر السطر كله اتغير!
الحل الجذري للموضوع ده هو ملف إعدادات على مستوى البروجكت اسمه `.gitattributes`.
الملف ده بيتحط في جذر المشروع (Root) وبيترفع مع الكود عشان يجبر الـ Git على جهازه وجهاز شادي وجهاز السيرفر إنه يتعامل بنظام موحد لنهايات السطور، وكمان بيعرف الـ Git مين الملفات النصية ومين الملفات الـ Binary عشان يحميها من التخريب.

```text
# Content of .gitattributes file

# Set default behavior to automatically normalize line endings
* text=auto

# Explicitly declare text files that should always be normalized to LF on checkout (Linux style)
*.js text eol=lf
*.json text eol=lf
*.html text eol=lf

# Explicitly declare files that should always keep CRLF (Windows style, e.g. batch scripts)
*.bat text eol=crlf

# Declare binary files (Git will never try to modify their line endings or diff them as text)
*.png binary
*.jpg binary
*.zip binary
```

```bash
# How to force Git to re-normalize the entire repository after creating .gitattributes
# 1. Clean the index
git rm --cached -r .

# 2. Rewrite the index and working tree to match the new rules
git reset --hard
```

#### مثال 1: فخ تخريب الصور والملفات المضغوطة
شادي لقى صور المشروع باظت ومش بتفتح بعد ما اترفت على GitHub. السبب إن الـ Git افتكر الصور دي ملفات نصية (لأن معندهاش امتداد واضح أو الإعدادات بايظة) وجرب يعمل تحويل للسطور جواها ومسح بعض علامات الـ `\r` اللي هي جزء أصلي من كود الصورة الثنائي. عشان نمنع الكارثة دي، أحمد فتح `.gitattributes` وكتب:
`*.png binary`
كلمة `binary` بتعني باختصار: "يا Git، إياك تلمس نهايات السطور هنا، ومتحاولش تعمل diff للمحتوى ده كـ نص".

#### مثال 2: إعداد الـ autocrlf المحلي (كحل فردي بديل)
لو البروجكت معندوش ملف `.gitattributes` حالياً، شادي على جهازه الويندوز لازم يظبط الكنفج ده محلياً عشان Git يحول الـ LF لـ CRLF عند التعديل، ويرجعها لـ LF وهو بيرفع (Normalization):
`git config --global core.autocrlf true`
بينما أحمد على لينكس بيظبطها:
`git config --global core.autocrlf input` (عشان يحول فقط عند الرفع وميغيرش حاجة محلياً).
لكن يظل وجود `.gitattributes` في المشروع هو الحل الأكثر أماناً لأنه بيفرض النظام على الجميع بالتساوي.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the purpose of the `.gitattributes` file, and how does it help prevent issues related to line endings (LF vs. CRLF) in cross-platform development teams?"*
>
> **الإجابة المثالية:**
> ملف `.gitattributes` هو ملف تكوين يُحفظ في جذر المستودع لتحديد خصائص معينة لكل مسار أو نوع ملف بشكل مركزي ومشارك. من أهم وظائفه حل مشكلة تعارض نهايات السطور (LF/CRLF) بين أنظمة التشغيل المختلفة. عبر إضافة قواعد مثل `* text=auto` و `*.js text eol=lf`، نقوم بإلزام Git بتهيئة نهايات السطور تلقائياً إلى المعيار الموحد (LF) عند إرسال الكود للمستودع (Commit)، وتحويلها يدوياً للنظام المحلي المناسب عند السحب (Checkout)، مما يمنع ظهور تغييرات وهمية لكامل أسطر الملفات ويحمي الملفات الثنائية (Binary) مثل الصور من التلف البرمجي.

> [!tip] Checkpoint
> بكدة نكون قفلنا أساسيات العمل اليومي (Topic 2). دلوقتي إنت فاهم إزاي الكود بيتحرك من الكيبورد للـ staging وللـ commit، وإزاي تفلتر تاريخ المشروع وتتحكم في تفاصيل نهايات السطور وأذونات الملفات زي المحترفين. يلا بينا ندخل في الغريق ونشوف الـ **Branching**!

---

# 🌿 Topic 3: Branching (الفروع والدمج)

## Q22 — هو الـ Branch في Git عبارة عن إيه تحت الغطاء؟ وليه عمل الـ branches سريع وجس نبض في Git مقارنة بأنظمة تانية؟

### أصل الحكاية
في شركة "InboxSales"، لما بتحب تعمل ميزة جديدة مش بتعدل في الكود الرئيسي علطول عشان متبوظش الدنيا للناس التانية. بتعمل فرع (Branch) جديد. في الأنظمة القديمة زي SVN مثلاً، عشان تعمل branch جديد كان السيرفر بياخد نسخة كاملة وفيزيائية من كل ملفات المشروع ويكررها في فولدر تاني، وده كان بياخد وقت كبير ومساحة ضخمة. 
في Git الموضوع مختلف تماماً. الـ Branch في Git تحت الغطاء مش فولدر ولا كود متكرر؛ هو حرفياً عبارة عن **ملف نصي صغير جداً ومخفي (Pointer)** مساحته 41 بايت بس! 

الملف ده جواه سطر واحد فيه الـ SHA-1 Hash بتاع الـ Commit اللي واقف عليه الفرع دلوقتي. لما بتعمل branch جديد، كل اللي Git بيعمله هو إنه بيكتب ملف نصي جديد جواه نفس الـ Hash بتاع الـ Commit اللي إنت واقف عليه حالياً. العملية دي بتاخد جزء من الثانية (O(1) time complexity) ومش بتستهلك أي مساحة تذكر على جهازك.

```bash
# Create a new branch named 'feature-auth'
git branch feature-auth

# View where the branch points under the hood
cat .git/refs/heads/feature-auth
# Output: 4c3d2e1b8f4a3c220f11904db3584860b0ffde18 (Points directly to the commit hash)

# View the current branch we are on
cat .git/HEAD
# Output: ref: refs/heads/main
```

#### مثال 1: المساحة التخزينية لـ 100 فرع
أحمد عمل 100 فرع تجريبي في نفس اليوم عشان يجرب أفكار مختلفة. المساحة المستهلكة في الـ Repo زادت قد إيه؟ تقريباً 4 كيلوبايت بس! لأن كل فرع هو مجرد ملف نصي فيه سطر واحد بيشير لكوميت موجود بالفعل. مفيش أي تكرار للملفات على الهارد ديسك.

#### مثال 2: سرعة إنشاء الفرع في المشاريع المليونية
في مشروع ضخم فيه ملايين السطور وصور وملفات بجيجابايتس، عمل فرع جديد بياخد نفس الوقت بالظبط اللي بياخده مشروع فيه سطرين كود (أقل من ملي ثانية)، لأن العملية مش نسخ ملفات، بل هي مجرد كتابة مؤشر جديد يشير لآخر لقطة (Snapshot).

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain how Git implements branches under the hood and why this design makes branching in Git much faster and cheaper compared to older version control systems."*
>
> **الإجابة المثالية:**
> تحت الغطاء، الفرع (Branch) في Git ليس مجرد نسخة مكررة من الملفات أو المجلدات، بل هو مجرد مؤشر خفيف الوزن (Lightweight Pointer) يحتوي على الـ SHA-1 Hash الخاص بالـ Commit الأحدث في هذا الفرع. يتم تخزين هذا المؤشر في ملف نصي بسيط مساحته 41 بايت داخل المسار `.git/refs/heads/`. في المقابل، كانت الأنظمة القديمة (مثل SVN) تقوم بنسخ كامل ملفات المشروع مادية لتكوين فرع جديد، مما يستهلك مساحة ووقت تشغيل طويلين. تصميم Git يجعل إنشاء الفرع عملية سريعة للغاية بتكلفة زمنية ثابتة O(1) ومساحة شبه معدومة، لأنها لا تتعدى إنشاء ملف نصي صغير يشير إلى كائن تسجيل موجود مسبقاً.

---

## Q23 — إزاي بنعمل ونعرض وننقل ونمسح الـ Branches؟ وإيه الفرق بين git checkout و git switch؟

### أصل الحكاية
في InboxSales، أحمد كان واقف في فرع `main` وعايز يعمل ميزة جديدة لتنسيق الفواتير. كتب `git branch feature-invoice` عشان يعمل الفرع. بس لما بدأ يعدل لقى نفسه لسه شغال في فرع `main`! وده لأن عمل الفرع مش معناه الانتقال إليه تلقائياً. 

عشان يتنقل للفرع الجديد، كان زمان بيستخدم `git checkout feature-invoice`. بس زي ما عرفنا، الـ checkout بيعمل مهام كتير متداخلة وساعات بتلخبط المطورين. عشان كدة تم إدخال الأمر `git switch` ليكون مخصصاً بالكامل لإدارة التنقل بين الفروع فقط.

```bash
# List all local branches (the current one has an asterisk '*')
git branch
# Output:
# * main
#   feature-invoice

# List both local and remote-tracking branches
git branch -a

# Create and switch to a new branch in one command (Modern Way)
git switch -c feature-invoice
# Output: Switched to a new branch 'feature-invoice'

# OLD WAY to create and switch:
# git checkout -b feature-invoice

# Switch back to the main branch
git switch main
```

#### مثال 1: التنقل السريع بين الفروع (Smart Switching)
أحمد شغال في فرع `feature-invoice` وعنده تعديلات غير مسجلة (unstaged changes) في ملف `helper.js` وجرب يعمل `git switch main`. لو التعديلات دي مش بتتعارض مع كود الـ `main` الحالي، الـ Git هيسمحله بالانتقال وياخد التعديلات معاه لفرع `main`. لكن لو التعديلات دي في سطور متعارضة، الـ Git هيمنعه ويقوله اعمل stash أو commit الأول عشان كودك ميضيعش.

#### مثال 2: استرجاع كود من branch تاني للملف الحالي
لو أحمد واقف في `main` وعايز ينسخ محتوى ملف `config.json` من فرع `feature-invoice` من غير ما ينقل الفرع كله، هنا الـ `switch` متقدرش تعمل ده لأنها بتنقل فروع بس. هنا بيستخدم `git checkout` أو `git restore`:
`git restore --source=feature-invoice config.json`

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the primary difference between `git checkout` and `git switch`, and why was `git switch` introduced in modern Git versions?"*
>
> **الإجابة المثالية:**
> تم إدخال الأمر `git switch` في الإصدار 2.23 لتسهيل التعامل مع الفروع وفصل المهام؛ حيث كان الأمر `git checkout` يقوم بوظائف متعددة ومتداخلة مثل التنقل بين الفروع وإنشائها واستعادة الملفات والذهاب للـ commits القديمة، مما سبب ارتباكاً وصعوبة في الاستخدام. الآن، يتخصص `git switch` حصرياً في التبديل بين الفروع وإنشائها (باستخدام خيار `-c`)، بينما يتخصص `git restore` في استعادة الملفات، وظل `git checkout` مدعوماً للتوافق مع الإصدارات السابقة فقط ولكن لا يفضل استخدامه في بيئات العمل الحديثة منعاً للأخطاء غير المقصودة.

---

## Q24 — يعني إيه Tracking Branch و Upstream Branch؟ وإزاي بنربط الـ local branch بالـ remote branch؟

### أصل الحكاية
أحمد عمل فرع محلي اسمه `feature-login` وخلص الشغل عليه وعايز يرفعه على GitHub. كتب `git push` وسكت. فجأة الـ Git ضرب في وشه وقاله: 
`fatal: The current branch feature-login has no upstream branch. To push the current branch and set the remote as upstream, use: git push --set-upstream origin feature-login`.

الموضوع ده بيحصل لأن الـ Git على جهازك (Local) والـ GitHub (Remote) هما مستودعين منفصلين تماماً. لما بتعمل branch محلي، الـ Git ميعرفش تلقائياً هو المفروض يترفع فين أو يقرأ منين على السيرفر، إلا لو ربطتهم ببعض. الربط ده بيخلق حاجة اسمها **Tracking Branch** (الفرع المتابع)، والفرع المقابل على السيرفر بيبقى اسمه **Upstream Branch**.

```bash
# Push and link the local branch to the remote branch (set upstream)
git push -u origin feature-login
# Output: Branch 'feature-login' set up to track remote branch 'feature-login' from 'origin'.
# Note: '-u' is shorthand for '--set-upstream'

# Once upstream is set, subsequent pulls and pushes require no extra arguments
git push
git pull

# Check which local branches are tracking which remote branches
git branch -vv
# Output:
# * feature-login 4c3d2e1 [origin/feature-login] feat: add auth handler
#   main          9f3e4b1 [origin/main] chore: update config
```

#### مثال 1: تغير الفرع البعيد (Remote branch name differs)
أحمد عنده فرع محلي اسمه `local-auth` بس التيم طلب منه يرفعه على السيرفر باسم `remote-authentication`. يقدر يربطهم رغم اختلاف الأسامي:
`git push -u origin local-auth:remote-authentication`
دلوقتي الـ Upstream بتاع `local-auth` بقى `origin/remote-authentication`.

#### مثال 2: ربط فرع محلي موجود بفرع سيرفر موجود بالفعل
أحمد سحب فروع جديدة من السيرفر بـ `git fetch` وعنده فرع محلي اسمه `dev` وعايز يربطه بـ `origin/dev` اللي ظهر على السيرفر من غير ما يعمل push:
`git branch -u origin/dev dev`
أو لو هو واقف جواه: `git branch --set-upstream-to=origin/dev`

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is an upstream branch in Git, and what are the benefits of configuring a local branch to track a remote branch?"*
>
> **الإجابة المثالية:**
> الفرع البعيد (Upstream Branch) هو فرع مستضاف على خادم بعيد (Remote Repository) مثل GitHub يرتبط بفرع محلي مناظر له. إعداد هذا الارتباط يحول الفرع المحلي إلى فرع متابع (Tracking Branch). الفائدة من هذا التكوين هي تبسيط العمليات اليومية؛ حيث يتيح للمطور استخدام الأوامر `git push` و `git pull` مباشرة دون الحاجة لتحديد اسم المستودع البعيد أو اسم الفرع في كل مرة، كما يتيح لـ Git حساب الفروقات وتنبيه المطور عبر `git status` ما إذا كان فرعه المحلي متأخراً (Behind) أو متقدماً (Ahead) عن السيرفر وبكم عدد من الـ commits.

---

## Q25 — إزاي بنمسح الـ Branches محلياً وسحابياً؟ وإيه الفرق بين git branch -d و git branch -D؟

### أصل الحكاية
بعد ما تم دمج فرع `feature-login` بنجاح في فرع `main` على GitHub، التيك ليد طلب من أحمد ينظف المستودع بتاعه ويمسح الفروع القديمة عشان متعملش زحمة. أحمد راح يمسح الفرع محلياً. كتب `git branch -d feature-login` والعملية تمت بنجاح. 

بس لما جرب يمسح فرع تاني اسمه `feature-experimental` لسه مدمجش، الـ Git صرخ في وشه وقاله: 
`error: The branch 'feature-experimental' is not fully merged. If you are sure you want to delete it, run 'git branch -D feature-experimental'`.
هنا أحمد فهم إن Git بيعمل صمام أمان (Safety Guard) عشان يحميه من مسح شغله بالخطأ.

```bash
# Delete a branch locally (Safe mode: only if fully merged)
git branch -d <branch-name>

# Force delete a branch locally (DANGER: destroys unmerged changes)
git branch -D <branch-name>

# Delete a remote branch from the server (GitHub)
git push origin --delete <branch-name>
```

#### مثال 1: أحمد قرر يمسح الفرع القسري عشان التغييرات طلعت بايظة وعايز يخلص منها:
`git branch -D feature-experimental`
 كأن شيئاً لم يكن!

#### مثال 2: تنظيف الفروع البعيدة الميتة محلياً (Pruning)
التيم مسح 50 فرع من على GitHub بعد دمجهم، بس لما أحمد بيكتب `git branch -a` على جهازه، الفروع دي لسه ظاهرة عنده كـ `remotes/origin/...`. دي فروع ميتة (Stale references). عشان أحمد ينظف جهازه ويحذف الإشارات للفروع الممسوحة من على السيرفر:
بيكتب `git fetch --prune` أو `git fetch -p`

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the difference between `git branch -d` and `git branch -D`, and how you would delete a branch on the remote server."*
>
> **الإجابة المثالية:**
> يقوم الخيار `-d` (اختصار لـ `--delete`) بحذف الفرع محلياً بشرط أن يكون قد تم دمجه (Merged) بالكامل في الفرع الأب أو الفرع النشط حالياً كصمام أمان لمنع فقدان البيانات. أما الخيار `-D` (اختصار لـ `--delete --force`) فيقوم بفرض الحذف القسري للفرع دون التحقق من حالة الدمج، وهو ما يعرض الأكواد غير المدمجة للفقدان. لحذف الفرع من السيرفر البعيد (Remote Server)، نستخدم الأمر `git push origin --delete <branch-name>` والذي يقوم بإرسال إشارة للمستودع البعيد لحذف هذا المرجع.


---

## Q26 — إيه الفرق بين الـ Fast-Forward Merge والـ Three-Way Merge؟ وإزاي Git بيختار بينهم؟

### أصل الحكاية
في InboxSales، أحمد عمل فرع اسمه `feature-tax` من فرع `main`. أثناء ما أحمد شغال، مفيش أي مطور تاني رفع أي كود على فرع `main`. لما خلص أحمد وطلب دمج فرعه في `main` بـ `git merge feature-tax`، الـ Git قاله في التقرير: `Fast-forward`.

بعدها بأسبوع، عمل فرع تاني اسمه `feature-discount`. بس المرة دي، شادي رفع كوميت جديد على `main` وأحمد لسه شغال. لما جه أحمد يدمج، الـ Git فتحله شاشة الـ Editor وقاله اكتب رسالة الـ merge commit، وقاله في التقرير: `Merge made by the 'ort' strategy`.
هنا بنفهم إن الـ Merge في Git له طريقتين رئيسيتين للتشغيل حسب حالة شجرة التاريخ (Commit Graph).

```
Fast-Forward Merge:
Before:
main: A --- B (HEAD)
               \
feature:        C --- D

After (git merge feature):
main: A --- B --- C --- D (HEAD)
(No new merge commit created, pointer just moved forward)

---------------------------------------------------------

Three-Way Merge:
Before:
main: A --- B --- E (HEAD)
               \
feature:        C --- D

After (git merge feature):
main: A --- B --- E --- M (HEAD, New Merge Commit)
               \       /
feature:        C --- D
(Uses common ancestor 'B' to combine changes and creates commit 'M')
```
```bash
# Force a 3-way merge even if a fast-forward is possible (to keep history explicit)
git merge --no-ff feature-tax

# Fast-forward only: refuse to merge if it requires a merge commit
git merge --ff-only feature-discount
```

#### مثال 1: ميزة وعيب الـ Fast-Forward
الـ Fast-Forward ميزته إنه بيخلي التاريخ خطي تماماً (Linear History) ملوش أي تفرعات معقدة وسهل القراءة. عيبه إنه بيمسح حقيقة إن التغييرات دي اتعملت في فرع منفصل؛ الفرع بينصهر جوة الـ main تماماً ومتقدرش تعرف الكوميتس دي كانت تبع أنهي تذكرة (Ticket).

#### مثال 2: استخدام `--no-ff` لحفظ الهوية
التيك ليد في InboxSales بيجبر التيم يكتبوا `git merge --no-ff` عند دمج أي ميزة رئيسية، حتى لو كان ينفع يتعملها Fast-Forward. ليه؟ عشان يتخلق Merge Commit (زي الكوميت `M` في الرسمة) يربط الفروع ببعضها ويسجل بشكل رسمي: "في اللحظة دي تم دمج فرع Feature X". ده بيسهل عمل Revert للميزة كاملة بـ revert للـ merge commit بالكامل لو ظهرت فيها مشاكل.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Contrast Fast-Forward merges with Three-Way merges in Git. Under what conditions does Git choose a Three-Way merge, and why would you use `--no-ff`?"*
>
> **الإجابة المثالية:**
> يحدث الدمج السريع (Fast-Forward Merge) عندما لا يكون هناك أي commits جديدة على الفرع الرئيسي منذ تفرع الفرع المراد دمجه منه؛ فيقوم Git بمجرد نقل مؤشر الفرع الرئيسي للأمام ليشير إلى أحدث commit في الفرع الفرعي دون إنشاء تسجيل دمج جديد. أما الدمج ثلاثي الأطراف (Three-Way Merge) فيحدث عند وجود تعديلات متوازية على كلا الفرعين؛ فيستخدم Git ثلاث نقاط مرجعية (أحدث commit في الرئيسي، وأحدث commit في الفرعي، والجد المشترك الأحدث Common Ancestor) لدمج التغييرات وإنشاء تسجيل دمج جديد (Merge Commit). نستخدم `--no-ff` لمنع الدمج السريع قسرياً حتى لو كان ممكناً، وذلك للحفاظ على تاريخ فرعي واضح ومجمع للـ commits يسهل تتبعه أو التراجع عنه مستقبلاً.

---

## Q27 — إيه هي استراتيجية الدمج الافتراضية الحديثة Git ORT Merge Strategy؟ وليه هي أسرع وأذكى من Recursive؟

### أصل الحكاية
لو إنت بتستخدم إصدار Git حديث (بداية من 2.34 في أواخر 2021) وجربت تعمل merge فيه conflicts معقدة، هتلاقيه كاتبلك: `Using the 'ort' merge strategy`. زمان كان الـ Git بيستخدم استراتيجية اسمها `recursive` كخيار افتراضي. 

لما سألت مهندس سينيور في التيم: "هو يعني إيه ORT دي واشمعنى غيروها؟" ضحك وقالك: "دي اختصار لـ **Ostensibly Recursive's Twin** (توأم ريكرسيف المزعوم)، ودي إعادة كتابة كاملة ومحسنة لاستراتيجية الدمج عشان تحل مشاكل الأداء والـ conflicts المعقدة".
أكبر ميزة في ORT هي ذكاؤها الخارق وسرعتها في التعامل مع إعادة التسمية (Renames Detection) وحل حالات التعارض المعقدة اللي بتشمل أكتر من جد مشترك (Cross-merges).

```bash
# Verify the default merge strategy by doing a merge in Git 2.34+
# Under the hood, ORT is written in C and replaces the old python-heavy/C logic of recursive.

# You can explicitly choose the strategy if needed (though default is ORT now)
git merge -s ort feature-branch

# You can pass options to the ORT strategy, like favoring changes from our branch
git merge -X ours feature-branch
```

#### مثال 1: توفير الوقت في المستودعات الضخمة
في مشروع InboxSales الضخم، لما أحمد بيعمل merge لفرع متأخر بقاله شهرين وكان فيه ملفات كتير اتغيرت أساميها واتنقلت من فولدر للتاني، الـ Recursive القديمة كانت بتاخد دقايق وتقف عاجزة وتطلع conflicts وهمية كتير. الـ ORT بتعمل نفس الـ merge في جزء من الثانية وبتحل أغلب التسميات تلقائياً لأنها بتكاش (cache) معلومات الـ rename وتعملها reuse.

#### مثال 2: السيطرة على الـ Conflict التلقائي بـ `-X`
أحمد بيعمل merge لكود من فرع التيم التاني وعارف إن فيه ملفات إعدادات فيها conflicts ومش عايز يحلها يدوي؛ هو عايز كود فريقه هو اللي يكسب ويدوس على كود الفريق التاني تلقائياً. بيكتب:
`git merge -Xours feature-team-b`
الـ ORT هتحل الـ conflicts لصالح فرع أحمد تلقائياً بدون تدخل منه. ولو كان عايز العكس بيكتب `-Xtheirs`.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the 'ORT' merge strategy in modern Git, and how does it improve upon the older 'Recursive' merge strategy?"*
>
> **الإجابة المثالية:**
> استراتيجية الدمج ORT (Ostensibly Recursive's Twin) هي الخوارزمية الافتراضية للدمج في إصدارات Git الحديثة (بدءاً من 2.34)، وقد تم تطويرها كإعادة كتابة كاملة ومحسنة لاستراتيجية `recursive` القديمة. تتفوق ORT في سرعتها الفائقة (أسرع بعدة أضعاف في المشاريع الكبرى) وكفاءتها العالية في معالجة عمليات إعادة التسمية (Rename Detection) وحفظ نتائج المقارنة مؤقتاً لتجنب إعادة حسابها. كما أنها تحل التعارضات الناتجة عن وجود أكثر من جد مشترك (Multiple Common Ancestors) بشكل أدق وتقلل من التعارضات الوهمية التي كانت تقع فيها الاستراتيجية القديمة، مما يجعل دمج الفروع الطويلة والمعقدة أكثر سلاسة وأماناً.

---

## Q28 — إزاي الـ Conflict بيحصل بالتفصيل؟ وإيه هي علامات التعارض (Conflict Markers) اللي بتظهر في الملف؟

### أصل الحكاية
أحمد وشادي شغالين في InboxSales على نفس ملف الـ `router.js`.
- أحمد عدل السطر رقم 15 وخلاه: `app.get('/users', getAllUsers)` وعمل commit و push.
- شادي (على جهازه وميعرفش إن أحمد رفع) عدل نفس السطر رقم 15 وخلاه: `app.get('/users', fetchUsersList)`.

عند محاولة الدمج، الـ Git بيقف عاجز تماماً! هو شايف إن السطر رقم 15 كان قيمته `X` في الجد المشترك (Common Ancestor)، ودلوقتي أحمد بيقول خليه `Y` وشادي بيقول خليه `Z`. الـ Git ميعرفش مين الصح بزنس (Business logic)؛ لو اختار واحد ومسح التاني ممكن الأبلكيشن يقع.
هنا الـ Git بيوقف الـ merge فوراً، ويحط علامات غريبة جوة ملف الكود اسمها **Conflict Markers** ويقول للمطورين: "روحوا اتصالحوا وحلوها يدوي!".

```javascript
// Inside router.js during a merge conflict
const express = require('express');
const app = express();

<<<<<<< HEAD
app.get('/users', fetchUsersList);
=======
app.get('/users', getAllUsers);
>>>>>>> feature-tax

app.listen(3000);
```

#### مثال 1: فك شفرة علامات التعارض
شادي فتح ملف الـ `router.js` واتخض من العلامات. أحمد قعد معاه وفهمه التقسيمة:
1. `<<<<<<< HEAD`: بتعني بداية التغييرات اللي موجودة في الفرع اللي إنت واقف عليه حالياً وبتحاول تدمج جواه (الـ Target Branch).
2. `=======`: ده السور الفاصل بين الكودين.
3. `>>>>>>> feature-tax`: بتعني نهاية التغييرات اللي جاية من الفرع اللي إنت بتسحبه وتدمجه عندك (الـ Source Branch).

#### مثال 2: التعارض على مستوى صلاحيات الملف أو الحذف
أحمد مسح ملف `utils.js` تماماً من فرعه وعمل commit. في نفس الوقت، شادي كان بيصلح سطر كود جوة نفس ملف `utils.js` في فرعه. لما يجوا يدمجوا، هيحصل Conflict من نوع خاص اسمه **Modify/Delete Conflict** (تعارض تعديل وحذف). الـ Git هيسألهم: "هل عايزين الملف يفضل ممسوح زي ما أحمد عمل، ولا نرجعه بالتصليح بتاع شادي؟" ويوقف الدمج لحد ما يختاروا.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Describe the structure of Git conflict markers, explain what each section represents, and discuss a scenario where a conflict occurs without code line overlaps."*
>
> **الإجابة المثالية:**
> يحدث التعارض (Merge Conflict) عندما يتم التعديل على نفس السطر في نفس الملف بطريقتين مختلفتين على فرعين متوازيين، أو عند حذف ملف في فرع وتعديله في فرع آخر. تظهر علامات التعارض البرمجية كالتالي:
> - القسم بين `<<<<<<< HEAD` والخط الفاصل `=======` يحتوي على التعديلات الموجودة في الفرع الحالي النشط الذي يتم الدمج فيه.
> - القسم بين الخط الفاصل `=======` وعلامة النهاية `>>>>>>> <branch-name>` يحتوي على التعديلات القادمة من الفرع الآخر المراد دمجه.
> - يمكن أن يحدث تعارض بدون تداخل سطور في حالات مثل Modify/Delete Conflict (حيث يعدل مطور ملفاً ويحذفه آخر)، أو File Rename Conflict (عندما يغير مطوران اسم نفس الملف إلى اسمين مختلفين في نفس الوقت)، وهي حالات تتطلب تدخلاً يدوياً لتحديد المسار الصحيح للمشروع.

---

## Q29 — إزاي بنحل الـ Conflict خطوة بخطوة؟ وإيه استخدام git merge --abort و git merge --continue؟

### أصل الحكاية
الـ Conflict حصل لأحمد في InboxSales والدنيا وقفت. شادي قاله: "أنا متوتر والـ terminal كاتبة `(main|merging)` ومش عارف أعمل إيه وخايف أبوظ الكود الرئيسي".
أحمد قاله: "متقلقش، الـ Git مديلنا السيطرة الكاملة. لو حسينا إن الدنيا اتعقدت ومش جاهزين نحلها دلوقتي، نقدر نلغي عملية الدمج دي كلها بضغطة زرار ونرجع للوضع الآمن قبل الـ merge".

حل الـ conflict بيتم بروتوكول منظم:
1. مراجعة الملفات المتعارضة بـ `git status`.
2. فتح الملفات في محرر الكود (VS Code) ومناقشة التعديلات مع المطور التاني للوصول للنسخة النهائية.
3. مسح علامات الـ conflict (الماركرز) بالكامل وحفظ الملف.
4. عمل `git add` للملفات اللي اتحلت لتعريف الـ Git إنها بقت جاهزة.
5. إكمال عملية الدمج بـ `git merge --continue`.

```bash
# Check which files have conflicts
git status
# Output:
# Unmerged paths:
#   (use "git add <file>..." to mark resolution)
#	both modified:   src/router.js

# SCENARIO A: We are overwhelmed and want to completely cancel the merge
git merge --abort
# Result: Repository goes back to the clean state before we ran 'git merge'

# SCENARIO B: We resolved the conflicts in editor, removed markers, and saved
# 1. Stage the resolved files
git add src/router.js

# 2. Finish the merge process
git merge --continue
# This opens the editor to save the merge commit message, then completes the merge.
```

#### مثال 1: استخدام VS Code Conflict 3-Way Editor
أحمد بيستخدم محرر VS Code الحديث. المحرر بيسهل الدنيا وبيعرض 3 نوافذ: النسخة الحالية (Incoming)، والنسخة السيرفر (Current)، والنسخة الناتجة تحت (Result). بيدي زرار سريع: `Accept Current Change` أو `Accept Incoming Change` أو `Accept Both` بدل ما يمسح الماركرز يدوياً.

#### مثال 2: نسيان إكمال الـ Merge والبدء في كود جديد
شادي حل الـ conflict يدوي ومسح الماركرز، بس نسي يكتب `git add` أو `git merge --continue` وبدأ يعدل في ملف تاني خالص. لما جه يعمل commit، الـ Git قاله: `fatal: cannot do a partial commit during a merge`. أحمد فكره وقاله: "لازم تقفل الـ merge المفتوحة الأول بـ `git add` للتعارض وتعمل الـ merge commit، مفيش كوميتس عادية بتتعمل أثناء حالة الـ merging".

### الفايدة الانترفيوية
> **Interview Question:**
> *"Walk me through the step-by-step process of resolving a merge conflict. What does `git merge --abort` do, and when is it appropriate to use it?"*
>
> **الإجابة المثالية:**
> لحل تعارض الدمج، نتبع الخطوات التالية: أولاً، نحدد الملفات المتعارضة باستخدام `git status`. ثانياً، نفتح الملفات في محرر الأكواد ونحدد الأسطر المتعارضة بين علامات التعارض، ثم نقوم بالتشاور مع زملائنا لاختيار الكود الصحيح ومسح علامات التعارض يدوياً وحفظ الملف. ثالثاً، نقوم بتجهيز الملفات المحلولة باستخدام `git add` لإخبار Git بحل التعارض. رابعاً، ننهي عملية الدمج بتشغيل `git merge --continue` لإنشاء الـ Merge Commit.
> أما الأمر `git merge --abort` فيقوم بإلغاء عملية الدمج الحالية بالكامل وإعادة حالة المستودع ودليل العمل إلى ما كانا عليه بدقة قبل كتابة أمر الدمج؛ ونستخدمه عندما تكون التعارضات معقدة للغاية ونحتاج إلى وقت لمراجعة الكود، أو إذا قمنا بالدمج بالخطأ ونريد التراجع الفوري لتجنب تخريب بيئة العمل.

> [!tip] Checkpoint
> بكدة نكون قفلنا موضوع الفروع والدمج الأساسي (Topic 3). دلوقتي إنت مستعد تدخل في واحد من أكتر المواضيع جدلاً في الإنترفيوهات وشغل التيمز: الـ **Merging vs Rebasing** وتفاصيل كل واحد فيهم! يلا بينا.

---

# 🔀 Topic 4: Merging vs Rebasing (إعادة بناء التاريخ والدمج المتقدم)

## Q30 — هو الـ `git rebase` إيه فكرته تحت الغطاء؟ وبيفرق إيه عن الـ `git merge` في إعادة بناء التاريخ؟

### أصل الحكاية
في InboxSales، أحمد عمل فرع اسمه `feature-payment` من فرع `main`. وفي نفس الوقت، شادي كان بيعدل في الـ `main` وعمل push لكوميتس جديدة على السيرفر.
دلوقتي أحمد محتاج يحدث فرعه بآخر تعديلات الـ `main` عشان يضمن إن كوده متوافق مع آخر نسخة.
لو أحمد عمل `git merge main` وهو واقف في فرع `feature-payment`:
- الـ Git هيعمل Three-way merge ويتخلق كوميت دمج جديد (Merge Commit) يربط فرع أحمد بالـ `main`. التاريخ هنا هيبقى عبارة عن شبكة متفرعة ومترابطة.

لكن لو أحمد قرر يعمل `git rebase main`:
- الـ Git هيعمل حركة تانية خالص تحت الغطاء:
  1. هيروح يحدد الجد المشترك (Common Ancestor) بين فرع أحمد وفرع `main`.
  2. بياخد الكوميتس اللي أحمد عملها على فرع `feature-payment` بعد الجد المشترك ده، ويركنها في مكان مؤقت (Temporary area).
  3. ينقل مؤشر فرع `feature-payment` ويخليه يقف على أحدث كوميت في فرع `main` حالياً (تحديث قاعدة التفرع أو الـ Base).
  4. يبدأ يجيب الكوميتس المركونة في المكان المؤقت، ويطبقها واحدة ورا التانية (Replay) فوق أحدث كوميت في الـ `main`.
النتيجة: خط تاريخ مستقيم تماماً (Linear History)، وكأن أحمد لسه عامل الفرع بتاعه حالاً من أحدث نقطة في الـ `main` بدون أي تسجيل دمج.

```text
Under the hood: Rebase vs Merge

Original State:
      C --- D (feature-payment)
     /
A --- B (Ancestor) --- E --- F (main)

After git merge main (creates new merge commit M):
      C --- D 
     /         \
A --- B --- E --- F --- M (feature-payment, HEAD)

After git rebase main (replays commits C and D as C' and D'):
A --- B --- E --- F (main) --- C' --- D' (feature-payment, HEAD)
```

```bash
# How to rebase the current feature branch onto main
git switch feature-payment
git rebase main

# Under the hood, Git does this:
# 1. Identifies common ancestor 'B'
# 2. Stores modifications of 'C' and 'D' in temporary patch files
# 3. Resets HEAD of feature-payment to 'F' (main's latest commit)
# 4. Applies patches 'C' and 'D' successively to get 'C'' and 'D''
```

#### مثال 1: مصير الـ Hashes بعد الـ Rebase
أحمد لاحظ إن الـ Commit hashes في فرعه اتغيرت تماماً بعد الـ rebase. الـ commit اللي كان الـ hash بتاعه `4c3d2e1` بقى `9f3e4b1`. ده تصرف طبيعي؛ لأن الـ SHA-1 Hash بتاع الكوميت بيتحسب بناء على محتوى الكود، وتاريخ الكوميت، والكوميت الأب (Parent). ولأن الأب اتغير (بقى أحدث كوميت في main بدل الجد المشترك القديم)، الـ Git بيعتبرها كوميتس جديدة تماماً ويعيد حساب الـ hashes بتاعتها.

#### مثال 2: الدمج الآمن محلياً
أحمد بيفضل يعمل rebase لفرعه على الـ `main` بشكل دوري وهو شغال عشان يحل أي conflicts بدري بدري على جهازه، وبكدة لما يجي يخلص ويبعت Pull Request للتيم، يضمن إن الـ PR هيتدمج تلقائياً بدون أي مشاكل تعارض على GitHub.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the conceptual difference between `git merge` and `git rebase` under the hood. How does `git rebase` rebuild history, and what happens to commit hashes?"*
>
> **الإجابة المثالية:**
> يكمن الاختلاف الجوهري في طريقة معالجة تاريخ المشروع؛ حيث يقوم `git merge` بدمج الفرعين عبر إنشاء تسجيل دمج جديد (Merge Commit) يربط بين نهايتي الفرعين مع الاحتفاظ بالتاريخ الأصلي للفرعين كما هو دون أي تعديل. أما `git rebase` فيقوم بـ "إعادة كتابة التاريخ" عن طريق تحديد الجد المشترك للفرعين، والاحتفاظ بالـ commits الخاصة بالفرع الحالي مؤقتاً، ثم نقل قاعدة تفرع الفرع (Base) إلى أحدث commit في الفرع المستهدف، وأخيراً إعادة تطبيق (Replaying) الـ commits المحفوظة تباعاً فوق القاعدة الجديدة. ينتج عن الـ Rebase تاريخ خطي (Linear History) خالٍ من الـ Merge Commits، ولكن يعاد حساب الـ SHA-1 Hashes لكل الكوميتس المعاد تطبيقها لأن آباءها (Parents) قد تغيروا، مما يمثل تاريخاً برمجياً جديداً.

---

## Q31 — يعني إيه "القاعدة الذهبية للـ Rebasing" (The Golden Rule of Rebasing)؟ وليه تطبيقها غلط بيخرب الدنيا للتيم كله؟

### أصل الحكاية
شادي في InboxSales كان شغال على فرع `develop` وهو فرع مشترك وببليك (Public Branch) كل زمايله بيسحبوا منه ويعملوا فروعهم عليه. 
شادي حب ينظف الكود ويرتبه، فعمل `git rebase main` وهو واقف في فرع `develop` على جهازه. الـ rebase نجح، وعشان السيرفر يرضى يقبل الكود (لأن التاريخ اختلف)، شادي كتب `git push --force origin develop`.
بمجرد ما شادي عمل كدة، الدنيا خربت في الشركة!
منى وأحمد وكريم لما جربوا يعملوا `git pull` عشان يسحبوا التحديثات، أجهزتهم ضربت conflicts معقدة ولانهائية، وبدأ الـ Git يكرر نفس الكوميتس بتاعتهم بأسامي مختلفة!
السبب إن شادي غير الـ Hashes بتاعة الكوميتس اللي موجودة بالفعل عند زمايله في التيم. التيم عنده كوميتس بآباء معينة، وشادي رفع نفس الكود بآباء جديدة. الـ Git لما جه يعمل pull لقى نسختين من نفس الشغل فقرر يدمجهم ببعض وعمل كوارث.
عشان كدة، فيه قاعدة ذهبية في عالم الفيرجن كونترول لازم تحفظها زي اسمك:
`Never rebase a public branch!` (إياك تعمل rebase لفرع عام مشترك).

```bash
# DANGEROUS ACTION: Rebasing a shared public branch and forcing push
# (Never do this on branches like main, master, or develop!)
git checkout develop
git rebase main
git push --force origin develop # WARNING: This rewrites history for everyone else!
```

#### مثال 1: النطاق الآمن للـ Rebase
منى دايماً بتلتزم بالقاعدة: الـ rebase يتعمل فقط على فروعها المحلية (Local Branches) الخاصة بيها هي بس، واللي مفيش أي مطور تاني في الشركة بيسحب منها أو شغال عليها. بمجرد ما الفرع يترفع ويبقى متاح للعامة أو يتعمل له PR للدمج، بتوقف الـ rebase تماماً وتتحول للـ Merge العادي.

#### مثال 2: كيفية إنقاذ جهازك لو زميلك خرق القاعدة
لو شادي خرق القاعدة وعمل force push لفرع مشترك، وأحمد لقى جهازه متبهدل ومش عارف يسحب الكود؛ الحل هنا إن أحمد ميعملش pull العادي، بل يعمل fetch ويمسح فرعه المحلي ويعيد تنزيله نظيف من السيرفر:
```bash
git fetch origin
git checkout develop
# Reset your local branch to match the remote exactly, discarding your local rebase issues
git reset --hard origin/develop
```

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the 'Golden Rule of Rebasing' and what are the consequences of violating it on a shared team branch?"*
>
> **الإجابة المثالية:**
> تنص القاعدة الذهبية للـ Rebasing على: "عدم إجراء rebase للفروع العامة أو المشتركة (Public/Shared Branches) التي يعمل عليها مطورون آخرون". عند مخالفة هذه القاعدة وعمل force push لفرع مشترك بعد الـ rebase، يتم تغيير الـ hashes الخاصة بالـ commits الموجودة مسبقاً لدى بقية أعضاء الفريق. عندما يحاول المطورون الآخرون سحب التحديثات بـ `git pull` التقليدي، يعتبر Git أن تاريخهم المحلي وتاريخ السيرفر قد تباعدا، ويحاول دمج التاريخين معاً، مما ينتج عنه تكرار الكوميتس (Duplicate commits) وتفشي تعارضات الدمج (Merge Conflicts) المعقدة وفقدان ثبات مستودع الأكواد.

---

## Q32 — إزاي الـ Rebase بيغير شكل الـ Fast-Forward عند الدمج؟ وتاريخ خطي (Linear) ولا تاريخ حقيقي (Explicit)؟

### أصل الحكاية
في InboxSales، التيم منقسم لمدارس فلسفية في كتابة تاريخ المشروع:
- **مدرسة التاريخ الحقيقي (Explicit History):** أحمد بيقول: "التاريخ ده مرآة للي حصل بالظبط، ولازم نسجل كل فرع اتفتح إمتى واتقفل إمتى بالدقيقة والساعة، والـ Merge Commits دي دليل توثيقي مهم".
- **مدرسة التاريخ النظيف (Clean Linear History):** شادي بيقول: "أنا مش عايز أشوف تعقيد شجرة الفروع وتفرعاتها في الـ log. أنا عايز أقرأ التاريخ كخط مستقيم ورا بعضه كأنه كتاب رواية منظم".

لو أحمد عمل Rebase لفرعه `feature-invoice` على الـ `main` قبل الدمج، مؤشر فرعه هيبقى متقدم خطياً ومباشرة على الـ `main` (مفيش تفرعات متباعدة). لما يجي التيك ليد يدمج الفرع ده، الـ Git هيعمل **Fast-Forward Merge** تلقائي وينقل مؤشر الـ `main` لنهاية فرع أحمد بدون إنشاء أي Merge Commit إضافي، وبكدة التاريخ يفضل مستقيم تماماً.

```text
Merge Strategy (Explicit & Branching):
main:     A --- B ----------- M (HEAD, Merge Commit)
                 \           /
feature:          C ------- D

Rebase Strategy (Linear & Clean):
main:     A --- B --- C' --- D' (HEAD, Fast-Forwarded)
```

```bash
# Force a 3-way merge even if a fast-forward is possible (to keep history explicit)
git merge --no-ff feature-invoice

# Force Git to only merge if it can do a fast-forward (refuses to create a merge commit)
git merge --ff-only feature-invoice
```

#### مثال 1: ميزة التاريخ الخطي في تتبع العيوب
شادي بيفضل التاريخ الخطي لأنه بيسهل جداً تشغيل أمر `git bisect` (أداة البحث الثنائي لتحديد الكوميت اللي بوظ الكود). لو الشجرة خطية، الـ bisect بيمشي بسرعة البرق ويطلع الكوميت المسؤول عن الـ bug. في الشجرة العنكبوتية المعقدة، الـ bisect بيتشتت بسبب كثرة مسارات الدمج.

#### مثال 2: ميزة التاريخ الحقيقي في التراجع عن الميزات
أحمد بيفضل الـ Merge Commits لأنه لو دمج ميزة كبيرة فيها 20 commit ولقى الـ production انهار وعايز يلغي الميزة دي كلها فوراً؛ كل اللي بيعمله هو إنه بيلغي الـ Merge Commit الواحد بتاعها بـ `git revert -m 1 <merge-commit-hash>`. بكدة الميزة كلها بتتمسح بـ commit واحد. لو كان شغال Rebase، كان هيضطر يعمل revert لـ 20 commit منفصلين يدوياً!

### الفايدة الانترفيوية
> **Interview Question:**
> *"Compare the tradeoffs between maintaining a linear history via rebasing versus an explicit history via merging. How does rebasing enable fast-forwarding?"*
>
> **الإجابة المثالية:**
> يؤدي الـ Rebase إلى جعل الفرع الفرعي امتداداً خطياً مباشراً لنهاية الفرع الرئيسي (الجديد)، مما يمكن Git من إجراء دمج سريع (Fast-Forward Merge) بمجرد تحريك مؤشر الفرع الرئيسي للأمام دون الحاجة لإنشاء تسجيل دمج.
> **المفاضلة (Tradeoffs):**
> - **التاريخ الخطي (Rebase):** يوفر سجلاً نظيفاً للغاية وسهل القراءة والمراجعة ويحسن كفاءة أدوات تتبع الأخطاء مثل `git bisect`، ولكن عيبه أنه يفقد التوثيق الزمني الفعلي لحدوث التغييرات ويزيف آباء الكوميتس.
> - **التاريخ الحقيقي (Merge):** يحافظ على السياق الحقيقي للمشروع ويسهل التراجع عن ميزات كاملة عبر إلغاء تسجيل الدمج (Reverting a merge commit)، ولكن عيبه أنه يجعل شجرة التاريخ معقدة وصعبة القراءة والتتبع في الفرق الكبيرة.

---

## Q33 — إيه هو الـ Interactive Rebase (`git rebase -i`)؟ وإزاي بيخليك تعدل وتدمج (Squash) الكوميتس قبل ما ترفع؟

### أصل الحكاية
أحمد بقاله يومين شغال على ميزة معقدة في InboxSales وعمل 5 commits على جهازه:
1. `feat: create bill screen`
2. `fix: fix spelling errors` (تصليح أخطاء إملائية)
3. `wip: testing some changes` (كود مؤقت وتجريبي)
4. `feat: add PDF export`
5. `fix: solve pdf crash` (حل مشكلة انهيار الـ PDF)

أحمد عارف إن لو عمل push بالمنظر ده، الكود ريفيو هيبقى سيء والـ commit log هيبقى مشوه برسائل زي `fix spelling` و `wip`.
عشان يظهر بمظهر المطور المحترف، استخدم الـ **Interactive Rebase** (`git rebase -i`) لتنظيف وتعديل ودمج الكوميتس دي كلها قبل ما تترفع وتتشاف.
الـ Interactive Rebase بيفتح ل أحمد ملف نصي فيه الكوميتس وجنب كل كوميت كلمة تحكم (Action Command) يقدر يغيرها:
- `pick`: احتفظ بالكوميت ده زي ما هو.
- `reword`: احتفظ بالكوميت بس غير رسالة التوثيق بتاعته (Reword message).
- `edit`: وقف الـ rebase عند الخطوة دي عشان أعدل في ملفات الكود نفسها.
- `squash`: ادمج الكوميت ده في الكوميت اللي فوقه، وافتحلي محرر النصوص لدمج الرسائل مع بعضها.
- `fixup`: ادمج الكوميت ده في اللي فوقه، بس امسح رسالته خالص (Discard commit message)؛ مفيد جداً للتصليحات الإملائية البسيطة.
- `drop`: احذف الكوميت ده تماماً بكوده من التاريخ!

```bash
# Start an interactive rebase for the last 5 commits
git rebase -i HEAD~5

# Git opens your default text editor showing this configuration:
#
# pick a1b2c3d feat: create bill screen
# fixup d4e5f6g fix: fix spelling errors
# fixup h7i8j9k wip: testing some changes
# pick l0m1n2o feat: add PDF export
# fixup p3q4r5s fix: solve pdf crash
#
# (When you save and close this file, Git executes these instructions from top to bottom)
```

#### مثال 1: دمج تعديل مع الكوميت الأب بـ `fixup`
أحمد غير كلمة `pick` للكوميتس رقم 2 ورقم 3 وخلاها `fixup`. لما حفظ الملف وقفل المحرر، الـ Git مسك الكود بتاعهم ودمجه جوة الكوميت الأول `feat: create bill screen` وحذف رسايلهم. التاريخ دلوقتي مبقاش فيه أثر لـ `fix spelling` ولا `wip` وبقى نظيف جداً.

#### مثال 2: إعادة ترتيب الكوميتس (Reordering)
لو أحمد غير ترتيب السطور في ملف الـ Interactive Rebase اللي اتفتحله (مثلاً خلى السطر الخامس مكان التاني)، الـ Git هيغير ترتيب الكوميتس دي في شجرة التاريخ الفعلي للمشروع! بس لازم يضمن إن التغييرات دي مش معتمدة على بعضها عشان ميحصلش conflicts أثناء إعادة الترتيب.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is an interactive rebase (`git rebase -i`), and how do commands like `squash` and `fixup` differ in cleanup workflows?"*
>
> **الإجابة المثالية:**
> الـ Interactive Rebase هو واجهة تفاعلية في Git تتيح للمطورين إعادة كتابة وتنظيم التاريخ المحلي للـ commits قبل دمجها أو دفعها للمستودع المشترك.
> **الفرق بين `squash` و `fixup`:**
> - **`squash`:** تقوم بدمج الـ commit الحالي مع الـ commit السابق له مباشرة في الشجرة، وتفتح محرر النصوص لتسمح للمطور بدمج أو كتابة رسالة توثيقية جديدة تجمع بين محتوى الكوميتين.
> - **`fixup`:** تقوم أيضاً بدمج الـ commit الحالي مع السابق له، ولكنها تتجاهل (Discard) رسالة الكوميت الحالي تماماً وتحتفظ بالرسالة الخاصة بالكوميت الأب فقط، مما يجعلها مثالية لدمج الإصلاحات البسيطة والتعديلات الطفيفة دون تلويث سجل الرسائل.

---

## Q34 — إزاي بنحل الـ Conflicts أثناء الـ Rebase؟ وإيه الفرق بين `--continue` و `--abort` و `--skip`؟

### أصل الحكاية
شادي شغال على فرع `feature-analytics` وقرر يعمل `git rebase main`. فجأة العملية وقفت تماماً وظهرت رسالة حمراء: `CONFLICT (content): Merge conflict in src/analytics.js`.
الـ terminal بتاع شادي اتغير وبقى كاتب بين قوسين: `(feature-analytics|REBASE 1/3)`.
ده معناه إن Git عنده 3 commits بيجرب يطبقهم ورا بعض، وحصل تعارض وهو بيطبق أول commit.
شادي لازم يفهم إنه مش في merge عادي، وحل التعارض هنا بيخضع لخطوات الـ rebase:
1. يفتح الملف المتعارض ويحل التعارض يدوياً ويمسح علامات التعارض (Conflict Markers).
2. يعمل `git add src/analytics.js` للملف المحلول.
3. يكتب `git rebase --continue` عشان الـ Git يكمل ويجرب يطبق الكوميتس اللي بعدها.

```bash
# Scenario A: Resolve conflict, stage the file, and proceed
git add src/analytics.js
git rebase --continue

# Scenario B: Panic! Cancel the whole rebase and restore original state
git rebase --abort

# Scenario C: Skip the current commit entirely (WARNING: discards its code!)
git rebase --skip
```

#### مثال 1: تعارض متكرر في كذا خطوة
شادي عنده 3 commits. حل التعارض في الكوميت الأول وكتب `--continue`. الـ Git دخل على الكوميت التاني لقاه تمام ومفهوش تعارض. دخل على الكوميت التالت لقى تعارض تاني! شادي هيرجع يحل التعارض التاني، يعمل `git add` ويكتب `git rebase --continue`. بمجرد ما يخلص الكوميتس كلها، الـ Git هينهي الـ rebase ويرجعه للحالة العادية بنجاح.

#### مثال 2: خطورة استخدام `--skip`
لو شادي كتب `git rebase --skip` أثناء التعارض، الـ Git هيتجاهل الكوميت الحالي تماماً ويرميه في الزبالة بكوده ويدخل على اللي بعده. ده خطير وممكن يوقع الأبلكيشن لو الكوميتس اللي بعده معتمدة على الكود اللي كان موجود في الكوميت اللي اتعمله skip.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the workflow of resolving conflicts during a rebase. What are the roles of `--continue`, `--abort`, and `--skip`?"*
>
> **الإجابة المثالية:**
> أثناء الـ Rebase، يقوم Git بتطبيق الـ commits بشكل تسلسلي؛ وإذا حدث تعارض عند خطوة معينة، تتوقف العملية مؤقتاً لحلها يدوياً.
> **أدوار الأوامر المساعدة:**
> - **`git rebase --continue`:** يُستخدم بعد حل التعارضات وتجهيز الملفات بـ `git add`؛ ليقوم Git بحفظ التقدم الحالي والانتقال لتطبيق الكوميت التالي في القائمة.
> - **`git rebase --abort`:** يلغي عملية الـ rebase بالكامل ويعيد المستودع ودليل العمل بدقة إلى حالتهما الأصلية قبل بدء العملية.
> - **`git rebase --skip`:** يتخطى الكوميت المتعارض الحالي تماماً دون تطبيقه على السلسلة الجديدة وينتقل للكوميت التالي، مما يعني تجاهل كافة التعديلات البرمجية التي كانت بداخله، ويجب استخدامه بحذر شديد.

---

## Q35 — يعني إيه `git pull --rebase`؟ وإزاي بيحميك من الـ Merge Commits الوهمية اللي بتنشأ وقت الـ pull؟

### أصل الحكاية
في InboxSales، منى كتبت كود على جهازها وعملت commit محلي. قبل ما تعمل push، أحمد كان رفع كود جديد على نفس الفرع على GitHub.
منى كتبت `git pull` عشان تسحب شغل أحمد. الـ Git سحب الكود وفتح شاشة الـ Editor تلقائياً وقام كاتب رسالة دمج افتراضية: `Merge branch 'main' of github.com:inboxsales/app`.
منى قفلت المحرر، فـ الـ Git عمل Merge Commit تلقائي لمجرد إنه يدمج شغل أحمد مع شغلها المحلي قبل الـ push. 
لما التيم يكتب `git log` بيلاقوا الشجرة مليانة Merge Commits وهمية ناتجة عن الـ pull المزدوج اليومي لدرجة إنها بتشوش على الكوميتس الحقيقية للميزات.
عشان كدة، التيك ليد طلب من منى تستخدم `git pull --rebase`.
تحت الغطاء، الـ `git pull --rebase` بيعمل خطوتين:
1. بيعمل `git fetch` يسحب كود أحمد من السيرفر.
2. بيعمل `git rebase` لكوميتس منى المحلية فوق كود أحمد اللي لسه واصل.
النتيجة: كود منى بيترتب خطياً ومباشرة فوق كود أحمد، ومبيتخلقش الـ Merge Commit الوهمي ده نهائي.

```text
Traditional git pull (creates merge commit M):
Local:  A --- B --- D
Remote: A --- B --- C
Result: A --- B --- C --- D --- M (HEAD)

git pull --rebase (replays local D as D' on top of C):
Local:  A --- B --- D
Remote: A --- B --- C
Result: A --- B --- C --- D' (HEAD, clean linear history)
```

```bash
# Pull remote updates and rebase your local commits on top of them
git pull --rebase origin main

# Set Git to always use rebase by default for all pulls (Best Practice)
git config --global pull.rebase true
```

#### مثال 1: ضبط الإعداد العالمي (Global config)
منى كتبت الأمر `git config --global pull.rebase true` على جهازها مرة واحدة. من اللحظة دي، كل ما تكتب `git pull` الـ Git هيعمل rebase تلقائي للتعديلات المحلية بدون ما تضطر تكتب علم `--rebase` يدوياً في كل مرة.

#### مثال 2: حدوث تعارض أثناء الـ pull --rebase
أحمد عدل نفس الملف اللي منى عدلته محلياً. لما منى عملت `git pull --rebase` العملية وقفت بسبب Conflict. منى محتاجة تفتح الملف، تحل التعارض، تعمل `git add` وتكمل بـ `git rebase --continue` كأنها بتعمل rebase عادي جداً لحد ما العملية تنتهي والـ push يبقى جاهز.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What does `git pull --rebase` do, and how does it prevent the creation of unnecessary merge commits during daily synchronization?"*
>
> **الإجابة المثالية:**
> يقوم `git pull` التقليدي بإجراء `git fetch` ثم `git merge` للفرع البعيد، مما يتسبب في إنشاء تسجيل دمج وهمي (Sync Merge Commit) لمجرد دمج التعديلات المحلية غير المرفوعة مع تعديلات السيرفر. أما `git pull --rebase` فيقوم بإجراء `git fetch` ثم `git rebase`؛ حيث يأخذ الكوميتس المحلية التي لم تدفع بعد ويركنها جانباً، ويحدث الفرع المحلي ليتطابق مع السيرفر، ثم يعيد تطبيق (Replay) الكوميتس المحلية فوق أحدث نسخة من السيرفر. هذا يمنع تكوين تسجيلات الدمج الوهمية ويحافظ على شجرة تاريخ خطية ونظيفة تماماً.

---

## Q36 — إيه هو الـ `git cherry-pick`؟ وإزاي بيشتغل تحت الغطاء؟ وإيه الحالات اللي بنحتاجه فيها؟

### أصل الحكاية
في InboxSales، منى كانت شغالة على ميزة كبيرة ومعقدة في فرع اسمه `feature-heavy-reports` وعملت 10 commits.
أثناء الشغل، العميل كلم الدعم الفني وقالهم إن فيه Bug خطير بيعمل crash للسيستم لما يختاروا تقرير شهر ديسمبر على الـ Production.
منى دخلت في فرعها وعملت تصليح سريع للـ Bug ده وسجلته في commit واحد الـ Hash بتاعه `9a2b3c4`.
المشكلة إن ميزة التقارير نفسها لسه مش جاهزة للإطلاق ومفيهاش اختبارات كافية، فمتقدرش تعمل merge للفرع كله لـ `main` عشان متبوظش الـ production بكود غير ناضج.
الحل السحري لمنى هنا هو إنها تدخل في فرع الـ `main` وتعمل "لقط كرزة" (Cherry-pick) للـ Commit ده بالذات `9a2b3c4` وتسحبه لوحده وتطبقه على `main`.
تحت الغطاء، الـ Git بيروح يشوف الـ Diff (التغييرات) اللي حصلت جوة الكوميت `9a2b3c4` في الفرع التاني، ويقوم بتطبيق نفس التغييرات دي بالظبط كـ commit جديد تماماً بـ SHA-1 Hash جديد على فرع الـ `main`.

```bash
# 1. Switch to the target branch where you want the fix (main)
git switch main

# 2. Apply the specific commit from the feature branch
git cherry-pick 9a2b3c4
# Output: [main 4f5e6d7] fix: resolve December report crash
```

#### مثال 1: حدوث تعارض أثناء لقط الكرزة
منى جربت تعمل `git cherry-pick 9a2b3c4` بس الكوميت ده كان بيعدل كود في ملف حصل فيه تعديلات تانية على الـ `main` وحصل conflict. الـ Git هيوقف العملية فوراً. منى هتدخل تحل التعارض في الكود، وتعمل `git add` وتكمل بـ `git cherry-pick --continue` عشان يسجل الكوميت، أو تكتب `git cherry-pick --abort` لو حست إن العملية مش نافعة وعايزة تتراجع تماماً.

#### مثال 2: سحب مجموعة كوميتس (Cherry-picking a range)
لو منى محتاجة تسحب 3 commits ورا بعض من فرع التقارير للـ `main`؛ تقدر تحدد رينج كامل للأمر:
`git cherry-pick 9a2b3c4^..8d9e0f1`
الـ Git هيسحب الكوميتس دي كلها بالترتيب ويطبقها على `main`.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain what `git cherry-pick` is, how it functions under the hood, and describe a real-world scenario where it is the most appropriate solution."*
>
> **الإجابة المثالية:**
> الأمر `git cherry-pick` هو أداة تتيح للمطورين تطبيق التغييرات التي أدخلها commit معين من أي فرع في المستودع إلى الفرع الحالي النشط بشكل انتقائي ودون الحاجة لدمج الفرع المصدر بأكمله.
> تحت الغطاء، يقوم Git باستخراج الـ Diff الخاص بالـ commit المحدد وتطبيقه كـ commit جديد كلياً بـ SHA-1 Hash جديد فوق الـ HEAD للفرع الحالي.
> **سيناريو استخدام حقيقي:**
> عند اكتشاف ثغرة أو Bug عاجل في بيئة الإنتاج (Production)، ويقوم أحد المطورين بإصلاحها وتسجيلها في commit منفرد داخل فرع ميزة طويل الأجل (Long-lived feature branch) غير مكتمل وغير جاهز للإطلاق بالكامل؛ يتم استخدام `git cherry-pick` لسحب هذا الـ commit التحديد وتطبيقه منفرداً على فرع الإصدار الرئيسي لترقيته وحل المشكلة فوراً دون الاضطرار لدمج الميزات غير المكتملة.

---

## Q37 — إيه الفرق الجوهري بين `git revert` و `git reset`؟ وإمتى بنستخدم كل واحد فيهم حسب حالة الفرع (Local vs Public)؟

### أصل الحكاية
أحمد كتب كود وسجل commit محلي، وبعد خمس دقائق اكتشف إن الفكرة كلها غلط وعايز يلغيها كأنها محصلتش.
وفي نفس الوقت، شادي كان شغال على فرع مشترك ورفع commit غلط على السيرفر (GitHub) والعميل شافه واشتكى.
هنا بيحصل خلط شهير بين الـ `reset` والـ `revert`.
- **الـ `git reset`:** بيقوم بنقل مؤشر الـ HEAD والفرع الحالي لورا، وبيمسح الكوميتس من التاريخ تماماً. العملية دي آمنة وممتازة طالما الكوميتس دي **محلية على جهازك ولسه مرفعتهوش للسيرفر** (Local commits). لو رفعتها وعملت reset وعايز ترفع بـ force push، هتخرب شغل زمايلك اللي سحبوا كودك.
- **الـ `git revert`:** هو البطل المنقذ للـ **فروع المشتركة والعامة** (Public commits). الـ revert مبيلمسش التاريخ القديم؛ هو بيعمل كوميت جديد تماماً جواه عكس التعديلات اللي حصلت في الكوميت القديم. بكدة التاريخ بيمشي لقدام بأمان، ومحدش من زمايلك هيحصله مشاكل في الـ hashes.

```text
Commit Tree: A --- B --- C (HEAD)

After git reset --hard B (C disappears from history):
A --- B (HEAD)

After git revert C (Creates new commit D that undoes C):
A --- B --- C --- D (HEAD, C is still in history, D reverses C's code changes)
```

```bash
# Safely undo a local commit that was never pushed
git reset --hard HEAD~1

# Safely undo a public commit that is already on GitHub
git revert 9a2b3c4
# (This creates a new commit undoing the changes of 9a2b3c4)
```

#### مثال 1: خطر إفشاء الأسرار والـ Revert
منى كتبت API key سري جداً في ملف ورفعته على GitHub بالخطأ. لما اكتشفت الغلطة، عملت `git revert` للكوميت ده عشان تلغيه. هل الـ Key كدة بقى آمن؟
لا طبعاً! لأن الـ `git revert` ساب الكوميت القديم في تاريخ المشروع، والناس تقدر ترجع في الـ commits وتشوف الـ Key بكل سهولة. في الحالة دي الـ revert غير كافي؛ لازم الـ Key يتغير فوراً من السيرفر الأصلي، أو يُحذف الكوميت من السجل تماماً بأدوات تنظيف التاريخ مثل `git-filter-repo`.

#### مثال 2: استخدام الـ reset لتغيير هيكل الكوميتس
كريم عمل commit لقى نفسه حط فيه 10 ملفات معدلة، وحس إن الكوميت ده ضخم ومحتاج يقسمه لـ 3 commits صغيرة عشان الكود ريفيو يبقى مريح.
كتب: `git reset --soft HEAD~1`
الكوميت اتلغى، بس الملفات الـ 10 فضلت موجودة في الـ Staging area (باللون الأخضر). كريم بدأ يعمل add لملفين ملفين ويعمل commits منفصلة ونظيفة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the fundamental differences between `git reset` and `git revert`. Under what conditions should you use one over the other?"*
>
> **الإجابة المثالية:**
> الفرق الجوهري هو أن `git reset` يقوم بإعادة كتابة التاريخ عبر إرجاع مؤشر الـ HEAD والفرع إلى الخلف وإسقاط الـ commits المستهدفة كأنها لم تكن، وهو أداة مناسبة فقط للـ commits المحلية (Local) التي لم تدفع بعد إلى مستودع بعيد. أما `git revert` فيقوم بإنشاء commit جديد تماماً يحتوي على تعديلات عكسية (Anti-changes) للـ commit المستهدف مع الحفاظ على الكوميت الأصلي وتاريخ المشروع دون تعديل، مما يجعله الخيار الآمن والوحيد للفروع العامة والمشتركة (Public Branches) لتجنب تخريب بيئة العمل لبقية المطورين.

---

## Q38 — إزاي بنعمل Revert لـ Merge Commit؟ وإيه سر خيار `-m 1` وليه الموضوع ده بيبقى محير للمطورين؟

### أصل الحكاية
أحمد دمج فرع الضرائب `feature-tax` في الـ `main` وتخلق Merge Commit بالرمز `M`. بعدها بنصف ساعة، اكتشفوا إن كود الضرائب بيعمل عمليات حسابية غلط وبوظ الفواتير على السيرفر.
التيك ليد قاله: "الغى الـ merge ده فوراً ورجع الكود للوضع السليم!".
أحمد كتب `git revert M`. فجأة الـ Git رفض وقال له:
`error: commit M is a merge but no -m option was given.`
أحمد اتلخبط، إيه الـ `-m` دي؟
الموضوع ببساطة إن الـ Merge Commit `M` ناتج عن تلاقي فرعين؛ وبالتالي هو عنده اتنين آباء (Two Parents):
- الأب الأول (Parent 1): هو آخر كوميت في فرع الـ `main` قبل الدمج (الـ Mainline).
- الأب الثاني (Parent 2): هو آخر كوميت في فرع الميزة `feature-tax`.

الـ Git هنا محتار وبيسألك: "أنا لما ألغي الـ merge ده، المفروض أرجع الكود لأي مسار تاريخي؟ هل أرجع للـ `main` وألغي الضرائب، ولا أرجع للـ `feature-tax` وألغي الـ `main`؟"
عشان نحدد المسار، بنستخدم خيار الـ Mainline (`-m`):
- `-m 1` تعني الرجوع للأب الأول (الفرع الأصلي اللي واقفين فيه وهو الـ `main`).
- `-m 2` تعني الرجوع للأب الثاني (فرع الميزة).

```bash
# Revert the merge commit M and keep the changes of parent 1 (main branch codebase)
git revert -m 1 M_COMMIT_HASH
```

#### مثال 1: فخ إعادة دمج فرع الميزة لاحقاً
أحمد عمل `git revert -m 1 M` والسيستم رجع سليم. بعد يومين، أحمد دخل فرع الضرائب وصلح الـ bug وجرب يعمل merge تاني للـ `main`.
تفاجأ إن الـ Git قاله: "مفيش أي تعديلات جديدة للدمج!" وملفات الضرائب مظهرتش على الـ `main`!
السبب: الـ Git شايف إن الكوميتس القديمة لفرع الضرائب موجودة بالفعل في شجرة التاريخ ومحصلهاش مسح، والـ Revert لغى كودها بس ممسحش الكوميتس نفسها.
عشان أحمد يحل المشكلة دي، لازم الأول يدخل الـ `main` ويعمل revert لكوميت الـ revert نفسه (Revert the Revert) عشان يحيي كود الضرائب القديم تاني، وبعدين يعمل دمج لكوده الجديد!

#### مثال 2: خطورة `-m 2` بالخطأ
كريم كتب `-m 2` بالخطأ عند إلغاء الدمج. الـ Git اعتبر إن التاريخ الأساسي هو فرع الضرائب ومسح كل التحديثات اللي كانت موجودة في الـ `main` ومكنتش موجودة في فرع الضرائب! السيستم انهار تماماً واضطروا يعملوا abort ويتراجعوا.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Why does reverting a merge commit require the `-m` (mainline) option, and what are the implications when you decide to merge the same branch again later?"*
>
> **الإجابة المثالية:**
> يتطلب التراجع عن تسجيل دمج (Merge Commit) خيار `-m` (الاختصار لـ `--mainline`) لأن تسجيل الدمج يمتلك أكثر من أب (Parents)، وبالتالي يجب تحديد رقم الأب الذي يمثل المسار التاريخي الرئيسي الذي يجب إبقاء الكود عليه (غالباً `-m 1` للفرع الذي تم الدمج فيه).
> **الآثار المستقبلية:**
> عند إجراء الـ Revert، يقوم Git بإلغاء التعديلات البرمجية فقط وليس الـ commits هيكلياً. إذا حاولت دمج نفس فرع الميزة لاحقاً، سيرفض Git إعادة تطبيق التغييرات القديمة لأنه يعتبرها مدمجة مسبقاً. للتغلب على ذلك، يجب أولاً التراجع عن تسجيل التراجع نفسه (Revert the Revert Commit) لإعادة تفعيل الكود الملغى، ثم إجراء الدمج الجديد.

---

## Q39 — إيه الفرق بالتفصيل الممل بين `git reset` بأوضاعه التلاتة: `--soft` و `--mixed` و `--hard`؟

### أصل الحكاية
شادي شغال في InboxSales وعنده تعديلات في ملفين: `db.js` و `server.js`. عمل commit بالخطأ وعايز يرجع فيه بـ `git reset HEAD~1`. 
بس لقى زمايله بيسألوه: "إنت هتعمل reset بأنهي وضع؟ soft ولا mixed ولا hard؟"
شادي قرر يفهم الفرق بين التلاتة بدقة لأن اختيار الوضع الغلط ممكن يمسح شغله كله في ثانية!
التأثير بيكون على تلات مناطق في Git:
1. **Working Directory (فولدر المشروع على جهازك).**
2. **Staging Area / Index (مكان تحضير الكوميت).**
3. **Commit History (شجرة الكوميتس).**

| الوضع | هل بيحرك مؤشر HEAD والـ Branch؟ | هل بيأثر على الـ Staging Area؟ | هل بيأثر على الـ Working Directory؟ |
| :--- | :---: | :---: | :---: |
| **`--soft`** | نعم | لا (الملفات بتفضل Staged) | لا (تعديلاتك في الملفات سليمة) |
| **`--mixed`** (الافتراضي) | نعم | نعم (الملفات بتبقى Unstaged) | لا (تعديلاتك في الملفات سليمة) |
| **`--hard`** | نعم | نعم (بيفضي الـ Staging) | نعم (بيمسح كل التعديلات والكود تماماً!) |

```bash
# Soft reset: keeps changes in staging area, deletes the commit record
git reset --soft HEAD~1

# Mixed reset (default): moves changes to working directory, unstages them
git reset --mixed HEAD~1
# (Same as: git reset HEAD~1)

# Hard reset: DESTROYS all changes in commits, staging, and files!
git reset --hard HEAD~1
```

#### مثال 1: استخدام `--soft` لإعادة صياغة الكوميت
شادي عمل commit ولقى إنه كتب رسالة مش واضحة، ونسى يضيف ملف `env.example`. كتب `git reset --soft HEAD~1`. الكوميت اختفى، والملفات فضلت في الـ staging باللون الأخضر. شادي ضاف الملف وعمل الكوميت من جديد برسالة صح.

#### مثال 2: استخدام `--mixed` لفرز الملفات
منى عملت `git add .` ولقيت نفسها ضافت ملفات Log تالفة بالخطأ وعملت commit. كتبت `git reset HEAD~1` (وهو mixed تلقائياً). الملفات كلها رجعت للون الأحمر (Unstaged). عملت استثناء لملفات الـ Log وعملت add للملفات البرمجية بس.

#### مثال 3: كارثة الـ `--hard`
أحمد كتب كود جديد بالكامل بقاله 5 ساعات ومكنش عمله commit، وكتب `git reset --hard HEAD~1`. الـ Git مسح كود الـ commit الأخير، وكمان مسح كوده اللي لسه كاتبه ومكنش متسجل، ورجع الفولدر نظيف تماماً لحالة الكوميت ما قبل الأخير. الكود ضاع (إلا لو لحقه بطرق تانية زي الـ IDE history).

### الفايدة الانترفيوية
> **Interview Question:**
> *"Detail the differences between `git reset --soft`, `--mixed`, and `--hard` in terms of their effects on the HEAD pointer, index (staging area), and working directory."*
>
> **الإجابة المثالية:**
> تتحكم خيارات `git reset` في مدى تراجع التغييرات في بيئات العمل الثلاث للـ Git:
> - **`--soft`:** يقوم بنقل مؤشر الـ HEAD والفرع الحالي فقط إلى الكوميت المحدد، مع الاحتفاظ بجميع التغييرات التي كانت في الكوميتس الملغاة داخل الـ Staging Area (Index)؛ مما يتيح إعادة التزام الكود فوراً.
> - **`--mixed` (الوضع الافتراضي):** ينقل الـ HEAD ويقوم بتحديث الـ Staging Area لتتطابق مع الكوميت الذي تم الرجوع إليه (أي يلغي إعداد الملفات Staging)، ولكنه يترك ملفات دليل العمل (Working Directory) كما هي دون تعديل؛ مما يعيد التغييرات كملفات معدلة باللون الأحمر (Unstaged).
> - **`--hard`:** هو الخيار الأكثر خطورة؛ حيث ينقل الـ HEAD، ويفرغ الـ Staging Area، ويقوم بمسح كافة التغييرات والتعديلات في دليل العمل (Working Directory) لتتطابق تماماً مع الكوميت المستهدف، مما يتسبب في تدمير وفقدان أي تعديلات غير مسجلة أو كود كتب بعد تلك النقطة.

---

## Q40 — الكارثة حصلت وعملت `git reset --hard` بالخطأ وكودك ضاع! إزاي الـ `git reflog` بينقذ حياتك ويرجع الكود؟

### أصل الحكاية
شادي في InboxSales عمل `git reset --hard HEAD~3` عشان يتخلص من شوية كوميتس قديمة، بس فجأة ضربت ركبه في بعضها واكتشف إنه رجع بزيادة ولغى 3 commits فيهم شغل يومين كاملين!
شادي قعد على مكتبه مصدوم وفاكر إن شغله ضاع للأبد لأن الهارد ديسك اتمسح.
أحمد لقى شادي منهار، قاله: "اهدى خالص يا شادي، في Git مفيش حاجة بتضيع بسهولة طالما اتعملها Commit ولو لمرة واحدة! الـ Git عنده صندوق أسود بيسجل فيه كل حركاتك وجريمتك دي متسجلة في حاجة اسمها **Reflog**".
تحت الغطاء: الـ Git بيحتفظ بسجل محلي سري اسمه Reference Log (Reflog) في المسار `.git/logs/`.
الملف ده بيسجل أي حركة لمؤشر الـ HEAD؛ سواء عملت checkout، أو switch، أو commit، أو reset، أو merge.
حتى لو الكوميتس مبقتش ظاهرة في الـ `git log` العادي (بقت Dangling Commits)، الـ Reflog بيفضل شايل الـ SHA-1 Hashes بتاعتها لمدة 30 لـ 90 يوم قبل ما الـ Garbage Collector يمسحها.

```bash
# 1. Open the Git black box logs
git reflog

# Output looks like this:
# a1b2c3d HEAD@{0}: reset: moving to HEAD~3 (The mistake!)
# e5f6g7h HEAD@{1}: commit: feat: complete database schema (The lost commit!)
# i8j9k0l HEAD@{2}: commit: feat: setup router

# 2. Rescue your code by pointing the branch back to the lost commit
git reset --hard e5f6g7h

# Or safely create a new branch at that lost commit to inspect first:
git switch -c feature-rescued e5f6g7h
```

#### مثال 1: شادي بيرجع شغله في دقيقتين
شادي كتب `git reflog` ولقى السطر `HEAD@{1}` هو الكوميت الضائع. كتب `git reset --hard HEAD@{1}`. السحر حصل! كل الملفات رجعت على جهازه، والكوميتس التلاتة ظهروا تاني في الـ log كأن مفيش أي حاجة حصلت.

#### مثال 2: Reflog هو سجل محلي خاص بجهازك
Reflog هو سجل محلي خاص بجهاز المطور نفسه (Local-only). يعني لو شادي عمل الكارثة دي على جهازه، وراح يسأل أحمد يفتح الـ reflog عنده، أحمد مش هيلاقي حركات شادي عنده خالص لأن السيرفر مبيسجلش الـ reflog بتاع المطورين، فهو ينقذ الموقف محلياً فقط.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain what `git reflog` is, how it differs from `git log`, and how it can be used to recover commits lost due to a destructive command like `git reset --hard`."*
>
> **الإجابة المثالية:**
> الـ `git reflog` (Reference Log) هو آلية محلية يقوم Git من خلالها بتسجيل كافة التغييرات والتحركات التي تطرأ على مؤشر الـ HEAD والمراجع المحلية (مثل التبديل بين الفروع، الـ commits، الـ resets، والـ merges).
> **الفرق بينه وبين `git log`:**
> - **`git log`:** يعرض تاريخ الـ commits الخاص بالفرع الحالي فقط، وإذا تم مسح commits بـ reset تختفي منه تماماً.
> - **`git reflog`:** يعرض سجلاً زمنياً خطياً لكل الحركات المحلية التي قام بها المطور على جهازه، حتى لو كانت تشير إلى commits ممسوحة أو يتيمة (Dangling/Orphaned Commits).
> **طريقة الاسترجاع:**
> عند حدوث `git reset --hard` بالخطأ، نقوم بتشغيل `git reflog` لرؤية الـ SHA-1 Hash الخاص بالكوميت المفقود قبل عملية الـ reset مباشرة (غالباً يظهر بجانب علامة `HEAD@{1}` أو ما شابه)، ثم نستخدم `git reset --hard <lost-commit-hash>` لإعادة توجيه الفرع الحالي إلى تلك النقطة المسترجعة بالكامل، أو ننشئ فرعاً جديداً عندها بـ `git switch -c <new-branch> <hash>`.

---

## Q41 — دمج الفروع في الشركات الكبيرة: إمتى بنستخدم الـ Merging وإمتى الـ Rebasing؟ وإيه دور الـ Git Flow والـ Trunk-Based Development؟

### أصل الحكاية
في InboxSales، ومع زيادة عدد المطورين لـ 20 مهندس، بدأت تحصل خناقات يومية وقت دمج الكود. التيك ليد قعد مع الفريق وقرر يحدد استراتيجية واضحة للدمج مبنية على بيئة عمل المشروع وسرعة الإطلاق.
الشركات الكبيرة بتوازن بين مدرستين في الدمج حسب هيكل التطوير:
1. **إستراتيجية الـ Git Flow (الكلاسيكية/المنظمة):**
   - بتعتمد على فروع طويلة الأمد زي `main` و `develop` وفروع ميزات `feature/...` وفروع إصدارات `release/...`.
   - بتفضل استخدام الـ **Merging** مع علم `--no-ff` (حفظ شجرة التفرعات كاملة) عشان يكون فيه توثيق واضح ومراجعة دقيقة لكل ميزة ككتلة واحدة مدمجة.
2. **إستراتيجية الـ Trunk-Based Development (الحديثة/السريعة):**
   - المطورين بيشتغلوا على فرع رئيسي واحد (Trunk/main) وبيعملوا فروع ميزات قصيرة الأمد جداً (ساعات أو أيام قليلة) ويدمجوا فوراً.
   - بتفضل استخدام الـ **Rebasing** أو **Squash and Merge** عشان يفضل الـ main خطي تماماً، وسريع في التحديث، ومتوافق مع أنظمة الـ CI/CD للدمج والإطلاق المستمر.

```bash
# Trunk-based workflow: Keep feature fresh with rebase, then merge
git checkout feature-micro
git rebase main
# (Resolve conflicts local)
git switch main
git merge --ff-only feature-micro # Safe linear push
```

#### مثال 1: خيار "Squash and Merge" على GitHub
على GitHub، التيك ليد ظبط إعدادات الـ Pull Requests عشان تفرض Squash and Merge عند الموافقة. ده معناه إن منى لما تخلص فرع التقارير وفيه 15 commit، لما نضغط دمج على GitHub، الموقع بيدمج الـ 15 commit دول كلهم في commit واحد نظيف على الـ `main`. ده بيجمع ميزة الـ Rebase (نظافة الـ main الخطي) مع ميزة الـ Merge (سهولة تتبع الميزة).

#### مثال 2: خطورة الـ Rebase في بيئة الـ Git Flow
لو أحمد شغال Git Flow وجرب يعمل rebase لفرع الـ `develop` المشترك على الـ `main`؛ هيمنع باقي زمايله من الدمج لعدة أيام وهيوقف الشركة كلها. عشان كدة في Git Flow الـ Merge هو الملك والـ Rebase ممنوع تماماً على الفروع المشتركة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Discuss when a large team should adopt a Merging strategy versus a Rebasing strategy. How do these strategies align with Git Flow and Trunk-Based Development workflows?"*
>
> **الإجابة المثالية:**
> تعتمد المفاضلة بين Merging و Rebasing على ثقافة الفريق ومنهجية إطلاق البرمجيات:
> - **نعتمد على الـ Merging (Git Flow):** عندما يكون المشروع يتطلب تتبعاً دقيقاً وموثقاً لكل خطوة وتفرع (Auditability)، وحيث يتم العمل بفروع طويلة الأمد ذات إصدارات متباعدة. هنا يفضل استخدام `git merge --no-ff` لتوثيق تاريخ الدمج بشكل صريح وتسهيل التراجع عن الإصدارات.
> - **نعتمد على الـ Rebasing / Squash (Trunk-Based Development):** عندما نهدف للإطلاق السريع والدمج المستمر (CI/CD)، وحيث تكون الفروع قصيرة الأجل (Short-lived). يساعد الـ Rebasing في إبقاء فرع الـ main خطياً وخالياً من التشويش، مما يسهل عمليات الأتمتة والاختبار وتتبع الأعطال بـ `git bisect`.
> - **الحل الهجين (Hybrid):** هو استخدام الـ Rebase محلياً للمطور لتنظيف فرعه، ثم إجراء "Squash and Merge" عند الدمج النهائي على GitHub للحصول على خط تاريخ نظيف على الرئيسي مع الحفاظ على خصوصية فروع المطورين.

---

## Q42 — يعني إيه `git clean`؟ وإزاي بتنظف مجلد المشروع من الملفات غير المتابعة (Untracked Files) بأمان؟

### أصل الحكاية
شادي كان بيجرب مكتبة بتولد ملفات PDF وصور تجريبية كتيرة في فولدر المشروع. بعد ما خلص، لقى عنده 50 ملف تجريبي غير متابع (Untracked Files) باللون الأحمر في الـ `git status`.
شادي مش عايز الملفات دي ومش عايز يمسحهم ملف ملف يدوياً لأن الموضوع ممل وممكن يغلط.
أحمد قاله: "استخدم المكنسة الكهربائية بتاعة الـ Git وهي أمر `git clean`".
أمر `git clean` مخصص لمسح الملفات غير المتابعة (التي لا يراقبها Git وليست في `.gitignore`).
ولأن الأمر ده مدمر (بيمسح ملفات من الهارد ديسك بدون رجعة)، الـ Git بيحميك بشكل افتراضي وبيمنع تشغيله إلا لو حددت خيارات معينة للتأكيد.

```bash
# 1. DRY RUN: Preview what files will be deleted without actually deleting them (ALWAYS DO THIS FIRST!)
git clean -n
# Output: Would remove temp_invoice.pdf

# 2. FORCE: Actually delete the untracked files
git clean -f
# Output: Removing temp_invoice.pdf

# 3. DIRECTORIES: Delete untracked files and untracked folders too
git clean -fd

# 4. IGNORED TOO: Delete untracked files, folders, AND files listed in .gitignore (e.g. node_modules)
git clean -fdx
```

#### مثال 1: فخ الـ `git clean -fdx`
أحمد شغال في مشروع Node.js وحب يمسح مجلد `node_modules` والملفات المؤقتة تماماً عشان يعيد تنزيل المكتبات نظيفة. كتب `git clean -fdx`. الـ Git مسح الـ `node_modules` وأي ملفات `.env` محلية مش مرفوعة على السيرفر (لأنها متفلترة في gitignore). أحمد كان كاتب إعدادات سرية في `.env` وضاعت واضطر يكتبها من جديد. عشان كدة لازم الحذر الشديد مع خيار `x`.

#### مثال 2: التشغيل التجريبي (Dry Run)
شادي كتب `git clean -n`. الـ Git قاله: "لو اشتغلت حقيقي، همسح ملف `test-output.json` و `debug.log`". شادي لقى ملف `test-output.json` فيه داتا تهمه، فنقله بره الفولدر وبعدين كتب `git clean -f` عشان يمسح الباقي بأمان.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the purpose of `git clean`? Explain the differences between `-n`, `-f`, `-d`, and `-x` flags, and discuss the safety precautions associated with this command."*
>
> **الإجابة المثالية:**
> يُستخدم الأمر `git clean` لتنظيف دليل العمل (Working Directory) عبر إزالة الملفات غير المتابعة (Untracked Files) التي لا يراقبها Git بشكل دائم وسريع.
> **دلالات الأعلام (Flags):**
> - **`-n` (Dry Run):** يقوم بعرض تجريبي للملفات والمجلدات التي سيتم حذفها دون إجراء الحذف الفعلي، وهو صمام الأمان الأهم للاستخدام قبل التنفيذ.
> - **`-f` (Force):** فرض الحذف الفعلي للملفات غير المتابعة (حيث يرفض Git تشغيل الأمر بدونه كإجراء وقائي).
> - **`-d`:** يمتد الحذف ليشمل المجلدات غير المتابعة (Untracked Directories) بالكامل بجانب الملفات.
> - **`-x`:** يقوم بحذف جميع الملفات غير المتابعة، بما فيها الملفات المتجاهلة المدرجة في `.gitignore` (مثل ملفات التكوين المحلية أو مجلدات الحزم مثل node_modules).
> **احتياطات الأمان (Safety Precautions):**
> الـ `git clean` هو أمر مدمر للملفات غير المتابعة ولا يمكن التراجع عنه أو استرجاعه بـ `git reflog` (لأن الملفات لم تدخل قواعد بيانات Git أبداً). لذلك، يجب دائماً تشغيل `git clean -n` أولاً للتأكد من قائمة الملفات المستهدفة، والحذر البالغ عند استخدام خيار `-x` لتجنب حذف ملفات البيئة الحساسة مثل `.env`.

> [!tip] Checkpoint
> بكدة نكون قفلنا موضوع إعادة بناء التاريخ والدمج المتقدم (Topic 4). دلوقتي إنت بقيت فاهم الفرق بين الـ Merge والـ Rebase، وإزاي تنظف تاريخك بـ Interactive Rebase وتنقذ نفسك بـ Reflog لو غلطت، وتتحكم بالملفات غير المتابعة بـ clean. يلا بينا ندخل في الكور بتاع GitHub والـ Remote Workflows (Topic 5)!

---

# Topic 5 — Remote Workflows & Collaboration (بيئة العمل الجماعي والمزامنة)

## Q43 — يعني إيه Git Remote؟ وإزاي الـ Git بيتابع المستودعات البعيدة (Remote Repositories) تحت الغطاء؟

### أصل الحكاية
في InboxSales، الكود كله مرفوع على GitHub. لما أحمد بينزل المشروع على جهازه، أو بينشئ مستودع محلي ويربطه بالسيرفر، بيتعامل مع مفهوم الـ "Remote".
الـ Remote هو ببساطة رابط (URL) بيشير لنسخة المشروع المستضافة على سيرفر خارجي (زي GitHub أو GitLab). الاسم الافتراضي الشائع للرابط ده هو `origin`، بس تقدر تسميه أي اسم تاني تحبه.
تحت الغطاء، Git مبيعملش اتصال مستمر بالإنترنت. هو شغال محلياً بنسبة 100%. عشان يتابع الفرع البعيد، بيستخدم مراجع خاصة اسمها "Remote-Tracking Branches".
دي مؤشرات للقراءة فقط (Read-only local pointers) بتعبر عن حالة الفرع على السيرفر لحظة آخر عملية اتصال (fetch أو push).
المراجع دي متخزنة في الفولدر السري `.git` تحت المسار:
`.git/refs/remotes/origin/`
جوا الفولدر ده هتلاقي ملفات بأسماء الفروع، زي ملف اسمه `main`. الملف ده مكتوب جواه الـ SHA-1 Hash بتاع آخر commit كانت موجودة على السيرفر وقت آخر تحديث.

```bash
# 1. إظهار روابط الـ Remotes المرتبطة بالمشروع
git remote -v
# Output:
# origin  https://github.com/InboxSales/GRAD-inpoxsales.git (fetch)
# origin  https://github.com/InboxSales/GRAD-inpoxsales.git (push)

# 2. إضافة Remote جديد باسم مخصص
git remote add upstream https://github.com/OriginalOwner/GRAD-inpoxsales.git

# 3. إظهار تفاصيل كاملة عن Remote معين والفروع المتابعة
git remote show origin
```

#### مثال 1: أحمد بيعدل الكود محلياً وشادي شغال على السيرفر
أحمد كاتب كود ومخلص شغل على جهازه، والـ Git status بيقوله إن فرعه المحلي متطابق مع `origin/main`. في نفس اللحظة، شادي رفع كوميت جديدة على GitHub.
لو أحمد كتب `git status` دلوقتي، الـ Git هيقوله برضه إنه متطابق! ليه؟ لأن Git مبيكلمش السيرفر مع كل أمر status.
لازم أحمد يكتب `git fetch origin` الأول. وقتها الـ Git هيتصل بالـ Remote وينزل التغييرات الجديدة، ويحرك المؤشر اللي في الملف `.git/refs/remotes/origin/main` للكوميت الجديدة. بعد كدة لو أحمد كتب `git status` هيقوله:
`Your branch is behind 'origin/main' by 1 commit.`

#### مثال 2: ملف الإعدادات `.git/config`
لو فتحنا ملف `.git/config` على جهاز أحمد، هنلاقي السطور دي اللي بتوضح إزاي Git بيربط الفروع وبيرسم خريطة المزامنة (Refspec):
```ini
[remote "origin"]
    url = https://github.com/InboxSales/GRAD-inpoxsales.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```
السطر الأخير (`fetch`) بيقول للـ Git: "لما تعمل fetch من origin، خد كل الفروع اللي تحت `refs/heads/` على السيرفر، وحطها في جهاز المطور تحت اسم `refs/remotes/origin/`".

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is a Git Remote, and how does Git track remote repositories under the hood? Explain remote-tracking branches."*
>
> **الإجابة المثالية:**
> الـ Git Remote هو مرجع أو رابط يؤشر إلى نسخة من المستودع (Repository) مستضافة على سيرفر خارجي مثل GitHub. الاسم الافتراضي لهذا المرجع هو `origin`.
> يقوم Git بمتابعة المستودع البعيد محلياً عن طريق مراجع خاصة تسمى **Remote-Tracking Branches** وتُخزن في المسار `.git/refs/remotes/<remote-name>/`.
> هذه المؤشرات هي مؤشرات محددة للقراءة فقط (Read-only) ولا يمكن للمطور الكتابة عليها مباشرة أو تعديلها محلياً؛ بل تتحرك فقط عند حدوث تواصل فعلي مع السيرفر عبر الأوامر `git fetch` أو `git push` أو `git pull`. يساعد هذا التصميم Git على العمل بشكل مستقل تماماً وسريع دون الحاجة للاتصال المستمر بالشبكة لمعرفة الفروقات بين الكود المحلي وكود السيرفر.

---

## Q44 — إيه الفرق بين `git fetch` و `git pull` على مستوى الـ Object Database والـ Internals؟

### أصل الحكاية
منى سألت شادي في InboxSales: "أنا عايزة أشوف التعديلات اللي زمايلنا عملوها على السيرفر، بس خايفة أعمل `git pull` يعكلي الكود بتاعي أو يعمل Conflicts مع التغييرات اللي لسه مخلصتهاش محلياً".
شادي قالها: "استخدمي الـ Fetch، لأن الـ Fetch آمن تماماً، عكس الـ Pull اللي بيعمل دمج فوراً".
الفرق بين الاتنين جوهري وبيحصل تحت الغطاء كالتالي:
1. **`git fetch`**:
   - بيتصل بالسيرفر الخارجي.
   - بيشوف لو فيه Commits جديدة مش موجودة في جهازك.
   - بيقوم بتحميل الـ Objects الجديدة والـ Packfiles ويحطها جوة الـ Object Database (`.git/objects`).
   - بيحدث الـ Remote-tracking branches (زي `origin/main`) ويحدث مرجع مؤقت اسمه `FETCH_HEAD` عشان يشير لآخر كوميت نزلت.
   - **لا يلمس** الـ Working Directory ولا يغير الكود اللي شغال عليه ولا يعدل فروعك المحلية. هو فقط بيحدث "معلومات السيرفر" جوة فولدر `.git`.
2. **`git pull`**:
   - هو أمر مركب (Shortcut) بيعمل وظيفتين ورا بعض:
     1. بيشغل `git fetch` لتنزيل الـ Objects وتحديث مؤشرات الـ remote.
     2. بيشغل تلقائياً خطوة دمج (غالباً `git merge` أو `git rebase` حسب إعداداتك) لدمج التغييرات الجديدة في فرعك المحلي الحالي وتحديث الـ Working Directory.

```bash
# 1. تنزيل التغييرات بأمان تام ودون تعديل الكود الحالي
git fetch origin

# 2. مقارنة الكود المحلي باللي نزل من السيرفر قبل الدمج
git diff main origin/main

# 3. رؤية لوج السيرفر والكوميتس الجديدة
git log main..origin/main

# 4. دمج التعديلات يدوياً بعد الاطمئنان
git merge origin/main

# 5. الأمر البديل المباشر (Fetch + Merge)
git pull origin main
```

#### مثال 1: منى بتتفادى الـ Conflicts
منى كتبت `git fetch origin`. الـ Git نزل 3 كوميتس جديدة عملهم أحمد على الباك إند. منى عملت `git diff main origin/main` ولقيت إن أحمد عدل في ملف هي لسه شغالة عليه. عرفت إن الدمج هيعمل conflict، فقررت تخلص شغلها الأول وتعمل commit محلي، وبعدين تعمل الدمج على نظافة وبتركيز.

#### مثال 2: الـ Pull المباشر وفخ الـ Conflicts المفاجئة
شادي كان مستعجل وعمل `git pull` مباشرة. فجأة شاشة التيرمنال اتملت بكلام أحمر: `CONFLICT (content): Merge conflict in src/App.js`. الكود وقف عن العمل، والـ Git دخل في حالة merge معلقة، واضطر شادي يحل المشاكل يدوياً تحت ضغط الوقت. لو كان عمل fetch وجرب الـ diff الأول كان هيكون مستعد ومرتب خطواته.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the difference between `git fetch` and `git pull`? Explain their behavior at the object database and configuration levels."*
>
> **الإجابة المثالية:**
> الفرق الجوهري يكمن في تأثر دليل العمل (Working Directory) والفرع المحلي الحالي:
> - **`git fetch`:** هو عملية اتصال آمنة ومحافظة (Safe & Non-destructive). يقوم بجلب كافة الكائنات (Objects) والـ Commits الجديدة من السيرفر وحفظها في قاعدة بيانات الجيت المحلية `.git/objects` ويقوم بتحديث مؤشرات الفروع البعيدة `refs/remotes/` فقط. لا يقوم بتعديل ملفات العمل الخاصة بالمطور أو دمج أي كود.
> - **`git pull`:** هو أمر مركب ينفذ `git fetch` أولاً لجلب البيانات، ثم يقوم فوراً بتشغيل عملية دمج (تكون إما `git merge FETCH_HEAD` أو `git rebase FETCH_HEAD` بناءً على إعدادات التكوين مثل `pull.rebase`). هذا الأمر يؤدي لتعديل دليل العمل مباشرة ويمكن أن ينتج عنه تعارضات (Merge Conflicts) تتطلب التدخل الفوري من المطور.

---

## Q45 — الفرق بين `git push --force` و `git push --force-with-lease`: إمتى بنستخدم كل واحد؟ وإيه المخاطر؟

### أصل الحكاية
شادي عمل Rebase محلي لفرع الميزة بتاعه عشان ينظف الكوميتس قبل ما يعمل PR. لما جه يرفع الكود بـ `git push origin feat-auth` الـ Git رفض، لأن تاريخ الفرع المحلي اختلف عن السيرفر (بعد الـ Rebase تغيرت الـ Hashes).
شادي عارف إنه لازم يجبر السيرفر يقبل، ففكر يكتب `git push --force`.
أحمد صرخ فيه وقاله: "أوعى تستخدم `--force` العادية! لو منى رفعت كود على نفس الفرع ده وأنت مش واخد بالك، هتمسح شغلها تماماً من على السيرفر بدون أي إنذار! استخدم `--force-with-lease`".

الفرق بين الأمرين بيمثل "حزام الأمان" في الحفاظ على كود زمايلك:
1. **`git push --force` (`-f`)**:
   - بيبعت أمر للسيرفر: "امسح مؤشر الفرع ده عندك تماماً، وحطه عند الـ Commit Hash اللي ببعتهولك ده، بغض النظر عن اللي موجود على السيرفر".
   - لو فيه مطور تاني (منى) رفع كود على نفس الفرع على GitHub في الوقت اللي شادي كان بيعمل فيه Rebase محلي، الـ push بتاع شادي هيمسح كوميتس منى تماماً وهيطير تعبها.
2. **`git push --force-with-lease`**:
   - هو خيار ذكي وآمن. بيقول للسيرفر: "أنا عايز أجبرك تقبل الكود بتاعي، بشرط: اتأكد إن مؤشر الفرع عندك على السيرفر هو نفسه المؤشر اللي متسجل عندي في الـ Remote-tracking branch محلياً (`origin/feat-auth`)".
   - لو منى رفعت كود جديد على السيرفر، مؤشر السيرفر اتغير. وبما إن جهاز شادي لسه معملش fetch للكوميتس الجديدة دي، فالـ Remote-tracking branch عنده محلياً لسه بيشير للكوميت القديمة.
   - الـ Git هيقارن وهيلاقي اختلاف، فهيرفض الـ push ويقول لشادي: "فيه كود جديد على السيرفر أنت معملتلوش fetch، مش هسمحلك تمسحه!".

```bash
# 1. الطريقة الخطيرة (تجنبها تماماً في الفروع المشتركة)
git push origin feat-auth --force

# 2. الطريقة الآمنة لرفع الكود بعد الـ Rebase أو الـ Amend
git push origin feat-auth --force-with-lease

# 3. إعداد أمان إضافي (التأكد من عدم مسح الكوميتس نهائياً)
# لو جربت force-with-lease ورفض، هتعمل fetch الأول عشان تشوف كود زمايلك وتدمجه، ثم ترفع.
```

#### مثال 1: شادي ينقذ كود منى بالـ Lease
شادي جرب يكتب `git push origin feat-auth --force-with-lease`. الـ Git رفض وطلع رسالة:
`error: failed to push some refs to... Hint: Updates were rejected because the remote contains work that you do not have locally.`
شادي فهم إن منى رفعت تعديل مهم. عمل `git fetch` ولقى تعديلها، دمجه مع شغله، وبعدين رفع الكود بنجاح وبدون خسائر.

#### مثال 2: الكارثة التي سببتها `--force`
في شركة تانية، مطور استخدم `git push origin main --force` بالخطأ بعد ما عمل Reset محلي. الحركة دي مسحت 20 كوميت لـ 5 مطورين مختلفين من على السيرفر الرئيسي للشركة. اضطر الفريق يقعد 4 ساعات يجمعوا الكود من أجهزة المطورين عشان يرجعوا السيرفر لحالته الطبيعية.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain the difference between `git push --force` and `git push --force-with-lease`. In what scenarios is each used, and why is the latter considered a safer alternative?"*
>
> **الإجابة المثالية:**
> الأمران يُستخدمان لتحديث تاريخ الفرع على السيرفر بعد تعديله محلياً بـ (Rebase أو Reset أو Commit --amend). ولكن تختلف درجة الأمان بشكل كبير:
> - **`git push --force`:** يقوم بتحديث مرجع الفرع على السيرفر بشكل أعمى (Blind Overwrite)، متجاهلاً أي تغييرات قد يكون مطورون آخرون قد قاموا برفعها على السيرفر في هذه الأثناء، مما قد يؤدي لفقدان دائم للكود المشترك.
> - **`git push --force-with-lease`:** يمثل صمام أمان (Conditional Force Push). حيث يرفض إتمام العملية إذا كانت النسخة الموجودة على السيرفر تحتوي على Commits جديدة لم يقم المطور الحالي بجلبها (Fetch) إلى جهازه بعد. يقوم بمقارنة المرجع البعيد على السيرفر بالمرجع المحلي المتوقع (Remote-tracking branch). إذا تطابقا، يتم الرفع؛ وإذا اختلفا، يتم رفض العملية لحماية أعمال الآخرين من الحذف غير المقصود.

---

## Q46 — الفرق بين الـ Clone والـ Fork في بيئة العمل الجماعي: إمتى بنستخدم ده وإمتى ده؟ وإيه اللي بيحصل تحت الغطاء؟

### أصل الحكاية
أحمد ومى انضموا لفريق InboxSales. أحمد أخد رابط المشروع الرئيسي وعمل `git clone`. مى راحت لصفحة المشروع على GitHub وضغطت على زرار "Fork" وبعدين عملت `clone` للنسخة الجديدة اللي ظهرت في حسابها الشخصي.
الاتنين شغالين على نفس المشروع، بس بطريقتين مختلفتين تماماً لإدارة الصلاحيات والتعاون.

تحت الغطاء وفي فلسفة الفيرجن كونترول:
1. **الـ Clone (الاستنساخ المحلي)**:
   - هو نسخ كامل لمستودع Git (بما فيه الـ Objects والتاريخ بالكامل) من السيرفر لجهازك المحلي.
   - بيحصل في مشاريع الشركات المغلقة والمشتركة حيث المطورين كلهم عندهم صلاحيات كتابة مباشرة (Write Access) على نفس المستودع الرئيسي.
   - بيبعت الكود مباشرة للسيرفر الرئيسي عبر `git push origin <branch>`.
2. **الـ Fork (الاشتقاق السحابي)**:
   - مبيحصلش على جهازك؛ ده بيحصل **على السيرفر** نفسه (زي GitHub). هو عبارة عن أخذ نسخة كاملة من المستودع الرئيسي وحفظها تحت اسم حسابك الشخصي على السيرفر (Server-side Copy).
   - بيستخدم في المشاريع مفتوحة المصدر (Open Source) أو في الشركات اللي بتطبق نظام أمان صارم يمنع المطورين من الكتابة مباشرة على المستودع الرئيسي.
   - المطور بيعمل clone للـ fork بتاعه على جهازه، يعدل الكود، يرفع التعديلات على الـ fork (اللي يملك عليه صلاحيات كاملة)، ومن هناك يفتح "Pull Request" للمستودع الأصلي (Upstream) يطلب فيه دمج التغييرات.

```bash
# 1. إعداد الـ Remotes في حالة الـ Fork
# origin يشير للمستودع المشتق الخاص بك على حسابك الشخصي
git remote add origin https://github.com/my-username/GRAD-inpoxsales.git

# upstream يشير للمستودع الأصلي للشركة أو المشروع الرئيسي
git remote add upstream https://github.com/InboxSales/GRAD-inpoxsales.git

# 2. تحديث كودك المحلي مباشرة من المستودع الأصلي الرئيسي
git fetch upstream
git merge upstream/main
```

#### مثال 1: مى بتساهم في الكود بدون صلاحيات مباشرة
مى انضمت كمتطوعة لتحسين كود الأمان في InboxSales. الشركة مرضيتش تديها صلاحيات كتابة على المستودع الرئيسي. مى عملت Fork للمشروع على GitHub، وعدلت الثغرة في نسختها الخاصة، ورفعت الكود على الـ Fork بتاعها. بعد كدة عملت Pull Request للشركة. أحمد (التيك ليد) راجع الكود ولقاه ممتاز، فضغط Approve واندمج الكود في المشروع الرئيسي بأمان.

#### مثال 2: أحمد شغال بنظام الـ Clone
أحمد مهندس أساسي في الفريق. هو مش محتاج يعمل Fork. هو عمل `git clone` مباشرة للمستودع الرئيسي للشركة. بيعمل فرع جديد `feat-payment` محلياً، وبيرفعه مباشرة للشركة `git push origin feat-payment` ويفتح PR للمراجعة مباشرة داخل نفس المستودع.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is the difference between Cloning and Forking a repository? When would you use each, and how do you manage remotes for a forked repository?"*
>
> **الإجابة المثالية:**
> الاختلاف الرئيسي يكمن في مكان النسخ والصلاحيات:
> - **الـ Clone:** هو عملية نسخ مستودع Git من سيرفر بعيد إلى جهاز محلي (Local Machine) للعمل عليه. يُستخدم عندما يمتلك المطور صلاحيات كتابة مباشرة (Write Access) على المشروع، وهو المعتاد في فرق العمل الداخلية بالشركات.
> - **الـ Fork:** هو عملية نسخ للمستودع تتم بالكامل على السيرفر (Server-side Copy) لإنشاء نسخة مستقلة تحت حساب المطور الشخصي. يُستخدم في المشاريع مفتوحة المصدر أو عندما لا يمتلك المطور صلاحية تعديل مباشرة على الكود الرئيسي؛ حيث يمكنه التعديل بحرية في نسخته ثم إرسال طلب دمج (Pull Request) للمستودع الأصلي.
> - **إدارة الـ Remotes:** للمستودع المشتق (Forked)، نقوم بتعريف مرجعين (Remotes):
>   1. **`origin`:** يشير إلى الـ Fork الخاص بنا على حسابنا الشخصي للرفع عليه (Push).
>   2. **`upstream`:** يشير إلى المستودع الأصلي لمتابعة التحديثات وجلبها منه (Fetch/Merge) للحفاظ على توافق الكود المحلي مع آخر التطورات.

---

## Q47 — إزاي Git بيتعامل مع الفروع المتباعدة (Divergent Branches)؟ وايه هي سلوكيات الـ default pull الثلاثة: merge و rebase و ff-only؟

### أصل الحكاية
منى كتبت كود ومسحت ملفات مؤقتة وعملت كوميت محلي على فرع `main`. في نفس الوقت، شادي كان رفع كوميت على السيرفر بيصلح فيه مشكلة في اللوجين.
لما منى كتبت `git pull` عشان تحدث جهازه، الـ Git طلع تحذير طويل ومحير بيقولها:
`warning: Pulling without specifying how to reconcile divergent branches is discouraged.`
الـ Git كان بيسألها: "دلوقتي الفرعين متباعدين (Diverged) — يعني كل فرع فيه كوميت مش عند التاني. أدمجهم بـ Merge commit؟ ولا أعمل Rebase لفرعك فوق كود السيرفر؟ ولا أرفض الدمج لو مش سريع؟"
منى مكنتش عارفة تختار إيه، وشادي شرحلها الاختيارات التلاتة اللي بتحدد سلوك المزامنة:

1. **الـ Merge (السلوك الافتراضي الكلاسيكي - `pull.rebase false`)**:
   - بيعمل `fetch` من السيرفر.
   - بيعمل `git merge origin/main` للفرع المحلي.
   - بيولد كوميت دمج جديدة (Merge Commit) تجمع الفرعين. ده بيخلي التاريخ متشابك ومليان كوميتس دمج تلقائية زي `Merge branch 'main' of github.com...`.
2. **الـ Rebase (السلوك الخطي النظيف - `pull.rebase true`)**:
   - بيعمل `fetch` من السيرفر.
   - بياخد الكوميتس المحلية بتاعة منى ويشيلها على جنب مؤقتاً.
   - بيحدث الفرع المحلي بكود السيرفر الجديد.
   - بيعيد تطبيق (Replay) كوميتس منى فوق كود السيرفر كأنها لسه كاتباها حالا. ده بيحافظ على تاريخ نظيف وخطي تماماً وبدون كوميتس دمج.
3. **الـ Fast-Forward Only (الأمان الصارم - `pull.ff only`)**:
   - بيرفض الـ pull تماماً لو الفرعين متباعدين.
   - بيسمح بالـ pull فقط في حالة واحدة: لو فرع منى المحلي معليهوش أي كوميتس جديدة (يعني هو مجرد متأخر عن السيرفر). في الحالة دي بيحرك المؤشر للأمام فوراً (Fast-Forward).
   - لو فيه كوميتس محلية، الـ Git هيقف ويطلب من المطور يقرر ويحل المشكلة يدوياً بـ merge أو rebase، وده بيمنع أي دمج تلقائي غير مرغوب فيه.

```bash
# 1. ضبط السلوك الافتراضي ليكون Rebase (موصى به للتاريخ النظيف)
git config --global pull.rebase true

# 2. ضبط السلوك الافتراضي ليكون Merge (الكلاسيكي)
git config --global pull.rebase false

# 3. ضبط السلوك الافتراضي ليكون Fast-Forward Only (الأكثر أماناً)
git config --global pull.ff only

# 4. تشغيل pull بسلوك محدد لمرة واحدة فقط دون تغيير الإعدادات العالمية
git pull --rebase origin main
git pull --no-rebase origin main
git pull --ff-only origin main
```

#### مثال 1: منى بتنظف تاريخها بالـ Rebase
منى قررت تضبط الإعدادات عشان تستخدم الـ Rebase دائماً: `git config --global pull.rebase true`.
لما كتبت `git pull origin main` بعد كدة، الـ Git سحب كود شادي، وحط تعديل منى فوقه بسلاسة. لما عملت `git log --oneline` لقت التاريخ خط مستقيم وجميل كأن منى بدأت شغلها بعد ما شادي خلص بالضبط.

#### مثال 2: حماية الكود بـ Fast-Forward Only
أحمد بيحب الأمان الشديد في الفروع الحساسة، فكتب `git config --global pull.ff only`.
لما جرب يعمل pull وكان كاتب كوميتس محلياً، الـ Git قاله:
`fatal: Not possible to fast-forward, aborting.`
أحمد عرف كدة إن فيه تباعد. عمل `git log` وراجع الكود بنفسه وقرر يعمل `git rebase` يدوياً بعد ما اتأكد إن مفيش مشاكل.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What does it mean when branches have diverged? Explain the three strategies Git can use to reconcile them during a pull operation (`merge`, `rebase`, and `ff-only`) and how they are configured."*
>
> **الإجابة المثالية:**
> يحدث تباعد الفروع (Branch Divergence) عندما يحتوي الفرع المحلي والفرع البعيد (Remote Branch) علىcommits مختلفة ومستقلة منذ آخر نقطة التقاء مشتركة بينهما.
> عند استخدام `git pull` لمزامنة هذا التباعد، تتوفر ثلاثة خيارات رئيسية:
> 1. **`merge` (`pull.rebase false`):** يقوم بإنشاء Commit دمج جديدة (Merge Commit) تجمع التاريخين، مما يحفظ شجرة التفرع الأصلية ولكن قد يسبب فوضى في لوج المشروع بسبب كثرة الـ Merge commits التلقائية.
> 2. **`rebase` (`pull.rebase true`):** يقوم بنقل الـ commits المحلية للمطور ويعيد تطبيقها فوق نهاية التاريخ القادم من السيرفر. هذا يحافظ على خط تاريخ نظيف وخطي (Linear History).
> 3. **`ff-only` (`pull.ff only`):** يمنع عملية الـ pull ويرفض دمج الكود إذا تطلب الأمر إنشاء merge commit أو rebase. يقبل التحديث فقط إذا كان الفرع المحلي متأخراً خطياً عن السيرفر دون أي تعديلات محلية.
> يتم ضبط السلوك افتراضياً باستخدام الأمر: `git config --global pull.rebase <true|false>` أو `git config --global pull.ff only`.

---

## Q48 — إيه هي البروتوكولات اللي Git بيستخدمها لنقل البيانات؟ والفرق بين HTTPS و SSH و Git Protocol؟

### أصل الحكاية
أحمد بيكتب رابط المشروع عشان ينزله، لقى خيارين على GitHub:
الأول: `https://github.com/InboxSales/GRAD-inpoxsales.git`
والثاني: `git@github.com:InboxSales/GRAD-inpoxsales.git`
شادي قاله: "لو هتشتغل كتير، يفضل تفعل الـ SSH وتستخدم الرابط التاني عشان ترتاح من إدخال كلمات المرور أو الـ Tokens كل شوية والسرعة تكون أعلى".
لأن Git نظام توزيع، لازم ينقل ملفات الـ Objects والـ Packs بين الأجهزة والسيرفرات. عشان يعمل ده، بيستخدم 4 بروتوكولات أساسية لنقل البيانات:

1. **بروتوكول HTTPS (أو HTTP)**:
   - الأكثر شعبية وسهولة في الاستخدام.
   - بيشتغل على بورت 443 الافتراضي للويب، يعني مستحيل يتحظر في أي شبكة أو فايروال بشركة.
   - بيحتاج مصادقة (Authentication) عن طريق Personal Access Token (PAT) أو مدير كلمات مرور (Credential Helper)، لأن المصادقة بكلمات المرور العادية تم إيقافها لأسباب أمنية.
2. **بروتوكول SSH (Secure Shell)**:
   - المفضل للمطورين المحترفين.
   - بيعتمد على تشفير المفاتيح العامة والخاصة (SSH Key Pairs) زي `id_ed25519`.
   - بمجرد ما ترفع مفتاحك العام على GitHub، بتقدر تعمل push و pull بأمان تام وبدون ما يطلب منك أي كلمة مرور.
   - بيشتغل على بورت 22، وسريع جداً في نقل البيانات.
3. **بروتوكول Git (البروتوكول المخصص)**:
   - بروتوكول سريع جداً وموفر للموارد لأنه مبيعملش أي تشفير أو مصادقة للبيانات (No Auth).
   - بيشتغل على بورت خاص 9418.
   - يُستخدم فقط للمشاريع العامة المفتوحة للقراءة والتحميل العام (Read-Only) بسبب انعدام الأمان فيه.
4. **البروتوكول المحلي (Local Protocol)**:
   - بيستخدم لو المستودع التاني موجود على نفس جهازك أو على شبكة داخلية مشتركة (Shared Drive).
   - بيتعامل مع المجلد كأنه هارد ديسك عادي وبيعمل نسخ مباشر للملفات.

```bash
# 1. التحويل من HTTPS إلى SSH لفرعك المحلي
git remote set-url origin git@github.com:InboxSales/GRAD-inpoxsales.git

# 2. التحويل من SSH إلى HTTPS
git remote set-url origin https://github.com/InboxSales/GRAD-inpoxsales.git

# 3. اختبار اتصال الـ SSH بـ GitHub للتأكد من عمل المفاتيح
ssh -T git@github.com
# Output: Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

#### مثال 1: أحمد بيتفادى مشاكل الفايروال في الفندق
أحمد كان مسافر وبيشتغل من فندق، والـ SSH كان مقفول على شبكة الفندق (بورت 22 محظور). أحمد مقدرش يعمل push للشغل بتاعه. قام بتحويل رابط الـ Remote لـ HTTPS (بورت 443) واستخدم الـ Personal Access Token ورفع كوده فوراً وبدون مشاكل لأن بورت الويب مستحيل يقفله الفندق.

#### مثال 2: سيرفرات الـ CI/CD تستخدم الـ SSH
سيرفر الـ CI/CD الخاص بالشركة محتاج يسحب الكود تلقائياً بدون تدخل بشري وبسرعة عالية وأمان. شادي أنشأ SSH Deploy Key (بدون باسورد) وحط المفتاح الخاص على السيرفر والمفتاح العام على GitHub. السيرفر دلوقتي بيسحب الكود بـ SSH في ثواني وبشكل آمن ومستقل تماماً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Compare the protocols Git uses to transfer data (HTTPS, SSH, Git Protocol, Local). What are the advantages and security trade-offs of HTTPS vs. SSH?"*
>
> **الإجابة المثالية:**
> يدعم Git أربعة بروتوكولات لنقل البيانات:
> 1. **HTTPS:** يتميز بسهولة الإعداد وتجاوز الجدران النارية (Firewalls) كونه يعمل على منفذ الويب 443. يتطلب المصادقة باستخدام tokens (PATs) أو مساعدي كلمات المرور، ويفضل في بيئات العمل التي تحظر منافذ الشبكات الأخرى.
> 2. **SSH:** يعتبر الأكثر أماناً وموثوقية للمطورين. يعتمد على مفاتيح التشفير العامة والخاصة (SSH Keys) بدون الحاجة لإدخال كلمات مرور تفاعلية. يعمل على منفذ 22 وقد يتم حظره في بعض الشبكات المقيدة، ولكنه يوفر سرعة وأماناً فائقين في بيئات التطوير المستمر وسيرفرات الـ CI/CD.
> 3. **Git Protocol:** أسرع بروتوكول متاح ولكنه غير آمن تماماً لخلوه من التشفير والمصادقة، لذا يقتصر استخدامه على قراءة وتنزيل المشاريع العامة (Read-only distribution).
> 4. **Local Protocol:** يُستخدم عندما يكون المستودعان على نفس الهارد ديسك أو دليل شبكة مشترك، ويعتمد على نسخ الكائنات مباشرة في نظام الملفات.

> [!tip] Checkpoint
> بكدة نكون خلصنا كل أسرار الـ Remote والـ Protocols وفهمنا إزاي بنزامن ونرفع كودنا بأمان تام (Topic 5). دلوقتي جه وقت الدخول في منصة العمل الجماعي الأهم في العالم: GitHub! هنشوف الـ Pull Requests والـ Actions والـ Security وقواعد حماية الفروع في التيمات الكبيرة (Topic 6).

---

# Topic 6 — GitHub Specifics & Team Collaboration (منصة GitHub وأدوات الفرق)

## Q49 — دورة حياة الـ Pull Request (PR) على GitHub: إزاي بتتم المراجعة والدمج بأسلوب احترافي؟ ويعني إيه Draft PR؟

### أصل الحكاية
منى خلصت ميزة الفواتير في فرع `feat-billing`. قبل ما تدمج الكود في الـ `main` اللي عليه كود البروداكشن، لازم تعمل Pull Request (طلب سحب ومراجعة الكود) على GitHub عشان أحمد وشادي يراجعوا الكود.
منى فتحت الـ PR، وبدأت دورة حياة الكود المنظم في الفريق:
1. **إنشاء الـ PR**: منى رفعت الفرع وكتبت وصف دقيق للتغييرات، وربطت الـ PR بالـ Task المخصصة ليها.
2. **الـ Draft PR (النسخة المبدئية)**: لو الكود لسه مخلصش 100% بس منى عايزة تاخد رأي زمايلها في الهيكل العام وتجرب الـ CI/CD، بتقدر تفتح الـ PR كـ **Draft**. في الحالة دي، الموقع بيمنع دمج الكود وبيوضح للكل إنه "قيد العمل" (Work In Progress).
3. **مراجعة الكود (Code Review)**: أحمد فتح الـ PR وبدأ يكتب ملاحظات على سطور معينة. كتب لمنى: "هنا السطر ده ممكن يعمل Memory Leak، يفضل نستخدم الكود ده بداله".
4. **التعديل والموافقة**: منى عدلت الكود محلياً وعملت push تاني للفرع. الـ PR بيتحدث تلقائياً. لما أحمد وشادي يطمنوا، بيضغطوا على زرار "Approve".
5. **الدمج (Merge)**: يتم الدمج بالأسلوب المتفق عليه (Merge, Rebase, or Squash).

```bash
# الخطوات المتبعة من المطور لتهيئة الـ PR:
# 1. إنشاء فرع جديد للميزة
git switch -c feat-billing

# 2. بعد كتابة الكود والكوميت محلياً، نرفع الفرع للسيرفر
git push origin feat-billing

# 3. نذهب لصفحة GitHub ونضغط "Create Pull Request" أو "Create Draft Pull Request"
# 4. بعد الموافقة والدمج على GitHub، نقوم بتحديث جهازنا ومسح الفرع المحلي
git switch main
git pull origin main
git branch -d feat-billing
```

#### مثال 1: منى تستخدم الـ Draft PR لمشاركة فكرة
منى كانت بتكتب خوارزمية صعبة لحساب الضرائب، ومش متأكدة من الأداء (Performance). فتحت PR كـ Draft وكتبت لشادي: "بص على الـ File ده وقولي رأيك". شادي دخل وكتب تعليقاته وعدلوا الكود سوا، ولما خلصوا، منى ضغطت على زرار "Ready for Review" عشان يتحول لـ PR رسمي جاهز للموافقة.

#### مثال 2: قواعد المراجعة الصارمة
التيك ليد في InboxSales ضبط إعدادات الـ PR بحيث مستحيل الكود يندمج إلا لو أخد على الأقل 2 Approval من المهندسين الكبار، والـ Tests كلها نجحت على سيرفر الـ CI/CD. أحمد حاول يدمج كود فيه مشكلة، الموقع رفض تماماً وعطل زرار Merge وحط عليه قفل أحمر لحد ما أحمد يصلح الـ Tests ويراجع الكود مع زمايله.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Describe the lifecycle of a Pull Request on GitHub. What is a Draft Pull Request, and how does it facilitate early collaboration in a team?"*
>
> **الإجابة المثالية:**
> الـ Pull Request (PR) هو أداة تعاونية على GitHub تتيح للمطورين إعلام الفريق بالتعديلات التي قاموا بها على فرع معين لطلب مراجعتها ودمجها في الفرع الرئيسي للمشروع.
> **دورة حياة الـ PR:**
> 1. المطور يقوم برفع فرعه وتجهيز الـ PR بالوصف والصور وربطه بالمهام.
> 2. يتم تشغيل الاختبارات الآلية (CI/CD) للتحقق من سلامة الكود.
> 3. يقوم أعضاء الفريق بمراجعة الأسطر (Code Review)، وترك تعليقات، وطلب تعديلات (Changes Requested).
> 4. بعد إتمام التعديلات ونجاح الاختبارات، يحصل الـ PR على الموافقة (Approval).
> 5. يتم دمج الفرع (Merge) ثم حذفه للحفاظ على نظافة المستودع.
> **الـ Draft PR:** هو خيار يتيح للمطور فتح طلب دمج مبكر يكون بمثابة مسودة (Work in progress). لا يمكن دمج الـ Draft PR في الفرع الرئيسي، ولكنه يسمح لباقي المطورين برؤية الكود ومناقشة المعمارية والتصميم في مراحل مبكرة، ومشاركة الأفكار وحل المشاكل قبل إتمام العمل بالكامل، مما يسرع عملية التطوير ويقلل التعارضات الكبيرة في نهاية الميزة.

---

## Q50 — قواعد حماية الفروع (GitHub Branch Protection Rules): إيه هي؟ وإزاي بتحمي كود البروداكشن من الكوارث؟

### أصل الحكاية
شادي كان شغال الصبح وهو نعسان، وكتب بالخطأ أمر `git push origin main` عشان يرفع كود تجريبي.
لو الكود ده وصل للسيرفر، كان هيوقف موقع الشركة والعملاء هيشتكوا والشركة هتخسر فلوس.
لكن لحسن الحظ، الشاشة طلعتله رسالة رفض عنيفة:
`Remote Rejected: refs/heads/main is protected. Pushing directly to this branch is forbidden.`
شادي فاق واتنفس براحة وقرأ الرسالة. الفرع الرئيسي `main` محمي بقواعد صارمة اسمها "Branch Protection Rules".
أحمد التيك ليد هو اللي فعل القواعد دي عشان يمنع أي مطور من العك مباشرة في الفروع الحساسة (Production & Staging).

قواعد حماية الفروع بتمكن الإدارة التقنية من فرض السياسات الأمنية التالية:
1. **منع الـ Push المباشر**: ممنوع أي شخص يرفع كود مباشرة للفرع المحمي بـ `git push`. الدمج فقط يتم عبر Pull Request معتمد.
2. **فرض موافقة المهندسين (Require Pull Request Approvals)**: يجب مراجعة الكود والموافقة عليه من عدد محدد من الأشخاص (مثلاً مطور أو اثنين).
3. **فرض نجاح الاختبارات الآلية (Require Status Checks to Pass)**: مستحيل الدمج ينجح لو فيه أي Test فاشل في الـ CI/CD (زي GitHub Actions).
4. **فرض الفروع النظيفة (Require Linear History)**: إجبار المطورين على عمل Rebase أو Squash لضمان عدم وجود تشابك في شجرة التاريخ.
5. **فرض التوقيع الإلكتروني (Require Signed Commits)**: التأكد من أن كل commit موقعة بمفتاح GPG لضمان هوية المطور الحقيقية ومنع انتحال الشخصيات.
6. **منع الـ Force Push والـ Deletion**: حظر مسح الفرع المحمي أو التلاعب بتاريخه نهائياً حتى من مديري المشروع (إلا لو تم استثنائهم صراحة).

```bash
# لا توجد أوامر Git مباشرة لتفعيل الحماية، لأنها تتم من إعدادات GitHub:
# Settings -> Branches -> Add branch protection rule
# Pattern: main
# Options enabled:
# [x] Require a pull request before merging
#   [x] Require approvals (Number of approvals: 1 or 2)
# [x] Require status checks to pass before merging
# [x] Require signed commits
```

#### مثال 1: شادي يعدل الكود ويمر بالمراجعة مجبراً
شادي بعد ما اترفض الـ Push المباشر بتاعه، عمل فرع جديد `feat-fix` وعمل Push عليه. فتح PR على GitHub. الاختبارات اشتغلت وطلعت علامة صح خضراء. دخل أحمد وراجع الكود وكتب Approve. شادي دخل وضغط Merge بنجاح وأمان. كدة الكود وصل للـ main وهو متراجع وسليم بنسبة 100%.

#### مثال 2: خط حماية ضد انتحال الشخصية
منى لقت زميل جديد انضم للتيم وحاول يرفع كود باسم مستعار وموقعش الكوميت بمفتاحه الـ GPG. نظام الحماية على GitHub رفض الكوميتس بتاعته لأنها مش Signed، ومنعه من الدمج لحد ما ظبط إعدادات الـ GPG Key على جهازه ووقع الكوميتس بشكل رسمي يثبت هويته.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What are GitHub Branch Protection Rules? Explain their key features and how they help enforce code quality and security in production environments."*
>
> **الإجابة المثالية:**
> قواعد حماية الفروع (Branch Protection Rules) هي آلية أمان يوفرها GitHub لفرض قيود صارمة على كيفية دمج وتعديل الأكواد في فروع معينة (مثل `main` أو `master` أو `develop`).
> **أهم ميزاتها:**
> - منع المطورين (بما فيهم أصحاب الصلاحيات العالية في بعض الأحيان) من إجراء `push` مباشر للفروع المحمية، وفرض دمج الأكواد حصراً عبر الـ Pull Requests.
> - اشتراط موافقة (Approval) من مراجعين محددين قبل السماح بالدمج.
> - اشتراط اجتياز اختبارات الفحص والـ Build بنجاح (Status Checks) عبر بيئات الـ CI/CD لضمان عدم إدخال أكواد مكسورة.
> - منع استخدام الـ Force Push وحذف الفروع للحفاظ على استقرار التاريخ البرمجي.
> - فرض توقيع الكوميتس رقمياً (Signed Commits) لضمان موثوقية هوية كاتب الكود.
> تساهم هذه القواعد في تقليل الأخطاء البشرية وحماية بيئة الإنتاج (Production) من الأكواد غير المختبرة أو التعديلات غير المصرح بها.

---

## Q51 — كيفية المصادقة مع GitHub: إيه الفرق بين SSH Keys و Personal Access Tokens (PATs) والـ GitHub CLI؟ وإزاي تظبطهم؟

### أصل الحكاية
منى لسه منضمة للفريق وبتحاول ترفع كود، فـ الـ Git طلب منها تدخل الـ Username والـ Password بتوع حسابها على GitHub. لما كتبت الباسورد الحقيقي، الـ Git رفض تماماً وطلع رسالة خطأ بتقول إن الباسوردات العادية اتلغت ومبقتش مدعومة لأسباب أمنية منذ أغسطس 2021.
منى سألت أحمد: "أنا مش عارفة أعمل push للكود! إزاي أثبت هويتي للـ Git والـ GitHub بأمان؟"
أحمد وضحلها إن فيه تلات طرق حديثة وآمنة للمصادقة مع GitHub:

1. **الـ SSH Keys (مفاتيح الأمان المشفرة)**:
   - بتعتمد على نظام مفتاحين: مفتاح خاص (Private Key) يفضل سري على جهازك محمي بباسورد، ومفتاح عام (Public Key) بترفه على حسابك في GitHub.
   - الطريقة دي هي الأسهل والأسرع لأنك مش هتحتاج تكتب أي توكن أو باسورد في كل Push أو Pull. الـ SSH بيقوم بالمصادقة الخلفية تلقائياً في ثواني.
2. **الـ Personal Access Tokens (PATs)**:
   - عبارة عن كود سري طويل بيولده GitHub ليك، وبيكون ليه صلاحيات محددة وتاريخ انتهاء (Expiration date).
   - بيعامل معاملة الباسورد البديل لما تستخدم رابط الـ HTTPS. الميزة هنا إنك تقدر تدي التوكن صلاحية القراءة فقط، أو صلاحية التعامل مع فروع معينة، ولو اتسرب منك تقدر تلغيه فوراً بدون ما تغير باسورد حسابك الرئيسي.
3. **الـ GitHub CLI (`gh`)**:
   - أداة رسمية من GitHub بتشتغل من داخل الـ Command Line.
   - بتسهل المصادقة جداً. بتكتب `gh auth login` وبتفتح المتصفح وتوافق بضغطة زرار واحدة، والأداة بتظبط الـ SSH أو التوكن نيابة عنك، بالإضافة لتمكينك من إدارة الـ PRs والـ Issues والـ Actions من التيرمنال مباشرة.

```bash
# 1. توليد SSH Key جديد من جهازك (نوع ed25519 الحديث والسريع)
ssh-keygen -t ed25519 -C "mona@example.com"
# اضغط Enter لحفظه في المكان الافتراضي وتحديد passphrase لحمايته

# 2. تشغيل الـ SSH Agent في الخلفية
eval "$(ssh-agent -s)"

# 3. إضافة المفتاح الخاص للـ SSH Agent لجهازك
ssh-add ~/.ssh/id_ed25519

# 4. عرض المفتاح العام لنسخه ورفعه على GitHub
cat ~/.ssh/id_ed25519.pub
# انسخ الخرج واذهب لـ GitHub -> Settings -> SSH and GPG keys -> New SSH key

# 5. طريقة الـ GitHub CLI السحرية للمصادقة
gh auth login
```

#### مثال 1: منى ترفع كودها بالـ SSH لأول مرة
منى عملت الخطوات السابقة ورفعت مفتاحها العام على GitHub. غيرت رابط الـ remote بتاعها لـ SSH بـ `git remote set-url origin git@github.com:InboxSales/GRAD-inpoxsales.git`. جربت تعمل `git push origin main`. العملية تمت في ثواني وبمنتهى السلاسة وبدون ما يطلب منها أي باسورد أو كود.

#### مثال 2: استخدام الـ PAT في أجهزة السيرفر
شادي بيبرمج سكربت بايثون على سيرفر خارجي عشان يسحب كود الموقع تلقائياً. السيرفر معندوش شاشة ولا يقدر يفتح متصفح. شادي أنشأ Personal Access Token على GitHub بصلاحيات محدودة جداً (Repo read-only) وصلاحية تنتهي بعد 30 يوم. حط التوكن ده في السكربت، والسيرفر شغال بيه بأمان، ولو حد اخترق السيرفر مش هيقدر يعدل أي حاجة في الكود الأصلي لأن التوكن صلاحياته محدودة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain how GitHub deprecated password authentication. Compare SSH keys, Personal Access Tokens (PATs), and GitHub CLI in terms of security and developer workflow."*
>
> **الإجابة المثالية:**
> قامت شركة GitHub بإيقاف دعم المصادقة عبر كلمات المرور العادية لعمليات الـ Git في أغسطس 2021 للحد من الهجمات السيبرانية وسرقة الحسابات، وفرضت استخدام طرق مصادقة أقوى:
> 1. **SSH Keys:** تعتمد على تشفير المفاتيح المتناظرة (Public/Private Keys). هي الخيار الأكثر راحة للمطور اليومي لأنها توفر مصادقة صامتة وآمنة وتلقائية بدون الحاجة لحفظ أو كتابة كلمات مرور في كل عملية اتصال، كما أنها ممتازة لربط الأجهزة المحلية ببيئات العمل.
> 2. **Personal Access Tokens (PATs):** هي سلاسل نصية مشفرة تعمل كبديل للباسورد مع روابط HTTPS. تتميز بالمرونة العالية حيث تتيح تحديد الصلاحيات بدقة (Granular Scopes) وتحديد تاريخ انتهاء صلاحية محدد، وتعتبر مثالية للأتمتة والسكربتات وسيرفرات CI/CD التي لا تدعم الـ SSH.
> 3. **GitHub CLI (`gh`):** هي أداة سطر الأوامر الرسمية من GitHub، وتسهل سير العمل من خلال أتمتة عملية المصادقة بالكامل عن طريق التوجيه للمتصفح (OAuth-based login)، بالإضافة إلى تمكين المطور من إدارة كافة ميزات GitHub (مثل فتح PRs أو مراجعة الـ Issues) مباشرة من داخل بيئة التيرمنال المفضلة لديه.

---

## Q52 — الـ GitHub Actions (CI/CD Pipelines): يعني إيه؟ وإزاي بتشغل اختباراتك يدوياً أو تلقائياً مع كل Commit أو PR؟ اكتب ملف YAML بسيط.

### أصل الحكاية
أحمد بيكتب كود الباك إند ومنى بتكتب تعديلات الفرونت إند. في كذا مرة، حد فيهم كان بيرفع تعديل ويبوظ الـ Build بتاع المشروع، ويكتشفوا ده متأخر بعد ما الكود يترفع على سيرفر الاختبارات.
شادي قرر يحل الموضوع ده باستخدام **GitHub Actions** — وهو نظام الأتمتة المدمج في GitHub.
شادي عمل بيئة اختبار آلية (CI/CD Pipeline). بمجرد ما أي مطور يعمل Push لكوده أو يفتح Pull Request، سيرفرات GitHub بتشتغل في الخلفية تلقائياً، وتعمل كلون للكود، وتنزل المكتبات، وتشغل الـ tests.
لو الـ tests نجحت، بيظهر علامة صح خضراء على الـ PR ويسمح بالدمج. لو فشلت، بيظهر علامة غلط حمراء ويتوقف الدمج فوراً ويبعت إيميل تحذيري للمطور المسؤول.

سيرفرات الـ Actions بتقرأ الخطوات دي من ملف إعدادات مكتوب بلغة YAML، ومحفوظ في مسار خاص جداً جوة المشروع:
`.github/workflows/`

```yaml
# اسم الملف: .github/workflows/ci.yml
name: InboxSales CI Pipeline

# 1. إمتى الـ Pipeline ده هيشتغل؟ (Trigger)
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

# 2. إيه هي الخطوات والوظائف اللي هينفذها؟ (Jobs)
jobs:
  run-tests:
    # نظام التشغيل اللي هيقوم عليه السيرفر الافتراضي
    runs-on: ubuntu-latest

    steps:
    # الخطوة 1: عمل كلون للكود داخل السيرفر الافتراضي
    - name: Checkout Repository Code
      uses: actions/checkout@v4

    # الخطوة 2: تثبيت بيئة Node.js على السيرفر
    - name: Set up Node.js Environment
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'

    # الخطوة 3: تنزيل مكتبات المشروع
    - name: Install Project Dependencies
      run: npm ci

    # الخطوة 4: تشغيل الـ Linter للتأكد من نظافة الكود
    - name: Run Code Linter
      run: npm run lint

    # الخطوة 5: تشغيل الاختبارات
    - name: Run Unit Tests
      run: npm test
```

#### مثال 1: منى تبوظ الـ Build بالخطأ والـ Pipeline ينقذ الموقف
منى عدلت كود في واجهة الدفع وعملت push. هي مخدتش بالها إنها غيرت اسم متغير مستخدم في الـ Tests. بمجرد ما الـ push وصل لـ GitHub، الـ CI Pipeline اشتغل تلقائياً. في خطوة `npm test` السكربت فشل وطلع خطأ. الـ GitHub حط علامة حمراء جنب الكوميت وكتب `Run Unit Tests failed`. أحمد دخل وشاف الخطأ ونبه منى اللي صلحته فوراً قبل ما الكود يوصل للـ main.

#### مثال 2: استخدام الـ Actions في الـ Deployment
شادي زود جزء في ملف الـ YAML: "لو الاختبارات نجحت، والفرع اللي ارفع عليه هو `main`، شغل سكربت يرفع الكود ده تلقائياً لسيرفر الـ Production (AWS)". بكدة الفريق بقى بيعمل دمج وهو مغمض عينيه، لأن الأتمتة بتضمن إن الكود شغال وبيترفع لوحده بدون تدخل بشري وبأعلى درجة أمان.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is GitHub Actions? Explain how you configure a continuous integration (CI) workflow to run tests automatically on pull requests. Write a basic YAML workflow."*
>
> **الإجابة المثالية:**
> الـ GitHub Actions هي منصة لأتمتة سير العمل (Workflow Automation) مدمجة بالكامل داخل GitHub. تُستخدم لبناء وتطبيق خطوط الإنتاج والدمج المستمر (CI/CD Pipelines)، مما يتيح تشغيل مهام مثل الاختبارات (Tests)، والفحص (Linting)، والرفع للسيرفرات (Deployment) بشكل آلي بناءً على أحداث معينة (Triggers) مثل الـ push أو الـ pull requests.
> **آلية التكوين:**
> يتم تكوين هذه المهام عبر إنشاء ملفات بصيغة YAML داخل المجلد المخصص `.github/workflows/` في جذر المشروع. يحتوي الملف على:
> - **`on`:** يحدد الأحداث التي تُطلق الـ pipeline (مثل push على فروع معينة).
> - **`jobs`:** مجموعة من الوظائف التي يتم تشغيلها (مثل run-tests).
> - **`runs-on`:** يحدد البيئة أو نظام التشغيل للسيرفر الذي سيعمل عليه الكود (مثل ubuntu-latest).
> - **`steps`:** الخطوات المتتالية التي ينفذها السيرفر، بدءاً من جلب الكود بـ `actions/checkout` وتثبيت لغة البرمجة، وانتهاءً بتشغيل الأوامر الخاصة بالمشروع مثل `npm install` و `npm test`.

---

## Q53 — ربط المهام والـ Issues بالـ Pull Requests: إزاي الكلمات السحرية زي "closes #12" بتقفل الـ Tasks تلقائياً عند الدمج؟ وإيه فايدة الربط ده؟

### أصل الحكاية
أحمد فتح تذكرة خطأ (Issue) على GitHub برقم `#45` بعنوان: `Bug: Checkout page crashes on Safari browser`.
منى اشتغلت على المشكلة وحلتها في فرع جديد. لما جت تفتح الـ Pull Request، كتبت في وصف الـ PR جملة بسيطة جداً:
`This PR fixes #45 and updates the user agent check.`
لما شادي وافق على الـ PR وضغط دمج، فجأة الكل لاحظ إن الـ Issue رقم `#45` اتقفلت لوحدها واتحولت للون البنفسجي (Closed) كأن فيه روبوت قفلها.
أحمد شرحلها إن الـ GitHub فيه نظام ذكي لربط الكوميتس والـ PRs بالمهام والـ Issues باستخدام كلمات دلالية مخصصة (Magic Keywords).

الكلمات السحرية دي بتفيد الفريق في:
1. **الأتمتة الكاملة (Automation)**: توفير الوقت الضائع في تحديث تذاكر المهام والـ Issues يدوياً. بمجرد الدمج، المشكلة بتقفل تلقائياً.
2. **التتبع التاريخي (Traceability)**: لو بعد سنة حصلت مشكلة تانية وحبينا نعرف ليه الكود ده اتغير، بنفتح الـ Commit أو الـ Issue وبنلاقيها مربوطة بالـ PR اللي فيه المناقشات والـ Code Review والمطور اللي اشتغل عليها بالتفصيل.
3. **تنظيم الـ Board (Project Management)**: لو الفريق بيستخدم GitHub Projects (الـ Kanban Board)، الـ Issue بتتحرك تلقائياً من عمود `In Progress` لعمود `Done` بمجرد ربطها وقفلها بـ PR مدمج.

أهم الكلمات السحرية المقبولة في GitHub:
- `close`, `closes`, `closed`
- `fix`, `fixes`, `fixed`
- `resolve`, `resolves`, `resolved`

```bash
# كيفية كتابة الكوميت أو الوصف للربط التلقائي:

# 1. كتابة رسالة الكوميت مع رقم الـ Issue
git commit -m "fix: resolve memory leak in billing module (closes #23)"

# 2. في وصف الـ Pull Request على GitHub نكتب في أي مكان:
# "Closes #12" أو "Fixes #34" أو "Resolves #56"

# 3. لو الـ Issue في مستودع تاني تبع نفس المنظمة:
# "Closes InboxSales/GRAD-inpoxsales#45"
```

#### مثال 1: منى تغلق مهمتين بـ PR واحد
منى كانت شغالة على ميزة التسجيل وحلت مشكلتين مع بعض (رقم `#8` ورقم `#9`). في وصف الـ PR كتبت:
`Implemented Google OAuth registration. Closes #8 and Closes #9.`
بمجرد دمج الـ PR، السيرفر قفل المشكلتين مع بعض ووفر عليها خطوتين مراجعة وتحديث يدوية.

#### مثال 2: فخ كتابة الكلمة السحرية في فرع غير رئيسي
شادي فتح PR لفرع `develop` وكتب `closes #15`. لما دمج الـ PR، الـ Issue رقم `#15` مقفلتش! شادي استغرب وسأل أحمد. أحمد قاله: "الكلمات السحرية بتقفل الـ Issues فقط لما الكود يندمج في **الفرع الرئيسي الافتراضي (Default Branch)** بتاع المستودع (زي `main` أو `master`). لو دمجت في فرع فرعي مش هتقفل تلقائياً لحد ما الفرع الفرعي ده يندمج في الـ main".

### الفايدة الانترفيوية
> **Interview Question:**
> *"Explain how to link GitHub Issues with Pull Requests. What are the magic keywords, and how do they improve traceability and automate the development workflow?"*
>
> **الإجابة المثالية:**
> يتيح GitHub ربط تذاكر المشاكل (Issues) بطلبات السحب (Pull Requests) عن طريق كتابة كلمات مفتاحية مخصصة (Magic Keywords) متبوعة برقم التذكرة (مثل `closes #12` أو `fixes #34`) في وصف الـ PR أو في رسائل الـ Commits المدمجة.
> **أهم الكلمات الدلالية:**
> `closes`, `close`, `closed`, `fixes`, `fix`, `fixed`, `resolves`, `resolve`, `resolved`.
> **الفوائد:**
> 1. **الأتمتة (Automation):** يتم إغلاق الـ Issues المرتبطة تلقائياً بمجرد دمج الـ PR في الفرع الرئيسي للمستودع (Default Branch)، مما يوفر جهداً إدارياً كبيراً.
> 2. **التتبع التاريخي (Traceability):** يُنشئ هذا الربط مرجعاً تبادلياً (Cross-reference) دائماً بين التذكرة، الكود المعدل، والمناقشات التي دارت أثناء مراجعة الكود، مما يسهل الرجوع للتاريخ وسياق التعديل مستقبلاً.
> 3. **تحديث لوحات العمل (Project Board Sync):** يتكامل هذا النظام مع لوحات إدارة المهام (GitHub Projects) لتحديث حالة التذاكر تلقائياً (مثلاً نقل المهام إلى Done) فور الدمج.

> [!tip] Checkpoint
> ممتاز جداً! كدة غطينا منصة GitHub بشكل كامل، وعرفنا إزاي بندير الـ PRs والـ Actions والتراخيص وقواعد الأمان (Topic 6). دلوقتي استعد لأقوى جزء في الدليل: الأدوات المتقدمة في الـ Git وسيناريوهات الإنقاذ للمطورين المحترفين! هنتكلم عن الـ Worktrees، الـ Submodules، الـ Git Bisect للبحث عن الـ Bugs، والـ Git Hooks وتنسيق الكود التلقائي (Topic 7).

---

# Topic 7 — Advanced Git Tools & Recovery Scenarios (الأدوات المتقدمة وسيناريوهات الإنقاذ)

## Q54 — الفرق بين الـ Git Submodules والـ Git Subtrees: إمتى بنستخدم كل واحد؟ وإيه الاختلافات المعمارية تحت الغطاء؟

### أصل الحكاية
فريق InboxSales شغال على كود المشروع الرئيسي. في نفس الوقت، احتاجوا يستخدموا مكتبة باك إند لتوليد التقارير والفواتير اسمها `InvoiceEngine` ودي معمولة كمستودع مستقل تماماً على GitHub، وبتستخدم في مشاريع تانية تابعة للشركة.
منى سألت: "إزاي نضمن كود المكتبة دي جوة مشروعنا الرئيسي؟ هل ننسخ الملفات يدوياً؟"
أحمد قالها: "لو نسخناها يدوياً هنفقد القدرة على تحديثها بسهولة لو نزل ليها إصدار جديد. لازم نستخدم إما الـ Submodules أو الـ Subtrees عشان نربط المستودعين ببعض".

الفرق المعماري بين الطريقتين بيحدد إزاي Git بيتعامل مع كود الطرف الثالث:
1. **الـ Git Submodules (المستودعات الفرعية المنفصلة)**:
   - بتتعامل مع المستودع الفرعي كأنه مجرد "مؤشر" (Pointer) أو رابط يشير لـ Commit Hash محددة في المستودع الخارجي.
   - كود المكتبة الفرعية **لا يندمج** في تاريخ المشروع الرئيسي. الملفات بتكون موجودة في فولدر مستقل، بس الـ Git الرئيسي مبيراقبش ملفات الفولدر ده؛ هو فقط بيسجل سطر واحد: "الفولدر ده بيحتوي على مستودع خارجي واقف عند الكوميت رقم `xyz`".
   - مفيدة جداً للمكتبات الكبيرة والضخمة اللي مش عايزين تاريخها يملأ لوج المشروع الرئيسي، أو للمشاريع المشتركة اللي بيتم تطويرها بشكل مستقل تماماً.
2. **الـ Git Subtrees (شجرة الأكواد المدمجة)**:
   - بتقوم بنسخ كود وتاريخ المستودع الفرعي بالكامل وتدمجه داخل تاريخ ومجلدات المشروع الرئيسي كأنه جزء منه.
   - المطورين الآخرين مش هيحتاجوا يعملوا أي خطوات إضافية لتحديث المكتبة؛ بمجرد ما يعملوا `git clone` للمشروع الرئيسي، الكود كله بينزل معاهم تلقائياً كملفات عادية.
   - مفيدة جداً للمشاريع التي تتطلب تعديلات مستمرة وسريعة على المستودع الفرعي من داخل المشروع الرئيسي نفسه، ودون تعقيد في الأوامر لباقي الفريق.

```bash
# --- التعامل مع الـ Submodules ---

# 1. إضافة Submodule جديد للمشروع
git submodule add https://github.com/InboxSales/InvoiceEngine.git shared/invoice-engine
# ده هيولد ملف جديد اسمه .gitmodules بيسجل معلومات المستودع الفرعي

# 2. كلون لمشروع يحتوي على submodules لأول مرة (تحميل الكود الفرعي)
git clone --recurse-submodules https://github.com/InboxSales/GRAD-inpoxsales.git
# أو لو عملت كلون عادي وعايز تنزلهم يدوياً:
git submodule update --init --recursive

# --- التعامل مع الـ Subtrees ---

# 3. إضافة Subtree جديد للمشروع (دمج الكود والتاريخ بالكامل)
git subtree add --prefix shared/invoice-engine https://github.com/InboxSales/InvoiceEngine.git main --squash
```

#### مثال 1: شادي يعاني مع الـ Submodules والكلون الناقص
شادي عمل كلون للمشروع الرئيسي عشان يبدأ يشتغل. لقى الفولدر `shared/invoice-engine` فاضي تماماً والكود مش شغال! افتكر إن الكود ممسوح. أحمد قاله: "المشروع بيستخدم Submodules، الـ Git بيعمل كلون للمشروع الرئيسي بس وبيسيب الفولدر الفرعي فاضي لحد ما تكتب أمر التحديث يدوياً: `git submodule update --init`". شادي كتب الأمر، والكود نزل واشتغل فوراً.

#### مثال 2: منى تعدل على كود المكتبة وتدفعه للسيرفر بـ Subtree
منى شغال بنظام الـ Subtree. لقت مشكلة في مكتبة الفواتير محلياً جوة مجلد المشروع الرئيسي. عدلت السطور جوة مجلد `shared/invoice-engine` وعملت commit عادي. الكود اتسجل في مستودع الشركة الرئيسي. شادي بعد كدة حب يرجع التعديل ده للمستودع المستقل بتاع المكتبة الأصلية عشان باقي فرق الشركة تستفيد، فكتب أمر push مخصص للـ subtree بيفرز التعديلات ويرفعها للمستودع الفرعي مباشرة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Compare Git Submodules and Git Subtrees. Under what circumstances would you choose one over the other, and how do they differ in their storage and commit history internals?"*
>
> **الإجابة المثالية:**
> يكمن الاختلاف الأساسي بينهما في كيفية إدارة وتخزين الملفات والتاريخ الخاص بالمستودع الخارجي:
> - **Git Submodules:** تقوم بتخزين المستودع الخارجي كـ "مؤشر" (Link/Pointer) فقط يشير إلى رابط المستودع الخارجي و SHA-1 commit محددة. لا يندمج كود الفرعي في مستودع الأب؛ بل يُخزن في ملف تكوين `.gitmodules`. المطورون الآخرون يحتاجون لتشغيل أوامر خاصة (`git submodule update`) لجلب الكود. تُفضل هذه الطريقة عندما تكون المشاريع ضخمة ومستقلة تماماً وتُدار من فرق مختلفة ولا نرغب في تلويث تاريخ المشروع الرئيسي بكوميتس فرعية.
> - **Git Subtrees:** تقوم بنسخ الكود وكافة ملفات وتاريخ المستودع الفرعي ودمجها مباشرة في شجرة ملفات وتاريخ المستودع الرئيسي (Physical Copy). لا يحتاج المطورون الآخرون لأي خطوات إضافية للحصول على الكود. تُفضل هذه الطريقة عندما نريد تسهيل عملية الكلون والمزامنة للجميع، أو عندما نحتاج لإجراء تعديلات مستمرة وسريعة على كود المكتبة من داخل سياق المشروع الرئيسي وإعادة إرسالها (Push) للمستودع الخارجي بسهولة.

---

## Q55 — يعني إيه `git worktree`؟ وإزاي بيسمحلك تشتغل على كذا فرع في نفس الوقت ومن غير ما تعمل Stash أو كلون جديد؟

### أصل الحكاية
منى شغالة بتركيز على فرع `feat-billing` وكاتبة تعديلات كتيرة في 15 ملف، والكود حالياً مش شغال (Broken state) لأنها لسه بتعدل في الهيكل.
فجأة، أحمد التيك ليد دخل وقالها: "منى، فيه bug خطيرة جداً على البروداكشن في الـ `main` والعملاء مش عارفين يدفعوا، لازم تدخلي فوراً وتصلحي الـ hotfix ده حالا!".
منى وقعت في حيرة: لو عملت `git checkout main` الـ Git هيرفض لأن عندها ملفات معدلة كتير محصلهاش commit وهتضيع.
لو عملت `git stash` هتشيل شغلها على جنب، بس لما ترجع ممكن تنسى كانت واقفة فين أو يحصل خلط، ولو المشروع كبير خطوة الـ stash والـ rebuild هتاخد وقت طويل.
شادي قالها: "استخدمي السحر الحقيقي للـ Git وهو الـ `git worktree`!".
أمر `git worktree` بيسمحلك تعمل كذا "مجلد عمل" (Working Directory) مستقلين تماماً لنفس المشروع على جهازك، وكل مجلد فيهم واقف على فرع مختلف، مع مشاركة نفس قاعدة بيانات الـ `.git` المخفية!

```bash
# 1. إنشاء مجلد عمل جديد مربوط بفرع الـ main لحل المشكلة الطارئة
# الصيغة: git worktree add <path-to-new-folder> <branch-name>
git worktree add ../GRAD-hotfix main
# السحر هنا: Git هينشئ مجلد جديد اسمه GRAD-hotfix بجانب مجلد مشروعك الحالي واقف على فرع main

# 2. الذهاب للمجلد الجديد للعمل على الـ Bug بأمان تام ودون لمس فرع التقارير
cd ../GRAD-hotfix
# بيكتب ويصلح الكود هنا ويعمل commit ويرفع التعديل للسيرفر

# 3. إظهار قائمة بكل مجلدات العمل النشطة على جهازك
git worktree list

# 4. بعد الانتهاء والرفع، نعود للمجلد الأصلي
cd ../GRAD-inpoxsales

# 5. حذف مجلد العمل الإضافي بعد انتهاء المهمة
git worktree remove ../GRAD-hotfix
```

#### مثال 1: منى تحل الـ Hotfix في دقيقتين دون لمس كودها
منى كتبت `git worktree add ../GRAD-hotfix main`. فتحت برنامج الـ VS Code على الفولدر الجديد `GRAD-hotfix`. الكود هناك نظيف وواقف على الـ main. عدلت السطر المسبب للمشكلة، وعملت commit و push. قفلت الفولدر ورجعت للفولدر الأصلي `GRAD-inpoxsales`. لقت كل ملفاتها الـ 15 المعدلة زي ما هي وواقفة عند نفس السطر اللي كانت بتكتبه. كأنها سافرت عبر الزمن ورجعت بدون أي خسائر.

#### مثال 2: تشغيل نسختين من المشروع في نفس الوقت للمقارنة
أحمد شغال على تطوير واجهة جديدة في فرع `new-ui` وعايز يقارنها بالواجهة القديمة في فرع `main` بالمتصفح ويشوفهم قصاد بعض.
عمل `git worktree add ../main-ui main`. بقى عنده فولدرين على جهازه، شغل السيرفر المحلي للأول على بورت 3000، وشغل التاني على بورت 3001، وفتح المتصفح يقارن بينهم لحظة بلحظة وبمنتهى السهولة.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is `git worktree`? How does it solve the problem of context switching between different branches compared to using `git stash` or cloning the repository multiple times?"*
>
> **الإجابة المثالية:**
> الـ `git worktree` هي ميزة متقدمة في Git تتيح للمطور امتلاك عدة أدلة عمل (Working Directories) نشطة ومستقلة مرتبطة بمستودع محلي واحد (Single local `.git` repository).
> **حل مشكلة Context Switching:**
> - **بديل الـ `git stash`:** عند وجود عطل طارئ، بدلاً من إخفاء التغييرات الحالية بـ stash (والتي قد تسبب تعارضات أو تتطلب إعادة بناء وتثبيت الحزم للمشروع عند التبديل)، تتيح الـ worktree إنشاء مجلد منفصل تماماً للعمل على العطل بشكل مستقل والعودة للمجلد الأصلي دون أي تعديل على حالة الملفات غير المكتملة.
> - **بديل الـ Multiple Clones:** عند عمل clone للمستودع عدة مرات، نقوم بنسخ قاعدة البيانات بالكامل وهدر المساحة على القرص الصلب، وتضيع مزامنة الـ commits المحلية بين النسخ. مع الـ worktree، تتشارك جميع المجلدات نفس قاعدة بيانات `.git` المخفية؛ مما يعني أن أي commit أو جلب للبيانات (Fetch) في أي مجلد عمل يصبح متاحاً فوراً في المجلدات الأخرى دون استهلاك مساحة تخزينية إضافية.

---

## Q56 — استخدام الـ `git bisect` لتتبع الـ Bugs: إزاي بتكتشف الكوميت اللي بوظت الكود باستخدام البحث الثنائي (Binary Search)؟ وإزاي بتشغلها أوتوماتيك بسكربت؟

### أصل الحكاية
فريق InboxSales لاحظ فجأة إن صفحة تسجيل الدخول مهنجة وبطيئة جداً على البروداكشن.
المشكلة إن مفيش حد عارف المشكلة دي بدأت إمتى بالظبط. فيه أكتر من 150 commit اتعملوا الأسبوع ده من كذا مطور.
أحمد قال: "مستحيل نراجع الـ 150 commit دول يدوياً ونشغل الكود عندهم واحدة واحدة، ده هيضيع يوم كامل!".
شادي قاله: "الحل هو المفتش الذكي `git bisect`".
أمر `git bisect` بيستخدم خوارزمية البحث الثنائي (Binary Search) عشان يقلص عدد الكوميتس المشتبه فيها بسرعة رهيبة.
أنت بتحدد للـ Git نقطة البداية (كوميت قديمة كنت متأكد إن الكود عندها سليم - Good) ونقطة النهاية (الوضع الحالي اللي فيه المشكلة - Bad).
الـ Git تلقائياً هيروح يقف في نص المسافة بين الكوميتس (الكوميت رقم 75)، ويطلب منك تختبر الكود. لو الكود شغال، بتقوله `good`، فالـ Git بيفهم إن المشكلة في النص التاني، فيروح يقف في نص النص التاني (الكوميت رقم 112) وهكذا... لحد ما يوصل للكوميت الخبيثة في خطوات معدودة (لو 128 كوميت هيوصلها في 7 خطوات فقط!).

```bash
# 1. بدء عملية البحث والتحقيق
git bisect start

# 2. تحديد الكوميت الحالية كحالة سيئة (Bad)
git bisect bad

# 3. تحديد كوميت قديمة (مثلاً قبل أسبوع) كحالة سليمة (Good)
git bisect good a1b2c3d

# 4. الآن Git سينتقل تلقائياً لكوميت في المنتصف ويطلب منك التجربة:
# بعد تجربة الكود بالمتصفح أو الـ build:
git bisect bad   # لو وجدتها معطلة
# أو:
git bisect good  # لو وجدتها سليمة

# 5. يكرر Git العملية حتى يطبع لك الكوميت المسؤولة بالضبط:
# Output: e5f6g7h is the first bad commit

# 6. إنهاء عملية التحقيق والعودة للوضع الأصلي
git bisect reset
```

#### مثال 1: أحمد يكتشف الكوميت المسببة للبطء في 5 دقائق
أحمد بدأ الـ bisect. الـ Git نقله لكوميت في النص. عمل build واختبر سرعة اللوجين، لقاها سريعة. كتب `git bisect good`. الـ Git نقله لكوميت تانية. جرب، لقاها بطيئة. كتب `git bisect bad`. بعد 6 خطوات فقط، الـ Git طبع:
`e5f6g7h890 commit by Shadi: feat: add new analytics tracker`
أحمد فتح الكوميت دي ولقى إن شادي كتب loop غير منتهية في الباك إند هي اللي مسببة البطء. صلحوها في دقيقتين وخلص التحقيق.

#### مثال 2: الأتمتة السحرية بـ `git bisect run`
شادي قال: "أنا مش عايز أجرب بالمتصفح يدوياً في كل خطوة، أنا كاتب Test script جاهز بيبحث عن المشكلة دي".
شادي شغل الـ bisect أوتوماتيك تماماً بكتابة أمر واحد:
`git bisect run npm test`
الـ Git بقى ينتقل بين الكوميتس لوحده، ويشغل الـ test script. لو السكربت رجع نجاح (exit code 0) بيعلم الكوميت كـ `good`، ولو رجع فشل بيعلمها كـ `bad`... وفضل شغال لوحده لحد ما طبع الكوميت الخربانة وشادي كان بيشرب القهوة بتاعته!

### الفايدة الانترفيوية
> **Interview Question:**
> *"What is `git bisect` and how does it utilize binary search to pinpoint regression bugs? How can the process be automated using scripts?"*
>
> **الإجابة المثالية:**
> الـ `git bisect` هي أداة تصحيح أخطاء (Debugging Tool) قوية في Git تُستخدم لتحديد الـ Commit الأولى التي تسببت في ظهور مشكلة أو عطل (Regression Bug) في الكود.
> **آلية العمل بـ Binary Search:**
> تقوم الأداة بتقسيم قائمة الـ commits بين نقطة سليمة معروفة (`good`) ونقطة معطلة معروفة (`bad`) إلى النصف. ينتقل Git تلقائياً للـ commit التي تقع في المنتصف ويطلب من المطور اختبار الكود. بناءً على نتيجة الاختبار (سواء تم تعليمه كـ good أو bad)، يقوم Git باستبعاد نصف الكوميتس المتبقية وتكرار العملية على النصف الآخر. هذا يقلل من تعقيد البحث من وقت خطي $O(N)$ إلى وقت لوغاريتمي $O(\log N)$.
> **الأتمتة بـ `git bisect run`:**
> يمكن أتمتة هذه العملية بالكامل إذا توفر اختبار مؤتمت (Linter, Unit Test, or custom script). نقوم بتشغيل الأمر:
> `git bisect run <script-or-command>`
> يقوم Git بالتنقل الذاتي وتشغيل الأمر على كل commit؛ فإذا كان كود الخروج الخاص بالأمر هو `0` يعتبرها سليمة، وإذا كان بين `1` و `127` (باستثناء 125) يعتبرها معطلة، ويستمر حتى يعثر على الكوميت المسببة للخطأ تلقائياً ودون تدخل بشري.

---

## Q57 — مستودعات الملفات الكبيرة Git LFS (Large File Storage): ليه الـ Git بيعطل مع الملفات الكبيرة؟ وإزاي الـ LFS بيحل المشكلة تحت الغطاء؟

### أصل الحكاية
تيم InboxSales بدأوا يضيفوا فيديوهات توضيحية للموقع وملفات تصميم وصور بدقة عالية جداً (بعض الملفات حجمها 150 ميجا بايت).
بمجرد ما رفعوا الملفات دي، شادي جه يعمل clone للمشروع على جهازه، لقى الـ download بطيء جداً وبياخد ساعات والـ Git بيشتكي من الـ memory.
أحمد شرحلهم المشكلة: "الـ Git مصمم لتتبع ملفات الأكواد النصية (Text files). الـ Git بيحفظ تاريخ كل ملف كامل؛ فلو عدلت ملف فيديو حجمه 100 ميجا 3 مرات، الـ Git هيخزن الـ 3 نسخ بالكامل جوة فولدر `.git` وهيخلي حجم المستودع 300 ميجا بايت! مع الوقت المستودع هينفجر والـ clone هيبقى مستحيل".
عشان كدة، الحل هو استخدام **Git LFS (Large File Storage)**.

تحت الغطاء، Git LFS بيحل الأزمة دي كالتالي:
1. المطور بيحدد أنواع الملفات الكبيرة (زي `*.mp4`, `*.zip`, `*.psd`) لـ Git LFS ليقوم بتتبعها.
2. لما المطور بيعمل commit لملف كبير، الـ Git LFS بيسحب الملف الحقيقي ويخزنه في سيرفر سحابي مخصص للملفات الكبيرة (LFS Store).
3. جوة مستودع الـ Git الرئيسي، الـ LFS بيستبدل الملف الكبير ده بـ **ملف نصي صغير جداً (Pointer file)** حجمه حوالي 150 بايت فقط!
4. الملف النصي الصغير ده بيحتوي فقط على معلومات الملف الأصلي: الـ SHA-256 Hash بتاعه، وحجمه الحقيقي.
5. لما مطور تاني يعمل clone، هو بينزل الأكواد والملفات النصية الصغيرة دي بسرعة البرق. ولما يجي يعمل checkout للفرع، الـ Git LFS محلياً بيقرأ الملفات النصية دي، ويروح يحمل الفيديوهات والملفات الكبيرة الخاصة بالكوميت الحالية فقط من السيرفر السحابي ويستبدلها بالملفات الحقيقية على الهارد ديسك.

```bash
# 1. تثبيت Git LFS على جهازك (لمرة واحدة فقط)
git lfs install

# 2. تحديد أنواع الملفات الكبيرة المراد تتبعها (مثلاً كل الفيديوهات)
git lfs track "*.mp4"
# هذا الأمر ينشئ أو يعدل ملف اسمه .gitattributes يجب رفعه للمستودع

# 3. التأكد من إضافة ملف الإعدادات للمستودع
git add .gitattributes

# 4. إضافة الملف الكبير وعمل commit كالمعتاد
git add promo_video.mp4
git commit -m "media: add promotional video for main page"
git push origin main
```

#### مثال 1: فحص ملف الـ Pointer تحت الغطاء
أحمد حب يشوف الـ Pointer file اللي Git بيخزنه بدل الفيديو الحقيقي. كتب أمر قراءة الملف ولقى محتواه كالتالي:
```text
version https://git-lfs.github.com/spec/v1
oid sha256:4b8a1c2d3e4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9u0v1w2x3y4z5a6b7c8d9e0f
size 157286400
```
ده معناه إن الـ Git الرئيسي ميعرفش أي حاجة عن الفيديو غير الـ ID ده وحجمه، وده مبيستهلكش أي مساحة في تاريخ الـ Commits.

#### مثال 2: توفير مساحة القرص الصلب للمطورين
منى انضمت للتيم وعملت clone للمشروع. بما إن المشروع فيه فيديوهات قديمة كتير اتعدلت على مدار سنة ومجموع حجمها 5 جيجا، هي منزلتش الـ 5 جيجا دول! هي فقط نزل معاها كود المشروع (15 ميجا) والفيديو الأخير المستخدم حالياً (100 ميجا). الـ 4.9 جيجا الباقيين فضلوا على سيرفر الـ LFS ومستهلكوش مساحة من جهازها ولا وقت من الكلون.

### الفايدة الانترفيوية
> **Interview Question:**
> *"Why does standard Git struggle with large binary files, and how does Git LFS (Large File Storage) solve this issue under the hood? Describe pointer files."*
>
> **الإجابة المثالية:**
> يواجه Git العادي صعوبة مع الملفات الثنائية الكبيرة (Large Binary Files) لأنه مصمم لتخزين التاريخ الكامل للمشروع؛ وحيث إنه لا يستطيع عمل Diff (فروقات نصية) للملفات الثنائية، فإنه يقوم بتخزين نسخة كاملة جديدة من الملف مع كل تعديل داخل مجلد `.git` المحلي. هذا يؤدي لتضخم حجم المستودع بشكل كبير وبطء عمليات الـ clone والـ push.
> **حل Git LFS:**
> يقوم Git LFS بحل هذه المشكلة عن طريق استبدال الملفات الثنائية الكبيرة بـ **ملفات نصية مرجعية صغيرة (Pointer Files)** داخل مستودع Git الرئيسي. تحتوي هذه الـ pointers على مراجع للملف الأصلي (SHA-256 Hash وحجم الملف).
> بينما يتم تخزين الملفات الثنائية الفعلية على سيرفر سحابي منفصل (LFS Cache/Store). عند إجراء `clone` أو `checkout`، يقوم برنامج Git LFS المساعد بتحميل الملفات الفعلية الخاصة بالإصدار المطلوب فقط واستبدال الـ pointers بها محلياً، مما يحافظ على صغر حجم المستودع وسرعة أدائه.

---

## Q58 — الـ Git Hooks والـ Husky: إزاي بتمنع رفع كود بايظ وتفرض الـ Linting والـ Unit Tests تلقائياً قبل الـ Commit؟

### أصل الحكاية
أحمد بيراجع الـ PRs ولقى إن شادي نسي يشغل الـ Prettier والـ ESLint على جهازه، ورفع كود فيه مسافات غلط وأقواس ناقصة ومتغيرات غير مستخدمة. منى كمان رفعت كود فيه Test مكسور وبوظ الـ Build على السيرفر.
أحمد تنهد وقرر يحط نظام أمان يمنع المشاكل دي من المصدر — يعني على أجهزة المطورين محلياً وقبل ما الكود يترفع أو حتى يتعمل له commit.
أحمد استخدم الـ **Git Hooks**.
الـ Git Hooks هي سكربتات تطلقها بيئة الـ Git تلقائياً عند حدوث أحداث معينة (مثل: قبل ما تعمل commit، أو قبل ما تعمل push، أو عند كتابة رسالة commit).
السكربتات دي موجودة في المسار الافتراضي `.git/hooks/` على جهاز كل مطور.
ولأن الفولدر `.git` غير مرفوع على السيرفر (مستبعد تلقائياً)، فكان من الصعب مشاركة السكربتات دي مع باقي التيم. عشان كدة، أحمد استخدم مكتبة اسمها **Husky** في مشروع الـ Node.js لتسهيل كتابة ومشاركة الـ Hooks مع كل مطوري الفريق.

أهم الـ Hooks المستخدمة:
1. **`pre-commit`**: بيشتغل أول ما تكتب `git commit`. بيعمل فحص للكود (Linting/Formatting). لو وجد أي خطأ، بيلغي عملية الـ commit فوراً ويجبر المطور يصلح الكود الأول.
2. **`pre-push`**: بيشتغل أول ما تكتب `git push`. بيشغل الـ Unit Tests بالكامل. لو فيه Test واحد مكسور، بيلغي الـ push ويمنع وصول الكود للسيرفر.
3. **`commit-msg`**: بيستخدم للتأكد من أن رسالة الكوميت مكتوبة بأسلوب منظم (زي Conventional Commits).

```bash
# 1. تثبيت Husky في مشروع Node.js
npm install husky --save-dev

# 2. تفعيل Husky وإنشاء الفولدر المخصص للمشاركة
npx husky init
# هذا الأمر ينشئ مجلد .husky/ ويضيف سكربت التثبيت التلقائي في package.json

# 3. إضافة Hook من نوع pre-commit يشغل الـ Linting محلياً
echo "npm run lint" > .husky/pre-commit

# 4. إضافة Hook من نوع pre-push يشغل الاختبارات قبل الرفع للسيرفر
echo "npm test" > .husky/pre-push

# 5. الآن، بمجرد كتابة git commit، سيقوم Husky بتشغيل npm run lint تلقائياً.
# إذا فشل الفحص، ستفشل الـ commit ولن تُنشأ.
```

#### مثال 1: شادي يتعلم الالتزام بالـ formatting مجبراً
شادي كتب كود غير منسق وجرب يعمل `git commit -m "feat: update card component"`.
بمجرد ما ضغط Enter، الـ pre-commit hook اشتغل وطلع:
`ESLint found 3 errors. Commit aborted.`
شادي عرف إن الـ Git مش هيسمحله بالكسل. كتب `npm run lint -- --fix` لتصليح الأخطاء تلقائياً، وبعدين عمل الـ commit بنجاح.

#### مثال 2: منع الكوميتس العشوائية بـ `commit-msg`
منى كتبت رسالة كوميت مبهمة جداً: `git commit -m "fix stuff"`.
الـ `commit-msg` hook اشتغل وقارن الرسالة بالقواعد المطلوبة (Conventional Commits) ولقاها غير متطابقة. لغى الكوميت وكتبلها:
`Error: Commit message must follow pattern: type(scope): description. Example: feat(auth): add login button.`
منى غيرت الرسالة لـ `git commit -m "fix(payment): resolve crash on Safari"` فقبلها الـ Git فوراً.

### الفايدة الانترفيوية
> **Interview Question:**
> *"What are Git Hooks? How do tools like Husky help share hooks across a development team, and how can they be used to enforce code quality locally?"*
>
> **الإجابة المثالية:**
> الـ Git Hooks هي سكربتات مخصصة يقوم Git بتشغيلها تلقائياً قبل أو بعد أحداث معينة في دورة حياة الفيرجن كونترول (مثل `pre-commit`, `pre-push`, `commit-msg`). تُستخدم لفرض معايير الجودة والحماية بشكل محلي على جهاز المطور.
> **دور Husky:**
> تكمن المشكلة في أن مجلد `.git/hooks/` المحلي لا يتم رفعه للمستودع المشترك (غير مراقب بواسطة Git)، مما يجعل مشاركة هذه السكربتات مع الفريق أمراً صعباً. تحل أداة **Husky** هذه المشكلة عن طريق تمكين المطورين من كتابة الـ hooks كملفات نصية عادية داخل مجلد `.husky/` الذي يتم رفعه للمستودع كباقي كود المشروع. عند قيام مطور آخر بعمل clone وتثبيت الحزم بـ `npm install`، تقوم Husky تلقائياً بربط هذه السكربتات ببيئة الـ Git المحلية لديه.
> **فرض الجودة:**
> تُستخدم لـ:
> 1. تشغيل الفحص والتنسيق (`npm run lint` & `prettier`) في مرحلة الـ `pre-commit` لمنع دخول أكواد غير منسقة للمستودع.
> 2. تشغيل الاختبارات الوظيفية (`npm test`) في مرحلة الـ `pre-push` لضمان عدم رفع كود معطل للسيرفر.
> 3. التحقق من صياغة رسائل الكوميت بـ `commit-msg` لضمان اتساق لوج المشروع.

> [!tip] Checkpoint
> تهانينا الحارة! بكدة نكون خلصنا الموضوع السابع والأخير (Topic 7) وقفلنا الدليل الشامل لـ Git & GitHub بالكامل من الصفر المطلق لأعمق نقطة تحتاجها في حياتك العملية والإنترفيو. أنت الآن مسلح بكل المفاهيم النظرية، الهياكل المعمارية الداخلية، والسيناريوهات الواقعية اللي بتدور في أكبر الشركات البرمجية. بالتوفيق الباهر في الإنترفيو القادم!
