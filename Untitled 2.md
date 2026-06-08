# ITI M5 — Agent Session Playbook

> Copy-paste prompts for each session. English only. Nothing to figure out — just follow the steps.

  

---

  

## ⚙️ Before You Start Any Session — Settings Checklist

  

> Open `Cmd+,` → Agent → confirm these are set:

  

| Setting | Required Value |

|---------|---------------|
| Artifact Review Policy | `Request Review` |
| Terminal Command Auto Execution | `Request Review` |
| JavaScript Execution Policy | `Disabled` |

  

> If agent starts executing without showing a plan → **Cancel immediately** and re-check settings.

  

---

  

## Session 1 — Project Onboarding (Run once before anything else)

  

**Open:** Antigravity → Editor view

**Model:** Gemini 3.1 Pro (High)

**Agent Mode:** `Plan`

**Skills:** `@laravel-expert @php-pro @postgres-best-practices`

  

**Prompt:**

  

```

/graphify

  

After the graph is built, answer these three questions from the graph only:

  

1. What columns exist in the `users` table? List them all.

2. What columns exist in the `attendance_records` table? List them all.

3. What columns exist in the `cohorts` and `lab_groups` tables? List them all.

  

I need exact column names before I write any foreign key references.

Save this output — I will use it in every migration I write today.

```

  

---

  

## Session 2 — Migrations

  

**Open:** Antigravity → Agent Manager → 2 parallel workspaces

**Both agents:** Gemini 3.5 Flash (Medium)

**Agent Mode:** `Fast`

**Skills (both agents):** `@laravel-expert @php-pro @database-migration @postgres-best-practices`

  

**Agent 1 Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

  

Task: Create migration file 0010_create_students_table.php

  

Rules:

- File path: database/migrations/0010_create_students_table.php

- Use PostgreSQL-compatible column types

- Columns: id (bigIncrements), user_id (FK → users, unique), cohort_id (FK → cohorts),

lab_group_id (FK → lab_groups, nullable), national_id (varchar, unique),

is_at_risk (boolean, default false), timestamps(), softDeletes()

- Add foreign key constraints with onDelete cascade where appropriate

- PHPDoc block at the top of the file

- Follow PSR-12

  

GitHub rules:

- You are on branch feat/excuse-student-migration

- Do NOT touch any file outside database/migrations/0010_create_students_table.php

- Do NOT run php artisan migrate — I will run it manually

- Stage the file and write a commit message: feat(m5): add students table migration

- Do NOT push — I will push manually after reviewing the diff

```

  

**Agent 2 Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

  

Task: Create three migration files for the M5 attendance ledger module

  

Rules:

- Use PostgreSQL-compatible column types

- PHPDoc block at the top of each file

- Follow PSR-12

  

File 1 — database/migrations/0014_create_attendance_ledgers_table.php

Columns: id, student_id (FK → students, unique), balance (int, default 250), timestamps()

  

File 2 — database/migrations/0015_create_attendance_ledger_entries_table.php

Columns: id, ledger_id (FK → attendance_ledgers), attendance_record_id (FK → attendance_records, nullable),

delta (int — can be negative), reason (varchar), balance_after (int), created_at (timestamp only — no updated_at, entries are immutable)

  

File 3 — database/migrations/0016_create_excuse_requests_table.php

Columns: id, student_id (FK → students), attendance_record_id (FK → attendance_records, unique — one excuse per record),

reason (text), attachment_path (varchar, nullable), status (PostgreSQL enum: requested / approved / rejected, default requested),

reviewed_by (FK → users, nullable), reviewed_at (timestamp, nullable), review_note (text, nullable), timestamps()

  

GitHub rules:

- You are on branch feat/excuse-ledger-migrations

- Do NOT touch any file outside database/migrations/0014*, 0015*, 0016*

- Do NOT run php artisan migrate — I will run it manually

- Stage the files and write commit: feat(m5): add ledger, ledger entries, and excuse requests migrations

- Do NOT push — I will push manually after reviewing the diff

```

  

---

  

## Session 3 — Models + Service Layer

  

**Open:** Antigravity → Editor view

