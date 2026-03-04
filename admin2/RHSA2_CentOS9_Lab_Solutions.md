# 🐧 RHSA2 Lab 1 — Complete Solutions on CentOS 9 Stream
## With Explanations & Lecture Connections
**ITI Open Source Track — Corrected for CentOS 9 Stream**

---

> 💡 **CentOS 9 Stream — What Changed from CentOS 7**
>
> This document is fully corrected for **CentOS 9 Stream on VirtualBox**. Major changes from CentOS 7:
>
> | Area | CentOS 7 (old) | CentOS 9 (use this) |
> |------|---------------|---------------------|
> | Package manager | `yum` | `dnf` (`yum` still works as alias) |
> | Mail client package | `mailx` | `s-nail` |
> | Interface name | `ens33` | `enp0s3` (VirtualBox default) |
> | Network config files | `/etc/sysconfig/network-scripts/ifcfg-*` | NetworkManager keyfiles + `nmcli` |
> | Bring interface up/down | `ifup` / `ifdown` | `nmcli con up/down` |
> | Virtual IP aliases | `ifcfg-ens33:1` | `nmcli +ipv4.addresses` |
> | `ifconfig` | installed by default | `dnf install net-tools` first |
>
> Your interface is **`enp0s3`** throughout this document.

---

> 🔍 **First thing — detect your boot mode (BIOS or UEFI). Run this once:**
> ```bash
> [ -d /sys/firmware/efi ] && echo "YOU ARE ON UEFI" || echo "YOU ARE ON BIOS"
> ```
> This matters for the GRUB section. The command to use differs between the two.

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

`systemd` is the **parent of all processes** (PID 1). It manages services using `systemctl`. Key commands:
- `systemctl start/stop [service_name]`
- `systemctl status [service_name]`
- `systemctl enable/disable [service_name]`
- `systemctl list-unit-files --type service`

---

## Q1 — Use `systemctl` to view the status of all system services

### ✅ CentOS 9 Solution

```bash
# Show all currently loaded service units (runtime state):
systemctl list-units --type=service

# Include services that aren't loaded at all:
systemctl list-units --type=service --all

# Show which services are enabled/disabled at boot:
systemctl list-unit-files --type service
```

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

### ✅ CentOS 9 Solution

```bash
# Step 1: Check your current default
systemctl get-default

# Step 2: Change to multi-user (text-only server mode)
systemctl set-default multi-user.target

# Step 3: Verify
systemctl get-default
# Should output: multi-user.target

# Step 4: Reboot
reboot
```

After rebooting you'll land at a text login prompt — no GUI.

> ⚠️ **To get back to GUI later (if needed):**
> ```bash
> systemctl set-default graphical.target
> reboot
> ```

---

## Q3 — Send mail to the root user

### ✅ CentOS 9 Solution

> ⚠️ **CentOS 9 Change:** The package `mailx` no longer exists. Install `s-nail` instead — it provides the same `mail` command.

```bash
# Step 1: Install postfix
dnf install postfix -y

# Step 2: Install s-nail (provides the 'mail' command — NOT 'mailx' on CentOS 9)
dnf install s-nail -y

# Step 3: Start and enable postfix
systemctl start postfix
systemctl enable postfix

# Step 4: Verify postfix is running
systemctl status postfix
```

Now send the mail:

```bash
echo 'This is the body of the test email' | mail -s 'Test Email Q3' root
```

**Breaking this down:**
- `echo 'body'` — creates the message body
- `|` — pipes it as input to the `mail` command
- `-s 'Test Email Q3'` — sets the Subject line
- `root` — the recipient (root user on this machine)

---

## Q4 — Verify that you received the mail

### ✅ CentOS 9 Solution

```bash
mail
```

You'll see something like:
```
s-nail version 14.9.xx  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.localdomain  [date]  "Test Email Q3"
```

- Type `1` and press Enter to read message 1
- Type `q` to quit

Or read the raw mailbox file directly:

```bash
cat /var/spool/mail/root
```

---

## Q5 — Use `systemctl` to stop the `postfix` service

