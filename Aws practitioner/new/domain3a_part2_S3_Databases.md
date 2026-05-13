# 🗄️ Cloud Technology & Services — الجزء الثاني
### AWS Certified Cloud Practitioner — CLF-C02
### Amazon S3 + Databases & Analytics

---

## 🪣 الحكاية بتبدأ من سؤال — فين بتخزّن البيانات اللي مش لازمها Server؟

الـ EC2 عنده EBS للـ OS والـ Application، وEFS للـ Shared Files. بس في نوع تاني من البيانات — ملفات، صور، فيديوهات، Backups، Logs، Datasets — دي مش محتاجة File System ولا Block Storage. محتاجة **Object Storage** — وده بالظبط اللي جاء **Amazon S3** عشانه.

الـ S3 واحد من أهم الخدمات في AWS على الإطلاق — مش مجرد تخزين، بس Infrastructure أساسي بيعتمد عليه نص خدمات AWS نفسها.

---

## 🪣 Amazon S3 — المفاهيم الأساسية

الـ S3 بيخزّن **Objects (ملفات)** في **Buckets (مجلدات)**. بس قبل ما نكمل، في فروق دقيقة مهمة:

**الـ Buckets:**
- لازم الاسم يكون **Globally Unique** — على مستوى كل AWS Accounts في كل الـ Regions.
- الـ Bucket نفسه بييتنشأ في **Region محددة** — مش Global.
- الـ S3 بيظهر كـ Global Service في الـ Console — بس الـ Buckets بتخزن في Region.

**قواعد الـ Naming:**
1. بس lowercase letters وأرقام وhyphens.
2. من 3 لـ 63 حرف.
3. مش IP Address.
4. لازم يبدأ بـ Letter أو رقم.
5. مش يبدأ بـ `xn--` ومش ينتهي بـ `-s3alias`.

**الـ Objects:**
- كل Object عنده **Key** — وهو الـ Full Path بتاعه (مثلاً `my_folder/images/photo.jpg`).
- مفيش فكرة Directories حقيقية في S3 — الـ `/` في الـ Key هو مجرد جزء من الاسم.
- أقصى حجم Object واحد هو **5TB**.
- لو هترفع أكتر من 5GB — لازم تستخدم **Multi-Part Upload**.

**الـ Object بيتكون من:**
1. **Value** — محتوى الملف نفسه.
2. **Metadata** — معلومات إضافية (System أو User-Defined).
3. **Tags** — حتى 10 Tags للتصنيف والأمان.
4. **Version ID** — لو الـ Versioning مفعّل.

---

## 🔐 Amazon S3 Security — مين يقدر يوصل لإيه؟

التحكم في الوصول لـ S3 بيمشي من اتجاهين:

**User-Based (IAM):**
بتكتب IAM Policies على الـ User أو الـ Role بتقول إيه الـ API Calls المسموحة. مثلاً: User ده يقدر يعمل `s3:GetObject` بس.

**Resource-Based:**
1. **Bucket Policy** — أهمهم. JSON-Based Policy بتحطها على الـ Bucket نفسه. بتحدد Principal (مين)، Action (إيه)، وEffect (Allow/Deny). بتستخدمها لـ:
   - فتح الـ Bucket للعموم (Public Access).
   - إجبار التشفير على الـ Upload.
   - منح وصول لـ Account AWS تانية (Cross-Account).
2. **Object ACL** — تحكم أدق على مستوى Object — ممكن تعطّله.
3. **Bucket ACL** — أقل شيوعاً — ممكن تعطّله.

**القاعدة:** User يقدر يوصل لـ Object لو:
- الـ IAM Policy بتاعه بتسمحه **أو** الـ Bucket Policy بتسمحه.
- **و** مفيش Explicit Deny.

**Block Public Access:** إعدادات على مستوى الـ Bucket أو الـ Account بتمنع أي Public Access حتى لو فيه Bucket Policy بتفتحه. بتشغّلها كـ Safety Net لو Bucket ما المفروضش يكون Public أبداً.

---

## 🌐 Static Website Hosting

الـ S3 يقدر يـ Host **Static Websites** (HTML, CSS, JS, صور) مباشرة من غير Server. بعد التفعيل، الـ Website بتكون على URL بالشكل:

```
http://bucket-name.s3-website-aws-region.amazonaws.com
```

لو بتاخد **403 Forbidden** — ده معناه إن الـ Bucket Policy مش بتسمح بـ Public Read.

---

## 🔄 S3 Versioning

الـ Versioning بيخليك تحتفظ بكل إصدار من كل ملف. لما تـ Upload نفس الـ File تاني — S3 ما بيمسحش القديم بل بيحتفظ بالاتنين بـ Version IDs مختلفة.

الفوايد:
1. حماية من الحذف الغلط — ممكن ترجع لأي Version سابق.
2. Rollback سهل للإصدار السابق.

نقاط مهمة:
1. الـ Versioning بيتفعّل على مستوى الـ Bucket.
2. أي File اتخزّن قبل تفعيل الـ Versioning هياخد Version ID = `null`.
3. إيقاف الـ Versioning (Suspend) مش بيحذف الـ Versions السابقة.

---

## 🔁 S3 Replication — نسخ عبر Regions والـ AZs

الـ Replication بيعمل نسخة تلقائية ومتزامنة من الـ Bucket في مكان تاني:

1. **CRR (Cross-Region Replication)** — النسخ في Region مختلف. للـ Compliance والـ Disaster Recovery والوصول بـ Latency منخفض للمستخدمين في مناطق مختلفة.
2. **SRR (Same-Region Replication)** — النسخ في نفس الـ Region. لـ Log Aggregation والـ Live Replication بين البيئات المختلفة.

شروط:
1. لازم تفعّل الـ Versioning في الـ Source والـ Destination Buckets.
2. الـ Copying بيحصل **Asynchronously** في الخلفية.
3. لازم تدي الـ S3 IAM Permissions مناسبة.
4. الـ Buckets ممكن تكون في **AWS Accounts مختلفة**.

---

## 📂 S3 Storage Classes — مش كل البيانات بتاخد نفس المعاملة

AWS بتوفر تدرّج في الـ Storage Classes بين السرعة والتكلفة. كلما أرخص — كلما الاسترداد أبطأ أو أغلى.

**الأساس اللي لازم تعرفه:**
- **Durability** — ثابتة لكل الـ Classes: **11 nines** (99.999999999%). لو عندك مليار ملف، متوقع تضيع ملف كل 10,000 سنة.
- **Availability** — بتتفاوت حسب الـ Class.

**الـ Classes السبعة:**

**1 — S3 Standard (General Purpose):**
الـ Default. للبيانات اللي بتوصّلها بشكل متكرر. 99.99% Availability. يتحمل فشل AZ اتنين في نفس الوقت. يستخدم لـ:
- Big Data Analytics.
- Mobile وGaming Applications.
- Content Distribution.

**2 — S3 Standard-IA (Infrequent Access):**
للبيانات اللي بتوصّلها أحياناً بس لازم تيجي بسرعة لما توصّلها. أرخص في التخزين من Standard — بس فيه Retrieval Cost. 99.9% Availability. يستخدم لـ Disaster Recovery والـ Backups.

**3 — S3 One Zone-IA:**
زي Standard-IA بس في AZ واحدة بس. لو الـ AZ دي اتدمرت — البيانات اتفقدت. أرخص بـ 20% من Standard-IA. 99.5% Availability. يستخدم لـ Secondary Backups اللي تقدر تعمل منها نسخة أخرى.

**4 — S3 Glacier Instant Retrieval:**
تخزين أرشيف رخيص مع Retrieval سريع (Milliseconds). أقل مدة تخزين 90 يوم. للبيانات اللي بتوصّلها مرة في الربع (Quarter).

**5 — S3 Glacier Flexible Retrieval:**
تخزين أرشيف رخيص جداً — بس الاسترداد بياخد وقت:
- Expedited: 1-5 دقائق.
- Standard: 3-5 ساعات.
- Bulk: 5-12 ساعة (مجاني).

أقل مدة تخزين 90 يوم.

**6 — S3 Glacier Deep Archive:**
الأرخص على الإطلاق — للأرشيف طويل الأمد:
- Standard: 12 ساعة.
- Bulk: 48 ساعة.

أقل مدة تخزين 180 يوم. للبيانات اللي نادراً ما تحتاجها — زي Legal Archives وRegulatory Compliance.

