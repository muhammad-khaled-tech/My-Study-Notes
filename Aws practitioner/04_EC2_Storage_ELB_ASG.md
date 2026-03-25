# 💾 EC2 Instance Storage + ⚖️ ELB & ASG
**AWS Certified Cloud Practitioner — CLF-C02**
*Elite Egyptian AWS Cloud Architect & Mentor | Stephane Maarek Slides v42 — Sections 6 & 7*

---

## 🗂️ Section 6 — EC2 Instance Storage

---

### EBS Volume — Elastic Block Store

#### 1. The Naive Approach (The Problem):

لو عندك EC2 Instance وعايز تحفظ بيانات على الـ Hard Disk — في عالم الـ Physical Servers، الـ Hard Disk كان مركّب جسدياً جوه الـ Server. لو الـ Server اتعطل، بياناتك مع الـ Server. لو عايز تنقل الـ Disk لـ Server تاني — Physical Migration معقدة. الـ EBS جاي يحل المشكلة دي بـ Virtual Disk مرن تقدر تفصله وتحطه على أي Instance تاني في نفس الـ AZ.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EBS Volume
>
> الـ **EBS (Elastic Block Store) Volume** هو **Network Drive** (مش Physical Disk مركّب جسدياً). بيتواصل مع الـ EC2 Instance عبر الـ AWS Internal Network. ده بيعني:
>
> **خصائص الـ EBS الجوهرية:**
>
> **① Network Drive — مش Physical:**
> بيستخدم الـ Network عشان يتكلم مع الـ Instance. ده بيعني في نانو ثوانٍ Latency إضافية مقارنة بالـ Physical Disk. لكن ممتاز في إنه تقدر تـ Detach من Instance وتـ Attach على Instance تاني في ثوانٍ من غير ما تمس الـ Hardware.
>
> **② Persistence — البيانات بتفضل:**
> حتى لو عملت Terminate للـ EC2 Instance، الـ EBS Volume ممكن يفضل موجود ويتـ Attach على Instance جديد. البيانات محفوظة. ده بيختلف جوهرياً عن الـ EC2 Instance Store.
>
> **③ AZ-Bound — مقيّد بالـ Availability Zone:**
> الـ EBS Volume في `us-east-1a` مش ممكن يتـ Attach مباشرة على Instance في `us-east-1b`. لو عايز تنقله — لازم تعمل **Snapshot** الأول، وتـ Restore من الـ Snapshot في الـ AZ التانية.
>
> **④ One Instance at a Time (at CCP Level):**
> الـ EBS Volume واحد بيتـ Attach على **Instance واحد بس** في نفس الوقت (في الـ CCP exam level). في الواقع في Feature اسمها EBS Multi-Attach لأنواع معينة (io1/io2) لكن ده فوق نطاق الـ CCP.
>
> **⑤ Provisioned Capacity:**
> بتحدد الـ Size (بالـ GBs) وعدد الـ IOPS وقت الإنشاء. بتدفع على الـ Provisioned Capacity كلها حتى لو الـ Volume فاضي. تقدر تزود الـ Size بمرور الوقت.
>
> **EBS Volume Types (Overview):**
> - **gp2/gp3 (SSD):** General Purpose — Balance بين Price وPerformance. الأكثر استخداماً.
> - **io1/io2 (SSD):** Provisioned IOPS — للـ High-Performance Databases اللي محتاجة IOPS عالي ومضمون.
> - **st1 (HDD):** Throughput Optimized — للـ Sequential Read/Write على Data كبيرة (Big Data, Data Warehouses).
> - **sc1 (HDD):** Cold HDD — الأرخص، للـ Infrequently Accessed Data.
>
> **Delete on Termination Attribute:**
> لما بتعمل EC2 Instance، كل EBS Volume بياخد Setting اسمه "Delete on Termination":
> - **Root Volume:** Delete on Termination = **Enabled by default** (بيتمسح مع الـ Instance)
> - **Additional Volumes:** Delete on Termination = **Disabled by default** (بيفضل موجود)
> تقدر تغير الـ Default من الـ Console أو AWS CLI. الـ Use Case: لو عايز تحافظ على الـ Root Volume بعد الـ Termination (مثلاً عشان تحقق في الـ Logs) — تعطّل الـ Attribute ده.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EBS زي **فلاشة USB الشبكة (Network USB Stick)** — وده بالظبط الـ Analogy اللي Stephane بيستخدمه.

تخيل عندك فلاشة شغّالة على الـ WiFi. تقدر توصّلها بأي كمبيوتر في نفس الـ مبنى (نفس الـ AZ). تقدر تفصلها من كمبيوتر وتحطها في كمبيوتر تاني. البيانات فيها بتفضل حتى لو الكمبيوتر اتكسر. لكن مش تقدر تستخدمها في مبنى تاني (AZ تانية) من غير ما تعمل نسخة منها (Snapshot) الأول.

الـ "Delete on Termination" زي لو قلت للكمبيوتر "لما تتخرب، اكسر الفلاشة معاك" (Enabled) أو "لما تتخرب، الفلاشة تفضل معايا" (Disabled).

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EBS Volume
>
> - **EBS = AZ-Specific.** مش ممكن تـ Attach EBS Volume في us-east-1a على Instance في us-east-1b مباشرة. لازم Snapshot ثم Restore.
> - **EBS = ONE Instance at a time** (at CCP level). لا تقول "متعدد" في الـ Exam.
> - **Stopped Instance لسه بتدفع على الـ EBS.** الـ Compute بيوقف، الـ Storage لأ.
> - **Root EBS بيتمسح by default عند الـ Termination.** الـ Additional Volumes بتفضل by default.
> - **EBS = Network Drive** — مش Physical Disk. ده بيعني فيه Latency لكن Detach/Attach سريع.
> - **بتدفع على الـ Provisioned Capacity** مش على الـ Used Capacity. لو عندك 100 GB EBS وبتستخدم 10 GB — بتدفع على الـ 100 GB كلها.

#### 5. The "Zatouna" Table:

| Characteristic | القيمة |
|---|---|
| **Type** | Network Drive (Virtual Block Storage) |
| **Persistence** | ✅ يفضل بعد Instance Stop/Terminate |
| **AZ Scope** | Locked to ONE Availability Zone |
| **Multi-Attach** | ❌ (One Instance at a time — CCP Level) |
| **Billing** | على الـ Provisioned Capacity |
| **Root Volume Default** | Delete on Termination = Enabled |
| **Additional Volume Default** | Delete on Termination = Disabled |
| **Cross-AZ Migration** | Snapshot → Restore in New AZ |
| **Analogy** | Network USB Stick |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q1
> **An EC2 instance in us-east-1a has a 50 GB EBS volume attached. The team wants to use this data on a new EC2 instance in us-east-1b. What is the CORRECT approach?**
>
> - A. Detach the EBS volume from the instance in us-east-1a and attach it directly to the instance in us-east-1b
> - B. Create a Snapshot of the EBS volume, then restore the Snapshot as a new EBS volume in us-east-1b
> - C. Enable EBS Multi-Attach to allow both instances to share the volume across AZs
> - D. Copy the EBS volume directly to us-east-1b using the AWS Console without snapshots

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> EBS volumes are locked to a specific Availability Zone. You **cannot** directly attach a volume from us-east-1a to an instance in us-east-1b. The correct workflow is: Create Snapshot of the volume (snapshot is stored in S3 and is Region-scoped, not AZ-scoped) → Restore the snapshot as a new EBS volume in us-east-1b → Attach the new volume to the instance.
>
> **Why A is wrong:** EBS is AZ-bound. Direct cross-AZ attachment is not possible.
> **Why C is wrong:** EBS Multi-Attach allows multiple instances to share the same volume, but it only works within the SAME AZ, and only for io1/io2 volume types. It does NOT work across AZs.
> **Why D is wrong:** There is no direct "copy EBS volume to another AZ" feature. Snapshots are the migration path.

---

### EBS Snapshots

#### 1. The Naive Approach (The Problem):

الـ EBS Volume مقيّد بالـ AZ. لو عايز تعمل Backup أو تنقل Data لـ AZ تانية أو Region تاني — محتاج آلية للـ Point-in-Time Copy. الـ EBS Snapshot ده الحل.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EBS Snapshots
>
> الـ **EBS Snapshot** هو **Incremental Backup** لحالة الـ EBS Volume في لحظة معينة. الـ Snapshot بيتخزّن في **Amazon S3** (internally) وبيبقى **Region-scoped** مش AZ-scoped — ده اللي بيسمح بنقل الـ Data بين الـ AZs والـ Regions.
>
> **Incremental Backup:**
> أول Snapshot بياخد الـ Full Volume. كل Snapshot بعده بيسجّل الـ Blocks اللي اتغيرت بس من الـ Snapshot الفاتت. ده بيوفر Storage وبيسرّع الـ Backup.
>
> **مش لازم Detach الـ Volume:**
> تقدر تعمل Snapshot وهو متـ Attached على الـ Instance، لكن Stephane **بيوصي** إنك توقف الـ Instance أو تعمل Detach لضمان الـ Data Consistency (عشان مفيش Write جارية وقت الـ Snapshot).
>
> **EBS Snapshot Features الإضافية:**
>
> **① EBS Snapshot Archive:**
> تقدر تنقل الـ Snapshot لـ "Archive Tier" أرخص بـ **75%** من الـ Standard Tier. المقايضة: Restore من الـ Archive بياخد من **24 لـ 72 ساعة** (مش Instant). مناسب للـ Snapshots اللي نادراً محتاجها.
>
> **② Recycle Bin for EBS Snapshots:**
> بدل ما الـ Snapshot يتمسح نهائياً على طول، تقدر تعمل Rules إن الـ Deleted Snapshots تفضل في الـ Recycle Bin لمدة تحددها (من 1 يوم لـ 1 سنة). لو احتجتها تاني — تقدر تسترجعها. Protection ضد الـ Accidental Deletion.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EBS Snapshot زي **صورة لكل حاجة على الـ Flash Drive** في لحظة بعينها. بتعمل "Ctrl+S" للـ Flash Drive كلها.

الـ Archive Tier زي إنك بتحط الصورة في **مخزن بعيد أرخص** — تقدر توصّله لكن بياخد يومين. الـ Recycle Bin زي **سلة المهملات** على الكمبيوتر — لما تحذف الصورة، بتروح السلة الأول مش ترمى على طول.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Snapshots
>
> - **Snapshot = Region-scoped (not AZ-scoped).** بعد ما تعمل الـ Snapshot، تقدر تـ Restore في أي AZ في نفس الـ Region، أو تـ Copy لـ Region تانية.
> - **Snapshot Archive = 75% Cheaper لكن 24-72 ساعة Restore Time.** لو الـ Exam سأل عن "cost-effective snapshot storage for rarely accessed backups" → Archive Tier.
> - **Recycle Bin = Protection من Accidental Deletion.** Retention من 1 يوم لـ 1 سنة.
> - **Snapshot = Incremental** — مش Full Backup في كل مرة.

#### 5. The "Zatouna" Table:

| Feature | التفاصيل |
|---|---|
| **Scope** | Region-level (بيتخزّن في S3) |
| **Type** | Incremental Backup |
| **Detach Required?** | لا — بس Recommended لـ Consistency |
| **Cross-AZ Migration** | Snapshot → Restore in New AZ ✅ |
| **Cross-Region Copy** | ✅ ممكن (Copy Snapshot to Another Region) |
| **Archive Tier** | 75% أرخص — Restore: 24-72 ساعة |
| **Recycle Bin** | Retention: 1 day → 1 year |

---

### AMI — Amazon Machine Image

#### 1. The Naive Approach (The Problem):

كل ما بتعمل EC2 Instance جديد، محتاج تثبّت الـ OS، تركّب الـ Software، تعمل الـ Configuration — ده بياخد وقت. لو عندك 50 Instance محتاجين نفس الـ Setup — 50 مرة نفس الـ Process. الـ AMI بيحل ده — بيخليك تعمل "صورة" للـ Instance بعد ما جهّزته، وتستخدمها لتشغيل Instances جديدة جاهزة فوراً.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — AMI Deep Dive
>
> الـ **AMI (Amazon Machine Image)** هو **Template** (قالب) جاهز بيحتوي على:
> - الـ Operating System
> - الـ Pre-installed Software والـ Configuration
> - الـ EBS Snapshots للـ Root Volume (وأي Volumes تانية)
> - الـ Launch Permissions (مين يقدر يستخدم الـ AMI دي)
>
> **الـ 3 أنواع من الـ AMIs:**
>
> **① Public AMI (AWS-Provided):**
> AWS بتوفر AMIs جاهزة وبتصونها — زي Amazon Linux 2، Ubuntu، Windows Server، إلخ. دي الأكثر استخداماً للـ Standard Deployments.
>
> **② Custom AMI (Self-Created):**
> إنت بتعمل EC2 Instance، بتجهّزه زي ما تحب (تثبّت Apache، Node.js، أي حاجة)، بتعمل Stop، بتعمل Create Image — والـ AMI الجديد بيحتوي على كل الـ Customizations بتاعتك. بعدين تقدر تـ Launch Instances جديدة من الـ AMI ده في ثوانٍ من غير أي Manual Setup.
>
> **③ AWS Marketplace AMI:**
> AMIs معمولة من Third-Party Vendors وبتُباع على الـ Marketplace. مثلاً Instance جاهز بـ Nginx + SSL + Monitoring مركّب ومجهّز من شركة متخصصة.
>
> **AMI Process (الخطوات):**
> 1. **Start EC2 Instance** — لنفترض Instance عليه Amazon Linux 2
> 2. **Customize It** — ثبّت Apache، Node.js، أي Software محتاجه
> 3. **Stop the Instance** — لضمان Data Integrity
> 4. **Build AMI** — AWS بتعمل EBS Snapshot للـ Root Volume وبتسجّل كل الـ Configuration
> 5. **Launch New Instances from AMI** — في أي AZ في نفس الـ Region (أو Copy لـ Region تانية)
>
> **AMI = Region-Specific:**
> الـ AMIs بتتبنى في Region معينة. لو عايز تستخدمها في Region تانية — بتـ Copy الـ AMI.
>
> **Faster Boot Time:**
> لأن كل الـ Software محمّل مسبقاً في الـ AMI، الـ Instance الجديد بيبوت أسرع بكتير من Instance بيشغّل User Data Script لتثبيت كل حاجة.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ AMI زي **Master Stamp (قالب الختم)** في المصنع. بدل ما كل Worker يعمل العملة (Instance) من الصفر — بيبدأ من شمع ويقولب — الـ Master Stamp بيطبع آلاف العملات المتطابقة في ثوانٍ.

