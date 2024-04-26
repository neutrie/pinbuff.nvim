if vim.g.loaded_pinbuff == 1 then
  return
end
vim.g.loaded_pinbuff = 1

local higlights = {
  PinBuffNormalFloat = { default = true, link = "NormalFloat" },
  PinBuffNonText = { default = true, link = "NonText" },
  PinBuffSlot = { default = true, link = "Keyword" },
  PinBuffBufnr = { default = true, link = "PinBuffNonText" },
}

for k, v in pairs(higlights) do
  vim.api.nvim_set_hl(0, k, v)
end
