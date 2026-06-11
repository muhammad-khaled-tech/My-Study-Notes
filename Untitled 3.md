# M5 Prompts — الـ 7 Sessions كاملة

> ITI Attendance & Grading Platform · Vue 3 · Antigravity IDE **كل prompt هنا جاهز للـ paste مباشرة في الـ Agent Panel** **v5.0 — updated against Postman collection (self-driving)**

---

## ⚠️ قبل كل session — 3 خطوات

```
1. Select the correct model from the dropdown (specified in each session header)
2. Paste the full prompt into the Agent Panel as one message
3. If the agent proposes to modify a file outside your ownership → stop it immediately
```

---

## ⚠️ REAL API ENDPOINTS — READ BEFORE ANY SESSION

```
Verified against Postman collection (self-driving). These are the ONLY real M5 endpoints:

AUTH
  POST /api/login                              → { token, user: { id, name, role, student_id, instructor_id, expires_at } }
  GET  /api/me                                 → { id, name, role, student_id, instructor_id, expires_at }
  POST /api/logout

  ⚠️ /me does NOT return cohort_id directly.
     After fetchMe(), call GET /api/students/{student_id} to get cohort_id.
  ✅ login response includes user.student_id directly — confirmed in Postman.

STUDENT
  GET  /api/students/{student}                 → student profile (includes cohort_id)
  GET  /api/students/{student}/ledger          → { balance, max, is_at_risk, ... }
  GET  /api/students/{student}/ledger/entries  → paginated [ { delta, balance_after, reason, ... } ]
  ⚠️  ledger/entries is NOT in the Postman collection but exists in backend source — keep two-call approach.

GRADES
  GET  /api/students/{student}/grade-card      → full grade card (grades, components, tags, notes)

EXCUSE REQUESTS
  ⚠️  Not present in Postman collection — endpoint confirmed in backend source code.
  GET  /api/excuse-requests                    → student's own list (scoped server-side by role)
  POST /api/excuse-requests                    → submit excuse — body: { attendance_record_id, reason, attachment? }
  GET  /api/excuse-requests/{excuse}           → single excuse

SESSIONS (for upcoming sessions + QR)
  GET  /api/sessions                           → list all sessions (flat, all cohorts)
  GET  /api/sessions/{session}/qr-code         → { qr_payload, expires_in: 15, refresh_at }
  GET  /api/sessions/{session}/attendance      → attendance records (instructor/admin only)
  ⚠️  Sessions are generated server-side via POST /api/engagements/{id}/sessions/generate
      The student-facing frontend only reads GET /api/sessions — never calls generate.

ATTENDANCE
  POST /api/attendance/scan                    → { session_qr_code: string, student_id: number }
  ✅  UPDATED: body now requires BOTH session_qr_code AND student_id (confirmed Postman line 1470)
  ⚠️  session_qr_code value is the raw qr_payload string decoded by jsQR (encrypted token)
  ⚠️  QR expires in 15 seconds — handle 400 "expired" response

ANNOUNCEMENTS
  GET  /api/cohorts/{cohort}/announcements     → list for cohort

DOES NOT EXIST (do not call these):
  ❌ GET /student/dashboard     → compose manually from /me + /students/{id} + /ledger + /sessions + /announcements
  ❌ GET /student/ledger        → real path: /students/{student_id}/ledger
  ❌ GET /student/unexcused-sessions → not an endpoint
  ❌ POST /api/excuses          → real is POST /api/excuse-requests
  ❌ GET /student/grades        → real is GET /api/students/{student_id}/grade-card
```

---

## Session 1 — Foundation

**Model: Gemini 3.5 Flash (Medium)** **Goal: Build the complete foundation layer with REAL API endpoints**

```
/antigravity-workflows /senior-frontend

STEP 0 — SET ENV:
  Open .env.local (copy from .env.example if missing).
  Set: VITE_API_BASE_URL=http://13.60.179.178/api
  Save the file.

STEP 1 — src/services/api.js (currently empty — write from scratch):

  Axios instance:
    baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://13.60.179.178/api'
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' }

  Request interceptor:
    Read token from localStorage.getItem('auth_token')
    If token: set Authorization: 'Bearer ' + token

  Response interceptor:
    On 401: clear localStorage, redirect to /login

  Export as default.

STEP 2 — src/stores/auth.js (currently empty — write from scratch):

  defineStore('auth', () => {
    user: ref(null),    // shape: { id, name, role, student_id, instructor_id, cohort_id, expires_at }
    token: ref(localStorage.getItem('auth_token') ?? null),

    isAuthenticated: computed(() => !!token.value),
    studentId:    computed(() => user.value?.student_id    ?? null),  // ← from login/me response directly
    instructorId: computed(() => user.value?.instructor_id ?? null),  // ← from login/me response
    cohortId:     computed(() => user.value?.cohort_id     ?? null),  // ← added after fetchStudentProfile()

    async login(email, password):
      POST /api/login { email, password }
      Response shape: { token, user: { id, name, role, student_id, instructor_id, expires_at } }
      On success:
        token.value = response.data.token
        localStorage.setItem('auth_token', token.value)
        user.value = response.data.user   // already has student_id directly ✅
        If user.value.student_id → await fetchStudentProfile(user.value.student_id)

    async fetchMe():
      GET /api/me
      user.value = response.data          // has student_id but NOT cohort_id
      If user.value.student_id → await fetchStudentProfile(user.value.student_id)

    async fetchStudentProfile(studentId):
      // cohort_id lives on the students table, not on /me
      GET /api/students/{studentId}
      user.value.cohort_id = response.data.cohort_id
                          ?? response.data.data?.cohort_id  // handle both wrapped/unwrapped

    async logout():
      POST /api/logout
      Clear token + user, localStorage.removeItem('auth_token')
      router.push('/login')

    return { user, token, isAuthenticated, studentId, instructorId, cohortId,
             login, fetchMe, fetchStudentProfile, logout }
  })

STEP 3 — src/stores/ledger.js (currently empty — write from scratch):

  NOTE: The ledger has TWO separate endpoints:
    - GET /api/students/{student_id}/ledger          → balance only
    - GET /api/students/{student_id}/ledger/entries  → paginated timeline entries
  ⚠️  ledger/entries is confirmed in backend source — not in Postman collection.
      Keep the two-call approach. If /entries returns 404 at runtime, log the error
      and set entries.value = [] without blocking the balance display.

  defineStore('ledger', () => {
    balance: ref(250),
    max: ref(250),
    is_at_risk: ref(false),
    entries: ref([]),
    loading: ref(false),
    error: ref(null),

    isAtRisk: computed(() => balance.value < 150),
    balanceColor: computed(() => balance.value >= 150 ? '#059669' : '#DC2626'),

    async fetchLedger(studentId: number):
      loading.value = true
      Call BOTH in parallel with Promise.allSettled (not Promise.all — entries may 404):
        GET /api/students/{studentId}/ledger
        GET /api/students/{studentId}/ledger/entries
      Map results:
        If ledger call fulfilled:
          balance.value    = ledgerData.balance ?? ledgerData.data?.balance
          max.value        = ledgerData.max ?? ledgerData.data?.max ?? 250
          is_at_risk.value = ledgerData.is_at_risk ?? (balance.value < 150)
        If entries call fulfilled:
          entries.value    = Array.isArray(entriesData)
                             ? entriesData
                             : entriesData.data ?? []
        If entries call rejected: entries.value = [] (silent — don't block UI)
      On ledger call error: set error.value

    return { balance, max, is_at_risk, entries, loading, error, isAtRisk, balanceColor, fetchLedger }
  })

STEP 4 — src/stores/excuse.js (does not exist — create it):

  ⚠️  /api/excuse-requests endpoints confirmed in backend source.
      Not present in Postman collection — keep as-is.

  defineStore('excuse', () => {
    excuseRequests: ref([]),   // student's own list from GET /api/excuse-requests
    submitting: ref(false),
    submitted: ref(false),
    submittedLabel: ref(''),
    fieldErrors: ref({}),

    async fetchExcuseRequests():
      GET /api/excuse-requests
      excuseRequests.value = response.data?.data ?? response.data ?? []

    async submitExcuse({ attendance_record_id, reason, attachment }):
      // ⚠️ API requires attendance_record_id — NOT session_id
      submitting.value = true
      const form = new FormData()
      form.append('attendance_record_id', attendance_record_id)
      form.append('reason', reason)
      if (attachment) form.append('attachment', attachment)
      POST /api/excuse-requests  (multipart/form-data)
      On 201: submitted.value = true
      On 422: fieldErrors.value = error.response.data.errors
      On other error: throw for view to handle
      Finally: submitting.value = false

    reset():
      submitted.value = false
      fieldErrors.value = {}
      submittedLabel.value = ''

    return { excuseRequests, submitting, submitted, submittedLabel,
             fieldErrors, fetchExcuseRequests, submitExcuse, reset }
  })

STEP 5 — src/stores/attendance.js (currently empty — write from scratch):

  defineStore('attendance', () => {
    // ⚠️ States: 'scanning' | 'success' | 'duplicate' | 'expired' | 'error'
    scanState: ref('scanning'),
    lastScanResult: ref(null),
    loading: ref(false),

    async submitScan(qrValue: string, studentId: number):
      // ✅ UPDATED: body requires BOTH session_qr_code AND student_id (confirmed Postman)
      // qrValue = raw encrypted string decoded by jsQR — do NOT parse or decode further
      loading.value = true
      try:
        POST /api/attendance/scan { session_qr_code: qrValue, student_id: studentId }
        On 200/201: scanState.value = 'success', lastScanResult.value = response.data
        On 409: scanState.value = 'duplicate', lastScanResult.value = error.response.data
        On 400:
          if error.response.data.message includes 'expired':
            scanState.value = 'expired'
          else:
            scanState.value = 'error'
        On other: scanState.value = 'error'
      Finally: loading.value = false

    resetScan():
      scanState.value = 'scanning'
      lastScanResult.value = null

    return { scanState, lastScanResult, loading, submitScan, resetScan }
  })

STEP 6 — ROUTES:

src/router/attendance.routes.js → append:
  { path: '/attendance/ledger', name: 'LedgerBalance',
    component: () => import('@/views/attendance/LedgerBalanceView.vue'),
    meta: { requiresAuth: true, role: 'student' } },
  { path: '/attendance/scan', name: 'QrScanner',
    component: () => import('@/views/attendance/QrScannerView.vue'),
    meta: { requiresAuth: true, role: 'student' } }

src/router/excuse.routes.js → append:
  { path: '/excuses/submit', name: 'ExcuseForm',
    component: () => import('@/views/excuses/ExcuseFormView.vue'),
    meta: { requiresAuth: true, role: 'student' } }

Check which route file handles dashboard. Append:
  { path: '/student/dashboard', name: 'StudentDashboard',
    component: () => import('@/views/dashboard/StudentDashboard.vue'),
    meta: { requiresAuth: true, role: 'student' } },
  { path: '/student/grades', name: 'StudentGradeCard',
    component: () => import('@/views/dashboard/StudentGradeCardView.vue'),
    meta: { requiresAuth: true, role: 'student' } }

STEP 7 — VERIFY:
  GET http://13.60.179.178/api/me (with a test Bearer token if available)
  Report: reachable or not. List any CORS or 401 issues.
  Log the full response — confirm student_id is present.

RULES:
  - <script setup lang="ts"> in all .vue files
  - Import from @/services/api only — never create a second axios instance
  - DO NOT touch: grading.js, cohort.js, engagement.js
  - student ID always comes from authStore.studentId (never hardcoded)
```