### ✅ CentOS 9 Solution

```bash
systemctl stop postfix
```

Verify it's stopped:

```bash
systemctl status postfix
# Active: inactive (dead)
```

---

## Q6 — Send mail again to the root user (postfix is stopped)

### ✅ CentOS 9 Solution

```bash
echo 'Postfix is stopped, will this arrive?' | mail -s 'Test Email Q6' root
```

The command appears to succeed — no error. But the mail has NOT been delivered. It's **queued**.

Check the queue:
```bash
# The correct command to view postfix queue:
mailq

# Or check postfix's own spool directory:
ls /var/spool/postfix/deferred/
```

> ⚠️ **CentOS 9 note:** On CentOS 9 with postfix, the mail queue is managed by postfix internally. The old `/var/spool/mqueue/` was for sendmail — it doesn't apply here. Use `mailq` to see what's waiting.

---

## Q7 — Verify that you received the mail (postfix still stopped)

### ✅ CentOS 9 Solution

```bash
mail
```

You'll only see the Q3 message. The Q6 message is in the postfix queue, not yet delivered.

```bash
# Confirm it's queued:
mailq
# Should show 1 message waiting for delivery
```

---

## Q8 — Use `systemctl` to start the `postfix` service

### ✅ CentOS 9 Solution

```bash
systemctl start postfix

# Verify it's running:
systemctl status postfix
# Active: active (running)
```

Postfix will immediately process the queue and deliver the Q6 message.

---

## Q9 — Verify that you received the mail (postfix running again)

### ✅ CentOS 9 Solution

```bash
mail
```

Now you'll see **two messages** — Q3 and Q6. The Q6 message timestamp shows when it was delivered (when postfix came back up), not when it was sent.

```bash
# Confirm queue is now empty:
mailq
# Should show: Mail queue is empty
```

---

<a name="part-2"></a>
# 🥾 PART 2 — GRUB2 Bootloader (Q10–Q11)

## 📖 Lecture Connection

- `/boot/grub2/grub.cfg` — the real config file, **never edit directly**
- `/etc/default/grub` — where **you** make your changes
- After any change to `/etc/default/grub`, **must** run `grub2-mkconfig` to regenerate

---

## Q10 — Change the GRUB2 timeout to 20 seconds

### ✅ CentOS 9 Solution

**Step 1 — First, detect your boot mode:**

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
```

**Step 2 — Edit the settings file:**

```bash
vi /etc/default/grub
```

Find `GRUB_TIMEOUT=5` and change it to:
```
GRUB_TIMEOUT=20
```

Save: `:wq`

**Step 3 — Regenerate GRUB config (use the right command for your boot mode):**

```bash
# If BIOS:
grub2-mkconfig -o /boot/grub2/grub.cfg

# If UEFI:
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
```

**Step 4 — Verify:**

```bash
# If BIOS:
grep timeout /boot/grub2/grub.cfg

# If UEFI:
grep timeout /boot/efi/EFI/centos/grub.cfg
# Should show: set timeout=20
```

> ⚠️ **Most common mistake:** Editing `/boot/grub2/grub.cfg` directly. It gets overwritten on the next `grub2-mkconfig` run (e.g., after a kernel update). Always edit `/etc/default/grub` and regenerate.

---

## Q11 — Change the default operating system in GRUB2

### ✅ CentOS 9 Solution

**Step 1 — List menu entries:**

```bash
# If BIOS:
awk -F\' '/^menuentry / {print NR-1": "$2}' /boot/grub2/grub.cfg

# If UEFI:
awk -F\' '/^menuentry / {print NR-1": "$2}' /boot/efi/EFI/centos/grub.cfg
```

Example output:
```
0: CentOS Stream (5.14.0-xxx.el9.x86_64) 9
1: CentOS Stream (0-rescue-...) 9
```

**Step 2 — Edit `/etc/default/grub`:**

```bash
vi /etc/default/grub
```

Change `GRUB_DEFAULT=saved` to the index number you want:
```
GRUB_DEFAULT=1
```

**Step 3 — Regenerate (same command as Q10 for your boot mode):**

```bash
# BIOS:
grub2-mkconfig -o /boot/grub2/grub.cfg

