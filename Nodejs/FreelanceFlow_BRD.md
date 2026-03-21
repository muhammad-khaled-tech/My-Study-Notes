# FreelanceFlow — Business Requirements Document

> This is the document you would have after your first meeting with the client.
> Read this before touching any code. Every model, every field, every rule has a reason.
> When you ask "why do we have this?" — the answer is in here.

---

## The Client Meeting

You sit down with **Tarek**, a 38-year-old Egyptian entrepreneur. He has a problem.

> "I run a small agency. Every time I need a freelancer — a developer, a designer, a writer — I go to WhatsApp groups and Facebook. I post what I need, 40 people send me their prices in DMs, I lose track, I forget who said what, I end up hiring the wrong person, and half the time the job doesn't get done properly. I want a platform that organizes this."

You ask him questions for two hours. By the end, you have this:

---

## The Problem Being Solved

The current process is:
1. Client posts a need informally (WhatsApp, Facebook)
2. Freelancers respond chaotically — no standard format
3. Client has no way to compare bids
4. No record of who worked on what
5. No accountability — no reviews, no reputation
6. Payment and completion have no tracking

FreelanceFlow replaces this with a structured, trackable workflow.

---

## The Two Users

### The Client
Someone who has work that needs to be done. They:
- Post projects with a clear description, budget range, required skills, and deadline
- Review proposals from freelancers
- Choose one freelancer per project
- Mark the project as complete when the work is done
- Leave a review for the freelancer

### The Freelancer
Someone who has skills and wants to get hired. They:
- Browse open projects that match their skills
- Submit a proposal — their pitch, their price
- Either get accepted or rejected
- Build a reputation through reviews and ratings

---

## The Full Journey — One Complete Story

```
1. Ali (Client) registers → role: client

2. Sara (Freelancer) registers → role: freelancer

3. Ali posts a project:
   "Build a React dashboard"
   Budget: $500 - $2000
   Skills needed: React, Node.js
   Deadline: 3 months from now

4. Sara browses open projects → sees Ali's project

5. Sara submits a proposal:
   Cover letter: "I have 5 years of React experience..."
   Her bid: $1200

6. Omar (another freelancer) also submits a proposal:
   His bid: $900

7. Ali reviews both proposals

8. Ali accepts Sara's proposal →
   - Sara's proposal: accepted ✅
   - Omar's proposal: rejected automatically ❌
   - Project status: open → in_progress automatically

9. Sara does the work

10. Ali marks the project as completed →
    Project status: in_progress → completed

11. Ali leaves Sara a review:
    Rating: 5 stars
    Comment: "Excellent work, delivered on time"

12. Sara's average rating updates automatically
```

Every step in this journey maps directly to something in the codebase.

---

## The Data Models — Why Each One Exists

### User Model

Exists because both Clients and Freelancers need accounts. They are the same entity in the database — differentiated by a `role` field.

**Why one model and not two?**
They share almost everything — name, email, password, authentication. Splitting into two models would mean two login endpoints, two register endpoints, duplicated logic. One model with a `role` field is simpler and correct.

```
User
├── name          — who they are
├── email         — how they log in (unique — no two accounts same email)
├── password      — stored as a hash, never plain text
├── role          — 'client' or 'freelancer' — controls what they can do
├── avgRating     — only meaningful for freelancers, but stored on all users
├── ratingsCount  — how many reviews this freelancer has received
├── createdAt     — when they joined
└── updatedAt     — when their profile was last changed
```

**Why `avgRating` on the User model?**
When a client browses freelancers, they need to see the rating quickly — without running a separate aggregation query every time. The rating is calculated from the Reviews collection and cached on the User document automatically every time a review is added or removed.

---

### Project Model

Exists because the Client needs a structured way to post work. The project is the central object — everything else (proposals, reviews) revolves around it.

```
Project
├── title           — short name of the work
├── description     — full details (min 20 chars — forces real descriptions)
├── budget.min      — lowest the client will pay
├── budget.max      — highest the client will pay
├── skillsRequired  — array of strings — what the freelancer must know
├── deadline        — when the work must be done by
├── status          — the lifecycle: open → in_progress → completed / cancelled
├── client          — reference to the User who created it
├── acceptedFreelancer — reference to the User who got hired (null until accepted)
├── createdAt
└── updatedAt
```

**Why `budget.min` and `budget.max` instead of a single price?**
The client doesn't know the exact price — they have a range. Freelancers bid within that range. This is how real platforms work (Upwork, Freelancer.com).

**Why a `status` field?**
A project is not just data sitting in a database — it has a lifecycle. You cannot accept a proposal on a cancelled project. You cannot review a project that is still in progress. The `status` field enforces these rules.

```
open → in_progress → completed
 ↓
cancelled
```

**Why `acceptedFreelancer`?**
When a project is completed, the client needs to leave a review for the specific freelancer who worked on it. Without this field, the system cannot verify "did this freelancer actually work on this project?" before allowing a review.

---

### Proposal Model

Exists because the Freelancer needs a structured way to express interest in a project. The proposal is the handshake between Freelancer and Project.

```
Proposal
├── project      — which project this is for
├── freelancer   — who submitted it
├── coverLetter  — their pitch (min 50 chars — forces real pitches, not just a number)
├── bidAmount    — how much they want
├── status       — pending / accepted / rejected
├── createdAt
└── updatedAt
```

