# 🖥️ EC2 — Elastic Compute Cloud + Storage + ELB + ASG
**AWS Certified Cloud Practitioner — CLF-C02**
*Senior AWS Solutions Architect | 20+ Years Experience*

---

## 🧱 البداية — إيه معنى "Cloud Computing" في الواقع؟

كل الكلام الجميل عن الـ Cloud — الـ Pay-as-you-go، الـ Elasticity، الـ Global Infrastructure — كله يرجع في النهاية لحاجة واحدة أساسية: **إنت محتاج سيرفر يشغّل الكود بتاعك.** وده بالظبط اللي الـ **Amazon EC2** بيديهولك.

الـ **EC2 (Elastic Compute Cloud)** هو أشهر وأهم خدمة في الـ AWS على الإطلاق. هو **IaaS — Infrastructure as a Service** — يعني AWS بتديك الـ Virtual Machine الخام، وإنت بتعمل فيها اللي إنت عايزه. ومش بس سيرفرات — EC2 هو في الحقيقة أربع قدرات مجمّعة:

- **Renting Virtual Machines** — تأجير سيرفرات افتراضية بالثانية.
- **Storing Data on Virtual Drives** — تخزين البيانات على الـ **EBS**.
- **Distributing Load across Machines** — توزيع الحمل بالـ **ELB**.
- **Scaling Services using Auto Scaling** — التوسع التلقائي بالـ **ASG**.

فهم EC2 مش بس مهم للـ Exam — هو أساس فهم كيف يشتغل الـ Cloud كله.

---

## ⚙️ بتبني السيرفر — إيه الخيارات؟

لما بتشغّل EC2 Instance على AWS، إنت بالكامل بتختار مواصفاته. ده مش زي الـ PaaS اللي AWS بتقرر كل حاجة — هنا إنت اللي بتحدد:

- **Operating System** — Linux أو Windows أو macOS.
- **CPU** — عدد الـ vCPUs ونوعها.
- **RAM** — كمية الذاكرة.
- **Storage** — إما Network-Attached زي EBS وEFS، أو Hardware-Attached زي الـ EC2 Instance Store.
- **Network Card** — سرعة الكارت والـ Public IP Address.
- **Security Group** — الـ Firewall اللي بيتحكم في الـ Traffic.
- **EC2 User Data** — Script بتشتغل مرة واحدة عند أول تشغيل للـ Instance.

**الـ EC2 User Data** ده مهم جداً للـ Exam. هو Script بتكتبه بنفسك وبتحطه عند إنشاء الـ Instance — وبيشتغل **مرة واحدة بس عند الـ First Launch** بصلاحيات الـ Root User. بتستخدمه لتثبيت الـ Updates، تنزيل الـ Software، أو أي تهيئة أولية محتاجها. بعد أول تشغيل — مش بيشتغل تاني حتى لو الـ Instance اتوقف وأعيد تشغيله.

---

## 🏷️ فهم أسماء الـ Instance Types

الـ EC2 instances بتيجي في أحجام وأنواع مختلفة، وكل اسم بيقولك حاجة. خد `m5.2xlarge` كمثال:

- **m** = الـ Instance Class (General Purpose في الحالة دي).
- **5** = الـ Generation — رقم بيزيد كل ما AWS بتحسّن الـ Hardware.
- **2xlarge** = الـ Size جوه الـ Class — كل ما الاسم أكبر، كل ما الموارد أكتر.

**فيه أربع فئات رئيسية لازم تحفظهم للـ Exam:**

**General Purpose (t, m):**
الفئة الأكتر استخداماً. بتديك توازن بين الـ Compute والـ Memory والـ Networking. مناسبة لـ Web Servers وCode Repositories وأي Workload عادي. الـ `t2.micro` هو الـ Instance اللي بتبدأ بيه في الكورس وجزء من الـ Free Tier.

**Compute Optimized (c):**
للـ Workloads اللي محتاجة CPU قوي جداً. زي: Batch Processing، Media Transcoding، High Performance Web Servers، Scientific Modeling، Machine Learning Training، وDedicated Gaming Servers. الحرف **c** = Compute.

**Memory Optimized (r, x, z):**
للـ Workloads اللي بتشتغل على بيانات ضخمة في الـ RAM نفسها. زي: High Performance Databases، Distributed Cache Stores، In-Memory Databases للـ Business Intelligence، وReal-Time Processing. الحرف **r** = RAM.

**Storage Optimized (i, d, h):**
للـ Workloads اللي محتاجة Read/Write سريع جداً على الـ Local Storage. زي: OLTP Systems، Relational وNoSQL Databases، Redis Cache، Data Warehousing، وDistributed File Systems.

---

## 🔥 Security Groups — الـ Firewall بتاع الـ EC2

الـ **Security Groups** هي الـ Fundamental لأمان الشبكة في AWS. هي بتشتغل كـ **Virtual Firewall** على الـ EC2 Instances — بتتحكم في كل Traffic داخل وخارج.

