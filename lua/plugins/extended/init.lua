local fmt = string.format
local map = vim.keymap.set
local SETTINGS = require("mega.settings")
local icons = SETTINGS.icons

return {
  {
    -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})
    { "brenoprata10/nvim-highlight-colors", opts = { enable_tailwind = true } },

    -- "gc" to comment visual regions/lines
    { "numToStr/Comment.nvim", opts = {} },

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

    -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
    --
    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `config` key, the configuration only runs
    -- after the plugin has been loaded:
    --  config = function() ... end

    { -- Useful plugin to show you pending keybinds.
      "folke/which-key.nvim",
      event = "VimEnter", -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        require("which-key").setup()

        -- Document existing key chains
        require("which-key").register({
          ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
          ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
          ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
          ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
          ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
          ["<leader>p"] = { name = "[P]lugins", _ = "which_key_ignore" },
          ["<localleader>t"] = { name = "[T]test", _ = "which_key_ignore" },
        })
      end,
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
      },
    },

    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin

    { -- Autoformat
      "stevearc/conform.nvim",
      lazy = false,
      keys = {
        {
          "<leader>f",
          function() require("conform").format({ async = true, lsp_fallback = true }) end,
          mode = "",
          desc = "[F]ormat buffer",
        },
      },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform can also run multiple formatters sequentially
          -- python = { "isort", "black" },
          --
          -- You can use a sub-list to tell conform to run *until* a formatter
          -- is found.
          -- javascript = { { "prettierd", "prettier" } },
        },
      },
    },

    { -- You can easily change to a different colorscheme.
      -- Change the name of the colorscheme plugin below, and then
      -- change the command in the config to whatever the name of that colorscheme is.
      --
      -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
      "folke/tokyonight.nvim",
      cond = false,
      priority = 1000, -- Make sure to load this before all the other start plugins.
      init = function()
        -- Load the colorscheme here.
        -- Like many other themes, this one has different styles, and you could load
        -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
        vim.cmd.colorscheme("tokyonight-night")

        -- You can configure highlights by doing something like:
        vim.cmd.hi("Comment gui=none")
      end,
    },

    -- Highlight todo, notes, etc in comments
    { "folke/todo-comments.nvim", event = "VimEnter", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },
    -- {
    --   "echasnovski/mini.surround",
    --   opts = {
    --     mappings = {
    --       add = "S",
    --       delete = "ds",
    --       find = "",
    --       find_left = "",
    --       highlight = "",
    --       replace = "cs",
    --       update_n_lines = "",
    --     },
    --   },
    --   keys = { { "S", mode = { "n", "x" } }, "ds", "cs" },
    -- },
    -- { "echasnovski/mini.ai", opts = {}, keys = { { "a", mode = { "o", "x" } }, { "i", mode = { "o", "x" } } } },
    { -- Collection of various small independent plugins/modules
      "echasnovski/mini.nvim",
      config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({ n_lines = 500 })

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require("mini.surround").setup()

        -- -- Simple and easy statusline.
        -- --  You could remove this setup call if you don't like it,
        -- --  and try some other statusline plugin
        -- local statusline = require 'mini.statusline'
        -- -- set use_icons to true if you have a Nerd Font
        -- statusline.setup { use_icons = vim.g.have_nerd_font }
        --
        -- -- You can configure sections in the statusline by overriding their
        -- -- default behavior. For example, here we set the section for
        -- -- cursor location to LINE:COLUMN
        -- ---@diagnostic disable-next-line: duplicate-set-field
        -- statusline.section_location = function()
        --   return '%2l:%-2v'
        -- end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
      end,
    },
    { -- Highlight, edit, and navigate code
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby" } },
      },
      config = function(_, opts)
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        require("nvim-treesitter.install").prefer_git = true
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup(opts)

        -- There are additional nvim-treesitter modules that you can use to interact
        -- with nvim-treesitter. You should go explore a few and see what interests you:
        --
        --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
        --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      end,
    },

    -- The following two comments only work if you have downloaded the mega.repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'mega.plugins.debug',
    -- require 'mega.plugins.indent_line',
    -- require 'mega.plugins.lint',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
    -- { import = 'custom.plugins' },
  },
}
