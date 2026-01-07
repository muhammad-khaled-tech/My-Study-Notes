

الـ **Bubble Sort** ده هو "الجد الأكبر" لكل خوارزميات الترتيب. هو أبطأ واحد فيهم، بس فهمه هو "تذكرة الدخول" لعالم الـ Algorithms، وفيه "تريكة" (Optimization) بتخليه ذكي جداً في حالات معينة.

يلا بينا نفصصه بمستوى **ITI** المحترم.

---

## [[Algorithms]]/Sorting/Bubble Sort

### 1. The Hook (المقدمة: تشبيه من الحياة)

ليه سموه Bubble (فقاعة)؟

تخيل كوباية "سفن أب". الفقاعات الكبيرة بتعمل إيه؟ بتطلع لفوق واحدة واحدة لحد ما توصل للسطح.

هو ده بالضبط اللي بيحصل. إحنا بنمسك الرقم الكبير، ونفضل نبدله (Swap) مع اللي جنبه لحد ما "يطوف" ويوصل لآخر الـ Array (مكانه الصح).

في أول لفة، أكبر رقم بيوصل للآخر. في تاني لفة، تاني أكبر رقم بيوصل لقبل الأخير.. وهكذا.

---

### 2. The Deep Dive (الشرح التقني)

المستوى السطحي (What):

هو خوارزمية ترتيب بسيطة بتعتمد على المقارنة والتبديل (Compare and Swap). بيمشي على الـ Array ويقارن كل عنصرين جنب بعض، لو مش مترتبين يبدلهم.

المستوى المتوسط (How):

بيحتاج 2 Nested Loops:

1. **Outer Loop:** 
2. بتعد الـ Passes (اللفات). في كل لفة بنضمن إن عنصر واحد وصل لمكانه الصح في الآخر.
    
3. **Inner Loop:**
4. دي "الخلاط". بتمشي تقارن `arr[j]` مع `arr[j+1]`.
    
    - `arr[j] > arr[j+1]` -> **SWAP**.
        

**المستوى العميق (Why & Optimization):**

- **Time Complexity:** 
- في أسوأ الظروف هو $O(N^2)$، يعني كارثة لو الداتا كبيرة.
    
- **Space Complexity:** 
- هو $O(1)$ لأنه **In-Place** (مش بيحتاج ميموري زيادة، بيبدل في نفس المكان).
    
- **The Optimization (الذكاء):** 
- تخيل إن الـ Array أصلاً مترتبة `1, 2, 3, 4, 5`. الـ Bubble Sort "الغبي" هيلف $N^2$ على الفاضي.
    
    - **الحل:** بنحط `flag` (مؤشر) اسمه `swapped`.
        
    - لو لفينا لفة كاملة والـ `flag` فضل `false` (يعني معملناش ولا `swap`)، يبقى الـ Array مترتبة! نكسر اللوب فوراً. الحركة دي بتحول الـ Best Case لـ $O(N)$.
        

---

### 3. The Obsidian Note

انسخ دي عندك عشان المذاكرة:




# [[Algorithms]]/Sorting/Bubble_Sort

> [!summary] Definition
> A simple sorting algorithm that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order. The pass through the list is repeated until the list is sorted.

## Key Characteristics
- **Time Complexity**: 
    - Worst/Average: $O(N^2)$ (Nested Loops).
    - Best: $O(N)$ (With `swapped` flag optimization).
- **Space Complexity**: $O(1)$ (In-Place).
- **Stability**: **Stable** (Does not change the relative order of equal elements).
- **Adaptive**: Yes (Can exit early if list is sorted).

## Mechanism (The Logic)
1. Iterate from index `0` to `n-1`.
2. Compare `item[j]` with `item[j+1]`.
3. If `item[j] > item[j+1]`, **SWAP**.
4. Repeat until no swaps occur in a full pass.

## Mermaid Flowchart
```mermaid
flowchart TD
    Start([Start Pass]) --> InitFlag[Swapped = False]
    InitFlag --> Loop{End of Array?}
    Loop -- No --> Compare{Arr[j] > Arr[j+1]?}
    Compare -- Yes --> Swap[Swap Elements]
    Swap --> SetFlag[Swapped = True]
    SetFlag --> Next[Next Pair]
    Compare -- No --> Next
    Next --> Loop
    Loop -- Yes --> CheckFlag{Swapped == False?}
    CheckFlag -- Yes --> Finish([Sorted!])
    CheckFlag -- No --> Start


---

### 4. C++ Implementation (Optimized)

ده الكود "البروفيشنال". مش بس بيرتب، ده بيوفر في اللفات (Optimized).

C++

```

```c++
#include <iostream>
#include <vector>
#include <algorithm> // For std::swap

using namespace std;

void bubbleSort(vector<int>& arr) {
    int n = arr.size();
    bool swapped; // The optimization flag

    // Outer Loop: Controls the number of passes
    // We run n-1 passes because the last element sorts itself
    for (int i = 0; i < n - 1; i++) {
        swapped = false; // Reset flag at start of each pass

        // Inner Loop: The actual comparison and swapping
        // Optimization: 'n - i - 1' because the last 'i' elements are already sorted
        for (int j = 0; j < n - i - 1; j++) {
            
            // Compare adjacent elements
            if (arr[j] > arr[j + 1]) {
                // If wrong order, swap them
                swap(arr[j], arr[j + 1]);
                swapped = true; // Mark that a change happened
            }
        }

        // Deep Optimization:
        // If no swaps occurred in this entire pass, the array is fully sorted.
        // Break the loop to save time (O(N) best case).
        if (swapped == false) {
            break;
        }
    }
}

void printArray(const vector<int>& arr) {
    for (int i : arr) {
        cout << i << " ";
    }
    cout << endl;
}

int main() {
    // Test Case: Nearly sorted array to test optimization
    vector<int> data = {64, 34, 25, 12, 22, 11, 90};
    
    cout << "Original: ";
    printArray(data);

    bubbleSort(data);

    cout << "Sorted:   ";
    printArray(data);

    return 0;
}
```

---

### **تمرين سريع (Mental Check):**

في السطر ده:

for (int j = 0; j < n - i - 1; j++)

ليه طرحنا `i`؟ وليه طرحنا `1`؟

- **طرحنا `1`:** عشان إحنا بنقارن `j` مع `j+1`. لو وصلنا لآخر عنصر (`n-1`) وجينا نبص على `j+1` هنقع برة الـ Array.
    
- **طرحنا `i`:** لأن بعد اللفة الأولى، أكبر عنصر بقى في الآخر خلاص. بعد اللفة التانية، آخر عنصرين بقوا في مكانهم. فمش محتاجين نضيع وقت ونقارن معاهم تاني. ده توفير وقت (Micro-optimization).
    