الـ Security Group بتحتوي على **Rules بس** — كل Rule بتقول: "اسمح لـ Traffic من الـ IP ده على الـ Port ده يدخل أو يخرج." الـ Rules ممكن تستند على:
- **IP Addresses** — IPv4 أو IPv6 محدد أو Range.
- **Other Security Groups** — تسمح لأي Instance في الـ SG ده يوصل.

**المبادئ الأساسية:**
- **All Inbound Traffic محظور بـ Default** — يعني أي Request جاي للـ Instance بيتبلوك تلقائياً إلا لو عملت Rule بتسمحه صراحةً.
- **All Outbound Traffic مسموح بـ Default** — الـ Instance يقدر يتواصل مع أي حاجة بره من غير قيود.
- الـ Security Group **"lives outside" the EC2** — الـ EC2 Instance نفسه مش بيشوف الـ Traffic المبلوك. الـ Block بيحصل قبل ما الـ Packet توصل للـ Instance.
- ممكن تـ Attach نفس الـ Security Group على **أكتر من Instance**.
- الـ Security Group **مقيّدة بـ Region/VPC** — مش ممكن تستخدم SG من Region في Region تانية.

**تشخيص المشاكل — قاعدة ذهبية للـ Exam:**
- لو الـ Application **Timeout** — دي مشكلة في الـ Security Group. الـ Traffic بيتبلوك قبل ما يوصل.
- لو الـ Application بترجع **"Connection Refused"** — دي مشكلة في الـ Application نفسها أو مش شغّالة. الـ Traffic وصل بس الـ App مش ردّت.

---

## 🔌 الـ Ports الأساسية — لازم تحفظهم

| Port | Protocol | الاستخدام |
|------|----------|-----------|
| 22 | SSH | دخول على Linux Instances من الـ Terminal |
| 21 | FTP | رفع ملفات |
| 22 | SFTP | رفع ملفات بأمان عبر SSH |
| 80 | HTTP | مواقع عادية غير مشفّرة |
| 443 | HTTPS | مواقع مشفّرة (SSL/TLS) |
| 3389 | RDP | دخول على Windows Instances |

---

## 💰 خيارات الشراء — دفع إزاي؟

ده من أهم أجزاء الـ Exam. فيه سبع طرق مختلفة لدفع ثمن الـ EC2 Instances، وكل واحدة بتناسب سيناريو مختلف. الـ Exam بيحب يديك Scenario ويسألك "إيه الـ Option الأمثل؟"

**1. On-Demand:**
بتدفع بالثانية (Linux/Windows) أو بالساعة (OS تانية) بدون أي التزام. أعلى سعر لكن أقصى مرونة. مفيش Upfront Payment ومفيش Contract. للـ Short-Term Workloads وأي حاجة مش قادر تتوقع سلوكها.

**2. Reserved Instances:**
بتحجز Instance لمدة **1 أو 3 سنوات** وبتاخد Discount كبير (يصل لـ 72%). بتحدد الـ Instance Type والـ Region والـ OS والـ Tenancy وبتفضل ملتزم بيهم. الأنسب للـ Steady-State Applications زي الـ Databases اللي شغّالة طول الوقت. ممكن تبيع وتشتري Reserved Instances في الـ **Reserved Instance Marketplace**. فيه نوع ثاني اسمه **Convertible Reserved Instance** بيسمحلك تغير الـ Instance Type والـ OS والـ Scope خلال فترة الحجز — مرونة أكتر لكن Discount أقل (66%).

**3. Savings Plans:**
بدل ما تحجز Instance بعينه، بتلتزم بمبلغ معين بالساعة لمدة 1 أو 3 سنوات (زي "$10/hour"). نفس نسبة الـ Discount زي الـ Reserved تقريباً (72%) لكن مرونة أكتر — مقيّد بـ Instance Family والـ Region بس، بيكون flexible في الـ Size والـ OS والـ Tenancy.

**4. Spot Instances:**
الأرخص على الإطلاق — Discount يصل لـ **90%**. بتحدد أقصى سعر إنت مستعد تدفعه. لو السعر الحالي اتجاوز الـ Max Price بتاعك — الـ Instance بتتأخذ منك في غضون دقيقتين بدون رجعة. مناسبة جداً للـ Batch Jobs، Data Analysis، Image Processing، وأي Workload مقدر يتحمل الانقطاع المفاجئ. **مش مناسبة أبداً للـ Critical Applications أو Databases.**

**5. Dedicated Hosts:**
بتحجز **Physical Server كامل** مخصص ليك إنت بس. أغلى Option على الإطلاق. بتستخدمها في حالتين: لما عندك Software Licenses مربوطة بالـ Hardware (BYOL — Bring Your Own License، زي Oracle أو Windows Server Per-Socket/Per-Core)، أو لما عندك Compliance Requirements صعبة بتمنعك تشارك الـ Hardware مع أي حد.

**6. Dedicated Instances:**
الـ Instance بتشتغل على Hardware مخصص ليك — بس ممكن تتشارك الـ Hardware مع Instances تانية من **نفس الـ Account بتاعتك**. مش بتشارك مع Customers تانيين. أرخص من الـ Dedicated Hosts ولكن مش عندك تحكم في الـ Instance Placement.

