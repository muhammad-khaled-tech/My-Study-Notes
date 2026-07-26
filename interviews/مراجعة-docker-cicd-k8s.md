# مراجعة سريعة: Docker وCI/CD وKubernetes

دليل مختصر، سؤال وجواب، من الأسهل للأصعب. تركيز كبير على Docker، وباقي المواضيع (CI/CD وKubernetes) أشهر الأسئلة بس.

---

## القسم الأول: Docker من الأساس

**Q1 — Docker ايه أصلاً، وإيه الفرق بينه وبين الـ Virtual Machine؟**
Docker أداة بتخليك "تعلّب" تطبيقك مع كل حاجة محتاجها (مكتبات، إعدادات، نسخة اللغة) في وحدة واحدة اسمها **Container**، بحيث تشتغل بنفس الشكل بالظبط على أي جهاز، من غير مشكلة "شغال عندي وموشغلش عندك".
الفرق عن الـ Virtual Machine: الـ VM بتشغّل نظام تشغيل كامل منفصل جوه نظامك (تقيلة، بتاخد دقايق تفتح، وبتاخد جيجات مساحة). الـ Container بتشارك نفس نواة نظام التشغيل (Kernel) بتاعت الجهاز المضيف، وبتعزل بس العمليات والملفات — فبتبقى أخف بكتير (ميجابايتات مش جيجابايتات) وبتفتح في أجزاء من الثانية.

**Q2 — الفرق بين Image وContainer؟**
**Image** هي القالب الثابت (زي الوصفة): ملف مضغوط فيه كل حاجة التطبيق محتاجها (نظام تشغيل مصغر، مكتبات، الكود نفسه). **Container** هي نسخة شغالة فعلياً من الـ Image ده (زي الأكلة المطبوخة من الوصفة). تقدر تشغّل أكتر من Container من نفس الـ Image في نفس الوقت، كل واحد مستقل عن التاني.
```bash
docker images        # يوريك كل الـ Images الموجودة عندك
docker ps             # يوريك الـ Containers الشغالة دلوقتي
docker ps -a           # يوريك كل الـ Containers حتى الواقفة
```

**Q3 — إزاي أكتب Dockerfile بسيط؟**
`Dockerfile` ملف نص بسيط فيه خطوات بناء الـ Image خطوة بخطوة.
```dockerfile
FROM node:20-alpine        # الصورة الأساسية (نظام + Node.js مثبت عليه)
WORKDIR /app                # مجلد الشغل جوه الـ Container
COPY package.json .          # ينسخ ملف واحد بس الأول (لسبب هنشرحه في Q5)
RUN npm install               # يشغّل أمر وقت بناء الـ Image
COPY . .                      # ينسخ باقي ملفات المشروع
CMD ["npm", "start"]           # الأمر اللي يشتغل لما الـ Container يبدأ
```

**Q4 — إزاي أبني وأشغّل Container من الـ Dockerfile؟**
```bash
docker build -t myapp:1.0 .        # يبني Image من الـ Dockerfile في المجلد الحالي
docker run -p 3000:3000 myapp:1.0   # يشغّل Container، ويربط بورت 3000 بره بـ 3000 جوه
docker run -d -p 3000:3000 myapp:1.0  # -d يشغّله في الخلفية (Detached mode)
```
`-p 3000:3000` معناه "أي طلب على بورت 3000 في جهازي، حوّله لبورت 3000 جوه الـ Container".

**Q5 — Layers (الطبقات) في الـ Image بتشتغل إزاي، وليه ترتيب الأوامر في Dockerfile مهم؟**
كل سطر في الـ Dockerfile بيعمل طبقة (Layer) منفصلة، وDocker بيكاش (Cache) كل طبقة عشان لو بنيت الـ Image تاني وملحقتش سطر معين، بيستخدم النسخة المخزنة بدل ما يعيد التنفيذ من الصفر. لو نسخت كل الملفات (`COPY . .`) قبل `npm install`، أي تعديل بسيط في أي ملف هيبطل الكاش ويرجعك تعمل `npm install` من الأول كل مرة، حتى لو `package.json` نفسه ماتغيرش. لو نسخت `package.json` بس الأول وبعدين عملت `npm install`، الكاش هيفضل شغال طالما `package.json` ماتغيرش، وبعدين تنسخ باقي الكود — ده بيوفر وقت بناء كبير جداً.

**Q6 — ملف .dockerignore بيعمل ايه؟**
زي `.gitignore` بالظبط بس لـ Docker: بيمنع ملفات ومجلدات معينة من إنها تتنسخ جوه الـ Image وقت البناء، زي `node_modules`، ملفات `.git`، أو ملفات بيئة العمل الحساسة. ده بيقلل حجم الـ Image وبيسرّع عملية البناء.
```
node_modules
.git
.env
*.log
```

**Q7 — الفرق بين CMD وENTRYPOINT؟**
`CMD` بيحدد الأمر الافتراضي اللي يتنفذ لما الـ Container يبدأ، لكن تقدر تستبدله بسهولة وقت التشغيل (`docker run myapp echo hello` هيشغّل `echo hello` بدل CMD). `ENTRYPOINT` بيحدد أمر ثابت مش سهل تستبدله، وأي حاجة تكتبها بعد اسم الـ Image وقت التشغيل بتتضاف كـ Argument ليه مش تستبدله. غالباً بتستخدمهم مع بعض: `ENTRYPOINT` للأمر الثابت، وCMD كـ Default Arguments قابلة للتغيير.
```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8000"]   # ده الجزء اللي سهل تستبدله وقت التشغيل
```

**Q8 — البيانات جوه Container بتضيع لما الـ Container يتمسح، إزاي أحافظ عليها؟**
Containers بطبيعتها Ephemeral (مؤقتة) — أي بيانات جوه الـ Container نفسه بتضيع لو اتمسح. الحل: **Volumes**، مساحة تخزين بيديرها Docker نفسه، منفصلة عن دورة حياة الـ Container، وبتفضل موجودة حتى لو مسحت الـ Container وعملت واحد جديد.
```bash
docker volume create mydata
docker run -v mydata:/app/data myapp:1.0
# البيانات في /app/data جوه الـ Container هتتخزن فعلياً في mydata، وتفضل موجودة
```

**Q9 — الفرق بين Volumes وBind Mounts؟**
**Volume**: مساحة بيديرها Docker نفسه بالكامل (مكانها الفعلي على الديسك مش لازم تعرفه)، الأنسب للبيانات الدائمة زي قواعد البيانات. **Bind Mount**: بتربط مجلد معين وموجود بالفعل على جهازك مباشرة بمسار جوه الـ Container، مفيد جداً وقت التطوير عشان أي تعديل في الكود على جهازك يظهر فوراً جوه الـ Container من غير إعادة بناء.
```bash
docker run -v $(pwd)/src:/app/src myapp:1.0
# أي تعديل في مجلد src على جهازك هيظهر فوراً جوه الـ Container
```

**Q10 — الشبكات (Networking) في Docker بتشتغل إزاي؟**
كل Container بيتحط افتراضياً على شبكة اسمها `bridge`، وبيقدر يتكلم مع Containers تانية على نفس الشبكة باستخدام اسم الـ Container كـ Hostname. تقدر تعمل شبكة مخصصة عشان تعزل مجموعة Containers معينة عن باقي النظام.
```bash
docker network create mynetwork
docker run --network mynetwork --name db postgres
docker run --network mynetwork --name app myapp
# الـ app يقدر يتكلم مع الـ db باستخدام الاسم "db" كـ hostname مباشرة
```

**Q11 — Docker Compose بيحل ايه، وإزاي شكله؟**
لو مشروعك محتاج أكتر من Container شغالين مع بعض (تطبيق + قاعدة بيانات + Redis مثلاً)، بدل ما تكتب أوامر `docker run` طويلة لكل واحد لوحده، `docker-compose.yml` بيوصف كل الـ Services دي في ملف واحد، وبأمر واحد بيشغّلهم كلهم مع بعض.
```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:
```
```bash
docker compose up -d       # يشغّل كل الـ Services المعرّفة في الملف
docker compose down         # يوقفهم كلهم
```

**Q12 — depends_on في Compose بتضمن ايه بالظبط؟**
بتضمن بس **ترتيب بدء التشغيل** (يبدأ `db` قبل `app`)، لكن **مش بتضمن** إن قاعدة البيانات فعلاً جاهزة تستقبل اتصالات لما الـ `app` يبدأ (ممكن الـ Container يكون شغال بس البروسيس جواه لسه بيبدأ). للتعامل مع ده، التطبيق نفسه لازم يكون فيه منطق إعادة محاولة الاتصال (Retry Logic)، أو تستخدم أداة زي `wait-for-it` تستنى فعلياً لحد ما القاعدة تبقى جاهزة.

**Q13 — إزاي أدخّل متغيرات بيئة (Environment Variables) للـ Container؟**
```bash
docker run -e DATABASE_URL=postgres://localhost/mydb myapp:1.0
```
```yaml
# أو في docker-compose.yml
environment:
  - DATABASE_URL=postgres://db:5432/mydb
  - NODE_ENV=production
```
أو تحط كل المتغيرات في ملف `.env` منفصل، وDocker Compose بيقراه تلقائياً لو موجود في نفس المجلد.

