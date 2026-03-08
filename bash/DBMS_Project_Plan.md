# 🗄️ Bash DBMS — 6-Day Project Plan
### Mohamed & Karim | Graduation Course | Shell Scripting

---

## 🧠 The Big Picture — Read This Before Anything Else

### What Are You Actually Building?

You are building a **miniature version of MySQL** — but instead of a server process and memory buffers, your entire database engine lives in:
- **Directories** (databases)
- **Plain text files** (tables)
- **Bash logic** (the engine)

This is not a toy. Real early databases like dBASE worked exactly this way. You are learning the *fundamental concept* behind every database that exists.

---

### The 3-Layer Mental Model

Every real software system has layers. Yours has exactly 3:

```
┌─────────────────────────────────────────────────┐
│                 LAYER 3 — UI                    │
│         whiptail GUI menus & dialogs            │
│   (What the user SEES — Days 5)                 │
├─────────────────────────────────────────────────┤
│               LAYER 2 — LOGIC                   │
│    Bash functions: create, insert, select...    │
│   (What the app DOES — Days 1–4)                │
├─────────────────────────────────────────────────┤
│              LAYER 1 — STORAGE                  │
│    Directories + .meta files + .data files      │
│   (Where data LIVES — designed on Day 0)        │
└─────────────────────────────────────────────────┘
```

> **This is why the phases are ordered the way they are.**
> You build Layer 1 (storage design) mentally before Day 1.
> You build Layer 2 (all logic) across Days 1–4.
> You build Layer 3 (GUI) only on Day 5 — because the GUI is just a *skin* on top of working logic.
> If you try to build GUI and logic at the same time, you will get confused and lost.

---

### The Full System Flow (End to End)

This is the complete journey from the moment Mohamed runs `./dbms.sh` to the moment data is saved:

```
User runs ./dbms.sh
        │
        ▼
┌─── MAIN MENU ──────────────────────┐
│  1. Create DB   → mkdir databases/mydb
│  2. List DBs    → ls databases/
│  3. Connect DB  → set CURRENT_DB="mydb"  ──────────────┐
│  4. Drop DB     → rm -rf databases/mydb                │
└────────────────────────────────────┘                   │
                                                         ▼
                                          ┌─── TABLE MENU (inside mydb) ───────────┐
                                          │  1. Create Table  → write .meta file   │
                                          │  2. List Tables   → ls *.meta          │
                                          │  3. Drop Table    → rm .meta + .data   │
                                          │  4. Insert Row    → append to .data    │
                                          │  5. Select Rows   → read + format .data│
                                          │  6. Delete Row    → rewrite .data      │
                                          │  7. Update Row    → rewrite .data      │
                                          └────────────────────────────────────────┘
```

---

### How the Data Flows for Every Operation

#### CREATE TABLE → writes the schema
```
User input: "id, int, PK | name, string | age, int"
                    │
                    ▼
          databases/mydb/students.meta
          ┌──────────────┐
          │ id|int|PK    │  ← column 1: name | type | is_primary_key
          │ name|string| │  ← column 2
          │ age|int|     │  ← column 3
          └──────────────┘
          databases/mydb/students.data  ← created empty (touch)
```

#### INSERT → validates then writes a row
```
User input: id=1, name=Alice, age=22
                    │
          ┌─────────┴──────────┐
          │    VALIDATION      │
          │  1. id is int? ✓   │
          │  2. PK duplicate?✓ │
          │  3. age is int? ✓  │
          └─────────┬──────────┘
                    │ all pass
                    ▼
          databases/mydb/students.data
          ┌──────────────┐
          │ 1|Alice|22   │  ← new row appended
          └──────────────┘
```

#### SELECT → reads, formats, displays
```
          databases/mydb/students.data
          ┌──────────────┐
          │ 1|Alice|22   │
          │ 2|Bob|20     │
          └──────────────┘
                    │
          ┌─────────┴──────────┐
          │  read .meta for    │
          │  column headers    │
          └─────────┬──────────┘
                    │
                    ▼
          ┌──────────────────────────┐
          │ ID   │ NAME   │ AGE      │
          │──────│────────│──────────│
          │ 1    │ Alice  │ 22       │
          │ 2    │ Bob    │ 20       │
          └──────────────────────────┘
```

#### UPDATE → find row, rebuild it, swap file
```
User: update where id=1, new name=Alicia
                    │
          ┌─────────┴──────────┐
          │  awk reads .data   │
          │  line by line      │
          │  id==1? → replace  │
          │  id!=1? → keep as-is│
          └─────────┬──────────┘
                    │
                    ▼
          tmpfile (new version of .data)
          ┌──────────────┐
          │ 1|Alicia|22  │  ← updated
          │ 2|Bob|20     │  ← untouched
          └──────────────┘
                    │
                    ▼
          mv tmpfile → students.data  ← atomic swap
```

