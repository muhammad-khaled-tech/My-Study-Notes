# 🛡️ Security & Compliance — الجزء الأول
### AWS Certified Cloud Practitioner — CLF-C02

---

## 🤝 الحكاية بتبدأ بسؤال مهم — مين مسؤول لو حصل حاجة؟

تخيل معايا إنك استأجرت شقة في عمارة. حصل حريق. السؤال الطبيعي: مين المسؤول؟ لو الحريق بدأ من العزل الكهربائي في جدران العمارة نفسها — ده مسؤولية صاحب العمارة. لو بدأ من سيجارة نسيتها في شقتك — ده مسؤوليتك إنت. المنطق ده بالظبط هو اللي AWS بنت عليه الـ **Shared Responsibility Model**.

لما بتشتغل على AWS، مش AWS وحدها المسؤولة عن كل حاجة. في حاجات AWS بتتكفل بيها — وفي حاجات إنت المسؤول عنها بالكامل. الـ Exam بيسألك عن الفرق ده في كل صورة ممكنة، فلازم تفهمه جوهرياً مش بس تحفظه.

---

## ⚖️ الـ Shared Responsibility Model — التقسيم الرسمي

الجملتان اللي لازم تعرفهم وبتيجيوا في كل امتحان:

> **AWS مسؤولة عن Security OF the Cloud.**
> **إنت (Customer) مسؤول عن Security IN the Cloud.**

**AWS** مسؤولة عن كل حاجة إنت مش شايفها — الـ Physical Infrastructure: المباني والأجهزة والكابلات والتبريد. الـ Hypervisors اللي بتشغّل الـ Virtualization. الشبكات الفيزيائية بين الـ Data Centers. والـ Managed Services نفسها — يعني لو AWS قالتلك "S3 آمن وDATA بتاعتك متفصلة عن باقي العملاء" — ده وعد AWS إنها بتحافظ عليه.

**إنت** مسؤول عن كل حاجة إنت بتقرر فيها — البيانات بتاعتك وتشفيرها، إعدادات الـ Network والـ Security Groups، مين يقدر يدخل على الـ AWS Account بتاعتك، الـ IAM Users والـ Roles، والـ Application Code اللي بتكتبه.

> [!abstract]+ تفاصيل التقسيم لكل Service — RDS وS3 كأمثلة
>
> ### الـ RDS — Database Service
> **AWS مسؤولة عن:**
> - إدارة الـ EC2 Instance اللي الـ Database شغّالة عليه.
> - إغلاق الـ SSH Access على الـ Instance التحتاني (إنت ما تقدرش تـ SSH عليه أصلاً في الـ Managed RDS).
> - الـ Automated Patching للـ OS والـ Database Software تلقائياً.
> - ضمان إن الـ Underlying Hardware شغّال ومصحي.
>
> **إنت مسؤول عن:**
> - فتح وإغلاق الـ Ports على الـ Security Group بتاع الـ Database.
> - إنشاء الـ Users والصلاحيات جوه الـ Database نفسه.
> - تقرير إنت هتخلي الـ Database Publicly Accessible ولا لا.
> - تفعيل الـ SSL Connections وضبط الـ Parameter Groups.
> - تفعيل الـ Encryption على الـ RDS.
>
> ### الـ S3 — Object Storage
> **AWS مسؤولة عن:**
> - ضمان التخزين اللا نهائي — إنت ما بتفكرش في السعة.
> - تشفير البيانات على مستوى الـ Infrastructure.
> - عزل بيانات العملاء المختلفين عن بعض.
> - ضمان إن موظفي AWS ما يقدروش يوصلوا لبياناتك.
>
> **إنت مسؤول عن:**
> - إعدادات الـ Bucket نفسها — هل هي Public أو Private.
> - الـ Bucket Policy — مين يقدر يقرأ أو يكتب.
> - الـ IAM Roles اللي بتوصّل بيها Services لاـ Bucket.
> - تفعيل الـ Encryption على المحتوى (SSE-S3 أو SSE-KMS).

**الـ Shared Controls** — وفيه حاجات في المنتصف اللي الاتنين مسؤولين عنها بشكل مختلف:
- **Patch Management** — AWS بتـ Patch الـ Infrastructure، إنت بتـ Patch الـ OS على الـ EC2 بتاعك.
- **Configuration Management** — AWS بتحافظ على إعدادات الأجهزة، إنت بتحافظ على إعدادات الـ Application.
- **Awareness & Training** — الاتنين مسؤولين عن تدريب فرقهم على الأمان.

> [!important] القاعدة الذهبية في الامتحان
> لما السؤال بيسألك "من مسؤول عن تحديث الـ OS على الـ EC2؟" — الإجابة إنت.
> لما بيسألك "من مسؤول عن الـ Physical Hardware؟" — الإجابة AWS.
> لما بيسألك عن "Managed Service زي RDS أو S3"، AWS مسؤولة عن الـ Underlying Infrastructure، وإنت مسؤول عن الـ Configuration.

