# 💰 DOMAIN 4 — Billing, Pricing & Support | CLF-C02 Mega Revision
> **Domain Weight: 12%** — أصغر domain، بس **44 سؤال في الـ dumps على EC2 Pricing وحدها**. ده اللي بيخسر فيه الناس.

---

## 📦 TABLE OF CONTENTS

1. [EC2 Purchasing Options — الـ Boss Fight](#1-ec2-purchasing-options)
2. [Savings Plans](#2-savings-plans)
3. [AWS Organizations + Consolidated Billing](#3-aws-organizations)
4. [Billing & Cost Tools](#4-billing--cost-tools)
5. [AWS Support Plans](#5-aws-support-plans)
6. [AWS Trusted Advisor](#6-aws-trusted-advisor)
7. [Free Tier + Pricing Models](#7-free-tier--pricing-models)
8. [Control Tower + Service Catalog + RAM](#8-control-tower--service-catalog--ram)
9. [Keyword Trap Table — Domain 4](#9-keyword-trap-table)
10. [زتونة الإنترفيو — Domain 4](#10-interview-zitona)

---

## 1. EC2 Purchasing Options

> **44 سؤال في الـ dumps على الموضوع ده** — ده الأهم في Domain 4 بالكتير.
> غلطت فيه 3 مرات في الامتحانات. اقرأ القواعد دي كويس.

### الـ 5 Options — المقارنة الكاملة

| Option | Discount vs On-Demand | Commitment | Best For | Keyword |
|---|---|---|---|---|
| **On-Demand** | 0% (baseline) | None | Short-term, unpredictable, can't be interrupted | "no commitment / short / unpredictable / cannot be interrupted + unspecified duration" |
| **Reserved Instances** | Up to 75% | 1 or 3 years | Steady-state, long-term, predictable | "1 year / 3 years / steady state / predictable / long-term" |
| **Spot Instances** | Up to 90% | None | Fault-tolerant, flexible, can be interrupted | "cheapest / batch jobs / can be interrupted / flexible / stateless" |
| **Dedicated Host** | — (On-Demand or Reserved) | On-demand or 1/3 yr | **BYOL: per-socket/per-core/per-VM licensing** | "per-socket / per-core / per-VM / BYOL / Windows Server license / compliance" |
| **Dedicated Instance** | — | — | Physical isolation, single-tenant | "physical isolation / no sharing hardware / compliance (without license)" |
| **Savings Plans** | Up to 72% | 1 or 3 years | Flexible (EC2, Fargate, Lambda) | "flexible / any instance family / compute savings" |

---

### ⚡ The Decision Tree — اتبع ده في كل سؤال

```
Q: What EC2 purchasing option?
          │
          ▼
    Has "per-socket / per-core / per-VM / BYOL / Windows license"?
          │
     YES ─┴─ NO
      │         │
  Dedicated     ▼
   HOST      Can be interrupted / fault tolerant / batch?
                  │
             YES ─┴─ NO
              │         │
            SPOT        ▼
                  Mentions "1 year" or "3 years" or "steady-state" or "predictable"?
                        │
                   YES ─┴─ NO
                    │         │
                Reserved    On-Demand
                Instances   (default answer for "no downtime" without duration)
```

---

### 🔥 The Rules Your Brain Keeps Forgetting

**Rule 1:** "no downtime / without interruption" + **no duration mentioned** → **On-Demand**
- لو مقالش 1 سنة أو 3 سنين → Reserved مش منطقية
- "most cost-effective" + short/seasonal → **On-Demand** wins

**Rule 2:** "2 months/year" or "seasonal" → **On-Demand**
- Reserved بتدفع فيها طول الـ 1/3 سنين حتى لو مش شغلة
- شغل 2 شهر بس → On-Demand أوفر

**Rule 3:** "per-socket / per-core / per-VM" → **Dedicated HOST** مش Dedicated Instance
- Dedicated Host = تقدر تحدد الـ physical server وتحط licenses عليه
- Dedicated Instance = physical isolation بس، مش بتتحكم في الـ server

**Rule 4:** "can tolerate interruption / background batch / flexible start/end" → **Spot**
- Spot = AWS بيوقفها لو محتاج الـ capacity للـ On-Demand

---

### Reserved Instances — Deep Dive

| Type | Flexibility | Discount |
|---|---|---|
| **Standard RI** | Fixed instance type, region, OS | 75% discount |
| **Convertible RI** | Can change instance type, OS | 54% discount (less savings) |

**Payment Options:**
- All Upfront → maximum savings
- Partial Upfront → middle
- No Upfront → least savings but no initial payment

> Keyword: "change instance type later" → **Convertible RI**
> Keyword: "maximum savings / locked in" → **Standard RI**

---

## 2. Savings Plans

> بديل للـ Reserved Instances بس أمرن

| Plan | Discount | Flexibility | Covers |
|---|---|---|---|
| **EC2 Savings Plan** | Up to 72% | Fixed family + region | EC2 only (any AZ/size/OS) |
| **Compute Savings Plan** | Up to 66% | Any family, region, size, OS | EC2 + Fargate + Lambda |
| **ML Savings Plan** | Variable | SageMaker | SageMaker only |

> Keyword: "commit $ per hour / flexible / EC2+Fargate+Lambda" → **Compute Savings Plan**
> Setup from: **AWS Cost Explorer** console

---

## 3. AWS Organizations

### What It Does

- Manage **multiple AWS accounts** from one master/management account
- **Consolidated Billing** = one bill for all accounts
- **Volume discounts** across all accounts combined
- Share Reserved Instances across accounts

### Service Control Policies (SCP)

| Rule | Detail |
|---|---|
| Applied to | OU or Account level |
| Does NOT apply to | Master/Management account |
| Applies to | ALL users + roles + **Root user** in member accounts |
| Default | Denies everything — must explicit Allow |
| Use case | "Restrict EMR in dev OU / enforce PCI compliance" |

> ⚠️ SCP مش بتأثر على الـ Management account — ده trap بيجي في الامتحان

### Consolidated Billing Benefits

- Single payment method
- **Combined usage** = higher volume = better discount
- **Pool Reserved Instances** — account A's unused RIs help account B

---

### AWS Control Tower

- **Governance layer on top of Organizations**
- Automates multi-account setup with best practices
- Uses **guardrails** (preventive + detective) for policy enforcement
- Keyword: "govern / best practices / multi-account setup / guardrails / policy violations"

> Control Tower ≠ Organizations — Control Tower runs **on top of** Organizations

---

## 4. Billing & Cost Tools

### The 3 Categories

```
ESTIMATING (before you spend)
    └─ AWS Pricing Calculator → "how much will this architecture cost?"

TRACKING (while you spend)
    ├─ Billing Dashboard → high-level overview
    ├─ Cost Allocation Tags → tag resources → detailed reports
    ├─ Cost & Usage Reports (CUR) → most comprehensive raw data
    └─ Cost Explorer → visualize + forecast + rightsizing

ALERTING (when you overspend)
    ├─ Billing Alarms (CloudWatch) → simple threshold in us-east-1
    └─ AWS Budgets → advanced: cost/usage/RI/Savings Plans alerts
```

### Tool-by-Tool Breakdown

| Tool | Does What | Keyword |
|---|---|---|
| **Pricing Calculator** | Estimate cost before deploying | "estimate / before / how much will it cost" |
| **Cost Explorer** | Visualize past + forecast future + recommend Savings Plans | "visualize / forecast 12 months / rightsizing / current usage" |
| **Cost & Usage Report (CUR)** | Most detailed raw billing data, integrates with Athena/Redshift/QuickSight | "most comprehensive / detailed / hourly line items / Athena" |
| **Billing Alarms** | Simple CloudWatch alarm when total bill exceeds threshold | "simple / actual cost only / us-east-1 / not projected" |
| **AWS Budgets** | Advanced alerts: cost/usage/RI/Savings Plans + 5 SNS notifications | "budget / alert before spending / RI utilization / SNS" |
| **Cost Anomaly Detection** | ML detects unusual spending automatically (no threshold needed) | "unusual / spike / ML / automatic detection / no threshold" |
| **AWS Compute Optimizer** | Rightsize EC2, EBS, Lambda, ASG recommendations | "rightsize / optimal instance / over-provisioned / CloudWatch metrics" |

> ⚠️ **الـ Traps (Q396 + Q374 + Q635):**
> - "Cost Explorer demonstrates what concept?" → **Rightsizing** (مش resilience أو reliability)
> - "Compute Optimizer sizing recommendations for?" → **EC2** (مش Lightsail, مش RDS)
> - "Ongoing optimization + security checks?" → **Trusted Advisor** (مش Health Dashboard)

---

### Billing Alarms vs AWS Budgets

| | **Billing Alarms** | **AWS Budgets** |
|---|---|---|
| Where | CloudWatch (us-east-1 only) | AWS Budgets console |
| Tracks | Actual cost only | Cost, Usage, RI, Savings Plans |
| Projections | ❌ No | ✅ Yes |
| Notifications | CloudWatch alarm | Up to 5 SNS |
| Complexity | Simple | Advanced |

---

### Cost Allocation Tags

- **AWS generated:** prefix `aws:` — e.g., aws:createdBy
- **User defined:** prefix `user:` — e.g., user:Environment
- Used to create **Resource Groups** and detailed billing reports

---

## 5. AWS Support Plans

> **7 سؤال في الـ dumps** — حافظ الجدول ده

| Plan | Price | Response Time | Key Feature | Keyword |
|---|---|---|---|---|
| **Basic** | Free | Docs/forums only | 7 core Trusted Advisor checks + Personal Health Dashboard | "free / documentation / forums" |
| **Developer** | $29/mo | < 24h general / < 12h impaired | 1 contact, business hours email | "dev / testing / non-production" |
| **Business** | $100/mo | < 24h / < 12h / < 4h prod impaired / **< 1h prod down** | Full Trusted Advisor + 24/7 phone/chat + IEM (extra fee) | "production workloads / 24/7 / 1 hour response" |
| **Enterprise On-Ramp** | $5,500/mo | + **< 30min biz-critical** | Pool of TAMs + Concierge + IEM included | "pool of TAMs / concierge / 30 min" |
| **Enterprise** | $15,000/mo | + **< 15min biz-critical** | Dedicated TAM + Concierge + IEM + Incident Detection | "designated TAM / mission critical / 15 min / IEM included free" |

### Critical Support Plan Rules

> ⚠️ **الـ Trap (Q71):**
> - "Operational readiness assessment + event guidance **at no additional charge**" → **Enterprise Support**
> - Business Support بيديك Infrastructure Event Management (IEM) بس بـ **additional fee**
> - Enterprise بيديك IEM **مجاناً** included

**TAM (Technical Account Manager):**
- Enterprise On-Ramp → **Pool** of TAMs (shared)
- Enterprise → **Designated** TAM (dedicated one person)

**Trusted Advisor Access:**
- Basic + Developer → 7 core checks only
- Business + Enterprise → Full checks + API access

---

## 6. AWS Trusted Advisor

### الـ 6 Categories

| Category | Example Check |
|---|---|
| **Cost Optimization** | Idle EC2, underutilized RDS |
| **Performance** | High utilization EC2, CloudFront config |
| **Security** | MFA on root, open S3 buckets, unrestricted SG ports |
| **Fault Tolerance** | No Multi-AZ RDS, low EBS snapshots |
| **Service Limits** | Approaching EC2 limit, VPC limit |
| **Operational Excellence** | (New category) |

> ⚠️ **"Ongoing optimization + security recommendations"** → **Trusted Advisor** (مش Health Dashboard, مش Systems Manager)

---

## 7. Free Tier + Pricing Models

### AWS Pricing Models (4)

| Model | Meaning | Keyword |
|---|---|---|
| **Pay as you go** | Pay only what you use | "agile / no commitment / flexible" |
| **Save when you reserve** | RI discount for commitment | "predictable / long-term / 1/3 years" |
| **Pay less by using more** | Volume discounts | "economies of scale / tiered pricing / more = cheaper" |
| **Pay less as AWS grows** | Savings passed to customers over time | "AWS grows = you save" |

### Free Tier Types

| Type | Duration | Examples |
|---|---|---|
| **Always Free** | Forever | Lambda 1M req/mo, DynamoDB 25GB |
| **12 Months Free** | First 12 months | EC2 750hrs t2.micro, S3 5GB |
| **Trials** | Short period | Lightsail 30 days, SageMaker 2 months |

### What's Always Free

- **Lambda**: 1,000,000 requests/month + 400,000 GB-seconds compute
- **DynamoDB**: 25 GB storage + 200M requests/month
- **IAM**: Always free
- **CloudFormation**: Free (pay for resources it creates)
- **Auto Scaling**: Free (pay for EC2 instances)
- **Elastic Beanstalk**: Free (pay for resources)

---

### Data Transfer Pricing Rules

| Transfer | Cost |
|---|---|
| **Inbound to AWS** | Free |
| **Within same AZ (private IP)** | Free |
| **Between AZs (private IP)** | $0.01/GB |
| **Between AZs (public/Elastic IP)** | $0.02/GB |
| **Between Regions** | $0.02/GB |
| **Outbound to internet** | Tiered pricing |

> 💡 **Tip:** Use private IPs + same AZ = maximum savings (but less HA)

---

## 8. Control Tower + Service Catalog + RAM

| Service | Purpose | Keyword |
|---|---|---|
| **AWS Control Tower** | Govern multi-account environment with guardrails | "best practices / multi-account / guardrails / automate setup" |
| **AWS Service Catalog** | Pre-approved product catalog for self-service | "self-service / pre-defined / admins approve / users launch" |
| **AWS RAM (Resource Access Manager)** | Share resources across accounts in Org | "share VPC subnet / Transit Gateway / avoid duplication / cross-account" |

---

## 9. Keyword Trap Table — Domain 4

### EC2 Pricing Traps (الأخطر)

| Question Says | Answer | NOT |
|---|---|---|
| "no downtime" + no duration mentioned | **On-Demand** | ❌ Reserved |
| "2 months/year / seasonal / short-term" | **On-Demand** | ❌ Reserved |
| "1 year / 3 years / steady-state / predictable" | **Reserved Instances** | ❌ On-Demand |
| "per-socket / per-core / per-VM / BYOL / Windows license" | **Dedicated HOST** | ❌ Dedicated Instance |
| "physical isolation / single-tenant, no license mention" | **Dedicated Instance** | ❌ Dedicated Host |
| "can be interrupted / batch / fault-tolerant / cheapest" | **Spot Instances** | ❌ On-Demand |
| "change instance family / flexible reserved" | **Convertible RI** | ❌ Standard RI |

### Billing Tools Traps

| Question Says | Answer | NOT |
|---|---|---|
| "estimate cost before deploying" | **Pricing Calculator** | ❌ Cost Explorer |
| "visualize + forecast 12 months" | **Cost Explorer** | ❌ CUR |
| "most comprehensive / hourly line items / Athena" | **Cost & Usage Report** | ❌ Cost Explorer |
| "simple alarm when bill exceeds X" | **Billing Alarm** | ❌ Budgets |
| "alert before budget runs out / RI utilization" | **AWS Budgets** | ❌ Billing Alarm |
| "unusual spend / ML / no threshold needed" | **Cost Anomaly Detection** | ❌ Budgets |
| "rightsize EC2 / optimal instance type" | **Compute Optimizer** | ❌ Cost Explorer |
| "Cost Explorer demonstrates which concept?" | **Rightsizing** | ❌ Resilience |

### Support Plan Traps

| Question Says | Answer | NOT |
|---|---|---|
| "event guidance at no additional charge / IEM free" | **Enterprise** | ❌ Business |
| "designated TAM / single TAM" | **Enterprise** | ❌ Enterprise On-Ramp |
| "pool of TAMs / concierge" | **Enterprise On-Ramp** | ❌ Enterprise |
| "24/7 + production + 1 hour response" | **Business** | ❌ Developer |
| "7 core checks only" | **Basic or Developer** | ❌ Business |
| "full Trusted Advisor + API" | **Business or Enterprise** | ❌ Developer |

---

## 10. زتونة الإنترفيو 🫒 — Domain 4

**EC2 Pricing القاعدة الذهبية:**
Short/unspecified = On-Demand | 1-3yr steady = Reserved | Can interrupt = Spot | per-socket license = Dedicated HOST

**Billing Tools بالترتيب:**
Estimate → Pricing Calculator | Track detailed → CUR | Visualize/Forecast → Cost Explorer | Alert simple → Billing Alarm | Alert advanced → Budgets | ML anomaly → Cost Anomaly Detection | Rightsize → Compute Optimizer

**Support Plans بالأرقام:**
Basic=free | Developer=$29 | Business=$100+1hr response | On-Ramp=$5500+30min+pool TAM | Enterprise=$15000+15min+dedicated TAM+IEM free

**Organizations:**
SCP مش بتأثر على Management Account | Consolidated Billing = volume discount + pool RIs

**Free Always:**
Lambda 1M req | DynamoDB 25GB | IAM | CloudFormation | Auto Scaling | Beanstalk
