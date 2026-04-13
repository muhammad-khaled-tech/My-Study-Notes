# FreelanceFlow — Git & GitHub Training Guide

> Runs parallel to the Learning Journey sprint by sprint. After finishing each sprint and verifying the checkpoint in Postman — come here and run the git section. Repo: https://github.com/muhammad-khaled-tech/freelance-flow.git

---

## The Branching Strategy

```
main          ← production-ready, only touched at the very end
  └── dev     ← integration branch, always up to date
        ├── sprint/00-bare-server       → merge to dev
        ├── sprint/01-express-json      → merge to dev
        ├── sprint/02-error-handler     → merge to dev
        ├── sprint/03-mongodb-schema    → merge to dev
        ├── sprint/04-password-hashing  → merge to dev
        ├── sprint/05-register          → merge to dev
        ├── sprint/06-login-jwt         → merge to dev
        ├── sprint/07-protect           → merge to dev
        ├── sprint/08-projects-crud     → merge to dev
        ├── sprint/09-proposals-cascade → merge to dev
        └── sprint/10-reviews           → merge to dev
                                                  ↓
                                            merge dev → main
```

This is **simplified GitFlow** — the same pattern used in real teams.

- `main` stays clean and always represents a fully working version
- `dev` is the integration branch — everything comes here first
- Each sprint branch is isolated — if something breaks it does not affect the others
- The final `dev → main` merge is your "production release"

---

## One-Time Setup

```bash
# Clone the repo
git clone https://github.com/muhammad-khaled-tech/freelance-flow.git
cd freelance-flow

# Create dev branch and push it to GitHub
git checkout -b dev
git push -u origin dev

# Verify
git remote -v
git branch -a
```

**Create `.gitignore` before anything:**

```bash
cat > .gitignore << 'EOF'
node_modules/
.env
*.log
npm-debug.log*
.DS_Store
Thumbs.db
.vscode/
.idea/
EOF
```

> [!warning] Critical The `.env` file contains your `JWT_SECRET` and `MONGO_URI`. If pushed to GitHub anyone can read them. The `.gitignore` prevents this permanently.

**Create `.env.example` — this one gets pushed:**

```bash
cat > .env.example << 'EOF'
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb://127.0.0.1:27017/freelanceflow
JWT_SECRET=your-secret-key-minimum-32-characters
JWT_EXPIRES_IN=7d
EOF
```

This tells any developer which environment variables they need — without exposing real values.

---

## The Merge Command — Same Pattern Every Sprint

```bash
# Step 1: on sprint branch, commit when checkpoint passes

# Step 2: merge into dev
git checkout dev
git merge sprint/XX-name --no-ff -m "merge: sprint XX - short description"

# Step 3: push dev
git push origin dev
```

`--no-ff` means no fast forward. It creates an explicit merge commit so the branch structure stays visible in the graph. Most teams use this.

---

## Sprint 00 — Bare-Bones Server

```bash
git checkout dev
git checkout -b sprint/00-bare-server

git add .

git commit -m "feat: Sprint 00 - bare-bones Express server

- Initialize project with npm
- Add express and dotenv dependencies
- Create server.js with basic GET / route
- Add .gitignore (exclude node_modules and .env)
- Add .env.example for documentation"

git checkout dev
git merge sprint/00-bare-server --no-ff -m "merge: sprint 00 - bare-bones server"
git push origin dev
```

---

## Sprint 01 — express.json Middleware

```bash
git checkout dev
git checkout -b sprint/01-express-json

git add server.js

git commit -m "feat: Sprint 01 - add express.json middleware

- Register express.json() before all routes
- Add /test-body route to verify req.body parsing
- Demonstrates middleware pipeline concept"

git checkout dev
git merge sprint/01-express-json --no-ff -m "merge: sprint 01 - express.json middleware"
git push origin dev
```

---

## Sprint 02 — Error Handler

```bash
git checkout dev
git checkout -b sprint/02-error-handler

git add src/utils/AppError.js src/middlewares/errorHandler.js server.js

git commit -m "feat: Sprint 02 - global error handling system

- Add AppError class extending native Error
- Add statusCode, status, isOperational properties
- Implement globalErrorHandler middleware (4-param signature)
- Add /test-error route for verification
- Add app.all('*') catch-all 404 handler"

git checkout dev
git merge sprint/02-error-handler --no-ff -m "merge: sprint 02 - error handler"
git push origin dev
```

---

## Sprint 03 — MongoDB + Schema

```bash
git checkout dev
git checkout -b sprint/03-mongodb-schema

git add src/models/User.model.js server.js

git commit -m "feat: Sprint 03 - MongoDB connection and User schema

- Add mongoose dependency
- Connect to MongoDB with error handling and process.exit
- Create User schema (name, email, password, role)
- Add timestamps option (createdAt, updatedAt)
- Add unique index on email field
- Add /test-user route for verification"

git checkout dev
git merge sprint/03-mongodb-schema --no-ff -m "merge: sprint 03 - mongodb and user schema"
git push origin dev
```

---

## Sprint 04 — Password Hashing