---

## 💥 هجمات الـ DDoS — لما العدو بيجيب جيش


### أولاً: إيه هو الـ DDoS Attack أصلاً؟

تخيل انك فاتح مشروع ابليكشن طلبات ومعاك فرع معين شغال منه، والفرع ده يقدر يستقبل ويخدم 100 عميل في نفس الوقت مستريح. جاء هكر شرير مش حابب إن شركتك تنجح، فعمل إيه؟ سخر آلاف الأجهزة المخترقة حول العالم (بنسميها **Botnet**) وأمرهم كلهم في نفس الثانية يدخلوا على الموقع بتاعك ويطلبوا صفحات أو يعملوا عمليات وهمية.

الموقع بتاعك هيلاقي فجأة فيه 500,000 ريكويست جايين في نفس اللحظة. السيرفرات بتاعتك مش هتستحمل الضغط ده، الـ CPU هيوصل 100%، والسيستم كله هيقع (Crash). النتيجة؟ العميل الحقيقي الشرعي لما ييجي يفتح الموقع، هيلاقيه واقف ومش بيفتح. هو ده الـ DDoS — الهكر مش بيسرق بياناتك، هو بس **بيسد باب السيستم** بترافيك وهمي عشان يوقعه ويخسرك عملاء وفلوس.

 الهجمات دي بتحصل على مستويات مختلفة في الشبكة (Network Layers):

- **Layer 3 (Network Layer):** هجمات بتستهدف الـ IP والـ Routing (زي الـ Reflection Attacks).
    
- **Layer 4 (Transport Layer):** هجمات بتستهدف بروتوكولات النقل والتوصيل (زي الـ SYN Floods والـ UDP Floods).
    
- **Layer 7 (Application Layer):** هجمات ذكية بتستهدف كود الأبلكيشن نفسه والـ HTTP Requests (زي إنه يفضل يعمل لوجين أو سيرش ملايين المرات ورا بعض عشان يتعب الداتا بيز).
    

### ثانياً: دخول البطل — AWS Shield

هنا بيجي دور **AWS Shield**. ده نظام جدار حماية وفلترة ذكي جداً، بيقعد بره الـ Infrastructure بتاعتك خالص، وظيفته إنه يراقب الترافيك اللي جاي من الإنترنت لخدماتك، ويفصل الزبون الحقيقي عن الريكويست الوهمي بتاع الهكر.

أمازون بتقدم الخدمة دي في نسختين (Standard و Advanced)، والفرق بينهم جوهري هندسياً ومادياً:

Code snippet

![](data:image/png;base64,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)

```mermaid
graph TD
    User[All Internet Traffic] --> Shield[AWS Shield Perimeter]
    Shield -->|Filters Layer 3/4 Floods| Clean[Clean Traffic]
    Clean --> AWS_Infra[Your AWS Infrastructure: EC2, ALB, CloudFront]
    
    subgraph "AWS Shield Standard (Free & Auto)"
        Shield
    end
```

### 1. AWS Shield Standard (الدرع الافتراضي المجاني)

ده الحارس اللي واقف على الباب أوتوماتيك. بمجرد ما تفتح حساب على AWS، الميزة دي بتكون **شغالة ومفعلة تلقائياً بنسبة 100% وببلاش** من غير ما تدفع مليم ولا ترفع تيكت تطلبها.

- **بيحمي إيه؟** بيحمي حسابك على مستوى الـ **Layer 3** والـ **Layer 4**.
    
- **نوع الهجمات اللي بيصدها:** الهجمات المشهورة والتقليدية جداً زي الـ SYN Floods و UDP Floods والـ Reflection attacks. النظام بيلمح الارتفاع المفاجئ وغير المنطقي في النوع ده من الـ Packets، وبيعمل لها فلترة (Mitigation) في الخلفية من غير ما الأبلكيشن بتاعك يحس بحاجة.
    
- **الـ Scope:** شغال على كل خدمات AWS بشكل عام وخصوصاً الخدمات اللي بتستقبل ترافيك من بره زي Amazon CloudFront و Amazon Route 53.
    

### 2. AWS Shield Advanced (الدرع الثقيل المدفوع)

ده بقى مش مجرد سيستم آلي، ده "غرفة عمليات وإدارة أزمات كاملة" مخصصة للشركات الكبرى (زي البنوك، منصات التجارة الضخمة، أو أبلكيشنز المليون مستخدم) اللي لو الموقع بتاعها وقع ساعة واحدة ممكن تخسر ملايين الدولارات.

الخدمة دي بتكلف **3,000 دولار في الشهر ثابته (Flat Fee)** لكل الـ Organization بتاعتك، وبتديك مميزات خرافية:

- **حماية شاملة لكل الطبقات (Layer 3/4/7):** بيحميك من الهجمات المعقدة والذكية جداً اللي بتستهدف الأبلكيشن نفسه (HTTP Floods)، وبيتكامل بشكل Native مع الـ **AWS WAF** (Web Application Firewall) عشان يكتب قواعد حماية ذكية أوتوماتيك وقت الهجوم.
    