---

### Why Each Phase Depends on the Previous One

```
DAY 1 — Database shell
  └── You need this FIRST because every table operation
      requires knowing WHICH database you're in ($CURRENT_DB)

DAY 2 — Create Table
  └── You need this before Insert/Select because
      Insert reads the .meta to know column types
      Select reads the .meta to know column headers

DAY 3 — Insert + Select
  └── Insert fills the .data file
      Select proves your storage design works
      These two together = your first "working database"

DAY 4 — Delete + Update
  └── These MODIFY existing .data — so you need rows
      already in the file (from Insert on Day 3)
      to test them properly

DAY 5 — GUI (whiptail)
  └── Just a skin. Plugs on top of Days 1-4 functions.
      If logic is solid, GUI takes only one day.

DAY 6 — Testing
  └── You can only test the full flow after everything exists.
      Edge cases only show up when all parts are connected.
```

> **The golden rule:** Never skip forward. A broken Insert will make Update impossible to debug. Build in order, test each day before moving on.

---

## 🗂️ Project Architecture (Read This First)

Before writing a single line of code, understand how your DBMS will store data on disk:

```
dbms.sh                  ← Main entry point
databases/
  mydb/                  ← Each database = a directory
    students.meta        ← Schema: column names, types, primary key
    students.data        ← Rows of data, pipe-separated
    courses.meta
    courses.data
```

### Table File Format

**`students.meta`** — stores schema (one line per column):
```
id|int|PK
name|string|
age|int|
```

**`students.data`** — stores rows:
```
1|Alice|22
2|Bob|20
```

> **Why pipe `|` as separator?** Commas appear in normal text. Pipe is safer and easy to parse with `awk -F'|'`.

---

## 👥 Recommended Work Split

| Who | Responsibilities |
|-----|-----------------|
| **Mohamed** | Main menu, DB-level operations (Create/List/Connect/Drop), Select display formatting, final GUI wiring |
| **Karim** | Table-level operations (Create Table, Insert, Delete, Update), all data validation logic |
| **Both Together** | Day 5 GUI layer, Day 6 testing & integration |

> This split is logical: Mohamed owns the "navigation shell", Karim owns the "data engine". They meet at the table menu interface.

---

## 📅 Day-by-Day Plan

---

### 📌 DAY 1 — Foundation & Database Operations
**Goal:** Working main menu + Create / List / Connect / Drop Database

#### 🎓 Study Before You Start (1 hour)
| Topic | What to look up |
|-------|----------------|
| Functions in Bash | `function myFunc() {}` syntax, local variables |
| `case` statement | Menu-driven programs with `case $choice in` |
| `mkdir`, `ls`, `rm -rf` | Directory manipulation |
| `read -p` | Getting user input |
| `[[ -d path ]]` | Checking if a directory exists |
| `$( )` command substitution | Storing command output in a variable |

#### 🔨 Build Today
```bash
# Structure to have working by end of Day 1:

main_menu()         # Show main menu with select/case
create_db()         # mkdir databases/$name + existence check
list_dbs()          # ls databases/ — handle empty case
drop_db()           # rm -rf with confirmation prompt
connect_db()        # Set $CURRENT_DB variable, enter table menu loop
table_menu()        # Stub — just show menu, no logic yet
```

#### ✅ Learning Points After Day 1
- A **directory IS a database** — simple and elegant
- Always validate input: what if the user enters a DB name with spaces? Use `[[ "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]` to enforce safe names
- Use a **global variable** like `CURRENT_DB` to track which database is "connected"
- `select` built-in is great for menus — explore it as alternative to `case`
- **Never skip the empty-state check**: what if `databases/` has no folders yet?

---

### 📌 DAY 2 — Table Management
**Goal:** Create Table (with schema), List Tables, Drop Table

#### 🎓 Study Before You Start (1 hour)
| Topic | What to look up |
|-------|----------------|
| `while` loops + `read` | Reading user input in a loop |
| Bash arrays `arr=()` | Storing multiple column names temporarily |
| Writing to files | `echo "text" >> file` vs `>` (append vs overwrite) |
| `IFS` (Internal Field Separator) | Splitting strings on a delimiter |
| `wc -l` | Counting lines in a file |

