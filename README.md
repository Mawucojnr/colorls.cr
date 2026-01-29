[![GitHub release](https://img.shields.io/github/v/release/wyhaines/colorls.cr.svg)](https://github.com/wyhaines/colorls.cr/releases)
[![Crystal](https://img.shields.io/badge/Crystal-%3E%3D1.15.0-blue.svg)](https://crystal-lang.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

# colorls

A Crystal rewrite inspired by [colorls](https://github.com/athityakumar/colorls) — a beautifully colorized `ls` replacement with file-type icons, git status integration, and broad GNU `ls` flag compatibility.

## Overview

`colorls` enhances directory listings with:

- **Nerd Font icons** for files and directories based on type and extension
- **Git status indicators** showing modified, added, deleted, and untracked files
- **Customizable color themes** (dark and light) with user overrides
- **Multiple display formats** — vertical columns, horizontal, single-column, long, comma-separated, and tree view
- **GNU `ls` compatibility** — supports most common flags (`-d`, `-f`, `-F`, `-R`, `-m`, `-n`, `-o`, `-g`, `-s`, `-B`, `-I`, `-Q`, `-b`, `-q`, `-X`, `-v`, `-c`, `-u`, `-H`, `-w`, `--sort`, `--format`, `--time`, `--time-style`, `--quoting-style`, `--indicator-style`, `--block-size`, `--hide`, `--si`, and more)
- **Sorting and filtering** — by name, size, time, extension, or version; directories or files only; pattern-based exclusions
- **Long format output** — permissions, owner, group, size, modification time, hard link counts, symlink targets, author, numeric IDs, and allocated blocks
- **Hyperlink support** — clickable `file://` links in supported terminals
- **Human-readable sizes** — automatic unit conversion with SI or binary units
- **Locale-aware sorting** — uses the system locale for natural sort order
- **Recursive listing** — traverse subdirectories with `-R`

## Installation

### Prebuilt binaries

Prebuilt binaries are available for each [GitHub release](https://github.com/wyhaines/colorls.cr/releases). Download the archive for your platform, extract it, and place the binary on your `PATH`:

```bash
# Example for Linux x86_64 (static build, works on any distro)
tar xzf colorls-linux-x86_64-static.tar.gz
sudo mv colorls-linux-x86_64-static /usr/local/bin/colorls
```

Available builds:

| Archive | Platform |
|---------|----------|
| `colorls-linux-x86_64-static.tar.gz` | Linux x86_64 (static, portable) |
| `colorls-linux-x86_64.tar.gz` | Linux x86_64 (dynamic) |
| `colorls-linux-aarch64.tar.gz` | Linux ARM64 (dynamic) |
| `colorls-darwin-x86_64.tar.gz` | macOS Intel |
| `colorls-darwin-aarch64.tar.gz` | macOS Apple Silicon |

The static Linux build has no runtime dependencies and works on any Linux distribution. The dynamic builds require a compatible system libc.

### Building from source

If a prebuilt binary isn't available for your platform, or you prefer to build from source:

```bash
crystal build src/colorls_cli.cr -o bin/colorls --release
```

Copy `bin/colorls` somewhere on your `PATH`. Requires Crystal >= 1.15.0.

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

## Replacing `ls`

To use `colorls` as a drop-in replacement for `ls`, add an alias to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
alias ls='colorls'
```

If you prefer to keep some default options:

```bash
alias ls='colorls --gs'        # always show git status
alias ls='colorls --sd'        # always group directories first
alias ls='colorls --sd --gs'   # both
```

Reload your shell or run `source ~/.bashrc` (or `~/.zshrc`) for the change to take effect. Combined short flags work as expected — `ls -lart`, `ls -la`, etc.

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
colorls -m                  # Comma-separated list
colorls --format=WORD       # across, horizontal, long, single-column, vertical, commas
colorls --tree              # Tree view (default depth 3)
colorls --tree=5            # Tree view with custom depth
colorls --without-icons     # Disable icons
```

### Filtering and Sorting

```bash
colorls -a                  # Show all entries including hidden
colorls -A                  # Show all except . and ..
colorls -d                  # List directories themselves, not contents
colorls --dirs              # Show only directories
colorls --files             # Show only files
colorls -f                  # Do not sort, enable -a, disable color
colorls -t                  # Sort by modification time
colorls -S                  # Sort by file size
colorls -X                  # Sort by extension
colorls -v                  # Natural (version) sort
colorls -U                  # Unsorted (directory order)
colorls --sort=WORD         # none, size, time, extension, version
colorls -r                  # Reverse sort order
colorls --sd                # Group directories first
colorls --sf                # Group files first
colorls -R                  # List subdirectories recursively
colorls -B                  # Ignore entries ending with ~
colorls --hide=PATTERN      # Hide entries matching shell pattern
colorls -I PATTERN          # Ignore entries matching shell pattern
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
colorls -n                  # Long format with numeric user/group IDs
colorls -l -G               # Long format, hide group
colorls -l -L               # Show symlink target info
colorls -l --author         # Show file author
colorls -l --no-hardlinks   # Hide hard link counts
colorls -l --time-style="+%Y-%m-%d"  # Custom date format
colorls -l --full-time      # Long format with full ISO time
colorls -l --non-human-readable     # Show sizes in bytes
```

### Indicator and Name Options

```bash
colorls -F                  # Append indicator (*/=>@|) to entries
colorls --file-type         # Like -F but without * for executables
colorls --indicator-style=STYLE  # none, slash, classify, file-type
colorls -p                  # Append / to directories
colorls -Q                  # Enclose names in double quotes
colorls -b                  # Print C-style escapes for nongraphic chars
colorls -q                  # Print ? for nongraphic characters
colorls --quoting-style=WORD  # literal, shell, shell-always, c, escape, locale, clocale
```

### Size and Time Options

```bash
colorls -s                  # Show allocated size in blocks
colorls --block-size=SIZE   # Scale sizes (e.g., 1K, 1M, 4096)
colorls --si                # Use powers of 1000 instead of 1024
colorls -k                  # Use 1024-byte blocks for -s
colorls -w COLS             # Set output width
colorls -c                  # Show/sort by ctime
colorls -u                  # Show/sort by atime
colorls --time=WORD         # atime, access, ctime, status, birth
```

### Other Options

```bash
colorls --color=WHEN        # Colorize: auto, always, never
colorls --light             # Light color scheme
colorls --dark              # Dark color scheme (default)
colorls --hyperlink         # Enable file:// hyperlinks
colorls -i                  # Show inode numbers
colorls -H                  # Follow symlinks on command line
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