# UEFI:
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
```

---

<a name="part-3"></a>
# 📅 PART 3 — Scheduling with cron (Q12–Q15)

## 📖 Lecture Connection

Crontab format:
```
Min(0-59)  Hours(0-23)  Day(1-31)  Month(1-12)  DayOfWeek(0-6)  command
```

`MAILTO=root` in the crontab causes cron output to be emailed to that user.

---

## ⚠️ CRITICAL CentOS 9 Setup for This Entire Section

**Before doing Q12–Q15, run all of these:**

```bash
# 1. Install postfix (mail delivery)
dnf install postfix -y
systemctl start postfix
systemctl enable postfix

# 2. Install s-nail (provides the 'mail' command — replaces 'mailx' on CentOS 9)
dnf install s-nail -y

# 3. Verify the 'mail' command is available:
which mail
# Should output: /usr/bin/mail

# 4. Make sure crond is running
systemctl start crond
systemctl enable crond
systemctl status crond
```

> ⚠️ **Why `s-nail` and not `mailx`?**
> On CentOS 9, the package `mailx` was replaced by `s-nail`. Both provide the exact same `mail` command you use in the terminal — the package name just changed. After installing `s-nail`, everything in this section works identically.

---

## Q12 — Monitor system resources every 10 minutes, 8 AM to 5 PM, focusing on memory

### ✅ CentOS 9 Solution

**Step 1 — Edit your crontab:**

```bash
crontab -e
```

This opens in `vi`. Add one of these lines:

**Option A — `free -m` (memory and swap — focused on the memory issue):**
```
*/10 8-17 * * * /usr/bin/free -m >> /var/log/perf_report.log
```

**Option B — `vmstat` (CPU, memory, swap, IO — broader picture):**
```
*/10 8-17 * * * /usr/bin/vmstat 1 1 >> /var/log/perf_report.log
```

**Option C — with timestamps (recommended — shows when each sample was taken):**
```
*/10 8-17 * * * echo "=== $(date) ===" >> /var/log/perf_report.log && /usr/bin/free -m >> /var/log/perf_report.log
```

Save and quit: `:wq`

**Step 2 — Verify it was saved:**

```bash
crontab -l
```

**Decoding `*/10 8-17 * * *`:**

```
Min    Hour   Day(month)  Month   Day(week)
*/10   8-17      *          *        *
 ↑       ↑