---

## Session 2 — StudentDashboard

**Model: Gemini 3.1 Pro (High)** **Goal: Main student home screen — composed from multiple real endpoints**

```
/antigravity-workflows /stitch-ui-design /antigravity-design-expert /senior-frontend /ui-component

DESIGN SOURCE: @stitch-exports/student_dashboard_iti_platform/code.html
REFERENCE SCREENSHOT: @stitch-exports/student_dashboard_iti_platform/screen.png

TASK: Build src/views/dashboard/StudentDashboard.vue

CRITICAL: There is NO single /student/dashboard endpoint.
The dashboard must be composed from these real API calls:

  import { useAuthStore } from '@/stores/auth'
  import { useLedgerStore } from '@/stores/ledger'
  import api from '@/services/api'

  onMounted async:
    const authStore = useAuthStore()
    const ledgerStore = useLedgerStore()

    // 1. Get student profile (fetchMe also calls fetchStudentProfile to get cohort_id)
    if (!authStore.user) await authStore.fetchMe()
    const studentId = authStore.studentId
    const cohortId  = authStore.cohortId   // available after fetchMe() completes

    // 2. Fetch ledger balance
    await ledgerStore.fetchLedger(studentId)

    // 3. Fetch sessions (flat list — student reads GET /api/sessions)
    const sessionsRes = await api.get('/sessions')
    upcomingSessions.value = (sessionsRes.data?.data ?? sessionsRes.data)
      .filter(s => {
        // ⚠️ field name uncertain — keep both fallbacks
        const d = s.date ?? s.starts_at
        return d && new Date(d) >= new Date()
      })
      .slice(0, 5)

    // 4. Fetch announcements for cohort
    if (cohortId) {
      const annRes = await api.get('/cohorts/' + cohortId + '/announcements')
      announcements.value = (annRes.data?.data ?? annRes.data).slice(0, 3)
    }

    // 5. Fetch excuse requests count
    const excuseRes = await api.get('/excuse-requests')
    const excuses = excuseRes.data?.data ?? excuseRes.data
    pendingExcuses.value = excuses.filter(e => e.status === 'pending' || e.status === 'requested').length

NOTE: Inspect the actual API response fields before mapping.
  Log the raw response in the console first, then map field names exactly.

COMPONENT STRUCTURE (pixel-accurate from Stitch):

1. Header:
   "Good morning, {authStore.user?.name}" — Playfair Display 28px
   Cohort badge: DM Sans 13px, muted pill

2. BUILD: src/components/student/SummaryCard.vue
   Props: { label: string, value: string, subtext?: string,
            variant: 'normal' | 'at-risk' | 'warning' }
   Three instances:
   a. Attendance Balance — ledgerStore.balance + '/250 pts'
      variant = ledgerStore.isAtRisk ? 'at-risk' : 'normal'
      at-risk: border crimson #8B1A1A + "⚠️ At-Risk" warning text
   b. Grand Total — computed from ledger + course scores (show ledger contribution for now)
   c. Pending Actions — pendingExcuses count
      variant = pendingExcuses > 0 ? 'warning' : 'normal'

3. Announcements panel (left):
   Role badge colors: Track Admin = #0369A1, Instructor = #0D9488

4. Upcoming Sessions:
   BUILD: src/components/student/SessionCard.vue
   Props: { date, type, time, instructor }
   Type pill: Lecture = #8B1A1A | Lab = #0D9488 | Business = #D97706

LOADING & ERROR:
  Show skeleton (3 placeholder cards) while any fetch is in progress
  Show error banner "Could not load dashboard." if any fetch fails
  Use Promise.allSettled to avoid one failure blocking the whole view

RULES:
  - <script setup lang="ts">
  - No Tailwind, no Bootstrap, scoped CSS only
  - All colors via CSS custom properties
  - SummaryCard.vue → src/components/student/SummaryCard.vue
  - SessionCard.vue → src/components/student/SessionCard.vue
  - After building: screenshot and compare with @stitch-exports/student_dashboard_iti_platform/screen.png
```

