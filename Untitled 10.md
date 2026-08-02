# 🔴 الموضوع الأول: الـ Inner Classes (الفئات الداخلية) - الشرح الشامل العميق

في بداية تصميم الجافا (الكلاسيكية)، كان كل الكود بيكتب في كلاس مفرد جوه ملف `.java` مستقل. لكن مع تعقد المشاريع، ظهرت حاجة ماسة لربط الكلاسات المترابطة جداً ببعضها بدون ما نعمل ملفات زيادة وبدون ما نكسر مبدأ الـ Encapsulation.

الـ **Inner Class** هو كلاس بيتم تعريفه **جوه كلاس تاني**.

## 💡 ليه الجافا عملت الـ Inner Classes؟ (المميزات والفوائد)

1. **الوصول التام للـ Private Data (Encapsulation Bypass):**
    
    الـ Inner Class له "صلاحية استثنائية" في الجافا: يقدر يوصل لجميع العناصر (`variables` و `methods`) الخاصة بالـ Outer Class حتى لو كانت **`private`**!
    
2. **الربط المنطقي المحكم (Logical Grouping):**
    
    لو عندك كلاس بيخدم على كلاس واحد فقط ومحدش تاني في السيستم هيستخدمه (زي مثلاً `Node` جوه `LinkedList`)، مش منطقي تسيبه صايع في ملف لوحده. حطه جوه الكلاس الأساسي!
    
3. **تحسين قراءة وتنظيم الكود (Code Readability & Maintainability):**
    
    بدل ما الملفات تكثر والـ Package تترس كلاسات صغيرة ملهاش قيمة مستقلة، الكود بيبقى ملموم ومترتب.
    

## 🛠️ الأنواع الأربعة للـ Inner Classes (بالتفصيل والكود)

الجافا توفر 4 أنواع من الـ Inner Classes، وكل نوع له غرض واستخدام في الميموري:

### 1️⃣ Non-Static Nested Class (Member Inner Class)

ده الكلاس الداخلي العادي. بيتعامل مع الـ Outer Class كأنه member عادي زي أي Variable أو Method.

- **الخاصية الأساسية:** مرتبط **بـ Object (Instance)** من الـ Outer Class.
    
- **الوصول للميموري:** يقدر يوصل لكل الـ Static و Non-Static members بتاعة الـ Outer Class.
    
n
Java

```java
// Outer Class
class BankAccount {
    private double balance = 10000.0; // Private Field
    private String accountNumber = "EG123456789";

    // Non-Static Inner Class
    class TransactionHistory {
        public void printStatement() {
            // كود الـ Inner بيوصل لـ private balance بشكل مباشر!
            System.out.println("Account: " + accountNumber);
            System.out.println("Current Balance: " + balance + " EGP");
        }
    }
}

public class Main {
    public static void main(String[] args) {
        // ❌ الخطأ الشهير: ما ينفعش تكريت Inner مباشرة من غير Outer!
        // BankAccount.TransactionHistory history = new BankAccount.TransactionHistory(); // Compilation Error!

        // ✅ الطريقة الصحيحة: لازم تكريت Outer الأول
        BankAccount account = new BankAccount();
        
        // بعدين تكريت الـ Inner باستخدام الـ Instance بتاع الـ Outer (لاحظ السنتاكس: account.new)
        BankAccount.TransactionHistory history = account.new TransactionHistory();
        
        history.printStatement();
    }
}
```

### 2️⃣ Static Nested Class

ده كلاس بنحطه جوه الكلاس الخارجي وبنحط قبله كلمة **`static`**.

- **الخاصية الأساسية:** **غير مرتبط بـ Instance** من الـ Outer Class. بيتعامل كأنه كلاس خارجي أصلاني بس معزول منطقياً جوه Scope الـ Outer.
    
- **الوصول للميموري:** يقدر يوصل **فقط للـ Static members** بتاعة الـ Outer Class! **ما ينفعش** يوصل لـ Non-static variables (لأنه مش محتاج Outer Object يتكريت عشان يشتغل).
    

Java

```java
class FawryPaymentSystem {
    private static String systemVersion = "v2.4.0"; // Static
    private String merchantKey = "SECRET_KEY_123";  // Non-Static

    // Static Nested Class
    static class SystemUtils {
        public void checkVersion() {
            // ✅ ينفع: يوصل للـ Static
            System.out.println("System Version: " + systemVersion); 
            
            // ❌ ما ينفعش: خطأ كومبايلر لو حاول يوصل لـ merchantKey!
            // System.out.println(merchantKey); // Cannot make a static reference to non-static field
        }
    }
}

public class Main {
    public static void main(String[] args) {
        // ✅ بنكريته مباشرة باسم الـ Class من غير ما نعمل new FawryPaymentSystem()!
        FawryPaymentSystem.SystemUtils utils = new FawryPaymentSystem.SystemUtils();
        utils.checkVersion();
    }
}
```

