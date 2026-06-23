# Domain 1: Fundamentals of AI and ML (20%)

## Phase 1 - Part 1: Hierarchical Boundaries of AI (التفكيك المعماري لطبقات الذكاء الاصطناعي)

### 1. أصل الحكاية والمشكلة المعمارية (The Core Problem)

في هندسة البرمجيات الكلاسيكية (Classical Software Engineering)، إحنا كـ Backend Developers بنعتمد على الـ **Deterministic Logic**. اليوزر بيبعت (Data)، الكود بيمشي على قواعد صارمة احنا كاتبينها (Rules / If-Else Conditions)، وبيطلع (Output).

**المشكلة (The Bottleneck):**

الـ Architecture دي بتنهار تماماً لما المشكلة تكون معقدة وصعب وصفها بقواعد ثابتة. تخيل إن مطلوب منك تكتب كود بـ `if/else` يفرق بين صورة قطة وصورة كلب! هل هتكتب قاعدة لكل بيكسل (Pixel)؟ هل هتكتب `if (RGB == 255)`؟ مستحيل.

التعقيد (Complexity) بتاع العالم الحقيقي أكبر من إننا نحصره في `Rules` يدوية.

من هنا حصل التحول المعماري الأهم في تاريخ الكمبيوتر: **"بدل ما نبرمج القواعد، خلينا نخلي المكنة تستنتجها"**.

### 2. التشريح العميق لطبقات التجريد (The Matryoshka Doll of AI)

الامتحان (AIF-C01) بيختبر بدقة قدرتك كـ Tech Lead إنك تفرق بين الـ 5 طبقات دول هندسياً. هما مش حاجة واحدة، هما دوائر جوه بعض، كل دايرة بتضيف مستوى أعلى من التعقيد والتجريد (Abstraction):

#### 🛡️ المظلة الكبرى: Artificial Intelligence (AI)

- **المعنى الهندسي:** الـ AI هو المظلة الشاملة (The Superset). أي نظام أو (System) بيقدر يحاكي الوظائف الإدراكية للبشر (زي الإدراك، التفكير، حل المشاكل، أو اتخاذ القرار) بيقع تحت المظلة دي.
    
- **العمق التقني:** **الـ AI مش شرط يكون بيتعلم!** في بدايات الـ AI كان عندنا حاجة اسمها الأنظمة الخبيرة (Expert Systems) أو (Rule-based AI). يعني لو عملت شجرة قرارات (Decision Tree) ضخمة جداً متبرمجة بـ `if/else` عشان تشخص أمراض بناءً على أعراض واضحة (زي نظام MYCIN في السبعينات)، النظام ده اسمه AI، رغم إنه مش بيتعلم أي حاجة جديدة من الداتا، هو مجرد بينفذ قواعد برمجية معقدة.
    

#### ⚙️ محرك الاستنتاج: Machine Learning (ML)

- **المعنى الهندسي:** دايرة أعمق جوه الـ AI. هنا إحنا بنرمي برمجة القواعد الصريحة (Explicit Programming) في الزبالة. النظام هنا **بيتعلم** الخرائط (Mapping) من البيانات التاريخية.
    
