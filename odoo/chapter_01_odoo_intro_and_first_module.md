# الفصل الأول — Odoo: من الصفر للموديول الأول

> **المتطلبات:** معرفة أساسية بـ Python و XML — هتحتاج تفهم إزاي بيشتغلوا لأن Odoo مبني عليهم بالكامل.

---

## البداية — المشكلة اللي Odoo اتعمل عشان يحلها

تخيّل معايا إنك صاحب شركة متوسطة الحجم. عندك نظام للـ accounting من شركة، ونظام تاني للـ inventory من شركة تانية، وشيت Excel بتعمله بإيدك عشان تربط بينهم. كل أسبوع في migration manual للداتا، في errors، في ناس بتشتغل على أرقام قديمة.

ده اللي كان بيحصل قبل الـ ERP systems. كل department عنده جزيرة منفصلة من البيانات.

> بدل ما يبقى عندك 5 أنظمة منفصلة مش بتكلم بعض — Odoo بتديك نظام واحد متكامل بـ database واحدة وكل الـ modules بتكلم بعضها automatically.

---

## 1. تاريخ Odoo — من tinyERP للعملاق

سنة 2005، Fabien Pinckaers طالب بلجيكي بدأ يبني ERP صغير بالـ Python. سماه **tinyERP** — اسم بيقول كل حاجة: صغير ومش مكمّل. بعدين لما نضج، غير الاسم لـ **OpenERP** عشان يوضح إنه Open Source. وفي 2014 تحول للاسم اللي إحنا عارفينه: **Odoo**.

```
tinyERP (2005)  →  OpenERP (2009)  →  Odoo (2014)
    صغير              مفتوح المصدر        الاسم الحالي
```

ليه مهم تعرف ده؟ عشان هتلاقي في بعض الأماكن في الكود والـ database أسماء قديمة زي `openerp` في paths والـ module names. مش هيبقى غلط — ده تاريخ.

---

## 2. ليه Odoo؟ — الـ Value Proposition

الـ Odoo مش بس ERP — ده platform كامل فيه:

| Module | بيعمل إيه |
|---|---|
| CRM | إدارة العملاء والـ leads |
| Accounting | محاسبة كاملة |
| Inventory | مخازن وتتبع المنتجات |
| HR | رواتب وموظفين |
| E-commerce | متجر إلكتروني |
| Manufacturing | تصنيع ومتابعة إنتاج |

بس اللي بيخليه مميز عن الـ SAP مثلاً إنه:

- **Open Source**: تقدر تعدل في أي حاجة
- **Easy to extend**: تكتب موديول بـ Python وبيتكامل مع كل حاجة تانية
- **مناسب لـ SMEs**: مش محتاج ميزانية enterprise

> ⚠️ **انتبه:** في نسختين — Community (مجانية open source) وEnterprise (مدفوعة بـ features زيادة). الفرق بيبقى واضح في الـ Kanban views والـ reporting المتقدم.

---

## 3. الـ Odoo Eco-System — مين بيشتغل مع مين

تخيّل معايا إن Odoo زي مطعم كبير:

- **Python** = الطباخ الأساسي — كل الـ business logic بتتكتب بيه
- **PostgreSQL** = المخزن — كل البيانات محفوظة فيه
- **XML / HTML** = منيو الطلبات — بيحدد اللي بيظهر للمستخدم
- **WSGI Server** = الـ reception — بياخد الـ requests وبيوجهها صح
- **Node modules** = الـ waiters — بيتعاملوا مع الـ JavaScript والـ frontend

```
Browser / User
      |
      | HTTP Request
      v
  WSGI Server (Werkzeug)
      |
      v
  Python (Odoo Framework)
      |           |
      v           v
  PostgreSQL    XML Views
  (Data)        (UI)
```

اللي بيحصل هنا إن لما المستخدم يفتح صفحة، الـ WSGI server بياخد الـ request، الـ Python بيجيب البيانات من PostgreSQL، ويحولها لـ XML view بيتحول لـ HTML في الـ browser.

---

## 4. الـ Odoo Configuration — ملف الـ Settings

قبل ما تبدأ، Odoo محتاجة تعرف فين كل حاجة. الـ configuration file هو `.conf` بتاعك:

```ini
[options]
# Path where Odoo looks for addons/modules
addons_path = /path/to/odoo/addons,/path/to/your/custom/addons

# Master password to manage databases from the UI
admin_passwd = admin

# PostgreSQL connection settings
db_host = localhost
db_port = 5432
db_user = odoo
db_password = odoo_password

# Which database to use (False = show all)
db_name = False

# Filter databases shown in the UI using regex
dbfilter = myproject.*

# The port Odoo listens on
http_port = 8069
```

> **نصيحة الخبراء:** الـ `addons_path` هي أهم config key. عندك مسارين دايمًا: مسار الـ addons الأساسية بتاعة Odoo، ومسار الـ custom addons بتاعتك. **متخليشهم في نفس الفولدر أبدًا** — لما تعمل update هيتمسح كودك.

```ini
# Good practice — separate paths with comma
addons_path = /odoo/addons,/my_project/custom_addons
#              ^base addons  ^your custom addons
```

---

## 5. Create Your First Module — هيكل الموديول

الـ module في Odoo هو folder عادي بس بشروط. بالظبط زي الـ package في Python — محتاج ملفين أساسيين:

```
custom_addons/
└── my_module/
    ├── __init__.py        ← makes it a Python package
    └── __manifest__.py    ← tells Odoo what this module is
```

### 5.1 الـ __manifest__.py — بطاقة التعريف

الـ manifest هو أول حاجة Odoo بتقراها. لو مش موجود — الموديول مش موجود.

```python
{
    # Module display name in the UI
    'name': 'Hospital Management System',

    # Short description shown in the module list
    'summary': 'Manage patients, doctors and departments',

    # Long description (supports RST markup)
    'description': """
        HMS Module
        ==========
        A complete hospital management system built on Odoo 18.
    """,

    'author': 'My Company',
    'website': 'https://www.mycompany.com',

    # Category used for filtering in the Apps menu
    'category': 'Healthcare',

    # Version follows the pattern: odoo_version.module_version
    'version': '18.0.1.0.0',

    # List of modules this module depends on
    # 'base' is always implicitly there, but 'mail' adds chatter, 'hr' adds HR features
    'depends': ['base'],

    # Files to load when installing/upgrading — ORDER MATTERS
    'data': [
        'security/ir.model.access.csv',   # access rights must come first
        'views/patient_views.xml',         # then views
    ],

    # Set to False to hide from the main Apps page
    'application': True,

    # If True, module is installed automatically
    'installable': True,
}
```

> ⚠️ **انتبه:** الـ `data` list بتتقرأ **بالترتيب**. لو حطيت الـ view قبل الـ security file، ممكن تلاقي access errors لأن الـ model مش متعرفش لسه من ناحية الـ security.

### 5.2 خطوات تفعيل الموديول

اللي بيحصل هنا مش سحر:

```
1. Add custom path to addons_path in .conf file
         ↓
2. Restart Odoo server
         ↓
3. Activate Developer Mode (Settings > About > Activate Developer Mode)
         ↓
4. Apps > Update Apps List
         ↓
5. Search for your module and Install it
```

لما Odoo بـ install الموديول، بيقرأ الـ manifest، بيعمل الـ database tables من الـ models، وبيحمّل الـ XML files في الـ database.

---

## 6. Database Models — إزاي بتعمل جدول في الـ database

ده القلب. كل موديول بيضيف حاجة للـ database عن طريق الـ models.

### 6.1 هيكل الـ models folder

```
my_module/
├── __init__.py
├── __manifest__.py
└── models/
    ├── __init__.py        ← imports all model files
    └── patient.py         ← your actual model
```

الـ `models/__init__.py` لازم يعمل import لكل ملف موديل:

```python
# models/__init__.py
from . import patient  # this tells Python to load patient.py
```

والـ module الرئيسي `__init__.py` لازم يعمل import للـ models folder:

```python
# my_module/__init__.py
from . import models  # this loads the whole models/ folder
```

### 6.2 كتابة الـ Model

