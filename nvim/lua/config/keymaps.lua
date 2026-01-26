-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ============================================================================
-- CUSTOM KEYMAPS
-- ============================================================================

-- [INSERT MODE] --------------------------------------------------------------
-- jk: Exit insert mode quickly
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- [NORMAL MODE] --------------------------------------------------------------

-- Buffer navigation (LazyVim defaults)
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Quick actions
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all without saving" })

-- ============================================================================
-- LAZYVIM DEFAULT KEYMAPS (Reference)
-- ============================================================================
--
-- [General]
-- <leader>     : Open which-key (show all keybindings)
-- <leader>l    : Open Lazy plugin manager
-- <leader>qq   : Quit all
--
-- [File/Find] <leader>f
-- <leader>ff   : Find files
-- <leader>fr   : Find recent files
-- <leader>fg   : Find git files
-- <leader>fb   : Browse files
--
-- [Search] <leader>s
-- <leader>sg   : Search text (grep)
-- <leader>sw   : Search word under cursor
-- <leader>sr   : Search and replace (Spectre)
--
-- [Buffer] <leader>b
-- <leader>bb   : Switch buffer
-- <leader>bd   : Delete buffer
-- <S-h>        : Previous buffer
-- <S-l>        : Next buffer
--
-- [Window]
-- <C-h/j/k/l>  : Move between windows
-- <leader>w    : Window menu
-- <leader>wd   : Close window
-- <leader>-    : Split horizontal
-- <leader>|    : Split vertical
--
-- [Code] <leader>c
-- <leader>cf   : Format code
-- <leader>cd   : Line diagnostics
-- <leader>cr   : Rename symbol
-- <leader>ca   : Code action
--
-- [Git] <leader>g
-- <leader>gg   : Open Lazygit
-- <leader>gb   : Git blame
-- <leader>gd   : Git diff
--
-- [UI] <leader>u
-- <leader>uf   : Toggle format on save
-- <leader>us   : Toggle spelling
-- <leader>uw   : Toggle word wrap
-- <leader>ul   : Toggle line numbers
--
-- [Explorer]
-- <leader>e    : Toggle file explorer (neo-tree)
-- <leader>E    : Explorer at current directory
--
-- [LSP]
-- gd           : Go to definition
-- gr           : Go to references
-- K            : Hover documentation
-- gI           : Go to implementation
-- gy           : Go to type definition
--
-- [Terminal]
-- <C-/>        : Toggle terminal (LazyVim default)
--