#### 🔨 Build Today
```bash
create_table()    # Prompt for table name, then loop: ask column name, type, is PK?
                  # Write to .meta file. Validate: exactly one PK, valid types only

list_tables()     # ls databases/$CURRENT_DB/*.meta (strip .meta extension for display)

drop_table()      # Remove both .meta and .data files with confirmation
```

**Valid data types to support:** `int` and `string` (keep it simple)

**Example interaction for Create Table:**
```
Enter table name: students
Enter number of columns: 3
Column 1 name: id
Column 1 type (int/string): int
Is this the primary key? (y/n): y
Column 2 name: name
Column 2 type (int/string): string
...
```

#### ✅ Learning Points After Day 2
- The **`.meta` file IS your schema** — protect it. Never let the user corrupt it
- Enforce that **exactly one PK** is defined per table
- Learn to read a `.meta` file back line-by-line using `while IFS='|' read -r col type pk`
- `printf` is better than `echo` for formatted output — start using it now
- If `.data` file doesn't exist yet, `touch` it on table creation (empty file = empty table)

---

### 📌 DAY 3 — Insert Into Table & Select From Table
**Goal:** Insert rows with full validation + formatted Select output

#### 🎓 Study Before You Start (1.5 hours)
| Topic | What to look up |
|-------|----------------|
| `awk -F'|'` | Parsing pipe-separated files, `$1`, `$2`, `NR`, `NF` |
| `grep -c` | Counting matches |
| `cut -d'|' -f1` | Extracting specific fields |
| `printf "%-15s"` | Left-aligned fixed-width columns for display |
| Regex in bash | `[[ "$val" =~ ^[0-9]+$ ]]` to check if value is integer |

#### 🔨 Build Today (Karim: Insert | Mohamed: Select)

**Insert logic (Karim):**
```bash
insert_into_table()
  # 1. Read .meta to get column names and types
  # 2. For each column, prompt user for value
  # 3. Validate: int columns must be numeric
  # 4. Validate: PK column must not already exist in .data
  # 5. Append the new row to .data
```

**Select logic (Mohamed):**
```bash
select_from_table()
  # 1. Read .meta to get column headers
  # 2. Print header row with printf formatting
  # 3. Print separator line (e.g. ──────────────)
  # 4. Loop through .data, print each row formatted
  # 5. Handle empty table gracefully
```

**Target Select output:**
```
┌─────────────────────────────┐
│ ID    │ NAME      │ AGE     │
├─────────────────────────────┤
│ 1     │ Alice     │ 22      │
│ 2     │ Bob       │ 20      │
└─────────────────────────────┘
2 row(s) found.
```

#### ✅ Learning Points After Day 3
- `awk` is one of the most powerful tools for tabular data in bash — invest time here
- **Always validate before writing** — never trust user input
- For the PK check: `awk -F'|' -v pk="$pk_col_index" -v val="$input" '$pk == val' file` — if it returns anything, the PK is duplicate
- `printf "%-10s | %-10s\n"` gives you clean aligned columns — memorize this pattern
- `column -t -s'|'` is a quick alternative for display — know both methods

---

### 📌 DAY 4 — Delete & Update
**Goal:** Delete rows by PK condition, Update rows by PK

#### 🎓 Study Before You Start (1 hour)
| Topic | What to look up |
|-------|----------------|
| `sed -i` | In-place file editing |
| `grep -v` | Exclude matching lines (inverse grep) |
| Temp file pattern | `tmp=$(mktemp); ... ; mv $tmp original` |
| `awk` with conditions | `awk -F'|' '$1 != "value"' file` |

#### 🔨 Build Today
```bash
delete_from_table()
  # 1. Ask user: which column to filter on (show column names)
  # 2. Ask user: what value to match
  # 3. Show matching rows first (confirm with user)
  # 4. Use grep -v or awk to write all NON-matching rows to temp file
  # 5. Replace original .data with temp file

update_table()
  # 1. Ask: which row to update (by PK value)
  # 2. Find the row — show it to user
  # 3. For each column (except PK), ask new value (Enter to keep old)
  # 4. Validate new values (type check)
  # 5. Use awk to rebuild the row in .data
```

**The safe update pattern:**
```bash
# Never edit .data directly — always use a temp file
tmpfile=$(mktemp)
awk -F'|' -v pk="$pk_val" -v new_row="$updated_row" '
  BEGIN { OFS="|" }
  $1 == pk { print new_row; next }
  { print }
' "$table_data" > "$tmpfile"
mv "$tmpfile" "$table_data"
```

