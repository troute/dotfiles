# CLAUDE.md - Claude Code Guidelines

## General Guidelines

### Commandments

* Always opt for the simplest solution, without compromising on readability, extensibility, and maintainability.
* Do not leave trivial comments which merely restate the code. Reserve comments for scenarios where more context would
be helpful to an engineer working on this section of the code in the future.
* Avoid adding functionality that was not explicity requested.
* Avoid making cosmetic changes to existing code unless explicitly requested.
* Attempt to respect existing abstractions and responsibility boundaries when adding new functionality.
* Avoid "swallowing" exceptions except when explicitly requested.
* Obey KISS, YAGNI, and SOLID principles:
  * KISS: Keep It Simple, Stupid
  * YAGNI: You Aren't Gonna Need it
  * SOLID:
    * S: Single Responsibility Principle - A class should have only one reason to change, meaning it should have only one job or responsibility. This keeps classes focused, understandable, and easier to maintain.
    * O: Open-Closed Principle - Software entities should be open for extension but closed for modification. Add new functionality by extending existing code rather than changing it, which reduces the risk of introducing bugs.
    * L: Liskov Substitution Principle - Objects of a superclass should be replaceable with objects of a subclass without affecting the correctness of the program. Subclasses should extend functionality without changing the expected behavior.
    * I: Interface Segregation Principle - Clients should not be forced to depend on interfaces they don't use. Create specific, focused interfaces rather than one general-purpose interface to prevent implementing unnecessary methods.
    * D: Dependency Inversion Principle - High-level modules should not depend on low-level modules. Both should depend on abstractions. And abstractions should not depend on details; details should depend on abstractions. This enables decoupling and flexibility. 

### Working Style

When I ask you to perform a complex task, please follow the following steps:
1. Ask me clarifying questions to ensure you understand the task correctly. I would rather discuss the task at length
before beginning than need to rectify misunderstandings after finishing implementation.
2. Generate a plan for how you will accomplish the task, focusing on the simplest solution that implements exactly the 
specified requirements. Note which files will be added, modified, or deleted.
3. Ask me to verify that the plan is acceptable, and engage in constructive dialogue with me to iterate on the plan.
4. Only proceed to implementing the plan after I have verified that it is acceptable.

For simple tasks, you can proceed directly to implementation, but please note in your response that you are doing so
precisely because you view the task as simple.

### TODO_AI Comments

It is important to me to be able to track which code is was recently edited using AI, as I like to manually review
in detail all AI code changes in large, infrequent batches. To that end, please leave comments which indicate when
you've modified individual classes, methods, functions, and files.

For example, if you make a modification to the `add` function, you should add comments like the following, providing the
current date:

```python
# TODO_AI: file modified by AI on 2025-04-04

def subtract(a, b):
    return a - b

# TODO_AI: function modified by AI on 2025-04-04
def add(a, b):
    return a + b
```

Always put these in single-line comments, never in docstrings or other multi-line comment constructs.

## Language-Specific Guidelines

### Python

Use Python virtual environments to isolate dependencies:

```bash
python3 -m venv .venv
```

I will often do this myself when setting up a brand new project, so check before attempting to create a new virtual
environment. When using virtual environments, I also configure a `.envrc` to activate the environment automatically:

```bash
# .envrc
source .venv/bin/activate
```

The virtual environment aliases `python`, so use `python` to invoke Python (rather than `python3`, for example).
