# 🚀 Git Training Project - From Zero to Expert
## Project: Building and Managing a Simple Website

---

## 📚 Level 1: Getting Started (Easiest Level)

### Question 1: Create the Project Directory
**Task:** Create a new folder called `my-website`

**What you need to know:**
- `mkdir` stands for "make directory" - it's the Linux command to create folders
- This is one of the most basic commands you'll use daily as a developer
- You can create multiple directories at once: `mkdir folder1 folder2 folder3`
- Use `mkdir -p path/to/nested/folder` to create nested directories

**Hint:** Use the command to make directories
**Related Command:** `mkdir`

---

### Question 2: Navigate to the Directory
**Task:** Enter the folder you just created

**What you need to know:**
- `cd` stands for "change directory" - it's how you navigate the file system
- `cd ..` goes up one level (to parent directory)
- `cd ~` takes you to your home directory
- `cd -` takes you back to the previous directory you were in
- Just typing `cd` alone also takes you home

**Hint:** Use the command to change your current location
**Related Command:** `cd`

---

### Question 3: Verify Your Location
**Task:** Print the full path of where you are now to confirm

**What you need to know:**
- `pwd` stands for "print working directory"
- This shows you the absolute path from the root (/) to your current location
- Very useful when you're lost in the terminal or in complex directory structures
- The output looks like: `/home/username/projects/my-website`

**Hint:** Command to print the working directory
**Related Command:** `pwd`

---

### Question 4: Initialize Git Repository
**Task:** Turn this folder into an empty Git repository

**What you need to know:**
- `git init` creates a hidden `.git` folder that stores all version control information
- This is the first step for any new Git project
- After this, Git starts tracking changes in this directory
- The `.git` folder contains your entire project history, branches, and commits
- You only need to do this once per project

**Hint:** Command to initialize/start Git
**Related Command:** `git init`

---

### Question 5: View Hidden Files
**Task:** Display all files and folders including hidden ones

**What you need to know:**
- `ls` lists files, but by default hides files starting with `.` (dot files)
- `-a` flag means "all" - shows hidden files including `.` and `..`
- `-l` flag gives detailed info (permissions, size, date)
- Combine them: `ls -la` for detailed view of all files
- The `.git` directory you just created is hidden, so you need `-a` to see it

**Hint:** List command with flag for all files
**Related Command:** `ls -a`

---

## 📝 Level 2: Creating Files and First Commits

### Question 6: Create an HTML File
**Task:** Create an empty file named `index.html`

**What you need to know:**
- `touch` creates an empty file or updates the timestamp of an existing file
- If the file doesn't exist, it creates it
- If it exists, it updates the "last modified" time without changing content
- You can create multiple files at once: `touch file1.txt file2.txt`
- This is a quick way to create files without opening an editor

**Hint:** Command to "touch" or create files
**Related Command:** `touch`

---

### Question 7: Write Simple Content
**Task:** Write this text into the file: `<h1>Hello World</h1>`

**What you need to know:**
- `echo` prints text to the screen (standard output)
- `>` redirects that output to a file (overwrites existing content)
- `>>` appends to a file instead of overwriting
- Use quotes to include the whole string: `echo "text here"`
- This is useful for quick file creation, but use a text editor for complex files

**Hint:** Echo command with output redirection
**Related Command:** `echo "text" > file`

---

### Question 8: Read the Content
**Task:** Display the file content on screen

**What you need to know:**
- `cat` stands for "concatenate" - originally meant to combine files
- Most commonly used to display file contents
- `cat file1 file2` displays both files sequentially
- For large files, use `less` or `more` for pagination
- `head` shows first 10 lines, `tail` shows last 10 lines

**Hint:** Command to concatenate and display files
**Related Command:** `cat`

---

### Question 9: Check Git Status
**Task:** See the current state of your repository