- **الـ SRT (Shield Response Team):** (🚨 **أهم كلمة مفتاحية للامتحان**) أول ما بتشترك في الـ Advanced، بيكون ليك صلاحية تواصل 24/7 على مدار الساعة مع فريق مهندسين متخصصين في الـ Cybersecurity والـ DDoS جوه أمازون اسمهم الـ SRT (كان اسمهم زمان DRT). وقت ما يحصل عليك هجوم معقد وجديد، الناس دي بتدخل معاك لايف جوه السيستم وبتبني معمارية حماية وتكتب Rules فورية لصد الهجوم عنك.
    
- **الحماية المالية ضد الفواتير (DDoS Cost Protection):** تخيل لو إنت عامل Auto Scaling للسيرفرات بتاعتك. لما الهجوم يحصل والملايين الريكويستات تدخل، الـ Auto Scaling هيفهم إن ده ضغط حقيقي فيفتحلك 100 سيرفر زيادة عشان يشيلوا الحمل. الهجوم هيتصد، بس في آخر الشهر هتفاجأ بفاتورة مرعبة بسبب السيرفرات اللي فتحت دي! الـ Shield Advanced بيحميك من ده؛ AWS بتبص على الفاتورة وتعرف إن الزيادة دي كانت بسبب الهجوم، **فبتعوضك وبتشيل من عليك تكلفة الـ Scaling الزيادة دي تماماً**.
    
- **لوحة تحكم متطورة (Visibility & Alerts):** بيديك Dashboard تفصيلية لحظة بلحظة عن طبيعة الهجوم، جاي من أنهي بلاد، وحجم الـ Packets، وإيه الـ Mitigation اللي شغال حالياً.
    

### 🚨 فخاخ الـ Exam لـ ستيفان (Exam Traps):

1. **فخ التكلفة والدعم البشري:** لو جابلك سؤال في الامتحان وقال لك شركة محتاجة **"24/7 access to the AWS DDoS Response Team (DRT/SRT)"** أو محتاجة **"DDoS Cost Protection"** عشان يحميهم من قفزات الفواتير وقت الهجوم ➔ الإجابة بدون تفكير هي **AWS Shield Advanced**.
    
2. **فخ التفعيل والمصاريف:** لو قال لك شركة صغيرة خايفة من الـ DDoS وميزانيتها محدودة جداً وعايزة حماية من غير ما تدفع تكاليف إضافية أو تعمل إعدادات معقدة ➔ الإجابة هي **AWS Shield Standard** لأنه أوتوماتيك ومجاني.
    
3. **الخدمات المحمية بالـ Advanced:** الـ Advanced بيتم ربطه وتفعيله خصيصاً على خدمات معينة بالاسم: Elastic Load Balancing (ELB)، Amazon CloudFront، Amazon Route 53، و AWS Global Accelerator.
    

### برشامة الذاكرة (Quick Summary):

- **Shield Standard:** مجاني + تلقائي + بيصد هجمات الطبقة 3 و 4 (شبكة ونقل).
    
- **Shield Advanced:** بـ 3,000$ في الشهر + فريق SRT بشرائي معاك 24/7 + حماية مادية ضد فواتير الـ Scaling + بيحمي كمان الطبقة 7 (الأبلكيشن).

---

## 🔥 AWS WAF — حارس البوابة على الـ Layer 7

الـ **Shield** بيحميك من هجمات الـ Network. الـ **WAF (Web Application Firewall)** بيحميك من هجمات الـ Application — وده مستوى أعمق وأذكى.

الـ WAF بيشتغل على **Layer 7** — يعني بيفهم الـ HTTP/HTTPS. بيقدر يفحص كل Request بالتفصيل — الـ IP Address، الـ HTTP Headers، محتوى الـ Body، الـ URI. وبناءً على قواعد إنت بتحددها، بيسمح أو بيمنع.

بتنشره على: Application Load Balancer، API Gateway، وCloudFront.

الـ **Web ACL (Web Access Control List)** هي القلب — مجموعة Rules بتقول للـ WAF إيه يسمح وإيه يمنع:
- **IP Blocking** — بتحجب IPs معينة أو نطاقات بأكملها.
- **SQL Injection Protection** — بيتعرف على محاولات حقن SQL في الـ Parameters.
- **XSS (Cross-Site Scripting) Protection** — بيتعرف على Scripts خبيثة في الـ Requests.
- **Geo-Match** — بتحجب بلدان بأكملها. مثلاً: موقعك للسوق المصري فقط — بتحجب كل حاجة خارج مصر.
- **Rate-Based Rules** — لو IP معين بيرسل أكتر من عدد معين من الـ Requests في الدقيقة — بيتـ Block تلقائياً (ده بيساعد في صد الـ DDoS على مستوى الـ Application).