**7. Capacity Reservations:**
بتحجز **Capacity** في AZ محدد لأي مدة — بدون Discount وبدون التزام زمني. بتفضل تدفع الـ On-Demand Rate حتى لو مش شغّال الـ Instances. الفايدة الوحيدة: ضمان إن الـ Capacity موجودة لما تحتاجها في الـ AZ ده بالذات.

**الجدول المقارن:**

| Option | الاستخدام الأمثل | التوفير |
|---|---|---|
| On-Demand | Short-term، unpredictable | لا يوجد |
| Reserved (1/3 yr) | Steady-state (databases) | حتى 72% |
| Savings Plans | Flexible long-term | حتى 72% |
| Spot | Fault-tolerant batch jobs | حتى 90% |
| Dedicated Host | BYOL أو Compliance | متغير |
| Dedicated Instance | Hardware isolation | أقل من Dedicated Host |
| Capacity Reservation | ضمان الـ Capacity في AZ | لا يوجد |

---

## 💾 EC2 Storage — فين بتحط البيانات؟

الـ EC2 Instance بياخد Compute — CPU وRAM. بس البيانات محتاج تتخزن في حتة. فيه أربع طرق مختلفة لتخزين البيانات مع الـ EC2، وكل واحدة بتناسب حالة.

---

### EBS — Elastic Block Store

الـ **EBS Volume** هو الـ "Network USB Stick" — Storage Drive افتراضي بتوصله بالـ EC2 Instance عبر الشبكة. البيانات بتتحفظ حتى بعد ما الـ Instance يتوقف أو يتحذف. ده اللي بيخليه مختلف عن الـ Instance Store.

**خصائصه الأساسية:**
- هو **Network Drive** — مش فيزيائي. بيستخدم الشبكة للتواصل مع الـ Instance، ومعناه ممكن يكون فيه شوية Latency.
- **Locked to an Availability Zone** — الـ EBS Volume في `us-east-1a` مش ممكن يتوصل بـ Instance في `us-east-1b`. عشان تنقله، لازم تعمله **Snapshot** الأول.
- **One Instance at a Time** — على مستوى الـ CLF-C02، كل EBS Volume بيتوصل بـ Instance واحد بس في نفس الوقت.
- **Provisioned Capacity** — بتحدد الحجم (GBs) والـ IOPS مقدماً وبتدفع على اللي حجزته — حتى لو مش مستخدم كله.
- **Delete on Termination** — بـ Default، الـ Root EBS Volume بيتحذف لما الـ Instance يتحذف. الـ Additional Volumes مش بتتحذف. ممكن تغير الـ Behavior ده.

---

### EBS Snapshots — النسخ الاحتياطية

الـ **Snapshot** هو نسخة احتياطية من الـ EBS Volume في لحظة معينة. تقدر تعمل Snapshot والـ Volume لسه متوصل (Recommended تفصله بس مش إلزامي).

الأهم: **الـ Snapshots بتنتقل بين الـ AZs والـ Regions.** ده المفتاح لنقل البيانات من AZ لـ AZ أو من Region لـ Region — تعمل Snapshot وتـ Restore منه في الـ AZ أو الـ Region الجديدة.

**Features مهمة:**
- **EBS Snapshot Archive** — بتنقل الـ Snapshot لـ "Archive Tier" بـ 75% أرخص. الـ Trade-off: لو احتجت تـ Restore — بياخد من **24 لـ 72 ساعة**.
- **Recycle Bin** — بتعمل Rules تحتفظ بالـ Snapshots المحذوفة لفترة معينة (من يوم لسنة) عشان تقدر ترجعها لو حذفتها بالغلط.

---

### AMI — Amazon Machine Image

الـ **AMI** هو الـ Template الكامل للـ EC2 Instance — بيتضمن الـ OS، الـ Software المثبّت، الـ Configurations، كل حاجة. لما بتشغّل Instance من AMI، بياخد كل اللي فيها جاهز من غير ما تعمل Setup من الصفر.

**ثلاث أنواع من الـ AMIs:**
- **Public AMI** — بتوفرها AWS. زي Amazon Linux 2، Ubuntu، Windows Server.
- **Custom AMI** — بتعملها إنت. بتشغّل Instance، بتعمل فيها كل الـ Setup اللي محتاجه، بتوقفها، وبتعمل منها AMI. المرة الجاية بتشغّل Instance من الـ AMI دي — كل حاجة جاهزة فوراً.
- **Marketplace AMI** — AMIs معمولة من Third Parties — بعضها مجاني وبعضها بيكلف. زي AMIs مع Software جاهز زي Nginx أو databases.

الـ AMIs **مقيّدة بـ Region** — لو عايز تستخدم نفس الـ AMI في Region تاني، بتـ Copy بيها.

**EC2 Image Builder:**
Service مجانية بتـ Automate عملية بناء الـ AMIs. بتشغّل Instance، بتطبق عليها Build Components (زي تنزيل Software)، بتشغّل Test Suite عليها، وبعدين بتوزّع الـ AMI على الـ Regions اللي إنت محتاجها. ممكن تشتغل على Schedule. بتدفع بس على الـ Underlying Resources (Instance وقت البناء).

