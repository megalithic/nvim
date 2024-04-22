local ftplugin = require("mega.ftplugin")

ftplugin.extend_all({
  elixir = {
    abbr = {
      ep = "|>",
      epry = [[require IEx; IEx.pry]],
      ei = [[IO.inspect()<ESC>hi]],
      eputs = [[IO.puts()<ESC>hi]],
      edb = [[dbg()<ESC>hi]],
      ["~H"] = [[~H""""""<ESC>2hi<CR><ESC>O<BS> ]],
      ["~h"] = [[~H""""""<ESC>2hi<CR><ESC>O<BS> ]],
      [":skip:"] = "@tag :skip",
      tskip = "@tag :skip",
    },
    -- opt = {
    --   iskeyword = vim.opt.iskeyword + { "!", "?", "-" },
    --   indentkeys = vim.opt.indentkeys + { "end" },
    -- },
    callback = function()
      -- REF:
      -- running tests in iex:
      -- https://curiosum.com/til/run-tests-in-elixir-iex-shell?utm_medium=email&utm_source=elixir-radar
      vim.cmd([[setlocal iskeyword+=!,?,-]])
      vim.cmd([[setlocal indentkeys-=0{]])
      vim.cmd([[setlocal indentkeys+=0=end]])

      -- mega.command("CopyModuleAlias", function()
      --   vim.api.nvim_feedkeys(
      --     -- Copy Module Alias to next window? [[mT?defmodule <cr>w"zyiW`T<c-w>poalias <c-r>z]]
      --     vim.api.nvim_replace_termcodes([[mT?defmodule <cr>w"zyiW`Tpoalias <c-r>z]], true, false, true),
      --     "n",
      --     true
      --   )
      -- end)

      local nmap = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = 0, desc = "ex: " .. desc }) end
      local xmap = function(lhs, rhs, desc) vim.keymap.set("x", lhs, rhs, { buffer = 0, desc = "ex: " .. desc }) end
      -- nnoremap("<leader>ed", [[orequire IEx; IEx.pry; #respawn() to leave pry<ESC>:w<CR>]])
      nmap("<localleader>ep", [[o|><ESC>a]], "pipe (new line)")
      nmap("<localleader>ed", [[o|> dbg()<ESC>a]], "dbg (new line)")
      nmap("<localleader>ei", [[o|> IO.inspect()<ESC>i]], "inspect (new line)")
      nmap("<localleader>eil", [[o|> IO.inspect(label: "")<ESC>hi]], "inspect label (new line)")
      nmap("<localleader>em", "<cmd>CopyModuleAlias<cr>", "copy module alias")

      nmap("<localleader>ok", [[:lua require("mega.utils").wrap_cursor_node("{:ok, ", "}")<CR>]], "copy module alias")
      xmap("<localleader>ok", [[:lua require("mega.utils").wrap_selected_nodes("{:ok, ", "}")<CR>]], "copy module alias")
      nmap("<localleader>err", [[:lua require("mega.utils").wrap_cursor_node("{:error, ", "}")<CR>]], "copy module alias")
      xmap("<localleader>err", [[:lua require("mega.utils").wrap_selected_nodes("{:error, ", "}")<CR>]], "copy module alias")

      local has_wk, wk = pcall(require, "which-key")
      if has_wk then wk.register({
        ["<localleader>e"] = { name = "+elixir" },
      }) end
    end,
  },
  heex = {
    opt = {
      tabstop = 2,
      shiftwidth = 2,
      commentstring = [[<%!-- %s --%>]],
    },
  },
  gitconfig = {
    opt = {
      tabstop = 2,
      shiftwidth = 2,
      commentstring = [[# %s]],
    },
  },
  gitcommit = {
    keys = {
      { "q", vim.cmd.cquit, { nowait = true, buffer = true, desc = "abort", bang = true } },
    },
    opt = {
      list = false,
      number = false,
      relativenumber = false,
      cursorline = false,
      spell = true,
      spelllang = "en_gb",
      colorcolumn = "50,72",
    },
    callback = function()
      vim.fn.matchaddpos("DiagnosticVirtualTextError", { { 1, 50, 10000 } })
      if vim.fn.prevnonblank(".") ~= vim.fn.line(".") then vim.cmd.startinsert() end
    end,
  },
  gitrebase = {
    function() vim.keymap.set("n", "q", vim.cmd.cquit, { nowait = true, desc = "abort" }) end,
  },
  neogitcommitmessage = {
    keys = {
      { "q", vim.cmd.cquit, { nowait = true, buffer = true, desc = "abort", bang = true } },
    },
    opt = {
      list = false,
      number = false,
      relativenumber = false,
      cursorline = false,
      spell = true,
      spelllang = "en_gb",
      colorcolumn = "50,72",
    },
    callback = function()
      map("n", "q", vim.cmd.cquit, { buffer = true, nowait = true, desc = "Abort" })
      vim.fn.matchaddpos("DiagnosticVirtualTextError", { { 1, 50, 10000 } })
      if vim.fn.prevnonblank(".") ~= vim.fn.line(".") then vim.cmd.startinsert() end
    end,
  },
  fugitiveblame = {
    keys = {
      { "gp", "<CMD>echo system('git findpr ' . expand('<cword>'))<CR>" },
    },
  },
  help = {
    keys = {
      { "gd", "<C-]>" },
    },
    opt = {
      signcolumn = "no",
      splitbelow = true,
      number = true,
      relativenumber = true,
      list = false,
      textwidth = 80,
    },
    callback = function() mega.pcall(vim.treesitter.start) end,
  },
  man = {
    keys = {
      { "gd", "<C-]>" },
    },
    opt = {
      signcolumn = "no",
      splitbelow = true,
      number = true,
      relativenumber = true,
      list = false,
      textwidth = 80,
    },
  },
  oil = {
    keys = {},
    opt = {
      conceallevel = 3,
      concealcursor = "n",
      list = false,
      wrap = false,
      signcolumn = "no",
    },
    callback = function()
      local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = 0, desc = "oil: " .. desc }) end

      map("q", "<cmd>q<cr>", "quit")
      map("<leader>ed", "<cmd>q<cr>", "quit")
      map("<BS>", function() require("oil").open() end, "goto parent dir")

      map("<localleader>ff", function()
        local oil = require("oil")
        local dir = oil.get_current_dir()
        if vim.api.nvim_win_get_config(0).relative ~= "" then vim.api.nvim_win_close(0, true) end
        mega.find_files({ cwd = dir, hidden = true })
      end, "find files in dir")
      map("<localleader>a", function()
        local oil = require("oil")
        local dir = oil.get_current_dir()
        if vim.api.nvim_win_get_config(0).relative ~= "" then vim.api.nvim_win_close(0, true) end
        mega.grep({ cwd = dir })
      end, "grep files in dir")
    end,
  },
  lua = {
    abbr = {
      ["!="] = "~=",
      locla = "local",
      vll = "vim.log.levels",
    },
    keys = {
      { "gh", "<CMD>exec 'help ' . expand('<cword>')<CR>" },
    },
    opt = {
      comments = ":---,:--",
    },
  },
})

ftplugin.setup()
