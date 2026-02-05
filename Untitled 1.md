# 📘 MAZER PROJECT - COMPLETE TECHNICAL REVIEW & INTERVIEW PREPARATION

**Project:** MAZER - Egyptian Tomb Maze Game  
**Tech Stack:** HTML5, CSS3, Vanilla JavaScript (ES6+)  
**Architecture:** Object-Oriented, Module-Based, Canvas-Rendered Game  
**Target:** ITI Project Discussion + Technical Interview Preparation

---

# PART 1 — PROJECT HIGH LEVEL OVERVIEW

## 1.1 What This Project Is

**MAZER** is a 2D top-down maze escape game with an Ancient Egyptian tomb theme. The player navigates through progressively difficult mazes, collecting keys to unlock the exit door while avoiding traps and enemies (mummies).

**Core Concept:**

- **Genre:** Puzzle-Adventure / Maze Navigation
- **Perspective:** Top-down 2D with limited visibility (fog of war effect)
- **Objective:** Collect all 3 keys in each level to unlock the exit door, survive traps and enemies, complete 3 levels before time runs out
- **Theme:** Ancient Egyptian burial chamber with hieroglyphics, mummies, and atmospheric sound design

**User Experience Flow:**

1. Player starts at home screen with Egyptian-themed UI
2. Can start new game, load saved game, or adjust settings
3. Gate animation transitions between screens (immersive experience)
4. Gameplay involves strategic maze navigation with limited visibility
5. Save/load system allows progress persistence
6. Progressive difficulty across 3 levels

## 1.2 Tech Stack Breakdown

### HTML → Structure

**Role:** Semantic markup for game screens and UI elements

**Key Functions:**

- Multiple `<section>` elements represent different game screens (home, game, settings, win/lose)
- `<dialog>` elements for modals (pause menu, rules, confirmations)
- Single `<canvas>` element for game rendering (1180x510px)
- HUD elements embedded in HTML for live game stats
- Screen switching handled through CSS classes (`.active`)

**Why This Matters:**

- Screen-based architecture allows easy navigation without page reloads
- Canvas provides high-performance 2D rendering for game graphics
- Dialog elements provide native modal functionality with accessibility support

### CSS → Layout / UI / Animations

**Role:** Visual presentation, theming, and transition effects

**Key Functions:**

- **Modular Architecture:** CSS split into base, components, and screens folders
- **Custom Properties (CSS Variables):** For consistent theming
- **Egyptian Typography:** Custom hieroglyphic and themed fonts (@font-face)
- **Gate Animation:** CSS-based transition effect between screens
- **Responsive Warnings:** Mobile detection and warning screen
- **Toggle Switches:** Custom-styled checkboxes for settings

**Why This Matters:**

- Separation of concerns makes styling maintainable
- CSS animations don't block JavaScript execution
- Custom fonts create immersive theme
- Prevents gameplay on unsuitable screen sizes

### JavaScript → Game Engine Logic (MOST IMPORTANT)

**Role:** All game mechanics, state management, rendering, and interaction

**Key Functions:**

- **Game Loop:** requestAnimationFrame for 60fps rendering
- **State Management:** Object-oriented approach with class instances
- **Canvas Rendering:** 2D context drawing for maze, sprites, effects
- **Collision Detection:** Grid-based movement validation
- **Enemy AI:** Pathfinding logic for mummy movement
- **Save System:** LocalStorage-based game persistence
- **Input Handling:** Keyboard event listeners for player control
- **Timer System:** Countdown mechanics with pause/resume
- **Camera System:** Viewport that follows player position
- **Sprite Animation:** Frame-based character animation

**Why This Matters:**

- This is where 90% of interview questions will focus
- Understanding the game loop is crucial
- Module pattern demonstrates modern JavaScript practices
- State management shows architectural thinking

## 1.3 Architecture Style

### Primary Architecture: **Object-Oriented with ES6 Modules**

**Characteristics:**

1. **Class-Based Design:**
    
    - Each major component is a class (Player, Enemy, Camera, Timer, etc.)
    - Encapsulation using private fields (`#position`, `#lives`)
    - Methods represent behaviors (move, update, draw)
2. **Module-Based Organization:**
    
    - ES6 import/export statements
    - Files organized by responsibility (player/, enemies/, core/, maze/)
    - Dependency injection pattern (passing maze, spriteImage to constructors)
3. **Factory Pattern:**
    
    - `createPlayer()` and `createEnemy()` functions act as factories
    - Compose multiple classes into a single interface
    - Returns object with public methods (closure-based encapsulation)
4. **Singleton Pattern:**
    
    - `Game` class has single instance exposed globally (`window.game`)
    - HUD class uses static methods (no instantiation needed)
    - CONFIG object is single source of truth for game constants
5. **Event-Driven Architecture:**
    
    - Keyboard events trigger game actions
    - UI button clicks handled via event listeners
    - Pause menu, screen navigation all event-based
6. **Canvas Rendering (Immediate Mode):**
    
    - No DOM manipulation during gameplay
    - Everything drawn directly to canvas each frame
    - Clear → Draw → Display cycle

**Why This Architecture:**

- **OOP:** Makes game entities intuitive (Player IS an object, has properties and behaviors)
- **Modules:** Code splitting for maintainability and testing
- **Factory Pattern:** Decouples creation logic from usage
- **Event-Driven:** Natural fit for user interactions and game events
- **Canvas:** Performance advantage over DOM manipulation for animations

**Interview Key Point:** This is a **hybrid architecture** - it uses OOP principles but also functional patterns (factories, pure functions in utils). It's NOT purely functional or purely object-oriented, but uses best of both worlds.

---

# PART 2 — GAME LOGIC DEEP DIVE (40% OF CONTENT)

## 2.1 Game Flow Lifecycle

### Complete Game Flow from Start to Finish:

```
USER ACTION → HTML EVENT → JS HANDLER → GAME STATE CHANGE → RENDER UPDATE
```

### Phase 1: Application Initialization (On Page Load)

**What Happens:**

1. Browser loads HTML document
2. CSS files loaded and parsed
3. JavaScript modules loaded via `<script type="module">`
4. Navigation.js executes first (loaded first in HTML)
5. Game.js executes second (creates Game instance)

**Code Location:**

```javascript
// Bottom of Game.js
const game = new Game();
window.game = game;  // Expose globally for event handlers
```

**Why This Order Matters:**

- Navigation.js sets up screen transitions and audio
- Game.js needs to be instantiated but not started yet
- Global exposure allows HTML onclick handlers to access game instance

**Interview Trap:** "Why is the game instance global?" **Answer:** HTML onclick attributes need to access it (`onClick="onResume()"`). Better alternatives would be data attributes with event delegation, but this is simpler for small projects.

### Phase 2: Game Initialization - game.start() → game.loadLvl(1)

**Critical Code:**

```javascript
start() {
  this.lvl = 1;
  this.keys = 0;
  this.loadLvl(1);
}
```

**What loadLvl Does:**

1. **Set State Variables:**

```javascript
this.lvl = num;
this.running = true;
this.paused = false;
this.enemies = [];
```

2. **Handle Saved Data (if loading from save):**

```javascript
if (this.savedData) {
  savedKeys = this.savedData.keys;
  savedMaze = this.savedData.mazeState;
  savedTime = this.savedData.time;
  savedHearts = this.savedData.hearts;
  savedPosition = this.savedData.playerPosition;
  this.savedData = null;  // Clear after use
}
```

3. **Load Maze Data:**

```javascript
if (savedMaze) {
  this.maze = savedMaze.map(row => [...row]);  // Deep copy
} else {
  this.maze = getMaze(num).map(row => [...row]);  // Deep copy from template
}
```

**Why Deep Copy:** The maze array is mutated during gameplay (keys removed, door opened), so we need a fresh copy each time.

4. **Create Player Sprite:**

```javascript
sprite.onload = () => {
  let startX = savedPosition ? savedPosition.x : getStartPosition().col;
  let startY = savedPosition ? savedPosition.y : getStartPosition().row;
  let lives = savedHearts ? savedHearts : 3;
  
  this.player = createPlayer({
    startX, startY, lives,
    maze: this.maze,
    spriteImage: sprite
  });
  
  this.updateUI();
  this.startGameLoop();  // BEGIN RENDERING
};
sprite.src = "assets/sprites/player/player.png";
```

**Why Image Loading is Asynchronous:**

- Images load from disk/network asynchronously
- If we draw before images load, canvas shows nothing
- `onload` callback ensures sprite is ready before use

### Phase 3: The Game Loop - Heart of the Game

**gameLoop() method - Most Important Function:**

```javascript
gameLoop = (currentTime) => {
  if (!this.running) return;  // Early exit if game stopped
  
  // 1. Calculate delta time
  const deltaTime = currentTime - this.lastFrameTime;
  this.lastFrameTime = currentTime;
  
  // 2. Update camera position
  const pos = this.player.getVisualPosition();
  this.camera.follow(pos.x, pos.y);
  this.camera.clamp(this.maze[0].length, this.maze.length);
  
  // 3. Clear canvas
  this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
  
  // 4. Render maze
  renderMaze(this.maze, this.camera);
  
  // 5. Update and render enemies (if not paused)
  if (!this.paused) {
    for (let enemy of this.enemies) {
      enemy.update(deltaTime);
      enemy.draw(this.ctx, this.TILE_SIZE, this.camera);
      this.checkEnemyCollision(playerPos.x, playerPos.y);
    }
    this.player.update(deltaTime);
    this.renderPlayer();
  } else {
    // Still render but don't update when paused
    for (let enemy of this.enemies) {
      enemy.draw(this.ctx, this.TILE_SIZE, this.camera);
    }
    this.renderPlayer();
  }
  
  // 6. Apply fog of war effect
  this.lightCircle();
  
  // 7. Request next frame
  this.animationFrameId = requestAnimationFrame(this.gameLoop);
};
```

**Why This Order:**

1. **Camera First:** Needed to know what portion of maze to draw
2. **Clear Canvas:** Remove previous frame's drawing
3. **Maze First:** Background layer, drawn behind everything
4. **Enemies Before Player:** So player appears on top (z-index equivalent)
5. **Lighting Last:** Applied over everything for fog effect
6. **requestAnimationFrame:** Efficient 60fps loop tied to browser repaint

**Delta Time Explained:**

- `deltaTime` = time since last frame in milliseconds
- Used for frame-rate independent animation
- If game runs at 30fps vs 60fps, entities move same speed (adjusted by deltaTime)
- Example: `position += velocity * (deltaTime / 1000)` makes movement consistent

**Interview Key Point:** "Why arrow function for gameLoop?" **Answer:** Arrow function preserves `this` context. If we used regular function, `this` inside gameLoop would be window, not the Game instance. Arrow function lexically binds `this`.

### Phase 4: Player Input Handling

**Keyboard Event Listener:**

```javascript
document.addEventListener("keydown", (e) => {
  // ESCAPE KEY - Pause/Resume
  if (e.key === "Escape") {
    if (game.running) {
      e.preventDefault();  // Prevent default browser behavior
      if (game.paused) {
        window.onResume();
      } else {
        game.togglePause(true);
        document.getElementById("pause-menu").showModal();
      }
      return;
    }
  }
  
  // S KEY - Quick Save
  if (e.key === "s" && game.running) {
    game.saveGame();
  }
  
  // Ignore input if not running or paused
  if (!game.running || game.paused) return;
  
  // ARROW KEYS - Movement
  const keys = {
    ArrowUp: "up",
    ArrowDown: "down",
    ArrowLeft: "left",
    ArrowRight: "right",
  };
  
  if (keys[e.key]) {
    game.move(keys[e.key]);
  }
});
```