---

### EC2 Instance Store — السرعة الخام

الـ **Instance Store** هو Storage فيزيائي ملصق بالـ Physical Server اللي الـ EC2 بتاعتك شغّالة عليه. مش Network Drive — ده Hard Disk حقيقي.

**المميزات:** I/O Performance عالية جداً — أسرع بكتير من الـ EBS.

**العيب الكبير:** الـ Instance Store هو **Ephemeral (مؤقت)**. لو الـ Instance اتوقفت (Stopped) أو اتحذفت (Terminated) — **البيانات بتتحذف نهائياً بدون رجعة.** حتى لو الـ Hardware نفسه فشل — البيانات بتضيع. مسؤولية الـ Backup والـ Replication عليك إنت.

متصلح لـ: Buffer، Cache، Scratch Data، أي بيانات مؤقتة مش محتاجها تتحفظ.

---

### EFS — Elastic File System

الـ **EFS** هو Network File System مُدار — بتـ Mount بيه على **مئات الـ EC2 Instances في نفس الوقت**. ده الفرق الجوهري عن الـ EBS اللي بيتوصل بـ Instance واحد بس.

**خصائصه:**
- بيشتغل مع **Linux EC2 Instances فقط** — مش Windows.
- **Multi-AZ** — بيشتغل عبر أكتر من AZ في نفس الوقت تلقائياً.
- **Highly Available وScalable** — بيكبر تلقائياً مع البيانات.
- **أغلى من EBS** — تقريباً 3x سعر الـ gp2 EBS Volume.
- **Pay per use** — بتدفع على اللي بتستخدمه فعلاً، مش على Provisioned Capacity.

**EFS Infrequent Access (EFS-IA):**
Storage Class مُحسّنة للملفات اللي مش بتتوصللها كل يوم. أرخص بـ 92% من الـ EFS Standard. بتفعّلها بـ **Lifecycle Policy** — مثلاً "أي ملف ماتوصلوش من 60 يوم انقله لـ EFS-IA تلقائياً." العملية شفّافة تماماً للـ Application — مش محتاج تغير أي كود.

---

### Amazon FSx — File Systems من Third Parties

**Amazon FSx** هو Service بيشغّل High-Performance File Systems من Third Parties على AWS كـ Fully Managed Service.

- **FSx for Windows File Server** — Windows-native shared file system. بيدعم SMB Protocol وWindows NTFS. بيتكامل مع Microsoft Active Directory. للـ Windows-based Applications اللي محتاجة Shared Storage.
- **FSx for Lustre** — High-Performance Computing (HPC) File System. اسمه من "Linux + Cluster." للـ Machine Learning، Analytics، Video Processing، Financial Modeling. بيوصل لـ 100s GB/s وملايين IOPS وLatency أقل من millisecond.

---

## ⚖️ المقارنة النهائية للـ Storage

| نوع الـ Storage | بيتوصل بـ | الـ Persistence | الأداء | الاستخدام |
|---|---|---|---|---|
| EBS | Instance واحد في AZ واحد | ✅ Persistent | جيد | General Storage، OS Drive |
| EC2 Instance Store | نفس الـ Instance فيزيائياً | ❌ Ephemeral | ممتاز جداً | Cache مؤقت |
| EFS | مئات الـ Instances في Multi-AZ | ✅ Persistent | جيد | Shared File System (Linux) |
| FSx for Windows | Windows Instances | ✅ Persistent | عالي | Windows Shared Storage |
| FSx for Lustre | HPC Clusters | ✅ Persistent | استثنائي | HPC، ML، Analytics |

---

## 🔄 الـ Scalability وHighAvailability — مش نفس الحاجة

قبل ما نيجي للـ ELB والـ ASG، لازم نفهم الفرق بين ثلاث مصطلحات بيتخلط فيهم الناس دايماً:

**Vertical Scalability (Scale Up/Down):**
يعني بتكبّر الـ Instance نفسه — زيادة الـ CPU والـ RAM. زي ما تترقّي من Junior Developer لـ Senior Developer. مثال: بدّل `t2.micro` بـ `t2.large`. فيه **حد أقصى** — مفيش Instance بلا نهاية.

**Horizontal Scalability (Scale Out/In):**
يعني بتضيف Instances جديدة بدل ما تكبّر الواحدة. زي ما تعيّن موظفين جدد بدل ما تشغّل واحد أكتر ساعات. الـ Cloud اتصمّم أساساً لدعم ده. ممكن تعمله يدوياً أو تلقائياً بالـ ASG.

**Elasticity:**
لما الـ Horizontal Scaling بيحصل **تلقائياً** حسب الـ Load — من غير تدخل يدوي. الـ System بيكبر لما الضغط يزيد وبيصغر لما يقل. ده هو الـ Cloud-native behavior الحقيقي.