### 3️⃣ Local Inner Class (الفئة المحلية)

ده كلاس بيتم تعريفه **جوه Method معينة** في الكلاس الخارجي!

- **الخاصية الأساسية:** نطاق رؤيته (Scope) محصور فقط داخل الميثود دي. محدش بره الميثود يقدر يشوفه أو ياخد منه Instance.
    
- **شرط مهم جداً:** يقدر يوصل للـ Variables المحلية بتاعة الميثود **بشرط تكون `final` أو `effectively final`** (يعني القيمة بتاعتها مش بتتغير بعد ما تتدسجل).
    

Java

```
class OrderProcessor {
    public void processOrder(double amount) {
        double taxRate = 0.14; // Effectively Final variable

        // Local Inner Class جوه الميثود!
        class TaxCalculator {
            public double calculateTotal() {
                return amount + (amount * taxRate);
            }
        }

        // الاستخدام بيكون جوه الميثود نفسها
        TaxCalculator calc = new TaxCalculator();
        System.out.println("Total Amount after Tax: " + calc.calculateTotal());
    }
}
```

### 4️⃣ Anonymous Inner Class (الفئة المجهولة)

كلاس ملوش اسم، بنكريته ونعمل منه Instance في نفس السطر.

_(ده هنفرد له الرسالة الجاية بالكامل لأنه بوابة الـ Lambda Expressions والـ Interfaces!)_

## 🎯 أساليب وأسئلة الإنترفيو القاتلة في فوري وفودافون (Inner Classes)

إليك أهم الأسئلة التي تطرح في مقابلات الشركات الكبرى حول هذا الموضوع، مع الإجابات النموذجية:

### ❓ س1: ما الفرق بين Static Nested Class و Non-Static Inner Class من حيث الميموري والـ Encapsulation؟

- **الإجابة:**
    
    1. **الارتباط بالحالة (Instance Binding):** الـ Non-Static Inner Class بيحتفظ بمرجع مخفي (Implicit Reference) للكلاس الخارجي اللي أنشأه (`OuterClass.this`). ده معناه إنه بيستهلك ميموري زيادة وما ينفعش يعيش بدون Outer Object. أما الـ Static Nested Class فملوش أي مرجع للكلاس الخارجي وبيتعامل كأنه Top-level class منفصل.
        
    2. **الصلاحيات:** الـ Non-Static بيقدر يوصل لكل الـ Members (Static و Non-Static حتى الـ `private`). أما الـ Static بيمتلك وصولاً فقط للـ `static members` بتاعة الكلاس الخارجي.
        

### ❓ س2: لما بنعمل Compile لكلاس جواها Inner Class، ملفات الـ `.class` الصادرة بتكون إزاي؟

- **الإجابة:**
    
    الكومبايلر بيولد ملف `.class` منفصل لكل Inner Class بالصيغة دي:
    
    - للـ Non-static / Static Inner Class: `OuterClass$InnerClass.class`
        
    - للـ Local Inner Class: `OuterClass$1LocalClassName.class`
        
        _(الشركات بتسأل السؤال ده عشان تتأكد إنك فاهم الكومبايلر بيتعامل إزاي تحت الترابيزة - Under the hood)._
        

### ❓ س3: كيف يحل الكومبايلر مشكلة وصول الـ Inner Class لبيانات الـ `private` بتاعة الـ Outer Class برغم إن الـ JVM ممنوع يتخطى الـ Encapsulation؟

- **الإجابة المتقدمة جداً (To Impress the Interviewer):**
    
    في الـ Bytecode، الكومبايلر بيعمل توليد أوتوماتيكي لـ Synthetic Accessor Methods (طرق وصول مساعدة محصورة بالبكدج) في الكلاس الخارجي، وتُسمى مثلاً `access$000()`. الـ Inner Class بيستدعي الميثود المساعدة دي عشان يجيب القيمة الـ `private` بدون ما يكسر قواعد الـ JVM!
    

### ❓ س4: هل ينفع نعرف `static members` جوه Non-Static Inner Class؟