**game.move() Method:**

```javascript
move(dir) {
  if (!this.running || this.paused || !this.player) return;
  
  let dx = 0, dy = 0;
  if (dir === "left") dx = -1;
  if (dir === "right") dx = 1;
  if (dir === "up") dy = -1;
  if (dir === "down") dy = 1;
  
  if (this.player.movePlayer(dx, dy)) {  // Returns true if move succeeded
    const newPos = this.player.getPlayerPosition();
    this.handleTile(newPos.x, newPos.y);  // Check for items, traps
    this.updateUI();  // Refresh HUD
    if (this.checkWin(newPos)) {
      this.nextLvl();
    }
  }
}
```

**Why Separate dx/dy:**

- Grid-based movement requires integer offsets
- Direction strings converted to coordinate deltas
- Makes collision detection simpler (just check newX, newY)

**Why Check movePlayer() Return Value:**

- Player might try to move into wall
- PlayerMovement.movePlayer() returns false if can't move
- Only process tile interaction if move actually happened

### Phase 5: Tile Interaction Logic

**handleTile() Method:**

```javascript
handleTile(x, y) {
  if (hasTrap(y, x, this.lvl)) {
    this.player.loseLife();
  } else if (hasLife(y, x, this.lvl)) {
    this.player.gainLife();
    this.maze[y][x] = 0;  // Remove gem from maze
  } else if (this.maze[y][x] === 3) {
    this.keys++;
    this.maze[y][x] = 0;  // Remove key from maze
  }
  
  // Check if player died from trap
  if (!this.player.isPlayerAlive()) {
    this.gameOver();
  }
  
  // Open door if all keys collected
  if (this.keys === 3) {
    this.maze[this.maze.length - 1][this.maze[0].length - 1] = 6;
  }
}
```

**Tile Value Meanings:**

- `0` = Walkable path
- `1` = Wall (blocks movement)
- `2` = Heart/Gem (restore 1 life)
- `3` = Key (collectible, need 3 to open door)
- `4` = Trap (lose 1 life)
- `5` = Closed door
- `6` = Open door (can win)
- `10` = Enemy spawn position

**Why Mutate Maze Array:**