**Model:** Claude Sonnet 4.6 (Thinking)

**Agent Mode:** `Plan`

**Skills:** `@laravel-expert @php-pro @backend-architect @spec-to-code-compliance`

  

**Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

Then run /graphify and confirm the existing migrations for students, attendance_ledgers,

attendance_ledger_entries, and excuse_requests are present before writing any model.

  

Task: Build all M5 models and the AttendanceLedgerService in this exact order.

  

--- 1. app/Models/Student.php ---

- fillable: user_id, cohort_id, lab_group_id, national_id, is_at_risk

- casts: is_at_risk as boolean

- relationships: belongsTo User, belongsTo Cohort, belongsTo LabGroup (nullable), hasOne AttendanceLedger

- booted() static method: on 'created' event → auto-create AttendanceLedger with balance = 250

- local scope: scopeAtRisk($query) → where is_at_risk = true

- PHPDoc on every method

  

--- 2. app/Models/AttendanceLedger.php ---

- fillable: student_id, balance

- relationships: belongsTo Student, hasMany AttendanceLedgerEntry

- PHPDoc on every method

  

--- 3. app/Models/AttendanceLedgerEntry.php ---

- fillable: ledger_id, attendance_record_id, delta, reason, balance_after

- casts: delta as integer, balance_after as integer

- relationships: belongsTo AttendanceLedger, belongsTo AttendanceRecord (nullable)

- Entries are immutable: override the save() method to throw a RuntimeException

if the model already exists in the database (no updates allowed, only inserts)

- PHPDoc on every method

  

--- 4. app/Models/ExcuseRequest.php ---

- fillable: student_id, attendance_record_id, reason, attachment_path, status, reviewed_by, reviewed_at, review_note

- casts: status as App\Enums\ExcuseStatus (create this enum: requested, approved, rejected)

- relationships: belongsTo Student, belongsTo AttendanceRecord, belongsTo User as reviewer

- helper methods: isApproved(), isRejected(), isPending() — return boolean

- PHPDoc on every method

  

--- 5. app/Enums/ExcuseStatus.php ---

- PHP 8.1 backed enum (string)

- Cases: Requested = 'requested', Approved = 'approved', Rejected = 'rejected'

  

--- 6. app/Services/AttendanceLedgerService.php ---

Methods in this order:

  

applyAbsenceDeduction(Student $student, AttendanceRecord $record): void

- Wrap in DB::transaction()

- Create one AttendanceLedgerEntry: delta = -25, reason = "unexcused_absence", balance_after = current balance - 25

- Update attendance_ledgers.balance = balance - 25

- Call checkAndFlagAtRisk($student) after

  

applyExcuseAdjustment(ExcuseRequest $excuse): void

- Wrap in DB::transaction()

- Find the existing AttendanceLedgerEntry where attendance_record_id = $excuse->attendance_record_id

- UPDATE that entry's delta from -25 to -5 (do NOT create a new entry)

- Recalculate ledger balance: sum all entry deltas for this ledger

- Update attendance_ledgers.balance with the recalculated value

- Call checkAndFlagAtRisk($excuse->student) after

  

recalculateBalance(AttendanceLedger $ledger): int

- Return sum of all delta values in attendance_ledger_entries for this ledger

- Do NOT update anything — read only

  

checkAndFlagAtRisk(Student $student): void

- Reload the student's ledger balance fresh from DB

- If balance < 150 → set student.is_at_risk = true and save

- If balance >= 150 → set student.is_at_risk = false and save

  

Constraints for all files:

- No hardcoded strings — use the ExcuseStatus enum and named constants

- No raw SQL — Eloquent only

- PHPDoc on every public method

- DB::transaction() on every method that writes to the database

  

GitHub rules:

- You are on branch feat/excuse-models-and-service

- Do NOT touch any file outside app/Models/ and app/Services/ and app/Enums/

- Do NOT run any artisan commands

- Stage all files and write commit: feat(m5): add Student, Ledger, ExcuseRequest models and AttendanceLedgerService

- Do NOT push — I will push manually after reviewing the diff