**What you need to know:**
- `git status` is THE most important command - use it constantly!
- Shows which files are modified, staged, untracked, or ready to commit
- Untracked files are new files Git doesn't know about yet
- Modified files are tracked files that have changes
- Staged files are ready to be committed
- This command never changes anything - safe to run anytime

**Hint:** Command to check status in Git
**Related Command:** `git status`

---

### Question 10: Stage the File
**Task:** Add `index.html` to the staging area

**What you need to know:**
- Staging area (also called "index") is like a preview of your next commit
- `git add` moves files from "untracked" or "modified" to "staged"
- `git add .` adds all changes in current directory
- `git add -A` adds all changes in entire repository
- You can unstage with `git restore --staged <file>`
- Think of it as preparing items before taking a snapshot

**Hint:** Command to add files to staging
**Related Command:** `git add`

---

### Question 11: First Commit
**Task:** Create a commit with message "Initial commit: Add index.html"

**What you need to know:**
- A commit is a snapshot of your staged changes
- `-m` flag lets you write the commit message inline
- Without `-m`, Git opens a text editor for the message
- Good commit messages are clear and describe what changed
- Each commit gets a unique hash (SHA) identifier
- Commits are the building blocks of Git history
- Convention: Use present tense ("Add" not "Added")

**Hint:** Commit command with message flag
**Related Command:** `git commit -m`

---

## 🌿 Level 3: Working with Branches

### Question 12: List Branches
**Task:** Display all existing branches

**What you need to know:**
- Branches are independent lines of development
- `git branch` without arguments lists all local branches
- The current branch is marked with `*` and/or color
- `git branch -a` shows remote branches too
- `git branch -v` shows last commit on each branch
- Default branch is usually called `main` or `master`

**Hint:** Branch command to list
**Related Command:** `git branch`

---

### Question 13: Create New Branch
**Task:** Create a new branch called `feature/add-css`

**What you need to know:**
- Branch names often follow patterns: `feature/`, `bugfix/`, `hotfix/`
- `git branch <name>` creates but doesn't switch to the branch
- Branches are just pointers to commits - very lightweight
- Use descriptive names that explain the purpose
- Slashes (`/`) in names create logical grouping
- You can have hundreds of branches without performance issues

**Hint:** Same command as before but with a name
**Related Command:** `git branch <name>`

---

### Question 14: Switch to New Branch
**Task:** Move to the branch you just created

**What you need to know:**
- `git checkout` is the old way to switch branches
- `git switch` is the newer, clearer command (Git 2.23+)
- Both do the same thing for switching branches
- When you switch, your files change to match that branch
- Uncommitted changes come with you when switching
- `git checkout -b <name>` creates and switches in one command

**Hint:** Command to checkout or switch branches
**Related Command:** `git checkout` or `git switch`

---

### Question 15: Create CSS File
**Task:** Create `style.css` and write: `body { background: blue; }`

**What you need to know:**
- You're now working on a different branch - changes here won't affect main
- This is why branches are powerful: work on features in isolation
- You can use `touch` + `echo`, or open a text editor like `nano` or `vim`
- This simulates adding a new feature to your project
- Later you'll merge this back to main

**Hint:** Use `touch` and `echo` commands
**Related Commands:** `touch`, `echo >`

---

### Question 16: Commit New Changes
**Task:** Stage and commit with message "Add CSS file"

**What you need to know:**
- You need both `git add` and `git commit` - two steps
- `git commit -am "message"` combines both for tracked files only
- New files (untracked) must be explicitly added first
- This commit only exists on the `feature/add-css` branch
- Your main branch still doesn't have this CSS file
- Check `git status` between steps to see the changes

**Hint:** Need both add and commit commands
**Related Commands:** `git add`, `git commit`

---

### Question 17: Return to Main
**Task:** Switch back to the main branch (main or master)

**What you need to know:**
- When you switch back, the CSS file will "disappear" - don't panic!
- It's still safe in the feature branch
- Your working directory always reflects the current branch
- This demonstrates how branches keep work separate
- Git is just showing you the files from the main branch timeline

