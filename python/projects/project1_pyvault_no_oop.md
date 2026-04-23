# 🔐 Project 1 — PyVault
### A Secret Message Encoder, Decoder & Password Manager (No OOP)

---

## 🧠 What You're Building

A terminal app that lets users:
- Encode & decode secret messages using two cipher methods
- Generate strong random passwords
- Save & load vaults (encoded messages + passwords) to/from JSON files
- Search through saved vault entries
- Show stats about their vault

This is a **real, useful tool** — not a toy. By the end you'll have touched every core Python concept.

---

## 🗺️ Concepts Map

| Feature | Concepts Covered |
|---|---|
| Main menu loop | `while`, `input()`, `if/elif/else` |
| Caesar Cipher | strings, `ord()`, `chr()`, loops, slicing |
| Vigenere Cipher | nested loops, `zip()`, modulo `%` |
| Password Generator | `random`, `string` modules, list comprehension |
| Save to file | `json`, `open()`, `write`, error handling |
| Load from file | `json`, `try/except`, file reading |
| Search vault | `dict`, list of dicts, `for` loop, `in` keyword |
| Stats | `len()`, `dict`, counting patterns |
| Input validation | `while True`, `try/except`, `isdigit()` |
| Helpers | pure functions, return values, default args |

---

## 📁 Project Structure

```
pyvault/
│
├── main.py          ← entry point, main menu
├── ciphers.py       ← caesar & vigenere functions
├── generator.py     ← password generator functions
├── vault.py         ← save, load, search vault (file I/O)
├── utils.py         ← helper functions (validation, display)
└── vault_data.json  ← auto-created when user saves data
```

---

## 🏗️ Phase 1 — The Menu Skeleton
**Goal:** Get a working loop with a menu before writing any real logic.

```python
# main.py

def show_menu():
    print("\n" + "="*40)
    print("       🔐 PyVault — Your Secret Keeper")
    print("="*40)
    print("1. Encode a message")
    print("2. Decode a message")
    print("3. Generate a password")
    print("4. Save to vault")
    print("5. View / Search vault")
    print("6. Vault stats")
    print("0. Exit")
    print("="*40)


def main():
    print("Welcome to PyVault!")
    
    while True:
        show_menu()
        choice = input("Choose an option: ").strip()
        
        if choice == "1":
            print("→ [Encode] — Coming soon")
        elif choice == "2":
            print("→ [Decode] — Coming soon")
        elif choice == "3":
            print("→ [Password Generator] — Coming soon")
        elif choice == "4":
            print("→ [Save] — Coming soon")
        elif choice == "5":
            print("→ [View Vault] — Coming soon")
        elif choice == "6":
            print("→ [Stats] — Coming soon")
        elif choice == "0":
            print("Goodbye! Stay secret. 🔐")
            break
        else:
            print("❌ Invalid choice. Try again.")


if __name__ == "__main__":
    main()
```

> ✅ **Checkpoint:** Run this. The menu should loop forever until you press 0.

---

## 🏗️ Phase 2 — Caesar Cipher
**Goal:** Encode and decode text by shifting letters.

```python
# ciphers.py

def caesar_encode(text, shift):
    """
    Shifts every letter by 'shift' positions in the alphabet.
    Numbers and symbols stay unchanged.
    
    Example: caesar_encode("Hello", 3) → "Khoor"
    """
    result = ""
    
    for char in text:
        if char.isalpha():
            # Find base: 'A' for uppercase, 'a' for lowercase
            base = ord('A') if char.isupper() else ord('a')
            
            # Shift the character and wrap around using modulo
            shifted = (ord(char) - base + shift) % 26
            result += chr(base + shifted)
        else:
            result += char  # Keep spaces, digits, punctuation as-is
    
    return result


def caesar_decode(text, shift):
    """
    Decoding is just encoding with a negative shift.
    """
    return caesar_encode(text, -shift)
```

**In main.py, replace the encode placeholder:**
```python
elif choice == "1":
    from ciphers import caesar_encode, vigenere_encode
    
    message = input("Enter your message: ")
    method = input("Method — (1) Caesar  (2) Vigenere: ").strip()
    
    if method == "1":
        shift = int(input("Shift amount (e.g. 3): "))
        encoded = caesar_encode(message, shift)
        print(f"✅ Encoded: {encoded}")
    elif method == "2":
        print("→ Vigenere coming in Phase 3")
```

