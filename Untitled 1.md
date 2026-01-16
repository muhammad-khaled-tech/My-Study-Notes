# 🎮 Mazer - ITI Client-Side Technology Project - Discussion & Planning

## 👋 Introduction

I'm part of a team of 5 students at ITI (Information Technology Institute) working on our final client-side technology project. We need your help to **discuss, refine, and finalize** our game concept before creating the implementation plan.

**⚠️ Important**: Please **DO NOT jump to creating a plan immediately**. I want to have a **collaborative discussion** first where you:

1. Review our current ideas and requirements
2. Ask clarifying questions about unclear aspects
3. Suggest improvements and alternatives
4. Challenge our assumptions constructively
5. Help us refine the scope to fit our timeline
6. **Only AFTER discussion**, create the final comprehensive plan

---

## 👥 Team Information

### Team Members (5 people):

1. **محمد خالد (Mohamed Khaled)** 
2. **مصطفى خليفة (Mostafa Khalifa)**
3. **أحمد إيهاب (Ahmed Ehab)** 
4. **منه محمد (Menna Mohamed)**
5. **مهند سامح (Mohanad Sameh)** 


---

## 📅 Timeline & Constraints

- **Start Date**: January 17, 2026 (tomorrow)
- **Deadline**: January 24, 2026 (23:59)
- **Available Time**: **8 days** (7 working days + 1 buffer)
- **Project Type**: Client-side web game (HTML, CSS, Vanilla JavaScript only)

### Technical Requirements:

- ✅ HTML, CSS, JavaScript only (no frameworks)
- ✅ Movement: Mouse OR Keyboard (we chose keyboard)
- ✅ Acceptable design
- ✅ Scoring system
- ✅ Save user progress (localStorage)
- ✅ GitHub delivery
- ✅ Every team member must have commits
- ✅ Unique game (not duplicated by other teams)

---

## 🎮 Game Concept: "Mazer"

### Core Idea:

A 2D top-down Egyptian pyramid maze game where an archaeologist explores ancient pyramids, discovers that the ancient Pharaohs invented programming, and must escape while solving coding puzzles.

### Story Concept:

"Dr. Zahi, a young Egyptian archaeologist, discovers a secret entrance to a forgotten pyramid in Saqqara. While searching for the legendary 'Gem of Ra,' the entrance collapses behind him. Deep inside, he discovers ancient hieroglyphics that reveal the Pharaohs were the first to invent programming! Now he must escape by understanding their ancient 'code' while racing against time."

---

## 🎯 Game Features (Confirmed)

### Core Mechanics:

1. **Player Movement**: Arrow keys (⬆️⬇️⬅️➡️)
2. **Objective**: Collect keys to unlock the door and escape each level
3. **Health System**: Hearts (❤️❤️❤️) - lose on damage from enemies or wrong answers
4. **Timer**: Each level has a countdown
5. **Scoring**: Points from keys, gems, remaining time, health

### Unique Feature: Code Questions

- **When**: If player reaches door without ALL keys (e.g., has 3/5 keys)
- **What**: Simple JavaScript quiz question appears (15 seconds to answer)
    - Example: "What is the output? `console.log(2 + 2);`"
    - Choices: [2] [4] [22] [NaN]
- **Wrong Answer**: Lose 1 heart ❤️, can retry
- **Right Answer**: Door unlocks (compensates for missing keys)
- **Question Difficulty**: Easy (basic output, simple syntax)

### Story Videos (Veo 3):

- **Intro Video**: Character enters pyramid, discovers secret
- **Between Levels**: Short 10-15 second story progression
    - After Level 1: "Discovered the first ancient code..."
    - After Level 2: "Found the secret of algorithms..."
- **Outro Video**: Character escapes with knowledge
- **Total**: 5 videos (Intro + 3 transitions + Outro)

### Level Structure:

- **3 Levels** (feasible in 8 days)
- **Progressive Difficulty**:
    - Level 1: Simple maze, 1 enemy, 60 seconds
    - Level 2: Medium maze, 2 enemies, 90 seconds
    - Level 3: Complex maze, 3 enemies, 120 seconds

### Enemies:

- **Type**: Mummies (🧟) - one type to keep it simple
- **Behavior**: Move in fixed patrol patterns
- **Collision**: Touch = lose 1 heart ❤️

### Collectibles:

- **Keys** (🔑): 3-5 per level (must collect to unlock door)
- **Health** (❤️): Optional health pickups
- **Gems** (💎): Bonus points (optional)

---

## 🎨 Visual Style & Assets

### Art Style Decision:

**Pixel Art** - 2D top-down perspective

### Asset Creation Method:

1. **Character Sprites**: Generated using **Nanobana** with professional prompts
2. **Environment Tiles**: Generated using **Nanobana** with professional prompts
3. **Story Videos**: Generated using **Veo 3** with cinematic prompts

### Required Sprite Sheets:

1. **Player (Explorer)**:
    
    - Size: 32×32 pixels per frame
    - Layout: 4 directions × 4 frames = 128×128 image
    - Directions: Down, Up, Left, Right
2. **Enemy (Mummy)**:
    
    - Size: 32×32 pixels per frame
    - Layout: 4 directions × 4 frames = 128×128 image
3. **Items** (animated):
    
    - Keys, Hearts, Gems
    - Size: 32×32 each, 4 animation frames

### Required Tileset:

- **Environment Tiles**:
    - Walls (4 variations with different hieroglyphics)
    - Floors (4 variations: plain, decorated, carpet, cracked)
    - Doors (closed, open, magic portal, golden)
    - Size: 64×64 pixels per tile
    - Layout: 4×3 grid = 256×192 image

---

