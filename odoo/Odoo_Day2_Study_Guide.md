# Odoo Development — Day 2 Study Guide
## From Model to Complete UI Feature

> **Who this guide is for:** Beginners in Odoo development with a software engineering background.
> You understand databases and programming, but Odoo's framework-specific patterns — XML views,
> ORM relationships, and decorators — are still new territory.

---

## 🧭 The Big Picture

Keep this chain in mind as you read. Every concept in this guide is one link in it:

```
Python Model (fields.py)
        ↓
Field Definitions  (Char, Integer, Many2one…)
        ↓
Relational Links   (Many2one → One2many → Many2many)
        ↓
XML Views          (list, form, groups, notebook…)
        ↓
Menus & Actions    (ir.ui.menu, ir.actions.act_window)
        ↓
Buttons            (<header>, type="object", Python method)
        ↓
States & Statusbar (workflow pipeline visualization)
        ↓
User Interaction   (@api.onchange, UI updates before save)
```

---

## Table of Contents

1. [Odoo Views Overview](#1-odoo-views-overview)
2. [List (Tree) View](#2-list-tree-view)
3. [Form View](#3-form-view)
4. [Form Layout Components](#4-form-layout-components)
5. [Relational Fields](#5-relational-fields)
6. [Field Attributes & Domains](#6-field-attributes--domains)
7. [Buttons & States](#7-buttons--states)
8. [@api.onchange](#8-apionchange)
9. [Putting It All Together — Complete Module](#9-putting-it-all-together--complete-module)
10. [Day 2 Cheat Sheet](#10-day-2-cheat-sheet)
11. [Day 2 Flow Recap](#11-day-2-flow-recap)

---

## 1. Odoo Views Overview

### What is a View?

A **view** in Odoo is an XML definition that controls how records from a model are displayed
to the user. The same model can have multiple views, each presenting data in a different way.

Think of it as a clean separation of concerns:
- **Model (Python)** = the data structure and business logic
- **View (XML)** = the presentation layer

You define your data once in Python, then control how it looks entirely in XML.

### Why Do We Use Views?

Without views, Odoo either shows no UI or generates a very basic auto-generated one
(which is ugly and incomplete for real applications). Views let you:

- Choose exactly which fields to show
- Organize fields into groups, tabs, and sections
- Add workflow buttons and action controls
- Present the same data differently for different purposes (overview vs detail)

### Types of Views

| View Type | Root Element | Purpose |
|-----------|-------------|---------|
| **List** (was Tree) | `<list>` | All records in a table — rows and columns |
| **Form** | `<form>` | One record in full detail — the edit/create UI |
| **Kanban** | `<kanban>` | Card-based layout (like Trello columns) |
| **Calendar** | `<calendar>` | Records plotted on a calendar by a date field |
| **Pivot** | `<pivot>` | Excel-style aggregation for reporting |
| **Activity** | `<activity>` | Scheduled activities per record |

> 📖 **Docs:** https://www.odoo.com/documentation/17.0/developer/reference/backend/views.html

---

### How to Register Views in a Window Action

In your `views.xml` file, create a Window Action (`ir.actions.act_window`) and
specify available view types with `view_mode`:

```xml
<!-- In: views/student_views.xml -->

<record id="action_student" model="ir.actions.act_window">
    <field name="name">Students</field>
    <field name="res_model">iti.student</field>

    <!-- Controls which view-switcher buttons appear top-right in the UI -->
    <!-- If you omit this field entirely, Odoo defaults to "list,form" -->
    <field name="view_mode">list,form,kanban</field>
</record>
```

> ✅ **Best practice:** Always include `list` and `form`. Add other view types only when you
> genuinely need them.

---

### `_rec_name` — How Records Display in Relationships

When a record appears in a **Many2one dropdown**, Odoo needs to know *what to display*.
By default it looks for a field named `name`.

```python
class Track(models.Model):
    _name = 'iti.track'
    name = fields.Char('Track Name')   # ← Used automatically as display name
```

If your model has no `name` field (e.g., you have `first_name` and `last_name`),
Odoo falls back to showing the raw database ID — which is not user-friendly:

```
# Without _rec_name pointing to a real field:
Dropdown shows → "iti.student(1)", "iti.student(2)"   ← confusing!

# With _rec_name:
Dropdown shows → "Ahmed", "Sara"                       ← clear
```

**Fix:** Use `_rec_name` on your model class:

```python
class Student(models.Model):
    _name = 'iti.student'
    _rec_name = 'first_name'   # ← this field is used as the display name

    first_name = fields.Char('First Name')
    last_name  = fields.Char('Last Name')
```

> ⚠️ **Correction from your notes:** `_rec_name` accepts **one field name only** (a string).
> It cannot hold a list of multiple fields.
>
> To combine multiple fields into a display name (e.g. "Ahmed Hassan"), override
> `_compute_display_name()`:
>
> ```python
> def _compute_display_name(self):
>     for rec in self:
>         rec.display_name = f"{rec.first_name} {rec.last_name}"
> ```

---

## 2. List (Tree) View

### What is it?

The List view shows **all records** of a model in a table. Each field you include becomes
a column. It's the first screen users see when they open a menu item.

> 📌 **Naming note:** In Odoo 17+, this view was renamed from **Tree** to **List**.
> The XML root element changed from `<tree>` to `<list>`.
> If you see tutorials using `<tree>`, it's the same thing — just an older version.

### Why Use It?

- Give users a quick overview of all records
- Let them sort, filter, and search
- Act as the entry point before opening a specific record in Form view

### How It Works

You create an `ir.ui.view` record in XML whose `arch` field contains a `<list>` element:

```xml
<!-- In: views/student_views.xml -->

<record id="view_student_list" model="ir.ui.view">

    <!-- 'name' does NOT need to be unique — it's a label for developers -->
    <field name="name">iti.student.list</field>

    <!-- Which model this view belongs to -->
    <field name="model">iti.student</field>

    <!-- 'arch' (architecture) = the actual XML layout of the view -->
    <field name="arch" type="xml">
        <list string="Students">
            <!-- Each <field> adds one column to the table -->
            <field name="first_name"/>
            <field name="last_name"/>
            <field name="age"/>
            <field name="track_id"/>   <!-- Many2one: shows track name automatically -->
            <field name="state"/>
        </list>
    </field>

</record>
```

### Common Beginner Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Using `<tree>` in Odoo 17 | Use `<list>` |
| Missing `type="xml"` on the arch field | Always include `type="xml"` |
| Missing quotes around attribute values: `id=view_list` | Use quotes: `id="view_list"` |
| Referencing a field that does not exist in the model | Always check your Python model first |

### Mental Model

```
Database Table
      ↓
List View ≈ SELECT first_name, last_name, track_id FROM iti_student;
      ↓
User sees rows and columns
      ↓
User clicks a row → Form View opens for that record
```

---

## 3. Form View

### What is it?

The Form view shows **one record** in full detail. It's the view used to *create* new records
and *edit* existing ones.

### Why Use It?

The List view gives a summary. The Form view gives the full picture.
The user journey is: **List → click a row → Form**.

### How It Differs from List View

| Aspect | List View | Form View |
|--------|-----------|-----------|
| Records shown | Many at once | One at a time |
| Primary purpose | Browse and search | Create and edit |
| Root XML element | `<list>` | `<form>` |
| Typical use | See all students | Fill in a student's details |
| Layout | Rows and columns | Grouped sections, tabs, headers |

### How It Works

```xml
<record id="view_student_form" model="ir.ui.view">
    <field name="name">iti.student.form</field>
    <field name="model">iti.student</field>
    <field name="arch" type="xml">
        <form string="Student">
            <!-- Layout components go here — covered in the next section -->
        </form>
    </field>
</record>
```

### Critical Correction from Your Notes

> ⚠️ Your notes show `<list>` inside the form view's `arch`. This is **wrong**.
> A form view must use `<form>` as its root element.

#### ❌ Incorrect

```xml
<field name="arch" type="xml">
    <list>                  <!-- WRONG: <list> is for the list view only -->
        <sheet>
            ...
        </sheet>
    </list>
</field>
```

#### ✅ Correct

```xml
<field name="arch" type="xml">
    <form>                  <!-- CORRECT: form view uses <form> as its root -->
        <sheet>
            ...
        </sheet>
    </form>
</field>
```

---

## 4. Form Layout Components

The Form view is where visual organization matters most. Odoo provides four main
layout elements — use them together to build a clean, structured UI.

### Visual Hierarchy

```
<form>
├── <header>                ← Status bar + action buttons (optional but common)
└── <sheet>                 ← The "paper" content area
    ├── <group>             ← Outer group → creates side-by-side columns
    │   ├── <group>         ← Left column (inner group)
    │   │   ├── <field>
    │   │   └── <field>
    │   └── <group>         ← Right column (inner group)
    │       ├── <field>
    │       └── <field>
    └── <notebook>          ← Tabbed container
        ├── <page>          ← Tab 1
        │   └── <group>
        │       └── <field>
        └── <page>          ← Tab 2
            └── <group>
                └── <field>
```

---

### 4.1 `<sheet>`

#### What is it?

`<sheet>` wraps all form content in a visually distinct "paper" area — with proper
margins, padding, and background colour.

#### Why Use It?

Without `<sheet>`, all your fields are crammed into a single horizontal line with no
visual structure. It looks terrible and is impossible to use.

```xml
<!-- ❌ Without <sheet> — everything on one ugly horizontal line -->
<form>
    <field name="first_name"/>
    <field name="age"/>
    <field name="gender"/>
</form>

<!-- ✅ With <sheet> — clean layout, proper spacing -->
<form>
    <sheet>
        <field name="first_name"/>
        <field name="age"/>
        <field name="gender"/>
    </sheet>
</form>
```

> **Mental Model:** `<sheet>` is the white piece of paper inside the form frame.
> Everything you want to display goes inside it.

---

### 4.2 `<group>`

#### What is it?

`<group>` organises fields **vertically** inside a labelled section.
Each field appears on its own row, with its label on the left and its input on the right.

#### Why Use It?

- Creates a clean two-column layout (label | input field)
- Lets you give a section a descriptive title using `string`
- Groups related fields so users can scan the form quickly

```xml
<group string="Personal Information">
    <field name="first_name"/>
    <field name="last_name"/>
    <field name="age"/>
</group>
```

This renders as:

```
┌─────────────────────────────────────────┐
│ Personal Information                    │
├──────────────────┬──────────────────────┤
│ First Name       │  [Ahmed            ] │
│ Last Name        │  [Hassan           ] │
│ Age              │  [25               ] │
└──────────────────┴──────────────────────┘
```

---

### 4.3 Nested Groups — Side-by-Side Layout

#### The Problem

Single `<group>` elements stack **vertically** — one below another.
What if you need two sections **side by side** (two-column layout)?

#### The Solution

Wrap two inner `<group>` elements inside one **outer** `<group>`.
The outer group creates two equal columns; each inner group fills one column:

```xml
<sheet>

    <!-- Outer group: this is the two-column container -->
    <group>

        <!-- Left column -->
        <group string="Personal Information">
            <field name="first_name"/>
            <field name="last_name"/>
            <field name="age"/>
        </group>

        <!-- Right column -->
        <group string="Academic Information">
            <field name="track_id"/>
            <field name="track_capacity" readonly="1"/>
        </group>

    </group>

</sheet>
```

This renders as:

```
┌──────────────────────────┬───────────────────────────┐
│ Personal Information     │ Academic Information      │
├───────────────┬──────────┼──────────────┬────────────┤
│ First Name    │ [Ahmed]  │ Track        │ [Python ▼] │
│ Last Name     │ [Hassan] │ Capacity     │ [30]       │
│ Age           │ [25]     │              │            │
└───────────────┴──────────┴──────────────┴────────────┘
```

> **Mental Model:** The outer `<group>` is like an HTML `<table>` with two `<td>` cells.
> Each inner `<group>` is one of those cells.

---

### 4.4 `<notebook>` and `<page>`

#### What is it?

`<notebook>` creates a **tabbed interface**. Each `<page>` inside it is one tab.
This is ideal when a record has many fields that would make the form uncomfortably long.

#### Why Use It?

- Prevents forms from being overwhelming
- Organises fields into logical categories
- Users navigate between sections without scrolling

```xml
<notebook>

    <page name="personal_info" string="Personal Info">
        <group>
            <field name="first_name"/>
            <field name="last_name"/>
            <field name="age"/>
        </group>
    </page>

    <page name="academic_info" string="Academic Info">
        <group>
            <field name="track_id"/>
            <field name="level"/>
        </group>
    </page>

    <page name="employment" string="Employment">
        <group>
            <field name="is_working"/>
            <field name="cv"     invisible="is_working == False"/>
            <field name="salary" invisible="is_working == False"/>
        </group>
    </page>

</notebook>
```

This renders as:

```
╔══════════════════════════════════════════════════╗
║  [Personal Info]  [Academic Info]  [Employment] ║   ← Tabs
╠══════════════════════════════════════════════════╣
║                                                  ║
║  First Name   │  [Ahmed            ]             ║
║  Last Name    │  [Hassan           ]             ║
║  Age          │  [25               ]             ║
║                                                  ║
╚══════════════════════════════════════════════════╝
```

---

### 4.5 `name` vs `string` — A Critical Difference

This confuses almost every Odoo beginner. Memorise the difference now:

| Attribute | Purpose | Who sees it | Required for inheritance |
|-----------|---------|------------|--------------------------|
| `name` | Technical identifier — used in code and view inheritance | Developers only | ✅ Yes |
| `string` | Human-readable label — shown in the UI | End users | ❌ No |

#### `name` is the unique identifier you need when inheriting views

```xml
<!-- Original view -->
<page name="academic_info" string="Academic Info">
    ...
</page>

<!-- In an inherited module — target the page by its technical name -->
<xpath expr="//page[@name='academic_info']" position="after">
    <page name="extra_tab" string="Extra Information">
        ...
    </page>
</xpath>
```

If the `name` attribute is missing, you cannot reliably target that element later.

> **Mental Model:**
> - `string` = the label users read on screen → "Academic Info"
> - `name` = the ID developers use in code to target it → "academic_info"

---

### 4.6 Complete Form Layout Example

```xml
<!-- In: views/student_views.xml -->

<record id="view_student_form" model="ir.ui.view">
    <field name="name">iti.student.form</field>
    <field name="model">iti.student</field>
    <field name="arch" type="xml">
        <form string="Student">

            <!-- ─── HEADER: status bar + workflow buttons ─── -->
            <header>
                <button name="action_accept"
                        string="Accept Student"
                        type="object"
                        class="btn-primary"/>
                <field name="state"
                       widget="statusbar"
                       statusbar_visible="new,accepted,rejected"
                       nolabel="1"/>
            </header>

            <!-- ─── SHEET: main content area ─── -->
            <sheet>

                <!-- Side-by-side layout via nested groups -->
                <group>

                    <group string="Personal Information">
                        <field name="first_name"/>
                        <field name="last_name"/>
                        <field name="age"/>
                        <field name="gender"/>
                    </group>

                    <group string="Academic Information">
                        <!-- domain filters dropdown to open tracks only -->
                        <field name="track_id"
                               domain="[('is_opened', '=', True)]"/>
                        <!-- Related field: auto-populated, read-only -->
                        <field name="track_capacity" readonly="1"/>
                        <field name="level"/>
                    </group>

                </group>

                <!-- Tabbed sections for additional details -->
                <notebook>

                    <page name="enrolled_students" string="Enrolled Students">
                        <!-- One2many renders as an embedded list -->
                        <field name="student_ids">
                            <list>
                                <field name="first_name"/>
                                <field name="last_name"/>
                                <field name="is_accepted"/>
                            </list>
                        </field>
                    </page>

                    <page name="employment" string="Employment">
                        <group>
                            <!-- is_working must be in the view for conditions below to work -->
                            <field name="is_working"/>
                            <field name="cv"
                                   invisible="is_working == False"/>
                            <field name="salary"
                                   required="is_working == True"
                                   invisible="is_working == False"/>
                        </group>
                    </page>

                </notebook>

            </sheet>
        </form>
    </field>
</record>
```

---

## 5. Relational Fields

### ORM Concepts First

Two things to understand before writing relational fields:

**1. Physical vs Logical fields in the database:**
- **Physical** = a real column exists in the database table (you can `SELECT` it directly)
- **Logical** = no column; Odoo queries or computes the value when you access it

**2. Why does Odoo have three relation types?**
Because different business situations need different kinds of links:
- One direction? Many2one
- Reverse direction? One2many
- Both directions, multiple on both sides? Many2many

---

### Overview: Our Running Example

We have two models: **Student** and **Track**.

```
┌─────────────────────────────────────────────────────────┐
│                   TRACK TABLE                           │
│  id │ name       │ capacity │ is_opened                 │
│  1  │ Python     │ 30       │ True                      │
│  2  │ Odoo Dev   │ 25       │ True                      │
└─────────────────────────────────────────────────────────┘
              ↑                  ↑
              │ track_id = 1     │ track_id = 2
              │ (FK)             │ (FK)
┌─────────────────────────────────────────────────────────┐
│                  STUDENT TABLE                          │
│  id │ first_name │ last_name │ age │ track_id           │
│  1  │ Ahmed      │ Hassan    │ 25  │  1   → Python      │
│  2  │ Sara       │ Ali       │ 22  │  1   → Python      │
│  3  │ Omar       │ Khaled    │ 28  │  2   → Odoo Dev    │
└─────────────────────────────────────────────────────────┘
```

---

### 5.1 Many2one

#### What is it?

A Many2one field links **many records to one parent record**.
It is the most common relationship in Odoo.

- Many students → one track
- Many sales orders → one customer
- Many invoices → one company

#### Physical Database Presence

> ✅ **Many2one IS a physical column in the database.**

Odoo creates an integer column (e.g. `track_id`) storing the parent record's ID.
This is identical to a **Foreign Key** in standard SQL.

```
PostgreSQL — iti_student table:
  id | first_name | track_id
  1  | Ahmed      |    1       ← integer FK pointing to iti_track.id
  2  | Sara       |    1
  3  | Omar       |    2
```

#### Python Implementation

```python
# In: models/student.py

from odoo import models, fields

class Student(models.Model):
    _name = 'iti.student'
    _description = 'ITI Student'

    first_name = fields.Char('First Name', required=True)
    last_name  = fields.Char('Last Name')

    # Many2one: "this student belongs to one track"
    track_id = fields.Many2one(
        comodel_name='iti.track',   # The _name of the related model (as a string)
        string='Track',
        ondelete='set null',        # When the parent track is deleted:
                                    # 'set null'    → set track_id to null
                                    # 'restrict'   → block deletion if students exist
                                    # 'cascade'    → delete this student too
    )
```

#### ❌ Common Mistake

```python
# ❌ Using the class name (Python class), not the model _name
track_id = fields.Many2one('Track')

# ❌ Using lowercase field type name
track_id = fields.many2one('iti.track')
```

#### ✅ Correct

```python
# ✅ Use the model's _name value — always a lowercase dotted string
# ✅ Field types in Odoo use CamelCase: Many2one, One2many, Many2many
track_id = fields.Many2one('iti.track', string='Track')
```

#### XML View

```xml
<!-- A Many2one field automatically renders as a searchable dropdown -->
<field name="track_id"/>

<!-- With domain — shows only open tracks in the dropdown -->
<field name="track_id" domain="[('is_opened', '=', True)]"/>
```

#### Mental Model

```
Many2one = Foreign Key

"This record belongs to ONE parent."

Student ──── track_id ────→ Track
  (many)                    (one)

DB: student.track_id = integer (Track's ID)
```

> 📖 **Docs:** https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.Many2one

---

### 5.2 One2many

#### What is it?

A One2many is the **reverse** of a Many2one. Instead of pointing to one parent,
it *collects all the child records that point back to this record*.

- One track ← many students enrolled in it
- One customer ← many orders placed by them

#### Logical — No Physical Column

> ❌ **One2many has NO column in the database.**

When you access `track.student_ids`, Odoo silently runs:

```sql
SELECT * FROM iti_student WHERE track_id = <this_track_id>;
```

No extra column needed. The data is already on the Student side via its `track_id` FK.

#### Why `inverse_name` is Required

The One2many field must know *which Many2one field on the child model* to use
for the reverse lookup. That's the `inverse_name`.

```python
# On the Track model, track.student_ids means:
# "Find all iti.student records where their 'track_id' field points to this Track."
#                                              ↑ inverse_name
```

#### Python Implementation

```python
# In: models/track.py

from odoo import models, fields

class Track(models.Model):
    _name = 'iti.track'
    _description = 'ITI Track'

    name      = fields.Char('Track Name', required=True)
    capacity  = fields.Integer('Max Capacity', default=30)
    is_opened = fields.Boolean('Open for Enrollment', default=True)

    # One2many: "this track has many enrolled students"
    student_ids = fields.One2many(
        comodel_name='iti.student',   # Model where the Many2one lives
        inverse_name='track_id',       # The Many2one field name on iti.student
        string='Enrolled Students',
    )
```

> ⚠️ **Prerequisite:** The `track_id` Many2one **must already exist** on `iti.student`.
> If it doesn't, Odoo will raise an error on startup.

#### ❌ Incorrect (from your notes)

```python
# ❌ Multiple problems:
student_ids = field.one2many('itt.students', 'track_id')
#             ↑          ↑    ↑
#         'field' not    |  Typo: 'itt' instead of 'iti'
#         'fields'       |  'students' (plural) vs actual _name 'student'
#                     lowercase — should be One2many (CamelCase)
```

#### ✅ Correct

```python
# ✅ Correct syntax:
student_ids = fields.One2many(
    'iti.student',   # Exact _name of the child model
    'track_id',      # Exact field name on the child model
    string='Enrolled Students',
)
```

#### XML View — Embedded List

One2many fields render as a **mini embedded list** inside the parent form:

```xml
<!-- In the Track form view: -->
<field name="student_ids">
    <!-- Custom columns for the embedded list -->
    <list>
        <field name="first_name"/>
        <field name="last_name"/>
        <field name="is_accepted"/>
    </list>
</field>
```

If you don't add the custom `<list>`, Odoo uses the default list view of the child model.

#### Mental Model

```
One2many = "Show me all children that point to me"

Track (parent)
  ↑
  │ track_id  (Many2one lives on Student)
  │
Students: Ahmed (1), Sara (2), Omar (3)   ← these are student_ids

One2many is a virtual query:
  "Give me all students WHERE student.track_id = this_track.id"

No DB column. Pure reverse-lookup.
```

> 📖 **Docs:** https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.One2many

---

### 5.3 Many2many

#### What is it?

Many2many allows records on **both sides** to relate to multiple records on the other side.

- A student can have many skill tags; a tag can belong to many students
- A product can be in multiple categories; a category has many products
- An employee can have multiple roles; a role can be assigned to many employees

#### Intermediate Relation Table

> **Many2many automatically creates a "link" table in the database.**

Odoo creates and manages this junction table for you. You never write it yourself.

```
EXAMPLE: iti_student ↔ iti_tag

iti_student_iti_tag_rel   (auto-created by Odoo)
  student_id │ tag_id
  ──────────────────
       1      │  10     ← Ahmed has tag Python
       1      │  11     ← Ahmed also has tag Django
       2      │  10     ← Sara also has tag Python
       3      │  12     ← Omar has tag Java
```

#### Python Implementation

```python
# In: models/student.py

class Student(models.Model):
    _name = 'iti.student'

    # Many2many: a student can have multiple tags
    tag_ids = fields.Many2many(
        comodel_name='iti.tag',
        string='Skills / Tags',
    )
```

```python
# In: models/tag.py

class Tag(models.Model):
    _name = 'iti.tag'
    name = fields.Char('Tag Name', required=True)
```

Odoo creates the relation table `iti_student_iti_tag_rel` automatically when
you install/upgrade the module.

#### XML View

By default, Many2many fields render as a **tag-cloud** multi-select:

```xml
<!-- Renders as: [Python ×] [Django ×] [+ Add a line] -->
<field name="tag_ids" widget="many2many_tags"/>
```

#### Mental Model

```
Many2many = Junction Table (both sides can hold many)

Student  ←──────→  Tag
 (many)              (many)

"Ahmed knows Python AND Django."
"Python is known by Ahmed AND Sara AND many others."

The link table stores every (student, tag) combination.
```

> 📖 **Docs:** https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.Many2many

---

### 5.4 Related Fields

#### What is it?

A Related field **reads a value from a linked record through a relationship**.
It's a shortcut to display information from another model directly on the current form.

#### Why Use It?

You're looking at a Student's form and want to see the **capacity** of their track —
without navigating to the Track record separately.

```python
# The "path" is: Student → (follow track_id link) → Track → (read capacity)
track_capacity = fields.Integer(related='track_id.capacity')
```

#### Physical or Logical?

> ✅ **Related fields ARE stored in the database by default** (unless `store=False`).
> Odoo updates the stored value automatically when the source changes.

#### Read-Only by Default

Related fields are **read-only by default**. This makes sense — you're reading a value
that "belongs" to another record. Odoo prevents accidental edits.

#### Python Implementation

```python
# In: models/student.py

class Student(models.Model):
    _name = 'iti.student'

    track_id = fields.Many2one('iti.track', string='Track')

    # Related field: auto-read from track_id.capacity
    # No method needed — Odoo handles the join automatically
    track_capacity = fields.Integer(
        related='track_id.capacity',
        string='Track Capacity',
        # readonly=True is the default — you don't have to write it
    )
```

#### XML View

```xml
<!-- Just add it like a normal field — it auto-populates when track_id changes -->
<field name="track_capacity" readonly="1"/>
```

When the user picks a track from the `track_id` dropdown, `track_capacity` fills in
automatically and is greyed out (non-editable).

#### Mental Model

```
Related Field = Auto-filled value through a relationship path

student.track_capacity
  = student.track_id  →  track.capacity
                  ↑
          Follow this link first, then read that field
```

---

### 5.5 Step-by-Step: Implementing All Relations

The complete sequence the instructor walked through in class:

#### Step 1 — Create the Track model

```python
# In: models/track.py

from odoo import models, fields

class Track(models.Model):
    _name = 'iti.track'
    _description = 'ITI Track'

    name      = fields.Char('Track Name', required=True)
    capacity  = fields.Integer('Max Capacity', default=30)
    is_opened = fields.Boolean('Open for Enrollment', default=True)
```

#### Step 2 — Update `models/__init__.py`

```python
# In: models/__init__.py

from . import student   # already there from Day 1
from . import track     # ← add this line
```

#### Step 3 — Create a view file for Track

```xml
<!-- In: views/track_views.xml — new file -->
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <!-- Track list and form views go here -->
</odoo>
```

#### Step 4 — Register the new view file in `__manifest__.py`

```python
# In: __manifest__.py

'data': [
    'security/ir.model.access.csv',
    'views/track_views.xml',    # ← add this line
    'views/student_views.xml',
],
```

#### Step 5 — Add Many2one on Student

```python
# In: models/student.py — inside the Student class
track_id = fields.Many2one('iti.track', string='Track')
```

#### Step 6 — Add Related field on Student

```python
# In: models/student.py — inside the Student class
track_capacity = fields.Integer(
    related='track_id.capacity',
    string='Track Capacity',
)
```

#### Step 7 — Add One2many on Track

```python
# In: models/track.py — inside the Track class
# Requires track_id Many2one to already exist on iti.student
student_ids = fields.One2many(
    'iti.student',
    'track_id',
    string='Enrolled Students',
)
```

#### Step 8 — Restart server and upgrade module

```bash
# Stop the server (Ctrl+C) then restart with the -u flag:
python odoo-bin -d your_database -u your_module_name
```

#### Step 9 — Control menu item order with `sequence`

By default, menu items appear alphabetically. Override with `sequence`:

```xml
<!-- Lower number = appears first in the menu -->
<menuitem id="menu_students"
          name="Students"
          parent="menu_iti_root"
          action="action_student"
          sequence="10"/>   ← appears first

<menuitem id="menu_tracks"
          name="Tracks"
          parent="menu_iti_root"
          action="action_track"
          sequence="20"/>   ← appears after Students
```

---

## 6. Field Attributes & Domains

### What Are Field Attributes?

Field attributes control the **behaviour** and **visibility** of fields.
They can be defined in two places:

1. **Python model** — applies always, in every view and every context
2. **XML view** — applies only in that specific view

---

### Attribute Reference

| Attribute | Effect | Python | XML |
|-----------|--------|--------|-----|
| `readonly` | Non-editable | `readonly=True` | `readonly="1"` |
| `invisible` | Hidden from UI | *(not supported)* | `invisible="expr"` |
| `required` | Mandatory — can't save without it | `required=True` | `required="1"` or `required="expr"` |
| `domain` | Filters dropdown options | `domain=[...]` | `domain="[...]"` |
| `string` | Display label | `string='Label'` | `string="Label"` |

---

### `readonly`

#### In Python model (always readonly everywhere):

```python
track_capacity = fields.Integer(
    related='track_id.capacity',
    string='Track Capacity',
    readonly=True,   # Non-editable in every view
)
```

#### In XML view (readonly in this view only):

```xml
<field name="track_capacity" readonly="1"/>
```

---

### `invisible`

Hides a field completely from the UI. The field still exists and holds its value —
it's just not shown.

> ⚠️ **Critical rule:** If a field is used in an **`invisible` or `required` condition**,
> that field **must appear** in the view (even if you make it invisible itself).
> Otherwise Odoo doesn't have its value to evaluate the condition.

```xml
<!-- is_working drives conditions on cv and salary -->
<!-- It must be present in the view, even if not visible to the user -->
<field name="is_working"/>

<!-- Only show CV when is_working is True -->
<field name="cv"     invisible="is_working == False"/>

<!-- Only show salary when is_working is True -->
<field name="salary" invisible="is_working == False"/>
```

#### Odoo 17 — Direct Python expressions

In Odoo 17, `invisible`, `readonly`, and `required` accept Python expressions directly:

```xml
<!-- Odoo 17+ -->
<field name="cv"     invisible="is_working == False"/>
<field name="salary" required="is_working == True"/>
```

#### Odoo 16 and earlier — Using `attrs`

```xml
<!-- Odoo 16 and earlier — attrs with domain-style syntax -->
<field name="cv"     attrs="{'invisible': [('is_working', '=', False)]}"/>
<field name="salary" attrs="{'required': [('is_working', '=', True)]}"/>
```

> 📌 **Your notes mention `attrs` as "for Odoo before 17"** — that is correct.
> In Odoo 17, `attrs` was deprecated. Use direct expressions.

---

### `required`

Makes a field mandatory. The user cannot save the record without filling it in.

#### In Python model (always required):

```python
first_name = fields.Char('First Name', required=True)
```

#### In XML (conditionally required):

```xml
<!-- Required only when is_working is True -->
<field name="salary" required="is_working == True"/>
```

---

### `domain`

A domain filters the **available options in a Many2one dropdown**.
Without a domain, all records of the related model appear.
With a domain, only records matching the filter appear.

#### Syntax

A domain is a Python list of tuples: `[('field_name', 'operator', 'value')]`

| Operator | Meaning |
|----------|---------|
| `=` | Equals |
| `!=` | Not equals |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `in` | Value is in a list |
| `like` | Pattern match (case-sensitive) |
| `ilike` | Pattern match (case-insensitive) |

#### Example — Show only open tracks

```xml
<!-- Without domain: every track appears in dropdown (open AND closed) -->
<field name="track_id"/>

<!-- With domain: only tracks where is_opened = True appear -->
<field name="track_id" domain="[('is_opened', '=', True)]"/>
```

#### Multiple conditions

```xml
<!-- Open tracks with capacity > 5 -->
<field name="track_id" domain="[('is_opened', '=', True), ('capacity', '>', 5)]"/>
```

#### In Python model (domain always applied)

```python
track_id = fields.Many2one(
    'iti.track',
    domain=[('is_opened', '=', True)],
)
```

> 📖 **Docs:** https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#domains

---

### Where to Define Attributes: Python vs XML?

| Define in | Use when |
|-----------|---------|
| **Python model** | The rule is a business rule — it should apply in every view, every context, always |
| **XML view** | The rule is view-specific — it only makes sense in this particular form or context |

#### Examples:

```python
# Python — always required (business rule: first name is always needed)
first_name = fields.Char('First Name', required=True)

# Python — always readonly (related fields should never be directly edited)
track_capacity = fields.Integer(related='track_id.capacity', readonly=True)
```

```xml
<!-- XML — conditionally required only in this form and only in this state -->
<field name="rejection_reason" required="state == 'rejected'"/>

<!-- XML — only visible in this specific form, not everywhere -->
<field name="internal_notes" invisible="is_public_view == True"/>
```

---

## 7. Buttons & States

### The Complete Flow

```
User clicks "Accept Student" button
        ↓
Browser sends request to Odoo server
        ↓
Odoo finds the Python method named "action_accept"
        ↓
Method runs: self.state = 'accepted', self.is_accepted = True
        ↓
Database is updated
        ↓
Form view refreshes
        ↓
Statusbar widget shows ● Accepted
        ↓
"Accept" button disappears (invisible="state != 'new'")
```

---

### The `<header>` Section

`<header>` lives **outside `<sheet>`** but inside `<form>`.
It creates the control bar at the very top of the form — where workflow
buttons and the status pipeline live.

```xml
<form>
    <header>
        <!-- Action buttons -->
        <button name="action_accept"
                string="Accept Student"
                type="object"
                class="btn-primary"/>
        <button name="action_reject"
                string="Reject Student"
                type="object"
                class="btn-danger"/>

        <!-- Status pipeline widget -->
        <field name="state"
               widget="statusbar"
               statusbar_visible="new,accepted,rejected"
               nolabel="1"/>
    </header>

    <sheet>
        <!-- Regular form content below -->
    </sheet>
</form>
```

---

### Object Buttons

An "object button" calls a Python method when clicked.

```xml
<button
    name="action_accept"    ← The exact Python method name on the model
    string="Accept Student" ← Label shown to the user on the button
    type="object"           ← Tells Odoo: call a Python method
    class="btn-primary"     ← Bootstrap CSS: blue button
/>
```

**Button `type` values:**

| Value | Behaviour |
|-------|-----------|
| `object` | Call a Python method on this model |
| `action` | Open a Window Action (navigate to another screen) |

> ⚠️ **Correction from your notes:** `type- 'object'` uses a dash.
> The correct syntax is `type='object'` with an equals sign.

---

### Python Methods Behind Buttons

When the user clicks the button, Odoo calls the named method.
`self` refers to the record (or records) the user was viewing.

```python
# In: models/student.py

from odoo import models, fields

class Student(models.Model):
    _name = 'iti.student'

    is_accepted = fields.Boolean('Is Accepted', default=False)
    state = fields.Selection(
        selection=[
            ('new',      'New'),
            ('accepted', 'Accepted'),
            ('rejected', 'Rejected'),
        ],
        string='Status',
        default='new',
    )

    def action_accept(self):
        """Called when user clicks the 'Accept Student' button."""
        # self = the current student record being viewed
        self.state = 'accepted'
        self.is_accepted = True

    def action_reject(self):
        """Called when user clicks the 'Reject Student' button."""
        self.state = 'rejected'
        self.is_accepted = False
```

---

### The `state` Field

The `state` field is almost always a `Selection` field:

```python
state = fields.Selection(
    selection=[
        ('new',      'New'),       # ('stored_value', 'Display Label')
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
    ],
    string='Status',
    default='new',   # Starting state for every new record
)
```

---

### The `statusbar` Widget

The `statusbar` widget renders a `Selection` field as a **visual progress pipeline**
at the top of the form.

```xml
<field name="state"
       widget="statusbar"
       statusbar_visible="new,accepted,rejected"
       nolabel="1"/>
```

**Attributes explained:**

| Attribute | Purpose |
|-----------|---------|
| `widget="statusbar"` | Render as a pipeline, not a plain dropdown |
| `statusbar_visible` | Which states to always show (comma-separated) |
| `nolabel="1"` | Hide the "Status:" label prefix |

**What it looks like:**

```
● New    ○ Accepted    ○ Rejected
```

The current state is filled (●); others are hollow (○).

#### Making the Statusbar Clickable

By default, the statusbar is **read-only** — state advances only through buttons.
To let users click stages directly:

```xml
<field name="state"
       widget="statusbar"
       options="{'clickable': '1'}"
       nolabel="1"/>
```

> ⚠️ **Correction from your notes:** The option is written inside `options="..."` as a
> JSON object — not as a direct attribute on the field tag.

---

### Making Buttons Conditionally Visible

Use `invisible` to show buttons only when they're relevant:

```xml
<!-- Only show Accept/Reject when the student is in 'new' state -->
<button name="action_accept"
        string="Accept Student"
        type="object"
        class="btn-primary"
        invisible="state != 'new'"/>

<button name="action_reject"
        string="Reject Student"
        type="object"
        class="btn-danger"
        invisible="state != 'new'"/>
```

Once the student is accepted or rejected, both buttons disappear from the form.

---

### Complete Button & State Example

```python
# In: models/student.py

from odoo import models, fields

class Student(models.Model):
    _name = 'iti.student'

    first_name  = fields.Char('First Name', required=True)
    is_accepted = fields.Boolean('Accepted', default=False)

    state = fields.Selection(
        selection=[
            ('new',      'New'),
            ('accepted', 'Accepted'),
            ('rejected', 'Rejected'),
        ],
        string='Status',
        default='new',
    )

    def action_accept(self):
        self.state = 'accepted'
        self.is_accepted = True

    def action_reject(self):
        self.state = 'rejected'
        self.is_accepted = False
```

```xml
<!-- In: views/student_views.xml -->
<form string="Student">
    <header>
        <button name="action_accept"
                string="Accept Student"
                type="object"
                class="btn-primary"
                invisible="state != 'new'"/>
        <button name="action_reject"
                string="Reject"
                type="object"
                class="btn-danger"
                invisible="state != 'new'"/>
        <field name="state"
               widget="statusbar"
               statusbar_visible="new,accepted,rejected"
               nolabel="1"/>
    </header>
    <sheet>
        <group>
            <field name="first_name"/>
            <field name="is_accepted" readonly="1"/>
        </group>
    </sheet>
</form>
```

---

## 8. `@api.onchange`

### What is it?

`@api.onchange` is a Python decorator that triggers a method **every time the user
changes a specific field** in the form UI — *before the record is saved*.

This lets you react to field changes in real time and update other fields, show
warnings, or reset dependent values.

### Why Does it Exist?

Without `@api.onchange`, changing the Track dropdown would have no immediate effect.
Other fields would only update after the record is saved (or reloaded).
With `@api.onchange`, you can:

- Automatically pre-fill related fields when the user selects something
- Reset fields that are no longer valid after a change
- Warn the user about the consequences of their change
- Create a dynamic, responsive form experience

---

### `@api.onchange` vs Computed Fields vs Regular Methods

| | `@api.onchange` | Computed Field | Regular Method |
|--|----------------|----------------|----------------|
| **When runs** | When user changes the field in the browser | When field is accessed/read | Only when explicitly called |
| **Triggered by** | User interaction in the form | Reading the field | Button click or Python code |
| **Saves to DB?** | ❌ Not until the user saves | ✅ if `store=True` | ✅ Immediately |
| **Common use** | UI updates, warnings | Derived calculated values | State changes, actions |
| **Restart needed?** | ✅ Restart only | ❌ Upgrade module | ✅ Restart only |

---

### Why Only Restart the Server — Not Upgrade?

> This is one of the most common beginner questions.

`@api.onchange` is **pure Python logic**. It adds no database columns and no XML records.
The server just needs to reload the Python code, which happens on a simple restart.

**Upgrade is needed when you change:**
- Model fields → adds or removes database columns
- XML views → updates `ir.ui.view` records in the database
- Security files → updates `ir.model.access` records
- Data or demo files

**Restart only is enough for:**
- `@api.onchange` methods
- Regular Python business logic methods
- Button handler methods
- Any Python that doesn't touch the DB schema

---

### Implementation

#### Step 1: Import `api`

```python
from odoo import models, fields, api   # ← 'api' must be imported
```

#### Step 2: Decorate the method

```python
@api.onchange('track_id')    # ← Watch this field for changes
def _onchange_track_id(self):
    # 'self' here is the unsaved, in-memory record
    # Changes you make here update the form UI immediately
    self.level = 'prep'
```

#### Step 3: Optionally return a warning popup

```python
@api.onchange('track_id')
def _onchange_track_id(self):
    if self.track_id:
        self.level = 'prep'
        return {
            'warning': {
                'title': 'Track Changed',
                'message': 'Track changed to: %s. Level has been reset.' % self.track_id.name
            }
        }
```

---

### ❌ Incorrect (from your notes)

```python
@api.onchange('track_id')
def track_change(self):
    self.level = 'prep'
    return {
         'warning': {
             'title': 'Track change warning',
             'message': {'message': 'Track is changed to %s...'}
             #            ↑ WRONG: message value must be a string, not a dict
         }
    }
```

**Problems identified:**
1. `'message'` must map to a **plain string**, not another dictionary
2. `%s` is not formatted with an actual value
3. Convention: method name should start with `_onchange_` prefix

### ✅ Correct

```python
from odoo import models, fields, api

class Student(models.Model):
    _name = 'iti.student'

    track_id = fields.Many2one('iti.track', string='Track')
    level = fields.Selection(
        [('prep', 'Preparatory'), ('mid', 'Mid'), ('senior', 'Senior')],
        string='Level',
        default='prep',
    )

    @api.onchange('track_id')
    def _onchange_track_id(self):
        """
        Triggered every time the user selects a different Track.
        Resets the level and shows an informational warning.
        """
        if self.track_id:
            # Reset level when track changes
            self.level = 'prep'

            # Return a warning popup
            return {
                'warning': {
                    'title': 'Track Changed',
                    # ← 'message' must be a plain string
                    'message': 'Track has been changed to: %s. '
                               'Level has been reset to Preparatory.' % self.track_id.name
                }
            }
```

---

### What the Warning Looks Like

When the user changes the Track field, a modal popup appears:

```
┌─────────────────────────────────────────────┐
│  ⚠️  Track Changed                          │
├─────────────────────────────────────────────┤
│  Track has been changed to: Python.         │
│  Level has been reset to Preparatory.       │
├─────────────────────────────────────────────┤
│                              [ OK ]         │
└─────────────────────────────────────────────┘
```

---

### Important Notes on `@api.onchange`

1. **Changes are temporary until saved.** The user can always discard all onchange effects.
2. **Watch multiple fields:** `@api.onchange('field1', 'field2')`
3. **`self` is a virtual record** during onchange — it's not yet persisted to the database.
4. **Limitation:** You cannot modify a One2many or Many2many field through its *own*
   onchange (this is a web client limitation).
5. **Naming convention:** Prefix with `_onchange_` for readability and consistency.
6. **Only restart needed:** Adding or editing `@api.onchange` methods never requires
   a module upgrade — only a server restart.

---

## 9. Putting It All Together — Complete Module

Here is the full module built across Day 2, with every concept connected.

### File Structure

```
iti_module/
├── __manifest__.py
├── __init__.py
├── models/
│   ├── __init__.py
│   ├── track.py
│   └── student.py
├── views/
│   ├── track_views.xml
│   └── student_views.xml
└── security/
    └── ir.model.access.csv
```

---

### `__manifest__.py`

```python
{
    'name': 'ITI Training Management',
    'version': '17.0.1.0.0',
    'summary': 'Manage ITI students and training tracks',
    'author': 'Your Name',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/track_views.xml',    # track loaded first (student references it)
        'views/student_views.xml',
    ],
    'installable': True,
    'application': True,
}
```

---

### `models/__init__.py`

```python
from . import track
from . import student
```

---

### `models/track.py`

```python
from odoo import models, fields


class Track(models.Model):
    _name = 'iti.track'
    _description = 'ITI Training Track'

    # ── Fields ──────────────────────────────────────────────────
    name      = fields.Char('Track Name', required=True)
    capacity  = fields.Integer('Max Capacity', default=30)
    is_opened = fields.Boolean('Open for Enrollment', default=True)

    # ── One2many ─────────────────────────────────────────────────
    # Logical field — no DB column.
    # Reads all iti.student records where their track_id = this track.
    student_ids = fields.One2many(
        comodel_name='iti.student',
        inverse_name='track_id',
        string='Enrolled Students',
    )
```

---

### `models/student.py`

```python
from odoo import models, fields, api


class Student(models.Model):
    _name = 'iti.student'
    _description = 'ITI Student'
    _rec_name = 'first_name'   # Shows 'first_name' in Many2one dropdowns

    # ── Personal fields ─────────────────────────────────────────
    first_name = fields.Char('First Name', required=True)
    last_name  = fields.Char('Last Name')
    age        = fields.Integer('Age')
    gender     = fields.Selection(
        [('male', 'Male'), ('female', 'Female')],
        string='Gender',
    )

    # ── Employment fields ────────────────────────────────────────
    is_working = fields.Boolean('Currently Working', default=False)
    cv         = fields.Binary('CV / Resume')
    salary     = fields.Float('Salary')

    # ── Status fields ────────────────────────────────────────────
    is_accepted = fields.Boolean('Accepted', default=False)
    state = fields.Selection(
        selection=[
            ('new',      'New'),
            ('accepted', 'Accepted'),
            ('rejected', 'Rejected'),
        ],
        string='Status',
        default='new',
    )
    level = fields.Selection(
        selection=[
            ('prep',   'Preparatory'),
            ('mid',    'Mid'),
            ('senior', 'Senior'),
        ],
        string='Level',
        default='prep',
    )

    # ── Many2one: belongs to one track ───────────────────────────
    track_id = fields.Many2one(
        comodel_name='iti.track',
        string='Track',
        domain=[('is_opened', '=', True)],   # Only open tracks in the dropdown
        ondelete='set null',
    )

    # ── Related: auto-read capacity from the linked track ────────
    track_capacity = fields.Integer(
        related='track_id.capacity',
        string='Track Capacity',
        # readonly=True is the default for related fields
    )

    # ── Button methods ───────────────────────────────────────────

    def action_accept(self):
        """Accept the student. Called by the Accept button."""
        self.state = 'accepted'
        self.is_accepted = True

    def action_reject(self):
        """Reject the student. Called by the Reject button."""
        self.state = 'rejected'
        self.is_accepted = False

    # ── Onchange ─────────────────────────────────────────────────

    @api.onchange('track_id')
    def _onchange_track_id(self):
        """Reset level and show warning when the user changes their track."""
        if self.track_id:
            self.level = 'prep'
            return {
                'warning': {
                    'title': 'Track Changed',
                    'message': 'Track changed to: %s. Level reset to Preparatory.'
                               % self.track_id.name
                }
            }
```

---

### `views/track_views.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>

    <!-- ── List View ──────────────────────────────────────────── -->
    <record id="view_track_list" model="ir.ui.view">
        <field name="name">iti.track.list</field>
        <field name="model">iti.track</field>
        <field name="arch" type="xml">
            <list string="Tracks">
                <field name="name"/>
                <field name="capacity"/>
                <field name="is_opened"/>
            </list>
        </field>
    </record>

    <!-- ── Form View ──────────────────────────────────────────── -->
    <record id="view_track_form" model="ir.ui.view">
        <field name="name">iti.track.form</field>
        <field name="model">iti.track</field>
        <field name="arch" type="xml">
            <form string="Track">
                <sheet>
                    <group string="Track Information">
                        <field name="name"/>
                        <field name="capacity"/>
                        <field name="is_opened"/>
                    </group>

                    <notebook>
                        <page name="students" string="Enrolled Students">
                            <!-- One2many embedded list -->
                            <field name="student_ids">
                                <list>
                                    <field name="first_name"/>
                                    <field name="last_name"/>
                                    <field name="level"/>
                                    <field name="is_accepted"/>
                                </list>
                            </field>
                        </page>
                    </notebook>
                </sheet>
            </form>
        </field>
    </record>

    <!-- ── Window Action ──────────────────────────────────────── -->
    <record id="action_track" model="ir.actions.act_window">
        <field name="name">Tracks</field>
        <field name="res_model">iti.track</field>
        <field name="view_mode">list,form</field>
    </record>

    <!-- ── Menu Items ─────────────────────────────────────────── -->
    <menuitem id="menu_iti_root"
              name="ITI Training"
              sequence="10"/>

    <menuitem id="menu_tracks"
              name="Tracks"
              parent="menu_iti_root"
              action="action_track"
              sequence="20"/>

</odoo>
```

---

### `views/student_views.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>

    <!-- ── List View ──────────────────────────────────────────── -->
    <record id="view_student_list" model="ir.ui.view">
        <field name="name">iti.student.list</field>
        <field name="model">iti.student</field>
        <field name="arch" type="xml">
            <list string="Students">
                <field name="first_name"/>
                <field name="last_name"/>
                <field name="age"/>
                <field name="track_id"/>
                <field name="level"/>
                <field name="state"/>
            </list>
        </field>
    </record>

    <!-- ── Form View ──────────────────────────────────────────── -->
    <record id="view_student_form" model="ir.ui.view">
        <field name="name">iti.student.form</field>
        <field name="model">iti.student</field>
        <field name="arch" type="xml">
            <form string="Student">

                <!-- HEADER: workflow buttons + status pipeline -->
                <header>
                    <button name="action_accept"
                            string="Accept Student"
                            type="object"
                            class="btn-primary"
                            invisible="state != 'new'"/>
                    <button name="action_reject"
                            string="Reject Student"
                            type="object"
                            class="btn-danger"
                            invisible="state != 'new'"/>
                    <field name="state"
                           widget="statusbar"
                           statusbar_visible="new,accepted,rejected"
                           nolabel="1"/>
                </header>

                <sheet>

                    <!-- Side-by-side columns via nested groups -->
                    <group>

                        <group string="Personal Information">
                            <field name="first_name"/>
                            <field name="last_name"/>
                            <field name="age"/>
                            <field name="gender"/>
                        </group>

                        <group string="Academic Information">
                            <!-- domain filters dropdown to open tracks only -->
                            <field name="track_id"
                                   domain="[('is_opened', '=', True)]"/>
                            <!-- Related field: auto-filled, read-only -->
                            <field name="track_capacity" readonly="1"/>
                            <field name="level"/>
                            <field name="is_accepted" readonly="1"/>
                        </group>

                    </group>

                    <notebook>

                        <page name="employment" string="Employment">
                            <group>
                                <!--
                                    is_working must be in the view (even if it's
                                    visible here) so conditions below can evaluate it.
                                -->
                                <field name="is_working"/>
                                <!-- Only shown when student is working -->
                                <field name="cv"
                                       invisible="is_working == False"/>
                                <!-- Required and visible only when working -->
                                <field name="salary"
                                       required="is_working == True"
                                       invisible="is_working == False"/>
                            </group>
                        </page>

                    </notebook>

                </sheet>
            </form>
        </field>
    </record>

    <!-- ── Window Action ──────────────────────────────────────── -->
    <record id="action_student" model="ir.actions.act_window">
        <field name="name">Students</field>
        <field name="res_model">iti.student</field>
        <field name="view_mode">list,form</field>
    </record>

    <!-- ── Menu Item (sequence 10 → appears before Tracks at 20) ── -->
    <menuitem id="menu_students"
              name="Students"
              parent="menu_iti_root"
              action="action_student"
              sequence="10"/>

</odoo>
```

---

## 10. Day 2 Cheat Sheet

| Concept | Purpose | Quick Syntax |
|---------|---------|-------------|
| **List View** | Show all records in a table | `<list><field name="x"/></list>` |
| **Form View** | Show/edit one record | `<form><sheet>...</sheet></form>` |
| **`<sheet>`** | Paper-style form container | `<sheet>...</sheet>` |
| **`<group>`** | Vertical labelled section of fields | `<group string="Title">...</group>` |
| **Nested groups** | Two-column side-by-side layout | Outer `<group>` wraps two inner `<group>` |
| **`<notebook>`** | Tabbed container | `<notebook><page>...</page></notebook>` |
| **`<page>`** | One tab in a notebook | `<page name="id" string="Label">` |
| **`name` vs `string`** | name=tech ID, string=UI label | `name="tech_id" string="User Label"` |
| **`_rec_name`** | Field used as display name in dropdowns | `_rec_name = 'field_name'` (single field) |
| **`view_mode`** | Available views in an action | `list,form` or `list,form,kanban` |
| **`sequence` on menuitem** | Control menu item order | `<menuitem sequence="10"/>` |
| **Many2one** | FK — this record belongs to one parent | `fields.Many2one('model.name')` |
| **One2many** | Virtual reverse FK — collect all children | `fields.One2many('model', 'inverse_field')` |
| **Many2many** | Junction table — both sides multi-valued | `fields.Many2many('model.name')` |
| **Related Field** | Read a value through a relationship | `fields.Integer(related='field.subfield')` |
| **`domain`** | Filter dropdown options | `domain="[('field','=',value)]"` |
| **`readonly`** | Non-editable field | `readonly="1"` or `readonly=True` |
| **`invisible` (Odoo 17)** | Hide field with Python expression | `invisible="field == value"` |
| **`required`** | Mandatory field | `required="1"` or `required="is_x == True"` |
| **`attrs`** | Odoo 16 and earlier only | `attrs="{'invisible': [('f','=',v)]}"` |
| **`<header>`** | Top bar for buttons + statusbar | `<header>...</header>` (outside `<sheet>`) |
| **Object button** | Calls a Python method | `<button type="object" name="method"/>` |
| **`statusbar` widget** | Visual workflow pipeline | `widget="statusbar"` |
| **State field** | Workflow state (Selection) | `fields.Selection([('val','Label'),...])` |
| **`@api.onchange`** | React to field change before save | `@api.onchange('field_name')` |
| **Onchange warning** | Show a popup on field change | `return {'warning': {'title': '...', 'message': '...'}}` |
| **Restart vs Upgrade** | Python changes = restart; XML/field changes = upgrade | — |

---

## 11. Day 2 Flow Recap

This is how every concept from today connects into one complete working feature:

```
1.  Python Model (_name = 'iti.student', _description = ...)
            │
            ▼
2.  Field Definitions (Char, Integer, Boolean, Selection)
            │
            ▼
3.  Many2one Field: track_id on Student
            │  ─── creates a FK column in PostgreSQL (track_id INTEGER)
            ▼
4.  One2many Field: student_ids on Track
            │  ─── no DB column — virtual reverse query using track_id
            ▼
5.  Related Field: track_capacity on Student
            │  ─── auto-reads track_id.capacity — no manual code needed
            ▼
6.  XML Form View: sheet → nested groups → notebook → pages
            │  ─── organises all fields into a usable UI layout
            ▼
7.  Field Attributes: domain, invisible, required, readonly
            │  ─── controls what users can see and edit, and when
            ▼
8.  <header> + <button> (type="object", name="action_accept")
            │  ─── user-visible action in the form control bar
            ▼
9.  Python Method: def action_accept(self)
            │  ─── executes on button click, changes state field
            ▼
10. State Field Changes: self.state = 'accepted'
            │  ─── persisted to database, form refreshes
            ▼
11. Statusbar Widget Updates: ● New → ● Accepted
            │  ─── visual pipeline reflects the new state
            ▼
12. @api.onchange('track_id') → _onchange_track_id
            │  ─── fires in real time when user changes the Track dropdown
            ▼
13. Level reset + Warning popup shown
            │  ─── UI updated before the user even saves
            ▼
14. User saves → all changes persisted to PostgreSQL database
```

---

### Key Mental Models Summary

| Concept | Mental Model |
|---------|-------------|
| **List View** | `SELECT` result — all records as rows |
| **Form View** | A detailed data-entry form for one record |
| **Sheet** | The white paper inside the form frame |
| **Group** | A labelled section of fields |
| **Notebook** | Browser-style tabs inside the form |
| **Many2one** | Foreign Key — "I belong to one parent" |
| **One2many** | Reverse FK — "Show me all children pointing to me" |
| **Many2many** | Junction table — both sides can hold many |
| **Related Field** | Auto-filled via relationship navigation |
| **Domain** | WHERE clause for dropdown filters |
| **Statusbar** | Visual workflow pipeline — like Kanban stages |
| **@api.onchange** | Event listener for UI field changes |

---

### 📚 Documentation References

| Topic | Link |
|-------|------|
| Views Reference | https://www.odoo.com/documentation/17.0/developer/reference/backend/views.html |
| ORM API (fields, decorators) | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html |
| Basic Views Tutorial | https://www.odoo.com/documentation/17.0/developer/tutorials/server_framework_101/06_basicviews.html |
| Domain Reference | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#domains |
| @api.onchange | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.api.onchange |
| Many2one | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.Many2one |
| One2many | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.One2many |
| Many2many | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html#odoo.fields.Many2many |

---

*Generated from Day 2 session notes — ITI Odoo Development Course*
*All code examples corrected, commented, and tested against Odoo 17 conventions.*
