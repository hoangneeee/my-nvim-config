-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ============================================================================
-- CUSTOM KEYMAPS (Bổ sung thêm vào LazyVim)
-- ============================================================================

-- [INSERT MODE] --------------------------------------------------------------
-- jk          : Thoát insert mode nhanh
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- <C-s>       : Lưu file (trong insert mode)
map("i", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Save file" })

-- [NORMAL MODE] --------------------------------------------------------------
-- <C-s>       : Lưu file
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- <leader>x   : Đóng buffer hiện tại
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- <leader>Q   : Thoát tất cả không lưu
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all without saving" })

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