إنت بتعمل Instance واحد وبتجهّزه يدوياً (ده الـ Master) — بعدين بتعمله AMI. الـ AMI ده هو الـ Master Stamp. كل Instance جديد بتعمله من الـ AMI ده بييجي جاهز ومتطابق تماماً مع الـ Master من غير أي عمل إضافي.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — AMI
>
> - **AMI = Region-Specific.** مش Global. لو عايزها في Region تانية — Copy.
> - **AMI بيحتوي على EBS Snapshots.** لما بتعمل AMI من Instance، AWS بتعمل Snapshots لكل الـ EBS Volumes المرتبطة تلقائياً.
> - **Custom AMI = Faster Boot + Pre-configured.** ده الـ Use Case الرئيسي — لو الـ Exam قال "need to launch pre-configured instances quickly" → Custom AMI.
> - **AMI Launch Permissions:** AMI ممكن تكون Public أو Private أو Shared مع Accounts بعينها.

#### 5. The "Zatouna" Table:

| AMI Type | من بيعملها | الـ Use Case |
|---|---|---|
| **Public (AWS)** | AWS | Standard OS — Amazon Linux, Ubuntu, Windows |
| **Custom** | إنت | Pre-configured Application Instances |
| **Marketplace** | Third Parties | Commercial Software Stacks |
| **Scope** | Region-Specific | بتـ Copy للـ Regions التانية |
| **يحتوي على** | EBS Snapshots + Config | — |
| **ميزة** | Faster Boot، Zero Manual Setup | — |

---

### EC2 Image Builder

#### 1. The Naive Approach (The Problem):

عمل AMI يدوياً (Launch → Configure → Stop → Build) بيستهلك وقت وجهد. لو الـ AMI محتاج تحديث دوري (OS Security Patches، Software Updates) — الـ Process اليدوية مؤلمة. الـ EC2 Image Builder بيأتمت الـ Pipeline كلها.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EC2 Image Builder
>
> الـ **EC2 Image Builder** هو **Managed Service** بيأتمت كل خطوة في الـ AMI Creation Pipeline:
>
> **الـ Pipeline:**
> ```
> EC2 Image Builder Service
>         ↓ (create)
> Builder EC2 Instance
>         ↓ (applies Build Components — installs/configures software)
>         ↓ (create)
>       New AMI
>         ↓ (create)
> Test EC2 Instance
>         ↓ (runs Test Suite — is the AMI working? is it secure?)
>         ↓ (distribute)
> AMI Distributed (can be multiple regions)
> ```
>
> **خصائص مهمة:**
> - **Scheduled Runs:** ممكن تشغّله على Schedule — كل أسبوع، أو كلما اتنزّلت Package Updates
> - **Free Service:** الـ Service نفسها مجانية — بتدفع على الـ Underlying Resources (الـ EC2 Instances اللي بتتنشأ أثناء الـ Build وTest)
> - **Automated Testing:** بيشغّل Test Suite على الـ AMI الجديدة قبل الـ Distribution — بيضمن إن الـ AMI شغّالة وآمنة
> - **Multi-Region Distribution:** بيوزّع الـ AMI على Regions متعددة تلقائياً بعد النجاح

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EC2 Image Builder زي **خط إنتاج أوتوماتيكي** في مصنع العملات بتاعنا. بدل ما إنت تعمل الـ Master Stamp يدوياً كل أسبوع — في روبوت بيعمله بدلك كل يوم اثنين الصبح، يعمله QC Tests، ولو عدى الـ Test بيبعته لكل الفروع (Regions) تلقائياً.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EC2 Image Builder
>
> - **EC2 Image Builder = Free Service** — بس بتدفع على الـ EC2 Instances اللي بتتنشأ أثناء الـ Build/Test.
> - **الـ Use Case الرئيسي:** Automate creation, maintenance, validation, and testing of AMIs.
> - **بيشغّل Test Suite** على كل AMI قبل ما تتوزّع — ده بيضمن الـ Quality.
> - مش بتُشغّل EC2 Image Builder يدوياً كل مرة — بيشتغل على **Schedule** أو **Event-based**.

#### 5. The "Zatouna" Table:

| Characteristic | القيمة |
|---|---|
| **Type** | Managed Service |
| **Cost** | Free (تدفع على الـ EC2 Resources فقط) |
| **Purpose** | Automate AMI Creation + Testing + Distribution |
| **Scheduling** | Weekly / On Package Update / Manual Trigger |
| **Testing** | Automated Test Suite على كل AMI جديدة |
| **Distribution** | Multi-Region بعد نجاح الـ Tests |

---

### EC2 Instance Store

#### 1. The Naive Approach (The Problem):

الـ EBS عالي الأداء لكن هو Network Drive — وده بيضيف Latency. في بعض الـ Use Cases زي الـ High-Frequency Databases أو الـ Video Processing — محتاج أداء Storage أسرع من أي Network Latency. الـ EC2 Instance Store هو الحل — لكن بثمن.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EC2 Instance Store
>
> الـ **EC2 Instance Store** هو **Physical NVMe SSD** مركّب مباشرةً على الـ Physical Host اللي الـ EC2 Instance شغّال عليه. مفيش Network في المعادلة — الـ Disk موجود على نفس الـ Hardware.
>
> **المزايا:**
> - **Very High IOPS** — بيوصل لـ Millions of IOPS (أعلى بكتير من أي EBS Type)
> - **Very Low Latency** — مش في Network Latency، الـ Data قريب جداً
> - **High Throughput** — مناسب للـ Sequential Read/Write الضخمة
>
> **العيب الجوهري — Ephemeral Storage:**
> الـ Data على الـ Instance Store **بتتمسح نهائياً** في الحالات دي:
> - الـ Instance تعمل **Stop**
> - الـ Instance تعمل **Terminate**
> - الـ Physical Hardware اللي الـ Instance شغّال عليه **فشل (Hardware Failure)**
>
> **الـ Use Cases الصح:**
> - **Buffer/Cache:** بيانات مؤقتة للـ Application
> - **Scratch Data:** بيانات حسابات مؤقتة
> - **Temporary Content:** أي حاجة مش محتاج تفضل موجودة
>
> **Backup مسؤوليتك:**
> AWS مش بتعمل Backup للـ Instance Store. لو حابب تحتفظ بالبيانات — مسؤوليتك إنك تعمل Backup يدوي لـ S3 أو EBS.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EC2 Instance Store زي **الـ RAM بتاعت الكمبيوتر** — أسرع حاجة موجودة، لكن لما بتقفّل الكمبيوتر، بيطير كل حاجة. الـ EBS زي الـ Hard Disk — أبطأ شوية، لكن بياناتك بتفضل حتى لو الكمبيوتر اتقفّل.

استخدم الـ Instance Store لما عندك حسابات Intensive ومؤقتة — زي إنك بتعمل Video Encoding ومحتاج Buffer سريع جداً. لكن اللي يطلع من الـ Buffer ده (الـ Final Video) — ابعته على EBS أو S3 على طول.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EC2 Instance Store
>
> - **Instance Store = Ephemeral = Data Loss on Stop/Terminate.** ده الـ Trap الأساسي. لو الـ Question قال "need high performance storage" AND "data must persist" → **EBS، مش Instance Store**.
> - **"High Performance" + "Temporary/Cache/Buffer" → Instance Store** هو الإجابة.
> - **Backup = Customer Responsibility.** AWS مش بتعمل Backup للـ Instance Store.
> - **Hardware Failure → Data Loss.** مش بس الـ Stop أو Terminate — حتى لو الـ Physical Host فشل، البيانات بتتمسح.

#### 5. The "Zatouna" Table:

| Characteristic | القيمة |
|---|---|
| **Type** | Physical NVMe SSD (على الـ Physical Host) |
| **Performance** | Highest IOPS — Millions/sec |
| **Latency** | Lowest (No Network) |
| **Persistence** | ❌ Ephemeral — بيتمسح عند Stop/Terminate/HW Failure |
| **Use Cases** | Buffer, Cache, Scratch, Temp Data |
| **Backup** | Customer's Responsibility |
| **الـ Trade-off** | Speed مقابل Durability |

---

### EFS — Elastic File System

#### 1. The Naive Approach (The Problem):

الـ EBS Volume واحد بيتـ Attach على Instance واحد في AZ واحدة. لو عندك 100 EC2 Instance في AZs مختلفة محتاجين يوصلوا لنفس الـ Files؟ EBS مش مناسب هنا. محتاج **Shared File System** — وده اللي EFS بيعمله.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EFS
>
> الـ **EFS (Elastic File System)** هو **Managed NFS (Network File System)** — يعني File System بيشتغل على الـ Network ومشترك بين Instances متعددة.
>
> **الخصائص الجوهرية:**
>
> **① Multi-AZ & Multi-Instance:**
> تقدر توصّل مئات الـ EC2 Instances من AZs مختلفة على نفس الـ EFS في نفس الوقت. كل Instance بيشوف نفس الـ Files. ده ممكن بـ Mount Targets — كل AZ بيكون فيها Mount Target خاص بها.
>
> **② Linux Only (at CCP Level):**
> الـ EFS بيشتغل مع الـ Linux EC2 Instances. مش بيدعم Windows نفسه (لـ Windows في FSx for Windows).
>
> **③ Highly Available & Scalable:**
> الـ EFS Highly Available out of the box — بيتوزّع على Multiple AZs تلقائياً. والـ Storage بيكبر تلقائياً مع البيانات — مفيش Provisioning مسبق.
>
> **④ Pay Per Use — No Capacity Planning:**
> بتدفع على الـ GB المستخدم فعلاً. مش بتـ Provision Size زي الـ EBS.
>
> **⑤ Expensive — 3x gp2 EBS:**
> الـ EFS أغلى من الـ EBS gp2 بحوالي 3 أضعاف لكن بيوفر Shared Access وAuto-Scaling.
>
> **EFS-IA (Infrequent Access):**
> Storage Class متخصصة للـ Files اللي مش بتتوصّل بشكل يومي. أرخص بـ **92%** من الـ Standard EFS. الـ EFS بيـ Move الـ Files تلقائياً لـ EFS-IA بناءً على **Lifecycle Policy** (مثلاً: لو الـ File ما اتوصّلش 60 يوم → ينتقل لـ EFS-IA). الـ Applications مش حاسة بالفرق — الـ Access Transparent.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EFS زي **Server Room مشترك** في عمارة الشركة. كل الموظفين (EC2 Instances) في كل الأدوار (AZs) يقدروا يوصلوا لنفس الـ Server Room ويشوفوا نفس الملفات في نفس الوقت. الـ EBS زي إن كل موظف عنده فلاشة شخصية — مش ممكن يشاركها مع التاني.

الـ EFS-IA زي **الأرشيف** في آخر الـ Server Room — الملفات اللي ما فيش حد فتحها من شهرين بتانتقل للأرشيف تلقائياً بسعر أرخص. لو فتحتها — بترجع من الأرشيف بشكل تلقائي من غير ما تحس.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EFS
>
> - **EFS = Shared File System = Multi-Instance, Multi-AZ.** ده الـ Key Differentiator عن الـ EBS.
> - **EFS = Linux Only** (out of the box). لـ Windows → **FSx for Windows File Server**.
> - **EFS = Pay Per Use.** مش بتـ Provision Size زي EBS.
> - **EFS = 3x More Expensive than EBS gp2** لكن بيوفر Shared Access.
> - **EFS-IA = 92% Cheaper** للـ Infrequently Accessed Files.
> - **EBS vs EFS:** EBS = One Instance/One AZ. EFS = Many Instances/Many AZs.

#### 5. The "Zatouna" Table:

| Characteristic | EBS | EFS |
|---|---|---|
| **Instances** | 1 | Hundreds |
| **AZ Scope** | Single AZ | Multi-AZ |
| **OS** | Linux + Windows | Linux only |
| **Capacity** | Provisioned (fixed) | Auto-scales |
| **Billing** | Provisioned size | Per GB used |
| **Cost vs EBS gp2** | Baseline | 3x أغلى |
| **EFS-IA Saving** | N/A | 92% للـ Infrequent Files |

---

### Amazon FSx

#### 1. The Naive Approach (The Problem):

الـ EFS ممتاز لـ Linux. لكن لو عندك Windows Servers تحتاج Shared File System؟ أو HPC Cluster يحتاج Storage بالـ GB/s؟ محتاج Specialized File Systems — وده اللي الـ FSx بيوفره كـ Fully Managed Service.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Amazon FSx
>
> الـ **Amazon FSx** بيتيح لك تشغّل **High-Performance Third-Party File Systems** على AWS بشكل Fully Managed. بدل ما تثبّت وتصون الـ File System بنفسك على EC2 — AWS بتعمل ده بدلك.
>
> **FSx for Windows File Server:**
> - **Fully Managed** Windows Native File System
> - بيستخدم **SMB Protocol** (Server Message Block) — نفس الـ Protocol اللي Windows بيستخدمه للـ File Sharing
> - بيدعم **Windows NTFS** بالكامل
> - Integrated مع **Microsoft Active Directory** — يعني الـ Users والـ Groups من الـ AD بيتطبقوا على الـ File Permissions
> - يوصّله Instances من داخل الـ AWS **وكمان من On-Premise** عبر SMB
> - **الـ Use Case:** أي Windows Application محتاجة Shared File System (SQL Server Shared Storage، Windows Home Directories، إلخ)
>
> **FSx for Lustre:**
> - Lustre = اسم مركّب من **"Linux"** + **"Cluster"**
> - **Fully Managed High-Performance File System** للـ HPC (High-Performance Computing)
> - Scales لـ **100s of GB/s** Throughput، **Millions of IOPS**، **Sub-millisecond Latency**
> - بيتكامل مع **Amazon S3** — تقدر تقرأ Data مباشرة من S3 عبر FSx for Lustre وتكتب النتايج عليه
> - **الـ Use Cases:** Machine Learning، Big Data Analytics، Video Processing، Financial Modeling، Scientific Simulations
>
> **FSx for NetApp ONTAP:**
> - Managed NetApp ONTAP — Enterprise-grade file storage لأي OS (Linux, Windows, macOS)
> - ممتاز للـ Migration من On-Premise NetApp environments

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ FSx زي إنك **استأجرت متخصص** بدل ما تعمل الشغل بنفسك:

**FSx for Windows** = متخصص Windows File Sharing جاهز — بيتكلم SMB بطلاقة ومتصل بالـ Active Directory. الـ Windows Servers بتتكلم معه كأنه File Server عادي.

**FSx for Lustre** = محرك فورمولا 1 للـ Storage — مصمم خصيصاً للـ Scientists والـ ML Engineers اللي عندهم Datasets بالـ Terabytes ومحتاجين يقروها بسرعة مجنونة.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — FSx
>
> - **Windows Shared File System → FSx for Windows File Server** (مش EFS — اللي هو Linux only).
> - **HPC + Machine Learning + Sub-ms Latency → FSx for Lustre**.
> - **FSx for Lustre = S3 Integration** — تقدر تقرأ Data من S3 مباشرة عبر Lustre.
> - الـ "Lustre" name = Linux + Cluster.

#### 5. The "Zatouna" Table:

| FSx Type | الـ Protocol | الـ Use Case | ملاحظة |
|---|---|---|---|
| **FSx for Windows** | SMB / NTFS | Windows Shared FS, AD Integration | مش Linux |
| **FSx for Lustre** | POSIX / Lustre | HPC, ML, Big Data, Video Processing | S3 Integration |
| **FSx for NetApp ONTAP** | Multi-Protocol | Enterprise Migration from NetApp | — |

---

### Shared Responsibility Model for EC2 Storage

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics
>
> **AWS مسؤولة عن:**
> - Infrastructure (Physical Storage Hardware)
> - Replication for EBS Volumes & EFS (AWS بتعمل Internal Replication لضمان Durability)
> - Replacing Faulty Hardware
> - ضمان إن Employees بتاعت AWS مش يوصلوا لبياناتك
>
> **الـ Customer مسؤول عن:**
> - Setting up Backup/Snapshot Procedures (إنت بتقرر متى وكيف تعمل Snapshots)
> - Setting up Data Encryption (ما في إجبار من AWS — إنت بتختار تشفّر أو لأ)
> - Responsibility of any Data on the Drives (محتوى البيانات مسؤوليتك)
> - **Understanding the Risk of using EC2 Instance Store** — لو اخترت Instance Store وفقدت بياناتك بسبب Hardware Failure، ده كان Risk قبلته إنت

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Storage Shared Responsibility
>
> - **EBS Snapshots = Customer's Responsibility** to CREATE them. AWS بتوفر الـ Tool، إنت بتستخدمه.
> - **Data Encryption = Customer's Choice.** AWS بتوفر KMS Integration مع EBS — لكن تفعيله مسؤوليتك.
> - **AWS بتعمل Internal Replication** للـ EBS وEFS عشان تضمن الـ Durability — لكن ده مش Backup قابل للـ Restore في الـ Disaster Recovery.

---

### EC2 Instance Storage — Section Summary

| Service | الـ Type | الـ Persistence | الـ Scope | الـ Use Case |
|---|---|---|---|---|
| **EBS** | Network Block Storage | ✅ Persistent | Single AZ | Boot Volume, Single-Instance Storage |
| **EBS Snapshot** | Backup of EBS | ✅ In S3 | Region | Backup, Cross-AZ Migration |
| **AMI** | EC2 Template | ✅ In S3 | Region | Fast Launch, Pre-configured Instances |
| **EC2 Image Builder** | AMI Pipeline | N/A | Regional | Automate AMI Build/Test/Distribute |
| **EC2 Instance Store** | Physical NVMe SSD | ❌ Ephemeral | On Physical Host | Buffer, Cache, Temp Data |
| **EFS** | Shared NFS | ✅ Persistent | Multi-AZ | Shared Linux File System |
| **EFS-IA** | EFS Cold Tier | ✅ Persistent | Multi-AZ | Infrequent Access Files (92% cheaper) |
| **FSx for Windows** | Managed Windows FS | ✅ Persistent | Multi-AZ | Windows SMB, Active Directory |
| **FSx for Lustre** | Managed HPC FS | ✅ Persistent | Single AZ | HPC, ML, Big Data |

---

---

## ⚖️ Section 7 — Elastic Load Balancing & Auto Scaling Groups

---

### Scalability & High Availability — المفاهيم الجوهرية

#### 1. The Naive Approach (The Problem):

في الـ On-Premise world، لو الـ Traffic على الـ Application زاد 10x فجأة — الـ Server بيتعطل. الحل القديم كان تشتري Servers أقوى وأضخم وتستنى. وكمان لو الـ Data Center اللي الـ Server فيه غرق أو اتحرق — الـ Application بيوقف خالص. Cloud بيحل المشكلتين: الـ Scalability (التعامل مع الـ Load) والـ High Availability (الاستمرارية).

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Scalability vs HA vs Elasticity vs Agility
>
> **① Vertical Scalability (Scale Up / Scale Down):**
> بتزود حجم الـ Instance نفسه. Application شغّال على `t2.micro` → بتحوّله لـ `t2.large` أو `t2.xlarge`. ده زي إنك تستبدل الموظف الـ Junior بـ Senior أقوى منه.
>
> **الحدود:** في Upper Limit لحجم الـ Instance — مش ممكن تعمل Instance بـ RAM أكتر من الـ Hardware المتاح في الـ Data Center. الـ `u-12tb1.metal` هو الأكبر (12.3 TB RAM, 448 vCPUs) — وده حد طبيعي.
>
> **متى تستخدمه:** Non-Distributed Systems زي الـ Databases اللي بتشتغل على Instance واحد.
>
> **② Horizontal Scalability (Scale Out / Scale In):**
> بتزود عدد الـ Instances (Scale Out) أو بتنقّص عددها (Scale In). Application شغّال على Instance واحد → بتشغّل 5 Instances بنفس الـ Application.
>
> ده بيفترض إن الـ Application **Distributed** — يعني أكتر من نسخة منه تقدر تشتغل مع بعض بدون مشاكل. معظم الـ Modern Web Applications مصممة هكذا.
>
> **متى تستخدمه:** Web Applications، APIs، Stateless Services.
>
> **③ High Availability (HA):**
> بيعني إن الـ Application شغّال على الأقل في **Availability Zone (AZ) واحدة** أو أكتر. الـ Goal هو **Survive Data Center Loss** — لو AZ واحدة اتعطلت، الـ Application فاضل شغّال من الـ AZ التانية.
>
> HA دايماً مصاحبة للـ Horizontal Scaling في الـ Cloud.
>
> **④ Scalability vs Elasticity vs Agility:**
>
> | المفهوم | التعريف |
> |---|---|
> | **Scalability** | القدرة على استيعاب Load أعلى — إما بـ Vertical (قوة أكتر) أو Horizontal (عدد أكتر) |
> | **Elasticity** | الـ System يـ Auto-Scale تلقائياً بناءً على الـ Load — بيكبر لما الـ Demand يكبر، وبينقص لما الـ Demand ينقص |
> | **Agility** | (مش مرتبط بالـ Scalability مباشرة) — سرعة إتاحة الـ IT Resources. من أسابيع (On-Premise) لدقائق (Cloud) |

#### 3. The Mentor's Story (The "Ashta" Analogy):

Stephane بيستخدم **Call Center** كـ Analogy:

**Vertical Scaling:** بدل ما تشغّل Operator Junior بيرد على 10 calls/hour — تشغّل Senior Operator بيرد على 100 calls/hour. ده Scale Up. الحد إنه مش ممكن يرد على 1000 call في نفس الوقت مهما كان شاطر.

**Horizontal Scaling:** بدل Operator واحد — تشغّل 100 Operator في نفس الوقت. كل واحد يرد على Call. ده Scale Out. مش في حد أعلى تقريباً — بتضيف Operators على حسب الـ Load.

**High Availability:** بدل ما الـ Call Center كله في مبنى واحد في القاهرة — عندك مبنى تاني في الإسكندرية. لو مبنى القاهرة غرق في الفيضان — المبنى التاني فاضل شغّال.

**Elasticity:** الـ Call Center بتحس بـ Load تلقائياً وبتشغّل Operators زيادة في الـ Peak وبتقفّل بعضهم في الـ Off-Peak عشان توفر فلوس.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Scalability Concepts
>
> - **Agility ≠ Scalability.** الـ Exam بيحط Agility كـ Distractor. Agility هو سرعة الـ Provisioning — مش الـ Scaling نفسه.
> - **Scale Up = Vertical. Scale Out = Horizontal.** الـ Terms دول Fixed في الـ Exam.
> - **High Availability = Multi-AZ.** مش بس Backup — ده Running Application في AZs متعددة في نفس الوقت.
> - **Elasticity = Auto-Scaling** (تلقائي). Scalability = القدرة على الـ Scaling (مش بالضرورة تلقائي).
> - **Vertical Scaling = Hardware Limit موجود.** Horizontal Scaling = مفيش Limit تقريباً.