```python
# models/patient.py
from odoo import models, fields

class HmsPatient(models.Model):
    # This becomes the database table name: hms_patient
    # And the technical name used everywhere in Odoo
    _name = 'hms.patient'

    # Human-readable name shown in menus and logs
    _description = 'Hospital Patient'

    # ---- Basic Fields ----
    first_name = fields.Char(required=True)           # VARCHAR in DB
    last_name = fields.Char(required=True)            # VARCHAR in DB
    age = fields.Integer()                             # INTEGER in DB
    salary = fields.Float()                            # NUMERIC in DB
    history = fields.Html()                            # TEXT in DB (rich text)
    address = fields.Text()                            # TEXT in DB (plain text)

    # Selection field = ENUM-like, stored as VARCHAR
    # Format: [('stored_value', 'Display Label')]
    gender = fields.Selection([
        ('male', 'Male'),
        ('female', 'Female'),
    ], default='male')

    blood_type = fields.Selection([
        ('A+', 'A+'), ('A-', 'A-'),
        ('B+', 'B+'), ('B-', 'B-'),
        ('O+', 'O+'), ('O-', 'O-'),
        ('AB+', 'AB+'), ('AB-', 'AB-'),
    ])

    # Boolean = checkbox in form view
    is_accepted = fields.Boolean(default=False)
    pcr = fields.Boolean()

    cr_ratio = fields.Float(string='CR Ratio')  # 'string' = label in UI

    # Date and DateTime fields
    birth_date = fields.Date()
    interview_time = fields.Datetime()

    # Binary field for images
    image = fields.Binary()                            # stored as bytea in DB
```

> ⚠️ **انتبه:** الـ `_name` بيستخدم نقط (dots) زي `hms.patient`، بس في الـ database بيتخزن بـ underscore: جدول اسمه `hms_patient`. ده مش غلط — ده سلوك Odoo الأصلي.

لاحظ إن كل field بيتحول لـ column في الـ database تلقائيًا لما تعمل install أو upgrade للموديول.

---

## 7. Menus and Actions — إزاي بتعمل قايمة في الـ UI

ده الجزء اللي بيربط الـ model بالـ interface. الـ user مش بيشوف Python — بيشوف menus وbuttons.

### 7.1 هيكل الـ views folder

```
my_module/
├── models/
└── views/
    └── patient_views.xml   ← menu + action + views all here
```

لازم تضيف الـ XML file في الـ manifest:

```python
# In __manifest__.py
'data': [
    'views/patient_views.xml',
],
```

### 7.2 الـ Action — الجسر بين الـ menu والـ model

الـ action هو اللي بيحدد "لما حد يضغط على الـ menu ده، افتح الـ model ده":

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <!-- Action: defines what happens when menu item is clicked -->
        <!-- model="ir.actions.act_window" = open a window/view -->
        <record id="action_hms_patients" model="ir.actions.act_window">
            <!-- Name shown in the window title bar -->
            <field name="name">Patients</field>

            <!-- Which model's data to show -->
            <field name="res_model">hms.patient</field>

            <!-- Which views to offer — order matters for default view -->
            <!-- In Odoo 18, 'list' is the new name for 'tree' -->
            <field name="view_mode">list,form</field>
        </record>

        <!-- Level 1: Top-level menu (appears in the main navbar) -->
        <!-- No parent = root menu item -->
        <menuitem
            id="menu_hms_root"
            name="HMS"
            sequence="10"/>

        <!-- Level 2: Sub-menu under HMS -->
        <menuitem
            id="menu_hms_data"
            name="Data"
            parent="menu_hms_root"
            sequence="10"/>

        <!-- Level 3: Clickable item that triggers the action -->
        <menuitem
            id="menu_hms_patients"
            name="Patients"
            parent="menu_hms_data"
            action="action_hms_patients"
            sequence="10"/>

    </data>
</odoo>
```

اللي بيحصل هنا خطوة خطوة:

```
User clicks "Patients" menu
         ↓
Odoo finds the menuitem record in ir.ui.menu table
         ↓
menuitem has action="action_hms_patients"
         ↓
Odoo finds the action record in ir.actions.act_window table
         ↓
Action says: res_model=hms.patient, view_mode=list,form
         ↓
Odoo loads the list view for hms.patient model
         ↓