> [!important] Shield vs WAF — الفرق الجوهري
> - **Shield** = حماية من هجمات الـ Network (Layer 3/4) — SYN Floods وUDP Floods.
> - **WAF** = حماية من هجمات الـ Application (Layer 7) — SQL Injection وXSS وBot Traffic.
> - الاتنين ممكن يشتغلوا مع بعض — Shield يحمي الـ Infrastructure، WAF يحمي الـ Application.

---

## 🌐 AWS Network Firewall — حارس الـ VPC كله

الـ **Network Firewall** بيحمي الـ VPC بتاعتك كلها — مش بس الـ Web Application. بيشتغل من **Layer 3 لـ Layer 7**، وبيفحص كل الـ Traffic في كل الاتجاهات:
- Traffic جاي من الإنترنت لجوّا الـ VPC.
- Traffic خارج من الـ VPC للإنترنت.
- Traffic بين الـ VPCs المختلفة (VPC to VPC).
- Traffic عبر الـ Direct Connect أو الـ Site-to-Site VPN.

يعني هو Firewall شامل على مستوى الـ VPC كله — مش بس على الـ Web Layer.

---

## 🏛️ AWS Firewall Manager — إدارة الأمان على مستوى Organization كاملة

تخيل إن عندك 50 AWS Account في Organization واحدة. في كل Account عندك EC2 Instances وLoad Balancers وResources محتاجة تتأمن. مش معقول تروح لكل Account لوحدها وتعمل الإعدادات دي. هنا الـ **Firewall Manager** بييجي.

الـ Firewall Manager بيخليك تحدد **Security Policies مركزية** على مستوى الـ Organization كلها، وبتطبق تلقائياً على كل Account موجود وكل Account جديد هيتضاف:
- VPC Security Groups لـ EC2 والـ Load Balancers.
- WAF Rules على CloudFront وAPI Gateway.
- AWS Shield Advanced على كل الـ Resources.
- AWS Network Firewall على كل الـ VPCs.

الميزة الكبيرة: لما Account جديد بييتضاف للـ Organization — السياسات دي بتتطبق عليه **تلقائياً** من غير تدخل يدوي. ده بيضمن Compliance موحد على الكل.

```mermaid
graph TD
    FM["🏛️ Firewall Manager<br/>(Organization Level)"] --> A1["Account 1"]
    FM --> A2["Account 2"]
    FM --> A3["Account 3"]
    FM --> AN["...Account N"]

    A1 --> R1["WAF + Shield + SG Rules"]
    A2 --> R2["WAF + Shield + SG Rules"]
    A3 --> R3["WAF + Shield + SG Rules"]
    AN --> RN["WAF + Shield + SG Rules"]

    style FM fill:#FF9900,color:#000
    style R1 fill:#232F3E,color:#fff
    style R2 fill:#232F3E,color:#fff
    style R3 fill:#232F3E,color:#fff
    style RN fill:#232F3E,color:#fff
```

---

## 🔍 Penetration Testing — لما إنت اللي بتهاجم

الـ **Penetration Testing** (أو الـ Pen Testing) هو إنك توظّف متخصص في الأمان — أو تعمله بنفسك — يحاول يخترق Infrastructure بتاعتك عشان يكتشف الثغرات قبل المهاجمين الحقيقيين. فكرة جيدة جداً — بس على AWS لازم تعرف القواعد.

**الخبر الكويس:** AWS بتسمحلك تعمل Pen Testing على عدد من الخدمات **من غير ما تاخد إذن مسبق**:
EC2 Instances وNAT Gateways وElastic Load Balancers — RDS — CloudFront — Aurora — API Gateway — Lambda وLambda Edge — Lightsail — Elastic Beanstalk.

**الخبر اللي لازم تنتبهله — الأشياء الممنوعة تماماً:**
- هجمات الـ DDoS أو أي شيء يشبهها (حتى Simulated DDoS).
- Port Flooding وProtocol Flooding.
- DNS Zone Walking عبر Route 53.
- Request Flooding (إغراق الـ Login Endpoint أو الـ API بـ Requests).

السبب بسيط — الأنشطة دي ممكن تأثر على عملاء AWS التانيين اللي على نفس الـ Infrastructure. لو عايز تعمل أي حاجة خارج القائمة المسموحة — بتتواصل مع AWS عبر `aws-security-simulatedevent@amazon.com` وبتاخد موافقة مسبقة.

> [!important] Trap مهم في الـ Exam
> لو السؤال سألك "هل تحتاج إذن من AWS قبل Pen Testing على EC2؟"
> الإجابة: **لا** — الـ 8 خدمات دي مسموح عليها Pen Testing بدون إذن.
> لو سألك عن DDoS Simulation: **لازم إذن وتواصل مسبق مع AWS.**

---

## 🔐 التشفير — Data at Rest vs Data in Transit

قبل ما نتكلم عن الـ Services التشفير، لازم تفهم مفهومين أساسيين بيبانوا في كل سؤال تشفير.

