
# 📄 GitHub README.md

Now for your README! Here's a comprehensive template:

---

<div align="center">

```
███╗   ███╗ █████╗ ███████╗███████╗██████╗ 
████╗ ████║██╔══██╗╚══███╔╝██╔════╝██╔══██╗
██╔████╔██║███████║  ███╔╝ █████╗  ██████╔╝
██║╚██╔╝██║██╔══██║ ███╔╝  ██╔══╝  ██╔══██╗
██║ ╚═╝ ██║██║  ██║███████╗███████╗██║  ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
```

<h3>🏺 An Egyptian-Themed Maze Adventure Game 🏺</h3>

[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript) [![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML) [![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/CSS) [![Canvas](https://img.shields.io/badge/Canvas_API-FF6F00?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)

[Play Live Demo](https://claude.ai/chat/d7687c2c-52c1-46f1-a27f-9e4452958cca#) • [Report Bug](https://github.com/yourusername/mazer/issues) • [Request Feature](https://github.com/yourusername/mazer/issues)

![Mazer Gameplay](https://claude.ai/chat/assets/screenshots/gameplay.gif)

</div>

---

## 📜 About The Project

**Mazer** is a 2D maze adventure game built entirely with **vanilla JavaScript** (no frameworks, no game engines) as part of the **ITI Open Source Track - Intake 46** curriculum. Navigate through Egyptian-themed labyrinths, avoid deadly traps and mummies, collect ancient keys, and escape before time runs out!

### ✨ Key Features

- 🎮 **Pure Vanilla JS** – No frameworks, just clean JavaScript game logic
- 🗺️ **3 Challenging Levels** – Progressive difficulty with traps and enemies
- 👻 **Smart Enemy AI** – Mummies that patrol the maze with pathfinding
- 💾 **Save/Load System** – 3 save slots using localStorage
- 🎵 **Dynamic Audio** – Egyptian music and sound effects
- 📹 **Smooth Camera** – Follows player with viewport clamping
- 💡 **Dynamic Lighting** – Radial gradient darkness effect
- ⏱️ **Time-Based Challenges** – Complete levels before the timer runs out
- 🎨 **Custom Egyptian Theme** – Hand-crafted sprites, fonts, and UI

---

## 🎬 Screenshots

<div align="center">

|Home Screen|Gameplay|Victory|
|---|---|---|
|![Home](https://claude.ai/chat/assets/screenshots/home.png)|![Game](https://claude.ai/chat/assets/screenshots/game.png)|![Win](https://claude.ai/chat/assets/screenshots/win.png)|

</div>

---

## 🚀 Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Edge, Safari)
- A local web server (optional but recommended)

### Installation

1. **Clone the repository**
    
    ```bash
    git clone https://github.com/yourusername/mazer.git
    cd mazer
    ```
    
2. **Run with a local server** (recommended)
    
    ```bash
    # Using Python 3
    python -m http.server 8000
    
    # Using Node.js (http-server)
    npx http-server
    
    # Using PHP
    php -S localhost:8000
    ```
    
3. **Open in browser**
    
    ```
    http://localhost:8000
    ```
    
    **Or** simply open `index.html` directly (some features may not work without a server).
    

---

## 🎮 How to Play

### Controls

|Key|Action|
|---|---|
|`↑`|Move Up|
|`↓`|Move Down|
|`←`|Move Left|
|`→`|Move Right|
|`Esc`|Pause Menu|
|`S`|Quick Save|

### Game Mechanics

- **Objective:** Collect all 3 keys to unlock the exit door
- **Hearts (❤️):** Gems that restore 1 life
- **Keys (🔑):** Required to open the exit
- **Traps (🪲):** Scarab traps that reduce 1 life
- **Mummies (👻):** Moving enemies that reset your position
- **Timer:** Complete the level before time runs out!

### Level Progression

- **Level 1:** 90 seconds, 3 traps
- **Level 2:** 120 seconds, 3 mummies
- **Level 3:** 180 seconds, 3 traps + 3 mummies

---

## 🏗️ Project Structure

```
mazer/
├── assets/
│   ├── fonts/              # Custom Egyptian fonts
│   ├── images/
│   │   ├── frames/         # UI backgrounds and borders
│   │   ├── gameplay/       # Tiles, characters, items
│   │   ├── sprites/        # Player sprite sheets
│   │   └── traps/          # Trap animations
│   └── sounds/             # Music and SFX
├── css/
│   ├── base/               # Reset, variables, fonts
│   ├── components/         # Buttons, modals, HUD
│   └── screens/            # Screen-specific styles
├── js/
│   ├── core/               # Game.js, Timer.js, HUD.js
│   ├── enemies/            # Enemy logic and AI
│   ├── maze/               # Maze rendering and levels
│   ├── player/             # Player controller and movement
│   ├── storage/            # Save/load system
│   └── navigation.js       # Screen transitions
└── index.html
```

---

## 🧩 Technical Highlights

### Architecture Patterns

- **MVC-inspired structure:** Separation of game logic, rendering, and UI
- **Component-based design:** Reusable player, enemy, and camera modules
- **Event-driven controls:** Keyboard input handlers with debouncing
- **State management:** Centralized game state in `Game.js`

### Core Systems

```javascript
// Example: Player Movement System
class PlayerMovement {
  movePlayer(dx, dy) {
    const { x, y } = this.player.getPlayerPosition();
    const newX = x + dx, newY = y + dy;
    
    if (!this.canMoveTo(newX, newY)) return false;
    
    this.player.setPlayerPosition(newX, newY);
    this.player.setMoving(true);
    return true;
  }
}
```

### Canvas Rendering

- **Tile-based system:** 120x120px tiles with sprite atlases
- **Camera follow:** Smooth interpolation with boundary clamping
- **Layered rendering:** Background → Enemies → Player → Lighting
- **Sprite animation:** Frame-based character animations

### Save System

```javascript
// LocalStorage-based save slots
StorageSystem.saveToSlot(1, {
  level: 2,
  hearts: 3,
  keys: 1,
  time: 75,
  playerPosition: { x: 5, y: 3 },
  mazeState: [[0, 1, 0], ...]
});
```

---

## 🛠️ Technologies Used

- **JavaScript (ES6+)** – Classes, modules, async/await
- **HTML5 Canvas API** – 2D rendering
- **CSS3** – Animations, gradients, custom properties
- **LocalStorage API** – Save/load persistence
- **Web Audio API** – Background music and sound effects

---

## 👥 Team

This project was created by students from **ITI Open Source Track - Intake 46**:

<table> <tr> <td align="center"> <a href="https://github.com/student1"> <img src="https://github.com/student1.png" width="100px;" alt="Student 1"/><br /> <sub><b>Student Name 1</b></sub> </a><br /> <sub>Game Logic & AI</sub> </td> <td align="center"> <a href="https://github.com/student2"> <img src="https://github.com/student2.png" width="100px;" alt="Student 2"/><br /> <sub><b>Student Name 2</b></sub> </a><br /> <sub>Rendering & Animations</sub> </td> <td align="center"> <a href="https://github.com/student3"> <img src="https://github.com/student3.png" width="100px;" alt="Student 3"/><br /> <sub><b>Student Name 3</b></sub> </a><br /> <sub>UI/UX Design</sub> </td> <td align="center"> <a href="https://github.com/student4"> <img src="https://github.com/student4.png" width="100px;" alt="Student 4"/><br /> <sub><b>Student Name 4</b></sub> </a><br /> <sub>Level Design & Testing</sub> </td> </tr> </table>

---

## 📝 Lessons Learned

### What We Learned

- ✅ Game loop implementation with `requestAnimationFrame`
- ✅ Collision detection and grid-based movement
- ✅ Sprite animation and state machines
- ✅ Camera systems and viewport management
- ✅ Event-driven programming patterns
- ✅ Code organization without frameworks

### Challenges Faced

- 🔧 **Enemy Pathfinding:** Implementing simple AI without libraries
- 🔧 **Smooth Movement:** Interpolating sprite positions vs. grid positions
- 🔧 **Save State:** Serializing complex game state to JSON
- 🔧 **Performance:** Optimizing canvas redraws for 60fps

---

## 🔮 Future Enhancements

- [ ] Additional levels with new mechanics (ice floors, teleporters)
- [ ] Boss fights at the end of each world
- [ ] Leaderboard system with online persistence
- [ ] Mobile touch controls
- [ ] Procedural maze generation
- [ ] Power-ups (speed boost, invincibility, extra time)
- [ ] Achievements system

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://claude.ai/chat/LICENSE) file for details.

---

## 🙏 Acknowledgments

- **ITI Open Source Track** – For the amazing learning experience
- **Instructors** – For guidance and code reviews
- **Pixel Art Assets** – [Credit any asset sources here]
- **Egyptian Fonts** – [Credit font creators]
- **Sound Effects** – [Credit audio sources]

---

<div align="center">

**Made with ❤️ by ITI Open Source Track - Intake 46**

[⬆ back to top](https://claude.ai/chat/d7687c2c-52c1-46f1-a27f-9e4452958cca#)

</div>

---

## 🎯 Final CSS Summary

|Priority|Action|Effort|Impact|
|---|---|---|---|
|🔥 **Do First**|Add gradient CSS variables|30 min|Reduces 10+ duplicated lines|
|🔥 **Do First**|Fix inline `onClick` handlers|1 hour|Proper separation of concerns|
|⚠️ **Do Soon**|Add `:focus-visible` styles|30 min|Keyboard accessibility|
|⚠️ **Do Soon**|Document sprite magic numbers|15 min|Future maintainability|
|📚 **Reference**|Use `rem` instead of `vw`/`px`|1 hour|Responsive + accessible|

---

**You've built something genuinely impressive!** A complete game with save/load, AI enemies, animations, and a cohesive theme—all in vanilla JS. The CSS is clean, the HTML is structured, and the architecture is solid.

Now go add that README, fix those inline event handlers, and **ship it to GitHub!** 🚀