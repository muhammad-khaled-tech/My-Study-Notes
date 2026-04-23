# 🚗 Project 2 — PyFleet
### A Vehicle Rental Management System (Full OOP)

---

## 🧠 What You're Building

A terminal app for managing a vehicle rental company:
- Add vehicles (Cars, Motorcycles, Vans) to a fleet
- Register customers
- Create and return rentals with automatic bill calculation
- Track availability, rental history, and revenue
- Generate reports

This project is designed to make you **think in objects** — every real-world thing becomes a class.

---

## 🗺️ OOP Concepts Map

| Concept | Where You'll Use It |
|---|---|
| Classes & `__init__` | `Vehicle`, `Customer`, `Rental`, `Fleet` |
| `__str__` & `__repr__` | Every class (clean display) |
| Inheritance | `Car`, `Motorcycle`, `Van` all extend `Vehicle` |
| Method overriding | Each vehicle type overrides `calculate_rate()` |
| Encapsulation | `_mileage`, `__revenue` — private/protected attrs |
| Properties (`@property`) | `Vehicle.is_available`, `Rental.duration_days` |
| Class methods | `Customer.from_dict()`, `Vehicle.from_dict()` |
| Static methods | `Report.format_currency()`, `Report.divider()` |
| Composition | `Rental` contains a `Vehicle` and a `Customer` |
| `@dataclass` (bonus) | Optional refactor of `Customer` |
| Dunder methods | `__len__` on `Fleet`, `__eq__` on `Vehicle` |
| File I/O + JSON | `Fleet.save()` / `Fleet.load()` |

---

## 📁 Project Structure

```
pyfleet/
│
├── main.py              ← entry point, main menu
├── models/
│   ├── __init__.py      ← makes models a package
│   ├── vehicle.py       ← Vehicle base class + Car/Motorcycle/Van
│   ├── customer.py      ← Customer class
│   └── rental.py        ← Rental class
├── services/
│   ├── __init__.py
│   ├── fleet.py         ← Fleet manager class
│   └── report.py        ← Report class (static methods)
└── data/
    ├── vehicles.json    ← auto-created
    └── rentals.json     ← auto-created
```

---

## 🏗️ Phase 1 — The Base Class: `Vehicle`
**Goal:** Design the parent class. Every vehicle shares these traits.

```python
# models/vehicle.py

class Vehicle:
    """
    Base class for all vehicle types.
    Stores shared attributes and defines the interface every subclass must follow.
    """
    
    def __init__(self, vehicle_id, brand, model, year, daily_rate):
        self.vehicle_id = vehicle_id
        self.brand = brand
        self.model = model
        self.year = year
        self.daily_rate = daily_rate      # Base rate — subclasses may adjust this
        self._is_available = True          # Protected: use the property below
        self._rental_count = 0             # How many times this vehicle was rented
    
    # ── Properties ────────────────────────────────────────
    
    @property
    def is_available(self):
        return self._is_available
    
    @is_available.setter
    def is_available(self, value):
        if not isinstance(value, bool):
            raise TypeError("is_available must be True or False")
        self._is_available = value
    
    @property
    def rental_count(self):
        return self._rental_count  # Read-only — only Fleet can increment this
    
    # ── Methods ───────────────────────────────────────────
    
    def calculate_rate(self, days):
        """
        Returns total rental cost for 'days'.
        Subclasses can override this to add their own pricing rules.
        """
        return self.daily_rate * days
    
    def mark_rented(self):
        self._is_available = False
        self._rental_count += 1
    
    def mark_returned(self):
        self._is_available = True
    
    def to_dict(self):
        """Serializes this vehicle to a dict (for JSON saving)."""
        return {
            "vehicle_id": self.vehicle_id,
            "type": self.__class__.__name__,   # "Car", "Van", etc.
            "brand": self.brand,
            "model": self.model,
            "year": self.year,
            "daily_rate": self.daily_rate,
            "is_available": self._is_available,
            "rental_count": self._rental_count,
        }
    
    def __str__(self):
        status = "✅ Available" if self._is_available else "🔴 Rented"
        return f"[{self.vehicle_id}] {self.year} {self.brand} {self.model} — {status}"
    
    def __repr__(self):
        return f"Vehicle(id={self.vehicle_id!r}, brand={self.brand!r})"
    
    def __eq__(self, other):
        if isinstance(other, Vehicle):
            return self.vehicle_id == other.vehicle_id
        return False
```

