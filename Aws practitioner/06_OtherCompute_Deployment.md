# 🐳 Other Compute + 🚀 Deploying & Managing Infrastructure at Scale
**AWS Certified Cloud Practitioner — CLF-C02**
*Elite Egyptian AWS Cloud Architect & Mentor | Stephane Maarek Slides v42 — Sections 10 & 11*

---

## 🐳 Section 10 — Other Compute Services

---

### Docker & Containers — المفهوم الأساسي

#### 1. The Naive Approach (The Problem):

كل Developer عنده المشكلة الكلاسيكية: "عندي شغّال على الـ Laptop بتاعي ومش شغّال على الـ Server!" السبب؟ الـ Dependencies، الـ OS Version، الـ Libraries — كلها مختلفة بين الـ Machines. الـ Docker جاي يحل ده بفكرة بسيطة: لمّ كل حاجة جوه حاجة واحدة.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Docker vs Virtual Machines
>
> الـ **Docker** هو Platform لـ Packaging وتشغيل الـ Applications كـ **Containers** — وحدات خفيفة وقابلة للنقل بتحتوي على الـ Code وكل الـ Dependencies بتاعته.
>
> **Docker Container vs Virtual Machine:**
>
> | | Virtual Machine (VM) | Docker Container |
> |---|---|---|
> | **الحجم** | GBs | MBs |
> | **Startup** | دقائق | ثوانٍ |
> | **OS** | كل VM عنده Guest OS كامل | بيشاركوا الـ Host OS Kernel |
> | **Isolation** | كاملة (Hypervisor) | أقل عزلاً لكن كافية |
> | **Resources** | Dedicated | Shared مع الـ Host |
>
> **VMs:** الـ Hypervisor بيشغّل Guest OS كامل لكل VM — ده بياكل Resources كتير.
> **Containers:** الـ Docker Daemon بيشارك الـ Host OS Kernel — أخف بكتير وأسرع.
>
> **Docker Images والـ Registries:**
> الـ Docker Image هو الـ Template الجاهز للـ Container. بيتخزّن في:
> - **Docker Hub** (Public): مجاني، فيه Images جاهزة لـ Ubuntu، MySQL، Node.js، Java...
> - **Amazon ECR (Elastic Container Registry)**: Private Docker Registry على AWS — بتحط فيه Images بتاعتك عشان ECS أو Fargate يشغّلها.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ Docker Container زي **الـ Meal Kit** بتاع الطعام — زي HelloFresh أو طلبات. بدل ما الطباخ يبحث عن المكونات في أكتر من دكان، الـ Box وصله جاهز فيها: الدجاجة، البهارات، الخضار — كل حاجة بالكميات الصح.

الطباخ (Server) بيستقبل الـ Box (Container) ويطبخها بنفس النتيجة في أي مطبخ (Any Machine) في العالم — مش هيختلف الطعم حسب المطبخ.

الـ ECR ده **مخزن الـ Boxes** الخاص بالشركة — بدل ما تبعتها لـ Docker Hub العام، بتحطها في مخزنك الخاص الآمن.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Docker
>
> - **ECR = Private Docker Registry على AWS.** مش Docker Hub.
> - **Containers أخف من VMs** — بيشاركوا الـ Host OS. VMs = Full Guest OS.
> - **Docker Images بتتخزّن في Registries** — ECR (Private) أو Docker Hub (Public).

---

### ECS — Elastic Container Service

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — ECS
>
> الـ **ECS (Elastic Container Service)** هو الـ AWS Service لتشغيل Docker Containers على AWS.
>
> **طريقة الشغل:**
> - إنت بتـ **Provision وتدير الـ EC2 Instances** (الـ Underlying Infrastructure)
> - الـ ECS بيتولى **تشغيل ووقف الـ Containers** عليهم
> - الـ ECS بيعمل **Integration مع ALB** (Application Load Balancer) تلقائياً لتوزيع الـ Traffic على الـ Containers
>
> **الـ Responsibility Split:**
> - إنت مسؤول عن: EC2 Instances (الـ Sizing، الـ Patching، الـ Count)
> - AWS (ECS) مسؤولة عن: Container Placement، Scaling الـ Containers، Health Checks

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — ECS
>
> - **ECS = You manage EC2 Instances.** مش Serverless.
> - **ECS + ALB** = Standard Architecture للـ Containerized Web Apps.
> - **ECS vs Fargate:** ECS = بتدير EC2. Fargate = مش بتدير حاجة.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Type** | Managed Container Orchestration |
| **Infrastructure** | إنت بتدير EC2 Instances |
| **Container Management** | AWS (ECS) |
| **Load Balancer** | Integrates with ALB |
| **Serverless?** | ❌ لا |

---

### Fargate — Serverless Containers

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Fargate
>
> الـ **Fargate** بيشغّل Docker Containers على AWS بدون أي Infrastructure Management من جانبك.
>
> - **لا EC2 Instances لازم تدير.** AWS بتعمل ده كله.
> - **Serverless Offering** — بتحدد CPU وRAM المطلوبين للـ Container، وAWS بتشغّله.
> - بتدفع على الـ vCPU وMemory اللي الـ Container استخدمه فعلاً.
>
> **Fargate vs ECS:**
> | | ECS | Fargate |
> |---|---|---|
> | **EC2 Instances** | إنت بتـ Provision | AWS بتـ Manage |
> | **Serverless** | ❌ | ✅ |
> | **Complexity** | أعلى | أقل |
> | **Control** | أعلى | أقل |
> | **Use Case** | عايز تتحكم في الـ Infra | عايز تركّز على الـ Code بس |

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Fargate
>
> - **Fargate = Serverless Containers.** ده الـ Keyword المباشر.
> - **Fargate مش بتدير EC2.** لو الـ Exam سأل "run containers without managing servers" → Fargate.
> - **Fargate يشتغل مع ECS وكمان EKS** — مش ECS وحده.

