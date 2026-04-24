# 🏥 Medical AI Agent Lab — الدليل الشامل
> **ITI | Open Source & Gen-AI Track | Day 2 Lab**
> Mohamed's Personal Study Guide — Egyptian Arabic + English

---

## 🗺️ القصة الكاملة أولاً — Big Picture

تخيّل إنك دكتور في عيادة كبيرة. كل يوم بييجيلك مرضى — كل واحد بيجيب معاه:

- **أعراض مكتوبة** (text symptoms)
- **صورة MRI أو X-ray** (medical image)

ومهمتك:
1. تحلّل الحالة
2. تدي insight آمن (مش تشخيص رسمي!)
3. لو المريض محتاج مستشفى متخصص — تدوّر له
4. تحفظ الحالة في سجل (CSV)

**المشكلة؟** — لو كل كلام المريض فضل في الذاكرة، بعد شوية محادثات الـ context window هتبوظ وهتدفع فلوس tokens كتير.

**الحل؟** — نعمل agent ذكي بـ:
- ✂️ **Trim** — بيمسح الـ ToolMessages المؤقتة اللي ملهاش لازمة
- 📝 **Summarize** — لما الكلام يكتر، بيلخّصه
- 🧠 **Structured Output** — بيرد بـ JSON منظّم مش نص عشوائي
- 👁️ **Multimodal** — بيفهم صور + نص في نفس الوقت
- 🔧 **Tools** — WebSearch + CSV Storage

---

## 📚 Concept 1 — Managing Context (الذاكرة والتكلفة)

### النظري — ليه أصلاً في مشكلة؟

الـ LLM عنده **context window** — عدد tokens محدود بيقدر يشوفه في نفس الوقت.

```
[System Prompt] + [كل الـ Messages] + [Output] <= Context Window Limit
```

كل ما المحادثة تطوّل:
- الـ tokens بتزيد → التكلفة بتزيد 💸
- لو وصلت للـ limit → الـ model بيبدأ ينسى أول المحادثة 🤯

### الحل 1 — Trim Messages (قص الرسايل)

**الفكرة**: ToolMessages هي رسايل مؤقتة — الأداة قالت نتيجتها والـ AI فهمها. بعد كده ملهاش لازمة تفضل في الذاكرة.

```
User: "ابحث عن مستشفى"
  ↓
Agent: [يستدعي WebSearch tool]
  ↓
ToolMessage: "نتيجة البحث: مستشفى X في ميدان كذا..."   ← ده اللي بنمسحه
  ↓
Agent: "وجدت مستشفى X متخصص في..."
```

**مثال بسيط عام:**

```python
from langchain.agents.middleware import before_agent
from langchain.agents import AgentState
from langgraph.runtime import Runtime
from langchain.messages import ToolMessage, RemoveMessage

@before_agent
def trim_tool_messages(state: AgentState, runtime: Runtime) -> dict:
    """قبل ما الـ agent يشتغل، احذف كل الـ ToolMessages"""
    messages = state["messages"]
    tool_msgs = [m for m in messages if isinstance(m, ToolMessage)]
    # RemoveMessage بيقول للـ state: احذف الرسالة دي عن طريق الـ id
    return {"messages": [RemoveMessage(id=m.id) for m in tool_msgs]}
```

> 💡 **الـ `@before_agent` decorator** — بيخلي الـ function دي تتنفذ *قبل* كل مرة الـ agent يعالج رسائله. زي حارس عند الباب بيفلتر الداخلين.

---

### الحل 2 — Summarize Messages (التلخيص التلقائي)

**الفكرة**: لما عدد الـ tokens يعدي حد معين، بدل ما نمسح كل حاجة، نلخّص المحادثة في رسالة واحدة ونفضل بكام رسالة أخيرة.

```
[قديم: 50 رسالة] ← بتتلخص في رسالة واحدة
[جديد: summary + آخر 2 رسايل]
```

**مثال بسيط عام:**