```

  

---

  

## Session 4 — Controllers + Endpoints

  

**Open:** Antigravity → Editor view

**Model:** Gemini 3.1 Pro (High)

**Agent Mode:** `Plan`

**Skills:** `@laravel-expert @php-pro @api-design-principles @auth-implementation-patterns @backend-dev-guidelines`

  

**Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

Run /graphify and confirm Student, AttendanceLedger, ExcuseRequest models

and AttendanceLedgerService exist in the codebase before writing any controller.

  

Task: Build three controllers in this exact order.

  

--- 1. app/Http/Controllers/StudentController.php ---

Methods:

- index: GET /api/cohorts/{cohort}/students — list students scoped to cohort, paginated, TA only

- store: POST /api/students — enroll a student in a cohort, TA only

- show: GET /api/students/{student} — student profile + current ledger balance

- update: PUT /api/students/{student} — update student fields, TA only

- assignLabGroup: PATCH /api/students/{student}/lab-group — assign student to a lab group, TA only

- atRisk: GET /api/students/at-risk — list students where is_at_risk = true

(Track Admin sees only their cohort, Branch Manager sees all)

  

--- 2. app/Http/Controllers/AttendanceLedgerController.php ---

Methods:

- show: GET /api/students/{student}/ledger — ledger balance + last 10 entries

- entries: GET /api/students/{student}/ledger/entries — full paginated entry history

  

--- 3. app/Http/Controllers/ExcuseRequestController.php ---

Methods:

- index: GET /api/excuse-requests

(Track Admin sees pending requests in their track, Student sees only their own)

- store: POST /api/excuse-requests — student submits excuse with optional file upload

- show: GET /api/excuse-requests/{excuseRequest}

- review: PATCH /api/excuse-requests/{excuseRequest}/review — TA approves or rejects

  

Constraints for all controllers:

- Use constructor injection for AttendanceLedgerService where needed

- No business logic in controllers — delegate everything to AttendanceLedgerService

- Return API Resources for all responses (create placeholder resources if they don't exist yet)

- Add auth:sanctum middleware to every route

- Add role-based middleware per method as described above

- PHPDoc on every method

  

GitHub rules:

- You are on branch feat/excuse-controllers

- Do NOT touch any file outside app/Http/Controllers/

- Do NOT run any artisan commands

- Stage all files and write commit: feat(m5): add StudentController, LedgerController, ExcuseRequestController

- Do NOT push — I will push manually after reviewing the diff

```

  

---

  

## Session 5 — FormRequests + File Upload + API Resources

  

**Open:** Antigravity → Editor view

**Model:** Claude Sonnet 4.6 (Thinking)

**Agent Mode:** `Plan`

**Skills:** `@laravel-expert @php-pro @file-uploads @laravel-security-audit @api-patterns`

  

**Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

  

Task: Build FormRequests, API Resources, and file upload logic for M5.

  

--- 1. app/Http/Requests/StoreStudentRequest.php ---

Rules: user_id required exists:users,id | cohort_id required exists:cohorts,id |

lab_group_id nullable exists:lab_groups,id | national_id required unique:students,national_id

  

--- 2. app/Http/Requests/StoreExcuseRequest.php ---

Rules:

- attendance_record_id: required, exists:attendance_records,id

- reason: required, string, max:500

- attachment: nullable, file, mimes:jpg,jpeg,png,pdf, max:1024 (1MB in kilobytes)

Custom messages for each rule in clear English.

  

--- 3. app/Http/Requests/ReviewExcuseRequest.php ---

Rules:

- decision: required, in:approved,rejected

- review_note: required_if:decision,rejected, string, max:500

  

--- 4. File upload logic — add to ExcuseRequestController@store ---

- If attachment is present: store to storage/app/excuses/{student_id}/{sanitized_original_filename}

- Use Storage::putFileAs()

- Store the relative path in excuse_requests.attachment_path

- Validate file size AND type server-side regardless of anything sent by the client [SEC-4]

  

--- 5. app/Http/Resources/StudentResource.php ---

Fields: id, national_id, is_at_risk, ledger balance (from relationship), cohort_id, lab_group_id,

created_at formatted as Y-m-d

  