---

### Amazon EKS — Elastic Kubernetes Service

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — EKS
>
> الـ **EKS (Elastic Kubernetes Service)** بيخليك تشغّل **Managed Kubernetes Clusters** على AWS.
>
> **إيه هو الـ Kubernetes؟**
> الـ **Kubernetes** هو Open-Source System لإدارة وتوزيع وـ Scaling الـ Containerized Applications. مطوّر من Google. الـ Kubernetes بيدير مجموعة من الـ Containers (بيسميهم **Pods**) على مجموعة من الـ Servers (بيسميهم **Nodes**).
>
> **EKS Architecture:**
> - **EKS Nodes:** EC2 Instances أو Fargate (Serverless)
> - **EKS Pods:** مجموعة من الـ Containers بتشتغل مع بعض
> - الـ EKS بيدير الـ Control Plane (الـ Kubernetes Master) — إنت بتدير الـ Worker Nodes
>
> **ليه EKS وليس ECS؟**
> - **Kubernetes = Cloud-Agnostic** — لو عندك Workloads شغّالة على Kubernetes On-Premise أو على GCP/Azure، ممكن تنقلها لـ AWS بسهولة مع EKS
> - الـ ECS مرتبط بـ AWS فقط
>
> **ECS vs EKS:**
> | | ECS | EKS |
> |---|---|---|
> | **Orchestration** | AWS Proprietary | Kubernetes (Open-Source) |
> | **Cloud Lock-in** | AWS Only | Cloud-Agnostic |
> | **Complexity** | أبسط | أعقد |
> | **Use Case** | AWS-native Workloads | Multi-cloud أو K8s Migration |

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — EKS
>
> - **EKS = Kubernetes على AWS.** لو الـ Exam قال "Kubernetes" → EKS.
> - **Kubernetes = Cloud-Agnostic.** ECS مش Cloud-Agnostic.
> - **EKS Nodes = EC2 أو Fargate.** ممكن تختار.
> - الـ CCP مش محتاج تعرف تفاصيل الـ Kubernetes — بس تعرف إن EKS = Managed Kubernetes.

---

### AWS Lambda — Serverless Functions

#### 1. The Naive Approach (The Problem):

عندك Function بسيطة — مثلاً: "لما يتـ Upload صورة لـ S3، اعمل لها Thumbnail." هتشغّل EC2 Instance 24/7 عشان تستنى الـ Event ده؟ ده تبذير. الـ Lambda بيخليك تكتب الـ Function وتنساها — بتشتغل بس لما يحصل الـ Event.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — AWS Lambda
>
> الـ **AWS Lambda** هو **Serverless Compute Service** بيشغّل Code استجابةً لـ Events. مش في Server بتديره — بس بتكتب الـ Function وبتحدد ما الذي يُشغّلها.
>
> **EC2 vs Lambda:**
>
> | | EC2 | Lambda |
> |---|---|---|
> | **Infrastructure** | Virtual Server — بتديره | لا يوجد — Serverless |
> | **Running** | Continuously (حتى لو مفيش Load) | On-Demand (بس لما في Event) |
> | **Scaling** | يدوي أو ASG | Automatic (فوري) |
> | **Time Limit** | لا يوجد | **Max 15 دقيقة** per Invocation |
> | **RAM Limit** | حسب Instance Type | حتى **10 GB RAM** |
>
> **التسعير:**
> - **Pay per Request:** أول 1,000,000 Request شهرياً = **مجاني**. بعدها $0.20 per million.
> - **Pay per Duration:** أول 400,000 GB-seconds شهرياً = **مجاني**. بعدها $1.00 per 600,000 GB-seconds.
> - **نتيجة:** Lambda رخيصة جداً للـ Workloads الـ Event-Driven.
>
> **اللغات المدعومة:**
> Node.js، Python، Java، C# (.NET Core)، PowerShell، Ruby، Custom Runtime API (Rust، Golang)، Lambda Container Image (لكن لازم يـ Implement Lambda Runtime API).
>
> **Use Cases العملية:**
>
> **① Serverless Thumbnail Creation:**
> ```
> User uploads image → S3 Bucket (Trigger)
>         ↓
>  Lambda Function (Creates Thumbnail)
>         ↓                    ↓
>  New Thumbnail in S3    Metadata in DynamoDB
>                         (image name, size, date)
> ```
>
> **② Serverless CRON Job:**
> ```
> CloudWatch Events / EventBridge (Trigger every 1 hour)
>         ↓
>  Lambda Function (Perform a task)
> ```
> بدل ما تشغّل EC2 Instance عشان يعمل Task كل ساعة — Lambda بتشتغل ثوانٍ، تنهي الـ Task، وتوقف. بتدفع على الثوانٍ دي بس.
>
> **الـ RAM وCPU:**
> زيادة الـ RAM بتزوّد الـ CPU والـ Network تلقائياً — مفيش إعداد منفصل للـ CPU في Lambda.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ EC2 زي **موظف بـ Salary ثابت** — بتدفعله من الصبح للآخر حتى لو قاعد مش شغّال. الـ Lambda زي **Freelancer** — بتدفعه بس لما بيشتغل. جاله Request، اشتغل 2 ثانية، اتدفعت على الـ 2 ثانية دول بس.