## 🖥️ Technical Architecture (Initial Thoughts)

### File Structure (proposed):

mazer/

├── index.html

├── css/

│   ├── style.css       (global styles)

│   ├── game.css        (game canvas styles)

│   └── responsive.css  (mobile adaptation)

├── js/

│   ├── main.js         (game initialization)

│   ├── player.js       (player logic)

│   ├── enemy.js        (enemy AI)

│   ├── maze.js         (maze rendering)

│   ├── collision.js    (collision detection)

│   ├── ui.js           (menus, HUD, questions)

│   ├── levels.js       (level data)

│   └── storage.js      (localStorage)

├── assets/

│   ├── sprites/        (character sprites)

│   ├── tiles/          (environment tiles)

│   ├── sounds/         (audio files)

│   └── videos/         (story videos)

└── README.md

### Technology Stack:

- **Rendering**: HTML5 Canvas API
- **Animation**: requestAnimationFrame
- **Storage**: localStorage for save/progress
- **Audio**: HTML5 Audio API
- **Responsive**: CSS media queries + canvas scaling

---

## 📱 Responsiveness Requirements

### Target Devices:

- **Desktop**: 1920×1080, 1366×768 (primary)
- **Tablet**: 768×1024 (landscape/portrait)
- **Mobile**: 375×667, 414×896 (portrait - should work but not priority)

### Approach:

- Canvas scaling based on viewport
- Touch controls for mobile (optional, time permitting)
- Responsive UI elements
- Testing on real devices by team

---

## 🔄 GitHub Workflow (Proposed)

### Branch Strategy:

main (production)

└── dev (integration)

    ├── feature/player-movement    (Mohamed)

    ├── feature/maze-rendering     (Mostafa)

    ├── feature/collision          (Ahmed)

    ├── feature/ui-menus           (Menna)

    └── feature/assets-integration (Mohanad)

### Commit Convention:

- `feat: add player sprite animation`
- `fix: collision detection bug`
- `style: update Egyptian theme colors`
- `docs: update README with controls`

### Team Responsibilities:

- **Mohamed**: Core engine, player, code review
- **Mostafa**: Maze system, enemy AI, collision
- **Ahmed**: UI, scoring, localStorage
- **Menna**: HTML structure, CSS, asset collection
- **Mohanad**: Level design (on paper), testing, documentation

---

## ❓ Questions for Discussion

Before creating the plan, I need your input on:

### 1. Scope & Feasibility:

- Is 3 levels realistic in 8 days for our skill levels?
- Should we simplify any features? (e.g., only 1 enemy type is fine?)
- Are the story videos essential or "nice-to-have"?

### 2. Technical Decisions:

- Should we use ES6 modules or keep everything in global scope for simplicity?
- Canvas rendering vs. DOM manipulation - is Canvas the right choice?
- How to structure the game loop efficiently?

### 3. Asset Creation:

- Should we generate ALL assets with AI, or mix with free resources?
- What's the best prompt structure for Nanobana to ensure consistency?
- Backup plan if Nanobana doesn't produce usable sprites?

### 4. Team Coordination:

- How to ensure beginners (Menna, Mohanad) contribute meaningfully without blocking progress?
- Should we pair program (advanced + beginner)?
- Daily standup format?

### 5. Responsive Design:

- Should we build "mobile-first" or "desktop-first"?
- Is it okay if mobile experience is "acceptable" rather than "perfect"?

### 6. Testing & QA:

- Who handles cross-browser testing?
- When should we start testing (continuous vs. final phase)?

---

## 🎯 What I Need From You

### Phase 1: Discussion (Now)

1. **Review** our concept and requirements
2. **Ask** clarifying questions about anything unclear
3. **Challenge** our assumptions (too ambitious? missing something?)
4. **Suggest** improvements, alternatives, or simplifications
5. **Validate** our technical choices or recommend better approaches

### Phase 2: Refinement (After Discussion)

- Help us adjust scope based on timeline reality
- Optimize team member assignments
- Identify potential blockers early

### Phase 3: Final Deliverables (After We Agree)

Only create these AFTER we've discussed and refined:

1. **Detailed Implementation Plan**:
    
    - Day-by-day breakdown (Jan 17-24)
    - Exact tasks per team member
    - Dependencies and critical path
    - Buffer time for issues
2. **Professional Asset Prompts**:
    
    - Complete Nanobana prompts for each sprite/tileset
    - Veo 3 prompts for each story video
    - Specifications (dimensions, style, colors)
3. **Technical Architecture Document**:
    
    - Detailed file structure
    - Code organization patterns
    - API/interface between modules
4. **Complete Asset List**:
    
    - Every sprite sheet needed
    - Every tile needed
    - Every sound effect
    - Every video
    - With exact specifications
5. **Git Workflow Guide**:
    
    - Branch naming conventions
    - PR review process
    - Merge strategy
6. **Responsive Design Strategy**:
    
    - Breakpoints
    - Canvas scaling formula
    - UI adaptation rules

---

## 🚨 Important Notes

- **Simplicity Over Features**: We prefer a polished 3-level game over a buggy 5-level game
- **Learning vs. Shipping**: We're okay learning new things but need to ship on time
- **Individual Commits**: Every member MUST have commits (requirement)
- **No Frameworks**: Pure HTML/CSS/JS only (school requirement)
- **Uniqueness**: Game must be different from other teams

---

## 💬 Let's Discuss!

Please start by:

1. Telling me your initial thoughts on feasibility
2. Asking any clarifying questions
3. Pointing out potential risks or challenges
4. Suggesting any improvements to the concept

**Remember**: I want a discussion first, NOT a final plan yet. Let's refine this together