```python
from langchain.agents.middleware import SummarizationMiddleware

# في لحظة إنشاء الـ agent
middleware=[
    SummarizationMiddleware(
        model="gpt-4o-mini",        # مودل التلخيص
        trigger=("tokens", 500),    # لما نوصل 500 token ← لخّص
        keep=("messages", 2)        # احتفظ بآخر 2 رسالة بعد التلخيص
    )
]
```

---

## 📚 Concept 2 — Structured Output (الرد المنظّم)

### النظري

الـ LLM بطبعه بيرد بـ **free text** — يعني نص حر. المشكلة إن لو إنت عايز تعالج الرد برمجياً (تحفظه في DB، تعرضه في UI، تعمله validation)، النص الحر صعب.

**الحل**: تحدد **Schema** بـ Pydantic وتقول للـ model "ارد بس بالشكل ده".

### مثال بسيط عام

```python
from pydantic import BaseModel

class MovieReview(BaseModel):
    title: str
    rating: int          # من 1 لـ 10
    summary: str
    recommended: bool

# بعدين في الـ agent:
agent = create_agent(
    model="gpt-4o-mini",
    response_format=MovieReview  # ← هنا البيت
)

res = agent.invoke(...)
# بدل ما تعمل parsing يدوي:
print(res["structured_response"].rating)  # ← مباشر!
print(res["structured_response"].recommended)
```

---

## 📚 Concept 3 — Multimodal Inputs (صور + نص)

### النظري

الـ `gpt-4o-mini` مش بس بيقرأ نص — بيشوف صور كمان. ده اللي بيتسمى **Vision Model**.

بترسمله الصورة على شكل **base64** — ده تحويل الصورة لسلسلة نصية طويلة.

```
صورة JPG/PNG → bytes → base64 string → API
```

### مثال بسيط عام

```python
import base64

# 1. اقرأ الصورة وحوّلها لـ base64
with open("xray.jpg", "rb") as f:
    img_b64 = base64.b64encode(f.read()).decode("utf-8")

# 2. ابعتها ضمن الـ HumanMessage كـ content list
from langchain.messages import HumanMessage

msg = HumanMessage(content=[
    {
        "type": "text",
        "text": "ما رأيك في هذه الصورة الطبية؟"
    },
    {
        "type": "image",
        "base64": img_b64,
        "mime_type": "image/jpeg"   # أو "image/png"
    }
])
```

> 💡 **content** هنا بقى **list** مش string — لأن فيه أكتر من نوع محتوى.

---

## 📚 Concept 4 — Tools (الأدوات)

### النظري

الـ Tools هي "أيادي" الـ agent. الـ model بيقرر *هو* امتى يستخدمها بناءً على السياق.

```
User: "ابحث عن أقرب مستشفى أعصاب في القاهرة"
  ↓
Agent: [يقرر إن السؤال ده يحتاج WebSearch]
  ↓
[ينادي WebSearch("neurology hospital", "Cairo")]
  ↓
[يستلم النتيجة ويصيغها للمستخدم]
```

**بيعرف يستخدمها إزاي؟** — عن طريق الـ **docstring** (التوثيق) اللي بتكتبه جوا الـ function. ده اللي بيوصف للـ model وظيفة الـ tool.

```python
from langchain.tools import tool

@tool
def my_tool(query: str) -> str:
    """هنا بتشرح للـ model إيه اللي بتعمله الأداة دي"""
    # الكود الفعلي
    return result
```

---

## 🔨 اللاب الكامل — Step by Step

> **ملاحظة مهمة**: الـ API اللي معاك بيشتغل زي OpenAI API تماماً.
> المودل المناسب للـ multimodal هو `gpt-4o-mini` (موجود في الـ list).
> متنساش تحط `OPENAI_API_KEY` و `OPENAI_API_BASE` في الـ `.env`.

---

### الخطوة 0 — `.env` Setup

```
# .env
OPENAI_API_KEY=your_key_here
OPENAI_API_BASE=your_api_link_here
TAVILY_API_KEY=your_tavily_key_here
```