#### ✅ Learning Points After Day 4
- **Always use a temp file** for modifications — never `sed -i` on production data without a backup strategy
- `mktemp` creates a safe temporary file — use it
- For update: let user press Enter to **keep old value** — parse with: `[[ -z "$input" ]] && input="$old_val"`
- `awk` can do a full row replacement in one pass — cleaner than sed for structured data
- This is the hardest day — budget extra time if needed

---

### 📌 DAY 5 — GUI with whiptail
**Goal:** Replace all text menus with whiptail dialogs

#### 🎓 Study Before You Start (1.5 hours)
| Topic | What to look up |
|-------|----------------|
| `whiptail --menu` | Dropdown menu dialog |
| `whiptail --inputbox` | Text input dialog |
| `whiptail --yesno` | Confirmation dialog |
| `whiptail --msgbox` | Info/result display |
| `$?` return codes | `0` = OK, `1` = Cancel in whiptail |
| `3>&1 1>&2 2>&3` | The whiptail stdout redirect trick |

#### 🔨 Build Today
```bash
# Pattern for EVERY whiptail menu:
CHOICE=$(whiptail --title "Main Menu" --menu "Choose an option:" 20 60 5 \
  "1" "Create Database" \
  "2" "List Databases" \
  "3" "Connect to Database" \
  "4" "Drop Database" \
  "5" "Exit" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus -ne 0 ]; then
  # User pressed Cancel or Escape
  return
fi

# Pattern for input box:
DB_NAME=$(whiptail --title "Create Database" --inputbox "Enter database name:" 10 50 3>&1 1>&2 2>&3)
```

**Strategy:** Don't rewrite everything from scratch. Extract each menu into a function, then replace the `echo/read` block with a `whiptail` block. Keep the logic functions exactly the same.

#### ✅ Learning Points After Day 5
- `3>&1 1>&2 2>&3` is not magic — it's file descriptor swapping: whiptail writes to stderr, this trick captures it into a variable
- **Always check `$?` after every whiptail call** — user can press Escape/Cancel at any point
- `whiptail` is pre-installed on most Linux distros; `dialog` is the older equivalent
- Keep your **GUI layer and logic layer separate** — the whiptail functions should only collect input, then call the same logic functions from Days 1–4
- Test on a real Linux terminal — whiptail may not render well in some IDEs

---

### 📌 DAY 6 — Integration, Testing & Discussion Prep
**Goal:** Full integration, edge case handling, code cleanup, discussion prep

#### Morning (2 hours): Integration & Testing Checklist
Run through every scenario below. Each one should work cleanly:

```
□ Create a database with a valid name
□ Try to create a database with the same name twice (should fail gracefully)
□ Try to create a database with spaces in the name (should reject)
□ Connect to a database
□ Create a table with 3 columns, one PK
□ Try to create a table with the same name twice
□ Insert 5 rows into the table
□ Try to insert a duplicate PK → should reject
□ Try to insert letters into an int column → should reject
□ Select all rows → check formatting
□ Delete a row by PK
□ Try to delete a PK that doesn't exist
□ Update a row — change one value, keep others (press Enter)
□ Drop a table → verify .meta and .data are both deleted
□ Drop a database that still has tables
□ All whiptail dialogs respond correctly to Escape/Cancel
```

#### Afternoon (1.5 hours): Code Cleanup
- Add a **header comment** to your script explaining authors, date, purpose
- Make sure all functions have **1-line comments** above them
- Remove debug `echo` statements
- Consistent indentation (2 or 4 spaces — pick one)
- Group functions logically: DB functions together, Table functions together

---

## 🎓 Discussion Preparation — Key Topics

These are the questions a professor is most likely to ask. Know every answer.

### Architecture Questions
| Question | Your Answer |
|----------|-------------|
| How are databases stored? | As directories under `databases/` |
| How are tables stored? | Two files: `.meta` (schema) and `.data` (rows) |
| Why pipe `|` as separator? | Commas appear in user data; pipe is safer |
| How do you handle the schema? | `.meta` stores `colname|type|PK` per line |

### Code Questions (Must be able to point to your code)
- **Show me the PK uniqueness check** — where exactly is it?
- **How do you validate that a value is an integer?** — regex: `[[ "$val" =~ ^[0-9]+$ ]]`
- **How does Update work without corrupting the file?** — temp file + `awk` + `mv`
- **What happens if the user presses Cancel in whiptail?** — `$?` check, graceful return
- **How does Select format the output?** — `printf "%-Ns"` with column widths from metadata

