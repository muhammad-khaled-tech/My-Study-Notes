# الفصل الثاني — Odoo Views: من الـ XML للشاشة اللي قدامك

> **المتطلبات:** [[الفصل الأول]] — لازم يكون عندك موديول شغال وعارف تعمل model، لأن الـ views مفيهاش معنى من غير model بتشاور عليه.

---

## البداية — ليه XML ومش HTML مباشرة؟

تخيّل معايا إنك بتعمل نظام ERP لـ 500 شركة مختلفة. كل شركة عايزة نفس النموذج بس بـ fields مختلفة، بترتيب مختلف، بصلاحيات مختلفة. لو كتبت HTML ثابت — هتكتب 500 نسخة. الكابوس!

Odoo حلّت المشكلة دي بطريقة ذكية: الـ views مش HTML — دي **descriptions** محفوظة في الـ database، Odoo بتقراها وتحولها لـ HTML ديناميكيًا. يعني تقدر تغير الشكل من غير ما تلمس كود Python.

> بدل ما تكتب HTML ثابت لكل شاشة — بتكتب XML بيوصف الشكل، وOdoo بتعمل الـ rendering تلقائياً.

---

## 1. الـ Odoo Golden Rule — كل حاجة Record

ده أهم مفهوم في Odoo. لما بتفتح أي صفحة:

- الـ **view** نفسها محفوظة كـ record في جدول `ir_ui_view`
- الـ **menu** محفوظ كـ record في جدول `ir_ui_menu`
- الـ **action** محفوظ كـ record في `ir_actions_act_window`

يعني لما بتكتب ده في الـ XML:

```xml
<record id="view_patient_form" model="ir.ui.view">
    ...
</record>
```

أنت بتعمل **INSERT** في جدول `ir_ui_view` في الـ PostgreSQL database. مش بتعمل file — بتعمل record.

---

## 2. أنواع الـ Views في Odoo 18

```
List View   → بيعرض records في جدول (اسمه اتغير من tree لـ list في Odoo 18)
Form View   → بيعرض record واحدة بالتفصيل
Kanban View → بيعرض records ككروت (زي Trello)
Calendar    → بيعرض records على تقويم
Search View → بيتحكم في الـ filters والـ groupby فوق الـ views
```

> ⚠️ **انتبه مهم:** في Odoo 18، الـ root element للـ list view اتغير من `<tree>` لـ `<list>`. الـ `<tree>` لسه شغال للـ backward compatibility بس الـ best practice الجديدة هي `<list>`. الـ Lecture بتاعتك مبنية على Odoo 12 فكان فيها `<tree>`.

---

## 3. الـ List View — جدول الـ Records

الـ list view هي الشاشة الأولى اللي بتشوفها لما تفتح أي menu. بتعرض الـ records في جدول.

```xml
<!-- List View (was 'tree' in older versions, now 'list' in Odoo 18) -->
<record id="view_patient_list" model="ir.ui.view">
    <!-- Display name of this view record -->
    <field name="name">hms.patient.list</field>

    <!-- Which model this view belongs to -->
    <field name="model">hms.patient</field>

    <!-- The actual architecture/structure in XML -->
    <field name="arch" type="xml">

        <!-- Root element: 'list' in Odoo 18 (was 'tree') -->
        <list>
            <!-- Each field becomes a column in the table -->
            <field name="first_name"/>
            <field name="last_name"/>
            <field name="age"/>
            <field name="blood_type"/>
        </list>

    </field>
</record>
```

اللي بيحصل:

```
XML field name="first_name"
         ↓
Odoo looks up 'first_name' column in hms_patient table
         ↓
Renders it as a column header with the field's 'string' label
         ↓
User sees a table with patient data
```

---

## 4. الـ Form View — شاشة التفاصيل

لما المستخدم يضغط على record في الـ list، بيفتح الـ form view. ده أعقد أنواع الـ views.

### 4.1 الـ Minimal Form

```xml
<record id="view_patient_form" model="ir.ui.view">
    <field name="name">hms.patient.form</field>
    <field name="model">hms.patient</field>
    <field name="arch" type="xml">

        <form>
            <field name="first_name"/>
            <field name="last_name"/>
            <field name="age"/>
        </form>

    </field>
</record>
```

