# Testing Guidelines

**When to read this file:** You MUST read this file when writing, reviewing, or debugging tests.

---

## Core Principles

- **One test = one thing** - Each test should verify a single behavior
- **Use parameterized tests** for variations of the same test logic
- **Functional tests spanning multiple components** → separate test file/directory

---

## Assertion Patterns: Avoid Field-by-Field

**Prefer asserting complete values over individual fields.**

❌ **Bad — splits one logical check into multiple expects:**
```ts
expect(result.map(h => h.text)).toEqual(['A', 'B']);
expect(result.map(h => h.lineIndex)).toEqual([1, 3]);
// or
expect(result.ok).toBe(false);
expect(result.error).toMatch(/something/);
```

✅ **Good — assert the whole value at once:**
```ts
expect(result).toEqual([
  { lineIndex: 1, level: 2, text: 'A' },
  { lineIndex: 3, level: 2, text: 'B' },
]);
// or
expect(result).toMatchObject({ ok: false, error: expect.stringMatching(/something/) });
```

**Why:** Field-by-field failures lose context ("expected 'foo' to be 'bar'" vs seeing the full object). Multiple `expect` calls on properties of the same value almost always collapse into one `toEqual` or `toMatchObject`.

**For partial matching (vitest/jest):**
- `toMatchObject({ a: 'x' })` — subset of object properties; **prefer for top-level partial matching**
- `expect.objectContaining({ a: 'x' })` — use only nested inside `toEqual` (e.g. array of partial objects); at top level `toEqual(objectContaining(...))` hides unexpected fields in failure output
- `expect.stringMatching(/pattern/)` — string field within `toMatchObject`

**For deterministic but complex string output, prefer inline snapshots** over hand-coding expected strings:
```ts
expect(store.get('foo.md')).toMatchInlineSnapshot(`"## Keep\\nkeep body"`);
```
Vitest fills in the value on first run; subsequent runs assert it hasn't changed.

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
