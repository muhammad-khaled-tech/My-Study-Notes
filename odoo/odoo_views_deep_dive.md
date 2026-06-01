# الفصل المركّز — Odoo Views وال XML: من الفايل للشاشة

> **المتطلبات:** عارف تعمل model وعندك module شغال — الفصل ده مركّز على حاجة واحدة بس: إزاي الـ XML بيتحول للي بتشوفه قدامك في الـ browser.
>
> **📚 الـ Official Docs:** [View Records — Odoo 18](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_records.html) | [View Architectures — Odoo 18](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_architectures.html)

---

## البداية — ليه محتاج تفهم الـ Views صح؟

كل developer جديد على Odoo بيعمل نفس الغلطة: بيكتب XML، بيعمل reload، ومبيعرفش ليه الـ form بيبان بشكل معين — بيجي الـ field في غلط المكان، بيطلع بدون label، أو بيتخفى من غير سبب واضح.

المشكلة مش في الـ code — المشكلة إنه مش فاهم الـ mental model. قبل ما تكتب حرف XML، لازم تفهم حاجتين:

1. الـ view في Odoo مش HTML — هي **وصفة** محفوظة في الـ database
2. كل element في الـ XML بيتحول لـ UI component بقواعد محددة

---

## 1. الـ Golden Rule — كل حاجة Record

> **📚 المصدر الرسمي:** [View Records](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_records.html)

لما بتكتب الـ XML ده:

```xml
<record id="view_patient_form" model="ir.ui.view">
    <field name="name">hms.patient.form</field>
    <field name="model">hms.patient</field>
    <field name="arch" type="xml">
        <form>
            <field name="first_name"/>
        </form>
    </field>
</record>
```

أنت مش بتعمل file — أنت بتعمل **INSERT في جدول `ir_ui_view`** في الـ PostgreSQL database. الـ Odoo عندها جداول لكل حاجة:

| الـ XML بتكتب | بيتخزن في جدول |
|---|---|
| `model="ir.ui.view"` | `ir_ui_view` |
| `model="ir.ui.menu"` | `ir_ui_menu` |
| `model="ir.actions.act_window"` | `ir_act_window` |

يعني لما بتفتح الـ browser وبتشوف الـ form — Odoo بتعمل SELECT من `ir_ui_view` بتجيب الـ `arch` XML، وبتعمل rendering منه live. ده بالظبط ليه تقدر تعدّل الـ view من الـ UI مباشرة في الـ Developer Mode.

```
Your XML file
      ↓ (on module install/upgrade)
INSERT into ir_ui_view table in PostgreSQL
      ↓ (when user opens a page)
Odoo fetches the 'arch' column
      ↓
Odoo renders it as HTML for the browser
      ↓
User sees the form/list/kanban
```

---

## 2. الـ XML File Structure — هيكل الفايل بالظبط

أي view file لازم يبدأ بكذا:

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <!-- Your records go here -->

    </data>
</odoo>
```

ولازم يتضاف في الـ `__manifest__.py` في الـ `data` list — من غير كده Odoo مش هتحمّله:

```python
# __manifest__.py
'data': [
    'security/ir.model.access.csv',  # security first
    'views/patient_views.xml',        # then views
],
```

> ⚠️ **انتبه:** الـ order في الـ `data` list مهم. الـ security file لازم يجي قبل الـ views.

---

## 3. الـ Action — الجسر الإجباري

> **📚 المصدر الرسمي:** [Window Actions](https://www.odoo.com/documentation/18.0/developer/reference/backend/actions.html#window-actions)

قبل ما أشرح الـ views نفسها، لازم نفهم الـ action. الـ action هو اللي بيربط الـ menu بالـ model وبيحدد أي views تتعرض.

```xml
<record id="action_hms_patients" model="ir.actions.act_window">

    <!-- Label shown in the breadcrumb at the top of the page -->
    <field name="name">Patients</field>

    <!-- The model whose data this action shows -->
    <field name="res_model">hms.patient</field>

    <!-- IMPORTANT: Order here = priority of views shown
         First one in the list = the default view that opens first
         In Odoo 18: 'list' replaces 'tree' (both still work) -->
    <field name="view_mode">list,form</field>

    <!-- Optional: pass context data to the views -->
    <!-- <field name="context">{'default_state': 'draft'}</field> -->

    <!-- Optional: pre-filter the records shown -->
    <!-- <field name="domain">[('active', '=', True)]</field> -->