every  between
10min  8am-5pm
```

- `*/10` = every 10 minutes (at :00, :10, :20, :30, :40, :50 of each hour)
- `8-17` = only when the hour is 8 through 17 (8 AM to 5 PM)
- `*` × 3 = every day, every month, every weekday

---

## Q13 — Use mail as root to check for email from cron jobs

### ✅ CentOS 9 Solution

By default, cron emails any output your command produces to the `MAILTO` user (default: root).

Wait for at least one 10-minute interval, or **test immediately with a 1-minute job:**

```bash
crontab -e
# Add this temporary line at the top:
* * * * * /usr/bin/free -m
```

Wait ~1 minute, then:

```bash
mail
```

You'll see an entry from `Cron Daemon`:
```
N  1 (Cron Daemon)  [date]  "Cron <root@localhost> /usr/bin/free -m"
```

Type `1` to read it — you'll see the actual `free -m` output inside.

**After testing, remove the 1-minute job:**
```bash
crontab -e
# Delete the '* * * * *' test line, keep your real job
```

> 💡 **If `mail` shows nothing after waiting:** Check that postfix is actually running (`systemctl status postfix`) and that s-nail is installed (`which mail`).

---

## Q14 — Send cron output to the manager user instead of root

### ✅ CentOS 9 Solution

**Step 1 — Create the manager user:**

```bash
id manager 2>/dev/null || useradd manager
passwd manager
```

**Step 2 — Edit your crontab:**

```bash
crontab -e
```

Add `MAILTO=manager` **before** your cron job line:

```
MAILTO=manager
*/10 8-17 * * * /usr/bin/free -m >> /var/log/perf_report.log
```

Save: `:wq`

Now cron emails the output to `manager`'s mailbox instead of root's.

> 📌 **How `MAILTO` works:**
> - `MAILTO=root` → emails root (default)
> - `MAILTO=manager` → emails manager
> - `MAILTO=""` → no email at all (silent mode)

> 💡 **You can have different `MAILTO` per job:**
> ```
> MAILTO=manager
> */10 8-17 * * * /usr/bin/free -m
>
> MAILTO=root
> 0 2 * * * /usr/bin/du -sh /var
> ```

---

## Q15 — Use mail as the manager user to check for email

### ✅ CentOS 9 Solution

```bash
# Switch to manager user and read their mail:
su - manager
mail
```

Or check their mailbox directly as root (faster for testing):

```bash
cat /var/spool/mail/manager
```

You should see the cron output emails redirected there by `MAILTO=manager`.

> 💡 **If the manager mailbox is empty:** Trigger a test immediately:
> ```bash
> crontab -e
> # Temporarily add: * * * * * /usr/bin/free -m
> # Wait 1 minute, check /var/spool/mail/manager, then remove the test line
> ```

---

<a name="part-4"></a>
# 🔐 PART 4 — Advanced Permissions (Q16)

---

## Q16 — Create `/opt/research` with the required permissions

**Requirements:**
- Owned by `root`, group `grads`
- New files inside automatically belong to group `grads` (setgid)
- `profs` group: read + write on new files
- `grads` group: full access
- `interns` group: read-only on new files
- `others`: zero access

### ✅ CentOS 9 Solution

**Step 0 — Install ACL tools and create groups:**

```bash
dnf install acl -y

groupadd grads
groupadd profs
groupadd interns
```

**Step 1 — Create the directory:**

```bash
mkdir /opt/research
```

**Step 2 — Set ownership and permissions:**

```bash
chown root:grads /opt/research
chmod 3770 /opt/research
```

Decoding `3770`:
```
3      7      7      0
↑      ↑      ↑      ↑
special owner  group  others
bits   rwx    rwx    ---

Special bit 3 = setgid(2) + sticky(1)
setgid → new files inside inherit group 'grads'
sticky → only file owner can delete their own files
```

Verify:
```bash
ls -ld /opt/research
# drwxrws--T. 2 root grads ...
#        ↑  ↑
#        s  T  (setgid + sticky)
```

**Step 3 — Set ACLs for directory access:**

```bash
setfacl -m g:profs:rwx /opt/research
setfacl -m g:interns:rx /opt/research
setfacl -m o::--- /opt/research
```

**Step 4 — Set DEFAULT ACLs (inherited by new files inside):**

```bash
setfacl -d -m g:grads:rwx /opt/research
setfacl -d -m g:profs:rw /opt/research
setfacl -d -m g:interns:r /opt/research
setfacl -d -m o::--- /opt/research
```

**Step 5 — Verify:**

```bash
getfacl /opt/research
```

Expected output:
```
# file: opt/research
# owner: root
# group: grads
# flags: -s-
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

---

<a name="part-5"></a>
# 🌐 PART 5 — Network Configuration (Q17–Q28)

## 📖 CentOS 9 — Major Networking Changes

> ⚠️ **This section has the most breaking changes from CentOS 7.**
>
> | What changed | CentOS 7 | CentOS 9 |
> |---|---|---|
> | Interface name | `ens33` | **`enp0s3`** (VirtualBox) |
> | Config files | `/etc/sysconfig/network-scripts/ifcfg-*` | **Deprecated** — use `nmcli` |
> | `ifup` / `ifdown` | Available | **Not available** — use `nmcli` |
> | `ifconfig` | Pre-installed | `dnf install net-tools` first |
> | Virtual IPs | `ifcfg-ens33:1` alias files | `nmcli +ipv4.addresses` |

**First, install net-tools to get `ifconfig`:**
```bash
dnf install net-tools -y
```