---

## Session 3 — LedgerBalanceView

**Model: Gemini 3.1 Pro (High)** **Goal: Ledger balance + deduction timeline — two separate API calls**

```
/antigravity-workflows /stitch-ui-design /antigravity-design-expert /ui-component

DESIGN SOURCE: @stitch-exports/attendance_ledger_iti_student_portal/code.html
REFERENCE SCREENSHOT: @stitch-exports/attendance_ledger_iti_student_portal/screen.png

TASK: Build LedgerBalanceView.vue + 2 sub-components

STORES:
  import { useAuthStore } from '@/stores/auth'
  import { useLedgerStore } from '@/stores/ledger'

REAL API (two separate endpoints — both called inside ledgerStore.fetchLedger):
  GET /api/students/{studentId}/ledger         → balance object
  GET /api/students/{studentId}/ledger/entries → paginated entries array
  ⚠️  If /entries returns 404 at runtime the store silently sets entries = [] —
      the view should handle an empty entries array gracefully.

onMounted:
  const authStore = useAuthStore()
  if (!authStore.user) await authStore.fetchMe()
  await ledgerStore.fetchLedger(authStore.studentId)

NOTE on field names:
  Log ledgerStore.balance and ledgerStore.entries to console before building UI.
  The entries array uses fields: delta, balance_after, reason, created_at.
  Adjust the store mapping if the actual response differs.

COMPONENT 1 — src/components/attendance/BalanceHeroCard.vue:
Props: { balance: number, max: number, isAtRisk: boolean }
  - Giant balance number: Playfair Display 72px bold
    Color: #059669 if balance >= 150, else #DC2626
  - "/ {max} pts" beside it: DM Sans 28px, #6B7280
  - Full-width progress bar: height 10px, border-radius 5px
    Fill: emerald if >= 150, crimson if below
    Width: (balance/max * 100)%, CSS transition 0.6s ease
  - Warning row (only if isAtRisk):
    "⚠️ Students below 150 pts are flagged as At-Risk — contact your Track Admin"
    DM Sans 12px, #6B7280

COMPONENT 2 — src/components/attendance/LedgerTimeline.vue:
Props: { entries: LedgerEntry[] }
NOT a table — vertical timeline:
  Left (120px): date + day — JetBrains Mono 13px, #6B7280
  Center (24px): vertical line (1.5px #E5E7EB) + dot (12px circle)
    Dot color: crimson for deduction (delta < 0), emerald for credit (delta > 0), gray for present
  Right (flex): description from entry.reason (DM Sans 14px) + delta badge
    "-25 pts": background #FEF2F2, color #DC2626, border-radius 999px
    "+20 pts": background #ECFDF5, color #059669, border-radius 999px

MAIN VIEW — src/views/attendance/LedgerBalanceView.vue:
1. BalanceHeroCard (pass ledgerStore values)
2. Section header: "Deduction History" (Playfair Display 20px) + count badge
3. LedgerTimeline — show empty state "No deductions recorded yet." if entries is empty
4. CTA button — only if any entry has delta < 0:
   "Submit an Excuse Request →"
   Full-width, height 52px, background #8B1A1A, hover #6B1212
   → router.push({ name: 'ExcuseForm' })

Loading: skeleton for hero + 5 timeline rows
Error: crimson inline banner "Could not load your ledger."

After building: screenshot and compare with reference.
```

---

## Session 4 — ExcuseFormView

**Model: Gemini 3.1 Pro (High)** **Goal: Excuse submission — POST /api/excuse-requests with attendance_record_id**

