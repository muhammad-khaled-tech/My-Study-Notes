# Domain 4: Billing, Pricing & Support (هندسة التكاليف السحابية)

## المحطة الأولى: الإدارة المركزية وحوكمة الشركات - الجزء الأول (AWS Organizations)

**أصل الحكاية والمشكلة المعمارية (The Core Problem):**

تخيل إن منصة (Wateen.ai) كبرت جداً وبقى عندك فريق للتطوير (Dev)، وفريق للإنتاج (Prod)، وفريق للبيانات. لو كل فريق عمل حساب AWS منفصل وربطه بفيزا مختلفة، هيحصل الآتي:

1. الفواتير هتتشتت ومش هتعرف مين صرف إيه.
    
2. هتخسر "خصومات الكمية" (Volume Discounts) لأن كل حساب بيتحاسب لوحده من الصفر.
    
3. ممكن مطور مبتدئ في حساب الـ Dev يفتح سيرفر بـ 1000 دولار في الشهر بالغلط وتدبس فيه.
    

**الحل المعماري (AWS Organizations):**

أمازون عملت الخدمة دي عشان تكون "الشركة القابضة". بتعمل حساب رئيسي (Management Account)، وتدخل تحته كل الحسابات الفرعية التانية، وتبدأ تدير الفلوس والصلاحيات بقبضة من حديد.

### ⚙️ الفوائد المعمارية والمالية (لماذا نستخدم Organizations؟)

الامتحان بيركز على الـ 4 فوائد دول تحديداً:

#### 1. الفاتورة الموحدة (Consolidated Billing)

- حساب الـ Management هو اللي بيدفع الفاتورة المجمعة لكل الحسابات اللي تحته. ده بيسهل شغل قسم الحسابات في الشركة جداً.
    

#### 2. خصومات الكمية المجمعة (Aggregated Volume Discounts)

- **الميزة القاتلة:** تسعير أمازون لخدمات زي (S3) بيقل كل ما استهلاكك بيزيد (Tiered Pricing). الـ Organizations بتجمع استهلاك كل حساباتك مع بعض. لو حساب الـ Dev خزن 50 تيرا، وحساب الـ Prod خزن 50 تيرا، أمازون هتحاسبك على إنك خزنت 100 تيرا، فتدخل في شريحة سعرية أرخص بكتير!
    

#### 3. مشاركة الخصومات (Pooling of Reserved Instances)

- لو فريق الـ Dev اشترى (Reserved Instance) لمدة سنة، بس قفل السيرفر بتاعه ومبقاش بيستخدمه.. الخصم ده مابيضيعش! الـ Organizations بتخلي أي حساب تاني (زي الـ Prod) يورث الخصم ده أوتوماتيك ويستفيد بيه.
    

#### 4. سياسات التحكم في الخدمة (Service Control Policies - SCPs) 🚨

- دي **أقوى أداة حماية** في أمازون كلها. دي عبارة عن وثيقة (JSON) بتطبقها على حساب كامل عشان تمنع عنه خدمات معينة.
    
- **السيناريو:** بتعمل SCP تمنع أي حد في الـ Dev Account إنه يفتح سيرفرات غالية (زي سلسلة X1 أو P4).
    
- **القوة الغاشمة:** الـ SCP بتلغي أي صلاحيات تانية. حتى لو المطور معاه صلاحية (Administrator) جوه حساب الـ Dev، الـ SCP هتمنعه! (SCPs override everything).
    

### 🏗️ اللوحة المعمارية: الهيكل التنظيمي (Mermaid)

الرسمة دي (`flowchart TD`) معمولة بقواعدك الصارمة جداً، مفيش فيها أي أرقام كقوائم في الـ Labels، والأسهم نظيفة، وبتوضح إزاي الهيكل بيترتب في شكل وحدات تنظيمية (OUs):

Code snippet

![](data:image/png;base64,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)

```
flowchart TD
    %% Global Styling
    classDef default font-weight:bold,font-size:14px,stroke-width:2px;
    classDef root fill:#fffbe6,stroke:#faad14,color:#000;
    classDef ou fill:#e6f7ff,stroke:#1890ff,color:#000;
    classDef acc fill:#f6ffed,stroke:#52c41a,color:#000;
    classDef scp fill:#fff1f0,stroke:#ff4d4f,stroke-dasharray: 5 5,color:#000;

    Master(("👑 Management Account<br>Pays the single bill")):::root

    subgraph Org_Structure ["🏢 AWS Organization"]
        direction TB
        
        OU_Prod["📁 Production OU"]:::ou
        OU_Dev["📁 Development OU"]:::ou
        
        Acc_Prod1["☁️ Wateen Prod Account"]:::acc
        Acc_Prod2["☁️ Analytics Account"]:::acc
        
        Acc_Dev1["☁️ Testing Account"]:::acc
        Acc_Dev2["☁️ Sandbox Account"]:::acc
    end

    SCP_Block["🛑 SCP: Deny expensive EC2 instances"]:::scp

    %% Connections defined outside
    Master ==>|"(1) Consolidated Billing"| OU_Prod
    Master ==>|"(2) Consolidated Billing"| OU_Dev
    
    OU_Prod --> Acc_Prod1
    OU_Prod --> Acc_Prod2
    
    OU_Dev --> Acc_Dev1
    OU_Dev --> Acc_Dev2

    SCP_Block -.->|"(3) Restricts ALL users inside"| OU_Dev
```

### 📊 شفرات الامتحان: التفرقة الحاسمة لـ AWS Organizations

احفظ الكلمات الدلالية دي، بتيجي بالنص في أسئلة الـ Billing:

|**السيناريو المعماري في الامتحان (Keyword)**|**الإجابة الصحيحة (AWS Service / Feature)**|
|---|---|
|`Manage multiple AWS accounts centrally`|**AWS Organizations**|
|`Combine usage across all accounts to share volume pricing discounts`|**Consolidated Billing / AWS Organizations**|
|`Share Reserved Instances (RI) discounts across accounts`|**AWS Organizations**|
|`Restrict services or actions across multiple AWS accounts`|**Service Control Policies (SCPs)**|
|`Apply restrictions that override even the root user of a member account`|**Service Control Policies (SCPs)**|

الأساس المركزي للشركة اتصب بنجاح يا هندسة!

انسخ الجزء ده في الـ Vault، واديني الإشارة بكلمة **"ارمي الجزء التاني"** عشان ننزل بخدمة **(AWS Control Tower)**: إزاي تخلي أمازون تبني الهيكل المعقد ده كله بضغطة زرار واحدة وبأفضل معايير الأمان! جاهز؟