```python
# Cell 0 — Load env
from dotenv import load_dotenv
load_dotenv()
```

---

### الخطوة 1 — Pydantic Model للـ Structured Output

```python
# Cell 1 — Structured Output Schema
from pydantic import BaseModel
from typing import Optional

class CaseSummary(BaseModel):
    patient_symptoms: str
    medical_insights: str
    recommended_specialist: str
    urgency_level: str          # Low / Medium / High
    disclaimer: str = "This is not a medical diagnosis. Consult a doctor."
```

**ليه كده؟**
- `patient_symptoms` — ملخص الأعراض اللي ذكرها المريض
- `medical_insights` — ملاحظات طبية آمنة (مش diagnosis)
- `recommended_specialist` — نوع الدكتور المناسب
- `urgency_level` — مستوى الإلحاح
- `disclaimer` — مطلوب في الـ assignment، وبتحمي نفسك قانونياً 😄

---

### الخطوة 2 — WebSearch Tool

```python
# Cell 2 — Web Search Tool
from tavily import TavilyClient
from langchain.tools import tool

tavily_client = TavilyClient()

@tool
def web_search(diagnosis: str, location: str) -> str:
    """
    Search for the nearest hospital based on the patient's diagnosis and location.
    Use this tool ONLY when the user explicitly asks for nearby hospitals.
    """
    query = f"nearest hospital for {diagnosis} near {location}"
    response = tavily_client.search(query)
    return str(response)
```

---

### الخطوة 3 — CSV Storage Tool

```python
# Cell 3 — CSV Storage Tool
import csv
import os
from datetime import datetime
from langchain.tools import tool

@tool
def save_case_to_csv(
    patient_name: str,
    symptoms: str,
    insights: str,
    specialist: str,
    urgency_level: str,
    location: str = "Not provided"
) -> str:
    """
    Save a structured patient case summary to a CSV file for record keeping.
    Use this tool after completing the analysis of a patient's case.
    """
    filename = "patient_cases.csv"
    file_exists = os.path.exists(filename)

    with open(filename, "a", newline="", encoding="utf-8") as f:
        fieldnames = [
            "timestamp", "patient_name", "symptoms",
            "insights", "specialist", "urgency_level", "location"
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)

        if not file_exists:
            writer.writeheader()  # اكتب الـ headers لو الملف جديد

        writer.writerow({
            "timestamp": datetime.now().isoformat(),
            "patient_name": patient_name,
            "symptoms": symptoms,
            "insights": insights,
            "specialist": specialist,
            "urgency_level": urgency_level,
            "location": location
        })

    return f"✅ Case for '{patient_name}' saved successfully to {filename}."
```

---

### الخطوة 4 — Middleware (Trim + Summarize)

```python
# Cell 4 — Message Trimming Middleware
from langchain.agents.middleware import before_agent
from langchain.agents import AgentState
from langgraph.runtime import Runtime
from langchain.messages import ToolMessage, RemoveMessage
from langchain.agents.middleware import SummarizationMiddleware

@before_agent
def trim_tool_messages(state: AgentState, runtime: Runtime) -> dict:
    """
    بتشتغل قبل كل run للـ agent.
    بتحذف كل الـ ToolMessages عشان توفر context space.
    """
    messages = state["messages"]
    tool_msgs = [m for m in messages if isinstance(m, ToolMessage)]
    return {"messages": [RemoveMessage(id=m.id) for m in tool_msgs]}
```

---

### الخطوة 5 — System Prompt

```python
# Cell 5 — Medical System Prompt
medical_prompt = """
You are a Medical AI Assistant Agent that helps patients understand their health concerns.

Your capabilities:
- Analyze text symptoms and medical images (MRI, X-rays, lab results)
- Provide safe, general medical insights
- Search for nearby hospitals when requested
- Save structured case summaries to a CSV file

Rules you MUST follow:
1. NEVER provide a definitive diagnosis or prescribe medications.
2. ALWAYS end your response with: 'This is not a medical diagnosis. Consult a doctor.'
3. Use the 'web_search' tool ONLY when the user explicitly asks for nearby hospitals.
4. Use 'save_case_to_csv' after you have enough information to create a full case summary.
5. Be empathetic, professional, and clear.
6. If an image is provided, describe what you observe and offer general insights.
"""
```