```
/antigravity-workflows /stitch-ui-design /file-uploads /ui-component

DESIGN SOURCE: @stitch-exports/excuse_submission_iti_student_portal/code.html
REFERENCE SCREENSHOT: @stitch-exports/excuse_submission_iti_student_portal/screen.png

TASK: Build ExcuseFormView.vue + ExcuseUploadZone sub-component

STORES:
  import { useAuthStore } from '@/stores/auth'
  import { useExcuseStore } from '@/stores/excuse'
  import api from '@/services/api'

REAL API ENDPOINTS:
  ⚠️  Excuse endpoints confirmed in backend source — not present in Postman collection.
  GET  /api/sessions                → all sessions (filter past ones client-side)
  GET  /api/sessions/{id}/attendance → instructor-only (403 for students) — use fallback below
  GET  /api/excuse-requests         → student's already-submitted excuses
  POST /api/excuse-requests         → { attendance_record_id, reason, attachment? }
  ⚠️  Body uses attendance_record_id — NOT session_id

onMounted:
  await authStore.fetchMe() if not loaded
  const studentId = authStore.studentId

  // Fetch past sessions for the dropdown
  const sessionsRes = await api.get('/sessions')
  const pastSessions = (sessionsRes.data?.data ?? sessionsRes.data)
    .filter(s => {
      // ⚠️ field name uncertain — keep both fallbacks
      const d = s.date ?? s.starts_at
      return d && new Date(d) < new Date()
    })

  // Fetch student's existing excuse requests
  await excuseStore.fetchExcuseRequests()
  const excusedRecordIds = excuseStore.excuseRequests.map(e => e.attendance_record_id)

  // Fetch the student's own attendance records via ledger entries
  // GET /api/students/{studentId}/ledger/entries gives ledger entries with attendance_record_id
  const entriesRes = await api.get('/students/' + studentId + '/ledger/entries')
  const entries = entriesRes.data?.data ?? entriesRes.data

  // Build dropdown: past sessions where student has an attendance record (via ledger entries)
  // and has NOT already submitted an excuse
  availableItems.value = pastSessions
    .map(session => {
      const entry = entries.find(e => e.attendance_record?.session_id === session.id
                                   || e.session_id === session.id)
      if (!entry) return null
      const recordId = entry.attendance_record_id ?? entry.attendance_record?.id
      if (!recordId) return null
      if (excusedRecordIds.includes(recordId)) return null
      return {
        label: formatDate(session.date ?? session.starts_at) + ' — ' + (session.type ?? session.engagement?.type ?? 'Session'),
        attendance_record_id: recordId
      }
    })
    .filter(Boolean)

  NOTE: Log the raw entries response to confirm field names before writing the map above.
        If ledger entries do not expose session_id, fall back to showing all past sessions
        and let the server validate — the server returns 422 if an excuse already exists.

COMPONENT 1 — src/components/attendance/ExcuseUploadZone.vue:
Props: { modelValue: File | null }
Emits: ['update:modelValue', 'validation-error']

Empty state:
  Dashed border 1.5px #8B1A1A, border-radius 12px, padding 32px
  "Drop PDF, JPG or PNG · Max 1MB" — DM Sans 14px, #6B7280

File selected state:
  Filename chip + file size + × remove button (crimson)

Drag and drop + click trigger on hidden <input type="file">
Validation: PDF/JPG/PNG only, max 1048576 bytes
  Emit 'validation-error' with message string on invalid

MAIN VIEW — src/views/excuses/ExcuseFormView.vue:
Centered card, max-width 580px

STATE 1 — Form (excuseStore.submitted === false):
  Title: "Submit an Excuse Request" — Playfair Display 24px
  Subtitle: "Your Track Admin will review within 24 hours"

  a. Session dropdown:
     Options from availableItems (label + attendance_record_id)
     Format: "Jun 3 — Laravel Lab"
     Error: fieldErrors.attendance_record_id below

  b. Reason textarea:
     4 rows, 200 char max, live counter "{n}/200" — JetBrains Mono 12px
     Counter turns crimson when > 190
     Error: fieldErrors.reason below

  c. ExcuseUploadZone component

  d. Submit button: disabled + spinner when excuseStore.submitting

On submit:
  Client-side: attendance_record_id required, reason 10-200 chars, file size/type if attached
  await excuseStore.submitExcuse({ attendance_record_id, reason, attachment })
  On 422: display excuseStore.fieldErrors under each field
  On network error: show crimson toast banner (4s auto-dismiss)

STATE 2 — Success (excuseStore.submitted === true):
  ✅ emerald icon, "Excuse Submitted Successfully"
  "← Back to Ledger" → router.push({ name: 'LedgerBalance' })

onUnmounted → excuseStore.reset()

After building: screenshot and compare with reference.
```

---

## Session 5 — QrScannerView

**Model: Gemini 3.1 Pro (High)** **Goal: Mobile QR check-in — POST /api/attendance/scan**

