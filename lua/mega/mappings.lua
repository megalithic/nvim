-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
local map = vim.keymap.set

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", function(args) vim.api.nvim_command("silent! write") end, { desc = "write buffer" })
map("n", "<leader>W", "<cmd>SudaWrite<cr>", { desc = "sudo write buffer" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "quit" })
map("n", "<leader>Q", "<cmd>q!<cr>", { desc = "really quit" })

-- [[ better movements within a buffer ]] --------------------------------------------
map("n", "H", "^")
map("n", "L", "$")
map("v", "L", "g_")
map("n", "0", "^")

-- ignores line wraps
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ plugin management ]] --------------------------------------------
map("n", "<leader>ps", "<cmd>Lazy sync<cr>", { desc = "[lazy] sync plugins" })

-- [[ opening/closing delimiters/matchup/pairs ]] --------------------------------------------
map({ "n", "o", "s", "v", "x" }, "<Tab>", "%", { desc = "jump to opening/closing delimiter", remap = true, silent = false })

-- [[ copy/paste/yank/registers ]] --------------------------------------------
-- don't yank the currently pasted text // thanks @theprimeagen
vim.cmd([[xnoremap <expr> p 'pgv"' . v:register . 'y']])
-- xnoremap("p", "\"_dP", "paste with saved register contents")

-- yank to empty register for D, c, etc.
map("n", "x", "\"_x")
map("n", "X", "\"_X")
map("n", "D", "\"_D")
map("n", "c", "\"_c")
map("n", "C", "\"_C")
map("n", "cc", "\"_S")

map("x", "x", "\"_x")
map("x", "X", "\"_X")
map("x", "D", "\"_D")
map("x", "c", "\"_c")
map("x", "C", "\"_C")

map("n", "dd", function()
  if vim.fn.prevnonblank(".") ~= vim.fn.line(".") then
    return "\"_dd"
  else
    return "dd"
  end
end, { expr = true, desc = "Special Line Delete" })

-- Undo breakpoints
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", "!", "!<C-g>u")
map("i", "?", "?<C-g>u")