الـ CRON Job بالـ Lambda زي بالظبط **مخبّز أوتوماتيكي** — بيحضر الخبز كل يوم الساعة 6 الصبح، وبعدين يقفل لوحده. مش شغّال 24 ساعة يستنى.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Lambda
>
> - **Lambda Max Execution Time = 15 دقيقة (900 seconds).** لو الـ Task تاخد أكتر → مش مناسب لـ Lambda → استخدم EC2 أو Batch.
> - **Lambda Scaling = Automatic.** مش محتاج ASG.
> - **Lambda Billing = Per Request + Per Duration.** مش Per Hour.
> - **Max RAM = 10 GB.** زيادة الـ RAM = زيادة الـ CPU تلقائياً.
> - **Lambda = Serverless.** مش بتدير Infrastructure.
> - **Free Tier:** 1M Requests/Month + 400,000 GB-seconds/Month مجاناً.
> - **Lambda Container Image** مدعوم لكن لازم يـ Implement Lambda Runtime API — مش أي Docker Image.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Type** | Serverless Function (FaaS) |
| **Max Time** | 15 دقيقة per Invocation |
| **Max RAM** | 10 GB |
| **Scaling** | Automatic |
| **Billing** | Per Request + Per Duration |
| **Free Tier** | 1M Requests + 400K GB-sec/Month |
| **Trigger** | S3, DynamoDB, API Gateway, EventBridge, etc. |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q1
> **A company needs to process images uploaded to S3. Each processing task takes 8 minutes and runs only when a new image is uploaded. Which compute option is MOST cost-effective?**
>
> - A. EC2 On-Demand Instance running 24/7 to monitor S3 for new uploads
> - B. AWS Lambda triggered by S3 events, with a 10-minute timeout configured
> - C. AWS Batch triggered by S3 events, running on Spot Instances
> - D. Amazon ECS running a container that polls S3 every minute

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B — AWS Lambda**
>
> 8 minutes is well within Lambda's 15-minute maximum. Lambda is triggered directly by S3 events (zero polling overhead), runs only when needed, and costs only for the 8 minutes of compute. This is exactly the event-driven, pay-per-use model Lambda is designed for.
>
> **Why A is wrong:** Running EC2 24/7 means paying for idle time constantly — extremely wasteful for a workload that only runs when an image is uploaded.
> **Why C is partially valid but not "most cost-effective" here:** Batch is for large-scale batch jobs with no time limit, often hundreds/thousands of concurrent jobs. For a single triggered 8-minute task, Lambda is simpler and cheaper.
> **Why D is wrong:** Polling every minute wastes compute. Lambda's event-driven trigger is more efficient and cheaper.

---

### Amazon API Gateway

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — API Gateway
>
> الـ **API Gateway** هو Fully Managed Service لبناء وـ Publishing وـ Securing وـ Monitoring الـ APIs.
>
> **الـ Classic Serverless Architecture:**
> ```
> Client → REST API → API Gateway → Lambda Function → DynamoDB
>                     (CRUD Operations)
> ```
>
> الـ API Gateway بيعمل:
> - **Proxy Requests** من الـ Clients للـ Backend (Lambda وغيره)
> - **Security:** Authentication، Authorization، API Keys
> - **Throttling:** منع الـ Abuse بتحديد عدد الـ Requests
> - **Monitoring:** عبر CloudWatch
> - بيدعم **RESTful APIs** وـ **WebSocket APIs**
> - **Serverless and Scalable** — مش في Infrastructure تديره

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — API Gateway
>
> - **"Expose Lambda as HTTP API" = API Gateway.** ده الـ Use Case الرئيسي.
> - **API Gateway = Serverless.** مش بتدير Servers.
> - الـ Full Serverless Stack: API Gateway + Lambda + DynamoDB.

---

### AWS Batch

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — AWS Batch
>
> الـ **AWS Batch** هو Fully Managed Service لتشغيل **Batch Jobs** على نطاق واسع.
>
> **إيه هو الـ Batch Job؟**
> Job بيبدأ وبينتهي (مش Continuous) — معالجة ملفات، تحويل صور، تحليل Data.
>
> **كيف يشتغل:**
> - بتـ Submit الـ Batch Jobs
> - AWS Batch بيشوّل دينامكياً **EC2 Instances أو Spot Instances** حسب الحاجة
> - الـ Jobs بتتعرّف كـ **Docker Images** وبتشتغل على ECS
> - لما الـ Jobs تخلص، الـ Instances بتتحذف
>
> **Batch vs Lambda:**
>
> | | Lambda | Batch |
> |---|---|---|
> | **Time Limit** | Max 15 دقيقة | **لا يوجد حد** |
> | **Runtimes** | محدود (Node, Python, Java...) | Any Runtime (Docker Image) |
> | **Storage** | محدود Temp Disk | EBS / Instance Store |
> | **Serverless** | ✅ | ❌ (Relies on EC2) |
> | **Use Case** | Short Event-Driven Tasks | Long Heavy Processing Jobs |
>
> **Example Architecture:**
> ```
> Amazon S3 (New Object) → Trigger → AWS Batch
>         ↓ (Spins up EC2/Spot Instances)
>   Docker Container (Processes Object)
>         ↓
>   Amazon S3 (Processed Output)
> ```

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Batch
>
> - **Batch = No Time Limit.** لو الـ Task أطول من 15 دقيقة → Batch مش Lambda.
> - **Batch Jobs = Docker Images على ECS.**
> - **Batch بيستخدم EC2/Spot Instances** — مش Serverless خالص.
> - **Spot Instances مع Batch** = Cost Optimization للـ Long Batch Jobs.

