# Multiton Pattern in ABAP – Module-Based Logger Example

This repository contains a practical implementation of the **Multiton** pattern in ABAP using a module-based logger as an example.

The objective of this implementation is to ensure that **exactly one logger instance exists per module key**, while still allowing multiple independent loggers to exist across the system.

This is a classic Multiton use case:
one instance per key — not one instance globally.

---

## 📌 Purpose

In real projects, logging is often separated by functional domains such as `SALES`, `FINANCE`, or `HR`. Creating multiple logger objects for the same module can lead to inconsistent state and fragmented logs.

This implementation ensures:

* Controlled instantiation
* One shared logger per module
* Isolated log buffers
* Centralized lifecycle management

A Singleton would be too restrictive.
A simple Factory would not enforce uniqueness.
The Multiton solves exactly this problem.

---

## 🏗️ Design Overview

The class `zul_cl_module_logger` is defined as:

* `CREATE PRIVATE` — prevents external instantiation
* `FINAL` — prevents subclassing
* Static `get_instance( )` method — controlled access point

Internally, the class maintains a static hashed table acting as a registry:

```abap
CLASS-DATA gt_registry TYPE HASHED TABLE ...
```

Conceptually:

```
module → logger reference
```

When `get_instance( iv_module )` is called:

1. The module name is normalized (uppercase)
2. The registry is checked
3. If an instance exists → it is returned
4. If not → a new instance is created and stored
5. The reference is returned

This guarantees **exactly one instance per module key**.

---

## 🧠 Why This Is a Multiton

This implementation:

* Is **not** a Singleton — because multiple instances can exist.
* Is **not** a Factory pattern — because its responsibility is not selecting between subclasses.
* Is a **Multiton** — because it enforces controlled uniqueness per key.

Although the creation logic is implemented via a static factory method (`get_instance`), the core responsibility is uniqueness management, not flexible instantiation.

---

## 📦 Public API

The logger provides the following methods:

* `info( )`
* `warn( )`
* `error( )`

Each method appends a timestamped log entry to the module-specific buffer.

Additional functionality:

* `get_buffer( )` — returns buffered log entries
* `clear_buffer( )` — clears the buffer for the module
* `flush_to_list( )` — demo output to list (replaceable with BAL / SLG1 integration in productive systems)

---

## 🧪 Example Usage

```abap
DATA(lo_sales_logger) = zul_cl_module_logger=>get_instance( 'SALES' ).
DATA(lo_fin_logger)   = zul_cl_module_logger=>get_instance( 'FINANCE' ).

lo_sales_logger->info(  'Order created' ).
lo_fin_logger->error( 'Payment failed' ).
```

Calling `get_instance( 'SALES' )` again will return the same logger object.

---

## 🔍 Typical Use Cases

The Multiton pattern is useful when:

* You need logical separation by key
* Each key must correspond to exactly one shared object
* State must be isolated but centrally managed
* Lifecycle control is required

Common ABAP scenarios include:

* Module-based logging
* Configuration handlers per company code
* Service objects per tenant
* Context-based caching

---

## 📖 Related Blog Post

For a deeper architectural explanation of the Multiton pattern, design intent, naming considerations, and comparison with Singleton and Factory patterns:

👉 **Read the full article on my blog here – https://julialopina.com/factory_multiton**

---

## 📝 Notes

Patterns are not goals by themselves.
The primary objective is always clear structure and maintainable code.

The Multiton pattern here serves as a concise architectural description of how object lifecycle and uniqueness are controlled per module key.