**Data at Rest** هو البيانات الساكنة — المخزونة على أي وسيلة: هارد ديسك، RDS Instance، S3 Bucket، Glacier. البيانات مش بتتحرك — بس لازم تتحفظ بأمان لو حد وصل للـ Storage Device بشكل مادي أو رقمي.

**Data in Transit** هو البيانات المتحركة — بتتنقل من مكان لمكان: من الـ On-Premises لـ AWS، من EC2 لـ DynamoDB، من المستخدم لموقعك. لو حد قدر يـ Intercept الـ Network Traffic ده، ما يلاقيش حاجة مقروءة.

الهدف: **تشفير البيانات في الحالتين**. وللموضوع ده، AWS عندها خدمتان رئيسيتان.

---

## 🗝️ AWS KMS — مفاتيح التشفير بيديرها AWS

الـ **KMS (Key Management Service)** هو الخدمة اللي بتدير مفاتيح التشفير عشانك. القاعدة البسيطة: لما بتسمع كلمة "Encryption" في أي AWS Service تقريباً — اعرف إن ورا الكواليس فيه **KMS**.

ليه KMS مش بتدير المفاتيح نفسك؟ لأن إدارة مفاتيح التشفير صعبة وخطرة — لو ضيّعت المفتاح، ضيّعت البيانات. AWS بتأخد عنك المسؤولية دي وبتضمنلك الأمان والـ Durability.

**Services بتطلب تفعيل يدوي (Opt-in) للتشفير:**
- EBS Volumes.
- S3 Buckets — الـ SSE-S3 دلوقتي enabled by default، بس الـ SSE-KMS لازم تختاره.
- Redshift Database.
- RDS Database.
- EFS Drives.

**Services بتتشفر تلقائياً دايماً:**
- CloudTrail Logs.
- S3 Glacier.
- Storage Gateway.

**أنواع مفاتيح الـ KMS:**

الـ KMS ما هوش مفتاح واحد — فيه أربع أنواع مختلفة بمسؤوليات مختلفة:

**Customer Managed Keys** — إنت اللي بتنشئها وبتديرها. تقدر تفعّلها أو تعطّلها، تحدد Policy التناوب (كل سنة مثلاً تتجدد تلقائياً)، وتقدر تـ Import مفتاح من عندك (Bring Your Own Key). أعلى مستوى من التحكم.

**AWS Managed Keys** — بتتعمل تلقائياً لما بتفعّل تشفير على Service معينة. مثلاً لما بتفعّل التشفير على RDS — AWS بتنشئ المفتاح باسم `aws/rds`. إنت مش بتديره مباشرة — AWS بتديره نيابةً عنك.

**AWS Owned Keys** — مفاتيح AWS بتملكها وبتستخدمها في حسابات كتير. إنت ما بتشوفهاش ولا بتتحكم فيها — هي بتحمي Resources معينة في Account بتاعك من غير ما تعرف.

**CloudHSM Keys** — مفاتيح بتتنشأ داخل الـ CloudHSM Hardware بتاعك. التشفير نفسه بيحصل جوه الـ HSM Cluster.

> [!abstract]+ جدول أنواع KMS Keys للمراجعة السريعة
>
> | النوع | مين بيديره؟ | مين بيتحكم فيه؟ | استخدامه |
> |-------|------------|----------------|---------|
> | Customer Managed | إنت | إنت بالكامل | عايز تحكم كامل + Rotation + BYOK |
> | AWS Managed | AWS | إنت مش بتتدخل | تشفير تلقائي للـ Services |
> | AWS Owned | AWS | AWS بالكامل | حماية داخلية، مش بتشوفه |
> | CloudHSM Keys | AWS Hardware + إنت | إنت بتدير المفتاح | متطلبات Compliance شديدة |

---

## 🖥️ CloudHSM — لما تحتاج Hardware حقيقي

الـ **CloudHSM** مش مجرد Software زي KMS — هو **Hardware Security Module** حقيقي بتمتلكه أنت (بشكل dedicated). AWS بتوفرلك الـ Hardware، بس إنت اللي بتدير مفاتيح التشفير بالكامل — AWS نفسها ما تقدرش توصّل لمفاتيحك.

الفرق الجوهري:
- **KMS** = AWS بتدير الـ Software وبتدير المفاتيح نيابةً عنك.
- **CloudHSM** = AWS بتوفر الـ Hardware الفيزيائي — بس إنت بتدير مفاتيحك بنفسك تماماً.

متى تستخدم CloudHSM؟ لو عندك متطلبات Compliance صارمة جداً (زي FIPS 140-2 Level 3) أو قوانين تقول إن المفاتيح لازم تكون تحت سيطرتك الكاملة المطلقة — مش AWS ولا أي طرف تالت.

> [!important] KMS vs CloudHSM — الفرق في الامتحان
> - "AWS manages encryption keys" → **KMS**
> - "You manage your own encryption keys entirely" → **CloudHSM**
> - "FIPS 140-2 Level 3 compliance" → **CloudHSM**
> - "Dedicated Hardware" → **CloudHSM**

---

## 🔒 AWS Certificate Manager (ACM) — شهادات الـ HTTPS