---

### الخطوة 6 — Create the Agent

```python
# Cell 6 — Create Medical Agent
from langchain.agents import create_agent
from langgraph.checkpoint.memory import InMemorySaver

doctor = create_agent(
    model="gpt-4o-mini",           # يدعم Vision (multimodal)
    system_prompt=medical_prompt,
    checkpointer=InMemorySaver(),   # حفظ المحادثة في الذاكرة (non-persistent)
    tools=[web_search, save_case_to_csv],
    response_format=CaseSummary,    # الرد المنظّم
    middleware=[
        trim_tool_messages,         # امسح الـ ToolMessages
        SummarizationMiddleware(    # لخّص لما يكتر الكلام
            model="gpt-4o-mini",
            trigger=("tokens", 500),
            keep=("messages", 2)
        )
    ]
)

print("✅ Doctor agent created successfully!")
```

---

### الخطوة 7 — Test 1: Text Input

```python
# Cell 7 — Text-only input
from langchain.messages import HumanMessage

res = doctor.invoke(
    {
        "messages": [
            HumanMessage(
                content="""
                Patient: Ahmed Hassan, 35 years old.
                Symptoms: Severe headache for 3 days, blurred vision,
                neck stiffness, and fever of 39°C.
                Location: Cairo, Egypt.
                """
            )
        ]
    },
    config={"configurable": {"thread_id": "case_001"}}
)

# عرض الرد كـ raw text
print("=== Raw Response ===")
print(res["messages"][-1].content)

# عرض الـ structured output
print("\n=== Structured Output ===")
structured = res["structured_response"]
print(f"Symptoms: {structured.patient_symptoms}")
print(f"Insights: {structured.medical_insights}")
print(f"Specialist: {structured.recommended_specialist}")
print(f"Urgency: {structured.urgency_level}")
print(f"Disclaimer: {structured.disclaimer}")
```

---

### الخطوة 8 — Test 2: Multimodal Input (صورة + نص)

```python
# Cell 8 — Multimodal: Image + Text
import base64

# لو معندكش صورة حقيقية، استخدم أي صورة طبية من النت
# أو جرب من الـ imgs/ folder اللي في النوتبوك الأصلي

IMAGE_PATH = "imgs/download.jfif"  # نفس مسار اللاب الأصلي

with open(IMAGE_PATH, "rb") as f:
    image_base64 = base64.b64encode(f.read()).decode("utf-8")

res2 = doctor.invoke(
    {
        "messages": [
            HumanMessage(
                content=[
                    {
                        "type": "text",
                        "text": """
                        Patient: Sara Mohamed, 28 years old.
                        Please analyze this medical scan and provide your observations.
                        """
                    },
                    {
                        "type": "image",
                        "base64": image_base64,
                        "mime_type": "image/jpeg"
                    }
                ]
            )
        ]
    },
    config={"configurable": {"thread_id": "case_002"}}
)

print("=== Analysis of Medical Image ===")
print(res2["messages"][-1].content)
```

---

### الخطوة 9 — Test 3: Ask for Hospital (بتفعّل الـ WebSearch Tool)

```python
# Cell 9 — Trigger WebSearch tool
# دي continuation لنفس المحادثة (thread_id: "case_002")

res3 = doctor.invoke(
    {
        "messages": [
            HumanMessage(
                content="Can you find me the nearest neurology hospital in Alexandria, Egypt?"
            )
        ]
    },
    config={"configurable": {"thread_id": "case_002"}}
)

print("=== Hospital Search Results ===")
print(res3["messages"][-1].content)
```

---

### الخطوة 10 — Test 4: Save to CSV (بتفعّل الـ CSV Tool)