**Q14 — إزاي أدخل جوه Container شغال، أو أشوف الـ Logs بتاعته؟**
```bash
docker exec -it myapp bash     # يفتحلك Terminal جوه الـ Container الشغال
docker logs myapp                # يوريك كل الـ Output اللي الـ Container طبعه
docker logs -f myapp              # يتابع الـ Logs لحظياً (زي tail -f)
docker inspect myapp               # يوريك تفاصيل كاملة عن إعدادات الـ Container
```

**Q15 — إزاي أقلل حجم الـ Image؟**
- استخدم صور أساسية (Base Images) مصغّرة زي `alpine` بدل الصور الكاملة (`node:20-alpine` أصغر بكتير من `node:20`).
- استخدم **Multi-Stage Builds**: تبني المشروع في مرحلة أولى فيها كل أدوات البناء، وبعدين تاخد بس الملفات النهائية الجاهزة لمرحلة تانية أخف، من غير ما تنقل أدوات البناء الزيادة معاها.
```dockerfile
# Stage 1: build
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: production - image نهائي أخف بكتير
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

**Q16 — Health Check في Docker بيعمل ايه؟**
بيخلي Docker يتأكد دورياً إن الـ Container فعلاً شغال وبيرد صح، مش بس إن البروسيس بتاعه شغال. لو الفحص فشل كذا مرة، Docker بيعلّم الـ Container إنه `unhealthy`، وأدوات زي Kubernetes ممكن تستخدم ده عشان تعيد تشغيله تلقائياً.
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1
```

**Q17 — Tagging وPush وPull للـ Images على Docker Hub أو أي Registry؟**
```bash
docker tag myapp:1.0 username/myapp:1.0     # يديه اسم متوافق مع الـ Registry
docker push username/myapp:1.0                # يرفعه على Docker Hub (أو أي Registry تاني)
docker pull username/myapp:1.0                 # ينزّله على أي جهاز تاني
```
التاج (Tag) مهم جداً للتحكم في الإصدارات — استخدم أرقام إصدارات واضحة (`v1.2.0`) بدل الاعتماد على `latest` بس، عشان تعرف بالظبط أنهي نسخة شغالة فين.

**Q18 — أشهر ممارسات الأمان (Security Best Practices) في Docker؟**
- شغّل التطبيق جوه الـ Container بمستخدم عادي مش `root`، عشان لو حد اخترق الـ Container، صلاحياته تبقى محدودة.
```dockerfile
RUN adduser --disabled-password appuser
USER appuser
```
- استخدم صور أساسية رسمية وموثوقة، وحدّثها بانتظام عشان تقفل الثغرات الأمنية المعروفة.
- متحطش أسرار (Passwords, API Keys) مباشرة جوه الـ Dockerfile أو الـ Image، استخدم Environment Variables أو أدوات إدارة أسرار مخصصة بدل كده.

**Q19 — Docker Compose كفاية، ليه محتاج Kubernetes أصلاً؟**
Docker Compose ممتاز لجهاز واحد أو بيئة تطوير محلية، لكن لما تحتاج تشغّل عشرات أو مئات الـ Containers موزعة على أكتر من سيرفر، مع إعادة تشغيل تلقائي لو Container وقع، وتوزيع حمل تلقائي، وتوسع (Scaling) تلقائي حسب الحمل — ده تحدي أكبر بكتير من إمكانيات Compose، وهنا بييجي دور Kubernetes كأداة "تنسيق" (Orchestration) مصممة بالظبط للمشكلة دي، وهنتكلم عنها بعد شوية.

---

## القسم الثاني: CI/CD (أشهر الأسئلة)

**Q20 — CI/CD يعني ايه بشكل عام؟**
**CI (Continuous Integration)**: كل ما مبرمج يعمل Push لكوده، نظام تلقائي بيشغّل الاختبارات (Tests) ويتأكد إن الكود الجديد ماكسرش حاجة، بدل ما تكتشف المشكلة بعد أسابيع. **CD (Continuous Delivery/Deployment)**: بعد نجاح الاختبارات، الكود بينشر تلقائياً (أو بضغطة زر واحدة) لبيئة الإنتاج، من غير خطوات نشر يدوية معقدة.

**Q21 — الفرق بين Continuous Delivery وContinuous Deployment؟**
**Continuous Delivery**: الكود جاهز للنشر في أي وقت بعد نجاح كل الفحوصات، لكن النشر الفعلي لسه محتاج موافقة بشرية (زدة زر). **Continuous Deployment**: كل تغيير عدى الاختبارات بينشر تلقائياً على طول لبيئة الإنتاج من غير أي تدخل بشري خالص.

