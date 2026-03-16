# 🔐 IAM — Identity and Access Management
**AWS Certified Cloud Practitioner — CLF-C02**
*Senior AWS Solutions Architect | 20+ Years Experience*

---

## 🚪 الحكاية بتبدأ بسؤال بسيط — مين يقدر يدخل؟

تخيل إنك بنيت شركة ناجحة على AWS. عندك Servers شغالة، Databases مليانة بيانات، Storage فيه ملفات حساسة. الشركة بدأت تكبر وبدأت تشغّل موظفين — Developers وOps Engineers وAccountants وData Analysts. السؤال اللي بيطرح نفسه فوراً: **هل كل الموظفين دول المفروض يوصلوا لكل حاجة؟**

الـ Developer مش محتاج يشوف فواتير الـ Billing. الـ Accountant مش محتاج يحذف Servers. الـ Junior Developer مش المفروض يمسح الـ Production Database. لو الكل عنده صلاحية كل حاجة — يوم واحد غلطة بسيطة أو اختراق صغير ممكن يمسح كل حاجة بنيتها.

ده بالظبط المشكلة اللي **IAM** جاي يحلها.

---

## 🧠 IAM — الحارس الرسمي لـ AWS Account بتاعتك

الـ **IAM (Identity and Access Management)** هو الخدمة اللي بتتحكم في **مين** يقدر يدخل على الـ AWS Account بتاعتك، و**إيه** اللي مسموحله يعمله.

أهم حاجة تعرفها عن IAM قبل أي حاجة تانية: هو **Global Service** — يعني مش مرتبط بـ Region معين. لما بتعمل IAM User، ده User موجود في كل الـ AWS Regions تلقائياً من غير ما تعمل حاجة.

---

## 👑 الـ Root Account — اللي المفروض متلمهوش

لما بتفتح AWS Account جديدة لأول مرة، بيتعمل تلقائياً حاجة اسمها **Root Account**. ده الأكونت الإله — ليه صلاحية على **كل حاجة** في الـ AWS Account بدون استثناء. يقدر يعمل Billing Changes، يحذف كل الـ Resources، يغير إعدادات الأمان، يغلق الـ Account كلها.

المشكلة مش في وجوده — المشكلة في استخدامه بشكل يومي. لو حد حصل على الـ Root credentials بأي طريقة — Game Over. عشان كده القاعدة الذهبية اللي بتيجي في الـ Exam دايماً:

> **الـ Root Account بتستخدمها مرة واحدة بس — عند الـ Setup الأولي. بعدها بتعمل IAM Admin User وبتشتغل منه. ومش بتشاركها مع حد أبداً.**

---

## 👥 Users وGroups — هيكل المؤسسة

بعد ما عملت الـ Root Account وأمّنتها، جه وقت تنظيم الناس اللي هيشتغلوا على الـ Account.

الـ **IAM Users** هم الأشخاص الحقيقيين في مؤسستك — كل واحد بياخد User خاص بيه بـ Username وPassword. كل User بيمثل شخص واحد بعينه.

الـ **IAM Groups** هي طريقة تنظيم الـ Users في مجموعات منطقية. بدل ما تدي كل Developer صلاحياته منفردة — بتعمل Group اسمها "Developers" وبتحط فيها كل الـ Developers، وبتدي الـ Group الصلاحيات — وكل User جوه الـ Group بياخدها تلقائياً.

فيه قواعد مهمة:
- الـ Groups بتحتوي على **Users فقط** — مش ممكن تحط Group جوه Group.
- الـ User **مش مجبور** يكون في Group.
- الـ User ممكن يكون في **أكتر من Group** في نفس الوقت.

---

## 📋 الـ Policies — قانون الصلاحيات المكتوب

