# Neovim + LazyVim Quick Setup

One-line setup for Neovim with LazyVim on Windows.

## Quick Install

**Chạy 1 lệnh này trên máy mới (Run as Administrator):**

```powershell
irm https://raw.githubusercontent.com/hoangneeee/my-nvim-config/master/setup.ps1 | iex
```

Hoặc:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hoangneeee/my-nvim-config/master/setup.ps1" -UseBasicParsing | Invoke-Expression
```

## What Gets Installed

- **Neovim** (latest)
- **LazyVim** distribution
- **Git, Node.js, Python**
- **Ripgrep, fd, fzf** (for Telescope)
- **lazygit** (Git TUI)
- **JetBrainsMono Nerd Font** (with icons)
- **Windows Terminal** configuration

## Manual Install

```powershell
git clone https://github.com/hoangneeee/my-nvim-config.git
cd my-nvim-config
.\install.ps1
```

### Options

```powershell
.\install.ps1 -Help       # Show help
.\install.ps1 -Check      # Check dependencies only
.\install.ps1 -NvimOnly   # Only Neovim + config
.\install.ps1 -SkipFonts  # Skip font installation
```

## Folder Structure

```
my-nvim-config/
├── setup.ps1              # One-line bootstrap script
├── install.ps1            # Main installer
├── README.md
└── nvim/                  # LazyVim configuration
    ├── init.lua           # Entry point
    └── lua/
        ├── config/
        │   ├── lazy.lua       # Plugin manager + LazyVim setup
        │   ├── options.lua    # Custom options
        │   ├── keymaps.lua    # Custom keymaps
        │   └── autocmds.lua   # Custom autocommands
        └── plugins/
            ├── colorscheme.lua  # Theme config (tokyonight)
            └── example.lua      # Example plugin overrides
```

## Customization

Edit files in `nvim/lua/`:

| File | Purpose |
|------|---------|
| `config/options.lua` | Override Neovim options |
| `config/keymaps.lua` | Add custom keybindings |
| `config/autocmds.lua` | Add autocommands |
| `plugins/*.lua` | Add/override plugins |

### Enable Language Extras

Edit `nvim/lua/config/lazy.lua`:

```lua
{ import = "lazyvim.plugins.extras.lang.typescript" },  -- enabled
{ import = "lazyvim.plugins.extras.lang.python" },      -- enabled
-- { import = "lazyvim.plugins.extras.lang.go" },       -- uncomment to enable
-- { import = "lazyvim.plugins.extras.lang.rust" },
```

## Key Bindings

| Key | Action |
|-----|--------|
| `Space` | Show all keybindings (which-key) |
| `Space e` | Toggle file explorer |
| `Space ff` | Find files |
| `Space /` | Search in files (grep) |
| `Space gg` | Open lazygit |
| `Space l` | Lazy plugin manager |
| `jk` | Exit insert mode |
| `Ctrl+s` | Save file |

See full keybindings in `nvim/lua/config/keymaps.lua`

## Links

- [LazyVim Documentation](https://www.lazyvim.org)
- [Neovim](https://neovim.io)
- [Nerd Fonts](https://www.nerdfonts.com)
