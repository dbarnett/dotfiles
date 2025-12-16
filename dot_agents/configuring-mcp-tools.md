# Configuring MCP Tools

---

## Overview

Model Context Protocol (MCP) servers provide tools to AI assistants, but they consume significant context. This guide covers reducing context usage with mcpwrapped and configuring MCP servers.

**Key concepts:**
- MCP servers expose tools to Claude Code (GitHub, Obsidian, etc.)
- Each tool consumes ~600-900 tokens regardless of whether you use it
- mcpwrapped filters tools to only expose what you need
- Configuration lives in `~/.claude.json`

**Note:** This is primarily a Claude Code issue. Other editors like Cursor have built-in settings to disable MCP tools individually. For background, see [claude-code#7328](https://github.com/anthropics/claude-code/issues/7328).

---

## Reducing Context with mcpwrapped

### What is mcpwrapped?

[mcpwrapped](https://github.com/VitoLin/mcpwrapped) is a lightweight wrapper that filters MCP server tools. Instead of exposing all 48 GitHub tools (33k tokens), you can expose only the 12 you actually use (8k tokens).

**Savings example:**
- Before: GitHub MCP = 48 tools ≈ 33.8k tokens (16.9% of budget)
- After: GitHub MCP = 12 tools ≈ 8.4k tokens (4.2% of budget)
- **Saved: ~25k tokens (12.5% of total budget)**

### Installation

mcpwrapped doesn't require global installation - use `npx`:

```shell
# Test it works
npx -y mcpwrapped --help
```

### Basic Setup

**Before (unwrapped):**
```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_..."
      }
    }
  }
}
```

**After (wrapped with filtered tools):**
```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "mcpwrapped",
        "docker",
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server",
        "--visible_tools=get_me,get_file_contents,list_issues,get_issue,create_issue"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_..."
      }
    }
  }
}
```

**Pattern:**
1. Change `command` to `npx`
2. Add `"-y", "mcpwrapped"` at start of args
3. Move original command into args after mcpwrapped
4. Add `--visible_tools=tool1,tool2,tool3` at end

### Automated Setup Script

```shell
#!/usr/bin/env sh
# Wrap GitHub MCP with essential tools only

TOOLS="get_me,get_file_contents,list_issues,get_issue,create_issue,update_issue,add_issue_comment,list_pull_requests,pull_request_read,list_branches,list_commits,get_commit"

# Backup
cp ~/.claude.json ~/.claude.json.backup

# Update config
jq --arg tools "$TOOLS" '
  .mcpServers.github = {
    "type": "stdio",
    "command": "npx",
    "args": [
      "-y",
      "mcpwrapped",
      "docker",
      "run", "-i", "--rm",
      "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
      "ghcr.io/github/github-mcp-server",
      ("--visible_tools=" + $tools)
    ],
    "env": .mcpServers.github.env
  }
' ~/.claude.json > /tmp/claude.json && mv /tmp/claude.json ~/.claude.json

echo "✅ GitHub MCP wrapped with 12 essential tools"
echo "Restart Claude Code to apply changes"
```

### Choosing Which Tools to Expose

**Start minimal, add as needed. Essential GitHub tools:**

**File operations (2):**
- `get_file_contents` - Read files from GitHub repos
- ~~`create_or_update_file`~~ - Use local tools instead
- ~~`push_files`~~ - Use `git`/`jj` locally instead
- ~~`delete_file`~~ - Use local tools instead

**Issues (5):**
- `list_issues` - Browse issues
- `get_issue` - Get issue details
- `create_issue` - Create new issues
- `update_issue` - Update existing issues
- `add_issue_comment` - Comment on issues

**Pull Requests (2):**
- `list_pull_requests` - Browse PRs
- `pull_request_read` - Get PR details and status
- ~~`create_pull_request`~~ - Use `gh pr create` instead
- ~~`update_pull_request`~~ - Use `gh pr edit` instead
- ~~`merge_pull_request`~~ - Use `gh pr merge` instead

**Branches & Commits (2):**
- `list_branches` - List repository branches
- `list_commits` - Get commit history
- `get_commit` - Get commit details
- ~~`create_branch`~~ - Use `jj`/`git` locally instead

**Basic (1):**
- `get_me` - Get authenticated user info

**Total: 12 tools (down from 48)**

**Tools you might add later:**
- `search_code`, `search_repositories`, `search_issues` - Search GitHub
- `list_releases`, `get_latest_release` - Release management
- `get_label`, `list_label` - Label management
- Full list: https://github.com/github/github-mcp-server

### Verification

```shell
# Check current visible tools
jq -r '.mcpServers.github.args[-1]' ~/.claude.json | sed 's/--visible_tools=//' | tr ',' '\n'

# In Claude Code after restart:
/context
# Check "MCP tools" section - should show only your filtered tools
```

---

## Project-Specific Overrides

### When to Use

Sometimes one project needs tools not in your global filter:
- Release management project needs `list_releases`, `create_release`
- Open source project needs `search_code`, `fork_repository`
- Team project needs `get_team_members`

### Option 1: Add Tools to Global Filter

**When:** Need 1-3 more tools across all projects

**How:**
```shell
# Add search_code and list_releases to global filter
jq '.mcpServers.github.args[-1] += ",search_code,list_releases"' ~/.claude.json > /tmp/claude.json && mv /tmp/claude.json ~/.claude.json
```

### Option 2: Override for Specific Project

**When:** One project needs many extra tools

**How:** Add project-specific config to `~/.claude.json`:

```json
{
  "projects": {
    "/home/user/projects/my-oss-project": {
      "mcpServers": {
        "github": {
          "type": "stdio",
          "command": "docker",
          "args": [
            "run", "-i", "--rm",
            "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
            "ghcr.io/github/github-mcp-server"
          ],
          "env": {
            "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_..."
          }
        }
      }
    }
  }
}
```

**Result:** This project gets all 48 tools, others use the filtered 12.

### Option 3: Different Tool Subset Per Project

```json
{
  "projects": {
    "/home/user/projects/release-manager": {
      "mcpServers": {
        "github": {
          "type": "stdio",
          "command": "npx",
          "args": [
            "-y", "mcpwrapped",
            "docker", "run", "-i", "--rm",
            "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
            "ghcr.io/github/github-mcp-server",
            "--visible_tools=get_me,list_releases,get_latest_release,create_pull_request"
          ],
          "env": {
            "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_..."
          }
        }
      }
    }
  }
}
```

---

## Where MCP Servers are Configured

**Global MCP servers** (available in all projects):
```
~/.claude.json → .mcpServers
```

**Project-specific MCP servers** (only in that project):
```
~/.claude.json → .projects["/path/to/project"].mcpServers
```

**Example:**
```shell
# List global MCP servers
jq '.mcpServers | keys' ~/.claude.json

# List MCP servers for current project
jq --arg pwd "$PWD" '.projects[$pwd].mcpServers | keys // []' ~/.claude.json
```

---

## Configuring Other MCP Servers

### Obsidian MCP

The Obsidian MCP has 12 tools. Most are useful for note-taking, but you could filter:

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y", "mcpwrapped",
        "uvx", "mcp-obsidian",
        "--visible_tools=obsidian_get_file_contents,obsidian_simple_search,obsidian_append_content,obsidian_get_recent_changes"
      ],
      "env": {
        "OBSIDIAN_API_KEY": "...",
        "OBSIDIAN_HOST": "127.0.0.1",
        "OBSIDIAN_PORT": "27124"
      }
    }
  }
}
```

### General Pattern for Any MCP Server

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y", "mcpwrapped",
        "[original-command]",
        "[original-args...]",
        "--visible_tools=tool1,tool2,tool3"
      ],
      "env": {
        "[original-env-vars]": "..."
      }
    }
  }
}
```

