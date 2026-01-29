[![GitHub release](https://img.shields.io/github/v/release/wyhaines/colorls.cr.svg)](https://github.com/wyhaines/colorls.cr/releases)
[![Crystal](https://img.shields.io/badge/Crystal-%3E%3D1.15.0-blue.svg)](https://crystal-lang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

# colorls

A Crystal implementation of [colorls](https://github.com/athityakumar/colorls) — a beautifully colorized `ls` replacement with file-type icons, git status integration, and multiple layout modes.

## Overview

`colorls` enhances directory listings with:

- **Nerd Font icons** for files and directories based on type and extension
- **Git status indicators** showing modified, added, deleted, and untracked files
- **Customizable color themes** (dark and light) with user overrides
- **Multiple display formats** — vertical columns, horizontal, single-column, long, and tree view
- **Sorting and filtering** — by name, size, time, or extension; directories or files only
- **Long format output** — permissions, owner, group, size, modification time, hard link counts, and symlink targets
- **Hyperlink support** — clickable `file://` links in supported terminals
- **Human-readable sizes** — automatic unit conversion for file sizes
- **Locale-aware sorting** — uses the system locale for natural sort order

## Installation

### As a standalone tool

```bash
crystal build src/colorls_cli.cr -o bin/colorls --release
```

Copy `bin/colorls` somewhere on your `PATH`.

### As a shard dependency

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     colorls:
       github: wyhaines/colorls.cr
   ```

2. Run `shards install`

### Requirements

- Crystal >= 1.15.0
- A [Nerd Font](https://www.nerdfonts.com/) installed and configured in your terminal for icon display

## Usage

```bash
colorls                     # List current directory
colorls /path/to/dir        # List specific directory
colorls file1 file2         # List specific files
```

### Display Formats

```bash
colorls -1                  # One entry per line
colorls -l                  # Long format (permissions, owner, size, date)
colorls -x                  # Horizontal layout (entries across, then down)
colorls -C                  # Vertical columns (default for TTY)
colorls --tree              # Tree view (default depth 3)
colorls --tree=5            # Tree view with custom depth
colorls --without-icons     # Disable icons
```

### Filtering and Sorting

```bash
colorls -a                  # Show all entries including hidden
colorls -A                  # Show all except . and ..
colorls -d                  # Directories only
colorls -f                  # Files only
colorls -t                  # Sort by modification time
colorls -S                  # Sort by file size
colorls -X                  # Sort by extension
colorls -U                  # Unsorted (directory order)
colorls -r                  # Reverse sort order
colorls --sd                # Group directories first
colorls --sf                # Group files first
```

### Git Status

```bash
colorls --gs                # Show git status per file
```

Status symbols are color-coded for additions, modifications, deletions, and untracked files.

### Long Format Options

```bash
colorls -l                  # Full long format
colorls -o                  # Long format, no group
colorls -g                  # Long format, no owner
colorls -l -G               # Long format, hide group
colorls -l -L               # Show symlink target info
colorls -l --no-hardlinks   # Hide hard link counts
colorls -l --time-style="%Y-%m-%d"  # Custom date format
colorls -l --non-human-readable     # Show sizes in bytes
```

### Other Options

```bash
colorls --color=always      # Force color (auto, always, never)
colorls --light             # Light color scheme
colorls --dark              # Dark color scheme (default)
colorls --hyperlink         # Enable file:// hyperlinks
colorls -p                  # Append / to directories
colorls -i                  # Show inode numbers
colorls --report            # Short file/folder count report
colorls --report=long       # Detailed count report
```

## Configuration

User-specific overrides are loaded from `~/.config/colorls/`. Place YAML files there to customize colors and icon mappings:

| File | Purpose |
|------|---------|
| `dark_colors.yaml` | Override dark theme colors |
| `light_colors.yaml` | Override light theme colors |
| `files.yaml` | Custom file extension → icon mappings |
| `file_aliases.yaml` | Additional file extension aliases |
| `folders.yaml` | Custom folder name → icon mappings |
| `folder_aliases.yaml` | Additional folder name aliases |

User files are merged with the built-in defaults, so you only need to specify the entries you want to change.

### Color Values

Colors can be specified as CSS color names (`dodgerblue`, `lime`, `gold`) or hex codes (`#FF5733`). The output adapts automatically — truecolor (24-bit) when supported via the `COLORTERM` environment variable, otherwise ANSI 256-color approximation.

## Contributing

1. Fork it (<https://github.com/wyhaines/colorls.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer
