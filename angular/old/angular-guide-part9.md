# 📗 Angular Complete Guide — Part 9 of 9
## Deployment: ng build + Environment Files + Docker + Nginx
> The complete journey from local code to production server

---

# TABLE OF CONTENTS

1. Understanding the Build Process
   - What ng build produces
   - Development vs production builds
   - Bundle analysis — what's in your build
   - Tree shaking — removing unused code

2. Environment Files — Configuration per Stage
   - environments/ folder structure
   - environment.ts vs environment.development.ts
   - Adding custom environment variables
   - Using environments in services
   - Adding new environments (staging, QA)
   - File replacements — how Angular swaps files

3. ng build — Options and Flags
   - Essential build flags explained
   - Output hashing — cache busting
   - Budget limits — preventing bundle bloat
   - Source maps
   - Differential loading

4. Serving the Built App
   - Why you can't open index.html directly
   - Serving with a local HTTP server
   - Nginx — the production web server
   - The critical SPA routing fix — try_files
   - Gzip compression
   - Cache-Control headers

5. Docker — Containerizing the Angular App
   - Why Docker
   - Multi-stage Dockerfile: build stage + serve stage
   - .dockerignore
   - Building and running the container
   - Docker Compose — frontend + backend + MongoDB together
   - Environment variables at runtime (not build time)

6. Deployment Targets
   - Deploying to a VPS (DigitalOcean, Linode, AWS EC2)
   - Deploying to Vercel (frontend only)
   - Deploying to Netlify
   - Deploying with GitHub Actions CI/CD

7. Bookstore Application — Full Deployment Checklist

---

---

# CHAPTER 1 — Understanding the Build Process

## 1.1 What ng build Produces

When you run `ng build`, Angular compiles your TypeScript + HTML + CSS into static files that any web server can serve.

```bash
ng build
# Output directory: dist/bookstore-frontend/browser/
```

```
dist/bookstore-frontend/browser/
├── index.html                    ← the entry point (unchanged from src/index.html)
├── main-HASH.js                  ← your application code (components, services, etc.)
├── chunk-ABCDEF.js               ← lazy-loaded route chunks
├── polyfills-HASH.js             ← browser compatibility code
├── styles-HASH.css               ← compiled CSS
├── assets/                       ← everything from src/assets/ (images, fonts, etc.)
└── favicon.ico
```

**Key insight:** The output is 100% static files. No Node.js. No server-side code. Just HTML, CSS, and JavaScript that browsers understand.

---

## 1.2 Development vs Production Builds

```bash
# Development build (default with ng serve):
ng build                          # uses development configuration
ng build --configuration=development

# What it produces:
# - No minification (readable code — easier to debug)
# - Source maps included (see original TypeScript in DevTools)
# - No tree shaking (faster build)
# - Large bundle size (~3MB+ is normal)

# Production build:
ng build --configuration=production
# OR just:
ng build  # in Angular 17+, production is the default for ng build

# What it produces:
# - Minified and uglified (unreadable, tiny)
# - Tree shaking (unused code removed)
# - Ahead-of-Time (AOT) compilation
# - Bundle size optimized (~200-500KB typical for a medium app)
# - NO source maps by default (protect your code)
```

---

## 1.3 Bundle Analysis

Before deploying, check what's making your bundle large:

```bash
# Install the analyzer:
npm install --save-dev webpack-bundle-analyzer

# Build with stats:
ng build --stats-json

# Analyze:
npx webpack-bundle-analyzer dist/bookstore-frontend/browser/stats.json
# Opens an interactive chart in your browser
# Shows which libraries take up the most space
```

Common bundle size culprits:
```
moment.js        — ~300KB (replace with date-fns or Luxon — much smaller)
lodash           — ~70KB (import specific functions: import { debounce } from 'lodash-es')
Angular Material — ~100-200KB (only import modules you actually use)
```

---

---

# CHAPTER 2 — Environment Files

## 2.1 The environments/ Folder

Angular's environment system lets you have different configuration values for different builds (development, staging, production) without changing your code.

```
src/environments/
├── environment.ts              ← development configuration (default)
└── environment.development.ts  ← also development (used by ng serve)
```

**Note:** In Angular 15+, the structure changed. In older projects you might see:
```
src/environments/
├── environment.ts          ← production values
└── environment.prod.ts     ← also production (ng build swaps this in)
```

---

## 2.2 Environment Files in Your Bookstore

```typescript
// src/environments/environment.ts — development values
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api',
  // Local backend URL — only works on your machine
};

// src/environments/environment.development.ts — same for ng serve
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api',
};
```

---

## 2.3 Adding Production Environment

```bash
# Generate a production environment file:
ng generate environments
# OR create manually:
```

```typescript
// src/environments/environment.production.ts — production values
export const environment = {
  production: true,
  apiUrl: 'https://api.yourbookstore.com/api',
  // Your real backend URL — deployed server
};
```

```json
// angular.json — tell Angular which file to use for each configuration
{
  "configurations": {
    "production": {
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.production.ts"
        }
        // When ng build --configuration=production runs:
        // Angular replaces environment.ts with environment.production.ts
        // Your services import from environment.ts — Angular swaps the file automatically
        // Result: production build uses your real backend URL
      ],
      "optimization": true,
      "outputHashing": "all",
      "sourceMap": false,
      "budgets": [...]
    }
  }
}
```

---

## 2.4 Using Environments in Services

```typescript
// auth.service.ts
import { environment } from '../../../environments/environment';
// This import ALWAYS points to environment.ts
// Angular's file replacement swaps what environment.ts contains at build time

@Injectable({ providedIn: 'root' })
export class AuthService {
  private api = `${environment.apiUrl}/auth`;
  // Development: 'http://localhost:5000/api/auth'
  // Production: 'https://api.yourbookstore.com/api/auth'
  // Same code — different value depending on build configuration
}
```

---

## 2.5 Adding a Staging Environment

```typescript
// src/environments/environment.staging.ts
export const environment = {
  production: false,         // not production — still has some debug features
  apiUrl: 'https://staging-api.yourbookstore.com/api',
};
```

```json
// angular.json — add staging configuration:
{
  "configurations": {
    "staging": {
      "fileReplacements": [{
        "replace": "src/environments/environment.ts",
        "with": "src/environments/environment.staging.ts"
      }],
      "optimization": true,
      "sourceMap": true  // keep source maps for debugging staging issues
    }
  }
}
```

```bash
# Build for staging:
ng build --configuration=staging
```

---

---

# CHAPTER 3 — ng build Options and Flags

## 3.1 Essential Build Flags

```bash
# Production build (optimized, minified):
ng build --configuration=production

# Development build (readable, with source maps):
ng build --configuration=development

# Specify output directory:
ng build --output-path=my-dist-folder

# Watch mode (rebuild on file changes):
ng build --watch

# Verbose output (see what's happening):
ng build --verbose

# Skip TypeScript type checking (faster build — use for quick deploys):
ng build --no-aot  # use sparingly — AOT catches template errors
```

---

## 3.2 Output Hashing — Cache Busting

Angular adds a hash to file names based on file content:

```
main-A3B7C.js    ← hash changes when file content changes
styles-FF891.css
```

**Why:** When you deploy a new version, browsers have the old files cached. If filenames don't change, users get stale JavaScript. With content hashing, changed files get new names — browsers download them fresh. Unchanged files keep their name — browsers use the cache.

```json
// angular.json:
"outputHashing": "all"      // hash all files (default for production)
"outputHashing": "none"     // no hashing (bad for production, fine for development)
"outputHashing": "bundles"  // hash JS/CSS but not assets
"outputHashing": "media"    // hash only media files
```

---

## 3.3 Budget Limits — Preventing Bundle Bloat

Angular can warn or fail the build if bundles exceed size limits:

```json
// angular.json — production configuration:
"budgets": [
  {
    "type": "initial",
    "maximumWarning": "500kb",
    "maximumError": "1mb"
    // Initial bundle (main.js + polyfills): warn at 500KB, error at 1MB
  },
  {
    "type": "anyComponentStyle",
    "maximumWarning": "4kb",
    "maximumError": "8kb"
    // Component styles: warn if one component's CSS exceeds 4KB
  }
]
```

If your build fails with budget errors:
```bash
# Check what's large:
ng build --stats-json && npx webpack-bundle-analyzer dist/.../stats.json

# Common fixes:
# - Import only what you use from Angular Material
# - Replace moment.js with date-fns
# - Check for accidental duplicate library imports
# - Use lazy loading for large components
```

---

---

# CHAPTER 4 — Serving the Built App

## 4.1 Why You Can't Open index.html Directly

```bash
# After ng build:
open dist/bookstore-frontend/browser/index.html
# ❌ The app loads but routing is broken
# Clicking "Books" navigates to /books
# But the file system has no /books file — 404
```

The problem: Angular's router changes the URL in the browser bar (to `/books`, `/profile`, etc.) but these are NOT real files. There's only one real file: `index.html`. Every URL must serve `index.html` and let Angular's router handle the rest.

This is called a **Single Page Application (SPA) routing problem**. Every web server needs to be configured for it.

---

## 4.2 Local Testing with http-server

```bash
# Install once globally:
npm install -g http-server

# Serve from the dist folder:
cd dist/bookstore-frontend/browser
http-server -p 4200 --proxy http://localhost:4200?

# The --proxy flag redirects 404s back to index.html
# Now Angular's router handles all URLs correctly

# Alternative — Angular's built-in preview:
ng serve --configuration=production
# Builds and serves in one command — for testing production build locally
```

---

## 4.3 Nginx — The Production Web Server

Nginx is the most common web server for serving Angular apps in production. It's fast, efficient, and handles the SPA routing problem with one config line.

```nginx
# /etc/nginx/sites-available/bookstore
server {
    listen 80;
    server_name yourbookstore.com www.yourbookstore.com;
    root /var/www/bookstore/browser;
    # Root: where your ng build output is

    index index.html;

    # THE CRITICAL SPA ROUTING FIX:
    location / {
        try_files $uri $uri/ /index.html;
        # try_files: try to find a file matching the URI
        # $uri: look for the exact file (exists for /styles-HASH.css, /main-HASH.js, etc.)
        # $uri/: look for a directory
        # /index.html: if nothing found, serve index.html
        # This means: /books → no file found → serve index.html → Angular router handles /books
        # Without this: /books → 404 Not Found (Nginx can't find a 'books' file)
    }

    # Cache static assets aggressively (they have content hashes):
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2)$ {
        expires 1y;
        # Cache for 1 year — safe because filenames include content hash
        # When you deploy new code: new hash = new filename = new download
        add_header Cache-Control "public, immutable";
        # immutable: tells browser never to revalidate this file
    }

    # Don't cache index.html:
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        # When you deploy, users must get the new index.html immediately
        # Without this: users run old JS files referenced by cached index.html
    }

    # Gzip compression:
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1000;
    # Compress files over 1KB
    # Typical savings: JS 70%, CSS 80%, JSON 75%
}
```

```bash
# Enable the site:
sudo ln -s /etc/nginx/sites-available/bookstore /etc/nginx/sites-enabled/
sudo nginx -t    # test configuration syntax
sudo systemctl reload nginx
```

---

## 4.4 HTTPS with Let's Encrypt (Certbot)

```bash
# Install certbot:
sudo apt install certbot python3-certbot-nginx

# Get certificate and auto-configure Nginx:
sudo certbot --nginx -d yourbookstore.com -d www.yourbookstore.com

# Certbot automatically:
# 1. Gets a free SSL certificate from Let's Encrypt
# 2. Modifies your Nginx config to add HTTPS
# 3. Sets up auto-renewal (certificates expire every 90 days)
```

---

---

# CHAPTER 5 — Docker: Containerizing the Angular App

## 5.1 Why Docker

Without Docker:
```
Works on my machine → send to server → server has different Node version
→ different OS → missing dependencies → different Nginx config → breaks
```

With Docker:
```
Docker container = your app + exact Node version + exact Nginx config + all dependencies
Same container runs identically on any machine that has Docker installed
"Works on my machine" becomes "works everywhere"
```

---

## 5.2 Multi-Stage Dockerfile

The key insight: you need Node.js to BUILD Angular (run `ng build`), but you only need Nginx to SERVE the output. A multi-stage Dockerfile uses Node.js to build, then creates a tiny Nginx image with just the built files.

