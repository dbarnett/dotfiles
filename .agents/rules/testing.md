# Testing Guidelines

**When to read this file:** You MUST read this file when writing, reviewing, or debugging tests.

---

## Core Principles

- **One test = one thing** - Each test should verify a single behavior
- **Use parameterized tests** for variations of the same test logic
- **Functional tests spanning multiple components** → separate test file/directory

---

## Test Doubles: Avoid Overmocking

**CRITICAL: Test real behavior, not mocks**

- **Prefer real implementations** over mocks whenever practical
  - Use real objects, real methods, real integrations
  - Only mock external dependencies (APIs, databases, file systems, time)
  - Mocking internal code masks real bugs and makes tests brittle

- **Use appropriate test doubles:**
  - **Stub** - Provides canned responses to calls (for dependencies)
  - **Fake** - Working implementation with shortcuts (in-memory DB, fake API)
  - **Spy** - Records calls made to it for verification
  - **Mock** - Pre-programmed with expectations and verifies them
  - **Dummy** - Passed around but never used (satisfies parameters)

- **Test behaviors, not implementation details:**
  - ✅ Test public APIs and observable outcomes
  - ❌ Don't mock/verify internal method calls
  - ✅ Verify state changes or side effects
  - ❌ Don't verify the exact sequence of internal operations

---

## Project-Specific Examples

These guidelines should be reflected in your project's documentation with concrete examples:

- **AGENTS.local.md** - Project-specific testing conventions
- **.cursor/rules/** - IDE-specific test generation rules
- **AGENTS.md** (project version) - Extended testing examples

**Template for project documentation:**
```markdown
## Testing Examples

### ✅ Good: Testing real behavior
<!-- Insert real example from your codebase -->
def test_user_registration():
    user_service = UserService(real_db_connection)
    user = user_service.register("user@example.com")
    assert user_service.find_by_email("user@example.com") == user

### ❌ Bad: Overmocking internals
<!-- Insert hypothetical bad example in your language -->
def test_user_registration():
    mock_validator = Mock()
    mock_hasher = Mock()
    user_service = UserService(mock_db, mock_validator, mock_hasher)
    # Testing implementation details, not behavior
```

**When examples become outdated:**
- Fix bad code immediately when discovered
- Update docs to reference new positive examples
- Keep one historical bad example as documentation (clearly marked)
