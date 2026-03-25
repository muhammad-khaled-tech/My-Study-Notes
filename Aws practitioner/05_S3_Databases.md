# 🪣 Amazon S3 + 🗄️ Databases & Analytics
**AWS Certified Cloud Practitioner — CLF-C02**
*Elite Egyptian AWS Cloud Architect & Mentor | Stephane Maarek Slides v42 — Sections 8 & 9*

---

## 🪣 Section 8 — Amazon S3

---

### Amazon S3 — Overview & Use Cases

#### 1. The Naive Approach (The Problem):

كل الـ Storage اللي اتكلمنا عنه لحد دلوقتي (EBS, EFS, Instance Store) مرتبط بالـ EC2 Instances. لو عندك ملف عايز تحطه على الـ Internet بدون Server — ملف صورة، فيديو، JavaScript Code، CSV Data — فين بتحطه؟ الـ Traditional Answer كان FTP Server أو Shared Drive — محدود، مكلّف، ومش Scalable. الـ S3 جاي يكون الـ Universal Object Store للـ Internet.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — What is S3?
>
> الـ **Amazon S3 (Simple Storage Service)** هو **Object Storage Service** — مش Block Storage (زي EBS) ومش File System (زي EFS). بيخزّن **Objects** (Files) جوه **Buckets** (Containers).
>
> **الفرق الجوهري: Object vs Block vs File Storage:**
> - **Block (EBS):** بتكتب Data بالـ Block — الـ OS بيتعامل معاه كـ Raw Disk. سريع ومناسب لـ Databases وOS Boot.
> - **File (EFS/FSx):** بتشوف Folders وFiles. الـ OS بيـ Mount الـ File System.
> - **Object (S3):** مفيش Folders حقيقية. كل Object عنده **Key** (اسم كامل) وـ **Value** (المحتوى). بتوصّله عبر HTTP API (PUT, GET, DELETE).
>
> **الـ S3 Use Cases الأساسية:**
> - **Backup & Storage:** أرخص وأكثر Durability من أي Storage تاني
> - **Disaster Recovery:** Replicated تلقائياً على Multiple AZs
> - **Archive:** Glacier Storage Classes للـ Long-Term Archive
> - **Hybrid Cloud Storage:** Bridge بين On-Premise والـ Cloud (عبر Storage Gateway)
> - **Application Hosting:** Static Websites، JavaScript SPAs
> - **Media Hosting:** Images، Videos، Audio Files
> - **Data Lakes & Big Data Analytics:** S3 كـ Central Data Repository
> - **Software Delivery:** بيوزّع الـ Software Packages والـ Updates
> - **Static Websites:** بتـ Host HTML/CSS/JS مباشرة من S3
>
> **أمثلة Real-World:**
> - **Nasdaq** بتخزّن 7 سنين من الـ Financial Data في S3 Glacier
> - **Sysco** بتشغّل Analytics على الـ Data بتاعتها من S3

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ S3 زي **مستودع ضخم جداً على الـ Internet** — زي Amazon Warehouse لكن للـ Files مش للـ Products. أي حاجة تحطها فيه بتبقى Available على الـ Internet 24/7 من أي مكان في العالم. المستودع "Infinitely Scalable" — مهما حطيت، في مكان.