---

### Amazon Lightsail

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Lightsail
>
> الـ **Amazon Lightsail** هو "All-in-one" Cloud Platform بسعر ثابت ومنخفض — Virtual Servers + Storage + Databases + Networking في حزمة واحدة بسيطة.
>
> **الفكرة:** AWS بتكون معقدة للمبتدئين. Lightsail بيوفر تجربة مبسّطة شبه Digital Ocean أو Heroku.
>
> **الـ Features:**
> - Templates جاهزة: LAMP، MEAN، Node.js، WordPress، Magento، Joomla، Plesk
> - Pricing ثابت ومتوقع — مش مفاجآت في الفاتورة
> - Notifications وMonitoring مدمجين
>
> **القيود:**
> - **High Availability لكن لا يوجد Auto-Scaling**
> - **Limited AWS Integrations** — مش بيتكامل بسهولة مع باقي الـ AWS Services
>
> **Use Cases:**
> - Simple Web Applications
> - WordPress، Magento Websites
> - Dev/Test Environments
> - ناس عندها خبرة قليلة في الـ Cloud

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Lightsail
>
> - **Lightsail = Simple + Low Cost + Beginners.** لو الـ Exam سأل "simplest way to deploy a WordPress site on AWS" → Lightsail.
> - **Lightsail = No Auto-Scaling.** ده الـ Limitation الأساسي.
> - **Lightsail = Limited AWS Integrations.**

---

### Other Compute — Section Summary

| Service | الـ Type | من بيدير الـ Infrastructure | الـ Use Case |
|---|---|---|---|
| **ECS** | Container Orchestration | إنت (EC2 Instances) | Run Docker على EC2 |
| **Fargate** | Serverless Containers | AWS | Run Docker بدون EC2 |
| **ECR** | Container Registry | AWS | Store Private Docker Images |
| **EKS** | Managed Kubernetes | إنت (EC2/Fargate) | Kubernetes على AWS |
| **Lambda** | Serverless Functions | AWS | Event-Driven Short Tasks (max 15 min) |
| **API Gateway** | Managed API | AWS | Expose Lambda as HTTP API |
| **Batch** | Batch Jobs | AWS (EC2/Spot) | Long Heavy Jobs (No Time Limit) |
| **Lightsail** | Simple VPS | AWS | Beginners، Simple Sites |

---

---

## 🚀 Section 11 — Deploying & Managing Infrastructure at Scale

---

### AWS CloudFormation — Infrastructure as Code

#### 1. The Naive Approach (The Problem):

كل مرة بتعمل Environment جديد (Dev، Staging، Production) — بتروح الـ Console، بتعمل Security Group، بتعمل EC2 Instances، بتعمل S3 Bucket، بتعمل Load Balancer — يدوياً. لو نسيت خطوة أو غلطت في Setting، الـ Environments هتكون مختلفة عن بعض. والأسوأ: مش في Documentation مكتوبة لما عملت إيه بالظبط. الـ CloudFormation بيحل كل ده.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — CloudFormation
>
> الـ **CloudFormation** هو الـ **Infrastructure as Code (IaC)** Service في AWS. بتكتب Template (بصيغة JSON أو YAML) بيوصف الـ Infrastructure المطلوبة، وCloudFormation بيبنيها لك بالترتيب الصح.
>
> **مثال على Template:**
> "عايز:
> - Security Group بيسمح بـ HTTP
> - Instance EC2 بيستخدم الـ Security Group ده
> - S3 Bucket
> - ELB قدام الـ EC2 Instances"
>
> CloudFormation بيعمل كل ده تلقائياً بالترتيب الصح — عارف إن الـ Security Group لازم يتعمل قبل الـ EC2.
>
> **فوايد CloudFormation:**
>
> **① Infrastructure as Code:**
> - مفيش Resources بتتعمل يدوياً → كل حاجة في Code
> - التغييرات على الـ Infrastructure بتتراجع في الـ Code Review
> - الـ Infrastructure Version-Controlled (في Git)
>
> **② Cost Management:**
> - كل Resource في الـ Stack بيتـ Tag تلقائياً بـ Identifier
> - تقدر تعمل **Cost Estimation** من الـ Template نفسها قبل ما تبني حاجة
> - **Savings Strategy:** في Dev — اعمل Automation تـ Delete الـ Stack الساعة 5 PM وتـ Recreate الساعة 8 AM. الـ Developers مش شغّالين الليل — ليه تدفع؟
>
> **③ Productivity:**
> - Destroy وRecreate Infrastructure بسرعة من غير جهد
> - Automated Diagram Generation للـ Template
> - **Declarative Programming** — بتقول "عايز إيه" مش "كيف تعمله". CloudFormation بيحسب الـ Order والـ Orchestration.
>
> **④ Reusability:**
> - نفس الـ Template بتشتغل في أي Region وأي Account
> - بتـ Reuse Templates جاهزة من الـ Community
>
> **CloudFormation Stack:**
> مجموعة الـ Resources اللي اتبنت من Template واحدة بتسمى **Stack**. بتعمل Update للـ Stack لما تغيّر الـ Template، وCloudFormation بيعمل الـ Change Set اللازم.
>
> **CloudFormation + Infrastructure Composer:**
> Visual Tool بيعرضلك الـ CloudFormation Stack كـ Diagram تفاعلي — بتشوف كل الـ Resources والعلاقات بينهم.

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ CloudFormation زي **بلان المبنى الهندسي (Blueprint)**. بدل ما تبني عمارة حجرة حجرة يدوياً — بتدي المقاول (AWS) البلان، وهو بيبني كل حاجة بالترتيب الصح.