```dockerfile
# Dockerfile — place in the root of your Angular project

# ─── STAGE 1: BUILD ───────────────────────────────────────────────────────────
FROM node:20-alpine AS build
# node:20-alpine: Node.js 20 on Alpine Linux (tiny ~100MB)
# AS build: names this stage 'build' so we can reference it later

WORKDIR /app
# Create and switch to /app directory inside the container

COPY package.json package-lock.json ./
# Copy package files FIRST — before the rest of the code
# Docker caches layers: if package.json hasn't changed, npm install is cached
# This makes subsequent builds much faster

RUN npm ci --omit=dev
# npm ci: clean install from package-lock.json (reproducible, faster than npm install)
# --omit=dev: skip devDependencies (Angular CLI, testing tools, etc. not needed for build)
# Wait — we DO need @angular/cli for ng build:
# Actually: keep @angular/cli as a dependency or use npx

RUN npm ci
# Install all dependencies (including @angular/cli)

COPY . .
# Copy the rest of the project (src/, angular.json, tsconfig.json, etc.)
# This is AFTER npm install so package layer is cached separately

RUN npx ng build --configuration=production
# Build the Angular app in production mode
# Output goes to: /app/dist/bookstore-frontend/browser/

# ─── STAGE 2: SERVE ───────────────────────────────────────────────────────────
FROM nginx:alpine AS serve
# nginx:alpine: Nginx on Alpine Linux (~25MB — tiny!)
# Nothing from Stage 1 is included except what we explicitly copy

COPY --from=build /app/dist/bookstore-frontend/browser /usr/share/nginx/html
# --from=build: copy FROM the 'build' stage (not from your local machine)
# /app/dist/.../browser: the ng build output
# /usr/share/nginx/html: where Nginx serves files from by default

COPY nginx.conf /etc/nginx/conf.d/default.conf
# Replace default Nginx config with our custom one (SPA routing fix, caching, etc.)

EXPOSE 80
# Document that this container listens on port 80
# This is metadata — doesn't actually open the port (docker run -p does that)

CMD ["nginx", "-g", "daemon off;"]
# Start Nginx in the foreground
# "daemon off;" prevents Nginx from backgrounding itself
# Docker needs the main process to stay in the foreground — otherwise container exits
```

---

## 5.3 nginx.conf for Docker

```nginx
# nginx.conf — place next to Dockerfile
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location = /index.html {
        add_header Cache-Control "no-cache";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

---

## 5.4 .dockerignore

```
# .dockerignore — prevents these from being copied into the Docker image
# (same concept as .gitignore but for Docker)

node_modules/
# NEVER copy node_modules — it's huge and platform-specific
# Docker will run npm install inside the container for the right platform

dist/
# Don't copy local build output — Docker builds its own

.git/
# Git history not needed in the image

*.spec.ts
# Test files not needed in production

.angular/
# Angular CLI cache — not needed

coverage/
# Test coverage reports — not needed

README.md
*.md
```

---

## 5.5 Building and Running the Container

```bash
# Build the Docker image:
docker build -t bookstore-frontend .
# -t bookstore-frontend: tag (name) for the image
# .: build context — send current directory to Docker
# This runs the Dockerfile — takes 2-5 minutes on first run (npm install + ng build)
# Subsequent builds use cache — much faster

# Run the container:
docker run -d -p 3000:80 --name bookstore-app bookstore-frontend
# -d: detached mode (runs in background)
# -p 3000:80: map host port 3000 to container port 80
#   → http://localhost:3000 → container's Nginx on port 80
# --name: name for this running container

# Open in browser:
# http://localhost:3000

# View container logs:
docker logs bookstore-app

# Stop the container:
docker stop bookstore-app

# Remove the container:
docker rm bookstore-app

# List running containers:
docker ps

# List all images:
docker images
```

---

## 5.6 Docker Compose — Frontend + Backend + MongoDB

`docker-compose.yml` lets you run multiple containers together with one command.

```yaml
# docker-compose.yml — place in the root of your project
version: '3.8'

services:

  # MongoDB database:
  mongo:
    image: mongo:7
    container_name: bookstore-mongo
    volumes:
      - mongo-data:/data/db
      # Persist MongoDB data even when container restarts
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: secret

  # Backend (Express API):
  backend:
    build:
      context: ./bookstore-backend
      dockerfile: Dockerfile
    container_name: bookstore-backend
    ports:
      - "5000:5000"
    environment:
      NODE_ENV: production
      MONGO_URI: mongodb://root:secret@mongo:27017/bookstore?authSource=admin
      # mongo: the service name — Docker resolves it to the MongoDB container's IP
      JWT_SECRET: your-secret-key
      PORT: 5000
    depends_on:
      - mongo
    # Wait for mongo to start before starting backend

  # Frontend (Angular):
  frontend:
    build:
      context: ./bookstore-frontend
      dockerfile: Dockerfile
    container_name: bookstore-frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  mongo-data:
  # Named volume — data survives container restarts and removals
```

```bash
# Start everything:
docker-compose up -d
# -d: detached (run in background)
# Builds images if they don't exist, then starts all containers

# View logs from all containers:
docker-compose logs -f

# Stop everything:
docker-compose down

# Stop and remove all data (MongoDB data too):
docker-compose down -v

# Rebuild after code changes:
docker-compose up -d --build
```

---

## 5.7 Environment Variables at Runtime

**The problem:** `environment.ts` is baked into the bundle at build time. If `apiUrl` is `https://api.yourbookstore.com` in the bundle, you can't change it without rebuilding.

**For static Angular apps (your case):** The apiUrl in `environment.production.ts` is sufficient. Rebuild for each environment.

**For dynamic runtime config (advanced):** Fetch config from a JSON file at startup:

```typescript
// app.config.ts — fetch config before bootstrapping
fetch('/assets/config.json')
  .then(r => r.json())
  .then(config => {
    // Store config globally:
    (window as any).APP_CONFIG = config;
  })
  .then(() => bootstrapApplication(App, appConfig));

// In services — read runtime config:
const apiUrl = (window as any).APP_CONFIG?.apiUrl || environment.apiUrl;
```