> ✅ **Checkpoint:** Create a `Vehicle` object in a Python shell and print it. Check that `is_available` setter rejects non-bool values.

---

## 🏗️ Phase 2 — Subclasses (Inheritance + Override)
**Goal:** Create three vehicle types that each have their own pricing logic.

```python
# Still in models/vehicle.py — add below the Vehicle class

class Car(Vehicle):
    """Standard car. Adds insurance_class that affects pricing."""
    
    INSURANCE_MULTIPLIERS = {"basic": 1.0, "standard": 1.15, "premium": 1.30}
    
    def __init__(self, vehicle_id, brand, model, year, daily_rate,
                 num_seats=5, insurance_class="standard"):
        super().__init__(vehicle_id, brand, model, year, daily_rate)
        self.num_seats = num_seats
        self.insurance_class = insurance_class
    
    def calculate_rate(self, days):
        """Cars apply an insurance multiplier on top of the base rate."""
        multiplier = self.INSURANCE_MULTIPLIERS.get(self.insurance_class, 1.0)
        return self.daily_rate * days * multiplier
    
    def to_dict(self):
        data = super().to_dict()
        data["num_seats"] = self.num_seats
        data["insurance_class"] = self.insurance_class
        return data
    
    def __str__(self):
        return super().__str__() + f" | 🚗 Car | {self.num_seats} seats | {self.insurance_class} insurance"


class Motorcycle(Vehicle):
    """Motorcycles are cheaper but add a surcharge for drivers under 25."""
    
    def __init__(self, vehicle_id, brand, model, year, daily_rate, engine_cc=600):
        super().__init__(vehicle_id, brand, model, year, daily_rate)
        self.engine_cc = engine_cc
    
    def calculate_rate(self, days, driver_age=25):
        """Young driver surcharge: +20% if driver is under 25."""
        total = self.daily_rate * days
        if driver_age < 25:
            total *= 1.20
        return total
    
    def to_dict(self):
        data = super().to_dict()
        data["engine_cc"] = self.engine_cc
        return data
    
    def __str__(self):
        return super().__str__() + f" | 🏍️ Motorcycle | {self.engine_cc}cc"


class Van(Vehicle):
    """Vans charge more for cargo load and get a discount on long rentals."""
    
    def __init__(self, vehicle_id, brand, model, year, daily_rate,
                 cargo_capacity_kg=500):
        super().__init__(vehicle_id, brand, model, year, daily_rate)
        self.cargo_capacity_kg = cargo_capacity_kg
    
    def calculate_rate(self, days):
        """7+ days gets a 10% discount."""
        total = self.daily_rate * days
        if days >= 7:
            total *= 0.90
        return total
    
    def to_dict(self):
        data = super().to_dict()
        data["cargo_capacity_kg"] = self.cargo_capacity_kg
        return data
    
    def __str__(self):
        return super().__str__() + f" | 🚐 Van | {self.cargo_capacity_kg}kg capacity"
```

> ✅ **Checkpoint:** Create one of each type and call `calculate_rate(5)`. Verify that pricing rules apply correctly.

---

## 🏗️ Phase 3 — Customer Class
**Goal:** Model a customer with a rental history.

```python
# models/customer.py

class Customer:
    
    def __init__(self, customer_id, name, email, age, license_number):
        self.customer_id = customer_id
        self.name = name
        self.email = email
        self.age = age
        self.license_number = license_number
        self._rental_ids = []        # List of rental IDs this customer has
    
    def add_rental(self, rental_id):
        self._rental_ids.append(rental_id)
    
    @property
    def total_rentals(self):
        return len(self._rental_ids)
    
    @property
    def rental_ids(self):
        return list(self._rental_ids)   # Return a copy, not the real list
    
    @classmethod
    def from_dict(cls, data):
        """
        Alternative constructor — creates a Customer from a dict.
        Useful when loading from JSON.
        
        Usage: customer = Customer.from_dict({"name": "Ali", ...})
        """
        c = cls(
            customer_id=data["customer_id"],
            name=data["name"],
            email=data["email"],
            age=data["age"],
            license_number=data["license_number"],
        )
        c._rental_ids = data.get("rental_ids", [])
        return c
    
    def to_dict(self):
        return {
            "customer_id": self.customer_id,
            "name": self.name,
            "email": self.email,
            "age": self.age,
            "license_number": self.license_number,
            "rental_ids": self._rental_ids,
        }
    
    def __str__(self):
        return f"[{self.customer_id}] {self.name} | 📧 {self.email} | 🚗 {self.total_rentals} rental(s)"
    
    def __repr__(self):
        return f"Customer(id={self.customer_id!r}, name={self.name!r})"
```