ده بيشتغل بس مش بيبان كويس. عشان تعمل form محترمة، محتاج elements إضافية.

### 4.2 الـ Form View في العمق — العناصر المهمة

```xml
<form>

    <!-- header: contains buttons and the statusbar -->
    <!-- This renders as a top bar above the form content -->
    <header>
        <button name="action_approve"
                string="Approve"
                type="object"
                class="btn-primary"/>

        <!-- statusbar: shows the current state as a progress bar -->
        <field name="state"
               widget="statusbar"
               statusbar_visible="draft,approved,done"/>
    </header>

    <!-- sheet: gives the form a white paper-like background -->
    <!-- Without sheet, the form has a grey background -->
    <sheet>

        <!-- group: does two things:
             1. Shows field labels automatically (label + field side by side)
             2. Splits fields into 2-column layout -->
        <group>
            <field name="first_name"/>
            <field name="last_name"/>
        </group>

        <!-- Two groups side by side = 4-column layout -->
        <group>
            <group string="Personal Info">
                <field name="birth_date"/>
                <field name="age"/>
                <field name="gender"/>
            </group>
            <group string="Medical Info">
                <field name="blood_type"/>
                <field name="pcr"/>
                <field name="cr_ratio"/>
            </group>
        </group>

        <!-- notebook: creates a tabbed section at the bottom -->
        <notebook>

            <!-- Each page tag = one tab -->
            <page string="Medical History">
                <field name="history"/>
            </page>

            <page string="Address">
                <field name="address"/>
            </page>

        </notebook>

    </sheet>

</form>
```

الفرق بين الـ elements:

| Element | بيعمل إيه في الـ UI |
|---|---|
| `<sheet>` | خلفية بيضا بحدود، بتشبه ورقة |
| `<group>` | بيعرض الـ label جنب الـ field، وبيعمل 2 columns |
| `<notebook>` | container للـ tabs |
| `<page>` | tab واحدة جوا الـ notebook |
| `<header>` | شريط فوق الـ form للـ buttons والـ statusbar |

---

## 5. الـ Relational Fields — إزاي الـ tables بتتكلم مع بعض

ده من أهم الأجزاء في الكورس كله. في أي نظام حقيقي، الـ data مش isolated — في علاقات بين الجداول.

### 5.1 Many2one — "كل X ينتمي لـ Y واحد"

تخيّل معايا: كل **مريض** بينتمي لـ **department** واحدة.

```
Patient ──────────► Department
(many)               (one)
```

Many2one بيتحط في الجهة "الكتير" (الـ patient):

```python
# In models/patient.py
class HmsPatient(models.Model):
    _name = 'hms.patient'

    # Many2one: many patients → one department
    # Naming convention: use singular_name_id
    department_id = fields.Many2one(
        comodel_name='hms.department',  # the related model
        string='Department'
    )
```

في الـ database، بيعمل column اسمه `department_id` بيخزن الـ `id` بتاع الـ department. يعني **physical field** في الـ database.

في الـ form view، بيظهر كـ dropdown يختار منه المستخدم:

```xml
<!-- Renders as a searchable dropdown in the UI -->
<field name="department_id"/>
```

### 5.2 One2many — "عندي كتير تحتي"

الـ One2many هو العكس بالظبط من الـ Many2one. الـ Department عايزة تعرف مين الـ patients بتاعتها:

```python
# In models/department.py
class HmsDepartment(models.Model):
    _name = 'hms.department'

    name = fields.Char(required=True)

    # One2many: one department → many patients
    # Naming convention: use plural_name_ids
    # IMPORTANT: This is a LOGICAL field — no column in the database
    patient_ids = fields.One2many(
        comodel_name='hms.patient',   # the related model
        inverse_name='department_id', # the Many2one field name in hms.patient
        string='Patients'
    )
```

> ⚠️ **انتبه:** الـ One2many **مفيش له column في الـ database**. ده logical field — بس Odoo بتستخدم الـ Many2one في الجهة التانية عشان تجيب البيانات. لو محدش عمل Many2one في الـ patient model، الـ One2many مش هيشتغل.