```
/antigravity-workflows /stitch-ui-design /progressive-web-app /mobile-developer /antigravity-design-expert

DESIGN SOURCE: @stitch-exports/qr_scanner_iti_student_portal/code.html
REFERENCE SCREENSHOT: @stitch-exports/qr_scanner_iti_student_portal/screen.png

TASK: Build src/views/attendance/QrScannerView.vue
MOBILE-ONLY — 390px viewport, NO sidebar, NO AppHeader.

DEPENDENCY: Check package.json for jsqr. If missing, run: npm install jsqr
Import as: import jsQR from 'jsqr'

STORE: import { useAttendanceStore } from '@/stores/attendance'
AUTH:  import { useAuthStore } from '@/stores/auth'

REAL API:
  POST /api/attendance/scan
  ✅ UPDATED Body: { session_qr_code: string, student_id: number }
  ⚠️  BOTH fields are required — confirmed in Postman collection.
  ⚠️  session_qr_code value is the raw encrypted string decoded by jsQR — do NOT decode further
  ⚠️  student_id comes from authStore.studentId
  ⚠️  QR expires every 15 seconds — instructor refreshes on their side automatically

  Responses:
    200/201 → checked in/out successfully
    400     → invalid or EXPIRED QR — check message for "expired"
    409     → already checked in today

LAYOUT (mobile, 390px, full screen flex column):
  Top bar (56px): "ITI" (Playfair Display 18px crimson) | "Attendance" center | bell icon right
  Camera viewfinder (~65vh):
    Dark vignette overlay on edges
    Scanning frame: corner brackets only in crimson #8B1A1A (NOT full border)
    "Align QR code within the frame" — DM Sans 12px, white
  Status card (~20vh, state-dependent)
  Bottom tab bar (56px, fixed)

CAMERA:
  <video ref="videoEl" playsinline autoplay muted></video> (hidden, feeds canvas)
  <canvas ref="canvasEl"></canvas> (hidden, used for jsQR)
  The visible viewfinder is a CSS div with object-fit cover mirroring the video stream.

  startCamera(): getUserMedia({ video: { facingMode: 'environment' } })
    On success → videoEl.srcObject = stream → videoEl.play()
    Then setInterval(scanFrame, 200)
    On failure → cameraError.value = true

  scanFrame(): draw video onto canvas → jsQR → if code found → clearInterval → handleScan(code.data)

  handleScan(qrValue):
    // qrValue is the raw encrypted payload string — pass it directly, do not decode
    // studentId comes from authStore — required by the scan endpoint
    const authStore = useAuthStore()
    await attendanceStore.submitScan(qrValue, authStore.studentId)
    // scanState is updated inside the store

  onUnmounted: clearInterval + stream.getTracks().forEach(t => t.stop())

STATUS CARD STATES (driven by attendanceStore.scanState):

  'scanning':
    White card — QR icon + "Point your camera at the session QR code" — #6B7280

  'success':
    Background #ECFDF5, border 1.5px #059669
    ✅ "Checked in" — DM Sans 16px bold, #059669
    Session name + date from attendanceStore.lastScanResult
    CSS pulse animation on border

  'duplicate':
    Background #FFFBEB, border 1.5px #D97706
    Clock icon — "Already checked in today" — #D97706

  'expired':
    Background #FFFBEB, border 1.5px #D97706
    ⏱ "QR code expired. Ask your instructor to refresh the code." — #D97706
    "Scan Again" button → attendanceStore.resetScan() + restart camera

  'error':
    Background #FEF2F2, border 1.5px #DC2626
    ⚠️ "Check-in failed. Please try again or see your instructor."
    "Try Again" button → attendanceStore.resetScan() + restart camera

PERMISSION DENIED (cameraError.value === true):
  Replace viewfinder: "Camera access required. Enable in browser settings or ask instructor."

BOTTOM TAB BAR (router-link):
  Home  → /student/dashboard
  Scan  → /attendance/scan (active: crimson #8B1A1A)
  Grades → /student/grades
  Profile → /profile
  Inactive: #6B7280

After building: set devtools to 390px, screenshot, compare with reference.
```

---

## Session 6 — StudentGradeCardView

**Model: Gemini 3.1 Pro (High)** **Goal: Academic summary — GET /api/students/{id}/grade-card**