**7 — S3 Intelligent-Tiering:**
بيحرّك الـ Objects تلقائياً بين الـ Tiers بناءً على الاستخدام الفعلي. مناسب لما مش عارف Pattern الوصول للبيانات. فيه رسوم صغيرة للـ Monitoring. الـ Tiers:
1. Frequent Access (Default).
2. Infrequent Access (بعد 30 يوم بدون وصول).
3. Archive Instant Access (بعد 90 يوم).
4. Archive Access — Optional (من 90 لـ 700+ يوم).
5. Deep Archive Access — Optional (من 180 لـ 700+ يوم).

> [!abstract]+ ملخص الـ Classes للحفظ السريع
>
> | Class | الاستخدام | Min Duration |
> |-------|-----------|-------------|
> | Standard | Frequent Access | لا يوجد |
> | Standard-IA | Occasional Access, Fast Retrieval | 30 يوم |
> | One Zone-IA | Secondary Backups في AZ واحدة | 30 يوم |
> | Glacier Instant | Archive — ربع سنوي | 90 يوم |
> | Glacier Flexible | Archive — ساعات | 90 يوم |
> | Glacier Deep Archive | Archive طويل الأمد — أيام | 180 يوم |
> | Intelligent-Tiering | Unknown Pattern | لا يوجد |

**S3 Lifecycle Policies:** بتعمل Rules تحرّك الـ Objects تلقائياً بين الـ Classes بناءً على العمر. مثلاً: "بعد 30 يوم انقل لـ Standard-IA، وبعد 90 يوم انقل لـ Glacier."

---

## 🔏 S3 Encryption

نوعان من التشفير:
1. **Server-Side Encryption (Default)** — AWS بتشفّر الملف بعد ما بيوصلها. ده الـ Default حالياً.
2. **Client-Side Encryption** — إنت بتشفّر الملف قبل ما ترفعه.

---

## 🚛 AWS Snowball — لما الإنترنت مش كافي

تخيل إنك عندك Petabytes من البيانات تحتاج تنقلها لـ AWS. الحساب بسيط:

| الحجم | على 100 Mbps |
|-------|-------------|
| 10 TB | 12 يوم |
| 100 TB | 124 يوم |
| 1 PB | 3 سنين! |

القاعدة: **لو النقل هياخد أكتر من أسبوع — استخدم Snowball.**

الـ **Snowball Edge** هو Device فيزيائي AWS بترسهوالك، بتحمّل عليه بياناتك، وبترجعه لـ AWS تشحنه. نوعان:
1. **Snowball Edge Storage Optimized** — 210 TB و104 vCPUs.
2. **Snowball Edge Compute Optimized** — 28 TB بس بـ Compute قوي.

**Edge Computing مع Snowball:** في الأماكن اللي ما فيهاش إنترنت أو Connectivity ضعيف (سفينة، منجم، شاحنة على الطريق) — بتحط Snowball Edge تشغّل عليه EC2 Instances أو Lambda Functions وتعالج البيانات locally.

---

## 🌉 AWS Storage Gateway — الجسر بين الـ On-Premises وCloud

لما الشركة عندها Infrastructure On-Premises وعايزة تبدأ تستخدم S3 بدون ما تغيّر كل حاجة — الـ **Storage Gateway** هو الحل. بيعمل **Bridge** بين الـ On-Premises وS3 عبر 3 أنواع:
1. **File Gateway** — بيعرض الـ S3 Bucket كـ NFS أو SMB File Share.
2. **Volume Gateway** — بيعرض الـ Cloud Storage كـ iSCSI Block Storage.
3. **Tape Gateway** — بيعوّض الـ Tape Backup التقليدي بـ S3 وGlacier.

> [!important] Storage Gateway في الامتحان
> لو السؤال قال "Hybrid Cloud Storage" أو "extend on-premises storage to S3" أو "seamless access to S3 from on-premises" → **AWS Storage Gateway**.

---

## 🎯 فخاخ S3

**الـ Trap الأول — Bucket Name Global, Bucket Regional:** الـ Bucket Name لازم يكون Unique على مستوى كل AWS في العالم — بس الـ Bucket نفسه بييتنشأ في Region معينة.