في الـ form view، الـ One2many بيظهر كـ embedded list (table داخل الـ form):

```xml
<!-- Renders as an embedded table inside the department form -->
<field name="patient_ids">
    <list>
        <field name="first_name"/>
        <field name="last_name"/>
        <field name="age"/>
    </list>
</field>
```

### 5.3 Many2many — "كل X ممكن يكون في كتير Y وكل Y ممكن فيها كتير X"

مثال: مريض ممكن عنده أكتر من دكتور، ودكتور ممكن عنده أكتر من مريض:

```
Patient ◄──────────► Doctor
(many)               (many)
```

```python
# In models/patient.py
class HmsPatient(models.Model):
    _name = 'hms.patient'

    # Many2many: patients ↔ doctors (bidirectional)
    # Odoo creates a new junction table automatically: hms_patient_hms_doctors_rel
    # Naming convention: plural_name_ids
    doctor_ids = fields.Many2many(
        comodel_name='hms.doctors',
        string='Doctors'
    )
```

الـ Many2many بيعمل **جدول وسيط تلقائيًا** في الـ database (junction table) اسمه `model1_model2_rel`. محتش تعمله يدوي.

في الـ form view مع الـ tags widget:

```xml
<!-- widget="many2many_tags" renders as colored tags instead of a table -->
<field name="doctor_ids" widget="many2many_tags"/>
```

### 5.4 Related Field — "اجيب field من model تانية"

لو عايز تعرض الـ `capacity` بتاعة الـ department في فورم الـ patient من غير ما تفتح الـ department:

```python
# In models/patient.py
class HmsPatient(models.Model):
    _name = 'hms.patient'

    department_id = fields.Many2one(comodel_name='hms.department')

    # Related: follows the dot path to fetch the field value
    # Same type as the original field (Integer in this case)
    # Mostly readonly — it's a mirror, not an editable field
    department_capacity = fields.Integer(
        related='department_id.capacity',
        string='Department Capacity',
        readonly=True
    )
```

---

## 6. Fields Attributes — بتتحكم في الـ field من الـ XML

الـ attributes دي بتتكتب في الـ XML view، مش في الـ Python model (غير الـ `required`):

```xml
<form>
    <group>
        <!-- readonly: user can see but not edit -->
        <field name="age" readonly="True"/>

        <!-- invisible: hidden completely from the view -->
        <field name="history" invisible="True"/>

        <!-- required: must fill before saving (in view level) -->
        <field name="first_name" required="True"/>

        <!-- attrs: conditional behavior based on other field values -->
        <!-- If pcr == True, make cr_ratio required -->
        <field name="cr_ratio"
               attrs="{'required': [('pcr', '=', True)],
                       'invisible': [('age', '&lt;', 50)]}"/>

        <!-- domain: filter options in a Many2one dropdown -->
        <!-- Only show departments where is_opened == True -->
        <field name="department_id"
               domain="[('is_opened', '=', True)]"/>

        <!-- attrs for readonly based on condition -->
        <!-- doctors is readonly until department is selected -->
        <field name="doctor_ids"
               widget="many2many_tags"
               attrs="{'readonly': [('department_id', '=', False)]}"/>

    </group>
</form>
```

> ⚠️ **انتبه:** في الـ `attrs`، لما بتستخدم `<` أو `>` في الـ XML، لازم تعمل escape: `<` بتبقى `&lt;` و`>` بتبقى `&gt;`. ده مش Odoo-specific — ده XML standard.

---

## 7. الـ @api.onchange — بيخلي الـ form يتحرك وأنت بتكتب

تخيّل: المستخدم بيكتب العمر، وعايزك تتحقق لو أقل من 30 تشيل الـ PCR checkbox تلقائيًا وتحذّره.

ده مش بيحصل لما المستخدم يحفظ — بيحصل **فورًا** وهو بيغير الـ field، قبل الـ save.