- **الإجابة:**
    
    - في إصدارات الجافا القديمة (Java 8 حتى Java 15): **لا ينفع**، كان بيدي الكومبايلر خطأ مباشر لأن الكلاس نفسه مش static. (إلا لو كانت `static final` ثابتة primitive).
        
    - بداية من **Java 16 وما بعدها**: **نعم أصبح مسموحاً** بتعريف static members جوه الـ Non-Static Inner Class.
        

## 📌 ملخص الـ Inner Classes

- **المفهوم:** كلاس بيكتب جوه كلاس تاني بهدف تنظيم الكود، تحسين الـ Encapsulation، ومشاركة البيانات.
    
- **الخاصية الذهبية:** الـ Inner Class له صلاحية الوصول لكل عناصر الـ Outer Class حتى لو كانت **`private`**.
    

### 🔑 الفروق الأساسية بين الأنواع الأربعة:

- **Non-Static Inner Class (الممبر العادي):**
    
    - مرتبط بـ Object من الـ Outer Class (يلزمه `outerObj.new Inner()`).
        
    - يقدر يوصل للـ Static والـ Non-Static variables في الـ Outer Class.
        
    - بيمسك Implicit Reference بالكلاس الخارجي في الميموري (`OuterClass.this`).
        
- **Static Nested Class:**
    
    - **مش** مرتبط بـ Instance من الـ Outer Class (بنتكريته بـ `new OuterClass.StaticInner()`).
        
    - بيوصل فقط للـ **`static members`** بتاعة الـ Outer Class.
        
    - مش بيمسك Reference للـ Outer Object، وبالتالي استهلاكه للميموري أقل وأفضل في الأداء.
        
- **Local Inner Class:**
    
    - بيتعرف **جوه Method معينة** وسكوب رؤيته محصور جواه بس.
        
    - يقدر يوصل للـ Local Variables بشرط تكون **`final` أو `effectively final`**.
        
- **Anonymous Inner Class:**
    
    - كلاس ملوش اسم، بيتكرّيت وبيتعمل منه Instance في نفس السطر (بوابة الـ Lambda Expressions).
        

### 🎯 أهم نقاط وتريكات الإنترفيو (Under the Hood):

- **ملفات الـ Bytecode:** الكومبايلر بيعمل لكل Inner Class ملف منفصل بصيغة `OuterClass$InnerClass.class`.
    
- **الوصول للـ Private:** الكومبايلر بيولّد Synthetic Accessor Methods مخفية في الـ Outer Class عشان يسمح للـ Inner Class يقرا الـ Private variables من غير ما يكسر قواعد الـ JVM.
    
- **تحديث Java 16:** ينفع حالياً نكتب `static members` جوه الـ Non-Static Inner Class (كان ممنوع من Java 8 لـ Java 15 إلا لو `static final`).

----
حقك عليا يا هندسة، شكل السيرفر فصل مني لحظة في النص! 😂 هعيدلك الشرح كله من الأول، وبالمصري البسيط والواضح عشان يثبت في دماغك وتدخل إنترفيو فوري وفودافون وأنت حاطط رجل على رجل.

---

# 🔴 الموضوع الثاني: الـ Anonymous Inner Class (الكلاس المجهول)

بص يا سيدي، الـ **Anonymous Inner Class** ده يعتبر من أهم الحاجات اللي عملت نقلة في الجافا، لأنه كان الباب اللي دخلنا منه للـ Lambda Expressions بعدين.

## 💡 إيه المشكلة اللي المفهوم ده بيحلها؟

**تخيل معايا الموقف ده:**
عندك `Interface` اسمه `Payment` جواه ميثود اسمها `pay()`. وأنت شغال في الكود، احتجت تعمل كلاس يطبق (implement) الـ Interface ده عشان تستخدمه **مرة واحدة بس** في مكان معين.

**زمان (قبل الكلاس المجهول):**
كنت لازم تروح تفتح ملف `.java` جديد، وتسمي الكلاس مثلاً `FawryPayment`، وتعمل `implements Payment`، وتكتب الكود، وبعدين ترجع للكود الأصلي تاخد منه Object (نسخة). لفة طويلة ومملة، وبتخلي البروجكت مليان كلاسات صغيرة ملهاش لازمة وبتتسمى "Boilerplate code".

**الحل السحري (Anonymous Inner Class):**
الجافا قالتلك: "طالما أنت محتاجه مرة واحدة بس ومكسل تعمله ملف لوحده، إيه رأيك تعمله وتاخد منه Object في نفس السطر، ومن غير ما تديله اسم أصلاً؟". ومن هنا جت الفكرة!

---

## 🛠️ بيتكتب إزاي عملي؟

ليه طريقتين مشهورين بنستخدمهم:

### 1️⃣ عن طريق Interface