**Q22 — مراحل الـ Pipeline النموذجية؟**
غالباً: Build (بناء المشروع، أو بناء Docker Image) → Test (تشغيل الاختبارات التلقائية) → Deploy (نشر النسخة الجديدة). أي مرحلة تفشل، الـ Pipeline بيوقف ويبلّغ الفريق، والمرحلة اللي بعدها متتنفذش خالص.

**Q23 — أشهر أدوات CI/CD؟**
GitHub Actions (مدمجة في GitHub، سهلة الإعداد)، GitLab CI (مدمجة في GitLab)، Jenkins (أقدم وأكتر مرونة، لكن محتاج إعداد وصيانة أكبر)، وCircleCI. الاختيار غالباً بيتحدد حسب المنصة اللي كودك متخزن عليها بالفعل.

**Q24 — مثال بسيط لـ Pipeline في GitHub Actions بيبني ويشغّل Docker؟**
```yaml
name: CI/CD Pipeline
on: [push]
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Run tests
        run: docker run myapp:${{ github.sha }} npm test
```

**Q25 — Rolling Deployment وBlue-Green Deployment ايه الفرق بينهم بشكل مختصر؟**
**Rolling Deployment**: بتستبدل النسخ القديمة بالجديدة تدريجياً واحدة واحدة، من غير ما توقف الخدمة خالص، لكن لفترة قصيرة النسخة القديمة والجديدة شغالين مع بعض. **Blue-Green**: بتجهز بيئة كاملة جديدة (Green) جنب القديمة (Blue)، وبعد التأكد إن الجديدة شغالة صح، بتحوّل كل الترافيك ليها دفعة واحدة — لو فيه مشكلة، ترجع للقديمة فوراً.

---

## القسم الثالث: Kubernetes (أشهر الأسئلة)

**Q26 — Kubernetes ايه بشكل مختصر؟**
أداة "تنسيق Containers" (Container Orchestration)، بتدير تشغيل وتوسع وإعادة تشغيل مئات أو آلاف الـ Containers موزعة على مجموعة سيرفرات (Cluster) تلقائياً، بدل ما تديرهم يدوياً واحد واحد زي Docker Compose على جهاز واحد بس.

**Q27 — Pod ايه؟**
أصغر وحدة تشغيل في Kubernetes، بتحتوي عادةً على Container واحد (أو كذا Container مترابطين جداً بيشتغلوا مع بعض دايماً). Kubernetes مش بيدير Containers لوحدها مباشرة، بيديرها من خلال Pods.

**Q28 — Deployment ايه؟**
وصف بتقوله لـ Kubernetes "عايز كذا نسخة (Replica) من الـ Pod ده شغالة دايماً". لو Pod وقع لأي سبب، الـ Deployment بيشغّل واحد بديل تلقائياً عشان العدد المطلوب يفضل ثابت.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: myapp
          image: username/myapp:1.0
```

**Q29 — Service ايه، وليه محتاجه؟**
الـ Pods بتتحرك وتتغير IPs بتاعتها باستمرار (لو اتعمل واحد جديد بدل واقع مثلاً)، فـ Service بيديك عنوان ثابت واحد تقدر تتكلم بيه مع مجموعة Pods من غير ما تعرف IP كل واحد فيهم لوحده، وبيوزع الطلبات بينهم تلقائياً.

**Q30 — ConfigMap وSecret الفرق بينهم؟**
**ConfigMap**: بتخزن إعدادات عادية غير حساسة (زي اسم بيئة التشغيل، أو رابط API عام). **Secret**: بتخزن بيانات حساسة (باسورد، مفاتيح API)، ومشفرة بشكل أساسي (Base64) وبتتعامل معاها Kubernetes بحذر أكبر من ناحية الصلاحيات.

**Q31 — أشهر أوامر kubectl؟**
```bash
kubectl get pods                  # يوريك كل الـ Pods الشغالة
kubectl get deployments            # يوريك كل الـ Deployments
kubectl logs mypod                  # يوريك الـ Logs بتاعة Pod معين
kubectl scale deployment myapp --replicas=5   # يزود عدد النسخ لـ 5
```

---

**الخلاصة في سطرين**: اتقن Docker الأول (Images, Layers, Volumes, Compose) لأنه الأساس اللي كل حاجة تانية مبنية عليه. CI/CD بيوتّمت البناء والاختبار والنشر، وKubernetes بييجي لما تحتاج تدير عدد كبير من الـ Containers دي على أكتر من سيرفر بشكل موثوق وقابل للتوسع.
