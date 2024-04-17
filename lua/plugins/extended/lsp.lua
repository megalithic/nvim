local BORDER_STYLE = require("mega.settings").border

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "nvim-lua/lsp_extensions.nvim" },
      { "b0o/schemastore.nvim" },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        "j-hui/fidget.nvim",
        opts = {
          progress = {
            display = {
              done_icon = require("mega.settings").icons.lsp.ok,
            },
          },
          notification = {
            view = {
              group_separator = "─────", -- digraph `hh`
            },
            window = {
              winblend = 0,
            },
          },
        },
      },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      local augroup = require("mega.autocmds").augroup
      require("lspconfig.ui.windows").default_options.border = BORDER_STYLE

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      local function on_attach(bufnr, client)
        local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc }) end
        local icons = require("mega.settings").icons

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration (e.g. to a header file in C)")

        if client and client.server_capabilities.documentHighlightProvider then
          augroup("LSP-document-highlights", {
            {
              event = { "CursorHold", "CursorHoldI" },
              buffer = bufnr,
              command = vim.lsp.buf.document_highlight,
            },
            {
              event = { "CursorMoved", "CursorMovedI" },
              buffer = bufnr,
              command = vim.lsp.buf.clear_references,
            },
          })
        end

        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          update_in_insert = false,
          underline = true,
          severity_sort = true,
          float = { border = BORDER_STYLE },
        })

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = BORDER_STYLE,
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = BORDER_STYLE,
        })

        local signs = { Error = icons.lsp.error, Warn = icons.lsp.warn, Hint = icons.lsp.hint, Info = icons.lsp.info }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        -- Create a custom namespace. This will aggregate signs from all other
        -- namespaces and only show the one with the highest severity on a
        -- given line
        local ns = vim.api.nvim_create_namespace("mega_lsp_diagnostics")
        -- Get a reference to the original signs handler
        local orig_signs_handler = vim.diagnostic.handlers.signs
        -- Override the built-in signs handler
        vim.diagnostic.handlers.signs = {
          show = function(_, bufnr, _, opts)
            -- Get all diagnostics from the whole buffer rather than just the
            -- diagnostics passed to the handler
            local diagnostics = vim.diagnostic.get(bufnr)
            -- Find the "worst" diagnostic per line
            local max_severity_per_line = {}
            for _, d in pairs(diagnostics) do
              local m = max_severity_per_line[d.lnum]
              if not m or d.severity < m.severity then max_severity_per_line[d.lnum] = d end
            end
            -- Pass the filtered diagnostics (with our custom namespace) to
            -- the original handler
            local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
            orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
          end,
          hide = function(_, bufnr) orig_signs_handler.hide(ns, bufnr) end,
        }
      end

      augroup("LSP", {
        {
          event = { "LspAttach" },
          desc = "",
          command = function(evt)
            local client = vim.lsp.get_client_by_id(evt.data.client_id)
            if client ~= nil then on_attach(evt.buf, client) end
          end,
        },
      })

      local lspconfig = require("lspconfig")

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      -- local servers = {
      --   -- clangd = {},
      --   -- gopls = {},
      --   -- pyright = {},
      --   -- rust_analyzer = {},
      --   -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      --   --
      --   -- Some languages (like typescript) have entire language plugins that can be useful:
      --   --    https://github.com/pmizio/typescript-tools.nvim
      --   --
      --   -- But for many setups, the LSP (`tsserver`) will work just fine
      --   -- tsserver = {},
      --   --
      --
      --   lua_ls = {
      --     -- cmd = {...},
      --     -- filetypes = { ...},
      --     -- capabilities = {},
      --     settings = {
      --       Lua = {
      --         completion = {
      --           callSnippet = 'Replace',
      --         },
      --         -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      --         -- diagnostics = { disable = { 'missing-fields' } },
      --       },
      --     },
      --   },
      -- }
      local servers = require("mega.servers")
      if servers == nil then return end

      servers.load_unofficial()

      local function get_config(name)
        local config = name and servers.list[name] or {}
        if not config or config == nil then return end

        if type(config) == "function" then
          config = config()
          if not config or config == nil then return end
        end

        config.flags = { debounce_text_changes = 150 }
        -- config.on_init = on_init
        -- config.capabilities = get_server_capabilities()
        -- -- FIXME: This locks up lexical:
        -- -- if config.on_attach then
        -- --   config.on_attach = function(client, bufnr)
        -- --     dd("on_attach provided from servers.lua config")
        -- --     on_attach(client, bufnr)
        -- --     config.on_attach(client, bufnr)
        -- --   end
        -- -- else
        -- --   config.on_attach = on_attach
        -- -- end
        -- config.on_attach = on_attach

        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        return config
      end

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      local tools = {
        "luacheck",
        "prettier",
        "prettierd",
        "selene",
        "shellcheck",
        "shfmt",
        -- "solargraph",
        "stylua",
        "yamlfmt",
        -- "black",
        -- "buf",
        -- "cbfmt",
        -- "deno",
        -- "elm-format",
        -- "eslint_d",
        -- "fixjson",
        -- "flake8",
        -- "goimports",
        -- "isort",
      }

      require("mason").setup()
      local mr = require("mason-registry")
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers.list or {})
      vim.list_extend(ensure_installed, {
        "black",
        "eslint_d",
        "eslint_d",
        "isort",
        "prettier",
        "prettierd",
        "ruff",
        "stylua",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        automatic_installation = true,
        handlers = {
          function(server_name)
            if servers ~= nil then
              -- loads our custom set of lsp servers

              -- for server, _ in pairs(servers.list) do
              local cfg = get_config(server_name)
              if cfg ~= nil then
                -- if server == "nextls" then dd(cfg) end

                lspconfig[server_name].setup(cfg)
              end
              -- end
            end

            -- local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            -- server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },

  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    enabled = false,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup({
        nextls = {
          enable = true, -- defaults to false
          init_options = {
            experimental = {
              completions = {
                enable = false, -- control if completions are enabled. defaults to false
              },
            },
          },
        },
        credo = {},
        elixirls = {
          enable = true,
          settings = elixirls.settings({
            dialyzerEnabled = false,
            enableTestLenses = false,
          }),
          on_attach = function(client, bufnr)
            vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
          end,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
  },
}