```json
// src/assets/config.json — can be replaced at deployment without rebuilding
{
  "apiUrl": "https://api.yourbookstore.com/api"
}
```

```dockerfile
# In Docker — replace config.json at container startup:
CMD envsubst < /usr/share/nginx/html/assets/config.template.json \
    > /usr/share/nginx/html/assets/config.json && nginx -g 'daemon off;'
```

---

---

# CHAPTER 6 — Deployment Targets

## 6.1 Deploying to a VPS (DigitalOcean / AWS EC2)

```bash
# On your local machine — build:
ng build --configuration=production

# Upload dist files to server:
rsync -avz dist/bookstore-frontend/browser/ user@your-server:/var/www/bookstore/browser/
# rsync: efficient file sync — only uploads changed files

# On the server — configure Nginx:
sudo nano /etc/nginx/sites-available/bookstore
# Paste the Nginx config from Chapter 4.3
sudo ln -s /etc/nginx/sites-available/bookstore /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Get HTTPS:
sudo certbot --nginx -d yourdomain.com
```

---

## 6.2 Deploying to Vercel (Easiest)

Vercel is the simplest deployment for Angular frontends. It handles the SPA routing automatically.

```bash
# Install Vercel CLI:
npm install -g vercel

# Deploy from your project folder:
cd bookstore-frontend
vercel

# Vercel asks:
# - Which directory to deploy? → dist/bookstore-frontend/browser
# - Override build command? → ng build
# - Override output directory? → dist/bookstore-frontend/browser

# For subsequent deploys:
vercel --prod
```

```json
// vercel.json — SPA routing configuration (required):
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/(.*\\.js|.*\\.css)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    }
  ]
}
```

---

## 6.3 Deploying to Netlify

```bash
# Install Netlify CLI:
npm install -g netlify-cli

# Build and deploy:
ng build --configuration=production
netlify deploy --dir=dist/bookstore-frontend/browser --prod
```

```toml
# netlify.toml — SPA routing + build config:
[build]
  command = "ng build --configuration=production"
  publish = "dist/bookstore-frontend/browser"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
  # 200 (not 301): serve index.html while keeping the original URL
  # This is the SPA routing fix for Netlify
```

---

## 6.4 GitHub Actions CI/CD — Automated Deployment

Every push to `main` automatically builds and deploys.

```yaml
# .github/workflows/deploy.yml

name: Build and Deploy

on:
  push:
    branches: [main]
  # Triggers on every push to the main branch

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          # cache: 'npm' — caches node_modules between runs (faster)

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: ng test --watch=false --browsers=ChromeHeadless
        # Run tests before deploying — fail fast if tests fail

      - name: Build
        run: ng build --configuration=production
        env:
          # Pass environment values if needed:
          NODE_OPTIONS: '--max_old_space_size=4096'
          # Increase Node.js memory for large builds

      - name: Deploy to server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "dist/bookstore-frontend/browser/"
          target: "/var/www/bookstore/browser"
          # Secrets are stored in GitHub repo settings → Secrets and Variables
          # Never hardcode passwords or SSH keys in the workflow file

      - name: Reload Nginx
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: sudo systemctl reload nginx
```

---

---

# CHAPTER 7 — Bookstore Deployment Checklist

## Pre-Deployment

```bash
# 1. Update environment.production.ts with real backend URL:
#    apiUrl: 'https://api.yourbookstore.com/api'

# 2. Run tests — fix any failures:
ng test --watch=false --browsers=ChromeHeadless

# 3. Build for production locally first:
ng build --configuration=production

# 4. Check for budget warnings:
#    If you see "WARNING: bundle initial exceeded budget":
#    - Analyze with: npx webpack-bundle-analyzer dist/.../stats.json
#    - Remove unused imports
#    - Increase budget in angular.json if justified

# 5. Test the production build locally:
npx http-server dist/bookstore-frontend/browser -p 4200 --proxy 'http://localhost:4200?'
#    Navigate to /books, /auth/login, /profile — verify routing works

# 6. Test on mobile:
#    Open http://YOUR_LOCAL_IP:4200 on your phone (same WiFi)
```

## Backend CORS — Critical for Production

```javascript
// In your Express backend — update CORS for production:
app.use(cors({
  origin: [
    'http://localhost:4200',              // local development
    'https://yourbookstore.com',          // production frontend URL
    'https://www.yourbookstore.com',      // with www
  ],
  credentials: true,
  // credentials: true if you send cookies (you use Bearer tokens so likely not needed)
}));
```

## Post-Deployment Verification

```
✅ Homepage loads (/)
✅ Can register a new account (/auth/register)
✅ Can login (/auth/login) → token appears in localStorage
✅ Navbar updates after login (Cart/Profile visible)
✅ Navigating to /profile works (not 404)
✅ Refreshing the page on /profile doesn't give 404 (SPA routing works)
✅ Authorization header sent with API calls (check Network tab)
✅ Logout works → redirects to login → Navbar shows guest state
✅ Navigating to /admin as non-admin → redirected to /
✅ HTTPS works (padlock icon in browser)
✅ HTTP redirects to HTTPS (certbot handles this)
```

---

## Full Deployment Commands Reference

```bash
# ─── BUILD ──────────────────────────────────────────────────────────────────
ng build                              # production build
ng build --configuration=staging      # staging build
ng build --watch                      # rebuild on changes

# ─── DOCKER ─────────────────────────────────────────────────────────────────
docker build -t bookstore-frontend .  # build image
docker run -d -p 80:80 bookstore-frontend  # run container
docker-compose up -d                  # start all services
docker-compose up -d --build          # rebuild and start
docker-compose logs -f frontend       # follow logs
docker-compose down                   # stop all
docker-compose down -v                # stop + remove volumes

# ─── NGINX ──────────────────────────────────────────────────────────────────
sudo nginx -t                         # test config syntax
sudo systemctl reload nginx           # reload without downtime
sudo systemctl restart nginx          # full restart
sudo certbot --nginx -d yourdomain.com  # get HTTPS certificate

# ─── VERCEL ─────────────────────────────────────────────────────────────────
vercel                                # deploy to preview
vercel --prod                         # deploy to production

# ─── NETLIFY ────────────────────────────────────────────────────────────────
netlify deploy --dir=dist/.../browser --prod
```

