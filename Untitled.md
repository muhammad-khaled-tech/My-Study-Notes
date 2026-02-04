This is the extended execution and study plan for your **Angular Lecture 3 Lab (Products App)**. This plan is designed to bridge the gap between your theory and the final project delivery.

---

## I. Required Topics to Study

Before starting the code, ensure you have covered these specific modules in your resources:

### 1. Angular Routing Fundamentals

- **The Routes Array:** How to map a URL `path` to a specific `component`.
    
- **RouterOutlet:** Understanding the placeholder where components are rendered.
    
- **RouterLink & RouterLinkActive:** Navigating without page refreshes and providing visual feedback (e.g., changing link color).
    
- **Wildcard Routes:** Setting up the `**` path for "Not Found" pages.
    

### 2. Advanced Navigation

- **Parameterized Routes:** Defining paths with variables (e.g., `:id`) to handle dynamic content.
    
- **ActivatedRoute vs. Component Input Binding:** Learning how to retrieve the `id` from the URL.
    
- **Programmatic Navigation:** Using the `Router` service to navigate via TypeScript code.
    

### 3. Protection & Transformation

- **Route Guards:** Implementing `canActivate` to protect routes like the "Cart".
    
- **Built-in Pipes:** Using `currency`, `date`, `uppercase`, and `lowercase`.
    
- **Custom Pipes:** Creating your own functions to transform data in the template.
    

---

## II. Extended Lab Execution Plan (The Products App)

### Phase 1: Environment & Data Modeling

1. **Generate Components:** Use the CLI to create `products-list`, `product-details`, `login`, `register`, `cart`, `navbar`, and `not-found` .
    
2. **Define the Interface:** Create a `Product` interface in a separate file to define properties like `id`, `title`, `description`, `price`, `stock`, `image`, and `discountPercentage`.
    
3. **Local Data:** Import the provided products array into your `ProductsListComponent`.
    

### Phase 2: Navigation Backbone

1. **Configure Routes:** In your routing file, set up paths for all components .
    
2. **Default & Wildcard:** Set an empty path `''` to redirect to `/products` and the `**` path for the `NotFoundComponent`.
    
3. **Setup Navbar:** Implement the `routerLink` for each page and use `routerLinkActive` to apply an **orange color** to the active route.
    

### Phase 3: The Products Catalog

1. **List Rendering:** Use the `@for` control flow to iterate through the products and pass each object to a `ProductCardComponent`.
    
2. **Stock Logic (Conditional Styling):**
    
    - If `stock === 0`: Display "Out of stock" in **Red**.
        
    - If `stock > 0`: Display "In stock" in **Green**.
        
3. **Add to Cart Button:** Create a button that (for now) logs the product to the console.
    

### Phase 4: Dynamic Product Details

1. **Dynamic Route Config:** Define the details path as `product/:id`.
    
2. **Trigger Navigation:** Wrap the product card (or a button inside it) in a `routerLink` that passes the `product.id`.
    
3. **Fetch Single Product:**
    
    - In `ProductDetailsComponent`, use `ActivatedRoute` or `@Input id` to get the ID.
        
    - Find the matching product in the array and display its full details (images, rating, category, description).
        

### Phase 5: Transformations & Guards (The Bonus)

1. **Built-in Pipes:** Format all prices using the `currency` pipe.
    
2. **Custom Discount Pipe (Bonus):**
    
    - Generate a pipe: `ng generate pipe discount`.
        
    - The `transform` method should take the `price` and `discountPercentage` to return the new price.
        
3. **Simple Guard:** Protect the `/cart` route so only "logged in" users can access it.
    

---

## III. Your Obsidian Workflow

Since you are a "Technical Thought Partner" for your Obsidian vault, use these steps during study:

1. **The "Guard" Visualization:** Draw a flow chart in **Excalidraw** showing how a user is redirected if the Guard returns `false`.
    
2. **Code Snippet Library:** Create a folder for "Angular Snippets" including the `transform()` logic for your custom pipe.
    
3. **Refresher Links:** Link your new Angular notes to your previous **TypeScript Interfaces** notes to see how data models carry over.
    

---

**Would you like me to generate the "Custom Discount Pipe" logic or the "Routes Array" code specifically for this lab?**