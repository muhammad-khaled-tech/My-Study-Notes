# 👻 هندسة الوحش (المومياء) - شرح مبسط

---

## **🎯 الفكرة الأساسية:**

```
الوحش = نقطة تتحرك بين موقعين في المتاهة
زي "الحارس" اللي بيمشي جيئة وذهاباً
```

---

## **📐 المنطق:**

```
الوحش عنده:
1. موقع حالي (x, y)
2. نقطة بداية (startX, startY)
3. نقطة نهاية (endX, endY)
4. اتجاه (direction)
   - إذا كان رايح → من البداية للنهاية
   - إذا كان راجع ← من النهاية للبداية
```

---

## **💻 الكود البسيط:**

### **1. تعريف الوحش:**

```javascript
let enemy = {
    x: 3,           // موقع حالي (عمود)
    y: 2,           // موقع حالي (صف)
    startX: 3,      // نقطة البداية
    startY: 2,
    endX: 7,        // نقطة النهاية
    endY: 2,
    direction: 1,   // 1 = رايح، -1 = راجع
    speed: 0.02     // سرعة الحركة (أبطأ من اللاعب)
};
```

---

### **2. تحريك الوحش:**

```javascript
function updateEnemy() {
    // لو بيتحرك أفقياً (في نفس الصف)
    if (enemy.startY === enemy.endY) {
        // حرك في X
        enemy.x += enemy.speed * enemy.direction;
        
        // لو وصل النهاية → اقلب الاتجاه
        if (enemy.direction === 1 && enemy.x >= enemy.endX) {
            enemy.direction = -1;  // ارجع
        }
        // لو وصل البداية → اقلب الاتجاه
        else if (enemy.direction === -1 && enemy.x <= enemy.startX) {
            enemy.direction = 1;   // روح
        }
    }
    
    // لو بيتحرك رأسياً (في نفس العمود)
    else if (enemy.startX === enemy.endX) {
        // حرك في Y
        enemy.y += enemy.speed * enemy.direction;
        
        // لو وصل النهاية
        if (enemy.direction === 1 && enemy.y >= enemy.endY) {
            enemy.direction = -1;
        }
        // لو وصل البداية
        else if (enemy.direction === -1 && enemy.y <= enemy.startY) {
            enemy.direction = 1;
        }
    }
}
```

---

### **3. رسم الوحش:**

```javascript
// تحميل صورة المومياء
const mummyImage = new Image();
mummyImage.src = '../../assets/images/mummy.png';

function drawEnemy() {
    const x = enemy.x * TILE_SIZE - camera.x;
    const y = enemy.y * TILE_SIZE - camera.y;
    
    ctx.drawImage(
        mummyImage,
        x,
        y,
        TILE_SIZE,
        TILE_SIZE
    );
}
```

---

### **4. التصادم مع اللاعب:**

```javascript
function checkEnemyCollision() {
    // حساب المسافة بين اللاعب والعدو
    const dx = Math.abs(player.x - enemy.x);
    const dy = Math.abs(player.y - enemy.y);
    
    // لو قريبين جداً (في نفس المربع تقريباً)
    if (dx < 0.5 && dy < 0.5) {
        // اللاعب اتضرب!
        playerHearts--;
        
        // ارجع اللاعب لنقطة البداية
        player.x = 1;
        player.y = 1;
        
        // لو القلوب خلصت
        if (playerHearts <= 0) {
            alert('Game Over!');
            // restart game
        }
    }
}
```

---

### **5. دمجهم في Game Loop:**

```javascript
function gameLoop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    updateCamera();
    
    // تحديث الوحش
    updateEnemy();
    
    // شيك التصادم
    checkEnemyCollision();
    
    drawMaze();
    drawPlayer();
    drawEnemy();  // ← ارسم الوحش
    
    requestAnimationFrame(gameLoop);
}
```

---

## **🎮 مثال كامل:**