الـ Bucket ده الـ "رف" في المستودع — إنت بتسميه واسمه لازم يكون Unique في العالم كله (زي Domain Name). والـ Object ده الـ "منتج" اللي بتحطه على الرف — ممكن يكون صورة، فيديو، Excel File، أي حاجة.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — S3 Overview
>
> - **S3 is NOT a File System and NOT a Block Storage.** هو **Object Storage**. مش بتعمله Mount زي EFS، ومش بتستخدمه كـ OS Boot Drive.
> - **S3 looks Global but Buckets are Regional.** الـ Console بيبان فيه إن S3 Global لكن كل Bucket بيتعمل في Region محددة.
> - **S3 is "infinitely scalable"** — ده الـ Marketing Term اللي Stephane بيذكره. مش في Capacity Planning.
> - الـ Use Cases ضروري تحفظها — الـ Exam بيسأل "which service for Data Lake?" أو "which for Static Website?" → S3.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Type** | Object Storage (مش Block ومش File) |
| **Scope** | Global Console — لكن Buckets في Region محددة |
| **Scalability** | Infinitely Scalable — No Capacity Planning |
| **Durability** | 99.999999999% (11 9's) |
| **Access** | HTTP API (GET/PUT/DELETE) |
| **Max Object Size** | 5 TB |

---

### S3 Buckets & Objects

#### 1. The Naive Approach (The Problem):

في الـ File System، بتنظّم Files في Folders جوه Folders. الـ S3 مختلف جوهرياً — مش في Folders حقيقية. فيه Buckets وObjects وكل Object عنده Key. لو مفهمتش الـ Model ده، هتتوه في الـ Exam.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Buckets & Objects Internals
>
> **Buckets:**
> الـ Bucket هو الـ Top-Level Container في S3. كل Object لازم يكون جوه Bucket.
>
> **قواعد تسمية الـ Bucket (مهمة للـ Exam):**
> - **Globally Unique Name** — عبر كل الـ Regions وكل الـ AWS Accounts. لو حد تاني اخد الاسم ده — مش هتقدر تاخده.
> - **Lowercase only** — No uppercase letters
> - **No underscore** — بس hyphens (-)
> - **3-63 characters** طول
> - **مش IP Address** — مش `192.168.1.1`
> - **يبدأ بـ Lowercase letter أو Number**
> - **مش يبدأ بـ `xn--`** (Reserved prefix)
> - **مش ينتهي بـ `-s3alias`** (Reserved suffix)
>
> **Objects:**
> كل File بتحطه في S3 هو Object. الـ Object بيتكوّن من:
>
> **① Key (المفتاح):**
> الـ Key هو الاسم الكامل للـ Object — هو الـ Full Path:
> - `s3://my-bucket/my_file.txt` → Key = `my_file.txt`
> - `s3://my-bucket/my_folder/another_folder/my_file.txt` → Key = `my_folder/another_folder/my_file.txt`
>
> **⚠️ مفيش Directories حقيقية في S3:**
> الـ UI بيوهمك إن في Folders، لكن في الحقيقة الـ `/` في الـ Key اسم بس. الـ Key كلها String واحدة. `my_folder/file.txt` ده مجرد Key اسمه طويل فيه Slash.
>
> **② Value (المحتوى):**
> محتوى الـ File نفسه.
> - **Max Object Size: 5 TB (5,000 GB)**
> - لو بتـ Upload أكتر من **5 GB** في مرة واحدة → لازم تستخدم **Multi-Part Upload**
>
> **③ Metadata:**
> Key-Value pairs بتوصف الـ Object (Content-Type, Last-Modified, Custom Metadata).
>
> **④ Tags:**
> Unicode Key-Value Pairs — حتى 10 Tags. بتستخدمها للـ Security وLifecycle Management.
>
> **⑤ Version ID:**
> لو Versioning مفعّل — كل نسخة من الـ Object بياخد Version ID.

#### 3. The Mentor's Story (The "Ashta" Analogy):

تخيل **مكتبة** (Bucket). كل كتاب (Object) عنده **رقم تصنيف** (Key) — زي `علوم/فيزياء/ميكانيكا_كم.pdf`. المكتبة مش فيها رفوف فعلية — كل الكتب على الأرض، لكن رقم التصنيف بيبدأ بـ `علوم/` عشان تعرف إنه في قسم العلوم. الـ "/" في الاسم مش Folder — هو جزء من الاسم.

اسم المكتبة (Bucket Name) لازم يكون فريد في **العالم كله** — زي Domain Name. لو فيه مكتبة اسمها `alex-library` في لندن — إنت مش تقدر تسمي مكتبتك `alex-library` حتى لو في Tokyo.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Buckets & Objects
>
> - **Bucket Name = Globally Unique** — مش Region-unique. عبر كل الـ Accounts.
> - **No Real Directories in S3** — الـ Slash في الـ Key مجرد جزء من الاسم. الـ Exam ممكن يسألك "what is the key?" → الإجابة هي الـ Full Path مع الـ "Folders".
> - **Max Object Size = 5 TB.** Upload > 5 GB → Multi-Part Upload.
> - **Buckets defined at Region level** — حتى لو الـ Console يبان فيه Global.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Bucket Name** | Globally Unique — Lowercase — 3-63 chars |
| **Object Key** | Full Path (Prefix + Object Name) |
| **Max Object Size** | 5 TB |
| **Upload > 5 GB** | يلزم Multi-Part Upload |
| **Directories** | ❌ مفيش Directories حقيقية — بس Keys بـ Slashes |
| **Metadata** | System أو User-defined Key-Value Pairs |
| **Tags** | حتى 10 — للـ Security وLifecycle |

---

### S3 Security — IAM, Bucket Policies, ACLs

#### 1. The Naive Approach (The Problem):

عندك Bucket فيه Files حساسة (Customer Data) وFiles عامة (Static Website Images). محتاج نظام دقيق للتحكم في مين يوصل لإيه. الـ S3 Security بيتعامل معاه من زاويتين: User-Based (مين المستخدم) وResource-Based (على مستوى الـ Bucket أو الـ Object نفسه).

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — S3 Security Layers
>
> **User-Based Security:**
>
> **IAM Policies:**
> بتحدد Permissions على مستوى الـ IAM User/Role. مثلاً "IAM User Ahmed مسموحله بـ `s3:GetObject` على Bucket `my-bucket`." الـ Policy دي بتتحط على الـ User/Role في IAM — مش على الـ Bucket.
>
> **Resource-Based Security:**
>
> **① S3 Bucket Policies (الأهم والأكثر استخداماً):**
> JSON Document بيتحط مباشرة على الـ Bucket. بيحدد من الـ Principal (User, Account, Anyone) إيه الـ Allowed أو Denied Actions على الـ Bucket أو Objects فيه.
>
> ```json
> {
>   "Version": "2012-10-17",
>   "Statement": [{
>     "Effect": "Allow",
>     "Principal": "*",
>     "Action": "s3:GetObject",
>     "Resource": "arn:aws:s3:::my-bucket/*"
>   }]
> }
> ```
> الـ Policy دي بتسمح لأي حد (`"Principal": "*"`) يقرأ (`s3:GetObject`) أي Object في الـ Bucket.
>
> **الـ 3 Use Cases الرئيسية للـ Bucket Policy:**
> 1. **Grant Public Access:** اسمح لكل الـ Internet يقرأ الـ Objects (للـ Static Websites)
> 2. **Force Encryption:** افرض إن كل Object بيتـ Upload لازم يكون Encrypted
> 3. **Cross-Account Access:** اسمح لـ AWS Account تاني يوصل لـ Bucket بتاعك
>
> **② Object ACL (Access Control List):**
> Finer-grain Permissions على مستوى Object واحد. ممكن تـ Disable. قديم نسبياً — الـ Bucket Policies أحسن.
>
> **③ Bucket ACL:**
> Permissions على مستوى الـ Bucket كله. أقل شيوعاً من Bucket Policies. ممكن تـ Disable.
>
> **الـ Access Decision Logic:**
> الـ IAM Principal بيقدر يوصل لـ S3 Object لو:
> - الـ **IAM Permission ALLOWS it** OR الـ **Bucket Policy ALLOWS it**
> - **AND مفيش Explicit DENY**
>
> الـ Explicit Deny بيـ Override أي Allow — نفس قاعدة IAM.
>
> **Block Public Access Settings:**
> AWS بتوفر Account-level أو Bucket-level Setting بتـ Block أي Public Access حتى لو الـ Bucket Policy بتسمح بيه. ده Safety Net لمنع الـ Data Leaks العرضية. لو عارف إن الـ Bucket مش هيكون Public أبداً — اتركه Enabled.
>
> **S3 Encryption:**
> - **Server-Side Encryption (Default):** AWS بتشفّر الـ Object بعد ما يوصلها وقبل ما تحطه على الـ Disk. بتحصل تلقائياً.
> - **Client-Side Encryption:** إنت بتشفّر الـ File قبل الـ Upload. الـ File وصلت لـ AWS مشفّرة من قبل.
>
> **IAM Access Analyzer for S3:**
> Tool بتراجع Bucket Policies وACLs وتقولك لو Bucket مفتوح للعالم أو مشارك مع Account تاني — عشان تضمن إن بس الناس المفروض توصل بتوصل.

#### 3. The Mentor's Story (The "Ashta" Analogy):

تخيل الـ S3 Bucket زي **مخزن في شركة**. الـ Security بيشتغل من طرفين:

**IAM Policies (User-Side):** البطاقة الشخصية للموظف — "Ahmed مسموحله بدخول المخزن وقراءة الملفات." ده مكتوب في ملف الموظف في HR.

**Bucket Policy (Resource-Side):** اللافتة على باب المخزن نفسه — "المخزن ده: كل الموظفين ممنوعين من الدخول إلا بإذن كتابي" أو "الباب ده مفتوح للعموم" أو "فقط موظفي الشركة X المسموح لهم."

لو الموظف عنده Badge (IAM Allows) **أو** اللافتة بتسمحله (Bucket Policy Allows) → يدخل. لو في أي Explicit Deny في أي مكان → ممنوع تماماً.

**Block Public Access** زي **Master Lock إضافي** على الباب — حتى لو اللافتة قالت "الباب مفتوح"، الـ Master Lock يخليه موقّف.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — S3 Security
>
> - **Bucket Policy = Resource-Based.** IAM Policy = User/Identity-Based. الاتنين ممكن يشتغلوا مع بعض.
> - **Cross-Account Access → Bucket Policy.** مش IAM Policy لوحدها. لازم الـ Bucket Policy في Account الـ Source تسمح للـ Account التاني.
> - **Public Access → Bucket Policy (Allow `*`).** بس لازم كمان تشيل Block Public Access Settings.
> - **Block Public Access = Safety Net.** حتى لو الـ Bucket Policy بتسمح بـ Public — لو Block Public Access Enabled، مش هيكون Public.
> - **S3 Default Encryption = Server-Side.** بياخد من غير ما تعمل حاجة. Client-Side = إنت بتشفّر قبل الـ Upload.
> - **Access Rule:** IAM Allows OR Bucket Policy Allows → Access. ANY Explicit Deny → Block.

#### 5. The "Zatouna" Table:

| Security Type | النوع | الـ Use Case |
|---|---|---|
| **IAM Policies** | User-Based | تحديد Permissions لـ User/Role |
| **Bucket Policy** | Resource-Based | Public Access, Cross-Account, Force Encryption |
| **Object ACL** | Resource-Based (Fine-grained) | ممكن تـ Disable |
| **Bucket ACL** | Resource-Based | Uncommon — ممكن تـ Disable |
| **Block Public Access** | Safety Net | يمنع أي Public Access عرضي |
| **Server-Side Encryption** | Default | AWS بتشفّر بعد الاستقبال |
| **Client-Side Encryption** | Optional | إنت بتشفّر قبل الـ Upload |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q1
> **A company wants to allow all internet users to read objects from an S3 bucket (to host a static website) while ensuring no user can accidentally make the bucket public through future IAM policy changes. What combination is CORRECT?**
>
> - A. Add an IAM policy allowing `s3:GetObject` for all principals and enable Block Public Access
> - B. Add a Bucket Policy allowing `s3:GetObject` for all principals (`"Principal": "*"`) and DISABLE Block Public Access settings
> - C. Enable Object ACLs on each object and set them to Public Read
> - D. Create an IAM Role with S3 ReadOnly access and assign it to all users

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> To make a bucket publicly readable for a static website: (1) A **Bucket Policy** with `"Principal": "*"` and `s3:GetObject` allows all internet users to read. (2) **Block Public Access must be DISABLED** — even if the bucket policy allows public access, Block Public Access settings will override it and prevent public access. Both steps are required together.
>
> **Why A is wrong:** IAM policies can't grant access to anonymous internet users (they apply to IAM principals, not unauthenticated users). Also, enabling Block Public Access would block the policy anyway.
> **Why C is wrong:** Object ACLs work but require setting them on every object individually — not scalable. Also, Block Public Access needs to be disabled. Bucket Policy is the correct scalable approach.
> **Why D is wrong:** IAM Roles are for authenticated AWS principals, not anonymous internet visitors.

---

### S3 Static Website Hosting

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics
>
> الـ S3 بيقدر يعمل Host لـ **Static Websites** مباشرة من الـ Bucket — HTML, CSS, JavaScript, Images — من غير Server أو EC2.
>
> **الـ Website URL Format:**
> - `http://bucket-name.s3-website-aws-region.amazonaws.com`
> - OR: `http://bucket-name.s3-website.aws-region.amazonaws.com`
> (بيختلف حسب الـ Region)
>
> **شروط الـ Static Website Hosting:**
> - تفعيل Static Website Hosting من الـ Bucket Settings
> - الـ Objects (HTML Files) لازم تكون Publicly Readable
> - الـ Bucket Policy لازم تسمح بـ `s3:GetObject` لكل الـ World
> - لو جالك **403 Forbidden** → الـ Bucket Policy مش صح أو Block Public Access لسه Enabled
>
> **Static vs Dynamic:**
> Static Website = HTML/CSS/JS فقط — بيشتغل في المتصفح بدون Server-side Code.
> Dynamic Website = محتاج Server يشتغل عليه (PHP, Python, Node.js) → مش بيشتغل على S3 وحده.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Static Website
>
> - **403 Forbidden على Static Website = Bucket Policy Problem** أو Block Public Access Enabled.
> - **S3 Static Website = HTTP only by default.** لو عايز HTTPS → محتاج CloudFront Distribution.
> - **Static فقط** — HTML/CSS/JS. مش PHP أو Server-side Code.

---

### S3 Versioning

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Versioning
>
> الـ **Versioning** بيتفعّل على مستوى الـ Bucket. لما تفعّله، كل مرة بتـ Upload Object بنفس الـ Key — بدل ما يتستبدل الـ File القديمة، بيتضاف **Version جديد**:
> - `my-file.docx` Version 1 → Version 2 → Version 3
>
> **فوايد الـ Versioning:**
> - **Protect against Accidental Deletes:** لما بتحذف Object بـ Versioning مفعّل، بيتضاف "Delete Marker" بدل الحذف الحقيقي. الـ Object الأصلي موجود وتقدر تسترجعه.
> - **Easy Rollback:** ترجع لـ Version سابق في ثانية.
>
> **ملاحظات مهمة:**
> - الـ Files اللي كانت موجودة **قبل** تفعيل Versioning بياخدوا Version = **"null"**
> - لو **Suspended** الـ Versioning — الـ Versions الموجودة مش بتتمسح. بس الـ Uploads الجديدة مش بتاخد Versions.
> - تفعيل Versioning → بتدفع على **كل الـ Versions** جوه الـ Bucket — ممكن يزوّد التكلفة لو الـ Files بتتغير كتير.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Versioning
>
> - **Versioning Enabled at Bucket Level** — مش Object Level.
> - **Pre-versioning files get Version ID = "null"** — مش Empty String ومش Zero.
> - **Suspending Versioning ≠ Deleting Versions.** الـ Old Versions بتفضل موجودة.
> - **Delete with Versioning = Adds Delete Marker,** مش حذف فعلي. تقدر ترجعه.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Level** | Bucket-level |
| **Pre-existing Files Version** | "null" |
| **Delete Action** | يضيف Delete Marker (مش حذف حقيقي) |
| **Suspend Versioning** | Old Versions تفضل — New Uploads بدون Version |
| **Use Case** | Rollback, Accidental Delete Protection |

---

### S3 Replication — CRR & SRR

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Replication
>
> الـ S3 Replication بيسمحلك بنسخ Objects تلقائياً من Bucket لآخر.
>
> **نوعان:**
>
> **① CRR (Cross-Region Replication):**
> - الـ Source Bucket في Region A والـ Destination Bucket في Region B
> - **Use Cases:** Compliance (البيانات لازم تكون في أكتر من Region)، Lower Latency (بتخدم Users أقرب ليهم)، Cross-Account Replication
>
> **② SRR (Same-Region Replication):**
> - الـ Source والـ Destination في نفس الـ Region
> - **Use Cases:** Log Aggregation (جمع Logs من Buckets متعددة في Bucket واحد)، Live Replication بين Production وTest Accounts
>
> **الشروط اللازمة:**
> - **Versioning لازم يكون Enabled** في الـ Source وفي الـ Destination Bucket
> - الـ Copying **Asynchronous** — مش Real-time Instant
> - لازم تدي S3 الـ Proper IAM Permissions عشان يعمل الـ Replication

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Replication
>
> - **Versioning لازم Enabled** في الـ Source AND Destination. لو Disabled في أي منهم — الـ Replication مش هتشتغل.
> - **CRR = Cross-Region. SRR = Same-Region.** الـ Exam بيميّز بينهم بـ Use Case.
> - **Replication = Asynchronous** — مش Real-time. في Lag صغير.
> - **Buckets can be in different AWS Accounts** مع الـ Replication.

---

### S3 Storage Classes

#### 1. The Naive Approach (The Problem):

مش كل البيانات متساوية. الـ Data اللي بتوصّلها كل يوم مختلفة عن الـ Data اللي بتحتاجها مرة كل سنة. لو بتدفع نفس السعر على كل حاجة — بتضيّع فلوس. الـ S3 Storage Classes بيديك 7 خيارات بأسعار وـ Access Patterns مختلفة.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — All 7 Storage Classes
>
> **القاعدة الأساسية:** Durability ثابتة للكل = **99.999999999% (11 9's)**. اللي بيختلف هو الـ Availability والسعر وسرعة الـ Retrieval.
>
> ---
>
> **① S3 Standard — General Purpose:**
> - **Availability:** 99.99%
> - **Minimum Storage Duration:** لا يوجد
> - **Retrieval Fee:** لا يوجد
> - **Use Cases:** Frequently accessed data — Big Data Analytics، Mobile Apps، Content Distribution
> - الأغلى من ناحية الـ Storage لكن Zero Retrieval Cost
>
> ---
>
> **② S3 Standard-IA (Infrequent Access):**
> - **Availability:** 99.9%
> - **Minimum Storage Duration:** 30 يوم
> - **Retrieval Fee:** Per GB Retrieved
> - **Use Cases:** Disaster Recovery، Backups اللي مش بتوصّلها كل يوم
> - أرخص من Standard في الـ Storage لكن بتدفع لما بتوصّلها
>
> ---
>
> **③ S3 One Zone-IA:**
> - **Availability:** 99.5%
> - **AZs:** 1 فقط (ده الفرق الجوهري)
> - **Minimum Storage Duration:** 30 يوم
> - **الخطورة:** لو الـ AZ اتدمرت — البيانات اتفقدت نهائياً
> - **Use Cases:** Secondary Backups لـ On-Premise Data، بيانات ممكن تعيد إنشاؤها
>
> ---
>
> **④ S3 Glacier Instant Retrieval:**
> - **Retrieval Time:** Milliseconds (زي Standard!)
> - **Minimum Storage Duration:** 90 يوم
> - **Cost:** أرخص بكتير من Standard في الـ Storage لكن بتدفع على الـ Retrieval
> - **Use Cases:** Data بتوصّلها مرة كل ربع سنة (Quarterly) لكن لما تحتاجها عايزها فوراً
>
> ---
>
> **⑤ S3 Glacier Flexible Retrieval (formerly "S3 Glacier"):**
> - **Retrieval Options:**
>   - **Expedited:** 1-5 دقايق (الأغلى)
>   - **Standard:** 3-5 ساعات
>   - **Bulk:** 5-12 ساعات (Free)
> - **Minimum Storage Duration:** 90 يوم
> - **Use Cases:** Archives — Backup/Restore بدون Real-time Requirements
>
> ---
>
> **⑥ S3 Glacier Deep Archive:**
> - **Retrieval Options:**
>   - **Standard:** 12 ساعة
>   - **Bulk:** 48 ساعة
> - **Minimum Storage Duration:** 180 يوم
> - **الأرخص Storage Cost** في S3 كلها (`$0.00099 per GB/month`)
> - **Use Cases:** Long-term Archival — Compliance Data، Medical Records، Legal Documents
>
> ---
>
> **⑦ S3 Intelligent-Tiering:**
> - **Monthly Monitoring Fee** إضافي لكل 1000 Object
> - **لا يوجد Retrieval Fee**
> - بيتحرك بين الـ Tiers تلقائياً:
>   - **Frequent Access (Default):** Normal Storage
>   - **Infrequent Access:** لو مش بتوصّله 30 يوم
>   - **Archive Instant Access:** لو مش بتوصّله 90 يوم
>   - **Archive Access (Optional):** 90-700+ يوم
>   - **Deep Archive Access (Optional):** 180-700+ يوم
> - **Use Cases:** Data بـ Unknown أو Changing Access Patterns — مش عارف هتوصّله قد إيه

#### 3. The Mentor's Story (The "Ashta" Analogy):

تخيل إنك بتخزّن ملفات شركة:

**Standard** = مكتبك نفسه — الملفات اللي بتمسّها كل يوم. أسهل وصول لكن أغلى مكان.

**Standard-IA** = **الأرشيف في نفس المبنى** — مش بتروحه كل يوم لكن لما تحتاجه تلاقيه بسرعة. أرخص شوية، لكن بتدفع رسوم كلما رحت.

**One Zone-IA** = **نسخة احتياطية في درج** — بس في حجرة واحدة. لو الحجرة احترقت — ودّعت الملفات.

**Glacier Instant** = **المستودع القريب** — بعيد شوية عن المكتب لكن تقدر توصّله في ثوانٍ لو احتجته.

**Glacier Flexible** = **المستودع البعيد** — رحلة ساعات. تطلب البيانات النهارده وتيجي بكره أو بعده.

**Glacier Deep Archive** = **المخزن تحت الأرض** — أرخص مكان في الكون، لكن ممكن ياخد يومين عشان تطلع منه حاجة. للـ Compliance Records اللي بتحتفظ بيها 10 سنين بالقانون.

**Intelligent-Tiering** = **مساعد ذكي** بيحركلك الملفات بنفسه — الملف اللي بتفتحه كل يوم بيبقى على مكتبك، اللي مش بتفتحه بيتـ Archive. بتدفع رسوم للمساعد شهرياً لكن مش بتدفع لما بتجيب ملف.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Storage Classes
>
> - **One Zone-IA = Data Lost if AZ Destroyed.** ده الـ Trade-off مقابل السعر الأرخص. الـ Exam بيحط ده كـ Trap.
> - **Minimum Storage Duration:** Standard-IA & One Zone-IA = 30 يوم | Glacier Instant & Flexible = 90 يوم | Deep Archive = 180 يوم. لو حذفت قبل الـ Minimum — بتدفع على الـ Minimum.
> - **Glacier Instant Retrieval ≠ Slow.** اسمه Glacier لكن الـ Retrieval بالـ Milliseconds. الـ "Glacier" بيدل على الـ Cost مش الـ Speed هنا.
> - **Intelligent-Tiering = No Retrieval Fee** + Monthly Monitoring Fee. الـ Exam بيسأل عن ده.
> - **"Cheapest storage for long-term compliance" → Deep Archive.**
> - **"Accessed once a quarter but needed immediately" → Glacier Instant Retrieval.**
> - **Lifecycle Configurations:** تقدر تعمل Rules لتحريك الـ Objects بين الـ Classes تلقائياً بناءً على العمر.

#### 5. The "Zatouna" Table:

| Storage Class | Availability | Min Duration | Retrieval | الـ Use Case |
|---|---|---|---|---|
| **Standard** | 99.99% | لا يوجد | Instant — Free | Frequent Access |
| **Standard-IA** | 99.9% | 30 يوم | Instant — Paid | Backups, DR |
| **One Zone-IA** | 99.5% | 30 يوم | Instant — Paid | Secondary Backups (Recreatable) |
| **Glacier Instant** | 99.9% | 90 يوم | Milliseconds — Paid | Quarterly Access, Fast Needed |
| **Glacier Flexible** | 99.99% | 90 يوم | 1-5min/3-5hr/5-12hr | Archives |
| **Glacier Deep Archive** | 99.99% | 180 يوم | 12hr/48hr | Long-term Compliance |
| **Intelligent-Tiering** | 99.9% | لا يوجد | Instant — Free | Unknown Access Pattern |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q2
> **A healthcare company must retain patient records for 10 years to meet regulatory requirements. The records are almost never accessed but must be retrievable within 48 hours if requested. Cost minimization is the top priority. Which S3 storage class is MOST appropriate?**
>
> - A. S3 Standard — for immediate access
> - B. S3 Standard-IA — for infrequent access with fast retrieval
> - C. S3 Glacier Flexible Retrieval — bulk retrieval within 5-12 hours
> - D. S3 Glacier Deep Archive — lowest cost with 48-hour retrieval

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: D — S3 Glacier Deep Archive**
>
> Three signals: (1) **"10 years"** long-term retention — Deep Archive's 180-day minimum fits; (2) **"almost never accessed"** — Deep Archive is for data accessed once or twice a year; (3) **"retrievable within 48 hours"** — Deep Archive's Bulk retrieval is exactly 48 hours, meeting the requirement; (4) **"cost minimization"** — Deep Archive is the cheapest S3 class ($0.00099/GB/month).
>
> **Why C is better than nothing but D is better:** Glacier Flexible Retrieval costs more than Deep Archive ($0.0036 vs $0.00099/GB/month). Both meet the 48-hour SLA (Flexible Bulk = 5-12 hours, well within 48h; Deep Archive Standard = 12h, Bulk = 48h exactly). Since cost is the top priority and both meet the SLA, Deep Archive wins.
> **Why A is wrong:** S3 Standard is the most expensive. Completely unjustified for 10-year rarely accessed archives.
> **Why B is wrong:** Standard-IA costs more than Glacier options and has a 30-day minimum. For 10-year retention, Deep Archive is dramatically cheaper.

---

### AWS Snowball

#### 1. The Naive Approach (The Problem):

عندك 1 Petabyte (= 1,000 TB) من الـ Data On-Premise وعايز ترفعها لـ S3. على خط 10 Gbps — هياخد 12 يوم! الخط المشترك مع باقي الشركة — ممكن يكون أبطأ. الحل؟ مش Network — **شحن فيزيائي**.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — AWS Snowball
>
> الـ **AWS Snowball Edge** هو **Physical Device** آمن وضخم بترسله AWS لـ Data Center بتاعتك، بتحمّله بياناتك، وبتبعته لـ AWS فيشحنوا البيانات لـ S3.
>
> **القاعدة الأساسية:**
> "If it takes more than **a week** to transfer over the network → Use Snowball!"
>
> **نموذجين:**
> | Device | vCPUs | RAM | Storage |
> |---|---|---|---|
> | **Snowball Edge Storage Optimized** | 104 vCPU | 416 GB | 210 TB SSD |
> | **Snowball Edge Compute Optimized** | 104 vCPU | 416 GB | 28 TB SSD |
>
> **Data Migration مع Snowball:**
> - Data Transfer عبر Network على 10 Gbps: 1 PB = 12 يوم
> - مع Snowball: بتطلب Device → AWS بتبعتهوله → بتحمّله → بتبعته لـ AWS → بيرفعوا البيانات لـ S3
>
> **Edge Computing:**
> الـ Snowball مش بس للـ Migration — تقدر تشغّل عليه EC2 Instances وLambda Functions **على الحافة (Edge)** في أماكن مفيهاش Internet (ورا البحر، في المنجم، على شاحنة):
> - Preprocess Data قبل الـ Upload
> - Machine Learning Inference في الـ Field
> - Media Transcoding
>
> **التسعير:**
> - Data Transfer **INTO S3 = $0.00 per GB** (مجاني الرفع)
> - بتدفع على الـ Device Usage والـ Shipping
>
> **Hybrid Cloud — AWS Storage Gateway:**
> لو عندك On-Premise Applications محتاجة توصل لـ S3 بشكل مستمر (مش Migration لمرة واحدة) — بتستخدم **AWS Storage Gateway**. ده Bridge بين الـ On-Premise والـ Cloud:
> - **File Gateway:** بيعرض S3 كـ NFS/SMB File Share للـ On-Premise Servers
> - **Volume Gateway:** بيعرض S3 كـ iSCSI Block Storage
> - **Tape Gateway:** بيمثّل Virtual Tape Library مبني على S3/Glacier

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Snowball & Storage Gateway
>
> - **"Transfer more than 1 week" → Snowball** — ده الـ Rule الحرفي من الـ Slides.
> - **Data Transfer INTO S3 via Snowball = Free.** بتدفع على الـ Device بس.
> - **Snowball Edge = Edge Computing ممكن** — مش بس Migration.
> - **Storage Gateway = Hybrid Cloud Bridge.** لو الـ Exam قال "on-premise needs to access S3" أو "hybrid storage" → Storage Gateway.
> - **Storage Gateway Types:** File، Volume، Tape — الـ Exam ممكن يسأل عن الـ Concept مش التفاصيل عند الـ CCP Level.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Snowball Use Case** | Data Migration > 1 week بالـ Network |
| **Data IN to S3** | $0.00/GB (مجاني) |
| **Edge Computing** | EC2 + Lambda على الـ Device |
| **Storage Optimized** | 210 TB |
| **Compute Optimized** | 28 TB |
| **Storage Gateway** | Hybrid Cloud — On-Premise to S3 Bridge |

---

### Shared Responsibility Model for S3

| المسؤولية | AWS | Customer |
|---|---|---|
| Infrastructure (Durability, Global Security) | ✅ | ❌ |
| Replication of Data across Facilities | ✅ | ❌ |
| Compliance Validation | ✅ | ❌ |
| S3 Versioning Setup | ❌ | ✅ |
| S3 Bucket Policies | ❌ | ✅ |
| S3 Replication Configuration | ❌ | ✅ |
| Data Encryption at Rest/Transit | ❌ | ✅ |
| S3 Storage Class Selection | ❌ | ✅ |

---

### Amazon S3 — Section Summary

| Feature | الجوهر |
|---|---|
| **Buckets** | Globally Unique Name — Defined at Region Level |
| **Objects** | Max 5 TB — Key = Full Path — No Real Directories |
| **Security** | IAM Policy + Bucket Policy + ACL + Block Public Access |
| **Static Website** | HTML/CSS/JS — 403 = Policy Issue |
| **Versioning** | Bucket-level — Pre-existing = "null" — Delete = Marker |
| **Replication** | CRR (Cross-Region) / SRR (Same-Region) — Versioning Required |
| **Standard** | Frequent Access — No Min Duration |
| **Standard-IA** | Infrequent — 30 day min — Retrieval Fee |
| **One Zone-IA** | Single AZ — Data lost if AZ destroyed |
| **Glacier Instant** | Millisecond Retrieval — 90 day min |
| **Glacier Flexible** | Hours Retrieval — 90 day min |
| **Deep Archive** | 48hr Retrieval — 180 day min — Cheapest |
| **Intelligent-Tiering** | Auto-move — No Retrieval Fee |
| **Snowball** | Physical Migration > 1 week — Free Inbound |
| **Storage Gateway** | Hybrid Cloud — On-Premise to S3 |

---

---

## 🗄️ Section 9 — Databases & Analytics

---

### Databases Introduction — Relational vs NoSQL

#### 1. The Naive Approach (The Problem):

الـ S3 وEBS ممتازين لتخزين Files والـ Raw Data. لكن لو عندك Application محتاج يبحث في ملايين السجلات، يربط الـ Users بالـ Orders، يعمل Join بين Tables — الـ File Storage مش مناسب هنا. محتاج **Database** — نظام متخصص لتخزين البيانات المنظّمة والبحث فيها بكفاءة.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Relational vs NoSQL
>
> **Relational Databases (SQL):**
> - البيانات بتتنظّم في **Tables** (جداول) مع **Columns** وRows — زي Excel Spreadsheets
> - الـ Tables بتتربط ببعض عبر **Foreign Keys**
> - بتستخدم **SQL (Structured Query Language)** للـ Queries
> - مثال: جدول Students، جدول Departments، جدول Subjects — كلهم مترابطين
> - **Use Cases:** E-Commerce, ERP, Banking, Traditional Applications
> - **AWS Services:** RDS, Aurora
>
> **NoSQL Databases (Non-Relational):**
> - مبنية لـ Specific Data Models مع Flexible Schema
> - مش لازم كل الـ Records تكون بنفس الـ Columns
> - **أنواع:** Key-Value, Document (JSON), Graph, In-Memory, Search
> - **مزايا:**
>   - **Flexibility:** Schema بيتغيّر بسهولة مع الوقت
>   - **Scalability:** Designed for Horizontal Scaling (Distributed Clusters)
>   - **Performance:** Optimized للـ Specific Access Patterns
> - **AWS Services:** DynamoDB (Key-Value), DocumentDB (Document), Neptune (Graph)
>
> **الـ Benefits من استخدام Managed DBs على AWS:**
> - Quick Provisioning وHigh Availability
> - Automated Backup & Restore
> - **OS Patching مسؤولية AWS** (ده بيختلف عن EC2!)
> - Monitoring وAlerting
> - Vertical وHorizontal Scaling
>
> **DB على EC2 vs Managed DB:**
> تقدر تشغّل MySQL على EC2 Instance — لكن لازم إنت تعمل الـ Backup والـ Patching والـ HA والـ Scaling. الـ Managed Services بتعمل ده كله بدلك.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — DB Intro
>
> - **Managed DB = OS Patching by AWS.** ده عكس الـ EC2 اللي OS Patching مسؤوليتك. ده Exam Trap كلاسيكي.
> - **SQL = Relational = Tables.** NoSQL = Flexible Schema = Key-Value/Document/Graph.
> - **NoSQL = Designed for Scale-Out (Horizontal).** Relational = تاريخياً Scale-Up (Vertical).

---

### Amazon RDS — Relational Database Service

#### 1. The Naive Approach (The Problem):

قبل Managed Databases، لو عايز تشغّل PostgreSQL على AWS — بتشغّل EC2 Instance، تثبّت PostgreSQL، تعمل Backup Script يدوي، تعمل Monitoring يدوي، وتتعذّب كل ما يطلع Security Patch. الـ RDS بياخد كل ده منك.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — RDS Deep Dive
>
> الـ **RDS (Relational Database Service)** هو الـ Managed Relational DB Service في AWS. بيدعم الـ Engines التالية:
> - **PostgreSQL**
> - **MySQL**
> - **MariaDB**
> - **Oracle**
> - **Microsoft SQL Server**
> - **IBM DB2**
> - **Aurora** (AWS Proprietary — هنتكلم عنه بالتفصيل)
>
> **RDS Advantages over DB on EC2:**
> - Automated Provisioning وOS Patching
> - **Continuous Backups** + **Point-in-Time Restore** (PITR) — ترجع لأي لحظة في الـ Past
> - Monitoring Dashboards
> - **Read Replicas** لتحسين الـ Read Performance (حتى 15 Read Replica)
> - **Multi-AZ** للـ Disaster Recovery (HA)
> - Maintenance Windows للـ Upgrades
> - Scaling Capability (Vertical وHorizontal)
> - Storage Backed by EBS
>
> **⚠️ لكن مش تقدر تعمل SSH لـ RDS Instance.** AWS بتـ Manage الـ OS — إنت بتوصله بس عبر الـ DB Connection.
>
> **RDS Deployment Options:**
>
> **① Read Replicas:**
> - بتعمل نسخ Read-Only من الـ Main DB (حتى 15 Replica)
> - الـ Application بتـ Read من الـ Replicas وبتـ Write للـ Main DB فقط
> - الـ Replication Asynchronous
> - **Use Case:** Scale READ workload (لو عندك تطبيق كتير Read وقليل Write)
>
> **② Multi-AZ:**
> - AWS بتعمل **Standby DB** في AZ تانية تلقائياً
> - الـ Replication Synchronous بين الـ Main وStandby
> - الـ Application بيتكلم مع الـ Main فقط (الـ Standby مش Readable عادةً)
> - لو الـ Main AZ فشلت → **Automatic Failover** للـ Standby في دقائق
> - **Use Case:** Disaster Recovery وHigh Availability
>
> **③ Multi-Region (Read Replicas):**
> - بتعمل Read Replicas في Regions مختلفة
> - **Use Cases:** DR في حالة Region Issue، Lower Latency للـ Global Users
> - بتدفع Replication Cost (Data Transfer بين Regions)

#### 3. The Mentor's Story (The "Ashta" Analogy):

**Read Replicas** = زي مكتبة فيها كتاب مشهور (Main DB). بدل ما كل الناس يطابروا على نفس النسخة — بتعمل 5 نسخ (Replicas) موزّعة. الناس بتقرأ من أي نسخة، لكن التعديلات (Write) بتحصل على النسخة الأصلية بس وبتتنسخ للباقي.

**Multi-AZ** = زي إنك عندك نفس الكتاب في فرعين في مدينتين مختلفتين. لو فرع القاهرة احترق — فرع الإسكندرية جاهز فوراً.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — RDS
>
> - **Can't SSH into RDS.** AWS بتـ Manage الـ OS. لو الـ Exam سأل "SSH to RDS" → غلط.
> - **Read Replicas = Scale READ.** مش للـ DR. الـ Writes لسه بتروح للـ Main.
> - **Multi-AZ = High Availability + DR.** مش لـ Scaling. الـ Standby مش Readable.
> - **Multi-Region = DR + Lower Latency للـ Global Reads.** بتدفع Replication Cost.
> - **RDS Backup = Automated.** Point-in-Time Restore متاح.
> - **OS Patching = AWS Responsibility** في RDS (عكس EC2).

#### 5. The "Zatouna" Table:

| Feature | القيمة |
|---|---|
| **Engines** | PostgreSQL, MySQL, MariaDB, Oracle, SQL Server, IBM DB2, Aurora |
| **SSH Access** | ❌ مش ممكن |
| **OS Patching** | AWS Responsibility |
| **Read Replicas** | حتى 15 — Scale READ — Async Replication |
| **Multi-AZ** | HA + DR — Sync Replication — Auto Failover |
| **Multi-Region** | DR + Global Low Latency — Replication Cost |
| **Point-in-Time Restore** | ✅ |

---

### Amazon Aurora

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Aurora
>
> الـ **Aurora** هو Proprietary Database Engine من AWS — مش Open Source. بيدعم PostgreSQL وMySQL كـ Compatible Interfaces (يعني الـ Apps اللي بتستخدم MySQL Driver تقدر تتصل بـ Aurora من غير تغيير).
>
> **الأداء:**
> - **5x أسرع من MySQL** على RDS
> - **3x أسرع من PostgreSQL** على RDS
> - ده لأن Aurora مبنية من الأساس للـ Cloud — مش Port من On-Premise DB Engine
>
> **Storage:**
> - بتكبر تلقائياً بـ increments of **10 GB** حتى **256 TB**
> - مش بتـ Provision Size — بتدفع على الـ Used Storage
>
> **التكلفة:**
> - **20% أغلى من RDS** — لكن أكثر كفاءة وأسرع
>
> **Aurora Serverless:**
> - **Automated Instantiation** وـ Auto-Scaling بناءً على الـ Actual Usage
> - **Pay per second** — مش بتدفع لما مش بتستخدمه
> - **لا يوجد Capacity Planning** — Aurora بتقرر هي
> - **Use Cases:** Infrequent، Intermittent، أو Unpredictable Workloads (مثلاً Dev/Test Environments، Applications بـ Variable Traffic)

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Aurora
>
> - **Aurora = AWS Proprietary** — مش Open Source.
> - **Aurora بيدعم MySQL وPostgreSQL** كـ Compatible Engines — مش Engines جديدة.
> - **Aurora = 5x MySQL, 3x PostgreSQL Performance.**
> - **Aurora = 20% More Expensive than RDS** — لكن أكفأ.
> - **Aurora Serverless = Variable/Unpredictable Workloads** — Pay per second.
> - **Storage grows automatically** up to 256 TB — مش بتـ Provision.

---

### Amazon ElastiCache

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — ElastiCache
>
> الـ **ElastiCache** هو Managed **In-Memory Cache** Service — بيشغّل **Redis** أو **Memcached** كـ Managed Service.
>
> **الـ Concept:**
> الـ Database على الـ Disk — بياخد وقت للـ Query. الـ Cache في الـ RAM — بيرد في Microseconds. الـ Application بيحاول يقرأ من الـ Cache الأول. لو الـ Data موجودة (Cache Hit) → رد سريع جداً. لو مش موجودة (Cache Miss) → يروح الـ DB، يجيب البيانات، يحطها في الـ Cache للمرة الجاية.
>
> **Architecture:**
> ```
> User Request
>      ↓
>  Load Balancer
>      ↓
>  EC2 Instances (Application)
>      ↓ (Read/Write from Cache — Fast)
>  ElastiCache (In-Memory)
>      ↓ (Cache Miss — Read from DB — Slower)
>  RDS Database
> ```
>
> **Use Case:** Reduce DB Load لـ Read-Intensive Workloads. بدل ما الـ DB تستقبل مليون Query لنفس الـ Product Details — بيتخزّن في Cache ويرد في Microseconds.
>
> **Redis vs Memcached:**
> - Redis: أغنى Features — Persistence، Pub/Sub، Sorted Sets، Replication
> - Memcached: Simpler، Pure Caching فقط
>
> **الـ AWS مسؤولة عن:**
> OS Maintenance، Patching، Optimization، Setup، Configuration، Monitoring، Failure Recovery، Backups

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — ElastiCache
>
> - **ElastiCache = Managed Redis/Memcached.** الـ Exam بيسأل "managed in-memory database" → ElastiCache.
> - **ElastiCache vs DAX:** ElastiCache يشتغل مع أي DB (RDS, MySQL, etc.). DAX شغّال مع DynamoDB فقط.
> - **Reduce DB Load = ElastiCache.** للـ Read-Intensive Workloads.

---

### Amazon DynamoDB

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — DynamoDB
>
> الـ **DynamoDB** هو Fully Managed **NoSQL Key-Value Database** من AWS.
>
> **الخصائص الجوهرية:**
> - **Serverless** — مش بتدير Servers أو Clusters
> - **Scales to Massive Workloads:** Millions of Requests/Second، Trillions of Rows، 100s of TB
> - **Single-Digit Millisecond Latency** — حتى على النطاق الضخم
> - **Highly Available:** Replication تلقائي عبر **3 AZs**
> - Integrated مع IAM للـ Security
> - **Low Cost** وAuto Scaling Capabilities
> - **Standard & IA Table Classes** (زي S3 Storage Classes)
>
> **Data Type:**
> **Key-Value** — الـ Item بياخد Primary Key (Partition Key + Optional Sort Key) وAny Attributes. مش محتاج Schema ثابت — كل Item ممكن يكون مختلف.
>
> **DynamoDB Accelerator (DAX):**
> - Fully Managed **In-Memory Cache** مخصص لـ DynamoDB فقط
> - **10x Performance Improvement** — من Single-Digit Milliseconds لـ Microseconds
> - مدمج مع DynamoDB تلقائياً — بتستخدمه بدل ما تتكلم مع DynamoDB مباشرة
> - **الفرق عن ElastiCache:** DAX = DynamoDB ONLY. ElastiCache = Any DB.
>
> **DynamoDB Global Tables:**
> - بتعمل الـ DynamoDB Table Accessible في Multiple Regions
> - **Active-Active Replication:** تقدر تـ Read وWrite من أي Region
> - Low Latency للـ Multi-Region Applications

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ RDS زي **مكتب محاسبة منظّم** — كل ورقة في مكانها، الأوراق مترابطة، لكن الشغل بياخد وقت والـ Scaling صعب.

الـ DynamoDB زي **مستودع Amazon** — ملايين الـ Items، كل Item عنده Barcode (Key)، مش محتاج كل Item يكون بنفس الشكل، والـ Retrieval بالـ Milliseconds. "هاتلي Item رقم ABC123" → يجيبه في ثانية من بين Trillions من الـ Items.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — DynamoDB
>
> - **DynamoDB = NoSQL = Key-Value.** مش SQL ومش Relational.
> - **DynamoDB = Serverless.** مش بتدير EC2 Instances.
> - **DAX = Cache for DynamoDB ONLY.** ElastiCache = Any DB.
> - **DynamoDB Global Tables = Active-Active** — Read/Write من أي Region. ده بيختلف عن RDS Multi-Region اللي هو Read Replicas فقط.
> - **3 AZ Replication تلقائي.**

#### 5. The "Zatouna" Table:

| Feature | القيمة |
|---|---|
| **Type** | NoSQL Key-Value — Serverless |
| **Latency** | Single-Digit Milliseconds |
| **Scale** | Millions RPS — Trillions of rows |
| **Replication** | 3 AZs Automatic |
| **DAX** | In-Memory Cache لـ DynamoDB — 10x Performance |
| **Global Tables** | Active-Active Multi-Region |

---

### Amazon Redshift

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Redshift
>
> الـ **Redshift** هو **Data Warehouse** مبني على PostgreSQL — لكن مش للـ OLTP (Online Transaction Processing). هو للـ **OLAP (Online Analytical Processing)** — يعني الـ Analytics والـ Reporting.
>
> **OLTP vs OLAP:**
> - **OLTP (RDS/Aurora):** آلاف الـ Short Transactions في الثانية — "أضيف Order"، "اشيل Stock"
> - **OLAP (Redshift):** Queries ضخمة على Billions of Rows — "اعمل لي تقرير مبيعات آخر 3 سنين على مستوى كل فرع"
>
> **الخصائص:**
> - **Columnar Storage** (عكس Row-Based في RDS) — بيجمع نفس الـ Column مع بعضه، أسرع للـ Aggregations والـ Analytics
> - **Massively Parallel Query Execution (MPP)** — بيوزّع الـ Query على عشرات الـ Nodes
> - **10x Better Performance** من الـ Data Warehouses التانية
> - بيتكامل مع **QuickSight وTableau** للـ BI/Dashboards
> - **Load data once every hour** (مش Real-time مزي OLTP)
>
> **Redshift Serverless:**
> - Automatically provisions وscales الـ Underlying Capacity
> - Pay only for what you use
> - Use Cases: Reporting، Dashboarding، Real-time Analytics بدون DB Infrastructure Management

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Redshift
>
> - **Redshift = OLAP = Analytics/Warehouse.** مش OLTP. لو الـ Exam سأل "data warehouse" أو "analytics on PBs of data" → Redshift.
> - **Redshift = Based on PostgreSQL لكن مش للـ Transactions.**
> - **Columnar Storage** = أسرع للـ Analytics (Aggregations، COUNT، SUM).
> - **Redshift ≠ Real-time.** بيـ Load Data كل ساعة — مش كل ثانية.

---

### Amazon EMR

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics
>
> الـ **EMR (Elastic MapReduce)** بيساعدك تنشئ **Hadoop Clusters** لتحليل ومعالجة كميات ضخمة من الـ Data.
>
> - Clusters من مئات الـ EC2 Instances
> - بيدعم Apache Spark، HBase، Presto، Flink
> - Auto-scaling ومتكامل مع Spot Instances (لتوفير التكلفة)
> - AWS بتتولى الـ Provisioning والـ Configuration
>
> **Use Cases:** Data Processing، Machine Learning، Web Indexing، Big Data Analytics

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EMR
>
> - **EMR = Hadoop Clusters على AWS.** لو الـ Exam قال "Hadoop" أو "Big Data processing cluster" → EMR.
> - **EMR = EC2 Clusters** (مش Serverless مثل Athena). بتدير EC2 Instances.

---

### Amazon Athena

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Athena
>
> الـ **Athena** هو **Serverless Query Service** بيخليك تعمل SQL Queries مباشرة على الـ Data في **S3** من غير ما تحتاج Database أو Server.
>
> - بيستخدم **Standard SQL**
> - بيدعم: CSV، JSON، ORC، Avro، Parquet
> - مبني على **Presto** (Distributed SQL Engine)
> - **Pricing: $5.00 per TB of data scanned** — كلما قلّ الـ Data Scanned، كلما قلّت التكلفة
> - لو استخدمت Columnar Format (Parquet/ORC) أو Compressed Data → بتسكان أقل → أرخص
>
> **Use Cases:**
> - Business Intelligence وReporting
> - تحليل VPC Flow Logs، ELB Logs، CloudTrail Logs من S3
> - Ad-hoc Queries على Data Lakes
>
> **Exam Tip من Stephane:** "Analyze data in S3 using serverless SQL" → **Athena**

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Athena
>
> - **Athena = Serverless SQL على S3.** ده الـ Keyword Combo في الـ Exam.
> - **بتدفع per TB scanned** — مش per Query ومش per Hour.
> - **Columnar Data (Parquet) = أرخص** لأنه بيسكان Data أقل.
> - **Athena لا تنقل Data من S3** — بتقرأ منه مباشرة.

---

### Amazon QuickSight

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics
>
> الـ **QuickSight** هو **Serverless ML-Powered BI (Business Intelligence) Service** لعمل **Interactive Dashboards**.
>
> - Fast، Auto-Scalable، Embeddable
> - **Per-Session Pricing**
> - متكامل مع: RDS، Aurora، Athena، Redshift، S3
>
> **Use Cases:**
> - Business Analytics
> - Data Visualizations (Charts، Graphs، Maps)
> - Ad-hoc Analysis
> - Business Insights من الـ Data

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — QuickSight
>
> - **QuickSight = BI Dashboards = Visualization.** مش Query Service.
> - الـ Pipeline الكامل: Data في S3 → Athena (Query) → QuickSight (Visualize).
> - **Serverless + Per-Session Pricing.**

---

### DocumentDB

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics
>
> الـ **DocumentDB** هو AWS Implementation لـ **MongoDB** — الـ Popular NoSQL Document Database.
>
> - زي ما Aurora هو AWS Implementation لـ PostgreSQL/MySQL
> - بيخزّن ويقدر يـ Query ويـ Index **JSON Data**
> - Fully Managed، Highly Available — Replication عبر **3 AZs**
> - Storage بتكبر تلقائياً بـ increments of 10 GB
> - Scales to Millions of Requests/Second

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — DocumentDB
>
> - **"MongoDB on AWS" = DocumentDB.** ده الـ Keyword المباشر.
> - **DocumentDB = NoSQL Document (JSON).** مش Relational.
> - زي Aurora في الـ Deployment Concepts (HA، Auto-scaling Storage).

---

### Amazon Neptune

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Neptune
>
> الـ **Neptune** هو Fully Managed **Graph Database** متخصص في تخزين والـ Query في **Highly Connected Datasets**.
>
> **الـ Graph Model:**
> - الـ Data مش Rows وColumns — هي **Nodes** (كيانات) وـ **Edges** (العلاقات بينهم)
> - مثال على Social Network: User A → "friend with" → User B. User B → "liked" → Post C.
>
> **Specs:**
> - Highly Available عبر 3 AZs
> - حتى 15 Read Replicas
> - يخزّن حتى **Billions of Relations**
> - بيـ Query الـ Graph بـ Millisecond Latency
>
> **Use Cases:**
> - **Social Networks** (Friends، Followers، Likes)
> - **Knowledge Graphs** (Wikipedia)
> - **Fraud Detection** (شبكات المعاملات المشبوهة)
> - **Recommendation Engines** ("الناس اللي اشتروا ده اشتروا كمان...")

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Neptune
>
> - **"Graph Database" = Neptune.** ده الـ Keyword. Social Networks، Fraud Detection، Recommendation Engines.
> - **Neptune ≠ Relational ≠ Key-Value.** هو Graph.

---

### الخدمات الباقية — Overview

#### Amazon Timestream:
- Fully Managed **Time-Series Database** — للـ Data المرتبطة بالوقت (IoT Sensors، Application Metrics، Financial Data)
- 1000x أسرع وأرخص بـ 1/10 من الـ Relational DBs للـ Time-Series Data
- Built-in Time-Series Analytics Functions
- **Keyword:** "time series data" أو "IoT metrics" → Timestream

#### Amazon Managed Blockchain:
- Managed Service لإنشاء Blockchain Networks
- بيدعم **Hyperledger Fabric** وـ **Ethereum**
- Multiple Parties يعملوا Transactions من غير Central Authority
- **Keyword:** "blockchain" أو "decentralized transactions" → Managed Blockchain

#### AWS Glue:
- Managed **ETL (Extract، Transform، Load) Service** — Fully Serverless
- بيحضّر ويحوّل Data للـ Analytics
- **Glue Data Catalog:** Catalog لكل الـ Datasets — بيستخدمه Athena وRedshift وEMR
- **الـ Pipeline:** S3/RDS → Glue (Extract + Transform) → Redshift (Load)
- **Keyword:** "ETL" أو "data preparation" أو "data catalog" → Glue

#### AWS DMS — Database Migration Service:
- بيهجّر الـ Databases لـ AWS بشكل سريع وآمن
- **الـ Source Database بتفضل شغّالة** أثناء الـ Migration (Zero Downtime)
- بيدعم:
  - **Homogeneous Migration:** Oracle → Oracle، MySQL → MySQL
  - **Heterogeneous Migration:** SQL Server → Aurora، Oracle → PostgreSQL
- **Keyword:** "migrate database to AWS" أو "zero downtime migration" → DMS

---

### Databases & Analytics — Section Summary

| Service | الـ Type | الـ Use Case | الـ Keyword |
|---|---|---|---|
| **RDS** | Managed SQL | OLTP — Traditional Apps | "managed relational", "SQL" |
| **Aurora** | AWS SQL | High Performance OLTP | "5x MySQL", "proprietary", "auto-grow storage" |
| **Aurora Serverless** | Serverless SQL | Variable/Unpredictable Workloads | "pay per second", "no capacity planning" |
| **ElastiCache** | In-Memory Cache | Reduce DB Load — Redis/Memcached | "cache", "in-memory", "reduce DB load" |
| **DynamoDB** | NoSQL Key-Value | Serverless، Massive Scale | "key-value", "serverless DB", "millisecond" |
| **DAX** | DynamoDB Cache | 10x DynamoDB Performance | "DynamoDB cache", "microseconds" |
| **Redshift** | Data Warehouse | OLAP — Analytics — PBs | "data warehouse", "OLAP", "columnar" |
| **EMR** | Hadoop Cluster | Big Data Processing | "Hadoop", "Spark", "MapReduce" |
| **Athena** | Serverless SQL on S3 | Query S3 Data | "serverless SQL", "analyze S3" |
| **QuickSight** | BI Dashboards | Visualization | "dashboards", "BI", "visualization" |
| **DocumentDB** | NoSQL Document | MongoDB Compatible | "MongoDB", "JSON documents" |
| **Neptune** | Graph DB | Social Networks, Fraud Detection | "graph", "relationships", "social network" |
| **Timestream** | Time-Series DB | IoT, Metrics, Financial Data | "time series", "IoT" |
| **Managed Blockchain** | Blockchain | Decentralized Transactions | "blockchain", "Hyperledger", "Ethereum" |
| **Glue** | ETL Service | Data Preparation for Analytics | "ETL", "data catalog", "transform" |
| **DMS** | DB Migration | Migrate DBs with Zero Downtime | "migrate database", "zero downtime" |

---

## 🧪 Grand Quiz — Sections 8 & 9 Final Checkpoint

> [!question]- 🧪 Grand Quiz Q1 — شركة عايزة تحلل VPC Flow Logs المخزّنة في S3 بـ Standard SQL Queries من غير أي Infrastructure Management. أنهي Service؟
>
> - A. Amazon Redshift
> - B. Amazon Athena
> - C. Amazon RDS
> - D. Amazon EMR

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — Amazon Athena**
> "SQL على S3" + "Serverless" + "No Infrastructure" = Athena. Redshift = Data Warehouse (تحتاج Load Data فيه). RDS = Managed Relational DB (مش لـ S3). EMR = Hadoop Clusters (مش Serverless).

---

> [!question]- 🧪 Grand Quiz Q2 — Application بيحتاج Database بيتحمّل Millions of RPS، NoSQL، Serverless، ومحتاج Response في Single-Digit Milliseconds. أنهي Service؟
>
> - A. Amazon RDS Aurora Serverless
> - B. Amazon DynamoDB
> - C. Amazon Redshift
> - D. Amazon ElastiCache

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — DynamoDB**
> "NoSQL" + "Serverless" + "Millions RPS" + "Single-Digit Milliseconds" = DynamoDB. Aurora Serverless هو SQL Relational. Redshift = OLAP Analytics. ElastiCache = Cache (مش Primary DB).

---

> [!question]- 🧪 Grand Quiz Q3 — شركة محتاجة تشيل Load عن الـ RDS Database اللي بيستقبل كتير Read Requests لنفس البيانات المتكررة. أنهي Service؟
>
> - A. RDS Read Replicas
> - B. Amazon ElastiCache
> - C. Amazon DynamoDB
> - D. Amazon S3

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — ElastiCache**
> "Reduce load off RDS" + "repeated read requests" + "in-memory" = ElastiCache. الـ Cache بيحتفظ بالـ Results المتكررة ويردها بدون رجوع للـ DB. Read Replicas بتساعد لكن مش بنفس كفاءة الـ In-Memory Cache للـ Repeated Identical Queries.

---

> [!question]- 🧪 Grand Quiz Q4 — شركة عندها On-Premise Oracle Database عايزة تهجّرها لـ Amazon Aurora PostgreSQL على AWS من غير ما تعطّل الـ Production Operations. أنهي Service؟
>
> - A. AWS Snowball
> - B. Amazon S3 Transfer Acceleration
> - C. AWS Database Migration Service (DMS)
> - D. AWS Glue

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — DMS**
> "Migrate database" + "source stays available" + "Heterogeneous Migration" (Oracle → Aurora PostgreSQL) = DMS. Snowball = Physical Data Migration مش DB Migration. S3 Transfer Acceleration = Upload سريع لـ S3. Glue = ETL للـ Analytics مش DB Migration.

---

> [!question]- 🧪 Grand Quiz Q5 — Startup عايزة تبني Recommendation Engine بيحلل العلاقات بين الـ Users والـ Products والـ Purchases بشكل ديناميكي. أنهي DB Type؟
>
> - A. Amazon RDS — Relational Database
> - B. Amazon DynamoDB — Key-Value NoSQL
> - C. Amazon Neptune — Graph Database
> - D. Amazon Redshift — Data Warehouse

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — Amazon Neptune**
> "Relationships between entities" + "recommendation engine" + "highly connected dataset" = Graph Database = Neptune. الـ Graph Model مثالي للـ "Users who bought X also bought Y" لأنه بيتتبع العلاقات بين الـ Nodes بكفاءة عالية. RDS = Tabular. DynamoDB = Key-Value. Redshift = Analytics/Reporting.

---

*القسم الجاي: **Other Compute Services — Lambda, ECS, EKS, Fargate, Batch, Lightsail.***
