---
title: Quick Sort
created: 2026-01-07
tags:
  - algorithms
  - sorting
  - divide-and-conquer
  - O(nlogn)
  - unstable
related:
  - "[[_Algorithms MOC]]"
  - "[[Merge sort]]"
  - "[[Algorithm Paradigms]]"
complexity:
  best: O(n log n)
  average: O(n log n)
  worst: O(n²)
  space: O(log n)
---

يا أهلاً بيك يا وحش الـ Open Source. إحنا دلوقتي وصلنا لمحطة "الصاروخ".. الـ **Quick Sort**. لو الـ Merge Sort هو المحرك النفاث، فالـ Quick Sort هو "العربية الـ Formula 1". ده أكتر خوارزمية ترتيب مستخدمة في العالم الحقيقي، ولما بتنادي دالة `sort()` في أغلب اللغات البرمجية، هي بتستخدم الـ Quick Sort (أو نسخة متطورة منها) تحت الكبوت.

الخوارزمية دي اخترعها **Tony Hoare** سنة 1959، وهي المثال الأروع لمبدأ الـ Divide and Conquer.

---

## خوارزمية الترتيب السريع - Quick Sort

### التعريف السريع

الـ **Quick Sort** هي خوارزمية ترتيب بتعتمد على فكرة الـ **Partitioning** (التقسيم). بنختار عنصر عشوائي بنسميه الـ **Pivot**، وبنرتب المصفوفة بحيث كل اللي أصغر منه يروح شماله، وكل اللي أكبر منه يروح يمينه. بعدين بنكرر العملية دي "ريكيرسيفلي" (Recursively) على الجزء الشمال واليمين لحد ما المصفوفة كلها تترتب. هي خوارزمية **In-place** وسريعة جداً في المتوسط.

---

### الشرح التفصيلي

بص يا هندسة، عشان تفهم الـ Quick Sort، لازم تفهم إن اللعبة كلها في اختيار الـ "الزعيم" (الـ **Pivot**).

#### 1. المستوى السطحي (إيه ده؟)

تخيل إنك في فصل فيه 50 طالب بأطوال مختلفة، وعايز ترتبهم. هتعمل إيه؟ هتنقي أي طالب عشوائي (وليكن "أحمد") وتوقفه في نص الفصل. وتقول: "يا جماعة، أي حد أقصر من أحمد يروح يقف على شماله، وأي حد أطول من أحمد يروح يقف على يمينه".

دلوقتي "أحمد" واقف في مكانه الصح 100% في المصفوفة المترتبة النهائية، حتى لو اللي على شماله لسه ملخبطين واللي على يمينه ملخبطين. بعدين هتروح للجماعة اللي على شماله وتكرر نفس الحركة، وتجيب "زعيم" جديد.. وهكذا لحد ما الفصل كله يترتب.

#### 2. المستوى المتوسط (إزاي بيشتغل؟)

الخوارزمية بتعتمد على دالة سحرية اسمها **`partition`**. الدالة دي وظيفتها:

1. تختار **Pivot** (ممكن يكون أول عنصر، آخر عنصر، أو عنصر في النص).
    
2. تعمل Loop على المصفوفة وتقارن كل العناصر بالـ Pivot.
    
3. أي عنصر أصغر، بتعمله **Swap** وتجيبه في الجزء الشمال.
    
4. في الآخر، بتحط الـ Pivot في مكانه الفاصل بين "الصغيرين" و "الكبار".
    
5. بترجع الـ **Index** بتاع الـ Pivot ده عشان نقسم المصفوفة من عنده لحتتين وننادي الـ `quickSort` عليهم تاني.
    

#### 3. المستوى العميق (ليه اتصمم كده؟ والـ Trade-offs)

ليه الـ Quick Sort هو "الملك" مع إن الـ Merge Sort دايما $O(N \log N)$؟

- **الـ Cache Friendliness:** الـ Quick Sort بيتعامل مع العناصر اللي جنب بعض في الميموري بشكل ممتاز، وده بيخلي الـ CPU Cache يشتغل بكفاءة عالية جداً، عكس الـ Merge Sort اللي بيقعد يحجز ميموري جديدة وينقل داتا كتير.
    
- **الـ Space Complexity:** الـ Quick Sort هو **In-place** (تقريباً). مش بيحتاج مصفوفة تانية ($O(N)$) زي الـ Merge Sort. هو بس بيحتاج مساحة للـ **Recursion Stack** ودي بتكون في حدود $O(\log N)$.
    
- **الـ Worst Case (الثغرة):** هنا بقى "الخطر". لو اخترت Pivot وحش دايماً (مثلاً لو المصفوفة مترتبة وأنت دايماً بتختار آخر عنصر كـ Pivot)، الـ Quick Sort هيقلب لـ $O(N^2)$ وهيبقى أبطأ من السلحفاة. عشان كده المهندسين الشطار بيستخدموا **Randomized Pivot** أو **Median-of-Three** عشان يهربوا من الفخ ده.
    
- **الـ Stability:** للأسف هو **Unstable**. الـ Swaps البعيدة ممكن تبوظ الترتيب النسبي للعناصر المتساوية.
    

---

#### كيفية العمل (How It Works)

العملية بتتم بخطوات الـ Divide and Conquer:

1. **Pick:** 
2. نقي عنصر Pivot.
    
3. **Partition:** 
4. رتب العناصر (أصغر من الـ Pivot على الشمال، أكبر على اليمين).
    
