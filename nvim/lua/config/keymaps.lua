-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ============================================================================
-- CUSTOM KEYMAPS - VSCode Friendly (Dễ làm quen)
-- ============================================================================

-- [INSERT MODE] --------------------------------------------------------------
-- jk          : Thoát insert mode nhanh (thay vì ESC xa tay)
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Ctrl+S      : Lưu file (giống VSCode)
map("i", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Save file" })

-- [NORMAL MODE] --------------------------------------------------------------

-- === FILE OPERATIONS (giống VSCode) ===
-- Ctrl+S      : Lưu file
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Ctrl+P      : Tìm file (giống VSCode Ctrl+P)
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

-- Ctrl+Shift+F : Tìm text trong project (giống VSCode)
map("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in files" })

-- Ctrl+Shift+P : Command palette (giống VSCode)
map("n", "<C-S-p>", "<cmd>Telescope commands<cr>", { desc = "Command palette" })

-- === SIDEBAR & UI (giống VSCode) ===
-- Ctrl+B      : Toggle file explorer (giống VSCode sidebar)
map("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

-- Ctrl+`      : Toggle terminal (giống VSCode)
map("n", "<C-`>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

-- === BUFFER/TAB (giống VSCode tabs) ===
-- Ctrl+W      : Đóng buffer/tab hiện tại
map("n", "<C-w>", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Ctrl+Tab    : Buffer tiếp theo (giống VSCode tab next)
map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Ctrl+Shift+Tab : Buffer trước (giống VSCode tab prev)
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Shift+H/L   : Di chuyển giữa buffers (LazyVim default - giữ lại)
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- === CODE EDITING (giống VSCode) ===
-- Ctrl+/      : Comment/Uncomment (giống VSCode)
map("n", "<C-_>", "gcc", { desc = "Comment line", remap = true })
map("v", "<C-_>", "gc", { desc = "Comment selection", remap = true })

-- Ctrl+D      : Select next occurrence (giống VSCode multi-cursor)
-- (LazyVim đã có sẵn với flash.nvim)

-- === QUICK ACTIONS ===
-- <leader>x   : Đóng buffer (alias cho Ctrl+W)
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- <leader>Q   : Thoát tất cả không lưu
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all without saving" })

-- ============================================================================
-- CHIẾN LƯỢC HỌC NVIM TỪ VSCODE (3 giai đoạn)
-- ============================================================================
--
-- 🔰 TUẦN 1-2: DÙNG VSCODE KEYBINDINGS (ở trên)
-- ────────────────────────────────────────────
-- • Ctrl+P    : Tìm file
-- • Ctrl+S    : Save
-- • Ctrl+B    : Toggle sidebar
-- • Ctrl+W    : Đóng tab
-- • Ctrl+/    : Comment
-- → Mục tiêu: Làm việc bình thường, quen với Neovim UI
--
-- 🚀 TUẦN 3-4: HỌC VIM MOTIONS CÔ BẢN
-- ────────────────────────────────────────────
-- • hjkl      : Di chuyển (thay mũi tên)
-- • w/b       : Nhảy từ (word forward/backward)
-- • 0/$       : Đầu/cuối dòng
-- • gg/G      : Đầu/cuối file
-- • dd/yy/p   : Delete/Copy/Paste dòng
-- • ciw/diw   : Change/Delete word
-- → Mục tiêu: Bắt đầu thấy nhanh hơn VSCode
--
-- ⚡ TUẦN 5+: DÙNG LAZYVIM LEADER KEYS
-- ────────────────────────────────────────────
-- • <leader>  : Ấn Space xem tất cả shortcuts (which-key)
-- • <leader>ff: Find files (thay Ctrl+P)
-- • <leader>sg: Search grep (thay Ctrl+Shift+F)
-- • <leader>e : File explorer
-- → Mục tiêu: Workflow tối ưu, tay không rời home row
--
-- ============================================================================
-- LAZYVIM DEFAULT KEYMAPS (Tham khảo - đã có sẵn)
-- ============================================================================
--
-- [General]
-- <leader>     : Mở which-key (hiện tất cả keybindings)
-- <leader>l    : Mở Lazy plugin manager
-- <leader>qq   : Thoát tất cả
--
-- [File/Find] <leader>f
-- <leader>ff   : Tìm file
-- <leader>fr   : Tìm file đã mở gần đây
-- <leader>fg   : Tìm file trong git
-- <leader>fb   : Duyệt file
--
-- [Search] <leader>s
-- <leader>sg   : Tìm kiếm text (grep)
-- <leader>sw   : Tìm từ dưới cursor
-- <leader>sr   : Tìm và thay thế (Spectre)
--
-- [Buffer] <leader>b
-- <leader>bb   : Chuyển buffer
-- <leader>bd   : Xóa buffer
-- <S-h>        : Buffer trước
-- <S-l>        : Buffer sau
--
-- [Window]
-- <C-h/j/k/l>  : Di chuyển giữa các window
-- <leader>w    : Window menu
-- <leader>wd   : Đóng window
-- <leader>-    : Split ngang
-- <leader>|    : Split dọc
--
-- [Code] <leader>c
-- <leader>cf   : Format code
-- <leader>cd   : Line diagnostics
-- <leader>cr   : Rename symbol
-- <leader>ca   : Code action
--
-- [Git] <leader>g
-- <leader>gg   : Mở Lazygit
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
-- <leader>E    : Explorer tại thư mục hiện tại
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
