# 🐧 مشروع تدريبي Linux System Administration
## من Zero إلى System Admin محترف

---

## 📚 المستوى 1: أساسيات التعامل مع النظام

### السؤال 1: معرفة معلومات النظام
**المطلوب:** اعرض اسم النظام والإصدار
**Hint:** أمر اسم النظام
**الأمر المتعلق:** `uname -a`

---

### السؤال 2: معرفة المستخدم الحالي
**المطلوب:** اعرف إنت مسجل دخول باسم مين
**Hint:** أمر "من أنا"
**الأمر المتعلق:** `whoami`

---

### السؤال 3: عرض المستخدمين المتصلين
**المطلوب:** شوف مين متصل بالسيرفر دلوقتي
**Hint:** أمر "من"
**الأمر المتعلق:** `who` أو `w`

---

### السؤال 4: معرفة وقت التشغيل
**المطلوب:** اعرف السيرفر شغال من امتى والـ load average
**Hint:** أمر "وقت التشغيل"
**الأمر المتعلق:** `uptime`

---

### السؤال 5: عرض استخدام الذاكرة
**المطلوب:** شوف الـ RAM المستخدم والمتاح
**Hint:** أمر "حر/مجاني"
**الأمر المتعلق:** `free -h`

---

## 💾 المستوى 2: إدارة الملفات والمجلدات

### السؤال 6: إنشاء مجلد للمشروع
**المطلوب:** أنشئ مجلد `/opt/myapp` (محتاج root)
**Hint:** استخدم `sudo` مع أمر إنشاء المجلدات
**الأمر المتعلق:** `sudo mkdir -p`

---

### السؤال 7: تغيير الصلاحيات
**المطلوب:** اديله صلاحيات 755 (rwxr-xr-x)
**Hint:** أمر تغيير الوضع
**الأمر المتعلق:** `chmod 755`

---

### السؤال 8: تغيير المالك
**المطلوب:** غيّر مالك المجلد لمستخدم `www-data`
**Hint:** أمر تغيير المالك
**الأمر المتعلق:** `chown www-data:www-data`

---

### السؤال 9: إنشاء Symbolic Link
**المطلوب:** اعمل symbolic link من `/opt/myapp` إلى `/var/www/myapp`
**Hint:** أمر الربط مع flag للـ symbolic
**الأمر المتعلق:** `ln -s`

---

### السؤال 10: البحث عن ملفات
**المطلوب:** دوّر على كل ملفات `.log` في `/var/log`
**Hint:** أمر البحث
**الأمر المتعلق:** `find /var/log -name "*.log"`

---

## 👥 المستوى 3: إدارة المستخدمين والصلاحيات

### السؤال 11: إنشاء مستخدم جديد
**المطلوب:** أنشئ مستخدم اسمه `ahmed`
**Hint:** أمر إضافة مستخدم
**الأمر المتعلق:** `sudo useradd` أو `adduser`

---

### السؤال 12: تعيين كلمة مرور
**المطلوب:** حط password للمستخدم `ahmed`
**Hint:** أمر كلمة المرور
**الأمر المتعلق:** `sudo passwd ahmed`

---

### السؤال 13: إضافة مستخدم لمجموعة
**المطلوب:** ضيف `ahmed` لمجموعة `sudo`
**Hint:** أمر تعديل المستخدم مع flag للمجموعات
**الأمر المتعلق:** `sudo usermod -aG sudo ahmed`

---

### السؤال 14: عرض المجموعات
**المطلوب:** اعرض كل المجموعات اللي `ahmed` منضم ليها
**Hint:** أمر المجموعات أو id
**الأمر المتعلق:** `groups ahmed` أو `id ahmed`

---

### السؤال 15: حذف مستخدم
**المطلوب:** احذف مستخدم اسمه `testuser` مع الـ home directory بتاعه
**Hint:** أمر حذف المستخدم مع flag للـ home
**الأمر المتعلق:** `sudo userdel -r testuser`

---

## 📦 المستوى 4: إدارة الحزم (Package Management)

### السؤال 16: تحديث قائمة الحزم
**المطلوب:** حدّث قائمة الـ packages المتاحة (Ubuntu/Debian)
**Hint:** أمر apt مع update
**الأمر المتعلق:** `sudo apt update`

---

### السؤال 17: ترقية النظام
**المطلوب:** رقّي كل الـ packages المثبتة
**Hint:** أمر apt مع upgrade
**الأمر المتعلق:** `sudo apt upgrade -y`

