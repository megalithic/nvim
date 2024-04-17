local SETTINGS = mega.req("mega.settings")

return {
  { -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {},
  },

  { "lukas-reineke/virt-column.nvim", opts = { char = SETTINGS.virt_column_char }, event = "VimEnter" },
  {
    "echasnovski/mini.indentscope",
    config = function()
      mega.req("mini.indentscope").setup({
        symbol = SETTINGS.indent_scope_char,
        -- mappings = {
        --   goto_top = "<leader>k",
        --   goto_bottom = "<leader>j",
        -- },
        draw = {
          delay = 10,
          animation = function() return 0 end,
        },
        options = { try_as_border = true, border = "both", indent_at_cursor = true },
      })

      mega.req("mega.autocmds").augroup("mini.indentscope", {
        {
          event = "FileType",
          pattern = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "fzf",
            "dirbuf",
            "terminal",
            "fzf-lua",
            "fzflua",
            "megaterm",
            "nofile",
            "terminal",
            "megaterm",
            "lsp-installer",
            "SidebarNvim",
            "lspinfo",
            "markdown",
            "help",
            "startify",
            "packer",
            "NeogitStatus",
            "oil",
            "DirBuf",
            "markdown",
          },
          command = function() vim.b.miniindentscope_disable = true end,
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "LazyFile" },
    main = "ibl",
    opts = {
      indent = {
        char = SETTINGS.indent_char,
        smart_indent_cap = false,
      },
      scope = {
        enabled = false,
      },
      exclude = { filetypes = { "markdown" } },
    },
  },
}