**High Availability:**
إنك بتشغّل الـ Application في **أكتر من AZ في نفس الوقت**. هدفه الوحيد: لو AZ كاملة وقعت — الـ Application بتكمل شغلانتها من الـ AZ التانية بدون انقطاع للـ Users. ده **مش نفس الـ Scalability** — ده **Survival** من Disasters.

**Agility** (مش مرتبط بالـ Scaling):
يعني إنك تقدر تعمل Resources جديدة في دقايق بدل أسابيع. ده Advantage من مزايا الـ Cloud بشكل عام، مش Scaling Mechanism.

---

## 🚦 Elastic Load Balancer — الموزّع الذكي

الـ **ELB (Elastic Load Balancer)** هو Service مُدار بيستقبل الـ Traffic القادم من الـ Users وبيوزّعه على عدد من الـ EC2 Instances. بدل ما 1000 User يضربوا نفس الـ Server — الـ ELB بيوزّعهم على 10 Servers بالتساوي.

**ليه ELB أحسن من Load Balancer خاص بيك؟**
لو عملت Load Balancer على EC2 يدوياً — إنت المسؤول عن كل حاجة: الصيانة، الـ Upgrades، الـ High Availability. مع الـ ELB، AWS هي المسؤولة عن كل ده. أرخص على المدى البعيد وأقل تعب بكتير.

**فوايد الـ ELB:**
- **توزيع الـ Load** على أكتر من Instance.
- **Single Point of Access (DNS)** للـ Application — Users بيتكلموا مع الـ ELB، مش الـ Servers المباشرة.
- **Health Checks** — الـ ELB بيتحقق باستمرار إن الـ Instances شغّالة. لو Instance وقعت — الـ ELB بيبطل يبعتلها Traffic تلقائياً.
- **SSL Termination** — بيعمل HTTPS للـ Users ويتعامل مع الـ Instances داخلياً بـ HTTP.
- **High Availability across AZs** — بيوزّع على Instances في AZs مختلفة.

**أنواع الـ Load Balancers — مهمة جداً للـ Exam:**

| النوع | الـ Layer | البروتوكول | متى تستخدمه |
|---|---|---|---|
| **Application LB (ALB)** | Layer 7 | HTTP / HTTPS / gRPC | الأغلب — Web Apps، Microservices |
| **Network LB (NLB)** | Layer 4 | TCP / UDP | Ultra-high performance، Static IP |
| **Gateway LB (GWLB)** | Layer 3 | GENEVE (IP Packets) | Routing عبر Security Appliances |
| Classic LB | Layer 4 & 7 | Mixed | متقاعد منذ 2023، تجاهله |

---

## 📈 Auto Scaling Groups — التوسع التلقائي

الـ **ASG (Auto Scaling Group)** هو الحل الكامل لمشكلة الـ Load المتغير. إنت بتقوله: "عايز دايماً بين X وY Instances شغّالين" — وهو بيدير الباقي تلقائياً.

**وظائف الـ ASG:**
- **Scale Out** — بيضيف Instances تلقائياً لما الـ Load يزيد.
- **Scale In** — بيشيل Instances تلقائياً لما الـ Load يقل.
- **Minimum وMaximum وDesired Capacity** — بتحدد الحدود الدنيا والقصوى والمثالية.
- **Automatic Registration مع الـ ELB** — الـ Instances الجديدة بتتضاف للـ Load Balancer تلقائياً.
- **Replace Unhealthy Instances** — لو Instance وقعت، الـ ASG بيشيلها ويعمل واحدة جديدة.
- **Cost Savings** — بتشتغل دايماً بـ Optimal Capacity بدون زيادة أو نقصان.

**استراتيجيات الـ Scaling:**

- **Manual Scaling** — إنت بتحدد العدد يدوياً. للاختبارات والإعدادات الخاصة.
- **Dynamic Scaling — Simple/Step:** بتربطه بـ CloudWatch Alarm — "لو الـ CPU عدى 70% ضيف 2 Instances، لو نزل تحت 30% شيل واحد."
- **Dynamic Scaling — Target Tracking:** إنت بتقوله "خلي الـ CPU دايماً حواليه 40%" وهو بيعمل الحسابات وحده.
- **Scheduled Scaling:** بتحدد وقت محدد للـ Scale — "كل يوم جمعة الساعة 5 المساء، ضيف Instances عشان الـ Load بيزيد."
- **Predictive Scaling:** بيستخدم **Machine Learning** يتوقع الـ Load المستقبلي بناءً على التاريخ ويـ Scale قبليه. مثالي للـ Workloads اللي عندها Pattern واضح زي مواقع التعليم (الضغط أعلى في أوقات الامتحانات).

---

## 🤝 الـ Shared Responsibility للـ EC2 وStorage

**AWS مسؤولة عن:**
الـ Physical Infrastructure، الـ Isolation بين الـ Hosts، استبدال الـ Hardware المعطوب، والـ Compliance Validation للـ Infrastructure.

**إنت مسؤول عن:**
- **EC2:** Security Group Rules، OS Patches والـ Updates، الـ Software المثبّت، الـ IAM Roles على الـ Instance، وأمان البيانات.
- **Storage:** عمل الـ Backup والـ Snapshot، الـ Encryption للبيانات، فهم مخاطر الـ Instance Store (Ephemeral)، وضمان إن موظفينك مش يوصلوا لبيانات مش من حقهم.

