return {

  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then return end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      { "saadparwaiz1/cmp_luasnip", cond = vim.g.snipper == "luasnip" },
      {
        "garymjr/nvim-snippets",
        -- cond = vim.g.snipper == "snippets",
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
        opts = {
          friendly_snippets = true,
          -- extended_filetypes = {
          --   eelixir = { "elixir" },
          -- },
          search_paths = { vim.fn.stdpath("config") .. "/snippets" },
        },
      },
      { "hrsh7th/cmp-buffer" },
      {
        "tzachar/cmp-fuzzy-buffer",
        dependencies = { "tzachar/fuzzy.nvim" },
      },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-path" },
      { "FelipeLema/cmp-async-path" },
      { "hrsh7th/cmp-cmdline" }, -- event = { "CmdlineEnter" } },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      -- { "hrsh7th/cmp-emoji" },
      { "f3fora/cmp-spell" },
      { "lukas-reineke/cmp-rg" },
      { "lukas-reineke/cmp-under-comparator" },
      -- { "davidsierradz/cmp-conventionalcommits" },
      { "dmitmel/cmp-cmdline-history" },
      { "andersevenrud/cmp-tmux", cond = false },
      -- { "kristijanhusak/vim-dadbod-completion"},
    },
    init = function() vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" } end,
    config = function()
      -- See `:help cmp`
      local cmp = require("cmp")
      -- local luasnip = require("luasnip")
      -- luasnip.config.setup({})

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local tab = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.snippet.jumpable(1) then
          vim.schedule(function() vim.snippet.jump(1) end)
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end
      local shift_tab = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.snippet.jumpable(-1) then
          vim.schedule(function() vim.snippet.jump(-1) end)
        else
          fallback()
        end
      end

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args) vim.snippet.expand(args.body) end,
        },
        -- NOTE: read `:help ins-completion`
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ["<C-n>"] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ["<C-p>"] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),

          ["<CR>"] = function(fallback)
            if vim.g.snipper == "luasnip" then
              cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace })(fallback)
            else
              if cmp.visible() then
                -- cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })(fallback)
              else
                fallback()
              end
            end
          end,
          ["<Tab>"] = {
            i = tab,
            s = tab,
            c = function()
              if vim.fn.getcmdline():sub(1, 1) == "!" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-z>", true, false, true), "n", false)
                return
              end
              if cmp.visible() then
                cmp.confirm({ select = true })
              else
                cmp.complete()
                cmp.select_next_item()
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
              end
            end,
          },
          ["<S-Tab>"] = {
            i = shift_tab,
            s = shift_tab,
            c = function()
              if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
              else
                cmp.complete()
              end
            end,
          },

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ["<C-Space>"] = cmp.mapping.complete({}),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          -- ["<C-l>"] = cmp.mapping(function()
          --   if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
          -- end, { "i", "s" }),
          -- ["<C-h>"] = cmp.mapping(function()
          --   if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
          -- end, { "i", "s" }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help" },
          { name = "snippets", group_index = 1, max_item_count = 5, keyword_length = 1 },
          -- { name = "luasnip", group_index = 1, max_item_count = 5, keyword_length = 1 },
          -- { name = "vsnip", group_index = 1, max_item_count = 5, keyword_length = 1 },
          { name = "nvim_lua" },
          {
            name = "nvim_lsp",
            group_index = 1,
            max_item_count = 35,
            entry_filter = function(entry)
              local kind = entry:get_kind()
              if vim.tbl_contains(vim.g.completion_exclusions, entry.source.source.client.name) then return false end
              return cmp.lsp.CompletionItemKind.Snippet ~= kind
              -- return true
            end,
          },
          { name = "async_path", option = { trailing_slash = true } },
          { name = "tmux", option = { all_panes = true } },
        }, {
          {
            name = "fuzzy_buffer",
            option = {
              min_match_length = 3,
              max_matches = 5,
              options = {
                get_bufnrs = function() return vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_list_wins()) end,
              },
            },
          },
          -- {
          --   name = "buffer",
          --   keyword_length = 4,
          --   max_item_count = 5,
          --   options = {
          --     get_bufnrs = function() return vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_list_wins()) end,
          --   },
          -- },
          { name = "spell" },
        }),
        -- sources = {
        --   { name = "nvim_lsp" },
        --   { name = "luasnip" },
        --   { name = "path" },
        -- },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        -- view = {
        --   entries = { name = "custom", direction = "bottom_up" },
        -- },
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "nvim_lsp_document_symbol" },
          { name = "fuzzy_buffer", option = { min_match_length = 3 } },
          -- { name = "buffer", option = { min_match_length = 2 } },
        },
      })

      cmp.setup.cmdline(":", {
        -- view = {
        --   entries = { name = "custom", direction = "bottom_up" },
        -- },
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "async_path" },
          -- { name = "path" },
          {
            name = "cmdline",
            keyword_length = 3,
            option = {
              ignore_cmds = { "Man", "!" },
            },
            keyword_pattern = [=[[^[:blank:]\!]*]=],
          },
          -- { name = "cmdline_history", priority = 10, max_item_count = 3 },
        }),
      })
    end,
  },
}