---

## Troubleshooting

**"Tool X not found" error:**
1. Check tool is in `--visible_tools` list
2. Verify spelling (GitHub uses snake_case: `get_file_contents` not `getFileContents`)
3. Add to filter or use project override

**Context still high after restart:**
```shell
# Verify config change
jq '.mcpServers.github' ~/.claude.json

# Restart Claude Code completely (exit terminal, reopen)

# Check new context usage
/context  # In Claude Code
```

**Need to restore original config:**
```shell
cp ~/.claude.json.backup ~/.claude.json
```

**mcpwrapped not working:**
```shell
# Test npx can run it
npx -y mcpwrapped --help

# Check for errors in Claude Code startup logs
~/.claude/debug/
```

---

## Summary

**Quick wins:**
1. Install mcpwrapped: `npx -y mcpwrapped --help`
2. Wrap GitHub MCP with 12 essential tools (save ~25k tokens)
3. Add tools only as needed, not preemptively
4. Use project overrides for special cases

**Philosophy:**
- Start minimal, expand as needed
- Context is precious - every tool costs ~700 tokens
- Local tools (git, jj, gh) are better than MCP tools when available
- MCP tools are for data Claude can't get locally (remote repos, issues, PRs)

**Alternative solutions:**
- **Cursor IDE:** Has built-in settings to disable individual MCP tools without needing mcpwrapped
- **Other IDEs:** Check if your IDE has native MCP filtering before using mcpwrapped

**References:**
- mcpwrapped: https://github.com/VitoLin/mcpwrapped
- Claude Code context issue: https://github.com/anthropics/claude-code/issues/7328

**Last Updated:** 2025-12-15