الفرق الأهم: لو عندك 5 بيئات (Dev، Staging، UAT، Pre-Prod، Production) — مش هتبني 5 عمارات يدوياً. بتدي كل مقاول نفس البلان، وكل العمارات هتكون متطابقة تماماً.

**Cost Strategy** زي إنك عندك مكاتب بتفتحها الصبح وتقفلها بالليل — بتدفع الإيجار بالساعة بس.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — CloudFormation
>
> - **CloudFormation = IaC = Declarative.** بتقول "عايز إيه" مش "كيف تعمله."
> - **CloudFormation = Repeat across Regions & Accounts** بنفس الـ Template.
> - **Supports Almost All AWS Resources.** للـ Unsupported Resources → Custom Resources.
> - **Stack = Group of Resources من نفس الـ Template.**
> - **Infrastructure Composer** = Visual Diagram للـ Stack — مش CloudFormation نفسه.
> - **CloudFormation مجاني** — بتدفع على الـ Resources اللي بيبنيها بس.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Type** | Infrastructure as Code (IaC) |
| **Format** | JSON أو YAML |
| **Paradigm** | Declarative (مش Imperative) |
| **Multi-Region** | ✅ نفس الـ Template في أي Region |
| **Cost** | Free (بتدفع على الـ Resources) |
| **Stack** | Group of Resources من Template واحدة |
| **Tag Strategy** | كل Resource بيتـ Tag تلقائياً |

---

### AWS CDK — Cloud Development Kit

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — CDK
>
> الـ **CDK (Cloud Development Kit)** بيخليك تكتب الـ Infrastructure بلغة Programming حقيقية بدل YAML/JSON.
>
> **اللغات المدعومة:**
> JavaScript/TypeScript، Python، Java، .NET
>
> **كيف يشتغل:**
> ```
> CDK Application (Python/TypeScript/Java)
>         ↓ (CDK CLI يحوّله)
>   CloudFormation Template (JSON/YAML)
>         ↓ (CloudFormation ينفّذه)
>   Actual AWS Resources
> ```
>
> **الميزة الرئيسية:**
> تقدر تكتب Infrastructure وApplication Code في نفس الـ Codebase وتـ Deploy الاتنين مع بعض — ممتاز لـ Lambda Functions وDocker Containers في ECS/EKS.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — CDK
>
> - **CDK = Code بيتحوّل لـ CloudFormation.** المخرج النهائي دايماً CloudFormation Template.
> - **CDK = Familiar Programming Languages** — Python، TypeScript، Java، .NET.
> - **CDK vs CloudFormation:** CDK = Code بلغات برمجة. CloudFormation = YAML/JSON مباشرة.

---

### AWS Elastic Beanstalk — PaaS

#### 1. The Naive Approach (The Problem):

الـ Developer عايز يـ Deploy الـ Code بتاعه على AWS. مش عايز يهتم بـ EC2 وASG وELB وRDS وكيف يحطهم مع بعض. عايز: "هاهوا الـ Code، اشغّله." ده بالظبط الـ Elastic Beanstalk.

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — Elastic Beanstalk
>
> الـ **Elastic Beanstalk** هو **PaaS (Platform as a Service)** — بتـ Upload الـ Code وBeanstalk بيـ Handle كل حاجة تانية.
>
> **ما بيعمله Beanstalk تلقائياً:**
> - Instance Configuration وOS Management
> - Deployment Strategy
> - Capacity Provisioning
> - Load Balancing وAuto-Scaling
> - Application Health Monitoring
>
> **مسؤولية الـ Developer:**
> **Application Code فقط.** بس كده.
>
> **3 Architecture Models:**
> 1. **Single Instance:** للـ Development
> 2. **LB + ASG:** للـ Production وPre-Production Web Apps
> 3. **ASG Only:** للـ Non-Web Apps (Workers، Background Jobs)
>
> **اللغات المدعومة:**
> Go، Java SE، Java with Tomcat، .NET on IIS، Node.js، PHP، Python، Ruby، Packer Builder، Single/Multi-Container Docker، Preconfigured Docker
>
> **Beanstalk = Free (PaaS):**
> الـ Service نفسها مجانية — بتدفع على الـ EC2، RDS، ELB، وغيرها من الـ Underlying Resources.
>
> **الـ Health Monitoring:**
> Beanstalk عنده Health Agent على كل Instance بيـ Push Metrics لـ CloudWatch ويعمل Health Events.

