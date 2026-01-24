# 🧪 Testing & Bug Report

---

## **🐛 CRITICAL BUGS FOUND:**

### **Bug #1: Enemy Collision Logic Flaw**

```javascript
// In Game.js - checkEnemyCollision()
// PROBLEM: Checks position AFTER player moved
// Enemy could be at old position when player moves

// Current (WRONG):
checkEnemyCollision(playerX, playerY) {
    for (let enemy of this.enemies) {
      const enemyPos = enemy.getPosition();
      if (enemyPos.x === playerX && enemyPos.y === playerY) {
        this.player.loseLife();
      }
    }
}

// Also checked AGAIN in gameLoop - DUPLICATE CHECK
```

**Fix:** Remove one collision check (keep only gameLoop version)

---

### **Bug #2: Win Condition Inconsistent**

```javascript
// You check keys === 3 to open door
if (this.keys === 3) {
    this.maze[...][...] = 6; // open door
}

// But checkWin() accepts tile 5 OR 6
if (tile === 5 && this.keys >= 3) return true; // >= not ===
if (tile === 6) return true; // doesn't check keys!

// PROBLEM: Can win by reaching tile 6 with 0 keys
```

**Fix:**

```javascript
checkWin(pos) {
    const tile = this.maze[pos.y][pos.x];
    return (tile === 5 || tile === 6) && this.keys >= 3;
}
```

---

### **Bug #3: Trap Never Resets**

```javascript
// Player steps on trap (tile 4) → loses heart
// But tile stays 4 forever
// Player loses heart EVERY frame while standing on it

// In handleTile():
if (tile === 4) {
    this.player.loseLife();
    // NO: this.maze[y][x] = 0; ← MISSING!
}
```

**Fix:** Add `this.maze[y][x] = 0;` after damage

---

### **Bug #4: Enemy Spawn Position Not Cleared**

```javascript
// In spawnEnemies():
this.maze[y][x] = 0; // ✓ Good

// But enemy visual position starts at grid position
// Smooth movement not initialized properly
```

**Test:** Enemy might "jump" first move

---

### **Bug #5: Save/Load System Broken**

```javascript
// In loadLvl():
if (this.savedData) {
    savedKeys = this.savedData.keys;
    savedMaze = this.savedData.mazeState;
    // ...
    this.savedData = null; // ← Cleared immediately
}

// But player creation is ASYNC (sprite.onload)
// By the time sprite loads, savedData is null!
```

**Fix:** Store savedData temporarily before clearing

---

## **🧪 TEST CASES:**

### **Test 1: Player Movement**

```
✓ Player moves with arrow keys
✓ Cannot walk through walls (tile 1)
✓ Movement is smooth (not jittery)
✓ Direction sprite changes correctly
✗ ISSUE: Can move while previous move animating
```

**How to test:**

- Press arrow rapidly
- Check if player "skips" tiles

**Expected:** Should block input during animation  
**Actual:** Might allow double-move

---

### **Test 2: Key Collection**

```
✓ Keys disappear when collected
✓ Counter updates (0/3 → 1/3)
✓ Door opens at 3 keys
✗ BUG: Counter shows wrong emoji
```

**How to test:**

- Collect all 3 keys in Level 1
- Check HUD shows "🔑 3/3"
- Check door tile changes to 6

**Expected:** Door opens, can enter  
**Actual:** Works but emoji garbled in HUD.js

---

### **Test 3: Enemy Collision**

```
✗ CRITICAL: Collision checked twice
✗ CRITICAL: Player can "pass through" enemy if moving fast
```

**How to test:**

- Stand still, let enemy walk into you → lose heart ✓
- Move INTO enemy → might not trigger

**Expected:** Lose heart on any collision  
**Actual:** Inconsistent

---

### **Test 4: Trap Damage**

```
✗ CRITICAL: Standing on trap loses ALL hearts instantly
```

**How to test:**

- Step on scarab trap (tile 4)
- DON'T MOVE

**Expected:** Lose 1 heart, trap disappears  
**Actual:** Loses heart every frame → instant death

---

### **Test 5: Heart Pickup**

```
✓ Heart disappears when collected
✓ Health increases (max 3)
✗ Can collect heart at 3 HP (wastes it)
```

**How to test:**

- Collect heart at full health

**Expected:** Heart remains if at max  
**Actual:** Heart disappears (wasted)

---

### **Test 6: Timer**

```
✓ Counts down correctly
✓ Game over at 0
✗ Pause doesn't stop timer immediately (race condition)
```

**How to test:**

- Press ESC at timer = 1 second
- Check if it hits 0 before pausing

---

### **Test 7: Win Condition**

```
✗ CRITICAL: Can win with 0 keys if door is tile 6
```

**How to test:**

- Edit maze: change door to 6 from start
- Walk to door with 0 keys

**Expected:** Cannot enter  
**Actual:** Level completes

---

### **Test 8: Save/Load**

```
✗ CRITICAL: Save/Load doesn't work
```

**How to test:**

- Play to Level 2
- Click "Save"
- Refresh page
- Click "Load"

**Expected:** Resume at Level 2  
**Actual:** Might crash or restart Level 1

---