```javascript
// =========================================
// لعبة مع وحش متحرك
// =========================================

const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

const maze = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 1],  // ← الوحش يتحرك هنا
    [1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 5, 1]
];

const TILE_SIZE = 80;

let player = {
    x: 1,
    y: 1
};

let enemy = {
    x: 2,
    y: 2,
    startX: 2,
    startY: 2,
    endX: 8,
    endY: 2,
    direction: 1,
    speed: 0.02
};

let camera = {
    x: 0,
    y: 0
};

let playerHearts = 3;

// رسم المتاهة
function drawMaze() {
    for (let row = 0; row < maze.length; row++) {
        for (let col = 0; col < maze[row].length; col++) {
            const x = col * TILE_SIZE - camera.x;
            const y = row * TILE_SIZE - camera.y;
            
            if (maze[row][col] === 1) {
                ctx.fillStyle = '#8B4513';
                ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
            } else {
                ctx.fillStyle = '#F4A460';
                ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
            }
            
            if (maze[row][col] === 5) {
                ctx.fillStyle = '#FFD700';
                ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
            }
        }
    }
}

// رسم اللاعب
function drawPlayer() {
    const x = player.x * TILE_SIZE - camera.x;
    const y = player.y * TILE_SIZE - camera.y;
    
    ctx.fillStyle = '#00CED1';
    ctx.fillRect(x + 10, y + 10, TILE_SIZE - 20, TILE_SIZE - 20);
}

// رسم الوحش
function drawEnemy() {
    const x = enemy.x * TILE_SIZE - camera.x;
    const y = enemy.y * TILE_SIZE - camera.y;
    
    ctx.fillStyle = '#8B008B';  // بنفسجي (المومياء)
    ctx.fillRect(x + 5, y + 5, TILE_SIZE - 10, TILE_SIZE - 10);
    
    // عينين حمرا
    ctx.fillStyle = '#FF0000';
    ctx.fillRect(x + 20, y + 20, 10, 10);
    ctx.fillRect(x + 50, y + 20, 10, 10);
}

// تحديث الكاميرا
function updateCamera() {
    camera.x = (player.x * TILE_SIZE) - (canvas.width / 2);
    camera.y = (player.y * TILE_SIZE) - (canvas.height / 2);
    
    if (camera.x < 0) camera.x = 0;
    if (camera.y < 0) camera.y = 0;
}

// تحديث الوحش
function updateEnemy() {
    // حركة أفقية
    if (enemy.startY === enemy.endY) {
        enemy.x += enemy.speed * enemy.direction;
        
        if (enemy.direction === 1 && enemy.x >= enemy.endX) {
            enemy.direction = -1;
        } else if (enemy.direction === -1 && enemy.x <= enemy.startX) {
            enemy.direction = 1;
        }
    }
    // حركة رأسية
    else if (enemy.startX === enemy.endX) {
        enemy.y += enemy.speed * enemy.direction;
        
        if (enemy.direction === 1 && enemy.y >= enemy.endY) {
            enemy.direction = -1;
        } else if (enemy.direction === -1 && enemy.y <= enemy.startY) {
            enemy.direction = 1;
        }
    }
}

// شيك التصادم
function checkEnemyCollision() {
    const dx = Math.abs(player.x - enemy.x);
    const dy = Math.abs(player.y - enemy.y);
    
    if (dx < 0.5 && dy < 0.5) {
        playerHearts--;
        console.log('Hit! Hearts:', playerHearts);
        
        // ارجع اللاعب للبداية
        player.x = 1;
        player.y = 1;
        
        if (playerHearts <= 0) {
            alert('Game Over!');
            playerHearts = 3;
            player.x = 1;
            player.y = 1;
        }
    }
}

// حركة اللاعب
function movePlayer(dx, dy) {
    const newX = player.x + dx;
    const newY = player.y + dy;
    
    if (maze[newY] && maze[newY][newX] !== 1) {
        player.x = newX;
        player.y = newY;
    }
    
    if (maze[player.y][player.x] === 5) {
        alert('فزت!');
    }
}

// الأسهم
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowUp') movePlayer(0, -1);
    if (e.key === 'ArrowDown') movePlayer(0, 1);
    if (e.key === 'ArrowLeft') movePlayer(-1, 0);
    if (e.key === 'ArrowRight') movePlayer(1, 0);
});

// Game Loop
function gameLoop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    updateCamera();
    updateEnemy();        // ← تحديث الوحش
    checkEnemyCollision(); // ← شيك التصادم
    
    drawMaze();
    drawPlayer();
    drawEnemy();          // ← رسم الوحش
    
    requestAnimationFrame(gameLoop);
}

gameLoop();
```

---

## **🎨 لو عايزين أكتر من وحش:**

