# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

colorls.cr is a Crystal port of the Ruby `colorls` tool — a colorized `ls` replacement with file-type icons, git status integration, and multiple layout modes.

## Build & Test Commands

```bash
# Build
crystal build src/colorls_cli.cr -o bin/colorls

# Run directly
crystal run src/colorls_cli.cr -- [ARGS]

# Run all tests
crystal spec

# Run a single spec file
crystal spec spec/colorls/core_spec.cr

# Install dependencies
shards install
```

Crystal >= 1.15.0 is required (see `shard.yml`).

## Architecture

**Entry point:** `src/colorls_cli.cr` → creates `Flags`, parses args into a `Config` struct, passes it to `Core`, exits.

**Key classes:**

- `Flags` (`flags.cr`) — OptionParser-based CLI arg parsing, produces a `Config`
- `Core` (`core.cr`) — main listing logic: traversal, sorting, filtering, formatting output
- `FileInfo` (`file_info.cr`) — wraps file metadata with caching for owner/group lookups and symlink handling
- `Git` (`git.cr`) — parses `git status --porcelain` output, provides per-file status symbols
- `Layout` (`layout.cr`) — three layout engines: SingleColumn, Horizontal, Vertical (column width via binary search)
- `ColorMap` (`color_map.cr`) — CSS color names → RGB, truecolor/ANSI256 detection and conversion
- `YamlConfig` (`yaml_config.cr`) — loads bundled YAML configs, merges user overrides from `~/.config/colorls/`
- `Config` / enums (`types.cr`) — all configuration types: SortMode, DisplayMode, ShowFilter, GroupMode, etc.

**Data flow:** CLI args → `Flags` → `Config` → `Core.ls_dir()`/`ls_files()` → `FileInfo` objects → sort/filter/group → `Layout` → colored terminal output.

**YAML data files** in `src/yaml/`: icon mappings (files, folders, aliases) and color themes (dark, light).

## Dependencies

- **unicode_width** (local path `../unicode_width.cr`) — terminal display width calculations for multi-byte characters
- LibC bindings for: `ioctl` (terminal size), `lstat`, `getpwuid_r`/`getgrgid_r` (owner/group), `strxfrm`/`setlocale` (locale-aware sorting)

## Key Implementation Notes

- Terminal width detected via `TIOCGWINSZ` ioctl, falls back to `COLUMNS` env or 80
- Truecolor support detected via `COLORTERM` env var; otherwise ANSI256 color cube mapping
- User/group name lookups are cached in static hashes
- Git status is fetched once per directory and cached