</record>
```

الـ `view_mode` بيحدد الأزرار اللي بتظهر فوق يمين الصفحة (list icon, form icon, kanban icon). اللي بيجي أول = الـ default view اللي بتفتح أوتوماتيك.

---

## 4. الـ List View (كانت Tree) — جدول الـ Records

> **📚 المصدر الرسمي:** [List View](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_architectures.html#list)

### 4.1 مهم: التغيير في Odoo 18

في Odoo 12-16: الـ root element كان `<tree>`
في Odoo 17-18: اتغير لـ `<list>` (الـ `<tree>` لسه شغال كـ alias)

```xml
<!-- Odoo 12-16 way (still works but deprecated) -->
<tree>
    <field name="name"/>
</tree>

<!-- Odoo 17-18 official way -->
<list>
    <field name="name"/>
</list>
```

### 4.2 الـ List View الكاملة مع الشرح

```xml
<record id="view_patient_list" model="ir.ui.view">
    <!-- Naming convention: model_name.view_type -->
    <field name="name">hms.patient.list</field>
    <field name="model">hms.patient</field>
    <field name="arch" type="xml">

        <!-- 'list' root element — renders as an HTML table -->
        <!-- optional: editable="top" or editable="bottom" makes rows editable inline -->
        <list>

            <!-- Each field = one column in the table -->
            <!-- The column header = field's 'string' attribute from the model -->
            <field name="first_name"/>
            <field name="last_name"/>

            <!-- You can override the column label with string attribute -->
            <field name="age" string="Patient Age"/>

            <!-- optional_columns: columns hidden by default, user can show them -->
            <field name="blood_type" optional="hide"/>

            <!-- decoration-*: color the row based on condition -->
            <!-- decoration-danger = red, decoration-success = green, decoration-warning = yellow -->
            <field name="state"
                   decoration-danger="state == 'serious'"
                   decoration-success="state == 'good'"/>

        </list>

    </field>
</record>
```

اللي بيظهر في الـ UI:

```
┌──────────────┬─────────────┬─────────────┬──────────┐
│  First Name  │  Last Name  │  Patient Age│  State   │
├──────────────┼─────────────┼─────────────┼──────────┤
│  Ahmed       │  Mohamed    │  35         │  Good    │  ← green row
│  Sara        │  Ali        │  22         │  Serious │  ← red row
└──────────────┴─────────────┴─────────────┴──────────┘
```

---

## 5. الـ Form View — شاشة التفاصيل من الجذور

> **📚 المصدر الرسمي:** [Form View](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_architectures.html#form)

### 5.1 أبسط form view ممكنة (مش professional)

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

ده بيشتغل بس الشكل مش كويس — الـ fields بتنزل فوق بعض من غير label، والخلفية رمادية.

### 5.2 الـ Form View العناصر الأساسية — إيه بيعمل إيه

```
┌─────────────────────────────────────────────────────┐
│  <header>                                           │
│  [Approve Button]  [State: Draft → Approved → Done] │
├─────────────────────────────────────────────────────┤
│  <sheet>                                            │
│  ┌──────────────────────────────────────────────┐  │
│  │  <group>                                     │  │
│  │  Label:  [Field Value]  │  Label: [Value]    │  │
│  │  Label:  [Field Value]  │  Label: [Value]    │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  <notebook>                                  │  │
│  │  [Tab 1] [Tab 2] [Tab 3]                    │  │
│  │  ┌────────────────────────────────────────┐ │  │
│  │  │  <page> content here                  │ │  │
│  │  └────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 5.3 الـ Form View الكاملة — كل element بشرح

