# 🐧 Linux Essentials Training Project
## Mastering the Command Line (Local System Focus)

---

## 📂 Part 1: Navigation & Shell Basics (The Foundation)

### Q1: Where am I?
* **Task:** Display the full path of the directory you are currently in.
* **Command:** `pwd`
* **Educational Detail:** `pwd` stands for **P**rint **W**orking **D**irectory. It prevents you from getting lost in the filesystem tree.

### Q2: Listing Contents (Detailed)
* **Task:** List all files, including hidden ones, showing file sizes and permissions.
* **Command:** `ls -la`
* **Educational Detail:**
    * `-l` (long): Shows permissions, owner, size, and modification date.
    * `-a` (all): Shows hidden files (files starting with a dot `.`).

### Q3: Human Readable Sizes
* **Task:** List files with sizes displayed in KB, MB, or GB instead of bytes.
* **Command:** `ls -lh`
* **Educational Detail:** Reading "4096" bytes is hard; reading "4.0K" is easy. Always use `-h` for clarity.

### Q4: Moving Around
* **Task:** Navigate into `/var/log` and then return to your home directory using a shortcut.
* **Command:** `cd /var/log` then `cd ~` (or just `cd`)
* **Educational Detail:** `~` (tilde) is the universal shortcut for "My Home Directory". `cd -` will take you back to the *previous* directory you were in.

### Q5: Directory Tree
* **Task:** Visualize the directory structure of the current folder.
* **Command:** `tree` (might need install) or `ls -R`
* **Educational Detail:** `ls -R` recursively lists subdirectories. It helps you understand how files are nested.

---

## 📝 Part 2: File Creation & Viewing

### Q6: Creating Empty Files
* **Task:** Create three empty files named `file1.txt`, `file2.txt`, and `file3.txt` at once.
* **Command:** `touch file1.txt file2.txt file3.txt`
* **Educational Detail:** `touch` updates the timestamp of a file if it exists, or creates an empty one if it doesn't.

### Q7: Viewing Content (Small Files)
* **Task:** Display the contents of `/etc/os-release`.
* **Command:** `cat /etc/os-release`
* **Educational Detail:** `cat` (concatenate) dumps the whole file to the screen. Good for small files, bad for huge logs.

### Q8: Viewing Content (Large Files)
* **Task:** View the contents of `/var/log/syslog` page by page.
* **Command:** `less /var/log/syslog`
* **Educational Detail:** `less` is safer than `cat`. You can scroll up/down with arrows. Press `q` to quit.

### Q9: The Beginning of a File
* **Task:** View only the first 5 lines of a file.
* **Command:** `head -n 5 /etc/passwd`
* **Educational Detail:** Useful to check the format of a file (like headers) without opening the whole thing.

### Q10: The End of a File
* **Task:** View the last 10 lines of a file.
* **Command:** `tail /var/log/syslog`
* **Educational Detail:** By default, `tail` shows 10 lines. Crucial for checking the most recent events in a log file.

---

## ✂️ Part 3: Advanced File Management

### Q11: Copying Files
* **Task:** Copy `file1.txt` to `file1_backup.txt`.
* **Command:** `cp file1.txt file1_backup.txt`
* **Educational Detail:** `cp` creates a duplicate. The original remains untouched.

### Q12: Moving & Renaming
* **Task:** Rename `file2.txt` to `notes.txt`.
* **Command:** `mv file2.txt notes.txt`
* **Educational Detail:** Linux doesn't have a "rename" command. You "move" a file from its old name to a new name.

### Q13: Interactive Deletion
* **Task:** Delete `file3.txt` but ask for confirmation first.
* **Command:** `rm -i file3.txt`
* **Educational Detail:** `-i` (interactive) saves you from accidental deletions. Once a file is `rm`'d in Linux, it is gone forever (no Recycle Bin!).

### Q14: Creating Directories
* **Task:** Create a directory structure `project/code/src` in one command.
* **Command:** `mkdir -p project/code/src`
* **Educational Detail:** Without `-p` (parents), you would get an error because the parent folders don't exist yet.

### Q15: Removing Directories
* **Task:** Delete the `project` directory and everything inside it.
* **Command:** `rm -rf project`
* **Educational Detail:**
    * `-r` (recursive): Go into folders and delete contents.
    * `-f` (force): Don't ask questions. **Danger:** Use carefully!

---

## 🔍 Part 4: The Power of Wildcards (Globbing)

### Q16: Matching Characters
* **Task:** List all files that start with `f` and end with `.txt`.
* **Command:** `ls f*.txt`
* **Educational Detail:** `*` matches *any number* of characters.

### Q17: Single Character Match
* **Task:** List files named `file1.txt`, `fileA.txt`, but not `file10.txt`.
* **Command:** `ls file?.txt`
* **Educational Detail:** `?` matches exactly *one* character.

### Q18: Character Classes
* **Task:** List files named `file1.txt`, `file2.txt`, or `file3.txt` only.
* **Command:** `ls file[1-3].txt`
* **Educational Detail:** `[]` defines a range or specific list of allowed characters.

---

## 🔗 Part 5: Hard vs. Soft Links (Crucial Concept)

### Q19: Creating a Soft Link (Shortcut)
* **Task:** Create a shortcut named `mylog` pointing to `/var/log/syslog`.
* **Command:** `ln -s /var/log/syslog mylog`
* **Educational Detail:** If you delete the original file, the soft link becomes "broken" (useless). It points to the *path*.

### Q20: Creating a Hard Link
* **Task:** Create a hard link named `important_data` for `file1.txt`.
* **Command:** `ln file1.txt important_data`
* **Educational Detail:** A hard link points to the actual data on the disk (inode). If you delete `file1.txt`, `important_data` **still has the content**.

---

## 📜 Part 6: I/O Redirection & Pipes (The Linux Superpower)

### Q21: Standard Output to File
* **Task:** Save the list of files in `/etc` to a file named `config_list.txt`.
* **Command:** `ls /etc > config_list.txt`
* **Educational Detail:** `>` overwrites the file. If `config_list.txt` had data, it's gone now.

### Q22: Appending to File
* **Task:** Add the date to the end of `config_list.txt` without deleting the existing content.
* **Command:** `date >> config_list.txt`
* **Educational Detail:** `>>` appends (adds to the bottom).

### Q23: The Pipe
* **Task:** Count how many files are in `/etc`.
* **Command:** `ls /etc | wc -l`
* **Educational Detail:** `|` takes the output of `ls` and feeds it into `wc` (word count). `-l` counts lines.

### Q24: Redirecting Errors
* **Task:** Try to list a non-existent folder and save the error message to `errors.log`.
* **Command:** `ls /fakefolder 2> errors.log`
* **Educational Detail:**
    * `1>` is Standard Output (Success).
    * `2>` is Standard Error (Failures).

### Q25: The "Black Hole"
* **Task:** Run a command but discard all output and errors.
* **Command:** `command > /dev/null 2>&1`
* **Educational Detail:** `/dev/null` is a special device that deletes whatever you send to it. Useful for silencing noisy scripts.

---

## 🧠 Part 7: Text Processing Filters (Data Science on CLI)

### Q26: Sorting Data
* **Task:** Sort the content of `config_list.txt` alphabetically.
* **Command:** `sort config_list.txt`
* **Educational Detail:** Adds `-r` to sort in reverse. Does not change the file, just prints sorted output.

### Q27: Finding Duplicate Lines
* **Task:** Find unique lines in a file.
* **Command:** `sort file.txt | uniq`
* **Educational Detail:** `uniq` only detects duplicates if they are adjacent. You almost *always* `sort` before you `uniq`.

### Q28: Extracting Columns
* **Task:** Extract only the usernames (first column) from `/etc/passwd`.
* **Command:** `cut -d: -f1 /etc/passwd`
* **Educational Detail:**
    * `-d:`: Delimiter (the separator is a colon).
    * `-f1`: Field 1 (the first column).

### Q29: Searching Text (Grep)
* **Task:** Find all lines in `config_list.txt` that contain "conf".
* **Command:** `grep "conf" config_list.txt`
* **Educational Detail:** `grep` is the most used search tool. It prints every line that matches the pattern.

### Q30: Case Insensitive Search
* **Task:** Search for "error" regardless of Case (Error, ERROR, error).
* **Command:** `grep -i "error" logfile.txt`
* **Educational Detail:** `-i` ignores case sensitivity.

### Q31: Invert Match
* **Task:** Show lines that do **NOT** contain the word "pass".
* **Command:** `grep -v "pass" file.txt`
* **Educational Detail:** `-v` inverts the search. Useful for filtering out noise.

### Q32: Replacing Text
* **Task:** Display a file but replace all "Hello" with "Hi".
* **Command:** `sed 's/Hello/Hi/g' file.txt`
* **Educational Detail:** `sed` is a Stream Editor. `s` = substitute, `g` = global (all occurrences in the line).

---

## 🕵️ Part 8: Finding Files System-Wide

### Q33: Find by Name
* **Task:** Find a file named `host.conf` anywhere on the system.
* **Command:** `sudo find / -name "host.conf"`
* **Educational Detail:** `find` searches the real disk. It's slower but perfectly accurate.

### Q34: Find by Size
* **Task:** Find all files larger than 100MB in `/home`.
* **Command:** `find /home -size +100M`
* **Educational Detail:** Great for cleaning up disk space.

### Q35: Find by Time
* **Task:** Find files modified in the last 24 hours.
* **Command:** `find . -mtime -1`
* **Educational Detail:** `-mtime` uses days. `-1` means less than 1 day ago.

### Q36: Quick Search (Locate)
* **Task:** Quickly find where `python` files are.
* **Command:** `locate python`
* **Educational Detail:** `locate` searches a database (index), so it's instant. However, if the file was just created, `locate` won't find it until the database updates (`sudo updatedb`).

### Q37: Command Location
* **Task:** Find exactly which executable runs when you type `ls`.
* **Command:** `which ls`
* **Educational Detail:** Tells you if you are running `/bin/ls` or a different version.

---

## 👥 Part 9: User & Group Management (Local)

### Q38: Who is logged in?
* **Task:** See details about your current user (UID, GID).
* **Command:** `id`
* **Educational Detail:** UID 0 is always Root. UID 1000+ is usually the first normal user.

### Q39: Create User
* **Task:** Create a new user named `student`.
* **Command:** `sudo useradd -m student`
* **Educational Detail:** `-m` ensures they get a home folder `/home/student`. Without it, the user exists but has nowhere to save files.

### Q40: Lock Account
* **Task:** Lock the `student` account so they cannot login.
* **Command:** `sudo passwd -l student`
* **Educational Detail:** Does not delete the user, just disables the password. Useful for temporary suspension.

### Q41: User History
* **Task:** See who logged into the system recently.
* **Command:** `last`
* **Educational Detail:** Reads from `/var/log/wtmp`. Good for security auditing.

---

## 🔐 Part 10: File Permissions & Ownership

### Q42: Understanding rwx
* **Task:** Read the permission `-rw-r--r--`.
* **Answer:**
    * **User:** Read/Write
    * **Group:** Read Only
    * **Others:** Read Only

### Q43: Make Script Executable
* **Task:** Allow `script.sh` to be executed.
* **Command:** `chmod +x script.sh`
* **Educational Detail:** `+x` adds execute permission. Without this, you cannot run `./script.sh`.

### Q44: Restrict File
* **Task:** Make `secret.txt` readable ONLY by the owner.
* **Command:** `chmod 600 secret.txt`
* **Educational Detail:** 6 (rw-) for owner, 0 (---) for everyone else.