هنا إحنا بنعمل كلاس مجهول بيطبق الـ Interface ده في نفس اللحظة:

```java
interface PaymentProcessor {
    void processTransaction(double amount);
}

public class Main {
    public static void main(String[] args) {
        
        // هنا السحر! بنكريت الكلاس وناخد منه نسخة في نفس السطر
        PaymentProcessor fawryPay = new PaymentProcessor() {
            @Override
            public void processTransaction(double amount) {
                System.out.println("دفع فاتورة فوري بقيمة: " + amount);
            }
        };

        // بننادي على الميثود عادي جداً
        fawryPay.processTransaction(500.0);
    }
}

```

> ⚠️ **تركة إنترفيو:** لو حد سألك "هو إزاي عملت `new` لـ Interface وده ممنوع في الجافا؟"
> **ردك يكون:** "أنا معملتش Object من الـ Interface، أنا عملت Anonymous Class (كلاس مجهول) بيعمل implement للـ Interface، وخدت الـ Object من الكلاس المجهول ده!".

### 2️⃣ عن طريق Class عادي أو Abstract

نفس الفكرة بالظبط، لو عندك كلاس وعاوز تعمل Override لميثود جواه على الطاير:

```java
class VodafoneNetwork {
    void checkConnection() {
        System.out.println("Checking 4G...");
    }
}

public class Main {
    public static void main(String[] args) {
        
        VodafoneNetwork network = new VodafoneNetwork() {
            @Override
            void checkConnection() {
                System.out.println("Checking 5G for Vodafone directly!");
            }
        };

        network.checkConnection(); // هيطبع بتاعت الـ 5G
    }
}

```

---

## 🛑 شروط وقيود مهمة جداً (لازم تكون عارفها)

1. **مفيش Constructor:** بما إن الكلاس أصلاً ملوش اسم، فمستحيل تعمله Constructor.
2. **بيعمل حاجة واحدة بس:** يا إما يطبق (`implements`) Interface واحد، يا إما يورث (`extends`) من Class واحد. مينفعش يعمل الاتنين مع بعض.
3. **موضوع الـ Effectively Final:** لو الكلاس المجهول ده حب يستخدم متغير (Variable) متعرف بره في الميثود اللي هو مكتوب جواها، لازم المتغير ده قيمته متتغيرش بعد ما تتكتب (يعني يكون `final` أو بيتعامل كأنه `final`).

---

## 🎯 أسئلة إنترفيو فوري وفودافون في الحتة دي (Under the hood)

الشركات دي بتحب تسأل في الحاجات اللي "تحت الكبوت" عشان يتأكدوا إنك فاهم مش حافظ:

### ❓ السؤال الأول: الكومبايلر بيسمي ملفات الـ `.class` بتاعت الكلاس المجهول إيه؟

* **الإجابة النموذجية:** الكومبايلر بيديها أرقام تسلسلية لأنها ملهاش اسم. هتلاقي الملف طالع باسم الكلاس الخارجي زائد علامة الدولار ورقم، زي كده:
`OuterClass$1.class`
`OuterClass$2.class`

### ❓ السؤال التاني: إيه الفرق في استهلاك الميموري بين الـ Anonymous Class والـ Lambda Expression؟ (سؤال للتميز)

* **الإجابة:**
الـ Anonymous Class بيعمل ملف `.class` حقيقي، ولما الكود بيشتغل بيتكريت ليه Object حقيقي في الـ Heap Memory بياخد مساحة.
أما الـ Lambda Expression (في جافا 8) مبتعملش كلاسات خالص تحت الترابيزة! بتستخدم حاجة اسمها `invokedynamic` وبتكون أسرع بكتير وموفرة جداً في الميموري.

### ❓ السؤال التالت: ينفع أعمل ميثود جديدة خاصة بيا جوه الـ Anonymous Class واستخدمها من بره؟

* **الإجابة:** تقدر تكتب الميثود عادي جوه ومش هيضرب إيرور، **لكن مش هتقدر تنادي عليها من بره!** ليه؟ لأن الـ Reference بتاعك (المتغير اللي شايل الكلاس) بيكون من نوع الـ Interface أو الـ Class الأب، والأب ميعرفش حاجة عن الميثود الجديدة اللي أنت اخترعتها تحت.

---

## 📌 ملخص الـ Anonymous Inner Class (الكلاس المجهول)

* **الفكرة باختصار:** كلاس ملوش اسم، بتكتبه وتاخد منه Object في نفس اللحظة وفي نفس السطر، عشان تستخدمه مرة واحدة بس.
* **الهدف منه:** بيوفر عليك تعمل ملف `.class` كامل عشان تعدل سلوك (Override) لميثود هتستخدمها مؤقتاً، وهو اللي مهد الطريق لظهور الـ Lambda Expressions.