```python
# In models/patient.py
from odoo import models, fields, api

class HmsPatient(models.Model):
    _name = 'hms.patient'

    age = fields.Integer()
    pcr = fields.Boolean()
    cr_ratio = fields.Float()
    department_id = fields.Many2one(comodel_name='hms.department')

    @api.onchange('age')
    def _onchange_age(self):
        # This runs in the browser without saving to DB
        # self here is a temporary virtual record

        if self.age and self.age < 30:
            # Automatically check the PCR checkbox
            self.pcr = True

            # Return a warning popup to the user
            return {
                'warning': {
                    'title': 'PCR Auto-Checked',
                    'message': 'Patient age is below 30. PCR has been automatically checked.'
                }
            }

    @api.onchange('department_id')
    def _onchange_department(self):
        # When department changes, update the domain for doctors
        # Only show doctors linked to the selected department

        if self.department_id:
            return {
                'domain': {
                    'doctor_ids': [('department_id', '=', self.department_id.id)]
                }
            }
        else:
            # Clear the domain when no department selected
            return {
                'domain': {
                    'doctor_ids': []
                }
            }
```

اللي بيحصل تحت:

```
User types age = 25
         ↓
Browser sends RPC call to Odoo server
         ↓
Odoo runs _onchange_age() on a temporary record (not saved)
         ↓
Method sets self.pcr = True and returns a warning dict
         ↓
Odoo sends back the updated values + warning to the browser
         ↓
Browser updates the PCR checkbox and shows a popup
         ↓
User hasn't saved yet — all this is in-memory
```

> لو عايز **تمنع** الـ onchange من الـ trigger لـ field معين في الـ view، حط `on_change="0"` في الـ XML:
> ```xml
> <field name="age" on_change="0"/>
> ```

---

## 8. Buttons and States — إزاي الـ workflow بيشتغل

كتير من الـ records في Odoo بيمر بـ states: مريض "Undetermined" → "Good" → "Serious". الـ buttons بتغير الـ state.

### 8.1 الـ state field في الـ model

```python
# In models/patient.py
class HmsPatient(models.Model):
    _name = 'hms.patient'

    # State field: drives the workflow
    state = fields.Selection([
        ('undetermined', 'Undetermined'),
        ('good', 'Good'),
        ('fair', 'Fair'),
        ('serious', 'Serious'),
    ], default='undetermined', string='State')

    # Log history linked to this patient
    log_history_ids = fields.One2many(
        comodel_name='hms.patient.log',
        inverse_name='patient_id',
        string='Log History'
    )

    # Button method — @api.multi means it can work on multiple records
    def action_set_good(self):
        for record in self:
            record.state = 'good'
            # Create a log entry each time state changes
            self.env['hms.patient.log'].create({
                'patient_id': record.id,
                'description': f'State changed to Good',
            })
```

### 8.2 الـ buttons في الـ form view

```xml
<form>
    <header>
        <!-- type="object" means: call a Python method with this name -->
        <button name="action_set_good"
                string="Set Good"
                type="object"
                class="btn-success"/>

        <!-- statusbar shows state as a visual progress indicator -->
        <field name="state"
               widget="statusbar"
               statusbar_visible="undetermined,good,fair,serious"/>
    </header>
    <sheet>
        ...
        <notebook>
            <page string="Log History">
                <field name="log_history_ids">
                    <list>
                        <field name="create_uid" string="Created By"/>
                        <field name="create_date" string="Date"/>
                        <field name="description"/>
                    </list>
                </field>
            </page>
        </notebook>
    </sheet>
</form>
```

---

## 9. الـ Odoo ORM — بتعمل CRUD من غير SQL

الـ ORM هو الطبقة اللي بتتعامل مع الـ database من غير ما تكتب SQL.

### 9.1 create — إنشاء record جديدة

```python
# Takes a dict or a list of dicts
# Returns a recordset containing the new records

# Create one record
new_patient = self.env['hms.patient'].create({
    'first_name': 'Ahmed',
    'last_name': 'Mohamed',
    'age': 25,
})
# new_patient is now a recordset: hms.patient(5,)

# Create multiple at once
new_patients = self.env['hms.patient'].create([
    {'first_name': 'Sara', 'last_name': 'Ali'},
    {'first_name': 'Omar', 'last_name': 'Hassan'},
])
# new_patients: hms.patient(6, 7)
```