```bash
git checkout dev
git checkout -b sprint/04-password-hashing

git add src/models/User.model.js

git commit -m "feat: Sprint 04 - password hashing with bcrypt

- Add bcryptjs dependency
- Implement pre-save hook for password hashing (cost factor 12)
- Add isModified check to skip re-hashing on unrelated updates
- Add select: false on password field
- Add minlength validation (8 characters)
- Add correctPassword instance method"

git checkout dev
git merge sprint/04-password-hashing --no-ff -m "merge: sprint 04 - password hashing"
git push origin dev
```

---

## Sprint 05 — MVC Structure + Register

```bash
git checkout dev
git checkout -b sprint/05-register

mkdir -p src/controllers src/routes

git add .

git commit -m "feat: Sprint 05 - MVC structure and register endpoint

- Create src/utils/catchAsync.js
- Create src/controllers/auth.controller.js
- Create src/routes/auth.routes.js
- Create app.js (separate Express setup from server.js)
- Refactor server.js (DB connection + app.listen only)
- Implement POST /api/v1/auth/register
- Apply Fat Model, Thin Controller principle
- Use explicit req.body fields (not spread)"

git checkout dev
git merge sprint/05-register --no-ff -m "merge: sprint 05 - MVC structure and register"
git push origin dev
```

---

## Sprint 06 — Login + JWT

```bash
git checkout dev
git checkout -b sprint/06-login-jwt

git add src/controllers/auth.controller.js src/routes/auth.routes.js

git commit -m "feat: Sprint 06 - login and JWT authentication

- Add jsonwebtoken dependency
- Implement POST /api/v1/auth/login
- Add signToken and sendTokenResponse helpers
- Add JWT_SECRET and JWT_EXPIRES_IN to .env.example
- Prevent user enumeration (single error for wrong email or password)"

git checkout dev
git merge sprint/06-login-jwt --no-ff -m "merge: sprint 06 - login and JWT"
git push origin dev
```

---

## Sprint 07 — protect + restrictTo

```bash
git checkout dev
git checkout -b sprint/07-protect

git add src/middlewares/auth.middleware.js src/middlewares/errorHandler.js

git commit -m "feat: Sprint 07 - route protection and authorization

- Create auth.middleware.js
- Implement protect middleware (4 steps: extract, verify, find user, attach)
- Implement restrictTo factory function (closure pattern)
- Add JWT error handlers (JsonWebTokenError, TokenExpiredError)
- Add sendErrorDev / sendErrorProd based on NODE_ENV
- Add Mongoose error handlers (CastError, DuplicateKey, ValidationError)"

git checkout dev
git merge sprint/07-protect --no-ff -m "merge: sprint 07 - protect and restrictTo"
git push origin dev
```

---

## Sprint 08 — Projects CRUD

```bash
git checkout dev
git checkout -b sprint/08-projects-crud

git add src/models/Project.model.js \
        src/controllers/project.controller.js \
        src/routes/project.routes.js \
        app.js

git commit -m "feat: Sprint 08 - Projects CRUD with soft delete

- Create Project schema (title, description, budget, skills, deadline, status)
- Add cross-field validation via pre-save hook (budget.max > budget.min)
- Add status state machine (open, in_progress, completed, cancelled)
- Add DB indexes on status and client fields
- Implement createProject — client only, injects req.user._id
- Implement getAllProjects — open projects with client populate
- Implement getProject — single project with populate
- Implement updateProject — owner check, strips protected fields
- Implement deleteProject — soft delete (status: cancelled)
- Add router.use(protect) pattern"

git checkout dev
git merge sprint/08-projects-crud --no-ff -m "merge: sprint 08 - projects CRUD"
git push origin dev
```

---

## Sprint 09 — Proposals + Cascade Hook

```bash
git checkout dev
git checkout -b sprint/09-proposals-cascade

git add src/models/Proposal.model.js \
        src/controllers/proposal.controller.js \
        src/routes/proposal.routes.js \
        src/routes/project.routes.js \
        app.js

git commit -m "feat: Sprint 09 - proposals system with cascade hook

- Create Proposal schema (project, freelancer, coverLetter, bidAmount, status)
- Add compound unique index {project, freelancer}
- Implement post-save cascade hook on proposal acceptance:
  * Reject all other pending proposals on same project
  * Update project status to in_progress
  * Set acceptedFreelancer on project
  * Uses mongoose.model() to avoid circular dependency
- Implement submitProposal — freelancer only
- Implement getProjectProposals — client owner only
- Implement acceptProposal — triggers cascade via .save()
- Add nested routes /:projectId/proposals"

git checkout dev
git merge sprint/09-proposals-cascade --no-ff -m "merge: sprint 09 - proposals and cascade"
git push origin dev
```

---

## Sprint 10 — Reviews + Aggregation

