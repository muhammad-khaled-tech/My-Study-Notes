# 🏛️ Well-Architected Framework, AWS CAF & Ecosystem — الجزء الثالث
### AWS Certified Cloud Practitioner — CLF-C02
---

## 🏗️ الحكاية بتبدأ من ... — إيه معنى Architecture "كويس"؟

لما تبني بيت، مش بس بتبني جدران — بتفكّر في السلامة، القوة، التكلفة، والكفاءة. نفس الكلام مع الـ Cloud Architecture. AWS جمعت خبرتها في آلاف العملاء وعملت **AWS Well-Architected Framework** — 6 Pillars بتعرّفلك معنى الـ Architecture الصح.

---

## 🏛️ الـ 6 Pillars — Well-Architected Framework

### 🛠️ Pillar 1: Operational Excellence

**الفكرة:** شغّل الـ Systems وراقبها وحسّنها باستمرار عشان تقدّم Business Value.

Design Principles الأساسية:

1. **Perform operations as code** — اعمل كل حاجة بـ IaC (CloudFormation، CDK).
2. **Make frequent small reversible changes** — تغييرات صغيرة قابلة للرجوع عنها.
3. **Refine operations procedures frequently** — حسّن الإجراءات باستمرار.
4. **Anticipate failure** — افترض إن حاجة هتتعطّل وجهّز ليها.
5. **Learn from all operational failures** — اتعلّم من كل مشكلة.

AWS Services المرتبطة: **CloudFormation، Config، CloudTrail، CloudWatch، X-Ray**.

---

### 🔐 Pillar 2: Security

**الفكرة:** حماية المعلومات والأنظمة.

Design Principles:

1. **Implement a strong identity foundation** — IAM، Least Privilege.
2. **Enable traceability** — CloudTrail، CloudWatch Logs.
3. **Apply security at all layers** — Network، Application، Data.
4. **Automate security best practices** — Security Groups، Config Rules.
5. **Protect data in transit and at rest** — KMS، SSL/TLS.
6. **Keep people away from data** — أتمتة العمليات بدل الـ Manual Access.
7. **Prepare for security events** — Incident Response Plans.

AWS Services: **IAM، KMS، Shield، WAF، Inspector، CloudTrail**.

---

### 💪 Pillar 3: Reliability

**الفكرة:** قدرة النظام على يتعافى من الأعطال ويلبّي الطلبات بشكل ثابت.

Design Principles:

1. **Test recovery procedures** — اختبر الـ Recovery بانتظام.
2. **Automatically recover from failure** — Auto Scaling، Health Checks.
3. **Scale horizontally** — وزّع الـ Load على Instances متعددة — Single Point of Failure يختفي.
4. **Stop guessing capacity** — Auto Scaling بدل الـ Manual Provisioning.
5. **Manage change in automation** — CloudFormation للتغييرات.

AWS Services: **IAM، VPC، Auto Scaling، Route 53، CloudWatch، CloudTrail، Backup، CloudFormation، S3**.

---

### ⚡ Pillar 4: Performance Efficiency

**الفكرة:** استخدام الـ Resources بكفاءة عشان تلبّي الطلبات حتى لو تغيّر الـ Load.

Design Principles:

1. **Democratize advanced technologies** — استخدم الـ Managed Services واتركها لـ AWS.
2. **Go global in minutes** — Deploy في Multiple Regions بسهولة.
3. **Use serverless architectures** — Lambda بدل Servers.
4. **Experiment more often** — A/B Testing أصبح سهل على Cloud.
5. **Mechanical sympathy** — افهم كل الـ AWS Services واختار الأنسب.

AWS Services: **Auto Scaling، Lambda، EBS، S3، CloudFormation، CloudWatch، ElastiCache، CloudFront، RDS**.

---

### 💰 Pillar 5: Cost Optimization

**الفكرة:** شغّل الـ Systems بأقل سعر ممكن مع المحافظة على الـ Business Value.

Design Principles:

1. **Adopt a consumption model** — ادفع بس على اللي بتستخدمه.
2. **Measure overall efficiency** — CloudWatch + Cost Explorer.
3. **Stop spending money on data center operations** — AWS بتدير الـ Infrastructure.
4. **Analyze and attribute expenditure** — استخدم **Tags** عشان تعرف مين بيصرف إيه.
5. **Use managed and application level services** — أرخص من تدير الـ Infrastructure بنفسك.

AWS Services: **Budgets، Cost Explorer، Spot Instances، Reserved Instances، S3 Glacier، Auto Scaling، Trusted Advisor**.

---

### 🌱 Pillar 6: Sustainability

**الفكرة:** تقليل الأثر البيئي لتشغيل الـ Cloud Workloads.

Design Principles:

1. **Understand your impact** — قِس الـ Carbon Footprint.
2. **Establish sustainability goals** — حدد أهداف طويلة المدى.
3. **Maximize utilization** — Right Size كل Workload — لا Idle Resources.
4. **Adopt newer, efficient hardware** — AWS Graviton Processors.
5. **Use managed services** — Shared Services = أقل Infrastructure.
6. **Reduce downstream impact** — قلّل الطاقة اللي Customers محتاجينها.

AWS Services: **Auto Scaling، Lambda، Fargate، Cost Explorer، AWS Graviton، Spot Instances، EFS-IA، S3 Glacier، S3 Intelligent-Tiering، CloudFront، DynamoDB Global Tables**.

> [!important] الـ 6 Pillars — ازكرهم بالترتيب
> **O**perational Excellence → **S**ecurity → **R**eliability → **P**erformance Efficiency → **C**ost Optimization → **S**ustainability
> 
> جملة للحفظ: **"O S R P C S"** أو "Operations Secure Reliable Performance-Driven Cost-Smart Sustainable"

---

## 🛠️ AWS Well-Architected Tool

مش بس Framework نظري — فيه **Tool مجاني** في الـ Console بيساعدك تقيّم Architecture بتاعتك:

1. تختار الـ Workload وتجاوب على أسئلة.
2. بيراجع إجاباتك مقارنة بالـ 6 Pillars.
3. بيديك **Advice مخصوص** — Videos، Documentation، وReports.
4. بيعرض النتائج في **Dashboard** واضح.

---

## 🌍 AWS Customer Carbon Footprint Tool

بيساعدك تتتبع وتقيس وتتوقع الـ Carbon Emissions من استخدامك لـ AWS:

1. بيعرض **Carbon Emissions over Time**.
2. بيقسّمها **حسب Geography وحسب Service**.
3. بيساعدك تحقق أهدافك للـ Sustainability.
4. AWS هدفها وصول لـ **100% Renewable Energy**.

---

## ☁️ AWS Cloud Adoption Framework (AWS CAF)

## 🗺️ الحكاية بتبدأ من ... — الانتقال للـ Cloud مش بس تقني

لما شركة بتقرر تنتقل للـ Cloud، التحدي مش بس تقني — التحدي هو التغيير في الـ People والـ Process والـ Culture. **AWS CAF** هو Framework شامل بيساعد الشركات تخطّط وتنفّذ رحلة الـ Digital Transformation.

الـ CAF عنده **6 Perspectives** — 3 بيزنس و3 تقنية:

---

### Business Capabilities — 3 Perspectives

**1. Business Perspective:**
بيضمن إن الـ Cloud Investments بتحقق الـ Digital Transformation Goals وتسرّع الـ Business Outcomes.

**2. People Perspective:**
بيعمل جسر بين الـ Technology والـ Business — بيركّز على الـ Culture والـ Organizational Structure والـ Leadership والـ Workforce.

**3. Governance Perspective:**
بيساعدك تنسّق الـ Cloud Initiatives وتقلّل المخاطر وتعظّم الـ Organizational Benefits.

---

### Technical Capabilities — 3 Perspectives

**4. Platform Perspective:**
بيساعدك تبني Cloud Platform على مستوى Enterprise — Scalable وHybrid. وتـModernize الـ Workloads وتبني Cloud-Native Solutions.