```javascript
// Array من الوحوش
let enemies = [
    {
        x: 2, y: 2,
        startX: 2, startY: 2,
        endX: 8, endY: 2,
        direction: 1, speed: 0.02
    },
    {
        x: 5, y: 4,
        startX: 5, startY: 4,
        endX: 5, endY: 1,  // ← يتحرك رأسياً
        direction: 1, speed: 0.015
    }
];

// تحديث كل الوحوش
function updateEnemies() {
    enemies.forEach(enemy => {
        // نفس الكود بتاع updateEnemy
        if (enemy.startY === enemy.endY) {
            enemy.x += enemy.speed * enemy.direction;
            if (enemy.direction === 1 && enemy.x >= enemy.endX) {
                enemy.direction = -1;
            } else if (enemy.direction === -1 && enemy.x <= enemy.startX) {
                enemy.direction = 1;
            }
        } else if (enemy.startX === enemy.endX) {
            enemy.y += enemy.speed * enemy.direction;
            if (enemy.direction === 1 && enemy.y >= enemy.endY) {
                enemy.direction = -1;
            } else if (enemy.direction === -1 && enemy.y <= enemy.startY) {
                enemy.direction = 1;
            }
        }
    });
}

// رسم كل الوحوش
function drawEnemies() {
    enemies.forEach(enemy => {
        const x = enemy.x * TILE_SIZE - camera.x;
        const y = enemy.y * TILE_SIZE - camera.y;
        
        ctx.fillStyle = '#8B008B';
        ctx.fillRect(x + 5, y + 5, TILE_SIZE - 10, TILE_SIZE - 10);
    });
}

// شيك التصادم مع كل الوحوش
function checkEnemiesCollision() {
    enemies.forEach(enemy => {
        const dx = Math.abs(player.x - enemy.x);
        const dy = Math.abs(player.y - enemy.y);
        
        if (dx < 0.5 && dy < 0.5) {
            playerHearts--;
            player.x = 1;
            player.y = 1;
            
            if (playerHearts <= 0) {
                alert('Game Over!');
                playerHearts = 3;
            }
        }
    });
}

// في Game Loop
function gameLoop() {
    // ...
    updateEnemies();
    checkEnemiesCollision();
    drawEnemies();
    // ...
}
```

---

## **🗺️ تحديد مسار الوحش في المتاهة:**

### **طريقة 1: يدوي (أسهل)**

```javascript
// شوف المتاهة:
const maze = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 1],  // ← صف 2
    //   ↑           ↑           ↑
    //  col 2       col 5      col 8
];

// الوحش يتحرك من (2,2) لـ (8,2)
let enemy = {
    startX: 2, startY: 2,
    endX: 8, endY: 2
};
```

**الخطوات:**

1. شوف صف فيه ممر طويل
2. اختار نقطة بداية ونهاية
3. حطهم في enemy object

---

### **طريقة 2: علّم في المتاهة**

```javascript
// في المتاهة، استخدم رقم جديد (مثلاً 4)
const maze = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 4, 0, 0, 0, 0, 0, 4, 1],  // ← 4 = نقاط الوحش
    [1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
];

// اقرأ المتاهة واستخرج النقاط
function findEnemyPoints() {
    let points = [];
    for (let row = 0; row < maze.length; row++) {
        for (let col = 0; col < maze[row].length; col++) {
            if (maze[row][col] === 4) {
                points.push({ x: col, y: row });
                maze[row][col] = 0;  // امسحها من المتاهة
            }
        }
    }
    return points;
}

let enemyPoints = findEnemyPoints();
let enemy = {
    x: enemyPoints[0].x,
    y: enemyPoints[0].y,
    startX: enemyPoints[0].x,
    startY: enemyPoints[0].y,
    endX: enemyPoints[1].x,
    endY: enemyPoints[1].y,
    direction: 1,
    speed: 0.02
};
```

---

## **🎯 نصائح مهمة:**

### **1. السرعة:**

```javascript
speed: 0.02  // ← بطيء (سهل)
speed: 0.05  // ← متوسط
speed: 0.08  // ← سريع (صعب)
```

### **2. عدد الوحوش:**

```
Level 1: وحش واحد
Level 2: وحشين
Level 3: 3-4 وحوش
```

### **3. أنماط الحركة:**

```javascript
// أفقي بس
startX: 2, startY: 2,
endX: 8, endY: 2

// رأسي بس
startX: 5, startY: 1,
endX: 5, endY: 4

// ممكن تعمل L-shape (متقدم)
// هتحتاج waypoints
```

---

## **✅ الخلاصة:**

**الوحش = object فيه:**

- موقع حالي
- نقطة بداية
- نقطة نهاية
- اتجاه
- سرعة

**كل frame:**

1. حرّك الوحش شوية (`x += speed`)
2. لو وصل النهاية → اقلب الاتجاه
3. شيك: اللاعب قريب؟ → ضرب!

**بسيط وفعّال!** 👻✨