---

### السؤال 18: تثبيت حزمة
**المطلوب:** ثبّت `nginx` و `curl` و `vim`
**Hint:** أمر apt مع install
**الأمر المتعلق:** `sudo apt install nginx curl vim -y`

---

### السؤال 19: البحث عن حزمة
**المطلوب:** دوّر على حزم فيها كلمة "python"
**Hint:** أمر apt مع search
**الأمر المتعلق:** `apt search python`

---

### السؤال 20: إزالة حزمة
**المطلوب:** احذف `apache2` مع ملفات الإعدادات
**Hint:** أمر apt مع purge
**الأمر المتعلق:** `sudo apt purge apache2 -y`

---

## 🔧 المستوى 5: إدارة العمليات (Process Management)

### السؤال 21: عرض العمليات الجارية
**المطلوب:** اعرض كل العمليات اللي شغالة دلوقتي
**Hint:** أمر العمليات (تفاعلي)
**الأمر المتعلق:** `top` أو `htop`

---

### السؤال 22: عرض عمليات معينة
**المطلوب:** اعرض كل العمليات المتعلقة بـ `nginx`
**Hint:** أمر ps مع grep
**الأمر المتعلق:** `ps aux | grep nginx`

---

### السؤال 23: قتل عملية
**المطلوب:** اقتل العملية رقم 1234
**Hint:** أمر القتل
**الأمر المتعلق:** `kill 1234` أو `sudo kill -9 1234`

---

### السؤال 24: قتل عمليات بالاسم
**المطلوب:** اقتل كل العمليات اسمها `firefox`
**Hint:** أمر قتل الكل
**الأمر المتعلق:** `pkill firefox` أو `killall firefox`

---

### السؤال 25: تشغيل عملية في الخلفية
**المطلوب:** شغّل سكريبت في الـ background
**Hint:** استخدم `&` في آخر الأمر
**الأمر المتعلق:** `./script.sh &`

---

## 🌐 المستوى 6: إدارة الشبكات (Networking Basics)

### السؤال 26: عرض الـ IP Address
**المطلوب:** اعرض عناوين IP لكل الـ interfaces
**Hint:** أمر معلومات الـ IP
**الأمر المتعلق:** `ip addr` أو `ifconfig`

---

### السؤال 27: Ping لموقع
**المطلوب:** اعمل ping لـ `google.com` (5 مرات بس)
**Hint:** أمر الـ ping مع عدد المحاولات
**الأمر المتعلق:** `ping -c 5 google.com`

---

### السؤال 28: عرض المنافذ المفتوحة
**المطلوب:** شوف كل الـ ports اللي شغالة ومين مستخدمها
**Hint:** أمر netstat أو ss
**الأمر المتعلق:** `sudo netstat -tulpn` أو `sudo ss -tulpn`

---

### السؤال 29: اختبار اتصال بمنفذ
**المطلوب:** اختبر إذا المنفذ 80 مفتوح على `example.com`
**Hint:** أمر telnet أو nc
**الأمر المتعلق:** `telnet example.com 80` أو `nc -zv example.com 80`

---

### السؤال 30: تحميل ملف من الإنترنت
**المطلوب:** حمّل ملف من URL معين
**Hint:** أمر wget أو curl
**الأمر المتعلق:** `wget <url>` أو `curl -O <url>`

---

## 🔐 المستوى 7: إدارة الخدمات (Services & Systemd)

### السؤال 31: بدء خدمة
**المطلوب:** شغّل خدمة `nginx`
**Hint:** أمر systemctl مع start
**الأمر المتعلق:** `sudo systemctl start nginx`

---

### السؤال 32: إيقاف خدمة
**المطلوب:** وقّف خدمة `apache2`
**Hint:** أمر systemctl مع stop
**الأمر المتعلق:** `sudo systemctl stop apache2`

---

### السؤال 33: إعادة تشغيل خدمة
**المطلوب:** اعمل restart لـ `ssh`
**Hint:** أمر systemctl مع restart
**الأمر المتعلق:** `sudo systemctl restart ssh`

---

### السؤال 34: تفعيل خدمة عند البدء
**المطلوق:** فعّل `nginx` عشان يشتغل تلقائياً عند البوت
**Hint:** أمر systemctl مع enable
**الأمر المتعلق:** `sudo systemctl enable nginx`

---