### 🛑 أهم شروطه وقيوده (بتيجي كتير في الأسئلة):

* **مفيش Constructor:** طالما ملوش اسم، يبقى مستحيل تعمله Constructor.
* **حاجة واحدة بس:** يا إما يطبق (`implements`) Interface **أو** يورث (`extends`) من Class. مستحيل يعمل الاتنين مع بعض.
* **قاعدة الـ Effectively Final:** لو هيقرأ متغير محلي (Local Variable) من الميثود اللي هو مكتوب جواها، لازم المتغير ده متتغيرش قيمته نهائي بعد ما تتكتب.

### 🎯 تريكات الإنترفيو اللي بتيجي فيه (Under the hood):

* **اسم الملف المجهول:** الكومبايلر بيحوله لملف `.class` بياخد رقم تسلسلي، زي `OuterClass$1.class`.
* **ميثود جديدة؟:** تقدر تكتب ميثود خاصة بيك جواه، بس مستحيل تنادي عليها من بره لأنه متسجل في Reference بتاع الأب اللي ميعرفش الميثود دي.
* **الفرق بينه وبين الـ Lambda (سؤال فودافون القوي):** الـ Anonymous Class بيكريت ملف `.class` حقيقي وبياخد ميموري.. إنما الـ Lambda مش بتعمل كلاسات خالص وبتعتمد على حاجة اسمها `invokedynamic` فبتكون موفرة وسريعة جداً.

---
عاش جداً! بما إن الأساسيات كده بقت تمام ومترتبة في دماغك، هننقل دلوقتي على **أهم مرحلة في الجافا الحديثة**. المرحلة دي هي اللي بتفرق في الإنترفيو بين ديفيلوبر بيكتب جافا قديمة (Java 7 وأقدم) وديفيلوبر فاهم جافا حديثة (Java 8 وطالع).

# 🔴 الموضوع الرابع: تطور الـ Interface في جافا 8 والـ Functional Interface

قبل جافا 8، الـ Interface كان صارم جداً: **"كل الميثودز اللي جواه لازم تكون فاضية (Abstract) وممنوع تكتب جواها أي كود"**. بس في جافا 8، مهندسين أوراكل غيروا القواعد دي تماماً.. ليه؟

## 💡 التطور التاريخي: ليه غيروا الـ Interface في جافا 8؟ (المشكلة والحل)

**المشكلة (كسر الكود القديم):**

تخيل مهندسين الجافا حبوا يضيفوا ميزة جديدة زي الـ `Stream API` جوه الـ Interface القديم اللي اسمه `Collection`.

لو كانوا حطوا الميثود دي كـ Abstract، كان **كل كود العالم** اللي مطبق الـ `Collection` هيضرب Compilation Error في ثانية، لأنهم هيكونوا مجبرين يعملوا Override للميثود الجديدة دي! ده اسمه كسر التوافقية (Breaking Backward Compatibility).

**الحل السحري (Default & Static Methods):**

عشان يحلوا الأزمة دي، سمحوا إن الـ Interface يشيل ميثودز فيها كود حقيقي، عن طريق كلمتين:

1. **`default` methods:** ميثود ليها Body وكود جاهز. الكلاس اللي بيطبق الـ Interface يقدر يستخدمها زي ما هي، أو يعملها Override براحته.
    
2. **`static` methods:** ميثود برضه ليها Body، بس تخص الـ Interface نفسه ومينفعش الكلاس يعملها Override. بننادي عليها باسم الـ Interface مباشرة.
    

## 🎯 يعني إيه بقى Functional Interface؟ (المفهوم الذهبي)

الـ **Functional Interface** هو ببساطة شديدة: **Interface بيحتوي على ميثود واحدة فقط لا غير فاضية (Abstract Method)**. المفهوم ده معروف في الإنترفيوهات باسم **SAM (Single Abstract Method)**.

**طب ليه عملوه؟**

عشان يكون هو "الهدف" أو "المستقبل" بتاع الـ **Lambda Expressions** (اللي هنشرحه المرة الجاية). الـ Lambda بتحتاج ميثود واحدة بس عشان تنفذها، فالـ Functional Interface هو المكان المثالي ليها.

### 🛠️ الكود العملي (السنتاكس):

عشان نعرّف الكومبايلر إن ده Functional Interface، بنحط فوقيه أنوتيشن اسمه `@FunctionalInterface`.

Java

