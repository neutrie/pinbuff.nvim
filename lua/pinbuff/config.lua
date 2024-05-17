---@class PBConfig
local M = {}

---@class PBConfig.opts
M.defaults = {
  ---Returns a table of pairs `{str, hl}` to be displayed for the entry in the floating window.
  ---@param slot PBslot
  ---@param bufnr PBbufnr
  entry_line = function(slot, bufnr)
    local path_full = vim.api.nvim_buf_get_name(bufnr)
    local path_short = vim.fn.pathshorten(path_full, 2)
    local path_base = vim.fs.basename(path_full)
    local line = {
      { str = tostring(slot), hl = "PinBuffSlot" },
      { str = " -> ", hl = "PinBuffNonText" },
      { str = ("%3d: "):format(bufnr), hl = "PinBuffBufnr" },
      { str = ("%s "):format(path_base), hl = "PinBuffNormalFloat" },
      { str = ("(%s)"):format(path_short), hl = "PinBuffNonText" },
    }
    return line
  end,

  ---Returns a `{config}` map for `nvim_open_win()`
  ---@param entries_count integer
  float_config = function(entries_count)
    local min_width = 40
    local min_height = 5
    local c = {}
    c.width = vim.fn.max({ vim.fn.round(vim.o.columns / 2), min_width })
    c.height = vim.fn.max({ entries_count, min_height })
    c.col = (vim.o.columns / 2) - c.width / 2
    c.row = ((vim.o.lines - vim.o.cmdheight) / 2) - c.height / 2
    c.style = "minimal"
    c.border = "rounded"
    c.relative = "editor"
    c.anchor = "NW"
    c.noautocmd = true
    return c
  end,

  ---@type { [string]: any }: map of `{name}: {value}` pairs for `nvim_set_option_value()`
  buf_opts = {},

  ---@type { [string]: any }: map of `{name}: {value}` pairs for `nvim_set_option_value()`
  win_opts = {
    wrap = false,
    scrolloff = 0,
  },

  ---@see PBWindow.action
  float_keymaps = {
    ["<CR>"] = "select",
    ["q"] = "close",
    ["Q"] = "close",
    ["<ESC>"] = "close",
    ["<C-c>"] = "close",
    ["x"] = "clear_current",
    ["X"] = "clear_all",
    ["K"] = "swap_prev",
    ["<M-k>"] = "swap_prev",
    ["J"] = "swap_next",
    ["<M-j>"] = "swap_next",
  },
}

---@type PBConfig.opts
M.options = {}

---@param opts? PBConfig.opts
function M:setup(opts)
  self.options = vim.tbl_deep_extend("force", {}, self.defaults, opts or {})
end

return M