**الـ Trap التاني — Versioning ما بيمسحش القديم:** لما تعمل Delete على Object وفيه Versioning — S3 بيضيف "Delete Marker" ومش بيمسح الـ Versions القديمة.

**الـ Trap التالت — One Zone-IA مش للـ Critical Data:** لو الـ AZ اتدمرت — البيانات اتضاعت. بس Durability 11 nines جوه الـ AZ نفسها.

**الـ Trap الرابع — Glacier ≠ Instant:** لو السؤال قال "millisecond retrieval" وGlacier — الإجابة **Glacier Instant Retrieval** مش Glacier Flexible.

---

## 🗃️ الجزء الثاني — Databases & Analytics

---

## 📊 الحكاية بتبدأ من — ليه Database مش S3؟

الـ S3 ممتاز لتخزين الملفات — بس مش مناسب للبيانات المنظّمة اللي محتاج تعمل عليها Queries سريعة، ترابط بين الجداول، وفهرسة. الـ Databases بتحل المشكلة دي. وفي AWS، في نوعان أساسيان: **Relational** (SQL) و**NoSQL**.

---

## 🐘 Amazon RDS — الـ Database الـ Managed

الـ **RDS (Relational Database Service)** هو Managed Service بيشغّل Relational Databases. بتختار الـ Engine اللي تحبه:
1. PostgreSQL
2. MySQL
3. MariaDB
4. Oracle
5. Microsoft SQL Server
6. IBM DB2
7. Amazon Aurora (الـ Aurora بنشرحها لوحدها)

**إيه اللي AWS بتديره نيابةً عنك؟**
1. Automated Provisioning وOS Patching.
2. Continuous Backups — Point in Time Restore.
3. Monitoring Dashboards.
4. Read Replicas لتحسين الـ Read Performance.
5. Multi-AZ Setup للـ Disaster Recovery.
6. Maintenance Windows للـ Upgrades.
7. Vertical وHorizontal Scaling.

**المقابل:** مش هتقدر تـ SSH على الـ Instance بتاع الـ RDS — AWS مش بتديك وصول مباشر.

**RDS Deployments — ثلاث طرق:**

**1 — Read Replicas:**
بتعمل نسخ قراءة من الـ Database الرئيسي. تقدر تعمل حتى 15 Read Replica. الـ Writes بتروح للـ Main فقط، الـ Reads ممكن يتوزعوا على الـ Replicas. بيخفّف الحِمل على الـ Main DB.

**2 — Multi-AZ:**
بيعمل Standby DB في AZ تانية. لو الـ Main DB وقع — AWS تلقائياً بتـ Failover للـ Standby. الـ Standby ما ينفعش للـ Read — هو بس للـ DR.

**3 — Multi-Region:**
Read Replicas في Regions مختلفة. للـ DR في حالة فشل الـ Region كامل، وللـ Users في مناطق تانية يوصلوا بـ Latency منخفض. بس فيه Replication Cost.

---

## ⚡ Amazon Aurora — الـ Database الـ AWS

الـ **Aurora** هو Database من تصميم AWS — مش Open Source. بيدعم PostgreSQL وMySQL كـ Engines.

مميزاته:
1. **5x أسرع** من MySQL على RDS، **3x أسرع** من PostgreSQL.
2. **Storage بينمو تلقائياً** بزيادات 10GB، حتى 256TB.
3. **أغلى بـ 20%** من RDS — بس الـ Performance أعلى.
4. **Aurora Serverless** — بيتوسع ويتضيق تلقائياً. مدفوع بالثانية. مناسب للـ Workloads غير المتوقعة أو المتقطعة.

> [!important] Aurora في الامتحان
> "AWS cloud-optimized database" أو "5x faster than MySQL" → **Aurora**.
> "Infrequent, intermittent, or unpredictable workloads" → **Aurora Serverless**.

---

## ⚡ Amazon ElastiCache — الـ In-Memory Cache

تخيل إن الـ Application بتروح للـ Database لكل Request. لو الـ Request هي نفسها بتتكرر (مثلاً: اجيب أعلى 10 منتجات مباعة) — بتعمل نفس الـ Query مئات المرات في الثانية. الـ **ElastiCache** بيحل ده.