```
@FunctionalInterface
interface Calculator {
    
    // 1. الميثود اليتيمة الفاضية (Abstract) - دي الإجبارية
    int calculate(int x, int y);
    
    // 2. ميثود عادية (Default) - مسموح بيها عادي ومبتأثرش على شروطنا
    default void printResult(int result) {
        System.out.println("The result is: " + result);
    }
    
    // 3. ميثود ثابتة (Static) - مسموح بيها برضه
    static void showWelcomeMessage() {
        System.out.println("Welcome to Fawry Calculator!");
    }
}
```

**القاعدة الذهبية:** الـ Functional Interface ملوش دعوة عندك كام ميثود `default` أو `static`.. الشرط الوحيد إن يكون عندك **ميثود واحدة بس Abstract**.

## 💥 أسئلة وتريكات الإنترفيو القاتلة (فوري، فودافون، وڤويس):

الأسئلة هنا بتبقى خبيثة وبتقيس قوة ملاحظتك:

### ❓ سؤال 1: إيه اللي هيحصل لو شلت الأنوتيشن `@FunctionalInterface` من فوق الـ Interface؟ هل هيضرب إيرور؟

- **الإجابة:** **لأ مش هيضرب إيرور خالص!** الأنوتيشن ده مش إجباري، ده مجرد **Validation (تأكيد)** للكومبايلر زيه زي `@Override`. يعني لو حطيته، الكومبايلر هيراقب الـ Interface ده، ولو حد من زمايلك في التيم حاول يضيف ميثود فاضية تانية جواه، الكومبايلر هيضربه على إيده ويديله إيرور. لو شلته، هيفضل برضه Functional Interface طالما جواه ميثود واحدة فاضية.
    

### ❓ سؤال 2: لو عندي Interface فيه ميثود واحدة فاضية، بس كمان عامل ميثود فاضية تانية اسمها `equals()` أو `toString()`.. هل ده يعتبر Functional Interface ولا كده بقوا اتنين ميثودز؟

- **الإجابة النموذجية (بتبهر اللي قدامك):** **أيوة، هيفضل Functional Interface!** الجافا بتستثني أي ميثود فاضية معمولة عشان تطابق ميثودز كلاس `Object` الأساسي (زي `equals`, `hashCode`, `toString`). الكومبايلر مش بيحسبهم من ضمن عدد الـ Abstract Methods في الـ Interface، لأن أي كلاس في الدنيا كده كده هيورثهم من كلاس `Object`.
    

### ❓ سؤال 3: إيه المشكلة اللي بتحصل لو عملت `implements` لاتنين Interfaces، والاتنين فيهم نفس الـ `default method` بنفس الاسم؟

- **الإجابة:** دي مشكلة الـ Diamond Problem اللي اتكلمنا عنها! الجافا هنا **هتضرب إيرور وقت الكومبايل** وتجبرك إنك تعمل `Override` للميثود دي جوه الكلاس بتاعك، وتحدد أنت عاوز تنفذ الكود بتاع أني Interface فيهم، أو تكتب كود جديد خالص يحل التعارض ده. (بتنادي على الـ super بتاعها بالطريقة دي: `InterfaceName.super.methodName()`).

---

## 📌 ملخص تطور الـ Interface في جافا 8 والـ Functional Interface

### 1️⃣ التغيير الجذري في جافا 8 (ليه حصل؟)

- **المشكلة الأساسية:** قبل جافا 8، لو أوراكل ضافت أي ميثود جديدة لـ Interface قديم (زي `Collection`)، كل المشاريع في العالم كانت هتضرب إيرور لأن الكلاسات هتُجبر تعملها Override.
    
- **الحل السحري:** جافا سمحت بوجود ميثودز **مكتوب جواها كود حقيقي** جوه الـ Interface عشان تحافظ على التوافقية (Backward Compatibility)، عن طريق نوعين:
    
    1. **`default` methods:** ميثود بكود جاهز، الكلاس يقدر يستخدمه زي ما هو، أو يعملها Override ويغيره براحته.
        
    2. **`static` methods:** ميثود بكود تخص الـ Interface نفسه ومينفعش الكلاس يعملها Override (بنناديها باسم الانترفيس).
        

### 2️⃣ الـ Functional Interface (الهدف الرئيسي)

- **التعريف (SAM):** اختصار لـ Single Abstract Method. هو Interface جواه **ميثود واحدة فقط لا غير فاضية** (Abstract).
    
- **الهدف منه:** اتعمل مخصوص عشان يكون هو المستقبل والأساس اللي هتتبني عليه الـ **Lambda Expressions**.
    