---

# Quick Reference — Deployment

```typescript
// environment.production.ts:
export const environment = {
  production: true,
  apiUrl: 'https://api.yourbookstore.com/api'
};

// Build:
// ng build --configuration=production

// Dockerfile (multi-stage):
// Stage 1: node:20-alpine → npm ci → ng build
// Stage 2: nginx:alpine → copy dist/ → custom nginx.conf

// nginx.conf SPA fix (CRITICAL):
// location / { try_files $uri $uri/ /index.html; }

// Docker Compose:
// docker-compose up -d --build

// Cache headers:
// Static assets (*.js, *.css): Cache-Control: public, max-age=31536000, immutable
// index.html:                  Cache-Control: no-cache
```

---

*End of Part 9 — Final part of the series.*

---

# 🎓 Complete Guide Summary

| Part | Topics | Pages |
|------|--------|-------|
| 1 | TypeScript Deep Dive + Angular Foundations (decorators, DI, change detection, template syntax, lifecycle) | Foundation |
| 2 | RxJS + AuthService + HttpClient + Interceptors + Guards | Infrastructure |
| 3 | Reactive Forms + Login/Register/Profile Pages + Navbar + Testing Steps + Error Reference | Pages |
| 4 | Component Communication (@Input/@Output/@ViewChild) + Signals + Routing Deep Dive | Advanced Concepts |
| 5 | Directives + Standalone vs NgModule History + Angular Animations | Framework Depth |
| 6 | Angular Material/CDK + Advanced Forms (async validators, cross-field, FormArray) | UI + Forms |
| 7 | HTTP Advanced (retry, cache, loading bar, cancellation) + Performance (OnPush, @defer, preloading) | Optimization |
| 8 | Testing (Jasmine, TestBed, HttpTestingController, component tests, guard tests) | Quality |
| 9 | Deployment (ng build, environments, Nginx, Docker, Docker Compose, CI/CD) | Production |

**You now have a complete, production-ready Angular education.**

---

# CHAPTER 8 — Build Configuration Deep Dive

## 8.1 angular.json — The Full Build Configuration

Every Angular project is configured through `angular.json`. Understanding it helps you customize builds, add environments, and optimize output.

```json
{
  "projects": {
    "bookstore-frontend": {
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:application",
          "options": {
            "outputPath": "dist/bookstore-frontend",
            "index": "src/index.html",
            "browser": "src/main.ts",
            "polyfills": ["zone.js"],
            "tsConfig": "tsconfig.app.json",
            "assets": [
              { "glob": "**/*", "input": "public" }
            ],
            "styles": ["src/styles.scss"],
            "scripts": []
          },
          "configurations": {
            "production": {
              "budgets": [
                { "type": "initial",          "maximumWarning": "500kB", "maximumError": "1MB" },
                { "type": "anyComponentStyle","maximumWarning": "4kB",   "maximumError": "8kB" }
              ],
              "outputHashing": "all",
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.production.ts"
                }
              ]
            },
            "development": {
              "optimization": false,
              "extractLicenses": false,
              "sourceMap": true,
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.development.ts"
                }
              ]
            }
          }
        }
      }
    }
  }
}
```

---

## 8.2 Optimization Flags — What They Do

```json
// production configuration options:
{
  "optimization": true,
  // Enables all these sub-options:
  // - scripts: minify JavaScript (removes whitespace, renames variables)
  // - styles: minify CSS
  // - fonts: inline critical font CSS (reduces render-blocking)

  "outputHashing": "all",
  // Adds content hash to file names: main-A3B7.js
  // 'all': hash all output files
  // 'bundles': hash only JS/CSS (not media)
  // 'media': hash only images/fonts
  // 'none': no hashing (bad for production caching)

  "sourceMap": false,
  // Source maps map minified code back to your original TypeScript
  // Disable in production to protect source code from being read
  // Enable for staging to debug production issues

  "extractLicenses": true,
  // Extract all third-party license comments into a 3rdpartylicenses.txt file
  // Required for license compliance in commercial products

  "namedChunks": false,
  // false: chunk files get hashed names (main-A3B7.js)
  // true: chunk files get readable names (book-list.js) — helpful for debugging

  "aot": true,
  // Ahead-of-Time compilation: compile templates at build time
  // NOT at runtime (which is what JIT = Just-In-Time does)
  // AOT advantages: smaller bundle (no compiler shipped), faster startup,
  // template errors caught at build time not at runtime

  "buildOptimizer": true,
  // Additional Angular-specific optimizations:
  // - Tree shakes Angular decorators
  // - Removes Angular framework debug information
  // Enabled automatically when optimization: true and aot: true
}
```

---

## 8.3 Environment Variables — Complete Configuration Per Stage

Your bookstore needs different values in development, staging, and production. Here is the complete setup:

```typescript
// src/environments/environment.ts  — used by default (development)
export const environment = {
  production:     false,
  apiUrl:         'http://localhost:5000/api',
  appVersion:     '1.0.0-dev',
  enableDebugLog: true,
  googleAnalytics: '',  // no analytics in dev
};

// src/environments/environment.staging.ts
export const environment = {
  production:     false,  // staging is not production
  apiUrl:         'https://staging-api.yourbookstore.com/api',
  appVersion:     '1.0.0-staging',
  enableDebugLog: true,   // keep debug logging for staging testing
  googleAnalytics: 'UA-STAGING-ID',
};

// src/environments/environment.production.ts
export const environment = {
  production:     true,
  apiUrl:         'https://api.yourbookstore.com/api',
  appVersion:     '1.0.0',
  enableDebugLog: false,  // no console.log in production
  googleAnalytics: 'UA-YOUR-REAL-ID',
};
```

```json
// angular.json — add staging configuration:
{
  "configurations": {
    "staging": {
      "fileReplacements": [{
        "replace": "src/environments/environment.ts",
        "with": "src/environments/environment.staging.ts"
      }],
      "optimization": true,
      "outputHashing": "all",
      "sourceMap": true,
      "namedChunks": true
    }
  }
}
```

```typescript
// Use environment in services:
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class BookService {
  private api = `${environment.apiUrl}/books`;

  constructor() {
    if (environment.enableDebugLog) {
      console.log('BookService initialized. API:', this.api);
    }
  }
}
```