--- 6. app/Http/Resources/LedgerResource.php ---

Fields: id, student_id, balance, last 10 entries as LedgerEntryResource collection

  

--- 7. app/Http/Resources/LedgerEntryResource.php ---

Fields: id, delta, reason, balance_after, created_at formatted as Y-m-d H:i

  

--- 8. app/Http/Resources/ExcuseRequestResource.php ---

Fields: id, student_id, attendance_record_id, reason, attachment_path, status (string label),

reviewed_by, reviewed_at, review_note, created_at

  

Constraints:

- PHPDoc on every class

- Never return raw model data — always use Resources

  

GitHub rules:

- You are on branch feat/excuse-requests-validation

- Do NOT touch files outside app/Http/Requests/ and app/Http/Resources/ and app/Http/Controllers/ExcuseRequestController.php

- Do NOT run any artisan commands

- Stage all files and write commit: feat(m5): add FormRequests, API Resources, and file upload logic

- Do NOT push — I will push manually after reviewing the diff

```

  

---

  

## Session 6 — Routes + Seeder

  

**Open:** Antigravity → Agent Manager → 2 parallel workspaces

**Both agents:** Gemini 3.5 Flash (Low)

**Agent Mode:** `Fast`

**Skills (both agents):** `@laravel-expert @php-pro`

  

**Agent 1 Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

  

Task: Add the M5 route block to routes/api.php

  

Find the existing routes/api.php file.

Add a clearly labeled block using this exact comment format:

  

// ===== M5 — Ledger & Excuses (Mohamed) =====

  

Then add these routes inside the block:

  

GET /api/cohorts/{cohort}/students → StudentController@index middleware: auth:sanctum, role:track_admin

POST /api/students → StudentController@store middleware: auth:sanctum, role:track_admin

GET /api/students/at-risk → StudentController@atRisk middleware: auth:sanctum, role:track_admin|branch_manager

GET /api/students/{student} → StudentController@show middleware: auth:sanctum

PUT /api/students/{student} → StudentController@update middleware: auth:sanctum, role:track_admin

PATCH /api/students/{student}/lab-group → StudentController@assignLabGroup middleware: auth:sanctum, role:track_admin

GET /api/students/{student}/ledger → AttendanceLedgerController@show middleware: auth:sanctum

GET /api/students/{student}/ledger/entries → AttendanceLedgerController@entries middleware: auth:sanctum

GET /api/excuse-requests → ExcuseRequestController@index middleware: auth:sanctum

POST /api/excuse-requests → ExcuseRequestController@store middleware: auth:sanctum, role:student

GET /api/excuse-requests/{excuseRequest} → ExcuseRequestController@show middleware: auth:sanctum

PATCH /api/excuse-requests/{excuseRequest}/review → ExcuseRequestController@review middleware: auth:sanctum, role:track_admin

  

Close the block with:

// ============================================

  

GitHub rules:

- You are on branch feat/excuse-routes

- Do NOT touch any other section of routes/api.php — only add inside the M5 block

- Stage the file and write commit: feat(m5): add M5 route block to api.php

- Do NOT push — I will push manually

```

  

**Agent 2 Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

  

Task: Create database/seeders/StudentSeeder.php

  

Requirements:

- Create 10 students for cohort_id = 1 (assume it exists from M2)

- Each student must be linked to a User — create the User inline with role = student

- Use Faker for: full English name, national_id as a unique 14-digit numeric string

- After creating each Student, the AttendanceLedger is auto-created by the model observer (balance = 250)

- For 3 of the 10 students: manually create 2–3 AttendanceLedgerEntry records

showing varied deductions so their balance drops below 150 (at-risk scenario)

- For those at-risk students: set is_at_risk = true on the Student model

- Seed realistic reasons in ledger entries: "unexcused_absence"

  

GitHub rules:

- You are on branch feat/excuse-seeder

- Do NOT touch any file outside database/seeders/StudentSeeder.php

- Do NOT run php artisan db:seed — I will run it manually

- Stage the file and write commit: feat(m5): add StudentSeeder with at-risk scenarios

- Do NOT push — I will push manually