- **قاعدة المرونة:** الـ Functional Interface يقدر يشيل **أي عدد** من الـ `default` أو الـ `static` ميثودز براحته، طالما محتفظ بـ ميثود واحدة بس Abstract.
    

### 3️⃣ 🎯 تريكات الإنترفيو اللي بتوقع (Under the hood)

- **خدعة الأنوتيشن (`@FunctionalInterface`):**
    
    - الأنوتيشن ده **مش إجباري** خالص.
        
    - لو شلته، هيفضل الكود شغال والانترفيس هيفضل Functional طالما فيه ميثود واحدة فاضية.
        
    - وظيفته بس "الحماية" (Validation)، بيخلي الكومبايلر يضرب إيرور لو حد حاول يضيف ميثود فاضية تانية.
        
- **استثناء ميثودز الـ `Object`:**
    
    - لو كتبت ميثود فاضية جوه الانترفيس بتطابق ميثود من كلاس Object (زي `equals` أو `toString`)، **الكومبايلر مش بيعدها!** وهيفضل الانترفيس Functional عادي جداً.
        
- **الـ Diamond Problem رجعت تاني!**
    
    - لو كلاس عمل `implements` لاتنين Interfaces والاتنين فيهم نفس الـ `default method` بنفس الاسم، الكومبايلر هيضرب إيرور.
        
    - **الحل:** الجافا هتجبرك تعمل `Override` للميثود دي جوه الكلاس بتاعك عشان تحل التعارض.
---

أنا متفهم إحباطك من لخبطة التنسيق، وهدخل في الشرح التفصيلي الكامل من الصفر للموضوع الخامس (الـ Lambda Expressions) بتنسيق يضمن القراءة السليمة.

# 🔴 الموضوع الخامس: الـ Lambda Expressions (من الصفر)

الـ Lambda Expressions هي التحديث الأهم في تاريخ الجافا (بداية من جافا 8)، وهي اللي نقلت اللغة من مجرد "برمجة كائنية" (OOP) إلى دعم الـ "البرمجة الوظيفية" (Functional Programming).

## 💡 ليه الجافا اخترعت الـ Lambda؟ (المشكلة والحل)

**المشكلة قبل جافا 8:**

لو عندك Interface فيه ميثود واحدة، وعاوز تستخدمها، كنت بتضطر تستخدم الـ Anonymous Inner Class. الطريقة دي كانت بتجبرك تكتب سطور كتير جداً (Boilerplate Code) ملهاش لازمة: بتكتب اسم الانترفيس، وكلمة `new`، و `@Override`، واسم الميثود، وأقواس كتير عشان تنفذ سطر واحد بس من الكود.

**الحل السحري (Lambda):**

الجافا صممت اللامبدا عشان تشتغل **حصرياً مع الـ Functional Interfaces** (اللي فيها ميثود واحدة بس فاضية). الجافا قالت: "بما إن الانترفيس مفيهوش غير ميثود واحدة، أنا ككومبايلر عارف اسمها وعارف بتاخد إيه وبترجع إيه.. فمفيش داعي تكتب كل ده. اكتبلي بس (المدخلات)، وسهم `->`، و(الكود اللي هيتنفذ)".

## 🛠️ إزاي بنكتبها؟ (الكود وقواعد الاختصار)

الشكل الأساسي للـ Lambda هو:

`(Parameters) -> { Body }`

تعالى نقارن بين الطريقة القديمة والجديدة لإنشاء آلة حاسبة بسيطة:

**أولاً: الطريقة القديمة (Anonymous Inner Class):**

Java

```
@FunctionalInterface
interface Calculator {
    int add(int a, int b);
}

public class Main {
    public static void main(String[] args) {
        // كتابة سطور كتير عشان أمر بسيط
        Calculator calc = new Calculator() {
            @Override
            public int add(int a, int b) {
                return a + b;
            }
        };
        System.out.println(calc.add(5, 10));
    }
}
```

**ثانياً: الطريقة الجديدة (Lambda Expression):**

نفس الكود اللي فوق، هنضغطه بالشكل ده:

Java

```
public class Main {
    public static void main(String[] args) {
        // اختصار كل الدوشة اللي فاتت
        Calculator calc = (int a, int b) -> {
            return a + b;
        };
        System.out.println(calc.add(5, 10));
    }
}
```

### ✂️ مستويات الاختصار (عشان تكتب كود احترافي):

الكومبايلر ذكي جداً، وبيديك صلاحية تختصر الكود أكتر وأكتر بناءً على 3 قواعد:

1. **حذف نوع البيانات (Data Types):** الكومبايلر عارف من الانترفيس إنهم `int`، فمش لازم تكتبهم.
    
    `Calculator calc = (a, b) -> { return a + b; };`
    
2. **حذف الأقواس `{ }` وكلمة `return`:** لو الكود بتاعك بيتنفذ في سطر واحد فقط!
    
    `Calculator calc = (a, b) -> a + b;`
    
3. **حذف الأقواس العادية `( )` للبارامتر:** لو الميثود بتاخد **متغير واحد فقط**، تقدر تشيل الأقواس من عليه.
    
    `(x) -> x * 2;` ممكن تتكتب كده `x -> x * 2;`
    

## 🎯 أسئلة الإنترفيو القاتلة (فوري وفودافون)

الأسئلة في الجزء ده بتقيس فهمك للي بيحصل تحت الترابيزة (Under the hood):

### ❓ السؤال الأول: إيه الفرق في استهلاك الميموري والأداء بين الـ Lambda والـ Anonymous Inner Class؟ (أهم سؤال)

- **الإجابة النموذجية:**
    
    - **الـ Anonymous Class:** وقت الكومبايل، بيكريت ملف `.class` حقيقي على الهارد (مثلاً `Main$1.class`). ووقت التشغيل، بيكريت Object كامل بياخد مساحة في الـ Heap Memory.
        
    - **الـ Lambda Expression:** الجافا **مبتعملش كلاسات جديدة خالص** وقت الكومبايل. بتستخدم تعليمة داخل الـ JVM اسمها `invokedynamic`. التعليمة دي بتربط الكود مباشرة وقت التشغيل، وده بيخلي اللامبدا أسرع بكتير، ومش بتعمل زحمة في الميموري ولا بتكتر ملفات الكلاسات.
        

### ❓ السؤال الثاني: هل ينفع أستخدم الـ Lambda مع أي Interface في الجافا؟

- **الإجابة:** **مستحيل.** اللامبدا بتشتغل **فقط** مع الـ Functional Interfaces (اللي فيها ميثود واحدة Abstract). لو الانترفيس فيه أكتر من ميثود فاضية، الكومبايلر هيضرب Compilation Error لأنه مش هيعرف السهم `->` ده معمول عشان ينفذ أي ميثود فيهم.
    

### ❓ السؤال الثالث: إيه هي قاعدة الـ "Variable Capture" أو الـ "Effectively Final" في اللامبدا؟

- **الإجابة:** لو اللامبدا استخدمت متغير (Variable) متعرف بره الأقواس بتاعتها (Local Variable)، الجافا بتشترط إن المتغير ده يكون `final` أو `Effectively Final` (يعني قيمته متتغيرش أبداً بعد أول مرة أخد فيها قيمة).
    
- **السبب:** اللامبدا بتاخد Copy من المتغير ده، فلو أنت غيرت قيمة المتغير الأصلي بره اللامبدا، الكومبايلر هيمنعك وهيضرب إيرور عشان النسخة اللي جوه اللامبدا متبقاش قديمة وغلط.
---
إليك خلاصة الـ **Lambda Expressions** في نقاط سريعة ومباشرة للمراجعة قبل الإنترفيو:

- **الهدف الأساسي:** اختصار سحري بيغنيك عن السطور الكتير بتاعة الـ Anonymous Inner Class، وبنكتب بيه "المدخلات" وسهم `->` و"الكود" في سطر واحد.
    
- **شرط الاستخدام الصارم:** اللامبدا بتشتغل **حصرياً** مع الـ Functional Interface (اللي فيه ميثود واحدة بس Abstract)، مستحيل تشتغل مع أي Interface تاني.
    
- **قواعد الاختصار:** مش لازم تكتب نوع البيانات (Data Types). ولو الكود سطر واحد، شيل أقواس `{ }` وكلمة `return`. ولو الميثود بتاخد بارامتر واحد بس، شيل أقواس `( )` من عليه.
    
- **سؤال الأداء (سؤال إنترفيو مهم):** اللامبدا مش بتعمل ملف `.class` جديد على الهارد ولا بتزحم الميموري. بتعتمد على تعليمة في الـ JVM اسمها `invokedynamic` عشان تشتغل وقت الـ Runtime، وده بيخليها سريعة جداً.
    
- **قاعدة المتغيرات (Effectively Final):** لو استخدمت متغير (Variable) متعرف بره أقواس اللامبدا، الجافا بتجبرك إن المتغير ده قيمته متتغيرش أبداً في باقي الكود، عشان اللامبدا بتشتغل على نسخة (Copy) منه.