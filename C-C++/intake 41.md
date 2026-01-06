أكيد يا هندسة، ولا يهمك. قمت بإعادة تنسيق الامتحان بالكامل ليكون واضحاً، مرتباً، وسهل القراءة والمذاكرة. حذفت الزوائد (مثل أرقام الصفحات والمصادر) ورتبت الأكواد بشكل سليم.

إليك الامتحان بتنسيق نظيف جداً:

---

# 🎓 C Programming Exam - Intake 41

Time Allowed: 75 min

Instructions: NOT ALLOWED to use Digital tools, Open software, or Browser Tabs.

---

### Q3. What would be the equivalent pointer expression for referring to the array element `a[i][j][k][l]`?

- a) `((((a+i)+j)+k)+l)`
    
- b) `*(*(*(*(a+i)+j)+k)+l)`
    
- c) `(((a+i)+j)+k+l)`
    
- d) `((a+i)+j+k+l)`

✅ **Answer:** **b**

> **الشرح:** للوصول لقيمة داخل مصفوفة متعددة الأبعاد بالـ Pointers، بنستخدم `*` (Dereference) لكل بُعد. `a[i]` تساوي `*(a+i)`، وبالتالي `a[i][j]` تساوي `*(*(a+i)+j)` وهكذا

### Q4. What is the output of the C Program?



```C
int main() {
    float a = 10.0;
    a = (int)a % 3;
    printf("%f", a);
    return 0;
}
```

- a) 0
    
- b) 1
    
- c) 1.000000
    
- d) Compiler Error
    
✅ **Answer:** **c**

> **الشرح:** `(int)10.0` هي 10. باقي قسمة 10 على 3 هو `1`. بما إن المتغير `a` نوعه `float`، الـ 1 هتتخزن كـ `1.0`. الطباعة بـ `%f` بتطلع كسور (افتراضياً 6 أصفار).
### Q5. What is the output of the C program with `#define`?



```C
#define CVV 156
int main() {
    int a = 10;
    a = a * CVV;
    printf("CVW=%d", a);
    return 0;
}
```

- a) 1560
    
- b) 156=1560
    
- c) 156-10
    
- d) CVV=1560
    
- e) CV=10
    

### Q6. Which of the following, when used as the body of method `sum`, will enable that method to compute `1+2+...+n` correctly for any `n>0`?



```C
// return 1+2+...+n
int sum(int n) {
    /* body */
}
```

- **I)** `return n + sum(n-1);`
    
- **II)** `if (n==1) return 1; else return n + sum(n-1);`
    
- **III)** `if (n==1) return 1; else return sum(n) + sum(n-1);`
    

**Options:**

- a) I only
    
- b) II only
    
- c) III only
    
- d) I and II only
    
- e) I, II, and III
    

### Q7. How many bytes of memory will the following code reserve?



```C
#include<stdio.h>
#include<stdlib.h>
int main() {
    int *p;
    p = (int*)malloc(256 * 256);
    if(p == NULL) printf("Allocation failed");
    return 0;
}
```

- a) 65536
    
- b) Allocation Failed
    
- c) Error
    
- d) No Output
    

### Q8. What value does `result(5)` return?



```C
int result(int n) {
    if (n == 1)
        return 2;
    else
        return 2 * result(n - 1);
}
```

- a) 64
    
- b) 32
    
- c) 16
    
- d) 8
    
- e) 2
    

### Q9. If `malloc()` successfully allocates memory it returns the number of bytes it has allocated.

- a) True
    
- b) False
    

### Q10. What is the output of the C Program?



```C
int main() {
    int a = 5, b = 8;
    if(a == 5 || (b = 9)) {
        printf("Gorilla Glass=");
    }
    printf("%d %d", a, b);
    return 0;
}
```

- a) 58
    
- b) 59
    
- c) Gorilla Glass=5 8
    
- d) Gorilla Glass=5 9
    

### Q11. What does `#include <stdio.h>` do in C language?

- a) It includes stdio.h into existing C program.
    
- b) #include increases the size of C program by including the specified file contents like functions, constants etc.
    
- c) #include includes specified file before compilation.
    
- d) All the above
    
- e) a and b
    
- f) a and c
    

### Q12. As the C Programming Language under DOS and UNIX Operating Systems have the same Syntax, we can take the source code written under DOS and execute it under UNIX Environment.

- a) No, C is a platform dependent Language
    
- b) No, the operating system will Prompt with error message
    
- c) Yes, the execution is valid
    
- d) No, this will give an unexpected error
    
- e) Both a and b
    
- f) Both a and d
    

### Q13. In Compile languages it needs 2 steps to translate the source code to native language, while in Interpreted languages it needs only 1 step for this translation.

- a) True
    
- b) False
    

### Q14. If we miss to write the `#include` statement, it will:

- a) Generate a compile error "function should have a prototype"
    
- b) Will compile and work fine
    
- c) Will compile and work in an unexpected way
    
- d) Generate a compile error "missing header file"
    

### Q15. What is the output of the C Program?



```C
int main() {
    int a = 0;
    a = 14 % -5 - 2;
    printf("%d", a);
    return 0;
}
```

- a) 0
    
- b) -4
    
- c) -2
    
- d) 2
    

### Q16. What is the output of C Program?



```C
int main() {
    int k;
    for(printf("FLOWER "); printf("YELLOW "); printf("FRUITS ")) {
        break;
    }
    return 0;
}
```

- a) Compiler error
    
- b) FLOWER FRUITS
    
- c) FLOWER YELLOW
    
- d) FLOWER YELLOW FRUITS
    

### Q17. What is the output of C Program?



```C
int main() {
    int a = 10, b, c;
    b = a++;
    c = ++a;
    printf("%d %d %d", a, b, c);
    return 0;
}
```

- a) 10 11 12
    
- b) 12 10 12
    
- c) 12 11 12
    
- d) 12 12 12
    
**الشرح:**

1. `b = a++`: 
`b` تاخد قيمة `a` القديمة (10)، و `a` تزيد تبقى 11.
    
2. `c = ++a`: `a` تزيد الأول تبقى 12، و `c` تاخد القيمة الجديدة (12). الناتج: a=12, b=10, c=12.
### Q18. What will be the output of the program?



```C
#include<stdio.h>
int main() {
    int a[5] = {5, 1, 15, 20, 25};
    int i, j, m;
    i = ++a[1];
    j = a[1]++;
    m = a[i++];
    printf("%d, %d, %d", i, j, m);
    return 0;
}
```

- a) 2, 1, 15
    
- b) 1, 2, 5
    
- c) 3, 2, 15
    
- d) 2, 3, 20
    

### Q19. What will be the Output of the following Code:



```C
int * GetMin(int ar[5]);

int main () {
    int *ptr;
    int X[5] = {12, 18, -11, -20, 3};
    ptr = GetMin(X);
    printf("%d", *ptr);
    return 0;
}

int * GetMin(int ar[5]) {
    int min, I;
    min = ar[0];
    for(I = 1; I < 10; I++) { // Note: Loop condition seems to go out of bounds in question text
        if(ar[I] < min) {
            min = ar[I];
        }
    }
    return &min;
}
```

- a) -20
    
- b) Function can't return address
    
- c) No value will be printed
    
- d) There is a value that we don't know appear on the screen
    

### Q20. How many times will the following loop be executed?



```C
// ...
ch = 'b';
while (ch >= 'a' && ch <= 'z')
    ch++;
// ...
```

- a) 0
    
- b) 25
    
- c) 26
    
- d) 1
    

### Q21. Consider the following code:



```C
void recur(int i) {
    int j;
    if(i == 0) {
        printf("%d ", i);
    } else {
        for(j = 0; j < 2; j++)
            recur(i - 1);
    }
}
```

**What is printed by the call `recur(1)`?**

- a) 0
    
- b) 00
    
- c) 000...infinitely
    
- d) 01
    
- e) None of the above
    

### Q22. The output of this program is:



```C
void e(int);
void main() {
    int a;
    a = 4;
    e(a);
}
void e(int n) {
    if(n > 0) {
        e(--n);
        printf("%d", n);
        e(--n);
    }
}
```

- a) 0120201
    
- b) 0121301
    
- c) 0120301
    
- d) 0211301
    

### Q23. Which of the above functions will cause a problem?



```C
int *f1(void) {
    int x = 10;
    return(&x);
}

int *f2(void) {
    int *ptr;
    *ptr = 10;
    return ptr;
}

int *f3(void) {
    int *ptr;
    ptr = (int*) malloc(sizeof(int));
    return ptr;
}
```

- a) f1 only
    
- b) f2 only
    
- c) f3 only
    
- d) f1 & f2 only
    
- e) f2 & f3 only
    
- f) f1 & f3 only
    
- g) f1, f2 & f3
    

### Q24. What will be the output of the following program?



```C
#include<stdio.h>
int main() {
    char str[20] = "Hello";
    char *p = str;
    *p = 'M';
    printf("%s\n", str);
    return 0;
}
```

- a) Mello
    
- b) Hello
    
- c) HMello
    
- d) MHello
    

### Q25. What will be the output?



```C
int Sum(int ar[], int size) {
    int j, s = 0;
    for(j = 0; j < size; j++) {
        s += ar[j];
    }
    return s;
}

void main() {
    int X[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int* ptr;
    int Total;
    ptr = X;
    ptr += 2;
    Total = Sum(ptr, 4); // Note: Assuming Sum takes the pointer
    printf("%d", Total);
}
```