```xml
<record id="view_patient_form" model="ir.ui.view">
    <field name="name">hms.patient.form</field>
    <field name="model">hms.patient</field>
    <field name="arch" type="xml">

        <form>

            <!-- ═══════════════════════════════════════════════ -->
            <!-- HEADER: top bar with buttons and status bar     -->
            <!-- Renders with a grey background above the sheet  -->
            <!-- ═══════════════════════════════════════════════ -->
            <header>

                <!-- type="object" = call a Python method on the model -->
                <!-- type="action"  = open another action/view         -->
                <button name="action_set_good"
                        string="Mark as Good"
                        type="object"
                        class="btn-success"/>

                <button name="action_set_serious"
                        string="Mark as Serious"
                        type="object"
                        class="btn-danger"/>

                <!-- statusbar widget: renders state as a pipeline bar -->
                <!-- statusbar_visible: which states to always show    -->
                <field name="state"
                       widget="statusbar"
                       statusbar_visible="undetermined,good,fair,serious"/>

            </header>

            <!-- ═══════════════════════════════════════════════ -->
            <!-- SHEET: gives the form a white paper-like look  -->
            <!-- Everything inside sheet has white background   -->
            <!-- ═══════════════════════════════════════════════ -->
            <sheet>

                <!-- ─────────────────────────────────────── -->
                <!-- GROUP: two important functions:         -->
                <!-- 1. Automatically shows field labels     -->
                <!-- 2. Creates a 2-column layout            -->
                <!-- Without group: no labels, no columns    -->
                <!-- ─────────────────────────────────────── -->

                <!-- Single group = 2-column layout -->
                <group>
                    <field name="first_name"/>   <!-- col 1 -->
                    <field name="last_name"/>    <!-- col 2 -->
                    <field name="birth_date"/>   <!-- col 1 -->
                    <field name="age"/>          <!-- col 2 -->
                </group>

                <!-- Two groups side by side = 4-column layout -->
                <!-- string attribute adds a section title     -->
                <group>
                    <group string="Personal Information">
                        <field name="gender"/>
                        <field name="blood_type"/>
                        <field name="image" widget="image"/>
                    </group>
                    <group string="Medical Information">
                        <field name="pcr"/>
                        <field name="cr_ratio"/>
                        <field name="department_id"/>
                        <!-- related field: shows dept capacity read-only -->
                        <field name="department_capacity" readonly="True"/>
                    </group>
                </group>

                <!-- Full-width field outside a group (no label shown) -->
                <field name="address"/>

                <!-- ─────────────────────────────────────── -->
                <!-- NOTEBOOK: creates a tabbed section      -->
                <!-- Each <page> = one tab                   -->
                <!-- ─────────────────────────────────────── -->
                <notebook>

                    <page string="Medical History">
                        <!-- Html field: renders a rich-text editor -->
                        <field name="history"/>
                    </page>

                    <page string="Assigned Doctors">
                        <!-- Many2many field inside a page -->
                        <field name="doctor_ids" widget="many2many_tags"/>
                    </page>

                    <page string="Log History">
                        <!-- One2many field = embedded list inside form -->
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

    </field>
</record>
```

---

## 6. الـ Field في الـ XML — كل الـ Attributes