لما موقعك بيستخدم HTTPS بدل HTTP، ده معناه إن البيانات بين المستخدم وموقعك مشفّرة أثناء النقل. عشان كده لازم **SSL/TLS Certificate** — وثيقة رقمية بتثبت هوية موقعك وبتمكّن التشفير.

الـ **ACM (AWS Certificate Manager)** بيعملها سهلة جداً:
- بتـ Provision الـ Certificate بضغطة زرار.
- مجانية للـ Public TLS Certificates.
- بيجدد الشهادة تلقائياً قبل ما تنتهي — مش لازم تفكر فيها.
- بتنشرها على: Elastic Load Balancer، CloudFront، وAPI Gateway.

يعني الـ ACM بيأخد عنك كابوس إدارة الشهادات.

---

## 🔑 AWS Secrets Manager — خزينة الأسرار

الـ **Secrets Manager** خدمة متخصصة في تخزين الـ Secrets بشكل آمن — Database Passwords، API Keys، أي بيانات حساسة ما ينفعش تحطها في الـ Code أو في الـ Environment Variables عادية.

الميزة الأقوى فيه: **Automatic Rotation**. بتحدد إن الـ Password يتغير كل X أيام — الـ Secrets Manager بيولّد Password جديد تلقائياً، بيحدّثه في الـ Secret، ولو الـ Service دي RDS — بيحدّثه على الـ Database نفسها تلقائياً (باستخدام Lambda في الخلفية). كل ده من غير Downtime ومن غير تدخل يدوي.

التشفير: كل الـ Secrets مشفّرة باستخدام **KMS**.

> [!important] Secrets Manager vs Parameter Store — الفرق الأساسي
> الـ **Parameter Store** (جزء من Systems Manager) بيخزن Config والـ Secrets بشكل بسيط ومجاني.
> الـ **Secrets Manager** متخصص أكتر — بيضيف Automatic Rotation وDeep Integration مع RDS. لو السؤال ذكر "rotation" أو "database credentials" — **Secrets Manager**.

---

## 📋 AWS Artifact — مكتبة الوثائق القانونية

الـ **Artifact** مش Service تقنية بالمعنى الحرفي — ده **Portal** بيديك وصول فوري لوثائق الـ Compliance والاتفاقيات القانونية بتاعة AWS.

**Artifact Reports** — تقارير الأمان والـ Compliance اللي بيصدرها مدققون خارجيون: AWS ISO Certifications، PCI-DSS Reports، SOC 1/2/3 Reports. مهمة لما بتحتاج تثبت لعميل أو لجهة تنظيمية إن AWS بتلتزم بالمعايير.

**Artifact Agreements** — الاتفاقيات القانونية: زي الـ BAA (Business Associate Addendum) لمتطلبات الـ HIPAA في القطاع الصحي. بتراجعها وتوقّعها وتتتبع حالتها كلها من مكان واحد.

> [!important] Artifact في الامتحان
> لو السؤال قال "compliance reports" أو "audit documentation" أو "PCI/ISO/SOC reports" — الإجابة **AWS Artifact**.
> مش خدمة بتحميك — هي وثائق بتثبت الالتزام.

---

## 🎯 فخاخ الـ Exam — الجزء الأول

**الـ Trap الأول — Shield Standard مجاني ومفعّل تلقائياً:** كتير من الناس بيفتكروا إنك لازم تفعّل الحماية. لا — كل AWS Customer عنده Shield Standard من أول يوم من غير أي إعداد.

**الـ Trap التاني — WAF مش بديل Shield:** WAF بيحمي من SQL Injection وXSS (Layer 7). Shield بيحمي من DDoS (Layer 3/4). الاتنين بيكملوا بعض — مش بديل.

**الـ Trap التالت — KMS مش بيدير الـ Hardware:** KMS بيدير مفاتيح التشفير على مستوى الـ Software. لو السؤال قال "dedicated hardware" أو "you manage encryption keys entirely" — **CloudHSM** مش KMS.

**الـ Trap الرابع — Pen Testing على EC2 لا يحتاج إذن:** المستخدمين دايماً بيفتكروا إن أي Pen Testing على AWS يحتاج موافقة مسبقة. الـ 8 Services المذكورة — مسموح بدون إذن. الممنوع هو DDoS Simulation.

**الـ Trap الخامس — Data Transfer IN مجاني دايماً:** في الـ Encryption Context، البيانات اللي بتيجي لـ AWS مجانية. اللي بيكلف هو Transfer OUT. مش مرتبط بالتشفير — ده Pricing Rule عام.

**الـ Trap السادس — Secrets Manager vs Parameter Store:** دايماً "rotation" أو "RDS integration" → **Secrets Manager**. "Simple config values" أو "free" → **Parameter Store**.

**الـ Trap السابع — Firewall Manager بيحتاج AWS Organizations:** الـ Firewall Manager بيشتغل على مستوى Organization — مش على Account منفردة.

---