---

## 8.4 Build Scripts in package.json

```json
{
  "scripts": {
    "start":        "ng serve",
    "start:prod":   "ng serve --configuration=production",
    "build":        "ng build --configuration=production",
    "build:staging":"ng build --configuration=staging",
    "build:dev":    "ng build --configuration=development",
    "test":         "ng test",
    "test:ci":      "ng test --watch=false --browsers=ChromeHeadless",
    "test:coverage":"ng test --code-coverage --watch=false --browsers=ChromeHeadless",
    "lint":         "ng lint",
    "analyze":      "ng build --stats-json && npx webpack-bundle-analyzer dist/bookstore-frontend/browser/stats.json"
  }
}
```

---

# CHAPTER 9 — Docker Compose: Complete Production Stack

## 9.1 Full Stack Docker Compose — Every Property Explained

```yaml
version: '3.8'
# Version of the Docker Compose file format.
# 3.8 supports all modern Docker features.

services:
  # ─── DATABASE ───────────────────────────────────────────────────────────────
  mongo:
    image: mongo:7
    # Use the official MongoDB 7 image from Docker Hub
    # ':7' = latest MongoDB 7.x release (minor versions update automatically)
    # For strict version pinning: 'mongo:7.0.5' (exact version)

    container_name: bookstore-mongo
    # Human-readable name for this container
    # Used in docker ps output and docker logs bookstore-mongo

    restart: unless-stopped
    # Restart the container if it crashes or the server reboots
    # Options: 'no', 'always', 'on-failure', 'unless-stopped'
    # 'unless-stopped': restart automatically UNLESS you manually stopped it

    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
      # ${MONGO_PASSWORD}: reads from a .env file in the same directory as docker-compose.yml
      # NEVER hardcode passwords in docker-compose.yml (it goes in git)
      # Create a .env file (add to .gitignore) with: MONGO_PASSWORD=your-secret

      MONGO_INITDB_DATABASE: bookstore
      # Creates this database automatically on first startup

    volumes:
      - mongo-data:/data/db
      # mongo-data: named volume (defined at bottom of file)
      # /data/db: where MongoDB stores its data files inside the container
      # Without this volume: all data is lost when container restarts
      # With this volume: data persists across container restarts and even image updates

    ports:
      - "27017:27017"
      # host:container — expose MongoDB port to host machine
      # Only needed for local development (connecting with MongoDB Compass)
      # Remove in production if you don't need direct DB access

    networks:
      - bookstore-network
      # Connect to custom network — containers on same network can reach each other
      # by service name (e.g. backend connects to mongo using host 'mongo')

  # ─── BACKEND API ────────────────────────────────────────────────────────────
  backend:
    build:
      context: ./bookstore-backend
      # context: the directory sent to Docker as the build context
      # All files in this directory are available to the Dockerfile

      dockerfile: Dockerfile
      # The name of the Dockerfile (default is 'Dockerfile')

    container_name: bookstore-backend

    restart: unless-stopped

    environment:
      NODE_ENV: production
      PORT: 5000
      MONGO_URI: mongodb://root:${MONGO_PASSWORD}@mongo:27017/bookstore?authSource=admin
      # 'mongo' in the URI refers to the 'mongo' SERVICE NAME above
      # Docker's DNS resolves 'mongo' to the MongoDB container's IP automatically
      # This is why they must be on the same network

      JWT_SECRET: ${JWT_SECRET}
      # From .env file — never hardcode secrets

    ports:
      - "5000:5000"

    depends_on:
      mongo:
        condition: service_healthy
        # Wait until MongoDB passes its health check before starting backend
        # Without this, backend might try to connect before MongoDB is ready

    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:5000/api/health"]
      # Health check: ping the /api/health endpoint
      # If it responds, the service is healthy
      interval: 30s   # check every 30 seconds
      timeout: 10s    # wait up to 10 seconds for a response
      retries: 3      # mark unhealthy after 3 consecutive failures
      start_period: 40s # wait 40s after start before checking (startup time)

    networks:
      - bookstore-network

    volumes:
      - ./bookstore-backend/uploads:/app/uploads
      # Persist uploaded files (book covers) on the host machine
      # If the backend container is replaced, uploads survive

  # ─── FRONTEND ───────────────────────────────────────────────────────────────
  frontend:
    build:
      context: ./bookstore-frontend
      dockerfile: Dockerfile

    container_name: bookstore-frontend

    restart: unless-stopped

    ports:
      - "80:80"
      - "443:443"
      # Expose both HTTP and HTTPS
      # HTTPS requires SSL certificates (see Nginx + Certbot section)

    depends_on:
      backend:
        condition: service_healthy
        # Wait until backend is healthy before starting frontend
        # (technically not required since frontend is static — but good practice)

    networks:
      - bookstore-network

# ─── VOLUMES ──────────────────────────────────────────────────────────────────
volumes:
  mongo-data:
    # Named volume — managed by Docker
    # Stored at: /var/lib/docker/volumes/bookstore_mongo-data
    # Survives: container stop, container rm, docker-compose down
    # Deleted only by: docker-compose down -v OR docker volume rm bookstore_mongo-data

# ─── NETWORKS ─────────────────────────────────────────────────────────────────
networks:
  bookstore-network:
    driver: bridge
    # bridge: standard Docker network
    # Containers on this network can talk to each other by service name
    # Containers are isolated from containers on other networks
```

---

## 9.2 The .env File — Secrets Management

```bash
# .env — place in same directory as docker-compose.yml
# ADD THIS FILE TO .gitignore — NEVER commit secrets

MONGO_PASSWORD=your-very-secure-password-here
JWT_SECRET=your-long-random-jwt-secret-at-least-32-chars
BACKEND_PORT=5000
FRONTEND_PORT=80
```

```bash
# .env.example — COMMIT THIS (template for other developers)
MONGO_PASSWORD=
JWT_SECRET=
BACKEND_PORT=5000
FRONTEND_PORT=80
# Copy this file to .env and fill in the values
```