**Hint:** Checkout/switch command
**Related Command:** `git checkout main`

---

### Question 18: Merge the Branch
**Task:** Merge `feature/add-css` into main

**What you need to know:**
- Merging combines histories of two branches
- You must be ON the branch you want to merge INTO (main)
- `git merge <branch-name>` brings that branch's changes into current branch
- If no conflicts, Git creates a merge commit automatically
- Fast-forward merge: Git just moves the pointer forward (simplest case)
- After merging, the CSS file now exists in main too!

**Hint:** Merge command
**Related Command:** `git merge`

---

## 📜 Level 4: History and Tracking

### Question 19: View Commit History
**Task:** Display the history of all commits

**What you need to know:**
- `git log` shows commits from newest to oldest
- Each entry shows: hash, author, date, message
- Press `q` to quit the log view
- The hash is a unique identifier for each commit
- Commits have parent commits, forming a chain (history)
- This is your project's timeline

**Hint:** Log command
**Related Command:** `git log`

---

### Question 20: Condensed Log View
**Task:** Show log with one line per commit

**What you need to know:**
- `--oneline` shows just hash and message - much cleaner
- `--graph` adds visual branch structure
- `--all` shows all branches, not just current
- Combine: `git log --oneline --graph --all` for best overview
- Useful when you have many commits
- Great for quick history checking

**Hint:** Log command with oneline flag
**Related Command:** `git log --oneline`

---

### Question 21: View Differences
**Task:** Modify `index.html` and see the difference between current and saved version

