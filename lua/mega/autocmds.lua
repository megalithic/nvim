local fmt = string.format
local U = require("mega.utils")

local M = {}

--- Validate the keys passed to mega.augroup are valid
---@param name string
---@param cmd Autocommand
local function validate_autocmd(name, cmd)
  local keys = { "event", "buffer", "pattern", "desc", "callback", "command", "group", "once", "nested" }
  local incorrect = U.fold(function(accum, _, key)
    if not vim.tbl_contains(keys, key) then table.insert(accum, key) end
    return accum
  end, cmd, {})
  if #incorrect == 0 then return end
  vim.schedule(
    function()
      vim.notify("Incorrect keys: " .. table.concat(incorrect, ", "), vim.log.levels.ERROR, {
        title = fmt("Autocmd: %s", name),
      })
    end
  )
end

---@class Autocommand
---@field desc string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
---@field nested  boolean
---@field once    boolean
---@field buffer  number
---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param ... Autocommand A list of autocommands to create (variadic parameter)
---@return number
function M.augroup(name, commands)
  assert(name ~= "User", "The name of an augroup CANNOT be User")

  local id = vim.api.nvim_create_augroup(name, { clear = true })

  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == "function"
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = "mega-" .. id,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end

  return id
end

function M.apply()
  M.augroup("Startup", {
    {
      event = { "VimEnter" },
      pattern = { "*" },
      once = true,
      desc = "Crazy behaviours for opening vim with arguments (or not)",
      command = function(args)
        -- TODO: handle situations where 2 file names given and the second is of the shape of a line number, e.g. `:200`;
        -- maybe use this? https://github.com/stevearc/dotfiles/commit/db4849d91328bb6f39481cf2e009866911c31757
        local arg = vim.api.nvim_eval("argv(0)")
        -- print("startup")
        -- print(vim.inspect(arg))

        if
          not vim.g.started_by_firenvim
          and (not vim.env.TMUX_POPUP and vim.env.TMUX_POPUP ~= 1)
          and not vim.tbl_contains({ "NeogitStatus" }, vim.bo[args.buf].filetype)
        then
          if vim.fn.argc() > 1 then
            local linenr = string.match(vim.fn.argv(1), "^:(%d+)$")
            if string.find(vim.fn.argv(1), "^:%d*") ~= nil then
              vim.cmd.edit({ args = { vim.fn.argv(0) } })
              pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(linenr), 0 })
              vim.api.nvim_buf_delete(args.buf + 1, { force = true })
            else
              vim.schedule(function()
                -- mega.resize_windows(args.buf)
                -- require("virt-column").update()
                pcall(mega.resize_windows, args.buf)
                pcall(require("virt-column").update)
              end)
            end
          elseif vim.fn.argc() == 1 then
            if vim.fn.isdirectory(arg) == 1 then
              -- require("oil").open(arg)
              local ok, oil = pcall(require, "oil")
              if ok then oil.open(arg) end
            else
              -- handle editing an argument with `:300`(line number) at the end
              local bufname = vim.api.nvim_buf_get_name(args.buf)
              local root, line = bufname:match("^(.*):(%d+)$")
              if vim.fn.filereadable(bufname) == 0 and root and line and vim.fn.filereadable(root) == 1 then
                vim.schedule(function()
                  vim.cmd.edit({ args = { root } })
                  pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), 0 })
                  vim.api.nvim_buf_delete(args.buf, { force = true })
                end)
              end
            end
          elseif vim.fn.isdirectory(arg) == 1 then
            local ok, oil = pcall(require, "oil")
            if ok then oil.open(arg) end
            -- elseif _G.picker ~= nil and _G.picker[vim.g.picker] ~= nil and _G.picker[vim.g.picker]["startup"] then
            --   _G.picker[vim.g.picker]["startup"](args)
          end
        end
      end,
    },
  })

  M.augroup("HighlightYank", {
    {
      desc = "Highlight when yanking (copying) text",
      event = { "TextYankPost" },
      command = function() vim.highlight.on_yank() end,
    },
  })

  M.augroup("CheckOutsideTime", {
    desc = "Automatically check for changed files outside vim",
    event = { "WinEnter", "BufWinEnter", "BufWinLeave", "BufRead", "BufEnter", "FocusGained" },
    command = "silent! checktime",
  })

  M.augroup("SmartCloseBuffers", {
    {
      event = { "FileType" },
      desc = "Smart close certain filetypes with `q`",
      pattern = { "*" },
      command = function()
        local is_unmapped = vim.fn.hasmapto("q", "n") == 0
        local is_eligible = is_unmapped
          or vim.wo.previewwindow
          or vim.tbl_contains({}, vim.bo.buftype)
          or vim.tbl_contains({
            "help",
            "git-status",
            "git-log",
            "oil",
            "dbui",
            "fugitive",
            "fugitiveblame",
            "LuaTree",
            "log",
            "tsplayground",
            "startuptime",
            "outputpanel",
            "preview",
            "qf",
            "man",
            "terminal",
            "lspinfo",
            "neotest-output",
            "neotest-output-panel",
            "query",
            "elixirls",
          }, vim.bo.filetype)
        if is_eligible then
          map("n", "q", function()
            if vim.fn.winnr("$") ~= 1 then
              vim.api.nvim_win_close(0, true)
              vim.cmd("wincmd p")
            end
          end, { buffer = 0, nowait = true, desc = "smart buffer quit" })
        end
      end,
    },
  })
end

return M