> ✅ **Checkpoint:** Create a customer, add 2 rental IDs manually, check `total_rentals`. Then call `to_dict()` and `Customer.from_dict()` on the result — you should get back an identical object.

---

## 🏗️ Phase 4 — Rental Class (Composition)
**Goal:** A Rental is composed of a Vehicle + a Customer + time info.

```python
# models/rental.py

from datetime import date, datetime


class Rental:
    """
    Represents a single rental transaction.
    Composition: holds a reference to a Vehicle and a Customer object.
    """
    
    def __init__(self, rental_id, vehicle, customer, start_date, end_date):
        self.rental_id = rental_id
        self.vehicle = vehicle          # A Vehicle object (composition)
        self.customer = customer        # A Customer object (composition)
        self.start_date = start_date    # date object
        self.end_date = end_date        # date object
        self._is_active = True
        self._total_cost = None         # Calculated on return
    
    @property
    def duration_days(self):
        delta = self.end_date - self.start_date
        return max(delta.days, 1)       # Minimum 1 day charge
    
    @property
    def is_active(self):
        return self._is_active
    
    def close_rental(self):
        """Called when the customer returns the vehicle."""
        self._is_active = False
        self._total_cost = self.vehicle.calculate_rate(self.duration_days)
        self.vehicle.mark_returned()
        return self._total_cost
    
    @property
    def total_cost(self):
        if self._total_cost is None:
            # Estimate cost if still active
            return self.vehicle.calculate_rate(self.duration_days)
        return self._total_cost
    
    def to_dict(self):
        return {
            "rental_id": self.rental_id,
            "vehicle_id": self.vehicle.vehicle_id,
            "customer_id": self.customer.customer_id,
            "start_date": self.start_date.isoformat(),
            "end_date": self.end_date.isoformat(),
            "is_active": self._is_active,
            "total_cost": self._total_cost,
        }
    
    def __str__(self):
        status = "🟢 Active" if self._is_active else "✅ Closed"
        return (
            f"Rental #{self.rental_id} | {status}\n"
            f"  Vehicle : {self.vehicle}\n"
            f"  Customer: {self.customer.name}\n"
            f"  Period  : {self.start_date} → {self.end_date} ({self.duration_days} days)\n"
            f"  Cost    : ${self.total_cost:.2f}"
        )
```

> ✅ **Checkpoint:** Create a `Rental` with 5-day duration. Check `duration_days` and `total_cost`. Then call `close_rental()` and verify the vehicle becomes available again.

---

## 🏗️ Phase 5 — Fleet Class (The Manager)
**Goal:** The `Fleet` class manages all vehicles, customers, and rentals.

