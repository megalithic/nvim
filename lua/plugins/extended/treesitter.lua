local disable_max_size = 2000000 -- 2MB

local function should_disable(lang, bufnr)
  local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr or 0))
  -- size will be -2 if it doesn't fit into a number
  if size > disable_max_size or size == -2 then return true end
  if vim.tbl_contains({ "ruby" }, lang) then return true end

  return false
end
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "csv",
        "comment",
        "devicetree",
        "dockerfile",
        "diff",
        "eex", -- doesn't seem to work, using `html_eex` below, too
        "elixir",
        "elm",
        "embedded_template",
        "erlang",
        "fish",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "graphql",
        "heex",
        "html",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "jsonc",
        "json5",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "nix",
        "perl",
        "psv",
        "python",
        "query",
        "regex",
        "ruby",
        "rust",
        "scss",
        "scheme",
        "sql",
        "surface",
        "teal",
        "toml",
        "tsv",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
      highlight = {
        enable = vim.g.vscode ~= 1,
        disable = should_disable,
        use_languagetree = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = {
          "ruby",
          "python",
          -- "lua",
          "vim",
          "zsh",
        },
      },
      indent = {
        enable = true,
        disable = function(lang, bufnr)
          if lang == "lua" then -- or lang == "python" then
            return true
          else
            return should_disable(lang, bufnr)
          end
        end,
      },

      endwise = { enable = true },
      matchup = { enable = true, include_match_words = true, disable = should_disable, disable_virtual_text = false },
      incremental_selection = {
        enable = true,
        keymaps = {
          -- init_selection = ":lua require'wildfire'.init_selection()<CR>:lua require('flash').treesitter()<CR>",
          -- init_selection = "vv",
          node_incremental = "v",
          node_decremental = "V",
          scope_incremental = false,
          -- scope_incremental = "vv", -- increment to the upper scope (as defined in locals.scm)
        },
      },
    },
    config = function(_, opts)
      local ft_to_parser_aliases = {
        dotenv = "bash",
        gitcommit = "NeogitCommitMessage",
        javascriptreact = "jsx",
        json = "jsonc",
        keymap = "devicetree",
        kittybuf = "bash",
        typescriptreact = "tsx",
        zsh = "bash",
        eelixir = "elixir",
      }

      for ft, parser in pairs(ft_to_parser_aliases) do
        vim.treesitter.language.register(parser, ft)
      end

      require("nvim-treesitter.install").prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  { "nvim-treesitter/nvim-treesitter-textobjects", cond = false, dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "RRethy/nvim-treesitter-textsubjects", cond = false, dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "nvim-treesitter/nvim-tree-docs", cond = false, dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "RRethy/nvim-treesitter-endwise", dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "megalithic/nvim-ts-autotag", dependencies = { "nvim-treesitter/nvim-treesitter" } },
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cond = false,
    lazy = false,
    config = function()
      vim.g.matchup_matchparen_nomode = "i"
      vim.g.matchup_delim_noskips = 1 -- recognize symbols within comments
      vim.g.matchup_matchparen_deferred_show_delay = 400
      vim.g.matchup_matchparen_deferred_hide_delay = 400
      vim.g.matchup_matchparen_offscreen = {}
      -- vim.g.matchup_matchparen_offscreen = {
      --   method = "popup",
      --   -- fullwidth = true,
      --   highlight = "TreesitterContext",
      --   border = "",
      -- }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 300
      vim.g.matchup_matchparen_insert_timeout = 60
      vim.g.matchup_surround_enabled = 1 -- defaulted 0
      vim.g.matchup_motion_enabled = 1 -- defaulted 0
      vim.g.matchup_text_obj_enabled = 1
    end,
  },
  { "David-Kunz/treesitter-unit", cond = false, dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "yorickpeterse/nvim-tree-pairs", dependencies = { "nvim-treesitter/nvim-treesitter" }, opts = {} },
  {
    "HiPhish/rainbow-delimiters.nvim",
    -- FIXME: MIGHT be causing segfaults
    cond = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VimEnter",
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          html = "rainbow-tags",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
        blacklist = { "c", "cpp" },
      }
    end,
  },
}
