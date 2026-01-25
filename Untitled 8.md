# CSS & HTML Code Review 🎨

Great work on the styling! You've created a cohesive Egyptian theme with custom fonts, smooth animations, and a well-organized CSS structure. Let's polish it up.

---

## 1. 🍎 Low Hanging Fruit (Quick Wins)

### A) **Consolidate Repeated Color Values**

**Where:** Throughout CSS files, especially in `_buttons.css`, `_load-game.css`, `_settings.css`

**Problem:** You're duplicating the same gradient in multiple places:

```css
/* _load-game.css */
background: linear-gradient(135deg, rgba(90, 74, 58, 0.9), rgba(45, 35, 23, 0.95));

/* _settings.css */
background: linear-gradient(135deg, rgba(90, 74, 58, 0.9), rgba(45, 35, 23, 0.95));
```

**Fix:** Add these to `_variables.css`:

```css
:root {
  /* ...existing colors... */
  
  /* Gradients */
  --gradient-stone: linear-gradient(135deg, rgba(90, 74, 58, 0.9), rgba(45, 35, 23, 0.95));
  --gradient-stone-hover: linear-gradient(135deg, rgba(110, 90, 70, 0.95), rgba(60, 45, 30, 0.98));
  --gradient-gold: linear-gradient(135deg, var(--gold-dark), var(--gold));
  --gradient-gold-hover: linear-gradient(135deg, var(--gold), var(--gold-light));
  
  /* Common rgba values */
  --overlay-dark: rgba(0, 0, 0, 0.8);
  --overlay-darker: rgba(0, 0, 0, 0.5);
}
```

Then use them:

```css
.save-row {
  background: var(--gradient-stone);
}

.save-row:hover {
  background: var(--gradient-stone-hover);
}
```

---

### B) **Clean Up Button Sprite Magic Numbers**

**Where:** `_buttons.css` line 7-10

```css
background-size: 375% 580%;
background-position: 5% 50.5%;
/* ... */
background-position: 50% 50.5%;
/* ... */
background-position: 95% 50.5%;
```

**Problem:** What does `375%` mean? Why `50.5%`? Future you won't remember.

**Fix:** Add comments OR create CSS custom properties:

```css
.menu-btn {
  /* Button sprite: 4 frames horizontal (idle, hover, active, disabled) */
  --btn-sprite-cols: 4;
  --btn-sprite-size: calc(var(--btn-sprite-cols) * 100% - 25%); /* 375% */
  
  /* Positions for each state */
  --btn-pos-idle: 5% 50.5%;
  --btn-pos-hover: 50% 50.5%;
  --btn-pos-active: 95% 50.5%;
  
  background-size: var(--btn-sprite-size) 580%;
  background-position: var(--btn-pos-idle);
}

.menu-btn:hover {
  background-position: var(--btn-pos-hover);
}

.menu-btn:active {
  background-position: var(--btn-pos-active);
}
```

**OR** just add a comment if custom properties feel overkill:

```css
.menu-btn {
  /* Sprite sheet: 4 cols × 2 rows (normal/disabled states) */
  background-size: 375% 580%;
  background-position: 5% 50.5%; /* idle state */
}
```

---

### C) **Fix Inconsistent Spacing Units**

**Where:** Mixed use of `rem`, `px`, `vw`, and percentages

**Examples:**

```css
/* _modal.css */
padding: 1.3rem 4rem; /* rem */
max-height: calc(100% - 1.3rem); /* % + rem */

/* _hud.css */
gap: 2vw; /* viewport width */
width: 9vw; /* viewport width */
min-width: 100px; /* pixels */
```

**Fix:** Stick to `rem` for spacing, `px` only for borders/shadows:

```css
/* _hud.css - Use rem for consistency */
.hud {
  gap: var(--spacing-lg); /* 1.5rem instead of 2vw */
}

.hud-item {
  width: 8rem; /* Fixed size instead of 9vw */
  min-width: 6rem; /* rem instead of 100px */
}
```

**Why?** `vw` breaks on mobile. `rem` scales with user font preferences (accessibility!).

---

## 2. 🚩 Red Flags (Bad Habits)

### **A) Hardcoded Asset Paths in CSS**

**Where:** Every `url()` in your CSS files

```css
/* _home.css */
background-image: url("../../assets/images/frames/home.png");

/* _buttons.css */
background-image: url("../../assets/images/ui-components/button-sprite.png");

/* _gate.css */
background-image: url("../../assets/images/frames/gate-left.png");
```

**Problem:** If you change your folder structure or deploy to a CDN, you have to update 20+ files.