```python
# services/fleet.py

import json
import os
from datetime import date

# Note: we'll add the import for Vehicle subclasses after they're all defined
from models.vehicle import Vehicle, Car, Motorcycle, Van
from models.customer import Customer
from models.rental import Rental


class Fleet:
    """
    Central manager class — the heart of the application.
    Uses composition (contains lists of other objects).
    """
    
    VEHICLES_FILE = "data/vehicles.json"
    RENTALS_FILE = "data/rentals.json"
    
    def __init__(self):
        self._vehicles = {}    # {vehicle_id: Vehicle}
        self._customers = {}   # {customer_id: Customer}
        self._rentals = {}     # {rental_id: Rental}
        self._next_rental_id = 1
    
    # ── Vehicle Management ────────────────────────────────
    
    def add_vehicle(self, vehicle):
        if vehicle.vehicle_id in self._vehicles:
            raise ValueError(f"Vehicle {vehicle.vehicle_id} already exists.")
        self._vehicles[vehicle.vehicle_id] = vehicle
        print(f"✅ Added: {vehicle}")
    
    def get_vehicle(self, vehicle_id):
        vehicle = self._vehicles.get(vehicle_id)
        if not vehicle:
            raise KeyError(f"No vehicle found with ID: {vehicle_id}")
        return vehicle
    
    def list_available(self):
        return [v for v in self._vehicles.values() if v.is_available]
    
    def list_all_vehicles(self):
        return list(self._vehicles.values())
    
    # ── Customer Management ───────────────────────────────
    
    def register_customer(self, customer):
        if customer.customer_id in self._customers:
            raise ValueError(f"Customer {customer.customer_id} already registered.")
        self._customers[customer.customer_id] = customer
        print(f"✅ Registered: {customer}")
    
    def get_customer(self, customer_id):
        customer = self._customers.get(customer_id)
        if not customer:
            raise KeyError(f"No customer found with ID: {customer_id}")
        return customer
    
    # ── Rental Management ─────────────────────────────────
    
    def create_rental(self, vehicle_id, customer_id, start_date, end_date):
        vehicle = self.get_vehicle(vehicle_id)
        customer = self.get_customer(customer_id)
        
        if not vehicle.is_available:
            raise RuntimeError(f"Vehicle {vehicle_id} is not available.")
        
        rental_id = f"R{self._next_rental_id:04d}"
        self._next_rental_id += 1
        
        rental = Rental(rental_id, vehicle, customer, start_date, end_date)
        vehicle.mark_rented()
        customer.add_rental(rental_id)
        
        self._rentals[rental_id] = rental
        print(f"✅ Rental created:\n{rental}")
        return rental
    
    def return_vehicle(self, rental_id):
        rental = self._rentals.get(rental_id)
        if not rental:
            raise KeyError(f"Rental {rental_id} not found.")
        if not rental.is_active:
            raise RuntimeError(f"Rental {rental_id} is already closed.")
        
        total = rental.close_rental()
        print(f"✅ Vehicle returned. Total charge: ${total:.2f}")
        return total
    
    # ── Dunder Methods ────────────────────────────────────
    
    def __len__(self):
        """len(fleet) returns number of vehicles in the fleet."""
        return len(self._vehicles)
    
    def __contains__(self, vehicle_id):
        """'V001' in fleet → True/False"""
        return vehicle_id in self._vehicles
    
    # ── Persistence (Save / Load) ─────────────────────────
    
    def save(self):
        os.makedirs("data", exist_ok=True)
        
        vehicles_data = [v.to_dict() for v in self._vehicles.values()]
        with open(self.VEHICLES_FILE, "w") as f:
            json.dump(vehicles_data, f, indent=2)
        
        rentals_data = [r.to_dict() for r in self._rentals.values()]
        with open(self.RENTALS_FILE, "w") as f:
            json.dump(rentals_data, f, indent=2)
        
        print("💾 Fleet data saved.")
    
    def load(self):
        """Rebuilds the fleet from saved JSON files."""
        type_map = {"Car": Car, "Motorcycle": Motorcycle, "Van": Van}
        
        if os.path.exists(self.VEHICLES_FILE):
            with open(self.VEHICLES_FILE) as f:
                for data in json.load(f):
                    cls = type_map.get(data["type"], Vehicle)
                    # Simplified: load as base Vehicle for now
                    v = Vehicle(
                        data["vehicle_id"], data["brand"],
                        data["model"], data["year"], data["daily_rate"]
                    )
                    v._is_available = data["is_available"]
                    v._rental_count = data["rental_count"]
                    self._vehicles[v.vehicle_id] = v
        
        print(f"📂 Loaded {len(self._vehicles)} vehicle(s).")
```

> ✅ **Checkpoint:** Create a Fleet, add 3 vehicles, create a rental, then call `save()`. Check the JSON files. Then create a new Fleet object and call `load()` — your vehicles should be back.

---

## 🏗️ Phase 6 — Report Class (Static Methods)
**Goal:** A utility class that generates analytics — no instance state needed.

