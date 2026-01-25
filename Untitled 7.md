# Code Review for Maze Game 🎮

First off—**great work** getting a fully functional game running in vanilla JS! You've got player movement, enemies, save/load, camera following, lighting effects, and multiple levels. That's genuinely impressive for a team learning game dev basics.

Now let's make it even better.

---

## 1. 🍎 Low Hanging Fruit (3 Quick Wins)

### A) **Stop Using `localStorage` Directly—Use Your Own System**

**Where:** `storage.js` uses `localStorage.setItem()` and `localStorage.getItem()` directly.

**Problem:** You're mixing raw browser APIs with your game logic, making it hard to test or change later.

**Fix:** You already have `StorageSystem`—but it's calling `localStorage` directly. Keep that abstraction, but make it _complete_:

```javascript
// storage.js - Add a private helper
class StorageSystem {
  static #storage = localStorage; // Can swap for testing later

  static #getKey(slotNumber) {
    return `mazer_save_slot_${slotNumber}`;
  }

  static saveToSlot(slotNumber, gameData) {
    if (slotNumber < 1 || slotNumber > 3) return false;
    
    const saveData = {
      level: gameData.level,
      hearts: gameData.hearts,
      keys: gameData.keys,
      time: gameData.time,
      playerPosition: gameData.playerPosition,
      mazeState: gameData.mazeState,
      date: new Date().toISOString()
    };

    this.#storage.setItem(this.#getKey(slotNumber), JSON.stringify(saveData));
    return true;
  }
  // ... same pattern for load/delete
}
```

**Why this matters:** If you ever want to add cloud saves, or test without breaking real saves, you can swap `#storage` without touching game code.

---

### B) **Magic Numbers Need Names**

**Where:** Scattered throughout (especially `Game.js`, `PlayerSprite.js`, `EnemyMovement.js`)

**Examples:**

```javascript
// Game.js
if (num === 1) this.timeForLevel = 90;
if (num === 2) this.timeForLevel = 120;
if (num === 3) this.timeForLevel = 180;

// PlayerSprite.js
const animationSpeed = 25;
const moveSpeed = 0.1;

// EnemyMovement.js
this.moveDelay = 600;
```

**Fix:** Create a config file:

```javascript
// config/GameConfig.js
export const CONFIG = {
  TILE_SIZE: 120,
  
  LEVEL_TIMES: {
    1: 90,
    2: 120,
    3: 180
  },
  
  PLAYER: {
    ANIMATION_SPEED: 25,
    MOVE_SPEED: 0.1,
    SPRITE_COLS: 9,
    SPRITE_ROWS: 4
  },
  
  ENEMY: {
    ANIMATION_SPEED: 100,
    MOVE_SPEED: 0.08,
    MOVE_DELAY: 600,
    SPRITE_COLS: 3,
    SPRITE_ROWS: 4
  },
  
  CAMERA: {
    LIGHT_RADIUS: 200,
    FADE_WIDTH: 60
  }
};
```

Then use it:

```javascript
// Game.js
this.timeForLevel = CONFIG.LEVEL_TIMES[num];
```

**Why this matters:** When your designer says "make enemies faster," you change ONE number, not hunt through 5 files.

---

### C) **Direction Numbers Are Cryptic**

**Where:** Every file dealing with directions uses `0, 1, 2, 3`

**Problem:** Code like `if (this.dir === 2)` is unreadable. What's 2? Down? Right?

**Fix:**

```javascript
// shared/constants.js
export const DIRECTION = {
  UP: 0,
  LEFT: 1,
  DOWN: 2,
  RIGHT: 3
};

export const DIRECTION_DELTA = {
  [DIRECTION.UP]: { dx: 0, dy: -1 },
  [DIRECTION.LEFT]: { dx: -1, dy: 0 },
  [DIRECTION.DOWN]: { dx: 0, dy: 1 },
  [DIRECTION.RIGHT]: { dx: 1, dy: 0 }
};
```

Then in `PlayerMovement.js`:

```javascript
movePlayer(dx, dy) {
  // ...
  if (dy === -1) this.player.setDirection(DIRECTION.UP);
  if (dx === -1) this.player.setDirection(DIRECTION.LEFT);
  // ...
}
```

Even better—use the delta map:

```javascript
// In Game.js
move(dir) {
  const delta = DIRECTION_DELTA[dir]; // dir is now DIRECTION.UP, etc.
  if (this.player.movePlayer(delta.dx, delta.dy)) {
    // ...
  }
}
```

**Why this matters:** 6 months from now, you won't remember what `3` means. `DIRECTION.RIGHT` is self-documenting.

---

## 2. 🚩 Red Flags (Bad Habits to Stop)

### **A) Mutating Arrays Passed by Reference**

**Where:** `Game.js` line 44-48