**Why a minimum length on `coverLetter`?**
Tarek's original complaint was that freelancers just sent prices with no context. The minimum forces them to write something real.

**Why can't the same freelancer submit two proposals on the same project?**
It doesn't make sense — you can't bid against yourself. The database enforces this with a compound unique index on `{project, freelancer}`.

**Why does accepting one proposal automatically reject the others?**
Once you hire someone, the job is taken. Leaving other proposals as "pending" is misleading — the freelancers are waiting for an answer that will never come. The cascade makes the system honest automatically.

**Why does accepting a proposal automatically change the project status?**
Because the project is now in progress — it should no longer appear in the "open projects" list. If this wasn't automatic, a client might forget to update the status, and other freelancers would keep submitting proposals on a project that's already hired.

---

### Review Model

Exists because freelancers need a reputation system. Without reviews, every client is starting from zero — they have no way to know if a freelancer is good.

```
Review
├── project     — which project this review is for
├── reviewer    — the client who is writing the review (ref: User)
├── freelancer  — the freelancer being reviewed (ref: User)
├── rating      — 1 to 5 stars
├── comment     — written feedback (min 10 chars)
├── createdAt
└── updatedAt
```

**Why is `reviewer` stored, not just `client`?**
For clarity and to allow future expansion. `reviewer` is semantically cleaner — it describes the role of that person in this context.

**Why can a client only review a freelancer from a completed project?**
Three reasons:
1. The work must be done — you cannot review work that hasn't been delivered
2. The review must be for the freelancer who actually did the work — verified via `acceptedFreelancer` on the project
3. The project must belong to this client — a client cannot review someone else's project

**Why does the rating update automatically?**
Manual updates would be inconsistent — a developer might forget to update it. A static method on the Review model recalculates the average from scratch every time a review is added or deleted. This way the rating is always accurate.

---

## The Business Rules — Every Rule Has a Reason

These are the constraints Tarek gave you in the meeting:

| Rule | Why |
|------|-----|
| Only clients can create projects | Freelancers don't post work — they find it |
| Only freelancers can submit proposals | Clients don't bid on their own projects |
| One proposal per freelancer per project | You can't bid against yourself |
| Accepting a proposal rejects all others | The job is taken — be honest about it |
| Only the project owner can accept proposals | Other people cannot decide for you |
| Only completed projects can be reviewed | You review results, not promises |
| Only the client of that project can review | You review work you paid for |
| Only the freelancer who did the work gets reviewed | Review the right person |
| Projects cannot be cancelled once in_progress | A freelancer is already working — protect them |
| Ratings update automatically | Human memory is unreliable |
| Passwords are never stored plain text | If the database is stolen, passwords are useless to attackers |
| JWT expires in 7 days | Security — old tokens should not work forever |
| Email is unique per user | One account per person |

---

## What the API Exposes

Every endpoint maps to one action in the user journey above.

```
Authentication
  POST /api/v1/auth/register     → Step 1 and 2 (Ali and Sara register)
  POST /api/v1/auth/login        → Any user logs in

Projects
  POST   /api/v1/projects        → Step 3 (Ali posts a project)
  GET    /api/v1/projects        → Step 4 (Sara browses open projects)
  GET    /api/v1/projects/:id    → Sara looks at a specific project
  PATCH  /api/v1/projects/:id    → Ali edits the project details
  DELETE /api/v1/projects/:id    → Ali cancels the project (soft delete)
  PATCH  /api/v1/projects/:id/complete → Step 9 (Ali marks it done)

Proposals
  POST  /api/v1/projects/:id/proposals  → Step 5 and 6 (Sara and Omar bid)
  GET   /api/v1/projects/:id/proposals  → Step 7 (Ali reviews bids)
  PATCH /api/v1/proposals/:id/accept    → Step 8 (Ali accepts Sara)

Reviews
  POST /api/v1/reviews                        → Step 11 (Ali reviews Sara)
  GET  /api/v1/reviews/stats/:freelancerId    → Sara's dashboard stats
```

---

## What the Frontend Needs to Show

When you build the Angular frontend, every screen maps to this business logic:

**For a Client (Ali):**
- Dashboard — his projects and their statuses
- Create Project form — title, description, budget range, skills, deadline
- Project detail — see all proposals, compare bids, accept one
- Review form — after project is completed

**For a Freelancer (Sara):**
- Browse Projects — list of open projects, filterable by skill
- Project detail — read the full description before bidding
- Submit Proposal form — cover letter + bid amount
- My Proposals — status of all her bids (pending / accepted / rejected)
- My Profile — her rating, number of reviews, stats

**Shared:**
- Register / Login pages
- JWT stored in localStorage or memory — sent in every request header

---

## The Stack Decision — Why These Tools

| Tool | Why |
|------|-----|
| Node.js + Express | Fast to build, huge ecosystem, same language as the frontend (JS) |
| MongoDB | Flexible schema — projects can have different skill sets, proposals vary in structure |
| Mongoose | Adds validation and hooks that MongoDB alone doesn't provide |
| JWT | Stateless auth — scales horizontally, no session storage needed |
| bcrypt | Industry standard for password hashing — slow by design to resist brute force |

---

> Read this document once before Sprint 0 and once before Sprint 5.
> The first read gives you the big picture.
> The second read connects the dots after you have seen the code.