**5. Security Perspective:**
بيضمن Confidentiality والـ Integrity والـ Availability للـ Data والـ Cloud Workloads.

**6. Operations Perspective:**
بيضمن إن الـ Cloud Services بتتقدّم بالمستوى اللي يلبّي احتياجات الـ Business.

> [!important] Business vs Technical Perspectives
> **Business:** Business، People، Governance
> **Technical:** Platform، Security، Operations
>
> الـ Exam ممكن يسألك "أنهي Perspective بيتعامل مع الـ Culture والـ Workforce؟" → **People**
> أو "أنهي Perspective بيتعامل مع الـ Risk Management؟" → **Governance**

---

## 🔄 AWS CAF — Transformation Domains

الـ Transformation الناجحة بتحصل في **4 Domains**:

1. **Technology** — نقل وتحديث الـ Infrastructure والـ Applications والـ Data Platforms.
2. **Process** — رقمنة وأتمتة الـ Business Operations، وتحليل البيانات باستخدام ML.
3. **Organization** — إعادة تصميم الـ Operating Model وتنظيم الـ Teams حول Products وValue Streams.
4. **Product** — إعادة تخيّل الـ Business Model وخلق Value Propositions جديدة وRevenue Models.

---

## 🚀 AWS CAF — Transformation Phases

الرحلة بتمرّ بـ **4 Phases**:

1. **Envision** — إظهار كيف الـ Cloud هيسرّع الـ Business Outcomes. تحديد فرص الـ Transformation.
2. **Align** — تحديد الـ Gaps في الـ 6 Perspectives وعمل **Action Plan**.
3. **Launch** — بناء وتوصيل **Pilot Initiatives** في Production وإظهار الـ Business Value بشكل تدريجي.
4. **Scale** — توسيع الـ Pilot Initiatives للـ Scale المطلوب وتحقيق الـ Business Benefits الكاملة.

---

## 📦 AWS Right Sizing

**المشكلة:** اشتريت EC2 Instance كبير عشان "ماتيجيش" — ومش محتاجه فعلاً.

**Right Sizing** هو عملية اختيار الـ Instance Type والـ Size اللي يوفّر الـ Performance المطلوب بأقل تكلفة:

1. ابدأ **صغير** — الـ Cloud Elastic، تقدر تـScale Up في أي وقت.
2. راجع الـ Instances الموجودة وشوف ممكن تصغّر أو تيقف حاجة من غير ما تأثر على الـ Capacity.
3. اعمل Right Sizing **قبل Migration** وكمان **باستمرار بعدها** (الـ Requirements بتتغير).

Tools للمساعدة: **CloudWatch، Cost Explorer، Trusted Advisor، وأي Third-Party Tools**.

---

## 🌐 AWS Ecosystem

## 📚 Free Resources

AWS بتوفّر مصادر مجانية كتير للتعلم والمساعدة:

1. **AWS Blogs** — آخر الأخبار والـ Updates.
2. **AWS Forums (Community)** — مجتمع المطورين.
3. **AWS Whitepapers & Guides** — وثائق تقنية رسمية.
4. **AWS Solutions Library** — Solutions جاهزة ومـValidated (مثال: Live Streaming on AWS).

---

## 🎧 AWS Support Plans

في **4 مستويات** من الـ Support:

| المستوى | الميزة الرئيسية | Response Time |
|---------|----------------|---------------|
| **Basic** | Free — Trusted Advisor محدود — Health Dashboard | لا يوجد |
| **Developer** | Business Hours Email لـ Cloud Support Associates | General: < 24 ساعة عمل، System Impaired: < 12 ساعة |
| **Business** | 24x7 Phone + Email + Chat لـ Cloud Support Engineers | Production Impaired: < 4 ساعات، Production Down: < 1 ساعة |
| **Enterprise** | Technical Account Manager (TAM) + Concierge Support | Business-Critical Down: **< 15 دقيقة** |