**What you need to know:**
- `git diff` shows unstaged changes (what you edited but didn't add yet)
- `git diff --staged` shows staged changes (what's ready to commit)
- `git diff <commit> <commit>` compares two commits
- Lines starting with `-` are removed, `+` are added
- Very useful before committing to review your changes
- No arguments = shows unstaged changes in working directory

**Hint:** Difference command
**Related Command:** `git diff`

---

## 🗂️ Level 5: Advanced File Management

### Question 22: Create .gitignore
**Task:** Create `.gitignore` file and add `*.log` and `node_modules/`

**What you need to know:**
- `.gitignore` tells Git which files to never track
- `*.log` ignores all files ending in .log (wildcard pattern)
- `node_modules/` ignores entire directory (common for dependencies)
- Use `>>` to append lines: `echo "*.log" >> .gitignore`
- Then add another: `echo "node_modules/" >> .gitignore`
- Very important for keeping repos clean of generated or sensitive files
- Create this early in your project!

**Hint:** Use echo with append operator
**Related Command:** `echo "text" >> file`

---

### Question 23: Create Multiple Directories
**Task:** Create directories: `css`, `js`, `images`

**What you need to know:**
- Space-separated names create multiple directories: `mkdir css js images`
- `-p` flag creates parent directories if needed
- Example: `mkdir -p path/to/deep/folder` creates all intermediate folders
- Useful for setting up project structure
- All folders created in one command
- Standard web project organization

**Hint:** mkdir can take multiple names or use -p flag
**Related Command:** `mkdir -p`

---

### Question 24: Move Files
**Task:** Move `style.css` into the `css` folder

**What you need to know:**
- `mv` stands for "move" - also used for renaming
- Syntax: `mv source destination`
- To rename: `mv oldname.txt newname.txt`
- To move: `mv file.txt folder/`
- Can do both: `mv file.txt folder/newname.txt`
- Original file is removed from source location
- Git tracks this as a rename if you commit properly

**Hint:** Move command
**Related Command:** `mv`

---

### Question 25: Copy Files
**Task:** Copy `index.html` to a file named `about.html`

**What you need to know:**
- `cp` stands for "copy"
- Syntax: `cp source destination`
- Original file stays intact, duplicate is created
- `-r` flag for copying directories recursively
- `cp -r folder1 folder2` copies entire directory
- Useful for creating templates or backups
- Both files are now separate - changes to one don't affect the other

**Hint:** Copy command
**Related Command:** `cp`

---

## 🔧 Level 6: Undoing Changes

### Question 26: Discard Unstaged Changes
**Task:** Edit `about.html` then revert it to the last committed version

**What you need to know:**
- This discards your changes - they're gone forever!
- `git restore <file>` is the modern way (Git 2.23+)
- `git checkout -- <file>` is the old way (still works)
- Only works for unstaged changes
- `git restore .` restores all files in current directory
- Always check `git status` first to see what you're discarding
- Use carefully - this cannot be undone!

**Hint:** Restore or checkout command
**Related Command:** `git restore` or `git checkout --`

---

### Question 27: Unstage Files
**Task:** Add a file to staging then remove it from staging (but keep the changes)

**What you need to know:**
- This doesn't delete your changes, just removes from staging area
- `git restore --staged <file>` is modern way
- `git reset HEAD <file>` is old way (still works)
- The file goes back to "modified" status
- Your actual file content is unchanged
- Useful when you accidentally staged wrong files
- `git reset` alone unstages everything

**Hint:** Restore with staged flag or reset command
**Related Command:** `git restore --staged` or `git reset`

---

### Question 28: Modify Last Commit
**Task:** Change the message of your most recent commit

**What you need to know:**
- `--amend` rewrites the last commit
- Can change the message: `git commit --amend -m "new message"`
- Can add forgotten files: stage them, then `git commit --amend --no-edit`
- Only amend commits that haven't been pushed!
- Amending changes the commit hash - it's a new commit
- Never amend pushed commits (causes problems for collaborators)

**Hint:** Commit command with amend flag
**Related Command:** `git commit --amend`

---

## 🔍 Level 7: Searching and Inspection

### Question 29: Search in Files
**Task:** Search for the word "Hello" in all project files

**What you need to know:**
- `grep` stands for "Global Regular Expression Print"
- `-r` means recursive (search in subdirectories too)
- `-i` makes search case-insensitive
- `-n` shows line numbers
- `grep -rn "Hello" .` searches current directory recursively with line numbers
- Very powerful for finding code across large projects
- Works with regex patterns for advanced searching

**Hint:** Global search command with recursive flag
**Related Command:** `grep -r`

---

### Question 30: Display File Sizes
**Task:** Show file sizes in the project in human-readable format

**What you need to know:**
- `ls -l` shows detailed list (long format)
- `-h` makes sizes human-readable (KB, MB, GB instead of bytes)
- Combine: `ls -lh` for best view
- `-S` sorts by size (largest first)
- `-t` sorts by modification time
- File permissions are shown as first column (rwxrwxrwx)

**Hint:** List command with size flags
**Related Command:** `ls -lh`

---

### Question 31: View Directory Tree
**Task:** Display project structure as a tree

**What you need to know:**
- `tree` creates visual hierarchy of files/folders
- Not installed by default: `sudo apt install tree` (Ubuntu/Debian)
- `-L 2` limits depth to 2 levels
- `-a` shows hidden files
- `-d` shows only directories
- `ls -R` is alternative (recursive list) if tree isn't available
- Great for documentation and understanding project structure

**Hint:** Tree command (may need installation) or ls -R
**Related Command:** `tree` or `ls -R`

---

## 🌐 Level 8: Remote Repository (Advanced Level)

### Question 32: Add Remote Repository
**Task:** Add a remote repository named origin

**What you need to know:**
- Remote = version of your project hosted elsewhere (GitHub, GitLab, etc.)
- `origin` is the conventional name for the primary remote
- Syntax: `git remote add <name> <url>`
- Example URL: `https://github.com/username/repo.git`
- You can have multiple remotes with different names
- This doesn't upload anything yet - just registers the URL
- Use `git remote -v` to verify it was added

**Hint:** Remote command with add
**Related Command:** `git remote add origin <url>`

---

### Question 33: List Remote Repositories
**Task:** Display all configured remote repositories

**What you need to know:**
- `git remote` lists remote names only
- `-v` stands for "verbose" - shows URLs too
- Shows fetch and push URLs (usually the same)
- Each remote can have separate URLs for fetching and pushing
- Helps verify your remote configuration is correct
- Shows if you have multiple remotes (common in fork workflows)

**Hint:** Remote command with verbose flag
**Related Command:** `git remote -v`

---

### Question 34: Create and Push Branch
**Task:** Create branch `feature/footer` and push it to remote

**What you need to know:**
- `git checkout -b <name>` creates and switches in one command
- `git push` uploads commits to remote
- `-u` sets upstream tracking (links local branch to remote branch)
- Full command: `git push -u origin feature/footer`
- After `-u`, you can just use `git push` without arguments
- This publishes your branch for others to see
- First push of a new branch needs `-u`, subsequent pushes don't

**Hint:** Need checkout -b and push with -u flag
**Related Commands:** `git checkout -b`, `git push -u origin`

---

### Question 35: Pull from Remote
**Task:** Fetch and merge latest updates from remote

**What you need to know:**
- `git pull` = `git fetch` + `git merge` combined
- Downloads new commits and merges them into your current branch
- Always pull before starting new work to stay updated
- Can cause merge conflicts if remote and local both changed
- `git fetch` downloads without merging (safer to check first)
- `git pull origin main` specifies which remote and branch

**Hint:** Pull command
**Related Command:** `git pull`

---

### Question 36: Resolve Merge Conflict
**Task:** Intentionally create a conflict and resolve it

**What you need to know:**
- Conflicts happen when same lines are changed in different branches
- Git marks conflicts in files with `<<<<<<<`, `=======`, `>>>>>>>`
- You must manually edit the file to resolve
- Remove conflict markers and keep the desired changes
- After editing: `git add <file>` then `git commit`
- `git status` shows which files have conflicts
- Don't panic - conflicts are normal in team development!

**Hint:** Need to manually edit file, then add and commit
**Related Commands:** `nano/vim`, `git add`, `git commit`

---

## 🎯 Level 9: Advanced Commands

### Question 37: Stash Changes
**Task:** Save your current work temporarily without committing

**What you need to know:**
- Stash = temporary storage for uncommitted changes
- Useful when you need to switch branches but aren't ready to commit
- `git stash` saves changes and cleans working directory
- `git stash push -m "description"` adds a message
- Can stash multiple times - creates a stack
- Changes include both staged and unstaged modifications
- Stash is per-repository, not per-branch

**Hint:** Stash command
**Related Command:** `git stash`

---

### Question 38: Retrieve Stash
**Task:** Restore the temporarily saved changes

**What you need to know:**
- `git stash pop` applies latest stash and removes it from stash list
- `git stash apply` applies but keeps it in stash list
- `git stash list` shows all stashes
- `git stash pop stash@{2}` applies specific stash by number
- `git stash drop` removes a stash without applying
- `git stash clear` removes all stashes
- Pop can cause conflicts if files were modified

**Hint:** Stash command with pop or apply
**Related Command:** `git stash pop`

---

### Question 39: Cherry-pick Commit
**Task:** Copy a specific commit from another branch

**What you need to know:**
- Cherry-pick takes one commit and applies it to current branch
- Syntax: `git cherry-pick <commit-hash>`
- Creates a new commit with same changes but different hash
- Useful for applying bug fixes from one branch to another
- Can cherry-pick multiple commits: `git cherry-pick hash1 hash2`
- Can cause conflicts if changes overlap
- Use `git log` or `git log --oneline` to find commit hash

**Hint:** Cherry-pick command
**Related Command:** `git cherry-pick`

---

### Question 40: Rebase Branch
**Task:** Rebase your branch onto main

**What you need to know:**
- Rebase rewrites history by moving your commits to a new base
- Makes history linear (cleaner than merge commits)
- `git rebase main` while on feature branch
- Replays your commits on top of main's latest commit
- Can cause conflicts - resolve them and `git rebase --continue`
- NEVER rebase commits that have been pushed (breaks others' history)
- `git rebase --abort` cancels the rebase
- More advanced than merging - use carefully!

**Hint:** Rebase command
**Related Command:** `git rebase`

---

## 🧹 Level 10: Cleanup and Maintenance

### Question 41: Delete Branch
**Task:** Delete the `feature/add-css` branch after merging

**What you need to know:**
- `-d` is safe delete (only if merged)
- `-D` is force delete (even if not merged)
- `git branch -d feature/add-css` deletes local branch
- `git push origin --delete feature/add-css` deletes remote branch
- Can't delete the branch you're currently on
- Deleted branches can be recovered if you know the commit hash
- Good practice to delete merged branches to keep repo clean

**Hint:** Branch command with delete flag
**Related Command:** `git branch -d`

---

### Question 42: Clean Untracked Files
**Task:** Delete all files not tracked by Git

**What you need to know:**
- `git clean` removes untracked files - DANGEROUS!
- `-f` means force (required for safety)
- `-d` includes directories
- `-n` shows what would be deleted (dry run - ALWAYS USE FIRST!)
- `git clean -fd` removes files and directories
- Doesn't touch ignored files (in .gitignore)
- `-x` also removes ignored files
- Use with extreme caution - cannot be undone!

**Hint:** Clean command with force and directory flags
**Related Command:** `git clean -fd`

---

### Question 43: Optimize Repository
**Task:** Clean up and compress the repository

**What you need to know:**
- `gc` stands for "garbage collection"
- Removes orphaned objects and compresses data
- Happens automatically periodically, but you can trigger manually
- `--aggressive` does deeper optimization (slower)
- `--prune=now` removes all unreachable objects immediately
- Reduces .git folder size
- Safe to run anytime
- Useful after deleting large files or many branches

**Hint:** Garbage collection command
**Related Command:** `git gc`

---

### Question 44: View Contributors
**Task:** Display all contributors to the project

**What you need to know:**
- `git shortlog` summarizes git log by author
- `-s` shows summary (count only)
- `-n` sorts by number of commits (most active first)
- Combine: `git shortlog -sn` for ranked list
- `--all` includes all branches
- `-e` shows email addresses
- Great for identifying main contributors
- Useful for generating credits or analyzing team activity

**Hint:** Shortlog command
**Related Command:** `git shortlog -sn`

---

### Question 45: Tag a Release
**Task:** Create a tag for version v1.0.0

**What you need to know:**
- Tags mark specific commits as important (usually releases)
- `git tag v1.0.0` creates lightweight tag
- `git tag -a v1.0.0 -m "Version 1.0"` creates annotated tag (recommended)
- Annotated tags store tagger name, email, date, message
- Tags don't move when new commits are made (unlike branches)
- Push tags: `git push origin v1.0.0` or `git push --tags`
- List tags: `git tag` or `git tag -l`
- Semantic versioning: MAJOR.MINOR.PATCH

**Hint:** Tag command
**Related Command:** `git tag`

---

## 🏆 Final Project: Comprehensive Challenge

### Questions 46-50: Complete Scenario
**Task:** 
1. Create branch named `release/v2.0`
2. Add `README.md` file with project description
3. Make 3 separate commits for different additions
4. Merge it into main
5. Push everything to remote

**What you need to know:**
- This combines everything you've learned!
- Plan your commits - each should be logical unit of work
- Write clear commit messages
- Test the merge before pushing
- Verify with `git log` that history looks correct
- Check `git status` frequently
- Use `git push -u origin release/v2.0` for the branch
- After merging, `git push origin main` for main branch

**Hint:** Use everything you learned from question 1!

---

## 📌 Important Notes:
- Each question builds on previous ones
- If you forget a command, check the hint
- Try writing commands from memory first
- After answering, we'll review together and explain details
- Practice makes perfect - repeat exercises if needed
- Real projects use all these commands daily

**Ready to start? Begin with Question 1! 🚀**