### 9.2 write — تعديل records موجودة

```python
# Updates all records in the current recordset
# Does NOT return anything

patient = self.env['hms.patient'].browse(5)  # get record by ID

# Update one field
patient.write({'age': 30})

# Update multiple fields at once
patient.write({
    'age': 30,
    'state': 'good',
    'department_id': 3,
})

# Or directly (triggers onchange logic in server side):
patient.age = 30  # same as write but for single record
```

### 9.3 search — البحث عن records

```python
# Takes a domain (list of conditions), returns a recordset

# Find all patients in department 3
patients = self.env['hms.patient'].search([
    ('department_id', '=', 3)
])

# Find patients with age > 50 AND pcr is True
patients = self.env['hms.patient'].search([
    ('age', '>', 50),
    ('pcr', '=', True),
])

# Limit results and order them
first_patient = self.env['hms.patient'].search([
    ('state', '=', 'serious')
], limit=1, order='age desc')

# Just count without fetching records (more efficient)
count = self.env['hms.patient'].search_count([('state', '=', 'good')])
```

**Domain operators:**

| Operator | المعنى |
|---|---|
| `=` | يساوي |
| `!=` | مش يساوي |
| `>`, `>=` | أكبر من / أكبر أو يساوي |
| `<`, `<=` | أصغر من / أصغر أو يساوي |
| `like` | يحتوي على (case sensitive) |
| `ilike` | يحتوي على (case insensitive) |
| `in` | موجود في list |
| `not in` | مش موجود في list |

### 9.4 browse — جيب record بالـ ID

```python
# Takes an ID or a list of IDs, returns a recordset
# Useful when you already have the ID from somewhere

patient = self.env['hms.patient'].browse(5)
# patient: hms.patient(5,)

patients = self.env['hms.patient'].browse([5, 7, 12])
# patients: hms.patient(5, 7, 12)
```

### 9.5 unlink — حذف records

```python
# Deletes all records in the current recordset
# Does NOT return anything

patient = self.env['hms.patient'].browse(5)
patient.unlink()  # patient with ID 5 is now deleted from DB

# Or delete multiple
patients = self.env['hms.patient'].search([('state', '=', 'undetermined')])
patients.unlink()
```

> ⚠️ **انتبه:** الـ `unlink` مش بيرجع undo! لو عندك constraints أو related records ممكن يـ raise error. اتأكد دايمًا من الـ access rights والـ constraints قبل الـ delete.

---

## ✅ Checkpoint — أسئلة إنترفيو

**س: إيه الفرق بين الـ `<tree>` والـ `<list>` في Odoo 18؟**
> في Odoo 18، الـ root element للـ list view اتغير رسميًا من `<tree>` لـ `<list>`. الـ `<tree>` لسه شغال كـ alias عشان backward compatibility، بس الـ official documentation والـ best practice بيقولوا استخدم `<list>`. الـ behavior نفسه بالظبط، بس لو بتكتب كود جديد، استخدم `<list>`.

**س: إيه الفرق بين الـ Many2one والـ One2many من ناحية الـ database؟**
> الـ Many2one هو physical field في الـ database — بيخزن الـ foreign key (الـ ID بتاع الـ related record). أما الـ One2many فهو logical field مفيش له column في الـ database — بس Odoo بتستخدمه عشان تجيب كل الـ records اللي عندها Many2one بيشاور عليك. عشان كده الـ One2many لازم يكون فيه `inverse_name` بيوضح اسم الـ Many2one في الجهة التانية.

**س: إيه اللي بيحصل تحت لما اليوزر يغير field عنده `@api.onchange`؟**
> لما اليوزر يغير قيمة الـ field في الـ browser، بيتبعت RPC call للـ server بالقيم الحالية (مش المحفوظة). Odoo بتشغّل الـ onchange method على temporary record في الـ memory، والـ changes اللي بتحصل فيها بتتبعت للـ browser. المستخدم بيشوف التحديث فورًا بس لسه محفظش في الـ database.