> [!important] الـ TAM — متاح بس في Enterprise
> **Technical Account Manager (TAM)** هو شخص مخصوص من AWS يتابع Account بتاعك. ده متاح بس في الـ **Enterprise Plan**.
> الـ **Concierge Support Team** (للـ Billing وBest Practices) كمان Enterprise Plan بس.

---

## 🛒 AWS Marketplace

مش بس AWS Services — فيه **Marketplace** كامل فيه آلاف الـ Software من Vendors خارجيين:

1. **Custom AMIs** — OS جاهز مع Software معيّن.
2. **CloudFormation Templates**.
3. **SaaS Solutions**.
4. **Containers**.

اللي بتشتريه من Marketplace بيتضاف على **AWS Bill بتاعك** مباشرة.
وتقدر **تبيع** Products بتاعتك على الـ Marketplace كمان.

---

## 🎓 AWS Training

AWS بتوفّر تدريب رسمي بأشكال مختلفة:

1. **AWS Digital Training** — Online.
2. **AWS Classroom Training** — In-person أو Virtual.
3. **AWS Private Training** — للشركات.
4. **AWS Academy** — للجامعات.
5. **Training & Certification for Government وEnterprise**.

---

## 🤝 AWS Professional Services & Partner Network

### AWS Professional Services

فريق خبراء AWS يشتغل مع Team بتاعك على مشاريع Cloud.

### AWS Partner Network (APN)

شبكة الـ Partners:

1. **APN Technology Partners** — Hardware، Connectivity، وSoftware.
2. **APN Consulting Partners** — شركات استشارات بتساعدك تبني على AWS.
3. **APN Training Partners** — بيعلّموا AWS.
4. **AWS Competency Program** — Competencies ممنوحة لـ Partners اللي أثبتوا التميّز في مجالات معيّنة.
5. **AWS Navigate Program** — بيساعد الـ Partners يتطوروا.

---

## ⚡ AWS IQ

بتلاقيلك **AWS Certified Experts** بسرعة لمشاريع محددة:

**للـ Customers:**
1. اعمل Submit Request — وصف المشروع.
2. راجع الردود والـ Proposals.
3. اختار الـ Expert.
4. اشتغل بأمان.
5. ادفع per Milestone — والرسوم على AWS Bill.

**للـ Experts:**
1. عمل Profile.
2. تواصل مع الـ Customers.
3. ابدأ Proposal.
4. اشتغل بأمان.
5. اتقبّض بعد الـ Milestone.

---

## 💬 AWS re:Post

بديل الـ AWS Forums القديمة — **Crowd-sourced Q&A Service**:

1. أسئلة وإجابات Technical عن AWS من الـ Community.
2. الأعضاء بيكسبوا **Reputation Points** عشان يبنوا Expert Status.
3. الأسئلة اللي مش بتلاقي إجابة من الـ Community → بتتحوّل لـ **AWS Support Engineers** (بس لو Premium Support Customer).
4. **مش مناسب** للأسئلة الـ Time-Sensitive أو اللي فيها معلومات Proprietary.
5. فيه **Knowledge Center** — أكتر الأسئلة شيوعاً وإجاباتها.

---

## 🏢 AWS Managed Services (AMS)

لو الشركة مش عايزة تدير الـ AWS Infrastructure بنفسها — **AMS** بيتكفّل بكل حاجة:

1. **Team of AWS Experts** بيديروا الـ Infrastructure بتاعك.
2. بيتكفّل بـ: **Security، Reliability، Availability**.
3. بيعمل: **Change Requests، Monitoring، Patch Management، Backup**.
4. **24/365 Business Hours**.
5. بيـImplement Best Practices ويقلّل الـ Operational Overhead والـ Risk.

**النتيجة:**
1. Improved Security.
2. Stronger Compliance.
3. Reduced Operating Costs.
4. Simplified Management.
5. Frictionless Innovation.

> [!abstract]+ AMS مقارنة بالـ Support Plans
> **Support Plans** (Developer, Business, Enterprise) → بتديلك إجابات على أسئلتك.
> **AWS Managed Services (AMS)** → بياخد المسؤولية الكاملة عن تشغيل الـ Infrastructure بدلاً منك.
> ده تمييز مهم في الـ Exam.