#### 3. The Mentor's Story (The "Ashta" Analogy):

CloudFormation زي **بلان المبنى الهندسي** — إنت بتصمم كل حاجة. Elastic Beanstalk زي **Turnkey Contract (تسليم مفتاح)** — إنت بتعطي الـ Developer Code فقط وتقوله "اللي بناه لي مناسب للـ Web App"، والشركة تبني المبنى المناسب من غير ما تقلق في التفاصيل.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Elastic Beanstalk
>
> - **Beanstalk = PaaS.** EC2 = IaaS. Lambda = FaaS/Serverless.
> - **Beanstalk = Free.** بتدفع على الـ Underlying Resources بس.
> - **Developer Responsibility = Code Only.** Infrastructure = Beanstalk.
> - **Beanstalk بيستخدم EC2، ASG، ELB، RDS** تحت الغطاء — مش Service منفصلة.
> - **Full Control** على الـ Configuration لسه موجود — مش Black Box.

#### 5. The "Zatouna" Table:

| Concept | القيمة |
|---|---|
| **Type** | PaaS — Platform as a Service |
| **Developer Responsibility** | Application Code فقط |
| **Infrastructure** | Managed by Beanstalk |
| **Cost** | Free (بتدفع على Underlying Resources) |
| **Architectures** | Single Instance / LB+ASG / ASG-only |
| **Health Monitoring** | CloudWatch Integration |

---

### Developer Tools — CodeDeploy, CodeCommit, CodeBuild, CodePipeline, CodeArtifact

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — AWS Developer Tools Suite
>
> AWS بتوفر مجموعة متكاملة من الـ Developer Tools للـ CI/CD Pipeline:
>
> **① AWS CodeCommit — Git Repository:**
> - Source-control Service بيـ Host **Git-based Repositories** على AWS
> - المنافس المباشر لـ GitHub — لكن Private وIntegrated مع AWS
> - Fully Managed، Scalable، Highly Available
> - **Secured وPrivate** — بيتكامل مع IAM
>
> **② AWS CodeBuild — Build Service:**
> - بيـ Compile الـ Source Code + يشغّل الـ Tests + ينتج الـ Artifacts الجاهزة للـ Deploy
> - Fully Managed + Serverless
> - Pay-as-you-go: بتدفع على الـ Build Time فقط
>
> **③ AWS CodeDeploy — Deployment Service:**
> - بيـ Deploy الـ Application تلقائياً على EC2 Instances وOn-Premises Servers
> - **Hybrid Service** — يشتغل مع AWS وOn-Premise
> - الـ Servers لازم يكون عليهم **CodeDeploy Agent** مثبّت مسبقاً
>
> **④ AWS CodePipeline — CI/CD Orchestration:**
> - بيـ Orchestrate الـ Pipeline كلها: Code → Build → Test → Provision → Deploy
> - الـ Basis للـ **CI/CD (Continuous Integration & Continuous Delivery)**
> - بيتكامل مع: CodeCommit، CodeBuild، CodeDeploy، Elastic Beanstalk، CloudFormation، GitHub، وغيرها
>
> **الـ Full CI/CD Pipeline:**
> ```
> CodeCommit (Code) → CodeBuild (Build+Test) → CodeDeploy (Deploy) → Elastic Beanstalk
>     \_________________________CodePipeline Orchestration_________________________/
> ```
>
> **⑤ AWS CodeArtifact — Artifact Management:**
> - Secure، Scalable، Cost-effective Artifact Management
> - بيخزّن الـ Software Dependencies (Packages) على AWS
> - بيشتغل مع: Maven، Gradle، npm، yarn، pip، twine، NuGet
> - الـ Developers وCodeBuild بيسحبوا الـ Dependencies منه مباشرة

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — Developer Tools
>
> - **CodeCommit = AWS's GitHub.** Git-based Repository.
> - **CodeBuild = Compile + Test + Package.** Serverless، Pay per Build Time.
> - **CodeDeploy = Hybrid** — يشتغل مع EC2 وOn-Premise. **لازم CodeDeploy Agent**.
> - **CodePipeline = CI/CD Orchestration** — مش هو اللي بيعمل الـ Deploy، هو بيـ Coordinate الكل.
> - **CodeArtifact = Package/Dependency Management.** مش Code Repository.
> - **CDK = Infrastructure Code بلغات برمجة → CloudFormation.**

#### 5. The "Zatouna" Table:

| Service | الوظيفة | الـ Keyword |
|---|---|---|
| **CodeCommit** | Git Repository | "private git", "code repository" |
| **CodeBuild** | Build + Test + Package | "build code", "compile", "test" |
| **CodeDeploy** | Deploy to EC2/On-Premise | "deploy code", "hybrid", "agent" |
| **CodePipeline** | CI/CD Orchestration | "CI/CD pipeline", "orchestrate" |
| **CodeArtifact** | Dependency Management | "packages", "dependencies", "npm", "pip" |
| **CDK** | IaC بلغات برمجة | "Python/TypeScript infrastructure" |

---

### AWS Systems Manager (SSM)

#### 2. The Deep Dive:

> [!DEEP-DIVE] Technical Mechanics — SSM
>
> الـ **AWS Systems Manager (SSM)** هو Suite من الأدوات لإدارة الـ EC2 Instances والـ On-Premises Servers على نطاق واسع.
>
> **Hybrid Service** — بيشتغل مع AWS وOn-Premise.
>
> **كيف يشتغل:**
> - لازم تثبّت الـ **SSM Agent** على الـ Instances/Servers
> - الـ SSM Agent بيكون مثبّت **By Default** على Amazon Linux AMI وبعض Ubuntu AMIs
> - لو Instance مش قادر يتـ Controlled بـ SSM → الغالب المشكلة في الـ SSM Agent
>
> **أهم الـ Features:**
>
> **① Patching Automation:**
> بيعمل OS Patches على Fleet كامل من الـ Servers تلقائياً وبيضمن الـ Compliance.
>
> **② Run Commands:**
> بتشغّل Commands على مئات أو آلاف الـ Servers في نفس الوقت من غير SSH.
>
> **③ SSM Session Manager:**
> - بيفتح **Secure Shell** على الـ EC2 Instances وOn-Premises Servers
> - **مش محتاج SSH، Bastion Hosts، أو SSH Keys**
> - **مش محتاج Port 22 يكون مفتوح** ← ده أمان أعلى بكتير
> - بيدعم Linux، macOS، Windows
> - بيبعت الـ Session Logs لـ S3 أو CloudWatch Logs
>
> **④ SSM Parameter Store:**
> - Secure Storage للـ Configuration والـ Secrets (API Keys، Passwords، Config Values)
> - Serverless، Scalable، Durable
> - Control Access بـ IAM
> - Version Tracking + Encryption اختياري (عبر AWS KMS)

#### 3. The Mentor's Story (The "Ashta" Analogy):

الـ SSM Session Manager زي **Remote Control للـ TV من غير ما يكون فيه Infrared Receiver مكشوف.** بدل ما تفتح Port 22 (الـ IR Receiver) على الـ Firewall — الـ SSM Agent هو الـ Bridge الآمن من جوا، والتحكم بيجي من AWS Console من غير ما تفتح أي Port للعالم الخارجي.

الـ Parameter Store زي **خزنة الشركة للـ Passwords** — كل Application بتاخد الـ Password بتاعها من الخزنة عبر IAM بدل ما تكون مكتوبة hard-coded في الـ Code.

#### 4. The Exam Hacker:

> [!WARNING] Exam Traps — SSM
>
> - **SSM Session Manager = No SSH + No Port 22 + No Key Pairs.** ده بيتيح Secure Shell بطريقة أكثر أماناً.
> - **SSM = Hybrid Service** — EC2 وOn-Premise.
> - **SSM Agent لازم مثبّت** — By Default على Amazon Linux 2.
> - **SSM Parameter Store = Store Secrets/Config.** مش Database.
> - **Parameter Store vs Secrets Manager:** كلاهم لتخزين الـ Secrets — الـ Secrets Manager أكثر Feature-Rich ومدفوع. Parameter Store أبسط وجزء من SSM.

#### 5. The "Zatouna" Table:

| Feature | القيمة |
|---|---|
| **Type** | Hybrid Management Suite |
| **SSM Agent** | Required — Installed by Default on Amazon Linux 2 |
| **Session Manager** | Secure Shell — No SSH — No Port 22 — No Key Pairs |
| **Patching** | Automated OS Patching للـ Fleet |
| **Run Commands** | على آلاف الـ Servers في نفس الوقت |
| **Parameter Store** | Secure Config/Secrets Storage — Serverless |

#### 6. The Checkpoint:

> [!question]- 🧪 Test Your Knowledge — Q2
> **A security team wants to connect to EC2 instances for debugging without opening port 22 in any Security Group and without managing SSH key files. Which AWS service enables this?**
>
> - A. EC2 Instance Connect — browser-based SSH
> - B. AWS Systems Manager Session Manager
> - C. AWS CodeDeploy Agent
> - D. AWS CloudFormation StackSets

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B — SSM Session Manager**
>
> Session Manager provides secure shell access to EC2 instances with **zero port 22 exposure** and **no SSH key files**. It works through the SSM Agent already installed on the instance, communicating over HTTPS (port 443) to the SSM service. Sessions are logged to S3 or CloudWatch for audit.
>
> **Why A is wrong:** EC2 Instance Connect DOES require port 22 to be open in the Security Group. It creates a temporary key pair automatically, but port 22 must still be accessible. The question explicitly says "without opening port 22."
> **Why C is wrong:** CodeDeploy Agent is for application deployment, not for interactive shell access.
> **Why D is wrong:** CloudFormation StackSets is for deploying infrastructure across multiple accounts/regions, not for shell access.

---

### Deployment Section — Summary

