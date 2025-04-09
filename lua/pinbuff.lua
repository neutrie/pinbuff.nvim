local M = {}

---@alias PBslot  integer|string
---@alias PBbufnr integer

---@type PBState
local state = require("pinbuff.state")

---@type PBWindow
local window = require("pinbuff.window")

---@param opts? PBConfig.opts
function M.setup(opts)
  require("pinbuff.config"):setup(opts)
end

---Returns a function that calls `get_bufnr` and sets its value into the `slot`.
---@param slot PBslot
---@param get_bufnr? function: default is `vim.api.nvim_get_current_buf`
---@nodiscard
function M.setter(slot, get_bufnr)
  get_bufnr = get_bufnr or vim.api.nvim_get_current_buf
  local pb_setter = function()
    local bufnr = get_bufnr()
    if not bufnr then
      return
    end
    state.buffers[slot] = bufnr
    state.slots[bufnr] = slot
  end
  return pb_setter
end

---Returns a function that jumps to the bufnr in the `slot`.
---@param slot PBslot
---@nodiscard
function M.jumper(slot)
  local pb_jumper = function()
    local bufnr = state.buffers[slot]
    local can_jump = bufnr and vim.api.nvim_buf_is_loaded(bufnr)
    if can_jump then
      vim.api.nvim_set_current_buf(bufnr)
    end
  end
  return pb_jumper
end

---Returns the `bufnr` in the `slot`. Ignores unloaded buffers.
---@param slot PBslot
---@return PBbufnr|nil
function M.get_bufnr(slot)
  state:sync()
  return state.buffers[slot]
end

---Returns the `slot` of the `bufnr`. Ignores unloaded buffers.
---@param bufnr PBbufnr
---@return PBslot|nil
function M.get_slot(bufnr)
  state:sync()
  return state.slots[bufnr]
end

---Opens an interactive floating window containing currently pinned buffers.
---@return table<integer, integer>: handles { bufnr, win }
function M.open_float()
  local cursor_pos = { 1, 0 }
  local entries = window.make_entries()
  local current_bufnr = vim.api.nvim_get_current_buf()
  for i, e in ipairs(entries) do
    if current_bufnr == e.bufnr then
      cursor_pos[1] = i
      break
    end
  end
  return window:open_float(entries, cursor_pos)
end

return M
