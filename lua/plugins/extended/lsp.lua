local BORDER_STYLE = require("mega.settings").border
local augroup = require("mega.autocmds").augroup
local fmt = string.format

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
      local diagnostic_ns = vim.api.nvim_create_namespace("hldiagnosticregion")
      local diagnostic_timer
      local hl_cancel
      local hl_map = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticVirtualTextError",
        [vim.diagnostic.severity.WARN] = "DiagnosticVirtualTextWarn",
        [vim.diagnostic.severity.HINT] = "DiagnosticVirtualTextHint",
        [vim.diagnostic.severity.INFO] = "DiagnosticVirtualTextInfo",
      }

      require("lspconfig.ui.windows").default_options.border = BORDER_STYLE

      local function has_existing_floats()
        local winids = vim.api.nvim_tabpage_list_wins(0)
        for _, winid in ipairs(winids) do
          if vim.api.nvim_win_get_config(winid).zindex then return true end
        end
      end

      local function diagnostic_popup(opts)
        local bufnr = opts
        if type(opts) == "table" then bufnr = opts.buf end

        local diags = vim.diagnostic.open_float(bufnr, { focus = false, scope = "cursor" })

        -- If there's no diagnostic under the cursor show diagnostics of the entire line
        if not diags then vim.diagnostic.open_float(bufnr, { focus = false, scope = "line" }) end

        -- if not vim.g.git_conflict_detected and not has_existing_floats() then
        --   -- Try to open diagnostics under the cursor
        --   local diags = vim.diagnostic.open_float(bufnr, { focus = false, scope = "cursor" })
        --
        --   -- If there's no diagnostic under the cursor show diagnostics of the entire line
        --   if not diags then vim.diagnostic.open_float(bufnr, { focus = false, scope = "line" }) end
        --
        --   return diags
        -- end
      end

      local function goto_diagnostic_hl(dir)
        assert(dir == "prev" or dir == "next")
        local diagnostic = vim.diagnostic["get_" .. dir]()
        if not diagnostic then return end
        if diagnostic_timer then
          diagnostic_timer:close()
          hl_cancel()
        end
        vim.api.nvim_buf_set_extmark(0, diagnostic_ns, diagnostic.lnum, diagnostic.col, {
          end_row = diagnostic.end_lnum,
          end_col = diagnostic.end_col,
          hl_group = hl_map[diagnostic.severity],
        })
        hl_cancel = function()
          diagnostic_timer = nil
          hl_cancel = nil
          pcall(vim.api.nvim_buf_clear_namespace, 0, diagnostic_ns, 0, -1)
        end
        diagnostic_timer = vim.defer_fn(hl_cancel, 500)
        vim.diagnostic["goto_" .. dir]()
      end

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      local function on_attach(bufnr, client)
        -- if action opens up qf list, open the first item and close the list
        local function choose_list_first(options)
          vim.fn.setqflist({}, " ", options)
          vim.cmd.cfirst()
        end
        local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc }) end
        local icons = require("mega.settings").icons

        -- if client and client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
        --   vim.lsp.inlay_hint.enable(bufnr, true)
        --   -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        -- end

        map("<leader>lic", [[<cmd>LspInfo<CR>]], "connected client info")
        map("<leader>lim", [[<cmd>Mason<CR>]], "mason info")
        map("<leader>lil", [[<cmd>LspLog<CR>]], "logs (vsplit)")

        map("[d", function() goto_diagnostic_hl("prev") end, "Go to previous [D]iagnostic message")
        map("]d", function() goto_diagnostic_hl("next") end, "Go to next [D]iagnostic message")

        -- map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gd", function() vim.lsp.buf.definition({ on_list = choose_list_first }) end, "[g]oto [d]efinition")
        map("gD", function()
          vim.cmd.split({ mods = { tab = vim.fn.tabpagenr() + 1 } })
          vim.lsp.buf.definition({ on_list = choose_list_first })
        end, "[g]oto [d]efinition (split)")
        map("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration (e.g. to a header file in C)")

        map("gn", function()
          bufnr = vim.api.nvim_get_current_buf()
          local params = vim.lsp.util.make_position_params()
          local current_symbol = vim.fn.expand("<cword>")
          params.old_symbol = current_symbol
          params.context = { includeDeclaration = true }
          local clients = vim.lsp.get_clients()
          client = clients[1]
          for _, possible_client in pairs(clients) do
            if possible_client.server_capabilities.renameProvider then
              client = possible_client
              break
            end
          end
          local ns = vim.api.nvim_create_namespace("LspRenamespace")

          client.request("textDocument/references", params, function(_, result)
            if not result or vim.tbl_isempty(result) then
              vim.notify("Nothing to rename.")
              return
            end

            for _, v in ipairs(result) do
              if v.range then
                local buf = vim.uri_to_bufnr(v.uri)
                local line = v.range.start.line
                local start_char = v.range.start.character
                local end_char = v.range["end"].character
                if buf == bufnr then
                  print(line, start_char, end_char)
                  vim.api.nvim_buf_add_highlight(bufnr, ns, "LspReferenceWrite", line, start_char, end_char)
                end
              end
            end
            vim.cmd.redraw()
            local new_name = vim.fn.input({ prompt = fmt("%s (%d) -> ", params.old_symbol, #result) })
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
            if #new_name == 0 then return end
            vim.lsp.buf.rename(new_name)
          end, bufnr)
        end, "[r]ename")

        augroup("LspDiagnostics", {
          {
            event = { "CursorHold" },
            desc = "Show diagnostics",
            command = diagnostic_popup,
          },
        })

        if client and client.server_capabilities.documentHighlightProvider then
          augroup("LspDocumentHighlights", {
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

        local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
        local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

        local vim_diag = vim.diagnostic
        vim_diag.config({
          underline = true,
          signs = {
            text = {
              [vim_diag.severity.ERROR] = icons.lsp.error, -- alts: ▌
              [vim_diag.severity.WARN] = icons.lsp.warn,
              [vim_diag.severity.HINT] = icons.lsp.hint,
              [vim_diag.severity.INFO] = icons.lsp.info,
            },
            numhl = {
              [vim_diag.severity.ERROR] = "DiagnosticError",
              [vim_diag.severity.WARN] = "DiagnosticWarn",
              [vim_diag.severity.HINT] = "DiagnosticHint",
              [vim_diag.severity.INFO] = "DiagnosticInfo",
            },
            texthl = {
              [vim_diag.severity.ERROR] = "DiagnosticError",
              [vim_diag.severity.WARN] = "DiagnosticWarn",
              [vim_diag.severity.HINT] = "DiagnosticHint",
              [vim_diag.severity.INFO] = "DiagnosticInfo",
            },
            -- severity = { min = vim_diag.severity.WARN },
          },
          float = {
            -- border = BORDER_STYLE,
            max_width = max_width,
            max_height = max_height,
            -- severity = { min = vim_diag.severity.WARN },
          },
          severity_sort = true,
          virtual_text = {
            severity = { min = vim_diag.severity.ERROR },
          },
          update_in_insert = false,
        })

        -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        --   border = BORDER_STYLE,
        -- })
        -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        --   border = BORDER_STYLE,
        -- })

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
          show = function(_, bn, _, opts)
            -- Get all diagnostics from the whole buffer rather than just the
            -- diagnostics passed to the handler
            local diagnostics = vim.diagnostic.get(bn)
            -- Find the "worst" diagnostic per line
            local max_severity_per_line = {}
            for _, d in pairs(diagnostics) do
              local m = max_severity_per_line[d.lnum]
              if not m or d.severity < m.severity then max_severity_per_line[d.lnum] = d end
            end
            -- Pass the filtered diagnostics (with our custom namespace) to
            -- the original handler
            local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
            orig_signs_handler.show(ns, bn, filtered_diagnostics, opts)
          end,
          hide = function(_, bn) orig_signs_handler.hide(ns, bn) end,
        }
      end

      augroup("LspAttach", {
        {
          event = { "LspAttach" },
          desc = "Attach various functionality to an LSP-connected buffer/client",
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
    "mhanberg/output-panel.nvim",
    keys = {
      {
        "<leader>lip",
        ":OutputPanel<CR>",
        desc = "lsp: open output panel",
      },
    },
    event = "LspAttach",
    cmd = { "OutputPanel" },
    config = function() require("output_panel").setup() end,
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
                enable = true, -- control if completions are enabled. defaults to false
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
          on_attach = function(_client, bufnr)
            local map = vim.keymap.set
            map("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = bufnr, noremap = true })
            map("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = bufnr, noremap = true })
            map("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = bufnr, noremap = true })
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
