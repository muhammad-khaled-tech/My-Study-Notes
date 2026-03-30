# 🏛️ DevArcheology AI — The Complete Master Reference

> *"Every line of code has a story. We help developers understand the WHY, not just the WHAT."*

**Version:** Defense-Ready Build | March 2026
**Track:** ITI Open Source Applications Development — Gen-AI Capstone
**Status:** 🟢 Gold Tier Target (99/100)

---

## 🗺️ Table of Contents

1. [[#The Story — Why This Exists]]
2. [[#Business Domain & Market Intelligence]]
3. [[#The Killer Question — Positioning vs Competitors]]
4. [[#Competitive Landscape — The Real Map]]
5. [[#Solution Architecture — The Full System]]
6. [[#The 6-Agent Orchestration Engine]]
7. [[#RAG Implementation — Hybrid Retrieval]]
8. [[#The Cold Start Problem — Solved]]
9. [[#The Slack Problem — Solved]]
10. [[#VS Code Extension — The Daily Driver]]
11. [[#Web Admin Portal — The Team Brain]]
12. [[#The Archaeology Trail — The Wow Moment]]
13. [[#Developer DNA Profiles — The Enterprise Killer]]
14. [[#Tech Stack — Hybrid Architecture]]
15. [[#Security — OWASP LLM Top 10]]
16. [[#Observability & Evaluation]]
17. [[#Business Model & Monetization]]
18. [[#ITI Checklist Coverage Map]]
19. [[#Team Structure & Ownership]]
20. [[#4-Week Execution Timeline]]
21. [[#Success Metrics & KPIs]]
22. [[#The 60-Second Wow Moment]]
23. [[#Interview Zitona 🫒]]

---

## The Story — Why This Exists

### The Scene

Ahmed joins a fintech company as a backend developer. Day 3. He opens the payment processing module and finds this:

```javascript
// DO NOT CHANGE THIS TIMEOUT VALUE
const PAYMENT_RETRY_TIMEOUT = 847;
```

`847`? Not `1000`. Not `500`. `847`.

Ahmed spends **4 hours** trying to understand why. He runs `git blame`. He finds the commit. The message says: *"fix timeout issue"*. He searches Jira. The ticket is closed with no description. He asks the senior dev. The senior dev who wrote it left 8 months ago.

**The knowledge is gone. The WHY is dead.**

This happens **35% of a developer's working life** — time spent understanding existing code instead of writing new features. That's 14 hours of a 40-hour week, per developer, across every software team on earth.

### The Problem Statement

```
THE CONTEXT GAP
───────────────
WHAT changed  →  git blame, git log .............. ✅ SOLVED (GitLens)
WHEN changed  →  commit timestamps ............... ✅ SOLVED (GitLens)
WHO changed   →  author metadata ................. ✅ SOLVED (GitLens)

WHY it changed →  ???????????????? .............. ❌ UNSOLVED
WHY like that →  ???????????????? .............. ❌ UNSOLVED
WHY still here →  ???????????????? .............. ❌ UNSOLVED
```

The WHY lives scattered across **5 different tools** that never talk to each other:

```mermaid
graph TD
    WHY["❓ WHY was this<br>code written this way?"]

    WHY --> G["📁 Git History<br>commit messages"]
    WHY --> PR["🔀 Pull Request<br>review debates"]
    WHY --> J["🎫 Jira Tickets<br>business context"]
    WHY --> S["💬 Slack Threads<br>decision moments"]
    WHY --> DOC["📄 Docs / Comments<br>tribal knowledge"]

    G --> PAIN["⏱️ 20-45 minutes<br>manual archaeology<br>per investigation"]
    PR --> PAIN
    J --> PAIN
    S --> PAIN
    DOC --> PAIN

    PAIN --> COST["💸 35% of developer time<br>= $5,250/month per team<br>in wasted senior dev hours"]

    style WHY fill:#ff6b6b,color:#fff
    style PAIN fill:#ffa500,color:#fff
    style COST fill:#dc3545,color:#fff
```

### The Vision

> DevArcheology AI is the **institutional memory layer** for software teams. It synthesizes Git, PRs, Jira, and Slack into a **5-second narrative** that answers the question no tool answers: **WHY**.

---

## Business Domain & Market Intelligence

### Where We Sit in the Market

```mermaid
graph TD
    PARENT["🌐 AI Code Tools Market<br>$7.37B in 2025<br>→ $23.97B by 2030<br>CAGR: 26.6%"]

    PARENT --> GEN["⚡ Code Generation<br>GitHub Copilot, Cursor<br>Most crowded segment"]
    PARENT --> REVIEW["🔍 Code Review<br>CodeRabbit, Qodo<br>Growing fast"]
    PARENT --> INTEL["🧠 Developer Intelligence<br>Sourcegraph, GitLens<br>Our parent segment"]
    PARENT --> MEMORY["🏛️ Institutional Memory<br>DevArcheology AI<br>UNSOLVED NICHE ← WE ARE HERE"]

    style MEMORY fill:#2ecc71,color:#fff
    style PARENT fill:#3498db,color:#fff
```

### Market Numbers to Memorize

| Stat | Number | Source |
|---|---|---|
| AI Code Tools Market 2025 | **$7.37 Billion** | Market Research |
| Projected 2030 | **$23.97 Billion** | CAGR 26.6% |
| Devs using AI tools daily | **97% of enterprise devs** | Industry surveys |
| Developer time on understanding code | **35% of working hours** | Stack Overflow surveys |
| Time saved per AI tool adoption | **30% reduction** in task resolution | Industry benchmark |
| Developers who distrust AI accuracy | **46% vs 33% who trust it** | Key insight: accuracy = product |
| On-premise AI deployment growth | **28.7% CAGR** | Enterprise segment |

### The Three Market Signals

**Signal 1 — Adoption is universal, trust is the problem.**
46% of developers *distrust* AI tool accuracy vs only 33% who trust it. Your target user (senior devs on legacy codebases) is already skeptical. This means: your citation linking and source transparency is not a nice-to-have. **It IS the product.**

**Signal 2 — The "understanding" problem is explicitly unsolved.**
No tool in the market today specifically addresses the "WHY was this written?" question at scale. The whitespace is real and proven by the market.

**Signal 3 — Sourcegraph just retreated from the mid-market.**
As of July 2025, Sourcegraph discontinued Cody Free and Cody Pro. They pivoted to Enterprise-only. The developer who used Cody Free for codebase understanding **has no replacement**. That gap opened 8 months ago. **We walk into it.**

---

## The Killer Question — Positioning vs Competitors

### The Question That Froze You

> *"What's the difference between DevArcheology and CodeRabbit and any AI code reviewer?"*

You froze because you were thinking about **features**. Your supervisor was asking about **product category**. Never confuse these two again.

### The Answer — The Timeline

```mermaid
timeline
    title The Developer Workflow — Where Each Tool Lives
    section Writing Code
        Developer writes feature : Cursor / Copilot assist
        Code generation happens : AI code gen tools active
    section Review Phase
        PR opened : CodeRabbit activates
        Line-by-line review : AI reviewer comments
        PR merged : CodeRabbit DIES HERE
    section The Graveyard
        Code sits in production : No tool covers this
        New dev joins team : Inherits mystery code
        847 timeout found : Nobody knows why
        Original dev left : Knowledge is gone
    section DevArcheology Zone
        Dev asks WHY : DevArcheology activates
        5-agent synthesis : Story generated in 5s
        Full context recovered : WHY answered
```

### The Script — Memorize Every Word

**When they ask:** *"What's the difference between you and CodeRabbit?"*

**You say:**

> *"CodeRabbit and all AI code reviewers are **forward-looking** tools. They answer: 'Should we merge this?' They activate when a PR opens and they die when it merges.*
>
> *DevArcheology is a **backward-looking** tool. It answers: 'Why was this merged 2 years ago?' It activates when a new developer inherits old code and needs to understand a decision made by someone who no longer works at the company.*
>
> *The right analogy: CodeRabbit is a **building inspector** reviewing a house before you move in. DevArcheology is the **historian** you call 10 years later when you find a strange wall and need to know if removing it will collapse the building."*

### The Three Proof Points

| Proof Point | The Fact |
|---|---|
| **Different data sources** | CodeRabbit reads your new diff. DevArcheology reads entire Git history + closed PRs + archived Jira tickets + 18-month-old Slack threads. CodeRabbit cannot access any of this. |
| **Different user, different moment** | CodeRabbit user = developer who wrote the code, before merge. DevArcheology user = developer who inherited the code, 6 months after the original author left. |
| **CodeRabbit creates the problem we solve** | Every clever decision CodeRabbit approves becomes invisible after merge. DevArcheology recovers exactly those decisions 2 years later. **They don't compete — CodeRabbit feeds our RAG corpus.** |

### The One-Line Killer

> *"Show me how CodeRabbit explains a commit from 2 years ago written by a developer who left the company — and I'll shut down DevArcheology today."*

---

## Competitive Landscape — The Real Map

### The Full Competitor Matrix

```mermaid
quadrantChart
    title Competitor Positioning Map
    x-axis Backward-Looking --> Forward-Looking
    y-axis Single Source --> Multi-Source Synthesis
    quadrant-1 Future Tools
    quadrant-2 Our Space
    quadrant-3 Legacy Tools
    quadrant-4 Current AI Tools

    DevArcheology AI: [0.1, 0.95]
    GitLens: [0.25, 0.2]
    CodeRabbit: [0.9, 0.35]
    Sourcegraph Cody: [0.5, 0.45]
    GitHub Copilot: [0.95, 0.1]
    Manual Git Log: [0.15, 0.05]
```

### Tier 1 — Direct Competitors (Head-to-Head)

#### GitLens by GitKraken

**What they do:** Git history visualization inside VS Code. Blame annotations, commit graphs, file history, PR integration.

**What they added recently:** AI-powered commit explanations, changelog generation, Jira Cloud + Trello integration, MCP (Model Context Protocol) support.

**Their gap — your entrance:**
- GitLens shows you the **tombstone** of the code (WHO, WHEN, WHAT)
- DevArcheology tells you the **biography** (WHY, in a synthesized story)
- GitLens stops at metadata. We start where metadata ends.

**When asked about GitLens:**
> *"GitLens is actually a data source for DevArcheology, not a competitor. We consume their Git data and add 4 more layers of context on top."*

---

#### CodeRabbit

**What they do:** AI code review on every PR. Line-by-line comments, bug detection, PR summaries.

**Scale:** 2 million+ repositories, 13 million+ PRs processed, 9,000+ organizations.

**Their pricing:** $12–24/month per user.

**Their key feature:** Codebase-awareness — pulls context from across files.

**The critical insight:**
- CodeRabbit = **prospective** (reviews code before it enters production)
- DevArcheology = **retrospective** (explains code already in production)
- **Different workflow moment. Not competitors.**

---

#### Sourcegraph / Cody

**What they do:** Whole-codebase code search, AI chat with codebase context, autocomplete.

**Plot twist — July 2025:** Sourcegraph **discontinued** Cody Free and Cody Pro. Pivoted to Enterprise-only. Launched "Amp" for individual developers separately.

**What this means for us:** The mid-market they abandoned = our entry point. Developers who relied on Cody Free for codebase understanding have no replacement. **We walk into the gap.**

---

### Tier 2 — Adjacent (Same Budget, Different Use Case)

| Tool | What They Do | Our Relationship |
|---|---|---|
| **GitHub Copilot** | Code generation, 20M+ users | Zero institutional memory. We're complementary. |
| **Greptile** | AI reviews with full codebase context | Newer, well-funded. Watch this space. |
| **Qodo** | Code integrity, test generation | Different niche entirely. |
| **Linear + Jira AI** | Issue tracking with AI summaries | We consume them. We don't compete. |

---

### The Invisible Competitor — The Most Dangerous One

**The developer's brain + Slack search + manual git log.**

This is what developers actually do today:
1. Run `git blame` → get author + commit hash (2 min)
2. Open PR manually → read 47 comments (10 min)
3. Search Slack for ticket number → find thread (8 min)
4. Ask senior dev who wrote it → they left 8 months ago (∞ min)

**Total: 20–45 minutes per investigation, per commit, per developer.**

DevArcheology does this in **5 seconds**. That's your core value proposition expressed in time saved.

---

### When Your Supervisor Asks About Each Competitor

| If they mention... | You say... |
|---|---|
| **GitLens** | "Complementary data source. They show WHO and WHEN. We synthesize WHY." |
| **CodeRabbit** | "Different workflow moment entirely. They die when the PR closes. We activate after." |
| **Sourcegraph** | "They just abandoned the mid-market in July 2025. We walk into their gap." |
| **GitHub Copilot** | "Code generation, not code understanding. Zero institutional memory." |
| **"Any AI reviewer"** | "AI reviewers are forward-looking. We are backward-looking. Ask any of them to explain a 2-year-old commit by a developer who left. They can't." |

---

## Solution Architecture — The Full System

### The 30,000-Foot View

```mermaid
graph TB
    subgraph USER_SURFACES["🖥️ User Surfaces"]
        VSCODE["VS Code Extension<br>──────────────<br>Hover tooltip<br>Inline story preview<br>Timeline sidebar"]
        WEB["Web Admin Portal<br>──────────────<br>Team knowledge base<br>Chat interface<br>Archaeology explorer"]
    end

    subgraph API_GATEWAY["🔀 Node.js API Gateway"]
        AUTH["Auth Service<br>JWT + OAuth"]
        RATE["Rate Limiter"]
        ROUTER["Request Router"]
        OAUTH["OAuth Manager<br>GitHub / Jira / Slack"]
    end

    subgraph AI_ENGINE["🧠 Python AI Engine — FastAPI"]
        SUPERVISOR["Supervisor Agent<br>LangGraph Orchestrator"]
        subgraph PARALLEL_AGENTS["Parallel Retrieval Agents"]
            GIT_A["Git Archeologist"]
            PR_A["PR Context Retriever"]
            JIRA_A["Issue Tracker Linker"]
        end
        SLACK_A["Slack Archaeologist<br>conditional"]
        SYNTH["Story Synthesizer"]
    end

    subgraph RAG_LAYER["🔍 RAG Pipeline"]
        PINECONE["Pinecone<br>Vector DB"]
        HYBRID["Hybrid Retrieval<br>Semantic + BM25"]
        RERANK["Cross-Encoder<br>Reranker"]
    end

    subgraph DATA_SOURCES["📡 Data Sources"]
        GITHUB["GitHub API<br>Commits, PRs, Reviews"]
        JIRA_API["Jira API<br>Tickets, Comments"]
        SLACK_API["Slack API<br>xoxp- User Token"]
        GIT_LOCAL["Local Git<br>blame, log, diff"]
    end

    subgraph OBSERVABILITY["📊 Observability"]
        LANGSMITH["LangSmith<br>Full trace logging"]
        METRICS["Story Metrics<br>Latency, Cost, Quality"]
    end

    VSCODE --> API_GATEWAY
    WEB --> API_GATEWAY
    API_GATEWAY --> AI_ENGINE
    AI_ENGINE --> RAG_LAYER
    AI_ENGINE --> DATA_SOURCES
    AI_ENGINE --> OBSERVABILITY

    style SUPERVISOR fill:#e74c3c,color:#fff
    style SYNTH fill:#9b59b6,color:#fff
    style PARALLEL_AGENTS fill:#3498db,color:#fff
```

---

## The 6-Agent Orchestration Engine

### Why Sequential = Death

Your original proposal had 5 agents running **one after another**:

```
Git Agent (3s) → PR Agent (3s) → Jira Agent (3s) → Slack Agent (3s) → Synth (4s)
Total: 16 seconds ❌  (your target was 5 seconds)
```

### The Optimized Architecture — Supervisor + Parallel

```mermaid
sequenceDiagram
    participant U as Developer
    participant S as Supervisor Agent
    participant G as Git Archeologist
    participant P as PR Retriever
    participant J as Jira Linker
    participant SL as Slack Archaeologist
    participant SY as Story Synthesizer
    participant DB as Pinecone RAG

    U->>S: "Why was this line written this way?"
    Note over S: Analyzes request<br>Checks available integrations<br>Dispatches concurrently

    par Parallel Retrieval (~2s)
        S->>G: Fetch git blame, diffs, commit history
        S->>P: Fetch PR discussions, review comments
        S->>J: Fetch linked Jira tickets, business context
    end

    G-->>S: Git context + confidence score
    P-->>S: PR context + confidence score
    J-->>S: Business context + confidence score

    Note over S: Evaluates completeness<br>Decides if Slack needed

    S->>SL: Search Slack threads (conditional)
    SL->>DB: Semantic search over indexed Slack
    DB-->>SL: Relevant thread chunks
    SL-->>S: Decision moments + tradeoff discussions

    S->>SY: Full context package from all agents
    SY->>SY: LLM synthesis (GPT-4 / Claude)
    SY-->>U: Story + Timeline + Confidence Score

    Note over U: Total: ~5 seconds ✅
```

### The 6 Agents — Roles and Responsibilities

| # | Agent | Role | Tools Used | Failure Mode |
|---|---|---|---|---|
| 0 | **Supervisor** | Orchestrates all agents, decides parallelism, handles failures | LangGraph state machine | Degrades gracefully — skips failed agents |
| 1 | **Git Archeologist** | `git blame`, `git log`, `git diff`, commit message analysis | GitHub API, local git | Falls back to local git only |
| 2 | **PR Context Retriever** | Fetches PR discussions, code review comments, team debates | GitHub REST API | Skips if no linked PR found |
| 3 | **Issue Tracker Linker** | Connects code to business context via Jira/Linear tickets | Jira REST API | Marks as "no business context found" |
| 4 | **Slack Archaeologist** | Searches channel threads for decision-making moments | Slack API xoxp- token | Skips if not connected |
| 5 | **Story Synthesizer** | Combines all context into narrative, detects technical debt | GPT-4 + Claude 3.5 Sonnet | Cannot fail — has all context weights |

### Agent Decision Logic (Supervisor)

```mermaid
flowchart TD
    START["Request received<br>code line + file + repo"]
    START --> PARSE["Parse: extract commit hash<br>file path, line number"]
    PARSE --> DISPATCH["Dispatch parallel agents<br>Git + PR + Jira simultaneously"]

    DISPATCH --> WAIT["Wait for parallel results<br>timeout: 2.5s"]
    WAIT --> EVAL{"Evaluate completeness<br>Score context richness"}

    EVAL -->|"Score >= 3/5"| SYNTH_DIRECT["Go to Synthesizer<br>skip Slack for speed"]
    EVAL -->|"Score < 3/5 AND<br>Slack connected"| SLACK["Run Slack Agent<br>for deeper context"]
    EVAL -->|"Score < 3/5 AND<br>Slack not connected"| CTA["Generate story<br>+ Show connect-Slack CTA"]

    SLACK --> SYNTH["Story Synthesizer"]
    SYNTH_DIRECT --> SYNTH
    CTA --> SYNTH

    SYNTH --> STORY["Return: Story + Score + Citations"]

    style START fill:#3498db,color:#fff
    style SYNTH fill:#9b59b6,color:#fff
    style STORY fill:#2ecc71,color:#fff
```

---

## RAG Implementation — Hybrid Retrieval

### What We Index

| Data Source | Chunk Strategy | Metadata Tags |
|---|---|---|
| Git commit messages | 1 chunk per commit | author, date, files_changed, hash |
| PR discussions | 1 chunk per thread | pr_id, participants, decision_outcome |
| Jira tickets + comments | 1 chunk per ticket | ticket_id, priority, linked_commits |
| Slack threads | 1 chunk per thread | channel, participants, timestamp |
| Code comments + docstrings | 1 chunk per function | file, line_range, author |

### The Hybrid Retrieval Pipeline

```mermaid
flowchart LR
    QUERY["User Query<br>'Why is timeout 847?'"]

    QUERY --> EXPAND["Query Expansion<br>Generate 3 query variants<br>via LLM"]

    EXPAND --> PARALLEL_SEARCH["Parallel Search"]

    PARALLEL_SEARCH --> SEMANTIC["🔵 Semantic Search<br>Dense vector similarity<br>Pinecone HNSW index"]
    PARALLEL_SEARCH --> KEYWORD["🟠 Keyword Search<br>BM25 lexical matching<br>Elasticsearch"]

    SEMANTIC --> FUSION["Score Fusion<br>RRF Algorithm<br>Reciprocal Rank Fusion"]
    KEYWORD --> FUSION

    FUSION --> FILTER["Metadata Filtering<br>by file path, author,<br>date range, source type"]

    FILTER --> RERANK["Cross-Encoder Reranker<br>Re-scores top 20 results<br>for true relevance"]

    RERANK --> TOP_K["Top 5 chunks<br>with source citations"]

    TOP_K --> LLM["LLM Synthesis<br>Grounded generation"]

    style SEMANTIC fill:#3498db,color:#fff
    style KEYWORD fill:#e67e22,color:#fff
    style RERANK fill:#e74c3c,color:#fff
    style LLM fill:#9b59b6,color:#fff
```

### RAG Quality Metrics (RAGAS)

| Metric | Target | What It Measures |
|---|---|---|
| **Context Precision** | > 80% | Are retrieved chunks actually relevant? |
| **Context Recall** | > 85% | Did we miss important context? |
| **Faithfulness** | > 90% | Is the story grounded in retrieved context? |
| **Answer Relevancy** | > 85% | Does the story address "WHY"? |
| **Citation Accuracy** | 100% | Every claim links to a real source |

---

## The Cold Start Problem — Solved

### The Problem

DevArcheology only generates rich stories for repos with:
- Many commits with meaningful messages
- Linked PRs with real discussions
- Connected Jira/Slack

**What happens on Day 1 with an empty repo?**

### The 3-Layer Solution

#### Layer 1 — Demo Mode: Pre-Indexed Famous Repos

Ship on day one with 3 repos **already indexed and live:**

| Repo | Why It's Perfect |
|---|---|
| `microsoft/vscode` | 100K+ commits, famous decisions, rich PR history |
| `facebook/react` | The Hooks decision (2018) — 1,000+ comment PR. The best "WHY" story in open source history |
| `calcom/cal.com` | Modern full-stack, active discussions, Linear tickets |

**Demo script:** Evaluator opens Web Portal → clicks "Explore React" → hovers over the commit that introduced Hooks → sees a full 5-source story in 5 seconds. **Zero setup. Zero permissions. Maximum wow.**

#### Layer 2 — The Story Richness Score (Your Upgrade Funnel)

```
┌─────────────────────────────────────────────────────┐
│  📊 Context Richness for this commit: 3/5            │
│                                                      │
│  ✅ Git Blame & Diff        — Full history available │
│  ✅ PR Discussion           — 12 review comments     │
│  ✅ Code Comments           — 2 relevant docstrings  │
│  ⚠️  Jira Ticket            — Not linked             │
│  ❌ Slack Threads           — Not connected          │
│                                                      │
│  Story Confidence: MEDIUM                            │
│  ────────────────────────────────────────────────── │
│  🔗 Connect Jira to unlock business context →       │
│  💬 Connect Slack to unlock decision moments →      │
└─────────────────────────────────────────────────────┘
```

Every missing source = a CTA to connect. **Cold start becomes the onboarding funnel.**

#### Layer 3 — Minimum Viable Story (Git-Only)

Even with 50 commits and zero integrations, Git alone provides:
- **WHO** built this (author pattern analysis)
- **WHEN** and in what project phase (release proximity)
- **WHAT** problem it was proximate to (nearby commits context)
- **HOW** it evolved (diff analysis across commits)

Framing: *"Based on Git history only — connect Jira and Slack to complete the story."*

---

## The Slack Problem — Solved

### The Myth You Believed

> ❌ "You need Workspace Admin permissions to read Slack messages."

### The Reality

Slack has two token types:
- **Bot Tokens (`xoxb-`)** — app-level, need admin installation ← this is what you were thinking
- **User Tokens (`xoxp-`)** ← **this is what you actually use**

### The xoxp- Solution

```mermaid
sequenceDiagram
    participant D as Developer
    participant DA as DevArcheology
    participant S as Slack OAuth

    D->>DA: Click "Connect Slack"
    DA->>S: Redirect to OAuth flow
    Note over S: Scopes requested:<br>channels:history<br>channels:read<br>search:read

    D->>S: "Allow" — developer logs in
    S->>DA: Returns xoxp- USER token
    Note over DA: Token has exactly the same<br>access as the developer<br>already has in Slack

    DA->>S: conversations.history()<br>search.messages()
    S-->>DA: All messages the developer<br>can already see

    DA-->>D: Slack context integrated<br>into stories
```

**The key insight:** A user token carries the exact permissions the user already has. If you can see a Slack channel, your DevArcheology token can read it. **Zero admin approval. Zero IT department. Zero enterprise sales cycle.**

**Onboarding copy:** *"Sign in with Slack — we only read messages you can already see."*

**Privacy model:** Each developer's stories are built from **their own view** of Slack. This is actually a feature — call it **"Your Context View"** and make it explicit in the UI.

---

## VS Code Extension — The Daily Driver

### The User Journey

```mermaid
journey
    title Developer's Journey with DevArcheology in VS Code
    section Discovers Mystery Code
      Opens legacy file: 3: Developer
      Sees 847 timeout value: 2: Developer
      Hovers over the line: 5: Developer
    section DevArcheology Activates
      Tooltip appears instantly: 5: DevArcheology
      Shows 2-line story preview: 5: DevArcheology
      Shows Context Score 4 of 5: 4: DevArcheology
    section Goes Deeper
      Clicks Full Story: 5: Developer
      Side panel opens: 5: DevArcheology
      Reads full narrative: 5: Developer
      Sees Archaeology Timeline: 5: DevArcheology
    section Takes Action
      Understands the WHY: 5: Developer
      Saves 40 minutes: 5: Developer
      Upvotes the story: 5: Developer
```

### Extension Features

| Feature | Description | Priority |
|---|---|---|
| **Inline Hover Tooltip** | 2-line story preview + context score on hover | P0 — Week 1 |
| **Full Story Panel** | Complete narrative with all sources, citations | P0 — Week 2 |
| **Archaeology Timeline** | Interactive timeline visualization | P1 — Week 3 |
| **Context Score Badge** | Visual indicator of story richness in gutter | P1 — Week 3 |
| **Connect Integrations** | In-extension OAuth flows for Jira/Slack | P1 — Week 3 |
| **Arabic Mode Toggle** | Switch story language to Arabic | P2 — Week 4 |

---

## Web Admin Portal — The Team Brain

### Two Different Users, Two Different Surfaces

| Surface | Primary User | Primary Question |
|---|---|---|
| VS Code Extension | Individual developer | "I'm reading this code RIGHT NOW — why is it like this?" |
| Web Admin Portal | Engineering manager / Tech lead | "Our senior dev left — what decisions did they make? What's our technical debt?" |

### Portal Features

```mermaid
graph LR
    PORTAL["Web Admin Portal"]

    PORTAL --> CHAT["💬 Chat Interface<br>Ask WHY questions<br>in natural language"]
    PORTAL --> EXPLORE["🗺️ Repo Explorer<br>Browse stories<br>by file or author"]
    PORTAL --> TRAIL["⏱️ Archaeology Trail<br>Interactive timeline<br>of decisions"]
    PORTAL --> UPLOAD["📄 Code Upload<br>Paste snippet or file<br>get story instantly"]
    PORTAL --> DNA["🧬 Developer DNA<br>Author profiles<br>and patterns"]
    PORTAL --> DEBT["⚠️ Tech Debt Map<br>AI-detected patterns<br>across codebase"]
    PORTAL --> EXPORT["📥 Export Stories<br>PDF, Markdown<br>for documentation"]

    style CHAT fill:#3498db,color:#fff
    style TRAIL fill:#e74c3c,color:#fff
    style DNA fill:#9b59b6,color:#fff
```

### Why the Portal Matters for Evaluation

**The brutal truth:** Not every evaluator will install a VS Code extension during a 10-minute demo. Every evaluator will click a browser link. The Web Portal **is your evaluation surface**. Build it first. The extension is the daily driver. The portal is the demo.

---

## The Archaeology Trail — The Wow Moment

### What It Is

An interactive **decision biography** timeline — the visual that no competitor has ever built.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY IS PAYMENT_RETRY_TIMEOUT = 847?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Jan 2023              Mar 2023              Aug 2023
    │                     │                     │
 [🎫 JIRA-441]        [💬 PR #892]          [📝 COMMIT a3f7c]
 "Payments timing     "Hot debate: 1000ms   "Changed to 847ms —
  out under load"      vs 500ms. 23 comments  sweet spot found
  P0 incident         Sarah: 'go lower'     after load testing"
  5 reports           Ahmed: 'too risky'
    │                     │                     │
    └─────────────────────┴─────────────────────┘
                           │
               [💬 SLACK #backend-eng]
               Sarah 3 months later:
               "The 847 is from our p95
                latency on worst-case day.
                DON'T CHANGE IT."

STORY CONFIDENCE: 5/5  ████████████████████ HIGH
TECHNICAL DEBT FLAG: ⚠️ Magic number — consider extracting to config
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Implementation

- **Frontend:** D3.js timeline in Web Portal, simplified SVG in VS Code sidebar
- **Data:** Each event node links to its original source (click → opens actual PR/Jira/Slack)
- **Interaction:** Hover reveals full quote, click opens source document
- **Export:** Download as PNG or embed in documentation

**This is your 60-second wow moment.** Nobody else in your class has this. Nobody in the market has this.

---

## Developer DNA Profiles — The Enterprise Killer

### What It Is

After analyzing enough commits and PR reviews by a single author, DevArcheology automatically generates **behavioral profiles** — patterns in how each developer thinks and makes decisions.

### Example Profile

```
┌─────────────────────────────────────────────────────┐
│  🧬 Developer DNA: Sarah Chen                        │
│  Analyzed: 847 commits, 234 PR reviews              │
│                                                      │
│  EXPERTISE MAP                                       │
│  ████████████████░░  Auth/Security (89%)            │
│  ████████████░░░░░░  Payment Systems (67%)          │
│  ████░░░░░░░░░░░░░░  Frontend (23%)                 │
│                                                      │
│  DECISION PATTERNS                                   │
│  • Tends to over-engineer auth boundaries           │
│  • Proposed 3 simplifications overruled by deadlines│
│  • Code is 40% more commented than team average     │
│  • Strong preference for explicit error handling    │
│                                                      │
│  KNOWLEDGE CONCENTRATION                            │
│  ⚠️  SILO RISK: Only author of payment-gateway/*    │
│     Last touch: 8 months ago                        │
│     Replacement context exists: LOW                 │
│                                                      │
│  ONBOARDING VALUE                                   │
│  "Read Sarah's PRs from Jan-Mar 2023 to understand  │
│   why our auth system is structured this way."      │
└─────────────────────────────────────────────────────┘
```

### Why This Is Gold-Tier

No tool on earth does this. GitLens shows you *who* wrote it. DevArcheology tells you *what kind of developer* wrote it and *what tradeoffs they typically made*.

**Enterprise value propositions:**
- New devs onboard 3x faster ("understand the codebase by understanding who built it")
- Tech leads identify knowledge silos before they become crises
- Engineering managers get objective technical debt attribution
- Exit interviews for departing developers generate knowledge transfer reports automatically

---

## Tech Stack — Hybrid Architecture

### The Problem with Pure Python

Your team knows Node.js. Python + FastAPI + LangGraph is the best AI choice. Forcing everyone onto Python = bugs in Week 2 you can't debug.

### The Solution — Clean Microservice Split

```mermaid
graph TB
    subgraph FRONTEND["Frontend Layer"]
        EXT["VS Code Extension<br>TypeScript"]
        PORTAL["Web Admin Portal<br>React + Next.js"]
    end

    subgraph GATEWAY["Node.js API Gateway<br>Express / NestJS"]
        AUTH2["JWT Auth"]
        RATE2["Rate Limiting"]
        OAUTH2["OAuth Flows<br>GitHub + Jira + Slack"]
        WEBSOCKET["WebSocket<br>Streaming stories"]
    end

    subgraph AI_SVC["Python AI Service<br>FastAPI"]
        LANGGRAPH["LangGraph<br>Agent Orchestration"]
        CHAINS["LangChain<br>RAG Chains"]
        EMBEDDINGS["Embedding Service<br>OpenAI ada-002"]
    end

    subgraph STORAGE["Storage"]
        PINECONE2["Pinecone<br>Vector DB"]
        POSTGRES["PostgreSQL<br>Users, Repos, Stories"]
        REDIS["Redis<br>Cache + Queue"]
    end

    FRONTEND --> GATEWAY
    GATEWAY -->|"Internal HTTP"| AI_SVC
    AI_SVC --> STORAGE
    GATEWAY --> STORAGE

    style GATEWAY fill:#68a063,color:#fff
    style AI_SVC fill:#3776ab,color:#fff
```

### Team Ownership Map

| Service | Language | Owner Expertise Needed |
|---|---|---|
| VS Code Extension | TypeScript | Frontend dev |
| Web Portal | React/Next.js | Frontend dev |
| API Gateway | Node.js/Express | Node.js devs ← your strength |
| OAuth flows | Node.js | Node.js dev |
| AI Agent Service | Python/FastAPI | 1-2 members learn LangGraph |
| RAG Pipeline | Python | Same as above |
| Pinecone integration | Python | Same as above |
| PostgreSQL schema | SQL | Any backend dev |

**The Rule:** If the Python service breaks in Week 3, the Node.js gateway still runs. Users get a graceful "Story generation temporarily unavailable" instead of a crash. **Microservice boundary = resilience + clear team ownership.**

---

## Security — OWASP LLM Top 10

```mermaid
graph LR
    subgraph OWASP["OWASP LLM Top 10 — Our Coverage"]
        P1["LLM01: Prompt Injection<br>──────────────<br>Sanitize all commit messages<br>and PR content before<br>injecting into prompts"]
        P2["LLM02: Sensitive Info<br>──────────────<br>PII detection in stories<br>Redact emails, keys,<br>passwords from git history"]
        P3["LLM06: Excessive Agency<br>──────────────<br>Read-only access only<br>No write operations<br>ever executed by agents"]
        P4["LLM08: Insecure Output<br>──────────────<br>Sanitize story HTML<br>XSS prevention on<br>all rendered output"]
        P5["LLM09: Misinformation<br>──────────────<br>Every claim in story<br>linked to source<br>Citation-grounded generation"]
    end
```

### Key Security Decisions

| Decision | Implementation | Why |
|---|---|---|
| **Repo access scope** | Only index repos the user already has access to via their GitHub token | Users can't access data they don't own |
| **Slack scope** | xoxp- user token — only what the user already sees | No privilege escalation |
| **No code execution** | Agents are read-only. No `eval()`, no shell commands | Prevents malicious commit message attacks |
| **Rate limiting** | 20 stories/hour per user, 100 API calls/hour | Cost control + abuse prevention |
| **PII detection** | Scan output for emails, phone numbers, API keys before display | Prevent sensitive data leakage from old commits |

---

## Observability & Evaluation

### LangSmith Integration

Every agent action, every retrieval, every LLM call is traced end-to-end from day 1.

```mermaid
graph LR
    REQUEST["Incoming Request"] --> TRACE["LangSmith Trace ID"]
    TRACE --> SPAN1["Span: Supervisor Agent<br>inputs, outputs, latency"]
    TRACE --> SPAN2["Span: Git Agent<br>tools called, results"]
    TRACE --> SPAN3["Span: RAG Retrieval<br>query, chunks, scores"]
    TRACE --> SPAN4["Span: LLM Call<br>prompt, completion, tokens"]
    TRACE --> SPAN5["Span: Story Output<br>final response, cost"]

    SPAN1 --> DASHBOARD["Metrics Dashboard<br>────────────────<br>P95 Latency<br>Cost per story<br>Agent success rate<br>User feedback score"]
```

### The Continuous Improvement Loop

```
Production Stories
       ↓
User gives 👎 (thumbs down)
       ↓
Flagged story → evaluation queue
       ↓
Team reviews: was retrieval bad? Was synthesis bad?
       ↓
Fix prompt / fix chunking / fix reranker
       ↓
Regression test on golden dataset (50+ ground truth stories)
       ↓
Deploy improved version
       ↓
Measure: did thumbs-up rate improve?
```

---

## Business Model & Monetization

### Pricing Tiers

| Tier | Price | What You Get |
|---|---|---|
| **Free** | $0/month | 10 stories/month, Git + GitHub only, pre-indexed demo repos |
| **Developer** | $15/month | Unlimited stories, + Jira integration, Archaeology Trail |
| **Team** | $49/month per 5 devs | + Slack integration, Developer DNA, Tech Debt Map |
| **Enterprise** | Custom | On-premise deployment, private LLM, SSO, SLA |

### The Sponsor Pitch (For Your Job Fair)

> *"DevArcheology saves your senior engineers 30 minutes every time they touch legacy code.*
>
> *5 senior engineers × 3 investigations/day × $50/hour fully loaded cost = **$5,250 saved per month per team.**
>
> *Our Team plan costs $49/month. That's a **107x ROI** on month one."*

### Go-to-Market Strategy

**Phase 1 — Self-serve (Months 1-6)**
Target: Individual developers via VS Code Marketplace + Product Hunt launch. Free tier drives adoption. Frictionless — no sales call needed.

**Phase 2 — Bottom-up Enterprise (Months 6-18)**
Individual users become internal champions. When 5+ developers at a company are on Free, offer Team upgrade automatically.

**Phase 3 — Enterprise Direct (Month 18+)**
Target CTO/Engineering Director at Egyptian tech companies (Instabug, Breadfast, Paymob, Vodafone Digital) with the institutional memory narrative + Developer DNA for knowledge retention.

---

## ITI Checklist Coverage Map

| Checklist Section | Requirement | DevArcheology Implementation | Tier |
|---|---|---|---|
| **LLM Integration** | Primary LLM + fallback | GPT-4 synthesis + Claude 3.5 Sonnet analysis + Gemini fallback | ✅ Gold |
| **LLM Advanced** | Function calling + Streaming | Agent tool calls + streaming story output | ✅ Gold |
| **RAG — Sources** | Multi-format | Git, PRs, Jira, Slack, code comments | ✅ Gold |
| **RAG — Chunking** | Semantic chunking + overlap | Per-commit, per-thread chunking with metadata | ✅ Gold |
| **RAG — Retrieval** | Hybrid search (min 2) | Semantic + BM25 + reranking | ✅ Gold |
| **RAG — Advanced** | Min 1 advanced feature | Multi-query RAG (3 query variants) | ✅ Gold |
| **Agents — Foundation** | Clear architecture | LangGraph ReAct with state machine | ✅ Gold |
| **Agents — Tools** | Min 3 tools | git_blame, github_api, jira_api, slack_api, pinecone_search | ✅ Gold |
| **Agents — Multi** | 3+ agents coordinated | 6 agents: Supervisor + 4 parallel + Synthesizer | ✅ Gold |
| **Agents — Advanced** | Min 2 features | Human-in-loop (approval) + Agent self-reflection on confidence | ✅ Gold |
| **Multimodal** | Min 2 | Code diff visualization + Archaeology Trail + Code snippet upload | ✅ Silver→Gold |
| **Security** | OWASP LLM Top 10 | Prompt injection, PII detection, rate limiting, read-only agents | ✅ Gold |
| **Observability** | LLM platform | LangSmith full tracing + RAGAS evaluation metrics | ✅ Gold |
| **UX** | Chat + Streaming + Citations | Web Portal chat + real-time streaming + citation bubbles | ✅ Gold |
| **Arabic** | Bilingual support | One-click Arabic mode, code-switching stories, RTL UI | ✅ Gold |
| **Cost Optimization** | Caching + budgets | Redis cache for identical queries, cost dashboard, $0.10/story target | ✅ Gold |
| **Testing** | 60% coverage + LLM tests | 50+ golden stories, RAGAS metrics, adversarial prompt tests | ✅ Gold |
| **Deployment** | Cloud + CI/CD | Railway/Render + GitHub Actions pipeline | ✅ Gold |
| **Documentation** | Full docs | README, API docs, Architecture diagram, Prompt library | ✅ Gold |

---

## Team Structure & Ownership

| Member | Role | Owns |
|---|---|---|
| **Mohamed (You)** | Tech Lead + AI Engineer | LangGraph orchestration, agent design, architecture decisions |
| **Member 2** | Backend Engineer | Node.js API Gateway, OAuth flows, PostgreSQL |
| **Member 3** | AI/RAG Engineer | Python FastAPI, Pinecone, RAG pipeline, embeddings |
| **Member 4** | Frontend Engineer | Web Admin Portal, React, Archaeology Trail (D3.js) |
| **Member 5** | VS Code Extension | TypeScript extension, hover UI, sidebar |
| **Member 6** | QA + Observability | LangSmith integration, RAGAS eval, testing suite, security |

---

## 4-Week Execution Timeline

```mermaid
gantt
    title DevArcheology AI — 4-Week Build Plan
    dateFormat  YYYY-MM-DD
    section Week 1 — Foundation
    Repo setup + CI/CD skeleton         :done, w1a, 2026-03-01, 2d
    Git parser + GitHub API integration :done, w1b, 2026-03-01, 4d
    Basic Agent 1 (Git Archeologist)    :done, w1c, 2026-03-03, 3d
    VS Code extension hello world       :done, w1d, 2026-03-05, 2d
    Pinecone setup + first embeddings   :done, w1e, 2026-03-05, 2d
    section Week 2 — Core AI
    All 5 agents implemented            :w2a, 2026-03-08, 4d
    LangGraph supervisor orchestration  :w2b, 2026-03-08, 4d
    Hybrid RAG pipeline operational     :w2c, 2026-03-10, 3d
    Pre-index React + VSCode repos      :w2d, 2026-03-12, 2d
    Basic Web Portal chat interface     :w2e, 2026-03-10, 4d
    section Week 3 — Features
    VS Code hover tooltip complete      :w3a, 2026-03-15, 3d
    Archaeology Trail visualization     :w3b, 2026-03-15, 4d
    Slack OAuth + integration           :w3c, 2026-03-16, 3d
    Story Richness Score UI             :w3d, 2026-03-17, 2d
    LangSmith observability             :w3e, 2026-03-18, 2d
    section Week 4 — Polish
    OWASP security hardening            :w4a, 2026-03-22, 2d
    Arabic mode + RTL UI                :w4b, 2026-03-22, 2d
    50+ golden story test dataset       :w4c, 2026-03-23, 2d
    RAGAS evaluation metrics            :w4d, 2026-03-24, 1d
    Demo video recording                :w4e, 2026-03-25, 1d
    Presentation deck                   :w4f, 2026-03-26, 2d
```

---

## Success Metrics & KPIs

### Technical KPIs

| Metric | Target | How We Measure |
|---|---|---|
| Story Generation Time (P95) | **< 5 seconds** | LangSmith latency traces |
| Story Generation Time (P50) | **< 3 seconds** | LangSmith latency traces |
| Agent Success Rate | **> 95%** | LangSmith error tracking |
| Cost per Story | **< $0.10** | LangSmith token cost attribution |
| Uptime During Evaluation | **99%+** | UptimeRobot monitoring |
| Test Coverage | **> 60%** | Jest + pytest coverage reports |

### AI Quality KPIs (RAGAS)

| Metric | Target | Description |
|---|---|---|
| Faithfulness | **> 90%** | Stories grounded in actual sources |
| Context Precision | **> 80%** | Retrieved chunks are relevant |
| Answer Relevancy | **> 85%** | Story answers "WHY" specifically |
| Citation Accuracy | **100%** | Every claim links to real source |

### User Experience KPIs

| Metric | Target |
|---|---|
| Thumbs Up Rate | **> 70%** |
| User Return Rate | **> 40% weekly** |
| Time Reading Story | **> 2 minutes** (engagement signal) |
| Integrations Connected per User | **> 2** (GitHub + Jira/Slack) |

---

## The 60-Second Wow Moment

### The Demo Script (Memorize This)

**Setup:** Web Portal is open. React repo is pre-indexed.

> *"Every developer has seen this moment. You open old code and find something like this:"*

```javascript
// DO NOT CHANGE THIS VALUE
const PAYMENT_RETRY_TIMEOUT = 847;
```

> *"847. Not 1000. Not 500. 847. Why? Every tool you know — GitLens, Copilot, CodeRabbit — they cannot answer this. I'm going to answer it in 5 seconds."*

[Types in Web Portal chat: *"Why is the payment retry timeout 847?"*]

[Story streams in real-time — 5 seconds]

> *"Here's what happened. In January 2023, there was a P0 incident — payments timing out under load. The team opened PR #892. There were 23 review comments. Sarah argued for going lower than 1000ms. Ahmed said that was too risky. They ran load tests. The p95 latency on the worst-case production day was 847ms. That number isn't magic — it's a measurement. And 3 months after the PR merged, Sarah wrote in Slack: 'The 847 is from our p95 latency on worst-case day. DON'T CHANGE IT.' That message was buried in a Slack channel. The original dev left 8 months ago. DevArcheology found it in 4.3 seconds."*

[Click "View Archaeology Trail" — the timeline renders]

> *"This is the biography of a decision. No other tool on earth shows you this."*

**Total time: 60 seconds. Total wow: maximum.**

---

## Interview Zitona 🫒

*The answers that win any defense room.*

---

**Q: What is DevArcheology AI in one sentence?**
> "DevArcheology is the first institutional memory system for software teams — it synthesizes Git, PRs, Jira, and Slack into a 5-second narrative that answers the question every developer asks but no tool answers: WHY was this code written this way?"

---

**Q: Who are your competitors?**
> "GitLens shows WHO and WHEN. CodeRabbit reviews code before it merges. Sourcegraph searches code structure. None of them answer WHY — and none of them work on code that already exists in production. We have no direct competitor."

---

**Q: What's the difference between you and CodeRabbit?**
> "CodeRabbit is born when a PR opens and dies when it merges. DevArcheology is born the day a new developer inherits code written 2 years ago by someone who left. Different tool, different moment, different user, different question."

---

**Q: How big is your market?**
> "The AI Code Tools market is $7.37 billion in 2025, growing to $23.97 billion by 2030 at 26.6% CAGR. We operate in the Developer Intelligence sub-segment, and our specific niche — institutional memory — has zero established players."

---

**Q: What happens on a repo with no history?**
> "Three things: One — we ship with 3 famous repos pre-indexed so you get a full demo experience on day one. Two — we show a Story Richness Score that honestly tells you what context we have and what's missing. Three — even with Git-only data, we generate a minimum viable story and use every missing source as a prompt to connect more integrations."

---

**Q: You need Slack admin permissions — how does that work?**
> "We use OAuth user tokens, not bot tokens. A user token carries exactly the same Slack access the developer already has. Zero admin approval. Zero IT department. A developer connects Slack in 30 seconds and we read every channel they can already see."

---

**Q: What's your business model?**
> "Freemium self-serve. 10 free stories/month to acquire users. $15/month for individual developers. $49/month for teams of 5. The ROI argument: a team of 5 senior devs saves 30 minutes per investigation, 3 investigations per day, at $50/hour fully loaded — that's $5,250 saved per month for $49. 107x ROI."

---

**Q: Why is your project better than [Education AI / Legal AI from your class]?**
> "Three reasons. One — we are the only project in this class with zero competitors in our specific category. Five teams submitted education AI. We own developer institutional memory alone. Two — our market is international. Any software team on GitHub anywhere in the world is our customer. Three — our demo is live and observable. We answer a specific question with a specific answer in 5 seconds. That's measurable, not theoretical."

---

**Q: What would you build next after the MVP?**
> "Three things in priority order. Developer DNA Profiles — behavioral patterns automatically extracted from commit history to accelerate onboarding and identify knowledge silos. Graph RAG — representing relationships between decisions as a knowledge graph, not just document chunks. And an Enterprise on-premise option for financial and healthcare companies who cannot send their code to external APIs."

---

*"The code always has a story. DevArcheology makes sure it's never lost."* 🏛️

---

> **Last Updated:** March 2026 | **Status:** Defense-Ready
> **Tags:** #capstone #DevArcheology #AI #LangGraph #RAG #MultiAgent #ITI
