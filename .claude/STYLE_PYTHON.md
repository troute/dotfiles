# Style Guide

## TODO

Ensure ruff/formatter configurations in my projects match this guide.

## Auto-Formatting vs. Manual Conventions

**Ruff Auto-Formats (don't manually enforce these):**
- Line length and wrapping
- Trailing commas
- Whitespace around operators
- Blank lines between definitions
- Quote normalization (single quotes)
- Indentation (4 spaces)

**Manual Conventions (follow when writing code):**
- Type hints on all functions
- Absolute imports over relative
- EAFP error handling style
- Naming conventions (snake_case, PascalCase, UPPER_SNAKE_CASE)
- Design patterns (context managers, dependency injection, async/await)
- Project structure and separation of concerns

All rules are documented below for completeness, but trust Ruff for formatting details.

## Quick Reference

**Most Important Rules:**
- Always use type hints
- Prefer single quotes (double to avoid escaping)
- Always use absolute imports
- Use `|` for unions (Python 3.10+)
- Prefer EAFP over LBYL
- Always use context managers
- Never use mutable defaults
- Include units in variable names

**FastAPI Patterns:**
- Project structure and separation of concerns
- Dependency injection for resource management
- Use HTTPException for API errors
- Use appropriate HTTP status codes

**Database:**
- SQLModel models with separation of concerns
- Pydantic Settings with environment files
- Soft deletion for data preservation

## Purpose

This document is a comprehensive, up-to-date representation of my preferences for Python code style and best practices. See CLAUDE.md for general guidelines that apply across all languages.

## Related Guides

- **CLAUDE.md** - General coding guidelines, workflow, and principles (DRY, KISS, YAGNI, SOLID)
- **TERMINAL_USE.md** - Terminal commands, Git conventions, and tool usage
- **STYLE_TYPESCRIPT.md** - TypeScript/React guidelines

Note: Entry format and maintenance guidelines are defined in CLAUDE.md.

## Style Conventions

### Use 120 character maximum line length

Allow up to 120 characters per line for code, providing more room for complex expressions and inline comments while still maintaining readability on modern displays.

#### Do

```python
def calculate_compound_interest(principal, rate, time, frequency):
    return principal * (1 + rate / frequency) ** (frequency * time)  # More room for inline comments
```

#### Don't

```python
def calculate_compound_interest(
    principal, rate, time, frequency
):  # Unnecessarily broken up for narrow limit
    return principal * (1 + rate / frequency) ** (
        frequency * time
    )
```

Note: This limit applies to code; docstrings and comments may still benefit from shorter line lengths (80) for readability.

---

### Always use type hints

Type all function signatures, class attributes, and variables where the type is not immediately obvious from the assignment, ensuring code is self-documenting and enabling better IDE support and static analysis.

#### Do

```python
from typing import Any

def process_user_data(user_id: int, name: str, active: bool = True) -> dict[str, Any]:
    result: dict[str, Any] = {"id": user_id, "name": name, "active": active}
    return result
```

#### Don't

```python
def process_user_data(user_id, name, active=True):
    result = {"id": user_id, "name": name, "active": active}
    return result
```

---

### Always use absolute imports

Use absolute imports even within the same package to ensure clarity about module locations and avoid confusion about import sources.

#### Do

```python
from mypackage.subpackage.module_b import helper_function
from mypackage.utils import validate
```

#### Don't

```python
from .module_b import helper_function  # Relative import
from ..utils import validate  # Relative import
```

---

### Allow star imports only in `__init__.py` files

Star imports (`from module import *`) should be avoided in regular code but are permitted in `__init__.py` files for re-exporting package-level APIs, making it easier for users to import from the top-level package.

#### Do

```python
# mypackage/__init__.py
from .user_operations import *
from .data_processing import *

# Regular module files - use explicit imports
from mypackage.utilities import validate_input, format_output
```

#### Don't

```python
# mypackage/foobar.py
from mypackage.utilities import *  # Avoid in non-__init__ files
```

Note: Even in `__init__.py`, explicit imports are cleaner and can be preferred when the API surface is small or clear. This guideline may be revisited.

---

### Prefer single quotes, use double to avoid escaping

Use single quotes for strings by default, but switch to double quotes when the string contains single quotes to avoid escaping and improve readability.

#### Do

```python
name = 'Alice'
greeting = 'Hello, world!'
message = "It's a beautiful day"  # Double quotes avoid escaping apostrophe
quote = 'She said, "Hello!"'  # Single quotes avoid escaping double quotes
```

#### Don't

```python
name = "Alice"  # Unnecessary double quotes
message = 'It\'s a beautiful day'  # Escaped apostrophe when double quotes would be cleaner
```

---

### Use single underscore for private/internal members

Prefix methods, functions, and attributes that are internal implementation details with a single underscore to indicate they are not part of the public API. Avoid double underscores unless intentionally using name mangling.

#### Do

```python
class DataProcessor:
    def process(self, data: list) -> list:  # Public API
        return self._normalize(data)

    def _normalize(self, data: list) -> list:  # Internal helper
        return [self._clean_item(x) for x in data]

    def _clean_item(self, item: Any) -> Any:  # Internal helper
        return str(item).strip()
```

#### Don't

```python
class DataProcessor:
    def process(self, data: list) -> list:
        return self.__normalize(data)  # Double underscore triggers name mangling

    def __normalize(self, data: list) -> list:  # Avoid unless intentional
        return data
```

Note: Double underscore (`__name`) triggers Python's name mangling and should only be used when you specifically need that behavior to avoid name conflicts in inheritance hierarchies.

---

### Use PEP 8 naming conventions

Follow PEP 8 casing conventions for all identifiers to maintain consistency with the broader Python ecosystem.

#### Do

```python
# Constants: UPPER_SNAKE_CASE
MAX_CONNECTIONS = 100
DEFAULT_TIMEOUT_MS = 5000

# Variables: snake_case
user_name = 'Alice'

# Classes: PascalCase
class UserAccount:
    def calculate_balance(self) -> float:  # Methods/functions: snake_case
        return self._current_balance  # Private attributes: _snake_case

# Related constants: Use Enum classes (PascalCase) with UPPER_SNAKE_CASE members
from enum import Enum

class ReportType(str, Enum):
    TRAILING_TWELVE = "TRAILING_TWELVE"
    GENERAL_LEDGER = "GENERAL_LEDGER"
    RENT_ROLL = "RENT_ROLL"
```

Note: Use UPPER_SNAKE_CASE for standalone constants. For related constant groups, use Enum classes with PascalCase names and UPPER_SNAKE_CASE members.

---

### Include units in variable names

When a variable represents a measurement with specific units, include the unit in the variable name to make the expected unit explicit and prevent confusion.

#### Do

```python
timeout_ms = 5000  # Clear that this is milliseconds
duration_seconds = 30
file_size_bytes = 1024
temperature_celsius = 25.0
```

#### Don't

```python
timeout = 5000  # Unclear if this is ms, seconds, or minutes
duration = 30  # What unit?
file_size = 1024  # Bytes? KB? MB?
temperature = 25.0  # Celsius? Fahrenheit? Kelvin?
```

---

### Group imports by type and sort alphabetically

Organize imports into three groups separated by blank lines: standard library, third-party packages, and local application imports. Sort imports alphabetically within each group.

#### Do

```python
import os
import sys
from pathlib import Path

import numpy as np
import requests

from myapp.models import User
from myapp.utils import validate
```

#### Don't

```python
import requests
from myapp.models import User
import os
from myapp.utils import validate
import numpy as np
```

---

### Always use trailing commas in multi-line constructs

Include a trailing comma after the last item in multi-line lists, tuples, dictionaries, function arguments, and function parameters. This makes diffs cleaner and prevents errors when adding new items.

#### Do

```python
items = [
    'apple',
    'banana',
    'cherry',
]

def process_data(
    name: str,
    age: int,
    active: bool = True,
) -> dict:
    return {'name': name, 'age': age}
```

#### Don't

```python
items = [
    'apple',
    'banana',
    'cherry'
]

def process_data(
    name: str,
    age: int,
    active: bool = True
) -> dict:
    return {'name': name, 'age': age}
```

---

### Use two blank lines between top-level definitions, one between methods

Follow PEP 8 conventions for blank lines: use two blank lines to separate top-level function and class definitions, and one blank line between method definitions within a class.

#### Do

```python
def first_function():
    pass


def second_function():
    pass


class MyClass:
    def first_method(self):
        pass

    def second_method(self):
        pass
```

---

### No whitespace immediately inside brackets, parentheses, or braces

Avoid extra spaces immediately inside brackets, parentheses, or braces to maintain clean, readable expressions.

#### Do

```python
spam(ham[1], {eggs: 2})
result = calculate_value(items[0], {'key': 'value'})
```

#### Don't

```python
spam( ham[ 1 ], { eggs: 2 } )
result = calculate_value( items[ 0 ], { 'key': 'value' } )
```

---

### Use single space around assignment and comparison operators

Place one space on each side of assignment, comparison, and boolean operators for readability.

#### Do

```python
x = 1
y = 2
if x == y:
    z = x + y
```

#### Don't

```python
x=1
y=2
if x==y:
    z=x+y
```

---

### Break before binary operators

When breaking long expressions across lines, place the line break before binary operators rather than after them.

#### Do

```python
total = (
    first_value
    + second_value
    - third_value
)
```

#### Don't

```python
total = (
    first_value +
    second_value -
    third_value
)
```

---

### Use 4 spaces for indentation

Use 4 spaces per indentation level. Never use tabs or mix tabs and spaces.

#### Do

```python
def example():
    if True:
        print('properly indented')
```

---

### Use f-strings for string formatting

Prefer f-strings (formatted string literals) for string interpolation as they are more readable and performant than older formatting methods.

#### Do

```python
name = 'Alice'
age = 30
message = f'Hello {name}, you are {age} years old'
formatted = f'{value:.2f}'  # With formatting specifiers
```

#### Don't

```python
message = 'Hello {}, you are {} years old'.format(name, age)  # str.format()
message = 'Hello %s, you are %d years old' % (name, age)  # %-formatting
```

---

## Best Practices and Conventions

### Prefer EAFP over LBYL for error handling

Use "Easier to Ask Forgiveness than Permission" (EAFP) style with try/except blocks rather than "Look Before You Leap" (LBYL) style with pre-checks. EAFP is more Pythonic and handles race conditions better.

#### Do

```python
# EAFP - Try the operation and handle failures
try:
    value = my_dict[key]
except KeyError:
    value = default_value

try:
    with open('config.txt') as f:
        data = f.read()
except FileNotFoundError:
    data = default_config
```

#### Don't

```python
# LBYL - Check before attempting
if key in my_dict:
    value = my_dict[key]
else:
    value = default_value

if os.path.exists('config.txt'):
    with open('config.txt') as f:
        data = f.read()
else:
    data = default_config
```

---

### Never use mutable default arguments

Never use mutable objects (lists, dicts, sets) as default arguments. Mutable defaults are evaluated once at function definition and persist across all calls, causing unexpected behavior. Always use `None` and initialize inside the function.

#### Do

```python
def append_to_list(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items

def process_data(data: dict, config: dict | None = None) -> dict:
    if config is None:
        config = {}
    return {**data, **config}
```

#### Don't

```python
def append_to_list(item: str, items: list[str] = []) -> list[str]:  # BAD!
    items.append(item)
    return items  # Same list persists across all calls

def process_data(data: dict, config: dict = {}) -> dict:  # BAD!
    return {**data, **config}
```

---

### Always use context managers for resource management

Use context managers (`with` statements) for all resource management including files, database connections, locks, and network connections. This ensures resources are properly released even if exceptions occur.

#### Do

```python
# Files
with open('data.txt', 'r') as f:
    data = f.read()  # File automatically closed

# Database connections
with database.connection() as conn:
    conn.execute(query)  # Connection automatically closed/committed

# Custom context manager
from contextlib import contextmanager

@contextmanager
def temporary_directory():
    temp_dir = create_temp_dir()
    try:
        yield temp_dir
    finally:
        cleanup_temp_dir(temp_dir)
```

#### Don't

```python
# Manual resource management
f = open('data.txt', 'r')
try:
    data = f.read()
finally:
    f.close()  # Easy to forget or get wrong
```

---

### Use type unions with `|` operator (Python 3.10+)

Modern Python (3.10+) supports union types using the `|` operator. This is preferred over the legacy `Optional[]` and `Union[]` syntax for cleaner, more readable type hints.

#### Do

```python
# Union types (Python 3.10+)
def process_data(value: int | str) -> list[int] | None:
    if isinstance(value, int):
        return [value]
    return None

# Optional types (Python 3.10+)
def get_user(user_id: int) -> User | None:
    return db.query(User).filter(User.id == user_id).first()

# Optional parameters with default None
def search(query: str, limit: int | None = None) -> list[Result]:
    results = db.query(Result).filter(Result.name.contains(query))
    if limit:
        results = results.limit(limit)
    return results.all()
```

#### Don't

```python
# Legacy Optional syntax
from typing import Optional, Union

def process_data(value: Union[int, str]) -> Optional[list[int]]:
    pass

def get_user(user_id: int) -> Optional[User]:
    pass
```

Note: The `|` operator for unions is available in Python 3.10+. For Python 3.9 and earlier, use `Optional[]` and `Union[]`.

---

### Use async/await for all I/O operations

Use async/await for all operations that involve I/O (network requests, file operations, database queries). This improves performance and responsiveness in concurrent scenarios.

#### Do

```python
from typing import AsyncIterator
from sqlmodel import Session

# Async function for I/O-bound operations
async def fetch_user_data(user_id: int, session: Session) -> User:
    user = await session.get(User, user_id)
    return user

# Async generators for streaming results
async def stream_events() -> AsyncIterator[Event]:
    async for event in event_stream:
        yield event

# Proper exception handling in async context
async def process_api_request(request: Request) -> Response:
    try:
        result = await external_api.call()
        return Response(result)
    except APIError as e:
        raise HTTPException(status_code=500, detail=str(e))
```

#### Don't

```python
# Mixing sync I/O in async function (blocks event loop)
async def fetch_data():
    with open('file.txt') as f:
        data = f.read()
    return data

# Unnecessary async for CPU-bound operations
async def calculate_sum(numbers: list[int]):
    return sum(numbers)  # Just make it sync
```

Note: Keep async for I/O-bound operations. Sync is fine for CPU-bound operations and pure functions.

---

### Use Pydantic v2 for data validation and configuration

Use Pydantic v2 features for robust data validation in APIs and configuration management with modern syntax and features.

#### Do

```python
# Pydantic BaseSettings for configuration
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: str
    debug: bool = False

    model_config = {
        'env_file': '.env',
        'env_file_encoding': 'utf-8',
        'extra': 'ignore',
    }

# Discriminated unions for polymorphic types
from typing import Annotated, Literal
from pydantic import BaseModel, Field as PydanticField

class TextContent(BaseModel):
    type: Literal['text'] = 'text'
    content: str

class ImageContent(BaseModel):
    type: Literal['image'] = 'image'
    url: str

Content = Annotated[
    TextContent | ImageContent,
    PydanticField(discriminator='type'),
]

# Use model_dump() for serialization (v2 method)
model_data = user.model_dump(mode='json', exclude={'password'})
```

#### Don't

```python
# Avoid old Pydantic config class (v1 style)
class Settings(BaseSettings):
    database_url: str

    class Config:
        env_file = '.env'

# Avoid .dict() method (replaced with model_dump in v2)
data = model.dict()  # Use model.model_dump() instead
```

---

### Use FastAPI dependency injection for resource management

FastAPI's dependency injection system is powerful for managing authentication, database sessions, and other request-scoped resources.

#### Do

```python
from typing import Annotated, Generator
from fastapi import Depends
from sqlmodel import Session

# Define dependency for database session
def get_database_session() -> Generator[Session, None, None]:
    """Dependency for database session management."""
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()

# Use dependency in routes
@router.get('/items')
async def list_items(
    session: Annotated[Session, Depends(get_database_session)],
) -> list[ItemResponse]:
    items = session.exec(select(Item)).all()
    return [ItemResponse.model_validate(item) for item in items]

# Reusable dependency type alias
DatabaseSession = Annotated[Session, Depends(get_database_session)]

@router.post('/items')
async def create_item(
    data: ItemCreate,
    session: DatabaseSession,  # Cleaner syntax
) -> ItemResponse:
    item = Item(**data.model_dump())
    session.add(item)
    session.commit()
    session.refresh(item)
    return ItemResponse.model_validate(item)
```

#### Don't

```python
# Avoid manual dependency resolution
@router.get('/items')
def list_items(request: Request):
    session = Session(engine)
    try:
        items = session.query(Item).all()
    finally:
        session.close()
    token = request.headers.get('Authorization')
    if not verify_token(token):
        raise HTTPException(status_code=401)
    return items
```

---

### Use SQLModel for database models with separation of concerns

Use SQLModel for combining SQLAlchemy and Pydantic, providing both ORM functionality and data validation. Separate model definitions from CRUD operations.

#### Do

```python
from datetime import datetime, timezone
from typing import Optional
from sqlmodel import Field, Relationship, Session, SQLModel, Column, DateTime, select

# Define models with mixins for shared fields
class TimestampMixin(SQLModel):
    create_time: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_type=DateTime(timezone=True),
    )
    update_time: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_type=DateTime(timezone=True),
    )
    delete_time: Optional[datetime] = Field(
        default=None,
        sa_type=DateTime(timezone=True),
        index=True,
    )

# Use mixins in table definitions
class Asset(TimestampMixin, table=True):
    asset_id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    documents: list['Document'] = Relationship(back_populates='asset')

# Separate CRUD operations from models (in operations module)
def insert_asset(session: Session, name: str) -> Asset:
    asset = Asset(name=name)
    session.add(asset)
    session.commit()
    session.refresh(asset)
    return asset

def get_asset(session: Session, asset_id: int) -> Asset | None:
    statement = select(Asset).where(
        Asset.asset_id == asset_id,
        Asset.delete_time == None,  # Filter soft-deleted
    )
    return session.exec(statement).first()

# Use soft deletion for data preservation
def delete_asset(session: Session, asset_id: int) -> bool:
    asset = get_asset(session, asset_id)
    if not asset:
        return False
    asset.delete_time = datetime.now(timezone.utc)
    session.add(asset)
    session.commit()
    return True
```

#### Don't

```python
# Avoid putting CRUD logic in model classes
class Asset(TimestampMixin, table=True):
    asset_id: Optional[int] = Field(default=None, primary_key=True)
    name: str

    @staticmethod
    def create(session, name):
        pass  # Don't mix model and operations

# Avoid hard deletes unless necessary
def delete_asset(session, asset_id):
    session.delete(asset)  # Hard delete - loses data
    session.commit()

# Avoid querying without soft-delete filter
def get_asset(session, asset_id):
    return session.get(Asset, asset_id)  # Might return deleted records
```

---

### Use Annotated types for dependency injection metadata

Use `Annotated[]` to attach metadata to types, especially for FastAPI dependencies and validation constraints.

#### Do

```python
from typing import Annotated, Generator
from fastapi import Depends, Header, Query
from sqlmodel import Session

def get_session() -> Generator[Session, None, None]:
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()

# Annotated types for dependencies and validation
@router.get('/items')
async def list_items(
    session: Annotated[Session, Depends(get_session)],
    skip: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=100)] = 10,
    api_key: Annotated[str, Header()],
) -> list[ItemResponse]:
    items = session.exec(select(Item).offset(skip).limit(limit)).all()
    return [ItemResponse.model_validate(item) for item in items]

# Type aliases for reusable dependencies
DatabaseSession = Annotated[Session, Depends(get_session)]

@router.post('/items')
async def create_item(
    data: ItemCreate,
    session: DatabaseSession,
) -> ItemResponse:
    item = Item(**data.model_dump())
    session.add(item)
    session.commit()
    return ItemResponse.model_validate(item)
```

#### Don't

```python
# Avoid typing without metadata context
@router.get('/items')
def list_items(session, skip=0, limit=10, auth=None):
    pass

# Avoid mixing Depends syntax
@router.get('/items')
async def list_items(
    session = Depends(get_session),  # Not annotated
    skip: int = 0,
):
    pass
```

---

### Use async generators for streaming data

Use async generators for streaming data and async iteration with proper type hints.

#### Do

```python
import json
from typing import AsyncIterator
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

router = APIRouter()

class AgentEvent(BaseModel):
    type: str
    content: str

class Agent:
    async def run(self) -> AsyncIterator[AgentEvent]:
        """Run agent and yield events as they occur."""
        while True:
            response = await self.get_response()
            for block in response.content:
                if block.type == 'text':
                    yield AgentEvent(type='text', content=block.text)
                elif block.type == 'tool_use':
                    yield AgentEvent(type='tool_call', content=block.name)
            if not has_more_turns(response):
                break

# Use in streaming responses
@router.get('/chat/stream')
async def chat_stream():
    async def event_generator():
        agent = Agent()
        async for event in agent.run():
            yield f'data: {json.dumps(event.model_dump())}\n\n'

    return StreamingResponse(event_generator(), media_type='text/event-stream')
```

#### Don't

```python
# Avoid blocking generators in async context
async def run(self):
    while True:
        yield expensive_sync_operation()  # Blocks event loop

# Avoid AsyncIterator without proper typing
async def run(self):  # No return type hint
    async for event in events:
        yield event
```

---

### Prefer generator dependencies for resource cleanup

Use generator functions with `yield` for FastAPI dependencies that require cleanup to ensure resources are properly released.

#### Do

```python
from typing import Annotated, Generator
from fastapi import Depends
from sqlmodel import Session
from redis import Redis

def get_database_session() -> Generator[Session, None, None]:
    """Provides a database session with automatic cleanup."""
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()

def get_redis_connection() -> Generator[Redis, None, None]:
    """Provides Redis connection with automatic cleanup."""
    redis = Redis(host='localhost', port=6379)
    try:
        yield redis
    finally:
        redis.close()

@router.get('/items')
async def list_items(
    session: Annotated[Session, Depends(get_database_session)],
) -> list[ItemResponse]:
    items = session.exec(select(Item)).all()
    return [ItemResponse.model_validate(item) for item in items]
    # Session automatically closed after response
```

#### Don't

```python
# Avoid manual resource management in endpoints
@router.get('/items')
def list_items():
    session = Session(engine)
    try:
        items = session.exec(select(Item)).all()
        return items
    finally:
        session.close()  # Manual cleanup - verbose and error-prone

# Avoid dependencies without cleanup
def get_session() -> Session:
    return Session(engine)  # Session never closed, memory leak!
```

---

### Use Literal types for strict value constraints

Use `Literal` types to constrain string values to specific options, especially for discriminators in unions and API parameters.

#### Do

```python
from typing import Annotated, Literal
from enum import Enum
from pydantic import BaseModel, Field as PydanticField

# Enum for related constant groups
class ReportType(str, Enum):
    TRAILING_TWELVE = 'TRAILING_TWELVE'
    GENERAL_LEDGER = 'GENERAL_LEDGER'
    RENT_ROLL = 'RENT_ROLL'

# Pydantic models with Literal discriminators
class TrailingTwelveContent(BaseModel):
    type: Literal['TRAILING_TWELVE'] = 'TRAILING_TWELVE'
    months: int
    data: list[dict]

class GeneralLedgerContent(BaseModel):
    type: Literal['GENERAL_LEDGER'] = 'GENERAL_LEDGER'
    postings: list[dict]

# Discriminated union for type-safe polymorphism
ReportContent = Annotated[
    TrailingTwelveContent | GeneralLedgerContent,
    PydanticField(discriminator='type'),
]

# Function parameters with Literal constraints
def process_report(
    content: ReportContent,
    format: Literal['json', 'csv', 'html'] = 'json',
) -> str:
    if format == 'json':
        return content.model_dump_json()
    elif format == 'csv':
        return convert_to_csv(content)
    return convert_to_html(content)
```

#### Don't

```python
# Avoid string literals without constraints
def process_report(content, format='json'):
    if format == 'JSON':  # Case mismatch, silently fails
        pass
    if format == 'xml':  # Unsupported, but no error at type-check time
        pass

# Avoid Union of complex types without discriminator
ReportContent = TrailingTwelveContent | GeneralLedgerContent  # Ambiguous
```

---

### Organize FastAPI projects with separation of concerns

Structure projects to separate HTTP endpoints, business logic, and database schema. Keep routers thin and delegate to operation functions.

#### Do

```python
# Project structure (based on FastAPI + SQLModel stack)
project/
  backend/
    api/              # HTTP routers - one file per resource
      example.py
      auth.py
    db/
      models/         # SQLModel table definitions
      operations/     # CRUD functions and business logic
      session.py      # Database session management
    middleware/       # FastAPI middleware
    utils/            # Helper functions
    main.py           # FastAPI app instance, startup/shutdown
    settings.py       # Pydantic Settings configuration
  alembic/            # Database migrations (Alembic)
    versions/
  pyproject.toml      # Dependencies and project metadata

# Example: Keep routers thin - delegate to operations
# backend/api/example.py
from typing import Annotated
from fastapi import APIRouter, Depends
from sqlmodel import Session

from backend.db.operations import example as example_ops
from backend.db.session import get_session

router = APIRouter(prefix='/examples', tags=['examples'])

@router.get('/{example_id}')
async def get_example(
    example_id: int,
    session: Annotated[Session, Depends(get_session)],
):
    return example_ops.get_example(session, example_id)

# backend/db/operations/example.py - business logic separate
from sqlmodel import Session, select
from backend.db.models.example import Example

def get_example(session: Session, example_id: int) -> Example | None:
    statement = select(Example).where(Example.example_id == example_id)
    return session.exec(statement).first()
```

Note: Separate routers (HTTP layer) from operations (business logic) from models (database schema). This keeps concerns isolated and makes testing easier.

---

### Use Pydantic Settings with environment files

Define all configuration in a Settings class. Use `.env` as a template (empty values) and `.env.local` for actual secrets in local development.

#### Do

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: str
    debug: bool = False

    model_config = {
        'env_file': '.env.local',  # Load actual secrets from .env.local
        'env_file_encoding': 'utf-8',
        'extra': 'ignore',
    }

settings = Settings()
```

Note: Keep `.env` as a template with empty values (e.g., `DATABASE_URL=`). Copy to `.env.local` and fill in actual secrets. Both are gitignored. In production, use environment variables only - avoid .env files to prevent empty values from overriding platform-provided environment variables.

---

### Use appropriate HTTP status codes and response models

Return correct HTTP status codes for operations and use Pydantic models for consistent response structure.

#### Do

```python
from fastapi import HTTPException, status

# 201 for resource creation
@router.post('/examples', status_code=status.HTTP_201_CREATED)
async def create_example(data: ExampleCreate, session: DatabaseSession) -> ExampleResponse:
    example = Example(**data.model_dump())
    session.add(example)
    session.commit()
    session.refresh(example)
    return ExampleResponse.model_validate(example)

# 204 for deletion (no content)
@router.delete('/examples/{example_id}', status_code=status.HTTP_204_NO_CONTENT)
async def delete_example(example_id: int, session: DatabaseSession):
    example = session.get(Example, example_id)
    if example:
        session.delete(example)
        session.commit()

# 404 for not found
@router.get('/examples/{example_id}')
async def get_example(example_id: int, session: DatabaseSession) -> ExampleResponse:
    example = session.get(Example, example_id)
    if not example:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return ExampleResponse.model_validate(example)
```

---