| Service | الـ Type | الـ Use Case | الـ Keyword |
|---|---|---|---|
| **CloudFormation** | IaC — Declarative | Infrastructure as Code — Multi-Region | "infrastructure as code", "declare resources" |
| **CDK** | IaC — Code | Infrastructure بلغات برمجة → CloudFormation | "Python/TypeScript infrastructure" |
| **Elastic Beanstalk** | PaaS | Developer deploys Code — AWS manages rest | "PaaS", "deploy code not infrastructure" |
| **CodeCommit** | Git Repo | Private Git Repository | "git repository", "source control" |
| **CodeBuild** | Build Service | Compile + Test + Package | "build", "compile", "serverless build" |
| **CodeDeploy** | Deployment | Deploy to EC2/On-Premise (Hybrid) | "deploy", "hybrid", "agent required" |
| **CodePipeline** | CI/CD | Orchestrate Code→Build→Deploy | "CI/CD pipeline", "orchestration" |
| **CodeArtifact** | Artifact Mgmt | Store Dependencies (npm, pip, Maven) | "artifact", "packages", "dependencies" |
| **SSM** | Hybrid Mgmt | Patch + Run Commands + Session Manager | "hybrid management", "no SSH", "patch fleet" |
| **SSM Session Manager** | Secure Shell | Shell بدون Port 22 + بدون SSH Keys | "no port 22", "no SSH keys", "secure shell" |
| **SSM Parameter Store** | Config/Secrets | Store API Keys + Passwords + Config | "configuration store", "secrets", "parameter" |

---

## 🧪 Grand Quiz — Sections 10 & 11 Final Checkpoint

> [!question]- 🧪 Grand Quiz Q1 — شركة عايزة تشغّل Docker Containers على AWS بدون ما تدير أي EC2 Instances وبدون ما تعرف Kubernetes. أنهي Service؟
>
> - A. Amazon ECS with EC2 Launch Type
> - B. Amazon EKS with Fargate
> - C. AWS Fargate with ECS
> - D. AWS Batch

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — Fargate with ECS**
> "Docker Containers" + "No EC2 to manage" + "No Kubernetes" = Fargate مع ECS. الـ Fargate هو الـ Serverless Container Engine. EKS = Kubernetes (الـ Question قالت "without knowing Kubernetes"). Batch = Batch Jobs مش General Containers.

---

> [!question]- 🧪 Grand Quiz Q2 — Dev Team عايزة Environment جديد (Dev, Staging, Production) بنفس الإعدادات في أي وقت وفي أي Region. أنهي Service؟
>
> - A. AWS Elastic Beanstalk
> - B. AWS CloudFormation
> - C. AWS CodeDeploy
> - D. Amazon EC2 Manual Setup

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — CloudFormation**
> "Identical infrastructure" + "any Region" + "repeatable" = CloudFormation IaC. نفس الـ Template بتشغّلها في أي Region وبتطلع نفس الـ Infrastructure. Beanstalk ممكن لكن CloudFormation أقدر وأشمل للـ "أي Resources" وأي Region بدون قيود.

---

> [!question]- 🧪 Grand Quiz Q3 — شركة عندها 500 EC2 Linux Instance وعايزة تعمل OS Security Patching على كلهم بدون SSH لكل Instance. أنهي Service؟
>
> - A. AWS CodeDeploy
> - B. AWS Systems Manager (SSM) Patch Manager
> - C. AWS CloudFormation
> - D. AWS Elastic Beanstalk

> [!success]- ✅ Reveal Answer
> **Correct Answer: B — AWS Systems Manager (SSM)**
> "Patch fleet" + "No SSH" + "At Scale" = SSM Patch Manager. SSM Agent موجود على كل Instance، وتقدر تشغّل Patching على الـ 500 Instance في نفس الوقت من SSM Console بدون أي SSH. CodeDeploy = Application Deployment. CloudFormation = Infrastructure Provisioning. Beanstalk = Application Platform.

---

> [!question]- 🧪 Grand Quiz Q4 — مطلوب بناء CI/CD Pipeline كامل: Code مخزّن في AWS، بيتـ Compile وتشتغل عليه Tests، وبعدين بيتـ Deploy على EC2 Instances تلقائياً. أنهي Combination صح؟
>
> - A. GitHub + Jenkins + Ansible
> - B. CodeCommit + CodeBuild + CodeDeploy مع CodePipeline كـ Orchestrator
> - C. S3 + Lambda + CloudFormation
> - D. Elastic Beanstalk alone

> [!success]- ✅ Reveal Answer
> **Correct Answer: B**
> الـ AWS-native CI/CD Stack: CodeCommit (Store Code) + CodeBuild (Build + Test) + CodeDeploy (Deploy to EC2) + CodePipeline (Orchestrate كل ده). ده الـ Stack الكامل المتكامل اللي Stephane بيذكره.

---

> [!question]- 🧪 Grand Quiz Q5 — Developer عايزة تـ Deploy Web Application على AWS من غير ما تهتم بإدارة الـ Servers أو الـ Load Balancer أو الـ Auto Scaling. بتدفع على الـ Code بس. أنهي Service؟
>
> - A. Amazon EC2 + Manual Configuration
> - B. AWS CloudFormation
> - C. AWS Elastic Beanstalk
> - D. Amazon EKS

> [!success]- ✅ Reveal Answer
> **Correct Answer: C — Elastic Beanstalk**
> "Deploy without managing servers" + "PaaS" + "Developer focuses on code only" = Elastic Beanstalk. هو الـ PaaS Service اللي بيعمل كل الـ Infrastructure تلقائياً. EC2 = Manual. CloudFormation = IaC (لسه بتحتاج تعرف الـ Resources). EKS = Kubernetes (معقّد).

---

*القسم الجاي: **Global Infrastructure Section — Route 53، CloudFront، Global Accelerator، Outposts، WaveLength، Local Zones.***