> ✅ **Checkpoint:** Encode "Hello World" with shift 13. You should get "Uryyb Jbeyq".

---

## 🏗️ Phase 3 — Vigenere Cipher
**Goal:** A more advanced cipher using a keyword — each letter uses a different shift.

```python
# Add to ciphers.py

def vigenere_encode(text, keyword):
    """
    Each letter in the text is shifted by the corresponding letter
    in the keyword (cycling through the keyword repeatedly).
    
    Example: vigenere_encode("HELLO", "KEY") → "RIJVS"
    """
    keyword = keyword.lower()
    result = ""
    key_index = 0  # Separate index for keyword (skips non-alpha chars)
    
    for char in text:
        if char.isalpha():
            shift = ord(keyword[key_index % len(keyword)]) - ord('a')
            base = ord('A') if char.isupper() else ord('a')
            encoded_char = chr((ord(char) - base + shift) % 26 + base)
            result += encoded_char
            key_index += 1  # Only advance keyword index for letters
        else:
            result += char
    
    return result


def vigenere_decode(text, keyword):
    """
    Decode by shifting backwards using the keyword.
    """
    keyword = keyword.lower()
    result = ""
    key_index = 0
    
    for char in text:
        if char.isalpha():
            shift = ord(keyword[key_index % len(keyword)]) - ord('a')
            base = ord('A') if char.isupper() else ord('a')
            decoded_char = chr((ord(char) - base - shift) % 26 + base)
            result += decoded_char
            key_index += 1
        else:
            result += char
    
    return result
```

> ✅ **Checkpoint:** Encode "HELLO" with keyword "KEY", then decode it back. You should get "HELLO".

---

## 🏗️ Phase 4 — Password Generator
**Goal:** Generate secure random passwords with options.

```python
# generator.py

import random
import string


def generate_password(length=16, use_upper=True, use_digits=True, use_symbols=True):
    """
    Builds a character pool based on user preferences,
    then picks random characters from it.
    """
    pool = string.ascii_lowercase  # Always include lowercase
    
    if use_upper:
        pool += string.ascii_uppercase
    if use_digits:
        pool += string.digits
    if use_symbols:
        pool += string.punctuation
    
    if not pool:
        raise ValueError("At least one character type must be selected!")
    
    # Pick 'length' random chars from the pool
    password = ''.join(random.choice(pool) for _ in range(length))
    return password


def check_strength(password):
    """
    Returns a strength label based on what the password contains.
    """
    score = 0
    
    if len(password) >= 12:
        score += 1
    if any(c.isupper() for c in password):
        score += 1
    if any(c.isdigit() for c in password):
        score += 1
    if any(c in string.punctuation for c in password):
        score += 1
    
    labels = {0: "❌ Very Weak", 1: "🟠 Weak", 2: "🟡 Fair", 3: "🟢 Strong", 4: "🔵 Very Strong"}
    return labels[score]
```

> ✅ **Checkpoint:** Generate 5 passwords of length 20 with all options. Check that they all look different.

---

## 🏗️ Phase 5 — Vault (File I/O)
**Goal:** Save and load entries to/from a JSON file.