User sees the patient records in a table
```

> **نصيحة الخبراء:** الـ Golden Rule في Odoo: **Everything is a record**. الـ menus، الـ actions، الـ views — كلهم records في جداول في الـ database. لما بتكتب XML، أنت مش بتكتب UI — أنت بتعمل insert لـ records في جداول زي `ir.ui.menu`، `ir.actions.act_window`، `ir.ui.view`.

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه الفرق بين `__init__.py` و `__manifest__.py` في الـ Odoo module؟**
> الـ `__init__.py` هو ملف Python عادي بيخلي الـ folder يتعامل معاه كـ Python package ويعمل import للـ sub-modules. الـ `__manifest__.py` هو ملف Odoo خاص بيحتوي على dictionary بيوصف الموديول: اسمه، اعتمادياته، الـ data files، إلخ. من غير الـ manifest، Odoo مش بتعرف إن ده موديول.

**س: امتى بتحتاج تعمل restart للـ server في Odoo؟**
> لما تعمل تغيير في Python code (models, controllers) لازم restart. أما لو التغيير في XML files بس، تقدر تستخدم `--dev xml` flag وتعمل refresh للـ page من غير restart. ده بيوفر وقت كتير في الـ development.

**س: إيه اللي بيحصل في الـ database لما تعمل install لـ Odoo module؟**
> Odoo بيقرأ الـ manifest، بيعمل الـ database tables من الـ Python models (كل `fields.X` بيتحول لـ column)، وبيحمّل الـ XML files كـ records في جداول زي `ir.ui.view` و `ir.ui.menu` و `ir.actions.act_window`. يعني الـ UI نفسه محفوظ في الـ database مش في ملفات static.

**س: إيه الـ naming convention الصح لـ Odoo models؟**
> الـ `_name` بيستخدم **نقط** عشان يفصل الـ module name عن الـ model name: `hms.patient`. الـ Odoo تلقائيًا بيحوله لاسم الجدول بالـ underscore: `hms_patient`. الـ convention المعروف إنك تبدأ بـ module name عشان تتجنب conflicts.

**س: ليه الـ `data` list في الـ manifest الترتيب فيها مهم؟**
> عشان الـ files بتتقرأ بالتسلسل. لو عندك view بيشير لـ security group ومعرفتهاش الأول، هيجيك error. القاعدة: security files أول، بعدين data files، بعدين views.

---

## 🛠️ Practical Exercise — HMS Lab 01

### Task 1 — انشئ الـ module structure

```bash
# Create the folder structure
mkdir -p custom_addons/hms/models
mkdir -p custom_addons/hms/views
mkdir -p custom_addons/hms/security

# Create empty init files
touch custom_addons/hms/__init__.py
touch custom_addons/hms/models/__init__.py
```

### Task 2 — اكتب الـ manifest والـ Patient model

اعمل `__manifest__.py` للـ `hms` module وخليه يـ depend على `base`.

اكتب الـ `hms.patient` model بالـ fields دي:

| Field | Type | Notes |
|---|---|---|
| `first_name` | Char | required |
| `last_name` | Char | required |
| `birth_date` | Date | |
| `history` | Html | |
| `cr_ratio` | Float | |
| `blood_type` | Selection | A+, A-, B+, B-, O+, O-, AB+, AB- |
| `pcr` | Boolean | |
| `image` | Binary | |
| `address` | Text | |
| `age` | Integer | |

### Task 3 — اعمل الـ menus والـ action

في الـ views file، اعمل:
- Action بيفتح `hms.patient` بـ `list,form` mode
- Root menu اسمه `HMS`
- Sub-menu اسمه `Patients`

| الملف | السؤال |
|---|---|
| `__manifest__.py` | هل ضفت الـ views file في الـ data list؟ |
| `models/patient.py` | هل الـ `_name` بيستخدم نقط مش underscore؟ |
| `views/patient_views.xml` | هل الـ `menuitem` الأخير عنده `action` attribute؟ |

---

## 🫒 زتونة الإنترفيو

> **"Odoo هو ERP framework مبني على Python وPostgreSQL، الـ architecture بتاعته قايمة على إن everything is a record — حتى الـ views والـ menus نفسهم محفوظين في الـ database مش في static files. لما بتعمل موديول، بتعمل Python classes بترث من `models.Model`، كل field بيتحول تلقائياً لـ column في الـ database. الـ UI بتتعمل عن طريق XML files بتتحمل كـ records في جداول زي `ir.ui.view` و `ir.ui.menu`. الـ manifest هو بطاقة تعريف الموديول، والـ addons_path هو اللي بيقول لـ Odoo فين يدور على الموديولات دي."**

---

*Next → الفصل الثاني — Odoo Views في العمق: إزاي الـ XML بيتحول لصفحة كاملة قدامك*
