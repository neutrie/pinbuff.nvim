---@class PBState
local M = {}

---@type { [PBslot]: PBbufnr }
M.buffers = {}

---@type { [PBbufnr]: PBslot }: inverse of buffers
M.slots = {}

---@param slot PBslot
function M:clear_slot(slot)
  local bufnr = self.buffers[slot]
  if not bufnr then
    return
  end
  self.buffers[slot] = nil
  self.slots[bufnr] = nil
end

---Clears all the slots containing unloaded buffers.
function M:sync()
  for slot, bufnr in pairs(self.buffers) do
    if not vim.api.nvim_buf_is_loaded(bufnr) then
      self:clear_slot(slot)
    end
  end
end

return M