---

## Q17 — Display your MAC address in 2 different ways

### ✅ CentOS 9 Solution

**Way 1 — `ip link show`:**

```bash
ip link show enp0s3
```

Look for the `link/ether` line:
```
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether 08:00:27:ab:cd:ef brd ff:ff:ff:ff:ff:ff
#              ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑  This is the MAC address
```

**Way 2 — `ifconfig` (after installing net-tools):**

```bash
ifconfig enp0s3
# or to extract just the MAC:
ifconfig enp0s3 | grep ether
```

---

## Q18 — Display network settings of all ACTIVE interfaces

### ✅ CentOS 9 Solution

```bash
# Modern way (works without extra packages):
ip addr show

# Classic way (requires: dnf install net-tools):
ifconfig
```

---

## Q19 — Display network settings of ALL interfaces (active AND inactive)

### ✅ CentOS 9 Solution

```bash
# Modern way — shows all including DOWN interfaces:
ip addr show

# Classic way:
ifconfig -a
```

---

## Q20 — Bring your interface down

### ✅ CentOS 9 Solution

> ⚠️ **`ifdown` does NOT exist on CentOS 9.** Use `nmcli` or `ip`.

```bash
# Method 1 — nmcli (recommended — works with NetworkManager):
nmcli con down enp0s3

# Method 2 — ip command:
ip link set enp0s3 down

# Verify it's down:
ip addr show enp0s3
# Will show <BROADCAST,MULTICAST> without UP flag
```

> ⚠️ **If you're connected via SSH, bringing the interface down will disconnect you.** Use the VirtualBox console window instead.

---

## Q21 — Configure your network card to have a static IP

### ✅ CentOS 9 Solution

> ⚠️ **CentOS 9 Change:** `/etc/sysconfig/network-scripts/ifcfg-*` files are deprecated. The correct way is `nmcli` or editing NetworkManager keyfiles.

**First, note your current network values before changing:**
```bash
ip addr show enp0s3    # note current IP and prefix
ip route show          # note the 'default via' line = your gateway
```

**Method 1 — `nmcli` (recommended):**

```bash
# Set static IP, gateway, and DNS:
nmcli con mod "enp0s3" \
  ipv4.method manual \
  ipv4.addresses "192.168.1.100/24" \
  ipv4.gateway "192.168.1.1" \
  ipv4.dns "8.8.8.8 8.8.4.4"

# Apply the changes:
nmcli con up "enp0s3"
```

**Method 2 — Edit the NetworkManager keyfile directly:**

```bash
# The keyfile is here on CentOS 9:
ls /etc/NetworkManager/system-connections/

# Edit it (filename matches your connection name):
vi /etc/NetworkManager/system-connections/enp0s3.nmconnection
```

The file uses INI format. The `[ipv4]` section should look like:
```ini
[ipv4]
method=manual
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;8.8.4.4;
```

After editing, reload and apply:
```bash
nmcli con reload
nmcli con up "enp0s3"
```

---

## Q22 — Bring your interface up

### ✅ CentOS 9 Solution

> ⚠️ **`ifup` does NOT exist on CentOS 9.** Use `nmcli`.

```bash
# nmcli — brings interface up and applies all settings from config:
nmcli con up "enp0s3"

# Or using ip (brings link layer up only, doesn't re-apply IP settings):
ip link set enp0s3 up
```

> 💡 **Use `nmcli con up`** after editing network settings — it reads the full configuration (IP, gateway, DNS) and applies everything in one step.

---

## Q23 — Verify your network settings using `ifconfig`

### ✅ CentOS 9 Solution

```bash
ifconfig enp0s3
```

Expected output:
```
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
        ether 08:00:27:ab:cd:ef  txqueuelen 1000  (Ethernet)
```

Also verify gateway and DNS:
```bash
ip route show           # should show: default via 192.168.1.1
cat /etc/resolv.conf    # should show: nameserver 8.8.8.8

# Test connectivity:
ping -c 3 192.168.1.1   # ping the gateway
ping -c 3 8.8.8.8       # ping external IP (tests routing)
ping -c 3 google.com    # ping by name (tests DNS)
```