---

## 🎯 فخاخ الـ Exam

**الـ Trap الأول — Pillar الـ Sustainability:** ناس كتير بتنسى إن Sustainability هو Pillar السادس الأحدث. لو السؤال قال "reduce carbon footprint" أو "minimize environmental impact" → **Sustainability Pillar**.

**الـ Trap الثاني — Reliability vs Performance:** Reliability هو "النظام بيشتغل وبيتعافى." Performance Efficiency هو "النظام بيشتغل بكفاءة." "Auto Scaling" ممكن يندرج تحت الاتنين — بس في سياق الـ Exam: إذا الكلام عن Availability والـ Recovery → Reliability. إذا الكلام عن Efficiency وتوفير Resources → Performance.

**الـ Trap التالت — TAM يبقى في Enterprise بس:** لو السؤال قال "dedicated AWS expert assigned to your account" → **Enterprise Support Plan**.

**الـ Trap الرابع — CAF vs Well-Architected:** الـ Well-Architected Framework هو لـ **Technical Architecture** (بتبني الـ Systems إزاي). الـ AWS CAF هو لـ **Organizational Transformation** (الشركة تتبنّى Cloud إزاي). مختلفين خالص.

**الـ Trap الخامس — CAF Perspectives عدد:** الـ CAF عنده **6 Perspectives** — 3 Business (Business, People, Governance) + 3 Technical (Platform, Security, Operations). مش 4 ولا 5.

**الـ Trap السادس — AWS Marketplace:** اللي بيشتري من Marketplace، الفاتورة بتتضاف على الـ AWS Bill مباشرة — مش فاتورة منفصلة من الـ Vendor.

**الـ Trap السابع — re:Post مش للـ Urgent Questions:** الـ re:Post نفسها بتقول مش مناسبة للأسئلة الـ Time-Sensitive. لو urgent → AWS Support.

**الـ Trap الثامن — Right Sizing قبل وبعد Migration:** Right Sizing مش بس قبل Migration — لازم تكمل تعمله باستمرار بعد ما تنتقل للـ Cloud لأن الـ Requirements بتتغير.

---

## 📝 أسئلة الـ Exam

### Q1. A company wants to evaluate their existing AWS architecture against AWS best practices to identify areas for improvement across security, reliability, and cost. Which FREE tool should they use?

- A. AWS Trusted Advisor
- B. AWS Well-Architected Tool
- C. AWS Config
- D. AWS Cost Explorer

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> الـ **AWS Well-Architected Tool** هو الـ Free Tool المصمم بالظبط لمراجعة الـ Architecture مقارنة بالـ 6 Pillars والحصول على توصيات مخصوصة.
>
> **ليه الباقي غلط:**
> - **A** — Trusted Advisor بيديك Best Practice Recommendations لكنه بيركّز على Security، Cost، Performance، Fault Tolerance — مش مراجعة Architecture شاملة مقارنة بالـ 6 Pillars.
> - **C** — Config بيتتبع التغييرات في الـ Resource Configurations — مش Architecture Review.
> - **D** — Cost Explorer لتحليل التكاليف فقط — مش Architecture Review.

---

### Q2. An organization is planning a cloud migration and needs to align their business strategy with cloud capabilities. They need help managing the cultural and organizational change involved. Which aspect of the AWS Cloud Adoption Framework addresses this?

- A. Platform Perspective
- B. Security Perspective
- C. People Perspective
- D. Operations Perspective

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **People Perspective** في الـ AWS CAF هو اللي بيركّز على الـ Culture والـ Organizational Structure والـ Leadership والـ Workforce — يعني إزاي الناس والفرق بتتغير مع رحلة الـ Cloud.
>
> **ليه الباقي غلط:**
> - **A** — Platform Perspective عن بناء الـ Cloud Platform تقنياً.
> - **B** — Security Perspective عن الـ Confidentiality والـ Integrity.
> - **D** — Operations Perspective عن تشغيل الـ Cloud Services على المستوى المطلوب.

