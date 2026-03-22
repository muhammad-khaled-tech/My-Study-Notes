# 📸 SnapGrid — Graduation Project Plan
### Instagram-Style Social Platform | Junior Frontend Developer Roadmap
> Version control & GitHub management included | Progressive Angular + Tailwind learning

---

## 🧭 How to Use This Document

This is your **single source of truth** for the entire project. Treat it like a real junior developer would treat a project spec at a company:

- Read the **whole phase** before writing a single line of code
- Create the **GitHub branch** listed before starting
- Follow the **commit message format** — it trains a real habit
- The code blocks are **hints and pseudo-code only** — your job is to turn them into real Angular
- Mark each checkbox ✅ when done before moving to the next phase
- **Never skip a phase.** Each one is a prerequisite for the next.

---

## 🏢 The Brief (As If You're at a Company)

> **Project:** SnapGrid Social
> **Assigned to:** Junior Frontend Developer
> **Backend:** Provided as a REST API (you focus 100% on Angular)
> **Stack:** Angular 18+, Tailwind CSS, TypeScript
> **Timeline:** 12 phases over ~12 weeks
> **Repo:** `github.com/YOUR_USERNAME/snapgrid`

SnapGrid is an image-first social platform. Users can share photos, follow each other, like and comment on posts, and view ephemeral stories. The platform supports both English (LTR) and Arabic (RTL), has a dark mode, real-time notifications, infinite scroll, and is installable as a PWA.

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Framework | Angular 18+ (standalone) | The whole point |
| Styling | Tailwind CSS | Utility-first, dark mode, RTL baked in |
| Language | TypeScript | Strict mode — catch bugs early |
| State | Angular Signals | Modern, no Zone.js, simple |
| HTTP | Angular HttpClient | REST API integration |
| Animations | Angular Animations | Transitions, story viewer |
| Testing | Jasmine + TestBed | Unit tests per phase |
| Version Control | Git + GitHub | PRs, issues, branches |
| PWA | @angular/pwa | Service worker, installable |

---

## 🌿 Git & GitHub Workflow — Junior Developer Standard

This section is as important as the code. Every professional team works this way.

### Repository Setup

```bash
# 1. Create repo on GitHub (Public, with README, .gitignore: Node)
# 2. Clone it locally:
git clone https://github.com/YOUR_USERNAME/snapgrid.git
cd snapgrid

# 3. Create Angular project INSIDE the cloned folder:
ng new snapgrid-frontend --routing --style=css --standalone
# Move files up if nested, or work in the subfolder

# 4. Install Tailwind:
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

# 5. First commit:
git add .
git commit -m "chore: initial Angular + Tailwind project setup"
git push origin main
```

### Branch Strategy

You always work on a **feature branch** — never directly on `main`.

```
main          ← production-ready code only. Never commit here directly.
  └── develop ← integration branch. Merge features here first.
        └── feature/phase-01-auth       ← your current work
        └── feature/phase-02-shell
        └── feature/phase-03-feed
        └── ... and so on
```

```bash
# Before starting ANY phase:
git checkout develop
git pull origin develop
git checkout -b feature/phase-XX-name

# While working — commit often:
git add .
git commit -m "feat(auth): add login form with email/password validation"

# When done with the phase:
git push origin feature/phase-XX-name
# Then open a Pull Request on GitHub: feature/phase-XX → develop
```

### Commit Message Format

Every commit follows **Conventional Commits**. This is the industry standard.

```
type(scope): short description

Types:
  feat     → new feature
  fix      → bug fix
  style    → CSS/Tailwind changes only
  refactor → code change with no behavior change
  test     → adding or changing tests
  chore    → setup, config, dependencies
  docs     → README or comments

Examples:
  feat(feed): add post card component with like button
  fix(auth): prevent form submission when invalid
  style(profile): adjust avatar size on mobile
  refactor(services): extract api base url to environment
  test(auth): add login form validation tests
  chore: add @angular/pwa
```

### GitHub Issues

Before starting each phase, create a GitHub Issue:

```
Title: [Phase 03] Feed Page & Post Card Component
Labels: enhancement, in-progress
Description:
  ## What
  Build the home feed page and the reusable PostCard component.

  ## Acceptance Criteria
  - [ ] Feed page loads and displays a list of PostCard components
  - [ ] PostCard receives a post @Input() and renders image, caption, username
  - [ ] PostCard has a like button that toggles state visually
  - [ ] Page works on mobile and desktop

  ## Concepts introduced
  - @Input() / @Output()
  - Signal for like state
  - Tailwind responsive classes
```

### Pull Request Template

When you open a PR, describe what you did:

```
## Summary
Built the PostCard component and wired it to the FeedPage.

## Changes
- Added `post-card/` component with @Input() post
- Added `feed/` page that renders a list of PostCard
- Introduced signal for local like toggle state
- Added skeleton loading state

## Screenshots
[paste a screenshot of the feature]

## Self-review checklist
- [ ] No TypeScript errors (ng build passes)
- [ ] Works on mobile (tested at 375px)
- [ ] Commit messages follow the format
- [ ] I've read my own diff and it makes sense
```

---

## 🏗️ Company-Grade Project Setup

### The `.github/` Folder — Automate Your Workflow

Real companies use GitHub templates so every Issue and PR looks the same. Create these files in your repo root during Phase 0.

```
.github/
├── ISSUE_TEMPLATE/
│   ├── feature.md       ← template for new feature issues
│   └── bug.md           ← template for bug reports
├── PULL_REQUEST_TEMPLATE.md
└── workflows/
    └── ci.yml           ← runs tests + build on every push
```

**`.github/ISSUE_TEMPLATE/feature.md`** — copy this exactly:

```markdown
---
name: Feature
about: A new feature or phase task
labels: enhancement
---

## 📋 What
<!-- One sentence: what are you building? -->

## ✅ Acceptance Criteria
<!-- The definition of done — every checkbox must pass before merging -->
- [ ]
- [ ]
- [ ]

## 🧠 Angular Concepts Introduced
<!-- List the new concepts this phase teaches -->

## 🔗 Related Phase
<!-- e.g. Phase 03 — Feed Page -->
```

**`.github/PULL_REQUEST_TEMPLATE.md`** — copy this exactly:

```markdown
## Summary
<!-- What did you build? One paragraph. -->

## Changes
<!-- Bullet list of what files/components changed and why -->
-
-

## Screenshots
<!-- Paste a screenshot of the feature on mobile AND desktop -->
| Mobile | Desktop |
|--------|---------|
| img    | img     |

## Self-review Checklist
- [ ] `ng build --configuration=production` passes with no errors
- [ ] No TypeScript errors (`npx tsc --noEmit`)
- [ ] Works on mobile (tested at 375px width in DevTools)
- [ ] Dark mode looks correct
- [ ] RTL mode looks correct (if UI was changed)
- [ ] Commit messages follow Conventional Commits format
- [ ] I've read my own diff line by line and it makes sense
- [ ] The acceptance criteria in the Issue are all checked
```

**`.github/workflows/ci.yml`** — your first CI pipeline:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [develop]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npx tsc --noEmit

      - name: Build production
        run: npx ng build --configuration=production

      - name: Run tests
        run: npx ng test --watch=false --browsers=ChromeHeadless
```

What this does: every time you push or open a PR, GitHub automatically runs your type check, build, and tests. If any fail, the PR shows a red ✗ — you fix it before merging. This is how every professional Angular team works.

---

### 📅 Sprint Calendar — 12-Week Plan

Work in 2-week sprints. Each sprint has a goal and a mini-review at the end.

| Sprint | Weeks | Phases | Sprint Goal |
|--------|-------|--------|-------------|
| 1 | 1–2 | 0, 1, 2 | App runs, auth works, shell navigates |
| 2 | 3–4 | 3, 3.5 | Feed shows posts, create post works |
| 3 | 5–6 | 4, 5 | Profiles load, post detail with comments |
| 4 | 7–8 | 6, 6.5 | Real API wired, error boundary in place |
| 5 | 9–10 | 7, 8 | Stories work, dark mode + RTL complete |
| 6 | 11–12 | 9, 10, 11, 12 | Skeletons, infinite scroll, notifications, PWA |
| 7 | 13–14 | 13, 14, 15 | Explore search, edit profile, test retrospective |

**Sprint Review ritual** — at the end of each sprint, write 3 sentences in your journal or README:
1. What I built
2. What was harder than expected and why
3. What concept I feel most confident about now

This mirrors agile retrospectives at real companies and forces reflection that accelerates learning.

---

### 📝 CHANGELOG.md — The Professional Documentation Habit

After every phase is merged to `develop`, open `CHANGELOG.md` and add an entry. Follow [Keep a Changelog](https://keepachangelog.com) format.

```markdown
# Changelog

## [Unreleased]

## [0.3.0] — Phase 3 Complete — YYYY-MM-DD
### Added
- PostCard component with @Input() post and like/save toggle
- FeedPage with mock data and skeleton loading states
- TimeAgo pipe (English + Arabic)
- OnPush change detection on PostCard

### Learned
- @Input() and @Output() for component communication
- Optimistic UI: update signal first, revert on API error
- Tailwind aspect-ratio and object-cover for image cards

## [0.2.0] — Phase 2 Complete — YYYY-MM-DD
### Added
- App shell with persistent sidebar and bottom navigation
- Lazy-loaded routes for all main pages
- Responsive layout: sidebar on desktop, bottom nav on mobile
- routerLinkActive for active nav highlighting
```

The "Learned" section is non-standard but the most valuable part for you — it becomes a personal learning diary embedded in the repo.

---

### 🔌 Mock API Contract — Build Frontend Without a Backend

You need a defined API contract to write your services confidently. Use this spec. If your backend isn't ready, use [json-server](https://github.com/typicode/json-server) or [MSW (Mock Service Worker)](https://mswjs.io) to simulate these endpoints locally.

**Base URL:** `http://localhost:3000/api`

**Standard response shape:**
```typescript
// Every endpoint returns this wrapper:
interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string      // present on errors
  total?: number        // present on paginated lists
  page?: number
  limit?: number
}
```

**Auth endpoints:**

| Method | Endpoint | Body | Returns |
|--------|----------|------|---------|
| POST | `/auth/register` | `{ email, password, username }` | `ApiResponse<{ token: string }>` |
| POST | `/auth/login` | `{ email, password }` | `ApiResponse<{ token: string }>` |
| GET | `/auth/me` | — | `ApiResponse<User>` |

**Post endpoints:**

| Method | Endpoint | Body / Params | Returns |
|--------|----------|------|---------|
| GET | `/posts/feed` | `?page=1&limit=10` | `ApiResponse<Post[]>` |
| GET | `/posts/:id` | — | `ApiResponse<Post>` |
| POST | `/posts` | `FormData: { image, caption, location? }` | `ApiResponse<Post>` |
| DELETE | `/posts/:id` | — | `ApiResponse<null>` |
| POST | `/posts/:id/like` | — | `ApiResponse<{ isLiked: boolean; likesCount: number }>` |
| POST | `/posts/:id/save` | — | `ApiResponse<{ isSaved: boolean }>` |
| GET | `/posts/:id/comments` | `?page=1&limit=20` | `ApiResponse<Comment[]>` |
| POST | `/posts/:id/comments` | `{ text }` | `ApiResponse<Comment>` |

**User endpoints:**

| Method | Endpoint | Body | Returns |
|--------|----------|------|---------|
| GET | `/users/:username` | — | `ApiResponse<User>` |
| GET | `/users/:username/posts` | `?page=1&limit=12` | `ApiResponse<Post[]>` |
| PATCH | `/users/me` | `{ bio?, website?, firstName?, lastName? }` | `ApiResponse<User>` |
| POST | `/users/me/avatar` | `FormData: { avatar }` | `ApiResponse<{ avatarUrl: string }>` |
| POST | `/users/:username/follow` | — | `ApiResponse<{ isFollowing: boolean; followersCount: number }>` |
| GET | `/users/search` | `?q=query&limit=10` | `ApiResponse<User[]>` |
| GET | `/users/suggestions` | `?limit=5` | `ApiResponse<User[]>` |

**Story endpoints:**

| Method | Endpoint | Returns |
|--------|----------|---------|
| GET | `/stories/feed` | `ApiResponse<Story[]>` — stories from followed users |
| POST | `/stories` | `ApiResponse<Story>` |
| DELETE | `/stories/:id` | `ApiResponse<null>` |

**Notification endpoints:**

| Method | Endpoint | Returns |
|--------|----------|---------|
| GET | `/notifications` | `ApiResponse<Notification[]>` |
| GET | `/notifications/unread-count` | `ApiResponse<{ count: number }>` |
| PATCH | `/notifications/read-all` | `ApiResponse<null>` |

**Explore endpoints:**

| Method | Endpoint | Returns |
|--------|----------|---------|
| GET | `/explore/posts` | `ApiResponse<Post[]>` — trending posts |
| GET | `/explore/search` | `?q=query&type=posts\|users` → `ApiResponse<Post[] \| User[]>` |
| GET | `/explore/hashtags/trending` | `ApiResponse<Hashtag[]>` |

**Error response format:**
```typescript
// All 4xx/5xx errors follow this shape:
{
  success: false,
  message: "Human readable error",
  field?: "email"   // present for validation errors — which field failed
}
```

**Setting up json-server for instant mock API:**
```bash
npm install -g json-server
# Create db.json with sample data, then:
json-server --watch db.json --port 3000
# All REST endpoints work instantly — GET, POST, PUT, DELETE
```

---

## 📁 Project Folder Structure

Set this up in **Phase 0** and respect it forever. Structure reflects how professional Angular apps are organized.

```
snapgrid-frontend/
├── src/
│   ├── app/
│   │   ├── core/                        ← singleton services, guards, interceptors
│   │   │   ├── services/
│   │   │   │   ├── auth.service.ts
│   │   │   │   ├── post.service.ts
│   │   │   │   ├── user.service.ts
│   │   │   │   ├── notification.service.ts
│   │   │   │   ├── theme.service.ts
│   │   │   │   └── direction.service.ts
│   │   │   ├── guards/
│   │   │   │   ├── auth.guard.ts
│   │   │   │   └── guest.guard.ts       ← redirect logged-in users away from login
│   │   │   ├── interceptors/
│   │   │   │   ├── token.interceptor.ts
│   │   │   │   └── error.interceptor.ts
│   │   │   └── models/
│   │   │       ├── post.model.ts
│   │   │       ├── user.model.ts
│   │   │       ├── story.model.ts
│   │   │       ├── comment.model.ts
│   │   │       └── notification.model.ts
│   │   │
│   │   ├── shared/                      ← reusable components used everywhere
│   │   │   ├── components/
│   │   │   │   ├── avatar/
│   │   │   │   ├── button/
│   │   │   │   ├── skeleton/
│   │   │   │   ├── modal/
│   │   │   │   └── spinner/
│   │   │   ├── directives/
│   │   │   │   ├── infinite-scroll.directive.ts
│   │   │   │   └── long-press.directive.ts
│   │   │   ├── pipes/
│   │   │   │   ├── time-ago.pipe.ts
│   │   │   │   └── short-number.pipe.ts
│   │   │   └── animations/
│   │   │       └── animations.ts
│   │   │
│   │   ├── layout/                      ← app shell, navbar, sidebar, bottom nav
│   │   │   ├── navbar/
│   │   │   ├── sidebar/
│   │   │   ├── bottom-nav/
│   │   │   └── app-shell/
│   │   │
│   │   ├── features/                    ← one folder per major feature/page
│   │   │   ├── auth/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── feed/
│   │   │   ├── explore/
│   │   │   ├── post/
│   │   │   │   ├── post-card/
│   │   │   │   ├── post-detail/
│   │   │   │   └── create-post/
│   │   │   ├── profile/
│   │   │   ├── stories/
│   │   │   │   ├── story-bar/
│   │   │   │   └── story-viewer/
│   │   │   └── notifications/
│   │   │
│   │   ├── app.routes.ts
│   │   ├── app.config.ts
│   │   └── app.ts
│   │
│   ├── environments/
│   │   ├── environment.ts               ← dev: localhost:3000
│   │   └── environment.production.ts   ← prod: real API URL
│   │
│   └── styles.css                       ← Tailwind base imports + CSS variables
│
├── tailwind.config.js
├── angular.json
└── README.md
```

---

## 🎨 Design Tokens — Set Up Once, Used Everywhere

Before writing any components, define your design system in `tailwind.config.js` and `styles.css`.

```javascript
// tailwind.config.js — hint (fill in the actual values yourself)
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  darkMode: 'class',   // 'class' strategy: add/remove 'dark' class on <html>
  theme: {
    extend: {
      colors: {
        // Define your brand colors here — used as Tailwind classes throughout
        primary: {
          // hint: Instagram uses a gradient, but for a solid color pick a purple/pink
          DEFAULT: '???',
          dark: '???',
        },
        surface: {
          // hint: card backgrounds — white in light, dark gray in dark mode
          light: '???',
          dark: '???',
        }
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        arabic: ['Cairo', 'sans-serif'],   // for RTL/Arabic content
      },
    },
  },
  plugins: [],
}
```

```css
/* styles.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* CSS custom properties for things Tailwind can't do alone: */
:root {
  /* hint: define spacing, border-radius tokens */
  --story-ring: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888);
  /* ^ the Instagram gradient ring on stories */
}

/* RTL support — when [dir="rtl"] is on <html>: */
[dir="rtl"] {
  /* hint: some layout things need to flip for Arabic */
}
```

---

---

---

## 📚 Topics to Study or Review Before Phase 0

