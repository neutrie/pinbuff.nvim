---@class PBWindow
local M = {}

---@type PBState
local state = require("pinbuff.state")

---@type PBConfig
local config = require("pinbuff.config")

---Returns entries for floating window based on the current state.
---@return table<table<PBslot, PBbufnr, string>>: entries {slot, bufnr, line}
function M.make_entries()
  state:sync()
  local entries = {}
  for slot, bufnr in pairs(state.buffers) do
    local entry = {}
    entry.slot = slot
    entry.bufnr = bufnr
    entry.line = config.options.entry_line(slot, bufnr)
    table.insert(entries, entry)
  end
  return entries
end

---@param entries? table<table<PBslot, PBbufnr, string>>: entries {slot, bufnr, line}
---@param cursor_pos? table<integer, integer>: `{pos}` option for `nvim_win_set_cursor()`
---@return table<integer, integer>: handles { bufnr, win }
function M:open_float(entries, cursor_pos)
  entries = entries or self.make_entries()
  cursor_pos = cursor_pos or { 1, 0 }
  local float_config = config.options.float_config(#entries)

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("textwidth", 0, { buf = bufnr })

  -- set lines and highlights
  for idx, entry in ipairs(entries) do
    local line_text = {}
    local line_highlights = {}
    local hl_start = 0
    for _, part in ipairs(entry.line) do
      local str = part.str or ""
      local hl = part.hl or "PinBuffNormalFloat"
      local hl_end = hl_start + #str
      table.insert(line_text, str)
      table.insert(line_highlights, {
        hl_group = hl,
        col_start = hl_start,
        col_end = hl_end,
      })
      hl_start = hl_end
    end
    line_text = { table.concat(line_text) }
    vim.api.nvim_buf_set_lines(bufnr, idx - 1, idx, false, line_text)
    for _, h in ipairs(line_highlights) do
      vim.api.nvim_buf_add_highlight(bufnr, -1, h.hl_group, idx - 1, h.col_start, h.col_end)
    end
  end

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  for opt, value in pairs(config.options.buf_opts) do
    vim.api.nvim_set_option_value(opt, value, { buf = bufnr })
  end

  local win = vim.api.nvim_open_win(bufnr, true, float_config)
  for opt, value in pairs(config.options.win_opts) do
    vim.api.nvim_set_option_value(opt, value, { win = win })
  end

  -- clamp between first and last line
  cursor_pos[1] = vim.fn.max({ 1, vim.fn.min({ #entries, cursor_pos[1] }) })
  vim.api.nvim_win_set_cursor(win, cursor_pos)

  -- close win on focus loss
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    group = vim.api.nvim_create_augroup("pinbuff-win-leave", { clear = true }),
    buffer = bufnr,
    once = true,
    callback = function(_)
      vim.api.nvim_win_close(win, true)
    end,
  })

  ---@class PBWindow.action
  local actions = {}

  actions.close = function()
    vim.api.nvim_win_close(win, true)
  end

  actions.refresh = function(row_shift)
    local current_cursor_pos = vim.api.nvim_win_get_cursor(win)
    local row = current_cursor_pos[1] + (row_shift and row_shift or 0)
    actions.close()
    self:open_float(self.make_entries(), { row, 0 })
  end

  actions.select = function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local current_entry = entries[idx]
    if not current_entry then
      return
    end
    actions.close()
    vim.api.nvim_set_current_buf(current_entry.bufnr)
  end

  actions.swap_prev = function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local current_entry = entries[idx]
    local prev_entry = entries[idx - 1]
    if not current_entry or not prev_entry then
      return
    end

    state.buffers[current_entry.slot] = prev_entry.bufnr
    state.buffers[prev_entry.slot] = current_entry.bufnr
    state.slots[current_entry.bufnr] = prev_entry.slot
    state.slots[prev_entry.bufnr] = current_entry.slot
    actions.refresh(-1)
  end

  actions.swap_next = function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local current_entry = entries[idx]
    local next_entry = entries[idx + 1]
    if not current_entry or not next_entry then
      return
    end

    state.buffers[current_entry.slot] = next_entry.bufnr
    state.buffers[next_entry.slot] = current_entry.bufnr
    state.slots[current_entry.bufnr] = next_entry.slot
    state.slots[next_entry.bufnr] = current_entry.slot
    actions.refresh(1)
  end

  actions.clear_current = function()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local current_entry = entries[idx]
    if not current_entry then
      return
    end
    state.buffers[current_entry.slot] = nil
    state.slots[current_entry.bufnr] = nil
    actions.refresh()
  end

  actions.clear_all = function()
    for _, e in ipairs(entries) do
      state.buffers[e.slot] = nil
      state.slots[e.bufnr] = nil
    end
    actions.refresh()
  end

  for key, action in pairs(config.options.float_keymaps) do
    if actions[action] then
      vim.keymap.set("n", key, actions[action], { buffer = bufnr, silent = true })
    end
  end

  return { bufnr, win }
end

return M