```python
# Cell 10 — Trigger CSV save
# لو الـ agent مش حفظ تلقائياً، اطلب منه صراحة

res4 = doctor.invoke(
    {
        "messages": [
            HumanMessage(
                content="Please save the case summary for Sara Mohamed to the records."
            )
        ]
    },
    config={"configurable": {"thread_id": "case_002"}}
)

print("=== CSV Save Result ===")
print(res4["messages"][-1].content)
```

---

### الخطوة 11 — View the CSV

```python
# Cell 11 — Read saved cases
import pandas as pd

try:
    df = pd.read_csv("patient_cases.csv")
    print(f"✅ Total cases saved: {len(df)}")
    print(df.to_string(index=False))
except FileNotFoundError:
    print("⚠️ No cases saved yet. Make sure the CSV tool was triggered.")
```

---

## 🧪 Test 5 — Full Flow من الأول (Bonus)

```python
# Cell 12 — Complete end-to-end test
new_patient_thread = "full_case_test"

# Turn 1: أعراض نصية
turn1 = doctor.invoke({
    "messages": [HumanMessage(content="""
        Patient: Khaled Ibrahim, 52 years old, diabetic.
        Symptoms: Chest pain radiating to the left arm, 
        shortness of breath, sweating. Started 2 hours ago.
        Location: Giza, Egypt.
    """)]},
    config={"configurable": {"thread_id": new_patient_thread}}
)
print("Turn 1:", turn1["messages"][-1].content[:300], "...\n")

# Turn 2: يطلب مستشفى
turn2 = doctor.invoke({
    "messages": [HumanMessage(content="Find me the nearest cardiology hospital in Giza urgently!")]},
    config={"configurable": {"thread_id": new_patient_thread}}
)
print("Turn 2:", turn2["messages"][-1].content[:300], "...\n")

# Turn 3: يطلب حفظ الحالة
turn3 = doctor.invoke({
    "messages": [HumanMessage(content="Save this case to the records please.")]},
    config={"configurable": {"thread_id": new_patient_thread}}
)
print("Turn 3:", turn3["messages"][-1].content)
```

---

## 💬 نقط المناقشة مع المعيد — Talking Points

> دي أسئلة مرجّح يسألها المعيد — كن جاهز ليها.

### سؤال 1: ليه بنستخدم `trim_tool_messages`؟
**الإجابة**: الـ ToolMessages هي نتيجة مؤقتة من الأدوات — الـ AI فهمها واستخدمها وخلاص. لو فضلت في الـ context هتأكل tokens بلاش وتزود التكلفة. الـ trim بيحذفها بعد ما الـ agent يعالجها.

---

### سؤال 2: إيه الفرق بين Trim وSummarize؟
**الإجابة**:
- **Trim** = حذف نوع معين من الرسايل (زي ToolMessages) تلقائياً — جراحة انتقائية ✂️
- **Summarize** = لما الكلام كله يكتر ويعدي الـ trigger، بيعمل ملخص لكل المحادثة ويبدأ من الملخص ده — زي إنك بتكتب ملخص الاجتماع بدل ما تحتفظ بـ recording كامل 📝

---

### سؤال 3: ليه استخدمنا Pydantic مش JSON prompt؟
**الإجابة**: الـ Pydantic بيضمن **type safety** — يعني لو الـ model حاول يرجع `urgency_level` كـ int بدل string، هيطلع validation error. كمان بيديك **IDE autocomplete** ومباشرة تقدر تعمل `res["structured_response"].urgency_level` بدل ما تعمل `json.loads(...)["urgency_level"]`.

---

### سؤال 4: إيه الـ `thread_id` وليه مهم؟
**الإجابة**: الـ `thread_id` هو معرّف المحادثة. كل thread_id مختلف = محادثة مستقلة لها ذاكرة مستقلة. ده بيخلينا نقدر نشتغل مع أكتر من مريض في نفس الوقت — كل مريض عنده thread_id خاص بيه.

---