```python
# services/report.py

class Report:
    """
    Generates summaries and analytics from fleet data.
    All methods are static — this class is a collection of utilities, not a stateful object.
    """
    
    @staticmethod
    def divider(char="═", length=45):
        return char * length
    
    @staticmethod
    def format_currency(amount):
        return f"${amount:,.2f}"
    
    @staticmethod
    def fleet_summary(fleet):
        vehicles = fleet.list_all_vehicles()
        available = fleet.list_available()
        rented = [v for v in vehicles if not v.is_available]
        
        print(Report.divider())
        print("          📊 FLEET SUMMARY REPORT")
        print(Report.divider())
        print(f"  Total Vehicles   : {len(vehicles)}")
        print(f"  Available        : {len(available)}")
        print(f"  Currently Rented : {len(rented)}")
        print(Report.divider())
        
        # Vehicle type breakdown
        type_counts = {}
        for v in vehicles:
            vtype = type(v).__name__
            type_counts[vtype] = type_counts.get(vtype, 0) + 1
        
        print("  Breakdown by Type:")
        for vtype, count in type_counts.items():
            print(f"    {vtype:15s}: {count}")
        
        print(Report.divider())
    
    @staticmethod
    def revenue_report(fleet):
        """Shows total revenue from all closed rentals."""
        rentals = fleet._rentals.values()
        closed = [r for r in rentals if not r.is_active]
        
        total_revenue = sum(r.total_cost for r in closed)
        
        print(Report.divider())
        print("          💰 REVENUE REPORT")
        print(Report.divider())
        print(f"  Completed Rentals: {len(closed)}")
        print(f"  Total Revenue    : {Report.format_currency(total_revenue)}")
        
        if closed:
            avg = total_revenue / len(closed)
            print(f"  Avg per Rental   : {Report.format_currency(avg)}")
        
        print(Report.divider())
    
    @staticmethod
    def most_rented(fleet):
        """Finds the vehicle with the highest rental count."""
        vehicles = fleet.list_all_vehicles()
        if not vehicles:
            print("No vehicles in fleet.")
            return
        
        top = max(vehicles, key=lambda v: v.rental_count)
        print(f"🏆 Most Rented: {top} — {top.rental_count} rental(s)")
```

---

## 🏗️ Phase 7 — Wire Everything in main.py

Your main menu should offer:

```
══════════════════════════════
       🚗 PyFleet Manager
══════════════════════════════
1. Add Vehicle
2. List Vehicles (all / available)
3. Register Customer
4. Create Rental
5. Return Vehicle
6. View Rental Details
7. Fleet Summary Report
8. Revenue Report
9. Save & Exit
══════════════════════════════
```

Each menu option calls the appropriate `Fleet` or `Report` method. Use `try/except` to catch `ValueError`, `KeyError`, and `RuntimeError` so bad input never crashes the app.

---

## 🔥 Bonus Challenges

- [ ] Add `__iter__` to `Fleet` so you can do `for vehicle in fleet:`
- [ ] Add a `Coupon` class with `apply(rental)` method — flat discount or percentage
- [ ] Add `@classmethod from_dict()` to `Car`, `Motorcycle`, `Van` for proper JSON reloading
- [ ] Add a `Waitlist` feature: if a vehicle is rented, customers can queue for it
- [ ] Write a `search_vehicles(brand=None, max_rate=None, type=None)` method on `Fleet` using `filter()` + `lambda`
- [ ] Use `@dataclass` decorator to refactor `Customer`

---

## 🧪 OOP Concepts Checklist

After finishing, make sure you can explain each of these:

- [ ] Why `__init__` is not a constructor (it's an initializer)
- [ ] Difference between `_protected` and `__private` attributes
- [ ] Why we returned a copy in `Customer.rental_ids` property
- [ ] How `super().__init__()` works in `Car.__init__`
- [ ] Why `Report` uses static methods instead of instance methods
- [ ] What `__len__` and `__contains__` do (dunder/magic methods)
- [ ] Difference between **inheritance** (`Car` is a `Vehicle`) and **composition** (`Rental` has a `Vehicle`)
- [ ] When to use `@classmethod` vs `@staticmethod` vs regular method
- [ ] Why `to_dict()` + `from_dict()` is a common serialization pattern
