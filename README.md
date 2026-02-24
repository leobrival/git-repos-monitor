# Git Repos Monitor

A lightweight macOS menubar app to scan directories for git repositories and display their status at a glance.

## Features

- **Auto-scan** configurable directories for git repos (depth 4)
- **Status tracking** — staged, modified, and untracked file counts
- **Branch display** for each repository
- **Last commit** date and message
- **Quick actions** — open in Terminal or Finder
- **Filter toggle** — show all repos or only dirty ones
- **Configurable scan paths** with persistent settings

## Requirements

- macOS 13.0+
- Swift 5.9+
- Git installed at `/usr/bin/git`

## Build

```bash
swift build -c release
```

Or use the bundled script to create a `.app`:

```bash
sh scripts/build.sh
```

## Install

```bash
sh scripts/install.sh
```

Copies the app to `~/Applications/` and optionally creates a LaunchAgent for login startup.

## How It Works

The app uses `find` to locate `.git` directories recursively (max depth 4), then runs `git status --porcelain` and `git log` on each repo. Results refresh automatically every 2 minutes.

Default scan paths: `~/Developer` and `~/Desktop`. Excludes `node_modules`, `.build`, `vendor`, and `.claude` directories.

## License

MIT
