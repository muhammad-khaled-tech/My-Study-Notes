# 🐧 RHSA2 Lab 1 — Complete Solutions on CentOS
## With Explanations & Lecture Connections
**ITI Open Source Track**

---

> 💡 **Before we start — CentOS vs RHEL**
>
> CentOS 7 is essentially RHEL 7 with the Red Hat branding removed. Every command, every config file, every concept from the lecture works identically on CentOS. The one thing that may differ is your **network interface name**. On RHEL/CentOS 7, the old name `eth0` has been replaced by **predictable names** like `ens33`, `ens160`, or `enp0s3` depending on your hardware and virtualization platform.
>
> Before starting the networking section, always run:
> ```bash
> ip addr show
> ```
> and note your actual interface name. Replace `eth0` in every command with whatever yours is called.

---

## 📋 Quick Navigation

| Part | Questions | Topic |
|------|-----------|-------|
| [Part 1](#part-1) | Q1–Q9 | systemd & Services (postfix) |
| [Part 2](#part-2) | Q10–Q11 | GRUB2 Bootloader |
| [Part 3](#part-3) | Q12–Q15 | Scheduling with cron |
| [Part 4](#part-4) | Q16 | Advanced Permissions (ACLs) |
| [Part 5](#part-5) | Q17–Q28 | Network Configuration |
| [Part 6](#part-6) | Bonus | Centralized Logging (rsyslog) |

---

<a name="part-1"></a>
# 🔧 PART 1 — systemd & Services (Q1–Q9)

## 📖 Lecture Connection

The lecture introduces `systemd` as the **parent of all processes** (PID 1). It reads `/etc/systemd/system/default.target` to decide what state to boot into, and it manages services using `systemctl`. The lecture explicitly shows:
- `systemctl start/stop [service_name]`
- `systemctl status [service_name]`
- `systemctl enable/disable [service_name]`
- `systemctl list-unit-files --type service`

This entire section of the lab is you practicing exactly those commands on the `postfix` mail service, and learning by experience what happens when a service goes down.

---

## Q1 — Use `systemctl` to view the status of all system services

### 🧠 The Story

Imagine you're a new admin who just sat down at a server for the first time. The very first thing any good admin does is look around — who's running? Who's stopped? You need a full picture before touching anything.

### ✅ CentOS Solution

```bash
systemctl list-units --type=service
```

This shows all **currently loaded** service units — their state (active/inactive), sub-state (running/dead/exited), and description.

If you also want to see services that aren't loaded at all:

```bash
systemctl list-units --type=service --all
```

And if you want to see which services are **enabled to start at boot** vs which are disabled:

```bash
systemctl list-unit-files --type service
```

> 📌 **Lecture note:** The lecture shows exactly `systemctl list-unit-files --type service` under "Listing services." Both commands are valid. `list-units` shows runtime state; `list-unit-files` shows boot configuration.

### 🔍 Reading the Output

```
UNIT                    LOAD   ACTIVE  SUB     DESCRIPTION
postfix.service         loaded active  running Postfix Mail Transport Agent
sshd.service            loaded active  running OpenSSH server daemon
crond.service           loaded active  running Command Scheduler
NetworkManager.service  loaded active  running Network Manager
```

- **LOAD** = has systemd read this unit's config file?
- **ACTIVE** = is the unit active (running in some form)?
- **SUB** = the detailed state (running, dead, exited, waiting...)

---

## Q2 — Change the default run level to `multi-user.target` and reboot

### 🧠 The Story

When CentOS boots with a desktop environment (GNOME), it loads `graphical.target` — which is heavier and uses more RAM. For a server, you don't need a GUI at all. `multi-user.target` gives you everything a server needs (network, services, multi-user login) without the graphical overhead.

The lecture explains that `default.target` is a **symbolic link** that points to whichever target you want. When you run `set-default`, systemd just rewrites that link.

### ✅ CentOS Solution

```bash
# Step 1: Check what your current default is
systemctl get-default

# Step 2: Change it to multi-user (text-only server mode)
systemctl set-default multi-user.target

# Step 3: Verify the change took effect
systemctl get-default
# Should output: multi-user.target

# Step 4: Reboot to confirm it boots into the right target
reboot
```

After rebooting, you should land at a text login prompt — no GUI. That confirms `multi-user.target` is active.

> 📌 **Lecture note:** The lecture shows this exact command and explains that it works by creating a symlink:
> ```
> ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
> ```
> You don't need to create the symlink manually — `set-default` does it for you.

---

## Q3 — Send mail to the root user

### 🧠 The Story

Before we prove that `postfix` matters, we need to prove that mail works when it IS running. This is the "control" test — send a mail while everything is healthy, confirm it arrives, then we'll break things intentionally.

### ✅ CentOS Solution

First, make sure `postfix` and `mailx` are installed on CentOS:

```bash
# Install postfix if not already installed
yum install postfix -y

# Install mailx (the mail command)
yum install mailx -y

# Make sure postfix is running
systemctl start postfix
systemctl enable postfix
```

Now send the mail:

```bash
echo 'This is the body of the test email' | mail -s 'Test Email Q3' root
```

Breaking this command down:
- `echo 'body'` — creates the message body
- `|` — pipes it as input to the `mail` command
- `-s 'Test Email Q3'` — sets the Subject line
- `root` — the recipient (the root user on this machine)

> 📌 **Lecture note:** The lecture covers the `mail` command in the context of cron job output. The same command syntax is used throughout the lab.

---

## Q4 — Verify that you received the mail

### 🧠 The Story

The `mail` command is also a **mail reader**. When you run it without arguments, it opens your inbox and lets you read messages interactively.

### ✅ CentOS Solution

```bash
mail
```

You'll see something like:
```
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost    Mon Feb 26 10:00  17/634  "Test Email Q3"
```

- Type `1` and press Enter to read message 1
- Type `q` to quit the mail reader

Alternatively, read the raw mailbox file directly (faster for checking):

```bash
cat /var/spool/mail/root
```

> 📌 **How mail delivery works on CentOS:** When you send mail to `root`, `postfix` delivers it to the local mailbox file at `/var/spool/mail/root`. This is a plain text file — you can `cat` it any time.

---

## Q5 — Use `systemctl` to stop the `postfix` service

### 🧠 The Story

Now we perform the experiment. We're going to deliberately bring down the mail delivery system and observe what happens. This teaches you something very practical: services don't just affect themselves — everything that depends on them breaks too.

### ✅ CentOS Solution

```bash
systemctl stop postfix
```

Verify it's actually stopped:

```bash
systemctl status postfix
```

You'll see:
```
● postfix.service - Postfix Mail Transport Agent
   Loaded: loaded (/usr/lib/systemd/system/postfix.service; enabled)
   Active: inactive (dead)
```

`inactive (dead)` = postfix is no longer running. No mail delivery is happening right now.

> ⚠️ Note: `systemctl stop` stops it **right now**, but since we ran `systemctl enable postfix` earlier, it will start again automatically on next reboot. To prevent it from restarting: `systemctl disable postfix`. But for this lab, just stopping it is enough.

---

## Q6 — Send mail again to the root user (postfix is stopped)

### 🧠 The Story

postfix is dead. What happens when you try to send mail? Does it fail immediately? Does it give an error? Or does something else happen?

### ✅ CentOS Solution

```bash
echo 'Postfix is stopped, will this arrive?' | mail -s 'Test Email Q6' root
```

The command appears to succeed — no error message. But the mail has NOT been delivered. Instead it is **queued** — placed in a holding area waiting for postfix to come back online.

The queue lives at:
```bash
ls /var/spool/mqueue/
# You'll see files here — each one is a queued message waiting to be delivered
```

> 📌 **Why no error?** The `mail` command's job is only to hand the message to the **mail transfer agent (MTA)**. When the MTA (postfix) is down, the local mail subsystem stores the message in the queue and returns success to `mail`. The queue is the safety net.

---

## Q7 — Verify that you received the mail (postfix still stopped)

### 🧠 The Story

Check the mailbox now. The Q6 message is NOT there. It's sitting in the queue. This is the moment of understanding: **postfix is the delivery truck**. Without it, packages pile up at the depot.

### ✅ CentOS Solution

```bash
mail
```

You'll see only the Q3 message from before. The Q6 message has not arrived because postfix is not running to deliver it from the queue.

```bash
# Also check the queue to see your message waiting:
mailq
# or
ls /var/spool/mqueue/
```

---

## Q8 — Use `systemctl` to start the `postfix` service

### 🧠 The Story

Time to bring the delivery truck back. The moment postfix starts, it will scan the queue, find the waiting Q6 message, and deliver it immediately.

### ✅ CentOS Solution

```bash
systemctl start postfix
```

Verify it's running again:

```bash
systemctl status postfix
# Active: active (running) ← this is what you want to see
```

> 📌 **What happens internally:** postfix, on startup, checks `/var/spool/mqueue/` for any queued messages and processes them. This is standard MTA behaviour — the queue is exactly what it sounds like, a waiting room for messages that couldn't be delivered yet.

---

## Q9 — Verify that you received the mail (postfix running again)

### ✅ CentOS Solution

```bash
mail
```

Now you'll see **two messages** — the Q3 message from before, and the Q6 message that was queued while postfix was stopped. Both are now in the inbox.

```
"/var/spool/mail/root": 2 messages 1 new
    1 root@localhost   Mon Feb 26 10:00  "Test Email Q3"
>N  2 root@localhost   Mon Feb 26 10:05  "Test Email Q6"
```

The Q6 message timestamp will show when it was **delivered** (when postfix came back up), not when it was sent.

> 🎯 **The lesson of Q1–Q9:** Services are not isolated. When postfix is down, mail queues. When it comes back up, the queue is processed. This is the real-world behaviour of any MTA, and it's why monitoring service health is a core admin responsibility.

---

<a name="part-2"></a>
# 🥾 PART 2 — GRUB2 Bootloader (Q10–Q11)

## 📖 Lecture Connection

The lecture dedicates a full section to GRUB2, explaining:
- `/boot/grub2/grub.cfg` is the **real** config file but you must **never edit it directly**
- `/etc/default/grub` is where **you** make your changes
- After any change to `/etc/default/grub`, you **must** run `grub2-mkconfig` to regenerate `grub.cfg`

The sample file shown in the lecture is:
```
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"
```

The lab asks you to modify exactly these parameters.

---

## Q10 — Change the GRUB2 timeout to 20 seconds

### 🧠 The Story

Right now, when your machine boots, the GRUB menu appears for 5 seconds and then automatically boots the first option. Your boss wants 20 seconds — maybe there's a secondary OS that team members sometimes need to select. Let's change it.

### ✅ CentOS Solution

**Step 1 — Edit the settings file (NOT grub.cfg directly):**

```bash
vi /etc/default/grub
```

Find this line:
```
GRUB_TIMEOUT=5
```

Change it to:
```
GRUB_TIMEOUT=20
```

Save and quit: `:wq`

**Step 2 — Regenerate the actual GRUB config:**

```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

You'll see output like:
```
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-1127.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1127.el7.x86_64.img
done
```

**Step 3 — Verify the change was written:**

```bash
grep TIMEOUT /boot/grub2/grub.cfg
# Should show: set timeout=20
```

> ⚠️ **The most common mistake:** Students edit `/boot/grub2/grub.cfg` directly. This seems to work, but the next time `grub2-mkconfig` runs (e.g., after a kernel update), your change is **overwritten**. Always edit `/etc/default/grub` and regenerate.

> 📌 **Lecture note:** The lecture explicitly states: *"The GRUB 2 configuration file is located at /boot/grub2/grub.cfg (Do not edit this file directly). GRUB 2 menu-configuration settings are taken from /etc/default/grub when generating grub.cfg."*

---

## Q11 — Change the default operating system in GRUB2

### 🧠 The Story

If your machine has multiple operating systems or multiple kernel versions installed, GRUB shows them all in its menu. By default, it boots entry number 0 (the first one, usually the latest kernel). You can change this to any other entry.

### ✅ CentOS Solution

**Step 1 — See what menu entries exist and their index numbers:**

```bash
awk -F\' '/^menuentry / {print NR-1": "$2}' /boot/grub2/grub.cfg
```

Example output:
```
0: CentOS Linux (3.10.0-1127.el7.x86_64) 7 (Core)
1: CentOS Linux (3.10.0-1062.el7.x86_64) 7 (Core)
2: CentOS Linux (0-rescue-...) 7 (Core)
```

**Step 2 — Edit `/etc/default/grub` and change `GRUB_DEFAULT`:**

```bash
vi /etc/default/grub
```

Find:
```
GRUB_DEFAULT=saved
```

Change it to the index number you want (e.g., entry 1):
```
GRUB_DEFAULT=1
```

Or you can use the full menu title as a string:
```
GRUB_DEFAULT="CentOS Linux (3.10.0-1062.el7.x86_64) 7 (Core)"
```

Save and quit: `:wq`

**Step 3 — Regenerate:**

```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

**Step 4 — Verify:**

```bash
grep 'set default' /boot/grub2/grub.cfg
# Should show: set default="1"
```

> 📌 **What `GRUB_DEFAULT=saved` means:** When set to `saved`, GRUB remembers whichever entry was booted last time. When you set it to a number, it always boots that specific entry regardless of what was booted before.

---

<a name="part-3"></a>
# 📅 PART 3 — Scheduling with cron (Q12–Q15)

## 📖 Lecture Connection

The lecture covers both `at` (one-time) and `cron` (recurring). It shows the crontab format:
```
Min(0-59)  Hours(0-23)  Day(1-31)  Month(1-12)  Day(0-6)  command
```

It also explains that `MAILTO=root` at the top of `/etc/anacrontab` causes cron output to be emailed to root — the same mechanism applies to user crontabs. The lab asks you to use this mechanism and then redirect it to a different user.

---

## Q12 — Monitor system resources every 10 minutes, 8 AM to 5 PM, focusing on memory

### 🧠 The Story

Your boss is investigating performance problems that seem to happen during business hours. He suspects memory is the culprit — maybe a process is leaking memory, or the system is swapping heavily. He asks you to set up automatic monitoring every 10 minutes during the workday. You set it up once and it runs itself.

### ✅ CentOS Solution

**Step 1 — Make sure crond is running:**

```bash
systemctl status crond
# If not running:
systemctl start crond
systemctl enable crond
```

**Step 2 — Edit your crontab:**

```bash
crontab -e
```

This opens your crontab in `vi`. Add one of the following lines:

**Option A — `vmstat` (CPU, memory, swap, IO — broad picture):**
```bash
*/10 8-17 * * * /usr/bin/vmstat 1 1 >> /var/log/perf_report.log
```

**Option B — `free -m` (memory and swap only — focused on the memory issue):**
```bash
*/10 8-17 * * * /usr/bin/free -m >> /var/log/perf_report.log
```

**Option C — add a timestamp so you know when each sample was taken:**
```bash
*/10 8-17 * * * echo "=== $(date) ===" >> /var/log/perf_report.log && /usr/bin/free -m >> /var/log/perf_report.log
```

Save and quit: `:wq`

**Step 3 — Verify the crontab was saved:**

```bash
crontab -l
```

**Decoding `*/10 8-17 * * *` from the lecture format:**

```
Min   Hour   Day(month)  Month   Day(week)
*/10   8-17      *          *        *
 ↑      ↑
every  between
10min  8am-5pm
```

- `*/10` = every 10 minutes (0:00, 0:10, 0:20 ... 0:50 of every hour)
- `8-17` = only when the hour is between 8 and 17 (8 AM to 5 PM)
- `*` × 3 = every day, every month, every day of week

> 📌 **Lecture note:** The lecture shows the format as `Min Hours Day Month Day command` and gives examples like `*/20` for "every 20 minutes." The `*/10` you see here follows exactly that same pattern.

---

## Q13 — Use mail as root to check for email from cron jobs

### 🧠 The Story

By default, cron captures any **output** that your command produces (anything printed to the screen) and emails it to the user listed in `MAILTO`. Since the default is `MAILTO=root`, everything your cron job prints lands in root's mailbox. The lecture shows this default in `/etc/anacrontab`:

```
MAILTO=root
```

### ✅ CentOS Solution

Wait for at least one 10-minute interval to pass, or test with a job that runs every minute temporarily. Then:

```bash
mail
```

You'll see entries from `(Cron Daemon)` or `root@localhost` containing the output of your `free -m` command:

```
N  1 (Cron Daemon)   Mon Feb 26 08:10   "Cron <root@localhost> /usr/bin/free -m"
```

Type `1` to read it. You'll see the actual `free -m` output inside.

> 💡 **To test immediately without waiting 10 minutes**, add a temporary 1-minute job:
> ```bash
> crontab -e
> # Add: * * * * * /usr/bin/free -m
> # Wait 1 minute, check mail, then remove this line
> ```

---

## Q14 — Send cron output to the manager user instead of root

### 🧠 The Story

Your manager wants to receive these performance reports directly in their own mailbox, not have you forward them manually every time. The `MAILTO` variable in the crontab controls exactly this.

### ✅ CentOS Solution

**Step 1 — Make sure the manager user exists:**

```bash
id manager
# If not found:
useradd manager
passwd manager
```

**Step 2 — Edit your crontab and add `MAILTO`:**

```bash
crontab -e
```

Add `MAILTO=manager` **before** the cron job line:

```bash
MAILTO=manager
*/10 8-17 * * * /usr/bin/free -m >> /var/log/perf_report.log
```

Save and quit: `:wq`

Now cron will email the output to the `manager` user's mailbox instead of root's.

> 📌 **How `MAILTO` works:** It's a variable that goes at the top of the crontab (or before a specific job). `MAILTO=root` → emails root. `MAILTO=manager` → emails manager. `MAILTO=""` → no email at all (silent mode). The lecture shows `MAILTO=root` as the default in the system crontab.

> 💡 **You can have different `MAILTO` for different jobs** by placing it right before each job:
> ```bash
> MAILTO=manager
> */10 8-17 * * * /usr/bin/free -m
>
> MAILTO=root
> 0 2 * * * /usr/bin/backup.sh
> ```

---

## Q15 — Use mail as the manager user to check for email

### ✅ CentOS Solution

Switch to the manager user and read their mailbox:

```bash
su - manager
mail
```

Or as root, you can read another user's mailbox directly:

```bash
cat /var/spool/mail/manager
```

You should see the cron job output emails that were redirected there by the `MAILTO=manager` setting.

---

<a name="part-4"></a>
# 🔐 PART 4 — Advanced Permissions (Q16)

## 📖 Lecture Connection

The lecture covers **Special Permissions** including SGID on directories. It shows:
```bash
chmod g+s executable1
ls -l
-rwsr-xr-x ...
```

When SGID is applied to a **directory** (not just a file), new files created inside inherit the directory's group — not the creator's primary group. Combined with **ACLs** (`setfacl`), this lets you build the exact access structure the lab requires.

---

## Q16 — Create `/opt/research` with the required permissions

### 🧠 The Story

A university department has a shared research results directory. Four different groups of people need it, each with different access levels. Standard `chmod` only has three permission slots (owner, group, others) — nowhere near enough. This is a real-world problem that ACLs were designed to solve.

**Full requirements:**
- The directory is owned by `root`
- New files inside automatically belong to group `grads` (setgid does this)
- `profs` group: read + write access to new files automatically
- `grads` group: full access (read, write, create files)
- `interns` group: read-only access to new files automatically
- `others`: zero access — can't even see what's inside

### ✅ CentOS Solution — Step by Step

**Step 0 — Install ACL support and create the groups (if they don't exist):**

```bash
# ACL tools are usually pre-installed on CentOS 7, but just in case:
yum install acl -y

# Create the groups
groupadd grads
groupadd profs
groupadd interns
```

**Step 1 — Create the directory:**

```bash
mkdir /opt/research
```

**Step 2 — Set ownership to root:grads and apply the setgid + permissions:**

```bash
chown root:grads /opt/research
chmod 3770 /opt/research
```

Let's decode `3770` digit by digit:

```
3      7      7      0
↑      ↑      ↑      ↑
special owner  group  others
bits   rwx    rwx    ---

Special bit 3 = setgid(2) + sticky(1)
setgid → new files inside inherit group 'grads' automatically
sticky → only the file's owner can delete it (bonus protection)
```

Check what it looks like now:
```bash
ls -ld /opt/research
drwxrws--T. 2 root grads 6 Feb 26 10:00 /opt/research
#      ↑  ↑
#      s  T
#      |  └── sticky bit
#      └───── setgid active
```

**Step 3 — Set ACLs for current access to the directory:**

The base permissions already give `grads` full access (rwx via the group bit). Now we grant `profs` and `interns` access using ACLs:

```bash
# profs need to enter the directory (x) and read/write files inside (rw)
setfacl -m g:profs:rwx /opt/research

# interns can only read and enter (no write = cannot create or modify files)
setfacl -m g:interns:rx /opt/research

# Reinforce that others get absolutely nothing
setfacl -m o::--- /opt/research
```

**Step 4 — Set DEFAULT ACLs (this is what applies to NEW files created inside):**

Without this step, ACLs only protect the directory itself. Files created inside would have no ACLs. Default ACLs are automatically **inherited** by every new file and subdirectory created inside.

```bash
# New files: grads get full access
setfacl -d -m g:grads:rwx /opt/research

# New files: profs automatically get read+write
setfacl -d -m g:profs:rw /opt/research

# New files: interns automatically get read-only
setfacl -d -m g:interns:r /opt/research

# New files: others get nothing
setfacl -d -m o::--- /opt/research
```

> 📌 **The `-d` flag** stands for "default." Without `-d`, the ACL only applies to the directory itself. With `-d`, it's a template that stamps onto every new file created inside. This is the key to making the lab requirement work.

**Step 5 — Verify everything:**

```bash
getfacl /opt/research
```

Expected output:
```
# file: opt/research
# owner: root
# group: grads
# flags: -s-                    ← 's' = setgid is active
user::rwx
group::rwx
group:profs:rwx
group:interns:r-x
mask::rwx
other::---
default:user::rwx
default:group::rwx
default:group:profs:rw-
default:group:interns:r--
default:mask::rwx
default:other::---
```

**Step 6 — Test it (optional but smart):**

```bash
# Add a user to grads and test
usermod -aG grads testuser
su - testuser
touch /opt/research/newfile.txt   # should work
ls -l /opt/research/newfile.txt   # check the group — should be 'grads'
getfacl /opt/research/newfile.txt # ACLs should match defaults
```

---

<a name="part-5"></a>
# 🌐 PART 5 — Network Configuration (Q17–Q28)

## 📖 Lecture Connection

The lecture covers:
- `ifconfig` command for viewing and configuring interfaces
- `ip addr show` as the modern replacement
- `/etc/sysconfig/network-scripts/ifcfg-<interface>` as the config file
- Static vs DHCP configuration
- `NetworkManager` with graphical and command-line tools
- `/etc/sysconfig/network` for hostname and gateway
- `/etc/hosts` and `/etc/resolv.conf` for name resolution

> ⚠️ **CentOS 7 interface naming:** Run `ip addr show` to find your interface name before starting. Common names on VMs:
> - VMware: `ens33` or `ens160`
> - VirtualBox: `enp0s3`
> - KVM: `eth0` or `ens3`
>
> In all commands below, replace `eth0` with **your actual interface name**.

---

## Q17 — Display your MAC address in 2 different ways

### 🧠 The Story

A MAC address (Media Access Control) is the **hardware address** burned into your network card at manufacture — unique worldwide. The lecture mentions both `ifconfig` and `ip` for viewing it.

### ✅ CentOS Solution

**Way 1 — Using `ip link show`:**

```bash
ip link show
```

Look for the `link/ether` line:
```
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether 00:0c:29:ab:cd:ef brd ff:ff:ff:ff:ff:ff
#              ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
#              This is the MAC address
```

To show only a specific interface:
```bash
ip link show ens33
```

**Way 2 — Using `ifconfig`:**

```bash
ifconfig
```

Look for the `ether` value in the output:
```
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>
        ether 00:0c:29:ab:cd:ef  txqueuelen 1000  (Ethernet)
#             ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
```

Or filter directly:
```bash
ifconfig | grep ether
```

> 📌 **Lecture note:** The lecture says *"To view MAC address: ifconfig command, Use /sbin/ip command"* — both methods are directly from the lecture slides.

---

## Q18 — Display network settings of all ACTIVE interfaces

### ✅ CentOS Solution

**Method 1 — `ifconfig` (shows active interfaces only by default):**

```bash
ifconfig
```

**Method 2 — `ip addr show` (modern way, also shows active):**

```bash
ip addr show
```

> 📌 **Lecture note:** The lecture states *"To display the network settings of all active network devices: ifconfig"*

---

## Q19 — Display network settings of ALL interfaces (active AND inactive)

### ✅ CentOS Solution

**Method 1 — `ifconfig -a` (the `-a` means "all"):**

```bash
ifconfig -a
```

**Method 2 — `ip addr show` also shows all:**

```bash
ip addr show
```

The difference from Q18: inactive interfaces (those that are `DOWN`) will also appear. You'll see them with no IP address assigned and `<BROADCAST,MULTICAST>` without the `UP` flag.

> 📌 **Lecture note:** The lecture explicitly shows: *"To see both active and inactive network device setting: ifconfig -a"*

---

## Q20 — Bring your interface down

### 🧠 The Story

Bringing an interface down is like unplugging the network cable in software. The card is still physically there, but it's not communicating. You do this before reconfiguring an interface.

### ✅ CentOS Solution

```bash
# Method 1 — using the legacy ifdown script (reads the config file)
ifdown ens33

# Method 2 — using ip command
ip link set ens33 down

# Verify it's down:
ip addr show ens33
# The output will show: <BROADCAST,MULTICAST> without UP — it's down
```

> ⚠️ **If you're connected via SSH, bringing the interface down will disconnect you.** Do this from the physical console or VM console, not over SSH.

---

## Q21 — Configure your network card to have a static IP

### 🧠 The Story

By default, most CentOS installations use DHCP — the network automatically assigns an IP from a pool. But servers should have **static IPs** — fixed addresses that never change. If your server's IP changed every reboot, nobody could connect to it reliably.

### ✅ CentOS Solution

**Step 1 — Find your config file:**

```bash
ls /etc/sysconfig/network-scripts/
# Look for ifcfg-ens33 (or whatever your interface is named)
```

**Step 2 — Edit the config file:**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-ens33
```

**Step 3 — Set it up for static IP:**

Here's what the file should look like. The lecture shows exactly this format:

```bash
TYPE=Ethernet
DEVICE=ens33             # your interface name
ONBOOT=yes               # bring this up at every boot
BOOTPROTO=none           # "none" or "static" = manual IP (NOT dhcp)
IPADDR=192.168.1.100     # your chosen static IP address
PREFIX=24                # subnet prefix (/24 = 255.255.255.0)
NETMASK=255.255.255.0    # alternatively, use NETMASK instead of PREFIX
GATEWAY=192.168.1.1      # your router's IP
DNS1=8.8.8.8             # primary DNS (Google's)
DNS2=8.8.4.4             # secondary DNS
```

> 📌 **Lecture note:** The lecture shows this exact file format under "Editing interface configuration files" with `BOOTPROTO=static`, `IPADDR`, `PREFIX`, `GATEWAY`, `DNS1`. Use values appropriate for your network.

> 💡 **How to find your network's gateway and subnet:**
> Before changing to static, note your current DHCP-assigned values:
> ```bash
> ip addr show ens33     # note current IP and prefix
> ip route show          # note the 'default via' line = your gateway
> ```

---

## Q22 — Bring your interface up

### ✅ CentOS Solution

```bash
# Method 1 — using ifup (reads the config file you just edited)
ifup ens33

# Method 2 — using ip command
ip link set ens33 up

# Method 3 — using NetworkManager
nmcli con up ens33
```

> 💡 **`ifup` is smarter than `ip link set up`** for this use case — it reads your config file and applies ALL the settings (IP, gateway, DNS) in one step. `ip link set up` just brings the link layer up without applying IP settings.

---

## Q23 — Verify your network settings using `ifconfig`

### ✅ CentOS Solution

```bash
ifconfig ens33
```

You should see your static IP address in the output:
```
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
#           ↑↑↑↑↑↑↑↑↑↑↑↑↑  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
#           Your static IP   Your subnet mask
        ether 00:0c:29:ab:cd:ef  txqueuelen 1000  (Ethernet)
```

Also verify the gateway and DNS:
```bash
ip route show              # should show: default via 192.168.1.1
cat /etc/resolv.conf       # should show: nameserver 8.8.8.8

# Test connectivity:
ping -c 3 192.168.1.1      # ping the gateway
ping -c 3 8.8.8.8          # ping external IP (tests routing)
ping -c 3 google.com       # ping by name (tests DNS)
```

---

## Q24 — Configure your network card for dynamic IP using NetworkManager

### 🧠 The Story

Now we reverse Q21 — we go back to DHCP. The lecture mentions NetworkManager as the service that manages connections, and `nmcli` as its command-line tool.

### ✅ CentOS Solution

**Method 1 — Using `nmcli` (command-line NetworkManager):**

```bash
# Change the connection to use DHCP
nmcli con mod ens33 ipv4.method auto
nmcli con mod ens33 ipv4.addresses ""
nmcli con mod ens33 ipv4.gateway ""
nmcli con mod ens33 ipv4.dns ""

# Bring the connection down and up to apply changes
nmcli con down ens33
nmcli con up ens33
```

**Method 2 — Using `nmtui` (text-based UI — easier):**

```bash
nmtui
```

Navigate: Edit a connection → select ens33 → IPv4 Configuration → change from Manual to Automatic → OK → Back → Activate a connection → select ens33

**Method 3 — Edit the config file directly:**

```bash
vi /etc/sysconfig/network-scripts/ifcfg-ens33
```

Change:
```
BOOTPROTO=none    →    BOOTPROTO=dhcp
```

Remove or comment out:
```bash
# IPADDR=192.168.1.100
# NETMASK=255.255.255.0
# GATEWAY=192.168.1.1
# DNS1=8.8.8.8
```

Then restart networking:
```bash
systemctl restart NetworkManager
ifup ens33
```

> 📌 **Lecture note:** The lecture introduces NetworkManager and its graphical tool. `nmcli` is the command-line equivalent that does the same thing.

---

## Q25 — Check using `ifconfig`, then check the configuration file

### ✅ CentOS Solution

**Check the current live settings:**
```bash
ifconfig ens33
# If DHCP is working, you'll see an IP assigned by your DHCP server
# It will be different from your static 192.168.1.100
```

**Check the configuration file:**
```bash
cat /etc/sysconfig/network-scripts/ifcfg-ens33
# You should see BOOTPROTO=dhcp
# The IPADDR lines should be gone or commented out
```

Notice the difference: `ifconfig` shows the **live, currently active** settings. The config file shows what will happen **on the next interface restart**. They should match after you've applied the changes.

---

## Q26 — Reconfigure using `system-config-network` to have static IP

### 🧠 The Story

`system-config-network` is a text-mode UI (TUI) tool for configuring networking. It's easier than editing files by hand and good for students learning.

### ✅ CentOS Solution

**Step 1 — Install it (often not installed by default on CentOS 7):**

```bash
yum install system-config-network-tui -y
```

**Step 2 — Launch it:**

```bash
system-config-network
```

**Step 3 — Navigate the TUI:**

1. Select **Edit Devices**
2. Select your interface (e.g., `eth0` or `ens33`)
3. Press Enter to Edit
4. Change:
   - **Use DHCP**: uncheck this
   - **Static IP Address**: enter `192.168.1.100`
   - **Prefix**: `24` (or Netmask: `255.255.255.0`)
   - **Default gateway IP**: `192.168.1.1`
5. Select **OK**
6. Select **Save**
7. Select **Quit**

**Step 4 — Apply the changes:**

```bash
ifdown ens33 && ifup ens33
# or:
systemctl restart NetworkManager
```

**Step 5 — Verify:**

```bash
ifconfig ens33
```

---

## Q27 — Configure the network card to have 3 IPs and verify with `ifconfig`

### 🧠 The Story

IP aliasing lets you assign multiple IP addresses to a single physical interface. Each alias acts as a completely separate IP — you can ping each one, bind services to specific IPs, or host multiple websites on one machine with different IPs.

Think of it like a building that has one front door but three different mailboxes on it, each with a different address.

### ✅ CentOS Solution

We already have the main IP on `ens33` (e.g., `192.168.1.100`). Now we add two more.

**Create alias 1 — `ens33:1` with IP `192.168.1.101`:**

```bash
cp /etc/sysconfig/network-scripts/ifcfg-ens33 \
   /etc/sysconfig/network-scripts/ifcfg-ens33:1

vi /etc/sysconfig/network-scripts/ifcfg-ens33:1
```

Edit the file to look like this:
```bash
DEVICE=ens33:1           # must match the filename
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.1.101     # different IP
NETMASK=255.255.255.0
```

Remove any GATEWAY, DNS lines (only the primary interface needs those).

**Create alias 2 — `ens33:2` with IP `192.168.1.102`:**

```bash
cp /etc/sysconfig/network-scripts/ifcfg-ens33 \
   /etc/sysconfig/network-scripts/ifcfg-ens33:2

vi /etc/sysconfig/network-scripts/ifcfg-ens33:2
```

```bash
DEVICE=ens33:2
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.1.102
NETMASK=255.255.255.0
```

**Bring all aliases up:**

```bash
ifup ens33:1
ifup ens33:2
```

**Verify all three IPs appear:**

```bash
ifconfig
```

You should see three entries: `ens33`, `ens33:1`, and `ens33:2`, each with their respective IP.

```bash
# Test all three IPs respond to ping:
ping -c 2 192.168.1.100
ping -c 2 192.168.1.101
ping -c 2 192.168.1.102
```

---

## Q28 — Change the hostname in the global network file

### 🧠 The Story

The hostname is the machine's name on the network. The lecture shows it in `/etc/sysconfig/network` as `HOSTNAME=iti.gov.eg`. On CentOS 7, `hostnamectl` is the modern way, but the global network file still works.

### ✅ CentOS Solution

**Method 1 — `hostnamectl` (modern, recommended on CentOS 7):**

```bash
hostnamectl set-hostname myserver.example.com

# Verify:
hostname
hostnamectl status
```

**Method 2 — Edit the global network file (the lecture method):**

```bash
vi /etc/sysconfig/network
```

Add or change:
```bash
NETWORKING=yes
HOSTNAME=myserver.example.com
```

Save. The hostname change takes effect after reboot, or immediately with:
```bash
hostname myserver.example.com
```

**Method 3 — Edit `/etc/hostname` directly:**

```bash
vi /etc/hostname
# Replace the content with your new hostname:
myserver.example.com
```

**Update `/etc/hosts` so the system can resolve its own name:**

```bash
vi /etc/hosts
```

Make sure this line exists:
```
127.0.0.1   myserver.example.com myserver localhost
```

> 📌 **Lecture note:** The lecture shows `HOSTNAME=iti.gov.eg` inside `/etc/sysconfig/network` and also shows `/etc/hosts` mapping the hostname to an IP. Both files are part of local name resolution.

---

<a name="part-6"></a>
# 📋 PART 6 — Centralized Logging with rsyslog (Bonus Section)

## 📖 Lecture Connection

The lecture covers rsyslog in detail:
- Configuration at `/etc/rsyslog.conf`
- The selector format: `facility.severity action`
- Facilities: `kern`, `mail`, `daemon`, `cron`, `local0-7`, `*`
- Severity levels: `emerg`, `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`
- The `logger` command to manually send log messages
- Log files: `/var/log/messages`, `/var/log/secure`, `/var/log/maillog`
- `tail -f` for real-time log monitoring

---

## Setup — Centralized Logging Server on CentOS

### 🧠 The Story

Your boss wants one central place to collect logs from all machines. Currently every server writes to its own `/var/log/messages`. He wants one **logging server** that receives messages from all workstations. This makes security auditing and troubleshooting dramatically easier.

### ✅ CentOS Solution

**On the LOGGING SERVER machine:**

```bash
# Step 1: Edit rsyslog config to accept remote messages
vi /etc/rsyslog.conf

# Find and UNCOMMENT these lines (remove the # at the start):
$ModLoad imudp
$UDPServerRun 514
```

```bash
# Step 2: Restart rsyslog to apply the change
systemctl restart rsyslog

# Step 3: Verify rsyslog is listening on port 514
ss -tulnp | grep 514
# or:
netstat -tulnp | grep 514
```

```bash
# Step 4: Open the firewall on CentOS 7
firewall-cmd --permanent --add-port=514/udp
firewall-cmd --reload

# Verify the rule is in place:
firewall-cmd --list-ports
```

**On each WORKSTATION machine:**

```bash
# Step 1: Edit rsyslog config to forward to the server
vi /etc/rsyslog.conf

# Add this line at the bottom:
*.* @192.168.1.10:514
# Replace 192.168.1.10 with your actual logging server IP
# @ = UDP   @@ = TCP (TCP is more reliable for production)

# Step 2: Restart rsyslog
systemctl restart rsyslog
```

**Test the setup:**

```bash
# On the WORKSTATION — generate a test log message using logger:
logger 'Hello from workstation - testing centralized logging'

# On the LOGGING SERVER — watch for it arriving in real time:
tail -f /var/log/messages
```

The lecture specifically shows this `tail -f` command for real-time monitoring. You should see a line like:
```
Feb 26 10:30:01 workstation1 root: Hello from workstation - testing centralized logging
```

---

## ❓ Lab Question: Does the message appear in the logging server's `/var/log/messages`?

**Answer: Yes** — if the setup is correct. The message you sent with `logger` on the workstation will appear in the logging server's `/var/log/messages` file.

---

## ❓ Lab Question: Why does the message ALSO appear in the workstation's `/var/log/messages`?

**Answer:** Because rsyslog processes messages by applying **every matching rule** in `/etc/rsyslog.conf`, not just the first one it finds.

When you run `logger 'test'` on the workstation:
1. rsyslogd receives the message locally
2. It reads the config top to bottom
3. It finds the rule `*.info /var/log/messages` → **writes to local log**
4. It also finds `*.* @192.168.1.10:514` → **forwards to server**
5. Both actions happen. Both locations get the message.

---

## ❓ Lab Question: How could you make the message appear ONLY on the logging server?

**Answer:** Use the **discard action** (`& ~`) immediately after the forwarding rule. This tells rsyslog: "after forwarding this message, throw it away — don't write it anywhere else."

```bash
vi /etc/rsyslog.conf

# Change from:
*.* @192.168.1.10:514

# To:
*.* @192.168.1.10:514
& ~
```

The `& ~` means:
- `&` = "apply this action to the same messages as the previous rule"
- `~` = "discard — do not process further"

Now messages are forwarded to the server and immediately discarded locally. The workstation's `/var/log/messages` will stop receiving them.

> 📌 **Lecture connection:** The lecture shows `logger` being used to manually generate log messages, and `tail -f /var/log/messages` for real-time monitoring — both are used to test this entire setup.

---

# ⚡ CentOS Quick-Reference Card

```bash
# ── SYSTEMD ──────────────────────────────────────────────────
systemctl list-units --type=service [--all]
systemctl {start|stop|restart|status} postfix
systemctl {enable|disable|is-enabled} postfix
systemctl {get-default|set-default|isolate} multi-user.target

# ── GRUB2 ────────────────────────────────────────────────────
vi /etc/default/grub             # GRUB_TIMEOUT=20 / GRUB_DEFAULT=1
grub2-mkconfig -o /boot/grub2/grub.cfg    # ALWAYS run after editing

# ── CRON ─────────────────────────────────────────────────────
crontab {-e|-l|-r}
# MIN  HOUR  DOM  MON  DOW  command
*/10  8-17   *    *    *   /usr/bin/free -m >> /var/log/perf.log
MAILTO=manager   # at top of crontab

# ── NETWORKING ───────────────────────────────────────────────
ip addr show / ifconfig -a
ip link show / ifconfig | grep ether         # MAC address
ifdown ens33 / ifup ens33
nmcli con mod ens33 ipv4.method {auto|manual}
nmcli con up ens33
hostnamectl set-hostname name
# Static IP config: /etc/sysconfig/network-scripts/ifcfg-ens33
#   BOOTPROTO=none / IPADDR= / NETMASK= / GATEWAY= / ONBOOT=yes

# ── ACLS ─────────────────────────────────────────────────────
chown root:grads /opt/research
chmod 3770 /opt/research                  # setgid + rwxrwx---
setfacl -m g:profs:rwx /opt/research     # current ACL
setfacl -d -m g:profs:rw /opt/research   # default ACL (new files)
getfacl /opt/research                     # verify

# ── RSYSLOG ──────────────────────────────────────────────────
# Logging server: /etc/rsyslog.conf → $ModLoad imudp + $UDPServerRun 514
# Workstation: /etc/rsyslog.conf → *.* @server_ip:514
# Local discard: & ~
logger 'test message'
tail -f /var/log/messages
```

---
*CentOS Lab Solutions Complete ✅ — Good luck on your exam!*