```bash
git checkout dev
git checkout -b sprint/10-reviews

git add src/models/Review.model.js \
        src/controllers/review.controller.js \
        src/routes/review.routes.js \
        src/models/User.model.js \
        app.js

git commit -m "feat: Sprint 10 - reviews and aggregation pipeline

- Add avgRating and ratingsCount fields to User schema
- Create Review schema with compound index {project, reviewer}
- Implement calcAverageRating static method using aggregation pipeline
- Add post-save hook for recalculation after review create
- Add pre/post findOneAnd hooks for recalculation after review delete
- Implement createReview with 3-layer business rule validation
- Implement getFreelancerStats with two aggregation pipelines
- Add completeProject endpoint (in_progress -> completed)"

git checkout dev
git merge sprint/10-reviews --no-ff -m "merge: sprint 10 - reviews and aggregation"
git push origin dev
```

---

## Final — Merge dev into main

After all sprints are done and everything works end to end:

```bash
git checkout main

git merge dev --no-ff -m "release: FreelanceFlow API v1.0.0

Complete REST API including:
- Express + MVC architecture
- JWT authentication and role-based authorization
- MongoDB + Mongoose with hooks and validation
- Projects, Proposals, Reviews CRUD
- Cascade hook on proposal acceptance
- MongoDB aggregation pipeline for stats
- Global error handling system"

git push origin main
```

---

## The Final Git Graph

After everything is merged, `git log --oneline --graph` will look like this:

```
*   release: FreelanceFlow API v1.0.0        ← main
|\
* | merge: sprint 10 - reviews               ← dev
|\|
| * feat: Sprint 10 - reviews and aggregation
|/
* merge: sprint 09 - proposals and cascade
|\
| * feat: Sprint 09 - proposals system with cascade hook
|/
* merge: sprint 08 - projects CRUD
|\
| * feat: Sprint 08 - Projects CRUD with soft delete
|/
* ... sprints 00-07
```

A professional git history. Anyone who opens the repo can follow the entire build journey from start to finish.

---

---

# Skills Roadmap — What to Add Next

All of these get added to the same FreelanceFlow repo as feature branches off `dev`. You build skills and portfolio at the same time.

```bash
# Pattern for every new skill
git checkout dev
git checkout -b feat/skill-name
# implement
git checkout dev
git merge feat/skill-name --no-ff -m "feat: add skill-name"
git push origin dev
```

---

## Level 2 — Add These Right After the Sprints

### 1. Input Validation — `express-validator`

Currently relying on Mongoose validation only. Request-level validation catches bad data before it hits the controller.

```bash
npm install express-validator
git checkout -b feat/input-validation
```

**What you learn:** validation middleware chain, custom validators, consistent error response format. **Where to apply:** all POST and PATCH routes in the project.

---

### 2. Rate Limiting — `express-rate-limit`

The login endpoint is vulnerable to brute force without it.

```bash
npm install express-rate-limit
git checkout -b feat/rate-limiting
```

```javascript
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 5,
  message: 'Too many login attempts. Try again in 15 minutes.'
});
router.post('/login', loginLimiter, login);
```

**What you learn:** global vs route-specific middleware, sliding window rate limiting.

---

### 3. API Documentation — `swagger-ui-express`

Interactive docs that let anyone test the API from the browser at `GET /api-docs`.

```bash
npm install swagger-ui-express swagger-jsdoc
git checkout -b feat/api-docs
```

**What you learn:** OpenAPI spec, JSDoc annotations on routes, self-documenting APIs.

---

## Level 3 — After You Are Comfortable

### 4. Testing — `jest` + `supertest`

The most valuable one for interviews.

```bash
npm install --save-dev jest supertest
git checkout -b feat/testing
```

**What you learn:** unit tests on models, integration tests on endpoints, how to test the cascade hook specifically, test coverage reports.

---

### 5. Caching — `redis`

The `getAllProjects` query hits the DB on every request. With real traffic this becomes slow.

```bash
npm install redis
git checkout -b feat/redis-cache
```

**What you learn:** cache-aside pattern, TTL (time to live), cache invalidation when data changes.

---

### 6. File Upload — `multer` + Cloudinary

Profile pictures for freelancers, attachments for projects.

```bash
npm install multer cloudinary multer-storage-cloudinary
git checkout -b feat/file-upload
```

**What you learn:** multipart/form-data, cloud storage, file size and type validation.

---

### 7. Real-time Notifications — `socket.io`

When a client accepts a proposal, the freelancer gets notified instantly without polling.

```bash
npm install socket.io
git checkout -b feat/real-time
```

**What you learn:** WebSockets, event-based communication, the difference between HTTP and WebSocket.

---

### 8. Email — `nodemailer`

Send emails on: new registration, proposal accepted, project completed.

```bash
npm install nodemailer
git checkout -b feat/email
```

---

## Priority Order

```
Right now (after the sprints):
  1. express-validator   — correct validation layer
  2. express-rate-limit  — basic security
  3. swagger             — professional documentation

Next:
  4. jest + supertest    — high interview value
  5. redis               — important performance concept

Advanced:
  6. file upload
  7. socket.io
  8. nodemailer
```

---

> **Last note:** A repo with sprint branches, conventional commit messages, and a clean merge history into main is more valuable in an interview than anything you can write on a CV.