### السؤال 35: عرض حالة خدمة
**المطلوب:** شوف حالة وتفاصيل خدمة `mysql`
**Hint:** أمر systemctl مع status
**الأمر المتعلق:** `sudo systemctl status mysql`

---

### السؤال 36: عرض logs الخدمة
**المطلوب:** اعرض آخر 50 سطر من logs خدمة `nginx`
**Hint:** أمر journalctl
**الأمر المتعلق:** `sudo journalctl -u nginx -n 50`

---

## 💿 المستوى 8: إدارة الأقراص والتخزين

### السؤال 37: عرض مساحة الأقراص
**المطلوب:** اعرض مساحة كل الأقراص بشكل مقروء
**Hint:** أمر disk free
**الأمر المتعلق:** `df -h`

---

### السؤال 38: عرض حجم مجلد
**المطلوب:** اعرف حجم مجلد `/var/log`
**Hint:** أمر disk usage
**الأمر المتعلق:** `du -sh /var/log`

---

### السؤال 39: عرض أكبر 10 ملفات
**المطلوب:** اعرض أكبر 10 ملفات في `/home`
**Hint:** استخدم du مع sort و head
**الأمر المتعلق:** `sudo du -ah /home | sort -rh | head -10`

---

### السؤال 40: عرض الأقراص المتصلة
**المطلوب:** اعرض كل الأقراص والـ partitions
**Hint:** أمر list block devices
**الأمر المتعلق:** `lsblk`

---

### السؤال 41: Mount قرص
**المطلوب:** اعمل mount لـ partition `/dev/sdb1` على `/mnt/data`
**Hint:** أمر التركيب
**الأمر المتعلق:** `sudo mount /dev/sdb1 /mnt/data`

---

### السؤال 42: Unmount قرص
**المطلوب:** اعمل unmount للمجلد `/mnt/data`
**Hint:** أمر إلغاء التركيب
**الأمر المتعلق:** `sudo umount /mnt/data`

---

## 📝 المستوى 9: إدارة Logs والمراقبة

### السؤال 43: عرض System Logs
**المطلوب:** اعرض آخر 100 سطر من system logs
**Hint:** أمر journalctl مع عدد الأسطر
**الأمر المتعلق:** `sudo journalctl -n 100`

---

### السؤال 44: متابعة Log في الوقت الفعلي
**المطلوب:** تابع ملف `/var/log/syslog` live
**Hint:** أمر tail مع follow
**الأمر المتعلق:** `sudo tail -f /var/log/syslog`

---

### السؤال 45: البحث في Logs
**المطلوب:** دوّر على كلمة "error" في كل logs
**Hint:** استخدم grep بشكل متكرر
**الأمر المتعلق:** `sudo grep -r "error" /var/log/`

---

### السؤال 46: عرض Logs بتاريخ معين
**المطلوب:** اعرض logs من ساعة 10 صباحاً لـ 2 ظهراً
**Hint:** journalctl مع since و until
**الأمر المتعلق:** `sudo journalctl --since "10:00" --until "14:00"`

---

## 🔥 المستوى 10: Firewall والأمان (Security Basics)

### السؤال 47: تفعيل Firewall
**المطلوب:** فعّل UFW firewall
**Hint:** أمر ufw مع enable
**الأمر المتعلق:** `sudo ufw enable`

---

### السؤال 48: السماح بمنفذ
**المطلوب:** اسمح بالاتصالات على المنفذ 80 و 443
**Hint:** أمر ufw مع allow
**الأمر المتعلق:** `sudo ufw allow 80/tcp` و `sudo ufw allow 443/tcp`

---

### السؤال 49: حظر IP معين
**المطلوب:** احظر الـ IP `192.168.1.100`
**Hint:** أمر ufw مع deny
**الأمر المتعلق:** `sudo ufw deny from 192.168.1.100`

---

### السؤال 50: عرض قواعد Firewall
**المطلوب:** اعرض كل قواعد UFW الحالية
**Hint:** أمر ufw مع status
**الأمر المتعلق:** `sudo ufw status verbose`

---

## 🚀 المستوى 11: Cron Jobs والمهام المجدولة

### السؤال 51: فتح محرر Crontab
**المطلوب:** افتح crontab للتعديل
**Hint:** أمر crontab مع edit
**الأمر المتعلق:** `crontab -e`

---