```

  

---

  

## Session 7 — Pre-Merge Security Review

  

**Open:** Antigravity → Editor view

**Model:** Claude Sonnet 4.6 (Thinking)

**Agent Mode:** `Plan`

**Skills:** `@laravel-security-audit @api-security-best-practices @security-audit @verification-before-completion`

  

**Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

Run /graphify to load the full M5 codebase into context.

  

Task: Security and completeness review of all M5 files before merge.

  

Review these areas in order:

  

1. RBAC enforcement — confirm every endpoint has auth:sanctum + correct role middleware.

Flag any endpoint missing middleware.

  

2. File upload security — confirm attachment validation enforces:

- Max size: 1MB (1024 KB)

- Allowed types: jpg, jpeg, png, pdf only

- Server-side validation only — not relying on client input

Flag any gap.

  

3. Scope violations — confirm no M5 file touches tables outside:

students, attendance_ledgers, attendance_ledger_entries, excuse_requests.

Flag any FK reference or query targeting other tables without read-only justification.

  

4. Transaction safety — confirm every method in AttendanceLedgerService that writes to the DB

is wrapped in DB::transaction(). Flag any missing transaction.

  

5. Raw model exposure — confirm no controller returns a raw Eloquent model.

Every response must go through an API Resource. Flag any violation.

  

6. Completeness check — verify all deliverables in GEMINI.md Phase 1–6 are present in the codebase.

List any missing file or method.

  

Output: a numbered list of findings. For each finding: file path, line number if possible, issue, fix required.

If everything passes, say: "M5 is ready for testing."

  

GitHub rules:

- Do NOT modify any file during this session — read only

- After the review report is complete, I will fix any findings manually

```

  

---

  

## Session 8 — Endpoint Feature Tests

  

**Open:** Antigravity → Editor view

**Model:** Claude Sonnet 4.6 (Thinking)

**Agent Mode:** `Plan`

**Skills:** `@laravel-expert @php-pro @tdd-workflow @unit-testing-test-generate`

  

**Prompt:**

  