```
/antigravity-workflows /stitch-ui-design /antigravity-design-expert /ui-component

DESIGN SOURCE: @stitch-exports/student_grade_card_iti_portal/code.html
REFERENCE SCREENSHOT: @stitch-exports/student_grade_card_iti_portal/screen.png

TASK: Build StudentGradeCardView.vue + 3 SVG sub-components

REAL API ENDPOINT (confirmed in Postman collection — section 6):
  GET /api/students/{student_id}/grade-card
  → Returns StudentGradeCardResource
  ⚠️  Log the full response before building any UI — field names are unconfirmed.
      Map whatever the endpoint returns. Do NOT assume field names.
  ⚠️  DO NOT touch src/stores/grading.js — M6 owns it.
  ⚠️  lab_group_id is used server-side for grade entry — the view does NOT need to handle it.
      Just display what the grade-card endpoint returns.

STORES:
  import { useAuthStore } from '@/stores/auth'
  import api from '@/services/api'

onMounted:
  if (!authStore.user) await authStore.fetchMe()
  const studentId = authStore.studentId
  const res = await api.get('/students/' + studentId + '/grade-card')
  gradeCard.value = res.data?.data ?? res.data
  // ✅ Log gradeCard.value to console BEFORE building the UI
  // Confirm actual field names: grades[].normalized_score, grades[].override_value,
  //   gradeComponent.weight, gradeComponent.course.name, gradeComponent.course.max_score

COMPONENT 1 — src/components/student/GrandTotalRing.vue:
Props: { total: number, max: number, letterGrade: string }
Pure SVG — NO external library:
  viewBox="0 0 160 160"
  Background circle: r=64, stroke=#E5E7EB, stroke-width=12
  Progress arc: r=64, stroke=#8B1A1A
    circumference = 2 * π * 64 ≈ 402.1
    stroke-dashoffset = circumference - (total/max) * circumference
    transform="rotate(-90 80 80)", stroke-linecap="round"
    CSS transition: stroke-dashoffset 0.8s ease on mount
  Center text: total (Playfair Display 36px) + "/500 pts" (DM Sans 13px)
  Letter grade pill beside SVG: background #8B1A1A, color white, Playfair Display 32px bold

COMPONENT 2 — src/components/student/CourseGradeBar.vue:
Props: { course: { name, normalized_score, max, components } }
  Course name (bold) + score right-aligned (JetBrains Mono 13px)
  Horizontal bar: height 8px, fill width = normalized_score/max * 100%
    >= 60% → #8B1A1A | 50-59% → #D97706 | < 50% → #6B7280
  Hover tooltip: "Labs: 38/40 · Project: 37/60" — CSS :hover only, no JS

COMPONENT 3 — src/components/student/ProgressSparkline.vue:
Props: { timeline: [{ week: number, running_total: number }], maxTotal: number }
Pure SVG area chart — NO chart library:
  viewBox="0 0 400 120", preserveAspectRatio="none"
  SVG <path> M x0,y0 L x1,y1 ... for line
  Area fill = same path + L 400,120 L 0,120 Z, fill #8B1A1A33
  Stroke: #8B1A1A, stroke-width 2

MAIN VIEW:
1. Hero card: GrandTotalRing (left) + ledger/course bars (right)
   Grand total = ledgerStore.balance + sum of normalized course scores
   Max = 250 (ledger) + 100 × number of courses
2. "Course Breakdown": CourseGradeBar per course
   Group grades by gradeComponent.course, sum normalized_score per course
   Use override_value if present, else normalized_score
3. "Progress Over Time": ProgressSparkline
   Build timeline from grades ordered by gradeComponent.course — week approximation from created_at
4. No download button for now — no export endpoint confirmed.

Loading/Error states required.

After building: screenshot and compare with reference.
```

---

## Session 7 — Integration + Polish + PR

**Model: Claude Sonnet 4.6 (Thinking)** **⚠️ One message only — paste as a single prompt, do not continue the conversation**

