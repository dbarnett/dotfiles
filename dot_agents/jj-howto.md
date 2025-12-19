# Jujutsu (jj) Version Control Howto

**When to read this:** When working with version control in any repository that has a `.jj/` directory, or when you need to perform version control operations in my projects.

---

## Overview

Jujutsu ([jj-vcs.dev](https://jj-vcs.dev/)) is a version control system that provides a friendlier interface to Git. All my projects use jj instead of direct git commands.

---

## Key Concepts

Jujutsu flips traditional git workflows:

- **Continuous snapshots**: Changes are automatically snapshotted from your working directory (anything not in `.gitignore`)
- **Change-centric**: You work with "changes" (stable change IDs) rather than commits (which are transient)
- **No explicit staging**: Working directory changes automatically become part of the current change
- **Amending is automatic**: `jj commit` creates a new change on top; modifications to current change happen automatically
- **Bookmarks not branches**: Use bookmarks to point to specific changes (like git branches, but moveable)
- **Immutability**: Changes become immutable after pushing to remote

---

## Essential Commands Cheatsheet

```shell
# Check status of current change
jj status

# View current change with file statistics
jj show --stat

# View change history with statistics
jj log --stat

# View compact change graph
jj log

# Create new change on top of current (stops updating current change)
jj new

# Create new change with description
jj new -m "Description of what I'm working on"

# Describe/update current change description
jj describe

# Amend/modify current change (though this happens automatically)
jj squash  # squash current into parent

# View diff of current change
jj diff

# View diff with statistics
jj diff --stat

# Move between changes
jj edit <change-id>  # make a specific change current
jj prev             # move to parent change
jj next             # move to child change

# Bookmarks (like git branches)
jj bookmark create <name>     # create bookmark at current change
jj bookmark set <name>        # move bookmark to current change
jj bookmark list              # list all bookmarks

# Push to remote
jj git push                   # push current bookmark
jj git push --all             # push all bookmarks
jj git push --change @        # push current change (creates branch)

# Pull from remote
jj git fetch                  # fetch from all remotes
jj git fetch --all-remotes    # fetch from all configured remotes

# Abandon changes (like git reset)
jj abandon                    # abandon current empty change
jj abandon <change-id>        # abandon specific change

# Undo last operation
jj undo

# Restore files from a change
jj restore --from <change-id>

# Read files from a specific change (without checking it out)
jj file show -r <change-id> <path>       # show file contents from change
jj file show -r _grafana_scripts README.md  # example: read README from another change
jj file list -r <change-id>              # list all files in change
```

---

## Common Workflows

### Starting new work

```shell
jj new -m "Implement feature X"
# Make changes, they auto-snapshot to current change
jj show --stat  # review what's changed
```

### Switching contexts

```shell
jj new -m "Quick bugfix"
# Work on bugfix
jj new  # start another change on top, or...
jj edit <change-id>  # jump to different change
```

### Preparing for review

```shell
jj log --stat  # review all changes in lineage
jj describe  # polish change description
jj git push  # push bookmark to remote
```

### Checking what's happening

```shell
jj status         # what files changed in current change
jj show --stat    # current change summary
jj log --stat     # history with file stats
jj log -r ::@     # changes from root to current
```

---

## Tips and Best Practices

1. **Check status frequently** - `jj status` and `jj show --stat` help you understand what's in your current change
2. **Use descriptive change descriptions** - They persist across rebases and help track intent
3. **Leverage automatic amending** - No need to `jj amend`, just make changes and they're added to current change
4. **Create new changes deliberately** - Use `jj new` when you want to start tracking a different logical change
5. **Bookmarks are cheap** - Create them freely to mark important changes

---

## Further Reading

- Official docs: [jj-vcs.dev](https://jj-vcs.dev/)
- Tutorial: [jj-vcs.dev/latest/tutorial](https://jj-vcs.dev/latest/tutorial/)
- Git comparison: [jj-vcs.dev/latest/git-comparison](https://jj-vcs.dev/latest/git-comparison/)