```python
# vault.py

import json
import os
from datetime import datetime

VAULT_FILE = "vault_data.json"


def load_vault():
    """
    Loads the vault from disk. Returns empty list if file doesn't exist.
    """
    if not os.path.exists(VAULT_FILE):
        return []
    
    try:
        with open(VAULT_FILE, "r") as f:
            return json.load(f)
    except json.JSONDecodeError:
        print("⚠️ Vault file is corrupted. Starting fresh.")
        return []


def save_vault(vault):
    """
    Saves the entire vault list back to disk.
    """
    with open(VAULT_FILE, "w") as f:
        json.dump(vault, f, indent=2)
    print("✅ Vault saved.")


def add_entry(label, content, entry_type="message"):
    """
    Adds a new entry to the vault.
    entry_type: 'message' or 'password'
    """
    vault = load_vault()
    
    entry = {
        "id": len(vault) + 1,
        "label": label,
        "content": content,
        "type": entry_type,
        "created_at": datetime.now().strftime("%Y-%m-%d %H:%M")
    }
    
    vault.append(entry)
    save_vault(vault)
    return entry


def search_vault(keyword):
    """
    Returns all entries whose label contains the keyword (case-insensitive).
    """
    vault = load_vault()
    keyword = keyword.lower()
    
    return [entry for entry in vault if keyword in entry["label"].lower()]


def get_stats():
    """
    Returns a dict with summary stats about the vault.
    """
    vault = load_vault()
    
    messages = [e for e in vault if e["type"] == "message"]
    passwords = [e for e in vault if e["type"] == "password"]
    
    return {
        "total": len(vault),
        "messages": len(messages),
        "passwords": len(passwords),
    }
```

> ✅ **Checkpoint:** Save two entries, then open `vault_data.json` in a text editor. You should see your data as formatted JSON.

---

## 🏗️ Phase 6 — Input Validation (utils.py)
**Goal:** Make the app bulletproof against bad input.

```python
# utils.py

def get_int_input(prompt, min_val=1, max_val=100):
    """
    Keeps asking until the user enters a valid integer in range.
    """
    while True:
        try:
            value = int(input(prompt))
            if min_val <= value <= max_val:
                return value
            else:
                print(f"❌ Enter a number between {min_val} and {max_val}.")
        except ValueError:
            print("❌ That's not a number. Try again.")


def get_yes_no(prompt):
    """
    Asks a yes/no question and returns True/False.
    """
    while True:
        answer = input(prompt + " (y/n): ").strip().lower()
        if answer == 'y':
            return True
        elif answer == 'n':
            return False
        else:
            print("❌ Please enter 'y' or 'n'.")


def print_divider(char="─", length=40):
    print(char * length)


def print_entry(entry):
    print_divider()
    print(f"  🆔 ID     : {entry['id']}")
    print(f"  🏷️  Label  : {entry['label']}")
    print(f"  📦 Type   : {entry['type']}")
    print(f"  🔑 Content: {entry['content']}")
    print(f"  🕒 Saved  : {entry['created_at']}")
    print_divider()
```

---

## 🏗️ Phase 7 — Wire Everything Together (main.py final)

Now replace all the "Coming soon" placeholders in `main.py` with real calls to your modules. The full main menu should:

- **Option 1 (Encode):** Ask for message → ask for cipher method → ask for key/shift → show result → ask if they want to save it
- **Option 2 (Decode):** Same flow but reversed
- **Option 3 (Generate):** Ask for length → ask yes/no for uppercase/digits/symbols → show password + strength → ask to save
- **Option 4 (Save):** Ask for label → ask for content → call `add_entry()`
- **Option 5 (View/Search):** Ask for search keyword (or press Enter to see all) → display results using `print_entry()`
- **Option 6 (Stats):** Call `get_stats()` and display a summary

---

## 🔥 Bonus Challenges (push yourself)

- [ ] Add a **brute-force Caesar decoder** that tries all 26 shifts and shows them all
- [ ] Add **entry deletion** by ID from the vault
- [ ] Add **export feature** that saves vault to a `.txt` report
- [ ] Add a **"guess the shift"** mini game using one of the saved encoded messages
- [ ] Color your terminal output using the `colorama` library

---

## 📋 Skills Checklist

After finishing, tick everything you've used:

- [ ] Variables & data types (str, int, bool, list, dict)
- [ ] String methods (`.lower()`, `.strip()`, `.isalpha()`, f-strings)
- [ ] `for` loops & `while` loops
- [ ] `if / elif / else`
- [ ] Functions with parameters & return values
- [ ] Default argument values
- [ ] List comprehensions
- [ ] `try / except` error handling
- [ ] File I/O (`open`, `read`, `write`)
- [ ] `json` module
- [ ] `os` module
- [ ] `random` & `string` modules
- [ ] `datetime` module
- [ ] Importing from other files (modules)
- [ ] `__name__ == "__main__"` guard