- **التعريف الأكاديمي الصارم (Mitchell's Definition):** السيستم بيتقال عليه بيعمل Machine Learning لو كان أداؤه في مهمة معينة `(Task T)`، بيتحسن مع اكتساب خبرة `(Experience E)`، وبنقيس التحسن ده بمقياس `(Performance P)`.
    
- **العمق التقني:** الموديل هنا بيتعلم دالة رياضية `f(X) → Y`. الـ `X` هي البيانات (Features)، والـ `Y` هي النتيجة (Label). بدل ما تقوله "لو لقيت كلمة كذا، اعتبر الإيميل Spam"، إنت بتديله 10,000 إيميل Spam، وخوارزميات الـ ML (الإحصائية) هي اللي بتوزن الكلمات وتستنتج القاعدة.
    

#### 🧠 الشبكات العصبية: Deep Learning (DL)

- **المعنى الهندسي:** دايرة أعمق جوه الـ ML. خوارزميات الـ ML الكلاسيكية قوية، بس بتيجي عند البيانات الغير مهيكلة (Unstructured Data) زي الصور، الفيديوهات، والصوت.. وبتعطل. هنا ظهر الـ DL.
    
- **العمق التقني:** بيعتمد على معمارية اسمها **Artificial Neural Networks (ANNs)**. الميزة الهندسية المرعبة للـ DL اللي فرقت مع المهندسين هي الـ **Automatic Feature Representation**. في الـ ML العادي، كان لازم مهندس داتا يعمل (Manual Feature Engineering) ويقول للموديل "ركز على طول ودن القطة". في الـ DL، الشبكة العصبية بتتكون من طبقات مخفية متعددة (Hidden Layers). الطبقات دي بتكتشف الـ Features لوحدها من الـ Raw Data.
    
- **متطلبات البنية التحتية:** المعمارية دي مبنية على عمليات ضرب مصفوفات (Matrix Multiplication) ضخمة جداً، عشان كده مبتشتغلش بكفاءة على الـ CPU وبتحتاج **GPUs**.
    

#### ✨ محرك الإبداع: Generative AI (GenAI)

- **المعنى الهندسي:** دايرة أعمق جوه الـ DL. معظم أنظمة الـ ML/DL القديمة كانت بتعمل "تصنيف" أو "توقع" (Discriminative AI)، يعني الموديل بيتعلم `P(Y|X)` "احتمالية إن الصورة دي قطة بناءً على البيكسلات". الـ GenAI بيعمل حاجة تانية خالص..
    
- **العمق التقني:** الموديل هنا بيتعلم **التوزيع الاحتمالي** للبيانات نفسها `P(X)`. ولأنه فهم الداتا بتتوزع إزاي، بيقدر يولد (Generate) عينات جديدة تماماً (Synthetic artifacts) سواء كانت نصوص، صور، أو كود، من نفس التوزيع ده. النماذج دي بتبقى ضخمة جداً واسمها Foundation Models (FMs).
    

#### 🕵️ الذكاء المستقل: Agentic AI (إضافة حيوية في امتحان AIF-C01 v1.1)

- **المعنى الهندسي:** ده التطور الجديد اللي الامتحان بيركز عليه. الـ LLM العادي عبارة عن (Request -> Response). الـ Agentic AI هو نظام بيخلي الـ LLM يشتغل كـ "مخ" جوه حلقة تشغيل (Orchestration Loop) عشان يحقق هدف معقد بيحتاج خطوات كتير.
    
- **العمق التقني:** الـ Agent بيتميز بـ 3 حاجات:
    
    1. **التخطيط (Planning):** يكسر المشكلة الكبيرة لخطوات صغيرة.
        
    2. **الذاكرة (Memory):** يفتكر هو عمل إيه في الخطوة اللي فاتت (سواء Short-term في الـ Context، أو Long-term في Vector DB).
        
    3. **استخدام الأدوات (Tool Usage):** يقدر يكلم APIs خارجية، ينفذ كود، أو يعمل Web Search (من خلال بروتوكولات زي Model Context Protocol - MCP).
        

### 3. المجاز المعماري (The Corporate Metaphor)

عشان تثبت الفروقات دي في دماغك للـ Scenario Questions:

- **Rule-based AI:** الموظف البصمجي اللي معاه شيت إكسيل فيه ماكرو (Macro). لو الدخل كذا، ارفض القرض. مبيفكرش.
    
- **Machine Learning:** المحلل المالي الجونيور. بتديله ملفات القروض بتاعة آخر 10 سنين وتقوله "ذاكرهم"، عشان لما يجيلك عميل جديد تعرف تقيمه بناءً على الأنماط القديمة.
    
- **Deep Learning:** قسم كامل من المحللين الماليين، كل واحد بيدقق في تفصيلة صغيرة جداً (واحد بيبص على السن، التاني على السكن، التالت على حركة الحساب)، ومن غير ما تديهم قواعد، هما لوحدهم بيكتشفوا إن "العميل اللي بيشتري قهوة كتير فرصة سداده أعلى" (اكتشاف Features مخفية).
    
- **Generative AI:** مدير التسويق الإبداعي. مش بس بيحلل الداتا، لأ ده بيكتبلك خطة تسويقية جديدة تماماً بلغة احترافية بناءً على خبرته الطويلة.
    
- **Agentic AI:** الـ CEO المستقل. بتقوله "زود المبيعات 10%" وتسيبه. هو هيفكر، يبعت إيميلات (Tool Use)، يحلل الردود (Memory)، ويعدل الخطط لوحده بدون تدخلك (Autonomous).
    

### 4. اللوحة المعمارية: مسار الـ Data والـ Logic (Mermaid)

Code snippet

```mermaid
graph TD

classDef default font-weight:bold,font-size:14px,stroke-width:2px;
classDef classical fill:#f0f2f5,stroke:#595959,color:#000;
classDef ai fill:#f9f0ff,stroke:#722ed1,color:#000;
classDef agent fill:#e6fffc,stroke:#13c2c2,color:#000;

subgraph Classical_Engineering ["⚙️ Classical Software Engineering"]
    direction LR
    Data1["Raw Data"] --> Rules["Manual Rules <br> if/else"] --> Output1["Output"]
end

subgraph The_AI_Evolution ["🚀 The AI Evolution"]
    direction TB
    
    AI_Layer["<b>Artificial Intelligence</b> <br> Mimics human logic. Can be Rule-Based."]
    
    ML_Layer["<b>Machine Learning</b> <br> Learns Rules from Data and Answers."]
    
    DL_Layer["<b>Deep Learning</b> <br> Uses Neural Networks. Auto-extracts features."]
    
    Gen_Layer["<b>Generative AI</b> <br> Learns patterns to create NET-NEW content."]
    
    Agent_Layer["<b>Agentic AI (v1.1)</b> <br> Orchestrates GenAI with Tools & Memory."]

    AI_Layer ==> ML_Layer
    ML_Layer ==> DL_Layer
    DL_Layer ==> Gen_Layer
    Gen_Layer ==> Agent_Layer
end

class Classical_Engineering classical;
class The_AI_Evolution ai;
class Agent_Layer agent;
```

### 5. دستور الامتحان (Exam Traps & Keyword Mapping)

في امتحان הـ AIF-C01، الأسئلة بتيجي في شكل سيناريو لشركة (Use Case)، وبيطلب منك تحدد التقنية المظبوطة. دي الـ Keywords الصارمة اللي بتلخص الإجابات:

|**فخ السيناريو في الامتحان (The Trap/Keyword)**|**التقنية المطلوبة (The Answer)**|**التفسير المعماري (Why?)**|
|---|---|---|
|`Mimics human behavior but does NOT learn from data`, `Expert system`|**Artificial Intelligence (AI)**|دي إشارة صريحة للـ Rule-based AI اللي مفيش فيه تدريب أو موديلز.|
|`Improves performance through data`, `Uses statistical algorithms`|**Machine Learning (ML)**|مفيش ذكر لبيانات معقدة أو إنشاء محتوى جديد، مجرد استنتاج إحصائي.|
|`Complex unstructured data (Images/Audio)`, `Multi-layered neural networks`, `Requires GPUs`|**Deep Learning (DL)**|ذكر الطبقات المتعددة والبيانات الغير مهيكلة بيحسم الإجابة للـ DL.|
|`Produce novel content`, `Create new artifacts`, `Foundation Models`|**Generative AI (GenAI)**|الكلمة المفتاحية هي `Create/Generate` و `Novel` (جديد). لو بيصنف بس مش GenAI.|
|`Take autonomous actions`, `Use tools/APIs`, `Orchestrate multi-step workflows`|**Agentic AI**|إضافة الإصدار v1.1. التركيز على الـ "أفعال المستقلة" واستخدام الـ Tools (الأدوات).|

---
جاهز يا بطل، إحنا لسه جوه **Domain 1** وفي نفس الـ **Phase 1**، بس هندخل دلوقتي بمشرط الجراح عشان نفكك "لغة الآلة".

استلم **(Phase 1 - الجزء الثاني)**، خده Copy/Paste في الـ Obsidian تحت الجزء اللي فات على طول:

## Phase 1 - Part 2: Core ML Terminology & The Bias-Variance Tradeoff (ميكانيكا المصطلحات وفخاخ التدريب)

### 1. أصل الحكاية والمشكلة المعمارية (The Core Problem)

في الـ Backend العادي، لو الكود شغال على جهازك وشغال على الـ Staging، بنسبة 99% هيشتغل على الـ Production (طالما الـ Environment واحدة).

في الـ Machine Learning، القاعدة دي بتتدمر تماماً! الموديل ممكن يجيب دقة 100% في المعمل، وأول ما يطلع Production يودي الشركة في داهية. ليه؟ لأن الموديل "حفظ" الداتا بدل ما "يفهمها".

عشان كده هندسة الذكاء الاصطناعي خلقت مصطلحات صارمة جداً توصف حالة الموديل، وتفصل بين مرحلة "المذاكرة" ومرحلة "الامتحان"، وتحدد بالضبط إيه سبب الفشل لو حصل.

### 2. التشريح العميق للقاموس المعماري (Strict Engineering Definitions)

الامتحان بيوقعك في الفروقات البسيطة بين الكلمات دي. لازم تتعامل معاهم كأنهم Variables في الكود، كل واحد ليه Data Type مختلف:

#### ⚙️ ميكانيكا التشغيل (The Mechanics)

- **الخوارزمية (Algorithm):**
    
    ده "المحرك" الرياضي أو إجراء التحسين (Optimization Procedure) اللي بنستخدمه عشان ندرب الموديل. (أمثلة: Gradient Descent, Random Forest, K-Means). الخوارزمية مش هي الموديل، الخوارزمية هي الأداة اللي بتبني الموديل.
    
- **النموذج (Model):**
    
    هو "المنتج النهائي". عبارة عن دالة رياضية `f(X; θ)` محكومة بـ Parameters (أوزان `θ`) الخوارزمية ظبطتها. ده اللي بناخده نعمله Deploy كـ API.
    
- **التدريب (Training):**
    
    العملية المتكررة (Iterative) اللي بنغذي فيها الخوارزمية ببيانات (Training Dataset) عشان تقلل نسبة الخطأ (Loss Function). **هنا الأوزان (`θ`) بتتعدل وتتحدث باستمرار.**
    
- **الاستنتاج / التشغيل (Inferencing):**
    
    إنك تاخد الموديل الجاهز `f(X; θ*)` وتطبق عليه بيانات جديدة تماماً (Unseen Data) عشان تطلع النتيجة `ŷ`. **(قاعدة معمارية صارمة: في مرحلة الـ Inference، مفيش أي تعديل للأوزان بيحصل. الموديل بيكون Read-only).**
    

#### ⚖️ مثلث الرعب المعماري (Fit, Bias, and Variance)

دول أهم 3 مفاهيم في تقييم جودة الـ ML Model:

- **Fit (الملاءمة):**
    
    الدرجة اللي الموديل قدر بيها يلقط الـ Pattern الحقيقي بتاع الداتا من غير ما يتأثر بالدوشة (Noise).
    
- **Statistical Bias (التحيز الإحصائي):**
    
    _(ملاحظة: ده غير التحيز الأخلاقي / العنصرية اللي هنشوفه في Domain 4)._ الـ Bias هنا معناه إن الموديل "مبسط بزيادة" (Too simple) لدرجة إنه مش قادر يفهم العلاقات المعقدة في الداتا. الموديل عنده افتراضات مسبقة قوية جداً معمياه عن الحقيقة.
    
    - **النتيجة الكارثية:** **Underfitting** (القصور). الموديل أداؤه سيء جداً في الـ Training وسيء في الـ Testing.
        
- **Variance (التشتت الإحصائي):**
    
    حساسية الموديل المفرطة لأي تفصيلة أو "دوشة" في بيانات التدريب. الموديل معقد جداً (Too complex) لدرجة إنه بيعامل الدوشة كأنها قواعد أساسية.
    
    - **النتيجة الكارثية:** **Overfitting** (الإفراط). الموديل أداؤه 100% في الـ Training، بس بينهار ويفشل تماماً في الـ Validation/Testing لأنه "حفظ" ومقدرش "يعمم" (Poor Generalization).
        
- **The Bias-Variance Tradeoff (المقايضة الهندسية):**
    
    الـ Error الكلي للموديل = `Bias² + Variance + Irreducible Noise`.
    
    لو حاولت تقلل الـ Bias جداً (بإنك تزود تعقيد الموديل)، الـ Variance هيضرب في السما (Overfitting). ولو قللت الـ Variance جداً (بإنك تبسط الموديل)، الـ Bias هيزيد (Underfitting). وظيفتك كمهندس تلاقي "نقطة التوازن" (Optimal Capacity).
    

#### 🌐 تخصصات فرعية جوه الـ ML (Sub-disciplines)

- **Large Language Models (LLMs):** نماذج Deep Learning عملاقة متدربة على كميات مهولة من النصوص (Corpora). بتستخدم أهداف تدريب ذاتية (Self-supervised) زي توقع الكلمة الجاية (Next-token prediction). بتتميز بظهور قدرات مفاجئة (Emergent capabilities).
    
- **Computer Vision (CV):** فرع الذكاء الاصطناعي الخاص باستخراج المعاني من البيانات المرئية (الصور، الفيديو).
    
- **Natural Language Processing (NLP):** فرع الذكاء الاصطناعي الخاص بفهم، وتوليد، وتحويل اللغات البشرية.
    

### 3. المجاز المعماري (The Student Metaphor)

عشان عمرك ما تتلخبط بين الـ Overfitting والـ Underfitting تاني:

تخيل عندنا امتحان آخر السنة (Production / Inference) وإدينا للطلاب امتحانات السنين اللي فاتت يذاكروا منها (Training Data).

- **الـ High Bias (طالب الـ Underfitting):** طالب كسلان أو قدراته محدودة. فتح امتحانات السنين اللي فاتت، مفهمش حاجة، ومذاكرش. دخل الامتحان التجريبي (Training) سقط، ودخل الفاينال (Testing) سقط برضه. الموديل ده محتاج يتعقد أو يتشرح له أحسن (Capacity increase).
    
- **الـ High Variance (طالب الـ Overfitting):** طالب "بصمجي" بدرجة امتياز. حفظ امتحانات السنين اللي فاتت بالمللي، لدرجة إنه حفظ إن "لو السؤال مكتوب بخط أحمر تبقى إجابته أ". دخل الامتحان التجريبي (Training) جاب 100%. دخل الفاينال (Testing) لقى نفس الأسئلة بس مكتوبة بخط أزرق.. سقط! الموديل ده حفظ الدوشة (Noise) وفشل في التعميم (Generalization).
    


```mermaid
graph TD
    classDef default font-weight:bold,font-size:14px,stroke-width:2px;
    classDef training fill:#e6f7ff,stroke:#1890ff,color:#000;
    classDef inference fill:#f6ffed,stroke:#52c41a,color:#000;
    classDef warning fill:#fff2e8,stroke:#ff4d4f,color:#000;

    subgraph Phase_1_Training ["🏋️ Model Training (Learning Phase)"]
        direction LR
        Algo["Algorithm<br>(e.g. Gradient Descent)"] --> |"Updates Weights (θ)"| Mod_Train["Model f(X; θ)"]
        TrainData["Training Data"] --> Mod_Train
        Mod_Train --> |"Calculate Error"| Loss["Loss Function"]
        Loss -.-> |"Iterative Optimization"| Algo
    end

    subgraph Phase_2_Inference ["🚀 Inferencing (Production Phase)"]
        direction LR
        NewData["New/Unseen Data"] --> Mod_Prod["Trained Model f(X; θ*)<br>NO WEIGHT UPDATES"]
        Mod_Prod --> Prediction["Prediction (ŷ)"]
    end

    subgraph The_Fit_Traps ["⚠️ The Bias-Variance Tradeoff"]
        direction TB
        Under["Underfitting (High Bias)<br>Model too simple.<br>Fails Training & Testing"] 
        Optimal["Optimal Fit<br>Generalizes well to new data"]
        Over["Overfitting (High Variance)<br>Model memorized noise.<br>Aces Training, Fails Testing"]
        
        Under --> Optimal --> Over
    end

    %% Apply Classes
    class Phase_1_Training,Algo,TrainData,Loss training;
    class Phase_2_Inference,NewData,Prediction inference;
    class The_Fit_Traps,Under,Over warning;
    
    style Mod_Train fill:#fff,stroke:#1890ff,stroke-dasharray: 5 5
    style Mod_Prod fill:#fff,stroke:#52c41a
    style Optimal fill:#d9f7be,stroke:#389e0d
```

### 5. دستور الامتحان (Exam Traps & Keyword Mapping)

الجدول ده هو الـ Cheat Sheet بتاعك عشان تترجم خدع أمازون في الأسئلة لقرارات معمارية:

|**فخ السيناريو في الامتحان (The Trap/Keyword)**|**المصطلح الهندسي (The Concept)**|**التفسير المعماري (Why?)**|
|---|---|---|
|`Updating parameters`, `Iterative optimization of weights`, `Minimizing loss`|**Training**|طالما الأوزان بتتعدل والموديل بيتعلم، إحنا في مرحلة التدريب.|
|`Applying the model to new data`, `Generating predictions in production`, `No parameter updates`|**Inferencing**|الاستنتاج يعني الموديل بقى (Read-only) وبيستخدم في الواقع.|
|`Model performs well on training data but poorly on validation/test data`, `Memorized training noise`|**Overfitting (High Variance)**|الفجوة الكبيرة بين أداء التدريب وأداء الاختبار (Training loss << Validation loss) معناها إن الموديل حفظ الداتا ومقدرش يعمم.|
|`Model performs poorly on BOTH training and validation data`, `Model is too simple`|**Underfitting (High Bias)**|الموديل مش قادر يفهم الـ Pattern أصلاً سواء في التدريب أو بره التدريب.|
|`Balancing model complexity to minimize total error`|**Bias-Variance Tradeoff**|المقايضة الهندسية الأساسية لمنع الموديل من إنه يتغبى أو يبصم.|
|`Model capability not explicitly trained for, arising from massive scale`|**Emergent Capabilities (LLMs)**|قدرات مفاجئة بتظهر في الـ LLMs لما تكبر (زي قدرتها على كتابة كود وهي متدربة على نصوص عامة).|


----
## Phase 2 - Part 1: Supervised Learning Mechanics (التشريح الهندسي للتعلم الخاضع للإشراف)

### 1. أصل الحكاية والمشكلة المعمارية (The Core Problem)

الـ Machine Learning مش سحر، هو في الأساس "Optimization Problem" (مشكلة تحسين رياضي).

المشكلة بتبدأ لما يكون عندنا بيانات تاريخية متسجلة في الـ Database، وعارفين النتيجة بتاعتها (زي بيانات أسعار شقق اتباعت فعلاً، أو إيميلات اتصنفت يدوياً إنها Spam). المشكلة المعمارية هي: **إزاي نبني دالة رياضية `f(X)` تقدر تاخد المدخلات `X` (مساحة الشقة) وتطلع نتيجة `ŷ` تكون أقرب ما يمكن للنتيجة الحقيقية `y` (السعر الفعلي)؟**

من هنا ظهر الـ **Supervised Learning** (التعلم الخاضع للإشراف). السيستم هنا عامل زي طالب معاه "نموذج الإجابة" (Ground-Truth Labels). بيحل، يغلط، يقارن إجابته بنموذج الإجابة، ويعدل طريقة تفكيره (يعدل الأوزان `θ`) لحد ما نسبة الخطأ (Loss) توصل لأقل حد ممكن.

### 2. التشريح العميق لخوارزميات الـ Supervised Learning

التعلم الخاضع للإشراف بينقسم هندسياً لنوعين أساسيين بناءً على نوع الناتج (Output `Y`):

#### 📈 النوع الأول: الانحدار (Regression Algorithms)

بنستخدمه لما يكون الـ Output بتاعنا **قيمة رقمية متصلة (Continuous Output `Y ∈ ℝ`)**. (مثال: سعر، درجة حرارة، نسبة مبيعات).

**1. الانحدار الخطي (Linear Regression):**

- **الميكانيكا:** أبسط وأقدم خوارزمية. بتحاول ترسم "أفضل خط مستقيم" يمر بين نقاط الداتا بحيث يكون مجموع المسافات بين النقط والخط أقل ما يمكن.
    
- **المعادلة:** `ŷ = θ₀ + θ₁x₁ + θ₂x₂ ...` (الـ `x` هي الـ Features، والـ `θ` هي الأوزان اللي الموديل بيتعلمها).
    
- **دالة الخسارة (Loss Function):** بيستخدم الـ `MSE` (Mean Squared Error). بيحسب مربع الفرق بين التوقع والحقيقة عشان يتجاهل الإشارات السالبة ويعاقب الأخطاء الكبيرة بشدة.
    
- **الاستخدام (Use Case):** توقع المبيعات المستقبلية بناءً على ميزانية الإعلانات.
    

**2. خوارزمية XGBoost (Extreme Gradient Boosting) - نجمة الامتحان:**

- **الميكانيكا:** دي مش خوارزمية عادية، دي **Ensemble Method** (مجموعة خوارزميات شغالة مع بعض). بتعتمد على فكرة بناء أشجار قرار (Decision Trees) بشكل متسلسل (Sequentially).
    
- **السر المعماري:** الشجرة الأولى بتتبني وبتغلط. الشجرة التانية مبتتدربش على الداتا من الأول، لأ، دي بتتدرب على "الأخطاء" (Residuals) بتاعة الشجرة الأولى عشان تصلحها. الشجرة التالتة تصلح أخطاء التانية.. وهكذا. النتيجة النهائية هي مجموع تصحيحات كل الأشجار: `F(x) = Σ h_t(x)`.
    
- **الـ Hyperparameters المهمة:**
    
    - `n_estimators`: عدد الأشجار (لو زاد أوي يعمل Overfitting).
        
    - `learning_rate (η)`: بيقلل تأثير كل شجرة عشان الموديل يتعلم بالراحة وميبصمش الداتا.
        
- **الاستخدام (Use Case):** الساحر الأول في التعامل مع أي **بيانات مجدولة (Tabular/Structured Data)** زي ملفات الـ CSV. بيكتسح أي خوارزمية تانية في الداتا المهيكلة زي توقع احتمالية تخلف العميل عن سداد القرض.
    

#### 🗂️ النوع الثاني: التصنيف (Classification Algorithms)

بنستخدمه لما يكون الـ Output بتاعنا **فئة محددة (Discrete/Categorical Output)**. (مثال: مريض/سليم، أو قطة/كلب/عصفورة).

**1. الانحدار اللوجستي (Logistic Regression):**

- **الميكانيكا:** اسمه Regression بس هو في الحقيقة خوارزمية Classification! بيعمل إيه؟ بياخد الناتج بتاع الانحدار الخطي العادي، ويمرره جوه دالة اسمها **Sigmoid Function `σ(z) = 1/(1 + e^-z)`**.
    
- **السر المعماري:** الدالة دي بتعصر أي رقم في الدنيا (سواء مليون أو سالب مليون) وتطلعه في شكل **احتمالية (Probability) بين 0 و 1**.
    
- **اتخاذ القرار:** بنحط `Threshold` (عتبة). لو الاحتمالية > 0.5، الموديل يقول "Spam" (Class 1). لو أقل، يقول "Not Spam" (Class 0).
    
- **دالة الخسارة:** بيستخدم الـ `Log Loss` (Binary Cross-Entropy).
    

**2. أشجار القرار (Decision Trees):**

- **الميكانيكا:** بتشتغل زي لعبة "عروستي". الشجرة بتبدأ من الـ Root، وتسأل أسئلة بـ Yes/No بناءً على الـ Features (هل العمر > 30؟ -> هل الدخل > 50k؟) لحد ما توصل للـ Leaf Node اللي فيها القرار النهائي.
    
- **السر المعماري (Splitting Criteria):** إزاي الشجرة بتختار السؤال؟ بتستخدم معادلة رياضية زي الـ **Gini Impurity** أو הـ **Entropy**. بتختار السؤال اللي بيفصل الداتا لأكثر مجموعات نقاءً (يعني مجموعة كلها Spam ومجموعة كلها Not Spam).
    
- **المشكلة الكارثية:** الـ Decision Tree عندها قابلية مرعبة للـ **Overfitting** (High Variance). لو مفرملتهاش بـ `max_depth`، هتفضل تسأل أسئلة لحد ما تحفظ كل صف في الداتا لوحده.
    

**3. غابات القرار (Random Forests):**

- **الميكانيكا:** دي برضه **Ensemble Method**، بس بتعالج عيب الشجرة الواحدة (الـ Overfitting) عن طريق بناء "غابة" من مئات الأشجار.
    
- **السر المعماري (Bagging & Feature Randomness):** * كل شجرة بتتدرب على عينة عشوائية ومختلفة من الداتا (Bootstrap sample).
    
    - عند كل سؤال، الشجرة مبيكونش مسموح ليها تشوف كل الـ Features، بتشوف جزء عشوائي بس. ده بيخلي الأشجار (Decorrelated) مش شبه بعض.
        
- **القرار النهائي:** بناخد النتيجة بـ **"تصويت الأغلبية" (Majority Vote)** للـ Classification، أو الـ "متوسط" (Mean) للـ Regression.
    
- **الميزة:** بتقلل الـ Variance جداً ومبتبصمش الداتا.
    

### 3. المجاز المعماري (The Board of Directors Metaphor)

عشان نفرق بين الـ Decision Tree والـ Random Forest والـ XGBoost في اتخاذ القرار:

- **Decision Tree (المدير الديكتاتور):** مدير واحد بياخد كل القرارات بناءً على أسئلة صارمة في دماغه. قراره سريع جداً، بس لأنه لوحده، غالباً بيكون متحيز وتفكيره ضيق (High Variance).
    
- **Random Forest (البرلمان الديمقراطي):** بنجيب 100 خبير، كل واحد بنوريه جزء مختلف من المشكلة، وكل واحد بياخد قرار في السر. في الآخر بنجمع الأصوات والأغلبية بتكسب. الغلطات الفردية بتضيع في وسط الزحمة، والقرار النهائي بيكون متزن جداً (Low Variance).
    
- **XGBoost (لجنة المراجعة المتسلسلة):** بنجيب خبير يحل المشكلة. بعد ما يخلص، نجيب مراجع يدور على أخطاء الخبير الأول ويصلحها. بعدين نجيب مراجع تالت يصلح أخطاء التاني. التراكم ده بيطلع نتيجة دقيقة بشكل مرعب (Low Bias).
    

### 4. اللوحة المعمارية: مسارات الـ Supervised Learning (Mermaid)

Code snippet

```
graph TD

classDef default font-weight:bold,font-size:14px,stroke-width:2px;
classDef supervised fill:#e6f7ff,stroke:#1890ff,color:#000;
classDef algo fill:#fff,stroke:#595959,color:#000;
classDef ensemble fill:#f6ffed,stroke:#52c41a,color:#000;

subgraph Supervised_Learning_Engine ["⚙️ Supervised Learning (Labeled Data)"]
    direction TB
    
    Data["Dataset: Features (X) + Ground Truth (Y)"] --> Split
    
    Split{"What is the type of Output (Y)?"}
    
    Split -->|Continuous Number<br>(e.g. $150.5, 30.2°C)| Regression["📈 Regression Task"]
    Split -->|Discrete Category<br>(e.g. Spam, Not Spam)| Classification["🗂️ Classification Task"]
    
    Regression --> LinReg["Linear Regression<br>(Fits a straight line)"]:::algo
    Regression --> XGB_Reg["XGBoost (Regression)<br>(Sequential Trees correcting errors)"]:::ensemble
    
    Classification --> LogReg["Logistic Regression<br>(Uses Sigmoid for Probabilities)"]:::algo
    Classification --> DTree["Decision Trees<br>(Yes/No splitting logic)"]:::algo
    Classification --> RForest["Random Forest<br>(Parallel Trees + Majority Vote)"]:::ensemble
    Classification --> XGB_Class["XGBoost (Classification)"]:::ensemble

end

class Data,Split,Regression,Classification supervised;
```

### 5. دستور الامتحان (Exam Traps & Keyword Mapping)

ركز في الـ Keywords دي لأنها بتيجي بالنص في أسئلة السيناريو (Use Cases):

|**فخ السيناريو في الامتحان (The Trap/Keyword)**|**الخوارزمية / الإجابة المطلوبة**|**التفسير المعماري (Why?)**|
|---|---|---|
|`Structured data`, `Tabular datasets`, `Consistently wins Kaggle`, `Gradient boosted trees`|**XGBoost**|الـ XGBoost هو المكتسح لأي داتا موجودة في أعمدة وصفوف (Tabular)، الامتحان دايماً بيجيبه كأفضل حل للـ Structured data.|
|`Binary outcome`, `Probability of an event between 0 and 1`|**Logistic Regression**|رغم وجود كلمة Regression، إلا إنه الحل الكلاسيكي لتحويل الأرقام لاحتمالات (0 أو 1) عبر دالة الـ Sigmoid.|
|`Ensemble of decorrelated trees`, `Bootstrap sample`, `Majority vote`|**Random Forests**|دي الميكانيكا الحرفية لبناء غابات القرار لمنع الـ Overfitting (طريقة الـ Bagging).|
|`Sequential trees correcting previous errors`, `Residual learning`|**XGBoost** أو **Gradient Boosting**|طريقة الـ Boosting بتعتمد على التدريب "المتسلسل" (Sequential)، عكس الـ Random forest اللي بيتدرب "بالتوازي" (Parallel).|
|`Highly interpretable`, `Human-readable rules`, `Prone to overfitting`|**Decision Trees**|شجرة القرار هي أكتر خوارزمية الـ البشر بيقدروا يقرأوا القواعد بتاعتها كأنها `If/Else`، بس عيبها إنها بتبصم.|

---