#### 5. The "Zatouna" Table:

| Concept | المعنى | الـ AWS Tool |
|---|---|---|
| **Vertical Scale Up** | Instance أكبر | Change Instance Type |
| **Horizontal Scale Out** | Instances أكتر | Auto Scaling Group |
| **Horizontal Scale In** | Instances أقل | Auto Scaling Group |
| **High Availability** | Multi-AZ Deployment | ELB + ASG Multi-AZ |
| **Elasticity** | Auto-Scale بالـ Load | Auto Scaling Group |
| **Agility** | سرعة Provisioning | Cloud في حد ذاته |

---

### Elastic Load Balancer (ELB)

#### 1. The Naive Approach (The Problem):

عندك 5 EC2 Instances بيشغّلوا نفس الـ Web Application. مين اللي بيوزّع الـ Users على الـ 5 Instances؟ لو User 1 دايماً بيروح Instance 1 وInstance 2 فارغ — الموازنة مش شغّالة. محتاج **Load Balancer** يقف في الوسط، يستقبل كل الـ Traffic، ويوزّعه على الـ Instances بشكل ذكي.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — ELB Deep Dive
>
> الـ **Load Balancer** هو Server/Service بيستقبل كل الـ Incoming Traffic ويوزّعه على الـ Backend Instances (Downstream Servers). بدل ما User يتكلم مع Instance معين مباشرة — بيتكلم مع الـ Load Balancer، والـ Load Balancer هو اللي يقرر مين الـ Instance اللي يرد.
>
> **ليه Load Balancer؟**
> - **Spread Load:** توزيع الـ Traffic على Multiple Instances عشان ما يحصلش Overload
> - **Single Point of Access (DNS):** بدل ما تدي الـ Users عناوين 5 Instances — بتديهم عنوان واحد للـ Load Balancer
> - **Health Checks:** بيراقب الـ Instances باستمرار، ولو Instance وقع — بيبطل يبعتله Traffic تلقائياً
> - **SSL Termination:** الـ HTTPS بيتفكّك عند الـ Load Balancer — الـ Internal Traffic ممكن يكون HTTP عادي (أبسط وأقل Overhead)
> - **High Availability:** بيتوزّع على Multiple AZs تلقائياً
>
> **الـ ELB = Managed Service:**
> الـ ELB (Elastic Load Balancer) هو الـ Load Balancer المُدار من AWS. يعني:
> - AWS بتضمن إنه شغّال دايماً
> - AWS بتعمل الـ Upgrades والـ Maintenance
> - AWS بتوفر الـ HA تلقائياً
>
> **4 أنواع من الـ ELB:**
>
> **① Application Load Balancer (ALB) — Layer 7:**
> - بيشتغل على الـ **Application Layer (HTTP/HTTPS/gRPC)**
> - يقدر يـ Route الـ Traffic بناءً على الـ **URL Path** (`/api` لـ Servers مختلفة عن `/web`)
> - يقدر يـ Route بناءً على الـ **Host Header** (domain.com vs api.domain.com)
> - يقدر يـ Route بناءً على الـ **Query Strings والـ Headers**
> - **Static DNS (URL)** — عنوان DNS ثابت
> - **الـ Use Case:** Modern Web Applications، Microservices، Container-based Apps
>
> **② Network Load Balancer (NLB) — Layer 4:**
> - بيشتغل على الـ **Transport Layer (TCP/UDP/TLS)**
> - **Ultra-High Performance:** بيستحمل Millions of Requests per Second
> - **Static IP through Elastic IP** — ممكن تدي الـ NLB IP ثابت (مش بس DNS)
> - Latency أقل بكتير من ALB (~100ms vs ~400ms)
> - **الـ Use Case:** Gaming (محتاج TCP/UDP بـ Ultra-Low Latency)، Financial Trading، Real-time Streaming
>
> **③ Gateway Load Balancer (GWLB) — Layer 3:**
> - بيشتغل على الـ **Network Layer (IP Packets) — GENEVE Protocol**
> - **الـ Purpose الرئيسي:** توجيه الـ Traffic عبر Third-Party Security Appliances (Firewalls، IDS/IPS، Deep Packet Inspection) قبل ما يوصل للـ Application
> - الـ Traffic بيمشي: Users → GWLB → Security Virtual Appliances على EC2 → Application
> - **الـ Use Case:** Intrusion Detection، Network Traffic Inspection، Compliance Requirements
>
> **④ Classic Load Balancer (CLB) — Layer 4 & 7:**
> - الجيل الأول من الـ ELBs
> - **Retired in 2023** — مش بتنشأ CLBs جديدة
> - الـ Exam ممكن يذكره كخيار غلط أو Legacy

#### 3. The Mentor's Story (The "Ashta" Analogy):

تخيل **مطعم كبير** فيه 5 Chefs (EC2 Instances) في المطبخ. الـ Load Balancer هو **الـ Maître d'** (المشرف على الاستقبال) — الـ Customers مش بيدخلوا المطبخ مباشرة. بيقولوا للـ Maître d' "عايزين Order"، وهو بيوزّع الـ Orders على الـ Chefs اللي فاضيين.

**الـ ALB** زي Maître d' ذكي — بيعرف يـ Route حسب نوع الأكل: "طلبات الـ Grills روحوا Chef Ahmed"، "طلبات الـ Sushi روحوا Chef Kenji". بيقرأ الـ Request ويفهمه.

**الـ NLB** زي Maître d' سريع جداً ـ مش بيقرأ الـ Order بالتفاصيل، بس بيوزّع الـ Customers بسرعة البرق. مناسب لما في ملايين الـ Orders في الثانية.

**الـ GWLB** زي إن الـ Order لازم يعدي **مراقبة الجودة (Security Scanner)** قبل ما يوصل للـ Kitchen. الـ GWLB هو الـ Checkpoint ده.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — ELB Types
>
> - **ALB = Layer 7 = HTTP/HTTPS/gRPC.** لما الـ Exam يقول "route based on URL path" أو "microservices routing" → **ALB**.
> - **NLB = Layer 4 = TCP/UDP = Ultra-High Performance.** لما الـ Exam يقول "millions of requests per second" أو "static IP for load balancer" أو "gaming/financial" → **NLB**.
> - **GWLB = Layer 3 = Security Appliances / Intrusion Detection.** ده الأقل شيوعاً في الـ Exam لكن الـ Use Case مميز.
> - **CLB = Retired 2023 = Legacy.** لو ظهر في الـ Exam كـ Option، هو غالباً الإجابة الغلطة.
> - **ELB = Managed Service** — AWS بتعمل كل الـ Maintenance. مش لازم تهتم بالـ Upgrades.
> - **Health Checks:** ELB بيعمل Health Checks على الـ Instances تلقائياً ومش بيبعت Traffic لـ Unhealthy Instances.
> - **Static IP:** ALB مش بيدي Static IP (بيدي DNS). NLB بيدي Static IP عبر Elastic IP.

#### 5. The "Zatouna" Table:

| ELB Type | Layer | Protocol | الـ Use Case | Static IP? |
|---|---|---|---|---|
| **ALB** | 7 (Application) | HTTP/HTTPS/gRPC | Web Apps, Microservices, URL Routing | ❌ (DNS فقط) |
| **NLB** | 4 (Transport) | TCP/UDP/TLS | High Performance, Gaming, Financial | ✅ (Elastic IP) |
| **GWLB** | 3 (Network) | GENEVE/IP | Security Appliances, Firewalls, IDS | ❌ |
| **CLB** | 4 & 7 | HTTP/TCP | Legacy — Retired 2023 | ❌ |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q2
> **A financial trading platform needs a load balancer that can handle millions of TCP connections per second with ultra-low latency and requires a static IP address for whitelisting on client firewalls. Which ELB type is MOST appropriate?**
>
> - A. Application Load Balancer — for its advanced routing features
> - B. Gateway Load Balancer — for its security inspection capabilities
> - C. Network Load Balancer — for ultra-high performance TCP with Static IP
> - D. Classic Load Balancer — for its combined Layer 4 and Layer 7 support

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C — Network Load Balancer**
>
> Three signals: (1) **"millions of TCP connections per second"** → NLB handles millions RPS; (2) **"ultra-low latency"** → NLB has ~100ms latency vs ALB's ~400ms; (3) **"static IP address for whitelisting"** → Only NLB supports static IP via Elastic IP. ALB only provides a DNS name.
>
> **Why A is wrong:** ALB is Layer 7 (HTTP/HTTPS). The question says TCP connections — ALB doesn't natively handle raw TCP. Also, ALB doesn't support static IP.
> **Why B is wrong:** GWLB is for routing traffic through third-party security appliances (firewalls, IDS). It's not a general-purpose high-performance load balancer.
> **Why D is wrong:** CLB was retired in 2023. It's not a valid choice for new deployments.

---

### Auto Scaling Groups (ASG)

#### 1. The Naive Approach (The Problem):

عندك Load Balancer بيوزّع الـ Traffic على 3 EC2 Instances. يوم الجمعة الصبح الـ Traffic يزيد 10 أضعاف — الـ 3 Instances يتحمّلوا وكلهم CPU يوصل 100%. المشكلة: مفيش Instance جديد بيتنشأ تلقائياً. الحل المنطقي: نظام يراقب الـ Load ويزود ينقص الـ Instances أوتوماتيكياً.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Auto Scaling Groups
>
> الـ **ASG (Auto Scaling Group)** هو الـ Service اللي بيدير مجموعة من الـ EC2 Instances وبيـ Scale تلقائياً بناءً على قواعد بتحددها.
>
> **الـ 3 Parameters الأساسية:**
> - **Minimum Size:** أقل عدد Instances تشغيلاً في أي وقت (e.g., 1 Instance — عشان الـ Application ما يوقفش خالص)
> - **Maximum Size:** أكتر عدد Instances مسموح بيه (e.g., 10 Instances — عشان الفاتورة ما تطيرش)
> - **Desired Capacity / Actual Size:** العدد المطلوب الآن (e.g., 3 Instances — الـ Default)
>
> **الـ ASG وظيفته الرئيسية:**
> - **Scale Out:** يضيف EC2 Instances لما الـ Load يزيد
> - **Scale In:** يشيل EC2 Instances لما الـ Load ينقص
> - **Replace Unhealthy Instances:** لو Instance بيفشل الـ Health Check — الـ ASG بيحذفه تلقائياً وينشئ واحد جديد
> - **Register with Load Balancer:** كل Instance جديد بيتضاف تلقائياً للـ Load Balancer — الـ Traffic بيوصّله على طول
>
> **ASG + Load Balancer Architecture:**
> ```
> Internet Traffic
>       ↓
> Elastic Load Balancer
>       ↓ (distributes to)
> [EC2] [EC2] [EC2] [EC2] [EC2] [EC2]
>  \_________ASG_________/
>  Min=2, Max=10, Desired=3
> ```
>
> **الـ 5 Scaling Strategies:**
>
> **① Manual Scaling:**
> إنت بتغيّر الـ Desired Capacity يدوياً. بسيط لكن مش Elastic.
>
> **② Dynamic Scaling — Simple/Step:**
> بناءً على **CloudWatch Alarms**:
> - "لو الـ Average CPU > 70% → أضيف 2 Instances"
> - "لو الـ Average CPU < 30% → اشيل Instance واحد"
>
> **③ Dynamic Scaling — Target Tracking:**
> بتحدد **Target Metric** وإنت تسيب AWS تـ Scale عشان تحافظ عليه:
> - "خلّي الـ Average CPU حوالين 40%"
> - الـ ASG بيضيف وبيشيل Instances تلقائياً عشان يحافظ على الـ 40%
>
> **④ Scheduled Scaling:**
> بتـ Scale بناءً على **وقت معروف مسبقاً**:
> - "كل يوم جمعة الساعة 5pm — ارفع الـ Min لـ 10 Instances" (عشان الـ Weekend Traffic)
> - "الصبح الساعة 8am — الـ Normal Size"
>
> **⑤ Predictive Scaling:**
> بيستخدم **Machine Learning** لتوقع الـ Traffic المستقبلي. الـ ASG بيشوف الـ Historical Patterns ويـ Pre-provision الـ Instances قبل الـ Load الفعلي. ممتاز للـ Workloads اللي عندها **Predictable Time-based Patterns** (زي موقع بيـ Peak كل يوم الساعة 12 ظهر).

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ ASG زي **مدير موارد بشرية ذكي** لمطعمك. بتديه قواعد بسيطة:
- "المطعم لازم يكون فيه على الأقل 2 طباخ دايماً"
- "مش يعدي 10 طباخين في أي وقت"
- "دلوقتي ابدأ بـ 3 طباخين"

لما الـ Orders تكتر (Lunch Rush): المدير يلاقي إن الـ Load عالي → يكلّم الـ HR الخارجي (AWS) → يستقدم طباخين جدد → يدرّبهم ويبدأوا شغل (الـ Instance Launch يبدأ). لما الـ Orders تقل (بعد العشا): المدير يطلع كام طباخ ويوفّر على الكهربا. ولو طباخ اتعطل (Unhealthy Instance): المدير بيبعته بيته ويستقدم طباخ جديد أوتوماتيكياً من غير ما يوقف المطعم.

**Predictive Scaling** زي المدير اللي بيعرف إن كل جمعة الـ Lunch Rush أضعاف — فبيستقدم الطباخين الزيادة قبل الجمعة بيوم من غير ما يستنى الـ Load يحصل.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — ASG
>
> - **ASG + ELB = High Availability + Scalability** معاً. لما الـ Exam يسأل عن "automatically scale and distribute traffic" → الإجابة دايماً الاتنين مع بعض.
> - **ASG بيـ Replace Unhealthy Instances تلقائياً.** ده Self-Healing — مش لازم تعمله يدوياً.
> - **Scale Out = Add Instances. Scale In = Remove Instances.** الـ Terms بتيجي في الـ Exam.
> - **Predictive Scaling = Machine Learning + Time-based Patterns.** لو الـ Exam قال "predict future load using ML" → Predictive Scaling.
> - **Target Tracking = Simplest Dynamic Scaling.** بتحدد Target Metric وبتسيب AWS.
> - **الـ ASG مجاني.** بتدفع على الـ EC2 Instances اللي بتنشئها الـ ASG، مش على الـ ASG Service نفسها.
> - **Cost Optimization:** الـ ASG بيضمن إنك مش شغّال Instances زيادة في الـ Off-Peak.

#### 5. The "Zatouna" Table:

| Concept | التفاصيل |
|---|---|
| **Min Size** | أقل عدد Instances دايماً شغّالين |
| **Max Size** | أعلى عدد مسموح (Cost Control) |
| **Desired Capacity** | الـ Target الحالي |
| **Scale Out** | Add Instances (عند زيادة الـ Load) |
| **Scale In** | Remove Instances (عند قلة الـ Load) |
| **Self-Healing** | يحذف Unhealthy ويستبدله تلقائياً |
| **ELB Integration** | الـ Instances الجديدة بتتسجّل تلقائياً |
| **ASG Cost** | مجاني (بتدفع على الـ EC2 فقط) |
| **Scaling Strategies** | Manual / Simple-Step / Target Tracking / Scheduled / Predictive |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q3
> **An e-commerce company experiences predictable traffic spikes every Friday at 6 PM when a weekly flash sale begins, lasting for 2 hours. The team wants to proactively scale before the load hits rather than react after. Which ASG scaling strategy is MOST appropriate?**
>
> - A. Target Tracking Scaling — to maintain a target CPU percentage
> - B. Simple Scaling — to respond when a CloudWatch CPU alarm triggers
> - C. Scheduled Scaling — to pre-scale capacity at 5:45 PM every Friday
> - D. Manual Scaling — to increase desired capacity manually before each sale

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C — Scheduled Scaling**
>
> The key signals: (1) **"predictable"** timing — every Friday at 6 PM; (2) **"proactively scale BEFORE the load hits"** — this means not reacting to a metric but acting on a known schedule. Scheduled Scaling is exactly this: you tell the ASG "at 5:45 PM every Friday, raise the minimum to 20 instances." The capacity is ready before the first customer clicks.
>
> **Why A is wrong:** Target Tracking REACTS to current metrics (CPU is already high). By the time CPU climbs, thousands of users are already experiencing slow responses. It doesn't predict or prepare in advance.
> **Why B is wrong:** Simple/Step Scaling also REACTS to CloudWatch alarms after the metric threshold is crossed — same reactive problem as Target Tracking.
> **Why D is wrong:** Manual Scaling requires a human to intervene every Friday. It's error-prone (someone might forget), and it's not automated. The question implies the team wants an automated, hands-off solution.

---

## 📦 ELB & ASG — Section Summary

| Concept | الجوهر |
|---|---|
| **Vertical Scaling** | Instance أكبر (Scale Up) — حد أعلى موجود |
| **Horizontal Scaling** | Instances أكتر (Scale Out/In) — مفيش حد تقريباً |
| **High Availability** | Multi-AZ Deployment — Survive AZ Failure |
| **Elasticity** | Auto-Scale تلقائياً بالـ Load |
| **Agility** | سرعة Provisioning (Cloud in general) — مش Scaling |
| **ALB** | Layer 7 — HTTP/HTTPS — URL-based Routing |
| **NLB** | Layer 4 — TCP/UDP — Millions RPS — Static IP |
| **GWLB** | Layer 3 — Security Appliances — GENEVE Protocol |
| **CLB** | Retired 2023 — Legacy |
| **ASG** | Auto Scale EC2 — Min/Max/Desired — Self-Healing |
| **Scale Out** | Add EC2 Instances |
| **Scale In** | Remove EC2 Instances |
| **Target Tracking** | أسهل Dynamic Scaling — حدد Target Metric |
| **Scheduled** | Scale حسب وقت معروف مسبقاً |
| **Predictive** | ML-based — Time-based Patterns |

---

## 🧪 Grand Quiz — Sections 6 & 7 Final Checkpoint

> [!question]- 🧪 Grand Quiz Q1 — شركة عندها 200 EC2 Linux Instance محتاجين يوصلوا لنفس الـ Configuration Files في نفس الوقت عبر AZs متعددة. أنهي Storage Solution المناسبة؟
>
> - A. EBS Volume with Multi-Attach enabled
> - B. EC2 Instance Store على كل Instance
> - C. EFS Elastic File System
> - D. S3 Bucket مع SDK للوصول

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — EFS**
> EFS هو الـ Shared NFS اللي بيسمح لمئات الـ Linux Instances من Multi-AZ يوصلوا لنفس الـ File System في نفس الوقت. EBS مش مناسب للـ Multi-Instance (One Instance at a time at CCP level). Instance Store Ephemeral. S3 مش Block Storage — محتاج API Calls مش File System Access.

---

> [!question]- 🧪 Grand Quiz Q2 — مطلوب عمل Backup لـ EBS Volume ونقله لـ Region تانية. أنهي خطوات صح؟
>
> - A. Detach الـ Volume وأرسله بالـ AWS Transfer Service
> - B. عمل Snapshot من الـ Volume، ثم Copy الـ Snapshot للـ Region التانية، ثم Restore
> - C. Enable EBS Multi-Attach ليوصّله Instances في Regions متعددة
> - D. تحويل الـ EBS لـ EFS عشان يبقى Multi-Region

> [!success]- ✅ Reveal Answer
> **Correct Answer: B**
> الـ Workflow الصح: Create Snapshot (Region-scoped في S3) → Copy Snapshot to Target Region → Restore as new EBS Volume في الـ Region الجديدة. مفيش Direct Cross-Region EBS Attachment.

---

> [!question]- 🧪 Grand Quiz Q3 — ما الفرق الجوهري بين EC2 Instance Store وEBS؟
>
> - A. Instance Store أغلى من EBS
> - B. Instance Store بيتمسح عند Stop/Terminate، EBS بيفضل موجود
> - C. EBS يوفر IOPS أعلى من Instance Store
> - D. Instance Store بيشتغل على النت، EBS Physical Disk

> [!success]- ✅ Reveal Answer
> **Correct Answer: B**
> الفرق الجوهري هو الـ Persistence. Instance Store = Ephemeral (بيتمسح). EBS = Persistent (بيفضل). العكس صح بالنسبة للـ IOPS — Instance Store أعلى IOPS لأنه Physical. وInstance Store هو Physical/Local، EBS هو Network Drive.

---

> [!question]- 🧪 Grand Quiz Q4 — Application بيستخدم Windows Servers ومحتاج Shared File System يدعم SMB Protocol ومتكامل مع Active Directory. أنهي Service؟
>
> - A. EFS — Elastic File System
> - B. FSx for Lustre
> - C. FSx for Windows File Server
> - D. EBS with Multi-Attach

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — FSx for Windows File Server**
> الـ Keywords: Windows + SMB + Active Directory = FSx for Windows. EFS هو Linux only. FSx for Lustre هو HPC Linux. EBS Multi-Attach مش Shared File System.

---

> [!question]- 🧪 Grand Quiz Q5 — Web Application محتاجة توزّع الـ Traffic على EC2 Instances، توعمل Health Checks، وتشيل Instances الفاشلة تلقائياً وتضيف Instances جديدة لما يزيد الـ Load. أنهي Architecture؟
>
> - A. Single EC2 Instance مع Auto Restart Policy
> - B. Application Load Balancer مع Auto Scaling Group
> - C. Network Load Balancer بدون ASG
> - D. Multiple EC2 Instances بـ Manual Management

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — ALB + ASG**
> ALB بيعمل الـ Load Distribution والـ Health Checks وبيوجّه Traffic بعيداً عن الـ Unhealthy Instances. الـ ASG بيعمل الـ Auto-Scaling (Add/Remove Instances) والـ Self-Healing (Replace Unhealthy). الاتنين مع بعض هو الـ Standard HA + Scalability Architecture في AWS.

---

*القسم الجاي: **Amazon S3 — Simple Storage Service** — الـ Object Storage اللي الـ Internet بيشتغل عليه.*
