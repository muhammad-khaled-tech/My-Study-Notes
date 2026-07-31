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
