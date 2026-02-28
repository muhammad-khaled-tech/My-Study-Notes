# 🐧 Shell Scripting — Day 1: Complete Beginner's Guide

> **How to use this guide:** Read each section top to bottom. Every concept is explained simply, then followed by progressive examples. Try each example yourself in a terminal!

---

## 📋 Table of Contents

1. [What is the Shell?](#1-what-is-the-shell)
2. [Linux Directory Hierarchy](#2-linux-directory-hierarchy)
3. [Piping and Redirection](#3-piping-and-redirection)
4. [Processes & Job Management](#4-processes--job-management)
5. [sed — The Stream Editor](#5-sed--the-stream-editor)
6. [awk — The Data Tool](#6-awk--the-data-tool)
7. [Lab 1 Solutions](#7-lab-1-solutions)

---

## 1. What is the Shell?

The **shell** is the program that lets you talk to your Linux computer by typing commands.

Think of it like this:
- You (human) → type commands → **Shell** → talks to Linux → shows you results

The most common shell is called **Bash** (`/bin/bash`).

---

## 2. Linux Directory Hierarchy

### 🗂️ The Filesystem is Like an Upside-Down Tree

Everything starts from `/` (called the "root"). All folders branch out from there.

```
/
├── bin/      → Basic programs (ls, cp, mv, cat...)
├── etc/      → Configuration files (like /etc/passwd)
├── home/     → User home folders (like /home/ali)
├── root/     → Home folder of the root (admin) user
├── tmp/      → Temporary files
├── var/      → Log files, variable data
└── usr/
    ├── bin/  → More programs
    └── lib/  → Libraries
```

### 🧭 Navigation Commands

| Command | What it does | Example |
|---------|-------------|---------|
| `pwd` | **P**rint **W**orking **D**irectory — shows where you are | `pwd` → `/home/ali` |
| `cd folder` | **C**hange **D**irectory — move into a folder | `cd Documents` |
| `cd ..` | Go UP one level (to parent folder) | from `/home/ali` → `/home` |
| `cd ../..` | Go UP two levels | from `/home/ali/docs` → `/home` |
| `cd` | Go directly to your home folder | always goes to `/home/yourusername` |
| `cd ~` | Same as `cd` — home shortcut | `/home/ali` |
| `ls` | **L**i**s**t files in current folder | `ls` |

### 📝 Progressive Examples

```bash
# Example 1: See where you are
pwd
# Output: /home/user1/dir1

# Example 2: Go one level up
cd ..
pwd
# Output: /home/user1

# Example 3: Go two levels up at once
cd ../..
pwd
# Output: /

# Example 4: Go back home, then enter a folder
cd              # goes to /home/user1
cd dir1         # enter dir1
pwd
# Output: /home/user1/dir1

# Example 5: Jump sideways to a sibling folder
cd ../dir2
pwd
# Output: /home/user1/dir2

# Example 6: Use absolute path (starts with /)
cd /home/user1
pwd
# Output: /home/user1
```

> 💡 **Tip:** `..` always means "parent folder". `~` always means "my home folder".

---

## 3. Piping and Redirection

### 🔤 Understanding stdin, stdout, stderr

Every command in Linux has 3 "channels" for data:

```
Keyboard ──→ [stdin  fd=0] ──→ COMMAND ──→ [stdout fd=1] ──→ Screen
                                   │
                                   └──→ [stderr fd=2] ──→ Screen (errors)
```

| Name | File Descriptor | Default | Meaning |
|------|----------------|---------|---------|
| stdin | 0 | Keyboard | Where input comes FROM |
| stdout | 1 | Screen | Where normal output goes TO |
| stderr | 2 | Screen | Where error messages go TO |

### ➡️ Redirection — Changing Where Data Goes

#### Output Redirection (`>` and `>>`)

```bash
# > : Send stdout to a FILE (overwrites the file if it exists!)
ls -l > myfile.txt       # saves ls output to myfile.txt

# >> : APPEND stdout to a file (adds to the end, doesn't overwrite)
echo "new line" >> myfile.txt

# Full form (explicitly saying "redirect stdout = fd 1"):
ls 1> myfile.txt         # same as ls > myfile.txt
```

#### Input Redirection (`<`)

```bash
# < : Read stdin FROM a file instead of keyboard
wc -l < myfile.txt       # count lines in file (wc reads from file, not keyboard)

# Full form:
wc -l 0< myfile.txt      # same thing
```

#### Error Redirection (`2>`)

```bash
# 2> : Send error messages to a file (or /dev/null to throw them away)
ls /fake/path 2> errors.txt        # save error to file
ls /fake/path 2>/dev/null          # throw error away (silence it)

# Send BOTH stdout and stderr to the same file:
ls /etc 1> output.txt 2>&1         # 2>&1 means "send stderr to wherever stdout is going"
```

### 🔗 Piping (`|`) — Chaining Commands Together

The **pipe** (`|`) takes the **output** of one command and feeds it as **input** to the next command.

```
Command1 ──stdout──→ | ──stdin──→ Command2
```

#### Progressive Examples

```bash
# Example 1: Count how many users are logged in
who | wc -l
# who → lists logged-in users, wc -l → counts lines

# Example 2: Find only directories in /etc
ls -F /etc | grep "/"
# ls -F adds "/" after directory names, grep "/" keeps only those lines

# Example 3: Chain 3 commands together
head -10 myfile.txt | tail -3 | wc -l
# head -10 → get first 10 lines
# tail -3  → from those 10, get last 3
# wc -l   → count them (should be 3)

# Example 4: Find and count a specific process
ps -e | grep bash | wc -l
# ps -e → list all processes
# grep bash → keep only lines with "bash"
# wc -l → count how many

# Example 5: Real-world use
cat /etc/passwd | grep root
# Show only lines in /etc/passwd that contain "root"
```

> 💡 **Key difference:**
> - **Redirection** (`>`, `<`) connects commands to **files**
> - **Piping** (`|`) connects commands to **other commands**

---

## 4. Processes & Job Management

### 🔄 What is a Process?

Every time you run a program, Linux creates a **process** — a running instance of that program.

- Each process gets a unique **PID** (Process ID number)
- Processes can be parents or children (a parent process creates child processes)
- **Daemons** are special background processes that provide services (like web servers, print spoolers)

### 🔍 Viewing Processes

```bash
# See YOUR processes
ps

# See ALL processes (every user, full details)
ps -ef

# Output explained:
# UID    PID   PPID  C  STIME  TTY   TIME    CMD
# root   1     0     0  10:00  ?     0:01    /sbin/init
#  │      │     │              │
#  │      │     │              └── Terminal (? = no terminal)
#  │      │     └── Parent PID (who created this process)
#  │      └── Process ID
#  └── User who owns the process
```

### 🔎 Finding a Specific Process

```bash
# Method 1: ps + grep
ps -e | grep firefox

# Method 2: pgrep (cleaner)
pgrep firefox           # shows just the PID number
pgrep -l firefox        # shows PID AND name
pgrep -u ali            # all processes owned by user "ali"
pgrep -x firefox        # exact name match only
```

### ☠️ Killing / Stopping a Process

```bash
# kill sends a "signal" to a process by PID
kill 1234               # politely ask process 1234 to stop (SIGTERM = signal 15)
kill -9 1234            # force-kill process 1234 (SIGKILL = signal 9, unstoppable)
kill -STOP 1234         # pause (freeze) a process

# pkill — kill by name instead of PID
pkill firefox           # kill any process named "firefox"
pkill -9 firefox        # force kill by name
```

| Signal # | Name | Effect |
|----------|------|--------|
| 15 | SIGTERM | Politely ask to stop (default) |
| 9 | SIGKILL | Force kill — cannot be ignored |
| STOP | SIGSTOP | Pause/freeze the process |

### ⚡ Background & Foreground Jobs

```bash
# Run a command in the BACKGROUND (add & at the end)
sleep 500 &
# Output: [1] 3028   ← [job number] PID

# See all background jobs
jobs
# Output: [1]+ Running    sleep 500 &

# Bring job #1 to FOREGROUND
fg %1

# While a foreground job runs, press Ctrl+Z to PAUSE it
# Output: [1]+ Stopped   sleep 500

# Resume the stopped job in the BACKGROUND
bg %1

# Stop a background job
kill -STOP %1

# Kill a background job entirely
kill %1
```

### 🛠️ Useful Utility Commands

```bash
# split: Split a big file into smaller chunks of N lines each
split -10 /etc/passwd        # creates files: xaa, xab, xac, xad...
split -5 bigfile.txt piece_  # creates: piece_aa, piece_ab...

# diff: Compare two files, shows differences
diff file1.txt file2.txt

# head: Show first N lines
head -5 /etc/passwd          # first 5 lines

# tail: Show last N lines
tail -5 /etc/passwd          # last 5 lines
```

---

## 5. sed — The Stream Editor

### 💡 What is sed?

`sed` (Stream EDitor) processes a file **one line at a time** and prints results to the screen.

- It does NOT change your file (unless you save the output)
- Think of it as: "read file → do something to each line → print result"

### 🔄 How sed Works (Step by Step)

```
File ──→ [Read line 1 into buffer] ──→ [Apply command] ──→ [Print to screen]
         [Read line 2 into buffer] ──→ [Apply command] ──→ [Print to screen]
         [Read line 3 into buffer] ──→ [Apply command] ──→ [Print to screen]
         ... until last line
```

### 📌 Basic sed Format

```bash
sed 'COMMAND' filename
sed 'ADDRESS COMMAND' filename        # apply command only to specific lines
```

### 🖨️ The `p` Command — Print

```bash
# Print every line (default behavior — p doubles matched lines)
sed '/root/p' myfile          # lines with "root" print TWICE, others print once

# -n suppresses default printing (only print what you explicitly say)
sed -n '/root/p' myfile       # ONLY print lines containing "root"

# Print specific line numbers
sed -n '1p' myfile            # print only line 1
sed -n '3p' myfile            # print only line 3
sed -n '1,5p' myfile          # print lines 1 through 5

# Print from a pattern to another pattern
sed -n '/maha/,/root/p' myfile   # print from line with "maha" to line with "root"

# Print from line 2 to the line starting with "us"
sed -n '2,/^us/p' myfile
```

### 🗑️ The `d` Command — Delete

```bash
# Delete = don't print that line (all other lines still print)

sed '3d' myfile              # delete (don't print) line 3
sed '$d' myfile              # delete the LAST line ($ means last line)
sed '1,3d' myfile            # delete lines 1 through 3
sed '3,$d' myfile            # delete from line 3 to the end
sed '/root/d' myfile         # delete any line containing "root"
```

### 🔄 The `s` Command — Substitute (Find & Replace)

```bash
# Format: s/OLD/NEW/FLAGS
# s = substitute, / = separator, g = global (replace ALL occurrences on each line)

sed 's/old/new/' myfile            # replace FIRST occurrence on each line
sed 's/old/new/g' myfile           # replace ALL occurrences (g = global)
sed -n 's/old/new/gp' myfile       # replace and only PRINT lines where change happened

# Real example: replace "sherine" with "sbahader" everywhere
sed 's/sherine/sbahader/g' myfile

# Replace only on specific lines
sed '2s/old/new/' myfile           # replace only on line 2
sed '/root/s/lp/mylp/g' myfile     # replace only on lines containing "root"
```

### 🔢 Multiple Commands with `-e`

```bash
# Run multiple sed commands on the same file
sed -e '2d' -e 's/sherine/sbahader/g' myfile
#          ↑ delete line 2    ↑ AND replace sherine with sbahader
```

### 🧪 Complete sed Example — Step by Step

Imagine `myfile` contains:
```
sherine
maha
root
user
```

```bash
# 1. Print lines with "root" (suppressed mode)
sed -n '/root/p' myfile
# Output: root

# 2. Delete line 3
sed '3d' myfile
# Output:
# sherine
# maha
# user

# 3. Delete last line
sed '$d' myfile
# Output:
# sherine
# maha
# root

# 4. Delete lines 1 to 3
sed '1,3d' myfile
# Output: user

# 5. Delete lines with "root"
sed '/root/d' myfile
# Output:
# sherine
# maha
# user

# 6. Replace "sherine" with "sbahader"
sed 's/sherine/sbahader/g' myfile
# Output:
# sbahader
# maha
# root
# user

# 7. Delete line 2 AND replace "sherine"
sed -e '2d' -e 's/sherine/sbahader/g' myfile
# Output:
# sbahader
# root
# user
```

> 💡 **Remember:** sed never changes your original file. Use `> newfile` to save:
> ```bash
> sed 's/old/new/g' myfile > newfile
> ```

---

## 6. awk — The Data Tool

### 💡 What is awk?

`awk` is a programming language built for processing **structured data** (like spreadsheets or `/etc/passwd`).

> **Name origin:** Alfred **A**ho, Peter **W**einberger, Brian **K**ernighan — the three creators.

`awk` reads a file line by line, splits each line into **fields** (columns), and lets you do things with them.

### 📌 Basic awk Format

```bash
awk 'INSTRUCTIONS' inputfile
awk -F: 'INSTRUCTIONS' inputfile      # -F: sets the field separator to ":"
```

### 🧩 Records and Fields — The Key Concept

```
Line 1: root:x:0:0:Super User:/root:/bin/bash
         │    │ │ │ │           │     │
        $1   $2 $3 $4 $5       $6    $7
```

| Variable | Meaning | Example |
|----------|---------|---------|
| `$0` | The **entire line** (all fields) | `root:x:0:0:Super User:/root:/bin/bash` |
| `$1` | Field 1 | `root` |
| `$2` | Field 2 | `x` |
| `$3` | Field 3 | `0` (uid) |
| `$4` | Field 4 | `0` (gid) |
| `$5` | Field 5 | `Super User` (comment/full name) |
| `$6` | Field 6 | `/root` (home dir) |
| `$7` | Field 7 | `/bin/bash` (shell) |
| `NF` | **N**umber of **F**ields in this line | `7` |
| `NR` | **N**umber of **R**ecords (current line number) | `1`, `2`, `3`... |
| `FS` | **F**ield **S**eparator (you set this) | `:` for passwd |
| `RS` | **R**ecord **S**eparator (default = newline) | `\n` |

### 🖨️ Basic Printing Examples

```bash
# Print field 1 of /etc/passwd (usernames)
# IMPORTANT: /etc/passwd uses ":" as separator, so we use -F:
awk -F: '{print $1}' /etc/passwd
# Output:
# root
# daemon
# ali

# Print field 1 with a label
awk -F: '{print "Username:", $1}' /etc/passwd
# Output:
# Username: root
# Username: daemon

# Print the whole file (like cat)
awk '{print $0}' /etc/passwd

# Print with line numbers (like cat -n)
awk '{print NR, $0}' /etc/passwd
# Output:
# 1 root:x:0:0:...
# 2 daemon:x:1:1:...

# Print how many fields each line has
awk -F: '{print $0, NF}' /etc/passwd
# Output:
# root:x:0:0:Super User:/root:/bin/bash 7
```

### 🎬 BEGIN and END Patterns

```bash
# BEGIN: runs ONCE before reading any lines
# Good for: setting variables, printing headers
awk 'BEGIN {print "=== USER LIST ==="} {print $1}' /etc/passwd

# END: runs ONCE after reading ALL lines
# Good for: printing totals, summaries
awk 'END {print "Total lines:", NR}' /etc/passwd

# Combined:
awk -F: 'BEGIN {print "Login\tUID"} {print $1, "\t", $3} END {print "Done!"}' /etc/passwd
```

### 🔀 Conditional Expressions (if/else)

```bash
# Basic if/else
awk -F: '{if ($3 > 500) print "High UID:", $1}' /etc/passwd

# if/else with two branches
awk '{if ($1 > $2) max=$1; else max=$2; print max}' numbers.txt

# Ternary operator (shorter if/else)
# FORMAT: condition ? value_if_true : value_if_false
awk -F: '{print ($3 > 500) ? "Regular: "$1 : "System: "$1}' /etc/passwd
```

### ➗ Relational Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `==` | Equal to | `$3 == 500` |
| `!=` | Not equal | `$3 != 0` |
| `>` | Greater than | `$3 > 500` |
| `>=` | Greater or equal | `$3 >= 100` |
| `<` | Less than | `$3 < 100` |
| `<=` | Less or equal | `$3 <= 500` |
| `~` | Matches regex | `$1 ~ /^a/` (starts with a) |
| `!~` | Does NOT match | `$1 !~ /root/` |

### 🔁 Loops in awk

```bash
# While loop: print each field of every line
awk -F: '{i=1; while (i<=NF) {print $i; i++}}' /etc/passwd

# For loop (cleaner way to do the same)
awk -F: '{for (i=1; i<=NF; i++) print $i}' /etc/passwd
```

### 🧪 Progressive awk Examples

```bash
# /etc/passwd structure reminder:
# $1=login $2=pass $3=uid $4=gid $5=comment $6=home $7=shell

# 1. Print all usernames
awk -F: '{print $1}' /etc/passwd

# 2. Print username and home directory
awk -F: '{print $1, $6}' /etc/passwd

# 3. Print with nice formatting using NR
awk -F: '{print NR". "$1" → home: "$6}' /etc/passwd

# 4. Print only users with uid > 500
awk -F: '{if ($3 > 500) print $1, $3, $5}' /etc/passwd

# 5. Print only the user with uid == 500
awk -F: '{if ($3 == 500) print $1, $3, $5}' /etc/passwd

# 6. Print lines 5 to 15
awk 'NR>=5 && NR<=15' /etc/passwd      # short form
awk '{if (NR>=5 && NR<=15) print}' /etc/passwd   # long form

# 7. Replace "lp" with "mylp" in field 5 (comment)
awk -F: '{gsub(/lp/, "mylp"); print}' /etc/passwd

# 8. Find and print info about user with greatest UID
awk -F: 'BEGIN{max=0} {if ($3>max) {max=$3; line=$0}} END{print line}' /etc/passwd

# 9. Sum of all UIDs
awk -F: 'BEGIN{sum=0} {sum+=$3} END{print "Total sum:", sum}' /etc/passwd

# 10. Count users per shell
awk -F: '{shells[$7]++} END{for (s in shells) print shells[s], s}' /etc/passwd
```

---

## 7. Lab 1 Solutions

> The `/etc/passwd` file format:
> `login:password:uid:gid:comment:home:shell`

---

### 🔷 Using sed

#### 1. Display lines containing "lp"

```bash
sed -n '/lp/p' /etc/passwd
```
**Explanation:** `-n` suppresses default output. `/lp/p` = find lines matching "lp" and print them.

#### 2. Display /etc/passwd EXCEPT line 3

```bash
sed '3d' /etc/passwd
```
**Explanation:** `3d` = delete (skip) line 3. All other lines print normally.

#### 3. Display /etc/passwd EXCEPT the last line

```bash
sed '$d' /etc/passwd
```
**Explanation:** `$` means "last line" in sed. `$d` = delete last line.

#### 4. Display /etc/passwd EXCEPT lines containing "lp"

```bash
sed '/lp/d' /etc/passwd
```
**Explanation:** `/lp/d` = delete any line that matches the pattern "lp".

#### 5. Substitute "lp" with "mylp" everywhere

```bash
sed 's/lp/mylp/g' /etc/passwd
```
**Explanation:** `s/lp/mylp/g` = substitute "lp" with "mylp", `g` = on every occurrence (not just first).

---

### 🔶 Using awk

> Remember: `-F:` tells awk to use `:` as the field separator.
> Fields: `$1`=login, `$3`=uid, `$4`=gid, `$5`=comment(full name), `$6`=home

#### 1. Print full name (comment) of all users

```bash
awk -F: '{print $5}' /etc/passwd
```

#### 2. Print login, full name, home directory — with line numbers

```bash
awk -F: '{print NR". "$1, $5, $6}' /etc/passwd
```
Or nicely formatted:
```bash
awk -F: '{printf "%d. %-15s %-20s %s\n", NR, $1, $5, $6}' /etc/passwd
```

#### 3. Print login, uid, full name — only where uid > 500

```bash
awk -F: '{if ($3 > 500) print $1, $3, $5}' /etc/passwd
```

#### 4. Print login, uid, full name — only where uid == 500

```bash
awk -F: '{if ($3 == 500) print $1, $3, $5}' /etc/passwd
```

#### 5. Print lines 5 to 15

```bash
awk 'NR>=5 && NR<=15' /etc/passwd
```

#### 6. Change "lp" to "mylp"

```bash
awk '{gsub(/lp/, "mylp"); print}' /etc/passwd
```
**Note:** `gsub(pattern, replacement)` = global substitute (replaces all occurrences in the line).

#### 7. Print all information about the user with the greatest UID

```bash
awk -F: 'BEGIN{max=0} {if ($3+0 > max) {max=$3; line=$0}} END{print line}' /etc/passwd
```
**Explanation:**
- `BEGIN{max=0}` → start with max=0
- `if ($3+0 > max)` → `+0` forces numeric comparison; if this uid is bigger, update max and save the line
- `END{print line}` → after reading all lines, print the one we saved

#### 8. Sum of all account UIDs

```bash
awk -F: 'BEGIN{sum=0} {sum+=$3} END{print "Sum of all UIDs:", sum}' /etc/passwd
```

---

### 🌟 Bonus

#### Bonus 1: Sum of UIDs grouped by GID (same group)

```bash
awk -F: '{gid_sum[$4]+=$3; gid_count[$4]++} END{for (g in gid_sum) print "GID="g, "Sum of UIDs="gid_sum[g], "Users="gid_count[g]}' /etc/passwd
```

**Explanation — broken down:**
```
gid_sum[$4] += $3       → for each group (field 4), add the uid (field 3) to a running total
gid_count[$4]++         → count how many users are in each group
END{for (g in gid_sum)} → after reading all lines, loop through each group
print ...               → print the group id, total uid sum, and user count
```

#### Bonus 2: User-Group Report

```bash
awk -F: '{users[$4]=users[$4]"\n\t"$1} END{for (g in users) print "Group "g" Name:"users[g]}' /etc/passwd | sort
```

Or a cleaner approach using both `/etc/passwd` and `/etc/group`:

```bash
awk -F: 'NR==FNR{groups[$3]=$1; next} {print groups[$4]"\n\t"$1}' /etc/group /etc/passwd
```

---

## 🔑 Quick Reference Cheat Sheet

### sed

| Command | What it does |
|---------|-------------|
| `sed -n '/pattern/p' file` | Print only matching lines |
| `sed '/pattern/d' file` | Delete matching lines |
| `sed 'Nd' file` | Delete line N |
| `sed '$d' file` | Delete last line |
| `sed '1,5d' file` | Delete lines 1-5 |
| `sed 's/old/new/g' file` | Replace all old with new |
| `sed -n 's/old/new/gp' file` | Replace and print only changed lines |
| `sed -e 'cmd1' -e 'cmd2' file` | Multiple commands |

### awk

| Command | What it does |
|---------|-------------|
| `awk -F: '{print $1}' file` | Print field 1 (separator = :) |
| `awk '{print NR, $0}' file` | Print with line numbers |
| `awk '{print NF}' file` | Print number of fields per line |
| `awk 'BEGIN{...} {..} END{...}'` | Run code before/during/after |
| `awk '{sum+=$3} END{print sum}'` | Sum a numeric field |
| `awk '{if ($3>500) print}'` | Conditional printing |
| `awk 'NR>=5 && NR<=10'` | Print lines 5 to 10 |
| `awk '{gsub(/old/,"new"); print}'` | Global substitute |

---

> 📌 **Practice tip:** Run each example on your own system. `/etc/passwd` exists on every Linux machine — it's the perfect practice file!