---

### Q3. A company's production application experienced a failure, and recovery took 6 hours due to restoring from backups. Which Well-Architected pillar was most likely not followed?

- A. Performance Efficiency
- B. Cost Optimization
- C. Reliability
- D. Operational Excellence

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **Reliability Pillar** هو اللي بيتكلم عن قدرة النظام على يتعافى من الأعطال بسرعة. Recovery time طويل (6 hours) هو علامة على إن الـ Reliability Design Principles متطبّقةش صح — زي الـ Automated Recovery والـ Tested Recovery Procedures.
>
> **ليه الباقي غلط:**
> - **A** — Performance Efficiency عن كفاءة استخدام الـ Resources — مش الـ Recovery Time.
> - **B** — Cost Optimization عن تقليل التكاليف — مش Recovery.
> - **D** — Operational Excellence عن تحسين العمليات — لكن الـ Reliability أكثر تحديداً للـ Failure Recovery Scenario ده.

---

### Q4. Which AWS support plan provides access to a Technical Account Manager (TAM) and guarantees a response time of less than 15 minutes for business-critical system failures?

- A. Developer
- B. Business
- C. Enterprise
- D. Basic

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **Enterprise Support Plan** هو الوحيد اللي بيوفّر الـ **Technical Account Manager (TAM)** وضمان الـ Response Time < 15 دقيقة لـ Business-Critical System Down.
>
> **ليه الباقي غلط:**
> - **A** — Developer Plan: Business Hours Email بس — Response < 24 Business Hours.
> - **B** — Business Plan: 24x7 Support — لكن Production Down = < 1 ساعة، ومفيش TAM.
> - **D** — Basic Plan: Free — مفيش Personal Support.

---

### Q5. According to the AWS Well-Architected Framework, which design principle belongs to the Cost Optimization pillar?

- A. Automatically recover from failure
- B. Experiment more often
- C. Use tags to analyze and attribute expenditure
- D. Test recovery procedures

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> **Tags** هي من أهم Tools لـ Cost Optimization — بتساعدك تعرف بالظبط مين يصرف على إيه في الـ AWS Account وتحسب الـ ROI بشكل دقيق.
>
> **ليه الباقي غلط:**
> - **A** — "Automatically recover from failure" → **Reliability Pillar**.
> - **B** — "Experiment more often" → **Performance Efficiency Pillar**.
> - **D** — "Test recovery procedures" → **Reliability Pillar**.

---

### Q6. A company wants to purchase third-party software solutions, including custom AMIs and CloudFormation templates, directly through AWS and have the charges added to their AWS bill. Which service should they use?

- A. AWS Partner Network (APN)
- B. AWS IQ
- C. AWS Marketplace
- D. AWS Professional Services

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **AWS Marketplace** هو الـ Digital Catalog للـ Third-Party Software — Custom AMIs، CloudFormation Templates، SaaS، Containers. الدفع بيتضاف على AWS Bill مباشرة.
>
> **ليه الباقي غلط:**
> - **A** — APN هو شبكة الـ Partners اللي بتشتغل مع AWS — مش لشراء Software.
> - **B** — IQ للإيجاد AWS Certified Experts لـ Project Work — مش لشراء Software.
> - **D** — Professional Services هو فريق خبراء AWS — مش لشراء Software.

---

### Q7. Which phase of the AWS Cloud Adoption Framework involves identifying capability gaps across the 6 CAF Perspectives and creating an Action Plan?

- A. Envision
- B. Align
- C. Launch
- D. Scale

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> الـ **Align Phase** هو بالظبط اللي فيه بتحدد الـ Gaps عبر الـ 6 Perspectives وتبني الـ Action Plan بناءً على ده.
>
> **ليه الباقي غلط:**
> - **A** — Envision = تحديد الفرص وكيف Cloud بيسرّع الـ Business Outcomes.
> - **C** — Launch = بناء وتوصيل Pilot Initiatives في Production.
> - **D** — Scale = توسيع الـ Pilot Initiatives للـ Scale الكامل.