### سؤال 5: إيه اللي بيقرر الـ agent يستخدم tool ولا لأ؟
**الإجابة**: الـ docstring (التعليق جوا الـ function). الـ model بيقرأه ويقارنه بسؤال المستخدم. لو الـ docstring قال "use this tool ONLY when the user explicitly asks for nearby hospitals" — الـ model بيحترم ده ومش بيستخدمها في كل سؤال. الـ prompt engineering في الـ docstring مهم جداً.

---

### سؤال 6: إيه الفرق بين `InMemorySaver` وـ `PostgresSaver`؟
**الإجابة**:
- **InMemorySaver** = الذاكرة بتتمسح لما البرنامج بيقفل. مناسبة للـ testing والـ debugging.
- **PostgresSaver** = بتحفظ في قاعدة بيانات حقيقية. مناسبة للـ production لما تحتاج المحادثات تفضل بعد restart.

---

## 🫒 الزتونة — Interview Zitona

```
┌─────────────────────────────────────────────────────────┐
│              Medical AI Agent — الخلاصة                 │
├─────────────────────────────────────────────────────────┤
│  create_agent = model + prompt + tools + middleware      │
│                                                         │
│  Middleware Flow (قبل كل run):                          │
│  Messages → trim_tool_msgs → SummarizationMW → Agent   │
│                                                         │
│  Tools:                                                 │
│  • @tool + docstring = الـ LLM يعرف يستخدمها           │
│  • بيقرر هو لوحده امتى يناديها                         │
│                                                         │
│  Multimodal:                                            │
│  • content = LIST مش string                             │
│  • صورة = base64 + mime_type                            │
│                                                         │
│  Structured Output:                                     │
│  • Pydantic BaseModel → response_format                 │
│  • res["structured_response"].field_name               │
│                                                         │
│  Context Optimization:                                  │
│  • Trim = حذف ToolMessages المؤقتة                     │
│  • Summarize = تلخيص عند token limit                   │
└─────────────────────────────────────────────────────────┘
```

---

## ⚠️ Common Mistakes — اللي بتغلط فيه الناس

| الغلطة | الصح |
|--------|------|
| `content="صورة + نص"` في HumanMessage | `content=[{text}, {image}]` — list! |
| ننسى الـ `mime_type` مع الصورة | `"mime_type": "image/jpeg"` دايماً |
| الـ docstring فاضي أو مش واضح | اكتب docstring واضح عشان الـ model يعرف |
| نبعت صورة لـ model مش Vision | استخدم `gpt-4o-mini` مش `davinci-002` |
| نبعت صورة كـ URL مش base64 | بعض الـ wrappers مش بتدعم URL مباشرة — استخدم base64 |
| ننسى الـ `thread_id` في الـ config | بدونه مفيش memory بين الـ turns |

---

## 🔗 الصورة الكاملة — Architecture

```
User Input (text + optional image)
            │
            ▼
    ┌───────────────┐
    │  HumanMessage │ content=[text_block, image_block]
    └───────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │             Middleware Pipeline        │
    │  1. trim_tool_messages                │ ← بيحذف ToolMessages القديمة
    │  2. SummarizationMiddleware           │ ← بيلخّص لو tokens كترت
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │           gpt-4o-mini Agent           │
    │  System Prompt: "You are a doctor..."│
    │  response_format: CaseSummary        │
    └───────┬───────────────────┬──────────┘
            │ maybe calls tool  │
            ▼                   ▼
    ┌───────────────┐   ┌───────────────┐
    │  web_search   │   │save_case_csv  │
    │  (Tavily API) │   │(local CSV)    │
    └───────┬───────┘   └───────┬───────┘
            │                   │
            └─────────┬─────────┘
                      ▼
    ┌───────────────────────────────────────┐
    │         Structured Response           │
    │  CaseSummary:                         │
    │  • patient_symptoms: "..."            │
    │  • medical_insights: "..."            │
    │  • recommended_specialist: "..."      │
    │  • urgency_level: "High"              │
    │  • disclaimer: "Consult a doctor"     │
    └───────────────────────────────────────┘
```

---

*Guide by Claude · ITI Gen-AI Track · April 2026*