**س: إيه الفرق بين `write()` و `create()` في الـ ORM؟**
> الـ `create()` بيعمل records جديدة وبيرجع recordset بالـ records الجديدة. الـ `write()` بيعدّل records موجودة في الـ recordset الحالي ومبيرجعش حاجة (None). الـ `create()` بياخد dict أو list of dicts، والـ `write()` بياخد dict بس.

**س: امتى بستخدم `search()` وامتى بستخدم `browse()`؟**
> `browse()` لما عندي الـ ID أصلًا وعايز أجيب الـ record بيه. `search()` لما عايز أدور على records بناءً على conditions. الـ `browse()` أسرع لأنه مش بيعمل query — بس بيعمل SQL لما تاكسس الـ fields الفعلية. الـ `search()` بيعمل SQL query من أول.

---

## 🛠️ Practical Exercise — HMS Lab 02

### Task 1 — ضيف الـ models الجديدة

اعمل `hms.department` model:

```python
# models/department.py
from odoo import models, fields

class HmsDepartment(models.Model):
    _name = 'hms.department'
    _description = 'Hospital Department'

    name = fields.Char(required=True)
    capacity = fields.Integer()
    is_opened = fields.Boolean(default=True)

    # One2many back-reference to patients
    patient_ids = fields.One2many(
        comodel_name='hms.patient',
        inverse_name='department_id',
        string='Patients'
    )
```

اعمل `hms.doctors` model:

```python
# models/doctor.py
from odoo import models, fields

class HmsDoctors(models.Model):
    _name = 'hms.doctors'
    _description = 'Hospital Doctor'

    first_name = fields.Char(required=True)
    last_name = fields.Char(required=True)
    image = fields.Binary()
```

### Task 2 — اربط الـ patient بالـ department والـ doctors

في `patient.py`، ضيف:

```python
# Relational fields linking patient to other models
department_id = fields.Many2one(
    comodel_name='hms.department',
    domain=[('is_opened', '=', True)],  # only show open departments
    string='Department'
)

department_capacity = fields.Integer(
    related='department_id.capacity',
    string='Department Capacity',
    readonly=True
)

doctor_ids = fields.Many2many(
    comodel_name='hms.doctors',
    string='Doctors'
)

state = fields.Selection([
    ('undetermined', 'Undetermined'),
    ('good', 'Good'),
    ('fair', 'Fair'),
    ('serious', 'Serious'),
], default='undetermined')
```

### Task 3 — اعمل الـ Form View الكاملة للـ patient

تحديات التصميم:
- الـ `doctors` field يكون `readonly` لحد ما يتاختار department
- لو `pcr` اتشال، الـ `cr_ratio` يبقى required
- الـ `history` field يتخفى لو العمر أقل من 50
- لو العمر أقل من 30، الـ PCR يتشال تلقائيًا مع warning

| الملف | السؤال |
|---|---|
| `patient.py` | هل الـ onchange على age بيشتغل صح مع العمر أقل من 30؟ |
| `patient_views.xml` | هل الـ attrs على cr_ratio بيستخدم `pcr` مش اسم تاني؟ |
| `department.py` | هل الـ One2many عنده `inverse_name` صح؟ |

---

## 🫒 زتونة الإنترفيو

> **"الـ views في Odoo هي records مخزنة في جدول `ir_ui_view` في الـ database — مش HTML ثابت. لما بتكتب XML، أنت بتعمل INSERT في الـ database بيوصف شكل الشاشة. في Odoo 18، الـ list view root element بقى `<list>` بدل `<tree>`. الـ form view بتتبنى من عناصر: `<sheet>` للشكل الورقي، `<group>` للـ labels والـ columns، `<notebook>` للـ tabs. الـ relational fields تلاتة: Many2one فيه column في الـ database بيخزن الـ foreign key، One2many مفيش له column بس بيستخدم الـ Many2one في الجهة التانية، والـ Many2many بيعمل junction table. الـ `@api.onchange` بيشتغل في الـ browser memory قبل الـ save، والـ ORM بيديك create وwrite وsearch وbrowse وunlink من غير ما تكتب SQL خالص."**

---

*Next → الفصل الثالث — Security وAccess Rights: مين يقدر يشوف إيه ويعمل إيه في الـ system*