الـ ElastiCache هو Managed Service لـ **Redis** أو **Memcached** — In-Memory Databases بـ Latency أقل من Millisecond. النتائج الشائعة بتتخزن في الـ Cache، والـ Application بتقراهم منه مباشرة بدل الرجوع للـ Database.

الفرق بين الاتنين:
- **Redis** — أكثر features، بيدعم الـ Persistence والـ HA والـ Pub/Sub.
- **Memcached** — أبسط، للـ Caching البسيط.

> [!important] ElastiCache في الامتحان
> "Reduce database load" أو "in-memory cache" أو "sub-millisecond latency" → **ElastiCache**.

---

## 🔑 Amazon DynamoDB — الـ NoSQL الـ Serverless

الـ **DynamoDB** هو الـ Fully Managed NoSQL Database من AWS. مصمم للـ Scale الضخم جداً:

1. Fully Managed — مفيش Provisioning أو Patching.
2. Highly Available — Replication عبر **3 AZs**.
3. يقدر يتعامل مع **ملايين Requests في الثانية**.
4. **Trillions of Rows وhundreds of TB** من الـ Storage.
5. **Single-digit millisecond latency**.
6. **Serverless** — مفيش Servers تديرها.
7. بياكل Key-Value Data.

**DynamoDB Global Tables:** بيعمل Active-Active Replication في Regions متعددة. يعني تقدر تكتب وتقرأ من أي Region. للـ Users الموزعين على العالم.

**DynamoDB Accelerator (DAX):**
Fully Managed In-Memory Cache **متخصص لـ DynamoDB**. بيحوّل الـ Single-digit ms latency لـ **Microseconds**. الفرق بينه وبين ElastiCache:
- DAX = فقط مع DynamoDB.
- ElastiCache = مع أي Database.

> [!important] DynamoDB في الامتحان
> "Serverless NoSQL database" أو "key-value" أو "millions of requests/second" → **DynamoDB**.
> "Cache for DynamoDB" → **DAX**.
> "Cache for RDS/Aurora" → **ElastiCache**.

---

## 📈 Amazon Redshift — الـ Data Warehouse

الـ **Redshift** ليس للـ OLTP (Online Transaction Processing) زي RDS — هو للـ **OLAP (Online Analytical Processing)**. يعني مش للـ Transactions اليومية العادية، لكن لتحليل كميات ضخمة من البيانات.

مميزاته:
1. مبني على PostgreSQL — بس للـ Analytics.
2. **10x أسرع** من Data Warehouses تانية.
3. يتعامل مع **Petabytes** من البيانات.
4. **Columnar Storage** بدل Row-Based — أسرع للـ Analytics.
5. **Massively Parallel Query Execution (MPP)**.
6. SQL Interface للـ Queries.
7. بيتكامل مع QuickSight وTableau.
8. **Redshift Serverless** — بيوفرلك Redshift من غير إدارة Infrastructure.

> [!important] RDS vs Redshift
> - **RDS** = OLTP — Transactions يومية، عمليات CRUD.
> - **Redshift** = OLAP — تحليل البيانات، BI، Data Warehouse.

---

## 🗂️ Amazon EMR — Big Data على Hadoop

الـ **EMR (Elastic MapReduce)** بيساعدك تنشئ **Hadoop Clusters** على AWS لمعالجة Data ضخم. بيدعم كمان Apache Spark وHBase وPresto وFlink.

مميزاته:
1. بيتعامل مع مئات الـ EC2 Instances في Cluster.
2. بيعمل كل الـ Provisioning والـ Configuration تلقائياً.
3. Auto-Scaling ومتكامل مع الـ Spot Instances لتوفير التكلفة.

الـ Use Cases: Data Processing وMachine Learning وWeb Indexing وBig Data Analytics.

---

## 🔍 Amazon Athena — SQL على S3

الـ **Athena** هو Serverless Query Service بيخليك تعمل **SQL Queries مباشرة على ملفات في S3** — من غير ما تنقل البيانات لـ Database.

مميزاته:
1. بيدعم CSV وJSON وORC وAvro وParquet.
2. Pricing بسيط: $5 لكل TB من البيانات المـ Scanned.
3. لو استخدمت Compressed أو Columnar Data — بيسكان أقل وتدفع أقل.