```
/code-review-excellence /production-code-audit /systematic-debugging

TASK: Full M5 integration review against live backend at http://13.60.179.178/api

READ FIRST:
@src/stores/auth.js
@src/stores/ledger.js
@src/stores/excuse.js
@src/stores/attendance.js

──────────────────────────────────────────────
1. API CONNECTIONS — test real endpoints
──────────────────────────────────────────────
These are the REAL M5 endpoints (verified from backend source + Postman collection):

  GET  /api/me                                  → { id, name, role, student_id, instructor_id }
  GET  /api/students/{id}                       → student profile with cohort_id
  GET  /api/students/{id}/ledger                → ledgerStore balance
  GET  /api/students/{id}/ledger/entries        → ledgerStore entries (not in Postman — test carefully)
  GET  /api/students/{id}/grade-card            → full grade card (confirmed Postman section 6)
  GET  /api/sessions                            → dashboard upcoming + excuse dropdown (confirmed Postman)
  GET  /api/cohorts/{id}/announcements          → dashboard announcements
  GET  /api/excuse-requests                     → excuseStore (confirmed backend source, not in Postman)
  POST /api/excuse-requests                     → body: { attendance_record_id, reason, attachment? }
  POST /api/attendance/scan                     → body: { session_qr_code: string, student_id: number }

For each: make the actual request, log status code + response shape.
Flag any field name mismatch between API response and store mapping.
Fix mismatches in the store (not in the view).

KEY FIELD CHECKS:
  auth store:    studentId = user.student_id (confirmed from login + /me responses)
  ledger store:  entries fields = delta, balance_after, reason, created_at
                 entries fetched with Promise.allSettled — 404 on /entries is silent
  excuse store:  POST body uses attendance_record_id (NOT session_id)
  attendance:    POST body uses BOTH session_qr_code AND student_id ✅ (confirmed Postman)
  sessions:      date field may be session.date OR session.starts_at — handle both fallbacks

──────────────────────────────────────────────
2. AT-RISK FLAG
──────────────────────────────────────────────
isAtRisk = ledgerStore.balance < 150
Verify crimson styling in:
  @src/views/dashboard/StudentDashboard.vue     → SummaryCard variant='at-risk'
  @src/views/attendance/LedgerBalanceView.vue   → BalanceHeroCard crimson bar

──────────────────────────────────────────────
3. VISUAL ACCURACY
──────────────────────────────────────────────
Open each screen, screenshot, compare with:
  @stitch-exports/student_dashboard_iti_platform/screen.png
  @stitch-exports/attendance_ledger_iti_student_portal/screen.png
  @stitch-exports/excuse_submission_iti_student_portal/screen.png
  @stitch-exports/qr_scanner_iti_student_portal/screen.png
  @stitch-exports/student_grade_card_iti_portal/screen.png
Fix differences: colors | typography | spacing | missing elements

──────────────────────────────────────────────
4. MOBILE CHECK
──────────────────────────────────────────────
Set browser to 390px:
  QrScannerView — tab bar, camera frame, all 5 status card states
  StudentDashboard — cards stack, no overflow

──────────────────────────────────────────────
5. CODE QUALITY
──────────────────────────────────────────────
Scan all 5 views + components:
  □ Missing loading state
  □ Missing error state
  □ console.log remaining (remove all)
  □ Hardcoded colors instead of CSS variables
  □ vue-tsc --noEmit errors
  □ Any write to grading.js (not allowed — M6 owns it)
  □ attendance/scan store method called with only 1 arg (must pass studentId as 2nd arg)

──────────────────────────────────────────────
6. PR DESCRIPTION
──────────────────────────────────────────────
## M5 — Student Portal & Attendance Module

### Built
- StudentDashboard.vue — composed from /me + /students/{id} + /ledger + /sessions + /announcements
- LedgerBalanceView.vue + BalanceHeroCard + LedgerTimeline
- ExcuseFormView.vue + ExcuseUploadZone (POST /api/excuse-requests with attendance_record_id)
- QrScannerView.vue — jsQR + POST /api/attendance/scan { session_qr_code, student_id } (390px mobile)
- StudentGradeCardView.vue — SVG ring, sparkline, bars (no chart libraries)
- src/stores/auth.js, ledger.js, attendance.js, excuse.js (all from scratch)

### Real API endpoints consumed
(list endpoints confirmed working against http://13.60.179.178/api)

### Design
Pixel-accurate from Stitch exports (local stitch-exports/ folder)

### At-Risk
balance < 150 → crimson styling in dashboard SummaryCard + LedgerBalanceView

### Screenshots
[attach screenshots from built-in browser]

### Known issues / TODOs
(list any field name mismatches or 404s discovered during integration)
```

---

## Quick Reference

```
Backend:    http://13.60.179.178/api
Dev:        http://localhost:5173
Auth:       Bearer token → localStorage key 'auth_token'
Student ID: authStore.studentId → from user.student_id (login response + GET /api/me)
Cohort ID:  authStore.cohortId  → from GET /api/students/{student_id} (2nd call in fetchMe)

Real M5 endpoints (Postman collection + backend source):
  GET  /api/me                                ← student_id confirmed ✅
  GET  /api/students/{id}                     ← cohort_id is here
  GET  /api/students/{id}/ledger
  GET  /api/students/{id}/ledger/entries      ← SEPARATE from ledger — not in Postman, in source ✅
  GET  /api/students/{id}/grade-card          ← confirmed Postman section 6 ✅
  GET  /api/sessions                          ← confirmed Postman ✅
  GET  /api/cohorts/{id}/announcements
  GET  /api/excuse-requests                   ← backend source only, not in Postman ⚠️
  POST /api/excuse-requests                   ← body: attendance_record_id (NOT session_id)
  POST /api/attendance/scan                   ← body: session_qr_code + student_id ✅ UPDATED

Session date field: session.date ?? session.starts_at — keep both fallbacks ⚠️

Model per session:
  1 Foundation   → Flash (Medium)
  2-6 Screens    → Pro (High)
  7 Integration  → Sonnet (Thinking) — one message only

At-Risk: balance < 150 → crimson #DC2626 everywhere
QR Note: expires every 15s — 'expired' state needed in scanner
Skill syntax in Antigravity: /skill-name (e.g. /antigravity-workflows)
```

---

_M5 Prompts v5.0 — updated against Postman collection (self-driving)_ _Changes from v4.0:_ _- attendance/scan body now includes student_id (confirmed Postman line 1470)_ _- submitScan() store method signature updated to (qrValue, studentId)_ _- handleScan() in QrScannerView now passes authStore.studentId as 2nd arg_ _- ledger store uses Promise.allSettled — /entries 404 is silent, not blocking_ _- session date fallback (date ?? starts_at) applied in all 3 places it's used_ _- excuse endpoints kept as-is with source-confirmed warning comment_ _- grade-card view: lab_group_id concern removed — view just displays what endpoint returns_ _- skill syntax updated to /skill-name format for Antigravity IDE_ _- Session 7 code quality checklist adds: submitScan 2-arg check_