```bash
# In docker-compose.yml — reference env vars:
environment:
  JWT_SECRET: ${JWT_SECRET}
  # Docker Compose reads from .env automatically

# From command line — override for specific deployment:
MONGO_PASSWORD=prod-secret JWT_SECRET=prod-jwt docker-compose up -d
```

---

## 9.3 Multi-Stage Backend Dockerfile

For completeness — your Express backend should also have a proper Dockerfile:

```dockerfile
# bookstore-backend/Dockerfile

# ─── STAGE 1: DEPENDENCIES ────────────────────────────────────────────────────
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
# --omit=dev: skip devDependencies (nodemon, jest, typescript types etc.)
# Result: only production packages — smaller final image

# ─── STAGE 2: RUN ─────────────────────────────────────────────────────────────
FROM node:20-alpine AS run
# Start fresh — don't carry over the build environment
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
# Copy only production node_modules from deps stage

COPY . .
# Copy application source code

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup
# Create a non-root user for security
# Running as root inside containers is a security risk

USER nodeuser
# Switch to non-root user for the remaining commands and CMD

EXPOSE 5000

# Health check — Docker will monitor this:
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:5000/api/health || exit 1

CMD ["node", "server.js"]
# Start the Express server
# NOT: "nodemon server.js" — nodemon is for development only
```

---

## 9.4 CI/CD with GitHub Actions — Complete Workflow

```yaml
# .github/workflows/deploy.yml

name: Test, Build, and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
    # Run tests on PRs but don't deploy

env:
  NODE_VERSION: '20'
  IMAGE_NAME: bookstore-frontend

jobs:
  # ─── JOB 1: TEST ──────────────────────────────────────────────────────────
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ env.NODE_VERSION }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: bookstore-frontend/package-lock.json

      - name: Install dependencies
        working-directory: bookstore-frontend
        run: npm ci

      - name: Run unit tests
        working-directory: bookstore-frontend
        run: npm run test:ci
        # npm run test:ci = ng test --watch=false --browsers=ChromeHeadless

      - name: Upload coverage report
        uses: codecov/codecov-action@v3
        # Uploads coverage to codecov.io (free for open source)
        with:
          directory: bookstore-frontend/coverage

  # ─── JOB 2: BUILD ─────────────────────────────────────────────────────────
  build:
    needs: test  # only runs if tests pass
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'  # only on main branch (not PRs)

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: bookstore-frontend/package-lock.json

      - name: Install dependencies
        working-directory: bookstore-frontend
        run: npm ci

      - name: Build for production
        working-directory: bookstore-frontend
        run: npm run build
        env:
          NODE_OPTIONS: '--max_old_space_size=4096'

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: frontend-build
          path: bookstore-frontend/dist/bookstore-frontend/browser
          retention-days: 1
          # Keep the build artifact for 1 day (used by the deploy job)

  # ─── JOB 3: DEPLOY ────────────────────────────────────────────────────────
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production  # requires manual approval in GitHub settings

    steps:
      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: frontend-build
          path: dist

      - name: Deploy to server via SCP
        uses: appleboy/scp-action@v0.1.7
        with:
          host:     ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key:      ${{ secrets.SSH_PRIVATE_KEY }}
          source:   "dist/*"
          target:   "/var/www/bookstore/browser"
          rm:       true
          # rm: true — remove old files before uploading new ones

      - name: Reload Nginx
        uses: appleboy/ssh-action@v1.0.0
        with:
          host:     ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key:      ${{ secrets.SSH_PRIVATE_KEY }}
          script:   |
            sudo systemctl reload nginx
            echo "Deployment completed at $(date)"

      - name: Notify on success
        if: success()
        run: echo "✅ Deployed successfully to production"

      - name: Notify on failure
        if: failure()
        run: echo "❌ Deployment failed"
        # In real projects: send Slack/email notification
```

---

## 9.5 SSL/HTTPS in Docker with Nginx

For Docker deployments that need HTTPS:

```dockerfile
# Nginx Dockerfile with SSL support:
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/bookstore-frontend/browser /usr/share/nginx/html

VOLUME ["/etc/nginx/ssl"]
# SSL certificates are mounted at runtime, not baked into the image
# This allows certificate renewal without rebuilding the image

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
```

```nginx
# nginx.conf — with HTTPS:
server {
    listen 80;
    server_name yourbookstore.com www.yourbookstore.com;
    return 301 https://$server_name$request_uri;
    # Redirect all HTTP to HTTPS
}

server {
    listen 443 ssl http2;
    server_name yourbookstore.com www.yourbookstore.com;

    ssl_certificate     /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    # Certificates from Certbot (Let's Encrypt) or your SSL provider

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location = /index.html {
        add_header Cache-Control "no-cache";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    gzip_min_length 1000;

    # Security headers:
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

```yaml
# docker-compose.yml — mount certificates:
frontend:
  volumes:
    - /etc/letsencrypt/live/yourbookstore.com:/etc/nginx/ssl:ro
    # :ro = read-only — Nginx only needs to read certificates, not write them
    # /etc/letsencrypt/live/...: where Certbot puts certificates on the host
```

---

## 9.6 Vercel Deployment — Step by Step

Vercel is the easiest zero-configuration deployment for Angular frontends:

```bash
# 1. Install Vercel CLI globally:
npm install -g vercel

# 2. Log in:
vercel login
# Opens browser — log in with GitHub/GitLab/Email

# 3. From your Angular project root:
vercel

# Vercel will ask:
# Set up and deploy? → Y
# Which scope? → your account name
# Link to existing project? → N (first deploy) or Y (redeploying)
# What's your project's name? → bookstore-frontend
# In which directory is your code? → ./ (current)
# Want to override settings? → Y
#   → Build Command: ng build --configuration=production
#   → Output Directory: dist/bookstore-frontend/browser
#   → Install Command: npm ci

# 4. First deploy goes to a preview URL: https://bookstore-frontend-abc.vercel.app

# 5. Deploy to production:
vercel --prod
# → https://bookstore-frontend.vercel.app
```

```json
// vercel.json — required for SPA routing and caching:
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/index.html",
      "headers": [
        { "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }
      ]
    },
    {
      "source": "/(.*\\.(js|css|png|jpg|jpeg|gif|ico|woff|woff2|svg)$)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ],
  "buildCommand": "ng build --configuration=production",
  "outputDirectory": "dist/bookstore-frontend/browser",
  "installCommand": "npm ci"
}
```

**Setting environment variables in Vercel:**

```bash
# Via CLI:
vercel env add API_URL production
# Vercel prompts for the value — never appears in your code or git