> **📚 المصدر الرسمي:** [Field Attributes](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_architectures.html#field)

الـ `<field>` tag في الـ XML عندها attributes بتتحكم في السلوك. الفرق المهم: بعض الـ attributes بتتكتب في **الـ Python model** وبعضها في **الـ XML view**.

### 6.1 الـ Attributes الثابتة (بتتكتب في الـ XML)

```xml
<!-- readonly: user sees value but cannot edit it -->
<field name="age" readonly="True"/>

<!-- invisible: field completely hidden from view (still sent to browser) -->
<field name="history" invisible="True"/>

<!-- required: must be filled before saving — overrides model setting -->
<field name="first_name" required="True"/>

<!-- string: override the field label shown in UI -->
<field name="cr_ratio" string="CR Ratio (%)"/>

<!-- widget: change how the field renders in the UI -->
<field name="image"    widget="image"/>           <!-- shows actual image -->
<field name="doctor_ids" widget="many2many_tags"/> <!-- shows colored tags -->
<field name="state"    widget="statusbar"/>        <!-- shows pipeline bar -->
<field name="history"  widget="html"/>             <!-- rich text editor   -->

<!-- nolabel: hide the label but keep the field visible -->
<field name="description" nolabel="1"/>

<!-- colspan: make field span multiple columns in a group -->
<field name="address" colspan="2"/>
```

### 6.2 الـ attrs — السلوك الشرطي (الأهم)

`attrs` بيخليك تحدد سلوك الـ field بناءً على قيمة fields تانية. الـ format هو Python dictionary من domains:

```xml
<!-- If pcr is True → cr_ratio becomes required -->
<field name="cr_ratio"
       attrs="{'required': [('pcr', '=', True)]}"/>

<!-- If age < 50 → history field is hidden -->
<!-- IMPORTANT: less-than must be escaped in XML: < becomes &lt; -->
<field name="history"
       attrs="{'invisible': [('age', '&lt;', 50)]}"/>

<!-- If department_id is not set → doctors field is readonly -->
<field name="doctor_ids"
       widget="many2many_tags"
       attrs="{'readonly': [('department_id', '=', False)]}"/>

<!-- Multiple conditions on same field -->
<field name="cr_ratio"
       attrs="{
           'required':  [('pcr', '=', True)],
           'invisible': [('state', '=', 'undetermined')]
       }"/>
```

> ⚠️ **قاعدة مهمة في الـ XML:** لما بتكتب operators في الـ attrs أو الـ domain، الـ `<` و `>` لازم تتعمل escape:
> - `<` تبقى `&lt;`
> - `>` تبقى `&gt;`
> - `<=` تبقى `&lt;=`
> - `>=` تبقى `&gt;=`

### 6.3 الـ domain — فلترة الـ Many2one Options

الـ domain بيحدد أي records تظهر في الـ dropdown بتاع الـ Many2one field:

```xml
<!-- Only show departments that are open -->
<field name="department_id"
       domain="[('is_opened', '=', True)]"/>

<!-- Dynamic domain based on another field in the same form -->
<!-- Only show doctors belonging to the selected department -->
<field name="doctor_ids"
       domain="[('department_id', '=', department_id)]"/>
```

---

## 7. الـ Menus — الهيكل الثلاثي

> **📚 المصدر الرسمي:** [Menus](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_records.html#menus)

الـ menus في Odoo بتتبنى على 3 مستويات:

```
Level 1: Root Menu   (appears in the top navbar)
    └── Level 2: App Menu  (appears in the side or sub-nav)
            └── Level 3: Clickable Item (triggers the action)
```

```xml
<!-- LEVEL 1: Root — no parent attribute = top navbar item -->
<menuitem
    id="menu_hms_root"
    name="HMS"
    sequence="10"
    web_icon="hms,static/description/icon.png"/>

<!-- LEVEL 2: Category — has parent but no action -->
<menuitem
    id="menu_hms_data"
    name="Data"
    parent="menu_hms_root"
    sequence="10"/>

<!-- LEVEL 3: Clickable — has action attribute -->
<!-- This is the only level that has action -->
<menuitem
    id="menu_hms_patients"
    name="Patients"
    parent="menu_hms_data"
    action="action_hms_patients"
    sequence="10"/>

<menuitem
    id="menu_hms_departments"
    name="Departments"
    parent="menu_hms_data"
    action="action_hms_departments"
    sequence="20"/>

<menuitem
    id="menu_hms_doctors"
    name="Doctors"
    parent="menu_hms_data"
    action="action_hms_doctors"
    sequence="30"/>
```

الـ `sequence` بيحدد الترتيب — الأقل بيجي أول.

---

## 8. ربط الكل مع بعض — الـ Flow الكامل

تخيّل معايا إن المستخدم ضغط على "Patients" في الـ menu. إيه اللي بيحصل بالظبط؟

```
[1] User clicks "Patients" menu item
          ↓
[2] Odoo looks up menu record in ir_ui_menu table
    → finds: action="action_hms_patients"
          ↓
[3] Odoo loads the action from ir_act_window table
    → finds: res_model="hms.patient", view_mode="list,form"
          ↓
[4] Odoo checks if there's a custom list view for hms.patient
    → searches ir_ui_view where model="hms.patient" AND type="list"
          ↓
[5] If found: use it. If not: use auto-generated default view
          ↓
[6] Odoo fetches patient records from hms_patient table in PostgreSQL
          ↓
[7] Combines the view architecture (arch XML) with the data
          ↓
[8] Sends rendered HTML to the browser
          ↓
[9] User sees the list of patients ✅
```

---

## 9. الـ Complete HMS View File — مثال شامل

ده مثال على الـ views file كاملة للـ HMS project اللي في الـ Lab:

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <!-- ================================================ -->
        <!-- PATIENT VIEWS                                    -->
        <!-- ================================================ -->

        <!-- List View for patients -->
        <record id="view_hms_patient_list" model="ir.ui.view">
            <field name="name">hms.patient.list</field>
            <field name="model">hms.patient</field>
            <field name="arch" type="xml">
                <list decoration-danger="state == 'serious'"
                      decoration-success="state == 'good'"
                      decoration-warning="state == 'fair'">
                    <field name="first_name"/>
                    <field name="last_name"/>
                    <field name="age"/>
                    <field name="blood_type"/>
                    <field name="department_id"/>
                    <field name="state"/>
                </list>
            </field>
        </record>

        <!-- Form View for patients -->
        <record id="view_hms_patient_form" model="ir.ui.view">
            <field name="name">hms.patient.form</field>
            <field name="model">hms.patient</field>
            <field name="arch" type="xml">
                <form>
                    <header>
                        <button name="action_set_good"
                                string="Good"
                                type="object"
                                class="btn-success"
                                attrs="{'invisible': [('state', '=', 'good')]}"/>
                        <button name="action_set_serious"
                                string="Serious"
                                type="object"
                                class="btn-danger"
                                attrs="{'invisible': [('state', '=', 'serious')]}"/>
                        <field name="state"
                               widget="statusbar"
                               statusbar_visible="undetermined,good,fair,serious"/>
                    </header>

                    <sheet>
                        <group>
                            <!-- Required fields -->
                            <field name="first_name" required="True"/>
                            <field name="last_name"  required="True"/>
                            <field name="birth_date"/>
                            <field name="age"/>
                        </group>

                        <group>
                            <group string="Medical">
                                <field name="blood_type"/>
                                <!-- pcr is a Boolean checkbox -->
                                <field name="pcr"/>
                                <!-- cr_ratio is only required when pcr is checked -->
                                <field name="cr_ratio"
                                       attrs="{'required': [('pcr', '=', True)]}"/>
                            </group>
                            <group string="Department">
                                <!-- domain: only show open departments -->
                                <field name="department_id"
                                       domain="[('is_opened', '=', True)]"/>
                                <!-- related field: auto-populated, read-only -->
                                <field name="department_capacity" readonly="True"/>
                                <!-- doctors readonly until department is selected -->
                                <field name="doctor_ids"
                                       widget="many2many_tags"
                                       attrs="{'readonly': [('department_id', '=', False)]}"/>
                            </group>
                        </group>

                        <notebook>
                            <!-- history hidden if age < 50 -->
                            <page string="Medical History"
                                  attrs="{'invisible': [('age', '&lt;', 50)]}">
                                <field name="history" widget="html"/>
                            </page>

                            <page string="Address">
                                <field name="address"/>
                                <field name="image" widget="image"/>
                            </page>

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
            </field>
        </record>

        <!-- Action for patients -->
        <record id="action_hms_patients" model="ir.actions.act_window">
            <field name="name">Patients</field>
            <field name="res_model">hms.patient</field>
            <field name="view_mode">list,form</field>
        </record>

        <!-- ================================================ -->
        <!-- DEPARTMENT VIEWS                                 -->
        <!-- ================================================ -->

        <record id="view_hms_department_list" model="ir.ui.view">
            <field name="name">hms.department.list</field>
            <field name="model">hms.department</field>
            <field name="arch" type="xml">
                <list decoration-muted="not is_opened">
                    <field name="name"/>
                    <field name="capacity"/>
                    <field name="is_opened"/>
                </list>
            </field>
        </record>

        <record id="view_hms_department_form" model="ir.ui.view">
            <field name="name">hms.department.form</field>
            <field name="model">hms.department</field>
            <field name="arch" type="xml">
                <form>
                    <sheet>
                        <group>
                            <field name="name"/>
                            <field name="capacity"/>
                            <field name="is_opened"/>
                        </group>
                        <notebook>
                            <page string="Patients">
                                <field name="patient_ids">
                                    <list>
                                        <field name="first_name"/>
                                        <field name="last_name"/>
                                        <field name="state"/>
                                    </list>
                                </field>
                            </page>
                        </notebook>
                    </sheet>
                </form>
            </field>
        </record>

        <record id="action_hms_departments" model="ir.actions.act_window">
            <field name="name">Departments</field>
            <field name="res_model">hms.department</field>
            <field name="view_mode">list,form</field>
        </record>

        <!-- ================================================ -->
        <!-- DOCTORS VIEWS                                    -->
        <!-- ================================================ -->

        <record id="view_hms_doctors_list" model="ir.ui.view">
            <field name="name">hms.doctors.list</field>
            <field name="model">hms.doctors</field>
            <field name="arch" type="xml">
                <list>
                    <field name="first_name"/>
                    <field name="last_name"/>
                </list>
            </field>
        </record>

        <record id="view_hms_doctors_form" model="ir.ui.view">
            <field name="name">hms.doctors.form</field>
            <field name="model">hms.doctors</field>
            <field name="arch" type="xml">
                <form>
                    <sheet>
                        <group>
                            <field name="image" widget="image" class="oe_avatar"/>
                        </group>
                        <group>
                            <field name="first_name"/>
                            <field name="last_name"/>
                        </group>
                    </sheet>
                </form>
            </field>
        </record>

        <record id="action_hms_doctors" model="ir.actions.act_window">
            <field name="name">Doctors</field>
            <field name="res_model">hms.doctors</field>
            <field name="view_mode">list,form</field>
        </record>

        <!-- ================================================ -->
        <!-- MENUS — 3-Level Structure                        -->
        <!-- ================================================ -->

        <!-- Level 1: Root menu (appears in main navbar) -->
        <menuitem
            id="menu_hms_root"
            name="HMS"
            sequence="100"/>

        <!-- Level 2: Data category (no action, just a grouper) -->
        <menuitem
            id="menu_hms_data"
            name="Data"
            parent="menu_hms_root"
            sequence="10"/>

        <!-- Level 3: Clickable items with actions -->
        <menuitem
            id="menu_hms_patients"
            name="Patients"
            parent="menu_hms_data"
            action="action_hms_patients"
            sequence="10"/>

        <menuitem
            id="menu_hms_departments"
            name="Departments"
            parent="menu_hms_data"
            action="action_hms_departments"
            sequence="20"/>

        <menuitem
            id="menu_hms_doctors"
            name="Doctors"
            parent="menu_hms_data"
            action="action_hms_doctors"
            sequence="30"/>

    </data>
</odoo>
```

---

## 10. الأخطاء الشائعة وإزاي تحلها

### خطأ 1: الـ field مش بيظهر label

**السبب:** الـ field خارج `<group>`

```xml
<!-- ❌ No label shown — field is outside a group -->
<sheet>
    <field name="first_name"/>
</sheet>

<!-- ✅ Label shows automatically inside a group -->
<sheet>
    <group>
        <field name="first_name"/>
    </group>
</sheet>
```

### خطأ 2: الـ XML بيرفض يتحمل بسبب operators

```xml
<!-- ❌ This breaks XML parsing -->
<field name="age" attrs="{'invisible': [('age', '<', 50)]}"/>

<!-- ✅ Escape the operator -->
<field name="age" attrs="{'invisible': [('age', '&lt;', 50)]}"/>
```

### خطأ 3: الـ view مش بتتحدث بعد التعديل

الحل: لو عدلت XML بس مش Python، استخدم `--dev xml` flag عند تشغيل الـ server:

```bash
python odoo-bin -c odoo.conf --dev xml
```

ده بيخليك تعمل refresh للـ browser من غير restart.

### خطأ 4: الـ menu بيظهر بس مش بيفتح حاجة

**السبب:** الـ `menuitem` مش عنده `action` attribute، أو الـ `action` id غلط.

```xml
<!-- ❌ Missing action — clicking does nothing -->
<menuitem id="menu_patients" name="Patients" parent="menu_data"/>

<!-- ✅ Correct — action links to the act_window record -->
<menuitem id="menu_patients" name="Patients"
          parent="menu_data" action="action_hms_patients"/>
```

### خطأ 5: الـ One2many مش شايف حاجة

**السبب:** النسيان إن الـ One2many محتاج Many2one في الجهة التانية.

```python
# ❌ This will error or show nothing
class HmsDepartment(models.Model):
    patient_ids = fields.One2many('hms.patient', 'department_id')

# But hms.patient doesn't have department_id field → ERROR

# ✅ Make sure the Many2one exists in the related model
class HmsPatient(models.Model):
    department_id = fields.Many2one('hms.department')  # this MUST exist
```

---

## 11. Quick Reference — جدول المرجع السريع

### الـ View Types

| View | Root Element | الـ Use Case | Default |
|---|---|---|---|
| List | `<list>` (Odoo 18) | عرض records في جدول | أول view في action |
| Form | `<form>` | تفاصيل record واحدة | عند click على row |
| Kanban | `<kanban>` | كروت (زي Trello) | اختياري |
| Search | `<search>` | فلترة وgroupby | تلقائي فوق كل view |

### الـ Form Elements

| Element | بيعمل إيه في الـ UI | ملاحظات |
|---|---|---|
| `<header>` | شريط فوق الـ form | للـ buttons والـ statusbar |
| `<sheet>` | خلفية بيضا | كل الـ content جواه |
| `<group>` | labels + 2 columns | ضروري عشان الـ labels تظهر |
| `<notebook>` | tabs container | |
| `<page>` | tab واحدة | جوا الـ notebook بس |

### الـ Field Attributes

| Attribute | القيم | بيتحكم في |
|---|---|---|
| `readonly` | `True/False` | التعديل |
| `invisible` | `True/False` | الظهور |
| `required` | `True/False` | الإلزامية |
| `string` | text | الـ label في الـ UI |
| `widget` | image, html, statusbar, many2many_tags… | طريقة العرض |
| `attrs` | dict of domains | سلوك شرطي |
| `domain` | list of tuples | فلترة الـ Many2one options |

### الـ Domain Operators

| Operator في Domain | المعنى | في XML |
|---|---|---|
| `=` | يساوي | `=` |
| `!=` | مش يساوي | `!=` |
| `<` | أصغر من | `&lt;` |
| `>` | أكبر من | `&gt;` |
| `<=` | أصغر أو يساوي | `&lt;=` |
| `>=` | أكبر أو يساوي | `&gt;=` |
| `in` | موجود في list | `in` |
| `like` / `ilike` | يحتوي على | `like` |

---

## ✅ Checkpoint — أسئلة إنترفيو Views

**س: ليه الـ views في Odoo XML ومش HTML مباشرة؟**
> عشان الـ views في Odoo مش static files — هي records محفوظة في جدول `ir_ui_view` في الـ database. الـ XML بيوصف الـ structure بس، وOdoo بتعمل rendering منه لـ HTML ديناميكيًا. ده بيخلي الـ views قابلة للتعديل من الـ UI في Developer Mode وقابلة للـ inheritance والـ override من modules تانية من غير ما تلمس الكود الأصلي.

**س: إيه الفرق بين `invisible` في الـ attrs والـ `invisible` العادي؟**
> الـ `invisible="True"` الثابت بيخفي الـ field دايمًا. الـ `attrs="{'invisible': [condition]}"` بيخفيه بناءً على شرط ديناميكي — الـ browser بيبعته في كل مرة بتتغير القيمة. الاتنين بيخفوا الـ field من الشاشة، بس الـ field لسه بيتبعت للـ browser في الـ HTML (مش كـ security measure — استخدم `groups` عشان الـ security).

**س: إيه اللي بيحصل لما تضيف field جوا `<group>` مقارنة بـ بره؟**
> جوا `<group>`: الـ Odoo بيعمل label تلقائيًا من الـ field's `string` attribute، والـ fields بتتوزع في 2 columns. بره الـ group: مفيش label والـ field بياخد الـ width الكاملة. عشان كده دايمًا تحط الـ fields جوا `<group>` في الـ form view إلا لو معايا سبب معين.

**س: في Odoo 18، إيه الفرق بين `<tree>` و`<list>`؟**
> في Odoo 17-18، الـ root element للـ list view اتغير رسميًا من `<tree>` لـ `<list>`. الـ `<tree>` لسه شغال كـ backward-compatible alias، بس الـ official docs بتقول استخدم `<list>`. اسم الـ view type في الـ action لسه `list` في كل الـ versions. لو بتكتب كود جديد لـ Odoo 18، استخدم `<list>`.

**س: عندي Many2one field في الـ form، عايز أفلتر الـ options — بعمل إيه؟**
> بستخدم الـ `domain` attribute على الـ field في الـ XML: `<field name="department_id" domain="[('is_opened', '=', True)]"/>`. ده بيحدد الـ records اللي بتظهر في الـ dropdown. ممكن كمان يكون dynamic بيعتمد على field تاني في نفس الـ form: `domain="[('type', '=', field_name)]"`.

---

## 🫒 زتونة الإنترفيو

> **"الـ views في Odoo هي records في جدول `ir_ui_view` في الـ database مش HTML static — الـ XML اللي بتكتبه بيتحول لـ INSERT في الـ database لما بتعمل install أو upgrade، وOdoo بتـ render منه HTML ديناميكيًا لكل request. الـ form view بتتبنى من 4 layers: `<header>` للـ buttons والـ statusbar، `<sheet>` للـ white paper look، `<group>` للـ labels والـ 2-column layout، و`<notebook>` للـ tabs. الـ `attrs` بيديك conditional behavior بناءً على domain expressions، والـ operators فيه زي `<` لازم تتعمل escape في الـ XML لـ `&lt;`. في Odoo 18، الـ `<tree>` اتغير رسميًا لـ `<list>`. أهم حاجة تفتكرها: الـ field من غير `<group>` = مفيش label."**

---

## 📚 مصادر رسمية للمراجعة

| الموضوع | الـ Link |
|---|---|
| View Records (إزاي الـ views بتتخزن) | [odoo.com/documentation/18.0/…/view_records.html](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_records.html) |
| View Architectures (كل الـ XML elements) | [odoo.com/documentation/18.0/…/view_architectures.html](https://www.odoo.com/documentation/18.0/developer/reference/user_interface/view_architectures.html) |
| Basic Views Tutorial | [odoo.com/documentation/18.0/…/06_basicviews.html](https://www.odoo.com/documentation/18.0/developer/tutorials/server_framework_101/06_basicviews.html) |
| Window Actions | [odoo.com/documentation/18.0/…/actions.html](https://www.odoo.com/documentation/18.0/developer/reference/backend/actions.html) |
| Fields Reference | [odoo.com/documentation/18.0/…/fields.html](https://www.odoo.com/documentation/18.0/developer/reference/backend/orm.html#fields) |