- Removes collected items visually (won't render next frame)
- Prevents collecting same item twice
- Saved maze state preserves these changes

**Critical Interview Point:** "What happens if you step on the same trap twice?" **Answer:** `hasTrap()` checks the original maze data (MazeLevels.js), not the mutated runtime maze. Traps always hurt because they're not cleared from the array (unlike keys/gems).

## 2.2 Maze Representation

### Data Structure: 2D Array of Integers

**Example Maze (Level 1):**

```javascript
[
  [0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0, 1, 0, 0, 0],
  [1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0],
  // ... more rows
]
```

**Access Pattern:**

```javascript
maze[row][column]
maze[y][x]
```

**Why This Order:**

- Arrays are row-major (each inner array is a row)
- Matches how 2D arrays are conceptualized visually
- y-coordinate = row index, x-coordinate = column index

**Grid Coordinate System:**

```
canvasX = gridX * TILE_SIZE
canvasY = gridY * TILE_SIZE
```

**Example:**

- Player at grid position (2, 3)
- TILE_SIZE = 120
- Canvas position = (2 * 120, 3 * 120) = (240, 360)

**Camera Offset:**

```
screenX = canvasX - camera.x
screenY = canvasY - camera.y
```

**Why Deep Copy on Load:**

```javascript
this.maze = getMaze(num).map(row => [...row]);
```

- `map` creates new outer array
- `[...row]` spreads to create new inner arrays
- Without this, modifying runtime maze would modify the template
- Enables maze reset on restart

## 2.3 Player Logic

### Player Architecture: Composition Pattern

**Three Separate Classes:**

1. **Player.js** - Core state (position, lives, direction)
2. **PlayerMovement.js** - Movement logic and collision detection
3. **PlayerSprite.js** - Visual representation and animation

**Assembled by Factory:**

```javascript
// PlayerController.js
export function createPlayer({ startX, startY, lives, maze, spriteImage }) {
  const player = new Player(startX, startY, lives);
  const movement = new PlayerMovement(player, maze);
  const sprite = new PlayerSprite(spriteImage);
  
  return {
    update(deltaTime) {
      sprite.update(deltaTime, player.isMoving());
      player.setMoving(false);
    },
    draw(ctx, cellSize, camera) {
      sprite.draw(ctx, player.getPlayerPosition(), 
                  player.getDirection(), cellSize, camera);
    },
    movePlayer: (dx, dy) => {
      if (sprite.isMoving()) return false;
      return movement.movePlayer(dx, dy);
    },
    // ... more methods
  };
}
```

**Why Composition Over Inheritance:**

- Each class has single responsibility
- Can test movement logic independently of sprite rendering
- Can swap sprite without touching movement logic
- Factory provides clean public interface

### Player State Management

**Private Fields (Player.js):**

```javascript
#position;      // { x, y }
#lives;         // Current health (0-3)
#startPosition; // For respawn after enemy hit
#maxLives;      // 3 (from constructor)
#direction;     // 0=up, 1=left, 2=down, 3=right
#isMoving;      // Boolean flag for animation
```

**Why Private Fields:**

- Encapsulation prevents external code from corrupting state
- Forces use of getter/setter methods
- TypeScript-like strictness in vanilla JS

### Movement System: Grid-Locked Movement

**Two-Position System:**

1. **Logical Position (Player.js):** Grid coordinates (integer), immediate update
2. **Visual Position (PlayerSprite.js):** Canvas coordinates (float), interpolated smoothly

**PlayerMovement.js:**

```javascript
movePlayer(dx, dy) {
  if (this.player.isMoving()) return false;  // Prevent move during animation
  
  const { x, y } = this.player.getPlayerPosition();
  const newX = x + dx;
  const newY = y + dy;
  
  if (!this.canMoveTo(newX, newY)) return false;  // Wall collision
  
  this.player.setPlayerPosition(newX, newY);  // Update logical position
  this.player.setMoving(true);  // Trigger animation
  
  // Update direction based on delta
  if (dy === -1) this.player.setDirection(0);
  if (dx === -1) this.player.setDirection(1);
  if (dy === 1) this.player.setDirection(2);
  if (dx === 1) this.player.setDirection(3);
  
  return true;
}
```

**Smooth Movement Animation (PlayerSprite.js):**

```javascript
draw(ctx, position, direction, cellSize, camera) {
  this.targetX = position.x;  // From logical position
  this.targetY = position.y;

  // Linear interpolation
  this.visualX += (this.targetX - this.visualX) * moveSpeed;  // 0.1
  this.visualY += (this.targetY - this.visualY) * moveSpeed;

  // Snap when close enough
  if (Math.abs(this.targetX - this.visualX) < 0.1 &&
      Math.abs(this.targetY - this.visualY) < 0.1) {
    this.visualX = this.targetX;
    this.visualY = this.targetY;
    this.currentFrame = 0;  // Stop animation
  }
  
  // Draw sprite
  const srcX = this.currentFrame * this.frameWidth;
  const srcY = direction * this.frameHeight;
  ctx.drawImage(this.image, srcX, srcY, ...);
}
```

**Why Two Positions:**

- Logical position used for game logic (collision, tile interaction)
- Visual position used for rendering (smooth animation)
- Decouples game logic from animation speed
- Prevents input buffering (can't move again until animation complete)

### Collision Detection

**Wall Collision:**

```javascript
canMoveTo(x, y) {
  // Boundary check
  if (y < 0 || y >= this.maze.length ||
      x < 0 || x >= this.maze[0].length) {
    return false;
  }
  
  // Wall check
  return this.maze[y][x] !== 1;
}
```

**Why This Works:**

- Checks BEFORE moving, not after
- Prevents invalid state (player inside wall)
- Returning false from movePlayer prevents position update

### Sprite Animation

**Sprite Sheet Structure:**

- 9 columns (frames) × 4 rows (directions)
- Each frame = 1/9th of total width
- Each direction = 1/4th of total height

**Frame Calculation:**

```javascript
this.frameWidth = image.width / 9;   // CONFIG.PLAYER.SPRITE_COLS
this.frameHeight = image.height / 4;  // CONFIG.PLAYER.SPRITE_ROWS

// Animation update
this.frameTimer += deltaTime;
if (this.frameTimer >= animationSpeed) {  // 25ms
  this.frameTimer = 0;
  this.currentFrame = (this.currentFrame + 1) % 9;  // Loop through frames
}
```

**Why Modulo Operator:**

- `(currentFrame + 1) % 9` wraps from 8 back to 0
- Creates infinite looping animation
- Avoids if statement: cleaner code

## 2.4 Enemy System

### Enemy AI: Random Walk Algorithm

**EnemyMovement.js Update Logic:**

```javascript
update(deltaTime) {
  const now = performance.now();
  if (now - this.lastMoveTime < this.moveDelay) {  // 600ms
    this.isCurrentlyMoving = true;
    return;
  }
  
  this.lastMoveTime = now;
  const { x, y } = this.enemy.getPosition();
  let dx = 0, dy = 0;
  
  // Convert direction to delta
  if (this.dir === 0) dy = -1;
  if (this.dir === 1) dx = -1;
  if (this.dir === 2) dy = 1;
  if (this.dir === 3) dx = 1;
  
  const nx = x + dx;
  const ny = y + dy;
  
  if (this.canMoveTo(nx, ny)) {
    this.enemy.setPosition(nx, ny);
    this.enemy.setDirection(this.dir);
    this.enemy.setMoving(true);
  } else {
    this.dir = this.chooseNewDirection(x, y);  // Hit wall, pick new direction
  }
}
```

**Direction Selection (AI):**

```javascript
chooseNewDirection(x, y) {
  const options = [];
  
  // Check all directions except opposite of current
  if (this.canMoveTo(x, y - 1) && this.dir !== 2) options.push(0);
  if (this.canMoveTo(x - 1, y) && this.dir !== 3) options.push(1);
  if (this.canMoveTo(x, y + 1) && this.dir !== 0) options.push(2);
  if (this.canMoveTo(x + 1, y) && this.dir !== 1) options.push(3);
  
  if (options.length === 0) {
    return this.reverseDirection(this.dir);  // Dead end, turn around
  }
  
  return options[Math.floor(Math.random() * options.length)];  // Random choice
}
```

**Why Prevent Reverse:**

- `this.dir !== 2` when checking up direction
- Prevents enemy from immediately backtracking
- Creates more natural movement pattern
- Otherwise enemy would "wiggle" back and forth

**AI Behavior Analysis:**

- **Type:** Random Walk with No Backtracking
- **Pros:** Simple, unpredictable, works for maze
- **Cons:** No pathfinding to player, can get "stuck" in corners
- **Difficulty:** Based on number of enemies, not intelligence

### Enemy Collision Detection

**checkEnemyCollision() in Game.js:**

```javascript
checkEnemyCollision(playerX, playerY) {
  for (let enemy of this.enemies) {
    const enemyPos = enemy.getPosition();
    if (enemyPos.x === playerX && enemyPos.y === playerY) {
      this.player.loseLife();
      if (this.player.isPlayerAlive()) {
        this.player.resetPlayerPosition();  // Back to start
      } else {
        this.gameOver();
        break;  // Stop checking after game over
      }
    }
  }
}
```

**Collision Type:**

- Grid-based exact position match
- No bounding box or radius collision
- Simple but works for grid-based movement

## 2.5 Camera and Rendering

### Camera System

**Camera.js:**

```javascript
follow(playerX, playerY) {
  // Center camera on player
  this.x = playerX * this.tileSize - this.width / 2 + this.tileSize / 2;
  this.y = playerY * this.tileSize - this.height / 2 + this.tileSize / 2;
}

clamp(mazeWidth, mazeHeight) {
  const maxX = mazeWidth * this.tileSize - this.width;
  const maxY = mazeHeight * this.tileSize - this.height;
  
  if (this.x < 0) this.x = 0;
  if (this.y < 0) this.y = 0;
  if (this.x > maxX) this.x = maxX;
  if (this.y > maxY) this.y = maxY;
}
```

**Why Clamp:**

- Prevents camera from showing outside maze bounds
- Shows black void if maze smaller than viewport
- Keeps player centered except at edges

### Fog of War Effect

**lightCircle() Method:** Creates a radial gradient darkness overlay with orange glow in center:

```javascript
lightCircle() {
  const playerPos = this.player.getVisualPosition();
  const playerXCord = playerPos.x * TILE_SIZE - camera.x + TILE_SIZE / 2;
  const playerYCord = playerPos.y * TILE_SIZE - camera.y + TILE_SIZE / 2;
  
  const lightRadius = 200;
  const fadeWidth = 60;
  
  // Create darkness gradient
  const darknessGradient = ctx.createRadialGradient(
    playerXCord, playerYCord, 0,
    playerXCord, playerYCord, maxRadius
  );
  
  darknessGradient.addColorStop(0, "rgba(0, 0, 0, 0)");  // Transparent center
  darknessGradient.addColorStop(startFade, "rgba(0, 0, 0, 0)");
  darknessGradient.addColorStop(endFade, "rgba(0, 0, 0, 0.98)");  // Dark edges
  darknessGradient.addColorStop(1, "rgba(0, 0, 0, 0.98)");
  
  ctx.fillStyle = darknessGradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  // Add orange glow
  ctx.globalCompositeOperation = "lighter";
  const glowGradient = ctx.createRadialGradient(...);
  glowGradient.addColorStop(0, "rgba(255, 200, 100, 0.1)");
  // ... more color stops
  
  ctx.fillStyle = glowGradient;
  ctx.arc(playerXCord, playerYCord, lightRadius, 0, Math.PI * 2);
  ctx.fill();
  
  ctx.restore();
}
```

**Composite Operation:**

- `"lighter"` adds glow colors to existing pixels
- Creates torch-like orange glow effect

## 2.6 Timer and HUD Systems

### Timer Implementation

**Timer.js:**

```javascript
startCountdown(seconds, game) {
  this.timeLeft = seconds;
  this.gameReference = game;
  this.isPaused = false;
  
  if (this.timerId) {
    clearInterval(this.timerId);  // Clear old timer
  }
  
  HUD.updateTimer(this.timeLeft);
  
  this.timerId = setInterval(() => {
    if (!this.isPaused) {
      this.timeLeft--;
      HUD.updateTimer(this.timeLeft);
      
      if (this.timeLeft <= 0) {
        this.stop();
        this.gameReference.gameOver();  // Trigger loss
      }
    }
  }, 1000);  // 1 second interval
}
```

**Why setInterval Not requestAnimationFrame:**

- Timer updates once per second
- requestAnimationFrame runs 60 times per second
- setInterval more efficient for this use case

### HUD System

**HUD.js - Utility Class:**

```javascript
class HUD {
  static updateHearts(hearts) {
    const element = document.querySelector(".heart-hud .hud-content");
    if (element) {
      element.textContent = "❤️".repeat(hearts);
    }
  }
  
  static updateKeys(keys) {
    const element = document.querySelector(".key-hud .hud-content");
    if (element) {
      element.textContent = `🔑 ${keys}/3`;
    }
  }
  
  static updateTimer(seconds) {
    const element = document.querySelector(".timer-hud .hud-content");
    if (element) {
      const minutes = Math.floor(seconds / 60);
      const secs = seconds % 60;
      const formatted = 
        String(minutes).padStart(2, "0") + ":" + 
        String(secs).padStart(2, "0");
      element.textContent = formatted;
    }
  }
}
```

**Why Static:**

- No state to maintain
- Only updates DOM elements
- Single responsibility: UI updates

---

## 2.7 Save/Load System

### LocalStorage Implementation

**storage.js:**

```javascript
class StorageSystem {
  static saveToSlot(slotNumber, gameData) {
    const saveData = {
      level: gameData.level,
      hearts: gameData.hearts,
      keys: gameData.keys,
      time: gameData.time,
      playerPosition: gameData.playerPosition,
      mazeState: gameData.mazeState,
      date: new Date().toISOString()
    };
    
    this.#storage.setItem(
      this.#getKey(slotNumber),
      JSON.stringify(saveData)
    );
  }
  
  static loadFromSlot(slotNumber) {
    const savedData = this.#storage.getItem(this.#getKey(slotNumber));
    if (!savedData) return null;
    return JSON.parse(savedData);
  }
  
  static shiftSlotsDown() {
    const slot1 = this.loadFromSlot(1);
    const slot2 = this.loadFromSlot(2);
    
    if (slot2) this.saveToSlot(3, slot2);  // 2 → 3
    if (slot1) this.saveToSlot(2, slot1);  // 1 → 2
    // New save will go in slot 1
  }
}
```

**Shift Algorithm:**

```
Before: [Slot1: SaveA] [Slot2: SaveB] [Slot3: SaveC]
Shift:  [Slot1: -----] [Slot2: SaveA] [Slot3: SaveB]
After:  [Slot1: SaveD] [Slot2: SaveA] [Slot3: SaveB]
```

**Why Shift:**

- Slot 1 always newest
- Keeps 3 most recent saves
- Simple LIFO queue

---

# MAZER TECHNICAL REVIEW - FINAL PART

_Quick Revision Cheat Sheet & Summary_

---

<a name="part-12"></a>

# 🧭 PART 12 — QUICK REVISION CHEAT SHEET

## Core Concepts (Memorize These)

### Game Loop

```javascript
gameLoop = (currentTime) => {
  if (!this.running) return;
  
  deltaTime = currentTime - lastFrameTime;
  camera.follow(player.position);
  ctx.clearRect();
  renderMaze(maze, camera);
  enemies.forEach(enemy => enemy.update());
  player.update();
  lightCircle();
  requestAnimationFrame(gameLoop);
}
```

**Why Arrow Function:** Preserves `this` context (Game instance)  
**Why requestAnimationFrame:** 60fps, pauses when tab inactive, provides timestamp  
**Why Delta Time:** Frame-rate independence

### Movement System

**Two Positions:**

- **Logical:** Grid coordinates (integer), instant update, used for game logic
- **Visual:** Canvas coordinates (float), interpolated, used for rendering

**Linear Interpolation:**

```javascript
visualX += (targetX - visualX) * moveSpeed;  // moveSpeed = 0.1
```

### Collision Detection

```javascript
canMoveTo(x, y) {
  if (y < 0 || y >= maze.length) return false;  // Bounds
  if (x < 0 || x >= maze[0].length) return false;
  return maze[y][x] !== 1;  // Not wall
}
```

**Before vs After:** Check BEFORE moving, not after

### Maze Representation

- 2D array of integers
- `maze[row][column]` or `maze[y][x]`
- Deep copied on load: `maze.map(row => [...row])`
- Mutated at runtime (keys removed, door opened)

**Tile Values:**

```
0 = Path    1 = Wall      2 = Gem    3 = Key
4 = Trap    5 = Door      6 = Open   10 = Enemy Spawn
```

### Camera System

```javascript
follow(playerX, playerY) {
  this.x = playerX * tileSize - width/2 + tileSize/2;
  this.y = playerY * tileSize - height/2 + tileSize/2;
}
```

**Purpose:** Centers player in viewport, allows larger mazes than screen

### Factory Pattern

```javascript
createPlayer({ startX, startY, lives, maze, spriteImage }) {
  const player = new Player(startX, startY, lives);
  const movement = new PlayerMovement(player, maze);
  const sprite = new PlayerSprite(spriteImage);
  
  return { update, draw, movePlayer, ... };  // Unified interface
}
```

**Why:** Composition over inheritance, clean API, testable components

### Enemy AI

**Algorithm:** Random walk with no backtracking

- Choose random valid direction
- Avoid reversing immediately
- If stuck, reverse
- Move every 600ms (MOVE_DELAY)

### Save System

**Slots:** 3 total, slot 1 always newest  
**Data:** level, hearts, keys, time, playerPosition, mazeState, date  
**Shift:** When saving: slot 1→2, slot 2→3, new→slot 1

### Timer System

- `setInterval` every 1000ms (not requestAnimationFrame)
- Updates HUD, checks if timeLeft <= 0
- Pause vs Stop: pause = freeze, stop = destroy

### Sprite Animation

```javascript
frameX = currentFrame * frameWidth;
frameY = direction * frameHeight;
ctx.drawImage(sprite, frameX, frameY, width, height, destX, destY, size, size);
```

**Frame Selection:** Modulo wraps: `(currentFrame + 1) % totalFrames`

---

## Common Interview Questions - Quick Answers

**Q: Why separate Player, PlayerMovement, and PlayerSprite?**  
A: Single Responsibility Principle. Player = state, Movement = logic, Sprite = visuals. Easier to test and modify independently.

**Q: What happens if image fails to load?**  
A: Promise never resolves, game hangs. Need error handling with timeout and onerror callback.

**Q: Is there a memory leak?**  
A: Potential if game loop not stopped (requestAnimationFrame keeps calling). Fixed by cancelAnimationFrame in gameOver().

**Q: Why deep copy maze?**  
A: Runtime maze is mutated (keys collected). Need fresh copy from template each level to reset state.

**Q: Difference between paused and stopped?**  
A: Paused = updates stop, rendering continues. Stopped = loop exits, everything stops.

**Q: Why `this.maze[y][x]` not `this.maze[x][y]`?**  
A: 2D arrays are row-major. First index = row (y), second = column (x).

**Q: How does camera create scrolling?**  
A: Subtracts camera offset from all world coordinates: `screenX = worldX - camera.x`

**Q: What triggers win condition?**  
A: Standing on tile value 6 (open door). Door opens when keys === 3.

**Q: Why private fields (#position)?**  
A: True encapsulation, prevents external modification, self-documenting, better than _ convention.

**Q: Optimize gradient creation?**  
A: Cache gradient, only recreate when player moves significantly (>5 pixels).

---

## Architecture Patterns Used

1. **Object-Oriented:** Classes for entities (Player, Enemy, Game)
2. **Factory Pattern:** createPlayer(), createEnemy()
3. **Singleton:** Game instance (window.game), HUD static methods
4. **Module Pattern:** ES6 modules with import/export
5. **Composition:** Player composed of state + movement + sprite
6. **Observer (implicit):** Event listeners, callbacks
7. **Strategy (implicit):** Enemy AI could be swapped

---

## File Structure Map

```
js/
├── core/           (Game systems)
│   ├── Game.js     (Main orchestrator)
│   ├── Timer.js    (Countdown)
│   ├── HUD.js      (UI updates)
│   └── Camera.js   (Viewport)
├── player/         (Player entity)
│   ├── Player.js   (State)
│   ├── PlayerMovement.js (Logic)
│   ├── PlayerSprite.js (Visuals)
│   └── PlayerController.js (Factory)
├── enemies/        (Enemy entities)
│   ├── Enemy.js
│   ├── EnemyMovement.js
│   ├── EnemySprite.js
│   └── EnemyController.js
├── maze/           (Level data & rendering)
│   ├── MazeLevels.js (Data)
│   ├── Maze.js     (Rendering)
│   └── ImageLoader.js (Assets)
├── storage/        (Persistence)
│   └── storage.js  (LocalStorage wrapper)
├── config/         (Constants)
│   └── GameConfig.js
└── navigation.js   (UI & screens)
```

---

## Critical Code Snippets to Remember

### Game Initialization

```javascript
loadLvl(num) {
  this.maze = getMaze(num).map(row => [...row]);  // Deep copy
  loadLevelMaze().then(() => {
    sprite.onload = () => {
      this.player = createPlayer(...);
      this.startGameLoop();
    };
    sprite.src = "path.png";
  });
}
```

### Movement Validation

```javascript
movePlayer(dx, dy) {
  if (this.player.isMoving()) return false;  // Block during animation
  const newX = x + dx;
  const newY = y + dy;
  if (!canMoveTo(newX, newY)) return false;  // Collision check
  
  this.player.setPlayerPosition(newX, newY);
  this.player.setMoving(true);
  return true;
}
```

### Collision Detection

```javascript
checkEnemyCollision(playerX, playerY) {
  for (let enemy of this.enemies) {
    const pos = enemy.getPosition();
    if (pos.x === playerX && pos.y === playerY) {
      this.player.loseLife();
      if (!this.player.isPlayerAlive()) {
        this.gameOver();
        break;
      } else {
        this.player.resetPlayerPosition();
      }
    }
  }
}
```

### Smooth Animation

```javascript
update(deltaTime, isMoving) {
  if (!isMoving) {
    this.currentFrame = 0;
    return;
  }
  
  this.frameTimer += deltaTime;
  if (this.frameTimer >= animationSpeed) {
    this.frameTimer = 0;
    this.currentFrame = (this.currentFrame + 1) % SPRITE_COLS;
  }
}
```

---

## Performance Tips

1. **Use Transform, Not Position**
    
    - Bad: `element.style.left = '100px'` (reflow)
    - Good: `element.style.transform = 'translateX(100px)'` (composite only)
2. **Request Animation Frame**
    
    - Synced to refresh rate
    - Pauses when tab inactive
    - Better than setInterval for rendering
3. **Canvas Optimization**
    
    - Clear only changed areas (dirty rectangles)
    - Pre-render static elements to offscreen canvas
    - Use will-change CSS property sparingly
4. **Asset Loading**
    
    - Load once, cache in Map
    - Use Promise.all for parallel loading
    - Add loading indicators
5. **Memory Management**
    
    - Remove event listeners when done
    - Cancel animation frames on cleanup
    - Clear intervals/timeouts

---

## Common Bugs & Fixes

### Bug 1: Time Calculation Wrong

```javascript
// Wrong:
this.startingTime = new Date().getSeconds();  // 0-59 only!

// Right:
this.startingTime = Date.now();  // Milliseconds since epoch
```

### Bug 2: Canvas Blurry

```javascript
// Wrong:
<canvas style="width: 1180px; height: 510px"></canvas>

// Right:
<canvas width="1180" height="510"></canvas>
```

### Bug 3: Arrow Function Context

```javascript
// Wrong (this = window):
gameLoop(currentTime) {
  this.ctx.clearRect();  // Error!
}

// Right (this = Game):
gameLoop = (currentTime) => {
  this.ctx.clearRect();  // Works!
}
```

### Bug 4: Shallow Copy Issue

```javascript
// Wrong:
this.maze = getMaze(num);  // Reference, not copy!

// Right:
this.maze = getMaze(num).map(row => [...row]);  // Deep copy
```

### Bug 5: Closure in Loop

```javascript
// Wrong (var):
for (var i = 0; i < 3; i++) {
  btn[i].onclick = () => console.log(i);  // Always logs 3
}

// Right (let):
for (let i = 0; i < 3; i++) {
  btn[i].onclick = () => console.log(i);  // Logs 0, 1, 2
}
```

---

## Testing Strategy

### Unit Tests

```javascript
describe('Player', () => {
  test('loses life correctly', () => {
    const player = new Player(0, 0, 3);
    player.loseLife();
    expect(player.getLivesCount()).toBe(2);
  });
  
  test('cannot go negative lives', () => {
    const player = new Player(0, 0, 1);
    player.loseLife();
    player.loseLife();  // Extra
    expect(player.getLivesCount()).toBe(0);
  });
});
```

### Integration Tests

```javascript
describe('Game Flow', () => {
  test('game over when time expires', (done) => {
    const game = new Game();
    game.start();
    game.timer.timeLeft = 1;
    
    setTimeout(() => {
      expect(game.running).toBe(false);
      done();
    }, 1500);
  });
});
```

### E2E Tests (Playwright/Cypress)

```javascript
test('can complete level 1', async () => {
  await page.goto('http://localhost:8080');
  await page.click('#btn-new-game');
  await page.waitForSelector('#canvas');
  
  // Simulate movements
  await page.keyboard.press('ArrowRight');
  await page.keyboard.press('ArrowDown');
  // ... more moves
  
  await page.waitForSelector('.win-screen');
  expect(page.locator('.win-screen')).toBeVisible();
});
```

---

## Deployment Checklist

- [ ] Minify JavaScript (UglifyJS, Terser)
- [ ] Optimize images (TinyPNG, ImageOptim)
- [ ] Enable gzip compression
- [ ] Add service worker for offline play
- [ ] Set cache headers
- [ ] Add CSP headers
- [ ] Test on multiple browsers
- [ ] Test on mobile devices
- [ ] Check accessibility (WAVE, axe)
- [ ] Add analytics
- [ ] Set up error tracking
- [ ] Create backup save system
- [ ] Add loading indicators
- [ ] Implement rate limiting (if multiplayer)
- [ ] Security audit (XSS, injection)
- [ ] Performance audit (Lighthouse)

---

## Useful Resources

**JavaScript:**

- MDN Web Docs: https://developer.mozilla.org
- JavaScript.info: https://javascript.info
- ES6 Features: http://es6-features.org

**Canvas API:**

- Canvas Tutorial: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial
- requestAnimationFrame: https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame

**Game Development:**

- Game Programming Patterns: https://gameprogrammingpatterns.com
- HTML5 Game Development: https://www.html5gamedevelopment.com

**Testing:**

- Jest: https://jestjs.io
- Playwright: https://playwright.dev
- Testing Library: https://testing-library.com

---

## Final Tips for Interview

### Before Interview

1. Run through the entire codebase once
2. Be able to explain every function's purpose
3. Know the architectural decisions and trade-offs
4. Have 2-3 "If I had more time" improvements ready
5. Practice explaining concepts out loud

### During Interview

1. Think out loud - show your reasoning process
2. Ask clarifying questions before answering
3. It's okay to say "I don't know, but here's how I'd find out"
4. Use examples from THIS project, not generic theory
5. Admit mistakes/bugs you found in your own code

### After Interview

1. Send thank you email referencing specific discussions
2. If you said you'd research something, do it and follow up
3. Be prepared for technical follow-ups

---

## Project Strengths (Highlight These)

✅ Modern JavaScript (ES6+)  
✅ Modular architecture  
✅ Separation of concerns  
✅ Design patterns (Factory, Composition)  
✅ Canvas API proficiency  
✅ Event-driven design  
✅ LocalStorage implementation  
✅ Animation techniques  
✅ Object-oriented programming  
✅ Code organization

---

## Areas for Improvement (Be Honest About These)

⚠️ Limited error handling  
⚠️ Global state in Maze.js  
⚠️ No automated tests  
⚠️ Save time calculation bug  
⚠️ No TypeScript  
⚠️ Inline event handlers in HTML  
⚠️ Asset loading not optimized

**How to Frame:** "I recognize X is a limitation. If I were to improve it, I would Y because Z. For example..."

---

## Confidence Boosters

**You Built:**

- A complete, playable game
- Multiple interconnected systems
- Persistent storage
- Smooth animations
- AI behavior
- Complex state management

**You Demonstrated:**

- Problem-solving
- Architectural thinking
- Code organization
- Modern JavaScript
- Game development concepts

**You Can Discuss:**

- Design patterns
- Performance optimization
- Testing strategies
- Scalability concerns
- Alternative approaches

---

## Emergency Responses

**If You Blank:** "Let me think through this step by step... [use pseudocode/diagram]"

**If You're Wrong:** "Actually, I realize I made a mistake. Let me correct that..."

**If You Don't Know:** "I haven't encountered that specific scenario, but here's how I would approach researching it..."

**If Stuck:** "Could you give me a hint about which direction to explore?"

**If Time's Up:** "I understand we're short on time. The key point I want to emphasize is..."

---

# 🎓 CONCLUSION

## What Makes This Project Interview-Ready

1. **Real Implementation:** Not a tutorial follow-along
2. **Complete Features:** Full game loop, save system, multiple levels
3. **Modern Practices:** ES6 modules, classes, async/await
4. **Architectural Awareness:** Design patterns, separation of concerns
5. **Practical Trade-offs:** Performance vs readability, simplicity vs flexibility

## Key Takeaway

This project demonstrates **practical software engineering**, not just coding ability. You made decisions, faced constraints, and shipped a working product. That's what matters.

## You're Ready When You Can:

✅ Explain any function without looking at code  
✅ Discuss alternative implementations  
✅ Identify bugs and fixes  
✅ Scale the architecture  
✅ Refactor confidently

---

**Good luck with your interview! 🚀**

**Remember:** The goal isn't perfection - it's demonstrating growth, learning, and problem-solving ability. You've built something impressive. Own it.

---

# APPENDIX: Technical Terms Glossary

**Closure:** Inner function that captures variables from outer scope  
**Event Loop:** JS concurrency model (call stack + task queue + microtask queue)  
**Lexical Scoping:** Variable scope determined by code structure  
**Hoisting:** var/function declarations moved to top of scope  
**Prototype Chain:** Object inheritance mechanism in JavaScript  
**Event Bubbling:** Events propagate from target to root  
**Reflow:** Browser recalculates layout  
**Repaint:** Browser redraws pixels  
**Composite:** Browser merges layers  
**RAF:** requestAnimationFrame - browser's optimal rendering loop  
**Delta Time:** Time elapsed since last frame  
**Interpolation (Lerp):** Smooth transition between values  
**Sprite Sheet:** Single image containing multiple frames  
**Collision Detection:** Checking if objects overlap  
**Factory Pattern:** Function that creates objects  
**Composition:** Building complex objects from simple ones  
**Singleton:** Only one instance exists  
**Deep Copy:** Recursive copy of nested structures  
**Shallow Copy:** Copy references, not values  
**Immutable:** Cannot be changed after creation  
**Side Effect:** Function modifies external state  
**Pure Function:** Same input = same output, no side effects  
**Higher-Order Function:** Function that takes/returns functions  
**Callback:** Function passed as argument  
**Promise:** Async operation that will complete  
**Async/Await:** Syntactic sugar for promises  
**Module:** Self-contained code unit with imports/exports

---

## End of Technical Review

**Total Pages Equivalent:** ~40+  
**Total Questions:** 65  
**Coverage:** Complete codebase + best practices + interview prep

**Next Steps:**

1. Review this document thoroughly
2. Run the code and experiment
3. Practice explaining concepts out loud
4. Prepare 3-5 "improvement" ideas
5. Get good sleep before interview!