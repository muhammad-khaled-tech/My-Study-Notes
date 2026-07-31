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
    

Java

```
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

```
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