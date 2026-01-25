# Code Review & Refactoring Report

**Date:** 2026-01-25 **Project:** Mazer

This report outlines areas of the codebase where the **DRY (Don't Repeat Yourself)** principle is violated, where redundancy exists, and offers architectural recommendations to improve maintainability.

---

## 🛑 Critical DRY Violations

### 1. Magic Numbers & Hardcoded Constants

Multiple files contain hardcoded values that should be centralized. If these values need to change, they must currently be updated in multiple locations, leading to bugs.

- **`TILE_SIZE = 120`**:
    
    - Found in: 
        
        js/core/Game.js, 
        
        js/maze/Maze.js.
    - Implicitly used in: 
        
        js/core/Camera.js (passed as argument, but relies on caller).
    - **Fix**: Create `js/core/Constants.js` and export `export const TILE_SIZE = 120;`.
- **Direction Mapping**:
    
    - Found in: 
        
        PlayerMovement.js, 
        
        EnemyMovement.js, 
        
        Game.js.
    - Logic: `0: Up, 1: Left, 2: Down, 3: Right` is manually checked in multiple 
        
        if statements.
    - **Fix**: Define `export const Directions = { UP: 0, LEFT: 1, DOWN: 2, RIGHT: 3 };` in Constants.
- **Audio Paths**:
    
    - Found in: 
        
        js/navigation.js and 
        
        js/core/Game.js (implicit loading).
    - **Fix**: Store asset paths in a configuration object or resource manager.

### 2. Logic Duplication

- **Boundary Checking (**
    
    **isInsideMaze)**:
    
    - js/maze/Maze.js has 
        
        isInsideMaze().
    - js/player/PlayerMovement.js implements similar logic manually (`x < 0 || x >= width...`).
    - js/enemies/EnemyMovement.js implements the same manual logic.
    - **Fix**: Export 
        
        isInsideMaze and 
        
        isWall from 
        
        Maze.js and import them in movement controllers.
- **Collision/Movement Math**:
    
    - Both 
        
        Player and 
        
        Enemy calculate target positions (`x + dx`, `y + dy`) separately using switch/if statements.
    - **Fix**: Create a `MovementSystem` or utility function `getNextPosition(x, y, dir)` to handle coordinate math.

---

## ⚠️ Redundancy & Architectural Issues

### 1. Canvas Context (`ctx`) Management

- **Issue**:
    - Game.js obtains `ctx` from the DOM: `this.ctx = ...`.
    - Maze.js _independently_ obtains `ctx` from the DOM: `const ctx = canvas.getContext("2d")`.
- **Risk**: If the canvas ID changes or you switch to an offscreen canvas, 
    
    Maze.js will break or draw to the wrong target.
- **Fix**: Pass `ctx` explicitly to 
    
    renderMaze() or make 
    
    Maze a class that is initialized with a context.

### 2. Audio State Management

- **Issue**:
    - navigation.js handles background music and SFX.
    - Game.js triggers 
        
        playLevelMusic.
- **Risk**: Audio state (playing/paused/volume) is scattered.
- **Fix**: Encapsulate audio logic in an `AudioManager` class that handles all playback, volume, and muting states centrally.

### 3. Loop Handling

- **Issue**: 
    
    Game.js has a main loop, but 
    
    Maze.js has an 
    
    animateKeys function that seems to rely on being called within that loop (or potentially runs its own frame logic if not careful).
- **Fix**: Ensure a single "Source of Truth" game loop in 
    
    Game.js that calls 
    
    update() and 
    
    draw() on all subsystems.

---

## 🎨 CSS & Frontend Review

- **Variables Usage**: Good usage of CSS variables in 
    
    _variables.css.
- **Redundancy**: Some hardcoded pixel values (e.g., in `screens/_home.css` or `_modal.css` effectively checked via git diffs) often mirror `TILE_SIZE` related dimensions.
- **Recommendation**: Use CSS variables for game-board relative dimensions if possible, or generate them via JS for consistency.

---

## 🚀 Recommended Action Plan

1. **Phase 1: Safe Logic Refactor**
    
    - Create `js/core/Constants.js`.
    - Replace all `120` and direction literals with imports.
    - Export 
        
        isInsideMaze from 
        
        Maze.js and use it in 
        
        PlayerMovement/
        
        EnemyMovement.
2. **Phase 2: Architectural Cleanup**
    
    - Refactor 
        
        Maze.js from a module of functions into a 
        
        Maze class that accepts `ctx` in its constructor.
    - Create `AudioManager.js` to replace scattered audio calls in 
        
        navigation.js.
3. **Phase 3: Code cleanup**
    
    - Remove unused images/assets (Already partially done).
    - Standardize event listener attachment (centralize Input handling).