### السؤال 52: إضافة مهمة يومية
**المطلوب:** اضبط مهمة تشتغل كل يوم الساعة 3 صباحاً
**Hint:** صيغة Cron: `0 3 * * * /path/to/script.sh`
**الأمر المتعلق:** يدوي في crontab

---

### السؤال 53: عرض Cron Jobs
**المطلوب:** اعرض كل الـ cron jobs للمستخدم الحالي
**Hint:** أمر crontab مع list
**الأمر المتعلق:** `crontab -l`

---

### السؤال 54: حذف كل Cron Jobs
**المطلوب:** احذف كل الـ cron jobs
**Hint:** أمر crontab مع remove
**الأمر المتعلق:** `crontab -r`

---

## 🔄 المستوى 12: Backup والأرشفة

### السؤال 55: إنشاء Tar Archive
**المطلوب:** اعمل archive لمجلد `/var/www` في ملف `backup.tar.gz`
**Hint:** أمر tar مع compress
**الأمر المتعلق:** `tar -czf backup.tar.gz /var/www`

---

### السؤال 56: استخراج Archive
**المطلوب:** فك ضغط ملف `backup.tar.gz`
**Hint:** أمر tar مع extract
**الأمر المتعلق:** `tar -xzf backup.tar.gz`

---

### السؤال 57: Backup باستخدام rsync
**المطلوب:** اعمل sync لمجلد `/data` إلى `/backup/data`
**Hint:** أمر rsync
**الأمر المتعلق:** `rsync -av /data/ /backup/data/`

---

### السؤال 58: Backup لسيرفر بعيد
**المطلوب:** انقل ملفات لسيرفر آخر عن طريق SSH
**Hint:** rsync مع SSH
**الأمر المتعلق:** `rsync -avz -e ssh /local/path user@remote:/remote/path`

---

## ⚙️ المستوى 13: Shell Scripting (Admin Level 1)

### السؤال 59: إنشاء سكريبت بسيط
**المطلوب:** اكتب سكريبت يطبع "Hello Admin" واديله صلاحيات تنفيذ
**Hint:** استخدم `#!/bin/bash` و `echo` و `chmod +x`
**الأوامر المتعلقة:** `nano`, `chmod`

---

### السؤال 60: سكريبت بمتغيرات
**المطلوب:** اكتب سكريبت ياخد اسم كـ argument ويطبعه
**Hint:** استخدم `$1` للـ argument الأول
**الأمر المتعلق:** Bash scripting

---

### السؤال 61: سكريبت مع If condition
**المطلوب:** اكتب سكريبت يتحقق إذا ملف موجود أو لا
**Hint:** استخدم `if [ -f "file" ]`
**الأمر المتعلق:** Bash conditionals

---

### السؤال 62: سكريبت Loop
**المطلوب:** اكتب سكريبت يعمل loop على الأرقام من 1 لـ 10
**Hint:** استخدم `for i in {1..10}`
**الأمر المتعلق:** Bash loops

---

## 🌐 المستوى 14: SSH وإدارة Remote Servers

### السؤال 63: الاتصال بسيرفر
**المطلوب:** اتصل بسيرفر عن طريق SSH
**Hint:** أمر ssh مع username و IP
**الأمر المتعلق:** `ssh user@192.168.1.100`

---

### السؤال 64: نسخ ملف عبر SCP
**المطلوب:** انسخ ملف لسيرفر بعيد
**Hint:** أمر secure copy
**الأمر المتعلق:** `scp file.txt user@remote:/path/`

---

### السؤال 65: إنشاء SSH Key
**المطلوب:** اعمل SSH key pair
**Hint:** أمر ssh-keygen
**الأمر المتعلق:** `ssh-keygen -t rsa -b 4096`

---

### السؤال 66: نسخ SSH Key للسيرفر
**المطلوب:** انسخ الـ public key للسيرفر البعيد
**Hint:** أمر ssh-copy-id
**الأمر المتعلق:** `ssh-copy-id user@remote`

---

## 🐳 المستوى 15: أساسيات Docker (Admin Level 2)

### السؤال 67: تثبيت Docker
**المطلوب:** ثبّت Docker على Ubuntu
**Hint:** استخدم apt و official repository
**الأوامر المتعلقة:** `apt install`, `systemctl`

---

### السؤال 68: تشغيل Container بسيط
**المطلوب:** شغّل container من image `nginx`
**Hint:** أمر docker run
**الأمر المتعلق:** `docker run -d -p 80:80 nginx`

---

