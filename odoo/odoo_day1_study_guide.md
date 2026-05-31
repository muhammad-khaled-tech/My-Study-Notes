# Odoo Day 1 Study Guide — Complete Beginner's Reference

> **About this guide:** Generated from live session notes and enriched with official Odoo documentation.  
> **Target version:** Odoo 17 (concepts apply to Odoo 18 as well)  
> **Level:** Absolute beginner — no prior ERP or Odoo knowledge required.

---

## Table of Contents

1. [What Is ERP? Why Does It Matter?](#1-what-is-erp-why-does-it-matter)
2. [History of Odoo](#2-history-of-odoo)
3. [Why Odoo?](#3-why-odoo)
4. [The Odoo Ecosystem & Technology Stack](#4-the-odoo-ecosystem--technology-stack)
5. [Odoo Configuration (odoo.conf)](#5-odoo-configuration-odooconf)
6. [Installation on Ubuntu](#6-installation-on-ubuntu)
7. [Creating Your First Module](#7-creating-your-first-module)
8. [Database Models (The M in MVC)](#8-database-models-the-m-in-mvc)
9. [Menus and Actions (The V + C in MVC)](#9-menus-and-actions-the-v--c-in-mvc)
10. [How Everything Connects: The Full Picture](#10-how-everything-connects-the-full-picture)
11. [Quick Reference Cheat Sheet](#11-quick-reference-cheat-sheet)

---

## 1. What Is ERP? Why Does It Matter?

### The Problem Before ERP

Imagine a company where:
- HR keeps employee records in **one Excel sheet**
- Finance tracks salaries in **another Excel sheet**
- The project manager uses **a third tool** for task tracking

When a new employee joins, HR updates their sheet — but Finance still uses the old one, and the project manager doesn't know the person even exists yet. **There is no single source of truth.** Data is scattered, duplicated, and out of sync.

### What ERP Solves

**ERP (Enterprise Resource Planning)** is business management software that brings all departments into **one shared system with one shared database**.

```
New Employee Hired
      │
      ▼
 Single Action in Odoo
      │
      ├──► HR Module updated automatically
      ├──► Payroll/Salary Module updated automatically
      ├──► Project Module notified automatically
      └──► Leave/Holiday Module configured automatically
```

**One action → multiple automatic updates across the whole system.** This is the core value of an ERP.

> 💡 **Key Concept:** A database (db) here means a structured place to store all company data. Think of it like a giant organized spreadsheet that all departments share and read from simultaneously.

---

## 2. History of Odoo

> 📖 Reference: [Odoo — Wikipedia](https://en.wikipedia.org/wiki/Odoo)

| Year | Name | Milestone |
|------|------|-----------|
| 2002–2004 | *(unnamed)* | Fabien Pinckaers, a Belgian computer science student, starts developing business apps for personal use |
| 2005 | **TinyERP** | Released as open-source software. Lightweight ERP focused on small businesses |
| 2008 | **OpenERP** | Rebranded to reflect a more professional, enterprise-ready platform |
| 2010 | OpenERP | Grew to 100+ employees. Raised €3M in funding. Expanded internationally |
| 2013 | OpenERP | Shifted to **Open Core model**: free Community edition + paid Enterprise edition |
| 2014 | **Odoo** | Renamed "Odoo" to move beyond the ERP label and emphasize the full business suite |
| Today | Odoo | 16+ million users, 120+ countries, 4,000+ employees, 7 million+ app installs |

### Key Takeaways

- Odoo was created by **Fabien Pinckaers** (still CEO today).
- The name evolution: **TinyERP → OpenERP → Odoo**
- Odoo's mission from day one: make business software **affordable, open, and accessible** — even for small businesses that couldn't afford SAP.
- There are two editions:
  - **Community (CE):** Free and open-source
  - **Enterprise (EE):** Paid, includes extra modules and cloud hosting (Odoo.sh)

> ⚠️ **Common Misconception:** The session notes say "renamed in 2010" but the actual rename to *Odoo* happened in **2014** (version 8). In 2010, it was still *OpenERP* — though that's when the company grew significantly.

---

## 3. Why Odoo?

### Odoo Is More Than an ERP

> 📖 Reference: [Odoo Developer Documentation](https://www.odoo.com/documentation/17.0/developer.html)

Your notes correctly identify this: **"Odoo is a framework to build business systems."**

Unlike rigid enterprise software like SAP, Odoo is:

- **Modular:** Install only what you need (Sales, HR, Accounting, Inventory, etc.)
- **Extensible:** Build your own custom modules on top of the framework
- **Open-source:** The Community edition is freely available on GitHub
- **Integrated:** All modules share the same database — no sync issues
- **Full-stack:** Handles front-end, back-end, and database all in one

### The "Single Source of Truth" Philosophy

Before Odoo (siloed approach):

```
Employees DB  ←──  No connection  ──→  Finance DB
Inventory DB  ←──  No connection  ──→  Sales DB
```

With Odoo (integrated approach):

```
         ┌──────────────────────────────────┐
         │         ONE PostgreSQL DB        │
         └──┬──────┬──────┬──────┬──────────┘
            │      │      │      │
           HR   Finance  Sales  Inventory
```

All modules read and write to the **same database** — a change in one place reflects everywhere immediately.

---

## 4. The Odoo Ecosystem & Technology Stack

> 📖 Reference: [Odoo Developer Overview](https://www.odoo.com/documentation/17.0/developer.html)

Your notes asked: **"What are the aims of each component?"** Here is the full answer:

```
Browser (User)
     │  HTTP requests
     ▼
 WSGI Server (Gunicorn/Odoo's built-in server)
     │  Routes requests
     ▼
 Python (Odoo Framework / ORM)
     │  Business logic, models, views
     ▼
 PostgreSQL (Database)
     │  Stores all data
     ▼
 Node.js / npm
     │  Bundles frontend assets (JS, CSS)
     ▼
 XML / HTML / OWL (JavaScript framework)
        UI templates and components
```

### Component Breakdown

| Component | Role | Analogy |
|-----------|------|---------|
| **PostgreSQL** | Relational database that stores all company data | The filing cabinet |
| **Python** | The main programming language for all business logic and the ORM | The manager who handles all decisions |
| **ORM** (Object Relational Mapper) | Translates Python class definitions into SQL database tables automatically — no raw SQL needed | A translator between Python and the database |
| **Node.js / npm** | Compiles and bundles JavaScript and CSS assets (frontend dependencies) | The construction crew for the UI |
| **WSGI Server** | "Web Server Gateway Interface" — the standard interface between Python web apps and web servers. Handles incoming HTTP requests | The receptionist who routes calls |
| **XML / HTML** | Defines the structure of menus, views, and UI elements in Odoo | The blueprint of the interface |

> 💡 **What is WSGI?** WSGI stands for *Web Server Gateway Interface*. It's a Python standard (PEP 3333) that defines how a web server (like Nginx) communicates with a Python application (like Odoo). You don't need to configure this manually — Odoo handles it internally.

> 💡 **What is ORM?** ORM (Object Relational Mapper) lets you work with the database using Python classes instead of writing SQL queries. When you define a Python class in Odoo, the ORM automatically creates the corresponding database table.

---

## 5. Odoo Configuration (odoo.conf)

> 📖 Reference: [Odoo Configuration Documentation](https://www.odoo.com/documentation/17.0/administration/install/deploy.html)

This is **the most important file** for setting up Odoo. Your notes correctly note: *"most issues occur on this part."*

### Where Is the Config File?

| Installation Type | Default Path |
|-------------------|--------------|
| Ubuntu/Debian package | `/etc/odoo/odoo.conf` |
| Manual install | You create it yourself |
| Docker | Passed via environment variables or mounted file |

### The Configuration File Explained

```ini
[options]

; ─── DATABASE CONNECTION ───────────────────────────────────────────────
; Which server is PostgreSQL running on?
; Use False if PostgreSQL is on the same machine (uses faster Unix socket)
db_host = False

; Which port is PostgreSQL running on?
; Default PostgreSQL port is 5432. Use False for local socket connection.
db_port = False

; The PostgreSQL user that Odoo will use to interact with the database.
; This user must have privileges to CREATE tables, INSERT data, etc.
db_user = odoo

; Password for the db_user above.
db_password = False

; If you want Odoo to always open a specific database, set it here.
; Set to False so users can see a database selector on the login page.
; IMPORTANT: The database must already exist in PostgreSQL before setting this.
db_name = False

; Filter which databases are visible by name (uses Regular Expression).
; Example: "^mycompany" only shows databases starting with "mycompany".
dbfilter =

; ─── NETWORK ───────────────────────────────────────────────────────────
; The port Odoo's web interface runs on. Default is 8069.
; Access via: http://localhost:8069
http_port = 8069

; ─── MODULES ────────────────────────────────────────────────────────────
; Comma-separated list of directories where Odoo searches for modules.
; Always include the default Odoo addons path PLUS your custom addons path.
; Example: /opt/odoo17/addons,/opt/odoo17/custom-addons
addons_path = /opt/odoo17/addons

; ─── SECURITY ────────────────────────────────────────────────────────────
; Master password required to Create, Drop, Backup, or Restore databases
; via the Database Manager at http://localhost:8069/web/database/manager
; IMPORTANT: Change this from the default! A weak password here is a huge risk.
admin_passwd = my_secure_master_password
```

### Quick Parameter Reference Table

| Parameter | What It Does | Common Value |
|-----------|-------------|--------------|
| `db_host` | PostgreSQL server address | `False` (local) |
| `db_port` | PostgreSQL port | `False` (local) or `5432` |
| `db_user` | DB username for Odoo | `odoo` |
| `db_password` | DB user password | your password |
| `db_name` | Lock Odoo to one DB | `False` (show selector) |
| `dbfilter` | Filter DB list by name pattern | leave empty or use regex |
| `http_port` | Odoo web interface port | `8069` |
| `addons_path` | Where to find modules | `/opt/odoo17/addons,...` |
| `admin_passwd` | Master password for DB management | change this immediately! |

> ⚠️ **Beginner Mistake #1:** Setting `db_name` to a database name that doesn't exist yet in PostgreSQL. The database **must be created first** before Odoo can use it.

> ⚠️ **Beginner Mistake #2:** Leaving `admin_passwd = admin`. This controls the ability to delete your entire database. Always change it.

> ⚠️ **Beginner Mistake #3:** Forgetting to add your custom addons path to `addons_path`. If your module folder isn't listed here, Odoo will never find your module.

---

## 6. Installation on Ubuntu

> 📖 Reference: [Odoo 17 Install Guide](https://www.odoo.com/documentation/17.0/administration/install/install.html)

Your notes contain the correct installation commands. Here they are with explanations:

```bash
# ─── Step 1: Install and start PostgreSQL ────────────────────────────
# PostgreSQL is the database engine Odoo requires
sudo apt install postgresql -y

# Start the PostgreSQL service now
sudo systemctl start postgresql

# Enable it so it starts automatically on every system reboot
sudo systemctl enable postgresql

# ─── Step 2: Add the official Odoo 17 package repository ─────────────
# Download and register Odoo's GPG key (verifies packages are authentic)
wget -O - https://nightly.odoo.com/odoo.key | sudo gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg

# Add the Odoo 17 nightly repository to your apt sources
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/17.0/nightly/deb/ ./" | sudo tee /etc/apt/sources.list.d/odoo.list

# ─── Step 3: Install Odoo ─────────────────────────────────────────────
# Update package lists, then install Odoo
sudo apt-get update && sudo apt-get install odoo

# ─── Step 4: Start Odoo ──────────────────────────────────────────────
# Start the Odoo service
sudo systemctl start odoo

# Enable it so it starts automatically on reboot
sudo systemctl enable odoo

# ─── Step 5: Access Odoo in your browser ─────────────────────────────
# Open: http://localhost:8069
```

### Alternative: Docker (Recommended for Beginners)

If you run into issues during installation (very common), Docker is much easier:

```bash
# Pull and run Odoo 17 with PostgreSQL using Docker Compose
# Official Docker images: https://hub.docker.com/_/odoo
```

> 💡 **Restarting Odoo after changes (Linux):**
> ```bash
> sudo systemctl restart odoo
> ```
> You must restart the Odoo server every time you:
> - Add or modify a Python file (models)
> - Change the configuration file

---

## 7. Creating Your First Module

> 📖 Reference: [Module Manifests — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/reference/backend/module.html)  
> 📖 Reference: [Building a Module — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/tutorials/backend.html)

### What Is a Module?

**A module (also called an addon/app) is the basic unit of Odoo customization.** Everything in Odoo is a module — HR, Accounting, Sales — even the core system is a module called `base`.

Every module you build **depends on `base`** by default, which is why it appears in the UI automatically once installed.

### The MVC Architecture

Before looking at files, understand that Odoo follows **MVC (Model-View-Controller)**:

```
Model      → Python class → defines the data structure (your database table)
View       → XML file     → defines what the user sees (forms, lists, menus)
Controller → Odoo handles this mostly automatically
```

As a beginner, you'll mainly work with **Models** and **Views**.

### Module Folder Structure

```
iti_smart/                    ← Your module folder (name = your module's technical name)
│
├── __manifest__.py           ← Module "ID card" — tells Odoo this is a valid module
├── __init__.py               ← Python package entry point — imports all sub-folders
│
├── models/                   ← All business logic and database table definitions
│   ├── __init__.py           ← Imports all Python model files in this folder
│   └── iti_student.py        ← Your Student model (one model per file, best practice)
│
└── views/                    ← All XML files for UI (menus, actions, form layouts)
    └── iti_student_views.xml ← Menus and actions for the Student model
```

### Step 1: Create the Module Folder

Place your module inside a folder that is listed in `addons_path` in your config file.

```bash
# Example: create the module under a custom addons directory
mkdir -p /opt/odoo17/custom-addons/iti_smart
mkdir -p /opt/odoo17/custom-addons/iti_smart/models
mkdir -p /opt/odoo17/custom-addons/iti_smart/views
```

### Step 2: `__manifest__.py` — The Module ID Card

> ⚠️ **Important:** The file is named `__manifest__.py` (with double underscores on each side), not `manifest.py`. Your notes wrote `manifest.py` — this is a common mistake!

```python
# __manifest__.py
# This file declares your Python folder as a valid Odoo module.
# It is a plain Python dictionary with module metadata.

{
    # REQUIRED: The human-readable name shown in the Odoo Apps menu
    'name': 'ITI Smart',

    # Module version (follow: major.minor.patch convention)
    'version': '17.0.1.0.0',

    # Modules this module depends on. 'base' is always required.
    # If you use fields from another module (e.g. 'mail'), add it here.
    'depends': ['base'],

    # Author info
    'author': 'Your Name',

    # Short description shown in the Apps menu
    'summary': 'ITI Student Management Module',

    # XML and CSV data files to load when the module is installed/updated.
    # The order matters — always declare actions BEFORE menuitems.
    'data': [
        'views/iti_student_views.xml',
    ],

    # Makes the module appear as a full App (with icon) in the Apps menu
    'application': True,

    # Allows installation via the UI
    'installable': True,
}
```

### Step 3: `__init__.py` (Root Level) — The Package Entry Point

> 💡 **What is `__init__.py`?** Python uses this file to recognize a folder as a "package" (a collection of Python files that can be imported). Without it, Python ignores the folder.

```python
# iti_smart/__init__.py
# Import the models folder so Python loads all model files inside it.
from . import models
```

### Step 4: `models/__init__.py` — Import Your Model Files

```python
# iti_smart/models/__init__.py
# Import each model file you create inside the models folder.
# This tells Python to load the Student model when the module loads.
from . import iti_student
```

### Step 5: How to Install Your Module in Odoo UI

1. **Restart the Odoo server** (required after adding new files):
   ```bash
   sudo systemctl restart odoo
   ```

2. **Activate Developer Mode** (do this once at the beginning):
   - Go to `Settings` → scroll to bottom → click **Activate Developer Mode**
   - Or visit: `http://localhost:8069/web?debug=1`

3. **Update the App List:**
   - Go to `Apps` menu → click **Update Apps List** button
   - This makes Odoo re-scan all `addons_path` directories for new modules

4. **Search for your module:**
   - In the Apps search bar, search for `ITI` (or whatever your module name is)
   - Click **Install**

> ⚠️ **Beginner Mistake:** Searching for the module without restarting the server or updating the app list first. Always do both steps after adding a new module.

> 💡 **Become Superuser:** In Developer Mode, you'll see a "Become Superuser" button. Click it to get full admin access, which is needed during development.


### Alternative: Scaffold via Command Line

> ⚠️ **Not recommended for Day 1.** Scaffolding auto-generates the structure
> but skips understanding *why* each file exists. Learn the manual approach first.

Odoo has a built-in command that generates the module skeleton automatically:

```bash
odoo-bin scaffold <module_name> <path_to_addons_folder>

# Example:
odoo-bin scaffold iti_smart /opt/odoo17/custom-addons/
```

It creates extra folders (`controllers`, `demo`, `security`) you don't need yet —
safely ignore them for now and focus on `models/` and `views/`.

> 📖 [Scaffold command — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/tutorials/backend.html)
---

## 8. Database Models (The M in MVC)

> 📖 Reference: [ORM API — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html)

### What Is a Model?

**A model is a Python class that defines your database table structure.** When Odoo loads your model, the ORM automatically:
- Creates the table in PostgreSQL
- Handles all SQL (INSERT, SELECT, UPDATE, DELETE) for you
- Adds built-in fields like `id`, `create_date`, `write_date`, `create_uid`

### The Student Model — Full Example

```python
# iti_smart/models/iti_student.py

# Import the base classes from Odoo's ORM
from odoo import models, fields


class Student(models.Model):
    """
    The Student model — represents the 'iti_student' table in PostgreSQL.
    Each attribute below (fields.Char, fields.Integer, etc.) becomes a column in the table.
    """

    # _name is REQUIRED. It is the unique technical identifier for this model.
    # Convention: use dot notation with your module prefix, e.g. 'iti.student'
    # This also becomes the table name in PostgreSQL: iti_student (dots → underscores)
    _name = 'iti.student'

    # _description is a human-readable label for the model (shows in Settings > Technical > Models)
    _description = 'ITI Student'

    # ─── FIELDS (= database columns) ─────────────────────────────────────────

    # Char: stores a short text string (like VARCHAR in SQL)
    # The first argument is the field label shown in the UI
    name = fields.Char('Name', required=True)

    # Integer: stores a whole number
    age = fields.Integer('Age')

    # Date: stores a date (YYYY-MM-DD)
    birth_date = fields.Date('Birth Date')

    # Float: stores a decimal number — perfect for money, measurements
    salary = fields.Float('Salary')

    # Selection: creates a dropdown list of fixed choices
    # Format: [('stored_value', 'Displayed Label'), ...]
    gender = fields.Selection([
        ('male', 'Male'),
        ('female', 'Female'),
    ], string='Gender')

    # Html: stores rich text content (like a text editor / WYSIWYG field)
    cv = fields.Html('CV / Resume')

    # Boolean: stores True or False (a checkbox in the UI)
    is_accepted = fields.Boolean('Is Accepted?')
```

### Common Field Types Reference

| Field Type | Use Case | UI Widget |
|------------|----------|-----------|
| `fields.Char` | Short text (name, phone, email) | Text input |
| `fields.Text` | Long plain text | Multi-line text area |
| `fields.Html` | Rich formatted text | HTML editor |
| `fields.Integer` | Whole numbers (age, quantity) | Number input |
| `fields.Float` | Decimal numbers (salary, price) | Decimal input |
| `fields.Boolean` | Yes/No flag | Checkbox |
| `fields.Date` | Date without time | Date picker |
| `fields.Datetime` | Date + time | Date-time picker |
| `fields.Selection` | Fixed list of choices | Dropdown |
| `fields.Many2one` | Link to another model (foreign key) | Search/dropdown |
| `fields.One2many` | One-to-many relationship | Inline table |
| `fields.Many2many` | Many-to-many relationship | Tag selector |

### Automatic (Inherited) Fields

Odoo automatically adds these fields to **every** model — you don't define them:

| Auto Field | Description |
|------------|-------------|
| `id` | Unique record ID (auto-increment) |
| `create_date` | When the record was created |
| `create_uid` | Who created the record |
| `write_date` | When the record was last modified |
| `write_uid` | Who last modified the record |
| `display_name` | Computed display name (based on `name` field by default) |

### How to Verify Your Model Was Created

After installing your module:

1. Go to `Settings` (with Developer Mode on)
2. In the top menu, click **Technical → Database Structure → Models**
3. Search for `iti.student`

You should see your model and all its fields listed there.

> ⚠️ **Beginner Mistake #1:** Writing `_name = 'Student'` instead of `_name = 'iti.student'`. Model names should follow the `module.modelname` dot notation convention. Odoo converts dots to underscores for the actual table name.

> ⚠️ **Beginner Mistake #2:** Writing `fields.Char` with a capital `S` in `Selection` vs lowercase in `Char`. The correct class is `fields.Selection` — always check capitalization.

> ⚠️ **Beginner Mistake #3:** Forgetting to restart the server after modifying a Python model file. **Python changes always require a server restart.**

---

## 9. Menus and Actions (The V + C in MVC)

> 📖 Reference: [Actions — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/reference/backend/actions.html)  
> 📖 Reference: [Views — Odoo 17 Docs](https://www.odoo.com/documentation/17.0/developer/reference/backend/views.html)

### The Concept: Action → Menu → UI

A **menu item** in Odoo is just a button in the navigation bar. When a user clicks it, it triggers an **action**. The most common action is `ir.actions.act_window`, which opens a model's records in a list or form view.

```
User clicks Menu Item
        │
        ▼
   Action triggered  (ir.actions.act_window)
        │
        ▼
   Opens View of Model  (list + form of iti.student)
        │
        ▼
   User sees/edits records
```

### Step 1: Add the Views File to `__manifest__.py`

Before creating the XML file, register it in your manifest's `data` list:

```python
# __manifest__.py
{
    ...
    'data': [
        'views/iti_student_views.xml',   # XML file with menus and actions
    ],
}
```

> ⚠️ **Critical Rule:** Inside the XML file, always define the **action BEFORE the menuitem** that links to it. Odoo reads XML files sequentially — a menuitem cannot reference an action that hasn't been defined yet.

### Step 2: Create `views/iti_student_views.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <!-- ══════════════════════════════════════════════════════
             ACTION — Defines WHAT happens when the menu is clicked.
             model="ir.actions.act_window" means: open a window view.
             ══════════════════════════════════════════════════════ -->
        <record id="action_iti_student" model="ir.actions.act_window">
            <!-- The label displayed in the breadcrumb and window title -->
            <field name="name">Students</field>

            <!-- The model whose records this action displays.
                 MUST match the _name attribute in your Python model exactly. -->
            <field name="res_model">iti.student</field>

            <!-- Which views to show, in order.
                 'list,form' = show list first; clicking a row opens a form.
                 In Odoo 17+, 'tree' was renamed to 'list'. -->
            <field name="view_mode">list,form</field>
        </record>


        <!-- ══════════════════════════════════════════════════════
             MENU STRUCTURE — Defines the navigation hierarchy.
             ══════════════════════════════════════════════════════ -->

        <!-- TOP-LEVEL MENU: appears in the main app bar (no parent, no action) -->
        <menuitem
            id="menu_iti_root"
            name="ITI"
        />

        <!-- CHILD MENU: appears inside the ITI menu.
             parent= links it to the top-level menu above.
             action= links it to the action record above (by id).
             This is what makes clicking the menu open your Student list. -->
        <menuitem
            id="menu_iti_students"
            name="Students"
            parent="menu_iti_root"
            action="action_iti_student"
        />

    </data>
</odoo>
```

### Understanding the XML Tags

| Tag / Attribute | Meaning |
|-----------------|---------|
| `<record id="..." model="ir.actions.act_window">` | Creates a new action record in Odoo's database |
| `id` | **Must be unique** within the module. Used to reference this record from other places |
| `model="ir.actions.act_window"` | Tells Odoo this is a "Window Action" (opens a view) |
| `<field name="res_model">` | Which model's data to display — must match Python `_name` |
| `<field name="view_mode">` | Which view types to enable: `list`, `form`, `kanban`, `calendar`, etc. |
| `<menuitem .../>` | A navigation item in the Odoo menu bar |
| `parent=` | Links the menu as a child of another menu (creates hierarchy) |
| `action=` | The action to trigger when this menu is clicked (links to `record id`) |

### How to Verify Menus Were Created

1. Go to your module in Apps
2. Click **Installed Features** (or with Developer Mode: Settings → Technical → User Interface → Menu Items)
3. Search for `ITI` — you should see your menu items

> ⚠️ **Beginner Mistake #1:** Putting the `<menuitem>` **before** the `<record>` action in the XML. Odoo reads files top-to-bottom — the action must be defined first.

> ⚠️ **Beginner Mistake #2:** Setting `action="action_iti_student"` but the `id` on the record is spelled differently. IDs are case-sensitive and must match exactly.

> ⚠️ **Beginner Mistake #3:** Setting `res_model="Student"` instead of `res_model="iti.student"`. This must match the exact `_name` value from your Python model.

> ⚠️ **Beginner Mistake #4:** Modifying the XML views file but not updating the module. XML changes require an **"Update"** of the module (not just a server restart):
> - Apps → Find your module → click **Upgrade** (the circular arrow icon)

---

## 10. How Everything Connects: The Full Picture

Here is the complete flow from file to visible UI:

```
iti_smart/
│
├── __manifest__.py
│   └── tells Odoo the module exists
│       └── lists 'views/iti_student_views.xml' under 'data'
│
├── __init__.py
│   └── imports → models/
│
├── models/
│   ├── __init__.py
│   │   └── imports → iti_student.py
│   │
│   └── iti_student.py
│       └── class Student(models.Model)
│           └── _name = 'iti.student'   ← creates table in PostgreSQL
│               └── fields: name, age, gender, ...
│
└── views/
    └── iti_student_views.xml
        ├── <record model="ir.actions.act_window">
        │   ├── res_model = 'iti.student'  ← connects to Python model
        │   └── view_mode = 'list,form'
        │
        └── <menuitem action="action_iti_student">
            └── clicking this → triggers action → shows iti.student records
```

### Development Workflow Recap

```
1. Create/edit a .py file (model)     → Restart server → Upgrade module
2. Create/edit an .xml file (view)    → Upgrade module (no restart needed)
3. Edit __manifest__.py               → Restart server → Upgrade module
4. Add a new module folder            → Restart server → Update App List → Install
```

---

## 11. Quick Reference Cheat Sheet

### Essential Commands

```bash
# Restart Odoo (needed after Python file changes)
sudo systemctl restart odoo

# View Odoo logs in real time (very useful for debugging errors)
sudo journalctl -u odoo -f
# OR if using a log file:
tail -f /var/log/odoo/odoo.log
```

### Developer Mode

| Action | How To |
|--------|--------|
| Enable Developer Mode | Settings → Activate Developer Mode |
| Enable via URL | Add `?debug=1` to any URL |
| Become Superuser | Developer mode → click "Become Superuser" icon |

### Module Development Checklist

- [ ] Module folder created inside a path listed in `addons_path`
- [ ] `__manifest__.py` exists with at least `'name'` key
- [ ] Root `__init__.py` imports `models`
- [ ] `models/__init__.py` imports each model file
- [ ] Model class has `_name` attribute set (dot notation: `module.name`)
- [ ] XML views file is listed in `__manifest__.py` `data` list
- [ ] Action is defined **before** menuitem in XML
- [ ] Server restarted after Python changes
- [ ] App list updated after adding a new module
- [ ] Module installed from the Apps menu

### Key Documentation Links

| Topic | Official URL |
|-------|-------------|
| Developer overview | https://www.odoo.com/documentation/17.0/developer.html |
| Getting started tutorial | https://www.odoo.com/documentation/17.0/developer/tutorials/getting_started.html |
| Module manifest reference | https://www.odoo.com/documentation/17.0/developer/reference/backend/module.html |
| ORM API & Fields | https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html |
| Actions reference | https://www.odoo.com/documentation/17.0/developer/reference/backend/actions.html |
| Views reference | https://www.odoo.com/documentation/17.0/developer/reference/backend/views.html |
| Server framework 101 tutorial | https://www.odoo.com/documentation/17.0/developer/tutorials/server_framework_101.html |

---

> **Next Steps (Day 2 and beyond):**
> - Define custom form and list views in XML
> - Add security (access rights via `ir.model.access.csv`)
> - Learn computed fields, `@api.depends`, and `@api.onchange`
> - Explore relational fields (`Many2one`, `One2many`, `Many2many`)
> - Inherit and extend existing Odoo models

*Study guide generated from Day 1 session notes. Last updated: 2026.*