## 📝 أسئلة الـ Exam — الجزء الأول

### Q1. A company runs a web application on AWS. They need to protect it from SQL injection attacks and cross-site scripting (XSS). Which AWS service should they use?

- A. AWS Shield Standard
- B. AWS Shield Advanced
- C. AWS WAF
- D. AWS Network Firewall

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **AWS WAF** هو الخدمة المصممة للحماية من هجمات الـ Application Layer (Layer 7) — ومنها SQL Injection وXSS. بيعمل ده عن طريق Web ACL Rules بتفحص محتوى الـ HTTP Requests.
>
> **ليه الباقي غلط:**
> - **A و B** — الـ Shield بيحمي من هجمات الـ Network (Layer 3/4) زي DDoS. لا علاقة له بالـ SQL Injection.
> - **D** — الـ Network Firewall بيحمي الـ VPC كله على مستوى الـ Network — مش متخصص في هجمات الـ Application.

---

### Q2. What is the monthly cost of AWS Shield Standard for a company with 10 AWS accounts?

- A. $3,000 per account ($30,000 total)
- B. $100 per month per account
- C. Free — it is automatically enabled for all AWS customers
- D. It is included in the AWS Business Support plan only

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **AWS Shield Standard** مجاني تماماً ومفعّل تلقائياً لكل عملاء AWS بدون أي إعداد. مش محتاج تشتريه أو تفعّله.
>
> الـ **$3,000 شهرياً** هو سعر **AWS Shield Advanced** — وده optional وللشركات اللي محتاجة حماية متقدمة.
>
> **ليه الباقي غلط:**
> - **A** — الـ $3,000 هو تمن Shield Advanced لكل Organization — مش per account.
> - **D** — Shield Standard مش مرتبط بأي Support Plan.

---

### Q3. According to the AWS Shared Responsibility Model, which of the following is AWS's responsibility when a company uses Amazon RDS?

- A. Configuring the database security groups to restrict access
- B. Creating database users and assigning appropriate permissions
- C. Applying operating system patches to the underlying RDS instance
- D. Enabling encryption on the RDS database

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> في الـ **Managed Service** زي RDS، AWS مسؤولة عن كل الـ Underlying Infrastructure — وده يشمل التحديثات التلقائية للـ OS والـ Database Software نفسها. إنت ما تقدرش حتى تـ SSH على الـ Instance التحتاني في RDS — AWS هي اللي بتديره.
>
> **ليه الباقي غلط:**
> - **A** — إعداد الـ Security Groups مسؤولية Customer.
> - **B** — إنشاء الـ Users والصلاحيات جوه الـ Database مسؤولية Customer.
> - **D** — تفعيل الـ Encryption على RDS مسؤولية Customer — AWS بتوفر الأداة، بس إنت اللي بتفعّلها.

---

### Q4. A company needs to store database credentials securely and requires automatic rotation of these credentials every 30 days. Which AWS service best meets this requirement?

- A. AWS Systems Manager Parameter Store
- B. AWS KMS
- C. AWS Secrets Manager
- D. AWS Certificate Manager

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **Secrets Manager** هو الخيار الأمثل لإنه مصمم بالظبط للـ Database Credentials مع **Automatic Rotation**. بيغير الـ Password تلقائياً كل X أيام وبيحدّثه على الـ RDS Instance من غير Downtime.
>
> **ليه الباقي غلط:**
> - **A** — Parameter Store بيخزن الـ Config والـ Secrets بس ما عندوش Automatic Rotation تلقائي مدمج مع RDS.
> - **B** — KMS بيدير مفاتيح التشفير — مش الـ Credentials نفسها.
> - **D** — Certificate Manager للـ SSL/TLS Certificates — مش الـ Database Passwords.

---

### Q5. Which of the following activities are PROHIBITED in AWS penetration testing without prior approval? (Select TWO)

- A. Running vulnerability scans on Amazon EC2 instances you own
- B. Simulating a DDoS attack against your own AWS infrastructure
- C. Testing your Amazon RDS database for SQL injection vulnerabilities
- D. Performing port flooding attacks to test network resilience
- E. Running automated security scans on Amazon CloudFront distributions

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answers: B and D**
>
> **B (DDoS Simulation)** — أي Simulated DDoS ممنوع على AWS حتى لو على Infrastructure بتاعتك. السبب: الـ DDoS ممكن يأثر على عملاء تانيين على نفس الـ Shared Infrastructure. ده Prohibited بشكل قاطع.
>
> **D (Port Flooding)** — كمان ممنوع بشكل صريح في قائمة AWS Pen Testing Policy.
>
> **ليه الباقي مسموح:**
> - **A و C و E** — كلها Pen Testing عادي على Services في قائمة الـ 8 Services المسموح عليها (EC2، RDS، CloudFront) من غير إذن مسبق.

---

### Q6. A company's security team wants a single pane of glass to apply WAF rules, Shield Advanced protections, and VPC Security Group policies across all 20 AWS accounts in their organization. Which service enables this?