---

## Q24 — Configure your network card for dynamic IP using NetworkManager

### ✅ CentOS 9 Solution

**Method 1 — `nmcli` (command-line):**

```bash
nmcli con mod "enp0s3" ipv4.method auto
nmcli con mod "enp0s3" ipv4.addresses ""
nmcli con mod "enp0s3" ipv4.gateway ""
nmcli con mod "enp0s3" ipv4.dns ""

nmcli con down "enp0s3"
nmcli con up "enp0s3"
```

**Method 2 — `nmtui` (text-based UI — easiest):**

```bash
nmtui
```

Navigate to: **Edit a connection** → select `enp0s3` → change IPv4 Configuration from `Manual` to `Automatic` → OK → Back → **Activate a connection** → select `enp0s3`.

---

## Q25 — Display your IP address in 2 different ways

### ✅ CentOS 9 Solution

```bash
# Way 1 — ip command (modern):
ip addr show enp0s3

# Way 2 — ifconfig (classic, requires net-tools):
ifconfig enp0s3

# To extract just the IP address:
ip addr show enp0s3 | grep "inet " | awk '{print $2}'
```

---

## Q26 — Display the default gateway

### ✅ CentOS 9 Solution

```bash
# Way 1:
ip route show
# Look for: default via 192.168.x.x dev enp0s3

# Way 2:
ip route | grep default

# Way 3 (classic):
netstat -rn
# Requires: dnf install net-tools
```

---

## Q27 — Add two more IP addresses to your network interface

### ✅ CentOS 9 Solution

> ⚠️ **CentOS 9 Change:** Virtual alias files (`ifcfg-enp0s3:1`, `ifcfg-enp0s3:2`) are **gone**. On CentOS 9, you add secondary IPs to the same connection using `nmcli`.

```bash
# Add a second IP address:
nmcli con mod "enp0s3" +ipv4.addresses "192.168.1.101/24"

# Add a third IP address:
nmcli con mod "enp0s3" +ipv4.addresses "192.168.1.102/24"

# Apply the changes:
nmcli con up "enp0s3"
```

**Verify all three IPs are active:**

```bash
ip addr show enp0s3
```

You should see three `inet` lines:
```
inet 192.168.1.100/24 ...
inet 192.168.1.101/24 ...
inet 192.168.1.102/24 ...
```

```bash
# Test all three respond to ping:
ping -c 2 192.168.1.100
ping -c 2 192.168.1.101
ping -c 2 192.168.1.102
```

**To remove the extra IPs later:**
```bash
nmcli con mod "enp0s3" -ipv4.addresses "192.168.1.101/24"
nmcli con mod "enp0s3" -ipv4.addresses "192.168.1.102/24"
nmcli con up "enp0s3"
```

---

## Q28 — Change the hostname in the global network file

### ✅ CentOS 9 Solution

**Method 1 — `hostnamectl` (modern, recommended):**

```bash
hostnamectl set-hostname myserver.example.com

# Verify:
hostname
hostnamectl status
```

**Method 2 — Edit `/etc/hostname` directly:**

```bash
vi /etc/hostname
# Replace the content with:
myserver.example.com
```

**Method 3 — `/etc/sysconfig/network` (lecture method — still works on CentOS 9):**

```bash
vi /etc/sysconfig/network
```

Add or change:
```
NETWORKING=yes
HOSTNAME=myserver.example.com
```

Takes effect after reboot, or immediately:
```bash
hostname myserver.example.com
```

**Always update `/etc/hosts` so the system can resolve its own name:**

```bash
vi /etc/hosts
```

Make sure this line exists:
```
127.0.0.1   myserver.example.com myserver localhost
```

---

<a name="part-6"></a>
# 📋 PART 6 — Centralized Logging with rsyslog (Bonus)

---

## Setup — Centralized Logging Server on CentOS 9

**On the LOGGING SERVER machine:**