# Or in Vercel dashboard:
# Project → Settings → Environment Variables
# Add: API_URL = https://api.yourbookstore.com/api
# Select: Production / Preview / Development
```

**Important:** Vercel environment variables injected at RUNTIME are only available to server-side code. Angular runs in the browser — use `environment.ts` file replacement for Angular environment variables.

---

## 9.7 Common Deployment Mistakes

**Mistake 1: Not fixing SPA routing on the server**

```
Symptom: App loads on /, but refreshing /books shows "404 Not Found"
Cause:   Server tries to find a file called 'books' — doesn't exist
Fix:     Nginx: try_files $uri $uri/ /index.html;
         Vercel: "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
         Netlify: [[redirects]] from = "/*" to = "/index.html" status = 200
```

**Mistake 2: CORS errors after deployment**

```
Symptom: API calls work locally, fail in production with "CORS error"
Cause:   Backend only allows localhost:4200, not yourbookstore.com
Fix:     Update backend CORS:
         app.use(cors({ origin: ['http://localhost:4200', 'https://yourbookstore.com'] }))
```

**Mistake 3: API URL hardcoded to localhost**

```
Symptom: All API calls fail in production — they hit localhost:5000 which doesn't exist
Cause:   environment.production.ts still has apiUrl: 'http://localhost:5000/api'
Fix:     Update environment.production.ts → rebuild → redeploy
```

**Mistake 4: Deploying development build to production**

```
Symptom: App is very slow, bundle size is 5MB+
Cause:   ng build --configuration=development was used
Fix:     Always use ng build --configuration=production for deployment
         Check package.json "build" script points to production config
```

**Mistake 5: Not setting Cache-Control for index.html**

```
Symptom: Users run old version of app even after you deployed a new one
Cause:   Browser cached index.html (which references old bundle filenames)
Fix:     Add Cache-Control: no-cache to index.html response headers
         Nginx: location = /index.html { add_header Cache-Control "no-cache"; }
         Vercel: headers for /index.html with no-cache value
```

---

# Full Deployment Checklist — Bookstore

## Before First Deployment

```bash
# 1. Update environment.production.ts:
#    apiUrl: 'https://api.yourbookstore.com/api'

# 2. Build and inspect:
ng build --configuration=production
ls -la dist/bookstore-frontend/browser/
# Verify files are there, check sizes

# 3. Test production build locally:
npx http-server dist/bookstore-frontend/browser -p 4200 \
    --proxy 'http://localhost:4200?'
# Open http://localhost:4200 in browser
# Test: register, login, books page, refresh on /books, profile

# 4. Check bundle sizes:
cat dist/bookstore-frontend/browser/*.js | wc -c
# Should be under 1MB total for a medium app

# 5. Check for console errors:
# Open DevTools → Console — should be clean in production build

# 6. Update backend CORS to include production domain
```

## Server Setup (VPS)

```bash
# Install Nginx:
sudo apt update && sudo apt install -y nginx certbot python3-certbot-nginx

# Upload built files:
rsync -avz --delete dist/bookstore-frontend/browser/ \
    user@your-server:/var/www/bookstore/browser/

# Create Nginx config (see Chapter 4.3)
# Enable site, test config, reload

# Get SSL certificate:
sudo certbot --nginx -d yourbookstore.com -d www.yourbookstore.com

# Verify HTTPS works:
curl -I https://yourbookstore.com
# Should see: HTTP/2 200 and Strict-Transport-Security header
```

## Ongoing Deployment Process

```bash
# Every time you push changes:
ng build --configuration=production
rsync -avz --delete dist/bookstore-frontend/browser/ \
    user@your-server:/var/www/bookstore/browser/
# (or: push to GitHub → GitHub Actions deploys automatically)
```

---

# Quick Reference — Deployment

```bash
# Build commands:
ng build                                # production (default)
ng build --configuration=staging        # staging
ng build --configuration=development    # development

# Docker:
docker build -t app-name .
docker run -d -p 80:80 app-name
docker-compose up -d --build
docker-compose logs -f
docker-compose down -v  # remove volumes too

# Nginx SPA fix (REQUIRED):
location / { try_files $uri $uri/ /index.html; }

# Cache headers:
*.js, *.css:   Cache-Control: public, max-age=31536000, immutable
index.html:    Cache-Control: no-cache, no-store, must-revalidate

# Vercel:
vercel --prod
# vercel.json: "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]

# GitHub Actions:
# test job → build job → deploy job
# Uses: actions/checkout, actions/setup-node, appleboy/scp-action, appleboy/ssh-action

# Common deployment bugs:
# 404 on refresh → missing SPA routing fix on server
# CORS error → backend origin list missing production domain
# Old version after deploy → index.html cache headers not set
# Slow app → accidentally deployed development build
```

---

*End of Part 9 (fully expanded). This completes the 9-part Angular Complete Tutorial.*

---

# 🎓 Complete Guide — Final Summary

| Part | Core Topics | Approximate Words |
|------|-------------|-------------------|
| **1** | TypeScript generics, decorators, DI, template syntax, lifecycle hooks | ~7,400 |
| **2** | RxJS deep dive, AuthService, HttpClient, interceptors, guards, routes | ~7,500 |
| **3** | Reactive Forms, Login/Register/Profile pages, Navbar, error reference | ~8,400 |
| **4** | Component communication, Angular Signals, Routing deep dive | ~4,600 |
| **5** | Directives (tooltip, permissions, Renderer2), NgModule history, Animations | ~7,800 |
| **6** | Angular Material/CDK, cross-field validators, async validators, FormArray | ~4,600 |
| **7** | HTTP advanced (retry, cache, loading bar, polling), OnPush, @defer, performance | ~4,700 |
| **8** | Testing with Jasmine, TestBed, HttpTestingController, signal tests, guard tests | ~5,300 |
| **9** | ng build, environments, Nginx, Docker, Docker Compose, CI/CD, Vercel | ~7,000 |

**Everything you need to build, test, and deploy a professional Angular application.**
