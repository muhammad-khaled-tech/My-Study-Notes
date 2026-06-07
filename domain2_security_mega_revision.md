# 🔐 DOMAIN 2 — Security & Compliance | CLF-C02 Mega Revision
> **Domain Weight: 30%** — أكبر domain في الامتحان. الـ 158 سؤال في الـ dumps اتحللوا عشان الملف ده.

---

## 📦 TABLE OF CONTENTS

1. [Shared Responsibility Model](#1-shared-responsibility-model)
2. [IAM — Identity & Access Management](#2-iam)
3. [Security Groups vs NACLs](#3-security-groups-vs-nacls)
4. [DDoS Protection — Shield + WAF + Firewall](#4-ddos--waf--firewall)
5. [Encryption — KMS + CloudHSM + ACM](#5-encryption)
6. [Threat Detection — GuardDuty, Inspector, Macie, Detective](#6-threat-detection)
7. [Audit & Compliance — CloudTrail, Config, Artifact](#7-audit--compliance)
8. [Advanced Identity — STS, Cognito, IAM Identity Center](#8-advanced-identity)
9. [Security Hub + AWS Abuse](#9-security-hub--abuse)
10. [Keyword Trap Table — Domain 2](#10-keyword-trap-table)
11. [زتونة الإنترفيو — Domain 2](#11-interview-zitona)

---

## 1. Shared Responsibility Model

### المعادلة الأساسية

| | AWS Responsible | Customer Responsible |
|---|---|---|
| **الجملة** | Security **OF** the Cloud | Security **IN** the Cloud |
| **يعني إيه** | Physical infra, hardware, global network, managed services | Data, IAM, OS patches, app config, encryption enable |

### Per-Service Breakdown — الأكثر سؤالاً

| Service | AWS Owns | Customer Owns | SHARED |
|---|---|---|---|
| **EC2** | Physical host, hypervisor | OS patches, apps, firewall (SG), IAM, data | Patch mgmt |
| **RDS** | OS patching, DB patching, hardware, SSH disabled | SG rules, DB users/permissions, SSL config, encryption setting, public access | Patch mgmt |
| **S3** | Unlimited storage, encryption infra, data separation | Bucket policy, public access setting, IAM roles, enabling encryption | — |
| **DynamoDB** | Hardware, patching, availability | **Access to tables (IAM)** | Encryption |
| **Lambda** | Runtime, infra | Function code, IAM roles | — |

> ⚠️ **الـ Trap بتاعتك (Q231 + Q5):**
> - EBS encryption → **Customer enables it** (AWS provides the tool/KMS, customer decides to use it)
> - DynamoDB customer responsibility → **Access control (IAM)** مش encryption (AWS does that by default)
> - "Security OF the cloud" → **AWS's job** = physical infra وبس

### Shared Controls (ALWAYS Both)

> دي دايمًا الجواب لو السؤال قال "shared between AWS and customer":

- **Patch Management** — AWS patches managed services, Customer patches EC2 OS
- **Configuration Management** — both sides configure their own layer
- **Awareness & Training** — both train their teams

---

## 2. IAM

### IAM Building Blocks

| Component | What It Is | Keyword |
|---|---|---|
| **User** | Physical person → has password for console | "employee / person / human" |
| **Group** | Collection of users (NOT nested groups) | "team / department" |
| **Policy** | JSON document defining permissions | "permissions / allow / deny" |
| **Role** | Permissions for AWS services or cross-account | "EC2 needs to access S3" / "service" |

### IAM Policy Structure — اعرف الـ Keywords

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",          ← Allow or Deny
    "Principal": "arn:...",     ← Who (account/user/role)
    "Action": "s3:GetObject",  ← What action
    "Resource": "arn:...",     ← On what resource
    "Condition": {...}          ← Optional: when
  }]
}
```

> **Least Privilege Principle** = don't give more permissions than needed → دايمًا جواب صح في الامتحان

### IAM Security Tools

| Tool | Scope | Does What | Keyword |
|---|---|---|---|
| **IAM Credential Report** | Account-level | CSV: all users + password age + access keys + MFA status | "list users / status of credentials / MFA status / access keys" |
| **IAM Access Advisor** | User-level | Shows which services a user accessed + last access time | "revise policies / unused permissions / last accessed" |
| **IAM Access Analyzer** | Account/Org level | Finds resources shared **externally** outside Zone of Trust | "shared externally / outside account / S3 bucket shared" |

> ⚠️ **الـ Trap (Q234 + Q336):**
> - "List users + credential status" → **Credential Report** (مش Access Analyzer)
> - "Resources shared externally" → **Access Analyzer** (مش OpenSearch, مش GuardDuty)

### IAM Access Methods

| Method | Protected By | Use Case |
|---|---|---|
| **AWS Console** | Password + MFA | Humans logging in |
| **AWS CLI** | Access Keys (Key ID + Secret) | Scripting, automation |
| **AWS SDK** | Access Keys | Code/applications |

> Access Key ID ≈ username | Secret Access Key ≈ password — **لا تشاركهم أبداً**

### MFA Device Types

| Type | Example | Notes |
|---|---|---|
| Virtual MFA | Google Authenticator, Authy | Phone app — multiple tokens on 1 device |
| U2F Security Key | YubiKey | Physical USB key — 1 key for multiple users |
| Hardware Key Fob | Gemalto | Physical device |

### IAM Roles — متى تستخدمهم؟

| Scenario | Use |
|---|---|
| EC2 instance needs to call S3 | IAM Role attached to EC2 |
| Lambda needs to write to DynamoDB | IAM Role attached to Lambda |
| One AWS account access another | Cross-account Role |
| User from Active Directory needs AWS access | Federation Role via STS |

> ⚠️ مش Access Keys للـ services — دايمًا **Roles**

### Root Account — Only Root Can Do These

- Change account settings (name, email, password)
- Close AWS account
- Change or cancel AWS Support plan
- Register as Reserved Instance Marketplace seller
- Enable MFA on S3 bucket
- Restore IAM user permissions
- Sign up for GovCloud

> ⚠️ **لا تستخدم الـ root لأي حاجة تانية**

---

## 3. Security Groups vs NACLs

> ده من أكتر topics في الـ dumps (16 سؤال Security Groups)

```
INTERNET
    │
    ▼
┌─────────────────────────────────┐
│  VPC                             │
│  ┌──────────────────────────┐   │
│  │  Subnet                   │   │
│  │  ┌─────────────────────┐ │   │
│  │  │   EC2 Instance       │ │   │
│  │  │   [Security Group]   │ │   │← instance level
│  │  └─────────────────────┘ │   │
│  │  [NACL]                   │   │← subnet level
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

| | **Security Group** | **Network ACL (NACL)** |
|---|---|---|
| **Level** | Instance level | Subnet level |
| **State** | **Stateful** (return traffic auto allowed) | **Stateless** (must allow both directions) |
| **Rules** | Allow rules only | Allow AND Deny rules |
| **Default** | Deny all inbound, allow all outbound | Allow all |
| **Scope** | Single EC2 instance | All instances in subnet |
| **Keyword** | "single instance / specific EC2 / firewall for instance" | "subnet level / block IP / deny specific" |

> ⚠️ **الـ Trap (Q554):**
> - "Firewall for a **single** EC2, not others in same subnet" → **Security Group** (مش NACL, مش WAF)
> - WAF = Layer 7 HTTP/HTTPS فقط
> - NACL = كل الـ subnet مش instance واحدة

---

## 4. DDoS + WAF + Firewall

### DDoS Protection Layers

```
ATTACK TRAFFIC
      │
      ▼
[Route 53 + CloudFront] ← Edge: Shield Standard (automatic, free)
      │
      ▼
[AWS WAF] ← Layer 7: filter HTTP rules, geo-block, rate limit
      │
      ▼
[AWS Shield Advanced] ← Premium: $3,000/mo, DDoS Response Team (DRP)
      │
      ▼
[Auto Scaling] ← absorb spike traffic
```

### Shield Standard vs Advanced

| | **Shield Standard** | **Shield Advanced** |
|---|---|---|
| **Cost** | Free — all customers | $3,000/month/org |
| **Protection** | Layer 3/4 (SYN/UDP floods) | Layer 3/4/7 + sophisticated attacks |
| **Access** | Automatic | 24/7 DDoS Response Team (DRP) |
| **Coverage** | Basic | EC2, ELB, CloudFront, Global Accelerator, Route 53 |
| **Extra** | — | Protects against cost spikes from DDoS |

### WAF vs Network Firewall vs Firewall Manager

| Service | Scope | Layer | Keyword |
|---|---|---|---|
| **AWS WAF** | ALB, API Gateway, CloudFront | Layer 7 (HTTP/HTTPS) | "SQL injection / XSS / block countries / rate limit / web ACL" |
| **AWS Network Firewall** | Entire VPC | Layer 3–7 | "protect VPC / all directions / VPC to VPC / Direct Connect traffic" |
| **AWS Firewall Manager** | All accounts in Org | Management layer | "manage WAF rules across all accounts / organization-wide security" |

> 🎯 **"Block users from certain countries"** → **AWS WAF** (geo-match rule) — مش Control Tower، مش Fraud Detector

---

## 5. Encryption

### KMS vs CloudHSM

| | **AWS KMS** | **AWS CloudHSM** |
|---|---|---|
| **Who manages keys** | AWS manages software | **You manage keys** (hardware) |
| **Hardware** | AWS managed | Dedicated hardware (HSM) |
| **Compliance** | Standard | FIPS 140-2 Level 3 |
| **Keyword** | "encryption / managed by AWS / most services" | "you manage your own keys / dedicated hardware / FIPS" |

### KMS Key Types

| Type | Who Creates | Who Manages | Keyword |
|---|---|---|---|
| **AWS Owned Key** | AWS | AWS | Invisible to you, used internally |
| **AWS Managed Key** | AWS | AWS | aws/s3, aws/ebs — auto for services |
| **Customer Managed Key** | You | You | Custom policies, rotation, bring-your-own |
| **CloudHSM Key** | Your HSM | You | Hardware-generated |

### Encryption Auto-Enabled (no action needed)

- CloudTrail Logs ✅
- S3 Glacier ✅
- Storage Gateway ✅

### Encryption Opt-In (customer must enable)

- EBS volumes
- S3 buckets (SSE-KMS)
- RDS databases
- EFS drives
- Redshift

### Other Encryption Services

| Service | Does What | Keyword |
|---|---|---|
| **AWS Certificate Manager (ACM)** | SSL/TLS certificates for HTTPS | "HTTPS / TLS cert / free public cert / auto renewal" |
| **AWS Secrets Manager** | Store & rotate secrets (passwords, API keys) | "RDS password rotation / secrets / rotate every X days" |

---

## 6. Threat Detection

### The 4 Detection Services — أكتر من بيتلخبط فيهم

```
THREAT DETECTED
       │
       ├─ Is it a malicious pattern/behavior in logs?
       │     └─ GuardDuty (ML on VPC, CloudTrail, DNS logs)
       │
       ├─ Is it a software vulnerability in code/container?
       │     └─ Amazon Inspector (CVE scanning: EC2, ECR, Lambda)
       │
       ├─ Is it sensitive data (PII) in S3?
       │     └─ Amazon Macie (ML pattern matching in S3)
       │
       └─ Need to investigate ROOT CAUSE of security incident?
             └─ Amazon Detective (ML graphs from GuardDuty/CloudTrail/VPC)
```

### Comparison Table

| Service | Input Sources | What It Finds | Keyword |
|---|---|---|---|
| **GuardDuty** | CloudTrail, VPC Flow Logs, DNS Logs | Malicious activity, cryptocurrency mining, unauthorized API calls | "threat / malicious / anomaly / suspicious behavior / ML" |
| **Amazon Inspector** | EC2 (via SSM), ECR images, Lambda | CVE vulnerabilities, network reachability | "vulnerability / CVE / software flaw / package / EC2+Lambda+ECR" |
| **Amazon Macie** | S3 buckets | PII / sensitive data | "PII / sensitive data / S3 / personally identifiable" |
| **Amazon Detective** | GuardDuty + CloudTrail + VPC Flow Logs | Root cause of security issue | "investigate / root cause / analyze security findings / ML graphs" |

> ⚠️ **الـ Trap (Q393):**
> - "Analyze log data + security investigations using ML" → **Amazon Detective** (مش Inspector)
> - Inspector = vulnerability scanner (CVEs), مش log investigator
> - GuardDuty = detects threats real-time, مش root cause investigation

---

## 7. Audit & Compliance

### CloudTrail vs CloudWatch vs Config

| Service | Tracks What | Keyword |
|---|---|---|
| **CloudTrail** | API calls — who did what, when, from where | "who deleted / who created / API history / audit trail / event history" |
| **CloudWatch** | Metrics, logs, alarms — performance monitoring | "CPU / metrics / alarms / dashboards / performance" |
| **AWS Config** | Resource configuration changes over time | "configuration history / compliance / unrestricted SSH / bucket public?" |

> ⚠️ **الـ Trap:**
> - "Who deleted resources?" → **CloudTrail** (مش GuardDuty, مش EventBridge)
> - "Is my S3 bucket compliant?" → **AWS Config**
> - "CPU alarm" → **CloudWatch**

### AWS Artifact

> مش service حقيقية — portal لتحميل compliance documents

| What | Examples |
|---|---|
| **Artifact Reports** | ISO certs, PCI DSS, SOC reports (from third-party auditors) |
| **Artifact Agreements** | BAA (HIPAA), business agreements |

> Keyword: "compliance report / audit documentation / PCI / ISO / SOC / HIPAA agreement"

### AWS Config — ما يعمله بالظبط

- Track config changes over time
- "Is unrestricted SSH allowed on my SGs?" → Yes/No answer
- "Did my S3 bucket go public?" → Yes, at this time
- Store history in S3 → analyze with Athena
- Send SNS alerts on changes

---

## 8. Advanced Identity

### STS — Security Token Service

- Provides **temporary, limited-privilege credentials**
- Use cases: cross-account access, EC2 role assumption, identity federation
- Keyword: "temporary credentials / assume role / federated user"

### Amazon Cognito

- User database for **web & mobile apps** (millions of users)
- بدل ما تعمل IAM user لكل user في app → Cognito
- Supports social login (Facebook, Google)
- Keyword: "mobile app users / web app users / social identity provider / millions of users"

### AWS IAM Identity Center (SSO)

- Single Sign-On for **multiple AWS accounts + business apps**
- Integrates with Active Directory, Okta, OneLogin
- Keyword: "single login / multiple accounts / SSO / SAML 2.0 / Salesforce + AWS"

### AWS Directory Services

| Service | Use Case | Keyword |
|---|---|---|
| **AWS Managed AD** | Full AD in AWS, trust with on-prem | "full AD in cloud / trust on-premises AD" |
| **AD Connector** | Proxy to on-prem AD, no local users | "redirect to on-prem / gateway / proxy to existing AD" |
| **Simple AD** | Basic AD, no on-prem connection | "simple / standalone / no on-prem AD" |

---

## 9. Security Hub + Abuse

### AWS Security Hub

- **Aggregates** security findings from multiple services + accounts
- Must enable **AWS Config** first
- Sources: GuardDuty, Inspector, Macie, IAM Access Analyzer, Firewall Manager, Config, Systems Manager
- Keyword: "central security dashboard / aggregate findings / multiple accounts / single view"

### AWS Abuse

- Report AWS resources used for: Spam, DDoS, port scanning, malware distribution, illegal content
- Contact: AWS Abuse form or abuse@amazonaws.com
- Keyword: "report misuse / spam from AWS IP / illegal activity using AWS"

### Penetration Testing — Allowed Without Prior Approval

EC2, NAT GW, ELB, RDS, CloudFront, Aurora, API Gateway, Lambda, Lightsail, Beanstalk

> ❌ **NOT allowed:** DoS/DDoS simulation, DNS zone walking, port flooding

---

## 10. Keyword Trap Table — Domain 2

### Security Services Decision Matrix

| Question Says... | Answer |
|---|---|
| "who did what / API calls / deleted / created / audit" | **CloudTrail** |
| "metrics / CPU / performance / alarms" | **CloudWatch** |
| "configuration compliance / unrestricted SSH / config history" | **AWS Config** |
| "malicious activity / anomaly / suspicious / threats" | **GuardDuty** |
| "CVE / software vulnerability / EC2 + Lambda + ECR" | **Amazon Inspector** |
| "PII / sensitive data in S3" | **Amazon Macie** |
| "root cause / investigate security / ML graphs" | **Amazon Detective** |
| "aggregate findings / central security / multiple accounts" | **AWS Security Hub** |
| "resources shared externally / outside account" | **IAM Access Analyzer** |
| "list users + credential status / MFA status / access keys" | **IAM Credential Report** |
| "unused permissions / last accessed service" | **IAM Access Advisor** |
| "block countries / SQL injection / XSS / web ACL" | **AWS WAF** |
| "protect VPC / all directions / Layer 3-7" | **AWS Network Firewall** |
| "WAF rules across all org accounts" | **AWS Firewall Manager** |
| "DDoS + free / automatic" | **AWS Shield Standard** |
| "DDoS + 24/7 team / $3000 / advanced" | **AWS Shield Advanced** |
| "SSL/TLS cert / HTTPS / auto renewal" | **ACM** |
| "RDS password rotation / secrets / rotate" | **AWS Secrets Manager** |
| "compliance doc / PCI / ISO / HIPAA agreement" | **AWS Artifact** |
| "temporary credentials / assume role" | **AWS STS** |
| "mobile/web app users / millions / social login" | **Amazon Cognito** |
| "SSO / multiple AWS accounts / SAML" | **IAM Identity Center** |

### Shared Responsibility Traps

| Phrase | Owner |
|---|---|
| "Security OF the cloud" | **AWS** |
| "Security IN the cloud" | **Customer** |
| "EBS encryption — who enables it?" | **Customer** (AWS provides tool) |
| "DynamoDB — customer responsibility?" | **Access control (IAM)** not encryption |
| "Patch management" | **SHARED** |
| "RDS patching" | **AWS** (managed service) |
| "EC2 OS patching" | **Customer** |

### Security Group vs NACL Traps

| Phrase | Answer |
|---|---|
| "firewall for single EC2, not others in same subnet" | **Security Group** |
| "block specific IP address" | **NACL** (has Deny rules) |
| "subnet-level firewall" | **NACL** |
| "stateful firewall" | **Security Group** |
| "stateless" | **NACL** |

---

## 11. زتونة الإنترفيو 🫒 — Domain 2

**Shared Responsibility:**
OF the cloud = AWS (hardware/infra) | IN the cloud = Customer (data/IAM/OS)
Patch Mgmt = SHARED | EBS encryption = Customer enables it | DynamoDB access = Customer IAM

**IAM Tools:**
Credential Report = all users status | Access Advisor = last used | Access Analyzer = shared externally

**Detection Pyramid:**
GuardDuty → threats/behavior | Inspector → CVE/vulnerabilities | Macie → PII in S3 | Detective → root cause

**Audit:**
CloudTrail = WHO did WHAT | Config = IS it compliant/changed | CloudWatch = metrics/performance

**Firewall Layers:**
WAF = Layer 7 / HTTP / geo-block | Network Firewall = entire VPC L3-7 | Firewall Manager = org-wide rules

**Encryption:**
KMS = AWS manages keys | CloudHSM = YOU manage keys | ACM = SSL certs | Secrets Manager = rotating passwords

**Identity:**
STS = temp creds | Cognito = app users millions | IAM Identity Center = SSO multi-account

**The 2 Numbers to Remember:**
Shield Advanced = $3,000/mo | CloudHSM = FIPS 140-2 Level 3