### Conceptual Questions
- **What is a primary key and why does it matter?** — unique identifier, prevents duplicate records
- **What's the difference between `>` and `>>`?** — overwrite vs append
- **Why use `mktemp` instead of a hardcoded temp file?** — concurrency safety, unique names
- **What are file descriptors?** — stdin(0), stdout(1), stderr(2) — and why whiptail needs the swap trick

---

## ⚠️ Critical Notes & Common Mistakes

1. **Whitespace in names** — Always quote variables: use `"$var"` not `$var`. One space will break everything.
2. **Empty `.data` file** — Always `touch table.data` on table creation. Never assume the file exists.
3. **The whiptail redirect** — `3>&1 1>&2 2>&3` must be at the END of the whiptail command, not the beginning.
4. **Deleting databases with tables** — Decide: do you allow it? Should you warn? Implement one consistent behavior.
5. **Relative vs absolute paths** — Store the script's directory in a variable at startup: `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"`. Use it everywhere.
6. **`rm -rf` is irreversible** — Always ask for confirmation before any drop operation.
7. **IFS side effects** — When you change `IFS`, restore it: `OLD_IFS=$IFS; IFS='|'; ...; IFS=$OLD_IFS`
8. **Column index in awk** — awk columns start at `$1`, not `$0` (`$0` is the whole line).

---

## 🛠️ Starter Code Skeleton

```bash
#!/bin/bash
# ============================================================
# Bash DBMS — A Shell Script Database Management System
# Authors : Mohamed & Karim [Last Name]
# Course  : Shell Scripting — Graduation Project
# Date    : [Date]
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_DIR="$SCRIPT_DIR/databases"
CURRENT_DB=""

# Create databases directory if it doesn't exist
mkdir -p "$DB_DIR"

# ─────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────

is_valid_name() {
  [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

press_enter() {
  whiptail --msgbox "$1" 10 60
}

# ─────────────────────────────────────────────
# DATABASE OPERATIONS
# ─────────────────────────────────────────────

create_db() {
  local name
  name=$(whiptail --title "Create Database" --inputbox "Enter database name:" 10 50 3>&1 1>&2 2>&3)
  [[ $? -ne 0 ]] && return
  # ... your logic here
}

list_dbs() { : ; }
drop_db()  { : ; }
connect_db(){ : ; }

# ─────────────────────────────────────────────
# TABLE OPERATIONS
# ─────────────────────────────────────────────

create_table()        { : ; }
list_tables()         { : ; }
drop_table()          { : ; }
insert_into_table()   { : ; }
select_from_table()   { : ; }
delete_from_table()   { : ; }
update_table()        { : ; }

# ─────────────────────────────────────────────
# MENUS
# ─────────────────────────────────────────────

table_menu() {
  while true; do
    CHOICE=$(whiptail --title "Table Menu — $CURRENT_DB" --menu "Choose:" 20 60 8 \
      "1" "Create Table"     \
      "2" "List Tables"      \
      "3" "Drop Table"       \
      "4" "Insert into Table"\
      "5" "Select From Table"\
      "6" "Delete From Table"\
      "7" "Update Table"     \
      "8" "← Back"           \
      3>&1 1>&2 2>&3)
    [[ $? -ne 0 || "$CHOICE" == "8" ]] && return
    case $CHOICE in
      1) create_table ;;
      2) list_tables ;;
      3) drop_table ;;
      4) insert_into_table ;;
      5) select_from_table ;;
      6) delete_from_table ;;
      7) update_table ;;
    esac
  done
}

main_menu() {
  while true; do
    CHOICE=$(whiptail --title "Bash DBMS — Main Menu" --menu "Choose:" 18 60 5 \
      "1" "Create Database"    \
      "2" "List Databases"     \
      "3" "Connect to Database"\
      "4" "Drop Database"      \
      "5" "Exit"               \
      3>&1 1>&2 2>&3)
    [[ $? -ne 0 ]] && break
    case $CHOICE in
      1) create_db ;;
      2) list_dbs ;;
      3) connect_db ;;
      4) drop_db ;;
      5) break ;;
    esac
  done
}

# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────
main_menu
```

---

## 📚 Best Reference Links

| Topic | Resource |
|-------|----------|
| Bash scripting full guide | https://tldp.org/LDP/abs/html/ |
| whiptail examples | Search: "whiptail bash examples" on linuxconfig.org |
| awk tutorial | https://www.tutorialspoint.com/awk/index.htm |
| Bash regex | Search: "bash regex test =~" |
| printf formatting | Search: "bash printf format specifiers" |

---

*Good luck Mohamed & Karim — this project will teach you more in 6 days than a semester of theory. The key is to build first, then refine. 💪*