### **Test 9: Fog of War**

```
✓ Circle follows player
✗ Performance: Lag on slower devices
```

**Test:** Check FPS on older laptop

---

### **Test 10: Enemy Movement**

```
✓ Enemies patrol randomly
✗ Enemies can get "stuck" in corners
✗ Enemy speed inconsistent (moveDelay in ms, not frames)
```

**How to test:**

- Watch enemy for 30 seconds
- Does it get stuck?

---

## **🔧 PRIORITY FIXES:**

### **HIGH PRIORITY (Do First):**

1. **Fix Trap Bug:**

```javascript
// In handleTile():
if (tile === 4) {
    this.player.loseLife();
    this.maze[y][x] = 0; // ← ADD THIS
}
```

2. **Fix Win Condition:**

```javascript
checkWin(pos) {
    const tile = this.maze[pos.y][pos.x];
    return (tile === 5 || tile === 6) && this.keys >= 3; // ← FIX
}
```

3. **Remove Duplicate Collision:**

```javascript
// DELETE checkEnemyCollision() function
// Keep only the gameLoop version
```

4. **Fix Save/Load:**

```javascript
loadLvl(num) {
    // Store savedData in local variable BEFORE clearing
    const tempSavedData = this.savedData;
    this.savedData = null;
    
    // Use tempSavedData in sprite.onload
}
```

---

### **MEDIUM PRIORITY:**

5. **Heart at Max HP:**

```javascript
if (tile === 2) {
    if (this.player.getLivesCount() < 3) { // ← ADD CHECK
        this.player.gainLife();
        this.maze[y][x] = 0;
    }
}
```

6. **Enemy Stuck Prevention:**

```javascript
// In EnemyMovement.js - add timeout
if (stuckCounter > 5) {
    // Teleport to random walkable tile
}
```

---

### **LOW PRIORITY:**

7. **Performance - Fog of War:**

```javascript
// Only redraw fog every 2-3 frames
if (frameCount % 2 === 0) {
    this.lightCircle();
}
```

8. **HUD Emoji Fix:**

```javascript
// In HUD.js, use proper UTF-8
element.textContent = '❤️'.repeat(hearts); // Check encoding
```

---

## **📋 TESTING CHECKLIST:**

```
MOVEMENT:
□ Walk up/down/left/right
□ Cannot walk through walls
□ Smooth animation (no jitter)
□ Cannot skip tiles

COLLECTIBLES:
□ Keys: collect, counter updates, door opens at 3
□ Hearts: collect, HP increases (max 3)
□ Hearts: don't waste at max HP

ENEMIES:
□ Enemy spawns correctly
□ Enemy moves randomly
□ Enemy collision damages player
□ Enemy doesn't get stuck
□ Multiple enemies work

TRAPS:
□ Trap damages player once
□ Trap disappears after damage
□ Doesn't infinite damage

WIN/LOSE:
□ Win: reach door with 3 keys
□ Cannot win: door with 0-2 keys
□ Lose: 0 hearts → game over
□ Lose: 0 time → game over

UI:
□ HUD shows correct values
□ Timer counts down
□ Pause works (ESC)
□ Resume works

SAVE/LOAD:
□ Save game state
□ Load restores position, keys, time, maze state
□ Multiple save slots work

LEVELS:
□ Level 1 → 2 → 3 progression
□ Each level loads correctly
□ Enemies spawn per level
□ Timer adjusts per level

FOG OF WAR:
□ Circle follows player
□ No performance issues
□ Visible radius appropriate
```

---

## **🚀 SUGGESTED IMPROVEMENTS:**

### **1. Enemy Collision Feedback**

```javascript
// Add invincibility frames
if (enemyPos.x === playerPos.x && enemyPos.y === playerPos.y) {
    if (!this.player.isInvincible) {
        this.player.loseLife();
        this.player.setInvincible(1000); // 1 second
        // Flash red or blink sprite
    }
}
```

### **2. Better Win Animation**

```javascript
if (this.checkWin(newPos)) {
    this.running = false; // Stop input
    // Show victory animation
    setTimeout(() => this.nextLvl(), 1500);
}
```

### **3. Sound Effects**

```javascript
// Add audio files
sounds = {
    keyCollect: new Audio('sounds/key.mp3'),
    damage: new Audio('sounds/hurt.mp3'),
    win: new Audio('sounds/victory.mp3')
};

// Play on events
if (tile === 3) {
    this.sounds.keyCollect.play();
    this.keys++;
}
```

### **4. Particle Effects**

```javascript
// On key collect, show sparkles
spawnParticles(x, y, color) {
    // Create 10 particles that fade out
}
```

---

## **⚡ QUICK FIX SUMMARY:**

**Do these 4 fixes NOW:**

1. Add `this.maze[y][x] = 0;` after trap damage
2. Change `checkWin()` to require `keys >= 3` always
3. Delete `checkEnemyCollision()` function (keep gameLoop version)
4. Fix save/load async issue

**Test these 3 cases:**

1. Step on trap → should lose 1 heart only
2. Reach door with 2 keys → should NOT win
3. Enemy collision → should lose exactly 1 heart

**Total time: 30 minutes to fix + test** ✅