### Q45: Change Group Ownership
* **Task:** Change the group of a file to `staff`.
* **Command:** `chgrp staff filename`
* **Educational Detail:** Sometimes you don't need `chown`, just changing the group is enough to share files.

### Q46: Default Permissions (Umask)
* **Task:** Check the current umask value.
* **Command:** `umask`
* **Educational Detail:** Umask determines the *default* permissions of new files. `0022` usually results in `755` for directories and `644` for files.

---

## ⚡ Part 11: Process Management (Local)

### Q47: Dynamic View
* **Task:** Monitor system processes, CPU, and RAM in real-time.
* **Command:** `top` (or `htop`)
* **Educational Detail:** Press `q` to exit. `top` is the Task Manager of Linux.

### Q48: Snapshot View
* **Task:** Take a snapshot of current processes for the current user only.
* **Command:** `ps` or `ps -u`
* **Educational Detail:** `ps` is static. It shows what happened the moment you ran the command.

### Q49: Background a Job
* **Task:** Pause a running foreground command (like `top`).
* **Command:** `Ctrl + Z`
* **Educational Detail:** This "Stops" the process and sends it to the background.

### Q50: Resume in Foreground
* **Task:** Bring the paused job back to the screen.
* **Command:** `fg`
* **Educational Detail:** "Foreground". Use `bg` to make it run in the background instead.

### Q51: Kill Unresponsive App
* **Task:** Force close a program named `vlc`.
* **Command:** `killall vlc`
* **Educational Detail:** Easier than finding the PID if you want to stop all instances of an app.

---

## 📦 Part 12: Package Management (Software)

### Q52: Update Cache (Debian/Ubuntu)
* **Task:** Refresh the software sources list.
* **Command:** `sudo apt update`
* **Educational Detail:** Does not install updates, just checks what is available.

### Q53: Install Tool
* **Task:** Install the `git` package.
* **Command:** `sudo apt install git`
* **Educational Detail:** Apt handles dependencies (it installs needed libraries automatically).

### Q54: Remove Tool
* **Task:** Remove `git` but keep its configuration files.
* **Command:** `sudo apt remove git`
* **Educational Detail:** Use `purge` if you want to delete configs too.

### Q55: Clean Up
* **Task:** Remove unneeded dependencies (orphaned packages).
* **Command:** `sudo apt autoremove`
* **Educational Detail:** Keeps your system lean by removing libraries that no installed program uses anymore.

---

## 🗜️ Part 13: Archiving & Compression

### Q56: Zip a Folder
* **Task:** Compress the `work` folder into `work.zip`.
* **Command:** `zip -r work.zip work/`
* **Educational Detail:** `-r` is needed to include files inside the folder.

### Q57: Unzip
* **Task:** Extract `work.zip`.
* **Command:** `unzip work.zip`
* **Educational Detail:** Standard tool for `.zip` files.

### Q58: Tar (Combine)
* **Task:** Combine files into a `.tar` file (no compression).
* **Command:** `tar -cvf archive.tar file1 file2`
* **Educational Detail:** Good for grouping files together for backup before compressing.

### Q59: Gzip (Compress)
* **Task:** Compress the `.tar` file to reduce size.
* **Command:** `gzip archive.tar` (creates `archive.tar.gz`)
* **Educational Detail:** `gzip` is a standard Linux compression tool.

### Q60: The All-in-One Command
* **Task:** Create a compressed archive (`.tar.gz`) in one step.
* **Command:** `tar -czf backup.tar.gz folder/`
* **Educational Detail:** `z` tells tar to use gzip automatically.

---

## 🛠️ Part 14: Environment Variables

### Q61: View Variables
* **Task:** Print the value of your generic PATH.
* **Command:** `echo $PATH`
* **Educational Detail:** The `$PATH` variable tells the shell which folders to look in for commands.

### Q62: Create Variable
* **Task:** Create a variable `MYNAME="LinuxUser"`.
* **Command:** `export MYNAME="LinuxUser"`
* **Educational Detail:** `export` makes the variable available to child processes (programs you run from the shell).