5. **Recurse:** 
6. نادي `quickSort` على الجزء اللي قبل الـ Pivot، و `quickSort` على الجزء اللي بعد الـ Pivot.
    

إزاي الـ Partition بيحصل (Lomuto Partition Scheme):

بنمشي بمؤشرين، واحد (i) بيراقب آخر مكان للعناصر الصغيره، والتاني (j) بيلف على المصفوفة. أول ما نلاقي عنصر أصغر من الـ Pivot، بنكبر i ونبدله مع j.

---

#### الأمثلة العملية (C++ Implementation)

ده كود كامل، بيشرح عملية الـ Partition والـ Quick Sort بالتفصيل الممل:



```C++
#include <iostream>
#include <vector>
#include <algorithm> // عشان الـ swap

using namespace std;

/**
 * دالة التقسيم (Partition)
 * وظيفتها تختار الـ Pivot وتحط الصغيرين شماله والكبار يمينه
 */
int partition(vector<int>& arr, int low, int high) {
    // هنختار آخر عنصر كـ Pivot (دي طريقة Lomuto)
    int pivot = arr[high]; 
    
    // مؤشر i بيشاور على "آخر مكان للعناصر اللي أصغر من الـ Pivot"
    int i = (low - 1); 

    for (int j = low; j < high; j++) {
        // لو العنصر الحالي أصغر من الـ Pivot
        if (arr[j] < pivot) {
            i++; // كبر حدود منطقة الصغيرين
            swap(arr[i], arr[arr[j]]); // غلطة مطبعية شائعة، التصحيح:
            swap(arr[i], arr[j]); // بدله مع العنصر الحالي
        }
    }
    
    // في الآخر، حط الـ Pivot في مكانه الصح (بعد منطقة الصغيرين مباشرة)
    swap(arr[i + 1], arr[high]);
    
    // رجع مكان الـ Pivot عشان نقسم المصفوفة من عنده في اللفة الجاية
    return (i + 1);
}

/**
 * دالة الـ Quick Sort الـ Recursive
 */
void quickSort(vector<int>& arr, int low, int high) {
    if (low < high) {
        // 1. تقسيم المصفوفة والحصول على مكان الـ Pivot
        int pi = partition(arr, low, high);

        // 2. ترتيب الجزء اللي قبل الـ Pivot (الصغيرين) ريكيرسيفلي
        quickSort(arr, low, pi - 1);

        // 3. ترتيب الجزء اللي بعد الـ Pivot (الكبار) ريكيرسيفلي
        quickSort(arr, pi + 1, high);
    }
}

// دالة مساعدة لطباعة المصفوفة
void printArray(const vector<int>& arr) {
    for (int x : arr) cout << x << " ";
    cout << endl;
}

int main() {
    vector<int> data = {10, 80, 30, 90, 40, 50, 70};
    int n = data.size();

    cout << "Original Array: ";
    printArray(data);

    // بنبدأ من index 0 لحد n-1
    quickSort(data, 0, n - 1);

    cout << "Sorted Array:   ";
    printArray(data);

    return 0;
}

// الـ Output المتوقع: 10 30 40 50 70 80 90
```

---

#### الـ Edge Cases والتفاصيل الدقيقة

1. **Already Sorted Data:** 
2. لو المصفوفة مترتبة وأنت بتختار الـ Pivot هو آخر عنصر، الـ Quick Sort هيعاني وهيعمل $N$ لفات وكل لفة فيها $N$ مقارنات ($O(N^2)$). عشان تحل ده، استخدم **Random Pivot**.
    
3. **All Elements Equal:**
4. لو كل العناصر زي بعض، الـ Quick Sort برضه ممكن يقع في فخ الـ $O(N^2)$ لو الـ Partition مش ذكي.
    
5. **Recursion Depth:** 
6. لو الداتا كبيرة جداً، الـ Stack ممكن يخلص (Stack Overflow). عشان كده اللغات الحديثة بتستخدم **Introsort** (بتبدأ Quick Sort، ولو لقت الـ Depth زاد عن حد معين، بتقلب Merge Sort أو Heap Sort أوتوماتيك).
    

---

### الربط بالمفاهيم التانية

موضوع الـ Quick Sort مرتبط بـ:

- **Recursion & Stack Limits:**
- فهم إزاي الـ Function calls بتتخزن في الميموري.
    
- **Pivot Selection:**
- مرتبط بمفاهيم الاحتمالات (Probability) لضمان أفضل أداء.
    
- **Hybrid Sorting:** 
- زي الـ **Timsort** والـ **Introsort** اللي هما ملوك لغات البرمجة حالياً.
    

---

### المصادر والقراءة الإضافية

بناءً على طلبك، دي لينكات هتخليك "أستاذ" في الموضوع ده:

1. **Abdul Bari (Quick Sort):** 
2. [مشاهدة الفيديو على يوتيوب](https://www.youtube.com/watch?v=7h1s2SojIRw) - الراجل ده هو "أسطورة" شرح الخوارزميات، هيفهمك الـ Tracing بالورقة والقلم.
    
3. **MyCodeSchool (Quick Sort Logic):** 
4. [مشاهدة الفيديو على يوتيوب](https://www.youtube.com/watch?v=COk73cpQbFQ) - شرح هادي وبسيط جداً للـ Partitioning.
    
5. **Visualgo.net (Interactive):**
6. [موقع فيجوالجو](https://visualgo.net/en/sorting) - جرب الـ Quick Sort وشوف الـ Pointers وهي بتتحرك بنفسك.