```

Read GEMINI.md for project context and M5 scope before doing anything.

Run /graphify to verify all M5 models and controllers exist in the codebase.

  

Task: Write PHPUnit Feature tests for all M5 endpoints.

  

Test setup — add to phpunit.xml if not already present:

<env name="DB_CONNECTION" value="sqlite"/>

<env name="DB_DATABASE" value=":memory:"/>

  

Test files to create:

- tests/Feature/M5/StudentTest.php

- tests/Feature/M5/AttendanceLedgerTest.php

- tests/Feature/M5/ExcuseRequestTest.php

  

All test classes must use: use RefreshDatabase;

All auth must use: Sanctum::actingAs($user)

All file tests must use: Storage::fake('local')

  

--- tests/Feature/M5/StudentTest.php ---

  

test_track_admin_can_list_students_in_their_cohort()

→ actingAs(TA user) → GET /api/cohorts/1/students → 200, returns paginated list

  

test_non_track_admin_cannot_list_students()

→ actingAs(student user) → GET /api/cohorts/1/students → 403

  

test_track_admin_can_create_student()

→ actingAs(TA) → POST /api/students with valid payload → 201

→ assert student exists in DB

→ assert attendance_ledger auto-created with balance=250

  

test_create_student_with_duplicate_national_id_fails()

→ create student with national_id="12345678901234"

→ POST again with same national_id → 422

  

test_student_can_view_own_profile()

→ actingAs(student) → GET /api/students/{own_id} → 200

  

test_at_risk_endpoint_returns_only_at_risk_students()

→ create 3 students: 2 normal, 1 with is_at_risk=true

→ actingAs(TA) → GET /api/students/at-risk → 200

→ assert response contains only 1 student

  

--- tests/Feature/M5/AttendanceLedgerTest.php ---

  

test_authenticated_user_can_view_own_ledger()

→ actingAs(student) → GET /api/students/{id}/ledger → 200

→ assert response has balance=250

  

test_ledger_starts_at_250()

→ create student → assert attendance_ledgers.balance = 250

  

test_apply_absence_deduction_reduces_balance_to_225()

→ create student (balance=250)

→ call AttendanceLedgerService::applyAbsenceDeduction()

→ assert balance = 225

→ assert one ledger_entry with delta=-25

  

test_approve_excuse_adjusts_balance_to_245()

→ create student (balance=250)

→ applyAbsenceDeduction() → balance=225

→ create ExcuseRequest with status=requested

→ approve the excuse (PATCH /api/excuse-requests/{id}/review with decision=approved)

→ assert balance = 245

→ assert ledger_entry delta changed from -25 to -5 (NOT a new entry created)

  

test_ledger_entries_paginate()

→ create 15 entries for one ledger

→ GET /api/students/{id}/ledger/entries → 200

→ assert response is paginated

  

--- tests/Feature/M5/ExcuseRequestTest.php ---

  

test_student_can_submit_excuse_without_attachment()

→ actingAs(student) → POST /api/excuse-requests with reason only → 201

→ assert excuse_request in DB with status=requested

  

test_student_can_submit_excuse_with_valid_jpg_attachment()

→ Storage::fake('local')

→ create fake jpg file (< 1MB)

→ POST /api/excuse-requests with attachment → 201

→ assert attachment_path saved in DB

  

test_attachment_over_1mb_is_rejected()

→ create fake file > 1MB → POST /api/excuse-requests → 422

  

test_attachment_with_invalid_mime_is_rejected()

→ create fake .exe file → POST /api/excuse-requests → 422

  

test_track_admin_can_approve_excuse()

→ create pending ExcuseRequest

→ actingAs(TA) → PATCH /api/excuse-requests/{id}/review {decision: "approved"} → 200

→ assert status = approved in DB

→ assert ledger delta = -5 (not -25)

→ assert balance = 245 (not 225)

  

test_track_admin_can_reject_excuse_with_note()

→ create pending ExcuseRequest

→ actingAs(TA) → PATCH with {decision: "rejected", review_note: "Invalid document"} → 200

→ assert status = rejected

→ assert ledger delta still = -25 (no change)

  

test_student_cannot_call_review_endpoint()

→ actingAs(student) → PATCH /api/excuse-requests/{id}/review → 403

  

test_double_excuse_on_same_attendance_record_is_rejected()

→ create ExcuseRequest for attendance_record_id=1

→ POST again with same attendance_record_id → 422

  

test_approved_excuse_cannot_be_reversed()

→ approve an excuse

→ PATCH again with {decision: "rejected"} → 422 (or 403)

→ assert status is still approved

  

Constraints:

- No hardcoded IDs — use factories or model::create() inside each test

- No real Supabase calls — SQLite :memory: only

- Each test is independent — no test depends on another test's data

- PHPDoc on every test method describing what it asserts

  

GitHub rules:

- You are on branch feat/excuse-feature-tests

- Do NOT touch any file outside tests/Feature/M5/ and phpunit.xml

- Do NOT run php artisan migrate — RefreshDatabase handles it with SQLite

- Stage all files and write commit: test(m5): add Feature tests for all M5 endpoints

- Do NOT push — I will push manually after running php artisan test locally

```

  

---

  

## Quick Reference — Model & Mode per Session

  

| Session | Model | Mode | Why |

|---------|-------|------|-----|

| 1 — Onboarding | Gemini 3.1 Pro (High) | Plan | Reading graph, FK discovery |

| 2 — Migrations | Gemini 3.5 Flash (Medium) | Fast | Schema-only, well-defined |

| 3 — Models + Service | Claude Sonnet 4.6 (Thinking) | Plan | Complex business logic |

| 4 — Controllers | Gemini 3.1 Pro (High) | Plan | Multi-file, auth wiring |

| 5 — Requests + Resources | Claude Sonnet 4.6 (Thinking) | Plan | Validation + security |

| 6 — Routes + Seeder | Gemini 3.5 Flash (Low) | Fast | Simple, isolated files |

| 7 — Security Review | Claude Sonnet 4.6 (Thinking) | Plan | Deep reasoning needed |

| 8 — Feature Tests | Claude Sonnet 4.6 (Thinking) | Plan | Test coverage reasoning |