- A. AWS Config
- B. AWS Security Hub
- C. AWS Firewall Manager
- D. AWS Control Tower

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **AWS Firewall Manager** هو الخدمة المصممة بالظبط لإدارة Security Rules مركزياً على مستوى AWS Organization. بتحدد Policy مرة واحدة — وبتتطبق تلقائياً على كل الـ 20 Account وأي Account جديد.
>
> **ليه الباقي غلط:**
> - **A** — Config لتتبع التغييرات والـ Compliance — مش لتطبيق Firewall Rules.
> - **B** — Security Hub لتجميع النتائج الأمنية من خدمات مختلفة — مش لتطبيق Rules.
> - **D** — Control Tower لإعداد الـ Landing Zone وMulti-Account Governance — مش للـ Firewall Management.

---

### Q7. Which AWS service would you use to download an AWS SOC 2 compliance report to share with an external auditor?

- A. AWS Trusted Advisor
- B. AWS Artifact
- C. AWS Config
- D. AWS Inspector

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> الـ **AWS Artifact** هو البوابة الرسمية للوثائق والتقارير القانونية والـ Compliance الصادرة عن AWS ومن جهات تدقيق خارجية. SOC 2 Report، ISO Certifications، PCI-DSS — كلها موجودة في Artifact وتقدر تحملها مباشرة.
>
> **ليه الباقي غلط:**
> - **A** — Trusted Advisor بيقدم توصيات لتحسين الـ Infrastructure — مش بيوفر وثائق Compliance.
> - **C** — Config بيتتبع التغييرات على الـ Resources — مش بيصدر تقارير Compliance لجهات خارجية.
> - **D** — Inspector بيفحص الثغرات الأمنية في الـ EC2 وLambda — مش بيوفر وثائق Compliance.

---

### Q8. A solutions architect needs to implement HTTPS for a web application hosted behind an Application Load Balancer. The certificate must renew automatically. Which service should they use?

- A. AWS KMS with a Customer Managed Key
- B. AWS CloudHSM
- C. AWS Secrets Manager
- D. AWS Certificate Manager (ACM)

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: D**
>
> الـ **AWS Certificate Manager** هو الخدمة المصممة بالظبط لإصدار وإدارة SSL/TLS Certificates للـ HTTPS. بيتكامل مباشرة مع Elastic Load Balancers وCloudFront وAPI Gateway. والأهم: بيجدد الشهادة تلقائياً قبل انتهائها.
>
> **ليه الباقي غلط:**
> - **A** — KMS للـ Encryption Keys — مش لإصدار SSL/TLS Certificates.
> - **B** — CloudHSM للـ Hardware Security Modules وإدارة مفاتيح التشفير يدوياً.
> - **C** — Secrets Manager لتخزين الـ Credentials والـ Secrets وتدويرها — مش لإصدار Certificates.

---

## 📊 ملخص نهائي — الـ Cheat Sheet الجزء الأول

| السؤال | الإجابة |
|--------|---------|
| Shared Responsibility — OS على EC2 | Customer |
| Shared Responsibility — Physical Hardware | AWS |
| Shared Responsibility — OS patches على RDS | AWS |
| Shared Responsibility — RDS Encryption تفعيل | Customer |
| حماية من SQL Injection وXSS | WAF (Layer 7) |
| حماية من DDoS (Layer 3/4) | Shield |
| Shield Standard — السعر | مجاني — تلقائي لكل عميل |
| Shield Advanced — السعر | $3,000/شهر/Organization |
| WAF بينشر على | ALB، API Gateway، CloudFront |
| حماية VPC كامل Layer 3-7 | AWS Network Firewall |
| إدارة Security Rules على Organization | AWS Firewall Manager |
| Pen Testing — محتاج إذن؟ | لا — لـ 8 Services محددة |
| DDoS Simulation — مسموح؟ | لا — ممنوع دايماً |
| Encryption at Rest | KMS، CloudHSM |
| Encryption in Transit | SSL/TLS، ACM |
| AWS manages encryption keys | KMS |
| You manage encryption keys entirely | CloudHSM |
| FIPS 140-2 Level 3 | CloudHSM |
| Dedicated Hardware for encryption | CloudHSM |
| SSL/TLS Certificates لـ HTTPS | ACM |
| ACM مع — Automatic Renewal | ✅ نعم |
| تخزين Database Credentials + Auto Rotation | Secrets Manager |
| تقارير Compliance — SOC/PCI/ISO | AWS Artifact |
| KMS Keys — Customer Managed | إنت بتديرها — Rotation + BYOK |
| KMS Keys — AWS Managed | AWS بتديرها، إنت بتختارها عند التفعيل |
| KMS Keys — AWS Owned | مش بتشوفها — AWS شغّالة بيها في الخلفية |

---

*الجزء الجاي: **Security & Compliance — الجزء الثاني** — كشف التهديدات والرصد: GuardDuty، Inspector، Macie، Config، Security Hub، Detective، وخدمات الـ Advanced Identity.*