الـ Use Cases:
1. Business Intelligence والـ Analytics والـ Reporting.
2. تحليل VPC Flow Logs وELB Logs وCloudTrail.

> [!important] Athena في الامتحان
> "Serverless SQL queries on S3" → **Amazon Athena** دايماً.

---

## 📊 Amazon QuickSight — الـ BI Dashboards

الـ **QuickSight** هو Serverless BI Service بيخليك تعمل Interactive Dashboards وVisualizations. بيتكامل مع RDS وAurora وAthena وRedshift وS3.

الـ Use Cases:
1. Business Analytics.
2. بناء Visualizations.
3. Ad-Hoc Analysis.
4. Business Insights من البيانات.

---

## 🍃 Amazon DocumentDB — الـ MongoDB على AWS

زي Aurora بالنسبة لـ PostgreSQL وMySQL — الـ **DocumentDB** هو "Aurora for MongoDB". MongoDB هو NoSQL Database بيخزّن JSON Documents.

مميزاته:
1. Fully Managed وHighly Available مع Replication عبر 3 AZs.
2. Storage بينمو تلقائياً بزيادات 10GB.
3. يتعامل مع ملايين Requests في الثانية.

---

## 🔗 Amazon Neptune — الـ Graph Database

الـ **Neptune** هو Fully Managed Graph Database. مصمم للـ Data اللي فيه علاقات معقدة ومترابطة. المثال الكلاسيكي هو الـ Social Network:
1. Users عندهم Friends.
2. Posts عندهم Comments.
3. Comments عندهم Likes من Users.
4. Users بيـ Share ويـ Like Posts.

مميزاته:
1. Highly Available عبر 3 AZs مع 15 Read Replicas.
2. بيخزّن مليارات العلاقات.
3. Millisecond Latency للـ Graph Queries.

الـ Use Cases: Knowledge Graphs (زي Wikipedia)، Fraud Detection، Recommendation Engines، Social Networking.

---

## ⏱️ Amazon Timestream — قاعدة بيانات الـ Time Series

الـ **Timestream** هو Serverless Database للـ Time Series Data — يعني بيانات مرتبطة بالوقت بشكل أساسي. مثلاً: قراءات IoT Sensors كل ثانية، Metrics للـ Application، Financial Data.

مميزاته:
1. Serverless — بيتوسع تلقائياً.
2. بيخزّن **Trillions of Events** في اليوم.
3. **1000x أسرع** من Relational Databases وبـ 10% من التكلفة.
4. Built-in Time Series Analytics Functions.

---

## ⛓️ Amazon Managed Blockchain

الـ **Blockchain** بيبني Applications بتنفّذ Transactions من غير ما تحتاج Trusted Central Authority. الـ **Amazon Managed Blockchain** هو Managed Service لـ:
1. الانضمام لـ Public Blockchain Networks.
2. أو بناء Private Blockchain Network.

يدعم Hyperledger Fabric وEthereum.

---

## 🔄 AWS Glue — الـ ETL Service

الـ **Glue** هو Serverless ETL (Extract, Transform, Load) Service. بيعملك:
1. **Extract** — بياخد البيانات من RDS أو S3.
2. **Transform** — بيحوّلها ويعمل عليها Processing.
3. **Load** — بيحطها في Redshift أو S3.

فيه برضو **Glue Data Catalog** — فهرس لكل الـ Datasets بتاعتك، بيستخدمه Athena وRedshift وEMR.

---

## 🚚 DMS — Database Migration Service

الـ **DMS (Database Migration Service)** بيساعدك تنقل الـ Databases لـ AWS بأمان وبسرعة. الـ Source Database بيفضل Available أثناء الـ Migration — مش هيحصل Downtime.

بيدعم:
1. **Homogeneous Migrations** — نفس الـ Engine (Oracle لـ Oracle).
2. **Heterogeneous Migrations** — Engines مختلفة (SQL Server لـ Aurora).

---

## 🎯 فخاخ الـ Databases

**الـ Trap الأول — RDS vs Redshift:** RDS = OLTP (Transactions يومية). Redshift = OLAP (Analytics وData Warehouse). لو السؤال قال "analytics" أو "data warehouse" → **Redshift** مش RDS.