**Fix:** Create a CSS custom property base path:

```css
/* _variables.css */
:root {
  --asset-path: '../../assets';
}

/* Then in other files */
/* _home.css */
background-image: url("var(--asset-path)/images/frames/home.png");
```

**WAIT!** CSS doesn't support `var()` inside `url()` 😞

**Better Fix:** Use a build step OR just document it:

```css
/* _variables.css */
/**
 * ASSET PATHS - If deploying to CDN, update these paths:
 * - Local: ../../assets
 * - CDN: https://cdn.yoursite.com/assets
 */
```

Then use find-and-replace when deploying. Not perfect, but realistic for vanilla CSS.

---

### **B) Semantic HTML Issues**

**Where:** `index.html`

**Problems:**

1. **Using `<menu>` for buttons:**

```html
<menu class="buttons">
  <button onClick="onResume()" class="menu-btn">Resume</button>
</menu>
```

`<menu>` is for toolbars, not button containers. Use `<div>` or `<nav>`.

2. **Inline `onClick` handlers:**

```html
<button onClick="onResume()">Resume</button>
```

This is 2005-style coding. Event listeners belong in JavaScript.

**Fix:**

```html
<!-- Change this -->
<menu class="buttons">
  <button onClick="onResume()">Resume</button>
</menu>

<!-- To this -->
<div class="buttons">
  <button id="btn-resume" class="menu-btn">Resume</button>
</div>
```

```javascript
// navigation.js
document.getElementById('btn-resume').addEventListener('click', () => {
  game.togglePause(false);
  document.getElementById('pause-menu').close();
});
```

**Why?** Separation of concerns. HTML = structure, JS = behavior.

---

### **C) Accessibility Gaps**

**Where:** Throughout HTML

**Problems:**

1. **Missing ARIA labels:**

```html
<canvas id="canvas" width="1180px" height="510px"></canvas>
```

Screen readers can't describe this.

2. **No focus indicators:** Your CSS has `:hover` and `:active`, but no `:focus` styles for keyboard navigation.
    
3. **Toggle switches without labels:**
    

```html
<label class="toggle">
  <input type="checkbox" id="toggle-music" checked />
  <span class="toggle-slider"></span>
</label>
```

The label is visual only; the checkbox itself has no accessible name.

**Fixes:**

```html
<!-- 1. Add ARIA labels -->
<canvas 
  id="canvas" 
  width="1180" 
  height="510"
  role="img"
  aria-label="Maze game playing field">
</canvas>

<!-- 2. Add focus styles in CSS -->
```

```css
/* Add to _buttons.css */
.menu-btn:focus-visible {
  outline: 3px solid var(--gold);
  outline-offset: 4px;
}

/* Add to _settings.css */
.toggle input:focus-visible + .toggle-slider {
  box-shadow: 0 0 0 3px var(--gold);
}
```

```html
<!-- 3. Fix toggle labels -->
<div class="setting-item">
  <label for="toggle-music" class="setting-label">Music</label>
  <div class="toggle">
    <input 
      type="checkbox" 
      id="toggle-music" 
      checked 
      aria-label="Toggle background music"
    />
    <span class="toggle-slider"></span>
  </div>
</div>
```

---

## 3. 🛠️ CSS Organization Best Practice

Your current structure is good:

```
css/
├── base/          # Fonts, variables, reset
├── components/    # Reusable pieces
└── screens/       # Page-specific styles
```

**One improvement:** Add a `utilities/` folder for helper classes:

```
css/
├── base/
├── components/
├── screens/
└── utilities/
    ├── _spacing.css      # .mt-1, .p-2, etc.
    └── _visibility.css   # .hidden, .sr-only, etc.
```

```css
/* utilities/_spacing.css */
.mt-1 { margin-top: var(--spacing-xs); }
.mt-2 { margin-top: var(--spacing-sm); }
/* ... */

/* utilities/_visibility.css */
.hidden {
  display: none;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}
```

Then import in `style.css`:

```css
@import "utilities/_spacing.css";
@import "utilities/_visibility.css";
```

---

## 4. 🎯 Performance Tip

**Where:** `_loading.css`

```css
.loading-screen .scrolling-content {
  animation: infiniteScroll 30s linear infinite;
}
```

**Problem:** Animating `transform: translate()` on a huge text block can lag on low-end devices.

**Fix:** Add `will-change` for GPU acceleration:

```css
.loading-screen .scrolling-content {
  animation: infiniteScroll 30s linear infinite;
  will-change: transform; /* Tells browser to optimize this */
}
```

**Warning:** Don't overuse `will-change`. Only use on elements that actually animate.

---