### Q63: Alias (Shortcuts)
* **Task:** Create a temporary shortcut `c` for `clear`.
* **Command:** `alias c='clear'`
* **Educational Detail:** Aliases save typing. To make it permanent, add it to `.bashrc`.

---

## 💾 Part 15: Disk & Filesystem (Local)

### Q64: Check Free Space
* **Task:** Check free disk space on your computer.
* **Command:** `df -h`
* **Educational Detail:** Look at the "Use%" column.

### Q65: Check Directory Size
* **Task:** How big is your home folder?
* **Command:** `du -sh ~`
* **Educational Detail:** `-s` sums it up into one number.

### Q66: Mounting USB
* **Task:** (Concept) Where do USB drives usually appear?
* **Answer:** Usually under `/media/username/` or `/mnt`.
* **Educational Detail:** In modern Linux Desktop, this is automatic. In servers/essentials, you might need to use `mount`.

---

## 📝 Part 16: Basic Shell Scripting (Automation)

### Q67: The Shebang
* **Task:** What must be the first line of a bash script?
* **Answer:** `#!/bin/bash`
* **Educational Detail:** Tells the system "Use the Bash program to run this text file".

### Q68: Variables in Script
* **Task:** Write a script that defines `NAME="John"` and prints "Hello John".
* **Code:**
    ```bash
    NAME="John"
    echo "Hello $NAME"
    ```

### Q69: User Input
* **Task:** Write a script that asks the user for their age.
* **Code:**
    ```bash
    read -p "Enter your age: " AGE
    echo "You are $AGE years old"
    ```
* **Educational Detail:** `read` pauses the script and waits for keyboard input.

### Q70: Simple Loop
* **Task:** Print "Linux is great" 5 times.
* **Code:**
    ```bash
    for i in {1..5}
    do
       echo "Linux is great"
    done
    ```

---

## 🔧 Part 17: Text Editors (Nano/Vim)

### Q71: Open Nano
* **Task:** Open a new file with Nano editor.
* **Command:** `nano newfile.txt`
* **Educational Detail:** Nano is the most beginner-friendly terminal editor.

### Q72: Save in Nano
* **Task:** How do you save in Nano?
* **Answer:** `Ctrl + O` (Write Out), then Enter.

### Q73: Exit Nano
* **Task:** How do you exit Nano?
* **Answer:** `Ctrl + X`.

### Q74: Open Vim
* **Task:** Open file with Vim.
* **Command:** `vim newfile.txt`
* **Educational Detail:** Vim is powerful but uses "Modes". You start in Normal mode (cannot type text yet).

### Q75: Insert Mode (Vim)
* **Task:** How to start typing in Vim?
* **Answer:** Press `i`.
* **Educational Detail:** You will see "-- INSERT --" at the bottom.

### Q76: Save & Quit (Vim)
* **Task:** Save and exit Vim.
* **Answer:** Press `Esc` (to leave Insert mode), then type `:wq` and Enter.

### Q77: Quit without Saving (Vim)
* **Task:** You made a mistake and want to exit Vim without saving.
* **Answer:** Press `Esc`, then type `:q!` and Enter.

---

## 🧠 Part 18: Troubleshooting & Help

### Q78: The Manual
* **Task:** Read the manual for the `ls` command.
* **Command:** `man ls`
* **Educational Detail:** The ultimate source of truth. Press `q` to quit.

### Q79: Quick Help
* **Task:** Get a short summary of how to use `grep`.
* **Command:** `grep --help`
* **Educational Detail:** Faster than `man` if you just forgot a specific flag.

### Q80: Command History
* **Task:** Run the same command you ran 5 minutes ago without typing it.
* **Command:** `history` (then `!number`) or `Ctrl + R` (search).
* **Educational Detail:** `Ctrl + R` allows you to search your past commands. A huge time saver!