**الـ Trap التاني — DAX vs ElastiCache:** DAX = Cache للـ DynamoDB بس. ElastiCache = Cache لأي Database (RDS، Aurora، إلخ).

**الـ Trap التالت — DynamoDB = Serverless NoSQL:** لما السؤال يقول "serverless" و"NoSQL" و"millisecond latency" مع بعض → **DynamoDB**.

**الـ Trap الرابع — Athena = Serverless SQL على S3:** لو في S3 ومحتاج SQL Queries بدون Database → **Athena**.

**الـ Trap الخامس — Neptune = Graph، Timestream = Time Series:** اسم الـ Use Case بيفضح الإجابة — Social Networks وFraud Detection → **Neptune**. IoT وMetrics وTime Data → **Timestream**.

---

## 📝 أسئلة الـ Exam

### Q1. A company needs a fully managed relational database on AWS. They want automatic backups, read replicas, and multi-AZ deployment without managing the underlying OS. Which service should they use?

- A. EC2 with a self-managed database
- B. Amazon RDS
- C. Amazon Redshift
- D. Amazon DynamoDB

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> الـ **RDS** هو الـ Managed Relational Database بيوفر كل اللي ذكره السؤال: Automated Backups، Read Replicas، Multi-AZ — من غير ما تتعامل مع الـ OS.
>
> **ليه الباقي غلط:**
> - **A** — EC2 بتدير فيه الـ Database نفسك — هتحتاج تعمل Backup وPatching وHA بنفسك.
> - **C** — Redshift للـ OLAP والـ Data Warehousing — مش للـ Transactional Databases العادية.
> - **D** — DynamoDB NoSQL — مش Relational.

---

### Q2. A startup is building an application that needs to handle 10 million reads per second with single-digit millisecond latency. The data is structured as simple key-value pairs. Which AWS database service best meets this requirement?

- A. Amazon RDS Aurora
- B. Amazon Redshift
- C. Amazon DynamoDB
- D. Amazon ElastiCache

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **DynamoDB** هو الخيار المثالي — مصمم للـ Scale الضخم (ملايين Requests في الثانية)، بـ Single-Digit Millisecond Latency، وبيتعامل مع Key-Value Data بشكل طبيعي. وهو Serverless.
>
> **ليه الباقي غلط:**
> - **A** — Aurora رائع — بس هو Relational Database. ما بيناسبش Key-Value بشكل مثالي على الـ Scale ده.
> - **B** — Redshift للـ Analytics — مش للـ High-Frequency Transactions.
> - **D** — ElastiCache In-Memory Cache — مش Database أساسي. بيستخدم مع Database أخرى.

---

### Q3. A data analytics team needs to run SQL queries on 5TB of log files stored in Amazon S3 without setting up any infrastructure. Which service should they use?

- A. Amazon Redshift
- B. Amazon RDS
- C. Amazon Athena
- D. AWS Glue

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **Amazon Athena** هو بالظبط اللي السؤال بيوصفه — Serverless SQL على S3 بدون Infrastructure. بتكتب SQL Query وبتشتغل مباشرة على الملفات.
>
> **ليه الباقي غلط:**
> - **A** — Redshift Data Warehouse — محتاج تحمّل البيانات فيه أولاً.
> - **B** — RDS Relational Database — محتاج تنقل البيانات إليه.
> - **D** — Glue هو ETL Service — بيحضّر البيانات. لكن مش بيعمل الـ Queries نفسها.

---

### Q4. An e-commerce platform's homepage loads product listings from a database. The same queries run thousands of times per minute. The database is becoming a bottleneck. Which service can reduce the load with microsecond latency?

- A. Amazon ElastiCache for Redis
- B. Amazon DynamoDB DAX
- C. Amazon RDS Read Replica
- D. Amazon CloudFront

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: A**
>
> الـ **ElastiCache for Redis** هو الأنسب لـ Caching نتائج الـ Database الـ Relational (RDS/Aurora) لتخفيف الـ Load. بيوفر Sub-Millisecond Latency.
>
> **ليه الباقي غلط:**
> - **B** — DAX Cache خاص بـ DynamoDB فقط — لو الـ Database هو RDS مش DynamoDB.
> - **C** — Read Replica بيتخفف الـ Read Load على الـ Main DB — بس ما بيوفرش Caching Layer بـ Microsecond Latency.
> - **D** — CloudFront CDN للـ Static Content — مش لـ Database Query Results.

---

### Q5. A company wants to migrate their on-premises SQL Server database to Amazon Aurora. The source database must remain online during the migration. Which service should they use?

- A. AWS Snowball
- B. AWS Database Migration Service (DMS)
- C. AWS DataSync
- D. AWS Transfer Family

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: B**
>
> الـ **DMS** هو المصمم بالظبط لهجرة الـ Databases مع الحفاظ على الـ Source Database Online أثناء الـ Migration. وهجرة SQL Server لـ Aurora هي **Heterogeneous Migration** — وده بيدعمها.
>
> **ليه الباقي غلط:**
> - **A** — Snowball لنقل البيانات الضخمة فيزيائياً — مش لـ Database Migration.
> - **C** — DataSync لنقل الملفات بين Storage Services — مش لـ Database Migration.
> - **D** — Transfer Family لـ FTP/SFTP/FTPS Transfer — مش لـ Database Migration.

---

### Q6. A company needs to store and query billions of time-stamped IoT sensor readings with near-real-time analytics. Which database is purpose-built for this use case?

- A. Amazon DynamoDB
- B. Amazon RDS
- C. Amazon Timestream
- D. Amazon Neptune

> [!success]- ✅ Reveal Answer & Explanation
> **Correct Answer: C**
>
> الـ **Amazon Timestream** هو الـ Database المصمم للـ Time Series Data — IoT Sensors وMetrics وTime-Stamped Events. بيخزّن Trillions of Events في اليوم بتكلفة أقل بكتير من الـ Relational Databases.
>
> **ليه الباقي غلط:**
> - **A** — DynamoDB يقدر يتعامل مع الـ Use Case ده — بس Timestream أفضل وأرخص للـ Time Series بالذات.
> - **B** — RDS مش مصمم للـ Scale ده ولا للـ Time Series Analytics.
> - **D** — Neptune للـ Graph Databases والعلاقات المعقدة — مش للـ Time Series.

---

## 📊 الـ Cheat Sheet — S3 + Databases

| السؤال | الإجابة |
|--------|---------|
| S3 Bucket Name | Globally Unique |
| S3 Bucket Location | Regional |
| Max Object Size | 5TB |
| Upload > 5GB | Multi-Part Upload |
| S3 Default Inbound Traffic | Blocked |
| Bucket Policy Cross-Account | Resource-Based |
| Replicate across Regions | CRR — Versioning مطلوب |
| Most Frequent Access | S3 Standard |
| Occasional Access, Fast Retrieval | Standard-IA |
| Archive — Milliseconds Retrieval | Glacier Instant Retrieval |
| Archive — Hours Retrieval | Glacier Flexible Retrieval |
| Long-Term Archive — Days Retrieval | Glacier Deep Archive |
| Auto-moves between tiers | Intelligent-Tiering |
| Offline Data Migration (Petabytes) | AWS Snowball |
| On-Prem to S3 Hybrid | Storage Gateway |
| Managed Relational DB (SQL) | Amazon RDS |
| AWS-Optimized Relational DB | Amazon Aurora |
| In-Memory Cache (General) | ElastiCache |
| Serverless NoSQL Key-Value | DynamoDB |
| Cache for DynamoDB | DAX |
| Cache for RDS/Aurora | ElastiCache |
| OLAP / Data Warehouse | Amazon Redshift |
| Big Data / Hadoop Clusters | Amazon EMR |
| Serverless SQL on S3 | Amazon Athena |
| BI Dashboards | Amazon QuickSight |
| NoSQL JSON Documents | Amazon DocumentDB |
| Graph Database | Amazon Neptune |
| Time Series Data | Amazon Timestream |
| Blockchain | Amazon Managed Blockchain |
| ETL Service | AWS Glue |
| Database Migration | AWS DMS |

---

*الجزء الجاي: **Other Compute (Docker, ECS, Fargate, Lambda, API Gateway)** + **Deploying at Scale (CloudFormation, CDK, Beanstalk, Developer Tools, SSM)** + **Cloud Integration (SQS, SNS, Kinesis, MQ)**.*