---

### Q8. A company needs AWS experts to manage their entire AWS infrastructure, including monitoring, patching, security, and backups, so the company's team can focus on business objectives. Which service provides this?

- A. AWS Support Enterprise Plan
- B. AWS Professional Services
- C. AWS Managed Services (AMS)
- D. AWS IQ

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **AWS Managed Services (AMS)** هو الـ Fully Managed Service اللي فيه AWS بتتكفّل بـ **إدارة الـ Infrastructure كاملة** — Monitoring، Patching، Security، Backup، Change Management. بيخلّي الشركة تركّز على الـ Business بدل العمليات.
>
> **ليه الباقي غلط:**
> - **A** — Enterprise Support Plan بيديك Support وAWS Expert Advice — لكن انت لسه بتدير Infrastructure بتاعك.
> - **B** — Professional Services فريق بيشتغل معك على Projects محددة — مش Ongoing Management.
> - **D** — IQ للإيجاد Freelance AWS Experts لـ Projects محددة — مش Ongoing Management.

---

## 📊 ملخص نهائي — الـ Cheat Sheet

| السؤال | الإجابة |
|--------|---------|
| عدد Pillars في Well-Architected؟ | 6 Pillars |
| أحدث Pillar في Well-Architected؟ | Sustainability (السادس) |
| "recover from failure" → أنهي Pillar؟ | Reliability |
| "pay for what you use" → أنهي Pillar؟ | Cost Optimization |
| "minimize environmental impact" → أنهي Pillar؟ | Sustainability |
| "go global in minutes" → أنهي Pillar؟ | Performance Efficiency |
| "least privilege, IAM" → أنهي Pillar؟ | Security |
| "IaC, automation" → أنهي Pillar؟ | Operational Excellence |
| الـ Well-Architected Tool مجاني؟ | نعم — Free Tool |
| CAF Perspectives عددها؟ | 6 Perspectives |
| CAF Business Perspectives؟ | Business، People، Governance |
| CAF Technical Perspectives؟ | Platform، Security، Operations |
| "Culture & Workforce" → أنهي Perspective؟ | People |
| "Risk Management" → أنهي Perspective؟ | Governance |
| CAF Transformation Phases بالترتيب؟ | Envision → Align → Launch → Scale |
| "identify gaps, create action plan" → أنهي Phase؟ | Align |
| "pilot initiatives in production" → أنهي Phase؟ | Launch |
| Right Sizing بيحصل إمتى؟ | قبل Migration وبعدها باستمرار |
| Tools للـ Right Sizing؟ | CloudWatch، Cost Explorer، Trusted Advisor |
| Support Plan فيه TAM؟ | Enterprise فقط |
| Business Critical Down → أنهي Plan وResponse Time؟ | Enterprise → < 15 دقيقة |
| Production Down → Business Plan Response Time؟ | < 1 ساعة |
| Production Impaired → Business Plan؟ | < 4 ساعات |
| Basic Support بيديك Support Engineer؟ | لا — Trusted Advisor محدود بس |
| AWS Marketplace فاتورته فين؟ | على AWS Bill مباشرة |
| تبيع Products على Marketplace؟ | نعم ممكن |
| AWS IQ هو إيه؟ | بيوصّلك بـ AWS Certified Experts للمشاريع |
| re:Post مناسب للـ Urgent Questions؟ | لا — مش مناسب |
| AMS بيدير الـ Infrastructure كاملاً؟ | نعم — Fully Managed |
| الفرق بين AMS والـ Enterprise Support؟ | AMS = يدير بدلاً منك، Enterprise = يدعمك |
| Carbon Footprint Tracking؟ | AWS Customer Carbon Footprint Tool |
| CAF vs Well-Architected — الفرق؟ | CAF = Org Transformation، WAF = Technical Architecture |

---
*انتهى Domain 3B — Cloud Technology & Services كامل ✅*