---

## 🗺️ الصورة الكاملة في جملة واحدة

> **EC2 Instance** بيشتغل بـ **Instance Type** مناسب ← محمي بـ **Security Group** ← بياخد Storage من **EBS أو Instance Store أو EFS** ← الـ Traffic بييجيله عبر **ELB** ← الـ ELB بيوزّع على مجموعة من الـ Instances في **ASG** ← الـ ASG بيـ Scale تلقائياً حسب الـ Load ← كل ده موزّع على **Multiple AZs** للـ High Availability.

---
---

# 🎯 EC2 + Storage + ELB + ASG — Exam Practice (CLF-C02 Style)

> **Instructions:** Read the question and ALL choices carefully before expanding the answer.

---

### Q1. A company needs to run a database that will operate continuously for the next 3 years with a consistent, predictable workload. Which EC2 purchasing option provides the BEST cost savings?

- A. On-Demand Instances
- B. Spot Instances
- C. Reserved Instances (3-year term)
- D. Dedicated Hosts

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> Reserved Instances are purpose-built for exactly this scenario — **steady-state, long-running, predictable workloads**. A 3-year Reserved Instance gives the maximum possible discount (up to 72% compared to On-Demand). Databases are the textbook example because they run 24/7 without interruption and their capacity needs are known in advance.
>
> **Why each wrong answer fails:**
> - **A** — On-Demand is the most expensive option with zero discount. It's meant for short-term, unpredictable workloads — the opposite of a 3-year database.
> - **B** — Spot Instances can be terminated at any moment with 2 minutes notice when AWS needs the capacity back. Running a production database on Spot is a guaranteed disaster waiting to happen.
> - **D** — Dedicated Hosts are for compliance and BYOL licensing requirements, not cost optimization for regular workloads. They are the most expensive option.

---

### Q2. A developer's EC2 instance is running a web application. Users report that when they try to connect to the application, they receive a "connection timed out" error. What is the MOST LIKELY cause?

- A. The application has crashed and needs to be restarted
- B. The EC2 instance has run out of memory
- C. A Security Group rule is blocking inbound traffic to the application's port
- D. The EC2 instance is in the wrong Availability Zone

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> This is the golden diagnostic rule for EC2 networking: **Timeout = Security Group issue**. A timeout means the TCP connection never even established — the packets are being dropped before they reach the instance. This happens when a Security Group doesn't have an inbound rule allowing traffic on the port the application is listening on. The EC2 instance itself never sees the blocked traffic because Security Groups filter at the network level before packets reach the instance.
>
> **The contrast to memorize:**
> - **Timeout** → Security Group is blocking the traffic.
> - **"Connection Refused"** → Traffic reached the instance, but the application isn't listening (crashed, wrong port, not started).
>
> **Why each wrong answer fails:**
> - **A** — If the application crashed, the connection would reach the instance and you'd get "Connection Refused," not "Timeout."
> - **B** — Memory exhaustion causes application slowness or crashes, resulting in "Connection Refused" — not a network timeout.
> - **D** — Being in a different AZ doesn't cause timeouts. Instances are accessible by their public IP regardless of AZ.

---

### Q3. Which EC2 instance type family is BEST suited for a workload running an in-memory database that processes large datasets entirely in RAM?

- A. Compute Optimized (C family)
- B. Memory Optimized (R family)
- C. Storage Optimized (I family)
- D. General Purpose (T family)

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> Memory Optimized instances (R, X, Z families) are specifically designed for workloads that need to process **large datasets that live entirely in RAM**. In-memory databases like Redis, SAP HANA, or real-time BI applications keep their entire working dataset in memory for maximum performance. The R family delivers very high RAM-to-CPU ratios — some instances go up to 24 TB of RAM — exactly what these workloads need.
>
> **The mnemonic:** R = RAM. M = Middle/Balanced. C = CPU/Compute. I = I/O/Storage.
>
> **Why each wrong answer fails:**
> - **A** — Compute Optimized (C) has proportionally more CPU power. Use it for video transcoding, HPC, ML training, or high-traffic web servers — not RAM-heavy databases.
> - **C** — Storage Optimized (I) has very fast local NVMe SSDs. Use it for OLTP systems that need extreme disk I/O — not in-memory processing.
> - **D** — General Purpose (T, M) has a balanced ratio. Good for web servers and dev environments, but not optimized for RAM-intensive workloads.

---

### Q4. What happens to data stored on an EC2 Instance Store if the instance is stopped?