```bash
# Step 1: Edit rsyslog config to accept remote messages
vi /etc/rsyslog.conf

# Find and UNCOMMENT these lines (remove the # at the start):
$ModLoad imudp
$UDPServerRun 514
```

```bash
# Step 2: Restart rsyslog
systemctl restart rsyslog

# Step 3: Verify rsyslog is listening on port 514
ss -tulnp | grep 514
```

```bash
# Step 4: Open the firewall on CentOS 9
firewall-cmd --permanent --add-port=514/udp
firewall-cmd --reload
firewall-cmd --list-ports
```

**On each WORKSTATION machine:**

```bash
vi /etc/rsyslog.conf

# Add this line at the bottom:
*.* @192.168.1.10:514
# Replace 192.168.1.10 with your actual logging server IP
# @ = UDP   @@ = TCP

systemctl restart rsyslog
```

**Test the setup:**

```bash
# On WORKSTATION — generate a test log message:
logger 'Hello from workstation - testing centralized logging'

# On LOGGING SERVER — watch for it in real time:
tail -f /var/log/messages
```

---

## ❓ Why does the message ALSO appear in the workstation's `/var/log/messages`?

Because rsyslog processes **every matching rule** in `/etc/rsyslog.conf`, not just the first one. Both the local write rule AND the forwarding rule match, so both actions happen.

## ❓ How to make the message appear ONLY on the logging server?

Use the **discard action** (`& ~`):

```bash
vi /etc/rsyslog.conf

# Change from:
*.* @192.168.1.10:514

# To:
*.* @192.168.1.10:514
& ~
```

`& ~` means: "for the same messages as the previous rule, discard — don't process further."

---

# ⚡ CentOS 9 Quick-Reference Card

```bash
# ── SYSTEMD ──────────────────────────────────────────────────
systemctl list-units --type=service [--all]
systemctl {start|stop|restart|status} postfix
systemctl {enable|disable|is-enabled} postfix
systemctl {get-default|set-default} multi-user.target

# ── MAIL (CentOS 9) ──────────────────────────────────────────
dnf install s-nail postfix -y          # NOT 'mailx' on CentOS 9
echo 'body' | mail -s 'subject' root
mail                                   # read inbox
mailq                                  # view postfix queue
cat /var/spool/mail/root               # raw mailbox

# ── GRUB2 ────────────────────────────────────────────────────
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS   # detect boot mode
vi /etc/default/grub                   # edit here (GRUB_TIMEOUT / GRUB_DEFAULT)
grub2-mkconfig -o /boot/grub2/grub.cfg           # BIOS
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg  # UEFI

# ── CRON ─────────────────────────────────────────────────────
crontab {-e|-l|-r}
# MIN  HOUR  DOM  MON  DOW  command
MAILTO=manager
*/10  8-17   *    *    *   /usr/bin/free -m >> /var/log/perf.log

# ── NETWORKING (CentOS 9) ────────────────────────────────────
dnf install net-tools -y               # get ifconfig
ip addr show / ifconfig enp0s3
ip link show enp0s3                    # MAC address
nmcli con down enp0s3                  # replaces ifdown
nmcli con up enp0s3                    # replaces ifup
nmcli con mod "enp0s3" ipv4.method manual ipv4.addresses "IP/PREFIX" ...
nmcli con mod "enp0s3" +ipv4.addresses "IP2/24"    # add secondary IP
nmtui                                  # text UI (easiest)
hostnamectl set-hostname name.example.com

# ── ACLS ─────────────────────────────────────────────────────
chown root:grads /opt/research
chmod 3770 /opt/research
setfacl -m g:profs:rwx /opt/research
setfacl -d -m g:profs:rw /opt/research
getfacl /opt/research

# ── RSYSLOG ──────────────────────────────────────────────────
# Server: /etc/rsyslog.conf → uncomment $ModLoad imudp + $UDPServerRun 514
# Client: /etc/rsyslog.conf → *.* @server_ip:514
# Discard locally: & ~
logger 'test message'
tail -f /var/log/messages
```

---
*CentOS 9 Stream Lab Solutions — Corrected & Complete ✅*
