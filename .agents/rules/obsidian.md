# Obsidian Vault Organization

**When to read this file:** You MUST read this file when:
- Working in the Obsidian vault (`~/.myvault`)
- Helping with daily notes, task planning, or work tracking
- Creating or updating Obsidian notes or templates

---

My Obsidian vault (`~/.myvault`) serves as a personal knowledge base and daily work tracker.

## Core Structure

**Now.canvas** - Central dashboard (canvas file)
- Links to today's daily note and yesterday's daily note
- Contains Todoist integration (`today|overdue` filter)
- Links to key ongoing work notes (e.g., `Obsidian.md`)
- **CRITICAL:** When helping with daily planning or reviewing work, check `Now.canvas` to see what's currently in focus

**Day/** - Daily notes directory
- Format: `YYYY-MM-DD (ddd).md` (e.g., `2025-12-10 (Wed).md`)
- Auto-generated from `Templates/Template, Day.md` using Templater plugin
- **Structure varies by day type:**
  - **Weekdays:** Morning section, Workday section with calendar integration, meeting notes
  - **Weekends:** Simpler "Big stuff" structure
- Each daily note links to previous/next day: `[[Day/YYYY-MM-DD|yday]]` ⇄ `[[Day/YYYY-MM-DD|tmrw]]`

**People/** - Person notes with @ prefix
- Format: `@firstname.lastname.md` or `@firstname.md`
- Used via @ Symbol Linking plugin for quick mentions
- Examples: `[[@leo.vieira]]`, `[[@edu]]`

**Templates/** - Note templates
- `Template, Day.md` - Daily note template with Templater syntax
- Uses conditional logic for weekday vs. weekend structure
- Includes Google Calendar integration via gEvent plugin

## Key Conventions

**Daily Note Structure (Weekdays):**
```markdown
[[Day/YYYY-MM-DD (ddd)|yday]] ⇄ [[Day/YYYY-MM-DD (ddd)|tmrw]]

# Morning
-

# Español
(Spanish study notes, if applicable)

---

# Workday
Priorities:
```gEvent
type: day
date: YYYY-MM-DD
showAllDay: true
hourRange: [0,-1]
include: ["5A Priorities"]
```

## Morning setup
(Setup tasks)

## Meeting Name
(Meeting notes, Google Docs links)

---

(End of day work admin notes)
```

**Daily Note Structure (Weekends):**
```markdown
[[Day/YYYY-MM-DD (ddd)|yday]] ⇄ [[Day/YYYY-MM-DD (ddd)|tmrw]]

Big stuff:
```

**Link Conventions:**
- Daily notes: `[[Day/YYYY-MM-DD (ddd)]]` with aliases `yday`/`tmrw`
- People: `[[@firstname.lastname]]` or `[[People/@firstname.lastname.md|@firstname]]`
- Project/topic notes: Standard wikilinks `[[Note Title]]`
- External links: Auto-titled via Auto Link Title plugin

**Task Management:**
- Todoist integration via Todoist Sync Plugin
- Displayed in `Now.canvas` with `today|overdue` filter
- Individual daily notes may contain checkboxes for day-specific tasks

**Calendar Integration:**
- Google Calendar via gEvent plugin
- Embeds in daily notes with `"5A Priorities"` calendar filter
- Shows all-day events and time-blocked items

## Plugins in Use

**Essential:**
- **Templater** - Daily note generation with conditional logic
- **@ Symbol Linking** - Quick people mentions
- **Google Calendar** - Calendar embedding in daily notes
- **Todoist Sync Plugin** - Task management integration
- **Fit** - Git-based sync (currently in maintenance limbo, may need fork)

**Helpful:**
- **Auto Link Title** - Automatically fetch titles for external URLs
- **Dataview** - Query and display note metadata
- **Excalidraw** - Embedded drawings
- **Emoji Shortcodes** - Quick emoji input

## Working with the Vault

**When creating/updating daily notes:**
- Follow the weekday vs. weekend template structure
- Preserve the yday/tmrw navigation links
- Keep Google Calendar gEvent blocks intact
- Use `[[@person]]` format for people mentions

**When reviewing work history:**
- Check `Now.canvas` for current focus
- Read recent daily notes in `Day/` directory
- Look for recurring meeting notes patterns (e.g., "1:1", "daily")

**When adding new notes:**
- Use descriptive wikilink titles
- Add emoji tags if helpful for topic categorization
- Consider whether note should link from `Now.canvas` if it's ongoing work

**Sync status:**
- Vault syncs via Fit plugin (git-based)
- Sync may be brittle - check `Obsidian.md` for current status
- Mobile sync supported but may require attention

## Common Patterns in Daily Notes

**Meeting notes:**
- Section header: `## [[@person]] 1:1` or `## [[Team, NAME]] daily`
- Often links to Google Docs: `[Meeting title](https://docs.google.com/document/d/...)`
- Action items as checkboxes: `- [ ] ASK: ...` or `- [ ] TODO: ...`

**Project work:**
- Section header: `## [[Project Name]] prep` or `## Work on [[Topic]]`
- Notes about what was worked on, decisions made, blockers
- May reference tickets: `[TICKET-123](https://...)`

**End of day admin:**
- Section at bottom: `# Work admin shit` or similar
- Captures completions: "Interview feedback done!", "Self-eval done!"