- A. The data is automatically backed up to Amazon S3
- B. The data persists and is available when the instance starts again
- C. The data is lost permanently
- D. The data is moved to an EBS volume automatically

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> EC2 Instance Store is **ephemeral storage** — it is physically attached to the host server where your EC2 instance runs. When the instance is stopped, hibernated, or terminated, the data on Instance Store is **permanently and irrecoverably erased**. Even if the underlying hardware fails, the data is gone. This is by design — Instance Store trades persistence for extreme I/O performance. The responsibility for backing up Instance Store data falls entirely on the customer.
>
> **Why each wrong answer fails:**
> - **A** — There is no automatic backup of Instance Store to S3. If you want backups, you must set this up yourself with a custom script.
> - **B** — This is the behavior of EBS volumes, not Instance Store. EBS persists across stop/start cycles. Instance Store does not.
> - **D** — AWS does not automatically migrate Instance Store data anywhere. When it's gone, it's gone.

---

### Q5. A company needs shared file storage that can be simultaneously accessed by 200 Linux EC2 instances across multiple Availability Zones. Which storage solution should be used?

- A. One EBS Volume attached to all instances
- B. Amazon EFS (Elastic File System)
- C. EC2 Instance Store
- D. Amazon FSx for Windows File Server

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> Amazon EFS is a managed Network File System (NFS) that can be **mounted on hundreds of EC2 instances simultaneously**, and it works **across multiple Availability Zones** natively. It scales automatically, requires no capacity planning, and delivers consistent performance. This is exactly the use case EFS was built for.
>
> **Why each wrong answer fails:**
> - **A** — At the CLF-C02 level, EBS Volumes can only be attached to **one EC2 instance at a time**. You cannot share a single EBS Volume across 200 instances simultaneously.
> - **C** — Instance Store is local to a single physical host. It can't be shared between instances at all, and it's ephemeral.
> - **D** — FSx for Windows File Server uses the SMB protocol and is designed for **Windows** workloads. The question specifies Linux instances. Using Windows File Server with Linux instances would require extra configuration and isn't the right fit.

---

### Q6. A company wants to move an EBS Volume from us-east-1a to us-east-1b. What is the correct sequence of steps?

- A. Detach the volume and re-attach it to an instance in us-east-1b
- B. Create a Snapshot of the volume, then restore it in us-east-1b
- C. Use the EBS Transfer service to move the volume directly
- D. Copy the volume using the AWS CLI move command

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> EBS Volumes are **locked to a specific Availability Zone**. A volume created in `us-east-1a` cannot be directly attached to an instance in `us-east-1b`. The correct process is: (1) Create a Snapshot of the EBS Volume — Snapshots are stored in S3 which is region-wide, not AZ-specific. (2) Restore the Snapshot as a new EBS Volume in `us-east-1b`. (3) Attach the new volume to your instance in `us-east-1b`.
>
> **Why each wrong answer fails:**
> - **A** — You cannot detach from one AZ and re-attach in a different AZ. The volume's AZ is fixed at creation time. Attempting this would simply fail.
> - **C** — There is no "EBS Transfer service" in AWS. This option is fabricated.
> - **D** — There is no `aws ebs move` command. This option is fabricated.

---

### Q7. An application needs to handle millions of TCP connections per second with ultra-low latency. The application requires a static IP address. Which load balancer should be used?

- A. Application Load Balancer (ALB)
- B. Classic Load Balancer
- C. Network Load Balancer (NLB)
- D. Gateway Load Balancer (GWLB)

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> The Network Load Balancer operates at **Layer 4 (TCP/UDP)** and is purpose-built for extreme performance — millions of requests per second with sub-millisecond latency. A critical differentiator is that NLB supports **Static IP addresses through Elastic IP** — something ALB cannot do. If an application requires a fixed IP that clients can whitelist in their firewall, NLB is the answer.
>
> **Why each wrong answer fails:**
> - **A** — Application Load Balancer operates at Layer 7 (HTTP/HTTPS). It's intelligent and feature-rich but adds processing overhead. It also uses a DNS name, not a static IP. Not suitable for raw TCP performance requirements.
> - **B** — Classic Load Balancer was retired in 2023. It should never be chosen for any new use case. Treat it as a wrong answer by default.
> - **D** — Gateway Load Balancer is for routing traffic through third-party virtual appliances (firewalls, intrusion detection systems). Not for general application load balancing.

---

### Q8. A company's web application experiences a massive traffic spike every Friday evening. They want to automatically add capacity before the spike occurs. Which Auto Scaling strategy should be used?

- A. Target Tracking Scaling
- B. Simple Scaling
- C. Scheduled Scaling
- D. Manual Scaling

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> **Scheduled Scaling** is designed exactly for predictable, time-based traffic patterns. You configure rules like "every Friday at 5 PM, increase minimum capacity to 20 instances." The scaling action happens **before** the traffic arrives, ensuring capacity is ready. This is proactive scaling based on a known schedule.
>
> **Why each wrong answer fails:**
> - **A** — Target Tracking Scaling is reactive — it responds to current metrics (like CPU at 70%). It works for general load management but can't proactively scale before a known event.
> - **B** — Simple/Step Scaling is also reactive — it fires when a CloudWatch Alarm triggers. Again, it responds to load rather than predicting it.
> - **D** — Manual Scaling requires a human to go in and change the desired capacity manually. It cannot be automated to happen at a specific time.

---

