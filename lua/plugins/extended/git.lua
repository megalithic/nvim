local SETTINGS = require("mega.settings")
local icons = SETTINGS.icons
return {
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      -- signs = {
      --   add = { text = "+" },
      --   change = { text = "~" },
      --   delete = { text = "_" },
      --   topdelete = { text = "‾" },
      --   changedelete = { text = "~" },
      -- },

      signs = {
        add = { hl = "GitSignsAdd", culhl = "GitSignsAddCursorLine", numhl = "GitSignsAddNum", text = icons.git.add }, -- alts: ▕, ▎, ┃, │, ▌, ▎ 🮉
        change = {
          hl = "GitSignsChange",
          culhl = "GitSignsChangeCursorLine",
          numhl = "GitSignsChangeNum",
          text = icons.git.change,
        }, -- alts: ▎║▎
        delete = {
          hl = "GitSignsDelete",
          culhl = "GitSignsDeleteCursorLine",
          numhl = "GitSignsDeleteNum",
          text = icons.git.delete,
        }, -- alts: ┊▎▎
        topdelete = { hl = "GitSignsDelete", text = icons.git.topdelete }, -- alts: ▌ ▄▀
        changedelete = { hl = "GitSignsChange", text = icons.git.changedelete }, -- alts: ▌
        untracked = { hl = "GitSignsAdd", text = icons.git.untracked }, -- alts: ┆ ▕
      },
      current_line_blame = not vim.fn.getcwd():match("dotfiles"),
      current_line_blame_formatter = " <author>, <author_time> · <summary>",
      preview_config = {
        border = SETTINGS.border,
      },
    },
  },

  {
    "linrongbin16/gitlinker.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "GitLink" },
    keys = {
      -- {
      --   "<localleader>gy",
      --   function() linker().get_buf_range_url("n") end,
      --   desc = "gitlinker: copy line to clipboard",
      -- },
      -- {
      --   "<localleader>gy",
      --   function() linker().get_buf_range_url("v") end,
      --   desc = "gitlinker: copy range to clipboard",
      --   mode = { "v" },
      -- },
      -- {
      --   "<localleader>go",
      --   function() linker().get_repo_url(browser_open()) end,
      --   desc = "gitlinker: open in browser",
      -- },
      -- {
      --   "<localleader>go",
      --   function() linker().get_buf_range_url("n", browser_open()) end,
      --   desc = "gitlinker: open current line in browser",
      -- },
      -- {
      --   "<localleader>go",
      --   function() linker().get_buf_range_url("v", browser_open()) end,
      --   desc = "gitlinker: open current selection in browser",
      --   mode = { "v" },
      -- },

      {
        "<localleader>go",
        "<cmd>GitLink!<cr>",
        desc = "gitlinker: open in browser",
        mode = { "n", "v" },
      },
      {
        "<localleader>gO",
        "<cmd>GitLink<cr>",
        desc = "gitlinker: copy to clipboard",
        mode = { "n", "v" },
      },
      {
        "<localleader>gb",
        "<cmd>GitLink! blame<cr>",
        desc = "gitlinker: blame in browser",
        mode = { "n", "v" },
      },
      {
        "<localleader>gB",
        "<cmd>GitLink blame<cr>",
        desc = "gitlinker: copy blame to clipboard",
        mode = { "n", "v" },
      },
    },
    opts = {
      -- print message in command line
      message = true,

      -- highlights the linked line(s) by the time in ms
      -- disable highlight by setting a value equal or less than 0
      highlight_duration = 500,

      -- user command
      command = {
        -- to copy link to clipboard, use: 'GitLink'
        -- to open link in browser, use bang: 'GitLink!'
        -- to use blame router, use: 'GitLink blame' and 'GitLink! blame'
        name = "GitLink",
        desc = "Generate git permanent link",
      },
      mappings = nil,
      debug = true,
      file_log = true,
    },
  },
}