الصلاحيات في AWS مش كلام — هي **JSON Documents** رسمية اسمها **Policies**. كل Policy بتقول بالظبط: "مسموح أو ممنوع — تعمل الـ Action ده — على الـ Resource ده."

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
```

الـ Policy دي بتقول: "مسموحلك تشوف (Describe) كل الـ EC2 Resources." بس بتشوف — مش تحذف أو تعدّل.

كل Policy بتتكون من:
- **Version** — دايماً `"2012-10-17"` — ده مش تاريخ، ده اسم الـ Policy Language Version.
- **Statement** — الجزء الأساسي اللي فيه القواعد.
- **Effect** — إما `Allow` أو `Deny`. لو في تعارض — الـ **Deny بيكسب دايماً**.
- **Action** — الفعل المحدد زي `s3:GetObject` أو `ec2:StartInstances`.
- **Resource** — على إيه بتطبق القاعدة. `"*"` يعني كل حاجة.
- **Principal** — مين اللي الـ Policy دي بتأثر عليه (في بعض أنواع الـ Policies).
- **Condition** — شروط إضافية (اختيارية).

---

## 🔗 الـ Inheritance — الصلاحيات بتتوارث

لما بتدي Group صلاحية، كل User جوه الـ Group بيورّثها تلقائياً. Alice في الـ Developers Group؟ بتاخد صلاحيات الـ Developers. Alice كمان في الـ Audit Team؟ بتاخد صلاحيات الاتنين مع بعض.

ومش لازم تكون في Group — ممكن تدي User صلاحية مباشرة اسمها **Inline Policy**. بس ده مش الـ Best Practice — الأحسن دايماً تشتغل بـ Groups.

القاعدة الأهم: **الـ Deny بيكسب الـ Allow دايماً** لو الاتنين موجودين في نفس الوقت على نفس الـ Resource.

---

## ⚖️ مبدأ الـ Least Privilege — أقل صلاحيات ممكنة

ده المبدأ الأساسي في كل الـ IAM. المعنى بسيط: **تدي الـ User بس اللي يحتاجه بالظبط — لا أكتر.**

ليه؟ لأن كل صلاحية زيادة هي خطر زيادة. لو حساب موظف اتاخد (Compromised)، الـ Damage بيكون محدود بصلاحياته هو بس. الشركات اللي اتهكت تاريخياً — السبب الأول دايماً كان Overpermissioned Users.

---

## 🔒 تأمين الـ Account — الطبقتان الأساسيتان

بعد ما نظّمت الـ Users والـ Permissions، فيه طبقتان أمان أساسيتان لازم تفعلهم.

**الطبقة الأولى — Password Policy:**
بتحدد قواعد إلزامية لكلمات المرور على كل الـ IAM Users في الـ Account. تقدر تشترط: طول أدنى، Uppercase وLowercase وأرقام وSpecial Characters، تغيير الباسورد كل فترة (Expiration)، ومنع إعادة استخدام باسورد قديم.

**الطبقة التانية — MFA (Multi-Factor Authentication):**
الـ MFA هو الحارس التاني. المعادلة:

> **MFA = شيء بتعرفه (الباسورد) + شيء بتمتلكه (Device أو App)**

حتى لو حد سرق الباسورد — مش هيقدر يدخل بدون الـ MFA Device. الـ Root Account وكل الـ Admin Users **لازم** يبقى عليهم MFA — ده مش اختياري.

**أنواع الـ MFA Devices على AWS:**
- **Virtual MFA** — Apps زي Google Authenticator أو Authy على الموبايل. بتدعم أكتر من Account على نفس الـ App.
- **U2F Security Key** — جهاز فيزيائي زي YubiKey. بتحطه في الـ USB. بيدعم أكتر من Root وIAM User على نفس الـ Key.
- **Hardware Key Fob** — جهاز فيزيائي من Gemalto بيولّد كود. للـ Standard Accounts.
- **Hardware Key Fob لـ GovCloud** — نفس الفكرة بس من SurePassID، مخصص لـ AWS GovCloud للحكومة الأمريكية.

---

## 🖥️ إزاي بتدخل على AWS — ثلاث طرق بس

فيه ثلاث طرق فقط للتعامل مع AWS:

**الأولى — AWS Management Console:**
الموقع الرسمي `console.aws.amazon.com`. بتدخل بـ Username + Password + MFA. ده اللي بتستخدمه كإنسان بيشتغل يدوياً.

**التانية — AWS CLI (Command Line Interface):**
بتشتغل من Terminal على الكمبيوتر بتاعك. بتكتب commands مباشرة زي `aws s3 ls` وبترجعلك النتيجة. مش محمية بـ Username/Password — محمية بـ **Access Keys**. مفيدة للـ Automation والـ Scripts. هي نفسها مبنية على الـ AWS SDK for Python.

**التالتة — AWS SDK (Software Development Kit):**
مكتبات برمجية بتحطها جوه الـ Application Code بتاعك. بتسمح للـ Application إنها تتعامل مع AWS Programmatically. بتدعم JavaScript، Python، Java، .NET، Go، وغيرهم. كمان محمية بـ **Access Keys**.

**الـ Access Keys:**
الـ Access Key مكوّن من جزأين:
- **Access Key ID** ≈ Username
- **Secret Access Key** ≈ Password

بيتعملوا من الـ Console، كل User بيدير الـ Access Keys بتاعته هو، وزي الباسورد بالظبط — **مش بتشاركهمش مع حد أبداً.**

---

## 🤖 IAM Roles — لما السيرفر نفسه محتاج صلاحية

لحد دلوقتي اتكلمنا عن صلاحيات الـ Users — الناس الحقيقية. بس في AWS، الـ Services نفسها أحياناً محتاجة تعمل Actions على Services تانية.

مثال: عندك EC2 Instance (سيرفر) عايز يقرأ ملفات من S3. السيرفر ده مش إنسان — مش عنده Username وPassword. الحل هو **IAM Role**.

الـ IAM Role هو مجموعة صلاحيات بتعملها وبتلصقها على الـ Service مباشرة. لما EC2 Instance عنده Role بيسمحه يقرأ من S3 — هيقدر يعملها تلقائياً من غير ما تحط Access Keys في الكود. ده أأمن وأنظف بكتير.

**أشهر الـ Roles:**
- **EC2 Instance Roles** — للسيرفرات
- **Lambda Function Roles** — للـ Serverless Functions
- **Roles for CloudFormation** — لإدارة الـ Infrastructure

---

## 🔍 IAM Security Tools — تدقيق وتحقق

AWS بتديك أداتين مهمتين تعرف بيهم إيه اللي بيحصل في الـ Account:

**الأولى — IAM Credentials Report (Account-Level):**
Report كاملة بتعملها على مستوى الـ Account كلها. بتليكي كل الـ Users وحالة كل Credential بتاعتهم — الباسورد متغير إمتى، الـ MFA مفعّل ولا لأ، الـ Access Keys اتُستخدمت إمتى. بتستخدمها للـ Audit الشامل.

**التانية — IAM Access Advisor (User-Level):**
بتبصها على User معين وبتشوف: إيه الـ Services اللي مسموحله يوصلها، وإمتى آخر مرة وصلها فعلاً. لو User معاه صلاحية S3 بس ما استخدمهاش من 6 شهور — ممكن تشيلها. ده بيساعدك تطبق الـ Least Privilege بشكل عملي.

---

## 🤝 الـ Shared Responsibility في IAM

في قسم الـ Cloud Computing اتكلمنا عن الـ Shared Responsibility Model بشكل عام. في IAM بالتحديد:

**AWS مسؤولة عن:**
الـ Infrastructure الخاصة بـ IAM نفسه — الـ Global Network، الـ Security، الـ Availability، والـ Compliance Validation.

**إنت مسؤول عن:**
- تعمل الـ Users والـ Groups والـ Roles والـ Policies صح.
- تفعّل MFA على كل الـ Accounts المهمة.
- تدوّر الـ Access Keys بانتظام.
- تستخدم الـ IAM Tools تراجع الصلاحيات.
- تحلل الـ Access Patterns وتراجع الـ Permissions.

---

## 📌 الـ Best Practices — الملخص الذهبي

- ❌ لا تستخدم الـ Root Account إلا عند الـ Setup الأولي.
- ✅ شخص واحد = IAM User واحد. مش تشارك.
- ✅ حط الـ Users في Groups وادي الصلاحيات للـ Groups.
- ✅ فعّل Password Policy قوية.
- ✅ فرض MFA على كل الـ Accounts وخصوصاً الـ Root.
- ✅ استخدم Roles للـ Services — مش Access Keys في الكود.
- ✅ استخدم Access Keys للـ CLI/SDK فقط — مش للـ Console.
- ✅ راجع الصلاحيات بانتظام بـ Credentials Report وAccess Advisor.
- ❌ لا تشارك IAM Users أو Access Keys مع أي حد.

---

## 🗺️ خريطة IAM في جملة واحدة

> **Root Account** تعمل **IAM Admin User** ← يعمل **Users** يحطهم في **Groups** ← يدي الـ Groups **Policies** ← يفعّل **MFA** ← يعمل **Roles** للـ Services ← يراجع بـ **Credentials Report** و**Access Advisor**.

---

---

# 🎯 IAM — Exam Practice

> **Instructions:** Try to answer each question before expanding the answer. These are CLF-C02 style questions.

---

> [!question]- **Q1.** A company has just created a new AWS account. Which account should be used for day-to-day administrative tasks?
> ✅ **Answer: B**
>
> **A.** The Root account, as it has full permissions
> **B.** An IAM user with administrative permissions
> **C.** An IAM user with read-only permissions
> **D.** A shared IAM user for the entire team
>
> **Explanation:** The Root account should never be used for daily tasks. Create an IAM Admin User immediately and lock the Root account away. This is a direct Best Practice from AWS.

---

> [!question]- **Q2.** Which of the following statements about IAM Groups is CORRECT?
> ✅ **Answer: C**
>
> **A.** A group can contain other groups
> **B.** Every IAM user must belong to at least one group
> **C.** A user can belong to multiple groups simultaneously
> **D.** Groups can be assigned MFA devices
>
> **Explanation:** Groups contain Users only — not other Groups. Users don't have to be in any group. A User CAN be in multiple groups at the same time and inherits all policies from all groups.

---

> [!question]- **Q3.** What is the primary purpose of the Least Privilege Principle in IAM?
> ✅ **Answer: A**
>
> **A.** Grant users only the permissions they need to perform their job
> **B.** Give all users the same level of access to ensure fairness
> **C.** Restrict the Root account from accessing billing information
> **D.** Ensure all users have MFA enabled before accessing AWS
>
> **Explanation:** Least Privilege = minimum permissions needed, nothing more. This limits the blast radius if an account is compromised.

---

> [!question]- **Q4.** A developer needs to interact with AWS services programmatically from their local machine. What should they use?
> ✅ **Answer: D**
>
> **A.** Username and password via the AWS Management Console
> **B.** The Root account credentials
> **C.** An IAM Group with developer permissions
> **D.** AWS CLI configured with Access Keys
>
> **Explanation:** Programmatic access (CLI/SDK) uses Access Keys (Access Key ID + Secret Access Key). The Console uses Username/Password + MFA. Never use Root credentials for programmatic access.

---

> [!question]- **Q5.** Which element in an IAM Policy is ALWAYS required?
> ✅ **Answer: B**
>
> **A.** Id
> **B.** Statement
> **C.** Sid
> **D.** Condition
>
> **Explanation:** Statement is the only required element besides Version. Id, Sid, and Condition are all optional.

---

> [!question]- **Q6.** An EC2 instance needs to read files from an S3 bucket. What is the MOST secure way to grant this access?
> ✅ **Answer: C**
>
> **A.** Store Access Keys as environment variables in the EC2 instance
> **B.** Hardcode the Access Keys directly in the application code
> **C.** Attach an IAM Role with S3 read permissions to the EC2 instance
> **D.** Create an IAM user for the EC2 instance and share the credentials
>
> **Explanation:** IAM Roles are designed exactly for this use case. Never put Access Keys inside an EC2 instance or application code. Roles are automatically managed and rotated by AWS.

---

> [!question]- **Q7.** What does the IAM Access Advisor tool help you accomplish?
> ✅ **Answer: B**
>
> **A.** Generate a report of all users and their password status across the account
> **B.** Identify unused service permissions for a specific IAM user
> **C.** Automatically remove inactive IAM users from the account
> **D.** Monitor login attempts and flag suspicious activity
>
> **Explanation:** Access Advisor shows which services a user has permission to access AND when they last accessed them. This helps you implement Least Privilege by removing unused permissions. The Credentials Report (not Access Advisor) covers password status at account level.

---

> [!question]- **Q8.** Which of the following is a valid MFA option in AWS? (Select TWO)
> ✅ **Answer: A and C**
>
> **A.** Google Authenticator (Virtual MFA)
> **B.** Biometric fingerprint scan
> **C.** YubiKey (U2F Security Key)
> **D.** Email one-time password
> **E.** SMS text message code
>
> **Explanation:** AWS supports Virtual MFA (Google Authenticator, Authy), U2F Security Keys (YubiKey), and Hardware Key Fobs (Gemalto, SurePassID). SMS-based MFA and biometrics are NOT supported by AWS IAM.

---

> [!question]- **Q9.** If a user belongs to two IAM Groups — one with an Allow policy for S3 and another with a Deny policy for S3 — what happens when the user tries to access S3?
> ✅ **Answer: B**
>
> **A.** Allow wins because it was assigned first
> **B.** Deny wins — access is blocked
> **C.** AWS prompts the user to choose which policy applies
> **D.** The most recently attached policy takes effect
>
> **Explanation:** In IAM, an explicit Deny ALWAYS overrides any Allow. This is one of the most important rules in IAM and a classic exam trap.

---

> [!question]- **Q10.** Which IAM tool generates a report listing ALL users in an account and the status of their credentials?
> ✅ **Answer: A**
>
> **A.** IAM Credentials Report
> **B.** IAM Access Advisor
> **C.** AWS CloudTrail
> **D.** AWS Config
>
> **Explanation:** Credentials Report = Account-level overview of all users and their credential status (password age, MFA enabled, access key rotation). Access Advisor = User-level view of service permissions and last access time.

---

> [!question]- **Q11.** According to the IAM Shared Responsibility Model, which of the following is the CUSTOMER'S responsibility?
> ✅ **Answer: D**
>
> **A.** Maintaining the physical security of data centers running IAM
> **B.** Ensuring global availability of the IAM service
> **C.** Patching the underlying infrastructure that runs IAM
> **D.** Enabling MFA on all IAM users and the Root account
>
> **Explanation:** AWS owns and maintains the infrastructure that runs IAM. The customer is responsible for how they configure and use IAM — including enabling MFA, rotating keys, and reviewing permissions.

---

> [!question]- **Q12.** What is the Version field value that must ALWAYS appear in an IAM Policy document?
> ✅ **Answer: C**
>
> **A.** The current year in YYYY format
> **B.** The date the policy was created
> **C.** 2012-10-17
> **D.** The AWS account creation date
>
> **Explanation:** The Version field in IAM policies is always "2012-10-17". This is the policy language version — not a date you choose. This is a classic exam trap where people think they should put today's date.

---

*القسم الجاي: **EC2 — Elastic Compute Cloud** — السيرفرات الافتراضية وكل حاجة حواليهم.*