- a) Compile time error
    
- b) 10
    
- c) 18
    
- d) None of the above
    

### Q26. The previous code will:



```C
void main() {
    int ar[10][3];
    int x, y;
    for(x = 0; x < 10; x++); // Note the semicolon here
    {
        for(y = 0; y < 3; y++) {
            ar[x][y] = 0;
        }
    }
}
```

- a) assign zero to all element of array
    
- b) will assign zero to the last row of array
    
- c) will assign zero to a row outside of the array boundary
    
- d) will generate a compile error
    

### Q27. The output of this program will be:

C

```C
int number[5] = {5, 4, 3};
printf("%d", (number[0] + number[5]) / 2);
```

- a) 2
    
- b) 2.5
    
- c) 5
    
- d) None of the above
    

### Q28. What does the following program segment do?



```C
int numb;
do {
    scanf("%d", &numb);
} while (numb < 1 || numb > 10);
```

- a) Reads an integer in the range [1, 10]
    
- b) Reads an integer out of range [1, 10]
    
- c) Reads an integer other than 1 and 10
    
- d) None of the above
    

### Q29. Referring to the sample code below, which statement is correct?



```C
struct Employee {
    int Code;
    char Name[21];
    float Salary;
};
struct Employee Emp;
```

- a) `Emp->Code = 100;`
    
- b) `Emp = 100;`
    
- c) `Emp.Code = 100;`
    
- d) `struct Emp.Code = 100;`
    

### Q30. When Using strcpy, the destination array size must be at least equal to the source array size.

- a) True
    
- b) False
    

---

### **Consider the following segment of code for Questions 31 and 32:**



```C
#include<stdio.h>
#include<stdlib.h>

struct Student {
    char Name[20];
    int Grades[5];
};

struct Student FillStudent() {
    struct Student std;
    int i;
    printf("Enter Student Name: ");
    scanf("%s", std.Name);
    printf("Enter Student Grades: \n");
    for (i = 0; i < 5; i++) {
        printf("Enter Grade of Subject %d:", i + 1);
        scanf("%d", &std.Grades[i]);
    }
    return std;
}

// ... (PrintStudent function omitted for brevity) ...

void main() {
    struct Student **Std;
    int NumClasses;
    int NumStudperClass;
    int cls, stdcls;

    printf("Enter Number of classes in the school");
    scanf("%d", &NumClasses);

    // Allocate array of pointers (rows)
    Std = (struct Student **)malloc(NumClasses * sizeof(struct Student *));

    if (Std) {
        for (cls = 0; cls < NumClasses; cls++) {
            printf("Enter Number of Student in class %d: ", cls + 1);
            scanf("%d", &NumStudperClass);
            // Allocate array of Students for each class
            Std[cls] = (struct Student*)malloc(NumStudperClass * sizeof(struct Student));
        }
    }
    // ...
}
```

### Q31. What is the code segment that should be written to fill all the student data?

- **a)**
    
    
    
    ```C
    for(cls = 0; cls < NumClasses; cls++) {
        for(stdcls = 0; stdcls < NumStudperClass ; stdcls++) {
            Std[cls][stdcls] = FillStudent();
        }
    }
    ```
    
- **b)**
    
    
    
    ```C
    for(cls = 0; cls < NumClasses; cls++) {
        for(stdcls = 0; stdcls < NumStudperClass; stdcls++) {
            *(Std[cls] + stdcls) = FillStudent();
        }
    }
    ```
    
- **c)**
    
    
    
    ```C
    for(cls = 0; cls < NumClasses; cls++) {
        int x;
        x = sizeof(Std[cls]) / sizeof(struct Student); // Problematic line logic-wise for dynamic arrays
        for(stdcls = 0; stdcls < x; stdcls++) {
            *(*(Std + cls) + stdcls) = FillStudent();
        }
    }
    ```
    
- **d)**
    
    
    
    ```C
    for(cls = 0; cls < NumClasses; cls++) {
        for(stdcls = 0; stdcls < NumStudperClass; stdcls++) {
            *(*(Std + cls) + stdcls) = FillStudent();
        }
    }
    ```
    

**Options:**

- a) a
    
- b) b
    
- c) c
    
- d) d
    
- e) a and b only
    
- f) a and d only
    
- **g) a and b and d**
    

### Q32. To change the grade of 4th Subject for 3rd student in the 5th class to 80:

- a) `Std[4][2].Grades[3] = 80;`
    
- b) `Std[4]+2->Grades[3] = 80;`
    
- c) `*(Std+4)[2].Grades[3] = 80;`
    
- d) `*(*(Std+4)+2).Grades[3] = 80;`
    
- e) `(*(Std + 4) + 2)->Grades[3] = 80;`
    
- f) All the above
    
- g) None of the above