### السؤال 69: عرض Containers الشغالة
**المطلوب:** اعرض كل الـ containers اللي شغالة
**Hint:** أمر docker ps
**الأمر المتعلق:** `docker ps`

---

### السؤال 70: إيقاف Container
**المطلوب:** وقّف container معين
**Hint:** أمر docker stop
**الأمر المتعلق:** `docker stop <container_id>`

---

## 📊 المستوى 16: Performance Monitoring (Admin Level 2)

### السؤال 71: مراقبة الـ CPU
**المطلوب:** اعرض استخدام الـ CPU لكل process
**Hint:** أمر top مع ترتيب حسب CPU
**الأمر المتعلق:** `top` (اضغط P)

---

### السؤال 72: مراقبة الـ I/O
**المطلوب:** شوف إحصائيات القراءة والكتابة للأقراص
**Hint:** أمر iostat
**الأمر المتعلق:** `iostat -x 1`

---

### السؤال 73: مراقبة الشبكة
**المطلوب:** شوف استخدام الـ bandwidth في الوقت الفعلي
**Hint:** أمر iftop أو nethogs
**الأمر المتعلق:** `sudo iftop` أو `sudo nethogs`

---

### السؤال 74: استخدام SAR
**المطلوب:** اعرض تقرير استخدام النظام من أمس
**Hint:** أمر System Activity Reporter
**الأمر المتعلق:** `sar -A`

---

## 🔧 المستوى 17: Troubleshooting المتقدم

### السؤال 75: فحص Kernel Messages
**المطلوب:** اعرض رسائل الـ kernel الأخيرة
**Hint:** أمر dmesg
**الأمر المتعلق:** `dmesg | tail -50`

---

### السؤال 76: تتبع System Calls
**المطلوب:** تتبع الـ system calls لعملية معينة
**Hint:** أمر strace
**الأمر المتعلق:** `strace -p <PID>`

---

### السؤال 77: فحص Open Files
**المطلوب:** شوف كل الملفات المفتوحة من process معين
**Hint:** أمر list open files
**الأمر المتعلق:** `lsof -p <PID>`

---

### السؤال 78: تحليل Network Traffic
**المطلوب:** اعمل capture للـ packets على port 80
**Hint:** أمر tcpdump
**الأمر المتعلق:** `sudo tcpdump -i eth0 port 80`

---

## 🔐 المستوى 18: Security المتقدم (Admin Level 2)

### السؤال 79: فحص Failed Login Attempts
**المطلوب:** شوف محاولات تسجيل الدخول الفاشلة
**Hint:** ابحث في auth.log
**الأمر المتعلق:** `sudo grep "Failed password" /var/log/auth.log`

---

### السؤال 80: تثبيت Fail2ban
**المطلوب:** ثبّت وفعّل Fail2ban
**Hint:** استخدم apt و systemctl
**الأوامر المتعلقة:** `apt install fail2ban`, `systemctl enable`

---

### السؤال 81: فحص Open Ports
**المطلوب:** اعمل scan للـ ports المفتوحة
**Hint:** أمر nmap
**الأمر المتعلق:** `nmap -sT localhost`

---

### السؤال 82: تشفير Partition
**المطلوب:** اعمل encrypt لـ partition باستخدام LUKS
**Hint:** أمر cryptsetup (متقدم جداً!)
**الأمر المتعلق:** `cryptsetup luksFormat /dev/sdX`

---

## 🎯 المشروع النهائي: سيناريو واقعي

### السؤال 83-90: بناء Web Server كامل
**المطلوب:** 
1. ثبّت وفعّل Nginx
2. أنشئ مستخدم `webadmin` وضيفه لـ sudo
3. اعمل virtual host للموقع
4. اضبط SSL Certificate (Let's Encrypt)
5. اعمل firewall rules مناسبة
6. اضبط automatic backup يومي
7. اعمل monitoring للخدمة
8. اكتب سكريبت يفحص صحة الموقع كل 5 دقايق

**Hint:** هتستخدم كل اللي اتعلمته! 🔥

---

## 📌 ملاحظات مهمة:
- الأسئلة مرتبة من السهل للصعب
- كل سؤال بيبني على المهارات السابقة
- في أسئلة محتاجة `sudo` - خلي بالك!
- بعض الأوامر ممكن تختلف حسب الـ Distribution

**جاهز تبدأ رحلة الـ Sysadmin؟ ابدأ من السؤال 1! 🚀**