### Git & GitHub
- What is version control and why it exists
- `git init`, `git add`, `git commit`, `git push`, `git pull`
- What a branch is — why we never commit directly to `main`
- `git checkout -b branch-name` — creating and switching branches
- `git merge` vs opening a Pull Request — when to use each
- What `.gitignore` does — why `node_modules/` must always be in it
- 📖 Resource: [Git — the simple guide](https://rogerdudler.github.io/git-guide/) (15 min read)
- 📖 Resource: [GitHub Hello World guide](https://docs.github.com/en/get-started/quickstart/hello-world)

### Angular CLI
- What `ng new` generates and what each file does
- `ng serve` vs `ng build` — development vs production
- `ng generate component` / `ng generate service` — what files get created
- What `--standalone` does and why we always use it
- What `--strict` does — TypeScript strict mode catches bugs at compile time
- 📖 Resource: Angular tutorial Part 1 (your guide) — "Project structure" section

### Tailwind CSS — First Exposure
- What utility-first CSS means vs writing your own CSS classes
- How to install Tailwind in an Angular project (official docs)
- The `tailwind.config.js` file — `content`, `theme`, `plugins`
- `@tailwind base; @tailwind components; @tailwind utilities;` in styles.css
- 📖 Resource: [Tailwind CSS — Core Concepts](https://tailwindcss.com/docs/utility-first) (20 min)

### Terminal Basics (if rusty)
- Navigating: `cd`, `ls` / `dir`, `mkdir`, `touch`
- Running npm scripts: `npm install`, `npm run start`

---

# PHASE 0 — Project Setup & GitHub Init
### ⏱ Time estimate: 2–3 hours | 🧠 Concepts: Angular CLI, Tailwind, Git workflow

## What you'll do
- Create the Angular project and configure Tailwind
- Set up the folder structure
- Initialize GitHub with the branching strategy
- Write the README

## Steps

```bash
# Create project:
ng new snapgrid-frontend --routing --style=css --standalone --strict
# --strict: enables strict TypeScript — catches more bugs at compile time

# Install and configure Tailwind (follow official Angular+Tailwind guide)
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init

# Install Google Fonts in index.html (Inter + Cairo)

# Create the folder structure manually (mkdir in terminal)
# Every folder in the structure above should exist from day 1
```

## GitHub Tasks

```
Branch: no branch needed — commit directly to main this phase only
Issue: [Phase 0] Project Setup
Commit: chore: initialize Angular + Tailwind + folder structure
```

## Definition of Done
- [ ] `ng serve` runs with no errors
- [ ] Tailwind classes work (test with a `class="text-red-500"` somewhere then remove)
- [ ] All folders from the structure above exist (even if empty)
- [ ] `README.md` has: project name, tech stack, how to run it locally
- [ ] Pushed to `main` on GitHub — repo is public

---

---

---

## 📚 Topics to Study or Review Before Phase 1

### Tailwind CSS — Core Utilities (your main focus this phase)
- Spacing: `p-4`, `px-4`, `py-2`, `m-4`, `mx-auto`, `gap-3` — learn the scale (1=4px, 4=16px, 8=32px)
- Sizing: `w-full`, `w-64`, `h-screen`, `min-h-screen`, `max-w-sm`
- Layout: `flex`, `flex-col`, `items-center`, `justify-center`, `justify-between`
- Typography: `text-sm`, `text-lg`, `font-semibold`, `font-bold`, `text-gray-500`
- Colors: `bg-white`, `bg-gray-50`, `text-gray-900`, `border-gray-300`
- Borders & Radius: `border`, `border-2`, `rounded`, `rounded-lg`, `rounded-full`
- Shadows: `shadow`, `shadow-md`, `shadow-xl`
- States: `hover:bg-gray-100`, `focus:outline-none`, `focus:ring-2`, `disabled:opacity-50`
- 📖 Resource: [Tailwind — Flexbox](https://tailwindcss.com/docs/flex), [Spacing](https://tailwindcss.com/docs/padding), [Colors](https://tailwindcss.com/docs/customizing-colors)
- 🎮 Practice: [Tailwind Play](https://play.tailwindcss.com) — try building a card component

### Dark Mode with Tailwind
- The `darkMode: 'class'` strategy — what it means and how it works
- Writing `dark:` variants: `dark:bg-gray-900`, `dark:text-white`
- How adding/removing the `dark` class on `<html>` switches the theme
- 📖 Resource: [Tailwind — Dark Mode docs](https://tailwindcss.com/docs/dark-mode)

### Reactive Forms (review from bookstore)
- `FormGroup`, `FormControl`, `FormBuilder`
- `Validators.required`, `Validators.email`, `Validators.minLength`
- `[formGroup]`, `formControlName` in the template
- How to check `control.touched && control.invalid` for showing errors
- 📖 Resource: Angular tutorial Part 3 (your guide) — Reactive Forms chapter

### Angular Signals (review)
- `signal(initialValue)` — creating a signal
- `signal.set(value)` — replacing the value
- `signal.update(fn)` — updating based on previous value
- Reading a signal in a template: `{{ mySignal() }}`
- Why signals are better than plain properties for loading/error state
- 📖 Resource: Angular tutorial Part 4 (your guide) — Angular Signals chapter

### Angular Guards
- What `CanActivateFn` is and how to write a functional guard
- `inject()` inside a guard
- Returning `true` (allow), `false` (block), or `router.createUrlTree(['/path'])` (redirect)
- 📖 Resource: Angular tutorial Part 2 (your guide) — Guards section

---

# PHASE 1 — Authentication Pages
### ⏱ Time estimate: 4–6 hours | 🧠 New concept: Tailwind CSS utility-first styling

## What you'll build
- `/auth/login` — email + password form
- `/auth/register` — email + password + username form
- A guest guard that redirects logged-in users away from these pages

## New concept this phase: Tailwind CSS

You already know Reactive Forms from the bookstore. The new thing here is **styling with Tailwind**. No CSS files — only utility classes in the HTML.

```
BEFORE (Bootstrap):
  <input class="form-control" />

AFTER (Tailwind):
  <input class="w-full rounded-lg border border-gray-300 px-4 py-2
                focus:outline-none focus:ring-2 focus:ring-primary
                dark:bg-gray-800 dark:border-gray-600 dark:text-white" />
```

The pattern to learn: **group related utilities together mentally:**
```
Layout:   w-full, h-screen, flex, items-center, justify-center
Spacing:  px-4, py-2, gap-3, mb-6, mt-4
Visual:   bg-white, rounded-xl, border, shadow-md
Text:     text-sm, font-semibold, text-gray-500
State:    hover:bg-primary-dark, focus:ring-2, disabled:opacity-50
Dark:     dark:bg-gray-900, dark:text-white, dark:border-gray-700
```

## Pseudo-code hints

```typescript
// login.ts — structure only, you write the real code
export class Login {
  // hint: same reactive form pattern as the bookstore login
  // email: required, must be email format
  // password: required, minLength 8

  // hint: on success, store token (same as bookstore)
  // hint: navigate to /feed after login

  // NEW: use signal() for loading and serverError (not plain boolean)
  loading = signal(???)
  serverError = signal(???)
}
```

```html
<!-- login.html — design hint -->
<!-- 
  Layout: full-screen centered card (like Instagram login page)
  - Logo / app name at top
  - White card, rounded, shadow
  - Input fields with Tailwind classes
  - "Don't have an account? Sign up" link at bottom
  - All of this should work in dark mode too
-->
<div class="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
  <div class="w-full max-w-sm ...">
    <!-- hint: logo here -->
    <!-- hint: form here -->
    <!-- hint: link to register here -->
  </div>
</div>
```

```typescript
// guest.guard.ts — new guard you haven't built before
// Logic: if the user IS logged in, redirect them to /feed
// (opposite of authGuard which redirects when NOT logged in)
export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthService)
  // hint: if auth.isLoggedIn() → return router.createUrlTree(['/feed'])
  // hint: otherwise → return true (let them see the login page)
}
```

## 👨‍💻 Senior Dev Code Review — Phase 1

> This is what a real PR review comment thread would look like. Read it BEFORE you write code — it changes how you think about what you're building.

**Comment on `login.ts`:**
> ⚠️ `loading` and `serverError` are plain `boolean` and `string` properties. We use signals everywhere in this project — please convert to `loading = signal(false)` and `serverError = signal('')`. Consistency matters more than you think when the codebase grows.

**Comment on `login.html`:**
> 🔴 The submit button is `[disabled]="loginForm.invalid"` but it's not also disabled when loading. A slow network lets the user click twice and send two login requests. Fix: `[disabled]="loginForm.invalid || loading()"`.

**Comment on `register.ts`:**
> 💬 Good cross-field validator for password confirm — exactly the right approach. One thing: extract it to `shared/validators/passwords-match.validator.ts` so Profile and any future password-change form can reuse it without copy-pasting.

**Comment on `guest.guard.ts`:**
> ✅ Logic is correct. Small thing: the redirect goes to `['/feed']` hardcoded. Consider a `APP_ROUTES` constant file with all route strings — then if `/feed` ever becomes `/home`, you change one file not ten.

## GitHub Tasks
```

Issue:  [Phase 1] Authentication Pages
Commits (spread across your work):
  feat(auth): add login page with reactive form
  feat(auth): add register page with username field
  feat(auth): add guest guard for auth routes
  style(auth): polish login/register with Tailwind
PR: feature/phase-01-auth → develop
## Definition of Done
- [ ] `/auth/login` and `/auth/register` routes work
- [ ] Forms validate correctly — show errors when touched
- [ ] Loading spinner shown while request is in flight
- [ ] Server error displayed below the form
- [ ] Logged-in user visiting `/auth/login` is redirected to `/feed`
- [ ] Pages look good on mobile (375px) AND desktop
- [ ] Dark mode manually works (add `dark` class to `<html>` and check)
```
---

---

---

## 📚 Topics to Study or Review Before Phase 2

### Angular Router — Core Concepts
- What `app.routes.ts` is and how routes are defined
- `path`, `component`, `redirectTo`, `pathMatch: 'full'`
- `loadComponent` — lazy loading a standalone component
- `children` — nested routes inside a parent component
- `<router-outlet>` — where child routes render inside the parent template
- `routerLink` directive — navigating in the template (vs `href` which reloads the page)
- `routerLinkActive` — adding a CSS class to the active link
- 📖 Resource: Angular tutorial Part 4 (your guide) — Routing Deep Dive chapter

### Lazy Loading
- What lazy loading means: the component's JavaScript is only downloaded when the route is visited
- `loadComponent: () => import('./path').then(c => c.ClassName)` — the exact syntax
- Why lazy loading improves first page load speed
- 📖 Resource: Angular tutorial Part 7 (your guide) — Lazy Loading section

### Angular Router — Programmatic Navigation
- `inject(Router)` in a component/guard
- `router.navigate(['/feed'])` — navigate from TypeScript
- `router.createUrlTree(['/path'])` — used in guards to redirect
- 📖 Resource: Angular tutorial Part 4 — Navigation extras section

### Tailwind — Responsive Design
- The mobile-first approach: styles without a prefix apply to all sizes
- Breakpoint prefixes: `sm:` (640px), `md:` (768px), `lg:` (1024px), `xl:` (1280px)
- `hidden` vs `block` vs `flex` — controlling display
- `hidden lg:flex` — hidden on mobile, flex on desktop
- `flex lg:hidden` — flex on mobile, hidden on desktop
- 📖 Resource: [Tailwind — Responsive Design](https://tailwindcss.com/docs/responsive-design)

### Angular App Architecture
- What a "shell" or "layout" component is — a wrapper that persists across routes
- How `<router-outlet>` inside the shell renders child routes
- Why we separate `authGuard` (protect private routes) from `guestGuard` (redirect logged-in users)
- 📖 Resource: Angular tutorial Part 2 (your guide) — Route structure section

---

# PHASE 2 — App Shell & Navigation
### ⏱ Time estimate: 5–7 hours | 🧠 New concept: Layout components + Responsive design

## What you'll build
- A persistent app shell (the layout that wraps all authenticated pages)
- Top navbar (desktop): logo, search, nav icons, avatar
- Left sidebar (desktop): nav links, new post button
- Bottom navigation bar (mobile): icons for feed, explore, add, notifications, profile
- Lazy-loaded routes for all main sections

## New concept this phase: Responsive layout with Tailwind

Tailwind's responsive prefixes: `sm:`, `md:`, `lg:`, `xl:`

```html
<!-- Element is hidden on mobile, visible on desktop: -->
<div class="hidden lg:flex">...</div>

<!-- Element visible on mobile, hidden on desktop: -->
<div class="flex lg:hidden">...</div>

<!-- Different padding depending on screen size: -->
<div class="px-4 md:px-8 lg:px-16">...</div>
```

The Instagram mobile-first layout:

```
Mobile (< lg):           Desktop (>= lg):
┌─────────────────┐      ┌────┬──────────────┬──────┐
│  [Navbar top]   │      │    │              │      │
├─────────────────┤      │Side│    Feed      │      │
│                 │      │bar │    Content   │Sugges│
│   Feed Content  │      │    │              │tions │
│                 │      │    │              │      │
├─────────────────┤      └────┴──────────────┴──────┘
│ [Bottom nav]    │
└─────────────────┘
```

## Pseudo-code hints

```typescript
// app.routes.ts — lazy loaded routes structure
export const routes: Routes = [
  {
    path: 'auth',
    // hint: loadChildren or individual loadComponent for login/register
    // hint: canActivate: [guestGuard]
  },
  {
    path: '',
    component: AppShell,  // the persistent layout wrapper
    canActivate: [authGuard],
    children: [
      { path: 'feed',          loadComponent: () => import(...) },
      { path: 'explore',       loadComponent: () => import(...) },
      { path: 'notifications', loadComponent: () => import(...) },
      { path: 'profile/:username', loadComponent: () => import(...) },
      { path: 'post/:id',      loadComponent: () => import(...) },
      { path: '',              redirectTo: 'feed', pathMatch: 'full' },
    ]
  },
  { path: '**', redirectTo: '/auth/login' }
]
```

```typescript
// app-shell.ts — the layout wrapper
// hint: this component has NO logic — it's just a layout template
// Its template contains: <app-sidebar>, <app-navbar>, <router-outlet>, <app-bottom-nav>
@Component({
  template: `
    <div class="flex h-screen">
      <!-- sidebar: hidden on mobile, visible on lg+ -->
      <!-- main content area: flex-1, overflow-y-auto -->
      <!-- <router-outlet> goes here — child routes render inside -->
    </div>
    <!-- bottom nav: visible on mobile, hidden on lg+ -->
  `
})
```

```typescript
// navbar.ts — hint: what data does the navbar need?
// - current user avatar + username (from AuthService)
// - unread notifications count (later in phase 11, for now: hardcode 0)
// - routerLink and routerLinkActive for nav items
```

## 👨‍💻 Senior Dev Code Review — Phase 2

**Comment on `app.routes.ts`:**
> ⚠️ You have `{ path: '', redirectTo: '/feed', pathMatch: 'full' }` at the end of the children array — good. But I see the catch-all `{ path: '**' }` is inside the authenticated shell. Move it OUTSIDE the shell so unauthenticated users who hit a bad URL also get redirected, not stuck on a blank shell page.

**Comment on `app-shell.ts`:**
> 💬 The shell component has `ngOnInit` that subscribes to `authService.authStatus$`. Why? The shell is only reachable when `authGuard` passes — the user IS authenticated at this point. Remove it. The shell should have zero logic. It's a layout wrapper, not a smart component.

**Comment on `sidebar.ts`:**
> 🔴 You're calling `inject(AuthService).getCurrentUser()` directly in the template via a method: `{{ getUsername() }}`. Methods in templates run on every change detection cycle. Store the result in a signal: `currentUser = toSignal(this.auth.user$)` and use `{{ currentUser()?.username }}` in the template.

**Comment on `bottom-nav.html`:**
> ✅ `routerLinkActive="..."` is used correctly. Nice. One improvement: add `[routerLinkActiveOptions]="{ exact: true }"` to the home/feed link — otherwise `/feed` AND `/feed/something` would both highlight the home icon.

## GitHub Tasks
Commits:
  feat(layout): add app shell with sidebar and bottom nav
  feat(layout): add responsive navbar with user avatar
  feat(routing): configure lazy-loaded routes for all pages
  style(layout): mobile-first responsive layout adjustments
PR: feature/phase-02-shell → develop

## Definition of Done
- [ ] Navigating to `/` when logged in shows the shell with sidebar
- [ ] All route links work (even if pages are empty components for now)
- [ ] Sidebar hides on mobile, bottom nav shows instead
- [ ] Active route is highlighted in nav (routerLinkActive)
- [ ] Logo in navbar/sidebar links back to `/feed`

---

---

---

## 📚 Topics to Study or Review Before Phase 3

### @Input() and @Output() — The Core of Component Communication
- What a "presentational" (dumb) component is vs a "smart" (container) component
- `@Input()` — passing data FROM parent TO child
- `@Input({ required: true })` — making an input mandatory (Angular 16+)
- `@Output()` and `EventEmitter` — sending events FROM child TO parent
- `(eventName)="handler($event)"` — listening to an output in the template
- Why the parent owns the data and the child only displays it
- 📖 Resource: Angular tutorial Part 4 (your guide) — Component Communication chapter

### ChangeDetectionStrategy.OnPush
- What change detection is — Angular checking if the template needs to re-render
- Why `Default` strategy is inefficient for lists (re-checks every component on every event)
- What `OnPush` means — only re-render when `@Input()` reference changes or an event comes from this component
- The immutability rule: with OnPush, you must create new object references (not mutate)
- 📖 Resource: Angular tutorial Part 7 (your guide) — OnPush section

### Angular Signals (deeper)
- `computed()` — a signal derived from other signals, auto-updates
- `effect()` — runs a side effect when a signal changes
- `signal.update(prev => newValue)` — updating based on current value
- 📖 Resource: Angular tutorial Part 4 (your guide) — Signals chapter

### TypeScript Interfaces
- Defining an `interface` for your data models: `interface Post { id: string; title: string }`
- Optional properties: `location?: string`
- Nested interfaces: `author: { username: string; avatarUrl: string }`
- Why interfaces help — TypeScript tells you when you use the wrong shape
- 📖 Resource: [TypeScript Handbook — Interfaces](https://www.typescriptlang.org/docs/handbook/2/objects.html)

### Custom Pipes
- What a pipe is: `{{ value | pipeName }}` — transforms a value in the template
- `@Pipe({ name: 'myPipe', standalone: true })` — declaring a standalone pipe
- Implementing `PipeTransform` and writing the `transform(value, ...args)` method
- Pure vs impure pipes — pure only re-runs when input reference changes
- 📖 Resource: Angular tutorial Part 7 (your guide) — Pure Pipes section

### Tailwind — Aspect Ratio and Object Fit
- `aspect-square` — forces a 1:1 ratio (perfect square)
- `aspect-[4/5]` — custom ratio (Instagram portrait post ratio)
- `object-cover` — image fills container, crops instead of distorting
- `object-center` — crops from the center
- `overflow-hidden` — clips the image to the container's border radius
- 📖 Resource: [Tailwind — Aspect Ratio](https://tailwindcss.com/docs/aspect-ratio)

---

# PHASE 3 — Feed Page & PostCard Component
### ⏱ Time estimate: 6–8 hours | 🧠 New concept: @Input/@Output + Component composition

## What you'll build
- The home feed page with a list of posts
- A reusable `PostCard` component that receives one post and displays it
- Static mock data to start (real API in Phase 6)
- Like toggle (client-side only — no API call yet)

## New concept this phase: @Input/@Output

The PostCard is a **dumb/presentational component** — it only knows what you tell it via `@Input()`. It does NOT fetch its own data. The Feed page fetches the data and passes it down.

```
FeedPage (smart — fetches data, owns state)
  └── PostCard (dumb — displays what it receives, emits events up)
  └── PostCard
  └── PostCard
```

```typescript
// post.model.ts — design your data shape first
export interface Post {
  id: string
  author: {
    username: string
    avatarUrl: string
    isVerified: boolean
  }
  imageUrl: string
  caption: string
  likesCount: number
  commentsCount: number
  isLiked: boolean         // has the current user liked this?
  isSaved: boolean         // has the current user saved this?
  createdAt: string        // ISO date string
  location?: string        // optional
}
```

## Pseudo-code hints

```typescript
// post-card.ts — the presentational component
export class PostCard {
  @Input({ required: true }) post!: Post
  // hint: add OnPush change detection — PostCard is purely @Input driven

  // hint: local signal for like state (optimistic UI)
  isLiked = signal(false)
  likesCount = signal(0)

  // hint: ngOnInit — sync the signals with the @Input values
  ngOnInit() {
    this.isLiked.set(this.post.isLiked)
    this.likesCount.set(this.post.likesCount)
  }

  @Output() likeToggled = new EventEmitter<{ postId: string; liked: boolean }>()
  @Output() commentClicked = new EventEmitter<string>()  // emits postId
  @Output() saveToggled = new EventEmitter<string>()

  toggleLike() {
    // hint: flip the signal value
    // hint: update count optimistically (±1)
    // hint: emit likeToggled up to the parent
    // the parent (FeedPage) will call the real API
  }
}
```

```html
<!-- post-card.html — structure hint -->
<!--
  ┌────────────────────────────────┐
  │ [avatar] username  [•••]       │ ← header
  │ [location if any]              │
  ├────────────────────────────────┤
  │                                │
  │         [POST IMAGE]           │ ← image (aspect-ratio: square or 4:5)
  │                                │
  ├────────────────────────────────┤
  │ ♡ 💬 ↗   [bookmark]           │ ← action row
  │ 1,234 likes                    │
  │ username caption text here...  │
  │ View all 12 comments           │
  │ 2 hours ago                    │ ← use the TimeAgo pipe you'll write
  └────────────────────────────────┘
-->
```

```typescript
// time-ago.pipe.ts — hint: write this pipe in shared/pipes/
// Input: ISO date string like "2024-11-01T10:30:00Z"
// Output: "2 hours ago", "3 days ago", "just now"
// Hint: use Date.now() - new Date(value).getTime() to get milliseconds
// Then convert to seconds, minutes, hours, days
@Pipe({ name: 'timeAgo', standalone: true })
export class TimeAgoPipe implements PipeTransform {
  transform(value: string): string {
    // hint: calculate difference between now and value
    // hint: return human-readable string
    // extra hint: Arabic support — return Arabic text when direction is RTL
  }
}
```

```typescript
// feed.ts — the smart page component
export class Feed implements OnInit {
  private postService = inject(PostService)

  posts = signal<Post[]>([])
  loading = signal(true)

  // MOCK DATA — use this before real API is ready
  private mockPosts: Post[] = [
    {
      id: '1',
      author: { username: 'khaled.dev', avatarUrl: '...', isVerified: false },
      imageUrl: 'https://picsum.photos/600/600?random=1',  // placeholder images
      caption: 'My first post on SnapGrid 🎉',
      likesCount: 142,
      commentsCount: 8,
      isLiked: false,
      isSaved: false,
      createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()  // 2 hours ago
    },
    // add 3-4 more mock posts
  ]

  ngOnInit() {
    // hint: simulate a loading delay with setTimeout (500ms)
    // then set posts.set(this.mockPosts) and loading.set(false)
  }

  handleLikeToggled(event: { postId: string; liked: boolean }) {
    // hint: later this will call postService.toggleLike()
    // for now, just console.log the event
    console.log('Like toggled:', event)
  }
}
```

## 👨‍💻 Senior Dev Code Review — Phase 3

**Comment on `post-card.ts`:**
> 🔴 `ngOnInit` sets `this.isLiked.set(this.post.isLiked)` — correct. But what if the `post` `@Input` changes after init? (e.g., parent refreshes the list.) The signal will be stale. Use `ngOnChanges(changes)` instead: if `changes['post']`, re-sync the signals. Or better: use `input()` signal (Angular 17+) and `effect()` to sync automatically.

**Comment on `post-card.html`:**
> 💬 The like button uses `(click)="toggleLike()"`. What about keyboard users? Add `(keydown.enter)="toggleLike()"` or use a `<button>` element (which handles Enter natively). Accessibility is not optional — it's part of "done".

**Comment on `feed.ts`:**
> ⚠️ Mock data is hardcoded inside the component. Move it to `core/mocks/posts.mock.ts`. Two reasons: (1) when you switch to real API in Phase 6 you delete one file, not scattered inline arrays; (2) other components (explore, profile) might need the same mock data during development.

**Comment on `time-ago.pipe.ts`:**
> ✅ Clean implementation. Mark it `pure: true` (it's the default but being explicit signals intent). One edge case: what if `value` is `null` or an empty string? Add a guard at the top: `if (!value) return ''`.

**Comment on `feed.html`:**
> 💬 The `@for` loop has `track post.id` — excellent, this is correct and shows you understand why tracking matters. Many juniors forget this. 

## GitHub Tasks
Commits:
  feat(models): add Post and User interfaces
  feat(post): add PostCard component with @Input and like toggle
  feat(feed): add FeedPage with mock data and PostCard list
  feat(pipes): add TimeAgo pipe
  style(post): style PostCard with Tailwind (mobile-first)
PR: feature/phase-03-feed → develop
## Definition of Done
- [ ] Feed page shows a vertical list of PostCard components
- [ ] PostCard displays: image, username, avatar, caption, likes count, time ago
- [ ] Clicking the heart icon toggles like state (signal flips, count ±1)
- [ ] `TimeAgo` pipe works: "just now", "5 minutes ago", "2 days ago"
- [ ] OnPush is set on PostCard — verify in Angular DevTools
- [ ] Posts look good on mobile AND desktop

---

---

---

# PHASE 3.5 — Create Post Page
### ⏱ Time estimate: 5–6 hours | 🧠 New concepts: File input, image preview, FormData upload

## What you'll build
- A "New Post" modal or page triggered from the `+` button in the bottom nav / sidebar
- Image picker with instant preview before uploading
- Caption input with character counter (2,200 char limit like Instagram)
- Optional location field
- Upload progress indicator
- On success: navigate to the new post's detail page

## Why this phase exists here

Creating content is what social apps are built around — and file uploads introduce concepts (`FormData`, `FileReader`, `URL.createObjectURL`) that don't appear anywhere else in the plan. Doing it right after Phase 3 (where you built the PostCard) keeps momentum: you just built the thing that shows posts, now you build the thing that creates them.

## New concepts this phase

### FileReader API — Image Preview Before Upload

```typescript
// When the user picks a file, show a preview BEFORE uploading:
onFileSelected(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  // Validate file type:
  if (!file.type.startsWith('image/')) {
    this.fileError.set('Please select an image file')
    return
  }

  // Validate file size (max 10MB):
  if (file.size > 10 * 1024 * 1024) {
    this.fileError.set('Image must be under 10MB')
    return
  }

  this.selectedFile.set(file)

  // Method 1 — URL.createObjectURL (fast, recommended):
  // Creates a temporary URL pointing to the file in memory
  this.previewUrl.set(URL.createObjectURL(file))
  // Remember to call URL.revokeObjectURL() in ngOnDestroy to free memory

  // Method 2 — FileReader (base64, use when you need the data URI):
  // const reader = new FileReader()
  // reader.onload = () => this.previewUrl.set(reader.result as string)
  // reader.readAsDataURL(file)
}
```

### FormData — Multipart File Upload

```typescript
// Regular JSON won't carry a file — you need FormData (multipart/form-data):
uploadPost() {
  const file = this.selectedFile()
  if (!file) return

  const formData = new FormData()
  formData.append('image', file)
  // 'image' must match the field name your backend expects
  formData.append('caption', this.captionControl.value ?? '')

  if (this.locationControl.value) {
    formData.append('location', this.locationControl.value)
  }

  // CRITICAL: Do NOT set Content-Type header manually
  // HttpClient detects FormData and sets 'multipart/form-data; boundary=...' automatically
  // Setting it manually BREAKS the boundary token and the upload fails
  this.http.post<ApiResponse<Post>>(`${this.api}/posts`, formData).subscribe(...)
}
```

### Upload Progress

```typescript
// Track upload percentage with HttpClient's reportProgress:
import { HttpEventType, HttpRequest } from '@angular/common/http'

uploadWithProgress(formData: FormData) {
  const req = new HttpRequest('POST', `${this.api}/posts`, formData, {
    reportProgress: true,   // enables progress events
  })

  this.http.request(req).subscribe(event => {
    if (event.type === HttpEventType.UploadProgress) {
      const percent = Math.round(100 * (event.loaded / (event.total ?? 1)))
      this.uploadProgress.set(percent)
      // hint: show a progress bar in the template: [style.width.%]="uploadProgress()"
    }

    if (event.type === HttpEventType.Response) {
      // hint: upload complete — navigate to new post
      const post = (event.body as ApiResponse<Post>).data
      this.router.navigate(['/post', post.id])
    }
  })
}
```

## Pseudo-code hints

```typescript
// create-post.ts
export class CreatePost implements OnDestroy {
  private http = inject(HttpClient)
  private router = inject(Router)

  selectedFile = signal<File | null>(null)
  previewUrl   = signal<string | null>(null)
  fileError    = signal('')
  uploading    = signal(false)
  uploadProgress = signal(0)

  captionControl  = new FormControl('', [Validators.maxLength(2200)])
  locationControl = new FormControl('')

  // Character counter for caption:
  captionLength  = computed(() => this.captionControl.value?.length ?? 0)
  captionNearMax = computed(() => this.captionLength() > 2000)
  // hint: show captionNearMax in red in the template

  onFileSelected(event: Event) {
    // hint: validate type and size
    // hint: set selectedFile and previewUrl signals
  }

  removeImage() {
    if (this.previewUrl()) URL.revokeObjectURL(this.previewUrl()!)
    this.selectedFile.set(null)
    this.previewUrl.set(null)
    // hint: also reset the file input element using @ViewChild
  }

  submit() {
    if (!this.selectedFile()) return
    // hint: build FormData and call uploadWithProgress()
  }

  ngOnDestroy() {
    // hint: revoke object URL to free browser memory
    if (this.previewUrl()) URL.revokeObjectURL(this.previewUrl()!)
  }
}
```

```html
<!-- create-post.html — structure hint -->
<!--
  Step 1: File picker (shown when no image selected)
  ┌─────────────────────────────────┐
  │                                 │
  │   [camera icon]                 │
  │   Tap to select a photo         │
  │                                 │
  └─────────────────────────────────┘
  <input type="file" accept="image/*" (change)="onFileSelected($event)"
         class="hidden" #fileInput />
  <button (click)="fileInput.click()">Select Photo</button>

  Step 2: Preview + form (shown after image selected)
  ┌──────┬──────────────────────────┐
  │      │ [✕] Remove               │
  │image │                          │
  │prev  │ Caption textarea...      │
  │      │ 0 / 2200                 │
  │      │                          │
  │      │ 📍 Location (optional)   │
  └──────┴──────────────────────────┘

  Upload progress bar (shown during upload):
  <div class="h-1 bg-gray-200 rounded-full">
    <div class="h-1 bg-primary rounded-full transition-all"
         [style.width.%]="uploadProgress()">
    </div>
  </div>
-->
```

## 👨‍💻 Senior Dev Code Review — Phase 3.5

**Comment on file validation:**
> 🔴 You validate `file.type.startsWith('image/')` — good. But MIME types can be spoofed. A renamed `.exe` file could pass this check. Add a secondary check on the file extension: `['jpg','jpeg','png','gif','webp'].includes(file.name.split('.').pop()?.toLowerCase() ?? '')`. Not foolproof but a reasonable frontend guard.

**Comment on `removeImage()`:**
> ⚠️ `URL.revokeObjectURL()` is called when removing — correct. Is it also called in `ngOnDestroy`? What if the user navigates away without removing the image? Memory leak. Make sure ngOnDestroy also revokes it.

**Comment on the file input:**
> 💬 `<input type="file">` is hidden and triggered by a visible button — correct approach for custom styling. But after `removeImage()`, the file input's value isn't reset. If the user removes and re-selects the same file, `(change)` won't fire (browser considers it unchanged). Fix: `this.fileInputRef.nativeElement.value = ''` after removing.

## GitHub Tasks

```
Branch: feature/phase-03-5-create-post
Issue:  [Phase 3.5] Create Post Page
Commits:
  feat(post): add create post page with image picker
  feat(post): add image preview with URL.createObjectURL
  feat(post): add upload progress bar with HttpRequest reportProgress
  feat(post): add caption character counter (2200 limit)
  fix(post): revoke object URL in ngOnDestroy to prevent memory leak
PR: feature/phase-03-5-create-post → develop
```

## Definition of Done
- [ ] Tapping `+` opens the create post flow
- [ ] File picker shows only on mobile file picker / desktop file dialog
- [ ] Image preview appears instantly after selection (before upload)
- [ ] File type and size validation show errors correctly
- [ ] Caption textarea shows character count, turns red above 2000
- [ ] Upload progress bar fills as file uploads
- [ ] Success navigates to the new post's detail page
- [ ] `URL.revokeObjectURL()` is called in `ngOnDestroy`
- [ ] Removing the image resets the file input so same file can be re-selected

---

---

## 📚 Topics to Study or Review Before Phase 4

### Route Parameters
- Defining a route with a parameter: `{ path: 'profile/:username', component: Profile }`
- `inject(ActivatedRoute)` — getting the route object in a component
- `route.snapshot.paramMap.get('username')` — one-time read of the param
- `route.paramMap` — Observable that updates if the param changes without destroying the component
- When to use snapshot vs the Observable — snapshot is fine when navigating between different routes, Observable needed when same component reloads with new param
- 📖 Resource: Angular tutorial Part 4 (your guide) — Route Parameters section

### computed() Signals — Derived State
- `computed(() => expression)` — a read-only signal whose value is calculated from other signals
- Why `computed` is better than a method for derived values — it's cached and only recalculates when its dependencies change
- Example: `isOwnProfile = computed(() => auth.getCurrentUser()?.username === this.username())`
- 📖 Resource: Angular tutorial Part 4 (your guide) — computed() section

### Tailwind — CSS Grid
- `grid` — enables CSS Grid
- `grid-cols-3` — three equal columns
- `gap-1`, `gap-0.5` — spacing between grid cells
- `col-span-2` — a cell that spans two columns
- 📖 Resource: [Tailwind — Grid Template Columns](https://tailwindcss.com/docs/grid-template-columns)

### Optimistic UI Pattern
- What "optimistic UI" means: update the UI immediately as if the API call succeeded, then revert if it fails
- Why it matters: snappy feel — the user sees instant feedback instead of waiting for the server
- The pattern: flip signal → call API → on error, flip signal back
- This is how all major social apps handle likes, follows, etc.
- 📖 Resource: Search "optimistic UI pattern React/Angular" — the concept is framework-agnostic

### ngOnInit vs constructor
- Why we use `ngOnInit` for data loading, NOT the constructor
- Constructor runs during Angular's class instantiation — injected services may not be ready
- `ngOnInit` runs after Angular has set all `@Input()` values — safe to use inputs here
- 📖 Resource: Angular tutorial Part 1 (your guide) — Lifecycle Hooks section

---

# PHASE 4 — Profile Page
### ⏱ Time estimate: 5–7 hours | 🧠 New concept: Route parameters + Signals for page state

## What you'll build
- `/profile/:username` — public profile page
- Shows: avatar, bio, follower/following counts, posts grid
- A follow/unfollow button with optimistic state
- Your own profile shows an "Edit Profile" button instead of Follow

## New concept this phase: Route parameters

```typescript
// Reading :username from the URL:
export class Profile implements OnInit {
  private route = inject(ActivatedRoute)

  // Method 1 — snapshot (one-time read):
  username = this.route.snapshot.paramMap.get('username') ?? ''

  // Method 2 — reactive (updates if URL changes without component recreating):
  username$ = this.route.paramMap.pipe(map(p => p.get('username') ?? ''))
  // hint: use toSignal() to convert this to a signal
}
```

## Pseudo-code hints

```typescript
// profile.ts
export class ProfilePage implements OnInit {
  private route = inject(ActivatedRoute)
  private userService = inject(UserService)
  private authService = inject(AuthService)

  username = signal('')
  profileUser = signal<User | null>(null)
  posts = signal<Post[]>([])
  loading = signal(true)

  // hint: is this the current user's own profile?
  isOwnProfile = computed(() => {
    const current = this.authService.getCurrentUser()
    return current?.username === this.username()
  })

  // hint: signal for follow state
  isFollowing = signal(false)
  followersCount = signal(0)

  ngOnInit() {
    // hint: read :username from route
    // hint: load user data and posts (use mock data for now)
    // hint: set isFollowing based on user data
  }

  toggleFollow() {
    // hint: optimistic update — flip signal THEN call API
    // if API fails, flip it back
    // This is called "optimistic UI" — common in social apps
    const wasFollowing = this.isFollowing()
    this.isFollowing.set(!wasFollowing)
    this.followersCount.update(n => wasFollowing ? n - 1 : n + 1)
    // hint: call userService.toggleFollow(this.username())
    // hint: on error, revert both signals
  }
}
```

```html
<!-- profile.html — structure hint -->
<!--
  Profile header:
  ┌──────────────────────────────────────┐
  │  [Avatar 150px]  username            │
  │                  Real Name           │
  │                  [Posts] [Followers] [Following]  │
  │                  [Follow btn] or [Edit Profile]  │
  │                  Bio text here       │
  └──────────────────────────────────────┘

  Posts grid (3 columns — Instagram style):
  ┌────┬────┬────┐
  │img │img │img │
  ├────┼────┼────┤
  │img │img │img │
  └────┴────┴────┘

  Tailwind hint for 3-col grid:
  <div class="grid grid-cols-3 gap-0.5">
    @for (post of posts(); track post.id) {
      <div class="aspect-square overflow-hidden">
        <img class="w-full h-full object-cover" ... />
      </div>
    }
  </div>
-->
```

## 👨‍💻 Senior Dev Code Review — Phase 4

**Comment on `profile.ts`:**
> 🔴 `toggleFollow()` updates `isFollowing` and `followersCount` optimistically — perfect pattern. But the error rollback does `this.isFollowing.set(wasFollowing)` using a variable captured before the call. What if the user spams the button before the API responds? The captured `wasFollowing` will be wrong by then. Fix: call `this.userService.toggleFollow()` inside `switchMap` so rapid clicks cancel the previous request.

**Comment on `profile.ts` — `isOwnProfile` computed:**
> ✅ Using `computed()` here is exactly right — it derives from two signals and auto-updates. This is the Angular Signals way. Approved.

**Comment on `profile.html`:**
> 💬 The posts grid uses `grid-cols-3` with no `gap` — posts are touching each other. Intentional? Instagram uses a very small gap (`gap-0.5` = 2px). Add it if you want to match that aesthetic.

**Comment on the missing case:**
> ⚠️ What happens when `getProfile('nonexistent-user')` returns a 404? The page shows... nothing? Add an empty/error state: a centered message "User not found" with a back link. Every data-loading page needs three states: loading, error, and success.

## GitHub Tasks
Commits:
  feat(profile): add profile page with user info and stats
  feat(profile): add posts grid with 3-column layout
  feat(profile): add follow/unfollow toggle with optimistic update
  feat(profile): differentiate own profile vs others
PR: feature/phase-04-profile → develop
## Definition of Done
- [ ] `/profile/khaled.dev` loads and shows a profile
- [ ] Posts appear in a 3-column grid
- [ ] Follow button toggles state optimistically
- [ ] Own profile shows "Edit Profile" not "Follow"
- [ ] Follower count updates when follow is toggled
- [ ] Profile header is responsive (stacks on mobile, side-by-side on desktop)

---

---

---

## 📚 Topics to Study or Review Before Phase 5

### Angular Services and Dependency Injection (review + deepen)
- What a service is: a singleton class that holds shared logic and data
- `@Injectable({ providedIn: 'root' })` — what `providedIn: 'root'` means (one instance for the whole app)
- `inject(ServiceName)` — the modern way to inject in standalone components
- Why services hold HTTP calls instead of putting them directly in components
- 📖 Resource: Angular tutorial Part 2 (your guide) — Services section

### HttpClient (review)
- `this.http.get<ResponseType>(url)` — returns an Observable, NOT the data directly
- `.subscribe({ next, error, complete })` — starting the HTTP call
- `map(res => res.data)` — transforming the response with RxJS
- `catchError` — handling HTTP errors in the pipe
- 📖 Resource: Angular tutorial Part 2 (your guide) — HTTP section

### TypeScript Generics — ApiResponse<T>
- What generics are: `ApiResponse<T>` means "a response that wraps any type T"
- Defining: `interface ApiResponse<T> { success: boolean; data: T; message?: string }`
- Using: `http.get<ApiResponse<Post>>('/api/posts/1')` — TypeScript knows `res.data` is `Post`
- 📖 Resource: Angular tutorial Part 1 (your guide) — TypeScript Generics section

### RxJS — map and forkJoin
- `map(fn)` — transforms each emission: `.pipe(map(res => res.data))`
- `catchError(err => of(fallbackValue))` — handle error and return a fallback
- `finalize(() => cleanup())` — runs on both complete and error (good for hiding spinners)
- 📖 Resource: Angular tutorial Part 2 (your guide) — RxJS section

### Tailwind — Overflow and Scroll
- `overflow-hidden` — clip content that overflows the container
- `overflow-y-auto` — vertical scroll when content exceeds height
- `sticky top-0` — element sticks to the top when scrolling past it
- `z-10` — stacking order (important for sticky elements over content)

---

# PHASE 5 — Post Detail & Comments
### ⏱ Time estimate: 5–6 hours | 🧠 New concept: Nested routes + Component data flow

## What you'll build
- `/post/:id` — full post detail page
- Shows large image, full caption, all comments
- Add a comment form at the bottom
- Clicking a post in the feed navigates here

## New concept this phase: Two-pane layout (desktop Instagram style)

On desktop, Instagram shows the post detail as two columns: image on left, info+comments on right.
On mobile, it's stacked.

```
Desktop:                          Mobile:
┌──────────────┬──────────────┐  ┌─────────────┐
│              │ username     │  │ username     │
│              │ location     │  │ location     │
│   IMAGE      │──────────────│  │─────────────│
│              │ [comments    │  │    IMAGE     │
│              │  scrollable] │  │─────────────│
│              │──────────────│  │ [comments]  │
│              │ [like, save] │  │ [like, save]│
│              │ [comment box]│  │ [comment box│
└──────────────┴──────────────┘  └─────────────┘
```

## Pseudo-code hints

```typescript
// comment.model.ts
export interface Comment {
  id: string
  author: {
    username: string
    avatarUrl: string
  }
  text: string
  likesCount: number
  isLiked: boolean
  createdAt: string
  replies?: Comment[]  // nested replies (optional for now)
}
```

```typescript
// post-detail.ts
export class PostDetail implements OnInit {
  private route = inject(ActivatedRoute)
  private postService = inject(PostService)

  postId = signal('')
  post = signal<Post | null>(null)
  comments = signal<Comment[]>([])
  loading = signal(true)
  newComment = new FormControl('', [Validators.required, Validators.minLength(1)])
  submittingComment = signal(false)

  ngOnInit() {
    // hint: read :id from route
    // hint: load post + comments (mock data for now)
  }

  submitComment() {
    // hint: validate newComment.value
    // hint: optimistically add comment to the comments signal
    // hint: clear the input
    // hint: call postService.addComment() (later)
  }
}
```

```typescript
// post.service.ts — build out this service this phase
@Injectable({ providedIn: 'root' })
export class PostService {
  private http = inject(HttpClient)
  private api = `${environment.apiUrl}/posts`

  getPostById(id: string): Observable<ApiResponse<Post>> {
    // hint: GET /posts/:id
  }

  getComments(postId: string): Observable<ApiResponse<Comment[]>> {
    // hint: GET /posts/:id/comments
  }

  addComment(postId: string, text: string): Observable<ApiResponse<Comment>> {
    // hint: POST /posts/:id/comments with { text }
  }

  toggleLike(postId: string): Observable<ApiResponse<{ isLiked: boolean; count: number }>> {
    // hint: POST /posts/:id/like (toggle endpoint)
  }
}
```

## 👨‍💻 Senior Dev Code Review — Phase 5

**Comment on `post.service.ts`:**
> ⚠️ All four methods (`getPostById`, `getComments`, `addComment`, `toggleLike`) are public and return raw Observables. That's correct. But I notice no `catchError` in any of them. Services should NOT handle errors — they let them propagate to the component or interceptor. But add a `tap` for any side effects (e.g. cache invalidation). Good structure otherwise.

**Comment on `post-detail.ts`:**
> 🔴 You're calling `this.route.snapshot.paramMap.get('id')` in `ngOnInit`. What if the user navigates from `/post/1` to `/post/2`? Angular reuses the component instance — `ngOnInit` does NOT re-run. You'll show post 1's content on post 2's URL. Use `this.route.paramMap` (the Observable version) with `switchMap` to handle navigation between posts correctly.

**Comment on `submitComment()`:**
> 💬 Comments are added optimistically to the local array — good. But the optimistic comment has no `id` yet (it hasn't been saved). If the user clicks on it or tries to like it before the API responds, things break. Give it a temporary id: `id: 'temp-' + Date.now()` and replace it when the API responds.

**Comment on two-pane layout:**
> ✅ `lg:flex` for desktop two-pane and single column on mobile is the right approach. Add `max-h-[calc(100vh-64px)] overflow-y-auto` to the comments column on desktop so it scrolls independently without the whole page scrolling — exactly like Instagram's desktop web.

## GitHub Tasks
Commits:
  feat(post): add post detail page with two-pane layout
  feat(post): add comment list and add comment form
  feat(services): implement PostService with HTTP methods
  style(post): responsive two-pane becomes stacked on mobile
PR: feature/phase-05-post-detail → develop
```

## Definition of Done
- [ ] Clicking a PostCard in the feed navigates to `/post/:id`
- [ ] Post detail shows image, caption, full comment list
- [ ] Comment form works — typed comment appears in list immediately
- [ ] Desktop: two-column layout. Mobile: stacked layout
- [ ] Loading state shown while post data loads

---

---

---

## 📚 Topics to Study or Review Before Phase 6

### HTTP Interceptors — How They Work
- What an interceptor is: middleware that runs on every HTTP request/response
- The functional interceptor syntax: `export const myInterceptor: HttpInterceptorFn = (req, next) => { ... }`
- `req.clone({ setHeaders: { Authorization: 'Bearer ...' } })` — modifying a request
- `next(req)` — passing the request to the next interceptor or the network
- `catchError` inside an interceptor — intercepting errors globally
- Registering interceptors: `withInterceptors([tokenInterceptor, errorInterceptor])` in `app.config.ts`
- The order matters: first in the array = outermost layer
- 📖 Resource: Angular tutorial Part 2 (your guide) — Interceptors section

### HTTP Error Handling
- `HttpErrorResponse` — the error object shape: `.status`, `.error.message`
- Status codes to handle: `0` (network error), `401` (unauthorized), `403` (forbidden), `404` (not found), `500` (server error)
- The interceptor handles `401` globally (logout); components handle other errors locally
- `throwError(() => err)` — re-throwing an error after handling it in the interceptor

### RxJS — retry and finalize
- `retry({ count: 2, delay: 1000 })` — retry a failed Observable N times
- Only retry server errors (5xx/0), not client errors (4xx)
- `finalize(() => fn())` — guaranteed to run whether Observable completes or errors
- Perfect for `loading.set(false)` — so loading never stays stuck on `true`
- 📖 Resource: Angular tutorial Part 7 (your guide) — Retry Logic section

### Environment Files
- `environment.ts` — development config (`apiUrl: 'http://localhost:3000/api'`)
- `environment.production.ts` — production config (your real API URL)
- How Angular swaps files at build time with `fileReplacements` in `angular.json`
- `import { environment } from '../../../environments/environment'` in services
- 📖 Resource: Angular tutorial Part 9 (your guide) — Environment Files chapter

### JWT — What's in the Token
- What a JSON Web Token is: `header.payload.signature` (three base64 parts separated by dots)
- The payload contains: `_id`, `email`, `role`, `exp` (expiry timestamp)
- Reading the payload: `JSON.parse(atob(token.split('.')[1]))`
- `exp` is in seconds since epoch: compare with `Date.now() / 1000`
- 📖 Resource: [jwt.io](https://jwt.io) — paste a token to see its contents (great for understanding)

---

# PHASE 6 — Real API Integration
### ⏱ Time estimate: 4–5 hours | 🧠 New concept: HTTP error handling + loading states

## What you'll do
Replace all mock data with real API calls. Wire up AuthService, PostService, UserService to your backend.

## New concept this phase: HTTP patterns you haven't seen yet

```typescript
// Pattern 1: loading + error signal combo (use this everywhere)
loading = signal(false)
error = signal('')

loadData() {
  this.loading.set(true)
  this.error.set('')

  this.service.getData().subscribe({
    next: res => {
      this.data.set(res.data)
      this.loading.set(false)
    },
    error: err => {
      this.error.set(err.error?.message ?? 'Something went wrong')
      this.loading.set(false)
    }
  })
}

// Pattern 2: retry on network errors (not 4xx)
this.service.getData().pipe(
  retry({
    count: 2,
    delay: (err, n) => {
      if (err.status >= 400 && err.status < 500) throw err  // don't retry client errors
      return timer(n * 1000)  // retry server/network errors with delay
    }
  })
).subscribe(...)
```

## Pseudo-code hints

```typescript
// user.service.ts
@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient)
  private api = `${environment.apiUrl}/users`

  getProfile(username: string): Observable<ApiResponse<User>> {
    // GET /users/:username
  }

  toggleFollow(username: string): Observable<ApiResponse<{ isFollowing: boolean }>> {
    // POST /users/:username/follow
  }

  updateProfile(data: Partial<User>): Observable<ApiResponse<User>> {
    // PATCH /users/me
  }

  searchUsers(query: string): Observable<ApiResponse<User[]>> {
    // GET /users/search?q=query
  }
}
```

```typescript
// Replace mock data in FeedPage with real API:
ngOnInit() {
  this.loading.set(true)
  this.postService.getFeed(1, 10).subscribe({
    // hint: on success set posts signal
    // hint: on error set error signal
    // hint: always set loading false in finalize()
  })
}
```

## 👨‍💻 Senior Dev Code Review — Phase 6

**Comment on `token.interceptor.ts`:**
> 💬 The interceptor reads the token with `inject(AuthService).getToken()` on every request — this is correct. But what happens after the token expires mid-session? The interceptor sends the expired token, the API returns 401, the error interceptor logs out. That flow is correct. Consider adding token refresh logic here later (Phase 13 stretch goal).

**Comment on `error.interceptor.ts`:**
> 🔴 You're catching ALL errors and showing a toast/snackbar globally. But some errors should be handled silently by the component (like a 404 on a search that returns no results). Add a custom header flag: `X-Silent-Error: true` on requests that should suppress the global error handler — same pattern as the `X-Skip-Loading` header from the tutorial.

**Comment on `feed.ts`:**
> ⚠️ You replaced the mock data `setTimeout` with a real API call — good. But `ngOnInit` now has both the initial load AND the polling logic in Phase 11 side by side. Extract the load logic to a private `loadFeed(page: number)` method to keep `ngOnInit` readable. `ngOnInit` should read like a table of contents, not a wall of code.

**Comment on `environment.ts`:**
> ✅ `apiUrl` is in the environment file, not hardcoded in services. This is correct. Confirm `environment.production.ts` has a real URL (not localhost) before Phase 12 deployment.

## GitHub Tasks
Commits:
  feat(services): wire PostService to real API endpoints
  feat(services): wire UserService to real API endpoints
  feat(auth): wire AuthService login/register to real API
  fix(feed): handle empty feed state gracefully
  fix(profile): handle profile not found (404)
PR: feature/phase-06-api → develop
```

## Definition of Done
- [ ] Login/register works with real backend
- [ ] Feed loads real posts from API
- [ ] Profile page loads real user data
- [ ] Post detail loads real post and comments
- [ ] All 401 errors trigger logout (interceptor)
- [ ] Loading and error states appear correctly

---

---

---

# PHASE 6.5 — Global Error Boundary
### ⏱ Time estimate: 3–4 hours | 🧠 New concept: Angular ErrorHandler + global UX

## What you'll build
- A custom `AppErrorHandler` that catches ALL unhandled JavaScript errors
- A non-intrusive toast notification system for error messages
- A retry mechanism for failed API calls
- An offline detection banner ("You're offline — some features may not work")

## Why this phase exists here

After Phase 6 you have real API calls flying everywhere. Network errors, unexpected API shapes, and unhandled RxJS errors will start appearing as white screens or silent failures. A real app handles this gracefully. Adding this before the heavy features of Phase 7+ means every subsequent phase gets error safety for free.

## New concept: Angular's `ErrorHandler`

Angular has a built-in `ErrorHandler` class. By default it just calls `console.error`. You can replace it with your own class to add monitoring, user notifications, and recovery behavior.

```typescript
// app-error-handler.ts
import { ErrorHandler, Injectable, inject } from '@angular/core'
import { HttpErrorResponse } from '@angular/common/http'

@Injectable()
export class AppErrorHandler implements ErrorHandler {
  // hint: inject your ToastService here

  handleError(error: unknown): void {
    // Categorize the error:

    if (error instanceof HttpErrorResponse) {
      // HTTP errors should already be handled by the error interceptor
      // This is a safety net for any that slip through
      console.error('[HTTP Error]', error.status, error.message)
      return
    }

    if (error instanceof TypeError) {
      // JavaScript errors — often a bug in your code
      // hint: show a generic "Something went wrong" toast
      // hint: in production, send to a logging service (Sentry, etc.)
      console.error('[TypeError]', error.message)
      return
    }

    // Unknown errors:
    console.error('[Unknown Error]', error)
    // hint: show a generic toast
  }
}
```

```typescript
// Register it in app.config.ts — REPLACES Angular's default handler:
export const appConfig: ApplicationConfig = {
  providers: [
    { provide: ErrorHandler, useClass: AppErrorHandler },
    // hint: other providers...
  ]
}
```

## Toast Notification Service

```typescript
// toast.service.ts — a lightweight notification system
export type ToastType = 'success' | 'error' | 'info' | 'warning'

export interface Toast {
  id: string
  message: string
  type: ToastType
  duration: number    // ms before auto-dismiss
}

@Injectable({ providedIn: 'root' })
export class ToastService {
  toasts = signal<Toast[]>([])

  show(message: string, type: ToastType = 'info', duration = 4000) {
    const toast: Toast = {
      id: crypto.randomUUID(),  // hint: built-in browser API, no import needed
      message,
      type,
      duration
    }

    this.toasts.update(current => [...current, toast])

    // Auto-dismiss:
    setTimeout(() => this.dismiss(toast.id), duration)
  }

  // Convenience methods:
  success(msg: string) { this.show(msg, 'success') }
  error(msg: string)   { this.show(msg, 'error', 6000) }  // errors stay longer
  info(msg: string)    { this.show(msg, 'info') }
  warn(msg: string)    { this.show(msg, 'warning') }

  dismiss(id: string) {
    this.toasts.update(current => current.filter(t => t.id !== id))
  }
}
```

```typescript
// toast-container.ts — renders the toast stack in the top-right corner
// Add <app-toast-container> once in app-shell.html
@Component({
  selector: 'app-toast-container',
  standalone: true,
  imports: [/* hint: what do you need for @for and animations? */],
  template: `
    <div class="fixed top-4 end-4 z-[9999] flex flex-col gap-2 w-80">
    <!-- end-4 = right in LTR, left in RTL — RTL-aware! -->
      @for (toast of toastService.toasts(); track toast.id) {
        <div [@toastAnimation]
             [class]="toastClasses(toast.type)"
             class="rounded-xl px-4 py-3 shadow-lg flex items-start gap-3">
          <!-- hint: icon based on toast.type -->
          <p class="flex-1 text-sm">{{ toast.message }}</p>
          <button (click)="toastService.dismiss(toast.id)"
                  class="text-current opacity-60 hover:opacity-100 text-lg leading-none">
            ✕
          </button>
        </div>
      }
    </div>
  `,
  animations: [/* hint: :enter fades in from right, :leave fades out */]
})
export class ToastContainer {
  toastService = inject(ToastService)

  toastClasses(type: ToastType): string {
    // hint: return Tailwind classes based on type
    // success: green bg
    // error: red bg
    // warning: yellow bg
    // info: blue bg
  }
}
```

## Offline Detection

```typescript
// In app-shell.ts — detect when the browser goes offline:
isOffline = signal(!navigator.onLine)
// navigator.onLine: true = connected, false = offline

constructor() {
  window.addEventListener('online',  () => this.isOffline.set(false))
  window.addEventListener('offline', () => this.isOffline.set(true))
  // hint: remove listeners in ngOnDestroy
}
```

```html
<!-- app-shell.html — offline banner -->
@if (isOffline()) {
  <div class="fixed top-0 inset-x-0 z-50 bg-yellow-500 text-black text-center py-2 text-sm font-medium">
    📡 You're offline — some features may not work
  </div>
}
```

## 👨‍💻 Senior Dev Code Review — Phase 6.5

**Comment on `AppErrorHandler`:**
> 💬 Good separation between HttpErrorResponse and other errors. One thing: in production, you'd want to send errors to a monitoring service (Sentry, Datadog). Add a `MonitoringService` stub now — even if it just `console.log`s — so when you integrate real monitoring later, you only change one file.

**Comment on `ToastService`:**
> ✅ `crypto.randomUUID()` for IDs is exactly right. Using `Math.random()` for IDs is a common junior mistake that causes duplicate keys in `@for` loops under load.

**Comment on `ToastContainer`:**
> ⚠️ The toast container uses `fixed top-4 end-4` — correct for RTL. But what about mobile? `w-80` (320px) might overflow on a 375px screen. Use `max-w-[calc(100vw-2rem)]` instead so it's always contained.

## GitHub Tasks

```
Branch: feature/phase-06-5-error-boundary
Issue:  [Phase 6.5] Global Error Handler + Toast System
Commits:
  feat(error): add AppErrorHandler replacing Angular default
  feat(toast): add ToastService with signal-based toast queue
  feat(toast): add ToastContainer component with enter/leave animations
  feat(shell): add offline detection banner
  refactor(interceptors): use ToastService instead of console.error
PR: feature/phase-06-5-error-boundary → develop
```

## Definition of Done
- [ ] Throwing `throw new Error('test')` anywhere in the app shows a toast
- [ ] A failed API call shows a toast with the error message
- [ ] Toasts auto-dismiss after their duration
- [ ] `✕` button manually dismisses a toast
- [ ] Multiple toasts stack vertically without overlapping
- [ ] Toast appears on the correct side in both LTR and RTL modes
- [ ] Disconnecting Wi-Fi shows the offline banner instantly
- [ ] Reconnecting hides the offline banner

---

---

## 📚 Topics to Study or Review Before Phase 7

### Angular Animations — From Scratch
- `provideAnimations()` — must be in `app.config.ts` before any animation works
- `trigger(name, [...])` — groups states and transitions under one name
- `state(name, style({...}))` — the resting CSS for a named state
- `transition('a => b', [...])` — what happens when switching between states
- `style({...})` — CSS object at a specific moment in the animation
- `animate('300ms ease-out', style({...}))` — the tween: duration, easing, end state
- `:enter` — alias for `void => *` — triggers when element is added to the DOM
- `:leave` — alias for `* => void` — triggers when element is removed from the DOM
- Adding `animations: [myTrigger]` to the `@Component` decorator
- Using `[@triggerName]` or `[@triggerName]="stateVariable"` in the template
- 📖 Resource: Angular tutorial Part 5 (your guide) — Angular Animations chapter (read the WHOLE chapter before starting)

### @defer Blocks
- What `@defer` does: downloads a component's JavaScript only when needed
- `@defer (on viewport)` — trigger when element scrolls into view
- `@defer (when condition())` — trigger when a signal/expression becomes true
- `@placeholder` — what shows before the trigger fires
- `@loading` — what shows while JS is downloading
- `@error` — what shows if download fails
- 📖 Resource: Angular tutorial Part 7 (your guide) — @defer section

### JavaScript Timers (for the story auto-advance)
- `setInterval(fn, ms)` — calls `fn` every `ms` milliseconds, returns an ID
- `clearInterval(id)` — stops the interval — ALWAYS call this in `ngOnDestroy`
- `setTimeout(fn, ms)` — calls `fn` once after `ms` ms, returns an ID
- `clearTimeout(id)` — cancels a pending timeout
- Why forgetting to clear timers causes memory leaks and bugs after navigation

### Tailwind — Position and Z-Index
- `fixed inset-0` — covers the entire viewport (good for overlays)
- `absolute`, `relative` — positioning context
- `top-0`, `right-0`, `bottom-0`, `left-0` — pin to edges
- `z-10`, `z-50`, `z-[9999]` — stacking order
- `pointer-events-none` — element doesn't respond to clicks (good for decorative overlays)
- 📖 Resource: [Tailwind — Position](https://tailwindcss.com/docs/position)

### CSS Transitions vs Angular Animations — When to Use Each
- CSS transitions (`transition` class in Tailwind): for simple hover/focus effects — no Angular involvement needed
- Angular Animations: for `:enter`/`:leave`, state machines, sequenced/staggered animations
- Rule of thumb: if the animation involves adding/removing an element from the DOM, use Angular Animations

---

# PHASE 7 — Stories Feature
### ⏱ Time estimate: 6–8 hours | 🧠 New concept: Angular Animations + @defer

## What you'll build
- The stories bar at the top of the feed (circular avatars with gradient ring)
- A full-screen story viewer (tap to advance, tap to go back)
- Auto-advance after 5 seconds
- Progress bar per story

## New concept this phase: Angular Animations

```typescript
// animations.ts in shared/animations/
import { trigger, transition, style, animate, query, stagger } from '@angular/animations'

export const storyEnterAnimation = trigger('storyEnter', [
  transition(':enter', [
    // hint: story slides in from the right
    style({ transform: 'translateX(100%)', opacity: 0 }),
    animate('300ms ease-out', style({ transform: 'translateX(0)', opacity: 1 }))
  ]),
  transition(':leave', [
    // hint: current story slides out to the left
    animate('300ms ease-in', style({ transform: 'translateX(-100%)', opacity: 0 }))
  ])
])
```

## New concept this phase: @defer

The story viewer is a heavy component (full-screen, animations, timer). Load it lazily:

```html
<!-- In feed.html — only load StoryViewer when the user actually opens it -->
@defer (when storyViewerOpen()) {
  <app-story-viewer
    [stories]="selectedStories()"
    (closed)="closeStoryViewer()">
  </app-story-viewer>
} @placeholder {
  <!-- nothing shown until triggered -->
}
```

## Pseudo-code hints

```typescript
// story-bar.ts — the circles at the top of feed
export class StoryBar {
  @Input() stories: Story[] = []
  @Output() storySelected = new EventEmitter<Story[]>()
  // hint: emit ALL stories of the selected user
  // (so viewer can show all their stories, not just one)

  // The gradient ring — a Tailwind class or inline style
  // Use CSS: background: var(--story-ring) (defined in styles.css)
}
```

```typescript
// story-viewer.ts — the full-screen viewer
export class StoryViewer implements OnInit, OnDestroy {
  @Input({ required: true }) stories!: Story[]
  @Output() closed = new EventEmitter<void>()

  currentIndex = signal(0)
  progress = signal(0)         // 0 to 100

  private timer: ReturnType<typeof setInterval> | null = null
  private progressTimer: ReturnType<typeof setInterval> | null = null

  currentStory = computed(() => this.stories[this.currentIndex()])

  ngOnInit() {
    this.startProgress()
  }

  private startProgress() {
    // hint: clear any existing timers
    this.progress.set(0)
    // hint: use setInterval to increment progress by 2 every 100ms
    // (100ms × 50 steps = 5 seconds total)
    // hint: when progress reaches 100, call this.nextStory()
  }

  nextStory() {
    if (this.currentIndex() < this.stories.length - 1) {
      // hint: increment index, restart progress
    } else {
      // hint: no more stories — emit closed
    }
  }

  prevStory() {
    // hint: decrement index (if > 0), restart progress
  }

  close() {
    // hint: clear timers, emit closed
  }

  ngOnDestroy() {
    // hint: always clear timers to prevent memory leaks
  }
}
```

```html
<!-- story-viewer.html — structure hint -->
<!--
  Full-screen overlay: fixed inset-0 bg-black z-50
  
  Progress bars row at top (one per story):
  <div class="flex gap-1 p-2">
    @for (story of stories; track story.id; let i = $index) {
      <div class="h-0.5 bg-white/30 flex-1 rounded-full overflow-hidden">
        <div class="h-full bg-white rounded-full"
             [style.width.%]="getProgressForIndex(i)">
        </div>
      </div>
    }
  </div>

  Story image: object-cover, fills the screen
  Left half: tap to go back
  Right half: tap to advance
  Close button: top-right corner
-->
```

## GitHub Tasks

```
Branch: feature/phase-07-stories
Commits:
  feat(stories): add story bar with gradient ring avatars
  feat(stories): add full-screen story viewer with auto-advance
  feat(stories): add progress bars for current story timing
  feat(stories): use @defer to lazy-load story viewer
  feat(animations): add slide transition between stories
PR: feature/phase-07-stories → develop
```

## Definition of Done
- [ ] Stories bar appears at top of feed with avatar rings
- [ ] Clicking a story opens the full-screen viewer
- [ ] Story advances every 5 seconds automatically
- [ ] Progress bars fill correctly (one per story)
- [ ] Tapping left half = prev story, right half = next story
- [ ] Last story closes the viewer
- [ ] Close button works
- [ ] Smooth animation between stories

---

---

---

## 📚 Topics to Study or Review Before Phase 8

### The `document` Object — Manipulating the Root HTML Element
- `document.documentElement` — the `<html>` element itself
- `.classList.add('dark')` / `.classList.remove('dark')` — adds/removes a class on `<html>`
- `.setAttribute('dir', 'rtl')` / `.setAttribute('lang', 'ar')` — sets attributes
- Why we do this on `<html>` — Tailwind's `dark:` and CSS `[dir="rtl"]` selectors look at the root element

### localStorage — Persisting User Preferences
- `localStorage.setItem('key', 'value')` — saves a string value
- `localStorage.getItem('key')` — reads it back (returns `null` if not found)
- `localStorage.removeItem('key')` — deletes it
- Always save strings — for booleans: `localStorage.setItem('dark', 'true')` and read with `=== 'true'`
- Values survive page refresh — cleared only when the user clears browser data

### CSS Logical Properties — RTL-Aware Layout
- Why `padding-left` breaks in RTL: it's always left, regardless of text direction
- The fix: CSS Logical Properties — they flip automatically with `dir="rtl"`
- `padding-inline-start` = left in LTR, right in RTL → Tailwind: `ps-4`
- `padding-inline-end`   = right in LTR, left in RTL → Tailwind: `pe-4`
- `margin-inline-start`  → Tailwind: `ms-4`
- `margin-inline-end`    → Tailwind: `me-4`
- `inset-inline-start`   → Tailwind: `start-0` (for absolute positioning)
- `inset-inline-end`     → Tailwind: `end-0`
- Rule: replace EVERY `pl-`, `pr-`, `ml-`, `mr-`, `left-`, `right-` with logical equivalents
- 📖 Resource: [MDN — CSS Logical Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values)
- 📖 Resource: [Tailwind — RTL support](https://tailwindcss.com/docs/hover-focus-and-other-states#rtl-support)

### Signals as Readonly State — The Service Pattern
- `signal()` inside a service — private writable state
- `.asReadonly()` — exposes a read-only version to components
- Components can READ but cannot SET the signal directly — only the service can
- This protects state integrity: state only changes through the service's methods

### Google Fonts — Loading Arabic Fonts
- Adding `<link>` tags to `index.html` for Cairo (Arabic) and Inter (Latin)
- `font-family` in CSS — specifying fallbacks
- Tailwind custom fonts in `tailwind.config.js`: `fontFamily: { arabic: ['Cairo', 'sans-serif'] }`
- Using `font-arabic` class in the template when RTL is active
- 📖 Resource: [Google Fonts — Cairo](https://fonts.google.com/specimen/Cairo)

---

# PHASE 8 — Dark Mode + RTL Arabic Support
### ⏱ Time estimate: 5–7 hours | 🧠 New concept: Global state services + CSS direction

## What you'll build
- `ThemeService` — manages light/dark mode, persists to localStorage
- `DirectionService` — manages LTR/RTL, updates `<html dir="">` and `<html lang="">`
- A toggle button in the navbar for both settings
- All existing pages look correct in dark mode AND RTL

## New concept this phase: Services that manage global DOM state

```typescript
// theme.service.ts
@Injectable({ providedIn: 'root' })
export class ThemeService {
  private isDark = signal(false)
  readonly isDark$ = this.isDark.asReadonly()  // read-only signal for components

  constructor() {
    // hint: read saved preference from localStorage on startup
    // hint: also check window.matchMedia('(prefers-color-scheme: dark)') as fallback
    this.applyTheme()
  }

  toggle() {
    this.isDark.update(v => !v)
    this.applyTheme()
    // hint: save to localStorage so preference persists
  }

  private applyTheme() {
    const html = document.documentElement
    if (this.isDark()) {
      html.classList.add('dark')       // Tailwind's dark mode strategy
    } else {
      html.classList.remove('dark')
    }
    // hint: save isDark() value to localStorage
  }
}
```

```typescript
// direction.service.ts
@Injectable({ providedIn: 'root' })
export class DirectionService {
  private isRTL = signal(false)
  readonly isRTL$ = this.isRTL.asReadonly()
  readonly direction = computed(() => this.isRTL() ? 'rtl' : 'ltr')

  constructor() {
    // hint: read from localStorage
    this.applyDirection()
  }

  toggle() {
    this.isRTL.update(v => !v)
    this.applyDirection()
    // hint: save to localStorage
  }

  private applyDirection() {
    const html = document.documentElement
    html.setAttribute('dir', this.direction())
    html.setAttribute('lang', this.isRTL() ? 'ar' : 'en')
    // hint: save preference to localStorage
  }
}
```

## Tailwind dark mode patterns

```html
<!-- Every color now needs a dark: variant: -->
<div class="bg-white dark:bg-gray-900">
<p class="text-gray-900 dark:text-gray-100">
<div class="border-gray-200 dark:border-gray-700">
<input class="bg-gray-50 dark:bg-gray-800">

<!-- RTL-aware spacing — Tailwind has start/end utilities: -->
<div class="ps-4">    <!-- padding-inline-start: LTR=left, RTL=right -->
<div class="me-2">    <!-- margin-inline-end:   LTR=right, RTL=left -->
<!-- This is BETTER than pl-4/mr-2 which are always left/right -->
```

## What needs dark mode styling

Go back through EVERY component you've built and add dark variants:

```
✅ Navbar      — background, text, border, active states
✅ Sidebar     — background, text, active link highlight
✅ PostCard    — background, text, border, like button colors
✅ Profile     — background, text, avatar border
✅ Post Detail — background, comment list, input field
✅ Login       — form card, inputs, labels
✅ Register    — same as login
✅ Story viewer — already dark-first (full black background)
```

## GitHub Tasks

```
Branch: feature/phase-08-theme-rtl
Commits:
  feat(theme): add ThemeService with dark mode toggle and persistence
  feat(i18n): add DirectionService with RTL/LTR toggle
  feat(navbar): add dark mode and language toggle buttons
  style(app): apply dark mode classes to all components
  style(app): apply RTL-aware spacing (ps/pe/ms/me) throughout
PR: feature/phase-08-theme-rtl → develop
```

## Definition of Done
- [ ] Dark mode toggle in navbar works and persists on refresh
- [ ] ALL pages look correct in dark mode (no white boxes on dark backgrounds)
- [ ] RTL toggle flips the entire UI direction
- [ ] Arabic font (Cairo) loads for RTL mode
- [ ] Spacing uses `ps-`/`pe-`/`ms-`/`me-` not `pl-`/`pr-`/`ml-`/`mr-`
- [ ] TimeAgo pipe returns Arabic text in RTL mode

---

---

---

## 📚 Topics to Study or Review Before Phase 9

### Component Composition — Building Small, Reusable Pieces
- The principle: build one tiny, general component (`SkeletonBlock`) then compose it into specific layouts (`PostCardSkeleton`)
- `@Input()` for configuration — width, height, shape — so the same component works everywhere
- The difference between a **primitive** (SkeletonBlock) and a **composite** (PostCardSkeleton that uses SkeletonBlock multiple times)
- This is the same pattern as HTML: `<div>` is a primitive, a card layout is composite

### Tailwind — The `animate-pulse` Utility
- What `animate-pulse` does: fades the element's opacity between 100% and 40% in a loop
- It's built into Tailwind — no custom CSS needed
- Combined with `bg-gray-200 dark:bg-gray-700` creates the standard skeleton look
- `rounded-md` for rectangular skeletons, `rounded-full` for circular ones (avatars)
- 📖 Resource: [Tailwind — Animation](https://tailwindcss.com/docs/animation)

### Conditional Rendering with @if — Three States
- The "three states" pattern every data-loading component needs:
  - State 1: loading → show skeleton
  - State 2: empty → show empty state message
  - State 3: has data → show the real components
- Using `@if / @else if / @else` in Angular templates
- Why this is better than showing multiple things at once

### @for with a number array — Repeating N times
- Sometimes you want to render N skeletons without real data
- The pattern: `@for (n of [1,2,3]; track n)` — iterates over a literal array
- Useful for: 3 skeleton cards, 5 skeleton comments, etc.
- The `n` value has no meaning — you just need the loop to run N times

### The `[ngStyle]` Directive
- When Tailwind classes aren't enough (e.g., dynamic pixel values from `@Input()`)
- `[ngStyle]="{ width: '120px', height: '16px' }"` — inline style object
- `[style.width]="width"` — single-property binding shorthand
- When to use: only for truly dynamic values that can't be expressed as Tailwind classes

---

# PHASE 9 — Skeleton Loaders
### ⏱ Time estimate: 4–5 hours | 🧠 New concept: Reusable loading components

## What you'll build
- A generic `SkeletonBlock` component (configurable width, height, shape)
- Specific skeleton layouts for: PostCard, Profile header, Story bar, Comments
- Replace every `@if (loading())` spinner with a skeleton layout

## Why skeletons over spinners?

Spinners say "waiting". Skeletons say "content is coming and it looks like this". They reduce perceived loading time and prevent layout shift.

```
SPINNER approach:          SKELETON approach:
┌──────────────┐           ┌──────────────┐
│              │           │ ▓▓▓▓ ████████│ ← shimmer animation
│      ⟳       │           │ ████████████ │
│              │           │ ██████       │
└──────────────┘           └──────────────┘
```

## Pseudo-code hints

```typescript
// skeleton-block.ts — the primitive
@Component({
  selector: 'app-skeleton-block',
  standalone: true,
  template: `
    <div [class]="classes()"
         [ngStyle]="{ width: width, height: height }">
    </div>
  `
})
export class SkeletonBlock {
  @Input() width  = '100%'
  @Input() height = '16px'
  @Input() rounded = false   // true = circle (for avatars)
  @Input() className = ''    // extra Tailwind classes if needed

  classes = computed(() => {
    // hint: always include animate-pulse and bg-gray-200 dark:bg-gray-700
    // hint: if rounded, add rounded-full; else add rounded-md
    return `animate-pulse bg-gray-200 dark:bg-gray-700 
            ${this.rounded ? 'rounded-full' : 'rounded-md'} 
            ${this.className}`
  })
}
```

```typescript
// post-card-skeleton.ts — exact replica of PostCard's layout but with skeleton blocks
@Component({
  selector: 'app-post-card-skeleton',
  standalone: true,
  imports: [SkeletonBlock],
  template: `
    <!-- Copy PostCard's HTML structure exactly -->
    <!-- Replace every piece of real content with <app-skeleton-block> -->
    <!-- Avatar: <app-skeleton-block width="40px" height="40px" [rounded]="true"> -->
    <!-- Username: <app-skeleton-block width="120px" height="14px"> -->
    <!-- Image area: <app-skeleton-block width="100%" height="400px"> -->
    <!-- Caption: <app-skeleton-block width="80%" height="14px"> -->
  `
})
export class PostCardSkeleton {}
```

```html
<!-- In feed.html — using the skeleton: -->
@if (loading()) {
  <!-- Show 3 skeleton cards while loading -->
  @for (n of [1,2,3]; track n) {
    <app-post-card-skeleton></app-post-card-skeleton>
  }
} @else if (posts().length === 0) {
  <p class="text-center text-gray-500 py-10">No posts yet. Follow someone!</p>
} @else {
  @for (post of posts(); track post.id) {
    <app-post-card [post]="post" ...></app-post-card>
  }
}
```

## GitHub Tasks

```
Branch: feature/phase-09-skeletons
Commits:
  feat(shared): add SkeletonBlock primitive component
  feat(shared): add PostCardSkeleton layout
  feat(shared): add ProfileSkeleton layout
  feat(shared): add StoryBarSkeleton layout
  refactor(feed): replace spinner with PostCardSkeleton
  refactor(profile): replace spinner with ProfileSkeleton
PR: feature/phase-09-skeletons → develop
```

## Definition of Done
- [ ] No more spinners — every loading state shows a skeleton
- [ ] Skeleton shapes match the real content's layout (same spacing, same columns)
- [ ] `animate-pulse` gives the shimmer effect
- [ ] Dark mode skeleton colors work (darker gray on dark bg)

---

---

---

## 📚 Topics to Study or Review Before Phase 10

### Custom Attribute Directives — The Full Pattern
- The difference between a component (has template) and a directive (no template, modifies host element)
- `@Directive({ selector: '[appMyDirective]', standalone: true })`
- `inject(ElementRef)` — access the host DOM element
- `@Output()` in a directive — emitting events from the host element to the parent template
- `ngAfterViewInit` — the directive's template/DOM is ready here (important: `ngOnInit` is too early for DOM interaction)
- `ngOnDestroy` — always clean up: disconnect observers, clear timers
- 📖 Resource: Angular tutorial Part 5 (your guide) — Custom Directives section

### The IntersectionObserver Browser API
- What it does: watches an element and tells you when it enters or exits the viewport
- Why it's better than a `scroll` event listener: doesn't fire on every scroll pixel, uses a callback instead
- `new IntersectionObserver(callback, options)` — creating the observer
- `observer.observe(element)` — start watching a specific element
- `observer.disconnect()` — stop watching (must call in `ngOnDestroy`)
- The callback receives `entries[]` — check `entry.isIntersecting` to know if visible
- `threshold: 0.1` option — fires when 10% of the element enters the viewport
- 📖 Resource: [MDN — Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) (read the "Concepts" section)

### Pagination Patterns
- Offset pagination: `?page=1&limit=10` — "give me page 1, 10 items per page"
- Why infinite scroll needs APPEND logic, not REPLACE: `posts.update(prev => [...prev, ...newItems])`
- Detecting "end of data": if the API returns fewer items than `limit`, you've reached the last page
- The guard pattern: `if (loadingMore() || noMorePosts()) return` — prevent double-loading

### RxJS `switchMap` — Cancelling Previous Requests (review)
- `switchMap` cancels the previous inner Observable when a new value arrives
- This is critical for search and scroll: if the user triggers two loads quickly, only the latest one counts
- 📖 Resource: Angular tutorial Part 2 (your guide) — switchMap section

### Tailwind — Height and Overflow for Scroll Containers
- `h-screen` — full viewport height
- `overflow-y-auto` / `overflow-y-scroll` — enable vertical scroll
- `flex-1` — fills remaining space in a flex container (used in the main content area)
- Why the feed container needs a defined height or `overflow-y-auto` for scroll detection to work

---

# PHASE 10 — Infinite Scroll Feed
### ⏱ Time estimate: 5–6 hours | 🧠 New concept: Custom directive + IntersectionObserver API

## What you'll build
- A custom `InfiniteScrollDirective` that detects when the user reaches the bottom
- Pagination in the FeedPage — load more posts when sentinel element is visible
- A "loading more" indicator at the bottom
- A "no more posts" end-of-feed message

## New concept this phase: IntersectionObserver API

```typescript
// IntersectionObserver: native browser API
// It watches an element and tells you when it enters or leaves the viewport

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      // The watched element entered the viewport
      // → Load the next page of posts
    }
  })
}, {
  threshold: 0.1  // trigger when 10% of the element is visible
})

observer.observe(someElement)  // start watching
observer.disconnect()          // stop watching (call in ngOnDestroy!)
```

## Pseudo-code hints

```typescript
// infinite-scroll.directive.ts
@Directive({
  selector: '[appInfiniteScroll]',
  standalone: true,
})
export class InfiniteScrollDirective implements AfterViewInit, OnDestroy {
  @Output() scrolledToEnd = new EventEmitter<void>()
  @Input() threshold = 0.1    // how much of the element must be visible to trigger

  private observer: IntersectionObserver | null = null

  constructor(private el: ElementRef) {}

  ngAfterViewInit() {
    // hint: create IntersectionObserver
    // hint: in the callback, if entry.isIntersecting, emit scrolledToEnd
    // hint: observe this.el.nativeElement
  }

  ngOnDestroy() {
    // hint: always disconnect the observer to prevent memory leaks
  }
}
```

```html
<!-- feed.html — attach directive to a sentinel element at the bottom -->
<div class="feed-container">
  @for (post of posts(); track post.id) {
    <app-post-card [post]="post" ...></app-post-card>
  }

  <!-- This invisible div acts as the "trigger" -->
  <div appInfiniteScroll (scrolledToEnd)="loadMore()" class="h-4"></div>

  @if (loadingMore()) {
    <!-- Loading indicator for the NEXT page (not first load) -->
    <app-post-card-skeleton></app-post-card-skeleton>
  }

  @if (noMorePosts()) {
    <p class="text-center text-gray-400 py-6 text-sm">You're all caught up ✓</p>
  }
</div>
```

```typescript
// feed.ts additions
page = signal(1)
loadingMore = signal(false)
noMorePosts = signal(false)
PAGE_SIZE = 10

loadMore() {
  // hint: guard — don't load if already loading or no more posts
  if (this.loadingMore() || this.noMorePosts()) return

  const nextPage = this.page() + 1
  this.loadingMore.set(true)

  this.postService.getFeed(nextPage, this.PAGE_SIZE).subscribe({
    next: res => {
      // hint: APPEND to existing posts (don't replace them!)
      this.posts.update(current => [...current, ...res.data])
      this.page.set(nextPage)

      // hint: if fewer posts returned than PAGE_SIZE, we've reached the end
      if (res.data.length < this.PAGE_SIZE) {
        this.noMorePosts.set(true)
      }
      this.loadingMore.set(false)
    },
    error: () => { this.loadingMore.set(false) }
  })
}
```

## GitHub Tasks

```
Branch: feature/phase-10-infinite-scroll
Commits:
  feat(directives): add InfiniteScrollDirective using IntersectionObserver
  feat(feed): add pagination with infinite scroll
  feat(feed): add "no more posts" end-of-feed message
  fix(feed): prevent duplicate loads on rapid scroll
PR: feature/phase-10-infinite-scroll → develop
```

## Definition of Done
- [ ] Scrolling to the bottom of the feed loads the next page
- [ ] Posts APPEND to the list (no scroll reset)
- [ ] Loading skeleton appears at the bottom while next page loads
- [ ] "You're all caught up" shows after last page
- [ ] No duplicate loads if user scrolls up/down rapidly

---

---

---

## 📚 Topics to Study or Review Before Phase 11

### RxJS — interval() and startWith()
- `interval(ms)` — emits `0, 1, 2, 3...` every `ms` milliseconds, never stops
- `startWith(value)` — emits `value` immediately before the Observable starts
- Why you need `startWith(0)` with `interval`: without it, the first emission happens after the first interval (30 seconds wait before first poll — bad UX)
- `interval(30_000).pipe(startWith(0))` — fires immediately, then every 30 seconds
- 📖 Resource: [RxJS — interval](https://rxjs.dev/api/index/function/interval), [startWith](https://rxjs.dev/api/operators/startWith)

### BehaviorSubject — Shared Observable State
- `new BehaviorSubject<T>(initialValue)` — an Observable with a current value
- `.next(value)` — push a new value to all subscribers
- `.asObservable()` — expose as read-only Observable (components can subscribe but not push)
- `.getValue()` — synchronously read the current value
- Why `BehaviorSubject` for shared state: new subscribers immediately get the current value (unlike plain `Subject`)
- The pattern: service owns the `BehaviorSubject` (private), exposes `.asObservable()` (public)
- 📖 Resource: Angular tutorial Part 2 (your guide) — BehaviorSubject section

### RxJS `takeUntilDestroyed`
- The problem: if a component subscribes to a long-running Observable (like a poll), that subscription keeps running even after the component is destroyed — a memory leak
- The solution: `takeUntilDestroyed(destroyRef)` — automatically unsubscribes when the component/service destroys
- `inject(DestroyRef)` — get the destruction signal for the current context
- Angular 16+ only — use `takeUntil(this.destroy$)` pattern if on older Angular
- 📖 Resource: Angular tutorial Part 7 (your guide) — takeUntilDestroyed section

### The `async` Pipe
- `someObservable$ | async` — subscribes in the template, automatically unsubscribes on destroy
- `(someObservable$ | async) as value` — assigns the emitted value to a local template variable
- Why it's safer than subscribing in `ngOnInit`: no manual unsubscribe needed
- Works with both Observables and Promises
- 📖 Resource: Angular tutorial Part 2 (your guide) — async pipe section

### Notification UX Patterns
- What "unread count badge" means in UI: the red bubble on the bell icon
- The `99+` pattern: cap at 99 for display (don't show `1,247 unread` — just `99+`)
- "Mark all read" vs "mark one read" — implement the simpler one first
- Unread items get a highlight (slightly different background) to draw attention

---

# PHASE 11 — Real-Time Notifications
### ⏱ Time estimate: 5–7 hours | 🧠 New concept: RxJS polling + BehaviorSubject for shared state

## What you'll build
- `NotificationService` that polls the API every 30 seconds
- Notification bell in navbar with unread count badge
- `/notifications` page with full notification list
- Mark as read behavior

## New concept this phase: Polling with RxJS

```typescript
// The polling pattern — used everywhere for "soft real-time":
import { interval, switchMap, startWith, takeUntilDestroyed } from 'rxjs'

// Poll every 30 seconds:
interval(30_000).pipe(
  startWith(0),         // emit immediately (don't wait 30s for first load)
  switchMap(() => this.http.get('/api/notifications/unread-count'))
  // switchMap: if the previous HTTP call hasn't finished, cancel it
  // (prevents piling up requests if server is slow)
)
```

## Pseudo-code hints

```typescript
// notification.model.ts
export interface Notification {
  id: string
  type: 'like' | 'comment' | 'follow' | 'mention'
  actor: {      // the user who did the action
    username: string
    avatarUrl: string
  }
  post?: {      // the post involved (if any)
    id: string
    thumbnailUrl: string
  }
  isRead: boolean
  createdAt: string
  // hint: a computed text based on type:
  // 'like'    → "liked your post"
  // 'comment' → "commented: [first 30 chars]"
  // 'follow'  → "started following you"
  // 'mention' → "mentioned you in a comment"
}
```

```typescript
// notification.service.ts
@Injectable({ providedIn: 'root' })
export class NotificationService {
  private http = inject(HttpClient)
  private api = `${environment.apiUrl}/notifications`

  // BehaviorSubject: shared state — navbar AND notification page subscribe to this
  private unreadCount$ = new BehaviorSubject<number>(0)
  readonly unreadCount = this.unreadCount$.asObservable()

  private destroyRef = inject(DestroyRef)

  constructor() {
    // Start polling as soon as service is created (it's a singleton)
    this.startPolling()
  }

  private startPolling() {
    interval(30_000).pipe(
      startWith(0),
      switchMap(() => this.getUnreadCount()),
      takeUntilDestroyed(this.destroyRef)
    ).subscribe(count => {
      this.unreadCount$.next(count)
    })
  }

  getUnreadCount(): Observable<number> {
    // hint: GET /notifications/unread-count → returns { count: number }
    // hint: map to just the number
    // hint: catchError → return of(0) (don't break polling if one request fails)
  }

  getNotifications(): Observable<ApiResponse<Notification[]>> {
    // hint: GET /notifications
  }

  markAllRead(): Observable<void> {
    // hint: PATCH /notifications/read-all
    // hint: after success, set unreadCount$ to 0
  }
}
```

```html
<!-- navbar.html — notification bell with badge -->
<a routerLink="/notifications" class="relative">
  <!-- Bell icon (use any icon library or SVG) -->
  <svg ...></svg>

  <!-- Badge — only show if unreadCount > 0 -->
  @if ((notificationService.unreadCount | async) as count) {
    @if (count > 0) {
      <span class="absolute -top-1 -right-1 
                   bg-red-500 text-white text-xs rounded-full 
                   min-w-[18px] h-[18px] flex items-center justify-center px-1">
        {{ count > 99 ? '99+' : count }}
      </span>
    }
  }
</a>
```

```html
<!-- notifications.html — the full page -->
<!--
  Header: "Notifications" + "Mark all read" button
  List of notifications, newest first:
  Each notification:
  ┌────────────────────────────────────────┐
  │ [avatar] username liked your post  [▪] │ ← thumbnail
  │          2 hours ago                   │
  └────────────────────────────────────────┘
  Unread = slightly highlighted bg
  Read = normal bg
-->
```

## GitHub Tasks

```
Branch: feature/phase-11-notifications
Commits:
  feat(notifications): add NotificationService with 30s polling
  feat(notifications): add unread badge on navbar bell icon
  feat(notifications): add notifications page with list
  feat(notifications): add mark all read functionality
PR: feature/phase-11-notifications → develop
```

## Definition of Done
- [ ] Navbar bell shows unread count badge
- [ ] Badge updates automatically every 30 seconds
- [ ] Clicking the bell navigates to `/notifications`
- [ ] Notifications list shows avatar, text, thumbnail, time ago
- [ ] "Mark all read" clears the badge and marks items as read
- [ ] Unread notifications have a subtle highlight
- [ ] Polling stops when user logs out (service + subject reset)

---

---

---

## 📚 Topics to Study or Review Before Phase 12

### What is a PWA? — Core Concepts
- A Progressive Web App is a website that behaves like a native app
- Three requirements to be installable: served over HTTPS, has a `manifest.webmanifest`, has a registered service worker
- `display: "standalone"` in the manifest — hides browser UI (address bar, nav buttons) when installed
- The install prompt: browsers show an "Add to Home Screen" button when PWA criteria are met
- 📖 Resource: [MDN — Progressive Web Apps](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps) (read the "Introduction" and "Installable" sections)

### Service Workers — What They Are
- A service worker is a JavaScript file that runs in the background, separate from your app
- It intercepts network requests and can serve cached responses when offline
- Lifecycle: `install` → `activate` → `fetch` (intercepts requests)
- Why Angular PWA does this for you: `@angular/pwa` generates the service worker code automatically
- You configure WHAT to cache in `ngsw-config.json`, Angular handles the HOW
- 📖 Resource: [Angular — Service Worker Introduction](https://angular.io/guide/service-worker-intro)

### `ng add @angular/pwa`
- What this command does automatically: generates `ngsw-config.json`, `manifest.webmanifest`, updates `index.html`, registers service worker in `app.config.ts`
- After running it, you MUST test with a production build — service workers don't run in `ng serve`
- Testing locally: `ng build --configuration=production` then `npx serve dist/...`
- 📖 Resource: [Angular — Getting started with Service Workers](https://angular.io/guide/service-worker-getting-started)

### The Web App Manifest
- `name` — full name shown on install prompt
- `short_name` — appears under the icon on home screen (keep it short: ≤12 chars)
- `start_url` — what URL opens when launched from home screen
- `display: "standalone"` — full-screen without browser chrome
- `background_color` — color of the splash screen while loading
- `theme_color` — color of the browser UI bar (on Android)
- `icons` — array of icons at different sizes (need 192×192 and 512×512 minimum)
- 📖 Resource: [MDN — Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)

### Lighthouse — Testing PWA Quality
- Chrome DevTools → Lighthouse tab → run a PWA audit
- It checks: installability, offline capability, icons, manifest, HTTPS
- Fix all red/orange items before considering the phase done
- 📖 Resource: [Lighthouse PWA Checklist](https://web.dev/pwa-checklist/)

### `ngsw-config.json` — Caching Strategy
- `assetGroups` — static files (JS, CSS, fonts, images): cache permanently
- `dataGroups` — API responses: use `"freshness"` (network-first) for dynamic data
- `installMode: "prefetch"` — cache during service worker installation
- `installMode: "lazy"` — cache only when first requested

---

# PHASE 12 — PWA: Installable on Phone
### ⏱ Time estimate: 3–4 hours | 🧠 New concept: Angular PWA + Service Worker

## What you'll build
- Web App Manifest (name, icon, theme color)
- Service Worker (Angular PWA)
- Install prompt handling
- Offline fallback page

## New concept this phase: PWA

A Progressive Web App is a website that behaves like a native app. It can be installed to the home screen, works partially offline, and gets updates automatically.

```bash
# Add Angular PWA (run this in your project):
ng add @angular/pwa

# This automatically:
# 1. Creates ngsw-config.json (service worker config)
# 2. Creates src/manifest.webmanifest
# 3. Adds <link rel="manifest"> to index.html
# 4. Registers the service worker in app.config.ts
```

## Pseudo-code hints

```json
// manifest.webmanifest — customize these values
{
  "name": "SnapGrid",
  "short_name": "SnapGrid",
  "description": "Share your world through photos",
  "start_url": "/feed",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    // hint: you need icons at 72, 96, 128, 144, 152, 192, 384, 512px
    // use a simple logo generator or draw a letter "S" with a canvas tool
    { "src": "icons/icon-192x192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/icon-512x512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

```json
// ngsw-config.json — what to cache
{
  "index": "/index.html",
  "assetGroups": [
    {
      "name": "app",
      "installMode": "prefetch",
      "resources": {
        "files": ["/favicon.ico", "/index.html", "/*.css", "/*.js"]
      }
    }
  ],
  "dataGroups": [
    {
      "name": "api-fresh",
      "urls": ["/api/feed"],
      "cacheConfig": {
        "maxSize": 100,
        "maxAge": "1d",
        "strategy": "freshness"
        // "freshness": try network first, fall back to cache
      }
    }
  ]
}
```

```typescript
// install-prompt.ts — optional but great UX
// A small banner that appears when the browser's install criteria are met
@Component({
  selector: 'app-install-prompt',
  standalone: true,
  template: `
    @if (showPrompt()) {
      <div class="fixed bottom-4 left-4 right-4 bg-white dark:bg-gray-800 
                  rounded-2xl shadow-xl p-4 flex items-center gap-3 z-50">
        <img src="icons/icon-72x72.png" class="w-12 h-12 rounded-xl" />
        <div class="flex-1">
          <p class="font-semibold text-sm">Add SnapGrid to Home Screen</p>
          <p class="text-xs text-gray-500">Get the full app experience</p>
        </div>
        <button (click)="install()" class="...">Add</button>
        <button (click)="dismiss()" class="...">✕</button>
      </div>
    }
  `
})
export class InstallPrompt {
  showPrompt = signal(false)
  private deferredPrompt: any = null

  constructor() {
    // The browser fires 'beforeinstallprompt' when install criteria are met:
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()    // prevent automatic prompt
      this.deferredPrompt = e
      this.showPrompt.set(true)
    })
  }

  install() {
    this.deferredPrompt?.prompt()
    this.showPrompt.set(false)
  }

  dismiss() {
    this.showPrompt.set(false)
  }
}
```

## GitHub Tasks

```
Branch: feature/phase-12-pwa
Commits:
  chore: add @angular/pwa service worker
  feat(pwa): configure manifest with icons and theme color
  feat(pwa): configure ngsw caching for app shell and API
  feat(pwa): add install prompt banner component
PR: feature/phase-12-pwa → develop
```

## Definition of Done
- [ ] `ng build --configuration=production && npx serve dist/...` — app is installable
- [ ] Chrome DevTools → Application → Manifest shows correct values
- [ ] Chrome DevTools → Application → Service Workers shows "Activated and running"
- [ ] Install prompt appears on Chrome mobile
- [ ] After install, app opens in standalone mode (no browser chrome)
- [ ] Lighthouse score → PWA section shows green checks

---

---

---

---

# PHASE 13 — Explore Page with Live Search
### ⏱ Time estimate: 6–7 hours | 🧠 New concepts: debounceTime + switchMap search, tab navigation

## What you'll build
- A full `/explore` page replacing the current placeholder
- Three tabs: **Trending** (grid of popular posts), **People** (user search results), **Tags** (hashtag search)
- A search bar at the top — live search fires as the user types (debounced)
- Skeleton loading for each tab's content
- Clicking a post opens its detail page; clicking a user opens their profile

## Why this phase is important

The live search pattern — `debounceTime(300) → distinctUntilChanged() → switchMap` — is the single most common Angular interview question for junior roles. Building it in a real feature means you understand it deeply, not just by reading.

## Pseudo-code hints

```typescript
// explore.ts
export class Explore {
  private exploreService = inject(ExploreService)

  searchControl = new FormControl('')
  activeTab = signal<'trending' | 'people' | 'tags'>('trending')

  // Trending posts — loaded once on init:
  trendingPosts   = signal<Post[]>([])
  trendingLoading = signal(true)

  // Search results — reactive to search input:
  searchResults = signal<Post[] | User[]>([])
  searchLoading = signal(false)
  hasSearched   = signal(false)  // true once user has typed something

  // The search Observable — built from the FormControl:
  private search$ = this.searchControl.valueChanges.pipe(
    debounceTime(300),
    // hint: wait 300ms after the user stops typing before firing
    distinctUntilChanged(),
    // hint: don't search if the query is the same as the last one
    tap(query => {
      this.hasSearched.set((query?.trim().length ?? 0) > 0)
      this.searchLoading.set(true)
      this.searchResults.set([])
    }),
    switchMap(query => {
      // hint: if query is empty or whitespace, return of([]) immediately
      if (!query?.trim()) return of([])

      // hint: search based on active tab
      return this.exploreService.search(query, this.activeTab()).pipe(
        catchError(() => of([]))
      )
    })
  )

  ngOnInit() {
    // hint: load trending posts
    // hint: subscribe to search$ and update searchResults + searchLoading
    // hint: use takeUntilDestroyed
  }

  switchTab(tab: 'trending' | 'people' | 'tags') {
    this.activeTab.set(tab)
    // hint: re-trigger search for the new tab if there's a current query
    // hint: you can do this by calling updateValueAndValidity() on the control
    this.searchControl.updateValueAndValidity({ emitEvent: true })
  }
}
```

```typescript
// explore.service.ts
@Injectable({ providedIn: 'root' })
export class ExploreService {
  private http = inject(HttpClient)
  private api = `${environment.apiUrl}/explore`

  getTrending(): Observable<ApiResponse<Post[]>> {
    // hint: GET /explore/posts
  }

  search(query: string, type: 'trending' | 'people' | 'tags'): Observable<ApiResponse<Post[] | User[]>> {
    // hint: GET /explore/search?q=query&type=type
  }

  getTrendingHashtags(): Observable<ApiResponse<Hashtag[]>> {
    // hint: GET /explore/hashtags/trending
  }
}
```

```html
<!-- explore.html — layout hint -->
<!--
  Sticky search bar at top:
  <input type="search" [formControl]="searchControl"
         placeholder="Search people, posts, tags..."
         class="sticky top-0 w-full ..." />

  Tab bar (only show when not searching):
  @if (!hasSearched()) {
    <div class="flex border-b border-gray-200">
      <button (click)="switchTab('trending')" ...>Trending</button>
      <button (click)="switchTab('people')"   ...>People</button>
      <button (click)="switchTab('tags')"     ...>Tags</button>
    </div>
  }

  Content area:
  @if (searchLoading()) {
    <app-explore-skeleton></app-explore-skeleton>
  } @else if (hasSearched() && searchResults().length === 0) {
    <p class="text-center ...">No results for "{{ searchControl.value }}"</p>
  } @else if (hasSearched()) {
    <!-- render search results -->
  } @else {
    <!-- render trending content for active tab -->
  }
-->
```

## 👨‍💻 Senior Dev Code Review — Phase 13

**Comment on `switchTab()`:**
> 💬 Calling `updateValueAndValidity({ emitEvent: true })` to re-trigger the search when switching tabs is clever — but it's a side-effect hack. A cleaner approach: use `combineLatest([this.searchControl.valueChanges, this.activeTab$])` where `activeTab$` is a Subject. Then the search automatically re-runs whenever either changes.

**Comment on search debounce:**
> ✅ `debounceTime(300)` + `distinctUntilChanged()` + `switchMap` is exactly correct. This is the canonical Angular search pattern. Note for your portfolio: be ready to explain in an interview why `mergeMap` would break this (it doesn't cancel previous requests — you'd see results flicker and arrive out of order).

**Comment on empty state:**
> ⚠️ "No results for X" only appears after a search. What about the initial load of trending posts failing? Add an error signal and show "Couldn't load trending content. Tap to retry" with a retry button.

## GitHub Tasks

```
Branch: feature/phase-13-explore
Issue:  [Phase 13] Explore Page with Live Search
Commits:
  feat(explore): add explore page with trending posts grid
  feat(explore): add live search with debounce and switchMap
  feat(explore): add tab navigation (trending / people / tags)
  feat(explore): add hashtag search and trending tags display
  feat(explore): add skeleton loading per tab
PR: feature/phase-13-explore → develop
```

## Definition of Done
- [ ] Explore page shows trending posts in a grid (same 3-col as profile)
- [ ] Search bar debounces — network tab shows requests only fire 300ms after typing stops
- [ ] Switching tab with an active query re-runs the search for that tab
- [ ] `switchMap` cancels previous request — verify in network tab (previous request shows "canceled")
- [ ] Empty state shown when no results
- [ ] Clicking a result navigates to the correct page
- [ ] Skeleton loading shown while search is in flight

---

---

# PHASE 14 — Edit Profile Page
### ⏱ Time estimate: 5–6 hours | 🧠 New concepts: PATCH requests, avatar upload with preview, form pre-fill

## What you'll build
- `/profile/edit` route, accessible from the "Edit Profile" button on your own profile
- Form pre-filled with the current user's data (username, bio, website, name)
- Avatar upload with circular image preview (same `URL.createObjectURL` pattern as Phase 3.5)
- Save button with loading state and success feedback
- Guard: only the logged-in user can access this page — any other username redirects away

## New concept: Image Crop Preview (circular avatar)

```typescript
// The avatar preview needs to show as a circle regardless of the original image's shape:
```
```html
<!-- Circular avatar preview using Tailwind: -->
<div class="relative w-24 h-24 mx-auto">
  <img [src]="avatarPreview() ?? currentUser()?.avatarUrl"
       class="w-24 h-24 rounded-full object-cover object-center
              ring-2 ring-gray-200 dark:ring-gray-700"
       alt="Avatar preview" />

  <!-- Click overlay to change: -->
  <button (click)="avatarInput.click()"
          class="absolute inset-0 rounded-full bg-black/40 opacity-0
                 hover:opacity-100 flex items-center justify-center
                 transition-opacity text-white text-xs font-medium">
    Change
  </button>
</div>

<input type="file" accept="image/*" #avatarInput class="hidden"
       (change)="onAvatarSelected($event)" />
```

## Pseudo-code hints

```typescript
// edit-profile.ts
export class EditProfile implements OnInit, OnDestroy {
  private userService  = inject(UserService)
  private authService  = inject(AuthService)
  private router       = inject(Router)
  private toastService = inject(ToastService)

  private fb = inject(FormBuilder)

  currentUser = signal<User | null>(null)
  saving      = signal(false)
  avatarFile  = signal<File | null>(null)
  avatarPreview = signal<string | null>(null)

  editForm = this.fb.group({
    firstName: ['', [Validators.required, Validators.maxLength(50)]],
    lastName:  ['', [Validators.required, Validators.maxLength(50)]],
    username:  ['', [Validators.required, Validators.minLength(3),
                     Validators.pattern('^[a-zA-Z0-9._]+$')]],
                     // hint: only letters, numbers, dots, underscores — like Instagram
    bio:       ['', [Validators.maxLength(150)]],
    website:   ['', [Validators.pattern('https?://.+')]],
    // hint: website must start with http:// or https://
  })

  ngOnInit() {
    const user = this.authService.getCurrentUser()
    if (!user) { this.router.navigate(['/feed']); return }

    this.currentUser.set(user)
    // hint: pre-fill the form with the current user's data using patchValue
    this.editForm.patchValue({
      firstName: user.firstName,
      // hint: fill in the rest
    })
  }

  onAvatarSelected(event: Event) {
    // hint: same validation as Phase 3.5 (type + size)
    // hint: set avatarPreview signal with URL.createObjectURL
  }

  async save() {
    this.editForm.markAllAsTouched()
    if (this.editForm.invalid) return
    if (this.saving()) return

    this.saving.set(true)

    // Step 1: upload avatar if changed (separate endpoint)
    if (this.avatarFile()) {
      // hint: POST to /users/me/avatar with FormData
      // hint: on success, update the stored user's avatarUrl
    }

    // Step 2: save profile data
    this.userService.updateProfile(this.editForm.value).subscribe({
      next: res => {
        // hint: update the stored user in AuthService
        // hint: show success toast
        // hint: navigate back to /profile/:username
        this.toastService.success('Profile updated successfully')
        this.router.navigate(['/profile', res.data.username])
      },
      error: err => {
        // hint: check for field-specific errors (e.g. username taken)
        if (err.error?.field === 'username') {
          this.editForm.get('username')?.setErrors({ taken: true })
        }
        this.saving.set(false)
      }
    })
  }

  ngOnDestroy() {
    if (this.avatarPreview()) URL.revokeObjectURL(this.avatarPreview()!)
  }
}
```

## 👨‍💻 Senior Dev Code Review — Phase 14

**Comment on the two-step save:**
> 💬 Avatar upload and profile data are two separate API calls — which means they can partially succeed. If the avatar uploads but the profile save fails, the user has a new avatar but their name is unchanged. This is a real UX problem. Consider uploading the avatar as part of the profile PATCH (one request) if your API supports it, or add a rollback mechanism.

**Comment on username validation:**
> ✅ The regex `^[a-zA-Z0-9._]+$` is correct and matches Instagram's rules. Adding `Validators.pattern` here is the right place. Also consider an async validator that checks username availability against the API — same pattern as the email availability check in your Angular tutorial.

**Comment on `patchValue` pre-fill:**
> ⚠️ Pre-filling works, but `getCurrentUser()` reads from the JWT payload — it might be stale if the user edited their profile from another device. Consider fetching fresh data from `GET /auth/me` in `ngOnInit` and pre-filling from the API response instead.

## GitHub Tasks

```
Branch: feature/phase-14-edit-profile
Issue:  [Phase 14] Edit Profile Page
Commits:
  feat(profile): add edit profile page with pre-filled form
  feat(profile): add circular avatar preview and upload
  feat(profile): add username availability async validator
  fix(profile): revoke avatar object URL in ngOnDestroy
PR: feature/phase-14-edit-profile → develop
```

## Definition of Done
- [ ] `/profile/edit` is guarded — only accessible when logged in
- [ ] Form is pre-filled with current user data on load
- [ ] Username field validates: letters, numbers, dots, underscores only
- [ ] Bio shows character count (150 limit)
- [ ] Avatar picker shows circular preview
- [ ] Saving shows loading state on the button
- [ ] Success navigates back to the profile page
- [ ] Field-specific server errors display on the correct input
- [ ] `URL.revokeObjectURL` is called on destroy

---

---

# PHASE 15 — Unit Test Retrospective
### ⏱ Time estimate: 8–10 hours | 🧠 Concepts: Jasmine, TestBed, HttpTestingController, test coverage

## What you'll do

Go back through the completed app and write unit tests for the most critical parts. The goal is **not** 100% coverage — it's learning to test the things that matter most and building the habit.

**Coverage target:** 70%+ on services, 60%+ on components, 100% on pipes and guards.

## What to test and in what order

### Round 1 — Pipes (easiest — no TestBed needed)

Start here because pipes are pure functions. No Angular DI, no mocking, no async.

```typescript
// time-ago.pipe.spec.ts — your first test file
describe('TimeAgoPipe', () => {
  let pipe: TimeAgoPipe

  beforeEach(() => { pipe = new TimeAgoPipe() })

  it('returns "just now" for dates less than 60 seconds ago', () => {
    const recent = new Date(Date.now() - 30_000).toISOString()  // 30 seconds ago
    expect(pipe.transform(recent)).toBe('just now')
  })

  it('returns "X minutes ago" for dates less than an hour ago', () => {
    const fiveMin = new Date(Date.now() - 5 * 60_000).toISOString()
    expect(pipe.transform(fiveMin)).toBe('5 minutes ago')
  })

  it('returns "X hours ago" for dates less than a day ago', () => {
    const twoHours = new Date(Date.now() - 2 * 60 * 60_000).toISOString()
    expect(pipe.transform(twoHours)).toBe('2 hours ago')
  })

  it('handles null/undefined input gracefully', () => {
    expect(pipe.transform(null as any)).toBe('')
    expect(pipe.transform(undefined as any)).toBe('')
  })
})
```

### Round 2 — Guards

```typescript
// auth.guard.spec.ts
describe('authGuard', () => {
  let authSpy: jasmine.SpyObj<AuthService>
  let routerSpy: jasmine.SpyObj<Router>

  beforeEach(() => {
    authSpy   = jasmine.createSpyObj('AuthService', ['isLoggedIn'])
    routerSpy = jasmine.createSpyObj('Router', ['createUrlTree'])
    routerSpy.createUrlTree.and.callFake((cmds: any[]) => cmds)

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authSpy },
        { provide: Router,      useValue: routerSpy }
      ]
    })
  })

  it('returns true when logged in', () => {
    authSpy.isLoggedIn.and.returnValue(true)
    const result = TestBed.runInInjectionContext(() => authGuard({} as any, {} as any))
    expect(result).toBeTrue()
  })

  it('redirects to /auth/login when not logged in', () => {
    authSpy.isLoggedIn.and.returnValue(false)
    TestBed.runInInjectionContext(() => authGuard({} as any, {} as any))
    expect(routerSpy.createUrlTree).toHaveBeenCalledWith(['/auth/login'])
  })
})
```

### Round 3 — Services

```typescript
// auth.service.spec.ts — test the most critical service
describe('AuthService', () => {
  let service: AuthService
  let http: HttpTestingController

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [AuthService]
    })
    service = TestBed.inject(AuthService)
    http    = TestBed.inject(HttpTestingController)
    localStorage.clear()
  })

  afterEach(() => { http.verify(); localStorage.clear() })

  describe('login()', () => {
    it('stores token in localStorage on success', () => {
      service.login('k@test.com', 'pw').subscribe()
      http.expectOne(`${environment.apiUrl}/auth/login`)
          .flush({ success: true, data: { token: 'abc.eyJleHAiOjk5OTk5OTk5OX0K.sig' } })
      expect(localStorage.getItem('snapgrid_token')).toBe('abc.eyJleHAiOjk5OTk5OTk5OX0K.sig')
    })

    it('emits true on authStatus$ after login', () => {
      let emitted = false
      service.authStatus$.subscribe(v => emitted = v)
      service.login('k@test.com', 'pw').subscribe()
      http.expectOne(`${environment.apiUrl}/auth/login`)
          .flush({ success: true, data: { token: 'abc.def.ghi' } })
      expect(emitted).toBeTrue()
    })

    it('propagates error without storing token', () => {
      let error: any
      service.login('bad@email.com', 'wrong').subscribe({ error: e => error = e })
      http.expectOne(`${environment.apiUrl}/auth/login`)
          .flush({ message: 'Invalid credentials' }, { status: 401, statusText: 'Unauthorized' })
      expect(error.status).toBe(401)
      expect(localStorage.getItem('snapgrid_token')).toBeNull()
    })
  })

  describe('logout()', () => {
    it('clears token and emits false', () => {
      localStorage.setItem('snapgrid_token', 'some-token')
      let emitted: boolean | undefined
      service.authStatus$.subscribe(v => emitted = v)
      service.logout()
      expect(localStorage.getItem('snapgrid_token')).toBeNull()
      expect(emitted).toBeFalse()
    })
  })
})
```

### Round 4 — Components

```typescript
// post-card.spec.ts — test the most important visual component
describe('PostCard Component', () => {
  let component: PostCard
  let fixture: ComponentFixture<PostCard>

  const mockPost: Post = {
    id: '1', imageUrl: '/test.jpg', caption: 'Test post',
    likesCount: 42, commentsCount: 3,
    isLiked: false, isSaved: false,
    createdAt: new Date(Date.now() - 60_000).toISOString(),
    author: { username: 'tester', avatarUrl: '/avatar.jpg', isVerified: false }
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PostCard],
      providers: [provideNoopAnimations()]
    }).compileComponents()

    fixture   = TestBed.createComponent(PostCard)
    component = fixture.componentInstance
    component.post = mockPost
    fixture.detectChanges()
  })

  it('displays the post image', () => {
    const img = fixture.nativeElement.querySelector('img[data-testid="post-image"]')
    expect(img?.src).toContain('/test.jpg')
  })

  it('displays the username', () => {
    const username = fixture.nativeElement.querySelector('[data-testid="post-username"]')
    expect(username?.textContent?.trim()).toBe('tester')
  })

  it('toggles like state when heart is clicked', () => {
    const likeBtn = fixture.nativeElement.querySelector('[data-testid="like-btn"]')
    likeBtn.click()
    expect(component.isLiked()).toBeTrue()
    expect(component.likesCount()).toBe(43)
  })

  it('emits likeToggled event when heart is clicked', () => {
    let emitted: any
    component.likeToggled.subscribe(v => emitted = v)
    fixture.nativeElement.querySelector('[data-testid="like-btn"]').click()
    expect(emitted).toEqual({ postId: '1', liked: true })
  })

  it('shows correct likes count', () => {
    const count = fixture.nativeElement.querySelector('[data-testid="likes-count"]')
    expect(count?.textContent).toContain('42')
  })
})
```

### Round 5 — The InfiniteScrollDirective

```typescript
// infinite-scroll.directive.spec.ts
describe('InfiniteScrollDirective', () => {
  it('emits scrolledToEnd when element enters viewport', () => {
    // hint: create a test host component that uses the directive
    // hint: manually trigger the IntersectionObserver callback
    // hint: verify scrolledToEnd was emitted

    // This is a harder test — look up "testing IntersectionObserver Angular"
    // The key: replace IntersectionObserver with a spy in tests
  })

  it('disconnects observer on destroy', () => {
    // hint: create component, get directive instance, call ngOnDestroy
    // hint: verify disconnect() was called on the observer
  })
})
```

## Running Coverage

```bash
# Run all tests with coverage:
ng test --code-coverage --watch=false --browsers=ChromeHeadless

# Open the report:
open coverage/index.html    # macOS
start coverage/index.html   # Windows
```

Look at the report. Find any file under 60% that isn't a model/interface. Add tests until it's green.

## 👨‍💻 Senior Dev Code Review — Phase 15

**Comment on test organization:**
> 💬 Your tests are all in `.spec.ts` files next to the source files — correct. Don't put them in a separate `tests/` folder. Co-location means when you rename or move a component, the spec file goes with it automatically.

**Comment on mock data:**
> ⚠️ You've copy-pasted the `mockPost` object in three different spec files. Extract it to `src/app/core/mocks/post.mock.ts` and import it. Same for `mockUser`. Duplication in tests is as bad as duplication in source code.

**Comment on what NOT to test:**
> ✅ I see you skipped testing the `ThemeService.applyTheme()` private method directly. Correct — never test private methods. Test the observable behavior: "when `toggle()` is called, does the `dark` class appear on `document.documentElement`?"

## GitHub Tasks

```
Branch: feature/phase-15-tests
Issue:  [Phase 15] Unit Test Retrospective
Commits:
  test(pipes): add TimeAgoPipe and ShortNumberPipe specs
  test(guards): add authGuard and guestGuard specs
  test(services): add AuthService spec with HttpTestingController
  test(services): add ToastService spec
  test(components): add PostCard component spec
  test(directives): add InfiniteScrollDirective spec
  test(coverage): reach 70% coverage on services
PR: feature/phase-15-tests → develop
```

## Definition of Done
- [ ] `ng test --watch=false` shows 0 failures
- [ ] All pipes have 100% coverage
- [ ] All guards have 100% coverage
- [ ] `AuthService` has 70%+ coverage
- [ ] `PostCard` component has 60%+ coverage
- [ ] `InfiniteScrollDirective` has at least a working test
- [ ] Coverage report is generated and reviewed
- [ ] Mock data is extracted to a shared `mocks/` folder

---

---

# 📊 Project Overview Summary

| Phase | Feature | New Angular Concept | Time |
|---|---|---|---|
| 0 | Setup + GitHub + CI workflow | Angular CLI, Git, GitHub Actions | 2–3h |
| 1 | Auth pages | Tailwind CSS utility-first | 4–6h |
| 2 | App shell + routing | Layout components, lazy loading | 5–7h |
| 3 | Feed + PostCard | @Input/@Output, signals, pipes | 6–8h |
| **3.5** | **Create Post** | **File input, FormData, upload progress** | **5–6h** |
| 4 | Profile page | Route params, computed signals | 5–7h |
| 5 | Post detail + comments | HTTP services, two-pane layout | 5–6h |
| 6 | Real API integration | HTTP error handling, interceptors | 4–5h |
| **6.5** | **Error boundary + Toast** | **ErrorHandler, global UX, offline detection** | **3–4h** |
| 7 | Stories | Angular Animations, @defer | 6–8h |
| 8 | Dark mode + RTL | Global state services | 5–7h |
| 9 | Skeleton loaders | Reusable components | 4–5h |
| 10 | Infinite scroll | Custom directive, IntersectionObserver | 5–6h |
| 11 | Notifications | RxJS polling, BehaviorSubject | 5–7h |
| 12 | PWA | Service worker, web manifest | 3–4h |
| **13** | **Explore + Live Search** | **debounceTime + switchMap search pattern** | **6–7h** |
| **14** | **Edit Profile** | **PATCH, avatar upload, async validator** | **5–6h** |
| **15** | **Unit Test Retrospective** | **Jasmine, TestBed, coverage reporting** | **8–10h** |
| **Total** | | | **~102–121 hours** |

---

# 🎯 Concepts You'll Have Mastered at the End

```
Angular:
  ✅ Standalone components (every component)
  ✅ Reactive Forms with validation (auth pages)
  ✅ Signals and computed (feed, profile, stories)
  ✅ @Input / @Output / @ViewChild (PostCard, StoryViewer)
  ✅ Route parameters and guards (profile, post detail)
  ✅ Lazy loading (every route)
  ✅ HTTP services with error handling (all pages)
  ✅ Interceptors (token + error)
  ✅ Custom ErrorHandler (global error boundary)
  ✅ Custom directives (infinite scroll)
  ✅ Custom pipes (timeAgo, shortNumber)
  ✅ Angular Animations (story transitions, toast enter/leave)
  ✅ @defer blocks (story viewer)
  ✅ Change detection OnPush (PostCard)
  ✅ PWA + Service Worker
  ✅ Unit testing with Jasmine + TestBed (Phase 15)

TypeScript:
  ✅ Interfaces and type safety (all models)
  ✅ Generics (ApiResponse<T>)
  ✅ Computed properties
  ✅ Strict null checks
  ✅ Union types (ToastType, tab types)

Tailwind CSS:
  ✅ Utility-first methodology
  ✅ Responsive prefixes (sm/md/lg)
  ✅ Dark mode variants
  ✅ RTL-aware spacing (ps/pe/ms/me)
  ✅ Custom design tokens
  ✅ animate-pulse for skeletons

Browser APIs:
  ✅ IntersectionObserver (infinite scroll)
  ✅ FileReader / URL.createObjectURL (image upload)
  ✅ navigator.onLine + online/offline events (offline banner)
  ✅ crypto.randomUUID() (toast IDs)
  ✅ localStorage (theme + direction persistence)

Version Control & Workflow:
  ✅ Feature branching strategy
  ✅ Conventional commit messages
  ✅ Pull request workflow with review checklists
  ✅ GitHub Issues with acceptance criteria
  ✅ GitHub Actions CI pipeline
  ✅ Sprint-based development with retrospectives
  ✅ CHANGELOG.md documentation habit
  ✅ Mock API with json-server for parallel development
```

---

# 🚀 When You're Done — What's Next

After completing all 12 phases, your project will be a production-grade Angular application. To take it further:

1. **Add unit tests** for each service and component (Phase 8 of the Angular tutorial)
2. **Deploy to Vercel** — one command: `vercel --prod`
3. **Add Explore page** — search users, trending hashtags, browse posts by category
4. **Add Create Post** — image upload, filters, caption, location tagging
5. **Add Direct Messages** — WebSocket or SSE (real real-time, not polling)
6. **Add Reels/Videos** — video upload, playback, full-screen viewer

---

*Document version 1.0 | Start date: ________ | Target completion: ________*
*Remember: a slow, correct phase is worth more than a fast, broken one.*
