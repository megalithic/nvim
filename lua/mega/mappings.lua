-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
local map = vim.keymap.set

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>w', function(args)
  vim.api.nvim_command 'silent! write'
end, { desc = 'write buffer' })
map('n', '<leader>W', '<cmd>SudaWrite<cr>', { desc = 'sudo write buffer' })
map('n', '<leader>q', '<cmd>q<cr>', { desc = 'quit' })
map('n', '<leader>Q', '<cmd>q!<cr>', { desc = 'really quit' })

map('n', 'H', '^')
map('n', 'L', '$')
map('v', 'L', 'g_')

map('n', '0', '^')

map('n', 'dd', function()
  if vim.fn.prevnonblank '.' ~= vim.fn.line '.' then
    return '"_dd'
  else
    return 'dd'
  end
end, { expr = true, desc = 'Special Line Delete' })

map('n', '<leader>ps', '<cmd>Lazy sync<cr>', { desc = '[lazy] sync plugins' })
