# CLAUDE.md - Claude Code Guidelines

## About Me

I am a software engineer with a degree in computer science and many years of experience in industry. I am technically
literate and familiar with coding best practices. I am opinionated about high quality code.

## General Guidelines

The following are general guidelines that you should always obey when writing code, unless explicitly directed
otherwise. Whenever possible, please reference these guidelines in your responses. This helps me verify that you are
taking these guidelines into consideration when crafting your solutions.

* ALWAYS opt for the simplest solution which accomplishes the stated goal WITHOUT compromising on readability,
extensibility, and maintainability.
* AVOID leaving trivial comments which merely restate the code. Reserve comments for scenarios where more context would
be helpful to an engineer working on this section of the code in the future.
* NEVER add functionality that was not explicitly requested, or necessary to accomplish explicitly stated goals. AVOID
attempting to anticipate future extensions to explicitly requested functionality, unless explicitly asked to do so.
* AVOID making cosmetic changes to existing code unless explicitly requested.
* ALWAYS attempt to respect existing abstractions and responsibility boundaries when adding new functionality.
* ALWAYS be honest about what is and is not possible. I would prefer to learn early if you think a task is ill-
conceived. Brutal honesty helps avoid wasted time.
* ALWAYS take note of tradeoffs to a particular approach and make sure to align with me before choosing one particular
alternative, for instance the choice of one library over another.
* Obey DRY, KISS, YAGNI, and SOLID principles:
  * DRY: Don't Repeat Yourself - Every piece of knowledge or logic should have a single, unambiguous representation in the codebase. Avoid duplication by extracting shared functionality into reusable functions, classes, or modules.
  * KISS: Keep It Simple, Stupid
  * YAGNI: You Aren't Gonna Need it
  * SOLID:
    * S: Single Responsibility Principle - A class should have only one reason to change, meaning it should have only one job or responsibility. This keeps classes focused, understandable, and easier to maintain.
    * O: Open-Closed Principle - Software entities should be open for extension but closed for modification. Add new functionality by extending existing code rather than changing it, which reduces the risk of introducing bugs.
    * L: Liskov Substitution Principle - Objects of a superclass should be replaceable with objects of a subclass without affecting the correctness of the program. Subclasses should extend functionality without changing the expected behavior.
    * I: Interface Segregation Principle - Clients should not be forced to depend on interfaces they don't use. Create specific, focused interfaces rather than one general-purpose interface to prevent implementing unnecessary methods.
    * D: Dependency Inversion Principle - High-level modules should not depend on low-level modules. Both should depend on abstractions. And abstractions should not depend on details; details should depend on abstractions. This enables decoupling and flexibility. 

## Working Style

The following are specific guidelines for how we will work together. They apply to almost all tasks I will ask you to
perform (except the very simplest, most rote tasks). Please reference these guidelines in your responses.

### Typical Workflow

Effectively solving complex tasks requires careful planning. Whenever I ask you to perform a complex task (generally,
I define "complex task" as any task that requires modifying multiple functions, classes, or files), ALWAYS follow
the following steps:

1. Restate your understanding of the request.
2. Ask clarifying questions to further flesh out your understanding. Ask as many rounds of questions as are necessary;
I would rather discuss the task at length before beginning than need to rectify misunderstandings during implementation.
3. Generate a plan for how you will accomplish the task, focusing on the simplest solution that implements exactly the 
specified requirements. Note which files, classes, and functions will be added, modified, or deleted.
4. Ask me to verify that the plan is acceptable, and engage in constructive dialogue with me to iterate on the plan.
5. ONLY proceed to implementation after we have reached agreement on the plan.

For simple tasks, you can proceed directly to implementation, but ALWAYS note in your response that you are doing so
precisely because you view the task as comparatively simple.

## Language-Specific Guidelines

### Python

Use Python virtual environments to isolate dependencies. Most projects already have a `.venv` directory (95% of cases), which is gitignored and not visible in file listings.

**Check if .venv exists before creating:**

```bash
# Only create if .venv doesn't exist
python3 -m venv .venv
```

I will often do this myself when setting up a brand new project, so check before attempting to create a new virtual environment. When using virtual environments, I also configure a `.envrc` to activate the environment automatically:

```bash
# .envrc
source .venv/bin/activate
```

The virtual environment aliases `python`, so use `python` to invoke Python (rather than `python3`, for example). See `TERMINAL_USE.md` for detailed venv usage patterns and common pitfalls.

## Compacting Guidelines

When compacting, always attempt to maintain a history of ALL user messages in the current session. It is important to me
that you remember all the guidance I give you during a given session, as I often say things like "we may modify this later",
and I want those thoughts to persist in a simple format (e.g. maintaining all my messages) throughout the session.

## Style Guide Format

The language-specific style guides (Python, TypeScript) follow a consistent format for each coding practice:

### {Coding Practice Name, 1 sentence or less, no period}

{Description of coding practice, 1-3 sentences.}

#### Do

```
code_example  # with optional explanatory comments
```

#### Don't

```
code_example  # with optional explanatory comments
```

{Optional} Note: {Any further important notes, 1-3 sentences.}

## Maintaining These Guides

As we work together, if you notice regular departures from the style guides, or if we encounter a style question which is absent from the guides, ask me to clarify the point and add or update a section as appropriate.

## Language-Specific Style and Best Practices Guides

This file (CLAUDE.md) contains universal guidelines that apply to all projects and languages. For language-specific details, consult:

- **STYLE_PYTHON.md** - Python code style, FastAPI patterns, SQLModel, Pydantic
- **STYLE_TYPESCRIPT.md** - TypeScript, React, state management, UI components
- **TERMINAL_USE.md** - Command patterns, Git workflow, tool usage

**Priority order when writing code:**
1. Start with CLAUDE.md for general principles (DRY, KISS, YAGNI, SOLID) and workflow
2. Consult language-specific guide for syntax, patterns, and architecture
3. Check TERMINAL_USE.md for command execution and Git conventions

@~/.claude/STYLE_PYTHON.md
@~/.claude/STYLE_TYPESCRIPT.md
@~/.claude/TERMINAL_USE.md