### Q9. A startup needs EC2 instances for a large batch data processing job that will run for 6 hours. The job can be interrupted and restarted if needed. What is the MOST cost-effective purchasing option?

- A. On-Demand Instances
- B. Reserved Instances (1-year)
- C. Spot Instances
- D. Dedicated Hosts

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> This scenario has three key signals: **short-term** (6 hours), **fault-tolerant** (can be interrupted and restarted), and **cost-sensitive** (startup). Spot Instances deliver up to **90% discount** compared to On-Demand and are perfect for exactly this — batch processing jobs that can handle interruption. If a Spot Instance gets terminated, the job simply resumes from where it stopped (with proper checkpointing).
>
> **Why each wrong answer fails:**
> - **A** — On-Demand works but is significantly more expensive than Spot for this use case. You're paying full price for something that could cost 90% less.
> - **B** — Reserved Instances require 1 or 3 year commitments and are for **continuously running** workloads, not occasional 6-hour jobs. Buying a 1-year RI for a 6-hour job is wasteful.
> - **D** — Dedicated Hosts are the most expensive option and are for compliance/licensing needs. Completely wrong fit for a cost-sensitive batch job.

---

### Q10. What is the DEFAULT behavior of an EC2 instance's Security Group regarding inbound and outbound traffic?

- A. All inbound allowed, all outbound blocked
- B. All inbound blocked, all outbound allowed
- C. All inbound and outbound traffic is blocked
- D. All inbound and outbound traffic is allowed

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> Security Groups follow a **default-deny for inbound, default-allow for outbound** model. When you create a new Security Group with no custom rules:
> - **Inbound:** All traffic is blocked by default. Nothing can reach your instance unless you explicitly create an Allow rule.
> - **Outbound:** All traffic is allowed by default. Your instance can reach out to the internet, other AWS services, or anything else without restriction.
>
> This makes sense from a security standpoint — you should explicitly decide what's allowed IN to your instance, while your instance should generally be free to make outbound connections (to download updates, call APIs, etc.).
>
> **Why each wrong answer fails:**
> - **A** — This is the opposite of the correct answer. Open inbound + blocked outbound would be extremely unusual and insecure.
> - **C** — If all traffic were blocked both ways, the instance would be completely isolated. This is not the default.
> - **D** — If all traffic were allowed both ways, every EC2 instance would be completely open to the internet by default. This would be a massive security hole.

---

### Q11. A company is building an AMI for their application servers. They want the AMI creation process to be automated, tested, and distributed to multiple regions on a weekly schedule. Which service handles this?

- A. AWS CloudFormation
- B. EC2 Auto Scaling
- C. EC2 Image Builder
- D. AWS Systems Manager

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> **EC2 Image Builder** is the purpose-built service for automating the entire AMI lifecycle: (1) Launch a builder instance, (2) Apply build components (install software, apply patches), (3) Run automated tests on the resulting image, (4) Distribute the validated AMI to multiple regions. It can run on a schedule (weekly, triggered by package updates, etc.). The service itself is free — you only pay for the EC2 instances and storage used during the build process.
>
> **Why each wrong answer fails:**
> - **A** — CloudFormation is Infrastructure as Code — it deploys and manages AWS resources (like EC2 instances from existing AMIs). It doesn't automate the creation of the AMI images themselves.
> - **B** — EC2 Auto Scaling manages the number of running instances based on load. It has nothing to do with building or distributing AMIs.
> - **D** — AWS Systems Manager can patch running instances and manage configuration, but it is not designed to automate the creation, testing, and multi-region distribution of AMI images.

---

### Q12. What is the key difference between Vertical Scaling and Horizontal Scaling in EC2?

- A. Vertical scaling adds more instances; horizontal scaling increases instance size
- B. Vertical scaling increases the size of one instance; horizontal scaling adds more instances
- C. Vertical scaling is unlimited; horizontal scaling has a hard limit of 10 instances
- D. Vertical scaling requires a Load Balancer; horizontal scaling does not

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> **Vertical Scaling (Scale Up/Down):** You increase the power of the **existing instance** — upgrade from `t2.micro` to `t2.xlarge` to `r5.4xlarge`. More CPU, more RAM, same instance. Has a hard physical limit (the biggest instance type available). Requires stopping the instance to resize it.
>
> **Horizontal Scaling (Scale Out/In):** You add **more instances** running the same application. From 1 instance to 5 to 20. No theoretical limit. Works with distributed systems and Load Balancers. This is the cloud-native approach and what Auto Scaling Groups implement.
>
> **Why each wrong answer fails:**
> - **A** — This is the exact opposite of the correct definitions. A classic trick answer.
> - **C** — Vertical scaling has a limit (largest instance type available). Horizontal scaling can scale to thousands of instances — there's no "10 instance limit."
> - **D** — It's actually the opposite — **Horizontal** scaling is what works with Load Balancers (distributing traffic across multiple instances). Vertical scaling doesn't need a Load Balancer since it's just one bigger instance.

---

*القسم الجاي: **Amazon S3** — التخزين الأشمل والأرخص في AWS وإيه اللي بيخليه مختلف عن كل حاجة تانية.*