```javascript
if (savedMaze) {
  this.maze = savedMaze.map(row => [...row]); // ✅ GOOD - you're copying
} else {
  this.maze = getMaze(num).map(row => [...row]); // ✅ GOOD
}
```

**You're doing this RIGHT!** But then in `Maze.js`:

```javascript
// maze/Maze.js line 97
function drawMaze(maze, camera = { x: 0, y: 0 }) {
  // ... modifying maze positions array
}
```

**The Red Flag:** You're _reading_ from `mazes` array (from `MazeLevels.js`) and drawing it. That's fine. But if you ever accidentally wrote `maze[y][x] = 0` inside `drawMaze`, you'd corrupt the original level data.

**Fix:** Make it a rule: **Render functions should NEVER modify data.** Keep all mutations in `Game.js` where you handle tiles.

---

### **B) Global State via `window.game`**

**Where:** `Game.js` line 311

```javascript
const game = new Game();
window.game = game; // ⚠️ 
```

**Problem:** This creates a hidden global dependency. `navigation.js` calls `window.game.start()` without importing anything.

**Fix:** Export properly:

```javascript
// Game.js
const game = new Game();
export { game }; // Named export

// navigation.js
import { game } from './game/Game.js';

document.getElementById('btn-new-game').addEventListener('click', () => {
  gateModal(() => {
    showScreen('game');
    game.start();
  });
});
```

**Why this matters:** Using `window` makes it impossible to know _where_ code is being called from. Explicit imports = explicit dependencies.

---

### **C) Hardcoded Asset Paths**

**Where:** `ImageLoader.js`, `navigation.js` (audio files)

```javascript
images.path.src = "../../assets/images/gameplay/playground/floor.png";
// vs
sprite.src = "assets/sprites/player/player.png"; // Different base path!
```

**Problem:** Some paths start with `../../`, others with `assets/`. This breaks if you move files.

**Fix:** Use a base path constant:

```javascript
// config/AssetPaths.js
const BASE = 'assets';

export const ASSETS = {
  IMAGES: {
    TILES: {
      FLOOR: `${BASE}/images/gameplay/playground/floor.png`,
      WALL: `${BASE}/images/gameplay/playground/wall-1.png`,
      // ...
    },
    PLAYER: `${BASE}/sprites/player/player.png`,
    MUMMY: `${BASE}/images/gameplay/characters/enimies/mummy-02.png`
  },
  SOUNDS: {
    LEVELS: {
      0: `${BASE}/sounds/Ancient Egyptian Music – The Nile River.mp3`,
      // ...
    }
  }
};
```

**Why this matters:** When you deploy to a server, you might need to change the base path. One place to edit > 20 places.


---

## 🎯 Summary: Your Roadmap

|Priority|Action|Effort|Impact|
|---|---|---|---|
|🔥 **Do First**|Replace magic numbers with `CONFIG`|1 hour|Huge readability boost|
|🔥 **Do First**|Add `DIRECTION` constants|30 min|Code reads like English|
|⚠️ **Do Soon**|Fix `window.game` to proper exports|30 min|Prevents future bugs|
|📦 **Do Soon**|Centralize asset paths|1 hour|Easy to refactor later|
|📚 **Reference**|Keep render functions pure (no mutations)|Ongoing|Prevents weird bugs|

---

## 💡 One More Thing: Enemy Collision Check

I noticed this in `Game.js`:

```javascript
checkEnemyCollision(playerX, playerY) {
  for (let enemy of this.enemies) {
    const enemyPos = enemy.getPosition();
    if (enemyPos.x === playerX && enemyPos.y === playerY) {
      this.player.loseLife();
      if (this.player.isPlayerAlive()) {
        this.player.resetPlayerPosition();
      } else {
        this.gameOver();
        break;
      }
    }
  }
}
```

**Potential Bug:** You only `break` if the player dies. If 2 enemies hit the player at once (rare but possible), they lose 2 lives instead of 1.

**Fix:**

```javascript
checkEnemyCollision(playerX, playerY) {
  const hitByEnemy = this.enemies.some(enemy => {
    const pos = enemy.getPosition();
    return pos.x === playerX && pos.y === playerY;
  });

  if (hitByEnemy) {
    this.player.loseLife();
    if (this.player.isPlayerAlive()) {
      this.player.resetPlayerPosition();
    } else {
      this.gameOver();
    }
  }
}
```

---

## Final Thoughts

You're building clean, understandable code. The fact that you're using classes for `Player`, `Enemy`, `Camera` shows you understand separation of concerns. The fact that you have a `StorageSystem` instead of raw `localStorage` calls shows you're thinking about architecture.

**Keep that mindset.** The suggestions above aren't about "you did it wrong"—they're about taking what's already good and making it **maintainable** as your game grows.

When you add that store, power-ups, new enemy types, or boss fights, you'll thank yourself for having clear constants, organized files, and explicit dependencies.

You're on the right track. Keep building! 🚀